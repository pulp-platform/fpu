package div_sqrt_tb_pkg;
import div_sqrt_package::*;
   
	 // --------------------------------------------------------------------------
	 // Timing of clock and simulation events.
	 // --------------------------------------------------------------------------
	 const time CLK_PHASE_HI       = 5ns;                         // Clock high time
	 const time CLK_PHASE_LO       = 5ns;                         // Clock low time
	 const time CLK_PERIOD         = CLK_PHASE_HI + CLK_PHASE_LO; // Clock period
	 const time STIM_APP_DEL       = CLK_PERIOD*0.5;              // Stimuli application delay
	 const time RESP_ACQ_DEL       = CLK_PERIOD*7.5;              // Response aquisition delay
	 const time RESET_DEL          = 50ns;         // Delay of the reset
         const time RESET_DEL_ADD_STIM          = 50ns + STIM_APP_DEL;   
         const time RESET_DEL_ADD_RESP          = 50ns + RESP_ACQ_DEL;    
         const time LATENCY                     = CLK_PERIOD*C_DIV_LATENCY; 
	 
	 // --------------------------------------------------------------------------
   //
   //            CLK_PERIOD
	 //   <------------------------->
	 //   --------------            --------------
	 //   |  A         |        T   |            |
	 // ---            --------------            --------------
	 //   <-->
	 //   STIM_APP_DEL
	 //   <--------------------->
	 //   RESP_ACQ_DEL
	 //
	 // --------------------------------------------------------------------------  

   function automatic void gen_stimuli(
                             input int unsigned operation,
                             output logic [31:0] opa_out,
                             output logic [31:0] opb_out,
                             output logic [31:0] opc_out,
                             output logic [31:0] check_result);
      begin
         logic [31:0] opa_in_bit;
         logic [31:0] opb_in_bit;
         logic [31:0] opc_in_bit;
         integer      fti_result;
         integer      opa_int;

         shortreal opa_float;
         shortreal opb_float;
         shortreal opc_float;
         shortreal opa_abs_float;
         shortreal itf_result;
         
         // randomize inputs with constraints
         assert(std::randomize(opa_in_bit) with {((opa_in_bit&C_INF_P)!=C_INF_P);});
         assert(std::randomize(opb_in_bit) with {((opb_in_bit&C_INF_P)!=C_INF_P);});
         assert(std::randomize(opc_in_bit) with {((opc_in_bit&C_INF_P)!=C_INF_P);});

         opa_float = $bitstoshortreal(opa_in_bit);
         opb_float = $bitstoshortreal(opb_in_bit);
         opc_float = $bitstoshortreal(opc_in_bit);

         opa_out = opa_in_bit;
         opb_out = opb_in_bit;
         opc_out = opc_in_bit;

         case (operation)
           C_OP_DIV:  check_result = $shortrealtobits(opa_float/opb_float); // division
           C_OP_SQRT: begin
              opa_abs_float = $bitstoshortreal(opa_in_bit&32'h7fffffff);
              check_result = $shortrealtobits(opa_abs_float**(0.5)); // square root
              opa_out = $shortrealtobits(opa_abs_float);
           end
         endcase
      end
   endfunction
      
endpackage
