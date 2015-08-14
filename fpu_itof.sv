////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Thomas Gautschi -- gauthoma@student.ethz.ch                //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    31/10/2014                                                 // 
// Design Name:    FPU                                                        // 
// Module Name:    fpu_itof.sv                                                //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Integer to floating point converter                        //
//                                                                            //
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

module fpu_itof
  (//Input
   input logic [31:0] Operand_a_DI,

   //Output
   output logic Sign_prenorm_DO,
   output logic signed [9:0] Exp_prenorm_DO,
   output logic [47:0] Mant_prenorm_DO
   );

   //Internal Operands
   logic [31:0] Operand_a_D;
   logic        Sign_int_D;           
   logic        Sign_prenorm_D;                         
   logic [30:0] Mant_int_D;                 //Integer number w/o sign-bit
   logic [31:0] Temp_twos_to_unsigned_D;
   logic [47:0] Mant_prenorm_D;
   
   
   //Hidden Bits
   logic        Hb_a_D;

   //Exponent calculations
   logic signed [9:0]  Exp_prenorm_D;       //signed exponent for normalizer
                   

   /////////////////////////////////////////////////////////////////////////////
   // Assign Inputs/Disassemble Operands
   /////////////////////////////////////////////////////////////////////////////

   assign Operand_a_D = Operand_a_DI;

   //Disassemble Operands
   assign Sign_int_D = Operand_a_D[31];
   assign Mant_int_D = Operand_a_D[30:0];
   logic               Twos_to_unsigned_zero;
   assign Temp_twos_to_unsigned_D = ~Operand_a_D + 1'b1;
   assign Twos_to_unsigned_zero_D = ~(|Temp_twos_to_unsigned_D[30:0]);

   /////////////////////////////////////////////////////////////////////////////
   // Output calculations
   /////////////////////////////////////////////////////////////////////////////
  
   assign Sign_prenorm_D = Sign_int_D;           

   assign Exp_prenorm_D = signed'({2'd0,8'd157});
   
   assign Mant_prenorm_D = Sign_int_D ? {Twos_to_unsigned_zero_D,Temp_twos_to_unsigned_D[30:0], 16'b0} : {1'b0,Mant_int_D, 16'b0};
   
   /////////////////////////////////////////////////////////////////////////////
   // Output assignments
   /////////////////////////////////////////////////////////////////////////////
   
   assign Sign_prenorm_DO = Sign_prenorm_D;
   assign Exp_prenorm_DO = Exp_prenorm_D;
   assign Mant_prenorm_DO = Mant_prenorm_D;
      
endmodule //fpu_itof
   
