#!/bin/sh 
#set -x
#
# Pre-requisites: 
#  - cd to the directory of this script before running the script   
#  - ensure you have sourced setenv.sh, e.g. . ./setenv.sh
#  - ensure you have GNU make installed (4.1 or later)
#  - ensure you have access to c99
#  - network connectivity to pull git source from org
#
if [ "${PERL_ROOT}" = '' ]; then
	echo "Need to set PERL_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${PERL_VRM}" = '' ]; then
	echo "Need to set PERL_VRM - source setenv.sh" >&2
	exit 16
fi

make --version >/dev/null 2>&1 
if [ $? -gt 0 ]; then
	echo "You need GNU Make on your PATH in order to build PERL" >&2
	exit 16
fi

whence c99 >/dev/null
if [ $? -gt 0 ]; then
	echo "c99 required to build PERL. " >&2
	exit 16
fi

if ! [ -d perl5 ]; then
	git clone https://github.com/Perl/perl5.git --branch "${PERL_VRM}" --single-branch --depth 1 
fi

MY_ROOT="${PWD}"

cd perl5
chtag -R -h -t -cISO8859-1 "${MY_ROOT}/perl5"
if [ $? -gt 0 ]; then
	echo "Unable to tag PERL directory tree as ASCII" >&2
	exit 16
fi


#
# Apply patches
# To create a new patch:
# cd to perl5 directory
# copy original file in perl5 directory to: <file>.orig
# diff -C 2 -f <file>.orig <file>.c >../patches/<file>.patch  
#
if [ "${PERL_VRM}" = "maint-5.34" ]; then
	patch -c doio.c <${MY_ROOT}/patches/doio.patch
	if [ $? -gt 0 ]; then
  		echo "Patch of perl tree failed (doio.c)." >&2
                exit 16
	fi      
	patch -c iperlsys.h <${MY_ROOT}/patches/iperlsys.patch
  	if [ $? -gt 0 ]; then
                echo "Patch of perl tree failed (iperlsys)." >&2
                exit 16
        fi      
fi  

#
# Setup the configuration 
#
sh Configure -de -Dccflags="-g -qsuppress=CCN3159 -qlanglvl=extc1x -qascii -D_OPEN_THREADS=3 -D_UNIX03_SOURCE=1 -DNSIG=39 -D_AE_BIMODAL=1 -D_XOPEN_SOURCE_EXTENDED -D_ALL_SOURCE -D_ENHANCED_ASCII_EXT=0xFFFFFFFF -D_OPEN_SYS_FILE_EXT=1 -D_OPEN_SYS_SOCK_IPV6 -D_XOPEN_SOURCE=600 -D_XOPEN_SOURCE_EXTENDED -qfloat=ieee" -Dcc=/bin/c99 
if [ $? -gt 0 ]; then
	echo "Configure of PERL tree failed." >&2
	exit 16
fi

make
if [ $? -gt 0 ]; then
	echo "MAKE of PERL tree failed." >&2
	exit 16
fi


cd "${DELTA_ROOT}/tests"
export PATH="${PERL_ROOT}/${PERL_VRM}/src:${PATH}"

./runbasic.sh
if [ $? -gt 0 ]; then
	echo "Basic test of PERL failed." >&2
	exit 16
fi
./runexamples.sh
if [ $? -gt 0 ]; then
	echo "Example tests of PERL failed." >&2
	exit 16
fi
exit 0
