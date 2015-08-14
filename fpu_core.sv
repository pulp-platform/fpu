////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Lukas Mueller -- lukasmue@student.ethz.ch                  //
//                 Thomas Gautschi -- gauthoma@student.ethz.ch                //
//		                                                                        //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    26/10/2014                                                 // 
// Design Name:    FPU                                                        // 
// Module Name:    fpu.sv                                                     //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Floating point unit core (all datapaths put together)      //
//                                                                            //
//                                                                            //
//                                                                            //
// Revision:                                                                  //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "defines_fpu.sv"

module fpu_core
  (
   //Clock and reset
   input logic 	       Clk_CI,
   input logic 	       Rst_RBI,
   input logic         Enable_SI,

   //Input Operands
   input logic [31:0]  Operand_a_DI,
   input logic [31:0]  Operand_b_DI,
   input logic [1:0]   RM_SI,    //Rounding Mode
   input logic [3:0]   OP_SI,

   input logic Stall_SI,

   output logic [31:0] Result_DO,
   //Output-Flags
   output logic        OF_SO,    //Overflow
   output logic        UF_SO,    //Underflow
   output logic        Zero_SO,  //Result zero
   output logic        IX_SO,    //Result inexact
   output logic        IV_SO,    //Result invalid
   output logic        Inf_SO    //Infinity
   );
   
   //Internal Operands
   logic [31:0] Operand_a_DP;
   logic [31:0] Operand_a_DN;
   logic [31:0] Operand_b_DP;
   logic [31:0] Operand_b_DN;

   logic [1:0]  RM_SP;
   logic [1:0]  RM_SN;
   logic [3:0]  OP_SP;
   logic [3:0]  OP_SN;
   logic        Enable_SP;
   logic        Enable_SN;
   
   
   assign Operand_a_DN = (Stall_SI) ? Operand_a_DP : Operand_a_DI;
   assign Operand_b_DN = (Stall_SI) ? Operand_b_DP : Operand_b_DI;               
   assign RM_SN = (Stall_SI) ? RM_SP : RM_SI;                             
   assign OP_SN = (Stall_SI) ? OP_SP : OP_SI;
   assign Enable_SN = (Stall_SI) ? Enable_SP : Enable_SI;
                             
   
   always_ff @(posedge Clk_CI, negedge Rst_RBI)
     begin : InputRegister
        if (~Rst_RBI)
          begin
             Operand_a_DP <= '0;
             Operand_b_DP <= '0;
             RM_SP <= '0;
             OP_SP <= '0;
             Enable_SP <= '0;
          end
        else
          begin
             Operand_a_DP <= Operand_a_DN;
             Operand_b_DP <= Operand_b_DN;
             RM_SP <= RM_SN;
             OP_SP <= OP_SN;
             Enable_SP <= Enable_SN;
          end // else: !if(~Rst_RBI)
     end // always_ff @ (posedge Clk_CI, negedge Rst_RBI)
   

   //Operand components
   logic        Sign_a_D;
   logic        Sign_b_D;
   logic [7:0]  Exp_a_D;
   logic [7:0]  Exp_b_D;
   logic [23:0] Mant_a_D;
   logic [23:0] Mant_b_D;

   //Hidden Bits
   logic        Hb_a_D;
   logic        Hb_b_D;

   //Pre-Normalizer result
   logic signed [9:0] Exp_prenorm_D;
   logic [47:0]       Mant_prenorm_D;

   //Post-Normalizer result
   logic        Sign_norm_D;
   logic [7:0]  Exp_norm_D;
   logic [23:0] Mant_norm_D;
      
   //Output result
   logic [31:0] Result_D;
   logic        Sign_res_D;
   logic [7:0]  Exp_res_D;
   logic [23:0] Mant_res_D;

   /////////////////////////////////////////////////////////////////////////////
   // Disassemble operands
   /////////////////////////////////////////////////////////////////////////////
   assign Sign_a_D = Operand_a_DP[31];
   assign Sign_b_D = (OP_SP == `FP_OP_SUB) ? ~Operand_b_DP[31] : Operand_b_DP[31];
   assign Exp_a_D = Operand_a_DP[30:23]; 
   assign Exp_b_D = Operand_b_DP[30:23]; 
   assign Mant_a_D = {Hb_a_D,Operand_a_DP[22:0]};
   assign Mant_b_D = {Hb_b_D,Operand_b_DP[22:0]};
   
   assign Hb_a_D = | Exp_a_D;
   assign Hb_b_D = | Exp_b_D;
   
   /////////////////////////////////////////////////////////////////////////////
   // Adder
   /////////////////////////////////////////////////////////////////////////////
   logic              Sign_prenorm_add_D;
   logic signed [9:0] Exp_prenorm_add_D;
   logic [47:0]       Mant_prenorm_add_D;
   logic              EnableAdd_S;

   assign EnableAdd_S = Enable_SP & ((OP_SP == `FP_OP_ADD)|(OP_SP == `FP_OP_SUB));
   
   fpu_add adder
     (
      .Sign_a_DI(EnableAdd_S ? Sign_a_D : '0),
      .Sign_b_DI(EnableAdd_S ? Sign_b_D: '0),
      .Exp_a_DI(EnableAdd_S ? Exp_a_D: '0),
      .Exp_b_DI(EnableAdd_S ? Exp_b_D: '0),
      .Mant_a_DI(EnableAdd_S ? Mant_a_D: '0),
      .Mant_b_DI(EnableAdd_S ? Mant_b_D: '0),

      .Sign_prenorm_DO(Sign_prenorm_add_D),
      .Exp_prenorm_DO(Exp_prenorm_add_D),
      .Mant_prenorm_DO(Mant_prenorm_add_D)
      );

   /////////////////////////////////////////////////////////////////////////////
   // Multiplier
   /////////////////////////////////////////////////////////////////////////////
   logic              Sign_prenorm_mult_D;
   logic signed [9:0] Exp_prenorm_mult_D;
   logic [47:0]       Mant_prenorm_mult_D;
   logic              EnableMult_S;

   assign EnableMult_S =  Enable_SP & (OP_SP == `FP_OP_MUL);
   
 
   fpu_mult multiplier
     (
      .Sign_a_DI(EnableMult_S ? Sign_a_D : '0),
      .Sign_b_DI(EnableMult_S ? Sign_b_D : '0),
      .Exp_a_DI(EnableMult_S ? Exp_a_D : '0),
      .Exp_b_DI(EnableMult_S ? Exp_b_D : '0),
      .Mant_a_DI(EnableMult_S ? Mant_a_D : '0),
      .Mant_b_DI(EnableMult_S ? Mant_b_D : '0),

      .Sign_prenorm_DO(Sign_prenorm_mult_D),
      .Exp_prenorm_DO(Exp_prenorm_mult_D),
      .Mant_prenorm_DO(Mant_prenorm_mult_D)
      );

   /////////////////////////////////////////////////////////////////////////////
   // Integer to floating point conversion
   /////////////////////////////////////////////////////////////////////////////
   logic              Sign_prenorm_itof_D;
   logic signed [9:0] Exp_prenorm_itof_D;
   logic [47:0]       Mant_prenorm_itof_D;
   logic              EnableITOF_S;

   assign EnableITOF_S = Enable_SP & (OP_SP == `FP_OP_ITOF);

   fpu_itof int2fp
     (
      .Operand_a_DI(EnableITOF_S ? Operand_a_DP : '0),

      .Sign_prenorm_DO(Sign_prenorm_itof_D),
      .Exp_prenorm_DO(Exp_prenorm_itof_D),
      .Mant_prenorm_DO(Mant_prenorm_itof_D)
      );

   /////////////////////////////////////////////////////////////////////////////
   // Floating point to integer conversion
   /////////////////////////////////////////////////////////////////////////////
   logic [31:0]       Result_ftoi_D;
   logic              UF_ftoi_S;
   logic              OF_ftoi_S;
   logic              Zero_ftoi_S;
   logic              IX_ftoi_S;
   logic              IV_ftoi_S;
   logic              Inf_ftoi_S;
   logic              EnableFTOI_S;
   
   assign EnableFTOI_S = Enable_SP & (OP_SP == `FP_OP_FTOI);
      
   fpu_ftoi fp2int
     (
      .Sign_a_DI(EnableFTOI_S ? Sign_a_D : '0),
      .Exp_a_DI(EnableFTOI_S ? Exp_a_D : '0),
      .Mant_a_DI(EnableFTOI_S ? Mant_a_D : '0),

      .Result_DO(Result_ftoi_D),
      .UF_SO(UF_ftoi_S),
      .OF_SO(OF_ftoi_S),
      .Zero_SO(Zero_ftoi_S),
      .IX_SO(IX_ftoi_S),
      .IV_SO(IV_ftoi_S),
      .Inf_SO(Inf_ftoi_S)
      );
   
   
   /////////////////////////////////////////////////////////////////////////////
   // Normalizer
   ///////////////////////////////////////////////////////////////////////////// 

   logic Mant_rounded_S;
   logic Exp_OF_S;
   logic Exp_UF_S;
   
   always_comb
     begin
        Sign_norm_D = '0;
        Exp_prenorm_D = '0;
        Mant_prenorm_D = '0;
        case (OP_SP)
          `FP_OP_ADD, `FP_OP_SUB:
            begin
               Sign_norm_D = Sign_prenorm_add_D;
               Exp_prenorm_D = Exp_prenorm_add_D;
               Mant_prenorm_D = Mant_prenorm_add_D;
            end
          `FP_OP_MUL:
            begin
               Sign_norm_D = Sign_prenorm_mult_D;
               Exp_prenorm_D = Exp_prenorm_mult_D;
               Mant_prenorm_D = Mant_prenorm_mult_D;
            end
          `FP_OP_ITOF:
            begin
               Sign_norm_D = Sign_prenorm_itof_D;
               Exp_prenorm_D = Exp_prenorm_itof_D;
               Mant_prenorm_D = Mant_prenorm_itof_D;
            end
            endcase //case (OP_S)
     end //always_comb begin

   
   fpnorm normalizer
     (
      .Mant_in_DI (Mant_prenorm_D),
      .Exp_in_DI (Exp_prenorm_D),
      .Sign_in_DI (Sign_norm_D),

      .RM_SI (RM_SP),
      .OP_SI (OP_SP),
      
      .Mant_res_DO (Mant_norm_D),
      .Exp_res_DO (Exp_norm_D),

      .Rounded_SO (Mant_rounded_S),
      .Exp_OF_SO (Exp_OF_S),
      .Exp_UF_SO (Exp_UF_S)
      );

   
   /////////////////////////////////////////////////////////////////////////////
   // Exceptions/Flags
   ///////////////////////////////////////////////////////////////////////////// 
   logic UF_S;
   logic OF_S;
   logic Zero_S;
   logic IX_S;
   logic IV_S;
   logic Inf_S;
   
   logic Exp_toZero_S;
   logic Exp_toInf_S;
   logic Mant_toZero_S;
            
   fpexc except
     (
      .Mant_a_DI (Mant_a_D),
      .Mant_b_DI (Mant_b_D),
      .Exp_a_DI (Exp_a_D),
      .Exp_b_DI (Exp_b_D),
      .Sign_a_DI (Sign_a_D),
      .Sign_b_DI (Sign_b_D),

      .Mant_norm_DI (Mant_norm_D),
      .Exp_res_DI (Exp_norm_D),

      .Op_SI (OP_SP),
      
      .UF_SI(UF_ftoi_S),
      .OF_SI(OF_ftoi_S),
      .Zero_SI(Zero_ftoi_S),
      .IX_SI(IX_ftoi_S),
      .IV_SI(IV_ftoi_S),
      .Inf_SI(Inf_ftoi_S),
      
      .Mant_rounded_SI (Mant_rounded_S),
      .Exp_OF_SI (Exp_OF_S),
      .Exp_UF_SI (Exp_UF_S),

      .Exp_toZero_SO (Exp_toZero_S),
      .Exp_toInf_SO (Exp_toInf_S),
      .Mant_toZero_SO (Mant_toZero_S),

      .UF_SO (UF_S),
      .OF_SO (OF_S),
      .Zero_SO (Zero_S),
      .IX_SO (IX_S),
      .IV_SO (IV_S),
      .Inf_SO (Inf_S)
      );
               
   
   /////////////////////////////////////////////////////////////////////////////
   // Output Assignments
   /////////////////////////////////////////////////////////////////////////////
   
   assign Sign_res_D = Zero_S ? 1'b0 : Sign_norm_D;
   always_comb
     begin
        Exp_res_D <= Exp_norm_D;
        if (Exp_toZero_S)
          Exp_res_D <= 8'h00;
        else if (Exp_toInf_S)
          Exp_res_D <= 8'hff;
     end
   assign Mant_res_D = Mant_toZero_S ? 24'b0 : Mant_norm_D;

   assign Result_D = (OP_SP == `FP_OP_FTOI) ? Result_ftoi_D : {Sign_res_D, Exp_res_D, Mant_res_D[22:0]};

   assign Result_DO = Result_D;
   assign UF_SO     = UF_S;
   assign OF_SO     = OF_S;
   assign Zero_SO   = Zero_S;
   assign IX_SO     = IX_S;
   assign IV_SO     = IV_S;
   assign Inf_SO    = Inf_S;
        
   
endmodule // fpu
