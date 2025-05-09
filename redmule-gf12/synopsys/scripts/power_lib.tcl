# Copyright (c) 2019 ETH Zurich
# Matheus Cavalcante <matheusd@iis.ee.ethz.ch>

# A library of useful functions for Synopsys Design Compiler.

set ROOT [file normalize [file join [file dirname [info script]] ../..]]
# set SYNDIR  [file normalize [file join $ROOT gf12/synopsys]]
# set SRCDIR  [file normalize [file join $ROOT gf12/sourcecode]]
set BEDIR [file normalize [file join $ROOT synopsys]]
# set TECHDIR [file normalize [file join $ROOT gf12/technology]]
# set PDK     /usr/pack/gf-12-kgf/gf/pdk-12LPPLUS-V1.0_1.3/PlaceRoute/ICC

set disable_multicore_resource_checks true

set_host_options -max_cores 4

suppress_message LINT-1
suppress_message LINT-2
suppress_message LINT-3
suppress_message LINT-28
suppress_message LINT-29
suppress_message LINT-31
suppress_message LINT-32
suppress_message LINT-33
suppress_message LINT-52
suppress_message LINT-54
suppress_message UCN-1
suppress_message VER-61
suppress_message TIM-179

set suppress_errors [list PSYN-115]

proc pause {{message "Hit Enter to continue ==> "}} {
  puts -nonewline $message
  flush stdout
  gets stdin
}

# Create folders
exec mkdir -p netlists
exec mkdir -p DDC