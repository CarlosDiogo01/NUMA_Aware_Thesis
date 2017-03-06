#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "Linpack.h"


void run(const int size, const int validation)
{
    const int datasizes[]   = {500, 1000, 2000, 4000, 8000, 16000}; 
    int info;
    Linpack linpack;
    linpack.size = size;
    const int n = datasizes[size];
    
    if(!JGFinitialise(&linpack, n)) return ; // return if problems
    
    const double start = omp_get_wtime();
    
    info = dgefa(n, linpack.a, linpack.ipvt);
    dgesl(n, linpack.a, linpack.ipvt, linpack.b, 0);
    
    const double end   = omp_get_wtime();
    printf("%f\n", (end - start));
    
   
    if(validation)
    {
        JGFvalidate    (n, &linpack, linpack.a);
    }
    
    free(linpack.b);
    free(linpack.ipvt);
    free(linpack.x);
    
    for(int i = 0; i < n; i++)
    {
        free(linpack.a[i]);
    }
    free(linpack.a);
}

 int JGFinitialise(Linpack *linpack, const int n){
     
    linpack->n      = n; 
    linpack->ldaa   = n; 
    linpack->lda    = linpack->ldaa + 1;
    
    linpack->b      = malloc(sizeof(double) * n);
    linpack->x      = malloc(sizeof(double) * n);
    linpack->ipvt   = malloc(sizeof(int) * n);
    linpack->a      = malloc(n * sizeof(double*));
    
    for(int i = 0; i < n; i++)
    {
        linpack->a[i] = malloc((n+1) * sizeof(double));
    }
    
    // unsuccessful memory allocation
    if(!(linpack->b) || !(linpack->x ) || !(linpack->ipvt) || ! (linpack->a))
    {
        return 0;
    }
        
    long nl = (long) n;   //avoid integer overflow
    linpack->ops = (2.0*(nl*nl*nl))/3.0 + 2.0*(nl*nl);
    linpack->norma = matgen(n, linpack->a, linpack->b);   

    return 1;
  }


double matgen (const int n, double **a, double b[]){
     
    double norma = 0.0;
    int init = 1325;
    
    for (int i = 0; i < n; i++) 
    {
        for (int j = 0; j < n; j++)
        {
            init = 3125*init % 65536;
            a[j][i] = (init - 32768.0)/16384.0;
            norma = (a[j][i] > norma) ? a[j][i] : norma;
        }
    }
    for (int i = 0; i < n; i++) 
    {
        b[i] = 0.0;
    }
    for (int j = 0; j < n; j++) 
    {
        for (int i = 0; i < n; i++)
        {
            b[i] += a[j][i];
        }
    }
    return norma;
  }
 
int dgefa(const int n, double **a, int ipvt[n]){
    
    const int nm1 = n - 1;  
    double *col_k, *col_j;
    int info = 0;
    
    if (nm1 >= 0) 
    {
        for (int k = 0, kp1 = 1; k < nm1; k++, kp1++) 
        {
            col_k = a[k];

            int l = idamax(n-k, col_k, k, 1) + k; // find l = pivot index
	    ipvt[k] = l;
	
	    // zero pivot implies this column already triangularized
	    if (col_k[l] != 0)
            {
                // interchange if necessary
                if (l != k) 
                {
                    double t = col_k[l];
                    col_k[l] = col_k[k];
                    col_k[k] = t;
                }
	  
                // compute multipliers
                dscal(n-(kp1), -1.0/col_k[k] ,col_k,kp1,1);
	  
                double t;
                // row elimination with column indexing
                for (int j = kp1; j < n; j++)
                {
                    col_j = a[j];
                    t = col_j[l];
                    if (l != k) 
                    {
                        col_j[l] = col_j[k];
                        col_j[k] = t;
                    }
                    daxpy(n-(kp1), t, col_k, kp1, 1, col_j, kp1, 1);
	    				
                }	
            }
            else 
            {
                info = k;
            }
        }
    }
    
    ipvt[nm1] = nm1;
    if (a[nm1][nm1] == 0)
    {
        info = nm1;
    }
    
    return info;
  }

int idamax(int n, double dx[], int dx_off, int incx){

    double dmax, dtemp;
    int ix, itemp=0;

    if (n < 1) 
    {
        itemp = -1;
    } 
    else if (n ==1) 
    {
        itemp = 0;
    } 
    else if (incx != 1) 
    {
        // code for increment not equal to 1
        dmax = abs_(dx[0 +dx_off]);
        ix = 1 + incx;
        for (int i = 1; i < n; i++) 
        {
            dtemp = abs_(dx[ix + dx_off]);
            if (dtemp > dmax)  
            {
                itemp = i;
                dmax = dtemp;
            }
            ix += incx;
        }
    } 
    else 
    {
      // code for increment equal to 1
      itemp = 0;
      dmax = abs_(dx[0 +dx_off]);
      for (int i = 1; i < n; i++)
      {
            dtemp = abs_(dx[i + dx_off]);
            if (dtemp > dmax) 
            {
                itemp = i;
                dmax = dtemp;
            }
      }
    }
    return (itemp);
  }
  
double abs_(double d) { return (d >= 0) ? d : -d;}
  
