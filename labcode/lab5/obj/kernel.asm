
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
ffffffffc020004a:	000a6517          	auipc	a0,0xa6
ffffffffc020004e:	2c650513          	addi	a0,a0,710 # ffffffffc02a6310 <buf>
ffffffffc0200052:	000aa617          	auipc	a2,0xaa
ffffffffc0200056:	77260613          	addi	a2,a2,1906 # ffffffffc02aa7c4 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	552050ef          	jal	ra,ffffffffc02055b4 <memset>
    dtb_init();
ffffffffc0200066:	4d6000ef          	jal	ra,ffffffffc020053c <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	0d7000ef          	jal	ra,ffffffffc0200940 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00006597          	auipc	a1,0x6
ffffffffc0200072:	97a58593          	addi	a1,a1,-1670 # ffffffffc02059e8 <etext+0x6>
ffffffffc0200076:	00006517          	auipc	a0,0x6
ffffffffc020007a:	99250513          	addi	a0,a0,-1646 # ffffffffc0205a08 <etext+0x26>
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
ffffffffc0200092:	607020ef          	jal	ra,ffffffffc0202e98 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	0de050ef          	jal	ra,ffffffffc0205174 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	053000ef          	jal	ra,ffffffffc02008ec <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	117000ef          	jal	ra,ffffffffc02009b4 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	26a050ef          	jal	ra,ffffffffc020530c <cpu_idle>

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
ffffffffc02000d4:	576050ef          	jal	ra,ffffffffc020564a <vprintfmt>
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
ffffffffc020010a:	540050ef          	jal	ra,ffffffffc020564a <vprintfmt>
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
ffffffffc0200184:	89050513          	addi	a0,a0,-1904 # ffffffffc0205a10 <etext+0x2e>
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
ffffffffc0200196:	000a6b97          	auipc	s7,0xa6
ffffffffc020019a:	17ab8b93          	addi	s7,s7,378 # ffffffffc02a6310 <buf>
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
ffffffffc02001f2:	000a6517          	auipc	a0,0xa6
ffffffffc02001f6:	11e50513          	addi	a0,a0,286 # ffffffffc02a6310 <buf>
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
ffffffffc020021e:	000aa317          	auipc	t1,0xaa
ffffffffc0200222:	51a30313          	addi	t1,t1,1306 # ffffffffc02aa738 <is_panic>
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
ffffffffc0200250:	7cc50513          	addi	a0,a0,1996 # ffffffffc0205a18 <etext+0x36>
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
ffffffffc0200266:	6ee50513          	addi	a0,a0,1774 # ffffffffc0206950 <commands+0xcc0>
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
ffffffffc020029a:	7a250513          	addi	a0,a0,1954 # ffffffffc0205a38 <etext+0x56>
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
ffffffffc02002ba:	69a50513          	addi	a0,a0,1690 # ffffffffc0206950 <commands+0xcc0>
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
ffffffffc02002d0:	78c50513          	addi	a0,a0,1932 # ffffffffc0205a58 <etext+0x76>
{
ffffffffc02002d4:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002d6:	e0bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002da:	00000597          	auipc	a1,0x0
ffffffffc02002de:	d7058593          	addi	a1,a1,-656 # ffffffffc020004a <kern_init>
ffffffffc02002e2:	00005517          	auipc	a0,0x5
ffffffffc02002e6:	79650513          	addi	a0,a0,1942 # ffffffffc0205a78 <etext+0x96>
ffffffffc02002ea:	df7ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002ee:	00005597          	auipc	a1,0x5
ffffffffc02002f2:	6f458593          	addi	a1,a1,1780 # ffffffffc02059e2 <etext>
ffffffffc02002f6:	00005517          	auipc	a0,0x5
ffffffffc02002fa:	7a250513          	addi	a0,a0,1954 # ffffffffc0205a98 <etext+0xb6>
ffffffffc02002fe:	de3ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200302:	000a6597          	auipc	a1,0xa6
ffffffffc0200306:	00e58593          	addi	a1,a1,14 # ffffffffc02a6310 <buf>
ffffffffc020030a:	00005517          	auipc	a0,0x5
ffffffffc020030e:	7ae50513          	addi	a0,a0,1966 # ffffffffc0205ab8 <etext+0xd6>
ffffffffc0200312:	dcfff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200316:	000aa597          	auipc	a1,0xaa
ffffffffc020031a:	4ae58593          	addi	a1,a1,1198 # ffffffffc02aa7c4 <end>
ffffffffc020031e:	00005517          	auipc	a0,0x5
ffffffffc0200322:	7ba50513          	addi	a0,a0,1978 # ffffffffc0205ad8 <etext+0xf6>
ffffffffc0200326:	dbbff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020032a:	000ab597          	auipc	a1,0xab
ffffffffc020032e:	89958593          	addi	a1,a1,-1895 # ffffffffc02aabc3 <end+0x3ff>
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
ffffffffc0200350:	7ac50513          	addi	a0,a0,1964 # ffffffffc0205af8 <etext+0x116>
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
ffffffffc020035e:	7ce60613          	addi	a2,a2,1998 # ffffffffc0205b28 <etext+0x146>
ffffffffc0200362:	04f00593          	li	a1,79
ffffffffc0200366:	00005517          	auipc	a0,0x5
ffffffffc020036a:	7da50513          	addi	a0,a0,2010 # ffffffffc0205b40 <etext+0x15e>
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
ffffffffc0200376:	00005617          	auipc	a2,0x5
ffffffffc020037a:	7e260613          	addi	a2,a2,2018 # ffffffffc0205b58 <etext+0x176>
ffffffffc020037e:	00005597          	auipc	a1,0x5
ffffffffc0200382:	7fa58593          	addi	a1,a1,2042 # ffffffffc0205b78 <etext+0x196>
ffffffffc0200386:	00005517          	auipc	a0,0x5
ffffffffc020038a:	7fa50513          	addi	a0,a0,2042 # ffffffffc0205b80 <etext+0x19e>
{
ffffffffc020038e:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200390:	d51ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200394:	00005617          	auipc	a2,0x5
ffffffffc0200398:	7fc60613          	addi	a2,a2,2044 # ffffffffc0205b90 <etext+0x1ae>
ffffffffc020039c:	00006597          	auipc	a1,0x6
ffffffffc02003a0:	81c58593          	addi	a1,a1,-2020 # ffffffffc0205bb8 <etext+0x1d6>
ffffffffc02003a4:	00005517          	auipc	a0,0x5
ffffffffc02003a8:	7dc50513          	addi	a0,a0,2012 # ffffffffc0205b80 <etext+0x19e>
ffffffffc02003ac:	d35ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc02003b0:	00006617          	auipc	a2,0x6
ffffffffc02003b4:	81860613          	addi	a2,a2,-2024 # ffffffffc0205bc8 <etext+0x1e6>
ffffffffc02003b8:	00006597          	auipc	a1,0x6
ffffffffc02003bc:	83058593          	addi	a1,a1,-2000 # ffffffffc0205be8 <etext+0x206>
ffffffffc02003c0:	00005517          	auipc	a0,0x5
ffffffffc02003c4:	7c050513          	addi	a0,a0,1984 # ffffffffc0205b80 <etext+0x19e>
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
ffffffffc02003fa:	00005517          	auipc	a0,0x5
ffffffffc02003fe:	7fe50513          	addi	a0,a0,2046 # ffffffffc0205bf8 <etext+0x216>
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
ffffffffc0200420:	80450513          	addi	a0,a0,-2044 # ffffffffc0205c20 <etext+0x23e>
ffffffffc0200424:	cbdff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    if (tf != NULL)
ffffffffc0200428:	000b8563          	beqz	s7,ffffffffc0200432 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020042c:	855e                	mv	a0,s7
ffffffffc020042e:	77a000ef          	jal	ra,ffffffffc0200ba8 <print_trapframe>
ffffffffc0200432:	00006c17          	auipc	s8,0x6
ffffffffc0200436:	85ec0c13          	addi	s8,s8,-1954 # ffffffffc0205c90 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020043a:	00006917          	auipc	s2,0x6
ffffffffc020043e:	80e90913          	addi	s2,s2,-2034 # ffffffffc0205c48 <etext+0x266>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200442:	00006497          	auipc	s1,0x6
ffffffffc0200446:	80e48493          	addi	s1,s1,-2034 # ffffffffc0205c50 <etext+0x26e>
        if (argc == MAXARGS - 1)
ffffffffc020044a:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020044c:	00006b17          	auipc	s6,0x6
ffffffffc0200450:	80cb0b13          	addi	s6,s6,-2036 # ffffffffc0205c58 <etext+0x276>
        argv[argc++] = buf;
ffffffffc0200454:	00005a17          	auipc	s4,0x5
ffffffffc0200458:	724a0a13          	addi	s4,s4,1828 # ffffffffc0205b78 <etext+0x196>
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
ffffffffc020047a:	81ad0d13          	addi	s10,s10,-2022 # ffffffffc0205c90 <commands>
        argv[argc++] = buf;
ffffffffc020047e:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc0200480:	4401                	li	s0,0
ffffffffc0200482:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200484:	0d6050ef          	jal	ra,ffffffffc020555a <strcmp>
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
ffffffffc0200498:	0c2050ef          	jal	ra,ffffffffc020555a <strcmp>
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
ffffffffc02004d6:	0c8050ef          	jal	ra,ffffffffc020559e <strchr>
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
ffffffffc0200514:	08a050ef          	jal	ra,ffffffffc020559e <strchr>
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
ffffffffc0200532:	74a50513          	addi	a0,a0,1866 # ffffffffc0205c78 <etext+0x296>
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
ffffffffc0200542:	79a50513          	addi	a0,a0,1946 # ffffffffc0205cd8 <commands+0x48>
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
ffffffffc0200570:	77c50513          	addi	a0,a0,1916 # ffffffffc0205ce8 <commands+0x58>
ffffffffc0200574:	b6dff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200578:	0000b417          	auipc	s0,0xb
ffffffffc020057c:	a9040413          	addi	s0,s0,-1392 # ffffffffc020b008 <boot_dtb>
ffffffffc0200580:	600c                	ld	a1,0(s0)
ffffffffc0200582:	00005517          	auipc	a0,0x5
ffffffffc0200586:	77650513          	addi	a0,a0,1910 # ffffffffc0205cf8 <commands+0x68>
ffffffffc020058a:	b57ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020058e:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200592:	00005517          	auipc	a0,0x5
ffffffffc0200596:	77e50513          	addi	a0,a0,1918 # ffffffffc0205d10 <commands+0x80>
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
ffffffffc02005da:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe35729>
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
ffffffffc0200650:	71490913          	addi	s2,s2,1812 # ffffffffc0205d60 <commands+0xd0>
ffffffffc0200654:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200656:	4d91                	li	s11,4
ffffffffc0200658:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020065a:	00005497          	auipc	s1,0x5
ffffffffc020065e:	6fe48493          	addi	s1,s1,1790 # ffffffffc0205d58 <commands+0xc8>
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
ffffffffc02006b2:	72a50513          	addi	a0,a0,1834 # ffffffffc0205dd8 <commands+0x148>
ffffffffc02006b6:	a2bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02006ba:	00005517          	auipc	a0,0x5
ffffffffc02006be:	75650513          	addi	a0,a0,1878 # ffffffffc0205e10 <commands+0x180>
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
ffffffffc02006fe:	63650513          	addi	a0,a0,1590 # ffffffffc0205d30 <commands+0xa0>
}
ffffffffc0200702:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200704:	baf1                	j	ffffffffc02000e0 <cprintf>
                int name_len = strlen(name);
ffffffffc0200706:	8556                	mv	a0,s5
ffffffffc0200708:	60b040ef          	jal	ra,ffffffffc0205512 <strlen>
ffffffffc020070c:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020070e:	4619                	li	a2,6
ffffffffc0200710:	85a6                	mv	a1,s1
ffffffffc0200712:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc0200714:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200716:	663040ef          	jal	ra,ffffffffc0205578 <strncmp>
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
ffffffffc02007ac:	5af040ef          	jal	ra,ffffffffc020555a <strcmp>
ffffffffc02007b0:	66a2                	ld	a3,8(sp)
ffffffffc02007b2:	f94d                	bnez	a0,ffffffffc0200764 <dtb_init+0x228>
ffffffffc02007b4:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200764 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02007b8:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02007bc:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02007c0:	00005517          	auipc	a0,0x5
ffffffffc02007c4:	5a850513          	addi	a0,a0,1448 # ffffffffc0205d68 <commands+0xd8>
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
ffffffffc0200892:	4fa50513          	addi	a0,a0,1274 # ffffffffc0205d88 <commands+0xf8>
ffffffffc0200896:	84bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020089a:	014b5613          	srli	a2,s6,0x14
ffffffffc020089e:	85da                	mv	a1,s6
ffffffffc02008a0:	00005517          	auipc	a0,0x5
ffffffffc02008a4:	50050513          	addi	a0,a0,1280 # ffffffffc0205da0 <commands+0x110>
ffffffffc02008a8:	839ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02008ac:	008b05b3          	add	a1,s6,s0
ffffffffc02008b0:	15fd                	addi	a1,a1,-1
ffffffffc02008b2:	00005517          	auipc	a0,0x5
ffffffffc02008b6:	50e50513          	addi	a0,a0,1294 # ffffffffc0205dc0 <commands+0x130>
ffffffffc02008ba:	827ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	55250513          	addi	a0,a0,1362 # ffffffffc0205e10 <commands+0x180>
        memory_base = mem_base;
ffffffffc02008c6:	000aa797          	auipc	a5,0xaa
ffffffffc02008ca:	e687bd23          	sd	s0,-390(a5) # ffffffffc02aa740 <memory_base>
        memory_size = mem_size;
ffffffffc02008ce:	000aa797          	auipc	a5,0xaa
ffffffffc02008d2:	e767bd23          	sd	s6,-390(a5) # ffffffffc02aa748 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02008d6:	b3f5                	j	ffffffffc02006c2 <dtb_init+0x186>

ffffffffc02008d8 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02008d8:	000aa517          	auipc	a0,0xaa
ffffffffc02008dc:	e6853503          	ld	a0,-408(a0) # ffffffffc02aa740 <memory_base>
ffffffffc02008e0:	8082                	ret

ffffffffc02008e2 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02008e2:	000aa517          	auipc	a0,0xaa
ffffffffc02008e6:	e6653503          	ld	a0,-410(a0) # ffffffffc02aa748 <memory_size>
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
ffffffffc02008f2:	000aa717          	auipc	a4,0xaa
ffffffffc02008f6:	e6f73323          	sd	a5,-410(a4) # ffffffffc02aa758 <timebase>
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
ffffffffc0200916:	51650513          	addi	a0,a0,1302 # ffffffffc0205e28 <commands+0x198>
    ticks = 0;
ffffffffc020091a:	000aa797          	auipc	a5,0xaa
ffffffffc020091e:	e207bb23          	sd	zero,-458(a5) # ffffffffc02aa750 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200922:	fbeff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200926 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200926:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020092a:	000aa797          	auipc	a5,0xaa
ffffffffc020092e:	e2e7b783          	ld	a5,-466(a5) # ffffffffc02aa758 <timebase>
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
ffffffffc02009e6:	46650513          	addi	a0,a0,1126 # ffffffffc0205e48 <commands+0x1b8>
{
ffffffffc02009ea:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009ec:	ef4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009f0:	640c                	ld	a1,8(s0)
ffffffffc02009f2:	00005517          	auipc	a0,0x5
ffffffffc02009f6:	46e50513          	addi	a0,a0,1134 # ffffffffc0205e60 <commands+0x1d0>
ffffffffc02009fa:	ee6ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009fe:	680c                	ld	a1,16(s0)
ffffffffc0200a00:	00005517          	auipc	a0,0x5
ffffffffc0200a04:	47850513          	addi	a0,a0,1144 # ffffffffc0205e78 <commands+0x1e8>
ffffffffc0200a08:	ed8ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a0c:	6c0c                	ld	a1,24(s0)
ffffffffc0200a0e:	00005517          	auipc	a0,0x5
ffffffffc0200a12:	48250513          	addi	a0,a0,1154 # ffffffffc0205e90 <commands+0x200>
ffffffffc0200a16:	ecaff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a1a:	700c                	ld	a1,32(s0)
ffffffffc0200a1c:	00005517          	auipc	a0,0x5
ffffffffc0200a20:	48c50513          	addi	a0,a0,1164 # ffffffffc0205ea8 <commands+0x218>
ffffffffc0200a24:	ebcff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a28:	740c                	ld	a1,40(s0)
ffffffffc0200a2a:	00005517          	auipc	a0,0x5
ffffffffc0200a2e:	49650513          	addi	a0,a0,1174 # ffffffffc0205ec0 <commands+0x230>
ffffffffc0200a32:	eaeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a36:	780c                	ld	a1,48(s0)
ffffffffc0200a38:	00005517          	auipc	a0,0x5
ffffffffc0200a3c:	4a050513          	addi	a0,a0,1184 # ffffffffc0205ed8 <commands+0x248>
ffffffffc0200a40:	ea0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a44:	7c0c                	ld	a1,56(s0)
ffffffffc0200a46:	00005517          	auipc	a0,0x5
ffffffffc0200a4a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0205ef0 <commands+0x260>
ffffffffc0200a4e:	e92ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a52:	602c                	ld	a1,64(s0)
ffffffffc0200a54:	00005517          	auipc	a0,0x5
ffffffffc0200a58:	4b450513          	addi	a0,a0,1204 # ffffffffc0205f08 <commands+0x278>
ffffffffc0200a5c:	e84ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a60:	642c                	ld	a1,72(s0)
ffffffffc0200a62:	00005517          	auipc	a0,0x5
ffffffffc0200a66:	4be50513          	addi	a0,a0,1214 # ffffffffc0205f20 <commands+0x290>
ffffffffc0200a6a:	e76ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a6e:	682c                	ld	a1,80(s0)
ffffffffc0200a70:	00005517          	auipc	a0,0x5
ffffffffc0200a74:	4c850513          	addi	a0,a0,1224 # ffffffffc0205f38 <commands+0x2a8>
ffffffffc0200a78:	e68ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a7c:	6c2c                	ld	a1,88(s0)
ffffffffc0200a7e:	00005517          	auipc	a0,0x5
ffffffffc0200a82:	4d250513          	addi	a0,a0,1234 # ffffffffc0205f50 <commands+0x2c0>
ffffffffc0200a86:	e5aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a8a:	702c                	ld	a1,96(s0)
ffffffffc0200a8c:	00005517          	auipc	a0,0x5
ffffffffc0200a90:	4dc50513          	addi	a0,a0,1244 # ffffffffc0205f68 <commands+0x2d8>
ffffffffc0200a94:	e4cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a98:	742c                	ld	a1,104(s0)
ffffffffc0200a9a:	00005517          	auipc	a0,0x5
ffffffffc0200a9e:	4e650513          	addi	a0,a0,1254 # ffffffffc0205f80 <commands+0x2f0>
ffffffffc0200aa2:	e3eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200aa6:	782c                	ld	a1,112(s0)
ffffffffc0200aa8:	00005517          	auipc	a0,0x5
ffffffffc0200aac:	4f050513          	addi	a0,a0,1264 # ffffffffc0205f98 <commands+0x308>
ffffffffc0200ab0:	e30ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200ab4:	7c2c                	ld	a1,120(s0)
ffffffffc0200ab6:	00005517          	auipc	a0,0x5
ffffffffc0200aba:	4fa50513          	addi	a0,a0,1274 # ffffffffc0205fb0 <commands+0x320>
ffffffffc0200abe:	e22ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200ac2:	604c                	ld	a1,128(s0)
ffffffffc0200ac4:	00005517          	auipc	a0,0x5
ffffffffc0200ac8:	50450513          	addi	a0,a0,1284 # ffffffffc0205fc8 <commands+0x338>
ffffffffc0200acc:	e14ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200ad0:	644c                	ld	a1,136(s0)
ffffffffc0200ad2:	00005517          	auipc	a0,0x5
ffffffffc0200ad6:	50e50513          	addi	a0,a0,1294 # ffffffffc0205fe0 <commands+0x350>
ffffffffc0200ada:	e06ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ade:	684c                	ld	a1,144(s0)
ffffffffc0200ae0:	00005517          	auipc	a0,0x5
ffffffffc0200ae4:	51850513          	addi	a0,a0,1304 # ffffffffc0205ff8 <commands+0x368>
ffffffffc0200ae8:	df8ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200aec:	6c4c                	ld	a1,152(s0)
ffffffffc0200aee:	00005517          	auipc	a0,0x5
ffffffffc0200af2:	52250513          	addi	a0,a0,1314 # ffffffffc0206010 <commands+0x380>
ffffffffc0200af6:	deaff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200afa:	704c                	ld	a1,160(s0)
ffffffffc0200afc:	00005517          	auipc	a0,0x5
ffffffffc0200b00:	52c50513          	addi	a0,a0,1324 # ffffffffc0206028 <commands+0x398>
ffffffffc0200b04:	ddcff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200b08:	744c                	ld	a1,168(s0)
ffffffffc0200b0a:	00005517          	auipc	a0,0x5
ffffffffc0200b0e:	53650513          	addi	a0,a0,1334 # ffffffffc0206040 <commands+0x3b0>
ffffffffc0200b12:	dceff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b16:	784c                	ld	a1,176(s0)
ffffffffc0200b18:	00005517          	auipc	a0,0x5
ffffffffc0200b1c:	54050513          	addi	a0,a0,1344 # ffffffffc0206058 <commands+0x3c8>
ffffffffc0200b20:	dc0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b24:	7c4c                	ld	a1,184(s0)
ffffffffc0200b26:	00005517          	auipc	a0,0x5
ffffffffc0200b2a:	54a50513          	addi	a0,a0,1354 # ffffffffc0206070 <commands+0x3e0>
ffffffffc0200b2e:	db2ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b32:	606c                	ld	a1,192(s0)
ffffffffc0200b34:	00005517          	auipc	a0,0x5
ffffffffc0200b38:	55450513          	addi	a0,a0,1364 # ffffffffc0206088 <commands+0x3f8>
ffffffffc0200b3c:	da4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b40:	646c                	ld	a1,200(s0)
ffffffffc0200b42:	00005517          	auipc	a0,0x5
ffffffffc0200b46:	55e50513          	addi	a0,a0,1374 # ffffffffc02060a0 <commands+0x410>
ffffffffc0200b4a:	d96ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b4e:	686c                	ld	a1,208(s0)
ffffffffc0200b50:	00005517          	auipc	a0,0x5
ffffffffc0200b54:	56850513          	addi	a0,a0,1384 # ffffffffc02060b8 <commands+0x428>
ffffffffc0200b58:	d88ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b5c:	6c6c                	ld	a1,216(s0)
ffffffffc0200b5e:	00005517          	auipc	a0,0x5
ffffffffc0200b62:	57250513          	addi	a0,a0,1394 # ffffffffc02060d0 <commands+0x440>
ffffffffc0200b66:	d7aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b6a:	706c                	ld	a1,224(s0)
ffffffffc0200b6c:	00005517          	auipc	a0,0x5
ffffffffc0200b70:	57c50513          	addi	a0,a0,1404 # ffffffffc02060e8 <commands+0x458>
ffffffffc0200b74:	d6cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b78:	746c                	ld	a1,232(s0)
ffffffffc0200b7a:	00005517          	auipc	a0,0x5
ffffffffc0200b7e:	58650513          	addi	a0,a0,1414 # ffffffffc0206100 <commands+0x470>
ffffffffc0200b82:	d5eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b86:	786c                	ld	a1,240(s0)
ffffffffc0200b88:	00005517          	auipc	a0,0x5
ffffffffc0200b8c:	59050513          	addi	a0,a0,1424 # ffffffffc0206118 <commands+0x488>
ffffffffc0200b90:	d50ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b94:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b96:	6402                	ld	s0,0(sp)
ffffffffc0200b98:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b9a:	00005517          	auipc	a0,0x5
ffffffffc0200b9e:	59650513          	addi	a0,a0,1430 # ffffffffc0206130 <commands+0x4a0>
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
ffffffffc0200bb4:	59850513          	addi	a0,a0,1432 # ffffffffc0206148 <commands+0x4b8>
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
ffffffffc0200bcc:	59850513          	addi	a0,a0,1432 # ffffffffc0206160 <commands+0x4d0>
ffffffffc0200bd0:	d10ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bd4:	10843583          	ld	a1,264(s0)
ffffffffc0200bd8:	00005517          	auipc	a0,0x5
ffffffffc0200bdc:	5a050513          	addi	a0,a0,1440 # ffffffffc0206178 <commands+0x4e8>
ffffffffc0200be0:	d00ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200be4:	11043583          	ld	a1,272(s0)
ffffffffc0200be8:	00005517          	auipc	a0,0x5
ffffffffc0200bec:	5a850513          	addi	a0,a0,1448 # ffffffffc0206190 <commands+0x500>
ffffffffc0200bf0:	cf0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf4:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bf8:	6402                	ld	s0,0(sp)
ffffffffc0200bfa:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bfc:	00005517          	auipc	a0,0x5
ffffffffc0200c00:	5a450513          	addi	a0,a0,1444 # ffffffffc02061a0 <commands+0x510>
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
ffffffffc0200c1c:	65070713          	addi	a4,a4,1616 # ffffffffc0206268 <commands+0x5d8>
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
ffffffffc0200c2e:	5ee50513          	addi	a0,a0,1518 # ffffffffc0206218 <commands+0x588>
ffffffffc0200c32:	caeff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c36:	00005517          	auipc	a0,0x5
ffffffffc0200c3a:	5c250513          	addi	a0,a0,1474 # ffffffffc02061f8 <commands+0x568>
ffffffffc0200c3e:	ca2ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c42:	00005517          	auipc	a0,0x5
ffffffffc0200c46:	57650513          	addi	a0,a0,1398 # ffffffffc02061b8 <commands+0x528>
ffffffffc0200c4a:	c96ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c4e:	00005517          	auipc	a0,0x5
ffffffffc0200c52:	58a50513          	addi	a0,a0,1418 # ffffffffc02061d8 <commands+0x548>
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
ffffffffc0200c62:	000aa697          	auipc	a3,0xaa
ffffffffc0200c66:	aee68693          	addi	a3,a3,-1298 # ffffffffc02aa750 <ticks>
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
ffffffffc0200c84:	5c850513          	addi	a0,a0,1480 # ffffffffc0206248 <commands+0x5b8>
ffffffffc0200c88:	c58ff06f          	j	ffffffffc02000e0 <cprintf>
        print_trapframe(tf);
ffffffffc0200c8c:	bf31                	j	ffffffffc0200ba8 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c8e:	06400593          	li	a1,100
ffffffffc0200c92:	00005517          	auipc	a0,0x5
ffffffffc0200c96:	5a650513          	addi	a0,a0,1446 # ffffffffc0206238 <commands+0x5a8>
ffffffffc0200c9a:	c46ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
            if (current) {
ffffffffc0200c9e:	000aa797          	auipc	a5,0xaa
ffffffffc0200ca2:	b0a7b783          	ld	a5,-1270(a5) # ffffffffc02aa7a8 <current>
ffffffffc0200ca6:	c399                	beqz	a5,ffffffffc0200cac <interrupt_handler+0xa2>
                current->need_resched = 1;
ffffffffc0200ca8:	4705                	li	a4,1
ffffffffc0200caa:	ef98                	sd	a4,24(a5)
            print_num++;
ffffffffc0200cac:	000aa717          	auipc	a4,0xaa
ffffffffc0200cb0:	ab470713          	addi	a4,a4,-1356 # ffffffffc02aa760 <print_num.0>
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
ffffffffc0200ce6:	74670713          	addi	a4,a4,1862 # ffffffffc0206428 <commands+0x798>
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
ffffffffc0200cf8:	68c50513          	addi	a0,a0,1676 # ffffffffc0206380 <commands+0x6f0>
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
ffffffffc0200d10:	7820406f          	j	ffffffffc0205492 <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d14:	00005517          	auipc	a0,0x5
ffffffffc0200d18:	68c50513          	addi	a0,a0,1676 # ffffffffc02063a0 <commands+0x710>
}
ffffffffc0200d1c:	6402                	ld	s0,0(sp)
ffffffffc0200d1e:	60a2                	ld	ra,8(sp)
ffffffffc0200d20:	0141                	addi	sp,sp,16
        cprintf("Instruction access fault\n");
ffffffffc0200d22:	bbeff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d26:	00005517          	auipc	a0,0x5
ffffffffc0200d2a:	69a50513          	addi	a0,a0,1690 # ffffffffc02063c0 <commands+0x730>
ffffffffc0200d2e:	b7fd                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Instruction page fault\n");
ffffffffc0200d30:	00005517          	auipc	a0,0x5
ffffffffc0200d34:	6b050513          	addi	a0,a0,1712 # ffffffffc02063e0 <commands+0x750>
ffffffffc0200d38:	ba8ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        if ((tf->status & SSTATUS_SPP) == 0) {
ffffffffc0200d3c:	10043783          	ld	a5,256(s0)
ffffffffc0200d40:	1007f793          	andi	a5,a5,256
ffffffffc0200d44:	e3c5                	bnez	a5,ffffffffc0200de4 <exception_handler+0x114>
            do_pgfault(current->mm, CAUSE_FETCH_PAGE_FAULT, tf->tval);
ffffffffc0200d46:	000aa797          	auipc	a5,0xaa
ffffffffc0200d4a:	a627b783          	ld	a5,-1438(a5) # ffffffffc02aa7a8 <current>
ffffffffc0200d4e:	11043603          	ld	a2,272(s0)
ffffffffc0200d52:	7788                	ld	a0,40(a5)
ffffffffc0200d54:	45b1                	li	a1,12
ffffffffc0200d56:	a025                	j	ffffffffc0200d7e <exception_handler+0xae>
        cprintf("Load page fault\n");
ffffffffc0200d58:	00005517          	auipc	a0,0x5
ffffffffc0200d5c:	6a050513          	addi	a0,a0,1696 # ffffffffc02063f8 <commands+0x768>
ffffffffc0200d60:	b80ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        if ((tf->status & SSTATUS_SPP) == 0) {
ffffffffc0200d64:	10043783          	ld	a5,256(s0)
ffffffffc0200d68:	1007f793          	andi	a5,a5,256
ffffffffc0200d6c:	efa5                	bnez	a5,ffffffffc0200de4 <exception_handler+0x114>
            do_pgfault(current->mm, CAUSE_LOAD_PAGE_FAULT, tf->tval);
ffffffffc0200d6e:	000aa797          	auipc	a5,0xaa
ffffffffc0200d72:	a3a7b783          	ld	a5,-1478(a5) # ffffffffc02aa7a8 <current>
ffffffffc0200d76:	11043603          	ld	a2,272(s0)
ffffffffc0200d7a:	7788                	ld	a0,40(a5)
ffffffffc0200d7c:	45b5                	li	a1,13
}
ffffffffc0200d7e:	6402                	ld	s0,0(sp)
ffffffffc0200d80:	60a2                	ld	ra,8(sp)
ffffffffc0200d82:	0141                	addi	sp,sp,16
            do_pgfault(current->mm, CAUSE_LOAD_PAGE_FAULT, tf->tval);
ffffffffc0200d84:	5a30106f          	j	ffffffffc0202b26 <do_pgfault>
        if ((tf->status & SSTATUS_SPP) == 0) {
ffffffffc0200d88:	10053783          	ld	a5,256(a0)
ffffffffc0200d8c:	1007f793          	andi	a5,a5,256
ffffffffc0200d90:	ef81                	bnez	a5,ffffffffc0200da8 <exception_handler+0xd8>
            if (do_pgfault(current->mm, CAUSE_STORE_PAGE_FAULT, tf->tval) != 0) {
ffffffffc0200d92:	000aa797          	auipc	a5,0xaa
ffffffffc0200d96:	a167b783          	ld	a5,-1514(a5) # ffffffffc02aa7a8 <current>
ffffffffc0200d9a:	11053603          	ld	a2,272(a0)
ffffffffc0200d9e:	7788                	ld	a0,40(a5)
ffffffffc0200da0:	45bd                	li	a1,15
ffffffffc0200da2:	585010ef          	jal	ra,ffffffffc0202b26 <do_pgfault>
ffffffffc0200da6:	cd1d                	beqz	a0,ffffffffc0200de4 <exception_handler+0x114>
                cprintf("Store/AMO page fault\n");
ffffffffc0200da8:	00005517          	auipc	a0,0x5
ffffffffc0200dac:	66850513          	addi	a0,a0,1640 # ffffffffc0206410 <commands+0x780>
ffffffffc0200db0:	b7b5                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Instruction address misaligned\n");
ffffffffc0200db2:	00005517          	auipc	a0,0x5
ffffffffc0200db6:	4e650513          	addi	a0,a0,1254 # ffffffffc0206298 <commands+0x608>
ffffffffc0200dba:	b78d                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Instruction access fault\n");
ffffffffc0200dbc:	00005517          	auipc	a0,0x5
ffffffffc0200dc0:	4fc50513          	addi	a0,a0,1276 # ffffffffc02062b8 <commands+0x628>
ffffffffc0200dc4:	bfa1                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Illegal instruction\n");
ffffffffc0200dc6:	00005517          	auipc	a0,0x5
ffffffffc0200dca:	51250513          	addi	a0,a0,1298 # ffffffffc02062d8 <commands+0x648>
ffffffffc0200dce:	b7b9                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Breakpoint\n");
ffffffffc0200dd0:	00005517          	auipc	a0,0x5
ffffffffc0200dd4:	52050513          	addi	a0,a0,1312 # ffffffffc02062f0 <commands+0x660>
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
ffffffffc0200df0:	51450513          	addi	a0,a0,1300 # ffffffffc0206300 <commands+0x670>
ffffffffc0200df4:	b725                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Load access fault\n");
ffffffffc0200df6:	00005517          	auipc	a0,0x5
ffffffffc0200dfa:	52a50513          	addi	a0,a0,1322 # ffffffffc0206320 <commands+0x690>
ffffffffc0200dfe:	bf39                	j	ffffffffc0200d1c <exception_handler+0x4c>
        cprintf("Store/AMO access fault\n");
ffffffffc0200e00:	00005517          	auipc	a0,0x5
ffffffffc0200e04:	56850513          	addi	a0,a0,1384 # ffffffffc0206368 <commands+0x6d8>
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
ffffffffc0200e18:	52460613          	addi	a2,a2,1316 # ffffffffc0206338 <commands+0x6a8>
ffffffffc0200e1c:	0c500593          	li	a1,197
ffffffffc0200e20:	00005517          	auipc	a0,0x5
ffffffffc0200e24:	53050513          	addi	a0,a0,1328 # ffffffffc0206350 <commands+0x6c0>
ffffffffc0200e28:	bf6ff0ef          	jal	ra,ffffffffc020021e <__panic>
            tf->epc += 4;
ffffffffc0200e2c:	10843783          	ld	a5,264(s0)
ffffffffc0200e30:	0791                	addi	a5,a5,4
ffffffffc0200e32:	10f43423          	sd	a5,264(s0)
            syscall();
ffffffffc0200e36:	65c040ef          	jal	ra,ffffffffc0205492 <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e3a:	000aa797          	auipc	a5,0xaa
ffffffffc0200e3e:	96e7b783          	ld	a5,-1682(a5) # ffffffffc02aa7a8 <current>
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
ffffffffc0200e56:	000aa417          	auipc	s0,0xaa
ffffffffc0200e5a:	95240413          	addi	s0,s0,-1710 # ffffffffc02aa7a8 <current>
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
ffffffffc0200ece:	4d80406f          	j	ffffffffc02053a6 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ed2:	555d                	li	a0,-9
ffffffffc0200ed4:	083030ef          	jal	ra,ffffffffc0204756 <do_exit>
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
ffffffffc0201058:	41460613          	addi	a2,a2,1044 # ffffffffc0206468 <commands+0x7d8>
ffffffffc020105c:	06900593          	li	a1,105
ffffffffc0201060:	00005517          	auipc	a0,0x5
ffffffffc0201064:	42850513          	addi	a0,a0,1064 # ffffffffc0206488 <commands+0x7f8>
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
ffffffffc0201074:	42860613          	addi	a2,a2,1064 # ffffffffc0206498 <commands+0x808>
ffffffffc0201078:	07f00593          	li	a1,127
ffffffffc020107c:	00005517          	auipc	a0,0x5
ffffffffc0201080:	40c50513          	addi	a0,a0,1036 # ffffffffc0206488 <commands+0x7f8>
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
ffffffffc0201092:	000a9797          	auipc	a5,0xa9
ffffffffc0201096:	6f67b783          	ld	a5,1782(a5) # ffffffffc02aa788 <pmm_manager>
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
ffffffffc02010aa:	000a9797          	auipc	a5,0xa9
ffffffffc02010ae:	6de7b783          	ld	a5,1758(a5) # ffffffffc02aa788 <pmm_manager>
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
ffffffffc02010d0:	000a9797          	auipc	a5,0xa9
ffffffffc02010d4:	6b87b783          	ld	a5,1720(a5) # ffffffffc02aa788 <pmm_manager>
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
ffffffffc02010ec:	000a9797          	auipc	a5,0xa9
ffffffffc02010f0:	69c7b783          	ld	a5,1692(a5) # ffffffffc02aa788 <pmm_manager>
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
ffffffffc0201110:	000a9797          	auipc	a5,0xa9
ffffffffc0201114:	6787b783          	ld	a5,1656(a5) # ffffffffc02aa788 <pmm_manager>
ffffffffc0201118:	779c                	ld	a5,40(a5)
ffffffffc020111a:	8782                	jr	a5
{
ffffffffc020111c:	1141                	addi	sp,sp,-16
ffffffffc020111e:	e406                	sd	ra,8(sp)
ffffffffc0201120:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201122:	899ff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201126:	000a9797          	auipc	a5,0xa9
ffffffffc020112a:	6627b783          	ld	a5,1634(a5) # ffffffffc02aa788 <pmm_manager>
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
ffffffffc020116c:	000a9997          	auipc	s3,0xa9
ffffffffc0201170:	60c98993          	addi	s3,s3,1548 # ffffffffc02aa778 <npage>
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
ffffffffc0201184:	000a9797          	auipc	a5,0xa9
ffffffffc0201188:	6047b783          	ld	a5,1540(a5) # ffffffffc02aa788 <pmm_manager>
ffffffffc020118c:	6f9c                	ld	a5,24(a5)
ffffffffc020118e:	4505                	li	a0,1
ffffffffc0201190:	9782                	jalr	a5
ffffffffc0201192:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201194:	12040d63          	beqz	s0,ffffffffc02012ce <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201198:	000a9b17          	auipc	s6,0xa9
ffffffffc020119c:	5e8b0b13          	addi	s6,s6,1512 # ffffffffc02aa780 <pages>
ffffffffc02011a0:	000b3503          	ld	a0,0(s6)
ffffffffc02011a4:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02011a8:	000a9997          	auipc	s3,0xa9
ffffffffc02011ac:	5d098993          	addi	s3,s3,1488 # ffffffffc02aa778 <npage>
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
ffffffffc02011cc:	000a9797          	auipc	a5,0xa9
ffffffffc02011d0:	5c47b783          	ld	a5,1476(a5) # ffffffffc02aa790 <va_pa_offset>
ffffffffc02011d4:	6605                	lui	a2,0x1
ffffffffc02011d6:	4581                	li	a1,0
ffffffffc02011d8:	953e                	add	a0,a0,a5
ffffffffc02011da:	3da040ef          	jal	ra,ffffffffc02055b4 <memset>
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
ffffffffc0201204:	000a9a97          	auipc	s5,0xa9
ffffffffc0201208:	58ca8a93          	addi	s5,s5,1420 # ffffffffc02aa790 <va_pa_offset>
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
ffffffffc0201234:	000a9797          	auipc	a5,0xa9
ffffffffc0201238:	5547b783          	ld	a5,1364(a5) # ffffffffc02aa788 <pmm_manager>
ffffffffc020123c:	6f9c                	ld	a5,24(a5)
ffffffffc020123e:	4505                	li	a0,1
ffffffffc0201240:	9782                	jalr	a5
ffffffffc0201242:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201244:	c4c9                	beqz	s1,ffffffffc02012ce <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201246:	000a9b17          	auipc	s6,0xa9
ffffffffc020124a:	53ab0b13          	addi	s6,s6,1338 # ffffffffc02aa780 <pages>
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
ffffffffc020127c:	338040ef          	jal	ra,ffffffffc02055b4 <memset>
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
ffffffffc02012d6:	000a9797          	auipc	a5,0xa9
ffffffffc02012da:	4b27b783          	ld	a5,1202(a5) # ffffffffc02aa788 <pmm_manager>
ffffffffc02012de:	6f9c                	ld	a5,24(a5)
ffffffffc02012e0:	4505                	li	a0,1
ffffffffc02012e2:	9782                	jalr	a5
ffffffffc02012e4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012e6:	eceff0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc02012ea:	b56d                	j	ffffffffc0201194 <get_pte+0x52>
        intr_disable();
ffffffffc02012ec:	eceff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc02012f0:	000a9797          	auipc	a5,0xa9
ffffffffc02012f4:	4987b783          	ld	a5,1176(a5) # ffffffffc02aa788 <pmm_manager>
ffffffffc02012f8:	6f9c                	ld	a5,24(a5)
ffffffffc02012fa:	4505                	li	a0,1
ffffffffc02012fc:	9782                	jalr	a5
ffffffffc02012fe:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc0201300:	eb4ff0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201304:	b781                	j	ffffffffc0201244 <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201306:	00005617          	auipc	a2,0x5
ffffffffc020130a:	1ba60613          	addi	a2,a2,442 # ffffffffc02064c0 <commands+0x830>
ffffffffc020130e:	0fa00593          	li	a1,250
ffffffffc0201312:	00005517          	auipc	a0,0x5
ffffffffc0201316:	1d650513          	addi	a0,a0,470 # ffffffffc02064e8 <commands+0x858>
ffffffffc020131a:	f05fe0ef          	jal	ra,ffffffffc020021e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020131e:	00005617          	auipc	a2,0x5
ffffffffc0201322:	1a260613          	addi	a2,a2,418 # ffffffffc02064c0 <commands+0x830>
ffffffffc0201326:	0ed00593          	li	a1,237
ffffffffc020132a:	00005517          	auipc	a0,0x5
ffffffffc020132e:	1be50513          	addi	a0,a0,446 # ffffffffc02064e8 <commands+0x858>
ffffffffc0201332:	eedfe0ef          	jal	ra,ffffffffc020021e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201336:	86aa                	mv	a3,a0
ffffffffc0201338:	00005617          	auipc	a2,0x5
ffffffffc020133c:	18860613          	addi	a2,a2,392 # ffffffffc02064c0 <commands+0x830>
ffffffffc0201340:	0e900593          	li	a1,233
ffffffffc0201344:	00005517          	auipc	a0,0x5
ffffffffc0201348:	1a450513          	addi	a0,a0,420 # ffffffffc02064e8 <commands+0x858>
ffffffffc020134c:	ed3fe0ef          	jal	ra,ffffffffc020021e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201350:	86aa                	mv	a3,a0
ffffffffc0201352:	00005617          	auipc	a2,0x5
ffffffffc0201356:	16e60613          	addi	a2,a2,366 # ffffffffc02064c0 <commands+0x830>
ffffffffc020135a:	0f700593          	li	a1,247
ffffffffc020135e:	00005517          	auipc	a0,0x5
ffffffffc0201362:	18a50513          	addi	a0,a0,394 # ffffffffc02064e8 <commands+0x858>
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
ffffffffc0201394:	000a9717          	auipc	a4,0xa9
ffffffffc0201398:	3e473703          	ld	a4,996(a4) # ffffffffc02aa778 <npage>
ffffffffc020139c:	00e7ff63          	bgeu	a5,a4,ffffffffc02013ba <get_page+0x50>
ffffffffc02013a0:	60a2                	ld	ra,8(sp)
ffffffffc02013a2:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02013a4:	fff80537          	lui	a0,0xfff80
ffffffffc02013a8:	97aa                	add	a5,a5,a0
ffffffffc02013aa:	079a                	slli	a5,a5,0x6
ffffffffc02013ac:	000a9517          	auipc	a0,0xa9
ffffffffc02013b0:	3d453503          	ld	a0,980(a0) # ffffffffc02aa780 <pages>
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
ffffffffc02013fc:	000a9c97          	auipc	s9,0xa9
ffffffffc0201400:	37cc8c93          	addi	s9,s9,892 # ffffffffc02aa778 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0201404:	000a9c17          	auipc	s8,0xa9
ffffffffc0201408:	37cc0c13          	addi	s8,s8,892 # ffffffffc02aa780 <pages>
ffffffffc020140c:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0201410:	000a9d17          	auipc	s10,0xa9
ffffffffc0201414:	378d0d13          	addi	s10,s10,888 # ffffffffc02aa788 <pmm_manager>
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
ffffffffc02014c4:	03868693          	addi	a3,a3,56 # ffffffffc02064f8 <commands+0x868>
ffffffffc02014c8:	00005617          	auipc	a2,0x5
ffffffffc02014cc:	06060613          	addi	a2,a2,96 # ffffffffc0206528 <commands+0x898>
ffffffffc02014d0:	12000593          	li	a1,288
ffffffffc02014d4:	00005517          	auipc	a0,0x5
ffffffffc02014d8:	01450513          	addi	a0,a0,20 # ffffffffc02064e8 <commands+0x858>
ffffffffc02014dc:	d43fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02014e0:	00005697          	auipc	a3,0x5
ffffffffc02014e4:	06068693          	addi	a3,a3,96 # ffffffffc0206540 <commands+0x8b0>
ffffffffc02014e8:	00005617          	auipc	a2,0x5
ffffffffc02014ec:	04060613          	addi	a2,a2,64 # ffffffffc0206528 <commands+0x898>
ffffffffc02014f0:	12100593          	li	a1,289
ffffffffc02014f4:	00005517          	auipc	a0,0x5
ffffffffc02014f8:	ff450513          	addi	a0,a0,-12 # ffffffffc02064e8 <commands+0x858>
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
ffffffffc020155a:	000a9d17          	auipc	s10,0xa9
ffffffffc020155e:	21ed0d13          	addi	s10,s10,542 # ffffffffc02aa778 <npage>
    return KADDR(page2pa(page));
ffffffffc0201562:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201566:	000a9717          	auipc	a4,0xa9
ffffffffc020156a:	21a70713          	addi	a4,a4,538 # ffffffffc02aa780 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020156e:	000a9d97          	auipc	s11,0xa9
ffffffffc0201572:	21ad8d93          	addi	s11,s11,538 # ffffffffc02aa788 <pmm_manager>
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
ffffffffc02015ca:	000a9817          	auipc	a6,0xa9
ffffffffc02015ce:	1c680813          	addi	a6,a6,454 # ffffffffc02aa790 <va_pa_offset>
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
ffffffffc020165e:	000a9817          	auipc	a6,0xa9
ffffffffc0201662:	13280813          	addi	a6,a6,306 # ffffffffc02aa790 <va_pa_offset>
ffffffffc0201666:	fff80e37          	lui	t3,0xfff80
ffffffffc020166a:	00080337          	lui	t1,0x80
ffffffffc020166e:	6885                	lui	a7,0x1
ffffffffc0201670:	000a9717          	auipc	a4,0xa9
ffffffffc0201674:	11070713          	addi	a4,a4,272 # ffffffffc02aa780 <pages>
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
ffffffffc02016a8:	000a9717          	auipc	a4,0xa9
ffffffffc02016ac:	0d870713          	addi	a4,a4,216 # ffffffffc02aa780 <pages>
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
ffffffffc02016f6:	000a9717          	auipc	a4,0xa9
ffffffffc02016fa:	08a70713          	addi	a4,a4,138 # ffffffffc02aa780 <pages>
ffffffffc02016fe:	6885                	lui	a7,0x1
ffffffffc0201700:	00080337          	lui	t1,0x80
ffffffffc0201704:	fff80e37          	lui	t3,0xfff80
ffffffffc0201708:	000a9817          	auipc	a6,0xa9
ffffffffc020170c:	08880813          	addi	a6,a6,136 # ffffffffc02aa790 <va_pa_offset>
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
ffffffffc020172c:	000a9717          	auipc	a4,0xa9
ffffffffc0201730:	05470713          	addi	a4,a4,84 # ffffffffc02aa780 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0201734:	00043023          	sd	zero,0(s0)
ffffffffc0201738:	bfb5                	j	ffffffffc02016b4 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020173a:	00005697          	auipc	a3,0x5
ffffffffc020173e:	dbe68693          	addi	a3,a3,-578 # ffffffffc02064f8 <commands+0x868>
ffffffffc0201742:	00005617          	auipc	a2,0x5
ffffffffc0201746:	de660613          	addi	a2,a2,-538 # ffffffffc0206528 <commands+0x898>
ffffffffc020174a:	13500593          	li	a1,309
ffffffffc020174e:	00005517          	auipc	a0,0x5
ffffffffc0201752:	d9a50513          	addi	a0,a0,-614 # ffffffffc02064e8 <commands+0x858>
ffffffffc0201756:	ac9fe0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc020175a:	00005617          	auipc	a2,0x5
ffffffffc020175e:	d6660613          	addi	a2,a2,-666 # ffffffffc02064c0 <commands+0x830>
ffffffffc0201762:	07100593          	li	a1,113
ffffffffc0201766:	00005517          	auipc	a0,0x5
ffffffffc020176a:	d2250513          	addi	a0,a0,-734 # ffffffffc0206488 <commands+0x7f8>
ffffffffc020176e:	ab1fe0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0201772:	8e1ff0ef          	jal	ra,ffffffffc0201052 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0201776:	00005697          	auipc	a3,0x5
ffffffffc020177a:	dca68693          	addi	a3,a3,-566 # ffffffffc0206540 <commands+0x8b0>
ffffffffc020177e:	00005617          	auipc	a2,0x5
ffffffffc0201782:	daa60613          	addi	a2,a2,-598 # ffffffffc0206528 <commands+0x898>
ffffffffc0201786:	13600593          	li	a1,310
ffffffffc020178a:	00005517          	auipc	a0,0x5
ffffffffc020178e:	d5e50513          	addi	a0,a0,-674 # ffffffffc02064e8 <commands+0x858>
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
ffffffffc02017c0:	000a9717          	auipc	a4,0xa9
ffffffffc02017c4:	fb873703          	ld	a4,-72(a4) # ffffffffc02aa778 <npage>
ffffffffc02017c8:	06e7f363          	bgeu	a5,a4,ffffffffc020182e <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02017cc:	fff80537          	lui	a0,0xfff80
ffffffffc02017d0:	97aa                	add	a5,a5,a0
ffffffffc02017d2:	079a                	slli	a5,a5,0x6
ffffffffc02017d4:	000a9517          	auipc	a0,0xa9
ffffffffc02017d8:	fac53503          	ld	a0,-84(a0) # ffffffffc02aa780 <pages>
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
ffffffffc0201802:	000a9797          	auipc	a5,0xa9
ffffffffc0201806:	f867b783          	ld	a5,-122(a5) # ffffffffc02aa788 <pmm_manager>
ffffffffc020180a:	739c                	ld	a5,32(a5)
ffffffffc020180c:	4585                	li	a1,1
ffffffffc020180e:	9782                	jalr	a5
    if (flag)
ffffffffc0201810:	bfe1                	j	ffffffffc02017e8 <page_remove+0x52>
        intr_disable();
ffffffffc0201812:	e42a                	sd	a0,8(sp)
ffffffffc0201814:	9a6ff0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0201818:	000a9797          	auipc	a5,0xa9
ffffffffc020181c:	f707b783          	ld	a5,-144(a5) # ffffffffc02aa788 <pmm_manager>
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
ffffffffc0201864:	000a9717          	auipc	a4,0xa9
ffffffffc0201868:	f1c73703          	ld	a4,-228(a4) # ffffffffc02aa780 <pages>
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
ffffffffc020189e:	000a9717          	auipc	a4,0xa9
ffffffffc02018a2:	eda73703          	ld	a4,-294(a4) # ffffffffc02aa778 <npage>
ffffffffc02018a6:	06e7ff63          	bgeu	a5,a4,ffffffffc0201924 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02018aa:	000a9a97          	auipc	s5,0xa9
ffffffffc02018ae:	ed6a8a93          	addi	s5,s5,-298 # ffffffffc02aa780 <pages>
ffffffffc02018b2:	000ab703          	ld	a4,0(s5)
ffffffffc02018b6:	fff80937          	lui	s2,0xfff80
ffffffffc02018ba:	993e                	add	s2,s2,a5
ffffffffc02018bc:	091a                	slli	s2,s2,0x6
ffffffffc02018be:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc02018c0:	01240c63          	beq	s0,s2,ffffffffc02018d8 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02018c4:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcd583c>
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
ffffffffc02018e4:	000a9797          	auipc	a5,0xa9
ffffffffc02018e8:	ea47b783          	ld	a5,-348(a5) # ffffffffc02aa788 <pmm_manager>
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
ffffffffc0201902:	000a9797          	auipc	a5,0xa9
ffffffffc0201906:	e867b783          	ld	a5,-378(a5) # ffffffffc02aa788 <pmm_manager>
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
ffffffffc020192c:	a7878793          	addi	a5,a5,-1416 # ffffffffc02073a0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201930:	638c                	ld	a1,0(a5)
{
ffffffffc0201932:	7159                	addi	sp,sp,-112
ffffffffc0201934:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201936:	00005517          	auipc	a0,0x5
ffffffffc020193a:	c2250513          	addi	a0,a0,-990 # ffffffffc0206558 <commands+0x8c8>
    pmm_manager = &default_pmm_manager;
ffffffffc020193e:	000a9b17          	auipc	s6,0xa9
ffffffffc0201942:	e4ab0b13          	addi	s6,s6,-438 # ffffffffc02aa788 <pmm_manager>
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
ffffffffc0201966:	000a9997          	auipc	s3,0xa9
ffffffffc020196a:	e2a98993          	addi	s3,s3,-470 # ffffffffc02aa790 <va_pa_offset>
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
ffffffffc020198e:	c0650513          	addi	a0,a0,-1018 # ffffffffc0206590 <commands+0x900>
ffffffffc0201992:	f4efe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc0201996:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020199a:	fff40693          	addi	a3,s0,-1
ffffffffc020199e:	864a                	mv	a2,s2
ffffffffc02019a0:	85a6                	mv	a1,s1
ffffffffc02019a2:	00005517          	auipc	a0,0x5
ffffffffc02019a6:	c0650513          	addi	a0,a0,-1018 # ffffffffc02065a8 <commands+0x918>
ffffffffc02019aa:	f36fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02019ae:	c8000737          	lui	a4,0xc8000
ffffffffc02019b2:	87a2                	mv	a5,s0
ffffffffc02019b4:	54876163          	bltu	a4,s0,ffffffffc0201ef6 <pmm_init+0x5ce>
ffffffffc02019b8:	757d                	lui	a0,0xfffff
ffffffffc02019ba:	000aa617          	auipc	a2,0xaa
ffffffffc02019be:	e0960613          	addi	a2,a2,-503 # ffffffffc02ab7c3 <end+0xfff>
ffffffffc02019c2:	8e69                	and	a2,a2,a0
ffffffffc02019c4:	000a9497          	auipc	s1,0xa9
ffffffffc02019c8:	db448493          	addi	s1,s1,-588 # ffffffffc02aa778 <npage>
ffffffffc02019cc:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02019d0:	000a9b97          	auipc	s7,0xa9
ffffffffc02019d4:	db0b8b93          	addi	s7,s7,-592 # ffffffffc02aa780 <pages>
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
ffffffffc02019f6:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd54844>
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
ffffffffc0201a2e:	bce50513          	addi	a0,a0,-1074 # ffffffffc02065f8 <commands+0x968>
ffffffffc0201a32:	eaefe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0201a36:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0201a3a:	000a9917          	auipc	s2,0xa9
ffffffffc0201a3e:	d3690913          	addi	s2,s2,-714 # ffffffffc02aa770 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc0201a42:	7b9c                	ld	a5,48(a5)
ffffffffc0201a44:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201a46:	00005517          	auipc	a0,0x5
ffffffffc0201a4a:	bca50513          	addi	a0,a0,-1078 # ffffffffc0206610 <commands+0x980>
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
ffffffffc0201a6c:	000a9797          	auipc	a5,0xa9
ffffffffc0201a70:	ced7be23          	sd	a3,-772(a5) # ffffffffc02aa768 <boot_pgdir_pa>
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
ffffffffc0201cdc:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd5483c>
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
ffffffffc0201d00:	c3c50513          	addi	a0,a0,-964 # ffffffffc0206938 <commands+0xca8>
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
ffffffffc0201dc4:	cc058593          	addi	a1,a1,-832 # ffffffffc0206a80 <commands+0xdf0>
ffffffffc0201dc8:	10000513          	li	a0,256
ffffffffc0201dcc:	77c030ef          	jal	ra,ffffffffc0205548 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201dd0:	10040593          	addi	a1,s0,256
ffffffffc0201dd4:	10000513          	li	a0,256
ffffffffc0201dd8:	782030ef          	jal	ra,ffffffffc020555a <strcmp>
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
ffffffffc0201e0e:	704030ef          	jal	ra,ffffffffc0205512 <strlen>
ffffffffc0201e12:	66051363          	bnez	a0,ffffffffc0202478 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0201e16:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0201e1a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e1c:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd5483c>
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
ffffffffc0201ed2:	c2a50513          	addi	a0,a0,-982 # ffffffffc0206af8 <commands+0xe68>
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
ffffffffc0201ef2:	56c0106f          	j	ffffffffc020345e <kmalloc_init>
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
ffffffffc020203a:	48a60613          	addi	a2,a2,1162 # ffffffffc02064c0 <commands+0x830>
ffffffffc020203e:	24200593          	li	a1,578
ffffffffc0202042:	00004517          	auipc	a0,0x4
ffffffffc0202046:	4a650513          	addi	a0,a0,1190 # ffffffffc02064e8 <commands+0x858>
ffffffffc020204a:	9d4fe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020204e:	00005697          	auipc	a3,0x5
ffffffffc0202052:	94a68693          	addi	a3,a3,-1718 # ffffffffc0206998 <commands+0xd08>
ffffffffc0202056:	00004617          	auipc	a2,0x4
ffffffffc020205a:	4d260613          	addi	a2,a2,1234 # ffffffffc0206528 <commands+0x898>
ffffffffc020205e:	24300593          	li	a1,579
ffffffffc0202062:	00004517          	auipc	a0,0x4
ffffffffc0202066:	48650513          	addi	a0,a0,1158 # ffffffffc02064e8 <commands+0x858>
ffffffffc020206a:	9b4fe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020206e:	00005697          	auipc	a3,0x5
ffffffffc0202072:	8ea68693          	addi	a3,a3,-1814 # ffffffffc0206958 <commands+0xcc8>
ffffffffc0202076:	00004617          	auipc	a2,0x4
ffffffffc020207a:	4b260613          	addi	a2,a2,1202 # ffffffffc0206528 <commands+0x898>
ffffffffc020207e:	24200593          	li	a1,578
ffffffffc0202082:	00004517          	auipc	a0,0x4
ffffffffc0202086:	46650513          	addi	a0,a0,1126 # ffffffffc02064e8 <commands+0x858>
ffffffffc020208a:	994fe0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc020208e:	fc5fe0ef          	jal	ra,ffffffffc0201052 <pa2page.part.0>
ffffffffc0202092:	fddfe0ef          	jal	ra,ffffffffc020106e <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202096:	00004697          	auipc	a3,0x4
ffffffffc020209a:	6ba68693          	addi	a3,a3,1722 # ffffffffc0206750 <commands+0xac0>
ffffffffc020209e:	00004617          	auipc	a2,0x4
ffffffffc02020a2:	48a60613          	addi	a2,a2,1162 # ffffffffc0206528 <commands+0x898>
ffffffffc02020a6:	21200593          	li	a1,530
ffffffffc02020aa:	00004517          	auipc	a0,0x4
ffffffffc02020ae:	43e50513          	addi	a0,a0,1086 # ffffffffc02064e8 <commands+0x858>
ffffffffc02020b2:	96cfe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02020b6:	00004697          	auipc	a3,0x4
ffffffffc02020ba:	5da68693          	addi	a3,a3,1498 # ffffffffc0206690 <commands+0xa00>
ffffffffc02020be:	00004617          	auipc	a2,0x4
ffffffffc02020c2:	46a60613          	addi	a2,a2,1130 # ffffffffc0206528 <commands+0x898>
ffffffffc02020c6:	20500593          	li	a1,517
ffffffffc02020ca:	00004517          	auipc	a0,0x4
ffffffffc02020ce:	41e50513          	addi	a0,a0,1054 # ffffffffc02064e8 <commands+0x858>
ffffffffc02020d2:	94cfe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02020d6:	00004697          	auipc	a3,0x4
ffffffffc02020da:	57a68693          	addi	a3,a3,1402 # ffffffffc0206650 <commands+0x9c0>
ffffffffc02020de:	00004617          	auipc	a2,0x4
ffffffffc02020e2:	44a60613          	addi	a2,a2,1098 # ffffffffc0206528 <commands+0x898>
ffffffffc02020e6:	20400593          	li	a1,516
ffffffffc02020ea:	00004517          	auipc	a0,0x4
ffffffffc02020ee:	3fe50513          	addi	a0,a0,1022 # ffffffffc02064e8 <commands+0x858>
ffffffffc02020f2:	92cfe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02020f6:	00004697          	auipc	a3,0x4
ffffffffc02020fa:	53a68693          	addi	a3,a3,1338 # ffffffffc0206630 <commands+0x9a0>
ffffffffc02020fe:	00004617          	auipc	a2,0x4
ffffffffc0202102:	42a60613          	addi	a2,a2,1066 # ffffffffc0206528 <commands+0x898>
ffffffffc0202106:	20300593          	li	a1,515
ffffffffc020210a:	00004517          	auipc	a0,0x4
ffffffffc020210e:	3de50513          	addi	a0,a0,990 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202112:	90cfe0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202116:	00004617          	auipc	a2,0x4
ffffffffc020211a:	3aa60613          	addi	a2,a2,938 # ffffffffc02064c0 <commands+0x830>
ffffffffc020211e:	07100593          	li	a1,113
ffffffffc0202122:	00004517          	auipc	a0,0x4
ffffffffc0202126:	36650513          	addi	a0,a0,870 # ffffffffc0206488 <commands+0x7f8>
ffffffffc020212a:	8f4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc020212e:	00004697          	auipc	a3,0x4
ffffffffc0202132:	7b268693          	addi	a3,a3,1970 # ffffffffc02068e0 <commands+0xc50>
ffffffffc0202136:	00004617          	auipc	a2,0x4
ffffffffc020213a:	3f260613          	addi	a2,a2,1010 # ffffffffc0206528 <commands+0x898>
ffffffffc020213e:	22b00593          	li	a1,555
ffffffffc0202142:	00004517          	auipc	a0,0x4
ffffffffc0202146:	3a650513          	addi	a0,a0,934 # ffffffffc02064e8 <commands+0x858>
ffffffffc020214a:	8d4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020214e:	00004697          	auipc	a3,0x4
ffffffffc0202152:	74a68693          	addi	a3,a3,1866 # ffffffffc0206898 <commands+0xc08>
ffffffffc0202156:	00004617          	auipc	a2,0x4
ffffffffc020215a:	3d260613          	addi	a2,a2,978 # ffffffffc0206528 <commands+0x898>
ffffffffc020215e:	22900593          	li	a1,553
ffffffffc0202162:	00004517          	auipc	a0,0x4
ffffffffc0202166:	38650513          	addi	a0,a0,902 # ffffffffc02064e8 <commands+0x858>
ffffffffc020216a:	8b4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020216e:	00004697          	auipc	a3,0x4
ffffffffc0202172:	75a68693          	addi	a3,a3,1882 # ffffffffc02068c8 <commands+0xc38>
ffffffffc0202176:	00004617          	auipc	a2,0x4
ffffffffc020217a:	3b260613          	addi	a2,a2,946 # ffffffffc0206528 <commands+0x898>
ffffffffc020217e:	22800593          	li	a1,552
ffffffffc0202182:	00004517          	auipc	a0,0x4
ffffffffc0202186:	36650513          	addi	a0,a0,870 # ffffffffc02064e8 <commands+0x858>
ffffffffc020218a:	894fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc020218e:	00005697          	auipc	a3,0x5
ffffffffc0202192:	82268693          	addi	a3,a3,-2014 # ffffffffc02069b0 <commands+0xd20>
ffffffffc0202196:	00004617          	auipc	a2,0x4
ffffffffc020219a:	39260613          	addi	a2,a2,914 # ffffffffc0206528 <commands+0x898>
ffffffffc020219e:	24600593          	li	a1,582
ffffffffc02021a2:	00004517          	auipc	a0,0x4
ffffffffc02021a6:	34650513          	addi	a0,a0,838 # ffffffffc02064e8 <commands+0x858>
ffffffffc02021aa:	874fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02021ae:	00004697          	auipc	a3,0x4
ffffffffc02021b2:	76268693          	addi	a3,a3,1890 # ffffffffc0206910 <commands+0xc80>
ffffffffc02021b6:	00004617          	auipc	a2,0x4
ffffffffc02021ba:	37260613          	addi	a2,a2,882 # ffffffffc0206528 <commands+0x898>
ffffffffc02021be:	23300593          	li	a1,563
ffffffffc02021c2:	00004517          	auipc	a0,0x4
ffffffffc02021c6:	32650513          	addi	a0,a0,806 # ffffffffc02064e8 <commands+0x858>
ffffffffc02021ca:	854fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p) == 1);
ffffffffc02021ce:	00005697          	auipc	a3,0x5
ffffffffc02021d2:	83a68693          	addi	a3,a3,-1990 # ffffffffc0206a08 <commands+0xd78>
ffffffffc02021d6:	00004617          	auipc	a2,0x4
ffffffffc02021da:	35260613          	addi	a2,a2,850 # ffffffffc0206528 <commands+0x898>
ffffffffc02021de:	24b00593          	li	a1,587
ffffffffc02021e2:	00004517          	auipc	a0,0x4
ffffffffc02021e6:	30650513          	addi	a0,a0,774 # ffffffffc02064e8 <commands+0x858>
ffffffffc02021ea:	834fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02021ee:	00004697          	auipc	a3,0x4
ffffffffc02021f2:	7da68693          	addi	a3,a3,2010 # ffffffffc02069c8 <commands+0xd38>
ffffffffc02021f6:	00004617          	auipc	a2,0x4
ffffffffc02021fa:	33260613          	addi	a2,a2,818 # ffffffffc0206528 <commands+0x898>
ffffffffc02021fe:	24a00593          	li	a1,586
ffffffffc0202202:	00004517          	auipc	a0,0x4
ffffffffc0202206:	2e650513          	addi	a0,a0,742 # ffffffffc02064e8 <commands+0x858>
ffffffffc020220a:	814fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020220e:	00004697          	auipc	a3,0x4
ffffffffc0202212:	68a68693          	addi	a3,a3,1674 # ffffffffc0206898 <commands+0xc08>
ffffffffc0202216:	00004617          	auipc	a2,0x4
ffffffffc020221a:	31260613          	addi	a2,a2,786 # ffffffffc0206528 <commands+0x898>
ffffffffc020221e:	22500593          	li	a1,549
ffffffffc0202222:	00004517          	auipc	a0,0x4
ffffffffc0202226:	2c650513          	addi	a0,a0,710 # ffffffffc02064e8 <commands+0x858>
ffffffffc020222a:	ff5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020222e:	00004697          	auipc	a3,0x4
ffffffffc0202232:	50a68693          	addi	a3,a3,1290 # ffffffffc0206738 <commands+0xaa8>
ffffffffc0202236:	00004617          	auipc	a2,0x4
ffffffffc020223a:	2f260613          	addi	a2,a2,754 # ffffffffc0206528 <commands+0x898>
ffffffffc020223e:	22400593          	li	a1,548
ffffffffc0202242:	00004517          	auipc	a0,0x4
ffffffffc0202246:	2a650513          	addi	a0,a0,678 # ffffffffc02064e8 <commands+0x858>
ffffffffc020224a:	fd5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020224e:	00004697          	auipc	a3,0x4
ffffffffc0202252:	66268693          	addi	a3,a3,1634 # ffffffffc02068b0 <commands+0xc20>
ffffffffc0202256:	00004617          	auipc	a2,0x4
ffffffffc020225a:	2d260613          	addi	a2,a2,722 # ffffffffc0206528 <commands+0x898>
ffffffffc020225e:	22100593          	li	a1,545
ffffffffc0202262:	00004517          	auipc	a0,0x4
ffffffffc0202266:	28650513          	addi	a0,a0,646 # ffffffffc02064e8 <commands+0x858>
ffffffffc020226a:	fb5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020226e:	00004697          	auipc	a3,0x4
ffffffffc0202272:	4b268693          	addi	a3,a3,1202 # ffffffffc0206720 <commands+0xa90>
ffffffffc0202276:	00004617          	auipc	a2,0x4
ffffffffc020227a:	2b260613          	addi	a2,a2,690 # ffffffffc0206528 <commands+0x898>
ffffffffc020227e:	22000593          	li	a1,544
ffffffffc0202282:	00004517          	auipc	a0,0x4
ffffffffc0202286:	26650513          	addi	a0,a0,614 # ffffffffc02064e8 <commands+0x858>
ffffffffc020228a:	f95fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020228e:	00004697          	auipc	a3,0x4
ffffffffc0202292:	53268693          	addi	a3,a3,1330 # ffffffffc02067c0 <commands+0xb30>
ffffffffc0202296:	00004617          	auipc	a2,0x4
ffffffffc020229a:	29260613          	addi	a2,a2,658 # ffffffffc0206528 <commands+0x898>
ffffffffc020229e:	21f00593          	li	a1,543
ffffffffc02022a2:	00004517          	auipc	a0,0x4
ffffffffc02022a6:	24650513          	addi	a0,a0,582 # ffffffffc02064e8 <commands+0x858>
ffffffffc02022aa:	f75fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02022ae:	00004697          	auipc	a3,0x4
ffffffffc02022b2:	5ea68693          	addi	a3,a3,1514 # ffffffffc0206898 <commands+0xc08>
ffffffffc02022b6:	00004617          	auipc	a2,0x4
ffffffffc02022ba:	27260613          	addi	a2,a2,626 # ffffffffc0206528 <commands+0x898>
ffffffffc02022be:	21e00593          	li	a1,542
ffffffffc02022c2:	00004517          	auipc	a0,0x4
ffffffffc02022c6:	22650513          	addi	a0,a0,550 # ffffffffc02064e8 <commands+0x858>
ffffffffc02022ca:	f55fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02022ce:	00004697          	auipc	a3,0x4
ffffffffc02022d2:	5b268693          	addi	a3,a3,1458 # ffffffffc0206880 <commands+0xbf0>
ffffffffc02022d6:	00004617          	auipc	a2,0x4
ffffffffc02022da:	25260613          	addi	a2,a2,594 # ffffffffc0206528 <commands+0x898>
ffffffffc02022de:	21d00593          	li	a1,541
ffffffffc02022e2:	00004517          	auipc	a0,0x4
ffffffffc02022e6:	20650513          	addi	a0,a0,518 # ffffffffc02064e8 <commands+0x858>
ffffffffc02022ea:	f35fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02022ee:	00004697          	auipc	a3,0x4
ffffffffc02022f2:	56268693          	addi	a3,a3,1378 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02022f6:	00004617          	auipc	a2,0x4
ffffffffc02022fa:	23260613          	addi	a2,a2,562 # ffffffffc0206528 <commands+0x898>
ffffffffc02022fe:	21c00593          	li	a1,540
ffffffffc0202302:	00004517          	auipc	a0,0x4
ffffffffc0202306:	1e650513          	addi	a0,a0,486 # ffffffffc02064e8 <commands+0x858>
ffffffffc020230a:	f15fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020230e:	00004697          	auipc	a3,0x4
ffffffffc0202312:	52a68693          	addi	a3,a3,1322 # ffffffffc0206838 <commands+0xba8>
ffffffffc0202316:	00004617          	auipc	a2,0x4
ffffffffc020231a:	21260613          	addi	a2,a2,530 # ffffffffc0206528 <commands+0x898>
ffffffffc020231e:	21a00593          	li	a1,538
ffffffffc0202322:	00004517          	auipc	a0,0x4
ffffffffc0202326:	1c650513          	addi	a0,a0,454 # ffffffffc02064e8 <commands+0x858>
ffffffffc020232a:	ef5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc020232e:	00004697          	auipc	a3,0x4
ffffffffc0202332:	4ea68693          	addi	a3,a3,1258 # ffffffffc0206818 <commands+0xb88>
ffffffffc0202336:	00004617          	auipc	a2,0x4
ffffffffc020233a:	1f260613          	addi	a2,a2,498 # ffffffffc0206528 <commands+0x898>
ffffffffc020233e:	21900593          	li	a1,537
ffffffffc0202342:	00004517          	auipc	a0,0x4
ffffffffc0202346:	1a650513          	addi	a0,a0,422 # ffffffffc02064e8 <commands+0x858>
ffffffffc020234a:	ed5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(*ptep & PTE_W);
ffffffffc020234e:	00004697          	auipc	a3,0x4
ffffffffc0202352:	4ba68693          	addi	a3,a3,1210 # ffffffffc0206808 <commands+0xb78>
ffffffffc0202356:	00004617          	auipc	a2,0x4
ffffffffc020235a:	1d260613          	addi	a2,a2,466 # ffffffffc0206528 <commands+0x898>
ffffffffc020235e:	21800593          	li	a1,536
ffffffffc0202362:	00004517          	auipc	a0,0x4
ffffffffc0202366:	18650513          	addi	a0,a0,390 # ffffffffc02064e8 <commands+0x858>
ffffffffc020236a:	eb5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(*ptep & PTE_U);
ffffffffc020236e:	00004697          	auipc	a3,0x4
ffffffffc0202372:	48a68693          	addi	a3,a3,1162 # ffffffffc02067f8 <commands+0xb68>
ffffffffc0202376:	00004617          	auipc	a2,0x4
ffffffffc020237a:	1b260613          	addi	a2,a2,434 # ffffffffc0206528 <commands+0x898>
ffffffffc020237e:	21700593          	li	a1,535
ffffffffc0202382:	00004517          	auipc	a0,0x4
ffffffffc0202386:	16650513          	addi	a0,a0,358 # ffffffffc02064e8 <commands+0x858>
ffffffffc020238a:	e95fd0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("DTB memory info not available");
ffffffffc020238e:	00004617          	auipc	a2,0x4
ffffffffc0202392:	1e260613          	addi	a2,a2,482 # ffffffffc0206570 <commands+0x8e0>
ffffffffc0202396:	06500593          	li	a1,101
ffffffffc020239a:	00004517          	auipc	a0,0x4
ffffffffc020239e:	14e50513          	addi	a0,a0,334 # ffffffffc02064e8 <commands+0x858>
ffffffffc02023a2:	e7dfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02023a6:	00004697          	auipc	a3,0x4
ffffffffc02023aa:	56a68693          	addi	a3,a3,1386 # ffffffffc0206910 <commands+0xc80>
ffffffffc02023ae:	00004617          	auipc	a2,0x4
ffffffffc02023b2:	17a60613          	addi	a2,a2,378 # ffffffffc0206528 <commands+0x898>
ffffffffc02023b6:	25d00593          	li	a1,605
ffffffffc02023ba:	00004517          	auipc	a0,0x4
ffffffffc02023be:	12e50513          	addi	a0,a0,302 # ffffffffc02064e8 <commands+0x858>
ffffffffc02023c2:	e5dfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02023c6:	00004697          	auipc	a3,0x4
ffffffffc02023ca:	3fa68693          	addi	a3,a3,1018 # ffffffffc02067c0 <commands+0xb30>
ffffffffc02023ce:	00004617          	auipc	a2,0x4
ffffffffc02023d2:	15a60613          	addi	a2,a2,346 # ffffffffc0206528 <commands+0x898>
ffffffffc02023d6:	21600593          	li	a1,534
ffffffffc02023da:	00004517          	auipc	a0,0x4
ffffffffc02023de:	10e50513          	addi	a0,a0,270 # ffffffffc02064e8 <commands+0x858>
ffffffffc02023e2:	e3dfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02023e6:	00004697          	auipc	a3,0x4
ffffffffc02023ea:	39a68693          	addi	a3,a3,922 # ffffffffc0206780 <commands+0xaf0>
ffffffffc02023ee:	00004617          	auipc	a2,0x4
ffffffffc02023f2:	13a60613          	addi	a2,a2,314 # ffffffffc0206528 <commands+0x898>
ffffffffc02023f6:	21500593          	li	a1,533
ffffffffc02023fa:	00004517          	auipc	a0,0x4
ffffffffc02023fe:	0ee50513          	addi	a0,a0,238 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202402:	e1dfd0ef          	jal	ra,ffffffffc020021e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202406:	86d6                	mv	a3,s5
ffffffffc0202408:	00004617          	auipc	a2,0x4
ffffffffc020240c:	0b860613          	addi	a2,a2,184 # ffffffffc02064c0 <commands+0x830>
ffffffffc0202410:	21100593          	li	a1,529
ffffffffc0202414:	00004517          	auipc	a0,0x4
ffffffffc0202418:	0d450513          	addi	a0,a0,212 # ffffffffc02064e8 <commands+0x858>
ffffffffc020241c:	e03fd0ef          	jal	ra,ffffffffc020021e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202420:	00004617          	auipc	a2,0x4
ffffffffc0202424:	0a060613          	addi	a2,a2,160 # ffffffffc02064c0 <commands+0x830>
ffffffffc0202428:	21000593          	li	a1,528
ffffffffc020242c:	00004517          	auipc	a0,0x4
ffffffffc0202430:	0bc50513          	addi	a0,a0,188 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202434:	debfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202438:	00004697          	auipc	a3,0x4
ffffffffc020243c:	30068693          	addi	a3,a3,768 # ffffffffc0206738 <commands+0xaa8>
ffffffffc0202440:	00004617          	auipc	a2,0x4
ffffffffc0202444:	0e860613          	addi	a2,a2,232 # ffffffffc0206528 <commands+0x898>
ffffffffc0202448:	20e00593          	li	a1,526
ffffffffc020244c:	00004517          	auipc	a0,0x4
ffffffffc0202450:	09c50513          	addi	a0,a0,156 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202454:	dcbfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202458:	00004697          	auipc	a3,0x4
ffffffffc020245c:	2c868693          	addi	a3,a3,712 # ffffffffc0206720 <commands+0xa90>
ffffffffc0202460:	00004617          	auipc	a2,0x4
ffffffffc0202464:	0c860613          	addi	a2,a2,200 # ffffffffc0206528 <commands+0x898>
ffffffffc0202468:	20d00593          	li	a1,525
ffffffffc020246c:	00004517          	auipc	a0,0x4
ffffffffc0202470:	07c50513          	addi	a0,a0,124 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202474:	dabfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202478:	00004697          	auipc	a3,0x4
ffffffffc020247c:	65868693          	addi	a3,a3,1624 # ffffffffc0206ad0 <commands+0xe40>
ffffffffc0202480:	00004617          	auipc	a2,0x4
ffffffffc0202484:	0a860613          	addi	a2,a2,168 # ffffffffc0206528 <commands+0x898>
ffffffffc0202488:	25400593          	li	a1,596
ffffffffc020248c:	00004517          	auipc	a0,0x4
ffffffffc0202490:	05c50513          	addi	a0,a0,92 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202494:	d8bfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202498:	00004697          	auipc	a3,0x4
ffffffffc020249c:	60068693          	addi	a3,a3,1536 # ffffffffc0206a98 <commands+0xe08>
ffffffffc02024a0:	00004617          	auipc	a2,0x4
ffffffffc02024a4:	08860613          	addi	a2,a2,136 # ffffffffc0206528 <commands+0x898>
ffffffffc02024a8:	25100593          	li	a1,593
ffffffffc02024ac:	00004517          	auipc	a0,0x4
ffffffffc02024b0:	03c50513          	addi	a0,a0,60 # ffffffffc02064e8 <commands+0x858>
ffffffffc02024b4:	d6bfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p) == 2);
ffffffffc02024b8:	00004697          	auipc	a3,0x4
ffffffffc02024bc:	5b068693          	addi	a3,a3,1456 # ffffffffc0206a68 <commands+0xdd8>
ffffffffc02024c0:	00004617          	auipc	a2,0x4
ffffffffc02024c4:	06860613          	addi	a2,a2,104 # ffffffffc0206528 <commands+0x898>
ffffffffc02024c8:	24d00593          	li	a1,589
ffffffffc02024cc:	00004517          	auipc	a0,0x4
ffffffffc02024d0:	01c50513          	addi	a0,a0,28 # ffffffffc02064e8 <commands+0x858>
ffffffffc02024d4:	d4bfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02024d8:	00004697          	auipc	a3,0x4
ffffffffc02024dc:	54868693          	addi	a3,a3,1352 # ffffffffc0206a20 <commands+0xd90>
ffffffffc02024e0:	00004617          	auipc	a2,0x4
ffffffffc02024e4:	04860613          	addi	a2,a2,72 # ffffffffc0206528 <commands+0x898>
ffffffffc02024e8:	24c00593          	li	a1,588
ffffffffc02024ec:	00004517          	auipc	a0,0x4
ffffffffc02024f0:	ffc50513          	addi	a0,a0,-4 # ffffffffc02064e8 <commands+0x858>
ffffffffc02024f4:	d2bfd0ef          	jal	ra,ffffffffc020021e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02024f8:	00004617          	auipc	a2,0x4
ffffffffc02024fc:	0d860613          	addi	a2,a2,216 # ffffffffc02065d0 <commands+0x940>
ffffffffc0202500:	0c900593          	li	a1,201
ffffffffc0202504:	00004517          	auipc	a0,0x4
ffffffffc0202508:	fe450513          	addi	a0,a0,-28 # ffffffffc02064e8 <commands+0x858>
ffffffffc020250c:	d13fd0ef          	jal	ra,ffffffffc020021e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202510:	00004617          	auipc	a2,0x4
ffffffffc0202514:	0c060613          	addi	a2,a2,192 # ffffffffc02065d0 <commands+0x940>
ffffffffc0202518:	08100593          	li	a1,129
ffffffffc020251c:	00004517          	auipc	a0,0x4
ffffffffc0202520:	fcc50513          	addi	a0,a0,-52 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202524:	cfbfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202528:	00004697          	auipc	a3,0x4
ffffffffc020252c:	1c868693          	addi	a3,a3,456 # ffffffffc02066f0 <commands+0xa60>
ffffffffc0202530:	00004617          	auipc	a2,0x4
ffffffffc0202534:	ff860613          	addi	a2,a2,-8 # ffffffffc0206528 <commands+0x898>
ffffffffc0202538:	20c00593          	li	a1,524
ffffffffc020253c:	00004517          	auipc	a0,0x4
ffffffffc0202540:	fac50513          	addi	a0,a0,-84 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202544:	cdbfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202548:	00004697          	auipc	a3,0x4
ffffffffc020254c:	17868693          	addi	a3,a3,376 # ffffffffc02066c0 <commands+0xa30>
ffffffffc0202550:	00004617          	auipc	a2,0x4
ffffffffc0202554:	fd860613          	addi	a2,a2,-40 # ffffffffc0206528 <commands+0x898>
ffffffffc0202558:	20900593          	li	a1,521
ffffffffc020255c:	00004517          	auipc	a0,0x4
ffffffffc0202560:	f8c50513          	addi	a0,a0,-116 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202564:	cbbfd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202568 <copy_range>:
{
ffffffffc0202568:	7119                	addi	sp,sp,-128
ffffffffc020256a:	f4a6                	sd	s1,104(sp)
ffffffffc020256c:	84b6                	mv	s1,a3
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020256e:	8ed1                	or	a3,a3,a2
{
ffffffffc0202570:	fc86                	sd	ra,120(sp)
ffffffffc0202572:	f8a2                	sd	s0,112(sp)
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
ffffffffc0202588:	16d2                	slli	a3,a3,0x34
{
ffffffffc020258a:	e43a                	sd	a4,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020258c:	24069663          	bnez	a3,ffffffffc02027d8 <copy_range+0x270>
    assert(USER_ACCESS(start, end));
ffffffffc0202590:	00200737          	lui	a4,0x200
ffffffffc0202594:	8db2                	mv	s11,a2
ffffffffc0202596:	20e66563          	bltu	a2,a4,ffffffffc02027a0 <copy_range+0x238>
ffffffffc020259a:	20967363          	bgeu	a2,s1,ffffffffc02027a0 <copy_range+0x238>
ffffffffc020259e:	4705                	li	a4,1
ffffffffc02025a0:	077e                	slli	a4,a4,0x1f
ffffffffc02025a2:	1e976f63          	bltu	a4,s1,ffffffffc02027a0 <copy_range+0x238>
ffffffffc02025a6:	5bfd                	li	s7,-1
ffffffffc02025a8:	8a2a                	mv	s4,a0
ffffffffc02025aa:	842e                	mv	s0,a1
        start += PGSIZE;
ffffffffc02025ac:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc02025ae:	000a8b17          	auipc	s6,0xa8
ffffffffc02025b2:	1cab0b13          	addi	s6,s6,458 # ffffffffc02aa778 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02025b6:	000a8a97          	auipc	s5,0xa8
ffffffffc02025ba:	1caa8a93          	addi	s5,s5,458 # ffffffffc02aa780 <pages>
    return KADDR(page2pa(page));
ffffffffc02025be:	00cbdb93          	srli	s7,s7,0xc
        page = pmm_manager->alloc_pages(n);
ffffffffc02025c2:	000a8d17          	auipc	s10,0xa8
ffffffffc02025c6:	1c6d0d13          	addi	s10,s10,454 # ffffffffc02aa788 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02025ca:	4601                	li	a2,0
ffffffffc02025cc:	85ee                	mv	a1,s11
ffffffffc02025ce:	8522                	mv	a0,s0
ffffffffc02025d0:	b73fe0ef          	jal	ra,ffffffffc0201142 <get_pte>
ffffffffc02025d4:	892a                	mv	s2,a0
        if (ptep == NULL)
ffffffffc02025d6:	c55d                	beqz	a0,ffffffffc0202684 <copy_range+0x11c>
        if (*ptep & PTE_V)
ffffffffc02025d8:	6118                	ld	a4,0(a0)
ffffffffc02025da:	8b05                	andi	a4,a4,1
ffffffffc02025dc:	e705                	bnez	a4,ffffffffc0202604 <copy_range+0x9c>
        start += PGSIZE;
ffffffffc02025de:	9dce                	add	s11,s11,s3
    } while (start != 0 && start < end);
ffffffffc02025e0:	fe9de5e3          	bltu	s11,s1,ffffffffc02025ca <copy_range+0x62>
    return 0;
ffffffffc02025e4:	4501                	li	a0,0
}
ffffffffc02025e6:	70e6                	ld	ra,120(sp)
ffffffffc02025e8:	7446                	ld	s0,112(sp)
ffffffffc02025ea:	74a6                	ld	s1,104(sp)
ffffffffc02025ec:	7906                	ld	s2,96(sp)
ffffffffc02025ee:	69e6                	ld	s3,88(sp)
ffffffffc02025f0:	6a46                	ld	s4,80(sp)
ffffffffc02025f2:	6aa6                	ld	s5,72(sp)
ffffffffc02025f4:	6b06                	ld	s6,64(sp)
ffffffffc02025f6:	7be2                	ld	s7,56(sp)
ffffffffc02025f8:	7c42                	ld	s8,48(sp)
ffffffffc02025fa:	7ca2                	ld	s9,40(sp)
ffffffffc02025fc:	7d02                	ld	s10,32(sp)
ffffffffc02025fe:	6de2                	ld	s11,24(sp)
ffffffffc0202600:	6109                	addi	sp,sp,128
ffffffffc0202602:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0202604:	4605                	li	a2,1
ffffffffc0202606:	85ee                	mv	a1,s11
ffffffffc0202608:	8552                	mv	a0,s4
ffffffffc020260a:	b39fe0ef          	jal	ra,ffffffffc0201142 <get_pte>
ffffffffc020260e:	10050e63          	beqz	a0,ffffffffc020272a <copy_range+0x1c2>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0202612:	00093703          	ld	a4,0(s2)
    if (!(pte & PTE_V))
ffffffffc0202616:	00177693          	andi	a3,a4,1
ffffffffc020261a:	0007091b          	sext.w	s2,a4
ffffffffc020261e:	16068563          	beqz	a3,ffffffffc0202788 <copy_range+0x220>
    if (PPN(pa) >= npage)
ffffffffc0202622:	000b3683          	ld	a3,0(s6)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202626:	070a                	slli	a4,a4,0x2
ffffffffc0202628:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc020262a:	18d77b63          	bgeu	a4,a3,ffffffffc02027c0 <copy_range+0x258>
    return &pages[PPN(pa) - nbase];
ffffffffc020262e:	fff807b7          	lui	a5,0xfff80
ffffffffc0202632:	973e                	add	a4,a4,a5
ffffffffc0202634:	000ab583          	ld	a1,0(s5)
            if (share) {
ffffffffc0202638:	67a2                	ld	a5,8(sp)
ffffffffc020263a:	071a                	slli	a4,a4,0x6
ffffffffc020263c:	00e58cb3          	add	s9,a1,a4
ffffffffc0202640:	cfb9                	beqz	a5,ffffffffc020269e <copy_range+0x136>
                perm = (perm & ~PTE_W) | PTE_COW;
ffffffffc0202642:	01b97913          	andi	s2,s2,27
ffffffffc0202646:	10096913          	ori	s2,s2,256
                page_insert(from, page, start, perm);
ffffffffc020264a:	86ca                	mv	a3,s2
ffffffffc020264c:	866e                	mv	a2,s11
ffffffffc020264e:	85e6                	mv	a1,s9
ffffffffc0202650:	8522                	mv	a0,s0
ffffffffc0202652:	9e0ff0ef          	jal	ra,ffffffffc0201832 <page_insert>
                ret = page_insert(to, page, start, perm);
ffffffffc0202656:	86ca                	mv	a3,s2
ffffffffc0202658:	866e                	mv	a2,s11
ffffffffc020265a:	85e6                	mv	a1,s9
ffffffffc020265c:	8552                	mv	a0,s4
ffffffffc020265e:	9d4ff0ef          	jal	ra,ffffffffc0201832 <page_insert>
            assert(ret == 0);
ffffffffc0202662:	dd35                	beqz	a0,ffffffffc02025de <copy_range+0x76>
ffffffffc0202664:	00004697          	auipc	a3,0x4
ffffffffc0202668:	4d468693          	addi	a3,a3,1236 # ffffffffc0206b38 <commands+0xea8>
ffffffffc020266c:	00004617          	auipc	a2,0x4
ffffffffc0202670:	ebc60613          	addi	a2,a2,-324 # ffffffffc0206528 <commands+0x898>
ffffffffc0202674:	1a100593          	li	a1,417
ffffffffc0202678:	00004517          	auipc	a0,0x4
ffffffffc020267c:	e7050513          	addi	a0,a0,-400 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202680:	b9ffd0ef          	jal	ra,ffffffffc020021e <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202684:	00200637          	lui	a2,0x200
ffffffffc0202688:	00cd87b3          	add	a5,s11,a2
ffffffffc020268c:	ffe00637          	lui	a2,0xffe00
ffffffffc0202690:	00c7fdb3          	and	s11,a5,a2
    } while (start != 0 && start < end);
ffffffffc0202694:	f40d88e3          	beqz	s11,ffffffffc02025e4 <copy_range+0x7c>
ffffffffc0202698:	f29de9e3          	bltu	s11,s1,ffffffffc02025ca <copy_range+0x62>
ffffffffc020269c:	b7a1                	j	ffffffffc02025e4 <copy_range+0x7c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020269e:	10002773          	csrr	a4,sstatus
ffffffffc02026a2:	8b09                	andi	a4,a4,2
ffffffffc02026a4:	eb25                	bnez	a4,ffffffffc0202714 <copy_range+0x1ac>
        page = pmm_manager->alloc_pages(n);
ffffffffc02026a6:	000d3703          	ld	a4,0(s10)
ffffffffc02026aa:	4505                	li	a0,1
ffffffffc02026ac:	6f18                	ld	a4,24(a4)
ffffffffc02026ae:	9702                	jalr	a4
ffffffffc02026b0:	8c2a                	mv	s8,a0
                assert(page != NULL);
ffffffffc02026b2:	0a0c8b63          	beqz	s9,ffffffffc0202768 <copy_range+0x200>
                assert(npage != NULL);
ffffffffc02026b6:	080c0963          	beqz	s8,ffffffffc0202748 <copy_range+0x1e0>
    return page - pages + nbase;
ffffffffc02026ba:	000ab703          	ld	a4,0(s5)
ffffffffc02026be:	000808b7          	lui	a7,0x80
    return KADDR(page2pa(page));
ffffffffc02026c2:	000b3603          	ld	a2,0(s6)
    return page - pages + nbase;
ffffffffc02026c6:	40ec86b3          	sub	a3,s9,a4
ffffffffc02026ca:	8699                	srai	a3,a3,0x6
ffffffffc02026cc:	96c6                	add	a3,a3,a7
    return KADDR(page2pa(page));
ffffffffc02026ce:	0176f5b3          	and	a1,a3,s7
    return page2ppn(page) << PGSHIFT;
ffffffffc02026d2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02026d4:	04c5fe63          	bgeu	a1,a2,ffffffffc0202730 <copy_range+0x1c8>
    return page - pages + nbase;
ffffffffc02026d8:	40ec0733          	sub	a4,s8,a4
    return KADDR(page2pa(page));
ffffffffc02026dc:	000a8797          	auipc	a5,0xa8
ffffffffc02026e0:	0b478793          	addi	a5,a5,180 # ffffffffc02aa790 <va_pa_offset>
ffffffffc02026e4:	6388                	ld	a0,0(a5)
    return page - pages + nbase;
ffffffffc02026e6:	8719                	srai	a4,a4,0x6
ffffffffc02026e8:	9746                	add	a4,a4,a7
    return KADDR(page2pa(page));
ffffffffc02026ea:	017778b3          	and	a7,a4,s7
ffffffffc02026ee:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02026f2:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc02026f4:	02c8fd63          	bgeu	a7,a2,ffffffffc020272e <copy_range+0x1c6>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02026f8:	6605                	lui	a2,0x1
ffffffffc02026fa:	953a                	add	a0,a0,a4
ffffffffc02026fc:	6cb020ef          	jal	ra,ffffffffc02055c6 <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc0202700:	01f97693          	andi	a3,s2,31
ffffffffc0202704:	866e                	mv	a2,s11
ffffffffc0202706:	85e2                	mv	a1,s8
ffffffffc0202708:	8552                	mv	a0,s4
ffffffffc020270a:	928ff0ef          	jal	ra,ffffffffc0201832 <page_insert>
            assert(ret == 0);
ffffffffc020270e:	ec0508e3          	beqz	a0,ffffffffc02025de <copy_range+0x76>
ffffffffc0202712:	bf89                	j	ffffffffc0202664 <copy_range+0xfc>
        intr_disable();
ffffffffc0202714:	aa6fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202718:	000d3703          	ld	a4,0(s10)
ffffffffc020271c:	4505                	li	a0,1
ffffffffc020271e:	6f18                	ld	a4,24(a4)
ffffffffc0202720:	9702                	jalr	a4
ffffffffc0202722:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202724:	a90fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0202728:	b769                	j	ffffffffc02026b2 <copy_range+0x14a>
                return -E_NO_MEM;
ffffffffc020272a:	5571                	li	a0,-4
ffffffffc020272c:	bd6d                	j	ffffffffc02025e6 <copy_range+0x7e>
ffffffffc020272e:	86ba                	mv	a3,a4
ffffffffc0202730:	00004617          	auipc	a2,0x4
ffffffffc0202734:	d9060613          	addi	a2,a2,-624 # ffffffffc02064c0 <commands+0x830>
ffffffffc0202738:	07100593          	li	a1,113
ffffffffc020273c:	00004517          	auipc	a0,0x4
ffffffffc0202740:	d4c50513          	addi	a0,a0,-692 # ffffffffc0206488 <commands+0x7f8>
ffffffffc0202744:	adbfd0ef          	jal	ra,ffffffffc020021e <__panic>
                assert(npage != NULL);
ffffffffc0202748:	00004697          	auipc	a3,0x4
ffffffffc020274c:	3e068693          	addi	a3,a3,992 # ffffffffc0206b28 <commands+0xe98>
ffffffffc0202750:	00004617          	auipc	a2,0x4
ffffffffc0202754:	dd860613          	addi	a2,a2,-552 # ffffffffc0206528 <commands+0x898>
ffffffffc0202758:	19b00593          	li	a1,411
ffffffffc020275c:	00004517          	auipc	a0,0x4
ffffffffc0202760:	d8c50513          	addi	a0,a0,-628 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202764:	abbfd0ef          	jal	ra,ffffffffc020021e <__panic>
                assert(page != NULL);
ffffffffc0202768:	00004697          	auipc	a3,0x4
ffffffffc020276c:	3b068693          	addi	a3,a3,944 # ffffffffc0206b18 <commands+0xe88>
ffffffffc0202770:	00004617          	auipc	a2,0x4
ffffffffc0202774:	db860613          	addi	a2,a2,-584 # ffffffffc0206528 <commands+0x898>
ffffffffc0202778:	19a00593          	li	a1,410
ffffffffc020277c:	00004517          	auipc	a0,0x4
ffffffffc0202780:	d6c50513          	addi	a0,a0,-660 # ffffffffc02064e8 <commands+0x858>
ffffffffc0202784:	a9bfd0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202788:	00004617          	auipc	a2,0x4
ffffffffc020278c:	d1060613          	addi	a2,a2,-752 # ffffffffc0206498 <commands+0x808>
ffffffffc0202790:	07f00593          	li	a1,127
ffffffffc0202794:	00004517          	auipc	a0,0x4
ffffffffc0202798:	cf450513          	addi	a0,a0,-780 # ffffffffc0206488 <commands+0x7f8>
ffffffffc020279c:	a83fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02027a0:	00004697          	auipc	a3,0x4
ffffffffc02027a4:	da068693          	addi	a3,a3,-608 # ffffffffc0206540 <commands+0x8b0>
ffffffffc02027a8:	00004617          	auipc	a2,0x4
ffffffffc02027ac:	d8060613          	addi	a2,a2,-640 # ffffffffc0206528 <commands+0x898>
ffffffffc02027b0:	17c00593          	li	a1,380
ffffffffc02027b4:	00004517          	auipc	a0,0x4
ffffffffc02027b8:	d3450513          	addi	a0,a0,-716 # ffffffffc02064e8 <commands+0x858>
ffffffffc02027bc:	a63fd0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02027c0:	00004617          	auipc	a2,0x4
ffffffffc02027c4:	ca860613          	addi	a2,a2,-856 # ffffffffc0206468 <commands+0x7d8>
ffffffffc02027c8:	06900593          	li	a1,105
ffffffffc02027cc:	00004517          	auipc	a0,0x4
ffffffffc02027d0:	cbc50513          	addi	a0,a0,-836 # ffffffffc0206488 <commands+0x7f8>
ffffffffc02027d4:	a4bfd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02027d8:	00004697          	auipc	a3,0x4
ffffffffc02027dc:	d2068693          	addi	a3,a3,-736 # ffffffffc02064f8 <commands+0x868>
ffffffffc02027e0:	00004617          	auipc	a2,0x4
ffffffffc02027e4:	d4860613          	addi	a2,a2,-696 # ffffffffc0206528 <commands+0x898>
ffffffffc02027e8:	17b00593          	li	a1,379
ffffffffc02027ec:	00004517          	auipc	a0,0x4
ffffffffc02027f0:	cfc50513          	addi	a0,a0,-772 # ffffffffc02064e8 <commands+0x858>
ffffffffc02027f4:	a2bfd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02027f8 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027f8:	12058073          	sfence.vma	a1
}
ffffffffc02027fc:	8082                	ret

ffffffffc02027fe <pgdir_alloc_page>:
{
ffffffffc02027fe:	7179                	addi	sp,sp,-48
ffffffffc0202800:	ec26                	sd	s1,24(sp)
ffffffffc0202802:	e84a                	sd	s2,16(sp)
ffffffffc0202804:	e052                	sd	s4,0(sp)
ffffffffc0202806:	f406                	sd	ra,40(sp)
ffffffffc0202808:	f022                	sd	s0,32(sp)
ffffffffc020280a:	e44e                	sd	s3,8(sp)
ffffffffc020280c:	8a2a                	mv	s4,a0
ffffffffc020280e:	84ae                	mv	s1,a1
ffffffffc0202810:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202812:	100027f3          	csrr	a5,sstatus
ffffffffc0202816:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0202818:	000a8997          	auipc	s3,0xa8
ffffffffc020281c:	f7098993          	addi	s3,s3,-144 # ffffffffc02aa788 <pmm_manager>
ffffffffc0202820:	ef8d                	bnez	a5,ffffffffc020285a <pgdir_alloc_page+0x5c>
ffffffffc0202822:	0009b783          	ld	a5,0(s3)
ffffffffc0202826:	4505                	li	a0,1
ffffffffc0202828:	6f9c                	ld	a5,24(a5)
ffffffffc020282a:	9782                	jalr	a5
ffffffffc020282c:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc020282e:	cc09                	beqz	s0,ffffffffc0202848 <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0202830:	86ca                	mv	a3,s2
ffffffffc0202832:	8626                	mv	a2,s1
ffffffffc0202834:	85a2                	mv	a1,s0
ffffffffc0202836:	8552                	mv	a0,s4
ffffffffc0202838:	ffbfe0ef          	jal	ra,ffffffffc0201832 <page_insert>
ffffffffc020283c:	e915                	bnez	a0,ffffffffc0202870 <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc020283e:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc0202840:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc0202842:	4785                	li	a5,1
ffffffffc0202844:	04f71e63          	bne	a4,a5,ffffffffc02028a0 <pgdir_alloc_page+0xa2>
}
ffffffffc0202848:	70a2                	ld	ra,40(sp)
ffffffffc020284a:	8522                	mv	a0,s0
ffffffffc020284c:	7402                	ld	s0,32(sp)
ffffffffc020284e:	64e2                	ld	s1,24(sp)
ffffffffc0202850:	6942                	ld	s2,16(sp)
ffffffffc0202852:	69a2                	ld	s3,8(sp)
ffffffffc0202854:	6a02                	ld	s4,0(sp)
ffffffffc0202856:	6145                	addi	sp,sp,48
ffffffffc0202858:	8082                	ret
        intr_disable();
ffffffffc020285a:	960fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020285e:	0009b783          	ld	a5,0(s3)
ffffffffc0202862:	4505                	li	a0,1
ffffffffc0202864:	6f9c                	ld	a5,24(a5)
ffffffffc0202866:	9782                	jalr	a5
ffffffffc0202868:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020286a:	94afe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc020286e:	b7c1                	j	ffffffffc020282e <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202870:	100027f3          	csrr	a5,sstatus
ffffffffc0202874:	8b89                	andi	a5,a5,2
ffffffffc0202876:	eb89                	bnez	a5,ffffffffc0202888 <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc0202878:	0009b783          	ld	a5,0(s3)
ffffffffc020287c:	8522                	mv	a0,s0
ffffffffc020287e:	4585                	li	a1,1
ffffffffc0202880:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc0202882:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc0202884:	9782                	jalr	a5
    if (flag)
ffffffffc0202886:	b7c9                	j	ffffffffc0202848 <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc0202888:	932fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc020288c:	0009b783          	ld	a5,0(s3)
ffffffffc0202890:	8522                	mv	a0,s0
ffffffffc0202892:	4585                	li	a1,1
ffffffffc0202894:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc0202896:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc0202898:	9782                	jalr	a5
        intr_enable();
ffffffffc020289a:	91afe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc020289e:	b76d                	j	ffffffffc0202848 <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc02028a0:	00004697          	auipc	a3,0x4
ffffffffc02028a4:	2a868693          	addi	a3,a3,680 # ffffffffc0206b48 <commands+0xeb8>
ffffffffc02028a8:	00004617          	auipc	a2,0x4
ffffffffc02028ac:	c8060613          	addi	a2,a2,-896 # ffffffffc0206528 <commands+0x898>
ffffffffc02028b0:	1ea00593          	li	a1,490
ffffffffc02028b4:	00004517          	auipc	a0,0x4
ffffffffc02028b8:	c3450513          	addi	a0,a0,-972 # ffffffffc02064e8 <commands+0x858>
ffffffffc02028bc:	963fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02028c0 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02028c0:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02028c2:	00004697          	auipc	a3,0x4
ffffffffc02028c6:	29e68693          	addi	a3,a3,670 # ffffffffc0206b60 <commands+0xed0>
ffffffffc02028ca:	00004617          	auipc	a2,0x4
ffffffffc02028ce:	c5e60613          	addi	a2,a2,-930 # ffffffffc0206528 <commands+0x898>
ffffffffc02028d2:	07600593          	li	a1,118
ffffffffc02028d6:	00004517          	auipc	a0,0x4
ffffffffc02028da:	2aa50513          	addi	a0,a0,682 # ffffffffc0206b80 <commands+0xef0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02028de:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02028e0:	93ffd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02028e4 <mm_create>:
{
ffffffffc02028e4:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02028e6:	04000513          	li	a0,64
{
ffffffffc02028ea:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02028ec:	397000ef          	jal	ra,ffffffffc0203482 <kmalloc>
    if (mm != NULL)
ffffffffc02028f0:	cd19                	beqz	a0,ffffffffc020290e <mm_create+0x2a>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02028f2:	e508                	sd	a0,8(a0)
ffffffffc02028f4:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02028f6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02028fa:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02028fe:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0202902:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc0202906:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc020290a:	02053c23          	sd	zero,56(a0)
}
ffffffffc020290e:	60a2                	ld	ra,8(sp)
ffffffffc0202910:	0141                	addi	sp,sp,16
ffffffffc0202912:	8082                	ret

ffffffffc0202914 <find_vma>:
{
ffffffffc0202914:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0202916:	c505                	beqz	a0,ffffffffc020293e <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0202918:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020291a:	c501                	beqz	a0,ffffffffc0202922 <find_vma+0xe>
ffffffffc020291c:	651c                	ld	a5,8(a0)
ffffffffc020291e:	02f5f263          	bgeu	a1,a5,ffffffffc0202942 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0202922:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0202924:	00f68d63          	beq	a3,a5,ffffffffc020293e <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0202928:	fe87b703          	ld	a4,-24(a5)
ffffffffc020292c:	00e5e663          	bltu	a1,a4,ffffffffc0202938 <find_vma+0x24>
ffffffffc0202930:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202934:	00e5ec63          	bltu	a1,a4,ffffffffc020294c <find_vma+0x38>
ffffffffc0202938:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc020293a:	fef697e3          	bne	a3,a5,ffffffffc0202928 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020293e:	4501                	li	a0,0
}
ffffffffc0202940:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0202942:	691c                	ld	a5,16(a0)
ffffffffc0202944:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0202922 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0202948:	ea88                	sd	a0,16(a3)
ffffffffc020294a:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc020294c:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0202950:	ea88                	sd	a0,16(a3)
ffffffffc0202952:	8082                	ret

ffffffffc0202954 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202954:	6590                	ld	a2,8(a1)
ffffffffc0202956:	0105b803          	ld	a6,16(a1)
{
ffffffffc020295a:	1141                	addi	sp,sp,-16
ffffffffc020295c:	e406                	sd	ra,8(sp)
ffffffffc020295e:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202960:	01066763          	bltu	a2,a6,ffffffffc020296e <insert_vma_struct+0x1a>
ffffffffc0202964:	a085                	j	ffffffffc02029c4 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0202966:	fe87b703          	ld	a4,-24(a5)
ffffffffc020296a:	04e66863          	bltu	a2,a4,ffffffffc02029ba <insert_vma_struct+0x66>
ffffffffc020296e:	86be                	mv	a3,a5
ffffffffc0202970:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0202972:	fef51ae3          	bne	a0,a5,ffffffffc0202966 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0202976:	02a68463          	beq	a3,a0,ffffffffc020299e <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020297a:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020297e:	fe86b883          	ld	a7,-24(a3)
ffffffffc0202982:	08e8f163          	bgeu	a7,a4,ffffffffc0202a04 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202986:	04e66f63          	bltu	a2,a4,ffffffffc02029e4 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc020298a:	00f50a63          	beq	a0,a5,ffffffffc020299e <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020298e:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202992:	05076963          	bltu	a4,a6,ffffffffc02029e4 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0202996:	ff07b603          	ld	a2,-16(a5)
ffffffffc020299a:	02c77363          	bgeu	a4,a2,ffffffffc02029c0 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc020299e:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02029a0:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02029a2:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02029a6:	e390                	sd	a2,0(a5)
ffffffffc02029a8:	e690                	sd	a2,8(a3)
}
ffffffffc02029aa:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02029ac:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02029ae:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02029b0:	0017079b          	addiw	a5,a4,1
ffffffffc02029b4:	d11c                	sw	a5,32(a0)
}
ffffffffc02029b6:	0141                	addi	sp,sp,16
ffffffffc02029b8:	8082                	ret
    if (le_prev != list)
ffffffffc02029ba:	fca690e3          	bne	a3,a0,ffffffffc020297a <insert_vma_struct+0x26>
ffffffffc02029be:	bfd1                	j	ffffffffc0202992 <insert_vma_struct+0x3e>
ffffffffc02029c0:	f01ff0ef          	jal	ra,ffffffffc02028c0 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02029c4:	00004697          	auipc	a3,0x4
ffffffffc02029c8:	1cc68693          	addi	a3,a3,460 # ffffffffc0206b90 <commands+0xf00>
ffffffffc02029cc:	00004617          	auipc	a2,0x4
ffffffffc02029d0:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0206528 <commands+0x898>
ffffffffc02029d4:	07c00593          	li	a1,124
ffffffffc02029d8:	00004517          	auipc	a0,0x4
ffffffffc02029dc:	1a850513          	addi	a0,a0,424 # ffffffffc0206b80 <commands+0xef0>
ffffffffc02029e0:	83ffd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02029e4:	00004697          	auipc	a3,0x4
ffffffffc02029e8:	1ec68693          	addi	a3,a3,492 # ffffffffc0206bd0 <commands+0xf40>
ffffffffc02029ec:	00004617          	auipc	a2,0x4
ffffffffc02029f0:	b3c60613          	addi	a2,a2,-1220 # ffffffffc0206528 <commands+0x898>
ffffffffc02029f4:	07500593          	li	a1,117
ffffffffc02029f8:	00004517          	auipc	a0,0x4
ffffffffc02029fc:	18850513          	addi	a0,a0,392 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0202a00:	81ffd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202a04:	00004697          	auipc	a3,0x4
ffffffffc0202a08:	1ac68693          	addi	a3,a3,428 # ffffffffc0206bb0 <commands+0xf20>
ffffffffc0202a0c:	00004617          	auipc	a2,0x4
ffffffffc0202a10:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0206528 <commands+0x898>
ffffffffc0202a14:	07400593          	li	a1,116
ffffffffc0202a18:	00004517          	auipc	a0,0x4
ffffffffc0202a1c:	16850513          	addi	a0,a0,360 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0202a20:	ffefd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202a24 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc0202a24:	591c                	lw	a5,48(a0)
{
ffffffffc0202a26:	1141                	addi	sp,sp,-16
ffffffffc0202a28:	e406                	sd	ra,8(sp)
ffffffffc0202a2a:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0202a2c:	e78d                	bnez	a5,ffffffffc0202a56 <mm_destroy+0x32>
ffffffffc0202a2e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0202a30:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0202a32:	00a40c63          	beq	s0,a0,ffffffffc0202a4a <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202a36:	6118                	ld	a4,0(a0)
ffffffffc0202a38:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0202a3a:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0202a3c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202a3e:	e398                	sd	a4,0(a5)
ffffffffc0202a40:	2f3000ef          	jal	ra,ffffffffc0203532 <kfree>
    return listelm->next;
ffffffffc0202a44:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0202a46:	fea418e3          	bne	s0,a0,ffffffffc0202a36 <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0202a4a:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0202a4c:	6402                	ld	s0,0(sp)
ffffffffc0202a4e:	60a2                	ld	ra,8(sp)
ffffffffc0202a50:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc0202a52:	2e10006f          	j	ffffffffc0203532 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0202a56:	00004697          	auipc	a3,0x4
ffffffffc0202a5a:	19a68693          	addi	a3,a3,410 # ffffffffc0206bf0 <commands+0xf60>
ffffffffc0202a5e:	00004617          	auipc	a2,0x4
ffffffffc0202a62:	aca60613          	addi	a2,a2,-1334 # ffffffffc0206528 <commands+0x898>
ffffffffc0202a66:	0a000593          	li	a1,160
ffffffffc0202a6a:	00004517          	auipc	a0,0x4
ffffffffc0202a6e:	11650513          	addi	a0,a0,278 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0202a72:	facfd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202a76 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc0202a76:	7139                	addi	sp,sp,-64
ffffffffc0202a78:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202a7a:	6405                	lui	s0,0x1
ffffffffc0202a7c:	147d                	addi	s0,s0,-1
ffffffffc0202a7e:	77fd                	lui	a5,0xfffff
ffffffffc0202a80:	9622                	add	a2,a2,s0
ffffffffc0202a82:	962e                	add	a2,a2,a1
{
ffffffffc0202a84:	f426                	sd	s1,40(sp)
ffffffffc0202a86:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202a88:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc0202a8c:	f04a                	sd	s2,32(sp)
ffffffffc0202a8e:	ec4e                	sd	s3,24(sp)
ffffffffc0202a90:	e852                	sd	s4,16(sp)
ffffffffc0202a92:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc0202a94:	002005b7          	lui	a1,0x200
ffffffffc0202a98:	00f67433          	and	s0,a2,a5
ffffffffc0202a9c:	06b4e363          	bltu	s1,a1,ffffffffc0202b02 <mm_map+0x8c>
ffffffffc0202aa0:	0684f163          	bgeu	s1,s0,ffffffffc0202b02 <mm_map+0x8c>
ffffffffc0202aa4:	4785                	li	a5,1
ffffffffc0202aa6:	07fe                	slli	a5,a5,0x1f
ffffffffc0202aa8:	0487ed63          	bltu	a5,s0,ffffffffc0202b02 <mm_map+0x8c>
ffffffffc0202aac:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0202aae:	cd21                	beqz	a0,ffffffffc0202b06 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0202ab0:	85a6                	mv	a1,s1
ffffffffc0202ab2:	8ab6                	mv	s5,a3
ffffffffc0202ab4:	8a3a                	mv	s4,a4
ffffffffc0202ab6:	e5fff0ef          	jal	ra,ffffffffc0202914 <find_vma>
ffffffffc0202aba:	c501                	beqz	a0,ffffffffc0202ac2 <mm_map+0x4c>
ffffffffc0202abc:	651c                	ld	a5,8(a0)
ffffffffc0202abe:	0487e263          	bltu	a5,s0,ffffffffc0202b02 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202ac2:	03000513          	li	a0,48
ffffffffc0202ac6:	1bd000ef          	jal	ra,ffffffffc0203482 <kmalloc>
ffffffffc0202aca:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0202acc:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc0202ace:	02090163          	beqz	s2,ffffffffc0202af0 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0202ad2:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0202ad4:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0202ad8:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0202adc:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0202ae0:	85ca                	mv	a1,s2
ffffffffc0202ae2:	e73ff0ef          	jal	ra,ffffffffc0202954 <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0202ae6:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc0202ae8:	000a0463          	beqz	s4,ffffffffc0202af0 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0202aec:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0202af0:	70e2                	ld	ra,56(sp)
ffffffffc0202af2:	7442                	ld	s0,48(sp)
ffffffffc0202af4:	74a2                	ld	s1,40(sp)
ffffffffc0202af6:	7902                	ld	s2,32(sp)
ffffffffc0202af8:	69e2                	ld	s3,24(sp)
ffffffffc0202afa:	6a42                	ld	s4,16(sp)
ffffffffc0202afc:	6aa2                	ld	s5,8(sp)
ffffffffc0202afe:	6121                	addi	sp,sp,64
ffffffffc0202b00:	8082                	ret
        return -E_INVAL;
ffffffffc0202b02:	5575                	li	a0,-3
ffffffffc0202b04:	b7f5                	j	ffffffffc0202af0 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0202b06:	00004697          	auipc	a3,0x4
ffffffffc0202b0a:	10268693          	addi	a3,a3,258 # ffffffffc0206c08 <commands+0xf78>
ffffffffc0202b0e:	00004617          	auipc	a2,0x4
ffffffffc0202b12:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0206528 <commands+0x898>
ffffffffc0202b16:	0b500593          	li	a1,181
ffffffffc0202b1a:	00004517          	auipc	a0,0x4
ffffffffc0202b1e:	06650513          	addi	a0,a0,102 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0202b22:	efcfd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202b26 <do_pgfault>:

int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0202b26:	715d                	addi	sp,sp,-80
ffffffffc0202b28:	e0a2                	sd	s0,64(sp)
ffffffffc0202b2a:	842e                	mv	s0,a1
    int ret = -E_INVAL;
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202b2c:	85b2                	mv	a1,a2
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0202b2e:	fc26                	sd	s1,56(sp)
ffffffffc0202b30:	f84a                	sd	s2,48(sp)
ffffffffc0202b32:	e486                	sd	ra,72(sp)
ffffffffc0202b34:	f44e                	sd	s3,40(sp)
ffffffffc0202b36:	f052                	sd	s4,32(sp)
ffffffffc0202b38:	ec56                	sd	s5,24(sp)
ffffffffc0202b3a:	e85a                	sd	s6,16(sp)
ffffffffc0202b3c:	e45e                	sd	s7,8(sp)
ffffffffc0202b3e:	84b2                	mv	s1,a2
ffffffffc0202b40:	892a                	mv	s2,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202b42:	dd3ff0ef          	jal	ra,ffffffffc0202914 <find_vma>

    pgfault_num++;
ffffffffc0202b46:	000a8797          	auipc	a5,0xa8
ffffffffc0202b4a:	c527a783          	lw	a5,-942(a5) # ffffffffc02aa798 <pgfault_num>
ffffffffc0202b4e:	2785                	addiw	a5,a5,1
ffffffffc0202b50:	000a8717          	auipc	a4,0xa8
ffffffffc0202b54:	c4f72423          	sw	a5,-952(a4) # ffffffffc02aa798 <pgfault_num>
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202b58:	16050b63          	beqz	a0,ffffffffc0202cce <do_pgfault+0x1a8>
ffffffffc0202b5c:	651c                	ld	a5,8(a0)
ffffffffc0202b5e:	16f4e863          	bltu	s1,a5,ffffffffc0202cce <do_pgfault+0x1a8>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }
    switch (error_code & 3) {
ffffffffc0202b62:	00347593          	andi	a1,s0,3
ffffffffc0202b66:	10058863          	beqz	a1,ffffffffc0202c76 <do_pgfault+0x150>
ffffffffc0202b6a:	4785                	li	a5,1
ffffffffc0202b6c:	0ef58363          	beq	a1,a5,ffffffffc0202c52 <do_pgfault+0x12c>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
ffffffffc0202b70:	4d1c                	lw	a5,24(a0)
            goto failed;
        }
    }
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
ffffffffc0202b72:	49d9                	li	s3,22
        if (!(vma->vm_flags & VM_WRITE)) {
ffffffffc0202b74:	0027f713          	andi	a4,a5,2
ffffffffc0202b78:	18070663          	beqz	a4,ffffffffc0202d04 <do_pgfault+0x1de>
    }
    if (vma->vm_flags & VM_READ) {
ffffffffc0202b7c:	0017f713          	andi	a4,a5,1
ffffffffc0202b80:	c319                	beqz	a4,ffffffffc0202b86 <do_pgfault+0x60>
        perm |= PTE_R;
ffffffffc0202b82:	0029e993          	ori	s3,s3,2
    }
    if (vma->vm_flags & VM_EXEC) {
ffffffffc0202b86:	8b91                	andi	a5,a5,4
ffffffffc0202b88:	c399                	beqz	a5,ffffffffc0202b8e <do_pgfault+0x68>
        perm |= PTE_X;
ffffffffc0202b8a:	0089e993          	ori	s3,s3,8
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202b8e:	767d                	lui	a2,0xfffff

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;
    
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202b90:	01893503          	ld	a0,24(s2)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202b94:	8cf1                	and	s1,s1,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202b96:	85a6                	mv	a1,s1
ffffffffc0202b98:	4605                	li	a2,1
ffffffffc0202b9a:	da8fe0ef          	jal	ra,ffffffffc0201142 <get_pte>
ffffffffc0202b9e:	872a                	mv	a4,a0
ffffffffc0202ba0:	16050a63          	beqz	a0,ffffffffc0202d14 <do_pgfault+0x1ee>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) {
ffffffffc0202ba4:	610c                	ld	a1,0(a0)
ffffffffc0202ba6:	c1fd                	beqz	a1,ffffffffc0202c8c <do_pgfault+0x166>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
        if (*ptep & PTE_COW) {
ffffffffc0202ba8:	1005f793          	andi	a5,a1,256
ffffffffc0202bac:	12078a63          	beqz	a5,ffffffffc0202ce0 <do_pgfault+0x1ba>
    if (!(pte & PTE_V))
ffffffffc0202bb0:	0015f793          	andi	a5,a1,1
ffffffffc0202bb4:	16078863          	beqz	a5,ffffffffc0202d24 <do_pgfault+0x1fe>
    if (PPN(pa) >= npage)
ffffffffc0202bb8:	000a8b17          	auipc	s6,0xa8
ffffffffc0202bbc:	bc0b0b13          	addi	s6,s6,-1088 # ffffffffc02aa778 <npage>
ffffffffc0202bc0:	000b3683          	ld	a3,0(s6)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202bc4:	00259793          	slli	a5,a1,0x2
ffffffffc0202bc8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bca:	16d7f963          	bgeu	a5,a3,ffffffffc0202d3c <do_pgfault+0x216>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bce:	000a8b97          	auipc	s7,0xa8
ffffffffc0202bd2:	bb2b8b93          	addi	s7,s7,-1102 # ffffffffc02aa780 <pages>
ffffffffc0202bd6:	000bb403          	ld	s0,0(s7)
ffffffffc0202bda:	00005a97          	auipc	s5,0x5
ffffffffc0202bde:	0feaba83          	ld	s5,254(s5) # ffffffffc0207cd8 <nbase>
ffffffffc0202be2:	415787b3          	sub	a5,a5,s5
ffffffffc0202be6:	079a                	slli	a5,a5,0x6
ffffffffc0202be8:	943e                	add	s0,s0,a5
            struct Page *page = pte2page(*ptep);
            if (page_ref(page) > 1) {
ffffffffc0202bea:	4014                	lw	a3,0(s0)
ffffffffc0202bec:	4785                	li	a5,1
ffffffffc0202bee:	0ad7de63          	bge	a5,a3,ffffffffc0202caa <do_pgfault+0x184>
                struct Page *npage = alloc_page();
ffffffffc0202bf2:	4505                	li	a0,1
ffffffffc0202bf4:	c96fe0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0202bf8:	8a2a                	mv	s4,a0
                if (npage == NULL) {
ffffffffc0202bfa:	0e050b63          	beqz	a0,ffffffffc0202cf0 <do_pgfault+0x1ca>
    return page - pages + nbase;
ffffffffc0202bfe:	000bb603          	ld	a2,0(s7)
    return KADDR(page2pa(page));
ffffffffc0202c02:	577d                	li	a4,-1
ffffffffc0202c04:	000b3683          	ld	a3,0(s6)
    return page - pages + nbase;
ffffffffc0202c08:	40c507b3          	sub	a5,a0,a2
ffffffffc0202c0c:	8799                	srai	a5,a5,0x6
ffffffffc0202c0e:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0202c10:	8331                	srli	a4,a4,0xc
ffffffffc0202c12:	00e7f5b3          	and	a1,a5,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c16:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202c18:	14d5fb63          	bgeu	a1,a3,ffffffffc0202d6e <do_pgfault+0x248>
    return page - pages + nbase;
ffffffffc0202c1c:	8c11                	sub	s0,s0,a2
ffffffffc0202c1e:	8419                	srai	s0,s0,0x6
ffffffffc0202c20:	9456                	add	s0,s0,s5
    return KADDR(page2pa(page));
ffffffffc0202c22:	000a8597          	auipc	a1,0xa8
ffffffffc0202c26:	b6e5b583          	ld	a1,-1170(a1) # ffffffffc02aa790 <va_pa_offset>
ffffffffc0202c2a:	8f61                	and	a4,a4,s0
ffffffffc0202c2c:	00b78533          	add	a0,a5,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c30:	0432                	slli	s0,s0,0xc
    return KADDR(page2pa(page));
ffffffffc0202c32:	12d77163          	bgeu	a4,a3,ffffffffc0202d54 <do_pgfault+0x22e>
                    goto failed;
                }
                memcpy(page2kva(npage), page2kva(page), PGSIZE);
ffffffffc0202c36:	6605                	lui	a2,0x1
ffffffffc0202c38:	95a2                	add	a1,a1,s0
ffffffffc0202c3a:	18d020ef          	jal	ra,ffffffffc02055c6 <memcpy>
                if (page_insert(mm->pgdir, npage, addr, perm) != 0) {
ffffffffc0202c3e:	01893503          	ld	a0,24(s2)
ffffffffc0202c42:	86ce                	mv	a3,s3
ffffffffc0202c44:	8626                	mv	a2,s1
ffffffffc0202c46:	85d2                	mv	a1,s4
ffffffffc0202c48:	bebfe0ef          	jal	ra,ffffffffc0201832 <page_insert>
ffffffffc0202c4c:	e93d                	bnez	a0,ffffffffc0202cc2 <do_pgfault+0x19c>
        } else {
            cprintf("ptep is %x, but no swap support, failed\n",*ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0202c4e:	4501                	li	a0,0
ffffffffc0202c50:	a801                	j	ffffffffc0202c60 <do_pgfault+0x13a>
        cprintf("do_pgfault failed: error code flag = read AND present\n");
ffffffffc0202c52:	00004517          	auipc	a0,0x4
ffffffffc0202c56:	05650513          	addi	a0,a0,86 # ffffffffc0206ca8 <commands+0x1018>
ffffffffc0202c5a:	c86fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202c5e:	5575                	li	a0,-3
failed:
    return ret;
}
ffffffffc0202c60:	60a6                	ld	ra,72(sp)
ffffffffc0202c62:	6406                	ld	s0,64(sp)
ffffffffc0202c64:	74e2                	ld	s1,56(sp)
ffffffffc0202c66:	7942                	ld	s2,48(sp)
ffffffffc0202c68:	79a2                	ld	s3,40(sp)
ffffffffc0202c6a:	7a02                	ld	s4,32(sp)
ffffffffc0202c6c:	6ae2                	ld	s5,24(sp)
ffffffffc0202c6e:	6b42                	ld	s6,16(sp)
ffffffffc0202c70:	6ba2                	ld	s7,8(sp)
ffffffffc0202c72:	6161                	addi	sp,sp,80
ffffffffc0202c74:	8082                	ret
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
ffffffffc0202c76:	4d1c                	lw	a5,24(a0)
ffffffffc0202c78:	0057f713          	andi	a4,a5,5
ffffffffc0202c7c:	cf25                	beqz	a4,ffffffffc0202cf4 <do_pgfault+0x1ce>
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202c7e:	0027f713          	andi	a4,a5,2
    uint32_t perm = PTE_U;
ffffffffc0202c82:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202c84:	ee070ce3          	beqz	a4,ffffffffc0202b7c <do_pgfault+0x56>
        perm |= (PTE_R | PTE_W);
ffffffffc0202c88:	49d9                	li	s3,22
ffffffffc0202c8a:	bdcd                	j	ffffffffc0202b7c <do_pgfault+0x56>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202c8c:	01893503          	ld	a0,24(s2)
ffffffffc0202c90:	864e                	mv	a2,s3
ffffffffc0202c92:	85a6                	mv	a1,s1
ffffffffc0202c94:	b6bff0ef          	jal	ra,ffffffffc02027fe <pgdir_alloc_page>
ffffffffc0202c98:	f95d                	bnez	a0,ffffffffc0202c4e <do_pgfault+0x128>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202c9a:	00004517          	auipc	a0,0x4
ffffffffc0202c9e:	0ce50513          	addi	a0,a0,206 # ffffffffc0206d68 <commands+0x10d8>
ffffffffc0202ca2:	c3efd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202ca6:	5571                	li	a0,-4
            goto failed;
ffffffffc0202ca8:	bf65                	j	ffffffffc0202c60 <do_pgfault+0x13a>
                tlb_invalidate(mm->pgdir, addr);
ffffffffc0202caa:	01893503          	ld	a0,24(s2)
                *ptep &= ~PTE_COW;
ffffffffc0202cae:	eff5f593          	andi	a1,a1,-257
                *ptep |= PTE_W;
ffffffffc0202cb2:	0045e593          	ori	a1,a1,4
ffffffffc0202cb6:	e30c                	sd	a1,0(a4)
                tlb_invalidate(mm->pgdir, addr);
ffffffffc0202cb8:	85a6                	mv	a1,s1
ffffffffc0202cba:	b3fff0ef          	jal	ra,ffffffffc02027f8 <tlb_invalidate>
   ret = 0;
ffffffffc0202cbe:	4501                	li	a0,0
ffffffffc0202cc0:	b745                	j	ffffffffc0202c60 <do_pgfault+0x13a>
                    free_page(npage);
ffffffffc0202cc2:	8552                	mv	a0,s4
ffffffffc0202cc4:	4585                	li	a1,1
ffffffffc0202cc6:	c02fe0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    ret = -E_NO_MEM;
ffffffffc0202cca:	5571                	li	a0,-4
                    goto failed;
ffffffffc0202ccc:	bf51                	j	ffffffffc0202c60 <do_pgfault+0x13a>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202cce:	85a6                	mv	a1,s1
ffffffffc0202cd0:	00004517          	auipc	a0,0x4
ffffffffc0202cd4:	f4850513          	addi	a0,a0,-184 # ffffffffc0206c18 <commands+0xf88>
ffffffffc0202cd8:	c08fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202cdc:	5575                	li	a0,-3
        goto failed;
ffffffffc0202cde:	b749                	j	ffffffffc0202c60 <do_pgfault+0x13a>
            cprintf("ptep is %x, but no swap support, failed\n",*ptep);
ffffffffc0202ce0:	00004517          	auipc	a0,0x4
ffffffffc0202ce4:	0b050513          	addi	a0,a0,176 # ffffffffc0206d90 <commands+0x1100>
ffffffffc0202ce8:	bf8fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202cec:	5571                	li	a0,-4
            goto failed;
ffffffffc0202cee:	bf8d                	j	ffffffffc0202c60 <do_pgfault+0x13a>
    ret = -E_NO_MEM;
ffffffffc0202cf0:	5571                	li	a0,-4
ffffffffc0202cf2:	b7bd                	j	ffffffffc0202c60 <do_pgfault+0x13a>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
ffffffffc0202cf4:	00004517          	auipc	a0,0x4
ffffffffc0202cf8:	fec50513          	addi	a0,a0,-20 # ffffffffc0206ce0 <commands+0x1050>
ffffffffc0202cfc:	be4fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202d00:	5575                	li	a0,-3
            goto failed;
ffffffffc0202d02:	bfb9                	j	ffffffffc0202c60 <do_pgfault+0x13a>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
ffffffffc0202d04:	00004517          	auipc	a0,0x4
ffffffffc0202d08:	f4450513          	addi	a0,a0,-188 # ffffffffc0206c48 <commands+0xfb8>
ffffffffc0202d0c:	bd4fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202d10:	5575                	li	a0,-3
            goto failed;
ffffffffc0202d12:	b7b9                	j	ffffffffc0202c60 <do_pgfault+0x13a>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202d14:	00004517          	auipc	a0,0x4
ffffffffc0202d18:	03450513          	addi	a0,a0,52 # ffffffffc0206d48 <commands+0x10b8>
ffffffffc0202d1c:	bc4fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202d20:	5571                	li	a0,-4
        goto failed;
ffffffffc0202d22:	bf3d                	j	ffffffffc0202c60 <do_pgfault+0x13a>
        panic("pte2page called with invalid pte");
ffffffffc0202d24:	00003617          	auipc	a2,0x3
ffffffffc0202d28:	77460613          	addi	a2,a2,1908 # ffffffffc0206498 <commands+0x808>
ffffffffc0202d2c:	07f00593          	li	a1,127
ffffffffc0202d30:	00003517          	auipc	a0,0x3
ffffffffc0202d34:	75850513          	addi	a0,a0,1880 # ffffffffc0206488 <commands+0x7f8>
ffffffffc0202d38:	ce6fd0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202d3c:	00003617          	auipc	a2,0x3
ffffffffc0202d40:	72c60613          	addi	a2,a2,1836 # ffffffffc0206468 <commands+0x7d8>
ffffffffc0202d44:	06900593          	li	a1,105
ffffffffc0202d48:	00003517          	auipc	a0,0x3
ffffffffc0202d4c:	74050513          	addi	a0,a0,1856 # ffffffffc0206488 <commands+0x7f8>
ffffffffc0202d50:	ccefd0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202d54:	86a2                	mv	a3,s0
ffffffffc0202d56:	00003617          	auipc	a2,0x3
ffffffffc0202d5a:	76a60613          	addi	a2,a2,1898 # ffffffffc02064c0 <commands+0x830>
ffffffffc0202d5e:	07100593          	li	a1,113
ffffffffc0202d62:	00003517          	auipc	a0,0x3
ffffffffc0202d66:	72650513          	addi	a0,a0,1830 # ffffffffc0206488 <commands+0x7f8>
ffffffffc0202d6a:	cb4fd0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0202d6e:	86be                	mv	a3,a5
ffffffffc0202d70:	00003617          	auipc	a2,0x3
ffffffffc0202d74:	75060613          	addi	a2,a2,1872 # ffffffffc02064c0 <commands+0x830>
ffffffffc0202d78:	07100593          	li	a1,113
ffffffffc0202d7c:	00003517          	auipc	a0,0x3
ffffffffc0202d80:	70c50513          	addi	a0,a0,1804 # ffffffffc0206488 <commands+0x7f8>
ffffffffc0202d84:	c9afd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202d88 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0202d88:	7139                	addi	sp,sp,-64
ffffffffc0202d8a:	fc06                	sd	ra,56(sp)
ffffffffc0202d8c:	f822                	sd	s0,48(sp)
ffffffffc0202d8e:	f426                	sd	s1,40(sp)
ffffffffc0202d90:	f04a                	sd	s2,32(sp)
ffffffffc0202d92:	ec4e                	sd	s3,24(sp)
ffffffffc0202d94:	e852                	sd	s4,16(sp)
ffffffffc0202d96:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0202d98:	c52d                	beqz	a0,ffffffffc0202e02 <dup_mmap+0x7a>
ffffffffc0202d9a:	892a                	mv	s2,a0
ffffffffc0202d9c:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0202d9e:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0202da0:	e595                	bnez	a1,ffffffffc0202dcc <dup_mmap+0x44>
ffffffffc0202da2:	a085                	j	ffffffffc0202e02 <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0202da4:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0202da6:	0155b423          	sd	s5,8(a1)
        vma->vm_end = vm_end;
ffffffffc0202daa:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0202dae:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0202db2:	ba3ff0ef          	jal	ra,ffffffffc0202954 <insert_vma_struct>

        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0202db6:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bc8>
ffffffffc0202dba:	fe843603          	ld	a2,-24(s0)
ffffffffc0202dbe:	6c8c                	ld	a1,24(s1)
ffffffffc0202dc0:	01893503          	ld	a0,24(s2)
ffffffffc0202dc4:	4705                	li	a4,1
ffffffffc0202dc6:	fa2ff0ef          	jal	ra,ffffffffc0202568 <copy_range>
ffffffffc0202dca:	e105                	bnez	a0,ffffffffc0202dea <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0202dcc:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0202dce:	02848863          	beq	s1,s0,ffffffffc0202dfe <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202dd2:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0202dd6:	fe843a83          	ld	s5,-24(s0)
ffffffffc0202dda:	ff043a03          	ld	s4,-16(s0)
ffffffffc0202dde:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202de2:	6a0000ef          	jal	ra,ffffffffc0203482 <kmalloc>
ffffffffc0202de6:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc0202de8:	fd55                	bnez	a0,ffffffffc0202da4 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0202dea:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0202dec:	70e2                	ld	ra,56(sp)
ffffffffc0202dee:	7442                	ld	s0,48(sp)
ffffffffc0202df0:	74a2                	ld	s1,40(sp)
ffffffffc0202df2:	7902                	ld	s2,32(sp)
ffffffffc0202df4:	69e2                	ld	s3,24(sp)
ffffffffc0202df6:	6a42                	ld	s4,16(sp)
ffffffffc0202df8:	6aa2                	ld	s5,8(sp)
ffffffffc0202dfa:	6121                	addi	sp,sp,64
ffffffffc0202dfc:	8082                	ret
    return 0;
ffffffffc0202dfe:	4501                	li	a0,0
ffffffffc0202e00:	b7f5                	j	ffffffffc0202dec <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0202e02:	00004697          	auipc	a3,0x4
ffffffffc0202e06:	fbe68693          	addi	a3,a3,-66 # ffffffffc0206dc0 <commands+0x1130>
ffffffffc0202e0a:	00003617          	auipc	a2,0x3
ffffffffc0202e0e:	71e60613          	addi	a2,a2,1822 # ffffffffc0206528 <commands+0x898>
ffffffffc0202e12:	12200593          	li	a1,290
ffffffffc0202e16:	00004517          	auipc	a0,0x4
ffffffffc0202e1a:	d6a50513          	addi	a0,a0,-662 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0202e1e:	c00fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202e22 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0202e22:	1101                	addi	sp,sp,-32
ffffffffc0202e24:	ec06                	sd	ra,24(sp)
ffffffffc0202e26:	e822                	sd	s0,16(sp)
ffffffffc0202e28:	e426                	sd	s1,8(sp)
ffffffffc0202e2a:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202e2c:	c531                	beqz	a0,ffffffffc0202e78 <exit_mmap+0x56>
ffffffffc0202e2e:	591c                	lw	a5,48(a0)
ffffffffc0202e30:	84aa                	mv	s1,a0
ffffffffc0202e32:	e3b9                	bnez	a5,ffffffffc0202e78 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0202e34:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0202e36:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0202e3a:	02850663          	beq	a0,s0,ffffffffc0202e66 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202e3e:	ff043603          	ld	a2,-16(s0)
ffffffffc0202e42:	fe843583          	ld	a1,-24(s0)
ffffffffc0202e46:	854a                	mv	a0,s2
ffffffffc0202e48:	d76fe0ef          	jal	ra,ffffffffc02013be <unmap_range>
ffffffffc0202e4c:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0202e4e:	fe8498e3          	bne	s1,s0,ffffffffc0202e3e <exit_mmap+0x1c>
ffffffffc0202e52:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0202e54:	00848c63          	beq	s1,s0,ffffffffc0202e6c <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202e58:	ff043603          	ld	a2,-16(s0)
ffffffffc0202e5c:	fe843583          	ld	a1,-24(s0)
ffffffffc0202e60:	854a                	mv	a0,s2
ffffffffc0202e62:	ea2fe0ef          	jal	ra,ffffffffc0201504 <exit_range>
ffffffffc0202e66:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0202e68:	fe8498e3          	bne	s1,s0,ffffffffc0202e58 <exit_mmap+0x36>
    }
}
ffffffffc0202e6c:	60e2                	ld	ra,24(sp)
ffffffffc0202e6e:	6442                	ld	s0,16(sp)
ffffffffc0202e70:	64a2                	ld	s1,8(sp)
ffffffffc0202e72:	6902                	ld	s2,0(sp)
ffffffffc0202e74:	6105                	addi	sp,sp,32
ffffffffc0202e76:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202e78:	00004697          	auipc	a3,0x4
ffffffffc0202e7c:	f6868693          	addi	a3,a3,-152 # ffffffffc0206de0 <commands+0x1150>
ffffffffc0202e80:	00003617          	auipc	a2,0x3
ffffffffc0202e84:	6a860613          	addi	a2,a2,1704 # ffffffffc0206528 <commands+0x898>
ffffffffc0202e88:	13b00593          	li	a1,315
ffffffffc0202e8c:	00004517          	auipc	a0,0x4
ffffffffc0202e90:	cf450513          	addi	a0,a0,-780 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0202e94:	b8afd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202e98 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0202e98:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202e9a:	04000513          	li	a0,64
{
ffffffffc0202e9e:	fc06                	sd	ra,56(sp)
ffffffffc0202ea0:	f822                	sd	s0,48(sp)
ffffffffc0202ea2:	f426                	sd	s1,40(sp)
ffffffffc0202ea4:	f04a                	sd	s2,32(sp)
ffffffffc0202ea6:	ec4e                	sd	s3,24(sp)
ffffffffc0202ea8:	e852                	sd	s4,16(sp)
ffffffffc0202eaa:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202eac:	5d6000ef          	jal	ra,ffffffffc0203482 <kmalloc>
    if (mm != NULL)
ffffffffc0202eb0:	2e050663          	beqz	a0,ffffffffc020319c <vmm_init+0x304>
ffffffffc0202eb4:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0202eb6:	e508                	sd	a0,8(a0)
ffffffffc0202eb8:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0202eba:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202ebe:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0202ec2:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0202ec6:	02053423          	sd	zero,40(a0)
ffffffffc0202eca:	02052823          	sw	zero,48(a0)
ffffffffc0202ece:	02053c23          	sd	zero,56(a0)
ffffffffc0202ed2:	03200413          	li	s0,50
ffffffffc0202ed6:	a811                	j	ffffffffc0202eea <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc0202ed8:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202eda:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202edc:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0202ee0:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202ee2:	8526                	mv	a0,s1
ffffffffc0202ee4:	a71ff0ef          	jal	ra,ffffffffc0202954 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0202ee8:	c80d                	beqz	s0,ffffffffc0202f1a <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202eea:	03000513          	li	a0,48
ffffffffc0202eee:	594000ef          	jal	ra,ffffffffc0203482 <kmalloc>
ffffffffc0202ef2:	85aa                	mv	a1,a0
ffffffffc0202ef4:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0202ef8:	f165                	bnez	a0,ffffffffc0202ed8 <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc0202efa:	00004697          	auipc	a3,0x4
ffffffffc0202efe:	07e68693          	addi	a3,a3,126 # ffffffffc0206f78 <commands+0x12e8>
ffffffffc0202f02:	00003617          	auipc	a2,0x3
ffffffffc0202f06:	62660613          	addi	a2,a2,1574 # ffffffffc0206528 <commands+0x898>
ffffffffc0202f0a:	17f00593          	li	a1,383
ffffffffc0202f0e:	00004517          	auipc	a0,0x4
ffffffffc0202f12:	c7250513          	addi	a0,a0,-910 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0202f16:	b08fd0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0202f1a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202f1e:	1f900913          	li	s2,505
ffffffffc0202f22:	a819                	j	ffffffffc0202f38 <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc0202f24:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202f26:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202f28:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202f2c:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202f2e:	8526                	mv	a0,s1
ffffffffc0202f30:	a25ff0ef          	jal	ra,ffffffffc0202954 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202f34:	03240a63          	beq	s0,s2,ffffffffc0202f68 <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202f38:	03000513          	li	a0,48
ffffffffc0202f3c:	546000ef          	jal	ra,ffffffffc0203482 <kmalloc>
ffffffffc0202f40:	85aa                	mv	a1,a0
ffffffffc0202f42:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0202f46:	fd79                	bnez	a0,ffffffffc0202f24 <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0202f48:	00004697          	auipc	a3,0x4
ffffffffc0202f4c:	03068693          	addi	a3,a3,48 # ffffffffc0206f78 <commands+0x12e8>
ffffffffc0202f50:	00003617          	auipc	a2,0x3
ffffffffc0202f54:	5d860613          	addi	a2,a2,1496 # ffffffffc0206528 <commands+0x898>
ffffffffc0202f58:	18600593          	li	a1,390
ffffffffc0202f5c:	00004517          	auipc	a0,0x4
ffffffffc0202f60:	c2450513          	addi	a0,a0,-988 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0202f64:	abafd0ef          	jal	ra,ffffffffc020021e <__panic>
    return listelm->next;
ffffffffc0202f68:	649c                	ld	a5,8(s1)
ffffffffc0202f6a:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0202f6c:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0202f70:	16f48663          	beq	s1,a5,ffffffffc02030dc <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202f74:	fe87b603          	ld	a2,-24(a5)
ffffffffc0202f78:	ffe70693          	addi	a3,a4,-2
ffffffffc0202f7c:	10d61063          	bne	a2,a3,ffffffffc020307c <vmm_init+0x1e4>
ffffffffc0202f80:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202f84:	0ed71c63          	bne	a4,a3,ffffffffc020307c <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0202f88:	0715                	addi	a4,a4,5
ffffffffc0202f8a:	679c                	ld	a5,8(a5)
ffffffffc0202f8c:	feb712e3          	bne	a4,a1,ffffffffc0202f70 <vmm_init+0xd8>
ffffffffc0202f90:	4a1d                	li	s4,7
ffffffffc0202f92:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0202f94:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202f98:	85a2                	mv	a1,s0
ffffffffc0202f9a:	8526                	mv	a0,s1
ffffffffc0202f9c:	979ff0ef          	jal	ra,ffffffffc0202914 <find_vma>
ffffffffc0202fa0:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0202fa2:	16050d63          	beqz	a0,ffffffffc020311c <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0202fa6:	00140593          	addi	a1,s0,1
ffffffffc0202faa:	8526                	mv	a0,s1
ffffffffc0202fac:	969ff0ef          	jal	ra,ffffffffc0202914 <find_vma>
ffffffffc0202fb0:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0202fb2:	14050563          	beqz	a0,ffffffffc02030fc <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0202fb6:	85d2                	mv	a1,s4
ffffffffc0202fb8:	8526                	mv	a0,s1
ffffffffc0202fba:	95bff0ef          	jal	ra,ffffffffc0202914 <find_vma>
        assert(vma3 == NULL);
ffffffffc0202fbe:	16051f63          	bnez	a0,ffffffffc020313c <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0202fc2:	00340593          	addi	a1,s0,3
ffffffffc0202fc6:	8526                	mv	a0,s1
ffffffffc0202fc8:	94dff0ef          	jal	ra,ffffffffc0202914 <find_vma>
        assert(vma4 == NULL);
ffffffffc0202fcc:	1a051863          	bnez	a0,ffffffffc020317c <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0202fd0:	00440593          	addi	a1,s0,4
ffffffffc0202fd4:	8526                	mv	a0,s1
ffffffffc0202fd6:	93fff0ef          	jal	ra,ffffffffc0202914 <find_vma>
        assert(vma5 == NULL);
ffffffffc0202fda:	18051163          	bnez	a0,ffffffffc020315c <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0202fde:	00893783          	ld	a5,8(s2)
ffffffffc0202fe2:	0a879d63          	bne	a5,s0,ffffffffc020309c <vmm_init+0x204>
ffffffffc0202fe6:	01093783          	ld	a5,16(s2)
ffffffffc0202fea:	0b479963          	bne	a5,s4,ffffffffc020309c <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0202fee:	0089b783          	ld	a5,8(s3)
ffffffffc0202ff2:	0c879563          	bne	a5,s0,ffffffffc02030bc <vmm_init+0x224>
ffffffffc0202ff6:	0109b783          	ld	a5,16(s3)
ffffffffc0202ffa:	0d479163          	bne	a5,s4,ffffffffc02030bc <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0202ffe:	0415                	addi	s0,s0,5
ffffffffc0203000:	0a15                	addi	s4,s4,5
ffffffffc0203002:	f9541be3          	bne	s0,s5,ffffffffc0202f98 <vmm_init+0x100>
ffffffffc0203006:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203008:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc020300a:	85a2                	mv	a1,s0
ffffffffc020300c:	8526                	mv	a0,s1
ffffffffc020300e:	907ff0ef          	jal	ra,ffffffffc0202914 <find_vma>
ffffffffc0203012:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0203016:	c90d                	beqz	a0,ffffffffc0203048 <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203018:	6914                	ld	a3,16(a0)
ffffffffc020301a:	6510                	ld	a2,8(a0)
ffffffffc020301c:	00004517          	auipc	a0,0x4
ffffffffc0203020:	ee450513          	addi	a0,a0,-284 # ffffffffc0206f00 <commands+0x1270>
ffffffffc0203024:	8bcfd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203028:	00004697          	auipc	a3,0x4
ffffffffc020302c:	f0068693          	addi	a3,a3,-256 # ffffffffc0206f28 <commands+0x1298>
ffffffffc0203030:	00003617          	auipc	a2,0x3
ffffffffc0203034:	4f860613          	addi	a2,a2,1272 # ffffffffc0206528 <commands+0x898>
ffffffffc0203038:	1ac00593          	li	a1,428
ffffffffc020303c:	00004517          	auipc	a0,0x4
ffffffffc0203040:	b4450513          	addi	a0,a0,-1212 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0203044:	9dafd0ef          	jal	ra,ffffffffc020021e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0203048:	147d                	addi	s0,s0,-1
ffffffffc020304a:	fd2410e3          	bne	s0,s2,ffffffffc020300a <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc020304e:	8526                	mv	a0,s1
ffffffffc0203050:	9d5ff0ef          	jal	ra,ffffffffc0202a24 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203054:	00004517          	auipc	a0,0x4
ffffffffc0203058:	eec50513          	addi	a0,a0,-276 # ffffffffc0206f40 <commands+0x12b0>
ffffffffc020305c:	884fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc0203060:	7442                	ld	s0,48(sp)
ffffffffc0203062:	70e2                	ld	ra,56(sp)
ffffffffc0203064:	74a2                	ld	s1,40(sp)
ffffffffc0203066:	7902                	ld	s2,32(sp)
ffffffffc0203068:	69e2                	ld	s3,24(sp)
ffffffffc020306a:	6a42                	ld	s4,16(sp)
ffffffffc020306c:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020306e:	00004517          	auipc	a0,0x4
ffffffffc0203072:	ef250513          	addi	a0,a0,-270 # ffffffffc0206f60 <commands+0x12d0>
}
ffffffffc0203076:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203078:	868fd06f          	j	ffffffffc02000e0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020307c:	00004697          	auipc	a3,0x4
ffffffffc0203080:	d9c68693          	addi	a3,a3,-612 # ffffffffc0206e18 <commands+0x1188>
ffffffffc0203084:	00003617          	auipc	a2,0x3
ffffffffc0203088:	4a460613          	addi	a2,a2,1188 # ffffffffc0206528 <commands+0x898>
ffffffffc020308c:	19000593          	li	a1,400
ffffffffc0203090:	00004517          	auipc	a0,0x4
ffffffffc0203094:	af050513          	addi	a0,a0,-1296 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0203098:	986fd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc020309c:	00004697          	auipc	a3,0x4
ffffffffc02030a0:	e0468693          	addi	a3,a3,-508 # ffffffffc0206ea0 <commands+0x1210>
ffffffffc02030a4:	00003617          	auipc	a2,0x3
ffffffffc02030a8:	48460613          	addi	a2,a2,1156 # ffffffffc0206528 <commands+0x898>
ffffffffc02030ac:	1a100593          	li	a1,417
ffffffffc02030b0:	00004517          	auipc	a0,0x4
ffffffffc02030b4:	ad050513          	addi	a0,a0,-1328 # ffffffffc0206b80 <commands+0xef0>
ffffffffc02030b8:	966fd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02030bc:	00004697          	auipc	a3,0x4
ffffffffc02030c0:	e1468693          	addi	a3,a3,-492 # ffffffffc0206ed0 <commands+0x1240>
ffffffffc02030c4:	00003617          	auipc	a2,0x3
ffffffffc02030c8:	46460613          	addi	a2,a2,1124 # ffffffffc0206528 <commands+0x898>
ffffffffc02030cc:	1a200593          	li	a1,418
ffffffffc02030d0:	00004517          	auipc	a0,0x4
ffffffffc02030d4:	ab050513          	addi	a0,a0,-1360 # ffffffffc0206b80 <commands+0xef0>
ffffffffc02030d8:	946fd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02030dc:	00004697          	auipc	a3,0x4
ffffffffc02030e0:	d2468693          	addi	a3,a3,-732 # ffffffffc0206e00 <commands+0x1170>
ffffffffc02030e4:	00003617          	auipc	a2,0x3
ffffffffc02030e8:	44460613          	addi	a2,a2,1092 # ffffffffc0206528 <commands+0x898>
ffffffffc02030ec:	18e00593          	li	a1,398
ffffffffc02030f0:	00004517          	auipc	a0,0x4
ffffffffc02030f4:	a9050513          	addi	a0,a0,-1392 # ffffffffc0206b80 <commands+0xef0>
ffffffffc02030f8:	926fd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma2 != NULL);
ffffffffc02030fc:	00004697          	auipc	a3,0x4
ffffffffc0203100:	d6468693          	addi	a3,a3,-668 # ffffffffc0206e60 <commands+0x11d0>
ffffffffc0203104:	00003617          	auipc	a2,0x3
ffffffffc0203108:	42460613          	addi	a2,a2,1060 # ffffffffc0206528 <commands+0x898>
ffffffffc020310c:	19900593          	li	a1,409
ffffffffc0203110:	00004517          	auipc	a0,0x4
ffffffffc0203114:	a7050513          	addi	a0,a0,-1424 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0203118:	906fd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma1 != NULL);
ffffffffc020311c:	00004697          	auipc	a3,0x4
ffffffffc0203120:	d3468693          	addi	a3,a3,-716 # ffffffffc0206e50 <commands+0x11c0>
ffffffffc0203124:	00003617          	auipc	a2,0x3
ffffffffc0203128:	40460613          	addi	a2,a2,1028 # ffffffffc0206528 <commands+0x898>
ffffffffc020312c:	19700593          	li	a1,407
ffffffffc0203130:	00004517          	auipc	a0,0x4
ffffffffc0203134:	a5050513          	addi	a0,a0,-1456 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0203138:	8e6fd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma3 == NULL);
ffffffffc020313c:	00004697          	auipc	a3,0x4
ffffffffc0203140:	d3468693          	addi	a3,a3,-716 # ffffffffc0206e70 <commands+0x11e0>
ffffffffc0203144:	00003617          	auipc	a2,0x3
ffffffffc0203148:	3e460613          	addi	a2,a2,996 # ffffffffc0206528 <commands+0x898>
ffffffffc020314c:	19b00593          	li	a1,411
ffffffffc0203150:	00004517          	auipc	a0,0x4
ffffffffc0203154:	a3050513          	addi	a0,a0,-1488 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0203158:	8c6fd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma5 == NULL);
ffffffffc020315c:	00004697          	auipc	a3,0x4
ffffffffc0203160:	d3468693          	addi	a3,a3,-716 # ffffffffc0206e90 <commands+0x1200>
ffffffffc0203164:	00003617          	auipc	a2,0x3
ffffffffc0203168:	3c460613          	addi	a2,a2,964 # ffffffffc0206528 <commands+0x898>
ffffffffc020316c:	19f00593          	li	a1,415
ffffffffc0203170:	00004517          	auipc	a0,0x4
ffffffffc0203174:	a1050513          	addi	a0,a0,-1520 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0203178:	8a6fd0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma4 == NULL);
ffffffffc020317c:	00004697          	auipc	a3,0x4
ffffffffc0203180:	d0468693          	addi	a3,a3,-764 # ffffffffc0206e80 <commands+0x11f0>
ffffffffc0203184:	00003617          	auipc	a2,0x3
ffffffffc0203188:	3a460613          	addi	a2,a2,932 # ffffffffc0206528 <commands+0x898>
ffffffffc020318c:	19d00593          	li	a1,413
ffffffffc0203190:	00004517          	auipc	a0,0x4
ffffffffc0203194:	9f050513          	addi	a0,a0,-1552 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0203198:	886fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(mm != NULL);
ffffffffc020319c:	00004697          	auipc	a3,0x4
ffffffffc02031a0:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0206c08 <commands+0xf78>
ffffffffc02031a4:	00003617          	auipc	a2,0x3
ffffffffc02031a8:	38460613          	addi	a2,a2,900 # ffffffffc0206528 <commands+0x898>
ffffffffc02031ac:	17700593          	li	a1,375
ffffffffc02031b0:	00004517          	auipc	a0,0x4
ffffffffc02031b4:	9d050513          	addi	a0,a0,-1584 # ffffffffc0206b80 <commands+0xef0>
ffffffffc02031b8:	866fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02031bc <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc02031bc:	7179                	addi	sp,sp,-48
ffffffffc02031be:	f022                	sd	s0,32(sp)
ffffffffc02031c0:	f406                	sd	ra,40(sp)
ffffffffc02031c2:	ec26                	sd	s1,24(sp)
ffffffffc02031c4:	e84a                	sd	s2,16(sp)
ffffffffc02031c6:	e44e                	sd	s3,8(sp)
ffffffffc02031c8:	e052                	sd	s4,0(sp)
ffffffffc02031ca:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc02031cc:	c135                	beqz	a0,ffffffffc0203230 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc02031ce:	002007b7          	lui	a5,0x200
ffffffffc02031d2:	04f5e663          	bltu	a1,a5,ffffffffc020321e <user_mem_check+0x62>
ffffffffc02031d6:	00c584b3          	add	s1,a1,a2
ffffffffc02031da:	0495f263          	bgeu	a1,s1,ffffffffc020321e <user_mem_check+0x62>
ffffffffc02031de:	4785                	li	a5,1
ffffffffc02031e0:	07fe                	slli	a5,a5,0x1f
ffffffffc02031e2:	0297ee63          	bltu	a5,s1,ffffffffc020321e <user_mem_check+0x62>
ffffffffc02031e6:	892a                	mv	s2,a0
ffffffffc02031e8:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc02031ea:	6a05                	lui	s4,0x1
ffffffffc02031ec:	a821                	j	ffffffffc0203204 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02031ee:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc02031f2:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc02031f4:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02031f6:	c685                	beqz	a3,ffffffffc020321e <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc02031f8:	c399                	beqz	a5,ffffffffc02031fe <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc02031fa:	02e46263          	bltu	s0,a4,ffffffffc020321e <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02031fe:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203200:	04947663          	bgeu	s0,s1,ffffffffc020324c <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203204:	85a2                	mv	a1,s0
ffffffffc0203206:	854a                	mv	a0,s2
ffffffffc0203208:	f0cff0ef          	jal	ra,ffffffffc0202914 <find_vma>
ffffffffc020320c:	c909                	beqz	a0,ffffffffc020321e <user_mem_check+0x62>
ffffffffc020320e:	6518                	ld	a4,8(a0)
ffffffffc0203210:	00e46763          	bltu	s0,a4,ffffffffc020321e <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203214:	4d1c                	lw	a5,24(a0)
ffffffffc0203216:	fc099ce3          	bnez	s3,ffffffffc02031ee <user_mem_check+0x32>
ffffffffc020321a:	8b85                	andi	a5,a5,1
ffffffffc020321c:	f3ed                	bnez	a5,ffffffffc02031fe <user_mem_check+0x42>
            return 0;
ffffffffc020321e:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203220:	70a2                	ld	ra,40(sp)
ffffffffc0203222:	7402                	ld	s0,32(sp)
ffffffffc0203224:	64e2                	ld	s1,24(sp)
ffffffffc0203226:	6942                	ld	s2,16(sp)
ffffffffc0203228:	69a2                	ld	s3,8(sp)
ffffffffc020322a:	6a02                	ld	s4,0(sp)
ffffffffc020322c:	6145                	addi	sp,sp,48
ffffffffc020322e:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203230:	c02007b7          	lui	a5,0xc0200
ffffffffc0203234:	4501                	li	a0,0
ffffffffc0203236:	fef5e5e3          	bltu	a1,a5,ffffffffc0203220 <user_mem_check+0x64>
ffffffffc020323a:	962e                	add	a2,a2,a1
ffffffffc020323c:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203220 <user_mem_check+0x64>
ffffffffc0203240:	c8000537          	lui	a0,0xc8000
ffffffffc0203244:	0505                	addi	a0,a0,1
ffffffffc0203246:	00a63533          	sltu	a0,a2,a0
ffffffffc020324a:	bfd9                	j	ffffffffc0203220 <user_mem_check+0x64>
        return 1;
ffffffffc020324c:	4505                	li	a0,1
ffffffffc020324e:	bfc9                	j	ffffffffc0203220 <user_mem_check+0x64>

ffffffffc0203250 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0203250:	c94d                	beqz	a0,ffffffffc0203302 <slob_free+0xb2>
{
ffffffffc0203252:	1141                	addi	sp,sp,-16
ffffffffc0203254:	e022                	sd	s0,0(sp)
ffffffffc0203256:	e406                	sd	ra,8(sp)
ffffffffc0203258:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc020325a:	e9c1                	bnez	a1,ffffffffc02032ea <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020325c:	100027f3          	csrr	a5,sstatus
ffffffffc0203260:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203262:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203264:	ebd9                	bnez	a5,ffffffffc02032fa <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203266:	000a3617          	auipc	a2,0xa3
ffffffffc020326a:	09a60613          	addi	a2,a2,154 # ffffffffc02a6300 <slobfree>
ffffffffc020326e:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203270:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203272:	679c                	ld	a5,8(a5)
ffffffffc0203274:	02877a63          	bgeu	a4,s0,ffffffffc02032a8 <slob_free+0x58>
ffffffffc0203278:	00f46463          	bltu	s0,a5,ffffffffc0203280 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020327c:	fef76ae3          	bltu	a4,a5,ffffffffc0203270 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0203280:	400c                	lw	a1,0(s0)
ffffffffc0203282:	00459693          	slli	a3,a1,0x4
ffffffffc0203286:	96a2                	add	a3,a3,s0
ffffffffc0203288:	02d78a63          	beq	a5,a3,ffffffffc02032bc <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc020328c:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc020328e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0203290:	00469793          	slli	a5,a3,0x4
ffffffffc0203294:	97ba                	add	a5,a5,a4
ffffffffc0203296:	02f40e63          	beq	s0,a5,ffffffffc02032d2 <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc020329a:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc020329c:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc020329e:	e129                	bnez	a0,ffffffffc02032e0 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02032a0:	60a2                	ld	ra,8(sp)
ffffffffc02032a2:	6402                	ld	s0,0(sp)
ffffffffc02032a4:	0141                	addi	sp,sp,16
ffffffffc02032a6:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02032a8:	fcf764e3          	bltu	a4,a5,ffffffffc0203270 <slob_free+0x20>
ffffffffc02032ac:	fcf472e3          	bgeu	s0,a5,ffffffffc0203270 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc02032b0:	400c                	lw	a1,0(s0)
ffffffffc02032b2:	00459693          	slli	a3,a1,0x4
ffffffffc02032b6:	96a2                	add	a3,a3,s0
ffffffffc02032b8:	fcd79ae3          	bne	a5,a3,ffffffffc020328c <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc02032bc:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02032be:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc02032c0:	9db5                	addw	a1,a1,a3
ffffffffc02032c2:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc02032c4:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02032c6:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc02032c8:	00469793          	slli	a5,a3,0x4
ffffffffc02032cc:	97ba                	add	a5,a5,a4
ffffffffc02032ce:	fcf416e3          	bne	s0,a5,ffffffffc020329a <slob_free+0x4a>
		cur->units += b->units;
ffffffffc02032d2:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc02032d4:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc02032d6:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc02032d8:	9ebd                	addw	a3,a3,a5
ffffffffc02032da:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc02032dc:	e70c                	sd	a1,8(a4)
ffffffffc02032de:	d169                	beqz	a0,ffffffffc02032a0 <slob_free+0x50>
}
ffffffffc02032e0:	6402                	ld	s0,0(sp)
ffffffffc02032e2:	60a2                	ld	ra,8(sp)
ffffffffc02032e4:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02032e6:	ecefd06f          	j	ffffffffc02009b4 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc02032ea:	25bd                	addiw	a1,a1,15
ffffffffc02032ec:	8191                	srli	a1,a1,0x4
ffffffffc02032ee:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02032f0:	100027f3          	csrr	a5,sstatus
ffffffffc02032f4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02032f6:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02032f8:	d7bd                	beqz	a5,ffffffffc0203266 <slob_free+0x16>
        intr_disable();
ffffffffc02032fa:	ec0fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc02032fe:	4505                	li	a0,1
ffffffffc0203300:	b79d                	j	ffffffffc0203266 <slob_free+0x16>
ffffffffc0203302:	8082                	ret

ffffffffc0203304 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0203304:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0203306:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0203308:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020330c:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc020330e:	d7dfd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
	if (!page)
ffffffffc0203312:	c91d                	beqz	a0,ffffffffc0203348 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0203314:	000a7697          	auipc	a3,0xa7
ffffffffc0203318:	46c6b683          	ld	a3,1132(a3) # ffffffffc02aa780 <pages>
ffffffffc020331c:	8d15                	sub	a0,a0,a3
ffffffffc020331e:	8519                	srai	a0,a0,0x6
ffffffffc0203320:	00005697          	auipc	a3,0x5
ffffffffc0203324:	9b86b683          	ld	a3,-1608(a3) # ffffffffc0207cd8 <nbase>
ffffffffc0203328:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc020332a:	00c51793          	slli	a5,a0,0xc
ffffffffc020332e:	83b1                	srli	a5,a5,0xc
ffffffffc0203330:	000a7717          	auipc	a4,0xa7
ffffffffc0203334:	44873703          	ld	a4,1096(a4) # ffffffffc02aa778 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0203338:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc020333a:	00e7fa63          	bgeu	a5,a4,ffffffffc020334e <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc020333e:	000a7697          	auipc	a3,0xa7
ffffffffc0203342:	4526b683          	ld	a3,1106(a3) # ffffffffc02aa790 <va_pa_offset>
ffffffffc0203346:	9536                	add	a0,a0,a3
}
ffffffffc0203348:	60a2                	ld	ra,8(sp)
ffffffffc020334a:	0141                	addi	sp,sp,16
ffffffffc020334c:	8082                	ret
ffffffffc020334e:	86aa                	mv	a3,a0
ffffffffc0203350:	00003617          	auipc	a2,0x3
ffffffffc0203354:	17060613          	addi	a2,a2,368 # ffffffffc02064c0 <commands+0x830>
ffffffffc0203358:	07100593          	li	a1,113
ffffffffc020335c:	00003517          	auipc	a0,0x3
ffffffffc0203360:	12c50513          	addi	a0,a0,300 # ffffffffc0206488 <commands+0x7f8>
ffffffffc0203364:	ebbfc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203368 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0203368:	1101                	addi	sp,sp,-32
ffffffffc020336a:	ec06                	sd	ra,24(sp)
ffffffffc020336c:	e822                	sd	s0,16(sp)
ffffffffc020336e:	e426                	sd	s1,8(sp)
ffffffffc0203370:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0203372:	01050713          	addi	a4,a0,16
ffffffffc0203376:	6785                	lui	a5,0x1
ffffffffc0203378:	0cf77363          	bgeu	a4,a5,ffffffffc020343e <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc020337c:	00f50493          	addi	s1,a0,15
ffffffffc0203380:	8091                	srli	s1,s1,0x4
ffffffffc0203382:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203384:	10002673          	csrr	a2,sstatus
ffffffffc0203388:	8a09                	andi	a2,a2,2
ffffffffc020338a:	e25d                	bnez	a2,ffffffffc0203430 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc020338c:	000a3917          	auipc	s2,0xa3
ffffffffc0203390:	f7490913          	addi	s2,s2,-140 # ffffffffc02a6300 <slobfree>
ffffffffc0203394:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0203398:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc020339a:	4398                	lw	a4,0(a5)
ffffffffc020339c:	08975e63          	bge	a4,s1,ffffffffc0203438 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc02033a0:	00f68b63          	beq	a3,a5,ffffffffc02033b6 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02033a4:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc02033a6:	4018                	lw	a4,0(s0)
ffffffffc02033a8:	02975a63          	bge	a4,s1,ffffffffc02033dc <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc02033ac:	00093683          	ld	a3,0(s2)
ffffffffc02033b0:	87a2                	mv	a5,s0
ffffffffc02033b2:	fef699e3          	bne	a3,a5,ffffffffc02033a4 <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc02033b6:	ee31                	bnez	a2,ffffffffc0203412 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02033b8:	4501                	li	a0,0
ffffffffc02033ba:	f4bff0ef          	jal	ra,ffffffffc0203304 <__slob_get_free_pages.constprop.0>
ffffffffc02033be:	842a                	mv	s0,a0
			if (!cur)
ffffffffc02033c0:	cd05                	beqz	a0,ffffffffc02033f8 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc02033c2:	6585                	lui	a1,0x1
ffffffffc02033c4:	e8dff0ef          	jal	ra,ffffffffc0203250 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02033c8:	10002673          	csrr	a2,sstatus
ffffffffc02033cc:	8a09                	andi	a2,a2,2
ffffffffc02033ce:	ee05                	bnez	a2,ffffffffc0203406 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc02033d0:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02033d4:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc02033d6:	4018                	lw	a4,0(s0)
ffffffffc02033d8:	fc974ae3          	blt	a4,s1,ffffffffc02033ac <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc02033dc:	04e48763          	beq	s1,a4,ffffffffc020342a <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc02033e0:	00449693          	slli	a3,s1,0x4
ffffffffc02033e4:	96a2                	add	a3,a3,s0
ffffffffc02033e6:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02033e8:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc02033ea:	9f05                	subw	a4,a4,s1
ffffffffc02033ec:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02033ee:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02033f0:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc02033f2:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc02033f6:	e20d                	bnez	a2,ffffffffc0203418 <slob_alloc.constprop.0+0xb0>
}
ffffffffc02033f8:	60e2                	ld	ra,24(sp)
ffffffffc02033fa:	8522                	mv	a0,s0
ffffffffc02033fc:	6442                	ld	s0,16(sp)
ffffffffc02033fe:	64a2                	ld	s1,8(sp)
ffffffffc0203400:	6902                	ld	s2,0(sp)
ffffffffc0203402:	6105                	addi	sp,sp,32
ffffffffc0203404:	8082                	ret
        intr_disable();
ffffffffc0203406:	db4fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
			cur = slobfree;
ffffffffc020340a:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc020340e:	4605                	li	a2,1
ffffffffc0203410:	b7d1                	j	ffffffffc02033d4 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0203412:	da2fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203416:	b74d                	j	ffffffffc02033b8 <slob_alloc.constprop.0+0x50>
ffffffffc0203418:	d9cfd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
}
ffffffffc020341c:	60e2                	ld	ra,24(sp)
ffffffffc020341e:	8522                	mv	a0,s0
ffffffffc0203420:	6442                	ld	s0,16(sp)
ffffffffc0203422:	64a2                	ld	s1,8(sp)
ffffffffc0203424:	6902                	ld	s2,0(sp)
ffffffffc0203426:	6105                	addi	sp,sp,32
ffffffffc0203428:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc020342a:	6418                	ld	a4,8(s0)
ffffffffc020342c:	e798                	sd	a4,8(a5)
ffffffffc020342e:	b7d1                	j	ffffffffc02033f2 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0203430:	d8afd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc0203434:	4605                	li	a2,1
ffffffffc0203436:	bf99                	j	ffffffffc020338c <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0203438:	843e                	mv	s0,a5
ffffffffc020343a:	87b6                	mv	a5,a3
ffffffffc020343c:	b745                	j	ffffffffc02033dc <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc020343e:	00004697          	auipc	a3,0x4
ffffffffc0203442:	b4a68693          	addi	a3,a3,-1206 # ffffffffc0206f88 <commands+0x12f8>
ffffffffc0203446:	00003617          	auipc	a2,0x3
ffffffffc020344a:	0e260613          	addi	a2,a2,226 # ffffffffc0206528 <commands+0x898>
ffffffffc020344e:	06300593          	li	a1,99
ffffffffc0203452:	00004517          	auipc	a0,0x4
ffffffffc0203456:	b5650513          	addi	a0,a0,-1194 # ffffffffc0206fa8 <commands+0x1318>
ffffffffc020345a:	dc5fc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020345e <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc020345e:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0203460:	00004517          	auipc	a0,0x4
ffffffffc0203464:	b6050513          	addi	a0,a0,-1184 # ffffffffc0206fc0 <commands+0x1330>
{
ffffffffc0203468:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc020346a:	c77fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc020346e:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203470:	00004517          	auipc	a0,0x4
ffffffffc0203474:	b6850513          	addi	a0,a0,-1176 # ffffffffc0206fd8 <commands+0x1348>
}
ffffffffc0203478:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc020347a:	c67fc06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc020347e <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc020347e:	4501                	li	a0,0
ffffffffc0203480:	8082                	ret

ffffffffc0203482 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0203482:	1101                	addi	sp,sp,-32
ffffffffc0203484:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0203486:	6905                	lui	s2,0x1
{
ffffffffc0203488:	e822                	sd	s0,16(sp)
ffffffffc020348a:	ec06                	sd	ra,24(sp)
ffffffffc020348c:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc020348e:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bc9>
{
ffffffffc0203492:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0203494:	04a7f963          	bgeu	a5,a0,ffffffffc02034e6 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0203498:	4561                	li	a0,24
ffffffffc020349a:	ecfff0ef          	jal	ra,ffffffffc0203368 <slob_alloc.constprop.0>
ffffffffc020349e:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02034a0:	c929                	beqz	a0,ffffffffc02034f2 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc02034a2:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02034a6:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc02034a8:	00f95763          	bge	s2,a5,ffffffffc02034b6 <kmalloc+0x34>
ffffffffc02034ac:	6705                	lui	a4,0x1
ffffffffc02034ae:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02034b0:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc02034b2:	fef74ee3          	blt	a4,a5,ffffffffc02034ae <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02034b6:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02034b8:	e4dff0ef          	jal	ra,ffffffffc0203304 <__slob_get_free_pages.constprop.0>
ffffffffc02034bc:	e488                	sd	a0,8(s1)
ffffffffc02034be:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc02034c0:	c525                	beqz	a0,ffffffffc0203528 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02034c2:	100027f3          	csrr	a5,sstatus
ffffffffc02034c6:	8b89                	andi	a5,a5,2
ffffffffc02034c8:	ef8d                	bnez	a5,ffffffffc0203502 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc02034ca:	000a7797          	auipc	a5,0xa7
ffffffffc02034ce:	2d678793          	addi	a5,a5,726 # ffffffffc02aa7a0 <bigblocks>
ffffffffc02034d2:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02034d4:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02034d6:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc02034d8:	60e2                	ld	ra,24(sp)
ffffffffc02034da:	8522                	mv	a0,s0
ffffffffc02034dc:	6442                	ld	s0,16(sp)
ffffffffc02034de:	64a2                	ld	s1,8(sp)
ffffffffc02034e0:	6902                	ld	s2,0(sp)
ffffffffc02034e2:	6105                	addi	sp,sp,32
ffffffffc02034e4:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02034e6:	0541                	addi	a0,a0,16
ffffffffc02034e8:	e81ff0ef          	jal	ra,ffffffffc0203368 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc02034ec:	01050413          	addi	s0,a0,16
ffffffffc02034f0:	f565                	bnez	a0,ffffffffc02034d8 <kmalloc+0x56>
ffffffffc02034f2:	4401                	li	s0,0
}
ffffffffc02034f4:	60e2                	ld	ra,24(sp)
ffffffffc02034f6:	8522                	mv	a0,s0
ffffffffc02034f8:	6442                	ld	s0,16(sp)
ffffffffc02034fa:	64a2                	ld	s1,8(sp)
ffffffffc02034fc:	6902                	ld	s2,0(sp)
ffffffffc02034fe:	6105                	addi	sp,sp,32
ffffffffc0203500:	8082                	ret
        intr_disable();
ffffffffc0203502:	cb8fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
		bb->next = bigblocks;
ffffffffc0203506:	000a7797          	auipc	a5,0xa7
ffffffffc020350a:	29a78793          	addi	a5,a5,666 # ffffffffc02aa7a0 <bigblocks>
ffffffffc020350e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0203510:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0203512:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0203514:	ca0fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
		return bb->pages;
ffffffffc0203518:	6480                	ld	s0,8(s1)
}
ffffffffc020351a:	60e2                	ld	ra,24(sp)
ffffffffc020351c:	64a2                	ld	s1,8(sp)
ffffffffc020351e:	8522                	mv	a0,s0
ffffffffc0203520:	6442                	ld	s0,16(sp)
ffffffffc0203522:	6902                	ld	s2,0(sp)
ffffffffc0203524:	6105                	addi	sp,sp,32
ffffffffc0203526:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0203528:	45e1                	li	a1,24
ffffffffc020352a:	8526                	mv	a0,s1
ffffffffc020352c:	d25ff0ef          	jal	ra,ffffffffc0203250 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0203530:	b765                	j	ffffffffc02034d8 <kmalloc+0x56>

ffffffffc0203532 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0203532:	c179                	beqz	a0,ffffffffc02035f8 <kfree+0xc6>
{
ffffffffc0203534:	1101                	addi	sp,sp,-32
ffffffffc0203536:	e822                	sd	s0,16(sp)
ffffffffc0203538:	ec06                	sd	ra,24(sp)
ffffffffc020353a:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc020353c:	03451793          	slli	a5,a0,0x34
ffffffffc0203540:	842a                	mv	s0,a0
ffffffffc0203542:	e7c1                	bnez	a5,ffffffffc02035ca <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203544:	100027f3          	csrr	a5,sstatus
ffffffffc0203548:	8b89                	andi	a5,a5,2
ffffffffc020354a:	ebc9                	bnez	a5,ffffffffc02035dc <kfree+0xaa>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc020354c:	000a7797          	auipc	a5,0xa7
ffffffffc0203550:	2547b783          	ld	a5,596(a5) # ffffffffc02aa7a0 <bigblocks>
    return 0;
ffffffffc0203554:	4601                	li	a2,0
ffffffffc0203556:	cbb5                	beqz	a5,ffffffffc02035ca <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0203558:	000a7697          	auipc	a3,0xa7
ffffffffc020355c:	24868693          	addi	a3,a3,584 # ffffffffc02aa7a0 <bigblocks>
ffffffffc0203560:	a021                	j	ffffffffc0203568 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0203562:	01048693          	addi	a3,s1,16
ffffffffc0203566:	c3ad                	beqz	a5,ffffffffc02035c8 <kfree+0x96>
		{
			if (bb->pages == block)
ffffffffc0203568:	6798                	ld	a4,8(a5)
ffffffffc020356a:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc020356c:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc020356e:	fe871ae3          	bne	a4,s0,ffffffffc0203562 <kfree+0x30>
				*last = bb->next;
ffffffffc0203572:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0203574:	ee3d                	bnez	a2,ffffffffc02035f2 <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc0203576:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc020357a:	4098                	lw	a4,0(s1)
ffffffffc020357c:	08f46b63          	bltu	s0,a5,ffffffffc0203612 <kfree+0xe0>
ffffffffc0203580:	000a7697          	auipc	a3,0xa7
ffffffffc0203584:	2106b683          	ld	a3,528(a3) # ffffffffc02aa790 <va_pa_offset>
ffffffffc0203588:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc020358a:	8031                	srli	s0,s0,0xc
ffffffffc020358c:	000a7797          	auipc	a5,0xa7
ffffffffc0203590:	1ec7b783          	ld	a5,492(a5) # ffffffffc02aa778 <npage>
ffffffffc0203594:	06f47363          	bgeu	s0,a5,ffffffffc02035fa <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203598:	00004517          	auipc	a0,0x4
ffffffffc020359c:	74053503          	ld	a0,1856(a0) # ffffffffc0207cd8 <nbase>
ffffffffc02035a0:	8c09                	sub	s0,s0,a0
ffffffffc02035a2:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc02035a4:	000a7517          	auipc	a0,0xa7
ffffffffc02035a8:	1dc53503          	ld	a0,476(a0) # ffffffffc02aa780 <pages>
ffffffffc02035ac:	4585                	li	a1,1
ffffffffc02035ae:	9522                	add	a0,a0,s0
ffffffffc02035b0:	00e595bb          	sllw	a1,a1,a4
ffffffffc02035b4:	b15fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02035b8:	6442                	ld	s0,16(sp)
ffffffffc02035ba:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02035bc:	8526                	mv	a0,s1
}
ffffffffc02035be:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02035c0:	45e1                	li	a1,24
}
ffffffffc02035c2:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02035c4:	c8dff06f          	j	ffffffffc0203250 <slob_free>
ffffffffc02035c8:	e215                	bnez	a2,ffffffffc02035ec <kfree+0xba>
ffffffffc02035ca:	ff040513          	addi	a0,s0,-16
}
ffffffffc02035ce:	6442                	ld	s0,16(sp)
ffffffffc02035d0:	60e2                	ld	ra,24(sp)
ffffffffc02035d2:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02035d4:	4581                	li	a1,0
}
ffffffffc02035d6:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02035d8:	c79ff06f          	j	ffffffffc0203250 <slob_free>
        intr_disable();
ffffffffc02035dc:	bdefd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc02035e0:	000a7797          	auipc	a5,0xa7
ffffffffc02035e4:	1c07b783          	ld	a5,448(a5) # ffffffffc02aa7a0 <bigblocks>
        return 1;
ffffffffc02035e8:	4605                	li	a2,1
ffffffffc02035ea:	f7bd                	bnez	a5,ffffffffc0203558 <kfree+0x26>
        intr_enable();
ffffffffc02035ec:	bc8fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc02035f0:	bfe9                	j	ffffffffc02035ca <kfree+0x98>
ffffffffc02035f2:	bc2fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc02035f6:	b741                	j	ffffffffc0203576 <kfree+0x44>
ffffffffc02035f8:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc02035fa:	00003617          	auipc	a2,0x3
ffffffffc02035fe:	e6e60613          	addi	a2,a2,-402 # ffffffffc0206468 <commands+0x7d8>
ffffffffc0203602:	06900593          	li	a1,105
ffffffffc0203606:	00003517          	auipc	a0,0x3
ffffffffc020360a:	e8250513          	addi	a0,a0,-382 # ffffffffc0206488 <commands+0x7f8>
ffffffffc020360e:	c11fc0ef          	jal	ra,ffffffffc020021e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0203612:	86a2                	mv	a3,s0
ffffffffc0203614:	00003617          	auipc	a2,0x3
ffffffffc0203618:	fbc60613          	addi	a2,a2,-68 # ffffffffc02065d0 <commands+0x940>
ffffffffc020361c:	07700593          	li	a1,119
ffffffffc0203620:	00003517          	auipc	a0,0x3
ffffffffc0203624:	e6850513          	addi	a0,a0,-408 # ffffffffc0206488 <commands+0x7f8>
ffffffffc0203628:	bf7fc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020362c <default_init>:
    elm->prev = elm->next = elm;
ffffffffc020362c:	000a3797          	auipc	a5,0xa3
ffffffffc0203630:	0e478793          	addi	a5,a5,228 # ffffffffc02a6710 <free_area>
ffffffffc0203634:	e79c                	sd	a5,8(a5)
ffffffffc0203636:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0203638:	0007a823          	sw	zero,16(a5)
}
ffffffffc020363c:	8082                	ret

ffffffffc020363e <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc020363e:	000a3517          	auipc	a0,0xa3
ffffffffc0203642:	0e256503          	lwu	a0,226(a0) # ffffffffc02a6720 <free_area+0x10>
ffffffffc0203646:	8082                	ret

ffffffffc0203648 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0203648:	715d                	addi	sp,sp,-80
ffffffffc020364a:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc020364c:	000a3417          	auipc	s0,0xa3
ffffffffc0203650:	0c440413          	addi	s0,s0,196 # ffffffffc02a6710 <free_area>
ffffffffc0203654:	641c                	ld	a5,8(s0)
ffffffffc0203656:	e486                	sd	ra,72(sp)
ffffffffc0203658:	fc26                	sd	s1,56(sp)
ffffffffc020365a:	f84a                	sd	s2,48(sp)
ffffffffc020365c:	f44e                	sd	s3,40(sp)
ffffffffc020365e:	f052                	sd	s4,32(sp)
ffffffffc0203660:	ec56                	sd	s5,24(sp)
ffffffffc0203662:	e85a                	sd	s6,16(sp)
ffffffffc0203664:	e45e                	sd	s7,8(sp)
ffffffffc0203666:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0203668:	2a878d63          	beq	a5,s0,ffffffffc0203922 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc020366c:	4481                	li	s1,0
ffffffffc020366e:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203670:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203674:	8b09                	andi	a4,a4,2
ffffffffc0203676:	2a070a63          	beqz	a4,ffffffffc020392a <default_check+0x2e2>
        count++, total += p->property;
ffffffffc020367a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020367e:	679c                	ld	a5,8(a5)
ffffffffc0203680:	2905                	addiw	s2,s2,1
ffffffffc0203682:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0203684:	fe8796e3          	bne	a5,s0,ffffffffc0203670 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0203688:	89a6                	mv	s3,s1
ffffffffc020368a:	a7ffd0ef          	jal	ra,ffffffffc0201108 <nr_free_pages>
ffffffffc020368e:	6f351e63          	bne	a0,s3,ffffffffc0203d8a <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203692:	4505                	li	a0,1
ffffffffc0203694:	9f7fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0203698:	8aaa                	mv	s5,a0
ffffffffc020369a:	42050863          	beqz	a0,ffffffffc0203aca <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020369e:	4505                	li	a0,1
ffffffffc02036a0:	9ebfd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02036a4:	89aa                	mv	s3,a0
ffffffffc02036a6:	70050263          	beqz	a0,ffffffffc0203daa <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02036aa:	4505                	li	a0,1
ffffffffc02036ac:	9dffd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02036b0:	8a2a                	mv	s4,a0
ffffffffc02036b2:	48050c63          	beqz	a0,ffffffffc0203b4a <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02036b6:	293a8a63          	beq	s5,s3,ffffffffc020394a <default_check+0x302>
ffffffffc02036ba:	28aa8863          	beq	s5,a0,ffffffffc020394a <default_check+0x302>
ffffffffc02036be:	28a98663          	beq	s3,a0,ffffffffc020394a <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02036c2:	000aa783          	lw	a5,0(s5)
ffffffffc02036c6:	2a079263          	bnez	a5,ffffffffc020396a <default_check+0x322>
ffffffffc02036ca:	0009a783          	lw	a5,0(s3)
ffffffffc02036ce:	28079e63          	bnez	a5,ffffffffc020396a <default_check+0x322>
ffffffffc02036d2:	411c                	lw	a5,0(a0)
ffffffffc02036d4:	28079b63          	bnez	a5,ffffffffc020396a <default_check+0x322>
    return page - pages + nbase;
ffffffffc02036d8:	000a7797          	auipc	a5,0xa7
ffffffffc02036dc:	0a87b783          	ld	a5,168(a5) # ffffffffc02aa780 <pages>
ffffffffc02036e0:	40fa8733          	sub	a4,s5,a5
ffffffffc02036e4:	00004617          	auipc	a2,0x4
ffffffffc02036e8:	5f463603          	ld	a2,1524(a2) # ffffffffc0207cd8 <nbase>
ffffffffc02036ec:	8719                	srai	a4,a4,0x6
ffffffffc02036ee:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02036f0:	000a7697          	auipc	a3,0xa7
ffffffffc02036f4:	0886b683          	ld	a3,136(a3) # ffffffffc02aa778 <npage>
ffffffffc02036f8:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02036fa:	0732                	slli	a4,a4,0xc
ffffffffc02036fc:	28d77763          	bgeu	a4,a3,ffffffffc020398a <default_check+0x342>
    return page - pages + nbase;
ffffffffc0203700:	40f98733          	sub	a4,s3,a5
ffffffffc0203704:	8719                	srai	a4,a4,0x6
ffffffffc0203706:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203708:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020370a:	4cd77063          	bgeu	a4,a3,ffffffffc0203bca <default_check+0x582>
    return page - pages + nbase;
ffffffffc020370e:	40f507b3          	sub	a5,a0,a5
ffffffffc0203712:	8799                	srai	a5,a5,0x6
ffffffffc0203714:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203716:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203718:	30d7f963          	bgeu	a5,a3,ffffffffc0203a2a <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc020371c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020371e:	00043c03          	ld	s8,0(s0)
ffffffffc0203722:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0203726:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc020372a:	e400                	sd	s0,8(s0)
ffffffffc020372c:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc020372e:	000a3797          	auipc	a5,0xa3
ffffffffc0203732:	fe07a923          	sw	zero,-14(a5) # ffffffffc02a6720 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0203736:	955fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc020373a:	2c051863          	bnez	a0,ffffffffc0203a0a <default_check+0x3c2>
    free_page(p0);
ffffffffc020373e:	4585                	li	a1,1
ffffffffc0203740:	8556                	mv	a0,s5
ffffffffc0203742:	987fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_page(p1);
ffffffffc0203746:	4585                	li	a1,1
ffffffffc0203748:	854e                	mv	a0,s3
ffffffffc020374a:	97ffd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_page(p2);
ffffffffc020374e:	4585                	li	a1,1
ffffffffc0203750:	8552                	mv	a0,s4
ffffffffc0203752:	977fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    assert(nr_free == 3);
ffffffffc0203756:	4818                	lw	a4,16(s0)
ffffffffc0203758:	478d                	li	a5,3
ffffffffc020375a:	28f71863          	bne	a4,a5,ffffffffc02039ea <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020375e:	4505                	li	a0,1
ffffffffc0203760:	92bfd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0203764:	89aa                	mv	s3,a0
ffffffffc0203766:	26050263          	beqz	a0,ffffffffc02039ca <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020376a:	4505                	li	a0,1
ffffffffc020376c:	91ffd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0203770:	8aaa                	mv	s5,a0
ffffffffc0203772:	3a050c63          	beqz	a0,ffffffffc0203b2a <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203776:	4505                	li	a0,1
ffffffffc0203778:	913fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc020377c:	8a2a                	mv	s4,a0
ffffffffc020377e:	38050663          	beqz	a0,ffffffffc0203b0a <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0203782:	4505                	li	a0,1
ffffffffc0203784:	907fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0203788:	36051163          	bnez	a0,ffffffffc0203aea <default_check+0x4a2>
    free_page(p0);
ffffffffc020378c:	4585                	li	a1,1
ffffffffc020378e:	854e                	mv	a0,s3
ffffffffc0203790:	939fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0203794:	641c                	ld	a5,8(s0)
ffffffffc0203796:	20878a63          	beq	a5,s0,ffffffffc02039aa <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc020379a:	4505                	li	a0,1
ffffffffc020379c:	8effd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02037a0:	30a99563          	bne	s3,a0,ffffffffc0203aaa <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc02037a4:	4505                	li	a0,1
ffffffffc02037a6:	8e5fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02037aa:	2e051063          	bnez	a0,ffffffffc0203a8a <default_check+0x442>
    assert(nr_free == 0);
ffffffffc02037ae:	481c                	lw	a5,16(s0)
ffffffffc02037b0:	2a079d63          	bnez	a5,ffffffffc0203a6a <default_check+0x422>
    free_page(p);
ffffffffc02037b4:	854e                	mv	a0,s3
ffffffffc02037b6:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02037b8:	01843023          	sd	s8,0(s0)
ffffffffc02037bc:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02037c0:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02037c4:	905fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_page(p1);
ffffffffc02037c8:	4585                	li	a1,1
ffffffffc02037ca:	8556                	mv	a0,s5
ffffffffc02037cc:	8fdfd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_page(p2);
ffffffffc02037d0:	4585                	li	a1,1
ffffffffc02037d2:	8552                	mv	a0,s4
ffffffffc02037d4:	8f5fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02037d8:	4515                	li	a0,5
ffffffffc02037da:	8b1fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02037de:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02037e0:	26050563          	beqz	a0,ffffffffc0203a4a <default_check+0x402>
ffffffffc02037e4:	651c                	ld	a5,8(a0)
ffffffffc02037e6:	8385                	srli	a5,a5,0x1
ffffffffc02037e8:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02037ea:	54079063          	bnez	a5,ffffffffc0203d2a <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02037ee:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02037f0:	00043b03          	ld	s6,0(s0)
ffffffffc02037f4:	00843a83          	ld	s5,8(s0)
ffffffffc02037f8:	e000                	sd	s0,0(s0)
ffffffffc02037fa:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02037fc:	88ffd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0203800:	50051563          	bnez	a0,ffffffffc0203d0a <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0203804:	08098a13          	addi	s4,s3,128
ffffffffc0203808:	8552                	mv	a0,s4
ffffffffc020380a:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020380c:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0203810:	000a3797          	auipc	a5,0xa3
ffffffffc0203814:	f007a823          	sw	zero,-240(a5) # ffffffffc02a6720 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0203818:	8b1fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020381c:	4511                	li	a0,4
ffffffffc020381e:	86dfd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0203822:	4c051463          	bnez	a0,ffffffffc0203cea <default_check+0x6a2>
ffffffffc0203826:	0889b783          	ld	a5,136(s3)
ffffffffc020382a:	8385                	srli	a5,a5,0x1
ffffffffc020382c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020382e:	48078e63          	beqz	a5,ffffffffc0203cca <default_check+0x682>
ffffffffc0203832:	0909a703          	lw	a4,144(s3)
ffffffffc0203836:	478d                	li	a5,3
ffffffffc0203838:	48f71963          	bne	a4,a5,ffffffffc0203cca <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020383c:	450d                	li	a0,3
ffffffffc020383e:	84dfd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0203842:	8c2a                	mv	s8,a0
ffffffffc0203844:	46050363          	beqz	a0,ffffffffc0203caa <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0203848:	4505                	li	a0,1
ffffffffc020384a:	841fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc020384e:	42051e63          	bnez	a0,ffffffffc0203c8a <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0203852:	418a1c63          	bne	s4,s8,ffffffffc0203c6a <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0203856:	4585                	li	a1,1
ffffffffc0203858:	854e                	mv	a0,s3
ffffffffc020385a:	86ffd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_pages(p1, 3);
ffffffffc020385e:	458d                	li	a1,3
ffffffffc0203860:	8552                	mv	a0,s4
ffffffffc0203862:	867fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
ffffffffc0203866:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020386a:	04098c13          	addi	s8,s3,64
ffffffffc020386e:	8385                	srli	a5,a5,0x1
ffffffffc0203870:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203872:	3c078c63          	beqz	a5,ffffffffc0203c4a <default_check+0x602>
ffffffffc0203876:	0109a703          	lw	a4,16(s3)
ffffffffc020387a:	4785                	li	a5,1
ffffffffc020387c:	3cf71763          	bne	a4,a5,ffffffffc0203c4a <default_check+0x602>
ffffffffc0203880:	008a3783          	ld	a5,8(s4) # 1008 <_binary_obj___user_faultread_out_size-0x8bb0>
ffffffffc0203884:	8385                	srli	a5,a5,0x1
ffffffffc0203886:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203888:	3a078163          	beqz	a5,ffffffffc0203c2a <default_check+0x5e2>
ffffffffc020388c:	010a2703          	lw	a4,16(s4)
ffffffffc0203890:	478d                	li	a5,3
ffffffffc0203892:	38f71c63          	bne	a4,a5,ffffffffc0203c2a <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203896:	4505                	li	a0,1
ffffffffc0203898:	ff2fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc020389c:	36a99763          	bne	s3,a0,ffffffffc0203c0a <default_check+0x5c2>
    free_page(p0);
ffffffffc02038a0:	4585                	li	a1,1
ffffffffc02038a2:	827fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02038a6:	4509                	li	a0,2
ffffffffc02038a8:	fe2fd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02038ac:	32aa1f63          	bne	s4,a0,ffffffffc0203bea <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02038b0:	4589                	li	a1,2
ffffffffc02038b2:	817fd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    free_page(p2);
ffffffffc02038b6:	4585                	li	a1,1
ffffffffc02038b8:	8562                	mv	a0,s8
ffffffffc02038ba:	80ffd0ef          	jal	ra,ffffffffc02010c8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02038be:	4515                	li	a0,5
ffffffffc02038c0:	fcafd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02038c4:	89aa                	mv	s3,a0
ffffffffc02038c6:	48050263          	beqz	a0,ffffffffc0203d4a <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02038ca:	4505                	li	a0,1
ffffffffc02038cc:	fbefd0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02038d0:	2c051d63          	bnez	a0,ffffffffc0203baa <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02038d4:	481c                	lw	a5,16(s0)
ffffffffc02038d6:	2a079a63          	bnez	a5,ffffffffc0203b8a <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02038da:	4595                	li	a1,5
ffffffffc02038dc:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02038de:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02038e2:	01643023          	sd	s6,0(s0)
ffffffffc02038e6:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02038ea:	fdefd0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    return listelm->next;
ffffffffc02038ee:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc02038f0:	00878963          	beq	a5,s0,ffffffffc0203902 <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc02038f4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02038f8:	679c                	ld	a5,8(a5)
ffffffffc02038fa:	397d                	addiw	s2,s2,-1
ffffffffc02038fc:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02038fe:	fe879be3          	bne	a5,s0,ffffffffc02038f4 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0203902:	26091463          	bnez	s2,ffffffffc0203b6a <default_check+0x522>
    assert(total == 0);
ffffffffc0203906:	46049263          	bnez	s1,ffffffffc0203d6a <default_check+0x722>
}
ffffffffc020390a:	60a6                	ld	ra,72(sp)
ffffffffc020390c:	6406                	ld	s0,64(sp)
ffffffffc020390e:	74e2                	ld	s1,56(sp)
ffffffffc0203910:	7942                	ld	s2,48(sp)
ffffffffc0203912:	79a2                	ld	s3,40(sp)
ffffffffc0203914:	7a02                	ld	s4,32(sp)
ffffffffc0203916:	6ae2                	ld	s5,24(sp)
ffffffffc0203918:	6b42                	ld	s6,16(sp)
ffffffffc020391a:	6ba2                	ld	s7,8(sp)
ffffffffc020391c:	6c02                	ld	s8,0(sp)
ffffffffc020391e:	6161                	addi	sp,sp,80
ffffffffc0203920:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0203922:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0203924:	4481                	li	s1,0
ffffffffc0203926:	4901                	li	s2,0
ffffffffc0203928:	b38d                	j	ffffffffc020368a <default_check+0x42>
        assert(PageProperty(p));
ffffffffc020392a:	00003697          	auipc	a3,0x3
ffffffffc020392e:	6ce68693          	addi	a3,a3,1742 # ffffffffc0206ff8 <commands+0x1368>
ffffffffc0203932:	00003617          	auipc	a2,0x3
ffffffffc0203936:	bf660613          	addi	a2,a2,-1034 # ffffffffc0206528 <commands+0x898>
ffffffffc020393a:	11000593          	li	a1,272
ffffffffc020393e:	00003517          	auipc	a0,0x3
ffffffffc0203942:	6ca50513          	addi	a0,a0,1738 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203946:	8d9fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020394a:	00003697          	auipc	a3,0x3
ffffffffc020394e:	75668693          	addi	a3,a3,1878 # ffffffffc02070a0 <commands+0x1410>
ffffffffc0203952:	00003617          	auipc	a2,0x3
ffffffffc0203956:	bd660613          	addi	a2,a2,-1066 # ffffffffc0206528 <commands+0x898>
ffffffffc020395a:	0db00593          	li	a1,219
ffffffffc020395e:	00003517          	auipc	a0,0x3
ffffffffc0203962:	6aa50513          	addi	a0,a0,1706 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203966:	8b9fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020396a:	00003697          	auipc	a3,0x3
ffffffffc020396e:	75e68693          	addi	a3,a3,1886 # ffffffffc02070c8 <commands+0x1438>
ffffffffc0203972:	00003617          	auipc	a2,0x3
ffffffffc0203976:	bb660613          	addi	a2,a2,-1098 # ffffffffc0206528 <commands+0x898>
ffffffffc020397a:	0dc00593          	li	a1,220
ffffffffc020397e:	00003517          	auipc	a0,0x3
ffffffffc0203982:	68a50513          	addi	a0,a0,1674 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203986:	899fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020398a:	00003697          	auipc	a3,0x3
ffffffffc020398e:	77e68693          	addi	a3,a3,1918 # ffffffffc0207108 <commands+0x1478>
ffffffffc0203992:	00003617          	auipc	a2,0x3
ffffffffc0203996:	b9660613          	addi	a2,a2,-1130 # ffffffffc0206528 <commands+0x898>
ffffffffc020399a:	0de00593          	li	a1,222
ffffffffc020399e:	00003517          	auipc	a0,0x3
ffffffffc02039a2:	66a50513          	addi	a0,a0,1642 # ffffffffc0207008 <commands+0x1378>
ffffffffc02039a6:	879fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(!list_empty(&free_list));
ffffffffc02039aa:	00003697          	auipc	a3,0x3
ffffffffc02039ae:	7e668693          	addi	a3,a3,2022 # ffffffffc0207190 <commands+0x1500>
ffffffffc02039b2:	00003617          	auipc	a2,0x3
ffffffffc02039b6:	b7660613          	addi	a2,a2,-1162 # ffffffffc0206528 <commands+0x898>
ffffffffc02039ba:	0f700593          	li	a1,247
ffffffffc02039be:	00003517          	auipc	a0,0x3
ffffffffc02039c2:	64a50513          	addi	a0,a0,1610 # ffffffffc0207008 <commands+0x1378>
ffffffffc02039c6:	859fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02039ca:	00003697          	auipc	a3,0x3
ffffffffc02039ce:	67668693          	addi	a3,a3,1654 # ffffffffc0207040 <commands+0x13b0>
ffffffffc02039d2:	00003617          	auipc	a2,0x3
ffffffffc02039d6:	b5660613          	addi	a2,a2,-1194 # ffffffffc0206528 <commands+0x898>
ffffffffc02039da:	0f000593          	li	a1,240
ffffffffc02039de:	00003517          	auipc	a0,0x3
ffffffffc02039e2:	62a50513          	addi	a0,a0,1578 # ffffffffc0207008 <commands+0x1378>
ffffffffc02039e6:	839fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free == 3);
ffffffffc02039ea:	00003697          	auipc	a3,0x3
ffffffffc02039ee:	79668693          	addi	a3,a3,1942 # ffffffffc0207180 <commands+0x14f0>
ffffffffc02039f2:	00003617          	auipc	a2,0x3
ffffffffc02039f6:	b3660613          	addi	a2,a2,-1226 # ffffffffc0206528 <commands+0x898>
ffffffffc02039fa:	0ee00593          	li	a1,238
ffffffffc02039fe:	00003517          	auipc	a0,0x3
ffffffffc0203a02:	60a50513          	addi	a0,a0,1546 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203a06:	819fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203a0a:	00003697          	auipc	a3,0x3
ffffffffc0203a0e:	75e68693          	addi	a3,a3,1886 # ffffffffc0207168 <commands+0x14d8>
ffffffffc0203a12:	00003617          	auipc	a2,0x3
ffffffffc0203a16:	b1660613          	addi	a2,a2,-1258 # ffffffffc0206528 <commands+0x898>
ffffffffc0203a1a:	0e900593          	li	a1,233
ffffffffc0203a1e:	00003517          	auipc	a0,0x3
ffffffffc0203a22:	5ea50513          	addi	a0,a0,1514 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203a26:	ff8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203a2a:	00003697          	auipc	a3,0x3
ffffffffc0203a2e:	71e68693          	addi	a3,a3,1822 # ffffffffc0207148 <commands+0x14b8>
ffffffffc0203a32:	00003617          	auipc	a2,0x3
ffffffffc0203a36:	af660613          	addi	a2,a2,-1290 # ffffffffc0206528 <commands+0x898>
ffffffffc0203a3a:	0e000593          	li	a1,224
ffffffffc0203a3e:	00003517          	auipc	a0,0x3
ffffffffc0203a42:	5ca50513          	addi	a0,a0,1482 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203a46:	fd8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(p0 != NULL);
ffffffffc0203a4a:	00003697          	auipc	a3,0x3
ffffffffc0203a4e:	78e68693          	addi	a3,a3,1934 # ffffffffc02071d8 <commands+0x1548>
ffffffffc0203a52:	00003617          	auipc	a2,0x3
ffffffffc0203a56:	ad660613          	addi	a2,a2,-1322 # ffffffffc0206528 <commands+0x898>
ffffffffc0203a5a:	11800593          	li	a1,280
ffffffffc0203a5e:	00003517          	auipc	a0,0x3
ffffffffc0203a62:	5aa50513          	addi	a0,a0,1450 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203a66:	fb8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free == 0);
ffffffffc0203a6a:	00003697          	auipc	a3,0x3
ffffffffc0203a6e:	75e68693          	addi	a3,a3,1886 # ffffffffc02071c8 <commands+0x1538>
ffffffffc0203a72:	00003617          	auipc	a2,0x3
ffffffffc0203a76:	ab660613          	addi	a2,a2,-1354 # ffffffffc0206528 <commands+0x898>
ffffffffc0203a7a:	0fd00593          	li	a1,253
ffffffffc0203a7e:	00003517          	auipc	a0,0x3
ffffffffc0203a82:	58a50513          	addi	a0,a0,1418 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203a86:	f98fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203a8a:	00003697          	auipc	a3,0x3
ffffffffc0203a8e:	6de68693          	addi	a3,a3,1758 # ffffffffc0207168 <commands+0x14d8>
ffffffffc0203a92:	00003617          	auipc	a2,0x3
ffffffffc0203a96:	a9660613          	addi	a2,a2,-1386 # ffffffffc0206528 <commands+0x898>
ffffffffc0203a9a:	0fb00593          	li	a1,251
ffffffffc0203a9e:	00003517          	auipc	a0,0x3
ffffffffc0203aa2:	56a50513          	addi	a0,a0,1386 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203aa6:	f78fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0203aaa:	00003697          	auipc	a3,0x3
ffffffffc0203aae:	6fe68693          	addi	a3,a3,1790 # ffffffffc02071a8 <commands+0x1518>
ffffffffc0203ab2:	00003617          	auipc	a2,0x3
ffffffffc0203ab6:	a7660613          	addi	a2,a2,-1418 # ffffffffc0206528 <commands+0x898>
ffffffffc0203aba:	0fa00593          	li	a1,250
ffffffffc0203abe:	00003517          	auipc	a0,0x3
ffffffffc0203ac2:	54a50513          	addi	a0,a0,1354 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203ac6:	f58fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203aca:	00003697          	auipc	a3,0x3
ffffffffc0203ace:	57668693          	addi	a3,a3,1398 # ffffffffc0207040 <commands+0x13b0>
ffffffffc0203ad2:	00003617          	auipc	a2,0x3
ffffffffc0203ad6:	a5660613          	addi	a2,a2,-1450 # ffffffffc0206528 <commands+0x898>
ffffffffc0203ada:	0d700593          	li	a1,215
ffffffffc0203ade:	00003517          	auipc	a0,0x3
ffffffffc0203ae2:	52a50513          	addi	a0,a0,1322 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203ae6:	f38fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203aea:	00003697          	auipc	a3,0x3
ffffffffc0203aee:	67e68693          	addi	a3,a3,1662 # ffffffffc0207168 <commands+0x14d8>
ffffffffc0203af2:	00003617          	auipc	a2,0x3
ffffffffc0203af6:	a3660613          	addi	a2,a2,-1482 # ffffffffc0206528 <commands+0x898>
ffffffffc0203afa:	0f400593          	li	a1,244
ffffffffc0203afe:	00003517          	auipc	a0,0x3
ffffffffc0203b02:	50a50513          	addi	a0,a0,1290 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203b06:	f18fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203b0a:	00003697          	auipc	a3,0x3
ffffffffc0203b0e:	57668693          	addi	a3,a3,1398 # ffffffffc0207080 <commands+0x13f0>
ffffffffc0203b12:	00003617          	auipc	a2,0x3
ffffffffc0203b16:	a1660613          	addi	a2,a2,-1514 # ffffffffc0206528 <commands+0x898>
ffffffffc0203b1a:	0f200593          	li	a1,242
ffffffffc0203b1e:	00003517          	auipc	a0,0x3
ffffffffc0203b22:	4ea50513          	addi	a0,a0,1258 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203b26:	ef8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203b2a:	00003697          	auipc	a3,0x3
ffffffffc0203b2e:	53668693          	addi	a3,a3,1334 # ffffffffc0207060 <commands+0x13d0>
ffffffffc0203b32:	00003617          	auipc	a2,0x3
ffffffffc0203b36:	9f660613          	addi	a2,a2,-1546 # ffffffffc0206528 <commands+0x898>
ffffffffc0203b3a:	0f100593          	li	a1,241
ffffffffc0203b3e:	00003517          	auipc	a0,0x3
ffffffffc0203b42:	4ca50513          	addi	a0,a0,1226 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203b46:	ed8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203b4a:	00003697          	auipc	a3,0x3
ffffffffc0203b4e:	53668693          	addi	a3,a3,1334 # ffffffffc0207080 <commands+0x13f0>
ffffffffc0203b52:	00003617          	auipc	a2,0x3
ffffffffc0203b56:	9d660613          	addi	a2,a2,-1578 # ffffffffc0206528 <commands+0x898>
ffffffffc0203b5a:	0d900593          	li	a1,217
ffffffffc0203b5e:	00003517          	auipc	a0,0x3
ffffffffc0203b62:	4aa50513          	addi	a0,a0,1194 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203b66:	eb8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(count == 0);
ffffffffc0203b6a:	00003697          	auipc	a3,0x3
ffffffffc0203b6e:	7be68693          	addi	a3,a3,1982 # ffffffffc0207328 <commands+0x1698>
ffffffffc0203b72:	00003617          	auipc	a2,0x3
ffffffffc0203b76:	9b660613          	addi	a2,a2,-1610 # ffffffffc0206528 <commands+0x898>
ffffffffc0203b7a:	14600593          	li	a1,326
ffffffffc0203b7e:	00003517          	auipc	a0,0x3
ffffffffc0203b82:	48a50513          	addi	a0,a0,1162 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203b86:	e98fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free == 0);
ffffffffc0203b8a:	00003697          	auipc	a3,0x3
ffffffffc0203b8e:	63e68693          	addi	a3,a3,1598 # ffffffffc02071c8 <commands+0x1538>
ffffffffc0203b92:	00003617          	auipc	a2,0x3
ffffffffc0203b96:	99660613          	addi	a2,a2,-1642 # ffffffffc0206528 <commands+0x898>
ffffffffc0203b9a:	13a00593          	li	a1,314
ffffffffc0203b9e:	00003517          	auipc	a0,0x3
ffffffffc0203ba2:	46a50513          	addi	a0,a0,1130 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203ba6:	e78fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203baa:	00003697          	auipc	a3,0x3
ffffffffc0203bae:	5be68693          	addi	a3,a3,1470 # ffffffffc0207168 <commands+0x14d8>
ffffffffc0203bb2:	00003617          	auipc	a2,0x3
ffffffffc0203bb6:	97660613          	addi	a2,a2,-1674 # ffffffffc0206528 <commands+0x898>
ffffffffc0203bba:	13800593          	li	a1,312
ffffffffc0203bbe:	00003517          	auipc	a0,0x3
ffffffffc0203bc2:	44a50513          	addi	a0,a0,1098 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203bc6:	e58fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203bca:	00003697          	auipc	a3,0x3
ffffffffc0203bce:	55e68693          	addi	a3,a3,1374 # ffffffffc0207128 <commands+0x1498>
ffffffffc0203bd2:	00003617          	auipc	a2,0x3
ffffffffc0203bd6:	95660613          	addi	a2,a2,-1706 # ffffffffc0206528 <commands+0x898>
ffffffffc0203bda:	0df00593          	li	a1,223
ffffffffc0203bde:	00003517          	auipc	a0,0x3
ffffffffc0203be2:	42a50513          	addi	a0,a0,1066 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203be6:	e38fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203bea:	00003697          	auipc	a3,0x3
ffffffffc0203bee:	6fe68693          	addi	a3,a3,1790 # ffffffffc02072e8 <commands+0x1658>
ffffffffc0203bf2:	00003617          	auipc	a2,0x3
ffffffffc0203bf6:	93660613          	addi	a2,a2,-1738 # ffffffffc0206528 <commands+0x898>
ffffffffc0203bfa:	13200593          	li	a1,306
ffffffffc0203bfe:	00003517          	auipc	a0,0x3
ffffffffc0203c02:	40a50513          	addi	a0,a0,1034 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203c06:	e18fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203c0a:	00003697          	auipc	a3,0x3
ffffffffc0203c0e:	6be68693          	addi	a3,a3,1726 # ffffffffc02072c8 <commands+0x1638>
ffffffffc0203c12:	00003617          	auipc	a2,0x3
ffffffffc0203c16:	91660613          	addi	a2,a2,-1770 # ffffffffc0206528 <commands+0x898>
ffffffffc0203c1a:	13000593          	li	a1,304
ffffffffc0203c1e:	00003517          	auipc	a0,0x3
ffffffffc0203c22:	3ea50513          	addi	a0,a0,1002 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203c26:	df8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203c2a:	00003697          	auipc	a3,0x3
ffffffffc0203c2e:	67668693          	addi	a3,a3,1654 # ffffffffc02072a0 <commands+0x1610>
ffffffffc0203c32:	00003617          	auipc	a2,0x3
ffffffffc0203c36:	8f660613          	addi	a2,a2,-1802 # ffffffffc0206528 <commands+0x898>
ffffffffc0203c3a:	12e00593          	li	a1,302
ffffffffc0203c3e:	00003517          	auipc	a0,0x3
ffffffffc0203c42:	3ca50513          	addi	a0,a0,970 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203c46:	dd8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203c4a:	00003697          	auipc	a3,0x3
ffffffffc0203c4e:	62e68693          	addi	a3,a3,1582 # ffffffffc0207278 <commands+0x15e8>
ffffffffc0203c52:	00003617          	auipc	a2,0x3
ffffffffc0203c56:	8d660613          	addi	a2,a2,-1834 # ffffffffc0206528 <commands+0x898>
ffffffffc0203c5a:	12d00593          	li	a1,301
ffffffffc0203c5e:	00003517          	auipc	a0,0x3
ffffffffc0203c62:	3aa50513          	addi	a0,a0,938 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203c66:	db8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203c6a:	00003697          	auipc	a3,0x3
ffffffffc0203c6e:	5fe68693          	addi	a3,a3,1534 # ffffffffc0207268 <commands+0x15d8>
ffffffffc0203c72:	00003617          	auipc	a2,0x3
ffffffffc0203c76:	8b660613          	addi	a2,a2,-1866 # ffffffffc0206528 <commands+0x898>
ffffffffc0203c7a:	12800593          	li	a1,296
ffffffffc0203c7e:	00003517          	auipc	a0,0x3
ffffffffc0203c82:	38a50513          	addi	a0,a0,906 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203c86:	d98fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203c8a:	00003697          	auipc	a3,0x3
ffffffffc0203c8e:	4de68693          	addi	a3,a3,1246 # ffffffffc0207168 <commands+0x14d8>
ffffffffc0203c92:	00003617          	auipc	a2,0x3
ffffffffc0203c96:	89660613          	addi	a2,a2,-1898 # ffffffffc0206528 <commands+0x898>
ffffffffc0203c9a:	12700593          	li	a1,295
ffffffffc0203c9e:	00003517          	auipc	a0,0x3
ffffffffc0203ca2:	36a50513          	addi	a0,a0,874 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203ca6:	d78fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203caa:	00003697          	auipc	a3,0x3
ffffffffc0203cae:	59e68693          	addi	a3,a3,1438 # ffffffffc0207248 <commands+0x15b8>
ffffffffc0203cb2:	00003617          	auipc	a2,0x3
ffffffffc0203cb6:	87660613          	addi	a2,a2,-1930 # ffffffffc0206528 <commands+0x898>
ffffffffc0203cba:	12600593          	li	a1,294
ffffffffc0203cbe:	00003517          	auipc	a0,0x3
ffffffffc0203cc2:	34a50513          	addi	a0,a0,842 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203cc6:	d58fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203cca:	00003697          	auipc	a3,0x3
ffffffffc0203cce:	54e68693          	addi	a3,a3,1358 # ffffffffc0207218 <commands+0x1588>
ffffffffc0203cd2:	00003617          	auipc	a2,0x3
ffffffffc0203cd6:	85660613          	addi	a2,a2,-1962 # ffffffffc0206528 <commands+0x898>
ffffffffc0203cda:	12500593          	li	a1,293
ffffffffc0203cde:	00003517          	auipc	a0,0x3
ffffffffc0203ce2:	32a50513          	addi	a0,a0,810 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203ce6:	d38fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0203cea:	00003697          	auipc	a3,0x3
ffffffffc0203cee:	51668693          	addi	a3,a3,1302 # ffffffffc0207200 <commands+0x1570>
ffffffffc0203cf2:	00003617          	auipc	a2,0x3
ffffffffc0203cf6:	83660613          	addi	a2,a2,-1994 # ffffffffc0206528 <commands+0x898>
ffffffffc0203cfa:	12400593          	li	a1,292
ffffffffc0203cfe:	00003517          	auipc	a0,0x3
ffffffffc0203d02:	30a50513          	addi	a0,a0,778 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203d06:	d18fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203d0a:	00003697          	auipc	a3,0x3
ffffffffc0203d0e:	45e68693          	addi	a3,a3,1118 # ffffffffc0207168 <commands+0x14d8>
ffffffffc0203d12:	00003617          	auipc	a2,0x3
ffffffffc0203d16:	81660613          	addi	a2,a2,-2026 # ffffffffc0206528 <commands+0x898>
ffffffffc0203d1a:	11e00593          	li	a1,286
ffffffffc0203d1e:	00003517          	auipc	a0,0x3
ffffffffc0203d22:	2ea50513          	addi	a0,a0,746 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203d26:	cf8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(!PageProperty(p0));
ffffffffc0203d2a:	00003697          	auipc	a3,0x3
ffffffffc0203d2e:	4be68693          	addi	a3,a3,1214 # ffffffffc02071e8 <commands+0x1558>
ffffffffc0203d32:	00002617          	auipc	a2,0x2
ffffffffc0203d36:	7f660613          	addi	a2,a2,2038 # ffffffffc0206528 <commands+0x898>
ffffffffc0203d3a:	11900593          	li	a1,281
ffffffffc0203d3e:	00003517          	auipc	a0,0x3
ffffffffc0203d42:	2ca50513          	addi	a0,a0,714 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203d46:	cd8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203d4a:	00003697          	auipc	a3,0x3
ffffffffc0203d4e:	5be68693          	addi	a3,a3,1470 # ffffffffc0207308 <commands+0x1678>
ffffffffc0203d52:	00002617          	auipc	a2,0x2
ffffffffc0203d56:	7d660613          	addi	a2,a2,2006 # ffffffffc0206528 <commands+0x898>
ffffffffc0203d5a:	13700593          	li	a1,311
ffffffffc0203d5e:	00003517          	auipc	a0,0x3
ffffffffc0203d62:	2aa50513          	addi	a0,a0,682 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203d66:	cb8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(total == 0);
ffffffffc0203d6a:	00003697          	auipc	a3,0x3
ffffffffc0203d6e:	5ce68693          	addi	a3,a3,1486 # ffffffffc0207338 <commands+0x16a8>
ffffffffc0203d72:	00002617          	auipc	a2,0x2
ffffffffc0203d76:	7b660613          	addi	a2,a2,1974 # ffffffffc0206528 <commands+0x898>
ffffffffc0203d7a:	14700593          	li	a1,327
ffffffffc0203d7e:	00003517          	auipc	a0,0x3
ffffffffc0203d82:	28a50513          	addi	a0,a0,650 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203d86:	c98fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(total == nr_free_pages());
ffffffffc0203d8a:	00003697          	auipc	a3,0x3
ffffffffc0203d8e:	29668693          	addi	a3,a3,662 # ffffffffc0207020 <commands+0x1390>
ffffffffc0203d92:	00002617          	auipc	a2,0x2
ffffffffc0203d96:	79660613          	addi	a2,a2,1942 # ffffffffc0206528 <commands+0x898>
ffffffffc0203d9a:	11300593          	li	a1,275
ffffffffc0203d9e:	00003517          	auipc	a0,0x3
ffffffffc0203da2:	26a50513          	addi	a0,a0,618 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203da6:	c78fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203daa:	00003697          	auipc	a3,0x3
ffffffffc0203dae:	2b668693          	addi	a3,a3,694 # ffffffffc0207060 <commands+0x13d0>
ffffffffc0203db2:	00002617          	auipc	a2,0x2
ffffffffc0203db6:	77660613          	addi	a2,a2,1910 # ffffffffc0206528 <commands+0x898>
ffffffffc0203dba:	0d800593          	li	a1,216
ffffffffc0203dbe:	00003517          	auipc	a0,0x3
ffffffffc0203dc2:	24a50513          	addi	a0,a0,586 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203dc6:	c58fc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203dca <default_free_pages>:
{
ffffffffc0203dca:	1141                	addi	sp,sp,-16
ffffffffc0203dcc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203dce:	14058463          	beqz	a1,ffffffffc0203f16 <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc0203dd2:	00659693          	slli	a3,a1,0x6
ffffffffc0203dd6:	96aa                	add	a3,a3,a0
ffffffffc0203dd8:	87aa                	mv	a5,a0
ffffffffc0203dda:	02d50263          	beq	a0,a3,ffffffffc0203dfe <default_free_pages+0x34>
ffffffffc0203dde:	6798                	ld	a4,8(a5)
ffffffffc0203de0:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203de2:	10071a63          	bnez	a4,ffffffffc0203ef6 <default_free_pages+0x12c>
ffffffffc0203de6:	6798                	ld	a4,8(a5)
ffffffffc0203de8:	8b09                	andi	a4,a4,2
ffffffffc0203dea:	10071663          	bnez	a4,ffffffffc0203ef6 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0203dee:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203df2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0203df6:	04078793          	addi	a5,a5,64
ffffffffc0203dfa:	fed792e3          	bne	a5,a3,ffffffffc0203dde <default_free_pages+0x14>
    base->property = n;
ffffffffc0203dfe:	2581                	sext.w	a1,a1
ffffffffc0203e00:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0203e02:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203e06:	4789                	li	a5,2
ffffffffc0203e08:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203e0c:	000a3697          	auipc	a3,0xa3
ffffffffc0203e10:	90468693          	addi	a3,a3,-1788 # ffffffffc02a6710 <free_area>
ffffffffc0203e14:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203e16:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0203e18:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0203e1c:	9db9                	addw	a1,a1,a4
ffffffffc0203e1e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0203e20:	0ad78463          	beq	a5,a3,ffffffffc0203ec8 <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc0203e24:	fe878713          	addi	a4,a5,-24
ffffffffc0203e28:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0203e2c:	4581                	li	a1,0
            if (base < page)
ffffffffc0203e2e:	00e56a63          	bltu	a0,a4,ffffffffc0203e42 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0203e32:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0203e34:	04d70c63          	beq	a4,a3,ffffffffc0203e8c <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc0203e38:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0203e3a:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0203e3e:	fee57ae3          	bgeu	a0,a4,ffffffffc0203e32 <default_free_pages+0x68>
ffffffffc0203e42:	c199                	beqz	a1,ffffffffc0203e48 <default_free_pages+0x7e>
ffffffffc0203e44:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203e48:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203e4a:	e390                	sd	a2,0(a5)
ffffffffc0203e4c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203e4e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203e50:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc0203e52:	00d70d63          	beq	a4,a3,ffffffffc0203e6c <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc0203e56:	ff872583          	lw	a1,-8(a4) # ff8 <_binary_obj___user_faultread_out_size-0x8bc0>
        p = le2page(le, page_link);
ffffffffc0203e5a:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0203e5e:	02059813          	slli	a6,a1,0x20
ffffffffc0203e62:	01a85793          	srli	a5,a6,0x1a
ffffffffc0203e66:	97b2                	add	a5,a5,a2
ffffffffc0203e68:	02f50c63          	beq	a0,a5,ffffffffc0203ea0 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0203e6c:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0203e6e:	00d78c63          	beq	a5,a3,ffffffffc0203e86 <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc0203e72:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0203e74:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc0203e78:	02061593          	slli	a1,a2,0x20
ffffffffc0203e7c:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0203e80:	972a                	add	a4,a4,a0
ffffffffc0203e82:	04e68a63          	beq	a3,a4,ffffffffc0203ed6 <default_free_pages+0x10c>
}
ffffffffc0203e86:	60a2                	ld	ra,8(sp)
ffffffffc0203e88:	0141                	addi	sp,sp,16
ffffffffc0203e8a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203e8c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203e8e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0203e90:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203e92:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0203e94:	02d70763          	beq	a4,a3,ffffffffc0203ec2 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0203e98:	8832                	mv	a6,a2
ffffffffc0203e9a:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0203e9c:	87ba                	mv	a5,a4
ffffffffc0203e9e:	bf71                	j	ffffffffc0203e3a <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0203ea0:	491c                	lw	a5,16(a0)
ffffffffc0203ea2:	9dbd                	addw	a1,a1,a5
ffffffffc0203ea4:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203ea8:	57f5                	li	a5,-3
ffffffffc0203eaa:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203eae:	01853803          	ld	a6,24(a0)
ffffffffc0203eb2:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0203eb4:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0203eb6:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0203eba:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0203ebc:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bb8>
ffffffffc0203ec0:	b77d                	j	ffffffffc0203e6e <default_free_pages+0xa4>
ffffffffc0203ec2:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc0203ec4:	873e                	mv	a4,a5
ffffffffc0203ec6:	bf41                	j	ffffffffc0203e56 <default_free_pages+0x8c>
}
ffffffffc0203ec8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203eca:	e390                	sd	a2,0(a5)
ffffffffc0203ecc:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203ece:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203ed0:	ed1c                	sd	a5,24(a0)
ffffffffc0203ed2:	0141                	addi	sp,sp,16
ffffffffc0203ed4:	8082                	ret
            base->property += p->property;
ffffffffc0203ed6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203eda:	ff078693          	addi	a3,a5,-16
ffffffffc0203ede:	9e39                	addw	a2,a2,a4
ffffffffc0203ee0:	c910                	sw	a2,16(a0)
ffffffffc0203ee2:	5775                	li	a4,-3
ffffffffc0203ee4:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203ee8:	6398                	ld	a4,0(a5)
ffffffffc0203eea:	679c                	ld	a5,8(a5)
}
ffffffffc0203eec:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203eee:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203ef0:	e398                	sd	a4,0(a5)
ffffffffc0203ef2:	0141                	addi	sp,sp,16
ffffffffc0203ef4:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203ef6:	00003697          	auipc	a3,0x3
ffffffffc0203efa:	45a68693          	addi	a3,a3,1114 # ffffffffc0207350 <commands+0x16c0>
ffffffffc0203efe:	00002617          	auipc	a2,0x2
ffffffffc0203f02:	62a60613          	addi	a2,a2,1578 # ffffffffc0206528 <commands+0x898>
ffffffffc0203f06:	09400593          	li	a1,148
ffffffffc0203f0a:	00003517          	auipc	a0,0x3
ffffffffc0203f0e:	0fe50513          	addi	a0,a0,254 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203f12:	b0cfc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(n > 0);
ffffffffc0203f16:	00003697          	auipc	a3,0x3
ffffffffc0203f1a:	43268693          	addi	a3,a3,1074 # ffffffffc0207348 <commands+0x16b8>
ffffffffc0203f1e:	00002617          	auipc	a2,0x2
ffffffffc0203f22:	60a60613          	addi	a2,a2,1546 # ffffffffc0206528 <commands+0x898>
ffffffffc0203f26:	09000593          	li	a1,144
ffffffffc0203f2a:	00003517          	auipc	a0,0x3
ffffffffc0203f2e:	0de50513          	addi	a0,a0,222 # ffffffffc0207008 <commands+0x1378>
ffffffffc0203f32:	aecfc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203f36 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203f36:	c941                	beqz	a0,ffffffffc0203fc6 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc0203f38:	000a2597          	auipc	a1,0xa2
ffffffffc0203f3c:	7d858593          	addi	a1,a1,2008 # ffffffffc02a6710 <free_area>
ffffffffc0203f40:	0105a803          	lw	a6,16(a1)
ffffffffc0203f44:	872a                	mv	a4,a0
ffffffffc0203f46:	02081793          	slli	a5,a6,0x20
ffffffffc0203f4a:	9381                	srli	a5,a5,0x20
ffffffffc0203f4c:	00a7ee63          	bltu	a5,a0,ffffffffc0203f68 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203f50:	87ae                	mv	a5,a1
ffffffffc0203f52:	a801                	j	ffffffffc0203f62 <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc0203f54:	ff87a683          	lw	a3,-8(a5)
ffffffffc0203f58:	02069613          	slli	a2,a3,0x20
ffffffffc0203f5c:	9201                	srli	a2,a2,0x20
ffffffffc0203f5e:	00e67763          	bgeu	a2,a4,ffffffffc0203f6c <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203f62:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0203f64:	feb798e3          	bne	a5,a1,ffffffffc0203f54 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203f68:	4501                	li	a0,0
}
ffffffffc0203f6a:	8082                	ret
    return listelm->prev;
ffffffffc0203f6c:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f70:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0203f74:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0203f78:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0203f7c:	0068b423          	sd	t1,8(a7) # 80008 <_binary_obj___user_exit_out_size+0x74ee0>
    next->prev = prev;
ffffffffc0203f80:	01133023          	sd	a7,0(t1) # 80000 <_binary_obj___user_exit_out_size+0x74ed8>
        if (page->property > n)
ffffffffc0203f84:	02c77863          	bgeu	a4,a2,ffffffffc0203fb4 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0203f88:	071a                	slli	a4,a4,0x6
ffffffffc0203f8a:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0203f8c:	41c686bb          	subw	a3,a3,t3
ffffffffc0203f90:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203f92:	00870613          	addi	a2,a4,8
ffffffffc0203f96:	4689                	li	a3,2
ffffffffc0203f98:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203f9c:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203fa0:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0203fa4:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0203fa8:	e290                	sd	a2,0(a3)
ffffffffc0203faa:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0203fae:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0203fb0:	01173c23          	sd	a7,24(a4)
ffffffffc0203fb4:	41c8083b          	subw	a6,a6,t3
ffffffffc0203fb8:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203fbc:	5775                	li	a4,-3
ffffffffc0203fbe:	17c1                	addi	a5,a5,-16
ffffffffc0203fc0:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0203fc4:	8082                	ret
{
ffffffffc0203fc6:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203fc8:	00003697          	auipc	a3,0x3
ffffffffc0203fcc:	38068693          	addi	a3,a3,896 # ffffffffc0207348 <commands+0x16b8>
ffffffffc0203fd0:	00002617          	auipc	a2,0x2
ffffffffc0203fd4:	55860613          	addi	a2,a2,1368 # ffffffffc0206528 <commands+0x898>
ffffffffc0203fd8:	06c00593          	li	a1,108
ffffffffc0203fdc:	00003517          	auipc	a0,0x3
ffffffffc0203fe0:	02c50513          	addi	a0,a0,44 # ffffffffc0207008 <commands+0x1378>
{
ffffffffc0203fe4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203fe6:	a38fc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203fea <default_init_memmap>:
{
ffffffffc0203fea:	1141                	addi	sp,sp,-16
ffffffffc0203fec:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203fee:	c5f1                	beqz	a1,ffffffffc02040ba <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc0203ff0:	00659693          	slli	a3,a1,0x6
ffffffffc0203ff4:	96aa                	add	a3,a3,a0
ffffffffc0203ff6:	87aa                	mv	a5,a0
ffffffffc0203ff8:	00d50f63          	beq	a0,a3,ffffffffc0204016 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203ffc:	6798                	ld	a4,8(a5)
ffffffffc0203ffe:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc0204000:	cf49                	beqz	a4,ffffffffc020409a <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0204002:	0007a823          	sw	zero,16(a5)
ffffffffc0204006:	0007b423          	sd	zero,8(a5)
ffffffffc020400a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc020400e:	04078793          	addi	a5,a5,64
ffffffffc0204012:	fed795e3          	bne	a5,a3,ffffffffc0203ffc <default_init_memmap+0x12>
    base->property = n;
ffffffffc0204016:	2581                	sext.w	a1,a1
ffffffffc0204018:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020401a:	4789                	li	a5,2
ffffffffc020401c:	00850713          	addi	a4,a0,8
ffffffffc0204020:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0204024:	000a2697          	auipc	a3,0xa2
ffffffffc0204028:	6ec68693          	addi	a3,a3,1772 # ffffffffc02a6710 <free_area>
ffffffffc020402c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020402e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0204030:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0204034:	9db9                	addw	a1,a1,a4
ffffffffc0204036:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc0204038:	04d78a63          	beq	a5,a3,ffffffffc020408c <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc020403c:	fe878713          	addi	a4,a5,-24
ffffffffc0204040:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0204044:	4581                	li	a1,0
            if (base < page)
ffffffffc0204046:	00e56a63          	bltu	a0,a4,ffffffffc020405a <default_init_memmap+0x70>
    return listelm->next;
ffffffffc020404a:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020404c:	02d70263          	beq	a4,a3,ffffffffc0204070 <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc0204050:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0204052:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0204056:	fee57ae3          	bgeu	a0,a4,ffffffffc020404a <default_init_memmap+0x60>
ffffffffc020405a:	c199                	beqz	a1,ffffffffc0204060 <default_init_memmap+0x76>
ffffffffc020405c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204060:	6398                	ld	a4,0(a5)
}
ffffffffc0204062:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204064:	e390                	sd	a2,0(a5)
ffffffffc0204066:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204068:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020406a:	ed18                	sd	a4,24(a0)
ffffffffc020406c:	0141                	addi	sp,sp,16
ffffffffc020406e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204070:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204072:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0204074:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204076:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0204078:	00d70663          	beq	a4,a3,ffffffffc0204084 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc020407c:	8832                	mv	a6,a2
ffffffffc020407e:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0204080:	87ba                	mv	a5,a4
ffffffffc0204082:	bfc1                	j	ffffffffc0204052 <default_init_memmap+0x68>
}
ffffffffc0204084:	60a2                	ld	ra,8(sp)
ffffffffc0204086:	e290                	sd	a2,0(a3)
ffffffffc0204088:	0141                	addi	sp,sp,16
ffffffffc020408a:	8082                	ret
ffffffffc020408c:	60a2                	ld	ra,8(sp)
ffffffffc020408e:	e390                	sd	a2,0(a5)
ffffffffc0204090:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204092:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204094:	ed1c                	sd	a5,24(a0)
ffffffffc0204096:	0141                	addi	sp,sp,16
ffffffffc0204098:	8082                	ret
        assert(PageReserved(p));
ffffffffc020409a:	00003697          	auipc	a3,0x3
ffffffffc020409e:	2de68693          	addi	a3,a3,734 # ffffffffc0207378 <commands+0x16e8>
ffffffffc02040a2:	00002617          	auipc	a2,0x2
ffffffffc02040a6:	48660613          	addi	a2,a2,1158 # ffffffffc0206528 <commands+0x898>
ffffffffc02040aa:	04b00593          	li	a1,75
ffffffffc02040ae:	00003517          	auipc	a0,0x3
ffffffffc02040b2:	f5a50513          	addi	a0,a0,-166 # ffffffffc0207008 <commands+0x1378>
ffffffffc02040b6:	968fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(n > 0);
ffffffffc02040ba:	00003697          	auipc	a3,0x3
ffffffffc02040be:	28e68693          	addi	a3,a3,654 # ffffffffc0207348 <commands+0x16b8>
ffffffffc02040c2:	00002617          	auipc	a2,0x2
ffffffffc02040c6:	46660613          	addi	a2,a2,1126 # ffffffffc0206528 <commands+0x898>
ffffffffc02040ca:	04700593          	li	a1,71
ffffffffc02040ce:	00003517          	auipc	a0,0x3
ffffffffc02040d2:	f3a50513          	addi	a0,a0,-198 # ffffffffc0207008 <commands+0x1378>
ffffffffc02040d6:	948fc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02040da <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc02040da:	8526                	mv	a0,s1
	jalr s0
ffffffffc02040dc:	9402                	jalr	s0

	jal do_exit
ffffffffc02040de:	678000ef          	jal	ra,ffffffffc0204756 <do_exit>

ffffffffc02040e2 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02040e2:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02040e6:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02040ea:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02040ec:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02040ee:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02040f2:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02040f6:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02040fa:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02040fe:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204102:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204106:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc020410a:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020410e:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204112:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204116:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc020411a:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020411e:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204120:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204122:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204126:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc020412a:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020412e:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204132:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204136:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc020413a:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020413e:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204142:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204146:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc020414a:	8082                	ret

ffffffffc020414c <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc020414c:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020414e:	10800513          	li	a0,264
{
ffffffffc0204152:	e022                	sd	s0,0(sp)
ffffffffc0204154:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204156:	b2cff0ef          	jal	ra,ffffffffc0203482 <kmalloc>
ffffffffc020415a:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc020415c:	cd21                	beqz	a0,ffffffffc02041b4 <alloc_proc+0x68>
    {
        proc->state = PROC_UNINIT; 
ffffffffc020415e:	57fd                	li	a5,-1
ffffffffc0204160:	1782                	slli	a5,a5,0x20
ffffffffc0204162:	e11c                	sd	a5,0(a0)
        proc->runs = 0;             
        proc->kstack = 0;         
        proc->need_resched = 0;  
        proc->parent = NULL;      
        proc->mm = NULL;          
        memset(&(proc->context), 0, sizeof(struct context)); 
ffffffffc0204164:	07000613          	li	a2,112
ffffffffc0204168:	4581                	li	a1,0
        proc->runs = 0;             
ffffffffc020416a:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;         
ffffffffc020416e:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;  
ffffffffc0204172:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;      
ffffffffc0204176:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;          
ffffffffc020417a:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context)); 
ffffffffc020417e:	03050513          	addi	a0,a0,48
ffffffffc0204182:	432010ef          	jal	ra,ffffffffc02055b4 <memset>
        proc->tf = NULL;            // 中断帧指针置为空
        proc->pgdir = boot_pgdir_pa;
ffffffffc0204186:	000a6797          	auipc	a5,0xa6
ffffffffc020418a:	5e27b783          	ld	a5,1506(a5) # ffffffffc02aa768 <boot_pgdir_pa>
        proc->tf = NULL;            // 中断帧指针置为空
ffffffffc020418e:	0a043023          	sd	zero,160(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc0204192:	f45c                	sd	a5,168(s0)
        proc->flags = 0;            
ffffffffc0204194:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN + 1); // 进程名初始化为空
ffffffffc0204198:	4641                	li	a2,16
ffffffffc020419a:	4581                	li	a1,0
ffffffffc020419c:	0b440513          	addi	a0,s0,180
ffffffffc02041a0:	414010ef          	jal	ra,ffffffffc02055b4 <memset>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->wait_state = 0;
ffffffffc02041a4:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc02041a8:	0e043c23          	sd	zero,248(s0)
ffffffffc02041ac:	10043023          	sd	zero,256(s0)
ffffffffc02041b0:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc02041b4:	60a2                	ld	ra,8(sp)
ffffffffc02041b6:	8522                	mv	a0,s0
ffffffffc02041b8:	6402                	ld	s0,0(sp)
ffffffffc02041ba:	0141                	addi	sp,sp,16
ffffffffc02041bc:	8082                	ret

ffffffffc02041be <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc02041be:	000a6797          	auipc	a5,0xa6
ffffffffc02041c2:	5ea7b783          	ld	a5,1514(a5) # ffffffffc02aa7a8 <current>
ffffffffc02041c6:	73c8                	ld	a0,160(a5)
ffffffffc02041c8:	ddffc06f          	j	ffffffffc0200fa6 <forkrets>

ffffffffc02041cc <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc02041cc:	000a6797          	auipc	a5,0xa6
ffffffffc02041d0:	5dc7b783          	ld	a5,1500(a5) # ffffffffc02aa7a8 <current>
ffffffffc02041d4:	43cc                	lw	a1,4(a5)
{
ffffffffc02041d6:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc02041d8:	00003617          	auipc	a2,0x3
ffffffffc02041dc:	20060613          	addi	a2,a2,512 # ffffffffc02073d8 <default_pmm_manager+0x38>
ffffffffc02041e0:	00003517          	auipc	a0,0x3
ffffffffc02041e4:	20850513          	addi	a0,a0,520 # ffffffffc02073e8 <default_pmm_manager+0x48>
{
ffffffffc02041e8:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc02041ea:	ef7fb0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc02041ee:	3fe06797          	auipc	a5,0x3fe06
ffffffffc02041f2:	78278793          	addi	a5,a5,1922 # a970 <_binary_obj___user_forktest_out_size>
ffffffffc02041f6:	e43e                	sd	a5,8(sp)
ffffffffc02041f8:	00003517          	auipc	a0,0x3
ffffffffc02041fc:	1e050513          	addi	a0,a0,480 # ffffffffc02073d8 <default_pmm_manager+0x38>
ffffffffc0204200:	0008e797          	auipc	a5,0x8e
ffffffffc0204204:	9d878793          	addi	a5,a5,-1576 # ffffffffc0291bd8 <_binary_obj___user_forktest_out_start>
ffffffffc0204208:	f03e                	sd	a5,32(sp)
ffffffffc020420a:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc020420c:	e802                	sd	zero,16(sp)
ffffffffc020420e:	304010ef          	jal	ra,ffffffffc0205512 <strlen>
ffffffffc0204212:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204214:	4511                	li	a0,4
ffffffffc0204216:	55a2                	lw	a1,40(sp)
ffffffffc0204218:	4662                	lw	a2,24(sp)
ffffffffc020421a:	5682                	lw	a3,32(sp)
ffffffffc020421c:	4722                	lw	a4,8(sp)
ffffffffc020421e:	48a9                	li	a7,10
ffffffffc0204220:	9002                	ebreak
ffffffffc0204222:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204224:	65c2                	ld	a1,16(sp)
ffffffffc0204226:	00003517          	auipc	a0,0x3
ffffffffc020422a:	1ea50513          	addi	a0,a0,490 # ffffffffc0207410 <default_pmm_manager+0x70>
ffffffffc020422e:	eb3fb0ef          	jal	ra,ffffffffc02000e0 <cprintf>
#else
    KERNEL_EXECVE(spin);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204232:	00003617          	auipc	a2,0x3
ffffffffc0204236:	1ee60613          	addi	a2,a2,494 # ffffffffc0207420 <default_pmm_manager+0x80>
ffffffffc020423a:	3aa00593          	li	a1,938
ffffffffc020423e:	00003517          	auipc	a0,0x3
ffffffffc0204242:	20250513          	addi	a0,a0,514 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0204246:	fd9fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020424a <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc020424a:	6d14                	ld	a3,24(a0)
{
ffffffffc020424c:	1141                	addi	sp,sp,-16
ffffffffc020424e:	e406                	sd	ra,8(sp)
ffffffffc0204250:	c02007b7          	lui	a5,0xc0200
ffffffffc0204254:	02f6ee63          	bltu	a3,a5,ffffffffc0204290 <put_pgdir+0x46>
ffffffffc0204258:	000a6517          	auipc	a0,0xa6
ffffffffc020425c:	53853503          	ld	a0,1336(a0) # ffffffffc02aa790 <va_pa_offset>
ffffffffc0204260:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc0204262:	82b1                	srli	a3,a3,0xc
ffffffffc0204264:	000a6797          	auipc	a5,0xa6
ffffffffc0204268:	5147b783          	ld	a5,1300(a5) # ffffffffc02aa778 <npage>
ffffffffc020426c:	02f6fe63          	bgeu	a3,a5,ffffffffc02042a8 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204270:	00004517          	auipc	a0,0x4
ffffffffc0204274:	a6853503          	ld	a0,-1432(a0) # ffffffffc0207cd8 <nbase>
}
ffffffffc0204278:	60a2                	ld	ra,8(sp)
ffffffffc020427a:	8e89                	sub	a3,a3,a0
ffffffffc020427c:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc020427e:	000a6517          	auipc	a0,0xa6
ffffffffc0204282:	50253503          	ld	a0,1282(a0) # ffffffffc02aa780 <pages>
ffffffffc0204286:	4585                	li	a1,1
ffffffffc0204288:	9536                	add	a0,a0,a3
}
ffffffffc020428a:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc020428c:	e3dfc06f          	j	ffffffffc02010c8 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204290:	00002617          	auipc	a2,0x2
ffffffffc0204294:	34060613          	addi	a2,a2,832 # ffffffffc02065d0 <commands+0x940>
ffffffffc0204298:	07700593          	li	a1,119
ffffffffc020429c:	00002517          	auipc	a0,0x2
ffffffffc02042a0:	1ec50513          	addi	a0,a0,492 # ffffffffc0206488 <commands+0x7f8>
ffffffffc02042a4:	f7bfb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02042a8:	00002617          	auipc	a2,0x2
ffffffffc02042ac:	1c060613          	addi	a2,a2,448 # ffffffffc0206468 <commands+0x7d8>
ffffffffc02042b0:	06900593          	li	a1,105
ffffffffc02042b4:	00002517          	auipc	a0,0x2
ffffffffc02042b8:	1d450513          	addi	a0,a0,468 # ffffffffc0206488 <commands+0x7f8>
ffffffffc02042bc:	f63fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02042c0 <proc_run>:
{
ffffffffc02042c0:	7179                	addi	sp,sp,-48
ffffffffc02042c2:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc02042c4:	000a6917          	auipc	s2,0xa6
ffffffffc02042c8:	4e490913          	addi	s2,s2,1252 # ffffffffc02aa7a8 <current>
{
ffffffffc02042cc:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc02042ce:	00093483          	ld	s1,0(s2)
{
ffffffffc02042d2:	f406                	sd	ra,40(sp)
ffffffffc02042d4:	e84e                	sd	s3,16(sp)
    if (proc != current)
ffffffffc02042d6:	02a48863          	beq	s1,a0,ffffffffc0204306 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02042da:	100027f3          	csrr	a5,sstatus
ffffffffc02042de:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02042e0:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02042e2:	ef9d                	bnez	a5,ffffffffc0204320 <proc_run+0x60>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc02042e4:	755c                	ld	a5,168(a0)
ffffffffc02042e6:	577d                	li	a4,-1
ffffffffc02042e8:	177e                	slli	a4,a4,0x3f
ffffffffc02042ea:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc02042ec:	00a93023          	sd	a0,0(s2)
ffffffffc02042f0:	8fd9                	or	a5,a5,a4
ffffffffc02042f2:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc02042f6:	03050593          	addi	a1,a0,48
ffffffffc02042fa:	03048513          	addi	a0,s1,48
ffffffffc02042fe:	de5ff0ef          	jal	ra,ffffffffc02040e2 <switch_to>
    if (flag)
ffffffffc0204302:	00099863          	bnez	s3,ffffffffc0204312 <proc_run+0x52>
}
ffffffffc0204306:	70a2                	ld	ra,40(sp)
ffffffffc0204308:	7482                	ld	s1,32(sp)
ffffffffc020430a:	6962                	ld	s2,24(sp)
ffffffffc020430c:	69c2                	ld	s3,16(sp)
ffffffffc020430e:	6145                	addi	sp,sp,48
ffffffffc0204310:	8082                	ret
ffffffffc0204312:	70a2                	ld	ra,40(sp)
ffffffffc0204314:	7482                	ld	s1,32(sp)
ffffffffc0204316:	6962                	ld	s2,24(sp)
ffffffffc0204318:	69c2                	ld	s3,16(sp)
ffffffffc020431a:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc020431c:	e98fc06f          	j	ffffffffc02009b4 <intr_enable>
ffffffffc0204320:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204322:	e98fc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc0204326:	6522                	ld	a0,8(sp)
ffffffffc0204328:	4985                	li	s3,1
ffffffffc020432a:	bf6d                	j	ffffffffc02042e4 <proc_run+0x24>

ffffffffc020432c <do_fork>:
{
ffffffffc020432c:	7119                	addi	sp,sp,-128
ffffffffc020432e:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204330:	000a6917          	auipc	s2,0xa6
ffffffffc0204334:	49090913          	addi	s2,s2,1168 # ffffffffc02aa7c0 <nr_process>
ffffffffc0204338:	00092703          	lw	a4,0(s2)
{
ffffffffc020433c:	fc86                	sd	ra,120(sp)
ffffffffc020433e:	f8a2                	sd	s0,112(sp)
ffffffffc0204340:	f4a6                	sd	s1,104(sp)
ffffffffc0204342:	ecce                	sd	s3,88(sp)
ffffffffc0204344:	e8d2                	sd	s4,80(sp)
ffffffffc0204346:	e4d6                	sd	s5,72(sp)
ffffffffc0204348:	e0da                	sd	s6,64(sp)
ffffffffc020434a:	fc5e                	sd	s7,56(sp)
ffffffffc020434c:	f862                	sd	s8,48(sp)
ffffffffc020434e:	f466                	sd	s9,40(sp)
ffffffffc0204350:	f06a                	sd	s10,32(sp)
ffffffffc0204352:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204354:	6785                	lui	a5,0x1
ffffffffc0204356:	32f75663          	bge	a4,a5,ffffffffc0204682 <do_fork+0x356>
ffffffffc020435a:	8a2a                	mv	s4,a0
ffffffffc020435c:	89ae                	mv	s3,a1
ffffffffc020435e:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc0204360:	dedff0ef          	jal	ra,ffffffffc020414c <alloc_proc>
ffffffffc0204364:	84aa                	mv	s1,a0
ffffffffc0204366:	2e050f63          	beqz	a0,ffffffffc0204664 <do_fork+0x338>
    proc->parent = current;
ffffffffc020436a:	000a6c17          	auipc	s8,0xa6
ffffffffc020436e:	43ec0c13          	addi	s8,s8,1086 # ffffffffc02aa7a8 <current>
ffffffffc0204372:	000c3783          	ld	a5,0(s8)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204376:	4509                	li	a0,2
    proc->parent = current;
ffffffffc0204378:	f09c                	sd	a5,32(s1)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020437a:	d11fc0ef          	jal	ra,ffffffffc020108a <alloc_pages>
    if (page != NULL)
ffffffffc020437e:	2e050063          	beqz	a0,ffffffffc020465e <do_fork+0x332>
    return page - pages + nbase;
ffffffffc0204382:	000a6a97          	auipc	s5,0xa6
ffffffffc0204386:	3fea8a93          	addi	s5,s5,1022 # ffffffffc02aa780 <pages>
ffffffffc020438a:	000ab683          	ld	a3,0(s5)
ffffffffc020438e:	00004b17          	auipc	s6,0x4
ffffffffc0204392:	94ab0b13          	addi	s6,s6,-1718 # ffffffffc0207cd8 <nbase>
ffffffffc0204396:	000b3783          	ld	a5,0(s6)
ffffffffc020439a:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc020439e:	000a6b97          	auipc	s7,0xa6
ffffffffc02043a2:	3dab8b93          	addi	s7,s7,986 # ffffffffc02aa778 <npage>
    return page - pages + nbase;
ffffffffc02043a6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02043a8:	5dfd                	li	s11,-1
ffffffffc02043aa:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02043ae:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02043b0:	00cddd93          	srli	s11,s11,0xc
ffffffffc02043b4:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02043b8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02043ba:	32e67a63          	bgeu	a2,a4,ffffffffc02046ee <do_fork+0x3c2>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02043be:	000c3603          	ld	a2,0(s8)
ffffffffc02043c2:	000a6c17          	auipc	s8,0xa6
ffffffffc02043c6:	3cec0c13          	addi	s8,s8,974 # ffffffffc02aa790 <va_pa_offset>
ffffffffc02043ca:	000c3703          	ld	a4,0(s8)
ffffffffc02043ce:	02863d03          	ld	s10,40(a2)
ffffffffc02043d2:	e43e                	sd	a5,8(sp)
ffffffffc02043d4:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02043d6:	e894                	sd	a3,16(s1)
    if (oldmm == NULL)
ffffffffc02043d8:	020d0863          	beqz	s10,ffffffffc0204408 <do_fork+0xdc>
    if (clone_flags & CLONE_VM)
ffffffffc02043dc:	100a7a13          	andi	s4,s4,256
ffffffffc02043e0:	1c0a0163          	beqz	s4,ffffffffc02045a2 <do_fork+0x276>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc02043e4:	030d2703          	lw	a4,48(s10)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02043e8:	018d3783          	ld	a5,24(s10)
ffffffffc02043ec:	c02006b7          	lui	a3,0xc0200
ffffffffc02043f0:	2705                	addiw	a4,a4,1
ffffffffc02043f2:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc02043f6:	03a4b423          	sd	s10,40(s1)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02043fa:	2cd7e163          	bltu	a5,a3,ffffffffc02046bc <do_fork+0x390>
ffffffffc02043fe:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204402:	6894                	ld	a3,16(s1)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204404:	8f99                	sub	a5,a5,a4
ffffffffc0204406:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204408:	6789                	lui	a5,0x2
ffffffffc020440a:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cd8>
ffffffffc020440e:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204410:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204412:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0204414:	87b6                	mv	a5,a3
ffffffffc0204416:	12040893          	addi	a7,s0,288
ffffffffc020441a:	00063803          	ld	a6,0(a2)
ffffffffc020441e:	6608                	ld	a0,8(a2)
ffffffffc0204420:	6a0c                	ld	a1,16(a2)
ffffffffc0204422:	6e18                	ld	a4,24(a2)
ffffffffc0204424:	0107b023          	sd	a6,0(a5)
ffffffffc0204428:	e788                	sd	a0,8(a5)
ffffffffc020442a:	eb8c                	sd	a1,16(a5)
ffffffffc020442c:	ef98                	sd	a4,24(a5)
ffffffffc020442e:	02060613          	addi	a2,a2,32
ffffffffc0204432:	02078793          	addi	a5,a5,32
ffffffffc0204436:	ff1612e3          	bne	a2,a7,ffffffffc020441a <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc020443a:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020443e:	12098f63          	beqz	s3,ffffffffc020457c <do_fork+0x250>
ffffffffc0204442:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204446:	00000797          	auipc	a5,0x0
ffffffffc020444a:	d7878793          	addi	a5,a5,-648 # ffffffffc02041be <forkret>
ffffffffc020444e:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204450:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204452:	100027f3          	csrr	a5,sstatus
ffffffffc0204456:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204458:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020445a:	14079063          	bnez	a5,ffffffffc020459a <do_fork+0x26e>
    if (++last_pid >= MAX_PID)
ffffffffc020445e:	000a2817          	auipc	a6,0xa2
ffffffffc0204462:	eaa80813          	addi	a6,a6,-342 # ffffffffc02a6308 <last_pid.1>
ffffffffc0204466:	00082783          	lw	a5,0(a6)
ffffffffc020446a:	6709                	lui	a4,0x2
ffffffffc020446c:	0017851b          	addiw	a0,a5,1
ffffffffc0204470:	00a82023          	sw	a0,0(a6)
ffffffffc0204474:	08e55d63          	bge	a0,a4,ffffffffc020450e <do_fork+0x1e2>
    if (last_pid >= next_safe)
ffffffffc0204478:	000a2317          	auipc	t1,0xa2
ffffffffc020447c:	e9430313          	addi	t1,t1,-364 # ffffffffc02a630c <next_safe.0>
ffffffffc0204480:	00032783          	lw	a5,0(t1)
ffffffffc0204484:	000a6417          	auipc	s0,0xa6
ffffffffc0204488:	2a440413          	addi	s0,s0,676 # ffffffffc02aa728 <proc_list>
ffffffffc020448c:	08f55963          	bge	a0,a5,ffffffffc020451e <do_fork+0x1f2>
        proc->pid = get_pid();
ffffffffc0204490:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204492:	45a9                	li	a1,10
ffffffffc0204494:	2501                	sext.w	a0,a0
ffffffffc0204496:	536010ef          	jal	ra,ffffffffc02059cc <hash32>
ffffffffc020449a:	02051793          	slli	a5,a0,0x20
ffffffffc020449e:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02044a2:	000a2797          	auipc	a5,0xa2
ffffffffc02044a6:	28678793          	addi	a5,a5,646 # ffffffffc02a6728 <hash_list>
ffffffffc02044aa:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02044ac:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02044ae:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02044b0:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc02044b4:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02044b6:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc02044b8:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02044ba:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02044bc:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc02044c0:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc02044c2:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc02044c4:	e21c                	sd	a5,0(a2)
ffffffffc02044c6:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc02044c8:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc02044ca:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc02044cc:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02044d0:	10e4b023          	sd	a4,256(s1)
ffffffffc02044d4:	c311                	beqz	a4,ffffffffc02044d8 <do_fork+0x1ac>
        proc->optr->yptr = proc;
ffffffffc02044d6:	ff64                	sd	s1,248(a4)
    nr_process++;
ffffffffc02044d8:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc02044dc:	fae4                	sd	s1,240(a3)
    nr_process++;
ffffffffc02044de:	2785                	addiw	a5,a5,1
ffffffffc02044e0:	00f92023          	sw	a5,0(s2)
    if (flag)
ffffffffc02044e4:	18099263          	bnez	s3,ffffffffc0204668 <do_fork+0x33c>
    wakeup_proc(proc);
ffffffffc02044e8:	8526                	mv	a0,s1
ffffffffc02044ea:	63d000ef          	jal	ra,ffffffffc0205326 <wakeup_proc>
    ret = proc->pid;
ffffffffc02044ee:	40c8                	lw	a0,4(s1)
}
ffffffffc02044f0:	70e6                	ld	ra,120(sp)
ffffffffc02044f2:	7446                	ld	s0,112(sp)
ffffffffc02044f4:	74a6                	ld	s1,104(sp)
ffffffffc02044f6:	7906                	ld	s2,96(sp)
ffffffffc02044f8:	69e6                	ld	s3,88(sp)
ffffffffc02044fa:	6a46                	ld	s4,80(sp)
ffffffffc02044fc:	6aa6                	ld	s5,72(sp)
ffffffffc02044fe:	6b06                	ld	s6,64(sp)
ffffffffc0204500:	7be2                	ld	s7,56(sp)
ffffffffc0204502:	7c42                	ld	s8,48(sp)
ffffffffc0204504:	7ca2                	ld	s9,40(sp)
ffffffffc0204506:	7d02                	ld	s10,32(sp)
ffffffffc0204508:	6de2                	ld	s11,24(sp)
ffffffffc020450a:	6109                	addi	sp,sp,128
ffffffffc020450c:	8082                	ret
        last_pid = 1;
ffffffffc020450e:	4785                	li	a5,1
ffffffffc0204510:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0204514:	4505                	li	a0,1
ffffffffc0204516:	000a2317          	auipc	t1,0xa2
ffffffffc020451a:	df630313          	addi	t1,t1,-522 # ffffffffc02a630c <next_safe.0>
    return listelm->next;
ffffffffc020451e:	000a6417          	auipc	s0,0xa6
ffffffffc0204522:	20a40413          	addi	s0,s0,522 # ffffffffc02aa728 <proc_list>
ffffffffc0204526:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc020452a:	6789                	lui	a5,0x2
ffffffffc020452c:	00f32023          	sw	a5,0(t1)
ffffffffc0204530:	86aa                	mv	a3,a0
ffffffffc0204532:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc0204534:	6e89                	lui	t4,0x2
ffffffffc0204536:	148e0163          	beq	t3,s0,ffffffffc0204678 <do_fork+0x34c>
ffffffffc020453a:	88ae                	mv	a7,a1
ffffffffc020453c:	87f2                	mv	a5,t3
ffffffffc020453e:	6609                	lui	a2,0x2
ffffffffc0204540:	a811                	j	ffffffffc0204554 <do_fork+0x228>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204542:	00e6d663          	bge	a3,a4,ffffffffc020454e <do_fork+0x222>
ffffffffc0204546:	00c75463          	bge	a4,a2,ffffffffc020454e <do_fork+0x222>
ffffffffc020454a:	863a                	mv	a2,a4
ffffffffc020454c:	4885                	li	a7,1
ffffffffc020454e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204550:	00878d63          	beq	a5,s0,ffffffffc020456a <do_fork+0x23e>
            if (proc->pid == last_pid)
ffffffffc0204554:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c7c>
ffffffffc0204558:	fed715e3          	bne	a4,a3,ffffffffc0204542 <do_fork+0x216>
                if (++last_pid >= next_safe)
ffffffffc020455c:	2685                	addiw	a3,a3,1
ffffffffc020455e:	10c6d863          	bge	a3,a2,ffffffffc020466e <do_fork+0x342>
ffffffffc0204562:	679c                	ld	a5,8(a5)
ffffffffc0204564:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204566:	fe8797e3          	bne	a5,s0,ffffffffc0204554 <do_fork+0x228>
ffffffffc020456a:	c581                	beqz	a1,ffffffffc0204572 <do_fork+0x246>
ffffffffc020456c:	00d82023          	sw	a3,0(a6)
ffffffffc0204570:	8536                	mv	a0,a3
ffffffffc0204572:	f0088fe3          	beqz	a7,ffffffffc0204490 <do_fork+0x164>
ffffffffc0204576:	00c32023          	sw	a2,0(t1)
ffffffffc020457a:	bf19                	j	ffffffffc0204490 <do_fork+0x164>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020457c:	89b6                	mv	s3,a3
ffffffffc020457e:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204582:	00000797          	auipc	a5,0x0
ffffffffc0204586:	c3c78793          	addi	a5,a5,-964 # ffffffffc02041be <forkret>
ffffffffc020458a:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020458c:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020458e:	100027f3          	csrr	a5,sstatus
ffffffffc0204592:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204594:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204596:	ec0784e3          	beqz	a5,ffffffffc020445e <do_fork+0x132>
        intr_disable();
ffffffffc020459a:	c20fc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc020459e:	4985                	li	s3,1
ffffffffc02045a0:	bd7d                	j	ffffffffc020445e <do_fork+0x132>
    if ((mm = mm_create()) == NULL)
ffffffffc02045a2:	b42fe0ef          	jal	ra,ffffffffc02028e4 <mm_create>
ffffffffc02045a6:	8caa                	mv	s9,a0
ffffffffc02045a8:	c159                	beqz	a0,ffffffffc020462e <do_fork+0x302>
    if ((page = alloc_page()) == NULL)
ffffffffc02045aa:	4505                	li	a0,1
ffffffffc02045ac:	adffc0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc02045b0:	cd25                	beqz	a0,ffffffffc0204628 <do_fork+0x2fc>
    return page - pages + nbase;
ffffffffc02045b2:	000ab683          	ld	a3,0(s5)
ffffffffc02045b6:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc02045b8:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02045bc:	40d506b3          	sub	a3,a0,a3
ffffffffc02045c0:	8699                	srai	a3,a3,0x6
ffffffffc02045c2:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02045c4:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02045c8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02045ca:	12edf263          	bgeu	s11,a4,ffffffffc02046ee <do_fork+0x3c2>
ffffffffc02045ce:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02045d2:	6605                	lui	a2,0x1
ffffffffc02045d4:	000a6597          	auipc	a1,0xa6
ffffffffc02045d8:	19c5b583          	ld	a1,412(a1) # ffffffffc02aa770 <boot_pgdir_va>
ffffffffc02045dc:	9a36                	add	s4,s4,a3
ffffffffc02045de:	8552                	mv	a0,s4
ffffffffc02045e0:	7e7000ef          	jal	ra,ffffffffc02055c6 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc02045e4:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc02045e8:	014cbc23          	sd	s4,24(s9)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02045ec:	4785                	li	a5,1
ffffffffc02045ee:	40fdb7af          	amoor.d	a5,a5,(s11)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc02045f2:	8b85                	andi	a5,a5,1
ffffffffc02045f4:	4a05                	li	s4,1
ffffffffc02045f6:	c799                	beqz	a5,ffffffffc0204604 <do_fork+0x2d8>
    {
        schedule();
ffffffffc02045f8:	5af000ef          	jal	ra,ffffffffc02053a6 <schedule>
ffffffffc02045fc:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock))
ffffffffc0204600:	8b85                	andi	a5,a5,1
ffffffffc0204602:	fbfd                	bnez	a5,ffffffffc02045f8 <do_fork+0x2cc>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204604:	85ea                	mv	a1,s10
ffffffffc0204606:	8566                	mv	a0,s9
ffffffffc0204608:	f80fe0ef          	jal	ra,ffffffffc0202d88 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020460c:	57f9                	li	a5,-2
ffffffffc020460e:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc0204612:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204614:	cfa5                	beqz	a5,ffffffffc020468c <do_fork+0x360>
good_mm:
ffffffffc0204616:	8d66                	mv	s10,s9
    if (ret != 0)
ffffffffc0204618:	dc0506e3          	beqz	a0,ffffffffc02043e4 <do_fork+0xb8>
    exit_mmap(mm);
ffffffffc020461c:	8566                	mv	a0,s9
ffffffffc020461e:	805fe0ef          	jal	ra,ffffffffc0202e22 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204622:	8566                	mv	a0,s9
ffffffffc0204624:	c27ff0ef          	jal	ra,ffffffffc020424a <put_pgdir>
    mm_destroy(mm);
ffffffffc0204628:	8566                	mv	a0,s9
ffffffffc020462a:	bfafe0ef          	jal	ra,ffffffffc0202a24 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020462e:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc0204630:	c02007b7          	lui	a5,0xc0200
ffffffffc0204634:	0af6e163          	bltu	a3,a5,ffffffffc02046d6 <do_fork+0x3aa>
ffffffffc0204638:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage)
ffffffffc020463c:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0204640:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204644:	83b1                	srli	a5,a5,0xc
ffffffffc0204646:	04e7ff63          	bgeu	a5,a4,ffffffffc02046a4 <do_fork+0x378>
    return &pages[PPN(pa) - nbase];
ffffffffc020464a:	000b3703          	ld	a4,0(s6)
ffffffffc020464e:	000ab503          	ld	a0,0(s5)
ffffffffc0204652:	4589                	li	a1,2
ffffffffc0204654:	8f99                	sub	a5,a5,a4
ffffffffc0204656:	079a                	slli	a5,a5,0x6
ffffffffc0204658:	953e                	add	a0,a0,a5
ffffffffc020465a:	a6ffc0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    kfree(proc);
ffffffffc020465e:	8526                	mv	a0,s1
ffffffffc0204660:	ed3fe0ef          	jal	ra,ffffffffc0203532 <kfree>
    ret = -E_NO_MEM;
ffffffffc0204664:	5571                	li	a0,-4
    return ret;
ffffffffc0204666:	b569                	j	ffffffffc02044f0 <do_fork+0x1c4>
        intr_enable();
ffffffffc0204668:	b4cfc0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc020466c:	bdb5                	j	ffffffffc02044e8 <do_fork+0x1bc>
                    if (last_pid >= MAX_PID)
ffffffffc020466e:	01d6c363          	blt	a3,t4,ffffffffc0204674 <do_fork+0x348>
                        last_pid = 1;
ffffffffc0204672:	4685                	li	a3,1
                    goto repeat;
ffffffffc0204674:	4585                	li	a1,1
ffffffffc0204676:	b5c1                	j	ffffffffc0204536 <do_fork+0x20a>
ffffffffc0204678:	c599                	beqz	a1,ffffffffc0204686 <do_fork+0x35a>
ffffffffc020467a:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc020467e:	8536                	mv	a0,a3
ffffffffc0204680:	bd01                	j	ffffffffc0204490 <do_fork+0x164>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204682:	556d                	li	a0,-5
ffffffffc0204684:	b5b5                	j	ffffffffc02044f0 <do_fork+0x1c4>
    return last_pid;
ffffffffc0204686:	00082503          	lw	a0,0(a6)
ffffffffc020468a:	b519                	j	ffffffffc0204490 <do_fork+0x164>
    {
        panic("Unlock failed.\n");
ffffffffc020468c:	00003617          	auipc	a2,0x3
ffffffffc0204690:	dcc60613          	addi	a2,a2,-564 # ffffffffc0207458 <default_pmm_manager+0xb8>
ffffffffc0204694:	03f00593          	li	a1,63
ffffffffc0204698:	00003517          	auipc	a0,0x3
ffffffffc020469c:	dd050513          	addi	a0,a0,-560 # ffffffffc0207468 <default_pmm_manager+0xc8>
ffffffffc02046a0:	b7ffb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02046a4:	00002617          	auipc	a2,0x2
ffffffffc02046a8:	dc460613          	addi	a2,a2,-572 # ffffffffc0206468 <commands+0x7d8>
ffffffffc02046ac:	06900593          	li	a1,105
ffffffffc02046b0:	00002517          	auipc	a0,0x2
ffffffffc02046b4:	dd850513          	addi	a0,a0,-552 # ffffffffc0206488 <commands+0x7f8>
ffffffffc02046b8:	b67fb0ef          	jal	ra,ffffffffc020021e <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02046bc:	86be                	mv	a3,a5
ffffffffc02046be:	00002617          	auipc	a2,0x2
ffffffffc02046c2:	f1260613          	addi	a2,a2,-238 # ffffffffc02065d0 <commands+0x940>
ffffffffc02046c6:	18900593          	li	a1,393
ffffffffc02046ca:	00003517          	auipc	a0,0x3
ffffffffc02046ce:	d7650513          	addi	a0,a0,-650 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc02046d2:	b4dfb0ef          	jal	ra,ffffffffc020021e <__panic>
    return pa2page(PADDR(kva));
ffffffffc02046d6:	00002617          	auipc	a2,0x2
ffffffffc02046da:	efa60613          	addi	a2,a2,-262 # ffffffffc02065d0 <commands+0x940>
ffffffffc02046de:	07700593          	li	a1,119
ffffffffc02046e2:	00002517          	auipc	a0,0x2
ffffffffc02046e6:	da650513          	addi	a0,a0,-602 # ffffffffc0206488 <commands+0x7f8>
ffffffffc02046ea:	b35fb0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc02046ee:	00002617          	auipc	a2,0x2
ffffffffc02046f2:	dd260613          	addi	a2,a2,-558 # ffffffffc02064c0 <commands+0x830>
ffffffffc02046f6:	07100593          	li	a1,113
ffffffffc02046fa:	00002517          	auipc	a0,0x2
ffffffffc02046fe:	d8e50513          	addi	a0,a0,-626 # ffffffffc0206488 <commands+0x7f8>
ffffffffc0204702:	b1dfb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204706 <kernel_thread>:
{
ffffffffc0204706:	7129                	addi	sp,sp,-320
ffffffffc0204708:	fa22                	sd	s0,304(sp)
ffffffffc020470a:	f626                	sd	s1,296(sp)
ffffffffc020470c:	f24a                	sd	s2,288(sp)
ffffffffc020470e:	84ae                	mv	s1,a1
ffffffffc0204710:	892a                	mv	s2,a0
ffffffffc0204712:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204714:	4581                	li	a1,0
ffffffffc0204716:	12000613          	li	a2,288
ffffffffc020471a:	850a                	mv	a0,sp
{
ffffffffc020471c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020471e:	697000ef          	jal	ra,ffffffffc02055b4 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204722:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204724:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204726:	100027f3          	csrr	a5,sstatus
ffffffffc020472a:	edd7f793          	andi	a5,a5,-291
ffffffffc020472e:	1207e793          	ori	a5,a5,288
ffffffffc0204732:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204734:	860a                	mv	a2,sp
ffffffffc0204736:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020473a:	00000797          	auipc	a5,0x0
ffffffffc020473e:	9a078793          	addi	a5,a5,-1632 # ffffffffc02040da <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204742:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204744:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204746:	be7ff0ef          	jal	ra,ffffffffc020432c <do_fork>
}
ffffffffc020474a:	70f2                	ld	ra,312(sp)
ffffffffc020474c:	7452                	ld	s0,304(sp)
ffffffffc020474e:	74b2                	ld	s1,296(sp)
ffffffffc0204750:	7912                	ld	s2,288(sp)
ffffffffc0204752:	6131                	addi	sp,sp,320
ffffffffc0204754:	8082                	ret

ffffffffc0204756 <do_exit>:
{
ffffffffc0204756:	7179                	addi	sp,sp,-48
ffffffffc0204758:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc020475a:	000a6417          	auipc	s0,0xa6
ffffffffc020475e:	04e40413          	addi	s0,s0,78 # ffffffffc02aa7a8 <current>
ffffffffc0204762:	601c                	ld	a5,0(s0)
{
ffffffffc0204764:	f406                	sd	ra,40(sp)
ffffffffc0204766:	ec26                	sd	s1,24(sp)
ffffffffc0204768:	e84a                	sd	s2,16(sp)
ffffffffc020476a:	e44e                	sd	s3,8(sp)
ffffffffc020476c:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc020476e:	000a6717          	auipc	a4,0xa6
ffffffffc0204772:	04273703          	ld	a4,66(a4) # ffffffffc02aa7b0 <idleproc>
ffffffffc0204776:	0ce78c63          	beq	a5,a4,ffffffffc020484e <do_exit+0xf8>
    if (current == initproc)
ffffffffc020477a:	000a6497          	auipc	s1,0xa6
ffffffffc020477e:	03e48493          	addi	s1,s1,62 # ffffffffc02aa7b8 <initproc>
ffffffffc0204782:	6098                	ld	a4,0(s1)
ffffffffc0204784:	0ee78b63          	beq	a5,a4,ffffffffc020487a <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc0204788:	0287b983          	ld	s3,40(a5)
ffffffffc020478c:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc020478e:	02098663          	beqz	s3,ffffffffc02047ba <do_exit+0x64>
ffffffffc0204792:	000a6797          	auipc	a5,0xa6
ffffffffc0204796:	fd67b783          	ld	a5,-42(a5) # ffffffffc02aa768 <boot_pgdir_pa>
ffffffffc020479a:	577d                	li	a4,-1
ffffffffc020479c:	177e                	slli	a4,a4,0x3f
ffffffffc020479e:	83b1                	srli	a5,a5,0xc
ffffffffc02047a0:	8fd9                	or	a5,a5,a4
ffffffffc02047a2:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02047a6:	0309a783          	lw	a5,48(s3)
ffffffffc02047aa:	fff7871b          	addiw	a4,a5,-1
ffffffffc02047ae:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc02047b2:	cb55                	beqz	a4,ffffffffc0204866 <do_exit+0x110>
        current->mm = NULL;
ffffffffc02047b4:	601c                	ld	a5,0(s0)
ffffffffc02047b6:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02047ba:	601c                	ld	a5,0(s0)
ffffffffc02047bc:	470d                	li	a4,3
ffffffffc02047be:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02047c0:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02047c4:	100027f3          	csrr	a5,sstatus
ffffffffc02047c8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02047ca:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02047cc:	e3f9                	bnez	a5,ffffffffc0204892 <do_exit+0x13c>
        proc = current->parent;
ffffffffc02047ce:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc02047d0:	800007b7          	lui	a5,0x80000
ffffffffc02047d4:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02047d6:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc02047d8:	0ec52703          	lw	a4,236(a0)
ffffffffc02047dc:	0af70f63          	beq	a4,a5,ffffffffc020489a <do_exit+0x144>
        while (current->cptr != NULL)
ffffffffc02047e0:	6018                	ld	a4,0(s0)
ffffffffc02047e2:	7b7c                	ld	a5,240(a4)
ffffffffc02047e4:	c3a1                	beqz	a5,ffffffffc0204824 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD)
ffffffffc02047e6:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc02047ea:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc02047ec:	0985                	addi	s3,s3,1
ffffffffc02047ee:	a021                	j	ffffffffc02047f6 <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc02047f0:	6018                	ld	a4,0(s0)
ffffffffc02047f2:	7b7c                	ld	a5,240(a4)
ffffffffc02047f4:	cb85                	beqz	a5,ffffffffc0204824 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02047f6:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fd8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02047fa:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02047fc:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02047fe:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0204800:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204804:	10e7b023          	sd	a4,256(a5)
ffffffffc0204808:	c311                	beqz	a4,ffffffffc020480c <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc020480a:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020480c:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020480e:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204810:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204812:	fd271fe3          	bne	a4,s2,ffffffffc02047f0 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204816:	0ec52783          	lw	a5,236(a0)
ffffffffc020481a:	fd379be3          	bne	a5,s3,ffffffffc02047f0 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020481e:	309000ef          	jal	ra,ffffffffc0205326 <wakeup_proc>
ffffffffc0204822:	b7f9                	j	ffffffffc02047f0 <do_exit+0x9a>
    if (flag)
ffffffffc0204824:	020a1263          	bnez	s4,ffffffffc0204848 <do_exit+0xf2>
    schedule();
ffffffffc0204828:	37f000ef          	jal	ra,ffffffffc02053a6 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc020482c:	601c                	ld	a5,0(s0)
ffffffffc020482e:	00003617          	auipc	a2,0x3
ffffffffc0204832:	c7260613          	addi	a2,a2,-910 # ffffffffc02074a0 <default_pmm_manager+0x100>
ffffffffc0204836:	23000593          	li	a1,560
ffffffffc020483a:	43d4                	lw	a3,4(a5)
ffffffffc020483c:	00003517          	auipc	a0,0x3
ffffffffc0204840:	c0450513          	addi	a0,a0,-1020 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0204844:	9dbfb0ef          	jal	ra,ffffffffc020021e <__panic>
        intr_enable();
ffffffffc0204848:	96cfc0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc020484c:	bff1                	j	ffffffffc0204828 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020484e:	00003617          	auipc	a2,0x3
ffffffffc0204852:	c3260613          	addi	a2,a2,-974 # ffffffffc0207480 <default_pmm_manager+0xe0>
ffffffffc0204856:	1fc00593          	li	a1,508
ffffffffc020485a:	00003517          	auipc	a0,0x3
ffffffffc020485e:	be650513          	addi	a0,a0,-1050 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0204862:	9bdfb0ef          	jal	ra,ffffffffc020021e <__panic>
            exit_mmap(mm);
ffffffffc0204866:	854e                	mv	a0,s3
ffffffffc0204868:	dbafe0ef          	jal	ra,ffffffffc0202e22 <exit_mmap>
            put_pgdir(mm);
ffffffffc020486c:	854e                	mv	a0,s3
ffffffffc020486e:	9ddff0ef          	jal	ra,ffffffffc020424a <put_pgdir>
            mm_destroy(mm);
ffffffffc0204872:	854e                	mv	a0,s3
ffffffffc0204874:	9b0fe0ef          	jal	ra,ffffffffc0202a24 <mm_destroy>
ffffffffc0204878:	bf35                	j	ffffffffc02047b4 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc020487a:	00003617          	auipc	a2,0x3
ffffffffc020487e:	c1660613          	addi	a2,a2,-1002 # ffffffffc0207490 <default_pmm_manager+0xf0>
ffffffffc0204882:	20000593          	li	a1,512
ffffffffc0204886:	00003517          	auipc	a0,0x3
ffffffffc020488a:	bba50513          	addi	a0,a0,-1094 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc020488e:	991fb0ef          	jal	ra,ffffffffc020021e <__panic>
        intr_disable();
ffffffffc0204892:	928fc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc0204896:	4a05                	li	s4,1
ffffffffc0204898:	bf1d                	j	ffffffffc02047ce <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc020489a:	28d000ef          	jal	ra,ffffffffc0205326 <wakeup_proc>
ffffffffc020489e:	b789                	j	ffffffffc02047e0 <do_exit+0x8a>

ffffffffc02048a0 <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc02048a0:	715d                	addi	sp,sp,-80
ffffffffc02048a2:	f84a                	sd	s2,48(sp)
ffffffffc02048a4:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02048a6:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc02048aa:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc02048ac:	fc26                	sd	s1,56(sp)
ffffffffc02048ae:	f052                	sd	s4,32(sp)
ffffffffc02048b0:	ec56                	sd	s5,24(sp)
ffffffffc02048b2:	e85a                	sd	s6,16(sp)
ffffffffc02048b4:	e45e                	sd	s7,8(sp)
ffffffffc02048b6:	e486                	sd	ra,72(sp)
ffffffffc02048b8:	e0a2                	sd	s0,64(sp)
ffffffffc02048ba:	84aa                	mv	s1,a0
ffffffffc02048bc:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02048be:	000a6b97          	auipc	s7,0xa6
ffffffffc02048c2:	eeab8b93          	addi	s7,s7,-278 # ffffffffc02aa7a8 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc02048c6:	00050b1b          	sext.w	s6,a0
ffffffffc02048ca:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02048ce:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02048d0:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc02048d2:	ccbd                	beqz	s1,ffffffffc0204950 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc02048d4:	0359e863          	bltu	s3,s5,ffffffffc0204904 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02048d8:	45a9                	li	a1,10
ffffffffc02048da:	855a                	mv	a0,s6
ffffffffc02048dc:	0f0010ef          	jal	ra,ffffffffc02059cc <hash32>
ffffffffc02048e0:	02051793          	slli	a5,a0,0x20
ffffffffc02048e4:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02048e8:	000a2797          	auipc	a5,0xa2
ffffffffc02048ec:	e4078793          	addi	a5,a5,-448 # ffffffffc02a6728 <hash_list>
ffffffffc02048f0:	953e                	add	a0,a0,a5
ffffffffc02048f2:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc02048f4:	a029                	j	ffffffffc02048fe <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc02048f6:	f2c42783          	lw	a5,-212(s0)
ffffffffc02048fa:	02978163          	beq	a5,s1,ffffffffc020491c <do_wait.part.0+0x7c>
ffffffffc02048fe:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc0204900:	fe851be3          	bne	a0,s0,ffffffffc02048f6 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0204904:	5579                	li	a0,-2
}
ffffffffc0204906:	60a6                	ld	ra,72(sp)
ffffffffc0204908:	6406                	ld	s0,64(sp)
ffffffffc020490a:	74e2                	ld	s1,56(sp)
ffffffffc020490c:	7942                	ld	s2,48(sp)
ffffffffc020490e:	79a2                	ld	s3,40(sp)
ffffffffc0204910:	7a02                	ld	s4,32(sp)
ffffffffc0204912:	6ae2                	ld	s5,24(sp)
ffffffffc0204914:	6b42                	ld	s6,16(sp)
ffffffffc0204916:	6ba2                	ld	s7,8(sp)
ffffffffc0204918:	6161                	addi	sp,sp,80
ffffffffc020491a:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc020491c:	000bb683          	ld	a3,0(s7)
ffffffffc0204920:	f4843783          	ld	a5,-184(s0)
ffffffffc0204924:	fed790e3          	bne	a5,a3,ffffffffc0204904 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204928:	f2842703          	lw	a4,-216(s0)
ffffffffc020492c:	478d                	li	a5,3
ffffffffc020492e:	0ef70b63          	beq	a4,a5,ffffffffc0204a24 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0204932:	4785                	li	a5,1
ffffffffc0204934:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0204936:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc020493a:	26d000ef          	jal	ra,ffffffffc02053a6 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc020493e:	000bb783          	ld	a5,0(s7)
ffffffffc0204942:	0b07a783          	lw	a5,176(a5)
ffffffffc0204946:	8b85                	andi	a5,a5,1
ffffffffc0204948:	d7c9                	beqz	a5,ffffffffc02048d2 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc020494a:	555d                	li	a0,-9
ffffffffc020494c:	e0bff0ef          	jal	ra,ffffffffc0204756 <do_exit>
        proc = current->cptr;
ffffffffc0204950:	000bb683          	ld	a3,0(s7)
ffffffffc0204954:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204956:	d45d                	beqz	s0,ffffffffc0204904 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204958:	470d                	li	a4,3
ffffffffc020495a:	a021                	j	ffffffffc0204962 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc020495c:	10043403          	ld	s0,256(s0)
ffffffffc0204960:	d869                	beqz	s0,ffffffffc0204932 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204962:	401c                	lw	a5,0(s0)
ffffffffc0204964:	fee79ce3          	bne	a5,a4,ffffffffc020495c <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc0204968:	000a6797          	auipc	a5,0xa6
ffffffffc020496c:	e487b783          	ld	a5,-440(a5) # ffffffffc02aa7b0 <idleproc>
ffffffffc0204970:	0c878963          	beq	a5,s0,ffffffffc0204a42 <do_wait.part.0+0x1a2>
ffffffffc0204974:	000a6797          	auipc	a5,0xa6
ffffffffc0204978:	e447b783          	ld	a5,-444(a5) # ffffffffc02aa7b8 <initproc>
ffffffffc020497c:	0cf40363          	beq	s0,a5,ffffffffc0204a42 <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc0204980:	000a0663          	beqz	s4,ffffffffc020498c <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0204984:	0e842783          	lw	a5,232(s0)
ffffffffc0204988:	00fa2023          	sw	a5,0(s4)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020498c:	100027f3          	csrr	a5,sstatus
ffffffffc0204990:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204992:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204994:	e7c1                	bnez	a5,ffffffffc0204a1c <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204996:	6c70                	ld	a2,216(s0)
ffffffffc0204998:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc020499a:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc020499e:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02049a0:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02049a2:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02049a4:	6470                	ld	a2,200(s0)
ffffffffc02049a6:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02049a8:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02049aa:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc02049ac:	c319                	beqz	a4,ffffffffc02049b2 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc02049ae:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc02049b0:	7c7c                	ld	a5,248(s0)
ffffffffc02049b2:	c3b5                	beqz	a5,ffffffffc0204a16 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc02049b4:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc02049b8:	000a6717          	auipc	a4,0xa6
ffffffffc02049bc:	e0870713          	addi	a4,a4,-504 # ffffffffc02aa7c0 <nr_process>
ffffffffc02049c0:	431c                	lw	a5,0(a4)
ffffffffc02049c2:	37fd                	addiw	a5,a5,-1
ffffffffc02049c4:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc02049c6:	e5a9                	bnez	a1,ffffffffc0204a10 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02049c8:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02049ca:	c02007b7          	lui	a5,0xc0200
ffffffffc02049ce:	04f6ee63          	bltu	a3,a5,ffffffffc0204a2a <do_wait.part.0+0x18a>
ffffffffc02049d2:	000a6797          	auipc	a5,0xa6
ffffffffc02049d6:	dbe7b783          	ld	a5,-578(a5) # ffffffffc02aa790 <va_pa_offset>
ffffffffc02049da:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc02049dc:	82b1                	srli	a3,a3,0xc
ffffffffc02049de:	000a6797          	auipc	a5,0xa6
ffffffffc02049e2:	d9a7b783          	ld	a5,-614(a5) # ffffffffc02aa778 <npage>
ffffffffc02049e6:	06f6fa63          	bgeu	a3,a5,ffffffffc0204a5a <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02049ea:	00003517          	auipc	a0,0x3
ffffffffc02049ee:	2ee53503          	ld	a0,750(a0) # ffffffffc0207cd8 <nbase>
ffffffffc02049f2:	8e89                	sub	a3,a3,a0
ffffffffc02049f4:	069a                	slli	a3,a3,0x6
ffffffffc02049f6:	000a6517          	auipc	a0,0xa6
ffffffffc02049fa:	d8a53503          	ld	a0,-630(a0) # ffffffffc02aa780 <pages>
ffffffffc02049fe:	9536                	add	a0,a0,a3
ffffffffc0204a00:	4589                	li	a1,2
ffffffffc0204a02:	ec6fc0ef          	jal	ra,ffffffffc02010c8 <free_pages>
    kfree(proc);
ffffffffc0204a06:	8522                	mv	a0,s0
ffffffffc0204a08:	b2bfe0ef          	jal	ra,ffffffffc0203532 <kfree>
    return 0;
ffffffffc0204a0c:	4501                	li	a0,0
ffffffffc0204a0e:	bde5                	j	ffffffffc0204906 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0204a10:	fa5fb0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0204a14:	bf55                	j	ffffffffc02049c8 <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc0204a16:	701c                	ld	a5,32(s0)
ffffffffc0204a18:	fbf8                	sd	a4,240(a5)
ffffffffc0204a1a:	bf79                	j	ffffffffc02049b8 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0204a1c:	f9ffb0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc0204a20:	4585                	li	a1,1
ffffffffc0204a22:	bf95                	j	ffffffffc0204996 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204a24:	f2840413          	addi	s0,s0,-216
ffffffffc0204a28:	b781                	j	ffffffffc0204968 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0204a2a:	00002617          	auipc	a2,0x2
ffffffffc0204a2e:	ba660613          	addi	a2,a2,-1114 # ffffffffc02065d0 <commands+0x940>
ffffffffc0204a32:	07700593          	li	a1,119
ffffffffc0204a36:	00002517          	auipc	a0,0x2
ffffffffc0204a3a:	a5250513          	addi	a0,a0,-1454 # ffffffffc0206488 <commands+0x7f8>
ffffffffc0204a3e:	fe0fb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0204a42:	00003617          	auipc	a2,0x3
ffffffffc0204a46:	a7e60613          	addi	a2,a2,-1410 # ffffffffc02074c0 <default_pmm_manager+0x120>
ffffffffc0204a4a:	35200593          	li	a1,850
ffffffffc0204a4e:	00003517          	auipc	a0,0x3
ffffffffc0204a52:	9f250513          	addi	a0,a0,-1550 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0204a56:	fc8fb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204a5a:	00002617          	auipc	a2,0x2
ffffffffc0204a5e:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0206468 <commands+0x7d8>
ffffffffc0204a62:	06900593          	li	a1,105
ffffffffc0204a66:	00002517          	auipc	a0,0x2
ffffffffc0204a6a:	a2250513          	addi	a0,a0,-1502 # ffffffffc0206488 <commands+0x7f8>
ffffffffc0204a6e:	fb0fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204a72 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc0204a72:	1141                	addi	sp,sp,-16
ffffffffc0204a74:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204a76:	e92fc0ef          	jal	ra,ffffffffc0201108 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0204a7a:	a05fe0ef          	jal	ra,ffffffffc020347e <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204a7e:	4601                	li	a2,0
ffffffffc0204a80:	4581                	li	a1,0
ffffffffc0204a82:	fffff517          	auipc	a0,0xfffff
ffffffffc0204a86:	74a50513          	addi	a0,a0,1866 # ffffffffc02041cc <user_main>
ffffffffc0204a8a:	c7dff0ef          	jal	ra,ffffffffc0204706 <kernel_thread>
    if (pid <= 0)
ffffffffc0204a8e:	00a04563          	bgtz	a0,ffffffffc0204a98 <init_main+0x26>
ffffffffc0204a92:	a071                	j	ffffffffc0204b1e <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc0204a94:	113000ef          	jal	ra,ffffffffc02053a6 <schedule>
    if (code_store != NULL)
ffffffffc0204a98:	4581                	li	a1,0
ffffffffc0204a9a:	4501                	li	a0,0
ffffffffc0204a9c:	e05ff0ef          	jal	ra,ffffffffc02048a0 <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc0204aa0:	d975                	beqz	a0,ffffffffc0204a94 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204aa2:	00003517          	auipc	a0,0x3
ffffffffc0204aa6:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0207500 <default_pmm_manager+0x160>
ffffffffc0204aaa:	e36fb0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204aae:	000a6797          	auipc	a5,0xa6
ffffffffc0204ab2:	d0a7b783          	ld	a5,-758(a5) # ffffffffc02aa7b8 <initproc>
ffffffffc0204ab6:	7bf8                	ld	a4,240(a5)
ffffffffc0204ab8:	e339                	bnez	a4,ffffffffc0204afe <init_main+0x8c>
ffffffffc0204aba:	7ff8                	ld	a4,248(a5)
ffffffffc0204abc:	e329                	bnez	a4,ffffffffc0204afe <init_main+0x8c>
ffffffffc0204abe:	1007b703          	ld	a4,256(a5)
ffffffffc0204ac2:	ef15                	bnez	a4,ffffffffc0204afe <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204ac4:	000a6697          	auipc	a3,0xa6
ffffffffc0204ac8:	cfc6a683          	lw	a3,-772(a3) # ffffffffc02aa7c0 <nr_process>
ffffffffc0204acc:	4709                	li	a4,2
ffffffffc0204ace:	0ae69463          	bne	a3,a4,ffffffffc0204b76 <init_main+0x104>
    return listelm->next;
ffffffffc0204ad2:	000a6697          	auipc	a3,0xa6
ffffffffc0204ad6:	c5668693          	addi	a3,a3,-938 # ffffffffc02aa728 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204ada:	6698                	ld	a4,8(a3)
ffffffffc0204adc:	0c878793          	addi	a5,a5,200
ffffffffc0204ae0:	06f71b63          	bne	a4,a5,ffffffffc0204b56 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204ae4:	629c                	ld	a5,0(a3)
ffffffffc0204ae6:	04f71863          	bne	a4,a5,ffffffffc0204b36 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204aea:	00003517          	auipc	a0,0x3
ffffffffc0204aee:	afe50513          	addi	a0,a0,-1282 # ffffffffc02075e8 <default_pmm_manager+0x248>
ffffffffc0204af2:	deefb0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return 0;
}
ffffffffc0204af6:	60a2                	ld	ra,8(sp)
ffffffffc0204af8:	4501                	li	a0,0
ffffffffc0204afa:	0141                	addi	sp,sp,16
ffffffffc0204afc:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204afe:	00003697          	auipc	a3,0x3
ffffffffc0204b02:	a2a68693          	addi	a3,a3,-1494 # ffffffffc0207528 <default_pmm_manager+0x188>
ffffffffc0204b06:	00002617          	auipc	a2,0x2
ffffffffc0204b0a:	a2260613          	addi	a2,a2,-1502 # ffffffffc0206528 <commands+0x898>
ffffffffc0204b0e:	3c000593          	li	a1,960
ffffffffc0204b12:	00003517          	auipc	a0,0x3
ffffffffc0204b16:	92e50513          	addi	a0,a0,-1746 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0204b1a:	f04fb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("create user_main failed.\n");
ffffffffc0204b1e:	00003617          	auipc	a2,0x3
ffffffffc0204b22:	9c260613          	addi	a2,a2,-1598 # ffffffffc02074e0 <default_pmm_manager+0x140>
ffffffffc0204b26:	3b700593          	li	a1,951
ffffffffc0204b2a:	00003517          	auipc	a0,0x3
ffffffffc0204b2e:	91650513          	addi	a0,a0,-1770 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0204b32:	eecfb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204b36:	00003697          	auipc	a3,0x3
ffffffffc0204b3a:	a8268693          	addi	a3,a3,-1406 # ffffffffc02075b8 <default_pmm_manager+0x218>
ffffffffc0204b3e:	00002617          	auipc	a2,0x2
ffffffffc0204b42:	9ea60613          	addi	a2,a2,-1558 # ffffffffc0206528 <commands+0x898>
ffffffffc0204b46:	3c300593          	li	a1,963
ffffffffc0204b4a:	00003517          	auipc	a0,0x3
ffffffffc0204b4e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0204b52:	eccfb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204b56:	00003697          	auipc	a3,0x3
ffffffffc0204b5a:	a3268693          	addi	a3,a3,-1486 # ffffffffc0207588 <default_pmm_manager+0x1e8>
ffffffffc0204b5e:	00002617          	auipc	a2,0x2
ffffffffc0204b62:	9ca60613          	addi	a2,a2,-1590 # ffffffffc0206528 <commands+0x898>
ffffffffc0204b66:	3c200593          	li	a1,962
ffffffffc0204b6a:	00003517          	auipc	a0,0x3
ffffffffc0204b6e:	8d650513          	addi	a0,a0,-1834 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0204b72:	eacfb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_process == 2);
ffffffffc0204b76:	00003697          	auipc	a3,0x3
ffffffffc0204b7a:	a0268693          	addi	a3,a3,-1534 # ffffffffc0207578 <default_pmm_manager+0x1d8>
ffffffffc0204b7e:	00002617          	auipc	a2,0x2
ffffffffc0204b82:	9aa60613          	addi	a2,a2,-1622 # ffffffffc0206528 <commands+0x898>
ffffffffc0204b86:	3c100593          	li	a1,961
ffffffffc0204b8a:	00003517          	auipc	a0,0x3
ffffffffc0204b8e:	8b650513          	addi	a0,a0,-1866 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0204b92:	e8cfb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204b96 <do_execve>:
{
ffffffffc0204b96:	7171                	addi	sp,sp,-176
ffffffffc0204b98:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204b9a:	000a6d97          	auipc	s11,0xa6
ffffffffc0204b9e:	c0ed8d93          	addi	s11,s11,-1010 # ffffffffc02aa7a8 <current>
ffffffffc0204ba2:	000db783          	ld	a5,0(s11)
{
ffffffffc0204ba6:	e54e                	sd	s3,136(sp)
ffffffffc0204ba8:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204baa:	0287b983          	ld	s3,40(a5)
{
ffffffffc0204bae:	e94a                	sd	s2,144(sp)
ffffffffc0204bb0:	f4de                	sd	s7,104(sp)
ffffffffc0204bb2:	892a                	mv	s2,a0
ffffffffc0204bb4:	8bb2                	mv	s7,a2
ffffffffc0204bb6:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204bb8:	862e                	mv	a2,a1
ffffffffc0204bba:	4681                	li	a3,0
ffffffffc0204bbc:	85aa                	mv	a1,a0
ffffffffc0204bbe:	854e                	mv	a0,s3
{
ffffffffc0204bc0:	f506                	sd	ra,168(sp)
ffffffffc0204bc2:	f122                	sd	s0,160(sp)
ffffffffc0204bc4:	e152                	sd	s4,128(sp)
ffffffffc0204bc6:	fcd6                	sd	s5,120(sp)
ffffffffc0204bc8:	f8da                	sd	s6,112(sp)
ffffffffc0204bca:	f0e2                	sd	s8,96(sp)
ffffffffc0204bcc:	ece6                	sd	s9,88(sp)
ffffffffc0204bce:	e8ea                	sd	s10,80(sp)
ffffffffc0204bd0:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204bd2:	deafe0ef          	jal	ra,ffffffffc02031bc <user_mem_check>
ffffffffc0204bd6:	40050a63          	beqz	a0,ffffffffc0204fea <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204bda:	4641                	li	a2,16
ffffffffc0204bdc:	4581                	li	a1,0
ffffffffc0204bde:	1808                	addi	a0,sp,48
ffffffffc0204be0:	1d5000ef          	jal	ra,ffffffffc02055b4 <memset>
    memcpy(local_name, name, len);
ffffffffc0204be4:	47bd                	li	a5,15
ffffffffc0204be6:	8626                	mv	a2,s1
ffffffffc0204be8:	1e97e263          	bltu	a5,s1,ffffffffc0204dcc <do_execve+0x236>
ffffffffc0204bec:	85ca                	mv	a1,s2
ffffffffc0204bee:	1808                	addi	a0,sp,48
ffffffffc0204bf0:	1d7000ef          	jal	ra,ffffffffc02055c6 <memcpy>
    if (mm != NULL)
ffffffffc0204bf4:	1e098363          	beqz	s3,ffffffffc0204dda <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc0204bf8:	00002517          	auipc	a0,0x2
ffffffffc0204bfc:	01050513          	addi	a0,a0,16 # ffffffffc0206c08 <commands+0xf78>
ffffffffc0204c00:	d1afb0ef          	jal	ra,ffffffffc020011a <cputs>
ffffffffc0204c04:	000a6797          	auipc	a5,0xa6
ffffffffc0204c08:	b647b783          	ld	a5,-1180(a5) # ffffffffc02aa768 <boot_pgdir_pa>
ffffffffc0204c0c:	577d                	li	a4,-1
ffffffffc0204c0e:	177e                	slli	a4,a4,0x3f
ffffffffc0204c10:	83b1                	srli	a5,a5,0xc
ffffffffc0204c12:	8fd9                	or	a5,a5,a4
ffffffffc0204c14:	18079073          	csrw	satp,a5
ffffffffc0204c18:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b88>
ffffffffc0204c1c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204c20:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc0204c24:	2c070463          	beqz	a4,ffffffffc0204eec <do_execve+0x356>
        current->mm = NULL;
ffffffffc0204c28:	000db783          	ld	a5,0(s11)
ffffffffc0204c2c:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204c30:	cb5fd0ef          	jal	ra,ffffffffc02028e4 <mm_create>
ffffffffc0204c34:	84aa                	mv	s1,a0
ffffffffc0204c36:	1c050d63          	beqz	a0,ffffffffc0204e10 <do_execve+0x27a>
    if ((page = alloc_page()) == NULL)
ffffffffc0204c3a:	4505                	li	a0,1
ffffffffc0204c3c:	c4efc0ef          	jal	ra,ffffffffc020108a <alloc_pages>
ffffffffc0204c40:	3a050963          	beqz	a0,ffffffffc0204ff2 <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc0204c44:	000a6c97          	auipc	s9,0xa6
ffffffffc0204c48:	b3cc8c93          	addi	s9,s9,-1220 # ffffffffc02aa780 <pages>
ffffffffc0204c4c:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204c50:	000a6c17          	auipc	s8,0xa6
ffffffffc0204c54:	b28c0c13          	addi	s8,s8,-1240 # ffffffffc02aa778 <npage>
    return page - pages + nbase;
ffffffffc0204c58:	00003717          	auipc	a4,0x3
ffffffffc0204c5c:	08073703          	ld	a4,128(a4) # ffffffffc0207cd8 <nbase>
ffffffffc0204c60:	40d506b3          	sub	a3,a0,a3
ffffffffc0204c64:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204c66:	5afd                	li	s5,-1
ffffffffc0204c68:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0204c6c:	96ba                	add	a3,a3,a4
ffffffffc0204c6e:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204c70:	00cad713          	srli	a4,s5,0xc
ffffffffc0204c74:	ec3a                	sd	a4,24(sp)
ffffffffc0204c76:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c78:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204c7a:	38f77063          	bgeu	a4,a5,ffffffffc0204ffa <do_execve+0x464>
ffffffffc0204c7e:	000a6b17          	auipc	s6,0xa6
ffffffffc0204c82:	b12b0b13          	addi	s6,s6,-1262 # ffffffffc02aa790 <va_pa_offset>
ffffffffc0204c86:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204c8a:	6605                	lui	a2,0x1
ffffffffc0204c8c:	000a6597          	auipc	a1,0xa6
ffffffffc0204c90:	ae45b583          	ld	a1,-1308(a1) # ffffffffc02aa770 <boot_pgdir_va>
ffffffffc0204c94:	9936                	add	s2,s2,a3
ffffffffc0204c96:	854a                	mv	a0,s2
ffffffffc0204c98:	12f000ef          	jal	ra,ffffffffc02055c6 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204c9c:	7782                	ld	a5,32(sp)
ffffffffc0204c9e:	4398                	lw	a4,0(a5)
ffffffffc0204ca0:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204ca4:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204ca8:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9457>
ffffffffc0204cac:	14f71863          	bne	a4,a5,ffffffffc0204dfc <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204cb0:	7682                	ld	a3,32(sp)
ffffffffc0204cb2:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204cb6:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204cba:	00371793          	slli	a5,a4,0x3
ffffffffc0204cbe:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204cc0:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204cc2:	078e                	slli	a5,a5,0x3
ffffffffc0204cc4:	97ce                	add	a5,a5,s3
ffffffffc0204cc6:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204cc8:	00f9fc63          	bgeu	s3,a5,ffffffffc0204ce0 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204ccc:	0009a783          	lw	a5,0(s3)
ffffffffc0204cd0:	4705                	li	a4,1
ffffffffc0204cd2:	14e78163          	beq	a5,a4,ffffffffc0204e14 <do_execve+0x27e>
    for (; ph < ph_end; ph++)
ffffffffc0204cd6:	77a2                	ld	a5,40(sp)
ffffffffc0204cd8:	03898993          	addi	s3,s3,56
ffffffffc0204cdc:	fef9e8e3          	bltu	s3,a5,ffffffffc0204ccc <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204ce0:	4701                	li	a4,0
ffffffffc0204ce2:	46ad                	li	a3,11
ffffffffc0204ce4:	00100637          	lui	a2,0x100
ffffffffc0204ce8:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204cec:	8526                	mv	a0,s1
ffffffffc0204cee:	d89fd0ef          	jal	ra,ffffffffc0202a76 <mm_map>
ffffffffc0204cf2:	8a2a                	mv	s4,a0
ffffffffc0204cf4:	1e051263          	bnez	a0,ffffffffc0204ed8 <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204cf8:	6c88                	ld	a0,24(s1)
ffffffffc0204cfa:	467d                	li	a2,31
ffffffffc0204cfc:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204d00:	afffd0ef          	jal	ra,ffffffffc02027fe <pgdir_alloc_page>
ffffffffc0204d04:	38050363          	beqz	a0,ffffffffc020508a <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d08:	6c88                	ld	a0,24(s1)
ffffffffc0204d0a:	467d                	li	a2,31
ffffffffc0204d0c:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204d10:	aeffd0ef          	jal	ra,ffffffffc02027fe <pgdir_alloc_page>
ffffffffc0204d14:	34050b63          	beqz	a0,ffffffffc020506a <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d18:	6c88                	ld	a0,24(s1)
ffffffffc0204d1a:	467d                	li	a2,31
ffffffffc0204d1c:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204d20:	adffd0ef          	jal	ra,ffffffffc02027fe <pgdir_alloc_page>
ffffffffc0204d24:	32050363          	beqz	a0,ffffffffc020504a <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204d28:	6c88                	ld	a0,24(s1)
ffffffffc0204d2a:	467d                	li	a2,31
ffffffffc0204d2c:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204d30:	acffd0ef          	jal	ra,ffffffffc02027fe <pgdir_alloc_page>
ffffffffc0204d34:	2e050b63          	beqz	a0,ffffffffc020502a <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc0204d38:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204d3a:	000db603          	ld	a2,0(s11)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204d3e:	6c94                	ld	a3,24(s1)
ffffffffc0204d40:	2785                	addiw	a5,a5,1
ffffffffc0204d42:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0204d44:	f604                	sd	s1,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204d46:	c02007b7          	lui	a5,0xc0200
ffffffffc0204d4a:	2cf6e463          	bltu	a3,a5,ffffffffc0205012 <do_execve+0x47c>
ffffffffc0204d4e:	000b3783          	ld	a5,0(s6)
ffffffffc0204d52:	577d                	li	a4,-1
ffffffffc0204d54:	177e                	slli	a4,a4,0x3f
ffffffffc0204d56:	8e9d                	sub	a3,a3,a5
ffffffffc0204d58:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204d5c:	f654                	sd	a3,168(a2)
ffffffffc0204d5e:	8fd9                	or	a5,a5,a4
ffffffffc0204d60:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204d64:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204d66:	4581                	li	a1,0
ffffffffc0204d68:	12000613          	li	a2,288
ffffffffc0204d6c:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0204d6e:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204d72:	043000ef          	jal	ra,ffffffffc02055b4 <memset>
    tf->epc = elf->e_entry;
ffffffffc0204d76:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d78:	000db903          	ld	s2,0(s11)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE | SSTATUS_SIE);
ffffffffc0204d7c:	edd4f493          	andi	s1,s1,-291
    tf->epc = elf->e_entry;
ffffffffc0204d80:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204d82:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d84:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_exit_out_size+0xffffffff7fff4f8c>
    tf->gpr.sp = USTACKTOP;
ffffffffc0204d88:	07fe                	slli	a5,a5,0x1f
    tf->status |= SSTATUS_SPIE;
ffffffffc0204d8a:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d8e:	4641                	li	a2,16
ffffffffc0204d90:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0204d92:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0204d94:	10e43423          	sd	a4,264(s0)
    tf->status |= SSTATUS_SPIE;
ffffffffc0204d98:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204d9c:	854a                	mv	a0,s2
ffffffffc0204d9e:	017000ef          	jal	ra,ffffffffc02055b4 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204da2:	463d                	li	a2,15
ffffffffc0204da4:	180c                	addi	a1,sp,48
ffffffffc0204da6:	854a                	mv	a0,s2
ffffffffc0204da8:	01f000ef          	jal	ra,ffffffffc02055c6 <memcpy>
}
ffffffffc0204dac:	70aa                	ld	ra,168(sp)
ffffffffc0204dae:	740a                	ld	s0,160(sp)
ffffffffc0204db0:	64ea                	ld	s1,152(sp)
ffffffffc0204db2:	694a                	ld	s2,144(sp)
ffffffffc0204db4:	69aa                	ld	s3,136(sp)
ffffffffc0204db6:	7ae6                	ld	s5,120(sp)
ffffffffc0204db8:	7b46                	ld	s6,112(sp)
ffffffffc0204dba:	7ba6                	ld	s7,104(sp)
ffffffffc0204dbc:	7c06                	ld	s8,96(sp)
ffffffffc0204dbe:	6ce6                	ld	s9,88(sp)
ffffffffc0204dc0:	6d46                	ld	s10,80(sp)
ffffffffc0204dc2:	6da6                	ld	s11,72(sp)
ffffffffc0204dc4:	8552                	mv	a0,s4
ffffffffc0204dc6:	6a0a                	ld	s4,128(sp)
ffffffffc0204dc8:	614d                	addi	sp,sp,176
ffffffffc0204dca:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0204dcc:	463d                	li	a2,15
ffffffffc0204dce:	85ca                	mv	a1,s2
ffffffffc0204dd0:	1808                	addi	a0,sp,48
ffffffffc0204dd2:	7f4000ef          	jal	ra,ffffffffc02055c6 <memcpy>
    if (mm != NULL)
ffffffffc0204dd6:	e20991e3          	bnez	s3,ffffffffc0204bf8 <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc0204dda:	000db783          	ld	a5,0(s11)
ffffffffc0204dde:	779c                	ld	a5,40(a5)
ffffffffc0204de0:	e40788e3          	beqz	a5,ffffffffc0204c30 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204de4:	00003617          	auipc	a2,0x3
ffffffffc0204de8:	82460613          	addi	a2,a2,-2012 # ffffffffc0207608 <default_pmm_manager+0x268>
ffffffffc0204dec:	23c00593          	li	a1,572
ffffffffc0204df0:	00002517          	auipc	a0,0x2
ffffffffc0204df4:	65050513          	addi	a0,a0,1616 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0204df8:	c26fb0ef          	jal	ra,ffffffffc020021e <__panic>
    put_pgdir(mm);
ffffffffc0204dfc:	8526                	mv	a0,s1
ffffffffc0204dfe:	c4cff0ef          	jal	ra,ffffffffc020424a <put_pgdir>
    mm_destroy(mm);
ffffffffc0204e02:	8526                	mv	a0,s1
ffffffffc0204e04:	c21fd0ef          	jal	ra,ffffffffc0202a24 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0204e08:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0204e0a:	8552                	mv	a0,s4
ffffffffc0204e0c:	94bff0ef          	jal	ra,ffffffffc0204756 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0204e10:	5a71                	li	s4,-4
ffffffffc0204e12:	bfe5                	j	ffffffffc0204e0a <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204e14:	0289b603          	ld	a2,40(s3)
ffffffffc0204e18:	0209b783          	ld	a5,32(s3)
ffffffffc0204e1c:	1cf66d63          	bltu	a2,a5,ffffffffc0204ff6 <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204e20:	0049a783          	lw	a5,4(s3)
ffffffffc0204e24:	0017f693          	andi	a3,a5,1
ffffffffc0204e28:	c291                	beqz	a3,ffffffffc0204e2c <do_execve+0x296>
            vm_flags |= VM_EXEC;
ffffffffc0204e2a:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204e2c:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204e30:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204e32:	e779                	bnez	a4,ffffffffc0204f00 <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204e34:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204e36:	c781                	beqz	a5,ffffffffc0204e3e <do_execve+0x2a8>
            vm_flags |= VM_READ;
ffffffffc0204e38:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0204e3c:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE)
ffffffffc0204e3e:	0026f793          	andi	a5,a3,2
ffffffffc0204e42:	e3f1                	bnez	a5,ffffffffc0204f06 <do_execve+0x370>
        if (vm_flags & VM_EXEC)
ffffffffc0204e44:	0046f793          	andi	a5,a3,4
ffffffffc0204e48:	c399                	beqz	a5,ffffffffc0204e4e <do_execve+0x2b8>
            perm |= PTE_X;
ffffffffc0204e4a:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204e4e:	0109b583          	ld	a1,16(s3)
ffffffffc0204e52:	4701                	li	a4,0
ffffffffc0204e54:	8526                	mv	a0,s1
ffffffffc0204e56:	c21fd0ef          	jal	ra,ffffffffc0202a76 <mm_map>
ffffffffc0204e5a:	8a2a                	mv	s4,a0
ffffffffc0204e5c:	ed35                	bnez	a0,ffffffffc0204ed8 <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204e5e:	0109bb83          	ld	s7,16(s3)
ffffffffc0204e62:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0204e64:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204e68:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204e6c:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204e70:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204e72:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204e74:	993e                	add	s2,s2,a5
        while (start < end)
ffffffffc0204e76:	054be963          	bltu	s7,s4,ffffffffc0204ec8 <do_execve+0x332>
ffffffffc0204e7a:	aa95                	j	ffffffffc0204fee <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e7c:	6785                	lui	a5,0x1
ffffffffc0204e7e:	415b8533          	sub	a0,s7,s5
ffffffffc0204e82:	9abe                	add	s5,s5,a5
ffffffffc0204e84:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204e88:	015a7463          	bgeu	s4,s5,ffffffffc0204e90 <do_execve+0x2fa>
                size -= la - end;
ffffffffc0204e8c:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0204e90:	000cb683          	ld	a3,0(s9)
ffffffffc0204e94:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204e96:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204e9a:	40d406b3          	sub	a3,s0,a3
ffffffffc0204e9e:	8699                	srai	a3,a3,0x6
ffffffffc0204ea0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204ea2:	67e2                	ld	a5,24(sp)
ffffffffc0204ea4:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ea8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204eaa:	14b87863          	bgeu	a6,a1,ffffffffc0204ffa <do_execve+0x464>
ffffffffc0204eae:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204eb2:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204eb4:	9bb2                	add	s7,s7,a2
ffffffffc0204eb6:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204eb8:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204eba:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204ebc:	70a000ef          	jal	ra,ffffffffc02055c6 <memcpy>
            start += size, from += size;
ffffffffc0204ec0:	6622                	ld	a2,8(sp)
ffffffffc0204ec2:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204ec4:	054bf363          	bgeu	s7,s4,ffffffffc0204f0a <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204ec8:	6c88                	ld	a0,24(s1)
ffffffffc0204eca:	866a                	mv	a2,s10
ffffffffc0204ecc:	85d6                	mv	a1,s5
ffffffffc0204ece:	931fd0ef          	jal	ra,ffffffffc02027fe <pgdir_alloc_page>
ffffffffc0204ed2:	842a                	mv	s0,a0
ffffffffc0204ed4:	f545                	bnez	a0,ffffffffc0204e7c <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0204ed6:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0204ed8:	8526                	mv	a0,s1
ffffffffc0204eda:	f49fd0ef          	jal	ra,ffffffffc0202e22 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204ede:	8526                	mv	a0,s1
ffffffffc0204ee0:	b6aff0ef          	jal	ra,ffffffffc020424a <put_pgdir>
    mm_destroy(mm);
ffffffffc0204ee4:	8526                	mv	a0,s1
ffffffffc0204ee6:	b3ffd0ef          	jal	ra,ffffffffc0202a24 <mm_destroy>
    return ret;
ffffffffc0204eea:	b705                	j	ffffffffc0204e0a <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0204eec:	854e                	mv	a0,s3
ffffffffc0204eee:	f35fd0ef          	jal	ra,ffffffffc0202e22 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204ef2:	854e                	mv	a0,s3
ffffffffc0204ef4:	b56ff0ef          	jal	ra,ffffffffc020424a <put_pgdir>
            mm_destroy(mm);
ffffffffc0204ef8:	854e                	mv	a0,s3
ffffffffc0204efa:	b2bfd0ef          	jal	ra,ffffffffc0202a24 <mm_destroy>
ffffffffc0204efe:	b32d                	j	ffffffffc0204c28 <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204f00:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204f04:	fb95                	bnez	a5,ffffffffc0204e38 <do_execve+0x2a2>
            perm |= (PTE_W | PTE_R);
ffffffffc0204f06:	4d5d                	li	s10,23
ffffffffc0204f08:	bf35                	j	ffffffffc0204e44 <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204f0a:	0109b683          	ld	a3,16(s3)
ffffffffc0204f0e:	0289b903          	ld	s2,40(s3)
ffffffffc0204f12:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204f14:	075bfd63          	bgeu	s7,s5,ffffffffc0204f8e <do_execve+0x3f8>
            if (start == end)
ffffffffc0204f18:	db790fe3          	beq	s2,s7,ffffffffc0204cd6 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204f1c:	6785                	lui	a5,0x1
ffffffffc0204f1e:	00fb8533          	add	a0,s7,a5
ffffffffc0204f22:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0204f26:	41790a33          	sub	s4,s2,s7
            if (end < la)
ffffffffc0204f2a:	0b597d63          	bgeu	s2,s5,ffffffffc0204fe4 <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0204f2e:	000cb683          	ld	a3,0(s9)
ffffffffc0204f32:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204f34:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204f38:	40d406b3          	sub	a3,s0,a3
ffffffffc0204f3c:	8699                	srai	a3,a3,0x6
ffffffffc0204f3e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204f40:	67e2                	ld	a5,24(sp)
ffffffffc0204f42:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f46:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204f48:	0ac5f963          	bgeu	a1,a2,ffffffffc0204ffa <do_execve+0x464>
ffffffffc0204f4c:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204f50:	8652                	mv	a2,s4
ffffffffc0204f52:	4581                	li	a1,0
ffffffffc0204f54:	96c2                	add	a3,a3,a6
ffffffffc0204f56:	9536                	add	a0,a0,a3
ffffffffc0204f58:	65c000ef          	jal	ra,ffffffffc02055b4 <memset>
            start += size;
ffffffffc0204f5c:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204f60:	03597463          	bgeu	s2,s5,ffffffffc0204f88 <do_execve+0x3f2>
ffffffffc0204f64:	d6e909e3          	beq	s2,a4,ffffffffc0204cd6 <do_execve+0x140>
ffffffffc0204f68:	00002697          	auipc	a3,0x2
ffffffffc0204f6c:	6c868693          	addi	a3,a3,1736 # ffffffffc0207630 <default_pmm_manager+0x290>
ffffffffc0204f70:	00001617          	auipc	a2,0x1
ffffffffc0204f74:	5b860613          	addi	a2,a2,1464 # ffffffffc0206528 <commands+0x898>
ffffffffc0204f78:	2a500593          	li	a1,677
ffffffffc0204f7c:	00002517          	auipc	a0,0x2
ffffffffc0204f80:	4c450513          	addi	a0,a0,1220 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0204f84:	a9afb0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0204f88:	ff5710e3          	bne	a4,s5,ffffffffc0204f68 <do_execve+0x3d2>
ffffffffc0204f8c:	8bd6                	mv	s7,s5
        while (start < end)
ffffffffc0204f8e:	d52bf4e3          	bgeu	s7,s2,ffffffffc0204cd6 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204f92:	6c88                	ld	a0,24(s1)
ffffffffc0204f94:	866a                	mv	a2,s10
ffffffffc0204f96:	85d6                	mv	a1,s5
ffffffffc0204f98:	867fd0ef          	jal	ra,ffffffffc02027fe <pgdir_alloc_page>
ffffffffc0204f9c:	842a                	mv	s0,a0
ffffffffc0204f9e:	dd05                	beqz	a0,ffffffffc0204ed6 <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204fa0:	6785                	lui	a5,0x1
ffffffffc0204fa2:	415b8533          	sub	a0,s7,s5
ffffffffc0204fa6:	9abe                	add	s5,s5,a5
ffffffffc0204fa8:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204fac:	01597463          	bgeu	s2,s5,ffffffffc0204fb4 <do_execve+0x41e>
                size -= la - end;
ffffffffc0204fb0:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0204fb4:	000cb683          	ld	a3,0(s9)
ffffffffc0204fb8:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204fba:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204fbe:	40d406b3          	sub	a3,s0,a3
ffffffffc0204fc2:	8699                	srai	a3,a3,0x6
ffffffffc0204fc4:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204fc6:	67e2                	ld	a5,24(sp)
ffffffffc0204fc8:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204fcc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204fce:	02b87663          	bgeu	a6,a1,ffffffffc0204ffa <do_execve+0x464>
ffffffffc0204fd2:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204fd6:	4581                	li	a1,0
            start += size;
ffffffffc0204fd8:	9bb2                	add	s7,s7,a2
ffffffffc0204fda:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0204fdc:	9536                	add	a0,a0,a3
ffffffffc0204fde:	5d6000ef          	jal	ra,ffffffffc02055b4 <memset>
ffffffffc0204fe2:	b775                	j	ffffffffc0204f8e <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204fe4:	417a8a33          	sub	s4,s5,s7
ffffffffc0204fe8:	b799                	j	ffffffffc0204f2e <do_execve+0x398>
        return -E_INVAL;
ffffffffc0204fea:	5a75                	li	s4,-3
ffffffffc0204fec:	b3c1                	j	ffffffffc0204dac <do_execve+0x216>
        while (start < end)
ffffffffc0204fee:	86de                	mv	a3,s7
ffffffffc0204ff0:	bf39                	j	ffffffffc0204f0e <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0204ff2:	5a71                	li	s4,-4
ffffffffc0204ff4:	bdc5                	j	ffffffffc0204ee4 <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0204ff6:	5a61                	li	s4,-8
ffffffffc0204ff8:	b5c5                	j	ffffffffc0204ed8 <do_execve+0x342>
ffffffffc0204ffa:	00001617          	auipc	a2,0x1
ffffffffc0204ffe:	4c660613          	addi	a2,a2,1222 # ffffffffc02064c0 <commands+0x830>
ffffffffc0205002:	07100593          	li	a1,113
ffffffffc0205006:	00001517          	auipc	a0,0x1
ffffffffc020500a:	48250513          	addi	a0,a0,1154 # ffffffffc0206488 <commands+0x7f8>
ffffffffc020500e:	a10fb0ef          	jal	ra,ffffffffc020021e <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0205012:	00001617          	auipc	a2,0x1
ffffffffc0205016:	5be60613          	addi	a2,a2,1470 # ffffffffc02065d0 <commands+0x940>
ffffffffc020501a:	2c400593          	li	a1,708
ffffffffc020501e:	00002517          	auipc	a0,0x2
ffffffffc0205022:	42250513          	addi	a0,a0,1058 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0205026:	9f8fb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc020502a:	00002697          	auipc	a3,0x2
ffffffffc020502e:	71e68693          	addi	a3,a3,1822 # ffffffffc0207748 <default_pmm_manager+0x3a8>
ffffffffc0205032:	00001617          	auipc	a2,0x1
ffffffffc0205036:	4f660613          	addi	a2,a2,1270 # ffffffffc0206528 <commands+0x898>
ffffffffc020503a:	2bf00593          	li	a1,703
ffffffffc020503e:	00002517          	auipc	a0,0x2
ffffffffc0205042:	40250513          	addi	a0,a0,1026 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0205046:	9d8fb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc020504a:	00002697          	auipc	a3,0x2
ffffffffc020504e:	6b668693          	addi	a3,a3,1718 # ffffffffc0207700 <default_pmm_manager+0x360>
ffffffffc0205052:	00001617          	auipc	a2,0x1
ffffffffc0205056:	4d660613          	addi	a2,a2,1238 # ffffffffc0206528 <commands+0x898>
ffffffffc020505a:	2be00593          	li	a1,702
ffffffffc020505e:	00002517          	auipc	a0,0x2
ffffffffc0205062:	3e250513          	addi	a0,a0,994 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0205066:	9b8fb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc020506a:	00002697          	auipc	a3,0x2
ffffffffc020506e:	64e68693          	addi	a3,a3,1614 # ffffffffc02076b8 <default_pmm_manager+0x318>
ffffffffc0205072:	00001617          	auipc	a2,0x1
ffffffffc0205076:	4b660613          	addi	a2,a2,1206 # ffffffffc0206528 <commands+0x898>
ffffffffc020507a:	2bd00593          	li	a1,701
ffffffffc020507e:	00002517          	auipc	a0,0x2
ffffffffc0205082:	3c250513          	addi	a0,a0,962 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0205086:	998fb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc020508a:	00002697          	auipc	a3,0x2
ffffffffc020508e:	5e668693          	addi	a3,a3,1510 # ffffffffc0207670 <default_pmm_manager+0x2d0>
ffffffffc0205092:	00001617          	auipc	a2,0x1
ffffffffc0205096:	49660613          	addi	a2,a2,1174 # ffffffffc0206528 <commands+0x898>
ffffffffc020509a:	2bc00593          	li	a1,700
ffffffffc020509e:	00002517          	auipc	a0,0x2
ffffffffc02050a2:	3a250513          	addi	a0,a0,930 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc02050a6:	978fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02050aa <do_yield>:
    current->need_resched = 1;
ffffffffc02050aa:	000a5797          	auipc	a5,0xa5
ffffffffc02050ae:	6fe7b783          	ld	a5,1790(a5) # ffffffffc02aa7a8 <current>
ffffffffc02050b2:	4705                	li	a4,1
ffffffffc02050b4:	ef98                	sd	a4,24(a5)
}
ffffffffc02050b6:	4501                	li	a0,0
ffffffffc02050b8:	8082                	ret

ffffffffc02050ba <do_wait>:
{
ffffffffc02050ba:	1101                	addi	sp,sp,-32
ffffffffc02050bc:	e822                	sd	s0,16(sp)
ffffffffc02050be:	e426                	sd	s1,8(sp)
ffffffffc02050c0:	ec06                	sd	ra,24(sp)
ffffffffc02050c2:	842e                	mv	s0,a1
ffffffffc02050c4:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc02050c6:	c999                	beqz	a1,ffffffffc02050dc <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc02050c8:	000a5797          	auipc	a5,0xa5
ffffffffc02050cc:	6e07b783          	ld	a5,1760(a5) # ffffffffc02aa7a8 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc02050d0:	7788                	ld	a0,40(a5)
ffffffffc02050d2:	4685                	li	a3,1
ffffffffc02050d4:	4611                	li	a2,4
ffffffffc02050d6:	8e6fe0ef          	jal	ra,ffffffffc02031bc <user_mem_check>
ffffffffc02050da:	c909                	beqz	a0,ffffffffc02050ec <do_wait+0x32>
ffffffffc02050dc:	85a2                	mv	a1,s0
}
ffffffffc02050de:	6442                	ld	s0,16(sp)
ffffffffc02050e0:	60e2                	ld	ra,24(sp)
ffffffffc02050e2:	8526                	mv	a0,s1
ffffffffc02050e4:	64a2                	ld	s1,8(sp)
ffffffffc02050e6:	6105                	addi	sp,sp,32
ffffffffc02050e8:	fb8ff06f          	j	ffffffffc02048a0 <do_wait.part.0>
ffffffffc02050ec:	60e2                	ld	ra,24(sp)
ffffffffc02050ee:	6442                	ld	s0,16(sp)
ffffffffc02050f0:	64a2                	ld	s1,8(sp)
ffffffffc02050f2:	5575                	li	a0,-3
ffffffffc02050f4:	6105                	addi	sp,sp,32
ffffffffc02050f6:	8082                	ret

ffffffffc02050f8 <do_kill>:
{
ffffffffc02050f8:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc02050fa:	6789                	lui	a5,0x2
{
ffffffffc02050fc:	e406                	sd	ra,8(sp)
ffffffffc02050fe:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0205100:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205104:	17f9                	addi	a5,a5,-2
ffffffffc0205106:	02e7e963          	bltu	a5,a4,ffffffffc0205138 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020510a:	842a                	mv	s0,a0
ffffffffc020510c:	45a9                	li	a1,10
ffffffffc020510e:	2501                	sext.w	a0,a0
ffffffffc0205110:	0bd000ef          	jal	ra,ffffffffc02059cc <hash32>
ffffffffc0205114:	02051793          	slli	a5,a0,0x20
ffffffffc0205118:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020511c:	000a1797          	auipc	a5,0xa1
ffffffffc0205120:	60c78793          	addi	a5,a5,1548 # ffffffffc02a6728 <hash_list>
ffffffffc0205124:	953e                	add	a0,a0,a5
ffffffffc0205126:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0205128:	a029                	j	ffffffffc0205132 <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc020512a:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020512e:	00870b63          	beq	a4,s0,ffffffffc0205144 <do_kill+0x4c>
ffffffffc0205132:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205134:	fef51be3          	bne	a0,a5,ffffffffc020512a <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205138:	5475                	li	s0,-3
}
ffffffffc020513a:	60a2                	ld	ra,8(sp)
ffffffffc020513c:	8522                	mv	a0,s0
ffffffffc020513e:	6402                	ld	s0,0(sp)
ffffffffc0205140:	0141                	addi	sp,sp,16
ffffffffc0205142:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0205144:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205148:	00177693          	andi	a3,a4,1
ffffffffc020514c:	e295                	bnez	a3,ffffffffc0205170 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc020514e:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205150:	00176713          	ori	a4,a4,1
ffffffffc0205154:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205158:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc020515a:	fe06d0e3          	bgez	a3,ffffffffc020513a <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc020515e:	f2878513          	addi	a0,a5,-216
ffffffffc0205162:	1c4000ef          	jal	ra,ffffffffc0205326 <wakeup_proc>
}
ffffffffc0205166:	60a2                	ld	ra,8(sp)
ffffffffc0205168:	8522                	mv	a0,s0
ffffffffc020516a:	6402                	ld	s0,0(sp)
ffffffffc020516c:	0141                	addi	sp,sp,16
ffffffffc020516e:	8082                	ret
        return -E_KILLED;
ffffffffc0205170:	545d                	li	s0,-9
ffffffffc0205172:	b7e1                	j	ffffffffc020513a <do_kill+0x42>

ffffffffc0205174 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0205174:	1101                	addi	sp,sp,-32
ffffffffc0205176:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205178:	000a5797          	auipc	a5,0xa5
ffffffffc020517c:	5b078793          	addi	a5,a5,1456 # ffffffffc02aa728 <proc_list>
ffffffffc0205180:	ec06                	sd	ra,24(sp)
ffffffffc0205182:	e822                	sd	s0,16(sp)
ffffffffc0205184:	e04a                	sd	s2,0(sp)
ffffffffc0205186:	000a1497          	auipc	s1,0xa1
ffffffffc020518a:	5a248493          	addi	s1,s1,1442 # ffffffffc02a6728 <hash_list>
ffffffffc020518e:	e79c                	sd	a5,8(a5)
ffffffffc0205190:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0205192:	000a5717          	auipc	a4,0xa5
ffffffffc0205196:	59670713          	addi	a4,a4,1430 # ffffffffc02aa728 <proc_list>
ffffffffc020519a:	87a6                	mv	a5,s1
ffffffffc020519c:	e79c                	sd	a5,8(a5)
ffffffffc020519e:	e39c                	sd	a5,0(a5)
ffffffffc02051a0:	07c1                	addi	a5,a5,16
ffffffffc02051a2:	fef71de3          	bne	a4,a5,ffffffffc020519c <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc02051a6:	fa7fe0ef          	jal	ra,ffffffffc020414c <alloc_proc>
ffffffffc02051aa:	000a5917          	auipc	s2,0xa5
ffffffffc02051ae:	60690913          	addi	s2,s2,1542 # ffffffffc02aa7b0 <idleproc>
ffffffffc02051b2:	00a93023          	sd	a0,0(s2)
ffffffffc02051b6:	0e050f63          	beqz	a0,ffffffffc02052b4 <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02051ba:	4789                	li	a5,2
ffffffffc02051bc:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02051be:	00003797          	auipc	a5,0x3
ffffffffc02051c2:	e4278793          	addi	a5,a5,-446 # ffffffffc0208000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02051c6:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02051ca:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc02051cc:	4785                	li	a5,1
ffffffffc02051ce:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02051d0:	4641                	li	a2,16
ffffffffc02051d2:	4581                	li	a1,0
ffffffffc02051d4:	8522                	mv	a0,s0
ffffffffc02051d6:	3de000ef          	jal	ra,ffffffffc02055b4 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02051da:	463d                	li	a2,15
ffffffffc02051dc:	00002597          	auipc	a1,0x2
ffffffffc02051e0:	5cc58593          	addi	a1,a1,1484 # ffffffffc02077a8 <default_pmm_manager+0x408>
ffffffffc02051e4:	8522                	mv	a0,s0
ffffffffc02051e6:	3e0000ef          	jal	ra,ffffffffc02055c6 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc02051ea:	000a5717          	auipc	a4,0xa5
ffffffffc02051ee:	5d670713          	addi	a4,a4,1494 # ffffffffc02aa7c0 <nr_process>
ffffffffc02051f2:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc02051f4:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02051f8:	4601                	li	a2,0
    nr_process++;
ffffffffc02051fa:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02051fc:	4581                	li	a1,0
ffffffffc02051fe:	00000517          	auipc	a0,0x0
ffffffffc0205202:	87450513          	addi	a0,a0,-1932 # ffffffffc0204a72 <init_main>
    nr_process++;
ffffffffc0205206:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205208:	000a5797          	auipc	a5,0xa5
ffffffffc020520c:	5ad7b023          	sd	a3,1440(a5) # ffffffffc02aa7a8 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205210:	cf6ff0ef          	jal	ra,ffffffffc0204706 <kernel_thread>
ffffffffc0205214:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0205216:	08a05363          	blez	a0,ffffffffc020529c <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc020521a:	6789                	lui	a5,0x2
ffffffffc020521c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205220:	17f9                	addi	a5,a5,-2
ffffffffc0205222:	2501                	sext.w	a0,a0
ffffffffc0205224:	02e7e363          	bltu	a5,a4,ffffffffc020524a <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205228:	45a9                	li	a1,10
ffffffffc020522a:	7a2000ef          	jal	ra,ffffffffc02059cc <hash32>
ffffffffc020522e:	02051793          	slli	a5,a0,0x20
ffffffffc0205232:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205236:	96a6                	add	a3,a3,s1
ffffffffc0205238:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc020523a:	a029                	j	ffffffffc0205244 <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc020523c:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c8c>
ffffffffc0205240:	04870b63          	beq	a4,s0,ffffffffc0205296 <proc_init+0x122>
    return listelm->next;
ffffffffc0205244:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205246:	fef69be3          	bne	a3,a5,ffffffffc020523c <proc_init+0xc8>
    return NULL;
ffffffffc020524a:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020524c:	0b478493          	addi	s1,a5,180
ffffffffc0205250:	4641                	li	a2,16
ffffffffc0205252:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205254:	000a5417          	auipc	s0,0xa5
ffffffffc0205258:	56440413          	addi	s0,s0,1380 # ffffffffc02aa7b8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020525c:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc020525e:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205260:	354000ef          	jal	ra,ffffffffc02055b4 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205264:	463d                	li	a2,15
ffffffffc0205266:	00002597          	auipc	a1,0x2
ffffffffc020526a:	56a58593          	addi	a1,a1,1386 # ffffffffc02077d0 <default_pmm_manager+0x430>
ffffffffc020526e:	8526                	mv	a0,s1
ffffffffc0205270:	356000ef          	jal	ra,ffffffffc02055c6 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205274:	00093783          	ld	a5,0(s2)
ffffffffc0205278:	cbb5                	beqz	a5,ffffffffc02052ec <proc_init+0x178>
ffffffffc020527a:	43dc                	lw	a5,4(a5)
ffffffffc020527c:	eba5                	bnez	a5,ffffffffc02052ec <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020527e:	601c                	ld	a5,0(s0)
ffffffffc0205280:	c7b1                	beqz	a5,ffffffffc02052cc <proc_init+0x158>
ffffffffc0205282:	43d8                	lw	a4,4(a5)
ffffffffc0205284:	4785                	li	a5,1
ffffffffc0205286:	04f71363          	bne	a4,a5,ffffffffc02052cc <proc_init+0x158>
}
ffffffffc020528a:	60e2                	ld	ra,24(sp)
ffffffffc020528c:	6442                	ld	s0,16(sp)
ffffffffc020528e:	64a2                	ld	s1,8(sp)
ffffffffc0205290:	6902                	ld	s2,0(sp)
ffffffffc0205292:	6105                	addi	sp,sp,32
ffffffffc0205294:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205296:	f2878793          	addi	a5,a5,-216
ffffffffc020529a:	bf4d                	j	ffffffffc020524c <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc020529c:	00002617          	auipc	a2,0x2
ffffffffc02052a0:	51460613          	addi	a2,a2,1300 # ffffffffc02077b0 <default_pmm_manager+0x410>
ffffffffc02052a4:	3e600593          	li	a1,998
ffffffffc02052a8:	00002517          	auipc	a0,0x2
ffffffffc02052ac:	19850513          	addi	a0,a0,408 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc02052b0:	f6ffa0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02052b4:	00002617          	auipc	a2,0x2
ffffffffc02052b8:	4dc60613          	addi	a2,a2,1244 # ffffffffc0207790 <default_pmm_manager+0x3f0>
ffffffffc02052bc:	3d700593          	li	a1,983
ffffffffc02052c0:	00002517          	auipc	a0,0x2
ffffffffc02052c4:	18050513          	addi	a0,a0,384 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc02052c8:	f57fa0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02052cc:	00002697          	auipc	a3,0x2
ffffffffc02052d0:	53468693          	addi	a3,a3,1332 # ffffffffc0207800 <default_pmm_manager+0x460>
ffffffffc02052d4:	00001617          	auipc	a2,0x1
ffffffffc02052d8:	25460613          	addi	a2,a2,596 # ffffffffc0206528 <commands+0x898>
ffffffffc02052dc:	3ed00593          	li	a1,1005
ffffffffc02052e0:	00002517          	auipc	a0,0x2
ffffffffc02052e4:	16050513          	addi	a0,a0,352 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc02052e8:	f37fa0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02052ec:	00002697          	auipc	a3,0x2
ffffffffc02052f0:	4ec68693          	addi	a3,a3,1260 # ffffffffc02077d8 <default_pmm_manager+0x438>
ffffffffc02052f4:	00001617          	auipc	a2,0x1
ffffffffc02052f8:	23460613          	addi	a2,a2,564 # ffffffffc0206528 <commands+0x898>
ffffffffc02052fc:	3ec00593          	li	a1,1004
ffffffffc0205300:	00002517          	auipc	a0,0x2
ffffffffc0205304:	14050513          	addi	a0,a0,320 # ffffffffc0207440 <default_pmm_manager+0xa0>
ffffffffc0205308:	f17fa0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020530c <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc020530c:	1141                	addi	sp,sp,-16
ffffffffc020530e:	e022                	sd	s0,0(sp)
ffffffffc0205310:	e406                	sd	ra,8(sp)
ffffffffc0205312:	000a5417          	auipc	s0,0xa5
ffffffffc0205316:	49640413          	addi	s0,s0,1174 # ffffffffc02aa7a8 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc020531a:	6018                	ld	a4,0(s0)
ffffffffc020531c:	6f1c                	ld	a5,24(a4)
ffffffffc020531e:	dffd                	beqz	a5,ffffffffc020531c <cpu_idle+0x10>
        {
            schedule();
ffffffffc0205320:	086000ef          	jal	ra,ffffffffc02053a6 <schedule>
ffffffffc0205324:	bfdd                	j	ffffffffc020531a <cpu_idle+0xe>

ffffffffc0205326 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205326:	4118                	lw	a4,0(a0)
{
ffffffffc0205328:	1101                	addi	sp,sp,-32
ffffffffc020532a:	ec06                	sd	ra,24(sp)
ffffffffc020532c:	e822                	sd	s0,16(sp)
ffffffffc020532e:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205330:	478d                	li	a5,3
ffffffffc0205332:	04f70b63          	beq	a4,a5,ffffffffc0205388 <wakeup_proc+0x62>
ffffffffc0205336:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205338:	100027f3          	csrr	a5,sstatus
ffffffffc020533c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020533e:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205340:	ef9d                	bnez	a5,ffffffffc020537e <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205342:	4789                	li	a5,2
ffffffffc0205344:	02f70163          	beq	a4,a5,ffffffffc0205366 <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc0205348:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc020534a:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc020534e:	e491                	bnez	s1,ffffffffc020535a <wakeup_proc+0x34>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205350:	60e2                	ld	ra,24(sp)
ffffffffc0205352:	6442                	ld	s0,16(sp)
ffffffffc0205354:	64a2                	ld	s1,8(sp)
ffffffffc0205356:	6105                	addi	sp,sp,32
ffffffffc0205358:	8082                	ret
ffffffffc020535a:	6442                	ld	s0,16(sp)
ffffffffc020535c:	60e2                	ld	ra,24(sp)
ffffffffc020535e:	64a2                	ld	s1,8(sp)
ffffffffc0205360:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205362:	e52fb06f          	j	ffffffffc02009b4 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205366:	00002617          	auipc	a2,0x2
ffffffffc020536a:	4fa60613          	addi	a2,a2,1274 # ffffffffc0207860 <default_pmm_manager+0x4c0>
ffffffffc020536e:	45d1                	li	a1,20
ffffffffc0205370:	00002517          	auipc	a0,0x2
ffffffffc0205374:	4d850513          	addi	a0,a0,1240 # ffffffffc0207848 <default_pmm_manager+0x4a8>
ffffffffc0205378:	f0ffa0ef          	jal	ra,ffffffffc0200286 <__warn>
ffffffffc020537c:	bfc9                	j	ffffffffc020534e <wakeup_proc+0x28>
        intr_disable();
ffffffffc020537e:	e3cfb0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205382:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205384:	4485                	li	s1,1
ffffffffc0205386:	bf75                	j	ffffffffc0205342 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205388:	00002697          	auipc	a3,0x2
ffffffffc020538c:	4a068693          	addi	a3,a3,1184 # ffffffffc0207828 <default_pmm_manager+0x488>
ffffffffc0205390:	00001617          	auipc	a2,0x1
ffffffffc0205394:	19860613          	addi	a2,a2,408 # ffffffffc0206528 <commands+0x898>
ffffffffc0205398:	45a5                	li	a1,9
ffffffffc020539a:	00002517          	auipc	a0,0x2
ffffffffc020539e:	4ae50513          	addi	a0,a0,1198 # ffffffffc0207848 <default_pmm_manager+0x4a8>
ffffffffc02053a2:	e7dfa0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02053a6 <schedule>:

void schedule(void)
{
ffffffffc02053a6:	1141                	addi	sp,sp,-16
ffffffffc02053a8:	e406                	sd	ra,8(sp)
ffffffffc02053aa:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02053ac:	100027f3          	csrr	a5,sstatus
ffffffffc02053b0:	8b89                	andi	a5,a5,2
ffffffffc02053b2:	4401                	li	s0,0
ffffffffc02053b4:	efbd                	bnez	a5,ffffffffc0205432 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02053b6:	000a5897          	auipc	a7,0xa5
ffffffffc02053ba:	3f28b883          	ld	a7,1010(a7) # ffffffffc02aa7a8 <current>
ffffffffc02053be:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02053c2:	000a5517          	auipc	a0,0xa5
ffffffffc02053c6:	3ee53503          	ld	a0,1006(a0) # ffffffffc02aa7b0 <idleproc>
ffffffffc02053ca:	04a88e63          	beq	a7,a0,ffffffffc0205426 <schedule+0x80>
ffffffffc02053ce:	0c888693          	addi	a3,a7,200
ffffffffc02053d2:	000a5617          	auipc	a2,0xa5
ffffffffc02053d6:	35660613          	addi	a2,a2,854 # ffffffffc02aa728 <proc_list>
        le = last;
ffffffffc02053da:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02053dc:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc02053de:	4809                	li	a6,2
ffffffffc02053e0:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc02053e2:	00c78863          	beq	a5,a2,ffffffffc02053f2 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE)
ffffffffc02053e6:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02053ea:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc02053ee:	03070163          	beq	a4,a6,ffffffffc0205410 <schedule+0x6a>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc02053f2:	fef697e3          	bne	a3,a5,ffffffffc02053e0 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc02053f6:	ed89                	bnez	a1,ffffffffc0205410 <schedule+0x6a>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc02053f8:	451c                	lw	a5,8(a0)
ffffffffc02053fa:	2785                	addiw	a5,a5,1
ffffffffc02053fc:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc02053fe:	00a88463          	beq	a7,a0,ffffffffc0205406 <schedule+0x60>
        {
            proc_run(next);
ffffffffc0205402:	ebffe0ef          	jal	ra,ffffffffc02042c0 <proc_run>
    if (flag)
ffffffffc0205406:	e819                	bnez	s0,ffffffffc020541c <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205408:	60a2                	ld	ra,8(sp)
ffffffffc020540a:	6402                	ld	s0,0(sp)
ffffffffc020540c:	0141                	addi	sp,sp,16
ffffffffc020540e:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205410:	4198                	lw	a4,0(a1)
ffffffffc0205412:	4789                	li	a5,2
ffffffffc0205414:	fef712e3          	bne	a4,a5,ffffffffc02053f8 <schedule+0x52>
ffffffffc0205418:	852e                	mv	a0,a1
ffffffffc020541a:	bff9                	j	ffffffffc02053f8 <schedule+0x52>
}
ffffffffc020541c:	6402                	ld	s0,0(sp)
ffffffffc020541e:	60a2                	ld	ra,8(sp)
ffffffffc0205420:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205422:	d92fb06f          	j	ffffffffc02009b4 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205426:	000a5617          	auipc	a2,0xa5
ffffffffc020542a:	30260613          	addi	a2,a2,770 # ffffffffc02aa728 <proc_list>
ffffffffc020542e:	86b2                	mv	a3,a2
ffffffffc0205430:	b76d                	j	ffffffffc02053da <schedule+0x34>
        intr_disable();
ffffffffc0205432:	d88fb0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc0205436:	4405                	li	s0,1
ffffffffc0205438:	bfbd                	j	ffffffffc02053b6 <schedule+0x10>

ffffffffc020543a <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020543a:	000a5797          	auipc	a5,0xa5
ffffffffc020543e:	36e7b783          	ld	a5,878(a5) # ffffffffc02aa7a8 <current>
}
ffffffffc0205442:	43c8                	lw	a0,4(a5)
ffffffffc0205444:	8082                	ret

ffffffffc0205446 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205446:	4501                	li	a0,0
ffffffffc0205448:	8082                	ret

ffffffffc020544a <sys_putc>:
    cputchar(c);
ffffffffc020544a:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020544c:	1141                	addi	sp,sp,-16
ffffffffc020544e:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205450:	cc7fa0ef          	jal	ra,ffffffffc0200116 <cputchar>
}
ffffffffc0205454:	60a2                	ld	ra,8(sp)
ffffffffc0205456:	4501                	li	a0,0
ffffffffc0205458:	0141                	addi	sp,sp,16
ffffffffc020545a:	8082                	ret

ffffffffc020545c <sys_kill>:
    return do_kill(pid);
ffffffffc020545c:	4108                	lw	a0,0(a0)
ffffffffc020545e:	c9bff06f          	j	ffffffffc02050f8 <do_kill>

ffffffffc0205462 <sys_yield>:
    return do_yield();
ffffffffc0205462:	c49ff06f          	j	ffffffffc02050aa <do_yield>

ffffffffc0205466 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205466:	6d14                	ld	a3,24(a0)
ffffffffc0205468:	6910                	ld	a2,16(a0)
ffffffffc020546a:	650c                	ld	a1,8(a0)
ffffffffc020546c:	6108                	ld	a0,0(a0)
ffffffffc020546e:	f28ff06f          	j	ffffffffc0204b96 <do_execve>

ffffffffc0205472 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205472:	650c                	ld	a1,8(a0)
ffffffffc0205474:	4108                	lw	a0,0(a0)
ffffffffc0205476:	c45ff06f          	j	ffffffffc02050ba <do_wait>

ffffffffc020547a <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020547a:	000a5797          	auipc	a5,0xa5
ffffffffc020547e:	32e7b783          	ld	a5,814(a5) # ffffffffc02aa7a8 <current>
ffffffffc0205482:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205484:	4501                	li	a0,0
ffffffffc0205486:	6a0c                	ld	a1,16(a2)
ffffffffc0205488:	ea5fe06f          	j	ffffffffc020432c <do_fork>

ffffffffc020548c <sys_exit>:
    return do_exit(error_code);
ffffffffc020548c:	4108                	lw	a0,0(a0)
ffffffffc020548e:	ac8ff06f          	j	ffffffffc0204756 <do_exit>

ffffffffc0205492 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205492:	715d                	addi	sp,sp,-80
ffffffffc0205494:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205496:	000a5497          	auipc	s1,0xa5
ffffffffc020549a:	31248493          	addi	s1,s1,786 # ffffffffc02aa7a8 <current>
ffffffffc020549e:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02054a0:	e0a2                	sd	s0,64(sp)
ffffffffc02054a2:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02054a4:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02054a6:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02054a8:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02054aa:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02054ae:	0327ee63          	bltu	a5,s2,ffffffffc02054ea <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02054b2:	00391713          	slli	a4,s2,0x3
ffffffffc02054b6:	00002797          	auipc	a5,0x2
ffffffffc02054ba:	41278793          	addi	a5,a5,1042 # ffffffffc02078c8 <syscalls>
ffffffffc02054be:	97ba                	add	a5,a5,a4
ffffffffc02054c0:	639c                	ld	a5,0(a5)
ffffffffc02054c2:	c785                	beqz	a5,ffffffffc02054ea <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02054c4:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02054c6:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02054c8:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02054ca:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02054cc:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02054ce:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02054d0:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02054d2:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02054d4:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02054d6:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02054d8:	0028                	addi	a0,sp,8
ffffffffc02054da:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02054dc:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02054de:	e828                	sd	a0,80(s0)
}
ffffffffc02054e0:	6406                	ld	s0,64(sp)
ffffffffc02054e2:	74e2                	ld	s1,56(sp)
ffffffffc02054e4:	7942                	ld	s2,48(sp)
ffffffffc02054e6:	6161                	addi	sp,sp,80
ffffffffc02054e8:	8082                	ret
    print_trapframe(tf);
ffffffffc02054ea:	8522                	mv	a0,s0
ffffffffc02054ec:	ebcfb0ef          	jal	ra,ffffffffc0200ba8 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02054f0:	609c                	ld	a5,0(s1)
ffffffffc02054f2:	86ca                	mv	a3,s2
ffffffffc02054f4:	00002617          	auipc	a2,0x2
ffffffffc02054f8:	38c60613          	addi	a2,a2,908 # ffffffffc0207880 <default_pmm_manager+0x4e0>
ffffffffc02054fc:	43d8                	lw	a4,4(a5)
ffffffffc02054fe:	06200593          	li	a1,98
ffffffffc0205502:	0b478793          	addi	a5,a5,180
ffffffffc0205506:	00002517          	auipc	a0,0x2
ffffffffc020550a:	3aa50513          	addi	a0,a0,938 # ffffffffc02078b0 <default_pmm_manager+0x510>
ffffffffc020550e:	d11fa0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0205512 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205512:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205516:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205518:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020551a:	cb81                	beqz	a5,ffffffffc020552a <strlen+0x18>
        cnt ++;
ffffffffc020551c:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020551e:	00a707b3          	add	a5,a4,a0
ffffffffc0205522:	0007c783          	lbu	a5,0(a5)
ffffffffc0205526:	fbfd                	bnez	a5,ffffffffc020551c <strlen+0xa>
ffffffffc0205528:	8082                	ret
    }
    return cnt;
}
ffffffffc020552a:	8082                	ret

ffffffffc020552c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020552c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020552e:	e589                	bnez	a1,ffffffffc0205538 <strnlen+0xc>
ffffffffc0205530:	a811                	j	ffffffffc0205544 <strnlen+0x18>
        cnt ++;
ffffffffc0205532:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205534:	00f58863          	beq	a1,a5,ffffffffc0205544 <strnlen+0x18>
ffffffffc0205538:	00f50733          	add	a4,a0,a5
ffffffffc020553c:	00074703          	lbu	a4,0(a4)
ffffffffc0205540:	fb6d                	bnez	a4,ffffffffc0205532 <strnlen+0x6>
ffffffffc0205542:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205544:	852e                	mv	a0,a1
ffffffffc0205546:	8082                	ret

ffffffffc0205548 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205548:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020554a:	0005c703          	lbu	a4,0(a1)
ffffffffc020554e:	0785                	addi	a5,a5,1
ffffffffc0205550:	0585                	addi	a1,a1,1
ffffffffc0205552:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205556:	fb75                	bnez	a4,ffffffffc020554a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205558:	8082                	ret

ffffffffc020555a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020555a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020555e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205562:	cb89                	beqz	a5,ffffffffc0205574 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205564:	0505                	addi	a0,a0,1
ffffffffc0205566:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205568:	fee789e3          	beq	a5,a4,ffffffffc020555a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020556c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205570:	9d19                	subw	a0,a0,a4
ffffffffc0205572:	8082                	ret
ffffffffc0205574:	4501                	li	a0,0
ffffffffc0205576:	bfed                	j	ffffffffc0205570 <strcmp+0x16>

ffffffffc0205578 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205578:	c20d                	beqz	a2,ffffffffc020559a <strncmp+0x22>
ffffffffc020557a:	962e                	add	a2,a2,a1
ffffffffc020557c:	a031                	j	ffffffffc0205588 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc020557e:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205580:	00e79a63          	bne	a5,a4,ffffffffc0205594 <strncmp+0x1c>
ffffffffc0205584:	00b60b63          	beq	a2,a1,ffffffffc020559a <strncmp+0x22>
ffffffffc0205588:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc020558c:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020558e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205592:	f7f5                	bnez	a5,ffffffffc020557e <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205594:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0205598:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020559a:	4501                	li	a0,0
ffffffffc020559c:	8082                	ret

ffffffffc020559e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020559e:	00054783          	lbu	a5,0(a0)
ffffffffc02055a2:	c799                	beqz	a5,ffffffffc02055b0 <strchr+0x12>
        if (*s == c) {
ffffffffc02055a4:	00f58763          	beq	a1,a5,ffffffffc02055b2 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02055a8:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02055ac:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02055ae:	fbfd                	bnez	a5,ffffffffc02055a4 <strchr+0x6>
    }
    return NULL;
ffffffffc02055b0:	4501                	li	a0,0
}
ffffffffc02055b2:	8082                	ret

ffffffffc02055b4 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02055b4:	ca01                	beqz	a2,ffffffffc02055c4 <memset+0x10>
ffffffffc02055b6:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02055b8:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02055ba:	0785                	addi	a5,a5,1
ffffffffc02055bc:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02055c0:	fec79de3          	bne	a5,a2,ffffffffc02055ba <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02055c4:	8082                	ret

ffffffffc02055c6 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02055c6:	ca19                	beqz	a2,ffffffffc02055dc <memcpy+0x16>
ffffffffc02055c8:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02055ca:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02055cc:	0005c703          	lbu	a4,0(a1)
ffffffffc02055d0:	0585                	addi	a1,a1,1
ffffffffc02055d2:	0785                	addi	a5,a5,1
ffffffffc02055d4:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02055d8:	fec59ae3          	bne	a1,a2,ffffffffc02055cc <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02055dc:	8082                	ret

ffffffffc02055de <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02055de:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02055e2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02055e4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02055e8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02055ea:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02055ee:	f022                	sd	s0,32(sp)
ffffffffc02055f0:	ec26                	sd	s1,24(sp)
ffffffffc02055f2:	e84a                	sd	s2,16(sp)
ffffffffc02055f4:	f406                	sd	ra,40(sp)
ffffffffc02055f6:	e44e                	sd	s3,8(sp)
ffffffffc02055f8:	84aa                	mv	s1,a0
ffffffffc02055fa:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02055fc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0205600:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0205602:	03067e63          	bgeu	a2,a6,ffffffffc020563e <printnum+0x60>
ffffffffc0205606:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0205608:	00805763          	blez	s0,ffffffffc0205616 <printnum+0x38>
ffffffffc020560c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020560e:	85ca                	mv	a1,s2
ffffffffc0205610:	854e                	mv	a0,s3
ffffffffc0205612:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205614:	fc65                	bnez	s0,ffffffffc020560c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205616:	1a02                	slli	s4,s4,0x20
ffffffffc0205618:	00002797          	auipc	a5,0x2
ffffffffc020561c:	3b078793          	addi	a5,a5,944 # ffffffffc02079c8 <syscalls+0x100>
ffffffffc0205620:	020a5a13          	srli	s4,s4,0x20
ffffffffc0205624:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205626:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205628:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020562c:	70a2                	ld	ra,40(sp)
ffffffffc020562e:	69a2                	ld	s3,8(sp)
ffffffffc0205630:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205632:	85ca                	mv	a1,s2
ffffffffc0205634:	87a6                	mv	a5,s1
}
ffffffffc0205636:	6942                	ld	s2,16(sp)
ffffffffc0205638:	64e2                	ld	s1,24(sp)
ffffffffc020563a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020563c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020563e:	03065633          	divu	a2,a2,a6
ffffffffc0205642:	8722                	mv	a4,s0
ffffffffc0205644:	f9bff0ef          	jal	ra,ffffffffc02055de <printnum>
ffffffffc0205648:	b7f9                	j	ffffffffc0205616 <printnum+0x38>

ffffffffc020564a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020564a:	7119                	addi	sp,sp,-128
ffffffffc020564c:	f4a6                	sd	s1,104(sp)
ffffffffc020564e:	f0ca                	sd	s2,96(sp)
ffffffffc0205650:	ecce                	sd	s3,88(sp)
ffffffffc0205652:	e8d2                	sd	s4,80(sp)
ffffffffc0205654:	e4d6                	sd	s5,72(sp)
ffffffffc0205656:	e0da                	sd	s6,64(sp)
ffffffffc0205658:	fc5e                	sd	s7,56(sp)
ffffffffc020565a:	f06a                	sd	s10,32(sp)
ffffffffc020565c:	fc86                	sd	ra,120(sp)
ffffffffc020565e:	f8a2                	sd	s0,112(sp)
ffffffffc0205660:	f862                	sd	s8,48(sp)
ffffffffc0205662:	f466                	sd	s9,40(sp)
ffffffffc0205664:	ec6e                	sd	s11,24(sp)
ffffffffc0205666:	892a                	mv	s2,a0
ffffffffc0205668:	84ae                	mv	s1,a1
ffffffffc020566a:	8d32                	mv	s10,a2
ffffffffc020566c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020566e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0205672:	5b7d                	li	s6,-1
ffffffffc0205674:	00002a97          	auipc	s5,0x2
ffffffffc0205678:	380a8a93          	addi	s5,s5,896 # ffffffffc02079f4 <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020567c:	00002b97          	auipc	s7,0x2
ffffffffc0205680:	594b8b93          	addi	s7,s7,1428 # ffffffffc0207c10 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205684:	000d4503          	lbu	a0,0(s10)
ffffffffc0205688:	001d0413          	addi	s0,s10,1
ffffffffc020568c:	01350a63          	beq	a0,s3,ffffffffc02056a0 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0205690:	c121                	beqz	a0,ffffffffc02056d0 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0205692:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205694:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0205696:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205698:	fff44503          	lbu	a0,-1(s0)
ffffffffc020569c:	ff351ae3          	bne	a0,s3,ffffffffc0205690 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056a0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02056a4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02056a8:	4c81                	li	s9,0
ffffffffc02056aa:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02056ac:	5c7d                	li	s8,-1
ffffffffc02056ae:	5dfd                	li	s11,-1
ffffffffc02056b0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02056b4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056b6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02056ba:	0ff5f593          	zext.b	a1,a1
ffffffffc02056be:	00140d13          	addi	s10,s0,1
ffffffffc02056c2:	04b56263          	bltu	a0,a1,ffffffffc0205706 <vprintfmt+0xbc>
ffffffffc02056c6:	058a                	slli	a1,a1,0x2
ffffffffc02056c8:	95d6                	add	a1,a1,s5
ffffffffc02056ca:	4194                	lw	a3,0(a1)
ffffffffc02056cc:	96d6                	add	a3,a3,s5
ffffffffc02056ce:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02056d0:	70e6                	ld	ra,120(sp)
ffffffffc02056d2:	7446                	ld	s0,112(sp)
ffffffffc02056d4:	74a6                	ld	s1,104(sp)
ffffffffc02056d6:	7906                	ld	s2,96(sp)
ffffffffc02056d8:	69e6                	ld	s3,88(sp)
ffffffffc02056da:	6a46                	ld	s4,80(sp)
ffffffffc02056dc:	6aa6                	ld	s5,72(sp)
ffffffffc02056de:	6b06                	ld	s6,64(sp)
ffffffffc02056e0:	7be2                	ld	s7,56(sp)
ffffffffc02056e2:	7c42                	ld	s8,48(sp)
ffffffffc02056e4:	7ca2                	ld	s9,40(sp)
ffffffffc02056e6:	7d02                	ld	s10,32(sp)
ffffffffc02056e8:	6de2                	ld	s11,24(sp)
ffffffffc02056ea:	6109                	addi	sp,sp,128
ffffffffc02056ec:	8082                	ret
            padc = '0';
ffffffffc02056ee:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02056f0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056f4:	846a                	mv	s0,s10
ffffffffc02056f6:	00140d13          	addi	s10,s0,1
ffffffffc02056fa:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02056fe:	0ff5f593          	zext.b	a1,a1
ffffffffc0205702:	fcb572e3          	bgeu	a0,a1,ffffffffc02056c6 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0205706:	85a6                	mv	a1,s1
ffffffffc0205708:	02500513          	li	a0,37
ffffffffc020570c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020570e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0205712:	8d22                	mv	s10,s0
ffffffffc0205714:	f73788e3          	beq	a5,s3,ffffffffc0205684 <vprintfmt+0x3a>
ffffffffc0205718:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020571c:	1d7d                	addi	s10,s10,-1
ffffffffc020571e:	ff379de3          	bne	a5,s3,ffffffffc0205718 <vprintfmt+0xce>
ffffffffc0205722:	b78d                	j	ffffffffc0205684 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0205724:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0205728:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020572c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020572e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0205732:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205736:	02d86463          	bltu	a6,a3,ffffffffc020575e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020573a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020573e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0205742:	0186873b          	addw	a4,a3,s8
ffffffffc0205746:	0017171b          	slliw	a4,a4,0x1
ffffffffc020574a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020574c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0205750:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0205752:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0205756:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020575a:	fed870e3          	bgeu	a6,a3,ffffffffc020573a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020575e:	f40ddce3          	bgez	s11,ffffffffc02056b6 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0205762:	8de2                	mv	s11,s8
ffffffffc0205764:	5c7d                	li	s8,-1
ffffffffc0205766:	bf81                	j	ffffffffc02056b6 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0205768:	fffdc693          	not	a3,s11
ffffffffc020576c:	96fd                	srai	a3,a3,0x3f
ffffffffc020576e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205772:	00144603          	lbu	a2,1(s0)
ffffffffc0205776:	2d81                	sext.w	s11,s11
ffffffffc0205778:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020577a:	bf35                	j	ffffffffc02056b6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020577c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205780:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0205784:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205786:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0205788:	bfd9                	j	ffffffffc020575e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020578a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020578c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205790:	01174463          	blt	a4,a7,ffffffffc0205798 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0205794:	1a088e63          	beqz	a7,ffffffffc0205950 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0205798:	000a3603          	ld	a2,0(s4)
ffffffffc020579c:	46c1                	li	a3,16
ffffffffc020579e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02057a0:	2781                	sext.w	a5,a5
ffffffffc02057a2:	876e                	mv	a4,s11
ffffffffc02057a4:	85a6                	mv	a1,s1
ffffffffc02057a6:	854a                	mv	a0,s2
ffffffffc02057a8:	e37ff0ef          	jal	ra,ffffffffc02055de <printnum>
            break;
ffffffffc02057ac:	bde1                	j	ffffffffc0205684 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02057ae:	000a2503          	lw	a0,0(s4)
ffffffffc02057b2:	85a6                	mv	a1,s1
ffffffffc02057b4:	0a21                	addi	s4,s4,8
ffffffffc02057b6:	9902                	jalr	s2
            break;
ffffffffc02057b8:	b5f1                	j	ffffffffc0205684 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02057ba:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057bc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02057c0:	01174463          	blt	a4,a7,ffffffffc02057c8 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02057c4:	18088163          	beqz	a7,ffffffffc0205946 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02057c8:	000a3603          	ld	a2,0(s4)
ffffffffc02057cc:	46a9                	li	a3,10
ffffffffc02057ce:	8a2e                	mv	s4,a1
ffffffffc02057d0:	bfc1                	j	ffffffffc02057a0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057d2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02057d6:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057d8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02057da:	bdf1                	j	ffffffffc02056b6 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02057dc:	85a6                	mv	a1,s1
ffffffffc02057de:	02500513          	li	a0,37
ffffffffc02057e2:	9902                	jalr	s2
            break;
ffffffffc02057e4:	b545                	j	ffffffffc0205684 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057e6:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02057ea:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057ec:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02057ee:	b5e1                	j	ffffffffc02056b6 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02057f0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057f2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02057f6:	01174463          	blt	a4,a7,ffffffffc02057fe <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02057fa:	14088163          	beqz	a7,ffffffffc020593c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02057fe:	000a3603          	ld	a2,0(s4)
ffffffffc0205802:	46a1                	li	a3,8
ffffffffc0205804:	8a2e                	mv	s4,a1
ffffffffc0205806:	bf69                	j	ffffffffc02057a0 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0205808:	03000513          	li	a0,48
ffffffffc020580c:	85a6                	mv	a1,s1
ffffffffc020580e:	e03e                	sd	a5,0(sp)
ffffffffc0205810:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0205812:	85a6                	mv	a1,s1
ffffffffc0205814:	07800513          	li	a0,120
ffffffffc0205818:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020581a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020581c:	6782                	ld	a5,0(sp)
ffffffffc020581e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205820:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0205824:	bfb5                	j	ffffffffc02057a0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205826:	000a3403          	ld	s0,0(s4)
ffffffffc020582a:	008a0713          	addi	a4,s4,8
ffffffffc020582e:	e03a                	sd	a4,0(sp)
ffffffffc0205830:	14040263          	beqz	s0,ffffffffc0205974 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0205834:	0fb05763          	blez	s11,ffffffffc0205922 <vprintfmt+0x2d8>
ffffffffc0205838:	02d00693          	li	a3,45
ffffffffc020583c:	0cd79163          	bne	a5,a3,ffffffffc02058fe <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205840:	00044783          	lbu	a5,0(s0)
ffffffffc0205844:	0007851b          	sext.w	a0,a5
ffffffffc0205848:	cf85                	beqz	a5,ffffffffc0205880 <vprintfmt+0x236>
ffffffffc020584a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020584e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205852:	000c4563          	bltz	s8,ffffffffc020585c <vprintfmt+0x212>
ffffffffc0205856:	3c7d                	addiw	s8,s8,-1
ffffffffc0205858:	036c0263          	beq	s8,s6,ffffffffc020587c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020585c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020585e:	0e0c8e63          	beqz	s9,ffffffffc020595a <vprintfmt+0x310>
ffffffffc0205862:	3781                	addiw	a5,a5,-32
ffffffffc0205864:	0ef47b63          	bgeu	s0,a5,ffffffffc020595a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0205868:	03f00513          	li	a0,63
ffffffffc020586c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020586e:	000a4783          	lbu	a5,0(s4)
ffffffffc0205872:	3dfd                	addiw	s11,s11,-1
ffffffffc0205874:	0a05                	addi	s4,s4,1
ffffffffc0205876:	0007851b          	sext.w	a0,a5
ffffffffc020587a:	ffe1                	bnez	a5,ffffffffc0205852 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020587c:	01b05963          	blez	s11,ffffffffc020588e <vprintfmt+0x244>
ffffffffc0205880:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0205882:	85a6                	mv	a1,s1
ffffffffc0205884:	02000513          	li	a0,32
ffffffffc0205888:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020588a:	fe0d9be3          	bnez	s11,ffffffffc0205880 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020588e:	6a02                	ld	s4,0(sp)
ffffffffc0205890:	bbd5                	j	ffffffffc0205684 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205892:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205894:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0205898:	01174463          	blt	a4,a7,ffffffffc02058a0 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020589c:	08088d63          	beqz	a7,ffffffffc0205936 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02058a0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02058a4:	0a044d63          	bltz	s0,ffffffffc020595e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02058a8:	8622                	mv	a2,s0
ffffffffc02058aa:	8a66                	mv	s4,s9
ffffffffc02058ac:	46a9                	li	a3,10
ffffffffc02058ae:	bdcd                	j	ffffffffc02057a0 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02058b0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02058b4:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02058b6:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02058b8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02058bc:	8fb5                	xor	a5,a5,a3
ffffffffc02058be:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02058c2:	02d74163          	blt	a4,a3,ffffffffc02058e4 <vprintfmt+0x29a>
ffffffffc02058c6:	00369793          	slli	a5,a3,0x3
ffffffffc02058ca:	97de                	add	a5,a5,s7
ffffffffc02058cc:	639c                	ld	a5,0(a5)
ffffffffc02058ce:	cb99                	beqz	a5,ffffffffc02058e4 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02058d0:	86be                	mv	a3,a5
ffffffffc02058d2:	00000617          	auipc	a2,0x0
ffffffffc02058d6:	13e60613          	addi	a2,a2,318 # ffffffffc0205a10 <etext+0x2e>
ffffffffc02058da:	85a6                	mv	a1,s1
ffffffffc02058dc:	854a                	mv	a0,s2
ffffffffc02058de:	0ce000ef          	jal	ra,ffffffffc02059ac <printfmt>
ffffffffc02058e2:	b34d                	j	ffffffffc0205684 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02058e4:	00002617          	auipc	a2,0x2
ffffffffc02058e8:	10460613          	addi	a2,a2,260 # ffffffffc02079e8 <syscalls+0x120>
ffffffffc02058ec:	85a6                	mv	a1,s1
ffffffffc02058ee:	854a                	mv	a0,s2
ffffffffc02058f0:	0bc000ef          	jal	ra,ffffffffc02059ac <printfmt>
ffffffffc02058f4:	bb41                	j	ffffffffc0205684 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02058f6:	00002417          	auipc	s0,0x2
ffffffffc02058fa:	0ea40413          	addi	s0,s0,234 # ffffffffc02079e0 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02058fe:	85e2                	mv	a1,s8
ffffffffc0205900:	8522                	mv	a0,s0
ffffffffc0205902:	e43e                	sd	a5,8(sp)
ffffffffc0205904:	c29ff0ef          	jal	ra,ffffffffc020552c <strnlen>
ffffffffc0205908:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020590c:	01b05b63          	blez	s11,ffffffffc0205922 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0205910:	67a2                	ld	a5,8(sp)
ffffffffc0205912:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205916:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0205918:	85a6                	mv	a1,s1
ffffffffc020591a:	8552                	mv	a0,s4
ffffffffc020591c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020591e:	fe0d9ce3          	bnez	s11,ffffffffc0205916 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205922:	00044783          	lbu	a5,0(s0)
ffffffffc0205926:	00140a13          	addi	s4,s0,1
ffffffffc020592a:	0007851b          	sext.w	a0,a5
ffffffffc020592e:	d3a5                	beqz	a5,ffffffffc020588e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205930:	05e00413          	li	s0,94
ffffffffc0205934:	bf39                	j	ffffffffc0205852 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0205936:	000a2403          	lw	s0,0(s4)
ffffffffc020593a:	b7ad                	j	ffffffffc02058a4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020593c:	000a6603          	lwu	a2,0(s4)
ffffffffc0205940:	46a1                	li	a3,8
ffffffffc0205942:	8a2e                	mv	s4,a1
ffffffffc0205944:	bdb1                	j	ffffffffc02057a0 <vprintfmt+0x156>
ffffffffc0205946:	000a6603          	lwu	a2,0(s4)
ffffffffc020594a:	46a9                	li	a3,10
ffffffffc020594c:	8a2e                	mv	s4,a1
ffffffffc020594e:	bd89                	j	ffffffffc02057a0 <vprintfmt+0x156>
ffffffffc0205950:	000a6603          	lwu	a2,0(s4)
ffffffffc0205954:	46c1                	li	a3,16
ffffffffc0205956:	8a2e                	mv	s4,a1
ffffffffc0205958:	b5a1                	j	ffffffffc02057a0 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020595a:	9902                	jalr	s2
ffffffffc020595c:	bf09                	j	ffffffffc020586e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020595e:	85a6                	mv	a1,s1
ffffffffc0205960:	02d00513          	li	a0,45
ffffffffc0205964:	e03e                	sd	a5,0(sp)
ffffffffc0205966:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0205968:	6782                	ld	a5,0(sp)
ffffffffc020596a:	8a66                	mv	s4,s9
ffffffffc020596c:	40800633          	neg	a2,s0
ffffffffc0205970:	46a9                	li	a3,10
ffffffffc0205972:	b53d                	j	ffffffffc02057a0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0205974:	03b05163          	blez	s11,ffffffffc0205996 <vprintfmt+0x34c>
ffffffffc0205978:	02d00693          	li	a3,45
ffffffffc020597c:	f6d79de3          	bne	a5,a3,ffffffffc02058f6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0205980:	00002417          	auipc	s0,0x2
ffffffffc0205984:	06040413          	addi	s0,s0,96 # ffffffffc02079e0 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205988:	02800793          	li	a5,40
ffffffffc020598c:	02800513          	li	a0,40
ffffffffc0205990:	00140a13          	addi	s4,s0,1
ffffffffc0205994:	bd6d                	j	ffffffffc020584e <vprintfmt+0x204>
ffffffffc0205996:	00002a17          	auipc	s4,0x2
ffffffffc020599a:	04ba0a13          	addi	s4,s4,75 # ffffffffc02079e1 <syscalls+0x119>
ffffffffc020599e:	02800513          	li	a0,40
ffffffffc02059a2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02059a6:	05e00413          	li	s0,94
ffffffffc02059aa:	b565                	j	ffffffffc0205852 <vprintfmt+0x208>

ffffffffc02059ac <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02059ac:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02059ae:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02059b2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02059b4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02059b6:	ec06                	sd	ra,24(sp)
ffffffffc02059b8:	f83a                	sd	a4,48(sp)
ffffffffc02059ba:	fc3e                	sd	a5,56(sp)
ffffffffc02059bc:	e0c2                	sd	a6,64(sp)
ffffffffc02059be:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02059c0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02059c2:	c89ff0ef          	jal	ra,ffffffffc020564a <vprintfmt>
}
ffffffffc02059c6:	60e2                	ld	ra,24(sp)
ffffffffc02059c8:	6161                	addi	sp,sp,80
ffffffffc02059ca:	8082                	ret

ffffffffc02059cc <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02059cc:	9e3707b7          	lui	a5,0x9e370
ffffffffc02059d0:	2785                	addiw	a5,a5,1
ffffffffc02059d2:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02059d6:	02000793          	li	a5,32
ffffffffc02059da:	9f8d                	subw	a5,a5,a1
}
ffffffffc02059dc:	00f5553b          	srlw	a0,a0,a5
ffffffffc02059e0:	8082                	ret
