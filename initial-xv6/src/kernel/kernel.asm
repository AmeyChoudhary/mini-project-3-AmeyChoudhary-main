
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	b1010113          	addi	sp,sp,-1264 # 80008b10 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	97e70713          	addi	a4,a4,-1666 # 800089d0 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	3dc78793          	addi	a5,a5,988 # 80006440 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdbbfa7>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	f0278793          	addi	a5,a5,-254 # 80000fb0 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	786080e7          	jalr	1926(ra) # 800028b2 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	794080e7          	jalr	1940(ra) # 800008d0 <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	98450513          	addi	a0,a0,-1660 # 80010b10 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	b72080e7          	jalr	-1166(ra) # 80000d06 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	97448493          	addi	s1,s1,-1676 # 80010b10 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	a0290913          	addi	s2,s2,-1534 # 80010ba8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405b63          	blez	s4,8000022a <consoleread+0xc6>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71763          	bne	a4,a5,800001ee <consoleread+0x8a>
      if(killed(myproc())){
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	a44080e7          	jalr	-1468(ra) # 80001c08 <myproc>
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	530080e7          	jalr	1328(ra) # 800026fc <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	26e080e7          	jalr	622(ra) # 80002448 <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fcf70de3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	0017871b          	addiw	a4,a5,1
    800001f2:	08e4ac23          	sw	a4,152(s1)
    800001f6:	07f7f713          	andi	a4,a5,127
    800001fa:	9726                	add	a4,a4,s1
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000204:	079c0663          	beq	s8,s9,80000270 <consoleread+0x10c>
    cbuf = c;
    80000208:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020c:	4685                	li	a3,1
    8000020e:	f8f40613          	addi	a2,s0,-113
    80000212:	85d6                	mv	a1,s5
    80000214:	855a                	mv	a0,s6
    80000216:	00002097          	auipc	ra,0x2
    8000021a:	646080e7          	jalr	1606(ra) # 8000285c <either_copyout>
    8000021e:	01a50663          	beq	a0,s10,8000022a <consoleread+0xc6>
    dst++;
    80000222:	0a85                	addi	s5,s5,1
    --n;
    80000224:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000226:	f9bc17e3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	8e650513          	addi	a0,a0,-1818 # 80010b10 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	b88080e7          	jalr	-1144(ra) # 80000dba <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	8d050513          	addi	a0,a0,-1840 # 80010b10 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	b72080e7          	jalr	-1166(ra) # 80000dba <release>
        return -1;
    80000250:	557d                	li	a0,-1
}
    80000252:	70e6                	ld	ra,120(sp)
    80000254:	7446                	ld	s0,112(sp)
    80000256:	74a6                	ld	s1,104(sp)
    80000258:	7906                	ld	s2,96(sp)
    8000025a:	69e6                	ld	s3,88(sp)
    8000025c:	6a46                	ld	s4,80(sp)
    8000025e:	6aa6                	ld	s5,72(sp)
    80000260:	6b06                	ld	s6,64(sp)
    80000262:	7be2                	ld	s7,56(sp)
    80000264:	7c42                	ld	s8,48(sp)
    80000266:	7ca2                	ld	s9,40(sp)
    80000268:	7d02                	ld	s10,32(sp)
    8000026a:	6de2                	ld	s11,24(sp)
    8000026c:	6109                	addi	sp,sp,128
    8000026e:	8082                	ret
      if(n < target){
    80000270:	000a071b          	sext.w	a4,s4
    80000274:	fb777be3          	bgeu	a4,s7,8000022a <consoleread+0xc6>
        cons.r--;
    80000278:	00011717          	auipc	a4,0x11
    8000027c:	92f72823          	sw	a5,-1744(a4) # 80010ba8 <cons+0x98>
    80000280:	b76d                	j	8000022a <consoleread+0xc6>

0000000080000282 <consputc>:
{
    80000282:	1141                	addi	sp,sp,-16
    80000284:	e406                	sd	ra,8(sp)
    80000286:	e022                	sd	s0,0(sp)
    80000288:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028a:	10000793          	li	a5,256
    8000028e:	00f50a63          	beq	a0,a5,800002a2 <consputc+0x20>
    uartputc_sync(c);
    80000292:	00000097          	auipc	ra,0x0
    80000296:	564080e7          	jalr	1380(ra) # 800007f6 <uartputc_sync>
}
    8000029a:	60a2                	ld	ra,8(sp)
    8000029c:	6402                	ld	s0,0(sp)
    8000029e:	0141                	addi	sp,sp,16
    800002a0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a2:	4521                	li	a0,8
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	552080e7          	jalr	1362(ra) # 800007f6 <uartputc_sync>
    800002ac:	02000513          	li	a0,32
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	546080e7          	jalr	1350(ra) # 800007f6 <uartputc_sync>
    800002b8:	4521                	li	a0,8
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	53c080e7          	jalr	1340(ra) # 800007f6 <uartputc_sync>
    800002c2:	bfe1                	j	8000029a <consputc+0x18>

00000000800002c4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c4:	1101                	addi	sp,sp,-32
    800002c6:	ec06                	sd	ra,24(sp)
    800002c8:	e822                	sd	s0,16(sp)
    800002ca:	e426                	sd	s1,8(sp)
    800002cc:	e04a                	sd	s2,0(sp)
    800002ce:	1000                	addi	s0,sp,32
    800002d0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d2:	00011517          	auipc	a0,0x11
    800002d6:	83e50513          	addi	a0,a0,-1986 # 80010b10 <cons>
    800002da:	00001097          	auipc	ra,0x1
    800002de:	a2c080e7          	jalr	-1492(ra) # 80000d06 <acquire>

  switch(c){
    800002e2:	47d5                	li	a5,21
    800002e4:	0af48663          	beq	s1,a5,80000390 <consoleintr+0xcc>
    800002e8:	0297ca63          	blt	a5,s1,8000031c <consoleintr+0x58>
    800002ec:	47a1                	li	a5,8
    800002ee:	0ef48763          	beq	s1,a5,800003dc <consoleintr+0x118>
    800002f2:	47c1                	li	a5,16
    800002f4:	10f49a63          	bne	s1,a5,80000408 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f8:	00002097          	auipc	ra,0x2
    800002fc:	610080e7          	jalr	1552(ra) # 80002908 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	81050513          	addi	a0,a0,-2032 # 80010b10 <cons>
    80000308:	00001097          	auipc	ra,0x1
    8000030c:	ab2080e7          	jalr	-1358(ra) # 80000dba <release>
}
    80000310:	60e2                	ld	ra,24(sp)
    80000312:	6442                	ld	s0,16(sp)
    80000314:	64a2                	ld	s1,8(sp)
    80000316:	6902                	ld	s2,0(sp)
    80000318:	6105                	addi	sp,sp,32
    8000031a:	8082                	ret
  switch(c){
    8000031c:	07f00793          	li	a5,127
    80000320:	0af48e63          	beq	s1,a5,800003dc <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000324:	00010717          	auipc	a4,0x10
    80000328:	7ec70713          	addi	a4,a4,2028 # 80010b10 <cons>
    8000032c:	0a072783          	lw	a5,160(a4)
    80000330:	09872703          	lw	a4,152(a4)
    80000334:	9f99                	subw	a5,a5,a4
    80000336:	07f00713          	li	a4,127
    8000033a:	fcf763e3          	bltu	a4,a5,80000300 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033e:	47b5                	li	a5,13
    80000340:	0cf48763          	beq	s1,a5,8000040e <consoleintr+0x14a>
      consputc(c);
    80000344:	8526                	mv	a0,s1
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	f3c080e7          	jalr	-196(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000034e:	00010797          	auipc	a5,0x10
    80000352:	7c278793          	addi	a5,a5,1986 # 80010b10 <cons>
    80000356:	0a07a683          	lw	a3,160(a5)
    8000035a:	0016871b          	addiw	a4,a3,1
    8000035e:	0007061b          	sext.w	a2,a4
    80000362:	0ae7a023          	sw	a4,160(a5)
    80000366:	07f6f693          	andi	a3,a3,127
    8000036a:	97b6                	add	a5,a5,a3
    8000036c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000370:	47a9                	li	a5,10
    80000372:	0cf48563          	beq	s1,a5,8000043c <consoleintr+0x178>
    80000376:	4791                	li	a5,4
    80000378:	0cf48263          	beq	s1,a5,8000043c <consoleintr+0x178>
    8000037c:	00011797          	auipc	a5,0x11
    80000380:	82c7a783          	lw	a5,-2004(a5) # 80010ba8 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00010717          	auipc	a4,0x10
    80000394:	78070713          	addi	a4,a4,1920 # 80010b10 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00010497          	auipc	s1,0x10
    800003a4:	77048493          	addi	s1,s1,1904 # 80010b10 <cons>
    while(cons.e != cons.w &&
    800003a8:	4929                	li	s2,10
    800003aa:	f4f70be3          	beq	a4,a5,80000300 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003ae:	37fd                	addiw	a5,a5,-1
    800003b0:	07f7f713          	andi	a4,a5,127
    800003b4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b6:	01874703          	lbu	a4,24(a4)
    800003ba:	f52703e3          	beq	a4,s2,80000300 <consoleintr+0x3c>
      cons.e--;
    800003be:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c2:	10000513          	li	a0,256
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	ebc080e7          	jalr	-324(ra) # 80000282 <consputc>
    while(cons.e != cons.w &&
    800003ce:	0a04a783          	lw	a5,160(s1)
    800003d2:	09c4a703          	lw	a4,156(s1)
    800003d6:	fcf71ce3          	bne	a4,a5,800003ae <consoleintr+0xea>
    800003da:	b71d                	j	80000300 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003dc:	00010717          	auipc	a4,0x10
    800003e0:	73470713          	addi	a4,a4,1844 # 80010b10 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00010717          	auipc	a4,0x10
    800003f6:	7af72f23          	sw	a5,1982(a4) # 80010bb0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fa:	10000513          	li	a0,256
    800003fe:	00000097          	auipc	ra,0x0
    80000402:	e84080e7          	jalr	-380(ra) # 80000282 <consputc>
    80000406:	bded                	j	80000300 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000408:	ee048ce3          	beqz	s1,80000300 <consoleintr+0x3c>
    8000040c:	bf21                	j	80000324 <consoleintr+0x60>
      consputc(c);
    8000040e:	4529                	li	a0,10
    80000410:	00000097          	auipc	ra,0x0
    80000414:	e72080e7          	jalr	-398(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000418:	00010797          	auipc	a5,0x10
    8000041c:	6f878793          	addi	a5,a5,1784 # 80010b10 <cons>
    80000420:	0a07a703          	lw	a4,160(a5)
    80000424:	0017069b          	addiw	a3,a4,1
    80000428:	0006861b          	sext.w	a2,a3
    8000042c:	0ad7a023          	sw	a3,160(a5)
    80000430:	07f77713          	andi	a4,a4,127
    80000434:	97ba                	add	a5,a5,a4
    80000436:	4729                	li	a4,10
    80000438:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043c:	00010797          	auipc	a5,0x10
    80000440:	76c7a823          	sw	a2,1904(a5) # 80010bac <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00010517          	auipc	a0,0x10
    80000448:	76450513          	addi	a0,a0,1892 # 80010ba8 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	060080e7          	jalr	96(ra) # 800024ac <wakeup>
    80000454:	b575                	j	80000300 <consoleintr+0x3c>

0000000080000456 <consoleinit>:

void
consoleinit(void)
{
    80000456:	1141                	addi	sp,sp,-16
    80000458:	e406                	sd	ra,8(sp)
    8000045a:	e022                	sd	s0,0(sp)
    8000045c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <etext+0x10>
    80000466:	00010517          	auipc	a0,0x10
    8000046a:	6aa50513          	addi	a0,a0,1706 # 80010b10 <cons>
    8000046e:	00001097          	auipc	ra,0x1
    80000472:	808080e7          	jalr	-2040(ra) # 80000c76 <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00241797          	auipc	a5,0x241
    80000482:	24278793          	addi	a5,a5,578 # 802416c0 <devsw>
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	cde70713          	addi	a4,a4,-802 # 80000164 <consoleread>
    8000048e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000490:	00000717          	auipc	a4,0x0
    80000494:	c7270713          	addi	a4,a4,-910 # 80000102 <consolewrite>
    80000498:	ef98                	sd	a4,24(a5)
}
    8000049a:	60a2                	ld	ra,8(sp)
    8000049c:	6402                	ld	s0,0(sp)
    8000049e:	0141                	addi	sp,sp,16
    800004a0:	8082                	ret

00000000800004a2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a2:	7179                	addi	sp,sp,-48
    800004a4:	f406                	sd	ra,40(sp)
    800004a6:	f022                	sd	s0,32(sp)
    800004a8:	ec26                	sd	s1,24(sp)
    800004aa:	e84a                	sd	s2,16(sp)
    800004ac:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ae:	c219                	beqz	a2,800004b4 <printint+0x12>
    800004b0:	08054663          	bltz	a0,8000053c <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b4:	2501                	sext.w	a0,a0
    800004b6:	4881                	li	a7,0
    800004b8:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004bc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004be:	2581                	sext.w	a1,a1
    800004c0:	00008617          	auipc	a2,0x8
    800004c4:	b8060613          	addi	a2,a2,-1152 # 80008040 <digits>
    800004c8:	883a                	mv	a6,a4
    800004ca:	2705                	addiw	a4,a4,1
    800004cc:	02b577bb          	remuw	a5,a0,a1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	97b2                	add	a5,a5,a2
    800004d6:	0007c783          	lbu	a5,0(a5)
    800004da:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004de:	0005079b          	sext.w	a5,a0
    800004e2:	02b5553b          	divuw	a0,a0,a1
    800004e6:	0685                	addi	a3,a3,1
    800004e8:	feb7f0e3          	bgeu	a5,a1,800004c8 <printint+0x26>

  if(sign)
    800004ec:	00088b63          	beqz	a7,80000502 <printint+0x60>
    buf[i++] = '-';
    800004f0:	fe040793          	addi	a5,s0,-32
    800004f4:	973e                	add	a4,a4,a5
    800004f6:	02d00793          	li	a5,45
    800004fa:	fef70823          	sb	a5,-16(a4)
    800004fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000502:	02e05763          	blez	a4,80000530 <printint+0x8e>
    80000506:	fd040793          	addi	a5,s0,-48
    8000050a:	00e784b3          	add	s1,a5,a4
    8000050e:	fff78913          	addi	s2,a5,-1
    80000512:	993a                	add	s2,s2,a4
    80000514:	377d                	addiw	a4,a4,-1
    80000516:	1702                	slli	a4,a4,0x20
    80000518:	9301                	srli	a4,a4,0x20
    8000051a:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051e:	fff4c503          	lbu	a0,-1(s1)
    80000522:	00000097          	auipc	ra,0x0
    80000526:	d60080e7          	jalr	-672(ra) # 80000282 <consputc>
  while(--i >= 0)
    8000052a:	14fd                	addi	s1,s1,-1
    8000052c:	ff2499e3          	bne	s1,s2,8000051e <printint+0x7c>
}
    80000530:	70a2                	ld	ra,40(sp)
    80000532:	7402                	ld	s0,32(sp)
    80000534:	64e2                	ld	s1,24(sp)
    80000536:	6942                	ld	s2,16(sp)
    80000538:	6145                	addi	sp,sp,48
    8000053a:	8082                	ret
    x = -xx;
    8000053c:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000540:	4885                	li	a7,1
    x = -xx;
    80000542:	bf9d                	j	800004b8 <printint+0x16>

0000000080000544 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000544:	1101                	addi	sp,sp,-32
    80000546:	ec06                	sd	ra,24(sp)
    80000548:	e822                	sd	s0,16(sp)
    8000054a:	e426                	sd	s1,8(sp)
    8000054c:	1000                	addi	s0,sp,32
    8000054e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000550:	00010797          	auipc	a5,0x10
    80000554:	6807a023          	sw	zero,1664(a5) # 80010bd0 <pr+0x18>
  printf("panic: ");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	ac050513          	addi	a0,a0,-1344 # 80008018 <etext+0x18>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	02e080e7          	jalr	46(ra) # 8000058e <printf>
  printf(s);
    80000568:	8526                	mv	a0,s1
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	024080e7          	jalr	36(ra) # 8000058e <printf>
  printf("\n");
    80000572:	00008517          	auipc	a0,0x8
    80000576:	b7e50513          	addi	a0,a0,-1154 # 800080f0 <digits+0xb0>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	014080e7          	jalr	20(ra) # 8000058e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000582:	4785                	li	a5,1
    80000584:	00008717          	auipc	a4,0x8
    80000588:	40f72623          	sw	a5,1036(a4) # 80008990 <panicked>
  for(;;)
    8000058c:	a001                	j	8000058c <panic+0x48>

000000008000058e <printf>:
{
    8000058e:	7131                	addi	sp,sp,-192
    80000590:	fc86                	sd	ra,120(sp)
    80000592:	f8a2                	sd	s0,112(sp)
    80000594:	f4a6                	sd	s1,104(sp)
    80000596:	f0ca                	sd	s2,96(sp)
    80000598:	ecce                	sd	s3,88(sp)
    8000059a:	e8d2                	sd	s4,80(sp)
    8000059c:	e4d6                	sd	s5,72(sp)
    8000059e:	e0da                	sd	s6,64(sp)
    800005a0:	fc5e                	sd	s7,56(sp)
    800005a2:	f862                	sd	s8,48(sp)
    800005a4:	f466                	sd	s9,40(sp)
    800005a6:	f06a                	sd	s10,32(sp)
    800005a8:	ec6e                	sd	s11,24(sp)
    800005aa:	0100                	addi	s0,sp,128
    800005ac:	8a2a                	mv	s4,a0
    800005ae:	e40c                	sd	a1,8(s0)
    800005b0:	e810                	sd	a2,16(s0)
    800005b2:	ec14                	sd	a3,24(s0)
    800005b4:	f018                	sd	a4,32(s0)
    800005b6:	f41c                	sd	a5,40(s0)
    800005b8:	03043823          	sd	a6,48(s0)
    800005bc:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c0:	00010d97          	auipc	s11,0x10
    800005c4:	610dad83          	lw	s11,1552(s11) # 80010bd0 <pr+0x18>
  if(locking)
    800005c8:	020d9b63          	bnez	s11,800005fe <printf+0x70>
  if (fmt == 0)
    800005cc:	040a0263          	beqz	s4,80000610 <printf+0x82>
  va_start(ap, fmt);
    800005d0:	00840793          	addi	a5,s0,8
    800005d4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d8:	000a4503          	lbu	a0,0(s4)
    800005dc:	16050263          	beqz	a0,80000740 <printf+0x1b2>
    800005e0:	4481                	li	s1,0
    if(c != '%'){
    800005e2:	02500a93          	li	s5,37
    switch(c){
    800005e6:	07000b13          	li	s6,112
  consputc('x');
    800005ea:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ec:	00008b97          	auipc	s7,0x8
    800005f0:	a54b8b93          	addi	s7,s7,-1452 # 80008040 <digits>
    switch(c){
    800005f4:	07300c93          	li	s9,115
    800005f8:	06400c13          	li	s8,100
    800005fc:	a82d                	j	80000636 <printf+0xa8>
    acquire(&pr.lock);
    800005fe:	00010517          	auipc	a0,0x10
    80000602:	5ba50513          	addi	a0,a0,1466 # 80010bb8 <pr>
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	700080e7          	jalr	1792(ra) # 80000d06 <acquire>
    8000060e:	bf7d                	j	800005cc <printf+0x3e>
    panic("null fmt");
    80000610:	00008517          	auipc	a0,0x8
    80000614:	a1850513          	addi	a0,a0,-1512 # 80008028 <etext+0x28>
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	f2c080e7          	jalr	-212(ra) # 80000544 <panic>
      consputc(c);
    80000620:	00000097          	auipc	ra,0x0
    80000624:	c62080e7          	jalr	-926(ra) # 80000282 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000628:	2485                	addiw	s1,s1,1
    8000062a:	009a07b3          	add	a5,s4,s1
    8000062e:	0007c503          	lbu	a0,0(a5)
    80000632:	10050763          	beqz	a0,80000740 <printf+0x1b2>
    if(c != '%'){
    80000636:	ff5515e3          	bne	a0,s5,80000620 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063a:	2485                	addiw	s1,s1,1
    8000063c:	009a07b3          	add	a5,s4,s1
    80000640:	0007c783          	lbu	a5,0(a5)
    80000644:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000648:	cfe5                	beqz	a5,80000740 <printf+0x1b2>
    switch(c){
    8000064a:	05678a63          	beq	a5,s6,8000069e <printf+0x110>
    8000064e:	02fb7663          	bgeu	s6,a5,8000067a <printf+0xec>
    80000652:	09978963          	beq	a5,s9,800006e4 <printf+0x156>
    80000656:	07800713          	li	a4,120
    8000065a:	0ce79863          	bne	a5,a4,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4605                	li	a2,1
    8000066c:	85ea                	mv	a1,s10
    8000066e:	4388                	lw	a0,0(a5)
    80000670:	00000097          	auipc	ra,0x0
    80000674:	e32080e7          	jalr	-462(ra) # 800004a2 <printint>
      break;
    80000678:	bf45                	j	80000628 <printf+0x9a>
    switch(c){
    8000067a:	0b578263          	beq	a5,s5,8000071e <printf+0x190>
    8000067e:	0b879663          	bne	a5,s8,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4605                	li	a2,1
    80000690:	45a9                	li	a1,10
    80000692:	4388                	lw	a0,0(a5)
    80000694:	00000097          	auipc	ra,0x0
    80000698:	e0e080e7          	jalr	-498(ra) # 800004a2 <printint>
      break;
    8000069c:	b771                	j	80000628 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006ae:	03000513          	li	a0,48
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bd0080e7          	jalr	-1072(ra) # 80000282 <consputc>
  consputc('x');
    800006ba:	07800513          	li	a0,120
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bc4080e7          	jalr	-1084(ra) # 80000282 <consputc>
    800006c6:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c8:	03c9d793          	srli	a5,s3,0x3c
    800006cc:	97de                	add	a5,a5,s7
    800006ce:	0007c503          	lbu	a0,0(a5)
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	bb0080e7          	jalr	-1104(ra) # 80000282 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006da:	0992                	slli	s3,s3,0x4
    800006dc:	397d                	addiw	s2,s2,-1
    800006de:	fe0915e3          	bnez	s2,800006c8 <printf+0x13a>
    800006e2:	b799                	j	80000628 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e4:	f8843783          	ld	a5,-120(s0)
    800006e8:	00878713          	addi	a4,a5,8
    800006ec:	f8e43423          	sd	a4,-120(s0)
    800006f0:	0007b903          	ld	s2,0(a5)
    800006f4:	00090e63          	beqz	s2,80000710 <printf+0x182>
      for(; *s; s++)
    800006f8:	00094503          	lbu	a0,0(s2)
    800006fc:	d515                	beqz	a0,80000628 <printf+0x9a>
        consputc(*s);
    800006fe:	00000097          	auipc	ra,0x0
    80000702:	b84080e7          	jalr	-1148(ra) # 80000282 <consputc>
      for(; *s; s++)
    80000706:	0905                	addi	s2,s2,1
    80000708:	00094503          	lbu	a0,0(s2)
    8000070c:	f96d                	bnez	a0,800006fe <printf+0x170>
    8000070e:	bf29                	j	80000628 <printf+0x9a>
        s = "(null)";
    80000710:	00008917          	auipc	s2,0x8
    80000714:	91090913          	addi	s2,s2,-1776 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000718:	02800513          	li	a0,40
    8000071c:	b7cd                	j	800006fe <printf+0x170>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b62080e7          	jalr	-1182(ra) # 80000282 <consputc>
      break;
    80000728:	b701                	j	80000628 <printf+0x9a>
      consputc('%');
    8000072a:	8556                	mv	a0,s5
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b56080e7          	jalr	-1194(ra) # 80000282 <consputc>
      consputc(c);
    80000734:	854a                	mv	a0,s2
    80000736:	00000097          	auipc	ra,0x0
    8000073a:	b4c080e7          	jalr	-1204(ra) # 80000282 <consputc>
      break;
    8000073e:	b5ed                	j	80000628 <printf+0x9a>
  if(locking)
    80000740:	020d9163          	bnez	s11,80000762 <printf+0x1d4>
}
    80000744:	70e6                	ld	ra,120(sp)
    80000746:	7446                	ld	s0,112(sp)
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	7906                	ld	s2,96(sp)
    8000074c:	69e6                	ld	s3,88(sp)
    8000074e:	6a46                	ld	s4,80(sp)
    80000750:	6aa6                	ld	s5,72(sp)
    80000752:	6b06                	ld	s6,64(sp)
    80000754:	7be2                	ld	s7,56(sp)
    80000756:	7c42                	ld	s8,48(sp)
    80000758:	7ca2                	ld	s9,40(sp)
    8000075a:	7d02                	ld	s10,32(sp)
    8000075c:	6de2                	ld	s11,24(sp)
    8000075e:	6129                	addi	sp,sp,192
    80000760:	8082                	ret
    release(&pr.lock);
    80000762:	00010517          	auipc	a0,0x10
    80000766:	45650513          	addi	a0,a0,1110 # 80010bb8 <pr>
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	650080e7          	jalr	1616(ra) # 80000dba <release>
}
    80000772:	bfc9                	j	80000744 <printf+0x1b6>

0000000080000774 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000774:	1101                	addi	sp,sp,-32
    80000776:	ec06                	sd	ra,24(sp)
    80000778:	e822                	sd	s0,16(sp)
    8000077a:	e426                	sd	s1,8(sp)
    8000077c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077e:	00010497          	auipc	s1,0x10
    80000782:	43a48493          	addi	s1,s1,1082 # 80010bb8 <pr>
    80000786:	00008597          	auipc	a1,0x8
    8000078a:	8b258593          	addi	a1,a1,-1870 # 80008038 <etext+0x38>
    8000078e:	8526                	mv	a0,s1
    80000790:	00000097          	auipc	ra,0x0
    80000794:	4e6080e7          	jalr	1254(ra) # 80000c76 <initlock>
  pr.locking = 1;
    80000798:	4785                	li	a5,1
    8000079a:	cc9c                	sw	a5,24(s1)
}
    8000079c:	60e2                	ld	ra,24(sp)
    8000079e:	6442                	ld	s0,16(sp)
    800007a0:	64a2                	ld	s1,8(sp)
    800007a2:	6105                	addi	sp,sp,32
    800007a4:	8082                	ret

00000000800007a6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a6:	1141                	addi	sp,sp,-16
    800007a8:	e406                	sd	ra,8(sp)
    800007aa:	e022                	sd	s0,0(sp)
    800007ac:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ae:	100007b7          	lui	a5,0x10000
    800007b2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b6:	f8000713          	li	a4,-128
    800007ba:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007be:	470d                	li	a4,3
    800007c0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007cc:	469d                	li	a3,7
    800007ce:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	88258593          	addi	a1,a1,-1918 # 80008058 <digits+0x18>
    800007de:	00010517          	auipc	a0,0x10
    800007e2:	3fa50513          	addi	a0,a0,1018 # 80010bd8 <uart_tx_lock>
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	490080e7          	jalr	1168(ra) # 80000c76 <initlock>
}
    800007ee:	60a2                	ld	ra,8(sp)
    800007f0:	6402                	ld	s0,0(sp)
    800007f2:	0141                	addi	sp,sp,16
    800007f4:	8082                	ret

00000000800007f6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f6:	1101                	addi	sp,sp,-32
    800007f8:	ec06                	sd	ra,24(sp)
    800007fa:	e822                	sd	s0,16(sp)
    800007fc:	e426                	sd	s1,8(sp)
    800007fe:	1000                	addi	s0,sp,32
    80000800:	84aa                	mv	s1,a0
  push_off();
    80000802:	00000097          	auipc	ra,0x0
    80000806:	4b8080e7          	jalr	1208(ra) # 80000cba <push_off>

  if(panicked){
    8000080a:	00008797          	auipc	a5,0x8
    8000080e:	1867a783          	lw	a5,390(a5) # 80008990 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	10000737          	lui	a4,0x10000
  if(panicked){
    80000816:	c391                	beqz	a5,8000081a <uartputc_sync+0x24>
    for(;;)
    80000818:	a001                	j	80000818 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000081e:	0ff7f793          	andi	a5,a5,255
    80000822:	0207f793          	andi	a5,a5,32
    80000826:	dbf5                	beqz	a5,8000081a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000828:	0ff4f793          	andi	a5,s1,255
    8000082c:	10000737          	lui	a4,0x10000
    80000830:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000834:	00000097          	auipc	ra,0x0
    80000838:	526080e7          	jalr	1318(ra) # 80000d5a <pop_off>
}
    8000083c:	60e2                	ld	ra,24(sp)
    8000083e:	6442                	ld	s0,16(sp)
    80000840:	64a2                	ld	s1,8(sp)
    80000842:	6105                	addi	sp,sp,32
    80000844:	8082                	ret

0000000080000846 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000846:	00008717          	auipc	a4,0x8
    8000084a:	15273703          	ld	a4,338(a4) # 80008998 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	1527b783          	ld	a5,338(a5) # 800089a0 <uart_tx_w>
    80000856:	06e78c63          	beq	a5,a4,800008ce <uartstart+0x88>
{
    8000085a:	7139                	addi	sp,sp,-64
    8000085c:	fc06                	sd	ra,56(sp)
    8000085e:	f822                	sd	s0,48(sp)
    80000860:	f426                	sd	s1,40(sp)
    80000862:	f04a                	sd	s2,32(sp)
    80000864:	ec4e                	sd	s3,24(sp)
    80000866:	e852                	sd	s4,16(sp)
    80000868:	e456                	sd	s5,8(sp)
    8000086a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000086c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000870:	00010a17          	auipc	s4,0x10
    80000874:	368a0a13          	addi	s4,s4,872 # 80010bd8 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	12048493          	addi	s1,s1,288 # 80008998 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	12098993          	addi	s3,s3,288 # 800089a0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000888:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000088c:	0ff7f793          	andi	a5,a5,255
    80000890:	0207f793          	andi	a5,a5,32
    80000894:	c785                	beqz	a5,800008bc <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000896:	01f77793          	andi	a5,a4,31
    8000089a:	97d2                	add	a5,a5,s4
    8000089c:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800008a0:	0705                	addi	a4,a4,1
    800008a2:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	c06080e7          	jalr	-1018(ra) # 800024ac <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	6098                	ld	a4,0(s1)
    800008b4:	0009b783          	ld	a5,0(s3)
    800008b8:	fce798e3          	bne	a5,a4,80000888 <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	2f650513          	addi	a0,a0,758 # 80010bd8 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	41c080e7          	jalr	1052(ra) # 80000d06 <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	09e7a783          	lw	a5,158(a5) # 80008990 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	0a47b783          	ld	a5,164(a5) # 800089a0 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	09473703          	ld	a4,148(a4) # 80008998 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	2c8a0a13          	addi	s4,s4,712 # 80010bd8 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	08048493          	addi	s1,s1,128 # 80008998 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	08090913          	addi	s2,s2,128 # 800089a0 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	b18080e7          	jalr	-1256(ra) # 80002448 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	29248493          	addi	s1,s1,658 # 80010bd8 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	04f73323          	sd	a5,70(a4) # 800089a0 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee4080e7          	jalr	-284(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	44e080e7          	jalr	1102(ra) # 80000dba <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb91                	beqz	a5,800009aa <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009a0:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009a4:	6422                	ld	s0,8(sp)
    800009a6:	0141                	addi	sp,sp,16
    800009a8:	8082                	ret
    return -1;
    800009aa:	557d                	li	a0,-1
    800009ac:	bfe5                	j	800009a4 <uartgetc+0x1e>

00000000800009ae <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ae:	1101                	addi	sp,sp,-32
    800009b0:	ec06                	sd	ra,24(sp)
    800009b2:	e822                	sd	s0,16(sp)
    800009b4:	e426                	sd	s1,8(sp)
    800009b6:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b8:	54fd                	li	s1,-1
    int c = uartgetc();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	fcc080e7          	jalr	-52(ra) # 80000986 <uartgetc>
    if(c == -1)
    800009c2:	00950763          	beq	a0,s1,800009d0 <uartintr+0x22>
      break;
    consoleintr(c);
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	8fe080e7          	jalr	-1794(ra) # 800002c4 <consoleintr>
  while(1){
    800009ce:	b7f5                	j	800009ba <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009d0:	00010497          	auipc	s1,0x10
    800009d4:	20848493          	addi	s1,s1,520 # 80010bd8 <uart_tx_lock>
    800009d8:	8526                	mv	a0,s1
    800009da:	00000097          	auipc	ra,0x0
    800009de:	32c080e7          	jalr	812(ra) # 80000d06 <acquire>
  uartstart();
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	e64080e7          	jalr	-412(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    800009ea:	8526                	mv	a0,s1
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	3ce080e7          	jalr	974(ra) # 80000dba <release>
}
    800009f4:	60e2                	ld	ra,24(sp)
    800009f6:	6442                	ld	s0,16(sp)
    800009f8:	64a2                	ld	s1,8(sp)
    800009fa:	6105                	addi	sp,sp,32
    800009fc:	8082                	ret

00000000800009fe <check_and_increment>:
// for COW
int temp[TEMP];
struct spinlock temp_lock;

void check_and_increment(uint64 pno)
{
    800009fe:	1101                	addi	sp,sp,-32
    80000a00:	ec06                	sd	ra,24(sp)
    80000a02:	e822                	sd	s0,16(sp)
    80000a04:	e426                	sd	s1,8(sp)
    80000a06:	e04a                	sd	s2,0(sp)
    80000a08:	1000                	addi	s0,sp,32

  if (temp[pno] < 0)
    80000a0a:	00251713          	slli	a4,a0,0x2
    80000a0e:	00010797          	auipc	a5,0x10
    80000a12:	23a78793          	addi	a5,a5,570 # 80010c48 <temp>
    80000a16:	97ba                	add	a5,a5,a4
    80000a18:	439c                	lw	a5,0(a5)
    80000a1a:	0407c063          	bltz	a5,80000a5a <check_and_increment+0x5c>
    80000a1e:	84aa                	mv	s1,a0
  {
    panic("Increment problem");
  }
  else
  {
    acquire(&temp_lock);
    80000a20:	00010917          	auipc	s2,0x10
    80000a24:	1f090913          	addi	s2,s2,496 # 80010c10 <temp_lock>
    80000a28:	854a                	mv	a0,s2
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	2dc080e7          	jalr	732(ra) # 80000d06 <acquire>
    temp[pno]++;
    80000a32:	048a                	slli	s1,s1,0x2
    80000a34:	00010517          	auipc	a0,0x10
    80000a38:	21450513          	addi	a0,a0,532 # 80010c48 <temp>
    80000a3c:	94aa                	add	s1,s1,a0
    80000a3e:	409c                	lw	a5,0(s1)
    80000a40:	2785                	addiw	a5,a5,1
    80000a42:	c09c                	sw	a5,0(s1)
    release(&temp_lock);
    80000a44:	854a                	mv	a0,s2
    80000a46:	00000097          	auipc	ra,0x0
    80000a4a:	374080e7          	jalr	884(ra) # 80000dba <release>
  }
}
    80000a4e:	60e2                	ld	ra,24(sp)
    80000a50:	6442                	ld	s0,16(sp)
    80000a52:	64a2                	ld	s1,8(sp)
    80000a54:	6902                	ld	s2,0(sp)
    80000a56:	6105                	addi	sp,sp,32
    80000a58:	8082                	ret
    panic("Increment problem");
    80000a5a:	00007517          	auipc	a0,0x7
    80000a5e:	60650513          	addi	a0,a0,1542 # 80008060 <digits+0x20>
    80000a62:	00000097          	auipc	ra,0x0
    80000a66:	ae2080e7          	jalr	-1310(ra) # 80000544 <panic>

0000000080000a6a <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000a6a:	7179                	addi	sp,sp,-48
    80000a6c:	f406                	sd	ra,40(sp)
    80000a6e:	f022                	sd	s0,32(sp)
    80000a70:	ec26                	sd	s1,24(sp)
    80000a72:	e84a                	sd	s2,16(sp)
    80000a74:	e44e                	sd	s3,8(sp)
    80000a76:	1800                	addi	s0,sp,48
    80000a78:	84aa                	mv	s1,a0

  // if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
  //   panic("kfree");

  // for COW
  acquire(&temp_lock);
    80000a7a:	00010517          	auipc	a0,0x10
    80000a7e:	19650513          	addi	a0,a0,406 # 80010c10 <temp_lock>
    80000a82:	00000097          	auipc	ra,0x0
    80000a86:	284080e7          	jalr	644(ra) # 80000d06 <acquire>
  uint64 pno = (uint64)pa / PGSIZE;
    80000a8a:	00c4d793          	srli	a5,s1,0xc
  int flag = temp[pno];
    80000a8e:	00279693          	slli	a3,a5,0x2
    80000a92:	00010717          	auipc	a4,0x10
    80000a96:	1b670713          	addi	a4,a4,438 # 80010c48 <temp>
    80000a9a:	9736                	add	a4,a4,a3
    80000a9c:	00072903          	lw	s2,0(a4)
  
  if (flag > 0)
    80000aa0:	03205d63          	blez	s2,80000ada <kfree+0x70>
  {
    temp[pno]--;
    80000aa4:	00010717          	auipc	a4,0x10
    80000aa8:	1a470713          	addi	a4,a4,420 # 80010c48 <temp>
    80000aac:	00d707b3          	add	a5,a4,a3
    80000ab0:	fff9071b          	addiw	a4,s2,-1
    80000ab4:	c398                	sw	a4,0(a5)
    release(&temp_lock);
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	15a50513          	addi	a0,a0,346 # 80010c10 <temp_lock>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	2fc080e7          	jalr	764(ra) # 80000dba <release>
    if (flag>1)
    80000ac6:	4785                	li	a5,1
    80000ac8:	0327d163          	bge	a5,s2,80000aea <kfree+0x80>

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
    80000acc:	70a2                	ld	ra,40(sp)
    80000ace:	7402                	ld	s0,32(sp)
    80000ad0:	64e2                	ld	s1,24(sp)
    80000ad2:	6942                	ld	s2,16(sp)
    80000ad4:	69a2                	ld	s3,8(sp)
    80000ad6:	6145                	addi	sp,sp,48
    80000ad8:	8082                	ret
    panic("Error");
    80000ada:	00007517          	auipc	a0,0x7
    80000ade:	59e50513          	addi	a0,a0,1438 # 80008078 <digits+0x38>
    80000ae2:	00000097          	auipc	ra,0x0
    80000ae6:	a62080e7          	jalr	-1438(ra) # 80000544 <panic>
  memset(pa, 1, PGSIZE);
    80000aea:	6605                	lui	a2,0x1
    80000aec:	4585                	li	a1,1
    80000aee:	8526                	mv	a0,s1
    80000af0:	00000097          	auipc	ra,0x0
    80000af4:	312080e7          	jalr	786(ra) # 80000e02 <memset>
  acquire(&kmem.lock);
    80000af8:	00010997          	auipc	s3,0x10
    80000afc:	11898993          	addi	s3,s3,280 # 80010c10 <temp_lock>
    80000b00:	00010917          	auipc	s2,0x10
    80000b04:	12890913          	addi	s2,s2,296 # 80010c28 <kmem>
    80000b08:	854a                	mv	a0,s2
    80000b0a:	00000097          	auipc	ra,0x0
    80000b0e:	1fc080e7          	jalr	508(ra) # 80000d06 <acquire>
  r->next = kmem.freelist;
    80000b12:	0309b783          	ld	a5,48(s3)
    80000b16:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000b18:	0299b823          	sd	s1,48(s3)
  release(&kmem.lock);
    80000b1c:	854a                	mv	a0,s2
    80000b1e:	00000097          	auipc	ra,0x0
    80000b22:	29c080e7          	jalr	668(ra) # 80000dba <release>
    80000b26:	b75d                	j	80000acc <kfree+0x62>

0000000080000b28 <freerange>:
{
    80000b28:	7179                	addi	sp,sp,-48
    80000b2a:	f406                	sd	ra,40(sp)
    80000b2c:	f022                	sd	s0,32(sp)
    80000b2e:	ec26                	sd	s1,24(sp)
    80000b30:	e84a                	sd	s2,16(sp)
    80000b32:	e44e                	sd	s3,8(sp)
    80000b34:	e052                	sd	s4,0(sp)
    80000b36:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000b38:	6785                	lui	a5,0x1
    80000b3a:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000b3e:	94aa                	add	s1,s1,a0
    80000b40:	757d                	lui	a0,0xfffff
    80000b42:	8ce9                	and	s1,s1,a0
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b44:	94be                	add	s1,s1,a5
    80000b46:	0095ee63          	bltu	a1,s1,80000b62 <freerange+0x3a>
    80000b4a:	892e                	mv	s2,a1
    kfree(p);
    80000b4c:	7a7d                	lui	s4,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b4e:	6985                	lui	s3,0x1
    kfree(p);
    80000b50:	01448533          	add	a0,s1,s4
    80000b54:	00000097          	auipc	ra,0x0
    80000b58:	f16080e7          	jalr	-234(ra) # 80000a6a <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b5c:	94ce                	add	s1,s1,s3
    80000b5e:	fe9979e3          	bgeu	s2,s1,80000b50 <freerange+0x28>
}
    80000b62:	70a2                	ld	ra,40(sp)
    80000b64:	7402                	ld	s0,32(sp)
    80000b66:	64e2                	ld	s1,24(sp)
    80000b68:	6942                	ld	s2,16(sp)
    80000b6a:	69a2                	ld	s3,8(sp)
    80000b6c:	6a02                	ld	s4,0(sp)
    80000b6e:	6145                	addi	sp,sp,48
    80000b70:	8082                	ret

0000000080000b72 <kinit>:
{
    80000b72:	1101                	addi	sp,sp,-32
    80000b74:	ec06                	sd	ra,24(sp)
    80000b76:	e822                	sd	s0,16(sp)
    80000b78:	e426                	sd	s1,8(sp)
    80000b7a:	1000                	addi	s0,sp,32
  initlock(&kmem.lock, "kmem");
    80000b7c:	00010497          	auipc	s1,0x10
    80000b80:	09448493          	addi	s1,s1,148 # 80010c10 <temp_lock>
    80000b84:	00007597          	auipc	a1,0x7
    80000b88:	4fc58593          	addi	a1,a1,1276 # 80008080 <digits+0x40>
    80000b8c:	00010517          	auipc	a0,0x10
    80000b90:	09c50513          	addi	a0,a0,156 # 80010c28 <kmem>
    80000b94:	00000097          	auipc	ra,0x0
    80000b98:	0e2080e7          	jalr	226(ra) # 80000c76 <initlock>
  initlock(&temp_lock, "temp_lock");
    80000b9c:	00007597          	auipc	a1,0x7
    80000ba0:	4ec58593          	addi	a1,a1,1260 # 80008088 <digits+0x48>
    80000ba4:	8526                	mv	a0,s1
    80000ba6:	00000097          	auipc	ra,0x0
    80000baa:	0d0080e7          	jalr	208(ra) # 80000c76 <initlock>
  acquire(&temp_lock);
    80000bae:	8526                	mv	a0,s1
    80000bb0:	00000097          	auipc	ra,0x0
    80000bb4:	156080e7          	jalr	342(ra) # 80000d06 <acquire>
  for (int i = 0; i < TEMP; i++)
    80000bb8:	00010797          	auipc	a5,0x10
    80000bbc:	09078793          	addi	a5,a5,144 # 80010c48 <temp>
    80000bc0:	00230697          	auipc	a3,0x230
    80000bc4:	08868693          	addi	a3,a3,136 # 80230c48 <pid_lock>
    temp[i] = 1;
    80000bc8:	4705                	li	a4,1
    80000bca:	c398                	sw	a4,0(a5)
  for (int i = 0; i < TEMP; i++)
    80000bcc:	0791                	addi	a5,a5,4
    80000bce:	fed79ee3          	bne	a5,a3,80000bca <kinit+0x58>
  release(&temp_lock);
    80000bd2:	00010517          	auipc	a0,0x10
    80000bd6:	03e50513          	addi	a0,a0,62 # 80010c10 <temp_lock>
    80000bda:	00000097          	auipc	ra,0x0
    80000bde:	1e0080e7          	jalr	480(ra) # 80000dba <release>
  freerange(end, (void *)PHYSTOP);
    80000be2:	45c5                	li	a1,17
    80000be4:	05ee                	slli	a1,a1,0x1b
    80000be6:	00242517          	auipc	a0,0x242
    80000bea:	c7250513          	addi	a0,a0,-910 # 80242858 <end>
    80000bee:	00000097          	auipc	ra,0x0
    80000bf2:	f3a080e7          	jalr	-198(ra) # 80000b28 <freerange>
}
    80000bf6:	60e2                	ld	ra,24(sp)
    80000bf8:	6442                	ld	s0,16(sp)
    80000bfa:	64a2                	ld	s1,8(sp)
    80000bfc:	6105                	addi	sp,sp,32
    80000bfe:	8082                	ret

0000000080000c00 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000c00:	1101                	addi	sp,sp,-32
    80000c02:	ec06                	sd	ra,24(sp)
    80000c04:	e822                	sd	s0,16(sp)
    80000c06:	e426                	sd	s1,8(sp)
    80000c08:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000c0a:	00010517          	auipc	a0,0x10
    80000c0e:	01e50513          	addi	a0,a0,30 # 80010c28 <kmem>
    80000c12:	00000097          	auipc	ra,0x0
    80000c16:	0f4080e7          	jalr	244(ra) # 80000d06 <acquire>
  r = kmem.freelist;
    80000c1a:	00010497          	auipc	s1,0x10
    80000c1e:	0264b483          	ld	s1,38(s1) # 80010c40 <kmem+0x18>
  if (r)
    80000c22:	c0a9                	beqz	s1,80000c64 <kalloc+0x64>
    kmem.freelist = r->next;
    80000c24:	609c                	ld	a5,0(s1)
    80000c26:	00010717          	auipc	a4,0x10
    80000c2a:	00f73d23          	sd	a5,26(a4) # 80010c40 <kmem+0x18>
  release(&kmem.lock);
    80000c2e:	00010517          	auipc	a0,0x10
    80000c32:	ffa50513          	addi	a0,a0,-6 # 80010c28 <kmem>
    80000c36:	00000097          	auipc	ra,0x0
    80000c3a:	184080e7          	jalr	388(ra) # 80000dba <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000c3e:	6605                	lui	a2,0x1
    80000c40:	4595                	li	a1,5
    80000c42:	8526                	mv	a0,s1
    80000c44:	00000097          	auipc	ra,0x0
    80000c48:	1be080e7          	jalr	446(ra) # 80000e02 <memset>

  // for COw
  if (r)
  {
    check_and_increment((uint64)r / PGSIZE);
    80000c4c:	00c4d513          	srli	a0,s1,0xc
    80000c50:	00000097          	auipc	ra,0x0
    80000c54:	dae080e7          	jalr	-594(ra) # 800009fe <check_and_increment>
  }

  return (void *)r;
}
    80000c58:	8526                	mv	a0,s1
    80000c5a:	60e2                	ld	ra,24(sp)
    80000c5c:	6442                	ld	s0,16(sp)
    80000c5e:	64a2                	ld	s1,8(sp)
    80000c60:	6105                	addi	sp,sp,32
    80000c62:	8082                	ret
  release(&kmem.lock);
    80000c64:	00010517          	auipc	a0,0x10
    80000c68:	fc450513          	addi	a0,a0,-60 # 80010c28 <kmem>
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	14e080e7          	jalr	334(ra) # 80000dba <release>
  if (r)
    80000c74:	b7d5                	j	80000c58 <kalloc+0x58>

0000000080000c76 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c76:	1141                	addi	sp,sp,-16
    80000c78:	e422                	sd	s0,8(sp)
    80000c7a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c7c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c7e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c82:	00053823          	sd	zero,16(a0)
}
    80000c86:	6422                	ld	s0,8(sp)
    80000c88:	0141                	addi	sp,sp,16
    80000c8a:	8082                	ret

0000000080000c8c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c8c:	411c                	lw	a5,0(a0)
    80000c8e:	e399                	bnez	a5,80000c94 <holding+0x8>
    80000c90:	4501                	li	a0,0
  return r;
}
    80000c92:	8082                	ret
{
    80000c94:	1101                	addi	sp,sp,-32
    80000c96:	ec06                	sd	ra,24(sp)
    80000c98:	e822                	sd	s0,16(sp)
    80000c9a:	e426                	sd	s1,8(sp)
    80000c9c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c9e:	6904                	ld	s1,16(a0)
    80000ca0:	00001097          	auipc	ra,0x1
    80000ca4:	f4c080e7          	jalr	-180(ra) # 80001bec <mycpu>
    80000ca8:	40a48533          	sub	a0,s1,a0
    80000cac:	00153513          	seqz	a0,a0
}
    80000cb0:	60e2                	ld	ra,24(sp)
    80000cb2:	6442                	ld	s0,16(sp)
    80000cb4:	64a2                	ld	s1,8(sp)
    80000cb6:	6105                	addi	sp,sp,32
    80000cb8:	8082                	ret

0000000080000cba <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000cba:	1101                	addi	sp,sp,-32
    80000cbc:	ec06                	sd	ra,24(sp)
    80000cbe:	e822                	sd	s0,16(sp)
    80000cc0:	e426                	sd	s1,8(sp)
    80000cc2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cc4:	100024f3          	csrr	s1,sstatus
    80000cc8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ccc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cce:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000cd2:	00001097          	auipc	ra,0x1
    80000cd6:	f1a080e7          	jalr	-230(ra) # 80001bec <mycpu>
    80000cda:	5d3c                	lw	a5,120(a0)
    80000cdc:	cf89                	beqz	a5,80000cf6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000cde:	00001097          	auipc	ra,0x1
    80000ce2:	f0e080e7          	jalr	-242(ra) # 80001bec <mycpu>
    80000ce6:	5d3c                	lw	a5,120(a0)
    80000ce8:	2785                	addiw	a5,a5,1
    80000cea:	dd3c                	sw	a5,120(a0)
}
    80000cec:	60e2                	ld	ra,24(sp)
    80000cee:	6442                	ld	s0,16(sp)
    80000cf0:	64a2                	ld	s1,8(sp)
    80000cf2:	6105                	addi	sp,sp,32
    80000cf4:	8082                	ret
    mycpu()->intena = old;
    80000cf6:	00001097          	auipc	ra,0x1
    80000cfa:	ef6080e7          	jalr	-266(ra) # 80001bec <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000cfe:	8085                	srli	s1,s1,0x1
    80000d00:	8885                	andi	s1,s1,1
    80000d02:	dd64                	sw	s1,124(a0)
    80000d04:	bfe9                	j	80000cde <push_off+0x24>

0000000080000d06 <acquire>:
{
    80000d06:	1101                	addi	sp,sp,-32
    80000d08:	ec06                	sd	ra,24(sp)
    80000d0a:	e822                	sd	s0,16(sp)
    80000d0c:	e426                	sd	s1,8(sp)
    80000d0e:	1000                	addi	s0,sp,32
    80000d10:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	fa8080e7          	jalr	-88(ra) # 80000cba <push_off>
  if(holding(lk))
    80000d1a:	8526                	mv	a0,s1
    80000d1c:	00000097          	auipc	ra,0x0
    80000d20:	f70080e7          	jalr	-144(ra) # 80000c8c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d24:	4705                	li	a4,1
  if(holding(lk))
    80000d26:	e115                	bnez	a0,80000d4a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d28:	87ba                	mv	a5,a4
    80000d2a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d2e:	2781                	sext.w	a5,a5
    80000d30:	ffe5                	bnez	a5,80000d28 <acquire+0x22>
  __sync_synchronize();
    80000d32:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000d36:	00001097          	auipc	ra,0x1
    80000d3a:	eb6080e7          	jalr	-330(ra) # 80001bec <mycpu>
    80000d3e:	e888                	sd	a0,16(s1)
}
    80000d40:	60e2                	ld	ra,24(sp)
    80000d42:	6442                	ld	s0,16(sp)
    80000d44:	64a2                	ld	s1,8(sp)
    80000d46:	6105                	addi	sp,sp,32
    80000d48:	8082                	ret
    panic("acquire");
    80000d4a:	00007517          	auipc	a0,0x7
    80000d4e:	34e50513          	addi	a0,a0,846 # 80008098 <digits+0x58>
    80000d52:	fffff097          	auipc	ra,0xfffff
    80000d56:	7f2080e7          	jalr	2034(ra) # 80000544 <panic>

0000000080000d5a <pop_off>:

void
pop_off(void)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d62:	00001097          	auipc	ra,0x1
    80000d66:	e8a080e7          	jalr	-374(ra) # 80001bec <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d6a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d6e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d70:	e78d                	bnez	a5,80000d9a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d72:	5d3c                	lw	a5,120(a0)
    80000d74:	02f05b63          	blez	a5,80000daa <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d78:	37fd                	addiw	a5,a5,-1
    80000d7a:	0007871b          	sext.w	a4,a5
    80000d7e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d80:	eb09                	bnez	a4,80000d92 <pop_off+0x38>
    80000d82:	5d7c                	lw	a5,124(a0)
    80000d84:	c799                	beqz	a5,80000d92 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d86:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d8a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d8e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d92:	60a2                	ld	ra,8(sp)
    80000d94:	6402                	ld	s0,0(sp)
    80000d96:	0141                	addi	sp,sp,16
    80000d98:	8082                	ret
    panic("pop_off - interruptible");
    80000d9a:	00007517          	auipc	a0,0x7
    80000d9e:	30650513          	addi	a0,a0,774 # 800080a0 <digits+0x60>
    80000da2:	fffff097          	auipc	ra,0xfffff
    80000da6:	7a2080e7          	jalr	1954(ra) # 80000544 <panic>
    panic("pop_off");
    80000daa:	00007517          	auipc	a0,0x7
    80000dae:	30e50513          	addi	a0,a0,782 # 800080b8 <digits+0x78>
    80000db2:	fffff097          	auipc	ra,0xfffff
    80000db6:	792080e7          	jalr	1938(ra) # 80000544 <panic>

0000000080000dba <release>:
{
    80000dba:	1101                	addi	sp,sp,-32
    80000dbc:	ec06                	sd	ra,24(sp)
    80000dbe:	e822                	sd	s0,16(sp)
    80000dc0:	e426                	sd	s1,8(sp)
    80000dc2:	1000                	addi	s0,sp,32
    80000dc4:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000dc6:	00000097          	auipc	ra,0x0
    80000dca:	ec6080e7          	jalr	-314(ra) # 80000c8c <holding>
    80000dce:	c115                	beqz	a0,80000df2 <release+0x38>
  lk->cpu = 0;
    80000dd0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000dd4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000dd8:	0f50000f          	fence	iorw,ow
    80000ddc:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000de0:	00000097          	auipc	ra,0x0
    80000de4:	f7a080e7          	jalr	-134(ra) # 80000d5a <pop_off>
}
    80000de8:	60e2                	ld	ra,24(sp)
    80000dea:	6442                	ld	s0,16(sp)
    80000dec:	64a2                	ld	s1,8(sp)
    80000dee:	6105                	addi	sp,sp,32
    80000df0:	8082                	ret
    panic("release");
    80000df2:	00007517          	auipc	a0,0x7
    80000df6:	2ce50513          	addi	a0,a0,718 # 800080c0 <digits+0x80>
    80000dfa:	fffff097          	auipc	ra,0xfffff
    80000dfe:	74a080e7          	jalr	1866(ra) # 80000544 <panic>

0000000080000e02 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000e02:	1141                	addi	sp,sp,-16
    80000e04:	e422                	sd	s0,8(sp)
    80000e06:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e08:	ce09                	beqz	a2,80000e22 <memset+0x20>
    80000e0a:	87aa                	mv	a5,a0
    80000e0c:	fff6071b          	addiw	a4,a2,-1
    80000e10:	1702                	slli	a4,a4,0x20
    80000e12:	9301                	srli	a4,a4,0x20
    80000e14:	0705                	addi	a4,a4,1
    80000e16:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000e18:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e1c:	0785                	addi	a5,a5,1
    80000e1e:	fee79de3          	bne	a5,a4,80000e18 <memset+0x16>
  }
  return dst;
}
    80000e22:	6422                	ld	s0,8(sp)
    80000e24:	0141                	addi	sp,sp,16
    80000e26:	8082                	ret

0000000080000e28 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e28:	1141                	addi	sp,sp,-16
    80000e2a:	e422                	sd	s0,8(sp)
    80000e2c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e2e:	ca05                	beqz	a2,80000e5e <memcmp+0x36>
    80000e30:	fff6069b          	addiw	a3,a2,-1
    80000e34:	1682                	slli	a3,a3,0x20
    80000e36:	9281                	srli	a3,a3,0x20
    80000e38:	0685                	addi	a3,a3,1
    80000e3a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e3c:	00054783          	lbu	a5,0(a0)
    80000e40:	0005c703          	lbu	a4,0(a1)
    80000e44:	00e79863          	bne	a5,a4,80000e54 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e48:	0505                	addi	a0,a0,1
    80000e4a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e4c:	fed518e3          	bne	a0,a3,80000e3c <memcmp+0x14>
  }

  return 0;
    80000e50:	4501                	li	a0,0
    80000e52:	a019                	j	80000e58 <memcmp+0x30>
      return *s1 - *s2;
    80000e54:	40e7853b          	subw	a0,a5,a4
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  return 0;
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <memcmp+0x30>

0000000080000e62 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e422                	sd	s0,8(sp)
    80000e66:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000e68:	ca0d                	beqz	a2,80000e9a <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e6a:	00a5f963          	bgeu	a1,a0,80000e7c <memmove+0x1a>
    80000e6e:	02061693          	slli	a3,a2,0x20
    80000e72:	9281                	srli	a3,a3,0x20
    80000e74:	00d58733          	add	a4,a1,a3
    80000e78:	02e56463          	bltu	a0,a4,80000ea0 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e7c:	fff6079b          	addiw	a5,a2,-1
    80000e80:	1782                	slli	a5,a5,0x20
    80000e82:	9381                	srli	a5,a5,0x20
    80000e84:	0785                	addi	a5,a5,1
    80000e86:	97ae                	add	a5,a5,a1
    80000e88:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e8a:	0585                	addi	a1,a1,1
    80000e8c:	0705                	addi	a4,a4,1
    80000e8e:	fff5c683          	lbu	a3,-1(a1)
    80000e92:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e96:	fef59ae3          	bne	a1,a5,80000e8a <memmove+0x28>

  return dst;
}
    80000e9a:	6422                	ld	s0,8(sp)
    80000e9c:	0141                	addi	sp,sp,16
    80000e9e:	8082                	ret
    d += n;
    80000ea0:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000ea2:	fff6079b          	addiw	a5,a2,-1
    80000ea6:	1782                	slli	a5,a5,0x20
    80000ea8:	9381                	srli	a5,a5,0x20
    80000eaa:	fff7c793          	not	a5,a5
    80000eae:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000eb0:	177d                	addi	a4,a4,-1
    80000eb2:	16fd                	addi	a3,a3,-1
    80000eb4:	00074603          	lbu	a2,0(a4)
    80000eb8:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000ebc:	fef71ae3          	bne	a4,a5,80000eb0 <memmove+0x4e>
    80000ec0:	bfe9                	j	80000e9a <memmove+0x38>

0000000080000ec2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000ec2:	1141                	addi	sp,sp,-16
    80000ec4:	e406                	sd	ra,8(sp)
    80000ec6:	e022                	sd	s0,0(sp)
    80000ec8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000eca:	00000097          	auipc	ra,0x0
    80000ece:	f98080e7          	jalr	-104(ra) # 80000e62 <memmove>
}
    80000ed2:	60a2                	ld	ra,8(sp)
    80000ed4:	6402                	ld	s0,0(sp)
    80000ed6:	0141                	addi	sp,sp,16
    80000ed8:	8082                	ret

0000000080000eda <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000eda:	1141                	addi	sp,sp,-16
    80000edc:	e422                	sd	s0,8(sp)
    80000ede:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ee0:	ce11                	beqz	a2,80000efc <strncmp+0x22>
    80000ee2:	00054783          	lbu	a5,0(a0)
    80000ee6:	cf89                	beqz	a5,80000f00 <strncmp+0x26>
    80000ee8:	0005c703          	lbu	a4,0(a1)
    80000eec:	00f71a63          	bne	a4,a5,80000f00 <strncmp+0x26>
    n--, p++, q++;
    80000ef0:	367d                	addiw	a2,a2,-1
    80000ef2:	0505                	addi	a0,a0,1
    80000ef4:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ef6:	f675                	bnez	a2,80000ee2 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ef8:	4501                	li	a0,0
    80000efa:	a809                	j	80000f0c <strncmp+0x32>
    80000efc:	4501                	li	a0,0
    80000efe:	a039                	j	80000f0c <strncmp+0x32>
  if(n == 0)
    80000f00:	ca09                	beqz	a2,80000f12 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000f02:	00054503          	lbu	a0,0(a0)
    80000f06:	0005c783          	lbu	a5,0(a1)
    80000f0a:	9d1d                	subw	a0,a0,a5
}
    80000f0c:	6422                	ld	s0,8(sp)
    80000f0e:	0141                	addi	sp,sp,16
    80000f10:	8082                	ret
    return 0;
    80000f12:	4501                	li	a0,0
    80000f14:	bfe5                	j	80000f0c <strncmp+0x32>

0000000080000f16 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f16:	1141                	addi	sp,sp,-16
    80000f18:	e422                	sd	s0,8(sp)
    80000f1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f1c:	872a                	mv	a4,a0
    80000f1e:	8832                	mv	a6,a2
    80000f20:	367d                	addiw	a2,a2,-1
    80000f22:	01005963          	blez	a6,80000f34 <strncpy+0x1e>
    80000f26:	0705                	addi	a4,a4,1
    80000f28:	0005c783          	lbu	a5,0(a1)
    80000f2c:	fef70fa3          	sb	a5,-1(a4)
    80000f30:	0585                	addi	a1,a1,1
    80000f32:	f7f5                	bnez	a5,80000f1e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f34:	00c05d63          	blez	a2,80000f4e <strncpy+0x38>
    80000f38:	86ba                	mv	a3,a4
    *s++ = 0;
    80000f3a:	0685                	addi	a3,a3,1
    80000f3c:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000f40:	fff6c793          	not	a5,a3
    80000f44:	9fb9                	addw	a5,a5,a4
    80000f46:	010787bb          	addw	a5,a5,a6
    80000f4a:	fef048e3          	bgtz	a5,80000f3a <strncpy+0x24>
  return os;
}
    80000f4e:	6422                	ld	s0,8(sp)
    80000f50:	0141                	addi	sp,sp,16
    80000f52:	8082                	ret

0000000080000f54 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f54:	1141                	addi	sp,sp,-16
    80000f56:	e422                	sd	s0,8(sp)
    80000f58:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f5a:	02c05363          	blez	a2,80000f80 <safestrcpy+0x2c>
    80000f5e:	fff6069b          	addiw	a3,a2,-1
    80000f62:	1682                	slli	a3,a3,0x20
    80000f64:	9281                	srli	a3,a3,0x20
    80000f66:	96ae                	add	a3,a3,a1
    80000f68:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f6a:	00d58963          	beq	a1,a3,80000f7c <safestrcpy+0x28>
    80000f6e:	0585                	addi	a1,a1,1
    80000f70:	0785                	addi	a5,a5,1
    80000f72:	fff5c703          	lbu	a4,-1(a1)
    80000f76:	fee78fa3          	sb	a4,-1(a5)
    80000f7a:	fb65                	bnez	a4,80000f6a <safestrcpy+0x16>
    ;
  *s = 0;
    80000f7c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f80:	6422                	ld	s0,8(sp)
    80000f82:	0141                	addi	sp,sp,16
    80000f84:	8082                	ret

0000000080000f86 <strlen>:

int
strlen(const char *s)
{
    80000f86:	1141                	addi	sp,sp,-16
    80000f88:	e422                	sd	s0,8(sp)
    80000f8a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f8c:	00054783          	lbu	a5,0(a0)
    80000f90:	cf91                	beqz	a5,80000fac <strlen+0x26>
    80000f92:	0505                	addi	a0,a0,1
    80000f94:	87aa                	mv	a5,a0
    80000f96:	4685                	li	a3,1
    80000f98:	9e89                	subw	a3,a3,a0
    80000f9a:	00f6853b          	addw	a0,a3,a5
    80000f9e:	0785                	addi	a5,a5,1
    80000fa0:	fff7c703          	lbu	a4,-1(a5)
    80000fa4:	fb7d                	bnez	a4,80000f9a <strlen+0x14>
    ;
  return n;
}
    80000fa6:	6422                	ld	s0,8(sp)
    80000fa8:	0141                	addi	sp,sp,16
    80000faa:	8082                	ret
  for(n = 0; s[n]; n++)
    80000fac:	4501                	li	a0,0
    80000fae:	bfe5                	j	80000fa6 <strlen+0x20>

0000000080000fb0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000fb0:	1141                	addi	sp,sp,-16
    80000fb2:	e406                	sd	ra,8(sp)
    80000fb4:	e022                	sd	s0,0(sp)
    80000fb6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000fb8:	00001097          	auipc	ra,0x1
    80000fbc:	c24080e7          	jalr	-988(ra) # 80001bdc <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000fc0:	00008717          	auipc	a4,0x8
    80000fc4:	9e870713          	addi	a4,a4,-1560 # 800089a8 <started>
  if(cpuid() == 0){
    80000fc8:	c139                	beqz	a0,8000100e <main+0x5e>
    while(started == 0)
    80000fca:	431c                	lw	a5,0(a4)
    80000fcc:	2781                	sext.w	a5,a5
    80000fce:	dff5                	beqz	a5,80000fca <main+0x1a>
      ;
    __sync_synchronize();
    80000fd0:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000fd4:	00001097          	auipc	ra,0x1
    80000fd8:	c08080e7          	jalr	-1016(ra) # 80001bdc <cpuid>
    80000fdc:	85aa                	mv	a1,a0
    80000fde:	00007517          	auipc	a0,0x7
    80000fe2:	10250513          	addi	a0,a0,258 # 800080e0 <digits+0xa0>
    80000fe6:	fffff097          	auipc	ra,0xfffff
    80000fea:	5a8080e7          	jalr	1448(ra) # 8000058e <printf>
    kvminithart();    // turn on paging
    80000fee:	00000097          	auipc	ra,0x0
    80000ff2:	0d8080e7          	jalr	216(ra) # 800010c6 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ff6:	00002097          	auipc	ra,0x2
    80000ffa:	cba080e7          	jalr	-838(ra) # 80002cb0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ffe:	00005097          	auipc	ra,0x5
    80001002:	482080e7          	jalr	1154(ra) # 80006480 <plicinithart>
  }

  scheduler();        
    80001006:	00001097          	auipc	ra,0x1
    8000100a:	1da080e7          	jalr	474(ra) # 800021e0 <scheduler>
    consoleinit();
    8000100e:	fffff097          	auipc	ra,0xfffff
    80001012:	448080e7          	jalr	1096(ra) # 80000456 <consoleinit>
    printfinit();
    80001016:	fffff097          	auipc	ra,0xfffff
    8000101a:	75e080e7          	jalr	1886(ra) # 80000774 <printfinit>
    printf("\n");
    8000101e:	00007517          	auipc	a0,0x7
    80001022:	0d250513          	addi	a0,a0,210 # 800080f0 <digits+0xb0>
    80001026:	fffff097          	auipc	ra,0xfffff
    8000102a:	568080e7          	jalr	1384(ra) # 8000058e <printf>
    printf("xv6 kernel is booting\n");
    8000102e:	00007517          	auipc	a0,0x7
    80001032:	09a50513          	addi	a0,a0,154 # 800080c8 <digits+0x88>
    80001036:	fffff097          	auipc	ra,0xfffff
    8000103a:	558080e7          	jalr	1368(ra) # 8000058e <printf>
    printf("\n");
    8000103e:	00007517          	auipc	a0,0x7
    80001042:	0b250513          	addi	a0,a0,178 # 800080f0 <digits+0xb0>
    80001046:	fffff097          	auipc	ra,0xfffff
    8000104a:	548080e7          	jalr	1352(ra) # 8000058e <printf>
    kinit();         // physical page allocator
    8000104e:	00000097          	auipc	ra,0x0
    80001052:	b24080e7          	jalr	-1244(ra) # 80000b72 <kinit>
    kvminit();       // create kernel page table
    80001056:	00000097          	auipc	ra,0x0
    8000105a:	326080e7          	jalr	806(ra) # 8000137c <kvminit>
    kvminithart();   // turn on paging
    8000105e:	00000097          	auipc	ra,0x0
    80001062:	068080e7          	jalr	104(ra) # 800010c6 <kvminithart>
    procinit();      // process table
    80001066:	00001097          	auipc	ra,0x1
    8000106a:	ac2080e7          	jalr	-1342(ra) # 80001b28 <procinit>
    trapinit();      // trap vectors
    8000106e:	00002097          	auipc	ra,0x2
    80001072:	c1a080e7          	jalr	-998(ra) # 80002c88 <trapinit>
    trapinithart();  // install kernel trap vector
    80001076:	00002097          	auipc	ra,0x2
    8000107a:	c3a080e7          	jalr	-966(ra) # 80002cb0 <trapinithart>
    plicinit();      // set up interrupt controller
    8000107e:	00005097          	auipc	ra,0x5
    80001082:	3ec080e7          	jalr	1004(ra) # 8000646a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001086:	00005097          	auipc	ra,0x5
    8000108a:	3fa080e7          	jalr	1018(ra) # 80006480 <plicinithart>
    binit();         // buffer cache
    8000108e:	00002097          	auipc	ra,0x2
    80001092:	58c080e7          	jalr	1420(ra) # 8000361a <binit>
    iinit();         // inode table
    80001096:	00003097          	auipc	ra,0x3
    8000109a:	c30080e7          	jalr	-976(ra) # 80003cc6 <iinit>
    fileinit();      // file table
    8000109e:	00004097          	auipc	ra,0x4
    800010a2:	bce080e7          	jalr	-1074(ra) # 80004c6c <fileinit>
    virtio_disk_init(); // emulated hard disk
    800010a6:	00005097          	auipc	ra,0x5
    800010aa:	4e2080e7          	jalr	1250(ra) # 80006588 <virtio_disk_init>
    userinit();      // first user process
    800010ae:	00001097          	auipc	ra,0x1
    800010b2:	e82080e7          	jalr	-382(ra) # 80001f30 <userinit>
    __sync_synchronize();
    800010b6:	0ff0000f          	fence
    started = 1;
    800010ba:	4785                	li	a5,1
    800010bc:	00008717          	auipc	a4,0x8
    800010c0:	8ef72623          	sw	a5,-1812(a4) # 800089a8 <started>
    800010c4:	b789                	j	80001006 <main+0x56>

00000000800010c6 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800010c6:	1141                	addi	sp,sp,-16
    800010c8:	e422                	sd	s0,8(sp)
    800010ca:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800010cc:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800010d0:	00008797          	auipc	a5,0x8
    800010d4:	8e07b783          	ld	a5,-1824(a5) # 800089b0 <kernel_pagetable>
    800010d8:	83b1                	srli	a5,a5,0xc
    800010da:	577d                	li	a4,-1
    800010dc:	177e                	slli	a4,a4,0x3f
    800010de:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800010e0:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800010e4:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800010e8:	6422                	ld	s0,8(sp)
    800010ea:	0141                	addi	sp,sp,16
    800010ec:	8082                	ret

00000000800010ee <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010ee:	7139                	addi	sp,sp,-64
    800010f0:	fc06                	sd	ra,56(sp)
    800010f2:	f822                	sd	s0,48(sp)
    800010f4:	f426                	sd	s1,40(sp)
    800010f6:	f04a                	sd	s2,32(sp)
    800010f8:	ec4e                	sd	s3,24(sp)
    800010fa:	e852                	sd	s4,16(sp)
    800010fc:	e456                	sd	s5,8(sp)
    800010fe:	e05a                	sd	s6,0(sp)
    80001100:	0080                	addi	s0,sp,64
    80001102:	84aa                	mv	s1,a0
    80001104:	89ae                	mv	s3,a1
    80001106:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001108:	57fd                	li	a5,-1
    8000110a:	83e9                	srli	a5,a5,0x1a
    8000110c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000110e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001110:	04b7f263          	bgeu	a5,a1,80001154 <walk+0x66>
    panic("walk");
    80001114:	00007517          	auipc	a0,0x7
    80001118:	fe450513          	addi	a0,a0,-28 # 800080f8 <digits+0xb8>
    8000111c:	fffff097          	auipc	ra,0xfffff
    80001120:	428080e7          	jalr	1064(ra) # 80000544 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001124:	060a8663          	beqz	s5,80001190 <walk+0xa2>
    80001128:	00000097          	auipc	ra,0x0
    8000112c:	ad8080e7          	jalr	-1320(ra) # 80000c00 <kalloc>
    80001130:	84aa                	mv	s1,a0
    80001132:	c529                	beqz	a0,8000117c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001134:	6605                	lui	a2,0x1
    80001136:	4581                	li	a1,0
    80001138:	00000097          	auipc	ra,0x0
    8000113c:	cca080e7          	jalr	-822(ra) # 80000e02 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001140:	00c4d793          	srli	a5,s1,0xc
    80001144:	07aa                	slli	a5,a5,0xa
    80001146:	0017e793          	ori	a5,a5,1
    8000114a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000114e:	3a5d                	addiw	s4,s4,-9
    80001150:	036a0063          	beq	s4,s6,80001170 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001154:	0149d933          	srl	s2,s3,s4
    80001158:	1ff97913          	andi	s2,s2,511
    8000115c:	090e                	slli	s2,s2,0x3
    8000115e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001160:	00093483          	ld	s1,0(s2)
    80001164:	0014f793          	andi	a5,s1,1
    80001168:	dfd5                	beqz	a5,80001124 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000116a:	80a9                	srli	s1,s1,0xa
    8000116c:	04b2                	slli	s1,s1,0xc
    8000116e:	b7c5                	j	8000114e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001170:	00c9d513          	srli	a0,s3,0xc
    80001174:	1ff57513          	andi	a0,a0,511
    80001178:	050e                	slli	a0,a0,0x3
    8000117a:	9526                	add	a0,a0,s1
}
    8000117c:	70e2                	ld	ra,56(sp)
    8000117e:	7442                	ld	s0,48(sp)
    80001180:	74a2                	ld	s1,40(sp)
    80001182:	7902                	ld	s2,32(sp)
    80001184:	69e2                	ld	s3,24(sp)
    80001186:	6a42                	ld	s4,16(sp)
    80001188:	6aa2                	ld	s5,8(sp)
    8000118a:	6b02                	ld	s6,0(sp)
    8000118c:	6121                	addi	sp,sp,64
    8000118e:	8082                	ret
        return 0;
    80001190:	4501                	li	a0,0
    80001192:	b7ed                	j	8000117c <walk+0x8e>

0000000080001194 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001194:	57fd                	li	a5,-1
    80001196:	83e9                	srli	a5,a5,0x1a
    80001198:	00b7f463          	bgeu	a5,a1,800011a0 <walkaddr+0xc>
    return 0;
    8000119c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000119e:	8082                	ret
{
    800011a0:	1141                	addi	sp,sp,-16
    800011a2:	e406                	sd	ra,8(sp)
    800011a4:	e022                	sd	s0,0(sp)
    800011a6:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800011a8:	4601                	li	a2,0
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f44080e7          	jalr	-188(ra) # 800010ee <walk>
  if(pte == 0)
    800011b2:	c105                	beqz	a0,800011d2 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800011b4:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800011b6:	0117f693          	andi	a3,a5,17
    800011ba:	4745                	li	a4,17
    return 0;
    800011bc:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800011be:	00e68663          	beq	a3,a4,800011ca <walkaddr+0x36>
}
    800011c2:	60a2                	ld	ra,8(sp)
    800011c4:	6402                	ld	s0,0(sp)
    800011c6:	0141                	addi	sp,sp,16
    800011c8:	8082                	ret
  pa = PTE2PA(*pte);
    800011ca:	00a7d513          	srli	a0,a5,0xa
    800011ce:	0532                	slli	a0,a0,0xc
  return pa;
    800011d0:	bfcd                	j	800011c2 <walkaddr+0x2e>
    return 0;
    800011d2:	4501                	li	a0,0
    800011d4:	b7fd                	j	800011c2 <walkaddr+0x2e>

00000000800011d6 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011d6:	715d                	addi	sp,sp,-80
    800011d8:	e486                	sd	ra,72(sp)
    800011da:	e0a2                	sd	s0,64(sp)
    800011dc:	fc26                	sd	s1,56(sp)
    800011de:	f84a                	sd	s2,48(sp)
    800011e0:	f44e                	sd	s3,40(sp)
    800011e2:	f052                	sd	s4,32(sp)
    800011e4:	ec56                	sd	s5,24(sp)
    800011e6:	e85a                	sd	s6,16(sp)
    800011e8:	e45e                	sd	s7,8(sp)
    800011ea:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800011ec:	c205                	beqz	a2,8000120c <mappages+0x36>
    800011ee:	8aaa                	mv	s5,a0
    800011f0:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800011f2:	77fd                	lui	a5,0xfffff
    800011f4:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800011f8:	15fd                	addi	a1,a1,-1
    800011fa:	00c589b3          	add	s3,a1,a2
    800011fe:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    80001202:	8952                	mv	s2,s4
    80001204:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001208:	6b85                	lui	s7,0x1
    8000120a:	a015                	j	8000122e <mappages+0x58>
    panic("mappages: size");
    8000120c:	00007517          	auipc	a0,0x7
    80001210:	ef450513          	addi	a0,a0,-268 # 80008100 <digits+0xc0>
    80001214:	fffff097          	auipc	ra,0xfffff
    80001218:	330080e7          	jalr	816(ra) # 80000544 <panic>
      panic("mappages: remap");
    8000121c:	00007517          	auipc	a0,0x7
    80001220:	ef450513          	addi	a0,a0,-268 # 80008110 <digits+0xd0>
    80001224:	fffff097          	auipc	ra,0xfffff
    80001228:	320080e7          	jalr	800(ra) # 80000544 <panic>
    a += PGSIZE;
    8000122c:	995e                	add	s2,s2,s7
  for(;;){
    8000122e:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001232:	4605                	li	a2,1
    80001234:	85ca                	mv	a1,s2
    80001236:	8556                	mv	a0,s5
    80001238:	00000097          	auipc	ra,0x0
    8000123c:	eb6080e7          	jalr	-330(ra) # 800010ee <walk>
    80001240:	cd19                	beqz	a0,8000125e <mappages+0x88>
    if(*pte & PTE_V)
    80001242:	611c                	ld	a5,0(a0)
    80001244:	8b85                	andi	a5,a5,1
    80001246:	fbf9                	bnez	a5,8000121c <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001248:	80b1                	srli	s1,s1,0xc
    8000124a:	04aa                	slli	s1,s1,0xa
    8000124c:	0164e4b3          	or	s1,s1,s6
    80001250:	0014e493          	ori	s1,s1,1
    80001254:	e104                	sd	s1,0(a0)
    if(a == last)
    80001256:	fd391be3          	bne	s2,s3,8000122c <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    8000125a:	4501                	li	a0,0
    8000125c:	a011                	j	80001260 <mappages+0x8a>
      return -1;
    8000125e:	557d                	li	a0,-1
}
    80001260:	60a6                	ld	ra,72(sp)
    80001262:	6406                	ld	s0,64(sp)
    80001264:	74e2                	ld	s1,56(sp)
    80001266:	7942                	ld	s2,48(sp)
    80001268:	79a2                	ld	s3,40(sp)
    8000126a:	7a02                	ld	s4,32(sp)
    8000126c:	6ae2                	ld	s5,24(sp)
    8000126e:	6b42                	ld	s6,16(sp)
    80001270:	6ba2                	ld	s7,8(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <kvmmap>:
{
    80001276:	1141                	addi	sp,sp,-16
    80001278:	e406                	sd	ra,8(sp)
    8000127a:	e022                	sd	s0,0(sp)
    8000127c:	0800                	addi	s0,sp,16
    8000127e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001280:	86b2                	mv	a3,a2
    80001282:	863e                	mv	a2,a5
    80001284:	00000097          	auipc	ra,0x0
    80001288:	f52080e7          	jalr	-174(ra) # 800011d6 <mappages>
    8000128c:	e509                	bnez	a0,80001296 <kvmmap+0x20>
}
    8000128e:	60a2                	ld	ra,8(sp)
    80001290:	6402                	ld	s0,0(sp)
    80001292:	0141                	addi	sp,sp,16
    80001294:	8082                	ret
    panic("kvmmap");
    80001296:	00007517          	auipc	a0,0x7
    8000129a:	e8a50513          	addi	a0,a0,-374 # 80008120 <digits+0xe0>
    8000129e:	fffff097          	auipc	ra,0xfffff
    800012a2:	2a6080e7          	jalr	678(ra) # 80000544 <panic>

00000000800012a6 <kvmmake>:
{
    800012a6:	1101                	addi	sp,sp,-32
    800012a8:	ec06                	sd	ra,24(sp)
    800012aa:	e822                	sd	s0,16(sp)
    800012ac:	e426                	sd	s1,8(sp)
    800012ae:	e04a                	sd	s2,0(sp)
    800012b0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800012b2:	00000097          	auipc	ra,0x0
    800012b6:	94e080e7          	jalr	-1714(ra) # 80000c00 <kalloc>
    800012ba:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012bc:	6605                	lui	a2,0x1
    800012be:	4581                	li	a1,0
    800012c0:	00000097          	auipc	ra,0x0
    800012c4:	b42080e7          	jalr	-1214(ra) # 80000e02 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012c8:	4719                	li	a4,6
    800012ca:	6685                	lui	a3,0x1
    800012cc:	10000637          	lui	a2,0x10000
    800012d0:	100005b7          	lui	a1,0x10000
    800012d4:	8526                	mv	a0,s1
    800012d6:	00000097          	auipc	ra,0x0
    800012da:	fa0080e7          	jalr	-96(ra) # 80001276 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012de:	4719                	li	a4,6
    800012e0:	6685                	lui	a3,0x1
    800012e2:	10001637          	lui	a2,0x10001
    800012e6:	100015b7          	lui	a1,0x10001
    800012ea:	8526                	mv	a0,s1
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	f8a080e7          	jalr	-118(ra) # 80001276 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012f4:	4719                	li	a4,6
    800012f6:	004006b7          	lui	a3,0x400
    800012fa:	0c000637          	lui	a2,0xc000
    800012fe:	0c0005b7          	lui	a1,0xc000
    80001302:	8526                	mv	a0,s1
    80001304:	00000097          	auipc	ra,0x0
    80001308:	f72080e7          	jalr	-142(ra) # 80001276 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000130c:	00007917          	auipc	s2,0x7
    80001310:	cf490913          	addi	s2,s2,-780 # 80008000 <etext>
    80001314:	4729                	li	a4,10
    80001316:	80007697          	auipc	a3,0x80007
    8000131a:	cea68693          	addi	a3,a3,-790 # 8000 <_entry-0x7fff8000>
    8000131e:	4605                	li	a2,1
    80001320:	067e                	slli	a2,a2,0x1f
    80001322:	85b2                	mv	a1,a2
    80001324:	8526                	mv	a0,s1
    80001326:	00000097          	auipc	ra,0x0
    8000132a:	f50080e7          	jalr	-176(ra) # 80001276 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000132e:	4719                	li	a4,6
    80001330:	46c5                	li	a3,17
    80001332:	06ee                	slli	a3,a3,0x1b
    80001334:	412686b3          	sub	a3,a3,s2
    80001338:	864a                	mv	a2,s2
    8000133a:	85ca                	mv	a1,s2
    8000133c:	8526                	mv	a0,s1
    8000133e:	00000097          	auipc	ra,0x0
    80001342:	f38080e7          	jalr	-200(ra) # 80001276 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001346:	4729                	li	a4,10
    80001348:	6685                	lui	a3,0x1
    8000134a:	00006617          	auipc	a2,0x6
    8000134e:	cb660613          	addi	a2,a2,-842 # 80007000 <_trampoline>
    80001352:	040005b7          	lui	a1,0x4000
    80001356:	15fd                	addi	a1,a1,-1
    80001358:	05b2                	slli	a1,a1,0xc
    8000135a:	8526                	mv	a0,s1
    8000135c:	00000097          	auipc	ra,0x0
    80001360:	f1a080e7          	jalr	-230(ra) # 80001276 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001364:	8526                	mv	a0,s1
    80001366:	00000097          	auipc	ra,0x0
    8000136a:	72c080e7          	jalr	1836(ra) # 80001a92 <proc_mapstacks>
}
    8000136e:	8526                	mv	a0,s1
    80001370:	60e2                	ld	ra,24(sp)
    80001372:	6442                	ld	s0,16(sp)
    80001374:	64a2                	ld	s1,8(sp)
    80001376:	6902                	ld	s2,0(sp)
    80001378:	6105                	addi	sp,sp,32
    8000137a:	8082                	ret

000000008000137c <kvminit>:
{
    8000137c:	1141                	addi	sp,sp,-16
    8000137e:	e406                	sd	ra,8(sp)
    80001380:	e022                	sd	s0,0(sp)
    80001382:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001384:	00000097          	auipc	ra,0x0
    80001388:	f22080e7          	jalr	-222(ra) # 800012a6 <kvmmake>
    8000138c:	00007797          	auipc	a5,0x7
    80001390:	62a7b223          	sd	a0,1572(a5) # 800089b0 <kernel_pagetable>
}
    80001394:	60a2                	ld	ra,8(sp)
    80001396:	6402                	ld	s0,0(sp)
    80001398:	0141                	addi	sp,sp,16
    8000139a:	8082                	ret

000000008000139c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000139c:	715d                	addi	sp,sp,-80
    8000139e:	e486                	sd	ra,72(sp)
    800013a0:	e0a2                	sd	s0,64(sp)
    800013a2:	fc26                	sd	s1,56(sp)
    800013a4:	f84a                	sd	s2,48(sp)
    800013a6:	f44e                	sd	s3,40(sp)
    800013a8:	f052                	sd	s4,32(sp)
    800013aa:	ec56                	sd	s5,24(sp)
    800013ac:	e85a                	sd	s6,16(sp)
    800013ae:	e45e                	sd	s7,8(sp)
    800013b0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013b2:	03459793          	slli	a5,a1,0x34
    800013b6:	e795                	bnez	a5,800013e2 <uvmunmap+0x46>
    800013b8:	8a2a                	mv	s4,a0
    800013ba:	892e                	mv	s2,a1
    800013bc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013be:	0632                	slli	a2,a2,0xc
    800013c0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800013c4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013c6:	6b05                	lui	s6,0x1
    800013c8:	0735e863          	bltu	a1,s3,80001438 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800013cc:	60a6                	ld	ra,72(sp)
    800013ce:	6406                	ld	s0,64(sp)
    800013d0:	74e2                	ld	s1,56(sp)
    800013d2:	7942                	ld	s2,48(sp)
    800013d4:	79a2                	ld	s3,40(sp)
    800013d6:	7a02                	ld	s4,32(sp)
    800013d8:	6ae2                	ld	s5,24(sp)
    800013da:	6b42                	ld	s6,16(sp)
    800013dc:	6ba2                	ld	s7,8(sp)
    800013de:	6161                	addi	sp,sp,80
    800013e0:	8082                	ret
    panic("uvmunmap: not aligned");
    800013e2:	00007517          	auipc	a0,0x7
    800013e6:	d4650513          	addi	a0,a0,-698 # 80008128 <digits+0xe8>
    800013ea:	fffff097          	auipc	ra,0xfffff
    800013ee:	15a080e7          	jalr	346(ra) # 80000544 <panic>
      panic("uvmunmap: walk");
    800013f2:	00007517          	auipc	a0,0x7
    800013f6:	d4e50513          	addi	a0,a0,-690 # 80008140 <digits+0x100>
    800013fa:	fffff097          	auipc	ra,0xfffff
    800013fe:	14a080e7          	jalr	330(ra) # 80000544 <panic>
      panic("uvmunmap: not mapped");
    80001402:	00007517          	auipc	a0,0x7
    80001406:	d4e50513          	addi	a0,a0,-690 # 80008150 <digits+0x110>
    8000140a:	fffff097          	auipc	ra,0xfffff
    8000140e:	13a080e7          	jalr	314(ra) # 80000544 <panic>
      panic("uvmunmap: not a leaf");
    80001412:	00007517          	auipc	a0,0x7
    80001416:	d5650513          	addi	a0,a0,-682 # 80008168 <digits+0x128>
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	12a080e7          	jalr	298(ra) # 80000544 <panic>
      uint64 pa = PTE2PA(*pte);
    80001422:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001424:	0532                	slli	a0,a0,0xc
    80001426:	fffff097          	auipc	ra,0xfffff
    8000142a:	644080e7          	jalr	1604(ra) # 80000a6a <kfree>
    *pte = 0;
    8000142e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001432:	995a                	add	s2,s2,s6
    80001434:	f9397ce3          	bgeu	s2,s3,800013cc <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001438:	4601                	li	a2,0
    8000143a:	85ca                	mv	a1,s2
    8000143c:	8552                	mv	a0,s4
    8000143e:	00000097          	auipc	ra,0x0
    80001442:	cb0080e7          	jalr	-848(ra) # 800010ee <walk>
    80001446:	84aa                	mv	s1,a0
    80001448:	d54d                	beqz	a0,800013f2 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000144a:	6108                	ld	a0,0(a0)
    8000144c:	00157793          	andi	a5,a0,1
    80001450:	dbcd                	beqz	a5,80001402 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001452:	3ff57793          	andi	a5,a0,1023
    80001456:	fb778ee3          	beq	a5,s7,80001412 <uvmunmap+0x76>
    if(do_free){
    8000145a:	fc0a8ae3          	beqz	s5,8000142e <uvmunmap+0x92>
    8000145e:	b7d1                	j	80001422 <uvmunmap+0x86>

0000000080001460 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001460:	1101                	addi	sp,sp,-32
    80001462:	ec06                	sd	ra,24(sp)
    80001464:	e822                	sd	s0,16(sp)
    80001466:	e426                	sd	s1,8(sp)
    80001468:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000146a:	fffff097          	auipc	ra,0xfffff
    8000146e:	796080e7          	jalr	1942(ra) # 80000c00 <kalloc>
    80001472:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001474:	c519                	beqz	a0,80001482 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001476:	6605                	lui	a2,0x1
    80001478:	4581                	li	a1,0
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	988080e7          	jalr	-1656(ra) # 80000e02 <memset>
  return pagetable;
}
    80001482:	8526                	mv	a0,s1
    80001484:	60e2                	ld	ra,24(sp)
    80001486:	6442                	ld	s0,16(sp)
    80001488:	64a2                	ld	s1,8(sp)
    8000148a:	6105                	addi	sp,sp,32
    8000148c:	8082                	ret

000000008000148e <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000148e:	7179                	addi	sp,sp,-48
    80001490:	f406                	sd	ra,40(sp)
    80001492:	f022                	sd	s0,32(sp)
    80001494:	ec26                	sd	s1,24(sp)
    80001496:	e84a                	sd	s2,16(sp)
    80001498:	e44e                	sd	s3,8(sp)
    8000149a:	e052                	sd	s4,0(sp)
    8000149c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000149e:	6785                	lui	a5,0x1
    800014a0:	04f67863          	bgeu	a2,a5,800014f0 <uvmfirst+0x62>
    800014a4:	8a2a                	mv	s4,a0
    800014a6:	89ae                	mv	s3,a1
    800014a8:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	756080e7          	jalr	1878(ra) # 80000c00 <kalloc>
    800014b2:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800014b4:	6605                	lui	a2,0x1
    800014b6:	4581                	li	a1,0
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	94a080e7          	jalr	-1718(ra) # 80000e02 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800014c0:	4779                	li	a4,30
    800014c2:	86ca                	mv	a3,s2
    800014c4:	6605                	lui	a2,0x1
    800014c6:	4581                	li	a1,0
    800014c8:	8552                	mv	a0,s4
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	d0c080e7          	jalr	-756(ra) # 800011d6 <mappages>
  memmove(mem, src, sz);
    800014d2:	8626                	mv	a2,s1
    800014d4:	85ce                	mv	a1,s3
    800014d6:	854a                	mv	a0,s2
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	98a080e7          	jalr	-1654(ra) # 80000e62 <memmove>
}
    800014e0:	70a2                	ld	ra,40(sp)
    800014e2:	7402                	ld	s0,32(sp)
    800014e4:	64e2                	ld	s1,24(sp)
    800014e6:	6942                	ld	s2,16(sp)
    800014e8:	69a2                	ld	s3,8(sp)
    800014ea:	6a02                	ld	s4,0(sp)
    800014ec:	6145                	addi	sp,sp,48
    800014ee:	8082                	ret
    panic("uvmfirst: more than a page");
    800014f0:	00007517          	auipc	a0,0x7
    800014f4:	c9050513          	addi	a0,a0,-880 # 80008180 <digits+0x140>
    800014f8:	fffff097          	auipc	ra,0xfffff
    800014fc:	04c080e7          	jalr	76(ra) # 80000544 <panic>

0000000080001500 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001500:	1101                	addi	sp,sp,-32
    80001502:	ec06                	sd	ra,24(sp)
    80001504:	e822                	sd	s0,16(sp)
    80001506:	e426                	sd	s1,8(sp)
    80001508:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000150a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000150c:	00b67d63          	bgeu	a2,a1,80001526 <uvmdealloc+0x26>
    80001510:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001512:	6785                	lui	a5,0x1
    80001514:	17fd                	addi	a5,a5,-1
    80001516:	00f60733          	add	a4,a2,a5
    8000151a:	767d                	lui	a2,0xfffff
    8000151c:	8f71                	and	a4,a4,a2
    8000151e:	97ae                	add	a5,a5,a1
    80001520:	8ff1                	and	a5,a5,a2
    80001522:	00f76863          	bltu	a4,a5,80001532 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001526:	8526                	mv	a0,s1
    80001528:	60e2                	ld	ra,24(sp)
    8000152a:	6442                	ld	s0,16(sp)
    8000152c:	64a2                	ld	s1,8(sp)
    8000152e:	6105                	addi	sp,sp,32
    80001530:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001532:	8f99                	sub	a5,a5,a4
    80001534:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001536:	4685                	li	a3,1
    80001538:	0007861b          	sext.w	a2,a5
    8000153c:	85ba                	mv	a1,a4
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	e5e080e7          	jalr	-418(ra) # 8000139c <uvmunmap>
    80001546:	b7c5                	j	80001526 <uvmdealloc+0x26>

0000000080001548 <uvmalloc>:
  if(newsz < oldsz)
    80001548:	0ab66563          	bltu	a2,a1,800015f2 <uvmalloc+0xaa>
{
    8000154c:	7139                	addi	sp,sp,-64
    8000154e:	fc06                	sd	ra,56(sp)
    80001550:	f822                	sd	s0,48(sp)
    80001552:	f426                	sd	s1,40(sp)
    80001554:	f04a                	sd	s2,32(sp)
    80001556:	ec4e                	sd	s3,24(sp)
    80001558:	e852                	sd	s4,16(sp)
    8000155a:	e456                	sd	s5,8(sp)
    8000155c:	e05a                	sd	s6,0(sp)
    8000155e:	0080                	addi	s0,sp,64
    80001560:	8aaa                	mv	s5,a0
    80001562:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001564:	6985                	lui	s3,0x1
    80001566:	19fd                	addi	s3,s3,-1
    80001568:	95ce                	add	a1,a1,s3
    8000156a:	79fd                	lui	s3,0xfffff
    8000156c:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001570:	08c9f363          	bgeu	s3,a2,800015f6 <uvmalloc+0xae>
    80001574:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001576:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000157a:	fffff097          	auipc	ra,0xfffff
    8000157e:	686080e7          	jalr	1670(ra) # 80000c00 <kalloc>
    80001582:	84aa                	mv	s1,a0
    if(mem == 0){
    80001584:	c51d                	beqz	a0,800015b2 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001586:	6605                	lui	a2,0x1
    80001588:	4581                	li	a1,0
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	878080e7          	jalr	-1928(ra) # 80000e02 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001592:	875a                	mv	a4,s6
    80001594:	86a6                	mv	a3,s1
    80001596:	6605                	lui	a2,0x1
    80001598:	85ca                	mv	a1,s2
    8000159a:	8556                	mv	a0,s5
    8000159c:	00000097          	auipc	ra,0x0
    800015a0:	c3a080e7          	jalr	-966(ra) # 800011d6 <mappages>
    800015a4:	e90d                	bnez	a0,800015d6 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015a6:	6785                	lui	a5,0x1
    800015a8:	993e                	add	s2,s2,a5
    800015aa:	fd4968e3          	bltu	s2,s4,8000157a <uvmalloc+0x32>
  return newsz;
    800015ae:	8552                	mv	a0,s4
    800015b0:	a809                	j	800015c2 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    800015b2:	864e                	mv	a2,s3
    800015b4:	85ca                	mv	a1,s2
    800015b6:	8556                	mv	a0,s5
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	f48080e7          	jalr	-184(ra) # 80001500 <uvmdealloc>
      return 0;
    800015c0:	4501                	li	a0,0
}
    800015c2:	70e2                	ld	ra,56(sp)
    800015c4:	7442                	ld	s0,48(sp)
    800015c6:	74a2                	ld	s1,40(sp)
    800015c8:	7902                	ld	s2,32(sp)
    800015ca:	69e2                	ld	s3,24(sp)
    800015cc:	6a42                	ld	s4,16(sp)
    800015ce:	6aa2                	ld	s5,8(sp)
    800015d0:	6b02                	ld	s6,0(sp)
    800015d2:	6121                	addi	sp,sp,64
    800015d4:	8082                	ret
      kfree(mem);
    800015d6:	8526                	mv	a0,s1
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	492080e7          	jalr	1170(ra) # 80000a6a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015e0:	864e                	mv	a2,s3
    800015e2:	85ca                	mv	a1,s2
    800015e4:	8556                	mv	a0,s5
    800015e6:	00000097          	auipc	ra,0x0
    800015ea:	f1a080e7          	jalr	-230(ra) # 80001500 <uvmdealloc>
      return 0;
    800015ee:	4501                	li	a0,0
    800015f0:	bfc9                	j	800015c2 <uvmalloc+0x7a>
    return oldsz;
    800015f2:	852e                	mv	a0,a1
}
    800015f4:	8082                	ret
  return newsz;
    800015f6:	8532                	mv	a0,a2
    800015f8:	b7e9                	j	800015c2 <uvmalloc+0x7a>

00000000800015fa <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800015fa:	7179                	addi	sp,sp,-48
    800015fc:	f406                	sd	ra,40(sp)
    800015fe:	f022                	sd	s0,32(sp)
    80001600:	ec26                	sd	s1,24(sp)
    80001602:	e84a                	sd	s2,16(sp)
    80001604:	e44e                	sd	s3,8(sp)
    80001606:	e052                	sd	s4,0(sp)
    80001608:	1800                	addi	s0,sp,48
    8000160a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000160c:	84aa                	mv	s1,a0
    8000160e:	6905                	lui	s2,0x1
    80001610:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001612:	4985                	li	s3,1
    80001614:	a821                	j	8000162c <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001616:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001618:	0532                	slli	a0,a0,0xc
    8000161a:	00000097          	auipc	ra,0x0
    8000161e:	fe0080e7          	jalr	-32(ra) # 800015fa <freewalk>
      pagetable[i] = 0;
    80001622:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001626:	04a1                	addi	s1,s1,8
    80001628:	03248163          	beq	s1,s2,8000164a <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000162c:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000162e:	00f57793          	andi	a5,a0,15
    80001632:	ff3782e3          	beq	a5,s3,80001616 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001636:	8905                	andi	a0,a0,1
    80001638:	d57d                	beqz	a0,80001626 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000163a:	00007517          	auipc	a0,0x7
    8000163e:	b6650513          	addi	a0,a0,-1178 # 800081a0 <digits+0x160>
    80001642:	fffff097          	auipc	ra,0xfffff
    80001646:	f02080e7          	jalr	-254(ra) # 80000544 <panic>
    }
  }
  kfree((void*)pagetable);
    8000164a:	8552                	mv	a0,s4
    8000164c:	fffff097          	auipc	ra,0xfffff
    80001650:	41e080e7          	jalr	1054(ra) # 80000a6a <kfree>
}
    80001654:	70a2                	ld	ra,40(sp)
    80001656:	7402                	ld	s0,32(sp)
    80001658:	64e2                	ld	s1,24(sp)
    8000165a:	6942                	ld	s2,16(sp)
    8000165c:	69a2                	ld	s3,8(sp)
    8000165e:	6a02                	ld	s4,0(sp)
    80001660:	6145                	addi	sp,sp,48
    80001662:	8082                	ret

0000000080001664 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001664:	1101                	addi	sp,sp,-32
    80001666:	ec06                	sd	ra,24(sp)
    80001668:	e822                	sd	s0,16(sp)
    8000166a:	e426                	sd	s1,8(sp)
    8000166c:	1000                	addi	s0,sp,32
    8000166e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001670:	e999                	bnez	a1,80001686 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001672:	8526                	mv	a0,s1
    80001674:	00000097          	auipc	ra,0x0
    80001678:	f86080e7          	jalr	-122(ra) # 800015fa <freewalk>
}
    8000167c:	60e2                	ld	ra,24(sp)
    8000167e:	6442                	ld	s0,16(sp)
    80001680:	64a2                	ld	s1,8(sp)
    80001682:	6105                	addi	sp,sp,32
    80001684:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001686:	6605                	lui	a2,0x1
    80001688:	167d                	addi	a2,a2,-1
    8000168a:	962e                	add	a2,a2,a1
    8000168c:	4685                	li	a3,1
    8000168e:	8231                	srli	a2,a2,0xc
    80001690:	4581                	li	a1,0
    80001692:	00000097          	auipc	ra,0x0
    80001696:	d0a080e7          	jalr	-758(ra) # 8000139c <uvmunmap>
    8000169a:	bfe1                	j	80001672 <uvmfree+0xe>

000000008000169c <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    8000169c:	715d                	addi	sp,sp,-80
    8000169e:	e486                	sd	ra,72(sp)
    800016a0:	e0a2                	sd	s0,64(sp)
    800016a2:	fc26                	sd	s1,56(sp)
    800016a4:	f84a                	sd	s2,48(sp)
    800016a6:	f44e                	sd	s3,40(sp)
    800016a8:	f052                	sd	s4,32(sp)
    800016aa:	ec56                	sd	s5,24(sp)
    800016ac:	e85a                	sd	s6,16(sp)
    800016ae:	e45e                	sd	s7,8(sp)
    800016b0:	0880                	addi	s0,sp,80
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  // char *mem;

  for(i = 0; i < sz; i += PGSIZE)
    800016b2:	c271                	beqz	a2,80001776 <uvmcopy+0xda>
    800016b4:	8a2a                	mv	s4,a0
    800016b6:	89ae                	mv	s3,a1
    800016b8:	8932                	mv	s2,a2
    800016ba:	4481                	li	s1,0
    flags = PTE_FLAGS(*pte);
    // for COW
    if(flags & PTE_W){
      flags = flags & (~PTE_W);
      flags = flags | PTE_COW;
      *pte = PA2PTE(pa)|flags;
    800016bc:	7afd                	lui	s5,0xfffff
    800016be:	002ada93          	srli	s5,s5,0x2
    800016c2:	a8a9                	j	8000171c <uvmcopy+0x80>
      panic("uvmcopy: pte should exist");
    800016c4:	00007517          	auipc	a0,0x7
    800016c8:	aec50513          	addi	a0,a0,-1300 # 800081b0 <digits+0x170>
    800016cc:	fffff097          	auipc	ra,0xfffff
    800016d0:	e78080e7          	jalr	-392(ra) # 80000544 <panic>
      panic("uvmcopy: page not present");
    800016d4:	00007517          	auipc	a0,0x7
    800016d8:	afc50513          	addi	a0,a0,-1284 # 800081d0 <digits+0x190>
    800016dc:	fffff097          	auipc	ra,0xfffff
    800016e0:	e68080e7          	jalr	-408(ra) # 80000544 <panic>
      flags = flags & (~PTE_W);
    800016e4:	3fb77693          	andi	a3,a4,1019
      flags = flags | PTE_COW;
    800016e8:	0206e713          	ori	a4,a3,32
      *pte = PA2PTE(pa)|flags;
    800016ec:	0157f7b3          	and	a5,a5,s5
    800016f0:	8fd9                	or	a5,a5,a4
    800016f2:	e11c                	sd	a5,0(a0)
    }

    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0)
    800016f4:	86da                	mv	a3,s6
    800016f6:	6605                	lui	a2,0x1
    800016f8:	85a6                	mv	a1,s1
    800016fa:	854e                	mv	a0,s3
    800016fc:	00000097          	auipc	ra,0x0
    80001700:	ada080e7          	jalr	-1318(ra) # 800011d6 <mappages>
    80001704:	8baa                	mv	s7,a0
    80001706:	e131                	bnez	a0,8000174a <uvmcopy+0xae>
    {
      goto err;
    }
    check_and_increment((uint64)pa/PGSIZE);
    80001708:	00cb5513          	srli	a0,s6,0xc
    8000170c:	fffff097          	auipc	ra,0xfffff
    80001710:	2f2080e7          	jalr	754(ra) # 800009fe <check_and_increment>
  for(i = 0; i < sz; i += PGSIZE)
    80001714:	6785                	lui	a5,0x1
    80001716:	94be                	add	s1,s1,a5
    80001718:	0524f363          	bgeu	s1,s2,8000175e <uvmcopy+0xc2>
    if((pte = walk(old, i, 0)) == 0)
    8000171c:	4601                	li	a2,0
    8000171e:	85a6                	mv	a1,s1
    80001720:	8552                	mv	a0,s4
    80001722:	00000097          	auipc	ra,0x0
    80001726:	9cc080e7          	jalr	-1588(ra) # 800010ee <walk>
    8000172a:	dd49                	beqz	a0,800016c4 <uvmcopy+0x28>
    if((*pte & PTE_V) == 0)
    8000172c:	611c                	ld	a5,0(a0)
    8000172e:	0017f713          	andi	a4,a5,1
    80001732:	d34d                	beqz	a4,800016d4 <uvmcopy+0x38>
    pa = PTE2PA(*pte);
    80001734:	00a7db13          	srli	s6,a5,0xa
    80001738:	0b32                	slli	s6,s6,0xc
    flags = PTE_FLAGS(*pte);
    8000173a:	0007871b          	sext.w	a4,a5
    if(flags & PTE_W){
    8000173e:	00477693          	andi	a3,a4,4
    80001742:	f2cd                	bnez	a3,800016e4 <uvmcopy+0x48>
    flags = PTE_FLAGS(*pte);
    80001744:	3ff77713          	andi	a4,a4,1023
    80001748:	b775                	j	800016f4 <uvmcopy+0x58>

  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000174a:	4685                	li	a3,1
    8000174c:	00c4d613          	srli	a2,s1,0xc
    80001750:	4581                	li	a1,0
    80001752:	854e                	mv	a0,s3
    80001754:	00000097          	auipc	ra,0x0
    80001758:	c48080e7          	jalr	-952(ra) # 8000139c <uvmunmap>
  return -1;
    8000175c:	5bfd                	li	s7,-1
}
    8000175e:	855e                	mv	a0,s7
    80001760:	60a6                	ld	ra,72(sp)
    80001762:	6406                	ld	s0,64(sp)
    80001764:	74e2                	ld	s1,56(sp)
    80001766:	7942                	ld	s2,48(sp)
    80001768:	79a2                	ld	s3,40(sp)
    8000176a:	7a02                	ld	s4,32(sp)
    8000176c:	6ae2                	ld	s5,24(sp)
    8000176e:	6b42                	ld	s6,16(sp)
    80001770:	6ba2                	ld	s7,8(sp)
    80001772:	6161                	addi	sp,sp,80
    80001774:	8082                	ret
  return 0;
    80001776:	4b81                	li	s7,0
    80001778:	b7dd                	j	8000175e <uvmcopy+0xc2>

000000008000177a <custom_cow>:

// for COW
int custom_cow(pagetable_t pt, uint64 va) {
    8000177a:	7179                	addi	sp,sp,-48
    8000177c:	f406                	sd	ra,40(sp)
    8000177e:	f022                	sd	s0,32(sp)
    80001780:	ec26                	sd	s1,24(sp)
    80001782:	e84a                	sd	s2,16(sp)
    80001784:	e44e                	sd	s3,8(sp)
    80001786:	e052                	sd	s4,0(sp)
    80001788:	1800                	addi	s0,sp,48
    va = PGROUNDDOWN(va);
    8000178a:	77fd                	lui	a5,0xfffff
    8000178c:	8dfd                	and	a1,a1,a5

    if (va > MAXVA) {
    8000178e:	4785                	li	a5,1
    80001790:	179a                	slli	a5,a5,0x26
    80001792:	06b7e763          	bltu	a5,a1,80001800 <custom_cow+0x86>
        printf("custom_cow: Virtual address out of bounds\n");
        return 1;
    }

    pte_t *pte = walk(pt, va, 0);
    80001796:	4601                	li	a2,0
    80001798:	00000097          	auipc	ra,0x0
    8000179c:	956080e7          	jalr	-1706(ra) # 800010ee <walk>
    800017a0:	892a                	mv	s2,a0

    if (!pte) {
    800017a2:	c92d                	beqz	a0,80001814 <custom_cow+0x9a>
        panic("custom_cow: pte should exist");
        return 1;
    }

    if (!(*pte & PTE_V)) {
    800017a4:	6104                	ld	s1,0(a0)
    800017a6:	0014f793          	andi	a5,s1,1
    800017aa:	cfad                	beqz	a5,80001824 <custom_cow+0xaa>
        panic("custom_cow: Page not present");
        return 1;
    }

    // Check if COW or not
    if (!(*pte & PTE_COW)) {
    800017ac:	0204f793          	andi	a5,s1,32
    800017b0:	c3d1                	beqz	a5,80001834 <custom_cow+0xba>
        printf("custom_cow: Page is not COW\n");
        return 1;
    }

    // If not COW, then it wasn't writable before.
    uint64 pa = PTE2PA(*pte);
    800017b2:	00a4da13          	srli	s4,s1,0xa
    800017b6:	0a32                	slli	s4,s4,0xc
    uint64 flags = PTE_FLAGS(*pte);

    // Update flags for Copy-on-Write
    flags &= ~PTE_COW;
    800017b8:	3df4f993          	andi	s3,s1,991
    flags |= PTE_W;

    // Allocate new memory
    char *mem = kalloc();
    800017bc:	fffff097          	auipc	ra,0xfffff
    800017c0:	444080e7          	jalr	1092(ra) # 80000c00 <kalloc>
    800017c4:	84aa                	mv	s1,a0

    if (!mem) {
    800017c6:	c149                	beqz	a0,80001848 <custom_cow+0xce>
        printf("custom_cow: kalloc error\n");
        return 1;
    }

    // Copy data from old page to new page
    memmove(mem, (char *)pa, PGSIZE);
    800017c8:	6605                	lui	a2,0x1
    800017ca:	85d2                	mv	a1,s4
    800017cc:	fffff097          	auipc	ra,0xfffff
    800017d0:	696080e7          	jalr	1686(ra) # 80000e62 <memmove>

    // Update page table entry
    *pte = PA2PTE(mem) | flags;
    800017d4:	80b1                	srli	s1,s1,0xc
    800017d6:	04aa                	slli	s1,s1,0xa
    800017d8:	0134e4b3          	or	s1,s1,s3
    800017dc:	0044e493          	ori	s1,s1,4
    800017e0:	00993023          	sd	s1,0(s2) # 1000 <_entry-0x7ffff000>

    // Free the old page
    kfree((void *)pa);
    800017e4:	8552                	mv	a0,s4
    800017e6:	fffff097          	auipc	ra,0xfffff
    800017ea:	284080e7          	jalr	644(ra) # 80000a6a <kfree>

    return 0;
    800017ee:	4501                	li	a0,0
}
    800017f0:	70a2                	ld	ra,40(sp)
    800017f2:	7402                	ld	s0,32(sp)
    800017f4:	64e2                	ld	s1,24(sp)
    800017f6:	6942                	ld	s2,16(sp)
    800017f8:	69a2                	ld	s3,8(sp)
    800017fa:	6a02                	ld	s4,0(sp)
    800017fc:	6145                	addi	sp,sp,48
    800017fe:	8082                	ret
        printf("custom_cow: Virtual address out of bounds\n");
    80001800:	00007517          	auipc	a0,0x7
    80001804:	9f050513          	addi	a0,a0,-1552 # 800081f0 <digits+0x1b0>
    80001808:	fffff097          	auipc	ra,0xfffff
    8000180c:	d86080e7          	jalr	-634(ra) # 8000058e <printf>
        return 1;
    80001810:	4505                	li	a0,1
    80001812:	bff9                	j	800017f0 <custom_cow+0x76>
        panic("custom_cow: pte should exist");
    80001814:	00007517          	auipc	a0,0x7
    80001818:	a0c50513          	addi	a0,a0,-1524 # 80008220 <digits+0x1e0>
    8000181c:	fffff097          	auipc	ra,0xfffff
    80001820:	d28080e7          	jalr	-728(ra) # 80000544 <panic>
        panic("custom_cow: Page not present");
    80001824:	00007517          	auipc	a0,0x7
    80001828:	a1c50513          	addi	a0,a0,-1508 # 80008240 <digits+0x200>
    8000182c:	fffff097          	auipc	ra,0xfffff
    80001830:	d18080e7          	jalr	-744(ra) # 80000544 <panic>
        printf("custom_cow: Page is not COW\n");
    80001834:	00007517          	auipc	a0,0x7
    80001838:	a2c50513          	addi	a0,a0,-1492 # 80008260 <digits+0x220>
    8000183c:	fffff097          	auipc	ra,0xfffff
    80001840:	d52080e7          	jalr	-686(ra) # 8000058e <printf>
        return 1;
    80001844:	4505                	li	a0,1
    80001846:	b76d                	j	800017f0 <custom_cow+0x76>
        printf("custom_cow: kalloc error\n");
    80001848:	00007517          	auipc	a0,0x7
    8000184c:	a3850513          	addi	a0,a0,-1480 # 80008280 <digits+0x240>
    80001850:	fffff097          	auipc	ra,0xfffff
    80001854:	d3e080e7          	jalr	-706(ra) # 8000058e <printf>
        return 1;
    80001858:	4505                	li	a0,1
    8000185a:	bf59                	j	800017f0 <custom_cow+0x76>

000000008000185c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000185c:	1141                	addi	sp,sp,-16
    8000185e:	e406                	sd	ra,8(sp)
    80001860:	e022                	sd	s0,0(sp)
    80001862:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001864:	4601                	li	a2,0
    80001866:	00000097          	auipc	ra,0x0
    8000186a:	888080e7          	jalr	-1912(ra) # 800010ee <walk>
  if(pte == 0)
    8000186e:	c901                	beqz	a0,8000187e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001870:	611c                	ld	a5,0(a0)
    80001872:	9bbd                	andi	a5,a5,-17
    80001874:	e11c                	sd	a5,0(a0)
}
    80001876:	60a2                	ld	ra,8(sp)
    80001878:	6402                	ld	s0,0(sp)
    8000187a:	0141                	addi	sp,sp,16
    8000187c:	8082                	ret
    panic("uvmclear");
    8000187e:	00007517          	auipc	a0,0x7
    80001882:	a2250513          	addi	a0,a0,-1502 # 800082a0 <digits+0x260>
    80001886:	fffff097          	auipc	ra,0xfffff
    8000188a:	cbe080e7          	jalr	-834(ra) # 80000544 <panic>

000000008000188e <copyout>:
  uint64 n, va0, pa0;

  // for COW
  pte_t *pte;

  while(len > 0){
    8000188e:	c2d5                	beqz	a3,80001932 <copyout+0xa4>
{
    80001890:	711d                	addi	sp,sp,-96
    80001892:	ec86                	sd	ra,88(sp)
    80001894:	e8a2                	sd	s0,80(sp)
    80001896:	e4a6                	sd	s1,72(sp)
    80001898:	e0ca                	sd	s2,64(sp)
    8000189a:	fc4e                	sd	s3,56(sp)
    8000189c:	f852                	sd	s4,48(sp)
    8000189e:	f456                	sd	s5,40(sp)
    800018a0:	f05a                	sd	s6,32(sp)
    800018a2:	ec5e                	sd	s7,24(sp)
    800018a4:	e862                	sd	s8,16(sp)
    800018a6:	e466                	sd	s9,8(sp)
    800018a8:	1080                	addi	s0,sp,96
    800018aa:	8baa                	mv	s7,a0
    800018ac:	89ae                	mv	s3,a1
    800018ae:	8b32                	mv	s6,a2
    800018b0:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    800018b2:	7cfd                	lui	s9,0xfffff
      pa0 = walkaddr(pagetable,va0);
    }



    n = PGSIZE - (dstva - va0);
    800018b4:	6c05                	lui	s8,0x1
    800018b6:	a081                	j	800018f6 <copyout+0x68>
      custom_cow(pagetable,va0);
    800018b8:	85ca                	mv	a1,s2
    800018ba:	855e                	mv	a0,s7
    800018bc:	00000097          	auipc	ra,0x0
    800018c0:	ebe080e7          	jalr	-322(ra) # 8000177a <custom_cow>
      pa0 = walkaddr(pagetable,va0);
    800018c4:	85ca                	mv	a1,s2
    800018c6:	855e                	mv	a0,s7
    800018c8:	00000097          	auipc	ra,0x0
    800018cc:	8cc080e7          	jalr	-1844(ra) # 80001194 <walkaddr>
    800018d0:	8a2a                	mv	s4,a0
    800018d2:	a0b9                	j	80001920 <copyout+0x92>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800018d4:	41298533          	sub	a0,s3,s2
    800018d8:	0004861b          	sext.w	a2,s1
    800018dc:	85da                	mv	a1,s6
    800018de:	9552                	add	a0,a0,s4
    800018e0:	fffff097          	auipc	ra,0xfffff
    800018e4:	582080e7          	jalr	1410(ra) # 80000e62 <memmove>

    len -= n;
    800018e8:	409a8ab3          	sub	s5,s5,s1
    src += n;
    800018ec:	9b26                	add	s6,s6,s1
    dstva = va0 + PGSIZE;
    800018ee:	018909b3          	add	s3,s2,s8
  while(len > 0){
    800018f2:	020a8e63          	beqz	s5,8000192e <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    800018f6:	0199f933          	and	s2,s3,s9
    pa0 = walkaddr(pagetable, va0);
    800018fa:	85ca                	mv	a1,s2
    800018fc:	855e                	mv	a0,s7
    800018fe:	00000097          	auipc	ra,0x0
    80001902:	896080e7          	jalr	-1898(ra) # 80001194 <walkaddr>
    80001906:	8a2a                	mv	s4,a0
    if(pa0 == 0)
    80001908:	c51d                	beqz	a0,80001936 <copyout+0xa8>
    pte = walk(pagetable,va0,0); 
    8000190a:	4601                	li	a2,0
    8000190c:	85ca                	mv	a1,s2
    8000190e:	855e                	mv	a0,s7
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	7de080e7          	jalr	2014(ra) # 800010ee <walk>
    if(*pte & PTE_COW){
    80001918:	611c                	ld	a5,0(a0)
    8000191a:	0207f793          	andi	a5,a5,32
    8000191e:	ffc9                	bnez	a5,800018b8 <copyout+0x2a>
    n = PGSIZE - (dstva - va0);
    80001920:	413904b3          	sub	s1,s2,s3
    80001924:	94e2                	add	s1,s1,s8
    if(n > len)
    80001926:	fa9af7e3          	bgeu	s5,s1,800018d4 <copyout+0x46>
    8000192a:	84d6                	mv	s1,s5
    8000192c:	b765                	j	800018d4 <copyout+0x46>
  }
  return 0;
    8000192e:	4501                	li	a0,0
    80001930:	a021                	j	80001938 <copyout+0xaa>
    80001932:	4501                	li	a0,0
}
    80001934:	8082                	ret
      return -1;
    80001936:	557d                	li	a0,-1
}
    80001938:	60e6                	ld	ra,88(sp)
    8000193a:	6446                	ld	s0,80(sp)
    8000193c:	64a6                	ld	s1,72(sp)
    8000193e:	6906                	ld	s2,64(sp)
    80001940:	79e2                	ld	s3,56(sp)
    80001942:	7a42                	ld	s4,48(sp)
    80001944:	7aa2                	ld	s5,40(sp)
    80001946:	7b02                	ld	s6,32(sp)
    80001948:	6be2                	ld	s7,24(sp)
    8000194a:	6c42                	ld	s8,16(sp)
    8000194c:	6ca2                	ld	s9,8(sp)
    8000194e:	6125                	addi	sp,sp,96
    80001950:	8082                	ret

0000000080001952 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001952:	c6bd                	beqz	a3,800019c0 <copyin+0x6e>
{
    80001954:	715d                	addi	sp,sp,-80
    80001956:	e486                	sd	ra,72(sp)
    80001958:	e0a2                	sd	s0,64(sp)
    8000195a:	fc26                	sd	s1,56(sp)
    8000195c:	f84a                	sd	s2,48(sp)
    8000195e:	f44e                	sd	s3,40(sp)
    80001960:	f052                	sd	s4,32(sp)
    80001962:	ec56                	sd	s5,24(sp)
    80001964:	e85a                	sd	s6,16(sp)
    80001966:	e45e                	sd	s7,8(sp)
    80001968:	e062                	sd	s8,0(sp)
    8000196a:	0880                	addi	s0,sp,80
    8000196c:	8b2a                	mv	s6,a0
    8000196e:	8a2e                	mv	s4,a1
    80001970:	8c32                	mv	s8,a2
    80001972:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001974:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001976:	6a85                	lui	s5,0x1
    80001978:	a015                	j	8000199c <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000197a:	9562                	add	a0,a0,s8
    8000197c:	0004861b          	sext.w	a2,s1
    80001980:	412505b3          	sub	a1,a0,s2
    80001984:	8552                	mv	a0,s4
    80001986:	fffff097          	auipc	ra,0xfffff
    8000198a:	4dc080e7          	jalr	1244(ra) # 80000e62 <memmove>

    len -= n;
    8000198e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001992:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001994:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001998:	02098263          	beqz	s3,800019bc <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000199c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800019a0:	85ca                	mv	a1,s2
    800019a2:	855a                	mv	a0,s6
    800019a4:	fffff097          	auipc	ra,0xfffff
    800019a8:	7f0080e7          	jalr	2032(ra) # 80001194 <walkaddr>
    if(pa0 == 0)
    800019ac:	cd01                	beqz	a0,800019c4 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    800019ae:	418904b3          	sub	s1,s2,s8
    800019b2:	94d6                	add	s1,s1,s5
    if(n > len)
    800019b4:	fc99f3e3          	bgeu	s3,s1,8000197a <copyin+0x28>
    800019b8:	84ce                	mv	s1,s3
    800019ba:	b7c1                	j	8000197a <copyin+0x28>
  }
  return 0;
    800019bc:	4501                	li	a0,0
    800019be:	a021                	j	800019c6 <copyin+0x74>
    800019c0:	4501                	li	a0,0
}
    800019c2:	8082                	ret
      return -1;
    800019c4:	557d                	li	a0,-1
}
    800019c6:	60a6                	ld	ra,72(sp)
    800019c8:	6406                	ld	s0,64(sp)
    800019ca:	74e2                	ld	s1,56(sp)
    800019cc:	7942                	ld	s2,48(sp)
    800019ce:	79a2                	ld	s3,40(sp)
    800019d0:	7a02                	ld	s4,32(sp)
    800019d2:	6ae2                	ld	s5,24(sp)
    800019d4:	6b42                	ld	s6,16(sp)
    800019d6:	6ba2                	ld	s7,8(sp)
    800019d8:	6c02                	ld	s8,0(sp)
    800019da:	6161                	addi	sp,sp,80
    800019dc:	8082                	ret

00000000800019de <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800019de:	c6c5                	beqz	a3,80001a86 <copyinstr+0xa8>
{
    800019e0:	715d                	addi	sp,sp,-80
    800019e2:	e486                	sd	ra,72(sp)
    800019e4:	e0a2                	sd	s0,64(sp)
    800019e6:	fc26                	sd	s1,56(sp)
    800019e8:	f84a                	sd	s2,48(sp)
    800019ea:	f44e                	sd	s3,40(sp)
    800019ec:	f052                	sd	s4,32(sp)
    800019ee:	ec56                	sd	s5,24(sp)
    800019f0:	e85a                	sd	s6,16(sp)
    800019f2:	e45e                	sd	s7,8(sp)
    800019f4:	0880                	addi	s0,sp,80
    800019f6:	8a2a                	mv	s4,a0
    800019f8:	8b2e                	mv	s6,a1
    800019fa:	8bb2                	mv	s7,a2
    800019fc:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800019fe:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a00:	6985                	lui	s3,0x1
    80001a02:	a035                	j	80001a2e <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001a04:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7fdbc7a8>
    80001a08:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001a0a:	0017b793          	seqz	a5,a5
    80001a0e:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001a12:	60a6                	ld	ra,72(sp)
    80001a14:	6406                	ld	s0,64(sp)
    80001a16:	74e2                	ld	s1,56(sp)
    80001a18:	7942                	ld	s2,48(sp)
    80001a1a:	79a2                	ld	s3,40(sp)
    80001a1c:	7a02                	ld	s4,32(sp)
    80001a1e:	6ae2                	ld	s5,24(sp)
    80001a20:	6b42                	ld	s6,16(sp)
    80001a22:	6ba2                	ld	s7,8(sp)
    80001a24:	6161                	addi	sp,sp,80
    80001a26:	8082                	ret
    srcva = va0 + PGSIZE;
    80001a28:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001a2c:	c8a9                	beqz	s1,80001a7e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001a2e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001a32:	85ca                	mv	a1,s2
    80001a34:	8552                	mv	a0,s4
    80001a36:	fffff097          	auipc	ra,0xfffff
    80001a3a:	75e080e7          	jalr	1886(ra) # 80001194 <walkaddr>
    if(pa0 == 0)
    80001a3e:	c131                	beqz	a0,80001a82 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001a40:	41790833          	sub	a6,s2,s7
    80001a44:	984e                	add	a6,a6,s3
    if(n > max)
    80001a46:	0104f363          	bgeu	s1,a6,80001a4c <copyinstr+0x6e>
    80001a4a:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001a4c:	955e                	add	a0,a0,s7
    80001a4e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001a52:	fc080be3          	beqz	a6,80001a28 <copyinstr+0x4a>
    80001a56:	985a                	add	a6,a6,s6
    80001a58:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001a5a:	41650633          	sub	a2,a0,s6
    80001a5e:	14fd                	addi	s1,s1,-1
    80001a60:	9b26                	add	s6,s6,s1
    80001a62:	00f60733          	add	a4,a2,a5
    80001a66:	00074703          	lbu	a4,0(a4)
    80001a6a:	df49                	beqz	a4,80001a04 <copyinstr+0x26>
        *dst = *p;
    80001a6c:	00e78023          	sb	a4,0(a5)
      --max;
    80001a70:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001a74:	0785                	addi	a5,a5,1
    while(n > 0){
    80001a76:	ff0796e3          	bne	a5,a6,80001a62 <copyinstr+0x84>
      dst++;
    80001a7a:	8b42                	mv	s6,a6
    80001a7c:	b775                	j	80001a28 <copyinstr+0x4a>
    80001a7e:	4781                	li	a5,0
    80001a80:	b769                	j	80001a0a <copyinstr+0x2c>
      return -1;
    80001a82:	557d                	li	a0,-1
    80001a84:	b779                	j	80001a12 <copyinstr+0x34>
  int got_null = 0;
    80001a86:	4781                	li	a5,0
  if(got_null){
    80001a88:	0017b793          	seqz	a5,a5
    80001a8c:	40f00533          	neg	a0,a5
}
    80001a90:	8082                	ret

0000000080001a92 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001a92:	7139                	addi	sp,sp,-64
    80001a94:	fc06                	sd	ra,56(sp)
    80001a96:	f822                	sd	s0,48(sp)
    80001a98:	f426                	sd	s1,40(sp)
    80001a9a:	f04a                	sd	s2,32(sp)
    80001a9c:	ec4e                	sd	s3,24(sp)
    80001a9e:	e852                	sd	s4,16(sp)
    80001aa0:	e456                	sd	s5,8(sp)
    80001aa2:	e05a                	sd	s6,0(sp)
    80001aa4:	0080                	addi	s0,sp,64
    80001aa6:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001aa8:	0022f497          	auipc	s1,0x22f
    80001aac:	5d048493          	addi	s1,s1,1488 # 80231078 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001ab0:	8b26                	mv	s6,s1
    80001ab2:	00006a97          	auipc	s5,0x6
    80001ab6:	54ea8a93          	addi	s5,s5,1358 # 80008000 <etext>
    80001aba:	04000937          	lui	s2,0x4000
    80001abe:	197d                	addi	s2,s2,-1
    80001ac0:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001ac2:	00236a17          	auipc	s4,0x236
    80001ac6:	9b6a0a13          	addi	s4,s4,-1610 # 80237478 <tickslock>
    char *pa = kalloc();
    80001aca:	fffff097          	auipc	ra,0xfffff
    80001ace:	136080e7          	jalr	310(ra) # 80000c00 <kalloc>
    80001ad2:	862a                	mv	a2,a0
    if (pa == 0)
    80001ad4:	c131                	beqz	a0,80001b18 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001ad6:	416485b3          	sub	a1,s1,s6
    80001ada:	8591                	srai	a1,a1,0x4
    80001adc:	000ab783          	ld	a5,0(s5)
    80001ae0:	02f585b3          	mul	a1,a1,a5
    80001ae4:	2585                	addiw	a1,a1,1
    80001ae6:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001aea:	4719                	li	a4,6
    80001aec:	6685                	lui	a3,0x1
    80001aee:	40b905b3          	sub	a1,s2,a1
    80001af2:	854e                	mv	a0,s3
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	782080e7          	jalr	1922(ra) # 80001276 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    80001afc:	19048493          	addi	s1,s1,400
    80001b00:	fd4495e3          	bne	s1,s4,80001aca <proc_mapstacks+0x38>
  }
}
    80001b04:	70e2                	ld	ra,56(sp)
    80001b06:	7442                	ld	s0,48(sp)
    80001b08:	74a2                	ld	s1,40(sp)
    80001b0a:	7902                	ld	s2,32(sp)
    80001b0c:	69e2                	ld	s3,24(sp)
    80001b0e:	6a42                	ld	s4,16(sp)
    80001b10:	6aa2                	ld	s5,8(sp)
    80001b12:	6b02                	ld	s6,0(sp)
    80001b14:	6121                	addi	sp,sp,64
    80001b16:	8082                	ret
      panic("kalloc");
    80001b18:	00006517          	auipc	a0,0x6
    80001b1c:	79850513          	addi	a0,a0,1944 # 800082b0 <digits+0x270>
    80001b20:	fffff097          	auipc	ra,0xfffff
    80001b24:	a24080e7          	jalr	-1500(ra) # 80000544 <panic>

0000000080001b28 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001b28:	7139                	addi	sp,sp,-64
    80001b2a:	fc06                	sd	ra,56(sp)
    80001b2c:	f822                	sd	s0,48(sp)
    80001b2e:	f426                	sd	s1,40(sp)
    80001b30:	f04a                	sd	s2,32(sp)
    80001b32:	ec4e                	sd	s3,24(sp)
    80001b34:	e852                	sd	s4,16(sp)
    80001b36:	e456                	sd	s5,8(sp)
    80001b38:	e05a                	sd	s6,0(sp)
    80001b3a:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001b3c:	00006597          	auipc	a1,0x6
    80001b40:	77c58593          	addi	a1,a1,1916 # 800082b8 <digits+0x278>
    80001b44:	0022f517          	auipc	a0,0x22f
    80001b48:	10450513          	addi	a0,a0,260 # 80230c48 <pid_lock>
    80001b4c:	fffff097          	auipc	ra,0xfffff
    80001b50:	12a080e7          	jalr	298(ra) # 80000c76 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b54:	00006597          	auipc	a1,0x6
    80001b58:	76c58593          	addi	a1,a1,1900 # 800082c0 <digits+0x280>
    80001b5c:	0022f517          	auipc	a0,0x22f
    80001b60:	10450513          	addi	a0,a0,260 # 80230c60 <wait_lock>
    80001b64:	fffff097          	auipc	ra,0xfffff
    80001b68:	112080e7          	jalr	274(ra) # 80000c76 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    80001b6c:	0022f497          	auipc	s1,0x22f
    80001b70:	50c48493          	addi	s1,s1,1292 # 80231078 <proc>
  {
    initlock(&p->lock, "proc");
    80001b74:	00006b17          	auipc	s6,0x6
    80001b78:	75cb0b13          	addi	s6,s6,1884 # 800082d0 <digits+0x290>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001b7c:	8aa6                	mv	s5,s1
    80001b7e:	00006a17          	auipc	s4,0x6
    80001b82:	482a0a13          	addi	s4,s4,1154 # 80008000 <etext>
    80001b86:	04000937          	lui	s2,0x4000
    80001b8a:	197d                	addi	s2,s2,-1
    80001b8c:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001b8e:	00236997          	auipc	s3,0x236
    80001b92:	8ea98993          	addi	s3,s3,-1814 # 80237478 <tickslock>
    initlock(&p->lock, "proc");
    80001b96:	85da                	mv	a1,s6
    80001b98:	8526                	mv	a0,s1
    80001b9a:	fffff097          	auipc	ra,0xfffff
    80001b9e:	0dc080e7          	jalr	220(ra) # 80000c76 <initlock>
    p->state = UNUSED;
    80001ba2:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001ba6:	415487b3          	sub	a5,s1,s5
    80001baa:	8791                	srai	a5,a5,0x4
    80001bac:	000a3703          	ld	a4,0(s4)
    80001bb0:	02e787b3          	mul	a5,a5,a4
    80001bb4:	2785                	addiw	a5,a5,1
    80001bb6:	00d7979b          	slliw	a5,a5,0xd
    80001bba:	40f907b3          	sub	a5,s2,a5
    80001bbe:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001bc0:	19048493          	addi	s1,s1,400
    80001bc4:	fd3499e3          	bne	s1,s3,80001b96 <procinit+0x6e>
  }
}
    80001bc8:	70e2                	ld	ra,56(sp)
    80001bca:	7442                	ld	s0,48(sp)
    80001bcc:	74a2                	ld	s1,40(sp)
    80001bce:	7902                	ld	s2,32(sp)
    80001bd0:	69e2                	ld	s3,24(sp)
    80001bd2:	6a42                	ld	s4,16(sp)
    80001bd4:	6aa2                	ld	s5,8(sp)
    80001bd6:	6b02                	ld	s6,0(sp)
    80001bd8:	6121                	addi	sp,sp,64
    80001bda:	8082                	ret

0000000080001bdc <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001bdc:	1141                	addi	sp,sp,-16
    80001bde:	e422                	sd	s0,8(sp)
    80001be0:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001be2:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001be4:	2501                	sext.w	a0,a0
    80001be6:	6422                	ld	s0,8(sp)
    80001be8:	0141                	addi	sp,sp,16
    80001bea:	8082                	ret

0000000080001bec <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001bec:	1141                	addi	sp,sp,-16
    80001bee:	e422                	sd	s0,8(sp)
    80001bf0:	0800                	addi	s0,sp,16
    80001bf2:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001bf4:	2781                	sext.w	a5,a5
    80001bf6:	079e                	slli	a5,a5,0x7
  return c;
}
    80001bf8:	0022f517          	auipc	a0,0x22f
    80001bfc:	08050513          	addi	a0,a0,128 # 80230c78 <cpus>
    80001c00:	953e                	add	a0,a0,a5
    80001c02:	6422                	ld	s0,8(sp)
    80001c04:	0141                	addi	sp,sp,16
    80001c06:	8082                	ret

0000000080001c08 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001c08:	1101                	addi	sp,sp,-32
    80001c0a:	ec06                	sd	ra,24(sp)
    80001c0c:	e822                	sd	s0,16(sp)
    80001c0e:	e426                	sd	s1,8(sp)
    80001c10:	1000                	addi	s0,sp,32
  push_off();
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	0a8080e7          	jalr	168(ra) # 80000cba <push_off>
    80001c1a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001c1c:	2781                	sext.w	a5,a5
    80001c1e:	079e                	slli	a5,a5,0x7
    80001c20:	0022f717          	auipc	a4,0x22f
    80001c24:	02870713          	addi	a4,a4,40 # 80230c48 <pid_lock>
    80001c28:	97ba                	add	a5,a5,a4
    80001c2a:	7b84                	ld	s1,48(a5)
  pop_off();
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	12e080e7          	jalr	302(ra) # 80000d5a <pop_off>
  return p;
}
    80001c34:	8526                	mv	a0,s1
    80001c36:	60e2                	ld	ra,24(sp)
    80001c38:	6442                	ld	s0,16(sp)
    80001c3a:	64a2                	ld	s1,8(sp)
    80001c3c:	6105                	addi	sp,sp,32
    80001c3e:	8082                	ret

0000000080001c40 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001c40:	1141                	addi	sp,sp,-16
    80001c42:	e406                	sd	ra,8(sp)
    80001c44:	e022                	sd	s0,0(sp)
    80001c46:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001c48:	00000097          	auipc	ra,0x0
    80001c4c:	fc0080e7          	jalr	-64(ra) # 80001c08 <myproc>
    80001c50:	fffff097          	auipc	ra,0xfffff
    80001c54:	16a080e7          	jalr	362(ra) # 80000dba <release>

  if (first)
    80001c58:	00007797          	auipc	a5,0x7
    80001c5c:	ce87a783          	lw	a5,-792(a5) # 80008940 <first.1725>
    80001c60:	eb89                	bnez	a5,80001c72 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001c62:	00001097          	auipc	ra,0x1
    80001c66:	066080e7          	jalr	102(ra) # 80002cc8 <usertrapret>
}
    80001c6a:	60a2                	ld	ra,8(sp)
    80001c6c:	6402                	ld	s0,0(sp)
    80001c6e:	0141                	addi	sp,sp,16
    80001c70:	8082                	ret
    first = 0;
    80001c72:	00007797          	auipc	a5,0x7
    80001c76:	cc07a723          	sw	zero,-818(a5) # 80008940 <first.1725>
    fsinit(ROOTDEV);
    80001c7a:	4505                	li	a0,1
    80001c7c:	00002097          	auipc	ra,0x2
    80001c80:	fca080e7          	jalr	-54(ra) # 80003c46 <fsinit>
    80001c84:	bff9                	j	80001c62 <forkret+0x22>

0000000080001c86 <allocpid>:
{
    80001c86:	1101                	addi	sp,sp,-32
    80001c88:	ec06                	sd	ra,24(sp)
    80001c8a:	e822                	sd	s0,16(sp)
    80001c8c:	e426                	sd	s1,8(sp)
    80001c8e:	e04a                	sd	s2,0(sp)
    80001c90:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c92:	0022f917          	auipc	s2,0x22f
    80001c96:	fb690913          	addi	s2,s2,-74 # 80230c48 <pid_lock>
    80001c9a:	854a                	mv	a0,s2
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	06a080e7          	jalr	106(ra) # 80000d06 <acquire>
  pid = nextpid;
    80001ca4:	00007797          	auipc	a5,0x7
    80001ca8:	ca078793          	addi	a5,a5,-864 # 80008944 <nextpid>
    80001cac:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001cae:	0014871b          	addiw	a4,s1,1
    80001cb2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001cb4:	854a                	mv	a0,s2
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	104080e7          	jalr	260(ra) # 80000dba <release>
}
    80001cbe:	8526                	mv	a0,s1
    80001cc0:	60e2                	ld	ra,24(sp)
    80001cc2:	6442                	ld	s0,16(sp)
    80001cc4:	64a2                	ld	s1,8(sp)
    80001cc6:	6902                	ld	s2,0(sp)
    80001cc8:	6105                	addi	sp,sp,32
    80001cca:	8082                	ret

0000000080001ccc <proc_pagetable>:
{
    80001ccc:	1101                	addi	sp,sp,-32
    80001cce:	ec06                	sd	ra,24(sp)
    80001cd0:	e822                	sd	s0,16(sp)
    80001cd2:	e426                	sd	s1,8(sp)
    80001cd4:	e04a                	sd	s2,0(sp)
    80001cd6:	1000                	addi	s0,sp,32
    80001cd8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001cda:	fffff097          	auipc	ra,0xfffff
    80001cde:	786080e7          	jalr	1926(ra) # 80001460 <uvmcreate>
    80001ce2:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001ce4:	c121                	beqz	a0,80001d24 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ce6:	4729                	li	a4,10
    80001ce8:	00005697          	auipc	a3,0x5
    80001cec:	31868693          	addi	a3,a3,792 # 80007000 <_trampoline>
    80001cf0:	6605                	lui	a2,0x1
    80001cf2:	040005b7          	lui	a1,0x4000
    80001cf6:	15fd                	addi	a1,a1,-1
    80001cf8:	05b2                	slli	a1,a1,0xc
    80001cfa:	fffff097          	auipc	ra,0xfffff
    80001cfe:	4dc080e7          	jalr	1244(ra) # 800011d6 <mappages>
    80001d02:	02054863          	bltz	a0,80001d32 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d06:	4719                	li	a4,6
    80001d08:	05893683          	ld	a3,88(s2)
    80001d0c:	6605                	lui	a2,0x1
    80001d0e:	020005b7          	lui	a1,0x2000
    80001d12:	15fd                	addi	a1,a1,-1
    80001d14:	05b6                	slli	a1,a1,0xd
    80001d16:	8526                	mv	a0,s1
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	4be080e7          	jalr	1214(ra) # 800011d6 <mappages>
    80001d20:	02054163          	bltz	a0,80001d42 <proc_pagetable+0x76>
}
    80001d24:	8526                	mv	a0,s1
    80001d26:	60e2                	ld	ra,24(sp)
    80001d28:	6442                	ld	s0,16(sp)
    80001d2a:	64a2                	ld	s1,8(sp)
    80001d2c:	6902                	ld	s2,0(sp)
    80001d2e:	6105                	addi	sp,sp,32
    80001d30:	8082                	ret
    uvmfree(pagetable, 0);
    80001d32:	4581                	li	a1,0
    80001d34:	8526                	mv	a0,s1
    80001d36:	00000097          	auipc	ra,0x0
    80001d3a:	92e080e7          	jalr	-1746(ra) # 80001664 <uvmfree>
    return 0;
    80001d3e:	4481                	li	s1,0
    80001d40:	b7d5                	j	80001d24 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d42:	4681                	li	a3,0
    80001d44:	4605                	li	a2,1
    80001d46:	040005b7          	lui	a1,0x4000
    80001d4a:	15fd                	addi	a1,a1,-1
    80001d4c:	05b2                	slli	a1,a1,0xc
    80001d4e:	8526                	mv	a0,s1
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	64c080e7          	jalr	1612(ra) # 8000139c <uvmunmap>
    uvmfree(pagetable, 0);
    80001d58:	4581                	li	a1,0
    80001d5a:	8526                	mv	a0,s1
    80001d5c:	00000097          	auipc	ra,0x0
    80001d60:	908080e7          	jalr	-1784(ra) # 80001664 <uvmfree>
    return 0;
    80001d64:	4481                	li	s1,0
    80001d66:	bf7d                	j	80001d24 <proc_pagetable+0x58>

0000000080001d68 <proc_freepagetable>:
{
    80001d68:	1101                	addi	sp,sp,-32
    80001d6a:	ec06                	sd	ra,24(sp)
    80001d6c:	e822                	sd	s0,16(sp)
    80001d6e:	e426                	sd	s1,8(sp)
    80001d70:	e04a                	sd	s2,0(sp)
    80001d72:	1000                	addi	s0,sp,32
    80001d74:	84aa                	mv	s1,a0
    80001d76:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d78:	4681                	li	a3,0
    80001d7a:	4605                	li	a2,1
    80001d7c:	040005b7          	lui	a1,0x4000
    80001d80:	15fd                	addi	a1,a1,-1
    80001d82:	05b2                	slli	a1,a1,0xc
    80001d84:	fffff097          	auipc	ra,0xfffff
    80001d88:	618080e7          	jalr	1560(ra) # 8000139c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d8c:	4681                	li	a3,0
    80001d8e:	4605                	li	a2,1
    80001d90:	020005b7          	lui	a1,0x2000
    80001d94:	15fd                	addi	a1,a1,-1
    80001d96:	05b6                	slli	a1,a1,0xd
    80001d98:	8526                	mv	a0,s1
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	602080e7          	jalr	1538(ra) # 8000139c <uvmunmap>
  uvmfree(pagetable, sz);
    80001da2:	85ca                	mv	a1,s2
    80001da4:	8526                	mv	a0,s1
    80001da6:	00000097          	auipc	ra,0x0
    80001daa:	8be080e7          	jalr	-1858(ra) # 80001664 <uvmfree>
}
    80001dae:	60e2                	ld	ra,24(sp)
    80001db0:	6442                	ld	s0,16(sp)
    80001db2:	64a2                	ld	s1,8(sp)
    80001db4:	6902                	ld	s2,0(sp)
    80001db6:	6105                	addi	sp,sp,32
    80001db8:	8082                	ret

0000000080001dba <freeproc>:
{
    80001dba:	1101                	addi	sp,sp,-32
    80001dbc:	ec06                	sd	ra,24(sp)
    80001dbe:	e822                	sd	s0,16(sp)
    80001dc0:	e426                	sd	s1,8(sp)
    80001dc2:	1000                	addi	s0,sp,32
    80001dc4:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001dc6:	6d28                	ld	a0,88(a0)
    80001dc8:	c509                	beqz	a0,80001dd2 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	ca0080e7          	jalr	-864(ra) # 80000a6a <kfree>
  p->trapframe = 0;
    80001dd2:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001dd6:	68a8                	ld	a0,80(s1)
    80001dd8:	c511                	beqz	a0,80001de4 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001dda:	64ac                	ld	a1,72(s1)
    80001ddc:	00000097          	auipc	ra,0x0
    80001de0:	f8c080e7          	jalr	-116(ra) # 80001d68 <proc_freepagetable>
  p->pagetable = 0;
    80001de4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001de8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001dec:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001df0:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001df4:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001df8:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001dfc:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001e00:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001e04:	0004ac23          	sw	zero,24(s1)
  p->pbs_static_priority = 0;
    80001e08:	1604aa23          	sw	zero,372(s1)
  p->pbs_dynamic_priority = 0;
    80001e0c:	1604ac23          	sw	zero,376(s1)
  p->pbs_rbi = 0;
    80001e10:	1604ae23          	sw	zero,380(s1)
  p->pbs_rtime = 0;
    80001e14:	1804a023          	sw	zero,384(s1)
  p->pbs_wtime = 0;
    80001e18:	1804a223          	sw	zero,388(s1)
  p->pbs_stime = 0;
    80001e1c:	1804a423          	sw	zero,392(s1)
  p->pbs_num_sched = 0;
    80001e20:	1804a623          	sw	zero,396(s1)
}
    80001e24:	60e2                	ld	ra,24(sp)
    80001e26:	6442                	ld	s0,16(sp)
    80001e28:	64a2                	ld	s1,8(sp)
    80001e2a:	6105                	addi	sp,sp,32
    80001e2c:	8082                	ret

0000000080001e2e <allocproc>:
{
    80001e2e:	1101                	addi	sp,sp,-32
    80001e30:	ec06                	sd	ra,24(sp)
    80001e32:	e822                	sd	s0,16(sp)
    80001e34:	e426                	sd	s1,8(sp)
    80001e36:	e04a                	sd	s2,0(sp)
    80001e38:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001e3a:	0022f497          	auipc	s1,0x22f
    80001e3e:	23e48493          	addi	s1,s1,574 # 80231078 <proc>
    80001e42:	00235917          	auipc	s2,0x235
    80001e46:	63690913          	addi	s2,s2,1590 # 80237478 <tickslock>
    acquire(&p->lock);
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	eba080e7          	jalr	-326(ra) # 80000d06 <acquire>
    if (p->state == UNUSED)
    80001e54:	4c9c                	lw	a5,24(s1)
    80001e56:	cf81                	beqz	a5,80001e6e <allocproc+0x40>
      release(&p->lock);
    80001e58:	8526                	mv	a0,s1
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	f60080e7          	jalr	-160(ra) # 80000dba <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001e62:	19048493          	addi	s1,s1,400
    80001e66:	ff2492e3          	bne	s1,s2,80001e4a <allocproc+0x1c>
  return 0;
    80001e6a:	4481                	li	s1,0
    80001e6c:	a059                	j	80001ef2 <allocproc+0xc4>
  p->pid = allocpid();
    80001e6e:	00000097          	auipc	ra,0x0
    80001e72:	e18080e7          	jalr	-488(ra) # 80001c86 <allocpid>
    80001e76:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001e78:	4785                	li	a5,1
    80001e7a:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	d84080e7          	jalr	-636(ra) # 80000c00 <kalloc>
    80001e84:	892a                	mv	s2,a0
    80001e86:	eca8                	sd	a0,88(s1)
    80001e88:	cd25                	beqz	a0,80001f00 <allocproc+0xd2>
  p->pagetable = proc_pagetable(p);
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	00000097          	auipc	ra,0x0
    80001e90:	e40080e7          	jalr	-448(ra) # 80001ccc <proc_pagetable>
    80001e94:	892a                	mv	s2,a0
    80001e96:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001e98:	c141                	beqz	a0,80001f18 <allocproc+0xea>
  memset(&p->context, 0, sizeof(p->context));
    80001e9a:	07000613          	li	a2,112
    80001e9e:	4581                	li	a1,0
    80001ea0:	06048513          	addi	a0,s1,96
    80001ea4:	fffff097          	auipc	ra,0xfffff
    80001ea8:	f5e080e7          	jalr	-162(ra) # 80000e02 <memset>
  p->context.ra = (uint64)forkret;
    80001eac:	00000797          	auipc	a5,0x0
    80001eb0:	d9478793          	addi	a5,a5,-620 # 80001c40 <forkret>
    80001eb4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001eb6:	60bc                	ld	a5,64(s1)
    80001eb8:	6705                	lui	a4,0x1
    80001eba:	97ba                	add	a5,a5,a4
    80001ebc:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001ebe:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001ec2:	1604a823          	sw	zero,368(s1)
  p->ctime = ticks;
    80001ec6:	00007797          	auipc	a5,0x7
    80001eca:	afa7a783          	lw	a5,-1286(a5) # 800089c0 <ticks>
    80001ece:	16f4a623          	sw	a5,364(s1)
  p->pbs_static_priority = 50;
    80001ed2:	03200793          	li	a5,50
    80001ed6:	16f4aa23          	sw	a5,372(s1)
  p->pbs_dynamic_priority = 0;
    80001eda:	1604ac23          	sw	zero,376(s1)
  p->pbs_rbi = 0;
    80001ede:	1604ae23          	sw	zero,380(s1)
  p->pbs_rtime = 0;
    80001ee2:	1804a023          	sw	zero,384(s1)
  p->pbs_wtime = 0;
    80001ee6:	1804a223          	sw	zero,388(s1)
  p->pbs_stime = 0;
    80001eea:	1804a423          	sw	zero,392(s1)
  p->pbs_num_sched = 0;
    80001eee:	1804a623          	sw	zero,396(s1)
}
    80001ef2:	8526                	mv	a0,s1
    80001ef4:	60e2                	ld	ra,24(sp)
    80001ef6:	6442                	ld	s0,16(sp)
    80001ef8:	64a2                	ld	s1,8(sp)
    80001efa:	6902                	ld	s2,0(sp)
    80001efc:	6105                	addi	sp,sp,32
    80001efe:	8082                	ret
    freeproc(p);
    80001f00:	8526                	mv	a0,s1
    80001f02:	00000097          	auipc	ra,0x0
    80001f06:	eb8080e7          	jalr	-328(ra) # 80001dba <freeproc>
    release(&p->lock);
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	fffff097          	auipc	ra,0xfffff
    80001f10:	eae080e7          	jalr	-338(ra) # 80000dba <release>
    return 0;
    80001f14:	84ca                	mv	s1,s2
    80001f16:	bff1                	j	80001ef2 <allocproc+0xc4>
    freeproc(p);
    80001f18:	8526                	mv	a0,s1
    80001f1a:	00000097          	auipc	ra,0x0
    80001f1e:	ea0080e7          	jalr	-352(ra) # 80001dba <freeproc>
    release(&p->lock);
    80001f22:	8526                	mv	a0,s1
    80001f24:	fffff097          	auipc	ra,0xfffff
    80001f28:	e96080e7          	jalr	-362(ra) # 80000dba <release>
    return 0;
    80001f2c:	84ca                	mv	s1,s2
    80001f2e:	b7d1                	j	80001ef2 <allocproc+0xc4>

0000000080001f30 <userinit>:
{
    80001f30:	1101                	addi	sp,sp,-32
    80001f32:	ec06                	sd	ra,24(sp)
    80001f34:	e822                	sd	s0,16(sp)
    80001f36:	e426                	sd	s1,8(sp)
    80001f38:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f3a:	00000097          	auipc	ra,0x0
    80001f3e:	ef4080e7          	jalr	-268(ra) # 80001e2e <allocproc>
    80001f42:	84aa                	mv	s1,a0
  initproc = p;
    80001f44:	00007797          	auipc	a5,0x7
    80001f48:	a6a7ba23          	sd	a0,-1420(a5) # 800089b8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f4c:	03400613          	li	a2,52
    80001f50:	00007597          	auipc	a1,0x7
    80001f54:	a0058593          	addi	a1,a1,-1536 # 80008950 <initcode>
    80001f58:	6928                	ld	a0,80(a0)
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	534080e7          	jalr	1332(ra) # 8000148e <uvmfirst>
  p->sz = PGSIZE;
    80001f62:	6785                	lui	a5,0x1
    80001f64:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001f66:	6cb8                	ld	a4,88(s1)
    80001f68:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001f6c:	6cb8                	ld	a4,88(s1)
    80001f6e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f70:	4641                	li	a2,16
    80001f72:	00006597          	auipc	a1,0x6
    80001f76:	36658593          	addi	a1,a1,870 # 800082d8 <digits+0x298>
    80001f7a:	15848513          	addi	a0,s1,344
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	fd6080e7          	jalr	-42(ra) # 80000f54 <safestrcpy>
  p->cwd = namei("/");
    80001f86:	00006517          	auipc	a0,0x6
    80001f8a:	36250513          	addi	a0,a0,866 # 800082e8 <digits+0x2a8>
    80001f8e:	00002097          	auipc	ra,0x2
    80001f92:	6da080e7          	jalr	1754(ra) # 80004668 <namei>
    80001f96:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f9a:	478d                	li	a5,3
    80001f9c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001f9e:	8526                	mv	a0,s1
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	e1a080e7          	jalr	-486(ra) # 80000dba <release>
}
    80001fa8:	60e2                	ld	ra,24(sp)
    80001faa:	6442                	ld	s0,16(sp)
    80001fac:	64a2                	ld	s1,8(sp)
    80001fae:	6105                	addi	sp,sp,32
    80001fb0:	8082                	ret

0000000080001fb2 <growproc>:
{
    80001fb2:	1101                	addi	sp,sp,-32
    80001fb4:	ec06                	sd	ra,24(sp)
    80001fb6:	e822                	sd	s0,16(sp)
    80001fb8:	e426                	sd	s1,8(sp)
    80001fba:	e04a                	sd	s2,0(sp)
    80001fbc:	1000                	addi	s0,sp,32
    80001fbe:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001fc0:	00000097          	auipc	ra,0x0
    80001fc4:	c48080e7          	jalr	-952(ra) # 80001c08 <myproc>
    80001fc8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001fca:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001fcc:	01204c63          	bgtz	s2,80001fe4 <growproc+0x32>
  else if (n < 0)
    80001fd0:	02094663          	bltz	s2,80001ffc <growproc+0x4a>
  p->sz = sz;
    80001fd4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001fd6:	4501                	li	a0,0
}
    80001fd8:	60e2                	ld	ra,24(sp)
    80001fda:	6442                	ld	s0,16(sp)
    80001fdc:	64a2                	ld	s1,8(sp)
    80001fde:	6902                	ld	s2,0(sp)
    80001fe0:	6105                	addi	sp,sp,32
    80001fe2:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001fe4:	4691                	li	a3,4
    80001fe6:	00b90633          	add	a2,s2,a1
    80001fea:	6928                	ld	a0,80(a0)
    80001fec:	fffff097          	auipc	ra,0xfffff
    80001ff0:	55c080e7          	jalr	1372(ra) # 80001548 <uvmalloc>
    80001ff4:	85aa                	mv	a1,a0
    80001ff6:	fd79                	bnez	a0,80001fd4 <growproc+0x22>
      return -1;
    80001ff8:	557d                	li	a0,-1
    80001ffa:	bff9                	j	80001fd8 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ffc:	00b90633          	add	a2,s2,a1
    80002000:	6928                	ld	a0,80(a0)
    80002002:	fffff097          	auipc	ra,0xfffff
    80002006:	4fe080e7          	jalr	1278(ra) # 80001500 <uvmdealloc>
    8000200a:	85aa                	mv	a1,a0
    8000200c:	b7e1                	j	80001fd4 <growproc+0x22>

000000008000200e <fork>:
{
    8000200e:	7179                	addi	sp,sp,-48
    80002010:	f406                	sd	ra,40(sp)
    80002012:	f022                	sd	s0,32(sp)
    80002014:	ec26                	sd	s1,24(sp)
    80002016:	e84a                	sd	s2,16(sp)
    80002018:	e44e                	sd	s3,8(sp)
    8000201a:	e052                	sd	s4,0(sp)
    8000201c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000201e:	00000097          	auipc	ra,0x0
    80002022:	bea080e7          	jalr	-1046(ra) # 80001c08 <myproc>
    80002026:	892a                	mv	s2,a0
  if ((np = allocproc()) == 0)
    80002028:	00000097          	auipc	ra,0x0
    8000202c:	e06080e7          	jalr	-506(ra) # 80001e2e <allocproc>
    80002030:	10050b63          	beqz	a0,80002146 <fork+0x138>
    80002034:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002036:	04893603          	ld	a2,72(s2)
    8000203a:	692c                	ld	a1,80(a0)
    8000203c:	05093503          	ld	a0,80(s2)
    80002040:	fffff097          	auipc	ra,0xfffff
    80002044:	65c080e7          	jalr	1628(ra) # 8000169c <uvmcopy>
    80002048:	04054663          	bltz	a0,80002094 <fork+0x86>
  np->sz = p->sz;
    8000204c:	04893783          	ld	a5,72(s2)
    80002050:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80002054:	05893683          	ld	a3,88(s2)
    80002058:	87b6                	mv	a5,a3
    8000205a:	0589b703          	ld	a4,88(s3)
    8000205e:	12068693          	addi	a3,a3,288
    80002062:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002066:	6788                	ld	a0,8(a5)
    80002068:	6b8c                	ld	a1,16(a5)
    8000206a:	6f90                	ld	a2,24(a5)
    8000206c:	01073023          	sd	a6,0(a4)
    80002070:	e708                	sd	a0,8(a4)
    80002072:	eb0c                	sd	a1,16(a4)
    80002074:	ef10                	sd	a2,24(a4)
    80002076:	02078793          	addi	a5,a5,32
    8000207a:	02070713          	addi	a4,a4,32
    8000207e:	fed792e3          	bne	a5,a3,80002062 <fork+0x54>
  np->trapframe->a0 = 0;
    80002082:	0589b783          	ld	a5,88(s3)
    80002086:	0607b823          	sd	zero,112(a5)
    8000208a:	0d000493          	li	s1,208
  for (i = 0; i < NOFILE; i++)
    8000208e:	15000a13          	li	s4,336
    80002092:	a03d                	j	800020c0 <fork+0xb2>
    freeproc(np);
    80002094:	854e                	mv	a0,s3
    80002096:	00000097          	auipc	ra,0x0
    8000209a:	d24080e7          	jalr	-732(ra) # 80001dba <freeproc>
    release(&np->lock);
    8000209e:	854e                	mv	a0,s3
    800020a0:	fffff097          	auipc	ra,0xfffff
    800020a4:	d1a080e7          	jalr	-742(ra) # 80000dba <release>
    return -1;
    800020a8:	5a7d                	li	s4,-1
    800020aa:	a069                	j	80002134 <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    800020ac:	00003097          	auipc	ra,0x3
    800020b0:	c52080e7          	jalr	-942(ra) # 80004cfe <filedup>
    800020b4:	009987b3          	add	a5,s3,s1
    800020b8:	e388                	sd	a0,0(a5)
  for (i = 0; i < NOFILE; i++)
    800020ba:	04a1                	addi	s1,s1,8
    800020bc:	01448763          	beq	s1,s4,800020ca <fork+0xbc>
    if (p->ofile[i])
    800020c0:	009907b3          	add	a5,s2,s1
    800020c4:	6388                	ld	a0,0(a5)
    800020c6:	f17d                	bnez	a0,800020ac <fork+0x9e>
    800020c8:	bfcd                	j	800020ba <fork+0xac>
  np->cwd = idup(p->cwd);
    800020ca:	15093503          	ld	a0,336(s2)
    800020ce:	00002097          	auipc	ra,0x2
    800020d2:	db6080e7          	jalr	-586(ra) # 80003e84 <idup>
    800020d6:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020da:	4641                	li	a2,16
    800020dc:	15890593          	addi	a1,s2,344
    800020e0:	15898513          	addi	a0,s3,344
    800020e4:	fffff097          	auipc	ra,0xfffff
    800020e8:	e70080e7          	jalr	-400(ra) # 80000f54 <safestrcpy>
  pid = np->pid;
    800020ec:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    800020f0:	854e                	mv	a0,s3
    800020f2:	fffff097          	auipc	ra,0xfffff
    800020f6:	cc8080e7          	jalr	-824(ra) # 80000dba <release>
  acquire(&wait_lock);
    800020fa:	0022f497          	auipc	s1,0x22f
    800020fe:	b6648493          	addi	s1,s1,-1178 # 80230c60 <wait_lock>
    80002102:	8526                	mv	a0,s1
    80002104:	fffff097          	auipc	ra,0xfffff
    80002108:	c02080e7          	jalr	-1022(ra) # 80000d06 <acquire>
  np->parent = p;
    8000210c:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80002110:	8526                	mv	a0,s1
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	ca8080e7          	jalr	-856(ra) # 80000dba <release>
  acquire(&np->lock);
    8000211a:	854e                	mv	a0,s3
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	bea080e7          	jalr	-1046(ra) # 80000d06 <acquire>
  np->state = RUNNABLE;
    80002124:	478d                	li	a5,3
    80002126:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000212a:	854e                	mv	a0,s3
    8000212c:	fffff097          	auipc	ra,0xfffff
    80002130:	c8e080e7          	jalr	-882(ra) # 80000dba <release>
}
    80002134:	8552                	mv	a0,s4
    80002136:	70a2                	ld	ra,40(sp)
    80002138:	7402                	ld	s0,32(sp)
    8000213a:	64e2                	ld	s1,24(sp)
    8000213c:	6942                	ld	s2,16(sp)
    8000213e:	69a2                	ld	s3,8(sp)
    80002140:	6a02                	ld	s4,0(sp)
    80002142:	6145                	addi	sp,sp,48
    80002144:	8082                	ret
    return -1;
    80002146:	5a7d                	li	s4,-1
    80002148:	b7f5                	j	80002134 <fork+0x126>

000000008000214a <max>:
{
    8000214a:	1141                	addi	sp,sp,-16
    8000214c:	e422                	sd	s0,8(sp)
    8000214e:	0800                	addi	s0,sp,16
  if (a > b)
    80002150:	87aa                	mv	a5,a0
    80002152:	00b55363          	bge	a0,a1,80002158 <max+0xe>
    80002156:	87ae                	mv	a5,a1
}
    80002158:	0007851b          	sext.w	a0,a5
    8000215c:	6422                	ld	s0,8(sp)
    8000215e:	0141                	addi	sp,sp,16
    80002160:	8082                	ret

0000000080002162 <min>:
{
    80002162:	1141                	addi	sp,sp,-16
    80002164:	e422                	sd	s0,8(sp)
    80002166:	0800                	addi	s0,sp,16
  if (a < b)
    80002168:	87aa                	mv	a5,a0
    8000216a:	00a5d363          	bge	a1,a0,80002170 <min+0xe>
    8000216e:	87ae                	mv	a5,a1
}
    80002170:	0007851b          	sext.w	a0,a5
    80002174:	6422                	ld	s0,8(sp)
    80002176:	0141                	addi	sp,sp,16
    80002178:	8082                	ret

000000008000217a <dp_priority>:
{
    8000217a:	1141                	addi	sp,sp,-16
    8000217c:	e422                	sd	s0,8(sp)
    8000217e:	0800                	addi	s0,sp,16
  int rtime = p->pbs_rtime;
    80002180:	18052703          	lw	a4,384(a0)
  int wtime = p->pbs_wtime;
    80002184:	18452683          	lw	a3,388(a0)
  int stime = p->pbs_stime;
    80002188:	18852603          	lw	a2,392(a0)
  int temp = (3 * rtime - wtime - stime) * 50;
    8000218c:	0017179b          	slliw	a5,a4,0x1
    80002190:	9fb9                	addw	a5,a5,a4
    80002192:	9f95                	subw	a5,a5,a3
    80002194:	9f91                	subw	a5,a5,a2
    80002196:	03200593          	li	a1,50
    8000219a:	02b787bb          	mulw	a5,a5,a1
  int temp1 = 1 + rtime + stime + wtime;
    8000219e:	2705                	addiw	a4,a4,1
    800021a0:	9f31                	addw	a4,a4,a2
    800021a2:	9f35                	addw	a4,a4,a3
  int temp2 = (int)temp / temp1;
    800021a4:	02e7c7bb          	divw	a5,a5,a4
    800021a8:	0007871b          	sext.w	a4,a5
    800021ac:	fff74713          	not	a4,a4
    800021b0:	977d                	srai	a4,a4,0x3f
    800021b2:	8ff9                	and	a5,a5,a4
    800021b4:	0007869b          	sext.w	a3,a5
  int dp = min(100, sp + rbi);
    800021b8:	17452703          	lw	a4,372(a0)
    800021bc:	9fb9                	addw	a5,a5,a4
    800021be:	0007861b          	sext.w	a2,a5
    800021c2:	06400713          	li	a4,100
    800021c6:	00c75463          	bge	a4,a2,800021ce <dp_priority+0x54>
    800021ca:	06400793          	li	a5,100
  p->pbs_rbi = rbi;
    800021ce:	16d52e23          	sw	a3,380(a0)
  p->pbs_dynamic_priority = dp;
    800021d2:	16f52c23          	sw	a5,376(a0)
}
    800021d6:	0007851b          	sext.w	a0,a5
    800021da:	6422                	ld	s0,8(sp)
    800021dc:	0141                	addi	sp,sp,16
    800021de:	8082                	ret

00000000800021e0 <scheduler>:
{
    800021e0:	7159                	addi	sp,sp,-112
    800021e2:	f486                	sd	ra,104(sp)
    800021e4:	f0a2                	sd	s0,96(sp)
    800021e6:	eca6                	sd	s1,88(sp)
    800021e8:	e8ca                	sd	s2,80(sp)
    800021ea:	e4ce                	sd	s3,72(sp)
    800021ec:	e0d2                	sd	s4,64(sp)
    800021ee:	fc56                	sd	s5,56(sp)
    800021f0:	f85a                	sd	s6,48(sp)
    800021f2:	f45e                	sd	s7,40(sp)
    800021f4:	f062                	sd	s8,32(sp)
    800021f6:	ec66                	sd	s9,24(sp)
    800021f8:	e86a                	sd	s10,16(sp)
    800021fa:	e46e                	sd	s11,8(sp)
    800021fc:	1880                	addi	s0,sp,112
    800021fe:	8792                	mv	a5,tp
  int id = r_tp();
    80002200:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002202:	00779d13          	slli	s10,a5,0x7
    80002206:	0022f717          	auipc	a4,0x22f
    8000220a:	a4270713          	addi	a4,a4,-1470 # 80230c48 <pid_lock>
    8000220e:	976a                	add	a4,a4,s10
    80002210:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &max_priority->context);
    80002214:	0022f717          	auipc	a4,0x22f
    80002218:	a6c70713          	addi	a4,a4,-1428 # 80230c80 <cpus+0x8>
    8000221c:	9d3a                	add	s10,s10,a4
      if (p->state != RUNNABLE)
    8000221e:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++)
    80002220:	00235a17          	auipc	s4,0x235
    80002224:	258a0a13          	addi	s4,s4,600 # 80237478 <tickslock>
    int priority = 101; // maximum priority is of lesser positive number. So 0 at more priority than 100
    80002228:	06500c93          	li	s9,101
    struct proc *max_priority = 0;
    8000222c:	4c01                	li	s8,0
      c->proc = max_priority;
    8000222e:	079e                	slli	a5,a5,0x7
    80002230:	0022fb97          	auipc	s7,0x22f
    80002234:	a18b8b93          	addi	s7,s7,-1512 # 80230c48 <pid_lock>
    80002238:	9bbe                	add	s7,s7,a5
    8000223a:	a055                	j	800022de <scheduler+0xfe>
        int dp = dp_priority(p);
    8000223c:	8526                	mv	a0,s1
    8000223e:	00000097          	auipc	ra,0x0
    80002242:	f3c080e7          	jalr	-196(ra) # 8000217a <dp_priority>
    80002246:	8daa                	mv	s11,a0
        if (max_priority == 0)
    80002248:	0e0a8463          	beqz	s5,80002330 <scheduler+0x150>
        if (dp < priority)
    8000224c:	0b654663          	blt	a0,s6,800022f8 <scheduler+0x118>
        else if (dp == priority)
    80002250:	01651a63          	bne	a0,s6,80002264 <scheduler+0x84>
          if (p->pbs_num_sched < max_priority->pbs_num_sched)
    80002254:	18c4a703          	lw	a4,396(s1)
    80002258:	18caa783          	lw	a5,396(s5)
    8000225c:	0af74663          	blt	a4,a5,80002308 <scheduler+0x128>
          else if (p->pbs_num_sched == max_priority->pbs_num_sched)
    80002260:	0af70b63          	beq	a4,a5,80002316 <scheduler+0x136>
        release(&p->lock);
    80002264:	854a                	mv	a0,s2
    80002266:	fffff097          	auipc	ra,0xfffff
    8000226a:	b54080e7          	jalr	-1196(ra) # 80000dba <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000226e:	19048793          	addi	a5,s1,400
    80002272:	0347f863          	bgeu	a5,s4,800022a2 <scheduler+0xc2>
    80002276:	19048493          	addi	s1,s1,400
    8000227a:	8926                	mv	s2,s1
      acquire(&p->lock);
    8000227c:	8526                	mv	a0,s1
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	a88080e7          	jalr	-1400(ra) # 80000d06 <acquire>
      if (p->state != RUNNABLE)
    80002286:	4c9c                	lw	a5,24(s1)
    80002288:	fb378ae3          	beq	a5,s3,8000223c <scheduler+0x5c>
        release(&p->lock);
    8000228c:	8526                	mv	a0,s1
    8000228e:	fffff097          	auipc	ra,0xfffff
    80002292:	b2c080e7          	jalr	-1236(ra) # 80000dba <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002296:	19048793          	addi	a5,s1,400
    8000229a:	fd47eee3          	bltu	a5,s4,80002276 <scheduler+0x96>
    if (max_priority != 0)
    8000229e:	040a8063          	beqz	s5,800022de <scheduler+0xfe>
      max_priority->state = RUNNING;
    800022a2:	4791                	li	a5,4
    800022a4:	00faac23          	sw	a5,24(s5)
      c->proc = max_priority;
    800022a8:	035bb823          	sd	s5,48(s7)
      max_priority->pbs_num_sched++;
    800022ac:	18caa783          	lw	a5,396(s5)
    800022b0:	2785                	addiw	a5,a5,1
    800022b2:	18faa623          	sw	a5,396(s5)
      max_priority->pbs_rtime = 0;
    800022b6:	180aa023          	sw	zero,384(s5)
      max_priority->pbs_wtime = 0;
    800022ba:	180aa223          	sw	zero,388(s5)
      max_priority->pbs_stime = 0;
    800022be:	180aa423          	sw	zero,392(s5)
      swtch(&c->context, &max_priority->context);
    800022c2:	060a8593          	addi	a1,s5,96
    800022c6:	856a                	mv	a0,s10
    800022c8:	00001097          	auipc	ra,0x1
    800022cc:	956080e7          	jalr	-1706(ra) # 80002c1e <swtch>
      c->proc = 0;
    800022d0:	020bb823          	sd	zero,48(s7)
      release(&max_priority->lock);
    800022d4:	8556                	mv	a0,s5
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	ae4080e7          	jalr	-1308(ra) # 80000dba <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022de:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022e2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022e6:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++)
    800022ea:	0022f497          	auipc	s1,0x22f
    800022ee:	d8e48493          	addi	s1,s1,-626 # 80231078 <proc>
    int priority = 101; // maximum priority is of lesser positive number. So 0 at more priority than 100
    800022f2:	8b66                	mv	s6,s9
    struct proc *max_priority = 0;
    800022f4:	8ae2                	mv	s5,s8
    800022f6:	b751                	j	8000227a <scheduler+0x9a>
          release(&max_priority->lock);
    800022f8:	8556                	mv	a0,s5
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	ac0080e7          	jalr	-1344(ra) # 80000dba <release>
          priority = dp;
    80002302:	8b6e                	mv	s6,s11
          continue;
    80002304:	8aa6                	mv	s5,s1
    80002306:	b7a5                	j	8000226e <scheduler+0x8e>
            release(&max_priority->lock);
    80002308:	8556                	mv	a0,s5
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	ab0080e7          	jalr	-1360(ra) # 80000dba <release>
            continue;
    80002312:	8aa6                	mv	s5,s1
    80002314:	bfa9                	j	8000226e <scheduler+0x8e>
            if (p->ctime < max_priority->ctime)
    80002316:	16c4a703          	lw	a4,364(s1)
    8000231a:	16caa783          	lw	a5,364(s5)
    8000231e:	f4f773e3          	bgeu	a4,a5,80002264 <scheduler+0x84>
              release(&max_priority->lock);
    80002322:	8556                	mv	a0,s5
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	a96080e7          	jalr	-1386(ra) # 80000dba <release>
              continue;
    8000232c:	8aa6                	mv	s5,s1
    8000232e:	b781                	j	8000226e <scheduler+0x8e>
          priority = dp;
    80002330:	8b2a                	mv	s6,a0
    80002332:	8aa6                	mv	s5,s1
    80002334:	bf2d                	j	8000226e <scheduler+0x8e>

0000000080002336 <sched>:
{
    80002336:	7179                	addi	sp,sp,-48
    80002338:	f406                	sd	ra,40(sp)
    8000233a:	f022                	sd	s0,32(sp)
    8000233c:	ec26                	sd	s1,24(sp)
    8000233e:	e84a                	sd	s2,16(sp)
    80002340:	e44e                	sd	s3,8(sp)
    80002342:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002344:	00000097          	auipc	ra,0x0
    80002348:	8c4080e7          	jalr	-1852(ra) # 80001c08 <myproc>
    8000234c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000234e:	fffff097          	auipc	ra,0xfffff
    80002352:	93e080e7          	jalr	-1730(ra) # 80000c8c <holding>
    80002356:	c93d                	beqz	a0,800023cc <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002358:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000235a:	2781                	sext.w	a5,a5
    8000235c:	079e                	slli	a5,a5,0x7
    8000235e:	0022f717          	auipc	a4,0x22f
    80002362:	8ea70713          	addi	a4,a4,-1814 # 80230c48 <pid_lock>
    80002366:	97ba                	add	a5,a5,a4
    80002368:	0a87a703          	lw	a4,168(a5)
    8000236c:	4785                	li	a5,1
    8000236e:	06f71763          	bne	a4,a5,800023dc <sched+0xa6>
  if (p->state == RUNNING)
    80002372:	4c98                	lw	a4,24(s1)
    80002374:	4791                	li	a5,4
    80002376:	06f70b63          	beq	a4,a5,800023ec <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000237a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000237e:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002380:	efb5                	bnez	a5,800023fc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002382:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002384:	0022f917          	auipc	s2,0x22f
    80002388:	8c490913          	addi	s2,s2,-1852 # 80230c48 <pid_lock>
    8000238c:	2781                	sext.w	a5,a5
    8000238e:	079e                	slli	a5,a5,0x7
    80002390:	97ca                	add	a5,a5,s2
    80002392:	0ac7a983          	lw	s3,172(a5)
    80002396:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002398:	2781                	sext.w	a5,a5
    8000239a:	079e                	slli	a5,a5,0x7
    8000239c:	0022f597          	auipc	a1,0x22f
    800023a0:	8e458593          	addi	a1,a1,-1820 # 80230c80 <cpus+0x8>
    800023a4:	95be                	add	a1,a1,a5
    800023a6:	06048513          	addi	a0,s1,96
    800023aa:	00001097          	auipc	ra,0x1
    800023ae:	874080e7          	jalr	-1932(ra) # 80002c1e <swtch>
    800023b2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023b4:	2781                	sext.w	a5,a5
    800023b6:	079e                	slli	a5,a5,0x7
    800023b8:	97ca                	add	a5,a5,s2
    800023ba:	0b37a623          	sw	s3,172(a5)
}
    800023be:	70a2                	ld	ra,40(sp)
    800023c0:	7402                	ld	s0,32(sp)
    800023c2:	64e2                	ld	s1,24(sp)
    800023c4:	6942                	ld	s2,16(sp)
    800023c6:	69a2                	ld	s3,8(sp)
    800023c8:	6145                	addi	sp,sp,48
    800023ca:	8082                	ret
    panic("sched p->lock");
    800023cc:	00006517          	auipc	a0,0x6
    800023d0:	f2450513          	addi	a0,a0,-220 # 800082f0 <digits+0x2b0>
    800023d4:	ffffe097          	auipc	ra,0xffffe
    800023d8:	170080e7          	jalr	368(ra) # 80000544 <panic>
    panic("sched locks");
    800023dc:	00006517          	auipc	a0,0x6
    800023e0:	f2450513          	addi	a0,a0,-220 # 80008300 <digits+0x2c0>
    800023e4:	ffffe097          	auipc	ra,0xffffe
    800023e8:	160080e7          	jalr	352(ra) # 80000544 <panic>
    panic("sched running");
    800023ec:	00006517          	auipc	a0,0x6
    800023f0:	f2450513          	addi	a0,a0,-220 # 80008310 <digits+0x2d0>
    800023f4:	ffffe097          	auipc	ra,0xffffe
    800023f8:	150080e7          	jalr	336(ra) # 80000544 <panic>
    panic("sched interruptible");
    800023fc:	00006517          	auipc	a0,0x6
    80002400:	f2450513          	addi	a0,a0,-220 # 80008320 <digits+0x2e0>
    80002404:	ffffe097          	auipc	ra,0xffffe
    80002408:	140080e7          	jalr	320(ra) # 80000544 <panic>

000000008000240c <yield>:
{
    8000240c:	1101                	addi	sp,sp,-32
    8000240e:	ec06                	sd	ra,24(sp)
    80002410:	e822                	sd	s0,16(sp)
    80002412:	e426                	sd	s1,8(sp)
    80002414:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	7f2080e7          	jalr	2034(ra) # 80001c08 <myproc>
    8000241e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002420:	fffff097          	auipc	ra,0xfffff
    80002424:	8e6080e7          	jalr	-1818(ra) # 80000d06 <acquire>
  p->state = RUNNABLE;
    80002428:	478d                	li	a5,3
    8000242a:	cc9c                	sw	a5,24(s1)
  sched();
    8000242c:	00000097          	auipc	ra,0x0
    80002430:	f0a080e7          	jalr	-246(ra) # 80002336 <sched>
  release(&p->lock);
    80002434:	8526                	mv	a0,s1
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	984080e7          	jalr	-1660(ra) # 80000dba <release>
}
    8000243e:	60e2                	ld	ra,24(sp)
    80002440:	6442                	ld	s0,16(sp)
    80002442:	64a2                	ld	s1,8(sp)
    80002444:	6105                	addi	sp,sp,32
    80002446:	8082                	ret

0000000080002448 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002448:	7179                	addi	sp,sp,-48
    8000244a:	f406                	sd	ra,40(sp)
    8000244c:	f022                	sd	s0,32(sp)
    8000244e:	ec26                	sd	s1,24(sp)
    80002450:	e84a                	sd	s2,16(sp)
    80002452:	e44e                	sd	s3,8(sp)
    80002454:	1800                	addi	s0,sp,48
    80002456:	89aa                	mv	s3,a0
    80002458:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	7ae080e7          	jalr	1966(ra) # 80001c08 <myproc>
    80002462:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	8a2080e7          	jalr	-1886(ra) # 80000d06 <acquire>
  release(lk);
    8000246c:	854a                	mv	a0,s2
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	94c080e7          	jalr	-1716(ra) # 80000dba <release>

  // Go to sleep.
  p->chan = chan;
    80002476:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000247a:	4789                	li	a5,2
    8000247c:	cc9c                	sw	a5,24(s1)

  sched();
    8000247e:	00000097          	auipc	ra,0x0
    80002482:	eb8080e7          	jalr	-328(ra) # 80002336 <sched>

  // Tidy up.
  p->chan = 0;
    80002486:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000248a:	8526                	mv	a0,s1
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	92e080e7          	jalr	-1746(ra) # 80000dba <release>
  acquire(lk);
    80002494:	854a                	mv	a0,s2
    80002496:	fffff097          	auipc	ra,0xfffff
    8000249a:	870080e7          	jalr	-1936(ra) # 80000d06 <acquire>
}
    8000249e:	70a2                	ld	ra,40(sp)
    800024a0:	7402                	ld	s0,32(sp)
    800024a2:	64e2                	ld	s1,24(sp)
    800024a4:	6942                	ld	s2,16(sp)
    800024a6:	69a2                	ld	s3,8(sp)
    800024a8:	6145                	addi	sp,sp,48
    800024aa:	8082                	ret

00000000800024ac <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800024ac:	7139                	addi	sp,sp,-64
    800024ae:	fc06                	sd	ra,56(sp)
    800024b0:	f822                	sd	s0,48(sp)
    800024b2:	f426                	sd	s1,40(sp)
    800024b4:	f04a                	sd	s2,32(sp)
    800024b6:	ec4e                	sd	s3,24(sp)
    800024b8:	e852                	sd	s4,16(sp)
    800024ba:	e456                	sd	s5,8(sp)
    800024bc:	0080                	addi	s0,sp,64
    800024be:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800024c0:	0022f497          	auipc	s1,0x22f
    800024c4:	bb848493          	addi	s1,s1,-1096 # 80231078 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800024c8:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800024ca:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800024cc:	00235917          	auipc	s2,0x235
    800024d0:	fac90913          	addi	s2,s2,-84 # 80237478 <tickslock>
    800024d4:	a821                	j	800024ec <wakeup+0x40>
        p->state = RUNNABLE;
    800024d6:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800024da:	8526                	mv	a0,s1
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	8de080e7          	jalr	-1826(ra) # 80000dba <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800024e4:	19048493          	addi	s1,s1,400
    800024e8:	03248463          	beq	s1,s2,80002510 <wakeup+0x64>
    if (p != myproc())
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	71c080e7          	jalr	1820(ra) # 80001c08 <myproc>
    800024f4:	fea488e3          	beq	s1,a0,800024e4 <wakeup+0x38>
      acquire(&p->lock);
    800024f8:	8526                	mv	a0,s1
    800024fa:	fffff097          	auipc	ra,0xfffff
    800024fe:	80c080e7          	jalr	-2036(ra) # 80000d06 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002502:	4c9c                	lw	a5,24(s1)
    80002504:	fd379be3          	bne	a5,s3,800024da <wakeup+0x2e>
    80002508:	709c                	ld	a5,32(s1)
    8000250a:	fd4798e3          	bne	a5,s4,800024da <wakeup+0x2e>
    8000250e:	b7e1                	j	800024d6 <wakeup+0x2a>
    }
  }
}
    80002510:	70e2                	ld	ra,56(sp)
    80002512:	7442                	ld	s0,48(sp)
    80002514:	74a2                	ld	s1,40(sp)
    80002516:	7902                	ld	s2,32(sp)
    80002518:	69e2                	ld	s3,24(sp)
    8000251a:	6a42                	ld	s4,16(sp)
    8000251c:	6aa2                	ld	s5,8(sp)
    8000251e:	6121                	addi	sp,sp,64
    80002520:	8082                	ret

0000000080002522 <reparent>:
{
    80002522:	7179                	addi	sp,sp,-48
    80002524:	f406                	sd	ra,40(sp)
    80002526:	f022                	sd	s0,32(sp)
    80002528:	ec26                	sd	s1,24(sp)
    8000252a:	e84a                	sd	s2,16(sp)
    8000252c:	e44e                	sd	s3,8(sp)
    8000252e:	e052                	sd	s4,0(sp)
    80002530:	1800                	addi	s0,sp,48
    80002532:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002534:	0022f497          	auipc	s1,0x22f
    80002538:	b4448493          	addi	s1,s1,-1212 # 80231078 <proc>
      pp->parent = initproc;
    8000253c:	00006a17          	auipc	s4,0x6
    80002540:	47ca0a13          	addi	s4,s4,1148 # 800089b8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002544:	00235997          	auipc	s3,0x235
    80002548:	f3498993          	addi	s3,s3,-204 # 80237478 <tickslock>
    8000254c:	a029                	j	80002556 <reparent+0x34>
    8000254e:	19048493          	addi	s1,s1,400
    80002552:	01348d63          	beq	s1,s3,8000256c <reparent+0x4a>
    if (pp->parent == p)
    80002556:	7c9c                	ld	a5,56(s1)
    80002558:	ff279be3          	bne	a5,s2,8000254e <reparent+0x2c>
      pp->parent = initproc;
    8000255c:	000a3503          	ld	a0,0(s4)
    80002560:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002562:	00000097          	auipc	ra,0x0
    80002566:	f4a080e7          	jalr	-182(ra) # 800024ac <wakeup>
    8000256a:	b7d5                	j	8000254e <reparent+0x2c>
}
    8000256c:	70a2                	ld	ra,40(sp)
    8000256e:	7402                	ld	s0,32(sp)
    80002570:	64e2                	ld	s1,24(sp)
    80002572:	6942                	ld	s2,16(sp)
    80002574:	69a2                	ld	s3,8(sp)
    80002576:	6a02                	ld	s4,0(sp)
    80002578:	6145                	addi	sp,sp,48
    8000257a:	8082                	ret

000000008000257c <exit>:
{
    8000257c:	7179                	addi	sp,sp,-48
    8000257e:	f406                	sd	ra,40(sp)
    80002580:	f022                	sd	s0,32(sp)
    80002582:	ec26                	sd	s1,24(sp)
    80002584:	e84a                	sd	s2,16(sp)
    80002586:	e44e                	sd	s3,8(sp)
    80002588:	e052                	sd	s4,0(sp)
    8000258a:	1800                	addi	s0,sp,48
    8000258c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000258e:	fffff097          	auipc	ra,0xfffff
    80002592:	67a080e7          	jalr	1658(ra) # 80001c08 <myproc>
    80002596:	89aa                	mv	s3,a0
  if (p == initproc)
    80002598:	00006797          	auipc	a5,0x6
    8000259c:	4207b783          	ld	a5,1056(a5) # 800089b8 <initproc>
    800025a0:	0d050493          	addi	s1,a0,208
    800025a4:	15050913          	addi	s2,a0,336
    800025a8:	02a79363          	bne	a5,a0,800025ce <exit+0x52>
    panic("init exiting");
    800025ac:	00006517          	auipc	a0,0x6
    800025b0:	d8c50513          	addi	a0,a0,-628 # 80008338 <digits+0x2f8>
    800025b4:	ffffe097          	auipc	ra,0xffffe
    800025b8:	f90080e7          	jalr	-112(ra) # 80000544 <panic>
      fileclose(f);
    800025bc:	00002097          	auipc	ra,0x2
    800025c0:	794080e7          	jalr	1940(ra) # 80004d50 <fileclose>
      p->ofile[fd] = 0;
    800025c4:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800025c8:	04a1                	addi	s1,s1,8
    800025ca:	01248563          	beq	s1,s2,800025d4 <exit+0x58>
    if (p->ofile[fd])
    800025ce:	6088                	ld	a0,0(s1)
    800025d0:	f575                	bnez	a0,800025bc <exit+0x40>
    800025d2:	bfdd                	j	800025c8 <exit+0x4c>
  begin_op();
    800025d4:	00002097          	auipc	ra,0x2
    800025d8:	2b0080e7          	jalr	688(ra) # 80004884 <begin_op>
  iput(p->cwd);
    800025dc:	1509b503          	ld	a0,336(s3)
    800025e0:	00002097          	auipc	ra,0x2
    800025e4:	a9c080e7          	jalr	-1380(ra) # 8000407c <iput>
  end_op();
    800025e8:	00002097          	auipc	ra,0x2
    800025ec:	31c080e7          	jalr	796(ra) # 80004904 <end_op>
  p->cwd = 0;
    800025f0:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800025f4:	0022e497          	auipc	s1,0x22e
    800025f8:	66c48493          	addi	s1,s1,1644 # 80230c60 <wait_lock>
    800025fc:	8526                	mv	a0,s1
    800025fe:	ffffe097          	auipc	ra,0xffffe
    80002602:	708080e7          	jalr	1800(ra) # 80000d06 <acquire>
  reparent(p);
    80002606:	854e                	mv	a0,s3
    80002608:	00000097          	auipc	ra,0x0
    8000260c:	f1a080e7          	jalr	-230(ra) # 80002522 <reparent>
  wakeup(p->parent);
    80002610:	0389b503          	ld	a0,56(s3)
    80002614:	00000097          	auipc	ra,0x0
    80002618:	e98080e7          	jalr	-360(ra) # 800024ac <wakeup>
  acquire(&p->lock);
    8000261c:	854e                	mv	a0,s3
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	6e8080e7          	jalr	1768(ra) # 80000d06 <acquire>
  p->xstate = status;
    80002626:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000262a:	4795                	li	a5,5
    8000262c:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002630:	00006797          	auipc	a5,0x6
    80002634:	3907a783          	lw	a5,912(a5) # 800089c0 <ticks>
    80002638:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    8000263c:	8526                	mv	a0,s1
    8000263e:	ffffe097          	auipc	ra,0xffffe
    80002642:	77c080e7          	jalr	1916(ra) # 80000dba <release>
  sched();
    80002646:	00000097          	auipc	ra,0x0
    8000264a:	cf0080e7          	jalr	-784(ra) # 80002336 <sched>
  panic("zombie exit");
    8000264e:	00006517          	auipc	a0,0x6
    80002652:	cfa50513          	addi	a0,a0,-774 # 80008348 <digits+0x308>
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	eee080e7          	jalr	-274(ra) # 80000544 <panic>

000000008000265e <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000265e:	7179                	addi	sp,sp,-48
    80002660:	f406                	sd	ra,40(sp)
    80002662:	f022                	sd	s0,32(sp)
    80002664:	ec26                	sd	s1,24(sp)
    80002666:	e84a                	sd	s2,16(sp)
    80002668:	e44e                	sd	s3,8(sp)
    8000266a:	1800                	addi	s0,sp,48
    8000266c:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000266e:	0022f497          	auipc	s1,0x22f
    80002672:	a0a48493          	addi	s1,s1,-1526 # 80231078 <proc>
    80002676:	00235997          	auipc	s3,0x235
    8000267a:	e0298993          	addi	s3,s3,-510 # 80237478 <tickslock>
  {
    acquire(&p->lock);
    8000267e:	8526                	mv	a0,s1
    80002680:	ffffe097          	auipc	ra,0xffffe
    80002684:	686080e7          	jalr	1670(ra) # 80000d06 <acquire>
    if (p->pid == pid)
    80002688:	589c                	lw	a5,48(s1)
    8000268a:	01278d63          	beq	a5,s2,800026a4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000268e:	8526                	mv	a0,s1
    80002690:	ffffe097          	auipc	ra,0xffffe
    80002694:	72a080e7          	jalr	1834(ra) # 80000dba <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002698:	19048493          	addi	s1,s1,400
    8000269c:	ff3491e3          	bne	s1,s3,8000267e <kill+0x20>
  }
  return -1;
    800026a0:	557d                	li	a0,-1
    800026a2:	a829                	j	800026bc <kill+0x5e>
      p->killed = 1;
    800026a4:	4785                	li	a5,1
    800026a6:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800026a8:	4c98                	lw	a4,24(s1)
    800026aa:	4789                	li	a5,2
    800026ac:	00f70f63          	beq	a4,a5,800026ca <kill+0x6c>
      release(&p->lock);
    800026b0:	8526                	mv	a0,s1
    800026b2:	ffffe097          	auipc	ra,0xffffe
    800026b6:	708080e7          	jalr	1800(ra) # 80000dba <release>
      return 0;
    800026ba:	4501                	li	a0,0
}
    800026bc:	70a2                	ld	ra,40(sp)
    800026be:	7402                	ld	s0,32(sp)
    800026c0:	64e2                	ld	s1,24(sp)
    800026c2:	6942                	ld	s2,16(sp)
    800026c4:	69a2                	ld	s3,8(sp)
    800026c6:	6145                	addi	sp,sp,48
    800026c8:	8082                	ret
        p->state = RUNNABLE;
    800026ca:	478d                	li	a5,3
    800026cc:	cc9c                	sw	a5,24(s1)
    800026ce:	b7cd                	j	800026b0 <kill+0x52>

00000000800026d0 <setkilled>:

void setkilled(struct proc *p)
{
    800026d0:	1101                	addi	sp,sp,-32
    800026d2:	ec06                	sd	ra,24(sp)
    800026d4:	e822                	sd	s0,16(sp)
    800026d6:	e426                	sd	s1,8(sp)
    800026d8:	1000                	addi	s0,sp,32
    800026da:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800026dc:	ffffe097          	auipc	ra,0xffffe
    800026e0:	62a080e7          	jalr	1578(ra) # 80000d06 <acquire>
  p->killed = 1;
    800026e4:	4785                	li	a5,1
    800026e6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800026e8:	8526                	mv	a0,s1
    800026ea:	ffffe097          	auipc	ra,0xffffe
    800026ee:	6d0080e7          	jalr	1744(ra) # 80000dba <release>
}
    800026f2:	60e2                	ld	ra,24(sp)
    800026f4:	6442                	ld	s0,16(sp)
    800026f6:	64a2                	ld	s1,8(sp)
    800026f8:	6105                	addi	sp,sp,32
    800026fa:	8082                	ret

00000000800026fc <killed>:

int killed(struct proc *p)
{
    800026fc:	1101                	addi	sp,sp,-32
    800026fe:	ec06                	sd	ra,24(sp)
    80002700:	e822                	sd	s0,16(sp)
    80002702:	e426                	sd	s1,8(sp)
    80002704:	e04a                	sd	s2,0(sp)
    80002706:	1000                	addi	s0,sp,32
    80002708:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000270a:	ffffe097          	auipc	ra,0xffffe
    8000270e:	5fc080e7          	jalr	1532(ra) # 80000d06 <acquire>
  k = p->killed;
    80002712:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002716:	8526                	mv	a0,s1
    80002718:	ffffe097          	auipc	ra,0xffffe
    8000271c:	6a2080e7          	jalr	1698(ra) # 80000dba <release>
  return k;
}
    80002720:	854a                	mv	a0,s2
    80002722:	60e2                	ld	ra,24(sp)
    80002724:	6442                	ld	s0,16(sp)
    80002726:	64a2                	ld	s1,8(sp)
    80002728:	6902                	ld	s2,0(sp)
    8000272a:	6105                	addi	sp,sp,32
    8000272c:	8082                	ret

000000008000272e <wait>:
{
    8000272e:	715d                	addi	sp,sp,-80
    80002730:	e486                	sd	ra,72(sp)
    80002732:	e0a2                	sd	s0,64(sp)
    80002734:	fc26                	sd	s1,56(sp)
    80002736:	f84a                	sd	s2,48(sp)
    80002738:	f44e                	sd	s3,40(sp)
    8000273a:	f052                	sd	s4,32(sp)
    8000273c:	ec56                	sd	s5,24(sp)
    8000273e:	e85a                	sd	s6,16(sp)
    80002740:	e45e                	sd	s7,8(sp)
    80002742:	e062                	sd	s8,0(sp)
    80002744:	0880                	addi	s0,sp,80
    80002746:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002748:	fffff097          	auipc	ra,0xfffff
    8000274c:	4c0080e7          	jalr	1216(ra) # 80001c08 <myproc>
    80002750:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002752:	0022e517          	auipc	a0,0x22e
    80002756:	50e50513          	addi	a0,a0,1294 # 80230c60 <wait_lock>
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	5ac080e7          	jalr	1452(ra) # 80000d06 <acquire>
    havekids = 0;
    80002762:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002764:	4a15                	li	s4,5
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002766:	00235997          	auipc	s3,0x235
    8000276a:	d1298993          	addi	s3,s3,-750 # 80237478 <tickslock>
        havekids = 1;
    8000276e:	4a85                	li	s5,1
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002770:	0022ec17          	auipc	s8,0x22e
    80002774:	4f0c0c13          	addi	s8,s8,1264 # 80230c60 <wait_lock>
    havekids = 0;
    80002778:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000277a:	0022f497          	auipc	s1,0x22f
    8000277e:	8fe48493          	addi	s1,s1,-1794 # 80231078 <proc>
    80002782:	a0bd                	j	800027f0 <wait+0xc2>
          pid = pp->pid;
    80002784:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002788:	000b0e63          	beqz	s6,800027a4 <wait+0x76>
    8000278c:	4691                	li	a3,4
    8000278e:	02c48613          	addi	a2,s1,44
    80002792:	85da                	mv	a1,s6
    80002794:	05093503          	ld	a0,80(s2)
    80002798:	fffff097          	auipc	ra,0xfffff
    8000279c:	0f6080e7          	jalr	246(ra) # 8000188e <copyout>
    800027a0:	02054563          	bltz	a0,800027ca <wait+0x9c>
          freeproc(pp);
    800027a4:	8526                	mv	a0,s1
    800027a6:	fffff097          	auipc	ra,0xfffff
    800027aa:	614080e7          	jalr	1556(ra) # 80001dba <freeproc>
          release(&pp->lock);
    800027ae:	8526                	mv	a0,s1
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	60a080e7          	jalr	1546(ra) # 80000dba <release>
          release(&wait_lock);
    800027b8:	0022e517          	auipc	a0,0x22e
    800027bc:	4a850513          	addi	a0,a0,1192 # 80230c60 <wait_lock>
    800027c0:	ffffe097          	auipc	ra,0xffffe
    800027c4:	5fa080e7          	jalr	1530(ra) # 80000dba <release>
          return pid;
    800027c8:	a0b5                	j	80002834 <wait+0x106>
            release(&pp->lock);
    800027ca:	8526                	mv	a0,s1
    800027cc:	ffffe097          	auipc	ra,0xffffe
    800027d0:	5ee080e7          	jalr	1518(ra) # 80000dba <release>
            release(&wait_lock);
    800027d4:	0022e517          	auipc	a0,0x22e
    800027d8:	48c50513          	addi	a0,a0,1164 # 80230c60 <wait_lock>
    800027dc:	ffffe097          	auipc	ra,0xffffe
    800027e0:	5de080e7          	jalr	1502(ra) # 80000dba <release>
            return -1;
    800027e4:	59fd                	li	s3,-1
    800027e6:	a0b9                	j	80002834 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800027e8:	19048493          	addi	s1,s1,400
    800027ec:	03348463          	beq	s1,s3,80002814 <wait+0xe6>
      if (pp->parent == p)
    800027f0:	7c9c                	ld	a5,56(s1)
    800027f2:	ff279be3          	bne	a5,s2,800027e8 <wait+0xba>
        acquire(&pp->lock);
    800027f6:	8526                	mv	a0,s1
    800027f8:	ffffe097          	auipc	ra,0xffffe
    800027fc:	50e080e7          	jalr	1294(ra) # 80000d06 <acquire>
        if (pp->state == ZOMBIE)
    80002800:	4c9c                	lw	a5,24(s1)
    80002802:	f94781e3          	beq	a5,s4,80002784 <wait+0x56>
        release(&pp->lock);
    80002806:	8526                	mv	a0,s1
    80002808:	ffffe097          	auipc	ra,0xffffe
    8000280c:	5b2080e7          	jalr	1458(ra) # 80000dba <release>
        havekids = 1;
    80002810:	8756                	mv	a4,s5
    80002812:	bfd9                	j	800027e8 <wait+0xba>
    if (!havekids || killed(p))
    80002814:	c719                	beqz	a4,80002822 <wait+0xf4>
    80002816:	854a                	mv	a0,s2
    80002818:	00000097          	auipc	ra,0x0
    8000281c:	ee4080e7          	jalr	-284(ra) # 800026fc <killed>
    80002820:	c51d                	beqz	a0,8000284e <wait+0x120>
      release(&wait_lock);
    80002822:	0022e517          	auipc	a0,0x22e
    80002826:	43e50513          	addi	a0,a0,1086 # 80230c60 <wait_lock>
    8000282a:	ffffe097          	auipc	ra,0xffffe
    8000282e:	590080e7          	jalr	1424(ra) # 80000dba <release>
      return -1;
    80002832:	59fd                	li	s3,-1
}
    80002834:	854e                	mv	a0,s3
    80002836:	60a6                	ld	ra,72(sp)
    80002838:	6406                	ld	s0,64(sp)
    8000283a:	74e2                	ld	s1,56(sp)
    8000283c:	7942                	ld	s2,48(sp)
    8000283e:	79a2                	ld	s3,40(sp)
    80002840:	7a02                	ld	s4,32(sp)
    80002842:	6ae2                	ld	s5,24(sp)
    80002844:	6b42                	ld	s6,16(sp)
    80002846:	6ba2                	ld	s7,8(sp)
    80002848:	6c02                	ld	s8,0(sp)
    8000284a:	6161                	addi	sp,sp,80
    8000284c:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000284e:	85e2                	mv	a1,s8
    80002850:	854a                	mv	a0,s2
    80002852:	00000097          	auipc	ra,0x0
    80002856:	bf6080e7          	jalr	-1034(ra) # 80002448 <sleep>
    havekids = 0;
    8000285a:	bf39                	j	80002778 <wait+0x4a>

000000008000285c <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000285c:	7179                	addi	sp,sp,-48
    8000285e:	f406                	sd	ra,40(sp)
    80002860:	f022                	sd	s0,32(sp)
    80002862:	ec26                	sd	s1,24(sp)
    80002864:	e84a                	sd	s2,16(sp)
    80002866:	e44e                	sd	s3,8(sp)
    80002868:	e052                	sd	s4,0(sp)
    8000286a:	1800                	addi	s0,sp,48
    8000286c:	84aa                	mv	s1,a0
    8000286e:	892e                	mv	s2,a1
    80002870:	89b2                	mv	s3,a2
    80002872:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002874:	fffff097          	auipc	ra,0xfffff
    80002878:	394080e7          	jalr	916(ra) # 80001c08 <myproc>
  if (user_dst)
    8000287c:	c08d                	beqz	s1,8000289e <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000287e:	86d2                	mv	a3,s4
    80002880:	864e                	mv	a2,s3
    80002882:	85ca                	mv	a1,s2
    80002884:	6928                	ld	a0,80(a0)
    80002886:	fffff097          	auipc	ra,0xfffff
    8000288a:	008080e7          	jalr	8(ra) # 8000188e <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000288e:	70a2                	ld	ra,40(sp)
    80002890:	7402                	ld	s0,32(sp)
    80002892:	64e2                	ld	s1,24(sp)
    80002894:	6942                	ld	s2,16(sp)
    80002896:	69a2                	ld	s3,8(sp)
    80002898:	6a02                	ld	s4,0(sp)
    8000289a:	6145                	addi	sp,sp,48
    8000289c:	8082                	ret
    memmove((char *)dst, src, len);
    8000289e:	000a061b          	sext.w	a2,s4
    800028a2:	85ce                	mv	a1,s3
    800028a4:	854a                	mv	a0,s2
    800028a6:	ffffe097          	auipc	ra,0xffffe
    800028aa:	5bc080e7          	jalr	1468(ra) # 80000e62 <memmove>
    return 0;
    800028ae:	8526                	mv	a0,s1
    800028b0:	bff9                	j	8000288e <either_copyout+0x32>

00000000800028b2 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800028b2:	7179                	addi	sp,sp,-48
    800028b4:	f406                	sd	ra,40(sp)
    800028b6:	f022                	sd	s0,32(sp)
    800028b8:	ec26                	sd	s1,24(sp)
    800028ba:	e84a                	sd	s2,16(sp)
    800028bc:	e44e                	sd	s3,8(sp)
    800028be:	e052                	sd	s4,0(sp)
    800028c0:	1800                	addi	s0,sp,48
    800028c2:	892a                	mv	s2,a0
    800028c4:	84ae                	mv	s1,a1
    800028c6:	89b2                	mv	s3,a2
    800028c8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028ca:	fffff097          	auipc	ra,0xfffff
    800028ce:	33e080e7          	jalr	830(ra) # 80001c08 <myproc>
  if (user_src)
    800028d2:	c08d                	beqz	s1,800028f4 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    800028d4:	86d2                	mv	a3,s4
    800028d6:	864e                	mv	a2,s3
    800028d8:	85ca                	mv	a1,s2
    800028da:	6928                	ld	a0,80(a0)
    800028dc:	fffff097          	auipc	ra,0xfffff
    800028e0:	076080e7          	jalr	118(ra) # 80001952 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800028e4:	70a2                	ld	ra,40(sp)
    800028e6:	7402                	ld	s0,32(sp)
    800028e8:	64e2                	ld	s1,24(sp)
    800028ea:	6942                	ld	s2,16(sp)
    800028ec:	69a2                	ld	s3,8(sp)
    800028ee:	6a02                	ld	s4,0(sp)
    800028f0:	6145                	addi	sp,sp,48
    800028f2:	8082                	ret
    memmove(dst, (char *)src, len);
    800028f4:	000a061b          	sext.w	a2,s4
    800028f8:	85ce                	mv	a1,s3
    800028fa:	854a                	mv	a0,s2
    800028fc:	ffffe097          	auipc	ra,0xffffe
    80002900:	566080e7          	jalr	1382(ra) # 80000e62 <memmove>
    return 0;
    80002904:	8526                	mv	a0,s1
    80002906:	bff9                	j	800028e4 <either_copyin+0x32>

0000000080002908 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002908:	715d                	addi	sp,sp,-80
    8000290a:	e486                	sd	ra,72(sp)
    8000290c:	e0a2                	sd	s0,64(sp)
    8000290e:	fc26                	sd	s1,56(sp)
    80002910:	f84a                	sd	s2,48(sp)
    80002912:	f44e                	sd	s3,40(sp)
    80002914:	f052                	sd	s4,32(sp)
    80002916:	ec56                	sd	s5,24(sp)
    80002918:	e85a                	sd	s6,16(sp)
    8000291a:	e45e                	sd	s7,8(sp)
    8000291c:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000291e:	00005517          	auipc	a0,0x5
    80002922:	7d250513          	addi	a0,a0,2002 # 800080f0 <digits+0xb0>
    80002926:	ffffe097          	auipc	ra,0xffffe
    8000292a:	c68080e7          	jalr	-920(ra) # 8000058e <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000292e:	0022f497          	auipc	s1,0x22f
    80002932:	8a248493          	addi	s1,s1,-1886 # 802311d0 <proc+0x158>
    80002936:	00235917          	auipc	s2,0x235
    8000293a:	c9a90913          	addi	s2,s2,-870 # 802375d0 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000293e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002940:	00006997          	auipc	s3,0x6
    80002944:	a1898993          	addi	s3,s3,-1512 # 80008358 <digits+0x318>
    printf("%d %s %s", p->pid, state, p->name);
    80002948:	00006a97          	auipc	s5,0x6
    8000294c:	a18a8a93          	addi	s5,s5,-1512 # 80008360 <digits+0x320>
    printf("\n");
    80002950:	00005a17          	auipc	s4,0x5
    80002954:	7a0a0a13          	addi	s4,s4,1952 # 800080f0 <digits+0xb0>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002958:	00006b97          	auipc	s7,0x6
    8000295c:	a48b8b93          	addi	s7,s7,-1464 # 800083a0 <states.1769>
    80002960:	a00d                	j	80002982 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002962:	ed86a583          	lw	a1,-296(a3)
    80002966:	8556                	mv	a0,s5
    80002968:	ffffe097          	auipc	ra,0xffffe
    8000296c:	c26080e7          	jalr	-986(ra) # 8000058e <printf>
    printf("\n");
    80002970:	8552                	mv	a0,s4
    80002972:	ffffe097          	auipc	ra,0xffffe
    80002976:	c1c080e7          	jalr	-996(ra) # 8000058e <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    8000297a:	19048493          	addi	s1,s1,400
    8000297e:	03248163          	beq	s1,s2,800029a0 <procdump+0x98>
    if (p->state == UNUSED)
    80002982:	86a6                	mv	a3,s1
    80002984:	ec04a783          	lw	a5,-320(s1)
    80002988:	dbed                	beqz	a5,8000297a <procdump+0x72>
      state = "???";
    8000298a:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000298c:	fcfb6be3          	bltu	s6,a5,80002962 <procdump+0x5a>
    80002990:	1782                	slli	a5,a5,0x20
    80002992:	9381                	srli	a5,a5,0x20
    80002994:	078e                	slli	a5,a5,0x3
    80002996:	97de                	add	a5,a5,s7
    80002998:	6390                	ld	a2,0(a5)
    8000299a:	f661                	bnez	a2,80002962 <procdump+0x5a>
      state = "???";
    8000299c:	864e                	mv	a2,s3
    8000299e:	b7d1                	j	80002962 <procdump+0x5a>
  }
}
    800029a0:	60a6                	ld	ra,72(sp)
    800029a2:	6406                	ld	s0,64(sp)
    800029a4:	74e2                	ld	s1,56(sp)
    800029a6:	7942                	ld	s2,48(sp)
    800029a8:	79a2                	ld	s3,40(sp)
    800029aa:	7a02                	ld	s4,32(sp)
    800029ac:	6ae2                	ld	s5,24(sp)
    800029ae:	6b42                	ld	s6,16(sp)
    800029b0:	6ba2                	ld	s7,8(sp)
    800029b2:	6161                	addi	sp,sp,80
    800029b4:	8082                	ret

00000000800029b6 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    800029b6:	711d                	addi	sp,sp,-96
    800029b8:	ec86                	sd	ra,88(sp)
    800029ba:	e8a2                	sd	s0,80(sp)
    800029bc:	e4a6                	sd	s1,72(sp)
    800029be:	e0ca                	sd	s2,64(sp)
    800029c0:	fc4e                	sd	s3,56(sp)
    800029c2:	f852                	sd	s4,48(sp)
    800029c4:	f456                	sd	s5,40(sp)
    800029c6:	f05a                	sd	s6,32(sp)
    800029c8:	ec5e                	sd	s7,24(sp)
    800029ca:	e862                	sd	s8,16(sp)
    800029cc:	e466                	sd	s9,8(sp)
    800029ce:	e06a                	sd	s10,0(sp)
    800029d0:	1080                	addi	s0,sp,96
    800029d2:	8b2a                	mv	s6,a0
    800029d4:	8bae                	mv	s7,a1
    800029d6:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800029d8:	fffff097          	auipc	ra,0xfffff
    800029dc:	230080e7          	jalr	560(ra) # 80001c08 <myproc>
    800029e0:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800029e2:	0022e517          	auipc	a0,0x22e
    800029e6:	27e50513          	addi	a0,a0,638 # 80230c60 <wait_lock>
    800029ea:	ffffe097          	auipc	ra,0xffffe
    800029ee:	31c080e7          	jalr	796(ra) # 80000d06 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    800029f2:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    800029f4:	4a15                	li	s4,5
    for (np = proc; np < &proc[NPROC]; np++)
    800029f6:	00235997          	auipc	s3,0x235
    800029fa:	a8298993          	addi	s3,s3,-1406 # 80237478 <tickslock>
        havekids = 1;
    800029fe:	4a85                	li	s5,1
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002a00:	0022ed17          	auipc	s10,0x22e
    80002a04:	260d0d13          	addi	s10,s10,608 # 80230c60 <wait_lock>
    havekids = 0;
    80002a08:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    80002a0a:	0022e497          	auipc	s1,0x22e
    80002a0e:	66e48493          	addi	s1,s1,1646 # 80231078 <proc>
    80002a12:	a059                	j	80002a98 <waitx+0xe2>
          pid = np->pid;
    80002a14:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    80002a18:	1684a703          	lw	a4,360(s1)
    80002a1c:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002a20:	16c4a783          	lw	a5,364(s1)
    80002a24:	9f3d                	addw	a4,a4,a5
    80002a26:	1704a783          	lw	a5,368(s1)
    80002a2a:	9f99                	subw	a5,a5,a4
    80002a2c:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002a30:	000b0e63          	beqz	s6,80002a4c <waitx+0x96>
    80002a34:	4691                	li	a3,4
    80002a36:	02c48613          	addi	a2,s1,44
    80002a3a:	85da                	mv	a1,s6
    80002a3c:	05093503          	ld	a0,80(s2)
    80002a40:	fffff097          	auipc	ra,0xfffff
    80002a44:	e4e080e7          	jalr	-434(ra) # 8000188e <copyout>
    80002a48:	02054563          	bltz	a0,80002a72 <waitx+0xbc>
          freeproc(np);
    80002a4c:	8526                	mv	a0,s1
    80002a4e:	fffff097          	auipc	ra,0xfffff
    80002a52:	36c080e7          	jalr	876(ra) # 80001dba <freeproc>
          release(&np->lock);
    80002a56:	8526                	mv	a0,s1
    80002a58:	ffffe097          	auipc	ra,0xffffe
    80002a5c:	362080e7          	jalr	866(ra) # 80000dba <release>
          release(&wait_lock);
    80002a60:	0022e517          	auipc	a0,0x22e
    80002a64:	20050513          	addi	a0,a0,512 # 80230c60 <wait_lock>
    80002a68:	ffffe097          	auipc	ra,0xffffe
    80002a6c:	352080e7          	jalr	850(ra) # 80000dba <release>
          return pid;
    80002a70:	a09d                	j	80002ad6 <waitx+0x120>
            release(&np->lock);
    80002a72:	8526                	mv	a0,s1
    80002a74:	ffffe097          	auipc	ra,0xffffe
    80002a78:	346080e7          	jalr	838(ra) # 80000dba <release>
            release(&wait_lock);
    80002a7c:	0022e517          	auipc	a0,0x22e
    80002a80:	1e450513          	addi	a0,a0,484 # 80230c60 <wait_lock>
    80002a84:	ffffe097          	auipc	ra,0xffffe
    80002a88:	336080e7          	jalr	822(ra) # 80000dba <release>
            return -1;
    80002a8c:	59fd                	li	s3,-1
    80002a8e:	a0a1                	j	80002ad6 <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    80002a90:	19048493          	addi	s1,s1,400
    80002a94:	03348463          	beq	s1,s3,80002abc <waitx+0x106>
      if (np->parent == p)
    80002a98:	7c9c                	ld	a5,56(s1)
    80002a9a:	ff279be3          	bne	a5,s2,80002a90 <waitx+0xda>
        acquire(&np->lock);
    80002a9e:	8526                	mv	a0,s1
    80002aa0:	ffffe097          	auipc	ra,0xffffe
    80002aa4:	266080e7          	jalr	614(ra) # 80000d06 <acquire>
        if (np->state == ZOMBIE)
    80002aa8:	4c9c                	lw	a5,24(s1)
    80002aaa:	f74785e3          	beq	a5,s4,80002a14 <waitx+0x5e>
        release(&np->lock);
    80002aae:	8526                	mv	a0,s1
    80002ab0:	ffffe097          	auipc	ra,0xffffe
    80002ab4:	30a080e7          	jalr	778(ra) # 80000dba <release>
        havekids = 1;
    80002ab8:	8756                	mv	a4,s5
    80002aba:	bfd9                	j	80002a90 <waitx+0xda>
    if (!havekids || p->killed)
    80002abc:	c701                	beqz	a4,80002ac4 <waitx+0x10e>
    80002abe:	02892783          	lw	a5,40(s2)
    80002ac2:	cb8d                	beqz	a5,80002af4 <waitx+0x13e>
      release(&wait_lock);
    80002ac4:	0022e517          	auipc	a0,0x22e
    80002ac8:	19c50513          	addi	a0,a0,412 # 80230c60 <wait_lock>
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	2ee080e7          	jalr	750(ra) # 80000dba <release>
      return -1;
    80002ad4:	59fd                	li	s3,-1
  }
}
    80002ad6:	854e                	mv	a0,s3
    80002ad8:	60e6                	ld	ra,88(sp)
    80002ada:	6446                	ld	s0,80(sp)
    80002adc:	64a6                	ld	s1,72(sp)
    80002ade:	6906                	ld	s2,64(sp)
    80002ae0:	79e2                	ld	s3,56(sp)
    80002ae2:	7a42                	ld	s4,48(sp)
    80002ae4:	7aa2                	ld	s5,40(sp)
    80002ae6:	7b02                	ld	s6,32(sp)
    80002ae8:	6be2                	ld	s7,24(sp)
    80002aea:	6c42                	ld	s8,16(sp)
    80002aec:	6ca2                	ld	s9,8(sp)
    80002aee:	6d02                	ld	s10,0(sp)
    80002af0:	6125                	addi	sp,sp,96
    80002af2:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002af4:	85ea                	mv	a1,s10
    80002af6:	854a                	mv	a0,s2
    80002af8:	00000097          	auipc	ra,0x0
    80002afc:	950080e7          	jalr	-1712(ra) # 80002448 <sleep>
    havekids = 0;
    80002b00:	b721                	j	80002a08 <waitx+0x52>

0000000080002b02 <update_time>:

void update_time()
{
    80002b02:	7139                	addi	sp,sp,-64
    80002b04:	fc06                	sd	ra,56(sp)
    80002b06:	f822                	sd	s0,48(sp)
    80002b08:	f426                	sd	s1,40(sp)
    80002b0a:	f04a                	sd	s2,32(sp)
    80002b0c:	ec4e                	sd	s3,24(sp)
    80002b0e:	e852                	sd	s4,16(sp)
    80002b10:	e456                	sd	s5,8(sp)
    80002b12:	0080                	addi	s0,sp,64
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002b14:	0022e497          	auipc	s1,0x22e
    80002b18:	56448493          	addi	s1,s1,1380 # 80231078 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    80002b1c:	4991                	li	s3,4
    {
      p->rtime++;
    }
// For PBS
#ifdef PBS
    if (p->state == RUNNABLE)
    80002b1e:	4a0d                	li	s4,3
    {
      p->pbs_wtime++;
    }
    else if (p->state == SLEEPING)
    80002b20:	4a89                	li	s5,2
  for (p = proc; p < &proc[NPROC]; p++)
    80002b22:	00235917          	auipc	s2,0x235
    80002b26:	95690913          	addi	s2,s2,-1706 # 80237478 <tickslock>
    80002b2a:	a025                	j	80002b52 <update_time+0x50>
      p->rtime++;
    80002b2c:	1684a783          	lw	a5,360(s1)
    80002b30:	2785                	addiw	a5,a5,1
    80002b32:	16f4a423          	sw	a5,360(s1)
    {
      p->pbs_stime++;
    }
    else if (p->state == RUNNING)
    {
      p->pbs_rtime++;
    80002b36:	1804a783          	lw	a5,384(s1)
    80002b3a:	2785                	addiw	a5,a5,1
    80002b3c:	18f4a023          	sw	a5,384(s1)
    // {
    //   p->pbs_dynamic_priority = dp_priority(p);
    //   printf("%d,%d,%d\n", p->pid, ticks, p->pbs_dynamic_priority); 
    // }
#endif
    release(&p->lock);
    80002b40:	8526                	mv	a0,s1
    80002b42:	ffffe097          	auipc	ra,0xffffe
    80002b46:	278080e7          	jalr	632(ra) # 80000dba <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002b4a:	19048493          	addi	s1,s1,400
    80002b4e:	03248a63          	beq	s1,s2,80002b82 <update_time+0x80>
    acquire(&p->lock);
    80002b52:	8526                	mv	a0,s1
    80002b54:	ffffe097          	auipc	ra,0xffffe
    80002b58:	1b2080e7          	jalr	434(ra) # 80000d06 <acquire>
    if (p->state == RUNNING)
    80002b5c:	4c9c                	lw	a5,24(s1)
    80002b5e:	fd3787e3          	beq	a5,s3,80002b2c <update_time+0x2a>
    if (p->state == RUNNABLE)
    80002b62:	01478a63          	beq	a5,s4,80002b76 <update_time+0x74>
    else if (p->state == SLEEPING)
    80002b66:	fd579de3          	bne	a5,s5,80002b40 <update_time+0x3e>
      p->pbs_stime++;
    80002b6a:	1884a783          	lw	a5,392(s1)
    80002b6e:	2785                	addiw	a5,a5,1
    80002b70:	18f4a423          	sw	a5,392(s1)
    80002b74:	b7f1                	j	80002b40 <update_time+0x3e>
      p->pbs_wtime++;
    80002b76:	1844a783          	lw	a5,388(s1)
    80002b7a:	2785                	addiw	a5,a5,1
    80002b7c:	18f4a223          	sw	a5,388(s1)
    80002b80:	b7c1                	j	80002b40 <update_time+0x3e>
  }
}
    80002b82:	70e2                	ld	ra,56(sp)
    80002b84:	7442                	ld	s0,48(sp)
    80002b86:	74a2                	ld	s1,40(sp)
    80002b88:	7902                	ld	s2,32(sp)
    80002b8a:	69e2                	ld	s3,24(sp)
    80002b8c:	6a42                	ld	s4,16(sp)
    80002b8e:	6aa2                	ld	s5,8(sp)
    80002b90:	6121                	addi	sp,sp,64
    80002b92:	8082                	ret

0000000080002b94 <setpriority>:

// for PBS, Copilot
int setpriority(int pid, int priority)
{
    80002b94:	715d                	addi	sp,sp,-80
    80002b96:	e486                	sd	ra,72(sp)
    80002b98:	e0a2                	sd	s0,64(sp)
    80002b9a:	fc26                	sd	s1,56(sp)
    80002b9c:	f84a                	sd	s2,48(sp)
    80002b9e:	f44e                	sd	s3,40(sp)
    80002ba0:	f052                	sd	s4,32(sp)
    80002ba2:	ec56                	sd	s5,24(sp)
    80002ba4:	e85a                	sd	s6,16(sp)
    80002ba6:	e45e                	sd	s7,8(sp)
    80002ba8:	e062                	sd	s8,0(sp)
    80002baa:	0880                	addi	s0,sp,80
    80002bac:	892a                	mv	s2,a0
    80002bae:	8a2e                	mv	s4,a1
  struct proc *p;
  int found = 0;
  int old_static_priority = 0;
    80002bb0:	4a81                	li	s5,0
  int found = 0;
    80002bb2:	4b01                	li	s6,0

  for (p = proc; p < &proc[NPROC]; p++)
    80002bb4:	0022e497          	auipc	s1,0x22e
    80002bb8:	4c448493          	addi	s1,s1,1220 # 80231078 <proc>
    acquire(&p->lock);
    if (p->pid == pid)
    {
      old_static_priority = p->pbs_static_priority;
      p->pbs_static_priority = priority;
      p->pbs_rbi =25;
    80002bbc:	4c65                	li	s8,25

      found = 1;
    80002bbe:	4b85                	li	s7,1
  for (p = proc; p < &proc[NPROC]; p++)
    80002bc0:	00235997          	auipc	s3,0x235
    80002bc4:	8b898993          	addi	s3,s3,-1864 # 80237478 <tickslock>
    80002bc8:	a811                	j	80002bdc <setpriority+0x48>
    }
    release(&p->lock);
    80002bca:	8526                	mv	a0,s1
    80002bcc:	ffffe097          	auipc	ra,0xffffe
    80002bd0:	1ee080e7          	jalr	494(ra) # 80000dba <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002bd4:	19048493          	addi	s1,s1,400
    80002bd8:	03348263          	beq	s1,s3,80002bfc <setpriority+0x68>
    acquire(&p->lock);
    80002bdc:	8526                	mv	a0,s1
    80002bde:	ffffe097          	auipc	ra,0xffffe
    80002be2:	128080e7          	jalr	296(ra) # 80000d06 <acquire>
    if (p->pid == pid)
    80002be6:	589c                	lw	a5,48(s1)
    80002be8:	ff2791e3          	bne	a5,s2,80002bca <setpriority+0x36>
      old_static_priority = p->pbs_static_priority;
    80002bec:	1744aa83          	lw	s5,372(s1)
      p->pbs_static_priority = priority;
    80002bf0:	1744aa23          	sw	s4,372(s1)
      p->pbs_rbi =25;
    80002bf4:	1784ae23          	sw	s8,380(s1)
      found = 1;
    80002bf8:	8b5e                	mv	s6,s7
    80002bfa:	bfc1                	j	80002bca <setpriority+0x36>
  }
  if (found == 0)
    80002bfc:	000b0f63          	beqz	s6,80002c1a <setpriority+0x86>
    return -1;
  return old_static_priority;
}
    80002c00:	8556                	mv	a0,s5
    80002c02:	60a6                	ld	ra,72(sp)
    80002c04:	6406                	ld	s0,64(sp)
    80002c06:	74e2                	ld	s1,56(sp)
    80002c08:	7942                	ld	s2,48(sp)
    80002c0a:	79a2                	ld	s3,40(sp)
    80002c0c:	7a02                	ld	s4,32(sp)
    80002c0e:	6ae2                	ld	s5,24(sp)
    80002c10:	6b42                	ld	s6,16(sp)
    80002c12:	6ba2                	ld	s7,8(sp)
    80002c14:	6c02                	ld	s8,0(sp)
    80002c16:	6161                	addi	sp,sp,80
    80002c18:	8082                	ret
    return -1;
    80002c1a:	5afd                	li	s5,-1
    80002c1c:	b7d5                	j	80002c00 <setpriority+0x6c>

0000000080002c1e <swtch>:
    80002c1e:	00153023          	sd	ra,0(a0)
    80002c22:	00253423          	sd	sp,8(a0)
    80002c26:	e900                	sd	s0,16(a0)
    80002c28:	ed04                	sd	s1,24(a0)
    80002c2a:	03253023          	sd	s2,32(a0)
    80002c2e:	03353423          	sd	s3,40(a0)
    80002c32:	03453823          	sd	s4,48(a0)
    80002c36:	03553c23          	sd	s5,56(a0)
    80002c3a:	05653023          	sd	s6,64(a0)
    80002c3e:	05753423          	sd	s7,72(a0)
    80002c42:	05853823          	sd	s8,80(a0)
    80002c46:	05953c23          	sd	s9,88(a0)
    80002c4a:	07a53023          	sd	s10,96(a0)
    80002c4e:	07b53423          	sd	s11,104(a0)
    80002c52:	0005b083          	ld	ra,0(a1)
    80002c56:	0085b103          	ld	sp,8(a1)
    80002c5a:	6980                	ld	s0,16(a1)
    80002c5c:	6d84                	ld	s1,24(a1)
    80002c5e:	0205b903          	ld	s2,32(a1)
    80002c62:	0285b983          	ld	s3,40(a1)
    80002c66:	0305ba03          	ld	s4,48(a1)
    80002c6a:	0385ba83          	ld	s5,56(a1)
    80002c6e:	0405bb03          	ld	s6,64(a1)
    80002c72:	0485bb83          	ld	s7,72(a1)
    80002c76:	0505bc03          	ld	s8,80(a1)
    80002c7a:	0585bc83          	ld	s9,88(a1)
    80002c7e:	0605bd03          	ld	s10,96(a1)
    80002c82:	0685bd83          	ld	s11,104(a1)
    80002c86:	8082                	ret

0000000080002c88 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002c88:	1141                	addi	sp,sp,-16
    80002c8a:	e406                	sd	ra,8(sp)
    80002c8c:	e022                	sd	s0,0(sp)
    80002c8e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c90:	00005597          	auipc	a1,0x5
    80002c94:	74058593          	addi	a1,a1,1856 # 800083d0 <states.1769+0x30>
    80002c98:	00234517          	auipc	a0,0x234
    80002c9c:	7e050513          	addi	a0,a0,2016 # 80237478 <tickslock>
    80002ca0:	ffffe097          	auipc	ra,0xffffe
    80002ca4:	fd6080e7          	jalr	-42(ra) # 80000c76 <initlock>
}
    80002ca8:	60a2                	ld	ra,8(sp)
    80002caa:	6402                	ld	s0,0(sp)
    80002cac:	0141                	addi	sp,sp,16
    80002cae:	8082                	ret

0000000080002cb0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002cb0:	1141                	addi	sp,sp,-16
    80002cb2:	e422                	sd	s0,8(sp)
    80002cb4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cb6:	00003797          	auipc	a5,0x3
    80002cba:	6fa78793          	addi	a5,a5,1786 # 800063b0 <kernelvec>
    80002cbe:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002cc2:	6422                	ld	s0,8(sp)
    80002cc4:	0141                	addi	sp,sp,16
    80002cc6:	8082                	ret

0000000080002cc8 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002cc8:	1141                	addi	sp,sp,-16
    80002cca:	e406                	sd	ra,8(sp)
    80002ccc:	e022                	sd	s0,0(sp)
    80002cce:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002cd0:	fffff097          	auipc	ra,0xfffff
    80002cd4:	f38080e7          	jalr	-200(ra) # 80001c08 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002cdc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cde:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002ce2:	00004617          	auipc	a2,0x4
    80002ce6:	31e60613          	addi	a2,a2,798 # 80007000 <_trampoline>
    80002cea:	00004697          	auipc	a3,0x4
    80002cee:	31668693          	addi	a3,a3,790 # 80007000 <_trampoline>
    80002cf2:	8e91                	sub	a3,a3,a2
    80002cf4:	040007b7          	lui	a5,0x4000
    80002cf8:	17fd                	addi	a5,a5,-1
    80002cfa:	07b2                	slli	a5,a5,0xc
    80002cfc:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cfe:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002d02:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002d04:	180026f3          	csrr	a3,satp
    80002d08:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002d0a:	6d38                	ld	a4,88(a0)
    80002d0c:	6134                	ld	a3,64(a0)
    80002d0e:	6585                	lui	a1,0x1
    80002d10:	96ae                	add	a3,a3,a1
    80002d12:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002d14:	6d38                	ld	a4,88(a0)
    80002d16:	00000697          	auipc	a3,0x0
    80002d1a:	13e68693          	addi	a3,a3,318 # 80002e54 <usertrap>
    80002d1e:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002d20:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002d22:	8692                	mv	a3,tp
    80002d24:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d26:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002d2a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002d2e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d32:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002d36:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d38:	6f18                	ld	a4,24(a4)
    80002d3a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002d3e:	6928                	ld	a0,80(a0)
    80002d40:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002d42:	00004717          	auipc	a4,0x4
    80002d46:	35a70713          	addi	a4,a4,858 # 8000709c <userret>
    80002d4a:	8f11                	sub	a4,a4,a2
    80002d4c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002d4e:	577d                	li	a4,-1
    80002d50:	177e                	slli	a4,a4,0x3f
    80002d52:	8d59                	or	a0,a0,a4
    80002d54:	9782                	jalr	a5
}
    80002d56:	60a2                	ld	ra,8(sp)
    80002d58:	6402                	ld	s0,0(sp)
    80002d5a:	0141                	addi	sp,sp,16
    80002d5c:	8082                	ret

0000000080002d5e <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002d5e:	1101                	addi	sp,sp,-32
    80002d60:	ec06                	sd	ra,24(sp)
    80002d62:	e822                	sd	s0,16(sp)
    80002d64:	e426                	sd	s1,8(sp)
    80002d66:	e04a                	sd	s2,0(sp)
    80002d68:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002d6a:	00234917          	auipc	s2,0x234
    80002d6e:	70e90913          	addi	s2,s2,1806 # 80237478 <tickslock>
    80002d72:	854a                	mv	a0,s2
    80002d74:	ffffe097          	auipc	ra,0xffffe
    80002d78:	f92080e7          	jalr	-110(ra) # 80000d06 <acquire>
  ticks++;
    80002d7c:	00006497          	auipc	s1,0x6
    80002d80:	c4448493          	addi	s1,s1,-956 # 800089c0 <ticks>
    80002d84:	409c                	lw	a5,0(s1)
    80002d86:	2785                	addiw	a5,a5,1
    80002d88:	c09c                	sw	a5,0(s1)
  update_time();
    80002d8a:	00000097          	auipc	ra,0x0
    80002d8e:	d78080e7          	jalr	-648(ra) # 80002b02 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002d92:	8526                	mv	a0,s1
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	718080e7          	jalr	1816(ra) # 800024ac <wakeup>
  release(&tickslock);
    80002d9c:	854a                	mv	a0,s2
    80002d9e:	ffffe097          	auipc	ra,0xffffe
    80002da2:	01c080e7          	jalr	28(ra) # 80000dba <release>
}
    80002da6:	60e2                	ld	ra,24(sp)
    80002da8:	6442                	ld	s0,16(sp)
    80002daa:	64a2                	ld	s1,8(sp)
    80002dac:	6902                	ld	s2,0(sp)
    80002dae:	6105                	addi	sp,sp,32
    80002db0:	8082                	ret

0000000080002db2 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002db2:	1101                	addi	sp,sp,-32
    80002db4:	ec06                	sd	ra,24(sp)
    80002db6:	e822                	sd	s0,16(sp)
    80002db8:	e426                	sd	s1,8(sp)
    80002dba:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dbc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002dc0:	00074d63          	bltz	a4,80002dda <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002dc4:	57fd                	li	a5,-1
    80002dc6:	17fe                	slli	a5,a5,0x3f
    80002dc8:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002dca:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002dcc:	06f70363          	beq	a4,a5,80002e32 <devintr+0x80>
  }
    80002dd0:	60e2                	ld	ra,24(sp)
    80002dd2:	6442                	ld	s0,16(sp)
    80002dd4:	64a2                	ld	s1,8(sp)
    80002dd6:	6105                	addi	sp,sp,32
    80002dd8:	8082                	ret
      (scause & 0xff) == 9)
    80002dda:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80002dde:	46a5                	li	a3,9
    80002de0:	fed792e3          	bne	a5,a3,80002dc4 <devintr+0x12>
    int irq = plic_claim();
    80002de4:	00003097          	auipc	ra,0x3
    80002de8:	6d4080e7          	jalr	1748(ra) # 800064b8 <plic_claim>
    80002dec:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002dee:	47a9                	li	a5,10
    80002df0:	02f50763          	beq	a0,a5,80002e1e <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002df4:	4785                	li	a5,1
    80002df6:	02f50963          	beq	a0,a5,80002e28 <devintr+0x76>
    return 1;
    80002dfa:	4505                	li	a0,1
    else if (irq)
    80002dfc:	d8f1                	beqz	s1,80002dd0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002dfe:	85a6                	mv	a1,s1
    80002e00:	00005517          	auipc	a0,0x5
    80002e04:	5d850513          	addi	a0,a0,1496 # 800083d8 <states.1769+0x38>
    80002e08:	ffffd097          	auipc	ra,0xffffd
    80002e0c:	786080e7          	jalr	1926(ra) # 8000058e <printf>
      plic_complete(irq);
    80002e10:	8526                	mv	a0,s1
    80002e12:	00003097          	auipc	ra,0x3
    80002e16:	6ca080e7          	jalr	1738(ra) # 800064dc <plic_complete>
    return 1;
    80002e1a:	4505                	li	a0,1
    80002e1c:	bf55                	j	80002dd0 <devintr+0x1e>
      uartintr();
    80002e1e:	ffffe097          	auipc	ra,0xffffe
    80002e22:	b90080e7          	jalr	-1136(ra) # 800009ae <uartintr>
    80002e26:	b7ed                	j	80002e10 <devintr+0x5e>
      virtio_disk_intr();
    80002e28:	00004097          	auipc	ra,0x4
    80002e2c:	bde080e7          	jalr	-1058(ra) # 80006a06 <virtio_disk_intr>
    80002e30:	b7c5                	j	80002e10 <devintr+0x5e>
    if (cpuid() == 0)
    80002e32:	fffff097          	auipc	ra,0xfffff
    80002e36:	daa080e7          	jalr	-598(ra) # 80001bdc <cpuid>
    80002e3a:	c901                	beqz	a0,80002e4a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002e3c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002e40:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002e42:	14479073          	csrw	sip,a5
    return 2;
    80002e46:	4509                	li	a0,2
    80002e48:	b761                	j	80002dd0 <devintr+0x1e>
      clockintr();
    80002e4a:	00000097          	auipc	ra,0x0
    80002e4e:	f14080e7          	jalr	-236(ra) # 80002d5e <clockintr>
    80002e52:	b7ed                	j	80002e3c <devintr+0x8a>

0000000080002e54 <usertrap>:
{
    80002e54:	1101                	addi	sp,sp,-32
    80002e56:	ec06                	sd	ra,24(sp)
    80002e58:	e822                	sd	s0,16(sp)
    80002e5a:	e426                	sd	s1,8(sp)
    80002e5c:	e04a                	sd	s2,0(sp)
    80002e5e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e60:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002e64:	1007f793          	andi	a5,a5,256
    80002e68:	e3d9                	bnez	a5,80002eee <usertrap+0x9a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e6a:	00003797          	auipc	a5,0x3
    80002e6e:	54678793          	addi	a5,a5,1350 # 800063b0 <kernelvec>
    80002e72:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002e76:	fffff097          	auipc	ra,0xfffff
    80002e7a:	d92080e7          	jalr	-622(ra) # 80001c08 <myproc>
    80002e7e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002e80:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e82:	14102773          	csrr	a4,sepc
    80002e86:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e88:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002e8c:	47a1                	li	a5,8
    80002e8e:	06f70863          	beq	a4,a5,80002efe <usertrap+0xaa>
    80002e92:	14202773          	csrr	a4,scause
  else if (r_scause() == 15)
    80002e96:	47bd                	li	a5,15
    80002e98:	0af71663          	bne	a4,a5,80002f44 <usertrap+0xf0>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e9c:	143026f3          	csrr	a3,stval
    if (stval >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE)
    80002ea0:	6d38                	ld	a4,88(a0)
    80002ea2:	77fd                	lui	a5,0xfffff
    80002ea4:	7b18                	ld	a4,48(a4)
    80002ea6:	8f7d                	and	a4,a4,a5
    80002ea8:	97ba                	add	a5,a5,a4
    80002eaa:	00f6e463          	bltu	a3,a5,80002eb2 <usertrap+0x5e>
      if (stval <= PGROUNDDOWN(p->trapframe->sp))
    80002eae:	00d77663          	bgeu	a4,a3,80002eba <usertrap+0x66>
    if (flag)
    80002eb2:	57fd                	li	a5,-1
    80002eb4:	83e9                	srli	a5,a5,0x1a
    80002eb6:	06d7fe63          	bgeu	a5,a3,80002f32 <usertrap+0xde>
      printf("Error\n");
    80002eba:	00005517          	auipc	a0,0x5
    80002ebe:	55e50513          	addi	a0,a0,1374 # 80008418 <states.1769+0x78>
    80002ec2:	ffffd097          	auipc	ra,0xffffd
    80002ec6:	6cc080e7          	jalr	1740(ra) # 8000058e <printf>
      p->killed = 1;
    80002eca:	4785                	li	a5,1
    80002ecc:	d49c                	sw	a5,40(s1)
  if (killed(p))
    80002ece:	8526                	mv	a0,s1
    80002ed0:	00000097          	auipc	ra,0x0
    80002ed4:	82c080e7          	jalr	-2004(ra) # 800026fc <killed>
    80002ed8:	e161                	bnez	a0,80002f98 <usertrap+0x144>
  usertrapret();
    80002eda:	00000097          	auipc	ra,0x0
    80002ede:	dee080e7          	jalr	-530(ra) # 80002cc8 <usertrapret>
}
    80002ee2:	60e2                	ld	ra,24(sp)
    80002ee4:	6442                	ld	s0,16(sp)
    80002ee6:	64a2                	ld	s1,8(sp)
    80002ee8:	6902                	ld	s2,0(sp)
    80002eea:	6105                	addi	sp,sp,32
    80002eec:	8082                	ret
    panic("usertrap: not from user mode");
    80002eee:	00005517          	auipc	a0,0x5
    80002ef2:	50a50513          	addi	a0,a0,1290 # 800083f8 <states.1769+0x58>
    80002ef6:	ffffd097          	auipc	ra,0xffffd
    80002efa:	64e080e7          	jalr	1614(ra) # 80000544 <panic>
    if (killed(p))
    80002efe:	fffff097          	auipc	ra,0xfffff
    80002f02:	7fe080e7          	jalr	2046(ra) # 800026fc <killed>
    80002f06:	e105                	bnez	a0,80002f26 <usertrap+0xd2>
    p->trapframe->epc += 4;
    80002f08:	6cb8                	ld	a4,88(s1)
    80002f0a:	6f1c                	ld	a5,24(a4)
    80002f0c:	0791                	addi	a5,a5,4
    80002f0e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f10:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002f14:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f18:	10079073          	csrw	sstatus,a5
    syscall();
    80002f1c:	00000097          	auipc	ra,0x0
    80002f20:	2e2080e7          	jalr	738(ra) # 800031fe <syscall>
    80002f24:	b76d                	j	80002ece <usertrap+0x7a>
      exit(-1);
    80002f26:	557d                	li	a0,-1
    80002f28:	fffff097          	auipc	ra,0xfffff
    80002f2c:	654080e7          	jalr	1620(ra) # 8000257c <exit>
    80002f30:	bfe1                	j	80002f08 <usertrap+0xb4>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f32:	143025f3          	csrr	a1,stval
      p->killed = custom_cow(p->pagetable, r_stval());
    80002f36:	68a8                	ld	a0,80(s1)
    80002f38:	fffff097          	auipc	ra,0xfffff
    80002f3c:	842080e7          	jalr	-1982(ra) # 8000177a <custom_cow>
    80002f40:	d488                	sw	a0,40(s1)
    80002f42:	b771                	j	80002ece <usertrap+0x7a>
  else if ((which_dev = devintr()) != 0)
    80002f44:	00000097          	auipc	ra,0x0
    80002f48:	e6e080e7          	jalr	-402(ra) # 80002db2 <devintr>
    80002f4c:	892a                	mv	s2,a0
    80002f4e:	c901                	beqz	a0,80002f5e <usertrap+0x10a>
  if (killed(p))
    80002f50:	8526                	mv	a0,s1
    80002f52:	fffff097          	auipc	ra,0xfffff
    80002f56:	7aa080e7          	jalr	1962(ra) # 800026fc <killed>
    80002f5a:	c529                	beqz	a0,80002fa4 <usertrap+0x150>
    80002f5c:	a83d                	j	80002f9a <usertrap+0x146>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f5e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002f62:	5890                	lw	a2,48(s1)
    80002f64:	00005517          	auipc	a0,0x5
    80002f68:	4bc50513          	addi	a0,a0,1212 # 80008420 <states.1769+0x80>
    80002f6c:	ffffd097          	auipc	ra,0xffffd
    80002f70:	622080e7          	jalr	1570(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f74:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f78:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f7c:	00005517          	auipc	a0,0x5
    80002f80:	4d450513          	addi	a0,a0,1236 # 80008450 <states.1769+0xb0>
    80002f84:	ffffd097          	auipc	ra,0xffffd
    80002f88:	60a080e7          	jalr	1546(ra) # 8000058e <printf>
    setkilled(p);
    80002f8c:	8526                	mv	a0,s1
    80002f8e:	fffff097          	auipc	ra,0xfffff
    80002f92:	742080e7          	jalr	1858(ra) # 800026d0 <setkilled>
    80002f96:	bf25                	j	80002ece <usertrap+0x7a>
  if (killed(p))
    80002f98:	4901                	li	s2,0
    exit(-1);
    80002f9a:	557d                	li	a0,-1
    80002f9c:	fffff097          	auipc	ra,0xfffff
    80002fa0:	5e0080e7          	jalr	1504(ra) # 8000257c <exit>
  if (which_dev == 2)
    80002fa4:	4789                	li	a5,2
    80002fa6:	f2f91ae3          	bne	s2,a5,80002eda <usertrap+0x86>
    yield();
    80002faa:	fffff097          	auipc	ra,0xfffff
    80002fae:	462080e7          	jalr	1122(ra) # 8000240c <yield>
    80002fb2:	b725                	j	80002eda <usertrap+0x86>

0000000080002fb4 <kerneltrap>:
{
    80002fb4:	7179                	addi	sp,sp,-48
    80002fb6:	f406                	sd	ra,40(sp)
    80002fb8:	f022                	sd	s0,32(sp)
    80002fba:	ec26                	sd	s1,24(sp)
    80002fbc:	e84a                	sd	s2,16(sp)
    80002fbe:	e44e                	sd	s3,8(sp)
    80002fc0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fc2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fc6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fca:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002fce:	1004f793          	andi	a5,s1,256
    80002fd2:	cb85                	beqz	a5,80003002 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fd4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002fd8:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002fda:	ef85                	bnez	a5,80003012 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002fdc:	00000097          	auipc	ra,0x0
    80002fe0:	dd6080e7          	jalr	-554(ra) # 80002db2 <devintr>
    80002fe4:	cd1d                	beqz	a0,80003022 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002fe6:	4789                	li	a5,2
    80002fe8:	06f50a63          	beq	a0,a5,8000305c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002fec:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ff0:	10049073          	csrw	sstatus,s1
}
    80002ff4:	70a2                	ld	ra,40(sp)
    80002ff6:	7402                	ld	s0,32(sp)
    80002ff8:	64e2                	ld	s1,24(sp)
    80002ffa:	6942                	ld	s2,16(sp)
    80002ffc:	69a2                	ld	s3,8(sp)
    80002ffe:	6145                	addi	sp,sp,48
    80003000:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003002:	00005517          	auipc	a0,0x5
    80003006:	46e50513          	addi	a0,a0,1134 # 80008470 <states.1769+0xd0>
    8000300a:	ffffd097          	auipc	ra,0xffffd
    8000300e:	53a080e7          	jalr	1338(ra) # 80000544 <panic>
    panic("kerneltrap: interrupts enabled");
    80003012:	00005517          	auipc	a0,0x5
    80003016:	48650513          	addi	a0,a0,1158 # 80008498 <states.1769+0xf8>
    8000301a:	ffffd097          	auipc	ra,0xffffd
    8000301e:	52a080e7          	jalr	1322(ra) # 80000544 <panic>
    printf("scause %p\n", scause);
    80003022:	85ce                	mv	a1,s3
    80003024:	00005517          	auipc	a0,0x5
    80003028:	49450513          	addi	a0,a0,1172 # 800084b8 <states.1769+0x118>
    8000302c:	ffffd097          	auipc	ra,0xffffd
    80003030:	562080e7          	jalr	1378(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003034:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003038:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000303c:	00005517          	auipc	a0,0x5
    80003040:	48c50513          	addi	a0,a0,1164 # 800084c8 <states.1769+0x128>
    80003044:	ffffd097          	auipc	ra,0xffffd
    80003048:	54a080e7          	jalr	1354(ra) # 8000058e <printf>
    panic("kerneltrap");
    8000304c:	00005517          	auipc	a0,0x5
    80003050:	49450513          	addi	a0,a0,1172 # 800084e0 <states.1769+0x140>
    80003054:	ffffd097          	auipc	ra,0xffffd
    80003058:	4f0080e7          	jalr	1264(ra) # 80000544 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000305c:	fffff097          	auipc	ra,0xfffff
    80003060:	bac080e7          	jalr	-1108(ra) # 80001c08 <myproc>
    80003064:	d541                	beqz	a0,80002fec <kerneltrap+0x38>
    80003066:	fffff097          	auipc	ra,0xfffff
    8000306a:	ba2080e7          	jalr	-1118(ra) # 80001c08 <myproc>
    8000306e:	4d18                	lw	a4,24(a0)
    80003070:	4791                	li	a5,4
    80003072:	f6f71de3          	bne	a4,a5,80002fec <kerneltrap+0x38>
    yield();
    80003076:	fffff097          	auipc	ra,0xfffff
    8000307a:	396080e7          	jalr	918(ra) # 8000240c <yield>
    8000307e:	b7bd                	j	80002fec <kerneltrap+0x38>

0000000080003080 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003080:	1101                	addi	sp,sp,-32
    80003082:	ec06                	sd	ra,24(sp)
    80003084:	e822                	sd	s0,16(sp)
    80003086:	e426                	sd	s1,8(sp)
    80003088:	1000                	addi	s0,sp,32
    8000308a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000308c:	fffff097          	auipc	ra,0xfffff
    80003090:	b7c080e7          	jalr	-1156(ra) # 80001c08 <myproc>
  switch (n) {
    80003094:	4795                	li	a5,5
    80003096:	0497e163          	bltu	a5,s1,800030d8 <argraw+0x58>
    8000309a:	048a                	slli	s1,s1,0x2
    8000309c:	00005717          	auipc	a4,0x5
    800030a0:	47c70713          	addi	a4,a4,1148 # 80008518 <states.1769+0x178>
    800030a4:	94ba                	add	s1,s1,a4
    800030a6:	409c                	lw	a5,0(s1)
    800030a8:	97ba                	add	a5,a5,a4
    800030aa:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800030ac:	6d3c                	ld	a5,88(a0)
    800030ae:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800030b0:	60e2                	ld	ra,24(sp)
    800030b2:	6442                	ld	s0,16(sp)
    800030b4:	64a2                	ld	s1,8(sp)
    800030b6:	6105                	addi	sp,sp,32
    800030b8:	8082                	ret
    return p->trapframe->a1;
    800030ba:	6d3c                	ld	a5,88(a0)
    800030bc:	7fa8                	ld	a0,120(a5)
    800030be:	bfcd                	j	800030b0 <argraw+0x30>
    return p->trapframe->a2;
    800030c0:	6d3c                	ld	a5,88(a0)
    800030c2:	63c8                	ld	a0,128(a5)
    800030c4:	b7f5                	j	800030b0 <argraw+0x30>
    return p->trapframe->a3;
    800030c6:	6d3c                	ld	a5,88(a0)
    800030c8:	67c8                	ld	a0,136(a5)
    800030ca:	b7dd                	j	800030b0 <argraw+0x30>
    return p->trapframe->a4;
    800030cc:	6d3c                	ld	a5,88(a0)
    800030ce:	6bc8                	ld	a0,144(a5)
    800030d0:	b7c5                	j	800030b0 <argraw+0x30>
    return p->trapframe->a5;
    800030d2:	6d3c                	ld	a5,88(a0)
    800030d4:	6fc8                	ld	a0,152(a5)
    800030d6:	bfe9                	j	800030b0 <argraw+0x30>
  panic("argraw");
    800030d8:	00005517          	auipc	a0,0x5
    800030dc:	41850513          	addi	a0,a0,1048 # 800084f0 <states.1769+0x150>
    800030e0:	ffffd097          	auipc	ra,0xffffd
    800030e4:	464080e7          	jalr	1124(ra) # 80000544 <panic>

00000000800030e8 <fetchaddr>:
{
    800030e8:	1101                	addi	sp,sp,-32
    800030ea:	ec06                	sd	ra,24(sp)
    800030ec:	e822                	sd	s0,16(sp)
    800030ee:	e426                	sd	s1,8(sp)
    800030f0:	e04a                	sd	s2,0(sp)
    800030f2:	1000                	addi	s0,sp,32
    800030f4:	84aa                	mv	s1,a0
    800030f6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800030f8:	fffff097          	auipc	ra,0xfffff
    800030fc:	b10080e7          	jalr	-1264(ra) # 80001c08 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80003100:	653c                	ld	a5,72(a0)
    80003102:	02f4f863          	bgeu	s1,a5,80003132 <fetchaddr+0x4a>
    80003106:	00848713          	addi	a4,s1,8
    8000310a:	02e7e663          	bltu	a5,a4,80003136 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000310e:	46a1                	li	a3,8
    80003110:	8626                	mv	a2,s1
    80003112:	85ca                	mv	a1,s2
    80003114:	6928                	ld	a0,80(a0)
    80003116:	fffff097          	auipc	ra,0xfffff
    8000311a:	83c080e7          	jalr	-1988(ra) # 80001952 <copyin>
    8000311e:	00a03533          	snez	a0,a0
    80003122:	40a00533          	neg	a0,a0
}
    80003126:	60e2                	ld	ra,24(sp)
    80003128:	6442                	ld	s0,16(sp)
    8000312a:	64a2                	ld	s1,8(sp)
    8000312c:	6902                	ld	s2,0(sp)
    8000312e:	6105                	addi	sp,sp,32
    80003130:	8082                	ret
    return -1;
    80003132:	557d                	li	a0,-1
    80003134:	bfcd                	j	80003126 <fetchaddr+0x3e>
    80003136:	557d                	li	a0,-1
    80003138:	b7fd                	j	80003126 <fetchaddr+0x3e>

000000008000313a <fetchstr>:
{
    8000313a:	7179                	addi	sp,sp,-48
    8000313c:	f406                	sd	ra,40(sp)
    8000313e:	f022                	sd	s0,32(sp)
    80003140:	ec26                	sd	s1,24(sp)
    80003142:	e84a                	sd	s2,16(sp)
    80003144:	e44e                	sd	s3,8(sp)
    80003146:	1800                	addi	s0,sp,48
    80003148:	892a                	mv	s2,a0
    8000314a:	84ae                	mv	s1,a1
    8000314c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000314e:	fffff097          	auipc	ra,0xfffff
    80003152:	aba080e7          	jalr	-1350(ra) # 80001c08 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80003156:	86ce                	mv	a3,s3
    80003158:	864a                	mv	a2,s2
    8000315a:	85a6                	mv	a1,s1
    8000315c:	6928                	ld	a0,80(a0)
    8000315e:	fffff097          	auipc	ra,0xfffff
    80003162:	880080e7          	jalr	-1920(ra) # 800019de <copyinstr>
    80003166:	00054e63          	bltz	a0,80003182 <fetchstr+0x48>
  return strlen(buf);
    8000316a:	8526                	mv	a0,s1
    8000316c:	ffffe097          	auipc	ra,0xffffe
    80003170:	e1a080e7          	jalr	-486(ra) # 80000f86 <strlen>
}
    80003174:	70a2                	ld	ra,40(sp)
    80003176:	7402                	ld	s0,32(sp)
    80003178:	64e2                	ld	s1,24(sp)
    8000317a:	6942                	ld	s2,16(sp)
    8000317c:	69a2                	ld	s3,8(sp)
    8000317e:	6145                	addi	sp,sp,48
    80003180:	8082                	ret
    return -1;
    80003182:	557d                	li	a0,-1
    80003184:	bfc5                	j	80003174 <fetchstr+0x3a>

0000000080003186 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80003186:	1101                	addi	sp,sp,-32
    80003188:	ec06                	sd	ra,24(sp)
    8000318a:	e822                	sd	s0,16(sp)
    8000318c:	e426                	sd	s1,8(sp)
    8000318e:	1000                	addi	s0,sp,32
    80003190:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003192:	00000097          	auipc	ra,0x0
    80003196:	eee080e7          	jalr	-274(ra) # 80003080 <argraw>
    8000319a:	c088                	sw	a0,0(s1)
}
    8000319c:	60e2                	ld	ra,24(sp)
    8000319e:	6442                	ld	s0,16(sp)
    800031a0:	64a2                	ld	s1,8(sp)
    800031a2:	6105                	addi	sp,sp,32
    800031a4:	8082                	ret

00000000800031a6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800031a6:	1101                	addi	sp,sp,-32
    800031a8:	ec06                	sd	ra,24(sp)
    800031aa:	e822                	sd	s0,16(sp)
    800031ac:	e426                	sd	s1,8(sp)
    800031ae:	1000                	addi	s0,sp,32
    800031b0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800031b2:	00000097          	auipc	ra,0x0
    800031b6:	ece080e7          	jalr	-306(ra) # 80003080 <argraw>
    800031ba:	e088                	sd	a0,0(s1)
}
    800031bc:	60e2                	ld	ra,24(sp)
    800031be:	6442                	ld	s0,16(sp)
    800031c0:	64a2                	ld	s1,8(sp)
    800031c2:	6105                	addi	sp,sp,32
    800031c4:	8082                	ret

00000000800031c6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800031c6:	7179                	addi	sp,sp,-48
    800031c8:	f406                	sd	ra,40(sp)
    800031ca:	f022                	sd	s0,32(sp)
    800031cc:	ec26                	sd	s1,24(sp)
    800031ce:	e84a                	sd	s2,16(sp)
    800031d0:	1800                	addi	s0,sp,48
    800031d2:	84ae                	mv	s1,a1
    800031d4:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800031d6:	fd840593          	addi	a1,s0,-40
    800031da:	00000097          	auipc	ra,0x0
    800031de:	fcc080e7          	jalr	-52(ra) # 800031a6 <argaddr>
  return fetchstr(addr, buf, max);
    800031e2:	864a                	mv	a2,s2
    800031e4:	85a6                	mv	a1,s1
    800031e6:	fd843503          	ld	a0,-40(s0)
    800031ea:	00000097          	auipc	ra,0x0
    800031ee:	f50080e7          	jalr	-176(ra) # 8000313a <fetchstr>
}
    800031f2:	70a2                	ld	ra,40(sp)
    800031f4:	7402                	ld	s0,32(sp)
    800031f6:	64e2                	ld	s1,24(sp)
    800031f8:	6942                	ld	s2,16(sp)
    800031fa:	6145                	addi	sp,sp,48
    800031fc:	8082                	ret

00000000800031fe <syscall>:
[SYS_setpriority] sys_setpriority,
};

void
syscall(void)
{
    800031fe:	1101                	addi	sp,sp,-32
    80003200:	ec06                	sd	ra,24(sp)
    80003202:	e822                	sd	s0,16(sp)
    80003204:	e426                	sd	s1,8(sp)
    80003206:	e04a                	sd	s2,0(sp)
    80003208:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000320a:	fffff097          	auipc	ra,0xfffff
    8000320e:	9fe080e7          	jalr	-1538(ra) # 80001c08 <myproc>
    80003212:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003214:	05853903          	ld	s2,88(a0)
    80003218:	0a893783          	ld	a5,168(s2)
    8000321c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003220:	37fd                	addiw	a5,a5,-1
    80003222:	475d                	li	a4,23
    80003224:	00f76f63          	bltu	a4,a5,80003242 <syscall+0x44>
    80003228:	00369713          	slli	a4,a3,0x3
    8000322c:	00005797          	auipc	a5,0x5
    80003230:	30478793          	addi	a5,a5,772 # 80008530 <syscalls>
    80003234:	97ba                	add	a5,a5,a4
    80003236:	639c                	ld	a5,0(a5)
    80003238:	c789                	beqz	a5,80003242 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000323a:	9782                	jalr	a5
    8000323c:	06a93823          	sd	a0,112(s2)
    80003240:	a839                	j	8000325e <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003242:	15848613          	addi	a2,s1,344
    80003246:	588c                	lw	a1,48(s1)
    80003248:	00005517          	auipc	a0,0x5
    8000324c:	2b050513          	addi	a0,a0,688 # 800084f8 <states.1769+0x158>
    80003250:	ffffd097          	auipc	ra,0xffffd
    80003254:	33e080e7          	jalr	830(ra) # 8000058e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003258:	6cbc                	ld	a5,88(s1)
    8000325a:	577d                	li	a4,-1
    8000325c:	fbb8                	sd	a4,112(a5)
  }
}
    8000325e:	60e2                	ld	ra,24(sp)
    80003260:	6442                	ld	s0,16(sp)
    80003262:	64a2                	ld	s1,8(sp)
    80003264:	6902                	ld	s2,0(sp)
    80003266:	6105                	addi	sp,sp,32
    80003268:	8082                	ret

000000008000326a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000326a:	1101                	addi	sp,sp,-32
    8000326c:	ec06                	sd	ra,24(sp)
    8000326e:	e822                	sd	s0,16(sp)
    80003270:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003272:	fec40593          	addi	a1,s0,-20
    80003276:	4501                	li	a0,0
    80003278:	00000097          	auipc	ra,0x0
    8000327c:	f0e080e7          	jalr	-242(ra) # 80003186 <argint>
  exit(n);
    80003280:	fec42503          	lw	a0,-20(s0)
    80003284:	fffff097          	auipc	ra,0xfffff
    80003288:	2f8080e7          	jalr	760(ra) # 8000257c <exit>
  return 0; // not reached
}
    8000328c:	4501                	li	a0,0
    8000328e:	60e2                	ld	ra,24(sp)
    80003290:	6442                	ld	s0,16(sp)
    80003292:	6105                	addi	sp,sp,32
    80003294:	8082                	ret

0000000080003296 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003296:	1141                	addi	sp,sp,-16
    80003298:	e406                	sd	ra,8(sp)
    8000329a:	e022                	sd	s0,0(sp)
    8000329c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000329e:	fffff097          	auipc	ra,0xfffff
    800032a2:	96a080e7          	jalr	-1686(ra) # 80001c08 <myproc>
}
    800032a6:	5908                	lw	a0,48(a0)
    800032a8:	60a2                	ld	ra,8(sp)
    800032aa:	6402                	ld	s0,0(sp)
    800032ac:	0141                	addi	sp,sp,16
    800032ae:	8082                	ret

00000000800032b0 <sys_fork>:

uint64
sys_fork(void)
{
    800032b0:	1141                	addi	sp,sp,-16
    800032b2:	e406                	sd	ra,8(sp)
    800032b4:	e022                	sd	s0,0(sp)
    800032b6:	0800                	addi	s0,sp,16
  return fork();
    800032b8:	fffff097          	auipc	ra,0xfffff
    800032bc:	d56080e7          	jalr	-682(ra) # 8000200e <fork>
}
    800032c0:	60a2                	ld	ra,8(sp)
    800032c2:	6402                	ld	s0,0(sp)
    800032c4:	0141                	addi	sp,sp,16
    800032c6:	8082                	ret

00000000800032c8 <sys_wait>:

uint64
sys_wait(void)
{
    800032c8:	1101                	addi	sp,sp,-32
    800032ca:	ec06                	sd	ra,24(sp)
    800032cc:	e822                	sd	s0,16(sp)
    800032ce:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800032d0:	fe840593          	addi	a1,s0,-24
    800032d4:	4501                	li	a0,0
    800032d6:	00000097          	auipc	ra,0x0
    800032da:	ed0080e7          	jalr	-304(ra) # 800031a6 <argaddr>
  return wait(p);
    800032de:	fe843503          	ld	a0,-24(s0)
    800032e2:	fffff097          	auipc	ra,0xfffff
    800032e6:	44c080e7          	jalr	1100(ra) # 8000272e <wait>
}
    800032ea:	60e2                	ld	ra,24(sp)
    800032ec:	6442                	ld	s0,16(sp)
    800032ee:	6105                	addi	sp,sp,32
    800032f0:	8082                	ret

00000000800032f2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800032f2:	7179                	addi	sp,sp,-48
    800032f4:	f406                	sd	ra,40(sp)
    800032f6:	f022                	sd	s0,32(sp)
    800032f8:	ec26                	sd	s1,24(sp)
    800032fa:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800032fc:	fdc40593          	addi	a1,s0,-36
    80003300:	4501                	li	a0,0
    80003302:	00000097          	auipc	ra,0x0
    80003306:	e84080e7          	jalr	-380(ra) # 80003186 <argint>
  addr = myproc()->sz;
    8000330a:	fffff097          	auipc	ra,0xfffff
    8000330e:	8fe080e7          	jalr	-1794(ra) # 80001c08 <myproc>
    80003312:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80003314:	fdc42503          	lw	a0,-36(s0)
    80003318:	fffff097          	auipc	ra,0xfffff
    8000331c:	c9a080e7          	jalr	-870(ra) # 80001fb2 <growproc>
    80003320:	00054863          	bltz	a0,80003330 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003324:	8526                	mv	a0,s1
    80003326:	70a2                	ld	ra,40(sp)
    80003328:	7402                	ld	s0,32(sp)
    8000332a:	64e2                	ld	s1,24(sp)
    8000332c:	6145                	addi	sp,sp,48
    8000332e:	8082                	ret
    return -1;
    80003330:	54fd                	li	s1,-1
    80003332:	bfcd                	j	80003324 <sys_sbrk+0x32>

0000000080003334 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003334:	7139                	addi	sp,sp,-64
    80003336:	fc06                	sd	ra,56(sp)
    80003338:	f822                	sd	s0,48(sp)
    8000333a:	f426                	sd	s1,40(sp)
    8000333c:	f04a                	sd	s2,32(sp)
    8000333e:	ec4e                	sd	s3,24(sp)
    80003340:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003342:	fcc40593          	addi	a1,s0,-52
    80003346:	4501                	li	a0,0
    80003348:	00000097          	auipc	ra,0x0
    8000334c:	e3e080e7          	jalr	-450(ra) # 80003186 <argint>
  acquire(&tickslock);
    80003350:	00234517          	auipc	a0,0x234
    80003354:	12850513          	addi	a0,a0,296 # 80237478 <tickslock>
    80003358:	ffffe097          	auipc	ra,0xffffe
    8000335c:	9ae080e7          	jalr	-1618(ra) # 80000d06 <acquire>
  ticks0 = ticks;
    80003360:	00005917          	auipc	s2,0x5
    80003364:	66092903          	lw	s2,1632(s2) # 800089c0 <ticks>
  while (ticks - ticks0 < n)
    80003368:	fcc42783          	lw	a5,-52(s0)
    8000336c:	cf9d                	beqz	a5,800033aa <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000336e:	00234997          	auipc	s3,0x234
    80003372:	10a98993          	addi	s3,s3,266 # 80237478 <tickslock>
    80003376:	00005497          	auipc	s1,0x5
    8000337a:	64a48493          	addi	s1,s1,1610 # 800089c0 <ticks>
    if (killed(myproc()))
    8000337e:	fffff097          	auipc	ra,0xfffff
    80003382:	88a080e7          	jalr	-1910(ra) # 80001c08 <myproc>
    80003386:	fffff097          	auipc	ra,0xfffff
    8000338a:	376080e7          	jalr	886(ra) # 800026fc <killed>
    8000338e:	ed15                	bnez	a0,800033ca <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003390:	85ce                	mv	a1,s3
    80003392:	8526                	mv	a0,s1
    80003394:	fffff097          	auipc	ra,0xfffff
    80003398:	0b4080e7          	jalr	180(ra) # 80002448 <sleep>
  while (ticks - ticks0 < n)
    8000339c:	409c                	lw	a5,0(s1)
    8000339e:	412787bb          	subw	a5,a5,s2
    800033a2:	fcc42703          	lw	a4,-52(s0)
    800033a6:	fce7ece3          	bltu	a5,a4,8000337e <sys_sleep+0x4a>
  }
  release(&tickslock);
    800033aa:	00234517          	auipc	a0,0x234
    800033ae:	0ce50513          	addi	a0,a0,206 # 80237478 <tickslock>
    800033b2:	ffffe097          	auipc	ra,0xffffe
    800033b6:	a08080e7          	jalr	-1528(ra) # 80000dba <release>
  return 0;
    800033ba:	4501                	li	a0,0
}
    800033bc:	70e2                	ld	ra,56(sp)
    800033be:	7442                	ld	s0,48(sp)
    800033c0:	74a2                	ld	s1,40(sp)
    800033c2:	7902                	ld	s2,32(sp)
    800033c4:	69e2                	ld	s3,24(sp)
    800033c6:	6121                	addi	sp,sp,64
    800033c8:	8082                	ret
      release(&tickslock);
    800033ca:	00234517          	auipc	a0,0x234
    800033ce:	0ae50513          	addi	a0,a0,174 # 80237478 <tickslock>
    800033d2:	ffffe097          	auipc	ra,0xffffe
    800033d6:	9e8080e7          	jalr	-1560(ra) # 80000dba <release>
      return -1;
    800033da:	557d                	li	a0,-1
    800033dc:	b7c5                	j	800033bc <sys_sleep+0x88>

00000000800033de <sys_kill>:

uint64
sys_kill(void)
{
    800033de:	1101                	addi	sp,sp,-32
    800033e0:	ec06                	sd	ra,24(sp)
    800033e2:	e822                	sd	s0,16(sp)
    800033e4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800033e6:	fec40593          	addi	a1,s0,-20
    800033ea:	4501                	li	a0,0
    800033ec:	00000097          	auipc	ra,0x0
    800033f0:	d9a080e7          	jalr	-614(ra) # 80003186 <argint>
  return kill(pid);
    800033f4:	fec42503          	lw	a0,-20(s0)
    800033f8:	fffff097          	auipc	ra,0xfffff
    800033fc:	266080e7          	jalr	614(ra) # 8000265e <kill>
}
    80003400:	60e2                	ld	ra,24(sp)
    80003402:	6442                	ld	s0,16(sp)
    80003404:	6105                	addi	sp,sp,32
    80003406:	8082                	ret

0000000080003408 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003408:	1101                	addi	sp,sp,-32
    8000340a:	ec06                	sd	ra,24(sp)
    8000340c:	e822                	sd	s0,16(sp)
    8000340e:	e426                	sd	s1,8(sp)
    80003410:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003412:	00234517          	auipc	a0,0x234
    80003416:	06650513          	addi	a0,a0,102 # 80237478 <tickslock>
    8000341a:	ffffe097          	auipc	ra,0xffffe
    8000341e:	8ec080e7          	jalr	-1812(ra) # 80000d06 <acquire>
  xticks = ticks;
    80003422:	00005497          	auipc	s1,0x5
    80003426:	59e4a483          	lw	s1,1438(s1) # 800089c0 <ticks>
  release(&tickslock);
    8000342a:	00234517          	auipc	a0,0x234
    8000342e:	04e50513          	addi	a0,a0,78 # 80237478 <tickslock>
    80003432:	ffffe097          	auipc	ra,0xffffe
    80003436:	988080e7          	jalr	-1656(ra) # 80000dba <release>
  return xticks;
}
    8000343a:	02049513          	slli	a0,s1,0x20
    8000343e:	9101                	srli	a0,a0,0x20
    80003440:	60e2                	ld	ra,24(sp)
    80003442:	6442                	ld	s0,16(sp)
    80003444:	64a2                	ld	s1,8(sp)
    80003446:	6105                	addi	sp,sp,32
    80003448:	8082                	ret

000000008000344a <sys_waitx>:

uint64
sys_waitx(void)
{
    8000344a:	7139                	addi	sp,sp,-64
    8000344c:	fc06                	sd	ra,56(sp)
    8000344e:	f822                	sd	s0,48(sp)
    80003450:	f426                	sd	s1,40(sp)
    80003452:	f04a                	sd	s2,32(sp)
    80003454:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003456:	fd840593          	addi	a1,s0,-40
    8000345a:	4501                	li	a0,0
    8000345c:	00000097          	auipc	ra,0x0
    80003460:	d4a080e7          	jalr	-694(ra) # 800031a6 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003464:	fd040593          	addi	a1,s0,-48
    80003468:	4505                	li	a0,1
    8000346a:	00000097          	auipc	ra,0x0
    8000346e:	d3c080e7          	jalr	-708(ra) # 800031a6 <argaddr>
  argaddr(2, &addr2);
    80003472:	fc840593          	addi	a1,s0,-56
    80003476:	4509                	li	a0,2
    80003478:	00000097          	auipc	ra,0x0
    8000347c:	d2e080e7          	jalr	-722(ra) # 800031a6 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003480:	fc040613          	addi	a2,s0,-64
    80003484:	fc440593          	addi	a1,s0,-60
    80003488:	fd843503          	ld	a0,-40(s0)
    8000348c:	fffff097          	auipc	ra,0xfffff
    80003490:	52a080e7          	jalr	1322(ra) # 800029b6 <waitx>
    80003494:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003496:	ffffe097          	auipc	ra,0xffffe
    8000349a:	772080e7          	jalr	1906(ra) # 80001c08 <myproc>
    8000349e:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800034a0:	4691                	li	a3,4
    800034a2:	fc440613          	addi	a2,s0,-60
    800034a6:	fd043583          	ld	a1,-48(s0)
    800034aa:	6928                	ld	a0,80(a0)
    800034ac:	ffffe097          	auipc	ra,0xffffe
    800034b0:	3e2080e7          	jalr	994(ra) # 8000188e <copyout>
    return -1;
    800034b4:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    800034b6:	00054f63          	bltz	a0,800034d4 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    800034ba:	4691                	li	a3,4
    800034bc:	fc040613          	addi	a2,s0,-64
    800034c0:	fc843583          	ld	a1,-56(s0)
    800034c4:	68a8                	ld	a0,80(s1)
    800034c6:	ffffe097          	auipc	ra,0xffffe
    800034ca:	3c8080e7          	jalr	968(ra) # 8000188e <copyout>
    800034ce:	00054a63          	bltz	a0,800034e2 <sys_waitx+0x98>
    return -1;
  return ret;
    800034d2:	87ca                	mv	a5,s2
}
    800034d4:	853e                	mv	a0,a5
    800034d6:	70e2                	ld	ra,56(sp)
    800034d8:	7442                	ld	s0,48(sp)
    800034da:	74a2                	ld	s1,40(sp)
    800034dc:	7902                	ld	s2,32(sp)
    800034de:	6121                	addi	sp,sp,64
    800034e0:	8082                	ret
    return -1;
    800034e2:	57fd                	li	a5,-1
    800034e4:	bfc5                	j	800034d4 <sys_waitx+0x8a>

00000000800034e6 <smax>:

// for PBS
int smax(int a, int b)
{
    800034e6:	1141                	addi	sp,sp,-16
    800034e8:	e422                	sd	s0,8(sp)
    800034ea:	0800                	addi	s0,sp,16
  if (a > b)
    800034ec:	87aa                	mv	a5,a0
    800034ee:	00b55363          	bge	a0,a1,800034f4 <smax+0xe>
    800034f2:	87ae                	mv	a5,a1
    return a;
  return b;
}
    800034f4:	0007851b          	sext.w	a0,a5
    800034f8:	6422                	ld	s0,8(sp)
    800034fa:	0141                	addi	sp,sp,16
    800034fc:	8082                	ret

00000000800034fe <smin>:

int smin(int a, int b)
{
    800034fe:	1141                	addi	sp,sp,-16
    80003500:	e422                	sd	s0,8(sp)
    80003502:	0800                	addi	s0,sp,16
  if (a < b)
    80003504:	87aa                	mv	a5,a0
    80003506:	00a5d363          	bge	a1,a0,8000350c <smin+0xe>
    8000350a:	87ae                	mv	a5,a1
    return a;
  return b;
}
    8000350c:	0007851b          	sext.w	a0,a5
    80003510:	6422                	ld	s0,8(sp)
    80003512:	0141                	addi	sp,sp,16
    80003514:	8082                	ret

0000000080003516 <sdp_priority>:

int sdp_priority(struct proc *p)
{
    80003516:	1141                	addi	sp,sp,-16
    80003518:	e422                	sd	s0,8(sp)
    8000351a:	0800                	addi	s0,sp,16
  int sp = p->pbs_static_priority;
  int rtime = p->pbs_rtime;
    8000351c:	18052703          	lw	a4,384(a0)
  int wtime = p->pbs_wtime;
    80003520:	18452683          	lw	a3,388(a0)
  int stime = p->pbs_stime;
    80003524:	18852603          	lw	a2,392(a0)

  int temp = (3 * rtime - wtime - stime) * 50;
    80003528:	0017179b          	slliw	a5,a4,0x1
    8000352c:	9fb9                	addw	a5,a5,a4
    8000352e:	9f95                	subw	a5,a5,a3
    80003530:	9f91                	subw	a5,a5,a2
    80003532:	03200593          	li	a1,50
    80003536:	02b787bb          	mulw	a5,a5,a1
  int temp1 = 1 + rtime + stime + wtime;
    8000353a:	2705                	addiw	a4,a4,1
    8000353c:	9f31                	addw	a4,a4,a2
    8000353e:	9f35                	addw	a4,a4,a3
  int temp2 = (int)temp / temp1;
    80003540:	02e7c7bb          	divw	a5,a5,a4
    80003544:	0007871b          	sext.w	a4,a5
    80003548:	fff74713          	not	a4,a4
    8000354c:	977d                	srai	a4,a4,0x3f
    8000354e:	8ff9                	and	a5,a5,a4
    80003550:	0007869b          	sext.w	a3,a5

  int rbi = smax(0, temp2);
  int dp = smin(100, sp + rbi);
    80003554:	17452703          	lw	a4,372(a0)
    80003558:	9fb9                	addw	a5,a5,a4
    8000355a:	0007861b          	sext.w	a2,a5
    8000355e:	06400713          	li	a4,100
    80003562:	00c75463          	bge	a4,a2,8000356a <sdp_priority+0x54>
    80003566:	06400793          	li	a5,100

  p->pbs_rbi = rbi;
    8000356a:	16d52e23          	sw	a3,380(a0)
  p->pbs_dynamic_priority = dp;
    8000356e:	16f52c23          	sw	a5,376(a0)

  return dp;
}
    80003572:	0007851b          	sext.w	a0,a5
    80003576:	6422                	ld	s0,8(sp)
    80003578:	0141                	addi	sp,sp,16
    8000357a:	8082                	ret

000000008000357c <sys_setpriority>:


uint64
sys_setpriority(void)
{
    8000357c:	7179                	addi	sp,sp,-48
    8000357e:	f406                	sd	ra,40(sp)
    80003580:	f022                	sd	s0,32(sp)
    80003582:	ec26                	sd	s1,24(sp)
    80003584:	e84a                	sd	s2,16(sp)
    80003586:	1800                	addi	s0,sp,48
  int pid, priority;
  argint(0, &pid);
    80003588:	fdc40593          	addi	a1,s0,-36
    8000358c:	4501                	li	a0,0
    8000358e:	00000097          	auipc	ra,0x0
    80003592:	bf8080e7          	jalr	-1032(ra) # 80003186 <argint>
  argint(1, &priority);
    80003596:	fd840593          	addi	a1,s0,-40
    8000359a:	4505                	li	a0,1
    8000359c:	00000097          	auipc	ra,0x0
    800035a0:	bea080e7          	jalr	-1046(ra) # 80003186 <argint>
  int old_static_priority = setpriority(pid, priority);
    800035a4:	fd842583          	lw	a1,-40(s0)
    800035a8:	fdc42503          	lw	a0,-36(s0)
    800035ac:	fffff097          	auipc	ra,0xfffff
    800035b0:	5e8080e7          	jalr	1512(ra) # 80002b94 <setpriority>
    800035b4:	84aa                	mv	s1,a0

  if (old_static_priority != -1) 
    800035b6:	57fd                	li	a5,-1
    800035b8:	04f50563          	beq	a0,a5,80003602 <sys_setpriority+0x86>
  {
    int old_dynamic_priority = -1;
    int new_dynamic_priority = -1;
    for (int i = 0; i < NPROC; i++)
    {
      if (proc[i].pid == pid)
    800035bc:	fdc42603          	lw	a2,-36(s0)
    800035c0:	0022e717          	auipc	a4,0x22e
    800035c4:	ae870713          	addi	a4,a4,-1304 # 802310a8 <proc+0x30>
    for (int i = 0; i < NPROC; i++)
    800035c8:	4781                	li	a5,0
    800035ca:	04000593          	li	a1,64
      if (proc[i].pid == pid)
    800035ce:	4314                	lw	a3,0(a4)
    800035d0:	00c68863          	beq	a3,a2,800035e0 <sys_setpriority+0x64>
    for (int i = 0; i < NPROC; i++)
    800035d4:	2785                	addiw	a5,a5,1
    800035d6:	19070713          	addi	a4,a4,400
    800035da:	feb79ae3          	bne	a5,a1,800035ce <sys_setpriority+0x52>
    800035de:	a015                	j	80003602 <sys_setpriority+0x86>
      {
        old_dynamic_priority = proc[i].pbs_dynamic_priority;
    800035e0:	19000513          	li	a0,400
    800035e4:	02a787b3          	mul	a5,a5,a0
    800035e8:	0022e517          	auipc	a0,0x22e
    800035ec:	a9050513          	addi	a0,a0,-1392 # 80231078 <proc>
    800035f0:	953e                	add	a0,a0,a5
    800035f2:	17852903          	lw	s2,376(a0)
        // printf("old_dynamic_priority: %d\n", old_dynamic_priority);
        new_dynamic_priority = sdp_priority(&proc[i]);
    800035f6:	00000097          	auipc	ra,0x0
    800035fa:	f20080e7          	jalr	-224(ra) # 80003516 <sdp_priority>
        // printf("new_dynamic_priority: %d\n", new_dynamic_priority);
        break;
      }
    }

    if (new_dynamic_priority < old_dynamic_priority)
    800035fe:	01254963          	blt	a0,s2,80003610 <sys_setpriority+0x94>
      yield();

  }

  return old_static_priority;
}
    80003602:	8526                	mv	a0,s1
    80003604:	70a2                	ld	ra,40(sp)
    80003606:	7402                	ld	s0,32(sp)
    80003608:	64e2                	ld	s1,24(sp)
    8000360a:	6942                	ld	s2,16(sp)
    8000360c:	6145                	addi	sp,sp,48
    8000360e:	8082                	ret
      yield();
    80003610:	fffff097          	auipc	ra,0xfffff
    80003614:	dfc080e7          	jalr	-516(ra) # 8000240c <yield>
    80003618:	b7ed                	j	80003602 <sys_setpriority+0x86>

000000008000361a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000361a:	7179                	addi	sp,sp,-48
    8000361c:	f406                	sd	ra,40(sp)
    8000361e:	f022                	sd	s0,32(sp)
    80003620:	ec26                	sd	s1,24(sp)
    80003622:	e84a                	sd	s2,16(sp)
    80003624:	e44e                	sd	s3,8(sp)
    80003626:	e052                	sd	s4,0(sp)
    80003628:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000362a:	00005597          	auipc	a1,0x5
    8000362e:	fce58593          	addi	a1,a1,-50 # 800085f8 <syscalls+0xc8>
    80003632:	00234517          	auipc	a0,0x234
    80003636:	e5e50513          	addi	a0,a0,-418 # 80237490 <bcache>
    8000363a:	ffffd097          	auipc	ra,0xffffd
    8000363e:	63c080e7          	jalr	1596(ra) # 80000c76 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003642:	0023c797          	auipc	a5,0x23c
    80003646:	e4e78793          	addi	a5,a5,-434 # 8023f490 <bcache+0x8000>
    8000364a:	0023c717          	auipc	a4,0x23c
    8000364e:	0ae70713          	addi	a4,a4,174 # 8023f6f8 <bcache+0x8268>
    80003652:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003656:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000365a:	00234497          	auipc	s1,0x234
    8000365e:	e4e48493          	addi	s1,s1,-434 # 802374a8 <bcache+0x18>
    b->next = bcache.head.next;
    80003662:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003664:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003666:	00005a17          	auipc	s4,0x5
    8000366a:	f9aa0a13          	addi	s4,s4,-102 # 80008600 <syscalls+0xd0>
    b->next = bcache.head.next;
    8000366e:	2b893783          	ld	a5,696(s2)
    80003672:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003674:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003678:	85d2                	mv	a1,s4
    8000367a:	01048513          	addi	a0,s1,16
    8000367e:	00001097          	auipc	ra,0x1
    80003682:	4c4080e7          	jalr	1220(ra) # 80004b42 <initsleeplock>
    bcache.head.next->prev = b;
    80003686:	2b893783          	ld	a5,696(s2)
    8000368a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000368c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003690:	45848493          	addi	s1,s1,1112
    80003694:	fd349de3          	bne	s1,s3,8000366e <binit+0x54>
  }
}
    80003698:	70a2                	ld	ra,40(sp)
    8000369a:	7402                	ld	s0,32(sp)
    8000369c:	64e2                	ld	s1,24(sp)
    8000369e:	6942                	ld	s2,16(sp)
    800036a0:	69a2                	ld	s3,8(sp)
    800036a2:	6a02                	ld	s4,0(sp)
    800036a4:	6145                	addi	sp,sp,48
    800036a6:	8082                	ret

00000000800036a8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800036a8:	7179                	addi	sp,sp,-48
    800036aa:	f406                	sd	ra,40(sp)
    800036ac:	f022                	sd	s0,32(sp)
    800036ae:	ec26                	sd	s1,24(sp)
    800036b0:	e84a                	sd	s2,16(sp)
    800036b2:	e44e                	sd	s3,8(sp)
    800036b4:	1800                	addi	s0,sp,48
    800036b6:	89aa                	mv	s3,a0
    800036b8:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800036ba:	00234517          	auipc	a0,0x234
    800036be:	dd650513          	addi	a0,a0,-554 # 80237490 <bcache>
    800036c2:	ffffd097          	auipc	ra,0xffffd
    800036c6:	644080e7          	jalr	1604(ra) # 80000d06 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800036ca:	0023c497          	auipc	s1,0x23c
    800036ce:	07e4b483          	ld	s1,126(s1) # 8023f748 <bcache+0x82b8>
    800036d2:	0023c797          	auipc	a5,0x23c
    800036d6:	02678793          	addi	a5,a5,38 # 8023f6f8 <bcache+0x8268>
    800036da:	02f48f63          	beq	s1,a5,80003718 <bread+0x70>
    800036de:	873e                	mv	a4,a5
    800036e0:	a021                	j	800036e8 <bread+0x40>
    800036e2:	68a4                	ld	s1,80(s1)
    800036e4:	02e48a63          	beq	s1,a4,80003718 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800036e8:	449c                	lw	a5,8(s1)
    800036ea:	ff379ce3          	bne	a5,s3,800036e2 <bread+0x3a>
    800036ee:	44dc                	lw	a5,12(s1)
    800036f0:	ff2799e3          	bne	a5,s2,800036e2 <bread+0x3a>
      b->refcnt++;
    800036f4:	40bc                	lw	a5,64(s1)
    800036f6:	2785                	addiw	a5,a5,1
    800036f8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036fa:	00234517          	auipc	a0,0x234
    800036fe:	d9650513          	addi	a0,a0,-618 # 80237490 <bcache>
    80003702:	ffffd097          	auipc	ra,0xffffd
    80003706:	6b8080e7          	jalr	1720(ra) # 80000dba <release>
      acquiresleep(&b->lock);
    8000370a:	01048513          	addi	a0,s1,16
    8000370e:	00001097          	auipc	ra,0x1
    80003712:	46e080e7          	jalr	1134(ra) # 80004b7c <acquiresleep>
      return b;
    80003716:	a8b9                	j	80003774 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003718:	0023c497          	auipc	s1,0x23c
    8000371c:	0284b483          	ld	s1,40(s1) # 8023f740 <bcache+0x82b0>
    80003720:	0023c797          	auipc	a5,0x23c
    80003724:	fd878793          	addi	a5,a5,-40 # 8023f6f8 <bcache+0x8268>
    80003728:	00f48863          	beq	s1,a5,80003738 <bread+0x90>
    8000372c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000372e:	40bc                	lw	a5,64(s1)
    80003730:	cf81                	beqz	a5,80003748 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003732:	64a4                	ld	s1,72(s1)
    80003734:	fee49de3          	bne	s1,a4,8000372e <bread+0x86>
  panic("bget: no buffers");
    80003738:	00005517          	auipc	a0,0x5
    8000373c:	ed050513          	addi	a0,a0,-304 # 80008608 <syscalls+0xd8>
    80003740:	ffffd097          	auipc	ra,0xffffd
    80003744:	e04080e7          	jalr	-508(ra) # 80000544 <panic>
      b->dev = dev;
    80003748:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000374c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003750:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003754:	4785                	li	a5,1
    80003756:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003758:	00234517          	auipc	a0,0x234
    8000375c:	d3850513          	addi	a0,a0,-712 # 80237490 <bcache>
    80003760:	ffffd097          	auipc	ra,0xffffd
    80003764:	65a080e7          	jalr	1626(ra) # 80000dba <release>
      acquiresleep(&b->lock);
    80003768:	01048513          	addi	a0,s1,16
    8000376c:	00001097          	auipc	ra,0x1
    80003770:	410080e7          	jalr	1040(ra) # 80004b7c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003774:	409c                	lw	a5,0(s1)
    80003776:	cb89                	beqz	a5,80003788 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003778:	8526                	mv	a0,s1
    8000377a:	70a2                	ld	ra,40(sp)
    8000377c:	7402                	ld	s0,32(sp)
    8000377e:	64e2                	ld	s1,24(sp)
    80003780:	6942                	ld	s2,16(sp)
    80003782:	69a2                	ld	s3,8(sp)
    80003784:	6145                	addi	sp,sp,48
    80003786:	8082                	ret
    virtio_disk_rw(b, 0);
    80003788:	4581                	li	a1,0
    8000378a:	8526                	mv	a0,s1
    8000378c:	00003097          	auipc	ra,0x3
    80003790:	fec080e7          	jalr	-20(ra) # 80006778 <virtio_disk_rw>
    b->valid = 1;
    80003794:	4785                	li	a5,1
    80003796:	c09c                	sw	a5,0(s1)
  return b;
    80003798:	b7c5                	j	80003778 <bread+0xd0>

000000008000379a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000379a:	1101                	addi	sp,sp,-32
    8000379c:	ec06                	sd	ra,24(sp)
    8000379e:	e822                	sd	s0,16(sp)
    800037a0:	e426                	sd	s1,8(sp)
    800037a2:	1000                	addi	s0,sp,32
    800037a4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800037a6:	0541                	addi	a0,a0,16
    800037a8:	00001097          	auipc	ra,0x1
    800037ac:	46e080e7          	jalr	1134(ra) # 80004c16 <holdingsleep>
    800037b0:	cd01                	beqz	a0,800037c8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800037b2:	4585                	li	a1,1
    800037b4:	8526                	mv	a0,s1
    800037b6:	00003097          	auipc	ra,0x3
    800037ba:	fc2080e7          	jalr	-62(ra) # 80006778 <virtio_disk_rw>
}
    800037be:	60e2                	ld	ra,24(sp)
    800037c0:	6442                	ld	s0,16(sp)
    800037c2:	64a2                	ld	s1,8(sp)
    800037c4:	6105                	addi	sp,sp,32
    800037c6:	8082                	ret
    panic("bwrite");
    800037c8:	00005517          	auipc	a0,0x5
    800037cc:	e5850513          	addi	a0,a0,-424 # 80008620 <syscalls+0xf0>
    800037d0:	ffffd097          	auipc	ra,0xffffd
    800037d4:	d74080e7          	jalr	-652(ra) # 80000544 <panic>

00000000800037d8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800037d8:	1101                	addi	sp,sp,-32
    800037da:	ec06                	sd	ra,24(sp)
    800037dc:	e822                	sd	s0,16(sp)
    800037de:	e426                	sd	s1,8(sp)
    800037e0:	e04a                	sd	s2,0(sp)
    800037e2:	1000                	addi	s0,sp,32
    800037e4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800037e6:	01050913          	addi	s2,a0,16
    800037ea:	854a                	mv	a0,s2
    800037ec:	00001097          	auipc	ra,0x1
    800037f0:	42a080e7          	jalr	1066(ra) # 80004c16 <holdingsleep>
    800037f4:	c92d                	beqz	a0,80003866 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800037f6:	854a                	mv	a0,s2
    800037f8:	00001097          	auipc	ra,0x1
    800037fc:	3da080e7          	jalr	986(ra) # 80004bd2 <releasesleep>

  acquire(&bcache.lock);
    80003800:	00234517          	auipc	a0,0x234
    80003804:	c9050513          	addi	a0,a0,-880 # 80237490 <bcache>
    80003808:	ffffd097          	auipc	ra,0xffffd
    8000380c:	4fe080e7          	jalr	1278(ra) # 80000d06 <acquire>
  b->refcnt--;
    80003810:	40bc                	lw	a5,64(s1)
    80003812:	37fd                	addiw	a5,a5,-1
    80003814:	0007871b          	sext.w	a4,a5
    80003818:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000381a:	eb05                	bnez	a4,8000384a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000381c:	68bc                	ld	a5,80(s1)
    8000381e:	64b8                	ld	a4,72(s1)
    80003820:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003822:	64bc                	ld	a5,72(s1)
    80003824:	68b8                	ld	a4,80(s1)
    80003826:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003828:	0023c797          	auipc	a5,0x23c
    8000382c:	c6878793          	addi	a5,a5,-920 # 8023f490 <bcache+0x8000>
    80003830:	2b87b703          	ld	a4,696(a5)
    80003834:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003836:	0023c717          	auipc	a4,0x23c
    8000383a:	ec270713          	addi	a4,a4,-318 # 8023f6f8 <bcache+0x8268>
    8000383e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003840:	2b87b703          	ld	a4,696(a5)
    80003844:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003846:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000384a:	00234517          	auipc	a0,0x234
    8000384e:	c4650513          	addi	a0,a0,-954 # 80237490 <bcache>
    80003852:	ffffd097          	auipc	ra,0xffffd
    80003856:	568080e7          	jalr	1384(ra) # 80000dba <release>
}
    8000385a:	60e2                	ld	ra,24(sp)
    8000385c:	6442                	ld	s0,16(sp)
    8000385e:	64a2                	ld	s1,8(sp)
    80003860:	6902                	ld	s2,0(sp)
    80003862:	6105                	addi	sp,sp,32
    80003864:	8082                	ret
    panic("brelse");
    80003866:	00005517          	auipc	a0,0x5
    8000386a:	dc250513          	addi	a0,a0,-574 # 80008628 <syscalls+0xf8>
    8000386e:	ffffd097          	auipc	ra,0xffffd
    80003872:	cd6080e7          	jalr	-810(ra) # 80000544 <panic>

0000000080003876 <bpin>:

void
bpin(struct buf *b) {
    80003876:	1101                	addi	sp,sp,-32
    80003878:	ec06                	sd	ra,24(sp)
    8000387a:	e822                	sd	s0,16(sp)
    8000387c:	e426                	sd	s1,8(sp)
    8000387e:	1000                	addi	s0,sp,32
    80003880:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003882:	00234517          	auipc	a0,0x234
    80003886:	c0e50513          	addi	a0,a0,-1010 # 80237490 <bcache>
    8000388a:	ffffd097          	auipc	ra,0xffffd
    8000388e:	47c080e7          	jalr	1148(ra) # 80000d06 <acquire>
  b->refcnt++;
    80003892:	40bc                	lw	a5,64(s1)
    80003894:	2785                	addiw	a5,a5,1
    80003896:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003898:	00234517          	auipc	a0,0x234
    8000389c:	bf850513          	addi	a0,a0,-1032 # 80237490 <bcache>
    800038a0:	ffffd097          	auipc	ra,0xffffd
    800038a4:	51a080e7          	jalr	1306(ra) # 80000dba <release>
}
    800038a8:	60e2                	ld	ra,24(sp)
    800038aa:	6442                	ld	s0,16(sp)
    800038ac:	64a2                	ld	s1,8(sp)
    800038ae:	6105                	addi	sp,sp,32
    800038b0:	8082                	ret

00000000800038b2 <bunpin>:

void
bunpin(struct buf *b) {
    800038b2:	1101                	addi	sp,sp,-32
    800038b4:	ec06                	sd	ra,24(sp)
    800038b6:	e822                	sd	s0,16(sp)
    800038b8:	e426                	sd	s1,8(sp)
    800038ba:	1000                	addi	s0,sp,32
    800038bc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800038be:	00234517          	auipc	a0,0x234
    800038c2:	bd250513          	addi	a0,a0,-1070 # 80237490 <bcache>
    800038c6:	ffffd097          	auipc	ra,0xffffd
    800038ca:	440080e7          	jalr	1088(ra) # 80000d06 <acquire>
  b->refcnt--;
    800038ce:	40bc                	lw	a5,64(s1)
    800038d0:	37fd                	addiw	a5,a5,-1
    800038d2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038d4:	00234517          	auipc	a0,0x234
    800038d8:	bbc50513          	addi	a0,a0,-1092 # 80237490 <bcache>
    800038dc:	ffffd097          	auipc	ra,0xffffd
    800038e0:	4de080e7          	jalr	1246(ra) # 80000dba <release>
}
    800038e4:	60e2                	ld	ra,24(sp)
    800038e6:	6442                	ld	s0,16(sp)
    800038e8:	64a2                	ld	s1,8(sp)
    800038ea:	6105                	addi	sp,sp,32
    800038ec:	8082                	ret

00000000800038ee <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800038ee:	1101                	addi	sp,sp,-32
    800038f0:	ec06                	sd	ra,24(sp)
    800038f2:	e822                	sd	s0,16(sp)
    800038f4:	e426                	sd	s1,8(sp)
    800038f6:	e04a                	sd	s2,0(sp)
    800038f8:	1000                	addi	s0,sp,32
    800038fa:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800038fc:	00d5d59b          	srliw	a1,a1,0xd
    80003900:	0023c797          	auipc	a5,0x23c
    80003904:	26c7a783          	lw	a5,620(a5) # 8023fb6c <sb+0x1c>
    80003908:	9dbd                	addw	a1,a1,a5
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	d9e080e7          	jalr	-610(ra) # 800036a8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003912:	0074f713          	andi	a4,s1,7
    80003916:	4785                	li	a5,1
    80003918:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000391c:	14ce                	slli	s1,s1,0x33
    8000391e:	90d9                	srli	s1,s1,0x36
    80003920:	00950733          	add	a4,a0,s1
    80003924:	05874703          	lbu	a4,88(a4)
    80003928:	00e7f6b3          	and	a3,a5,a4
    8000392c:	c69d                	beqz	a3,8000395a <bfree+0x6c>
    8000392e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003930:	94aa                	add	s1,s1,a0
    80003932:	fff7c793          	not	a5,a5
    80003936:	8ff9                	and	a5,a5,a4
    80003938:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000393c:	00001097          	auipc	ra,0x1
    80003940:	120080e7          	jalr	288(ra) # 80004a5c <log_write>
  brelse(bp);
    80003944:	854a                	mv	a0,s2
    80003946:	00000097          	auipc	ra,0x0
    8000394a:	e92080e7          	jalr	-366(ra) # 800037d8 <brelse>
}
    8000394e:	60e2                	ld	ra,24(sp)
    80003950:	6442                	ld	s0,16(sp)
    80003952:	64a2                	ld	s1,8(sp)
    80003954:	6902                	ld	s2,0(sp)
    80003956:	6105                	addi	sp,sp,32
    80003958:	8082                	ret
    panic("freeing free block");
    8000395a:	00005517          	auipc	a0,0x5
    8000395e:	cd650513          	addi	a0,a0,-810 # 80008630 <syscalls+0x100>
    80003962:	ffffd097          	auipc	ra,0xffffd
    80003966:	be2080e7          	jalr	-1054(ra) # 80000544 <panic>

000000008000396a <balloc>:
{
    8000396a:	711d                	addi	sp,sp,-96
    8000396c:	ec86                	sd	ra,88(sp)
    8000396e:	e8a2                	sd	s0,80(sp)
    80003970:	e4a6                	sd	s1,72(sp)
    80003972:	e0ca                	sd	s2,64(sp)
    80003974:	fc4e                	sd	s3,56(sp)
    80003976:	f852                	sd	s4,48(sp)
    80003978:	f456                	sd	s5,40(sp)
    8000397a:	f05a                	sd	s6,32(sp)
    8000397c:	ec5e                	sd	s7,24(sp)
    8000397e:	e862                	sd	s8,16(sp)
    80003980:	e466                	sd	s9,8(sp)
    80003982:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003984:	0023c797          	auipc	a5,0x23c
    80003988:	1d07a783          	lw	a5,464(a5) # 8023fb54 <sb+0x4>
    8000398c:	10078163          	beqz	a5,80003a8e <balloc+0x124>
    80003990:	8baa                	mv	s7,a0
    80003992:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003994:	0023cb17          	auipc	s6,0x23c
    80003998:	1bcb0b13          	addi	s6,s6,444 # 8023fb50 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000399c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000399e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039a0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800039a2:	6c89                	lui	s9,0x2
    800039a4:	a061                	j	80003a2c <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800039a6:	974a                	add	a4,a4,s2
    800039a8:	8fd5                	or	a5,a5,a3
    800039aa:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800039ae:	854a                	mv	a0,s2
    800039b0:	00001097          	auipc	ra,0x1
    800039b4:	0ac080e7          	jalr	172(ra) # 80004a5c <log_write>
        brelse(bp);
    800039b8:	854a                	mv	a0,s2
    800039ba:	00000097          	auipc	ra,0x0
    800039be:	e1e080e7          	jalr	-482(ra) # 800037d8 <brelse>
  bp = bread(dev, bno);
    800039c2:	85a6                	mv	a1,s1
    800039c4:	855e                	mv	a0,s7
    800039c6:	00000097          	auipc	ra,0x0
    800039ca:	ce2080e7          	jalr	-798(ra) # 800036a8 <bread>
    800039ce:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800039d0:	40000613          	li	a2,1024
    800039d4:	4581                	li	a1,0
    800039d6:	05850513          	addi	a0,a0,88
    800039da:	ffffd097          	auipc	ra,0xffffd
    800039de:	428080e7          	jalr	1064(ra) # 80000e02 <memset>
  log_write(bp);
    800039e2:	854a                	mv	a0,s2
    800039e4:	00001097          	auipc	ra,0x1
    800039e8:	078080e7          	jalr	120(ra) # 80004a5c <log_write>
  brelse(bp);
    800039ec:	854a                	mv	a0,s2
    800039ee:	00000097          	auipc	ra,0x0
    800039f2:	dea080e7          	jalr	-534(ra) # 800037d8 <brelse>
}
    800039f6:	8526                	mv	a0,s1
    800039f8:	60e6                	ld	ra,88(sp)
    800039fa:	6446                	ld	s0,80(sp)
    800039fc:	64a6                	ld	s1,72(sp)
    800039fe:	6906                	ld	s2,64(sp)
    80003a00:	79e2                	ld	s3,56(sp)
    80003a02:	7a42                	ld	s4,48(sp)
    80003a04:	7aa2                	ld	s5,40(sp)
    80003a06:	7b02                	ld	s6,32(sp)
    80003a08:	6be2                	ld	s7,24(sp)
    80003a0a:	6c42                	ld	s8,16(sp)
    80003a0c:	6ca2                	ld	s9,8(sp)
    80003a0e:	6125                	addi	sp,sp,96
    80003a10:	8082                	ret
    brelse(bp);
    80003a12:	854a                	mv	a0,s2
    80003a14:	00000097          	auipc	ra,0x0
    80003a18:	dc4080e7          	jalr	-572(ra) # 800037d8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003a1c:	015c87bb          	addw	a5,s9,s5
    80003a20:	00078a9b          	sext.w	s5,a5
    80003a24:	004b2703          	lw	a4,4(s6)
    80003a28:	06eaf363          	bgeu	s5,a4,80003a8e <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003a2c:	41fad79b          	sraiw	a5,s5,0x1f
    80003a30:	0137d79b          	srliw	a5,a5,0x13
    80003a34:	015787bb          	addw	a5,a5,s5
    80003a38:	40d7d79b          	sraiw	a5,a5,0xd
    80003a3c:	01cb2583          	lw	a1,28(s6)
    80003a40:	9dbd                	addw	a1,a1,a5
    80003a42:	855e                	mv	a0,s7
    80003a44:	00000097          	auipc	ra,0x0
    80003a48:	c64080e7          	jalr	-924(ra) # 800036a8 <bread>
    80003a4c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a4e:	004b2503          	lw	a0,4(s6)
    80003a52:	000a849b          	sext.w	s1,s5
    80003a56:	8662                	mv	a2,s8
    80003a58:	faa4fde3          	bgeu	s1,a0,80003a12 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003a5c:	41f6579b          	sraiw	a5,a2,0x1f
    80003a60:	01d7d69b          	srliw	a3,a5,0x1d
    80003a64:	00c6873b          	addw	a4,a3,a2
    80003a68:	00777793          	andi	a5,a4,7
    80003a6c:	9f95                	subw	a5,a5,a3
    80003a6e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003a72:	4037571b          	sraiw	a4,a4,0x3
    80003a76:	00e906b3          	add	a3,s2,a4
    80003a7a:	0586c683          	lbu	a3,88(a3)
    80003a7e:	00d7f5b3          	and	a1,a5,a3
    80003a82:	d195                	beqz	a1,800039a6 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a84:	2605                	addiw	a2,a2,1
    80003a86:	2485                	addiw	s1,s1,1
    80003a88:	fd4618e3          	bne	a2,s4,80003a58 <balloc+0xee>
    80003a8c:	b759                	j	80003a12 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003a8e:	00005517          	auipc	a0,0x5
    80003a92:	bba50513          	addi	a0,a0,-1094 # 80008648 <syscalls+0x118>
    80003a96:	ffffd097          	auipc	ra,0xffffd
    80003a9a:	af8080e7          	jalr	-1288(ra) # 8000058e <printf>
  return 0;
    80003a9e:	4481                	li	s1,0
    80003aa0:	bf99                	j	800039f6 <balloc+0x8c>

0000000080003aa2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003aa2:	7179                	addi	sp,sp,-48
    80003aa4:	f406                	sd	ra,40(sp)
    80003aa6:	f022                	sd	s0,32(sp)
    80003aa8:	ec26                	sd	s1,24(sp)
    80003aaa:	e84a                	sd	s2,16(sp)
    80003aac:	e44e                	sd	s3,8(sp)
    80003aae:	e052                	sd	s4,0(sp)
    80003ab0:	1800                	addi	s0,sp,48
    80003ab2:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003ab4:	47ad                	li	a5,11
    80003ab6:	02b7e763          	bltu	a5,a1,80003ae4 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003aba:	02059493          	slli	s1,a1,0x20
    80003abe:	9081                	srli	s1,s1,0x20
    80003ac0:	048a                	slli	s1,s1,0x2
    80003ac2:	94aa                	add	s1,s1,a0
    80003ac4:	0504a903          	lw	s2,80(s1)
    80003ac8:	06091e63          	bnez	s2,80003b44 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003acc:	4108                	lw	a0,0(a0)
    80003ace:	00000097          	auipc	ra,0x0
    80003ad2:	e9c080e7          	jalr	-356(ra) # 8000396a <balloc>
    80003ad6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ada:	06090563          	beqz	s2,80003b44 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003ade:	0524a823          	sw	s2,80(s1)
    80003ae2:	a08d                	j	80003b44 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003ae4:	ff45849b          	addiw	s1,a1,-12
    80003ae8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003aec:	0ff00793          	li	a5,255
    80003af0:	08e7e563          	bltu	a5,a4,80003b7a <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003af4:	08052903          	lw	s2,128(a0)
    80003af8:	00091d63          	bnez	s2,80003b12 <bmap+0x70>
      addr = balloc(ip->dev);
    80003afc:	4108                	lw	a0,0(a0)
    80003afe:	00000097          	auipc	ra,0x0
    80003b02:	e6c080e7          	jalr	-404(ra) # 8000396a <balloc>
    80003b06:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b0a:	02090d63          	beqz	s2,80003b44 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003b0e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003b12:	85ca                	mv	a1,s2
    80003b14:	0009a503          	lw	a0,0(s3)
    80003b18:	00000097          	auipc	ra,0x0
    80003b1c:	b90080e7          	jalr	-1136(ra) # 800036a8 <bread>
    80003b20:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003b22:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003b26:	02049593          	slli	a1,s1,0x20
    80003b2a:	9181                	srli	a1,a1,0x20
    80003b2c:	058a                	slli	a1,a1,0x2
    80003b2e:	00b784b3          	add	s1,a5,a1
    80003b32:	0004a903          	lw	s2,0(s1)
    80003b36:	02090063          	beqz	s2,80003b56 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003b3a:	8552                	mv	a0,s4
    80003b3c:	00000097          	auipc	ra,0x0
    80003b40:	c9c080e7          	jalr	-868(ra) # 800037d8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003b44:	854a                	mv	a0,s2
    80003b46:	70a2                	ld	ra,40(sp)
    80003b48:	7402                	ld	s0,32(sp)
    80003b4a:	64e2                	ld	s1,24(sp)
    80003b4c:	6942                	ld	s2,16(sp)
    80003b4e:	69a2                	ld	s3,8(sp)
    80003b50:	6a02                	ld	s4,0(sp)
    80003b52:	6145                	addi	sp,sp,48
    80003b54:	8082                	ret
      addr = balloc(ip->dev);
    80003b56:	0009a503          	lw	a0,0(s3)
    80003b5a:	00000097          	auipc	ra,0x0
    80003b5e:	e10080e7          	jalr	-496(ra) # 8000396a <balloc>
    80003b62:	0005091b          	sext.w	s2,a0
      if(addr){
    80003b66:	fc090ae3          	beqz	s2,80003b3a <bmap+0x98>
        a[bn] = addr;
    80003b6a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003b6e:	8552                	mv	a0,s4
    80003b70:	00001097          	auipc	ra,0x1
    80003b74:	eec080e7          	jalr	-276(ra) # 80004a5c <log_write>
    80003b78:	b7c9                	j	80003b3a <bmap+0x98>
  panic("bmap: out of range");
    80003b7a:	00005517          	auipc	a0,0x5
    80003b7e:	ae650513          	addi	a0,a0,-1306 # 80008660 <syscalls+0x130>
    80003b82:	ffffd097          	auipc	ra,0xffffd
    80003b86:	9c2080e7          	jalr	-1598(ra) # 80000544 <panic>

0000000080003b8a <iget>:
{
    80003b8a:	7179                	addi	sp,sp,-48
    80003b8c:	f406                	sd	ra,40(sp)
    80003b8e:	f022                	sd	s0,32(sp)
    80003b90:	ec26                	sd	s1,24(sp)
    80003b92:	e84a                	sd	s2,16(sp)
    80003b94:	e44e                	sd	s3,8(sp)
    80003b96:	e052                	sd	s4,0(sp)
    80003b98:	1800                	addi	s0,sp,48
    80003b9a:	89aa                	mv	s3,a0
    80003b9c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003b9e:	0023c517          	auipc	a0,0x23c
    80003ba2:	fd250513          	addi	a0,a0,-46 # 8023fb70 <itable>
    80003ba6:	ffffd097          	auipc	ra,0xffffd
    80003baa:	160080e7          	jalr	352(ra) # 80000d06 <acquire>
  empty = 0;
    80003bae:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003bb0:	0023c497          	auipc	s1,0x23c
    80003bb4:	fd848493          	addi	s1,s1,-40 # 8023fb88 <itable+0x18>
    80003bb8:	0023e697          	auipc	a3,0x23e
    80003bbc:	a6068693          	addi	a3,a3,-1440 # 80241618 <log>
    80003bc0:	a039                	j	80003bce <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003bc2:	02090b63          	beqz	s2,80003bf8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003bc6:	08848493          	addi	s1,s1,136
    80003bca:	02d48a63          	beq	s1,a3,80003bfe <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003bce:	449c                	lw	a5,8(s1)
    80003bd0:	fef059e3          	blez	a5,80003bc2 <iget+0x38>
    80003bd4:	4098                	lw	a4,0(s1)
    80003bd6:	ff3716e3          	bne	a4,s3,80003bc2 <iget+0x38>
    80003bda:	40d8                	lw	a4,4(s1)
    80003bdc:	ff4713e3          	bne	a4,s4,80003bc2 <iget+0x38>
      ip->ref++;
    80003be0:	2785                	addiw	a5,a5,1
    80003be2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003be4:	0023c517          	auipc	a0,0x23c
    80003be8:	f8c50513          	addi	a0,a0,-116 # 8023fb70 <itable>
    80003bec:	ffffd097          	auipc	ra,0xffffd
    80003bf0:	1ce080e7          	jalr	462(ra) # 80000dba <release>
      return ip;
    80003bf4:	8926                	mv	s2,s1
    80003bf6:	a03d                	j	80003c24 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003bf8:	f7f9                	bnez	a5,80003bc6 <iget+0x3c>
    80003bfa:	8926                	mv	s2,s1
    80003bfc:	b7e9                	j	80003bc6 <iget+0x3c>
  if(empty == 0)
    80003bfe:	02090c63          	beqz	s2,80003c36 <iget+0xac>
  ip->dev = dev;
    80003c02:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003c06:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003c0a:	4785                	li	a5,1
    80003c0c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003c10:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003c14:	0023c517          	auipc	a0,0x23c
    80003c18:	f5c50513          	addi	a0,a0,-164 # 8023fb70 <itable>
    80003c1c:	ffffd097          	auipc	ra,0xffffd
    80003c20:	19e080e7          	jalr	414(ra) # 80000dba <release>
}
    80003c24:	854a                	mv	a0,s2
    80003c26:	70a2                	ld	ra,40(sp)
    80003c28:	7402                	ld	s0,32(sp)
    80003c2a:	64e2                	ld	s1,24(sp)
    80003c2c:	6942                	ld	s2,16(sp)
    80003c2e:	69a2                	ld	s3,8(sp)
    80003c30:	6a02                	ld	s4,0(sp)
    80003c32:	6145                	addi	sp,sp,48
    80003c34:	8082                	ret
    panic("iget: no inodes");
    80003c36:	00005517          	auipc	a0,0x5
    80003c3a:	a4250513          	addi	a0,a0,-1470 # 80008678 <syscalls+0x148>
    80003c3e:	ffffd097          	auipc	ra,0xffffd
    80003c42:	906080e7          	jalr	-1786(ra) # 80000544 <panic>

0000000080003c46 <fsinit>:
fsinit(int dev) {
    80003c46:	7179                	addi	sp,sp,-48
    80003c48:	f406                	sd	ra,40(sp)
    80003c4a:	f022                	sd	s0,32(sp)
    80003c4c:	ec26                	sd	s1,24(sp)
    80003c4e:	e84a                	sd	s2,16(sp)
    80003c50:	e44e                	sd	s3,8(sp)
    80003c52:	1800                	addi	s0,sp,48
    80003c54:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003c56:	4585                	li	a1,1
    80003c58:	00000097          	auipc	ra,0x0
    80003c5c:	a50080e7          	jalr	-1456(ra) # 800036a8 <bread>
    80003c60:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003c62:	0023c997          	auipc	s3,0x23c
    80003c66:	eee98993          	addi	s3,s3,-274 # 8023fb50 <sb>
    80003c6a:	02000613          	li	a2,32
    80003c6e:	05850593          	addi	a1,a0,88
    80003c72:	854e                	mv	a0,s3
    80003c74:	ffffd097          	auipc	ra,0xffffd
    80003c78:	1ee080e7          	jalr	494(ra) # 80000e62 <memmove>
  brelse(bp);
    80003c7c:	8526                	mv	a0,s1
    80003c7e:	00000097          	auipc	ra,0x0
    80003c82:	b5a080e7          	jalr	-1190(ra) # 800037d8 <brelse>
  if(sb.magic != FSMAGIC)
    80003c86:	0009a703          	lw	a4,0(s3)
    80003c8a:	102037b7          	lui	a5,0x10203
    80003c8e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c92:	02f71263          	bne	a4,a5,80003cb6 <fsinit+0x70>
  initlog(dev, &sb);
    80003c96:	0023c597          	auipc	a1,0x23c
    80003c9a:	eba58593          	addi	a1,a1,-326 # 8023fb50 <sb>
    80003c9e:	854a                	mv	a0,s2
    80003ca0:	00001097          	auipc	ra,0x1
    80003ca4:	b40080e7          	jalr	-1216(ra) # 800047e0 <initlog>
}
    80003ca8:	70a2                	ld	ra,40(sp)
    80003caa:	7402                	ld	s0,32(sp)
    80003cac:	64e2                	ld	s1,24(sp)
    80003cae:	6942                	ld	s2,16(sp)
    80003cb0:	69a2                	ld	s3,8(sp)
    80003cb2:	6145                	addi	sp,sp,48
    80003cb4:	8082                	ret
    panic("invalid file system");
    80003cb6:	00005517          	auipc	a0,0x5
    80003cba:	9d250513          	addi	a0,a0,-1582 # 80008688 <syscalls+0x158>
    80003cbe:	ffffd097          	auipc	ra,0xffffd
    80003cc2:	886080e7          	jalr	-1914(ra) # 80000544 <panic>

0000000080003cc6 <iinit>:
{
    80003cc6:	7179                	addi	sp,sp,-48
    80003cc8:	f406                	sd	ra,40(sp)
    80003cca:	f022                	sd	s0,32(sp)
    80003ccc:	ec26                	sd	s1,24(sp)
    80003cce:	e84a                	sd	s2,16(sp)
    80003cd0:	e44e                	sd	s3,8(sp)
    80003cd2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003cd4:	00005597          	auipc	a1,0x5
    80003cd8:	9cc58593          	addi	a1,a1,-1588 # 800086a0 <syscalls+0x170>
    80003cdc:	0023c517          	auipc	a0,0x23c
    80003ce0:	e9450513          	addi	a0,a0,-364 # 8023fb70 <itable>
    80003ce4:	ffffd097          	auipc	ra,0xffffd
    80003ce8:	f92080e7          	jalr	-110(ra) # 80000c76 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003cec:	0023c497          	auipc	s1,0x23c
    80003cf0:	eac48493          	addi	s1,s1,-340 # 8023fb98 <itable+0x28>
    80003cf4:	0023e997          	auipc	s3,0x23e
    80003cf8:	93498993          	addi	s3,s3,-1740 # 80241628 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003cfc:	00005917          	auipc	s2,0x5
    80003d00:	9ac90913          	addi	s2,s2,-1620 # 800086a8 <syscalls+0x178>
    80003d04:	85ca                	mv	a1,s2
    80003d06:	8526                	mv	a0,s1
    80003d08:	00001097          	auipc	ra,0x1
    80003d0c:	e3a080e7          	jalr	-454(ra) # 80004b42 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003d10:	08848493          	addi	s1,s1,136
    80003d14:	ff3498e3          	bne	s1,s3,80003d04 <iinit+0x3e>
}
    80003d18:	70a2                	ld	ra,40(sp)
    80003d1a:	7402                	ld	s0,32(sp)
    80003d1c:	64e2                	ld	s1,24(sp)
    80003d1e:	6942                	ld	s2,16(sp)
    80003d20:	69a2                	ld	s3,8(sp)
    80003d22:	6145                	addi	sp,sp,48
    80003d24:	8082                	ret

0000000080003d26 <ialloc>:
{
    80003d26:	715d                	addi	sp,sp,-80
    80003d28:	e486                	sd	ra,72(sp)
    80003d2a:	e0a2                	sd	s0,64(sp)
    80003d2c:	fc26                	sd	s1,56(sp)
    80003d2e:	f84a                	sd	s2,48(sp)
    80003d30:	f44e                	sd	s3,40(sp)
    80003d32:	f052                	sd	s4,32(sp)
    80003d34:	ec56                	sd	s5,24(sp)
    80003d36:	e85a                	sd	s6,16(sp)
    80003d38:	e45e                	sd	s7,8(sp)
    80003d3a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d3c:	0023c717          	auipc	a4,0x23c
    80003d40:	e2072703          	lw	a4,-480(a4) # 8023fb5c <sb+0xc>
    80003d44:	4785                	li	a5,1
    80003d46:	04e7fa63          	bgeu	a5,a4,80003d9a <ialloc+0x74>
    80003d4a:	8aaa                	mv	s5,a0
    80003d4c:	8bae                	mv	s7,a1
    80003d4e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003d50:	0023ca17          	auipc	s4,0x23c
    80003d54:	e00a0a13          	addi	s4,s4,-512 # 8023fb50 <sb>
    80003d58:	00048b1b          	sext.w	s6,s1
    80003d5c:	0044d593          	srli	a1,s1,0x4
    80003d60:	018a2783          	lw	a5,24(s4)
    80003d64:	9dbd                	addw	a1,a1,a5
    80003d66:	8556                	mv	a0,s5
    80003d68:	00000097          	auipc	ra,0x0
    80003d6c:	940080e7          	jalr	-1728(ra) # 800036a8 <bread>
    80003d70:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003d72:	05850993          	addi	s3,a0,88
    80003d76:	00f4f793          	andi	a5,s1,15
    80003d7a:	079a                	slli	a5,a5,0x6
    80003d7c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003d7e:	00099783          	lh	a5,0(s3)
    80003d82:	c3a1                	beqz	a5,80003dc2 <ialloc+0x9c>
    brelse(bp);
    80003d84:	00000097          	auipc	ra,0x0
    80003d88:	a54080e7          	jalr	-1452(ra) # 800037d8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d8c:	0485                	addi	s1,s1,1
    80003d8e:	00ca2703          	lw	a4,12(s4)
    80003d92:	0004879b          	sext.w	a5,s1
    80003d96:	fce7e1e3          	bltu	a5,a4,80003d58 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003d9a:	00005517          	auipc	a0,0x5
    80003d9e:	91650513          	addi	a0,a0,-1770 # 800086b0 <syscalls+0x180>
    80003da2:	ffffc097          	auipc	ra,0xffffc
    80003da6:	7ec080e7          	jalr	2028(ra) # 8000058e <printf>
  return 0;
    80003daa:	4501                	li	a0,0
}
    80003dac:	60a6                	ld	ra,72(sp)
    80003dae:	6406                	ld	s0,64(sp)
    80003db0:	74e2                	ld	s1,56(sp)
    80003db2:	7942                	ld	s2,48(sp)
    80003db4:	79a2                	ld	s3,40(sp)
    80003db6:	7a02                	ld	s4,32(sp)
    80003db8:	6ae2                	ld	s5,24(sp)
    80003dba:	6b42                	ld	s6,16(sp)
    80003dbc:	6ba2                	ld	s7,8(sp)
    80003dbe:	6161                	addi	sp,sp,80
    80003dc0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003dc2:	04000613          	li	a2,64
    80003dc6:	4581                	li	a1,0
    80003dc8:	854e                	mv	a0,s3
    80003dca:	ffffd097          	auipc	ra,0xffffd
    80003dce:	038080e7          	jalr	56(ra) # 80000e02 <memset>
      dip->type = type;
    80003dd2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003dd6:	854a                	mv	a0,s2
    80003dd8:	00001097          	auipc	ra,0x1
    80003ddc:	c84080e7          	jalr	-892(ra) # 80004a5c <log_write>
      brelse(bp);
    80003de0:	854a                	mv	a0,s2
    80003de2:	00000097          	auipc	ra,0x0
    80003de6:	9f6080e7          	jalr	-1546(ra) # 800037d8 <brelse>
      return iget(dev, inum);
    80003dea:	85da                	mv	a1,s6
    80003dec:	8556                	mv	a0,s5
    80003dee:	00000097          	auipc	ra,0x0
    80003df2:	d9c080e7          	jalr	-612(ra) # 80003b8a <iget>
    80003df6:	bf5d                	j	80003dac <ialloc+0x86>

0000000080003df8 <iupdate>:
{
    80003df8:	1101                	addi	sp,sp,-32
    80003dfa:	ec06                	sd	ra,24(sp)
    80003dfc:	e822                	sd	s0,16(sp)
    80003dfe:	e426                	sd	s1,8(sp)
    80003e00:	e04a                	sd	s2,0(sp)
    80003e02:	1000                	addi	s0,sp,32
    80003e04:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e06:	415c                	lw	a5,4(a0)
    80003e08:	0047d79b          	srliw	a5,a5,0x4
    80003e0c:	0023c597          	auipc	a1,0x23c
    80003e10:	d5c5a583          	lw	a1,-676(a1) # 8023fb68 <sb+0x18>
    80003e14:	9dbd                	addw	a1,a1,a5
    80003e16:	4108                	lw	a0,0(a0)
    80003e18:	00000097          	auipc	ra,0x0
    80003e1c:	890080e7          	jalr	-1904(ra) # 800036a8 <bread>
    80003e20:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e22:	05850793          	addi	a5,a0,88
    80003e26:	40c8                	lw	a0,4(s1)
    80003e28:	893d                	andi	a0,a0,15
    80003e2a:	051a                	slli	a0,a0,0x6
    80003e2c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003e2e:	04449703          	lh	a4,68(s1)
    80003e32:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003e36:	04649703          	lh	a4,70(s1)
    80003e3a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003e3e:	04849703          	lh	a4,72(s1)
    80003e42:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003e46:	04a49703          	lh	a4,74(s1)
    80003e4a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003e4e:	44f8                	lw	a4,76(s1)
    80003e50:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e52:	03400613          	li	a2,52
    80003e56:	05048593          	addi	a1,s1,80
    80003e5a:	0531                	addi	a0,a0,12
    80003e5c:	ffffd097          	auipc	ra,0xffffd
    80003e60:	006080e7          	jalr	6(ra) # 80000e62 <memmove>
  log_write(bp);
    80003e64:	854a                	mv	a0,s2
    80003e66:	00001097          	auipc	ra,0x1
    80003e6a:	bf6080e7          	jalr	-1034(ra) # 80004a5c <log_write>
  brelse(bp);
    80003e6e:	854a                	mv	a0,s2
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	968080e7          	jalr	-1688(ra) # 800037d8 <brelse>
}
    80003e78:	60e2                	ld	ra,24(sp)
    80003e7a:	6442                	ld	s0,16(sp)
    80003e7c:	64a2                	ld	s1,8(sp)
    80003e7e:	6902                	ld	s2,0(sp)
    80003e80:	6105                	addi	sp,sp,32
    80003e82:	8082                	ret

0000000080003e84 <idup>:
{
    80003e84:	1101                	addi	sp,sp,-32
    80003e86:	ec06                	sd	ra,24(sp)
    80003e88:	e822                	sd	s0,16(sp)
    80003e8a:	e426                	sd	s1,8(sp)
    80003e8c:	1000                	addi	s0,sp,32
    80003e8e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e90:	0023c517          	auipc	a0,0x23c
    80003e94:	ce050513          	addi	a0,a0,-800 # 8023fb70 <itable>
    80003e98:	ffffd097          	auipc	ra,0xffffd
    80003e9c:	e6e080e7          	jalr	-402(ra) # 80000d06 <acquire>
  ip->ref++;
    80003ea0:	449c                	lw	a5,8(s1)
    80003ea2:	2785                	addiw	a5,a5,1
    80003ea4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ea6:	0023c517          	auipc	a0,0x23c
    80003eaa:	cca50513          	addi	a0,a0,-822 # 8023fb70 <itable>
    80003eae:	ffffd097          	auipc	ra,0xffffd
    80003eb2:	f0c080e7          	jalr	-244(ra) # 80000dba <release>
}
    80003eb6:	8526                	mv	a0,s1
    80003eb8:	60e2                	ld	ra,24(sp)
    80003eba:	6442                	ld	s0,16(sp)
    80003ebc:	64a2                	ld	s1,8(sp)
    80003ebe:	6105                	addi	sp,sp,32
    80003ec0:	8082                	ret

0000000080003ec2 <ilock>:
{
    80003ec2:	1101                	addi	sp,sp,-32
    80003ec4:	ec06                	sd	ra,24(sp)
    80003ec6:	e822                	sd	s0,16(sp)
    80003ec8:	e426                	sd	s1,8(sp)
    80003eca:	e04a                	sd	s2,0(sp)
    80003ecc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ece:	c115                	beqz	a0,80003ef2 <ilock+0x30>
    80003ed0:	84aa                	mv	s1,a0
    80003ed2:	451c                	lw	a5,8(a0)
    80003ed4:	00f05f63          	blez	a5,80003ef2 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003ed8:	0541                	addi	a0,a0,16
    80003eda:	00001097          	auipc	ra,0x1
    80003ede:	ca2080e7          	jalr	-862(ra) # 80004b7c <acquiresleep>
  if(ip->valid == 0){
    80003ee2:	40bc                	lw	a5,64(s1)
    80003ee4:	cf99                	beqz	a5,80003f02 <ilock+0x40>
}
    80003ee6:	60e2                	ld	ra,24(sp)
    80003ee8:	6442                	ld	s0,16(sp)
    80003eea:	64a2                	ld	s1,8(sp)
    80003eec:	6902                	ld	s2,0(sp)
    80003eee:	6105                	addi	sp,sp,32
    80003ef0:	8082                	ret
    panic("ilock");
    80003ef2:	00004517          	auipc	a0,0x4
    80003ef6:	7d650513          	addi	a0,a0,2006 # 800086c8 <syscalls+0x198>
    80003efa:	ffffc097          	auipc	ra,0xffffc
    80003efe:	64a080e7          	jalr	1610(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f02:	40dc                	lw	a5,4(s1)
    80003f04:	0047d79b          	srliw	a5,a5,0x4
    80003f08:	0023c597          	auipc	a1,0x23c
    80003f0c:	c605a583          	lw	a1,-928(a1) # 8023fb68 <sb+0x18>
    80003f10:	9dbd                	addw	a1,a1,a5
    80003f12:	4088                	lw	a0,0(s1)
    80003f14:	fffff097          	auipc	ra,0xfffff
    80003f18:	794080e7          	jalr	1940(ra) # 800036a8 <bread>
    80003f1c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f1e:	05850593          	addi	a1,a0,88
    80003f22:	40dc                	lw	a5,4(s1)
    80003f24:	8bbd                	andi	a5,a5,15
    80003f26:	079a                	slli	a5,a5,0x6
    80003f28:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f2a:	00059783          	lh	a5,0(a1)
    80003f2e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003f32:	00259783          	lh	a5,2(a1)
    80003f36:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003f3a:	00459783          	lh	a5,4(a1)
    80003f3e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f42:	00659783          	lh	a5,6(a1)
    80003f46:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f4a:	459c                	lw	a5,8(a1)
    80003f4c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f4e:	03400613          	li	a2,52
    80003f52:	05b1                	addi	a1,a1,12
    80003f54:	05048513          	addi	a0,s1,80
    80003f58:	ffffd097          	auipc	ra,0xffffd
    80003f5c:	f0a080e7          	jalr	-246(ra) # 80000e62 <memmove>
    brelse(bp);
    80003f60:	854a                	mv	a0,s2
    80003f62:	00000097          	auipc	ra,0x0
    80003f66:	876080e7          	jalr	-1930(ra) # 800037d8 <brelse>
    ip->valid = 1;
    80003f6a:	4785                	li	a5,1
    80003f6c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003f6e:	04449783          	lh	a5,68(s1)
    80003f72:	fbb5                	bnez	a5,80003ee6 <ilock+0x24>
      panic("ilock: no type");
    80003f74:	00004517          	auipc	a0,0x4
    80003f78:	75c50513          	addi	a0,a0,1884 # 800086d0 <syscalls+0x1a0>
    80003f7c:	ffffc097          	auipc	ra,0xffffc
    80003f80:	5c8080e7          	jalr	1480(ra) # 80000544 <panic>

0000000080003f84 <iunlock>:
{
    80003f84:	1101                	addi	sp,sp,-32
    80003f86:	ec06                	sd	ra,24(sp)
    80003f88:	e822                	sd	s0,16(sp)
    80003f8a:	e426                	sd	s1,8(sp)
    80003f8c:	e04a                	sd	s2,0(sp)
    80003f8e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f90:	c905                	beqz	a0,80003fc0 <iunlock+0x3c>
    80003f92:	84aa                	mv	s1,a0
    80003f94:	01050913          	addi	s2,a0,16
    80003f98:	854a                	mv	a0,s2
    80003f9a:	00001097          	auipc	ra,0x1
    80003f9e:	c7c080e7          	jalr	-900(ra) # 80004c16 <holdingsleep>
    80003fa2:	cd19                	beqz	a0,80003fc0 <iunlock+0x3c>
    80003fa4:	449c                	lw	a5,8(s1)
    80003fa6:	00f05d63          	blez	a5,80003fc0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003faa:	854a                	mv	a0,s2
    80003fac:	00001097          	auipc	ra,0x1
    80003fb0:	c26080e7          	jalr	-986(ra) # 80004bd2 <releasesleep>
}
    80003fb4:	60e2                	ld	ra,24(sp)
    80003fb6:	6442                	ld	s0,16(sp)
    80003fb8:	64a2                	ld	s1,8(sp)
    80003fba:	6902                	ld	s2,0(sp)
    80003fbc:	6105                	addi	sp,sp,32
    80003fbe:	8082                	ret
    panic("iunlock");
    80003fc0:	00004517          	auipc	a0,0x4
    80003fc4:	72050513          	addi	a0,a0,1824 # 800086e0 <syscalls+0x1b0>
    80003fc8:	ffffc097          	auipc	ra,0xffffc
    80003fcc:	57c080e7          	jalr	1404(ra) # 80000544 <panic>

0000000080003fd0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003fd0:	7179                	addi	sp,sp,-48
    80003fd2:	f406                	sd	ra,40(sp)
    80003fd4:	f022                	sd	s0,32(sp)
    80003fd6:	ec26                	sd	s1,24(sp)
    80003fd8:	e84a                	sd	s2,16(sp)
    80003fda:	e44e                	sd	s3,8(sp)
    80003fdc:	e052                	sd	s4,0(sp)
    80003fde:	1800                	addi	s0,sp,48
    80003fe0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003fe2:	05050493          	addi	s1,a0,80
    80003fe6:	08050913          	addi	s2,a0,128
    80003fea:	a021                	j	80003ff2 <itrunc+0x22>
    80003fec:	0491                	addi	s1,s1,4
    80003fee:	01248d63          	beq	s1,s2,80004008 <itrunc+0x38>
    if(ip->addrs[i]){
    80003ff2:	408c                	lw	a1,0(s1)
    80003ff4:	dde5                	beqz	a1,80003fec <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003ff6:	0009a503          	lw	a0,0(s3)
    80003ffa:	00000097          	auipc	ra,0x0
    80003ffe:	8f4080e7          	jalr	-1804(ra) # 800038ee <bfree>
      ip->addrs[i] = 0;
    80004002:	0004a023          	sw	zero,0(s1)
    80004006:	b7dd                	j	80003fec <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004008:	0809a583          	lw	a1,128(s3)
    8000400c:	e185                	bnez	a1,8000402c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000400e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004012:	854e                	mv	a0,s3
    80004014:	00000097          	auipc	ra,0x0
    80004018:	de4080e7          	jalr	-540(ra) # 80003df8 <iupdate>
}
    8000401c:	70a2                	ld	ra,40(sp)
    8000401e:	7402                	ld	s0,32(sp)
    80004020:	64e2                	ld	s1,24(sp)
    80004022:	6942                	ld	s2,16(sp)
    80004024:	69a2                	ld	s3,8(sp)
    80004026:	6a02                	ld	s4,0(sp)
    80004028:	6145                	addi	sp,sp,48
    8000402a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000402c:	0009a503          	lw	a0,0(s3)
    80004030:	fffff097          	auipc	ra,0xfffff
    80004034:	678080e7          	jalr	1656(ra) # 800036a8 <bread>
    80004038:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000403a:	05850493          	addi	s1,a0,88
    8000403e:	45850913          	addi	s2,a0,1112
    80004042:	a811                	j	80004056 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80004044:	0009a503          	lw	a0,0(s3)
    80004048:	00000097          	auipc	ra,0x0
    8000404c:	8a6080e7          	jalr	-1882(ra) # 800038ee <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80004050:	0491                	addi	s1,s1,4
    80004052:	01248563          	beq	s1,s2,8000405c <itrunc+0x8c>
      if(a[j])
    80004056:	408c                	lw	a1,0(s1)
    80004058:	dde5                	beqz	a1,80004050 <itrunc+0x80>
    8000405a:	b7ed                	j	80004044 <itrunc+0x74>
    brelse(bp);
    8000405c:	8552                	mv	a0,s4
    8000405e:	fffff097          	auipc	ra,0xfffff
    80004062:	77a080e7          	jalr	1914(ra) # 800037d8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004066:	0809a583          	lw	a1,128(s3)
    8000406a:	0009a503          	lw	a0,0(s3)
    8000406e:	00000097          	auipc	ra,0x0
    80004072:	880080e7          	jalr	-1920(ra) # 800038ee <bfree>
    ip->addrs[NDIRECT] = 0;
    80004076:	0809a023          	sw	zero,128(s3)
    8000407a:	bf51                	j	8000400e <itrunc+0x3e>

000000008000407c <iput>:
{
    8000407c:	1101                	addi	sp,sp,-32
    8000407e:	ec06                	sd	ra,24(sp)
    80004080:	e822                	sd	s0,16(sp)
    80004082:	e426                	sd	s1,8(sp)
    80004084:	e04a                	sd	s2,0(sp)
    80004086:	1000                	addi	s0,sp,32
    80004088:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000408a:	0023c517          	auipc	a0,0x23c
    8000408e:	ae650513          	addi	a0,a0,-1306 # 8023fb70 <itable>
    80004092:	ffffd097          	auipc	ra,0xffffd
    80004096:	c74080e7          	jalr	-908(ra) # 80000d06 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000409a:	4498                	lw	a4,8(s1)
    8000409c:	4785                	li	a5,1
    8000409e:	02f70363          	beq	a4,a5,800040c4 <iput+0x48>
  ip->ref--;
    800040a2:	449c                	lw	a5,8(s1)
    800040a4:	37fd                	addiw	a5,a5,-1
    800040a6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800040a8:	0023c517          	auipc	a0,0x23c
    800040ac:	ac850513          	addi	a0,a0,-1336 # 8023fb70 <itable>
    800040b0:	ffffd097          	auipc	ra,0xffffd
    800040b4:	d0a080e7          	jalr	-758(ra) # 80000dba <release>
}
    800040b8:	60e2                	ld	ra,24(sp)
    800040ba:	6442                	ld	s0,16(sp)
    800040bc:	64a2                	ld	s1,8(sp)
    800040be:	6902                	ld	s2,0(sp)
    800040c0:	6105                	addi	sp,sp,32
    800040c2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800040c4:	40bc                	lw	a5,64(s1)
    800040c6:	dff1                	beqz	a5,800040a2 <iput+0x26>
    800040c8:	04a49783          	lh	a5,74(s1)
    800040cc:	fbf9                	bnez	a5,800040a2 <iput+0x26>
    acquiresleep(&ip->lock);
    800040ce:	01048913          	addi	s2,s1,16
    800040d2:	854a                	mv	a0,s2
    800040d4:	00001097          	auipc	ra,0x1
    800040d8:	aa8080e7          	jalr	-1368(ra) # 80004b7c <acquiresleep>
    release(&itable.lock);
    800040dc:	0023c517          	auipc	a0,0x23c
    800040e0:	a9450513          	addi	a0,a0,-1388 # 8023fb70 <itable>
    800040e4:	ffffd097          	auipc	ra,0xffffd
    800040e8:	cd6080e7          	jalr	-810(ra) # 80000dba <release>
    itrunc(ip);
    800040ec:	8526                	mv	a0,s1
    800040ee:	00000097          	auipc	ra,0x0
    800040f2:	ee2080e7          	jalr	-286(ra) # 80003fd0 <itrunc>
    ip->type = 0;
    800040f6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800040fa:	8526                	mv	a0,s1
    800040fc:	00000097          	auipc	ra,0x0
    80004100:	cfc080e7          	jalr	-772(ra) # 80003df8 <iupdate>
    ip->valid = 0;
    80004104:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004108:	854a                	mv	a0,s2
    8000410a:	00001097          	auipc	ra,0x1
    8000410e:	ac8080e7          	jalr	-1336(ra) # 80004bd2 <releasesleep>
    acquire(&itable.lock);
    80004112:	0023c517          	auipc	a0,0x23c
    80004116:	a5e50513          	addi	a0,a0,-1442 # 8023fb70 <itable>
    8000411a:	ffffd097          	auipc	ra,0xffffd
    8000411e:	bec080e7          	jalr	-1044(ra) # 80000d06 <acquire>
    80004122:	b741                	j	800040a2 <iput+0x26>

0000000080004124 <iunlockput>:
{
    80004124:	1101                	addi	sp,sp,-32
    80004126:	ec06                	sd	ra,24(sp)
    80004128:	e822                	sd	s0,16(sp)
    8000412a:	e426                	sd	s1,8(sp)
    8000412c:	1000                	addi	s0,sp,32
    8000412e:	84aa                	mv	s1,a0
  iunlock(ip);
    80004130:	00000097          	auipc	ra,0x0
    80004134:	e54080e7          	jalr	-428(ra) # 80003f84 <iunlock>
  iput(ip);
    80004138:	8526                	mv	a0,s1
    8000413a:	00000097          	auipc	ra,0x0
    8000413e:	f42080e7          	jalr	-190(ra) # 8000407c <iput>
}
    80004142:	60e2                	ld	ra,24(sp)
    80004144:	6442                	ld	s0,16(sp)
    80004146:	64a2                	ld	s1,8(sp)
    80004148:	6105                	addi	sp,sp,32
    8000414a:	8082                	ret

000000008000414c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000414c:	1141                	addi	sp,sp,-16
    8000414e:	e422                	sd	s0,8(sp)
    80004150:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004152:	411c                	lw	a5,0(a0)
    80004154:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004156:	415c                	lw	a5,4(a0)
    80004158:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000415a:	04451783          	lh	a5,68(a0)
    8000415e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004162:	04a51783          	lh	a5,74(a0)
    80004166:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000416a:	04c56783          	lwu	a5,76(a0)
    8000416e:	e99c                	sd	a5,16(a1)
}
    80004170:	6422                	ld	s0,8(sp)
    80004172:	0141                	addi	sp,sp,16
    80004174:	8082                	ret

0000000080004176 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004176:	457c                	lw	a5,76(a0)
    80004178:	0ed7e963          	bltu	a5,a3,8000426a <readi+0xf4>
{
    8000417c:	7159                	addi	sp,sp,-112
    8000417e:	f486                	sd	ra,104(sp)
    80004180:	f0a2                	sd	s0,96(sp)
    80004182:	eca6                	sd	s1,88(sp)
    80004184:	e8ca                	sd	s2,80(sp)
    80004186:	e4ce                	sd	s3,72(sp)
    80004188:	e0d2                	sd	s4,64(sp)
    8000418a:	fc56                	sd	s5,56(sp)
    8000418c:	f85a                	sd	s6,48(sp)
    8000418e:	f45e                	sd	s7,40(sp)
    80004190:	f062                	sd	s8,32(sp)
    80004192:	ec66                	sd	s9,24(sp)
    80004194:	e86a                	sd	s10,16(sp)
    80004196:	e46e                	sd	s11,8(sp)
    80004198:	1880                	addi	s0,sp,112
    8000419a:	8b2a                	mv	s6,a0
    8000419c:	8bae                	mv	s7,a1
    8000419e:	8a32                	mv	s4,a2
    800041a0:	84b6                	mv	s1,a3
    800041a2:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800041a4:	9f35                	addw	a4,a4,a3
    return 0;
    800041a6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800041a8:	0ad76063          	bltu	a4,a3,80004248 <readi+0xd2>
  if(off + n > ip->size)
    800041ac:	00e7f463          	bgeu	a5,a4,800041b4 <readi+0x3e>
    n = ip->size - off;
    800041b0:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041b4:	0a0a8963          	beqz	s5,80004266 <readi+0xf0>
    800041b8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800041ba:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800041be:	5c7d                	li	s8,-1
    800041c0:	a82d                	j	800041fa <readi+0x84>
    800041c2:	020d1d93          	slli	s11,s10,0x20
    800041c6:	020ddd93          	srli	s11,s11,0x20
    800041ca:	05890613          	addi	a2,s2,88
    800041ce:	86ee                	mv	a3,s11
    800041d0:	963a                	add	a2,a2,a4
    800041d2:	85d2                	mv	a1,s4
    800041d4:	855e                	mv	a0,s7
    800041d6:	ffffe097          	auipc	ra,0xffffe
    800041da:	686080e7          	jalr	1670(ra) # 8000285c <either_copyout>
    800041de:	05850d63          	beq	a0,s8,80004238 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800041e2:	854a                	mv	a0,s2
    800041e4:	fffff097          	auipc	ra,0xfffff
    800041e8:	5f4080e7          	jalr	1524(ra) # 800037d8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041ec:	013d09bb          	addw	s3,s10,s3
    800041f0:	009d04bb          	addw	s1,s10,s1
    800041f4:	9a6e                	add	s4,s4,s11
    800041f6:	0559f763          	bgeu	s3,s5,80004244 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800041fa:	00a4d59b          	srliw	a1,s1,0xa
    800041fe:	855a                	mv	a0,s6
    80004200:	00000097          	auipc	ra,0x0
    80004204:	8a2080e7          	jalr	-1886(ra) # 80003aa2 <bmap>
    80004208:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000420c:	cd85                	beqz	a1,80004244 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000420e:	000b2503          	lw	a0,0(s6)
    80004212:	fffff097          	auipc	ra,0xfffff
    80004216:	496080e7          	jalr	1174(ra) # 800036a8 <bread>
    8000421a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000421c:	3ff4f713          	andi	a4,s1,1023
    80004220:	40ec87bb          	subw	a5,s9,a4
    80004224:	413a86bb          	subw	a3,s5,s3
    80004228:	8d3e                	mv	s10,a5
    8000422a:	2781                	sext.w	a5,a5
    8000422c:	0006861b          	sext.w	a2,a3
    80004230:	f8f679e3          	bgeu	a2,a5,800041c2 <readi+0x4c>
    80004234:	8d36                	mv	s10,a3
    80004236:	b771                	j	800041c2 <readi+0x4c>
      brelse(bp);
    80004238:	854a                	mv	a0,s2
    8000423a:	fffff097          	auipc	ra,0xfffff
    8000423e:	59e080e7          	jalr	1438(ra) # 800037d8 <brelse>
      tot = -1;
    80004242:	59fd                	li	s3,-1
  }
  return tot;
    80004244:	0009851b          	sext.w	a0,s3
}
    80004248:	70a6                	ld	ra,104(sp)
    8000424a:	7406                	ld	s0,96(sp)
    8000424c:	64e6                	ld	s1,88(sp)
    8000424e:	6946                	ld	s2,80(sp)
    80004250:	69a6                	ld	s3,72(sp)
    80004252:	6a06                	ld	s4,64(sp)
    80004254:	7ae2                	ld	s5,56(sp)
    80004256:	7b42                	ld	s6,48(sp)
    80004258:	7ba2                	ld	s7,40(sp)
    8000425a:	7c02                	ld	s8,32(sp)
    8000425c:	6ce2                	ld	s9,24(sp)
    8000425e:	6d42                	ld	s10,16(sp)
    80004260:	6da2                	ld	s11,8(sp)
    80004262:	6165                	addi	sp,sp,112
    80004264:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004266:	89d6                	mv	s3,s5
    80004268:	bff1                	j	80004244 <readi+0xce>
    return 0;
    8000426a:	4501                	li	a0,0
}
    8000426c:	8082                	ret

000000008000426e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000426e:	457c                	lw	a5,76(a0)
    80004270:	10d7e863          	bltu	a5,a3,80004380 <writei+0x112>
{
    80004274:	7159                	addi	sp,sp,-112
    80004276:	f486                	sd	ra,104(sp)
    80004278:	f0a2                	sd	s0,96(sp)
    8000427a:	eca6                	sd	s1,88(sp)
    8000427c:	e8ca                	sd	s2,80(sp)
    8000427e:	e4ce                	sd	s3,72(sp)
    80004280:	e0d2                	sd	s4,64(sp)
    80004282:	fc56                	sd	s5,56(sp)
    80004284:	f85a                	sd	s6,48(sp)
    80004286:	f45e                	sd	s7,40(sp)
    80004288:	f062                	sd	s8,32(sp)
    8000428a:	ec66                	sd	s9,24(sp)
    8000428c:	e86a                	sd	s10,16(sp)
    8000428e:	e46e                	sd	s11,8(sp)
    80004290:	1880                	addi	s0,sp,112
    80004292:	8aaa                	mv	s5,a0
    80004294:	8bae                	mv	s7,a1
    80004296:	8a32                	mv	s4,a2
    80004298:	8936                	mv	s2,a3
    8000429a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000429c:	00e687bb          	addw	a5,a3,a4
    800042a0:	0ed7e263          	bltu	a5,a3,80004384 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800042a4:	00043737          	lui	a4,0x43
    800042a8:	0ef76063          	bltu	a4,a5,80004388 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042ac:	0c0b0863          	beqz	s6,8000437c <writei+0x10e>
    800042b0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800042b2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800042b6:	5c7d                	li	s8,-1
    800042b8:	a091                	j	800042fc <writei+0x8e>
    800042ba:	020d1d93          	slli	s11,s10,0x20
    800042be:	020ddd93          	srli	s11,s11,0x20
    800042c2:	05848513          	addi	a0,s1,88
    800042c6:	86ee                	mv	a3,s11
    800042c8:	8652                	mv	a2,s4
    800042ca:	85de                	mv	a1,s7
    800042cc:	953a                	add	a0,a0,a4
    800042ce:	ffffe097          	auipc	ra,0xffffe
    800042d2:	5e4080e7          	jalr	1508(ra) # 800028b2 <either_copyin>
    800042d6:	07850263          	beq	a0,s8,8000433a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800042da:	8526                	mv	a0,s1
    800042dc:	00000097          	auipc	ra,0x0
    800042e0:	780080e7          	jalr	1920(ra) # 80004a5c <log_write>
    brelse(bp);
    800042e4:	8526                	mv	a0,s1
    800042e6:	fffff097          	auipc	ra,0xfffff
    800042ea:	4f2080e7          	jalr	1266(ra) # 800037d8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042ee:	013d09bb          	addw	s3,s10,s3
    800042f2:	012d093b          	addw	s2,s10,s2
    800042f6:	9a6e                	add	s4,s4,s11
    800042f8:	0569f663          	bgeu	s3,s6,80004344 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800042fc:	00a9559b          	srliw	a1,s2,0xa
    80004300:	8556                	mv	a0,s5
    80004302:	fffff097          	auipc	ra,0xfffff
    80004306:	7a0080e7          	jalr	1952(ra) # 80003aa2 <bmap>
    8000430a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000430e:	c99d                	beqz	a1,80004344 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004310:	000aa503          	lw	a0,0(s5)
    80004314:	fffff097          	auipc	ra,0xfffff
    80004318:	394080e7          	jalr	916(ra) # 800036a8 <bread>
    8000431c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000431e:	3ff97713          	andi	a4,s2,1023
    80004322:	40ec87bb          	subw	a5,s9,a4
    80004326:	413b06bb          	subw	a3,s6,s3
    8000432a:	8d3e                	mv	s10,a5
    8000432c:	2781                	sext.w	a5,a5
    8000432e:	0006861b          	sext.w	a2,a3
    80004332:	f8f674e3          	bgeu	a2,a5,800042ba <writei+0x4c>
    80004336:	8d36                	mv	s10,a3
    80004338:	b749                	j	800042ba <writei+0x4c>
      brelse(bp);
    8000433a:	8526                	mv	a0,s1
    8000433c:	fffff097          	auipc	ra,0xfffff
    80004340:	49c080e7          	jalr	1180(ra) # 800037d8 <brelse>
  }

  if(off > ip->size)
    80004344:	04caa783          	lw	a5,76(s5)
    80004348:	0127f463          	bgeu	a5,s2,80004350 <writei+0xe2>
    ip->size = off;
    8000434c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004350:	8556                	mv	a0,s5
    80004352:	00000097          	auipc	ra,0x0
    80004356:	aa6080e7          	jalr	-1370(ra) # 80003df8 <iupdate>

  return tot;
    8000435a:	0009851b          	sext.w	a0,s3
}
    8000435e:	70a6                	ld	ra,104(sp)
    80004360:	7406                	ld	s0,96(sp)
    80004362:	64e6                	ld	s1,88(sp)
    80004364:	6946                	ld	s2,80(sp)
    80004366:	69a6                	ld	s3,72(sp)
    80004368:	6a06                	ld	s4,64(sp)
    8000436a:	7ae2                	ld	s5,56(sp)
    8000436c:	7b42                	ld	s6,48(sp)
    8000436e:	7ba2                	ld	s7,40(sp)
    80004370:	7c02                	ld	s8,32(sp)
    80004372:	6ce2                	ld	s9,24(sp)
    80004374:	6d42                	ld	s10,16(sp)
    80004376:	6da2                	ld	s11,8(sp)
    80004378:	6165                	addi	sp,sp,112
    8000437a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000437c:	89da                	mv	s3,s6
    8000437e:	bfc9                	j	80004350 <writei+0xe2>
    return -1;
    80004380:	557d                	li	a0,-1
}
    80004382:	8082                	ret
    return -1;
    80004384:	557d                	li	a0,-1
    80004386:	bfe1                	j	8000435e <writei+0xf0>
    return -1;
    80004388:	557d                	li	a0,-1
    8000438a:	bfd1                	j	8000435e <writei+0xf0>

000000008000438c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000438c:	1141                	addi	sp,sp,-16
    8000438e:	e406                	sd	ra,8(sp)
    80004390:	e022                	sd	s0,0(sp)
    80004392:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004394:	4639                	li	a2,14
    80004396:	ffffd097          	auipc	ra,0xffffd
    8000439a:	b44080e7          	jalr	-1212(ra) # 80000eda <strncmp>
}
    8000439e:	60a2                	ld	ra,8(sp)
    800043a0:	6402                	ld	s0,0(sp)
    800043a2:	0141                	addi	sp,sp,16
    800043a4:	8082                	ret

00000000800043a6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800043a6:	7139                	addi	sp,sp,-64
    800043a8:	fc06                	sd	ra,56(sp)
    800043aa:	f822                	sd	s0,48(sp)
    800043ac:	f426                	sd	s1,40(sp)
    800043ae:	f04a                	sd	s2,32(sp)
    800043b0:	ec4e                	sd	s3,24(sp)
    800043b2:	e852                	sd	s4,16(sp)
    800043b4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800043b6:	04451703          	lh	a4,68(a0)
    800043ba:	4785                	li	a5,1
    800043bc:	00f71a63          	bne	a4,a5,800043d0 <dirlookup+0x2a>
    800043c0:	892a                	mv	s2,a0
    800043c2:	89ae                	mv	s3,a1
    800043c4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800043c6:	457c                	lw	a5,76(a0)
    800043c8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800043ca:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043cc:	e79d                	bnez	a5,800043fa <dirlookup+0x54>
    800043ce:	a8a5                	j	80004446 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800043d0:	00004517          	auipc	a0,0x4
    800043d4:	31850513          	addi	a0,a0,792 # 800086e8 <syscalls+0x1b8>
    800043d8:	ffffc097          	auipc	ra,0xffffc
    800043dc:	16c080e7          	jalr	364(ra) # 80000544 <panic>
      panic("dirlookup read");
    800043e0:	00004517          	auipc	a0,0x4
    800043e4:	32050513          	addi	a0,a0,800 # 80008700 <syscalls+0x1d0>
    800043e8:	ffffc097          	auipc	ra,0xffffc
    800043ec:	15c080e7          	jalr	348(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043f0:	24c1                	addiw	s1,s1,16
    800043f2:	04c92783          	lw	a5,76(s2)
    800043f6:	04f4f763          	bgeu	s1,a5,80004444 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043fa:	4741                	li	a4,16
    800043fc:	86a6                	mv	a3,s1
    800043fe:	fc040613          	addi	a2,s0,-64
    80004402:	4581                	li	a1,0
    80004404:	854a                	mv	a0,s2
    80004406:	00000097          	auipc	ra,0x0
    8000440a:	d70080e7          	jalr	-656(ra) # 80004176 <readi>
    8000440e:	47c1                	li	a5,16
    80004410:	fcf518e3          	bne	a0,a5,800043e0 <dirlookup+0x3a>
    if(de.inum == 0)
    80004414:	fc045783          	lhu	a5,-64(s0)
    80004418:	dfe1                	beqz	a5,800043f0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000441a:	fc240593          	addi	a1,s0,-62
    8000441e:	854e                	mv	a0,s3
    80004420:	00000097          	auipc	ra,0x0
    80004424:	f6c080e7          	jalr	-148(ra) # 8000438c <namecmp>
    80004428:	f561                	bnez	a0,800043f0 <dirlookup+0x4a>
      if(poff)
    8000442a:	000a0463          	beqz	s4,80004432 <dirlookup+0x8c>
        *poff = off;
    8000442e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004432:	fc045583          	lhu	a1,-64(s0)
    80004436:	00092503          	lw	a0,0(s2)
    8000443a:	fffff097          	auipc	ra,0xfffff
    8000443e:	750080e7          	jalr	1872(ra) # 80003b8a <iget>
    80004442:	a011                	j	80004446 <dirlookup+0xa0>
  return 0;
    80004444:	4501                	li	a0,0
}
    80004446:	70e2                	ld	ra,56(sp)
    80004448:	7442                	ld	s0,48(sp)
    8000444a:	74a2                	ld	s1,40(sp)
    8000444c:	7902                	ld	s2,32(sp)
    8000444e:	69e2                	ld	s3,24(sp)
    80004450:	6a42                	ld	s4,16(sp)
    80004452:	6121                	addi	sp,sp,64
    80004454:	8082                	ret

0000000080004456 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004456:	711d                	addi	sp,sp,-96
    80004458:	ec86                	sd	ra,88(sp)
    8000445a:	e8a2                	sd	s0,80(sp)
    8000445c:	e4a6                	sd	s1,72(sp)
    8000445e:	e0ca                	sd	s2,64(sp)
    80004460:	fc4e                	sd	s3,56(sp)
    80004462:	f852                	sd	s4,48(sp)
    80004464:	f456                	sd	s5,40(sp)
    80004466:	f05a                	sd	s6,32(sp)
    80004468:	ec5e                	sd	s7,24(sp)
    8000446a:	e862                	sd	s8,16(sp)
    8000446c:	e466                	sd	s9,8(sp)
    8000446e:	1080                	addi	s0,sp,96
    80004470:	84aa                	mv	s1,a0
    80004472:	8b2e                	mv	s6,a1
    80004474:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004476:	00054703          	lbu	a4,0(a0)
    8000447a:	02f00793          	li	a5,47
    8000447e:	02f70363          	beq	a4,a5,800044a4 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004482:	ffffd097          	auipc	ra,0xffffd
    80004486:	786080e7          	jalr	1926(ra) # 80001c08 <myproc>
    8000448a:	15053503          	ld	a0,336(a0)
    8000448e:	00000097          	auipc	ra,0x0
    80004492:	9f6080e7          	jalr	-1546(ra) # 80003e84 <idup>
    80004496:	89aa                	mv	s3,a0
  while(*path == '/')
    80004498:	02f00913          	li	s2,47
  len = path - s;
    8000449c:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000449e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800044a0:	4c05                	li	s8,1
    800044a2:	a865                	j	8000455a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800044a4:	4585                	li	a1,1
    800044a6:	4505                	li	a0,1
    800044a8:	fffff097          	auipc	ra,0xfffff
    800044ac:	6e2080e7          	jalr	1762(ra) # 80003b8a <iget>
    800044b0:	89aa                	mv	s3,a0
    800044b2:	b7dd                	j	80004498 <namex+0x42>
      iunlockput(ip);
    800044b4:	854e                	mv	a0,s3
    800044b6:	00000097          	auipc	ra,0x0
    800044ba:	c6e080e7          	jalr	-914(ra) # 80004124 <iunlockput>
      return 0;
    800044be:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800044c0:	854e                	mv	a0,s3
    800044c2:	60e6                	ld	ra,88(sp)
    800044c4:	6446                	ld	s0,80(sp)
    800044c6:	64a6                	ld	s1,72(sp)
    800044c8:	6906                	ld	s2,64(sp)
    800044ca:	79e2                	ld	s3,56(sp)
    800044cc:	7a42                	ld	s4,48(sp)
    800044ce:	7aa2                	ld	s5,40(sp)
    800044d0:	7b02                	ld	s6,32(sp)
    800044d2:	6be2                	ld	s7,24(sp)
    800044d4:	6c42                	ld	s8,16(sp)
    800044d6:	6ca2                	ld	s9,8(sp)
    800044d8:	6125                	addi	sp,sp,96
    800044da:	8082                	ret
      iunlock(ip);
    800044dc:	854e                	mv	a0,s3
    800044de:	00000097          	auipc	ra,0x0
    800044e2:	aa6080e7          	jalr	-1370(ra) # 80003f84 <iunlock>
      return ip;
    800044e6:	bfe9                	j	800044c0 <namex+0x6a>
      iunlockput(ip);
    800044e8:	854e                	mv	a0,s3
    800044ea:	00000097          	auipc	ra,0x0
    800044ee:	c3a080e7          	jalr	-966(ra) # 80004124 <iunlockput>
      return 0;
    800044f2:	89d2                	mv	s3,s4
    800044f4:	b7f1                	j	800044c0 <namex+0x6a>
  len = path - s;
    800044f6:	40b48633          	sub	a2,s1,a1
    800044fa:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800044fe:	094cd463          	bge	s9,s4,80004586 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004502:	4639                	li	a2,14
    80004504:	8556                	mv	a0,s5
    80004506:	ffffd097          	auipc	ra,0xffffd
    8000450a:	95c080e7          	jalr	-1700(ra) # 80000e62 <memmove>
  while(*path == '/')
    8000450e:	0004c783          	lbu	a5,0(s1)
    80004512:	01279763          	bne	a5,s2,80004520 <namex+0xca>
    path++;
    80004516:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004518:	0004c783          	lbu	a5,0(s1)
    8000451c:	ff278de3          	beq	a5,s2,80004516 <namex+0xc0>
    ilock(ip);
    80004520:	854e                	mv	a0,s3
    80004522:	00000097          	auipc	ra,0x0
    80004526:	9a0080e7          	jalr	-1632(ra) # 80003ec2 <ilock>
    if(ip->type != T_DIR){
    8000452a:	04499783          	lh	a5,68(s3)
    8000452e:	f98793e3          	bne	a5,s8,800044b4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004532:	000b0563          	beqz	s6,8000453c <namex+0xe6>
    80004536:	0004c783          	lbu	a5,0(s1)
    8000453a:	d3cd                	beqz	a5,800044dc <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000453c:	865e                	mv	a2,s7
    8000453e:	85d6                	mv	a1,s5
    80004540:	854e                	mv	a0,s3
    80004542:	00000097          	auipc	ra,0x0
    80004546:	e64080e7          	jalr	-412(ra) # 800043a6 <dirlookup>
    8000454a:	8a2a                	mv	s4,a0
    8000454c:	dd51                	beqz	a0,800044e8 <namex+0x92>
    iunlockput(ip);
    8000454e:	854e                	mv	a0,s3
    80004550:	00000097          	auipc	ra,0x0
    80004554:	bd4080e7          	jalr	-1068(ra) # 80004124 <iunlockput>
    ip = next;
    80004558:	89d2                	mv	s3,s4
  while(*path == '/')
    8000455a:	0004c783          	lbu	a5,0(s1)
    8000455e:	05279763          	bne	a5,s2,800045ac <namex+0x156>
    path++;
    80004562:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004564:	0004c783          	lbu	a5,0(s1)
    80004568:	ff278de3          	beq	a5,s2,80004562 <namex+0x10c>
  if(*path == 0)
    8000456c:	c79d                	beqz	a5,8000459a <namex+0x144>
    path++;
    8000456e:	85a6                	mv	a1,s1
  len = path - s;
    80004570:	8a5e                	mv	s4,s7
    80004572:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004574:	01278963          	beq	a5,s2,80004586 <namex+0x130>
    80004578:	dfbd                	beqz	a5,800044f6 <namex+0xa0>
    path++;
    8000457a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000457c:	0004c783          	lbu	a5,0(s1)
    80004580:	ff279ce3          	bne	a5,s2,80004578 <namex+0x122>
    80004584:	bf8d                	j	800044f6 <namex+0xa0>
    memmove(name, s, len);
    80004586:	2601                	sext.w	a2,a2
    80004588:	8556                	mv	a0,s5
    8000458a:	ffffd097          	auipc	ra,0xffffd
    8000458e:	8d8080e7          	jalr	-1832(ra) # 80000e62 <memmove>
    name[len] = 0;
    80004592:	9a56                	add	s4,s4,s5
    80004594:	000a0023          	sb	zero,0(s4)
    80004598:	bf9d                	j	8000450e <namex+0xb8>
  if(nameiparent){
    8000459a:	f20b03e3          	beqz	s6,800044c0 <namex+0x6a>
    iput(ip);
    8000459e:	854e                	mv	a0,s3
    800045a0:	00000097          	auipc	ra,0x0
    800045a4:	adc080e7          	jalr	-1316(ra) # 8000407c <iput>
    return 0;
    800045a8:	4981                	li	s3,0
    800045aa:	bf19                	j	800044c0 <namex+0x6a>
  if(*path == 0)
    800045ac:	d7fd                	beqz	a5,8000459a <namex+0x144>
  while(*path != '/' && *path != 0)
    800045ae:	0004c783          	lbu	a5,0(s1)
    800045b2:	85a6                	mv	a1,s1
    800045b4:	b7d1                	j	80004578 <namex+0x122>

00000000800045b6 <dirlink>:
{
    800045b6:	7139                	addi	sp,sp,-64
    800045b8:	fc06                	sd	ra,56(sp)
    800045ba:	f822                	sd	s0,48(sp)
    800045bc:	f426                	sd	s1,40(sp)
    800045be:	f04a                	sd	s2,32(sp)
    800045c0:	ec4e                	sd	s3,24(sp)
    800045c2:	e852                	sd	s4,16(sp)
    800045c4:	0080                	addi	s0,sp,64
    800045c6:	892a                	mv	s2,a0
    800045c8:	8a2e                	mv	s4,a1
    800045ca:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800045cc:	4601                	li	a2,0
    800045ce:	00000097          	auipc	ra,0x0
    800045d2:	dd8080e7          	jalr	-552(ra) # 800043a6 <dirlookup>
    800045d6:	e93d                	bnez	a0,8000464c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045d8:	04c92483          	lw	s1,76(s2)
    800045dc:	c49d                	beqz	s1,8000460a <dirlink+0x54>
    800045de:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045e0:	4741                	li	a4,16
    800045e2:	86a6                	mv	a3,s1
    800045e4:	fc040613          	addi	a2,s0,-64
    800045e8:	4581                	li	a1,0
    800045ea:	854a                	mv	a0,s2
    800045ec:	00000097          	auipc	ra,0x0
    800045f0:	b8a080e7          	jalr	-1142(ra) # 80004176 <readi>
    800045f4:	47c1                	li	a5,16
    800045f6:	06f51163          	bne	a0,a5,80004658 <dirlink+0xa2>
    if(de.inum == 0)
    800045fa:	fc045783          	lhu	a5,-64(s0)
    800045fe:	c791                	beqz	a5,8000460a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004600:	24c1                	addiw	s1,s1,16
    80004602:	04c92783          	lw	a5,76(s2)
    80004606:	fcf4ede3          	bltu	s1,a5,800045e0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000460a:	4639                	li	a2,14
    8000460c:	85d2                	mv	a1,s4
    8000460e:	fc240513          	addi	a0,s0,-62
    80004612:	ffffd097          	auipc	ra,0xffffd
    80004616:	904080e7          	jalr	-1788(ra) # 80000f16 <strncpy>
  de.inum = inum;
    8000461a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000461e:	4741                	li	a4,16
    80004620:	86a6                	mv	a3,s1
    80004622:	fc040613          	addi	a2,s0,-64
    80004626:	4581                	li	a1,0
    80004628:	854a                	mv	a0,s2
    8000462a:	00000097          	auipc	ra,0x0
    8000462e:	c44080e7          	jalr	-956(ra) # 8000426e <writei>
    80004632:	1541                	addi	a0,a0,-16
    80004634:	00a03533          	snez	a0,a0
    80004638:	40a00533          	neg	a0,a0
}
    8000463c:	70e2                	ld	ra,56(sp)
    8000463e:	7442                	ld	s0,48(sp)
    80004640:	74a2                	ld	s1,40(sp)
    80004642:	7902                	ld	s2,32(sp)
    80004644:	69e2                	ld	s3,24(sp)
    80004646:	6a42                	ld	s4,16(sp)
    80004648:	6121                	addi	sp,sp,64
    8000464a:	8082                	ret
    iput(ip);
    8000464c:	00000097          	auipc	ra,0x0
    80004650:	a30080e7          	jalr	-1488(ra) # 8000407c <iput>
    return -1;
    80004654:	557d                	li	a0,-1
    80004656:	b7dd                	j	8000463c <dirlink+0x86>
      panic("dirlink read");
    80004658:	00004517          	auipc	a0,0x4
    8000465c:	0b850513          	addi	a0,a0,184 # 80008710 <syscalls+0x1e0>
    80004660:	ffffc097          	auipc	ra,0xffffc
    80004664:	ee4080e7          	jalr	-284(ra) # 80000544 <panic>

0000000080004668 <namei>:

struct inode*
namei(char *path)
{
    80004668:	1101                	addi	sp,sp,-32
    8000466a:	ec06                	sd	ra,24(sp)
    8000466c:	e822                	sd	s0,16(sp)
    8000466e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004670:	fe040613          	addi	a2,s0,-32
    80004674:	4581                	li	a1,0
    80004676:	00000097          	auipc	ra,0x0
    8000467a:	de0080e7          	jalr	-544(ra) # 80004456 <namex>
}
    8000467e:	60e2                	ld	ra,24(sp)
    80004680:	6442                	ld	s0,16(sp)
    80004682:	6105                	addi	sp,sp,32
    80004684:	8082                	ret

0000000080004686 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004686:	1141                	addi	sp,sp,-16
    80004688:	e406                	sd	ra,8(sp)
    8000468a:	e022                	sd	s0,0(sp)
    8000468c:	0800                	addi	s0,sp,16
    8000468e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004690:	4585                	li	a1,1
    80004692:	00000097          	auipc	ra,0x0
    80004696:	dc4080e7          	jalr	-572(ra) # 80004456 <namex>
}
    8000469a:	60a2                	ld	ra,8(sp)
    8000469c:	6402                	ld	s0,0(sp)
    8000469e:	0141                	addi	sp,sp,16
    800046a0:	8082                	ret

00000000800046a2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800046a2:	1101                	addi	sp,sp,-32
    800046a4:	ec06                	sd	ra,24(sp)
    800046a6:	e822                	sd	s0,16(sp)
    800046a8:	e426                	sd	s1,8(sp)
    800046aa:	e04a                	sd	s2,0(sp)
    800046ac:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800046ae:	0023d917          	auipc	s2,0x23d
    800046b2:	f6a90913          	addi	s2,s2,-150 # 80241618 <log>
    800046b6:	01892583          	lw	a1,24(s2)
    800046ba:	02892503          	lw	a0,40(s2)
    800046be:	fffff097          	auipc	ra,0xfffff
    800046c2:	fea080e7          	jalr	-22(ra) # 800036a8 <bread>
    800046c6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800046c8:	02c92683          	lw	a3,44(s2)
    800046cc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800046ce:	02d05763          	blez	a3,800046fc <write_head+0x5a>
    800046d2:	0023d797          	auipc	a5,0x23d
    800046d6:	f7678793          	addi	a5,a5,-138 # 80241648 <log+0x30>
    800046da:	05c50713          	addi	a4,a0,92
    800046de:	36fd                	addiw	a3,a3,-1
    800046e0:	1682                	slli	a3,a3,0x20
    800046e2:	9281                	srli	a3,a3,0x20
    800046e4:	068a                	slli	a3,a3,0x2
    800046e6:	0023d617          	auipc	a2,0x23d
    800046ea:	f6660613          	addi	a2,a2,-154 # 8024164c <log+0x34>
    800046ee:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800046f0:	4390                	lw	a2,0(a5)
    800046f2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800046f4:	0791                	addi	a5,a5,4
    800046f6:	0711                	addi	a4,a4,4
    800046f8:	fed79ce3          	bne	a5,a3,800046f0 <write_head+0x4e>
  }
  bwrite(buf);
    800046fc:	8526                	mv	a0,s1
    800046fe:	fffff097          	auipc	ra,0xfffff
    80004702:	09c080e7          	jalr	156(ra) # 8000379a <bwrite>
  brelse(buf);
    80004706:	8526                	mv	a0,s1
    80004708:	fffff097          	auipc	ra,0xfffff
    8000470c:	0d0080e7          	jalr	208(ra) # 800037d8 <brelse>
}
    80004710:	60e2                	ld	ra,24(sp)
    80004712:	6442                	ld	s0,16(sp)
    80004714:	64a2                	ld	s1,8(sp)
    80004716:	6902                	ld	s2,0(sp)
    80004718:	6105                	addi	sp,sp,32
    8000471a:	8082                	ret

000000008000471c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000471c:	0023d797          	auipc	a5,0x23d
    80004720:	f287a783          	lw	a5,-216(a5) # 80241644 <log+0x2c>
    80004724:	0af05d63          	blez	a5,800047de <install_trans+0xc2>
{
    80004728:	7139                	addi	sp,sp,-64
    8000472a:	fc06                	sd	ra,56(sp)
    8000472c:	f822                	sd	s0,48(sp)
    8000472e:	f426                	sd	s1,40(sp)
    80004730:	f04a                	sd	s2,32(sp)
    80004732:	ec4e                	sd	s3,24(sp)
    80004734:	e852                	sd	s4,16(sp)
    80004736:	e456                	sd	s5,8(sp)
    80004738:	e05a                	sd	s6,0(sp)
    8000473a:	0080                	addi	s0,sp,64
    8000473c:	8b2a                	mv	s6,a0
    8000473e:	0023da97          	auipc	s5,0x23d
    80004742:	f0aa8a93          	addi	s5,s5,-246 # 80241648 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004746:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004748:	0023d997          	auipc	s3,0x23d
    8000474c:	ed098993          	addi	s3,s3,-304 # 80241618 <log>
    80004750:	a035                	j	8000477c <install_trans+0x60>
      bunpin(dbuf);
    80004752:	8526                	mv	a0,s1
    80004754:	fffff097          	auipc	ra,0xfffff
    80004758:	15e080e7          	jalr	350(ra) # 800038b2 <bunpin>
    brelse(lbuf);
    8000475c:	854a                	mv	a0,s2
    8000475e:	fffff097          	auipc	ra,0xfffff
    80004762:	07a080e7          	jalr	122(ra) # 800037d8 <brelse>
    brelse(dbuf);
    80004766:	8526                	mv	a0,s1
    80004768:	fffff097          	auipc	ra,0xfffff
    8000476c:	070080e7          	jalr	112(ra) # 800037d8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004770:	2a05                	addiw	s4,s4,1
    80004772:	0a91                	addi	s5,s5,4
    80004774:	02c9a783          	lw	a5,44(s3)
    80004778:	04fa5963          	bge	s4,a5,800047ca <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000477c:	0189a583          	lw	a1,24(s3)
    80004780:	014585bb          	addw	a1,a1,s4
    80004784:	2585                	addiw	a1,a1,1
    80004786:	0289a503          	lw	a0,40(s3)
    8000478a:	fffff097          	auipc	ra,0xfffff
    8000478e:	f1e080e7          	jalr	-226(ra) # 800036a8 <bread>
    80004792:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004794:	000aa583          	lw	a1,0(s5)
    80004798:	0289a503          	lw	a0,40(s3)
    8000479c:	fffff097          	auipc	ra,0xfffff
    800047a0:	f0c080e7          	jalr	-244(ra) # 800036a8 <bread>
    800047a4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800047a6:	40000613          	li	a2,1024
    800047aa:	05890593          	addi	a1,s2,88
    800047ae:	05850513          	addi	a0,a0,88
    800047b2:	ffffc097          	auipc	ra,0xffffc
    800047b6:	6b0080e7          	jalr	1712(ra) # 80000e62 <memmove>
    bwrite(dbuf);  // write dst to disk
    800047ba:	8526                	mv	a0,s1
    800047bc:	fffff097          	auipc	ra,0xfffff
    800047c0:	fde080e7          	jalr	-34(ra) # 8000379a <bwrite>
    if(recovering == 0)
    800047c4:	f80b1ce3          	bnez	s6,8000475c <install_trans+0x40>
    800047c8:	b769                	j	80004752 <install_trans+0x36>
}
    800047ca:	70e2                	ld	ra,56(sp)
    800047cc:	7442                	ld	s0,48(sp)
    800047ce:	74a2                	ld	s1,40(sp)
    800047d0:	7902                	ld	s2,32(sp)
    800047d2:	69e2                	ld	s3,24(sp)
    800047d4:	6a42                	ld	s4,16(sp)
    800047d6:	6aa2                	ld	s5,8(sp)
    800047d8:	6b02                	ld	s6,0(sp)
    800047da:	6121                	addi	sp,sp,64
    800047dc:	8082                	ret
    800047de:	8082                	ret

00000000800047e0 <initlog>:
{
    800047e0:	7179                	addi	sp,sp,-48
    800047e2:	f406                	sd	ra,40(sp)
    800047e4:	f022                	sd	s0,32(sp)
    800047e6:	ec26                	sd	s1,24(sp)
    800047e8:	e84a                	sd	s2,16(sp)
    800047ea:	e44e                	sd	s3,8(sp)
    800047ec:	1800                	addi	s0,sp,48
    800047ee:	892a                	mv	s2,a0
    800047f0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800047f2:	0023d497          	auipc	s1,0x23d
    800047f6:	e2648493          	addi	s1,s1,-474 # 80241618 <log>
    800047fa:	00004597          	auipc	a1,0x4
    800047fe:	f2658593          	addi	a1,a1,-218 # 80008720 <syscalls+0x1f0>
    80004802:	8526                	mv	a0,s1
    80004804:	ffffc097          	auipc	ra,0xffffc
    80004808:	472080e7          	jalr	1138(ra) # 80000c76 <initlock>
  log.start = sb->logstart;
    8000480c:	0149a583          	lw	a1,20(s3)
    80004810:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004812:	0109a783          	lw	a5,16(s3)
    80004816:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004818:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000481c:	854a                	mv	a0,s2
    8000481e:	fffff097          	auipc	ra,0xfffff
    80004822:	e8a080e7          	jalr	-374(ra) # 800036a8 <bread>
  log.lh.n = lh->n;
    80004826:	4d3c                	lw	a5,88(a0)
    80004828:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000482a:	02f05563          	blez	a5,80004854 <initlog+0x74>
    8000482e:	05c50713          	addi	a4,a0,92
    80004832:	0023d697          	auipc	a3,0x23d
    80004836:	e1668693          	addi	a3,a3,-490 # 80241648 <log+0x30>
    8000483a:	37fd                	addiw	a5,a5,-1
    8000483c:	1782                	slli	a5,a5,0x20
    8000483e:	9381                	srli	a5,a5,0x20
    80004840:	078a                	slli	a5,a5,0x2
    80004842:	06050613          	addi	a2,a0,96
    80004846:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004848:	4310                	lw	a2,0(a4)
    8000484a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000484c:	0711                	addi	a4,a4,4
    8000484e:	0691                	addi	a3,a3,4
    80004850:	fef71ce3          	bne	a4,a5,80004848 <initlog+0x68>
  brelse(buf);
    80004854:	fffff097          	auipc	ra,0xfffff
    80004858:	f84080e7          	jalr	-124(ra) # 800037d8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000485c:	4505                	li	a0,1
    8000485e:	00000097          	auipc	ra,0x0
    80004862:	ebe080e7          	jalr	-322(ra) # 8000471c <install_trans>
  log.lh.n = 0;
    80004866:	0023d797          	auipc	a5,0x23d
    8000486a:	dc07af23          	sw	zero,-546(a5) # 80241644 <log+0x2c>
  write_head(); // clear the log
    8000486e:	00000097          	auipc	ra,0x0
    80004872:	e34080e7          	jalr	-460(ra) # 800046a2 <write_head>
}
    80004876:	70a2                	ld	ra,40(sp)
    80004878:	7402                	ld	s0,32(sp)
    8000487a:	64e2                	ld	s1,24(sp)
    8000487c:	6942                	ld	s2,16(sp)
    8000487e:	69a2                	ld	s3,8(sp)
    80004880:	6145                	addi	sp,sp,48
    80004882:	8082                	ret

0000000080004884 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004884:	1101                	addi	sp,sp,-32
    80004886:	ec06                	sd	ra,24(sp)
    80004888:	e822                	sd	s0,16(sp)
    8000488a:	e426                	sd	s1,8(sp)
    8000488c:	e04a                	sd	s2,0(sp)
    8000488e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004890:	0023d517          	auipc	a0,0x23d
    80004894:	d8850513          	addi	a0,a0,-632 # 80241618 <log>
    80004898:	ffffc097          	auipc	ra,0xffffc
    8000489c:	46e080e7          	jalr	1134(ra) # 80000d06 <acquire>
  while(1){
    if(log.committing){
    800048a0:	0023d497          	auipc	s1,0x23d
    800048a4:	d7848493          	addi	s1,s1,-648 # 80241618 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800048a8:	4979                	li	s2,30
    800048aa:	a039                	j	800048b8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800048ac:	85a6                	mv	a1,s1
    800048ae:	8526                	mv	a0,s1
    800048b0:	ffffe097          	auipc	ra,0xffffe
    800048b4:	b98080e7          	jalr	-1128(ra) # 80002448 <sleep>
    if(log.committing){
    800048b8:	50dc                	lw	a5,36(s1)
    800048ba:	fbed                	bnez	a5,800048ac <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800048bc:	509c                	lw	a5,32(s1)
    800048be:	0017871b          	addiw	a4,a5,1
    800048c2:	0007069b          	sext.w	a3,a4
    800048c6:	0027179b          	slliw	a5,a4,0x2
    800048ca:	9fb9                	addw	a5,a5,a4
    800048cc:	0017979b          	slliw	a5,a5,0x1
    800048d0:	54d8                	lw	a4,44(s1)
    800048d2:	9fb9                	addw	a5,a5,a4
    800048d4:	00f95963          	bge	s2,a5,800048e6 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800048d8:	85a6                	mv	a1,s1
    800048da:	8526                	mv	a0,s1
    800048dc:	ffffe097          	auipc	ra,0xffffe
    800048e0:	b6c080e7          	jalr	-1172(ra) # 80002448 <sleep>
    800048e4:	bfd1                	j	800048b8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800048e6:	0023d517          	auipc	a0,0x23d
    800048ea:	d3250513          	addi	a0,a0,-718 # 80241618 <log>
    800048ee:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	4ca080e7          	jalr	1226(ra) # 80000dba <release>
      break;
    }
  }
}
    800048f8:	60e2                	ld	ra,24(sp)
    800048fa:	6442                	ld	s0,16(sp)
    800048fc:	64a2                	ld	s1,8(sp)
    800048fe:	6902                	ld	s2,0(sp)
    80004900:	6105                	addi	sp,sp,32
    80004902:	8082                	ret

0000000080004904 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004904:	7139                	addi	sp,sp,-64
    80004906:	fc06                	sd	ra,56(sp)
    80004908:	f822                	sd	s0,48(sp)
    8000490a:	f426                	sd	s1,40(sp)
    8000490c:	f04a                	sd	s2,32(sp)
    8000490e:	ec4e                	sd	s3,24(sp)
    80004910:	e852                	sd	s4,16(sp)
    80004912:	e456                	sd	s5,8(sp)
    80004914:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004916:	0023d497          	auipc	s1,0x23d
    8000491a:	d0248493          	addi	s1,s1,-766 # 80241618 <log>
    8000491e:	8526                	mv	a0,s1
    80004920:	ffffc097          	auipc	ra,0xffffc
    80004924:	3e6080e7          	jalr	998(ra) # 80000d06 <acquire>
  log.outstanding -= 1;
    80004928:	509c                	lw	a5,32(s1)
    8000492a:	37fd                	addiw	a5,a5,-1
    8000492c:	0007891b          	sext.w	s2,a5
    80004930:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004932:	50dc                	lw	a5,36(s1)
    80004934:	efb9                	bnez	a5,80004992 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004936:	06091663          	bnez	s2,800049a2 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000493a:	0023d497          	auipc	s1,0x23d
    8000493e:	cde48493          	addi	s1,s1,-802 # 80241618 <log>
    80004942:	4785                	li	a5,1
    80004944:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004946:	8526                	mv	a0,s1
    80004948:	ffffc097          	auipc	ra,0xffffc
    8000494c:	472080e7          	jalr	1138(ra) # 80000dba <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004950:	54dc                	lw	a5,44(s1)
    80004952:	06f04763          	bgtz	a5,800049c0 <end_op+0xbc>
    acquire(&log.lock);
    80004956:	0023d497          	auipc	s1,0x23d
    8000495a:	cc248493          	addi	s1,s1,-830 # 80241618 <log>
    8000495e:	8526                	mv	a0,s1
    80004960:	ffffc097          	auipc	ra,0xffffc
    80004964:	3a6080e7          	jalr	934(ra) # 80000d06 <acquire>
    log.committing = 0;
    80004968:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000496c:	8526                	mv	a0,s1
    8000496e:	ffffe097          	auipc	ra,0xffffe
    80004972:	b3e080e7          	jalr	-1218(ra) # 800024ac <wakeup>
    release(&log.lock);
    80004976:	8526                	mv	a0,s1
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	442080e7          	jalr	1090(ra) # 80000dba <release>
}
    80004980:	70e2                	ld	ra,56(sp)
    80004982:	7442                	ld	s0,48(sp)
    80004984:	74a2                	ld	s1,40(sp)
    80004986:	7902                	ld	s2,32(sp)
    80004988:	69e2                	ld	s3,24(sp)
    8000498a:	6a42                	ld	s4,16(sp)
    8000498c:	6aa2                	ld	s5,8(sp)
    8000498e:	6121                	addi	sp,sp,64
    80004990:	8082                	ret
    panic("log.committing");
    80004992:	00004517          	auipc	a0,0x4
    80004996:	d9650513          	addi	a0,a0,-618 # 80008728 <syscalls+0x1f8>
    8000499a:	ffffc097          	auipc	ra,0xffffc
    8000499e:	baa080e7          	jalr	-1110(ra) # 80000544 <panic>
    wakeup(&log);
    800049a2:	0023d497          	auipc	s1,0x23d
    800049a6:	c7648493          	addi	s1,s1,-906 # 80241618 <log>
    800049aa:	8526                	mv	a0,s1
    800049ac:	ffffe097          	auipc	ra,0xffffe
    800049b0:	b00080e7          	jalr	-1280(ra) # 800024ac <wakeup>
  release(&log.lock);
    800049b4:	8526                	mv	a0,s1
    800049b6:	ffffc097          	auipc	ra,0xffffc
    800049ba:	404080e7          	jalr	1028(ra) # 80000dba <release>
  if(do_commit){
    800049be:	b7c9                	j	80004980 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049c0:	0023da97          	auipc	s5,0x23d
    800049c4:	c88a8a93          	addi	s5,s5,-888 # 80241648 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800049c8:	0023da17          	auipc	s4,0x23d
    800049cc:	c50a0a13          	addi	s4,s4,-944 # 80241618 <log>
    800049d0:	018a2583          	lw	a1,24(s4)
    800049d4:	012585bb          	addw	a1,a1,s2
    800049d8:	2585                	addiw	a1,a1,1
    800049da:	028a2503          	lw	a0,40(s4)
    800049de:	fffff097          	auipc	ra,0xfffff
    800049e2:	cca080e7          	jalr	-822(ra) # 800036a8 <bread>
    800049e6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800049e8:	000aa583          	lw	a1,0(s5)
    800049ec:	028a2503          	lw	a0,40(s4)
    800049f0:	fffff097          	auipc	ra,0xfffff
    800049f4:	cb8080e7          	jalr	-840(ra) # 800036a8 <bread>
    800049f8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800049fa:	40000613          	li	a2,1024
    800049fe:	05850593          	addi	a1,a0,88
    80004a02:	05848513          	addi	a0,s1,88
    80004a06:	ffffc097          	auipc	ra,0xffffc
    80004a0a:	45c080e7          	jalr	1116(ra) # 80000e62 <memmove>
    bwrite(to);  // write the log
    80004a0e:	8526                	mv	a0,s1
    80004a10:	fffff097          	auipc	ra,0xfffff
    80004a14:	d8a080e7          	jalr	-630(ra) # 8000379a <bwrite>
    brelse(from);
    80004a18:	854e                	mv	a0,s3
    80004a1a:	fffff097          	auipc	ra,0xfffff
    80004a1e:	dbe080e7          	jalr	-578(ra) # 800037d8 <brelse>
    brelse(to);
    80004a22:	8526                	mv	a0,s1
    80004a24:	fffff097          	auipc	ra,0xfffff
    80004a28:	db4080e7          	jalr	-588(ra) # 800037d8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a2c:	2905                	addiw	s2,s2,1
    80004a2e:	0a91                	addi	s5,s5,4
    80004a30:	02ca2783          	lw	a5,44(s4)
    80004a34:	f8f94ee3          	blt	s2,a5,800049d0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004a38:	00000097          	auipc	ra,0x0
    80004a3c:	c6a080e7          	jalr	-918(ra) # 800046a2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004a40:	4501                	li	a0,0
    80004a42:	00000097          	auipc	ra,0x0
    80004a46:	cda080e7          	jalr	-806(ra) # 8000471c <install_trans>
    log.lh.n = 0;
    80004a4a:	0023d797          	auipc	a5,0x23d
    80004a4e:	be07ad23          	sw	zero,-1030(a5) # 80241644 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004a52:	00000097          	auipc	ra,0x0
    80004a56:	c50080e7          	jalr	-944(ra) # 800046a2 <write_head>
    80004a5a:	bdf5                	j	80004956 <end_op+0x52>

0000000080004a5c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a5c:	1101                	addi	sp,sp,-32
    80004a5e:	ec06                	sd	ra,24(sp)
    80004a60:	e822                	sd	s0,16(sp)
    80004a62:	e426                	sd	s1,8(sp)
    80004a64:	e04a                	sd	s2,0(sp)
    80004a66:	1000                	addi	s0,sp,32
    80004a68:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a6a:	0023d917          	auipc	s2,0x23d
    80004a6e:	bae90913          	addi	s2,s2,-1106 # 80241618 <log>
    80004a72:	854a                	mv	a0,s2
    80004a74:	ffffc097          	auipc	ra,0xffffc
    80004a78:	292080e7          	jalr	658(ra) # 80000d06 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004a7c:	02c92603          	lw	a2,44(s2)
    80004a80:	47f5                	li	a5,29
    80004a82:	06c7c563          	blt	a5,a2,80004aec <log_write+0x90>
    80004a86:	0023d797          	auipc	a5,0x23d
    80004a8a:	bae7a783          	lw	a5,-1106(a5) # 80241634 <log+0x1c>
    80004a8e:	37fd                	addiw	a5,a5,-1
    80004a90:	04f65e63          	bge	a2,a5,80004aec <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a94:	0023d797          	auipc	a5,0x23d
    80004a98:	ba47a783          	lw	a5,-1116(a5) # 80241638 <log+0x20>
    80004a9c:	06f05063          	blez	a5,80004afc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004aa0:	4781                	li	a5,0
    80004aa2:	06c05563          	blez	a2,80004b0c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004aa6:	44cc                	lw	a1,12(s1)
    80004aa8:	0023d717          	auipc	a4,0x23d
    80004aac:	ba070713          	addi	a4,a4,-1120 # 80241648 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004ab0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004ab2:	4314                	lw	a3,0(a4)
    80004ab4:	04b68c63          	beq	a3,a1,80004b0c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004ab8:	2785                	addiw	a5,a5,1
    80004aba:	0711                	addi	a4,a4,4
    80004abc:	fef61be3          	bne	a2,a5,80004ab2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004ac0:	0621                	addi	a2,a2,8
    80004ac2:	060a                	slli	a2,a2,0x2
    80004ac4:	0023d797          	auipc	a5,0x23d
    80004ac8:	b5478793          	addi	a5,a5,-1196 # 80241618 <log>
    80004acc:	963e                	add	a2,a2,a5
    80004ace:	44dc                	lw	a5,12(s1)
    80004ad0:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004ad2:	8526                	mv	a0,s1
    80004ad4:	fffff097          	auipc	ra,0xfffff
    80004ad8:	da2080e7          	jalr	-606(ra) # 80003876 <bpin>
    log.lh.n++;
    80004adc:	0023d717          	auipc	a4,0x23d
    80004ae0:	b3c70713          	addi	a4,a4,-1220 # 80241618 <log>
    80004ae4:	575c                	lw	a5,44(a4)
    80004ae6:	2785                	addiw	a5,a5,1
    80004ae8:	d75c                	sw	a5,44(a4)
    80004aea:	a835                	j	80004b26 <log_write+0xca>
    panic("too big a transaction");
    80004aec:	00004517          	auipc	a0,0x4
    80004af0:	c4c50513          	addi	a0,a0,-948 # 80008738 <syscalls+0x208>
    80004af4:	ffffc097          	auipc	ra,0xffffc
    80004af8:	a50080e7          	jalr	-1456(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004afc:	00004517          	auipc	a0,0x4
    80004b00:	c5450513          	addi	a0,a0,-940 # 80008750 <syscalls+0x220>
    80004b04:	ffffc097          	auipc	ra,0xffffc
    80004b08:	a40080e7          	jalr	-1472(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004b0c:	00878713          	addi	a4,a5,8
    80004b10:	00271693          	slli	a3,a4,0x2
    80004b14:	0023d717          	auipc	a4,0x23d
    80004b18:	b0470713          	addi	a4,a4,-1276 # 80241618 <log>
    80004b1c:	9736                	add	a4,a4,a3
    80004b1e:	44d4                	lw	a3,12(s1)
    80004b20:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004b22:	faf608e3          	beq	a2,a5,80004ad2 <log_write+0x76>
  }
  release(&log.lock);
    80004b26:	0023d517          	auipc	a0,0x23d
    80004b2a:	af250513          	addi	a0,a0,-1294 # 80241618 <log>
    80004b2e:	ffffc097          	auipc	ra,0xffffc
    80004b32:	28c080e7          	jalr	652(ra) # 80000dba <release>
}
    80004b36:	60e2                	ld	ra,24(sp)
    80004b38:	6442                	ld	s0,16(sp)
    80004b3a:	64a2                	ld	s1,8(sp)
    80004b3c:	6902                	ld	s2,0(sp)
    80004b3e:	6105                	addi	sp,sp,32
    80004b40:	8082                	ret

0000000080004b42 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b42:	1101                	addi	sp,sp,-32
    80004b44:	ec06                	sd	ra,24(sp)
    80004b46:	e822                	sd	s0,16(sp)
    80004b48:	e426                	sd	s1,8(sp)
    80004b4a:	e04a                	sd	s2,0(sp)
    80004b4c:	1000                	addi	s0,sp,32
    80004b4e:	84aa                	mv	s1,a0
    80004b50:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b52:	00004597          	auipc	a1,0x4
    80004b56:	c1e58593          	addi	a1,a1,-994 # 80008770 <syscalls+0x240>
    80004b5a:	0521                	addi	a0,a0,8
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	11a080e7          	jalr	282(ra) # 80000c76 <initlock>
  lk->name = name;
    80004b64:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b68:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b6c:	0204a423          	sw	zero,40(s1)
}
    80004b70:	60e2                	ld	ra,24(sp)
    80004b72:	6442                	ld	s0,16(sp)
    80004b74:	64a2                	ld	s1,8(sp)
    80004b76:	6902                	ld	s2,0(sp)
    80004b78:	6105                	addi	sp,sp,32
    80004b7a:	8082                	ret

0000000080004b7c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004b7c:	1101                	addi	sp,sp,-32
    80004b7e:	ec06                	sd	ra,24(sp)
    80004b80:	e822                	sd	s0,16(sp)
    80004b82:	e426                	sd	s1,8(sp)
    80004b84:	e04a                	sd	s2,0(sp)
    80004b86:	1000                	addi	s0,sp,32
    80004b88:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b8a:	00850913          	addi	s2,a0,8
    80004b8e:	854a                	mv	a0,s2
    80004b90:	ffffc097          	auipc	ra,0xffffc
    80004b94:	176080e7          	jalr	374(ra) # 80000d06 <acquire>
  while (lk->locked) {
    80004b98:	409c                	lw	a5,0(s1)
    80004b9a:	cb89                	beqz	a5,80004bac <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004b9c:	85ca                	mv	a1,s2
    80004b9e:	8526                	mv	a0,s1
    80004ba0:	ffffe097          	auipc	ra,0xffffe
    80004ba4:	8a8080e7          	jalr	-1880(ra) # 80002448 <sleep>
  while (lk->locked) {
    80004ba8:	409c                	lw	a5,0(s1)
    80004baa:	fbed                	bnez	a5,80004b9c <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004bac:	4785                	li	a5,1
    80004bae:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004bb0:	ffffd097          	auipc	ra,0xffffd
    80004bb4:	058080e7          	jalr	88(ra) # 80001c08 <myproc>
    80004bb8:	591c                	lw	a5,48(a0)
    80004bba:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004bbc:	854a                	mv	a0,s2
    80004bbe:	ffffc097          	auipc	ra,0xffffc
    80004bc2:	1fc080e7          	jalr	508(ra) # 80000dba <release>
}
    80004bc6:	60e2                	ld	ra,24(sp)
    80004bc8:	6442                	ld	s0,16(sp)
    80004bca:	64a2                	ld	s1,8(sp)
    80004bcc:	6902                	ld	s2,0(sp)
    80004bce:	6105                	addi	sp,sp,32
    80004bd0:	8082                	ret

0000000080004bd2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004bd2:	1101                	addi	sp,sp,-32
    80004bd4:	ec06                	sd	ra,24(sp)
    80004bd6:	e822                	sd	s0,16(sp)
    80004bd8:	e426                	sd	s1,8(sp)
    80004bda:	e04a                	sd	s2,0(sp)
    80004bdc:	1000                	addi	s0,sp,32
    80004bde:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004be0:	00850913          	addi	s2,a0,8
    80004be4:	854a                	mv	a0,s2
    80004be6:	ffffc097          	auipc	ra,0xffffc
    80004bea:	120080e7          	jalr	288(ra) # 80000d06 <acquire>
  lk->locked = 0;
    80004bee:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004bf2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004bf6:	8526                	mv	a0,s1
    80004bf8:	ffffe097          	auipc	ra,0xffffe
    80004bfc:	8b4080e7          	jalr	-1868(ra) # 800024ac <wakeup>
  release(&lk->lk);
    80004c00:	854a                	mv	a0,s2
    80004c02:	ffffc097          	auipc	ra,0xffffc
    80004c06:	1b8080e7          	jalr	440(ra) # 80000dba <release>
}
    80004c0a:	60e2                	ld	ra,24(sp)
    80004c0c:	6442                	ld	s0,16(sp)
    80004c0e:	64a2                	ld	s1,8(sp)
    80004c10:	6902                	ld	s2,0(sp)
    80004c12:	6105                	addi	sp,sp,32
    80004c14:	8082                	ret

0000000080004c16 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004c16:	7179                	addi	sp,sp,-48
    80004c18:	f406                	sd	ra,40(sp)
    80004c1a:	f022                	sd	s0,32(sp)
    80004c1c:	ec26                	sd	s1,24(sp)
    80004c1e:	e84a                	sd	s2,16(sp)
    80004c20:	e44e                	sd	s3,8(sp)
    80004c22:	1800                	addi	s0,sp,48
    80004c24:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c26:	00850913          	addi	s2,a0,8
    80004c2a:	854a                	mv	a0,s2
    80004c2c:	ffffc097          	auipc	ra,0xffffc
    80004c30:	0da080e7          	jalr	218(ra) # 80000d06 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c34:	409c                	lw	a5,0(s1)
    80004c36:	ef99                	bnez	a5,80004c54 <holdingsleep+0x3e>
    80004c38:	4481                	li	s1,0
  release(&lk->lk);
    80004c3a:	854a                	mv	a0,s2
    80004c3c:	ffffc097          	auipc	ra,0xffffc
    80004c40:	17e080e7          	jalr	382(ra) # 80000dba <release>
  return r;
}
    80004c44:	8526                	mv	a0,s1
    80004c46:	70a2                	ld	ra,40(sp)
    80004c48:	7402                	ld	s0,32(sp)
    80004c4a:	64e2                	ld	s1,24(sp)
    80004c4c:	6942                	ld	s2,16(sp)
    80004c4e:	69a2                	ld	s3,8(sp)
    80004c50:	6145                	addi	sp,sp,48
    80004c52:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c54:	0284a983          	lw	s3,40(s1)
    80004c58:	ffffd097          	auipc	ra,0xffffd
    80004c5c:	fb0080e7          	jalr	-80(ra) # 80001c08 <myproc>
    80004c60:	5904                	lw	s1,48(a0)
    80004c62:	413484b3          	sub	s1,s1,s3
    80004c66:	0014b493          	seqz	s1,s1
    80004c6a:	bfc1                	j	80004c3a <holdingsleep+0x24>

0000000080004c6c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004c6c:	1141                	addi	sp,sp,-16
    80004c6e:	e406                	sd	ra,8(sp)
    80004c70:	e022                	sd	s0,0(sp)
    80004c72:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004c74:	00004597          	auipc	a1,0x4
    80004c78:	b0c58593          	addi	a1,a1,-1268 # 80008780 <syscalls+0x250>
    80004c7c:	0023d517          	auipc	a0,0x23d
    80004c80:	ae450513          	addi	a0,a0,-1308 # 80241760 <ftable>
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	ff2080e7          	jalr	-14(ra) # 80000c76 <initlock>
}
    80004c8c:	60a2                	ld	ra,8(sp)
    80004c8e:	6402                	ld	s0,0(sp)
    80004c90:	0141                	addi	sp,sp,16
    80004c92:	8082                	ret

0000000080004c94 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c94:	1101                	addi	sp,sp,-32
    80004c96:	ec06                	sd	ra,24(sp)
    80004c98:	e822                	sd	s0,16(sp)
    80004c9a:	e426                	sd	s1,8(sp)
    80004c9c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c9e:	0023d517          	auipc	a0,0x23d
    80004ca2:	ac250513          	addi	a0,a0,-1342 # 80241760 <ftable>
    80004ca6:	ffffc097          	auipc	ra,0xffffc
    80004caa:	060080e7          	jalr	96(ra) # 80000d06 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004cae:	0023d497          	auipc	s1,0x23d
    80004cb2:	aca48493          	addi	s1,s1,-1334 # 80241778 <ftable+0x18>
    80004cb6:	0023e717          	auipc	a4,0x23e
    80004cba:	a6270713          	addi	a4,a4,-1438 # 80242718 <disk>
    if(f->ref == 0){
    80004cbe:	40dc                	lw	a5,4(s1)
    80004cc0:	cf99                	beqz	a5,80004cde <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004cc2:	02848493          	addi	s1,s1,40
    80004cc6:	fee49ce3          	bne	s1,a4,80004cbe <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004cca:	0023d517          	auipc	a0,0x23d
    80004cce:	a9650513          	addi	a0,a0,-1386 # 80241760 <ftable>
    80004cd2:	ffffc097          	auipc	ra,0xffffc
    80004cd6:	0e8080e7          	jalr	232(ra) # 80000dba <release>
  return 0;
    80004cda:	4481                	li	s1,0
    80004cdc:	a819                	j	80004cf2 <filealloc+0x5e>
      f->ref = 1;
    80004cde:	4785                	li	a5,1
    80004ce0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004ce2:	0023d517          	auipc	a0,0x23d
    80004ce6:	a7e50513          	addi	a0,a0,-1410 # 80241760 <ftable>
    80004cea:	ffffc097          	auipc	ra,0xffffc
    80004cee:	0d0080e7          	jalr	208(ra) # 80000dba <release>
}
    80004cf2:	8526                	mv	a0,s1
    80004cf4:	60e2                	ld	ra,24(sp)
    80004cf6:	6442                	ld	s0,16(sp)
    80004cf8:	64a2                	ld	s1,8(sp)
    80004cfa:	6105                	addi	sp,sp,32
    80004cfc:	8082                	ret

0000000080004cfe <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004cfe:	1101                	addi	sp,sp,-32
    80004d00:	ec06                	sd	ra,24(sp)
    80004d02:	e822                	sd	s0,16(sp)
    80004d04:	e426                	sd	s1,8(sp)
    80004d06:	1000                	addi	s0,sp,32
    80004d08:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004d0a:	0023d517          	auipc	a0,0x23d
    80004d0e:	a5650513          	addi	a0,a0,-1450 # 80241760 <ftable>
    80004d12:	ffffc097          	auipc	ra,0xffffc
    80004d16:	ff4080e7          	jalr	-12(ra) # 80000d06 <acquire>
  if(f->ref < 1)
    80004d1a:	40dc                	lw	a5,4(s1)
    80004d1c:	02f05263          	blez	a5,80004d40 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004d20:	2785                	addiw	a5,a5,1
    80004d22:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d24:	0023d517          	auipc	a0,0x23d
    80004d28:	a3c50513          	addi	a0,a0,-1476 # 80241760 <ftable>
    80004d2c:	ffffc097          	auipc	ra,0xffffc
    80004d30:	08e080e7          	jalr	142(ra) # 80000dba <release>
  return f;
}
    80004d34:	8526                	mv	a0,s1
    80004d36:	60e2                	ld	ra,24(sp)
    80004d38:	6442                	ld	s0,16(sp)
    80004d3a:	64a2                	ld	s1,8(sp)
    80004d3c:	6105                	addi	sp,sp,32
    80004d3e:	8082                	ret
    panic("filedup");
    80004d40:	00004517          	auipc	a0,0x4
    80004d44:	a4850513          	addi	a0,a0,-1464 # 80008788 <syscalls+0x258>
    80004d48:	ffffb097          	auipc	ra,0xffffb
    80004d4c:	7fc080e7          	jalr	2044(ra) # 80000544 <panic>

0000000080004d50 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004d50:	7139                	addi	sp,sp,-64
    80004d52:	fc06                	sd	ra,56(sp)
    80004d54:	f822                	sd	s0,48(sp)
    80004d56:	f426                	sd	s1,40(sp)
    80004d58:	f04a                	sd	s2,32(sp)
    80004d5a:	ec4e                	sd	s3,24(sp)
    80004d5c:	e852                	sd	s4,16(sp)
    80004d5e:	e456                	sd	s5,8(sp)
    80004d60:	0080                	addi	s0,sp,64
    80004d62:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004d64:	0023d517          	auipc	a0,0x23d
    80004d68:	9fc50513          	addi	a0,a0,-1540 # 80241760 <ftable>
    80004d6c:	ffffc097          	auipc	ra,0xffffc
    80004d70:	f9a080e7          	jalr	-102(ra) # 80000d06 <acquire>
  if(f->ref < 1)
    80004d74:	40dc                	lw	a5,4(s1)
    80004d76:	06f05163          	blez	a5,80004dd8 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004d7a:	37fd                	addiw	a5,a5,-1
    80004d7c:	0007871b          	sext.w	a4,a5
    80004d80:	c0dc                	sw	a5,4(s1)
    80004d82:	06e04363          	bgtz	a4,80004de8 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004d86:	0004a903          	lw	s2,0(s1)
    80004d8a:	0094ca83          	lbu	s5,9(s1)
    80004d8e:	0104ba03          	ld	s4,16(s1)
    80004d92:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d96:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d9a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d9e:	0023d517          	auipc	a0,0x23d
    80004da2:	9c250513          	addi	a0,a0,-1598 # 80241760 <ftable>
    80004da6:	ffffc097          	auipc	ra,0xffffc
    80004daa:	014080e7          	jalr	20(ra) # 80000dba <release>

  if(ff.type == FD_PIPE){
    80004dae:	4785                	li	a5,1
    80004db0:	04f90d63          	beq	s2,a5,80004e0a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004db4:	3979                	addiw	s2,s2,-2
    80004db6:	4785                	li	a5,1
    80004db8:	0527e063          	bltu	a5,s2,80004df8 <fileclose+0xa8>
    begin_op();
    80004dbc:	00000097          	auipc	ra,0x0
    80004dc0:	ac8080e7          	jalr	-1336(ra) # 80004884 <begin_op>
    iput(ff.ip);
    80004dc4:	854e                	mv	a0,s3
    80004dc6:	fffff097          	auipc	ra,0xfffff
    80004dca:	2b6080e7          	jalr	694(ra) # 8000407c <iput>
    end_op();
    80004dce:	00000097          	auipc	ra,0x0
    80004dd2:	b36080e7          	jalr	-1226(ra) # 80004904 <end_op>
    80004dd6:	a00d                	j	80004df8 <fileclose+0xa8>
    panic("fileclose");
    80004dd8:	00004517          	auipc	a0,0x4
    80004ddc:	9b850513          	addi	a0,a0,-1608 # 80008790 <syscalls+0x260>
    80004de0:	ffffb097          	auipc	ra,0xffffb
    80004de4:	764080e7          	jalr	1892(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004de8:	0023d517          	auipc	a0,0x23d
    80004dec:	97850513          	addi	a0,a0,-1672 # 80241760 <ftable>
    80004df0:	ffffc097          	auipc	ra,0xffffc
    80004df4:	fca080e7          	jalr	-54(ra) # 80000dba <release>
  }
}
    80004df8:	70e2                	ld	ra,56(sp)
    80004dfa:	7442                	ld	s0,48(sp)
    80004dfc:	74a2                	ld	s1,40(sp)
    80004dfe:	7902                	ld	s2,32(sp)
    80004e00:	69e2                	ld	s3,24(sp)
    80004e02:	6a42                	ld	s4,16(sp)
    80004e04:	6aa2                	ld	s5,8(sp)
    80004e06:	6121                	addi	sp,sp,64
    80004e08:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004e0a:	85d6                	mv	a1,s5
    80004e0c:	8552                	mv	a0,s4
    80004e0e:	00000097          	auipc	ra,0x0
    80004e12:	34c080e7          	jalr	844(ra) # 8000515a <pipeclose>
    80004e16:	b7cd                	j	80004df8 <fileclose+0xa8>

0000000080004e18 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004e18:	715d                	addi	sp,sp,-80
    80004e1a:	e486                	sd	ra,72(sp)
    80004e1c:	e0a2                	sd	s0,64(sp)
    80004e1e:	fc26                	sd	s1,56(sp)
    80004e20:	f84a                	sd	s2,48(sp)
    80004e22:	f44e                	sd	s3,40(sp)
    80004e24:	0880                	addi	s0,sp,80
    80004e26:	84aa                	mv	s1,a0
    80004e28:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004e2a:	ffffd097          	auipc	ra,0xffffd
    80004e2e:	dde080e7          	jalr	-546(ra) # 80001c08 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004e32:	409c                	lw	a5,0(s1)
    80004e34:	37f9                	addiw	a5,a5,-2
    80004e36:	4705                	li	a4,1
    80004e38:	04f76763          	bltu	a4,a5,80004e86 <filestat+0x6e>
    80004e3c:	892a                	mv	s2,a0
    ilock(f->ip);
    80004e3e:	6c88                	ld	a0,24(s1)
    80004e40:	fffff097          	auipc	ra,0xfffff
    80004e44:	082080e7          	jalr	130(ra) # 80003ec2 <ilock>
    stati(f->ip, &st);
    80004e48:	fb840593          	addi	a1,s0,-72
    80004e4c:	6c88                	ld	a0,24(s1)
    80004e4e:	fffff097          	auipc	ra,0xfffff
    80004e52:	2fe080e7          	jalr	766(ra) # 8000414c <stati>
    iunlock(f->ip);
    80004e56:	6c88                	ld	a0,24(s1)
    80004e58:	fffff097          	auipc	ra,0xfffff
    80004e5c:	12c080e7          	jalr	300(ra) # 80003f84 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004e60:	46e1                	li	a3,24
    80004e62:	fb840613          	addi	a2,s0,-72
    80004e66:	85ce                	mv	a1,s3
    80004e68:	05093503          	ld	a0,80(s2)
    80004e6c:	ffffd097          	auipc	ra,0xffffd
    80004e70:	a22080e7          	jalr	-1502(ra) # 8000188e <copyout>
    80004e74:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004e78:	60a6                	ld	ra,72(sp)
    80004e7a:	6406                	ld	s0,64(sp)
    80004e7c:	74e2                	ld	s1,56(sp)
    80004e7e:	7942                	ld	s2,48(sp)
    80004e80:	79a2                	ld	s3,40(sp)
    80004e82:	6161                	addi	sp,sp,80
    80004e84:	8082                	ret
  return -1;
    80004e86:	557d                	li	a0,-1
    80004e88:	bfc5                	j	80004e78 <filestat+0x60>

0000000080004e8a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004e8a:	7179                	addi	sp,sp,-48
    80004e8c:	f406                	sd	ra,40(sp)
    80004e8e:	f022                	sd	s0,32(sp)
    80004e90:	ec26                	sd	s1,24(sp)
    80004e92:	e84a                	sd	s2,16(sp)
    80004e94:	e44e                	sd	s3,8(sp)
    80004e96:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e98:	00854783          	lbu	a5,8(a0)
    80004e9c:	c3d5                	beqz	a5,80004f40 <fileread+0xb6>
    80004e9e:	84aa                	mv	s1,a0
    80004ea0:	89ae                	mv	s3,a1
    80004ea2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ea4:	411c                	lw	a5,0(a0)
    80004ea6:	4705                	li	a4,1
    80004ea8:	04e78963          	beq	a5,a4,80004efa <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004eac:	470d                	li	a4,3
    80004eae:	04e78d63          	beq	a5,a4,80004f08 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004eb2:	4709                	li	a4,2
    80004eb4:	06e79e63          	bne	a5,a4,80004f30 <fileread+0xa6>
    ilock(f->ip);
    80004eb8:	6d08                	ld	a0,24(a0)
    80004eba:	fffff097          	auipc	ra,0xfffff
    80004ebe:	008080e7          	jalr	8(ra) # 80003ec2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ec2:	874a                	mv	a4,s2
    80004ec4:	5094                	lw	a3,32(s1)
    80004ec6:	864e                	mv	a2,s3
    80004ec8:	4585                	li	a1,1
    80004eca:	6c88                	ld	a0,24(s1)
    80004ecc:	fffff097          	auipc	ra,0xfffff
    80004ed0:	2aa080e7          	jalr	682(ra) # 80004176 <readi>
    80004ed4:	892a                	mv	s2,a0
    80004ed6:	00a05563          	blez	a0,80004ee0 <fileread+0x56>
      f->off += r;
    80004eda:	509c                	lw	a5,32(s1)
    80004edc:	9fa9                	addw	a5,a5,a0
    80004ede:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ee0:	6c88                	ld	a0,24(s1)
    80004ee2:	fffff097          	auipc	ra,0xfffff
    80004ee6:	0a2080e7          	jalr	162(ra) # 80003f84 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004eea:	854a                	mv	a0,s2
    80004eec:	70a2                	ld	ra,40(sp)
    80004eee:	7402                	ld	s0,32(sp)
    80004ef0:	64e2                	ld	s1,24(sp)
    80004ef2:	6942                	ld	s2,16(sp)
    80004ef4:	69a2                	ld	s3,8(sp)
    80004ef6:	6145                	addi	sp,sp,48
    80004ef8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004efa:	6908                	ld	a0,16(a0)
    80004efc:	00000097          	auipc	ra,0x0
    80004f00:	3ce080e7          	jalr	974(ra) # 800052ca <piperead>
    80004f04:	892a                	mv	s2,a0
    80004f06:	b7d5                	j	80004eea <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004f08:	02451783          	lh	a5,36(a0)
    80004f0c:	03079693          	slli	a3,a5,0x30
    80004f10:	92c1                	srli	a3,a3,0x30
    80004f12:	4725                	li	a4,9
    80004f14:	02d76863          	bltu	a4,a3,80004f44 <fileread+0xba>
    80004f18:	0792                	slli	a5,a5,0x4
    80004f1a:	0023c717          	auipc	a4,0x23c
    80004f1e:	7a670713          	addi	a4,a4,1958 # 802416c0 <devsw>
    80004f22:	97ba                	add	a5,a5,a4
    80004f24:	639c                	ld	a5,0(a5)
    80004f26:	c38d                	beqz	a5,80004f48 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004f28:	4505                	li	a0,1
    80004f2a:	9782                	jalr	a5
    80004f2c:	892a                	mv	s2,a0
    80004f2e:	bf75                	j	80004eea <fileread+0x60>
    panic("fileread");
    80004f30:	00004517          	auipc	a0,0x4
    80004f34:	87050513          	addi	a0,a0,-1936 # 800087a0 <syscalls+0x270>
    80004f38:	ffffb097          	auipc	ra,0xffffb
    80004f3c:	60c080e7          	jalr	1548(ra) # 80000544 <panic>
    return -1;
    80004f40:	597d                	li	s2,-1
    80004f42:	b765                	j	80004eea <fileread+0x60>
      return -1;
    80004f44:	597d                	li	s2,-1
    80004f46:	b755                	j	80004eea <fileread+0x60>
    80004f48:	597d                	li	s2,-1
    80004f4a:	b745                	j	80004eea <fileread+0x60>

0000000080004f4c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004f4c:	715d                	addi	sp,sp,-80
    80004f4e:	e486                	sd	ra,72(sp)
    80004f50:	e0a2                	sd	s0,64(sp)
    80004f52:	fc26                	sd	s1,56(sp)
    80004f54:	f84a                	sd	s2,48(sp)
    80004f56:	f44e                	sd	s3,40(sp)
    80004f58:	f052                	sd	s4,32(sp)
    80004f5a:	ec56                	sd	s5,24(sp)
    80004f5c:	e85a                	sd	s6,16(sp)
    80004f5e:	e45e                	sd	s7,8(sp)
    80004f60:	e062                	sd	s8,0(sp)
    80004f62:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004f64:	00954783          	lbu	a5,9(a0)
    80004f68:	10078663          	beqz	a5,80005074 <filewrite+0x128>
    80004f6c:	892a                	mv	s2,a0
    80004f6e:	8aae                	mv	s5,a1
    80004f70:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f72:	411c                	lw	a5,0(a0)
    80004f74:	4705                	li	a4,1
    80004f76:	02e78263          	beq	a5,a4,80004f9a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f7a:	470d                	li	a4,3
    80004f7c:	02e78663          	beq	a5,a4,80004fa8 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f80:	4709                	li	a4,2
    80004f82:	0ee79163          	bne	a5,a4,80005064 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004f86:	0ac05d63          	blez	a2,80005040 <filewrite+0xf4>
    int i = 0;
    80004f8a:	4981                	li	s3,0
    80004f8c:	6b05                	lui	s6,0x1
    80004f8e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004f92:	6b85                	lui	s7,0x1
    80004f94:	c00b8b9b          	addiw	s7,s7,-1024
    80004f98:	a861                	j	80005030 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004f9a:	6908                	ld	a0,16(a0)
    80004f9c:	00000097          	auipc	ra,0x0
    80004fa0:	22e080e7          	jalr	558(ra) # 800051ca <pipewrite>
    80004fa4:	8a2a                	mv	s4,a0
    80004fa6:	a045                	j	80005046 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004fa8:	02451783          	lh	a5,36(a0)
    80004fac:	03079693          	slli	a3,a5,0x30
    80004fb0:	92c1                	srli	a3,a3,0x30
    80004fb2:	4725                	li	a4,9
    80004fb4:	0cd76263          	bltu	a4,a3,80005078 <filewrite+0x12c>
    80004fb8:	0792                	slli	a5,a5,0x4
    80004fba:	0023c717          	auipc	a4,0x23c
    80004fbe:	70670713          	addi	a4,a4,1798 # 802416c0 <devsw>
    80004fc2:	97ba                	add	a5,a5,a4
    80004fc4:	679c                	ld	a5,8(a5)
    80004fc6:	cbdd                	beqz	a5,8000507c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004fc8:	4505                	li	a0,1
    80004fca:	9782                	jalr	a5
    80004fcc:	8a2a                	mv	s4,a0
    80004fce:	a8a5                	j	80005046 <filewrite+0xfa>
    80004fd0:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004fd4:	00000097          	auipc	ra,0x0
    80004fd8:	8b0080e7          	jalr	-1872(ra) # 80004884 <begin_op>
      ilock(f->ip);
    80004fdc:	01893503          	ld	a0,24(s2)
    80004fe0:	fffff097          	auipc	ra,0xfffff
    80004fe4:	ee2080e7          	jalr	-286(ra) # 80003ec2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004fe8:	8762                	mv	a4,s8
    80004fea:	02092683          	lw	a3,32(s2)
    80004fee:	01598633          	add	a2,s3,s5
    80004ff2:	4585                	li	a1,1
    80004ff4:	01893503          	ld	a0,24(s2)
    80004ff8:	fffff097          	auipc	ra,0xfffff
    80004ffc:	276080e7          	jalr	630(ra) # 8000426e <writei>
    80005000:	84aa                	mv	s1,a0
    80005002:	00a05763          	blez	a0,80005010 <filewrite+0xc4>
        f->off += r;
    80005006:	02092783          	lw	a5,32(s2)
    8000500a:	9fa9                	addw	a5,a5,a0
    8000500c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005010:	01893503          	ld	a0,24(s2)
    80005014:	fffff097          	auipc	ra,0xfffff
    80005018:	f70080e7          	jalr	-144(ra) # 80003f84 <iunlock>
      end_op();
    8000501c:	00000097          	auipc	ra,0x0
    80005020:	8e8080e7          	jalr	-1816(ra) # 80004904 <end_op>

      if(r != n1){
    80005024:	009c1f63          	bne	s8,s1,80005042 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005028:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000502c:	0149db63          	bge	s3,s4,80005042 <filewrite+0xf6>
      int n1 = n - i;
    80005030:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005034:	84be                	mv	s1,a5
    80005036:	2781                	sext.w	a5,a5
    80005038:	f8fb5ce3          	bge	s6,a5,80004fd0 <filewrite+0x84>
    8000503c:	84de                	mv	s1,s7
    8000503e:	bf49                	j	80004fd0 <filewrite+0x84>
    int i = 0;
    80005040:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005042:	013a1f63          	bne	s4,s3,80005060 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005046:	8552                	mv	a0,s4
    80005048:	60a6                	ld	ra,72(sp)
    8000504a:	6406                	ld	s0,64(sp)
    8000504c:	74e2                	ld	s1,56(sp)
    8000504e:	7942                	ld	s2,48(sp)
    80005050:	79a2                	ld	s3,40(sp)
    80005052:	7a02                	ld	s4,32(sp)
    80005054:	6ae2                	ld	s5,24(sp)
    80005056:	6b42                	ld	s6,16(sp)
    80005058:	6ba2                	ld	s7,8(sp)
    8000505a:	6c02                	ld	s8,0(sp)
    8000505c:	6161                	addi	sp,sp,80
    8000505e:	8082                	ret
    ret = (i == n ? n : -1);
    80005060:	5a7d                	li	s4,-1
    80005062:	b7d5                	j	80005046 <filewrite+0xfa>
    panic("filewrite");
    80005064:	00003517          	auipc	a0,0x3
    80005068:	74c50513          	addi	a0,a0,1868 # 800087b0 <syscalls+0x280>
    8000506c:	ffffb097          	auipc	ra,0xffffb
    80005070:	4d8080e7          	jalr	1240(ra) # 80000544 <panic>
    return -1;
    80005074:	5a7d                	li	s4,-1
    80005076:	bfc1                	j	80005046 <filewrite+0xfa>
      return -1;
    80005078:	5a7d                	li	s4,-1
    8000507a:	b7f1                	j	80005046 <filewrite+0xfa>
    8000507c:	5a7d                	li	s4,-1
    8000507e:	b7e1                	j	80005046 <filewrite+0xfa>

0000000080005080 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005080:	7179                	addi	sp,sp,-48
    80005082:	f406                	sd	ra,40(sp)
    80005084:	f022                	sd	s0,32(sp)
    80005086:	ec26                	sd	s1,24(sp)
    80005088:	e84a                	sd	s2,16(sp)
    8000508a:	e44e                	sd	s3,8(sp)
    8000508c:	e052                	sd	s4,0(sp)
    8000508e:	1800                	addi	s0,sp,48
    80005090:	84aa                	mv	s1,a0
    80005092:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005094:	0005b023          	sd	zero,0(a1)
    80005098:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000509c:	00000097          	auipc	ra,0x0
    800050a0:	bf8080e7          	jalr	-1032(ra) # 80004c94 <filealloc>
    800050a4:	e088                	sd	a0,0(s1)
    800050a6:	c551                	beqz	a0,80005132 <pipealloc+0xb2>
    800050a8:	00000097          	auipc	ra,0x0
    800050ac:	bec080e7          	jalr	-1044(ra) # 80004c94 <filealloc>
    800050b0:	00aa3023          	sd	a0,0(s4)
    800050b4:	c92d                	beqz	a0,80005126 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800050b6:	ffffc097          	auipc	ra,0xffffc
    800050ba:	b4a080e7          	jalr	-1206(ra) # 80000c00 <kalloc>
    800050be:	892a                	mv	s2,a0
    800050c0:	c125                	beqz	a0,80005120 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800050c2:	4985                	li	s3,1
    800050c4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800050c8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800050cc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800050d0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800050d4:	00003597          	auipc	a1,0x3
    800050d8:	6ec58593          	addi	a1,a1,1772 # 800087c0 <syscalls+0x290>
    800050dc:	ffffc097          	auipc	ra,0xffffc
    800050e0:	b9a080e7          	jalr	-1126(ra) # 80000c76 <initlock>
  (*f0)->type = FD_PIPE;
    800050e4:	609c                	ld	a5,0(s1)
    800050e6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800050ea:	609c                	ld	a5,0(s1)
    800050ec:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800050f0:	609c                	ld	a5,0(s1)
    800050f2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800050f6:	609c                	ld	a5,0(s1)
    800050f8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800050fc:	000a3783          	ld	a5,0(s4)
    80005100:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005104:	000a3783          	ld	a5,0(s4)
    80005108:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000510c:	000a3783          	ld	a5,0(s4)
    80005110:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005114:	000a3783          	ld	a5,0(s4)
    80005118:	0127b823          	sd	s2,16(a5)
  return 0;
    8000511c:	4501                	li	a0,0
    8000511e:	a025                	j	80005146 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005120:	6088                	ld	a0,0(s1)
    80005122:	e501                	bnez	a0,8000512a <pipealloc+0xaa>
    80005124:	a039                	j	80005132 <pipealloc+0xb2>
    80005126:	6088                	ld	a0,0(s1)
    80005128:	c51d                	beqz	a0,80005156 <pipealloc+0xd6>
    fileclose(*f0);
    8000512a:	00000097          	auipc	ra,0x0
    8000512e:	c26080e7          	jalr	-986(ra) # 80004d50 <fileclose>
  if(*f1)
    80005132:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005136:	557d                	li	a0,-1
  if(*f1)
    80005138:	c799                	beqz	a5,80005146 <pipealloc+0xc6>
    fileclose(*f1);
    8000513a:	853e                	mv	a0,a5
    8000513c:	00000097          	auipc	ra,0x0
    80005140:	c14080e7          	jalr	-1004(ra) # 80004d50 <fileclose>
  return -1;
    80005144:	557d                	li	a0,-1
}
    80005146:	70a2                	ld	ra,40(sp)
    80005148:	7402                	ld	s0,32(sp)
    8000514a:	64e2                	ld	s1,24(sp)
    8000514c:	6942                	ld	s2,16(sp)
    8000514e:	69a2                	ld	s3,8(sp)
    80005150:	6a02                	ld	s4,0(sp)
    80005152:	6145                	addi	sp,sp,48
    80005154:	8082                	ret
  return -1;
    80005156:	557d                	li	a0,-1
    80005158:	b7fd                	j	80005146 <pipealloc+0xc6>

000000008000515a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000515a:	1101                	addi	sp,sp,-32
    8000515c:	ec06                	sd	ra,24(sp)
    8000515e:	e822                	sd	s0,16(sp)
    80005160:	e426                	sd	s1,8(sp)
    80005162:	e04a                	sd	s2,0(sp)
    80005164:	1000                	addi	s0,sp,32
    80005166:	84aa                	mv	s1,a0
    80005168:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000516a:	ffffc097          	auipc	ra,0xffffc
    8000516e:	b9c080e7          	jalr	-1124(ra) # 80000d06 <acquire>
  if(writable){
    80005172:	02090d63          	beqz	s2,800051ac <pipeclose+0x52>
    pi->writeopen = 0;
    80005176:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000517a:	21848513          	addi	a0,s1,536
    8000517e:	ffffd097          	auipc	ra,0xffffd
    80005182:	32e080e7          	jalr	814(ra) # 800024ac <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005186:	2204b783          	ld	a5,544(s1)
    8000518a:	eb95                	bnez	a5,800051be <pipeclose+0x64>
    release(&pi->lock);
    8000518c:	8526                	mv	a0,s1
    8000518e:	ffffc097          	auipc	ra,0xffffc
    80005192:	c2c080e7          	jalr	-980(ra) # 80000dba <release>
    kfree((char*)pi);
    80005196:	8526                	mv	a0,s1
    80005198:	ffffc097          	auipc	ra,0xffffc
    8000519c:	8d2080e7          	jalr	-1838(ra) # 80000a6a <kfree>
  } else
    release(&pi->lock);
}
    800051a0:	60e2                	ld	ra,24(sp)
    800051a2:	6442                	ld	s0,16(sp)
    800051a4:	64a2                	ld	s1,8(sp)
    800051a6:	6902                	ld	s2,0(sp)
    800051a8:	6105                	addi	sp,sp,32
    800051aa:	8082                	ret
    pi->readopen = 0;
    800051ac:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800051b0:	21c48513          	addi	a0,s1,540
    800051b4:	ffffd097          	auipc	ra,0xffffd
    800051b8:	2f8080e7          	jalr	760(ra) # 800024ac <wakeup>
    800051bc:	b7e9                	j	80005186 <pipeclose+0x2c>
    release(&pi->lock);
    800051be:	8526                	mv	a0,s1
    800051c0:	ffffc097          	auipc	ra,0xffffc
    800051c4:	bfa080e7          	jalr	-1030(ra) # 80000dba <release>
}
    800051c8:	bfe1                	j	800051a0 <pipeclose+0x46>

00000000800051ca <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800051ca:	7159                	addi	sp,sp,-112
    800051cc:	f486                	sd	ra,104(sp)
    800051ce:	f0a2                	sd	s0,96(sp)
    800051d0:	eca6                	sd	s1,88(sp)
    800051d2:	e8ca                	sd	s2,80(sp)
    800051d4:	e4ce                	sd	s3,72(sp)
    800051d6:	e0d2                	sd	s4,64(sp)
    800051d8:	fc56                	sd	s5,56(sp)
    800051da:	f85a                	sd	s6,48(sp)
    800051dc:	f45e                	sd	s7,40(sp)
    800051de:	f062                	sd	s8,32(sp)
    800051e0:	ec66                	sd	s9,24(sp)
    800051e2:	1880                	addi	s0,sp,112
    800051e4:	84aa                	mv	s1,a0
    800051e6:	8aae                	mv	s5,a1
    800051e8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800051ea:	ffffd097          	auipc	ra,0xffffd
    800051ee:	a1e080e7          	jalr	-1506(ra) # 80001c08 <myproc>
    800051f2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800051f4:	8526                	mv	a0,s1
    800051f6:	ffffc097          	auipc	ra,0xffffc
    800051fa:	b10080e7          	jalr	-1264(ra) # 80000d06 <acquire>
  while(i < n){
    800051fe:	0d405463          	blez	s4,800052c6 <pipewrite+0xfc>
    80005202:	8ba6                	mv	s7,s1
  int i = 0;
    80005204:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005206:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005208:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000520c:	21c48c13          	addi	s8,s1,540
    80005210:	a08d                	j	80005272 <pipewrite+0xa8>
      release(&pi->lock);
    80005212:	8526                	mv	a0,s1
    80005214:	ffffc097          	auipc	ra,0xffffc
    80005218:	ba6080e7          	jalr	-1114(ra) # 80000dba <release>
      return -1;
    8000521c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000521e:	854a                	mv	a0,s2
    80005220:	70a6                	ld	ra,104(sp)
    80005222:	7406                	ld	s0,96(sp)
    80005224:	64e6                	ld	s1,88(sp)
    80005226:	6946                	ld	s2,80(sp)
    80005228:	69a6                	ld	s3,72(sp)
    8000522a:	6a06                	ld	s4,64(sp)
    8000522c:	7ae2                	ld	s5,56(sp)
    8000522e:	7b42                	ld	s6,48(sp)
    80005230:	7ba2                	ld	s7,40(sp)
    80005232:	7c02                	ld	s8,32(sp)
    80005234:	6ce2                	ld	s9,24(sp)
    80005236:	6165                	addi	sp,sp,112
    80005238:	8082                	ret
      wakeup(&pi->nread);
    8000523a:	8566                	mv	a0,s9
    8000523c:	ffffd097          	auipc	ra,0xffffd
    80005240:	270080e7          	jalr	624(ra) # 800024ac <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005244:	85de                	mv	a1,s7
    80005246:	8562                	mv	a0,s8
    80005248:	ffffd097          	auipc	ra,0xffffd
    8000524c:	200080e7          	jalr	512(ra) # 80002448 <sleep>
    80005250:	a839                	j	8000526e <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005252:	21c4a783          	lw	a5,540(s1)
    80005256:	0017871b          	addiw	a4,a5,1
    8000525a:	20e4ae23          	sw	a4,540(s1)
    8000525e:	1ff7f793          	andi	a5,a5,511
    80005262:	97a6                	add	a5,a5,s1
    80005264:	f9f44703          	lbu	a4,-97(s0)
    80005268:	00e78c23          	sb	a4,24(a5)
      i++;
    8000526c:	2905                	addiw	s2,s2,1
  while(i < n){
    8000526e:	05495063          	bge	s2,s4,800052ae <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80005272:	2204a783          	lw	a5,544(s1)
    80005276:	dfd1                	beqz	a5,80005212 <pipewrite+0x48>
    80005278:	854e                	mv	a0,s3
    8000527a:	ffffd097          	auipc	ra,0xffffd
    8000527e:	482080e7          	jalr	1154(ra) # 800026fc <killed>
    80005282:	f941                	bnez	a0,80005212 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005284:	2184a783          	lw	a5,536(s1)
    80005288:	21c4a703          	lw	a4,540(s1)
    8000528c:	2007879b          	addiw	a5,a5,512
    80005290:	faf705e3          	beq	a4,a5,8000523a <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005294:	4685                	li	a3,1
    80005296:	01590633          	add	a2,s2,s5
    8000529a:	f9f40593          	addi	a1,s0,-97
    8000529e:	0509b503          	ld	a0,80(s3)
    800052a2:	ffffc097          	auipc	ra,0xffffc
    800052a6:	6b0080e7          	jalr	1712(ra) # 80001952 <copyin>
    800052aa:	fb6514e3          	bne	a0,s6,80005252 <pipewrite+0x88>
  wakeup(&pi->nread);
    800052ae:	21848513          	addi	a0,s1,536
    800052b2:	ffffd097          	auipc	ra,0xffffd
    800052b6:	1fa080e7          	jalr	506(ra) # 800024ac <wakeup>
  release(&pi->lock);
    800052ba:	8526                	mv	a0,s1
    800052bc:	ffffc097          	auipc	ra,0xffffc
    800052c0:	afe080e7          	jalr	-1282(ra) # 80000dba <release>
  return i;
    800052c4:	bfa9                	j	8000521e <pipewrite+0x54>
  int i = 0;
    800052c6:	4901                	li	s2,0
    800052c8:	b7dd                	j	800052ae <pipewrite+0xe4>

00000000800052ca <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800052ca:	715d                	addi	sp,sp,-80
    800052cc:	e486                	sd	ra,72(sp)
    800052ce:	e0a2                	sd	s0,64(sp)
    800052d0:	fc26                	sd	s1,56(sp)
    800052d2:	f84a                	sd	s2,48(sp)
    800052d4:	f44e                	sd	s3,40(sp)
    800052d6:	f052                	sd	s4,32(sp)
    800052d8:	ec56                	sd	s5,24(sp)
    800052da:	e85a                	sd	s6,16(sp)
    800052dc:	0880                	addi	s0,sp,80
    800052de:	84aa                	mv	s1,a0
    800052e0:	892e                	mv	s2,a1
    800052e2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800052e4:	ffffd097          	auipc	ra,0xffffd
    800052e8:	924080e7          	jalr	-1756(ra) # 80001c08 <myproc>
    800052ec:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800052ee:	8b26                	mv	s6,s1
    800052f0:	8526                	mv	a0,s1
    800052f2:	ffffc097          	auipc	ra,0xffffc
    800052f6:	a14080e7          	jalr	-1516(ra) # 80000d06 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052fa:	2184a703          	lw	a4,536(s1)
    800052fe:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005302:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005306:	02f71763          	bne	a4,a5,80005334 <piperead+0x6a>
    8000530a:	2244a783          	lw	a5,548(s1)
    8000530e:	c39d                	beqz	a5,80005334 <piperead+0x6a>
    if(killed(pr)){
    80005310:	8552                	mv	a0,s4
    80005312:	ffffd097          	auipc	ra,0xffffd
    80005316:	3ea080e7          	jalr	1002(ra) # 800026fc <killed>
    8000531a:	e941                	bnez	a0,800053aa <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000531c:	85da                	mv	a1,s6
    8000531e:	854e                	mv	a0,s3
    80005320:	ffffd097          	auipc	ra,0xffffd
    80005324:	128080e7          	jalr	296(ra) # 80002448 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005328:	2184a703          	lw	a4,536(s1)
    8000532c:	21c4a783          	lw	a5,540(s1)
    80005330:	fcf70de3          	beq	a4,a5,8000530a <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005334:	09505263          	blez	s5,800053b8 <piperead+0xee>
    80005338:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000533a:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000533c:	2184a783          	lw	a5,536(s1)
    80005340:	21c4a703          	lw	a4,540(s1)
    80005344:	02f70d63          	beq	a4,a5,8000537e <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005348:	0017871b          	addiw	a4,a5,1
    8000534c:	20e4ac23          	sw	a4,536(s1)
    80005350:	1ff7f793          	andi	a5,a5,511
    80005354:	97a6                	add	a5,a5,s1
    80005356:	0187c783          	lbu	a5,24(a5)
    8000535a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000535e:	4685                	li	a3,1
    80005360:	fbf40613          	addi	a2,s0,-65
    80005364:	85ca                	mv	a1,s2
    80005366:	050a3503          	ld	a0,80(s4)
    8000536a:	ffffc097          	auipc	ra,0xffffc
    8000536e:	524080e7          	jalr	1316(ra) # 8000188e <copyout>
    80005372:	01650663          	beq	a0,s6,8000537e <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005376:	2985                	addiw	s3,s3,1
    80005378:	0905                	addi	s2,s2,1
    8000537a:	fd3a91e3          	bne	s5,s3,8000533c <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000537e:	21c48513          	addi	a0,s1,540
    80005382:	ffffd097          	auipc	ra,0xffffd
    80005386:	12a080e7          	jalr	298(ra) # 800024ac <wakeup>
  release(&pi->lock);
    8000538a:	8526                	mv	a0,s1
    8000538c:	ffffc097          	auipc	ra,0xffffc
    80005390:	a2e080e7          	jalr	-1490(ra) # 80000dba <release>
  return i;
}
    80005394:	854e                	mv	a0,s3
    80005396:	60a6                	ld	ra,72(sp)
    80005398:	6406                	ld	s0,64(sp)
    8000539a:	74e2                	ld	s1,56(sp)
    8000539c:	7942                	ld	s2,48(sp)
    8000539e:	79a2                	ld	s3,40(sp)
    800053a0:	7a02                	ld	s4,32(sp)
    800053a2:	6ae2                	ld	s5,24(sp)
    800053a4:	6b42                	ld	s6,16(sp)
    800053a6:	6161                	addi	sp,sp,80
    800053a8:	8082                	ret
      release(&pi->lock);
    800053aa:	8526                	mv	a0,s1
    800053ac:	ffffc097          	auipc	ra,0xffffc
    800053b0:	a0e080e7          	jalr	-1522(ra) # 80000dba <release>
      return -1;
    800053b4:	59fd                	li	s3,-1
    800053b6:	bff9                	j	80005394 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053b8:	4981                	li	s3,0
    800053ba:	b7d1                	j	8000537e <piperead+0xb4>

00000000800053bc <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800053bc:	1141                	addi	sp,sp,-16
    800053be:	e422                	sd	s0,8(sp)
    800053c0:	0800                	addi	s0,sp,16
    800053c2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800053c4:	8905                	andi	a0,a0,1
    800053c6:	c111                	beqz	a0,800053ca <flags2perm+0xe>
      perm = PTE_X;
    800053c8:	4521                	li	a0,8
    if(flags & 0x2)
    800053ca:	8b89                	andi	a5,a5,2
    800053cc:	c399                	beqz	a5,800053d2 <flags2perm+0x16>
      perm |= PTE_W;
    800053ce:	00456513          	ori	a0,a0,4
    return perm;
}
    800053d2:	6422                	ld	s0,8(sp)
    800053d4:	0141                	addi	sp,sp,16
    800053d6:	8082                	ret

00000000800053d8 <exec>:

int
exec(char *path, char **argv)
{
    800053d8:	df010113          	addi	sp,sp,-528
    800053dc:	20113423          	sd	ra,520(sp)
    800053e0:	20813023          	sd	s0,512(sp)
    800053e4:	ffa6                	sd	s1,504(sp)
    800053e6:	fbca                	sd	s2,496(sp)
    800053e8:	f7ce                	sd	s3,488(sp)
    800053ea:	f3d2                	sd	s4,480(sp)
    800053ec:	efd6                	sd	s5,472(sp)
    800053ee:	ebda                	sd	s6,464(sp)
    800053f0:	e7de                	sd	s7,456(sp)
    800053f2:	e3e2                	sd	s8,448(sp)
    800053f4:	ff66                	sd	s9,440(sp)
    800053f6:	fb6a                	sd	s10,432(sp)
    800053f8:	f76e                	sd	s11,424(sp)
    800053fa:	0c00                	addi	s0,sp,528
    800053fc:	84aa                	mv	s1,a0
    800053fe:	dea43c23          	sd	a0,-520(s0)
    80005402:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005406:	ffffd097          	auipc	ra,0xffffd
    8000540a:	802080e7          	jalr	-2046(ra) # 80001c08 <myproc>
    8000540e:	892a                	mv	s2,a0

  begin_op();
    80005410:	fffff097          	auipc	ra,0xfffff
    80005414:	474080e7          	jalr	1140(ra) # 80004884 <begin_op>

  if((ip = namei(path)) == 0){
    80005418:	8526                	mv	a0,s1
    8000541a:	fffff097          	auipc	ra,0xfffff
    8000541e:	24e080e7          	jalr	590(ra) # 80004668 <namei>
    80005422:	c92d                	beqz	a0,80005494 <exec+0xbc>
    80005424:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005426:	fffff097          	auipc	ra,0xfffff
    8000542a:	a9c080e7          	jalr	-1380(ra) # 80003ec2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000542e:	04000713          	li	a4,64
    80005432:	4681                	li	a3,0
    80005434:	e5040613          	addi	a2,s0,-432
    80005438:	4581                	li	a1,0
    8000543a:	8526                	mv	a0,s1
    8000543c:	fffff097          	auipc	ra,0xfffff
    80005440:	d3a080e7          	jalr	-710(ra) # 80004176 <readi>
    80005444:	04000793          	li	a5,64
    80005448:	00f51a63          	bne	a0,a5,8000545c <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000544c:	e5042703          	lw	a4,-432(s0)
    80005450:	464c47b7          	lui	a5,0x464c4
    80005454:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005458:	04f70463          	beq	a4,a5,800054a0 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000545c:	8526                	mv	a0,s1
    8000545e:	fffff097          	auipc	ra,0xfffff
    80005462:	cc6080e7          	jalr	-826(ra) # 80004124 <iunlockput>
    end_op();
    80005466:	fffff097          	auipc	ra,0xfffff
    8000546a:	49e080e7          	jalr	1182(ra) # 80004904 <end_op>
  }
  return -1;
    8000546e:	557d                	li	a0,-1
}
    80005470:	20813083          	ld	ra,520(sp)
    80005474:	20013403          	ld	s0,512(sp)
    80005478:	74fe                	ld	s1,504(sp)
    8000547a:	795e                	ld	s2,496(sp)
    8000547c:	79be                	ld	s3,488(sp)
    8000547e:	7a1e                	ld	s4,480(sp)
    80005480:	6afe                	ld	s5,472(sp)
    80005482:	6b5e                	ld	s6,464(sp)
    80005484:	6bbe                	ld	s7,456(sp)
    80005486:	6c1e                	ld	s8,448(sp)
    80005488:	7cfa                	ld	s9,440(sp)
    8000548a:	7d5a                	ld	s10,432(sp)
    8000548c:	7dba                	ld	s11,424(sp)
    8000548e:	21010113          	addi	sp,sp,528
    80005492:	8082                	ret
    end_op();
    80005494:	fffff097          	auipc	ra,0xfffff
    80005498:	470080e7          	jalr	1136(ra) # 80004904 <end_op>
    return -1;
    8000549c:	557d                	li	a0,-1
    8000549e:	bfc9                	j	80005470 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800054a0:	854a                	mv	a0,s2
    800054a2:	ffffd097          	auipc	ra,0xffffd
    800054a6:	82a080e7          	jalr	-2006(ra) # 80001ccc <proc_pagetable>
    800054aa:	8baa                	mv	s7,a0
    800054ac:	d945                	beqz	a0,8000545c <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054ae:	e7042983          	lw	s3,-400(s0)
    800054b2:	e8845783          	lhu	a5,-376(s0)
    800054b6:	c7ad                	beqz	a5,80005520 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800054b8:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054ba:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800054bc:	6c85                	lui	s9,0x1
    800054be:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800054c2:	def43823          	sd	a5,-528(s0)
    800054c6:	ac0d                	j	800056f8 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800054c8:	00003517          	auipc	a0,0x3
    800054cc:	30050513          	addi	a0,a0,768 # 800087c8 <syscalls+0x298>
    800054d0:	ffffb097          	auipc	ra,0xffffb
    800054d4:	074080e7          	jalr	116(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800054d8:	8756                	mv	a4,s5
    800054da:	012d86bb          	addw	a3,s11,s2
    800054de:	4581                	li	a1,0
    800054e0:	8526                	mv	a0,s1
    800054e2:	fffff097          	auipc	ra,0xfffff
    800054e6:	c94080e7          	jalr	-876(ra) # 80004176 <readi>
    800054ea:	2501                	sext.w	a0,a0
    800054ec:	1aaa9a63          	bne	s5,a0,800056a0 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    800054f0:	6785                	lui	a5,0x1
    800054f2:	0127893b          	addw	s2,a5,s2
    800054f6:	77fd                	lui	a5,0xfffff
    800054f8:	01478a3b          	addw	s4,a5,s4
    800054fc:	1f897563          	bgeu	s2,s8,800056e6 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005500:	02091593          	slli	a1,s2,0x20
    80005504:	9181                	srli	a1,a1,0x20
    80005506:	95ea                	add	a1,a1,s10
    80005508:	855e                	mv	a0,s7
    8000550a:	ffffc097          	auipc	ra,0xffffc
    8000550e:	c8a080e7          	jalr	-886(ra) # 80001194 <walkaddr>
    80005512:	862a                	mv	a2,a0
    if(pa == 0)
    80005514:	d955                	beqz	a0,800054c8 <exec+0xf0>
      n = PGSIZE;
    80005516:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005518:	fd9a70e3          	bgeu	s4,s9,800054d8 <exec+0x100>
      n = sz - i;
    8000551c:	8ad2                	mv	s5,s4
    8000551e:	bf6d                	j	800054d8 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005520:	4a01                	li	s4,0
  iunlockput(ip);
    80005522:	8526                	mv	a0,s1
    80005524:	fffff097          	auipc	ra,0xfffff
    80005528:	c00080e7          	jalr	-1024(ra) # 80004124 <iunlockput>
  end_op();
    8000552c:	fffff097          	auipc	ra,0xfffff
    80005530:	3d8080e7          	jalr	984(ra) # 80004904 <end_op>
  p = myproc();
    80005534:	ffffc097          	auipc	ra,0xffffc
    80005538:	6d4080e7          	jalr	1748(ra) # 80001c08 <myproc>
    8000553c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000553e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005542:	6785                	lui	a5,0x1
    80005544:	17fd                	addi	a5,a5,-1
    80005546:	9a3e                	add	s4,s4,a5
    80005548:	757d                	lui	a0,0xfffff
    8000554a:	00aa77b3          	and	a5,s4,a0
    8000554e:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005552:	4691                	li	a3,4
    80005554:	6609                	lui	a2,0x2
    80005556:	963e                	add	a2,a2,a5
    80005558:	85be                	mv	a1,a5
    8000555a:	855e                	mv	a0,s7
    8000555c:	ffffc097          	auipc	ra,0xffffc
    80005560:	fec080e7          	jalr	-20(ra) # 80001548 <uvmalloc>
    80005564:	8b2a                	mv	s6,a0
  ip = 0;
    80005566:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005568:	12050c63          	beqz	a0,800056a0 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000556c:	75f9                	lui	a1,0xffffe
    8000556e:	95aa                	add	a1,a1,a0
    80005570:	855e                	mv	a0,s7
    80005572:	ffffc097          	auipc	ra,0xffffc
    80005576:	2ea080e7          	jalr	746(ra) # 8000185c <uvmclear>
  stackbase = sp - PGSIZE;
    8000557a:	7c7d                	lui	s8,0xfffff
    8000557c:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000557e:	e0043783          	ld	a5,-512(s0)
    80005582:	6388                	ld	a0,0(a5)
    80005584:	c535                	beqz	a0,800055f0 <exec+0x218>
    80005586:	e9040993          	addi	s3,s0,-368
    8000558a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000558e:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005590:	ffffc097          	auipc	ra,0xffffc
    80005594:	9f6080e7          	jalr	-1546(ra) # 80000f86 <strlen>
    80005598:	2505                	addiw	a0,a0,1
    8000559a:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000559e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800055a2:	13896663          	bltu	s2,s8,800056ce <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800055a6:	e0043d83          	ld	s11,-512(s0)
    800055aa:	000dba03          	ld	s4,0(s11)
    800055ae:	8552                	mv	a0,s4
    800055b0:	ffffc097          	auipc	ra,0xffffc
    800055b4:	9d6080e7          	jalr	-1578(ra) # 80000f86 <strlen>
    800055b8:	0015069b          	addiw	a3,a0,1
    800055bc:	8652                	mv	a2,s4
    800055be:	85ca                	mv	a1,s2
    800055c0:	855e                	mv	a0,s7
    800055c2:	ffffc097          	auipc	ra,0xffffc
    800055c6:	2cc080e7          	jalr	716(ra) # 8000188e <copyout>
    800055ca:	10054663          	bltz	a0,800056d6 <exec+0x2fe>
    ustack[argc] = sp;
    800055ce:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800055d2:	0485                	addi	s1,s1,1
    800055d4:	008d8793          	addi	a5,s11,8
    800055d8:	e0f43023          	sd	a5,-512(s0)
    800055dc:	008db503          	ld	a0,8(s11)
    800055e0:	c911                	beqz	a0,800055f4 <exec+0x21c>
    if(argc >= MAXARG)
    800055e2:	09a1                	addi	s3,s3,8
    800055e4:	fb3c96e3          	bne	s9,s3,80005590 <exec+0x1b8>
  sz = sz1;
    800055e8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800055ec:	4481                	li	s1,0
    800055ee:	a84d                	j	800056a0 <exec+0x2c8>
  sp = sz;
    800055f0:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800055f2:	4481                	li	s1,0
  ustack[argc] = 0;
    800055f4:	00349793          	slli	a5,s1,0x3
    800055f8:	f9040713          	addi	a4,s0,-112
    800055fc:	97ba                	add	a5,a5,a4
    800055fe:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005602:	00148693          	addi	a3,s1,1
    80005606:	068e                	slli	a3,a3,0x3
    80005608:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000560c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005610:	01897663          	bgeu	s2,s8,8000561c <exec+0x244>
  sz = sz1;
    80005614:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005618:	4481                	li	s1,0
    8000561a:	a059                	j	800056a0 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000561c:	e9040613          	addi	a2,s0,-368
    80005620:	85ca                	mv	a1,s2
    80005622:	855e                	mv	a0,s7
    80005624:	ffffc097          	auipc	ra,0xffffc
    80005628:	26a080e7          	jalr	618(ra) # 8000188e <copyout>
    8000562c:	0a054963          	bltz	a0,800056de <exec+0x306>
  p->trapframe->a1 = sp;
    80005630:	058ab783          	ld	a5,88(s5)
    80005634:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005638:	df843783          	ld	a5,-520(s0)
    8000563c:	0007c703          	lbu	a4,0(a5)
    80005640:	cf11                	beqz	a4,8000565c <exec+0x284>
    80005642:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005644:	02f00693          	li	a3,47
    80005648:	a039                	j	80005656 <exec+0x27e>
      last = s+1;
    8000564a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000564e:	0785                	addi	a5,a5,1
    80005650:	fff7c703          	lbu	a4,-1(a5)
    80005654:	c701                	beqz	a4,8000565c <exec+0x284>
    if(*s == '/')
    80005656:	fed71ce3          	bne	a4,a3,8000564e <exec+0x276>
    8000565a:	bfc5                	j	8000564a <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    8000565c:	4641                	li	a2,16
    8000565e:	df843583          	ld	a1,-520(s0)
    80005662:	158a8513          	addi	a0,s5,344
    80005666:	ffffc097          	auipc	ra,0xffffc
    8000566a:	8ee080e7          	jalr	-1810(ra) # 80000f54 <safestrcpy>
  oldpagetable = p->pagetable;
    8000566e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005672:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005676:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000567a:	058ab783          	ld	a5,88(s5)
    8000567e:	e6843703          	ld	a4,-408(s0)
    80005682:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005684:	058ab783          	ld	a5,88(s5)
    80005688:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000568c:	85ea                	mv	a1,s10
    8000568e:	ffffc097          	auipc	ra,0xffffc
    80005692:	6da080e7          	jalr	1754(ra) # 80001d68 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005696:	0004851b          	sext.w	a0,s1
    8000569a:	bbd9                	j	80005470 <exec+0x98>
    8000569c:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    800056a0:	e0843583          	ld	a1,-504(s0)
    800056a4:	855e                	mv	a0,s7
    800056a6:	ffffc097          	auipc	ra,0xffffc
    800056aa:	6c2080e7          	jalr	1730(ra) # 80001d68 <proc_freepagetable>
  if(ip){
    800056ae:	da0497e3          	bnez	s1,8000545c <exec+0x84>
  return -1;
    800056b2:	557d                	li	a0,-1
    800056b4:	bb75                	j	80005470 <exec+0x98>
    800056b6:	e1443423          	sd	s4,-504(s0)
    800056ba:	b7dd                	j	800056a0 <exec+0x2c8>
    800056bc:	e1443423          	sd	s4,-504(s0)
    800056c0:	b7c5                	j	800056a0 <exec+0x2c8>
    800056c2:	e1443423          	sd	s4,-504(s0)
    800056c6:	bfe9                	j	800056a0 <exec+0x2c8>
    800056c8:	e1443423          	sd	s4,-504(s0)
    800056cc:	bfd1                	j	800056a0 <exec+0x2c8>
  sz = sz1;
    800056ce:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800056d2:	4481                	li	s1,0
    800056d4:	b7f1                	j	800056a0 <exec+0x2c8>
  sz = sz1;
    800056d6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800056da:	4481                	li	s1,0
    800056dc:	b7d1                	j	800056a0 <exec+0x2c8>
  sz = sz1;
    800056de:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800056e2:	4481                	li	s1,0
    800056e4:	bf75                	j	800056a0 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800056e6:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056ea:	2b05                	addiw	s6,s6,1
    800056ec:	0389899b          	addiw	s3,s3,56
    800056f0:	e8845783          	lhu	a5,-376(s0)
    800056f4:	e2fb57e3          	bge	s6,a5,80005522 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800056f8:	2981                	sext.w	s3,s3
    800056fa:	03800713          	li	a4,56
    800056fe:	86ce                	mv	a3,s3
    80005700:	e1840613          	addi	a2,s0,-488
    80005704:	4581                	li	a1,0
    80005706:	8526                	mv	a0,s1
    80005708:	fffff097          	auipc	ra,0xfffff
    8000570c:	a6e080e7          	jalr	-1426(ra) # 80004176 <readi>
    80005710:	03800793          	li	a5,56
    80005714:	f8f514e3          	bne	a0,a5,8000569c <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    80005718:	e1842783          	lw	a5,-488(s0)
    8000571c:	4705                	li	a4,1
    8000571e:	fce796e3          	bne	a5,a4,800056ea <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005722:	e4043903          	ld	s2,-448(s0)
    80005726:	e3843783          	ld	a5,-456(s0)
    8000572a:	f8f966e3          	bltu	s2,a5,800056b6 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000572e:	e2843783          	ld	a5,-472(s0)
    80005732:	993e                	add	s2,s2,a5
    80005734:	f8f964e3          	bltu	s2,a5,800056bc <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005738:	df043703          	ld	a4,-528(s0)
    8000573c:	8ff9                	and	a5,a5,a4
    8000573e:	f3d1                	bnez	a5,800056c2 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005740:	e1c42503          	lw	a0,-484(s0)
    80005744:	00000097          	auipc	ra,0x0
    80005748:	c78080e7          	jalr	-904(ra) # 800053bc <flags2perm>
    8000574c:	86aa                	mv	a3,a0
    8000574e:	864a                	mv	a2,s2
    80005750:	85d2                	mv	a1,s4
    80005752:	855e                	mv	a0,s7
    80005754:	ffffc097          	auipc	ra,0xffffc
    80005758:	df4080e7          	jalr	-524(ra) # 80001548 <uvmalloc>
    8000575c:	e0a43423          	sd	a0,-504(s0)
    80005760:	d525                	beqz	a0,800056c8 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005762:	e2843d03          	ld	s10,-472(s0)
    80005766:	e2042d83          	lw	s11,-480(s0)
    8000576a:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000576e:	f60c0ce3          	beqz	s8,800056e6 <exec+0x30e>
    80005772:	8a62                	mv	s4,s8
    80005774:	4901                	li	s2,0
    80005776:	b369                	j	80005500 <exec+0x128>

0000000080005778 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005778:	7179                	addi	sp,sp,-48
    8000577a:	f406                	sd	ra,40(sp)
    8000577c:	f022                	sd	s0,32(sp)
    8000577e:	ec26                	sd	s1,24(sp)
    80005780:	e84a                	sd	s2,16(sp)
    80005782:	1800                	addi	s0,sp,48
    80005784:	892e                	mv	s2,a1
    80005786:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005788:	fdc40593          	addi	a1,s0,-36
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	9fa080e7          	jalr	-1542(ra) # 80003186 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005794:	fdc42703          	lw	a4,-36(s0)
    80005798:	47bd                	li	a5,15
    8000579a:	02e7eb63          	bltu	a5,a4,800057d0 <argfd+0x58>
    8000579e:	ffffc097          	auipc	ra,0xffffc
    800057a2:	46a080e7          	jalr	1130(ra) # 80001c08 <myproc>
    800057a6:	fdc42703          	lw	a4,-36(s0)
    800057aa:	01a70793          	addi	a5,a4,26
    800057ae:	078e                	slli	a5,a5,0x3
    800057b0:	953e                	add	a0,a0,a5
    800057b2:	611c                	ld	a5,0(a0)
    800057b4:	c385                	beqz	a5,800057d4 <argfd+0x5c>
    return -1;
  if(pfd)
    800057b6:	00090463          	beqz	s2,800057be <argfd+0x46>
    *pfd = fd;
    800057ba:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800057be:	4501                	li	a0,0
  if(pf)
    800057c0:	c091                	beqz	s1,800057c4 <argfd+0x4c>
    *pf = f;
    800057c2:	e09c                	sd	a5,0(s1)
}
    800057c4:	70a2                	ld	ra,40(sp)
    800057c6:	7402                	ld	s0,32(sp)
    800057c8:	64e2                	ld	s1,24(sp)
    800057ca:	6942                	ld	s2,16(sp)
    800057cc:	6145                	addi	sp,sp,48
    800057ce:	8082                	ret
    return -1;
    800057d0:	557d                	li	a0,-1
    800057d2:	bfcd                	j	800057c4 <argfd+0x4c>
    800057d4:	557d                	li	a0,-1
    800057d6:	b7fd                	j	800057c4 <argfd+0x4c>

00000000800057d8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800057d8:	1101                	addi	sp,sp,-32
    800057da:	ec06                	sd	ra,24(sp)
    800057dc:	e822                	sd	s0,16(sp)
    800057de:	e426                	sd	s1,8(sp)
    800057e0:	1000                	addi	s0,sp,32
    800057e2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800057e4:	ffffc097          	auipc	ra,0xffffc
    800057e8:	424080e7          	jalr	1060(ra) # 80001c08 <myproc>
    800057ec:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800057ee:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7fdbc878>
    800057f2:	4501                	li	a0,0
    800057f4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800057f6:	6398                	ld	a4,0(a5)
    800057f8:	cb19                	beqz	a4,8000580e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800057fa:	2505                	addiw	a0,a0,1
    800057fc:	07a1                	addi	a5,a5,8
    800057fe:	fed51ce3          	bne	a0,a3,800057f6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005802:	557d                	li	a0,-1
}
    80005804:	60e2                	ld	ra,24(sp)
    80005806:	6442                	ld	s0,16(sp)
    80005808:	64a2                	ld	s1,8(sp)
    8000580a:	6105                	addi	sp,sp,32
    8000580c:	8082                	ret
      p->ofile[fd] = f;
    8000580e:	01a50793          	addi	a5,a0,26
    80005812:	078e                	slli	a5,a5,0x3
    80005814:	963e                	add	a2,a2,a5
    80005816:	e204                	sd	s1,0(a2)
      return fd;
    80005818:	b7f5                	j	80005804 <fdalloc+0x2c>

000000008000581a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000581a:	715d                	addi	sp,sp,-80
    8000581c:	e486                	sd	ra,72(sp)
    8000581e:	e0a2                	sd	s0,64(sp)
    80005820:	fc26                	sd	s1,56(sp)
    80005822:	f84a                	sd	s2,48(sp)
    80005824:	f44e                	sd	s3,40(sp)
    80005826:	f052                	sd	s4,32(sp)
    80005828:	ec56                	sd	s5,24(sp)
    8000582a:	e85a                	sd	s6,16(sp)
    8000582c:	0880                	addi	s0,sp,80
    8000582e:	8b2e                	mv	s6,a1
    80005830:	89b2                	mv	s3,a2
    80005832:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005834:	fb040593          	addi	a1,s0,-80
    80005838:	fffff097          	auipc	ra,0xfffff
    8000583c:	e4e080e7          	jalr	-434(ra) # 80004686 <nameiparent>
    80005840:	84aa                	mv	s1,a0
    80005842:	16050063          	beqz	a0,800059a2 <create+0x188>
    return 0;

  ilock(dp);
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	67c080e7          	jalr	1660(ra) # 80003ec2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000584e:	4601                	li	a2,0
    80005850:	fb040593          	addi	a1,s0,-80
    80005854:	8526                	mv	a0,s1
    80005856:	fffff097          	auipc	ra,0xfffff
    8000585a:	b50080e7          	jalr	-1200(ra) # 800043a6 <dirlookup>
    8000585e:	8aaa                	mv	s5,a0
    80005860:	c931                	beqz	a0,800058b4 <create+0x9a>
    iunlockput(dp);
    80005862:	8526                	mv	a0,s1
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	8c0080e7          	jalr	-1856(ra) # 80004124 <iunlockput>
    ilock(ip);
    8000586c:	8556                	mv	a0,s5
    8000586e:	ffffe097          	auipc	ra,0xffffe
    80005872:	654080e7          	jalr	1620(ra) # 80003ec2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005876:	000b059b          	sext.w	a1,s6
    8000587a:	4789                	li	a5,2
    8000587c:	02f59563          	bne	a1,a5,800058a6 <create+0x8c>
    80005880:	044ad783          	lhu	a5,68(s5)
    80005884:	37f9                	addiw	a5,a5,-2
    80005886:	17c2                	slli	a5,a5,0x30
    80005888:	93c1                	srli	a5,a5,0x30
    8000588a:	4705                	li	a4,1
    8000588c:	00f76d63          	bltu	a4,a5,800058a6 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005890:	8556                	mv	a0,s5
    80005892:	60a6                	ld	ra,72(sp)
    80005894:	6406                	ld	s0,64(sp)
    80005896:	74e2                	ld	s1,56(sp)
    80005898:	7942                	ld	s2,48(sp)
    8000589a:	79a2                	ld	s3,40(sp)
    8000589c:	7a02                	ld	s4,32(sp)
    8000589e:	6ae2                	ld	s5,24(sp)
    800058a0:	6b42                	ld	s6,16(sp)
    800058a2:	6161                	addi	sp,sp,80
    800058a4:	8082                	ret
    iunlockput(ip);
    800058a6:	8556                	mv	a0,s5
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	87c080e7          	jalr	-1924(ra) # 80004124 <iunlockput>
    return 0;
    800058b0:	4a81                	li	s5,0
    800058b2:	bff9                	j	80005890 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800058b4:	85da                	mv	a1,s6
    800058b6:	4088                	lw	a0,0(s1)
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	46e080e7          	jalr	1134(ra) # 80003d26 <ialloc>
    800058c0:	8a2a                	mv	s4,a0
    800058c2:	c921                	beqz	a0,80005912 <create+0xf8>
  ilock(ip);
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	5fe080e7          	jalr	1534(ra) # 80003ec2 <ilock>
  ip->major = major;
    800058cc:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800058d0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800058d4:	4785                	li	a5,1
    800058d6:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    800058da:	8552                	mv	a0,s4
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	51c080e7          	jalr	1308(ra) # 80003df8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800058e4:	000b059b          	sext.w	a1,s6
    800058e8:	4785                	li	a5,1
    800058ea:	02f58b63          	beq	a1,a5,80005920 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800058ee:	004a2603          	lw	a2,4(s4)
    800058f2:	fb040593          	addi	a1,s0,-80
    800058f6:	8526                	mv	a0,s1
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	cbe080e7          	jalr	-834(ra) # 800045b6 <dirlink>
    80005900:	06054f63          	bltz	a0,8000597e <create+0x164>
  iunlockput(dp);
    80005904:	8526                	mv	a0,s1
    80005906:	fffff097          	auipc	ra,0xfffff
    8000590a:	81e080e7          	jalr	-2018(ra) # 80004124 <iunlockput>
  return ip;
    8000590e:	8ad2                	mv	s5,s4
    80005910:	b741                	j	80005890 <create+0x76>
    iunlockput(dp);
    80005912:	8526                	mv	a0,s1
    80005914:	fffff097          	auipc	ra,0xfffff
    80005918:	810080e7          	jalr	-2032(ra) # 80004124 <iunlockput>
    return 0;
    8000591c:	8ad2                	mv	s5,s4
    8000591e:	bf8d                	j	80005890 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005920:	004a2603          	lw	a2,4(s4)
    80005924:	00003597          	auipc	a1,0x3
    80005928:	ec458593          	addi	a1,a1,-316 # 800087e8 <syscalls+0x2b8>
    8000592c:	8552                	mv	a0,s4
    8000592e:	fffff097          	auipc	ra,0xfffff
    80005932:	c88080e7          	jalr	-888(ra) # 800045b6 <dirlink>
    80005936:	04054463          	bltz	a0,8000597e <create+0x164>
    8000593a:	40d0                	lw	a2,4(s1)
    8000593c:	00003597          	auipc	a1,0x3
    80005940:	eb458593          	addi	a1,a1,-332 # 800087f0 <syscalls+0x2c0>
    80005944:	8552                	mv	a0,s4
    80005946:	fffff097          	auipc	ra,0xfffff
    8000594a:	c70080e7          	jalr	-912(ra) # 800045b6 <dirlink>
    8000594e:	02054863          	bltz	a0,8000597e <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    80005952:	004a2603          	lw	a2,4(s4)
    80005956:	fb040593          	addi	a1,s0,-80
    8000595a:	8526                	mv	a0,s1
    8000595c:	fffff097          	auipc	ra,0xfffff
    80005960:	c5a080e7          	jalr	-934(ra) # 800045b6 <dirlink>
    80005964:	00054d63          	bltz	a0,8000597e <create+0x164>
    dp->nlink++;  // for ".."
    80005968:	04a4d783          	lhu	a5,74(s1)
    8000596c:	2785                	addiw	a5,a5,1
    8000596e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005972:	8526                	mv	a0,s1
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	484080e7          	jalr	1156(ra) # 80003df8 <iupdate>
    8000597c:	b761                	j	80005904 <create+0xea>
  ip->nlink = 0;
    8000597e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005982:	8552                	mv	a0,s4
    80005984:	ffffe097          	auipc	ra,0xffffe
    80005988:	474080e7          	jalr	1140(ra) # 80003df8 <iupdate>
  iunlockput(ip);
    8000598c:	8552                	mv	a0,s4
    8000598e:	ffffe097          	auipc	ra,0xffffe
    80005992:	796080e7          	jalr	1942(ra) # 80004124 <iunlockput>
  iunlockput(dp);
    80005996:	8526                	mv	a0,s1
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	78c080e7          	jalr	1932(ra) # 80004124 <iunlockput>
  return 0;
    800059a0:	bdc5                	j	80005890 <create+0x76>
    return 0;
    800059a2:	8aaa                	mv	s5,a0
    800059a4:	b5f5                	j	80005890 <create+0x76>

00000000800059a6 <sys_dup>:
{
    800059a6:	7179                	addi	sp,sp,-48
    800059a8:	f406                	sd	ra,40(sp)
    800059aa:	f022                	sd	s0,32(sp)
    800059ac:	ec26                	sd	s1,24(sp)
    800059ae:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800059b0:	fd840613          	addi	a2,s0,-40
    800059b4:	4581                	li	a1,0
    800059b6:	4501                	li	a0,0
    800059b8:	00000097          	auipc	ra,0x0
    800059bc:	dc0080e7          	jalr	-576(ra) # 80005778 <argfd>
    return -1;
    800059c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800059c2:	02054363          	bltz	a0,800059e8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800059c6:	fd843503          	ld	a0,-40(s0)
    800059ca:	00000097          	auipc	ra,0x0
    800059ce:	e0e080e7          	jalr	-498(ra) # 800057d8 <fdalloc>
    800059d2:	84aa                	mv	s1,a0
    return -1;
    800059d4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800059d6:	00054963          	bltz	a0,800059e8 <sys_dup+0x42>
  filedup(f);
    800059da:	fd843503          	ld	a0,-40(s0)
    800059de:	fffff097          	auipc	ra,0xfffff
    800059e2:	320080e7          	jalr	800(ra) # 80004cfe <filedup>
  return fd;
    800059e6:	87a6                	mv	a5,s1
}
    800059e8:	853e                	mv	a0,a5
    800059ea:	70a2                	ld	ra,40(sp)
    800059ec:	7402                	ld	s0,32(sp)
    800059ee:	64e2                	ld	s1,24(sp)
    800059f0:	6145                	addi	sp,sp,48
    800059f2:	8082                	ret

00000000800059f4 <sys_getreadcount>:
{
    800059f4:	1141                	addi	sp,sp,-16
    800059f6:	e422                	sd	s0,8(sp)
    800059f8:	0800                	addi	s0,sp,16
}
    800059fa:	00003517          	auipc	a0,0x3
    800059fe:	fca52503          	lw	a0,-54(a0) # 800089c4 <readCount>
    80005a02:	6422                	ld	s0,8(sp)
    80005a04:	0141                	addi	sp,sp,16
    80005a06:	8082                	ret

0000000080005a08 <sys_read>:
{
    80005a08:	7179                	addi	sp,sp,-48
    80005a0a:	f406                	sd	ra,40(sp)
    80005a0c:	f022                	sd	s0,32(sp)
    80005a0e:	1800                	addi	s0,sp,48
  readCount++;
    80005a10:	00003717          	auipc	a4,0x3
    80005a14:	fb470713          	addi	a4,a4,-76 # 800089c4 <readCount>
    80005a18:	431c                	lw	a5,0(a4)
    80005a1a:	2785                	addiw	a5,a5,1
    80005a1c:	c31c                	sw	a5,0(a4)
  argaddr(1, &p);
    80005a1e:	fd840593          	addi	a1,s0,-40
    80005a22:	4505                	li	a0,1
    80005a24:	ffffd097          	auipc	ra,0xffffd
    80005a28:	782080e7          	jalr	1922(ra) # 800031a6 <argaddr>
  argint(2, &n);
    80005a2c:	fe440593          	addi	a1,s0,-28
    80005a30:	4509                	li	a0,2
    80005a32:	ffffd097          	auipc	ra,0xffffd
    80005a36:	754080e7          	jalr	1876(ra) # 80003186 <argint>
  if(argfd(0, 0, &f) < 0)
    80005a3a:	fe840613          	addi	a2,s0,-24
    80005a3e:	4581                	li	a1,0
    80005a40:	4501                	li	a0,0
    80005a42:	00000097          	auipc	ra,0x0
    80005a46:	d36080e7          	jalr	-714(ra) # 80005778 <argfd>
    80005a4a:	87aa                	mv	a5,a0
    return -1;
    80005a4c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a4e:	0007cc63          	bltz	a5,80005a66 <sys_read+0x5e>
  return fileread(f, p, n);
    80005a52:	fe442603          	lw	a2,-28(s0)
    80005a56:	fd843583          	ld	a1,-40(s0)
    80005a5a:	fe843503          	ld	a0,-24(s0)
    80005a5e:	fffff097          	auipc	ra,0xfffff
    80005a62:	42c080e7          	jalr	1068(ra) # 80004e8a <fileread>
}
    80005a66:	70a2                	ld	ra,40(sp)
    80005a68:	7402                	ld	s0,32(sp)
    80005a6a:	6145                	addi	sp,sp,48
    80005a6c:	8082                	ret

0000000080005a6e <sys_write>:
{
    80005a6e:	7179                	addi	sp,sp,-48
    80005a70:	f406                	sd	ra,40(sp)
    80005a72:	f022                	sd	s0,32(sp)
    80005a74:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a76:	fd840593          	addi	a1,s0,-40
    80005a7a:	4505                	li	a0,1
    80005a7c:	ffffd097          	auipc	ra,0xffffd
    80005a80:	72a080e7          	jalr	1834(ra) # 800031a6 <argaddr>
  argint(2, &n);
    80005a84:	fe440593          	addi	a1,s0,-28
    80005a88:	4509                	li	a0,2
    80005a8a:	ffffd097          	auipc	ra,0xffffd
    80005a8e:	6fc080e7          	jalr	1788(ra) # 80003186 <argint>
  if(argfd(0, 0, &f) < 0)
    80005a92:	fe840613          	addi	a2,s0,-24
    80005a96:	4581                	li	a1,0
    80005a98:	4501                	li	a0,0
    80005a9a:	00000097          	auipc	ra,0x0
    80005a9e:	cde080e7          	jalr	-802(ra) # 80005778 <argfd>
    80005aa2:	87aa                	mv	a5,a0
    return -1;
    80005aa4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005aa6:	0007cc63          	bltz	a5,80005abe <sys_write+0x50>
  return filewrite(f, p, n);
    80005aaa:	fe442603          	lw	a2,-28(s0)
    80005aae:	fd843583          	ld	a1,-40(s0)
    80005ab2:	fe843503          	ld	a0,-24(s0)
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	496080e7          	jalr	1174(ra) # 80004f4c <filewrite>
}
    80005abe:	70a2                	ld	ra,40(sp)
    80005ac0:	7402                	ld	s0,32(sp)
    80005ac2:	6145                	addi	sp,sp,48
    80005ac4:	8082                	ret

0000000080005ac6 <sys_close>:
{
    80005ac6:	1101                	addi	sp,sp,-32
    80005ac8:	ec06                	sd	ra,24(sp)
    80005aca:	e822                	sd	s0,16(sp)
    80005acc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005ace:	fe040613          	addi	a2,s0,-32
    80005ad2:	fec40593          	addi	a1,s0,-20
    80005ad6:	4501                	li	a0,0
    80005ad8:	00000097          	auipc	ra,0x0
    80005adc:	ca0080e7          	jalr	-864(ra) # 80005778 <argfd>
    return -1;
    80005ae0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005ae2:	02054463          	bltz	a0,80005b0a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005ae6:	ffffc097          	auipc	ra,0xffffc
    80005aea:	122080e7          	jalr	290(ra) # 80001c08 <myproc>
    80005aee:	fec42783          	lw	a5,-20(s0)
    80005af2:	07e9                	addi	a5,a5,26
    80005af4:	078e                	slli	a5,a5,0x3
    80005af6:	97aa                	add	a5,a5,a0
    80005af8:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005afc:	fe043503          	ld	a0,-32(s0)
    80005b00:	fffff097          	auipc	ra,0xfffff
    80005b04:	250080e7          	jalr	592(ra) # 80004d50 <fileclose>
  return 0;
    80005b08:	4781                	li	a5,0
}
    80005b0a:	853e                	mv	a0,a5
    80005b0c:	60e2                	ld	ra,24(sp)
    80005b0e:	6442                	ld	s0,16(sp)
    80005b10:	6105                	addi	sp,sp,32
    80005b12:	8082                	ret

0000000080005b14 <sys_fstat>:
{
    80005b14:	1101                	addi	sp,sp,-32
    80005b16:	ec06                	sd	ra,24(sp)
    80005b18:	e822                	sd	s0,16(sp)
    80005b1a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005b1c:	fe040593          	addi	a1,s0,-32
    80005b20:	4505                	li	a0,1
    80005b22:	ffffd097          	auipc	ra,0xffffd
    80005b26:	684080e7          	jalr	1668(ra) # 800031a6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005b2a:	fe840613          	addi	a2,s0,-24
    80005b2e:	4581                	li	a1,0
    80005b30:	4501                	li	a0,0
    80005b32:	00000097          	auipc	ra,0x0
    80005b36:	c46080e7          	jalr	-954(ra) # 80005778 <argfd>
    80005b3a:	87aa                	mv	a5,a0
    return -1;
    80005b3c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b3e:	0007ca63          	bltz	a5,80005b52 <sys_fstat+0x3e>
  return filestat(f, st);
    80005b42:	fe043583          	ld	a1,-32(s0)
    80005b46:	fe843503          	ld	a0,-24(s0)
    80005b4a:	fffff097          	auipc	ra,0xfffff
    80005b4e:	2ce080e7          	jalr	718(ra) # 80004e18 <filestat>
}
    80005b52:	60e2                	ld	ra,24(sp)
    80005b54:	6442                	ld	s0,16(sp)
    80005b56:	6105                	addi	sp,sp,32
    80005b58:	8082                	ret

0000000080005b5a <sys_link>:
{
    80005b5a:	7169                	addi	sp,sp,-304
    80005b5c:	f606                	sd	ra,296(sp)
    80005b5e:	f222                	sd	s0,288(sp)
    80005b60:	ee26                	sd	s1,280(sp)
    80005b62:	ea4a                	sd	s2,272(sp)
    80005b64:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b66:	08000613          	li	a2,128
    80005b6a:	ed040593          	addi	a1,s0,-304
    80005b6e:	4501                	li	a0,0
    80005b70:	ffffd097          	auipc	ra,0xffffd
    80005b74:	656080e7          	jalr	1622(ra) # 800031c6 <argstr>
    return -1;
    80005b78:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b7a:	10054e63          	bltz	a0,80005c96 <sys_link+0x13c>
    80005b7e:	08000613          	li	a2,128
    80005b82:	f5040593          	addi	a1,s0,-176
    80005b86:	4505                	li	a0,1
    80005b88:	ffffd097          	auipc	ra,0xffffd
    80005b8c:	63e080e7          	jalr	1598(ra) # 800031c6 <argstr>
    return -1;
    80005b90:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b92:	10054263          	bltz	a0,80005c96 <sys_link+0x13c>
  begin_op();
    80005b96:	fffff097          	auipc	ra,0xfffff
    80005b9a:	cee080e7          	jalr	-786(ra) # 80004884 <begin_op>
  if((ip = namei(old)) == 0){
    80005b9e:	ed040513          	addi	a0,s0,-304
    80005ba2:	fffff097          	auipc	ra,0xfffff
    80005ba6:	ac6080e7          	jalr	-1338(ra) # 80004668 <namei>
    80005baa:	84aa                	mv	s1,a0
    80005bac:	c551                	beqz	a0,80005c38 <sys_link+0xde>
  ilock(ip);
    80005bae:	ffffe097          	auipc	ra,0xffffe
    80005bb2:	314080e7          	jalr	788(ra) # 80003ec2 <ilock>
  if(ip->type == T_DIR){
    80005bb6:	04449703          	lh	a4,68(s1)
    80005bba:	4785                	li	a5,1
    80005bbc:	08f70463          	beq	a4,a5,80005c44 <sys_link+0xea>
  ip->nlink++;
    80005bc0:	04a4d783          	lhu	a5,74(s1)
    80005bc4:	2785                	addiw	a5,a5,1
    80005bc6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005bca:	8526                	mv	a0,s1
    80005bcc:	ffffe097          	auipc	ra,0xffffe
    80005bd0:	22c080e7          	jalr	556(ra) # 80003df8 <iupdate>
  iunlock(ip);
    80005bd4:	8526                	mv	a0,s1
    80005bd6:	ffffe097          	auipc	ra,0xffffe
    80005bda:	3ae080e7          	jalr	942(ra) # 80003f84 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005bde:	fd040593          	addi	a1,s0,-48
    80005be2:	f5040513          	addi	a0,s0,-176
    80005be6:	fffff097          	auipc	ra,0xfffff
    80005bea:	aa0080e7          	jalr	-1376(ra) # 80004686 <nameiparent>
    80005bee:	892a                	mv	s2,a0
    80005bf0:	c935                	beqz	a0,80005c64 <sys_link+0x10a>
  ilock(dp);
    80005bf2:	ffffe097          	auipc	ra,0xffffe
    80005bf6:	2d0080e7          	jalr	720(ra) # 80003ec2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005bfa:	00092703          	lw	a4,0(s2)
    80005bfe:	409c                	lw	a5,0(s1)
    80005c00:	04f71d63          	bne	a4,a5,80005c5a <sys_link+0x100>
    80005c04:	40d0                	lw	a2,4(s1)
    80005c06:	fd040593          	addi	a1,s0,-48
    80005c0a:	854a                	mv	a0,s2
    80005c0c:	fffff097          	auipc	ra,0xfffff
    80005c10:	9aa080e7          	jalr	-1622(ra) # 800045b6 <dirlink>
    80005c14:	04054363          	bltz	a0,80005c5a <sys_link+0x100>
  iunlockput(dp);
    80005c18:	854a                	mv	a0,s2
    80005c1a:	ffffe097          	auipc	ra,0xffffe
    80005c1e:	50a080e7          	jalr	1290(ra) # 80004124 <iunlockput>
  iput(ip);
    80005c22:	8526                	mv	a0,s1
    80005c24:	ffffe097          	auipc	ra,0xffffe
    80005c28:	458080e7          	jalr	1112(ra) # 8000407c <iput>
  end_op();
    80005c2c:	fffff097          	auipc	ra,0xfffff
    80005c30:	cd8080e7          	jalr	-808(ra) # 80004904 <end_op>
  return 0;
    80005c34:	4781                	li	a5,0
    80005c36:	a085                	j	80005c96 <sys_link+0x13c>
    end_op();
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	ccc080e7          	jalr	-820(ra) # 80004904 <end_op>
    return -1;
    80005c40:	57fd                	li	a5,-1
    80005c42:	a891                	j	80005c96 <sys_link+0x13c>
    iunlockput(ip);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	4de080e7          	jalr	1246(ra) # 80004124 <iunlockput>
    end_op();
    80005c4e:	fffff097          	auipc	ra,0xfffff
    80005c52:	cb6080e7          	jalr	-842(ra) # 80004904 <end_op>
    return -1;
    80005c56:	57fd                	li	a5,-1
    80005c58:	a83d                	j	80005c96 <sys_link+0x13c>
    iunlockput(dp);
    80005c5a:	854a                	mv	a0,s2
    80005c5c:	ffffe097          	auipc	ra,0xffffe
    80005c60:	4c8080e7          	jalr	1224(ra) # 80004124 <iunlockput>
  ilock(ip);
    80005c64:	8526                	mv	a0,s1
    80005c66:	ffffe097          	auipc	ra,0xffffe
    80005c6a:	25c080e7          	jalr	604(ra) # 80003ec2 <ilock>
  ip->nlink--;
    80005c6e:	04a4d783          	lhu	a5,74(s1)
    80005c72:	37fd                	addiw	a5,a5,-1
    80005c74:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c78:	8526                	mv	a0,s1
    80005c7a:	ffffe097          	auipc	ra,0xffffe
    80005c7e:	17e080e7          	jalr	382(ra) # 80003df8 <iupdate>
  iunlockput(ip);
    80005c82:	8526                	mv	a0,s1
    80005c84:	ffffe097          	auipc	ra,0xffffe
    80005c88:	4a0080e7          	jalr	1184(ra) # 80004124 <iunlockput>
  end_op();
    80005c8c:	fffff097          	auipc	ra,0xfffff
    80005c90:	c78080e7          	jalr	-904(ra) # 80004904 <end_op>
  return -1;
    80005c94:	57fd                	li	a5,-1
}
    80005c96:	853e                	mv	a0,a5
    80005c98:	70b2                	ld	ra,296(sp)
    80005c9a:	7412                	ld	s0,288(sp)
    80005c9c:	64f2                	ld	s1,280(sp)
    80005c9e:	6952                	ld	s2,272(sp)
    80005ca0:	6155                	addi	sp,sp,304
    80005ca2:	8082                	ret

0000000080005ca4 <sys_unlink>:
{
    80005ca4:	7151                	addi	sp,sp,-240
    80005ca6:	f586                	sd	ra,232(sp)
    80005ca8:	f1a2                	sd	s0,224(sp)
    80005caa:	eda6                	sd	s1,216(sp)
    80005cac:	e9ca                	sd	s2,208(sp)
    80005cae:	e5ce                	sd	s3,200(sp)
    80005cb0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005cb2:	08000613          	li	a2,128
    80005cb6:	f3040593          	addi	a1,s0,-208
    80005cba:	4501                	li	a0,0
    80005cbc:	ffffd097          	auipc	ra,0xffffd
    80005cc0:	50a080e7          	jalr	1290(ra) # 800031c6 <argstr>
    80005cc4:	18054163          	bltz	a0,80005e46 <sys_unlink+0x1a2>
  begin_op();
    80005cc8:	fffff097          	auipc	ra,0xfffff
    80005ccc:	bbc080e7          	jalr	-1092(ra) # 80004884 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005cd0:	fb040593          	addi	a1,s0,-80
    80005cd4:	f3040513          	addi	a0,s0,-208
    80005cd8:	fffff097          	auipc	ra,0xfffff
    80005cdc:	9ae080e7          	jalr	-1618(ra) # 80004686 <nameiparent>
    80005ce0:	84aa                	mv	s1,a0
    80005ce2:	c979                	beqz	a0,80005db8 <sys_unlink+0x114>
  ilock(dp);
    80005ce4:	ffffe097          	auipc	ra,0xffffe
    80005ce8:	1de080e7          	jalr	478(ra) # 80003ec2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005cec:	00003597          	auipc	a1,0x3
    80005cf0:	afc58593          	addi	a1,a1,-1284 # 800087e8 <syscalls+0x2b8>
    80005cf4:	fb040513          	addi	a0,s0,-80
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	694080e7          	jalr	1684(ra) # 8000438c <namecmp>
    80005d00:	14050a63          	beqz	a0,80005e54 <sys_unlink+0x1b0>
    80005d04:	00003597          	auipc	a1,0x3
    80005d08:	aec58593          	addi	a1,a1,-1300 # 800087f0 <syscalls+0x2c0>
    80005d0c:	fb040513          	addi	a0,s0,-80
    80005d10:	ffffe097          	auipc	ra,0xffffe
    80005d14:	67c080e7          	jalr	1660(ra) # 8000438c <namecmp>
    80005d18:	12050e63          	beqz	a0,80005e54 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005d1c:	f2c40613          	addi	a2,s0,-212
    80005d20:	fb040593          	addi	a1,s0,-80
    80005d24:	8526                	mv	a0,s1
    80005d26:	ffffe097          	auipc	ra,0xffffe
    80005d2a:	680080e7          	jalr	1664(ra) # 800043a6 <dirlookup>
    80005d2e:	892a                	mv	s2,a0
    80005d30:	12050263          	beqz	a0,80005e54 <sys_unlink+0x1b0>
  ilock(ip);
    80005d34:	ffffe097          	auipc	ra,0xffffe
    80005d38:	18e080e7          	jalr	398(ra) # 80003ec2 <ilock>
  if(ip->nlink < 1)
    80005d3c:	04a91783          	lh	a5,74(s2)
    80005d40:	08f05263          	blez	a5,80005dc4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005d44:	04491703          	lh	a4,68(s2)
    80005d48:	4785                	li	a5,1
    80005d4a:	08f70563          	beq	a4,a5,80005dd4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005d4e:	4641                	li	a2,16
    80005d50:	4581                	li	a1,0
    80005d52:	fc040513          	addi	a0,s0,-64
    80005d56:	ffffb097          	auipc	ra,0xffffb
    80005d5a:	0ac080e7          	jalr	172(ra) # 80000e02 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d5e:	4741                	li	a4,16
    80005d60:	f2c42683          	lw	a3,-212(s0)
    80005d64:	fc040613          	addi	a2,s0,-64
    80005d68:	4581                	li	a1,0
    80005d6a:	8526                	mv	a0,s1
    80005d6c:	ffffe097          	auipc	ra,0xffffe
    80005d70:	502080e7          	jalr	1282(ra) # 8000426e <writei>
    80005d74:	47c1                	li	a5,16
    80005d76:	0af51563          	bne	a0,a5,80005e20 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005d7a:	04491703          	lh	a4,68(s2)
    80005d7e:	4785                	li	a5,1
    80005d80:	0af70863          	beq	a4,a5,80005e30 <sys_unlink+0x18c>
  iunlockput(dp);
    80005d84:	8526                	mv	a0,s1
    80005d86:	ffffe097          	auipc	ra,0xffffe
    80005d8a:	39e080e7          	jalr	926(ra) # 80004124 <iunlockput>
  ip->nlink--;
    80005d8e:	04a95783          	lhu	a5,74(s2)
    80005d92:	37fd                	addiw	a5,a5,-1
    80005d94:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005d98:	854a                	mv	a0,s2
    80005d9a:	ffffe097          	auipc	ra,0xffffe
    80005d9e:	05e080e7          	jalr	94(ra) # 80003df8 <iupdate>
  iunlockput(ip);
    80005da2:	854a                	mv	a0,s2
    80005da4:	ffffe097          	auipc	ra,0xffffe
    80005da8:	380080e7          	jalr	896(ra) # 80004124 <iunlockput>
  end_op();
    80005dac:	fffff097          	auipc	ra,0xfffff
    80005db0:	b58080e7          	jalr	-1192(ra) # 80004904 <end_op>
  return 0;
    80005db4:	4501                	li	a0,0
    80005db6:	a84d                	j	80005e68 <sys_unlink+0x1c4>
    end_op();
    80005db8:	fffff097          	auipc	ra,0xfffff
    80005dbc:	b4c080e7          	jalr	-1204(ra) # 80004904 <end_op>
    return -1;
    80005dc0:	557d                	li	a0,-1
    80005dc2:	a05d                	j	80005e68 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005dc4:	00003517          	auipc	a0,0x3
    80005dc8:	a3450513          	addi	a0,a0,-1484 # 800087f8 <syscalls+0x2c8>
    80005dcc:	ffffa097          	auipc	ra,0xffffa
    80005dd0:	778080e7          	jalr	1912(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005dd4:	04c92703          	lw	a4,76(s2)
    80005dd8:	02000793          	li	a5,32
    80005ddc:	f6e7f9e3          	bgeu	a5,a4,80005d4e <sys_unlink+0xaa>
    80005de0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005de4:	4741                	li	a4,16
    80005de6:	86ce                	mv	a3,s3
    80005de8:	f1840613          	addi	a2,s0,-232
    80005dec:	4581                	li	a1,0
    80005dee:	854a                	mv	a0,s2
    80005df0:	ffffe097          	auipc	ra,0xffffe
    80005df4:	386080e7          	jalr	902(ra) # 80004176 <readi>
    80005df8:	47c1                	li	a5,16
    80005dfa:	00f51b63          	bne	a0,a5,80005e10 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005dfe:	f1845783          	lhu	a5,-232(s0)
    80005e02:	e7a1                	bnez	a5,80005e4a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e04:	29c1                	addiw	s3,s3,16
    80005e06:	04c92783          	lw	a5,76(s2)
    80005e0a:	fcf9ede3          	bltu	s3,a5,80005de4 <sys_unlink+0x140>
    80005e0e:	b781                	j	80005d4e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005e10:	00003517          	auipc	a0,0x3
    80005e14:	a0050513          	addi	a0,a0,-1536 # 80008810 <syscalls+0x2e0>
    80005e18:	ffffa097          	auipc	ra,0xffffa
    80005e1c:	72c080e7          	jalr	1836(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005e20:	00003517          	auipc	a0,0x3
    80005e24:	a0850513          	addi	a0,a0,-1528 # 80008828 <syscalls+0x2f8>
    80005e28:	ffffa097          	auipc	ra,0xffffa
    80005e2c:	71c080e7          	jalr	1820(ra) # 80000544 <panic>
    dp->nlink--;
    80005e30:	04a4d783          	lhu	a5,74(s1)
    80005e34:	37fd                	addiw	a5,a5,-1
    80005e36:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005e3a:	8526                	mv	a0,s1
    80005e3c:	ffffe097          	auipc	ra,0xffffe
    80005e40:	fbc080e7          	jalr	-68(ra) # 80003df8 <iupdate>
    80005e44:	b781                	j	80005d84 <sys_unlink+0xe0>
    return -1;
    80005e46:	557d                	li	a0,-1
    80005e48:	a005                	j	80005e68 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005e4a:	854a                	mv	a0,s2
    80005e4c:	ffffe097          	auipc	ra,0xffffe
    80005e50:	2d8080e7          	jalr	728(ra) # 80004124 <iunlockput>
  iunlockput(dp);
    80005e54:	8526                	mv	a0,s1
    80005e56:	ffffe097          	auipc	ra,0xffffe
    80005e5a:	2ce080e7          	jalr	718(ra) # 80004124 <iunlockput>
  end_op();
    80005e5e:	fffff097          	auipc	ra,0xfffff
    80005e62:	aa6080e7          	jalr	-1370(ra) # 80004904 <end_op>
  return -1;
    80005e66:	557d                	li	a0,-1
}
    80005e68:	70ae                	ld	ra,232(sp)
    80005e6a:	740e                	ld	s0,224(sp)
    80005e6c:	64ee                	ld	s1,216(sp)
    80005e6e:	694e                	ld	s2,208(sp)
    80005e70:	69ae                	ld	s3,200(sp)
    80005e72:	616d                	addi	sp,sp,240
    80005e74:	8082                	ret

0000000080005e76 <sys_open>:

uint64
sys_open(void)
{
    80005e76:	7131                	addi	sp,sp,-192
    80005e78:	fd06                	sd	ra,184(sp)
    80005e7a:	f922                	sd	s0,176(sp)
    80005e7c:	f526                	sd	s1,168(sp)
    80005e7e:	f14a                	sd	s2,160(sp)
    80005e80:	ed4e                	sd	s3,152(sp)
    80005e82:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005e84:	f4c40593          	addi	a1,s0,-180
    80005e88:	4505                	li	a0,1
    80005e8a:	ffffd097          	auipc	ra,0xffffd
    80005e8e:	2fc080e7          	jalr	764(ra) # 80003186 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e92:	08000613          	li	a2,128
    80005e96:	f5040593          	addi	a1,s0,-176
    80005e9a:	4501                	li	a0,0
    80005e9c:	ffffd097          	auipc	ra,0xffffd
    80005ea0:	32a080e7          	jalr	810(ra) # 800031c6 <argstr>
    80005ea4:	87aa                	mv	a5,a0
    return -1;
    80005ea6:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ea8:	0a07c963          	bltz	a5,80005f5a <sys_open+0xe4>

  begin_op();
    80005eac:	fffff097          	auipc	ra,0xfffff
    80005eb0:	9d8080e7          	jalr	-1576(ra) # 80004884 <begin_op>

  if(omode & O_CREATE){
    80005eb4:	f4c42783          	lw	a5,-180(s0)
    80005eb8:	2007f793          	andi	a5,a5,512
    80005ebc:	cfc5                	beqz	a5,80005f74 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005ebe:	4681                	li	a3,0
    80005ec0:	4601                	li	a2,0
    80005ec2:	4589                	li	a1,2
    80005ec4:	f5040513          	addi	a0,s0,-176
    80005ec8:	00000097          	auipc	ra,0x0
    80005ecc:	952080e7          	jalr	-1710(ra) # 8000581a <create>
    80005ed0:	84aa                	mv	s1,a0
    if(ip == 0){
    80005ed2:	c959                	beqz	a0,80005f68 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005ed4:	04449703          	lh	a4,68(s1)
    80005ed8:	478d                	li	a5,3
    80005eda:	00f71763          	bne	a4,a5,80005ee8 <sys_open+0x72>
    80005ede:	0464d703          	lhu	a4,70(s1)
    80005ee2:	47a5                	li	a5,9
    80005ee4:	0ce7ed63          	bltu	a5,a4,80005fbe <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ee8:	fffff097          	auipc	ra,0xfffff
    80005eec:	dac080e7          	jalr	-596(ra) # 80004c94 <filealloc>
    80005ef0:	89aa                	mv	s3,a0
    80005ef2:	10050363          	beqz	a0,80005ff8 <sys_open+0x182>
    80005ef6:	00000097          	auipc	ra,0x0
    80005efa:	8e2080e7          	jalr	-1822(ra) # 800057d8 <fdalloc>
    80005efe:	892a                	mv	s2,a0
    80005f00:	0e054763          	bltz	a0,80005fee <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005f04:	04449703          	lh	a4,68(s1)
    80005f08:	478d                	li	a5,3
    80005f0a:	0cf70563          	beq	a4,a5,80005fd4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005f0e:	4789                	li	a5,2
    80005f10:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005f14:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005f18:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005f1c:	f4c42783          	lw	a5,-180(s0)
    80005f20:	0017c713          	xori	a4,a5,1
    80005f24:	8b05                	andi	a4,a4,1
    80005f26:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f2a:	0037f713          	andi	a4,a5,3
    80005f2e:	00e03733          	snez	a4,a4
    80005f32:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005f36:	4007f793          	andi	a5,a5,1024
    80005f3a:	c791                	beqz	a5,80005f46 <sys_open+0xd0>
    80005f3c:	04449703          	lh	a4,68(s1)
    80005f40:	4789                	li	a5,2
    80005f42:	0af70063          	beq	a4,a5,80005fe2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005f46:	8526                	mv	a0,s1
    80005f48:	ffffe097          	auipc	ra,0xffffe
    80005f4c:	03c080e7          	jalr	60(ra) # 80003f84 <iunlock>
  end_op();
    80005f50:	fffff097          	auipc	ra,0xfffff
    80005f54:	9b4080e7          	jalr	-1612(ra) # 80004904 <end_op>

  return fd;
    80005f58:	854a                	mv	a0,s2
}
    80005f5a:	70ea                	ld	ra,184(sp)
    80005f5c:	744a                	ld	s0,176(sp)
    80005f5e:	74aa                	ld	s1,168(sp)
    80005f60:	790a                	ld	s2,160(sp)
    80005f62:	69ea                	ld	s3,152(sp)
    80005f64:	6129                	addi	sp,sp,192
    80005f66:	8082                	ret
      end_op();
    80005f68:	fffff097          	auipc	ra,0xfffff
    80005f6c:	99c080e7          	jalr	-1636(ra) # 80004904 <end_op>
      return -1;
    80005f70:	557d                	li	a0,-1
    80005f72:	b7e5                	j	80005f5a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005f74:	f5040513          	addi	a0,s0,-176
    80005f78:	ffffe097          	auipc	ra,0xffffe
    80005f7c:	6f0080e7          	jalr	1776(ra) # 80004668 <namei>
    80005f80:	84aa                	mv	s1,a0
    80005f82:	c905                	beqz	a0,80005fb2 <sys_open+0x13c>
    ilock(ip);
    80005f84:	ffffe097          	auipc	ra,0xffffe
    80005f88:	f3e080e7          	jalr	-194(ra) # 80003ec2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005f8c:	04449703          	lh	a4,68(s1)
    80005f90:	4785                	li	a5,1
    80005f92:	f4f711e3          	bne	a4,a5,80005ed4 <sys_open+0x5e>
    80005f96:	f4c42783          	lw	a5,-180(s0)
    80005f9a:	d7b9                	beqz	a5,80005ee8 <sys_open+0x72>
      iunlockput(ip);
    80005f9c:	8526                	mv	a0,s1
    80005f9e:	ffffe097          	auipc	ra,0xffffe
    80005fa2:	186080e7          	jalr	390(ra) # 80004124 <iunlockput>
      end_op();
    80005fa6:	fffff097          	auipc	ra,0xfffff
    80005faa:	95e080e7          	jalr	-1698(ra) # 80004904 <end_op>
      return -1;
    80005fae:	557d                	li	a0,-1
    80005fb0:	b76d                	j	80005f5a <sys_open+0xe4>
      end_op();
    80005fb2:	fffff097          	auipc	ra,0xfffff
    80005fb6:	952080e7          	jalr	-1710(ra) # 80004904 <end_op>
      return -1;
    80005fba:	557d                	li	a0,-1
    80005fbc:	bf79                	j	80005f5a <sys_open+0xe4>
    iunlockput(ip);
    80005fbe:	8526                	mv	a0,s1
    80005fc0:	ffffe097          	auipc	ra,0xffffe
    80005fc4:	164080e7          	jalr	356(ra) # 80004124 <iunlockput>
    end_op();
    80005fc8:	fffff097          	auipc	ra,0xfffff
    80005fcc:	93c080e7          	jalr	-1732(ra) # 80004904 <end_op>
    return -1;
    80005fd0:	557d                	li	a0,-1
    80005fd2:	b761                	j	80005f5a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005fd4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005fd8:	04649783          	lh	a5,70(s1)
    80005fdc:	02f99223          	sh	a5,36(s3)
    80005fe0:	bf25                	j	80005f18 <sys_open+0xa2>
    itrunc(ip);
    80005fe2:	8526                	mv	a0,s1
    80005fe4:	ffffe097          	auipc	ra,0xffffe
    80005fe8:	fec080e7          	jalr	-20(ra) # 80003fd0 <itrunc>
    80005fec:	bfa9                	j	80005f46 <sys_open+0xd0>
      fileclose(f);
    80005fee:	854e                	mv	a0,s3
    80005ff0:	fffff097          	auipc	ra,0xfffff
    80005ff4:	d60080e7          	jalr	-672(ra) # 80004d50 <fileclose>
    iunlockput(ip);
    80005ff8:	8526                	mv	a0,s1
    80005ffa:	ffffe097          	auipc	ra,0xffffe
    80005ffe:	12a080e7          	jalr	298(ra) # 80004124 <iunlockput>
    end_op();
    80006002:	fffff097          	auipc	ra,0xfffff
    80006006:	902080e7          	jalr	-1790(ra) # 80004904 <end_op>
    return -1;
    8000600a:	557d                	li	a0,-1
    8000600c:	b7b9                	j	80005f5a <sys_open+0xe4>

000000008000600e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000600e:	7175                	addi	sp,sp,-144
    80006010:	e506                	sd	ra,136(sp)
    80006012:	e122                	sd	s0,128(sp)
    80006014:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006016:	fffff097          	auipc	ra,0xfffff
    8000601a:	86e080e7          	jalr	-1938(ra) # 80004884 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000601e:	08000613          	li	a2,128
    80006022:	f7040593          	addi	a1,s0,-144
    80006026:	4501                	li	a0,0
    80006028:	ffffd097          	auipc	ra,0xffffd
    8000602c:	19e080e7          	jalr	414(ra) # 800031c6 <argstr>
    80006030:	02054963          	bltz	a0,80006062 <sys_mkdir+0x54>
    80006034:	4681                	li	a3,0
    80006036:	4601                	li	a2,0
    80006038:	4585                	li	a1,1
    8000603a:	f7040513          	addi	a0,s0,-144
    8000603e:	fffff097          	auipc	ra,0xfffff
    80006042:	7dc080e7          	jalr	2012(ra) # 8000581a <create>
    80006046:	cd11                	beqz	a0,80006062 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006048:	ffffe097          	auipc	ra,0xffffe
    8000604c:	0dc080e7          	jalr	220(ra) # 80004124 <iunlockput>
  end_op();
    80006050:	fffff097          	auipc	ra,0xfffff
    80006054:	8b4080e7          	jalr	-1868(ra) # 80004904 <end_op>
  return 0;
    80006058:	4501                	li	a0,0
}
    8000605a:	60aa                	ld	ra,136(sp)
    8000605c:	640a                	ld	s0,128(sp)
    8000605e:	6149                	addi	sp,sp,144
    80006060:	8082                	ret
    end_op();
    80006062:	fffff097          	auipc	ra,0xfffff
    80006066:	8a2080e7          	jalr	-1886(ra) # 80004904 <end_op>
    return -1;
    8000606a:	557d                	li	a0,-1
    8000606c:	b7fd                	j	8000605a <sys_mkdir+0x4c>

000000008000606e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000606e:	7135                	addi	sp,sp,-160
    80006070:	ed06                	sd	ra,152(sp)
    80006072:	e922                	sd	s0,144(sp)
    80006074:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006076:	fffff097          	auipc	ra,0xfffff
    8000607a:	80e080e7          	jalr	-2034(ra) # 80004884 <begin_op>
  argint(1, &major);
    8000607e:	f6c40593          	addi	a1,s0,-148
    80006082:	4505                	li	a0,1
    80006084:	ffffd097          	auipc	ra,0xffffd
    80006088:	102080e7          	jalr	258(ra) # 80003186 <argint>
  argint(2, &minor);
    8000608c:	f6840593          	addi	a1,s0,-152
    80006090:	4509                	li	a0,2
    80006092:	ffffd097          	auipc	ra,0xffffd
    80006096:	0f4080e7          	jalr	244(ra) # 80003186 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000609a:	08000613          	li	a2,128
    8000609e:	f7040593          	addi	a1,s0,-144
    800060a2:	4501                	li	a0,0
    800060a4:	ffffd097          	auipc	ra,0xffffd
    800060a8:	122080e7          	jalr	290(ra) # 800031c6 <argstr>
    800060ac:	02054b63          	bltz	a0,800060e2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800060b0:	f6841683          	lh	a3,-152(s0)
    800060b4:	f6c41603          	lh	a2,-148(s0)
    800060b8:	458d                	li	a1,3
    800060ba:	f7040513          	addi	a0,s0,-144
    800060be:	fffff097          	auipc	ra,0xfffff
    800060c2:	75c080e7          	jalr	1884(ra) # 8000581a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800060c6:	cd11                	beqz	a0,800060e2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060c8:	ffffe097          	auipc	ra,0xffffe
    800060cc:	05c080e7          	jalr	92(ra) # 80004124 <iunlockput>
  end_op();
    800060d0:	fffff097          	auipc	ra,0xfffff
    800060d4:	834080e7          	jalr	-1996(ra) # 80004904 <end_op>
  return 0;
    800060d8:	4501                	li	a0,0
}
    800060da:	60ea                	ld	ra,152(sp)
    800060dc:	644a                	ld	s0,144(sp)
    800060de:	610d                	addi	sp,sp,160
    800060e0:	8082                	ret
    end_op();
    800060e2:	fffff097          	auipc	ra,0xfffff
    800060e6:	822080e7          	jalr	-2014(ra) # 80004904 <end_op>
    return -1;
    800060ea:	557d                	li	a0,-1
    800060ec:	b7fd                	j	800060da <sys_mknod+0x6c>

00000000800060ee <sys_chdir>:

uint64
sys_chdir(void)
{
    800060ee:	7135                	addi	sp,sp,-160
    800060f0:	ed06                	sd	ra,152(sp)
    800060f2:	e922                	sd	s0,144(sp)
    800060f4:	e526                	sd	s1,136(sp)
    800060f6:	e14a                	sd	s2,128(sp)
    800060f8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800060fa:	ffffc097          	auipc	ra,0xffffc
    800060fe:	b0e080e7          	jalr	-1266(ra) # 80001c08 <myproc>
    80006102:	892a                	mv	s2,a0
  
  begin_op();
    80006104:	ffffe097          	auipc	ra,0xffffe
    80006108:	780080e7          	jalr	1920(ra) # 80004884 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000610c:	08000613          	li	a2,128
    80006110:	f6040593          	addi	a1,s0,-160
    80006114:	4501                	li	a0,0
    80006116:	ffffd097          	auipc	ra,0xffffd
    8000611a:	0b0080e7          	jalr	176(ra) # 800031c6 <argstr>
    8000611e:	04054b63          	bltz	a0,80006174 <sys_chdir+0x86>
    80006122:	f6040513          	addi	a0,s0,-160
    80006126:	ffffe097          	auipc	ra,0xffffe
    8000612a:	542080e7          	jalr	1346(ra) # 80004668 <namei>
    8000612e:	84aa                	mv	s1,a0
    80006130:	c131                	beqz	a0,80006174 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006132:	ffffe097          	auipc	ra,0xffffe
    80006136:	d90080e7          	jalr	-624(ra) # 80003ec2 <ilock>
  if(ip->type != T_DIR){
    8000613a:	04449703          	lh	a4,68(s1)
    8000613e:	4785                	li	a5,1
    80006140:	04f71063          	bne	a4,a5,80006180 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006144:	8526                	mv	a0,s1
    80006146:	ffffe097          	auipc	ra,0xffffe
    8000614a:	e3e080e7          	jalr	-450(ra) # 80003f84 <iunlock>
  iput(p->cwd);
    8000614e:	15093503          	ld	a0,336(s2)
    80006152:	ffffe097          	auipc	ra,0xffffe
    80006156:	f2a080e7          	jalr	-214(ra) # 8000407c <iput>
  end_op();
    8000615a:	ffffe097          	auipc	ra,0xffffe
    8000615e:	7aa080e7          	jalr	1962(ra) # 80004904 <end_op>
  p->cwd = ip;
    80006162:	14993823          	sd	s1,336(s2)
  return 0;
    80006166:	4501                	li	a0,0
}
    80006168:	60ea                	ld	ra,152(sp)
    8000616a:	644a                	ld	s0,144(sp)
    8000616c:	64aa                	ld	s1,136(sp)
    8000616e:	690a                	ld	s2,128(sp)
    80006170:	610d                	addi	sp,sp,160
    80006172:	8082                	ret
    end_op();
    80006174:	ffffe097          	auipc	ra,0xffffe
    80006178:	790080e7          	jalr	1936(ra) # 80004904 <end_op>
    return -1;
    8000617c:	557d                	li	a0,-1
    8000617e:	b7ed                	j	80006168 <sys_chdir+0x7a>
    iunlockput(ip);
    80006180:	8526                	mv	a0,s1
    80006182:	ffffe097          	auipc	ra,0xffffe
    80006186:	fa2080e7          	jalr	-94(ra) # 80004124 <iunlockput>
    end_op();
    8000618a:	ffffe097          	auipc	ra,0xffffe
    8000618e:	77a080e7          	jalr	1914(ra) # 80004904 <end_op>
    return -1;
    80006192:	557d                	li	a0,-1
    80006194:	bfd1                	j	80006168 <sys_chdir+0x7a>

0000000080006196 <sys_exec>:

uint64
sys_exec(void)
{
    80006196:	7145                	addi	sp,sp,-464
    80006198:	e786                	sd	ra,456(sp)
    8000619a:	e3a2                	sd	s0,448(sp)
    8000619c:	ff26                	sd	s1,440(sp)
    8000619e:	fb4a                	sd	s2,432(sp)
    800061a0:	f74e                	sd	s3,424(sp)
    800061a2:	f352                	sd	s4,416(sp)
    800061a4:	ef56                	sd	s5,408(sp)
    800061a6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800061a8:	e3840593          	addi	a1,s0,-456
    800061ac:	4505                	li	a0,1
    800061ae:	ffffd097          	auipc	ra,0xffffd
    800061b2:	ff8080e7          	jalr	-8(ra) # 800031a6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800061b6:	08000613          	li	a2,128
    800061ba:	f4040593          	addi	a1,s0,-192
    800061be:	4501                	li	a0,0
    800061c0:	ffffd097          	auipc	ra,0xffffd
    800061c4:	006080e7          	jalr	6(ra) # 800031c6 <argstr>
    800061c8:	87aa                	mv	a5,a0
    return -1;
    800061ca:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800061cc:	0c07c263          	bltz	a5,80006290 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800061d0:	10000613          	li	a2,256
    800061d4:	4581                	li	a1,0
    800061d6:	e4040513          	addi	a0,s0,-448
    800061da:	ffffb097          	auipc	ra,0xffffb
    800061de:	c28080e7          	jalr	-984(ra) # 80000e02 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800061e2:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800061e6:	89a6                	mv	s3,s1
    800061e8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800061ea:	02000a13          	li	s4,32
    800061ee:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061f2:	00391513          	slli	a0,s2,0x3
    800061f6:	e3040593          	addi	a1,s0,-464
    800061fa:	e3843783          	ld	a5,-456(s0)
    800061fe:	953e                	add	a0,a0,a5
    80006200:	ffffd097          	auipc	ra,0xffffd
    80006204:	ee8080e7          	jalr	-280(ra) # 800030e8 <fetchaddr>
    80006208:	02054a63          	bltz	a0,8000623c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    8000620c:	e3043783          	ld	a5,-464(s0)
    80006210:	c3b9                	beqz	a5,80006256 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006212:	ffffb097          	auipc	ra,0xffffb
    80006216:	9ee080e7          	jalr	-1554(ra) # 80000c00 <kalloc>
    8000621a:	85aa                	mv	a1,a0
    8000621c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006220:	cd11                	beqz	a0,8000623c <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006222:	6605                	lui	a2,0x1
    80006224:	e3043503          	ld	a0,-464(s0)
    80006228:	ffffd097          	auipc	ra,0xffffd
    8000622c:	f12080e7          	jalr	-238(ra) # 8000313a <fetchstr>
    80006230:	00054663          	bltz	a0,8000623c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006234:	0905                	addi	s2,s2,1
    80006236:	09a1                	addi	s3,s3,8
    80006238:	fb491be3          	bne	s2,s4,800061ee <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000623c:	10048913          	addi	s2,s1,256
    80006240:	6088                	ld	a0,0(s1)
    80006242:	c531                	beqz	a0,8000628e <sys_exec+0xf8>
    kfree(argv[i]);
    80006244:	ffffb097          	auipc	ra,0xffffb
    80006248:	826080e7          	jalr	-2010(ra) # 80000a6a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000624c:	04a1                	addi	s1,s1,8
    8000624e:	ff2499e3          	bne	s1,s2,80006240 <sys_exec+0xaa>
  return -1;
    80006252:	557d                	li	a0,-1
    80006254:	a835                	j	80006290 <sys_exec+0xfa>
      argv[i] = 0;
    80006256:	0a8e                	slli	s5,s5,0x3
    80006258:	fc040793          	addi	a5,s0,-64
    8000625c:	9abe                	add	s5,s5,a5
    8000625e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006262:	e4040593          	addi	a1,s0,-448
    80006266:	f4040513          	addi	a0,s0,-192
    8000626a:	fffff097          	auipc	ra,0xfffff
    8000626e:	16e080e7          	jalr	366(ra) # 800053d8 <exec>
    80006272:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006274:	10048993          	addi	s3,s1,256
    80006278:	6088                	ld	a0,0(s1)
    8000627a:	c901                	beqz	a0,8000628a <sys_exec+0xf4>
    kfree(argv[i]);
    8000627c:	ffffa097          	auipc	ra,0xffffa
    80006280:	7ee080e7          	jalr	2030(ra) # 80000a6a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006284:	04a1                	addi	s1,s1,8
    80006286:	ff3499e3          	bne	s1,s3,80006278 <sys_exec+0xe2>
  return ret;
    8000628a:	854a                	mv	a0,s2
    8000628c:	a011                	j	80006290 <sys_exec+0xfa>
  return -1;
    8000628e:	557d                	li	a0,-1
}
    80006290:	60be                	ld	ra,456(sp)
    80006292:	641e                	ld	s0,448(sp)
    80006294:	74fa                	ld	s1,440(sp)
    80006296:	795a                	ld	s2,432(sp)
    80006298:	79ba                	ld	s3,424(sp)
    8000629a:	7a1a                	ld	s4,416(sp)
    8000629c:	6afa                	ld	s5,408(sp)
    8000629e:	6179                	addi	sp,sp,464
    800062a0:	8082                	ret

00000000800062a2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800062a2:	7139                	addi	sp,sp,-64
    800062a4:	fc06                	sd	ra,56(sp)
    800062a6:	f822                	sd	s0,48(sp)
    800062a8:	f426                	sd	s1,40(sp)
    800062aa:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800062ac:	ffffc097          	auipc	ra,0xffffc
    800062b0:	95c080e7          	jalr	-1700(ra) # 80001c08 <myproc>
    800062b4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800062b6:	fd840593          	addi	a1,s0,-40
    800062ba:	4501                	li	a0,0
    800062bc:	ffffd097          	auipc	ra,0xffffd
    800062c0:	eea080e7          	jalr	-278(ra) # 800031a6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800062c4:	fc840593          	addi	a1,s0,-56
    800062c8:	fd040513          	addi	a0,s0,-48
    800062cc:	fffff097          	auipc	ra,0xfffff
    800062d0:	db4080e7          	jalr	-588(ra) # 80005080 <pipealloc>
    return -1;
    800062d4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800062d6:	0c054463          	bltz	a0,8000639e <sys_pipe+0xfc>
  fd0 = -1;
    800062da:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800062de:	fd043503          	ld	a0,-48(s0)
    800062e2:	fffff097          	auipc	ra,0xfffff
    800062e6:	4f6080e7          	jalr	1270(ra) # 800057d8 <fdalloc>
    800062ea:	fca42223          	sw	a0,-60(s0)
    800062ee:	08054b63          	bltz	a0,80006384 <sys_pipe+0xe2>
    800062f2:	fc843503          	ld	a0,-56(s0)
    800062f6:	fffff097          	auipc	ra,0xfffff
    800062fa:	4e2080e7          	jalr	1250(ra) # 800057d8 <fdalloc>
    800062fe:	fca42023          	sw	a0,-64(s0)
    80006302:	06054863          	bltz	a0,80006372 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006306:	4691                	li	a3,4
    80006308:	fc440613          	addi	a2,s0,-60
    8000630c:	fd843583          	ld	a1,-40(s0)
    80006310:	68a8                	ld	a0,80(s1)
    80006312:	ffffb097          	auipc	ra,0xffffb
    80006316:	57c080e7          	jalr	1404(ra) # 8000188e <copyout>
    8000631a:	02054063          	bltz	a0,8000633a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000631e:	4691                	li	a3,4
    80006320:	fc040613          	addi	a2,s0,-64
    80006324:	fd843583          	ld	a1,-40(s0)
    80006328:	0591                	addi	a1,a1,4
    8000632a:	68a8                	ld	a0,80(s1)
    8000632c:	ffffb097          	auipc	ra,0xffffb
    80006330:	562080e7          	jalr	1378(ra) # 8000188e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006334:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006336:	06055463          	bgez	a0,8000639e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000633a:	fc442783          	lw	a5,-60(s0)
    8000633e:	07e9                	addi	a5,a5,26
    80006340:	078e                	slli	a5,a5,0x3
    80006342:	97a6                	add	a5,a5,s1
    80006344:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006348:	fc042503          	lw	a0,-64(s0)
    8000634c:	0569                	addi	a0,a0,26
    8000634e:	050e                	slli	a0,a0,0x3
    80006350:	94aa                	add	s1,s1,a0
    80006352:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006356:	fd043503          	ld	a0,-48(s0)
    8000635a:	fffff097          	auipc	ra,0xfffff
    8000635e:	9f6080e7          	jalr	-1546(ra) # 80004d50 <fileclose>
    fileclose(wf);
    80006362:	fc843503          	ld	a0,-56(s0)
    80006366:	fffff097          	auipc	ra,0xfffff
    8000636a:	9ea080e7          	jalr	-1558(ra) # 80004d50 <fileclose>
    return -1;
    8000636e:	57fd                	li	a5,-1
    80006370:	a03d                	j	8000639e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006372:	fc442783          	lw	a5,-60(s0)
    80006376:	0007c763          	bltz	a5,80006384 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000637a:	07e9                	addi	a5,a5,26
    8000637c:	078e                	slli	a5,a5,0x3
    8000637e:	94be                	add	s1,s1,a5
    80006380:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80006384:	fd043503          	ld	a0,-48(s0)
    80006388:	fffff097          	auipc	ra,0xfffff
    8000638c:	9c8080e7          	jalr	-1592(ra) # 80004d50 <fileclose>
    fileclose(wf);
    80006390:	fc843503          	ld	a0,-56(s0)
    80006394:	fffff097          	auipc	ra,0xfffff
    80006398:	9bc080e7          	jalr	-1604(ra) # 80004d50 <fileclose>
    return -1;
    8000639c:	57fd                	li	a5,-1
}
    8000639e:	853e                	mv	a0,a5
    800063a0:	70e2                	ld	ra,56(sp)
    800063a2:	7442                	ld	s0,48(sp)
    800063a4:	74a2                	ld	s1,40(sp)
    800063a6:	6121                	addi	sp,sp,64
    800063a8:	8082                	ret
    800063aa:	0000                	unimp
    800063ac:	0000                	unimp
	...

00000000800063b0 <kernelvec>:
    800063b0:	7111                	addi	sp,sp,-256
    800063b2:	e006                	sd	ra,0(sp)
    800063b4:	e40a                	sd	sp,8(sp)
    800063b6:	e80e                	sd	gp,16(sp)
    800063b8:	ec12                	sd	tp,24(sp)
    800063ba:	f016                	sd	t0,32(sp)
    800063bc:	f41a                	sd	t1,40(sp)
    800063be:	f81e                	sd	t2,48(sp)
    800063c0:	fc22                	sd	s0,56(sp)
    800063c2:	e0a6                	sd	s1,64(sp)
    800063c4:	e4aa                	sd	a0,72(sp)
    800063c6:	e8ae                	sd	a1,80(sp)
    800063c8:	ecb2                	sd	a2,88(sp)
    800063ca:	f0b6                	sd	a3,96(sp)
    800063cc:	f4ba                	sd	a4,104(sp)
    800063ce:	f8be                	sd	a5,112(sp)
    800063d0:	fcc2                	sd	a6,120(sp)
    800063d2:	e146                	sd	a7,128(sp)
    800063d4:	e54a                	sd	s2,136(sp)
    800063d6:	e94e                	sd	s3,144(sp)
    800063d8:	ed52                	sd	s4,152(sp)
    800063da:	f156                	sd	s5,160(sp)
    800063dc:	f55a                	sd	s6,168(sp)
    800063de:	f95e                	sd	s7,176(sp)
    800063e0:	fd62                	sd	s8,184(sp)
    800063e2:	e1e6                	sd	s9,192(sp)
    800063e4:	e5ea                	sd	s10,200(sp)
    800063e6:	e9ee                	sd	s11,208(sp)
    800063e8:	edf2                	sd	t3,216(sp)
    800063ea:	f1f6                	sd	t4,224(sp)
    800063ec:	f5fa                	sd	t5,232(sp)
    800063ee:	f9fe                	sd	t6,240(sp)
    800063f0:	bc5fc0ef          	jal	ra,80002fb4 <kerneltrap>
    800063f4:	6082                	ld	ra,0(sp)
    800063f6:	6122                	ld	sp,8(sp)
    800063f8:	61c2                	ld	gp,16(sp)
    800063fa:	7282                	ld	t0,32(sp)
    800063fc:	7322                	ld	t1,40(sp)
    800063fe:	73c2                	ld	t2,48(sp)
    80006400:	7462                	ld	s0,56(sp)
    80006402:	6486                	ld	s1,64(sp)
    80006404:	6526                	ld	a0,72(sp)
    80006406:	65c6                	ld	a1,80(sp)
    80006408:	6666                	ld	a2,88(sp)
    8000640a:	7686                	ld	a3,96(sp)
    8000640c:	7726                	ld	a4,104(sp)
    8000640e:	77c6                	ld	a5,112(sp)
    80006410:	7866                	ld	a6,120(sp)
    80006412:	688a                	ld	a7,128(sp)
    80006414:	692a                	ld	s2,136(sp)
    80006416:	69ca                	ld	s3,144(sp)
    80006418:	6a6a                	ld	s4,152(sp)
    8000641a:	7a8a                	ld	s5,160(sp)
    8000641c:	7b2a                	ld	s6,168(sp)
    8000641e:	7bca                	ld	s7,176(sp)
    80006420:	7c6a                	ld	s8,184(sp)
    80006422:	6c8e                	ld	s9,192(sp)
    80006424:	6d2e                	ld	s10,200(sp)
    80006426:	6dce                	ld	s11,208(sp)
    80006428:	6e6e                	ld	t3,216(sp)
    8000642a:	7e8e                	ld	t4,224(sp)
    8000642c:	7f2e                	ld	t5,232(sp)
    8000642e:	7fce                	ld	t6,240(sp)
    80006430:	6111                	addi	sp,sp,256
    80006432:	10200073          	sret
    80006436:	00000013          	nop
    8000643a:	00000013          	nop
    8000643e:	0001                	nop

0000000080006440 <timervec>:
    80006440:	34051573          	csrrw	a0,mscratch,a0
    80006444:	e10c                	sd	a1,0(a0)
    80006446:	e510                	sd	a2,8(a0)
    80006448:	e914                	sd	a3,16(a0)
    8000644a:	6d0c                	ld	a1,24(a0)
    8000644c:	7110                	ld	a2,32(a0)
    8000644e:	6194                	ld	a3,0(a1)
    80006450:	96b2                	add	a3,a3,a2
    80006452:	e194                	sd	a3,0(a1)
    80006454:	4589                	li	a1,2
    80006456:	14459073          	csrw	sip,a1
    8000645a:	6914                	ld	a3,16(a0)
    8000645c:	6510                	ld	a2,8(a0)
    8000645e:	610c                	ld	a1,0(a0)
    80006460:	34051573          	csrrw	a0,mscratch,a0
    80006464:	30200073          	mret
	...

000000008000646a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000646a:	1141                	addi	sp,sp,-16
    8000646c:	e422                	sd	s0,8(sp)
    8000646e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006470:	0c0007b7          	lui	a5,0xc000
    80006474:	4705                	li	a4,1
    80006476:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006478:	c3d8                	sw	a4,4(a5)
}
    8000647a:	6422                	ld	s0,8(sp)
    8000647c:	0141                	addi	sp,sp,16
    8000647e:	8082                	ret

0000000080006480 <plicinithart>:

void
plicinithart(void)
{
    80006480:	1141                	addi	sp,sp,-16
    80006482:	e406                	sd	ra,8(sp)
    80006484:	e022                	sd	s0,0(sp)
    80006486:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006488:	ffffb097          	auipc	ra,0xffffb
    8000648c:	754080e7          	jalr	1876(ra) # 80001bdc <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006490:	0085171b          	slliw	a4,a0,0x8
    80006494:	0c0027b7          	lui	a5,0xc002
    80006498:	97ba                	add	a5,a5,a4
    8000649a:	40200713          	li	a4,1026
    8000649e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800064a2:	00d5151b          	slliw	a0,a0,0xd
    800064a6:	0c2017b7          	lui	a5,0xc201
    800064aa:	953e                	add	a0,a0,a5
    800064ac:	00052023          	sw	zero,0(a0)
}
    800064b0:	60a2                	ld	ra,8(sp)
    800064b2:	6402                	ld	s0,0(sp)
    800064b4:	0141                	addi	sp,sp,16
    800064b6:	8082                	ret

00000000800064b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800064b8:	1141                	addi	sp,sp,-16
    800064ba:	e406                	sd	ra,8(sp)
    800064bc:	e022                	sd	s0,0(sp)
    800064be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064c0:	ffffb097          	auipc	ra,0xffffb
    800064c4:	71c080e7          	jalr	1820(ra) # 80001bdc <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800064c8:	00d5179b          	slliw	a5,a0,0xd
    800064cc:	0c201537          	lui	a0,0xc201
    800064d0:	953e                	add	a0,a0,a5
  return irq;
}
    800064d2:	4148                	lw	a0,4(a0)
    800064d4:	60a2                	ld	ra,8(sp)
    800064d6:	6402                	ld	s0,0(sp)
    800064d8:	0141                	addi	sp,sp,16
    800064da:	8082                	ret

00000000800064dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800064dc:	1101                	addi	sp,sp,-32
    800064de:	ec06                	sd	ra,24(sp)
    800064e0:	e822                	sd	s0,16(sp)
    800064e2:	e426                	sd	s1,8(sp)
    800064e4:	1000                	addi	s0,sp,32
    800064e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800064e8:	ffffb097          	auipc	ra,0xffffb
    800064ec:	6f4080e7          	jalr	1780(ra) # 80001bdc <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800064f0:	00d5151b          	slliw	a0,a0,0xd
    800064f4:	0c2017b7          	lui	a5,0xc201
    800064f8:	97aa                	add	a5,a5,a0
    800064fa:	c3c4                	sw	s1,4(a5)
}
    800064fc:	60e2                	ld	ra,24(sp)
    800064fe:	6442                	ld	s0,16(sp)
    80006500:	64a2                	ld	s1,8(sp)
    80006502:	6105                	addi	sp,sp,32
    80006504:	8082                	ret

0000000080006506 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006506:	1141                	addi	sp,sp,-16
    80006508:	e406                	sd	ra,8(sp)
    8000650a:	e022                	sd	s0,0(sp)
    8000650c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000650e:	479d                	li	a5,7
    80006510:	04a7cc63          	blt	a5,a0,80006568 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006514:	0023c797          	auipc	a5,0x23c
    80006518:	20478793          	addi	a5,a5,516 # 80242718 <disk>
    8000651c:	97aa                	add	a5,a5,a0
    8000651e:	0187c783          	lbu	a5,24(a5)
    80006522:	ebb9                	bnez	a5,80006578 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006524:	00451613          	slli	a2,a0,0x4
    80006528:	0023c797          	auipc	a5,0x23c
    8000652c:	1f078793          	addi	a5,a5,496 # 80242718 <disk>
    80006530:	6394                	ld	a3,0(a5)
    80006532:	96b2                	add	a3,a3,a2
    80006534:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006538:	6398                	ld	a4,0(a5)
    8000653a:	9732                	add	a4,a4,a2
    8000653c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006540:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006544:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006548:	953e                	add	a0,a0,a5
    8000654a:	4785                	li	a5,1
    8000654c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006550:	0023c517          	auipc	a0,0x23c
    80006554:	1e050513          	addi	a0,a0,480 # 80242730 <disk+0x18>
    80006558:	ffffc097          	auipc	ra,0xffffc
    8000655c:	f54080e7          	jalr	-172(ra) # 800024ac <wakeup>
}
    80006560:	60a2                	ld	ra,8(sp)
    80006562:	6402                	ld	s0,0(sp)
    80006564:	0141                	addi	sp,sp,16
    80006566:	8082                	ret
    panic("free_desc 1");
    80006568:	00002517          	auipc	a0,0x2
    8000656c:	2d050513          	addi	a0,a0,720 # 80008838 <syscalls+0x308>
    80006570:	ffffa097          	auipc	ra,0xffffa
    80006574:	fd4080e7          	jalr	-44(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006578:	00002517          	auipc	a0,0x2
    8000657c:	2d050513          	addi	a0,a0,720 # 80008848 <syscalls+0x318>
    80006580:	ffffa097          	auipc	ra,0xffffa
    80006584:	fc4080e7          	jalr	-60(ra) # 80000544 <panic>

0000000080006588 <virtio_disk_init>:
{
    80006588:	1101                	addi	sp,sp,-32
    8000658a:	ec06                	sd	ra,24(sp)
    8000658c:	e822                	sd	s0,16(sp)
    8000658e:	e426                	sd	s1,8(sp)
    80006590:	e04a                	sd	s2,0(sp)
    80006592:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006594:	00002597          	auipc	a1,0x2
    80006598:	2c458593          	addi	a1,a1,708 # 80008858 <syscalls+0x328>
    8000659c:	0023c517          	auipc	a0,0x23c
    800065a0:	2a450513          	addi	a0,a0,676 # 80242840 <disk+0x128>
    800065a4:	ffffa097          	auipc	ra,0xffffa
    800065a8:	6d2080e7          	jalr	1746(ra) # 80000c76 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065ac:	100017b7          	lui	a5,0x10001
    800065b0:	4398                	lw	a4,0(a5)
    800065b2:	2701                	sext.w	a4,a4
    800065b4:	747277b7          	lui	a5,0x74727
    800065b8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800065bc:	14f71e63          	bne	a4,a5,80006718 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065c0:	100017b7          	lui	a5,0x10001
    800065c4:	43dc                	lw	a5,4(a5)
    800065c6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065c8:	4709                	li	a4,2
    800065ca:	14e79763          	bne	a5,a4,80006718 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065ce:	100017b7          	lui	a5,0x10001
    800065d2:	479c                	lw	a5,8(a5)
    800065d4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065d6:	14e79163          	bne	a5,a4,80006718 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800065da:	100017b7          	lui	a5,0x10001
    800065de:	47d8                	lw	a4,12(a5)
    800065e0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065e2:	554d47b7          	lui	a5,0x554d4
    800065e6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800065ea:	12f71763          	bne	a4,a5,80006718 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065ee:	100017b7          	lui	a5,0x10001
    800065f2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065f6:	4705                	li	a4,1
    800065f8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065fa:	470d                	li	a4,3
    800065fc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800065fe:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006600:	c7ffe737          	lui	a4,0xc7ffe
    80006604:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47dbbf07>
    80006608:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000660a:	2701                	sext.w	a4,a4
    8000660c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000660e:	472d                	li	a4,11
    80006610:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006612:	0707a903          	lw	s2,112(a5)
    80006616:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006618:	00897793          	andi	a5,s2,8
    8000661c:	10078663          	beqz	a5,80006728 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006620:	100017b7          	lui	a5,0x10001
    80006624:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006628:	43fc                	lw	a5,68(a5)
    8000662a:	2781                	sext.w	a5,a5
    8000662c:	10079663          	bnez	a5,80006738 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006630:	100017b7          	lui	a5,0x10001
    80006634:	5bdc                	lw	a5,52(a5)
    80006636:	2781                	sext.w	a5,a5
  if(max == 0)
    80006638:	10078863          	beqz	a5,80006748 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000663c:	471d                	li	a4,7
    8000663e:	10f77d63          	bgeu	a4,a5,80006758 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006642:	ffffa097          	auipc	ra,0xffffa
    80006646:	5be080e7          	jalr	1470(ra) # 80000c00 <kalloc>
    8000664a:	0023c497          	auipc	s1,0x23c
    8000664e:	0ce48493          	addi	s1,s1,206 # 80242718 <disk>
    80006652:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006654:	ffffa097          	auipc	ra,0xffffa
    80006658:	5ac080e7          	jalr	1452(ra) # 80000c00 <kalloc>
    8000665c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000665e:	ffffa097          	auipc	ra,0xffffa
    80006662:	5a2080e7          	jalr	1442(ra) # 80000c00 <kalloc>
    80006666:	87aa                	mv	a5,a0
    80006668:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000666a:	6088                	ld	a0,0(s1)
    8000666c:	cd75                	beqz	a0,80006768 <virtio_disk_init+0x1e0>
    8000666e:	0023c717          	auipc	a4,0x23c
    80006672:	0b273703          	ld	a4,178(a4) # 80242720 <disk+0x8>
    80006676:	cb6d                	beqz	a4,80006768 <virtio_disk_init+0x1e0>
    80006678:	cbe5                	beqz	a5,80006768 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000667a:	6605                	lui	a2,0x1
    8000667c:	4581                	li	a1,0
    8000667e:	ffffa097          	auipc	ra,0xffffa
    80006682:	784080e7          	jalr	1924(ra) # 80000e02 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006686:	0023c497          	auipc	s1,0x23c
    8000668a:	09248493          	addi	s1,s1,146 # 80242718 <disk>
    8000668e:	6605                	lui	a2,0x1
    80006690:	4581                	li	a1,0
    80006692:	6488                	ld	a0,8(s1)
    80006694:	ffffa097          	auipc	ra,0xffffa
    80006698:	76e080e7          	jalr	1902(ra) # 80000e02 <memset>
  memset(disk.used, 0, PGSIZE);
    8000669c:	6605                	lui	a2,0x1
    8000669e:	4581                	li	a1,0
    800066a0:	6888                	ld	a0,16(s1)
    800066a2:	ffffa097          	auipc	ra,0xffffa
    800066a6:	760080e7          	jalr	1888(ra) # 80000e02 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800066aa:	100017b7          	lui	a5,0x10001
    800066ae:	4721                	li	a4,8
    800066b0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800066b2:	4098                	lw	a4,0(s1)
    800066b4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800066b8:	40d8                	lw	a4,4(s1)
    800066ba:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800066be:	6498                	ld	a4,8(s1)
    800066c0:	0007069b          	sext.w	a3,a4
    800066c4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800066c8:	9701                	srai	a4,a4,0x20
    800066ca:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800066ce:	6898                	ld	a4,16(s1)
    800066d0:	0007069b          	sext.w	a3,a4
    800066d4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800066d8:	9701                	srai	a4,a4,0x20
    800066da:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800066de:	4685                	li	a3,1
    800066e0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    800066e2:	4705                	li	a4,1
    800066e4:	00d48c23          	sb	a3,24(s1)
    800066e8:	00e48ca3          	sb	a4,25(s1)
    800066ec:	00e48d23          	sb	a4,26(s1)
    800066f0:	00e48da3          	sb	a4,27(s1)
    800066f4:	00e48e23          	sb	a4,28(s1)
    800066f8:	00e48ea3          	sb	a4,29(s1)
    800066fc:	00e48f23          	sb	a4,30(s1)
    80006700:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006704:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006708:	0727a823          	sw	s2,112(a5)
}
    8000670c:	60e2                	ld	ra,24(sp)
    8000670e:	6442                	ld	s0,16(sp)
    80006710:	64a2                	ld	s1,8(sp)
    80006712:	6902                	ld	s2,0(sp)
    80006714:	6105                	addi	sp,sp,32
    80006716:	8082                	ret
    panic("could not find virtio disk");
    80006718:	00002517          	auipc	a0,0x2
    8000671c:	15050513          	addi	a0,a0,336 # 80008868 <syscalls+0x338>
    80006720:	ffffa097          	auipc	ra,0xffffa
    80006724:	e24080e7          	jalr	-476(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006728:	00002517          	auipc	a0,0x2
    8000672c:	16050513          	addi	a0,a0,352 # 80008888 <syscalls+0x358>
    80006730:	ffffa097          	auipc	ra,0xffffa
    80006734:	e14080e7          	jalr	-492(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006738:	00002517          	auipc	a0,0x2
    8000673c:	17050513          	addi	a0,a0,368 # 800088a8 <syscalls+0x378>
    80006740:	ffffa097          	auipc	ra,0xffffa
    80006744:	e04080e7          	jalr	-508(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006748:	00002517          	auipc	a0,0x2
    8000674c:	18050513          	addi	a0,a0,384 # 800088c8 <syscalls+0x398>
    80006750:	ffffa097          	auipc	ra,0xffffa
    80006754:	df4080e7          	jalr	-524(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006758:	00002517          	auipc	a0,0x2
    8000675c:	19050513          	addi	a0,a0,400 # 800088e8 <syscalls+0x3b8>
    80006760:	ffffa097          	auipc	ra,0xffffa
    80006764:	de4080e7          	jalr	-540(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006768:	00002517          	auipc	a0,0x2
    8000676c:	1a050513          	addi	a0,a0,416 # 80008908 <syscalls+0x3d8>
    80006770:	ffffa097          	auipc	ra,0xffffa
    80006774:	dd4080e7          	jalr	-556(ra) # 80000544 <panic>

0000000080006778 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006778:	7159                	addi	sp,sp,-112
    8000677a:	f486                	sd	ra,104(sp)
    8000677c:	f0a2                	sd	s0,96(sp)
    8000677e:	eca6                	sd	s1,88(sp)
    80006780:	e8ca                	sd	s2,80(sp)
    80006782:	e4ce                	sd	s3,72(sp)
    80006784:	e0d2                	sd	s4,64(sp)
    80006786:	fc56                	sd	s5,56(sp)
    80006788:	f85a                	sd	s6,48(sp)
    8000678a:	f45e                	sd	s7,40(sp)
    8000678c:	f062                	sd	s8,32(sp)
    8000678e:	ec66                	sd	s9,24(sp)
    80006790:	e86a                	sd	s10,16(sp)
    80006792:	1880                	addi	s0,sp,112
    80006794:	892a                	mv	s2,a0
    80006796:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006798:	00c52c83          	lw	s9,12(a0)
    8000679c:	001c9c9b          	slliw	s9,s9,0x1
    800067a0:	1c82                	slli	s9,s9,0x20
    800067a2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800067a6:	0023c517          	auipc	a0,0x23c
    800067aa:	09a50513          	addi	a0,a0,154 # 80242840 <disk+0x128>
    800067ae:	ffffa097          	auipc	ra,0xffffa
    800067b2:	558080e7          	jalr	1368(ra) # 80000d06 <acquire>
  for(int i = 0; i < 3; i++){
    800067b6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800067b8:	4ba1                	li	s7,8
      disk.free[i] = 0;
    800067ba:	0023cb17          	auipc	s6,0x23c
    800067be:	f5eb0b13          	addi	s6,s6,-162 # 80242718 <disk>
  for(int i = 0; i < 3; i++){
    800067c2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800067c4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800067c6:	0023cc17          	auipc	s8,0x23c
    800067ca:	07ac0c13          	addi	s8,s8,122 # 80242840 <disk+0x128>
    800067ce:	a8b5                	j	8000684a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800067d0:	00fb06b3          	add	a3,s6,a5
    800067d4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800067d8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800067da:	0207c563          	bltz	a5,80006804 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800067de:	2485                	addiw	s1,s1,1
    800067e0:	0711                	addi	a4,a4,4
    800067e2:	1f548a63          	beq	s1,s5,800069d6 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    800067e6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800067e8:	0023c697          	auipc	a3,0x23c
    800067ec:	f3068693          	addi	a3,a3,-208 # 80242718 <disk>
    800067f0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800067f2:	0186c583          	lbu	a1,24(a3)
    800067f6:	fde9                	bnez	a1,800067d0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800067f8:	2785                	addiw	a5,a5,1
    800067fa:	0685                	addi	a3,a3,1
    800067fc:	ff779be3          	bne	a5,s7,800067f2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006800:	57fd                	li	a5,-1
    80006802:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006804:	02905a63          	blez	s1,80006838 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006808:	f9042503          	lw	a0,-112(s0)
    8000680c:	00000097          	auipc	ra,0x0
    80006810:	cfa080e7          	jalr	-774(ra) # 80006506 <free_desc>
      for(int j = 0; j < i; j++)
    80006814:	4785                	li	a5,1
    80006816:	0297d163          	bge	a5,s1,80006838 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000681a:	f9442503          	lw	a0,-108(s0)
    8000681e:	00000097          	auipc	ra,0x0
    80006822:	ce8080e7          	jalr	-792(ra) # 80006506 <free_desc>
      for(int j = 0; j < i; j++)
    80006826:	4789                	li	a5,2
    80006828:	0097d863          	bge	a5,s1,80006838 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000682c:	f9842503          	lw	a0,-104(s0)
    80006830:	00000097          	auipc	ra,0x0
    80006834:	cd6080e7          	jalr	-810(ra) # 80006506 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006838:	85e2                	mv	a1,s8
    8000683a:	0023c517          	auipc	a0,0x23c
    8000683e:	ef650513          	addi	a0,a0,-266 # 80242730 <disk+0x18>
    80006842:	ffffc097          	auipc	ra,0xffffc
    80006846:	c06080e7          	jalr	-1018(ra) # 80002448 <sleep>
  for(int i = 0; i < 3; i++){
    8000684a:	f9040713          	addi	a4,s0,-112
    8000684e:	84ce                	mv	s1,s3
    80006850:	bf59                	j	800067e6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006852:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006856:	00479693          	slli	a3,a5,0x4
    8000685a:	0023c797          	auipc	a5,0x23c
    8000685e:	ebe78793          	addi	a5,a5,-322 # 80242718 <disk>
    80006862:	97b6                	add	a5,a5,a3
    80006864:	4685                	li	a3,1
    80006866:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006868:	0023c597          	auipc	a1,0x23c
    8000686c:	eb058593          	addi	a1,a1,-336 # 80242718 <disk>
    80006870:	00a60793          	addi	a5,a2,10
    80006874:	0792                	slli	a5,a5,0x4
    80006876:	97ae                	add	a5,a5,a1
    80006878:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000687c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006880:	f6070693          	addi	a3,a4,-160
    80006884:	619c                	ld	a5,0(a1)
    80006886:	97b6                	add	a5,a5,a3
    80006888:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000688a:	6188                	ld	a0,0(a1)
    8000688c:	96aa                	add	a3,a3,a0
    8000688e:	47c1                	li	a5,16
    80006890:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006892:	4785                	li	a5,1
    80006894:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006898:	f9442783          	lw	a5,-108(s0)
    8000689c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800068a0:	0792                	slli	a5,a5,0x4
    800068a2:	953e                	add	a0,a0,a5
    800068a4:	05890693          	addi	a3,s2,88
    800068a8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800068aa:	6188                	ld	a0,0(a1)
    800068ac:	97aa                	add	a5,a5,a0
    800068ae:	40000693          	li	a3,1024
    800068b2:	c794                	sw	a3,8(a5)
  if(write)
    800068b4:	100d0d63          	beqz	s10,800069ce <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800068b8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800068bc:	00c7d683          	lhu	a3,12(a5)
    800068c0:	0016e693          	ori	a3,a3,1
    800068c4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800068c8:	f9842583          	lw	a1,-104(s0)
    800068cc:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800068d0:	0023c697          	auipc	a3,0x23c
    800068d4:	e4868693          	addi	a3,a3,-440 # 80242718 <disk>
    800068d8:	00260793          	addi	a5,a2,2
    800068dc:	0792                	slli	a5,a5,0x4
    800068de:	97b6                	add	a5,a5,a3
    800068e0:	587d                	li	a6,-1
    800068e2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800068e6:	0592                	slli	a1,a1,0x4
    800068e8:	952e                	add	a0,a0,a1
    800068ea:	f9070713          	addi	a4,a4,-112
    800068ee:	9736                	add	a4,a4,a3
    800068f0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800068f2:	6298                	ld	a4,0(a3)
    800068f4:	972e                	add	a4,a4,a1
    800068f6:	4585                	li	a1,1
    800068f8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800068fa:	4509                	li	a0,2
    800068fc:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006900:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006904:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006908:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000690c:	6698                	ld	a4,8(a3)
    8000690e:	00275783          	lhu	a5,2(a4)
    80006912:	8b9d                	andi	a5,a5,7
    80006914:	0786                	slli	a5,a5,0x1
    80006916:	97ba                	add	a5,a5,a4
    80006918:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000691c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006920:	6698                	ld	a4,8(a3)
    80006922:	00275783          	lhu	a5,2(a4)
    80006926:	2785                	addiw	a5,a5,1
    80006928:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000692c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006930:	100017b7          	lui	a5,0x10001
    80006934:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006938:	00492703          	lw	a4,4(s2)
    8000693c:	4785                	li	a5,1
    8000693e:	02f71163          	bne	a4,a5,80006960 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006942:	0023c997          	auipc	s3,0x23c
    80006946:	efe98993          	addi	s3,s3,-258 # 80242840 <disk+0x128>
  while(b->disk == 1) {
    8000694a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000694c:	85ce                	mv	a1,s3
    8000694e:	854a                	mv	a0,s2
    80006950:	ffffc097          	auipc	ra,0xffffc
    80006954:	af8080e7          	jalr	-1288(ra) # 80002448 <sleep>
  while(b->disk == 1) {
    80006958:	00492783          	lw	a5,4(s2)
    8000695c:	fe9788e3          	beq	a5,s1,8000694c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006960:	f9042903          	lw	s2,-112(s0)
    80006964:	00290793          	addi	a5,s2,2
    80006968:	00479713          	slli	a4,a5,0x4
    8000696c:	0023c797          	auipc	a5,0x23c
    80006970:	dac78793          	addi	a5,a5,-596 # 80242718 <disk>
    80006974:	97ba                	add	a5,a5,a4
    80006976:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000697a:	0023c997          	auipc	s3,0x23c
    8000697e:	d9e98993          	addi	s3,s3,-610 # 80242718 <disk>
    80006982:	00491713          	slli	a4,s2,0x4
    80006986:	0009b783          	ld	a5,0(s3)
    8000698a:	97ba                	add	a5,a5,a4
    8000698c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006990:	854a                	mv	a0,s2
    80006992:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006996:	00000097          	auipc	ra,0x0
    8000699a:	b70080e7          	jalr	-1168(ra) # 80006506 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000699e:	8885                	andi	s1,s1,1
    800069a0:	f0ed                	bnez	s1,80006982 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800069a2:	0023c517          	auipc	a0,0x23c
    800069a6:	e9e50513          	addi	a0,a0,-354 # 80242840 <disk+0x128>
    800069aa:	ffffa097          	auipc	ra,0xffffa
    800069ae:	410080e7          	jalr	1040(ra) # 80000dba <release>
}
    800069b2:	70a6                	ld	ra,104(sp)
    800069b4:	7406                	ld	s0,96(sp)
    800069b6:	64e6                	ld	s1,88(sp)
    800069b8:	6946                	ld	s2,80(sp)
    800069ba:	69a6                	ld	s3,72(sp)
    800069bc:	6a06                	ld	s4,64(sp)
    800069be:	7ae2                	ld	s5,56(sp)
    800069c0:	7b42                	ld	s6,48(sp)
    800069c2:	7ba2                	ld	s7,40(sp)
    800069c4:	7c02                	ld	s8,32(sp)
    800069c6:	6ce2                	ld	s9,24(sp)
    800069c8:	6d42                	ld	s10,16(sp)
    800069ca:	6165                	addi	sp,sp,112
    800069cc:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800069ce:	4689                	li	a3,2
    800069d0:	00d79623          	sh	a3,12(a5)
    800069d4:	b5e5                	j	800068bc <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800069d6:	f9042603          	lw	a2,-112(s0)
    800069da:	00a60713          	addi	a4,a2,10
    800069de:	0712                	slli	a4,a4,0x4
    800069e0:	0023c517          	auipc	a0,0x23c
    800069e4:	d4050513          	addi	a0,a0,-704 # 80242720 <disk+0x8>
    800069e8:	953a                	add	a0,a0,a4
  if(write)
    800069ea:	e60d14e3          	bnez	s10,80006852 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800069ee:	00a60793          	addi	a5,a2,10
    800069f2:	00479693          	slli	a3,a5,0x4
    800069f6:	0023c797          	auipc	a5,0x23c
    800069fa:	d2278793          	addi	a5,a5,-734 # 80242718 <disk>
    800069fe:	97b6                	add	a5,a5,a3
    80006a00:	0007a423          	sw	zero,8(a5)
    80006a04:	b595                	j	80006868 <virtio_disk_rw+0xf0>

0000000080006a06 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006a06:	1101                	addi	sp,sp,-32
    80006a08:	ec06                	sd	ra,24(sp)
    80006a0a:	e822                	sd	s0,16(sp)
    80006a0c:	e426                	sd	s1,8(sp)
    80006a0e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006a10:	0023c497          	auipc	s1,0x23c
    80006a14:	d0848493          	addi	s1,s1,-760 # 80242718 <disk>
    80006a18:	0023c517          	auipc	a0,0x23c
    80006a1c:	e2850513          	addi	a0,a0,-472 # 80242840 <disk+0x128>
    80006a20:	ffffa097          	auipc	ra,0xffffa
    80006a24:	2e6080e7          	jalr	742(ra) # 80000d06 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006a28:	10001737          	lui	a4,0x10001
    80006a2c:	533c                	lw	a5,96(a4)
    80006a2e:	8b8d                	andi	a5,a5,3
    80006a30:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006a32:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006a36:	689c                	ld	a5,16(s1)
    80006a38:	0204d703          	lhu	a4,32(s1)
    80006a3c:	0027d783          	lhu	a5,2(a5)
    80006a40:	04f70863          	beq	a4,a5,80006a90 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006a44:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006a48:	6898                	ld	a4,16(s1)
    80006a4a:	0204d783          	lhu	a5,32(s1)
    80006a4e:	8b9d                	andi	a5,a5,7
    80006a50:	078e                	slli	a5,a5,0x3
    80006a52:	97ba                	add	a5,a5,a4
    80006a54:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006a56:	00278713          	addi	a4,a5,2
    80006a5a:	0712                	slli	a4,a4,0x4
    80006a5c:	9726                	add	a4,a4,s1
    80006a5e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006a62:	e721                	bnez	a4,80006aaa <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006a64:	0789                	addi	a5,a5,2
    80006a66:	0792                	slli	a5,a5,0x4
    80006a68:	97a6                	add	a5,a5,s1
    80006a6a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006a6c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006a70:	ffffc097          	auipc	ra,0xffffc
    80006a74:	a3c080e7          	jalr	-1476(ra) # 800024ac <wakeup>

    disk.used_idx += 1;
    80006a78:	0204d783          	lhu	a5,32(s1)
    80006a7c:	2785                	addiw	a5,a5,1
    80006a7e:	17c2                	slli	a5,a5,0x30
    80006a80:	93c1                	srli	a5,a5,0x30
    80006a82:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006a86:	6898                	ld	a4,16(s1)
    80006a88:	00275703          	lhu	a4,2(a4)
    80006a8c:	faf71ce3          	bne	a4,a5,80006a44 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006a90:	0023c517          	auipc	a0,0x23c
    80006a94:	db050513          	addi	a0,a0,-592 # 80242840 <disk+0x128>
    80006a98:	ffffa097          	auipc	ra,0xffffa
    80006a9c:	322080e7          	jalr	802(ra) # 80000dba <release>
}
    80006aa0:	60e2                	ld	ra,24(sp)
    80006aa2:	6442                	ld	s0,16(sp)
    80006aa4:	64a2                	ld	s1,8(sp)
    80006aa6:	6105                	addi	sp,sp,32
    80006aa8:	8082                	ret
      panic("virtio_disk_intr status");
    80006aaa:	00002517          	auipc	a0,0x2
    80006aae:	e7650513          	addi	a0,a0,-394 # 80008920 <syscalls+0x3f0>
    80006ab2:	ffffa097          	auipc	ra,0xffffa
    80006ab6:	a92080e7          	jalr	-1390(ra) # 80000544 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
