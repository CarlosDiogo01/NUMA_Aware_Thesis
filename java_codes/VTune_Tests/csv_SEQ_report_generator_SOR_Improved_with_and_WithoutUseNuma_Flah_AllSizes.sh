#PBS -N VTune_SOR_SEQ_Improved_Export_CSV
#PBS -l walltime=02:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -l nodes=1:r662:ppn=4


#### SCRIPT FOR ORGANIZE VTUNE RESULTS IN A CSV FILE SOR IMPROVED - SEQUENTIAL VERSION ####

# Knowing wich machine is being used
read -r node_info<$PBS_NODEFILE

VTune_output_dir="$HOME/NUMA_Aware_Thesis/java_codes/VTune_Tests/"
# Java Dir 
Java_dir="/share/apps/java/jdk1.8.0_20/bin/"

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
	# Organize CSV results to SOR SEQ improved Use_NUMA_Flag 
	cd "sor_SEQ_Improved_j8_UseNumaFlag_*/Size_$size"
	
	(>&2 echo "**** START collect profile for SOR SEQ IMPROVED WITH -XX:+UseNuma Flag SIZE $size ******")

	# Generate CSV for hotspots
	(>&2 echo "Generate Hotspots CSV for Size_$size")
	amplxe-cl -R hotspots -report-output SOR_SEQ_UseNuma_Flag_hotspots_$node_info.csv -format csv -csv-delimiter comma
	echo ""

	#Generate CSV for Memory Access 
	(>&2 echo "Generate Memory Access CSV for Size_$size")
	amplxe-cl -R memory-access -report-output SOR_SEQ_UseNuma_Flag_memory_access_$node_info.csv -format csv -csv-delimiter comma
	echo ""

	#Generate CSV for Advanced-hostposts	
	(>&2 echo "Generate Advanced Hotspots CSV for Size_$size")
	amplxe-cl -R advanced-hotspots -report-output SOR_SEQ_UseNuma_Flag_advanced_hotspots_$node_info.csv -format csv -csv-delimiter comma
	echo ""

	#Generate CSV for General-Exploration 
	(>&2 echo "Generate General-Hotspots CSV for Size_$size")
	amplxe-cl -R general-exploration -report-output SOR_SEQ_UseNuma_Flag_general_exploration_$node_info.csv -format csv -csv-delimiter comma
	echo ""

	(>&2 echo "**** END CSV gen profile for SOR SEQ IMPROVED WITH -XX:+UseNuma Flag SIZE $size ******")
	


	cd ..
	


	# Organize CSV results to SOR SEQ improved WITHOUT Use_NUMA_Flag 
	cd "sor_SEQ_Improved_j8_WithoutUseNumaFlag_*/Size_$size"

	(>&2 echo "**** START collect profile for SOR SEQ IMPROVED WITHOUT -XX:+UseNuma Flag SIZE $size ******")

        # Generate CSV for hotspots
        (>&2 echo "Generate Hotspots CSV for Size_$size")
        amplxe-cl -R hotspots -report-output SOR_SEQ_UseNuma_Flag_hotspots_$node_info.csv -format csv -csv-delimiter comma
        echo ""

        #Generate CSV for Memory Access 
        (>&2 echo "Generate Memory Access CSV for Size_$size")
        amplxe-cl -R memory-access -report-output SOR_SEQ_UseNuma_Flag_memory_access_$node_info.csv -format csv -csv-delimiter comma
        echo ""

        #Generate CSV for Advanced-hostposts    
        (>&2 echo "Generate Advanced Hotspots CSV for Size_$size")
        amplxe-cl -R advanced-hotspots -report-output SOR_SEQ_UseNuma_Flag_advanced_hotspots_$node_info.csv -format csv -csv-delimiter comma
        echo ""

        #Generate CSV for General-Exploration 
        (>&2 echo "Generate General-Hotspots CSV for Size_$size")
        amplxe-cl -R general-exploration -report-output SOR_SEQ_UseNuma_Flag_general_exploration_$node_info.csv -format csv -csv-delimiter comma
        echo ""

        (>&2 echo "**** END CSV gen profile for SOR SEQ IMPROVED WITHOUT -XX:+UseNuma Flag for SIZE $size ******")
done
