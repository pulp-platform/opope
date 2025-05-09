# ---------------------------------------
# Synthesis script for the sample design
# ---------------------------------------
remove_design -design
set reports  "reports"
set out      "out"
set DESIGN   "redmule_complex"
# Corner options are ffpg, sspg, tt
set corner   "sspg"
# Voltage otions are: 0p495, 0p585, 0p63, 0p72, 0p81
set voltage  "0p495"
# Temperature options are: 125, m40, m55
set temp     "m40"
# Time units are in ns for GF12
set CLK_PERIOD {1}
set REPORTS  "${reports}/${DESIGN}_${corner}_${voltage}v_${temp}c_${CLK_PERIOD}ns"
set OUT      "${out}/${DESIGN}_${corner}_${voltage}v_${temp}c_${CLK_PERIOD}ns"

# Just for reference, the area of an AND cell (AND2_X1N_A7P5PP84TL_C14) is 0.2016 um^2

# Clean and recreate reports folder
sh rm -rf   ${REPORTS}
sh mkdir -p ${REPORTS}

#-------------------------------------------------------------------------------
# Define libraries
#-------------------------------------------------------------------------------
global link_path
global link_library
global target_library
set target_library []

# Synth library
lappend target_library sc7p5mcpp84_12lpplus_base_lvt_c14_${corner}_sigcmax_max_${voltage}v_${temp}c.db
# Driving cells library
lappend target_library sc7p5mcpp84_12lpplus_base_lvt_c14_tt_nominal_max_0p80v_25c.db

set link_library [concat "*" $target_library]
set link_path [concat "*" $target_library]

# ------------------------------------------------------------------------------
# Analyze Design
# ------------------------------------------------------------------------------ 
source -echo -verbose ../../scripts/synth_compile.tcl > ${REPORTS}/01_analyze_${DESIGN}.rpt

# ------------------------------------------------------------------------------
# Elaborate Design
# ------------------------------------------------------------------------------
elaborate ${DESIGN}_wrap > ${REPORTS}/02_elaborate_${DESIGN}.rpt

#-------------------------------------------------------------------------------
# Timing loop check
#------------------------------------------------------------------------------
report_timing -loop > ${REPORTS}/03_timing_loop_${DESIGN}.rpt

# To link together all the listed files
link > ${REPORTS}/04_link_${DESIGN}.rpt

# ------------------------------------------------------------------------------
# Define Constraints
# ------------------------------------------------------------------------------
create_clock clk_i -period ${CLK_PERIOD}
set_clock_uncertainty 0.1 [all_clocks]
set_dont_touch_network [all_clocks]

set RST rst_ni
remove_driving_cell $RST
set_drive 0 $RST
set_dont_touch_network $RST

# Defining divers and loaders
# We use a regular buffer that is meant to drive all inputs with its output (Y)
# and is used to load all output with its input. For the load, we use the
# maximum equivalent input capacitance. All info about pins and driving cells
# is available under technology/lib/${driving_library}.lib.gz
set DRIVE_CELL BUFH_X10N_A7P5PP84TL_C14
set DRIVE_PIN Y
# Capacitances are in pF
set LOAD_PIN 0.00446609

set_input_delay -clock clk_i  0.1 [all_inputs]
set_output_delay -clock clk_i 0.1 [all_outputs]
set_driving_cell [all_inputs] -lib_cell $DRIVE_CELL -pin ${DRIVE_PIN} -no_design_rule
set_load -pin_load ${LOAD_PIN} [all_outputs]

#-------------------------------------------------------------------------------
# FPNEW retiming
#------------------------------------------------------------------------------
set_optimize_registers true -designs "fpnew_*"

# ------------------------------------------------------------------------------
# Compile Design
# ------------------------------------------------------------------------------
compile_ultra -no_autoungroup -gate_clock > ${REPORTS}/05_compile_${DESIGN}.rpt

# ------------------------------------------------------------------------------
# Generate Reports
# ------------------------------------------------------------------------------
sh rm -rf   ${OUT}
sh mkdir -p ${OUT}

report_timing              > ${OUT}/final_timing.rpt
report_area     -hierarchy > ${OUT}/final_area.rpt
report_register -nosplit   > ${OUT}/final_registers.rpt
check_design               > ${OUT}/final_check_design.rpt
report_design              > ${OUT}/final_report_design.rpt

# ------------------------------------------------------------------------------
# Write Out Data
# ------------------------------------------------------------------------------
# Change names for Verilog.
change_names -rule verilog -hierarchy

#-------------------------------------------------------------------------------
# Write Verilog netlist.
#-------------------------------------------------------------------------------
write -hierarchy -format verilog -output ${OUT}/netlist_${DESIGN}.v
