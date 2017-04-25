#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <time.h>
#include "Sor.h"

void run (int size, int validation, int num_threads){
    
    const int datasizes[]={1000, 1500, 2000, 5000, 10000, 15000};
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

    /* !Initialization of G on RandomMatrix (MASTER Thread!) */
    RandomMatrix(sor->M, sor->N, G);
  
    #pragma omp parallel
    {
	const int tid = omp_get_thread_num();
	for(int j = 0; j < CACHELINE; j++){
        	sync[tid][j] = 0;
     	}
    }

    const double start  = omp_get_wtime();
    /* !Computing G (PARALLEL) */
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
/**
 * In this version I managed to remove the conditions inside the inner loop
 * for (int i = (p%2) + 1; i < Mm1+1; i+=2) making the code faster.
 */

void sor_simulation (double omega, int M, int N, 
        double G[M][N], int num_iterations, 
        int total_threads, volatile long sync[total_threads][CACHELINE]) {

    int id_thread =  omp_get_thread_num();
    double omega_over_four = omega * 0.25;
    double one_minus_omega = 1.0 - omega;
    int Mm1 = M-1;
    int Nm1 = N-1;
    
    // Calculating the thread distribution
    int tslice      = (Mm1) / 2;
    int ttslice     = (tslice + total_threads - 1)/total_threads;
    int slice       = ttslice * 2;

    int ilow        = id_thread * slice + 1;
    int iupper      = ((id_thread + 1) * slice) + 1;
    if (iupper > Mm1 || (id_thread == (total_threads - 1))) iupper =  Mm1+1;
    int end = iupper - 2; // adjusting to remove the last iteration from the loop


    int num_iterations_2 = 2 * num_iterations;

    for (int p=0; p< num_iterations_2; p++) 
    {
        int begin = ilow + (p%2);
        
        // Dealing with the first row
        if(begin == 1) 
        { 
            first_row(omega_over_four, one_minus_omega, Nm1, G[1], G[0], G[2]);
            begin += 2;
        } 
			
        // Dealing with the middle rows
        int i;

        for (i = begin; i < end; i += 2) 
        {
            middle_rows(omega_over_four, one_minus_omega, Nm1, 
                        G[i], G[i-1], G[i+1], G[i-2]);
        }
        
        // Dealing with the last iteration
        if (i == Mm1) 
        {
            last_row(omega_over_four, one_minus_omega, Nm1,
                        G[i], G[i-1], G[i-2]);
        } 
        else 
        {
            middle_rows(omega_over_four, one_minus_omega, Nm1, 
                        G[i], G[i-1], G[i+1], G[i-2]);
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

void middle_rows(   const double omega_over_four, const double one_minus_omega, 
                    const int Nm1, double *Gi, double *Gim1, 
                    double *G1, double *G2) 
{
    const double *Gip1 = G1;
    const double *Gim2 = G2;
    int j;

    int Nm3 = Nm1-2;
    
    // removing the if((j+1) != Nm1)  condition from the inside loop body
    for (j = 1; j < Nm3; j += 2)
    {
        Gi[j] = omega_over_four * (Gim1[j] + Gip1[j] + Gi[j-1]
                        + Gi[j+1]) + one_minus_omega * Gi[j];
        Gim1[j+1] =omega_over_four * (Gim2[j+1] + Gi[j+1] + Gim1[j] + Gim1[j+2]) 
                + one_minus_omega * Gim1[j+1];
    }
    Gi[j] = omega_over_four * (Gim1[j] + Gip1[j] + Gi[j-1] + Gi[j+1]) + 
            one_minus_omega * Gi[j];
			
    if((j+1) != Nm1) 
    {
        Gim1[j+1]=omega_over_four * (Gim2[j+1] + Gi[j+1] + Gim1[j]
                + Gim1[j+2]) + one_minus_omega * Gim1[j+1];
    }
}


void last_row(  const double omega_over_four, const double one_minus_omega, 
                const int Nm1, double *Gi, double *Gim1, double *Gim2_) 
{
                
    const double *Gim2 = Gim2_;
    // removing if((j+1) != Nm1) condition using Nm-1 instead of Nm1
    const int Nm2 = Nm1 - 1;
    for (int j = 1; j < Nm2; j += 2)
    {
        Gim1[j+1]=omega_over_four * (Gim2[j+1] + Gi[j+1] + Gim1[j]
			+ Gim1[j+2]) + one_minus_omega * Gim1[j+1];
    }
}

void first_row( const double omega_over_four, const double one_minus_omega, 
                const int Nm1, double *Gi, double *Gim1, double *Gip1_) 
{
    const double *Gip1 = Gip1_;
    
    for (int j = 1; j < Nm1; j += 2)
    {
        Gi[j] = omega_over_four * (Gim1[j] + Gip1[j] + Gi[j-1]+ Gi[j+1]) 
                + one_minus_omega * Gi[j];
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
