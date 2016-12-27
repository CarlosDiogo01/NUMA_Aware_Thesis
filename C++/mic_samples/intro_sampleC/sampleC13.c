/*******************************************************************************
!#
!#  Copyright (C) 2012 Intel Corporation. All Rights Reserved.
!#
!#  The source code contained or described herein and all
!#  documents related to the source code ("Material") are owned by
!#  Intel Corporation or its suppliers or licensors. Title to the
!#  Material remains with Intel Corporation or its suppliers and
!#  licensors. The Material is protected by worldwide copyright
!#  laws and treaty provisions.  No part of the Material may be
!#  used, copied, reproduced, modified, published, uploaded,
!#  posted, transmitted, distributed,  or disclosed in any way
!#  except as expressly provided in the license provided with the
!#  Materials.  No license under any patent, copyright, trade
!#  secret or other intellectual property right is granted to or
!#  conferred upon you by disclosure or delivery of the Materials,
!#  either expressly, by implication, inducement, estoppel or
!#  otherwise, except as expressly provided in the license
!#  provided with the Materials.
!#
!#
!#******************************************************************************
!# Content:
!#      Intel(R) C++ Composer XE 2013
!#      Example Program Text from Sample intro_sampleC
!#*****************************************************************************/

#include <stdio.h>
#include <sys/time.h>
#include <stdlib.h> 
#include <unistd.h>

// Sample 13 ..................................................................
// This sample demonstrates using the offload_transfer and offload_wait 
// pragmas for memory allocation on the target device  and for performing
// asynchronous data transfers 
//

#pragma offload_attribute(push, target(mic))
int cnt_13 = 64000;
int iter_13 = 100;
static float *in1_13, *res1_13;
static float *in2_13, *res2_13;
#pragma offload_attribute(pop)

float sync_sum, async_in_sum, async_out_sum;

float sum_array13(float *x);


__attribute__ (( target (mic))) void compute13(float *x, float *y)
{
   int i;

   #pragma omp parallel for num_threads(4) private(i)
   for (i=0; i < cnt_13; i++)
   {
      y[i] = x[i] * x[i];

#ifdef DEBUG
      if (i == 0 || i  == cnt_13/2 || i  == cnt_13-1) {
          printf("compute13: x[%d] = %f y[%d] = %f \n", i,x[i],i,y[i]);
          fflush(0);
      }
#endif
   }
}

void use_result(float *x)
{
 // function could perform other post offload uses of data on host
}

void do_sync()
{
   float lsum;  
   int i;

   lsum = 0.0f;  

   // Perform computations and use synchronous data transfers

   for (i=0; i < iter_13; i++)
   {
      if (i%2 == 0) {

      #pragma offload target(mic:0)  \
              in(in1_13   : length(cnt_13) alloc_if(0) free_if(0) )  \
              out(res1_13 : length(cnt_13) alloc_if(0) free_if(0) )
         {
         compute13(in1_13, res1_13);
         }

         lsum = lsum + sum_array13(res1_13);
      }

      else {

      #pragma offload target(mic:0)  \
              in(in2_13   : length(cnt_13) alloc_if(0) free_if(0) )  \
              out(res2_13 : length(cnt_13) alloc_if(0) free_if(0) )
         {
         compute13(in2_13, res2_13);
         }

         lsum = lsum + sum_array13(res2_13);
      }

   }
   sync_sum = lsum / (float) iter_13;
}

