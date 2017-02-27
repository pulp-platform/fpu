`timescale 1ns/1ns


import div_sqrt_package::*;
import div_sqrt_tb_pkg::*;

import fpu_defs_div_sqrt::*;

module div_sqrt_testbench
  (
   );
   
   parameter C_N_STIM = 1000;

   
   
// -----------------------------------------------------------------------------
// Reset and clock generation
// -----------------------------------------------------------------------------
   logic clk_i;
   logic rst_ni;

   // reset generator
   initial
     begin
        rst_ni = 1'b0;
        #RESET_DEL;
        rst_ni = 1'b1;
     end

   // clk generator
   initial
     begin
        clk_i = 1'b1;
        while(1) begin
           #CLK_PHASE_HI;
           clk_i = 1'b0;
           #CLK_PHASE_LO;
           clk_i = 1'b1;
        end
     end


// -----------------------------------------------------------------------------
// randomize enable signal for each core and operation for each stimuli
// -----------------------------------------------------------------------------
   int unsigned enable;
   int unsigned operation [C_N_STIM-1:0];
   
  

   // random enable signals
   initial begin
      int k;
      for (k=0;k<C_N_STIM;k++) begin
         int unsigned op_random;
         assert(std::randomize(op_random) with {op_random<=1;});
        operation[k] = op_random;
//      operation[k] =1;
      end
   end
   
               
// -----------------------------------------------------------------------------
// Device under test
// -----------------------------------------------------------------------------

   // TODO add your division/square-root block here


  logic                                Div_start_S,Sqrt_start_S;
  logic [31:0]                         Operand_a_DI, Operand_b_DI,result;
  logic [31:0]                         Result_D; 
  logic                                Ready_S,Done_S;
  logic [1:0]                          RM_SI;

 div_sqrt_top  div_top_U0
  (//Input
   .Clk_CI(clk_i),
   .Rst_RBI(rst_ni),

   .Div_start_SI(Div_start_S),
   .Sqrt_start_SI(Sqrt_start_S),

   //Input Operands
   .Operand_a_DI(Operand_a_DI),
   .Operand_b_DI(Operand_b_DI),
   .RM_SI(RM_SI),    //Rounding Mode


   .Result_DO(Result_D),

   .Exp_OF_SO(),
   .Exp_UF_SO(),
   .Div_zero_SO(),
   .Ready_SO(Ready_S),
   .Done_SO(Done_S)
 );
   




   
// -----------------------------------------------------------------------------
// stimuli generation
// -----------------------------------------------------------------------------
   
   logic [31:0] check_result [C_N_STIM-1:0];
   logic [31:0] opa [C_N_STIM-1:0];
   logic [31:0] opb [C_N_STIM-1:0];
   logic [31:0] opc [C_N_STIM-1:0];
   
   int       ind_stim;
   logic     incr_stim;

   initial begin
      int k;
      for (k=0;k<C_N_STIM;k++) begin
       if(k<C_N_STIM-23)begin
         gen_stimuli(operation[k], opa[k],opb[k],opc[k],check_result[k]);
       end
      else if(k==C_N_STIM-23)begin
//               a/+NaN
       operation[k]=1'b0;
       opa[k]=32'h50600000; 
       opb[k]=32'h7fff0000;   
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
      end
     else if(k==C_N_STIM-22)begin
//               a/-NaN
       operation[k]=1'b0;
       opa[k]=32'h50600000; 
       opb[k]=32'hffff0000;  
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k])); 
      end

     else if(k==C_N_STIM-21)begin

//               +NaN/b
       operation[k]=1'b0;
       opa[k]=32'h7fff1000;   
       opb[k]=32'h50600000; 
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end
     else if(k==C_N_STIM-20)begin

//               -NaN/b
       operation[k]=1'b0;
       opa[k]=32'hffff1000;   
       opb[k]=32'h50600000;  
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k])); 
       end 
     else if(k==C_N_STIM-19)begin

//               a/+Inf
       operation[k]=1'b0;
       opa[k]=32'h50600000; 
       opb[k]=32'h7f800000;  //+Inf
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 
     else if(k==C_N_STIM-18)begin

//               a/-Inf
       operation[k]=1'b0;
       opa[k]=32'h50600000;
       opb[k]=32'hff800000;   
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 

     else if(k==C_N_STIM-17)begin

//               a/+0
       operation[k]=1'b0;
       opa[k]=32'h50600000;
       opb[k]=32'h00000000;  //+0
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 
     else if(k==C_N_STIM-16)begin

//               a/-0
       operation[k]=1'b0;
       opa[k]=32'h50600000;
       opb[k]=32'h80000000;  //-0
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 

     else if(k==C_N_STIM-15)begin

//               +0/b
       operation[k]=1'b0;
       opa[k]=32'h00000000;  //+0
       opb[k]=32'h50600000;
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 
     else if(k==C_N_STIM-14)begin

//               -0/b
       operation[k]=1'b0;
       opa[k]=32'h80000000;  //-0
       opb[k]=32'h50600000;
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 

     else if(k==C_N_STIM-13)begin

//               +0/+Inf
       operation[k]=1'b0;
       opa[k]=32'h00000000;  //+0
       opb[k]=32'h7f800000;  //+INf
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 
     else if(k==C_N_STIM-12)begin

//               -0/+Inf
       operation[k]=1'b0;
       opa[k]=32'h80000000;  //-0
       opb[k]=32'h7f800000;  //+INf
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 

     else if(k==C_N_STIM-11)begin

//               +0/-Inf
       operation[k]=1'b0;
       opa[k]=32'h00000000;  //+0
       opb[k]=32'hff800000;  //-Inf
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 
     else if(k==C_N_STIM-10)begin

//               -0/-Inf
       operation[k]=1'b0;
       opa[k]=32'h80000000;  //-0
       opb[k]=32'hff800000;  //-Inf
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 

     else if(k==C_N_STIM-9)begin

//               +Inf/b
       operation[k]=1'b0;
       opa[k]=32'h7f800000;  //+Inf
       opb[k]=32'h50600000;
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 

     else if(k==C_N_STIM-8)begin

//               -Inf/b
       operation[k]=1'b0;
       opa[k]=32'hff800000;  //-Inf
       opb[k]=32'h50600000;
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 


     else if(k==C_N_STIM-7)begin

//               +Inf/+0
       operation[k]=1'b0;
       opa[k]=32'h7f800000;  //+Inf
       opb[k]=32'h00000000;  //+0
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 

     else if(k==C_N_STIM-6)begin

//               -Inf/+0
       operation[k]=1'b0;
       opa[k]=32'hff800000;  //-Inf
       opb[k]=32'h00000000;  //+0
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 

     else if(k==C_N_STIM-5)begin

//               +Inf/-0
       operation[k]=1'b0;
       opa[k]=32'h7f800000;  //+Inf
       opb[k]=32'h80000000;  //-0
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end 

     else if(k==C_N_STIM-4)begin

//               -Inf/-0
       operation[k]=1'b0;
       opa[k]=32'hff800000;  //-Inf
       opb[k]=32'h80000000;  //-0
       check_result[k]=$shortrealtobits($bitstoshortreal(opa[k])/$bitstoshortreal(opb[k]));
       end

//square root 
     else if(k==C_N_STIM-3)begin
//               +NaN
       operation[k]=1'b1; 
       opa[k]=32'h7fff0000;  
       opb[k]=32'h00000000; 
       check_result[k]=$shortrealtobits(($bitstoshortreal(opa[k]&32'h7fffffff))**(0.5));
      end

     else if(k==C_N_STIM-2)begin

//               +Inf
       operation[k]=1'b1;
       opa[k]=32'h7f800000;  //+Inf
       opb[k]=32'h00000000;  //+0
       check_result[k]=$shortrealtobits(($bitstoshortreal(opa[k]&32'h7fffffff))**(0.5));
       end 

    else if(k==C_N_STIM-1)begin

//               +0
       operation[k]=1'b1;
       opa[k]=32'h00000000;  //+0
       opb[k]=32'h00000000;  //+0
       check_result[k]=$shortrealtobits(($bitstoshortreal(opa[k]&32'h7fffffff))**(0.5));
       end 

	
   end
   

end
// -----------------------------------------------------------------------------
// stimuli application
// -----------------------------------------------------------------------------
  


  initial begin
   Div_start_S = 1'b0;
   Sqrt_start_S= 1'b0; 
   RM_SI = 2'b00; 
   #RESET_DEL_ADD_STIM; 
  while (ind_stim<C_N_STIM) begin
   if(operation[ind_stim]==1)
   begin
   Div_start_S = 1'b0;
   Sqrt_start_S=1'b1;
   #CLK_PERIOD;
   Sqrt_start_S=1'b0;
   end
   else
   begin
   Div_start_S = 1'b1;
   Sqrt_start_S=1'b0;
   #CLK_PERIOD;
   Div_start_S=1'b0;
   end
 //   #CLK_PERIOD;
    #CLK_PERIOD;
    #CLK_PERIOD; 
    #CLK_PERIOD;
    #CLK_PERIOD;
    #CLK_PERIOD;
    #CLK_PERIOD;  
     end  
  end

   logic start;

//assign start=Div_start_S |Sqrt_start_S;

  initial begin
   start = 1'b0;
   #RESET_DEL_ADD_STIM; 
//   #CLK_PERIOD;
   start = 1'b1;  
   #CLK_PERIOD;
   start=1'b0;
  end

   initial begin
     Operand_a_DI='0;
     Operand_b_DI='0; 
     #RESET_DEL_ADD_STIM; 
     while (ind_stim<C_N_STIM) begin
     Operand_a_DI=opa[ind_stim];
//Operand_a_DI=opa[1];
    Operand_b_DI=opb[ind_stim]; 
//Operand_b_DI=opb[1];
//For the division first test
//       Operand_a_DI=32'h50600000; 
//       Operand_b_DI=32'h40600000;   
//               a/NaN
//       Operand_a_DI=32'h50600000; 
//       Operand_b_DI=32'h7fff0000;   

//               NaN/b
//       Operand_b_DI=32'h50600000; 
//       Operand_a_DI=32'h7fff1000;   
    
//               a/+-Inf
//       Operand_a_DI=32'h50600000; 
//       Operand_b_DI=32'h7f800000;  //+INf
//       Operand_b_DI=32'hff800000;  //-Inf
//               a/0
//       Operand_a_DI=32'h50600000; 
//       Operand_b_DI=32'h00000000;  //+0
//       Operand_b_DI=32'h80000000;  //-0

//               0/b
//       Operand_b_DI=32'h50600000; 
//       Operand_a_DI=32'h00000000;  //+0
//       Operand_a_DI=32'h80000000;  //-0

//               +-0/+-Inf

//       Operand_a_DI=32'h00000000;  //+0
//       Operand_a_DI=32'h80000000;  //-0
//       Operand_b_DI=32'h7f800000;  //+INf
//       Operand_b_DI=32'hff800000;  //-Inf

//               +-Inf/b
//       Operand_b_DI=32'h50600000; 
//       Operand_a_DI=32'h7f800000;  //+INf
//       Operand_a_DI=32'hff800000;  //-Inf

//               +-Inf/+-0


//       Operand_a_DI=32'h7f800000;  //+INf
//       Operand_a_DI=32'hff800000;  //-Inf
//       Operand_b_DI=32'h00000000;  //+0
//       Operand_b_DI=32'h80000000;  //-0

//For the sqrt first test
//       Operand_a_DI=32'h44440000; 
//       Operand_b_DI=32'h00000000;  

//           NaN
//
//       Operand_a_DI=32'hffff1000; 
//       Operand_b_DI=32'h00000000;

//           0
//       Operand_a_DI=32'h00000000; 
//       Operand_b_DI=32'h00000000;
//         INf
//       Operand_a_DI=32'h7f800000;  //+INf
//       Operand_a_DI=32'hff800000;  //-Inf
//       Operand_b_DI=32'h00000000;

     #LATENCY;
     end
  end
 
// -----------------------------------------------------------------------------
// response aquisition and checker
// -----------------------------------------------------------------------------

   integer   ind;
   logic     incr;

   // check acknowledge
   initial begin
      incr_stim = 1'b0;
      #RESET_DEL_ADD_RESP;
      while (ind_stim<C_N_STIM) begin
         if (Done_S|start)
           incr_stim = 1'b1;
         else
           incr_stim = 1'b0;
         #CLK_PERIOD;
      end
      incr_stim = 1'b0;
   end

         shortreal opa_abs_float_sqrt;  
         logic [31:0] check_result_sqrt; 
logic [31:0]  Operand_a_DI_tmp;

//assign        Operand_a_DI_tmp=32'h44440000;   
//assign        Operand_a_DI_tmp=opa[6];   
//assign              opa_abs_float_sqrt = $bitstoshortreal(Operand_a_DI&32'h7fffffff);
//assign              check_result_sqrt = $shortrealtobits(opa_abs_float_sqrt**(0.5)); // square root
//logic [31:0] check_result_div; 
//assign        check_result_div = $shortrealtobits($bitstoshortreal(Operand_a_DI)/$bitstoshortreal(Operand_b_DI));

   int errors = 0;
 
   logic [31:0] result_us_d;
   assign result_us_d=Result_D;     
   initial begin
      incr = 1'b0;
      #RESET_DEL_ADD_RESP;
      while(ind<C_N_STIM) begin
         incr = 1'b0;
         if (Done_S) begin
//         if (result_us_d!=check_result[ind]) begin
//         if (result_us_d!=check_result_sqrt) begin
         if ((result_us_d!=check_result[ind]) && (result_us_d!=check_result[ind]+1)  && (result_us_d!=check_result[ind]-1) ) begin 
               $error("wrong result: expected: %h, is: %h ; ind: %d; operation: %d",check_result[ind],result_us_d, ind, operation[ind]);
               errors++;
            end
            //      else
            //                 $display("check passed!");
            incr = 1'b1;
            
         end
         else
           incr = 1'b0;
         #LATENCY;
      end
      incr = 1'b0;
   end

// -----------------------------------------------------------------------------
// index tracker for stimuli and responses
// -----------------------------------------------------------------------------

   always_ff @(posedge clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
         ind = 0;
         ind_stim = 0;
      end
      else begin
         if(Done_S) begin
            ind = ind + 1;
         end
         if(Done_S|start) begin
            ind_stim = ind_stim + 1;
         end

      end
   end


/*   initial begin
      incr = 1'b0;
      #RESET_DEL_ADD_RESP;
      while(ind<C_N_STIM) begin
         if (Done_S) begin
            ind = ind + 1;
         end
         if(Done_S|start) begin
            ind_stim = ind_stim + 1;
         end
      #LATENCY;
     end
   end

*/
  
   
// -----------------------------------------------------------------------------
// end of simulation determination and final block
// -----------------------------------------------------------------------------
   
   always_comb begin
      
      if(ind==C_N_STIM)
        $finish;
   end
   
   final begin
      $display("verified %d stimuli; found %d errors!", C_N_STIM ,errors);
   end
      
endmodule
