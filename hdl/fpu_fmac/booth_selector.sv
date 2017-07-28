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
// Engineers:      Lei Li  lile@iis.ee.ethz.ch                                //
//		                                                                      //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    01/12/2016                                                 //
// Design Name:    fmac                                                       //
// Module Name:    booth_selector.sv                                          //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Booth Seletor                                              //
//                                                                            //
//                                                                            //
//                                                                            //
// Revision:        20/06/2017                                                //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs_fmac::*;

module booth_selector
  (//Inputs
   input logic [1:0]               Booth_a_DI,
   input  logic                    Sel_1x_SI,
   input logic                     Sel_2x_SI,
   input logic                     Sel_sign_SI,
   //Outputs
   output logic                    Booth_pp_DO
   );

assign      Booth_pp_DO  =~((~((Sel_1x_SI&&Booth_a_DI[1]) | (Sel_2x_SI&&Booth_a_DI[0])))^(Sel_sign_SI));

endmodule
