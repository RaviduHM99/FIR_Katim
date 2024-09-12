# You can Parameterized and Pass Parameters through here***********************************
set PROJ_NAME firFilter
set PROJ_FOLDER FIRVivado
set PROJ_DIR ../work/firFilter

set PACKAGE_FOLDER ../packages
set SOURCE_FOLDER ../rtl
set TB_FOLDER ../sim
set CONSTR_FOLDER ../constraints
set REPORT_FOLDER ../reports

# Check if the project directory exists and is a directory
if {[file exists $PROJ_DIR] && [file isdirectory $PROJ_DIR]} {
    exec rm -r $PROJ_FOLDER
}

# Create Project 
create_project $PROJ_NAME ./$PROJ_FOLDER -part xczu7ev-ffvc1156-2-e -force
set_property board_part xilinx.com:zcu106:part0:2.6 [current_project]

# Add Packages
add_files [glob $PACKAGE_FOLDER/*.vhdl]
set_property library xil_defaultlib [get_files  $PACKAGE_FOLDER/params_package.vhdl] 
set_property library xil_defaultlib [get_files  $PACKAGE_FOLDER/coeff_package.vhdl]
set_property file_type {VHDL 2008} [get_files  $PACKAGE_FOLDER/params_package.vhdl]
set_property file_type {VHDL 2008} [get_files  $PACKAGE_FOLDER/coeff_package.vhdl]

# Add Design Sources
add_files -norecurse $SOURCE_FOLDER/fir_v7.vhdl
add_files -norecurse $SOURCE_FOLDER/firFixedAXI.vhdl
set_property file_type {VHDL 2008} [get_files  $SOURCE_FOLDER/fir_v7.vhdl]
set_property file_type {VHDL 2008} [get_files  $SOURCE_FOLDER/firFixedAXI.vhdl]

add_files -norecurse $SOURCE_FOLDER/fir_wrapper.v

create_bd_design "design_1"
open_bd_design {$PROJ_DIR.srcs/sources_1/bd/design_1/design_1.bd}
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_0
create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_1
create_bd_cell -type module -reference fir_wrapper fir_wrapper_0
endgroup
set_property -dict [list \
  CONFIG.Clock_Type_AXI {Independent_Clock} \
  CONFIG.Enable_TLAST {true} \
  CONFIG.HAS_ACLKEN {false} \
  CONFIG.INTERFACE_TYPE {AXI_STREAM} \
  CONFIG.Input_Depth_axis {512} \
  CONFIG.TDATA_NUM_BYTES {2} \
  CONFIG.TUSER_WIDTH {0} \
] [get_bd_cells fifo_generator_0]
set_property -dict [list \
  CONFIG.Clock_Type_AXI {Independent_Clock} \
  CONFIG.Enable_TLAST {true} \
  CONFIG.HAS_ACLKEN {false} \
  CONFIG.INTERFACE_TYPE {AXI_STREAM} \
  CONFIG.Input_Depth_axis {512} \
  CONFIG.TDATA_NUM_BYTES {2} \
  CONFIG.TUSER_WIDTH {0} \
] [get_bd_cells fifo_generator_1]

connect_bd_intf_net [get_bd_intf_pins fir_wrapper_0/s_axis] [get_bd_intf_pins fifo_generator_0/M_AXIS]
connect_bd_intf_net [get_bd_intf_pins fir_wrapper_0/m_axis] [get_bd_intf_pins fifo_generator_1/S_AXIS]
connect_bd_net [get_bd_pins fifo_generator_0/m_aclk] [get_bd_pins fifo_generator_1/s_aclk]

startgroup
make_bd_pins_external  [get_bd_pins fir_wrapper_0/clk]
make_bd_intf_pins_external  [get_bd_intf_pins fifo_generator_1/M_AXIS]
make_bd_intf_pins_external  [get_bd_intf_pins fifo_generator_0/S_AXIS]
make_bd_pins_external  [get_bd_pins fir_wrapper_0/rstn]
endgroup

connect_bd_net [get_bd_ports rstn_0] [get_bd_pins fifo_generator_1/s_aresetn]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {New Clocking Wizard} Freq {128} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins fifo_generator_0/s_aclk]

startgroup
set_property -dict [list \
  CONFIG.CLKOUT1_DRIVES {Buffer} \
  CONFIG.CLKOUT1_JITTER {144.719} \
  CONFIG.CLKOUT1_PHASE_ERROR {114.212} \
  CONFIG.CLKOUT2_DRIVES {Buffer} \
  CONFIG.CLKOUT3_DRIVES {Buffer} \
  CONFIG.CLKOUT4_DRIVES {Buffer} \
  CONFIG.CLKOUT5_DRIVES {Buffer} \
  CONFIG.CLKOUT6_DRIVES {Buffer} \
  CONFIG.CLKOUT7_DRIVES {Buffer} \
  CONFIG.MMCM_BANDWIDTH {OPTIMIZED} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {8} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {8} \
  CONFIG.MMCM_COMPENSATION {AUTO} \
  CONFIG.PRIMITIVE {PLL} \
] [get_bd_cells clk_wiz]

set_property -dict [list \
  CONFIG.CLKOUT1_JITTER {182.553} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {32} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {25} \
] [get_bd_cells clk_wiz]

set_property -dict [list \
  CONFIG.RESET_PORT {resetn} \
  CONFIG.RESET_TYPE {ACTIVE_LOW} \
] [get_bd_cells clk_wiz]
endgroup
connect_bd_net [get_bd_ports rstn_0] [get_bd_pins clk_wiz/resetn]
connect_bd_net [get_bd_pins clk_wiz/resetn] [get_bd_pins rst_clk_wiz_100M/ext_reset_in]

set_property -dict [list CONFIG.FREQ_HZ 32000000 CONFIG.TDATA_NUM_BYTES 4] [get_bd_intf_ports S_AXIS_0]
set_property -dict [list CONFIG.FREQ_HZ 32000000 CONFIG.TDATA_NUM_BYTES 4] [get_bd_intf_ports M_AXIS_0]

startgroup
set_property CONFIG.TDATA_NUM_BYTES {4} [get_bd_cells fifo_generator_0]
set_property CONFIG.TDATA_NUM_BYTES {4} [get_bd_cells fifo_generator_1]
endgroup

connect_bd_net [get_bd_pins fifo_generator_1/m_aclk] [get_bd_pins clk_wiz/clk_out1]
connect_bd_net [get_bd_ports clk_0] [get_bd_pins fifo_generator_1/s_aclk]
connect_bd_net [get_bd_ports clk_0] [get_bd_pins clk_wiz/clk_in1]

validate_bd_design

make_wrapper -files [get_files $PROJ_FOLDER/firFilter.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse $PROJ_FOLDER/firFilter.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v
set_property top design_1_wrapper [current_fileset]

# Add Simulation Sources
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $TB_FOLDER/fifo_tb.sv
update_compile_order -fileset sources_1

set_property top fifo_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {3000ns} -objects [get_filesets sim_1]

# Generate Output Products of Block Design
generate_target all [get_files  $PROJ_FOLDER/firFilter.srcs/sources_1/bd/design_1/design_1.bd]
catch { config_ip_cache -export [get_ips -all design_1_fifo_generator_0_0] }
catch { config_ip_cache -export [get_ips -all design_1_fifo_generator_1_0] }
catch { config_ip_cache -export [get_ips -all design_1_fir_wrapper_0_0] }
catch { config_ip_cache -export [get_ips -all design_1_clk_wiz_0] }
catch { config_ip_cache -export [get_ips -all design_1_rst_clk_wiz_100M_0] }
export_ip_user_files -of_objects [get_files $PROJ_FOLDER/firFilter.srcs/sources_1/bd/design_1/design_1.bd] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_FOLDER/firFilter.srcs/sources_1/bd/design_1/design_1.bd]
launch_runs design_1_clk_wiz_0_synth_1 design_1_fifo_generator_0_0_synth_1 design_1_fifo_generator_1_0_synth_1 design_1_fir_wrapper_0_0_synth_1 design_1_rst_clk_wiz_100M_0_synth_1 -jobs 4
export_simulation -of_objects [get_files $PROJ_FOLDER/firFilter.srcs/sources_1/bd/design_1/design_1.bd] -directory $PROJ_FOLDER/firFilter.ip_user_files/sim_scripts -ip_user_files_dir $PROJ_FOLDER/firFilter.ip_user_files -ipstatic_source_dir $PROJ_FOLDER/firFilter.ip_user_files/ipstatic -lib_map_path [list {modelsim=$PROJ_FOLDER/firFilter.cache/compile_simlib/modelsim} {questa=$PROJ_FOLDER/firFilter.cache/compile_simlib/questa} {riviera=$PROJ_FOLDER/firFilter.cache/compile_simlib/riviera} {activehdl=$PROJ_FOLDER/firFilter.cache/compile_simlib/activehdl}] -use_ip_compiled_libs -force -quiet
wait_on_run design_1_fifo_generator_0_0_synth_1
wait_on_run design_1_fifo_generator_1_0_synth_1
wait_on_run design_1_fir_wrapper_0_0_synth_1
wait_on_run design_1_clk_wiz_0_synth_1
wait_on_run design_1_rst_clk_wiz_100M_0_synth_1

# Check Lints
synth_design -top design_1_wrapper -part xczu7ev-ffvc1156-2-e -lint 
wait_on_run design_1_fifo_generator_0_0_synth_1
wait_on_run design_1_fifo_generator_1_0_synth_1
wait_on_run design_1_fir_wrapper_0_0_synth_1
wait_on_run design_1_clk_wiz_0_synth_1
wait_on_run design_1_rst_clk_wiz_100M_0_synth_1

# Simulation and Waveform generation
launch_simulation

# Add Constraint Files
add_files -fileset constrs_1 -norecurse $CONSTR_FOLDER/fir_fifo.xdc
set_property target_constrs_file $CONSTR_FOLDER/fir_fifo.xdc [current_fileset -constrset]

# Run Synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1
open_run synth_1 -name netlist_1

#Output Resource Utilization, Timing Diagram, Power
report_timing_summary -file $REPORT_FOLDER/fifo_syn_timing.rpt
report_utilization -file $REPORT_FOLDER/fifo_syn_utilization.rpt
report_power -file $REPORT_FOLDER/fifo_syn_power.rpt

# Run Implementation
launch_runs impl_1 -jobs 4
wait_on_run impl_1 
open_run impl_1

# Output Resource Utilization, Timing Diagram, Power, DRC, Noise
report_timing_summary -file $REPORT_FOLDER/fifo_impl_timing.rpt
report_utilization -file $REPORT_FOLDER/fifo_impl_utilization.rpt
report_power -file $REPORT_FOLDER/fifo_impl_power.rpt
report_drc -file $REPORT_FOLDER/fifo_impl_drc.rpt -ruledecks {default}
report_ssn -file $REPORT_FOLDER/fifo_impl_noise.rpt 

# Generate Bit Stream
# Upload to FPGA board

# Close Simulator
# close_sim -force

# create_peripheral xilinx.com user FIR_AXI_Wrapper 1.0 -dir c:/Projects/FIR_Katim/work/FIRVivado/../ip_repo
# add_peripheral_interface S00_AXIS -interface_mode slave -axi_type stream [ipx::find_open_core xilinx.com:user:FIR_AXI_Wrapper:1.0]
# add_peripheral_interface M00_AXIS -interface_mode master -axi_type stream [ipx::find_open_core xilinx.com:user:FIR_AXI_Wrapper:1.0]
# generate_peripheral -force [ipx::find_open_core xilinx.com:user:FIR_AXI_Wrapper:1.0]
# write_peripheral [ipx::find_open_core xilinx.com:user:FIR_AXI_Wrapper:1.0]
# set_property  ip_repo_paths  {c:/Projects/FIR_Katim/work/FIRVivado/../ip_repo/FIR_AXI_Wrapper_1_0 c:/Projects/FIR_Katim/work/ip_repo/myip2_1_0 c:/Projects/FIR_Katim/work/ip_repo/myip_1_0} [current_project]
# update_ip_catalog -rebuild
# ipx::edit_ip_in_project -upgrade true -name edit_FIR_AXI_Wrapper_v1_0 -directory c:/Projects/FIR_Katim/work/FIRVivado/../ip_repo c:/Projects/FIR_Katim/work/ip_repo/FIR_AXI_Wrapper_1_0/component.xml

