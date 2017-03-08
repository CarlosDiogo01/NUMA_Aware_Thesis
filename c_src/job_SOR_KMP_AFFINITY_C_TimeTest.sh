#PBS -N SOR_KMP_AFFINITY_C_TimeTest
#PBS -l walltime=20:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE



############ Information about algorithm to run ################
alg="SOR_C"
exe="$HOME/NUMA_Aware_Thesis/c_src/SOR_C/Sor_sm_improvment/dist/Debug/OpenMPI-MacOSX/sor_sm_improvment_icc_default"
################################################################




########################## Tests configuration ###############################
dataset="1 2 3 4 5"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=10
index_val_to_collect=5
Project_Folder="$HOME/NUMA_Aware_Thesis/c_src/SOR_C/Sor_sm_improvment/${alg}_TimeTest_$node_info"
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
test2="KMP_AFFINITY_none"
test3="KMP_AFFINITY_compact"
test4="KMP_AFFINITY_scatter"
test5="KMP_AFFINITY_disable"
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


#test2 -> KMP_AFFINITY_none dont bind OpenMP threads to particularr thread context BUT if the OS support thread affinity the compiler still uses OpenMP thread affinity interface to determine machine topology.
mkdir $test2
for size in $dataset
do
        mkdir "$test2/Size_$size"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
		echo "Test2 - KMP_AFFINITY None"
		export KMP_AFFINITY=verbose,none
                for ((i = 0; i < $REP; i++))
                do
			$exe -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
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
		export KMP_AFFINITY=verbose,compact
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
		export KMP_AFFINITY=verbose,scatter
                for ((i = 0; i < $REP; i++))
                do
			$exe -5 $size $thr >> "$test4/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test4/Size_$size/$csv" "$test4/Size_$size/$csv"
        done
done


#test5 -> KMP_AFFINITY_disable
mkdir $test5
for size in $dataset
do
        mkdir "$test5/Size_$size"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test5.$size.size.$thr.thr.csv"
		echo "Test5 - KMP_AFFINITY Disable"
		export KMP_AFFINITY=verbose,disable
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
	echo "Size_$size","$test1","$test2","$test3","$test4","$test5" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_test1=`cat "$test1/Size_$size/times.${alg}_$test1.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test2=`cat "$test2/Size_$size/times.${alg}_$test2.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test3=`cat "$test3/Size_$size/times.${alg}_$test3.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`	
		median_test4=`cat "$test4/Size_$size/times.${alg}_$test4.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test5=`cat "$test5/Size_$size/times.${alg}_$test5.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","$median_test1","$median_test2","$median_test3","$median_test4","$median_test5" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	done
done
