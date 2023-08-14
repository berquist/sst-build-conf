#!/bin/bash

set -euo pipefail

if [[ $(uname) == "Darwin" ]]; then
    export CC=/usr/bin/clang
    export CXX=/usr/bin/clang++
else
    export CC=/usr/bin/gcc
    export CXX=/usr/bin/g++
fi
