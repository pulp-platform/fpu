analyze -format vhdl     -work WORK $FPU_PATH/VHDLTools.vhd 
analyze -format vhdl     -work WORK $FPU_PATH/firstone.vhd   
analyze -format sverilog -work WORK $FPU_PATH/fpu_norm_div_sqrt.sv   	      
analyze -format sverilog -work WORK $FPU_PATH/iteration_div_sqrt_first.sv    
analyze -format sverilog -work WORK $FPU_PATH/iteration_div_sqrt.sv 
analyze -format sverilog -work WORK $FPU_PATH/control.sv   
analyze -format sverilog -work WORK $FPU_PATH/nrbd_nrsc.sv   
analyze -format sverilog -work WORK $FPU_PATH/preprocess.sv   
analyze -format sverilog -work WORK $FPU_PATH/div_sqrt_top.sv













