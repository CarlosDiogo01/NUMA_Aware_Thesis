#PBS -N SOR_FirstTouch_V1_Time_MasterOnly_MasterAndAllocation_AllTests_Java
#PBS -l walltime=80:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE



############ Information about algorithm to run ############################################
alg="SOR_FirstTouch_V1_Master_plus_MasterAndAllocation_Tests"
dirjar="$HOME/NUMA_Aware_Thesis/java_codes/jar"
exe1="sor_FirstTouch_corrected_V1_alloc_e_master.jar"
exe2="sor_FirstTouch_corrected_V1_master.jar"
############################################################################################



########################## Tests configuration ###############################
pack_exes="$exe1 $exe2"
dataset="1 2 3 4 5"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=20
index_val_to_collect=10
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
# test7="UseNUMAInterleaving"
############################################################################





# Go to Project Folder
mkdir $Project_Folder
cd $Project_Folder

for exe in $pack_exes
do
	mkdir $exe
	cd $exe
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
				$JAVA8 -jar $dirjar/$exe -5 $size $thr >> "$test1/Size_$size/$csv"
			done
			sort -t, -nk1 -o "$test1/Size_$size/$csv" "$test1/Size_$size/$csv"
		done
	done



	# test2 -> Using -XX:+UseNUMA -XX:+UseParallelGC flags
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
				$JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC $dirjar/$exe -5 $size $thr >> "$test2/Size_$size/$csv"
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
				numactl --interleave=all $JAVA8 -jar $dirjar/$exe -5 $size $thr >> "$test3/Size_$size/$csv"
			done
			sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv" 
		done
	done



	# test4 -> -XX:+UseNUMA -XX:UseParallelGC AND numactl --interleave=all
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
				numactl --interleave=all $JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC $dirjar/$exe -5 $size $thr >> "$test4/Size_$size/$csv"
			done
			sort -t, -nk1 -o "$test4/Size_$size/$csv" "$test4/Size_$size/$csv"
		done
	done



	# test5 -> cpubind=0,1 (inteleave between CPU0 and CPU1) and membind=0
	mkdir $test5
	for size in $dataset
	do                      
		mkdir "$test5/Size_$size"
		for thr in $thread_bundle
		do
			echo "<ignore> thr = $thr" 
			csv="times.${alg}_$test5.$size.size.$thr.thr.csv"
			for ((i = 0; i < $REP; i++))
			do
				# cpubind=0,1 (inteleave between CPU0 and CPU1) and membind=0
				numactl --cpubind=0,1 --membind=0 $JAVA8 -jar $dirjar/$exe -5 $size $thr >> "$test5/Size_$size/$csv"
			done
			sort -t, -nk1 -o "$test5/Size_$size/$csv" "$test5/Size_$size/$csv"
		done
	done


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
				numactl --cpubind=0,1 --membind=0 $JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC $dirjar/$exe -5 $size $thr >> "$test6/Size_$size/$csv"
			done
			sort -t, -nk1 -o "$test6/Size_$size/$csv" "$test6/Size_$size/$csv"
		done
	done


	# UseNUMAInterleaving 
	# mkdir $test7
	# for size in $dataset
	# do
	#        mkdir "$test7/Size_$size"
	#        for thr in $thread_bundle
	#        do
	#                echo "<ignore> thr = $thr" 
	#		csv="times.${alg}_$test7.$size.size.$thr.thr.csv"
	#                for ((i = 0; i < $REP; i++))
	#                do      
	#			# UseNUMAInterleaving 
	#			$JAVA8 -XX:+UseNUMAInterleaving -jar $exe -5 $size $thr >> "$test7/Size_$size/$csv"
	#		done
	#		sort -t, -nk1 -o "$test7/Size_$size/$csv" "$test7/Size_$size/$csv"
	#        done
	# done



	#Extract Medians and merge all times for all tests per thread
	mkdir $TIMES_ALL_TESTS_PER_SIZE
	for size in $dataset
	do
		echo "Size_$size","$test1","$test2","$test3","$test4","$test5","$test6" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
		for thr in $thread_bundle
		do
			median_test1=`cat "$test1/Size_$size/times.${alg}_$test1.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
			median_test2=`cat "$test2/Size_$size/times.${alg}_$test2.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
			median_test3=`cat "$test3/Size_$size/times.${alg}_$test3.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`	
			median_test4=`cat "$test4/Size_$size/times.${alg}_$test4.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
			median_test5=`cat "$test5/Size_$size/times.${alg}_$test5.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
			median_test6=`cat "$test6/Size_$size/times.${alg}_$test6.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
			echo "$thr.Threads","$median_test1","$median_test2","$median_test3","$median_test4","$median_test5","$median_test6" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
		done
	done

cd ..
done
