
user/_getreadcount:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

// Reference: https://cs631.cs.usfca.edu/guides/adding-a-syscall-to-xv6

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("Current read count is %d\n", getreadcount());
   8:	00000097          	auipc	ra,0x0
   c:	35c080e7          	jalr	860(ra) # 364 <getreadcount>
  10:	85aa                	mv	a1,a0
  12:	00000517          	auipc	a0,0x0
  16:	7de50513          	addi	a0,a0,2014 # 7f0 <malloc+0xe6>
  1a:	00000097          	auipc	ra,0x0
  1e:	632080e7          	jalr	1586(ra) # 64c <printf>
    exit(0);
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	298080e7          	jalr	664(ra) # 2bc <exit>

000000000000002c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  2c:	1141                	addi	sp,sp,-16
  2e:	e406                	sd	ra,8(sp)
  30:	e022                	sd	s0,0(sp)
  32:	0800                	addi	s0,sp,16
  extern int main();
  main();
  34:	00000097          	auipc	ra,0x0
  38:	fcc080e7          	jalr	-52(ra) # 0 <main>
  exit(0);
  3c:	4501                	li	a0,0
  3e:	00000097          	auipc	ra,0x0
  42:	27e080e7          	jalr	638(ra) # 2bc <exit>

0000000000000046 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  46:	1141                	addi	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4c:	87aa                	mv	a5,a0
  4e:	0585                	addi	a1,a1,1
  50:	0785                	addi	a5,a5,1
  52:	fff5c703          	lbu	a4,-1(a1)
  56:	fee78fa3          	sb	a4,-1(a5)
  5a:	fb75                	bnez	a4,4e <strcpy+0x8>
    ;
  return os;
}
  5c:	6422                	ld	s0,8(sp)
  5e:	0141                	addi	sp,sp,16
  60:	8082                	ret

0000000000000062 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  62:	1141                	addi	sp,sp,-16
  64:	e422                	sd	s0,8(sp)
  66:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  68:	00054783          	lbu	a5,0(a0)
  6c:	cb91                	beqz	a5,80 <strcmp+0x1e>
  6e:	0005c703          	lbu	a4,0(a1)
  72:	00f71763          	bne	a4,a5,80 <strcmp+0x1e>
    p++, q++;
  76:	0505                	addi	a0,a0,1
  78:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	fbe5                	bnez	a5,6e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  80:	0005c503          	lbu	a0,0(a1)
}
  84:	40a7853b          	subw	a0,a5,a0
  88:	6422                	ld	s0,8(sp)
  8a:	0141                	addi	sp,sp,16
  8c:	8082                	ret

000000000000008e <strlen>:

uint
strlen(const char *s)
{
  8e:	1141                	addi	sp,sp,-16
  90:	e422                	sd	s0,8(sp)
  92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  94:	00054783          	lbu	a5,0(a0)
  98:	cf91                	beqz	a5,b4 <strlen+0x26>
  9a:	0505                	addi	a0,a0,1
  9c:	87aa                	mv	a5,a0
  9e:	4685                	li	a3,1
  a0:	9e89                	subw	a3,a3,a0
  a2:	00f6853b          	addw	a0,a3,a5
  a6:	0785                	addi	a5,a5,1
  a8:	fff7c703          	lbu	a4,-1(a5)
  ac:	fb7d                	bnez	a4,a2 <strlen+0x14>
    ;
  return n;
}
  ae:	6422                	ld	s0,8(sp)
  b0:	0141                	addi	sp,sp,16
  b2:	8082                	ret
  for(n = 0; s[n]; n++)
  b4:	4501                	li	a0,0
  b6:	bfe5                	j	ae <strlen+0x20>

00000000000000b8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b8:	1141                	addi	sp,sp,-16
  ba:	e422                	sd	s0,8(sp)
  bc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  be:	ce09                	beqz	a2,d8 <memset+0x20>
  c0:	87aa                	mv	a5,a0
  c2:	fff6071b          	addiw	a4,a2,-1
  c6:	1702                	slli	a4,a4,0x20
  c8:	9301                	srli	a4,a4,0x20
  ca:	0705                	addi	a4,a4,1
  cc:	972a                	add	a4,a4,a0
    cdst[i] = c;
  ce:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  d2:	0785                	addi	a5,a5,1
  d4:	fee79de3          	bne	a5,a4,ce <memset+0x16>
  }
  return dst;
}
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	addi	sp,sp,16
  dc:	8082                	ret

00000000000000de <strchr>:

