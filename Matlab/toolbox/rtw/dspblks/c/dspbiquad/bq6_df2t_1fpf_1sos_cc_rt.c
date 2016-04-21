/*
 *  DSP Biquad Run-Time Library Helper Function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.2 $  $Date: 2004/04/12 23:41:56 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BQ6_DF2T_1fpf_1sos_CC (const creal32_T *u,
                                  creal32_T *y,
                                  creal32_T *state,
                                  const creal32_T *coeffs,
                                  const creal32_T  a0inv,
                                  const int_T sampsPerChan,
                                  const int_T numChans) {
  int_T i,j;
  creal32_T  out;

  for (i=0; i++ < numChans; ) {
    for (j=0; j++ < sampsPerChan; ) {
      creal32_T *mem = state;
      const creal32_T *c = coeffs;
      creal32_T  tmp; 
      creal32_T  in = *u++;             
      tmp.re      = mem->re + in.re * c->re - in.im * c->im; 
      tmp.im      = mem->im + in.re * c->im + in.im * c->re; 
      out.re      = CMULT_RE(tmp,a0inv); 
      out.im      = CMULT_IM(tmp,a0inv); 
      c++; 
      mem->re     = (mem+1)->re + (in.re * c->re - in.im * c->im) 
        - (out.re * (c+3)->re - out.im * (c+3)->im); 
      mem->im     = (mem+1)->im + (in.re * c->im + in.im * c->re) 
        - (out.re * (c+3)->im + out.im * (c+3)->re); 
      ++mem;
      mem->re     = (in.re * (c+1)->re - in.im * (c+1)->im) 
        - (out.re * (c+4)->re - out.im * (c+4)->im); 
      (mem++)->im = (in.re * (c+1)->im + in.im * (c+1)->re) 
        - (out.re * (c+4)->im + out.im * (c+4)->re); 
      *y++ = out;
    } /* Frame */
    /* Move to the state memory for the next channel */
    state += 2;
  } /* Channel */
}    
