#!/bin/bash

platform=$(uname)
case "${platform}" in
    Linux)
        export DRAMSIM2_DIR=/home/ejberqu/development/forks/personal/DRAMSim2/install/share/DRAMSim2/cmake
        export NVDIMMSIM_DIR=/home/ejberqu/development/forks/personal/NVDIMMSim/install/share/NVDIMMSim/cmake
        ;;
    Darwin)
        export DRAMSIM2_DIR=/Users/ejberqu/development/forks/sst/DRAMSim2/install/share/DRAMSim2/cmake
        export NVDIMMSIM_DIR=/Users/ejberqu/development/forks/sst/NVDIMMSim/install/share/NVDIMMSim/cmake
        ;;
    *)
        exit 1
        ;;
esac
