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
// Module Name:    adders.sv                                                     //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:          // decomposition and operand detection
//                                                                            //
//          FMAC=a+b*c                                                               //
//                                                                            //
// Revision:        26/06/2017                                                          //
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

module adders
  (

   input  logic [2*C_MANT+1:0]            AL_DI,  // The sum of the former unit  
   input  logic [2*C_MANT+1:0]            BL_DI,  // The carry-out of the former unit??
   input  logic                           Sub_SI,
   input  logic [2:0]                     Sign_cor_SI,  //???
   input  logic                           Sign_amt_DI,
   input  logic                           Sft_stop_SI, 
   input  logic [C_MANT+3:0]              BH_DI,
   input  logic                           Sign_postalig_DI,
   output logic [3*C_MANT+4:0]            Sum_pos_DO,
   output logic                           Sign_out_DO,
   output logic [3*C_MANT+4:0]            A_LZA_DO,
   output logic [3*C_MANT+4:0]            B_LZA_DO             

   );

////////////////////////////////////////////////////////////////////////////////////  
//                  LSBs                                                          //
////////////////////////////////////////////////////////////////////////////////

   logic                                  Carry_postcor_D;
   assign Carry_postcor_D = (Sign_amt_DI )? 1'b0 : {(~(| Sign_cor_SI) ^ BL_DI[2*C_MANT+1]) } ;   //????                                
//    assign Carry_postcor_D = Sign_amt_DI? 1'b0 : {(| Sign_cor_SI) ? BL_DI[2*C_MANT+1]: 1'b0 } ;   //????           
   logic  Carry_uninv_LS;
   logic [2*C_MANT+1:0] Sum_uninv_LD;
   assign {Carry_uninv_LS, Sum_uninv_LD} = {1'b0,AL_DI}+{Carry_postcor_D,BL_DI[2*C_MANT:0],Sub_SI};
   
   logic  Carry_inv_LS;
   logic [2*C_MANT+2:0] Sum_inv_LD;
   assign {Carry_inv_LS, Sum_inv_LD} = {1'b1,~AL_DI,1'b1}+{~Carry_postcor_D,~BL_DI[2*C_MANT:0],2'b11} + 2;  //adding 2                  Sub_SI=0, donot choose this one   


////////////////////////////////////////////////////////////////////////////////////  
//                  MSBs                                                          //
////////////////////////////////////////////////////////////////////////////////
// incrementer
   logic [C_MANT+3:0]               BH_inv_D;
   logic [C_MANT+3:0]               Sum_uninv_HD,  Sum_inv_HD;  
   assign  BH_inv_D = ~  BH_DI;  
//   assign  {Sign_uninv_S, Sum_uninv_HD}= Carry_uninv_S ? {BH_DI+1} : BH_DI;         //
//   assign  {Sign_inv_S,Sum_inv_HD}=Carry_inv_S? BH_inv_D : {BH_inv_D-1};            // 
   assign  {Carryout_uninv_HS, Sum_uninv_HD}= Carry_uninv_LS ? {BH_DI+1} : BH_DI;         //
   assign  {Carryout_inv_HS,Sum_inv_HD}=Carry_inv_LS? BH_inv_D : {BH_inv_D-1};            // 
   assign Sum_pos_DO =Sft_stop_SI ? {{26'h0} , Sum_uninv_LD[2*C_MANT+1:0]} : {Sign_amt_DI?  {BH_DI[C_MANT+2:0], {48'b0}} : {Sum_uninv_HD[C_MANT+3] ?  {Sum_inv_HD[C_MANT+2:0] , Sum_inv_LD[2*C_MANT+2:1]} : {Sum_uninv_HD[C_MANT+2:0] , Sum_uninv_LD} } };  
   assign Sign_out_DO = Sign_amt_DI? Sign_postalig_DI : (Sum_uninv_HD[C_MANT+3] ^ Sign_postalig_DI);
////////////////////////////////////////////////////////////////////////////////////  
//                  to LZA                                                         //
////////////////////////////////////////////////////////////////////////////////
   assign A_LZA_DO = Sign_amt_DI? {BH_DI[C_MANT+2:0], {48'b0}} : {BH_DI[C_MANT+2:0] , {48'b0}};
   assign B_LZA_DO = Sign_amt_DI? {74'h0} : {{25'h0},Carry_uninv_LS, Sum_uninv_LD};   

  
endmodule // 
