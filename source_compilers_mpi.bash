#!/bin/bash

set -euo pipefail

ompi_version="4.1.5"
if [[ $(uname) == "Darwin" ]]; then
    export CC=/usr/bin/clang
    export CXX=/usr/bin/clang++
    ompi_loc="$(spack location -i openmpi@${ompi_version} ~internal-pmix %apple-clang@14.0.3)"
else
    export CC=/usr/bin/gcc
    export CXX=/usr/bin/g++
    ompi_loc="$(spack location -i openmpi@${ompi_version} %gcc)"
fi
export MPICC="${ompi_loc}"/bin/mpicc
export MPICXX="${ompi_loc}"/bin/mpicxx
export CPPFLAGS="-I${ompi_loc}/include"
