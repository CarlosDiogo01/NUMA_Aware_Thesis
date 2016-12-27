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
 * This C code sample demonstrates how to use C, MMX, and SSE3
 * instrinsics to calculate the dot product of two vectors.
 *
 * Do not run the sample on systems using processors that do
 * not support MMX and SSE3 intrinsics; the application will fail.
 *
 * [Compile]
 * Windows*: icl
 *
 * Linux* and OS X*: icc -o <output file name>
 * 
 * [Output]
 * Dot Product computed by C: 506.000000
 * Dot Product computed by SSE2 intrinsics:  506.000000
 * Dot Product computed by MMX intrinsics:  506
 *
 */ 


#include <stdio.h>
#include <pmmintrin.h>
#define SIZE 12  //assumes size is a multiple of 4 because MMX and SSE
                 //registers will store 4 elements.

// Computes dot product using C
  float dot_product(float *a, float *b);
// Computes dot product using intrinsics
  float dot_product_intrin(float *a, float *b);
// Computes dot product using MMX intrinsics
  short MMX_dot_product(short *a, short *b);

int main()
{
  float x[SIZE], y[SIZE];
  short a[SIZE], b[SIZE];
  int i;
  float product;
  short mmx_product;

  for(i=0; i<SIZE; i++)

  {
    x[i]=i;
    y[i]=i;
    a[i]=i;
    b[i]=i;
  }

  product= dot_product(x, y);
  printf("Dot Product computed by C: %f\n", product);  
  

  #if __INTEL_COMPILER
  product =dot_product_intrin(x,y);
  printf("Dot Product computed by SSE2 intrinsics:  %f\n", product); 
  mmx_product =MMX_dot_product(a,b);
  printf("Dot Product computed by MMX intrinsics:  %d\n", mmx_product); 

  #else
  printf("Use INTEL compiler in order to calculate dot product\n");
  printf("usng intrinsics\n");

  #endif
  return 0;
}

float dot_product(float *a, float *b)
{

  int i;
  int sum=0;
  for(i=0; i<SIZE; i++)
  {
    sum += a[i]*b[i];
  }
  return sum;
}

#if __INTEL_COMPILER
float dot_product_intrin(float *a, float *b)
{
  float arr[4];
  float total;
  int i;
  __m128 num1, num2, num3, num4;
  num4= _mm_setzero_ps();  //sets sum to zero
  for(i=0; i<SIZE; i+=4)
  {
    num1 = _mm_loadu_ps(a+i);   //loads unaligned array a into num1  num1= a[3]  a[2]  a[1]  a[0]
    num2 = _mm_loadu_ps(b+i);   //loads unaligned array b into num2  num2= b[3]   b[2]   b[1]  b[0]
    num3 = _mm_mul_ps(num1, num2); //performs multiplication   num3 = a[3]*b[3]  a[2]*b[2]  a[1]*b[1]  a[0]*b[0]
    num3 = _mm_hadd_ps(num3, num3); //performs horizontal addition 
                              //num3=  a[3]*b[3]+ a[2]*b[2]  a[1]*b[1]+a[0]*b[0]  a[3]*b[3]+ a[2]*b[2]  a[1]*b[1]+a[0]*b[0]
    num4 = _mm_add_ps(num4, num3);  //performs vertical addition
  }

  num4= _mm_hadd_ps(num4, num4);
  _mm_store_ss(&total,num4); 
  return total;
}

//MMX technology cannot handle single precision floats
short MMX_dot_product(short *a, short *b)
{
  int i;
  short result, data;
  __m64 num3, sum;
  __m64 *ptr1, *ptr2;

  sum = _mm_setzero_si64(); //sets sum to zero
  for(i=0; i<SIZE; i+=4){
   ptr1 = (__m64*)&a[i];  //Converts array a to a pointer of type
                          //__m64 and stores four elements into MMX
                          //registers
   ptr2 = (__m64*)&b[i];
   num3 = _m_pmaddwd(*ptr1, *ptr2); //multiplies elements and adds lower
                                    //elements with lower element and
                                    //higher elements with higher
   sum = _m_paddw(sum, num3);       
   }

   data = _m_to_int(sum);     //converts __m64 data type to an int
   sum= _m_psrlqi(sum,32);    //shifts sum    
   result = _m_to_int(sum);   
   result= result+data;      
   _m_empty();  //clears the MMX registers and MMX state.
   return result;
}
#endif