#!/bin/bash
#
# Copyright (c) 2006 Mellanox Technologies. All rights reserved.
# Copyright (c) 2004, 2005, 2006 Voltaire, Inc. All rights reserved.
#
# This Software is licensed under one of the following licenses:
#
# 1) under the terms of the "Common Public License 1.0" a copy of which is
#    available from the Open Source Initiative, see
#    http://www.opensource.org/licenses/cpl.php.
#
# 2) under the terms of the "The BSD License" a copy of which is
#    available from the Open Source Initiative, see
#    http://www.opensource.org/licenses/bsd-license.php.
#
# 3) under the terms of the "GNU General Public License (GPL) Version 2" a
#    copy of which is available from the Open Source Initiative, see
#    http://www.opensource.org/licenses/gpl-license.php.
#
# Licensee has the right to choose one of the above licenses.
#
# Redistributions of source code must retain the above copyright
# notice and one of the license notices.
#
# Redistributions in binary form must reproduce both the above copyright
# notice, one of the license notices in the documentation
# and/or other materials provided with the distribution.
#
# Description: creates Module.symvers file for InfiniBand modules 

K_VER=${K_VER:-$(uname -r)}
MOD_SYMVERS_IB=./Module.symvers
SYMS=/tmp/syms

if [ -d /lib/modules/$K_VER/updates/kernel/drivers/infiniband ]; then
	MODULES_DIR=/lib/modules/$K_VER/updates/kernel/drivers/infiniband
elif [ -d /lib/modules/$K_VER/kernel/drivers/infiniband ]; then
	MODULES_DIR=/lib/modules/$K_VER/kernel/drivers/infiniband
else
	echo "No infiniband modules found"
	exit 1
fi

echo MODULES_DIR=${MODULES_DIR}

if [ -f ${MOD_SYMVERS_IB} -a ! -f ${MOD_SYMVERS_IB}.save ]; then
	mv ${MOD_SYMVERS_IB} ${MOD_SYMVERS_IB}.save
fi
rm -f $MOD_SYMVERS_IB
rm -f $SYMS

for mod in $(find ${MODULES_DIR} -name '*.ko') ; do
           nm -o $mod |grep __crc >> $SYMS
           n_mods=$((n_mods+1))
done

n_syms=$(wc -l $SYMS |cut -f1 -d" ")
echo Found $n_syms InfiniBand symbols in $n_mods InfiniBand modules
n=1


while [ $n -le $n_syms ] ; do
    line=$(head -$n $SYMS|tail -1)

    line1=$(echo $line|cut -f1 -d:)
    line2=$(echo $line|cut -f2 -d:)
    file=$(echo $line1|cut -f6- -d/)
    file=$(echo $file|cut -f1 -d.)

    crc=$(echo $line2|cut -f1 -d" ")
    crc=${crc:8}
    sym=$(echo $line2|cut -f3 -d" ")
    sym=${sym:6}
    echo -e  "0x$crc\t$sym\t$file" >> $MOD_SYMVERS_IB
    if [ -z $allsyms ] ; then
        allsyms=$sym
    else
        allsyms="$allsyms|$sym"
    fi
    n=$((n+1))
done

echo ${MOD_SYMVERS_IB} created. 
