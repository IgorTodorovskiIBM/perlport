#!/bin/sh
#
# Manage patches
# To create a new patch:
#   -cd to patches directory, create any sub-directories if required, and create an empty patch file by touch'ing it
# To refresh patches:
#   -run managepatches
#   -This will look at all the patch files, update them, and then patch the source files
#
#set -x
if [ $# -ne 0 ]; then
	echo "Syntax: managepatches" >&2
	echo "  refreshes patch files" >&2
	exit 8
fi

PERLPORT_ROOT="$1"
mydir="$(dirname $0)"
PERLPORT_ROOT=`cd $mydir/..; echo $PWD`

if [ "${PERL_ROOT}" = '' ]; then
	echo "Need to set PERL_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${PERL_VRM}" = '' ]; then
	echo "Need to set PERL_VRM - source setenv.sh" >&2
        exit 16
fi

if [ "${PERL_VRM}" = "maint-5.34" ]; then
	CODE_ROOT="${PERLPORT_ROOT}/perl5"
	PATCH_ROOT="${PERLPORT_ROOT}/patches"
	patches=`cd ${PATCH_ROOT}; find . -name "*.patch"`
	for patch in $patches; do
		rp="${patch%*.patch}"
		o="${CODE_ROOT}/${rp}.orig"
		f="${CODE_ROOT}/${rp}"
		p="${PATCH_ROOT}/${rp}.patch"

		if [ -f "${o}" ]; then
			# Original file exists. Regenerate patch, then replace file with original version 
			diff -C 2 -f "${o}" "${f}" | tail +3 >"${p}"
			cp "${o}" "${f}"
		else
			# Original file does not exist yet. Create original file
			cp "${f}" "${o}"
		fi

		out=`patch -c "${f}" <"${p}" 2>&1`
		if [ $? -gt 0 ]; then
			echo "Patch of perl tree failed (${f})." >&2
			echo "${out}" >&2
			exit 16
		fi
	done
fi

exit 0	