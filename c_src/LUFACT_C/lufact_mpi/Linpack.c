#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <mpi.h>
#include "Linpack.h"
#include "functions_mpi.h"


void run(const int size, const int validation)
{
    const int datasizes[]   = {500, 1000, 2000, 4000, 8000, 16000}; 
    int info;
    Linpack linpack;
    linpack.size = size;
    const int n = datasizes[size];
    double **a = malloc(n * sizeof(double*));
    int num_process = numberProcess();
    int rank        = getProcessId();
    
    // Master will allocate the entire matrix
    if(master())
    {
        for(int i = 0; i < n; i++)
        {
            a[i] = malloc((n+1) * sizeof(double));
        }
    }
    else // Slave allocate only the position where they will work
    {
        for(int i = 0; i < n; i++) a[i] = NULL;
        
        for(int i = rank; i < n; i += num_process)
        {
            a[i] = malloc((n+1) * sizeof(double));
        }
    }
    
    if(!JGFinitialise(&linpack, n, a)) return ; // return if problems
    
    // Send the values from matrix a from the master to the slaves
    sendAndRecvSubMatrixCycleManner (n, n+1, a);
    
    MPI_Barrier(MPI_COMM_WORLD);
    const double start = omp_get_wtime();
    
    info = dgefa(rank, num_process, n, a, linpack.ipvt);
    
    if(rank == 0)
    {
        dgesl(n, a, linpack.ipvt, linpack.b, 0);
    }
    
     MPI_Barrier(MPI_COMM_WORLD);
     
    if(rank == 0)
    {
        const double end   = omp_get_wtime();
        printf("%f\n", (end - start));
    }
    
   
    if(validation && rank == 0)
    {
        JGFvalidate    (n, &linpack, a);
    }
    
    free(linpack.b);
    free(linpack.ipvt);
    free(linpack.x);
    free(a);
}

 int JGFinitialise(Linpack *linpack, const int n, double **a){
     
    linpack->n      = n; 
    linpack->ldaa   = n; 
    linpack->lda    = linpack->ldaa + 1;
    
    if(master())
    {
        linpack->b      = malloc(sizeof(double) * n);
        linpack->x      = malloc(sizeof(double) * n);
        linpack->ipvt   = malloc(sizeof(int) * n);
    
        // unsuccessful memory allocation
        if(!(linpack->b) || !(linpack->x ) || !(linpack->ipvt))
        {
            return 0;
        }

        long nl = (long) n;   //avoid integer overflow
        linpack->ops = (2.0*(nl*nl*nl))/3.0 + 2.0*(nl*nl);
        linpack->norma = matgen(n, a, linpack->b);
        
        
    }
    else
    {
        linpack->ipvt   = malloc(sizeof(int) * n);
        linpack->b      = NULL;
        linpack->x      = NULL;
        
        // unsuccessful memory allocation
        if(!(linpack->ipvt)) return 0;
    }

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
 
int dgefa(int rank, int total_process, const int n, double **a, int ipvt[n]){
	  
    int nm1 = n - 1;
    double *broad_cast_buffer = malloc(sizeof(double) * n);
    double *buf_col_k = broad_cast_buffer;
    
    int tmp_l[1];
    int info = 0;
	  
    int parallel_for_begin = rank;
    if (nm1 >=  0) 
    {
        for (int k = 0, worker = 0, kp1 = 1; k < nm1; k++, kp1++, worker++) 
        {
            if(worker == total_process) worker = 0;
			  
            if(worker == rank)
            {
		double *col_k = a[k]; 
		const int l = tmp_l[0] = idamax(n-k,col_k,k,1) + k; // find l = pivot index
	
		// zero pivot implies this column already triangularized
		if (col_k[l] != 0) 
		{
                    // interchange if necessary
                    if (l != k) 
                    {
			const double t = col_k[l];
			col_k[l] = col_k[k];
			col_k[k] = t;
                    }
                    // compute multipliers
                    dscal(n-(kp1), -1.0/col_k[k], col_k, kp1, 1);
                    buf_col_k = a[k];
                }
            }
            else
            {
                buf_col_k = broad_cast_buffer;
            }
            /* Broadcast the copy buf_col_k to all processes */
            send_buffer_to_worker   (buf_col_k, n , worker);
            send_l_to_worker        (tmp_l, worker);
			  
            if (buf_col_k[k] != 0) 
            {
                const int l = ipvt[k] = tmp_l[0];

		if(parallel_for_begin == k)
                {
                    parallel_for_begin += total_process;
                }
		double t;
                double *col_j;
				  
		for (int j = parallel_for_begin; j < n; j += total_process) 
		{	  
                    col_j = a[j];
                    t = col_j[l];
                    
                    if (l != k) 
                    {
			col_j[l] = col_j[k];
                        col_j[k] = t;
                    }
                    
                    daxpy(n-(kp1), t, buf_col_k, kp1, 1, col_j, kp1, 1);
		}
            }
            else 
            {
                info = k;
            }
        }
    }
	  /* do the send back of arrays to process 0 */
    if(rank == 0) 
    {
        master_collecting_results(total_process, n, n + 1, a);	
	     
        ipvt[nm1] = nm1;
    	
        if (a[nm1][nm1] == 0) info = nm1;
    } 
    else 
    {
        slaves_send_results(rank, total_process, n, n + 1, a);
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