#PBS -N VTune_SOR_SEQ_Improved_WithoutUseNUMA
#PBS -l walltime=02:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -l nodes=1:r662:ppn=48


#### SCRIPT FOR TESTING SOR IMPROVED - SEQUENTIAL VERSION ####

# Knowing wich machine is being used
read -r node_info<$PBS_NODEFILE

Project_Folder="$HOME/ScholarShip_public/JGF/sor/Improved"
VTune_output_dir="$HOME/NUMA_Aware_Thesis/java_codes/VTune_Tests/sor_SEQ_Improved_j8_WithoutUseNumaFlag_$node_info"
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
cd $Project_Folder

# Compile Java code
mkdir -p class_SEQ_j8
# sm
${Java_dir}/javac -g -d ./class_SEQ_j8 ./seq_sm/*.java


for size in 0 1 2 3 4 5
do
	# Creating Folder for Results of a given SIZE
	mkdir -p ${VTune_output_dir}/Size_$size/
	cd $VTune_output_dir/Size_$size/
	
	echo ""
	
	echo "**** START COLLECT ALL EVENTS FOR SIZE $size ******"
	# Collecting VTune Events for $size
	echo "Collecting HotSpots"
	(>&2 echo "Collecting hotspots")
	amplxe-cl -collect hotspots -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SEQ_j8/ seq_sm.improved.JGFSORBenchSizeA -size $size

	echo ""

	echo "Collecting Memory-access"
	(>&2 echo "Collecting Memory_Acess")
	amplxe-cl -collect memory-access -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SEQ_j8/ seq_sm.improved.JGFSORBenchSizeA -size $size

	echo ""

	echo "Collecting Advanced-Hotspots"
	(>&2 echo "Collecting advanced-hotspots")
	amplxe-cl -collect advanced-hotspots -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SEQ_j8/ seq_sm.improved.JGFSORBenchSizeA -size $size

	echo ""

	echo "Collecting general-exploration"
	(>&2 echo "Collecting general-exploration")
	amplxe-cl -collect general-exploration -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SEQ_j8/ seq_sm.improved.JGFSORBenchSizeA -size $size
	
	echo ""
	
	echo "**** END COLLECT ALL EVENTS FOR SIZE $size ******"

	cd ..
done

mv VTune_SOR_SEQ_Improved_WithoutUseNUMA* sor_SEQ_Improved_j8_WithoutUseNumaFlag_$node_info/

# Clear class files
rm -rf ${Project_Folder}/class_SEQ_j8
