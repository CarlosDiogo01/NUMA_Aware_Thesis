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

int main(int argc, char* argv[])
{
    // Start calls to test functions
    printf("Samples started\n");

    // Invoke Samples 
	sample00();     // Check for targets and offload mode
	sample01();     // Scalars
	sample02();     // Scalars and named arrays
	sample03();     // Controlling data transfer
	sample04();     // Pointers
	sample05();     // Use alloc_if to receive result
	sample06();     // Use __MIC__ macro for target-specific code
	sample07();     // Use __MIC__ macro for data reuse on target
	sample08();     // Heterogeneous OpenMP
	sample09();     // Use Globals in functions called from offloaded region
	sample10();     // Bit-wise copyable structs
	sample11();     // Dealing with non-bit-wise copyable structs
	sample12();     // Multi-card
	sample13();     // Memory allocation pragma and asynchronous 
                        // offload and data transfer
	sample14();     // alloc and into modifiers

    // End of calls to test functions
    printf("Samples complete\n");
}
//.......................................................................driver
