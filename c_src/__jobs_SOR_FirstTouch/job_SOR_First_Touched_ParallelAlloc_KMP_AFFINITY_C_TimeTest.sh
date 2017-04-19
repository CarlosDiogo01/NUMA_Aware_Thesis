#PBS -N SOR_FirstTouched_ParallelAlloc_KMP_AFFINITY_C_TimeTest
#PBS -l walltime=20:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE



############ Information about algorithm to run ################
alg="Sor_C_FT_ICC16_ParallelAlloc"
exe="$HOME/NUMA_Aware_Thesis/c_src/SOR_C_FirstTouch/Sor_sm_improvment_ICC/dist/Debug/OpenMPI-MacOSX/Sor_FT_ICC_ParallelAlloc"
################################################################




########################## Tests configuration ###############################
dataset="1 2 3 4 5"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=16
index_val_to_collect=8
Project_Folder="$HOME/NUMA_Aware_Thesis/c_src/${alg}_TimeTest_$node_info"
TIMES_ALL_TESTS_PER_SIZE="TIMES_${alg}_ALL_TESTS_PER_SIZE"
##############################################################################




################## External LIBS and Tools Configuration #####################
module purge

# ICC
source /share/apps/intel/compilers_and_libraries_2016/linux/bin/compilervars.sh intel64
source /share/apps/intel/compilers_and_libraries_2016/linux/mkl/bin/mklvars.sh intel64
#############################################################################




############################### Tests ######################################
test1="Default"

#KMP_AFFINITY tests based on "Default" execution. Just changing binding policy on KMP_AFFINITY
test3="KMP_AFFINITY_compact"
test4="KMP_AFFINITY_scatter"
############################################################################

# Go to Project Folder
mkdir $Project_Folder
cd $Project_Folder


#test1 -> Default
mkdir $test1
for size in $dataset
do
	mkdir "$test1/Size_$size"
        for thr in $thread_bundle
        do
		csv="times.${alg}_$test1.$size.size.$thr.thr.csv" 
                for ((i = 0; i < $REP; i++))
                do
                        # Default execution
                        $exe -5 $size $thr >> "$test1/Size_$size/$csv"
		done
                sort -t, -nk1 -o "$test1/Size_$size/$csv" "$test1/Size_$size/$csv"
	done
done


#test3 -> KMP_AFFINITY_compact
mkdir $test3
for size in $dataset
do
        mkdir "$test3/Size_$size"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test3.$size.size.$thr.thr.csv"
		echo "Test3 - KMP_AFFINITY Compact"
		export KMP_AFFINITY=compact
                for ((i = 0; i < $REP; i++))
                do
			$exe -5 $size $thr >> "$test3/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
        done
done


#test4 -> KMP_AFFINITY_scatter
mkdir $test4
for size in $dataset
do
        mkdir "$test4/Size_$size"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test4.$size.size.$thr.thr.csv"
		echo "Test4 - KMP_AFFINITY Scatter"
		export KMP_AFFINITY=scatter
                for ((i = 0; i < $REP; i++))
                do
			$exe -5 $size $thr >> "$test4/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test4/Size_$size/$csv" "$test4/Size_$size/$csv"
        done
done

#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_$size","$test1","$test3","$test4" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_test1=`cat "$test1/Size_$size/times.${alg}_$test1.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test3=`cat "$test3/Size_$size/times.${alg}_$test3.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`	
		median_test4=`cat "$test4/Size_$size/times.${alg}_$test4.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","$median_test1","$median_test3","$median_test4" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	done
done
