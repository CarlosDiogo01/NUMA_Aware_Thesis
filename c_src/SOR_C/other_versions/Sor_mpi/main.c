/* 
 * File:   main.c
 * Author: Bruno Medeiros
 *
 * Created on 20 de Outubro de 2016, 15:57
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Sor.h"
#include <mpi.h>

/**
 * This version is an improvement over the original SOR version.
 */

int main(int argc, char** argv) {
    
    /* Initialize MPI */
    MPI_Init(&argc, &argv);
    
    // If the user wants to validate the simulation 
    int validation  = (argc > 1) ? (strcmp(argv[1],"-v") == 0) :1;	
    int size        = (argc > 2) ? atoi(argv[2]) : 0;   // dim problem
    
    run(size, validation);
    
     /* Finalize MPI */
     MPI_Finalize();
    
    return (EXIT_SUCCESS);
}