char*
strchr(const char *s, char c)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e422                	sd	s0,8(sp)
  e2:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e4:	00054783          	lbu	a5,0(a0)
  e8:	cb99                	beqz	a5,fe <strchr+0x20>
    if(*s == c)
  ea:	00f58763          	beq	a1,a5,f8 <strchr+0x1a>
  for(; *s; s++)
  ee:	0505                	addi	a0,a0,1
  f0:	00054783          	lbu	a5,0(a0)
  f4:	fbfd                	bnez	a5,ea <strchr+0xc>
      return (char*)s;
  return 0;
  f6:	4501                	li	a0,0
}
  f8:	6422                	ld	s0,8(sp)
  fa:	0141                	addi	sp,sp,16
  fc:	8082                	ret
  return 0;
  fe:	4501                	li	a0,0
 100:	bfe5                	j	f8 <strchr+0x1a>

0000000000000102 <gets>:

char*
gets(char *buf, int max)
{
 102:	711d                	addi	sp,sp,-96
 104:	ec86                	sd	ra,88(sp)
 106:	e8a2                	sd	s0,80(sp)
 108:	e4a6                	sd	s1,72(sp)
 10a:	e0ca                	sd	s2,64(sp)
 10c:	fc4e                	sd	s3,56(sp)
 10e:	f852                	sd	s4,48(sp)
 110:	f456                	sd	s5,40(sp)
 112:	f05a                	sd	s6,32(sp)
 114:	ec5e                	sd	s7,24(sp)
 116:	1080                	addi	s0,sp,96
 118:	8baa                	mv	s7,a0
 11a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 11c:	892a                	mv	s2,a0
 11e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 120:	4aa9                	li	s5,10
 122:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 124:	89a6                	mv	s3,s1
 126:	2485                	addiw	s1,s1,1
 128:	0344d863          	bge	s1,s4,158 <gets+0x56>
    cc = read(0, &c, 1);
 12c:	4605                	li	a2,1
 12e:	faf40593          	addi	a1,s0,-81
 132:	4501                	li	a0,0
 134:	00000097          	auipc	ra,0x0
 138:	1a0080e7          	jalr	416(ra) # 2d4 <read>
    if(cc < 1)
 13c:	00a05e63          	blez	a0,158 <gets+0x56>
    buf[i++] = c;
 140:	faf44783          	lbu	a5,-81(s0)
 144:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 148:	01578763          	beq	a5,s5,156 <gets+0x54>
 14c:	0905                	addi	s2,s2,1
 14e:	fd679be3          	bne	a5,s6,124 <gets+0x22>
  for(i=0; i+1 < max; ){
 152:	89a6                	mv	s3,s1
 154:	a011                	j	158 <gets+0x56>
 156:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 158:	99de                	add	s3,s3,s7
 15a:	00098023          	sb	zero,0(s3)
  return buf;
}
 15e:	855e                	mv	a0,s7
 160:	60e6                	ld	ra,88(sp)
 162:	6446                	ld	s0,80(sp)
 164:	64a6                	ld	s1,72(sp)
 166:	6906                	ld	s2,64(sp)
 168:	79e2                	ld	s3,56(sp)
 16a:	7a42                	ld	s4,48(sp)
 16c:	7aa2                	ld	s5,40(sp)
 16e:	7b02                	ld	s6,32(sp)
 170:	6be2                	ld	s7,24(sp)
 172:	6125                	addi	sp,sp,96
 174:	8082                	ret

0000000000000176 <stat>:

int
stat(const char *n, struct stat *st)
{
 176:	1101                	addi	sp,sp,-32
 178:	ec06                	sd	ra,24(sp)
 17a:	e822                	sd	s0,16(sp)
 17c:	e426                	sd	s1,8(sp)
 17e:	e04a                	sd	s2,0(sp)
 180:	1000                	addi	s0,sp,32
 182:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 184:	4581                	li	a1,0
 186:	00000097          	auipc	ra,0x0
 18a:	176080e7          	jalr	374(ra) # 2fc <open>
  if(fd < 0)
 18e:	02054563          	bltz	a0,1b8 <stat+0x42>
 192:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 194:	85ca                	mv	a1,s2
 196:	00000097          	auipc	ra,0x0
 19a:	17e080e7          	jalr	382(ra) # 314 <fstat>
 19e:	892a                	mv	s2,a0
  close(fd);
 1a0:	8526                	mv	a0,s1
 1a2:	00000097          	auipc	ra,0x0
 1a6:	142080e7          	jalr	322(ra) # 2e4 <close>
  return r;
}
 1aa:	854a                	mv	a0,s2
 1ac:	60e2                	ld	ra,24(sp)
 1ae:	6442                	ld	s0,16(sp)
 1b0:	64a2                	ld	s1,8(sp)
 1b2:	6902                	ld	s2,0(sp)
 1b4:	6105                	addi	sp,sp,32
 1b6:	8082                	ret
    return -1;
 1b8:	597d                	li	s2,-1
 1ba:	bfc5                	j	1aa <stat+0x34>

00000000000001bc <atoi>:

int
atoi(const char *s)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e422                	sd	s0,8(sp)
 1c0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c2:	00054603          	lbu	a2,0(a0)
 1c6:	fd06079b          	addiw	a5,a2,-48
 1ca:	0ff7f793          	andi	a5,a5,255
 1ce:	4725                	li	a4,9
 1d0:	02f76963          	bltu	a4,a5,202 <atoi+0x46>
 1d4:	86aa                	mv	a3,a0
  n = 0;
 1d6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1d8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1da:	0685                	addi	a3,a3,1
 1dc:	0025179b          	slliw	a5,a0,0x2
 1e0:	9fa9                	addw	a5,a5,a0
 1e2:	0017979b          	slliw	a5,a5,0x1
 1e6:	9fb1                	addw	a5,a5,a2
 1e8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ec:	0006c603          	lbu	a2,0(a3)
 1f0:	fd06071b          	addiw	a4,a2,-48
 1f4:	0ff77713          	andi	a4,a4,255
 1f8:	fee5f1e3          	bgeu	a1,a4,1da <atoi+0x1e>
  return n;
}
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret
  n = 0;
 202:	4501                	li	a0,0
 204:	bfe5                	j	1fc <atoi+0x40>

