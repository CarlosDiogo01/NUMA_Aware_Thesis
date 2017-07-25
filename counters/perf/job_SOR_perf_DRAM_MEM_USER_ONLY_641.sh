#PBS -N SOR_JAVA_Improved_PERF_NUMA_DRAM_Counters__USER_ONLY_641
#PBS -l walltime=20:00:00
#PBS -q mei
#PBS -m abe
#PBS -M carlos.sa01@gmail.com

#PBS -lnodes=1:r641:ppn=24

# Machine USED (Interactive usage)
node=`echo $HOSTNAME | awk -F'.' '{print $1}'`


# Machine USED (job-exclusive usage)
#read -r node<$PBS_NODEFILE


############ Information about algorithm to run ################
alg="SOR_Improved"
exe="$HOME/NUMA_Aware_Thesis/java_codes/jar/SOR_Improved_sm.jar"
size=0
nthreads=8
################################################################

########################## Tests configuration ###############################
# Java Dir 
JAVA8="/share/apps/java/jdk1.8.0_20/bin/java"

# Tests to perform with perf
DEFAULT="$JAVA8 -jar $exe -5 $size $nthreads"
LOCAL_ACCESS="numactl --cpubind=0 --membind=0 $JAVA8 -jar $exe -5 $size $nthreads"
REMOTE_ACCESS="numactl --cpubind=0 --membind=1 $JAVA8 -jar $exe -5 $size $nthreads"

# Number of repetitions for each counter
# This will take advantage of -r flag of perf stat wich allow to repeat each test and print the stddev of average for all executions (max: 100, forever: 0)
REP=5

# Array with all tests
declare -a TEST=("$DEFAULT" "$LOCAL_ACCESS" "$REMOTE_ACCESS")

# Project Folder
Project_DIR=`pwd`
#############################################################################


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# #   
#	COUNTERS INFO
#
# 0xd3
# MEM_LOAD_UOPS_LLC_MISS_RETIRED - Load uops retired that missed the LLC
#       0x01 : PMU : [LOCAL_DRAM]  : Number of retired load uops that missed L3 but were service by local RAM. Does not count hardware prefetches
#       0x0c : PMU : [REMOTE_DRAM] : Number of retired load uops that missed L3 but were service by remote RAM, snoop not needed, snoop miss, snoop hit data not forwarded
#       0x10 : PMU : [REMOTE_HITM] : Number of retired load uops whose data sources was remote HITM
#       0x20 : PMU : [REMOTE_FWD]  : Load uops that miss in the L3 whose data source was forwarded from a remote cache
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Error control
ERROR_FLAG=0

# PERF USED
perf="/usr/bin/perf"
echo "PERF USED:"
$perf --version

echo
echo

hour=`date "+%Hh%Mm%Ss"`
mkdir "$Project_DIR/${alg}_DRAM_LOCAL_and_REMOTE_Counters_$hour"


for t in "${TEST[@]}"
do
	if [ "$t" == "$DEFAULT" ]; then
		name_test="DEFAULT"
	else
		if [ "$t" == "$LOCAL_ACCESS" ]; then
			name_test="LOCAL_ACCESS"
		else
			if [ "$t" == "$REMOTE_ACCESS" ]; then
				name_test="REMOTE_ACCESS"
			
			fi
		fi
	fi

	
	OUTPUT_FILE="$Project_DIR/${alg}_DRAM_LOCAL_and_REMOTE_Counters_${hour}/__perf_output_$name_test.output"

	###### MEM_LOAD_UOPS_LLC_MISS_RETIRED (0xd3) ###### 
	echo "Testing $name_test | MEM_LOAD_UOPS_LLC_MISS_RETIRED......." | tee -a $OUTPUT_FILE
	echo "Running '$t' " | tee -a $OUTPUT_FILE
	echo "Number of repetitions for each counter: $REP"
	echo | tee -a $OUTPUT_FILE

        echo -e "0x01 : PMU : [LOCAL_DRAM]" | tee -a $OUTPUT_FILE
        perf stat -e r5301d3:u -r $REP --output $OUTPUT_FILE --append $t &> /dev/null

        echo -e "0x0c : PMU : [REMOTE_DRAM]" | tee -a $OUTPUT_FILE
        perf stat -e r530cd3:u -r $REP --output $OUTPUT_FILE --append $t &> /dev/null
        
	echo -e "0x10 : PMU : [REMOTE_HITM]" | tee -a $OUTPUT_FILE
        perf stat -e r5310d3:u -r $REP --output $OUTPUT_FILE --append $t &> /dev/null

        echo -e "0x20 : PMU : [REMOTE_FWD]" | tee -a $OUTPUT_FILE
        perf stat -e r5320d3:u -r $REP --output $OUTPUT_FILE --append $t &> /dev/null
	
	echo ""
	echo ""
	
	# Organising info
	CSV="${name_test}_results.csv"
	ncounters=`grep -e "0x" $OUTPUT_FILE | wc -l`
	ncounters_results=`grep -e ":u" $OUTPUT_FILE | wc -l`
	
	if [ "$ncounters" -ne "$ncounters_results" ]; then
		ERROR_FLAG=1
		echo "Number of collected results different than number of counters" 
		echo "Please check if all "MEM_LOAD_UOPS_LLC_MISS_RETIRED" counters are available!"	
	else
		for ((i=1; i<=$ncounters; i++ ))
		do
			counter_i_name=`awk '/0x/' $OUTPUT_FILE | awk NR==$i`
			counter_i_RAWCode=`awk -F=' ' '/:u/' $OUTPUT_FILE | awk NR==$i | awk '{print $2}'`
			counter_i_result=`awk -F=' ' '/:u/' $OUTPUT_FILE | awk NR==$i | awk '{print $1}'`
			counter_i_stdDev=`awk -F=':u' '/:u/' $OUTPUT_FILE | awk NR==$i | awk '{ s = ""; for (i = 3; i <= NF; i++) s = s $i " "; print s }'`
			echo -e "$counter_i_name","$counter_i_RAWCode","$counter_i_result","$counter_i_stdDev" >> "$Project_DIR/${alg}_DRAM_LOCAL_and_REMOTE_Counters_${hour}/$CSV"
		done
	fi
done


# Printing results
if [ $ERROR_FLAG -ne 1 ]; then
	CSV_DIR="$Project_DIR/${alg}_DRAM_LOCAL_and_REMOTE_Counters_${hour}"
	cd $CSV_DIR 
	for CSV in *.csv
	do
		echo "Results for $CSV ......"
			column -tx -c 4 -s ',' $CSV
		echo
		echo 
	done
	echo "This results are in CSV file at $CSV_DIR ...."
	echo
else
	echo "Aborting..."
	rm -rf "$Project_DIR/${alg}_DRAM_LOCAL_and_REMOTE_Counters_$hour"
	echo "Check if MEM_UNCORE_RETIRED counters are available!"
fi

echo
echo
