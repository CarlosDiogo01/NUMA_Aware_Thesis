#PBS -N SOR_NUMA_9tests_Java_Flags_And_NUMACTL_TimeTest
#PBS -l walltime=20:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE



############ Information about algorithm to run ################
alg="SOR"
exe="$HOME/NUMA_Aware_Thesis/java_codes/jar/SOR_Improved_sm.jar"
################################################################




########################## Tests configuration ###############################
dataset="1 2 3 4 5"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=10
index_val_to_collect=5
Project_Folder="$HOME/NUMA_Aware_Thesis/java_codes/jar/${alg}_TimeTest_$node_info"
TIMES_ALL_TESTS_PER_SIZE="TIMES_${alg}_ALL_TESTS_PER_SIZE"
##############################################################################




################## External LIBS and Tools Configuration #####################
# Java Dir 
JAVA8="/share/apps/java/jdk1.8.0_20/bin/java"
#############################################################################




############################### Tests ######################################
test1="Default"
test2="UseNUMA_and_UseParallelGC"
test3="numactl_interleave_all_only" 
test4="UseNUMA_UseParallelGC_and_numactl_interleave_all"
test5="numactl_cpubind_0_1_and_membind_0"
test6="numactl_cpubind_0_1_membind_0_and_JAVA_NUMA_FLAGS"
test7="UseNUMAInterleaving"
test8="UseAdaptiveNUMAChunkSizing"
test9="NUMAStats"
############################################################################






#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_$size","$test1","$test2","$test3","$test4","$test5","$test6","$test7","$test8","$test9" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_test1=`cat "$test1/Size_$size/times.${alg}_$test1.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test2=`cat "$test2/Size_$size/times.${alg}_$test2.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test3=`cat "$test3/Size_$size/times.${alg}_$test3.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`	
		median_test4=`cat "$test4/Size_$size/times.${alg}_$test4.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test5=`cat "$test5/Size_$size/times.${alg}_$test5.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test6=`cat "$test6/Size_$size/times.${alg}_$test6.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test7=`cat "$test7/Size_$size/times.${alg}_$test7.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test8=`cat "$test8/Size_$size/times.${alg}_$test8.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test9=`cat "$test9/Size_$size/times.${alg}_$test9.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","$median_test1","$median_test2","$median_test3","$median_test4","$median_test5","$median_test6","$median_test7","$median_test8","$median_test9" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	done
done
