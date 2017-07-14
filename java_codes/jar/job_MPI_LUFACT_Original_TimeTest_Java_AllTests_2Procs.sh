#PBS -N LUFACT_MPI_Original_AllTests_2procs_TimeTest
#PBS -l walltime=20:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=compute-641-4:ppn=32:r641


# Machine USED
read -r node_info<$PBS_NODEFILE



############ Information about algorithm to run ################
alg="LUFACT_MPI_Original"
exe="$HOME/NUMA_Aware_Thesis/java_codes/jar/lufact_jgf_dm_improved.jar"
################################################################


#Number of MPI processes
nprocs=2
nprocs_per_socket=1


########################## Tests configuration ###############################
dataset="1 2 3 4 5"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=6
index_val_to_collect=3
Project_Folder="$HOME/NUMA_Aware_Thesis/java_codes/jar/${alg}_TimeTest_${nprocs}_nprocs__$node_info"
TIMES_ALL_TESTS_PER_SIZE="TIMES_${alg}_ALL_TESTS_PER_SIZE"
##############################################################################




################## External LIBS and Tools Configuration #####################
module load gnu/5.3.0
module load gnu/openmpi_eth/1.8.4

# Java Dir 
JAVA8="/share/apps/java/jdk1.8.0_20/bin/java"
#############################################################################




############################### Tests ######################################
test1="Default"
test2="UseNUMA_and_UseParallelGC"
test3="numactl_interleave_all_only" 
test4="UseNUMA_and_numactl_interleave_all"
#test5="cpubind=0,1_inteleave_between_CPU0_and_CPU1)_and_membind=0"
test6="numactl_cpubind_0_1_membind_0_and_JAVA_NUMA_FLAGS"
############################################################################


# Go to Project Folder
mkdir $Project_Folder
cd $Project_Folder


# test1 -> Default
mkdir $test1
for size in $dataset
do
	mkdir "$test1/Size_$size"
        for thr in $thread_bundle
        do
                echo "<ignore> thr = $thr"
		csv="times.${alg}_$test1.$size.size.$thr.thr.csv" 
                for ((i = 0; i < $REP; i++))
                do
                        # Default execution
			result=`mpirun -np $nprocs --map-by socket:PE=8 $JAVA8 -jar $exe -v $size $thr | grep Time | awk -F: '{print $2}'`
			echo $result >> "$test1/Size_$size/$csv"
		done
               sort -t, -nk1 -o "$test1/Size_$size/$csv" "$test1/Size_$size/$csv"
	done
done



# test2 -> Using -XX:+UseNUMA flags
mkdir $test2
for size in $dataset
do
        mkdir "$test2/Size_$size"
        for thr in $thread_bundle
       do
                echo "<ignore> thr = $thr" 
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
		for ((i = 0; i < $REP; i++))
                do
                        #Using -XX:+UseNUMA -XX:+UseParallelGC flags
			result=`mpirun -np $nprocs --map-by socket:PE=8 $JAVA8 -XX:+UseNUMA -jar $exe -v $size $thr | grep Time | awk -F: '{print $2}'`
                        echo $result >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done
done


# test3 -> numactl --interleave=all ONLY
mkdir $test3
for size in $dataset
do
        mkdir "$test3/Size_$size"
        for thr in $thread_bundle
        do
                echo "<ignore> thr = $thr" 
		csv="times.${alg}_$test3.$size.size.$thr.thr.csv"
               for ((i = 0; i < $REP; i++))
                do
			#Using numactl interleave all nodes
			result=`mpirun -np $nprocs --map-by socket:PE=8 numactl --interleave=all $JAVA8 -jar $exe -v $size $thr | grep Time | awk -F: '{print $2}'`
			echo $result >> "$test3/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv" 
        done
done



# test4 -> -XX:+UseNUMA AND numactl --interleave=all
mkdir $test4
for size in $dataset
do
        mkdir "$test4/Size_$size"
        for thr in $thread_bundle
        do
                echo "<ignore> thr = $thr"
		csv="times.${alg}_$test4.$size.size.$thr.thr.csv" 
                for ((i = 0; i < $REP; i++))
                do
			#Using -XX:+UseNUMA -XX:UseParallelGC + numactl --interleave all
			result=`mpirun -np $nprocs --map-by socket:PE=8 numactl --interleave=all $JAVA8 -XX:+UseNUMA -jar $exe -v $size $thr | grep Time | awk -F: '{print $2}'`
                        echo $result >> "$test4/Size_$size/$csv"
		done
		sort -t, -nk1 -o "$test4/Size_$size/$csv" "$test4/Size_$size/$csv"
        done
done



#test5 -> cpubind=0,1 (inteleave between CPU0 and CPU1) and membind=0 <- excluido dos testes escolhidos por ter menor performance
#mkdir $test5
#for size in $dataset
#do                      
#        mkdir "$test5/Size_$size"
#        for thr in $thread_bundle
#        do
#                echo "<ignore> thr = $thr" 
#		csv="times.${alg}_$test5.$size.size.$thr.thr.csv"
#                for ((i = 0; i < $REP; i++))
#                do
#			# cpubind=0,1 (inteleave between CPU0 and CPU1) and membind=0
#			result=`mpirun -np $nprocs --npersocket $nprocs_per_socket numactl --cpunodebind=0,1 --membind=0 $JAVA8 -jar $exe -v $size $thr | grep Time | awk -F: '{print $2}'`
#                        echo $result >> "$test5/Size_$size/$csv"
#		done
#		sort -t, -nk1 -o "$test5/Size_$size/$csv" "$test5/Size_$size/$csv"
#        done
#done


# test6 -> cpubind=0,1 (inteleave between CPU0 and CPU1) and membind=0 + JAVA NUMA Flags
mkdir $test6
for size in $dataset
do
        mkdir "$test6/Size_$size"
        for thr in $thread_bundle
        do
                echo "<ignore> thr = $thr" 
		csv="times.${alg}_$test6.$size.size.$thr.thr.csv"
                for ((i = 0; i < $REP; i++))
                do      
			#cpubind=0,1 (interlieve between CPU0 and CPU1) + JAVA NUMA Flags
			numactl --cpubind=0,1 --membind=0 $JAVA8 -jar -XX:+UseNUMA $exe -5 $size $thr >> "$test6/Size_$size/$csv"
		done
		sort -t, -nk1 -o "$test6/Size_$size/$csv" "$test6/Size_$size/$csv"
       done
done



#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_${size}_${nprocs}_procs","$test1","$test2","$test3","$test4",$test6"" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_test1=`cat "$test1/Size_$size/times.${alg}_$test1.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test2=`cat "$test2/Size_$size/times.${alg}_$test2.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test3=`cat "$test3/Size_$size/times.${alg}_$test3.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`	
		median_test4=`cat "$test4/Size_$size/times.${alg}_$test4.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		# median_test5=`cat "$test5/Size_$size/times.${alg}_$test5.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test6=`cat "$test6/Size_$size/times.${alg}_$test6.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","$median_test1","$median_test2","$median_test3","$median_test4","$median_test6">> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	done
done
