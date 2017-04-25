package sm_innerloop;

import java.util.concurrent.BrokenBarrierException;
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public final class ThreadTeam 
{
	private final ExecutorService  teamSlaves[];
	private final CyclicBarrier 	teamBarrier;	
	private final int numThreads;
	
	public ThreadTeam (final int numThr)
	{
	    numThreads	 	= numThr;
	    teamSlaves		= new ExecutorService[numThr-1];
	    for(int i = 0; i < numThr-1; i++)
	    {
	    		teamSlaves[i] = Executors.newSingleThreadExecutor();
	    }
	    teamBarrier 	= new CyclicBarrier	 	(numThreads);
	}
	
	// Team barrier
	public final void callBarrier()	
    { 											  																						
    	  try							   
    	  {
    		 teamBarrier.await(); 
    	  } 
    	  catch (InterruptedException | BrokenBarrierException  e)   {e.printStackTrace();} 
	}
	
	// Giving work to a thread
	public final void addTask	(final Runnable r, final int pos)
	{
		teamSlaves[pos].execute(r);
	}
		
	// Terminating the team of threads
	public final void shutdownThreads(){

		for(int i = 0; i < numThreads - 1; i++)
		{
			teamSlaves[i].shutdown();
		}
	}
}
