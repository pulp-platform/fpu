////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Thomas Gautschi -- gauthoma@student.ethz.ch                //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    29/10/2014                                                 // 
// Design Name:    FPU                                                        // 
// Module Name:    fpu_ftoi.sv                                                //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Floating point to unsigned integer converter               //
//                 sets flags if necessary                                    //
//                                                                            //
//                                                                            //
// Revision:                                                                  //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "defines_fpu.sv"

module fpu_ftoi
  (//Input
   input logic Sign_a_DI,
   input logic [7:0] Exp_a_DI,
   input logic [23:0] Mant_a_DI,
   
   //Output
   output logic [31:0] Result_DO,
  
   output logic OF_SO,               //Overflow
   output logic UF_SO,               //Underflow
   output logic Zero_SO,             //Result zero
   output logic IX_SO,               //Result inexact
   output logic IV_SO,               //Result invalid
   output logic Inf_SO               //Infinity
   );

   //Internal Operands
   logic        Sign_a_D;            
   logic [7:0] 	Exp_a_D;             
   logic [23:0] Mant_a_D;           
           
   //Output result
   logic [31:0] Result_D;                

   //Disassemble Operand
   assign Sign_a_D = Sign_a_DI;
   assign Exp_a_D = Exp_a_DI;
   assign Mant_a_D = Mant_a_DI;

   /////////////////////////////////////////////////////////////////////////////
   // Conversion
   /////////////////////////////////////////////////////////////////////////////
   logic signed [9:0] Shift_amount_D; //8
   logic [53:0]       Temp_shift_D;          // 23 bit fraction + 31 bit integer (w/o sign-bit) 
   logic [31:0]       Temp_twos_D;       
   logic              Shift_amount_neg_S;
   logic              Result_zero_S;
   logic              Input_zero_S;
      
   assign Shift_amount_D = signed'({1'b0,Exp_a_D}) - signed'(9'd127); 
   assign Shift_amount_neg_S = Shift_amount_D[9]; //8
   
   assign Temp_shift_D = Shift_amount_neg_S ? '0 : (Mant_a_D << Shift_amount_D);
   assign Temp_twos_D = ~{1'b0,Temp_shift_D[53:23]} + 1'b1;
   
   /////////////////////////////////////////////////////////////////////////////
   // Output assignments
   /////////////////////////////////////////////////////////////////////////////  

   //assign result
   assign Result_D = OF_SO ? (Sign_a_D ? 32'h80000000 : 32'h7fffffff) : (Sign_a_D ? Temp_twos_D : {Sign_a_D, Temp_shift_D[53:23]});
   assign Result_DO = Result_D;

   //assign flags
   assign Result_zero_S = (~|Result_D);
   assign Input_zero_S = (~|{Exp_a_D,Mant_a_D});

   assign UF_SO = 1'b0;
   assign OF_SO = Shift_amount_D > 30;
   assign Zero_SO = Result_zero_S & ~OF_SO;
   assign IX_SO = (|Temp_shift_D[22:0] | Shift_amount_neg_S | OF_SO) & ~Input_zero_S;
   assign IV_SO = (&Exp_a_D) && (|Mant_a_D);    
   assign Inf_SO = 1'b0;
 

endmodule //fpu_ftoi
   
