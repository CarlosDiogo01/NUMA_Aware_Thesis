CC = gcc
CFLAGS = -O3

all: stream.c 
	${CC} ${CFLAGS} -fopenmp -D_OPENMP -DSTREAM_ARRAY_SIZE=80000000 -DNTIMES=20 stream.c -o stream.omp.AVX2.80M.20x.gcc

clean:
	rm -f *.gcc *.o
