////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Lukas Mueller -- lukasmue@student.ethz.ch                  //
//                 Thomas Gautschi -- gauthoma@student.ethz.ch                //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    06/10/2014                                                 // 
// Design Name:    FPU                                                        // 
// Module Name:    fpnorm.sv                                                  //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Handles all exceptions and sets output and flags           //
//                 accordingly.                                               //
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

module fpexc 
  (//Input
   input logic [23:0] Mant_a_DI,
   input logic [23:0] Mant_b_DI,
   input logic [7:0]  Exp_a_DI,
   input logic [7:0]  Exp_b_DI,
   input logic        Sign_a_DI,
   input logic        Sign_b_DI,

   input logic [23:0] Mant_norm_DI,
   input logic [7:0]  Exp_res_DI,

   input logic [3:0]  Op_SI,

   input logic Mant_rounded_SI,
   input logic Exp_OF_SI,
   input logic Exp_UF_SI,

   input logic OF_SI,
   input logic UF_SI,
   input logic Zero_SI,
   input logic IX_SI,
   input logic IV_SI,
   input logic Inf_SI,
   
   //Output
   output logic Exp_toZero_SO,
   output logic Exp_toInf_SO,
   output logic Mant_toZero_SO,

   output logic OF_SO,
   output logic UF_SO,
   output logic Zero_SO,
   output logic IX_SO,
   output logic IV_SO,
   output logic Inf_SO
   ) ;

 
   /////////////////////////////////////////////////////////////////////////////
   // preliminary checks for infinite/zero operands
   /////////////////////////////////////////////////////////////////////////////
   
   logic        Inf_a_S;
   logic        Inf_b_S;
   logic        Zero_a_S;
   logic        Zero_b_S;
     
   logic        Mant_zero_S;
  
   assign Inf_a_S = (Exp_a_DI == 8'hff);
   assign Inf_b_S = (Exp_b_DI == 8'hff);

   assign Zero_a_S = (Exp_a_DI == 8'h0) & (Mant_a_DI == 24'h0);
   assign Zero_b_S = (Exp_b_DI == 8'h0) & (Mant_b_DI == 24'h0);

   assign Mant_zero_S = Mant_norm_DI == 24'h0;
   
   
   /////////////////////////////////////////////////////////////////////////////
   // flag assignments
   /////////////////////////////////////////////////////////////////////////////
   
   assign OF_SO   = (Op_SI == `FP_OP_FTOI) ? OF_SI : (Exp_OF_SI & ~Mant_zero_S) | (~IV_SO & (Inf_a_S ^ Inf_b_S) & (Op_SI != `FP_OP_ITOF));
   assign UF_SO   = (Op_SI == `FP_OP_FTOI) ? UF_SI : Exp_UF_SI & Mant_rounded_SI;
   assign Zero_SO = (Op_SI == `FP_OP_FTOI) ? Zero_SI : (Mant_zero_S & ~IV_SO); 
   assign IX_SO   = (Op_SI == `FP_OP_FTOI) ? IX_SI : Mant_rounded_SI | OF_SO; 

   always_comb //check operation validity
     begin
        IV_SO = 1'b0;
        case (Op_SI)
          `FP_OP_ADD, `FP_OP_SUB : //input logic already adjusts operands 
            begin
               if ((Inf_a_S & Inf_b_S) & (Sign_a_DI ^ Sign_b_DI))
                 IV_SO = 1'b1;
            end
          `FP_OP_MUL :
            begin
            if ((Inf_a_S & Zero_b_S) | (Inf_b_S & Zero_a_S))
              IV_SO = 1'b1;
            end
          `FP_OP_FTOI :
            IV_SO = IV_SI;       
        endcase
     end

   logic Inf_temp_S;
   
   
   always_comb //check infinite outputs
     begin
        Inf_temp_S = 1'b0;
        case(Op_SI)
          `FP_OP_ADD, `FP_OP_SUB : //input logic already adjusts operands
            if ((Inf_a_S ^ Inf_b_S) | ((Inf_a_S & Inf_b_S) & ~(Sign_a_DI ^ Sign_b_DI)))
              Inf_temp_S = 1'b1;
          `FP_OP_MUL :
            if ((Inf_a_S & ~Zero_b_S) | (Inf_b_S & ~Zero_a_S))
              Inf_temp_S = 1'b1;
        endcase // case (Op_SI)
     end // always_comb begin

   assign Inf_SO = (Op_SI == `FP_OP_FTOI) ? Inf_SI : Inf_temp_S | (Exp_OF_SI & ~Mant_zero_S);

 
   /////////////////////////////////////////////////////////////////////////////
   // flags/signals for result manipulation
   /////////////////////////////////////////////////////////////////////////////
   
   assign Exp_toZero_SO =(Op_SI == `FP_OP_ITOF) ? (Zero_a_S & ~Sign_a_DI) : Exp_UF_SI | (Mant_zero_S & ~Exp_toInf_SO);
   assign Exp_toInf_SO = (OF_SO | IV_SO);
   assign Mant_toZero_SO = Inf_SO;
   
   
endmodule // fpexc
