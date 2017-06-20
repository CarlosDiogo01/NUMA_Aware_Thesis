#PBS -N STREAM_ICC
#PBS -l walltime=20:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE


########################## Tests configuration ###############################
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
datasets="5 10000"
#############################################################################


if [-d "$exe"]
	rm -rf $exes
fi

if [-d "$outputfolder"]
	rm -rf $outputfolder
fi


for size in $datasets
do 

# in total Stream Benchmark uses 3 arrays
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


# Making stream executables for the size
$CC $CFLAGS -fopenmp -D_OPENMP -DSTREAM_ARRAY_SIZE=$stream_each_array_nelems -DNTIMES=$stream_rep_no stream.c -o $stream_exe
mkdir -p $exe
mv stream.omp* $exe


# Running stream executables
mkdir -p $outputfolder/${total_mem_required}_MB/
echo "${total_mem_required}_MB","LOCAL_ACCESS(MB/s)","REMOTE_ACCESS(MB/s)" >> "$outputfolder/${total_mem_required}_MB/MemoryBandwidth.LOCAL.AND.REMOTE.Accesses.${total_mem_required}_MB.csv"
for nthr in $thread_bundle 
do
	export OMP_NUM_THREADS=$nthr
	
	# Local Memory Access
	numactl --cpunodebind 0 --membind 0 $exe/$stream_exe >> $outputfolder/${total_mem_required}_MB/$stream_exe.$nthr.LOCAL_ACCESS.output
	best_rate_scale_local=`cat $outputfolder/${total_mem_required}_MB/$stream_exe.$nthr.LOCAL_ACCESS.output | grep Scale | awk '{print $2}'`
	
	# Remote Memory Access
	numactl --cpunodebind 0 --membind 1 $exe/$stream_exe >> $outputfolder/${total_mem_required}_MB/$stream_exe.$nthr.REMOTE_ACCESS.output
	best_rate_scale_remote=`cat $outputfolder/${total_mem_required}_MB/$stream_exe.$nthr.REMOTE_ACCESS.output | grep Scale | awk '{print $2}'`

	echo "$nthr.Threads","$best_rate_scale_local","$best_rate_scale_remote" >> "$outputfolder/${total_mem_required}_MB/MemoryBandwidth.LOCAL.AND.REMOTE.Accesses.${total_mem_required}_MB.csv"
done

mv $outputfolder/${total_mem_required}_MB/MemoryBandwidth.LOCAL.AND.REMOTE.Accesses.${total_mem_required}_MB.csv $outputfolder
done
