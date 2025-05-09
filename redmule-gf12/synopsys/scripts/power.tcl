
# Copyright (c) 2023 ETH Zurich
# Matheus Cavalcante <matheusd@ethz.ch>

###################
##  ENVIRONMENT  ##
###################

source [file join [file dirname [info script]] power_lib.tcl]

# Names and constants.
if {![info exists TCP    ]} {set TCP      1.05}
if {![info exists MEMCUTS]} {set MEMCUTS    []}
if {![info exists VCD    ]} {set VCD      none}
if {![info exists NAME   ]} {set NAME     none}

# Use eight CPUs
set_host_options -max_cores 8

# Activate power analysis
set_app_var power_enable_analysis true

# Signal analysis
set si_enable_analysis true

# Report directory
set REPDIR $BEDIR/reports/module_power_${TCP}ns
if {![file exists $REPDIR]} {
    file mkdir $REPDIR
}

# Load standard cells
set pvt [list sc7p5mcpp84_12lpplus_base_lvt_c14_tt_nominal_max_0p80v_25c ]

# # Load memory macros
# foreach cut $MEMCUTS {
#     lappend pvt ${cut}_tt_nominal_0p80v_0p80v_25c
# }

# Set libraries
dz_set_pvt $pvt

##############
##  DESIGN  ##
##############

redirect -tee -file $REPDIR/signoff_setup_${NAME}.log {
    # Search path
    lappend search_path $BEDIR/out

    # Read netlist
    read_verilog $BEDIR/out/ope_sspg_0p495v_125c_1ns_4_reg_multiple_paths/netlist_ope.v
    link_design ope_wrap

    # Read constraints
    source $BEDIR/out/ope_sspg_0p495v_125c_1ns_4_reg_multiple_paths/final_constraints.sdc

    # Read parasitics
    # read_parasitics -keep_capacitive_coupling $BEDIR/out/spatz_cluster_wrapper_${TCK}ns/spatz_cluster_wrapper_parasitics.nominal_25.spef.gz

    # Read VCD
    read_vcd -strip_path /redmule_tb_wrap/i_redmule_tb/i_redmule_wrap/i_redmule_top $BEDIR/../vcd/${VCD}
}

##############
##  REPORT  ##
##############

# Reports
update_timing -full

report_timing -nosplit           > $REPDIR/signoff_timing_${NAME}.rpt
report_power -hierarchy -nosplit > $REPDIR/signoff_power_${NAME}.rpt

# Ciao!
exit
