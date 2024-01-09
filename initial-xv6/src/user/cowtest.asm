
user/_cowtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <simpletest>:
// allocate more than half of physical memory,
// then fork. this will fail in the default
// kernel, which does not support copy-on-write.
void
simpletest()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  uint64 phys_size = PHYSTOP - KERNBASE;
  int sz = (phys_size / 3) * 2;

  printf("simple: ");
   e:	00001517          	auipc	a0,0x1
  12:	c9250513          	addi	a0,a0,-878 # ca0 <malloc+0xee>
  16:	00001097          	auipc	ra,0x1
  1a:	ade080e7          	jalr	-1314(ra) # af4 <printf>
  
  char *p = sbrk(sz);
  1e:	05555537          	lui	a0,0x5555
  22:	55450513          	addi	a0,a0,1364 # 5555554 <base+0x5550544>
  26:	00000097          	auipc	ra,0x0
  2a:	7c6080e7          	jalr	1990(ra) # 7ec <sbrk>
  if(p == (char*)0xffffffffffffffffL){
  2e:	57fd                	li	a5,-1
  30:	06f50563          	beq	a0,a5,9a <simpletest+0x9a>
  34:	84aa                	mv	s1,a0
    printf("sbrk(%d) failed\n", sz);
    exit(-1);
  }

  for(char *q = p; q < p + sz; q += 4096){
  36:	05556937          	lui	s2,0x5556
  3a:	992a                	add	s2,s2,a0
  3c:	6985                	lui	s3,0x1
    *(int*)q = getpid();
  3e:	00000097          	auipc	ra,0x0
  42:	7a6080e7          	jalr	1958(ra) # 7e4 <getpid>
  46:	c088                	sw	a0,0(s1)
  for(char *q = p; q < p + sz; q += 4096){
  48:	94ce                	add	s1,s1,s3
  4a:	fe991ae3          	bne	s2,s1,3e <simpletest+0x3e>
  }

  int pid = fork();
  4e:	00000097          	auipc	ra,0x0
  52:	70e080e7          	jalr	1806(ra) # 75c <fork>
  if(pid < 0){
  56:	06054363          	bltz	a0,bc <simpletest+0xbc>
    printf("fork() failed\n");
    exit(-1);
  }

  if(pid == 0)
  5a:	cd35                	beqz	a0,d6 <simpletest+0xd6>
    exit(0);

  wait(0);
  5c:	4501                	li	a0,0
  5e:	00000097          	auipc	ra,0x0
  62:	70e080e7          	jalr	1806(ra) # 76c <wait>

  if(sbrk(-sz) == (char*)0xffffffffffffffffL){
  66:	faaab537          	lui	a0,0xfaaab
  6a:	aac50513          	addi	a0,a0,-1364 # fffffffffaaaaaac <base+0xfffffffffaaa5a9c>
  6e:	00000097          	auipc	ra,0x0
  72:	77e080e7          	jalr	1918(ra) # 7ec <sbrk>
  76:	57fd                	li	a5,-1
  78:	06f50363          	beq	a0,a5,de <simpletest+0xde>
    printf("sbrk(-%d) failed\n", sz);
    exit(-1);
  }

  printf("ok\n");
  7c:	00001517          	auipc	a0,0x1
  80:	c7450513          	addi	a0,a0,-908 # cf0 <malloc+0x13e>
  84:	00001097          	auipc	ra,0x1
  88:	a70080e7          	jalr	-1424(ra) # af4 <printf>
}
  8c:	70a2                	ld	ra,40(sp)
  8e:	7402                	ld	s0,32(sp)
  90:	64e2                	ld	s1,24(sp)
  92:	6942                	ld	s2,16(sp)
  94:	69a2                	ld	s3,8(sp)
  96:	6145                	addi	sp,sp,48
  98:	8082                	ret
    printf("sbrk(%d) failed\n", sz);
  9a:	055555b7          	lui	a1,0x5555
  9e:	55458593          	addi	a1,a1,1364 # 5555554 <base+0x5550544>
  a2:	00001517          	auipc	a0,0x1
  a6:	c0e50513          	addi	a0,a0,-1010 # cb0 <malloc+0xfe>
  aa:	00001097          	auipc	ra,0x1
  ae:	a4a080e7          	jalr	-1462(ra) # af4 <printf>
    exit(-1);
  b2:	557d                	li	a0,-1
  b4:	00000097          	auipc	ra,0x0
  b8:	6b0080e7          	jalr	1712(ra) # 764 <exit>
    printf("fork() failed\n");
  bc:	00001517          	auipc	a0,0x1
  c0:	c0c50513          	addi	a0,a0,-1012 # cc8 <malloc+0x116>
  c4:	00001097          	auipc	ra,0x1
  c8:	a30080e7          	jalr	-1488(ra) # af4 <printf>
    exit(-1);
  cc:	557d                	li	a0,-1
  ce:	00000097          	auipc	ra,0x0
  d2:	696080e7          	jalr	1686(ra) # 764 <exit>
    exit(0);
  d6:	00000097          	auipc	ra,0x0
  da:	68e080e7          	jalr	1678(ra) # 764 <exit>
    printf("sbrk(-%d) failed\n", sz);
  de:	055555b7          	lui	a1,0x5555
  e2:	55458593          	addi	a1,a1,1364 # 5555554 <base+0x5550544>
  e6:	00001517          	auipc	a0,0x1
  ea:	bf250513          	addi	a0,a0,-1038 # cd8 <malloc+0x126>
  ee:	00001097          	auipc	ra,0x1
  f2:	a06080e7          	jalr	-1530(ra) # af4 <printf>
    exit(-1);
  f6:	557d                	li	a0,-1
  f8:	00000097          	auipc	ra,0x0
  fc:	66c080e7          	jalr	1644(ra) # 764 <exit>

