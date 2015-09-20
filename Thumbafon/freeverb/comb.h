/*
// Comb filter class declaration
//
// Written by Jezar at Dreampoint, June 2000
// http://www.dreampoint.co.uk
// This code is public domain
// Converted to C by Alastair M. Robinson, Jan 2001
*/

#ifndef _comb_
#define _comb_

#include "denormals.h"

struct Comb
{
	double	feedback;
	double	filterstore;
	double	damp1;
	double	damp2;
	double	*buffer;
	int	bufsize;
	int	bufidx;
};


// Big to inline - but crucial for speed
/*
inline double comb_process(struct Comb *cf,double input)
{
	double output;

	output = cf->buffer[cf->bufidx];
	undenormalise(output);

	cf->filterstore = (output*cf->damp2) + (cf->filterstore*cf->damp1);
	undenormalise(cf->filterstore);

	cf->buffer[cf->bufidx] = input + (cf->filterstore*cf->feedback);

	if(++cf->bufidx>=cf->bufsize) cf->bufidx = 0;

	return output;
}
*/

void comb_init(struct Comb *cf);
void comb_setbuffer(struct Comb *cf,double *buf, int size);
void comb_mute(struct Comb *cf);
void comb_setdamp(struct Comb *cf,double val);
double comb_getdamp(struct Comb *cf);
void comb_setfeedback(struct Comb *cf,double val);
double comb_getfeedback(struct Comb *cf);

#endif //_comb_

//ends
