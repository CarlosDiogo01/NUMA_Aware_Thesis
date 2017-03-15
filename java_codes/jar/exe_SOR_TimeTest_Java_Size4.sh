# Machine USED
node_info="compute-641-17"




############ Information about algorithm to run ################
alg="SOR"
exe="$HOME/NUMA_Aware_Thesis/java_codes/jar/SOR_Improved_sm.jar"
################################################################




########################## Tests configuration ###############################
dataset="4"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=10
index_val_to_collect=5
Project_Folder="$HOME/NUMA_Aware_Thesis/java_codes/jar/${alg}_TimeTest_Size4_$node_info"
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
test6="numactl_cpubind_0_1_membind_0_and_JAVA_NUMA_FLAGS"
############################################################################





# Go to Project Folder
mkdir $Project_Folder
cd $Project_Folder


#Default
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
                        $JAVA8 -jar $exe -5 $size $thr >> "$test1/Size_$size/$csv"
		done
                sort -t, -nk1 -o "$test1/Size_$size/$csv" "$test1/Size_$size/$csv"
	done
done



#Using -XX:+UseNUMA -XX:+UseParallelGC flags
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
                        $JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC $exe -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done
done


#numactl --interleave=all ONLY
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
                       	numactl --interleave=all $JAVA8 -jar $exe -5 $size $thr >> "$test3/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv" 
        done
done



#-XX:+UseNUMA -XX:UseParallelGC AND numactl --interleave=all
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
                        numactl --interleave=all $JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC $exe -5 $size $thr >> "$test4/Size_$size/$csv"
		done
		sort -t, -nk1 -o "$test4/Size_$size/$csv" "$test4/Size_$size/$csv"
        done
done




# cpubind=0,1 (inteleave between CPU0 and CPU1) and membind=0 + JAVA NUMA Flags
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
			numactl --cpubind=0,1 --membind=0 $JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC $exe -5 $size $thr >> "$test6/Size_$size/$csv"
		done
		sort -t, -nk1 -o "$test6/Size_$size/$csv" "$test6/Size_$size/$csv"
        done
done


#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_$size","$test1","$test2","$test3","$test4","$test6" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_test1=`cat "$test1/Size_$size/times.${alg}_$test1.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test2=`cat "$test2/Size_$size/times.${alg}_$test2.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test3=`cat "$test3/Size_$size/times.${alg}_$test3.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`	
		median_test4=`cat "$test4/Size_$size/times.${alg}_$test4.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test6=`cat "$test6/Size_$size/times.${alg}_$test6.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","$median_test1","$median_test2","$median_test3","$median_test4","$median_test6" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	done
done
