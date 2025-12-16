
obj/__user_cow.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800020:	7175                	addi	sp,sp,-144
  800022:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800024:	e0ba                	sd	a4,64(sp)
  800026:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  800028:	e42a                	sd	a0,8(sp)
  80002a:	ecae                	sd	a1,88(sp)
  80002c:	f0b2                	sd	a2,96(sp)
  80002e:	f4b6                	sd	a3,104(sp)
  800030:	fcbe                	sd	a5,120(sp)
  800032:	e142                	sd	a6,128(sp)
  800034:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  800036:	f42e                	sd	a1,40(sp)
  800038:	f832                	sd	a2,48(sp)
  80003a:	fc36                	sd	a3,56(sp)
  80003c:	f03a                	sd	a4,32(sp)
  80003e:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  800040:	6522                	ld	a0,8(sp)
  800042:	75a2                	ld	a1,40(sp)
  800044:	7642                	ld	a2,48(sp)
  800046:	76e2                	ld	a3,56(sp)
  800048:	6706                	ld	a4,64(sp)
  80004a:	67a6                	ld	a5,72(sp)
  80004c:	00000073          	ecall
  800050:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  800054:	4572                	lw	a0,28(sp)
  800056:	6149                	addi	sp,sp,144
  800058:	8082                	ret

000000000080005a <sys_exit>:

int
sys_exit(int64_t error_code) {
  80005a:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  80005c:	4505                	li	a0,1
  80005e:	b7c9                	j	800020 <syscall>

0000000000800060 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800060:	4509                	li	a0,2
  800062:	bf7d                	j	800020 <syscall>

0000000000800064 <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  800064:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  800066:	85aa                	mv	a1,a0
  800068:	450d                	li	a0,3
  80006a:	bf5d                	j	800020 <syscall>

000000000080006c <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  80006c:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  80006e:	4579                	li	a0,30
  800070:	bf45                	j	800020 <syscall>

0000000000800072 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800072:	1141                	addi	sp,sp,-16
  800074:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800076:	fe5ff0ef          	jal	ra,80005a <sys_exit>
    cprintf("BUG: exit failed.\n");
  80007a:	00000517          	auipc	a0,0x0
  80007e:	59650513          	addi	a0,a0,1430 # 800610 <main+0x114>
  800082:	02e000ef          	jal	ra,8000b0 <cprintf>
    while (1);
  800086:	a001                	j	800086 <exit+0x14>

0000000000800088 <fork>:
}

int
fork(void) {
    return sys_fork();
  800088:	bfe1                	j	800060 <sys_fork>

000000000080008a <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  80008a:	4581                	li	a1,0
  80008c:	4501                	li	a0,0
  80008e:	bfd9                	j	800064 <sys_wait>

0000000000800090 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800090:	056000ef          	jal	ra,8000e6 <umain>
1:  j 1b
  800094:	a001                	j	800094 <_start+0x4>

0000000000800096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800096:	1141                	addi	sp,sp,-16
  800098:	e022                	sd	s0,0(sp)
  80009a:	e406                	sd	ra,8(sp)
  80009c:	842e                	mv	s0,a1
    sys_putc(c);
  80009e:	fcfff0ef          	jal	ra,80006c <sys_putc>
    (*cnt) ++;
  8000a2:	401c                	lw	a5,0(s0)
}
  8000a4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  8000a6:	2785                	addiw	a5,a5,1
  8000a8:	c01c                	sw	a5,0(s0)
}
  8000aa:	6402                	ld	s0,0(sp)
  8000ac:	0141                	addi	sp,sp,16
  8000ae:	8082                	ret

