/*
// Allpass filter declaration
//
// Written by Jezar at Dreampoint, June 2000
// http://www.dreampoint.co.uk
// This code is public domain
// Converted to C by Alastair M. Robinson, Jan 2001
*/

#ifndef _allpass_
#define _allpass_
#include "denormals.h"

struct AllPass {
 	double	feedback;
	double	*buffer;
	int	bufsize;
	int	bufidx;
};


// Big to inline - but crucial for speed
/*
inline double allpass_process(struct AllPass *ap,double input)
{
	double output;
	double bufout;
	
	bufout = ap->buffer[ap->bufidx];
	undenormalise(bufout);
	
	output = -input + bufout;
	ap->buffer[ap->bufidx] = input + (bufout*ap->feedback);

	if(++ap->bufidx>=ap->bufsize) ap->bufidx = 0;

	return output;
}
*/

void allpass_init(struct AllPass *ap);
void allpass_setbuffer(struct AllPass *ap,double *buf, int size);
void allpass_mute(struct AllPass *ap);
void allpass_setfeedback(struct AllPass *ap,double val);
double allpass_getfeedback(struct AllPass *ap);

#endif//_allpass

//ends
