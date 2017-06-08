#! /bin/tcsh -f

# Example script for compiling RTL sourcecode

set VER=10.5a
set LIB=rtl


if (-e $LIB) then
  rm -rf $LIB 
endif

vlib-${VER} $LIB

# compile sourcecode


vlog-${VER}   -work ${LIB}       /usr/pack/umc-65-kgf/umc/ll/uk65lscllmvbbl/b03/verilog/uk65lscllmvbbl_sdf30.v
vlog-${VER}   -work ${LIB}       ../synopsys/div_sqrt_top.v 


 


# testbench (note no -check_synthesis)
vlog-${VER}   -sv -work ${LIB}       ../sourcecode/fpu_defs.sv 
vlog-${VER}   -sv -work ${LIB} ../sourcecode/testbench/div_sqrt_package.sv 
vlog-${VER}   -sv -work ${LIB} ../sourcecode/testbench/div_sqrt_tb_pkg.sv 
vlog-${VER}   -sv -work ${LIB} ../sourcecode/testbench/div_sqrt_testbench.sv

# use a command like 
#
vsim-${VER} -voptargs="+acc -suppress 2103" -lib rtl div_sqrt_testbench +nospecify +notimingchecks
#
# to simulate
