// Copyright 2017, 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Lei Li  lile@iis.ee.ethz.ch                                //
//		                                                                        //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    01/12/2016                                                 //
// Design Name:    fmac                                                       //
// Module Name:    aligner.sv                                                 //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    To align Mant_a_DI                                         //
//                                                                            //
//                                                                            //
// Revision:        06/07/2017                                                //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs_fmac::*;

module aligner
  (//Inputs
   input logic [C_EXP-1:0]                         Exp_a_DI,
   input logic [C_EXP-1:0]                         Exp_b_DI,
   input logic [C_EXP-1:0]                         Exp_c_DI,
   input logic [C_MANT:0]                          Mant_a_DI,
   input logic                                     Sign_a_DI,
   input logic                                     Sign_b_DI,
   input logic                                     Sign_c_DI,
   input logic [2*C_MANT+2:0]                      Pp_sum_DI,
   input logic [2*C_MANT+2:0]                      Pp_carry_DI,
   //Outputs
   output logic                                    Sub_SO,
   output logic [74:0]                             Mant_postalig_a_DO,
   output logic [C_EXP+1:0]                        Exp_postalig_DO,
   output logic                                    Sign_postalig_DO,
   output logic                                    Sign_amt_DO,
   output logic                                    Sft_stop_SO,
   output logic [2*C_MANT+2:0]                     Pp_sum_postcal_DO,
   output logic [2*C_MANT+2:0]                     Pp_carry_postcal_DO
   );

 logic [C_EXP+1:0]                                Exp_dif_D;
 logic [C_EXP+1:0]                                Sft_amt_D;


 assign Sub_SO = Sign_a_DI ^ Sign_b_DI ^ Sign_c_DI;
 assign Exp_dif_D = Exp_a_DI - Exp_b_DI - Exp_c_DI + C_BIAS;
 assign Sft_amt_D = Exp_b_DI + Exp_c_DI - Exp_a_DI - C_BIAS + 27; //Two bits are added including sign bit
 assign Sign_amt_DO = Sft_amt_D[C_EXP+1];
 logic                                            Sft_stop_S;       // right shift larger 74
 assign Sft_stop_S = (~Sft_amt_D[C_EXP+1])&&(Sft_amt_D[C_EXP:0]>=74);  //For rounding
 assign Sft_stop_SO = Sft_stop_S;
 // The exponent after alignment
 assign Exp_postalig_DO = Sft_amt_D[C_EXP+1] ? Exp_a_DI : {Exp_b_DI + Exp_c_DI - C_BIAS + 27};

 logic [73:0]                                     Mant_postalig_a_D;
 logic [C_MANT :0]                                Bit_sftout_D;
 assign  {Mant_postalig_a_D, Bit_sftout_D} = {Mant_a_DI,74'h0}>>{Sft_stop_S?0 : Sft_amt_D};     //Alignment
// another case for b*c>>a
 assign   Mant_postalig_a_DO =Sft_amt_D[C_EXP+1] ? {1'b0, Mant_a_DI, 50'h0}: { Sft_stop_S? 75'h0 :{ Sub_SO ? {1'b1,~Mant_postalig_a_D}:{1'b0,Mant_postalig_a_D} } };

 assign Sign_postalig_DO = Sft_amt_D[C_EXP+1] ? Sign_a_DI: Sign_b_DI ^ Sign_c_DI;
 assign Pp_sum_postcal_DO = Sft_amt_D[C_EXP+1] ? '0 : Pp_sum_DI;
 assign Pp_carry_postcal_DO =  Sft_amt_D[C_EXP+1] ? '0 : Pp_carry_DI;

endmodule
