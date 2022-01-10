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

mydir="$(dirname $0)"

if [ "${PERL_ROOT}" = '' ]; then
	echo "Need to set PERL_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${PERL_VRM}" = '' ]; then
	echo "Need to set PERL_VRM - source setenv.sh" >&2
        exit 16
fi

perlpatch="${PERL_VRM}"
perlcode="${PERL_VRM}.${PERL_OS390_TGT_AMODE}.${PERL_OS390_TGT_LINK}.${PERL_OS390_TGT_CODEPAGE}"

CODE_ROOT="${PERL_ROOT}/${perlcode}/perl5"
PATCH_ROOT="${PERL_ROOT}/${perlpatch}/patches"
commonpatches=`cd ${PATCH_ROOT} && find . -name "*.patch"`
specificpatches=`cd ${PATCH_ROOT} && find . -name "*.patch${PERL_OS390_TGT_CODEPAGE}"`
patches="$commonpatches $specificpatches"
for patch in $patches; do
	rp="${patch%*.patch*}"
	o="${CODE_ROOT}/${rp}.orig"
	f="${CODE_ROOT}/${rp}"
	p="${PATCH_ROOT}/${patch}"

	if [ -f "${o}" ]; then
		# Original file exists. Regenerate patch, then replace file with original version 
		diff -C 2 -f "${o}" "${f}" | tail +3 >"${p}"
		cp "${o}" "${f}"
	else
		# Original file does not exist yet. Create original file
		if ! [ -f "${f}" ]; then
			# This patch is meant to create a brand new file
			touch "${f}"
		fi
		cp "${f}" "${o}"
	fi

	patchsize=`wc -c "${p}" | awk '{ print $1 }'` 
	if [ $patchsize -eq 0 ]; then
		echo "Warning: patch file ${f} is empty - nothing to be done" >&2 
	else 
		out=`patch -c "${f}" <"${p}" 2>&1`
		if [ $? -gt 0 ]; then
			echo "Patch of perl tree failed (${f})." >&2
			echo "${out}" >&2
			exit 16
		fi
	fi
done

exit 0	