void dscal(int n, double da, double dx[], int dx_off, int incx){
    
    int nincx;
    if (n > 0) 
    {
        if (incx != 1) 
        {
            // code for increment not equal to 1

            nincx = n*incx;
            for (int i = 0; i < nincx; i += incx)
                dx[i +dx_off] *= da;
            
        } 
        else 
        {
            // code for increment equal to 1

            for (int i = 0; i < n; i++)
                dx[i +dx_off] *= da;
        }
    }
}

void daxpy( int n, double da, double dx[], int dx_off, int incx,
	      double dy[], int dy_off, int incy){
    
    int ix,iy;

    if ((n > 0) && (da != 0)) 
    {
        if (incx != 1 || incy != 1) 
        {
            // code for unequal increments or equal increments not equal to 1
            ix = 0;
            iy = 0;
            if (incx < 0) ix = (-n+1)*incx;
            if (incy < 0) iy = (-n+1)*incy;
			  
            for (int i = 0;i < n; i++) 
            {
                dy[iy +dy_off] += da*dx[ix +dx_off];
                ix += incx;
                iy += incy;
            }
            return;
        } 
        else 
        {
            // code for both increments equal to 1

            for (int i = 0; i < n; i++)
            {
                dy[i + dy_off] += da * dx[i + dx_off];
            }
        }
    }
}

void JGFvalidate(const int n, Linpack *linpack, double **a){
    
    const int lda   = linpack->lda;
    const int size  = linpack->size;
    double *x       = linpack->x;
    double *b       = linpack->b;
    double eps,residn, norma = linpack->norma;
    const double ref[] = {6.0, 12.0, 20.0}; 

    for (int i = 0; i < n; i++) 
    {
        x[i] = b[i];
    }
    
    norma = matgen(n, a, b);
    
    for (int i = 0; i < n; i++) 
    {
        b[i] = -b[i];
    }

    dmxpy(n,b,n,lda,x,a);
    double resid = 0.0;
    double normx = 0.0;
    
    for (int i = 0; i < n; i++) 
    {
        resid = (resid > abs_(b[i])) ? resid : abs_(b[i]);
        normx = (normx > abs_(x[i])) ? normx : abs_(x[i]);
    }
    
    eps =  epslon((double)1.0);
    residn = resid/( n*norma*normx*eps );

    if (residn > ref[size]) 
    {
	printf("Validation failed\n");
	printf("Computed Norm Res = %f \n", residn);
        printf("Reference Norm Res = %f \n", ref[size]); 
    }
}

void dmxpy (int n1, double y[], int n2, int ldm, double x[], double **m){
    
    // cleanup odd vector
    for (int j = 0; j < n2; j++)
    {
        for (int i = 0; i < n1; i++) 
        {
            y[i] += x[j]*m[j][i];
        }
    }
}

double epslon (double x){
    
    double a,b,c,eps;

    a = 4.0e0/3.0e0;
    eps = 0;
    while (eps == 0) 
    {
        b = a - 1.0;
        c = b + b + b;
        eps = abs_(c-1.0);
    }
    return(eps * abs_(x));
}

void dgesl(int n, double **a, int ipvt[], double b[], int job){
	    
    double t;
    int l, k, nm1,kp1;
    
    nm1 = n - 1;
    if (job == 0) 
    {
        // job = 0 , solve  a * x = b.  first solve  l*y = b
        if (nm1 >= 1) 
        {
            for (k = 0; k < nm1; k++) 
            {
                l = ipvt[k];
                t = b[l];
                if (l != k)
                {
                    b[l] = b[k];
                    b[k] = t;
                }
                    kp1 = k + 1;
                    daxpy(n-(kp1),t,a[k],kp1,1,b,kp1,1);
	    }
        }

        // now solve  u*x = y
        
        for (int kb = 0; kb < n; kb++)
        {
            k = n - (kb + 1);
            b[k] /= a[k][k];
            t = -b[k];
            daxpy(k,t,a[k],0,1,b,0,1);
	}
    }
    else 
    {
        // job = nonzero, solve  trans(a) * x = b.  first solve  trans(u)*y = b
        for (k = 0; k < n; k++) 
        {
            t = ddot(k,a[k],0,1,b,0,1);
            b[k] = (b[k] - t)/a[k][k];
        }

        // now solve trans(l)*x = y 
        if (nm1 >= 1) 
        {
            for (int kb = 1; kb < nm1; kb++) 
            {
                k = n - (kb+1);
                kp1 = k + 1;
                b[k] += ddot(n-(kp1),a[k],kp1,1,b,kp1,1);
                l = ipvt[k];
	    				
                if (l != k) 
                {
                    t = b[l];
                    b[l] = b[k];
                    b[k] = t;
                }
            }
        }
    }
}
    
double ddot( int n, double dx[], int dx_off, int incx, double dy[],
	       int dy_off, int incy){
    
    double dtemp;
    int ix,iy;

    dtemp = 0;

    if (n > 0) 
    {
        if (incx != 1 || incy != 1) 
        {
            // code for unequal increments or equal increments not equal to 1
            ix = 0;
            iy = 0;
            if (incx < 0) ix = (-n+1)*incx;
            if (incy < 0) iy = (-n+1)*incy;
            
            for (int i = 0;i < n; i++) 
            {
                dtemp += dx[ix +dx_off]*dy[iy +dy_off];
                ix += incx;
                iy += incy;
            }
        } 
        else 
        {
            // code for both increments equal to 1
	
            for (int i = 0; i < n; i++)
                dtemp += dx[i +dx_off]*dy[i +dy_off];
        }
    }
    return(dtemp);
  }