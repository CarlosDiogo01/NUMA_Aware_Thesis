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

// Sample 07 ..................................................................
// This sample demonstrates use of the __MIC__ macro and data
// persistence.
//
// The macro __MIC__ can be used to determine target availability
// and if a computation actually occurred on the target
//
// If one computation on the target leaves some data behind
// for a subsequent computation to reuse, then we need to be
// certain the first computation was offloaded
//
// This sample requires a target be available and using same target 
// which is required to guarantee the integrity of data persistence. 
// When no target is available, execution does not default to the CPU 
// and the sample reports a failure.

#define SIZE 1000

__attribute__((target(mic))) int array1[SIZE];
__attribute__((target(mic))) int send_array(int* p, int s);
__attribute__((target(mic))) void compute07(int* out, int size);

void sample07()
{
    int in_data[16] = { 1, 2, 3, 4, 5, 6, 7, 8,
                        9, 10, 11, 12, 13, 14, 15, 16 };
    int out_data[16];
    int array_sent = 0;
    int num_devices;

    // Check if target device(s) are installed and available
    #ifdef __INTEL_OFFLOAD
      num_devices = _Offload_number_of_devices();
    #else
      num_devices = 0;
    #endif

    if (num_devices == 0) {
        printf("*** FAIL Sample07 - target unavailable\n");
        return;
    }

    #pragma offload target(mic : 0)
    array_sent = send_array(in_data, 16);

    #pragma offload target(mic : 0) if(array_sent) out(out_data)
    compute07(out_data, 16);

    if (out_data[0] == 2 && out_data[15] == 32)
       printf("PASS Sample07\n");
    else
       printf("*** FAIL Sample07\n");
}

__attribute__((target(mic))) int send_array(int* p, int s)
{
    int retval;
    int i;

    for (i=0; i<s; i++)
    {
        array1[i] = p[i];
    }

#ifdef __MIC__
    retval = 1;
#else
    retval = 0;
#endif

    // Return 1 if array initialization was done on target
    return retval;
}

__attribute__((target(mic))) void compute07(int* out, int size)
{
    int i;

    for (i=0; i<size; i++)
    {
        out[i] = array1[i]*2;
    }
}
//...........................................................................07
