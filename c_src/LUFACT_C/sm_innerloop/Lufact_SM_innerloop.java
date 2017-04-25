package sm_innerloop;
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

/**
 * 
 * @author Bruno Medeiros
 *
 * This version took the JGF Lufact multi-thread version and changed the parallel 
 * strategy used, instead of using threads over the entire kernel (dgefa method )
 * it only uses threads during the row elimination.Tthis version uses executors, 
 * in oder to reuse the threads between executions of the row elimination.
 * 
 *  Comparing with the old version, this version :
 *  -> has less synchronization (less barriers);
 *  -> is more readable;
 *  -> is faster.
 *
 */


public class Lufact_SM_innerloop{ 

		public static int nthreads;
	
	public static void main(String argv[])
	{
		final boolean validation		= (argv.length > 0) && (argv[0].equals("-v"));		
		final int size				= (argv.length > 1) ? Integer.parseInt(argv[1]) : 0; 
		nthreads 					= (argv.length > 2) ? Integer.parseInt(argv[2]) : 2; // The number of threads
	
		(new JGFLUFactBench()).JGFrun(validation, size);
	}
}
 
