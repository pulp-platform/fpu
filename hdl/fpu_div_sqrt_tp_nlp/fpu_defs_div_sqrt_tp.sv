/* Copyright (C) 2017 ETH Zurich, University of Bologna
 * All rights reserved.
 *
 * This code is under development and not yet released to the public.
 * Until it is released, the code is under the copyright of ETH Zurich and
 * the University of Bologna, and may contain confidential and/or unpublished
 * work. Any reuse/redistribution is strictly forbidden without written
 * permission from ETH Zurich.
 *
 * Bug fixes and contributions will eventually be released under the
 * SolderPad open hardware license in the context of the PULP platform
 * (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
 * University of Bologna.
 */
///////////////////////////////////////////////////////////////////////////////
// This file contains all div_sqrt_top parameters                            //
//                                                                           //
// Authors    : Lei Li  (lile@iis.ee.ethz.ch)                                //
// Copyright (c) 2017 Integrated Systems Laboratory, ETH Zurich              //
///////////////////////////////////////////////////////////////////////////////


package fpu_defs_div_sqrt_tp;

   parameter C_DIV_RM           = 2;
   parameter C_DIV_RM_NEAREST   = 2'h0;
   parameter C_DIV_RM_TRUNC     = 2'h1;
   parameter C_DIV_RM_PLUSINF   = 2'h2;
   parameter C_DIV_RM_MINUSINF  = 2'h3;
   parameter C_DIV_PC           = 5;
   parameter C_DIV_OP           = 32;
   parameter C_DIV_MANT         = 23;
   parameter C_DIV_EXP          = 8;
   parameter C_DIV_BIAS         = 127;
   parameter C_DIV_BIAS_AONE    = 8'h80;
   parameter C_DIV_HALF_BIAS    = 63;
   parameter C_DIV_MANT_PRENORM = C_DIV_MANT+1;
   parameter C_DIV_EXP_ZERO     = 8'h00;
   parameter C_DIV_EXP_ONE      = 8'h01;
   parameter C_DIV_EXP_INF      = 8'hff;
   parameter C_DIV_MANT_ZERO    = 23'h0;
   parameter C_DIV_MANT_NAN     = 23'h400000;

endpackage : fpu_defs_div_sqrt_tp
