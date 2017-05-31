#PBS -N SOR_NUMA_TimeTest_NUMAPageResizeRate
#PBS -l walltime=20:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE



############ Information about algorithm to run ################
alg="SOR"
exe="$HOME/NUMA_Aware_Thesis/java_codes/jar/SOR_Improved_sm.jar"
################################################################




########################## Tests configuration ###############################
dataset="1 2 3 4 5"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=15
index_val_to_collect=8
Project_Folder="$HOME/NUMA_Aware_Thesis/java_codes/jar/${alg}_TimeTest_NUMAPageResizeRate_$node_info"
TIMES_ALL_TESTS_PER_SIZE="TIMES_${alg}_ALL_TESTS_PER_SIZE"
##############################################################################




################## External LIBS and Tools Configuration #####################
# Java Dir 
JAVA8="/share/apps/java/jdk1.8.0_20/bin/java"
#############################################################################




############################### Tests ######################################
amount_per_collection="2M 4M 8M 16M 32M 64M 128M 256M 512M 1G 2G"
############################################################################


# Go to Project Folder
mkdir $Project_Folder
cd $Project_Folder

for size in $dataset
do
	mkdir "Size_$size"
	for amount in $amount_per_collection	
	do
		mkdir "Size_$size/$amount"
		for thr in $thread_bundle
		do
			csv="times.${alg}_NUMASpaceResizeRate_$amount.$size.size.$thr.thr.csv"
			for ((i = 0; i < $REP; i++))
			do
				$JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC -XX:NUMASpaceResizeRate=$amount $exe -5 $size $thr >> "Size_$size/$amount/$csv"
			done
			sort -t, -nk1 -o "Size_$size/$amount/$csv" "Size_$size/$amount/$csv"
		done
	done
done

#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_$size","2M","4M","8M","16M","32M","64M","128M","256M","512M","1G","2G" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_NUMASpaceResizeRate_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_2M=`cat "Size_$size/2M/times.${alg}_NUMASpaceResizeRate_2M.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_4M=`cat "Size_$size/4M/times.${alg}_NUMASpaceResizeRate_4M.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_8M=`cat "Size_$size/8M/times.${alg}_NUMASpaceResizeRate_8M.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_16M=`cat "Size_$size/16M/times.${alg}_NUMASpaceResizeRate_16M.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`	
		median_32M=`cat "Size_$size/32M/times.${alg}_NUMASpaceResizeRate_32M.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_64M=`cat "Size_$size/64M/times.${alg}_NUMASpaceResizeRate_64M.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_128M=`cat "Size_$size/128M/times.${alg}_NUMASpaceResizeRate_128M.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_256M=`cat "Size_$size/256M/times.${alg}_NUMASpaceResizeRate_256M.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_512M=`cat "Size_$size/512M/times.${alg}_NUMASpaceResizeRate_512M.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_1G=`cat "Size_$size/1G/times.${alg}_NUMASpaceResizeRate_1G.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_2G=`cat "Size_$size/2G/times.${alg}_NUMASpaceResizeRate_2G.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","$median_2M","$median_4M","$median_8M","$median_16M","$median_32M","$median_64M","$median_128M","$median_256M","$median_512M","$median_1G","$median_2G" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_NUMASpaceResizeRate_Size_$size.csv"
	done
done
