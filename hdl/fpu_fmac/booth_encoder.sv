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
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    01/12/2016                                                 //
// Design Name:    fmac                                                       //
// Module Name:    booth_enocder.sv                                           //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Booth encoding                                             //
//                                                                            //
//                                                                            //
//                                                                            //
// Revision:        20/06/2017                                                //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs_fmac::*;

module booth_encoder
  (//Inputs
   input logic [2:0]               Booth_b_DI,
   //Outputs
   output logic                    Sel_1x_SO,
   output logic                    Sel_2x_SO,
   output logic                    Sel_sign_SO
   );
   
  logic                            Sel_xnor_S;

assign      Sel_1x_SO  =(^Booth_b_DI[1:0]);
assign      Sel_xnor_S =~(^Booth_b_DI[2:1]);
assign      Sel_2x_SO  =~(Sel_1x_SO | Sel_xnor_S);
assign      Sel_sign_SO= Booth_b_DI[2];

endmodule
