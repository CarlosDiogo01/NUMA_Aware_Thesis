# Machine USED
node_info="KNL-002-1-Config-2-1"



############ Information about algorithm to run ################
alg="SOR_C_Original_ICC_KMP_AFFINITY"
exe="$HOME/NUMA_Aware_Thesis/c_src/exes/sor_sm_improvment_icc17_KNL_default"
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

# ICC 17
source /opt/intel/compilers_and_libraries/linux/bin/compilervars.sh intel64

#Vtune
source /opt/intel/vtune_amplifier_xe/amplxe-vars.sh
#############################################################################




############################### Tests ######################################
test1="KNL_Default"

#KMP_AFFINITY tests based on "Default" execution. Just changing binding policy on KMP_AFFINITY
test3="KNL_KMP_AFFINITY_compact"
test4="KNL_KMP_AFFINITY_scatter"
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
