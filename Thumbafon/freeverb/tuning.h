// Reverb model tuning values
//
// Written by Jezar at Dreampoint, June 2000
// http://www.dreampoint.co.uk
// This code is public domain

#ifndef _tuning_
#define _tuning_

#define	numcombs 8
#define	numallpasses 4

#define fixedgain 0.005f
#define scalewet 3
#define scaledry 2
#define scaledamp 0.4f
#define scaleroom 0.28f
#define offsetroom 0.7f
#define initialroom 0.9f
#define initialdamp 0.2f
#define initialwet 0.2f
#define initialdry 0.5f
#define initialwidth 0.9f
#define initialmode 0
#define freezemode 0.5f
#define stereospread 23

// These values assume 44.1KHz sample rate
// they will probably be OK for 48KHz sample rate
// but would need scaling for 96KHz (or other) sample rates.
// The values were obtained by listening tests.
#define combtuningL1	 1116
#define combtuningR1	 1116+stereospread
#define combtuningL2	 1188
#define combtuningR2	 1188+stereospread
#define combtuningL3	 1277
#define combtuningR3	 1277+stereospread
#define combtuningL4	 1356
#define combtuningR4	 1356+stereospread
#define combtuningL5	 1422
#define combtuningR5	 1422+stereospread
#define combtuningL6	 1491
#define combtuningR6	 1491+stereospread
#define combtuningL7	 1557
#define combtuningR7	 1557+stereospread
#define combtuningL8	 1617
#define combtuningR8	 1617+stereospread
#define allpasstuningL1	 556
#define allpasstuningR1	 556+stereospread
#define allpasstuningL2	 441
#define allpasstuningR2	 441+stereospread
#define allpasstuningL3	 341
#define allpasstuningR3	 341+stereospread
#define allpasstuningL4	 225
#define allpasstuningR4	 225+stereospread

#endif//_tuning_

//ends

