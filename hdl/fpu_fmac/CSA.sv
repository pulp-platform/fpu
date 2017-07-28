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
// Engineers:      Lei Li  //lile@iis.ee.ethz.ch                              //
//		                                                                        //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    01/12/2016                                                 //
// Design Name:    fmac                                                       //
// Module Name:    CSA.sv                                                     //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Carry Save Adder                                           //
//                                                                            //
// Revision:       22/06/2017                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs_fmac::*;

module CSA
#( parameter n=49 )
 (
   input logic [n-1:0]           A_DI,
   input logic [n-1:0]           B_DI,
   input logic [n-1:0]           C_DI,
   output logic [n-1:0]          Sum_DO,
   output logic [n-1:0]          Carry_DO
 );

    generate
      genvar i;
        for (i=0; i<=n-1;i++) 
          begin
            always@(*)
              begin
                Sum_DO[i]= A_DI[i] ^ B_DI[i] ^ C_DI[i];
                Carry_DO[i]=(A_DI[i]&B_DI[i]) | (A_DI[i]&C_DI[i]) | (B_DI[i]&C_DI[i]);
              end
          end
     endgenerate

endmodule


