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
    
}Sor;

void run            (int size, int validation);
void JGFinitialise  (Sor *sor);
void JGFKernel      (Sor *sor);
void RandomMatrix   (int M, int N, double G [M][N]);
void sor_simulation (double omega, int M, int N, double G[M][N], int iterations);
void middle_rows    (const double omega_over_four, const double one_minus_omega, 
                        const int Nm1, double *Gi, double *Gim1, 
                        double *G1, double *G2); 
void last_row       (const double omega_over_four, const double one_minus_omega, 
                     const int Nm1, double *Gi, double *Gim1, double *Gim2_);

void first_row      ( const double omega_over_four, const double one_minus_omega, 
                        const int Nm1, double *Gi, double *Gim1, double *Gip1_);

int abs_            (int value);
double abs_double   (double value);
void JGFvalidate    (double Gtotal, int size);


#ifdef __cplusplus
extern "C" {
#endif


#ifdef __cplusplus
}
#endif

#endif /* SOR_H */

