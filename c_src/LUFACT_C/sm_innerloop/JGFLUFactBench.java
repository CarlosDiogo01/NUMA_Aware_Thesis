/**************************************************************************
*                                                                         *
*             Java Grande Forum Benchmark Suite - Version 2.0             *
*                                                                         *
*                            produced by                                  *
*                                                                         *
*                  Java Grande Benchmarking Project                       *
*                                                                         *
*                                at                                       *
*                                                                         *
*                Edinburgh Parallel Computing Centre                      *
*                                                                         * 
*                email: epcc-javagrande@epcc.ed.ac.uk                     *
*                                                                         *
*                                                                         *
*      This version copyright (c) The University of Edinburgh, 1999.      *
*                         All rights reserved.                            *
*                                                                         *
**************************************************************************/


package sm_innerloop;


public class JGFLUFactBench extends Linpack{

	
	private int size;
	private int datasizes[] = {500, 1000, 2000, 4000, 8000, 16000};

	public JGFLUFactBench() {}
	
	public void JGFsetsize(int size){
		this.size = size;
	}

	public void JGFinitialise(){

	    n = datasizes[size]; 
	    ldaa = n; 
	    lda = ldaa + 1;
	
	    a = new double[ldaa][lda];
	    b = new double [ldaa];
	    x = new double [ldaa];
	    ipvt = new int [ldaa];
	    
	    long nl = (long) n;   //avoid integer overflow
	    ops = (2.0*(nl*nl*nl))/3.0 + 2.0*(nl*nl);

	    norma = matgen(a,lda,n,b); 
    
	    final ThreadTeam team = new ThreadTeam (Lufact_SM_innerloop.nthreads);
	    Linpack.team = team;
	    super.totalThreads = Lufact_SM_innerloop.nthreads;
	}

	 public void JGFkernel()
	 {
		 final long begin = System.currentTimeMillis(); 
	   
		 info = dgefa(a,lda,n,ipvt);
		 dgesl(a,lda,n,ipvt,b,0);
	
		 final long end = System.currentTimeMillis();
		 System.out.println((end-begin) / 1000.0);
		 
		 team.shutdownThreads();
	 }

	 public void JGFvalidate(){
		 
		 double eps,residn;
		 final double ref[] = {6.0, 12.0, 20.0}; 

		 if(ref.length > size)
		 {
			 for (int i = 0; i < n; i++) {
				 x[i] = b[i];
			 }
			 norma = matgen(a,lda,n,b);
			 for (int i = 0; i < n; i++) {
				 b[i] = -b[i];
			 }
	
			 dmxpy(n,b,n,lda,x,a);
			 resid = 0.0;
			 normx = 0.0;
			 for (int i = 0; i < n; i++) {
				 resid = (resid > abs(b[i])) ? resid : abs(b[i]);
				 normx = (normx > abs(x[i])) ? normx : abs(x[i]);
			 }
	
			 eps =  epslon((double)1.0);
			 residn = resid/( n*norma*normx*eps );
	    
			 if (residn > ref[size]) {
				 System.out.println("Validation failed");
				 System.out.println("Computed Norm Res = " + residn);
				 System.out.println("Reference Norm Res = " + ref[size]); 
			 }
		 }
	 }

	 public void JGFtidyup()
	 {
		 // Make sure large arrays are gc'd.
		 a = null; 
		 b = null;
		 x = null;
		 ipvt = null; 
		 System.gc();  
	 }


	 public void JGFrun(boolean validation, int size)
	 {
		 JGFsetsize(size); 
		 JGFinitialise(); 
		 JGFkernel(); 
		 if(validation)
		 {
			 JGFvalidate(); 
		 }
	 }
}