0000000000000206 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 206:	1141                	addi	sp,sp,-16
 208:	e422                	sd	s0,8(sp)
 20a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 20c:	02b57663          	bgeu	a0,a1,238 <memmove+0x32>
    while(n-- > 0)
 210:	02c05163          	blez	a2,232 <memmove+0x2c>
 214:	fff6079b          	addiw	a5,a2,-1
 218:	1782                	slli	a5,a5,0x20
 21a:	9381                	srli	a5,a5,0x20
 21c:	0785                	addi	a5,a5,1
 21e:	97aa                	add	a5,a5,a0
  dst = vdst;
 220:	872a                	mv	a4,a0
      *dst++ = *src++;
 222:	0585                	addi	a1,a1,1
 224:	0705                	addi	a4,a4,1
 226:	fff5c683          	lbu	a3,-1(a1)
 22a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 22e:	fee79ae3          	bne	a5,a4,222 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret
    dst += n;
 238:	00c50733          	add	a4,a0,a2
    src += n;
 23c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 23e:	fec05ae3          	blez	a2,232 <memmove+0x2c>
 242:	fff6079b          	addiw	a5,a2,-1
 246:	1782                	slli	a5,a5,0x20
 248:	9381                	srli	a5,a5,0x20
 24a:	fff7c793          	not	a5,a5
 24e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 250:	15fd                	addi	a1,a1,-1
 252:	177d                	addi	a4,a4,-1
 254:	0005c683          	lbu	a3,0(a1)
 258:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 25c:	fee79ae3          	bne	a5,a4,250 <memmove+0x4a>
 260:	bfc9                	j	232 <memmove+0x2c>

0000000000000262 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 268:	ca05                	beqz	a2,298 <memcmp+0x36>
 26a:	fff6069b          	addiw	a3,a2,-1
 26e:	1682                	slli	a3,a3,0x20
 270:	9281                	srli	a3,a3,0x20
 272:	0685                	addi	a3,a3,1
 274:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 276:	00054783          	lbu	a5,0(a0)
 27a:	0005c703          	lbu	a4,0(a1)
 27e:	00e79863          	bne	a5,a4,28e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 282:	0505                	addi	a0,a0,1
    p2++;
 284:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 286:	fed518e3          	bne	a0,a3,276 <memcmp+0x14>
  }
  return 0;
 28a:	4501                	li	a0,0
 28c:	a019                	j	292 <memcmp+0x30>
      return *p1 - *p2;
 28e:	40e7853b          	subw	a0,a5,a4
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret
  return 0;
 298:	4501                	li	a0,0
 29a:	bfe5                	j	292 <memcmp+0x30>

