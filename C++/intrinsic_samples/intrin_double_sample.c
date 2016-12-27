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
 * This code sample demonstrates the use of C in comparison with SSE2
 * and SSE3 instrinsics to multiply two complex numbers.
 *
 * Do not run the sample on systems using processors that do
 * not support SSE2 and SSE3 instructions; the application will fail.
 *
 * [Compile]
 * Windows*: icl
 *
 * Linux* and OS X*: icc -o <output file name>
 *
 * [Output]
 * Complex Product(C):    23.00+ -2.00i
 * Complex Product(SSE3): 23.00+ -2.00i
 * Complex Product(SSE2): 23.00+ -2.00i
 *
 */

#include <stdio.h>
#include <pmmintrin.h>

typedef struct {
  double real;
  double img;
} complex_num;

// Multiplying complex numbers in C
void multiply_C(complex_num x, complex_num y, complex_num *z)
{
  z->real = (x.real*y.real) - (x.img*y.img);
  z->img  = (x.img*y.real)  + (y.img*x.real);
}

#if __INTEL_COMPILER
// Multiplying complex numbers using SSE3 intrinsics
void multiply_SSE3(complex_num x, complex_num y, complex_num *z)
{
  __m128d num1, num2, num3;

  // Duplicates lower vector element into upper vector element.
  //   num1: [x.real, x.real]

  num1 = _mm_loaddup_pd(&x.real);

  // Move y elements into a vector
  //   num2: [y.img, y.real]

  num2 = _mm_set_pd(y.img, y.real);

  // Multiplies vector elements
  //   num3: [(x.real*y.img), (x.real*y.real)]

  num3 = _mm_mul_pd(num2, num1);

  //   num1: [x.img, x.img]

  num1 = _mm_loaddup_pd(&x.img);

  // Swaps the vector elements
  //   num2: [y.real, y.img]

  num2 = _mm_shuffle_pd(num2, num2, 1);

  //   num2: [(x.img*y.real), (x.img*y.img)]

  num2 = _mm_mul_pd(num2, num1);

  // Adds upper vector element while subtracting lower vector element
  //   num3: [((x.real *y.img)+(x.img*y.real)),
  //          ((x.real*y.real)-(x.img*y.img))]

  num3 = _mm_addsub_pd(num3, num2);

  // Stores the elements of num3 into z

  _mm_storeu_pd((double *)z, num3);

}

#endif

#if __INTEL_COMPILER

// Multiplying complex numbers using SSE2 intrinsics

void multiply_SSE2(complex_num x, complex_num y, complex_num *z)

{
  __m128d num1, num2, num3, num4;

  // Copies a single element into the vector
  //   num1:  [x.real, x.real]

  num1 = _mm_load1_pd(&x.real);

  // Move y elements into a vector
  //   num2: [y.img, y.real]

  num2 = _mm_set_pd(y.img, y.real);

  // Multiplies vector elements
  //   num3: [(x.real*y.img), (x.real*y.real)]

  num3 = _mm_mul_pd(num2, num1);

  //   num1: [x.img, x.img]

  num1 = _mm_load1_pd(&x.img);

  // Swaps the vector elements.
  //   num2: [y.real, y.img]

  num2 = _mm_shuffle_pd(num2, num2, 1);

  //   num2: [(x.img*y.real), (x.img*y.img)]

  num2 = _mm_mul_pd(num2, num1);
  num4 = _mm_add_pd(num3, num2);
  num3 = _mm_sub_pd(num3, num2);
  num4 = _mm_shuffle_pd(num3, num4, 2);

  // Stores the elements of num4 into z

  _mm_storeu_pd((double *)z, num4);
}

#endif

int main()

{
  complex_num a, b, c;
  // Initialize complex numbers

  a.real =  3;
  a.img  =  2;
  b.real =  5;
  b.img  = -4;

  // Output for each: 23.00+ -2.00i

  multiply_C(a, b, &c);
  printf("Complex Product(C):    %2.2f+ %2.2fi\n", c.real, c.img);

#if __INTEL_COMPILER

  multiply_SSE3(a, b, &c);
  printf("Complex Product(SSE3): %2.2f+ %2.2fi\n", c.real, c.img);
  multiply_SSE2(a, b, &c);
  printf("Complex Product(SSE2): %2.2f+ %2.2fi\n", c.real, c.img);

#endif

  return 0;

}