0000000000000100 <threetest>:
// this causes more than half of physical memory
// to be allocated, so it also checks whether
// copied pages are freed.
void
threetest()
{
 100:	7179                	addi	sp,sp,-48
 102:	f406                	sd	ra,40(sp)
 104:	f022                	sd	s0,32(sp)
 106:	ec26                	sd	s1,24(sp)
 108:	e84a                	sd	s2,16(sp)
 10a:	e44e                	sd	s3,8(sp)
 10c:	e052                	sd	s4,0(sp)
 10e:	1800                	addi	s0,sp,48
  uint64 phys_size = PHYSTOP - KERNBASE;
  int sz = phys_size / 4;
  int pid1, pid2;

  printf("three: ");
 110:	00001517          	auipc	a0,0x1
 114:	be850513          	addi	a0,a0,-1048 # cf8 <malloc+0x146>
 118:	00001097          	auipc	ra,0x1
 11c:	9dc080e7          	jalr	-1572(ra) # af4 <printf>
  
  char *p = sbrk(sz);
 120:	02000537          	lui	a0,0x2000
 124:	00000097          	auipc	ra,0x0
 128:	6c8080e7          	jalr	1736(ra) # 7ec <sbrk>
  if(p == (char*)0xffffffffffffffffL){
 12c:	57fd                	li	a5,-1
 12e:	08f50763          	beq	a0,a5,1bc <threetest+0xbc>
 132:	84aa                	mv	s1,a0
    printf("sbrk(%d) failed\n", sz);
    exit(-1);
  }

  pid1 = fork();
 134:	00000097          	auipc	ra,0x0
 138:	628080e7          	jalr	1576(ra) # 75c <fork>
  if(pid1 < 0){
 13c:	08054f63          	bltz	a0,1da <threetest+0xda>
    printf("fork failed\n");
    exit(-1);
  }
  if(pid1 == 0){
 140:	c955                	beqz	a0,1f4 <threetest+0xf4>
      *(int*)q = 9999;
    }
    exit(0);
  }

  for(char *q = p; q < p + sz; q += 4096){
 142:	020009b7          	lui	s3,0x2000
 146:	99a6                	add	s3,s3,s1
 148:	8926                	mv	s2,s1
 14a:	6a05                	lui	s4,0x1
    *(int*)q = getpid();
 14c:	00000097          	auipc	ra,0x0
 150:	698080e7          	jalr	1688(ra) # 7e4 <getpid>
 154:	00a92023          	sw	a0,0(s2) # 5556000 <base+0x5550ff0>
  for(char *q = p; q < p + sz; q += 4096){
 158:	9952                	add	s2,s2,s4
 15a:	ff3919e3          	bne	s2,s3,14c <threetest+0x4c>
  }

  wait(0);
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	60c080e7          	jalr	1548(ra) # 76c <wait>

  sleep(1);
 168:	4505                	li	a0,1
 16a:	00000097          	auipc	ra,0x0
 16e:	68a080e7          	jalr	1674(ra) # 7f4 <sleep>

  for(char *q = p; q < p + sz; q += 4096){
 172:	6a05                	lui	s4,0x1
    if(*(int*)q != getpid()){
 174:	0004a903          	lw	s2,0(s1)
 178:	00000097          	auipc	ra,0x0
 17c:	66c080e7          	jalr	1644(ra) # 7e4 <getpid>
 180:	10a91a63          	bne	s2,a0,294 <threetest+0x194>
  for(char *q = p; q < p + sz; q += 4096){
 184:	94d2                	add	s1,s1,s4
 186:	ff3497e3          	bne	s1,s3,174 <threetest+0x74>
      printf("wrong content\n");
      exit(-1);
    }
  }

  if(sbrk(-sz) == (char*)0xffffffffffffffffL){
 18a:	fe000537          	lui	a0,0xfe000
 18e:	00000097          	auipc	ra,0x0
 192:	65e080e7          	jalr	1630(ra) # 7ec <sbrk>
 196:	57fd                	li	a5,-1
 198:	10f50b63          	beq	a0,a5,2ae <threetest+0x1ae>
    printf("sbrk(-%d) failed\n", sz);
    exit(-1);
  }

  printf("ok\n");
 19c:	00001517          	auipc	a0,0x1
 1a0:	b5450513          	addi	a0,a0,-1196 # cf0 <malloc+0x13e>
 1a4:	00001097          	auipc	ra,0x1
 1a8:	950080e7          	jalr	-1712(ra) # af4 <printf>
}
 1ac:	70a2                	ld	ra,40(sp)
 1ae:	7402                	ld	s0,32(sp)
 1b0:	64e2                	ld	s1,24(sp)
 1b2:	6942                	ld	s2,16(sp)
 1b4:	69a2                	ld	s3,8(sp)
 1b6:	6a02                	ld	s4,0(sp)
 1b8:	6145                	addi	sp,sp,48
 1ba:	8082                	ret
    printf("sbrk(%d) failed\n", sz);
 1bc:	020005b7          	lui	a1,0x2000
 1c0:	00001517          	auipc	a0,0x1
 1c4:	af050513          	addi	a0,a0,-1296 # cb0 <malloc+0xfe>
 1c8:	00001097          	auipc	ra,0x1
 1cc:	92c080e7          	jalr	-1748(ra) # af4 <printf>
    exit(-1);
 1d0:	557d                	li	a0,-1
 1d2:	00000097          	auipc	ra,0x0
 1d6:	592080e7          	jalr	1426(ra) # 764 <exit>
    printf("fork failed\n");
 1da:	00001517          	auipc	a0,0x1
 1de:	b2650513          	addi	a0,a0,-1242 # d00 <malloc+0x14e>
 1e2:	00001097          	auipc	ra,0x1
 1e6:	912080e7          	jalr	-1774(ra) # af4 <printf>
    exit(-1);
 1ea:	557d                	li	a0,-1
 1ec:	00000097          	auipc	ra,0x0
 1f0:	578080e7          	jalr	1400(ra) # 764 <exit>
    pid2 = fork();
 1f4:	00000097          	auipc	ra,0x0
 1f8:	568080e7          	jalr	1384(ra) # 75c <fork>
    if(pid2 < 0){
 1fc:	04054263          	bltz	a0,240 <threetest+0x140>
    if(pid2 == 0){
 200:	ed29                	bnez	a0,25a <threetest+0x15a>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 202:	0199a9b7          	lui	s3,0x199a
 206:	99a6                	add	s3,s3,s1
 208:	8926                	mv	s2,s1
 20a:	6a05                	lui	s4,0x1
        *(int*)q = getpid();
 20c:	00000097          	auipc	ra,0x0
 210:	5d8080e7          	jalr	1496(ra) # 7e4 <getpid>
 214:	00a92023          	sw	a0,0(s2)
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 218:	9952                	add	s2,s2,s4
 21a:	ff2999e3          	bne	s3,s2,20c <threetest+0x10c>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 21e:	6a05                	lui	s4,0x1
        if(*(int*)q != getpid()){
 220:	0004a903          	lw	s2,0(s1)
 224:	00000097          	auipc	ra,0x0
 228:	5c0080e7          	jalr	1472(ra) # 7e4 <getpid>
 22c:	04a91763          	bne	s2,a0,27a <threetest+0x17a>
      for(char *q = p; q < p + (sz/5)*4; q += 4096){
 230:	94d2                	add	s1,s1,s4
 232:	fe9997e3          	bne	s3,s1,220 <threetest+0x120>
      exit(-1);
 236:	557d                	li	a0,-1
 238:	00000097          	auipc	ra,0x0
 23c:	52c080e7          	jalr	1324(ra) # 764 <exit>
      printf("fork failed");
 240:	00001517          	auipc	a0,0x1
 244:	ad050513          	addi	a0,a0,-1328 # d10 <malloc+0x15e>
 248:	00001097          	auipc	ra,0x1
 24c:	8ac080e7          	jalr	-1876(ra) # af4 <printf>
      exit(-1);
 250:	557d                	li	a0,-1
 252:	00000097          	auipc	ra,0x0
 256:	512080e7          	jalr	1298(ra) # 764 <exit>
    for(char *q = p; q < p + (sz/2); q += 4096){
 25a:	01000737          	lui	a4,0x1000
 25e:	9726                	add	a4,a4,s1
      *(int*)q = 9999;
 260:	6789                	lui	a5,0x2
 262:	70f7879b          	addiw	a5,a5,1807
    for(char *q = p; q < p + (sz/2); q += 4096){
 266:	6685                	lui	a3,0x1
      *(int*)q = 9999;
 268:	c09c                	sw	a5,0(s1)
    for(char *q = p; q < p + (sz/2); q += 4096){
 26a:	94b6                	add	s1,s1,a3
 26c:	fee49ee3          	bne	s1,a4,268 <threetest+0x168>
    exit(0);
 270:	4501                	li	a0,0
 272:	00000097          	auipc	ra,0x0
 276:	4f2080e7          	jalr	1266(ra) # 764 <exit>
          printf("wrong content\n");
 27a:	00001517          	auipc	a0,0x1
 27e:	aa650513          	addi	a0,a0,-1370 # d20 <malloc+0x16e>
 282:	00001097          	auipc	ra,0x1
 286:	872080e7          	jalr	-1934(ra) # af4 <printf>
          exit(-1);
 28a:	557d                	li	a0,-1
 28c:	00000097          	auipc	ra,0x0
 290:	4d8080e7          	jalr	1240(ra) # 764 <exit>
      printf("wrong content\n");
 294:	00001517          	auipc	a0,0x1
 298:	a8c50513          	addi	a0,a0,-1396 # d20 <malloc+0x16e>
 29c:	00001097          	auipc	ra,0x1
 2a0:	858080e7          	jalr	-1960(ra) # af4 <printf>
      exit(-1);
 2a4:	557d                	li	a0,-1
 2a6:	00000097          	auipc	ra,0x0
 2aa:	4be080e7          	jalr	1214(ra) # 764 <exit>
    printf("sbrk(-%d) failed\n", sz);
 2ae:	020005b7          	lui	a1,0x2000
 2b2:	00001517          	auipc	a0,0x1
 2b6:	a2650513          	addi	a0,a0,-1498 # cd8 <malloc+0x126>
 2ba:	00001097          	auipc	ra,0x1
 2be:	83a080e7          	jalr	-1990(ra) # af4 <printf>
    exit(-1);
 2c2:	557d                	li	a0,-1
 2c4:	00000097          	auipc	ra,0x0
 2c8:	4a0080e7          	jalr	1184(ra) # 764 <exit>

00000000000002cc <filetest>:
char junk3[4096];

// test whether copyout() simulates COW faults.
void
filetest()
{
 2cc:	7179                	addi	sp,sp,-48
 2ce:	f406                	sd	ra,40(sp)
 2d0:	f022                	sd	s0,32(sp)
 2d2:	ec26                	sd	s1,24(sp)
 2d4:	e84a                	sd	s2,16(sp)
 2d6:	1800                	addi	s0,sp,48
  printf("file: ");
 2d8:	00001517          	auipc	a0,0x1
 2dc:	a5850513          	addi	a0,a0,-1448 # d30 <malloc+0x17e>
 2e0:	00001097          	auipc	ra,0x1
 2e4:	814080e7          	jalr	-2028(ra) # af4 <printf>
  
  buf[0] = 99;
 2e8:	06300793          	li	a5,99
 2ec:	00002717          	auipc	a4,0x2
 2f0:	d2f70223          	sb	a5,-732(a4) # 2010 <buf>

  for(int i = 0; i < 4; i++){
 2f4:	fc042c23          	sw	zero,-40(s0)
    if(pipe(fds) != 0){
 2f8:	00001497          	auipc	s1,0x1
 2fc:	d0848493          	addi	s1,s1,-760 # 1000 <fds>
  for(int i = 0; i < 4; i++){
 300:	490d                	li	s2,3
    if(pipe(fds) != 0){
 302:	8526                	mv	a0,s1
 304:	00000097          	auipc	ra,0x0
 308:	470080e7          	jalr	1136(ra) # 774 <pipe>
 30c:	e149                	bnez	a0,38e <filetest+0xc2>
      printf("pipe() failed\n");
      exit(-1);
    }
    int pid = fork();
 30e:	00000097          	auipc	ra,0x0
 312:	44e080e7          	jalr	1102(ra) # 75c <fork>
    if(pid < 0){
 316:	08054963          	bltz	a0,3a8 <filetest+0xdc>
      printf("fork failed\n");
      exit(-1);
    }
    if(pid == 0){
 31a:	c545                	beqz	a0,3c2 <filetest+0xf6>
        printf("error: read the wrong value\n");
        exit(1);
      }
      exit(0);
    }
    if(write(fds[1], &i, sizeof(i)) != sizeof(i)){
 31c:	4611                	li	a2,4
 31e:	fd840593          	addi	a1,s0,-40
 322:	40c8                	lw	a0,4(s1)
 324:	00000097          	auipc	ra,0x0
 328:	460080e7          	jalr	1120(ra) # 784 <write>
 32c:	4791                	li	a5,4
 32e:	10f51b63          	bne	a0,a5,444 <filetest+0x178>
  for(int i = 0; i < 4; i++){
 332:	fd842783          	lw	a5,-40(s0)
 336:	2785                	addiw	a5,a5,1
 338:	0007871b          	sext.w	a4,a5
 33c:	fcf42c23          	sw	a5,-40(s0)
 340:	fce951e3          	bge	s2,a4,302 <filetest+0x36>
      printf("error: write failed\n");
      exit(-1);
    }
  }

  int xstatus = 0;
 344:	fc042e23          	sw	zero,-36(s0)
 348:	4491                	li	s1,4
  for(int i = 0; i < 4; i++) {
    wait(&xstatus);
 34a:	fdc40513          	addi	a0,s0,-36
 34e:	00000097          	auipc	ra,0x0
 352:	41e080e7          	jalr	1054(ra) # 76c <wait>
    if(xstatus != 0) {
 356:	fdc42783          	lw	a5,-36(s0)
 35a:	10079263          	bnez	a5,45e <filetest+0x192>
  for(int i = 0; i < 4; i++) {
 35e:	34fd                	addiw	s1,s1,-1
 360:	f4ed                	bnez	s1,34a <filetest+0x7e>
      exit(1);
    }
  }

  if(buf[0] != 99){
 362:	00002717          	auipc	a4,0x2
 366:	cae74703          	lbu	a4,-850(a4) # 2010 <buf>
 36a:	06300793          	li	a5,99
 36e:	0ef71d63          	bne	a4,a5,468 <filetest+0x19c>
    printf("error: child overwrote parent\n");
    exit(1);
  }

  printf("ok\n");
 372:	00001517          	auipc	a0,0x1
 376:	97e50513          	addi	a0,a0,-1666 # cf0 <malloc+0x13e>
 37a:	00000097          	auipc	ra,0x0
 37e:	77a080e7          	jalr	1914(ra) # af4 <printf>
}
 382:	70a2                	ld	ra,40(sp)
 384:	7402                	ld	s0,32(sp)
 386:	64e2                	ld	s1,24(sp)
 388:	6942                	ld	s2,16(sp)
 38a:	6145                	addi	sp,sp,48
 38c:	8082                	ret
      printf("pipe() failed\n");
 38e:	00001517          	auipc	a0,0x1
 392:	9aa50513          	addi	a0,a0,-1622 # d38 <malloc+0x186>
 396:	00000097          	auipc	ra,0x0
 39a:	75e080e7          	jalr	1886(ra) # af4 <printf>
      exit(-1);
 39e:	557d                	li	a0,-1
 3a0:	00000097          	auipc	ra,0x0
 3a4:	3c4080e7          	jalr	964(ra) # 764 <exit>
      printf("fork failed\n");
 3a8:	00001517          	auipc	a0,0x1
 3ac:	95850513          	addi	a0,a0,-1704 # d00 <malloc+0x14e>
 3b0:	00000097          	auipc	ra,0x0
 3b4:	744080e7          	jalr	1860(ra) # af4 <printf>
      exit(-1);
 3b8:	557d                	li	a0,-1
 3ba:	00000097          	auipc	ra,0x0
 3be:	3aa080e7          	jalr	938(ra) # 764 <exit>
      sleep(1);
 3c2:	4505                	li	a0,1
 3c4:	00000097          	auipc	ra,0x0
 3c8:	430080e7          	jalr	1072(ra) # 7f4 <sleep>
      if(read(fds[0], buf, sizeof(i)) != sizeof(i)){
 3cc:	4611                	li	a2,4
 3ce:	00002597          	auipc	a1,0x2
 3d2:	c4258593          	addi	a1,a1,-958 # 2010 <buf>
 3d6:	00001517          	auipc	a0,0x1
 3da:	c2a52503          	lw	a0,-982(a0) # 1000 <fds>
 3de:	00000097          	auipc	ra,0x0
 3e2:	39e080e7          	jalr	926(ra) # 77c <read>
 3e6:	4791                	li	a5,4
 3e8:	02f51c63          	bne	a0,a5,420 <filetest+0x154>
      sleep(1);
 3ec:	4505                	li	a0,1
 3ee:	00000097          	auipc	ra,0x0
 3f2:	406080e7          	jalr	1030(ra) # 7f4 <sleep>
      if(j != i){
 3f6:	fd842703          	lw	a4,-40(s0)
 3fa:	00002797          	auipc	a5,0x2
 3fe:	c167a783          	lw	a5,-1002(a5) # 2010 <buf>
 402:	02f70c63          	beq	a4,a5,43a <filetest+0x16e>
        printf("error: read the wrong value\n");
 406:	00001517          	auipc	a0,0x1
 40a:	95a50513          	addi	a0,a0,-1702 # d60 <malloc+0x1ae>
 40e:	00000097          	auipc	ra,0x0
 412:	6e6080e7          	jalr	1766(ra) # af4 <printf>
        exit(1);
 416:	4505                	li	a0,1
 418:	00000097          	auipc	ra,0x0
 41c:	34c080e7          	jalr	844(ra) # 764 <exit>
        printf("error: read failed\n");
 420:	00001517          	auipc	a0,0x1
 424:	92850513          	addi	a0,a0,-1752 # d48 <malloc+0x196>
 428:	00000097          	auipc	ra,0x0
 42c:	6cc080e7          	jalr	1740(ra) # af4 <printf>
        exit(1);
 430:	4505                	li	a0,1
 432:	00000097          	auipc	ra,0x0
 436:	332080e7          	jalr	818(ra) # 764 <exit>
      exit(0);
 43a:	4501                	li	a0,0
 43c:	00000097          	auipc	ra,0x0
 440:	328080e7          	jalr	808(ra) # 764 <exit>
      printf("error: write failed\n");
 444:	00001517          	auipc	a0,0x1
 448:	93c50513          	addi	a0,a0,-1732 # d80 <malloc+0x1ce>
 44c:	00000097          	auipc	ra,0x0
 450:	6a8080e7          	jalr	1704(ra) # af4 <printf>
      exit(-1);
 454:	557d                	li	a0,-1
 456:	00000097          	auipc	ra,0x0
 45a:	30e080e7          	jalr	782(ra) # 764 <exit>
      exit(1);
 45e:	4505                	li	a0,1
 460:	00000097          	auipc	ra,0x0
 464:	304080e7          	jalr	772(ra) # 764 <exit>
    printf("error: child overwrote parent\n");
 468:	00001517          	auipc	a0,0x1
 46c:	93050513          	addi	a0,a0,-1744 # d98 <malloc+0x1e6>
 470:	00000097          	auipc	ra,0x0
 474:	684080e7          	jalr	1668(ra) # af4 <printf>
    exit(1);
 478:	4505                	li	a0,1
 47a:	00000097          	auipc	ra,0x0
 47e:	2ea080e7          	jalr	746(ra) # 764 <exit>

0000000000000482 <main>:

int
main(int argc, char *argv[])
{
 482:	1141                	addi	sp,sp,-16
 484:	e406                	sd	ra,8(sp)
 486:	e022                	sd	s0,0(sp)
 488:	0800                	addi	s0,sp,16
  simpletest();
 48a:	00000097          	auipc	ra,0x0
 48e:	b76080e7          	jalr	-1162(ra) # 0 <simpletest>

  // check that the first simpletest() freed the physical memory.
  simpletest();
 492:	00000097          	auipc	ra,0x0
 496:	b6e080e7          	jalr	-1170(ra) # 0 <simpletest>

  threetest();
 49a:	00000097          	auipc	ra,0x0
 49e:	c66080e7          	jalr	-922(ra) # 100 <threetest>
  threetest();
 4a2:	00000097          	auipc	ra,0x0
 4a6:	c5e080e7          	jalr	-930(ra) # 100 <threetest>
  threetest();
 4aa:	00000097          	auipc	ra,0x0
 4ae:	c56080e7          	jalr	-938(ra) # 100 <threetest>

  filetest();
 4b2:	00000097          	auipc	ra,0x0
 4b6:	e1a080e7          	jalr	-486(ra) # 2cc <filetest>

  printf("ALL COW TESTS PASSED\n");
 4ba:	00001517          	auipc	a0,0x1
 4be:	8fe50513          	addi	a0,a0,-1794 # db8 <malloc+0x206>
 4c2:	00000097          	auipc	ra,0x0
 4c6:	632080e7          	jalr	1586(ra) # af4 <printf>

  exit(0);
 4ca:	4501                	li	a0,0
 4cc:	00000097          	auipc	ra,0x0
 4d0:	298080e7          	jalr	664(ra) # 764 <exit>

00000000000004d4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 4d4:	1141                	addi	sp,sp,-16
 4d6:	e406                	sd	ra,8(sp)
 4d8:	e022                	sd	s0,0(sp)
 4da:	0800                	addi	s0,sp,16
  extern int main();
  main();
 4dc:	00000097          	auipc	ra,0x0
 4e0:	fa6080e7          	jalr	-90(ra) # 482 <main>
  exit(0);
 4e4:	4501                	li	a0,0
 4e6:	00000097          	auipc	ra,0x0
 4ea:	27e080e7          	jalr	638(ra) # 764 <exit>

00000000000004ee <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 4ee:	1141                	addi	sp,sp,-16
 4f0:	e422                	sd	s0,8(sp)
 4f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 4f4:	87aa                	mv	a5,a0
 4f6:	0585                	addi	a1,a1,1
 4f8:	0785                	addi	a5,a5,1
 4fa:	fff5c703          	lbu	a4,-1(a1)
 4fe:	fee78fa3          	sb	a4,-1(a5)
 502:	fb75                	bnez	a4,4f6 <strcpy+0x8>
    ;
  return os;
}
 504:	6422                	ld	s0,8(sp)
 506:	0141                	addi	sp,sp,16
 508:	8082                	ret

000000000000050a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 50a:	1141                	addi	sp,sp,-16
 50c:	e422                	sd	s0,8(sp)
 50e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 510:	00054783          	lbu	a5,0(a0)
 514:	cb91                	beqz	a5,528 <strcmp+0x1e>
 516:	0005c703          	lbu	a4,0(a1)
 51a:	00f71763          	bne	a4,a5,528 <strcmp+0x1e>
    p++, q++;
 51e:	0505                	addi	a0,a0,1
 520:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 522:	00054783          	lbu	a5,0(a0)
 526:	fbe5                	bnez	a5,516 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 528:	0005c503          	lbu	a0,0(a1)
}
 52c:	40a7853b          	subw	a0,a5,a0
 530:	6422                	ld	s0,8(sp)
 532:	0141                	addi	sp,sp,16
 534:	8082                	ret

0000000000000536 <strlen>:

uint
strlen(const char *s)
{
 536:	1141                	addi	sp,sp,-16
 538:	e422                	sd	s0,8(sp)
 53a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 53c:	00054783          	lbu	a5,0(a0)
 540:	cf91                	beqz	a5,55c <strlen+0x26>
 542:	0505                	addi	a0,a0,1
 544:	87aa                	mv	a5,a0
 546:	4685                	li	a3,1
 548:	9e89                	subw	a3,a3,a0
 54a:	00f6853b          	addw	a0,a3,a5
 54e:	0785                	addi	a5,a5,1
 550:	fff7c703          	lbu	a4,-1(a5)
 554:	fb7d                	bnez	a4,54a <strlen+0x14>
    ;
  return n;
}
 556:	6422                	ld	s0,8(sp)
 558:	0141                	addi	sp,sp,16
 55a:	8082                	ret
  for(n = 0; s[n]; n++)
 55c:	4501                	li	a0,0
 55e:	bfe5                	j	556 <strlen+0x20>

0000000000000560 <memset>:

void*
memset(void *dst, int c, uint n)
{
 560:	1141                	addi	sp,sp,-16
 562:	e422                	sd	s0,8(sp)
 564:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 566:	ce09                	beqz	a2,580 <memset+0x20>
 568:	87aa                	mv	a5,a0
 56a:	fff6071b          	addiw	a4,a2,-1
 56e:	1702                	slli	a4,a4,0x20
 570:	9301                	srli	a4,a4,0x20
 572:	0705                	addi	a4,a4,1
 574:	972a                	add	a4,a4,a0
    cdst[i] = c;
 576:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 57a:	0785                	addi	a5,a5,1
 57c:	fee79de3          	bne	a5,a4,576 <memset+0x16>
  }
  return dst;
}
 580:	6422                	ld	s0,8(sp)
 582:	0141                	addi	sp,sp,16
 584:	8082                	ret

0000000000000586 <strchr>:

char*
strchr(const char *s, char c)
{
 586:	1141                	addi	sp,sp,-16
 588:	e422                	sd	s0,8(sp)
 58a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 58c:	00054783          	lbu	a5,0(a0)
 590:	cb99                	beqz	a5,5a6 <strchr+0x20>
    if(*s == c)
 592:	00f58763          	beq	a1,a5,5a0 <strchr+0x1a>
  for(; *s; s++)
 596:	0505                	addi	a0,a0,1
 598:	00054783          	lbu	a5,0(a0)
 59c:	fbfd                	bnez	a5,592 <strchr+0xc>
      return (char*)s;
  return 0;
 59e:	4501                	li	a0,0
}
 5a0:	6422                	ld	s0,8(sp)
 5a2:	0141                	addi	sp,sp,16
 5a4:	8082                	ret
  return 0;
 5a6:	4501                	li	a0,0
 5a8:	bfe5                	j	5a0 <strchr+0x1a>

00000000000005aa <gets>:

char*
gets(char *buf, int max)
{
 5aa:	711d                	addi	sp,sp,-96
 5ac:	ec86                	sd	ra,88(sp)
 5ae:	e8a2                	sd	s0,80(sp)
 5b0:	e4a6                	sd	s1,72(sp)
 5b2:	e0ca                	sd	s2,64(sp)
 5b4:	fc4e                	sd	s3,56(sp)
 5b6:	f852                	sd	s4,48(sp)
 5b8:	f456                	sd	s5,40(sp)
 5ba:	f05a                	sd	s6,32(sp)
 5bc:	ec5e                	sd	s7,24(sp)
 5be:	1080                	addi	s0,sp,96
 5c0:	8baa                	mv	s7,a0
 5c2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5c4:	892a                	mv	s2,a0
 5c6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 5c8:	4aa9                	li	s5,10
 5ca:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 5cc:	89a6                	mv	s3,s1
 5ce:	2485                	addiw	s1,s1,1
 5d0:	0344d863          	bge	s1,s4,600 <gets+0x56>
    cc = read(0, &c, 1);
 5d4:	4605                	li	a2,1
 5d6:	faf40593          	addi	a1,s0,-81
 5da:	4501                	li	a0,0
 5dc:	00000097          	auipc	ra,0x0
 5e0:	1a0080e7          	jalr	416(ra) # 77c <read>
    if(cc < 1)
 5e4:	00a05e63          	blez	a0,600 <gets+0x56>
    buf[i++] = c;
 5e8:	faf44783          	lbu	a5,-81(s0)
 5ec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 5f0:	01578763          	beq	a5,s5,5fe <gets+0x54>
 5f4:	0905                	addi	s2,s2,1
 5f6:	fd679be3          	bne	a5,s6,5cc <gets+0x22>
  for(i=0; i+1 < max; ){
 5fa:	89a6                	mv	s3,s1
 5fc:	a011                	j	600 <gets+0x56>
 5fe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 600:	99de                	add	s3,s3,s7
 602:	00098023          	sb	zero,0(s3) # 199a000 <base+0x1994ff0>
  return buf;
}
 606:	855e                	mv	a0,s7
 608:	60e6                	ld	ra,88(sp)
 60a:	6446                	ld	s0,80(sp)
 60c:	64a6                	ld	s1,72(sp)
 60e:	6906                	ld	s2,64(sp)
 610:	79e2                	ld	s3,56(sp)
 612:	7a42                	ld	s4,48(sp)
 614:	7aa2                	ld	s5,40(sp)
 616:	7b02                	ld	s6,32(sp)
 618:	6be2                	ld	s7,24(sp)
 61a:	6125                	addi	sp,sp,96
 61c:	8082                	ret

000000000000061e <stat>:

int
stat(const char *n, struct stat *st)
{
 61e:	1101                	addi	sp,sp,-32
 620:	ec06                	sd	ra,24(sp)
 622:	e822                	sd	s0,16(sp)
 624:	e426                	sd	s1,8(sp)
 626:	e04a                	sd	s2,0(sp)
 628:	1000                	addi	s0,sp,32
 62a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 62c:	4581                	li	a1,0
 62e:	00000097          	auipc	ra,0x0
 632:	176080e7          	jalr	374(ra) # 7a4 <open>
  if(fd < 0)
 636:	02054563          	bltz	a0,660 <stat+0x42>
 63a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 63c:	85ca                	mv	a1,s2
 63e:	00000097          	auipc	ra,0x0
 642:	17e080e7          	jalr	382(ra) # 7bc <fstat>
 646:	892a                	mv	s2,a0
  close(fd);
 648:	8526                	mv	a0,s1
 64a:	00000097          	auipc	ra,0x0
 64e:	142080e7          	jalr	322(ra) # 78c <close>
  return r;
}
 652:	854a                	mv	a0,s2
 654:	60e2                	ld	ra,24(sp)
 656:	6442                	ld	s0,16(sp)
 658:	64a2                	ld	s1,8(sp)
 65a:	6902                	ld	s2,0(sp)
 65c:	6105                	addi	sp,sp,32
 65e:	8082                	ret
    return -1;
 660:	597d                	li	s2,-1
 662:	bfc5                	j	652 <stat+0x34>

0000000000000664 <atoi>:

int
atoi(const char *s)
{
 664:	1141                	addi	sp,sp,-16
 666:	e422                	sd	s0,8(sp)
 668:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 66a:	00054603          	lbu	a2,0(a0)
 66e:	fd06079b          	addiw	a5,a2,-48
 672:	0ff7f793          	andi	a5,a5,255
 676:	4725                	li	a4,9
 678:	02f76963          	bltu	a4,a5,6aa <atoi+0x46>
 67c:	86aa                	mv	a3,a0
  n = 0;
 67e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 680:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 682:	0685                	addi	a3,a3,1
 684:	0025179b          	slliw	a5,a0,0x2
 688:	9fa9                	addw	a5,a5,a0
 68a:	0017979b          	slliw	a5,a5,0x1
 68e:	9fb1                	addw	a5,a5,a2
 690:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 694:	0006c603          	lbu	a2,0(a3) # 1000 <fds>
 698:	fd06071b          	addiw	a4,a2,-48
 69c:	0ff77713          	andi	a4,a4,255
 6a0:	fee5f1e3          	bgeu	a1,a4,682 <atoi+0x1e>
  return n;
}
 6a4:	6422                	ld	s0,8(sp)
 6a6:	0141                	addi	sp,sp,16
 6a8:	8082                	ret
  n = 0;
 6aa:	4501                	li	a0,0
 6ac:	bfe5                	j	6a4 <atoi+0x40>

00000000000006ae <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 6ae:	1141                	addi	sp,sp,-16
 6b0:	e422                	sd	s0,8(sp)
 6b2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 6b4:	02b57663          	bgeu	a0,a1,6e0 <memmove+0x32>
    while(n-- > 0)
 6b8:	02c05163          	blez	a2,6da <memmove+0x2c>
 6bc:	fff6079b          	addiw	a5,a2,-1
 6c0:	1782                	slli	a5,a5,0x20
 6c2:	9381                	srli	a5,a5,0x20
 6c4:	0785                	addi	a5,a5,1
 6c6:	97aa                	add	a5,a5,a0
  dst = vdst;
 6c8:	872a                	mv	a4,a0
      *dst++ = *src++;
 6ca:	0585                	addi	a1,a1,1
 6cc:	0705                	addi	a4,a4,1
 6ce:	fff5c683          	lbu	a3,-1(a1)
 6d2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 6d6:	fee79ae3          	bne	a5,a4,6ca <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 6da:	6422                	ld	s0,8(sp)
 6dc:	0141                	addi	sp,sp,16
 6de:	8082                	ret
    dst += n;
 6e0:	00c50733          	add	a4,a0,a2
    src += n;
 6e4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 6e6:	fec05ae3          	blez	a2,6da <memmove+0x2c>
 6ea:	fff6079b          	addiw	a5,a2,-1
 6ee:	1782                	slli	a5,a5,0x20
 6f0:	9381                	srli	a5,a5,0x20
 6f2:	fff7c793          	not	a5,a5
 6f6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6f8:	15fd                	addi	a1,a1,-1
 6fa:	177d                	addi	a4,a4,-1
 6fc:	0005c683          	lbu	a3,0(a1)
 700:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 704:	fee79ae3          	bne	a5,a4,6f8 <memmove+0x4a>
 708:	bfc9                	j	6da <memmove+0x2c>

000000000000070a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 70a:	1141                	addi	sp,sp,-16
 70c:	e422                	sd	s0,8(sp)
 70e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 710:	ca05                	beqz	a2,740 <memcmp+0x36>
 712:	fff6069b          	addiw	a3,a2,-1
 716:	1682                	slli	a3,a3,0x20
 718:	9281                	srli	a3,a3,0x20
 71a:	0685                	addi	a3,a3,1
 71c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 71e:	00054783          	lbu	a5,0(a0)
 722:	0005c703          	lbu	a4,0(a1)
 726:	00e79863          	bne	a5,a4,736 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 72a:	0505                	addi	a0,a0,1
    p2++;
 72c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 72e:	fed518e3          	bne	a0,a3,71e <memcmp+0x14>
  }
  return 0;
 732:	4501                	li	a0,0
 734:	a019                	j	73a <memcmp+0x30>
      return *p1 - *p2;
 736:	40e7853b          	subw	a0,a5,a4
}
 73a:	6422                	ld	s0,8(sp)
 73c:	0141                	addi	sp,sp,16
 73e:	8082                	ret
  return 0;
 740:	4501                	li	a0,0
 742:	bfe5                	j	73a <memcmp+0x30>

0000000000000744 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 744:	1141                	addi	sp,sp,-16
 746:	e406                	sd	ra,8(sp)
 748:	e022                	sd	s0,0(sp)
 74a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 74c:	00000097          	auipc	ra,0x0
 750:	f62080e7          	jalr	-158(ra) # 6ae <memmove>
}
 754:	60a2                	ld	ra,8(sp)
 756:	6402                	ld	s0,0(sp)
 758:	0141                	addi	sp,sp,16
 75a:	8082                	ret

000000000000075c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 75c:	4885                	li	a7,1
 ecall
 75e:	00000073          	ecall
 ret
 762:	8082                	ret

0000000000000764 <exit>:
.global exit
exit:
 li a7, SYS_exit
 764:	4889                	li	a7,2
 ecall
 766:	00000073          	ecall
 ret
 76a:	8082                	ret

000000000000076c <wait>:
.global wait
wait:
 li a7, SYS_wait
 76c:	488d                	li	a7,3
 ecall
 76e:	00000073          	ecall
 ret
 772:	8082                	ret

0000000000000774 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 774:	4891                	li	a7,4
 ecall
 776:	00000073          	ecall
 ret
 77a:	8082                	ret

000000000000077c <read>:
.global read
read:
 li a7, SYS_read
 77c:	4895                	li	a7,5
 ecall
 77e:	00000073          	ecall
 ret
 782:	8082                	ret

0000000000000784 <write>:
.global write
write:
 li a7, SYS_write
 784:	48c1                	li	a7,16
 ecall
 786:	00000073          	ecall
 ret
 78a:	8082                	ret

000000000000078c <close>:
.global close
close:
 li a7, SYS_close
 78c:	48d5                	li	a7,21
 ecall
 78e:	00000073          	ecall
 ret
 792:	8082                	ret

0000000000000794 <kill>:
.global kill
kill:
 li a7, SYS_kill
 794:	4899                	li	a7,6
 ecall
 796:	00000073          	ecall
 ret
 79a:	8082                	ret

000000000000079c <exec>:
.global exec
exec:
 li a7, SYS_exec
 79c:	489d                	li	a7,7
 ecall
 79e:	00000073          	ecall
 ret
 7a2:	8082                	ret

00000000000007a4 <open>:
.global open
open:
 li a7, SYS_open
 7a4:	48bd                	li	a7,15
 ecall
 7a6:	00000073          	ecall
 ret
 7aa:	8082                	ret

00000000000007ac <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 7ac:	48c5                	li	a7,17
 ecall
 7ae:	00000073          	ecall
 ret
 7b2:	8082                	ret

00000000000007b4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 7b4:	48c9                	li	a7,18
 ecall
 7b6:	00000073          	ecall
 ret
 7ba:	8082                	ret

00000000000007bc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 7bc:	48a1                	li	a7,8
 ecall
 7be:	00000073          	ecall
 ret
 7c2:	8082                	ret

00000000000007c4 <link>:
.global link
link:
 li a7, SYS_link
 7c4:	48cd                	li	a7,19
 ecall
 7c6:	00000073          	ecall
 ret
 7ca:	8082                	ret

00000000000007cc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 7cc:	48d1                	li	a7,20
 ecall
 7ce:	00000073          	ecall
 ret
 7d2:	8082                	ret

00000000000007d4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 7d4:	48a5                	li	a7,9
 ecall
 7d6:	00000073          	ecall
 ret
 7da:	8082                	ret

00000000000007dc <dup>:
.global dup
dup:
 li a7, SYS_dup
 7dc:	48a9                	li	a7,10
 ecall
 7de:	00000073          	ecall
 ret
 7e2:	8082                	ret

00000000000007e4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7e4:	48ad                	li	a7,11
 ecall
 7e6:	00000073          	ecall
 ret
 7ea:	8082                	ret

00000000000007ec <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7ec:	48b1                	li	a7,12
 ecall
 7ee:	00000073          	ecall
 ret
 7f2:	8082                	ret

00000000000007f4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 7f4:	48b5                	li	a7,13
 ecall
 7f6:	00000073          	ecall
 ret
 7fa:	8082                	ret

00000000000007fc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7fc:	48b9                	li	a7,14
 ecall
 7fe:	00000073          	ecall
 ret
 802:	8082                	ret

0000000000000804 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 804:	48d9                	li	a7,22
 ecall
 806:	00000073          	ecall
 ret
 80a:	8082                	ret

000000000000080c <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 80c:	48dd                	li	a7,23
 ecall
 80e:	00000073          	ecall
 ret
 812:	8082                	ret

0000000000000814 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 814:	48e1                	li	a7,24
 ecall
 816:	00000073          	ecall
 ret
 81a:	8082                	ret

000000000000081c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 81c:	1101                	addi	sp,sp,-32
 81e:	ec06                	sd	ra,24(sp)
 820:	e822                	sd	s0,16(sp)
 822:	1000                	addi	s0,sp,32
 824:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 828:	4605                	li	a2,1
 82a:	fef40593          	addi	a1,s0,-17
 82e:	00000097          	auipc	ra,0x0
 832:	f56080e7          	jalr	-170(ra) # 784 <write>
}
 836:	60e2                	ld	ra,24(sp)
 838:	6442                	ld	s0,16(sp)
 83a:	6105                	addi	sp,sp,32
 83c:	8082                	ret

000000000000083e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 83e:	7139                	addi	sp,sp,-64
 840:	fc06                	sd	ra,56(sp)
 842:	f822                	sd	s0,48(sp)
 844:	f426                	sd	s1,40(sp)
 846:	f04a                	sd	s2,32(sp)
 848:	ec4e                	sd	s3,24(sp)
 84a:	0080                	addi	s0,sp,64
 84c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 84e:	c299                	beqz	a3,854 <printint+0x16>
 850:	0805c863          	bltz	a1,8e0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 854:	2581                	sext.w	a1,a1
  neg = 0;
 856:	4881                	li	a7,0
 858:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 85c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 85e:	2601                	sext.w	a2,a2
 860:	00000517          	auipc	a0,0x0
 864:	57850513          	addi	a0,a0,1400 # dd8 <digits>
 868:	883a                	mv	a6,a4
 86a:	2705                	addiw	a4,a4,1
 86c:	02c5f7bb          	remuw	a5,a1,a2
 870:	1782                	slli	a5,a5,0x20
 872:	9381                	srli	a5,a5,0x20
 874:	97aa                	add	a5,a5,a0
 876:	0007c783          	lbu	a5,0(a5)
 87a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 87e:	0005879b          	sext.w	a5,a1
 882:	02c5d5bb          	divuw	a1,a1,a2
 886:	0685                	addi	a3,a3,1
 888:	fec7f0e3          	bgeu	a5,a2,868 <printint+0x2a>
  if(neg)
 88c:	00088b63          	beqz	a7,8a2 <printint+0x64>
    buf[i++] = '-';
 890:	fd040793          	addi	a5,s0,-48
 894:	973e                	add	a4,a4,a5
 896:	02d00793          	li	a5,45
 89a:	fef70823          	sb	a5,-16(a4)
 89e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 8a2:	02e05863          	blez	a4,8d2 <printint+0x94>
 8a6:	fc040793          	addi	a5,s0,-64
 8aa:	00e78933          	add	s2,a5,a4
 8ae:	fff78993          	addi	s3,a5,-1
 8b2:	99ba                	add	s3,s3,a4
 8b4:	377d                	addiw	a4,a4,-1
 8b6:	1702                	slli	a4,a4,0x20
 8b8:	9301                	srli	a4,a4,0x20
 8ba:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 8be:	fff94583          	lbu	a1,-1(s2)
 8c2:	8526                	mv	a0,s1
 8c4:	00000097          	auipc	ra,0x0
 8c8:	f58080e7          	jalr	-168(ra) # 81c <putc>
  while(--i >= 0)
 8cc:	197d                	addi	s2,s2,-1
 8ce:	ff3918e3          	bne	s2,s3,8be <printint+0x80>
}
 8d2:	70e2                	ld	ra,56(sp)
 8d4:	7442                	ld	s0,48(sp)
 8d6:	74a2                	ld	s1,40(sp)
 8d8:	7902                	ld	s2,32(sp)
 8da:	69e2                	ld	s3,24(sp)
 8dc:	6121                	addi	sp,sp,64
 8de:	8082                	ret
    x = -xx;
 8e0:	40b005bb          	negw	a1,a1
    neg = 1;
 8e4:	4885                	li	a7,1
    x = -xx;
 8e6:	bf8d                	j	858 <printint+0x1a>

00000000000008e8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8e8:	7119                	addi	sp,sp,-128
 8ea:	fc86                	sd	ra,120(sp)
 8ec:	f8a2                	sd	s0,112(sp)
 8ee:	f4a6                	sd	s1,104(sp)
 8f0:	f0ca                	sd	s2,96(sp)
 8f2:	ecce                	sd	s3,88(sp)
 8f4:	e8d2                	sd	s4,80(sp)
 8f6:	e4d6                	sd	s5,72(sp)
 8f8:	e0da                	sd	s6,64(sp)
 8fa:	fc5e                	sd	s7,56(sp)
 8fc:	f862                	sd	s8,48(sp)
 8fe:	f466                	sd	s9,40(sp)
 900:	f06a                	sd	s10,32(sp)
 902:	ec6e                	sd	s11,24(sp)
 904:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 906:	0005c903          	lbu	s2,0(a1)
 90a:	18090f63          	beqz	s2,aa8 <vprintf+0x1c0>
 90e:	8aaa                	mv	s5,a0
 910:	8b32                	mv	s6,a2
 912:	00158493          	addi	s1,a1,1
  state = 0;
 916:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 918:	02500a13          	li	s4,37
      if(c == 'd'){
 91c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 920:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 924:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 928:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 92c:	00000b97          	auipc	s7,0x0
 930:	4acb8b93          	addi	s7,s7,1196 # dd8 <digits>
 934:	a839                	j	952 <vprintf+0x6a>
        putc(fd, c);
 936:	85ca                	mv	a1,s2
 938:	8556                	mv	a0,s5
 93a:	00000097          	auipc	ra,0x0
 93e:	ee2080e7          	jalr	-286(ra) # 81c <putc>
 942:	a019                	j	948 <vprintf+0x60>
    } else if(state == '%'){
 944:	01498f63          	beq	s3,s4,962 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 948:	0485                	addi	s1,s1,1
 94a:	fff4c903          	lbu	s2,-1(s1)
 94e:	14090d63          	beqz	s2,aa8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 952:	0009079b          	sext.w	a5,s2
    if(state == 0){
 956:	fe0997e3          	bnez	s3,944 <vprintf+0x5c>
      if(c == '%'){
 95a:	fd479ee3          	bne	a5,s4,936 <vprintf+0x4e>
        state = '%';
 95e:	89be                	mv	s3,a5
 960:	b7e5                	j	948 <vprintf+0x60>
      if(c == 'd'){
 962:	05878063          	beq	a5,s8,9a2 <vprintf+0xba>
      } else if(c == 'l') {
 966:	05978c63          	beq	a5,s9,9be <vprintf+0xd6>
      } else if(c == 'x') {
 96a:	07a78863          	beq	a5,s10,9da <vprintf+0xf2>
      } else if(c == 'p') {
 96e:	09b78463          	beq	a5,s11,9f6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 972:	07300713          	li	a4,115
 976:	0ce78663          	beq	a5,a4,a42 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 97a:	06300713          	li	a4,99
 97e:	0ee78e63          	beq	a5,a4,a7a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 982:	11478863          	beq	a5,s4,a92 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 986:	85d2                	mv	a1,s4
 988:	8556                	mv	a0,s5
 98a:	00000097          	auipc	ra,0x0
 98e:	e92080e7          	jalr	-366(ra) # 81c <putc>
        putc(fd, c);
 992:	85ca                	mv	a1,s2
 994:	8556                	mv	a0,s5
 996:	00000097          	auipc	ra,0x0
 99a:	e86080e7          	jalr	-378(ra) # 81c <putc>
      }
      state = 0;
 99e:	4981                	li	s3,0
 9a0:	b765                	j	948 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 9a2:	008b0913          	addi	s2,s6,8
 9a6:	4685                	li	a3,1
 9a8:	4629                	li	a2,10
 9aa:	000b2583          	lw	a1,0(s6)
 9ae:	8556                	mv	a0,s5
 9b0:	00000097          	auipc	ra,0x0
 9b4:	e8e080e7          	jalr	-370(ra) # 83e <printint>
 9b8:	8b4a                	mv	s6,s2
      state = 0;
 9ba:	4981                	li	s3,0
 9bc:	b771                	j	948 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9be:	008b0913          	addi	s2,s6,8
 9c2:	4681                	li	a3,0
 9c4:	4629                	li	a2,10
 9c6:	000b2583          	lw	a1,0(s6)
 9ca:	8556                	mv	a0,s5
 9cc:	00000097          	auipc	ra,0x0
 9d0:	e72080e7          	jalr	-398(ra) # 83e <printint>
 9d4:	8b4a                	mv	s6,s2
      state = 0;
 9d6:	4981                	li	s3,0
 9d8:	bf85                	j	948 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 9da:	008b0913          	addi	s2,s6,8
 9de:	4681                	li	a3,0
 9e0:	4641                	li	a2,16
 9e2:	000b2583          	lw	a1,0(s6)
 9e6:	8556                	mv	a0,s5
 9e8:	00000097          	auipc	ra,0x0
 9ec:	e56080e7          	jalr	-426(ra) # 83e <printint>
 9f0:	8b4a                	mv	s6,s2
      state = 0;
 9f2:	4981                	li	s3,0
 9f4:	bf91                	j	948 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 9f6:	008b0793          	addi	a5,s6,8
 9fa:	f8f43423          	sd	a5,-120(s0)
 9fe:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 a02:	03000593          	li	a1,48
 a06:	8556                	mv	a0,s5
 a08:	00000097          	auipc	ra,0x0
 a0c:	e14080e7          	jalr	-492(ra) # 81c <putc>
  putc(fd, 'x');
 a10:	85ea                	mv	a1,s10
 a12:	8556                	mv	a0,s5
 a14:	00000097          	auipc	ra,0x0
 a18:	e08080e7          	jalr	-504(ra) # 81c <putc>
 a1c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a1e:	03c9d793          	srli	a5,s3,0x3c
 a22:	97de                	add	a5,a5,s7
 a24:	0007c583          	lbu	a1,0(a5)
 a28:	8556                	mv	a0,s5
 a2a:	00000097          	auipc	ra,0x0
 a2e:	df2080e7          	jalr	-526(ra) # 81c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a32:	0992                	slli	s3,s3,0x4
 a34:	397d                	addiw	s2,s2,-1
 a36:	fe0914e3          	bnez	s2,a1e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 a3a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 a3e:	4981                	li	s3,0
 a40:	b721                	j	948 <vprintf+0x60>
        s = va_arg(ap, char*);
 a42:	008b0993          	addi	s3,s6,8
 a46:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 a4a:	02090163          	beqz	s2,a6c <vprintf+0x184>
        while(*s != 0){
 a4e:	00094583          	lbu	a1,0(s2)
 a52:	c9a1                	beqz	a1,aa2 <vprintf+0x1ba>
          putc(fd, *s);
 a54:	8556                	mv	a0,s5
 a56:	00000097          	auipc	ra,0x0
 a5a:	dc6080e7          	jalr	-570(ra) # 81c <putc>
          s++;
 a5e:	0905                	addi	s2,s2,1
        while(*s != 0){
 a60:	00094583          	lbu	a1,0(s2)
 a64:	f9e5                	bnez	a1,a54 <vprintf+0x16c>
        s = va_arg(ap, char*);
 a66:	8b4e                	mv	s6,s3
      state = 0;
 a68:	4981                	li	s3,0
 a6a:	bdf9                	j	948 <vprintf+0x60>
          s = "(null)";
 a6c:	00000917          	auipc	s2,0x0
 a70:	36490913          	addi	s2,s2,868 # dd0 <malloc+0x21e>
        while(*s != 0){
 a74:	02800593          	li	a1,40
 a78:	bff1                	j	a54 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a7a:	008b0913          	addi	s2,s6,8
 a7e:	000b4583          	lbu	a1,0(s6)
 a82:	8556                	mv	a0,s5
 a84:	00000097          	auipc	ra,0x0
 a88:	d98080e7          	jalr	-616(ra) # 81c <putc>
 a8c:	8b4a                	mv	s6,s2
      state = 0;
 a8e:	4981                	li	s3,0
 a90:	bd65                	j	948 <vprintf+0x60>
        putc(fd, c);
 a92:	85d2                	mv	a1,s4
 a94:	8556                	mv	a0,s5
 a96:	00000097          	auipc	ra,0x0
 a9a:	d86080e7          	jalr	-634(ra) # 81c <putc>
      state = 0;
 a9e:	4981                	li	s3,0
 aa0:	b565                	j	948 <vprintf+0x60>
        s = va_arg(ap, char*);
 aa2:	8b4e                	mv	s6,s3
      state = 0;
 aa4:	4981                	li	s3,0
 aa6:	b54d                	j	948 <vprintf+0x60>
    }
  }
}
 aa8:	70e6                	ld	ra,120(sp)
 aaa:	7446                	ld	s0,112(sp)
 aac:	74a6                	ld	s1,104(sp)
 aae:	7906                	ld	s2,96(sp)
 ab0:	69e6                	ld	s3,88(sp)
 ab2:	6a46                	ld	s4,80(sp)
 ab4:	6aa6                	ld	s5,72(sp)
 ab6:	6b06                	ld	s6,64(sp)
 ab8:	7be2                	ld	s7,56(sp)
 aba:	7c42                	ld	s8,48(sp)
 abc:	7ca2                	ld	s9,40(sp)
 abe:	7d02                	ld	s10,32(sp)
 ac0:	6de2                	ld	s11,24(sp)
 ac2:	6109                	addi	sp,sp,128
 ac4:	8082                	ret

0000000000000ac6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 ac6:	715d                	addi	sp,sp,-80
 ac8:	ec06                	sd	ra,24(sp)
 aca:	e822                	sd	s0,16(sp)
 acc:	1000                	addi	s0,sp,32
 ace:	e010                	sd	a2,0(s0)
 ad0:	e414                	sd	a3,8(s0)
 ad2:	e818                	sd	a4,16(s0)
 ad4:	ec1c                	sd	a5,24(s0)
 ad6:	03043023          	sd	a6,32(s0)
 ada:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 ade:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ae2:	8622                	mv	a2,s0
 ae4:	00000097          	auipc	ra,0x0
 ae8:	e04080e7          	jalr	-508(ra) # 8e8 <vprintf>
}
 aec:	60e2                	ld	ra,24(sp)
 aee:	6442                	ld	s0,16(sp)
 af0:	6161                	addi	sp,sp,80
 af2:	8082                	ret

0000000000000af4 <printf>:

void
printf(const char *fmt, ...)
{
 af4:	711d                	addi	sp,sp,-96
 af6:	ec06                	sd	ra,24(sp)
 af8:	e822                	sd	s0,16(sp)
 afa:	1000                	addi	s0,sp,32
 afc:	e40c                	sd	a1,8(s0)
 afe:	e810                	sd	a2,16(s0)
 b00:	ec14                	sd	a3,24(s0)
 b02:	f018                	sd	a4,32(s0)
 b04:	f41c                	sd	a5,40(s0)
 b06:	03043823          	sd	a6,48(s0)
 b0a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b0e:	00840613          	addi	a2,s0,8
 b12:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b16:	85aa                	mv	a1,a0
 b18:	4505                	li	a0,1
 b1a:	00000097          	auipc	ra,0x0
 b1e:	dce080e7          	jalr	-562(ra) # 8e8 <vprintf>
}
 b22:	60e2                	ld	ra,24(sp)
 b24:	6442                	ld	s0,16(sp)
 b26:	6125                	addi	sp,sp,96
 b28:	8082                	ret

0000000000000b2a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b2a:	1141                	addi	sp,sp,-16
 b2c:	e422                	sd	s0,8(sp)
 b2e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b30:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b34:	00000797          	auipc	a5,0x0
 b38:	4d47b783          	ld	a5,1236(a5) # 1008 <freep>
 b3c:	a805                	j	b6c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b3e:	4618                	lw	a4,8(a2)
 b40:	9db9                	addw	a1,a1,a4
 b42:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b46:	6398                	ld	a4,0(a5)
 b48:	6318                	ld	a4,0(a4)
 b4a:	fee53823          	sd	a4,-16(a0)
 b4e:	a091                	j	b92 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b50:	ff852703          	lw	a4,-8(a0)
 b54:	9e39                	addw	a2,a2,a4
 b56:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 b58:	ff053703          	ld	a4,-16(a0)
 b5c:	e398                	sd	a4,0(a5)
 b5e:	a099                	j	ba4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b60:	6398                	ld	a4,0(a5)
 b62:	00e7e463          	bltu	a5,a4,b6a <free+0x40>
 b66:	00e6ea63          	bltu	a3,a4,b7a <free+0x50>
{
 b6a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b6c:	fed7fae3          	bgeu	a5,a3,b60 <free+0x36>
 b70:	6398                	ld	a4,0(a5)
 b72:	00e6e463          	bltu	a3,a4,b7a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b76:	fee7eae3          	bltu	a5,a4,b6a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b7a:	ff852583          	lw	a1,-8(a0)
 b7e:	6390                	ld	a2,0(a5)
 b80:	02059713          	slli	a4,a1,0x20
 b84:	9301                	srli	a4,a4,0x20
 b86:	0712                	slli	a4,a4,0x4
 b88:	9736                	add	a4,a4,a3
 b8a:	fae60ae3          	beq	a2,a4,b3e <free+0x14>
    bp->s.ptr = p->s.ptr;
 b8e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b92:	4790                	lw	a2,8(a5)
 b94:	02061713          	slli	a4,a2,0x20
 b98:	9301                	srli	a4,a4,0x20
 b9a:	0712                	slli	a4,a4,0x4
 b9c:	973e                	add	a4,a4,a5
 b9e:	fae689e3          	beq	a3,a4,b50 <free+0x26>
  } else
    p->s.ptr = bp;
 ba2:	e394                	sd	a3,0(a5)
  freep = p;
 ba4:	00000717          	auipc	a4,0x0
 ba8:	46f73223          	sd	a5,1124(a4) # 1008 <freep>
}
 bac:	6422                	ld	s0,8(sp)
 bae:	0141                	addi	sp,sp,16
 bb0:	8082                	ret

0000000000000bb2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 bb2:	7139                	addi	sp,sp,-64
 bb4:	fc06                	sd	ra,56(sp)
 bb6:	f822                	sd	s0,48(sp)
 bb8:	f426                	sd	s1,40(sp)
 bba:	f04a                	sd	s2,32(sp)
 bbc:	ec4e                	sd	s3,24(sp)
 bbe:	e852                	sd	s4,16(sp)
 bc0:	e456                	sd	s5,8(sp)
 bc2:	e05a                	sd	s6,0(sp)
 bc4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bc6:	02051493          	slli	s1,a0,0x20
 bca:	9081                	srli	s1,s1,0x20
 bcc:	04bd                	addi	s1,s1,15
 bce:	8091                	srli	s1,s1,0x4
 bd0:	0014899b          	addiw	s3,s1,1
 bd4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 bd6:	00000517          	auipc	a0,0x0
 bda:	43253503          	ld	a0,1074(a0) # 1008 <freep>
 bde:	c515                	beqz	a0,c0a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 be0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 be2:	4798                	lw	a4,8(a5)
 be4:	02977f63          	bgeu	a4,s1,c22 <malloc+0x70>
 be8:	8a4e                	mv	s4,s3
 bea:	0009871b          	sext.w	a4,s3
 bee:	6685                	lui	a3,0x1
 bf0:	00d77363          	bgeu	a4,a3,bf6 <malloc+0x44>
 bf4:	6a05                	lui	s4,0x1
 bf6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bfa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bfe:	00000917          	auipc	s2,0x0
 c02:	40a90913          	addi	s2,s2,1034 # 1008 <freep>
  if(p == (char*)-1)
 c06:	5afd                	li	s5,-1
 c08:	a88d                	j	c7a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 c0a:	00004797          	auipc	a5,0x4
 c0e:	40678793          	addi	a5,a5,1030 # 5010 <base>
 c12:	00000717          	auipc	a4,0x0
 c16:	3ef73b23          	sd	a5,1014(a4) # 1008 <freep>
 c1a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c1c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c20:	b7e1                	j	be8 <malloc+0x36>
      if(p->s.size == nunits)
 c22:	02e48b63          	beq	s1,a4,c58 <malloc+0xa6>
        p->s.size -= nunits;
 c26:	4137073b          	subw	a4,a4,s3
 c2a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c2c:	1702                	slli	a4,a4,0x20
 c2e:	9301                	srli	a4,a4,0x20
 c30:	0712                	slli	a4,a4,0x4
 c32:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c34:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c38:	00000717          	auipc	a4,0x0
 c3c:	3ca73823          	sd	a0,976(a4) # 1008 <freep>
      return (void*)(p + 1);
 c40:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c44:	70e2                	ld	ra,56(sp)
 c46:	7442                	ld	s0,48(sp)
 c48:	74a2                	ld	s1,40(sp)
 c4a:	7902                	ld	s2,32(sp)
 c4c:	69e2                	ld	s3,24(sp)
 c4e:	6a42                	ld	s4,16(sp)
 c50:	6aa2                	ld	s5,8(sp)
 c52:	6b02                	ld	s6,0(sp)
 c54:	6121                	addi	sp,sp,64
 c56:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c58:	6398                	ld	a4,0(a5)
 c5a:	e118                	sd	a4,0(a0)
 c5c:	bff1                	j	c38 <malloc+0x86>
  hp->s.size = nu;
 c5e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c62:	0541                	addi	a0,a0,16
 c64:	00000097          	auipc	ra,0x0
 c68:	ec6080e7          	jalr	-314(ra) # b2a <free>
  return freep;
 c6c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c70:	d971                	beqz	a0,c44 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c72:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c74:	4798                	lw	a4,8(a5)
 c76:	fa9776e3          	bgeu	a4,s1,c22 <malloc+0x70>
    if(p == freep)
 c7a:	00093703          	ld	a4,0(s2)
 c7e:	853e                	mv	a0,a5
 c80:	fef719e3          	bne	a4,a5,c72 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 c84:	8552                	mv	a0,s4
 c86:	00000097          	auipc	ra,0x0
 c8a:	b66080e7          	jalr	-1178(ra) # 7ec <sbrk>
  if(p == (char*)-1)
 c8e:	fd5518e3          	bne	a0,s5,c5e <malloc+0xac>
        return 0;
 c92:	4501                	li	a0,0
 c94:	bf45                	j	c44 <malloc+0x92>
