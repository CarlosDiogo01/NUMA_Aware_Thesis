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
!#      Example Program Text from Sample shrd_sampleC
!#*****************************************************************************/

#include <stdio.h>

extern "C" void shrd_ofld00();
extern "C" void shrd_ofld01();
extern "C" void shrd_ofld02();
extern "C" void shrd_ofld03();
extern "C" void shrd_ofld04();
extern "C" void shrd_ofld05();
extern "C" void shrd_ofld06();
extern "C" void shrd_ofld07();
extern "C" void shrd_ofld08();
extern "C" void shrd_ofld09();
extern "C" void shrd_ofld10();
extern "C" void shrd_ofld11();
extern "C" void shrd_ofld12();
extern "C" void shrd_ofld13();
extern "C" void shrd_ofld14();

int main(int argc, char* argv[])
{
    // Start calls to test functions
    printf("Samples started\n");

    // Invoke Samples
    shrd_ofld00();  // Check for targets and offload mode
    shrd_ofld01();  // Shared scalars
    shrd_ofld02();  // Shared arrays
    shrd_ofld03();  // Shared structs
    shrd_ofld04();  // String allocation on Target
    shrd_ofld05();  // Pointer return
    shrd_ofld06();  // Cilk_spawn _Cilk_offload
    shrd_ofld07();  // _Cilk_offload _Cilk_for
    shrd_ofld08();  // Multiple Cilk_spawn _Cilk_offload
    shrd_ofld09();  // Mixed Multiple _Cilk_offload and Cilk_spawn _Cilk_offload
    shrd_ofld10();  // Use OpenMP in offloaded routine
    shrd_ofld11();  // Use Shared Malloc API
    shrd_ofld12();  // Multi-card _Cilk_offload_to
    shrd_ofld13();  // Multi-card Cilk_spawn _Cilk_offload_to
    shrd_ofld14();  // Multi-card _Cilk_offload_to with string allocation

    // End of calls to test functions
    printf("Samples complete\n");
}
//.......................................................................driver
