#include "mpi.h"
#include "functions_mpi.h"
#include <stdio.h>

// Get process id
int getProcessId(){
    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    return rank;
}

// Get number of process
int numberProcess(){
    int numProc;
    MPI_Comm_size(MPI_COMM_WORLD, &numProc);
    return numProc;
}

// finding the master process
int master(){
    int rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    return (rank == 0);
}