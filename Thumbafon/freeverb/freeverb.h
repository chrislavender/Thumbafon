#ifndef _rms_samp_h_
#define _rms_samp_h_

#include "revmodel.h"

#define RMS_SAMP_NUM_REVERB_UNITS	1

typedef int		RMSRevPosType;
typedef double	RMSRevValType;

void						Reverb_Init(void);
void						Reverb_Release(void);

RMSRevValType				Reverb_GetRoomSize(const RMSRevPosType);
void						Reverb_SetRoomSize(const RMSRevPosType, const RMSRevValType);

RMSRevValType				Reverb_GetDamp(const RMSRevPosType);
void						Reverb_SetDamp(const RMSRevPosType, const RMSRevValType);

RMSRevValType				Reverb_GetWet(const RMSRevPosType);
void						Reverb_SetWet(const RMSRevPosType, const RMSRevValType);

RMSRevValType				Reverb_GetDry(const RMSRevPosType);
void						Reverb_SetDry(const RMSRevPosType, const RMSRevValType);

RMSRevValType				Reverb_GetWidth(const RMSRevPosType);
void						Reverb_SetWidth(const RMSRevPosType, const RMSRevValType);

RMSRevValType				Reverb_GetInputGainA(const RMSRevPosType id);
void						Reverb_SetInputGainA(const RMSRevPosType id, const RMSRevValType val);
//RMSRevValType				Reverb_GetInputGainB(const RMSRevPosType id);
//void						Reverb_SetInputGainB(const RMSRevPosType id, const RMSRevValType val);
//RMSRevValType				Reverb_GetInputGainC(const RMSRevPosType id);
//void						Reverb_SetInputGainC(const RMSRevPosType id, const RMSRevValType val);
//RMSRevValType				Reverb_GetInputGainD(const RMSRevPosType id);
//void						Reverb_SetInputGainD(const RMSRevPosType id, const RMSRevValType val);
//RMSRevValType				Reverb_GetInputGainE(const RMSRevPosType id);
//void						Reverb_SetInputGainE(const RMSRevPosType id, const RMSRevValType val);

void	revmodel_process(double* io,
						 long numsamples,
						 int skip);

#endif
