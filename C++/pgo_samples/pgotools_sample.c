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
 * Demonstrates how to use Profile-guided Optimization (PGO) 
 * to optimize performance. Illustrates how to use the PGO
 * tools: code coverage and test prioritization.
 *
 * For code coverage, the comment indicate the covered and uncovered
 * functions; cover indicates covered functions or code blocks, and 
 * no_cover indicates functions or code block that are not covered by
 * the tool.
 *
 * [COMPILE]
 * See the Intel(R) C++ Compiler Documentation for information 
 * on using the PGO tools and using PGO to compile applications.
 *
 * Use the following general options and tool, in the order shown,
 * to profile an application:
 * 
 * Windows*:            /Qprof-gen
 *                       profmerge
 *                      /Qprof-use   
 * 
 * Linux* and OS X*:  -prof-gen
 *                       profmerge
 *                      -prof-use   
 *
 */ 
  
 #include <stdio.h> 
  
 static int one_arg()                // cover 0 
 { 
   printf("First function.\n"); 
   return 1; 
 } 
  
 static int two_args()               // cover 1 
 { 
   printf("Second function.\n"); 
   return 2; 
 } 
  
 static int three_args()             // no_cover 
 { 
   printf("Third function.\n"); 
   return 3; 
 } 
 
 static int decide(int argc)         // no_cover 0,1 
 { 
   switch (argc) {                   // cover 0,1 
     case 1:  return one_arg();      // cover 0 
     case 2:  return two_args();     // cover 1 
     case 3:  return three_args();   // no_cover 
     default: return 4;              // no_cover 
   }                                 // cover 0,1 
   return 5;                         // cover 0,1 
 }                                   // cover 0,1 
  
 int main(int argc, char *argv[]) 
 { 
   int res = decide(argc); 
   printf("Decision: %d\n", res); 
   return 0; 
 } 