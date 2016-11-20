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
*      adapted from SciMark 2.0, author Roldan Pozo (pozo@cam.nist.gov)   *
*                                                                         *
*      This version copyright (c) The University of Edinburgh, 2001.      *
*                         All rights reserved.                            *
*                                                                         *
**************************************************************************/

package sm.JGF;

public class SparseMatmult
{

  public static double ytotal = 0.0;
  public static double yt[];

	/* 10 iterations used to make kernel have roughly
		same granularity as other Scimark kernels. */

	public static void test(	final double y[], final double val[], final int row[],
							final int col[],  final double x[],   final int NUM_ITERATIONS, 
							final int lowsum[], final int highsum[])
	{
        final int nz = val.length;
        final int totalThreads = JGFSparseMatmultBench.nthreads;
        yt=y;

        final Thread th[] = new Thread[totalThreads];

        long begin = System.currentTimeMillis();

        for(int i = 1; i < totalThreads; i++) 
        {
        		th[i] = new Thread(new SparseRunner(i,val,row,col,x,NUM_ITERATIONS,nz,lowsum,highsum));
        		th[i].start();
        }   

        (new SparseRunner(0,val,row,col,x,NUM_ITERATIONS,nz,lowsum,highsum)).run();

        for(int i = 1; i < totalThreads;i++) 
        {
          try 
          {
        	  	th[i].join(); 
          } 
          catch (InterruptedException e) {}
        }


        long end = System.currentTimeMillis();
        System.out.println((end - begin) / 1000.0);


          for (int i=0; i<nz; i++)
          {
        	  	ytotal += yt[ row[i] ];
          }

	}
}


class SparseRunner implements Runnable {

    final int id,nz,row[],col[],NUM_ITERATIONS;
    final double val[],x[];
    final int lowsum[];
    final int highsum[];

   public SparseRunner(	final int id, final double val[], final int row[], final int col[], final double x[], 
		   				final int NUM_ITERATIONS, final int nz, final int lowsum[], final int highsum[]) {
        this.id = id;
        this.x=x;
        this.val=val;
        this.col=col;
        this.row=row;
        this.nz=nz;
        this.NUM_ITERATIONS=NUM_ITERATIONS;
        this.lowsum = lowsum;
        this.highsum = highsum;
    }

   public void run() 
   {
         for (int reps=0; reps<NUM_ITERATIONS; reps++) 
         {
           for (int i=lowsum[id]; i<highsum[id]; i++) 
           {
        	   		SparseMatmult.yt[ row[i] ] += x[ col[i] ] * val[i];
           }
         }
   }


}
