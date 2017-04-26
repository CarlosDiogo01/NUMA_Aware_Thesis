#PBS -N SOR_C_Original_ICC_TimeTest
#PBS -l walltime=20:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE



############ Information about algorithm to run ################
alg="SOR_C_Original_ICC"
exeICC="$HOME/NUMA_Aware_Thesis/c_src/exes/sor_sm_improvment_icc_16_default"
exeICCprocbindmaster="$HOME/NUMA_Aware_Thesis/c_src/exes/sor_sm_improvment_icc_16_procbind_master"
exeICCprocbindspread="$HOME/NUMA_Aware_Thesis/c_src/exes/sor_sm_improvment_icc_16_procbind_spread"
exeICCprocbindclose="$HOME/NUMA_Aware_Thesis/c_src/exes/sor_sm_improvment_icc_16_procbind_close"
################################################################



########################## Tests configuration ###############################
dataset="1 2 3 4 5"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=20
index_val_to_collect=10
Project_Folder="$HOME/NUMA_Aware_Thesis/c_src/${alg}_TimeTest_$node_info"
TIMES_ALL_TESTS_PER_SIZE="TIMES_${alg}_ALL_TESTS_PER_SIZE"
##############################################################################




############################### Tests ######################################

# ICC KMP_AFFINITY tests based on "Default" execution. Just changing binding policy on KMP_AFFINITY
test7="KMP_AFFINITY_compact"
test8="KMP_AFFINITY_scatter"

# ICC omp_proc_bind tests
#test9="omp_proc_bind_master"
#test10="omp_proc_bind_spread"
#test11="omp_proc_bind_close"
############################################################################



# Go to Project Folder
mkdir $Project_Folder
cd $Project_Folder



########### Loading ICC for using intel exe tests ##################
module purge

# ICC 16
source /share/apps/intel/compilers_and_libraries_2016/linux/bin/compilervars.sh intel64
source /share/apps/intel/compilers_and_libraries_2016/linux/mkl/bin/mklvars.sh intel64
#############################################################################


# test9 -> omp_proc_bind_master
#mkdir $test9
#for size in $dataset
#do
#        mkdir "$test9/Size_$size"
#        for thr in $thread_bundle
#        do
#                csv="times.${alg}_$test9.$size.size.$thr.thr.csv"
#                echo "OMP_PROC_BIND=master"
#                for ((i = 0; i < $REP; i++))
#                do
#                        $exeICCprocbindmaster -5 $size $thr >> "$test9/Size_$size/$csv"
#               done
#               sort -t, -nk1 -o "$test9/Size_$size/$csv" "$test9/Size_$size/$csv"
#       done
# done



# test10 -> omp_proc_bind_spread
#mkdir $test10
#for size in $dataset
#do
#        mkdir "$test10/Size_$size"
#        for thr in $thread_bundle
#        do
#                csv="times.${alg}_$test10.$size.size.$thr.thr.csv"
#                echo "OMP_PROC_BIND=spread"
#                for ((i = 0; i < $REP; i++))
#                do
#                       $exeICCprocbindspread -5 $size $thr >> "$test10/Size_$size/$csv"
#                done
#                sort -t, -nk1 -o "$test10/Size_$size/$csv" "$test10/Size_$size/$csv"
#        done
#done


# test11 -> omp_proc_bind_close
#mkdir $test11
#for size in $dataset
#do
#        mkdir "$test11/Size_$size"
#        for thr in $thread_bundle
#        do
#                csv="times.${alg}_$test11.$size.size.$thr.thr.csv"
#                echo "OMP_PROC_BIND=close"
#                for ((i = 0; i < $REP; i++))
#                do
#                        $exeICCprocbindclose -5 $size $thr >> "$test11/Size_$size/$csv"
#                done
#                sort -t, -nk1 -o "$test11/Size_$size/$csv" "$test11/Size_$size/$csv"
#        done
# done



# test7 -> KMP_AFFINITY_compact
mkdir $test7
for size in $dataset
do
        mkdir "$test7/Size_$size"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test7.$size.size.$thr.thr.csv"
                echo "Test7 - KMP_AFFINITY Compact"
                export KMP_AFFINITY=compact
                for ((i = 0; i < $REP; i++))
                do
                        $exeICC -5 $size $thr >> "$test7/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test7/Size_$size/$csv" "$test7/Size_$size/$csv"
        done
done


#test8 -> KMP_AFFINITY_scatter
mkdir $test8
for size in $dataset
do
        mkdir "$test8/Size_$size"
        for thr in $thread_bundle
        do
                csv="times.${alg}_$test8.$size.size.$thr.thr.csv"
                echo "Test4 - KMP_AFFINITY Scatter"
                export KMP_AFFINITY=scatter
                for ((i = 0; i < $REP; i++))
                do
                        $exeICC -5 $size $thr >> "$test8/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test8/Size_$size/$csv" "$test8/Size_$size/$csv"
        done
done




#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_$size","$test7","$test8" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_test7=`cat "$test7/Size_$size/times.${alg}_$test7.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test8=`cat "$test8/Size_$size/times.${alg}_$test8.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","$median_test7","$median_test8" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	done
done
