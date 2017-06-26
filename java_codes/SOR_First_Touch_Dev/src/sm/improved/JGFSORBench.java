/**************************************************************************
*                                                                         *
*         Java Grande Forum Benchmark Suite - Thread Version 1.0          *
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
*      This version copyright (c) The University of Edinburgh, 2001.      *
*                         All rights reserved.                            *
*                                                                         *
**************************************************************************/


package sm.improved;

public class JGFSORBench extends SOR{ 

  private int size; 
  private int datasizes[]={1000, 1500, 2000, 5000, 10000, 15000};
  private static final int JACOBI_NUM_ITER = 100;
  public static int nthreads;
  double ops;

  public JGFSORBench(int nt){
	  super(nt);
	  nthreads = nt;
  }

  public void JGFsetsize(int size){
    this.size = size;
  }

  public void JGFinitialise()
  {
	  double n = datasizes[size];
	  ops = 6*n*n*JACOBI_NUM_ITER;
  }
 
  
  public void JGFkernel(){

	  double G[][] = new double[datasizes[size]][];
	  
	  SORrun(1.25, G, datasizes[size], datasizes[size], JACOBI_NUM_ITER);
  }
  
  public void JGFvalidate(){

    double refval[] = {0.498574406322512,1.1234778980135105,1.9954895063582696};
    double dev = Math.abs(Gtotal - refval[size]);
    if (dev > 1.0e-12 ){
      System.out.println("Validation failed");
      System.out.println("Gtotal = " + Gtotal + "  " + dev + "  " + size);
    }
  }

  
  public void JGFtidyup(){
   System.gc();
  }  
  

  public void JGFrun(final int size, final boolean validation)
  {
	  JGFsetsize(size); 
	  JGFinitialise(); 
	  JGFkernel(); 
	  
	  if(validation)
	  {
		   JGFvalidate(); 
	  }
	  
	 
//	  JGFtidyup(); 
  }
}
