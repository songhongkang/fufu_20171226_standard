/*
  3DES����/���ܳ���
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>

//#include "zktype.h"
//#include "printlog.h"
//#include "option.h"

//#include <sys/vfs.h>
//#include "memory.h"
#include "Des.h"

#define BOOL		int
#ifndef TRUE
#define TRUE	1
#define FALSE	0
#endif

typedef char (*PSubKey)[16][48];
static char SubKey[2][16][48];		// 16Ȧ����Կ
static BOOL Is3DES;			// 3��DES��־
static char Tmp[256], deskey[16];


// initial permutation IP
const static char IP_Table[64] = {
	58, 50, 42, 34, 26, 18, 10, 2, 60, 52, 44, 36, 28, 20, 12, 4,
	62, 54, 46, 38, 30, 22, 14, 6, 64, 56, 48, 40, 32, 24, 16, 8,
	57, 49, 41, 33, 25, 17,  9, 1, 59, 51, 43, 35, 27, 19, 11, 3,
	61, 53, 45, 37, 29, 21, 13, 5, 63, 55, 47, 39, 31, 23, 15, 7
};
// final permutation IP^-1 
const static char IPR_Table[64] = {
	40, 8, 48, 16, 56, 24, 64, 32, 39, 7, 47, 15, 55, 23, 63, 31,
	38, 6, 46, 14, 54, 22, 62, 30, 37, 5, 45, 13, 53, 21, 61, 29,
	36, 4, 44, 12, 52, 20, 60, 28, 35, 3, 43, 11, 51, 19, 59, 27,
	34, 2, 42, 10, 50, 18, 58, 26, 33, 1, 41,  9, 49, 17, 57, 25
};
// expansion operation matrix
static const char E_Table[48] = {
	32,  1,  2,  3,  4,  5,  4,  5,  6,  7,  8,  9,
	 8,  9, 10, 11, 12, 13, 12, 13, 14, 15, 16, 17,
	16, 17, 18, 19, 20, 21, 20, 21, 22, 23, 24, 25,
	24, 25, 26, 27, 28, 29, 28, 29, 30, 31, 32,  1
};
// 32-bit permutation function P used on the output of the S-boxes 
const static char P_Table[32] = {
	16, 7, 20, 21, 29, 12, 28, 17, 1,  15, 23, 26, 5,  18, 31, 10,
	2,  8, 24, 14, 32, 27, 3,  9,  19, 13, 30, 6,  22, 11, 4,  25
};
// permuted choice table (key) 
const static char PC1_Table[56] = {
	57, 49, 41, 33, 25, 17,  9,  1, 58, 50, 42, 34, 26, 18,
	10,  2, 59, 51, 43, 35, 27, 19, 11,  3, 60, 52, 44, 36,
	63, 55, 47, 39, 31, 23, 15,  7, 62, 54, 46, 38, 30, 22,
	14,  6, 61, 53, 45, 37, 29, 21, 13,  5, 28, 20, 12,  4
};
// permuted choice key (table) 
const static char PC2_Table[48] = {
	14, 17, 11, 24,  1,  5,  3, 28, 15,  6, 21, 10,
	23, 19, 12,  4, 26,  8, 16,  7, 27, 20, 13,  2,
	41, 52, 31, 37, 47, 55, 30, 40, 51, 45, 33, 48,
	44, 49, 39, 56, 34, 53, 46, 42, 50, 36, 29, 32
};
// number left rotations of pc1 
const static char LOOP_Table[16] = {
	1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1
};
// The (in)famous S-boxes 
const static char S_Box[8][4][16] = {
	{
		{14,  4, 13,  1,  2, 15, 11,  8,  3, 10,  6, 12,  5,  9,  0,  7},
		{ 0, 15,  7,  4, 14,  2, 13,  1, 10,  6, 12, 11,  9,  5,  3,  8},
		{ 4,  1, 14,  8, 13,  6,  2, 11, 15, 12,  9,  7,  3, 10,  5,  0},
		{15, 12,  8,  2,  4,  9,  1,  7,  5, 11,  3, 14, 10,  0,  6, 13}
	},
	{
		{15,  1,  8, 14,  6, 11,  3,  4,  9,  7,  2, 13, 12,  0,  5, 10},
		{ 3, 13,  4,  7, 15,  2,  8, 14, 12,  0,  1, 10,  6,  9, 11,  5},
		{ 0, 14,  7, 11, 10,  4, 13,  1,  5,  8, 12,  6,  9,  3,  2, 15},
		{13,  8, 10,  1,  3, 15,  4,  2, 11,  6,  7, 12,  0,  5, 14,  9}
	},
	{
		{10,  0,  9, 14,  6,  3, 15,  5,  1, 13, 12,  7, 11,  4,  2,  8},
		{13,  7,  0,  9,  3,  4,  6, 10,  2,  8,  5, 14, 12, 11, 15,  1},
		{13,  6,  4,  9,  8, 15,  3,  0, 11,  1,  2, 12,  5, 10, 14,  7},
		{ 1, 10, 13,  0,  6,  9,  8,  7,  4, 15, 14,  3, 11,  5,  2, 12}
 	},
	{
		{ 7, 13, 14,  3,  0,  6,  9, 10,  1,  2,  8,  5, 11, 12,  4, 15},
		{13,  8, 11,  5,  6, 15,  0,  3,  4,  7,  2, 12,  1, 10, 14,  9},
		{10,  6,  9,  0, 12, 11,  7, 13, 15,  1,  3, 14,  5,  2,  8,  4},
		{ 3, 15,  0,  6, 10,  1, 13,  8,  9,  4,  5, 11, 12,  7,  2, 14}
	},
	{
		{ 2, 12,  4,  1,  7, 10, 11,  6,  8,  5,  3, 15, 13,  0, 14,  9},
		{14, 11,  2, 12,  4,  7, 13,  1,  5,  0, 15, 10,  3,  9,  8,  6},
		{ 4,  2,  1, 11, 10, 13,  7,  8, 15,  9, 12,  5,  6,  3,  0, 14},
		{11,  8, 12,  7,  1, 14,  2, 13,  6, 15,  0,  9, 10,  4,  5,  3},
	},
	{
		{12,  1, 10, 15,  9,  2,  6,  8,  0, 13,  3,  4, 14,  7,  5, 11},
		{10, 15,  4,  2,  7, 12,  9,  5,  6,  1, 13, 14,  0, 11,  3,  8},
		{ 9, 14, 15,  5,  2,  8, 12,  3,  7,  0,  4, 10,  1, 13, 11,  6},
		{ 4,  3,  2, 12,  9,  5, 15, 10, 11, 14,  1,  7,  6,  0,  8, 13}
	},
	{
		{ 4, 11,  2, 14, 15,  0,  8, 13,  3, 12,  9,  7,  5, 10,  6,  1},
		{13,  0, 11,  7,  4,  9,  1, 10, 14,  3,  5, 12,  2, 15,  8,  6},
		{ 1,  4, 11, 13, 12,  3,  7, 14, 10, 15,  6,  8,  0,  5,  9,  2},
		{ 6, 11, 13,  8,  1,  4, 10,  7,  9,  5,  0, 15, 14,  2,  3, 12},
	},
	{
		{13,  2,  8,  4,  6, 15, 11,  1, 10,  9,  3, 14,  5,  0, 12,  7},
		{ 1, 15, 13,  8, 10,  3,  7,  4, 12,  5,  6, 11,  0, 14,  9,  2},
		{ 7, 11,  4,  1,  9, 12, 14,  2,  0,  6, 10, 13, 15,  3,  5,  8},
		{ 2,  1, 14,  7,  4, 10,  8, 13, 15, 12,  9,  0,  3,  5,  6, 11}
	}
};

static void Xor(char *InA, const char *InB, int len)
{
	int i;
	for (i=0; i<len; ++i)
		InA[i] ^= InB[i];
}

static void ByteToBit(char *Out, char *In, int bits)
{
	int i;
	for (i=0; i<bits; ++i)
		Out[i] = (In[i>>3]>>(i&7)) & 1;
}

static void BitToByte(char *Out, char *In, int bits)
{
	int i;
	memset(Out, 0, bits>>3);
	for (i=0; i<bits; ++i)
		Out[i>>3] |= In[i]<<(i&7);
}

static void Transform(char *Out, char *In, const char *Table, int len)
{
	int i;
	for (i=0; i<len; ++i)
		Tmp[i] = In[Table[i]-1];
	memcpy(Out, Tmp, len);
}

static void RotateL(char *In, int len, int loop)
{
	memcpy(Tmp, In, loop);
	memcpy(In, In+loop, len-loop);
	memcpy(In+len-loop, Tmp, loop);
}

static void SetSubKey(PSubKey pSubKey, char* Key)
{
	int i;
	static char K[64], *KL = &K[0], *KR = &K[28];

	ByteToBit(K, Key, 64);
	Transform(K, K, PC1_Table, 56);
	for (i=0; i<16; ++i)
	{
		RotateL(KL, 28, LOOP_Table[i]);
		RotateL(KR, 28, LOOP_Table[i]);
		Transform((*pSubKey)[i], K, PC2_Table, 48);
	}
}

static void SetKey(char* Key, int len)
{
	memset(deskey, 0, 16);
	memcpy(deskey, Key, len>16?16:len);
	
	SetSubKey(&SubKey[0], &deskey[0]);
	if (len>8)
	{
		SetSubKey(&SubKey[1], &deskey[8]);
		Is3DES = TRUE;
	}
	else
		Is3DES = FALSE;
}

static void S_func(char* Out, char* In)
{
	int i, j, k;
	
	for (i=0; i<8; i++)
	{
		j = (In[0]<<1) + In[5];
		k = (In[1]<<3) + (In[2]<<2) + (In[3]<<1) + In[4];
		ByteToBit(Out,(char *) &S_Box[i][j][k], 4);
		In+=6;
		Out+=4;
	}
}

static void F_func(char* In, char* Ki)
{
	static char MR[48];
	Transform(MR, In, E_Table, 48);
	Xor(MR, Ki, 48);
	S_func(In, MR);
	Transform(In, In, P_Table, 32);
}

static void DES(char* Out, char* In, PSubKey pSubKey, int Type)
{
	int i;
	static char M[64], tmp[32], *Li=&M[0], *Ri=&M[32];

	ByteToBit(M, In, 64);
	Transform(M, M, IP_Table, 64);

	if (Type==ENCRYPT)
	{
		for (i=0; i<16; ++i)
		{
			memcpy(tmp, Ri, 32);
			F_func(Ri, (*pSubKey)[i]);
			Xor(Ri, Li, 32);
			memcpy(Li, tmp, 32);
		}
	}
	else
	{
		for (i=15; i>=0; --i)
		{
			memcpy(tmp, Li, 32);
			F_func(Li, (*pSubKey)[i]);
			Xor(Li, Ri, 32);
			memcpy(Ri, tmp, 32);
		}
	}

	Transform(M, M, IPR_Table, 64);
	BitToByte(Out, M, 64);
}

int Encrypt_Des(char *Out, char *In, long datalen, const char *Key, int keylen, int Type)
{
	long i;

	if (!(Out && In && Key && (datalen=(datalen+7)&0xfffffff8))) 
		return 0;

	SetKey((char *)Key, keylen);
	if (!Is3DES)
	{
		// 1��DES
		for (i=0; i<(datalen>>3); i++)
		{
			DES(Out, In, &SubKey[0], Type);
			Out+=8;
			In+=8;
		}
	}
	else
	{
		// 3��DES ����:��(key0)-��(key1)-��(key0) ����::��(key0)-��(key1)-��(key0)
		for (i=0; i<(datalen>>3); i++)
		{
			DES(Out, In,  &SubKey[0], Type);
			DES(Out, Out, &SubKey[1], !Type);
			DES(Out, Out, &SubKey[0], Type);
			Out+=8;
			In+=8;
		}
	}
	return 1;
}



int BluetoothGetSNStr(char* src, int src_len, char* dest, int dest_len)
{
    char decrypt_buf[19] = {0};
    char key[24] = {0xa5, 0x4f, 0x22, 0x42, 0x24, 0x56, 0x13, 0x25, 0x52, 0x24, 0x11, 0x45, 0x25, 0x25, 0x53, 0x82,
        0x22, 0x32, 0x43, 0x56, 0x11, 0x22, 0x33, 0x55};
    if (src_len != 19 || dest_len != 19)
    {
        return -1;
    }
    memcpy(decrypt_buf, src, 3);
    
    (void)Encrypt_Des(decrypt_buf+ 3, src + 3, 16, key, 24, DECRYPT);
    memcpy(dest, decrypt_buf, 19);
    
    return 0;
}
