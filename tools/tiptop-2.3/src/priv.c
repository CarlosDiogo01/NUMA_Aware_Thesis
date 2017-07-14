/*
 * This file is part of tiptop.
 *
 * Author: Erven ROHOU
 * Copyright (c) 2014, 2015 Inria
 *
 * License: GNU General Public License version 2.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

#include "error.h"
#include "priv.h"

/* Rationale: a user can attach performance counters only to processes
   it owns. When the paranoia level is high, a normal user cannot
   observe kernel events.

   To overcome this, tiptop may be installed root-setuid (at your own
   risk). To minimize the risk, we immediately drop root privilege,
   and restore it only for the time of the perf_event_open system
   call.
 */


/* Initial values of the user ID values. */
static uid_t euid = -1;
static uid_t uid =  -1;


/* Used for initial call. We check and store uid and effective uid,
   and drop any extra privilege we might have. */
uid_t init_drop_privilege()
{
  euid = geteuid();
  uid = getuid();
  drop_privilege();

  return euid;
}



/* This is where we drop privilege. */
void drop_privilege()
{
  if (euid != uid) {
    /* only do it if needed, otherwise skip  the call */
    int res = seteuid(uid);
    if (res == -1) {
      /* do not proceed as somebody else */
      fprintf(stderr, "Cannot change privileges. Aborting.\n");
      exit(EXIT_FAILURE);
    }
  }
}


/* This is where we restore privilege. Original effective uid was
   saved when we droped privilege. It can be restored. */
void restore_privilege()
{
  if (euid != uid) {
    /* only do it if needed, otherwise skip  the call */
    int res = seteuid(euid);
    if (res == -1) {
      /* this should really not happen */
      error_printf("Cannot restore privileges. "
                   "This will likely cause problems.");
    }
  }
}
