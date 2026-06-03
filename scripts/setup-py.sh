# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE_SW for details.
# SPDX-License-Identifier: Apache-2.0
#
# Danilo Cammarata <dcammarata@iis.ee.ethz.ch>
#
#!/bin/bash

export PYTHON=python3

# For CI: install directly to user site packages (persists across jobs)
# This avoids venv path issues entirely
pip3 install --user --upgrade pip
pip3 install --user numpy torch

# For local development, you can still use venv
if [ -n "$CI" ]; then
    echo "Running in CI - installed packages to user site"
else
    # Local development: use venv
    export PENV=$(pwd)/golden-model/venv
    $PYTHON -m venv $PENV
    source $PENV/bin/activate
    $PYTHON -m pip install --no-cache-dir --upgrade pip setuptools wheel
    $PYTHON -m pip install --no-cache-dir numpy torch
    deactivate
fi