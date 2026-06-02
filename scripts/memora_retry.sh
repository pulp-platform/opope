# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE_SW for details.
# SPDX-License-Identifier: Apache-2.0
#
# Danilo Cammarata <dcammarata@iis.ee.ethz.ch>
#

i=1
max_attempts=10
while ! memora --ignore-uncommitted-changes "$@"; do
  echo "Attempt $i/$max_attempts of 'memora $@' failed."
  if test $i -ge $max_attempts; then
    echo "'memora $@' keeps failing; aborting!"
    exit 1
  fi
  i=$(($i+1))
done