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
// Module Name:    fpadd.sv                                                   //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Floating point addition/subtraction                        //
//                 Adjusts exponents, adds/subtracts mantissas                //
//                 for Normalizer/Rounding stage                              //
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

module fpu_add
  (//Input
   input logic Sign_a_DI,
   input logic Sign_b_DI,
   input logic [7:0] Exp_a_DI,
   input logic [7:0] Exp_b_DI,
   input logic [23:0] Mant_a_DI,
   input logic [23:0] Mant_b_DI,

   //Output
   output logic Sign_prenorm_DO,
   output logic signed [9:0] Exp_prenorm_DO,
   output logic [47:0] Mant_prenorm_DO
   );
   
   //Internal Operands
   logic [31:0] Operand_a_D;
   logic [31:0] Operand_b_D;       

   //Operand components
   logic        Sign_a_D;
   logic        Sign_b_D;
   logic [7:0]  Exp_a_D;
   logic [7:0]  Exp_b_D;
   logic [23:0] Mant_a_D;
   logic [23:0] Mant_b_D;

   //Post-Normalizer result
   logic        Sign_norm_D;
     
   /////////////////////////////////////////////////////////////////////////////
   // Assign Inputs
   /////////////////////////////////////////////////////////////////////////////
   assign Sign_a_D = Sign_a_DI;
   assign Sign_b_D = Sign_b_DI;
   assign Exp_a_D = Exp_a_DI;
   assign Exp_b_D = Exp_b_DI;
   assign Mant_a_D = Mant_a_DI;
   assign Mant_b_D = Mant_b_DI;

   /////////////////////////////////////////////////////////////////////////////
   // Exponent operations
   /////////////////////////////////////////////////////////////////////////////

   logic       Exp_agtb_S;
   logic       Exp_equal_S;
   logic [7:0] Exp_diff_D;
   logic [7:0] Exp_prenorm_D;
   
   assign Exp_agtb_S = Exp_a_D > Exp_b_D;
   assign Exp_equal_S = Exp_diff_D == 0;
   
   always_comb
     begin
        if (Exp_agtb_S)
          begin
             Exp_diff_D <= Exp_a_D - Exp_b_D;
             Exp_prenorm_D <= Exp_a_D;
          end
        else
          begin
             Exp_diff_D <= Exp_b_D - Exp_a_D;
             Exp_prenorm_D <= Exp_b_D;
          end
     end // always_comb
   
   /////////////////////////////////////////////////////////////////////////////
   // Mantissa operations
   /////////////////////////////////////////////////////////////////////////////

   logic        Mant_agtb_S;
   logic [25:0] Mant_shiftIn_D;
   logic [26:0] Mant_shifted_D;
   logic        Mant_sticky_D;
   logic [26:0] Mant_unshifted_D;

   //Main Adder
   logic [26:0] Mant_addInA_D;
   logic [26:0] Mant_addInB_D;
   logic [27:0] Mant_addOut_D;

   logic [47:0] Mant_prenorm_D;
   
   //Inversion and carry for Subtraction
   logic        Mant_addCarryIn_D;
   logic        Mant_invA_S;
   logic        Mant_invB_S;

   logic        Subtract_S;
   
   //Shift the number with the smaller exponent to the right
   assign Mant_agtb_S = Mant_a_D > Mant_b_D;
   assign Mant_unshifted_D = {(Exp_agtb_S ? Mant_a_D : Mant_b_D), 3'b0};
   assign Mant_shiftIn_D = {(Exp_agtb_S ? Mant_b_D : Mant_a_D), 2'b0};

   
   always_comb //sticky bit
     begin
        Mant_sticky_D <= 1'b0;
        if (Exp_diff_D >= 26)
          Mant_sticky_D <= | Mant_shiftIn_D;
        else
          Mant_sticky_D <= | (Mant_shiftIn_D << (26 - Exp_diff_D));
     end
   assign Mant_shifted_D = {(Mant_shiftIn_D >> Exp_diff_D), Mant_sticky_D};

   always_comb
     begin
        Mant_invA_S <= '0;
        Mant_invB_S <= '0;
        if (Subtract_S)
          begin
             if (Exp_agtb_S)
               Mant_invA_S <= 1'b1;
             else if (Exp_equal_S)
               begin
                 if (Mant_agtb_S)
                   Mant_invB_S <= 1'b1;
                 else
                   Mant_invA_S <= 1'b1;
               end
             else
               Mant_invA_S <= 1'b1;
          end // if (Subtract_S)
     end // always_comb begin
   
   assign Mant_addCarryIn_D = Subtract_S;
   assign Mant_addInA_D = (Mant_invA_S) ? ~Mant_shifted_D : Mant_shifted_D;
   assign Mant_addInB_D = (Mant_invB_S) ? ~Mant_unshifted_D : Mant_unshifted_D;

   assign Mant_addOut_D = Mant_addInA_D + Mant_addInB_D + Mant_addCarryIn_D;

   assign Mant_prenorm_D = {(Mant_addOut_D[27] & ~Subtract_S), Mant_addOut_D[26:0], 20'b0};
   
   
   /////////////////////////////////////////////////////////////////////////////
   // Sign operations
   /////////////////////////////////////////////////////////////////////////////

   assign Subtract_S = Sign_a_D ^ Sign_b_D;
   
   always_comb
     begin
        Sign_norm_D <= 1'b0;
        if (Exp_agtb_S)
          Sign_norm_D <= Sign_a_D;
        else if (Exp_equal_S)
          begin
             if (Mant_agtb_S)
               Sign_norm_D <= Sign_a_D;
             else
               Sign_norm_D <= Sign_b_D;
          end
        else //Exp_a < Exp_b
          Sign_norm_D <= Sign_b_D;
     end // always_comb

   
   /////////////////////////////////////////////////////////////////////////////
   // Output Assignments
   /////////////////////////////////////////////////////////////////////////////
   
   assign Sign_prenorm_DO = Sign_norm_D;
   assign Exp_prenorm_DO = signed'({2'b0,Exp_prenorm_D});
   assign Mant_prenorm_DO = Mant_prenorm_D;
    
   
endmodule // fpadd
