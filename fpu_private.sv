////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Lukas Mueller -- lukasmue@student.ethz.ch                  //
//                 Thomas Gautschi -- gauthoma@student.ethz.ch                //
//		                                                                        //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    26/10/2014                                                 // 
// Design Name:    FPU                                                        // 
// Module Name:    fpu.sv                                                     //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Floating point unit with enable                            //
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

`include "defines_fpu.sv"

module fpu_private
  (
   //Clock and reset
   input logic 	       Clk_CI,
   input logic 	       Rst_RBI,
   input logic         Enable_SI,
   input logic         Stall_SI,

   //Input Operands
   input logic [31:0]  Operand_a_DI,
   input logic [31:0]  Operand_b_DI,
   input logic [1:0]   RM_SI,    //Rounding Mode
   input logic [3:0]   OP_SI,
  

   output logic [31:0] Result_DO,
   //Output-Flags
   output logic [8:0]  Flags_SO
   );

   logic [31:0]        Operand_a_D;
   logic [31:0]        Operand_b_D;
   logic [1:0]         RM_S;
   logic [3:0]         OP_S;


/* -----\/----- EXCLUDED -----\/-----
   //  Enable
   always_comb
     begin 
        Operand_a_D <= '0;
        Operand_b_D <= '0;
        RM_S        <= '0;
        OP_S        <= '0;
        if (Enable_SI)
          begin
             Operand_a_D <= Operand_a_DI;
             Operand_b_D <= Operand_b_DI;
             RM_S        <= RM_SI;
             OP_S       <= OP_SI;   
          end
     end
 -----/\----- EXCLUDED -----/\----- */

   assign Operand_a_D = Operand_a_DI;
   assign Operand_b_D = Operand_b_DI;
   assign RM_S = RM_SI;
   assign OP_S = OP_SI;
      

   logic OF_S;
   logic UF_S;
   logic Zero_S;
   logic IX_S;
   logic IV_S;
   logic Inf_S;
      
   fpu_core core
     (
      .Clk_CI        (Clk_CI),
      .Rst_RBI       (Rst_RBI),
      .Enable_SI     (Enable_SI),
     
      .Operand_a_DI  (Operand_a_D),
      .Operand_b_DI  (Operand_b_D),
      .RM_SI         (RM_S),
      .OP_SI         (OP_S),

      .Stall_SI      (Stall_SI),

      .Result_DO     (Result_DO),
      
      .OF_SO         (OF_S),
      .UF_SO         (UF_S),
      .Zero_SO       (Zero_S),
      .IX_SO         (IX_S),
      .IV_SO         (IV_S),
      .Inf_SO        (Inf_S)
      );

   assign Flags_SO = {1'b0, Inf_S, IV_S, IX_S, Zero_S, 2'b0, UF_S, OF_S};
   

endmodule