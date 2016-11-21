#MERGING EXECUTION TIMES FOR EACH SIZE FOR EACH GROUP OF THREADS
# Schema:
# Size X        -> without -XX:+UseNUMA -> with -XX:+UseNUMA
# 1 Thread      ->      (.......)               (.......)
# 2 Threads     ->      (.......)               (.......)
# (.....)
RESULTSFOLDER="results_on_compute-*"
TIMESFOLDER="Times_All_Sizes"

mkdir "$RESULTSFOLDER/$TIMESFOLDER"

echo "Size_$size","without -XX:+UseNUMA","with -XX:+UseNUMA" >> TIMES_CSV_FILE.csv
for size in 0 1 2 3 4 5
do
	for thr in 1 2 4 8 16 24 32
	do
		#Collecting without -XX:+UseNUMA
			cd "$RESULTSFOLDER/without_UseNUMA/Size_$size/$thr.threads"
			#Computing Median for samples
			nr_samples=`$(wc -l times.0.size.1.thr.txt | awk -F' ' '{print $1}')`
			index_val_to_collect=`$(( $nr_samples / 2 ))`
			sort -t, -nk1 -o "times.$size.size.$thr.thr.txt" "times.$size.size.$thr.thr.txt"
			val_collected_without_UseNUMA=`cat "times.$size.size.$thr.thr.txt" | awk 'FNR == '$nr_samples' {print}'`
	
		#Collecting with -XX:+UseNUMA
		

		#Collecting results without NUMA
	      
		MEDIAN=""               
		    

	done

done
