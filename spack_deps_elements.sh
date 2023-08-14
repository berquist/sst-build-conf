#!/bin/bash

# limitations:
#   - can't specify versions of dependencies: you must only have one visible of each to Spack

# include_goblin="$(spack location -i 'goblin-hmc-sim')/include"
if [[ "$(spack location -i 'intel-pin')" ]]; then
    include_pin="$(spack location -i 'intel-pin')/source/include/pin"
    include_pin="-I${include_pin}"
else
    include_pin=""
fi

# https://stackoverflow.com/a/7832158/
cppflags="${CPPFLAGS:-}"
CPPFLAGS="${cppflags} ${include_pin}"
export CPPFLAGS
