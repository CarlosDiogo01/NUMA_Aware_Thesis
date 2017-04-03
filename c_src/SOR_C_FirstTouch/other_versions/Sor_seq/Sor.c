#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <time.h>
#include "Sor.h"

void run (int size, int validation){
    
    const int datasizes[]={1000, 1500, 2000, 5000, 10000, 20000};
    Sor *sor = malloc(sizeof(Sor));
    sor->size = size;
    sor->M = sor->N = datasizes[size];
   
    JGFinitialise(sor);
   
    double (*G) [sor->N] = malloc(sizeof *G * sor->M);
    
    
    RandomMatrix(sor->M, sor->N, G);
    sor->Gtotal = SORrun(1.25, sor->M, sor->N, G, sor->JACOBI_NUM_ITER);
    
    if(validation)
    {
        JGFvalidate(sor->Gtotal, sor->size);
    }
    
    free(G);
    free(sor);

}

void JGFinitialise(Sor *sor){
    
    sor->JACOBI_NUM_ITER    = 100;
    sor->RANDOM_SEED        = 10101010; 
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


double SORrun(double omega, int M, int N, double G[M][N], 
            int num_iterations)
{
    double omega_over_four = omega * 0.25;
    double one_minus_omega = 1.0 - omega;
               
    int Mm1 = M-1;
    int Nm1 = N-1;

    const double start  = omp_get_wtime();

    for (int p = 0; p < num_iterations; p++)
    {
        for (int i = 1; i < Mm1; i++)
        {
            double *Gi = G[i];
            double *Gim1 = G[i-1];
            double *Gip1 = G[i+1];
            for (int j=1; j<Nm1; j++)
            {
                Gi[j] = omega_over_four * (Gim1[j] + Gip1[j] + Gi[j-1] 
            				+ Gi[j+1]) + one_minus_omega * Gi[j];
                
            }
        }
    }
		
    const double end    = omp_get_wtime();
    printf("%f\n", (end - start));

    double Gtotal = 0;
    
    for (int i = 1; i < Nm1; i++) 
    {
        for (int j=1; j<Nm1; j++) 
        {
            Gtotal += G[i][j];
        }
    }
    return Gtotal;
}



int abs_            (int value)     {return (value > 0) ? value : -value;}
double abs_double   (double value)  {return (value > 0) ? value : -value;}


void JGFvalidate(double Gtotal, int size){
   
    double refval[] = {0.4980140931916428, 1.1220495504514847,1.9961836674523350};
    double dev = abs_double(Gtotal - refval[size]);
    if (dev > 1.0e-12 )
    {
        printf("Validation failed\n");
        printf("Gtotal = %.16f %.16f %d\n",Gtotal, dev ,size);
    }
}
