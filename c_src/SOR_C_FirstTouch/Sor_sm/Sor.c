#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <time.h>
#include "Sor.h"

void run (int size, int validation, int num_threads){
    
    const int datasizes[]={1000, 1500, 2000, 5000, 10000, 20000};
    Sor *sor = malloc(sizeof(Sor));
    sor->size = size;
    sor->M = sor->N = datasizes[size];
    
    /** Explicitly disable dynamic teams **/
    omp_set_dynamic(0);      
    /** Use N threads for all parallel regions **/
    omp_set_num_threads(num_threads); 
   
    JGFinitialise   (sor);
   
    JGFKernel       (sor, num_threads);
    
    if(validation)
    {
        JGFvalidate(sor->Gtotal, sor->size);
    }

    free(sor);

}

void JGFinitialise(Sor *sor){
    
    sor->JACOBI_NUM_ITER    = 100;
    sor->RANDOM_SEED        = 10101010; 
    sor->ops = 6 * sor->size * sor->size * sor->JACOBI_NUM_ITER;
    
    srand(sor->RANDOM_SEED);
}


void RandomMatrix(int M, int N, double G [M][N]){

    for (int i = 0; i < N; i++)
    {
        for (int j = 0; j < N; j++)
        {
            G[i][j] = (((double)rand()/(double)RAND_MAX)) * 1e-6;
        }     
    }
}

void JGFKernel(Sor *sor, int total_threads){
    
    volatile long sync[total_threads][CACHELINE];
    double (*G) [sor->N] = malloc(sizeof *G * sor->M);
    RandomMatrix(sor->M, sor->N, G);
    
    
    for(int i = 0; i < total_threads; i++)
    {
        for(int j = 0; j < CACHELINE; j++)
        {
            sync[i][j] = 0;
        }
    }
    
    
    const double start  = omp_get_wtime();
    
    #pragma omp parallel
    {
        sor_simulation (1.25, sor->M, sor->N, G, sor->JACOBI_NUM_ITER, 
                        total_threads, sync);
    }
    const double end    = omp_get_wtime();
    printf("%f\n", (end - start));
    
    double Gtotal = 0;
    
    for (int i = 1; i < sor->M-1; i++) 
    {
        for (int j = 1; j < sor->N-1; j++) 
        {
            Gtotal += G[i][j];
        }
    }
    sor->Gtotal = Gtotal;
            
    free(G);
}

void sor_simulation (double omega, int M, int N, 
        double G[M][N], int num_iterations, 
        int total_threads, volatile long sync[total_threads][CACHELINE]) {

    int id_thread =  omp_get_thread_num();
    double omega_over_four = omega * 0.25;
    double one_minus_omega = 1.0 - omega;

    int Mm1 = M-1;
    int Nm1 = N-1;
    int num_iterations_2 = 2 * num_iterations;

    for (int p = 0; p < num_iterations_2; p++)
    {
        #pragma omp for nowait
        for (int i = (p%2) + 1; i < Mm1+1; i+=2) 
        {
            double *Gi = G[i];
            double *Gim1 = G[i-1];
            
            if(i == 1) 
            { 
                double *Gip1 = G[i+1];
                for (int j = 1; j < Nm1; j += 2)
                { 
                    Gi[j] = omega_over_four * (Gim1[j] + Gip1[j] + Gi[j-1]
                            + Gi[j+1]) + one_minus_omega * Gi[j];
                }
            } 
            else if (i == Mm1) 
            {
                double *Gim2 = G[i-2];
                
                for (int j = 1; j < Nm1; j += 2)
                {
                    if((j+1) != Nm1) 
                    {
                        Gim1[j+1] = omega_over_four * 
                                (Gim2[j+1] + Gi[j+1] + Gim1[j] + Gim1[j+2]) 
                                + one_minus_omega * Gim1[j+1];
                    }
                }
            } 
            else 
            {
                double *Gip1 = G[i+1];
                double *Gim2 = G[i-2];
                
                for (int j = 1; j < Nm1; j += 2)
                {
                    Gi[j] = omega_over_four * 
                            (Gim1[j] + Gip1[j] + Gi[j-1] + Gi[j+1]) 
                            + one_minus_omega * Gi[j];

                    if((j+1) != Nm1) 
                    {
                        Gim1[j+1] = omega_over_four * 
                                    (Gim2[j+1] + Gi[j+1] + Gim1[j] + Gim1[j+2]) 
                                    + one_minus_omega * Gim1[j+1];
                    }
                }
            }
        }
        
        // Signal this thread has done iteration
        sync[id_thread][0]++;

        // Wait for neighbours
        if (id_thread > 0) {
            while (sync[id_thread-1][0] < sync[id_thread][0]) ;
        }
        if (id_thread < total_threads -1) {
            while (sync[id_thread+1][0] < sync[id_thread][0]) ;
	}
   
    }
}


int abs_            (int value)     {return (value > 0) ? value : -value;}
double abs_double   (double value)  {return (value > 0) ? value : -value;}


void JGFvalidate(double Gtotal, int size){
   
    double refval[] = {0.4980286235707718, 1.1200980290730285, 1.9980973961615818};
    double dev = abs_double(Gtotal - refval[size]);
    if (dev > 1.0e-12 )
    {
        printf("Validation failed\n");
        printf("Gtotal = %.16f %.16f %d\n",Gtotal, dev ,size);
    }
}
