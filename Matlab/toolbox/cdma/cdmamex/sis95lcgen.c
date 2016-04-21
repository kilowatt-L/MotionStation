/*
 *  Module Name: sis95lcgen.c
 *
 *  Description:
 *      Generates the Long Code Sequence. 
 *      This long code is periodic with period 241-1 chips and is based on the
 *      specified characteristic polynomial in IS-95A specifications. Each chip 
 *      of the long code is generated by the modulo-2 inner product of a 42-bit 
 *      mask and the 42-bit state-vector of the sequence generator.
 * 
 *  Inputs:
 *      None
 * 
 *  Outputs:
 *      Long Code
 *          Binary vector, corresponding to the Long Code Sequence or a decimated 
 *          version as specified by the parameters.
 *		
 *  Parameters:
 *      Output Frame Size
 *          Size of the output frame, i.e. number of long code bits sent to the 
 *          output at each sampling time.
 *      Decimation Ratio
 *          The Long Code generator output will be decimated by this amount.
 *      Long Code Mask
 *          Integer scalar between 0 and 2^42 - 1, containing the Long Code Mask.
 *      Initial State
 *          Integer scalar between 0 and 2^42 - 1, which if given, is the initial 
 *          state of the Long Code generator. If it is empty, it uses the default 
 *          value of 2^41.
 *      Block Sampling Time (in Seconds)
 *          Simulink block sampling time, the Simulink block samples the input every 
 *          such interval. Sampling Rate of the output sequence is equal to Output 
 *      Frame Size divided by the Block Sampling Time.
 * 
 *  Notes:
 *      The Linear Feedback Shift Register (LFSR) states are stored (and shifted) 
 *      from RIGHT TO LEFT. This means MSB of the mask or the state corresponds 
 *      to the last register and the binary number ak ... a1 a0 corresponds to 
 *      the polynomial  aK xk + .. + a1 x1... + a0
 * 
 *  Copyright 1999-2002 The MathWorks, Inc. and ALGOREX, Inc.
 *  $Revision: 1.14.2.1 $  $Date: 2004/04/12 22:59:46 $
 */
#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME sis95lcgen

#include "simstruc.h"
#include <math.h>

#define NUM_ARGS        5
#define SAMP_TIME_ARG   ssGetSFcnParam(S,0)
#define INIT_ST_ARG     ssGetSFcnParam(S,1)
#define LC_MASK_ARG     ssGetSFcnParam(S,2)
#define DEC_RATIO_ARG   ssGetSFcnParam(S,3)
#define NUM_SYMB_ARG    ssGetSFcnParam(S,4)

#define BITS32  4294967295.0        /* 2^32 - 1 */
#define BITS53  9007199254740991.0  /* 2^53 - 1 */

#define NUM_FRAME_SYMBS    384
#define NUM_FRAME_CHIPS    (384*64)
#define NUM_SYMB_CHIPS     64

#define LONGCODEMASK        params.lcMask
#define LC_STATE            params.lcState
#define DECIMATION_RATIO    params.decRatio
#define NUM_SYMBOL          params.numSymb

typedef struct int64{
    short int           outOfRange;
    unsigned long int   high;
    unsigned long int   low;
} vlint;

typedef struct lcGen{
    unsigned long       *lcMask;
    unsigned long       *lcState;
    int                 decRatio;
    int                 numSymb;
    
} lcgen_par;

/* dbl2int -- Convert an IEEE double to a 64 bit integer */
static vlint dbl2int(real_T  x)
{
    vlint  intx;
    intx.outOfRange = 0;
    
    if ((x > BITS53) || mxIsNaN(x)){
        intx.outOfRange = 1;
    } else if ((x - floor(x)) || (x<0)){
        intx.outOfRange = 2;
    } else if (x > BITS32){
        intx.high = (unsigned long) ldexp((double) x, -32);
        /* implicit conversion to int */
        intx.low  = (unsigned long) (x - ldexp((double) intx.high, 32));
        /* implicit conversion to int */
    }       
    else{
        intx.high = 0;
        intx.low = (unsigned long) x;                /* implicit conversion to int */
    }
    return( intx );
}


