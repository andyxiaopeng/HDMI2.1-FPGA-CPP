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
File:	RS_Codec.c
Type:   C source file
Funcs:	
Desc:   RS Codec

	 
Version Control:
Date		Author			Version			Modified 
20041012	Zhangpeng			2.0			Orignal(Refering to LiuYu's program) 
	
Test Record：
Date		Tester			Case			

*******************************************************************************/

#include "RS_Codec.h"

// 生成阵
//UINT8 RSGen[7] = {21, 181, 9, 137, 2, 167, 0};
//UINT8 RSGen[17] = {136,240,208,195,181,158,201,100,11,83,167,107,113,110,106,121,0};
//UINT8 RSGen[5] = { 64,120,54,15,1};
//UINT8 RSGen[5] = { 6,78,249,75,0 };
UINT8 RSGen[5] = { 10,81,251,76,0 };

// 幂到向量查找表
UINT8 AlphaVec[GF_SIZE] = 
{
	1, 2, 4, 8, 16, 32, 64, 128, 29, 58, 116, 232, 205, 135, 19, 38, 
	76, 152, 45, 90, 180, 117, 234, 201, 143, 3, 6, 12, 24, 48, 96, 192, 
	157, 39, 78, 156, 37, 74, 148, 53, 106, 212, 181, 119, 238, 193, 159, 35, 
	70, 140, 5, 10, 20, 40, 80, 160, 93, 186, 105, 210, 185, 111, 222, 161, 
	95, 190, 97, 194, 153, 47, 94, 188, 101, 202, 137, 15, 30, 60, 120, 240, 
	253, 231, 211, 187, 107, 214, 177, 127, 254, 225, 223, 163, 91, 182, 113, 226, 
	217, 175, 67, 134, 17, 34, 68, 136, 13, 26, 52, 104, 208, 189, 103, 206, 
	129, 31, 62, 124, 248, 237, 199, 147, 59, 118, 236, 197, 151, 51, 102, 204, 
	133, 23, 46, 92, 184, 109, 218, 169, 79, 158, 33, 66, 132, 21, 42, 84, 
	168, 77, 154, 41, 82, 164, 85, 170, 73, 146, 57, 114, 228, 213, 183, 115, 
	230, 209, 191, 99, 198, 145, 63, 126, 252, 229, 215, 179, 123, 246, 241, 255, 
	227, 219, 171, 75, 150, 49, 98, 196, 149, 55, 110, 220, 165, 87, 174, 65, 
	130, 25, 50, 100, 200, 141, 7, 14, 28, 56, 112, 224, 221, 167, 83, 166, 
	81, 162, 89, 178, 121, 242, 249, 239, 195, 155, 43, 86, 172, 69, 138, 9, 
	18, 36, 72, 144, 61, 122, 244, 245, 247, 243, 251, 235, 203, 139, 11, 22, 
	44, 88, 176, 125, 250, 233, 207, 131, 27, 54, 108, 216, 173, 71, 142, 0, 	
};

// 向量到幂查找表
UINT8 AlphaExp[GF_SIZE] = 
{
	255, 0, 1, 25, 2, 50, 26, 198, 3, 223, 51, 238, 27, 104, 199, 75, 
	4, 100, 224, 14, 52, 141, 239, 129, 28, 193, 105, 248, 200, 8, 76, 113, 
	5, 138, 101, 47, 225, 36, 15, 33, 53, 147, 142, 218, 240, 18, 130, 69, 
	29, 181, 194, 125, 106, 39, 249, 185, 201, 154, 9, 120, 77, 228, 114, 166, 
	6, 191, 139, 98, 102, 221, 48, 253, 226, 152, 37, 179, 16, 145, 34, 136, 
	54, 208, 148, 206, 143, 150, 219, 189, 241, 210, 19, 92, 131, 56, 70, 64, 
	30, 66, 182, 163, 195, 72, 126, 110, 107, 58, 40, 84, 250, 133, 186, 61, 
	202, 94, 155, 159, 10, 21, 121, 43, 78, 212, 229, 172, 115, 243, 167, 87, 
	7, 112, 192, 247, 140, 128, 99, 13, 103, 74, 222, 237, 49, 197, 254, 24, 
	227, 165, 153, 119, 38, 184, 180, 124, 17, 68, 146, 217, 35, 32, 137, 46, 
	55, 63, 209, 91, 149, 188, 207, 205, 144, 135, 151, 178, 220, 252, 190, 97, 
	242, 86, 211, 171, 20, 42, 93, 158, 132, 60, 57, 83, 71, 109, 65, 162, 
	31, 45, 67, 216, 183, 123, 164, 118, 196, 23, 73, 236, 127, 12, 111, 246, 
	108, 161, 59, 82, 41, 157, 85, 170, 251, 96, 134, 177, 187, 204, 62, 90, 
	203, 89, 95, 176, 156, 169, 160, 81, 11, 245, 22, 235, 122, 117, 44, 215, 
	79, 174, 213, 233, 230, 231, 173, 232, 116, 214, 244, 234, 168, 80, 88, 175, 
};

/*---------------------------------------------------------------
函数:
	void RSCoder(UINT8 *pu8RSCoderInput, UINT8 *pu8RSCoderOutput, INT32 s32Size)
介绍:
	RS码编码函数
参数:
	输入参数: 

	输出参数: 

返回值:
	无
---------------------------------------------------------------*/
void RSCoder(UINT8 *pu8RSCoderInput, UINT8 *pu8RSCoderOutput, INT32 s32Size)
{
	INT32 i, j;				
	
	UINT8 TempInput;			
		
	UINT8 FBVec;				// 反馈向量
	
	INT32 FBExp;				// 反馈幂次
	
	UINT8 ZGVec;				// Z*G 向量
	
	INT32 ZGExp;				// Z*G 幂次
	
	UINT8 RegVec[RS_N-RS_K];	// 寄存器
	
	// 寄存器清0
	for (i=0; i<RS_N-RS_K; i++)
	{
		RegVec[i] = 0;
	}
	
	// 前面的K个
	for (i=0; i<RS_K; i++)
	{
		if (i<s32Size)
		{
			TempInput = *(pu8RSCoderInput+i);
		}
		else
		{
			TempInput = 0;
		}
		
		FBVec = TempInput^RegVec[RS_N-RS_K-1];
		if (FBVec == 0)
		{
			for (j=RS_N-RS_K-1; j>0; j--)
			{
				RegVec[j] = RegVec[j-1];
			}
			RegVec[0] = 0;
		}
		else
		{
			FBExp = AlphaExp[FBVec];
		
			// 更新寄存器
   			for (j=RS_N-RS_K-1; j>0; j--)
   			{
   				ZGExp = (FBExp + RSGen[j])%RS_N;		// 幂相加
   				ZGVec = AlphaVec[ZGExp];				// 查找幂对应的矢量
   				RegVec[j] = ZGVec ^ RegVec[j-1];		// 矢量模2相加
   			}
   			ZGExp = (FBExp + RSGen[0])%RS_N;
   			RegVec[0] = AlphaVec[ZGExp];
   		}							
   		
   		// 前面K个信息向量		
		*(pu8RSCoderOutput+i) = TempInput;
	}
	
	// 校验位
	for (i=RS_N-RS_K-1; i>=0; i--)
	{
		*(pu8RSCoderOutput+RS_N-i-1) = RegVec[i];
	}
}

/*---------------------------------------------------------------
函数:
	void RSDecoder(UINT8 *pu8RSDecIn, UINT8 *pu8RSDecOut, INT32 s32Size)
介绍:
	RS码译码函数
参数:
	输入参数: 

	输出参数: 

返回值:
	无
---------------------------------------------------------------*/
void RSDecoder(UINT8 *pu8RSDecIn, UINT8 *pu8RSDecOut, INT32 s32Size)
{
	INT32 i, j;									// 循环变量
	UINT8 TempVec, TempVec1;					// 临时变量(向量)
	INT32 TempExp;								// 临时变量(幂)
	INT32 RExp;									// 接收向量的幂
	UINT8 RVec;
	UINT8 Delta[RS_T2];							// Berlekamp算法中的Delta(幂)
	UINT8 DeltaVecTemp[RS_T2];
	UINT8 Sigma[RS_T2+1][2*RS_T2];				// Berlekamp算法中的Sigma(幂)
	UINT8 SigmaVecTemp[RS_T2];
	UINT8 TempSigma[2*RS_T2];					// 临时Sigma(幂)
	UINT8 SigmaFN[RS_T2];						// Forney算法SigmaForney(幂)
	INT32 TempSigmaIndex;						// X的幂次(临时)
	INT32 DCoef;								// 系数(临时)(幂)
	INT32 M;									// Berlekamp算法中的m
	UINT8 S[RS_T2];								// Berlekamp算法中的Si(幂)
	UINT8 SVecTemp[RS_T2];
	UINT8 L[RS_T2+1];							// Berlekamp算法中的Li
	INT32 iL;
	UINT8 TempL;
	INT32 ErrorPos;								// 差错位置
	INT32 ErrorNum;								// 差错个数
	INT32 ErrorExp;								// 差错向量幂次
	UINT8 NumeratorVec, DenominatorVec;			// Forney分子、分母（向量）
	
	// 写输出
	for (i=0; i<s32Size; i++)
	{
		*(pu8RSDecOut + i) = *(pu8RSDecIn + i);
	}
		
	// 计算Si, 0--(2t-1)  代表 1--2t    （S 应该是伴随多项式）
	for (i=0; i<RS_T2; i++) // Si
	{
		TempVec = 0;
		for (j=0; j<RS_N; j++) // 从下标 RS_N-1  到 下标0    循环遍历输入数据的每个元素
		{
			RVec = *(pu8RSDecIn+RS_N-1-j);   // 循环遍历输入数据的每个元素 来计算得到 Si
			if (RVec != 0) 					// 零向量特殊处理
			{
				RExp = AlphaExp[RVec];					
               	TempExp = (RExp + j*(i+1)) % RS_N;		// 乘       计算j*(i+1) 对RExp进行移位 得到 Si的 每一项的 指数
				//TempExp = (RExp + j*(i)) % RS_N;

               	TempVec1 = AlphaVec[TempExp];
   		    	TempVec = TempVec^TempVec1;            // 加  	
			}

		}
		SVecTemp[i] = TempVec;
		S[i] = AlphaExp[TempVec];
	}	
	
	// BerleKamp算法	
	// 初始化
	for (i=0; i<RS_N-RS_K+1; i++)
	{
		for (j=0; j<2*(RS_N-RS_K); j++)
		{
			Sigma[i][j] = RS_N;
		}
	}
	
	Sigma[0][0] = 0;
	Delta[0] = S[0];
	L[0] = 0;
	
	// 开始叠代
	for (i=0; i<RS_N-RS_K; i++)
	{
		// dn == 0
	  	if (Delta[i] == RS_N)
	  	{
	  		for (j=0; j<2*(RS_N-RS_K); j++)
	  		{
	  		   	Sigma[i+1][j] = Sigma[i][j];
	  		} 
		 	L[i+1] = L[i];                      
	  	}
	  	else		// dn != 0
	  	{
	  		TempL = 0;
	  		for (iL=0; iL<=i; iL++)
	  		{
	  			if (L[iL]!=0)
	  			{
	  				TempL = L[iL];
	  				break;
	  			}
	  		}
	  		
	  		// L0 = L1 = ... = 0
	  		if (TempL == 0)
	  		{
	  			Sigma[i+1][0] = 0;
	  			Sigma[i+1][i+1] = Delta[i];
	  			L[i+1] = i+1;	  		
	  		}
	  		else	// Lm < L(m+1) = ... = Li 
	  		{
	  			// 找到m
		   		for (M=i; L[M]==L[i]; M--)
		   		{
		   			 ;
		   		}
		   		
		   		// 计算Sigma
		   		if (Delta[M] != RS_N)		// 零向量特殊处理
		   		{
	     			DCoef = (Delta[i] - Delta[M] + RS_N) % RS_N;
		   		
		   			TempExp = i-M;
		   		
		   			// TempSigma初始化
		   			for (j=0; j<2*(RS_N-RS_K); j++)
			   		{
			   			TempSigma[j] = RS_N;
			   		}
					
					for (j=0; j<RS_N-RS_K; j++)
					{
						TempSigmaIndex = TempExp + j;
						if (Sigma[M][j] != RS_N)
						{
							TempSigma[TempSigmaIndex] = (DCoef + Sigma[M][j]) % RS_N;
						}
					}
					
					for (j=0; j<2*(RS_N-RS_K); j++)
					{
						Sigma[i+1][j] = AlphaExp[ ( AlphaVec[ Sigma[i][j] ] ^ AlphaVec[ TempSigma[j] ] ) ];
					}
								
		   			// 计算L
		   			L[i+1] = L[i]>(i+1-L[i]) ? L[i] : (i+1-L[i]);					
				}
				else	// ！(Delta[i] != RS_N && Delta[M] != RS_N)
				{
					for (j=0; j<2*(RS_N-RS_K); j++)
					{
						Sigma[i+1][j] = Sigma[i][j];
					}
					L[i+1] = L[i];					
				}
	  		} // Lm < L(m+1) = ... = Li 		
		} // (Delta[i] == 0)
		
		if (i < RS_N-RS_K-1)
		{
			TempVec = AlphaVec[ S[i+1] ];
		
			for (j=1; j<=L[i+1]; j++)
			{
				if (Sigma[i+1][j] != RS_N && S[i+1-j] != RS_N)
				{
					TempExp = (Sigma[i+1][j] + S[i+1-j]) % RS_N;
					TempVec = TempVec ^ AlphaVec[TempExp];
				}
			}
			DeltaVecTemp[i+1] = TempVec;
			Delta[i+1] = AlphaExp[TempVec];	
		}
		 
	}	// for (i...
	
	TempExp = 0;
	// for test
	for (i=RS_N-RS_K-1; i>=0; i--)
	{
		SigmaVecTemp[i] = AlphaVec[Sigma[RS_N-RS_K][i]];
	}
	
	for (i=RS_N-RS_K-1; i>=0; i--)
	{
		if (Sigma[RS_N-RS_K][i] != RS_N)
		{
			TempExp = i;
			break;
		}
	}
	
	if (TempExp<=RS_T)		// 错误个数小于t个才能纠
	{
		ErrorNum = L[RS_N-RS_K];
		
		// 钱氏搜索,找错误位置ErrorPos
		for (i=1; i<GF_SIZE; i++)
		{
			TempVec = 0;
			for (j=1; j<RS_N-RS_K; j++)
			{
				if (Sigma[RS_N-RS_K][j] != RS_N)
				{
					TempVec = TempVec
							 ^ AlphaVec[(Sigma[RS_N-RS_K][j] + i*j) % RS_N];
				}
			}

			if (TempVec == 1)
			{	// 错误位置
				ErrorPos = RS_N - i;
				
				if ((RS_N-1-ErrorPos) < RS_K)
				{
					// Forney算法,计算错误图样
					SigmaFN[0] = 0;
					for (j=1; j<ErrorNum; j++)
					{
						TempVec1 = 0;
						if (SigmaFN[j-1] == RS_N || ErrorPos == RS_N)
						{
							TempVec1 = 0;
						}
						else
						{
							TempVec1 = AlphaVec[(SigmaFN[j-1] + ErrorPos) % RS_N];
						}
						SigmaFN[j] = AlphaExp[ TempVec1 ^ AlphaVec[ Sigma[RS_N-RS_K][j] ] ];
					}
					for (; j<RS_N-RS_K; j++)
					{
						SigmaFN[j] = RS_N;
					}
					
					NumeratorVec = 0;				// 分子
					DenominatorVec = 0;				// 分母
					for (j=0; j<ErrorNum; j++)
					{
						if (SigmaFN[j] != RS_N && S[ErrorNum-j-1] != RS_N)
						{
							NumeratorVec = NumeratorVec^AlphaVec[(SigmaFN[j] + S[ErrorNum-j-1]) % RS_N];
						}
						if (SigmaFN[j] != RS_N && ErrorPos != RS_N)
						{
							DenominatorVec = DenominatorVec^AlphaVec[(SigmaFN[j] + ErrorPos*(ErrorNum-j)) % RS_N];
						}
					}
					ErrorExp = (AlphaExp[NumeratorVec] - AlphaExp[DenominatorVec] + RS_N) % RS_N;
					// 纠错
					*(pu8RSDecOut + RS_N - 1 - ErrorPos) = *(pu8RSDecOut + RS_N - 1 - ErrorPos) ^ AlphaVec[ErrorExp];
				}
			}
		}
	}		// 能纠

}

