////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:                Lei Li  //lile@iis.ee.ethz.ch
//		                                                                        //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:      01/12/2016                                            // 
// Design Name:    fmac                                                        // 
// Module Name:    preprocess.sv                                                     //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:          // decomposition and operand detection
//                                                                            //
//                                                                            //
//                                                                            //
// Revision:        20/06/2017                                                          //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs_fmac::*;

module booth_encoder
  (

   //Input Operands
   input logic [2:0]               Booth_b_DI,



   output logic                    Sel_1x_SO,
   output logic                    Sel_2x_SO,
   output logic                    Sel_sign_SO


   );
   
  logic                     Sel_xnor_S;

assign      Sel_1x_SO  =(^Booth_b_DI[1:0]);
assign      Sel_xnor_S =~(^Booth_b_DI[2:1]);
assign      Sel_2x_SO  =~(Sel_1x_SO | Sel_xnor_S);
assign      Sel_sign_SO= Booth_b_DI[2];

  
     
endmodule // 
