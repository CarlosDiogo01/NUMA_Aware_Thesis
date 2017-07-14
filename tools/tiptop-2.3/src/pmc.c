/*
 * This file is part of tiptop.
 *
 * Author: Erven ROHOU
 * Copyright (c) 2011, 2012, 2014, 2015 Inria
 *
 * License: GNU General Public License version 2.
 *
 */

#define _GNU_SOURCE  /* for syscall */
#include <unistd.h>

#include <asm/unistd.h>
#include <errno.h>
#include <sys/types.h>

#include "pmc.h"

long perf_event_open(struct STRUCT_NAME *hw_event,
                     pid_t pid,
                     int cpu,
                     int group_fd,
                     unsigned long flags)
{
  int ret;

  ret = syscall(SYSCALL_NUM, hw_event, pid, cpu, group_fd, flags);
#if defined(__x86_64__) || defined(__i386__)
  if ( ret < 0 && ret > -4096 ) {
    errno = -ret;
    ret = -1;
  }
#endif

  return ret;
}
