exe="CryptImproved_sm_with_NUMA_Counters.jar"
FLAGS="-XX:+UseNUMA -jar"
REP="10"

read -r node_info<$PBS_NODEFILE
RESULTSFOLDER="results_on_$node_info"

mkdir "./$RESULTSFOLDER"
mkdir "./$RESULTSFOLDER/with_UseNUMA"

for size in 0 1 2 3 4 5
do
	mkdir "$RESULTSFOLDER/with_UseNUMA/Size_$size"
	echo "<ignore> size = $size" 
	echo "<ignore> size = $size" >> "$RESULTSFOLDER/with_UseNUMA/Size_$size/ignore_$size.size.txt"

	for thr in 1 2 4 8 16 24 32
	do
		mkdir "$RESULTSFOLDER/with_UseNUMA/Size_$size/$thr.threads"
		echo "<ignore> thr = $thr" 
		echo "<ignore> thr = $thr" >> "$RESULTSFOLDER/with_UseNUMA/Size_$size/$thr.threads/ignore_$thr.threads.txt"
		
		for((i = 0; i < $REP; i++))
		do
			/share/apps/java/jdk1.8.0_20/bin/java $FLAGS $exe -5 $size $thr >> "times.$size.size.$thr.thr.txt"
		done
		mv "numa_before.txt" "$RESULTSFOLDER/with_UseNUMA/Size_$size/$thr.threads/numa_before_$thr.thr.txt"
		mv "numa_after.txt" "$RESULTSFOLDER/with_UseNUMA/Size_$size/$thr.threads/numa_after_$thr.thr.txt"
		mv *.txt "$RESULTSFOLDER/with_UseNUMA/Size_$size/$thr.threads/"
	done
done

