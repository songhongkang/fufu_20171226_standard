/* 3DES */
#ifndef __DES_H__
#define __DES_H__

enum{ENCRYPT, DECRYPT};

int Encrypt_Des(char *Out, char *In, long datalen, const char *Key, int keylen, int Type);

int BluetoothGetSNStr(char* src, int src_len, char* dest, int dest_len);

#endif

