/*
    Copyright 2005-2012 Intel Corporation.  All Rights Reserved.

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
*/

/*
    The original source for this example is
    Copyright (c) 1994-2008 John E. Stone
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
    3. The name of the author may not be used to endorse or promote products
       derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
    OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
    OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
    HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
    OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    SUCH DAMAGE.
*/


/******************************************************************************
The tachyon sample program is for use with 
    the Intel C++ Composer XE 2013 Getting Started Tutorials -> 
        Tutorial: Using Intel(R) C++ Compiler -> 
            Threading Your Applications

Please refer to the tutorial for build instructions. 
*******************************************************************************/


#include "../machine.h"
#include "../types.h"
#include "../macros.h"
#include "../vector.h"
#include "../tgafile.h"
#include "../trace.h"
#include "../light.h"
#include "../shade.h"
#include "../camera.h"
#include "../util.h"
#include "../intersect.h"
#include "../global.h"
#include "../ui.h"
#include "../video.h"
#include <omp.h>

// shared but read-only so could be private too
static thr_parms *all_parms;
static scenedef scene;
static int startx;
static int stopx;
static int starty;
static int stopy;
static flt jitterscale;
static int totaly;

static color_t render_one_pixel (int x, int y, unsigned int *local_mbox, unsigned int &serial,
                                 int startx, int stopx, int starty, int stopy)
{
    /* private vars moved inside loop */
    ray primary, sample;
    color col, avcol;
    int R,G,B;
    intersectstruct local_intersections;   
    int alias;
    /* end private */

    primary=camray(&scene, x, y);
    primary.intstruct = &local_intersections;
    primary.flags = RT_RAY_REGULAR;

    serial++;
    primary.serial = serial;  
    primary.mbox = local_mbox;
    primary.maxdist = FHUGE;
    primary.scene = &scene;
    col=trace(&primary);  

    serial = primary.serial;

    /* perform antialiasing if enabled.. */
    if (scene.antialiasing > 0) {
        for (alias=0; alias < scene.antialiasing; alias++) {

            serial++; /* increment serial number */
            sample=primary;  /* copy the regular primary ray to start with */
            sample.serial = serial; 

            {
                sample.d.x+=((std::rand() % 100) - 50) / jitterscale;
                sample.d.y+=((std::rand() % 100) - 50) / jitterscale;
                sample.d.z+=((std::rand() % 100) - 50) / jitterscale;
            }

            avcol=trace(&sample);  

            serial = sample.serial; /* update our overall serial # */

            col.r += avcol.r;
            col.g += avcol.g;
            col.b += avcol.b;
        }

        col.r /= (scene.antialiasing + 1.0);
        col.g /= (scene.antialiasing + 1.0);
        col.b /= (scene.antialiasing + 1.0);
    }

    /* Handle overexposure and underexposure here... */
    R=(int) (col.r*255);
    if (R > 255) R = 255;
    else if (R < 0) R = 0;

    G=(int) (col.g*255);
    if (G > 255) G = 255;
    else if (G < 0) G = 0;

    B=(int) (col.b*255);
    if (B > 255) B = 255;
    else if (B < 0) B = 0;

    return video->get_color(R, G, B);

}

static void draw_task (void)
{
//creating parallel region (team of threads)
//todo: uncomment following line  in OpenMP implementation
//#pragma omp parallel 
    {
        unsigned int serial = 1;
        int ison=1;
        unsigned int mboxsize = sizeof(unsigned int)*(max_objectid() + 20);
        unsigned int * local_mbox = (unsigned int *) alloca(mboxsize);
        memset(local_mbox,0,mboxsize);
        // Distributing loop iterations within the team of threads.
        // Set dynamic schedual. By default schedual is static.
	//todo: uncomment following line  in OpenMP implementation
	//#pragma omp for schedule(dynamic) 
        for(int y = starty; y < stopy; y++) {
            if ( ison ) {
                drawing_area drawing(startx, totaly-y, stopx-startx, 1);
                for (int x = startx; x < stopx; x++) {
                    color_t c = render_one_pixel (x, y, local_mbox, serial, startx, stopx, starty, stopy);
                    drawing.put_pixel(c);
                }; // for
                if(!video->next_frame()) {
                    ison=0;
                 // return cannot be inside parallel region. 
		 //todo: comment out following line in OpenMP implementation
		return;
		//todo: uncomment following line  in OpenMP implementation
//			ison=0;

                }; // if
            }; // if
        }; // for
    } // parallel
//todo: uncomment following line  in OpenMP implementation
// return;
}

void * thread_trace(thr_parms * parms)
{
    // shared but read-only so could be private too
    all_parms = parms;
    scene = parms->scene;
    startx = parms->startx;
    stopx = parms->stopx;
    starty = parms->starty;
    stopy = parms->stopy;
    jitterscale = 40.0*(scene.hres + scene.vres);
    totaly = parms->scene.vres-1;

    draw_task ();

    return(NULL);  
}
