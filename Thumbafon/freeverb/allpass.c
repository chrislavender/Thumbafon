/*
// Allpass filter implementation
//
// Written by Jezar at Dreampoint, June 2000
// http://www.dreampoint.co.uk
// This code is public domain
// Converted to C by Alastair M. Robinson January 2001
*/

#include "allpass.h"

void allpass_init(struct AllPass *ap)
{
	ap->bufidx = 0;
}

void allpass_setbuffer(struct AllPass *ap,double *buf, int size) 
{
	ap->buffer = buf; 
	ap->bufsize = size;
}

void allpass_mute(struct AllPass *ap)
{
        int i;
	for (i=0; i<ap->bufsize; i++)
		ap->buffer[i]=0;
}

void allpass_setfeedback(struct AllPass *ap,double val) 
{
	ap->feedback = val;
}

double allpass_getfeedback(struct AllPass *ap) 
{
	return ap->feedback;
}

//ends
