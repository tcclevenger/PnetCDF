/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*  
 *  (C) 2001 by Argonne National Laboratory.
 *      See COPYRIGHT in top-level directory.
 *
 * This file is automatically generated by buildiface -infile=../lib/pnetcdf.h -deffile=defs
 * DO NOT EDIT
 */
#include "mpinetcdf_impl.h"


#ifdef F77_NAME_UPPER
#define nfmpi_inq_varnatts_ NFMPI_INQ_VARNATTS
#elif defined(F77_NAME_LOWER_2USCORE)
#define nfmpi_inq_varnatts_ nfmpi_inq_varnatts__
#elif !defined(F77_NAME_LOWER_USCORE)
#define nfmpi_inq_varnatts_ nfmpi_inq_varnatts
/* Else leave name alone */
#endif


/* Prototypes for the Fortran interfaces */
#include "mpifnetcdf.h"
FORTRAN_API int FORT_CALL nfmpi_inq_varnatts_ ( int *v1, int64_t *v2, int64_t*v3 ){
    int ierr;
    int l2 = *v2 - 1;
    ierr = ncmpi_inq_varnatts( *v1, l2, v3 );
    return ierr;
}
