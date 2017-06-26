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

package sm.improved;

import java.util.Random;

public class SOR
{

	public static double Gtotal = 0.0;
	public static final int cachelinesize = 128;
	public static volatile long sync[][];
	private static final long RANDOM_SEED = 10101010;
	
	SOR(int total_threads){
		sync = new long  [total_threads][cachelinesize];
	}

	public final void SORrun(double omega, double G[][], int M, int N, int num_iterations) {		
		
		Random R = new Random(RANDOM_SEED);
		final int Mm1 			= M-1;
		final int Nm1 			= N-1;
		
		/* Creating Threads */
		final int total_threads = JGFSORBench.nthreads;
		final Thread th[] 		= new Thread[total_threads-1];

		final int chunk_size = M % total_threads;
		
		final int tslice 	= Mm1 >> 1;
		final int ttslice 	= (tslice + total_threads - 1) / total_threads;
		final int slice 		= ttslice << 1;

		
		final long begin = System.currentTimeMillis();
		
		/* Applying First Touch - Using threads to Alloc and Initialize G */
		for (int i = 0; i < total_threads-1; i++){
			final int id = i+1;			
			th[i] = new Thread(new Runnable() {				
				public final void run(){
					int chunk_start = chunk_size * id;
					int chunk_end = chunk_size * (id+1);
					for (int l=chunk_start; l < chunk_end; l++)
					{	
							/* Allocation in Parallel */
							G[l] = new double[M];
							
							/* Initialize in Parallel */
							for (int c=0; c<N; c++) {
								G[l][c] = R.nextDouble() * 1e-6;
							}
					}
					final int ilow 	= id * slice + 1;
					int iupper 		= slice + ilow;	
					
					if (iupper > Mm1) iupper =  Mm1+1;
					
					SORRunner(G, id, omega, num_iterations, ilow, iupper, Mm1, Nm1, total_threads);
				}
			});
			th[i].start();
		} 
		
		int iupper 		= slice + 1;
		if (iupper > Mm1 || total_threads == 1) iupper =  Mm1+1;


		SORRunner(G, 0, omega, num_iterations, 1, iupper, Mm1, Nm1, total_threads);		
		
		
		for(int i = 0 ; i < total_threads-1 ; i++)
		{
			try 
			{
				th[i].join();
			}
			catch (InterruptedException e) {}
		}
		//barrier
		
		final long end = System.currentTimeMillis();
		System.out.println((end-begin) / 1000.0);
		
		for (int i = 1; i < Nm1; i++) 
		{
			for (int j = 1; j < Nm1; j++) 
			{
				Gtotal += G[i][j];
			}
		}               

	}	
	public final void SORRunner(	final double G[][], final int id, final double omega, 
								final int num_iterations, final int ilow, final int iupper,
								final int Mm1, final int Nm1, final int total_threads)
	{
		final double omega_over_four 	= omega * 0.25;
		final double one_minus_omega 	= 1.0 - omega;
		final int num_iterations_2 		= 2 * num_iterations;
	
		// adjusting to remove the last iteration from the loop
		final int end = iupper - 2; 
		
		for (int p=0; p< num_iterations_2; p++) 
		{
			int begin = ilow + (p%2);
			
			// Dealing with the first row
			begin = first_row(begin, G, omega_over_four, one_minus_omega, Nm1); 
			
			// Dealing with the middle rows
			int i;
			for (i = begin; i < end; i += 2) 
			{
				middle_rows(G, omega_over_four, one_minus_omega, Nm1, i, G[i], G[i-1]);
			}
			
			// Dealing with the last iteration
			if (i == Mm1) 
			{
				last_row(G, omega_over_four, one_minus_omega, Nm1, i, G[i], G[i-1]);
			} 
			else if(i < Mm1)
			{
				middle_rows(G, omega_over_four, one_minus_omega, Nm1, i, G[i], G[i-1]);
			}

			call_barrier(id, total_threads);
		}

	}

	public int first_row(	int begin, final double[][] G, final double omega_over_four, 
							final double one_minus_omega, final int Nm1) {
		if(begin == 1) 
		{ 
			first_row(G, omega_over_four, one_minus_omega, Nm1, 1, G[1], G[0]);
			return begin + 2; // removing first iteration from it
		}
		return begin;
	}
	public final void call_barrier(final int id, final int total_threads) {
		// Signal this thread has done iteration
		sync[id][0]++;

		// Wait for neighbors
		if (id > 0) {
			while (sync[id-1][0] < sync[id][0]) ;
		}
		if (id < total_threads -1) {
			while (sync[id+1][0] < sync[id][0]) ;
		}
	}

	private void middle_rows(final double G[][], final double omega_4, final double one_m_omega, 
							final int Nm1, int i, final double[] Gi, final double[] Gim1) 
	{
		final double [] Gip1 = G[i+1];
		final double [] Gim2 = G[i-2];
		int j;
		final int Nm3 = Nm1-2;
		
		// removing the if((j+1) != Nm1)  condition from the inside loop body
		for (j = 1; j < Nm3; j += 2)
		{
			Gi[j] 	  = omega_4 * (Gim1[j] + Gip1[j] + Gi[j-1] + Gi[j+1]) + one_m_omega * Gi[j];
			Gim1[j+1] = omega_4 * (Gim2[j+1] + Gi[j+1] + Gim1[j] + Gim1[j+2]) + one_m_omega * Gim1[j+1];
		}
		
		Gi[j] = omega_4 * (Gim1[j] + Gip1[j] + Gi[j-1] + Gi[j+1]) + one_m_omega * Gi[j];
		
		if((j+1) != Nm1) 
		{
			Gim1[j+1] = omega_4 * (Gim2[j+1] + Gi[j+1] + Gim1[j]+ Gim1[j+2]) + one_m_omega * Gim1[j+1];
		}
	}

	private void last_row(	final double G[][], final double omega_4, final double one_m_omega, 
							final int Nm1, int i, final double[] Gi, final double[] Gim1) {
		final double [] Gim2 = G[i-2];

		// removing if((j+1) != Nm1) condition using Nm-1 instead of Nm1
		final int Nm2 = Nm1 - 1;
		
		for (int j = 1; j < Nm2; j += 2)
		{
			Gim1[j+1] = omega_4 * (Gim2[j+1] + Gi[j+1] + Gim1[j] + Gim1[j+2]) + one_m_omega * Gim1[j+1];
		}
	}

	private static void first_row (	final double G[][], 	  final double omega_over4, final double one_m_omega, 
			final int Nm1, int i, final double[] Gi, final double[] Gim1) 
	{
		final double [] Gip1 = G[i+1];

		for (int j = 1; j < Nm1; j += 2)
		{
			Gi[j] = omega_over4 * (Gim1[j] + Gip1[j] + Gi[j-1] + Gi[j+1]) + one_m_omega * Gi[j];
		}
	}
}
