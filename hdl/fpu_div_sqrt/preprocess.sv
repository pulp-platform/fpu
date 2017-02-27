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
// Design Name:    div_sqrt                                                        // 
// Module Name:    preprocess.sv                                                     //
// Project Name:   Private FPU                                                //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:          // decode and data preparation
//                                                                            //
//                                                                            //
//                                                                            //
// Revision:        19/01/2017                                                          //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import fpu_defs_div_sqrt::*;

module preprocess
  (
   input logic                   Clk_CI,
   input logic                   Rst_RBI,
   input logic                   Div_start_SI,
   input logic                   Sqrt_start_SI,
   //Input Operands
   input logic [C_OP-1:0]        Operand_a_DI,
   input logic [C_OP-1:0]        Operand_b_DI,
   input logic [C_RM-1:0]        RM_SI,    //Rounding Mode

   // to control
   output logic                  Start_SO,
   output logic [C_EXP:0]        Exp_a_DO_norm,
   output logic [C_EXP:0]        Exp_b_DO_norm,
   output logic [C_MANT:0]       Mant_a_DO_norm,
   output logic [C_MANT:0]       Mant_b_DO_norm,

   output logic [C_RM-1:0]       RM_dly_SO, 
   output logic [C_OP-1:0]       Operand_a_dly_DO,
   output logic [C_OP-1:0]       Operand_b_dly_DO,
   output logic                  Sign_z_DO,
   output logic                  Inf_a_SO,
   output logic                  Inf_b_SO,
   output logic                  Zero_a_SO,
   output logic                  Zero_b_SO,
   output logic                  NaN_a_SO,
   output logic                  NaN_b_SO,
   output logic                  Special_case_dly_SBO 

   );
   


   //Operand components
 

   //Hidden Bits
   logic                       Hb_a_D;
   logic                       Hb_b_D;

   logic [C_EXP-1:0]           Exp_a_D;
   logic [C_EXP-1:0]           Exp_b_D;
   logic [C_MANT:0]            Mant_a_D;
   logic [C_MANT:0]            Mant_b_D;

   /////////////////////////////////////////////////////////////////////////////
   // Disassemble operands
   /////////////////////////////////////////////////////////////////////////////
   logic                      Sign_a_D,Sign_b_D;
   logic                      Start_S;

   assign Sign_a_D = Operand_a_DI[C_OP-1];
   assign Sign_b_D = Operand_b_DI[C_OP-1];
   assign Exp_a_D  = Operand_a_DI[C_OP-2:C_MANT];
   assign Exp_b_D  = Operand_b_DI[C_OP-2:C_MANT];
   assign Mant_a_D = {Hb_a_D,Operand_a_DI[C_MANT-1:0]};
   assign Mant_b_D = {Hb_b_D,Operand_b_DI[C_MANT-1:0]};
   
   assign Hb_a_D = | Exp_a_D; // hidden bit
   assign Hb_b_D = | Exp_b_D; // hidden bit
   
   assign Start_S= Div_start_SI | Sqrt_start_SI;




   /////////////////////////////////////////////////////////////////////////////
   // preliminary checks for infinite/zero/NaN operands
   /////////////////////////////////////////////////////////////////////////////
   
   logic               Mant_a_prenorm_zero_S;
   logic               Mant_b_prenorm_zero_S;
   assign Mant_a_prenorm_zero_S=(Operand_a_DI[C_MANT-1:0] == C_MANT_ZERO);
   assign Mant_b_prenorm_zero_S=(Operand_b_DI[C_MANT-1:0] == C_MANT_ZERO);

   logic               Exp_a_prenorm_zero_S;
   logic               Exp_b_prenorm_zero_S;
   assign Exp_a_prenorm_zero_S=(Exp_a_D == C_EXP_ZERO);
   assign Exp_b_prenorm_zero_S=(Exp_b_D == C_EXP_ZERO);

   logic               Exp_a_prenorm_Inf_NaN_S;
   logic               Exp_b_prenorm_Inf_NaN_S;
   assign Exp_a_prenorm_Inf_NaN_S=(Exp_a_D == C_EXP_INF);
   assign Exp_b_prenorm_Inf_NaN_S=(Exp_b_D == C_EXP_INF);

   logic               Zero_a_SN,Zero_a_SP;
   logic               Zero_b_SN,Zero_b_SP;
   logic               Inf_a_SN,Inf_a_SP;
   logic               Inf_b_SN,Inf_b_SP;
   logic               NaN_a_SN,NaN_a_SP;
   logic               NaN_b_SN,NaN_b_SP;

   assign Zero_a_SN = Start_S?(Exp_a_prenorm_zero_S&&Mant_a_prenorm_zero_S):Zero_a_SP;
   assign Zero_b_SN = Start_S?(Exp_b_prenorm_zero_S&&Mant_b_prenorm_zero_S):Zero_b_SP;
   assign Inf_a_SN = Start_S?(Exp_a_prenorm_Inf_NaN_S&&Mant_a_prenorm_zero_S):Inf_a_SP;
   assign Inf_b_SN = Start_S?(Exp_b_prenorm_Inf_NaN_S&&Mant_b_prenorm_zero_S):Inf_b_SP;
   assign NaN_a_SN = Start_S?(Exp_a_prenorm_Inf_NaN_S&&(~Mant_a_prenorm_zero_S)):NaN_a_SP;
   assign NaN_b_SN = Start_S?(Exp_b_prenorm_Inf_NaN_S&&(~Mant_b_prenorm_zero_S)):NaN_b_SP;

    
   always_ff @(posedge Clk_CI, negedge Rst_RBI)   // Quotient
     begin
        if(~Rst_RBI)
          begin
            Zero_a_SP <='0;
            Zero_b_SP <='0;
            Inf_a_SP <='0;
            Inf_b_SP <='0;
            NaN_a_SP <='0;
            NaN_b_SP <='0;
          end
 
        else 
         begin 
           Inf_a_SP <=Inf_a_SN;
           Inf_b_SP <=Inf_b_SN;
           Zero_a_SP <=Zero_a_SN;
           Zero_b_SP <=Zero_b_SN;
           NaN_a_SP <=NaN_a_SN;
           NaN_b_SP <=NaN_b_SN;
         end

      end
   /////////////////////////////////////////////////////////////////////////////
   // Low power control
   /////////////////////////////////////////////////////////////////////////////
   logic               Special_case_SB;
   logic               Special_case_dly_SB;
 
    
   assign Special_case_SB=~(Zero_a_SN | Zero_b_SN |  Inf_a_SN | Inf_b_SN | NaN_a_SN | NaN_b_SN);
   assign Special_case_dly_SB=~(Zero_a_SP | Zero_b_SP |  Inf_a_SP | Inf_b_SP | NaN_a_SP | NaN_b_SP);

   /////////////////////////////////////////////////////////////////////////////
   // Delay operands for normalization and round
   /////////////////////////////////////////////////////////////////////////////

   logic [C_OP-1:0]             Operand_a_dly_DN;
   logic [C_OP-1:0]             Operand_a_dly_DP;
   logic [C_OP-1:0]             Operand_b_dly_DN;
   logic [C_OP-1:0]             Operand_b_dly_DP;

   always_comb   
     begin
       if(~Rst_RBI)
         begin
           Operand_a_dly_DN = '0;
           Operand_b_dly_DN = '0;
         end
       else if(Start_S) 
         begin
           Operand_a_dly_DN = Operand_a_DI;
           Operand_b_dly_DN = Operand_b_DI;
         end
       else 
         begin
           Operand_a_dly_DN = Operand_a_dly_DP;
           Operand_b_dly_DN = Operand_b_dly_DP;
         end
    end 


   always_ff @(posedge Clk_CI, negedge Rst_RBI)   
     begin
        if(~Rst_RBI)
          begin
            Operand_a_dly_DP <= '0;
            Operand_b_dly_DP <= '0;
          end
        else 
          begin
            Operand_a_dly_DP <= Operand_a_dly_DN;
            Operand_b_dly_DP <= Operand_b_dly_DN;
          end
    end 
   


   /////////////////////////////////////////////////////////////////////////////
   // Delay sign for normalization and round
   /////////////////////////////////////////////////////////////////////////////

   logic                   Sign_z_DN;
   logic                   Sign_z_DP;

   always_comb   
     begin
       if(~Rst_RBI)
         begin
           Sign_z_DN = '0;
         end
       else if(Div_start_SI)
           Sign_z_DN = Sign_a_D ^ Sign_b_D;
       else if(Sqrt_start_SI)
           Sign_z_DN = Sign_a_D;
       else
           Sign_z_DN = Sign_z_DP; 
    end 


 
   always_ff @(posedge Clk_CI, negedge Rst_RBI)   
     begin
       if(~Rst_RBI)
          begin
            Sign_z_DP <= '0;
          end
       else
         begin  
            Sign_z_DP <= Sign_z_DN;
         end 
    end  




   logic [C_RM-1:0]                  RM_DN;
   logic [C_RM-1:0]                  RM_DP;

   always_comb   
     begin
       if(~Rst_RBI)
         begin
           RM_DN = '0;
         end
       else if(Start_S)
           RM_DN = RM_SI;
       else
           RM_DN = RM_DP; 
    end 


 
   always_ff @(posedge Clk_CI, negedge Rst_RBI)   
     begin
       if(~Rst_RBI)
          begin
            RM_DP <= '0;
          end
       else
         begin  
            RM_DP <= RM_DN;
         end 
    end 
   assign RM_dly_SO = RM_DP;




 
   logic [4:0]                  Mant_leadingOne_a, Mant_leadingOne_b;
   logic                        Mant_zero_S_a,Mant_zero_S_b;
   //Detect leading one  
   firstone 
     #(.G_VECTORLEN(C_MANT+1),
       .G_FLIPVECTOR(1))
   LOD_Ua
     (
      .Vector_DI(Mant_a_D),
      .FirstOneIdx_DO(Mant_leadingOne_a),
      .NoOnes_SO(Mant_zero_S_a)
      );
 

   logic [C_MANT:0]            Mant_a_norm_DN,Mant_a_norm_DP;
   
   assign  Mant_a_norm_DN = (Start_S&Special_case_SB)?(Mant_a_D<<(Mant_leadingOne_a)):Mant_a_norm_DP;

   always_ff @(posedge Clk_CI, negedge Rst_RBI)  
     begin
        if(~Rst_RBI)
          begin
            Mant_a_norm_DP <= '0;
          end
        else  
          begin
            Mant_a_norm_DP<=Mant_a_norm_DN;
          end
     end 
   

   logic [C_EXP:0]            Exp_a_norm_DN,Exp_a_norm_DP;
   assign  Exp_a_norm_DN = (Start_S&Special_case_SB)?(Exp_a_D-Mant_leadingOne_a+(|Mant_leadingOne_a)):Exp_a_norm_DP;

   always_ff @(posedge Clk_CI, negedge Rst_RBI)  
     begin
        if(~Rst_RBI)
          begin
            Exp_a_norm_DP <= '0;
          end
        else  
          begin
            Exp_a_norm_DP<=Exp_a_norm_DN;
          end
     end 
                                  
   

   firstone 
     #(.G_VECTORLEN(C_MANT+1),
       .G_FLIPVECTOR(1))
   LOD_Ub
     (
      .Vector_DI(Mant_b_D),
      .FirstOneIdx_DO(Mant_leadingOne_b),
      .NoOnes_SO(Mant_zero_S_b)
      );




   logic [C_MANT:0]            Mant_b_norm_DN,Mant_b_norm_DP;
   
   assign  Mant_b_norm_DN = (Start_S&Special_case_SB)?(Mant_b_D<<(Mant_leadingOne_b)):Mant_b_norm_DP;

   always_ff @(posedge Clk_CI, negedge Rst_RBI)  
     begin
        if(~Rst_RBI)
          begin
            Mant_b_norm_DP <= '0;
          end
        else  
          begin
            Mant_b_norm_DP<=Mant_b_norm_DN;
          end
     end 
   

   logic [C_EXP:0]            Exp_b_norm_DN,Exp_b_norm_DP;
   assign  Exp_b_norm_DN = (Start_S&Special_case_SB)?(Exp_b_D-Mant_leadingOne_b+(|Mant_leadingOne_b)):Exp_b_norm_DP;

   always_ff @(posedge Clk_CI, negedge Rst_RBI)  
     begin
        if(~Rst_RBI)
          begin
            Exp_b_norm_DP <= '0;
          end
        else  
          begin
            Exp_b_norm_DP<=Exp_b_norm_DN;
          end
     end 



 



   
   /////////////////////////////////////////////////////////////////////////////
   // Output assignments
   /////////////////////////////////////////////////////////////////////////////

   assign Start_SO=Start_S;

   assign Exp_a_DO_norm=Exp_a_norm_DP;
   assign Exp_b_DO_norm=Exp_b_norm_DP;

   assign Mant_a_DO_norm=Mant_a_norm_DP;
   assign Mant_b_DO_norm=Mant_b_norm_DP;

   assign Operand_a_dly_DO = Operand_a_dly_DP;
   assign Operand_b_dly_DO = Operand_b_dly_DP;

   assign Sign_z_DO=Sign_z_DP;
   assign Inf_a_SO=Inf_a_SP;
   assign Inf_b_SO=Inf_b_SP;
   assign Zero_a_SO=Zero_a_SP;
   assign Zero_b_SO=Zero_b_SP;
   assign NaN_a_SO=NaN_a_SP;
   assign NaN_b_SO=NaN_b_SP;
   assign Special_case_dly_SBO=Special_case_dly_SB;
 
     
endmodule // 
