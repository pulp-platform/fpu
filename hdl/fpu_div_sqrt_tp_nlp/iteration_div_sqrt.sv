////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Lei Li                  //lile@iis.ee.ethz.ch
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    01/12/2016                                                 // 
// Design Name:    div_sqrt                                                        // 
// Module Name:    iteration_div_first                                                   //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    iteration unit for div and sqrt                                       //
//                                                   t                        //
//                                                                            //
// Revision:          07/02/2017                                                        //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////



import fpu_defs_div_sqrt_tp::*;
module iteration_div_sqrt
  (//Input

   input logic [C_MANT+1:0]     A_DI,
   input logic [C_MANT+1:0]     B_DI,
   input logic                  Div_enable_SI,
   input logic                  Sqrt_enable_SI,
   input logic [1:0]            D_DI,
   
   output logic [1:0]           D_DO, 
   output logic [C_MANT+1:0]    Sum_DO,
   output logic                 Carry_out_DO
    );

   logic                        D_carry_D;
   logic                        Sqrt_cin_D;
   logic                        Cin_D;
   
   assign D_DO[0]=~D_DI[0];
   assign D_DO[1]=~(D_DI[1] ^ D_DI[0]);
   assign D_carry_D=D_DI[1] | D_DI[0];
   assign Sqrt_cin_D=Sqrt_enable_SI&&D_carry_D; 
   assign Cin_D=Div_enable_SI?0:Sqrt_cin_D;             
   assign {Carry_out_DO,Sum_DO}=A_DI+B_DI+Cin_D;

endmodule

