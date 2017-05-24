############ Information about algorithm to run ################
alg="SOR"
jar_path="$HOME/NUMA_Aware_Thesis/java_codes/jar"
exe1="SOR_Improved_sm.jar"
exe2="SOR_AJ_SM.jar"

packexes="$exe2 $exe1"
################################################################


########################## Tests configuration ###############################
dataset="5"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=4
##############################################################################


################## External LIBS and Tools Configuration #####################
# Java Dir 
JAVA8="/share/apps/java/jdk1.8.0_20/bin/java"
#############################################################################



############################### Tests ######################################
#test1="Default"
#test2="UseNUMA_and_UseParallelGC"
#test3="numactl_interleave_all_only" 
test4="UseNUMA_UseParallelGC_and_numactl_interleave_all"
#test5="numactl_cpubind_0_1_and_membind_0"
#test6="numactl_cpubind_0_1_membind_0_and_JAVA_NUMA_FLAGS"
# test7="UseNUMAInterleaving"
############################################################################


for exe in $packexes
do
	echo " "
	echo "Running $exe ........."	

#	# test1 -> Default
#	echo "Test: $test1"
#	for size in $dataset
#	do
#		echo -e "\t Size = $size"
#		for thr in $thread_bundle
#		do
#			echo -e "\t\tThreads = $thr"
#			for ((i = 0; i < $REP; i++))
#			do
#				res=`$JAVA8 -jar $jar_path/$exe -5 $size $thr`
#				echo -e "\t\t$res"
#			done
#		done
#		echo " "
#	done

	# test2 -> Using -XX:+UseNUMA -XX:+UseParallelGC flags
#	echo "Test: $test2"
#	for size in $dataset
#	do
#		echo -e "\t Size = $size"
#		for thr in $thread_bundle
#		do
#			echo -e "\t\tThreads = $thr"
#			for ((i = 0; i < $REP; i++))
#			do
#				res=`$JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC $jar_path/$exe -5 $size $thr`
#				echo -e "\t\t$res"
#			done
#		done
#		echo " "
#	done

	# test3 -> numactl --interleave=all ONLY
#	echo "Test: $test3"
#	for size in $dataset
#	do
#		echo -e "\t Size = $size"
#		for thr in $thread_bundle
#		do
#			echo -e "\t\tThreads = $thr"
#			for ((i = 0; i < $REP; i++))
#			do
#				res=`numactl --interleave=all $JAVA8 -jar $jar_path/$exe -5 $size $thr`
#				echo -e "\t\t$res"
#			done
#		done
#		echo " "
#	done
#
	# test4 -> -XX:+UseNUMA -XX:UseParallelGC AND numactl --interleave=all
	echo "Test: $test4"
	for size in $dataset
	do
		echo -e "\t Size = $size"
		for thr in $thread_bundle
		do
			echo -e "\t\tThreads = $thr"
			for ((i = 0; i < $REP; i++))
			do
				res=`numactl --interleave=all $JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC $jar_path/$exe -5 $size $thr`
				echo -e "\t\t$res"
			done
		done
		echo " "
	done


#	# test5 -> cpubind=0,1 (inteleave between CPU0 and CPU1) and membind=0
#	mkdir $test5
#	for size in $dataset
#	do                      
#		mkdir "$test5/Size_$size"
#		for thr in $thread_bundle
#		do
#			echo "<ignore> thr = $thr" 
#			csv="times.${alg}_$test5.$size.size.$thr.thr.csv"
#			for ((i = 0; i < $REP; i++))
#			do
#				# cpubind=0,1 (inteleave between CPU0 and CPU1) and membind=0
#				numactl --cpubind=0,1 --membind=0 $JAVA8 -jar $jar_path/$exe -5 $size $thr >> "$test5/Size_$size/$csv"
#			done
#			sort -t, -nk1 -o "$test5/Size_$size/$csv" "$test5/Size_$size/$csv"
#		done
#	done
#
#
#	# test6 -> cpubind=0,1 (inteleave between CPU0 and CPU1) and membind=0 + JAVA NUMA Flags
#	mkdir $test6
#	for size in $dataset
#	do
#		mkdir "$test6/Size_$size"
#		for thr in $thread_bundle
#		do
#			echo "<ignore> thr = $thr" 
#			csv="times.${alg}_$test6.$size.size.$thr.thr.csv"
#			for ((i = 0; i < $REP; i++))
#			do      
#				#cpubind=0,1 (interlieve between CPU0 and CPU1) + JAVA NUMA Flags
#				numactl --cpubind=0,1 --membind=0 $JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC $jar_path/$exe -5 $size $thr >> "$test6/Size_$size/$csv"
#			done
#			sort -t, -nk1 -o "$test6/Size_$size/$csv" "$test6/Size_$size/$csv"
#		done
#	done
#
#
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
done
