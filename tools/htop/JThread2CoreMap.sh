# JThread2Core Map V1.0

# @author CarlosDiogo01
# https://github.com/CarlosDiogo01

clear

echo -e "\t\t JThread2Core Map V1.0"

# htop used (Change it if you're using another version!)
version_htop=2.0.2

# htop location
htop_folder=`pwd`
htop_path=$htop_folder/htop-$version_htop


# lstopo
lstopo --output-format png -v --no-io > "machine_arch_img.png"
lstopo --output-format txt -v --no-io > "machine_arch_img_txt.txt"


pids_java=(`pgrep java`)
total_java_pids=${#pids_java[@]}

if [ "$total_java_pids" -lt 1 ]; then
	echo ""
	echo "******* Oops! No Java programs running to monitor! ********"

elif [ "$total_java_pids" -eq 1 ]; then
	chosen_pid=${pids_java[0]}

# More than one Java program running at time
elif [ "$total_java_pids" -gt 1 ]; then
	echo ""
	echo "You're running more than 1 Java app!"
	echo ""
	
	echo "PIDs of Java programs running:"
	for (( i=0; i<=$total_java_pids; i++ ))
	do
		echo "${pids_java[$i]}" 
	done
	echo ""
	
	echo "Wich PID you want to monitor?"
	read chosen_pid	
fi

# Executing jstack
jstack $chosen_pid >> thread_dump_jstack_PID_$chosen_pid.dump

# Executing htop
cd $htop_path	
./htop -p $chosen_pid
