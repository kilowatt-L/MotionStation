// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.4 $  $Date: 2003/10/15 18:32:46 $

#ifndef _nidaqerr_h
#define _nidaqerr_h

#define DAQERROR_BASE  (-1000)
#define DEFINE_ERROR(_x) (_x+DAQERROR_BASE)
#define E_INVALID_TRANSFER_MODE		DEFINE_ERROR(1)
#define E_INVALID_TRIG_SRC		DEFINE_ERROR(2)
#define E_E_SERIES_ONLY			DEFINE_ERROR(3)
#define E_UNSUPPORTED			DEFINE_ERROR(4)
#define E_INVALID_HW_TRIG_CONDITION	DEFINE_ERROR(5)
#define E_INVALID_TRIG_CHANNEL		DEFINE_ERROR(6)
#define E_INVALID_SW_TRIG_CONDITION	DEFINE_ERROR(7)
#define E_INVALID_CHAN_RANGE		DEFINE_ERROR(8)
#define E_INVALID_DEVICE_ID		DEFINE_ERROR(9)
#define E_SAFEARRAY_ERR			DEFINE_ERROR(10)
#define E_MEM_ERR			DEFINE_ERROR(11)
#define E_INVALID_CHAN_RANGE_LO         DEFINE_ERROR(12)
#define E_HWND_FAIL			DEFINE_ERROR(13)
#define E_INVALID_WFM_GROUP		DEFINE_ERROR(14)
#define E_INVALID_OUTPUT_CHAN		DEFINE_ERROR(15)
#define E_AO_UNSUPPORTED                DEFINE_ERROR(16)
#define E_INVALID_TRIG_VALUE            DEFINE_ERROR(17)
#define E_ENGINE_ACCESS_ERR             DEFINE_ERROR(18)
#define E_UNKNOWN			DEFINE_ERROR(19)
#define E_INV_CHANSKEW			DEFINE_ERROR(20)
#define E_EXCEEDS_MAX_RATE		DEFINE_ERROR(21)
#define E_INVALID_INPUT_CHANNEL         DEFINE_ERROR(22)
#define E_NO_CHANSKEW                   DEFINE_ERROR(23)
#define E_BAD_DEVICE                    DEFINE_ERROR(24)
#define E_INV_NUM_MUX                   DEFINE_ERROR(25)
#define E_TRIG_PARAM_ERR                DEFINE_ERROR(26) 
#define E_CHANSKEW_CALCULATED           DEFINE_ERROR(27)
#define E_PRETRIGGER_NOT_SUPPORTED      DEFINE_ERROR(28)
#define E_INVALIED_MUX_CHAN_SETUP       DEFINE_ERROR(29)
#define E_HWCHANNEL_MAY_NOT_BE_SET_FOR_LAB  DEFINE_ERROR(30)
#define E_TRIGGER_REP_NOT_SUPPORTED     DEFINE_ERROR(31)
#define E_TRIGGER_CHANNEL_MUST_BE_FIRST DEFINE_ERROR(32)
#define E_AI_UNSUPPORTED                DEFINE_ERROR(33)
#define E_DIO_UNSUPPORTED               DEFINE_ERROR(34)
#define E_INVALID_CHANSKEW              DEFINE_ERROR(35)


// No errors in the rc file because those are unsigned...
#endif 