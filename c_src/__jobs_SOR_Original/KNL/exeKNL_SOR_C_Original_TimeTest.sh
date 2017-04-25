# Machine USED
node_info="KNL-002-1-Config-2-1"


############ Information about algorithm to run ################
alg="SOR_C_Original"
exe1="$HOME/NUMA_Aware_Thesis/c_src/exes/KNL_exes/sor_sm_improvment_KNL_Original_gcc530"
exe2="$HOME/NUMA_Aware_Thesis/c_src/exes/KNL_exes/sor_sm_improvment_KNL_Original_icc17"
exe3="$HOME/NUMA_Aware_Thesis/c_src/exes/KNL_exes/sor_sm_improvment_KNL_Original_icc17_proc_bind_master"
exe4="$HOME/NUMA_Aware_Thesis/c_src/exes/KNL_exes/sor_sm_improvment_KNL_Original_icc17_proc_bind_spread"
exe5="$HOME/NUMA_Aware_Thesis/c_src/exes/KNL_exes/sor_sm_improvment_KNL_Original_icc17_proc_bind_close"
################################################################


########################## Tests configuration ###############################
dataset="1 2 3 4 5"
thread_bundle="1 2 4 8 10 12 16 24 32 64 128 256 512"
REP=16
index_val_to_collect=8
Project_Folder="$HOME/NUMA_Aware_Thesis/c_src/${alg}_TimeTest_$node_info"
TIMES_ALL_TESTS_PER_SIZE="TIMES_${alg}_ALL_TESTS_PER_SIZE"
##############################################################################




################## External LIBS and Tools Configuration #####################

# GCC 5.3.0
export LD_RUN_PATH=$LD_RUN_PATH:/opt/gnu/gcc/5.3.0/lib64:/opt/gnu/gcc/5.3.0/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/gnu/gcc/5.3.0/lib64:/opt/gnu/gcc/5.3.0/lib:/opt/gnu/gmp/5.0.0/lib/:/opt/gnu/mpc/1.0.1/lib/:/opt/gnu/mpfr/3.1.5/lib/
export PATH=/opt/gnu/gcc/5.3.0/bin:$PATH
#############################################################################




############################### Tests ######################################

# Exe compiled with GCC 5.3.0
test1="Default"
test2="numactl_interleave_all_only"

# Exe compiled with ICC 17
test3="KMP_AFFINITY_compact"
test4="KMP_AFFINITY_scatter"
test5="omp_proc_bind_master"
test6="omp_proc_bind_spread"
test7="omp_proc_bind_close"
############################################################################


# Go to Project Folder
mkdir $Project_Folder
cd $Project_Folder


#test1 -> Default
mkdir $test1
for size in $dataset
do
	mkdir "$test1/Size_$size"
	echo "Test1 - Default"
        for thr in $thread_bundle
        do
		csv="times.${alg}_$test1.$size.size.$thr.thr.csv" 
                for ((i = 0; i < $REP; i++))
                do
                        # Default execution
                        $exe1 -5 $size $thr >> "$test1/Size_$size/$csv"
		done
                sort -t, -nk1 -o "$test1/Size_$size/$csv" "$test1/Size_$size/$csv"
	done
done


#test2 -> numactl_interleave_all_only
mkdir $test2
for size in $dataset
do
        mkdir "$test2/Size_$size"
	echo "Test2 - numactl_interleave_all_only"
        for thr in $thread_bundle
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
                for ((i = 0; i < $REP; i++))
                do
                        numactl --interleave=all $exe1 -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done
done


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



#test5 -> OMP_PROC_BIND=master
mkdir $test5
for size in $dataset
do
        mkdir "$test5/Size_$size"
     	echo "Test5 - OMP_PROC_BIND=master"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test5.$size.size.$thr.thr.csv"
                for ((i = 0; i < $REP; i++))
                do
                        $exe3 -5 $size $thr >> "$test5/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test5/Size_$size/$csv" "$test5/Size_$size/$csv"
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
	echo "Size_$size","$test1","$test2","$test3","$test4","$test5","$test6","$test7" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_test1=`cat "$test1/Size_$size/times.${alg}_$test1.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test2=`cat "$test2/Size_$size/times.${alg}_$test2.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test3=`cat "$test3/Size_$size/times.${alg}_$test3.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test4=`cat "$test4/Size_$size/times.${alg}_$test4.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test5=`cat "$test5/Size_$size/times.${alg}_$test5.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test6=`cat "$test6/Size_$size/times.${alg}_$test6.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test7=`cat "$test7/Size_$size/times.${alg}_$test7.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","${median_test1}","${median_test2}","${median_test3}","${median_test4}","${median_test5}","${median_test6}","${median_test7}" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	done
done
