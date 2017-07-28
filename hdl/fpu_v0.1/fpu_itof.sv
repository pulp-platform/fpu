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
// Create Date:    31/10/2014                                                 // 
// Design Name:    FPU                                                        // 
// Module Name:    fpu_itof.sv                                                //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Integer to floating point converter                        //
//                                                                            //
//                                                                            //
//                                                                            //
// Revision:                                                                  //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs::*;

module fpu_itof
  (//Input
   input logic [C_OP-1:0]                   Operand_a_DI,

   //Output
   output logic                             Sign_prenorm_DO,
   output logic signed [C_EXP_PRENORM-1 :0] Exp_prenorm_DO,
   output logic        [C_MANT_PRENORM-1:0] Mant_prenorm_DO
   );

   //Internal Operands
   logic [C_OP-1:0]                         Operand_a_D;
   logic                                    Sign_int_D;
   logic                                    Sign_prenorm_D;
   logic [C_MANT_INT-1:0]                   Mant_int_D;                 //Integer number w/o sign-bit
   logic [C_OP-1:0]                         Temp_twos_to_unsigned_D;
   logic [C_MANT_PRENORM-1:0]               Mant_prenorm_D;
   
   
   //Hidden Bits
   logic                                    Hb_a_D;

   //Exponent calculations
   logic signed [C_EXP_PRENORM-1:0]         Exp_prenorm_D;       //signed exponent for normalizer

   /////////////////////////////////////////////////////////////////////////////
   // Assign Inputs/Disassemble Operands                                      //
   /////////////////////////////////////////////////////////////////////////////

   assign Operand_a_D = Operand_a_DI;

   //Disassemble Operands
   assign Sign_int_D  = Operand_a_D[C_OP-1];
   assign Mant_int_D  = Operand_a_D[C_MANT_INT-1:0];
   logic  Twos_to_unsigned_zero;
   assign Temp_twos_to_unsigned_D = ~Operand_a_D + 1'b1;
   assign Twos_to_unsigned_zero_D = ~(|Temp_twos_to_unsigned_D[C_MANT_INT-1:0]);

   /////////////////////////////////////////////////////////////////////////////
   // Output calculations                                                     //
   /////////////////////////////////////////////////////////////////////////////

   assign Sign_prenorm_D = Sign_int_D;
   assign Exp_prenorm_D  = signed'({2'd0,C_UNKNOWN});
   assign Mant_prenorm_D = Sign_int_D ? {Twos_to_unsigned_zero_D,Temp_twos_to_unsigned_D[C_MANT_INT-1:0], C_PADMANT} : {1'b0,Mant_int_D, C_PADMANT};

   /////////////////////////////////////////////////////////////////////////////
   // Output assignments                                                      //
   /////////////////////////////////////////////////////////////////////////////

   assign Sign_prenorm_DO = Sign_prenorm_D;
   assign Exp_prenorm_DO  = Exp_prenorm_D;
   assign Mant_prenorm_DO = Mant_prenorm_D;

endmodule //fpu_itof
