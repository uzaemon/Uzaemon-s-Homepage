#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>

int elapsed(struct timeval *, struct timeval *);
void readfromsmtp(void);
void writetosmtp(char *);
void e2a(char *);
void a2e(char *);

int sd, rc, i, adjust;
struct timeval start, stop;
struct timezone tzpstart, tzpstop;
ssize_t count;
char buf[1024], buf2[1024];
const char CRLF[2] = {0x0d, 0x0a};
struct hostent *h;
struct sockaddr_in sa;

int main(int args, char *argv[]){

 gettimeofday(&start, &tzpstart);
 gettimeofday(&stop, &tzpstop);
 adjust = elapsed(&start, &stop);

 gettimeofday(&start, &tzpstart);
 sd = socket(PF_INET, SOCK_STREAM, 0);
 gettimeofday(&stop, &tzpstop);
 if (sd < 0) {
  perror("socket() failed.\n");
  return;
 }
 printf("socket() opened. [%d microsec]\n", elapsed(&start, &stop) - adjust);

 gettimeofday(&start, &tzpstart);
 h = gethostbyname(argv[1]);
 gettimeofday(&stop, &tzpstop);
 if (h == NULL) {
  perror("gethostbyname() failed.\n");
  return;
 }
 printf("gethostbyname() successful. [%d microsec]\n", elapsed(&start, &stop) - adjust);

 sa.sin_family = AF_INET;
 sa.sin_addr = *(struct in_addr *)h->h_addr_list[0];
 sa.sin_port = htons(25);

 gettimeofday(&start, &tzpstart);
 rc = connect(sd, (struct sockaddr *)&sa, sizeof(sa));
 gettimeofday(&stop, &tzpstop);
 if (rc < 0) {
  perror("connect() failed.\n");
  return;
 }
 printf("connection established. [%d microsec]\n", elapsed(&start, &stop) - adjust);

 readfromsmtp();
 for (i = 2 ; i < args ; args) {
  strcpy(buf, argv[i]);
  writetosmtp(buf);
  readfromsmtp();
  i++;
 }

 gettimeofday(&start, &tzpstart);
 close(sd);
 gettimeofday(&stop, &tzpstop);
 printf("socket() closed. [%d microsec]\n", elapsed(&start, &stop) - adjust);
 return;
}

int elapsed(struct timeval *first, struct timeval *second) {
  if (first->tv_usec > second->tv_usec) {
    second->tv_usec += 1000000;
    second->tv_sec--;
  }
  return( (int)(second->tv_sec - first->tv_sec) * 1000000
    + (int)(second->tv_usec - first->tv_usec));
}

void readfromsmtp() {
 gettimeofday(&start, &tzpstart);
 count = read(sd, buf, 1024);
 gettimeofday(&stop, &tzpstop);
 if (count > 0) {
  buf[count - 2] = 0x00;
  a2e(buf);
  printf("R<-%s [%d microsec]\n", buf, elapsed(&start, &stop) - adjust);
 } else {
  perror("read() failed.\n");
  return;
 }
}

void writetosmtp(char *buf) {
 strcpy(buf2, buf);
 e2a(buf2);
 strcat(buf2, CRLF);
 gettimeofday(&start, &tzpstart);
 count = write(sd, buf2, strlen(buf2));
 gettimeofday(&stop, &tzpstop);
 if (count > 0) {
  printf("S->%s [%d microsec]\n", buf, elapsed(&start, &stop) - adjust);
 } else {
  perror("write() failed.\n");
  return;
 }
}

void a2e(char *str)

