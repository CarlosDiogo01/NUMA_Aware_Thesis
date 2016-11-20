#!/bin/bash

sample_size=4


# Files in the directory should have filename as: 'Crypt_Original_MT_size_3_32.jar'

for file in Crypt_Original_MT_* 
do
	SIZE=`echo $file | awk -F'[_.]' '{print $5}'`
	NTHREADS=`echo $file | awk -F'[_.]' '{print $6}'`
	
	echo "Crypt Size: $SIZE #Threads: $NTHREADS" 
	for (( sample_num=1; sample_num <= $sample_size; ++sample_num ))
	do
		/share/apps/java/jdk1.8.0_20/bin/java -jar $file	
		sleep 3
	done
done
