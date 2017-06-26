#PBS -N STREAM_GCC
#PBS -l walltime=20:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE


########################## Test configuration ###############################
STREAM_FOLDER=$HOME/NUMA_Aware_Thesis/tools/memory_bandwidth
cd $STREAM_FOLDER

exe="`pwd`/exes"
outputfolder="`pwd`/output"

# Compiler options
module purge
module load gnu/5.3.0
CC=gcc
# -mcmodel flag necessary to test with large datasets
CFLAGS="-O3 -mcmodel=medium -ffreestanding"


# Number of threads
thread_bundle="1 2 4 8 10 12 16 24 32"

# Datasets in MB
datasets="16 300 10000 25000"
#############################################################################


# Remove to a clean test
if [ -d "$exe" ]; then
	rm -rf $exe
fi

if [ -d "$outputfolder" ]; then
	rm -rf "$outputfolder"
fi



for size in $datasets
do 

# Stream Benchmark uses 3 arrays
(( stream_each_array_size_MB = (( $size / 3 )) ))

# assuming each element double -> 8 bytes
(( stream_each_array_nelems = (( $stream_each_array_size_MB * 1000000 )) / 8 ))

# Total memory required
total_mem_required=$size

# number of repetitions for each execution
stream_rep_no=15

# executable name
stream_exe="stream.omp.${total_mem_required}MB.${stream_rep_no}x.$CC"


# each test
echo "ARRAY_SIZE = $stream_each_array_nelems elems | Total Mem = 3x$stream_each_array_size_MB -> $total_mem_required MB"


# Creating stream executables for the size
$CC $CFLAGS -fopenmp -D_OPENMP -DSTREAM_ARRAY_SIZE=$stream_each_array_nelems -DNTIMES=$stream_rep_no stream.c -o $stream_exe
mkdir -p $exe
mv stream.omp* $exe


# Running stream executables
mkdir -p $outputfolder/${total_mem_required}_MB/
echo "${total_mem_required}_MB","LOCAL_ACCESS(MB/s)","REMOTE_ACCESS(MB/s)","INTERLEAVE_ACCESS(MB/s)" >> "$outputfolder/${total_mem_required}_MB/MemoryBandwidth.LOCAL.AND.REMOTE.AND.INTERLEAVE.Accesses.${total_mem_required}_MB.csv"
for nthr in $thread_bundle 
do
	export OMP_NUM_THREADS=$nthr
	
	# Local Memory Access
	numactl --cpunodebind=0 --membind=0 $exe/$stream_exe >> $outputfolder/${total_mem_required}_MB/$stream_exe.$nthr.LOCAL_ACCESS.output
	best_rate_scale_local=`cat $outputfolder/${total_mem_required}_MB/$stream_exe.$nthr.LOCAL_ACCESS.output | grep Scale | awk '{print $2}'`
	
	# Remote Memory Access
	numactl --cpunodebind=0 --membind=1 $exe/$stream_exe >> $outputfolder/${total_mem_required}_MB/$stream_exe.$nthr.REMOTE_ACCESS.output
	best_rate_scale_remote=`cat $outputfolder/${total_mem_required}_MB/$stream_exe.$nthr.REMOTE_ACCESS.output | grep Scale | awk '{print $2}'`

	# Interleave Memory Access
	numactl --interleave=all $exe/$stream_exe >> $outputfolder/${total_mem_required}_MB/$stream_exe.$nthr.INTERLEAVE.output
        best_rate_scale_interleave=`cat $outputfolder/${total_mem_required}_MB/$stream_exe.$nthr.INTERLEAVE.output | grep Scale | awk '{print $2}'`


	echo "$nthr.Threads","$best_rate_scale_local","$best_rate_scale_remote","$best_rate_scale_interleave" >> "$outputfolder/${total_mem_required}_MB/MemoryBandwidth.LOCAL.AND.REMOTE.AND.INTERLEAVE.Accesses.${total_mem_required}_MB.csv"
done

mv $outputfolder/${total_mem_required}_MB/MemoryBandwidth.LOCAL.AND.REMOTE.AND.INTERLEAVE.Accesses.${total_mem_required}_MB.csv $outputfolder

echo "CSV file with Memory Bandwidth data generated inside $outputfolder "
done
