////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Lukas Mueller -- lukasmue@student.ethz.ch                  //
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
// Description:    Floating point Normalizer/Rounding unit                    //
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

module fpnorm 
  (
   //Input Operands
   input logic        [47:0] Mant_in_DI,
   input logic signed [9:0]  Exp_in_DI,
   input logic               Sign_in_DI,

   //Rounding Mode
   input logic [1:0] RM_SI,
   input logic [3:0] OP_SI,
   
   output logic [23:0] Mant_res_DO,
   output logic [7:0]  Exp_res_DO,

   output logic Rounded_SO,
   output logic Exp_OF_SO,
   output logic Exp_UF_SO
   );

   /////////////////////////////////////////////////////////////////////////////
   // Normalization
   /////////////////////////////////////////////////////////////////////////////

   logic [5:0]        Mant_leadingOne_D;
   logic              Mant_zero_S;
   logic [27:0]       Mant_norm_D;
   logic signed [9:0] Exp_norm_D;

   //trying out stuff for denormals
   logic signed [9:0] Mant_shAmt_D;
   logic signed [10:0] Mant_shAmt2_D;
   
   logic [7:0]        Exp_final_D;
   logic signed [9:0] Exp_rounded_D;
   
   //sticky bit
   logic              Mant_sticky_D;
   
   logic              Denormal_S;
   logic              Mant_renorm_S;
   
   //Detect leading one  
   firstone 
     #(.G_VECTORLEN(48),
       .G_FLIPVECTOR(1))
   LOD
     (
      .Vector_DI(Mant_in_DI),
      .FirstOneIdx_DO(Mant_leadingOne_D),
      .NoOnes_SO(Mant_zero_S)
      );
   
   
   logic Denormals_shift_add_D;  
   logic Denormals_exp_add_D;    
   assign Denormals_shift_add_D = ~Mant_zero_S & (Exp_in_DI == 8'b0) & ((OP_SI != `FP_OP_MUL) | (~Mant_in_DI[47] & ~Mant_in_DI[46]));   
   assign Denormals_exp_add_D =  Mant_in_DI[46] & (Exp_in_DI == 8'b0) & ((OP_SI == `FP_OP_ADD) | (OP_SI == `FP_OP_SUB ));    
   
   assign Denormal_S = (10'(signed'(Mant_leadingOne_D)) >= Exp_in_DI) || Mant_zero_S; 
   assign Mant_shAmt_D = Denormal_S ? Exp_in_DI + Denormals_shift_add_D : Mant_leadingOne_D;
   assign Mant_shAmt2_D = {Mant_shAmt_D[$high(Mant_shAmt_D)], Mant_shAmt_D} + 28;
   
   //Shift mantissa
   always_comb
     begin
        logic [75:0] temp;
        temp = (76'(Mant_in_DI) << (Mant_shAmt2_D) );
        Mant_norm_D <= temp[75:48];
     end
           

   always_comb
     begin
        Mant_sticky_D <= 1'b0;
        if (Mant_shAmt2_D <= 0)
          Mant_sticky_D <= | Mant_in_DI;
        else if (Mant_shAmt2_D <= 48)
          Mant_sticky_D <= | (Mant_in_DI << (Mant_shAmt2_D));
     end
                        
   
   //adjust exponent
   assign Exp_norm_D = Exp_in_DI - 10'(signed'(Mant_leadingOne_D)) + 1 + Denormals_exp_add_D; 
   //Explanation of the +1 since I'll probably forget:
   //we get numbers in the format xx.x...
   //but to make things easier we interpret them as
   //x.xx... and adjust the exponent accordingly

   assign Exp_rounded_D = Exp_norm_D + Mant_renorm_S;
   assign Exp_final_D = Exp_rounded_D[7:0];
   

   always_comb //detect exponent over/underflow
     begin
        Exp_OF_SO <= 1'b0;
        Exp_UF_SO <= 1'b0;
        if (Exp_rounded_D >= signed'(10'hff)) //overflow
          begin
             Exp_OF_SO <= 1'b1;
          end
        else if (Exp_rounded_D <= signed'(10'b0)) //underflow      
          begin
             Exp_UF_SO <= 1'b1;
          end
     end
   
   
   /////////////////////////////////////////////////////////////////////////////
   // Rounding
   /////////////////////////////////////////////////////////////////////////////

   logic [23:0] Mant_upper_D;
   logic [3:0] Mant_lower_D;
   logic [24:0] Mant_upperRounded_D;
   
   logic Mant_roundUp_S;
   logic Mant_rounded_S;

   assign Mant_lower_D = Mant_norm_D[3:0];
   assign Mant_upper_D = Mant_norm_D[27:4];
   
   
   assign Mant_rounded_S = (|(Mant_lower_D)) | Mant_sticky_D;
   
   always_comb //determine whether to round up or not
     begin
        Mant_roundUp_S <= 1'b0;
        case (RM_SI)
          `RM_NEAREST : 
            Mant_roundUp_S <= Mant_lower_D[3] && (((| Mant_lower_D[2:0]) | Mant_sticky_D) || Mant_upper_D[0]);
          `RM_TRUNC   : 
            Mant_roundUp_S <= 0;
          `RM_PLUSINF : 
            Mant_roundUp_S <= Mant_rounded_S & ~Sign_in_DI;
          `RM_MINUSINF:
            Mant_roundUp_S <= Mant_rounded_S & Sign_in_DI;
          default     :
            Mant_roundUp_S <= 0;
        endcase // case (RM_DI)
     end // always_comb begin

   assign Mant_upperRounded_D = Mant_upper_D + Mant_roundUp_S;
   assign Mant_renorm_S = Mant_upperRounded_D[24];

   /////////////////////////////////////////////////////////////////////////////
   // Output Assignments
   /////////////////////////////////////////////////////////////////////////////

   assign Mant_res_DO = Mant_upperRounded_D >> (Mant_renorm_S & ~Denormal_S);
   assign Exp_res_DO = Exp_final_D;
   assign Rounded_SO = Mant_rounded_S;
   
         
endmodule // fpnorm
