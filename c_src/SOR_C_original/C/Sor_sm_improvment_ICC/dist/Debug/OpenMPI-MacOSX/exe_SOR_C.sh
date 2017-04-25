
########################## Tests configuration ###############################
dataset="5"
thread_bundle="1 2 4 8 10 12 16 24 32"
REP=3
##############################################################################




################## External LIBS and Tools Configuration #####################
module purge

# GCC
module load gnu/5.3.0
#############################################################################



############################### Tests ######################################
test1="SOR_Without_FirstTouch"
exe1="$HOME/NUMA_Aware_Thesis/c_src/SOR_C_original/C/Sor_sm_improvment/dist/Debug/OpenMPI-MacOSX/sor_sm_improvment"

test2="SOR_FirstTouch"
exe2="$HOME/NUMA_Aware_Thesis/c_src/SOR_C_FirstTouch/Sor_sm_improvment/dist/Debug/OpenMPI-MacOSX/sor_sm_improvment"
############################################################################

for size in $dataset
do
	echo "***** Size $size ******"
	echo "SOR_FirstTouch"
        for thr in $thread_bundle
        do
		echo "$thr Threads"
                for ((i = 0; i < $REP; i++))
                do
			$exe2 -5 $size $thr
                done
        done
done

for size in $dataset
do
echo "***** Size $size ******"
	echo "SOR_Without_FirstTouch"
        for thr in $thread_bundle
	do
		echo "$thr Threads"
                for ((i = 0; i < $REP; i++))
                do
                        $exe1 -5 $size $thr
		done
	done
done
