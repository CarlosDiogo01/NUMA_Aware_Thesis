#!/bin/sh

#PBS -N job_SOR_NUMA_BindingWorkload_numactl
#PBS -l walltime=04:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com
#PBS -l nodes=1:r641:ppn=32


read -r node_info<$PBS_NODEFILE
echo "Allocated computing node: $node_info"


exe="SOR_Improved_sm.jar"
FLAGS="-jar"
size="5"
REP="5"
JAVA8="/share/apps/java/jdk1.8.0_20/bin/java"


#Creating ResultsFolder
cd ~/NUMA_Aware_Thesis/java_codes/jar
RESULTFOLDER="SOR_NUMA_BindingWorkload_numactl_$node_info"
mkdir "$RESULTFOLDER"
mkdir "$RESULTFOLDER/NUMA_Node_Info_$node_info/"

#Generate an image and ASCI txt with NUMA Architecture of the Allocated Node
lstopo --output-format txt -v --no-io > "lstopo_NUMA_ARCH_$node_info.txt"
lstopo --output-format png -v --no-io > "lstopo_NUMA_ARCH_$node_info.png"
mv lstopo_NUMA_ARCH_* "$RESULTFOLDER/NUMA_Node_Info_$node_info/"

#Generate info about NUMA Node Used Core Numbering And Memory
numactl --hardware >> "$RESULTFOLDER/NUMA_Node_Info_$node_info/numactl_hardware_$node_info.txt"

# Running tests
mkdir "$RESULTFOLDER/Size_$size"
for thr in 1 2 4 8 16 24 32
do
	mkdir "$RESULTFOLDER/Size_$size/$thr.threads/"
	echo "<ignore> thr = $thr" 
	for ((i = 0; i < $REP; i++))
	do
		#NO BINDING AT ALL
		$JAVA8 $FLAGS $exe -5 $size $thr >> "times.NO_BINDING_WORKLOAD_$size.size.$thr.thr.txt"

		#BINDING ON LOCAL NUMA Node (Node 0) ONLY and ALLOCATE MEMORY on the SAME NUMA Node
		numactl --cpubind=0 --membind=0 $JAVA8 $FLAGS $exe -5 $size $thr >> "times.numactl_LOCAL_BINDING_NODE0_$size.size.$thr.thr.txt"

		#BINDING ON LOCAL NUMA Node (Node 0) ONLY and ALLOCATE MEMORY on NUMA Node 0 and 1
		numactl --cpubind=0 --membind=0,1 $JAVA8 $FLAGS $exe -5 $size $thr >> "times.numactl_NODE0_MEM_0-1_$size.size.$thr.thr.txt"

		#Using interlieve mode to distributing an applications memory allocation across multiple NUMA nodes. 
		#This might be useful for applications whose total memory requirements are larger than a total memory in a single NUMA node
		numactl --interleave=all $JAVA8 $FLAGS $exe -5 $size $thr >> "times.numactl_INTERLIEVE_ALL_NODES_$size.size.$thr.thr.txt"	
	done
	mv *.txt "$RESULTFOLDER/Size_$size/$thr.threads/"
done
