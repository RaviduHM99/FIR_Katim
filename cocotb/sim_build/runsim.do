# Autogenerated file
onerror {
	quit -f -code 1
}
vmap -c
if [file exists sim_build/work] {vdel -lib sim_build/work -all}
vlib sim_build/work
vmap work sim_build/work
vcom -work work +acc C:/Projects/FIR_Katim/packages/params_package.vhdl C:/Projects/FIR_Katim/packages/coeff_package.vhdl C:/Projects/FIR_Katim/rtl/fir_v7.vhdl C:/Projects/FIR_Katim/rtl/firFixedAXI.vhdl
vsim -gui -onfinish exit -t 1ps -foreign "cocotb_init C:/Python312/Lib/site-packages/cocotb/libs/cocotbfli_modelsim.dll"   sim_build/work.firfixedaxi
onbreak resume
run -all
quit
