#!/bin/sh
#
# Copyright (C) 2003, Northwestern University and Argonne National Laboratory
# See COPYRIGHT notice in top-level directory.
#

# Exit immediately if a command exits with a non-zero status.
# set -e
# Cannot use "set -e" here, as the tests here all return errors.

VALIDATOR=ncmpivalid

for i in ${BAD_FILES} ; do
    ${TESTSEQRUN} ./${VALIDATOR} -q ${srcdir}/$i
done
