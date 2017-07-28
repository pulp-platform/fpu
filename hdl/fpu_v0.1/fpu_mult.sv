/* Copyright (C) 2017 ETH Zurich, University of Bologna
 * All rights reserved.
 *
 * This code is under development and not yet released to the public.
 * Until it is released, the code is under the copyright of ETH Zurich and
 * the University of Bologna, and may contain confidential and/or unpublished
 * work. Any reuse/redistribution is strictly forbidden without written
 * permission from ETH Zurich.
 *
 * Bug fixes and contributions will eventually be released under the
 * SolderPad open hardware license in the context of the PULP platform
 * (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
 * University of Bologna.
 */
////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Thomas Gautschi -- gauthoma@student.ethz.ch                //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    06/10/2014                                                 // 
// Design Name:    FPU                                                        // 
// Module Name:    fpu_mult.sv                                                  //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Floating point multiplier                                  //
//                 Calculates exponent and mantissa for                       //
//                 Normalizer/Rounding stage                                  //
//                                                                            //
// Revision:                                                                  //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs::*;

module fpu_mult
  (//Input
   input logic                              Sign_a_DI,
   input logic                              Sign_b_DI,
   input logic [C_EXP-1:0]                  Exp_a_DI,
   input logic [C_EXP-1:0]                  Exp_b_DI,
   input logic [C_MANT:0]                   Mant_a_DI ,
   input logic [C_MANT:0]                   Mant_b_DI,

   //Output
   output logic                             Sign_prenorm_DO,
   output logic signed [C_EXP_PRENORM-1 :0] Exp_prenorm_DO,
   output logic        [C_MANT_PRENORM-1:0] Mant_prenorm_DO
   );

   //Operand components
   logic                                    Sign_a_D;
   logic                                    Sign_b_D;
   logic                                    Sign_prenorm_D;
   logic [C_EXP-1:0]                        Exp_a_D;
   logic [C_EXP-1:0]                        Exp_b_D;
   logic [C_MANT:0]                         Mant_a_D;
   logic [C_MANT:0]                         Mant_b_D;

   //Exponent calculations
   logic signed [C_EXP_PRENORM-1:0]         Exp_prenorm_D;       //signed exponent for normalizer
      
   //Multiplication
   logic [C_MANT_PRENORM-1:0]               Mant_prenorm_D;

   /////////////////////////////////////////////////////////////////////////////
   // Assign Inputs                                                           //
   /////////////////////////////////////////////////////////////////////////////
   assign Sign_a_D = Sign_a_DI;
   assign Sign_b_D = Sign_b_DI;
   assign Exp_a_D  = Exp_a_DI;
   assign Exp_b_D  = Exp_b_DI;
   assign Mant_a_D = Mant_a_DI;
   assign Mant_b_D = Mant_b_DI;

   /////////////////////////////////////////////////////////////////////////////
   // Output calculations                                                     //
   /////////////////////////////////////////////////////////////////////////////
   assign Sign_prenorm_D = Sign_a_D ^ Sign_b_D;
   assign Exp_prenorm_D  = signed'({2'b0,Exp_a_D}) + signed'({2'b0,Exp_b_D}) - signed'(C_BIAS);
   assign Mant_prenorm_D = Mant_a_D * Mant_b_D;

   /////////////////////////////////////////////////////////////////////////////
   // Output assignments
   /////////////////////////////////////////////////////////////////////////////
   assign Sign_prenorm_DO = Sign_prenorm_D;
   assign Exp_prenorm_DO  = Exp_prenorm_D;
   assign Mant_prenorm_DO = Mant_prenorm_D;

endmodule //fpu_mult

