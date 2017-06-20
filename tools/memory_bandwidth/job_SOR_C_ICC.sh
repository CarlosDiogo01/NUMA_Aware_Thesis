#PBS -N STREAM_ICC
#PBS -l walltime=20:00:00
#PBS -q mei

#PBS -m abe
#PBS -M carlos.sa01@gmail.com 

#PBS -lnodes=1:r641:ppn=32


# Machine USED
read -r node_info<$PBS_NODEFILE



############ Folders ################
exe="`pwd`/exes"
outputfolder="`pwd`/output"
#####################################


######### Compiler options ##########
CC=gcc
CFLAGS="-O3 -ffreestanding"

module purge
module load gnu/5.3.0
####################################


########################## Tests configuration ###############################

# Number of threads
thread_bundle="1 2 4 8 10 12 16 24 32"

# Datasets in MB
datasets="15 2000 10000"

for size in $datasets
do 

# assuming each element double -> 8 bytes
stream_each_array_size_MB=$size
(( stream_each_array_nelems = (( $stream_each_array_size_MB * 1000000 )) / 8 ))

# in total Stream Benchmark uses 3 arrays
(( total_mem_required = (( $stream_each_array_size_MB * 3 )) ))

# number of repetitions for each execution
stream_rep_no=20
stream_exe="stream.omp.${stream_each_array_size_MB}MB.${stream_rep_no}x.$CC"


title="ARRAY_SIZE = $stream_each_array_size_MB MB | Total Mem = $total_mem_required MB"


# Making stream executables for the size
$CC $CFLAGS -fopenmp -D_OPENMP -DSTREAM_ARRAY_SIZE=$stream_each_array_nelems -DNTIMES=$stream_rep_no stream.c -o $stream_exe
mkdir -p $exe
mv stream.omp.* $exe


# Running stream executables
echo "${title}","LOCAL_ACCESS(MB/s)","REMOTE_ACCESS(MB/s)" >> "$outputfolder/${stream_each_array_size_MB}_MB/MemoryBandwidth.LOCAL.AND.REMOTE.Accesses.${stream_each_array_size_MB}_MB.csv"
for nthr in $thread_bundle 
do
	export OMP_NUM_THREADS=$nthr
	mkdir -p $outputfolder/${stream_each_array_size_MB}_MB/
	
	# Local Access
	numactl --cpunodebind 0 --membind 0 $exe/$stream_exe >> $outputfolder/${stream_each_array_size_MB}_MB/$stream_exe.$nthr.LOCAL_ACCESS.output
	best_rate_scale_local=`cat $outputfolder/${stream_each_array_size_MB}_MB/$stream_exe.$nthr.LOCAL_ACCESS.output | grep Scale | awk '{print $2}'`
	
	# Remote Access
	numactl --cpunodebind 0 --membind 1 $exe/$stream_exe >> $outputfolder/${stream_each_array_size_MB}_MB/$stream_exe.$nthr.REMOTE_ACCESS.output
	best_rate_scale_remote=`cat $outputfolder/${stream_each_array_size_MB}_MB/$stream_exe.$nthr.REMOTE_ACCESS.output | grep Scale | awk '{print $2}'`

	echo "$nthr.Threads","$best_rate_scale_local, $best_rate_scale_remote" >> "$outputfolder/${stream_each_array_size_MB}_MB/MemoryBandwidth.LOCAL.AND.REMOTE.Accesses.${stream_each_array_size_MB}_MB.csv"
done

done
