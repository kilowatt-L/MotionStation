/*
 * @(#)lu_r_rt.h    generated by: makeheader 4.21  Tue Mar 30 16:43:30 2004
 *
 *		built from:	lu_r_rt.c
 */

#ifndef lu_r_rt_h
#define lu_r_rt_h

#ifdef __cplusplus
    extern "C" {
#endif

EXPORT_FCN void MWDSP_lu_R(
          real32_T  *A,       /* Input Pointer */ 
          real32_T  *piv,     /* Ouyput (P) Pointer */ 
    const int_T      n,       /* P-port width */ 
          boolean_T *singular /* Singularity of input */
    );

#ifdef __cplusplus
    }	/* extern "C" */
#endif

#endif /* lu_r_rt_h */