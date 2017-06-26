# JThread2Core Map V1.0

# @author CarlosDiogo01
# https://github.com/CarlosDiogo01


# htop used
htop=htop-2.0.2.tar.gz
version=2.0.2

echo "Downloading $htop........"
	wget http://hisham.hm/htop/releases/$version/$htop
	echo ""

echo "Unpacking htop ........"
	tar xvf $htop
	echo ""

echo "Configuring $htop ....."
	cd ${htop%.tar.gz}
	./configure

echo ""
echo "Making ${htop%.tar.gz}......."
	sleep 5
	make
	echo ""
	
echo "Do you have ROOT permissions on this machine ? [Yes/No] :"
read answer
if [ $answer == "Yes" ] || [ $answer == "YES" ] || [ $answer == "yes" ] || [ $answer == "Y" ] || [ $answer == "y" ]; then
	sudo make install
	echo ""
elif [ $answer == "No" ] || [ $answer == "NO" ] || [ $answer == "no" ] || [ $answer == "N" ] || [ $answer == "n" ]; then
	echo ""
	echo "htop NOT INSTALLED but you're able to use it with JThread2Core Map script anyway." 
	echo ""
	echo "You're good to run your program with JThread2CoreMap.sh script now!"
	echo ""
fi
