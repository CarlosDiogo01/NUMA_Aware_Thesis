#PBS -N SOR_NUMA_TimeTest_NUMAPageScanRate
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
Project_Folder="$HOME/NUMA_Aware_Thesis/java_codes/jar/${alg}_TimeTest_NUMAPageScanRate_$node_info"
TIMES_ALL_TESTS_PER_SIZE="TIMES_${alg}_ALL_TESTS_PER_SIZE"
##############################################################################




################## External LIBS and Tools Configuration #####################
# Java Dir 
JAVA8="/share/apps/java/jdk1.8.0_20/bin/java"
#############################################################################




############################### Tests ######################################
number_of_pages="4 8 16 32 64 128 256 512 1024 2048 4096"
############################################################################


# Go to Project Folder
mkdir $Project_Folder
cd $Project_Folder

for size in $dataset
do
	mkdir "Size_$size"
	for npages in $number_of_pages	
	do
		mkdir "Size_$size/$npages"
		for thr in $thread_bundle
		do
			csv="times.${alg}_NUMAPageScanRate_$npages.$size.size.$thr.thr.csv"
			for ((i = 0; i < $REP; i++))
			do
				$JAVA8 -jar -XX:+UseNUMA -XX:+UseParallelGC -XX:NUMAPageScanRate=$npages $exe -5 $size $thr >> "Size_$size/$npages/$csv"
			done
			sort -t, -nk1 -o "Size_$size/$npages/$csv" "Size_$size/$npages/$csv"
		done
	done
done

#Extract Medians and merge all times for all tests per thread
mkdir $TIMES_ALL_TESTS_PER_SIZE
for size in $dataset
do
	echo "Size_$size","4","8","16","32","64","128","256","512","1024","2048","4096" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_NUMAPageScanRate_Size_$size.csv"
	for thr in $thread_bundle
	do
		median_4=`cat "Size_$size/4/times.${alg}_NUMAPageScanRate_4.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_8=`cat "Size_$size/8/times.${alg}_NUMAPageScanRate_8.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_16=`cat "Size_$size/16/times.${alg}_NUMAPageScanRate_16.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`	
		median_32=`cat "Size_$size/32/times.${alg}_NUMAPageScanRate_32.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_64=`cat "Size_$size/64/times.${alg}_NUMAPageScanRate_64.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_128=`cat "Size_$size/128/times.${alg}_NUMAPageScanRate_128.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_256=`cat "Size_$size/256/times.${alg}_NUMAPageScanRate_256.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_512=`cat "Size_$size/512/times.${alg}_NUMAPageScanRate_512.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_1024=`cat "Size_$size/1024/times.${alg}_NUMAPageScanRate_1024.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_2048=`cat "Size_$size/2048/times.${alg}_NUMAPageScanRate_2048.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		median_4096=`cat "Size_$size/4096/times.${alg}_NUMAPageScanRate_4096.$size.size.$thr.thr.csv" | awk 'FNR == '$index_val_to_collect' {print}'`
		echo "$thr.Threads","$median_4","$median_8","$median_16","$median_32","$median_64","$median_128","$median_256","$median_512","$median_1024","$median_2048","$median_4096" >> "$TIMES_ALL_TESTS_PER_SIZE/TIMES_${alg}_NUMAPageScanRate_Size_$size.csv"
	done
done
