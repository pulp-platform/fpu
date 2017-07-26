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

module booth_selector
  (

   //Input Operands
   input logic [1:0]               Booth_a_DI,



   input  logic                    Sel_1x_SI,
   input logic                     Sel_2x_SI,
   input logic                     Sel_sign_SI,
    
   output logic                    Booth_pp_DO


   );
   
assign      Booth_pp_DO  =~((~((Sel_1x_SI&&Booth_a_DI[1]) | (Sel_2x_SI&&Booth_a_DI[0])))^(Sel_sign_SI));
  
     
endmodule // 
