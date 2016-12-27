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
!#      Example Program Text from Sample shrd_sampleCPP
!#*****************************************************************************/

#include <stdio.h>
#include <math.h>
#include <offload.h>

// shrd_ofld 00 ...............................................................
// This sample uses the _Offload_number_of_devices() (C/C++) API and checks
// to determine if the samples are running in offload or host mode.

_Cilk_shared int chk_target00();

void shrd_ofld00()
{
   int num_devices = 0;
   int offload_mode = 0;
   int target_ok;
   int i;

   printf("Checking for Intel(R) MIC Architecture (Target CPU) devices...\n\n");

#ifdef __INTEL_OFFLOAD
   num_devices = _Offload_number_of_devices();
#endif
   printf("Number of Target devices installed: %d\n\n",num_devices);

   if (num_devices < 1) {
      // Run in fallback-mode
      printf("Offload sections will execute on: Host CPU (fallback mode)\n\n");
      offload_mode = 0;
   }
   else {
      printf("Offload sections will execute on: Target CPU (offload mode)\n\n");
      offload_mode = 1;

      #pragma noinline
      for (i = 0; i < num_devices; i++) {
         target_ok = 0;
         target_ok = _Cilk_offload_to(i) chk_target00();

         if (! target_ok) {
            printf(" ***Warning: offload to device #%d : failed\n", i);
         }
       }
    }
}

_Cilk_shared int chk_target00()
{
    int retval;

    #ifdef __MIC__
        retval = 1;
    #else
        retval = 0;
    #endif

    // Return 1 if target available
    return retval;
}
//...........................................................................00
