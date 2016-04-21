/* 
 * File: rt_lookflat2bincsf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 *
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 * Abstract:
 *   2-D column-major table look-up
 *   operating on real32_T with:
 *
 *   - Flat table look-up
 *   - Clipping
 *   - Binary breakpoint search
 *   - Uses previous index search result
 */

#include "rtlooksrc.h"

real32_T rt_LookFlat2BinCSf(const real32_T         u0,
			    const real32_T         u1,
			    const real32_T * const bpData01,
			    const real32_T * const bpData02,
			    const real32_T * const tableData,
			    int_T  * const bpIndex,
			    const int_T  * const maxIndex)
{
  real32_T bpLambda[2];

  bpIndex[0] = rt_PLookBinCf(u0, &bpLambda[0], bpData01, maxIndex[0], bpIndex[0]);
  bpIndex[1] = rt_PLookBinCf(u1, &bpLambda[1], bpData02, maxIndex[1], bpIndex[1]);
  return(rt_Intrp2Flatf(bpIndex, (maxIndex[0]+1), bpLambda, tableData));
}
/* [EOF] rt_lookflat2bincsf.c */