/*
// Reverb model declaration
//
// Written by Jezar at Dreampoint, June 2000
// http://www.dreampoint.co.uk
// This code is public domain
// Converted to C by Alastair M. Robinson January 2001
*/

#ifndef _revmodel_
#define _revmodel_

#include "comb.h"
#include "allpass.h"
#include "tuning.h"

struct RevModel {
	double	gain;
	double	roomsize,roomsize1;
	double	damp,damp1;
	double	wet,wet1,wet2;
	double	dry;
	double	width;
	double	mode;

	// The following are all declared inline 
	// to remove the need for dynamic allocation
	// with its subsequent error-checking messiness

	// Comb filters
	struct Comb	combL[numcombs];
	struct Comb	combR[numcombs];

	// Allpass filters
	struct AllPass	allpassL[numallpasses];
	struct AllPass	allpassR[numallpasses];

	// Buffers for the combs
	double	bufcombL1[combtuningL1];
	double	bufcombR1[combtuningR1];
	double	bufcombL2[combtuningL2];
	double	bufcombR2[combtuningR2];
	double	bufcombL3[combtuningL3];
	double	bufcombR3[combtuningR3];
	double	bufcombL4[combtuningL4];
	double	bufcombR4[combtuningR4];
	double	bufcombL5[combtuningL5];
	double	bufcombR5[combtuningR5];
	double	bufcombL6[combtuningL6];
	double	bufcombR6[combtuningR6];
	double	bufcombL7[combtuningL7];
	double	bufcombR7[combtuningR7];
	double	bufcombL8[combtuningL8];
	double	bufcombR8[combtuningR8];

	// Buffers for the allpasses
	double	bufallpassL1[allpasstuningL1];
	double	bufallpassR1[allpasstuningR1];
	double	bufallpassL2[allpasstuningL2];
	double	bufallpassR2[allpasstuningR2];
	double	bufallpassL3[allpasstuningL3];
	double	bufallpassR3[allpasstuningR3];
	double	bufallpassL4[allpasstuningL4];
	double	bufallpassR4[allpasstuningR4];
};


void revmodel_init(struct RevModel *rm);
void revmodel_mute(struct RevModel *rm);
void revmodel_processreplace(struct RevModel *rm,double *inputL, double *inputR, double *outputL, double *outputR, long numsamples, int skip);
void revmodel_processmix(struct RevModel *rm,double *inputL, double *inputR, double *outputL, double *outputR, long numsamples, int skip);
void revmodel_update(struct RevModel *rm);

void revmodel_setroomsize(struct RevModel *rm,double value);
double revmodel_getroomsize(struct RevModel *rm);
void revmodel_setdamp(struct RevModel *rm,double value);
double revmodel_getdamp(struct RevModel *rm);
void revmodel_setwet(struct RevModel *rm,double value);
double revmodel_getwet(struct RevModel *rm);
void revmodel_setdry(struct RevModel *rm,double value);
double revmodel_getdry(struct RevModel *rm);
void revmodel_setwidth(struct RevModel *rm,double value);
double revmodel_getwidth(struct RevModel *rm);
void revmodel_setmode(struct RevModel *rm,double value);
double revmodel_getmode(struct RevModel *rm);

#endif /*_revmodel_*/

/* ends */

