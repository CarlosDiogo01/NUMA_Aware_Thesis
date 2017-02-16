### ORGANIZING NUMA Results ####
cd results_on_compute-*

for with_without in "without_UseNUMA" "with_UseNUMA"
do
cd "$with_without"

mkdir "NUMA_AllResults"
for size in 0 1 2 3 4 5
do
	cd "Size_$size"
	for thr in 1 2 4 8 16 24 32
	do
		cd "$thr.threads"
		NUMA_BEFORE_COUNTERS_FILE="numa_before_$thr.thr.txt"
		NUMA_AFTER_COUNTERS_FILE="numa_after_$thr.thr.txt"
		
		num_threads=`echo $NUMA_BEFORE_COUNTERS_FILE | awk -F'[_.]' '{print $3}'`
		node0=`cat $NUMA_BEFORE_COUNTERS_FILE | awk -F' ' '{print $1}' | head -1`
		node1=`cat $NUMA_BEFORE_COUNTERS_FILE | awk -F' ' '{print $2}' | head -1`
		
		# Before Thread Creation
		# Node0
		valb_numa_hit_node0=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 2 {print}' | awk '{print $2}'`
		valb_numa_miss_node0=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 3 {print}' | awk '{print $2}'`
		valb_numa_foreign_node0=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 4 {print}' | awk '{print $2}'`
		valb_numa_interleave_hit_node0=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 5 {print}' | awk '{print $2}'`
		valb_numa_local_node_node0=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 6 {print}' | awk '{print $2}'`
		valb_numa_other_node_node0=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 7 {print}' | awk '{print $2}'`
		# Node1
		valb_numa_hit_node1=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 2 {print}' | awk '{print $3}'`
		valb_numa_miss_node1=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 3 {print}' | awk '{print $3}'`
		valb_numa_foreign_node1=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 4 {print}' | awk '{print $3}'`
		valb_numa_interleave_hit_node1=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 5 {print}' | awk '{print $3}'`
		valb_numa_local_node_node1=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 6 {print}' | awk '{print $3}'`
		valb_numa_other_node_node1=`cat $NUMA_BEFORE_COUNTERS_FILE | awk 'FNR == 7 {print}' | awk '{print $3}'`

		#After Thread Creation
		# Node0
		vala_numa_hit_node0=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 2 {print}' | awk '{print $2}'`
		vala_numa_miss_node0=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 3 {print}' | awk '{print $2}'`
		vala_numa_foreign_node0=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 4 {print}' | awk '{print $2}'`
		vala_numa_interleave_hit_node0=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 5 {print}' | awk '{print $2}'`
		vala_numa_local_node_node0=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 6 {print}' | awk '{print $2}'`
		vala_numa_other_node_node0=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 7 {print}' | awk '{print $2}'`
		# Node1
		vala_numa_hit_node1=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 2 {print}' | awk '{print $3}'`
		vala_numa_miss_node1=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 3 {print}' | awk '{print $3}'`
		vala_numa_foreign_node1=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 4 {print}' | awk '{print $3}'`
		vala_numa_interleave_hit_node1=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 5 {print}' | awk '{print $3}'`
		vala_numa_local_node_node1=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 6 {print}' | awk '{print $3}'`
		vala_numa_other_node_node1=`cat $NUMA_AFTER_COUNTERS_FILE | awk 'FNR == 7 {print}' | awk '{print $3}'`


		#Printing a CSV with NUMA Counters with schema: thr,BeforeN0,BeforeN1,AfterN0,AfterN1
		FILE=NUMA_Counters.$size.size.$thr.threads.csv
		echo "NUMA_Counters_$size"_size_"$thr"_Threads"","Before_$node0",Before_$node1,After_$node0,After_$node1 >> $FILE
		echo "numa_hit",$valb_numa_hit_node0,$valb_numa_hit_node1,$vala_numa_hit_node0,$vala_numa_hit_node1 >> $FILE
		echo "numa_miss",$valb_numa_miss_node0,$valb_numa_miss_node1,$vala_numa_miss_node0,$vala_numa_miss_node1 >> $FILE
		echo "numa_foreign",$valb_numa_foreign_node0,$valb_numa_foreign_node1,$vala_numa_foreign_node0,$vala_numa_foreign_node1 >> $FILE
		echo "interleave_hit",$valb_numa_interleave_hit_node0,$valb_numa_interleave_hit_node1,$vala_numa_interleave_hit_node0,$vala_numa_interleave_hit_node1 >> $FILE
		echo "local_node",$valb_numa_local_node_node0,$valb_numa_local_node_node1,$vala_numa_local_node_node0,$vala_numa_local_node_node1 >> $FILE
		echo "other_node",$valb_numa_other_node_node0,$valb_numa_other_node_node1,$vala_numa_other_node_node0,$vala_numa_other_node_node1 >> $FILE

		cp $FILE ../../NUMA_AllResults
		cd .. 	#back to $thr.threads folders directory
	done
	cd ..	#back to Size_$size folders directory
done

cd ..	#back to without_UseNUMA and with_UseNUMA folders directory
done


#MERGE NUMA COUNTERS for each size in on csv file
for with_without in "without_UseNUMA" "with_UseNUMA"
do
	cd "$with_without/NUMA_AllResults"
	for size in 0 1 2 3 4 5
	do
		for thr in 1 2 4 8 16 24 32
		do
			output=`cat "NUMA_Counters.$size.size.$thr.threads.csv" >> "NUMA_COUNTERS.$with_without.Size_$size.AllThreads.csv"`
		done
	done
	cd ../../	#back to with_UseNUMA and without_UseNUMA folders directory
done

cd ..	#back to jar default folder
