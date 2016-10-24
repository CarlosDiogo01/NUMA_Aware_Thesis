package sm.JGF;

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


public class Sm_jgf{ 

  public static int nthreads;

  public static void main(String argv[])
  {
	  	// If the user wants to validate the simulation and the dim problem
	  	final boolean validation	= (argv.length > 0) && (argv[0].equals("-v"));		
	  	final int size			= (argv.length > 1) ? Integer.parseInt(argv[1]) : 0; 
		nthreads 				= (argv.length > 2) ? Integer.parseInt(argv[2]) : 2; // The number of threads;

	  	(new JGFSparseMatmultBench(nthreads)).JGFrun(validation, size);
 
  }
}
