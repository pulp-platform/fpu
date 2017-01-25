########################
# set up some vars
########################
set NumberThreads [exec cat /proc/cpuinfo | grep -c processor]
set_host_options -max_cores $NumberThreads

set TOP_ENTITY "div_sqrt_top"
set FPU_PATH "../sourcecode"

set TIME [clock seconds]
set FILE [clock format $TIME -format _%a_%d_%m_%Y_]

# use typical case library
# for driving and load
# set LIB uk65lscllmvbbr_120c25_tc
set LIB uk65lscllmvbbl_108c125_wc
set DRIV_CELL BUFM4W
set DRIV_PIN  Z
set LOAD_CELL BUFM4W
set LOAD_PIN  A

set clk_period 2.8

set clk_name Clk_CI
set rst_name Rst_RBI

########################
# clean
# do not use -all, that 
# one will delete all 
# std cell libraries
########################

remove_design *
exec rm -rf WORK


########################
# analyze and compile
########################

source scripts/analyze_fpu_pkg.tcl
source scripts/analyze_fpu.tcl

elaborate ${TOP_ENTITY} -architecture verilog -library WORK

link

current_design ${TOP_ENTITY}

set_driving_cell  -no_design_rule -library ${LIB} -lib_cell ${DRIV_CELL} -pin ${DRIV_PIN} [all_inputs]   
set_load [load_of ${LIB}/${LOAD_CELL}/${LOAD_PIN}] [all_outputs]   
create_clock $clk_name -period $clk_period

set_dont_touch_network -no_propagate $clk_name
set_dont_touch_network -no_propagate $rst_name
set_ideal_network -no_propagate $clk_name
set_ideal_network -no_propagate $rst_name

set_input_delay 1 -clock $clk_name [all_inputs]
set_output_delay 1 -clock $clk_name [all_outputs]

compile_ultra -no_autoungroup 



report_timing -through [get_ports {Operand_a_DI}]
report_timing -to [get_ports {Mant_res_D*}]
report_timing -path_type full -max_paths 500

 report_area  -hier
