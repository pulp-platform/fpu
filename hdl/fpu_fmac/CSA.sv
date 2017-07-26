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
// Revision:        22/06/2017                                                          //
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

module CSA
#( parameter n=49)
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


endmodule // 


