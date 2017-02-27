///////////////////////////////////////////////////////////////////////////////
// This file contains all div_sqrt_top parameters
//
// Authors    : Lei Li  (lile@iis.ee.ethz.ch)
//             
//
// Copyright (c) 2017 Integrated Systems Laboratory, ETH Zurich
///////////////////////////////////////////////////////////////////////////////


package fpu_defs_div_sqrt;

   // op command

   parameter C_RM           = 2;
   parameter C_RM_NEAREST   = 2'h0;
   parameter C_RM_TRUNC     = 2'h1;
   parameter C_RM_PLUSINF   = 2'h2;
   parameter C_RM_MINUSINF  = 2'h3;


   parameter C_OP           = 32;
   parameter C_MANT         = 23;
   parameter C_EXP          = 8;
   
   parameter C_MANT_PRENORM = C_MANT+1;
   parameter C_EXP_ZERO     = 8'h00;
   parameter C_EXP_INF      = 8'hff;
   parameter C_MANT_ZERO    = 23'h0;

         
   
   
endpackage : fpu_defs_div_sqrt
