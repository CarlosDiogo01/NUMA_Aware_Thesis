#PBS -N LUFACT_NUMA_TimeTest_NUMAChunkResizeWeight
#PBS -l walltime=20:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE



############ Information about algorithm to run ################
alg="LUFACT_INNERLOOP"
exe="$HOME/NUMA_Aware_Thesis/java_codes/jar/lufact_inner_loop.jar"
################################################################




########################## Tests configuration ###############################
dataset="1 2 3 4 5"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=15
index_val_to_collect=8
Project_Folder="$HOME/NUMA_Aware_Thesis/java_codes/jar/${alg}_TimeTest_NUMAChunkResizeWeight_$node_info"
TIMES_ALL_TESTS_PER_SIZE="TIMES_${alg}_ALL_TESTS_PER_SIZE"
##############################################################################




################## External LIBS and Tools Configuration #####################
# Java Dir 
JAVA8="/share/apps/java/jdk1.8.0_20/bin/java"
#############################################################################




############################### Tests ######################################
chunks="5 10 20 50 75 100"
############################################################################


# Go to Project Folder
mkdir $Project_Folder
cd $Project_Folder

for size in $dataset
do
	mkdir "Size_$size"
	for chunksize in $chunks	
	do
		mkdir "Size_$size/$chunksize"
		for thr in $thread_bundle
		do
			csv="times.${alg}_NUMAChunkResizeWeight_$chunksize.$size.size.$thr.thr.csv"
			for ((i = 0; i < $REP; i++))
			do
				$JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC -XX:NUMAChunkResizeWeight=$chunksize $exe -5 $size $thr >> "Size_$size/$chunksize/$csv"
			done
			sort -t, -nk1 -o "Size_$size/$chunksize/$csv" "Size_$size/$chunksize/$csv"
		done
	done
done

#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_$size","5","10","20","75","100" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_NUMAChunkResizeWeight_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_5=`cat "Size_$size/5/times.${alg}_NUMAChunkResizeWeight_5.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_10=`cat "Size_$size/10/times.${alg}_NUMAChunkResizeWeight_10.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_20=`cat "Size_$size/20/times.${alg}_NUMAChunkResizeWeight_20.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`	
		median_75=`cat "Size_$size/75/times.${alg}_NUMAChunkResizeWeight_75.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_100=`cat "Size_$size/100/times.${alg}_NUMAChunkResizeWeight_100.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","$median_5","$median_10","$median_20","$median_75","$median_100" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_NUMAChunkResizeWeight_Size_$size.csv"
	done
done
