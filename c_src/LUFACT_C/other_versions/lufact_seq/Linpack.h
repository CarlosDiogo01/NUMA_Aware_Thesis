/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   Linpack.h
 * Author: Bruno Medeiros
 *
 * Created on 13 de Outubro de 2016, 13:54
 */

#ifndef LINPACK_H
#define LINPACK_H

typedef struct LINPACK
{
    int size;
    int n;
    int ldaa;
    int lda;
    double **a;
    double *b;
    double *x;
    double ops,total,norma,normx;
    double resid,time;
    double kf;
    int ntimes,info,kflops;
    int *ipvt;
} Linpack;


void run            (const int size, const int validation);
int JGFinitialise   (Linpack *linpack, const int n);
double matgen       (const int n, double **a, double b[]);
int dgefa           (const int n, double **a, int ipvt[n]);
int idamax          (int n, double dx[], int dx_off, int incx);
double abs_         (double d);
void dscal          (int n, double da, double dx[], int dx_off, int incx);
void daxpy          (int n, double da, double dx[], int dx_off, int incx,
                     double dy[], int dy_off, int incy);
void JGFvalidate    (const int n, Linpack *linpack, double **a);
void dmxpy          (int n1, double y[], int n2, int ldm, double x[], 
                        double **m);
double epslon       (double x);
void dgesl          (int n, double **a, int ipvt[], double b[], int job);
double ddot         (int n, double dx[], int dx_off, int incx, double dy[],
                        int dy_off, int incy);

#ifdef __cplusplus
extern "C" {
#endif


#ifdef __cplusplus
}
#endif

#endif /* LINPACK_H */

