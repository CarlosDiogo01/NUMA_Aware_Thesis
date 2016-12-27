/*
 * Copyright (C) 2011-2012 Intel Corporation. All Rights Reserved.
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
 * Part of the Guided Auto Parallel feature tutorial
 * For instructions on how to use this sample, please refer to the
 * tutorial in the Intel(R) C++ Composer XE documentation
 *
 */ 

#include "scalar_dep.h"


/*
 * loop will be vectorized if variable b can be unconditionally initialized
 * at the top of every iteration.
 *
 */


void test_scalar_dep(double *A, int n)
{
  int i;
  double b;

	//TODO: GAP suggested the following changes to get the loop to parallelize
	/* GAP REPORT LOG OPENED ON Thu Jan 13 12:43:11 2011
	scalar_dep.cpp(80): remark #30523: (PAR) Assign a value to the variable(s)
	"b" at the beginning of the body of the loop in line 76. This will allow 
	the loop to be parallelized. [VERIFY] Make sure that, in the original 
	program, the variable(s) "b" read in any iteration of the loop has been 
	defined earlier in the same iteration. [ALTERNATIVE] Another way is to 
	use "#pragma parallel private(b)" to parallelize the loop. [VERIFY] The 
	same conditions described previously must hold.

	scalar_dep.cpp(80): remark #30525: (PAR) Insert a "#pragma loop count 
	min(256)" statement right before the loop at line 76 to parallelize the 
	loop. [VERIFY] Make sure that the loop has a minimum of 256 iterations.
	Number of advice-messages emitted for this compilation session: 2.

	END OF GAP REPORT LOG */

	//TODO: GAP suggested the following changes to get the loop to parallelize
	/* GAP REPORT LOG OPENED ON Thu Jan 13 13:09:59 2011
	scalar_dep.cpp(80): remark #30515: (VECT) Assign a value to the variable(s)
	"b" at the beginning of the body of the loop in line 69. This will allow 
	the loop to be vectorized. [VERIFY] Make sure that, in the original program, 
	the variable(s) "b" read in any iteration of the loop has been defined 
	earlier in the same iteration.

	Number of advice-messages emitted for this compilation session: 1.
	END OF GAP REPORT LOG */

#ifdef TEST_GAP
#pragma loop count min (188)
  for (i=0; i<n; i++) {
        b = A[i];
    if (A[i] > 0) {A[i] = 1 / A[i];}
    if (A[i] > 1) {A[i] += b;}
  }

#else

for (i=0; i<n; i++) {
    if (A[i] > 0) {b=A[i]; A[i] = 1 / A[i]; }
    if (A[i] > 1) {A[i] += b;}
  }
#endif

}



