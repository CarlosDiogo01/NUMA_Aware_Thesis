/*
 * This file is part of tiptop.
 *
 * Author: Erven ROHOU
 * Copyright (c) 2014 Inria
 *
 * License: GNU General Public License version 2.
 *
 */

#ifndef _PRIV_H
#define _PRIV_H

#include <sys/types.h>

uid_t init_drop_privilege(void);
void drop_privilege(void);
void restore_privilege(void);

#endif  /* _PRIV_H */
