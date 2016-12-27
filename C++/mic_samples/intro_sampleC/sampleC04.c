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

// Sample 04 ..................................................................
// This sample uses pointers
//
// With a pointer, defining a length is essential since the compiler cannot 
// guess the program's intent
//
// The length of the data associated with the pointer is specified and also
// the direction in which to transfer the data

typedef double T;

#define SIZE 1000
static T in1_04[SIZE];
static T in2_04[SIZE];
static __attribute((target(mic))) T res_04[SIZE];
static void populate_04(T* a, int s);

void sample04()
{
    T* p1, *p2;
    int i;
    int s;
    populate_04(in1_04, SIZE);
    populate_04(in2_04, SIZE);

    p1 = in1_04;
    p2 = in2_04;
    s = SIZE;

    #pragma offload target(mic) in(p1, p2:length(s)) out(res_04)
    {
	for (i=0; i<s; i++)
	{
		res_04[i] = p1[i] + p2[i];
	}
    }

    if (res_04[0] == 0 && res_04[SIZE-1] == 2*(SIZE-1))
        printf("PASS Sample04\n");
    else
        printf("*** FAIL Sample04\n");
}

static void populate_04(T* a, int s)
{
    int i;

    for (i=0; i<s; i++)
        {
              a[i] = i;
        }
}
//...........................................................................04
