/*
// Reverb model implementation
//
// Written by Jezar at Dreampoint, June 2000
// http://www.dreampoint.co.uk
// This code is public domain
//
// Converted from C++ to C in Jan 2001 by Alastair M. Robinson
*/

#include <stdio.h>

#include "revmodel.h"

void revmodel_init(struct RevModel *rm) {
	int i;

	fprintf(stderr,"Initialising Reverb model\n");

	for (i=0;i<numcombs;i++) {
		comb_init(&rm->combL[i]);
		comb_init(&rm->combR[i]);
	}
	for (i=0;i<numallpasses;i++) {
		allpass_init(&rm->allpassL[i]);
		allpass_init(&rm->allpassR[i]);
	}

	/* Tie the components to their buffers */
	comb_setbuffer(&rm->combR[0],rm->bufcombR1,combtuningR1);
	comb_setbuffer(&rm->combL[0],rm->bufcombL1,combtuningL1);
	comb_setbuffer(&rm->combR[1],rm->bufcombR2,combtuningR2);
	comb_setbuffer(&rm->combL[1],rm->bufcombL2,combtuningL2);
	comb_setbuffer(&rm->combR[2],rm->bufcombR3,combtuningR3);
	comb_setbuffer(&rm->combL[2],rm->bufcombL3,combtuningL3);
	comb_setbuffer(&rm->combR[3],rm->bufcombR4,combtuningR4);
	comb_setbuffer(&rm->combL[3],rm->bufcombL4,combtuningL4);
	comb_setbuffer(&rm->combR[4],rm->bufcombR5,combtuningR5);
	comb_setbuffer(&rm->combL[4],rm->bufcombL5,combtuningL5);
	comb_setbuffer(&rm->combR[5],rm->bufcombR6,combtuningR6);
	comb_setbuffer(&rm->combL[5],rm->bufcombL6,combtuningL6);
	comb_setbuffer(&rm->combR[6],rm->bufcombR7,combtuningR7);
	comb_setbuffer(&rm->combL[6],rm->bufcombL7,combtuningL7);
	comb_setbuffer(&rm->combR[7],rm->bufcombR8,combtuningR8);
	comb_setbuffer(&rm->combL[7],rm->bufcombL8,combtuningL8);

	allpass_setbuffer(&rm->allpassL[0],rm->bufallpassL1,allpasstuningL1);
	allpass_setbuffer(&rm->allpassR[0],rm->bufallpassR1,allpasstuningR1);
	allpass_setbuffer(&rm->allpassL[1],rm->bufallpassL2,allpasstuningL2);
	allpass_setbuffer(&rm->allpassR[1],rm->bufallpassR2,allpasstuningR2);
	allpass_setbuffer(&rm->allpassL[2],rm->bufallpassL3,allpasstuningL3);
	allpass_setbuffer(&rm->allpassR[2],rm->bufallpassR3,allpasstuningR3);
	allpass_setbuffer(&rm->allpassL[3],rm->bufallpassL4,allpasstuningL4);
	allpass_setbuffer(&rm->allpassR[3],rm->bufallpassR4,allpasstuningR4);

	/* Set default values */
	allpass_setfeedback(&rm->allpassL[0],0.5f);
	allpass_setfeedback(&rm->allpassR[0],0.5f);
	allpass_setfeedback(&rm->allpassL[1],0.5f);
	allpass_setfeedback(&rm->allpassR[1],0.5f);
	allpass_setfeedback(&rm->allpassL[2],0.5f);
	allpass_setfeedback(&rm->allpassR[2],0.5f);
	allpass_setfeedback(&rm->allpassL[3],0.5f);
	allpass_setfeedback(&rm->allpassR[3],0.5f);

	revmodel_setwet(rm,initialwet);
	revmodel_setroomsize(rm,initialroom);
	revmodel_setdry(rm,initialdry);
	revmodel_setdamp(rm,initialdamp);
	revmodel_setwidth(rm,initialwidth);
/*	revmodel_setmode(rm,initialmode); */

	/* Buffers will be full of rubbish - so we MUST mute them */
	revmodel_mute(rm);
}

