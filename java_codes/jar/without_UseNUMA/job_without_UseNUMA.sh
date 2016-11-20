maq="$1"
exe="$2"
FLAGS="-jar"
FICHEIRO="$1.$2.txt"
REP="10"
for size in 0 1 2 3 4 5
do
	echo "<ignore> size = $size" >> $FICHEIRO
   	echo "<ignore> size = $size"

	for thr in 2 4 8 16 24 32
	do
		echo "<ignore> thr = $thr" >> $FICHEIRO 
		echo "<ignore> thr = $thr"
		for((i = 0; i < $REP; i++))
		do
			/share/apps/java/jdk1.8.0_20/bin/java $FLAGS $exe -f $size $thr >> $FICHEIRO
		done
	done
done
