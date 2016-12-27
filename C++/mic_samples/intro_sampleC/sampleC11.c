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
#include <stdlib.h>
#include <string.h>

// Sample 11 ..................................................................
// The first version of the offload implementation does not support copying
// of classes/structs that are not simply bit-wise copyable
//
// Sometimes it is necessary to get a struct across
//
// This needs to be done by transporting the members individually
// and reconstructing the struct on the other side

typedef struct
{
    int m1;
    char *m2;
} nbwcs;

void __attribute__((target(mic))) set_length(nbwcs *s);

void sample11()
{
    char *string = "string";
    int str_len = strlen(string);
    char *stringp = malloc(str_len+1);
    memcpy(stringp, string, str_len+1);
    nbwcs struct1;
    struct1.m1 = 0;
    struct1.m2 = stringp;
    int m1;
    char *m2;

    // Disassemble the struct for transfer to target
    m1 = struct1.m1;
    m2 = struct1.m2;

    #pragma offload target(mic) inout(m1) inout(m2 : length(str_len+1))
    {
        nbwcs struct2;
        //Reassemble the struct on the target
        struct2.m1 = m1;
        struct2.m2 = m2;

        // Use the non-bitwise copyable struct
        set_length(&struct2);

        // Disassemble it for copying back to CPU
        m1 = struct2.m1;
        m2 = struct2.m2;
    }
    // Reassemble struct received from target
    struct1.m1 = m1;
    struct1.m2 = m2;

    if (struct1.m1 == str_len)
        printf("PASS Sample11\n");
    else
        printf("*** FAIL Sample11\n");
}

void __attribute__((target(mic))) set_length(nbwcs *s)
{
    s->m1 = strlen(s->m2);
}
//...........................................................................11