void revmodel_mute(struct RevModel *rm) {
	int i;

/*	if (rm->mode==freezemode)
		return; */

	for (i=0;i<numcombs;i++) {
		comb_mute(&rm->combL[i]);
		comb_mute(&rm->combR[i]);
	}
	for (i=0;i<numallpasses;i++) {
		allpass_mute(&rm->allpassL[i]);
		allpass_mute(&rm->allpassR[i]);
	}
}

void revmodel_processreplace(struct RevModel *rm,double *inputL, double *inputR, double *outputL, double *outputR, long numsamples, int skip) {
	double outL,outR,input,output;
	int i;

	while(numsamples-- > 0) {
		outL = outR = 0;
		input = (*inputL + *inputR) * rm->gain;

		/* Accumulate comb filters in parallel */
		for(i=0; i<numcombs; i++) {
                   struct Comb *cf=&rm->combL[i];

                   output = cf->buffer[cf->bufidx];
                   undenormalise(output);

                   cf->filterstore = (output*cf->damp2) + (cf->filterstore*cf->damp1);
                   undenormalise(cf->filterstore);

                   cf->buffer[cf->bufidx] = input + (cf->filterstore*cf->feedback);

                   if(++cf->bufidx>=cf->bufsize) cf->bufidx = 0;

                   outL+=output;

                   cf=&rm->combR[i];

                   output = cf->buffer[cf->bufidx];
                   undenormalise(output);

                   cf->filterstore = (output*cf->damp2) + (cf->filterstore*cf->damp1);
                   undenormalise(cf->filterstore);

                   cf->buffer[cf->bufidx] = input + (cf->filterstore*cf->feedback);

                   if(++cf->bufidx>=cf->bufsize) cf->bufidx = 0;

                   outR+=output;
		}

		/* Feed through allpasses in series */
		for(i=0; i<numallpasses; i++) {
                   struct AllPass *apl,*apr;
                   double bufoutl,bufoutr;

                   apl=&rm->allpassL[i];
                   apr=&rm->allpassR[i];
	
                   bufoutl = apl->buffer[apl->bufidx];
                   bufoutr = apr->buffer[apr->bufidx];

                   undenormalise(bufoutl);
                   undenormalise(bufoutr);
	
                   output = -outL + bufoutl;
                   apl->buffer[apl->bufidx] = outL + ((bufoutl)*apl->feedback);

                   if(++apl->bufidx>=apl->bufsize) apl->bufidx = 0;
	
                   outL=output;	

                   output = -outR + bufoutr;
                   apr->buffer[apr->bufidx] = outR + ((bufoutr)*apr->feedback);

                   if(++apr->bufidx>=apr->bufsize) apr->bufidx = 0;

                   outR=output;
		}

		/* Calculate output REPLACING anything already there */
		*outputL = outL*rm->wet1 + outR*rm->wet2 + *inputL*rm->dry;
		*outputR = outR*rm->wet1 + outL*rm->wet2 + *inputR*rm->dry;

		/* Increment sample pointers, allowing for interleave (if any) */
		inputL += skip;
		inputR += skip;
		outputL += skip;
		outputR += skip;
	}
}