#ifdef MATLAB_MEX_FILE
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S) {
    const char *msg = NULL;
    
    if ((mxGetM(SAMP_TIME_ARG)*mxGetN(SAMP_TIME_ARG) != 1) ||
        ((mxGetPr(SAMP_TIME_ARG)[0] <= (real_T) 0.0) &&
        (mxGetPr(SAMP_TIME_ARG)[0] != (real_T) -1.0))) {
        msg = "Sample time must be a positive scalar";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(INIT_ST_ARG)*mxGetN(INIT_ST_ARG) != 0) &&
        ((mxGetM(INIT_ST_ARG)*mxGetN(INIT_ST_ARG) != 1) ||
        (mxGetPr(INIT_ST_ARG)[0] <= (real_T) 0.0)  ||
        (mxGetPr(INIT_ST_ARG)[0] >= (real_T) pow(2.0, 42.0))  ||
        (floor(mxGetPr(INIT_ST_ARG)[0]) - mxGetPr(INIT_ST_ARG)[0]))) {
        msg = "Initial state must be a positive integer less than 2^42 or empty";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(LC_MASK_ARG)*mxGetN(LC_MASK_ARG) != 1) ||
        (mxGetPr(LC_MASK_ARG)[0] <= (real_T) 0.0)  ||
        (mxGetPr(LC_MASK_ARG)[0] >= (real_T) pow(2.0, 42.0))  ||
        (floor(mxGetPr(LC_MASK_ARG)[0]) - mxGetPr(LC_MASK_ARG)[0])) {
        msg = "Long code mask must be a positive integer less than 2^42";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(DEC_RATIO_ARG)*mxGetN(DEC_RATIO_ARG) != 1) ||
        (mxGetPr(DEC_RATIO_ARG)[0] <= (real_T) 0.0)  ||
        (((int) mxGetPr(DEC_RATIO_ARG)[0]) - mxGetPr(DEC_RATIO_ARG)[0])) {
        msg = "Decimation ratio must be a positive integer";
        goto ERROR_EXIT;
    }
    
    if ((mxGetM(NUM_SYMB_ARG)*mxGetN(NUM_SYMB_ARG) != 1) ||
        (mxGetPr(NUM_SYMB_ARG)[0] <= (real_T) 0.0)  ||
        (((int) mxGetPr(NUM_SYMB_ARG)[0]) - mxGetPr(NUM_SYMB_ARG)[0])) {
        msg = "Output frame size must be a positive integer";
        goto ERROR_EXIT;
    }
ERROR_EXIT:
    if (msg != NULL) {
        ssSetErrorStatus(S,msg);
        return;
    }
}
#endif

static void mdlInitializeSizes(SimStruct *S)
{
    int numSymb;
    ssSetNumSFcnParams(S, NUM_ARGS);
    
#if defined(MATLAB_MEX_FILE)
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Simulink will report a parameter mismatch error */
    }
#endif
    
    numSymb= (int) mxGetScalar(NUM_SYMB_ARG);
    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0,numSymb);
    
    ssSetNumContStates(    S, 0);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 2);   /* number of pointer work vector elements*/
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)    */
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetScalar(SAMP_TIME_ARG));
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
static void mdlInitializeConditions(SimStruct *S)

