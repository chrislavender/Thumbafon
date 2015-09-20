/*
// Comb filter implementation
//
// Written by Jezar at Dreampoint, June 2000
// http://www.dreampoint.co.uk
// This code is public domain
// Converted to C by Alastair M. Robinson, Jan 2001
*/

#include "comb.h"

void comb_init(struct Comb *cf)
{
	cf->filterstore = 0;
	cf->bufidx = 0;
}

void comb_setbuffer(struct Comb *cf,double *buf, int size) 
{
	cf->buffer = buf; 
	cf->bufsize = size;
}

void comb_mute(struct Comb *cf)
{
        int i;
	for (i=0; i<cf->bufsize; i++)
		cf->buffer[i]=0;
}

void comb_setdamp(struct Comb *cf,double val) 
{
	cf->damp1 = val; 
	cf->damp2 = 1-val;
}

double comb_getdamp(struct Comb *cf) 
{
	return cf->damp1;
}

void comb_setfeedback(struct Comb *cf,double val) 
{
	cf->feedback = val;
}

double comb_getfeedback(struct Comb *cf) 
{
	return cf->feedback;
}

// ends