void do_async_in()
{

   //  Perform computation and use asynchronous offload IN data
   //  transfers

   float lsum;  
   int i;

   lsum = 0.0f;  

   //  The offload_transfer pragma is a stand-alone extension that is not 
   //  associated with any compound statement that follows it.

   //  Set transfers in motion with an initial transfer of in1_13
   #pragma offload_transfer target(mic:0)   \
           in(in1_13 : length(cnt_13) alloc_if(0) free_if(0) ) signal(in1_13)


   // Loop over all iterations transferring and computing using
   // a double buffer method

   for (i=0; i < iter_13; i++)
   {
      if (i%2 == 0) {

         //  For even # iter values less than iter-1, initiate tranfer 
         //  of in2_13 
         #pragma offload_transfer target(mic:0) if(i!=iter_13-1)  \
                 in(in2_13 : length(cnt_13) alloc_if(0) free_if(0) ) \
                 signal(in2_13)

         //  Wait for in1_13 and when ready, then offload compute
         #pragma offload target(mic:0) nocopy(in1_13) wait(in1_13)  \
                 out(res1_13 : length(cnt_13) alloc_if(0) free_if(0) )
         {
            compute13(in1_13, res1_13);
         }

         lsum = lsum + sum_array13(res1_13);
      } 

      else {
         //  For odd # iter values less than iter-1, initiate transfer 
         //  of in1_13 
         #pragma offload_transfer target(mic:0) if(i!=iter_13-1) \
                 in(in1_13 : length(cnt_13) alloc_if(0) free_if(0) ) \
                 signal(in1_13)

         //  Wait for in2_13 and when ready, then offload compute
	 #pragma offload target(mic:0) nocopy(in2_13) wait(in2_13) \
                 out(res2_13 : length(cnt_13) alloc_if(0) free_if(0) )
         {
            compute13(in2_13, res2_13);
         }

         lsum = lsum + sum_array13(res2_13);
      }
   }
   async_in_sum = lsum / (float) iter_13;
}

void do_async_out()
{

   //  Perform computation and use asynchronous offload OUT data
   //  transfers

   float lsum;  

   int i;

   lsum = 0.0f;  

   // Loop over all iterations transferring and computing using
   // a double buffer method

   for (i=0; i < iter_13+1; i++)
   {
      if (i%2 == 0) {
         if (i < iter_13) {

            //  The offload_transfer pragma is a stand-alone extension that is 
            //  not associated with any compound statement that follows it.

            //  For even # iter counts, compute res1_13 and leave values on 
            //  the target device  
	    #pragma offload target(mic:0) in(in1_13 : length(cnt_13) \
                            alloc_if(0) free_if(0) ) nocopy(res1_13)
            compute13(in1_13, res1_13);

            //  Initiate transfer of res1_13 back to the host and proceed
            #pragma offload_transfer target(mic:0)  \
                            out(res1_13 : length(cnt_13) \
                            alloc_if(0) free_if(0) ) signal(res1_13)
         }

         if (i > 0) {

            //  The offload_wait pragma is a stand-alone extension that is 
            //  not associated with any compound statement that follows it.

            //  After all iterations are complete, perform one final wait 
            //  on res2_13
            #pragma offload_wait target(mic:0) wait(res2_13)

            //  After final wait, other use of res2_13 on the host is now 
            //  possible
            lsum = lsum + sum_array13(res2_13);
            use_result(res2_13);
         }

      }

      else {

         if (i < iter_13) {

            //  For odd # iter counts, compute res2_13 and leave values on 
            //  the target device 
            #pragma offload target(mic:0) in(in2_13 : length(cnt_13) \
                            alloc_if(0) free_if(0) ) nocopy(res2_13)
            compute13(in2_13, res2_13);

            //  Initiate transfer of res2_13 back to host and proceed
            #pragma offload_transfer target(mic:0) \
                            out(res2_13 : length(cnt_13) \
                            alloc_if(0) free_if(0) ) signal(res2_13)
         }
         //  The offload_wait pragma is a stand-alone extension that is 
         //  not associated with any compound statement that follows it.

         //  Wait for res1_13 before restarting main loop
	 #pragma offload_wait target(mic:0) wait(res1_13)

         //  After final wait, other use of res1_13 on the host is now 
         //  possible
         lsum = lsum + sum_array13(res1_13);
	 use_result(res1_13);
       }
   }
   async_out_sum = lsum / (float) iter_13;
}

