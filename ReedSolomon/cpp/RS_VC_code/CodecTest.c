
/*******************************************************************************

        (c) COPYRIGHT 2003-2004 by Profound Communication, Inc.
                          All rights reserved.

     This software is confidential and proprietary to Profound 
     Communication, Inc.  No part of this software may be reproduced,
     stored, transmitted, disclosed or used in any form or by any means
     other than as expressly provided by the written license agreement
     between Profound and its licensee.
     
*******************************************************************************/
/*******************************************************************************
File:	CodecTest.c
Type:   C source file
Funcs:	
Desc:   

	 
Version Control:
Date		Author			Version			Modified 
20041018	ZhangPeng		1.0				Orignal
	
Test Record£º
Date		Tester			Case			

*******************************************************************************/
#include "RS_Codec.h"
#include "CodecTest.h"

#include <stdio.h>


extern UINT8 AlphaVec[GF_SIZE];
extern UINT8 AlphaExp[GF_SIZE];

void main()
{
	INT32 i; 
	INT32 TempIndex1, TempIndex2, TempIndex3, TempIndex4;
	INT32 FrmCt, ErrCt=0;
	UINT8 source[RS_K];
	
//	UINT8 source[RS_K] = {0xF, 0xE, 0xD, 0xC, 0xB, 0xA, 0x9, 0x8, 0x7};
//	UINT8 source[RS_K] = {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
//	UINT8 source[RS_K] = {0x1, 0x2, 0x3, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
			
	UINT8 coded_data[RS_N];
	
	UINT8 dec_in[RS_N];
	
	UINT8 dec_out[RS_K];
	
	srand(35345);
	
	for (FrmCt=0; FrmCt<2; FrmCt++)
	{
		for (i=0; i<RS_K; i++)
		{
			source[i] = i;
		}
	
		RSCoder(source, coded_data, RS_K);
		
		for (i=0; i<RS_N; i++)
		{
			dec_in[i] = coded_data[i];
		}

		// for (i = 0; i < RS_N; i++)
		// {
		// 	printf("%s", "index = ");
		// 	printf("%d", i); 
		// 	printf("%s", "    value = ");
		// 	printf("%d \n", source[i]);
		// }


		/*
		dec_in[3] = dec_in[3] ^ AlphaVec[23];
		for (i=0; i<RS_K; i++)
		{
			if (source[i] != dec_in[i])
			{
				ErrCt++;
			}
		}
		*/

		// ÒýÈë´íÎó
//		TempIndex1 = (rand() & RS_N);
//		dec_in[TempIndex1] = dec_in[TempIndex1] & (rand() & RS_N);
//		dec_in[TempIndex1] = AlphaVec[234];
		
//		TempIndex2 = (rand() & RS_N);
//		dec_in[TempIndex2] = dec_in[TempIndex2] & (rand() & RS_N);
//		dec_in[TempIndex2] = AlphaVec[24];
			
//		TempIndex3 = (rand() & RS_N);
//		dec_in[TempIndex3] = dec_in[TempIndex3] & (rand() & RS_N);
//		dec_in[TempIndex3] = AlphaVec[167];
		
//		TempIndex4 = (rand() & RS_N);
//		dec_in[TempIndex4] = dec_in[TempIndex4] & (rand() & RS_N);
	
	//	dec_in[2] = dec_in[2]^AlphaVec[4];
	//	dec_in[8] = dec_in[8]^AlphaVec[3];
	//	dec_in[11] = dec_in[11]^AlphaVec[7];

		dec_in[3] = dec_in[3]^AlphaVec[23];
		dec_in[58] = dec_in[58]^AlphaVec[2];
		//dec_in[170] = dec_in[170]^AlphaVec[79];

		RSDecoder(dec_in, dec_out, RS_K);
		
		for (i=0; i<RS_K; i++)
		{
			if (source[i] != dec_out[i])
			{
				ErrCt++;
			}
		}
		printf("%d \n", ErrCt);
		ErrCt = 0;
	}
	// ErrCt = 0;
}


