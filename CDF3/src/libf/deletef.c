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
#define nfmpi_delete_ NFMPI_DELETE
#elif defined(F77_NAME_LOWER_2USCORE)
#define nfmpi_delete_ nfmpi_delete__
#elif !defined(F77_NAME_LOWER_USCORE)
#define nfmpi_delete_ nfmpi_delete
/* Else leave name alone */
#endif


/* Prototypes for the Fortran interfaces */
#include "mpifnetcdf.h"
FORTRAN_API int FORT_CALL nfmpi_delete_ ( char *v1 FORT_MIXED_LEN(d1), MPI_Fint *v2 FORT_END_LEN(d1) ){
    int ierr;
    char *p1;

    {char *p = v1 + d1 - 1;
     int  li;
        while (*p == ' ' && p > v1) p--;
        p++;
        p1 = (char *)malloc( p-v1 + 1 );
        for (li=0; li<(p-v1); li++) { p1[li] = v1[li]; }
        p1[li] = 0; 
    }
    ierr = ncmpi_delete( p1, MPI_Info_f2c(*v2) );
    free( p1 );
    return ierr;
}
