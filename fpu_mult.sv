////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Thomas Gautschi -- gauthoma@student.ethz.ch                //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    06/10/2014                                                 // 
// Design Name:    FPU                                                        // 
// Module Name:    fpmult.sv                                                  //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Floating point multiplier                                  //
//                 Calculates exponent and mantissa for                       //
//                 Normalizer/Rounding stage                                  //
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

module fpu_mult
  (//Input
   input logic Sign_a_DI,
   input logic Sign_b_DI,
   input logic [7:0] Exp_a_DI,
   input logic [7:0] Exp_b_DI,
   input logic [23:0] Mant_a_DI,
   input logic [23:0] Mant_b_DI,

   //Output
   output logic Sign_prenorm_DO,
   output logic signed [9:0] Exp_prenorm_DO,
   output logic [47:0] Mant_prenorm_DO
   );

   //Operand components
   logic        Sign_a_D;            
   logic        Sign_b_D;
   logic        Sign_prenorm_D;              
   logic [7:0]  Exp_a_D;             
   logic [7:0]  Exp_b_D;
   logic [23:0] Mant_a_D;           
   logic [23:0] Mant_b_D;

   //Exponent calculations
   logic signed [9:0]  Exp_prenorm_D;       //signed exponent for normalizer
      
   //Multiplication
   logic [47:0] Mant_prenorm_D;               

   /////////////////////////////////////////////////////////////////////////////
   // Assign Inputs
   /////////////////////////////////////////////////////////////////////////////
   assign Sign_a_D = Sign_a_DI;
   assign Sign_b_D = Sign_b_DI;
   assign Exp_a_D = Exp_a_DI;
   assign Exp_b_D = Exp_b_DI;
   assign Mant_a_D = Mant_a_DI;
   assign Mant_b_D = Mant_b_DI;
  
   /////////////////////////////////////////////////////////////////////////////
   // Output calculations
   /////////////////////////////////////////////////////////////////////////////
  
   assign Sign_prenorm_D = Sign_a_D ^ Sign_b_D;           

   assign Exp_prenorm_D = signed'({2'b0,Exp_a_D}) + signed'({2'b0,Exp_b_D}) - signed'(10'd127);              
   
   assign Mant_prenorm_D = Mant_a_D * Mant_b_D;
   
   /////////////////////////////////////////////////////////////////////////////
   // Output assignments
   /////////////////////////////////////////////////////////////////////////////
   
   assign Sign_prenorm_DO = Sign_prenorm_D;
   assign Exp_prenorm_DO = Exp_prenorm_D;
   assign Mant_prenorm_DO = Mant_prenorm_D;
      
endmodule //fpu_mult
   