00000000008000b0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000b0:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000b2:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000b6:	8e2a                	mv	t3,a0
  8000b8:	f42e                	sd	a1,40(sp)
  8000ba:	f832                	sd	a2,48(sp)
  8000bc:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000be:	00000517          	auipc	a0,0x0
  8000c2:	fd850513          	addi	a0,a0,-40 # 800096 <cputch>
  8000c6:	004c                	addi	a1,sp,4
  8000c8:	869a                	mv	a3,t1
  8000ca:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
  8000cc:	ec06                	sd	ra,24(sp)
  8000ce:	e0ba                	sd	a4,64(sp)
  8000d0:	e4be                	sd	a5,72(sp)
  8000d2:	e8c2                	sd	a6,80(sp)
  8000d4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000d6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000d8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000da:	0a0000ef          	jal	ra,80017a <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000de:	60e2                	ld	ra,24(sp)
  8000e0:	4512                	lw	a0,4(sp)
  8000e2:	6125                	addi	sp,sp,96
  8000e4:	8082                	ret

00000000008000e6 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e6:	1141                	addi	sp,sp,-16
  8000e8:	e406                	sd	ra,8(sp)
    int ret = main();
  8000ea:	412000ef          	jal	ra,8004fc <main>
    exit(ret);
  8000ee:	f85ff0ef          	jal	ra,800072 <exit>

00000000008000f2 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8000f2:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8000f4:	e589                	bnez	a1,8000fe <strnlen+0xc>
  8000f6:	a811                	j	80010a <strnlen+0x18>
        cnt ++;
  8000f8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8000fa:	00f58863          	beq	a1,a5,80010a <strnlen+0x18>
  8000fe:	00f50733          	add	a4,a0,a5
  800102:	00074703          	lbu	a4,0(a4)
  800106:	fb6d                	bnez	a4,8000f8 <strnlen+0x6>
  800108:	85be                	mv	a1,a5
    }
    return cnt;
}
  80010a:	852e                	mv	a0,a1
  80010c:	8082                	ret

000000000080010e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80010e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800112:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800114:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800118:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80011a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80011e:	f022                	sd	s0,32(sp)
  800120:	ec26                	sd	s1,24(sp)
  800122:	e84a                	sd	s2,16(sp)
  800124:	f406                	sd	ra,40(sp)
  800126:	e44e                	sd	s3,8(sp)
  800128:	84aa                	mv	s1,a0
  80012a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80012c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800130:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800132:	03067e63          	bgeu	a2,a6,80016e <printnum+0x60>
  800136:	89be                	mv	s3,a5
        while (-- width > 0)
  800138:	00805763          	blez	s0,800146 <printnum+0x38>
  80013c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80013e:	85ca                	mv	a1,s2
  800140:	854e                	mv	a0,s3
  800142:	9482                	jalr	s1
        while (-- width > 0)
  800144:	fc65                	bnez	s0,80013c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800146:	1a02                	slli	s4,s4,0x20
  800148:	00000797          	auipc	a5,0x0
  80014c:	4e078793          	addi	a5,a5,1248 # 800628 <main+0x12c>
  800150:	020a5a13          	srli	s4,s4,0x20
  800154:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800156:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800158:	000a4503          	lbu	a0,0(s4)
}
  80015c:	70a2                	ld	ra,40(sp)
  80015e:	69a2                	ld	s3,8(sp)
  800160:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800162:	85ca                	mv	a1,s2
  800164:	87a6                	mv	a5,s1
}
  800166:	6942                	ld	s2,16(sp)
  800168:	64e2                	ld	s1,24(sp)
  80016a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80016c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80016e:	03065633          	divu	a2,a2,a6
  800172:	8722                	mv	a4,s0
  800174:	f9bff0ef          	jal	ra,80010e <printnum>
  800178:	b7f9                	j	800146 <printnum+0x38>

