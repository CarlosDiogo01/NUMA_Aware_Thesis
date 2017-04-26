# Machine USED
node_info="KNL-002-1-Config-2-1"


############ Information about algorithm to run ################
alg="SOR_C_1Alloc_GCC"
exe1="$HOME/NUMA_Aware_Thesis/c_src/exes/KNL_exes/sor_sm_improvment_KNL_1Alloc_gcc530"
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



#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_$size","$test1","$test2" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_test1=`cat "$test1/Size_$size/times.${alg}_$test1.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test2=`cat "$test2/Size_$size/times.${alg}_$test2.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","${median_test1}","${median_test2}" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	done
done