void revmodel_processmix(struct RevModel *rm,double *inputL, double *inputR, double *outputL, double *outputR, long numsamples, int skip)
{
	double outL,outR,input,output;
	int i;

	while(numsamples-- > 0) {
		outL = outR = 0;
		input = (*inputL + *inputR) * rm->gain;

		/* Accumulate comb filters in parallel */
		for(i=0; i<numcombs; i++) {
                   struct Comb *cf=&rm->combL[i];

                   output = cf->buffer[cf->bufidx];
                   undenormalise(output);

                   cf->filterstore = (output*cf->damp2) + (cf->filterstore*cf->damp1);
                   undenormalise(cf->filterstore);

                   cf->buffer[cf->bufidx] = input + (cf->filterstore*cf->feedback);

                   if(++cf->bufidx>=cf->bufsize) cf->bufidx = 0;

                   outL+=output;

                   cf=&rm->combR[i];

                   output = cf->buffer[cf->bufidx];
                   undenormalise(output);

                   cf->filterstore = (output*cf->damp2) + (cf->filterstore*cf->damp1);
                   undenormalise(cf->filterstore);

                   cf->buffer[cf->bufidx] = input + (cf->filterstore*cf->feedback);

                   if(++cf->bufidx>=cf->bufsize) cf->bufidx = 0;

                   outR+=output;
		}

		/* Feed through allpasses in series */
		for(i=0; i<numallpasses; i++) {
                   struct AllPass *ap;
                   double bufout;

                   ap=&rm->allpassL[i];
	
                   bufout = ap->buffer[ap->bufidx];
                   undenormalise(bufout);
	
                   outL = -input + bufout;
                   ap->buffer[ap->bufidx] = input + (bufout*ap->feedback);

                   if(++ap->bufidx>=ap->bufsize) ap->bufidx = 0;

                   ap=&rm->allpassR[i];
	
                   bufout = ap->buffer[ap->bufidx];
                   undenormalise(bufout);
	
                   outR = -input + bufout;
                   ap->buffer[ap->bufidx] = input + (bufout*ap->feedback);

                   if(++ap->bufidx>=ap->bufsize) ap->bufidx = 0;

		}

		/* Calculate output MIXING with anything already there */
		*outputL += outL*rm->wet1 + outR*rm->wet2 + *inputL*rm->dry;
		*outputR += outR*rm->wet1 + outL*rm->wet2 + *inputR*rm->dry;

		/* Increment sample pointers, allowing for interleave (if any) */
		inputL += skip;
		inputR += skip;
		outputL += skip;
		outputR += skip;
	}
}

void revmodel_update(struct RevModel *rm) {
	/* Recalculate internal values after parameter change */

	int i;

	rm->wet1 = rm->wet*(rm->width/2 + 0.5f);
	rm->wet2 = rm->wet*((1-rm->width)/2);

/*
	if (rm->mode==freezemode) {
		rm->roomsize1 = 1;
		rm->damp1 = 0;
		rm->gain = 0;
	}
	else
*/
	{
		rm->roomsize1 = rm->roomsize;
		rm->damp1 = rm->damp;
		rm->gain = fixedgain;
	}

	for(i=0; i<numcombs; i++) {
                comb_setfeedback(&rm->combL[i],rm->roomsize1);
                comb_setfeedback(&rm->combR[i],rm->roomsize1);
	}

	for(i=0; i<numcombs; i++) {
                comb_setdamp(&rm->combL[i],rm->damp1);
                comb_setdamp(&rm->combR[i],rm->damp1);
	}
}


void revmodel_setroomsize(struct RevModel *rm,double value) {
	rm->roomsize = (value*scaleroom) + offsetroom;
	revmodel_update(rm);
}

double revmodel_getroomsize(struct RevModel *rm) {
	return (rm->roomsize-offsetroom)/scaleroom;
}

void revmodel_setdamp(struct RevModel *rm,double value) {
	rm->damp = value*scaledamp;
	revmodel_update(rm);
}

double revmodel_getdamp(struct RevModel *rm) {
	return rm->damp/scaledamp;
}

void revmodel_setwet(struct RevModel *rm,double value) {
	rm->wet = value*scalewet;
	revmodel_update(rm);
}

double revmodel_getwet(struct RevModel *rm) {
	return rm->wet/scalewet;
}

void revmodel_setdry(struct RevModel *rm,double value) {
	rm->dry = value*scaledry;
}

double revmodel_getdry(struct RevModel *rm) {
	return rm->dry/scaledry;
}

void revmodel_setwidth(struct RevModel *rm,double value) {
	rm->width = value;
	revmodel_update(rm);
}

double revmodel_getwidth(struct RevModel *rm) {
	return rm->width;
}

void revmodel_setmode(struct RevModel *rm,double value) {
	rm->mode = value;
	revmodel_update(rm);
}

double revmodel_getmode(struct RevModel *rm) {
	if (rm->mode==freezemode)
		return 1;
	else
		return 0;
}

/* ends */