double get_TIME()
{
   struct timeval tp;

   // Return current timestamp

   gettimeofday(&tp, NULL);
   return((double)(tp.tv_sec) + (double)(tp.tv_usec)/1E6);
}

float sum_array13(float *x)
{
   int i;
   float res=0.0f;

   // Return sum of array

   for (i=0; i < cnt_13; i++)
   {
      res = res + x[i];
   }
   return(res);
}

void populate_13()
{
   int i;
 
   // Initialize arrasy

   for (i=0; i < cnt_13; i++)
   {
      in1_13[i] = (float) (i * .001);
      in2_13[i] = (float) (i * .001);
      res1_13[i] = 0;
      res2_13[i] = 0;
   }
}


void sample13()
{
   int num_devices, i;
   double st_time, end_time;
   double sync_tm, async_in_tm, async_out_tm;

   //  Allocate arrays

   in1_13 = (float*)malloc(cnt_13*sizeof(float));
   if (!in1_13)
   {
      printf("*** FAIL Sample13 - in1_13 allocate failed\n");
      return;
   }

   res1_13 = (float*)malloc(cnt_13*sizeof(float));
   if (!res1_13)
   {
      printf("*** FAIL Sample13 - res1_13 allocate failed\n");
      return;
   }

   in2_13 = (float*)malloc(cnt_13*sizeof(float));
   if (!in2_13)
   {
      printf("*** FAIL Sample13 - in2_13 allocate failed\n");
      return;
   }

   res2_13 = (float*)malloc(cnt_13*sizeof(float));
   if (!res2_13)
   {
      printf("*** FAIL Sample13 - res2_13 allocate failed\n");
      return;
   }

   // Sample requires target device(s) be installed and available

   // Check if target device(s) are installed and available
   #ifdef __INTEL_OFFLOAD
      num_devices = _Offload_number_of_devices();
   #else
      num_devices = 0;
   #endif

   if (num_devices == 0) {
       printf("*** FAIL Sample13 - target unavailable\n");
       return;
   }

   // Allocate memory on target device only and retain for the
   // duration of the sample

   #pragma offload_transfer target(mic:0) in(cnt_13)  \
           nocopy(in1_13, res1_13, in2_13, res2_13 : length(cnt_13) \
           alloc_if(1) free_if(0) )


   // Perform computations and use synchronous data transfers 

   // Initialize arrays
   populate_13();

   st_time=get_TIME();

   do_sync();

   end_time=get_TIME();

   sync_tm = (end_time - st_time);

   // Perform computations and use asynhcronous IN data transfers 

   // Initialize arrays
   populate_13();

   st_time=get_TIME();

   do_async_in();

   end_time=get_TIME();

   async_in_tm = (end_time - st_time);

   // Perform computations and use asynchronous OUT data transfers
 
   // Initialize arrays
   populate_13();

   st_time=get_TIME();

   do_async_out();

   end_time=get_TIME();

   async_out_tm = (end_time - st_time);

   // Validate results

   if ( (sync_sum > 0.0f) & (sync_sum == async_in_sum ) & \
        (sync_sum == async_out_sum) )
      {
#ifdef DEBUGT
        printf("PASS Sample13 -");
        printf(" times (secs): sync: %.3lf /",sync_tm);
        printf(" async_in: %.3lf / async_out: %.3lf \n",async_in_tm, async_out_tm);
#else
        printf("PASS Sample13\n");
#endif
      }
   else
        printf("*** FAIL Sample13\n");

#ifdef DEBUG
   printf(" Sums: sync: %.2f / async_in: %.2f / async_out: %.2f \n",sync_sum, async_in_sum, async_out_sum);
#endif

   // Free allocations on target device

   #pragma offload_transfer target(mic:0) \
           nocopy(in1_13, res1_13, in2_13, res2_13 : length(cnt_13) \
           alloc_if(0) free_if(1) )

   return;
}
