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
set_property file_type {VHDL 2008} [get_files  $SOURCE_FOLDER/fir_v7.vhdl]

set_property top firFilterv7 [current_fileset]

# Add Simulation Sources
set_property SOURCE_SET sources_1 [get_filesets sim_1 ]
add_files -fileset sim_1 -norecurse $TB_FOLDER/fir_fixed_tb.vhdl
set_property file_type {VHDL 2008} [get_files  $TB_FOLDER/fir_fixed_tb.vhdl]

set_property top fir_fixed_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Check Lints
synth_design -top firFilterv7 -part xczu7ev-ffvc1156-2-e -lint 

# Simulation and Waveform generation
launch_simulation

# Add Constraint Files
add_files -fileset constrs_1 -norecurse $CONSTR_FOLDER/fir.xdc
set_property target_constrs_file $CONSTR_FOLDER/fir.xdc [current_fileset -constrset]

# Run Synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1
open_run synth_1 -name netlist_1

#Output Resource Utilization, Timing Diagram, Power
report_timing_summary -file $REPORT_FOLDER/syn_timing.rpt
report_utilization -file $REPORT_FOLDER/syn_utilization.rpt
report_power -file $REPORT_FOLDER/syn_power.rpt

# Run Implementation
launch_runs impl_1 -jobs 4
wait_on_run impl_1 
open_run impl_1

# Output Resource Utilization, Timing Diagram, Power, DRC, Noise
report_timing_summary -file $REPORT_FOLDER/impl_timing.rpt
report_utilization -file $REPORT_FOLDER/impl_utilization.rpt
report_power -file $REPORT_FOLDER/impl_power.rpt
report_drc -file $REPORT_FOLDER/impl_drc.rpt -ruledecks {default}
report_ssn -file $REPORT_FOLDER/impl_noise.rpt 

# Generate Bit Stream
# Upload to FPGA board

# Close Simulator
# close_sim -force

