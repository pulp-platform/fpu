analyze -format vhdl     -work WORK $FPU_PATH/VHDLTools.vhd 
analyze -format vhdl     -work WORK $FPU_PATH/firstone.vhd  
analyze -format sverilog -work WORK $FPU_PATH/fpexc.sv      
analyze -format sverilog -work WORK $FPU_PATH/fpu_norm.sv   
analyze -format sverilog -work WORK $FPU_PATH/fpu.sv	      
analyze -format sverilog -work WORK $FPU_PATH/fpu_add.sv    
analyze -format sverilog -work WORK $FPU_PATH/fpu_core.sv   
analyze -format sverilog -work WORK $FPU_PATH/fpu_ftoi.sv   
analyze -format sverilog -work WORK $FPU_PATH/fpu_itof.sv   
analyze -format sverilog -work WORK $FPU_PATH/fpu_mult.sv   
analyze -format sverilog -work WORK $FPU_PATH/fpu_private.sv
analyze -format sverilog -work WORK $FPU_PATH/fpu_shared.sv 












