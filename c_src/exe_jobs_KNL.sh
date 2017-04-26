############ JOBS to run in KNL ################

echo "Start executing jobs on KNL....."


	echo "Executing JOB1" 
		sh /home/a59905/NUMA_Aware_Thesis/c_src/__jobs_SOR_Original/KNL/exeKNL_SOR_C_Original_TimeTest_GCC.sh
		sh /home/a59905/NUMA_Aware_Thesis/c_src/__jobs_SOR_Original/KNL/exeKNL_SOR_C_Original_TimeTest_ICC.sh

	echo "Executing JOB2"		
		sh /home/a59905/NUMA_Aware_Thesis/c_src/__jobs_SOR_FirstTouch/KNL/exeKNL_SOR_C_1Alloc_TimeTest_GCC.sh
		sh /home/a59905/NUMA_Aware_Thesis/c_src/__jobs_SOR_FirstTouch/KNL/exeKNL_SOR_C_1Alloc_TimeTest_ICC.sh



	echo ".....done!"

echo "DONE EXECUTING on KNL.........."
