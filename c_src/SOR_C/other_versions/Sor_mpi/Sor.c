#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <time.h>
#include "functions_mpi.h"
#include "Sor.h"
#include "mpi.h"


void run (int size, int validation){
    
    const int datasizes[]={1000, 1500, 2000, 5000, 10000, 20000};
    Sor *sor = malloc(sizeof(Sor));
    sor->size = size;
    sor->M = sor->N = datasizes[size];
   
    JGFinitialise   (sor);
   
    JGFKernel       (sor);
    
    if(validation && getProcessId() == 0)
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

void JGFKernel(Sor *sor){
    
    const int rank          = getProcessId();
    const int nprocess      = numberProcess();
    
    sor->p_row = sub_g_size(sor, nprocess, rank);
    double (*p_G) [sor->N]    = malloc(sizeof *p_G * (sor->p_row + 2));
    double (*G)   [sor->N]    = (rank == 0) ? malloc(sizeof *G * sor->M) 
                                            : NULL;
    
    
   
    if(rank == 0)
    {
        RandomMatrix(sor->M, sor->N, G);
       
        int iup = (nprocess==1) ? sor->p_row + 1 : sor->p_row + 2;
        
        for(int i = 1; i < iup ; i++)
  	{
            for(int j = 0; j < sor->N; j++)
            {
                p_G[i][j] = G[i-1][j];
            }
        }
        for(int j = 0; j < sor->N; j++)
        {
            p_G[0][j] = 0.0; 
        }
       
        for(int k = 1; k < nprocess; k++)
        {
            int m_length = (k==nprocess-1) ? sor->rem_p_row + 1 : sor->p_row + 2;
            int begin    = (k * sor->p_row) - 1;
            
            MPI_Send(   &G[begin], 
                        sor->N * m_length, 
                        MPI_DOUBLE, 
                        k, 
                        k, 
                        MPI_COMM_WORLD
                    );
        } 
    }
    else
    {
        int end = (rank==(nprocess-1)) ? sor->p_row+1 : sor->p_row+2;
        MPI_Recv(   &p_G[0], 
                    end * sor->N, 
                    MPI_DOUBLE, 
                    0, 
                    rank, 
                    MPI_COMM_WORLD, 
                    MPI_STATUS_IGNORE
                );
    }

    if(rank==(nprocess-1))
    {
        int last_line = sor->p_row + 1;
        for(int j = 0; j < sor->N; j++)
        {
            p_G[last_line][j] = 0.0; 
        }
    }
    
    int p_G_lenght = sor->p_row + 2;
    MPI_Barrier(MPI_COMM_WORLD);
    const double start  = omp_get_wtime();        
    sor_simulation (1.25, p_G_lenght, sor->N, p_G, 
                    sor->JACOBI_NUM_ITER, rank, nprocess);
    
        
    MPI_Barrier(MPI_COMM_WORLD);
    
    if(rank == 0) 
    {
        int last = sor->p_row + 1; // same as p_G.length-1 -> (sor->p_row + 2) - 1 
        for(int i = 1; i < last; i++)
        {
            for(int j = 0; j < sor->N ; j++)
            {
                G[i-1][j] = p_G[i][j];
            }
        }
        int rm_length;
        for(int k = 1; k < nprocess; k++)
        {
            rm_length = (k == (nprocess-1)) ? sor->rem_p_row : sor->p_row;
            int first_line 	= k * sor->p_row;
            MPI_Recv(   &G[first_line], 
                        rm_length * sor->N, 
                        MPI_DOUBLE, 
                        k, 
                        k, 
                        MPI_COMM_WORLD, 
                        MPI_STATUS_IGNORE
                    );
        }
    } 
    else 
    {
        MPI_Ssend(  &p_G[1], 
                    sor->N * sor->p_row, 
                    MPI_DOUBLE, 
                    0, 
                    rank, 
                    MPI_COMM_WORLD
                );
    }
    MPI_Barrier(MPI_COMM_WORLD);
    
    if(rank == 0){
        
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
    
    free(p_G);
}

/**
 * In this version I managed to remove the conditions inside the inner loop
 * for (int i = (p%2) + 1; i < Mm1+1; i+=2) making the code faster.
 */

void sor_simulation (   double omega, int p_G_lenght, int N, 
                        double p_G[p_G_lenght][N], int num_iterations, 
                        int rank, int nprocess){

    double omega_over_four = omega * 0.25;
    double one_minus_omega = 1.0 - omega;

    int Nm1 = N-1;
    int num_iterations_2 = 2 * num_iterations;
    int last_process    = (rank==(nprocess-1));
    int master          = (rank == 0);
    
   for (int p=0; p< num_iterations_2; p++) 
   {
        int begin = (p%2) + 1;
        
        // Dealing with the first row
        if(begin == 1) 
        { 
            if(master)
            {
                first_row(  p_G_lenght, N, p_G, 
                            omega_over_four, one_minus_omega, Nm1, 2);
                begin += 2;
            }
        }
        else
        {
            if(!master)
            {
                first_row   (p_G_lenght, N, p_G, 
                            omega_over_four, one_minus_omega, Nm1, 1);
            }
        }
        
        int Mm1 = (last_process ? p_G_lenght-1 : p_G_lenght) - 1;
        int end = Mm1-1;
	
        // Dealing with the middle rows
        int i;
        for (i = begin+1; i < end; i += 2) 
        {
            middle_rows(p_G_lenght, N, p_G, 
                        omega_over_four, one_minus_omega, Nm1, 
                        i, p_G[i], p_G[i-1]);
        }
        
        // Dealing with the last iteration
        if (i == Mm1) 
        {
            last_row(   p_G_lenght, N, p_G,
                        omega_over_four, one_minus_omega, Nm1,
                        i, p_G[i], p_G[i-1]);
        } 
        else if (i < Mm1)
        {
            middle_rows(    p_G_lenght, N, p_G, 
                            omega_over_four, one_minus_omega, Nm1, 
                            i, p_G[i], p_G[i-1]);
        }
  
        if(!last_process)
        {
            MPI_Sendrecv(   p_G[p_G_lenght-2], 
                            N,
                            MPI_DOUBLE, 
                            rank+1, 
                            1, 
                            p_G[p_G_lenght-1],  
                            N,
                            MPI_DOUBLE,
                            rank+1,
                            2, 
                            MPI_COMM_WORLD, 
                            MPI_STATUS_IGNORE
                        );
        }
        if(!master)
        {
            MPI_Sendrecv(   p_G[1], 
                            N,
                            MPI_DOUBLE, 
                            rank-1, 
                            2, 
                            p_G[0], 
                            N, 
                            MPI_DOUBLE,
                            rank-1,
                            1, 
                            MPI_COMM_WORLD, 
                            MPI_STATUS_IGNORE
                    );      
        }
    }   
}

void middle_rows(   int m, int n, double G[m][n],
                    const double omega_over4, const double one_m_omega, 
                    const int Nm1, int i, double *Gi, double *Gim1) 
{
    double *Gip1 = G[i+1];
    double *Gim2 = G[i-2];
    int j;
    int Nm3 = Nm1-2;
    
    // removing the if((j+1) != Nm1)  condition from the inside loop body
    for (j = 1; j < Nm3; j += 2)
    {
        Gi[j]     = omega_over4 * (Gim1[j] + Gip1[j] + Gi[j-1] + Gi[j+1]) 
                    + one_m_omega * Gi[j];
        
        Gim1[j+1] = omega_over4 * (Gim2[j+1] + Gi[j+1] + Gim1[j] + Gim1[j+2]) 	
                    + one_m_omega * Gim1[j+1];
    }
		
    Gi[j] = omega_over4 * (Gim1[j] + Gip1[j] + Gi[j-1] + Gi[j+1]) 
            + one_m_omega * Gi[j];
		
    if((j+1) != Nm1)
    {
        Gim1[j+1] = omega_over4 * (Gim2[j+1] + Gi[j+1] + Gim1[j] + Gim1[j+2]) 
                    + one_m_omega * Gim1[j+1];
    }
}


void last_row(  int m, int n, double G[m][n],
                const double omega_over_four, const double one_minus_omega, 
                const int Nm1, int i, double *Gi, double *Gim1) 
{
                
    double *Gim2 = G[i-2];
    
    // removing if((j+1) != Nm1) condition using Nm-1 instead of Nm1
    const int Nm2 = Nm1 - 1;
    for (int j = 1; j < Nm2; j += 2)
    {
        Gim1[j+1]=omega_over_four * (Gim2[j+1] + Gi[j+1] + Gim1[j]
			+ Gim1[j+2]) + one_minus_omega * Gim1[j+1];
    }
}

void first_row( int m, int n, double G[m][n], 
                const double omega_over_four, const double one_minus_omega, 
                const int Nm1, int begin) {
    
    double *Gi      = G[begin];
    double *Gim1    = G[begin-1];
    double *Gip1    = G[begin+1];
    
    for (int j = 1; j < Nm1; j += 2)
    {
        Gi[j] = omega_over_four * 
                (Gim1[j] + Gip1[j] + Gi[j-1]+ Gi[j+1]) 
                + one_minus_omega * Gi[j];
    }
}





int abs_            (int value)     {return (value > 0) ? value : -value;}
double abs_double   (double value)  {return (value > 0) ? value : -value;}



int sub_g_size(Sor *s, const int nprocess, const int rank){
    
    s->p_row = (((s->M / 2) + nprocess -1) / nprocess)*2;
    s->ref_p_row = s->p_row;
    s->rem_p_row = s->p_row - ((s->p_row*nprocess) - s->M);
    
    // adding to correct when using 48 processes
    if(s->rem_p_row < 0)
    {	
        do
        {
            s->p_row--;
            s->rem_p_row += nprocess;
        }
        while(s->rem_p_row < 0);

        s->ref_p_row = s->p_row;
        s->rem_p_row = s->p_row + (s->M - (s->p_row*nprocess));
        if(rank==(nprocess-1)) s->p_row = s->rem_p_row;
   }
  
    if(rank==(nprocess-1))
    {
        if((s->p_row * (rank+1)) > s->M) 
        {
            s->p_row = s->rem_p_row;
        }
    }
    return s->p_row;
}




void JGFvalidate(double Gtotal, int size){
   
    double refval[] = {0.4980286235707718, 1.1200980290730285, 1.9980973961615818};
    double dev = abs_double(Gtotal - refval[size]);
    if (dev > 1.0e-12 )
    {
        printf("Validation failed\n");
        printf("Gtotal = %.16f %.16f %d\n",Gtotal, dev ,size);
    }
}


