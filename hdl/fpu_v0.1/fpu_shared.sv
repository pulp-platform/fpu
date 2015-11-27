////////////////////////////////////////////////////////////////////////////////
// Company:        IIS @ ETHZ - Federal Institute of Technology               //
//                                                                            //
// Engineers:      Lukas Mueller -- lukasmue@student.ethz.ch                  //
//                 Thomas Gautschi -- gauthoma@sutdent.ethz.ch                //
//		                                                                        //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    26/10/2014                                                 // 
// Design Name:    FPU                                                        // 
// Module Name:    fpu.sv                                                     //
// Project Name:   FPU                                                        //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Wrapper for connecting the FPU to the shared interconnect  //
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

import fpu_defs::*;

module fpu_shared
  #(
    parameter ADD_REGISTER = 1
    )
  (
   input logic     Clk_CI,
   input logic     Rst_RBI,
   marx_apu_if.apu Interface
   );
   

   logic [C_OP-1:0]  Operand_a_D;
   logic [C_OP-1:0]  Operand_b_D;
   logic [C_CMD-1:0] Op_S;
   logic [C_RM-1:0]  RM_S;
   
   logic             Valid_S;
   logic [C_TAG-1:0] Tag_D;

   logic             Stall_S;
   
   assign Stall_S = Interface.req_us_s & ~Interface.ack_us_s;
   
   
   /////////////////////////////////////////////////////////////////////////////
   // Optional Input Register
   /////////////////////////////////////////////////////////////////////////////

   generate
      if (ADD_REGISTER == 1)
        begin
           logic [C_OP-1:0]  Operand_a_DN;
           logic [C_OP-1:0]  Operand_b_DN;
           logic [C_RM-1:0]  RM_SN;
           logic [C_CMD-1:0] Op_SN;

           logic             Valid_SN;
           logic [C_TAG-1:0] Tag_DN;

           assign  Operand_a_DN = Stall_S ? Operand_a_D : Interface.arga_ds_d;
           assign  Operand_b_DN = Stall_S ? Operand_b_D : Interface.argb_ds_d;
           assign  RM_SN        = Stall_S ? RM_S        : Interface.flags_ds_d;
           assign  Op_SN        = Stall_S ? Op_S        : Interface.op_ds_d;
                    
           assign  Valid_SN     = Stall_S ? Valid_S     : Interface.valid_ds_s;
           assign  Tag_DN       = Stall_S ? Tag_D       : Interface.tag_ds_d;

           always_ff @(posedge Clk_CI, negedge Rst_RBI) begin
              if (~Rst_RBI) begin
                 Operand_a_D <= '0;
                 Operand_b_D <= '0;
                 Op_S        <= '0;
                 RM_S        <= '0;

                 Valid_S     <= '0;
                 Tag_D       <= '0;
              end
              else begin
                 Operand_a_D <= Operand_a_DN;
                 Operand_b_D <= Operand_b_DN;
                 RM_S        <= RM_SN;
                 Op_S        <= Op_SN;
                    
                 Valid_S     <= Valid_SN;
                 Tag_D       <= Tag_DN;
              end
           end
        end
      else
        begin
           assign Operand_a_D  = Interface.arga_ds_d;
           assign Operand_b_D  = Interface.argb_ds_d;
           assign RM_S         = Interface.flags_ds_d;
           assign Op_S         = Interface.op_ds_d;
   
           assign Valid_S      = Interface.valid_ds_s;
           assign Tag_D        = Interface.tag_ds_d;
        end
   endgenerate

   /////////////////////////////////////////////////////////////////////////////
   // FPU core instance
   /////////////////////////////////////////////////////////////////////////////

   logic [C_OP-1:0]   Result_D;
   
   logic [C_FLAG-1:0] Flags_S;
   logic              UF_S;
   logic              OF_S;
   logic              Zero_S;
   logic              IX_S;
   logic              IV_S;
   logic              Inf_S;
   
   fpu_core core
     (
      .Clk_CI       ( Clk_CI        ),
      .Rst_RBI      ( Rst_RBI       ),
      .Enable_SI    ( Valid_S       ),
      
      .Operand_a_DI ( Operand_a_D   ),
      .Operand_b_DI ( Operand_b_D   ),
      .RM_SI        ( RM_S          ),
      .OP_SI        ( Op_S          ),
      
      .Stall_SI     ( Stall_S       ),

      .Result_DO    ( Result_D      ),

      .OF_SO        ( OF_S          ),
      .UF_SO        ( UF_S          ),
      .Zero_SO      ( Zero_S        ),
      .IX_SO        ( IX_S          ),
      .IV_SO        ( IV_S          ),
      .Inf_SO       ( Inf_S         )
      );
   

   /////////////////////////////////////////////////////////////////////////////
   // Shim register for tag and valid
   /////////////////////////////////////////////////////////////////////////////   

   logic              ValidDelayed_SP;
   logic              ValidDelayed_SN;
   logic [C_TAG-1:0]  TagDelayed_DP;
   logic [C_TAG-1:0]  TagDelayed_DN;

   assign ValidDelayed_SN = Stall_S ? ValidDelayed_SP : Valid_S;
   assign TagDelayed_DN   = Stall_S ? TagDelayed_DP   : Tag_D;
   
  
   always_ff @(posedge Clk_CI, negedge Rst_RBI)
     begin
        if (~Rst_RBI)
          begin
             ValidDelayed_SP <= '0;
             TagDelayed_DP   <= '0;
          end
        else
          begin
             ValidDelayed_SP <= ValidDelayed_SN;
             TagDelayed_DP   <= TagDelayed_DN;
          end
     end // always_ff @ (posedge Clk_CI, negedge Rst_RBI)

   /////////////////////////////////////////////////////////////////////////////
   // Output assignments
   /////////////////////////////////////////////////////////////////////////////   
   
   assign Interface.result_us_d = Result_D;
   assign Interface.flags_us_d  = {1'b0, Inf_S, IV_S, IX_S, Zero_S, 2'b0, UF_S, OF_S};
   assign Interface.tag_us_d    = TagDelayed_DP;
   assign Interface.req_us_s    = ValidDelayed_SP;
   assign Interface.ready_ds_s  = ~Stall_S;
       
endmodule