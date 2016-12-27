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

// Sample 14 ..................................................................
// This sample demonstrates using the ALLOC and INTO modifiers
//

// Size must be >= 16 and evenly divisible by 4
#define SIZE 100
#define QTR SIZE/4
#define HALF SIZE/2
#define ThreeQTR SIZE*3/4

#pragma offload_attribute(push, target(mic))
static int inp_14[SIZE];
static int micp_14[SIZE];
static int outp_14[SIZE];
#pragma offload_attribute(pop)

void sample14()
{
   int   num_devices;
   int   i;
   int   res;


   // The INTO() modifier requires a target device be installed and available

   // Check if target device(s) are installed and available

   #ifdef __INTEL_OFFLOAD
     num_devices = _Offload_number_of_devices();
   #else
     num_devices = 0;
   #endif

   if (num_devices == 0) {
       printf("*** FAIL Sample14 - target unavailable\n");
       return;
   }

   // Initialize input array
   for (i = 0; i < SIZE; i++)  {
       inp_14[i] = i + 10;
   }

   // The sample demonstrates use of the INTO and ALLOC modifiers

   // Given the following array sections
   //
   //           -----------------------
   // inp_14    | A  |  B  |  C  |  D  |
   //           -----------------------
   //
   //           -----------------------
   // micp_14   | E  |  F  |  G  |  H  |
   //           -----------------------
   //
   //           -----------------------
   // outp_14   | I  |  J  |  K  |  L  |
   //           -----------------------
   //
   // The offload pragma and associated code accomplish the following:
   //
   // 1. Allocates HALF (sections F & G ) of variable micp_14 on the Target CPU
   //
   // 2. Transfers one QUARTER of data (section A) of variable inp_14 from
   //    the host CPU INTO one QUARTER of the allocated HALF of variable 
   //    micp_14 (section G) on the Target CPU
   //
   // 3. Updates one QUARTER of data from variable micp_14 (section G) and 
   //    stores results into micp_14 (section F) on the Target CPU.
   //
   // 4. Transfers one QUARTER of data (section F) of variable micp_14 from
   //    the Target CPU INTO one QUARTER of the variable outp_14 (section L) 
   //    on the Host CPU
  
   #pragma offload target(mic)                                          \
                               in( inp_14[0 : QTR] :                    \
                                   alloc( micp_14[ QTR : HALF ] )       \
                                   into( micp_14[ HALF : QTR ] ) )      \
                               out( micp_14[ QTR : QTR ] :              \
                                    into( outp_14[ ThreeQTR : QTR ]) ) 
   {  

      // Update one QUARTER of data from variable micp_14 (section G) 
      // and store results into micp_14 (section F) on the Target CPU

      for (i = QTR; i < HALF; i++) {
          micp_14[i] = micp_14[i + QTR] + 100;
      }
   }

   //     Verify results

   res = 0;

   for (i = ThreeQTR; i < SIZE; i++) {
       res += (inp_14[i - ThreeQTR] != (outp_14[i] - 100) );
   } 

   printf("%s\n", ( res == 0 ) ? "PASS Sample14" : "*** FAIL Sample14\n");

   return;
}
