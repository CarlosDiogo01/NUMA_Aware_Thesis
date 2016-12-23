#PBS -N VTune_Result_SOR_SM_Improved
#PBS -l walltime=02:00:00
#PBS -q mei

# PBS -m abe
# PBS -M carlos.sa01@gmail.com 

#PBS -l nodes=1:r662:ppn=48


#### SCRIPT FOR TESTING SOR IMPROVED - SHARED MEMORY VERSION ####

# Knowing wich machine is being used
read -r node_info<$PBS_NODEFILE

# Directories for PROJECT and VTune OUTPUT
Project_Folder="$HOME/ScholarShip_public/JGF/sor/Improved"
Vtune_output_dir="$HOME/NUMA_Aware_Thesis/java_codes/VTune_Tests/sor_SM_Improved_j8_$node_info"
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
# INTEL_LICENSE_FILE (contains the path to the .lic file with your license)"
env | grep INTEL
echo "DONE!"



# Go to Project Folder 
cd $Project_Folder

# Compile Java code
mkdir -p class_SM_j8
# seq
${Java_dir}/javac -g -d ./class_SM_j8 ./sm/*.java

# Creating Folder for Results
mkdir -p $Vtune_output_dir 
cd $Vtune_output_dir

# Collecting VTune Events for Size 5 and 24 Threads (Physical Cores Only!)
echo "Collecting HotSpots"
(>&2 echo "Collecting hotspots")
amplxe-cl -collect hotspots -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SM_j8/ sm.improved.JGFSORBenchSizeA -size 5 24
echo "Collecting Memory-access"
(>&2 echo "Collecting Memory_Acess")
amplxe-cl -collect memory-access -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SM_j8/ sm.improved.JGFSORBenchSizeA -size 5 24
(>&2 echo "Collecting advanced-hotspots")
amplxe-cl -collect advanced-hotspots -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SM_j8/ sm.improved.JGFSORBenchSizeA -size 5 24
echo "Collecting general-exploration"
(>&2 echo "Collecting general-exploration")
amplxe-cl -collect general-exploration -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SM_j8/ sm.improved.JGFSORBenchSizeA -size 5 24


# Clear class files
rm -rf ${Project_Folder}/class_SM_j8
