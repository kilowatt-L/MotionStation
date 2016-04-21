/*
 *  ALLPOLE_TDF_A0SCALE_DZ_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:41:11 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_AllPole_TDF_A0Scale_DZ(const real_T          *u,
                                  creal_T               *y,
                                  creal_T * const       mem_base,
                                  const int_T           numDelays,
                                  const int_T           sampsPerChan,
                                  const int_T           numChans,
                                  const creal_T * const den,
                                  const int_T           ordDEN,
                                  const boolean_T       one_fpf)
{
    int_T k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
        const creal_T *dentmp = den;
        int_T         i    = sampsPerChan;
        creal_T       invA0;
        CRECIP(*dentmp, invA0);
        while (i--) {
            creal_T *filt_mem  = mem_base + k * numDelays; /* state memory for this channel */
            creal_T *next_mem  = filt_mem + 1;
            int_T   j          = ordDEN;
            creal_T sum;

            if (one_fpf) dentmp = den;
            else         CRECIP(*dentmp, invA0);

            /* Compute the output value
             * y[n] = x[n] + D0[n]*(1/a0)
             */
            sum.re    =  *u++ + filt_mem->re;
            sum.im    = filt_mem->im;
            y->re     = CMULT_RE(sum, invA0);
            y->im     = CMULT_IM(sum, invA0);
            dentmp++;

            /* Update filter states
             *   D0[n+1] = D1[n] - y[n]*a1
             *   D1[n+1] = D2[n] - y[n]*a2
             *   ...
             */           
            while (j--) {
                filt_mem->re     = next_mem->re     - CMULT_RE(*y, *dentmp);
                (filt_mem++)->im = (next_mem++)->im - CMULT_IM(*y, *dentmp);
                ++dentmp;
            }
            y++;

        } /* frame loop */
    } /* channel loop */
}

/* [EOF] allpole_tdf_a0scale_DZ_rt.c */
