/* 
 * File:   Sor.h
 * Author: Bruno Medeiros
 *
 * Created on 20 de Outubro de 2016, 15:58
 */

#ifndef SOR_H
#define SOR_H


typedef struct SOR{
    
    int     JACOBI_NUM_ITER;
    long    RANDOM_SEED;
    
    int     size;
    
    int M, N;
    
    double Gtotal;
    double ops;
    
    // MPI version variables
    int p_row, ref_p_row, rem_p_row;
    
    
}Sor;

void run            (int size, int validation);
void JGFinitialise  (Sor *sor);
void JGFKernel      (Sor *sor);
void RandomMatrix   (int M, int N, double G [M][N]);
void sor_simulation (double omega, int p_G_lenght, int N, 
                        double p_G[p_G_lenght][N], int JACOBI_NUM_ITER, 
                        int rank, int nprocess);
void middle_rows    (int m, int n, double G[m][n],
                        const double omega_over_four, const double one_minus_omega, 
                        const int Nm1, int i, double *Gi, double *Gim1);
void last_row       (  int m, int n, double G[m][n],
                        const double omega_over_four, const double one_minus_omega, 
                        const int Nm1, int i, double *Gi, double *Gim1);

void first_row      (   int m, int n, double p_g[m][n], 
                        const double omega_over_four, const double one_minus_omega, 
                        const int Nm1, int begin);

int abs_            (int value);
double abs_double   (double value);
int sub_g_size      (Sor *s, const int nprocess, const int rank);
void JGFvalidate    (double Gtotal, int size);


#ifdef __cplusplus
extern "C" {
#endif


#ifdef __cplusplus
}
#endif

#endif /* SOR_H */

