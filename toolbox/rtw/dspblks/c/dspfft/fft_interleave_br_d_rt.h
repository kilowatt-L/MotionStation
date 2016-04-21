/*
 * @(#)fft_interleave_br_d_rt.h    generated by: makeheader 4.21  Tue Mar 30 16:43:20 2004
 *
 *		built from:	fft_interleave_br_d_rt.c
 */

#ifndef fft_interleave_br_d_rt_h
#define fft_interleave_br_d_rt_h

#ifdef __cplusplus
    extern "C" {
#endif

EXPORT_FCN void MWDSP_FFTInterleave_BR_D(
    creal_T      *y,
    const real_T *u,
    const int_T   nChans,
    const int_T   nRows
    );

#ifdef __cplusplus
    }	/* extern "C" */
#endif

#endif /* fft_interleave_br_d_rt_h */