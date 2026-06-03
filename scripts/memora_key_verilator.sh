# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE_SW for details.
# SPDX-License-Identifier: Apache-2.0
#
# Danilo Cammarata <dcammarata@iis.ee.ethz.ch>
#

# scripts/memora_key_bender.sh
#!/bin/bash
# Key is: verilator + version + host arch
echo "verilator-$(make -s print-VerilatorVersion)-$(uname -m)"