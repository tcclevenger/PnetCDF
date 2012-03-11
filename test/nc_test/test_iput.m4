dnl This is m4 source.
dnl Process using m4 to produce 'C' language file.
dnl
dnl If you see this line, you can ignore the next one.
/* Do not edit this file. It is produced from the corresponding .m4 source */
dnl
/*********************************************************************
 *
 *  Copyright (C) 2003, Northwestern University and Argonne National Laboratory
 *  See COPYRIGHT notice in top-level directory.
 *
 *********************************************************************/

undefine(`index')dnl
dnl dnl dnl
dnl
dnl Macros
dnl
dnl dnl dnl
dnl
dnl Upcase(str)
dnl
define(`Upcase',dnl
`dnl
translit($1, abcdefghijklmnopqrstuvwxyz, ABCDEFGHIJKLMNOPQRSTUVWXYZ)')dnl
dnl dnl dnl
dnl
dnl NCT_ITYPE(type)
dnl
define(`NCT_ITYPE', ``NCT_'Upcase($1)')dnl
dnl

#include "tests.h"

dnl HASH(TYPE)
dnl
define(`HASH',dnl
`dnl
/*
 *  ensure hash value within range for internal TYPE
 */
static
double
hash_$1(
    const nc_type type,
    const int rank,
    const MPI_Offset *index,
    const nct_itype itype)
{
    const double min = $1_min;
    const double max = $1_max;

    return MAX(min, MIN(max, hash4( type, rank, index, itype)));
}
')dnl

HASH(text)
HASH(uchar)
HASH(schar)
HASH(short)
HASH(int)
HASH(long)
HASH(float)
HASH(double)
HASH(ushort)
HASH(uint)
HASH(longlong)
HASH(ulonglong)


dnl CHECK_VARS(TYPE)
dnl
define(`CHECK_VARS',dnl
`dnl
/* 
 *  check all vars in file which are (text/numeric) compatible with TYPE
 */
static
void
check_vars_$1(const char *filename)
{
    int  ncid;                  /* netCDF id */
    MPI_Offset index[MAX_RANK];
    int  err;           /* status */
    int  d;
    int  i;
    size_t  j;
    $1 value;
    nc_type datatype;
    int ndims;
    int dimids[MAX_RANK];
    double expect;
    char name[NC_MAX_NAME];
    MPI_Offset length;
    int canConvert;     /* Both text or both numeric */
    int nok = 0;      /* count of valid comparisons */

    err = ncmpi_open(comm, filename, NC_NOWRITE, MPI_INFO_NULL, &ncid);
    IF (err != NC_NOERR)
        error("ncmpi_open: %s", ncmpi_strerror(err));

    for (i = 0; i < NVARS; i++) {
        canConvert = (var_type[i] == NC_CHAR) == (NCT_ITYPE($1) == NCT_TEXT);
        if (canConvert) {
            err = ncmpi_inq_var(ncid, i, name, &datatype, &ndims, dimids, NULL);
            IF (err != NC_NOERR)
                error("ncmpi_inq_var: %s", ncmpi_strerror(err));
            IF (strcmp(name, var_name[i]) != 0)
                error("Unexpected var_name");
            IF (datatype != var_type[i])
                error("Unexpected type");
            IF (ndims != var_rank[i])
                error("Unexpected rank");
            for (j = 0; j < ndims; j++) {
                err = ncmpi_inq_dim(ncid, dimids[j], 0, &length);
                IF (err != NC_NOERR)
                    error("ncmpi_inq_dim: %s", ncmpi_strerror(err));
                IF (length != var_shape[i][j])
                    error("Unexpected shape");
            }
            for (j = 0; j < var_nels[i]; j++) {
                err = toMixedBase(j, var_rank[i], var_shape[i], index);
                IF (err != NC_NOERR)
                    error("error in toMixedBase 2");
                expect = hash4( var_type[i], var_rank[i], index, NCT_ITYPE($1));
                ncmpi_begin_indep_data(ncid);
                err = ncmpi_get_var1_$1(ncid, i, index, &value);
                if (inRange3(expect,datatype,NCT_ITYPE($1))) {
                    if (expect >= $1_min && expect <= $1_max) {
                        IF (err != NC_NOERR) {
                            error("ncmpi_get_var1_$1: %s", ncmpi_strerror(err));
                        } else {
                            IF (!equal(value,expect,var_type[i],NCT_ITYPE($1))) {
                                error("Var value read not that expected");
                                if (verbose) {
                                    error("\n");
                                    error("varid: %d, ", i);
                                    error("var_name: %s, ", var_name[i]);
                                    error("index:");
                                    for (d = 0; d < var_rank[i]; d++)
                                        error(" %d", index[d]);
                                    error(", expect: %g, ", expect);
                                    error("got: %g", (double) value);
                                }
                            } else {
                                ++nok;
                            }
                        }
                    }
                }
                ncmpi_end_indep_data(ncid);
            }
        }
    }
    err = ncmpi_close (ncid);
    IF (err != NC_NOERR)
        error("ncmpi_close: %s", ncmpi_strerror(err));
    print_nok(nok);
}
')dnl

CHECK_VARS(text)
CHECK_VARS(uchar)
CHECK_VARS(schar)
CHECK_VARS(short)
CHECK_VARS(int)
CHECK_VARS(long)
CHECK_VARS(float)
CHECK_VARS(double)
CHECK_VARS(ushort)
CHECK_VARS(uint)
CHECK_VARS(longlong)
CHECK_VARS(ulonglong)



dnl TEST_NC_IPUT_VAR1(TYPE)
dnl
define(`TEST_NC_IPUT_VAR1',dnl
`dnl
void
test_ncmpi_iput_var1_$1(void)
{
    int ncid;
    int i;
    int j;
    int err;
    MPI_Offset index[MAX_RANK];
    int canConvert;        /* Both text or both numeric */
    $1 value = 5;        /* any value would do - only for error cases */
    int reqid, status;

    err = ncmpi_create(comm, scratch, NC_CLOBBER|extra_flags, MPI_INFO_NULL, &ncid);
    IF (err != NC_NOERR) {
        error("ncmpi_create: %s", ncmpi_strerror(err));
        return;
    }
    def_dims(ncid);
    def_vars(ncid);
    err = ncmpi_enddef(ncid);
    IF (err != NC_NOERR)
        error("ncmpi_enddef: %s", ncmpi_strerror(err));

    for (i = 0; i < NVARS; i++) {
        canConvert = (var_type[i] == NC_CHAR) == (NCT_ITYPE($1) == NCT_TEXT);
        for (j = 0; j < var_rank[i]; j++)
            index[j] = 0;
        err = ncmpi_iput_var1_$1(BAD_ID, i, index, &value, &reqid);
        IF (err != NC_EBADID) 
            error("bad ncid: err = %d", err);
        err = ncmpi_iput_var1_$1(ncid, BAD_VARID, index, &value, &reqid);
        IF (err != NC_ENOTVAR) 
            error("bad var id: err = %d", err);
        for (j = 0; j < var_rank[i]; j++) {
            if (var_dimid[i][j] > 0) {                /* skip record dim */
                index[j] = var_shape[i][j];     /* out of boundary check */
                err = ncmpi_iput_var1_$1(ncid, i, index, &value, &reqid);
                IF (err != NC_EINVALCOORDS)
                    error("bad index: err = %d", err);
                index[j] = 0;
            }
        }
        for (j = 0; j < var_nels[i]; j++) {
            err = toMixedBase(j, var_rank[i], var_shape[i], index);
            IF (err != NC_NOERR) 
                error("error in toMixedBase 1");
            value = hash_$1( var_type[i], var_rank[i], index, NCT_ITYPE($1));
            if (var_rank[i] == 0 && i%2 == 0)
                err = ncmpi_iput_var1_$1(ncid, i, NULL, &value, &reqid);
            else
                err = ncmpi_iput_var1_$1(ncid, i, index, &value, &reqid);

            if (err == NC_NOERR) {
                /*
                ncmpi_begin_indep_data(ncid);
                err = ncmpi_wait(ncid, 1, &reqid, &status);
                ncmpi_end_indep_data(ncid);
                */
                ncmpi_wait_all(ncid, 1, &reqid, &status);
            }

            if (canConvert) {
                if (inRange3(value, var_type[i],NCT_ITYPE($1))) {
                    IF (status != NC_NOERR)
                        error("%s", ncmpi_strerror(status));
                } else {
                    IF (err != NC_ERANGE) {
                        error("Range error: err = %d", err);
                        error("\n\t\tfor type %s value %.17e %ld",
                                s_nc_type(var_type[i]),
                                (double)value, (long)value, &reqid);
                    }
                    ncmpi_cancel(ncid, 1, &reqid, &status);
                }
            } else {
                IF (err != NC_ECHAR)
                    error("wrong type: err = %d", err);
            }
        }
    }

    err = ncmpi_close(ncid);
    IF (err != NC_NOERR) 
        error("ncmpi_close: %s", ncmpi_strerror(err));

    check_vars_$1(scratch);

    err = ncmpi_delete(scratch, MPI_INFO_NULL);
    IF (err != NC_NOERR)
        error("remove of %s failed", scratch);
}
')dnl

TEST_NC_IPUT_VAR1(text)
TEST_NC_IPUT_VAR1(uchar)
TEST_NC_IPUT_VAR1(schar)
TEST_NC_IPUT_VAR1(short)
TEST_NC_IPUT_VAR1(int)
TEST_NC_IPUT_VAR1(long)
TEST_NC_IPUT_VAR1(float)
TEST_NC_IPUT_VAR1(double)
TEST_NC_IPUT_VAR1(ushort)
TEST_NC_IPUT_VAR1(uint)
TEST_NC_IPUT_VAR1(longlong)
TEST_NC_IPUT_VAR1(ulonglong)


dnl TEST_NC_IPUT_VAR(TYPE)
dnl
define(`TEST_NC_IPUT_VAR',dnl
`dnl
void
test_ncmpi_iput_var_$1(void)
{
    int ncid;
    int varid;
    int i;
    int j;
    int err;
    int nels;
    MPI_Offset index[MAX_RANK];
    int canConvert;        /* Both text or both numeric */
    int allInExtRange;        /* all values within external range? */
    $1 value[MAX_NELS];
    int reqid, status;

    err = ncmpi_create(comm, scratch, NC_CLOBBER|extra_flags, MPI_INFO_NULL, &ncid);
    IF (err != NC_NOERR) {
        error("ncmpi_create: %s", ncmpi_strerror(err));
        return;
    }
    def_dims(ncid);
    def_vars(ncid);
    err = ncmpi_enddef(ncid);
    IF (err != NC_NOERR)
        error("ncmpi_enddef: %s", ncmpi_strerror(err));

    for (i = 0; i < NVARS; i++) {
        canConvert = (var_type[i] == NC_CHAR) == (NCT_ITYPE($1) == NCT_TEXT);
        assert(var_rank[i] <= MAX_RANK);
        assert(var_nels[i] <= MAX_NELS);
        err = ncmpi_iput_var_$1(BAD_ID, i, value, &reqid);
        IF (err != NC_EBADID) 
            error("bad ncid: err = %d", err);
        err = ncmpi_iput_var_$1(ncid, BAD_VARID, value, &reqid);
        IF (err != NC_ENOTVAR) 
            error("bad var id: err = %d", err);

        nels = 1;
        for (j = 0; j < var_rank[i]; j++) {
            nels *= var_shape[i][j];
        }
        for (allInExtRange = 1, j = 0; j < nels; j++) {
            err = toMixedBase(j, var_rank[i], var_shape[i], index);
            IF (err != NC_NOERR) 
                error("error in toMixedBase 1");
            value[j]= hash_$1(var_type[i], var_rank[i], index, NCT_ITYPE($1));
            allInExtRange = allInExtRange 
                && inRange3(value[j], var_type[i], NCT_ITYPE($1));
        }
        err = ncmpi_iput_var_$1(ncid, i, value, &reqid);
        if (err == NC_NOERR || err == NC_ERANGE)
            /* NC_ERANGE is not a fatal error? */
            ncmpi_wait_all(ncid, 1, &reqid, &status);

        if (canConvert) {
            if (allInExtRange) {
                IF (err != NC_NOERR) 
                    error("%s", ncmpi_strerror(err));
            } else {
                IF (err != NC_ERANGE && var_dimid[i][0] != RECDIM)
                    error("range error: err = %d", err);
            }
        } else {       /* should flag wrong type even if nothing to write */
            IF (nels > 0 && err != NC_ECHAR)
                error("wrong type: err = %d", err);
        }
    }

    /* Preceeding has written nothing for record variables, now try */
    /* again with more than 0 records */

    /* Write record number NRECS to force writing of preceding records */
    /* Assumes variable cr is char vector with UNLIMITED dimension */
    err = ncmpi_inq_varid(ncid, "cr", &varid);
    IF (err != NC_NOERR)
        error("ncmpi_inq_varid: %s", ncmpi_strerror(err));
    index[0] = NRECS-1;
    err = ncmpi_iput_var1_text(ncid, varid, index, "x", &reqid);
    IF (err != NC_NOERR)
        error("ncmpi_iput_var1_text: %s", ncmpi_strerror(err));
    else {
        /*
        ncmpi_begin_indep_data(ncid);
        ncmpi_wait(ncid, 1, &reqid, &status);
        ncmpi_end_indep_data(ncid);
        */
        ncmpi_wait_all(ncid, 1, &reqid, &status);
    }

    for (i = 0; i < NVARS; i++) {
        if (var_dimid[i][0] == RECDIM) {  /* only test record variables here */
            canConvert = (var_type[i] == NC_CHAR) == (NCT_ITYPE($1) == NCT_TEXT);
            assert(var_rank[i] <= MAX_RANK);
            assert(var_nels[i] <= MAX_NELS);

            nels = 1;
            for (j = 0; j < var_rank[i]; j++) {
                nels *= var_shape[i][j];
            }
            for (allInExtRange = 1, j = 0; j < nels; j++) {
                err = toMixedBase(j, var_rank[i], var_shape[i], index);
                IF (err != NC_NOERR) 
                    error("error in toMixedBase 1");
                value[j]= hash_$1(var_type[i], var_rank[i], index, NCT_ITYPE($1));
                allInExtRange = allInExtRange 
                    && inRange3(value[j], var_type[i], NCT_ITYPE($1));
            }
            err = ncmpi_iput_var_$1(ncid, i, value, &reqid);
            if (err == NC_NOERR || err == NC_ERANGE)
                /* NC_ERANGE is not a fatal error? */
                ncmpi_wait_all(ncid, 1, &reqid, &status);

            if (canConvert) {
                if (allInExtRange) {
                    IF (err != NC_NOERR) 
                        error("%s", ncmpi_strerror(err));
                } else {
                    IF (err != NC_ERANGE)
                        error("range error: err = %d", err);
                }
            } else {
                IF (nels > 0 && err != NC_ECHAR)
                    error("wrong type: err = %d", err);
            }
        }
    }

    err = ncmpi_close(ncid);
    IF (err != NC_NOERR) 
        error("ncmpi_close: %s", ncmpi_strerror(err));

    check_vars_$1(scratch);

    err = ncmpi_delete(scratch, MPI_INFO_NULL);
    IF (err != NC_NOERR)
        error("remove of %s failed", scratch);
}
')dnl

TEST_NC_IPUT_VAR(text)
TEST_NC_IPUT_VAR(uchar)
TEST_NC_IPUT_VAR(schar)
TEST_NC_IPUT_VAR(short)
TEST_NC_IPUT_VAR(int)
TEST_NC_IPUT_VAR(long)
TEST_NC_IPUT_VAR(float)
TEST_NC_IPUT_VAR(double)
TEST_NC_IPUT_VAR(ushort)
TEST_NC_IPUT_VAR(uint)
TEST_NC_IPUT_VAR(longlong)
TEST_NC_IPUT_VAR(ulonglong)


dnl TEST_NC_IPUT_VARA(TYPE)
dnl
define(`TEST_NC_IPUT_VARA',dnl
`dnl
void
test_ncmpi_iput_vara_$1(void)
{
    int ncid;
    int d;
    int i;
    int j;
    int k;
    int err;
    int nslabs;
    int nels;
    MPI_Offset start[MAX_RANK];
    MPI_Offset edge[MAX_RANK];
    MPI_Offset mid[MAX_RANK];
    MPI_Offset index[MAX_RANK];
    int canConvert;        /* Both text or both numeric */
    int allInExtRange;        /* all values within external range? */
    $1 value[MAX_NELS];
    int reqid, status;

    err = ncmpi_create(comm, scratch, NC_CLOBBER|extra_flags, MPI_INFO_NULL, &ncid);
    IF (err != NC_NOERR) {
        error("ncmpi_create: %s", ncmpi_strerror(err));
        return;
    }
    def_dims(ncid);
    def_vars(ncid);
    err = ncmpi_enddef(ncid);
    IF (err != NC_NOERR)
        error("ncmpi_enddef: %s", ncmpi_strerror(err));

    value[0] = 0;
    for (i = 0; i < NVARS; i++) {
        canConvert = (var_type[i] == NC_CHAR) == (NCT_ITYPE($1) == NCT_TEXT);
        assert(var_rank[i] <= MAX_RANK);
        assert(var_nels[i] <= MAX_NELS);
        for (j = 0; j < var_rank[i]; j++) {
            start[j] = 0;
            edge[j] = 1;
        }
        err = ncmpi_iput_vara_$1(BAD_ID, i, start, edge, value, &reqid);
        IF (err != NC_EBADID) 
            error("bad ncid: err = %d", err);
        err = ncmpi_iput_vara_$1(ncid, BAD_VARID, start, edge, value, &reqid);
        IF (err != NC_ENOTVAR) 
            error("bad var id: err = %d", err);
        for (j = 0; j < var_rank[i]; j++) {
            if (var_dimid[i][j] > 0) {                /* skip record dim */
                start[j] = var_shape[i][j];      /* out of bundary check */
                err = ncmpi_iput_vara_$1(ncid, i, start, edge, value, &reqid);
                IF (err != NC_EINVALCOORDS)
                    error("bad start: err = %d", err);

                start[j] = 0;
                edge[j] = var_shape[i][j] + 1;  /* edge error check */
                err = ncmpi_iput_vara_$1(ncid, i, start, edge, value, &reqid);
                IF (err != NC_EEDGE)
                    error("bad edge: err = %d", err);
                edge[j] = 1;
            }
        }
        /* Check correct error returned even when nothing to put */
        for (j = 0; j < var_rank[i]; j++) {
            edge[j] = 0;
        }
        err = ncmpi_iput_vara_$1(BAD_ID, i, start, edge, value, &reqid);
        IF (err != NC_EBADID) 
            error("bad ncid: err = %d", err);
        err = ncmpi_iput_vara_$1(ncid, BAD_VARID, start, edge, value, &reqid);
        IF (err != NC_ENOTVAR) 
            error("bad var id: err = %d", err);
        for (j = 0; j < var_rank[i]; j++) {
            if (var_dimid[i][j] > 0) {                /* skip record dim */
                start[j] = var_shape[i][j];     /* out of boundary check */
                err = ncmpi_iput_vara_$1(ncid, i, start, edge, value, &reqid);
                IF (err != NC_EINVALCOORDS)
                    error("bad start: err = %d", err);
                start[j] = 0;
            }
        }
        err = ncmpi_iput_vara_$1(ncid, i, start, edge, value, &reqid);
        if (err == NC_NOERR) {
            /*
            ncmpi_begin_indep_data(ncid);
            err = ncmpi_wait(ncid, i, &reqid, &status);
            ncmpi_end_indep_data(ncid);
            */
            ncmpi_wait_all(ncid, 1, &reqid, &status);
        }

        if (canConvert) {
            IF (status != NC_NOERR) 
                error("%s", ncmpi_strerror(status));
        } else {
            IF (err != NC_ECHAR)
                error("wrong type: err = %d", err);
        }
        for (j = 0; j < var_rank[i]; j++) {
            edge[j] = 1;
        }

        /* Choose a random point dividing each dim into 2 parts */
        /* Put 2^rank (nslabs) slabs so defined */
        nslabs = 1;
        for (j = 0; j < var_rank[i]; j++) {
            mid[j] = roll( var_shape[i][j] );
            nslabs *= 2;
        }
        /* bits of k determine whether to put lower or upper part of dim */
        for (k = 0; k < nslabs; k++) {
            nels = 1;
            for (j = 0; j < var_rank[i]; j++) {
                if ((k >> j) & 1) {
                    start[j] = 0;
                    edge[j] = mid[j];
                } else {
                    start[j] = mid[j];
                    edge[j] = var_shape[i][j] - mid[j];
                }
                nels *= edge[j];
            }
            for (allInExtRange = 1, j = 0; j < nels; j++) {
                err = toMixedBase(j, var_rank[i], edge, index);
                IF (err != NC_NOERR) 
                    error("error in toMixedBase 1");
                for (d = 0; d < var_rank[i]; d++) 
                    index[d] += start[d];
                value[j]= hash_$1(var_type[i], var_rank[i], index, NCT_ITYPE($1));
                allInExtRange = allInExtRange 
                    && inRange3(value[j], var_type[i], NCT_ITYPE($1));
            }
            if (var_rank[i] == 0 && i%2 == 0)
                err = ncmpi_iput_vara_$1(ncid, i, NULL, NULL, value, &reqid);
            else
                err = ncmpi_iput_vara_$1(ncid, i, start, edge, value, &reqid);
            if (err == NC_NOERR || err == NC_ERANGE)
                /* NC_ERANGE is not a fatal error? */
                ncmpi_wait_all(ncid, 1, &reqid, &status);

            if (canConvert) {
                if (allInExtRange) {
                    IF (status != NC_NOERR) 
                        error("%s", ncmpi_strerror(status));
                } else {
                    IF (err != NC_ERANGE)
                        error("range error: err = %d", err);
                }
            } else {
                IF (nels > 0 && err != NC_ECHAR)
                    error("wrong type: err = %d", err);
            }
        }
    }

    err = ncmpi_close(ncid);
    IF (err != NC_NOERR) 
        error("ncmpi_close: %s", ncmpi_strerror(err));

    check_vars_$1(scratch);

    err = ncmpi_delete(scratch, MPI_INFO_NULL);
    IF (err != NC_NOERR)
        error("remove of %s failed", scratch);
}
')dnl

TEST_NC_IPUT_VARA(text)
TEST_NC_IPUT_VARA(uchar)
TEST_NC_IPUT_VARA(schar)
TEST_NC_IPUT_VARA(short)
TEST_NC_IPUT_VARA(int)
TEST_NC_IPUT_VARA(long)
TEST_NC_IPUT_VARA(float)
TEST_NC_IPUT_VARA(double)
TEST_NC_IPUT_VARA(ushort)
TEST_NC_IPUT_VARA(uint)
TEST_NC_IPUT_VARA(longlong)
TEST_NC_IPUT_VARA(ulonglong)


dnl TEST_NC_IPUT_VARS(TYPE)
dnl
define(`TEST_NC_IPUT_VARS',dnl
`dnl
void
test_ncmpi_iput_vars_$1(void)
{
    int ncid;
    int d;
    int i;
    int j;
    int k;
    int m;
    int err;
    int nels;
    int nslabs;
    int nstarts;        /* number of different starts */
    MPI_Offset start[MAX_RANK];
    MPI_Offset edge[MAX_RANK];
    MPI_Offset index[MAX_RANK];
    MPI_Offset index2[MAX_RANK];
    MPI_Offset mid[MAX_RANK];
    MPI_Offset count[MAX_RANK];
    MPI_Offset sstride[MAX_RANK];
    MPI_Offset stride[MAX_RANK];
    int canConvert;        /* Both text or both numeric */
    int allInExtRange;        /* all values within external range? */
    $1 value[MAX_NELS];
    int reqid, status;

    err = ncmpi_create(comm, scratch, NC_CLOBBER|extra_flags, MPI_INFO_NULL, &ncid);
    IF (err != NC_NOERR) {
        error("ncmpi_create: %s", ncmpi_strerror(err));
        return;
    }
    def_dims(ncid);
    def_vars(ncid);
    err = ncmpi_enddef(ncid);
    IF (err != NC_NOERR)
        error("ncmpi_enddef: %s", ncmpi_strerror(err));

    for (i = 0; i < NVARS; i++) {
        canConvert = (var_type[i] == NC_CHAR) == (NCT_ITYPE($1) == NCT_TEXT);
        assert(var_rank[i] <= MAX_RANK);
        assert(var_nels[i] <= MAX_NELS);
        for (j = 0; j < var_rank[i]; j++) {
            start[j] = 0;
            edge[j] = 1;
            stride[j] = 1;
        }
        err = ncmpi_iput_vars_$1(BAD_ID, i, start, edge, stride, value, &reqid);
        IF (err != NC_EBADID) 
            error("bad ncid: err = %d", err);
        err = ncmpi_iput_vars_$1(ncid, BAD_VARID, start, edge, stride, value, &reqid);
        IF (err != NC_ENOTVAR) 
            error("bad var id: err = %d", err);
        for (j = 0; j < var_rank[i]; j++) {
            if (var_dimid[i][j] > 0) {                /* skip record dim */
                start[j] = var_shape[i][j];     /* out of boundary check */
                err = ncmpi_iput_vars_$1(ncid, i, start, edge, stride, value, &reqid);
                IF (err != NC_EINVALCOORDS)
                    error("bad start: err = %d", err);

                start[j] = 0;
                edge[j] = var_shape[i][j] + 1;  /* edge error check */
                err = ncmpi_iput_vars_$1(ncid, i, start, edge, stride, value, &reqid);
                IF (err != NC_EEDGE)
                    error("bad edge: err = %d", err);

                edge[j] = 1;
                stride[j] = 0;  /* strided edge error check */
                err = ncmpi_iput_vars_$1(ncid, i, start, edge, stride, value, &reqid);
                IF (err != NC_ESTRIDE)
                    error("bad stride: err = %d", err);
                stride[j] = 1;
            }
        }
        /* Choose a random point dividing each dim into 2 parts */
        /* Put 2^rank (nslabs) slabs so defined */
        nslabs = 1;
        for (j = 0; j < var_rank[i]; j++) {
            mid[j] = roll( var_shape[i][j] );
            nslabs *= 2;
        }
        /* bits of k determine whether to put lower or upper part of dim */
        /* choose random stride from 1 to edge */
        for (k = 0; k < nslabs; k++) {
            nstarts = 1;
            for (j = 0; j < var_rank[i]; j++) {
                if ((k >> j) & 1) {
                    start[j] = 0;
                    edge[j] = mid[j];
                } else {
                    start[j] = mid[j];
                    edge[j] = var_shape[i][j] - mid[j];
                }
                sstride[j] = stride[j] = edge[j] > 0 ? 1+roll(edge[j]) : 1;
                nstarts *= stride[j];
            }
            for (m = 0; m < nstarts; m++) {
                err = toMixedBase(m, var_rank[i], sstride, index);
                IF (err != NC_NOERR)
                    error("error in toMixedBase");
                nels = 1;
                for (j = 0; j < var_rank[i]; j++) {
                    count[j] = 1 + (edge[j] - index[j] - 1) / stride[j];
                    nels *= count[j];
                    index[j] += start[j];
                }
                /* Random choice of forward or backward */
/* TODO
                if ( roll(2) ) {
                    for (j = 0; j < var_rank[i]; j++) {
                        index[j] += (count[j] - 1) * stride[j];
                        stride[j] = -stride[j];
                    }
                }
*/
                for (allInExtRange = 1, j = 0; j < nels; j++) {
                    err = toMixedBase(j, var_rank[i], count, index2);
                    IF (err != NC_NOERR)
                        error("error in toMixedBase");
                    for (d = 0; d < var_rank[i]; d++)
                        index2[d] = index[d] + index2[d] * stride[d];
                    value[j] = hash_$1(var_type[i], var_rank[i], index2, 
                        NCT_ITYPE($1));
                    allInExtRange = allInExtRange 
                        && inRange3(value[j], var_type[i], NCT_ITYPE($1));
                }
                if (var_rank[i] == 0 && i%2 == 0)
                    err = ncmpi_iput_vars_$1(ncid, i, NULL, NULL, stride, value, &reqid);
                else
                    err = ncmpi_iput_vars_$1(ncid, i, index, count, stride, value, &reqid);
                if (err == NC_NOERR || err == NC_ERANGE)
                    /* NC_ERANGE is not a fatal error? */
                    ncmpi_wait_all(ncid, 1, &reqid, &status);

                if (canConvert) {
                    if (allInExtRange) {
                        IF (status != NC_NOERR) 
                            error("%s", ncmpi_strerror(status));
                    } else {
                        IF (err != NC_ERANGE)
                            error("range error: err = %d", err);
                    }
                } else {
                    IF (nels > 0 && err != NC_ECHAR)
                        error("wrong type: err = %d", err);
                }
            }
        }
    }

    err = ncmpi_close(ncid);
    IF (err != NC_NOERR) 
        error("ncmpi_close: %s", ncmpi_strerror(err));

    check_vars_$1(scratch);

    err = ncmpi_delete(scratch, MPI_INFO_NULL);
    IF (err != NC_NOERR)
        error("remove of %s failed", scratch);
}
')dnl

TEST_NC_IPUT_VARS(text)
TEST_NC_IPUT_VARS(uchar)
TEST_NC_IPUT_VARS(schar)
TEST_NC_IPUT_VARS(short)
TEST_NC_IPUT_VARS(int)
TEST_NC_IPUT_VARS(long)
TEST_NC_IPUT_VARS(float)
TEST_NC_IPUT_VARS(double)
TEST_NC_IPUT_VARS(ushort)
TEST_NC_IPUT_VARS(uint)
TEST_NC_IPUT_VARS(longlong)
TEST_NC_IPUT_VARS(ulonglong)


dnl TEST_NC_IPUT_VARM(TYPE)
dnl
define(`TEST_NC_IPUT_VARM',dnl
`dnl
void
test_ncmpi_iput_varm_$1(void)
{
    int ncid;
    int d;
    int i;
    int j;
    int k;
    int m;
    int err;
    int nels;
    int nslabs;
    int nstarts;        /* number of different starts */
    MPI_Offset start[MAX_RANK];
    MPI_Offset edge[MAX_RANK];
    MPI_Offset index[MAX_RANK];
    MPI_Offset index2[MAX_RANK];
    MPI_Offset mid[MAX_RANK];
    MPI_Offset count[MAX_RANK];
    MPI_Offset sstride[MAX_RANK];
    MPI_Offset stride[MAX_RANK];
    MPI_Offset imap[MAX_RANK];
    int canConvert;        /* Both text or both numeric */
    int allInExtRange;        /* all values within external range? */
    $1 value[MAX_NELS];
    int reqid, status;

    err = ncmpi_create(comm, scratch, NC_CLOBBER|extra_flags, MPI_INFO_NULL, &ncid);
    IF (err != NC_NOERR) {
        error("ncmpi_create: %s", ncmpi_strerror(err));
        return;
    }
    def_dims(ncid);
    def_vars(ncid);
    err = ncmpi_enddef(ncid);
    IF (err != NC_NOERR)
        error("ncmpi_enddef: %s", ncmpi_strerror(err));

    for (i = 0; i < NVARS; i++) {
        canConvert = (var_type[i] == NC_CHAR) == (NCT_ITYPE($1) == NCT_TEXT);
        assert(var_rank[i] <= MAX_RANK);
        assert(var_nels[i] <= MAX_NELS);
        for (j = 0; j < var_rank[i]; j++) {
            start[j] = 0;
            edge[j] = 1;
            stride[j] = 1;
            imap[j] = 1;
        }
        err = ncmpi_iput_varm_$1(BAD_ID, i, start, edge, stride, imap, value, &reqid);
        IF (err != NC_EBADID) 
            error("bad ncid: err = %d", err);
        err = ncmpi_iput_varm_$1(ncid, BAD_VARID, start, edge, stride, imap, value, &reqid);
        IF (err != NC_ENOTVAR) 
            error("bad var id: err = %d", err);
        for (j = 0; j < var_rank[i]; j++) {
            if (var_dimid[i][j] > 0) {                /* skip record dim */
                start[j] = var_shape[i][j];     /* out of boundary check */
                err = ncmpi_iput_varm_$1(ncid, i, start, edge, stride, imap, value, &reqid);
                IF (err != NC_EINVALCOORDS)
                    error("bad start: err = %d", err);

                start[j] = 0;
                edge[j] = var_shape[i][j] + 1;  /* edge error check */
                err = ncmpi_iput_varm_$1(ncid, i, start, edge, stride, imap, value, &reqid);
                IF (err != NC_EEDGE)
                    error("bad edge: err = %d", err);

                edge[j] = 1;
                stride[j] = 0;  /* strided edge error check */
                err = ncmpi_iput_varm_$1(ncid, i, start, edge, stride, imap, value, &reqid);
                IF (err != NC_ESTRIDE)
                    error("bad stride: err = %d", err);
                stride[j] = 1;
            }
        }
        /* Choose a random point dividing each dim into 2 parts */
        /* Put 2^rank (nslabs) slabs so defined */
        nslabs = 1;
        for (j = 0; j < var_rank[i]; j++) {
            mid[j] = roll( var_shape[i][j] );
            nslabs *= 2;
        }
        /* bits of k determine whether to put lower or upper part of dim */
        /* choose random stride from 1 to edge */
        for (k = 0; k < nslabs; k++) {
            nstarts = 1;
            for (j = 0; j < var_rank[i]; j++) {
                if ((k >> j) & 1) {
                    start[j] = 0;
                    edge[j] = mid[j];
                } else {
                    start[j] = mid[j];
                    edge[j] = var_shape[i][j] - mid[j];
                }
                sstride[j] = stride[j] = edge[j] > 0 ? 1+roll(edge[j]) : 1;
                nstarts *= stride[j];
            }
            for (m = 0; m < nstarts; m++) {
                err = toMixedBase(m, var_rank[i], sstride, index);
                IF (err != NC_NOERR)
                    error("error in toMixedBase");
                nels = 1;
                for (j = 0; j < var_rank[i]; j++) {
                    count[j] = 1 + (edge[j] - index[j] - 1) / stride[j];
                    nels *= count[j];
                    index[j] += start[j];
                }
                /* Random choice of forward or backward */
/* TODO
                if ( roll(2) ) {
                    for (j = 0; j < var_rank[i]; j++) {
                        index[j] += (count[j] - 1) * stride[j];
                        stride[j] = -stride[j];
                    }
                }
*/
                if (var_rank[i] > 0) {
                    j = var_rank[i] - 1;
                    imap[j] = 1;
                    for (; j > 0; j--)
                        imap[j-1] = imap[j] * count[j];
                }
                for (allInExtRange = 1, j = 0; j < nels; j++) {
                    err = toMixedBase(j, var_rank[i], count, index2);
                    IF (err != NC_NOERR)
                        error("error in toMixedBase");
                    for (d = 0; d < var_rank[i]; d++)
                        index2[d] = index[d] + index2[d] * stride[d];
                    value[j] = hash_$1(var_type[i], var_rank[i], index2,
                        NCT_ITYPE($1));
                    allInExtRange = allInExtRange
                        && inRange3(value[j], var_type[i], NCT_ITYPE($1));
                }
                if (var_rank[i] == 0 && i%2 == 0)
                    err = ncmpi_iput_varm_$1(ncid,i,NULL,NULL,NULL,NULL,value, &reqid);
                else
                    err = ncmpi_iput_varm_$1(ncid,i,index,count,stride,imap,value,&reqid);
                if (err == NC_NOERR || err == NC_ERANGE)
                    /* NC_ERANGE is not a fatal error? */
                    ncmpi_wait_all(ncid, 1, &reqid, &status);

                if (canConvert) {
                    if (allInExtRange) {
                        IF (status != NC_NOERR)
                            error("%s", ncmpi_strerror(status));
                    } else {
                        IF (err != NC_ERANGE)
                            error("range error: err = %d", err);
                    }
                } else {
                    IF (nels > 0 && err != NC_ECHAR)
                        error("wrong type: err = %d", err);
                }
            }
        }
    }

    err = ncmpi_close(ncid);
    IF (err != NC_NOERR) 
        error("ncmpi_close: %s", ncmpi_strerror(err));

    check_vars_$1(scratch);

    err = ncmpi_delete(scratch, MPI_INFO_NULL);
    IF (err != NC_NOERR)
        error("remove of %s failed", scratch);
}
')dnl

TEST_NC_IPUT_VARM(text)
TEST_NC_IPUT_VARM(uchar)
TEST_NC_IPUT_VARM(schar)
TEST_NC_IPUT_VARM(short)
TEST_NC_IPUT_VARM(int)
TEST_NC_IPUT_VARM(long)
TEST_NC_IPUT_VARM(float)
TEST_NC_IPUT_VARM(double)
TEST_NC_IPUT_VARM(ushort)
TEST_NC_IPUT_VARM(uint)
TEST_NC_IPUT_VARM(longlong)
TEST_NC_IPUT_VARM(ulonglong)


