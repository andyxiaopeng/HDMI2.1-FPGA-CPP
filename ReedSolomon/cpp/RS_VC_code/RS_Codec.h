#ifndef _RS_CODEC_H
#define _RS_CODEC_H

#include "data_types.h"

#define GF_SIZE			256			// pow(2, GF_M)
#define RS_N			255
#define RS_K			251			// 255,239 , 16
#define RS_T			2			// (RS_N-RS_K)/2    
#define RS_T2			4			// 2*RS_T

		
#endif		// _RS_CODEC_H

void RSCoder(UINT8 *pu8RSCoderInput, UINT8 *pu8RSCoderOutput, INT32 s32Size);

void RSDecoder(UINT8 *pu8RSDecIn, UINT8 *pu8RSDecOut, INT32 s32Size);