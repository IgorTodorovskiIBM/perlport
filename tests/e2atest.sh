#!/bin/sh
CFLAGS="-qascii -qlanglvl=extc1x -D_OPEN_THREADS=3 -D_UNIX03_SOURCE=1 -DNSIG=39 -D_AE_BIMODAL=1 -D_XOPEN_SOURCE_EXTENDED -D_ALL_SOURCE -D_ENHANCED_ASCII_EXT=0xFFFFFFFF -D_OPEN_SYS_FILE_EXT=1 -D_OPEN_SYS_SOCK_IPV6 -D_XOPEN_SOURCE=600 -D_XOPEN_SOURCE_EXTENDED -qfloat=ieee"

c99 -o./e2atest ${CFLAGS} e2atest.c
if [ $? -eq 0 ]; then
	./e2atest
fi
