#PBS -N SOR_JAVA_Improved_PERF_NUMA_DRAM_Counters__USER_ONLY_431
#PBS -l walltime=20:00:00
#PBS -q mei
#PBS -m abe
#PBS -M carlos.sa01@gmail.com

#PBS -lnodes=1:r431:ppn=24

# Machine USED (Interactive usage)
node=`echo $HOSTNAME | awk -F'.' '{print $1}'`


# Machine USED (job-exclusive usage)
#read -r node<$PBS_NODEFILE




############ Information about algorithm to run ################
alg="SOR_Improved"
exe="$HOME/NUMA_Aware_Thesis/java_codes/jar/SOR_Improved_sm.jar"
size=3
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
REP=1

# Array with all tests
declare -a TEST=("$DEFAULT" "$LOCAL_ACCESS" "$REMOTE_ACCESS")

# Project Folder
Project_DIR=`pwd`
#############################################################################


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#	COUNTERS INFO
#
# 0xf
# MEM_UNCORE_RETIRED - Load instructions retired (Precise Event)
#	0x02 : PMU : [LOCAL_HITM] : Load instructions retired that HIT modified data in sibling core 
#	0x08 : PMU : [LOCAL_DRAM_AND_REMOTE_CACHE_HIT] : Load instructions retired local dram and remote cache HIT data sources 
#	0x10 : PMU : [REMOTE_DRAM] : Load instructions retired remote DRAM and remote home-remote cache HITM 
#	0x04 : PMU : [REMOTE_HITM] : Retired loads that hit remote socket in modified state 
#	0x20 : PMU : [OTHER_LLC_MISS] : Load instructions retired other LLC miss 
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

	
	###### MEM_UNCORE_RETIRED (0xf) ###### 
	echo "Testing $name_test | MEM_UNCORE_RETIRED  ......." >> $OUTPUT_FILE
	echo >> $OUTPUT_FILE
	
	echo "0x02 : PMU : [LOCAL_HITM]" 			>> $OUTPUT_FILE
	perf stat -e r53020f:u -r $REP --output $OUTPUT_FILE --append $t &> /dev/null
	echo >> $OUTPUT_FILE 

	echo "0x08 : PMU : [LOCAL_DRAM_AND_REMOTE_CACHE_HIT]" 	>> $OUTPUT_FILE 
	perf stat -e r53080f:u -r $REP --output $OUTPUT_FILE --append $t &> /dev/null
	echo >> $OUTPUT_FILE

	echo "0x10 : PMU : [REMOTE_DRAM]" 			>> $OUTPUT_FILE 
	perf stat -e r53100f:u -r $REP --output $OUTPUT_FILE --append $t &> /dev/null
	echo >> $OUTPUT_FILE 

	echo "0x04 : PMU : [REMOTE_HITM]" 			>> $OUTPUT_FILE 
	perf stat -e r53040f:u -r $REP --output $OUTPUT_FILE --append $t &> /dev/null
	echo >> $OUTPUT_FILE 

	echo "0x20 : PMU : [OTHER_LLC_MISS]" 			>> $OUTPUT_FILE 
	perf stat -e r53200f:u -r $REP --output $OUTPUT_FILE --append $t &> /dev/null
	echo >> $OUTPUT_FILE
	

	# Organising info
	CSV="${name_test}_results.csv"
	ncounters=`grep -e "0x" $OUTPUT_FILE | wc -l`
	ncounters_results=`grep -e ":u" $OUTPUT_FILE | wc -l`
	
	if [ "$ncounters" -ne "$ncounters_results" ]; then
		ERROR_FLAG=1
		echo "Number of collected results different than number of counters. Wrong catched!"	
	else
		for ((i=1; i<=$ncounters; i++ ))
		do
			counter_i_name=`awk '/0x/' $OUTPUT_FILE | awk NR==$i`
			counter_i_RAWCode=`awk -F=' ' '/:u/' $OUTPUT_FILE | awk NR==$i | awk '{print $2}'`
			counter_i_result=`awk -F=' ' '/:u/' $OUTPUT_FILE | awk NR==$i | awk '{print $1}'`
			counter_i_stdDev=`awk -F=':u' '/:u/' $OUTPUT_FILE | awk NR==$i | awk '{ s = ""; for (i = 3; i <= NF; i++) s = s $i " "; print s }'`

			echo "$counter_i_name","$counter_i_RAWCode","$counter_i_result",$counter_i_stdDev >> "$Project_DIR/${alg}_DRAM_LOCAL_and_REMOTE_Counters_${hour}/$CSV"
		done
	fi
done


# Printing results
if [ $ERROR_FLAG -ne 1 ]; then
	CSV_DIR="$Project_DIR/${alg}_DRAM_LOCAL_and_REMOTE_Counters_${hour}"
	cd $CSV_DIR 
	for CSV in *.csv
	do
		echo "Results for $CSV in $CSV_DIR ......"
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
