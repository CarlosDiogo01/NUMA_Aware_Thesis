#PBS -N result_sor_seq_Improved
#PBS -l walltime=00:05:00
#PBS -q mei

# PBS -m abe
# PBS -M carlos.sa01@gmail.com 

#PBS -l nodes=1:r662:ppn=48


#### SCRIPT FOR TESTING SOR IMPROVED - SEQUENTIAL VERSION ####


# Knowing wich machine is being used
read -r node_info<$PBS_NODEFILE

# Directories for PROJECT and VTUNE OUTPUT 
Project_Folder="/home/a59905/ScholarShip_public/JGF/sor/Improved"
Vtune_output_dir="/home/a59905/NUMA_Aware_Thesis/java_codes/VTune_Tests/sor_SEQ_Improved_j8_$node_info"
# Java Dir 
Java_dir="/share/apps/java/jdk1.8.0_20/bin/"


# Preparing Environment for VTune
source /share/apps/intel/vtune_amplifier_xe_2017/amplxe-vars.sh
source /share/apps/intel/vtune_amplifier_xe_2017/sep_vars.sh

# Go to Project Folder
cd $Project_Folder

# Compile Java code
mkdir -p class_SEQ_j8
# seq
${Java_dir}/javac -g -d ./class_SEQ_j8 ./seq_sm/*.java

# Creating Folder for Results
mkdir -p $Vtune_output_dir 
cd $Vtune_output_dir

# Collecting VTune Events for Size 5 (Physical Cores Only!)
echo "Collecting HotSpots"
(>&2 echo "Collecting hotspots")
amplxe-cl -collect hotspots -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SEQ_j8/ seq_sm.improved.JGFSORBenchSizeA -size 5
echo "Collecting Memory-access"
(>&2 echo "Collecting Memory_Acess")
amplxe-cl -collect memory-access -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SEQ_j8/ seq_sm.improved.JGFSORBenchSizeA -size 5
(>&2 echo "Collecting advanced-hotspots")
amplxe-cl -collect advanced-hotspots -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SEQ_j8/ seq_sm.improved.JGFSORBenchSizeA -size 5
echo "Collecting general-exploration"
(>&2 echo "Collecting general-exploration")
amplxe-cl -collect general-exploration -- ${Java_dir}/java -Xcomp -Djava.library.path=native_lib/ia32 -cp ${Project_Folder}/class_SEQ_j8/ seq_sm.improved.JGFSORBenchSizeA -size 5


# Clear class files
rm -rf ${Project_Folder}/class_SEQ_j8