000000000000029c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 29c:	1141                	addi	sp,sp,-16
 29e:	e406                	sd	ra,8(sp)
 2a0:	e022                	sd	s0,0(sp)
 2a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a4:	00000097          	auipc	ra,0x0
 2a8:	f62080e7          	jalr	-158(ra) # 206 <memmove>
}
 2ac:	60a2                	ld	ra,8(sp)
 2ae:	6402                	ld	s0,0(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret

00000000000002b4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2b4:	4885                	li	a7,1
 ecall
 2b6:	00000073          	ecall
 ret
 2ba:	8082                	ret

00000000000002bc <exit>:
.global exit
exit:
 li a7, SYS_exit
 2bc:	4889                	li	a7,2
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2c4:	488d                	li	a7,3
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2cc:	4891                	li	a7,4
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <read>:
.global read
read:
 li a7, SYS_read
 2d4:	4895                	li	a7,5
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <write>:
.global write
write:
 li a7, SYS_write
 2dc:	48c1                	li	a7,16
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <close>:
.global close
close:
 li a7, SYS_close
 2e4:	48d5                	li	a7,21
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <kill>:
.global kill
kill:
 li a7, SYS_kill
 2ec:	4899                	li	a7,6
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2f4:	489d                	li	a7,7
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <open>:
.global open
open:
 li a7, SYS_open
 2fc:	48bd                	li	a7,15
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 304:	48c5                	li	a7,17
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 30c:	48c9                	li	a7,18
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 314:	48a1                	li	a7,8
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <link>:
.global link
link:
 li a7, SYS_link
 31c:	48cd                	li	a7,19
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 324:	48d1                	li	a7,20
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 32c:	48a5                	li	a7,9
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <dup>:
.global dup
dup:
 li a7, SYS_dup
 334:	48a9                	li	a7,10
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 33c:	48ad                	li	a7,11
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 344:	48b1                	li	a7,12
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 34c:	48b5                	li	a7,13
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 354:	48b9                	li	a7,14
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 35c:	48d9                	li	a7,22
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 364:	48dd                	li	a7,23
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 36c:	48e1                	li	a7,24
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 374:	1101                	addi	sp,sp,-32
 376:	ec06                	sd	ra,24(sp)
 378:	e822                	sd	s0,16(sp)
 37a:	1000                	addi	s0,sp,32
 37c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 380:	4605                	li	a2,1
 382:	fef40593          	addi	a1,s0,-17
 386:	00000097          	auipc	ra,0x0
 38a:	f56080e7          	jalr	-170(ra) # 2dc <write>
}
 38e:	60e2                	ld	ra,24(sp)
 390:	6442                	ld	s0,16(sp)
 392:	6105                	addi	sp,sp,32
 394:	8082                	ret

0000000000000396 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 396:	7139                	addi	sp,sp,-64
 398:	fc06                	sd	ra,56(sp)
 39a:	f822                	sd	s0,48(sp)
 39c:	f426                	sd	s1,40(sp)
 39e:	f04a                	sd	s2,32(sp)
 3a0:	ec4e                	sd	s3,24(sp)
 3a2:	0080                	addi	s0,sp,64
 3a4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3a6:	c299                	beqz	a3,3ac <printint+0x16>
 3a8:	0805c863          	bltz	a1,438 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ac:	2581                	sext.w	a1,a1
  neg = 0;
 3ae:	4881                	li	a7,0
 3b0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3b4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3b6:	2601                	sext.w	a2,a2
 3b8:	00000517          	auipc	a0,0x0
 3bc:	46050513          	addi	a0,a0,1120 # 818 <digits>
 3c0:	883a                	mv	a6,a4
 3c2:	2705                	addiw	a4,a4,1
 3c4:	02c5f7bb          	remuw	a5,a1,a2
 3c8:	1782                	slli	a5,a5,0x20
 3ca:	9381                	srli	a5,a5,0x20
 3cc:	97aa                	add	a5,a5,a0
 3ce:	0007c783          	lbu	a5,0(a5)
 3d2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3d6:	0005879b          	sext.w	a5,a1
 3da:	02c5d5bb          	divuw	a1,a1,a2
 3de:	0685                	addi	a3,a3,1
 3e0:	fec7f0e3          	bgeu	a5,a2,3c0 <printint+0x2a>
  if(neg)
 3e4:	00088b63          	beqz	a7,3fa <printint+0x64>
    buf[i++] = '-';
 3e8:	fd040793          	addi	a5,s0,-48
 3ec:	973e                	add	a4,a4,a5
 3ee:	02d00793          	li	a5,45
 3f2:	fef70823          	sb	a5,-16(a4)
 3f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3fa:	02e05863          	blez	a4,42a <printint+0x94>
 3fe:	fc040793          	addi	a5,s0,-64
 402:	00e78933          	add	s2,a5,a4
 406:	fff78993          	addi	s3,a5,-1
 40a:	99ba                	add	s3,s3,a4
 40c:	377d                	addiw	a4,a4,-1
 40e:	1702                	slli	a4,a4,0x20
 410:	9301                	srli	a4,a4,0x20
 412:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 416:	fff94583          	lbu	a1,-1(s2)
 41a:	8526                	mv	a0,s1
 41c:	00000097          	auipc	ra,0x0
 420:	f58080e7          	jalr	-168(ra) # 374 <putc>
  while(--i >= 0)
 424:	197d                	addi	s2,s2,-1
 426:	ff3918e3          	bne	s2,s3,416 <printint+0x80>
}
 42a:	70e2                	ld	ra,56(sp)
 42c:	7442                	ld	s0,48(sp)
 42e:	74a2                	ld	s1,40(sp)
 430:	7902                	ld	s2,32(sp)
 432:	69e2                	ld	s3,24(sp)
 434:	6121                	addi	sp,sp,64
 436:	8082                	ret
    x = -xx;
 438:	40b005bb          	negw	a1,a1
    neg = 1;
 43c:	4885                	li	a7,1
    x = -xx;
 43e:	bf8d                	j	3b0 <printint+0x1a>

