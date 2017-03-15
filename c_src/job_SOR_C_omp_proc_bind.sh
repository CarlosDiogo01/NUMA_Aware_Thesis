#PBS -N SOR_C_omp_proc_bind_TimeTest
#PBS -l walltime=10:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE


############ Information about algorithm to run ################
alg="SOR_C_proc_bind"
exe1="$HOME/NUMA_Aware_Thesis/c_src/exes/sor_sm_improvment_proc_bind_master"
exe2="$HOME/NUMA_Aware_Thesis/c_src/exes/sor_sm_improvment_proc_bind_spread"
exe3="$HOME/NUMA_Aware_Thesis/c_src/exes/sor_sm_improvment_proc_bind_close"
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

# GCC
module load gnu/5.3.0
#############################################################################




############################### Tests ######################################
test1="omp_proc_bind_master"
test2="omp_proc_bind_spread"
test3="omp_proc_bind_close"
############################################################################

# Go to Project Folder
mkdir $Project_Folder
cd $Project_Folder


#test1 -> OMP_PROC_BIND=master
mkdir $test1
for size in $dataset
do
	mkdir "$test1/Size_$size"
        for thr in $thread_bundle
        do
		csv="times.${alg}_$test1.$size.size.$thr.thr.csv" 
		echo "OMP_PROC_BIND=master"
                for ((i = 0; i < $REP; i++))
                do
                        $exe1 -5 $size $thr >> "$test1/Size_$size/$csv"
		done
                sort -t, -nk1 -o "$test1/Size_$size/$csv" "$test1/Size_$size/$csv"
	done
done


#test2 -> OMP_PROC_BIND=spread 
mkdir $test2
for size in $dataset
do
        mkdir "$test2/Size_$size"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
		echo "OMP_PROC_BIND=spread"
                for ((i = 0; i < $REP; i++))
                do
			$exe2 -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done
done


#test3 -> OMP_PROC_BIND=close
mkdir $test3
for size in $dataset
do
        mkdir "$test3/Size_$size"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test3.$size.size.$thr.thr.csv"
		echo "OMP_PROC_BIND=close"
                for ((i = 0; i < $REP; i++))
                do
			$exe3 -5 $size $thr >> "$test3/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
        done
done


#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_$size","$test1","$test2","$test3" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_test1=`cat "$test1/Size_$size/times.${alg}_$test1.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test2=`cat "$test2/Size_$size/times.${alg}_$test2.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test3=`cat "$test3/Size_$size/times.${alg}_$test3.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`	
		echo "$thr.Threads","$median_test1","$median_test2","$median_test3" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	done
done
