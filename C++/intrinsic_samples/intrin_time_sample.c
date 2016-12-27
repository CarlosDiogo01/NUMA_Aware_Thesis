/*
 * Copyright (C) 2006-2012 Intel Corporation. All Rights Reserved.
 *
 * The source code contained or described herein and all
 * documents related to the source code ("Material") are owned by 
 * Intel Corporation or its suppliers or licensors. Title to the
 * Material remains with Intel Corporation or its suppliers and
 * licensors. The Material is protected by worldwide copyright
 * laws and treaty provisions.  No part of the Material may be
 * used, copied, reproduced, modified, published, uploaded,
 * posted, transmitted, distributed,  or disclosed in any way
 * except as expressly provided in the license provided with the
 * Materials.  No license under any patent, copyright, trade
 * secret or other intellectual property right is granted to or
 * conferred upon you by disclosure or delivery of the Materials,
 * either expressly, by implication, inducement, estoppel or
 * otherwise, except as expressly provided in the license
 * provided with the Materials. 
 *
 * [DESCRIPTION]
 * This code sample demonstrates how to use intrinsics to  
 * read the time stamp counter. The _rdtsc() function 
 * returns the current value of the processor's 64-bit time stamp counter.
 *
 * Run this sample on systems based on IA-32 and Intel(R) 64 architectures only.
 *
 * [Compile]
 * Windows*: icl
 *
 * Linux* and OS X*: icc -o <output file name>
 *
 */
                
#include <stdio.h>

int main()
{
 #if __INTEL_COMPILER
  __int64 start, stop, elaspe;
  int i;
  int arr[10000];
  start= _rdtsc();  
  for(i=0; i<10000; i++)

  {
    arr[i]=i;
  }

  stop= _rdtsc();
  elaspe = stop -start;
  printf("Processor cycles\n %I64u\n", elaspe); 

  #else
  printf("Use INTEL Compiler in order to implement\n");
  printf("_rdtsc intrinsic\n");

  #endif
  return 0;
}