0000000000000440 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 440:	7119                	addi	sp,sp,-128
 442:	fc86                	sd	ra,120(sp)
 444:	f8a2                	sd	s0,112(sp)
 446:	f4a6                	sd	s1,104(sp)
 448:	f0ca                	sd	s2,96(sp)
 44a:	ecce                	sd	s3,88(sp)
 44c:	e8d2                	sd	s4,80(sp)
 44e:	e4d6                	sd	s5,72(sp)
 450:	e0da                	sd	s6,64(sp)
 452:	fc5e                	sd	s7,56(sp)
 454:	f862                	sd	s8,48(sp)
 456:	f466                	sd	s9,40(sp)
 458:	f06a                	sd	s10,32(sp)
 45a:	ec6e                	sd	s11,24(sp)
 45c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 45e:	0005c903          	lbu	s2,0(a1)
 462:	18090f63          	beqz	s2,600 <vprintf+0x1c0>
 466:	8aaa                	mv	s5,a0
 468:	8b32                	mv	s6,a2
 46a:	00158493          	addi	s1,a1,1
  state = 0;
 46e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 470:	02500a13          	li	s4,37
      if(c == 'd'){
 474:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 478:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 47c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 480:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 484:	00000b97          	auipc	s7,0x0
 488:	394b8b93          	addi	s7,s7,916 # 818 <digits>
 48c:	a839                	j	4aa <vprintf+0x6a>
        putc(fd, c);
 48e:	85ca                	mv	a1,s2
 490:	8556                	mv	a0,s5
 492:	00000097          	auipc	ra,0x0
 496:	ee2080e7          	jalr	-286(ra) # 374 <putc>
 49a:	a019                	j	4a0 <vprintf+0x60>
    } else if(state == '%'){
 49c:	01498f63          	beq	s3,s4,4ba <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4a0:	0485                	addi	s1,s1,1
 4a2:	fff4c903          	lbu	s2,-1(s1)
 4a6:	14090d63          	beqz	s2,600 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4aa:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4ae:	fe0997e3          	bnez	s3,49c <vprintf+0x5c>
      if(c == '%'){
 4b2:	fd479ee3          	bne	a5,s4,48e <vprintf+0x4e>
        state = '%';
 4b6:	89be                	mv	s3,a5
 4b8:	b7e5                	j	4a0 <vprintf+0x60>
      if(c == 'd'){
 4ba:	05878063          	beq	a5,s8,4fa <vprintf+0xba>
      } else if(c == 'l') {
 4be:	05978c63          	beq	a5,s9,516 <vprintf+0xd6>
      } else if(c == 'x') {
 4c2:	07a78863          	beq	a5,s10,532 <vprintf+0xf2>
      } else if(c == 'p') {
 4c6:	09b78463          	beq	a5,s11,54e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4ca:	07300713          	li	a4,115
 4ce:	0ce78663          	beq	a5,a4,59a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4d2:	06300713          	li	a4,99
 4d6:	0ee78e63          	beq	a5,a4,5d2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4da:	11478863          	beq	a5,s4,5ea <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4de:	85d2                	mv	a1,s4
 4e0:	8556                	mv	a0,s5
 4e2:	00000097          	auipc	ra,0x0
 4e6:	e92080e7          	jalr	-366(ra) # 374 <putc>
        putc(fd, c);
 4ea:	85ca                	mv	a1,s2
 4ec:	8556                	mv	a0,s5
 4ee:	00000097          	auipc	ra,0x0
 4f2:	e86080e7          	jalr	-378(ra) # 374 <putc>
      }
      state = 0;
 4f6:	4981                	li	s3,0
 4f8:	b765                	j	4a0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4fa:	008b0913          	addi	s2,s6,8
 4fe:	4685                	li	a3,1
 500:	4629                	li	a2,10
 502:	000b2583          	lw	a1,0(s6)
 506:	8556                	mv	a0,s5
 508:	00000097          	auipc	ra,0x0
 50c:	e8e080e7          	jalr	-370(ra) # 396 <printint>
 510:	8b4a                	mv	s6,s2
      state = 0;
 512:	4981                	li	s3,0
 514:	b771                	j	4a0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 516:	008b0913          	addi	s2,s6,8
 51a:	4681                	li	a3,0
 51c:	4629                	li	a2,10
 51e:	000b2583          	lw	a1,0(s6)
 522:	8556                	mv	a0,s5
 524:	00000097          	auipc	ra,0x0
 528:	e72080e7          	jalr	-398(ra) # 396 <printint>
 52c:	8b4a                	mv	s6,s2
      state = 0;
 52e:	4981                	li	s3,0
 530:	bf85                	j	4a0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 532:	008b0913          	addi	s2,s6,8
 536:	4681                	li	a3,0
 538:	4641                	li	a2,16
 53a:	000b2583          	lw	a1,0(s6)
 53e:	8556                	mv	a0,s5
 540:	00000097          	auipc	ra,0x0
 544:	e56080e7          	jalr	-426(ra) # 396 <printint>
 548:	8b4a                	mv	s6,s2
      state = 0;
 54a:	4981                	li	s3,0
 54c:	bf91                	j	4a0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 54e:	008b0793          	addi	a5,s6,8
 552:	f8f43423          	sd	a5,-120(s0)
 556:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 55a:	03000593          	li	a1,48
 55e:	8556                	mv	a0,s5
 560:	00000097          	auipc	ra,0x0
 564:	e14080e7          	jalr	-492(ra) # 374 <putc>
  putc(fd, 'x');
 568:	85ea                	mv	a1,s10
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	e08080e7          	jalr	-504(ra) # 374 <putc>
 574:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 576:	03c9d793          	srli	a5,s3,0x3c
 57a:	97de                	add	a5,a5,s7
 57c:	0007c583          	lbu	a1,0(a5)
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	df2080e7          	jalr	-526(ra) # 374 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 58a:	0992                	slli	s3,s3,0x4
 58c:	397d                	addiw	s2,s2,-1
 58e:	fe0914e3          	bnez	s2,576 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 592:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 596:	4981                	li	s3,0
 598:	b721                	j	4a0 <vprintf+0x60>
        s = va_arg(ap, char*);
 59a:	008b0993          	addi	s3,s6,8
 59e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5a2:	02090163          	beqz	s2,5c4 <vprintf+0x184>
        while(*s != 0){
 5a6:	00094583          	lbu	a1,0(s2)
 5aa:	c9a1                	beqz	a1,5fa <vprintf+0x1ba>
          putc(fd, *s);
 5ac:	8556                	mv	a0,s5
 5ae:	00000097          	auipc	ra,0x0
 5b2:	dc6080e7          	jalr	-570(ra) # 374 <putc>
          s++;
 5b6:	0905                	addi	s2,s2,1
        while(*s != 0){
 5b8:	00094583          	lbu	a1,0(s2)
 5bc:	f9e5                	bnez	a1,5ac <vprintf+0x16c>
        s = va_arg(ap, char*);
 5be:	8b4e                	mv	s6,s3
      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	bdf9                	j	4a0 <vprintf+0x60>
          s = "(null)";
 5c4:	00000917          	auipc	s2,0x0
 5c8:	24c90913          	addi	s2,s2,588 # 810 <malloc+0x106>
        while(*s != 0){
 5cc:	02800593          	li	a1,40
 5d0:	bff1                	j	5ac <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5d2:	008b0913          	addi	s2,s6,8
 5d6:	000b4583          	lbu	a1,0(s6)
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	d98080e7          	jalr	-616(ra) # 374 <putc>
 5e4:	8b4a                	mv	s6,s2
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	bd65                	j	4a0 <vprintf+0x60>
        putc(fd, c);
 5ea:	85d2                	mv	a1,s4
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	d86080e7          	jalr	-634(ra) # 374 <putc>
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	b565                	j	4a0 <vprintf+0x60>
        s = va_arg(ap, char*);
 5fa:	8b4e                	mv	s6,s3
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b54d                	j	4a0 <vprintf+0x60>
    }
  }
}
 600:	70e6                	ld	ra,120(sp)
 602:	7446                	ld	s0,112(sp)
 604:	74a6                	ld	s1,104(sp)
 606:	7906                	ld	s2,96(sp)
 608:	69e6                	ld	s3,88(sp)
 60a:	6a46                	ld	s4,80(sp)
 60c:	6aa6                	ld	s5,72(sp)
 60e:	6b06                	ld	s6,64(sp)
 610:	7be2                	ld	s7,56(sp)
 612:	7c42                	ld	s8,48(sp)
 614:	7ca2                	ld	s9,40(sp)
 616:	7d02                	ld	s10,32(sp)
 618:	6de2                	ld	s11,24(sp)
 61a:	6109                	addi	sp,sp,128
 61c:	8082                	ret

000000000000061e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 61e:	715d                	addi	sp,sp,-80
 620:	ec06                	sd	ra,24(sp)
 622:	e822                	sd	s0,16(sp)
 624:	1000                	addi	s0,sp,32
 626:	e010                	sd	a2,0(s0)
 628:	e414                	sd	a3,8(s0)
 62a:	e818                	sd	a4,16(s0)
 62c:	ec1c                	sd	a5,24(s0)
 62e:	03043023          	sd	a6,32(s0)
 632:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 636:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 63a:	8622                	mv	a2,s0
 63c:	00000097          	auipc	ra,0x0
 640:	e04080e7          	jalr	-508(ra) # 440 <vprintf>
}
 644:	60e2                	ld	ra,24(sp)
 646:	6442                	ld	s0,16(sp)
 648:	6161                	addi	sp,sp,80
 64a:	8082                	ret

000000000000064c <printf>:

void
printf(const char *fmt, ...)
{
 64c:	711d                	addi	sp,sp,-96
 64e:	ec06                	sd	ra,24(sp)
 650:	e822                	sd	s0,16(sp)
 652:	1000                	addi	s0,sp,32
 654:	e40c                	sd	a1,8(s0)
 656:	e810                	sd	a2,16(s0)
 658:	ec14                	sd	a3,24(s0)
 65a:	f018                	sd	a4,32(s0)
 65c:	f41c                	sd	a5,40(s0)
 65e:	03043823          	sd	a6,48(s0)
 662:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 666:	00840613          	addi	a2,s0,8
 66a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 66e:	85aa                	mv	a1,a0
 670:	4505                	li	a0,1
 672:	00000097          	auipc	ra,0x0
 676:	dce080e7          	jalr	-562(ra) # 440 <vprintf>
}
 67a:	60e2                	ld	ra,24(sp)
 67c:	6442                	ld	s0,16(sp)
 67e:	6125                	addi	sp,sp,96
 680:	8082                	ret

0000000000000682 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 682:	1141                	addi	sp,sp,-16
 684:	e422                	sd	s0,8(sp)
 686:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 688:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68c:	00001797          	auipc	a5,0x1
 690:	9747b783          	ld	a5,-1676(a5) # 1000 <freep>
 694:	a805                	j	6c4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 696:	4618                	lw	a4,8(a2)
 698:	9db9                	addw	a1,a1,a4
 69a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 69e:	6398                	ld	a4,0(a5)
 6a0:	6318                	ld	a4,0(a4)
 6a2:	fee53823          	sd	a4,-16(a0)
 6a6:	a091                	j	6ea <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6a8:	ff852703          	lw	a4,-8(a0)
 6ac:	9e39                	addw	a2,a2,a4
 6ae:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6b0:	ff053703          	ld	a4,-16(a0)
 6b4:	e398                	sd	a4,0(a5)
 6b6:	a099                	j	6fc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b8:	6398                	ld	a4,0(a5)
 6ba:	00e7e463          	bltu	a5,a4,6c2 <free+0x40>
 6be:	00e6ea63          	bltu	a3,a4,6d2 <free+0x50>
{
 6c2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c4:	fed7fae3          	bgeu	a5,a3,6b8 <free+0x36>
 6c8:	6398                	ld	a4,0(a5)
 6ca:	00e6e463          	bltu	a3,a4,6d2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ce:	fee7eae3          	bltu	a5,a4,6c2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6d2:	ff852583          	lw	a1,-8(a0)
 6d6:	6390                	ld	a2,0(a5)
 6d8:	02059713          	slli	a4,a1,0x20
 6dc:	9301                	srli	a4,a4,0x20
 6de:	0712                	slli	a4,a4,0x4
 6e0:	9736                	add	a4,a4,a3
 6e2:	fae60ae3          	beq	a2,a4,696 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6e6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6ea:	4790                	lw	a2,8(a5)
 6ec:	02061713          	slli	a4,a2,0x20
 6f0:	9301                	srli	a4,a4,0x20
 6f2:	0712                	slli	a4,a4,0x4
 6f4:	973e                	add	a4,a4,a5
 6f6:	fae689e3          	beq	a3,a4,6a8 <free+0x26>
  } else
    p->s.ptr = bp;
 6fa:	e394                	sd	a3,0(a5)
  freep = p;
 6fc:	00001717          	auipc	a4,0x1
 700:	90f73223          	sd	a5,-1788(a4) # 1000 <freep>
}
 704:	6422                	ld	s0,8(sp)
 706:	0141                	addi	sp,sp,16
 708:	8082                	ret

