#MERGING EXECUTION TIMES FOR EACH SIZE FOR EACH GROUP OF THREADS
# Schema:
# Size X        -> without -XX:+UseNUMA -> with -XX:+UseNUMA
# 1 Thread      ->      (.......)               (.......)
# 2 Threads     ->      (.......)               (.......)
# (.....)

read -r node_info<$PBS_NODEFILE
RESULTSFOLDER="results_on_$node_info"
TIMESFOLDER="Times_All_Sizes"
nr_samples=10
index_val_to_collect=5

mkdir "$RESULTSFOLDER/$TIMESFOLDER"

for size in 0 1 2 3 4 5
do
	echo "Size_$size","without -XX:+UseNUMA","with -XX:+UseNUMA" >> "$RESULTSFOLDER/$TIMESFOLDER/TIMES_All_Threads.Size_$size.csv"
	for thr in 1 2 4 8 16 24 32
	do
		#Collecting without -XX:+UseNUMA
			cd "$RESULTSFOLDER/without_UseNUMA/Size_$size/$thr.threads"
			#Computing Median for samples
			sort -t, -nk1 -o "times.$size.size.$thr.thr.txt" "times.$size.size.$thr.thr.txt"
			median_collected_without_UseNUMA=`cat "times.$size.size.$thr.thr.txt" | awk 'FNR == '$index_val_to_collect' {print}'`
			cd ../../../../ 	# back to jar default directory
	
		#Collecting with -XX:+UseNUMA
			cd "$RESULTSFOLDER/with_UseNUMA/Size_$size/$thr.threads"
                        sort -t, -nk1 -o "times.$size.size.$thr.thr.txt" "times.$size.size.$thr.thr.txt"
                        median_collected_with_UseNUMA=`cat "times.$size.size.$thr.thr.txt" | awk 'FNR == '$index_val_to_collect' {print}'`
			cd ../../../../		# back to jar default directory

		echo "$thr.Threads","$median_collected_without_UseNUMA","$median_collected_with_UseNUMA" >> "$RESULTSFOLDER/$TIMESFOLDER/TIMES_All_Threads.Size_$size.csv"
	done
done
