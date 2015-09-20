// Macro for killing denormalled numbers
//
// Written by Jezar at Dreampoint, June 2000
// http://www.dreampoint.co.uk
// Based on IS_DENORMAL macro by Jon Watte
// This code is public domain

#ifndef _denormals_
#define _denormals_

#if 0
#define undenormalise(sample) if(((*(unsigned int*)&sample)&0x7f800000)==0) sample=0.0f
#else
#define undenormalise(sample) if(((((int *)&sample)[1])&0x7fe00000) == 0) sample = 0.0
#endif

#endif//_denormals_

//ends
