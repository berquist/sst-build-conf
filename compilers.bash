#!/bin/bash

set -euo pipefail

source_compilers_nompi() {
    local toolchain="${1}"

    case "${toolchain}" in
        clang)
            export CC=$(command -v clang)
            export CXX=$(command -v clang++)
            ;;
        gnu)
            export CC=$(command -v gcc)
            export CXX=$(command -v g++)
            ;;
        *)
            exit 1
            ;;
    esac
}

source_compilers_mpi() {
    local toolchain="${1}"

    local ompi_version="4.1.5"
    local ompi_loc
    case "${toolchain}" in
        clang)
            export CC=$(command -v clang)
            export CXX=$(command -v clang++)
            ompi_loc="$(spack location -i openmpi@${ompi_version} ~internal-pmix %apple-clang@14.0.3)"
            ;;
        gnu)
            export CC=$(command -v gcc)
            export CXX=$(command -v g++)
            ompi_loc="$(spack location -i openmpi@${ompi_version} %gcc)"
            ;;
        *)
            exit 1
            ;;
    esac
    export MPICC="${ompi_loc}"/bin/mpicc
    export MPICXX="${ompi_loc}"/bin/mpicxx
    export CPPFLAGS="-I${ompi_loc}/include"
}
