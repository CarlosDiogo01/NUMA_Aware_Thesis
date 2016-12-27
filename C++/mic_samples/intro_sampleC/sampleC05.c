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

// Sample 05 ..................................................................
// This sample demonstrates receiving output results into a pointer
//
// The parameter "res" is a pointer where the caller expects to see the result
//
// The memory to receive results must be preallocated on the CPU
//
// In this example, the memory is allocated on the stack.
//
// The result is received into my_result in the caller

typedef double T;

#define SIZE 1000
static T in1_05[SIZE];
static T in2_05[SIZE];
static void populate_05(T* a, int s);

static void get_result(T* pin1, T* pin2, T* res, int size);

void sample05()
{
    T my_result[SIZE];
    populate_05(in1_05, SIZE);
    populate_05(in2_05, SIZE);

    get_result(in1_05, in2_05, my_result, SIZE);

    if (my_result[0] == 0 && my_result[SIZE-1] == 2*(SIZE-1))
        printf("PASS Sample05\n");
    else
        printf("*** FAIL Sample05\n");
}

static void get_result(T* pin1, T* pin2, T* res, int s)
{
    int i;

    #pragma offload target(mic)         \
            in(pin1, pin2 : length(s))      \
            out(res : length(s)) 
    {
	for (i=0; i<s; i++)
	{
		res[i] = pin1[i] + pin2[i];
	}
    }
}

static void populate_05(T* a, int s)
{
    int i;

    for (i=0; i<s; i++)
        {
              a[i] = i;
        }
}
//...........................................................................05
