#PBS -N VTune_SOR_SM_Improved_Export_CSV
#PBS -l walltime=02:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -l nodes=1:r662:ppn=8


#### SCRIPT FOR ORGANIZE VTUNE RESULTS IN A CSV FILE SOR IMPROVED - SHARED MEMORY VERSION ####

# Knowing wich machine is being used
read -r node_info<$PBS_NODEFILE

VTune_output_dir="$HOME/NUMA_Aware_Thesis/java_codes/VTune_Tests"
# Java Dir 
Java_dir="/share/apps/java/jdk1.8.0_20/bin/"

MACHINE_WHERE_TESTS_RUNNED="compute-662-6"

# Preparing environment for Parallel Studio XE 2016
echo "Loading Parallel Studio XE 2016 ..." 
COMPILERS_AND_LIBRARIES_FOLDER="/share/apps/intel"
source ${COMPILERS_AND_LIBRARIES_FOLDER}/compilers_and_libraries_2016/linux/bin/compilervars.sh intel64
source ${COMPILERS_AND_LIBRARIES_FOLDER}/vtune_amplifier_xe_2017/amplxe-vars.sh
source ${COMPILERS_AND_LIBRARIES_FOLDER}/vtune_amplifier_xe_2017/sep_vars.sh

#If you need Intel MKL
source ${COMPILERS_AND_LIBRARIES_FOLDER}/compilers_and_libraries_2016/linux/mkl/bin/mklvars.sh intel64

echo "You have your license correctly loaded if you have these environment variables:
 INTEL_LICENSE_FILE (contains the path to the .lic file with your license)"
env | grep INTEL
echo "DONE!"

# Go to Project Folder
cd ${VTune_output_dir}

for size in 0 1 2 3 4 5
do
	# Organize CSV results to SOR SM improved Use_NUMA_Flag 
	cd "sor_SM_Improved_j8_UseNumaFlag_${MACHINE_WHERE_TESTS_RUNNED}/Size_$size"
	
	(>&2 echo "**** START collect profile for SOR SM IMPROVED WITH -XX:+UseNuma Flag SIZE $size ******")

	# Generate CSV for summary
	(>&2 echo "Generate Summary CSV for Size_$size")
	amplxe-cl -R summary -report-output SOR_SM_UseNuma_Flag_summary_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
	echo ""

	# Generate CSV for hotspots: Display CPU time.
	(>&2 echo "Generate Hotspots CSV for Size_$size")
	amplxe-cl -R hotspots -report-output SOR_SM_UseNuma_Flag_hotspots_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
	echo ""
	
	# Generate CSV for hw-events: Display hardware events
	(>&2 echo "Generate hw-events CSV for Size_$size")
	amplxe-cl -R hw-events -report-output SOR_SM_UseNuma_Flag_hw-events_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
	echo ""

	# Generate CSV for top-down: Display a call tree for your target application and provide CPU and wait time for each function.
	(>&2 echo "Generate top-down CSV for Size_$size")
	amplxe-cl -R top-down -report-output SOR_SM_UseNuma_Flag_top-down_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
	echo ""

	# Generate CSV for gprof-cc: Display CPU or wait time in the gprof-like format.
	(>&2 echo "Generate gprof-cc format CSV for Size_$size")
	amplxe-cl -R gprof-cc -report-output SOR_SM_UseNuma_Flag_gprof_cc_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
	echo ""

	# Generate CSV for callstacks:  Display CPU or wait time for callstacks
	(>&2 echo "Generate calstacks CSV for Size_$size")
	amplxe-cl -R callstacks -report-output SOR_SM_UseNuma_Flag_callstacks_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
	echo ""

	(>&2 echo "**** END CSV gen profile for SOR SM IMPROVED WITH -XX:+UseNuma Flag SIZE $size ******")


	cd ${VTune_output_dir}


	# Organize CSV results to SOR SM improved WITHOUT Use_NUMA_Flag 
	cd "sor_SM_Improved_j8_Without_UseNUMA_Fag_AllSizes_${MACHINE_WHERE_TESTS_RUNNED}/Size_$size"
	
	(>&2 echo "**** START collect profile for SOR SM IMPROVED WITHOUT -XX:+UseNuma Flag SIZE $size ******")

	# Generate CSV for summary
        (>&2 echo "Generate Summary CSV for Size_$size")
        amplxe-cl -R summary -report-output SOR_SM_WithoutUseNumaFlag_summary_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
        echo ""

        # Generate CSV for hotspots: Display CPU time.
        (>&2 echo "Generate Hotspots CSV for Size_$size")
        amplxe-cl -R hotspots -report-output SOR_SM_WithoutUseNumaFlag_hotspots_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
        echo ""

        # Generate CSV for hw-events: Display hardware events
        (>&2 echo "Generate hw-events CSV for Size_$size")
        amplxe-cl -R hw-events -report-output SOR_SM_WithoutUseNumaFlag_hw-events_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
        echo ""

        # Generate CSV for top-down: Display a call tree for your target application and provide CPU and wait time for each function.
        (>&2 echo "Generate top-down CSV for Size_$size")
        amplxe-cl -R top-down -report-output SOR_SM_WithoutUseNumaFlag_top-down_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
        echo ""

        # Generate CSV for gprof-cc: Display CPU or wait time in the gprof-like format.
        (>&2 echo "Generate gprof-cc format CSV for Size_$size")
        amplxe-cl -R gprof-cc -report-output SOR_SM_WithoutUseNumaFlag_gprof_cc_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
        echo ""

        # Generate CSV for callstacks:  Display CPU or wait time for callstacks
        (>&2 echo "Generate calstacks CSV for Size_$size")
        amplxe-cl -R callstacks -report-output SOR_SM_WithoutUseNumaFlag_callstacks_${MACHINE_WHERE_TESTS_RUNNED}.csv -format csv -csv-delimiter comma
        echo ""

        (>&2 echo "**** END CSV gen profile for SOR SM IMPROVED WITHOUT -XX:+UseNuma Flag for SIZE $size ******")

	cd ${VTune_output_dir}

done


# Difference between Without flag VS With -XX:+UseNUMA flag
for size in 0 1 2 3 4 5
do
	#SM (without flag VS With -XX:+UseNUMA flag)

	#Hotspots
	amplxe-cl -report hotspots -r "$VTune_output_dir/sor_SM_Improved_j8_Without_UseNUMA_Fag_AllSizes_${MACHINE_WHERE_TESTS_RUNNED}/Size_$size/r000hs" -r "$VTune_output_dir/sor_SM_Improved_j8_UseNumaFlag_${MACHINE_WHERE_TESTS_RUNNED}/Size_$size/r000hs" -report-output sor_SM_Without_VS_With_UseNUMA_hotspots_Size_$size.csv -format csv -csv-delimiter comma

	#hw-events
	amplxe-cl -report hotspots -r "$VTune_output_dir/sor_SM_Improved_j8_Without_UseNUMA_Fag_AllSizes_${MACHINE_WHERE_TESTS_RUNNED}/Size_$size/r001macc" -r "$VTune_output_dir/sor_SM_Improved_j8_UseNumaFlag_${MACHINE_WHERE_TESTS_RUNNED}/Size_$size/r001macc" -report-output sor_SM_Without_VS_With_UseNUMA_hw-events_Size_$size.csv -format csv -csv-delimiter comma
done

cd ${VTune_output_dir}
mkdir sor_SM_Improved_j8_Without_VS_UseNUMA_AllSizes
mv *.csv sor_SM_Improved_j8_Without_VS_UseNUMA_AllSizes
