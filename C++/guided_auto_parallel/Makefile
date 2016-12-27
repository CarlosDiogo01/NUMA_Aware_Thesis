CC=icpc
CFLAGS = -O2 
CFLAGS_GAP_VEC = -guide
CFLAGS_GAP_PAR = -guide -parallel
CFLAGS_VEC_PAR_REPORT = -vec-report1 -par-report1 -DTEST_GAP 
GAP_VEC_PAR_REPORT = -vec-report1 -par-report1 -DTEST_GAP 
CFLAGS_VEC_PAR_REPORT = -vec-report2 -par-report2 



default : main.o scalar_dep.o
	icpc main.o scalar_dep.o -parallel -o default

main.o : main.cpp
	 $(CC) -c $ main.cpp 

scalar_dep.o : scalar_dep.cpp
	$(CC) -c $(CFLAGS_VEC_PAR_REPORT) -parallel scalar_dep.cpp 

gap_vec_report : scalar_dep.ov

main.ov : main.cpp
	$(CC) -c  main.cpp 

scalar_dep.ov: scalar_dep.cpp
	$(CC) -c $(CFLAGS_GAP_VEC) scalar_dep.cpp


gap_par_report : scalar_dep.op

main.op : main.cpp
	$(CC) -c $ main.cpp 

scalar_dep.op : scalar_dep.cpp
	$(CC) -c $(CFLAGS_GAP_PAR) scalar_dep.cpp


final : main.of scalar_dep.of
	icpc main.o scalar_dep.o -parallel  -o final

main.of : main.cpp
	 $(CC) -c $ main.cpp 

scalar_dep.of : scalar_dep.cpp
	$(CC) -c $(GAP_VEC_PAR_REPORT) -parallel -DTEST_GAP scalar_dep.cpp


clean:
	rm *.o default final