{
    unsigned long *lcMask  = (unsigned long *) calloc(2, sizeof(unsigned long));
    unsigned long *lcState = (unsigned long *) calloc(2, sizeof(unsigned long));
    vlint mask, state;
    
#ifdef MATLAB_MEX_FILE
    if ((lcMask==NULL) || (lcState==NULL)){
        ssSetErrorStatus(S,"Not enough memory to allocate for work vectors");
        return;
    }
#endif
    
    ssSetPWorkValue(S, 0, lcMask);   
    ssSetPWorkValue(S, 1, lcState);   
    
    /* Initialize the state of the long code generator */
    if ((mxGetM(INIT_ST_ARG)*mxGetN(INIT_ST_ARG)) == 0)
        state = dbl2int(ldexp(1.0, 41.0));
    else    
        state = dbl2int(mxGetScalar(INIT_ST_ARG));
    
    mask  = dbl2int(mxGetScalar(LC_MASK_ARG));
    
#if defined(MATLAB_MEX_FILE)
    if (state.outOfRange != 0){
        ssSetErrorStatus( S, "Initial state is out of range");
        return;
    }        
    if (mask.outOfRange != 0){
        ssSetErrorStatus( S, "Long code mask is out of range");
        return;
    }        
#endif
    
    /* Fill the par structure with the parameters */
    lcMask[0]  = mask.low;
    lcMask[1]  = mask.high;
    
    lcState[0]  = state.low;
    lcState[1]  = state.high;
    
    lcMask[1]  &= 0x3FF;
    lcState[1] &= 0x3FF;
}
#endif	/* MDL_INITIALIZE_CONDITIONS */


static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T    *decOut =  ssGetOutputPortRealSignal(S,0);
    lcgen_par params;

    params.decRatio = (int) mxGetScalar(DEC_RATIO_ARG);
    params.lcMask   = (unsigned long *) ssGetPWorkValue(S, 0);
    params.lcState  = (unsigned long *) ssGetPWorkValue(S, 1);
    params.numSymb  = (int) mxGetScalar(NUM_SYMB_ARG);
   
    /* Call the computational routine */
    {
        unsigned long charPoly[2] = {0x8e6f04ef, 0xa}; /* Same value for all instances */
        unsigned long bit_31, bit_41;                  /* Bits indexed from bit 0 bit_41 is bit 9 of the second word */ 
        unsigned long tempOut1, tempOut2;
        int i, posIndex = 0, numFrameChips = NUM_SYMBOL * DECIMATION_RATIO;

        for (i=0; i<numFrameChips; i++){
            if(!(i % DECIMATION_RATIO)){
                /* Testing for the decimated LC index */
                int j, auxOut;
            
                /* Mask the long code state */
                tempOut1 = LC_STATE[0] & LONGCODEMASK[0];  
                tempOut2 = LC_STATE[1] & LONGCODEMASK[1];
            
                /* Clear from previous operation */
                auxOut = 0;
                /* Perform the excluse-or of the masked states */
                for (j=0; j<32; j++){
                    auxOut ^= tempOut1;
                    tempOut1 >>= 1;
                }
                for (j=0; j<10; j++){
                    auxOut ^= tempOut2;
                    tempOut2 >>= 1;
                }
                auxOut &= 0x1;
                decOut[posIndex] = (real_T) auxOut;
                posIndex++;        
            }
            /* Get the next state */
        
            /* Get bit 31 and 41 */
            bit_31 = (LC_STATE[0])>>31 & 0x1;
            bit_41 = (LC_STATE[1])>>9 & 0x1;
        
            /* Perform the shift */
            LC_STATE[0] <<= 1;
            LC_STATE[1] <<= 1;
        
            /* Insert bit 31 into LSB of 2nd word */
            LC_STATE[1] |= bit_31;
        
            /* Get the next state */
            LC_STATE[0] ^= (bit_41 * charPoly[0]);
            LC_STATE[1] ^= (bit_41 * charPoly[1]);
        }
        LC_STATE[1] &= 0x3FF;
    }

}


static void mdlTerminate(SimStruct *S)
{
    unsigned long *lcMask  = (unsigned long *) ssGetPWorkValue(S, 0);
    unsigned long *lcState = (unsigned long *) ssGetPWorkValue(S, 1);
    
    free(lcMask);
    free(lcState);
}


#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif