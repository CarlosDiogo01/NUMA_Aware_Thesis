#!/bin/sh

#PBS -N job_AllScriptsNUMA
#PBS -l walltime=08:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com
#PBS -l nodes=1:r641:ppn=32

read -r node_info<$PBS_NODEFILE

echo "Allocated computing node: $node_info"

cd ~/NUMA_Aware_Thesis/java_codes/jar

#Generate an image and ASCI txt with NUMA Architecture of the Allocated Node
lstopo --output-format txt -v --no-io > "lstopo_NUMA_ARCH_$node_info.txt"
lstopo --output-format png -v --no-io > "lstopo_NUMA_ARCH_$node_info.png"

sh 1_run_test_without_UseNUMA.sh
sh 1_run_test_with_UseNUMA.sh
sh 2_organize_withoutUseNUMA_withUseNUMA.sh
sh 3_Get_Median_Times_each_size.sh 