000000000080017a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80017a:	7119                	addi	sp,sp,-128
  80017c:	f4a6                	sd	s1,104(sp)
  80017e:	f0ca                	sd	s2,96(sp)
  800180:	ecce                	sd	s3,88(sp)
  800182:	e8d2                	sd	s4,80(sp)
  800184:	e4d6                	sd	s5,72(sp)
  800186:	e0da                	sd	s6,64(sp)
  800188:	fc5e                	sd	s7,56(sp)
  80018a:	f06a                	sd	s10,32(sp)
  80018c:	fc86                	sd	ra,120(sp)
  80018e:	f8a2                	sd	s0,112(sp)
  800190:	f862                	sd	s8,48(sp)
  800192:	f466                	sd	s9,40(sp)
  800194:	ec6e                	sd	s11,24(sp)
  800196:	892a                	mv	s2,a0
  800198:	84ae                	mv	s1,a1
  80019a:	8d32                	mv	s10,a2
  80019c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001a2:	5b7d                	li	s6,-1
  8001a4:	00000a97          	auipc	s5,0x0
  8001a8:	4b8a8a93          	addi	s5,s5,1208 # 80065c <main+0x160>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001ac:	00000b97          	auipc	s7,0x0
  8001b0:	6ccb8b93          	addi	s7,s7,1740 # 800878 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b4:	000d4503          	lbu	a0,0(s10)
  8001b8:	001d0413          	addi	s0,s10,1
  8001bc:	01350a63          	beq	a0,s3,8001d0 <vprintfmt+0x56>
            if (ch == '\0') {
  8001c0:	c121                	beqz	a0,800200 <vprintfmt+0x86>
            putch(ch, putdat);
  8001c2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001c6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c8:	fff44503          	lbu	a0,-1(s0)
  8001cc:	ff351ae3          	bne	a0,s3,8001c0 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
  8001d0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001d4:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001d8:	4c81                	li	s9,0
  8001da:	4881                	li	a7,0
        width = precision = -1;
  8001dc:	5c7d                	li	s8,-1
  8001de:	5dfd                	li	s11,-1
  8001e0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
  8001e4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001e6:	fdd6059b          	addiw	a1,a2,-35
  8001ea:	0ff5f593          	zext.b	a1,a1
  8001ee:	00140d13          	addi	s10,s0,1
  8001f2:	04b56263          	bltu	a0,a1,800236 <vprintfmt+0xbc>
  8001f6:	058a                	slli	a1,a1,0x2
  8001f8:	95d6                	add	a1,a1,s5
  8001fa:	4194                	lw	a3,0(a1)
  8001fc:	96d6                	add	a3,a3,s5
  8001fe:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800200:	70e6                	ld	ra,120(sp)
  800202:	7446                	ld	s0,112(sp)
  800204:	74a6                	ld	s1,104(sp)
  800206:	7906                	ld	s2,96(sp)
  800208:	69e6                	ld	s3,88(sp)
  80020a:	6a46                	ld	s4,80(sp)
  80020c:	6aa6                	ld	s5,72(sp)
  80020e:	6b06                	ld	s6,64(sp)
  800210:	7be2                	ld	s7,56(sp)
  800212:	7c42                	ld	s8,48(sp)
  800214:	7ca2                	ld	s9,40(sp)
  800216:	7d02                	ld	s10,32(sp)
  800218:	6de2                	ld	s11,24(sp)
  80021a:	6109                	addi	sp,sp,128
  80021c:	8082                	ret
            padc = '0';
  80021e:	87b2                	mv	a5,a2
            goto reswitch;
  800220:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800224:	846a                	mv	s0,s10
  800226:	00140d13          	addi	s10,s0,1
  80022a:	fdd6059b          	addiw	a1,a2,-35
  80022e:	0ff5f593          	zext.b	a1,a1
  800232:	fcb572e3          	bgeu	a0,a1,8001f6 <vprintfmt+0x7c>
            putch('%', putdat);
  800236:	85a6                	mv	a1,s1
  800238:	02500513          	li	a0,37
  80023c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80023e:	fff44783          	lbu	a5,-1(s0)
  800242:	8d22                	mv	s10,s0
  800244:	f73788e3          	beq	a5,s3,8001b4 <vprintfmt+0x3a>
  800248:	ffed4783          	lbu	a5,-2(s10)
  80024c:	1d7d                	addi	s10,s10,-1
  80024e:	ff379de3          	bne	a5,s3,800248 <vprintfmt+0xce>
  800252:	b78d                	j	8001b4 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
  800254:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
  800258:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80025c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80025e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800262:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  800266:	02d86463          	bltu	a6,a3,80028e <vprintfmt+0x114>
                ch = *fmt;
  80026a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
  80026e:	002c169b          	slliw	a3,s8,0x2
  800272:	0186873b          	addw	a4,a3,s8
  800276:	0017171b          	slliw	a4,a4,0x1
  80027a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
  80027c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
  800280:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800282:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
  800286:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
  80028a:	fed870e3          	bgeu	a6,a3,80026a <vprintfmt+0xf0>
            if (width < 0)
  80028e:	f40ddce3          	bgez	s11,8001e6 <vprintfmt+0x6c>
                width = precision, precision = -1;
  800292:	8de2                	mv	s11,s8
  800294:	5c7d                	li	s8,-1
  800296:	bf81                	j	8001e6 <vprintfmt+0x6c>
            if (width < 0)
  800298:	fffdc693          	not	a3,s11
  80029c:	96fd                	srai	a3,a3,0x3f
  80029e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
  8002a2:	00144603          	lbu	a2,1(s0)
  8002a6:	2d81                	sext.w	s11,s11
  8002a8:	846a                	mv	s0,s10
            goto reswitch;
  8002aa:	bf35                	j	8001e6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
  8002ac:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002b0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  8002b4:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
  8002b6:	846a                	mv	s0,s10
            goto process_precision;
  8002b8:	bfd9                	j	80028e <vprintfmt+0x114>
    if (lflag >= 2) {
  8002ba:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002bc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002c0:	01174463          	blt	a4,a7,8002c8 <vprintfmt+0x14e>
    else if (lflag) {
  8002c4:	1a088e63          	beqz	a7,800480 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
  8002c8:	000a3603          	ld	a2,0(s4)
  8002cc:	46c1                	li	a3,16
  8002ce:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002d0:	2781                	sext.w	a5,a5
  8002d2:	876e                	mv	a4,s11
  8002d4:	85a6                	mv	a1,s1
  8002d6:	854a                	mv	a0,s2
  8002d8:	e37ff0ef          	jal	ra,80010e <printnum>
            break;
  8002dc:	bde1                	j	8001b4 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
  8002de:	000a2503          	lw	a0,0(s4)
  8002e2:	85a6                	mv	a1,s1
  8002e4:	0a21                	addi	s4,s4,8
  8002e6:	9902                	jalr	s2
            break;
  8002e8:	b5f1                	j	8001b4 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002ea:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ec:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002f0:	01174463          	blt	a4,a7,8002f8 <vprintfmt+0x17e>
    else if (lflag) {
  8002f4:	18088163          	beqz	a7,800476 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
  8002f8:	000a3603          	ld	a2,0(s4)
  8002fc:	46a9                	li	a3,10
  8002fe:	8a2e                	mv	s4,a1
  800300:	bfc1                	j	8002d0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
  800302:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800306:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
  800308:	846a                	mv	s0,s10
            goto reswitch;
  80030a:	bdf1                	j	8001e6 <vprintfmt+0x6c>
            putch(ch, putdat);
  80030c:	85a6                	mv	a1,s1
  80030e:	02500513          	li	a0,37
  800312:	9902                	jalr	s2
            break;
  800314:	b545                	j	8001b4 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
  800316:	00144603          	lbu	a2,1(s0)
            lflag ++;
  80031a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
  80031c:	846a                	mv	s0,s10
            goto reswitch;
  80031e:	b5e1                	j	8001e6 <vprintfmt+0x6c>
    if (lflag >= 2) {
  800320:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800322:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800326:	01174463          	blt	a4,a7,80032e <vprintfmt+0x1b4>
    else if (lflag) {
  80032a:	14088163          	beqz	a7,80046c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
  80032e:	000a3603          	ld	a2,0(s4)
  800332:	46a1                	li	a3,8
  800334:	8a2e                	mv	s4,a1
  800336:	bf69                	j	8002d0 <vprintfmt+0x156>
            putch('0', putdat);
  800338:	03000513          	li	a0,48
  80033c:	85a6                	mv	a1,s1
  80033e:	e03e                	sd	a5,0(sp)
  800340:	9902                	jalr	s2
            putch('x', putdat);
  800342:	85a6                	mv	a1,s1
  800344:	07800513          	li	a0,120
  800348:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80034a:	0a21                	addi	s4,s4,8
            goto number;
  80034c:	6782                	ld	a5,0(sp)
  80034e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800350:	ff8a3603          	ld	a2,-8(s4)
            goto number;
  800354:	bfb5                	j	8002d0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
  800356:	000a3403          	ld	s0,0(s4)
  80035a:	008a0713          	addi	a4,s4,8
  80035e:	e03a                	sd	a4,0(sp)
  800360:	14040263          	beqz	s0,8004a4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
  800364:	0fb05763          	blez	s11,800452 <vprintfmt+0x2d8>
  800368:	02d00693          	li	a3,45
  80036c:	0cd79163          	bne	a5,a3,80042e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800370:	00044783          	lbu	a5,0(s0)
  800374:	0007851b          	sext.w	a0,a5
  800378:	cf85                	beqz	a5,8003b0 <vprintfmt+0x236>
  80037a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
  80037e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800382:	000c4563          	bltz	s8,80038c <vprintfmt+0x212>
  800386:	3c7d                	addiw	s8,s8,-1
  800388:	036c0263          	beq	s8,s6,8003ac <vprintfmt+0x232>
                    putch('?', putdat);
  80038c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80038e:	0e0c8e63          	beqz	s9,80048a <vprintfmt+0x310>
  800392:	3781                	addiw	a5,a5,-32
  800394:	0ef47b63          	bgeu	s0,a5,80048a <vprintfmt+0x310>
                    putch('?', putdat);
  800398:	03f00513          	li	a0,63
  80039c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80039e:	000a4783          	lbu	a5,0(s4)
  8003a2:	3dfd                	addiw	s11,s11,-1
  8003a4:	0a05                	addi	s4,s4,1
  8003a6:	0007851b          	sext.w	a0,a5
  8003aa:	ffe1                	bnez	a5,800382 <vprintfmt+0x208>
            for (; width > 0; width --) {
  8003ac:	01b05963          	blez	s11,8003be <vprintfmt+0x244>
  8003b0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b2:	85a6                	mv	a1,s1
  8003b4:	02000513          	li	a0,32
  8003b8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ba:	fe0d9be3          	bnez	s11,8003b0 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003be:	6a02                	ld	s4,0(sp)
  8003c0:	bbd5                	j	8001b4 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003c2:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003c4:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
  8003c8:	01174463          	blt	a4,a7,8003d0 <vprintfmt+0x256>
    else if (lflag) {
  8003cc:	08088d63          	beqz	a7,800466 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
  8003d0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003d4:	0a044d63          	bltz	s0,80048e <vprintfmt+0x314>
            num = getint(&ap, lflag);
  8003d8:	8622                	mv	a2,s0
  8003da:	8a66                	mv	s4,s9
  8003dc:	46a9                	li	a3,10
  8003de:	bdcd                	j	8002d0 <vprintfmt+0x156>
            err = va_arg(ap, int);
  8003e0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003e4:	4761                	li	a4,24
            err = va_arg(ap, int);
  8003e6:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003e8:	41f7d69b          	sraiw	a3,a5,0x1f
  8003ec:	8fb5                	xor	a5,a5,a3
  8003ee:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f2:	02d74163          	blt	a4,a3,800414 <vprintfmt+0x29a>
  8003f6:	00369793          	slli	a5,a3,0x3
  8003fa:	97de                	add	a5,a5,s7
  8003fc:	639c                	ld	a5,0(a5)
  8003fe:	cb99                	beqz	a5,800414 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
  800400:	86be                	mv	a3,a5
  800402:	00000617          	auipc	a2,0x0
  800406:	25660613          	addi	a2,a2,598 # 800658 <main+0x15c>
  80040a:	85a6                	mv	a1,s1
  80040c:	854a                	mv	a0,s2
  80040e:	0ce000ef          	jal	ra,8004dc <printfmt>
  800412:	b34d                	j	8001b4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800414:	00000617          	auipc	a2,0x0
  800418:	23460613          	addi	a2,a2,564 # 800648 <main+0x14c>
  80041c:	85a6                	mv	a1,s1
  80041e:	854a                	mv	a0,s2
  800420:	0bc000ef          	jal	ra,8004dc <printfmt>
  800424:	bb41                	j	8001b4 <vprintfmt+0x3a>
                p = "(null)";
  800426:	00000417          	auipc	s0,0x0
  80042a:	21a40413          	addi	s0,s0,538 # 800640 <main+0x144>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80042e:	85e2                	mv	a1,s8
  800430:	8522                	mv	a0,s0
  800432:	e43e                	sd	a5,8(sp)
  800434:	cbfff0ef          	jal	ra,8000f2 <strnlen>
  800438:	40ad8dbb          	subw	s11,s11,a0
  80043c:	01b05b63          	blez	s11,800452 <vprintfmt+0x2d8>
                    putch(padc, putdat);
  800440:	67a2                	ld	a5,8(sp)
  800442:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800446:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800448:	85a6                	mv	a1,s1
  80044a:	8552                	mv	a0,s4
  80044c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80044e:	fe0d9ce3          	bnez	s11,800446 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800452:	00044783          	lbu	a5,0(s0)
  800456:	00140a13          	addi	s4,s0,1
  80045a:	0007851b          	sext.w	a0,a5
  80045e:	d3a5                	beqz	a5,8003be <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
  800460:	05e00413          	li	s0,94
  800464:	bf39                	j	800382 <vprintfmt+0x208>
        return va_arg(*ap, int);
  800466:	000a2403          	lw	s0,0(s4)
  80046a:	b7ad                	j	8003d4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
  80046c:	000a6603          	lwu	a2,0(s4)
  800470:	46a1                	li	a3,8
  800472:	8a2e                	mv	s4,a1
  800474:	bdb1                	j	8002d0 <vprintfmt+0x156>
  800476:	000a6603          	lwu	a2,0(s4)
  80047a:	46a9                	li	a3,10
  80047c:	8a2e                	mv	s4,a1
  80047e:	bd89                	j	8002d0 <vprintfmt+0x156>
  800480:	000a6603          	lwu	a2,0(s4)
  800484:	46c1                	li	a3,16
  800486:	8a2e                	mv	s4,a1
  800488:	b5a1                	j	8002d0 <vprintfmt+0x156>
                    putch(ch, putdat);
  80048a:	9902                	jalr	s2
  80048c:	bf09                	j	80039e <vprintfmt+0x224>
                putch('-', putdat);
  80048e:	85a6                	mv	a1,s1
  800490:	02d00513          	li	a0,45
  800494:	e03e                	sd	a5,0(sp)
  800496:	9902                	jalr	s2
                num = -(long long)num;
  800498:	6782                	ld	a5,0(sp)
  80049a:	8a66                	mv	s4,s9
  80049c:	40800633          	neg	a2,s0
  8004a0:	46a9                	li	a3,10
  8004a2:	b53d                	j	8002d0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
  8004a4:	03b05163          	blez	s11,8004c6 <vprintfmt+0x34c>
  8004a8:	02d00693          	li	a3,45
  8004ac:	f6d79de3          	bne	a5,a3,800426 <vprintfmt+0x2ac>
                p = "(null)";
  8004b0:	00000417          	auipc	s0,0x0
  8004b4:	19040413          	addi	s0,s0,400 # 800640 <main+0x144>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b8:	02800793          	li	a5,40
  8004bc:	02800513          	li	a0,40
  8004c0:	00140a13          	addi	s4,s0,1
  8004c4:	bd6d                	j	80037e <vprintfmt+0x204>
  8004c6:	00000a17          	auipc	s4,0x0
  8004ca:	17ba0a13          	addi	s4,s4,379 # 800641 <main+0x145>
  8004ce:	02800513          	li	a0,40
  8004d2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
  8004d6:	05e00413          	li	s0,94
  8004da:	b565                	j	800382 <vprintfmt+0x208>

00000000008004dc <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004dc:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004de:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004e4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004e6:	ec06                	sd	ra,24(sp)
  8004e8:	f83a                	sd	a4,48(sp)
  8004ea:	fc3e                	sd	a5,56(sp)
  8004ec:	e0c2                	sd	a6,64(sp)
  8004ee:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004f0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004f2:	c89ff0ef          	jal	ra,80017a <vprintfmt>
}
  8004f6:	60e2                	ld	ra,24(sp)
  8004f8:	6161                	addi	sp,sp,80
  8004fa:	8082                	ret

00000000008004fc <main>:
#include <ulib.h>
#include <string.h>

int global_var = 100;

int main(void) {
  8004fc:	1101                	addi	sp,sp,-32
  8004fe:	e822                	sd	s0,16(sp)
    cprintf("COW test: parent process start. global_var = %d\n", global_var);
  800500:	00001417          	auipc	s0,0x1
  800504:	b0040413          	addi	s0,s0,-1280 # 801000 <global_var>
  800508:	400c                	lw	a1,0(s0)
  80050a:	00000517          	auipc	a0,0x0
  80050e:	43650513          	addi	a0,a0,1078 # 800940 <error_string+0xc8>
int main(void) {
  800512:	ec06                	sd	ra,24(sp)
  800514:	e426                	sd	s1,8(sp)
    cprintf("COW test: parent process start. global_var = %d\n", global_var);
  800516:	b9bff0ef          	jal	ra,8000b0 <cprintf>

    int pid = fork();
  80051a:	b6fff0ef          	jal	ra,800088 <fork>

    if (pid == 0) {
  80051e:	c939                	beqz	a0,800574 <main+0x78>
        
        cprintf("COW test: child process exit.\n");
        exit(0);
    } else {
        // Parent process
        if (pid < 0) {
  800520:	0a054c63          	bltz	a0,8005d8 <main+0xdc>
            cprintf("COW test: fork failed.\n");
            exit(-1);
        }

        cprintf("COW test: parent waiting for child...\n");
  800524:	00000517          	auipc	a0,0x0
  800528:	58450513          	addi	a0,a0,1412 # 800aa8 <error_string+0x230>
  80052c:	b85ff0ef          	jal	ra,8000b0 <cprintf>
        if (wait() != 0) {
  800530:	b5bff0ef          	jal	ra,80008a <wait>
  800534:	e95d                	bnez	a0,8005ea <main+0xee>
            cprintf("COW test: wait failed.\n");
            exit(-1);
        }

        // Check global variable (should remain unchanged in parent)
        cprintf("COW test: parent process resumed. global_var = %d\n", global_var);
  800536:	400c                	lw	a1,0(s0)
  800538:	00000517          	auipc	a0,0x0
  80053c:	5b050513          	addi	a0,a0,1456 # 800ae8 <error_string+0x270>
  800540:	b71ff0ef          	jal	ra,8000b0 <cprintf>
        if (global_var == 100) {
  800544:	400c                	lw	a1,0(s0)
  800546:	06400793          	li	a5,100
  80054a:	00f58e63          	beq	a1,a5,800566 <main+0x6a>
            cprintf("COW test: success! Parent's global_var is unchanged.\n");
        } else {
            cprintf("COW test: failure! Parent's global_var was modified to %d.\n", global_var);
  80054e:	00000517          	auipc	a0,0x0
  800552:	60a50513          	addi	a0,a0,1546 # 800b58 <error_string+0x2e0>
  800556:	b5bff0ef          	jal	ra,8000b0 <cprintf>
        }
    }

    return 0;
}
  80055a:	60e2                	ld	ra,24(sp)
  80055c:	6442                	ld	s0,16(sp)
  80055e:	64a2                	ld	s1,8(sp)
  800560:	4501                	li	a0,0
  800562:	6105                	addi	sp,sp,32
  800564:	8082                	ret
            cprintf("COW test: success! Parent's global_var is unchanged.\n");
  800566:	00000517          	auipc	a0,0x0
  80056a:	5ba50513          	addi	a0,a0,1466 # 800b20 <error_string+0x2a8>
  80056e:	b43ff0ef          	jal	ra,8000b0 <cprintf>
  800572:	b7e5                	j	80055a <main+0x5e>
        cprintf("COW test: child process start. global_var = %d\n", global_var);
  800574:	400c                	lw	a1,0(s0)
  800576:	00000517          	auipc	a0,0x0
  80057a:	40250513          	addi	a0,a0,1026 # 800978 <error_string+0x100>
  80057e:	b33ff0ef          	jal	ra,8000b0 <cprintf>
        if (global_var != 100) {
  800582:	400c                	lw	a1,0(s0)
  800584:	06400793          	li	a5,100
  800588:	06f59a63          	bne	a1,a5,8005fc <main+0x100>
        cprintf("COW test: child modifying global_var to 200...\n");
  80058c:	00000517          	auipc	a0,0x0
  800590:	44c50513          	addi	a0,a0,1100 # 8009d8 <error_string+0x160>
  800594:	b1dff0ef          	jal	ra,8000b0 <cprintf>
        cprintf("COW test: child modified global_var. global_var = %d\n", global_var);
  800598:	0c800593          	li	a1,200
        global_var = 200;
  80059c:	0c800493          	li	s1,200
        cprintf("COW test: child modified global_var. global_var = %d\n", global_var);
  8005a0:	00000517          	auipc	a0,0x0
  8005a4:	46850513          	addi	a0,a0,1128 # 800a08 <error_string+0x190>
        global_var = 200;
  8005a8:	c004                	sw	s1,0(s0)
        cprintf("COW test: child modified global_var. global_var = %d\n", global_var);
  8005aa:	b07ff0ef          	jal	ra,8000b0 <cprintf>
        if (global_var != 200) {
  8005ae:	400c                	lw	a1,0(s0)
  8005b0:	00958b63          	beq	a1,s1,8005c6 <main+0xca>
             cprintf("COW test: child write error! global_var = %d\n", global_var);
  8005b4:	00000517          	auipc	a0,0x0
  8005b8:	48c50513          	addi	a0,a0,1164 # 800a40 <error_string+0x1c8>
  8005bc:	af5ff0ef          	jal	ra,8000b0 <cprintf>
             exit(-1);
  8005c0:	557d                	li	a0,-1
  8005c2:	ab1ff0ef          	jal	ra,800072 <exit>
        cprintf("COW test: child process exit.\n");
  8005c6:	00000517          	auipc	a0,0x0
  8005ca:	4aa50513          	addi	a0,a0,1194 # 800a70 <error_string+0x1f8>
  8005ce:	ae3ff0ef          	jal	ra,8000b0 <cprintf>
        exit(0);
  8005d2:	4501                	li	a0,0
  8005d4:	a9fff0ef          	jal	ra,800072 <exit>
            cprintf("COW test: fork failed.\n");
  8005d8:	00000517          	auipc	a0,0x0
  8005dc:	4b850513          	addi	a0,a0,1208 # 800a90 <error_string+0x218>
  8005e0:	ad1ff0ef          	jal	ra,8000b0 <cprintf>
            exit(-1);
  8005e4:	557d                	li	a0,-1
  8005e6:	a8dff0ef          	jal	ra,800072 <exit>
            cprintf("COW test: wait failed.\n");
  8005ea:	00000517          	auipc	a0,0x0
  8005ee:	4e650513          	addi	a0,a0,1254 # 800ad0 <error_string+0x258>
  8005f2:	abfff0ef          	jal	ra,8000b0 <cprintf>
            exit(-1);
  8005f6:	557d                	li	a0,-1
  8005f8:	a7bff0ef          	jal	ra,800072 <exit>
            cprintf("COW test: child read error! global_var = %d\n", global_var);
  8005fc:	00000517          	auipc	a0,0x0
  800600:	3ac50513          	addi	a0,a0,940 # 8009a8 <error_string+0x130>
  800604:	aadff0ef          	jal	ra,8000b0 <cprintf>
            exit(-1);
  800608:	557d                	li	a0,-1
  80060a:	a69ff0ef          	jal	ra,800072 <exit>
