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
// Engineers:      Lei Li                  lile@iis.ee.ethz.ch                //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    01/12/2016                                                 //
// Design Name:    div_sqrt                                                   //
// Module Name:    iteration_div_first                                        //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    iteration unit for div and sqrt                            //
//                                                                            //
//                                                                            //
// Revision:          07/02/2017                                              //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs_div_sqrt_tp::*;
module iteration_div_sqrt
  (//Inputs
   input logic [C_DIV_MANT+1:0]     A_DI,
   input logic [C_DIV_MANT+1:0]     B_DI,
   input logic                      Div_enable_SI,
   input logic                      Sqrt_enable_SI,
   input logic [1:0]                D_DI,
  //Outputs
   output logic [1:0]               D_DO,
   output logic [C_DIV_MANT+1:0]    Sum_DO,
   output logic                     Carry_out_DO
    );

   logic                            D_carry_D;
   logic                            Sqrt_cin_D;
   logic                            Cin_D;

   assign D_DO[0]=~D_DI[0];
   assign D_DO[1]=~(D_DI[1] ^ D_DI[0]);
   assign D_carry_D=D_DI[1] | D_DI[0];
   assign Sqrt_cin_D=Sqrt_enable_SI&&D_carry_D;
   assign Cin_D=Div_enable_SI?0:Sqrt_cin_D;
   assign {Carry_out_DO,Sum_DO}=A_DI+B_DI+Cin_D;

endmodule