000000000000070a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 70a:	7139                	addi	sp,sp,-64
 70c:	fc06                	sd	ra,56(sp)
 70e:	f822                	sd	s0,48(sp)
 710:	f426                	sd	s1,40(sp)
 712:	f04a                	sd	s2,32(sp)
 714:	ec4e                	sd	s3,24(sp)
 716:	e852                	sd	s4,16(sp)
 718:	e456                	sd	s5,8(sp)
 71a:	e05a                	sd	s6,0(sp)
 71c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 71e:	02051493          	slli	s1,a0,0x20
 722:	9081                	srli	s1,s1,0x20
 724:	04bd                	addi	s1,s1,15
 726:	8091                	srli	s1,s1,0x4
 728:	0014899b          	addiw	s3,s1,1
 72c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 72e:	00001517          	auipc	a0,0x1
 732:	8d253503          	ld	a0,-1838(a0) # 1000 <freep>
 736:	c515                	beqz	a0,762 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 738:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 73a:	4798                	lw	a4,8(a5)
 73c:	02977f63          	bgeu	a4,s1,77a <malloc+0x70>
 740:	8a4e                	mv	s4,s3
 742:	0009871b          	sext.w	a4,s3
 746:	6685                	lui	a3,0x1
 748:	00d77363          	bgeu	a4,a3,74e <malloc+0x44>
 74c:	6a05                	lui	s4,0x1
 74e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 752:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 756:	00001917          	auipc	s2,0x1
 75a:	8aa90913          	addi	s2,s2,-1878 # 1000 <freep>
  if(p == (char*)-1)
 75e:	5afd                	li	s5,-1
 760:	a88d                	j	7d2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 762:	00001797          	auipc	a5,0x1
 766:	8ae78793          	addi	a5,a5,-1874 # 1010 <base>
 76a:	00001717          	auipc	a4,0x1
 76e:	88f73b23          	sd	a5,-1898(a4) # 1000 <freep>
 772:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 774:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 778:	b7e1                	j	740 <malloc+0x36>
      if(p->s.size == nunits)
 77a:	02e48b63          	beq	s1,a4,7b0 <malloc+0xa6>
        p->s.size -= nunits;
 77e:	4137073b          	subw	a4,a4,s3
 782:	c798                	sw	a4,8(a5)
        p += p->s.size;
 784:	1702                	slli	a4,a4,0x20
 786:	9301                	srli	a4,a4,0x20
 788:	0712                	slli	a4,a4,0x4
 78a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 78c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 790:	00001717          	auipc	a4,0x1
 794:	86a73823          	sd	a0,-1936(a4) # 1000 <freep>
      return (void*)(p + 1);
 798:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 79c:	70e2                	ld	ra,56(sp)
 79e:	7442                	ld	s0,48(sp)
 7a0:	74a2                	ld	s1,40(sp)
 7a2:	7902                	ld	s2,32(sp)
 7a4:	69e2                	ld	s3,24(sp)
 7a6:	6a42                	ld	s4,16(sp)
 7a8:	6aa2                	ld	s5,8(sp)
 7aa:	6b02                	ld	s6,0(sp)
 7ac:	6121                	addi	sp,sp,64
 7ae:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7b0:	6398                	ld	a4,0(a5)
 7b2:	e118                	sd	a4,0(a0)
 7b4:	bff1                	j	790 <malloc+0x86>
  hp->s.size = nu;
 7b6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7ba:	0541                	addi	a0,a0,16
 7bc:	00000097          	auipc	ra,0x0
 7c0:	ec6080e7          	jalr	-314(ra) # 682 <free>
  return freep;
 7c4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7c8:	d971                	beqz	a0,79c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7cc:	4798                	lw	a4,8(a5)
 7ce:	fa9776e3          	bgeu	a4,s1,77a <malloc+0x70>
    if(p == freep)
 7d2:	00093703          	ld	a4,0(s2)
 7d6:	853e                	mv	a0,a5
 7d8:	fef719e3          	bne	a4,a5,7ca <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7dc:	8552                	mv	a0,s4
 7de:	00000097          	auipc	ra,0x0
 7e2:	b66080e7          	jalr	-1178(ra) # 344 <sbrk>
  if(p == (char*)-1)
 7e6:	fd5518e3          	bne	a0,s5,7b6 <malloc+0xac>
        return 0;
 7ea:	4501                	li	a0,0
 7ec:	bf45                	j	79c <malloc+0x92>
