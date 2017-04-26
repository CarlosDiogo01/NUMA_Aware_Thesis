# Machine USED
node_info="KNL-002-1-Config-2-1"


############ Information about algorithm to run ################
alg="SOR_C_1Alloc_ICC"
exe2="$HOME/NUMA_Aware_Thesis/c_src/exes/KNL_exes/sor_sm_improvment_KNL_1Alloc_icc17"
exe4="$HOME/NUMA_Aware_Thesis/c_src/exes/KNL_exes/sor_sm_improvment_KNL_1Alloc_proc_bind_spread"
exe5="$HOME/NUMA_Aware_Thesis/c_src/exes/KNL_exes/sor_sm_improvment_KNL_1Alloc_proc_bind_close"
################################################################


########################## Tests configuration ###############################
dataset="1 2 3 4 5"
thread_bundle="1 2 4 8 10 12 16 24 32 64 128 256 512"
REP=16
index_val_to_collect=8
Project_Folder="$HOME/NUMA_Aware_Thesis/c_src/${alg}_TimeTest_$node_info"
TIMES_ALL_TESTS_PER_SIZE="TIMES_${alg}_ALL_TESTS_PER_SIZE"
##############################################################################



############################### Tests ######################################
# Exe compiled with ICC 17
test3="KMP_AFFINITY_compact"
test4="KMP_AFFINITY_scatter"
test6="omp_proc_bind_spread"
test7="omp_proc_bind_close"
############################################################################


# Go to Project Folder
mkdir $Project_Folder
cd $Project_Folder


#################### Loading ICC 17 to run intel exe tests ##################
# ICC 17
source /opt/intel/compilers_and_libraries/linux/bin/compilervars.sh intel64

#Vtune
source /opt/intel/vtune_amplifier_xe/amplxe-vars.sh
##############################################################################



#test3 -> KMP_AFFINITY_compact
mkdir $test3
for size in $dataset
do
        mkdir "$test3/Size_$size"
	echo "Test3 - KMP_AFFINITY Compact"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test3.$size.size.$thr.thr.csv"
		export KMP_AFFINITY=compact
                for ((i = 0; i < $REP; i++))
                do
			$exe2 -5 $size $thr >> "$test3/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
        done
done


#test4 -> KMP_AFFINITY_scatter
mkdir $test4
for size in $dataset
do
        mkdir "$test4/Size_$size"
	echo "Test4 - KMP_AFFINITY Scatter"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test4.$size.size.$thr.thr.csv"
		export KMP_AFFINITY=verbose,scatter
                for ((i = 0; i < $REP; i++))
                do
			$exe2 -5 $size $thr >> "$test4/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test4/Size_$size/$csv" "$test4/Size_$size/$csv"
        done
done


#test6 -> OMP_PROC_BIND=spread 
mkdir $test6
for size in $dataset
do
        mkdir "$test6/Size_$size"
        echo "Test6 - OMP_PROC_BIND=spread"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test6.$size.size.$thr.thr.csv"
                for ((i = 0; i < $REP; i++))
                do
                        $exe4 -5 $size $thr >> "$test6/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test6/Size_$size/$csv" "$test6/Size_$size/$csv"
        done
done


#test7 -> OMP_PROC_BIND=close
mkdir $test7
for size in $dataset
do
        mkdir "$test7/Size_$size"
        echo "Test7 - OMP_PROC_BIND=close"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test7.$size.size.$thr.thr.csv"
                for ((i = 0; i < $REP; i++))
                do
                        $exe5 -5 $size $thr >> "$test7/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test7/Size_$size/$csv" "$test7/Size_$size/$csv"
        done
done


#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_$size","$test3","$test4","$test6","$test7" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_test3=`cat "$test3/Size_$size/times.${alg}_$test3.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test4=`cat "$test4/Size_$size/times.${alg}_$test4.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test6=`cat "$test6/Size_$size/times.${alg}_$test6.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test7=`cat "$test7/Size_$size/times.${alg}_$test7.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","${median_test3}","${median_test4}","${median_test6}","${median_test7}" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	done
done
