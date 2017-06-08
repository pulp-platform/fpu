#! /bin/tcsh -f

# Example script for compiling RTL fpu_div_sqrt

set VER=10.5a
set LIB=rtl


if (-e $LIB) then
  rm -rf $LIB 
endif

vlib-${VER} $LIB

# compile fpu_div_sqrt
vlog-${VER}  -sv -work ${LIB}       ../fpu_div_sqrt/fpu_defs_div_sqrt.sv 
vcom-${VER}  -work ${LIB}           ../fpu_div_sqrt/VHDLTools.vhd
vcom-${VER}  -work ${LIB}           ../fpu_div_sqrt/firstone.vhd
vlog-${VER}  -sv -work ${LIB}       ../fpu_div_sqrt/iteration_div_sqrt_first.sv 
vlog-${VER}  -sv -work ${LIB}       ../fpu_div_sqrt/iteration_div_sqrt.sv 
vlog-${VER}  -sv -work ${LIB}       ../fpu_div_sqrt/control.sv 
vlog-${VER}  -sv -work ${LIB}       ../fpu_div_sqrt/nrbd_nrsc.sv
vlog-${VER}  -sv -work ${LIB}       ../fpu_div_sqrt/preprocess.sv 
vlog-${VER}  -sv -work ${LIB}       ../fpu_div_sqrt/fpu_norm_div_sqrt.sv 
vlog-${VER}  -sv -work ${LIB}       ../fpu_div_sqrt/div_sqrt_top.sv 


 


# testbench (note no -check_synthesis)
vlog-${VER}   -sv -work ${LIB} ../fpu_div_sqrt/testbench/div_sqrt_package.sv 
vlog-${VER}   -sv -work ${LIB} ../fpu_div_sqrt/testbench/div_sqrt_tb_pkg.sv 
vlog-${VER}   -sv -work ${LIB} ../fpu_div_sqrt/testbench/div_sqrt_testbench.sv

# use a command like 
#
vsim-${VER} -voptargs="+acc -suppress 2103" -lib rtl div_sqrt_testbench
#
# to simulate
