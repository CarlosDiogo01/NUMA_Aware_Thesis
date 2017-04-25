#PBS -N LUFACT_C_ArrayPointers_TimeTest_GCC
#PBS -l walltime=20:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE



############ Information about algorithm to run ################
alg="LUFACT_C_Original_ArrayPointers_GCC"
exe="$HOME/NUMA_Aware_Thesis/c_src/exes/lufact_sm_array_pointers_gcc530"
################################################################



########################## Tests configuration ###############################
dataset="1 2 3 4 5"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=20
index_val_to_collect=10
Project_Folder="$HOME/NUMA_Aware_Thesis/c_src/${alg}_TimeTest_$node_info"
TIMES_ALL_TESTS_PER_SIZE="TIMES_${alg}_ALL_TESTS_PER_SIZE"
##############################################################################



################## External LIBS and Tools Configuration #####################
# GCC
module purge
module load gnu/5.3.0
#############################################################################



############################### Tests ######################################
test1="Default"

# GCC GOMP_CPU_AFFINITY
test2="GOMP_CPU_AFFINITY_Interlieving"
test3="GOMP_CPU_AFFINITY_bindingSocket0_then_Socket1"
test6="numactl_interleave_all_only"


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
                echo "<ignore> thr = $thr"
		csv="times.${alg}_$test1.$size.size.$thr.thr.csv" 
                for ((i = 0; i < $REP; i++))
                do
                        # Default execution
                        $exe -5 $size $thr >> "$test1/Size_$size/$csv"
		done
                sort -t, -nk1 -o "$test1/Size_$size/$csv" "$test1/Size_$size/$csv"
	done
done



#test6 -> numactl_interleave_all_only
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
			numactl --interleave=all $exe -5 $size $thr >> "$test6/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test6/Size_$size/$csv" "$test6/Size_$size/$csv"
        done
done



#test2 -> GOMP_CPU_AFFINITY_Interlieving (threads distributed between socket 0 and socket 1 alternately)
mkdir $test2
for size in $dataset
do
	mkdir "$test2/Size_$size"

        for thr in 1
        do
                echo "<ignore> thr = $thr"
		csv="times.${alg}_$test2.$size.size.$thr.thr.csv" 
                export GOMP_CPU_AFFINITY=0
		for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test2/Size_$size/$csv"
		done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
	done


	for thr in 2
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,8
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done

	
	for thr in 4
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,8,1,9
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done


	for thr in 8
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,8,1,9,2,10,3,11
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done

	
	for thr in 10
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,8,1,9,2,10,3,11,4,12
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done

	
	for thr in 12
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,8,1,9,2,10,3,11,4,12,5,13
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done
	
	
	#Using MAX PHYSICAL CORES ONLY (in 641 machine)
	for thr in 16
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,8,1,9,2,10,3,11,4,12,5,13,6,14,7,15
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done

	
	for thr in 24
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,8,1,9,2,10,3,11,4,12,5,13,6,14,7,15,16,24,17,25,18,26,19,27
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done


	for thr in 32
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test2.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,8,1,9,2,10,3,11,4,12,5,13,6,14,7,15,16,24,17,25,18,26,19,27,20,28,21,29,22,30,23,31
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test2/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test2/Size_$size/$csv" "$test2/Size_$size/$csv"
        done
	
done



# test3 -> GOMP_CPU_AFFINITY_bindingSocket0_then_Socket1
# First filling Socket 0 with threads then Socket 1
 mkdir $test3
 for size in $dataset
 do
	mkdir "$test3/Size_$size"

        for thr in 1
        do
                echo "<ignore> thr = $thr"
		csv="times.${alg}_$test3.$size.size.$thr.thr.csv" 
               export GOMP_CPU_AFFINITY=0
		for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test3/Size_$size/$csv"
		done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
	done


       for thr in 2
        do
                echo "<ignore> thr = $thr"
		csv="times.${alg}_$test3.$size.size.$thr.thr.csv" 
                export GOMP_CPU_AFFINITY=0,1
		for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test3/Size_$size/$csv"
		done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
	done


        for thr in 4
        do
                echo "<ignore> thr = $thr"
		csv="times.${alg}_$test3.$size.size.$thr.thr.csv" 
                export GOMP_CPU_AFFINITY=0,1,2,3
		for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test3/Size_$size/$csv"
		done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
	done
	
	
	for thr in 8
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test3.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,1,2,3,4,5,6,7
                for ((i = 0; i < $REP; i++))
                do
                       $exe -5 $size $thr >> "$test3/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
        done


	for thr in 10
       do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test3.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,1,2,3,4,5,6,7,16,17
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test3/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
        done

	
	for thr in 12
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test3.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,1,2,3,4,5,6,7,16,17,18,19
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test3/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
        done


	#Socket 0 is Full of Threads (8 physical cores + 8 multithread) !!!
	for thr in 16
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test3.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test3/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
        done

	
	#Start Filling Socket 1
        for thr in 24
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test3.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23,8,9,10,11,12,13,14,15
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test3/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
        done

	
	for thr in 32
        do
                echo "<ignore> thr = $thr"
                csv="times.${alg}_$test3.$size.size.$thr.thr.csv"
                export GOMP_CPU_AFFINITY=0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23,8,9,10,11,12,13,14,15,24,25,26,27,28,29,30,31
                for ((i = 0; i < $REP; i++))
                do
                        $exe -5 $size $thr >> "$test3/Size_$size/$csv"
                done
                sort -t, -nk1 -o "$test3/Size_$size/$csv" "$test3/Size_$size/$csv"
        done
done




#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_$size","$test1","$test2","$test3","$test6" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_test1=`cat "$test1/Size_$size/times.${alg}_$test1.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test2=`cat "$test2/Size_$size/times.${alg}_$test2.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test3=`cat "$test3/Size_$size/times.${alg}_$test3.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_test6=`cat "$test6/Size_$size/times.${alg}_$test6.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","$median_test1","$median_test2","$median_test3","$median_test6" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_Size_$size.csv"
	done
done
