
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000b297          	auipc	t0,0xb
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020b000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000b297          	auipc	t0,0xb
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020b008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020a2b7          	lui	t0,0xc020a
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c020a137          	lui	sp,0xc020a

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc020004a:	000b1517          	auipc	a0,0xb1
ffffffffc020004e:	c2650513          	addi	a0,a0,-986 # ffffffffc02b0c70 <buf>
ffffffffc0200052:	000b5617          	auipc	a2,0xb5
ffffffffc0200056:	0d260613          	addi	a2,a2,210 # ffffffffc02b5124 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	57c050ef          	jal	ra,ffffffffc02055de <memset>
    dtb_init();
ffffffffc0200066:	4d6000ef          	jal	ra,ffffffffc020053c <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	0d7000ef          	jal	ra,ffffffffc0200940 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00006597          	auipc	a1,0x6
ffffffffc0200072:	9a258593          	addi	a1,a1,-1630 # ffffffffc0205a10 <etext+0x4>
ffffffffc0200076:	00006517          	auipc	a0,0x6
ffffffffc020007a:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0205a30 <etext+0x24>
ffffffffc020007e:	062000ef          	jal	ra,ffffffffc02000e0 <cprintf>

    print_kerninfo();
ffffffffc0200082:	248000ef          	jal	ra,ffffffffc02002ca <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	0a3010ef          	jal	ra,ffffffffc0201928 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	129000ef          	jal	ra,ffffffffc02009b2 <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	133000ef          	jal	ra,ffffffffc02009c0 <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	631020ef          	jal	ra,ffffffffc0202ec2 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	108050ef          	jal	ra,ffffffffc020519e <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	053000ef          	jal	ra,ffffffffc02008ec <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	117000ef          	jal	ra,ffffffffc02009b4 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	294050ef          	jal	ra,ffffffffc0205336 <cpu_idle>

ffffffffc02000a6 <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc02000a6:	1141                	addi	sp,sp,-16
ffffffffc02000a8:	e022                	sd	s0,0(sp)
ffffffffc02000aa:	e406                	sd	ra,8(sp)
ffffffffc02000ac:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc02000ae:	095000ef          	jal	ra,ffffffffc0200942 <cons_putc>
    (*cnt)++;
ffffffffc02000b2:	401c                	lw	a5,0(s0)
}
ffffffffc02000b4:	60a2                	ld	ra,8(sp)
    (*cnt)++;
ffffffffc02000b6:	2785                	addiw	a5,a5,1
ffffffffc02000b8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000ba:	6402                	ld	s0,0(sp)
ffffffffc02000bc:	0141                	addi	sp,sp,16
ffffffffc02000be:	8082                	ret

ffffffffc02000c0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc02000c0:	1101                	addi	sp,sp,-32
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fe050513          	addi	a0,a0,-32 # ffffffffc02000a6 <cputch>
ffffffffc02000ce:	006c                	addi	a1,sp,12
{
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000d2:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000d4:	5a0050ef          	jal	ra,ffffffffc0205674 <vprintfmt>
    return cnt;
}
ffffffffc02000d8:	60e2                	ld	ra,24(sp)
ffffffffc02000da:	4532                	lw	a0,12(sp)
ffffffffc02000dc:	6105                	addi	sp,sp,32
ffffffffc02000de:	8082                	ret

ffffffffc02000e0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc02000e0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000e2:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
{
ffffffffc02000e6:	8e2a                	mv	t3,a0
ffffffffc02000e8:	f42e                	sd	a1,40(sp)
ffffffffc02000ea:	f832                	sd	a2,48(sp)
ffffffffc02000ec:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000ee:	00000517          	auipc	a0,0x0
ffffffffc02000f2:	fb850513          	addi	a0,a0,-72 # ffffffffc02000a6 <cputch>
ffffffffc02000f6:	004c                	addi	a1,sp,4
ffffffffc02000f8:	869a                	mv	a3,t1
ffffffffc02000fa:	8672                	mv	a2,t3
{
ffffffffc02000fc:	ec06                	sd	ra,24(sp)
ffffffffc02000fe:	e0ba                	sd	a4,64(sp)
ffffffffc0200100:	e4be                	sd	a5,72(sp)
ffffffffc0200102:	e8c2                	sd	a6,80(sp)
ffffffffc0200104:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200106:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200108:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020010a:	56a050ef          	jal	ra,ffffffffc0205674 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020010e:	60e2                	ld	ra,24(sp)
ffffffffc0200110:	4512                	lw	a0,4(sp)
ffffffffc0200112:	6125                	addi	sp,sp,96
ffffffffc0200114:	8082                	ret

ffffffffc0200116 <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc0200116:	02d0006f          	j	ffffffffc0200942 <cons_putc>

ffffffffc020011a <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
ffffffffc020011a:	1101                	addi	sp,sp,-32
ffffffffc020011c:	e822                	sd	s0,16(sp)
ffffffffc020011e:	ec06                	sd	ra,24(sp)
ffffffffc0200120:	e426                	sd	s1,8(sp)
ffffffffc0200122:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
ffffffffc0200124:	00054503          	lbu	a0,0(a0)
ffffffffc0200128:	c51d                	beqz	a0,ffffffffc0200156 <cputs+0x3c>
ffffffffc020012a:	0405                	addi	s0,s0,1
ffffffffc020012c:	4485                	li	s1,1
ffffffffc020012e:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200130:	013000ef          	jal	ra,ffffffffc0200942 <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc0200134:	00044503          	lbu	a0,0(s0)
ffffffffc0200138:	008487bb          	addw	a5,s1,s0
ffffffffc020013c:	0405                	addi	s0,s0,1
ffffffffc020013e:	f96d                	bnez	a0,ffffffffc0200130 <cputs+0x16>
    (*cnt)++;
ffffffffc0200140:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200144:	4529                	li	a0,10
ffffffffc0200146:	7fc000ef          	jal	ra,ffffffffc0200942 <cons_putc>
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020014a:	60e2                	ld	ra,24(sp)
ffffffffc020014c:	8522                	mv	a0,s0
ffffffffc020014e:	6442                	ld	s0,16(sp)
ffffffffc0200150:	64a2                	ld	s1,8(sp)
ffffffffc0200152:	6105                	addi	sp,sp,32
ffffffffc0200154:	8082                	ret
    while ((c = *str++) != '\0')
ffffffffc0200156:	4405                	li	s0,1
ffffffffc0200158:	b7f5                	j	ffffffffc0200144 <cputs+0x2a>

ffffffffc020015a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc020015a:	1141                	addi	sp,sp,-16
ffffffffc020015c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020015e:	019000ef          	jal	ra,ffffffffc0200976 <cons_getc>
ffffffffc0200162:	dd75                	beqz	a0,ffffffffc020015e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200164:	60a2                	ld	ra,8(sp)
ffffffffc0200166:	0141                	addi	sp,sp,16
ffffffffc0200168:	8082                	ret

ffffffffc020016a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020016a:	715d                	addi	sp,sp,-80
ffffffffc020016c:	e486                	sd	ra,72(sp)
ffffffffc020016e:	e0a6                	sd	s1,64(sp)
ffffffffc0200170:	fc4a                	sd	s2,56(sp)
ffffffffc0200172:	f84e                	sd	s3,48(sp)
ffffffffc0200174:	f452                	sd	s4,40(sp)
ffffffffc0200176:	f056                	sd	s5,32(sp)
ffffffffc0200178:	ec5a                	sd	s6,24(sp)
ffffffffc020017a:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020017c:	c901                	beqz	a0,ffffffffc020018c <readline+0x22>
ffffffffc020017e:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0200180:	00006517          	auipc	a0,0x6
ffffffffc0200184:	8b850513          	addi	a0,a0,-1864 # ffffffffc0205a38 <etext+0x2c>
ffffffffc0200188:	f59ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
readline(const char *prompt) {
ffffffffc020018c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200190:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200192:	4aa9                	li	s5,10
ffffffffc0200194:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200196:	000b1b97          	auipc	s7,0xb1
ffffffffc020019a:	adab8b93          	addi	s7,s7,-1318 # ffffffffc02b0c70 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020019e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02001a2:	fb9ff0ef          	jal	ra,ffffffffc020015a <getchar>
        if (c < 0) {
ffffffffc02001a6:	00054a63          	bltz	a0,ffffffffc02001ba <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001aa:	00a95a63          	bge	s2,a0,ffffffffc02001be <readline+0x54>
ffffffffc02001ae:	029a5263          	bge	s4,s1,ffffffffc02001d2 <readline+0x68>
        c = getchar();
ffffffffc02001b2:	fa9ff0ef          	jal	ra,ffffffffc020015a <getchar>
        if (c < 0) {
ffffffffc02001b6:	fe055ae3          	bgez	a0,ffffffffc02001aa <readline+0x40>
            return NULL;
ffffffffc02001ba:	4501                	li	a0,0
ffffffffc02001bc:	a091                	j	ffffffffc0200200 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02001be:	03351463          	bne	a0,s3,ffffffffc02001e6 <readline+0x7c>
ffffffffc02001c2:	e8a9                	bnez	s1,ffffffffc0200214 <readline+0xaa>
        c = getchar();
ffffffffc02001c4:	f97ff0ef          	jal	ra,ffffffffc020015a <getchar>
        if (c < 0) {
ffffffffc02001c8:	fe0549e3          	bltz	a0,ffffffffc02001ba <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001cc:	fea959e3          	bge	s2,a0,ffffffffc02001be <readline+0x54>
ffffffffc02001d0:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001d2:	e42a                	sd	a0,8(sp)
ffffffffc02001d4:	f43ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            buf[i ++] = c;
ffffffffc02001d8:	6522                	ld	a0,8(sp)
ffffffffc02001da:	009b87b3          	add	a5,s7,s1
ffffffffc02001de:	2485                	addiw	s1,s1,1
ffffffffc02001e0:	00a78023          	sb	a0,0(a5)
ffffffffc02001e4:	bf7d                	j	ffffffffc02001a2 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001e6:	01550463          	beq	a0,s5,ffffffffc02001ee <readline+0x84>
ffffffffc02001ea:	fb651ce3          	bne	a0,s6,ffffffffc02001a2 <readline+0x38>
            cputchar(c);
ffffffffc02001ee:	f29ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            buf[i] = '\0';
ffffffffc02001f2:	000b1517          	auipc	a0,0xb1
ffffffffc02001f6:	a7e50513          	addi	a0,a0,-1410 # ffffffffc02b0c70 <buf>
ffffffffc02001fa:	94aa                	add	s1,s1,a0
ffffffffc02001fc:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200200:	60a6                	ld	ra,72(sp)
ffffffffc0200202:	6486                	ld	s1,64(sp)
ffffffffc0200204:	7962                	ld	s2,56(sp)
ffffffffc0200206:	79c2                	ld	s3,48(sp)
ffffffffc0200208:	7a22                	ld	s4,40(sp)
ffffffffc020020a:	7a82                	ld	s5,32(sp)
ffffffffc020020c:	6b62                	ld	s6,24(sp)
ffffffffc020020e:	6bc2                	ld	s7,16(sp)
ffffffffc0200210:	6161                	addi	sp,sp,80
ffffffffc0200212:	8082                	ret
            cputchar(c);
ffffffffc0200214:	4521                	li	a0,8
ffffffffc0200216:	f01ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            i --;
ffffffffc020021a:	34fd                	addiw	s1,s1,-1
ffffffffc020021c:	b759                	j	ffffffffc02001a2 <readline+0x38>

ffffffffc020021e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void __panic(const char *file, int line, const char *fmt, ...)
{
    if (is_panic)
ffffffffc020021e:	000b5317          	auipc	t1,0xb5
ffffffffc0200222:	e7a30313          	addi	t1,t1,-390 # ffffffffc02b5098 <is_panic>
ffffffffc0200226:	00033e03          	ld	t3,0(t1)
{
ffffffffc020022a:	715d                	addi	sp,sp,-80
ffffffffc020022c:	ec06                	sd	ra,24(sp)
ffffffffc020022e:	e822                	sd	s0,16(sp)
ffffffffc0200230:	f436                	sd	a3,40(sp)
ffffffffc0200232:	f83a                	sd	a4,48(sp)
ffffffffc0200234:	fc3e                	sd	a5,56(sp)
ffffffffc0200236:	e0c2                	sd	a6,64(sp)
ffffffffc0200238:	e4c6                	sd	a7,72(sp)
    if (is_panic)
ffffffffc020023a:	020e1a63          	bnez	t3,ffffffffc020026e <__panic+0x50>
    {
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020023e:	4785                	li	a5,1
ffffffffc0200240:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200244:	8432                	mv	s0,a2
ffffffffc0200246:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200248:	862e                	mv	a2,a1
ffffffffc020024a:	85aa                	mv	a1,a0
ffffffffc020024c:	00005517          	auipc	a0,0x5
ffffffffc0200250:	7f450513          	addi	a0,a0,2036 # ffffffffc0205a40 <etext+0x34>
    va_start(ap, fmt);
ffffffffc0200254:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200256:	e8bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020025a:	65a2                	ld	a1,8(sp)
ffffffffc020025c:	8522                	mv	a0,s0
ffffffffc020025e:	e63ff0ef          	jal	ra,ffffffffc02000c0 <vcprintf>
    cprintf("\n");
ffffffffc0200262:	00006517          	auipc	a0,0x6
ffffffffc0200266:	71650513          	addi	a0,a0,1814 # ffffffffc0206978 <commands+0xcc0>
ffffffffc020026a:	e77ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020026e:	4501                	li	a0,0
ffffffffc0200270:	4581                	li	a1,0
ffffffffc0200272:	4601                	li	a2,0
ffffffffc0200274:	48a1                	li	a7,8
ffffffffc0200276:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc020027a:	740000ef          	jal	ra,ffffffffc02009ba <intr_disable>
    while (1)
    {
        kmonitor(NULL);
ffffffffc020027e:	4501                	li	a0,0
ffffffffc0200280:	174000ef          	jal	ra,ffffffffc02003f4 <kmonitor>
    while (1)
ffffffffc0200284:	bfed                	j	ffffffffc020027e <__panic+0x60>

ffffffffc0200286 <__warn>:
    }
}

/* __warn - like panic, but don't */
void __warn(const char *file, int line, const char *fmt, ...)
{
ffffffffc0200286:	715d                	addi	sp,sp,-80
ffffffffc0200288:	832e                	mv	t1,a1
ffffffffc020028a:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020028c:	85aa                	mv	a1,a0
{
ffffffffc020028e:	8432                	mv	s0,a2
ffffffffc0200290:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200292:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc0200294:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200296:	00005517          	auipc	a0,0x5
ffffffffc020029a:	7ca50513          	addi	a0,a0,1994 # ffffffffc0205a60 <etext+0x54>
{
ffffffffc020029e:	ec06                	sd	ra,24(sp)
ffffffffc02002a0:	f436                	sd	a3,40(sp)
ffffffffc02002a2:	f83a                	sd	a4,48(sp)
ffffffffc02002a4:	e0c2                	sd	a6,64(sp)
ffffffffc02002a6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002a8:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002aa:	e37ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002ae:	65a2                	ld	a1,8(sp)
ffffffffc02002b0:	8522                	mv	a0,s0
ffffffffc02002b2:	e0fff0ef          	jal	ra,ffffffffc02000c0 <vcprintf>
    cprintf("\n");
ffffffffc02002b6:	00006517          	auipc	a0,0x6
ffffffffc02002ba:	6c250513          	addi	a0,a0,1730 # ffffffffc0206978 <commands+0xcc0>
ffffffffc02002be:	e23ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    va_end(ap);
}
ffffffffc02002c2:	60e2                	ld	ra,24(sp)
ffffffffc02002c4:	6442                	ld	s0,16(sp)
ffffffffc02002c6:	6161                	addi	sp,sp,80
ffffffffc02002c8:	8082                	ret

ffffffffc02002ca <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc02002ca:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002cc:	00005517          	auipc	a0,0x5
ffffffffc02002d0:	7b450513          	addi	a0,a0,1972 # ffffffffc0205a80 <etext+0x74>
{
ffffffffc02002d4:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002d6:	e0bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002da:	00000597          	auipc	a1,0x0
ffffffffc02002de:	d7058593          	addi	a1,a1,-656 # ffffffffc020004a <kern_init>
ffffffffc02002e2:	00005517          	auipc	a0,0x5
ffffffffc02002e6:	7be50513          	addi	a0,a0,1982 # ffffffffc0205aa0 <etext+0x94>
ffffffffc02002ea:	df7ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002ee:	00005597          	auipc	a1,0x5
ffffffffc02002f2:	71e58593          	addi	a1,a1,1822 # ffffffffc0205a0c <etext>
ffffffffc02002f6:	00005517          	auipc	a0,0x5
ffffffffc02002fa:	7ca50513          	addi	a0,a0,1994 # ffffffffc0205ac0 <etext+0xb4>
ffffffffc02002fe:	de3ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200302:	000b1597          	auipc	a1,0xb1
ffffffffc0200306:	96e58593          	addi	a1,a1,-1682 # ffffffffc02b0c70 <buf>
ffffffffc020030a:	00005517          	auipc	a0,0x5
ffffffffc020030e:	7d650513          	addi	a0,a0,2006 # ffffffffc0205ae0 <etext+0xd4>
ffffffffc0200312:	dcfff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200316:	000b5597          	auipc	a1,0xb5
ffffffffc020031a:	e0e58593          	addi	a1,a1,-498 # ffffffffc02b5124 <end>
ffffffffc020031e:	00005517          	auipc	a0,0x5
ffffffffc0200322:	7e250513          	addi	a0,a0,2018 # ffffffffc0205b00 <etext+0xf4>
ffffffffc0200326:	dbbff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020032a:	000b5597          	auipc	a1,0xb5
ffffffffc020032e:	1f958593          	addi	a1,a1,505 # ffffffffc02b5523 <end+0x3ff>
ffffffffc0200332:	00000797          	auipc	a5,0x0
ffffffffc0200336:	d1878793          	addi	a5,a5,-744 # ffffffffc020004a <kern_init>
ffffffffc020033a:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020033e:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200342:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200344:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200348:	95be                	add	a1,a1,a5
ffffffffc020034a:	85a9                	srai	a1,a1,0xa
ffffffffc020034c:	00005517          	auipc	a0,0x5
ffffffffc0200350:	7d450513          	addi	a0,a0,2004 # ffffffffc0205b20 <etext+0x114>
}
ffffffffc0200354:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200356:	b369                	j	ffffffffc02000e0 <cprintf>

ffffffffc0200358 <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc0200358:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc020035a:	00005617          	auipc	a2,0x5
ffffffffc020035e:	7f660613          	addi	a2,a2,2038 # ffffffffc0205b50 <etext+0x144>
ffffffffc0200362:	04f00593          	li	a1,79
ffffffffc0200366:	00006517          	auipc	a0,0x6
ffffffffc020036a:	80250513          	addi	a0,a0,-2046 # ffffffffc0205b68 <etext+0x15c>
{
ffffffffc020036e:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200370:	eafff0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0200374 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int mon_help(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200374:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i++)
    {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200376:	00006617          	auipc	a2,0x6
ffffffffc020037a:	80a60613          	addi	a2,a2,-2038 # ffffffffc0205b80 <etext+0x174>
ffffffffc020037e:	00006597          	auipc	a1,0x6
ffffffffc0200382:	82258593          	addi	a1,a1,-2014 # ffffffffc0205ba0 <etext+0x194>
ffffffffc0200386:	00006517          	auipc	a0,0x6
ffffffffc020038a:	82250513          	addi	a0,a0,-2014 # ffffffffc0205ba8 <etext+0x19c>
{
ffffffffc020038e:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200390:	d51ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200394:	00006617          	auipc	a2,0x6
ffffffffc0200398:	82460613          	addi	a2,a2,-2012 # ffffffffc0205bb8 <etext+0x1ac>
ffffffffc020039c:	00006597          	auipc	a1,0x6
ffffffffc02003a0:	84458593          	addi	a1,a1,-1980 # ffffffffc0205be0 <etext+0x1d4>
ffffffffc02003a4:	00006517          	auipc	a0,0x6
ffffffffc02003a8:	80450513          	addi	a0,a0,-2044 # ffffffffc0205ba8 <etext+0x19c>
ffffffffc02003ac:	d35ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc02003b0:	00006617          	auipc	a2,0x6
ffffffffc02003b4:	84060613          	addi	a2,a2,-1984 # ffffffffc0205bf0 <etext+0x1e4>
ffffffffc02003b8:	00006597          	auipc	a1,0x6
ffffffffc02003bc:	85858593          	addi	a1,a1,-1960 # ffffffffc0205c10 <etext+0x204>
ffffffffc02003c0:	00005517          	auipc	a0,0x5
ffffffffc02003c4:	7e850513          	addi	a0,a0,2024 # ffffffffc0205ba8 <etext+0x19c>
ffffffffc02003c8:	d19ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    return 0;
}
ffffffffc02003cc:	60a2                	ld	ra,8(sp)
ffffffffc02003ce:	4501                	li	a0,0
ffffffffc02003d0:	0141                	addi	sp,sp,16
ffffffffc02003d2:	8082                	ret

ffffffffc02003d4 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int mon_kerninfo(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02003d4:	1141                	addi	sp,sp,-16
ffffffffc02003d6:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003d8:	ef3ff0ef          	jal	ra,ffffffffc02002ca <print_kerninfo>
    return 0;
}
ffffffffc02003dc:	60a2                	ld	ra,8(sp)
ffffffffc02003de:	4501                	li	a0,0
ffffffffc02003e0:	0141                	addi	sp,sp,16
ffffffffc02003e2:	8082                	ret

ffffffffc02003e4 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int mon_backtrace(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02003e4:	1141                	addi	sp,sp,-16
ffffffffc02003e6:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003e8:	f71ff0ef          	jal	ra,ffffffffc0200358 <print_stackframe>
    return 0;
}
ffffffffc02003ec:	60a2                	ld	ra,8(sp)
ffffffffc02003ee:	4501                	li	a0,0
ffffffffc02003f0:	0141                	addi	sp,sp,16
ffffffffc02003f2:	8082                	ret

ffffffffc02003f4 <kmonitor>:
{
ffffffffc02003f4:	7115                	addi	sp,sp,-224
ffffffffc02003f6:	ed5e                	sd	s7,152(sp)
ffffffffc02003f8:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003fa:	00006517          	auipc	a0,0x6
ffffffffc02003fe:	82650513          	addi	a0,a0,-2010 # ffffffffc0205c20 <etext+0x214>
{
ffffffffc0200402:	ed86                	sd	ra,216(sp)
ffffffffc0200404:	e9a2                	sd	s0,208(sp)
ffffffffc0200406:	e5a6                	sd	s1,200(sp)
ffffffffc0200408:	e1ca                	sd	s2,192(sp)
ffffffffc020040a:	fd4e                	sd	s3,184(sp)
ffffffffc020040c:	f952                	sd	s4,176(sp)
ffffffffc020040e:	f556                	sd	s5,168(sp)
ffffffffc0200410:	f15a                	sd	s6,160(sp)
ffffffffc0200412:	e962                	sd	s8,144(sp)
ffffffffc0200414:	e566                	sd	s9,136(sp)
ffffffffc0200416:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200418:	cc9ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020041c:	00006517          	auipc	a0,0x6
ffffffffc0200420:	82c50513          	addi	a0,a0,-2004 # ffffffffc0205c48 <etext+0x23c>
ffffffffc0200424:	cbdff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    if (tf != NULL)
ffffffffc0200428:	000b8563          	beqz	s7,ffffffffc0200432 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020042c:	855e                	mv	a0,s7
ffffffffc020042e:	77a000ef          	jal	ra,ffffffffc0200ba8 <print_trapframe>
ffffffffc0200432:	00006c17          	auipc	s8,0x6
ffffffffc0200436:	886c0c13          	addi	s8,s8,-1914 # ffffffffc0205cb8 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020043a:	00006917          	auipc	s2,0x6
ffffffffc020043e:	83690913          	addi	s2,s2,-1994 # ffffffffc0205c70 <etext+0x264>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200442:	00006497          	auipc	s1,0x6
ffffffffc0200446:	83648493          	addi	s1,s1,-1994 # ffffffffc0205c78 <etext+0x26c>
        if (argc == MAXARGS - 1)
ffffffffc020044a:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020044c:	00006b17          	auipc	s6,0x6
ffffffffc0200450:	834b0b13          	addi	s6,s6,-1996 # ffffffffc0205c80 <etext+0x274>
        argv[argc++] = buf;
ffffffffc0200454:	00005a17          	auipc	s4,0x5
ffffffffc0200458:	74ca0a13          	addi	s4,s4,1868 # ffffffffc0205ba0 <etext+0x194>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020045c:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL)
ffffffffc020045e:	854a                	mv	a0,s2
ffffffffc0200460:	d0bff0ef          	jal	ra,ffffffffc020016a <readline>
ffffffffc0200464:	842a                	mv	s0,a0
ffffffffc0200466:	dd65                	beqz	a0,ffffffffc020045e <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200468:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020046c:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020046e:	e1bd                	bnez	a1,ffffffffc02004d4 <kmonitor+0xe0>
    if (argc == 0)
ffffffffc0200470:	fe0c87e3          	beqz	s9,ffffffffc020045e <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200474:	6582                	ld	a1,0(sp)
ffffffffc0200476:	00006d17          	auipc	s10,0x6
ffffffffc020047a:	842d0d13          	addi	s10,s10,-1982 # ffffffffc0205cb8 <commands>
        argv[argc++] = buf;
ffffffffc020047e:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc0200480:	4401                	li	s0,0
ffffffffc0200482:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200484:	100050ef          	jal	ra,ffffffffc0205584 <strcmp>
ffffffffc0200488:	c919                	beqz	a0,ffffffffc020049e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020048a:	2405                	addiw	s0,s0,1
ffffffffc020048c:	0b540063          	beq	s0,s5,ffffffffc020052c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200490:	000d3503          	ld	a0,0(s10)
ffffffffc0200494:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc0200496:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200498:	0ec050ef          	jal	ra,ffffffffc0205584 <strcmp>
ffffffffc020049c:	f57d                	bnez	a0,ffffffffc020048a <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020049e:	00141793          	slli	a5,s0,0x1
ffffffffc02004a2:	97a2                	add	a5,a5,s0
ffffffffc02004a4:	078e                	slli	a5,a5,0x3
ffffffffc02004a6:	97e2                	add	a5,a5,s8
ffffffffc02004a8:	6b9c                	ld	a5,16(a5)
ffffffffc02004aa:	865e                	mv	a2,s7
ffffffffc02004ac:	002c                	addi	a1,sp,8
ffffffffc02004ae:	fffc851b          	addiw	a0,s9,-1
ffffffffc02004b2:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0)
ffffffffc02004b4:	fa0555e3          	bgez	a0,ffffffffc020045e <kmonitor+0x6a>
}
ffffffffc02004b8:	60ee                	ld	ra,216(sp)
ffffffffc02004ba:	644e                	ld	s0,208(sp)
ffffffffc02004bc:	64ae                	ld	s1,200(sp)
ffffffffc02004be:	690e                	ld	s2,192(sp)
ffffffffc02004c0:	79ea                	ld	s3,184(sp)
ffffffffc02004c2:	7a4a                	ld	s4,176(sp)
ffffffffc02004c4:	7aaa                	ld	s5,168(sp)
ffffffffc02004c6:	7b0a                	ld	s6,160(sp)
ffffffffc02004c8:	6bea                	ld	s7,152(sp)
ffffffffc02004ca:	6c4a                	ld	s8,144(sp)
ffffffffc02004cc:	6caa                	ld	s9,136(sp)
ffffffffc02004ce:	6d0a                	ld	s10,128(sp)
ffffffffc02004d0:	612d                	addi	sp,sp,224
ffffffffc02004d2:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02004d4:	8526                	mv	a0,s1
ffffffffc02004d6:	0f2050ef          	jal	ra,ffffffffc02055c8 <strchr>
ffffffffc02004da:	c901                	beqz	a0,ffffffffc02004ea <kmonitor+0xf6>
ffffffffc02004dc:	00144583          	lbu	a1,1(s0)
            *buf++ = '\0';
ffffffffc02004e0:	00040023          	sb	zero,0(s0)
ffffffffc02004e4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02004e6:	d5c9                	beqz	a1,ffffffffc0200470 <kmonitor+0x7c>
ffffffffc02004e8:	b7f5                	j	ffffffffc02004d4 <kmonitor+0xe0>
        if (*buf == '\0')
ffffffffc02004ea:	00044783          	lbu	a5,0(s0)
ffffffffc02004ee:	d3c9                	beqz	a5,ffffffffc0200470 <kmonitor+0x7c>
        if (argc == MAXARGS - 1)
ffffffffc02004f0:	033c8963          	beq	s9,s3,ffffffffc0200522 <kmonitor+0x12e>
        argv[argc++] = buf;
ffffffffc02004f4:	003c9793          	slli	a5,s9,0x3
ffffffffc02004f8:	0118                	addi	a4,sp,128
ffffffffc02004fa:	97ba                	add	a5,a5,a4
ffffffffc02004fc:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200500:	00044583          	lbu	a1,0(s0)
        argv[argc++] = buf;
ffffffffc0200504:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200506:	e591                	bnez	a1,ffffffffc0200512 <kmonitor+0x11e>
ffffffffc0200508:	b7b5                	j	ffffffffc0200474 <kmonitor+0x80>
ffffffffc020050a:	00144583          	lbu	a1,1(s0)
            buf++;
ffffffffc020050e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200510:	d1a5                	beqz	a1,ffffffffc0200470 <kmonitor+0x7c>
ffffffffc0200512:	8526                	mv	a0,s1
ffffffffc0200514:	0b4050ef          	jal	ra,ffffffffc02055c8 <strchr>
ffffffffc0200518:	d96d                	beqz	a0,ffffffffc020050a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020051a:	00044583          	lbu	a1,0(s0)
ffffffffc020051e:	d9a9                	beqz	a1,ffffffffc0200470 <kmonitor+0x7c>
ffffffffc0200520:	bf55                	j	ffffffffc02004d4 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200522:	45c1                	li	a1,16
ffffffffc0200524:	855a                	mv	a0,s6
ffffffffc0200526:	bbbff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc020052a:	b7e9                	j	ffffffffc02004f4 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020052c:	6582                	ld	a1,0(sp)
ffffffffc020052e:	00005517          	auipc	a0,0x5
ffffffffc0200532:	77250513          	addi	a0,a0,1906 # ffffffffc0205ca0 <etext+0x294>
ffffffffc0200536:	babff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return 0;
ffffffffc020053a:	b715                	j	ffffffffc020045e <kmonitor+0x6a>

ffffffffc020053c <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc020053c:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc020053e:	00005517          	auipc	a0,0x5
ffffffffc0200542:	7c250513          	addi	a0,a0,1986 # ffffffffc0205d00 <commands+0x48>
void dtb_init(void) {
ffffffffc0200546:	fc86                	sd	ra,120(sp)
ffffffffc0200548:	f8a2                	sd	s0,112(sp)
ffffffffc020054a:	e8d2                	sd	s4,80(sp)
ffffffffc020054c:	f4a6                	sd	s1,104(sp)
ffffffffc020054e:	f0ca                	sd	s2,96(sp)
ffffffffc0200550:	ecce                	sd	s3,88(sp)
ffffffffc0200552:	e4d6                	sd	s5,72(sp)
ffffffffc0200554:	e0da                	sd	s6,64(sp)
ffffffffc0200556:	fc5e                	sd	s7,56(sp)
ffffffffc0200558:	f862                	sd	s8,48(sp)
ffffffffc020055a:	f466                	sd	s9,40(sp)
ffffffffc020055c:	f06a                	sd	s10,32(sp)
ffffffffc020055e:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200560:	b81ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200564:	0000b597          	auipc	a1,0xb
ffffffffc0200568:	a9c5b583          	ld	a1,-1380(a1) # ffffffffc020b000 <boot_hartid>
ffffffffc020056c:	00005517          	auipc	a0,0x5
ffffffffc0200570:	7a450513          	addi	a0,a0,1956 # ffffffffc0205d10 <commands+0x58>
ffffffffc0200574:	b6dff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200578:	0000b417          	auipc	s0,0xb
ffffffffc020057c:	a9040413          	addi	s0,s0,-1392 # ffffffffc020b008 <boot_dtb>
ffffffffc0200580:	600c                	ld	a1,0(s0)
ffffffffc0200582:	00005517          	auipc	a0,0x5
ffffffffc0200586:	79e50513          	addi	a0,a0,1950 # ffffffffc0205d20 <commands+0x68>
ffffffffc020058a:	b57ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020058e:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200592:	00005517          	auipc	a0,0x5
ffffffffc0200596:	7a650513          	addi	a0,a0,1958 # ffffffffc0205d38 <commands+0x80>
    if (boot_dtb == 0) {
ffffffffc020059a:	120a0463          	beqz	s4,ffffffffc02006c2 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc020059e:	57f5                	li	a5,-3
ffffffffc02005a0:	07fa                	slli	a5,a5,0x1e
ffffffffc02005a2:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc02005a6:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005a8:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ac:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ae:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005b2:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005b6:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ba:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005be:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005c2:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005c4:	8ec9                	or	a3,a3,a0
ffffffffc02005c6:	0087979b          	slliw	a5,a5,0x8
ffffffffc02005ca:	1b7d                	addi	s6,s6,-1
ffffffffc02005cc:	0167f7b3          	and	a5,a5,s6
ffffffffc02005d0:	8dd5                	or	a1,a1,a3
ffffffffc02005d2:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02005d4:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005d8:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02005da:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe2adc9>
ffffffffc02005de:	10f59163          	bne	a1,a5,ffffffffc02006e0 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02005e2:	471c                	lw	a5,8(a4)
ffffffffc02005e4:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02005e6:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005e8:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005ec:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02005f0:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005f4:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005f8:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005fc:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200600:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200604:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200608:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020060c:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200610:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200612:	01146433          	or	s0,s0,a7
ffffffffc0200616:	0086969b          	slliw	a3,a3,0x8
ffffffffc020061a:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020061e:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200620:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200624:	8c49                	or	s0,s0,a0
ffffffffc0200626:	0166f6b3          	and	a3,a3,s6
ffffffffc020062a:	00ca6a33          	or	s4,s4,a2
ffffffffc020062e:	0167f7b3          	and	a5,a5,s6
ffffffffc0200632:	8c55                	or	s0,s0,a3
ffffffffc0200634:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200638:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020063a:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020063c:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020063e:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200642:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200644:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200646:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc020064a:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020064c:	00005917          	auipc	s2,0x5
ffffffffc0200650:	73c90913          	addi	s2,s2,1852 # ffffffffc0205d88 <commands+0xd0>
ffffffffc0200654:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200656:	4d91                	li	s11,4
ffffffffc0200658:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020065a:	00005497          	auipc	s1,0x5
ffffffffc020065e:	72648493          	addi	s1,s1,1830 # ffffffffc0205d80 <commands+0xc8>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200662:	000a2703          	lw	a4,0(s4)
ffffffffc0200666:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020066a:	0087569b          	srliw	a3,a4,0x8
ffffffffc020066e:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200672:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200676:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020067a:	0107571b          	srliw	a4,a4,0x10
ffffffffc020067e:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200680:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200684:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200688:	8fd5                	or	a5,a5,a3
ffffffffc020068a:	00eb7733          	and	a4,s6,a4
ffffffffc020068e:	8fd9                	or	a5,a5,a4
ffffffffc0200690:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200692:	09778c63          	beq	a5,s7,ffffffffc020072a <dtb_init+0x1ee>
ffffffffc0200696:	00fbea63          	bltu	s7,a5,ffffffffc02006aa <dtb_init+0x16e>
ffffffffc020069a:	07a78663          	beq	a5,s10,ffffffffc0200706 <dtb_init+0x1ca>
ffffffffc020069e:	4709                	li	a4,2
ffffffffc02006a0:	00e79763          	bne	a5,a4,ffffffffc02006ae <dtb_init+0x172>
ffffffffc02006a4:	4c81                	li	s9,0
ffffffffc02006a6:	8a56                	mv	s4,s5
ffffffffc02006a8:	bf6d                	j	ffffffffc0200662 <dtb_init+0x126>
ffffffffc02006aa:	ffb78ee3          	beq	a5,s11,ffffffffc02006a6 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc02006ae:	00005517          	auipc	a0,0x5
ffffffffc02006b2:	75250513          	addi	a0,a0,1874 # ffffffffc0205e00 <commands+0x148>
ffffffffc02006b6:	a2bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02006ba:	00005517          	auipc	a0,0x5
ffffffffc02006be:	77e50513          	addi	a0,a0,1918 # ffffffffc0205e38 <commands+0x180>
}
ffffffffc02006c2:	7446                	ld	s0,112(sp)
ffffffffc02006c4:	70e6                	ld	ra,120(sp)
ffffffffc02006c6:	74a6                	ld	s1,104(sp)
ffffffffc02006c8:	7906                	ld	s2,96(sp)
ffffffffc02006ca:	69e6                	ld	s3,88(sp)
ffffffffc02006cc:	6a46                	ld	s4,80(sp)
ffffffffc02006ce:	6aa6                	ld	s5,72(sp)
ffffffffc02006d0:	6b06                	ld	s6,64(sp)
ffffffffc02006d2:	7be2                	ld	s7,56(sp)
ffffffffc02006d4:	7c42                	ld	s8,48(sp)
ffffffffc02006d6:	7ca2                	ld	s9,40(sp)
ffffffffc02006d8:	7d02                	ld	s10,32(sp)
ffffffffc02006da:	6de2                	ld	s11,24(sp)
ffffffffc02006dc:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02006de:	b409                	j	ffffffffc02000e0 <cprintf>
}
ffffffffc02006e0:	7446                	ld	s0,112(sp)
ffffffffc02006e2:	70e6                	ld	ra,120(sp)
ffffffffc02006e4:	74a6                	ld	s1,104(sp)
ffffffffc02006e6:	7906                	ld	s2,96(sp)
ffffffffc02006e8:	69e6                	ld	s3,88(sp)
ffffffffc02006ea:	6a46                	ld	s4,80(sp)
ffffffffc02006ec:	6aa6                	ld	s5,72(sp)
ffffffffc02006ee:	6b06                	ld	s6,64(sp)
ffffffffc02006f0:	7be2                	ld	s7,56(sp)
ffffffffc02006f2:	7c42                	ld	s8,48(sp)
ffffffffc02006f4:	7ca2                	ld	s9,40(sp)
ffffffffc02006f6:	7d02                	ld	s10,32(sp)
ffffffffc02006f8:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02006fa:	00005517          	auipc	a0,0x5
ffffffffc02006fe:	65e50513          	addi	a0,a0,1630 # ffffffffc0205d58 <commands+0xa0>
}
ffffffffc0200702:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200704:	baf1                	j	ffffffffc02000e0 <cprintf>
                int name_len = strlen(name);
ffffffffc0200706:	8556                	mv	a0,s5
ffffffffc0200708:	635040ef          	jal	ra,ffffffffc020553c <strlen>
ffffffffc020070c:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020070e:	4619                	li	a2,6
ffffffffc0200710:	85a6                	mv	a1,s1
ffffffffc0200712:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc0200714:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200716:	68d040ef          	jal	ra,ffffffffc02055a2 <strncmp>
ffffffffc020071a:	e111                	bnez	a0,ffffffffc020071e <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc020071c:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc020071e:	0a91                	addi	s5,s5,4
ffffffffc0200720:	9ad2                	add	s5,s5,s4
ffffffffc0200722:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200726:	8a56                	mv	s4,s5
ffffffffc0200728:	bf2d                	j	ffffffffc0200662 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc020072a:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020072e:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200732:	0087d71b          	srliw	a4,a5,0x8
ffffffffc0200736:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020073a:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020073e:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200742:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200746:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020074a:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020074e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200752:	00eaeab3          	or	s5,s5,a4
ffffffffc0200756:	00fb77b3          	and	a5,s6,a5
ffffffffc020075a:	00faeab3          	or	s5,s5,a5
ffffffffc020075e:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200760:	000c9c63          	bnez	s9,ffffffffc0200778 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200764:	1a82                	slli	s5,s5,0x20
ffffffffc0200766:	00368793          	addi	a5,a3,3
ffffffffc020076a:	020ada93          	srli	s5,s5,0x20
ffffffffc020076e:	9abe                	add	s5,s5,a5
ffffffffc0200770:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200774:	8a56                	mv	s4,s5
ffffffffc0200776:	b5f5                	j	ffffffffc0200662 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200778:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020077c:	85ca                	mv	a1,s2
ffffffffc020077e:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200780:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200784:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200788:	0187971b          	slliw	a4,a5,0x18
ffffffffc020078c:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200790:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200794:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200796:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020079a:	0087979b          	slliw	a5,a5,0x8
ffffffffc020079e:	8d59                	or	a0,a0,a4
ffffffffc02007a0:	00fb77b3          	and	a5,s6,a5
ffffffffc02007a4:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc02007a6:	1502                	slli	a0,a0,0x20
ffffffffc02007a8:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007aa:	9522                	add	a0,a0,s0
ffffffffc02007ac:	5d9040ef          	jal	ra,ffffffffc0205584 <strcmp>
ffffffffc02007b0:	66a2                	ld	a3,8(sp)
ffffffffc02007b2:	f94d                	bnez	a0,ffffffffc0200764 <dtb_init+0x228>
ffffffffc02007b4:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200764 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02007b8:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02007bc:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02007c0:	00005517          	auipc	a0,0x5
ffffffffc02007c4:	5d050513          	addi	a0,a0,1488 # ffffffffc0205d90 <commands+0xd8>
           fdt32_to_cpu(x >> 32);
ffffffffc02007c8:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007cc:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02007d0:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007d4:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02007d8:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007dc:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007e0:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007e4:	0187d693          	srli	a3,a5,0x18
ffffffffc02007e8:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02007ec:	0087579b          	srliw	a5,a4,0x8
ffffffffc02007f0:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007f4:	0106561b          	srliw	a2,a2,0x10
ffffffffc02007f8:	010f6f33          	or	t5,t5,a6
ffffffffc02007fc:	0187529b          	srliw	t0,a4,0x18
ffffffffc0200800:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200804:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200808:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020080c:	0186f6b3          	and	a3,a3,s8
ffffffffc0200810:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200814:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200818:	0107581b          	srliw	a6,a4,0x10
ffffffffc020081c:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200820:	8361                	srli	a4,a4,0x18
ffffffffc0200822:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200826:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020082a:	01e6e6b3          	or	a3,a3,t5
ffffffffc020082e:	00cb7633          	and	a2,s6,a2
ffffffffc0200832:	0088181b          	slliw	a6,a6,0x8
ffffffffc0200836:	0085959b          	slliw	a1,a1,0x8
ffffffffc020083a:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020083e:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200842:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200846:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020084a:	0088989b          	slliw	a7,a7,0x8
ffffffffc020084e:	011b78b3          	and	a7,s6,a7
ffffffffc0200852:	005eeeb3          	or	t4,t4,t0
ffffffffc0200856:	00c6e733          	or	a4,a3,a2
ffffffffc020085a:	006c6c33          	or	s8,s8,t1
ffffffffc020085e:	010b76b3          	and	a3,s6,a6
ffffffffc0200862:	00bb7b33          	and	s6,s6,a1
ffffffffc0200866:	01d7e7b3          	or	a5,a5,t4
ffffffffc020086a:	016c6b33          	or	s6,s8,s6
ffffffffc020086e:	01146433          	or	s0,s0,a7
ffffffffc0200872:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200874:	1702                	slli	a4,a4,0x20
ffffffffc0200876:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200878:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020087a:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020087c:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020087e:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200882:	0167eb33          	or	s6,a5,s6
ffffffffc0200886:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200888:	859ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc020088c:	85a2                	mv	a1,s0
ffffffffc020088e:	00005517          	auipc	a0,0x5
ffffffffc0200892:	52250513          	addi	a0,a0,1314 # ffffffffc0205db0 <commands+0xf8>
ffffffffc0200896:	84bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020089a:	014b5613          	srli	a2,s6,0x14
ffffffffc020089e:	85da                	mv	a1,s6
ffffffffc02008a0:	00005517          	auipc	a0,0x5
ffffffffc02008a4:	52850513          	addi	a0,a0,1320 # ffffffffc0205dc8 <commands+0x110>
ffffffffc02008a8:	839ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02008ac:	008b05b3          	add	a1,s6,s0
ffffffffc02008b0:	15fd                	addi	a1,a1,-1
ffffffffc02008b2:	00005517          	auipc	a0,0x5
ffffffffc02008b6:	53650513          	addi	a0,a0,1334 # ffffffffc0205de8 <commands+0x130>
ffffffffc02008ba:	827ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	57a50513          	addi	a0,a0,1402 # ffffffffc0205e38 <commands+0x180>
        memory_base = mem_base;
ffffffffc02008c6:	000b4797          	auipc	a5,0xb4
ffffffffc02008ca:	7c87bd23          	sd	s0,2010(a5) # ffffffffc02b50a0 <memory_base>
        memory_size = mem_size;
ffffffffc02008ce:	000b4797          	auipc	a5,0xb4
ffffffffc02008d2:	7d67bd23          	sd	s6,2010(a5) # ffffffffc02b50a8 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02008d6:	b3f5                	j	ffffffffc02006c2 <dtb_init+0x186>

ffffffffc02008d8 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02008d8:	000b4517          	auipc	a0,0xb4
ffffffffc02008dc:	7c853503          	ld	a0,1992(a0) # ffffffffc02b50a0 <memory_base>
ffffffffc02008e0:	8082                	ret

ffffffffc02008e2 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02008e2:	000b4517          	auipc	a0,0xb4
ffffffffc02008e6:	7c653503          	ld	a0,1990(a0) # ffffffffc02b50a8 <memory_size>
ffffffffc02008ea:	8082                	ret

ffffffffc02008ec <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02008ec:	67e1                	lui	a5,0x18
ffffffffc02008ee:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd578>
ffffffffc02008f2:	000b4717          	auipc	a4,0xb4
ffffffffc02008f6:	7cf73323          	sd	a5,1990(a4) # ffffffffc02b50b8 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02008fa:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02008fe:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200900:	953e                	add	a0,a0,a5
ffffffffc0200902:	4601                	li	a2,0
ffffffffc0200904:	4881                	li	a7,0
ffffffffc0200906:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020090a:	02000793          	li	a5,32
ffffffffc020090e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200912:	00005517          	auipc	a0,0x5
ffffffffc0200916:	53e50513          	addi	a0,a0,1342 # ffffffffc0205e50 <commands+0x198>
    ticks = 0;
ffffffffc020091a:	000b4797          	auipc	a5,0xb4
ffffffffc020091e:	7807bb23          	sd	zero,1942(a5) # ffffffffc02b50b0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200922:	fbeff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200926 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200926:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020092a:	000b4797          	auipc	a5,0xb4
ffffffffc020092e:	78e7b783          	ld	a5,1934(a5) # ffffffffc02b50b8 <timebase>
ffffffffc0200932:	953e                	add	a0,a0,a5
ffffffffc0200934:	4581                	li	a1,0
ffffffffc0200936:	4601                	li	a2,0
ffffffffc0200938:	4881                	li	a7,0
ffffffffc020093a:	00000073          	ecall
ffffffffc020093e:	8082                	ret

ffffffffc0200940 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200940:	8082                	ret

ffffffffc0200942 <cons_putc>:
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200942:	100027f3          	csrr	a5,sstatus
ffffffffc0200946:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200948:	0ff57513          	zext.b	a0,a0
ffffffffc020094c:	e799                	bnez	a5,ffffffffc020095a <cons_putc+0x18>
ffffffffc020094e:	4581                	li	a1,0
ffffffffc0200950:	4601                	li	a2,0
ffffffffc0200952:	4885                	li	a7,1
ffffffffc0200954:	00000073          	ecall
    return 0;
}

static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc0200958:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020095a:	1101                	addi	sp,sp,-32
ffffffffc020095c:	ec06                	sd	ra,24(sp)
ffffffffc020095e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200960:	05a000ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0200964:	6522                	ld	a0,8(sp)
ffffffffc0200966:	4581                	li	a1,0
ffffffffc0200968:	4601                	li	a2,0
ffffffffc020096a:	4885                	li	a7,1
ffffffffc020096c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200970:	60e2                	ld	ra,24(sp)
ffffffffc0200972:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc0200974:	a081                	j	ffffffffc02009b4 <intr_enable>

ffffffffc0200976 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200976:	100027f3          	csrr	a5,sstatus
ffffffffc020097a:	8b89                	andi	a5,a5,2
ffffffffc020097c:	eb89                	bnez	a5,ffffffffc020098e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020097e:	4501                	li	a0,0
ffffffffc0200980:	4581                	li	a1,0
ffffffffc0200982:	4601                	li	a2,0
ffffffffc0200984:	4889                	li	a7,2
ffffffffc0200986:	00000073          	ecall
ffffffffc020098a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020098c:	8082                	ret
int cons_getc(void) {
ffffffffc020098e:	1101                	addi	sp,sp,-32
ffffffffc0200990:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200992:	028000ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0200996:	4501                	li	a0,0
ffffffffc0200998:	4581                	li	a1,0
ffffffffc020099a:	4601                	li	a2,0
ffffffffc020099c:	4889                	li	a7,2
ffffffffc020099e:	00000073          	ecall
ffffffffc02009a2:	2501                	sext.w	a0,a0
ffffffffc02009a4:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02009a6:	00e000ef          	jal	ra,ffffffffc02009b4 <intr_enable>
}
ffffffffc02009aa:	60e2                	ld	ra,24(sp)
ffffffffc02009ac:	6522                	ld	a0,8(sp)
ffffffffc02009ae:	6105                	addi	sp,sp,32
ffffffffc02009b0:	8082                	ret

ffffffffc02009b2 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02009b2:	8082                	ret

ffffffffc02009b4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009b4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02009b8:	8082                	ret

ffffffffc02009ba <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009ba:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02009be:	8082                	ret

ffffffffc02009c0 <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc02009c0:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc02009c4:	00000797          	auipc	a5,0x0
ffffffffc02009c8:	51878793          	addi	a5,a5,1304 # ffffffffc0200edc <__alltraps>
ffffffffc02009cc:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc02009d0:	000407b7          	lui	a5,0x40
ffffffffc02009d4:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc02009d8:	8082                	ret

ffffffffc02009da <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009da:	610c                	ld	a1,0(a0)
{
ffffffffc02009dc:	1141                	addi	sp,sp,-16
ffffffffc02009de:	e022                	sd	s0,0(sp)
ffffffffc02009e0:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e2:	00005517          	auipc	a0,0x5
ffffffffc02009e6:	48e50513          	addi	a0,a0,1166 # ffffffffc0205e70 <commands+0x1b8>
{
ffffffffc02009ea:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009ec:	ef4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009f0:	640c                	ld	a1,8(s0)
ffffffffc02009f2:	00005517          	auipc	a0,0x5
ffffffffc02009f6:	49650513          	addi	a0,a0,1174 # ffffffffc0205e88 <commands+0x1d0>
ffffffffc02009fa:	ee6ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009fe:	680c                	ld	a1,16(s0)
ffffffffc0200a00:	00005517          	auipc	a0,0x5
ffffffffc0200a04:	4a050513          	addi	a0,a0,1184 # ffffffffc0205ea0 <commands+0x1e8>
ffffffffc0200a08:	ed8ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a0c:	6c0c                	ld	a1,24(s0)
ffffffffc0200a0e:	00005517          	auipc	a0,0x5
ffffffffc0200a12:	4aa50513          	addi	a0,a0,1194 # ffffffffc0205eb8 <commands+0x200>
ffffffffc0200a16:	ecaff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a1a:	700c                	ld	a1,32(s0)
ffffffffc0200a1c:	00005517          	auipc	a0,0x5
ffffffffc0200a20:	4b450513          	addi	a0,a0,1204 # ffffffffc0205ed0 <commands+0x218>
ffffffffc0200a24:	ebcff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a28:	740c                	ld	a1,40(s0)
ffffffffc0200a2a:	00005517          	auipc	a0,0x5
ffffffffc0200a2e:	4be50513          	addi	a0,a0,1214 # ffffffffc0205ee8 <commands+0x230>
ffffffffc0200a32:	eaeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a36:	780c                	ld	a1,48(s0)
ffffffffc0200a38:	00005517          	auipc	a0,0x5
ffffffffc0200a3c:	4c850513          	addi	a0,a0,1224 # ffffffffc0205f00 <commands+0x248>
ffffffffc0200a40:	ea0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a44:	7c0c                	ld	a1,56(s0)
ffffffffc0200a46:	00005517          	auipc	a0,0x5
ffffffffc0200a4a:	4d250513          	addi	a0,a0,1234 # ffffffffc0205f18 <commands+0x260>
ffffffffc0200a4e:	e92ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a52:	602c                	ld	a1,64(s0)
ffffffffc0200a54:	00005517          	auipc	a0,0x5
ffffffffc0200a58:	4dc50513          	addi	a0,a0,1244 # ffffffffc0205f30 <commands+0x278>
ffffffffc0200a5c:	e84ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a60:	642c                	ld	a1,72(s0)
ffffffffc0200a62:	00005517          	auipc	a0,0x5
ffffffffc0200a66:	4e650513          	addi	a0,a0,1254 # ffffffffc0205f48 <commands+0x290>
ffffffffc0200a6a:	e76ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a6e:	682c                	ld	a1,80(s0)
ffffffffc0200a70:	00005517          	auipc	a0,0x5
ffffffffc0200a74:	4f050513          	addi	a0,a0,1264 # ffffffffc0205f60 <commands+0x2a8>
ffffffffc0200a78:	e68ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a7c:	6c2c                	ld	a1,88(s0)
ffffffffc0200a7e:	00005517          	auipc	a0,0x5
ffffffffc0200a82:	4fa50513          	addi	a0,a0,1274 # ffffffffc0205f78 <commands+0x2c0>
ffffffffc0200a86:	e5aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a8a:	702c                	ld	a1,96(s0)
ffffffffc0200a8c:	00005517          	auipc	a0,0x5
ffffffffc0200a90:	50450513          	addi	a0,a0,1284 # ffffffffc0205f90 <commands+0x2d8>
ffffffffc0200a94:	e4cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a98:	742c                	ld	a1,104(s0)
ffffffffc0200a9a:	00005517          	auipc	a0,0x5
ffffffffc0200a9e:	50e50513          	addi	a0,a0,1294 # ffffffffc0205fa8 <commands+0x2f0>
ffffffffc0200aa2:	e3eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200aa6:	782c                	ld	a1,112(s0)
ffffffffc0200aa8:	00005517          	auipc	a0,0x5
ffffffffc0200aac:	51850513          	addi	a0,a0,1304 # ffffffffc0205fc0 <commands+0x308>
ffffffffc0200ab0:	e30ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200ab4:	7c2c                	ld	a1,120(s0)
ffffffffc0200ab6:	00005517          	auipc	a0,0x5
ffffffffc0200aba:	52250513          	addi	a0,a0,1314 # ffffffffc0205fd8 <commands+0x320>
ffffffffc0200abe:	e22ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200ac2:	604c                	ld	a1,128(s0)
ffffffffc0200ac4:	00005517          	auipc	a0,0x5
ffffffffc0200ac8:	52c50513          	addi	a0,a0,1324 # ffffffffc0205ff0 <commands+0x338>
ffffffffc0200acc:	e14ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200ad0:	644c                	ld	a1,136(s0)
ffffffffc0200ad2:	00005517          	auipc	a0,0x5
ffffffffc0200ad6:	53650513          	addi	a0,a0,1334 # ffffffffc0206008 <commands+0x350>
ffffffffc0200ada:	e06ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ade:	684c                	ld	a1,144(s0)
ffffffffc0200ae0:	00005517          	auipc	a0,0x5
ffffffffc0200ae4:	54050513          	addi	a0,a0,1344 # ffffffffc0206020 <commands+0x368>
ffffffffc0200ae8:	df8ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200aec:	6c4c                	ld	a1,152(s0)
ffffffffc0200aee:	00005517          	auipc	a0,0x5
ffffffffc0200af2:	54a50513          	addi	a0,a0,1354 # ffffffffc0206038 <commands+0x380>
ffffffffc0200af6:	deaff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200afa:	704c                	ld	a1,160(s0)
ffffffffc0200afc:	00005517          	auipc	a0,0x5
ffffffffc0200b00:	55450513          	addi	a0,a0,1364 # ffffffffc0206050 <commands+0x398>
ffffffffc0200b04:	ddcff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200b08:	744c                	ld	a1,168(s0)
ffffffffc0200b0a:	00005517          	auipc	a0,0x5
ffffffffc0200b0e:	55e50513          	addi	a0,a0,1374 # ffffffffc0206068 <commands+0x3b0>
ffffffffc0200b12:	dceff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b16:	784c                	ld	a1,176(s0)
ffffffffc0200b18:	00005517          	auipc	a0,0x5
ffffffffc0200b1c:	56850513          	addi	a0,a0,1384 # ffffffffc0206080 <commands+0x3c8>
ffffffffc0200b20:	dc0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b24:	7c4c                	ld	a1,184(s0)
ffffffffc0200b26:	00005517          	auipc	a0,0x5
ffffffffc0200b2a:	57250513          	addi	a0,a0,1394 # ffffffffc0206098 <commands+0x3e0>
ffffffffc0200b2e:	db2ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b32:	606c                	ld	a1,192(s0)
ffffffffc0200b34:	00005517          	auipc	a0,0x5
ffffffffc0200b38:	57c50513          	addi	a0,a0,1404 # ffffffffc02060b0 <commands+0x3f8>
ffffffffc0200b3c:	da4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b40:	646c                	ld	a1,200(s0)
ffffffffc0200b42:	00005517          	auipc	a0,0x5
ffffffffc0200b46:	58650513          	addi	a0,a0,1414 # ffffffffc02060c8 <commands+0x410>
ffffffffc0200b4a:	d96ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b4e:	686c                	ld	a1,208(s0)
ffffffffc0200b50:	00005517          	auipc	a0,0x5
ffffffffc0200b54:	59050513          	addi	a0,a0,1424 # ffffffffc02060e0 <commands+0x428>
ffffffffc0200b58:	d88ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b5c:	6c6c                	ld	a1,216(s0)
ffffffffc0200b5e:	00005517          	auipc	a0,0x5
ffffffffc0200b62:	59a50513          	addi	a0,a0,1434 # ffffffffc02060f8 <commands+0x440>
ffffffffc0200b66:	d7aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b6a:	706c                	ld	a1,224(s0)
ffffffffc0200b6c:	00005517          	auipc	a0,0x5
ffffffffc0200b70:	5a450513          	addi	a0,a0,1444 # ffffffffc0206110 <commands+0x458>
ffffffffc0200b74:	d6cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b78:	746c                	ld	a1,232(s0)
ffffffffc0200b7a:	00005517          	auipc	a0,0x5
ffffffffc0200b7e:	5ae50513          	addi	a0,a0,1454 # ffffffffc0206128 <commands+0x470>
ffffffffc0200b82:	d5eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b86:	786c                	ld	a1,240(s0)
ffffffffc0200b88:	00005517          	auipc	a0,0x5
ffffffffc0200b8c:	5b850513          	addi	a0,a0,1464 # ffffffffc0206140 <commands+0x488>
ffffffffc0200b90:	d50ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b94:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b96:	6402                	ld	s0,0(sp)
ffffffffc0200b98:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b9a:	00005517          	auipc	a0,0x5
ffffffffc0200b9e:	5be50513          	addi	a0,a0,1470 # ffffffffc0206158 <commands+0x4a0>
}
ffffffffc0200ba2:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ba4:	d3cff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200ba8 <print_trapframe>:
{
ffffffffc0200ba8:	1141                	addi	sp,sp,-16
ffffffffc0200baa:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bac:	85aa                	mv	a1,a0
{
ffffffffc0200bae:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bb0:	00005517          	auipc	a0,0x5
ffffffffc0200bb4:	5c050513          	addi	a0,a0,1472 # ffffffffc0206170 <commands+0x4b8>
{
ffffffffc0200bb8:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bba:	d26ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200bbe:	8522                	mv	a0,s0
ffffffffc0200bc0:	e1bff0ef          	jal	ra,ffffffffc02009da <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200bc4:	10043583          	ld	a1,256(s0)
ffffffffc0200bc8:	00005517          	auipc	a0,0x5
ffffffffc0200bcc:	5c050513          	addi	a0,a0,1472 # ffffffffc0206188 <commands+0x4d0>
ffffffffc0200bd0:	d10ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bd4:	10843583          	ld	a1,264(s0)
ffffffffc0200bd8:	00005517          	auipc	a0,0x5
ffffffffc0200bdc:	5c850513          	addi	a0,a0,1480 # ffffffffc02061a0 <commands+0x4e8>
ffffffffc0200be0:	d00ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200be4:	11043583          	ld	a1,272(s0)
ffffffffc0200be8:	00005517          	auipc	a0,0x5
ffffffffc0200bec:	5d050513          	addi	a0,a0,1488 # ffffffffc02061b8 <commands+0x500>
ffffffffc0200bf0:	cf0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf4:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bf8:	6402                	ld	s0,0(sp)
ffffffffc0200bfa:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bfc:	00005517          	auipc	a0,0x5
ffffffffc0200c00:	5cc50513          	addi	a0,a0,1484 # ffffffffc02061c8 <commands+0x510>
}
ffffffffc0200c04:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200c06:	cdaff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200c0a <interrupt_handler>:

extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200c0a:	11853783          	ld	a5,280(a0)
ffffffffc0200c0e:	472d                	li	a4,11
ffffffffc0200c10:	0786                	slli	a5,a5,0x1
ffffffffc0200c12:	8385                	srli	a5,a5,0x1
ffffffffc0200c14:	06f76c63          	bltu	a4,a5,ffffffffc0200c8c <interrupt_handler+0x82>
ffffffffc0200c18:	00005717          	auipc	a4,0x5
ffffffffc0200c1c:	67870713          	addi	a4,a4,1656 # ffffffffc0206290 <commands+0x5d8>
ffffffffc0200c20:	078a                	slli	a5,a5,0x2
ffffffffc0200c22:	97ba                	add	a5,a5,a4
ffffffffc0200c24:	439c                	lw	a5,0(a5)
ffffffffc0200c26:	97ba                	add	a5,a5,a4
ffffffffc0200c28:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200c2a:	00005517          	auipc	a0,0x5
ffffffffc0200c2e:	61650513          	addi	a0,a0,1558 # ffffffffc0206240 <commands+0x588>
ffffffffc0200c32:	caeff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c36:	00005517          	auipc	a0,0x5
ffffffffc0200c3a:	5ea50513          	addi	a0,a0,1514 # ffffffffc0206220 <commands+0x568>
ffffffffc0200c3e:	ca2ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c42:	00005517          	auipc	a0,0x5
ffffffffc0200c46:	59e50513          	addi	a0,a0,1438 # ffffffffc02061e0 <commands+0x528>
ffffffffc0200c4a:	c96ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c4e:	00005517          	auipc	a0,0x5
ffffffffc0200c52:	5b250513          	addi	a0,a0,1458 # ffffffffc0206200 <commands+0x548>
ffffffffc0200c56:	c8aff06f          	j	ffffffffc02000e0 <cprintf>
{
ffffffffc0200c5a:	1141                	addi	sp,sp,-16
ffffffffc0200c5c:	e406                	sd	ra,8(sp)
        /*(1)设置下次时钟中断- clock_set_next_event()
         *(2)计数器（ticks）加一
         *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
         * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
         */
        clock_set_next_event();
ffffffffc0200c5e:	cc9ff0ef          	jal	ra,ffffffffc0200926 <clock_set_next_event>
        if (++ticks % TICK_NUM == 0) {
ffffffffc0200c62:	000b4697          	auipc	a3,0xb4
ffffffffc0200c66:	44e68693          	addi	a3,a3,1102 # ffffffffc02b50b0 <ticks>
ffffffffc0200c6a:	629c                	ld	a5,0(a3)
ffffffffc0200c6c:	06400713          	li	a4,100
ffffffffc0200c70:	0785                	addi	a5,a5,1
ffffffffc0200c72:	02e7f733          	remu	a4,a5,a4
ffffffffc0200c76:	e29c                	sd	a5,0(a3)
ffffffffc0200c78:	cb19                	beqz	a4,ffffffffc0200c8e <interrupt_handler+0x84>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c7a:	60a2                	ld	ra,8(sp)
ffffffffc0200c7c:	0141                	addi	sp,sp,16
ffffffffc0200c7e:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c80:	00005517          	auipc	a0,0x5
ffffffffc0200c84:	5f050513          	addi	a0,a0,1520 # ffffffffc0206270 <commands+0x5b8>
ffffffffc0200c88:	c58ff06f          	j	ffffffffc02000e0 <cprintf>
        print_trapframe(tf);
ffffffffc0200c8c:	bf31                	j	ffffffffc0200ba8 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c8e:	06400593          	li	a1,100
ffffffffc0200c92:	00005517          	auipc	a0,0x5
ffffffffc0200c96:	5ce50513          	addi	a0,a0,1486 # ffffffffc0206260 <commands+0x5a8>
ffffffffc0200c9a:	c46ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
            if (current) {
ffffffffc0200c9e:	000b4797          	auipc	a5,0xb4
ffffffffc0200ca2:	46a7b783          	ld	a5,1130(a5) # ffffffffc02b5108 <current>
ffffffffc0200ca6:	c399                	beqz	a5,ffffffffc0200cac <interrupt_handler+0xa2>
                current->need_resched = 1;
ffffffffc0200ca8:	4705                	li	a4,1
ffffffffc0200caa:	ef98                	sd	a4,24(a5)
            print_num++;
ffffffffc0200cac:	000b4717          	auipc	a4,0xb4
ffffffffc0200cb0:	41470713          	addi	a4,a4,1044 # ffffffffc02b50c0 <print_num.0>
ffffffffc0200cb4:	431c                	lw	a5,0(a4)
            if (print_num == 10) {
ffffffffc0200cb6:	46a9                	li	a3,10
            print_num++;
ffffffffc0200cb8:	0017861b          	addiw	a2,a5,1
ffffffffc0200cbc:	c310                	sw	a2,0(a4)
            if (print_num == 10) {
ffffffffc0200cbe:	fad61ee3          	bne	a2,a3,ffffffffc0200c7a <interrupt_handler+0x70>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200cc2:	4501                	li	a0,0
ffffffffc0200cc4:	4581                	li	a1,0
ffffffffc0200cc6:	4601                	li	a2,0
ffffffffc0200cc8:	48a1                	li	a7,8
ffffffffc0200cca:	00000073          	ecall
}
ffffffffc0200cce:	b775                	j	ffffffffc0200c7a <interrupt_handler+0x70>

ffffffffc0200cd0 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200cd0:	11853783          	ld	a5,280(a0)
{
ffffffffc0200cd4:	1141                	addi	sp,sp,-16
ffffffffc0200cd6:	e022                	sd	s0,0(sp)
ffffffffc0200cd8:	e406                	sd	ra,8(sp)
ffffffffc0200cda:	473d                	li	a4,15
ffffffffc0200cdc:	842a                	mv	s0,a0
ffffffffc0200cde:	12f76663          	bltu	a4,a5,ffffffffc0200e0a <exception_handler+0x13a>
ffffffffc0200ce2:	00005717          	auipc	a4,0x5
ffffffffc0200ce6:	76e70713          	addi	a4,a4,1902 # ffffffffc0206450 <commands+0x798>
ffffffffc0200cea:	078a                	slli	a5,a5,0x2
ffffffffc0200cec:	97ba                	add	a5,a5,a4
ffffffffc0200cee:	439c                	lw	a5,0(a5)
ffffffffc0200cf0:	97ba                	add	a5,a5,a4
ffffffffc0200cf2:	8782                	jr	a5
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200cf4:	00005517          	auipc	a0,0x5
ffffffffc0200cf8:	6b450513          	addi	a0,a0,1716 # ffffffffc02063a8 <commands+0x6f0>
ffffffffc0200cfc:	be4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        tf->epc += 4;
ffffffffc0200d00:	10843783          	ld	a5,264(s0)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200d04:	60a2                	ld	ra,8(sp)
        tf->epc += 4;
ffffffffc0200d06:	0791                	addi	a5,a5,4
ffffffffc0200d08:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d0c:	6402                	ld	s0,0(sp)
ffffffffc0200d0e:	0141                	addi	sp,sp,16
        syscall();
ffffffffc0200d10:	7ac0406f          	j	ffffffffc02054bc <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d14:	00005517          	auipc	a0,0x5
ffffffffc0200d18:	6b450513          	addi	a0,a0,1716 # ffffffffc02063c8 <commands+0x710>
}
ffffffffc0200d1c:	6402                	ld	s0,0(sp)
ffffffffc0200d1e:	60a2                	ld	ra,8(sp)
ffffffffc0200d20:	0141                	addi	sp,sp,16
        cprintf("Instruction access fault\n");
ffffffffc0200d22:	bbeff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d26:	00005517          	auipc	a0,0x5
ffffffffc0200d2a:	6c250513          	addi	a0,a0,1730 # ffffffffc02063e8 <commands+0x730>
ffffffffc0200d2e:	b7fd                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Instruction page fault\n");
ffffffffc0200d30:	00005517          	auipc	a0,0x5
ffffffffc0200d34:	6d850513          	addi	a0,a0,1752 # ffffffffc0206408 <commands+0x750>
ffffffffc0200d38:	ba8ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        if ((tf->status & SSTATUS_SPP) == 0) {
ffffffffc0200d3c:	10043783          	ld	a5,256(s0)
ffffffffc0200d40:	1007f793          	andi	a5,a5,256
ffffffffc0200d44:	e3c5                	bnez	a5,ffffffffc0200de4 <exception_handler+0x114>
            do_pgfault(current->mm, CAUSE_FETCH_PAGE_FAULT, tf->tval);
ffffffffc0200d46:	000b4797          	auipc	a5,0xb4
ffffffffc0200d4a:	3c27b783          	ld	a5,962(a5) # ffffffffc02b5108 <current>
ffffffffc0200d4e:	11043603          	ld	a2,272(s0)
ffffffffc0200d52:	7788                	ld	a0,40(a5)
ffffffffc0200d54:	45b1                	li	a1,12
ffffffffc0200d56:	a025                	j	ffffffffc0200d7e <exception_handler+0xae>
        cprintf("Load page fault\n");
ffffffffc0200d58:	00005517          	auipc	a0,0x5
ffffffffc0200d5c:	6c850513          	addi	a0,a0,1736 # ffffffffc0206420 <commands+0x768>
ffffffffc0200d60:	b80ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        if ((tf->status & SSTATUS_SPP) == 0) {
ffffffffc0200d64:	10043783          	ld	a5,256(s0)
ffffffffc0200d68:	1007f793          	andi	a5,a5,256
ffffffffc0200d6c:	efa5                	bnez	a5,ffffffffc0200de4 <exception_handler+0x114>
            do_pgfault(current->mm, CAUSE_LOAD_PAGE_FAULT, tf->tval);
ffffffffc0200d6e:	000b4797          	auipc	a5,0xb4
ffffffffc0200d72:	39a7b783          	ld	a5,922(a5) # ffffffffc02b5108 <current>
ffffffffc0200d76:	11043603          	ld	a2,272(s0)
ffffffffc0200d7a:	7788                	ld	a0,40(a5)
ffffffffc0200d7c:	45b5                	li	a1,13
}
ffffffffc0200d7e:	6402                	ld	s0,0(sp)
ffffffffc0200d80:	60a2                	ld	ra,8(sp)
ffffffffc0200d82:	0141                	addi	sp,sp,16
            do_pgfault(current->mm, CAUSE_LOAD_PAGE_FAULT, tf->tval);
ffffffffc0200d84:	5cd0106f          	j	ffffffffc0202b50 <do_pgfault>
        if ((tf->status & SSTATUS_SPP) == 0) {
ffffffffc0200d88:	10053783          	ld	a5,256(a0)
ffffffffc0200d8c:	1007f793          	andi	a5,a5,256
ffffffffc0200d90:	ef81                	bnez	a5,ffffffffc0200da8 <exception_handler+0xd8>
            if (do_pgfault(current->mm, CAUSE_STORE_PAGE_FAULT, tf->tval) != 0) {
ffffffffc0200d92:	000b4797          	auipc	a5,0xb4
ffffffffc0200d96:	3767b783          	ld	a5,886(a5) # ffffffffc02b5108 <current>
ffffffffc0200d9a:	11053603          	ld	a2,272(a0)
ffffffffc0200d9e:	7788                	ld	a0,40(a5)
ffffffffc0200da0:	45bd                	li	a1,15
ffffffffc0200da2:	5af010ef          	jal	ra,ffffffffc0202b50 <do_pgfault>
ffffffffc0200da6:	cd1d                	beqz	a0,ffffffffc0200de4 <exception_handler+0x114>
                cprintf("Store/AMO page fault\n");
ffffffffc0200da8:	00005517          	auipc	a0,0x5
ffffffffc0200dac:	69050513          	addi	a0,a0,1680 # ffffffffc0206438 <commands+0x780>
ffffffffc0200db0:	b7b5                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Instruction address misaligned\n");
ffffffffc0200db2:	00005517          	auipc	a0,0x5
ffffffffc0200db6:	50e50513          	addi	a0,a0,1294 # ffffffffc02062c0 <commands+0x608>
ffffffffc0200dba:	b78d                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Instruction access fault\n");
ffffffffc0200dbc:	00005517          	auipc	a0,0x5
ffffffffc0200dc0:	52450513          	addi	a0,a0,1316 # ffffffffc02062e0 <commands+0x628>
ffffffffc0200dc4:	bfa1                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Illegal instruction\n");
ffffffffc0200dc6:	00005517          	auipc	a0,0x5
ffffffffc0200dca:	53a50513          	addi	a0,a0,1338 # ffffffffc0206300 <commands+0x648>
ffffffffc0200dce:	b7b9                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Breakpoint\n");
ffffffffc0200dd0:	00005517          	auipc	a0,0x5
ffffffffc0200dd4:	54850513          	addi	a0,a0,1352 # ffffffffc0206318 <commands+0x660>
ffffffffc0200dd8:	b08ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200ddc:	6458                	ld	a4,136(s0)
ffffffffc0200dde:	47a9                	li	a5,10
ffffffffc0200de0:	04f70663          	beq	a4,a5,ffffffffc0200e2c <exception_handler+0x15c>
}
ffffffffc0200de4:	60a2                	ld	ra,8(sp)
ffffffffc0200de6:	6402                	ld	s0,0(sp)
ffffffffc0200de8:	0141                	addi	sp,sp,16
ffffffffc0200dea:	8082                	ret
        cprintf("Load address misaligned\n");
ffffffffc0200dec:	00005517          	auipc	a0,0x5
ffffffffc0200df0:	53c50513          	addi	a0,a0,1340 # ffffffffc0206328 <commands+0x670>
ffffffffc0200df4:	b725                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Load access fault\n");
ffffffffc0200df6:	00005517          	auipc	a0,0x5
ffffffffc0200dfa:	55250513          	addi	a0,a0,1362 # ffffffffc0206348 <commands+0x690>
ffffffffc0200dfe:	bf39                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Store/AMO access fault\n");
ffffffffc0200e00:	00005517          	auipc	a0,0x5
ffffffffc0200e04:	59050513          	addi	a0,a0,1424 # ffffffffc0206390 <commands+0x6d8>
ffffffffc0200e08:	bf11                	j	ffffffffc0200d1c <exception_handler+0x4c>
        print_trapframe(tf);
ffffffffc0200e0a:	8522                	mv	a0,s0
}
ffffffffc0200e0c:	6402                	ld	s0,0(sp)
ffffffffc0200e0e:	60a2                	ld	ra,8(sp)
ffffffffc0200e10:	0141                	addi	sp,sp,16
        print_trapframe(tf);
ffffffffc0200e12:	bb59                	j	ffffffffc0200ba8 <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200e14:	00005617          	auipc	a2,0x5
ffffffffc0200e18:	54c60613          	addi	a2,a2,1356 # ffffffffc0206360 <commands+0x6a8>
ffffffffc0200e1c:	0c500593          	li	a1,197
ffffffffc0200e20:	00005517          	auipc	a0,0x5
ffffffffc0200e24:	55850513          	addi	a0,a0,1368 # ffffffffc0206378 <commands+0x6c0>
ffffffffc0200e28:	bf6ff0ef          	jal	ra,ffffffffc020021e <__panic>
            tf->epc += 4;
ffffffffc0200e2c:	10843783          	ld	a5,264(s0)
ffffffffc0200e30:	0791                	addi	a5,a5,4
ffffffffc0200e32:	10f43423          	sd	a5,264(s0)
            syscall();
ffffffffc0200e36:	686040ef          	jal	ra,ffffffffc02054bc <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e3a:	000b4797          	auipc	a5,0xb4
ffffffffc0200e3e:	2ce7b783          	ld	a5,718(a5) # ffffffffc02b5108 <current>
ffffffffc0200e42:	6b9c                	ld	a5,16(a5)
ffffffffc0200e44:	8522                	mv	a0,s0
}
ffffffffc0200e46:	6402                	ld	s0,0(sp)
ffffffffc0200e48:	60a2                	ld	ra,8(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e4a:	6589                	lui	a1,0x2
ffffffffc0200e4c:	95be                	add	a1,a1,a5
}
ffffffffc0200e4e:	0141                	addi	sp,sp,16
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e50:	aaa9                	j	ffffffffc0200faa <kernel_execve_ret>

ffffffffc0200e52 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
ffffffffc0200e52:	1101                	addi	sp,sp,-32
ffffffffc0200e54:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200e56:	000b4417          	auipc	s0,0xb4
ffffffffc0200e5a:	2b240413          	addi	s0,s0,690 # ffffffffc02b5108 <current>
ffffffffc0200e5e:	6018                	ld	a4,0(s0)
{
ffffffffc0200e60:	ec06                	sd	ra,24(sp)
ffffffffc0200e62:	e426                	sd	s1,8(sp)
ffffffffc0200e64:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e66:	11853683          	ld	a3,280(a0)
    if (current == NULL)
ffffffffc0200e6a:	cf1d                	beqz	a4,ffffffffc0200ea8 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e6c:	10053483          	ld	s1,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200e70:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200e74:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e76:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e7a:	0206c463          	bltz	a3,ffffffffc0200ea2 <trap+0x50>
        exception_handler(tf);
ffffffffc0200e7e:	e53ff0ef          	jal	ra,ffffffffc0200cd0 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200e82:	601c                	ld	a5,0(s0)
ffffffffc0200e84:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel)
ffffffffc0200e88:	e499                	bnez	s1,ffffffffc0200e96 <trap+0x44>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200e8a:	0b07a703          	lw	a4,176(a5)
ffffffffc0200e8e:	8b05                	andi	a4,a4,1
ffffffffc0200e90:	e329                	bnez	a4,ffffffffc0200ed2 <trap+0x80>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200e92:	6f9c                	ld	a5,24(a5)
ffffffffc0200e94:	eb85                	bnez	a5,ffffffffc0200ec4 <trap+0x72>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200e96:	60e2                	ld	ra,24(sp)
ffffffffc0200e98:	6442                	ld	s0,16(sp)
ffffffffc0200e9a:	64a2                	ld	s1,8(sp)
ffffffffc0200e9c:	6902                	ld	s2,0(sp)
ffffffffc0200e9e:	6105                	addi	sp,sp,32
ffffffffc0200ea0:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200ea2:	d69ff0ef          	jal	ra,ffffffffc0200c0a <interrupt_handler>
ffffffffc0200ea6:	bff1                	j	ffffffffc0200e82 <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200ea8:	0006c863          	bltz	a3,ffffffffc0200eb8 <trap+0x66>
}
ffffffffc0200eac:	6442                	ld	s0,16(sp)
ffffffffc0200eae:	60e2                	ld	ra,24(sp)
ffffffffc0200eb0:	64a2                	ld	s1,8(sp)
ffffffffc0200eb2:	6902                	ld	s2,0(sp)
ffffffffc0200eb4:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200eb6:	bd29                	j	ffffffffc0200cd0 <exception_handler>
}
ffffffffc0200eb8:	6442                	ld	s0,16(sp)
ffffffffc0200eba:	60e2                	ld	ra,24(sp)
ffffffffc0200ebc:	64a2                	ld	s1,8(sp)
ffffffffc0200ebe:	6902                	ld	s2,0(sp)
ffffffffc0200ec0:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200ec2:	b3a1                	j	ffffffffc0200c0a <interrupt_handler>
}
ffffffffc0200ec4:	6442                	ld	s0,16(sp)
ffffffffc0200ec6:	60e2                	ld	ra,24(sp)
ffffffffc0200ec8:	64a2                	ld	s1,8(sp)
ffffffffc0200eca:	6902                	ld	s2,0(sp)
ffffffffc0200ecc:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200ece:	5020406f          	j	ffffffffc02053d0 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ed2:	555d                	li	a0,-9
ffffffffc0200ed4:	0ad030ef          	jal	ra,ffffffffc0204780 <do_exit>
            if (current->need_resched)
ffffffffc0200ed8:	601c                	ld	a5,0(s0)
ffffffffc0200eda:	bf65                	j	ffffffffc0200e92 <trap+0x40>

ffffffffc0200edc <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200edc:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ee0:	00011463          	bnez	sp,ffffffffc0200ee8 <__alltraps+0xc>
ffffffffc0200ee4:	14002173          	csrr	sp,sscratch
ffffffffc0200ee8:	712d                	addi	sp,sp,-288
ffffffffc0200eea:	e002                	sd	zero,0(sp)
ffffffffc0200eec:	e406                	sd	ra,8(sp)
ffffffffc0200eee:	ec0e                	sd	gp,24(sp)
ffffffffc0200ef0:	f012                	sd	tp,32(sp)
ffffffffc0200ef2:	f416                	sd	t0,40(sp)
ffffffffc0200ef4:	f81a                	sd	t1,48(sp)
ffffffffc0200ef6:	fc1e                	sd	t2,56(sp)
ffffffffc0200ef8:	e0a2                	sd	s0,64(sp)
ffffffffc0200efa:	e4a6                	sd	s1,72(sp)
ffffffffc0200efc:	e8aa                	sd	a0,80(sp)
ffffffffc0200efe:	ecae                	sd	a1,88(sp)
ffffffffc0200f00:	f0b2                	sd	a2,96(sp)
ffffffffc0200f02:	f4b6                	sd	a3,104(sp)
ffffffffc0200f04:	f8ba                	sd	a4,112(sp)
ffffffffc0200f06:	fcbe                	sd	a5,120(sp)
ffffffffc0200f08:	e142                	sd	a6,128(sp)
ffffffffc0200f0a:	e546                	sd	a7,136(sp)
ffffffffc0200f0c:	e94a                	sd	s2,144(sp)
ffffffffc0200f0e:	ed4e                	sd	s3,152(sp)
ffffffffc0200f10:	f152                	sd	s4,160(sp)
ffffffffc0200f12:	f556                	sd	s5,168(sp)
ffffffffc0200f14:	f95a                	sd	s6,176(sp)
ffffffffc0200f16:	fd5e                	sd	s7,184(sp)
ffffffffc0200f18:	e1e2                	sd	s8,192(sp)
ffffffffc0200f1a:	e5e6                	sd	s9,200(sp)
ffffffffc0200f1c:	e9ea                	sd	s10,208(sp)
ffffffffc0200f1e:	edee                	sd	s11,216(sp)
ffffffffc0200f20:	f1f2                	sd	t3,224(sp)
ffffffffc0200f22:	f5f6                	sd	t4,232(sp)
ffffffffc0200f24:	f9fa                	sd	t5,240(sp)
ffffffffc0200f26:	fdfe                	sd	t6,248(sp)
ffffffffc0200f28:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200f2c:	100024f3          	csrr	s1,sstatus
ffffffffc0200f30:	14102973          	csrr	s2,sepc
ffffffffc0200f34:	143029f3          	csrr	s3,stval
ffffffffc0200f38:	14202a73          	csrr	s4,scause
ffffffffc0200f3c:	e822                	sd	s0,16(sp)
ffffffffc0200f3e:	e226                	sd	s1,256(sp)
ffffffffc0200f40:	e64a                	sd	s2,264(sp)
ffffffffc0200f42:	ea4e                	sd	s3,272(sp)
ffffffffc0200f44:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200f46:	850a                	mv	a0,sp
    jal trap
ffffffffc0200f48:	f0bff0ef          	jal	ra,ffffffffc0200e52 <trap>

ffffffffc0200f4c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200f4c:	6492                	ld	s1,256(sp)
ffffffffc0200f4e:	6932                	ld	s2,264(sp)
ffffffffc0200f50:	1004f413          	andi	s0,s1,256
ffffffffc0200f54:	e401                	bnez	s0,ffffffffc0200f5c <__trapret+0x10>
ffffffffc0200f56:	1200                	addi	s0,sp,288
ffffffffc0200f58:	14041073          	csrw	sscratch,s0
ffffffffc0200f5c:	10049073          	csrw	sstatus,s1
ffffffffc0200f60:	14191073          	csrw	sepc,s2
ffffffffc0200f64:	60a2                	ld	ra,8(sp)
ffffffffc0200f66:	61e2                	ld	gp,24(sp)
ffffffffc0200f68:	7202                	ld	tp,32(sp)
ffffffffc0200f6a:	72a2                	ld	t0,40(sp)
ffffffffc0200f6c:	7342                	ld	t1,48(sp)
ffffffffc0200f6e:	73e2                	ld	t2,56(sp)
ffffffffc0200f70:	6406                	ld	s0,64(sp)
ffffffffc0200f72:	64a6                	ld	s1,72(sp)
ffffffffc0200f74:	6546                	ld	a0,80(sp)
ffffffffc0200f76:	65e6                	ld	a1,88(sp)
ffffffffc0200f78:	7606                	ld	a2,96(sp)
ffffffffc0200f7a:	76a6                	ld	a3,104(sp)
ffffffffc0200f7c:	7746                	ld	a4,112(sp)
ffffffffc0200f7e:	77e6                	ld	a5,120(sp)
ffffffffc0200f80:	680a                	ld	a6,128(sp)
ffffffffc0200f82:	68aa                	ld	a7,136(sp)
ffffffffc0200f84:	694a                	ld	s2,144(sp)
ffffffffc0200f86:	69ea                	ld	s3,152(sp)
ffffffffc0200f88:	7a0a                	ld	s4,160(sp)
ffffffffc0200f8a:	7aaa                	ld	s5,168(sp)
ffffffffc0200f8c:	7b4a                	ld	s6,176(sp)
ffffffffc0200f8e:	7bea                	ld	s7,184(sp)
ffffffffc0200f90:	6c0e                	ld	s8,192(sp)
ffffffffc0200f92:	6cae                	ld	s9,200(sp)
ffffffffc0200f94:	6d4e                	ld	s10,208(sp)
ffffffffc0200f96:	6dee                	ld	s11,216(sp)
ffffffffc0200f98:	7e0e                	ld	t3,224(sp)
ffffffffc0200f9a:	7eae                	ld	t4,232(sp)
ffffffffc0200f9c:	7f4e                	ld	t5,240(sp)
ffffffffc0200f9e:	7fee                	ld	t6,248(sp)
ffffffffc0200fa0:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200fa2:	10200073          	sret

ffffffffc0200fa6 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200fa6:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200fa8:	b755                	j	ffffffffc0200f4c <__trapret>

ffffffffc0200faa <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200faa:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200fae:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200fb2:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200fb6:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200fba:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200fbe:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200fc2:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200fc6:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200fca:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200fce:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200fd0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200fd2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200fd4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200fd6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200fd8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200fda:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200fdc:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200fde:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200fe0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200fe2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200fe4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200fe6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200fe8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200fea:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200fec:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200fee:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200ff0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200ff2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200ff4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200ff6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200ff8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200ffa:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200ffc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200ffe:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0201000:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0201002:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0201004:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0201006:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0201008:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc020100a:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc020100c:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc020100e:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0201010:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0201012:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0201014:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0201016:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0201018:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc020101a:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc020101c:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc020101e:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0201020:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0201022:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0201024:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0201026:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0201028:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc020102a:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc020102c:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc020102e:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0201030:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0201032:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0201034:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0201036:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0201038:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc020103a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc020103c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc020103e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0201040:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0201042:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0201044:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0201046:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0201048:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc020104a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc020104c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc020104e:	812e                	mv	sp,a1
ffffffffc0201050:	bdf5                	j	ffffffffc0200f4c <__trapret>

ffffffffc0201052 <pa2page.part.0>:
{
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa)
ffffffffc0201052:	1141                	addi	sp,sp,-16
{
    if (PPN(pa) >= npage)
    {
        panic("pa2page called with invalid pa");
ffffffffc0201054:	00005617          	auipc	a2,0x5
ffffffffc0201058:	43c60613          	addi	a2,a2,1084 # ffffffffc0206490 <commands+0x7d8>
ffffffffc020105c:	06900593          	li	a1,105
ffffffffc0201060:	00005517          	auipc	a0,0x5
ffffffffc0201064:	45050513          	addi	a0,a0,1104 # ffffffffc02064b0 <commands+0x7f8>
pa2page(uintptr_t pa)
ffffffffc0201068:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020106a:	9b4ff0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020106e <pte2page.part.0>:
{
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte)
ffffffffc020106e:	1141                	addi	sp,sp,-16
{
    if (!(pte & PTE_V))
    {
        panic("pte2page called with invalid pte");
ffffffffc0201070:	00005617          	auipc	a2,0x5
ffffffffc0201074:	45060613          	addi	a2,a2,1104 # ffffffffc02064c0 <commands+0x808>
ffffffffc0201078:	07f00593          	li	a1,127
ffffffffc020107c:	00005517          	auipc	a0,0x5
ffffffffc0201080:	43450513          	addi	a0,a0,1076 # ffffffffc02064b0 <commands+0x7f8>
pte2page(pte_t pte)
ffffffffc0201084:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201086:	998ff0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020108a <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020108a:	100027f3          	csrr	a5,sstatus
ffffffffc020108e:	8b89                	andi	a5,a5,2
ffffffffc0201090:	e799                	bnez	a5,ffffffffc020109e <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201092:	000b4797          	auipc	a5,0xb4
ffffffffc0201096:	0567b783          	ld	a5,86(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc020109a:	6f9c                	ld	a5,24(a5)
ffffffffc020109c:	8782                	jr	a5
{
ffffffffc020109e:	1141                	addi	sp,sp,-16
ffffffffc02010a0:	e406                	sd	ra,8(sp)
ffffffffc02010a2:	e022                	sd	s0,0(sp)
ffffffffc02010a4:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02010a6:	915ff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02010aa:	000b4797          	auipc	a5,0xb4
ffffffffc02010ae:	03e7b783          	ld	a5,62(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc02010b2:	6f9c                	ld	a5,24(a5)
ffffffffc02010b4:	8522                	mv	a0,s0
ffffffffc02010b6:	9782                	jalr	a5
ffffffffc02010b8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02010ba:	8fbff0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02010be:	60a2                	ld	ra,8(sp)
ffffffffc02010c0:	8522                	mv	a0,s0
ffffffffc02010c2:	6402                	ld	s0,0(sp)
ffffffffc02010c4:	0141                	addi	sp,sp,16
ffffffffc02010c6:	8082                	ret

ffffffffc02010c8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02010c8:	100027f3          	csrr	a5,sstatus
ffffffffc02010cc:	8b89                	andi	a5,a5,2
ffffffffc02010ce:	e799                	bnez	a5,ffffffffc02010dc <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02010d0:	000b4797          	auipc	a5,0xb4
ffffffffc02010d4:	0187b783          	ld	a5,24(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc02010d8:	739c                	ld	a5,32(a5)
ffffffffc02010da:	8782                	jr	a5
{
ffffffffc02010dc:	1101                	addi	sp,sp,-32
ffffffffc02010de:	ec06                	sd	ra,24(sp)
ffffffffc02010e0:	e822                	sd	s0,16(sp)
ffffffffc02010e2:	e426                	sd	s1,8(sp)
ffffffffc02010e4:	842a                	mv	s0,a0
ffffffffc02010e6:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02010e8:	8d3ff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02010ec:	000b4797          	auipc	a5,0xb4
ffffffffc02010f0:	ffc7b783          	ld	a5,-4(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc02010f4:	739c                	ld	a5,32(a5)
ffffffffc02010f6:	85a6                	mv	a1,s1
ffffffffc02010f8:	8522                	mv	a0,s0
ffffffffc02010fa:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02010fc:	6442                	ld	s0,16(sp)
ffffffffc02010fe:	60e2                	ld	ra,24(sp)
ffffffffc0201100:	64a2                	ld	s1,8(sp)
ffffffffc0201102:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201104:	8b1ff06f          	j	ffffffffc02009b4 <intr_enable>

ffffffffc0201108 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201108:	100027f3          	csrr	a5,sstatus
ffffffffc020110c:	8b89                	andi	a5,a5,2
ffffffffc020110e:	e799                	bnez	a5,ffffffffc020111c <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201110:	000b4797          	auipc	a5,0xb4
ffffffffc0201114:	fd87b783          	ld	a5,-40(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc0201118:	779c                	ld	a5,40(a5)
ffffffffc020111a:	8782                	jr	a5
{
ffffffffc020111c:	1141                	addi	sp,sp,-16
ffffffffc020111e:	e406                	sd	ra,8(sp)
ffffffffc0201120:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201122:	899ff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201126:	000b4797          	auipc	a5,0xb4
ffffffffc020112a:	fc27b783          	ld	a5,-62(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc020112e:	779c                	ld	a5,40(a5)
ffffffffc0201130:	9782                	jalr	a5
ffffffffc0201132:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201134:	881ff0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201138:	60a2                	ld	ra,8(sp)
ffffffffc020113a:	8522                	mv	a0,s0
ffffffffc020113c:	6402                	ld	s0,0(sp)
ffffffffc020113e:	0141                	addi	sp,sp,16
ffffffffc0201140:	8082                	ret

ffffffffc0201142 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201142:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201146:	1ff7f793          	andi	a5,a5,511
{
ffffffffc020114a:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020114c:	078e                	slli	a5,a5,0x3
{
ffffffffc020114e:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201150:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201154:	6094                	ld	a3,0(s1)
{
ffffffffc0201156:	f04a                	sd	s2,32(sp)
ffffffffc0201158:	ec4e                	sd	s3,24(sp)
ffffffffc020115a:	e852                	sd	s4,16(sp)
ffffffffc020115c:	fc06                	sd	ra,56(sp)
ffffffffc020115e:	f822                	sd	s0,48(sp)
ffffffffc0201160:	e456                	sd	s5,8(sp)
ffffffffc0201162:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201164:	0016f793          	andi	a5,a3,1
{
ffffffffc0201168:	892e                	mv	s2,a1
ffffffffc020116a:	8a32                	mv	s4,a2
ffffffffc020116c:	000b4997          	auipc	s3,0xb4
ffffffffc0201170:	f6c98993          	addi	s3,s3,-148 # ffffffffc02b50d8 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201174:	efbd                	bnez	a5,ffffffffc02011f2 <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201176:	14060c63          	beqz	a2,ffffffffc02012ce <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020117a:	100027f3          	csrr	a5,sstatus
ffffffffc020117e:	8b89                	andi	a5,a5,2
ffffffffc0201180:	14079963          	bnez	a5,ffffffffc02012d2 <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201184:	000b4797          	auipc	a5,0xb4
ffffffffc0201188:	f647b783          	ld	a5,-156(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc020118c:	6f9c                	ld	a5,24(a5)
ffffffffc020118e:	4505                	li	a0,1
ffffffffc0201190:	9782                	jalr	a5
ffffffffc0201192:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201194:	12040d63          	beqz	s0,ffffffffc02012ce <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201198:	000b4b17          	auipc	s6,0xb4
ffffffffc020119c:	f48b0b13          	addi	s6,s6,-184 # ffffffffc02b50e0 <pages>
ffffffffc02011a0:	000b3503          	ld	a0,0(s6)
ffffffffc02011a4:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02011a8:	000b4997          	auipc	s3,0xb4
ffffffffc02011ac:	f3098993          	addi	s3,s3,-208 # ffffffffc02b50d8 <npage>
ffffffffc02011b0:	40a40533          	sub	a0,s0,a0
ffffffffc02011b4:	8519                	srai	a0,a0,0x6
ffffffffc02011b6:	9556                	add	a0,a0,s5
ffffffffc02011b8:	0009b703          	ld	a4,0(s3)
ffffffffc02011bc:	00c51793          	slli	a5,a0,0xc
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc02011c0:	4685                	li	a3,1
ffffffffc02011c2:	c014                	sw	a3,0(s0)
ffffffffc02011c4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02011c6:	0532                	slli	a0,a0,0xc
ffffffffc02011c8:	16e7f763          	bgeu	a5,a4,ffffffffc0201336 <get_pte+0x1f4>
ffffffffc02011cc:	000b4797          	auipc	a5,0xb4
ffffffffc02011d0:	f247b783          	ld	a5,-220(a5) # ffffffffc02b50f0 <va_pa_offset>
ffffffffc02011d4:	6605                	lui	a2,0x1
ffffffffc02011d6:	4581                	li	a1,0
ffffffffc02011d8:	953e                	add	a0,a0,a5
ffffffffc02011da:	404040ef          	jal	ra,ffffffffc02055de <memset>
    return page - pages + nbase;
ffffffffc02011de:	000b3683          	ld	a3,0(s6)
ffffffffc02011e2:	40d406b3          	sub	a3,s0,a3
ffffffffc02011e6:	8699                	srai	a3,a3,0x6
ffffffffc02011e8:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02011ea:	06aa                	slli	a3,a3,0xa
ffffffffc02011ec:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02011f0:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02011f2:	77fd                	lui	a5,0xfffff
ffffffffc02011f4:	068a                	slli	a3,a3,0x2
ffffffffc02011f6:	0009b703          	ld	a4,0(s3)
ffffffffc02011fa:	8efd                	and	a3,a3,a5
ffffffffc02011fc:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201200:	10e7ff63          	bgeu	a5,a4,ffffffffc020131e <get_pte+0x1dc>
ffffffffc0201204:	000b4a97          	auipc	s5,0xb4
ffffffffc0201208:	eeca8a93          	addi	s5,s5,-276 # ffffffffc02b50f0 <va_pa_offset>
ffffffffc020120c:	000ab403          	ld	s0,0(s5)
ffffffffc0201210:	01595793          	srli	a5,s2,0x15
ffffffffc0201214:	1ff7f793          	andi	a5,a5,511
ffffffffc0201218:	96a2                	add	a3,a3,s0
ffffffffc020121a:	00379413          	slli	s0,a5,0x3
ffffffffc020121e:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0201220:	6014                	ld	a3,0(s0)
ffffffffc0201222:	0016f793          	andi	a5,a3,1
ffffffffc0201226:	ebad                	bnez	a5,ffffffffc0201298 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201228:	0a0a0363          	beqz	s4,ffffffffc02012ce <get_pte+0x18c>
ffffffffc020122c:	100027f3          	csrr	a5,sstatus
ffffffffc0201230:	8b89                	andi	a5,a5,2
ffffffffc0201232:	efcd                	bnez	a5,ffffffffc02012ec <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201234:	000b4797          	auipc	a5,0xb4
ffffffffc0201238:	eb47b783          	ld	a5,-332(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc020123c:	6f9c                	ld	a5,24(a5)
ffffffffc020123e:	4505                	li	a0,1
ffffffffc0201240:	9782                	jalr	a5
ffffffffc0201242:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201244:	c4c9                	beqz	s1,ffffffffc02012ce <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201246:	000b4b17          	auipc	s6,0xb4
ffffffffc020124a:	e9ab0b13          	addi	s6,s6,-358 # ffffffffc02b50e0 <pages>
ffffffffc020124e:	000b3503          	ld	a0,0(s6)
ffffffffc0201252:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201256:	0009b703          	ld	a4,0(s3)
ffffffffc020125a:	40a48533          	sub	a0,s1,a0
ffffffffc020125e:	8519                	srai	a0,a0,0x6
ffffffffc0201260:	9552                	add	a0,a0,s4
ffffffffc0201262:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201266:	4685                	li	a3,1
ffffffffc0201268:	c094                	sw	a3,0(s1)
ffffffffc020126a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020126c:	0532                	slli	a0,a0,0xc
ffffffffc020126e:	0ee7f163          	bgeu	a5,a4,ffffffffc0201350 <get_pte+0x20e>
ffffffffc0201272:	000ab783          	ld	a5,0(s5)
ffffffffc0201276:	6605                	lui	a2,0x1
ffffffffc0201278:	4581                	li	a1,0
ffffffffc020127a:	953e                	add	a0,a0,a5
ffffffffc020127c:	362040ef          	jal	ra,ffffffffc02055de <memset>
    return page - pages + nbase;
ffffffffc0201280:	000b3683          	ld	a3,0(s6)
ffffffffc0201284:	40d486b3          	sub	a3,s1,a3
ffffffffc0201288:	8699                	srai	a3,a3,0x6
ffffffffc020128a:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020128c:	06aa                	slli	a3,a3,0xa
ffffffffc020128e:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201292:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201294:	0009b703          	ld	a4,0(s3)
ffffffffc0201298:	068a                	slli	a3,a3,0x2
ffffffffc020129a:	757d                	lui	a0,0xfffff
ffffffffc020129c:	8ee9                	and	a3,a3,a0
ffffffffc020129e:	00c6d793          	srli	a5,a3,0xc
ffffffffc02012a2:	06e7f263          	bgeu	a5,a4,ffffffffc0201306 <get_pte+0x1c4>
ffffffffc02012a6:	000ab503          	ld	a0,0(s5)
ffffffffc02012aa:	00c95913          	srli	s2,s2,0xc
ffffffffc02012ae:	1ff97913          	andi	s2,s2,511
ffffffffc02012b2:	96aa                	add	a3,a3,a0
ffffffffc02012b4:	00391513          	slli	a0,s2,0x3
ffffffffc02012b8:	9536                	add	a0,a0,a3
}
ffffffffc02012ba:	70e2                	ld	ra,56(sp)
ffffffffc02012bc:	7442                	ld	s0,48(sp)
ffffffffc02012be:	74a2                	ld	s1,40(sp)
ffffffffc02012c0:	7902                	ld	s2,32(sp)
ffffffffc02012c2:	69e2                	ld	s3,24(sp)
ffffffffc02012c4:	6a42                	ld	s4,16(sp)
ffffffffc02012c6:	6aa2                	ld	s5,8(sp)
ffffffffc02012c8:	6b02                	ld	s6,0(sp)
ffffffffc02012ca:	6121                	addi	sp,sp,64
ffffffffc02012cc:	8082                	ret
            return NULL;
ffffffffc02012ce:	4501                	li	a0,0
ffffffffc02012d0:	b7ed                	j	ffffffffc02012ba <get_pte+0x178>
        intr_disable();
ffffffffc02012d2:	ee8ff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012d6:	000b4797          	auipc	a5,0xb4
ffffffffc02012da:	e127b783          	ld	a5,-494(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc02012de:	6f9c                	ld	a5,24(a5)
ffffffffc02012e0:	4505                	li	a0,1
ffffffffc02012e2:	9782                	jalr	a5
ffffffffc02012e4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012e6:	eceff0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc02012ea:	b56d                	j	ffffffffc0201194 <get_pte+0x52>
        intr_disable();
ffffffffc02012ec:	eceff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc02012f0:	000b4797          	auipc	a5,0xb4
ffffffffc02012f4:	df87b783          	ld	a5,-520(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc02012f8:	6f9c                	ld	a5,24(a5)
ffffffffc02012fa:	4505                	li	a0,1
ffffffffc02012fc:	9782                	jalr	a5
ffffffffc02012fe:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc0201300:	eb4ff0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201304:	b781                	j	ffffffffc0201244 <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201306:	00005617          	auipc	a2,0x5
ffffffffc020130a:	1e260613          	addi	a2,a2,482 # ffffffffc02064e8 <commands+0x830>
ffffffffc020130e:	0fa00593          	li	a1,250
ffffffffc0201312:	00005517          	auipc	a0,0x5
ffffffffc0201316:	1fe50513          	addi	a0,a0,510 # ffffffffc0206510 <commands+0x858>
ffffffffc020131a:	f05fe0ef          	jal	ra,ffffffffc020021e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020131e:	00005617          	auipc	a2,0x5
ffffffffc0201322:	1ca60613          	addi	a2,a2,458 # ffffffffc02064e8 <commands+0x830>
ffffffffc0201326:	0ed00593          	li	a1,237
ffffffffc020132a:	00005517          	auipc	a0,0x5
ffffffffc020132e:	1e650513          	addi	a0,a0,486 # ffffffffc0206510 <commands+0x858>
ffffffffc0201332:	eedfe0ef          	jal	ra,ffffffffc020021e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201336:	86aa                	mv	a3,a0
ffffffffc0201338:	00005617          	auipc	a2,0x5
ffffffffc020133c:	1b060613          	addi	a2,a2,432 # ffffffffc02064e8 <commands+0x830>
ffffffffc0201340:	0e900593          	li	a1,233
ffffffffc0201344:	00005517          	auipc	a0,0x5
ffffffffc0201348:	1cc50513          	addi	a0,a0,460 # ffffffffc0206510 <commands+0x858>
ffffffffc020134c:	ed3fe0ef          	jal	ra,ffffffffc020021e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201350:	86aa                	mv	a3,a0
ffffffffc0201352:	00005617          	auipc	a2,0x5
ffffffffc0201356:	19660613          	addi	a2,a2,406 # ffffffffc02064e8 <commands+0x830>
ffffffffc020135a:	0f700593          	li	a1,247
ffffffffc020135e:	00005517          	auipc	a0,0x5
ffffffffc0201362:	1b250513          	addi	a0,a0,434 # ffffffffc0206510 <commands+0x858>
ffffffffc0201366:	eb9fe0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020136a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc020136a:	1141                	addi	sp,sp,-16
ffffffffc020136c:	e022                	sd	s0,0(sp)
ffffffffc020136e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201370:	4601                	li	a2,0
{
ffffffffc0201372:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201374:	dcfff0ef          	jal	ra,ffffffffc0201142 <get_pte>
    if (ptep_store != NULL)
ffffffffc0201378:	c011                	beqz	s0,ffffffffc020137c <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc020137a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020137c:	c511                	beqz	a0,ffffffffc0201388 <get_page+0x1e>
ffffffffc020137e:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201380:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0201382:	0017f713          	andi	a4,a5,1
ffffffffc0201386:	e709                	bnez	a4,ffffffffc0201390 <get_page+0x26>
}
ffffffffc0201388:	60a2                	ld	ra,8(sp)
ffffffffc020138a:	6402                	ld	s0,0(sp)
ffffffffc020138c:	0141                	addi	sp,sp,16
ffffffffc020138e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201390:	078a                	slli	a5,a5,0x2
ffffffffc0201392:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201394:	000b4717          	auipc	a4,0xb4
ffffffffc0201398:	d4473703          	ld	a4,-700(a4) # ffffffffc02b50d8 <npage>
ffffffffc020139c:	00e7ff63          	bgeu	a5,a4,ffffffffc02013ba <get_page+0x50>
ffffffffc02013a0:	60a2                	ld	ra,8(sp)
ffffffffc02013a2:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02013a4:	fff80537          	lui	a0,0xfff80
ffffffffc02013a8:	97aa                	add	a5,a5,a0
ffffffffc02013aa:	079a                	slli	a5,a5,0x6
ffffffffc02013ac:	000b4517          	auipc	a0,0xb4
ffffffffc02013b0:	d3453503          	ld	a0,-716(a0) # ffffffffc02b50e0 <pages>
ffffffffc02013b4:	953e                	add	a0,a0,a5
ffffffffc02013b6:	0141                	addi	sp,sp,16
ffffffffc02013b8:	8082                	ret
ffffffffc02013ba:	c99ff0ef          	jal	ra,ffffffffc0201052 <pa2page.part.0>

ffffffffc02013be <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc02013be:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02013c0:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02013c4:	f486                	sd	ra,104(sp)
ffffffffc02013c6:	f0a2                	sd	s0,96(sp)
ffffffffc02013c8:	eca6                	sd	s1,88(sp)
ffffffffc02013ca:	e8ca                	sd	s2,80(sp)
ffffffffc02013cc:	e4ce                	sd	s3,72(sp)
ffffffffc02013ce:	e0d2                	sd	s4,64(sp)
ffffffffc02013d0:	fc56                	sd	s5,56(sp)
ffffffffc02013d2:	f85a                	sd	s6,48(sp)
ffffffffc02013d4:	f45e                	sd	s7,40(sp)
ffffffffc02013d6:	f062                	sd	s8,32(sp)
ffffffffc02013d8:	ec66                	sd	s9,24(sp)
ffffffffc02013da:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02013dc:	17d2                	slli	a5,a5,0x34
ffffffffc02013de:	e3ed                	bnez	a5,ffffffffc02014c0 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc02013e0:	002007b7          	lui	a5,0x200
ffffffffc02013e4:	842e                	mv	s0,a1
ffffffffc02013e6:	0ef5ed63          	bltu	a1,a5,ffffffffc02014e0 <unmap_range+0x122>
ffffffffc02013ea:	8932                	mv	s2,a2
ffffffffc02013ec:	0ec5fa63          	bgeu	a1,a2,ffffffffc02014e0 <unmap_range+0x122>
ffffffffc02013f0:	4785                	li	a5,1
ffffffffc02013f2:	07fe                	slli	a5,a5,0x1f
ffffffffc02013f4:	0ec7e663          	bltu	a5,a2,ffffffffc02014e0 <unmap_range+0x122>
ffffffffc02013f8:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02013fa:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc02013fc:	000b4c97          	auipc	s9,0xb4
ffffffffc0201400:	cdcc8c93          	addi	s9,s9,-804 # ffffffffc02b50d8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201404:	000b4c17          	auipc	s8,0xb4
ffffffffc0201408:	cdcc0c13          	addi	s8,s8,-804 # ffffffffc02b50e0 <pages>
ffffffffc020140c:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0201410:	000b4d17          	auipc	s10,0xb4
ffffffffc0201414:	cd8d0d13          	addi	s10,s10,-808 # ffffffffc02b50e8 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201418:	00200b37          	lui	s6,0x200
ffffffffc020141c:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0201420:	4601                	li	a2,0
ffffffffc0201422:	85a2                	mv	a1,s0
ffffffffc0201424:	854e                	mv	a0,s3
ffffffffc0201426:	d1dff0ef          	jal	ra,ffffffffc0201142 <get_pte>
ffffffffc020142a:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc020142c:	cd29                	beqz	a0,ffffffffc0201486 <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc020142e:	611c                	ld	a5,0(a0)
ffffffffc0201430:	e395                	bnez	a5,ffffffffc0201454 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0201432:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201434:	ff2466e3          	bltu	s0,s2,ffffffffc0201420 <unmap_range+0x62>
}
ffffffffc0201438:	70a6                	ld	ra,104(sp)
ffffffffc020143a:	7406                	ld	s0,96(sp)
ffffffffc020143c:	64e6                	ld	s1,88(sp)
ffffffffc020143e:	6946                	ld	s2,80(sp)
ffffffffc0201440:	69a6                	ld	s3,72(sp)
ffffffffc0201442:	6a06                	ld	s4,64(sp)
ffffffffc0201444:	7ae2                	ld	s5,56(sp)
ffffffffc0201446:	7b42                	ld	s6,48(sp)
ffffffffc0201448:	7ba2                	ld	s7,40(sp)
ffffffffc020144a:	7c02                	ld	s8,32(sp)
ffffffffc020144c:	6ce2                	ld	s9,24(sp)
ffffffffc020144e:	6d42                	ld	s10,16(sp)
ffffffffc0201450:	6165                	addi	sp,sp,112
ffffffffc0201452:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0201454:	0017f713          	andi	a4,a5,1
ffffffffc0201458:	df69                	beqz	a4,ffffffffc0201432 <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc020145a:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020145e:	078a                	slli	a5,a5,0x2
ffffffffc0201460:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201462:	08e7ff63          	bgeu	a5,a4,ffffffffc0201500 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0201466:	000c3503          	ld	a0,0(s8)
ffffffffc020146a:	97de                	add	a5,a5,s7
ffffffffc020146c:	079a                	slli	a5,a5,0x6
ffffffffc020146e:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201470:	411c                	lw	a5,0(a0)
ffffffffc0201472:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201476:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0201478:	cf11                	beqz	a4,ffffffffc0201494 <unmap_range+0xd6>
        *ptep = 0;
ffffffffc020147a:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020147e:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0201482:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201484:	bf45                	j	ffffffffc0201434 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201486:	945a                	add	s0,s0,s6
ffffffffc0201488:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc020148c:	d455                	beqz	s0,ffffffffc0201438 <unmap_range+0x7a>
ffffffffc020148e:	f92469e3          	bltu	s0,s2,ffffffffc0201420 <unmap_range+0x62>
ffffffffc0201492:	b75d                	j	ffffffffc0201438 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201494:	100027f3          	csrr	a5,sstatus
ffffffffc0201498:	8b89                	andi	a5,a5,2
ffffffffc020149a:	e799                	bnez	a5,ffffffffc02014a8 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc020149c:	000d3783          	ld	a5,0(s10)
ffffffffc02014a0:	4585                	li	a1,1
ffffffffc02014a2:	739c                	ld	a5,32(a5)
ffffffffc02014a4:	9782                	jalr	a5
    if (flag)
ffffffffc02014a6:	bfd1                	j	ffffffffc020147a <unmap_range+0xbc>
ffffffffc02014a8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02014aa:	d10ff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc02014ae:	000d3783          	ld	a5,0(s10)
ffffffffc02014b2:	6522                	ld	a0,8(sp)
ffffffffc02014b4:	4585                	li	a1,1
ffffffffc02014b6:	739c                	ld	a5,32(a5)
ffffffffc02014b8:	9782                	jalr	a5
        intr_enable();
ffffffffc02014ba:	cfaff0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc02014be:	bf75                	j	ffffffffc020147a <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02014c0:	00005697          	auipc	a3,0x5
ffffffffc02014c4:	06068693          	addi	a3,a3,96 # ffffffffc0206520 <commands+0x868>
ffffffffc02014c8:	00005617          	auipc	a2,0x5
ffffffffc02014cc:	08860613          	addi	a2,a2,136 # ffffffffc0206550 <commands+0x898>
ffffffffc02014d0:	12000593          	li	a1,288
ffffffffc02014d4:	00005517          	auipc	a0,0x5
ffffffffc02014d8:	03c50513          	addi	a0,a0,60 # ffffffffc0206510 <commands+0x858>
ffffffffc02014dc:	d43fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02014e0:	00005697          	auipc	a3,0x5
ffffffffc02014e4:	08868693          	addi	a3,a3,136 # ffffffffc0206568 <commands+0x8b0>
ffffffffc02014e8:	00005617          	auipc	a2,0x5
ffffffffc02014ec:	06860613          	addi	a2,a2,104 # ffffffffc0206550 <commands+0x898>
ffffffffc02014f0:	12100593          	li	a1,289
ffffffffc02014f4:	00005517          	auipc	a0,0x5
ffffffffc02014f8:	01c50513          	addi	a0,a0,28 # ffffffffc0206510 <commands+0x858>
ffffffffc02014fc:	d23fe0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0201500:	b53ff0ef          	jal	ra,ffffffffc0201052 <pa2page.part.0>

ffffffffc0201504 <exit_range>:
{
ffffffffc0201504:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201506:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc020150a:	fc86                	sd	ra,120(sp)
ffffffffc020150c:	f8a2                	sd	s0,112(sp)
ffffffffc020150e:	f4a6                	sd	s1,104(sp)
ffffffffc0201510:	f0ca                	sd	s2,96(sp)
ffffffffc0201512:	ecce                	sd	s3,88(sp)
ffffffffc0201514:	e8d2                	sd	s4,80(sp)
ffffffffc0201516:	e4d6                	sd	s5,72(sp)
ffffffffc0201518:	e0da                	sd	s6,64(sp)
ffffffffc020151a:	fc5e                	sd	s7,56(sp)
ffffffffc020151c:	f862                	sd	s8,48(sp)
ffffffffc020151e:	f466                	sd	s9,40(sp)
ffffffffc0201520:	f06a                	sd	s10,32(sp)
ffffffffc0201522:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201524:	17d2                	slli	a5,a5,0x34
ffffffffc0201526:	20079a63          	bnez	a5,ffffffffc020173a <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc020152a:	002007b7          	lui	a5,0x200
ffffffffc020152e:	24f5e463          	bltu	a1,a5,ffffffffc0201776 <exit_range+0x272>
ffffffffc0201532:	8ab2                	mv	s5,a2
ffffffffc0201534:	24c5f163          	bgeu	a1,a2,ffffffffc0201776 <exit_range+0x272>
ffffffffc0201538:	4785                	li	a5,1
ffffffffc020153a:	07fe                	slli	a5,a5,0x1f
ffffffffc020153c:	22c7ed63          	bltu	a5,a2,ffffffffc0201776 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0201540:	c00009b7          	lui	s3,0xc0000
ffffffffc0201544:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0201548:	ffe00937          	lui	s2,0xffe00
ffffffffc020154c:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0201550:	5cfd                	li	s9,-1
ffffffffc0201552:	8c2a                	mv	s8,a0
ffffffffc0201554:	0125f933          	and	s2,a1,s2
ffffffffc0201558:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc020155a:	000b4d17          	auipc	s10,0xb4
ffffffffc020155e:	b7ed0d13          	addi	s10,s10,-1154 # ffffffffc02b50d8 <npage>
    return KADDR(page2pa(page));
ffffffffc0201562:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201566:	000b4717          	auipc	a4,0xb4
ffffffffc020156a:	b7a70713          	addi	a4,a4,-1158 # ffffffffc02b50e0 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020156e:	000b4d97          	auipc	s11,0xb4
ffffffffc0201572:	b7ad8d93          	addi	s11,s11,-1158 # ffffffffc02b50e8 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0201576:	c0000437          	lui	s0,0xc0000
ffffffffc020157a:	944e                	add	s0,s0,s3
ffffffffc020157c:	8079                	srli	s0,s0,0x1e
ffffffffc020157e:	1ff47413          	andi	s0,s0,511
ffffffffc0201582:	040e                	slli	s0,s0,0x3
ffffffffc0201584:	9462                	add	s0,s0,s8
ffffffffc0201586:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
        if (pde1 & PTE_V)
ffffffffc020158a:	001a7793          	andi	a5,s4,1
ffffffffc020158e:	eb99                	bnez	a5,ffffffffc02015a4 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc0201590:	12098463          	beqz	s3,ffffffffc02016b8 <exit_range+0x1b4>
ffffffffc0201594:	400007b7          	lui	a5,0x40000
ffffffffc0201598:	97ce                	add	a5,a5,s3
ffffffffc020159a:	894e                	mv	s2,s3
ffffffffc020159c:	1159fe63          	bgeu	s3,s5,ffffffffc02016b8 <exit_range+0x1b4>
ffffffffc02015a0:	89be                	mv	s3,a5
ffffffffc02015a2:	bfd1                	j	ffffffffc0201576 <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc02015a4:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02015a8:	0a0a                	slli	s4,s4,0x2
ffffffffc02015aa:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc02015ae:	1cfa7263          	bgeu	s4,a5,ffffffffc0201772 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02015b2:	fff80637          	lui	a2,0xfff80
ffffffffc02015b6:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc02015b8:	000806b7          	lui	a3,0x80
ffffffffc02015bc:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02015be:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02015c2:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02015c4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02015c6:	18f5fa63          	bgeu	a1,a5,ffffffffc020175a <exit_range+0x256>
ffffffffc02015ca:	000b4817          	auipc	a6,0xb4
ffffffffc02015ce:	b2680813          	addi	a6,a6,-1242 # ffffffffc02b50f0 <va_pa_offset>
ffffffffc02015d2:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc02015d6:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc02015d8:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc02015dc:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc02015de:	00080337          	lui	t1,0x80
ffffffffc02015e2:	6885                	lui	a7,0x1
ffffffffc02015e4:	a819                	j	ffffffffc02015fa <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc02015e6:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc02015e8:	002007b7          	lui	a5,0x200
ffffffffc02015ec:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02015ee:	08090c63          	beqz	s2,ffffffffc0201686 <exit_range+0x182>
ffffffffc02015f2:	09397a63          	bgeu	s2,s3,ffffffffc0201686 <exit_range+0x182>
ffffffffc02015f6:	0f597063          	bgeu	s2,s5,ffffffffc02016d6 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02015fa:	01595493          	srli	s1,s2,0x15
ffffffffc02015fe:	1ff4f493          	andi	s1,s1,511
ffffffffc0201602:	048e                	slli	s1,s1,0x3
ffffffffc0201604:	94da                	add	s1,s1,s6
ffffffffc0201606:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc0201608:	0017f693          	andi	a3,a5,1
ffffffffc020160c:	dee9                	beqz	a3,ffffffffc02015e6 <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc020160e:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201612:	078a                	slli	a5,a5,0x2
ffffffffc0201614:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201616:	14b7fe63          	bgeu	a5,a1,ffffffffc0201772 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020161a:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc020161c:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0201620:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0201624:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201628:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020162a:	12bef863          	bgeu	t4,a1,ffffffffc020175a <exit_range+0x256>
ffffffffc020162e:	00083783          	ld	a5,0(a6)
ffffffffc0201632:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0201634:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc0201638:	629c                	ld	a5,0(a3)
ffffffffc020163a:	8b85                	andi	a5,a5,1
ffffffffc020163c:	f7d5                	bnez	a5,ffffffffc02015e8 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc020163e:	06a1                	addi	a3,a3,8
ffffffffc0201640:	fed59ce3          	bne	a1,a3,ffffffffc0201638 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0201644:	631c                	ld	a5,0(a4)
ffffffffc0201646:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201648:	100027f3          	csrr	a5,sstatus
ffffffffc020164c:	8b89                	andi	a5,a5,2
ffffffffc020164e:	e7d9                	bnez	a5,ffffffffc02016dc <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0201650:	000db783          	ld	a5,0(s11)
ffffffffc0201654:	4585                	li	a1,1
ffffffffc0201656:	e032                	sd	a2,0(sp)
ffffffffc0201658:	739c                	ld	a5,32(a5)
ffffffffc020165a:	9782                	jalr	a5
    if (flag)
ffffffffc020165c:	6602                	ld	a2,0(sp)
ffffffffc020165e:	000b4817          	auipc	a6,0xb4
ffffffffc0201662:	a9280813          	addi	a6,a6,-1390 # ffffffffc02b50f0 <va_pa_offset>
ffffffffc0201666:	fff80e37          	lui	t3,0xfff80
ffffffffc020166a:	00080337          	lui	t1,0x80
ffffffffc020166e:	6885                	lui	a7,0x1
ffffffffc0201670:	000b4717          	auipc	a4,0xb4
ffffffffc0201674:	a7070713          	addi	a4,a4,-1424 # ffffffffc02b50e0 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0201678:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc020167c:	002007b7          	lui	a5,0x200
ffffffffc0201680:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0201682:	f60918e3          	bnez	s2,ffffffffc02015f2 <exit_range+0xee>
            if (free_pd0)
ffffffffc0201686:	f00b85e3          	beqz	s7,ffffffffc0201590 <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc020168a:	000d3783          	ld	a5,0(s10)
ffffffffc020168e:	0efa7263          	bgeu	s4,a5,ffffffffc0201772 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201692:	6308                	ld	a0,0(a4)
ffffffffc0201694:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201696:	100027f3          	csrr	a5,sstatus
ffffffffc020169a:	8b89                	andi	a5,a5,2
ffffffffc020169c:	efad                	bnez	a5,ffffffffc0201716 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc020169e:	000db783          	ld	a5,0(s11)
ffffffffc02016a2:	4585                	li	a1,1
ffffffffc02016a4:	739c                	ld	a5,32(a5)
ffffffffc02016a6:	9782                	jalr	a5
ffffffffc02016a8:	000b4717          	auipc	a4,0xb4
ffffffffc02016ac:	a3870713          	addi	a4,a4,-1480 # ffffffffc02b50e0 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02016b0:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc02016b4:	ee0990e3          	bnez	s3,ffffffffc0201594 <exit_range+0x90>
}
ffffffffc02016b8:	70e6                	ld	ra,120(sp)
ffffffffc02016ba:	7446                	ld	s0,112(sp)
ffffffffc02016bc:	74a6                	ld	s1,104(sp)
ffffffffc02016be:	7906                	ld	s2,96(sp)
ffffffffc02016c0:	69e6                	ld	s3,88(sp)
ffffffffc02016c2:	6a46                	ld	s4,80(sp)
ffffffffc02016c4:	6aa6                	ld	s5,72(sp)
ffffffffc02016c6:	6b06                	ld	s6,64(sp)
ffffffffc02016c8:	7be2                	ld	s7,56(sp)
ffffffffc02016ca:	7c42                	ld	s8,48(sp)
ffffffffc02016cc:	7ca2                	ld	s9,40(sp)
ffffffffc02016ce:	7d02                	ld	s10,32(sp)
ffffffffc02016d0:	6de2                	ld	s11,24(sp)
ffffffffc02016d2:	6109                	addi	sp,sp,128
ffffffffc02016d4:	8082                	ret
            if (free_pd0)
ffffffffc02016d6:	ea0b8fe3          	beqz	s7,ffffffffc0201594 <exit_range+0x90>
ffffffffc02016da:	bf45                	j	ffffffffc020168a <exit_range+0x186>
ffffffffc02016dc:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc02016de:	e42a                	sd	a0,8(sp)
ffffffffc02016e0:	adaff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02016e4:	000db783          	ld	a5,0(s11)
ffffffffc02016e8:	6522                	ld	a0,8(sp)
ffffffffc02016ea:	4585                	li	a1,1
ffffffffc02016ec:	739c                	ld	a5,32(a5)
ffffffffc02016ee:	9782                	jalr	a5
        intr_enable();
ffffffffc02016f0:	ac4ff0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc02016f4:	6602                	ld	a2,0(sp)
ffffffffc02016f6:	000b4717          	auipc	a4,0xb4
ffffffffc02016fa:	9ea70713          	addi	a4,a4,-1558 # ffffffffc02b50e0 <pages>
ffffffffc02016fe:	6885                	lui	a7,0x1
ffffffffc0201700:	00080337          	lui	t1,0x80
ffffffffc0201704:	fff80e37          	lui	t3,0xfff80
ffffffffc0201708:	000b4817          	auipc	a6,0xb4
ffffffffc020170c:	9e880813          	addi	a6,a6,-1560 # ffffffffc02b50f0 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0201710:	0004b023          	sd	zero,0(s1)
ffffffffc0201714:	b7a5                	j	ffffffffc020167c <exit_range+0x178>
ffffffffc0201716:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0201718:	aa2ff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020171c:	000db783          	ld	a5,0(s11)
ffffffffc0201720:	6502                	ld	a0,0(sp)
ffffffffc0201722:	4585                	li	a1,1
ffffffffc0201724:	739c                	ld	a5,32(a5)
ffffffffc0201726:	9782                	jalr	a5
        intr_enable();
ffffffffc0201728:	a8cff0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc020172c:	000b4717          	auipc	a4,0xb4
ffffffffc0201730:	9b470713          	addi	a4,a4,-1612 # ffffffffc02b50e0 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0201734:	00043023          	sd	zero,0(s0)
ffffffffc0201738:	bfb5                	j	ffffffffc02016b4 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020173a:	00005697          	auipc	a3,0x5
ffffffffc020173e:	de668693          	addi	a3,a3,-538 # ffffffffc0206520 <commands+0x868>
ffffffffc0201742:	00005617          	auipc	a2,0x5
ffffffffc0201746:	e0e60613          	addi	a2,a2,-498 # ffffffffc0206550 <commands+0x898>
ffffffffc020174a:	13500593          	li	a1,309
ffffffffc020174e:	00005517          	auipc	a0,0x5
ffffffffc0201752:	dc250513          	addi	a0,a0,-574 # ffffffffc0206510 <commands+0x858>
ffffffffc0201756:	ac9fe0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc020175a:	00005617          	auipc	a2,0x5
ffffffffc020175e:	d8e60613          	addi	a2,a2,-626 # ffffffffc02064e8 <commands+0x830>
ffffffffc0201762:	07100593          	li	a1,113
ffffffffc0201766:	00005517          	auipc	a0,0x5
ffffffffc020176a:	d4a50513          	addi	a0,a0,-694 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc020176e:	ab1fe0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0201772:	8e1ff0ef          	jal	ra,ffffffffc0201052 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0201776:	00005697          	auipc	a3,0x5
ffffffffc020177a:	df268693          	addi	a3,a3,-526 # ffffffffc0206568 <commands+0x8b0>
ffffffffc020177e:	00005617          	auipc	a2,0x5
ffffffffc0201782:	dd260613          	addi	a2,a2,-558 # ffffffffc0206550 <commands+0x898>
ffffffffc0201786:	13600593          	li	a1,310
ffffffffc020178a:	00005517          	auipc	a0,0x5
ffffffffc020178e:	d8650513          	addi	a0,a0,-634 # ffffffffc0206510 <commands+0x858>
ffffffffc0201792:	a8dfe0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0201796 <page_remove>:
{
ffffffffc0201796:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201798:	4601                	li	a2,0
{
ffffffffc020179a:	ec26                	sd	s1,24(sp)
ffffffffc020179c:	f406                	sd	ra,40(sp)
ffffffffc020179e:	f022                	sd	s0,32(sp)
ffffffffc02017a0:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02017a2:	9a1ff0ef          	jal	ra,ffffffffc0201142 <get_pte>
    if (ptep != NULL)
ffffffffc02017a6:	c511                	beqz	a0,ffffffffc02017b2 <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc02017a8:	611c                	ld	a5,0(a0)
ffffffffc02017aa:	842a                	mv	s0,a0
ffffffffc02017ac:	0017f713          	andi	a4,a5,1
ffffffffc02017b0:	e711                	bnez	a4,ffffffffc02017bc <page_remove+0x26>
}
ffffffffc02017b2:	70a2                	ld	ra,40(sp)
ffffffffc02017b4:	7402                	ld	s0,32(sp)
ffffffffc02017b6:	64e2                	ld	s1,24(sp)
ffffffffc02017b8:	6145                	addi	sp,sp,48
ffffffffc02017ba:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02017bc:	078a                	slli	a5,a5,0x2
ffffffffc02017be:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02017c0:	000b4717          	auipc	a4,0xb4
ffffffffc02017c4:	91873703          	ld	a4,-1768(a4) # ffffffffc02b50d8 <npage>
ffffffffc02017c8:	06e7f363          	bgeu	a5,a4,ffffffffc020182e <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02017cc:	fff80537          	lui	a0,0xfff80
ffffffffc02017d0:	97aa                	add	a5,a5,a0
ffffffffc02017d2:	079a                	slli	a5,a5,0x6
ffffffffc02017d4:	000b4517          	auipc	a0,0xb4
ffffffffc02017d8:	90c53503          	ld	a0,-1780(a0) # ffffffffc02b50e0 <pages>
ffffffffc02017dc:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02017de:	411c                	lw	a5,0(a0)
ffffffffc02017e0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02017e4:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc02017e6:	cb11                	beqz	a4,ffffffffc02017fa <page_remove+0x64>
        *ptep = 0;
ffffffffc02017e8:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02017ec:	12048073          	sfence.vma	s1
}
ffffffffc02017f0:	70a2                	ld	ra,40(sp)
ffffffffc02017f2:	7402                	ld	s0,32(sp)
ffffffffc02017f4:	64e2                	ld	s1,24(sp)
ffffffffc02017f6:	6145                	addi	sp,sp,48
ffffffffc02017f8:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02017fa:	100027f3          	csrr	a5,sstatus
ffffffffc02017fe:	8b89                	andi	a5,a5,2
ffffffffc0201800:	eb89                	bnez	a5,ffffffffc0201812 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0201802:	000b4797          	auipc	a5,0xb4
ffffffffc0201806:	8e67b783          	ld	a5,-1818(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc020180a:	739c                	ld	a5,32(a5)
ffffffffc020180c:	4585                	li	a1,1
ffffffffc020180e:	9782                	jalr	a5
    if (flag)
ffffffffc0201810:	bfe1                	j	ffffffffc02017e8 <page_remove+0x52>
        intr_disable();
ffffffffc0201812:	e42a                	sd	a0,8(sp)
ffffffffc0201814:	9a6ff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0201818:	000b4797          	auipc	a5,0xb4
ffffffffc020181c:	8d07b783          	ld	a5,-1840(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc0201820:	739c                	ld	a5,32(a5)
ffffffffc0201822:	6522                	ld	a0,8(sp)
ffffffffc0201824:	4585                	li	a1,1
ffffffffc0201826:	9782                	jalr	a5
        intr_enable();
ffffffffc0201828:	98cff0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc020182c:	bf75                	j	ffffffffc02017e8 <page_remove+0x52>
ffffffffc020182e:	825ff0ef          	jal	ra,ffffffffc0201052 <pa2page.part.0>

ffffffffc0201832 <page_insert>:
{
ffffffffc0201832:	7139                	addi	sp,sp,-64
ffffffffc0201834:	e852                	sd	s4,16(sp)
ffffffffc0201836:	8a32                	mv	s4,a2
ffffffffc0201838:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020183a:	4605                	li	a2,1
{
ffffffffc020183c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020183e:	85d2                	mv	a1,s4
{
ffffffffc0201840:	f426                	sd	s1,40(sp)
ffffffffc0201842:	fc06                	sd	ra,56(sp)
ffffffffc0201844:	f04a                	sd	s2,32(sp)
ffffffffc0201846:	ec4e                	sd	s3,24(sp)
ffffffffc0201848:	e456                	sd	s5,8(sp)
ffffffffc020184a:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020184c:	8f7ff0ef          	jal	ra,ffffffffc0201142 <get_pte>
    if (ptep == NULL)
ffffffffc0201850:	c961                	beqz	a0,ffffffffc0201920 <page_insert+0xee>
    page->ref += 1;
ffffffffc0201852:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc0201854:	611c                	ld	a5,0(a0)
ffffffffc0201856:	89aa                	mv	s3,a0
ffffffffc0201858:	0016871b          	addiw	a4,a3,1
ffffffffc020185c:	c018                	sw	a4,0(s0)
ffffffffc020185e:	0017f713          	andi	a4,a5,1
ffffffffc0201862:	ef05                	bnez	a4,ffffffffc020189a <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0201864:	000b4717          	auipc	a4,0xb4
ffffffffc0201868:	87c73703          	ld	a4,-1924(a4) # ffffffffc02b50e0 <pages>
ffffffffc020186c:	8c19                	sub	s0,s0,a4
ffffffffc020186e:	000807b7          	lui	a5,0x80
ffffffffc0201872:	8419                	srai	s0,s0,0x6
ffffffffc0201874:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201876:	042a                	slli	s0,s0,0xa
ffffffffc0201878:	8cc1                	or	s1,s1,s0
ffffffffc020187a:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020187e:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ed8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201882:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0201886:	4501                	li	a0,0
}
ffffffffc0201888:	70e2                	ld	ra,56(sp)
ffffffffc020188a:	7442                	ld	s0,48(sp)
ffffffffc020188c:	74a2                	ld	s1,40(sp)
ffffffffc020188e:	7902                	ld	s2,32(sp)
ffffffffc0201890:	69e2                	ld	s3,24(sp)
ffffffffc0201892:	6a42                	ld	s4,16(sp)
ffffffffc0201894:	6aa2                	ld	s5,8(sp)
ffffffffc0201896:	6121                	addi	sp,sp,64
ffffffffc0201898:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020189a:	078a                	slli	a5,a5,0x2
ffffffffc020189c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020189e:	000b4717          	auipc	a4,0xb4
ffffffffc02018a2:	83a73703          	ld	a4,-1990(a4) # ffffffffc02b50d8 <npage>
ffffffffc02018a6:	06e7ff63          	bgeu	a5,a4,ffffffffc0201924 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02018aa:	000b4a97          	auipc	s5,0xb4
ffffffffc02018ae:	836a8a93          	addi	s5,s5,-1994 # ffffffffc02b50e0 <pages>
ffffffffc02018b2:	000ab703          	ld	a4,0(s5)
ffffffffc02018b6:	fff80937          	lui	s2,0xfff80
ffffffffc02018ba:	993e                	add	s2,s2,a5
ffffffffc02018bc:	091a                	slli	s2,s2,0x6
ffffffffc02018be:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc02018c0:	01240c63          	beq	s0,s2,ffffffffc02018d8 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02018c4:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccaedc>
ffffffffc02018c8:	fff7869b          	addiw	a3,a5,-1
ffffffffc02018cc:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) == 0)
ffffffffc02018d0:	c691                	beqz	a3,ffffffffc02018dc <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02018d2:	120a0073          	sfence.vma	s4
}
ffffffffc02018d6:	bf59                	j	ffffffffc020186c <page_insert+0x3a>
ffffffffc02018d8:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02018da:	bf49                	j	ffffffffc020186c <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02018dc:	100027f3          	csrr	a5,sstatus
ffffffffc02018e0:	8b89                	andi	a5,a5,2
ffffffffc02018e2:	ef91                	bnez	a5,ffffffffc02018fe <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02018e4:	000b4797          	auipc	a5,0xb4
ffffffffc02018e8:	8047b783          	ld	a5,-2044(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc02018ec:	739c                	ld	a5,32(a5)
ffffffffc02018ee:	4585                	li	a1,1
ffffffffc02018f0:	854a                	mv	a0,s2
ffffffffc02018f2:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02018f4:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02018f8:	120a0073          	sfence.vma	s4
ffffffffc02018fc:	bf85                	j	ffffffffc020186c <page_insert+0x3a>
        intr_disable();
ffffffffc02018fe:	8bcff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201902:	000b3797          	auipc	a5,0xb3
ffffffffc0201906:	7e67b783          	ld	a5,2022(a5) # ffffffffc02b50e8 <pmm_manager>
ffffffffc020190a:	739c                	ld	a5,32(a5)
ffffffffc020190c:	4585                	li	a1,1
ffffffffc020190e:	854a                	mv	a0,s2
ffffffffc0201910:	9782                	jalr	a5
        intr_enable();
ffffffffc0201912:	8a2ff0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201916:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020191a:	120a0073          	sfence.vma	s4
ffffffffc020191e:	b7b9                	j	ffffffffc020186c <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201920:	5571                	li	a0,-4
ffffffffc0201922:	b79d                	j	ffffffffc0201888 <page_insert+0x56>
ffffffffc0201924:	f2eff0ef          	jal	ra,ffffffffc0201052 <pa2page.part.0>

ffffffffc0201928 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201928:	00006797          	auipc	a5,0x6
ffffffffc020192c:	aa078793          	addi	a5,a5,-1376 # ffffffffc02073c8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201930:	638c                	ld	a1,0(a5)
{
ffffffffc0201932:	7159                	addi	sp,sp,-112
ffffffffc0201934:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201936:	00005517          	auipc	a0,0x5
ffffffffc020193a:	c4a50513          	addi	a0,a0,-950 # ffffffffc0206580 <commands+0x8c8>
    pmm_manager = &default_pmm_manager;
ffffffffc020193e:	000b3b17          	auipc	s6,0xb3
ffffffffc0201942:	7aab0b13          	addi	s6,s6,1962 # ffffffffc02b50e8 <pmm_manager>
{
ffffffffc0201946:	f486                	sd	ra,104(sp)
ffffffffc0201948:	e8ca                	sd	s2,80(sp)
ffffffffc020194a:	e4ce                	sd	s3,72(sp)
ffffffffc020194c:	f0a2                	sd	s0,96(sp)
ffffffffc020194e:	eca6                	sd	s1,88(sp)
ffffffffc0201950:	e0d2                	sd	s4,64(sp)
ffffffffc0201952:	fc56                	sd	s5,56(sp)
ffffffffc0201954:	f45e                	sd	s7,40(sp)
ffffffffc0201956:	f062                	sd	s8,32(sp)
ffffffffc0201958:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020195a:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020195e:	f82fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    pmm_manager->init();
ffffffffc0201962:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201966:	000b3997          	auipc	s3,0xb3
ffffffffc020196a:	78a98993          	addi	s3,s3,1930 # ffffffffc02b50f0 <va_pa_offset>
    pmm_manager->init();
ffffffffc020196e:	679c                	ld	a5,8(a5)
ffffffffc0201970:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201972:	57f5                	li	a5,-3
ffffffffc0201974:	07fa                	slli	a5,a5,0x1e
ffffffffc0201976:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc020197a:	f5ffe0ef          	jal	ra,ffffffffc02008d8 <get_memory_base>
ffffffffc020197e:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc0201980:	f63fe0ef          	jal	ra,ffffffffc02008e2 <get_memory_size>
    if (mem_size == 0)
ffffffffc0201984:	200505e3          	beqz	a0,ffffffffc020238e <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0201988:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc020198a:	00005517          	auipc	a0,0x5
ffffffffc020198e:	c2e50513          	addi	a0,a0,-978 # ffffffffc02065b8 <commands+0x900>
ffffffffc0201992:	f4efe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0201996:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020199a:	fff40693          	addi	a3,s0,-1
ffffffffc020199e:	864a                	mv	a2,s2
ffffffffc02019a0:	85a6                	mv	a1,s1
ffffffffc02019a2:	00005517          	auipc	a0,0x5
ffffffffc02019a6:	c2e50513          	addi	a0,a0,-978 # ffffffffc02065d0 <commands+0x918>
ffffffffc02019aa:	f36fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02019ae:	c8000737          	lui	a4,0xc8000
ffffffffc02019b2:	87a2                	mv	a5,s0
ffffffffc02019b4:	54876163          	bltu	a4,s0,ffffffffc0201ef6 <pmm_init+0x5ce>
ffffffffc02019b8:	757d                	lui	a0,0xfffff
ffffffffc02019ba:	000b4617          	auipc	a2,0xb4
ffffffffc02019be:	76960613          	addi	a2,a2,1897 # ffffffffc02b6123 <end+0xfff>
ffffffffc02019c2:	8e69                	and	a2,a2,a0
ffffffffc02019c4:	000b3497          	auipc	s1,0xb3
ffffffffc02019c8:	71448493          	addi	s1,s1,1812 # ffffffffc02b50d8 <npage>
ffffffffc02019cc:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02019d0:	000b3b97          	auipc	s7,0xb3
ffffffffc02019d4:	710b8b93          	addi	s7,s7,1808 # ffffffffc02b50e0 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02019d8:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02019da:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02019de:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02019e2:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02019e4:	02f50863          	beq	a0,a5,ffffffffc0201a14 <pmm_init+0xec>
ffffffffc02019e8:	4781                	li	a5,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02019ea:	4585                	li	a1,1
ffffffffc02019ec:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc02019f0:	00679513          	slli	a0,a5,0x6
ffffffffc02019f4:	9532                	add	a0,a0,a2
ffffffffc02019f6:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd49ee4>
ffffffffc02019fa:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02019fe:	6088                	ld	a0,0(s1)
ffffffffc0201a00:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0201a02:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0201a06:	00d50733          	add	a4,a0,a3
ffffffffc0201a0a:	fee7e3e3          	bltu	a5,a4,ffffffffc02019f0 <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201a0e:	071a                	slli	a4,a4,0x6
ffffffffc0201a10:	00e606b3          	add	a3,a2,a4
ffffffffc0201a14:	c02007b7          	lui	a5,0xc0200
ffffffffc0201a18:	2ef6ece3          	bltu	a3,a5,ffffffffc0202510 <pmm_init+0xbe8>
ffffffffc0201a1c:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0201a20:	77fd                	lui	a5,0xfffff
ffffffffc0201a22:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201a24:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0201a26:	5086eb63          	bltu	a3,s0,ffffffffc0201f3c <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0201a2a:	00005517          	auipc	a0,0x5
ffffffffc0201a2e:	bf650513          	addi	a0,a0,-1034 # ffffffffc0206620 <commands+0x968>
ffffffffc0201a32:	eaefe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0201a36:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0201a3a:	000b3917          	auipc	s2,0xb3
ffffffffc0201a3e:	69690913          	addi	s2,s2,1686 # ffffffffc02b50d0 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc0201a42:	7b9c                	ld	a5,48(a5)
ffffffffc0201a44:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201a46:	00005517          	auipc	a0,0x5
ffffffffc0201a4a:	bf250513          	addi	a0,a0,-1038 # ffffffffc0206638 <commands+0x980>
ffffffffc0201a4e:	e92fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0201a52:	00008697          	auipc	a3,0x8
ffffffffc0201a56:	5ae68693          	addi	a3,a3,1454 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0201a5a:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0201a5e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201a62:	28f6ebe3          	bltu	a3,a5,ffffffffc02024f8 <pmm_init+0xbd0>
ffffffffc0201a66:	0009b783          	ld	a5,0(s3)
ffffffffc0201a6a:	8e9d                	sub	a3,a3,a5
ffffffffc0201a6c:	000b3797          	auipc	a5,0xb3
ffffffffc0201a70:	64d7be23          	sd	a3,1628(a5) # ffffffffc02b50c8 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a74:	100027f3          	csrr	a5,sstatus
ffffffffc0201a78:	8b89                	andi	a5,a5,2
ffffffffc0201a7a:	4a079763          	bnez	a5,ffffffffc0201f28 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201a7e:	000b3783          	ld	a5,0(s6)
ffffffffc0201a82:	779c                	ld	a5,40(a5)
ffffffffc0201a84:	9782                	jalr	a5
ffffffffc0201a86:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201a88:	6098                	ld	a4,0(s1)
ffffffffc0201a8a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201a8e:	83b1                	srli	a5,a5,0xc
ffffffffc0201a90:	66e7e363          	bltu	a5,a4,ffffffffc02020f6 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0201a94:	00093503          	ld	a0,0(s2)
ffffffffc0201a98:	62050f63          	beqz	a0,ffffffffc02020d6 <pmm_init+0x7ae>
ffffffffc0201a9c:	03451793          	slli	a5,a0,0x34
ffffffffc0201aa0:	62079b63          	bnez	a5,ffffffffc02020d6 <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0201aa4:	4601                	li	a2,0
ffffffffc0201aa6:	4581                	li	a1,0
ffffffffc0201aa8:	8c3ff0ef          	jal	ra,ffffffffc020136a <get_page>
ffffffffc0201aac:	60051563          	bnez	a0,ffffffffc02020b6 <pmm_init+0x78e>
ffffffffc0201ab0:	100027f3          	csrr	a5,sstatus
ffffffffc0201ab4:	8b89                	andi	a5,a5,2
ffffffffc0201ab6:	44079e63          	bnez	a5,ffffffffc0201f12 <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201aba:	000b3783          	ld	a5,0(s6)
ffffffffc0201abe:	4505                	li	a0,1
ffffffffc0201ac0:	6f9c                	ld	a5,24(a5)
ffffffffc0201ac2:	9782                	jalr	a5
ffffffffc0201ac4:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0201ac6:	00093503          	ld	a0,0(s2)
ffffffffc0201aca:	4681                	li	a3,0
ffffffffc0201acc:	4601                	li	a2,0
ffffffffc0201ace:	85d2                	mv	a1,s4
ffffffffc0201ad0:	d63ff0ef          	jal	ra,ffffffffc0201832 <page_insert>
ffffffffc0201ad4:	26051ae3          	bnez	a0,ffffffffc0202548 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0201ad8:	00093503          	ld	a0,0(s2)
ffffffffc0201adc:	4601                	li	a2,0
ffffffffc0201ade:	4581                	li	a1,0
ffffffffc0201ae0:	e62ff0ef          	jal	ra,ffffffffc0201142 <get_pte>
ffffffffc0201ae4:	240502e3          	beqz	a0,ffffffffc0202528 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc0201ae8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0201aea:	0017f713          	andi	a4,a5,1
ffffffffc0201aee:	5a070263          	beqz	a4,ffffffffc0202092 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0201af2:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201af4:	078a                	slli	a5,a5,0x2
ffffffffc0201af6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201af8:	58e7fb63          	bgeu	a5,a4,ffffffffc020208e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201afc:	000bb683          	ld	a3,0(s7)
ffffffffc0201b00:	fff80637          	lui	a2,0xfff80
ffffffffc0201b04:	97b2                	add	a5,a5,a2
ffffffffc0201b06:	079a                	slli	a5,a5,0x6
ffffffffc0201b08:	97b6                	add	a5,a5,a3
ffffffffc0201b0a:	14fa17e3          	bne	s4,a5,ffffffffc0202458 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0201b0e:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc0201b12:	4785                	li	a5,1
ffffffffc0201b14:	12f692e3          	bne	a3,a5,ffffffffc0202438 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0201b18:	00093503          	ld	a0,0(s2)
ffffffffc0201b1c:	77fd                	lui	a5,0xfffff
ffffffffc0201b1e:	6114                	ld	a3,0(a0)
ffffffffc0201b20:	068a                	slli	a3,a3,0x2
ffffffffc0201b22:	8efd                	and	a3,a3,a5
ffffffffc0201b24:	00c6d613          	srli	a2,a3,0xc
ffffffffc0201b28:	0ee67ce3          	bgeu	a2,a4,ffffffffc0202420 <pmm_init+0xaf8>
ffffffffc0201b2c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201b30:	96e2                	add	a3,a3,s8
ffffffffc0201b32:	0006ba83          	ld	s5,0(a3)
ffffffffc0201b36:	0a8a                	slli	s5,s5,0x2
ffffffffc0201b38:	00fafab3          	and	s5,s5,a5
ffffffffc0201b3c:	00cad793          	srli	a5,s5,0xc
ffffffffc0201b40:	0ce7f3e3          	bgeu	a5,a4,ffffffffc0202406 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0201b44:	4601                	li	a2,0
ffffffffc0201b46:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201b48:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0201b4a:	df8ff0ef          	jal	ra,ffffffffc0201142 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201b4e:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0201b50:	55551363          	bne	a0,s5,ffffffffc0202096 <pmm_init+0x76e>
ffffffffc0201b54:	100027f3          	csrr	a5,sstatus
ffffffffc0201b58:	8b89                	andi	a5,a5,2
ffffffffc0201b5a:	3a079163          	bnez	a5,ffffffffc0201efc <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201b5e:	000b3783          	ld	a5,0(s6)
ffffffffc0201b62:	4505                	li	a0,1
ffffffffc0201b64:	6f9c                	ld	a5,24(a5)
ffffffffc0201b66:	9782                	jalr	a5
ffffffffc0201b68:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201b6a:	00093503          	ld	a0,0(s2)
ffffffffc0201b6e:	46d1                	li	a3,20
ffffffffc0201b70:	6605                	lui	a2,0x1
ffffffffc0201b72:	85e2                	mv	a1,s8
ffffffffc0201b74:	cbfff0ef          	jal	ra,ffffffffc0201832 <page_insert>
ffffffffc0201b78:	060517e3          	bnez	a0,ffffffffc02023e6 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0201b7c:	00093503          	ld	a0,0(s2)
ffffffffc0201b80:	4601                	li	a2,0
ffffffffc0201b82:	6585                	lui	a1,0x1
ffffffffc0201b84:	dbeff0ef          	jal	ra,ffffffffc0201142 <get_pte>
ffffffffc0201b88:	02050fe3          	beqz	a0,ffffffffc02023c6 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc0201b8c:	611c                	ld	a5,0(a0)
ffffffffc0201b8e:	0107f713          	andi	a4,a5,16
ffffffffc0201b92:	7c070e63          	beqz	a4,ffffffffc020236e <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc0201b96:	8b91                	andi	a5,a5,4
ffffffffc0201b98:	7a078b63          	beqz	a5,ffffffffc020234e <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0201b9c:	00093503          	ld	a0,0(s2)
ffffffffc0201ba0:	611c                	ld	a5,0(a0)
ffffffffc0201ba2:	8bc1                	andi	a5,a5,16
ffffffffc0201ba4:	78078563          	beqz	a5,ffffffffc020232e <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc0201ba8:	000c2703          	lw	a4,0(s8)
ffffffffc0201bac:	4785                	li	a5,1
ffffffffc0201bae:	76f71063          	bne	a4,a5,ffffffffc020230e <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0201bb2:	4681                	li	a3,0
ffffffffc0201bb4:	6605                	lui	a2,0x1
ffffffffc0201bb6:	85d2                	mv	a1,s4
ffffffffc0201bb8:	c7bff0ef          	jal	ra,ffffffffc0201832 <page_insert>
ffffffffc0201bbc:	72051963          	bnez	a0,ffffffffc02022ee <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc0201bc0:	000a2703          	lw	a4,0(s4)
ffffffffc0201bc4:	4789                	li	a5,2
ffffffffc0201bc6:	70f71463          	bne	a4,a5,ffffffffc02022ce <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc0201bca:	000c2783          	lw	a5,0(s8)
ffffffffc0201bce:	6e079063          	bnez	a5,ffffffffc02022ae <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0201bd2:	00093503          	ld	a0,0(s2)
ffffffffc0201bd6:	4601                	li	a2,0
ffffffffc0201bd8:	6585                	lui	a1,0x1
ffffffffc0201bda:	d68ff0ef          	jal	ra,ffffffffc0201142 <get_pte>
ffffffffc0201bde:	6a050863          	beqz	a0,ffffffffc020228e <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc0201be2:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0201be4:	00177793          	andi	a5,a4,1
ffffffffc0201be8:	4a078563          	beqz	a5,ffffffffc0202092 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0201bec:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201bee:	00271793          	slli	a5,a4,0x2
ffffffffc0201bf2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201bf4:	48d7fd63          	bgeu	a5,a3,ffffffffc020208e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bf8:	000bb683          	ld	a3,0(s7)
ffffffffc0201bfc:	fff80ab7          	lui	s5,0xfff80
ffffffffc0201c00:	97d6                	add	a5,a5,s5
ffffffffc0201c02:	079a                	slli	a5,a5,0x6
ffffffffc0201c04:	97b6                	add	a5,a5,a3
ffffffffc0201c06:	66fa1463          	bne	s4,a5,ffffffffc020226e <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201c0a:	8b41                	andi	a4,a4,16
ffffffffc0201c0c:	64071163          	bnez	a4,ffffffffc020224e <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0201c10:	00093503          	ld	a0,0(s2)
ffffffffc0201c14:	4581                	li	a1,0
ffffffffc0201c16:	b81ff0ef          	jal	ra,ffffffffc0201796 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201c1a:	000a2c83          	lw	s9,0(s4)
ffffffffc0201c1e:	4785                	li	a5,1
ffffffffc0201c20:	60fc9763          	bne	s9,a5,ffffffffc020222e <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc0201c24:	000c2783          	lw	a5,0(s8)
ffffffffc0201c28:	5e079363          	bnez	a5,ffffffffc020220e <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0201c2c:	00093503          	ld	a0,0(s2)
ffffffffc0201c30:	6585                	lui	a1,0x1
ffffffffc0201c32:	b65ff0ef          	jal	ra,ffffffffc0201796 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201c36:	000a2783          	lw	a5,0(s4)
ffffffffc0201c3a:	52079a63          	bnez	a5,ffffffffc020216e <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0201c3e:	000c2783          	lw	a5,0(s8)
ffffffffc0201c42:	50079663          	bnez	a5,ffffffffc020214e <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0201c46:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0201c4a:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c4c:	000a3683          	ld	a3,0(s4)
ffffffffc0201c50:	068a                	slli	a3,a3,0x2
ffffffffc0201c52:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0201c54:	42b6fd63          	bgeu	a3,a1,ffffffffc020208e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c58:	000bb503          	ld	a0,0(s7)
ffffffffc0201c5c:	96d6                	add	a3,a3,s5
ffffffffc0201c5e:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0201c60:	00d507b3          	add	a5,a0,a3
ffffffffc0201c64:	439c                	lw	a5,0(a5)
ffffffffc0201c66:	4d979463          	bne	a5,s9,ffffffffc020212e <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc0201c6a:	8699                	srai	a3,a3,0x6
ffffffffc0201c6c:	00080637          	lui	a2,0x80
ffffffffc0201c70:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0201c72:	00c69713          	slli	a4,a3,0xc
ffffffffc0201c76:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c78:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201c7a:	48b77e63          	bgeu	a4,a1,ffffffffc0202116 <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201c7e:	0009b703          	ld	a4,0(s3)
ffffffffc0201c82:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201c84:	629c                	ld	a5,0(a3)
ffffffffc0201c86:	078a                	slli	a5,a5,0x2
ffffffffc0201c88:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201c8a:	40b7f263          	bgeu	a5,a1,ffffffffc020208e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c8e:	8f91                	sub	a5,a5,a2
ffffffffc0201c90:	079a                	slli	a5,a5,0x6
ffffffffc0201c92:	953e                	add	a0,a0,a5
ffffffffc0201c94:	100027f3          	csrr	a5,sstatus
ffffffffc0201c98:	8b89                	andi	a5,a5,2
ffffffffc0201c9a:	30079963          	bnez	a5,ffffffffc0201fac <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc0201c9e:	000b3783          	ld	a5,0(s6)
ffffffffc0201ca2:	4585                	li	a1,1
ffffffffc0201ca4:	739c                	ld	a5,32(a5)
ffffffffc0201ca6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ca8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0201cac:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201cae:	078a                	slli	a5,a5,0x2
ffffffffc0201cb0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201cb2:	3ce7fe63          	bgeu	a5,a4,ffffffffc020208e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cb6:	000bb503          	ld	a0,0(s7)
ffffffffc0201cba:	fff80737          	lui	a4,0xfff80
ffffffffc0201cbe:	97ba                	add	a5,a5,a4
ffffffffc0201cc0:	079a                	slli	a5,a5,0x6
ffffffffc0201cc2:	953e                	add	a0,a0,a5
ffffffffc0201cc4:	100027f3          	csrr	a5,sstatus
ffffffffc0201cc8:	8b89                	andi	a5,a5,2
ffffffffc0201cca:	2c079563          	bnez	a5,ffffffffc0201f94 <pmm_init+0x66c>
ffffffffc0201cce:	000b3783          	ld	a5,0(s6)
ffffffffc0201cd2:	4585                	li	a1,1
ffffffffc0201cd4:	739c                	ld	a5,32(a5)
ffffffffc0201cd6:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0201cd8:	00093783          	ld	a5,0(s2)
ffffffffc0201cdc:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd49edc>
    asm volatile("sfence.vma");
ffffffffc0201ce0:	12000073          	sfence.vma
ffffffffc0201ce4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ce8:	8b89                	andi	a5,a5,2
ffffffffc0201cea:	28079b63          	bnez	a5,ffffffffc0201f80 <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201cee:	000b3783          	ld	a5,0(s6)
ffffffffc0201cf2:	779c                	ld	a5,40(a5)
ffffffffc0201cf4:	9782                	jalr	a5
ffffffffc0201cf6:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0201cf8:	4b441b63          	bne	s0,s4,ffffffffc02021ae <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201cfc:	00005517          	auipc	a0,0x5
ffffffffc0201d00:	c6450513          	addi	a0,a0,-924 # ffffffffc0206960 <commands+0xca8>
ffffffffc0201d04:	bdcfe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0201d08:	100027f3          	csrr	a5,sstatus
ffffffffc0201d0c:	8b89                	andi	a5,a5,2
ffffffffc0201d0e:	24079f63          	bnez	a5,ffffffffc0201f6c <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d12:	000b3783          	ld	a5,0(s6)
ffffffffc0201d16:	779c                	ld	a5,40(a5)
ffffffffc0201d18:	9782                	jalr	a5
ffffffffc0201d1a:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0201d1c:	6098                	ld	a4,0(s1)
ffffffffc0201d1e:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201d22:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0201d24:	00c71793          	slli	a5,a4,0xc
ffffffffc0201d28:	6a05                	lui	s4,0x1
ffffffffc0201d2a:	02f47c63          	bgeu	s0,a5,ffffffffc0201d62 <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201d2e:	00c45793          	srli	a5,s0,0xc
ffffffffc0201d32:	00093503          	ld	a0,0(s2)
ffffffffc0201d36:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202034 <pmm_init+0x70c>
ffffffffc0201d3a:	0009b583          	ld	a1,0(s3)
ffffffffc0201d3e:	4601                	li	a2,0
ffffffffc0201d40:	95a2                	add	a1,a1,s0
ffffffffc0201d42:	c00ff0ef          	jal	ra,ffffffffc0201142 <get_pte>
ffffffffc0201d46:	32050463          	beqz	a0,ffffffffc020206e <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201d4a:	611c                	ld	a5,0(a0)
ffffffffc0201d4c:	078a                	slli	a5,a5,0x2
ffffffffc0201d4e:	0157f7b3          	and	a5,a5,s5
ffffffffc0201d52:	2e879e63          	bne	a5,s0,ffffffffc020204e <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0201d56:	6098                	ld	a4,0(s1)
ffffffffc0201d58:	9452                	add	s0,s0,s4
ffffffffc0201d5a:	00c71793          	slli	a5,a4,0xc
ffffffffc0201d5e:	fcf468e3          	bltu	s0,a5,ffffffffc0201d2e <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0201d62:	00093783          	ld	a5,0(s2)
ffffffffc0201d66:	639c                	ld	a5,0(a5)
ffffffffc0201d68:	42079363          	bnez	a5,ffffffffc020218e <pmm_init+0x866>
ffffffffc0201d6c:	100027f3          	csrr	a5,sstatus
ffffffffc0201d70:	8b89                	andi	a5,a5,2
ffffffffc0201d72:	24079963          	bnez	a5,ffffffffc0201fc4 <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201d76:	000b3783          	ld	a5,0(s6)
ffffffffc0201d7a:	4505                	li	a0,1
ffffffffc0201d7c:	6f9c                	ld	a5,24(a5)
ffffffffc0201d7e:	9782                	jalr	a5
ffffffffc0201d80:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201d82:	00093503          	ld	a0,0(s2)
ffffffffc0201d86:	4699                	li	a3,6
ffffffffc0201d88:	10000613          	li	a2,256
ffffffffc0201d8c:	85d2                	mv	a1,s4
ffffffffc0201d8e:	aa5ff0ef          	jal	ra,ffffffffc0201832 <page_insert>
ffffffffc0201d92:	44051e63          	bnez	a0,ffffffffc02021ee <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0201d96:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc0201d9a:	4785                	li	a5,1
ffffffffc0201d9c:	42f71963          	bne	a4,a5,ffffffffc02021ce <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201da0:	00093503          	ld	a0,0(s2)
ffffffffc0201da4:	6405                	lui	s0,0x1
ffffffffc0201da6:	4699                	li	a3,6
ffffffffc0201da8:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ab8>
ffffffffc0201dac:	85d2                	mv	a1,s4
ffffffffc0201dae:	a85ff0ef          	jal	ra,ffffffffc0201832 <page_insert>
ffffffffc0201db2:	72051363          	bnez	a0,ffffffffc02024d8 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0201db6:	000a2703          	lw	a4,0(s4)
ffffffffc0201dba:	4789                	li	a5,2
ffffffffc0201dbc:	6ef71e63          	bne	a4,a5,ffffffffc02024b8 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201dc0:	00005597          	auipc	a1,0x5
ffffffffc0201dc4:	ce858593          	addi	a1,a1,-792 # ffffffffc0206aa8 <commands+0xdf0>
ffffffffc0201dc8:	10000513          	li	a0,256
ffffffffc0201dcc:	7a6030ef          	jal	ra,ffffffffc0205572 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201dd0:	10040593          	addi	a1,s0,256
ffffffffc0201dd4:	10000513          	li	a0,256
ffffffffc0201dd8:	7ac030ef          	jal	ra,ffffffffc0205584 <strcmp>
ffffffffc0201ddc:	6a051e63          	bnez	a0,ffffffffc0202498 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0201de0:	000bb683          	ld	a3,0(s7)
ffffffffc0201de4:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201de8:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0201dea:	40da06b3          	sub	a3,s4,a3
ffffffffc0201dee:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201df0:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201df2:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201df4:	8031                	srli	s0,s0,0xc
ffffffffc0201df6:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dfa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201dfc:	30f77d63          	bgeu	a4,a5,ffffffffc0202116 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201e00:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201e04:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201e08:	96be                	add	a3,a3,a5
ffffffffc0201e0a:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201e0e:	72e030ef          	jal	ra,ffffffffc020553c <strlen>
ffffffffc0201e12:	66051363          	bnez	a0,ffffffffc0202478 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0201e16:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0201e1a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e1c:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd49edc>
ffffffffc0201e20:	068a                	slli	a3,a3,0x2
ffffffffc0201e22:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0201e24:	26f6f563          	bgeu	a3,a5,ffffffffc020208e <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0201e28:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e2a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201e2c:	2ef47563          	bgeu	s0,a5,ffffffffc0202116 <pmm_init+0x7ee>
ffffffffc0201e30:	0009b403          	ld	s0,0(s3)
ffffffffc0201e34:	9436                	add	s0,s0,a3
ffffffffc0201e36:	100027f3          	csrr	a5,sstatus
ffffffffc0201e3a:	8b89                	andi	a5,a5,2
ffffffffc0201e3c:	1e079163          	bnez	a5,ffffffffc020201e <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0201e40:	000b3783          	ld	a5,0(s6)
ffffffffc0201e44:	4585                	li	a1,1
ffffffffc0201e46:	8552                	mv	a0,s4
ffffffffc0201e48:	739c                	ld	a5,32(a5)
ffffffffc0201e4a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e4c:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0201e4e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e50:	078a                	slli	a5,a5,0x2
ffffffffc0201e52:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201e54:	22e7fd63          	bgeu	a5,a4,ffffffffc020208e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e58:	000bb503          	ld	a0,0(s7)
ffffffffc0201e5c:	fff80737          	lui	a4,0xfff80
ffffffffc0201e60:	97ba                	add	a5,a5,a4
ffffffffc0201e62:	079a                	slli	a5,a5,0x6
ffffffffc0201e64:	953e                	add	a0,a0,a5
ffffffffc0201e66:	100027f3          	csrr	a5,sstatus
ffffffffc0201e6a:	8b89                	andi	a5,a5,2
ffffffffc0201e6c:	18079d63          	bnez	a5,ffffffffc0202006 <pmm_init+0x6de>
ffffffffc0201e70:	000b3783          	ld	a5,0(s6)
ffffffffc0201e74:	4585                	li	a1,1
ffffffffc0201e76:	739c                	ld	a5,32(a5)
ffffffffc0201e78:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e7a:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0201e7e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e80:	078a                	slli	a5,a5,0x2
ffffffffc0201e82:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201e84:	20e7f563          	bgeu	a5,a4,ffffffffc020208e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e88:	000bb503          	ld	a0,0(s7)
ffffffffc0201e8c:	fff80737          	lui	a4,0xfff80
ffffffffc0201e90:	97ba                	add	a5,a5,a4
ffffffffc0201e92:	079a                	slli	a5,a5,0x6
ffffffffc0201e94:	953e                	add	a0,a0,a5
ffffffffc0201e96:	100027f3          	csrr	a5,sstatus
ffffffffc0201e9a:	8b89                	andi	a5,a5,2
ffffffffc0201e9c:	14079963          	bnez	a5,ffffffffc0201fee <pmm_init+0x6c6>
ffffffffc0201ea0:	000b3783          	ld	a5,0(s6)
ffffffffc0201ea4:	4585                	li	a1,1
ffffffffc0201ea6:	739c                	ld	a5,32(a5)
ffffffffc0201ea8:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0201eaa:	00093783          	ld	a5,0(s2)
ffffffffc0201eae:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0201eb2:	12000073          	sfence.vma
ffffffffc0201eb6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eba:	8b89                	andi	a5,a5,2
ffffffffc0201ebc:	10079f63          	bnez	a5,ffffffffc0201fda <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201ec0:	000b3783          	ld	a5,0(s6)
ffffffffc0201ec4:	779c                	ld	a5,40(a5)
ffffffffc0201ec6:	9782                	jalr	a5
ffffffffc0201ec8:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0201eca:	4c8c1e63          	bne	s8,s0,ffffffffc02023a6 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201ece:	00005517          	auipc	a0,0x5
ffffffffc0201ed2:	c5250513          	addi	a0,a0,-942 # ffffffffc0206b20 <commands+0xe68>
ffffffffc0201ed6:	a0afe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc0201eda:	7406                	ld	s0,96(sp)
ffffffffc0201edc:	70a6                	ld	ra,104(sp)
ffffffffc0201ede:	64e6                	ld	s1,88(sp)
ffffffffc0201ee0:	6946                	ld	s2,80(sp)
ffffffffc0201ee2:	69a6                	ld	s3,72(sp)
ffffffffc0201ee4:	6a06                	ld	s4,64(sp)
ffffffffc0201ee6:	7ae2                	ld	s5,56(sp)
ffffffffc0201ee8:	7b42                	ld	s6,48(sp)
ffffffffc0201eea:	7ba2                	ld	s7,40(sp)
ffffffffc0201eec:	7c02                	ld	s8,32(sp)
ffffffffc0201eee:	6ce2                	ld	s9,24(sp)
ffffffffc0201ef0:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0201ef2:	5960106f          	j	ffffffffc0203488 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0201ef6:	c80007b7          	lui	a5,0xc8000
ffffffffc0201efa:	bc7d                	j	ffffffffc02019b8 <pmm_init+0x90>
        intr_disable();
ffffffffc0201efc:	abffe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f00:	000b3783          	ld	a5,0(s6)
ffffffffc0201f04:	4505                	li	a0,1
ffffffffc0201f06:	6f9c                	ld	a5,24(a5)
ffffffffc0201f08:	9782                	jalr	a5
ffffffffc0201f0a:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0201f0c:	aa9fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201f10:	b9a9                	j	ffffffffc0201b6a <pmm_init+0x242>
        intr_disable();
ffffffffc0201f12:	aa9fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0201f16:	000b3783          	ld	a5,0(s6)
ffffffffc0201f1a:	4505                	li	a0,1
ffffffffc0201f1c:	6f9c                	ld	a5,24(a5)
ffffffffc0201f1e:	9782                	jalr	a5
ffffffffc0201f20:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0201f22:	a93fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201f26:	b645                	j	ffffffffc0201ac6 <pmm_init+0x19e>
        intr_disable();
ffffffffc0201f28:	a93fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f2c:	000b3783          	ld	a5,0(s6)
ffffffffc0201f30:	779c                	ld	a5,40(a5)
ffffffffc0201f32:	9782                	jalr	a5
ffffffffc0201f34:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f36:	a7ffe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201f3a:	b6b9                	j	ffffffffc0201a88 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201f3c:	6705                	lui	a4,0x1
ffffffffc0201f3e:	177d                	addi	a4,a4,-1
ffffffffc0201f40:	96ba                	add	a3,a3,a4
ffffffffc0201f42:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0201f44:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201f48:	14a77363          	bgeu	a4,a0,ffffffffc020208e <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0201f4c:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0201f50:	fff80537          	lui	a0,0xfff80
ffffffffc0201f54:	972a                	add	a4,a4,a0
ffffffffc0201f56:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201f58:	8c1d                	sub	s0,s0,a5
ffffffffc0201f5a:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0201f5e:	00c45593          	srli	a1,s0,0xc
ffffffffc0201f62:	9532                	add	a0,a0,a2
ffffffffc0201f64:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0201f66:	0009b583          	ld	a1,0(s3)
}
ffffffffc0201f6a:	b4c1                	j	ffffffffc0201a2a <pmm_init+0x102>
        intr_disable();
ffffffffc0201f6c:	a4ffe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f70:	000b3783          	ld	a5,0(s6)
ffffffffc0201f74:	779c                	ld	a5,40(a5)
ffffffffc0201f76:	9782                	jalr	a5
ffffffffc0201f78:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0201f7a:	a3bfe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201f7e:	bb79                	j	ffffffffc0201d1c <pmm_init+0x3f4>
        intr_disable();
ffffffffc0201f80:	a3bfe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0201f84:	000b3783          	ld	a5,0(s6)
ffffffffc0201f88:	779c                	ld	a5,40(a5)
ffffffffc0201f8a:	9782                	jalr	a5
ffffffffc0201f8c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0201f8e:	a27fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201f92:	b39d                	j	ffffffffc0201cf8 <pmm_init+0x3d0>
ffffffffc0201f94:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201f96:	a25fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f9a:	000b3783          	ld	a5,0(s6)
ffffffffc0201f9e:	6522                	ld	a0,8(sp)
ffffffffc0201fa0:	4585                	li	a1,1
ffffffffc0201fa2:	739c                	ld	a5,32(a5)
ffffffffc0201fa4:	9782                	jalr	a5
        intr_enable();
ffffffffc0201fa6:	a0ffe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201faa:	b33d                	j	ffffffffc0201cd8 <pmm_init+0x3b0>
ffffffffc0201fac:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201fae:	a0dfe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0201fb2:	000b3783          	ld	a5,0(s6)
ffffffffc0201fb6:	6522                	ld	a0,8(sp)
ffffffffc0201fb8:	4585                	li	a1,1
ffffffffc0201fba:	739c                	ld	a5,32(a5)
ffffffffc0201fbc:	9782                	jalr	a5
        intr_enable();
ffffffffc0201fbe:	9f7fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201fc2:	b1dd                	j	ffffffffc0201ca8 <pmm_init+0x380>
        intr_disable();
ffffffffc0201fc4:	9f7fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201fc8:	000b3783          	ld	a5,0(s6)
ffffffffc0201fcc:	4505                	li	a0,1
ffffffffc0201fce:	6f9c                	ld	a5,24(a5)
ffffffffc0201fd0:	9782                	jalr	a5
ffffffffc0201fd2:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0201fd4:	9e1fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201fd8:	b36d                	j	ffffffffc0201d82 <pmm_init+0x45a>
        intr_disable();
ffffffffc0201fda:	9e1fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201fde:	000b3783          	ld	a5,0(s6)
ffffffffc0201fe2:	779c                	ld	a5,40(a5)
ffffffffc0201fe4:	9782                	jalr	a5
ffffffffc0201fe6:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201fe8:	9cdfe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201fec:	bdf9                	j	ffffffffc0201eca <pmm_init+0x5a2>
ffffffffc0201fee:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201ff0:	9cbfe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201ff4:	000b3783          	ld	a5,0(s6)
ffffffffc0201ff8:	6522                	ld	a0,8(sp)
ffffffffc0201ffa:	4585                	li	a1,1
ffffffffc0201ffc:	739c                	ld	a5,32(a5)
ffffffffc0201ffe:	9782                	jalr	a5
        intr_enable();
ffffffffc0202000:	9b5fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0202004:	b55d                	j	ffffffffc0201eaa <pmm_init+0x582>
ffffffffc0202006:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202008:	9b3fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc020200c:	000b3783          	ld	a5,0(s6)
ffffffffc0202010:	6522                	ld	a0,8(sp)
ffffffffc0202012:	4585                	li	a1,1
ffffffffc0202014:	739c                	ld	a5,32(a5)
ffffffffc0202016:	9782                	jalr	a5
        intr_enable();
ffffffffc0202018:	99dfe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc020201c:	bdb9                	j	ffffffffc0201e7a <pmm_init+0x552>
        intr_disable();
ffffffffc020201e:	99dfe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0202022:	000b3783          	ld	a5,0(s6)
ffffffffc0202026:	4585                	li	a1,1
ffffffffc0202028:	8552                	mv	a0,s4
ffffffffc020202a:	739c                	ld	a5,32(a5)
ffffffffc020202c:	9782                	jalr	a5
        intr_enable();
ffffffffc020202e:	987fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0202032:	bd29                	j	ffffffffc0201e4c <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202034:	86a2                	mv	a3,s0
ffffffffc0202036:	00004617          	auipc	a2,0x4
ffffffffc020203a:	4b260613          	addi	a2,a2,1202 # ffffffffc02064e8 <commands+0x830>
ffffffffc020203e:	24400593          	li	a1,580
ffffffffc0202042:	00004517          	auipc	a0,0x4
ffffffffc0202046:	4ce50513          	addi	a0,a0,1230 # ffffffffc0206510 <commands+0x858>
ffffffffc020204a:	9d4fe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020204e:	00005697          	auipc	a3,0x5
ffffffffc0202052:	97268693          	addi	a3,a3,-1678 # ffffffffc02069c0 <commands+0xd08>
ffffffffc0202056:	00004617          	auipc	a2,0x4
ffffffffc020205a:	4fa60613          	addi	a2,a2,1274 # ffffffffc0206550 <commands+0x898>
ffffffffc020205e:	24500593          	li	a1,581
ffffffffc0202062:	00004517          	auipc	a0,0x4
ffffffffc0202066:	4ae50513          	addi	a0,a0,1198 # ffffffffc0206510 <commands+0x858>
ffffffffc020206a:	9b4fe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020206e:	00005697          	auipc	a3,0x5
ffffffffc0202072:	91268693          	addi	a3,a3,-1774 # ffffffffc0206980 <commands+0xcc8>
ffffffffc0202076:	00004617          	auipc	a2,0x4
ffffffffc020207a:	4da60613          	addi	a2,a2,1242 # ffffffffc0206550 <commands+0x898>
ffffffffc020207e:	24400593          	li	a1,580
ffffffffc0202082:	00004517          	auipc	a0,0x4
ffffffffc0202086:	48e50513          	addi	a0,a0,1166 # ffffffffc0206510 <commands+0x858>
ffffffffc020208a:	994fe0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc020208e:	fc5fe0ef          	jal	ra,ffffffffc0201052 <pa2page.part.0>
ffffffffc0202092:	fddfe0ef          	jal	ra,ffffffffc020106e <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202096:	00004697          	auipc	a3,0x4
ffffffffc020209a:	6e268693          	addi	a3,a3,1762 # ffffffffc0206778 <commands+0xac0>
ffffffffc020209e:	00004617          	auipc	a2,0x4
ffffffffc02020a2:	4b260613          	addi	a2,a2,1202 # ffffffffc0206550 <commands+0x898>
ffffffffc02020a6:	21400593          	li	a1,532
ffffffffc02020aa:	00004517          	auipc	a0,0x4
ffffffffc02020ae:	46650513          	addi	a0,a0,1126 # ffffffffc0206510 <commands+0x858>
ffffffffc02020b2:	96cfe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02020b6:	00004697          	auipc	a3,0x4
ffffffffc02020ba:	60268693          	addi	a3,a3,1538 # ffffffffc02066b8 <commands+0xa00>
ffffffffc02020be:	00004617          	auipc	a2,0x4
ffffffffc02020c2:	49260613          	addi	a2,a2,1170 # ffffffffc0206550 <commands+0x898>
ffffffffc02020c6:	20700593          	li	a1,519
ffffffffc02020ca:	00004517          	auipc	a0,0x4
ffffffffc02020ce:	44650513          	addi	a0,a0,1094 # ffffffffc0206510 <commands+0x858>
ffffffffc02020d2:	94cfe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02020d6:	00004697          	auipc	a3,0x4
ffffffffc02020da:	5a268693          	addi	a3,a3,1442 # ffffffffc0206678 <commands+0x9c0>
ffffffffc02020de:	00004617          	auipc	a2,0x4
ffffffffc02020e2:	47260613          	addi	a2,a2,1138 # ffffffffc0206550 <commands+0x898>
ffffffffc02020e6:	20600593          	li	a1,518
ffffffffc02020ea:	00004517          	auipc	a0,0x4
ffffffffc02020ee:	42650513          	addi	a0,a0,1062 # ffffffffc0206510 <commands+0x858>
ffffffffc02020f2:	92cfe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02020f6:	00004697          	auipc	a3,0x4
ffffffffc02020fa:	56268693          	addi	a3,a3,1378 # ffffffffc0206658 <commands+0x9a0>
ffffffffc02020fe:	00004617          	auipc	a2,0x4
ffffffffc0202102:	45260613          	addi	a2,a2,1106 # ffffffffc0206550 <commands+0x898>
ffffffffc0202106:	20500593          	li	a1,517
ffffffffc020210a:	00004517          	auipc	a0,0x4
ffffffffc020210e:	40650513          	addi	a0,a0,1030 # ffffffffc0206510 <commands+0x858>
ffffffffc0202112:	90cfe0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202116:	00004617          	auipc	a2,0x4
ffffffffc020211a:	3d260613          	addi	a2,a2,978 # ffffffffc02064e8 <commands+0x830>
ffffffffc020211e:	07100593          	li	a1,113
ffffffffc0202122:	00004517          	auipc	a0,0x4
ffffffffc0202126:	38e50513          	addi	a0,a0,910 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc020212a:	8f4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc020212e:	00004697          	auipc	a3,0x4
ffffffffc0202132:	7da68693          	addi	a3,a3,2010 # ffffffffc0206908 <commands+0xc50>
ffffffffc0202136:	00004617          	auipc	a2,0x4
ffffffffc020213a:	41a60613          	addi	a2,a2,1050 # ffffffffc0206550 <commands+0x898>
ffffffffc020213e:	22d00593          	li	a1,557
ffffffffc0202142:	00004517          	auipc	a0,0x4
ffffffffc0202146:	3ce50513          	addi	a0,a0,974 # ffffffffc0206510 <commands+0x858>
ffffffffc020214a:	8d4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020214e:	00004697          	auipc	a3,0x4
ffffffffc0202152:	77268693          	addi	a3,a3,1906 # ffffffffc02068c0 <commands+0xc08>
ffffffffc0202156:	00004617          	auipc	a2,0x4
ffffffffc020215a:	3fa60613          	addi	a2,a2,1018 # ffffffffc0206550 <commands+0x898>
ffffffffc020215e:	22b00593          	li	a1,555
ffffffffc0202162:	00004517          	auipc	a0,0x4
ffffffffc0202166:	3ae50513          	addi	a0,a0,942 # ffffffffc0206510 <commands+0x858>
ffffffffc020216a:	8b4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020216e:	00004697          	auipc	a3,0x4
ffffffffc0202172:	78268693          	addi	a3,a3,1922 # ffffffffc02068f0 <commands+0xc38>
ffffffffc0202176:	00004617          	auipc	a2,0x4
ffffffffc020217a:	3da60613          	addi	a2,a2,986 # ffffffffc0206550 <commands+0x898>
ffffffffc020217e:	22a00593          	li	a1,554
ffffffffc0202182:	00004517          	auipc	a0,0x4
ffffffffc0202186:	38e50513          	addi	a0,a0,910 # ffffffffc0206510 <commands+0x858>
ffffffffc020218a:	894fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc020218e:	00005697          	auipc	a3,0x5
ffffffffc0202192:	84a68693          	addi	a3,a3,-1974 # ffffffffc02069d8 <commands+0xd20>
ffffffffc0202196:	00004617          	auipc	a2,0x4
ffffffffc020219a:	3ba60613          	addi	a2,a2,954 # ffffffffc0206550 <commands+0x898>
ffffffffc020219e:	24800593          	li	a1,584
ffffffffc02021a2:	00004517          	auipc	a0,0x4
ffffffffc02021a6:	36e50513          	addi	a0,a0,878 # ffffffffc0206510 <commands+0x858>
ffffffffc02021aa:	874fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02021ae:	00004697          	auipc	a3,0x4
ffffffffc02021b2:	78a68693          	addi	a3,a3,1930 # ffffffffc0206938 <commands+0xc80>
ffffffffc02021b6:	00004617          	auipc	a2,0x4
ffffffffc02021ba:	39a60613          	addi	a2,a2,922 # ffffffffc0206550 <commands+0x898>
ffffffffc02021be:	23500593          	li	a1,565
ffffffffc02021c2:	00004517          	auipc	a0,0x4
ffffffffc02021c6:	34e50513          	addi	a0,a0,846 # ffffffffc0206510 <commands+0x858>
ffffffffc02021ca:	854fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p) == 1);
ffffffffc02021ce:	00005697          	auipc	a3,0x5
ffffffffc02021d2:	86268693          	addi	a3,a3,-1950 # ffffffffc0206a30 <commands+0xd78>
ffffffffc02021d6:	00004617          	auipc	a2,0x4
ffffffffc02021da:	37a60613          	addi	a2,a2,890 # ffffffffc0206550 <commands+0x898>
ffffffffc02021de:	24d00593          	li	a1,589
ffffffffc02021e2:	00004517          	auipc	a0,0x4
ffffffffc02021e6:	32e50513          	addi	a0,a0,814 # ffffffffc0206510 <commands+0x858>
ffffffffc02021ea:	834fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02021ee:	00005697          	auipc	a3,0x5
ffffffffc02021f2:	80268693          	addi	a3,a3,-2046 # ffffffffc02069f0 <commands+0xd38>
ffffffffc02021f6:	00004617          	auipc	a2,0x4
ffffffffc02021fa:	35a60613          	addi	a2,a2,858 # ffffffffc0206550 <commands+0x898>
ffffffffc02021fe:	24c00593          	li	a1,588
ffffffffc0202202:	00004517          	auipc	a0,0x4
ffffffffc0202206:	30e50513          	addi	a0,a0,782 # ffffffffc0206510 <commands+0x858>
ffffffffc020220a:	814fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020220e:	00004697          	auipc	a3,0x4
ffffffffc0202212:	6b268693          	addi	a3,a3,1714 # ffffffffc02068c0 <commands+0xc08>
ffffffffc0202216:	00004617          	auipc	a2,0x4
ffffffffc020221a:	33a60613          	addi	a2,a2,826 # ffffffffc0206550 <commands+0x898>
ffffffffc020221e:	22700593          	li	a1,551
ffffffffc0202222:	00004517          	auipc	a0,0x4
ffffffffc0202226:	2ee50513          	addi	a0,a0,750 # ffffffffc0206510 <commands+0x858>
ffffffffc020222a:	ff5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020222e:	00004697          	auipc	a3,0x4
ffffffffc0202232:	53268693          	addi	a3,a3,1330 # ffffffffc0206760 <commands+0xaa8>
ffffffffc0202236:	00004617          	auipc	a2,0x4
ffffffffc020223a:	31a60613          	addi	a2,a2,794 # ffffffffc0206550 <commands+0x898>
ffffffffc020223e:	22600593          	li	a1,550
ffffffffc0202242:	00004517          	auipc	a0,0x4
ffffffffc0202246:	2ce50513          	addi	a0,a0,718 # ffffffffc0206510 <commands+0x858>
ffffffffc020224a:	fd5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020224e:	00004697          	auipc	a3,0x4
ffffffffc0202252:	68a68693          	addi	a3,a3,1674 # ffffffffc02068d8 <commands+0xc20>
ffffffffc0202256:	00004617          	auipc	a2,0x4
ffffffffc020225a:	2fa60613          	addi	a2,a2,762 # ffffffffc0206550 <commands+0x898>
ffffffffc020225e:	22300593          	li	a1,547
ffffffffc0202262:	00004517          	auipc	a0,0x4
ffffffffc0202266:	2ae50513          	addi	a0,a0,686 # ffffffffc0206510 <commands+0x858>
ffffffffc020226a:	fb5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020226e:	00004697          	auipc	a3,0x4
ffffffffc0202272:	4da68693          	addi	a3,a3,1242 # ffffffffc0206748 <commands+0xa90>
ffffffffc0202276:	00004617          	auipc	a2,0x4
ffffffffc020227a:	2da60613          	addi	a2,a2,730 # ffffffffc0206550 <commands+0x898>
ffffffffc020227e:	22200593          	li	a1,546
ffffffffc0202282:	00004517          	auipc	a0,0x4
ffffffffc0202286:	28e50513          	addi	a0,a0,654 # ffffffffc0206510 <commands+0x858>
ffffffffc020228a:	f95fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020228e:	00004697          	auipc	a3,0x4
ffffffffc0202292:	55a68693          	addi	a3,a3,1370 # ffffffffc02067e8 <commands+0xb30>
ffffffffc0202296:	00004617          	auipc	a2,0x4
ffffffffc020229a:	2ba60613          	addi	a2,a2,698 # ffffffffc0206550 <commands+0x898>
ffffffffc020229e:	22100593          	li	a1,545
ffffffffc02022a2:	00004517          	auipc	a0,0x4
ffffffffc02022a6:	26e50513          	addi	a0,a0,622 # ffffffffc0206510 <commands+0x858>
ffffffffc02022aa:	f75fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02022ae:	00004697          	auipc	a3,0x4
ffffffffc02022b2:	61268693          	addi	a3,a3,1554 # ffffffffc02068c0 <commands+0xc08>
ffffffffc02022b6:	00004617          	auipc	a2,0x4
ffffffffc02022ba:	29a60613          	addi	a2,a2,666 # ffffffffc0206550 <commands+0x898>
ffffffffc02022be:	22000593          	li	a1,544
ffffffffc02022c2:	00004517          	auipc	a0,0x4
ffffffffc02022c6:	24e50513          	addi	a0,a0,590 # ffffffffc0206510 <commands+0x858>
ffffffffc02022ca:	f55fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02022ce:	00004697          	auipc	a3,0x4
ffffffffc02022d2:	5da68693          	addi	a3,a3,1498 # ffffffffc02068a8 <commands+0xbf0>
ffffffffc02022d6:	00004617          	auipc	a2,0x4
ffffffffc02022da:	27a60613          	addi	a2,a2,634 # ffffffffc0206550 <commands+0x898>
ffffffffc02022de:	21f00593          	li	a1,543
ffffffffc02022e2:	00004517          	auipc	a0,0x4
ffffffffc02022e6:	22e50513          	addi	a0,a0,558 # ffffffffc0206510 <commands+0x858>
ffffffffc02022ea:	f35fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02022ee:	00004697          	auipc	a3,0x4
ffffffffc02022f2:	58a68693          	addi	a3,a3,1418 # ffffffffc0206878 <commands+0xbc0>
ffffffffc02022f6:	00004617          	auipc	a2,0x4
ffffffffc02022fa:	25a60613          	addi	a2,a2,602 # ffffffffc0206550 <commands+0x898>
ffffffffc02022fe:	21e00593          	li	a1,542
ffffffffc0202302:	00004517          	auipc	a0,0x4
ffffffffc0202306:	20e50513          	addi	a0,a0,526 # ffffffffc0206510 <commands+0x858>
ffffffffc020230a:	f15fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020230e:	00004697          	auipc	a3,0x4
ffffffffc0202312:	55268693          	addi	a3,a3,1362 # ffffffffc0206860 <commands+0xba8>
ffffffffc0202316:	00004617          	auipc	a2,0x4
ffffffffc020231a:	23a60613          	addi	a2,a2,570 # ffffffffc0206550 <commands+0x898>
ffffffffc020231e:	21c00593          	li	a1,540
ffffffffc0202322:	00004517          	auipc	a0,0x4
ffffffffc0202326:	1ee50513          	addi	a0,a0,494 # ffffffffc0206510 <commands+0x858>
ffffffffc020232a:	ef5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc020232e:	00004697          	auipc	a3,0x4
ffffffffc0202332:	51268693          	addi	a3,a3,1298 # ffffffffc0206840 <commands+0xb88>
ffffffffc0202336:	00004617          	auipc	a2,0x4
ffffffffc020233a:	21a60613          	addi	a2,a2,538 # ffffffffc0206550 <commands+0x898>
ffffffffc020233e:	21b00593          	li	a1,539
ffffffffc0202342:	00004517          	auipc	a0,0x4
ffffffffc0202346:	1ce50513          	addi	a0,a0,462 # ffffffffc0206510 <commands+0x858>
ffffffffc020234a:	ed5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(*ptep & PTE_W);
ffffffffc020234e:	00004697          	auipc	a3,0x4
ffffffffc0202352:	4e268693          	addi	a3,a3,1250 # ffffffffc0206830 <commands+0xb78>
ffffffffc0202356:	00004617          	auipc	a2,0x4
ffffffffc020235a:	1fa60613          	addi	a2,a2,506 # ffffffffc0206550 <commands+0x898>
ffffffffc020235e:	21a00593          	li	a1,538
ffffffffc0202362:	00004517          	auipc	a0,0x4
ffffffffc0202366:	1ae50513          	addi	a0,a0,430 # ffffffffc0206510 <commands+0x858>
ffffffffc020236a:	eb5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(*ptep & PTE_U);
ffffffffc020236e:	00004697          	auipc	a3,0x4
ffffffffc0202372:	4b268693          	addi	a3,a3,1202 # ffffffffc0206820 <commands+0xb68>
ffffffffc0202376:	00004617          	auipc	a2,0x4
ffffffffc020237a:	1da60613          	addi	a2,a2,474 # ffffffffc0206550 <commands+0x898>
ffffffffc020237e:	21900593          	li	a1,537
ffffffffc0202382:	00004517          	auipc	a0,0x4
ffffffffc0202386:	18e50513          	addi	a0,a0,398 # ffffffffc0206510 <commands+0x858>
ffffffffc020238a:	e95fd0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("DTB memory info not available");
ffffffffc020238e:	00004617          	auipc	a2,0x4
ffffffffc0202392:	20a60613          	addi	a2,a2,522 # ffffffffc0206598 <commands+0x8e0>
ffffffffc0202396:	06500593          	li	a1,101
ffffffffc020239a:	00004517          	auipc	a0,0x4
ffffffffc020239e:	17650513          	addi	a0,a0,374 # ffffffffc0206510 <commands+0x858>
ffffffffc02023a2:	e7dfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02023a6:	00004697          	auipc	a3,0x4
ffffffffc02023aa:	59268693          	addi	a3,a3,1426 # ffffffffc0206938 <commands+0xc80>
ffffffffc02023ae:	00004617          	auipc	a2,0x4
ffffffffc02023b2:	1a260613          	addi	a2,a2,418 # ffffffffc0206550 <commands+0x898>
ffffffffc02023b6:	25f00593          	li	a1,607
ffffffffc02023ba:	00004517          	auipc	a0,0x4
ffffffffc02023be:	15650513          	addi	a0,a0,342 # ffffffffc0206510 <commands+0x858>
ffffffffc02023c2:	e5dfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02023c6:	00004697          	auipc	a3,0x4
ffffffffc02023ca:	42268693          	addi	a3,a3,1058 # ffffffffc02067e8 <commands+0xb30>
ffffffffc02023ce:	00004617          	auipc	a2,0x4
ffffffffc02023d2:	18260613          	addi	a2,a2,386 # ffffffffc0206550 <commands+0x898>
ffffffffc02023d6:	21800593          	li	a1,536
ffffffffc02023da:	00004517          	auipc	a0,0x4
ffffffffc02023de:	13650513          	addi	a0,a0,310 # ffffffffc0206510 <commands+0x858>
ffffffffc02023e2:	e3dfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02023e6:	00004697          	auipc	a3,0x4
ffffffffc02023ea:	3c268693          	addi	a3,a3,962 # ffffffffc02067a8 <commands+0xaf0>
ffffffffc02023ee:	00004617          	auipc	a2,0x4
ffffffffc02023f2:	16260613          	addi	a2,a2,354 # ffffffffc0206550 <commands+0x898>
ffffffffc02023f6:	21700593          	li	a1,535
ffffffffc02023fa:	00004517          	auipc	a0,0x4
ffffffffc02023fe:	11650513          	addi	a0,a0,278 # ffffffffc0206510 <commands+0x858>
ffffffffc0202402:	e1dfd0ef          	jal	ra,ffffffffc020021e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202406:	86d6                	mv	a3,s5
ffffffffc0202408:	00004617          	auipc	a2,0x4
ffffffffc020240c:	0e060613          	addi	a2,a2,224 # ffffffffc02064e8 <commands+0x830>
ffffffffc0202410:	21300593          	li	a1,531
ffffffffc0202414:	00004517          	auipc	a0,0x4
ffffffffc0202418:	0fc50513          	addi	a0,a0,252 # ffffffffc0206510 <commands+0x858>
ffffffffc020241c:	e03fd0ef          	jal	ra,ffffffffc020021e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202420:	00004617          	auipc	a2,0x4
ffffffffc0202424:	0c860613          	addi	a2,a2,200 # ffffffffc02064e8 <commands+0x830>
ffffffffc0202428:	21200593          	li	a1,530
ffffffffc020242c:	00004517          	auipc	a0,0x4
ffffffffc0202430:	0e450513          	addi	a0,a0,228 # ffffffffc0206510 <commands+0x858>
ffffffffc0202434:	debfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202438:	00004697          	auipc	a3,0x4
ffffffffc020243c:	32868693          	addi	a3,a3,808 # ffffffffc0206760 <commands+0xaa8>
ffffffffc0202440:	00004617          	auipc	a2,0x4
ffffffffc0202444:	11060613          	addi	a2,a2,272 # ffffffffc0206550 <commands+0x898>
ffffffffc0202448:	21000593          	li	a1,528
ffffffffc020244c:	00004517          	auipc	a0,0x4
ffffffffc0202450:	0c450513          	addi	a0,a0,196 # ffffffffc0206510 <commands+0x858>
ffffffffc0202454:	dcbfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202458:	00004697          	auipc	a3,0x4
ffffffffc020245c:	2f068693          	addi	a3,a3,752 # ffffffffc0206748 <commands+0xa90>
ffffffffc0202460:	00004617          	auipc	a2,0x4
ffffffffc0202464:	0f060613          	addi	a2,a2,240 # ffffffffc0206550 <commands+0x898>
ffffffffc0202468:	20f00593          	li	a1,527
ffffffffc020246c:	00004517          	auipc	a0,0x4
ffffffffc0202470:	0a450513          	addi	a0,a0,164 # ffffffffc0206510 <commands+0x858>
ffffffffc0202474:	dabfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202478:	00004697          	auipc	a3,0x4
ffffffffc020247c:	68068693          	addi	a3,a3,1664 # ffffffffc0206af8 <commands+0xe40>
ffffffffc0202480:	00004617          	auipc	a2,0x4
ffffffffc0202484:	0d060613          	addi	a2,a2,208 # ffffffffc0206550 <commands+0x898>
ffffffffc0202488:	25600593          	li	a1,598
ffffffffc020248c:	00004517          	auipc	a0,0x4
ffffffffc0202490:	08450513          	addi	a0,a0,132 # ffffffffc0206510 <commands+0x858>
ffffffffc0202494:	d8bfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202498:	00004697          	auipc	a3,0x4
ffffffffc020249c:	62868693          	addi	a3,a3,1576 # ffffffffc0206ac0 <commands+0xe08>
ffffffffc02024a0:	00004617          	auipc	a2,0x4
ffffffffc02024a4:	0b060613          	addi	a2,a2,176 # ffffffffc0206550 <commands+0x898>
ffffffffc02024a8:	25300593          	li	a1,595
ffffffffc02024ac:	00004517          	auipc	a0,0x4
ffffffffc02024b0:	06450513          	addi	a0,a0,100 # ffffffffc0206510 <commands+0x858>
ffffffffc02024b4:	d6bfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p) == 2);
ffffffffc02024b8:	00004697          	auipc	a3,0x4
ffffffffc02024bc:	5d868693          	addi	a3,a3,1496 # ffffffffc0206a90 <commands+0xdd8>
ffffffffc02024c0:	00004617          	auipc	a2,0x4
ffffffffc02024c4:	09060613          	addi	a2,a2,144 # ffffffffc0206550 <commands+0x898>
ffffffffc02024c8:	24f00593          	li	a1,591
ffffffffc02024cc:	00004517          	auipc	a0,0x4
ffffffffc02024d0:	04450513          	addi	a0,a0,68 # ffffffffc0206510 <commands+0x858>
ffffffffc02024d4:	d4bfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02024d8:	00004697          	auipc	a3,0x4
ffffffffc02024dc:	57068693          	addi	a3,a3,1392 # ffffffffc0206a48 <commands+0xd90>
ffffffffc02024e0:	00004617          	auipc	a2,0x4
ffffffffc02024e4:	07060613          	addi	a2,a2,112 # ffffffffc0206550 <commands+0x898>
ffffffffc02024e8:	24e00593          	li	a1,590
ffffffffc02024ec:	00004517          	auipc	a0,0x4
ffffffffc02024f0:	02450513          	addi	a0,a0,36 # ffffffffc0206510 <commands+0x858>
ffffffffc02024f4:	d2bfd0ef          	jal	ra,ffffffffc020021e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02024f8:	00004617          	auipc	a2,0x4
ffffffffc02024fc:	10060613          	addi	a2,a2,256 # ffffffffc02065f8 <commands+0x940>
ffffffffc0202500:	0c900593          	li	a1,201
ffffffffc0202504:	00004517          	auipc	a0,0x4
ffffffffc0202508:	00c50513          	addi	a0,a0,12 # ffffffffc0206510 <commands+0x858>
ffffffffc020250c:	d13fd0ef          	jal	ra,ffffffffc020021e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202510:	00004617          	auipc	a2,0x4
ffffffffc0202514:	0e860613          	addi	a2,a2,232 # ffffffffc02065f8 <commands+0x940>
ffffffffc0202518:	08100593          	li	a1,129
ffffffffc020251c:	00004517          	auipc	a0,0x4
ffffffffc0202520:	ff450513          	addi	a0,a0,-12 # ffffffffc0206510 <commands+0x858>
ffffffffc0202524:	cfbfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202528:	00004697          	auipc	a3,0x4
ffffffffc020252c:	1f068693          	addi	a3,a3,496 # ffffffffc0206718 <commands+0xa60>
ffffffffc0202530:	00004617          	auipc	a2,0x4
ffffffffc0202534:	02060613          	addi	a2,a2,32 # ffffffffc0206550 <commands+0x898>
ffffffffc0202538:	20e00593          	li	a1,526
ffffffffc020253c:	00004517          	auipc	a0,0x4
ffffffffc0202540:	fd450513          	addi	a0,a0,-44 # ffffffffc0206510 <commands+0x858>
ffffffffc0202544:	cdbfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202548:	00004697          	auipc	a3,0x4
ffffffffc020254c:	1a068693          	addi	a3,a3,416 # ffffffffc02066e8 <commands+0xa30>
ffffffffc0202550:	00004617          	auipc	a2,0x4
ffffffffc0202554:	00060613          	mv	a2,a2
ffffffffc0202558:	20b00593          	li	a1,523
ffffffffc020255c:	00004517          	auipc	a0,0x4
ffffffffc0202560:	fb450513          	addi	a0,a0,-76 # ffffffffc0206510 <commands+0x858>
ffffffffc0202564:	cbbfd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202568 <copy_range>:
{
ffffffffc0202568:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020256a:	00d667b3          	or	a5,a2,a3
{
ffffffffc020256e:	fc86                	sd	ra,120(sp)
ffffffffc0202570:	f8a2                	sd	s0,112(sp)
ffffffffc0202572:	f4a6                	sd	s1,104(sp)
ffffffffc0202574:	f0ca                	sd	s2,96(sp)
ffffffffc0202576:	ecce                	sd	s3,88(sp)
ffffffffc0202578:	e8d2                	sd	s4,80(sp)
ffffffffc020257a:	e4d6                	sd	s5,72(sp)
ffffffffc020257c:	e0da                	sd	s6,64(sp)
ffffffffc020257e:	fc5e                	sd	s7,56(sp)
ffffffffc0202580:	f862                	sd	s8,48(sp)
ffffffffc0202582:	f466                	sd	s9,40(sp)
ffffffffc0202584:	f06a                	sd	s10,32(sp)
ffffffffc0202586:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202588:	17d2                	slli	a5,a5,0x34
ffffffffc020258a:	22079263          	bnez	a5,ffffffffc02027ae <copy_range+0x246>
    assert(USER_ACCESS(start, end));
ffffffffc020258e:	002007b7          	lui	a5,0x200
ffffffffc0202592:	8432                	mv	s0,a2
ffffffffc0202594:	1cf66163          	bltu	a2,a5,ffffffffc0202756 <copy_range+0x1ee>
ffffffffc0202598:	84b6                	mv	s1,a3
ffffffffc020259a:	1ad67e63          	bgeu	a2,a3,ffffffffc0202756 <copy_range+0x1ee>
ffffffffc020259e:	4785                	li	a5,1
ffffffffc02025a0:	07fe                	slli	a5,a5,0x1f
ffffffffc02025a2:	1ad7ea63          	bltu	a5,a3,ffffffffc0202756 <copy_range+0x1ee>
ffffffffc02025a6:	5cfd                	li	s9,-1
ffffffffc02025a8:	00ccd793          	srli	a5,s9,0xc
ffffffffc02025ac:	8a2a                	mv	s4,a0
ffffffffc02025ae:	892e                	mv	s2,a1
ffffffffc02025b0:	8aba                	mv	s5,a4
        start += PGSIZE;
ffffffffc02025b2:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc02025b4:	000b3b97          	auipc	s7,0xb3
ffffffffc02025b8:	b24b8b93          	addi	s7,s7,-1244 # ffffffffc02b50d8 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02025bc:	000b3b17          	auipc	s6,0xb3
ffffffffc02025c0:	b24b0b13          	addi	s6,s6,-1244 # ffffffffc02b50e0 <pages>
ffffffffc02025c4:	fff80c37          	lui	s8,0xfff80
    return KADDR(page2pa(page));
ffffffffc02025c8:	e03e                	sd	a5,0(sp)
        page = pmm_manager->alloc_pages(n);
ffffffffc02025ca:	000b3d17          	auipc	s10,0xb3
ffffffffc02025ce:	b1ed0d13          	addi	s10,s10,-1250 # ffffffffc02b50e8 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02025d2:	4601                	li	a2,0
ffffffffc02025d4:	85a2                	mv	a1,s0
ffffffffc02025d6:	854a                	mv	a0,s2
ffffffffc02025d8:	b6bfe0ef          	jal	ra,ffffffffc0201142 <get_pte>
ffffffffc02025dc:	8caa                	mv	s9,a0
        if (ptep == NULL)
ffffffffc02025de:	cd51                	beqz	a0,ffffffffc020267a <copy_range+0x112>
        if (*ptep & PTE_V)
ffffffffc02025e0:	6118                	ld	a4,0(a0)
ffffffffc02025e2:	8b05                	andi	a4,a4,1
ffffffffc02025e4:	e705                	bnez	a4,ffffffffc020260c <copy_range+0xa4>
        start += PGSIZE;
ffffffffc02025e6:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc02025e8:	fe9465e3          	bltu	s0,s1,ffffffffc02025d2 <copy_range+0x6a>
    return 0;
ffffffffc02025ec:	4501                	li	a0,0
}
ffffffffc02025ee:	70e6                	ld	ra,120(sp)
ffffffffc02025f0:	7446                	ld	s0,112(sp)
ffffffffc02025f2:	74a6                	ld	s1,104(sp)
ffffffffc02025f4:	7906                	ld	s2,96(sp)
ffffffffc02025f6:	69e6                	ld	s3,88(sp)
ffffffffc02025f8:	6a46                	ld	s4,80(sp)
ffffffffc02025fa:	6aa6                	ld	s5,72(sp)
ffffffffc02025fc:	6b06                	ld	s6,64(sp)
ffffffffc02025fe:	7be2                	ld	s7,56(sp)
ffffffffc0202600:	7c42                	ld	s8,48(sp)
ffffffffc0202602:	7ca2                	ld	s9,40(sp)
ffffffffc0202604:	7d02                	ld	s10,32(sp)
ffffffffc0202606:	6de2                	ld	s11,24(sp)
ffffffffc0202608:	6109                	addi	sp,sp,128
ffffffffc020260a:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc020260c:	4605                	li	a2,1
ffffffffc020260e:	85a2                	mv	a1,s0
ffffffffc0202610:	8552                	mv	a0,s4
ffffffffc0202612:	b31fe0ef          	jal	ra,ffffffffc0201142 <get_pte>
ffffffffc0202616:	12050263          	beqz	a0,ffffffffc020273a <copy_range+0x1d2>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc020261a:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V))
ffffffffc020261e:	0017f613          	andi	a2,a5,1
ffffffffc0202622:	0007871b          	sext.w	a4,a5
ffffffffc0202626:	01f7fc93          	andi	s9,a5,31
ffffffffc020262a:	10060a63          	beqz	a2,ffffffffc020273e <copy_range+0x1d6>
    if (PPN(pa) >= npage)
ffffffffc020262e:	000bb603          	ld	a2,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202632:	078a                	slli	a5,a5,0x2
ffffffffc0202634:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202636:	14c7f063          	bgeu	a5,a2,ffffffffc0202776 <copy_range+0x20e>
    return &pages[PPN(pa) - nbase];
ffffffffc020263a:	000b3583          	ld	a1,0(s6)
ffffffffc020263e:	97e2                	add	a5,a5,s8
ffffffffc0202640:	079a                	slli	a5,a5,0x6
ffffffffc0202642:	95be                	add	a1,a1,a5
            if (share) {
ffffffffc0202644:	040a8563          	beqz	s5,ffffffffc020268e <copy_range+0x126>
                if (perm & PTE_W) {
ffffffffc0202648:	00477793          	andi	a5,a4,4
ffffffffc020264c:	efdd                	bnez	a5,ffffffffc020270a <copy_range+0x1a2>
                ret = page_insert(to, page, start, perm);
ffffffffc020264e:	86e6                	mv	a3,s9
ffffffffc0202650:	8622                	mv	a2,s0
ffffffffc0202652:	8552                	mv	a0,s4
ffffffffc0202654:	9deff0ef          	jal	ra,ffffffffc0201832 <page_insert>
            assert(ret == 0);
ffffffffc0202658:	d559                	beqz	a0,ffffffffc02025e6 <copy_range+0x7e>
ffffffffc020265a:	00004697          	auipc	a3,0x4
ffffffffc020265e:	50668693          	addi	a3,a3,1286 # ffffffffc0206b60 <commands+0xea8>
ffffffffc0202662:	00004617          	auipc	a2,0x4
ffffffffc0202666:	eee60613          	addi	a2,a2,-274 # ffffffffc0206550 <commands+0x898>
ffffffffc020266a:	1a300593          	li	a1,419
ffffffffc020266e:	00004517          	auipc	a0,0x4
ffffffffc0202672:	ea250513          	addi	a0,a0,-350 # ffffffffc0206510 <commands+0x858>
ffffffffc0202676:	ba9fd0ef          	jal	ra,ffffffffc020021e <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020267a:	00200637          	lui	a2,0x200
ffffffffc020267e:	9432                	add	s0,s0,a2
ffffffffc0202680:	ffe00637          	lui	a2,0xffe00
ffffffffc0202684:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc0202686:	d03d                	beqz	s0,ffffffffc02025ec <copy_range+0x84>
ffffffffc0202688:	f49465e3          	bltu	s0,s1,ffffffffc02025d2 <copy_range+0x6a>
ffffffffc020268c:	b785                	j	ffffffffc02025ec <copy_range+0x84>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020268e:	100027f3          	csrr	a5,sstatus
ffffffffc0202692:	8b89                	andi	a5,a5,2
ffffffffc0202694:	e42e                	sd	a1,8(sp)
ffffffffc0202696:	e7d1                	bnez	a5,ffffffffc0202722 <copy_range+0x1ba>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202698:	000d3783          	ld	a5,0(s10)
ffffffffc020269c:	4505                	li	a0,1
ffffffffc020269e:	6f9c                	ld	a5,24(a5)
ffffffffc02026a0:	9782                	jalr	a5
ffffffffc02026a2:	65a2                	ld	a1,8(sp)
ffffffffc02026a4:	8daa                	mv	s11,a0
                assert(page != NULL);
ffffffffc02026a6:	0e058463          	beqz	a1,ffffffffc020278e <copy_range+0x226>
                assert(npage != NULL);
ffffffffc02026aa:	140d8c63          	beqz	s11,ffffffffc0202802 <copy_range+0x29a>
    return page - pages + nbase;
ffffffffc02026ae:	000b3703          	ld	a4,0(s6)
    return KADDR(page2pa(page));
ffffffffc02026b2:	6682                	ld	a3,0(sp)
    return page - pages + nbase;
ffffffffc02026b4:	000808b7          	lui	a7,0x80
ffffffffc02026b8:	40e587b3          	sub	a5,a1,a4
ffffffffc02026bc:	8799                	srai	a5,a5,0x6
    return KADDR(page2pa(page));
ffffffffc02026be:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc02026c2:	97c6                	add	a5,a5,a7
    return KADDR(page2pa(page));
ffffffffc02026c4:	00d7f5b3          	and	a1,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02026c8:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02026ca:	10c5ff63          	bgeu	a1,a2,ffffffffc02027e8 <copy_range+0x280>
ffffffffc02026ce:	000b3697          	auipc	a3,0xb3
ffffffffc02026d2:	a2268693          	addi	a3,a3,-1502 # ffffffffc02b50f0 <va_pa_offset>
ffffffffc02026d6:	6288                	ld	a0,0(a3)
    return page - pages + nbase;
ffffffffc02026d8:	40ed8733          	sub	a4,s11,a4
    return KADDR(page2pa(page));
ffffffffc02026dc:	6682                	ld	a3,0(sp)
    return page - pages + nbase;
ffffffffc02026de:	8719                	srai	a4,a4,0x6
ffffffffc02026e0:	9746                	add	a4,a4,a7
    return KADDR(page2pa(page));
ffffffffc02026e2:	00d778b3          	and	a7,a4,a3
ffffffffc02026e6:	00a785b3          	add	a1,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02026ea:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc02026ec:	0ec8f163          	bgeu	a7,a2,ffffffffc02027ce <copy_range+0x266>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02026f0:	6605                	lui	a2,0x1
ffffffffc02026f2:	953a                	add	a0,a0,a4
ffffffffc02026f4:	6fd020ef          	jal	ra,ffffffffc02055f0 <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc02026f8:	86e6                	mv	a3,s9
ffffffffc02026fa:	8622                	mv	a2,s0
ffffffffc02026fc:	85ee                	mv	a1,s11
ffffffffc02026fe:	8552                	mv	a0,s4
ffffffffc0202700:	932ff0ef          	jal	ra,ffffffffc0201832 <page_insert>
            assert(ret == 0);
ffffffffc0202704:	ee0501e3          	beqz	a0,ffffffffc02025e6 <copy_range+0x7e>
ffffffffc0202708:	bf89                	j	ffffffffc020265a <copy_range+0xf2>
                    perm = (perm & ~PTE_W) | PTE_COW;
ffffffffc020270a:	01b77693          	andi	a3,a4,27
ffffffffc020270e:	1006ec93          	ori	s9,a3,256
                    page_insert(from, page, start, perm);
ffffffffc0202712:	86e6                	mv	a3,s9
ffffffffc0202714:	8622                	mv	a2,s0
ffffffffc0202716:	854a                	mv	a0,s2
ffffffffc0202718:	e42e                	sd	a1,8(sp)
ffffffffc020271a:	918ff0ef          	jal	ra,ffffffffc0201832 <page_insert>
ffffffffc020271e:	65a2                	ld	a1,8(sp)
ffffffffc0202720:	b73d                	j	ffffffffc020264e <copy_range+0xe6>
        intr_disable();
ffffffffc0202722:	a98fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202726:	000d3783          	ld	a5,0(s10)
ffffffffc020272a:	4505                	li	a0,1
ffffffffc020272c:	6f9c                	ld	a5,24(a5)
ffffffffc020272e:	9782                	jalr	a5
ffffffffc0202730:	8daa                	mv	s11,a0
        intr_enable();
ffffffffc0202732:	a82fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0202736:	65a2                	ld	a1,8(sp)
ffffffffc0202738:	b7bd                	j	ffffffffc02026a6 <copy_range+0x13e>
                return -E_NO_MEM;
ffffffffc020273a:	5571                	li	a0,-4
ffffffffc020273c:	bd4d                	j	ffffffffc02025ee <copy_range+0x86>
        panic("pte2page called with invalid pte");
ffffffffc020273e:	00004617          	auipc	a2,0x4
ffffffffc0202742:	d8260613          	addi	a2,a2,-638 # ffffffffc02064c0 <commands+0x808>
ffffffffc0202746:	07f00593          	li	a1,127
ffffffffc020274a:	00004517          	auipc	a0,0x4
ffffffffc020274e:	d6650513          	addi	a0,a0,-666 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc0202752:	acdfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202756:	00004697          	auipc	a3,0x4
ffffffffc020275a:	e1268693          	addi	a3,a3,-494 # ffffffffc0206568 <commands+0x8b0>
ffffffffc020275e:	00004617          	auipc	a2,0x4
ffffffffc0202762:	df260613          	addi	a2,a2,-526 # ffffffffc0206550 <commands+0x898>
ffffffffc0202766:	17c00593          	li	a1,380
ffffffffc020276a:	00004517          	auipc	a0,0x4
ffffffffc020276e:	da650513          	addi	a0,a0,-602 # ffffffffc0206510 <commands+0x858>
ffffffffc0202772:	aadfd0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202776:	00004617          	auipc	a2,0x4
ffffffffc020277a:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206490 <commands+0x7d8>
ffffffffc020277e:	06900593          	li	a1,105
ffffffffc0202782:	00004517          	auipc	a0,0x4
ffffffffc0202786:	d2e50513          	addi	a0,a0,-722 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc020278a:	a95fd0ef          	jal	ra,ffffffffc020021e <__panic>
                assert(page != NULL);
ffffffffc020278e:	00004697          	auipc	a3,0x4
ffffffffc0202792:	3b268693          	addi	a3,a3,946 # ffffffffc0206b40 <commands+0xe88>
ffffffffc0202796:	00004617          	auipc	a2,0x4
ffffffffc020279a:	dba60613          	addi	a2,a2,-582 # ffffffffc0206550 <commands+0x898>
ffffffffc020279e:	19c00593          	li	a1,412
ffffffffc02027a2:	00004517          	auipc	a0,0x4
ffffffffc02027a6:	d6e50513          	addi	a0,a0,-658 # ffffffffc0206510 <commands+0x858>
ffffffffc02027aa:	a75fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02027ae:	00004697          	auipc	a3,0x4
ffffffffc02027b2:	d7268693          	addi	a3,a3,-654 # ffffffffc0206520 <commands+0x868>
ffffffffc02027b6:	00004617          	auipc	a2,0x4
ffffffffc02027ba:	d9a60613          	addi	a2,a2,-614 # ffffffffc0206550 <commands+0x898>
ffffffffc02027be:	17b00593          	li	a1,379
ffffffffc02027c2:	00004517          	auipc	a0,0x4
ffffffffc02027c6:	d4e50513          	addi	a0,a0,-690 # ffffffffc0206510 <commands+0x858>
ffffffffc02027ca:	a55fd0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc02027ce:	86ba                	mv	a3,a4
ffffffffc02027d0:	00004617          	auipc	a2,0x4
ffffffffc02027d4:	d1860613          	addi	a2,a2,-744 # ffffffffc02064e8 <commands+0x830>
ffffffffc02027d8:	07100593          	li	a1,113
ffffffffc02027dc:	00004517          	auipc	a0,0x4
ffffffffc02027e0:	cd450513          	addi	a0,a0,-812 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc02027e4:	a3bfd0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc02027e8:	86be                	mv	a3,a5
ffffffffc02027ea:	00004617          	auipc	a2,0x4
ffffffffc02027ee:	cfe60613          	addi	a2,a2,-770 # ffffffffc02064e8 <commands+0x830>
ffffffffc02027f2:	07100593          	li	a1,113
ffffffffc02027f6:	00004517          	auipc	a0,0x4
ffffffffc02027fa:	cba50513          	addi	a0,a0,-838 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc02027fe:	a21fd0ef          	jal	ra,ffffffffc020021e <__panic>
                assert(npage != NULL);
ffffffffc0202802:	00004697          	auipc	a3,0x4
ffffffffc0202806:	34e68693          	addi	a3,a3,846 # ffffffffc0206b50 <commands+0xe98>
ffffffffc020280a:	00004617          	auipc	a2,0x4
ffffffffc020280e:	d4660613          	addi	a2,a2,-698 # ffffffffc0206550 <commands+0x898>
ffffffffc0202812:	19d00593          	li	a1,413
ffffffffc0202816:	00004517          	auipc	a0,0x4
ffffffffc020281a:	cfa50513          	addi	a0,a0,-774 # ffffffffc0206510 <commands+0x858>
ffffffffc020281e:	a01fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202822 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202822:	12058073          	sfence.vma	a1
}
ffffffffc0202826:	8082                	ret

ffffffffc0202828 <pgdir_alloc_page>:
{
ffffffffc0202828:	7179                	addi	sp,sp,-48
ffffffffc020282a:	ec26                	sd	s1,24(sp)
ffffffffc020282c:	e84a                	sd	s2,16(sp)
ffffffffc020282e:	e052                	sd	s4,0(sp)
ffffffffc0202830:	f406                	sd	ra,40(sp)
ffffffffc0202832:	f022                	sd	s0,32(sp)
ffffffffc0202834:	e44e                	sd	s3,8(sp)
ffffffffc0202836:	8a2a                	mv	s4,a0
ffffffffc0202838:	84ae                	mv	s1,a1
ffffffffc020283a:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020283c:	100027f3          	csrr	a5,sstatus
ffffffffc0202840:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0202842:	000b3997          	auipc	s3,0xb3
ffffffffc0202846:	8a698993          	addi	s3,s3,-1882 # ffffffffc02b50e8 <pmm_manager>
ffffffffc020284a:	ef8d                	bnez	a5,ffffffffc0202884 <pgdir_alloc_page+0x5c>
ffffffffc020284c:	0009b783          	ld	a5,0(s3)
ffffffffc0202850:	4505                	li	a0,1
ffffffffc0202852:	6f9c                	ld	a5,24(a5)
ffffffffc0202854:	9782                	jalr	a5
ffffffffc0202856:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0202858:	cc09                	beqz	s0,ffffffffc0202872 <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc020285a:	86ca                	mv	a3,s2
ffffffffc020285c:	8626                	mv	a2,s1
ffffffffc020285e:	85a2                	mv	a1,s0
ffffffffc0202860:	8552                	mv	a0,s4
ffffffffc0202862:	fd1fe0ef          	jal	ra,ffffffffc0201832 <page_insert>
ffffffffc0202866:	e915                	bnez	a0,ffffffffc020289a <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc0202868:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc020286a:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc020286c:	4785                	li	a5,1
ffffffffc020286e:	04f71e63          	bne	a4,a5,ffffffffc02028ca <pgdir_alloc_page+0xa2>
}
ffffffffc0202872:	70a2                	ld	ra,40(sp)
ffffffffc0202874:	8522                	mv	a0,s0
ffffffffc0202876:	7402                	ld	s0,32(sp)
ffffffffc0202878:	64e2                	ld	s1,24(sp)
ffffffffc020287a:	6942                	ld	s2,16(sp)
ffffffffc020287c:	69a2                	ld	s3,8(sp)
ffffffffc020287e:	6a02                	ld	s4,0(sp)
ffffffffc0202880:	6145                	addi	sp,sp,48
ffffffffc0202882:	8082                	ret
        intr_disable();
ffffffffc0202884:	936fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202888:	0009b783          	ld	a5,0(s3)
ffffffffc020288c:	4505                	li	a0,1
ffffffffc020288e:	6f9c                	ld	a5,24(a5)
ffffffffc0202890:	9782                	jalr	a5
ffffffffc0202892:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202894:	920fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0202898:	b7c1                	j	ffffffffc0202858 <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020289a:	100027f3          	csrr	a5,sstatus
ffffffffc020289e:	8b89                	andi	a5,a5,2
ffffffffc02028a0:	eb89                	bnez	a5,ffffffffc02028b2 <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc02028a2:	0009b783          	ld	a5,0(s3)
ffffffffc02028a6:	8522                	mv	a0,s0
ffffffffc02028a8:	4585                	li	a1,1
ffffffffc02028aa:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02028ac:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02028ae:	9782                	jalr	a5
    if (flag)
ffffffffc02028b0:	b7c9                	j	ffffffffc0202872 <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc02028b2:	908fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc02028b6:	0009b783          	ld	a5,0(s3)
ffffffffc02028ba:	8522                	mv	a0,s0
ffffffffc02028bc:	4585                	li	a1,1
ffffffffc02028be:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc02028c0:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc02028c2:	9782                	jalr	a5
        intr_enable();
ffffffffc02028c4:	8f0fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc02028c8:	b76d                	j	ffffffffc0202872 <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc02028ca:	00004697          	auipc	a3,0x4
ffffffffc02028ce:	2a668693          	addi	a3,a3,678 # ffffffffc0206b70 <commands+0xeb8>
ffffffffc02028d2:	00004617          	auipc	a2,0x4
ffffffffc02028d6:	c7e60613          	addi	a2,a2,-898 # ffffffffc0206550 <commands+0x898>
ffffffffc02028da:	1ec00593          	li	a1,492
ffffffffc02028de:	00004517          	auipc	a0,0x4
ffffffffc02028e2:	c3250513          	addi	a0,a0,-974 # ffffffffc0206510 <commands+0x858>
ffffffffc02028e6:	939fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02028ea <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02028ea:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02028ec:	00004697          	auipc	a3,0x4
ffffffffc02028f0:	29c68693          	addi	a3,a3,668 # ffffffffc0206b88 <commands+0xed0>
ffffffffc02028f4:	00004617          	auipc	a2,0x4
ffffffffc02028f8:	c5c60613          	addi	a2,a2,-932 # ffffffffc0206550 <commands+0x898>
ffffffffc02028fc:	07600593          	li	a1,118
ffffffffc0202900:	00004517          	auipc	a0,0x4
ffffffffc0202904:	2a850513          	addi	a0,a0,680 # ffffffffc0206ba8 <commands+0xef0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0202908:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020290a:	915fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020290e <mm_create>:
{
ffffffffc020290e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202910:	04000513          	li	a0,64
{
ffffffffc0202914:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202916:	397000ef          	jal	ra,ffffffffc02034ac <kmalloc>
    if (mm != NULL)
ffffffffc020291a:	cd19                	beqz	a0,ffffffffc0202938 <mm_create+0x2a>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020291c:	e508                	sd	a0,8(a0)
ffffffffc020291e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0202920:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202924:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0202928:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc020292c:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc0202930:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0202934:	02053c23          	sd	zero,56(a0)
}
ffffffffc0202938:	60a2                	ld	ra,8(sp)
ffffffffc020293a:	0141                	addi	sp,sp,16
ffffffffc020293c:	8082                	ret

ffffffffc020293e <find_vma>:
{
ffffffffc020293e:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0202940:	c505                	beqz	a0,ffffffffc0202968 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0202942:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0202944:	c501                	beqz	a0,ffffffffc020294c <find_vma+0xe>
ffffffffc0202946:	651c                	ld	a5,8(a0)
ffffffffc0202948:	02f5f263          	bgeu	a1,a5,ffffffffc020296c <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020294c:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc020294e:	00f68d63          	beq	a3,a5,ffffffffc0202968 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0202952:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f4ec0>
ffffffffc0202956:	00e5e663          	bltu	a1,a4,ffffffffc0202962 <find_vma+0x24>
ffffffffc020295a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020295e:	00e5ec63          	bltu	a1,a4,ffffffffc0202976 <find_vma+0x38>
ffffffffc0202962:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0202964:	fef697e3          	bne	a3,a5,ffffffffc0202952 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0202968:	4501                	li	a0,0
}
ffffffffc020296a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020296c:	691c                	ld	a5,16(a0)
ffffffffc020296e:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020294c <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0202972:	ea88                	sd	a0,16(a3)
ffffffffc0202974:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0202976:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020297a:	ea88                	sd	a0,16(a3)
ffffffffc020297c:	8082                	ret

ffffffffc020297e <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc020297e:	6590                	ld	a2,8(a1)
ffffffffc0202980:	0105b803          	ld	a6,16(a1)
{
ffffffffc0202984:	1141                	addi	sp,sp,-16
ffffffffc0202986:	e406                	sd	ra,8(sp)
ffffffffc0202988:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020298a:	01066763          	bltu	a2,a6,ffffffffc0202998 <insert_vma_struct+0x1a>
ffffffffc020298e:	a085                	j	ffffffffc02029ee <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0202990:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202994:	04e66863          	bltu	a2,a4,ffffffffc02029e4 <insert_vma_struct+0x66>
ffffffffc0202998:	86be                	mv	a3,a5
ffffffffc020299a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc020299c:	fef51ae3          	bne	a0,a5,ffffffffc0202990 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02029a0:	02a68463          	beq	a3,a0,ffffffffc02029c8 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02029a4:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02029a8:	fe86b883          	ld	a7,-24(a3)
ffffffffc02029ac:	08e8f163          	bgeu	a7,a4,ffffffffc0202a2e <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02029b0:	04e66f63          	bltu	a2,a4,ffffffffc0202a0e <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc02029b4:	00f50a63          	beq	a0,a5,ffffffffc02029c8 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02029b8:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02029bc:	05076963          	bltu	a4,a6,ffffffffc0202a0e <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02029c0:	ff07b603          	ld	a2,-16(a5)
ffffffffc02029c4:	02c77363          	bgeu	a4,a2,ffffffffc02029ea <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02029c8:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02029ca:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02029cc:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02029d0:	e390                	sd	a2,0(a5)
ffffffffc02029d2:	e690                	sd	a2,8(a3)
}
ffffffffc02029d4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02029d6:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02029d8:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02029da:	0017079b          	addiw	a5,a4,1
ffffffffc02029de:	d11c                	sw	a5,32(a0)
}
ffffffffc02029e0:	0141                	addi	sp,sp,16
ffffffffc02029e2:	8082                	ret
    if (le_prev != list)
ffffffffc02029e4:	fca690e3          	bne	a3,a0,ffffffffc02029a4 <insert_vma_struct+0x26>
ffffffffc02029e8:	bfd1                	j	ffffffffc02029bc <insert_vma_struct+0x3e>
ffffffffc02029ea:	f01ff0ef          	jal	ra,ffffffffc02028ea <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02029ee:	00004697          	auipc	a3,0x4
ffffffffc02029f2:	1ca68693          	addi	a3,a3,458 # ffffffffc0206bb8 <commands+0xf00>
ffffffffc02029f6:	00004617          	auipc	a2,0x4
ffffffffc02029fa:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0206550 <commands+0x898>
ffffffffc02029fe:	07c00593          	li	a1,124
ffffffffc0202a02:	00004517          	auipc	a0,0x4
ffffffffc0202a06:	1a650513          	addi	a0,a0,422 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0202a0a:	815fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202a0e:	00004697          	auipc	a3,0x4
ffffffffc0202a12:	1ea68693          	addi	a3,a3,490 # ffffffffc0206bf8 <commands+0xf40>
ffffffffc0202a16:	00004617          	auipc	a2,0x4
ffffffffc0202a1a:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0206550 <commands+0x898>
ffffffffc0202a1e:	07500593          	li	a1,117
ffffffffc0202a22:	00004517          	auipc	a0,0x4
ffffffffc0202a26:	18650513          	addi	a0,a0,390 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0202a2a:	ff4fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202a2e:	00004697          	auipc	a3,0x4
ffffffffc0202a32:	1aa68693          	addi	a3,a3,426 # ffffffffc0206bd8 <commands+0xf20>
ffffffffc0202a36:	00004617          	auipc	a2,0x4
ffffffffc0202a3a:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0206550 <commands+0x898>
ffffffffc0202a3e:	07400593          	li	a1,116
ffffffffc0202a42:	00004517          	auipc	a0,0x4
ffffffffc0202a46:	16650513          	addi	a0,a0,358 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0202a4a:	fd4fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202a4e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc0202a4e:	591c                	lw	a5,48(a0)
{
ffffffffc0202a50:	1141                	addi	sp,sp,-16
ffffffffc0202a52:	e406                	sd	ra,8(sp)
ffffffffc0202a54:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0202a56:	e78d                	bnez	a5,ffffffffc0202a80 <mm_destroy+0x32>
ffffffffc0202a58:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0202a5a:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0202a5c:	00a40c63          	beq	s0,a0,ffffffffc0202a74 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202a60:	6118                	ld	a4,0(a0)
ffffffffc0202a62:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0202a64:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0202a66:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202a68:	e398                	sd	a4,0(a5)
ffffffffc0202a6a:	2f3000ef          	jal	ra,ffffffffc020355c <kfree>
    return listelm->next;
ffffffffc0202a6e:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0202a70:	fea418e3          	bne	s0,a0,ffffffffc0202a60 <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0202a74:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0202a76:	6402                	ld	s0,0(sp)
ffffffffc0202a78:	60a2                	ld	ra,8(sp)
ffffffffc0202a7a:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc0202a7c:	2e10006f          	j	ffffffffc020355c <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0202a80:	00004697          	auipc	a3,0x4
ffffffffc0202a84:	19868693          	addi	a3,a3,408 # ffffffffc0206c18 <commands+0xf60>
ffffffffc0202a88:	00004617          	auipc	a2,0x4
ffffffffc0202a8c:	ac860613          	addi	a2,a2,-1336 # ffffffffc0206550 <commands+0x898>
ffffffffc0202a90:	0a000593          	li	a1,160
ffffffffc0202a94:	00004517          	auipc	a0,0x4
ffffffffc0202a98:	11450513          	addi	a0,a0,276 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0202a9c:	f82fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202aa0 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc0202aa0:	7139                	addi	sp,sp,-64
ffffffffc0202aa2:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202aa4:	6405                	lui	s0,0x1
ffffffffc0202aa6:	147d                	addi	s0,s0,-1
ffffffffc0202aa8:	77fd                	lui	a5,0xfffff
ffffffffc0202aaa:	9622                	add	a2,a2,s0
ffffffffc0202aac:	962e                	add	a2,a2,a1
{
ffffffffc0202aae:	f426                	sd	s1,40(sp)
ffffffffc0202ab0:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202ab2:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc0202ab6:	f04a                	sd	s2,32(sp)
ffffffffc0202ab8:	ec4e                	sd	s3,24(sp)
ffffffffc0202aba:	e852                	sd	s4,16(sp)
ffffffffc0202abc:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc0202abe:	002005b7          	lui	a1,0x200
ffffffffc0202ac2:	00f67433          	and	s0,a2,a5
ffffffffc0202ac6:	06b4e363          	bltu	s1,a1,ffffffffc0202b2c <mm_map+0x8c>
ffffffffc0202aca:	0684f163          	bgeu	s1,s0,ffffffffc0202b2c <mm_map+0x8c>
ffffffffc0202ace:	4785                	li	a5,1
ffffffffc0202ad0:	07fe                	slli	a5,a5,0x1f
ffffffffc0202ad2:	0487ed63          	bltu	a5,s0,ffffffffc0202b2c <mm_map+0x8c>
ffffffffc0202ad6:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0202ad8:	cd21                	beqz	a0,ffffffffc0202b30 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0202ada:	85a6                	mv	a1,s1
ffffffffc0202adc:	8ab6                	mv	s5,a3
ffffffffc0202ade:	8a3a                	mv	s4,a4
ffffffffc0202ae0:	e5fff0ef          	jal	ra,ffffffffc020293e <find_vma>
ffffffffc0202ae4:	c501                	beqz	a0,ffffffffc0202aec <mm_map+0x4c>
ffffffffc0202ae6:	651c                	ld	a5,8(a0)
ffffffffc0202ae8:	0487e263          	bltu	a5,s0,ffffffffc0202b2c <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202aec:	03000513          	li	a0,48
ffffffffc0202af0:	1bd000ef          	jal	ra,ffffffffc02034ac <kmalloc>
ffffffffc0202af4:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0202af6:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc0202af8:	02090163          	beqz	s2,ffffffffc0202b1a <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0202afc:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0202afe:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0202b02:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0202b06:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0202b0a:	85ca                	mv	a1,s2
ffffffffc0202b0c:	e73ff0ef          	jal	ra,ffffffffc020297e <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0202b10:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc0202b12:	000a0463          	beqz	s4,ffffffffc0202b1a <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0202b16:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0202b1a:	70e2                	ld	ra,56(sp)
ffffffffc0202b1c:	7442                	ld	s0,48(sp)
ffffffffc0202b1e:	74a2                	ld	s1,40(sp)
ffffffffc0202b20:	7902                	ld	s2,32(sp)
ffffffffc0202b22:	69e2                	ld	s3,24(sp)
ffffffffc0202b24:	6a42                	ld	s4,16(sp)
ffffffffc0202b26:	6aa2                	ld	s5,8(sp)
ffffffffc0202b28:	6121                	addi	sp,sp,64
ffffffffc0202b2a:	8082                	ret
        return -E_INVAL;
ffffffffc0202b2c:	5575                	li	a0,-3
ffffffffc0202b2e:	b7f5                	j	ffffffffc0202b1a <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0202b30:	00004697          	auipc	a3,0x4
ffffffffc0202b34:	10068693          	addi	a3,a3,256 # ffffffffc0206c30 <commands+0xf78>
ffffffffc0202b38:	00004617          	auipc	a2,0x4
ffffffffc0202b3c:	a1860613          	addi	a2,a2,-1512 # ffffffffc0206550 <commands+0x898>
ffffffffc0202b40:	0b500593          	li	a1,181
ffffffffc0202b44:	00004517          	auipc	a0,0x4
ffffffffc0202b48:	06450513          	addi	a0,a0,100 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0202b4c:	ed2fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202b50 <do_pgfault>:

int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0202b50:	715d                	addi	sp,sp,-80
ffffffffc0202b52:	e0a2                	sd	s0,64(sp)
ffffffffc0202b54:	842e                	mv	s0,a1
    int ret = -E_INVAL;
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202b56:	85b2                	mv	a1,a2
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0202b58:	fc26                	sd	s1,56(sp)
ffffffffc0202b5a:	f84a                	sd	s2,48(sp)
ffffffffc0202b5c:	e486                	sd	ra,72(sp)
ffffffffc0202b5e:	f44e                	sd	s3,40(sp)
ffffffffc0202b60:	f052                	sd	s4,32(sp)
ffffffffc0202b62:	ec56                	sd	s5,24(sp)
ffffffffc0202b64:	e85a                	sd	s6,16(sp)
ffffffffc0202b66:	e45e                	sd	s7,8(sp)
ffffffffc0202b68:	84b2                	mv	s1,a2
ffffffffc0202b6a:	892a                	mv	s2,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202b6c:	dd3ff0ef          	jal	ra,ffffffffc020293e <find_vma>

    pgfault_num++;
ffffffffc0202b70:	000b2797          	auipc	a5,0xb2
ffffffffc0202b74:	5887a783          	lw	a5,1416(a5) # ffffffffc02b50f8 <pgfault_num>
ffffffffc0202b78:	2785                	addiw	a5,a5,1
ffffffffc0202b7a:	000b2717          	auipc	a4,0xb2
ffffffffc0202b7e:	56f72f23          	sw	a5,1406(a4) # ffffffffc02b50f8 <pgfault_num>
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202b82:	16050b63          	beqz	a0,ffffffffc0202cf8 <do_pgfault+0x1a8>
ffffffffc0202b86:	651c                	ld	a5,8(a0)
ffffffffc0202b88:	16f4e863          	bltu	s1,a5,ffffffffc0202cf8 <do_pgfault+0x1a8>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }
    switch (error_code & 3) {
ffffffffc0202b8c:	00347593          	andi	a1,s0,3
ffffffffc0202b90:	10058863          	beqz	a1,ffffffffc0202ca0 <do_pgfault+0x150>
ffffffffc0202b94:	4785                	li	a5,1
ffffffffc0202b96:	0ef58363          	beq	a1,a5,ffffffffc0202c7c <do_pgfault+0x12c>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
ffffffffc0202b9a:	4d1c                	lw	a5,24(a0)
            goto failed;
        }
    }
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
ffffffffc0202b9c:	49d9                	li	s3,22
        if (!(vma->vm_flags & VM_WRITE)) {
ffffffffc0202b9e:	0027f713          	andi	a4,a5,2
ffffffffc0202ba2:	18070663          	beqz	a4,ffffffffc0202d2e <do_pgfault+0x1de>
    }
    if (vma->vm_flags & VM_READ) {
ffffffffc0202ba6:	0017f713          	andi	a4,a5,1
ffffffffc0202baa:	c319                	beqz	a4,ffffffffc0202bb0 <do_pgfault+0x60>
        perm |= PTE_R;
ffffffffc0202bac:	0029e993          	ori	s3,s3,2
    }
    if (vma->vm_flags & VM_EXEC) {
ffffffffc0202bb0:	8b91                	andi	a5,a5,4
ffffffffc0202bb2:	c399                	beqz	a5,ffffffffc0202bb8 <do_pgfault+0x68>
        perm |= PTE_X;
ffffffffc0202bb4:	0089e993          	ori	s3,s3,8
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202bb8:	767d                	lui	a2,0xfffff

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;
    
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202bba:	01893503          	ld	a0,24(s2)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202bbe:	8cf1                	and	s1,s1,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202bc0:	85a6                	mv	a1,s1
ffffffffc0202bc2:	4605                	li	a2,1
ffffffffc0202bc4:	d7efe0ef          	jal	ra,ffffffffc0201142 <get_pte>
ffffffffc0202bc8:	872a                	mv	a4,a0
ffffffffc0202bca:	16050a63          	beqz	a0,ffffffffc0202d3e <do_pgfault+0x1ee>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) {
ffffffffc0202bce:	610c                	ld	a1,0(a0)
ffffffffc0202bd0:	c1fd                	beqz	a1,ffffffffc0202cb6 <do_pgfault+0x166>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
        if (*ptep & PTE_COW) {
ffffffffc0202bd2:	1005f793          	andi	a5,a1,256
ffffffffc0202bd6:	12078a63          	beqz	a5,ffffffffc0202d0a <do_pgfault+0x1ba>
    if (!(pte & PTE_V))
ffffffffc0202bda:	0015f793          	andi	a5,a1,1
ffffffffc0202bde:	16078863          	beqz	a5,ffffffffc0202d4e <do_pgfault+0x1fe>
    if (PPN(pa) >= npage)
ffffffffc0202be2:	000b2b17          	auipc	s6,0xb2
ffffffffc0202be6:	4f6b0b13          	addi	s6,s6,1270 # ffffffffc02b50d8 <npage>
ffffffffc0202bea:	000b3683          	ld	a3,0(s6)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202bee:	00259793          	slli	a5,a1,0x2
ffffffffc0202bf2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bf4:	16d7f963          	bgeu	a5,a3,ffffffffc0202d66 <do_pgfault+0x216>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bf8:	000b2b97          	auipc	s7,0xb2
ffffffffc0202bfc:	4e8b8b93          	addi	s7,s7,1256 # ffffffffc02b50e0 <pages>
ffffffffc0202c00:	000bb403          	ld	s0,0(s7)
ffffffffc0202c04:	00005a97          	auipc	s5,0x5
ffffffffc0202c08:	0f4aba83          	ld	s5,244(s5) # ffffffffc0207cf8 <nbase>
ffffffffc0202c0c:	415787b3          	sub	a5,a5,s5
ffffffffc0202c10:	079a                	slli	a5,a5,0x6
ffffffffc0202c12:	943e                	add	s0,s0,a5
            struct Page *page = pte2page(*ptep);
            if (page_ref(page) > 1) {
ffffffffc0202c14:	4014                	lw	a3,0(s0)
ffffffffc0202c16:	4785                	li	a5,1
ffffffffc0202c18:	0ad7de63          	bge	a5,a3,ffffffffc0202cd4 <do_pgfault+0x184>
                struct Page *npage = alloc_page();
ffffffffc0202c1c:	4505                	li	a0,1
ffffffffc0202c1e:	c6cfe0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0202c22:	8a2a                	mv	s4,a0
                if (npage == NULL) {
ffffffffc0202c24:	0e050b63          	beqz	a0,ffffffffc0202d1a <do_pgfault+0x1ca>
    return page - pages + nbase;
ffffffffc0202c28:	000bb603          	ld	a2,0(s7)
    return KADDR(page2pa(page));
ffffffffc0202c2c:	577d                	li	a4,-1
ffffffffc0202c2e:	000b3683          	ld	a3,0(s6)
    return page - pages + nbase;
ffffffffc0202c32:	40c507b3          	sub	a5,a0,a2
ffffffffc0202c36:	8799                	srai	a5,a5,0x6
ffffffffc0202c38:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0202c3a:	8331                	srli	a4,a4,0xc
ffffffffc0202c3c:	00e7f5b3          	and	a1,a5,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c40:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202c42:	14d5fb63          	bgeu	a1,a3,ffffffffc0202d98 <do_pgfault+0x248>
    return page - pages + nbase;
ffffffffc0202c46:	8c11                	sub	s0,s0,a2
ffffffffc0202c48:	8419                	srai	s0,s0,0x6
ffffffffc0202c4a:	9456                	add	s0,s0,s5
    return KADDR(page2pa(page));
ffffffffc0202c4c:	000b2597          	auipc	a1,0xb2
ffffffffc0202c50:	4a45b583          	ld	a1,1188(a1) # ffffffffc02b50f0 <va_pa_offset>
ffffffffc0202c54:	8f61                	and	a4,a4,s0
ffffffffc0202c56:	00b78533          	add	a0,a5,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c5a:	0432                	slli	s0,s0,0xc
    return KADDR(page2pa(page));
ffffffffc0202c5c:	12d77163          	bgeu	a4,a3,ffffffffc0202d7e <do_pgfault+0x22e>
                    goto failed;
                }
                memcpy(page2kva(npage), page2kva(page), PGSIZE);
ffffffffc0202c60:	6605                	lui	a2,0x1
ffffffffc0202c62:	95a2                	add	a1,a1,s0
ffffffffc0202c64:	18d020ef          	jal	ra,ffffffffc02055f0 <memcpy>
                if (page_insert(mm->pgdir, npage, addr, perm) != 0) {
ffffffffc0202c68:	01893503          	ld	a0,24(s2)
ffffffffc0202c6c:	86ce                	mv	a3,s3
ffffffffc0202c6e:	8626                	mv	a2,s1
ffffffffc0202c70:	85d2                	mv	a1,s4
ffffffffc0202c72:	bc1fe0ef          	jal	ra,ffffffffc0201832 <page_insert>
ffffffffc0202c76:	e93d                	bnez	a0,ffffffffc0202cec <do_pgfault+0x19c>
        } else {
            cprintf("ptep is %x, but no swap support, failed\n",*ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0202c78:	4501                	li	a0,0
ffffffffc0202c7a:	a801                	j	ffffffffc0202c8a <do_pgfault+0x13a>
        cprintf("do_pgfault failed: error code flag = read AND present\n");
ffffffffc0202c7c:	00004517          	auipc	a0,0x4
ffffffffc0202c80:	05450513          	addi	a0,a0,84 # ffffffffc0206cd0 <commands+0x1018>
ffffffffc0202c84:	c5cfd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202c88:	5575                	li	a0,-3
failed:
    return ret;
}
ffffffffc0202c8a:	60a6                	ld	ra,72(sp)
ffffffffc0202c8c:	6406                	ld	s0,64(sp)
ffffffffc0202c8e:	74e2                	ld	s1,56(sp)
ffffffffc0202c90:	7942                	ld	s2,48(sp)
ffffffffc0202c92:	79a2                	ld	s3,40(sp)
ffffffffc0202c94:	7a02                	ld	s4,32(sp)
ffffffffc0202c96:	6ae2                	ld	s5,24(sp)
ffffffffc0202c98:	6b42                	ld	s6,16(sp)
ffffffffc0202c9a:	6ba2                	ld	s7,8(sp)
ffffffffc0202c9c:	6161                	addi	sp,sp,80
ffffffffc0202c9e:	8082                	ret
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
ffffffffc0202ca0:	4d1c                	lw	a5,24(a0)
ffffffffc0202ca2:	0057f713          	andi	a4,a5,5
ffffffffc0202ca6:	cf25                	beqz	a4,ffffffffc0202d1e <do_pgfault+0x1ce>
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202ca8:	0027f713          	andi	a4,a5,2
    uint32_t perm = PTE_U;
ffffffffc0202cac:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202cae:	ee070ce3          	beqz	a4,ffffffffc0202ba6 <do_pgfault+0x56>
        perm |= (PTE_R | PTE_W);
ffffffffc0202cb2:	49d9                	li	s3,22
ffffffffc0202cb4:	bdcd                	j	ffffffffc0202ba6 <do_pgfault+0x56>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202cb6:	01893503          	ld	a0,24(s2)
ffffffffc0202cba:	864e                	mv	a2,s3
ffffffffc0202cbc:	85a6                	mv	a1,s1
ffffffffc0202cbe:	b6bff0ef          	jal	ra,ffffffffc0202828 <pgdir_alloc_page>
ffffffffc0202cc2:	f95d                	bnez	a0,ffffffffc0202c78 <do_pgfault+0x128>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202cc4:	00004517          	auipc	a0,0x4
ffffffffc0202cc8:	0cc50513          	addi	a0,a0,204 # ffffffffc0206d90 <commands+0x10d8>
ffffffffc0202ccc:	c14fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202cd0:	5571                	li	a0,-4
            goto failed;
ffffffffc0202cd2:	bf65                	j	ffffffffc0202c8a <do_pgfault+0x13a>
                tlb_invalidate(mm->pgdir, addr);
ffffffffc0202cd4:	01893503          	ld	a0,24(s2)
                *ptep &= ~PTE_COW;
ffffffffc0202cd8:	eff5f593          	andi	a1,a1,-257
                *ptep |= PTE_W;
ffffffffc0202cdc:	0045e593          	ori	a1,a1,4
ffffffffc0202ce0:	e30c                	sd	a1,0(a4)
                tlb_invalidate(mm->pgdir, addr);
ffffffffc0202ce2:	85a6                	mv	a1,s1
ffffffffc0202ce4:	b3fff0ef          	jal	ra,ffffffffc0202822 <tlb_invalidate>
   ret = 0;
ffffffffc0202ce8:	4501                	li	a0,0
ffffffffc0202cea:	b745                	j	ffffffffc0202c8a <do_pgfault+0x13a>
                    free_page(npage);
ffffffffc0202cec:	8552                	mv	a0,s4
ffffffffc0202cee:	4585                	li	a1,1
ffffffffc0202cf0:	bd8fe0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    ret = -E_NO_MEM;
ffffffffc0202cf4:	5571                	li	a0,-4
                    goto failed;
ffffffffc0202cf6:	bf51                	j	ffffffffc0202c8a <do_pgfault+0x13a>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202cf8:	85a6                	mv	a1,s1
ffffffffc0202cfa:	00004517          	auipc	a0,0x4
ffffffffc0202cfe:	f4650513          	addi	a0,a0,-186 # ffffffffc0206c40 <commands+0xf88>
ffffffffc0202d02:	bdefd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202d06:	5575                	li	a0,-3
        goto failed;
ffffffffc0202d08:	b749                	j	ffffffffc0202c8a <do_pgfault+0x13a>
            cprintf("ptep is %x, but no swap support, failed\n",*ptep);
ffffffffc0202d0a:	00004517          	auipc	a0,0x4
ffffffffc0202d0e:	0ae50513          	addi	a0,a0,174 # ffffffffc0206db8 <commands+0x1100>
ffffffffc0202d12:	bcefd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202d16:	5571                	li	a0,-4
            goto failed;
ffffffffc0202d18:	bf8d                	j	ffffffffc0202c8a <do_pgfault+0x13a>
    ret = -E_NO_MEM;
ffffffffc0202d1a:	5571                	li	a0,-4
ffffffffc0202d1c:	b7bd                	j	ffffffffc0202c8a <do_pgfault+0x13a>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
ffffffffc0202d1e:	00004517          	auipc	a0,0x4
ffffffffc0202d22:	fea50513          	addi	a0,a0,-22 # ffffffffc0206d08 <commands+0x1050>
ffffffffc0202d26:	bbafd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202d2a:	5575                	li	a0,-3
            goto failed;
ffffffffc0202d2c:	bfb9                	j	ffffffffc0202c8a <do_pgfault+0x13a>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
ffffffffc0202d2e:	00004517          	auipc	a0,0x4
ffffffffc0202d32:	f4250513          	addi	a0,a0,-190 # ffffffffc0206c70 <commands+0xfb8>
ffffffffc0202d36:	baafd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202d3a:	5575                	li	a0,-3
            goto failed;
ffffffffc0202d3c:	b7b9                	j	ffffffffc0202c8a <do_pgfault+0x13a>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202d3e:	00004517          	auipc	a0,0x4
ffffffffc0202d42:	03250513          	addi	a0,a0,50 # ffffffffc0206d70 <commands+0x10b8>
ffffffffc0202d46:	b9afd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202d4a:	5571                	li	a0,-4
        goto failed;
ffffffffc0202d4c:	bf3d                	j	ffffffffc0202c8a <do_pgfault+0x13a>
        panic("pte2page called with invalid pte");
ffffffffc0202d4e:	00003617          	auipc	a2,0x3
ffffffffc0202d52:	77260613          	addi	a2,a2,1906 # ffffffffc02064c0 <commands+0x808>
ffffffffc0202d56:	07f00593          	li	a1,127
ffffffffc0202d5a:	00003517          	auipc	a0,0x3
ffffffffc0202d5e:	75650513          	addi	a0,a0,1878 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc0202d62:	cbcfd0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202d66:	00003617          	auipc	a2,0x3
ffffffffc0202d6a:	72a60613          	addi	a2,a2,1834 # ffffffffc0206490 <commands+0x7d8>
ffffffffc0202d6e:	06900593          	li	a1,105
ffffffffc0202d72:	00003517          	auipc	a0,0x3
ffffffffc0202d76:	73e50513          	addi	a0,a0,1854 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc0202d7a:	ca4fd0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202d7e:	86a2                	mv	a3,s0
ffffffffc0202d80:	00003617          	auipc	a2,0x3
ffffffffc0202d84:	76860613          	addi	a2,a2,1896 # ffffffffc02064e8 <commands+0x830>
ffffffffc0202d88:	07100593          	li	a1,113
ffffffffc0202d8c:	00003517          	auipc	a0,0x3
ffffffffc0202d90:	72450513          	addi	a0,a0,1828 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc0202d94:	c8afd0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0202d98:	86be                	mv	a3,a5
ffffffffc0202d9a:	00003617          	auipc	a2,0x3
ffffffffc0202d9e:	74e60613          	addi	a2,a2,1870 # ffffffffc02064e8 <commands+0x830>
ffffffffc0202da2:	07100593          	li	a1,113
ffffffffc0202da6:	00003517          	auipc	a0,0x3
ffffffffc0202daa:	70a50513          	addi	a0,a0,1802 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc0202dae:	c70fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202db2 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0202db2:	7139                	addi	sp,sp,-64
ffffffffc0202db4:	fc06                	sd	ra,56(sp)
ffffffffc0202db6:	f822                	sd	s0,48(sp)
ffffffffc0202db8:	f426                	sd	s1,40(sp)
ffffffffc0202dba:	f04a                	sd	s2,32(sp)
ffffffffc0202dbc:	ec4e                	sd	s3,24(sp)
ffffffffc0202dbe:	e852                	sd	s4,16(sp)
ffffffffc0202dc0:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0202dc2:	c52d                	beqz	a0,ffffffffc0202e2c <dup_mmap+0x7a>
ffffffffc0202dc4:	892a                	mv	s2,a0
ffffffffc0202dc6:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0202dc8:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0202dca:	e595                	bnez	a1,ffffffffc0202df6 <dup_mmap+0x44>
ffffffffc0202dcc:	a085                	j	ffffffffc0202e2c <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0202dce:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0202dd0:	0155b423          	sd	s5,8(a1)
        vma->vm_end = vm_end;
ffffffffc0202dd4:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0202dd8:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0202ddc:	ba3ff0ef          	jal	ra,ffffffffc020297e <insert_vma_struct>

        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0202de0:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc8>
ffffffffc0202de4:	fe843603          	ld	a2,-24(s0)
ffffffffc0202de8:	6c8c                	ld	a1,24(s1)
ffffffffc0202dea:	01893503          	ld	a0,24(s2)
ffffffffc0202dee:	4705                	li	a4,1
ffffffffc0202df0:	f78ff0ef          	jal	ra,ffffffffc0202568 <copy_range>
ffffffffc0202df4:	e105                	bnez	a0,ffffffffc0202e14 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0202df6:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0202df8:	02848863          	beq	s1,s0,ffffffffc0202e28 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202dfc:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0202e00:	fe843a83          	ld	s5,-24(s0)
ffffffffc0202e04:	ff043a03          	ld	s4,-16(s0)
ffffffffc0202e08:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202e0c:	6a0000ef          	jal	ra,ffffffffc02034ac <kmalloc>
ffffffffc0202e10:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc0202e12:	fd55                	bnez	a0,ffffffffc0202dce <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0202e14:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0202e16:	70e2                	ld	ra,56(sp)
ffffffffc0202e18:	7442                	ld	s0,48(sp)
ffffffffc0202e1a:	74a2                	ld	s1,40(sp)
ffffffffc0202e1c:	7902                	ld	s2,32(sp)
ffffffffc0202e1e:	69e2                	ld	s3,24(sp)
ffffffffc0202e20:	6a42                	ld	s4,16(sp)
ffffffffc0202e22:	6aa2                	ld	s5,8(sp)
ffffffffc0202e24:	6121                	addi	sp,sp,64
ffffffffc0202e26:	8082                	ret
    return 0;
ffffffffc0202e28:	4501                	li	a0,0
ffffffffc0202e2a:	b7f5                	j	ffffffffc0202e16 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0202e2c:	00004697          	auipc	a3,0x4
ffffffffc0202e30:	fbc68693          	addi	a3,a3,-68 # ffffffffc0206de8 <commands+0x1130>
ffffffffc0202e34:	00003617          	auipc	a2,0x3
ffffffffc0202e38:	71c60613          	addi	a2,a2,1820 # ffffffffc0206550 <commands+0x898>
ffffffffc0202e3c:	12200593          	li	a1,290
ffffffffc0202e40:	00004517          	auipc	a0,0x4
ffffffffc0202e44:	d6850513          	addi	a0,a0,-664 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0202e48:	bd6fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202e4c <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0202e4c:	1101                	addi	sp,sp,-32
ffffffffc0202e4e:	ec06                	sd	ra,24(sp)
ffffffffc0202e50:	e822                	sd	s0,16(sp)
ffffffffc0202e52:	e426                	sd	s1,8(sp)
ffffffffc0202e54:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202e56:	c531                	beqz	a0,ffffffffc0202ea2 <exit_mmap+0x56>
ffffffffc0202e58:	591c                	lw	a5,48(a0)
ffffffffc0202e5a:	84aa                	mv	s1,a0
ffffffffc0202e5c:	e3b9                	bnez	a5,ffffffffc0202ea2 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0202e5e:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0202e60:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0202e64:	02850663          	beq	a0,s0,ffffffffc0202e90 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202e68:	ff043603          	ld	a2,-16(s0)
ffffffffc0202e6c:	fe843583          	ld	a1,-24(s0)
ffffffffc0202e70:	854a                	mv	a0,s2
ffffffffc0202e72:	d4cfe0ef          	jal	ra,ffffffffc02013be <unmap_range>
ffffffffc0202e76:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0202e78:	fe8498e3          	bne	s1,s0,ffffffffc0202e68 <exit_mmap+0x1c>
ffffffffc0202e7c:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0202e7e:	00848c63          	beq	s1,s0,ffffffffc0202e96 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202e82:	ff043603          	ld	a2,-16(s0)
ffffffffc0202e86:	fe843583          	ld	a1,-24(s0)
ffffffffc0202e8a:	854a                	mv	a0,s2
ffffffffc0202e8c:	e78fe0ef          	jal	ra,ffffffffc0201504 <exit_range>
ffffffffc0202e90:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0202e92:	fe8498e3          	bne	s1,s0,ffffffffc0202e82 <exit_mmap+0x36>
    }
}
ffffffffc0202e96:	60e2                	ld	ra,24(sp)
ffffffffc0202e98:	6442                	ld	s0,16(sp)
ffffffffc0202e9a:	64a2                	ld	s1,8(sp)
ffffffffc0202e9c:	6902                	ld	s2,0(sp)
ffffffffc0202e9e:	6105                	addi	sp,sp,32
ffffffffc0202ea0:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202ea2:	00004697          	auipc	a3,0x4
ffffffffc0202ea6:	f6668693          	addi	a3,a3,-154 # ffffffffc0206e08 <commands+0x1150>
ffffffffc0202eaa:	00003617          	auipc	a2,0x3
ffffffffc0202eae:	6a660613          	addi	a2,a2,1702 # ffffffffc0206550 <commands+0x898>
ffffffffc0202eb2:	13b00593          	li	a1,315
ffffffffc0202eb6:	00004517          	auipc	a0,0x4
ffffffffc0202eba:	cf250513          	addi	a0,a0,-782 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0202ebe:	b60fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202ec2 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0202ec2:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202ec4:	04000513          	li	a0,64
{
ffffffffc0202ec8:	fc06                	sd	ra,56(sp)
ffffffffc0202eca:	f822                	sd	s0,48(sp)
ffffffffc0202ecc:	f426                	sd	s1,40(sp)
ffffffffc0202ece:	f04a                	sd	s2,32(sp)
ffffffffc0202ed0:	ec4e                	sd	s3,24(sp)
ffffffffc0202ed2:	e852                	sd	s4,16(sp)
ffffffffc0202ed4:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202ed6:	5d6000ef          	jal	ra,ffffffffc02034ac <kmalloc>
    if (mm != NULL)
ffffffffc0202eda:	2e050663          	beqz	a0,ffffffffc02031c6 <vmm_init+0x304>
ffffffffc0202ede:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0202ee0:	e508                	sd	a0,8(a0)
ffffffffc0202ee2:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0202ee4:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202ee8:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0202eec:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0202ef0:	02053423          	sd	zero,40(a0)
ffffffffc0202ef4:	02052823          	sw	zero,48(a0)
ffffffffc0202ef8:	02053c23          	sd	zero,56(a0)
ffffffffc0202efc:	03200413          	li	s0,50
ffffffffc0202f00:	a811                	j	ffffffffc0202f14 <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc0202f02:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202f04:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202f06:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0202f0a:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202f0c:	8526                	mv	a0,s1
ffffffffc0202f0e:	a71ff0ef          	jal	ra,ffffffffc020297e <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0202f12:	c80d                	beqz	s0,ffffffffc0202f44 <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202f14:	03000513          	li	a0,48
ffffffffc0202f18:	594000ef          	jal	ra,ffffffffc02034ac <kmalloc>
ffffffffc0202f1c:	85aa                	mv	a1,a0
ffffffffc0202f1e:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0202f22:	f165                	bnez	a0,ffffffffc0202f02 <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc0202f24:	00004697          	auipc	a3,0x4
ffffffffc0202f28:	07c68693          	addi	a3,a3,124 # ffffffffc0206fa0 <commands+0x12e8>
ffffffffc0202f2c:	00003617          	auipc	a2,0x3
ffffffffc0202f30:	62460613          	addi	a2,a2,1572 # ffffffffc0206550 <commands+0x898>
ffffffffc0202f34:	17f00593          	li	a1,383
ffffffffc0202f38:	00004517          	auipc	a0,0x4
ffffffffc0202f3c:	c7050513          	addi	a0,a0,-912 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0202f40:	adefd0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0202f44:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202f48:	1f900913          	li	s2,505
ffffffffc0202f4c:	a819                	j	ffffffffc0202f62 <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc0202f4e:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202f50:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202f52:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202f56:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202f58:	8526                	mv	a0,s1
ffffffffc0202f5a:	a25ff0ef          	jal	ra,ffffffffc020297e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202f5e:	03240a63          	beq	s0,s2,ffffffffc0202f92 <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202f62:	03000513          	li	a0,48
ffffffffc0202f66:	546000ef          	jal	ra,ffffffffc02034ac <kmalloc>
ffffffffc0202f6a:	85aa                	mv	a1,a0
ffffffffc0202f6c:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0202f70:	fd79                	bnez	a0,ffffffffc0202f4e <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0202f72:	00004697          	auipc	a3,0x4
ffffffffc0202f76:	02e68693          	addi	a3,a3,46 # ffffffffc0206fa0 <commands+0x12e8>
ffffffffc0202f7a:	00003617          	auipc	a2,0x3
ffffffffc0202f7e:	5d660613          	addi	a2,a2,1494 # ffffffffc0206550 <commands+0x898>
ffffffffc0202f82:	18600593          	li	a1,390
ffffffffc0202f86:	00004517          	auipc	a0,0x4
ffffffffc0202f8a:	c2250513          	addi	a0,a0,-990 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0202f8e:	a90fd0ef          	jal	ra,ffffffffc020021e <__panic>
    return listelm->next;
ffffffffc0202f92:	649c                	ld	a5,8(s1)
ffffffffc0202f94:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0202f96:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0202f9a:	16f48663          	beq	s1,a5,ffffffffc0203106 <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202f9e:	fe87b603          	ld	a2,-24(a5)
ffffffffc0202fa2:	ffe70693          	addi	a3,a4,-2
ffffffffc0202fa6:	10d61063          	bne	a2,a3,ffffffffc02030a6 <vmm_init+0x1e4>
ffffffffc0202faa:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202fae:	0ed71c63          	bne	a4,a3,ffffffffc02030a6 <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0202fb2:	0715                	addi	a4,a4,5
ffffffffc0202fb4:	679c                	ld	a5,8(a5)
ffffffffc0202fb6:	feb712e3          	bne	a4,a1,ffffffffc0202f9a <vmm_init+0xd8>
ffffffffc0202fba:	4a1d                	li	s4,7
ffffffffc0202fbc:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0202fbe:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202fc2:	85a2                	mv	a1,s0
ffffffffc0202fc4:	8526                	mv	a0,s1
ffffffffc0202fc6:	979ff0ef          	jal	ra,ffffffffc020293e <find_vma>
ffffffffc0202fca:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0202fcc:	16050d63          	beqz	a0,ffffffffc0203146 <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0202fd0:	00140593          	addi	a1,s0,1
ffffffffc0202fd4:	8526                	mv	a0,s1
ffffffffc0202fd6:	969ff0ef          	jal	ra,ffffffffc020293e <find_vma>
ffffffffc0202fda:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0202fdc:	14050563          	beqz	a0,ffffffffc0203126 <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0202fe0:	85d2                	mv	a1,s4
ffffffffc0202fe2:	8526                	mv	a0,s1
ffffffffc0202fe4:	95bff0ef          	jal	ra,ffffffffc020293e <find_vma>
        assert(vma3 == NULL);
ffffffffc0202fe8:	16051f63          	bnez	a0,ffffffffc0203166 <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0202fec:	00340593          	addi	a1,s0,3
ffffffffc0202ff0:	8526                	mv	a0,s1
ffffffffc0202ff2:	94dff0ef          	jal	ra,ffffffffc020293e <find_vma>
        assert(vma4 == NULL);
ffffffffc0202ff6:	1a051863          	bnez	a0,ffffffffc02031a6 <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0202ffa:	00440593          	addi	a1,s0,4
ffffffffc0202ffe:	8526                	mv	a0,s1
ffffffffc0203000:	93fff0ef          	jal	ra,ffffffffc020293e <find_vma>
        assert(vma5 == NULL);
ffffffffc0203004:	18051163          	bnez	a0,ffffffffc0203186 <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203008:	00893783          	ld	a5,8(s2)
ffffffffc020300c:	0a879d63          	bne	a5,s0,ffffffffc02030c6 <vmm_init+0x204>
ffffffffc0203010:	01093783          	ld	a5,16(s2)
ffffffffc0203014:	0b479963          	bne	a5,s4,ffffffffc02030c6 <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203018:	0089b783          	ld	a5,8(s3)
ffffffffc020301c:	0c879563          	bne	a5,s0,ffffffffc02030e6 <vmm_init+0x224>
ffffffffc0203020:	0109b783          	ld	a5,16(s3)
ffffffffc0203024:	0d479163          	bne	a5,s4,ffffffffc02030e6 <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203028:	0415                	addi	s0,s0,5
ffffffffc020302a:	0a15                	addi	s4,s4,5
ffffffffc020302c:	f9541be3          	bne	s0,s5,ffffffffc0202fc2 <vmm_init+0x100>
ffffffffc0203030:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203032:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203034:	85a2                	mv	a1,s0
ffffffffc0203036:	8526                	mv	a0,s1
ffffffffc0203038:	907ff0ef          	jal	ra,ffffffffc020293e <find_vma>
ffffffffc020303c:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203040:	c90d                	beqz	a0,ffffffffc0203072 <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203042:	6914                	ld	a3,16(a0)
ffffffffc0203044:	6510                	ld	a2,8(a0)
ffffffffc0203046:	00004517          	auipc	a0,0x4
ffffffffc020304a:	ee250513          	addi	a0,a0,-286 # ffffffffc0206f28 <commands+0x1270>
ffffffffc020304e:	892fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203052:	00004697          	auipc	a3,0x4
ffffffffc0203056:	efe68693          	addi	a3,a3,-258 # ffffffffc0206f50 <commands+0x1298>
ffffffffc020305a:	00003617          	auipc	a2,0x3
ffffffffc020305e:	4f660613          	addi	a2,a2,1270 # ffffffffc0206550 <commands+0x898>
ffffffffc0203062:	1ac00593          	li	a1,428
ffffffffc0203066:	00004517          	auipc	a0,0x4
ffffffffc020306a:	b4250513          	addi	a0,a0,-1214 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc020306e:	9b0fd0ef          	jal	ra,ffffffffc020021e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203072:	147d                	addi	s0,s0,-1
ffffffffc0203074:	fd2410e3          	bne	s0,s2,ffffffffc0203034 <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0203078:	8526                	mv	a0,s1
ffffffffc020307a:	9d5ff0ef          	jal	ra,ffffffffc0202a4e <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020307e:	00004517          	auipc	a0,0x4
ffffffffc0203082:	eea50513          	addi	a0,a0,-278 # ffffffffc0206f68 <commands+0x12b0>
ffffffffc0203086:	85afd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc020308a:	7442                	ld	s0,48(sp)
ffffffffc020308c:	70e2                	ld	ra,56(sp)
ffffffffc020308e:	74a2                	ld	s1,40(sp)
ffffffffc0203090:	7902                	ld	s2,32(sp)
ffffffffc0203092:	69e2                	ld	s3,24(sp)
ffffffffc0203094:	6a42                	ld	s4,16(sp)
ffffffffc0203096:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203098:	00004517          	auipc	a0,0x4
ffffffffc020309c:	ef050513          	addi	a0,a0,-272 # ffffffffc0206f88 <commands+0x12d0>
}
ffffffffc02030a0:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02030a2:	83efd06f          	j	ffffffffc02000e0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02030a6:	00004697          	auipc	a3,0x4
ffffffffc02030aa:	d9a68693          	addi	a3,a3,-614 # ffffffffc0206e40 <commands+0x1188>
ffffffffc02030ae:	00003617          	auipc	a2,0x3
ffffffffc02030b2:	4a260613          	addi	a2,a2,1186 # ffffffffc0206550 <commands+0x898>
ffffffffc02030b6:	19000593          	li	a1,400
ffffffffc02030ba:	00004517          	auipc	a0,0x4
ffffffffc02030be:	aee50513          	addi	a0,a0,-1298 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc02030c2:	95cfd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02030c6:	00004697          	auipc	a3,0x4
ffffffffc02030ca:	e0268693          	addi	a3,a3,-510 # ffffffffc0206ec8 <commands+0x1210>
ffffffffc02030ce:	00003617          	auipc	a2,0x3
ffffffffc02030d2:	48260613          	addi	a2,a2,1154 # ffffffffc0206550 <commands+0x898>
ffffffffc02030d6:	1a100593          	li	a1,417
ffffffffc02030da:	00004517          	auipc	a0,0x4
ffffffffc02030de:	ace50513          	addi	a0,a0,-1330 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc02030e2:	93cfd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02030e6:	00004697          	auipc	a3,0x4
ffffffffc02030ea:	e1268693          	addi	a3,a3,-494 # ffffffffc0206ef8 <commands+0x1240>
ffffffffc02030ee:	00003617          	auipc	a2,0x3
ffffffffc02030f2:	46260613          	addi	a2,a2,1122 # ffffffffc0206550 <commands+0x898>
ffffffffc02030f6:	1a200593          	li	a1,418
ffffffffc02030fa:	00004517          	auipc	a0,0x4
ffffffffc02030fe:	aae50513          	addi	a0,a0,-1362 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0203102:	91cfd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203106:	00004697          	auipc	a3,0x4
ffffffffc020310a:	d2268693          	addi	a3,a3,-734 # ffffffffc0206e28 <commands+0x1170>
ffffffffc020310e:	00003617          	auipc	a2,0x3
ffffffffc0203112:	44260613          	addi	a2,a2,1090 # ffffffffc0206550 <commands+0x898>
ffffffffc0203116:	18e00593          	li	a1,398
ffffffffc020311a:	00004517          	auipc	a0,0x4
ffffffffc020311e:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0203122:	8fcfd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma2 != NULL);
ffffffffc0203126:	00004697          	auipc	a3,0x4
ffffffffc020312a:	d6268693          	addi	a3,a3,-670 # ffffffffc0206e88 <commands+0x11d0>
ffffffffc020312e:	00003617          	auipc	a2,0x3
ffffffffc0203132:	42260613          	addi	a2,a2,1058 # ffffffffc0206550 <commands+0x898>
ffffffffc0203136:	19900593          	li	a1,409
ffffffffc020313a:	00004517          	auipc	a0,0x4
ffffffffc020313e:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0203142:	8dcfd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma1 != NULL);
ffffffffc0203146:	00004697          	auipc	a3,0x4
ffffffffc020314a:	d3268693          	addi	a3,a3,-718 # ffffffffc0206e78 <commands+0x11c0>
ffffffffc020314e:	00003617          	auipc	a2,0x3
ffffffffc0203152:	40260613          	addi	a2,a2,1026 # ffffffffc0206550 <commands+0x898>
ffffffffc0203156:	19700593          	li	a1,407
ffffffffc020315a:	00004517          	auipc	a0,0x4
ffffffffc020315e:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0203162:	8bcfd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma3 == NULL);
ffffffffc0203166:	00004697          	auipc	a3,0x4
ffffffffc020316a:	d3268693          	addi	a3,a3,-718 # ffffffffc0206e98 <commands+0x11e0>
ffffffffc020316e:	00003617          	auipc	a2,0x3
ffffffffc0203172:	3e260613          	addi	a2,a2,994 # ffffffffc0206550 <commands+0x898>
ffffffffc0203176:	19b00593          	li	a1,411
ffffffffc020317a:	00004517          	auipc	a0,0x4
ffffffffc020317e:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc0203182:	89cfd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma5 == NULL);
ffffffffc0203186:	00004697          	auipc	a3,0x4
ffffffffc020318a:	d3268693          	addi	a3,a3,-718 # ffffffffc0206eb8 <commands+0x1200>
ffffffffc020318e:	00003617          	auipc	a2,0x3
ffffffffc0203192:	3c260613          	addi	a2,a2,962 # ffffffffc0206550 <commands+0x898>
ffffffffc0203196:	19f00593          	li	a1,415
ffffffffc020319a:	00004517          	auipc	a0,0x4
ffffffffc020319e:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc02031a2:	87cfd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma4 == NULL);
ffffffffc02031a6:	00004697          	auipc	a3,0x4
ffffffffc02031aa:	d0268693          	addi	a3,a3,-766 # ffffffffc0206ea8 <commands+0x11f0>
ffffffffc02031ae:	00003617          	auipc	a2,0x3
ffffffffc02031b2:	3a260613          	addi	a2,a2,930 # ffffffffc0206550 <commands+0x898>
ffffffffc02031b6:	19d00593          	li	a1,413
ffffffffc02031ba:	00004517          	auipc	a0,0x4
ffffffffc02031be:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc02031c2:	85cfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(mm != NULL);
ffffffffc02031c6:	00004697          	auipc	a3,0x4
ffffffffc02031ca:	a6a68693          	addi	a3,a3,-1430 # ffffffffc0206c30 <commands+0xf78>
ffffffffc02031ce:	00003617          	auipc	a2,0x3
ffffffffc02031d2:	38260613          	addi	a2,a2,898 # ffffffffc0206550 <commands+0x898>
ffffffffc02031d6:	17700593          	li	a1,375
ffffffffc02031da:	00004517          	auipc	a0,0x4
ffffffffc02031de:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0206ba8 <commands+0xef0>
ffffffffc02031e2:	83cfd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02031e6 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc02031e6:	7179                	addi	sp,sp,-48
ffffffffc02031e8:	f022                	sd	s0,32(sp)
ffffffffc02031ea:	f406                	sd	ra,40(sp)
ffffffffc02031ec:	ec26                	sd	s1,24(sp)
ffffffffc02031ee:	e84a                	sd	s2,16(sp)
ffffffffc02031f0:	e44e                	sd	s3,8(sp)
ffffffffc02031f2:	e052                	sd	s4,0(sp)
ffffffffc02031f4:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc02031f6:	c135                	beqz	a0,ffffffffc020325a <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc02031f8:	002007b7          	lui	a5,0x200
ffffffffc02031fc:	04f5e663          	bltu	a1,a5,ffffffffc0203248 <user_mem_check+0x62>
ffffffffc0203200:	00c584b3          	add	s1,a1,a2
ffffffffc0203204:	0495f263          	bgeu	a1,s1,ffffffffc0203248 <user_mem_check+0x62>
ffffffffc0203208:	4785                	li	a5,1
ffffffffc020320a:	07fe                	slli	a5,a5,0x1f
ffffffffc020320c:	0297ee63          	bltu	a5,s1,ffffffffc0203248 <user_mem_check+0x62>
ffffffffc0203210:	892a                	mv	s2,a0
ffffffffc0203212:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203214:	6a05                	lui	s4,0x1
ffffffffc0203216:	a821                	j	ffffffffc020322e <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203218:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc020321c:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc020321e:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203220:	c685                	beqz	a3,ffffffffc0203248 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203222:	c399                	beqz	a5,ffffffffc0203228 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203224:	02e46263          	bltu	s0,a4,ffffffffc0203248 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203228:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc020322a:	04947663          	bgeu	s0,s1,ffffffffc0203276 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc020322e:	85a2                	mv	a1,s0
ffffffffc0203230:	854a                	mv	a0,s2
ffffffffc0203232:	f0cff0ef          	jal	ra,ffffffffc020293e <find_vma>
ffffffffc0203236:	c909                	beqz	a0,ffffffffc0203248 <user_mem_check+0x62>
ffffffffc0203238:	6518                	ld	a4,8(a0)
ffffffffc020323a:	00e46763          	bltu	s0,a4,ffffffffc0203248 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc020323e:	4d1c                	lw	a5,24(a0)
ffffffffc0203240:	fc099ce3          	bnez	s3,ffffffffc0203218 <user_mem_check+0x32>
ffffffffc0203244:	8b85                	andi	a5,a5,1
ffffffffc0203246:	f3ed                	bnez	a5,ffffffffc0203228 <user_mem_check+0x42>
            return 0;
ffffffffc0203248:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc020324a:	70a2                	ld	ra,40(sp)
ffffffffc020324c:	7402                	ld	s0,32(sp)
ffffffffc020324e:	64e2                	ld	s1,24(sp)
ffffffffc0203250:	6942                	ld	s2,16(sp)
ffffffffc0203252:	69a2                	ld	s3,8(sp)
ffffffffc0203254:	6a02                	ld	s4,0(sp)
ffffffffc0203256:	6145                	addi	sp,sp,48
ffffffffc0203258:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc020325a:	c02007b7          	lui	a5,0xc0200
ffffffffc020325e:	4501                	li	a0,0
ffffffffc0203260:	fef5e5e3          	bltu	a1,a5,ffffffffc020324a <user_mem_check+0x64>
ffffffffc0203264:	962e                	add	a2,a2,a1
ffffffffc0203266:	fec5f2e3          	bgeu	a1,a2,ffffffffc020324a <user_mem_check+0x64>
ffffffffc020326a:	c8000537          	lui	a0,0xc8000
ffffffffc020326e:	0505                	addi	a0,a0,1
ffffffffc0203270:	00a63533          	sltu	a0,a2,a0
ffffffffc0203274:	bfd9                	j	ffffffffc020324a <user_mem_check+0x64>
        return 1;
ffffffffc0203276:	4505                	li	a0,1
ffffffffc0203278:	bfc9                	j	ffffffffc020324a <user_mem_check+0x64>

ffffffffc020327a <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc020327a:	c94d                	beqz	a0,ffffffffc020332c <slob_free+0xb2>
{
ffffffffc020327c:	1141                	addi	sp,sp,-16
ffffffffc020327e:	e022                	sd	s0,0(sp)
ffffffffc0203280:	e406                	sd	ra,8(sp)
ffffffffc0203282:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0203284:	e9c1                	bnez	a1,ffffffffc0203314 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203286:	100027f3          	csrr	a5,sstatus
ffffffffc020328a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020328c:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020328e:	ebd9                	bnez	a5,ffffffffc0203324 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203290:	000ae617          	auipc	a2,0xae
ffffffffc0203294:	9d060613          	addi	a2,a2,-1584 # ffffffffc02b0c60 <slobfree>
ffffffffc0203298:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020329a:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020329c:	679c                	ld	a5,8(a5)
ffffffffc020329e:	02877a63          	bgeu	a4,s0,ffffffffc02032d2 <slob_free+0x58>
ffffffffc02032a2:	00f46463          	bltu	s0,a5,ffffffffc02032aa <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02032a6:	fef76ae3          	bltu	a4,a5,ffffffffc020329a <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc02032aa:	400c                	lw	a1,0(s0)
ffffffffc02032ac:	00459693          	slli	a3,a1,0x4
ffffffffc02032b0:	96a2                	add	a3,a3,s0
ffffffffc02032b2:	02d78a63          	beq	a5,a3,ffffffffc02032e6 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc02032b6:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc02032b8:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc02032ba:	00469793          	slli	a5,a3,0x4
ffffffffc02032be:	97ba                	add	a5,a5,a4
ffffffffc02032c0:	02f40e63          	beq	s0,a5,ffffffffc02032fc <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc02032c4:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc02032c6:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc02032c8:	e129                	bnez	a0,ffffffffc020330a <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02032ca:	60a2                	ld	ra,8(sp)
ffffffffc02032cc:	6402                	ld	s0,0(sp)
ffffffffc02032ce:	0141                	addi	sp,sp,16
ffffffffc02032d0:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02032d2:	fcf764e3          	bltu	a4,a5,ffffffffc020329a <slob_free+0x20>
ffffffffc02032d6:	fcf472e3          	bgeu	s0,a5,ffffffffc020329a <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc02032da:	400c                	lw	a1,0(s0)
ffffffffc02032dc:	00459693          	slli	a3,a1,0x4
ffffffffc02032e0:	96a2                	add	a3,a3,s0
ffffffffc02032e2:	fcd79ae3          	bne	a5,a3,ffffffffc02032b6 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc02032e6:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02032e8:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc02032ea:	9db5                	addw	a1,a1,a3
ffffffffc02032ec:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc02032ee:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02032f0:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc02032f2:	00469793          	slli	a5,a3,0x4
ffffffffc02032f6:	97ba                	add	a5,a5,a4
ffffffffc02032f8:	fcf416e3          	bne	s0,a5,ffffffffc02032c4 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc02032fc:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc02032fe:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0203300:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0203302:	9ebd                	addw	a3,a3,a5
ffffffffc0203304:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0203306:	e70c                	sd	a1,8(a4)
ffffffffc0203308:	d169                	beqz	a0,ffffffffc02032ca <slob_free+0x50>
}
ffffffffc020330a:	6402                	ld	s0,0(sp)
ffffffffc020330c:	60a2                	ld	ra,8(sp)
ffffffffc020330e:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0203310:	ea4fd06f          	j	ffffffffc02009b4 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0203314:	25bd                	addiw	a1,a1,15
ffffffffc0203316:	8191                	srli	a1,a1,0x4
ffffffffc0203318:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020331a:	100027f3          	csrr	a5,sstatus
ffffffffc020331e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203320:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203322:	d7bd                	beqz	a5,ffffffffc0203290 <slob_free+0x16>
        intr_disable();
ffffffffc0203324:	e96fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc0203328:	4505                	li	a0,1
ffffffffc020332a:	b79d                	j	ffffffffc0203290 <slob_free+0x16>
ffffffffc020332c:	8082                	ret

ffffffffc020332e <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc020332e:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0203330:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0203332:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0203336:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0203338:	d53fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
	if (!page)
ffffffffc020333c:	c91d                	beqz	a0,ffffffffc0203372 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc020333e:	000b2697          	auipc	a3,0xb2
ffffffffc0203342:	da26b683          	ld	a3,-606(a3) # ffffffffc02b50e0 <pages>
ffffffffc0203346:	8d15                	sub	a0,a0,a3
ffffffffc0203348:	8519                	srai	a0,a0,0x6
ffffffffc020334a:	00005697          	auipc	a3,0x5
ffffffffc020334e:	9ae6b683          	ld	a3,-1618(a3) # ffffffffc0207cf8 <nbase>
ffffffffc0203352:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0203354:	00c51793          	slli	a5,a0,0xc
ffffffffc0203358:	83b1                	srli	a5,a5,0xc
ffffffffc020335a:	000b2717          	auipc	a4,0xb2
ffffffffc020335e:	d7e73703          	ld	a4,-642(a4) # ffffffffc02b50d8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0203362:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0203364:	00e7fa63          	bgeu	a5,a4,ffffffffc0203378 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0203368:	000b2697          	auipc	a3,0xb2
ffffffffc020336c:	d886b683          	ld	a3,-632(a3) # ffffffffc02b50f0 <va_pa_offset>
ffffffffc0203370:	9536                	add	a0,a0,a3
}
ffffffffc0203372:	60a2                	ld	ra,8(sp)
ffffffffc0203374:	0141                	addi	sp,sp,16
ffffffffc0203376:	8082                	ret
ffffffffc0203378:	86aa                	mv	a3,a0
ffffffffc020337a:	00003617          	auipc	a2,0x3
ffffffffc020337e:	16e60613          	addi	a2,a2,366 # ffffffffc02064e8 <commands+0x830>
ffffffffc0203382:	07100593          	li	a1,113
ffffffffc0203386:	00003517          	auipc	a0,0x3
ffffffffc020338a:	12a50513          	addi	a0,a0,298 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc020338e:	e91fc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203392 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0203392:	1101                	addi	sp,sp,-32
ffffffffc0203394:	ec06                	sd	ra,24(sp)
ffffffffc0203396:	e822                	sd	s0,16(sp)
ffffffffc0203398:	e426                	sd	s1,8(sp)
ffffffffc020339a:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc020339c:	01050713          	addi	a4,a0,16
ffffffffc02033a0:	6785                	lui	a5,0x1
ffffffffc02033a2:	0cf77363          	bgeu	a4,a5,ffffffffc0203468 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02033a6:	00f50493          	addi	s1,a0,15
ffffffffc02033aa:	8091                	srli	s1,s1,0x4
ffffffffc02033ac:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02033ae:	10002673          	csrr	a2,sstatus
ffffffffc02033b2:	8a09                	andi	a2,a2,2
ffffffffc02033b4:	e25d                	bnez	a2,ffffffffc020345a <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02033b6:	000ae917          	auipc	s2,0xae
ffffffffc02033ba:	8aa90913          	addi	s2,s2,-1878 # ffffffffc02b0c60 <slobfree>
ffffffffc02033be:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02033c2:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc02033c4:	4398                	lw	a4,0(a5)
ffffffffc02033c6:	08975e63          	bge	a4,s1,ffffffffc0203462 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc02033ca:	00f68b63          	beq	a3,a5,ffffffffc02033e0 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02033ce:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc02033d0:	4018                	lw	a4,0(s0)
ffffffffc02033d2:	02975a63          	bge	a4,s1,ffffffffc0203406 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc02033d6:	00093683          	ld	a3,0(s2)
ffffffffc02033da:	87a2                	mv	a5,s0
ffffffffc02033dc:	fef699e3          	bne	a3,a5,ffffffffc02033ce <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc02033e0:	ee31                	bnez	a2,ffffffffc020343c <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02033e2:	4501                	li	a0,0
ffffffffc02033e4:	f4bff0ef          	jal	ra,ffffffffc020332e <__slob_get_free_pages.constprop.0>
ffffffffc02033e8:	842a                	mv	s0,a0
			if (!cur)
ffffffffc02033ea:	cd05                	beqz	a0,ffffffffc0203422 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc02033ec:	6585                	lui	a1,0x1
ffffffffc02033ee:	e8dff0ef          	jal	ra,ffffffffc020327a <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02033f2:	10002673          	csrr	a2,sstatus
ffffffffc02033f6:	8a09                	andi	a2,a2,2
ffffffffc02033f8:	ee05                	bnez	a2,ffffffffc0203430 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc02033fa:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02033fe:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0203400:	4018                	lw	a4,0(s0)
ffffffffc0203402:	fc974ae3          	blt	a4,s1,ffffffffc02033d6 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0203406:	04e48763          	beq	s1,a4,ffffffffc0203454 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc020340a:	00449693          	slli	a3,s1,0x4
ffffffffc020340e:	96a2                	add	a3,a3,s0
ffffffffc0203410:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0203412:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0203414:	9f05                	subw	a4,a4,s1
ffffffffc0203416:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0203418:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc020341a:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020341c:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0203420:	e20d                	bnez	a2,ffffffffc0203442 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0203422:	60e2                	ld	ra,24(sp)
ffffffffc0203424:	8522                	mv	a0,s0
ffffffffc0203426:	6442                	ld	s0,16(sp)
ffffffffc0203428:	64a2                	ld	s1,8(sp)
ffffffffc020342a:	6902                	ld	s2,0(sp)
ffffffffc020342c:	6105                	addi	sp,sp,32
ffffffffc020342e:	8082                	ret
        intr_disable();
ffffffffc0203430:	d8afd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
			cur = slobfree;
ffffffffc0203434:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0203438:	4605                	li	a2,1
ffffffffc020343a:	b7d1                	j	ffffffffc02033fe <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc020343c:	d78fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203440:	b74d                	j	ffffffffc02033e2 <slob_alloc.constprop.0+0x50>
ffffffffc0203442:	d72fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
}
ffffffffc0203446:	60e2                	ld	ra,24(sp)
ffffffffc0203448:	8522                	mv	a0,s0
ffffffffc020344a:	6442                	ld	s0,16(sp)
ffffffffc020344c:	64a2                	ld	s1,8(sp)
ffffffffc020344e:	6902                	ld	s2,0(sp)
ffffffffc0203450:	6105                	addi	sp,sp,32
ffffffffc0203452:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0203454:	6418                	ld	a4,8(s0)
ffffffffc0203456:	e798                	sd	a4,8(a5)
ffffffffc0203458:	b7d1                	j	ffffffffc020341c <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc020345a:	d60fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc020345e:	4605                	li	a2,1
ffffffffc0203460:	bf99                	j	ffffffffc02033b6 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0203462:	843e                	mv	s0,a5
ffffffffc0203464:	87b6                	mv	a5,a3
ffffffffc0203466:	b745                	j	ffffffffc0203406 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0203468:	00004697          	auipc	a3,0x4
ffffffffc020346c:	b4868693          	addi	a3,a3,-1208 # ffffffffc0206fb0 <commands+0x12f8>
ffffffffc0203470:	00003617          	auipc	a2,0x3
ffffffffc0203474:	0e060613          	addi	a2,a2,224 # ffffffffc0206550 <commands+0x898>
ffffffffc0203478:	06300593          	li	a1,99
ffffffffc020347c:	00004517          	auipc	a0,0x4
ffffffffc0203480:	b5450513          	addi	a0,a0,-1196 # ffffffffc0206fd0 <commands+0x1318>
ffffffffc0203484:	d9bfc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203488 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0203488:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc020348a:	00004517          	auipc	a0,0x4
ffffffffc020348e:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0206fe8 <commands+0x1330>
{
ffffffffc0203492:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0203494:	c4dfc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0203498:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc020349a:	00004517          	auipc	a0,0x4
ffffffffc020349e:	b6650513          	addi	a0,a0,-1178 # ffffffffc0207000 <commands+0x1348>
}
ffffffffc02034a2:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc02034a4:	c3dfc06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc02034a8 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc02034a8:	4501                	li	a0,0
ffffffffc02034aa:	8082                	ret

ffffffffc02034ac <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02034ac:	1101                	addi	sp,sp,-32
ffffffffc02034ae:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc02034b0:	6905                	lui	s2,0x1
{
ffffffffc02034b2:	e822                	sd	s0,16(sp)
ffffffffc02034b4:	ec06                	sd	ra,24(sp)
ffffffffc02034b6:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc02034b8:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc9>
{
ffffffffc02034bc:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc02034be:	04a7f963          	bgeu	a5,a0,ffffffffc0203510 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02034c2:	4561                	li	a0,24
ffffffffc02034c4:	ecfff0ef          	jal	ra,ffffffffc0203392 <slob_alloc.constprop.0>
ffffffffc02034c8:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02034ca:	c929                	beqz	a0,ffffffffc020351c <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc02034cc:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02034d0:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc02034d2:	00f95763          	bge	s2,a5,ffffffffc02034e0 <kmalloc+0x34>
ffffffffc02034d6:	6705                	lui	a4,0x1
ffffffffc02034d8:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02034da:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc02034dc:	fef74ee3          	blt	a4,a5,ffffffffc02034d8 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02034e0:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02034e2:	e4dff0ef          	jal	ra,ffffffffc020332e <__slob_get_free_pages.constprop.0>
ffffffffc02034e6:	e488                	sd	a0,8(s1)
ffffffffc02034e8:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc02034ea:	c525                	beqz	a0,ffffffffc0203552 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02034ec:	100027f3          	csrr	a5,sstatus
ffffffffc02034f0:	8b89                	andi	a5,a5,2
ffffffffc02034f2:	ef8d                	bnez	a5,ffffffffc020352c <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc02034f4:	000b2797          	auipc	a5,0xb2
ffffffffc02034f8:	c0c78793          	addi	a5,a5,-1012 # ffffffffc02b5100 <bigblocks>
ffffffffc02034fc:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02034fe:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0203500:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0203502:	60e2                	ld	ra,24(sp)
ffffffffc0203504:	8522                	mv	a0,s0
ffffffffc0203506:	6442                	ld	s0,16(sp)
ffffffffc0203508:	64a2                	ld	s1,8(sp)
ffffffffc020350a:	6902                	ld	s2,0(sp)
ffffffffc020350c:	6105                	addi	sp,sp,32
ffffffffc020350e:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0203510:	0541                	addi	a0,a0,16
ffffffffc0203512:	e81ff0ef          	jal	ra,ffffffffc0203392 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0203516:	01050413          	addi	s0,a0,16
ffffffffc020351a:	f565                	bnez	a0,ffffffffc0203502 <kmalloc+0x56>
ffffffffc020351c:	4401                	li	s0,0
}
ffffffffc020351e:	60e2                	ld	ra,24(sp)
ffffffffc0203520:	8522                	mv	a0,s0
ffffffffc0203522:	6442                	ld	s0,16(sp)
ffffffffc0203524:	64a2                	ld	s1,8(sp)
ffffffffc0203526:	6902                	ld	s2,0(sp)
ffffffffc0203528:	6105                	addi	sp,sp,32
ffffffffc020352a:	8082                	ret
        intr_disable();
ffffffffc020352c:	c8efd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
		bb->next = bigblocks;
ffffffffc0203530:	000b2797          	auipc	a5,0xb2
ffffffffc0203534:	bd078793          	addi	a5,a5,-1072 # ffffffffc02b5100 <bigblocks>
ffffffffc0203538:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020353a:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020353c:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc020353e:	c76fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
		return bb->pages;
ffffffffc0203542:	6480                	ld	s0,8(s1)
}
ffffffffc0203544:	60e2                	ld	ra,24(sp)
ffffffffc0203546:	64a2                	ld	s1,8(sp)
ffffffffc0203548:	8522                	mv	a0,s0
ffffffffc020354a:	6442                	ld	s0,16(sp)
ffffffffc020354c:	6902                	ld	s2,0(sp)
ffffffffc020354e:	6105                	addi	sp,sp,32
ffffffffc0203550:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0203552:	45e1                	li	a1,24
ffffffffc0203554:	8526                	mv	a0,s1
ffffffffc0203556:	d25ff0ef          	jal	ra,ffffffffc020327a <slob_free>
	return __kmalloc(size, 0);
ffffffffc020355a:	b765                	j	ffffffffc0203502 <kmalloc+0x56>

ffffffffc020355c <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc020355c:	c179                	beqz	a0,ffffffffc0203622 <kfree+0xc6>
{
ffffffffc020355e:	1101                	addi	sp,sp,-32
ffffffffc0203560:	e822                	sd	s0,16(sp)
ffffffffc0203562:	ec06                	sd	ra,24(sp)
ffffffffc0203564:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0203566:	03451793          	slli	a5,a0,0x34
ffffffffc020356a:	842a                	mv	s0,a0
ffffffffc020356c:	e7c1                	bnez	a5,ffffffffc02035f4 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020356e:	100027f3          	csrr	a5,sstatus
ffffffffc0203572:	8b89                	andi	a5,a5,2
ffffffffc0203574:	ebc9                	bnez	a5,ffffffffc0203606 <kfree+0xaa>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0203576:	000b2797          	auipc	a5,0xb2
ffffffffc020357a:	b8a7b783          	ld	a5,-1142(a5) # ffffffffc02b5100 <bigblocks>
    return 0;
ffffffffc020357e:	4601                	li	a2,0
ffffffffc0203580:	cbb5                	beqz	a5,ffffffffc02035f4 <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0203582:	000b2697          	auipc	a3,0xb2
ffffffffc0203586:	b7e68693          	addi	a3,a3,-1154 # ffffffffc02b5100 <bigblocks>
ffffffffc020358a:	a021                	j	ffffffffc0203592 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc020358c:	01048693          	addi	a3,s1,16
ffffffffc0203590:	c3ad                	beqz	a5,ffffffffc02035f2 <kfree+0x96>
		{
			if (bb->pages == block)
ffffffffc0203592:	6798                	ld	a4,8(a5)
ffffffffc0203594:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0203596:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0203598:	fe871ae3          	bne	a4,s0,ffffffffc020358c <kfree+0x30>
				*last = bb->next;
ffffffffc020359c:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc020359e:	ee3d                	bnez	a2,ffffffffc020361c <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc02035a0:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02035a4:	4098                	lw	a4,0(s1)
ffffffffc02035a6:	08f46b63          	bltu	s0,a5,ffffffffc020363c <kfree+0xe0>
ffffffffc02035aa:	000b2697          	auipc	a3,0xb2
ffffffffc02035ae:	b466b683          	ld	a3,-1210(a3) # ffffffffc02b50f0 <va_pa_offset>
ffffffffc02035b2:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc02035b4:	8031                	srli	s0,s0,0xc
ffffffffc02035b6:	000b2797          	auipc	a5,0xb2
ffffffffc02035ba:	b227b783          	ld	a5,-1246(a5) # ffffffffc02b50d8 <npage>
ffffffffc02035be:	06f47363          	bgeu	s0,a5,ffffffffc0203624 <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc02035c2:	00004517          	auipc	a0,0x4
ffffffffc02035c6:	73653503          	ld	a0,1846(a0) # ffffffffc0207cf8 <nbase>
ffffffffc02035ca:	8c09                	sub	s0,s0,a0
ffffffffc02035cc:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc02035ce:	000b2517          	auipc	a0,0xb2
ffffffffc02035d2:	b1253503          	ld	a0,-1262(a0) # ffffffffc02b50e0 <pages>
ffffffffc02035d6:	4585                	li	a1,1
ffffffffc02035d8:	9522                	add	a0,a0,s0
ffffffffc02035da:	00e595bb          	sllw	a1,a1,a4
ffffffffc02035de:	aebfd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02035e2:	6442                	ld	s0,16(sp)
ffffffffc02035e4:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02035e6:	8526                	mv	a0,s1
}
ffffffffc02035e8:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02035ea:	45e1                	li	a1,24
}
ffffffffc02035ec:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02035ee:	c8dff06f          	j	ffffffffc020327a <slob_free>
ffffffffc02035f2:	e215                	bnez	a2,ffffffffc0203616 <kfree+0xba>
ffffffffc02035f4:	ff040513          	addi	a0,s0,-16
}
ffffffffc02035f8:	6442                	ld	s0,16(sp)
ffffffffc02035fa:	60e2                	ld	ra,24(sp)
ffffffffc02035fc:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02035fe:	4581                	li	a1,0
}
ffffffffc0203600:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203602:	c79ff06f          	j	ffffffffc020327a <slob_free>
        intr_disable();
ffffffffc0203606:	bb4fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc020360a:	000b2797          	auipc	a5,0xb2
ffffffffc020360e:	af67b783          	ld	a5,-1290(a5) # ffffffffc02b5100 <bigblocks>
        return 1;
ffffffffc0203612:	4605                	li	a2,1
ffffffffc0203614:	f7bd                	bnez	a5,ffffffffc0203582 <kfree+0x26>
        intr_enable();
ffffffffc0203616:	b9efd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc020361a:	bfe9                	j	ffffffffc02035f4 <kfree+0x98>
ffffffffc020361c:	b98fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203620:	b741                	j	ffffffffc02035a0 <kfree+0x44>
ffffffffc0203622:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0203624:	00003617          	auipc	a2,0x3
ffffffffc0203628:	e6c60613          	addi	a2,a2,-404 # ffffffffc0206490 <commands+0x7d8>
ffffffffc020362c:	06900593          	li	a1,105
ffffffffc0203630:	00003517          	auipc	a0,0x3
ffffffffc0203634:	e8050513          	addi	a0,a0,-384 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc0203638:	be7fc0ef          	jal	ra,ffffffffc020021e <__panic>
    return pa2page(PADDR(kva));
ffffffffc020363c:	86a2                	mv	a3,s0
ffffffffc020363e:	00003617          	auipc	a2,0x3
ffffffffc0203642:	fba60613          	addi	a2,a2,-70 # ffffffffc02065f8 <commands+0x940>
ffffffffc0203646:	07700593          	li	a1,119
ffffffffc020364a:	00003517          	auipc	a0,0x3
ffffffffc020364e:	e6650513          	addi	a0,a0,-410 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc0203652:	bcdfc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203656 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0203656:	000ae797          	auipc	a5,0xae
ffffffffc020365a:	a1a78793          	addi	a5,a5,-1510 # ffffffffc02b1070 <free_area>
ffffffffc020365e:	e79c                	sd	a5,8(a5)
ffffffffc0203660:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0203662:	0007a823          	sw	zero,16(a5)
}
ffffffffc0203666:	8082                	ret

ffffffffc0203668 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0203668:	000ae517          	auipc	a0,0xae
ffffffffc020366c:	a1856503          	lwu	a0,-1512(a0) # ffffffffc02b1080 <free_area+0x10>
ffffffffc0203670:	8082                	ret

ffffffffc0203672 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0203672:	715d                	addi	sp,sp,-80
ffffffffc0203674:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0203676:	000ae417          	auipc	s0,0xae
ffffffffc020367a:	9fa40413          	addi	s0,s0,-1542 # ffffffffc02b1070 <free_area>
ffffffffc020367e:	641c                	ld	a5,8(s0)
ffffffffc0203680:	e486                	sd	ra,72(sp)
ffffffffc0203682:	fc26                	sd	s1,56(sp)
ffffffffc0203684:	f84a                	sd	s2,48(sp)
ffffffffc0203686:	f44e                	sd	s3,40(sp)
ffffffffc0203688:	f052                	sd	s4,32(sp)
ffffffffc020368a:	ec56                	sd	s5,24(sp)
ffffffffc020368c:	e85a                	sd	s6,16(sp)
ffffffffc020368e:	e45e                	sd	s7,8(sp)
ffffffffc0203690:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0203692:	2a878d63          	beq	a5,s0,ffffffffc020394c <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0203696:	4481                	li	s1,0
ffffffffc0203698:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020369a:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020369e:	8b09                	andi	a4,a4,2
ffffffffc02036a0:	2a070a63          	beqz	a4,ffffffffc0203954 <default_check+0x2e2>
        count++, total += p->property;
ffffffffc02036a4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02036a8:	679c                	ld	a5,8(a5)
ffffffffc02036aa:	2905                	addiw	s2,s2,1
ffffffffc02036ac:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02036ae:	fe8796e3          	bne	a5,s0,ffffffffc020369a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02036b2:	89a6                	mv	s3,s1
ffffffffc02036b4:	a55fd0ef          	jal	ra,ffffffffc0201108 <nr_free_pages>
ffffffffc02036b8:	6f351e63          	bne	a0,s3,ffffffffc0203db4 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02036bc:	4505                	li	a0,1
ffffffffc02036be:	9cdfd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02036c2:	8aaa                	mv	s5,a0
ffffffffc02036c4:	42050863          	beqz	a0,ffffffffc0203af4 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02036c8:	4505                	li	a0,1
ffffffffc02036ca:	9c1fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02036ce:	89aa                	mv	s3,a0
ffffffffc02036d0:	70050263          	beqz	a0,ffffffffc0203dd4 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02036d4:	4505                	li	a0,1
ffffffffc02036d6:	9b5fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02036da:	8a2a                	mv	s4,a0
ffffffffc02036dc:	48050c63          	beqz	a0,ffffffffc0203b74 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02036e0:	293a8a63          	beq	s5,s3,ffffffffc0203974 <default_check+0x302>
ffffffffc02036e4:	28aa8863          	beq	s5,a0,ffffffffc0203974 <default_check+0x302>
ffffffffc02036e8:	28a98663          	beq	s3,a0,ffffffffc0203974 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02036ec:	000aa783          	lw	a5,0(s5)
ffffffffc02036f0:	2a079263          	bnez	a5,ffffffffc0203994 <default_check+0x322>
ffffffffc02036f4:	0009a783          	lw	a5,0(s3)
ffffffffc02036f8:	28079e63          	bnez	a5,ffffffffc0203994 <default_check+0x322>
ffffffffc02036fc:	411c                	lw	a5,0(a0)
ffffffffc02036fe:	28079b63          	bnez	a5,ffffffffc0203994 <default_check+0x322>
    return page - pages + nbase;
ffffffffc0203702:	000b2797          	auipc	a5,0xb2
ffffffffc0203706:	9de7b783          	ld	a5,-1570(a5) # ffffffffc02b50e0 <pages>
ffffffffc020370a:	40fa8733          	sub	a4,s5,a5
ffffffffc020370e:	00004617          	auipc	a2,0x4
ffffffffc0203712:	5ea63603          	ld	a2,1514(a2) # ffffffffc0207cf8 <nbase>
ffffffffc0203716:	8719                	srai	a4,a4,0x6
ffffffffc0203718:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020371a:	000b2697          	auipc	a3,0xb2
ffffffffc020371e:	9be6b683          	ld	a3,-1602(a3) # ffffffffc02b50d8 <npage>
ffffffffc0203722:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203724:	0732                	slli	a4,a4,0xc
ffffffffc0203726:	28d77763          	bgeu	a4,a3,ffffffffc02039b4 <default_check+0x342>
    return page - pages + nbase;
ffffffffc020372a:	40f98733          	sub	a4,s3,a5
ffffffffc020372e:	8719                	srai	a4,a4,0x6
ffffffffc0203730:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203732:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203734:	4cd77063          	bgeu	a4,a3,ffffffffc0203bf4 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0203738:	40f507b3          	sub	a5,a0,a5
ffffffffc020373c:	8799                	srai	a5,a5,0x6
ffffffffc020373e:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203740:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203742:	30d7f963          	bgeu	a5,a3,ffffffffc0203a54 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0203746:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0203748:	00043c03          	ld	s8,0(s0)
ffffffffc020374c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0203750:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0203754:	e400                	sd	s0,8(s0)
ffffffffc0203756:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0203758:	000ae797          	auipc	a5,0xae
ffffffffc020375c:	9207a423          	sw	zero,-1752(a5) # ffffffffc02b1080 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0203760:	92bfd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0203764:	2c051863          	bnez	a0,ffffffffc0203a34 <default_check+0x3c2>
    free_page(p0);
ffffffffc0203768:	4585                	li	a1,1
ffffffffc020376a:	8556                	mv	a0,s5
ffffffffc020376c:	95dfd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_page(p1);
ffffffffc0203770:	4585                	li	a1,1
ffffffffc0203772:	854e                	mv	a0,s3
ffffffffc0203774:	955fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_page(p2);
ffffffffc0203778:	4585                	li	a1,1
ffffffffc020377a:	8552                	mv	a0,s4
ffffffffc020377c:	94dfd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    assert(nr_free == 3);
ffffffffc0203780:	4818                	lw	a4,16(s0)
ffffffffc0203782:	478d                	li	a5,3
ffffffffc0203784:	28f71863          	bne	a4,a5,ffffffffc0203a14 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203788:	4505                	li	a0,1
ffffffffc020378a:	901fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc020378e:	89aa                	mv	s3,a0
ffffffffc0203790:	26050263          	beqz	a0,ffffffffc02039f4 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203794:	4505                	li	a0,1
ffffffffc0203796:	8f5fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc020379a:	8aaa                	mv	s5,a0
ffffffffc020379c:	3a050c63          	beqz	a0,ffffffffc0203b54 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02037a0:	4505                	li	a0,1
ffffffffc02037a2:	8e9fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02037a6:	8a2a                	mv	s4,a0
ffffffffc02037a8:	38050663          	beqz	a0,ffffffffc0203b34 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc02037ac:	4505                	li	a0,1
ffffffffc02037ae:	8ddfd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02037b2:	36051163          	bnez	a0,ffffffffc0203b14 <default_check+0x4a2>
    free_page(p0);
ffffffffc02037b6:	4585                	li	a1,1
ffffffffc02037b8:	854e                	mv	a0,s3
ffffffffc02037ba:	90ffd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02037be:	641c                	ld	a5,8(s0)
ffffffffc02037c0:	20878a63          	beq	a5,s0,ffffffffc02039d4 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc02037c4:	4505                	li	a0,1
ffffffffc02037c6:	8c5fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02037ca:	30a99563          	bne	s3,a0,ffffffffc0203ad4 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc02037ce:	4505                	li	a0,1
ffffffffc02037d0:	8bbfd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02037d4:	2e051063          	bnez	a0,ffffffffc0203ab4 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc02037d8:	481c                	lw	a5,16(s0)
ffffffffc02037da:	2a079d63          	bnez	a5,ffffffffc0203a94 <default_check+0x422>
    free_page(p);
ffffffffc02037de:	854e                	mv	a0,s3
ffffffffc02037e0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02037e2:	01843023          	sd	s8,0(s0)
ffffffffc02037e6:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02037ea:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02037ee:	8dbfd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_page(p1);
ffffffffc02037f2:	4585                	li	a1,1
ffffffffc02037f4:	8556                	mv	a0,s5
ffffffffc02037f6:	8d3fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_page(p2);
ffffffffc02037fa:	4585                	li	a1,1
ffffffffc02037fc:	8552                	mv	a0,s4
ffffffffc02037fe:	8cbfd0ef          	jal	ra,ffffffffc02010c8 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0203802:	4515                	li	a0,5
ffffffffc0203804:	887fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0203808:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020380a:	26050563          	beqz	a0,ffffffffc0203a74 <default_check+0x402>
ffffffffc020380e:	651c                	ld	a5,8(a0)
ffffffffc0203810:	8385                	srli	a5,a5,0x1
ffffffffc0203812:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0203814:	54079063          	bnez	a5,ffffffffc0203d54 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0203818:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020381a:	00043b03          	ld	s6,0(s0)
ffffffffc020381e:	00843a83          	ld	s5,8(s0)
ffffffffc0203822:	e000                	sd	s0,0(s0)
ffffffffc0203824:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0203826:	865fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc020382a:	50051563          	bnez	a0,ffffffffc0203d34 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020382e:	08098a13          	addi	s4,s3,128
ffffffffc0203832:	8552                	mv	a0,s4
ffffffffc0203834:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0203836:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc020383a:	000ae797          	auipc	a5,0xae
ffffffffc020383e:	8407a323          	sw	zero,-1978(a5) # ffffffffc02b1080 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0203842:	887fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0203846:	4511                	li	a0,4
ffffffffc0203848:	843fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc020384c:	4c051463          	bnez	a0,ffffffffc0203d14 <default_check+0x6a2>
ffffffffc0203850:	0889b783          	ld	a5,136(s3)
ffffffffc0203854:	8385                	srli	a5,a5,0x1
ffffffffc0203856:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203858:	48078e63          	beqz	a5,ffffffffc0203cf4 <default_check+0x682>
ffffffffc020385c:	0909a703          	lw	a4,144(s3)
ffffffffc0203860:	478d                	li	a5,3
ffffffffc0203862:	48f71963          	bne	a4,a5,ffffffffc0203cf4 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203866:	450d                	li	a0,3
ffffffffc0203868:	823fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc020386c:	8c2a                	mv	s8,a0
ffffffffc020386e:	46050363          	beqz	a0,ffffffffc0203cd4 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0203872:	4505                	li	a0,1
ffffffffc0203874:	817fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0203878:	42051e63          	bnez	a0,ffffffffc0203cb4 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc020387c:	418a1c63          	bne	s4,s8,ffffffffc0203c94 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0203880:	4585                	li	a1,1
ffffffffc0203882:	854e                	mv	a0,s3
ffffffffc0203884:	845fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_pages(p1, 3);
ffffffffc0203888:	458d                	li	a1,3
ffffffffc020388a:	8552                	mv	a0,s4
ffffffffc020388c:	83dfd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
ffffffffc0203890:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0203894:	04098c13          	addi	s8,s3,64
ffffffffc0203898:	8385                	srli	a5,a5,0x1
ffffffffc020389a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020389c:	3c078c63          	beqz	a5,ffffffffc0203c74 <default_check+0x602>
ffffffffc02038a0:	0109a703          	lw	a4,16(s3)
ffffffffc02038a4:	4785                	li	a5,1
ffffffffc02038a6:	3cf71763          	bne	a4,a5,ffffffffc0203c74 <default_check+0x602>
ffffffffc02038aa:	008a3783          	ld	a5,8(s4) # 1008 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc02038ae:	8385                	srli	a5,a5,0x1
ffffffffc02038b0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02038b2:	3a078163          	beqz	a5,ffffffffc0203c54 <default_check+0x5e2>
ffffffffc02038b6:	010a2703          	lw	a4,16(s4)
ffffffffc02038ba:	478d                	li	a5,3
ffffffffc02038bc:	38f71c63          	bne	a4,a5,ffffffffc0203c54 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02038c0:	4505                	li	a0,1
ffffffffc02038c2:	fc8fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02038c6:	36a99763          	bne	s3,a0,ffffffffc0203c34 <default_check+0x5c2>
    free_page(p0);
ffffffffc02038ca:	4585                	li	a1,1
ffffffffc02038cc:	ffcfd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02038d0:	4509                	li	a0,2
ffffffffc02038d2:	fb8fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02038d6:	32aa1f63          	bne	s4,a0,ffffffffc0203c14 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02038da:	4589                	li	a1,2
ffffffffc02038dc:	fecfd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_page(p2);
ffffffffc02038e0:	4585                	li	a1,1
ffffffffc02038e2:	8562                	mv	a0,s8
ffffffffc02038e4:	fe4fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02038e8:	4515                	li	a0,5
ffffffffc02038ea:	fa0fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02038ee:	89aa                	mv	s3,a0
ffffffffc02038f0:	48050263          	beqz	a0,ffffffffc0203d74 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02038f4:	4505                	li	a0,1
ffffffffc02038f6:	f94fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02038fa:	2c051d63          	bnez	a0,ffffffffc0203bd4 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02038fe:	481c                	lw	a5,16(s0)
ffffffffc0203900:	2a079a63          	bnez	a5,ffffffffc0203bb4 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0203904:	4595                	li	a1,5
ffffffffc0203906:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0203908:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc020390c:	01643023          	sd	s6,0(s0)
ffffffffc0203910:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0203914:	fb4fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    return listelm->next;
ffffffffc0203918:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc020391a:	00878963          	beq	a5,s0,ffffffffc020392c <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc020391e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203922:	679c                	ld	a5,8(a5)
ffffffffc0203924:	397d                	addiw	s2,s2,-1
ffffffffc0203926:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0203928:	fe879be3          	bne	a5,s0,ffffffffc020391e <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc020392c:	26091463          	bnez	s2,ffffffffc0203b94 <default_check+0x522>
    assert(total == 0);
ffffffffc0203930:	46049263          	bnez	s1,ffffffffc0203d94 <default_check+0x722>
}
ffffffffc0203934:	60a6                	ld	ra,72(sp)
ffffffffc0203936:	6406                	ld	s0,64(sp)
ffffffffc0203938:	74e2                	ld	s1,56(sp)
ffffffffc020393a:	7942                	ld	s2,48(sp)
ffffffffc020393c:	79a2                	ld	s3,40(sp)
ffffffffc020393e:	7a02                	ld	s4,32(sp)
ffffffffc0203940:	6ae2                	ld	s5,24(sp)
ffffffffc0203942:	6b42                	ld	s6,16(sp)
ffffffffc0203944:	6ba2                	ld	s7,8(sp)
ffffffffc0203946:	6c02                	ld	s8,0(sp)
ffffffffc0203948:	6161                	addi	sp,sp,80
ffffffffc020394a:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc020394c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020394e:	4481                	li	s1,0
ffffffffc0203950:	4901                	li	s2,0
ffffffffc0203952:	b38d                	j	ffffffffc02036b4 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0203954:	00003697          	auipc	a3,0x3
ffffffffc0203958:	6cc68693          	addi	a3,a3,1740 # ffffffffc0207020 <commands+0x1368>
ffffffffc020395c:	00003617          	auipc	a2,0x3
ffffffffc0203960:	bf460613          	addi	a2,a2,-1036 # ffffffffc0206550 <commands+0x898>
ffffffffc0203964:	11000593          	li	a1,272
ffffffffc0203968:	00003517          	auipc	a0,0x3
ffffffffc020396c:	6c850513          	addi	a0,a0,1736 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203970:	8affc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203974:	00003697          	auipc	a3,0x3
ffffffffc0203978:	75468693          	addi	a3,a3,1876 # ffffffffc02070c8 <commands+0x1410>
ffffffffc020397c:	00003617          	auipc	a2,0x3
ffffffffc0203980:	bd460613          	addi	a2,a2,-1068 # ffffffffc0206550 <commands+0x898>
ffffffffc0203984:	0db00593          	li	a1,219
ffffffffc0203988:	00003517          	auipc	a0,0x3
ffffffffc020398c:	6a850513          	addi	a0,a0,1704 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203990:	88ffc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203994:	00003697          	auipc	a3,0x3
ffffffffc0203998:	75c68693          	addi	a3,a3,1884 # ffffffffc02070f0 <commands+0x1438>
ffffffffc020399c:	00003617          	auipc	a2,0x3
ffffffffc02039a0:	bb460613          	addi	a2,a2,-1100 # ffffffffc0206550 <commands+0x898>
ffffffffc02039a4:	0dc00593          	li	a1,220
ffffffffc02039a8:	00003517          	auipc	a0,0x3
ffffffffc02039ac:	68850513          	addi	a0,a0,1672 # ffffffffc0207030 <commands+0x1378>
ffffffffc02039b0:	86ffc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02039b4:	00003697          	auipc	a3,0x3
ffffffffc02039b8:	77c68693          	addi	a3,a3,1916 # ffffffffc0207130 <commands+0x1478>
ffffffffc02039bc:	00003617          	auipc	a2,0x3
ffffffffc02039c0:	b9460613          	addi	a2,a2,-1132 # ffffffffc0206550 <commands+0x898>
ffffffffc02039c4:	0de00593          	li	a1,222
ffffffffc02039c8:	00003517          	auipc	a0,0x3
ffffffffc02039cc:	66850513          	addi	a0,a0,1640 # ffffffffc0207030 <commands+0x1378>
ffffffffc02039d0:	84ffc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(!list_empty(&free_list));
ffffffffc02039d4:	00003697          	auipc	a3,0x3
ffffffffc02039d8:	7e468693          	addi	a3,a3,2020 # ffffffffc02071b8 <commands+0x1500>
ffffffffc02039dc:	00003617          	auipc	a2,0x3
ffffffffc02039e0:	b7460613          	addi	a2,a2,-1164 # ffffffffc0206550 <commands+0x898>
ffffffffc02039e4:	0f700593          	li	a1,247
ffffffffc02039e8:	00003517          	auipc	a0,0x3
ffffffffc02039ec:	64850513          	addi	a0,a0,1608 # ffffffffc0207030 <commands+0x1378>
ffffffffc02039f0:	82ffc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02039f4:	00003697          	auipc	a3,0x3
ffffffffc02039f8:	67468693          	addi	a3,a3,1652 # ffffffffc0207068 <commands+0x13b0>
ffffffffc02039fc:	00003617          	auipc	a2,0x3
ffffffffc0203a00:	b5460613          	addi	a2,a2,-1196 # ffffffffc0206550 <commands+0x898>
ffffffffc0203a04:	0f000593          	li	a1,240
ffffffffc0203a08:	00003517          	auipc	a0,0x3
ffffffffc0203a0c:	62850513          	addi	a0,a0,1576 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203a10:	80ffc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free == 3);
ffffffffc0203a14:	00003697          	auipc	a3,0x3
ffffffffc0203a18:	79468693          	addi	a3,a3,1940 # ffffffffc02071a8 <commands+0x14f0>
ffffffffc0203a1c:	00003617          	auipc	a2,0x3
ffffffffc0203a20:	b3460613          	addi	a2,a2,-1228 # ffffffffc0206550 <commands+0x898>
ffffffffc0203a24:	0ee00593          	li	a1,238
ffffffffc0203a28:	00003517          	auipc	a0,0x3
ffffffffc0203a2c:	60850513          	addi	a0,a0,1544 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203a30:	feefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203a34:	00003697          	auipc	a3,0x3
ffffffffc0203a38:	75c68693          	addi	a3,a3,1884 # ffffffffc0207190 <commands+0x14d8>
ffffffffc0203a3c:	00003617          	auipc	a2,0x3
ffffffffc0203a40:	b1460613          	addi	a2,a2,-1260 # ffffffffc0206550 <commands+0x898>
ffffffffc0203a44:	0e900593          	li	a1,233
ffffffffc0203a48:	00003517          	auipc	a0,0x3
ffffffffc0203a4c:	5e850513          	addi	a0,a0,1512 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203a50:	fcefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203a54:	00003697          	auipc	a3,0x3
ffffffffc0203a58:	71c68693          	addi	a3,a3,1820 # ffffffffc0207170 <commands+0x14b8>
ffffffffc0203a5c:	00003617          	auipc	a2,0x3
ffffffffc0203a60:	af460613          	addi	a2,a2,-1292 # ffffffffc0206550 <commands+0x898>
ffffffffc0203a64:	0e000593          	li	a1,224
ffffffffc0203a68:	00003517          	auipc	a0,0x3
ffffffffc0203a6c:	5c850513          	addi	a0,a0,1480 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203a70:	faefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(p0 != NULL);
ffffffffc0203a74:	00003697          	auipc	a3,0x3
ffffffffc0203a78:	78c68693          	addi	a3,a3,1932 # ffffffffc0207200 <commands+0x1548>
ffffffffc0203a7c:	00003617          	auipc	a2,0x3
ffffffffc0203a80:	ad460613          	addi	a2,a2,-1324 # ffffffffc0206550 <commands+0x898>
ffffffffc0203a84:	11800593          	li	a1,280
ffffffffc0203a88:	00003517          	auipc	a0,0x3
ffffffffc0203a8c:	5a850513          	addi	a0,a0,1448 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203a90:	f8efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free == 0);
ffffffffc0203a94:	00003697          	auipc	a3,0x3
ffffffffc0203a98:	75c68693          	addi	a3,a3,1884 # ffffffffc02071f0 <commands+0x1538>
ffffffffc0203a9c:	00003617          	auipc	a2,0x3
ffffffffc0203aa0:	ab460613          	addi	a2,a2,-1356 # ffffffffc0206550 <commands+0x898>
ffffffffc0203aa4:	0fd00593          	li	a1,253
ffffffffc0203aa8:	00003517          	auipc	a0,0x3
ffffffffc0203aac:	58850513          	addi	a0,a0,1416 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203ab0:	f6efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203ab4:	00003697          	auipc	a3,0x3
ffffffffc0203ab8:	6dc68693          	addi	a3,a3,1756 # ffffffffc0207190 <commands+0x14d8>
ffffffffc0203abc:	00003617          	auipc	a2,0x3
ffffffffc0203ac0:	a9460613          	addi	a2,a2,-1388 # ffffffffc0206550 <commands+0x898>
ffffffffc0203ac4:	0fb00593          	li	a1,251
ffffffffc0203ac8:	00003517          	auipc	a0,0x3
ffffffffc0203acc:	56850513          	addi	a0,a0,1384 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203ad0:	f4efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0203ad4:	00003697          	auipc	a3,0x3
ffffffffc0203ad8:	6fc68693          	addi	a3,a3,1788 # ffffffffc02071d0 <commands+0x1518>
ffffffffc0203adc:	00003617          	auipc	a2,0x3
ffffffffc0203ae0:	a7460613          	addi	a2,a2,-1420 # ffffffffc0206550 <commands+0x898>
ffffffffc0203ae4:	0fa00593          	li	a1,250
ffffffffc0203ae8:	00003517          	auipc	a0,0x3
ffffffffc0203aec:	54850513          	addi	a0,a0,1352 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203af0:	f2efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203af4:	00003697          	auipc	a3,0x3
ffffffffc0203af8:	57468693          	addi	a3,a3,1396 # ffffffffc0207068 <commands+0x13b0>
ffffffffc0203afc:	00003617          	auipc	a2,0x3
ffffffffc0203b00:	a5460613          	addi	a2,a2,-1452 # ffffffffc0206550 <commands+0x898>
ffffffffc0203b04:	0d700593          	li	a1,215
ffffffffc0203b08:	00003517          	auipc	a0,0x3
ffffffffc0203b0c:	52850513          	addi	a0,a0,1320 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203b10:	f0efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203b14:	00003697          	auipc	a3,0x3
ffffffffc0203b18:	67c68693          	addi	a3,a3,1660 # ffffffffc0207190 <commands+0x14d8>
ffffffffc0203b1c:	00003617          	auipc	a2,0x3
ffffffffc0203b20:	a3460613          	addi	a2,a2,-1484 # ffffffffc0206550 <commands+0x898>
ffffffffc0203b24:	0f400593          	li	a1,244
ffffffffc0203b28:	00003517          	auipc	a0,0x3
ffffffffc0203b2c:	50850513          	addi	a0,a0,1288 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203b30:	eeefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203b34:	00003697          	auipc	a3,0x3
ffffffffc0203b38:	57468693          	addi	a3,a3,1396 # ffffffffc02070a8 <commands+0x13f0>
ffffffffc0203b3c:	00003617          	auipc	a2,0x3
ffffffffc0203b40:	a1460613          	addi	a2,a2,-1516 # ffffffffc0206550 <commands+0x898>
ffffffffc0203b44:	0f200593          	li	a1,242
ffffffffc0203b48:	00003517          	auipc	a0,0x3
ffffffffc0203b4c:	4e850513          	addi	a0,a0,1256 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203b50:	ecefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203b54:	00003697          	auipc	a3,0x3
ffffffffc0203b58:	53468693          	addi	a3,a3,1332 # ffffffffc0207088 <commands+0x13d0>
ffffffffc0203b5c:	00003617          	auipc	a2,0x3
ffffffffc0203b60:	9f460613          	addi	a2,a2,-1548 # ffffffffc0206550 <commands+0x898>
ffffffffc0203b64:	0f100593          	li	a1,241
ffffffffc0203b68:	00003517          	auipc	a0,0x3
ffffffffc0203b6c:	4c850513          	addi	a0,a0,1224 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203b70:	eaefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203b74:	00003697          	auipc	a3,0x3
ffffffffc0203b78:	53468693          	addi	a3,a3,1332 # ffffffffc02070a8 <commands+0x13f0>
ffffffffc0203b7c:	00003617          	auipc	a2,0x3
ffffffffc0203b80:	9d460613          	addi	a2,a2,-1580 # ffffffffc0206550 <commands+0x898>
ffffffffc0203b84:	0d900593          	li	a1,217
ffffffffc0203b88:	00003517          	auipc	a0,0x3
ffffffffc0203b8c:	4a850513          	addi	a0,a0,1192 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203b90:	e8efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(count == 0);
ffffffffc0203b94:	00003697          	auipc	a3,0x3
ffffffffc0203b98:	7bc68693          	addi	a3,a3,1980 # ffffffffc0207350 <commands+0x1698>
ffffffffc0203b9c:	00003617          	auipc	a2,0x3
ffffffffc0203ba0:	9b460613          	addi	a2,a2,-1612 # ffffffffc0206550 <commands+0x898>
ffffffffc0203ba4:	14600593          	li	a1,326
ffffffffc0203ba8:	00003517          	auipc	a0,0x3
ffffffffc0203bac:	48850513          	addi	a0,a0,1160 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203bb0:	e6efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free == 0);
ffffffffc0203bb4:	00003697          	auipc	a3,0x3
ffffffffc0203bb8:	63c68693          	addi	a3,a3,1596 # ffffffffc02071f0 <commands+0x1538>
ffffffffc0203bbc:	00003617          	auipc	a2,0x3
ffffffffc0203bc0:	99460613          	addi	a2,a2,-1644 # ffffffffc0206550 <commands+0x898>
ffffffffc0203bc4:	13a00593          	li	a1,314
ffffffffc0203bc8:	00003517          	auipc	a0,0x3
ffffffffc0203bcc:	46850513          	addi	a0,a0,1128 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203bd0:	e4efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203bd4:	00003697          	auipc	a3,0x3
ffffffffc0203bd8:	5bc68693          	addi	a3,a3,1468 # ffffffffc0207190 <commands+0x14d8>
ffffffffc0203bdc:	00003617          	auipc	a2,0x3
ffffffffc0203be0:	97460613          	addi	a2,a2,-1676 # ffffffffc0206550 <commands+0x898>
ffffffffc0203be4:	13800593          	li	a1,312
ffffffffc0203be8:	00003517          	auipc	a0,0x3
ffffffffc0203bec:	44850513          	addi	a0,a0,1096 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203bf0:	e2efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203bf4:	00003697          	auipc	a3,0x3
ffffffffc0203bf8:	55c68693          	addi	a3,a3,1372 # ffffffffc0207150 <commands+0x1498>
ffffffffc0203bfc:	00003617          	auipc	a2,0x3
ffffffffc0203c00:	95460613          	addi	a2,a2,-1708 # ffffffffc0206550 <commands+0x898>
ffffffffc0203c04:	0df00593          	li	a1,223
ffffffffc0203c08:	00003517          	auipc	a0,0x3
ffffffffc0203c0c:	42850513          	addi	a0,a0,1064 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203c10:	e0efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203c14:	00003697          	auipc	a3,0x3
ffffffffc0203c18:	6fc68693          	addi	a3,a3,1788 # ffffffffc0207310 <commands+0x1658>
ffffffffc0203c1c:	00003617          	auipc	a2,0x3
ffffffffc0203c20:	93460613          	addi	a2,a2,-1740 # ffffffffc0206550 <commands+0x898>
ffffffffc0203c24:	13200593          	li	a1,306
ffffffffc0203c28:	00003517          	auipc	a0,0x3
ffffffffc0203c2c:	40850513          	addi	a0,a0,1032 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203c30:	deefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203c34:	00003697          	auipc	a3,0x3
ffffffffc0203c38:	6bc68693          	addi	a3,a3,1724 # ffffffffc02072f0 <commands+0x1638>
ffffffffc0203c3c:	00003617          	auipc	a2,0x3
ffffffffc0203c40:	91460613          	addi	a2,a2,-1772 # ffffffffc0206550 <commands+0x898>
ffffffffc0203c44:	13000593          	li	a1,304
ffffffffc0203c48:	00003517          	auipc	a0,0x3
ffffffffc0203c4c:	3e850513          	addi	a0,a0,1000 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203c50:	dcefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203c54:	00003697          	auipc	a3,0x3
ffffffffc0203c58:	67468693          	addi	a3,a3,1652 # ffffffffc02072c8 <commands+0x1610>
ffffffffc0203c5c:	00003617          	auipc	a2,0x3
ffffffffc0203c60:	8f460613          	addi	a2,a2,-1804 # ffffffffc0206550 <commands+0x898>
ffffffffc0203c64:	12e00593          	li	a1,302
ffffffffc0203c68:	00003517          	auipc	a0,0x3
ffffffffc0203c6c:	3c850513          	addi	a0,a0,968 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203c70:	daefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203c74:	00003697          	auipc	a3,0x3
ffffffffc0203c78:	62c68693          	addi	a3,a3,1580 # ffffffffc02072a0 <commands+0x15e8>
ffffffffc0203c7c:	00003617          	auipc	a2,0x3
ffffffffc0203c80:	8d460613          	addi	a2,a2,-1836 # ffffffffc0206550 <commands+0x898>
ffffffffc0203c84:	12d00593          	li	a1,301
ffffffffc0203c88:	00003517          	auipc	a0,0x3
ffffffffc0203c8c:	3a850513          	addi	a0,a0,936 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203c90:	d8efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203c94:	00003697          	auipc	a3,0x3
ffffffffc0203c98:	5fc68693          	addi	a3,a3,1532 # ffffffffc0207290 <commands+0x15d8>
ffffffffc0203c9c:	00003617          	auipc	a2,0x3
ffffffffc0203ca0:	8b460613          	addi	a2,a2,-1868 # ffffffffc0206550 <commands+0x898>
ffffffffc0203ca4:	12800593          	li	a1,296
ffffffffc0203ca8:	00003517          	auipc	a0,0x3
ffffffffc0203cac:	38850513          	addi	a0,a0,904 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203cb0:	d6efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203cb4:	00003697          	auipc	a3,0x3
ffffffffc0203cb8:	4dc68693          	addi	a3,a3,1244 # ffffffffc0207190 <commands+0x14d8>
ffffffffc0203cbc:	00003617          	auipc	a2,0x3
ffffffffc0203cc0:	89460613          	addi	a2,a2,-1900 # ffffffffc0206550 <commands+0x898>
ffffffffc0203cc4:	12700593          	li	a1,295
ffffffffc0203cc8:	00003517          	auipc	a0,0x3
ffffffffc0203ccc:	36850513          	addi	a0,a0,872 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203cd0:	d4efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203cd4:	00003697          	auipc	a3,0x3
ffffffffc0203cd8:	59c68693          	addi	a3,a3,1436 # ffffffffc0207270 <commands+0x15b8>
ffffffffc0203cdc:	00003617          	auipc	a2,0x3
ffffffffc0203ce0:	87460613          	addi	a2,a2,-1932 # ffffffffc0206550 <commands+0x898>
ffffffffc0203ce4:	12600593          	li	a1,294
ffffffffc0203ce8:	00003517          	auipc	a0,0x3
ffffffffc0203cec:	34850513          	addi	a0,a0,840 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203cf0:	d2efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203cf4:	00003697          	auipc	a3,0x3
ffffffffc0203cf8:	54c68693          	addi	a3,a3,1356 # ffffffffc0207240 <commands+0x1588>
ffffffffc0203cfc:	00003617          	auipc	a2,0x3
ffffffffc0203d00:	85460613          	addi	a2,a2,-1964 # ffffffffc0206550 <commands+0x898>
ffffffffc0203d04:	12500593          	li	a1,293
ffffffffc0203d08:	00003517          	auipc	a0,0x3
ffffffffc0203d0c:	32850513          	addi	a0,a0,808 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203d10:	d0efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0203d14:	00003697          	auipc	a3,0x3
ffffffffc0203d18:	51468693          	addi	a3,a3,1300 # ffffffffc0207228 <commands+0x1570>
ffffffffc0203d1c:	00003617          	auipc	a2,0x3
ffffffffc0203d20:	83460613          	addi	a2,a2,-1996 # ffffffffc0206550 <commands+0x898>
ffffffffc0203d24:	12400593          	li	a1,292
ffffffffc0203d28:	00003517          	auipc	a0,0x3
ffffffffc0203d2c:	30850513          	addi	a0,a0,776 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203d30:	ceefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203d34:	00003697          	auipc	a3,0x3
ffffffffc0203d38:	45c68693          	addi	a3,a3,1116 # ffffffffc0207190 <commands+0x14d8>
ffffffffc0203d3c:	00003617          	auipc	a2,0x3
ffffffffc0203d40:	81460613          	addi	a2,a2,-2028 # ffffffffc0206550 <commands+0x898>
ffffffffc0203d44:	11e00593          	li	a1,286
ffffffffc0203d48:	00003517          	auipc	a0,0x3
ffffffffc0203d4c:	2e850513          	addi	a0,a0,744 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203d50:	ccefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(!PageProperty(p0));
ffffffffc0203d54:	00003697          	auipc	a3,0x3
ffffffffc0203d58:	4bc68693          	addi	a3,a3,1212 # ffffffffc0207210 <commands+0x1558>
ffffffffc0203d5c:	00002617          	auipc	a2,0x2
ffffffffc0203d60:	7f460613          	addi	a2,a2,2036 # ffffffffc0206550 <commands+0x898>
ffffffffc0203d64:	11900593          	li	a1,281
ffffffffc0203d68:	00003517          	auipc	a0,0x3
ffffffffc0203d6c:	2c850513          	addi	a0,a0,712 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203d70:	caefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203d74:	00003697          	auipc	a3,0x3
ffffffffc0203d78:	5bc68693          	addi	a3,a3,1468 # ffffffffc0207330 <commands+0x1678>
ffffffffc0203d7c:	00002617          	auipc	a2,0x2
ffffffffc0203d80:	7d460613          	addi	a2,a2,2004 # ffffffffc0206550 <commands+0x898>
ffffffffc0203d84:	13700593          	li	a1,311
ffffffffc0203d88:	00003517          	auipc	a0,0x3
ffffffffc0203d8c:	2a850513          	addi	a0,a0,680 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203d90:	c8efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(total == 0);
ffffffffc0203d94:	00003697          	auipc	a3,0x3
ffffffffc0203d98:	5cc68693          	addi	a3,a3,1484 # ffffffffc0207360 <commands+0x16a8>
ffffffffc0203d9c:	00002617          	auipc	a2,0x2
ffffffffc0203da0:	7b460613          	addi	a2,a2,1972 # ffffffffc0206550 <commands+0x898>
ffffffffc0203da4:	14700593          	li	a1,327
ffffffffc0203da8:	00003517          	auipc	a0,0x3
ffffffffc0203dac:	28850513          	addi	a0,a0,648 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203db0:	c6efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(total == nr_free_pages());
ffffffffc0203db4:	00003697          	auipc	a3,0x3
ffffffffc0203db8:	29468693          	addi	a3,a3,660 # ffffffffc0207048 <commands+0x1390>
ffffffffc0203dbc:	00002617          	auipc	a2,0x2
ffffffffc0203dc0:	79460613          	addi	a2,a2,1940 # ffffffffc0206550 <commands+0x898>
ffffffffc0203dc4:	11300593          	li	a1,275
ffffffffc0203dc8:	00003517          	auipc	a0,0x3
ffffffffc0203dcc:	26850513          	addi	a0,a0,616 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203dd0:	c4efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203dd4:	00003697          	auipc	a3,0x3
ffffffffc0203dd8:	2b468693          	addi	a3,a3,692 # ffffffffc0207088 <commands+0x13d0>
ffffffffc0203ddc:	00002617          	auipc	a2,0x2
ffffffffc0203de0:	77460613          	addi	a2,a2,1908 # ffffffffc0206550 <commands+0x898>
ffffffffc0203de4:	0d800593          	li	a1,216
ffffffffc0203de8:	00003517          	auipc	a0,0x3
ffffffffc0203dec:	24850513          	addi	a0,a0,584 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203df0:	c2efc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203df4 <default_free_pages>:
{
ffffffffc0203df4:	1141                	addi	sp,sp,-16
ffffffffc0203df6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203df8:	14058463          	beqz	a1,ffffffffc0203f40 <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc0203dfc:	00659693          	slli	a3,a1,0x6
ffffffffc0203e00:	96aa                	add	a3,a3,a0
ffffffffc0203e02:	87aa                	mv	a5,a0
ffffffffc0203e04:	02d50263          	beq	a0,a3,ffffffffc0203e28 <default_free_pages+0x34>
ffffffffc0203e08:	6798                	ld	a4,8(a5)
ffffffffc0203e0a:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203e0c:	10071a63          	bnez	a4,ffffffffc0203f20 <default_free_pages+0x12c>
ffffffffc0203e10:	6798                	ld	a4,8(a5)
ffffffffc0203e12:	8b09                	andi	a4,a4,2
ffffffffc0203e14:	10071663          	bnez	a4,ffffffffc0203f20 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0203e18:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203e1c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0203e20:	04078793          	addi	a5,a5,64
ffffffffc0203e24:	fed792e3          	bne	a5,a3,ffffffffc0203e08 <default_free_pages+0x14>
    base->property = n;
ffffffffc0203e28:	2581                	sext.w	a1,a1
ffffffffc0203e2a:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0203e2c:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203e30:	4789                	li	a5,2
ffffffffc0203e32:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203e36:	000ad697          	auipc	a3,0xad
ffffffffc0203e3a:	23a68693          	addi	a3,a3,570 # ffffffffc02b1070 <free_area>
ffffffffc0203e3e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203e40:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0203e42:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0203e46:	9db9                	addw	a1,a1,a4
ffffffffc0203e48:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0203e4a:	0ad78463          	beq	a5,a3,ffffffffc0203ef2 <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc0203e4e:	fe878713          	addi	a4,a5,-24
ffffffffc0203e52:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0203e56:	4581                	li	a1,0
            if (base < page)
ffffffffc0203e58:	00e56a63          	bltu	a0,a4,ffffffffc0203e6c <default_free_pages+0x78>
    return listelm->next;
ffffffffc0203e5c:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0203e5e:	04d70c63          	beq	a4,a3,ffffffffc0203eb6 <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc0203e62:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0203e64:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0203e68:	fee57ae3          	bgeu	a0,a4,ffffffffc0203e5c <default_free_pages+0x68>
ffffffffc0203e6c:	c199                	beqz	a1,ffffffffc0203e72 <default_free_pages+0x7e>
ffffffffc0203e6e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203e72:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203e74:	e390                	sd	a2,0(a5)
ffffffffc0203e76:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203e78:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203e7a:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc0203e7c:	00d70d63          	beq	a4,a3,ffffffffc0203e96 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc0203e80:	ff872583          	lw	a1,-8(a4) # ff8 <_binary_obj___user_faultread_out_size-0x8bc0>
        p = le2page(le, page_link);
ffffffffc0203e84:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0203e88:	02059813          	slli	a6,a1,0x20
ffffffffc0203e8c:	01a85793          	srli	a5,a6,0x1a
ffffffffc0203e90:	97b2                	add	a5,a5,a2
ffffffffc0203e92:	02f50c63          	beq	a0,a5,ffffffffc0203eca <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0203e96:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0203e98:	00d78c63          	beq	a5,a3,ffffffffc0203eb0 <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc0203e9c:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0203e9e:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc0203ea2:	02061593          	slli	a1,a2,0x20
ffffffffc0203ea6:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0203eaa:	972a                	add	a4,a4,a0
ffffffffc0203eac:	04e68a63          	beq	a3,a4,ffffffffc0203f00 <default_free_pages+0x10c>
}
ffffffffc0203eb0:	60a2                	ld	ra,8(sp)
ffffffffc0203eb2:	0141                	addi	sp,sp,16
ffffffffc0203eb4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203eb6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203eb8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0203eba:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203ebc:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0203ebe:	02d70763          	beq	a4,a3,ffffffffc0203eec <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0203ec2:	8832                	mv	a6,a2
ffffffffc0203ec4:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0203ec6:	87ba                	mv	a5,a4
ffffffffc0203ec8:	bf71                	j	ffffffffc0203e64 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0203eca:	491c                	lw	a5,16(a0)
ffffffffc0203ecc:	9dbd                	addw	a1,a1,a5
ffffffffc0203ece:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203ed2:	57f5                	li	a5,-3
ffffffffc0203ed4:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203ed8:	01853803          	ld	a6,24(a0)
ffffffffc0203edc:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0203ede:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0203ee0:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0203ee4:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0203ee6:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc0203eea:	b77d                	j	ffffffffc0203e98 <default_free_pages+0xa4>
ffffffffc0203eec:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc0203eee:	873e                	mv	a4,a5
ffffffffc0203ef0:	bf41                	j	ffffffffc0203e80 <default_free_pages+0x8c>
}
ffffffffc0203ef2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203ef4:	e390                	sd	a2,0(a5)
ffffffffc0203ef6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203ef8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203efa:	ed1c                	sd	a5,24(a0)
ffffffffc0203efc:	0141                	addi	sp,sp,16
ffffffffc0203efe:	8082                	ret
            base->property += p->property;
ffffffffc0203f00:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203f04:	ff078693          	addi	a3,a5,-16
ffffffffc0203f08:	9e39                	addw	a2,a2,a4
ffffffffc0203f0a:	c910                	sw	a2,16(a0)
ffffffffc0203f0c:	5775                	li	a4,-3
ffffffffc0203f0e:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f12:	6398                	ld	a4,0(a5)
ffffffffc0203f14:	679c                	ld	a5,8(a5)
}
ffffffffc0203f16:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203f18:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203f1a:	e398                	sd	a4,0(a5)
ffffffffc0203f1c:	0141                	addi	sp,sp,16
ffffffffc0203f1e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203f20:	00003697          	auipc	a3,0x3
ffffffffc0203f24:	45868693          	addi	a3,a3,1112 # ffffffffc0207378 <commands+0x16c0>
ffffffffc0203f28:	00002617          	auipc	a2,0x2
ffffffffc0203f2c:	62860613          	addi	a2,a2,1576 # ffffffffc0206550 <commands+0x898>
ffffffffc0203f30:	09400593          	li	a1,148
ffffffffc0203f34:	00003517          	auipc	a0,0x3
ffffffffc0203f38:	0fc50513          	addi	a0,a0,252 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203f3c:	ae2fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(n > 0);
ffffffffc0203f40:	00003697          	auipc	a3,0x3
ffffffffc0203f44:	43068693          	addi	a3,a3,1072 # ffffffffc0207370 <commands+0x16b8>
ffffffffc0203f48:	00002617          	auipc	a2,0x2
ffffffffc0203f4c:	60860613          	addi	a2,a2,1544 # ffffffffc0206550 <commands+0x898>
ffffffffc0203f50:	09000593          	li	a1,144
ffffffffc0203f54:	00003517          	auipc	a0,0x3
ffffffffc0203f58:	0dc50513          	addi	a0,a0,220 # ffffffffc0207030 <commands+0x1378>
ffffffffc0203f5c:	ac2fc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203f60 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203f60:	c941                	beqz	a0,ffffffffc0203ff0 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc0203f62:	000ad597          	auipc	a1,0xad
ffffffffc0203f66:	10e58593          	addi	a1,a1,270 # ffffffffc02b1070 <free_area>
ffffffffc0203f6a:	0105a803          	lw	a6,16(a1)
ffffffffc0203f6e:	872a                	mv	a4,a0
ffffffffc0203f70:	02081793          	slli	a5,a6,0x20
ffffffffc0203f74:	9381                	srli	a5,a5,0x20
ffffffffc0203f76:	00a7ee63          	bltu	a5,a0,ffffffffc0203f92 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203f7a:	87ae                	mv	a5,a1
ffffffffc0203f7c:	a801                	j	ffffffffc0203f8c <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc0203f7e:	ff87a683          	lw	a3,-8(a5)
ffffffffc0203f82:	02069613          	slli	a2,a3,0x20
ffffffffc0203f86:	9201                	srli	a2,a2,0x20
ffffffffc0203f88:	00e67763          	bgeu	a2,a4,ffffffffc0203f96 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203f8c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0203f8e:	feb798e3          	bne	a5,a1,ffffffffc0203f7e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203f92:	4501                	li	a0,0
}
ffffffffc0203f94:	8082                	ret
    return listelm->prev;
ffffffffc0203f96:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f9a:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0203f9e:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0203fa2:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0203fa6:	0068b423          	sd	t1,8(a7) # 80008 <_binary_obj___user_exit_out_size+0x74ee0>
    next->prev = prev;
ffffffffc0203faa:	01133023          	sd	a7,0(t1) # 80000 <_binary_obj___user_exit_out_size+0x74ed8>
        if (page->property > n)
ffffffffc0203fae:	02c77863          	bgeu	a4,a2,ffffffffc0203fde <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0203fb2:	071a                	slli	a4,a4,0x6
ffffffffc0203fb4:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0203fb6:	41c686bb          	subw	a3,a3,t3
ffffffffc0203fba:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203fbc:	00870613          	addi	a2,a4,8
ffffffffc0203fc0:	4689                	li	a3,2
ffffffffc0203fc2:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203fc6:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203fca:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0203fce:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0203fd2:	e290                	sd	a2,0(a3)
ffffffffc0203fd4:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0203fd8:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0203fda:	01173c23          	sd	a7,24(a4)
ffffffffc0203fde:	41c8083b          	subw	a6,a6,t3
ffffffffc0203fe2:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203fe6:	5775                	li	a4,-3
ffffffffc0203fe8:	17c1                	addi	a5,a5,-16
ffffffffc0203fea:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0203fee:	8082                	ret
{
ffffffffc0203ff0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203ff2:	00003697          	auipc	a3,0x3
ffffffffc0203ff6:	37e68693          	addi	a3,a3,894 # ffffffffc0207370 <commands+0x16b8>
ffffffffc0203ffa:	00002617          	auipc	a2,0x2
ffffffffc0203ffe:	55660613          	addi	a2,a2,1366 # ffffffffc0206550 <commands+0x898>
ffffffffc0204002:	06c00593          	li	a1,108
ffffffffc0204006:	00003517          	auipc	a0,0x3
ffffffffc020400a:	02a50513          	addi	a0,a0,42 # ffffffffc0207030 <commands+0x1378>
{
ffffffffc020400e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204010:	a0efc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204014 <default_init_memmap>:
{
ffffffffc0204014:	1141                	addi	sp,sp,-16
ffffffffc0204016:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204018:	c5f1                	beqz	a1,ffffffffc02040e4 <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc020401a:	00659693          	slli	a3,a1,0x6
ffffffffc020401e:	96aa                	add	a3,a3,a0
ffffffffc0204020:	87aa                	mv	a5,a0
ffffffffc0204022:	00d50f63          	beq	a0,a3,ffffffffc0204040 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0204026:	6798                	ld	a4,8(a5)
ffffffffc0204028:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc020402a:	cf49                	beqz	a4,ffffffffc02040c4 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc020402c:	0007a823          	sw	zero,16(a5)
ffffffffc0204030:	0007b423          	sd	zero,8(a5)
ffffffffc0204034:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0204038:	04078793          	addi	a5,a5,64
ffffffffc020403c:	fed795e3          	bne	a5,a3,ffffffffc0204026 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0204040:	2581                	sext.w	a1,a1
ffffffffc0204042:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204044:	4789                	li	a5,2
ffffffffc0204046:	00850713          	addi	a4,a0,8
ffffffffc020404a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020404e:	000ad697          	auipc	a3,0xad
ffffffffc0204052:	02268693          	addi	a3,a3,34 # ffffffffc02b1070 <free_area>
ffffffffc0204056:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204058:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020405a:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020405e:	9db9                	addw	a1,a1,a4
ffffffffc0204060:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0204062:	04d78a63          	beq	a5,a3,ffffffffc02040b6 <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc0204066:	fe878713          	addi	a4,a5,-24
ffffffffc020406a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc020406e:	4581                	li	a1,0
            if (base < page)
ffffffffc0204070:	00e56a63          	bltu	a0,a4,ffffffffc0204084 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0204074:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0204076:	02d70263          	beq	a4,a3,ffffffffc020409a <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc020407a:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc020407c:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0204080:	fee57ae3          	bgeu	a0,a4,ffffffffc0204074 <default_init_memmap+0x60>
ffffffffc0204084:	c199                	beqz	a1,ffffffffc020408a <default_init_memmap+0x76>
ffffffffc0204086:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020408a:	6398                	ld	a4,0(a5)
}
ffffffffc020408c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020408e:	e390                	sd	a2,0(a5)
ffffffffc0204090:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204092:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204094:	ed18                	sd	a4,24(a0)
ffffffffc0204096:	0141                	addi	sp,sp,16
ffffffffc0204098:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020409a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020409c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020409e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02040a0:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc02040a2:	00d70663          	beq	a4,a3,ffffffffc02040ae <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc02040a6:	8832                	mv	a6,a2
ffffffffc02040a8:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc02040aa:	87ba                	mv	a5,a4
ffffffffc02040ac:	bfc1                	j	ffffffffc020407c <default_init_memmap+0x68>
}
ffffffffc02040ae:	60a2                	ld	ra,8(sp)
ffffffffc02040b0:	e290                	sd	a2,0(a3)
ffffffffc02040b2:	0141                	addi	sp,sp,16
ffffffffc02040b4:	8082                	ret
ffffffffc02040b6:	60a2                	ld	ra,8(sp)
ffffffffc02040b8:	e390                	sd	a2,0(a5)
ffffffffc02040ba:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02040bc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02040be:	ed1c                	sd	a5,24(a0)
ffffffffc02040c0:	0141                	addi	sp,sp,16
ffffffffc02040c2:	8082                	ret
        assert(PageReserved(p));
ffffffffc02040c4:	00003697          	auipc	a3,0x3
ffffffffc02040c8:	2dc68693          	addi	a3,a3,732 # ffffffffc02073a0 <commands+0x16e8>
ffffffffc02040cc:	00002617          	auipc	a2,0x2
ffffffffc02040d0:	48460613          	addi	a2,a2,1156 # ffffffffc0206550 <commands+0x898>
ffffffffc02040d4:	04b00593          	li	a1,75
ffffffffc02040d8:	00003517          	auipc	a0,0x3
ffffffffc02040dc:	f5850513          	addi	a0,a0,-168 # ffffffffc0207030 <commands+0x1378>
ffffffffc02040e0:	93efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(n > 0);
ffffffffc02040e4:	00003697          	auipc	a3,0x3
ffffffffc02040e8:	28c68693          	addi	a3,a3,652 # ffffffffc0207370 <commands+0x16b8>
ffffffffc02040ec:	00002617          	auipc	a2,0x2
ffffffffc02040f0:	46460613          	addi	a2,a2,1124 # ffffffffc0206550 <commands+0x898>
ffffffffc02040f4:	04700593          	li	a1,71
ffffffffc02040f8:	00003517          	auipc	a0,0x3
ffffffffc02040fc:	f3850513          	addi	a0,a0,-200 # ffffffffc0207030 <commands+0x1378>
ffffffffc0204100:	91efc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204104 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204104:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204106:	9402                	jalr	s0

	jal do_exit
ffffffffc0204108:	678000ef          	jal	ra,ffffffffc0204780 <do_exit>

ffffffffc020410c <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020410c:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204110:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204114:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204116:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204118:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020411c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204120:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204124:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204128:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020412c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204130:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204134:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204138:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020413c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204140:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204144:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204148:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020414a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020414c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204150:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204154:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204158:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020415c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204160:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204164:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204168:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020416c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204170:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204174:	8082                	ret

ffffffffc0204176 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0204176:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204178:	10800513          	li	a0,264
{
ffffffffc020417c:	e022                	sd	s0,0(sp)
ffffffffc020417e:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204180:	b2cff0ef          	jal	ra,ffffffffc02034ac <kmalloc>
ffffffffc0204184:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0204186:	cd21                	beqz	a0,ffffffffc02041de <alloc_proc+0x68>
    {
        proc->state = PROC_UNINIT; 
ffffffffc0204188:	57fd                	li	a5,-1
ffffffffc020418a:	1782                	slli	a5,a5,0x20
ffffffffc020418c:	e11c                	sd	a5,0(a0)
        proc->runs = 0;             
        proc->kstack = 0;         
        proc->need_resched = 0;  
        proc->parent = NULL;      
        proc->mm = NULL;          
        memset(&(proc->context), 0, sizeof(struct context)); 
ffffffffc020418e:	07000613          	li	a2,112
ffffffffc0204192:	4581                	li	a1,0
        proc->runs = 0;             
ffffffffc0204194:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;         
ffffffffc0204198:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;  
ffffffffc020419c:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;      
ffffffffc02041a0:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;          
ffffffffc02041a4:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context)); 
ffffffffc02041a8:	03050513          	addi	a0,a0,48
ffffffffc02041ac:	432010ef          	jal	ra,ffffffffc02055de <memset>
        proc->tf = NULL;            // 中断帧指针置为空
        proc->pgdir = boot_pgdir_pa;
ffffffffc02041b0:	000b1797          	auipc	a5,0xb1
ffffffffc02041b4:	f187b783          	ld	a5,-232(a5) # ffffffffc02b50c8 <boot_pgdir_pa>
        proc->tf = NULL;            // 中断帧指针置为空
ffffffffc02041b8:	0a043023          	sd	zero,160(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc02041bc:	f45c                	sd	a5,168(s0)
        proc->flags = 0;            
ffffffffc02041be:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN + 1); // 进程名初始化为空
ffffffffc02041c2:	4641                	li	a2,16
ffffffffc02041c4:	4581                	li	a1,0
ffffffffc02041c6:	0b440513          	addi	a0,s0,180
ffffffffc02041ca:	414010ef          	jal	ra,ffffffffc02055de <memset>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->wait_state = 0;
ffffffffc02041ce:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc02041d2:	0e043c23          	sd	zero,248(s0)
ffffffffc02041d6:	10043023          	sd	zero,256(s0)
ffffffffc02041da:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc02041de:	60a2                	ld	ra,8(sp)
ffffffffc02041e0:	8522                	mv	a0,s0
ffffffffc02041e2:	6402                	ld	s0,0(sp)
ffffffffc02041e4:	0141                	addi	sp,sp,16
ffffffffc02041e6:	8082                	ret

ffffffffc02041e8 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc02041e8:	000b1797          	auipc	a5,0xb1
ffffffffc02041ec:	f207b783          	ld	a5,-224(a5) # ffffffffc02b5108 <current>
ffffffffc02041f0:	73c8                	ld	a0,160(a5)
ffffffffc02041f2:	db5fc06f          	j	ffffffffc0200fa6 <forkrets>

ffffffffc02041f6 <user_main>:
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
ffffffffc02041f6:	000b1797          	auipc	a5,0xb1
ffffffffc02041fa:	f127b783          	ld	a5,-238(a5) # ffffffffc02b5108 <current>
ffffffffc02041fe:	43cc                	lw	a1,4(a5)
{
ffffffffc0204200:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);
ffffffffc0204202:	00003617          	auipc	a2,0x3
ffffffffc0204206:	1fe60613          	addi	a2,a2,510 # ffffffffc0207400 <default_pmm_manager+0x38>
ffffffffc020420a:	00003517          	auipc	a0,0x3
ffffffffc020420e:	1fe50513          	addi	a0,a0,510 # ffffffffc0207408 <default_pmm_manager+0x40>
{
ffffffffc0204212:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);
ffffffffc0204214:	ecdfb0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0204218:	3fe07797          	auipc	a5,0x3fe07
ffffffffc020421c:	f1078793          	addi	a5,a5,-240 # b128 <_binary_obj___user_exit_out_size>
ffffffffc0204220:	e43e                	sd	a5,8(sp)
ffffffffc0204222:	00003517          	auipc	a0,0x3
ffffffffc0204226:	1de50513          	addi	a0,a0,478 # ffffffffc0207400 <default_pmm_manager+0x38>
ffffffffc020422a:	0003a797          	auipc	a5,0x3a
ffffffffc020422e:	e4678793          	addi	a5,a5,-442 # ffffffffc023e070 <_binary_obj___user_exit_out_start>
ffffffffc0204232:	f03e                	sd	a5,32(sp)
ffffffffc0204234:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0204236:	e802                	sd	zero,16(sp)
ffffffffc0204238:	304010ef          	jal	ra,ffffffffc020553c <strlen>
ffffffffc020423c:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc020423e:	4511                	li	a0,4
ffffffffc0204240:	55a2                	lw	a1,40(sp)
ffffffffc0204242:	4662                	lw	a2,24(sp)
ffffffffc0204244:	5682                	lw	a3,32(sp)
ffffffffc0204246:	4722                	lw	a4,8(sp)
ffffffffc0204248:	48a9                	li	a7,10
ffffffffc020424a:	9002                	ebreak
ffffffffc020424c:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc020424e:	65c2                	ld	a1,16(sp)
ffffffffc0204250:	00003517          	auipc	a0,0x3
ffffffffc0204254:	1e050513          	addi	a0,a0,480 # ffffffffc0207430 <default_pmm_manager+0x68>
ffffffffc0204258:	e89fb0ef          	jal	ra,ffffffffc02000e0 <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc020425c:	00003617          	auipc	a2,0x3
ffffffffc0204260:	1e460613          	addi	a2,a2,484 # ffffffffc0207440 <default_pmm_manager+0x78>
ffffffffc0204264:	3aa00593          	li	a1,938
ffffffffc0204268:	00003517          	auipc	a0,0x3
ffffffffc020426c:	1f850513          	addi	a0,a0,504 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0204270:	faffb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204274 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204274:	6d14                	ld	a3,24(a0)
{
ffffffffc0204276:	1141                	addi	sp,sp,-16
ffffffffc0204278:	e406                	sd	ra,8(sp)
ffffffffc020427a:	c02007b7          	lui	a5,0xc0200
ffffffffc020427e:	02f6ee63          	bltu	a3,a5,ffffffffc02042ba <put_pgdir+0x46>
ffffffffc0204282:	000b1517          	auipc	a0,0xb1
ffffffffc0204286:	e6e53503          	ld	a0,-402(a0) # ffffffffc02b50f0 <va_pa_offset>
ffffffffc020428a:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc020428c:	82b1                	srli	a3,a3,0xc
ffffffffc020428e:	000b1797          	auipc	a5,0xb1
ffffffffc0204292:	e4a7b783          	ld	a5,-438(a5) # ffffffffc02b50d8 <npage>
ffffffffc0204296:	02f6fe63          	bgeu	a3,a5,ffffffffc02042d2 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020429a:	00004517          	auipc	a0,0x4
ffffffffc020429e:	a5e53503          	ld	a0,-1442(a0) # ffffffffc0207cf8 <nbase>
}
ffffffffc02042a2:	60a2                	ld	ra,8(sp)
ffffffffc02042a4:	8e89                	sub	a3,a3,a0
ffffffffc02042a6:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc02042a8:	000b1517          	auipc	a0,0xb1
ffffffffc02042ac:	e3853503          	ld	a0,-456(a0) # ffffffffc02b50e0 <pages>
ffffffffc02042b0:	4585                	li	a1,1
ffffffffc02042b2:	9536                	add	a0,a0,a3
}
ffffffffc02042b4:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc02042b6:	e13fc06f          	j	ffffffffc02010c8 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc02042ba:	00002617          	auipc	a2,0x2
ffffffffc02042be:	33e60613          	addi	a2,a2,830 # ffffffffc02065f8 <commands+0x940>
ffffffffc02042c2:	07700593          	li	a1,119
ffffffffc02042c6:	00002517          	auipc	a0,0x2
ffffffffc02042ca:	1ea50513          	addi	a0,a0,490 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc02042ce:	f51fb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02042d2:	00002617          	auipc	a2,0x2
ffffffffc02042d6:	1be60613          	addi	a2,a2,446 # ffffffffc0206490 <commands+0x7d8>
ffffffffc02042da:	06900593          	li	a1,105
ffffffffc02042de:	00002517          	auipc	a0,0x2
ffffffffc02042e2:	1d250513          	addi	a0,a0,466 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc02042e6:	f39fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02042ea <proc_run>:
{
ffffffffc02042ea:	7179                	addi	sp,sp,-48
ffffffffc02042ec:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc02042ee:	000b1917          	auipc	s2,0xb1
ffffffffc02042f2:	e1a90913          	addi	s2,s2,-486 # ffffffffc02b5108 <current>
{
ffffffffc02042f6:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc02042f8:	00093483          	ld	s1,0(s2)
{
ffffffffc02042fc:	f406                	sd	ra,40(sp)
ffffffffc02042fe:	e84e                	sd	s3,16(sp)
    if (proc != current)
ffffffffc0204300:	02a48863          	beq	s1,a0,ffffffffc0204330 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204304:	100027f3          	csrr	a5,sstatus
ffffffffc0204308:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020430a:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020430c:	ef9d                	bnez	a5,ffffffffc020434a <proc_run+0x60>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc020430e:	755c                	ld	a5,168(a0)
ffffffffc0204310:	577d                	li	a4,-1
ffffffffc0204312:	177e                	slli	a4,a4,0x3f
ffffffffc0204314:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204316:	00a93023          	sd	a0,0(s2)
ffffffffc020431a:	8fd9                	or	a5,a5,a4
ffffffffc020431c:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204320:	03050593          	addi	a1,a0,48
ffffffffc0204324:	03048513          	addi	a0,s1,48
ffffffffc0204328:	de5ff0ef          	jal	ra,ffffffffc020410c <switch_to>
    if (flag)
ffffffffc020432c:	00099863          	bnez	s3,ffffffffc020433c <proc_run+0x52>
}
ffffffffc0204330:	70a2                	ld	ra,40(sp)
ffffffffc0204332:	7482                	ld	s1,32(sp)
ffffffffc0204334:	6962                	ld	s2,24(sp)
ffffffffc0204336:	69c2                	ld	s3,16(sp)
ffffffffc0204338:	6145                	addi	sp,sp,48
ffffffffc020433a:	8082                	ret
ffffffffc020433c:	70a2                	ld	ra,40(sp)
ffffffffc020433e:	7482                	ld	s1,32(sp)
ffffffffc0204340:	6962                	ld	s2,24(sp)
ffffffffc0204342:	69c2                	ld	s3,16(sp)
ffffffffc0204344:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204346:	e6efc06f          	j	ffffffffc02009b4 <intr_enable>
ffffffffc020434a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020434c:	e6efc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc0204350:	6522                	ld	a0,8(sp)
ffffffffc0204352:	4985                	li	s3,1
ffffffffc0204354:	bf6d                	j	ffffffffc020430e <proc_run+0x24>

ffffffffc0204356 <do_fork>:
{
ffffffffc0204356:	7119                	addi	sp,sp,-128
ffffffffc0204358:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc020435a:	000b1917          	auipc	s2,0xb1
ffffffffc020435e:	dc690913          	addi	s2,s2,-570 # ffffffffc02b5120 <nr_process>
ffffffffc0204362:	00092703          	lw	a4,0(s2)
{
ffffffffc0204366:	fc86                	sd	ra,120(sp)
ffffffffc0204368:	f8a2                	sd	s0,112(sp)
ffffffffc020436a:	f4a6                	sd	s1,104(sp)
ffffffffc020436c:	ecce                	sd	s3,88(sp)
ffffffffc020436e:	e8d2                	sd	s4,80(sp)
ffffffffc0204370:	e4d6                	sd	s5,72(sp)
ffffffffc0204372:	e0da                	sd	s6,64(sp)
ffffffffc0204374:	fc5e                	sd	s7,56(sp)
ffffffffc0204376:	f862                	sd	s8,48(sp)
ffffffffc0204378:	f466                	sd	s9,40(sp)
ffffffffc020437a:	f06a                	sd	s10,32(sp)
ffffffffc020437c:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc020437e:	6785                	lui	a5,0x1
ffffffffc0204380:	32f75663          	bge	a4,a5,ffffffffc02046ac <do_fork+0x356>
ffffffffc0204384:	8a2a                	mv	s4,a0
ffffffffc0204386:	89ae                	mv	s3,a1
ffffffffc0204388:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc020438a:	dedff0ef          	jal	ra,ffffffffc0204176 <alloc_proc>
ffffffffc020438e:	84aa                	mv	s1,a0
ffffffffc0204390:	2e050f63          	beqz	a0,ffffffffc020468e <do_fork+0x338>
    proc->parent = current;
ffffffffc0204394:	000b1c17          	auipc	s8,0xb1
ffffffffc0204398:	d74c0c13          	addi	s8,s8,-652 # ffffffffc02b5108 <current>
ffffffffc020439c:	000c3783          	ld	a5,0(s8)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02043a0:	4509                	li	a0,2
    proc->parent = current;
ffffffffc02043a2:	f09c                	sd	a5,32(s1)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02043a4:	ce7fc0ef          	jal	ra,ffffffffc020108a <alloc_pages>
    if (page != NULL)
ffffffffc02043a8:	2e050063          	beqz	a0,ffffffffc0204688 <do_fork+0x332>
    return page - pages + nbase;
ffffffffc02043ac:	000b1a97          	auipc	s5,0xb1
ffffffffc02043b0:	d34a8a93          	addi	s5,s5,-716 # ffffffffc02b50e0 <pages>
ffffffffc02043b4:	000ab683          	ld	a3,0(s5)
ffffffffc02043b8:	00004b17          	auipc	s6,0x4
ffffffffc02043bc:	940b0b13          	addi	s6,s6,-1728 # ffffffffc0207cf8 <nbase>
ffffffffc02043c0:	000b3783          	ld	a5,0(s6)
ffffffffc02043c4:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02043c8:	000b1b97          	auipc	s7,0xb1
ffffffffc02043cc:	d10b8b93          	addi	s7,s7,-752 # ffffffffc02b50d8 <npage>
    return page - pages + nbase;
ffffffffc02043d0:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02043d2:	5dfd                	li	s11,-1
ffffffffc02043d4:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02043d8:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02043da:	00cddd93          	srli	s11,s11,0xc
ffffffffc02043de:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02043e2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02043e4:	32e67a63          	bgeu	a2,a4,ffffffffc0204718 <do_fork+0x3c2>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02043e8:	000c3603          	ld	a2,0(s8)
ffffffffc02043ec:	000b1c17          	auipc	s8,0xb1
ffffffffc02043f0:	d04c0c13          	addi	s8,s8,-764 # ffffffffc02b50f0 <va_pa_offset>
ffffffffc02043f4:	000c3703          	ld	a4,0(s8)
ffffffffc02043f8:	02863d03          	ld	s10,40(a2)
ffffffffc02043fc:	e43e                	sd	a5,8(sp)
ffffffffc02043fe:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204400:	e894                	sd	a3,16(s1)
    if (oldmm == NULL)
ffffffffc0204402:	020d0863          	beqz	s10,ffffffffc0204432 <do_fork+0xdc>
    if (clone_flags & CLONE_VM)
ffffffffc0204406:	100a7a13          	andi	s4,s4,256
ffffffffc020440a:	1c0a0163          	beqz	s4,ffffffffc02045cc <do_fork+0x276>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc020440e:	030d2703          	lw	a4,48(s10)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204412:	018d3783          	ld	a5,24(s10)
ffffffffc0204416:	c02006b7          	lui	a3,0xc0200
ffffffffc020441a:	2705                	addiw	a4,a4,1
ffffffffc020441c:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc0204420:	03a4b423          	sd	s10,40(s1)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204424:	2cd7e163          	bltu	a5,a3,ffffffffc02046e6 <do_fork+0x390>
ffffffffc0204428:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020442c:	6894                	ld	a3,16(s1)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020442e:	8f99                	sub	a5,a5,a4
ffffffffc0204430:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204432:	6789                	lui	a5,0x2
ffffffffc0204434:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd8>
ffffffffc0204438:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc020443a:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020443c:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc020443e:	87b6                	mv	a5,a3
ffffffffc0204440:	12040893          	addi	a7,s0,288
ffffffffc0204444:	00063803          	ld	a6,0(a2)
ffffffffc0204448:	6608                	ld	a0,8(a2)
ffffffffc020444a:	6a0c                	ld	a1,16(a2)
ffffffffc020444c:	6e18                	ld	a4,24(a2)
ffffffffc020444e:	0107b023          	sd	a6,0(a5)
ffffffffc0204452:	e788                	sd	a0,8(a5)
ffffffffc0204454:	eb8c                	sd	a1,16(a5)
ffffffffc0204456:	ef98                	sd	a4,24(a5)
ffffffffc0204458:	02060613          	addi	a2,a2,32
ffffffffc020445c:	02078793          	addi	a5,a5,32
ffffffffc0204460:	ff1612e3          	bne	a2,a7,ffffffffc0204444 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc0204464:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204468:	12098f63          	beqz	s3,ffffffffc02045a6 <do_fork+0x250>
ffffffffc020446c:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204470:	00000797          	auipc	a5,0x0
ffffffffc0204474:	d7878793          	addi	a5,a5,-648 # ffffffffc02041e8 <forkret>
ffffffffc0204478:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020447a:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020447c:	100027f3          	csrr	a5,sstatus
ffffffffc0204480:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204482:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204484:	14079063          	bnez	a5,ffffffffc02045c4 <do_fork+0x26e>
    if (++last_pid >= MAX_PID)
ffffffffc0204488:	000ac817          	auipc	a6,0xac
ffffffffc020448c:	7e080813          	addi	a6,a6,2016 # ffffffffc02b0c68 <last_pid.1>
ffffffffc0204490:	00082783          	lw	a5,0(a6)
ffffffffc0204494:	6709                	lui	a4,0x2
ffffffffc0204496:	0017851b          	addiw	a0,a5,1
ffffffffc020449a:	00a82023          	sw	a0,0(a6)
ffffffffc020449e:	08e55d63          	bge	a0,a4,ffffffffc0204538 <do_fork+0x1e2>
    if (last_pid >= next_safe)
ffffffffc02044a2:	000ac317          	auipc	t1,0xac
ffffffffc02044a6:	7ca30313          	addi	t1,t1,1994 # ffffffffc02b0c6c <next_safe.0>
ffffffffc02044aa:	00032783          	lw	a5,0(t1)
ffffffffc02044ae:	000b1417          	auipc	s0,0xb1
ffffffffc02044b2:	bda40413          	addi	s0,s0,-1062 # ffffffffc02b5088 <proc_list>
ffffffffc02044b6:	08f55963          	bge	a0,a5,ffffffffc0204548 <do_fork+0x1f2>
        proc->pid = get_pid();
ffffffffc02044ba:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044bc:	45a9                	li	a1,10
ffffffffc02044be:	2501                	sext.w	a0,a0
ffffffffc02044c0:	536010ef          	jal	ra,ffffffffc02059f6 <hash32>
ffffffffc02044c4:	02051793          	slli	a5,a0,0x20
ffffffffc02044c8:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02044cc:	000ad797          	auipc	a5,0xad
ffffffffc02044d0:	bbc78793          	addi	a5,a5,-1092 # ffffffffc02b1088 <hash_list>
ffffffffc02044d4:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02044d6:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02044d8:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044da:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc02044de:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02044e0:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc02044e2:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02044e4:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02044e6:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc02044ea:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc02044ec:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc02044ee:	e21c                	sd	a5,0(a2)
ffffffffc02044f0:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc02044f2:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc02044f4:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc02044f6:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02044fa:	10e4b023          	sd	a4,256(s1)
ffffffffc02044fe:	c311                	beqz	a4,ffffffffc0204502 <do_fork+0x1ac>
        proc->optr->yptr = proc;
ffffffffc0204500:	ff64                	sd	s1,248(a4)
    nr_process++;
ffffffffc0204502:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc0204506:	fae4                	sd	s1,240(a3)
    nr_process++;
ffffffffc0204508:	2785                	addiw	a5,a5,1
ffffffffc020450a:	00f92023          	sw	a5,0(s2)
    if (flag)
ffffffffc020450e:	18099263          	bnez	s3,ffffffffc0204692 <do_fork+0x33c>
    wakeup_proc(proc);
ffffffffc0204512:	8526                	mv	a0,s1
ffffffffc0204514:	63d000ef          	jal	ra,ffffffffc0205350 <wakeup_proc>
    ret = proc->pid;
ffffffffc0204518:	40c8                	lw	a0,4(s1)
}
ffffffffc020451a:	70e6                	ld	ra,120(sp)
ffffffffc020451c:	7446                	ld	s0,112(sp)
ffffffffc020451e:	74a6                	ld	s1,104(sp)
ffffffffc0204520:	7906                	ld	s2,96(sp)
ffffffffc0204522:	69e6                	ld	s3,88(sp)
ffffffffc0204524:	6a46                	ld	s4,80(sp)
ffffffffc0204526:	6aa6                	ld	s5,72(sp)
ffffffffc0204528:	6b06                	ld	s6,64(sp)
ffffffffc020452a:	7be2                	ld	s7,56(sp)
ffffffffc020452c:	7c42                	ld	s8,48(sp)
ffffffffc020452e:	7ca2                	ld	s9,40(sp)
ffffffffc0204530:	7d02                	ld	s10,32(sp)
ffffffffc0204532:	6de2                	ld	s11,24(sp)
ffffffffc0204534:	6109                	addi	sp,sp,128
ffffffffc0204536:	8082                	ret
        last_pid = 1;
ffffffffc0204538:	4785                	li	a5,1
ffffffffc020453a:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc020453e:	4505                	li	a0,1
ffffffffc0204540:	000ac317          	auipc	t1,0xac
ffffffffc0204544:	72c30313          	addi	t1,t1,1836 # ffffffffc02b0c6c <next_safe.0>
    return listelm->next;
ffffffffc0204548:	000b1417          	auipc	s0,0xb1
ffffffffc020454c:	b4040413          	addi	s0,s0,-1216 # ffffffffc02b5088 <proc_list>
ffffffffc0204550:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0204554:	6789                	lui	a5,0x2
ffffffffc0204556:	00f32023          	sw	a5,0(t1)
ffffffffc020455a:	86aa                	mv	a3,a0
ffffffffc020455c:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc020455e:	6e89                	lui	t4,0x2
ffffffffc0204560:	148e0163          	beq	t3,s0,ffffffffc02046a2 <do_fork+0x34c>
ffffffffc0204564:	88ae                	mv	a7,a1
ffffffffc0204566:	87f2                	mv	a5,t3
ffffffffc0204568:	6609                	lui	a2,0x2
ffffffffc020456a:	a811                	j	ffffffffc020457e <do_fork+0x228>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020456c:	00e6d663          	bge	a3,a4,ffffffffc0204578 <do_fork+0x222>
ffffffffc0204570:	00c75463          	bge	a4,a2,ffffffffc0204578 <do_fork+0x222>
ffffffffc0204574:	863a                	mv	a2,a4
ffffffffc0204576:	4885                	li	a7,1
ffffffffc0204578:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020457a:	00878d63          	beq	a5,s0,ffffffffc0204594 <do_fork+0x23e>
            if (proc->pid == last_pid)
ffffffffc020457e:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c7c>
ffffffffc0204582:	fed715e3          	bne	a4,a3,ffffffffc020456c <do_fork+0x216>
                if (++last_pid >= next_safe)
ffffffffc0204586:	2685                	addiw	a3,a3,1
ffffffffc0204588:	10c6d863          	bge	a3,a2,ffffffffc0204698 <do_fork+0x342>
ffffffffc020458c:	679c                	ld	a5,8(a5)
ffffffffc020458e:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204590:	fe8797e3          	bne	a5,s0,ffffffffc020457e <do_fork+0x228>
ffffffffc0204594:	c581                	beqz	a1,ffffffffc020459c <do_fork+0x246>
ffffffffc0204596:	00d82023          	sw	a3,0(a6)
ffffffffc020459a:	8536                	mv	a0,a3
ffffffffc020459c:	f0088fe3          	beqz	a7,ffffffffc02044ba <do_fork+0x164>
ffffffffc02045a0:	00c32023          	sw	a2,0(t1)
ffffffffc02045a4:	bf19                	j	ffffffffc02044ba <do_fork+0x164>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02045a6:	89b6                	mv	s3,a3
ffffffffc02045a8:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02045ac:	00000797          	auipc	a5,0x0
ffffffffc02045b0:	c3c78793          	addi	a5,a5,-964 # ffffffffc02041e8 <forkret>
ffffffffc02045b4:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02045b6:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02045b8:	100027f3          	csrr	a5,sstatus
ffffffffc02045bc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02045be:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02045c0:	ec0784e3          	beqz	a5,ffffffffc0204488 <do_fork+0x132>
        intr_disable();
ffffffffc02045c4:	bf6fc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc02045c8:	4985                	li	s3,1
ffffffffc02045ca:	bd7d                	j	ffffffffc0204488 <do_fork+0x132>
    if ((mm = mm_create()) == NULL)
ffffffffc02045cc:	b42fe0ef          	jal	ra,ffffffffc020290e <mm_create>
ffffffffc02045d0:	8caa                	mv	s9,a0
ffffffffc02045d2:	c159                	beqz	a0,ffffffffc0204658 <do_fork+0x302>
    if ((page = alloc_page()) == NULL)
ffffffffc02045d4:	4505                	li	a0,1
ffffffffc02045d6:	ab5fc0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02045da:	cd25                	beqz	a0,ffffffffc0204652 <do_fork+0x2fc>
    return page - pages + nbase;
ffffffffc02045dc:	000ab683          	ld	a3,0(s5)
ffffffffc02045e0:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc02045e2:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02045e6:	40d506b3          	sub	a3,a0,a3
ffffffffc02045ea:	8699                	srai	a3,a3,0x6
ffffffffc02045ec:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02045ee:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02045f2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02045f4:	12edf263          	bgeu	s11,a4,ffffffffc0204718 <do_fork+0x3c2>
ffffffffc02045f8:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02045fc:	6605                	lui	a2,0x1
ffffffffc02045fe:	000b1597          	auipc	a1,0xb1
ffffffffc0204602:	ad25b583          	ld	a1,-1326(a1) # ffffffffc02b50d0 <boot_pgdir_va>
ffffffffc0204606:	9a36                	add	s4,s4,a3
ffffffffc0204608:	8552                	mv	a0,s4
ffffffffc020460a:	7e7000ef          	jal	ra,ffffffffc02055f0 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc020460e:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc0204612:	014cbc23          	sd	s4,24(s9)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204616:	4785                	li	a5,1
ffffffffc0204618:	40fdb7af          	amoor.d	a5,a5,(s11)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc020461c:	8b85                	andi	a5,a5,1
ffffffffc020461e:	4a05                	li	s4,1
ffffffffc0204620:	c799                	beqz	a5,ffffffffc020462e <do_fork+0x2d8>
    {
        schedule();
ffffffffc0204622:	5af000ef          	jal	ra,ffffffffc02053d0 <schedule>
ffffffffc0204626:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock))
ffffffffc020462a:	8b85                	andi	a5,a5,1
ffffffffc020462c:	fbfd                	bnez	a5,ffffffffc0204622 <do_fork+0x2cc>
        ret = dup_mmap(mm, oldmm);
ffffffffc020462e:	85ea                	mv	a1,s10
ffffffffc0204630:	8566                	mv	a0,s9
ffffffffc0204632:	f80fe0ef          	jal	ra,ffffffffc0202db2 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204636:	57f9                	li	a5,-2
ffffffffc0204638:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc020463c:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc020463e:	cfa5                	beqz	a5,ffffffffc02046b6 <do_fork+0x360>
good_mm:
ffffffffc0204640:	8d66                	mv	s10,s9
    if (ret != 0)
ffffffffc0204642:	dc0506e3          	beqz	a0,ffffffffc020440e <do_fork+0xb8>
    exit_mmap(mm);
ffffffffc0204646:	8566                	mv	a0,s9
ffffffffc0204648:	805fe0ef          	jal	ra,ffffffffc0202e4c <exit_mmap>
    put_pgdir(mm);
ffffffffc020464c:	8566                	mv	a0,s9
ffffffffc020464e:	c27ff0ef          	jal	ra,ffffffffc0204274 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204652:	8566                	mv	a0,s9
ffffffffc0204654:	bfafe0ef          	jal	ra,ffffffffc0202a4e <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204658:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc020465a:	c02007b7          	lui	a5,0xc0200
ffffffffc020465e:	0af6e163          	bltu	a3,a5,ffffffffc0204700 <do_fork+0x3aa>
ffffffffc0204662:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage)
ffffffffc0204666:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc020466a:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc020466e:	83b1                	srli	a5,a5,0xc
ffffffffc0204670:	04e7ff63          	bgeu	a5,a4,ffffffffc02046ce <do_fork+0x378>
    return &pages[PPN(pa) - nbase];
ffffffffc0204674:	000b3703          	ld	a4,0(s6)
ffffffffc0204678:	000ab503          	ld	a0,0(s5)
ffffffffc020467c:	4589                	li	a1,2
ffffffffc020467e:	8f99                	sub	a5,a5,a4
ffffffffc0204680:	079a                	slli	a5,a5,0x6
ffffffffc0204682:	953e                	add	a0,a0,a5
ffffffffc0204684:	a45fc0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    kfree(proc);
ffffffffc0204688:	8526                	mv	a0,s1
ffffffffc020468a:	ed3fe0ef          	jal	ra,ffffffffc020355c <kfree>
    ret = -E_NO_MEM;
ffffffffc020468e:	5571                	li	a0,-4
    return ret;
ffffffffc0204690:	b569                	j	ffffffffc020451a <do_fork+0x1c4>
        intr_enable();
ffffffffc0204692:	b22fc0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0204696:	bdb5                	j	ffffffffc0204512 <do_fork+0x1bc>
                    if (last_pid >= MAX_PID)
ffffffffc0204698:	01d6c363          	blt	a3,t4,ffffffffc020469e <do_fork+0x348>
                        last_pid = 1;
ffffffffc020469c:	4685                	li	a3,1
                    goto repeat;
ffffffffc020469e:	4585                	li	a1,1
ffffffffc02046a0:	b5c1                	j	ffffffffc0204560 <do_fork+0x20a>
ffffffffc02046a2:	c599                	beqz	a1,ffffffffc02046b0 <do_fork+0x35a>
ffffffffc02046a4:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02046a8:	8536                	mv	a0,a3
ffffffffc02046aa:	bd01                	j	ffffffffc02044ba <do_fork+0x164>
    int ret = -E_NO_FREE_PROC;
ffffffffc02046ac:	556d                	li	a0,-5
ffffffffc02046ae:	b5b5                	j	ffffffffc020451a <do_fork+0x1c4>
    return last_pid;
ffffffffc02046b0:	00082503          	lw	a0,0(a6)
ffffffffc02046b4:	b519                	j	ffffffffc02044ba <do_fork+0x164>
    {
        panic("Unlock failed.\n");
ffffffffc02046b6:	00003617          	auipc	a2,0x3
ffffffffc02046ba:	dc260613          	addi	a2,a2,-574 # ffffffffc0207478 <default_pmm_manager+0xb0>
ffffffffc02046be:	03f00593          	li	a1,63
ffffffffc02046c2:	00003517          	auipc	a0,0x3
ffffffffc02046c6:	dc650513          	addi	a0,a0,-570 # ffffffffc0207488 <default_pmm_manager+0xc0>
ffffffffc02046ca:	b55fb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02046ce:	00002617          	auipc	a2,0x2
ffffffffc02046d2:	dc260613          	addi	a2,a2,-574 # ffffffffc0206490 <commands+0x7d8>
ffffffffc02046d6:	06900593          	li	a1,105
ffffffffc02046da:	00002517          	auipc	a0,0x2
ffffffffc02046de:	dd650513          	addi	a0,a0,-554 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc02046e2:	b3dfb0ef          	jal	ra,ffffffffc020021e <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02046e6:	86be                	mv	a3,a5
ffffffffc02046e8:	00002617          	auipc	a2,0x2
ffffffffc02046ec:	f1060613          	addi	a2,a2,-240 # ffffffffc02065f8 <commands+0x940>
ffffffffc02046f0:	18900593          	li	a1,393
ffffffffc02046f4:	00003517          	auipc	a0,0x3
ffffffffc02046f8:	d6c50513          	addi	a0,a0,-660 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc02046fc:	b23fb0ef          	jal	ra,ffffffffc020021e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204700:	00002617          	auipc	a2,0x2
ffffffffc0204704:	ef860613          	addi	a2,a2,-264 # ffffffffc02065f8 <commands+0x940>
ffffffffc0204708:	07700593          	li	a1,119
ffffffffc020470c:	00002517          	auipc	a0,0x2
ffffffffc0204710:	da450513          	addi	a0,a0,-604 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc0204714:	b0bfb0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc0204718:	00002617          	auipc	a2,0x2
ffffffffc020471c:	dd060613          	addi	a2,a2,-560 # ffffffffc02064e8 <commands+0x830>
ffffffffc0204720:	07100593          	li	a1,113
ffffffffc0204724:	00002517          	auipc	a0,0x2
ffffffffc0204728:	d8c50513          	addi	a0,a0,-628 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc020472c:	af3fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204730 <kernel_thread>:
{
ffffffffc0204730:	7129                	addi	sp,sp,-320
ffffffffc0204732:	fa22                	sd	s0,304(sp)
ffffffffc0204734:	f626                	sd	s1,296(sp)
ffffffffc0204736:	f24a                	sd	s2,288(sp)
ffffffffc0204738:	84ae                	mv	s1,a1
ffffffffc020473a:	892a                	mv	s2,a0
ffffffffc020473c:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020473e:	4581                	li	a1,0
ffffffffc0204740:	12000613          	li	a2,288
ffffffffc0204744:	850a                	mv	a0,sp
{
ffffffffc0204746:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204748:	697000ef          	jal	ra,ffffffffc02055de <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020474c:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020474e:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204750:	100027f3          	csrr	a5,sstatus
ffffffffc0204754:	edd7f793          	andi	a5,a5,-291
ffffffffc0204758:	1207e793          	ori	a5,a5,288
ffffffffc020475c:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020475e:	860a                	mv	a2,sp
ffffffffc0204760:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204764:	00000797          	auipc	a5,0x0
ffffffffc0204768:	9a078793          	addi	a5,a5,-1632 # ffffffffc0204104 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020476c:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020476e:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204770:	be7ff0ef          	jal	ra,ffffffffc0204356 <do_fork>
}
ffffffffc0204774:	70f2                	ld	ra,312(sp)
ffffffffc0204776:	7452                	ld	s0,304(sp)
ffffffffc0204778:	74b2                	ld	s1,296(sp)
ffffffffc020477a:	7912                	ld	s2,288(sp)
ffffffffc020477c:	6131                	addi	sp,sp,320
ffffffffc020477e:	8082                	ret

ffffffffc0204780 <do_exit>:
{
ffffffffc0204780:	7179                	addi	sp,sp,-48
ffffffffc0204782:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc0204784:	000b1417          	auipc	s0,0xb1
ffffffffc0204788:	98440413          	addi	s0,s0,-1660 # ffffffffc02b5108 <current>
ffffffffc020478c:	601c                	ld	a5,0(s0)
{
ffffffffc020478e:	f406                	sd	ra,40(sp)
ffffffffc0204790:	ec26                	sd	s1,24(sp)
ffffffffc0204792:	e84a                	sd	s2,16(sp)
ffffffffc0204794:	e44e                	sd	s3,8(sp)
ffffffffc0204796:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc0204798:	000b1717          	auipc	a4,0xb1
ffffffffc020479c:	97873703          	ld	a4,-1672(a4) # ffffffffc02b5110 <idleproc>
ffffffffc02047a0:	0ce78c63          	beq	a5,a4,ffffffffc0204878 <do_exit+0xf8>
    if (current == initproc)
ffffffffc02047a4:	000b1497          	auipc	s1,0xb1
ffffffffc02047a8:	97448493          	addi	s1,s1,-1676 # ffffffffc02b5118 <initproc>
ffffffffc02047ac:	6098                	ld	a4,0(s1)
ffffffffc02047ae:	0ee78b63          	beq	a5,a4,ffffffffc02048a4 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02047b2:	0287b983          	ld	s3,40(a5)
ffffffffc02047b6:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc02047b8:	02098663          	beqz	s3,ffffffffc02047e4 <do_exit+0x64>
ffffffffc02047bc:	000b1797          	auipc	a5,0xb1
ffffffffc02047c0:	90c7b783          	ld	a5,-1780(a5) # ffffffffc02b50c8 <boot_pgdir_pa>
ffffffffc02047c4:	577d                	li	a4,-1
ffffffffc02047c6:	177e                	slli	a4,a4,0x3f
ffffffffc02047c8:	83b1                	srli	a5,a5,0xc
ffffffffc02047ca:	8fd9                	or	a5,a5,a4
ffffffffc02047cc:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02047d0:	0309a783          	lw	a5,48(s3)
ffffffffc02047d4:	fff7871b          	addiw	a4,a5,-1
ffffffffc02047d8:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc02047dc:	cb55                	beqz	a4,ffffffffc0204890 <do_exit+0x110>
        current->mm = NULL;
ffffffffc02047de:	601c                	ld	a5,0(s0)
ffffffffc02047e0:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02047e4:	601c                	ld	a5,0(s0)
ffffffffc02047e6:	470d                	li	a4,3
ffffffffc02047e8:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02047ea:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02047ee:	100027f3          	csrr	a5,sstatus
ffffffffc02047f2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02047f4:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02047f6:	e3f9                	bnez	a5,ffffffffc02048bc <do_exit+0x13c>
        proc = current->parent;
ffffffffc02047f8:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc02047fa:	800007b7          	lui	a5,0x80000
ffffffffc02047fe:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0204800:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204802:	0ec52703          	lw	a4,236(a0)
ffffffffc0204806:	0af70f63          	beq	a4,a5,ffffffffc02048c4 <do_exit+0x144>
        while (current->cptr != NULL)
ffffffffc020480a:	6018                	ld	a4,0(s0)
ffffffffc020480c:	7b7c                	ld	a5,240(a4)
ffffffffc020480e:	c3a1                	beqz	a5,ffffffffc020484e <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204810:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204814:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204816:	0985                	addi	s3,s3,1
ffffffffc0204818:	a021                	j	ffffffffc0204820 <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc020481a:	6018                	ld	a4,0(s0)
ffffffffc020481c:	7b7c                	ld	a5,240(a4)
ffffffffc020481e:	cb85                	beqz	a5,ffffffffc020484e <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0204820:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204824:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0204826:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204828:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020482a:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020482e:	10e7b023          	sd	a4,256(a5)
ffffffffc0204832:	c311                	beqz	a4,ffffffffc0204836 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0204834:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204836:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0204838:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020483a:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020483c:	fd271fe3          	bne	a4,s2,ffffffffc020481a <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204840:	0ec52783          	lw	a5,236(a0)
ffffffffc0204844:	fd379be3          	bne	a5,s3,ffffffffc020481a <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0204848:	309000ef          	jal	ra,ffffffffc0205350 <wakeup_proc>
ffffffffc020484c:	b7f9                	j	ffffffffc020481a <do_exit+0x9a>
    if (flag)
ffffffffc020484e:	020a1263          	bnez	s4,ffffffffc0204872 <do_exit+0xf2>
    schedule();
ffffffffc0204852:	37f000ef          	jal	ra,ffffffffc02053d0 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204856:	601c                	ld	a5,0(s0)
ffffffffc0204858:	00003617          	auipc	a2,0x3
ffffffffc020485c:	c6860613          	addi	a2,a2,-920 # ffffffffc02074c0 <default_pmm_manager+0xf8>
ffffffffc0204860:	23000593          	li	a1,560
ffffffffc0204864:	43d4                	lw	a3,4(a5)
ffffffffc0204866:	00003517          	auipc	a0,0x3
ffffffffc020486a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc020486e:	9b1fb0ef          	jal	ra,ffffffffc020021e <__panic>
        intr_enable();
ffffffffc0204872:	942fc0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0204876:	bff1                	j	ffffffffc0204852 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc0204878:	00003617          	auipc	a2,0x3
ffffffffc020487c:	c2860613          	addi	a2,a2,-984 # ffffffffc02074a0 <default_pmm_manager+0xd8>
ffffffffc0204880:	1fc00593          	li	a1,508
ffffffffc0204884:	00003517          	auipc	a0,0x3
ffffffffc0204888:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc020488c:	993fb0ef          	jal	ra,ffffffffc020021e <__panic>
            exit_mmap(mm);
ffffffffc0204890:	854e                	mv	a0,s3
ffffffffc0204892:	dbafe0ef          	jal	ra,ffffffffc0202e4c <exit_mmap>
            put_pgdir(mm);
ffffffffc0204896:	854e                	mv	a0,s3
ffffffffc0204898:	9ddff0ef          	jal	ra,ffffffffc0204274 <put_pgdir>
            mm_destroy(mm);
ffffffffc020489c:	854e                	mv	a0,s3
ffffffffc020489e:	9b0fe0ef          	jal	ra,ffffffffc0202a4e <mm_destroy>
ffffffffc02048a2:	bf35                	j	ffffffffc02047de <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02048a4:	00003617          	auipc	a2,0x3
ffffffffc02048a8:	c0c60613          	addi	a2,a2,-1012 # ffffffffc02074b0 <default_pmm_manager+0xe8>
ffffffffc02048ac:	20000593          	li	a1,512
ffffffffc02048b0:	00003517          	auipc	a0,0x3
ffffffffc02048b4:	bb050513          	addi	a0,a0,-1104 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc02048b8:	967fb0ef          	jal	ra,ffffffffc020021e <__panic>
        intr_disable();
ffffffffc02048bc:	8fefc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc02048c0:	4a05                	li	s4,1
ffffffffc02048c2:	bf1d                	j	ffffffffc02047f8 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02048c4:	28d000ef          	jal	ra,ffffffffc0205350 <wakeup_proc>
ffffffffc02048c8:	b789                	j	ffffffffc020480a <do_exit+0x8a>

ffffffffc02048ca <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc02048ca:	715d                	addi	sp,sp,-80
ffffffffc02048cc:	f84a                	sd	s2,48(sp)
ffffffffc02048ce:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02048d0:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc02048d4:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc02048d6:	fc26                	sd	s1,56(sp)
ffffffffc02048d8:	f052                	sd	s4,32(sp)
ffffffffc02048da:	ec56                	sd	s5,24(sp)
ffffffffc02048dc:	e85a                	sd	s6,16(sp)
ffffffffc02048de:	e45e                	sd	s7,8(sp)
ffffffffc02048e0:	e486                	sd	ra,72(sp)
ffffffffc02048e2:	e0a2                	sd	s0,64(sp)
ffffffffc02048e4:	84aa                	mv	s1,a0
ffffffffc02048e6:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02048e8:	000b1b97          	auipc	s7,0xb1
ffffffffc02048ec:	820b8b93          	addi	s7,s7,-2016 # ffffffffc02b5108 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc02048f0:	00050b1b          	sext.w	s6,a0
ffffffffc02048f4:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02048f8:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02048fa:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc02048fc:	ccbd                	beqz	s1,ffffffffc020497a <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc02048fe:	0359e863          	bltu	s3,s5,ffffffffc020492e <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204902:	45a9                	li	a1,10
ffffffffc0204904:	855a                	mv	a0,s6
ffffffffc0204906:	0f0010ef          	jal	ra,ffffffffc02059f6 <hash32>
ffffffffc020490a:	02051793          	slli	a5,a0,0x20
ffffffffc020490e:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204912:	000ac797          	auipc	a5,0xac
ffffffffc0204916:	77678793          	addi	a5,a5,1910 # ffffffffc02b1088 <hash_list>
ffffffffc020491a:	953e                	add	a0,a0,a5
ffffffffc020491c:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc020491e:	a029                	j	ffffffffc0204928 <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc0204920:	f2c42783          	lw	a5,-212(s0)
ffffffffc0204924:	02978163          	beq	a5,s1,ffffffffc0204946 <do_wait.part.0+0x7c>
ffffffffc0204928:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc020492a:	fe851be3          	bne	a0,s0,ffffffffc0204920 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc020492e:	5579                	li	a0,-2
}
ffffffffc0204930:	60a6                	ld	ra,72(sp)
ffffffffc0204932:	6406                	ld	s0,64(sp)
ffffffffc0204934:	74e2                	ld	s1,56(sp)
ffffffffc0204936:	7942                	ld	s2,48(sp)
ffffffffc0204938:	79a2                	ld	s3,40(sp)
ffffffffc020493a:	7a02                	ld	s4,32(sp)
ffffffffc020493c:	6ae2                	ld	s5,24(sp)
ffffffffc020493e:	6b42                	ld	s6,16(sp)
ffffffffc0204940:	6ba2                	ld	s7,8(sp)
ffffffffc0204942:	6161                	addi	sp,sp,80
ffffffffc0204944:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc0204946:	000bb683          	ld	a3,0(s7)
ffffffffc020494a:	f4843783          	ld	a5,-184(s0)
ffffffffc020494e:	fed790e3          	bne	a5,a3,ffffffffc020492e <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204952:	f2842703          	lw	a4,-216(s0)
ffffffffc0204956:	478d                	li	a5,3
ffffffffc0204958:	0ef70b63          	beq	a4,a5,ffffffffc0204a4e <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc020495c:	4785                	li	a5,1
ffffffffc020495e:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0204960:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0204964:	26d000ef          	jal	ra,ffffffffc02053d0 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc0204968:	000bb783          	ld	a5,0(s7)
ffffffffc020496c:	0b07a783          	lw	a5,176(a5)
ffffffffc0204970:	8b85                	andi	a5,a5,1
ffffffffc0204972:	d7c9                	beqz	a5,ffffffffc02048fc <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc0204974:	555d                	li	a0,-9
ffffffffc0204976:	e0bff0ef          	jal	ra,ffffffffc0204780 <do_exit>
        proc = current->cptr;
ffffffffc020497a:	000bb683          	ld	a3,0(s7)
ffffffffc020497e:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204980:	d45d                	beqz	s0,ffffffffc020492e <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204982:	470d                	li	a4,3
ffffffffc0204984:	a021                	j	ffffffffc020498c <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204986:	10043403          	ld	s0,256(s0)
ffffffffc020498a:	d869                	beqz	s0,ffffffffc020495c <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020498c:	401c                	lw	a5,0(s0)
ffffffffc020498e:	fee79ce3          	bne	a5,a4,ffffffffc0204986 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc0204992:	000b0797          	auipc	a5,0xb0
ffffffffc0204996:	77e7b783          	ld	a5,1918(a5) # ffffffffc02b5110 <idleproc>
ffffffffc020499a:	0c878963          	beq	a5,s0,ffffffffc0204a6c <do_wait.part.0+0x1a2>
ffffffffc020499e:	000b0797          	auipc	a5,0xb0
ffffffffc02049a2:	77a7b783          	ld	a5,1914(a5) # ffffffffc02b5118 <initproc>
ffffffffc02049a6:	0cf40363          	beq	s0,a5,ffffffffc0204a6c <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc02049aa:	000a0663          	beqz	s4,ffffffffc02049b6 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02049ae:	0e842783          	lw	a5,232(s0)
ffffffffc02049b2:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02049b6:	100027f3          	csrr	a5,sstatus
ffffffffc02049ba:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02049bc:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02049be:	e7c1                	bnez	a5,ffffffffc0204a46 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02049c0:	6c70                	ld	a2,216(s0)
ffffffffc02049c2:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc02049c4:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02049c8:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02049ca:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02049cc:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02049ce:	6470                	ld	a2,200(s0)
ffffffffc02049d0:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02049d2:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02049d4:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc02049d6:	c319                	beqz	a4,ffffffffc02049dc <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc02049d8:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc02049da:	7c7c                	ld	a5,248(s0)
ffffffffc02049dc:	c3b5                	beqz	a5,ffffffffc0204a40 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc02049de:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc02049e2:	000b0717          	auipc	a4,0xb0
ffffffffc02049e6:	73e70713          	addi	a4,a4,1854 # ffffffffc02b5120 <nr_process>
ffffffffc02049ea:	431c                	lw	a5,0(a4)
ffffffffc02049ec:	37fd                	addiw	a5,a5,-1
ffffffffc02049ee:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc02049f0:	e5a9                	bnez	a1,ffffffffc0204a3a <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02049f2:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02049f4:	c02007b7          	lui	a5,0xc0200
ffffffffc02049f8:	04f6ee63          	bltu	a3,a5,ffffffffc0204a54 <do_wait.part.0+0x18a>
ffffffffc02049fc:	000b0797          	auipc	a5,0xb0
ffffffffc0204a00:	6f47b783          	ld	a5,1780(a5) # ffffffffc02b50f0 <va_pa_offset>
ffffffffc0204a04:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204a06:	82b1                	srli	a3,a3,0xc
ffffffffc0204a08:	000b0797          	auipc	a5,0xb0
ffffffffc0204a0c:	6d07b783          	ld	a5,1744(a5) # ffffffffc02b50d8 <npage>
ffffffffc0204a10:	06f6fa63          	bgeu	a3,a5,ffffffffc0204a84 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0204a14:	00003517          	auipc	a0,0x3
ffffffffc0204a18:	2e453503          	ld	a0,740(a0) # ffffffffc0207cf8 <nbase>
ffffffffc0204a1c:	8e89                	sub	a3,a3,a0
ffffffffc0204a1e:	069a                	slli	a3,a3,0x6
ffffffffc0204a20:	000b0517          	auipc	a0,0xb0
ffffffffc0204a24:	6c053503          	ld	a0,1728(a0) # ffffffffc02b50e0 <pages>
ffffffffc0204a28:	9536                	add	a0,a0,a3
ffffffffc0204a2a:	4589                	li	a1,2
ffffffffc0204a2c:	e9cfc0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    kfree(proc);
ffffffffc0204a30:	8522                	mv	a0,s0
ffffffffc0204a32:	b2bfe0ef          	jal	ra,ffffffffc020355c <kfree>
    return 0;
ffffffffc0204a36:	4501                	li	a0,0
ffffffffc0204a38:	bde5                	j	ffffffffc0204930 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0204a3a:	f7bfb0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0204a3e:	bf55                	j	ffffffffc02049f2 <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc0204a40:	701c                	ld	a5,32(s0)
ffffffffc0204a42:	fbf8                	sd	a4,240(a5)
ffffffffc0204a44:	bf79                	j	ffffffffc02049e2 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0204a46:	f75fb0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc0204a4a:	4585                	li	a1,1
ffffffffc0204a4c:	bf95                	j	ffffffffc02049c0 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204a4e:	f2840413          	addi	s0,s0,-216
ffffffffc0204a52:	b781                	j	ffffffffc0204992 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0204a54:	00002617          	auipc	a2,0x2
ffffffffc0204a58:	ba460613          	addi	a2,a2,-1116 # ffffffffc02065f8 <commands+0x940>
ffffffffc0204a5c:	07700593          	li	a1,119
ffffffffc0204a60:	00002517          	auipc	a0,0x2
ffffffffc0204a64:	a5050513          	addi	a0,a0,-1456 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc0204a68:	fb6fb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0204a6c:	00003617          	auipc	a2,0x3
ffffffffc0204a70:	a7460613          	addi	a2,a2,-1420 # ffffffffc02074e0 <default_pmm_manager+0x118>
ffffffffc0204a74:	35200593          	li	a1,850
ffffffffc0204a78:	00003517          	auipc	a0,0x3
ffffffffc0204a7c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0204a80:	f9efb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204a84:	00002617          	auipc	a2,0x2
ffffffffc0204a88:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0206490 <commands+0x7d8>
ffffffffc0204a8c:	06900593          	li	a1,105
ffffffffc0204a90:	00002517          	auipc	a0,0x2
ffffffffc0204a94:	a2050513          	addi	a0,a0,-1504 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc0204a98:	f86fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204a9c <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc0204a9c:	1141                	addi	sp,sp,-16
ffffffffc0204a9e:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204aa0:	e68fc0ef          	jal	ra,ffffffffc0201108 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0204aa4:	a05fe0ef          	jal	ra,ffffffffc02034a8 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204aa8:	4601                	li	a2,0
ffffffffc0204aaa:	4581                	li	a1,0
ffffffffc0204aac:	fffff517          	auipc	a0,0xfffff
ffffffffc0204ab0:	74a50513          	addi	a0,a0,1866 # ffffffffc02041f6 <user_main>
ffffffffc0204ab4:	c7dff0ef          	jal	ra,ffffffffc0204730 <kernel_thread>
    if (pid <= 0)
ffffffffc0204ab8:	00a04563          	bgtz	a0,ffffffffc0204ac2 <init_main+0x26>
ffffffffc0204abc:	a071                	j	ffffffffc0204b48 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc0204abe:	113000ef          	jal	ra,ffffffffc02053d0 <schedule>
    if (code_store != NULL)
ffffffffc0204ac2:	4581                	li	a1,0
ffffffffc0204ac4:	4501                	li	a0,0
ffffffffc0204ac6:	e05ff0ef          	jal	ra,ffffffffc02048ca <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc0204aca:	d975                	beqz	a0,ffffffffc0204abe <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204acc:	00003517          	auipc	a0,0x3
ffffffffc0204ad0:	a5450513          	addi	a0,a0,-1452 # ffffffffc0207520 <default_pmm_manager+0x158>
ffffffffc0204ad4:	e0cfb0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204ad8:	000b0797          	auipc	a5,0xb0
ffffffffc0204adc:	6407b783          	ld	a5,1600(a5) # ffffffffc02b5118 <initproc>
ffffffffc0204ae0:	7bf8                	ld	a4,240(a5)
ffffffffc0204ae2:	e339                	bnez	a4,ffffffffc0204b28 <init_main+0x8c>
ffffffffc0204ae4:	7ff8                	ld	a4,248(a5)
ffffffffc0204ae6:	e329                	bnez	a4,ffffffffc0204b28 <init_main+0x8c>
ffffffffc0204ae8:	1007b703          	ld	a4,256(a5)
ffffffffc0204aec:	ef15                	bnez	a4,ffffffffc0204b28 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204aee:	000b0697          	auipc	a3,0xb0
ffffffffc0204af2:	6326a683          	lw	a3,1586(a3) # ffffffffc02b5120 <nr_process>
ffffffffc0204af6:	4709                	li	a4,2
ffffffffc0204af8:	0ae69463          	bne	a3,a4,ffffffffc0204ba0 <init_main+0x104>
    return listelm->next;
ffffffffc0204afc:	000b0697          	auipc	a3,0xb0
ffffffffc0204b00:	58c68693          	addi	a3,a3,1420 # ffffffffc02b5088 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204b04:	6698                	ld	a4,8(a3)
ffffffffc0204b06:	0c878793          	addi	a5,a5,200
ffffffffc0204b0a:	06f71b63          	bne	a4,a5,ffffffffc0204b80 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204b0e:	629c                	ld	a5,0(a3)
ffffffffc0204b10:	04f71863          	bne	a4,a5,ffffffffc0204b60 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204b14:	00003517          	auipc	a0,0x3
ffffffffc0204b18:	af450513          	addi	a0,a0,-1292 # ffffffffc0207608 <default_pmm_manager+0x240>
ffffffffc0204b1c:	dc4fb0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return 0;
}
ffffffffc0204b20:	60a2                	ld	ra,8(sp)
ffffffffc0204b22:	4501                	li	a0,0
ffffffffc0204b24:	0141                	addi	sp,sp,16
ffffffffc0204b26:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204b28:	00003697          	auipc	a3,0x3
ffffffffc0204b2c:	a2068693          	addi	a3,a3,-1504 # ffffffffc0207548 <default_pmm_manager+0x180>
ffffffffc0204b30:	00002617          	auipc	a2,0x2
ffffffffc0204b34:	a2060613          	addi	a2,a2,-1504 # ffffffffc0206550 <commands+0x898>
ffffffffc0204b38:	3c000593          	li	a1,960
ffffffffc0204b3c:	00003517          	auipc	a0,0x3
ffffffffc0204b40:	92450513          	addi	a0,a0,-1756 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0204b44:	edafb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("create user_main failed.\n");
ffffffffc0204b48:	00003617          	auipc	a2,0x3
ffffffffc0204b4c:	9b860613          	addi	a2,a2,-1608 # ffffffffc0207500 <default_pmm_manager+0x138>
ffffffffc0204b50:	3b700593          	li	a1,951
ffffffffc0204b54:	00003517          	auipc	a0,0x3
ffffffffc0204b58:	90c50513          	addi	a0,a0,-1780 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0204b5c:	ec2fb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204b60:	00003697          	auipc	a3,0x3
ffffffffc0204b64:	a7868693          	addi	a3,a3,-1416 # ffffffffc02075d8 <default_pmm_manager+0x210>
ffffffffc0204b68:	00002617          	auipc	a2,0x2
ffffffffc0204b6c:	9e860613          	addi	a2,a2,-1560 # ffffffffc0206550 <commands+0x898>
ffffffffc0204b70:	3c300593          	li	a1,963
ffffffffc0204b74:	00003517          	auipc	a0,0x3
ffffffffc0204b78:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0204b7c:	ea2fb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204b80:	00003697          	auipc	a3,0x3
ffffffffc0204b84:	a2868693          	addi	a3,a3,-1496 # ffffffffc02075a8 <default_pmm_manager+0x1e0>
ffffffffc0204b88:	00002617          	auipc	a2,0x2
ffffffffc0204b8c:	9c860613          	addi	a2,a2,-1592 # ffffffffc0206550 <commands+0x898>
ffffffffc0204b90:	3c200593          	li	a1,962
ffffffffc0204b94:	00003517          	auipc	a0,0x3
ffffffffc0204b98:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0204b9c:	e82fb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_process == 2);
ffffffffc0204ba0:	00003697          	auipc	a3,0x3
ffffffffc0204ba4:	9f868693          	addi	a3,a3,-1544 # ffffffffc0207598 <default_pmm_manager+0x1d0>
ffffffffc0204ba8:	00002617          	auipc	a2,0x2
ffffffffc0204bac:	9a860613          	addi	a2,a2,-1624 # ffffffffc0206550 <commands+0x898>
ffffffffc0204bb0:	3c100593          	li	a1,961
ffffffffc0204bb4:	00003517          	auipc	a0,0x3
ffffffffc0204bb8:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0204bbc:	e62fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204bc0 <do_execve>:
{
ffffffffc0204bc0:	7171                	addi	sp,sp,-176
ffffffffc0204bc2:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204bc4:	000b0d97          	auipc	s11,0xb0
ffffffffc0204bc8:	544d8d93          	addi	s11,s11,1348 # ffffffffc02b5108 <current>
ffffffffc0204bcc:	000db783          	ld	a5,0(s11)
{
ffffffffc0204bd0:	e54e                	sd	s3,136(sp)
ffffffffc0204bd2:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204bd4:	0287b983          	ld	s3,40(a5)
{
ffffffffc0204bd8:	e94a                	sd	s2,144(sp)
ffffffffc0204bda:	f4de                	sd	s7,104(sp)
ffffffffc0204bdc:	892a                	mv	s2,a0
ffffffffc0204bde:	8bb2                	mv	s7,a2
ffffffffc0204be0:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204be2:	862e                	mv	a2,a1
ffffffffc0204be4:	4681                	li	a3,0
ffffffffc0204be6:	85aa                	mv	a1,a0
ffffffffc0204be8:	854e                	mv	a0,s3
{
ffffffffc0204bea:	f506                	sd	ra,168(sp)
ffffffffc0204bec:	f122                	sd	s0,160(sp)
ffffffffc0204bee:	e152                	sd	s4,128(sp)
ffffffffc0204bf0:	fcd6                	sd	s5,120(sp)
ffffffffc0204bf2:	f8da                	sd	s6,112(sp)
ffffffffc0204bf4:	f0e2                	sd	s8,96(sp)
ffffffffc0204bf6:	ece6                	sd	s9,88(sp)
ffffffffc0204bf8:	e8ea                	sd	s10,80(sp)
ffffffffc0204bfa:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204bfc:	deafe0ef          	jal	ra,ffffffffc02031e6 <user_mem_check>
ffffffffc0204c00:	40050a63          	beqz	a0,ffffffffc0205014 <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204c04:	4641                	li	a2,16
ffffffffc0204c06:	4581                	li	a1,0
ffffffffc0204c08:	1808                	addi	a0,sp,48
ffffffffc0204c0a:	1d5000ef          	jal	ra,ffffffffc02055de <memset>
    memcpy(local_name, name, len);
ffffffffc0204c0e:	47bd                	li	a5,15
ffffffffc0204c10:	8626                	mv	a2,s1
ffffffffc0204c12:	1e97e263          	bltu	a5,s1,ffffffffc0204df6 <do_execve+0x236>
ffffffffc0204c16:	85ca                	mv	a1,s2
ffffffffc0204c18:	1808                	addi	a0,sp,48
ffffffffc0204c1a:	1d7000ef          	jal	ra,ffffffffc02055f0 <memcpy>
    if (mm != NULL)
ffffffffc0204c1e:	1e098363          	beqz	s3,ffffffffc0204e04 <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc0204c22:	00002517          	auipc	a0,0x2
ffffffffc0204c26:	00e50513          	addi	a0,a0,14 # ffffffffc0206c30 <commands+0xf78>
ffffffffc0204c2a:	cf0fb0ef          	jal	ra,ffffffffc020011a <cputs>
ffffffffc0204c2e:	000b0797          	auipc	a5,0xb0
ffffffffc0204c32:	49a7b783          	ld	a5,1178(a5) # ffffffffc02b50c8 <boot_pgdir_pa>
ffffffffc0204c36:	577d                	li	a4,-1
ffffffffc0204c38:	177e                	slli	a4,a4,0x3f
ffffffffc0204c3a:	83b1                	srli	a5,a5,0xc
ffffffffc0204c3c:	8fd9                	or	a5,a5,a4
ffffffffc0204c3e:	18079073          	csrw	satp,a5
ffffffffc0204c42:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b88>
ffffffffc0204c46:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204c4a:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc0204c4e:	2c070463          	beqz	a4,ffffffffc0204f16 <do_execve+0x356>
        current->mm = NULL;
ffffffffc0204c52:	000db783          	ld	a5,0(s11)
ffffffffc0204c56:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204c5a:	cb5fd0ef          	jal	ra,ffffffffc020290e <mm_create>
ffffffffc0204c5e:	84aa                	mv	s1,a0
ffffffffc0204c60:	1c050d63          	beqz	a0,ffffffffc0204e3a <do_execve+0x27a>
    if ((page = alloc_page()) == NULL)
ffffffffc0204c64:	4505                	li	a0,1
ffffffffc0204c66:	c24fc0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0204c6a:	3a050963          	beqz	a0,ffffffffc020501c <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc0204c6e:	000b0c97          	auipc	s9,0xb0
ffffffffc0204c72:	472c8c93          	addi	s9,s9,1138 # ffffffffc02b50e0 <pages>
ffffffffc0204c76:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204c7a:	000b0c17          	auipc	s8,0xb0
ffffffffc0204c7e:	45ec0c13          	addi	s8,s8,1118 # ffffffffc02b50d8 <npage>
    return page - pages + nbase;
ffffffffc0204c82:	00003717          	auipc	a4,0x3
ffffffffc0204c86:	07673703          	ld	a4,118(a4) # ffffffffc0207cf8 <nbase>
ffffffffc0204c8a:	40d506b3          	sub	a3,a0,a3
ffffffffc0204c8e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204c90:	5afd                	li	s5,-1
ffffffffc0204c92:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0204c96:	96ba                	add	a3,a3,a4
ffffffffc0204c98:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204c9a:	00cad713          	srli	a4,s5,0xc
ffffffffc0204c9e:	ec3a                	sd	a4,24(sp)
ffffffffc0204ca0:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ca2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ca4:	38f77063          	bgeu	a4,a5,ffffffffc0205024 <do_execve+0x464>
ffffffffc0204ca8:	000b0b17          	auipc	s6,0xb0
ffffffffc0204cac:	448b0b13          	addi	s6,s6,1096 # ffffffffc02b50f0 <va_pa_offset>
ffffffffc0204cb0:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204cb4:	6605                	lui	a2,0x1
ffffffffc0204cb6:	000b0597          	auipc	a1,0xb0
ffffffffc0204cba:	41a5b583          	ld	a1,1050(a1) # ffffffffc02b50d0 <boot_pgdir_va>
ffffffffc0204cbe:	9936                	add	s2,s2,a3
ffffffffc0204cc0:	854a                	mv	a0,s2
ffffffffc0204cc2:	12f000ef          	jal	ra,ffffffffc02055f0 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204cc6:	7782                	ld	a5,32(sp)
ffffffffc0204cc8:	4398                	lw	a4,0(a5)
ffffffffc0204cca:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204cce:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204cd2:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9457>
ffffffffc0204cd6:	14f71863          	bne	a4,a5,ffffffffc0204e26 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204cda:	7682                	ld	a3,32(sp)
ffffffffc0204cdc:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204ce0:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204ce4:	00371793          	slli	a5,a4,0x3
ffffffffc0204ce8:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204cea:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204cec:	078e                	slli	a5,a5,0x3
ffffffffc0204cee:	97ce                	add	a5,a5,s3
ffffffffc0204cf0:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204cf2:	00f9fc63          	bgeu	s3,a5,ffffffffc0204d0a <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204cf6:	0009a783          	lw	a5,0(s3)
ffffffffc0204cfa:	4705                	li	a4,1
ffffffffc0204cfc:	14e78163          	beq	a5,a4,ffffffffc0204e3e <do_execve+0x27e>
    for (; ph < ph_end; ph++)
ffffffffc0204d00:	77a2                	ld	a5,40(sp)
ffffffffc0204d02:	03898993          	addi	s3,s3,56
ffffffffc0204d06:	fef9e8e3          	bltu	s3,a5,ffffffffc0204cf6 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204d0a:	4701                	li	a4,0
ffffffffc0204d0c:	46ad                	li	a3,11
ffffffffc0204d0e:	00100637          	lui	a2,0x100
ffffffffc0204d12:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204d16:	8526                	mv	a0,s1
ffffffffc0204d18:	d89fd0ef          	jal	ra,ffffffffc0202aa0 <mm_map>
ffffffffc0204d1c:	8a2a                	mv	s4,a0
ffffffffc0204d1e:	1e051263          	bnez	a0,ffffffffc0204f02 <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204d22:	6c88                	ld	a0,24(s1)
ffffffffc0204d24:	467d                	li	a2,31
ffffffffc0204d26:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204d2a:	afffd0ef          	jal	ra,ffffffffc0202828 <pgdir_alloc_page>
ffffffffc0204d2e:	38050363          	beqz	a0,ffffffffc02050b4 <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d32:	6c88                	ld	a0,24(s1)
ffffffffc0204d34:	467d                	li	a2,31
ffffffffc0204d36:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204d3a:	aeffd0ef          	jal	ra,ffffffffc0202828 <pgdir_alloc_page>
ffffffffc0204d3e:	34050b63          	beqz	a0,ffffffffc0205094 <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d42:	6c88                	ld	a0,24(s1)
ffffffffc0204d44:	467d                	li	a2,31
ffffffffc0204d46:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204d4a:	adffd0ef          	jal	ra,ffffffffc0202828 <pgdir_alloc_page>
ffffffffc0204d4e:	32050363          	beqz	a0,ffffffffc0205074 <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d52:	6c88                	ld	a0,24(s1)
ffffffffc0204d54:	467d                	li	a2,31
ffffffffc0204d56:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204d5a:	acffd0ef          	jal	ra,ffffffffc0202828 <pgdir_alloc_page>
ffffffffc0204d5e:	2e050b63          	beqz	a0,ffffffffc0205054 <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc0204d62:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204d64:	000db603          	ld	a2,0(s11)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204d68:	6c94                	ld	a3,24(s1)
ffffffffc0204d6a:	2785                	addiw	a5,a5,1
ffffffffc0204d6c:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0204d6e:	f604                	sd	s1,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204d70:	c02007b7          	lui	a5,0xc0200
ffffffffc0204d74:	2cf6e463          	bltu	a3,a5,ffffffffc020503c <do_execve+0x47c>
ffffffffc0204d78:	000b3783          	ld	a5,0(s6)
ffffffffc0204d7c:	577d                	li	a4,-1
ffffffffc0204d7e:	177e                	slli	a4,a4,0x3f
ffffffffc0204d80:	8e9d                	sub	a3,a3,a5
ffffffffc0204d82:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204d86:	f654                	sd	a3,168(a2)
ffffffffc0204d88:	8fd9                	or	a5,a5,a4
ffffffffc0204d8a:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204d8e:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204d90:	4581                	li	a1,0
ffffffffc0204d92:	12000613          	li	a2,288
ffffffffc0204d96:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0204d98:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204d9c:	043000ef          	jal	ra,ffffffffc02055de <memset>
    tf->epc = elf->e_entry;
ffffffffc0204da0:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204da2:	000db903          	ld	s2,0(s11)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE | SSTATUS_SIE);
ffffffffc0204da6:	edd4f493          	andi	s1,s1,-291
    tf->epc = elf->e_entry;
ffffffffc0204daa:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204dac:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204dae:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_exit_out_size+0xffffffff7fff4f8c>
    tf->gpr.sp = USTACKTOP;
ffffffffc0204db2:	07fe                	slli	a5,a5,0x1f
    tf->status |= SSTATUS_SPIE;
ffffffffc0204db4:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204db8:	4641                	li	a2,16
ffffffffc0204dba:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0204dbc:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0204dbe:	10e43423          	sd	a4,264(s0)
    tf->status |= SSTATUS_SPIE;
ffffffffc0204dc2:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204dc6:	854a                	mv	a0,s2
ffffffffc0204dc8:	017000ef          	jal	ra,ffffffffc02055de <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204dcc:	463d                	li	a2,15
ffffffffc0204dce:	180c                	addi	a1,sp,48
ffffffffc0204dd0:	854a                	mv	a0,s2
ffffffffc0204dd2:	01f000ef          	jal	ra,ffffffffc02055f0 <memcpy>
}
ffffffffc0204dd6:	70aa                	ld	ra,168(sp)
ffffffffc0204dd8:	740a                	ld	s0,160(sp)
ffffffffc0204dda:	64ea                	ld	s1,152(sp)
ffffffffc0204ddc:	694a                	ld	s2,144(sp)
ffffffffc0204dde:	69aa                	ld	s3,136(sp)
ffffffffc0204de0:	7ae6                	ld	s5,120(sp)
ffffffffc0204de2:	7b46                	ld	s6,112(sp)
ffffffffc0204de4:	7ba6                	ld	s7,104(sp)
ffffffffc0204de6:	7c06                	ld	s8,96(sp)
ffffffffc0204de8:	6ce6                	ld	s9,88(sp)
ffffffffc0204dea:	6d46                	ld	s10,80(sp)
ffffffffc0204dec:	6da6                	ld	s11,72(sp)
ffffffffc0204dee:	8552                	mv	a0,s4
ffffffffc0204df0:	6a0a                	ld	s4,128(sp)
ffffffffc0204df2:	614d                	addi	sp,sp,176
ffffffffc0204df4:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0204df6:	463d                	li	a2,15
ffffffffc0204df8:	85ca                	mv	a1,s2
ffffffffc0204dfa:	1808                	addi	a0,sp,48
ffffffffc0204dfc:	7f4000ef          	jal	ra,ffffffffc02055f0 <memcpy>
    if (mm != NULL)
ffffffffc0204e00:	e20991e3          	bnez	s3,ffffffffc0204c22 <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc0204e04:	000db783          	ld	a5,0(s11)
ffffffffc0204e08:	779c                	ld	a5,40(a5)
ffffffffc0204e0a:	e40788e3          	beqz	a5,ffffffffc0204c5a <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204e0e:	00003617          	auipc	a2,0x3
ffffffffc0204e12:	81a60613          	addi	a2,a2,-2022 # ffffffffc0207628 <default_pmm_manager+0x260>
ffffffffc0204e16:	23c00593          	li	a1,572
ffffffffc0204e1a:	00002517          	auipc	a0,0x2
ffffffffc0204e1e:	64650513          	addi	a0,a0,1606 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0204e22:	bfcfb0ef          	jal	ra,ffffffffc020021e <__panic>
    put_pgdir(mm);
ffffffffc0204e26:	8526                	mv	a0,s1
ffffffffc0204e28:	c4cff0ef          	jal	ra,ffffffffc0204274 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204e2c:	8526                	mv	a0,s1
ffffffffc0204e2e:	c21fd0ef          	jal	ra,ffffffffc0202a4e <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0204e32:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0204e34:	8552                	mv	a0,s4
ffffffffc0204e36:	94bff0ef          	jal	ra,ffffffffc0204780 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0204e3a:	5a71                	li	s4,-4
ffffffffc0204e3c:	bfe5                	j	ffffffffc0204e34 <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204e3e:	0289b603          	ld	a2,40(s3)
ffffffffc0204e42:	0209b783          	ld	a5,32(s3)
ffffffffc0204e46:	1cf66d63          	bltu	a2,a5,ffffffffc0205020 <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204e4a:	0049a783          	lw	a5,4(s3)
ffffffffc0204e4e:	0017f693          	andi	a3,a5,1
ffffffffc0204e52:	c291                	beqz	a3,ffffffffc0204e56 <do_execve+0x296>
            vm_flags |= VM_EXEC;
ffffffffc0204e54:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204e56:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204e5a:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204e5c:	e779                	bnez	a4,ffffffffc0204f2a <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204e5e:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204e60:	c781                	beqz	a5,ffffffffc0204e68 <do_execve+0x2a8>
            vm_flags |= VM_READ;
ffffffffc0204e62:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0204e66:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE)
ffffffffc0204e68:	0026f793          	andi	a5,a3,2
ffffffffc0204e6c:	e3f1                	bnez	a5,ffffffffc0204f30 <do_execve+0x370>
        if (vm_flags & VM_EXEC)
ffffffffc0204e6e:	0046f793          	andi	a5,a3,4
ffffffffc0204e72:	c399                	beqz	a5,ffffffffc0204e78 <do_execve+0x2b8>
            perm |= PTE_X;
ffffffffc0204e74:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204e78:	0109b583          	ld	a1,16(s3)
ffffffffc0204e7c:	4701                	li	a4,0
ffffffffc0204e7e:	8526                	mv	a0,s1
ffffffffc0204e80:	c21fd0ef          	jal	ra,ffffffffc0202aa0 <mm_map>
ffffffffc0204e84:	8a2a                	mv	s4,a0
ffffffffc0204e86:	ed35                	bnez	a0,ffffffffc0204f02 <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204e88:	0109bb83          	ld	s7,16(s3)
ffffffffc0204e8c:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0204e8e:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204e92:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204e96:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204e9a:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204e9c:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204e9e:	993e                	add	s2,s2,a5
        while (start < end)
ffffffffc0204ea0:	054be963          	bltu	s7,s4,ffffffffc0204ef2 <do_execve+0x332>
ffffffffc0204ea4:	aa95                	j	ffffffffc0205018 <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204ea6:	6785                	lui	a5,0x1
ffffffffc0204ea8:	415b8533          	sub	a0,s7,s5
ffffffffc0204eac:	9abe                	add	s5,s5,a5
ffffffffc0204eae:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204eb2:	015a7463          	bgeu	s4,s5,ffffffffc0204eba <do_execve+0x2fa>
                size -= la - end;
ffffffffc0204eb6:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0204eba:	000cb683          	ld	a3,0(s9)
ffffffffc0204ebe:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204ec0:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204ec4:	40d406b3          	sub	a3,s0,a3
ffffffffc0204ec8:	8699                	srai	a3,a3,0x6
ffffffffc0204eca:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204ecc:	67e2                	ld	a5,24(sp)
ffffffffc0204ece:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ed2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ed4:	14b87863          	bgeu	a6,a1,ffffffffc0205024 <do_execve+0x464>
ffffffffc0204ed8:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204edc:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204ede:	9bb2                	add	s7,s7,a2
ffffffffc0204ee0:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204ee2:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204ee4:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204ee6:	70a000ef          	jal	ra,ffffffffc02055f0 <memcpy>
            start += size, from += size;
ffffffffc0204eea:	6622                	ld	a2,8(sp)
ffffffffc0204eec:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204eee:	054bf363          	bgeu	s7,s4,ffffffffc0204f34 <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204ef2:	6c88                	ld	a0,24(s1)
ffffffffc0204ef4:	866a                	mv	a2,s10
ffffffffc0204ef6:	85d6                	mv	a1,s5
ffffffffc0204ef8:	931fd0ef          	jal	ra,ffffffffc0202828 <pgdir_alloc_page>
ffffffffc0204efc:	842a                	mv	s0,a0
ffffffffc0204efe:	f545                	bnez	a0,ffffffffc0204ea6 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0204f00:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0204f02:	8526                	mv	a0,s1
ffffffffc0204f04:	f49fd0ef          	jal	ra,ffffffffc0202e4c <exit_mmap>
    put_pgdir(mm);
ffffffffc0204f08:	8526                	mv	a0,s1
ffffffffc0204f0a:	b6aff0ef          	jal	ra,ffffffffc0204274 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204f0e:	8526                	mv	a0,s1
ffffffffc0204f10:	b3ffd0ef          	jal	ra,ffffffffc0202a4e <mm_destroy>
    return ret;
ffffffffc0204f14:	b705                	j	ffffffffc0204e34 <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0204f16:	854e                	mv	a0,s3
ffffffffc0204f18:	f35fd0ef          	jal	ra,ffffffffc0202e4c <exit_mmap>
            put_pgdir(mm);
ffffffffc0204f1c:	854e                	mv	a0,s3
ffffffffc0204f1e:	b56ff0ef          	jal	ra,ffffffffc0204274 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204f22:	854e                	mv	a0,s3
ffffffffc0204f24:	b2bfd0ef          	jal	ra,ffffffffc0202a4e <mm_destroy>
ffffffffc0204f28:	b32d                	j	ffffffffc0204c52 <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204f2a:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204f2e:	fb95                	bnez	a5,ffffffffc0204e62 <do_execve+0x2a2>
            perm |= (PTE_W | PTE_R);
ffffffffc0204f30:	4d5d                	li	s10,23
ffffffffc0204f32:	bf35                	j	ffffffffc0204e6e <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204f34:	0109b683          	ld	a3,16(s3)
ffffffffc0204f38:	0289b903          	ld	s2,40(s3)
ffffffffc0204f3c:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204f3e:	075bfd63          	bgeu	s7,s5,ffffffffc0204fb8 <do_execve+0x3f8>
            if (start == end)
ffffffffc0204f42:	db790fe3          	beq	s2,s7,ffffffffc0204d00 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204f46:	6785                	lui	a5,0x1
ffffffffc0204f48:	00fb8533          	add	a0,s7,a5
ffffffffc0204f4c:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0204f50:	41790a33          	sub	s4,s2,s7
            if (end < la)
ffffffffc0204f54:	0b597d63          	bgeu	s2,s5,ffffffffc020500e <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0204f58:	000cb683          	ld	a3,0(s9)
ffffffffc0204f5c:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204f5e:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204f62:	40d406b3          	sub	a3,s0,a3
ffffffffc0204f66:	8699                	srai	a3,a3,0x6
ffffffffc0204f68:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204f6a:	67e2                	ld	a5,24(sp)
ffffffffc0204f6c:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f70:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204f72:	0ac5f963          	bgeu	a1,a2,ffffffffc0205024 <do_execve+0x464>
ffffffffc0204f76:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204f7a:	8652                	mv	a2,s4
ffffffffc0204f7c:	4581                	li	a1,0
ffffffffc0204f7e:	96c2                	add	a3,a3,a6
ffffffffc0204f80:	9536                	add	a0,a0,a3
ffffffffc0204f82:	65c000ef          	jal	ra,ffffffffc02055de <memset>
            start += size;
ffffffffc0204f86:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204f8a:	03597463          	bgeu	s2,s5,ffffffffc0204fb2 <do_execve+0x3f2>
ffffffffc0204f8e:	d6e909e3          	beq	s2,a4,ffffffffc0204d00 <do_execve+0x140>
ffffffffc0204f92:	00002697          	auipc	a3,0x2
ffffffffc0204f96:	6be68693          	addi	a3,a3,1726 # ffffffffc0207650 <default_pmm_manager+0x288>
ffffffffc0204f9a:	00001617          	auipc	a2,0x1
ffffffffc0204f9e:	5b660613          	addi	a2,a2,1462 # ffffffffc0206550 <commands+0x898>
ffffffffc0204fa2:	2a500593          	li	a1,677
ffffffffc0204fa6:	00002517          	auipc	a0,0x2
ffffffffc0204faa:	4ba50513          	addi	a0,a0,1210 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0204fae:	a70fb0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0204fb2:	ff5710e3          	bne	a4,s5,ffffffffc0204f92 <do_execve+0x3d2>
ffffffffc0204fb6:	8bd6                	mv	s7,s5
        while (start < end)
ffffffffc0204fb8:	d52bf4e3          	bgeu	s7,s2,ffffffffc0204d00 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204fbc:	6c88                	ld	a0,24(s1)
ffffffffc0204fbe:	866a                	mv	a2,s10
ffffffffc0204fc0:	85d6                	mv	a1,s5
ffffffffc0204fc2:	867fd0ef          	jal	ra,ffffffffc0202828 <pgdir_alloc_page>
ffffffffc0204fc6:	842a                	mv	s0,a0
ffffffffc0204fc8:	dd05                	beqz	a0,ffffffffc0204f00 <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204fca:	6785                	lui	a5,0x1
ffffffffc0204fcc:	415b8533          	sub	a0,s7,s5
ffffffffc0204fd0:	9abe                	add	s5,s5,a5
ffffffffc0204fd2:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204fd6:	01597463          	bgeu	s2,s5,ffffffffc0204fde <do_execve+0x41e>
                size -= la - end;
ffffffffc0204fda:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0204fde:	000cb683          	ld	a3,0(s9)
ffffffffc0204fe2:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204fe4:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204fe8:	40d406b3          	sub	a3,s0,a3
ffffffffc0204fec:	8699                	srai	a3,a3,0x6
ffffffffc0204fee:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204ff0:	67e2                	ld	a5,24(sp)
ffffffffc0204ff2:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ff6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ff8:	02b87663          	bgeu	a6,a1,ffffffffc0205024 <do_execve+0x464>
ffffffffc0204ffc:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205000:	4581                	li	a1,0
            start += size;
ffffffffc0205002:	9bb2                	add	s7,s7,a2
ffffffffc0205004:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205006:	9536                	add	a0,a0,a3
ffffffffc0205008:	5d6000ef          	jal	ra,ffffffffc02055de <memset>
ffffffffc020500c:	b775                	j	ffffffffc0204fb8 <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc020500e:	417a8a33          	sub	s4,s5,s7
ffffffffc0205012:	b799                	j	ffffffffc0204f58 <do_execve+0x398>
        return -E_INVAL;
ffffffffc0205014:	5a75                	li	s4,-3
ffffffffc0205016:	b3c1                	j	ffffffffc0204dd6 <do_execve+0x216>
        while (start < end)
ffffffffc0205018:	86de                	mv	a3,s7
ffffffffc020501a:	bf39                	j	ffffffffc0204f38 <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc020501c:	5a71                	li	s4,-4
ffffffffc020501e:	bdc5                	j	ffffffffc0204f0e <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0205020:	5a61                	li	s4,-8
ffffffffc0205022:	b5c5                	j	ffffffffc0204f02 <do_execve+0x342>
ffffffffc0205024:	00001617          	auipc	a2,0x1
ffffffffc0205028:	4c460613          	addi	a2,a2,1220 # ffffffffc02064e8 <commands+0x830>
ffffffffc020502c:	07100593          	li	a1,113
ffffffffc0205030:	00001517          	auipc	a0,0x1
ffffffffc0205034:	48050513          	addi	a0,a0,1152 # ffffffffc02064b0 <commands+0x7f8>
ffffffffc0205038:	9e6fb0ef          	jal	ra,ffffffffc020021e <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc020503c:	00001617          	auipc	a2,0x1
ffffffffc0205040:	5bc60613          	addi	a2,a2,1468 # ffffffffc02065f8 <commands+0x940>
ffffffffc0205044:	2c400593          	li	a1,708
ffffffffc0205048:	00002517          	auipc	a0,0x2
ffffffffc020504c:	41850513          	addi	a0,a0,1048 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0205050:	9cefb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205054:	00002697          	auipc	a3,0x2
ffffffffc0205058:	71468693          	addi	a3,a3,1812 # ffffffffc0207768 <default_pmm_manager+0x3a0>
ffffffffc020505c:	00001617          	auipc	a2,0x1
ffffffffc0205060:	4f460613          	addi	a2,a2,1268 # ffffffffc0206550 <commands+0x898>
ffffffffc0205064:	2bf00593          	li	a1,703
ffffffffc0205068:	00002517          	auipc	a0,0x2
ffffffffc020506c:	3f850513          	addi	a0,a0,1016 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0205070:	9aefb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205074:	00002697          	auipc	a3,0x2
ffffffffc0205078:	6ac68693          	addi	a3,a3,1708 # ffffffffc0207720 <default_pmm_manager+0x358>
ffffffffc020507c:	00001617          	auipc	a2,0x1
ffffffffc0205080:	4d460613          	addi	a2,a2,1236 # ffffffffc0206550 <commands+0x898>
ffffffffc0205084:	2be00593          	li	a1,702
ffffffffc0205088:	00002517          	auipc	a0,0x2
ffffffffc020508c:	3d850513          	addi	a0,a0,984 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0205090:	98efb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205094:	00002697          	auipc	a3,0x2
ffffffffc0205098:	64468693          	addi	a3,a3,1604 # ffffffffc02076d8 <default_pmm_manager+0x310>
ffffffffc020509c:	00001617          	auipc	a2,0x1
ffffffffc02050a0:	4b460613          	addi	a2,a2,1204 # ffffffffc0206550 <commands+0x898>
ffffffffc02050a4:	2bd00593          	li	a1,701
ffffffffc02050a8:	00002517          	auipc	a0,0x2
ffffffffc02050ac:	3b850513          	addi	a0,a0,952 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc02050b0:	96efb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc02050b4:	00002697          	auipc	a3,0x2
ffffffffc02050b8:	5dc68693          	addi	a3,a3,1500 # ffffffffc0207690 <default_pmm_manager+0x2c8>
ffffffffc02050bc:	00001617          	auipc	a2,0x1
ffffffffc02050c0:	49460613          	addi	a2,a2,1172 # ffffffffc0206550 <commands+0x898>
ffffffffc02050c4:	2bc00593          	li	a1,700
ffffffffc02050c8:	00002517          	auipc	a0,0x2
ffffffffc02050cc:	39850513          	addi	a0,a0,920 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc02050d0:	94efb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02050d4 <do_yield>:
    current->need_resched = 1;
ffffffffc02050d4:	000b0797          	auipc	a5,0xb0
ffffffffc02050d8:	0347b783          	ld	a5,52(a5) # ffffffffc02b5108 <current>
ffffffffc02050dc:	4705                	li	a4,1
ffffffffc02050de:	ef98                	sd	a4,24(a5)
}
ffffffffc02050e0:	4501                	li	a0,0
ffffffffc02050e2:	8082                	ret

ffffffffc02050e4 <do_wait>:
{
ffffffffc02050e4:	1101                	addi	sp,sp,-32
ffffffffc02050e6:	e822                	sd	s0,16(sp)
ffffffffc02050e8:	e426                	sd	s1,8(sp)
ffffffffc02050ea:	ec06                	sd	ra,24(sp)
ffffffffc02050ec:	842e                	mv	s0,a1
ffffffffc02050ee:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc02050f0:	c999                	beqz	a1,ffffffffc0205106 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc02050f2:	000b0797          	auipc	a5,0xb0
ffffffffc02050f6:	0167b783          	ld	a5,22(a5) # ffffffffc02b5108 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc02050fa:	7788                	ld	a0,40(a5)
ffffffffc02050fc:	4685                	li	a3,1
ffffffffc02050fe:	4611                	li	a2,4
ffffffffc0205100:	8e6fe0ef          	jal	ra,ffffffffc02031e6 <user_mem_check>
ffffffffc0205104:	c909                	beqz	a0,ffffffffc0205116 <do_wait+0x32>
ffffffffc0205106:	85a2                	mv	a1,s0
}
ffffffffc0205108:	6442                	ld	s0,16(sp)
ffffffffc020510a:	60e2                	ld	ra,24(sp)
ffffffffc020510c:	8526                	mv	a0,s1
ffffffffc020510e:	64a2                	ld	s1,8(sp)
ffffffffc0205110:	6105                	addi	sp,sp,32
ffffffffc0205112:	fb8ff06f          	j	ffffffffc02048ca <do_wait.part.0>
ffffffffc0205116:	60e2                	ld	ra,24(sp)
ffffffffc0205118:	6442                	ld	s0,16(sp)
ffffffffc020511a:	64a2                	ld	s1,8(sp)
ffffffffc020511c:	5575                	li	a0,-3
ffffffffc020511e:	6105                	addi	sp,sp,32
ffffffffc0205120:	8082                	ret

ffffffffc0205122 <do_kill>:
{
ffffffffc0205122:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0205124:	6789                	lui	a5,0x2
{
ffffffffc0205126:	e406                	sd	ra,8(sp)
ffffffffc0205128:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc020512a:	fff5071b          	addiw	a4,a0,-1
ffffffffc020512e:	17f9                	addi	a5,a5,-2
ffffffffc0205130:	02e7e963          	bltu	a5,a4,ffffffffc0205162 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205134:	842a                	mv	s0,a0
ffffffffc0205136:	45a9                	li	a1,10
ffffffffc0205138:	2501                	sext.w	a0,a0
ffffffffc020513a:	0bd000ef          	jal	ra,ffffffffc02059f6 <hash32>
ffffffffc020513e:	02051793          	slli	a5,a0,0x20
ffffffffc0205142:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205146:	000ac797          	auipc	a5,0xac
ffffffffc020514a:	f4278793          	addi	a5,a5,-190 # ffffffffc02b1088 <hash_list>
ffffffffc020514e:	953e                	add	a0,a0,a5
ffffffffc0205150:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0205152:	a029                	j	ffffffffc020515c <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc0205154:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205158:	00870b63          	beq	a4,s0,ffffffffc020516e <do_kill+0x4c>
ffffffffc020515c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020515e:	fef51be3          	bne	a0,a5,ffffffffc0205154 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205162:	5475                	li	s0,-3
}
ffffffffc0205164:	60a2                	ld	ra,8(sp)
ffffffffc0205166:	8522                	mv	a0,s0
ffffffffc0205168:	6402                	ld	s0,0(sp)
ffffffffc020516a:	0141                	addi	sp,sp,16
ffffffffc020516c:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc020516e:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205172:	00177693          	andi	a3,a4,1
ffffffffc0205176:	e295                	bnez	a3,ffffffffc020519a <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205178:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc020517a:	00176713          	ori	a4,a4,1
ffffffffc020517e:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205182:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205184:	fe06d0e3          	bgez	a3,ffffffffc0205164 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205188:	f2878513          	addi	a0,a5,-216
ffffffffc020518c:	1c4000ef          	jal	ra,ffffffffc0205350 <wakeup_proc>
}
ffffffffc0205190:	60a2                	ld	ra,8(sp)
ffffffffc0205192:	8522                	mv	a0,s0
ffffffffc0205194:	6402                	ld	s0,0(sp)
ffffffffc0205196:	0141                	addi	sp,sp,16
ffffffffc0205198:	8082                	ret
        return -E_KILLED;
ffffffffc020519a:	545d                	li	s0,-9
ffffffffc020519c:	b7e1                	j	ffffffffc0205164 <do_kill+0x42>

ffffffffc020519e <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc020519e:	1101                	addi	sp,sp,-32
ffffffffc02051a0:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc02051a2:	000b0797          	auipc	a5,0xb0
ffffffffc02051a6:	ee678793          	addi	a5,a5,-282 # ffffffffc02b5088 <proc_list>
ffffffffc02051aa:	ec06                	sd	ra,24(sp)
ffffffffc02051ac:	e822                	sd	s0,16(sp)
ffffffffc02051ae:	e04a                	sd	s2,0(sp)
ffffffffc02051b0:	000ac497          	auipc	s1,0xac
ffffffffc02051b4:	ed848493          	addi	s1,s1,-296 # ffffffffc02b1088 <hash_list>
ffffffffc02051b8:	e79c                	sd	a5,8(a5)
ffffffffc02051ba:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc02051bc:	000b0717          	auipc	a4,0xb0
ffffffffc02051c0:	ecc70713          	addi	a4,a4,-308 # ffffffffc02b5088 <proc_list>
ffffffffc02051c4:	87a6                	mv	a5,s1
ffffffffc02051c6:	e79c                	sd	a5,8(a5)
ffffffffc02051c8:	e39c                	sd	a5,0(a5)
ffffffffc02051ca:	07c1                	addi	a5,a5,16
ffffffffc02051cc:	fef71de3          	bne	a4,a5,ffffffffc02051c6 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc02051d0:	fa7fe0ef          	jal	ra,ffffffffc0204176 <alloc_proc>
ffffffffc02051d4:	000b0917          	auipc	s2,0xb0
ffffffffc02051d8:	f3c90913          	addi	s2,s2,-196 # ffffffffc02b5110 <idleproc>
ffffffffc02051dc:	00a93023          	sd	a0,0(s2)
ffffffffc02051e0:	0e050f63          	beqz	a0,ffffffffc02052de <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02051e4:	4789                	li	a5,2
ffffffffc02051e6:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02051e8:	00003797          	auipc	a5,0x3
ffffffffc02051ec:	e1878793          	addi	a5,a5,-488 # ffffffffc0208000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02051f0:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02051f4:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc02051f6:	4785                	li	a5,1
ffffffffc02051f8:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02051fa:	4641                	li	a2,16
ffffffffc02051fc:	4581                	li	a1,0
ffffffffc02051fe:	8522                	mv	a0,s0
ffffffffc0205200:	3de000ef          	jal	ra,ffffffffc02055de <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205204:	463d                	li	a2,15
ffffffffc0205206:	00002597          	auipc	a1,0x2
ffffffffc020520a:	5c258593          	addi	a1,a1,1474 # ffffffffc02077c8 <default_pmm_manager+0x400>
ffffffffc020520e:	8522                	mv	a0,s0
ffffffffc0205210:	3e0000ef          	jal	ra,ffffffffc02055f0 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0205214:	000b0717          	auipc	a4,0xb0
ffffffffc0205218:	f0c70713          	addi	a4,a4,-244 # ffffffffc02b5120 <nr_process>
ffffffffc020521c:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc020521e:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205222:	4601                	li	a2,0
    nr_process++;
ffffffffc0205224:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205226:	4581                	li	a1,0
ffffffffc0205228:	00000517          	auipc	a0,0x0
ffffffffc020522c:	87450513          	addi	a0,a0,-1932 # ffffffffc0204a9c <init_main>
    nr_process++;
ffffffffc0205230:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205232:	000b0797          	auipc	a5,0xb0
ffffffffc0205236:	ecd7bb23          	sd	a3,-298(a5) # ffffffffc02b5108 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020523a:	cf6ff0ef          	jal	ra,ffffffffc0204730 <kernel_thread>
ffffffffc020523e:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0205240:	08a05363          	blez	a0,ffffffffc02052c6 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc0205244:	6789                	lui	a5,0x2
ffffffffc0205246:	fff5071b          	addiw	a4,a0,-1
ffffffffc020524a:	17f9                	addi	a5,a5,-2
ffffffffc020524c:	2501                	sext.w	a0,a0
ffffffffc020524e:	02e7e363          	bltu	a5,a4,ffffffffc0205274 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205252:	45a9                	li	a1,10
ffffffffc0205254:	7a2000ef          	jal	ra,ffffffffc02059f6 <hash32>
ffffffffc0205258:	02051793          	slli	a5,a0,0x20
ffffffffc020525c:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205260:	96a6                	add	a3,a3,s1
ffffffffc0205262:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0205264:	a029                	j	ffffffffc020526e <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc0205266:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c8c>
ffffffffc020526a:	04870b63          	beq	a4,s0,ffffffffc02052c0 <proc_init+0x122>
    return listelm->next;
ffffffffc020526e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205270:	fef69be3          	bne	a3,a5,ffffffffc0205266 <proc_init+0xc8>
    return NULL;
ffffffffc0205274:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205276:	0b478493          	addi	s1,a5,180
ffffffffc020527a:	4641                	li	a2,16
ffffffffc020527c:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc020527e:	000b0417          	auipc	s0,0xb0
ffffffffc0205282:	e9a40413          	addi	s0,s0,-358 # ffffffffc02b5118 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205286:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205288:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020528a:	354000ef          	jal	ra,ffffffffc02055de <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020528e:	463d                	li	a2,15
ffffffffc0205290:	00002597          	auipc	a1,0x2
ffffffffc0205294:	56058593          	addi	a1,a1,1376 # ffffffffc02077f0 <default_pmm_manager+0x428>
ffffffffc0205298:	8526                	mv	a0,s1
ffffffffc020529a:	356000ef          	jal	ra,ffffffffc02055f0 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020529e:	00093783          	ld	a5,0(s2)
ffffffffc02052a2:	cbb5                	beqz	a5,ffffffffc0205316 <proc_init+0x178>
ffffffffc02052a4:	43dc                	lw	a5,4(a5)
ffffffffc02052a6:	eba5                	bnez	a5,ffffffffc0205316 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02052a8:	601c                	ld	a5,0(s0)
ffffffffc02052aa:	c7b1                	beqz	a5,ffffffffc02052f6 <proc_init+0x158>
ffffffffc02052ac:	43d8                	lw	a4,4(a5)
ffffffffc02052ae:	4785                	li	a5,1
ffffffffc02052b0:	04f71363          	bne	a4,a5,ffffffffc02052f6 <proc_init+0x158>
}
ffffffffc02052b4:	60e2                	ld	ra,24(sp)
ffffffffc02052b6:	6442                	ld	s0,16(sp)
ffffffffc02052b8:	64a2                	ld	s1,8(sp)
ffffffffc02052ba:	6902                	ld	s2,0(sp)
ffffffffc02052bc:	6105                	addi	sp,sp,32
ffffffffc02052be:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02052c0:	f2878793          	addi	a5,a5,-216
ffffffffc02052c4:	bf4d                	j	ffffffffc0205276 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc02052c6:	00002617          	auipc	a2,0x2
ffffffffc02052ca:	50a60613          	addi	a2,a2,1290 # ffffffffc02077d0 <default_pmm_manager+0x408>
ffffffffc02052ce:	3e600593          	li	a1,998
ffffffffc02052d2:	00002517          	auipc	a0,0x2
ffffffffc02052d6:	18e50513          	addi	a0,a0,398 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc02052da:	f45fa0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02052de:	00002617          	auipc	a2,0x2
ffffffffc02052e2:	4d260613          	addi	a2,a2,1234 # ffffffffc02077b0 <default_pmm_manager+0x3e8>
ffffffffc02052e6:	3d700593          	li	a1,983
ffffffffc02052ea:	00002517          	auipc	a0,0x2
ffffffffc02052ee:	17650513          	addi	a0,a0,374 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc02052f2:	f2dfa0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02052f6:	00002697          	auipc	a3,0x2
ffffffffc02052fa:	52a68693          	addi	a3,a3,1322 # ffffffffc0207820 <default_pmm_manager+0x458>
ffffffffc02052fe:	00001617          	auipc	a2,0x1
ffffffffc0205302:	25260613          	addi	a2,a2,594 # ffffffffc0206550 <commands+0x898>
ffffffffc0205306:	3ed00593          	li	a1,1005
ffffffffc020530a:	00002517          	auipc	a0,0x2
ffffffffc020530e:	15650513          	addi	a0,a0,342 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0205312:	f0dfa0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205316:	00002697          	auipc	a3,0x2
ffffffffc020531a:	4e268693          	addi	a3,a3,1250 # ffffffffc02077f8 <default_pmm_manager+0x430>
ffffffffc020531e:	00001617          	auipc	a2,0x1
ffffffffc0205322:	23260613          	addi	a2,a2,562 # ffffffffc0206550 <commands+0x898>
ffffffffc0205326:	3ec00593          	li	a1,1004
ffffffffc020532a:	00002517          	auipc	a0,0x2
ffffffffc020532e:	13650513          	addi	a0,a0,310 # ffffffffc0207460 <default_pmm_manager+0x98>
ffffffffc0205332:	eedfa0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0205336 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0205336:	1141                	addi	sp,sp,-16
ffffffffc0205338:	e022                	sd	s0,0(sp)
ffffffffc020533a:	e406                	sd	ra,8(sp)
ffffffffc020533c:	000b0417          	auipc	s0,0xb0
ffffffffc0205340:	dcc40413          	addi	s0,s0,-564 # ffffffffc02b5108 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205344:	6018                	ld	a4,0(s0)
ffffffffc0205346:	6f1c                	ld	a5,24(a4)
ffffffffc0205348:	dffd                	beqz	a5,ffffffffc0205346 <cpu_idle+0x10>
        {
            schedule();
ffffffffc020534a:	086000ef          	jal	ra,ffffffffc02053d0 <schedule>
ffffffffc020534e:	bfdd                	j	ffffffffc0205344 <cpu_idle+0xe>

ffffffffc0205350 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205350:	4118                	lw	a4,0(a0)
{
ffffffffc0205352:	1101                	addi	sp,sp,-32
ffffffffc0205354:	ec06                	sd	ra,24(sp)
ffffffffc0205356:	e822                	sd	s0,16(sp)
ffffffffc0205358:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020535a:	478d                	li	a5,3
ffffffffc020535c:	04f70b63          	beq	a4,a5,ffffffffc02053b2 <wakeup_proc+0x62>
ffffffffc0205360:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205362:	100027f3          	csrr	a5,sstatus
ffffffffc0205366:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205368:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020536a:	ef9d                	bnez	a5,ffffffffc02053a8 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc020536c:	4789                	li	a5,2
ffffffffc020536e:	02f70163          	beq	a4,a5,ffffffffc0205390 <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc0205372:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205374:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc0205378:	e491                	bnez	s1,ffffffffc0205384 <wakeup_proc+0x34>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020537a:	60e2                	ld	ra,24(sp)
ffffffffc020537c:	6442                	ld	s0,16(sp)
ffffffffc020537e:	64a2                	ld	s1,8(sp)
ffffffffc0205380:	6105                	addi	sp,sp,32
ffffffffc0205382:	8082                	ret
ffffffffc0205384:	6442                	ld	s0,16(sp)
ffffffffc0205386:	60e2                	ld	ra,24(sp)
ffffffffc0205388:	64a2                	ld	s1,8(sp)
ffffffffc020538a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020538c:	e28fb06f          	j	ffffffffc02009b4 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205390:	00002617          	auipc	a2,0x2
ffffffffc0205394:	4f060613          	addi	a2,a2,1264 # ffffffffc0207880 <default_pmm_manager+0x4b8>
ffffffffc0205398:	45d1                	li	a1,20
ffffffffc020539a:	00002517          	auipc	a0,0x2
ffffffffc020539e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0207868 <default_pmm_manager+0x4a0>
ffffffffc02053a2:	ee5fa0ef          	jal	ra,ffffffffc0200286 <__warn>
ffffffffc02053a6:	bfc9                	j	ffffffffc0205378 <wakeup_proc+0x28>
        intr_disable();
ffffffffc02053a8:	e12fb0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc02053ac:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc02053ae:	4485                	li	s1,1
ffffffffc02053b0:	bf75                	j	ffffffffc020536c <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02053b2:	00002697          	auipc	a3,0x2
ffffffffc02053b6:	49668693          	addi	a3,a3,1174 # ffffffffc0207848 <default_pmm_manager+0x480>
ffffffffc02053ba:	00001617          	auipc	a2,0x1
ffffffffc02053be:	19660613          	addi	a2,a2,406 # ffffffffc0206550 <commands+0x898>
ffffffffc02053c2:	45a5                	li	a1,9
ffffffffc02053c4:	00002517          	auipc	a0,0x2
ffffffffc02053c8:	4a450513          	addi	a0,a0,1188 # ffffffffc0207868 <default_pmm_manager+0x4a0>
ffffffffc02053cc:	e53fa0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02053d0 <schedule>:

void schedule(void)
{
ffffffffc02053d0:	1141                	addi	sp,sp,-16
ffffffffc02053d2:	e406                	sd	ra,8(sp)
ffffffffc02053d4:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02053d6:	100027f3          	csrr	a5,sstatus
ffffffffc02053da:	8b89                	andi	a5,a5,2
ffffffffc02053dc:	4401                	li	s0,0
ffffffffc02053de:	efbd                	bnez	a5,ffffffffc020545c <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02053e0:	000b0897          	auipc	a7,0xb0
ffffffffc02053e4:	d288b883          	ld	a7,-728(a7) # ffffffffc02b5108 <current>
ffffffffc02053e8:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02053ec:	000b0517          	auipc	a0,0xb0
ffffffffc02053f0:	d2453503          	ld	a0,-732(a0) # ffffffffc02b5110 <idleproc>
ffffffffc02053f4:	04a88e63          	beq	a7,a0,ffffffffc0205450 <schedule+0x80>
ffffffffc02053f8:	0c888693          	addi	a3,a7,200
ffffffffc02053fc:	000b0617          	auipc	a2,0xb0
ffffffffc0205400:	c8c60613          	addi	a2,a2,-884 # ffffffffc02b5088 <proc_list>
        le = last;
ffffffffc0205404:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205406:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc0205408:	4809                	li	a6,2
ffffffffc020540a:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc020540c:	00c78863          	beq	a5,a2,ffffffffc020541c <schedule+0x4c>
                if (next->state == PROC_RUNNABLE)
ffffffffc0205410:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205414:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc0205418:	03070163          	beq	a4,a6,ffffffffc020543a <schedule+0x6a>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc020541c:	fef697e3          	bne	a3,a5,ffffffffc020540a <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205420:	ed89                	bnez	a1,ffffffffc020543a <schedule+0x6a>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc0205422:	451c                	lw	a5,8(a0)
ffffffffc0205424:	2785                	addiw	a5,a5,1
ffffffffc0205426:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc0205428:	00a88463          	beq	a7,a0,ffffffffc0205430 <schedule+0x60>
        {
            proc_run(next);
ffffffffc020542c:	ebffe0ef          	jal	ra,ffffffffc02042ea <proc_run>
    if (flag)
ffffffffc0205430:	e819                	bnez	s0,ffffffffc0205446 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205432:	60a2                	ld	ra,8(sp)
ffffffffc0205434:	6402                	ld	s0,0(sp)
ffffffffc0205436:	0141                	addi	sp,sp,16
ffffffffc0205438:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc020543a:	4198                	lw	a4,0(a1)
ffffffffc020543c:	4789                	li	a5,2
ffffffffc020543e:	fef712e3          	bne	a4,a5,ffffffffc0205422 <schedule+0x52>
ffffffffc0205442:	852e                	mv	a0,a1
ffffffffc0205444:	bff9                	j	ffffffffc0205422 <schedule+0x52>
}
ffffffffc0205446:	6402                	ld	s0,0(sp)
ffffffffc0205448:	60a2                	ld	ra,8(sp)
ffffffffc020544a:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020544c:	d68fb06f          	j	ffffffffc02009b4 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205450:	000b0617          	auipc	a2,0xb0
ffffffffc0205454:	c3860613          	addi	a2,a2,-968 # ffffffffc02b5088 <proc_list>
ffffffffc0205458:	86b2                	mv	a3,a2
ffffffffc020545a:	b76d                	j	ffffffffc0205404 <schedule+0x34>
        intr_disable();
ffffffffc020545c:	d5efb0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc0205460:	4405                	li	s0,1
ffffffffc0205462:	bfbd                	j	ffffffffc02053e0 <schedule+0x10>

ffffffffc0205464 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205464:	000b0797          	auipc	a5,0xb0
ffffffffc0205468:	ca47b783          	ld	a5,-860(a5) # ffffffffc02b5108 <current>
}
ffffffffc020546c:	43c8                	lw	a0,4(a5)
ffffffffc020546e:	8082                	ret

ffffffffc0205470 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205470:	4501                	li	a0,0
ffffffffc0205472:	8082                	ret

ffffffffc0205474 <sys_putc>:
    cputchar(c);
ffffffffc0205474:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205476:	1141                	addi	sp,sp,-16
ffffffffc0205478:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020547a:	c9dfa0ef          	jal	ra,ffffffffc0200116 <cputchar>
}
ffffffffc020547e:	60a2                	ld	ra,8(sp)
ffffffffc0205480:	4501                	li	a0,0
ffffffffc0205482:	0141                	addi	sp,sp,16
ffffffffc0205484:	8082                	ret

ffffffffc0205486 <sys_kill>:
    return do_kill(pid);
ffffffffc0205486:	4108                	lw	a0,0(a0)
ffffffffc0205488:	c9bff06f          	j	ffffffffc0205122 <do_kill>

ffffffffc020548c <sys_yield>:
    return do_yield();
ffffffffc020548c:	c49ff06f          	j	ffffffffc02050d4 <do_yield>

ffffffffc0205490 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205490:	6d14                	ld	a3,24(a0)
ffffffffc0205492:	6910                	ld	a2,16(a0)
ffffffffc0205494:	650c                	ld	a1,8(a0)
ffffffffc0205496:	6108                	ld	a0,0(a0)
ffffffffc0205498:	f28ff06f          	j	ffffffffc0204bc0 <do_execve>

ffffffffc020549c <sys_wait>:
    return do_wait(pid, store);
ffffffffc020549c:	650c                	ld	a1,8(a0)
ffffffffc020549e:	4108                	lw	a0,0(a0)
ffffffffc02054a0:	c45ff06f          	j	ffffffffc02050e4 <do_wait>

ffffffffc02054a4 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc02054a4:	000b0797          	auipc	a5,0xb0
ffffffffc02054a8:	c647b783          	ld	a5,-924(a5) # ffffffffc02b5108 <current>
ffffffffc02054ac:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02054ae:	4501                	li	a0,0
ffffffffc02054b0:	6a0c                	ld	a1,16(a2)
ffffffffc02054b2:	ea5fe06f          	j	ffffffffc0204356 <do_fork>

ffffffffc02054b6 <sys_exit>:
    return do_exit(error_code);
ffffffffc02054b6:	4108                	lw	a0,0(a0)
ffffffffc02054b8:	ac8ff06f          	j	ffffffffc0204780 <do_exit>

ffffffffc02054bc <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02054bc:	715d                	addi	sp,sp,-80
ffffffffc02054be:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02054c0:	000b0497          	auipc	s1,0xb0
ffffffffc02054c4:	c4848493          	addi	s1,s1,-952 # ffffffffc02b5108 <current>
ffffffffc02054c8:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02054ca:	e0a2                	sd	s0,64(sp)
ffffffffc02054cc:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02054ce:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02054d0:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02054d2:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02054d4:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02054d8:	0327ee63          	bltu	a5,s2,ffffffffc0205514 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02054dc:	00391713          	slli	a4,s2,0x3
ffffffffc02054e0:	00002797          	auipc	a5,0x2
ffffffffc02054e4:	40878793          	addi	a5,a5,1032 # ffffffffc02078e8 <syscalls>
ffffffffc02054e8:	97ba                	add	a5,a5,a4
ffffffffc02054ea:	639c                	ld	a5,0(a5)
ffffffffc02054ec:	c785                	beqz	a5,ffffffffc0205514 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02054ee:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02054f0:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02054f2:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02054f4:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02054f6:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02054f8:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02054fa:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02054fc:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02054fe:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205500:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205502:	0028                	addi	a0,sp,8
ffffffffc0205504:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205506:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205508:	e828                	sd	a0,80(s0)
}
ffffffffc020550a:	6406                	ld	s0,64(sp)
ffffffffc020550c:	74e2                	ld	s1,56(sp)
ffffffffc020550e:	7942                	ld	s2,48(sp)
ffffffffc0205510:	6161                	addi	sp,sp,80
ffffffffc0205512:	8082                	ret
    print_trapframe(tf);
ffffffffc0205514:	8522                	mv	a0,s0
ffffffffc0205516:	e92fb0ef          	jal	ra,ffffffffc0200ba8 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020551a:	609c                	ld	a5,0(s1)
ffffffffc020551c:	86ca                	mv	a3,s2
ffffffffc020551e:	00002617          	auipc	a2,0x2
ffffffffc0205522:	38260613          	addi	a2,a2,898 # ffffffffc02078a0 <default_pmm_manager+0x4d8>
ffffffffc0205526:	43d8                	lw	a4,4(a5)
ffffffffc0205528:	06200593          	li	a1,98
ffffffffc020552c:	0b478793          	addi	a5,a5,180
ffffffffc0205530:	00002517          	auipc	a0,0x2
ffffffffc0205534:	3a050513          	addi	a0,a0,928 # ffffffffc02078d0 <default_pmm_manager+0x508>
ffffffffc0205538:	ce7fa0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020553c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020553c:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205540:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205542:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205544:	cb81                	beqz	a5,ffffffffc0205554 <strlen+0x18>
        cnt ++;
ffffffffc0205546:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205548:	00a707b3          	add	a5,a4,a0
ffffffffc020554c:	0007c783          	lbu	a5,0(a5)
ffffffffc0205550:	fbfd                	bnez	a5,ffffffffc0205546 <strlen+0xa>
ffffffffc0205552:	8082                	ret
    }
    return cnt;
}
ffffffffc0205554:	8082                	ret

ffffffffc0205556 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205556:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205558:	e589                	bnez	a1,ffffffffc0205562 <strnlen+0xc>
ffffffffc020555a:	a811                	j	ffffffffc020556e <strnlen+0x18>
        cnt ++;
ffffffffc020555c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020555e:	00f58863          	beq	a1,a5,ffffffffc020556e <strnlen+0x18>
ffffffffc0205562:	00f50733          	add	a4,a0,a5
ffffffffc0205566:	00074703          	lbu	a4,0(a4)
ffffffffc020556a:	fb6d                	bnez	a4,ffffffffc020555c <strnlen+0x6>
ffffffffc020556c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020556e:	852e                	mv	a0,a1
ffffffffc0205570:	8082                	ret

ffffffffc0205572 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205572:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205574:	0005c703          	lbu	a4,0(a1)
ffffffffc0205578:	0785                	addi	a5,a5,1
ffffffffc020557a:	0585                	addi	a1,a1,1
ffffffffc020557c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205580:	fb75                	bnez	a4,ffffffffc0205574 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205582:	8082                	ret

ffffffffc0205584 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205584:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205588:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020558c:	cb89                	beqz	a5,ffffffffc020559e <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020558e:	0505                	addi	a0,a0,1
ffffffffc0205590:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205592:	fee789e3          	beq	a5,a4,ffffffffc0205584 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205596:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020559a:	9d19                	subw	a0,a0,a4
ffffffffc020559c:	8082                	ret
ffffffffc020559e:	4501                	li	a0,0
ffffffffc02055a0:	bfed                	j	ffffffffc020559a <strcmp+0x16>

ffffffffc02055a2 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02055a2:	c20d                	beqz	a2,ffffffffc02055c4 <strncmp+0x22>
ffffffffc02055a4:	962e                	add	a2,a2,a1
ffffffffc02055a6:	a031                	j	ffffffffc02055b2 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc02055a8:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02055aa:	00e79a63          	bne	a5,a4,ffffffffc02055be <strncmp+0x1c>
ffffffffc02055ae:	00b60b63          	beq	a2,a1,ffffffffc02055c4 <strncmp+0x22>
ffffffffc02055b2:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02055b6:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02055b8:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02055bc:	f7f5                	bnez	a5,ffffffffc02055a8 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02055be:	40e7853b          	subw	a0,a5,a4
}
ffffffffc02055c2:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02055c4:	4501                	li	a0,0
ffffffffc02055c6:	8082                	ret

ffffffffc02055c8 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02055c8:	00054783          	lbu	a5,0(a0)
ffffffffc02055cc:	c799                	beqz	a5,ffffffffc02055da <strchr+0x12>
        if (*s == c) {
ffffffffc02055ce:	00f58763          	beq	a1,a5,ffffffffc02055dc <strchr+0x14>
    while (*s != '\0') {
ffffffffc02055d2:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02055d6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02055d8:	fbfd                	bnez	a5,ffffffffc02055ce <strchr+0x6>
    }
    return NULL;
ffffffffc02055da:	4501                	li	a0,0
}
ffffffffc02055dc:	8082                	ret

ffffffffc02055de <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02055de:	ca01                	beqz	a2,ffffffffc02055ee <memset+0x10>
ffffffffc02055e0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02055e2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02055e4:	0785                	addi	a5,a5,1
ffffffffc02055e6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02055ea:	fec79de3          	bne	a5,a2,ffffffffc02055e4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02055ee:	8082                	ret

ffffffffc02055f0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02055f0:	ca19                	beqz	a2,ffffffffc0205606 <memcpy+0x16>
ffffffffc02055f2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02055f4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02055f6:	0005c703          	lbu	a4,0(a1)
ffffffffc02055fa:	0585                	addi	a1,a1,1
ffffffffc02055fc:	0785                	addi	a5,a5,1
ffffffffc02055fe:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205602:	fec59ae3          	bne	a1,a2,ffffffffc02055f6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205606:	8082                	ret

ffffffffc0205608 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205608:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020560c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020560e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205612:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205614:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205618:	f022                	sd	s0,32(sp)
ffffffffc020561a:	ec26                	sd	s1,24(sp)
ffffffffc020561c:	e84a                	sd	s2,16(sp)
ffffffffc020561e:	f406                	sd	ra,40(sp)
ffffffffc0205620:	e44e                	sd	s3,8(sp)
ffffffffc0205622:	84aa                	mv	s1,a0
ffffffffc0205624:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205626:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020562a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020562c:	03067e63          	bgeu	a2,a6,ffffffffc0205668 <printnum+0x60>
ffffffffc0205630:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0205632:	00805763          	blez	s0,ffffffffc0205640 <printnum+0x38>
ffffffffc0205636:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205638:	85ca                	mv	a1,s2
ffffffffc020563a:	854e                	mv	a0,s3
ffffffffc020563c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020563e:	fc65                	bnez	s0,ffffffffc0205636 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205640:	1a02                	slli	s4,s4,0x20
ffffffffc0205642:	00002797          	auipc	a5,0x2
ffffffffc0205646:	3a678793          	addi	a5,a5,934 # ffffffffc02079e8 <syscalls+0x100>
ffffffffc020564a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020564e:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205650:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205652:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0205656:	70a2                	ld	ra,40(sp)
ffffffffc0205658:	69a2                	ld	s3,8(sp)
ffffffffc020565a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020565c:	85ca                	mv	a1,s2
ffffffffc020565e:	87a6                	mv	a5,s1
}
ffffffffc0205660:	6942                	ld	s2,16(sp)
ffffffffc0205662:	64e2                	ld	s1,24(sp)
ffffffffc0205664:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205666:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0205668:	03065633          	divu	a2,a2,a6
ffffffffc020566c:	8722                	mv	a4,s0
ffffffffc020566e:	f9bff0ef          	jal	ra,ffffffffc0205608 <printnum>
ffffffffc0205672:	b7f9                	j	ffffffffc0205640 <printnum+0x38>

ffffffffc0205674 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0205674:	7119                	addi	sp,sp,-128
ffffffffc0205676:	f4a6                	sd	s1,104(sp)
ffffffffc0205678:	f0ca                	sd	s2,96(sp)
ffffffffc020567a:	ecce                	sd	s3,88(sp)
ffffffffc020567c:	e8d2                	sd	s4,80(sp)
ffffffffc020567e:	e4d6                	sd	s5,72(sp)
ffffffffc0205680:	e0da                	sd	s6,64(sp)
ffffffffc0205682:	fc5e                	sd	s7,56(sp)
ffffffffc0205684:	f06a                	sd	s10,32(sp)
ffffffffc0205686:	fc86                	sd	ra,120(sp)
ffffffffc0205688:	f8a2                	sd	s0,112(sp)
ffffffffc020568a:	f862                	sd	s8,48(sp)
ffffffffc020568c:	f466                	sd	s9,40(sp)
ffffffffc020568e:	ec6e                	sd	s11,24(sp)
ffffffffc0205690:	892a                	mv	s2,a0
ffffffffc0205692:	84ae                	mv	s1,a1
ffffffffc0205694:	8d32                	mv	s10,a2
ffffffffc0205696:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205698:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020569c:	5b7d                	li	s6,-1
ffffffffc020569e:	00002a97          	auipc	s5,0x2
ffffffffc02056a2:	376a8a93          	addi	s5,s5,886 # ffffffffc0207a14 <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02056a6:	00002b97          	auipc	s7,0x2
ffffffffc02056aa:	58ab8b93          	addi	s7,s7,1418 # ffffffffc0207c30 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02056ae:	000d4503          	lbu	a0,0(s10)
ffffffffc02056b2:	001d0413          	addi	s0,s10,1
ffffffffc02056b6:	01350a63          	beq	a0,s3,ffffffffc02056ca <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02056ba:	c121                	beqz	a0,ffffffffc02056fa <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02056bc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02056be:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02056c0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02056c2:	fff44503          	lbu	a0,-1(s0)
ffffffffc02056c6:	ff351ae3          	bne	a0,s3,ffffffffc02056ba <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056ca:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02056ce:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02056d2:	4c81                	li	s9,0
ffffffffc02056d4:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02056d6:	5c7d                	li	s8,-1
ffffffffc02056d8:	5dfd                	li	s11,-1
ffffffffc02056da:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02056de:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056e0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02056e4:	0ff5f593          	zext.b	a1,a1
ffffffffc02056e8:	00140d13          	addi	s10,s0,1
ffffffffc02056ec:	04b56263          	bltu	a0,a1,ffffffffc0205730 <vprintfmt+0xbc>
ffffffffc02056f0:	058a                	slli	a1,a1,0x2
ffffffffc02056f2:	95d6                	add	a1,a1,s5
ffffffffc02056f4:	4194                	lw	a3,0(a1)
ffffffffc02056f6:	96d6                	add	a3,a3,s5
ffffffffc02056f8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02056fa:	70e6                	ld	ra,120(sp)
ffffffffc02056fc:	7446                	ld	s0,112(sp)
ffffffffc02056fe:	74a6                	ld	s1,104(sp)
ffffffffc0205700:	7906                	ld	s2,96(sp)
ffffffffc0205702:	69e6                	ld	s3,88(sp)
ffffffffc0205704:	6a46                	ld	s4,80(sp)
ffffffffc0205706:	6aa6                	ld	s5,72(sp)
ffffffffc0205708:	6b06                	ld	s6,64(sp)
ffffffffc020570a:	7be2                	ld	s7,56(sp)
ffffffffc020570c:	7c42                	ld	s8,48(sp)
ffffffffc020570e:	7ca2                	ld	s9,40(sp)
ffffffffc0205710:	7d02                	ld	s10,32(sp)
ffffffffc0205712:	6de2                	ld	s11,24(sp)
ffffffffc0205714:	6109                	addi	sp,sp,128
ffffffffc0205716:	8082                	ret
            padc = '0';
ffffffffc0205718:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020571a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020571e:	846a                	mv	s0,s10
ffffffffc0205720:	00140d13          	addi	s10,s0,1
ffffffffc0205724:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0205728:	0ff5f593          	zext.b	a1,a1
ffffffffc020572c:	fcb572e3          	bgeu	a0,a1,ffffffffc02056f0 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0205730:	85a6                	mv	a1,s1
ffffffffc0205732:	02500513          	li	a0,37
ffffffffc0205736:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0205738:	fff44783          	lbu	a5,-1(s0)
ffffffffc020573c:	8d22                	mv	s10,s0
ffffffffc020573e:	f73788e3          	beq	a5,s3,ffffffffc02056ae <vprintfmt+0x3a>
ffffffffc0205742:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0205746:	1d7d                	addi	s10,s10,-1
ffffffffc0205748:	ff379de3          	bne	a5,s3,ffffffffc0205742 <vprintfmt+0xce>
ffffffffc020574c:	b78d                	j	ffffffffc02056ae <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020574e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0205752:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205756:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0205758:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020575c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205760:	02d86463          	bltu	a6,a3,ffffffffc0205788 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0205764:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0205768:	002c169b          	slliw	a3,s8,0x2
ffffffffc020576c:	0186873b          	addw	a4,a3,s8
ffffffffc0205770:	0017171b          	slliw	a4,a4,0x1
ffffffffc0205774:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0205776:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020577a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020577c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0205780:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205784:	fed870e3          	bgeu	a6,a3,ffffffffc0205764 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0205788:	f40ddce3          	bgez	s11,ffffffffc02056e0 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020578c:	8de2                	mv	s11,s8
ffffffffc020578e:	5c7d                	li	s8,-1
ffffffffc0205790:	bf81                	j	ffffffffc02056e0 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0205792:	fffdc693          	not	a3,s11
ffffffffc0205796:	96fd                	srai	a3,a3,0x3f
ffffffffc0205798:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020579c:	00144603          	lbu	a2,1(s0)
ffffffffc02057a0:	2d81                	sext.w	s11,s11
ffffffffc02057a2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02057a4:	bf35                	j	ffffffffc02056e0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02057a6:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057aa:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02057ae:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057b0:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02057b2:	bfd9                	j	ffffffffc0205788 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02057b4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057b6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02057ba:	01174463          	blt	a4,a7,ffffffffc02057c2 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02057be:	1a088e63          	beqz	a7,ffffffffc020597a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02057c2:	000a3603          	ld	a2,0(s4)
ffffffffc02057c6:	46c1                	li	a3,16
ffffffffc02057c8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02057ca:	2781                	sext.w	a5,a5
ffffffffc02057cc:	876e                	mv	a4,s11
ffffffffc02057ce:	85a6                	mv	a1,s1
ffffffffc02057d0:	854a                	mv	a0,s2
ffffffffc02057d2:	e37ff0ef          	jal	ra,ffffffffc0205608 <printnum>
            break;
ffffffffc02057d6:	bde1                	j	ffffffffc02056ae <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02057d8:	000a2503          	lw	a0,0(s4)
ffffffffc02057dc:	85a6                	mv	a1,s1
ffffffffc02057de:	0a21                	addi	s4,s4,8
ffffffffc02057e0:	9902                	jalr	s2
            break;
ffffffffc02057e2:	b5f1                	j	ffffffffc02056ae <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02057e4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057e6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02057ea:	01174463          	blt	a4,a7,ffffffffc02057f2 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02057ee:	18088163          	beqz	a7,ffffffffc0205970 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02057f2:	000a3603          	ld	a2,0(s4)
ffffffffc02057f6:	46a9                	li	a3,10
ffffffffc02057f8:	8a2e                	mv	s4,a1
ffffffffc02057fa:	bfc1                	j	ffffffffc02057ca <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057fc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0205800:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205802:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205804:	bdf1                	j	ffffffffc02056e0 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0205806:	85a6                	mv	a1,s1
ffffffffc0205808:	02500513          	li	a0,37
ffffffffc020580c:	9902                	jalr	s2
            break;
ffffffffc020580e:	b545                	j	ffffffffc02056ae <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205810:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0205814:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205816:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205818:	b5e1                	j	ffffffffc02056e0 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020581a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020581c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205820:	01174463          	blt	a4,a7,ffffffffc0205828 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0205824:	14088163          	beqz	a7,ffffffffc0205966 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0205828:	000a3603          	ld	a2,0(s4)
ffffffffc020582c:	46a1                	li	a3,8
ffffffffc020582e:	8a2e                	mv	s4,a1
ffffffffc0205830:	bf69                	j	ffffffffc02057ca <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0205832:	03000513          	li	a0,48
ffffffffc0205836:	85a6                	mv	a1,s1
ffffffffc0205838:	e03e                	sd	a5,0(sp)
ffffffffc020583a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020583c:	85a6                	mv	a1,s1
ffffffffc020583e:	07800513          	li	a0,120
ffffffffc0205842:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205844:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0205846:	6782                	ld	a5,0(sp)
ffffffffc0205848:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020584a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020584e:	bfb5                	j	ffffffffc02057ca <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205850:	000a3403          	ld	s0,0(s4)
ffffffffc0205854:	008a0713          	addi	a4,s4,8
ffffffffc0205858:	e03a                	sd	a4,0(sp)
ffffffffc020585a:	14040263          	beqz	s0,ffffffffc020599e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020585e:	0fb05763          	blez	s11,ffffffffc020594c <vprintfmt+0x2d8>
ffffffffc0205862:	02d00693          	li	a3,45
ffffffffc0205866:	0cd79163          	bne	a5,a3,ffffffffc0205928 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020586a:	00044783          	lbu	a5,0(s0)
ffffffffc020586e:	0007851b          	sext.w	a0,a5
ffffffffc0205872:	cf85                	beqz	a5,ffffffffc02058aa <vprintfmt+0x236>
ffffffffc0205874:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205878:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020587c:	000c4563          	bltz	s8,ffffffffc0205886 <vprintfmt+0x212>
ffffffffc0205880:	3c7d                	addiw	s8,s8,-1
ffffffffc0205882:	036c0263          	beq	s8,s6,ffffffffc02058a6 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0205886:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205888:	0e0c8e63          	beqz	s9,ffffffffc0205984 <vprintfmt+0x310>
ffffffffc020588c:	3781                	addiw	a5,a5,-32
ffffffffc020588e:	0ef47b63          	bgeu	s0,a5,ffffffffc0205984 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0205892:	03f00513          	li	a0,63
ffffffffc0205896:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205898:	000a4783          	lbu	a5,0(s4)
ffffffffc020589c:	3dfd                	addiw	s11,s11,-1
ffffffffc020589e:	0a05                	addi	s4,s4,1
ffffffffc02058a0:	0007851b          	sext.w	a0,a5
ffffffffc02058a4:	ffe1                	bnez	a5,ffffffffc020587c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02058a6:	01b05963          	blez	s11,ffffffffc02058b8 <vprintfmt+0x244>
ffffffffc02058aa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02058ac:	85a6                	mv	a1,s1
ffffffffc02058ae:	02000513          	li	a0,32
ffffffffc02058b2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02058b4:	fe0d9be3          	bnez	s11,ffffffffc02058aa <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02058b8:	6a02                	ld	s4,0(sp)
ffffffffc02058ba:	bbd5                	j	ffffffffc02056ae <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02058bc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02058be:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02058c2:	01174463          	blt	a4,a7,ffffffffc02058ca <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02058c6:	08088d63          	beqz	a7,ffffffffc0205960 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02058ca:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02058ce:	0a044d63          	bltz	s0,ffffffffc0205988 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02058d2:	8622                	mv	a2,s0
ffffffffc02058d4:	8a66                	mv	s4,s9
ffffffffc02058d6:	46a9                	li	a3,10
ffffffffc02058d8:	bdcd                	j	ffffffffc02057ca <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02058da:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02058de:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02058e0:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02058e2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02058e6:	8fb5                	xor	a5,a5,a3
ffffffffc02058e8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02058ec:	02d74163          	blt	a4,a3,ffffffffc020590e <vprintfmt+0x29a>
ffffffffc02058f0:	00369793          	slli	a5,a3,0x3
ffffffffc02058f4:	97de                	add	a5,a5,s7
ffffffffc02058f6:	639c                	ld	a5,0(a5)
ffffffffc02058f8:	cb99                	beqz	a5,ffffffffc020590e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02058fa:	86be                	mv	a3,a5
ffffffffc02058fc:	00000617          	auipc	a2,0x0
ffffffffc0205900:	13c60613          	addi	a2,a2,316 # ffffffffc0205a38 <etext+0x2c>
ffffffffc0205904:	85a6                	mv	a1,s1
ffffffffc0205906:	854a                	mv	a0,s2
ffffffffc0205908:	0ce000ef          	jal	ra,ffffffffc02059d6 <printfmt>
ffffffffc020590c:	b34d                	j	ffffffffc02056ae <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020590e:	00002617          	auipc	a2,0x2
ffffffffc0205912:	0fa60613          	addi	a2,a2,250 # ffffffffc0207a08 <syscalls+0x120>
ffffffffc0205916:	85a6                	mv	a1,s1
ffffffffc0205918:	854a                	mv	a0,s2
ffffffffc020591a:	0bc000ef          	jal	ra,ffffffffc02059d6 <printfmt>
ffffffffc020591e:	bb41                	j	ffffffffc02056ae <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0205920:	00002417          	auipc	s0,0x2
ffffffffc0205924:	0e040413          	addi	s0,s0,224 # ffffffffc0207a00 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205928:	85e2                	mv	a1,s8
ffffffffc020592a:	8522                	mv	a0,s0
ffffffffc020592c:	e43e                	sd	a5,8(sp)
ffffffffc020592e:	c29ff0ef          	jal	ra,ffffffffc0205556 <strnlen>
ffffffffc0205932:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0205936:	01b05b63          	blez	s11,ffffffffc020594c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020593a:	67a2                	ld	a5,8(sp)
ffffffffc020593c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205940:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0205942:	85a6                	mv	a1,s1
ffffffffc0205944:	8552                	mv	a0,s4
ffffffffc0205946:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205948:	fe0d9ce3          	bnez	s11,ffffffffc0205940 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020594c:	00044783          	lbu	a5,0(s0)
ffffffffc0205950:	00140a13          	addi	s4,s0,1
ffffffffc0205954:	0007851b          	sext.w	a0,a5
ffffffffc0205958:	d3a5                	beqz	a5,ffffffffc02058b8 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020595a:	05e00413          	li	s0,94
ffffffffc020595e:	bf39                	j	ffffffffc020587c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0205960:	000a2403          	lw	s0,0(s4)
ffffffffc0205964:	b7ad                	j	ffffffffc02058ce <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0205966:	000a6603          	lwu	a2,0(s4)
ffffffffc020596a:	46a1                	li	a3,8
ffffffffc020596c:	8a2e                	mv	s4,a1
ffffffffc020596e:	bdb1                	j	ffffffffc02057ca <vprintfmt+0x156>
ffffffffc0205970:	000a6603          	lwu	a2,0(s4)
ffffffffc0205974:	46a9                	li	a3,10
ffffffffc0205976:	8a2e                	mv	s4,a1
ffffffffc0205978:	bd89                	j	ffffffffc02057ca <vprintfmt+0x156>
ffffffffc020597a:	000a6603          	lwu	a2,0(s4)
ffffffffc020597e:	46c1                	li	a3,16
ffffffffc0205980:	8a2e                	mv	s4,a1
ffffffffc0205982:	b5a1                	j	ffffffffc02057ca <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0205984:	9902                	jalr	s2
ffffffffc0205986:	bf09                	j	ffffffffc0205898 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0205988:	85a6                	mv	a1,s1
ffffffffc020598a:	02d00513          	li	a0,45
ffffffffc020598e:	e03e                	sd	a5,0(sp)
ffffffffc0205990:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0205992:	6782                	ld	a5,0(sp)
ffffffffc0205994:	8a66                	mv	s4,s9
ffffffffc0205996:	40800633          	neg	a2,s0
ffffffffc020599a:	46a9                	li	a3,10
ffffffffc020599c:	b53d                	j	ffffffffc02057ca <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020599e:	03b05163          	blez	s11,ffffffffc02059c0 <vprintfmt+0x34c>
ffffffffc02059a2:	02d00693          	li	a3,45
ffffffffc02059a6:	f6d79de3          	bne	a5,a3,ffffffffc0205920 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02059aa:	00002417          	auipc	s0,0x2
ffffffffc02059ae:	05640413          	addi	s0,s0,86 # ffffffffc0207a00 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02059b2:	02800793          	li	a5,40
ffffffffc02059b6:	02800513          	li	a0,40
ffffffffc02059ba:	00140a13          	addi	s4,s0,1
ffffffffc02059be:	bd6d                	j	ffffffffc0205878 <vprintfmt+0x204>
ffffffffc02059c0:	00002a17          	auipc	s4,0x2
ffffffffc02059c4:	041a0a13          	addi	s4,s4,65 # ffffffffc0207a01 <syscalls+0x119>
ffffffffc02059c8:	02800513          	li	a0,40
ffffffffc02059cc:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02059d0:	05e00413          	li	s0,94
ffffffffc02059d4:	b565                	j	ffffffffc020587c <vprintfmt+0x208>

ffffffffc02059d6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02059d6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02059d8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02059dc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02059de:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02059e0:	ec06                	sd	ra,24(sp)
ffffffffc02059e2:	f83a                	sd	a4,48(sp)
ffffffffc02059e4:	fc3e                	sd	a5,56(sp)
ffffffffc02059e6:	e0c2                	sd	a6,64(sp)
ffffffffc02059e8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02059ea:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02059ec:	c89ff0ef          	jal	ra,ffffffffc0205674 <vprintfmt>
}
ffffffffc02059f0:	60e2                	ld	ra,24(sp)
ffffffffc02059f2:	6161                	addi	sp,sp,80
ffffffffc02059f4:	8082                	ret

ffffffffc02059f6 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02059f6:	9e3707b7          	lui	a5,0x9e370
ffffffffc02059fa:	2785                	addiw	a5,a5,1
ffffffffc02059fc:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0205a00:	02000793          	li	a5,32
ffffffffc0205a04:	9f8d                	subw	a5,a5,a1
}
ffffffffc0205a06:	00f5553b          	srlw	a0,a0,a5
ffffffffc0205a0a:	8082                	ret
