# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE_SW for details.
# SPDX-License-Identifier: Apache-2.0
#
# Danilo Cammarata <dcammarata@iis.ee.ethz.ch>
#

export PYTHON=python3
export PENV=$(pwd)/golden-model/venv
$PYTHON -m venv $PENV
source $PENV/bin/activate
$PYTHON -m ensurepip --upgrade
$PYTHON -m pip install --no-cache-dir --upgrade pip setuptools wheel
$PYTHON -m pip install --no-cache-dir numpy torch
deactivate
