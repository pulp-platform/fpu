
package div_sqrt_package;

   parameter C_NOPS    = 2;
   
   parameter C_OP_DIV  = 0;
   parameter C_OP_SQRT = 1;
   
   
   
   // FP-defines
   parameter C_NAN_P = 32'h7fc00000;
   parameter C_NAN_N = 32'hffc00000;
   parameter C_ZERO_P = 32'h00000000;
   parameter C_ZERO_N = 32'h80000000;
   parameter C_INF_P = 32'h7f800000;
   parameter C_INF_N = 32'hff800000;
   parameter C_MAX_INT = 32'h7fffffff;
   parameter C_MIN_INT = 32'h80000000;
   parameter C_MAX_INT_F = (2**31)-1;
   parameter C_MIN_INT_F = -(2**31);
   
   //
   parameter C_DIV_LATENCY = 7;
   
   
endpackage