{
unsigned char QEBCDIC[256] = {
  /* 00 */ 0x00, 0x01, 0x02, 0x03, 0x37, 0x2d, 0x2e, 0x2f,
  /* 08 */ 0x16, 0x05, 0x25, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
  /* 10 */ 0x10, 0x11, 0x12, 0x13, 0x3c, 0x3d, 0x32, 0x26,
  /* 18 */ 0x18, 0x19, 0x3f, 0x27, 0x1c, 0x1d, 0x1e, 0x1f,
  /* 20 */ 0x40, 0x4f, 0x7f, 0x7b, 0x5b, 0x6c, 0x50, 0x7d,
  /* 28 */ 0x4d, 0x5d, 0x5c, 0x4e, 0x6b, 0x60, 0x4b, 0x61,
  /* 30 */ 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7,
  /* 38 */ 0xf8, 0xf9, 0x7a, 0x5e, 0x4c, 0x7e, 0x6e, 0x6f,
  /* 40 */ 0x7c, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7,
  /* 48 */ 0xc8, 0xc9, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6,
  /* 50 */ 0xd7, 0xd8, 0xd9, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6,
  /* 58 */ 0xe7, 0xe8, 0xe9, 0x4a, 0xe0, 0x5a, 0x5f, 0x6d,
  /* 60 */ 0x79, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
  /* 68 */ 0x88, 0x89, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96,
  /* 70 */ 0x97, 0x98, 0x99, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6,
  /* 78 */ 0xa7, 0xa8, 0xa9, 0xc0, 0x6a, 0xd0, 0xa1, 0x07,
  /* 80 */ 0x20, 0x21, 0x22, 0x23, 0x24, 0x15, 0x06, 0x17,
  /* 88 */ 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x09, 0x0a, 0x1b,
  /* 90 */ 0x30, 0x31, 0x1a, 0x33, 0x34, 0x35, 0x36, 0x08,
  /* 98 */ 0x38, 0x39, 0x3a, 0x3b, 0x04, 0x14, 0x3e, 0xe1,
  /* a0 */ 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48,
  /* a8 */ 0x49, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57,
  /* b0 */ 0x58, 0x59, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
  /* b8 */ 0x68, 0x69, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75,
  /* c0 */ 0x76, 0x77, 0x78, 0x80, 0x8a, 0x8b, 0x8c, 0x8d,
  /* c8 */ 0x8e, 0x8f, 0x90, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e,
  /* d0 */ 0x9f, 0xa0, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
  /* d8 */ 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7,
  /* e0 */ 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf,
  /* e8 */ 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf, 0xda, 0xdb,
  /* f0 */ 0xdc, 0xdd, 0xde, 0xdf, 0xea, 0xeb, 0xec, 0xed,
  /* f8 */ 0xee, 0xef, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff
};
     while ((*str = QEBCDIC[*str++]) > 0x1F);
}

void e2a(char *str)

{
unsigned char QASCII[256] = {
  /* 00 */ 0x00, 0x01, 0x02, 0x03, 0x9c, 0x09, 0x86, 0x7f,
  /* 08 */ 0x97, 0x8d, 0x8e, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
  /* 10 */ 0x10, 0x11, 0x12, 0x13, 0x9d, 0x85, 0x08, 0x87,
  /* 18 */ 0x18, 0x19, 0x92, 0x8f, 0x1c, 0x1d, 0x1e, 0x1f,
  /* 20 */ 0x80, 0x81, 0x82, 0x83, 0x84, 0x0a, 0x17, 0x1b,
  /* 28 */ 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x05, 0x06, 0x07,
  /* 30 */ 0x90, 0x91, 0x16, 0x93, 0x94, 0x95, 0x96, 0x04,
  /* 38 */ 0x98, 0x99, 0x9a, 0x9b, 0x14, 0x15, 0x9e, 0x1a,
  /* 40 */ 0x20, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6,
  /* 48 */ 0xa7, 0xa8, 0x5b, 0x2e, 0x3c, 0x28, 0x2b, 0x21,
  /* 50 */ 0x26, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
  /* 58 */ 0xb0, 0xb1, 0x5d, 0x24, 0x2a, 0x29, 0x3b, 0x5e,
  /* 60 */ 0x2d, 0x2f, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7,
  /* 68 */ 0xb8, 0xb9, 0x7c, 0x2c, 0x25, 0x5f, 0x3e, 0x3f,
  /* 70 */ 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf, 0xc0, 0xc1,
  /* 78 */ 0xc2, 0x60, 0x3a, 0x23, 0x40, 0x27, 0x3d, 0x22,
  /* 80 */ 0xc3, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
  /* 88 */ 0x68, 0x69, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9,
  /* 90 */ 0xca, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70,
  /* 98 */ 0x71, 0x72, 0xcb, 0xcc, 0xcd, 0xce, 0xcf, 0xd0,
  /* a0 */ 0xd1, 0x7e, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
  /* a8 */ 0x79, 0x7a, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7,
  /* b0 */ 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf,
  /* b8 */ 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7,
  /* c0 */ 0x7b, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
  /* c8 */ 0x48, 0x49, 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed,
  /* d0 */ 0x7d, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50,
  /* d8 */ 0x51, 0x52, 0xee, 0xef, 0xf0, 0xf1, 0xf2, 0xf3,
  /* e0 */ 0x5c, 0x9f, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
  /* e8 */ 0x59, 0x5a, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9,
  /* f0 */ 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
  /* f8 */ 0x38, 0x39, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff,
};
     while ((*str = QASCII[*str++]) > '\0');
}
