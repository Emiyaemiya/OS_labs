
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00009297          	auipc	t0,0x9
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0209000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00009297          	auipc	t0,0x9
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0209008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02082b7          	lui	t0,0xc0208
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
ffffffffc020003c:	c0208137          	lui	sp,0xc0208

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
ffffffffc020004a:	00009517          	auipc	a0,0x9
ffffffffc020004e:	fe650513          	addi	a0,a0,-26 # ffffffffc0209030 <buf>
ffffffffc0200052:	0000d617          	auipc	a2,0xd
ffffffffc0200056:	49a60613          	addi	a2,a2,1178 # ffffffffc020d4ec <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	287030ef          	jal	ra,ffffffffc0203ae8 <memset>
    dtb_init();
ffffffffc0200066:	452000ef          	jal	ra,ffffffffc02004b8 <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	053000ef          	jal	ra,ffffffffc02008bc <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00004597          	auipc	a1,0x4
ffffffffc0200072:	ed258593          	addi	a1,a1,-302 # ffffffffc0203f40 <etext+0x6>
ffffffffc0200076:	00004517          	auipc	a0,0x4
ffffffffc020007a:	eea50513          	addi	a0,a0,-278 # ffffffffc0203f60 <etext+0x26>
ffffffffc020007e:	062000ef          	jal	ra,ffffffffc02000e0 <cprintf>

    print_kerninfo();
ffffffffc0200082:	1b8000ef          	jal	ra,ffffffffc020023a <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	2a8010ef          	jal	ra,ffffffffc020132e <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	0a5000ef          	jal	ra,ffffffffc020092e <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	0af000ef          	jal	ra,ffffffffc020093c <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	010020ef          	jal	ra,ffffffffc02020a2 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	680030ef          	jal	ra,ffffffffc0203716 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	7ce000ef          	jal	ra,ffffffffc0200868 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	093000ef          	jal	ra,ffffffffc0200930 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	0c3030ef          	jal	ra,ffffffffc0203964 <cpu_idle>

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
ffffffffc02000ae:	011000ef          	jal	ra,ffffffffc02008be <cons_putc>
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
ffffffffc02000d4:	2cf030ef          	jal	ra,ffffffffc0203ba2 <vprintfmt>
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
ffffffffc02000e2:	02810313          	addi	t1,sp,40 # ffffffffc0208028 <boot_page_table_sv39+0x28>
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
ffffffffc020010a:	299030ef          	jal	ra,ffffffffc0203ba2 <vprintfmt>
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
ffffffffc0200116:	7a80006f          	j	ffffffffc02008be <cons_putc>

ffffffffc020011a <getchar>:
}

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc020011a:	1141                	addi	sp,sp,-16
ffffffffc020011c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020011e:	7d4000ef          	jal	ra,ffffffffc02008f2 <cons_getc>
ffffffffc0200122:	dd75                	beqz	a0,ffffffffc020011e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200124:	60a2                	ld	ra,8(sp)
ffffffffc0200126:	0141                	addi	sp,sp,16
ffffffffc0200128:	8082                	ret

ffffffffc020012a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020012a:	715d                	addi	sp,sp,-80
ffffffffc020012c:	e486                	sd	ra,72(sp)
ffffffffc020012e:	e0a6                	sd	s1,64(sp)
ffffffffc0200130:	fc4a                	sd	s2,56(sp)
ffffffffc0200132:	f84e                	sd	s3,48(sp)
ffffffffc0200134:	f452                	sd	s4,40(sp)
ffffffffc0200136:	f056                	sd	s5,32(sp)
ffffffffc0200138:	ec5a                	sd	s6,24(sp)
ffffffffc020013a:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020013c:	c901                	beqz	a0,ffffffffc020014c <readline+0x22>
ffffffffc020013e:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0200140:	00004517          	auipc	a0,0x4
ffffffffc0200144:	e2850513          	addi	a0,a0,-472 # ffffffffc0203f68 <etext+0x2e>
ffffffffc0200148:	f99ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
readline(const char *prompt) {
ffffffffc020014c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020014e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200150:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200152:	4aa9                	li	s5,10
ffffffffc0200154:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200156:	00009b97          	auipc	s7,0x9
ffffffffc020015a:	edab8b93          	addi	s7,s7,-294 # ffffffffc0209030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020015e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200162:	fb9ff0ef          	jal	ra,ffffffffc020011a <getchar>
        if (c < 0) {
ffffffffc0200166:	00054a63          	bltz	a0,ffffffffc020017a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020016a:	00a95a63          	bge	s2,a0,ffffffffc020017e <readline+0x54>
ffffffffc020016e:	029a5263          	bge	s4,s1,ffffffffc0200192 <readline+0x68>
        c = getchar();
ffffffffc0200172:	fa9ff0ef          	jal	ra,ffffffffc020011a <getchar>
        if (c < 0) {
ffffffffc0200176:	fe055ae3          	bgez	a0,ffffffffc020016a <readline+0x40>
            return NULL;
ffffffffc020017a:	4501                	li	a0,0
ffffffffc020017c:	a091                	j	ffffffffc02001c0 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020017e:	03351463          	bne	a0,s3,ffffffffc02001a6 <readline+0x7c>
ffffffffc0200182:	e8a9                	bnez	s1,ffffffffc02001d4 <readline+0xaa>
        c = getchar();
ffffffffc0200184:	f97ff0ef          	jal	ra,ffffffffc020011a <getchar>
        if (c < 0) {
ffffffffc0200188:	fe0549e3          	bltz	a0,ffffffffc020017a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018c:	fea959e3          	bge	s2,a0,ffffffffc020017e <readline+0x54>
ffffffffc0200190:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200192:	e42a                	sd	a0,8(sp)
ffffffffc0200194:	f83ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            buf[i ++] = c;
ffffffffc0200198:	6522                	ld	a0,8(sp)
ffffffffc020019a:	009b87b3          	add	a5,s7,s1
ffffffffc020019e:	2485                	addiw	s1,s1,1
ffffffffc02001a0:	00a78023          	sb	a0,0(a5)
ffffffffc02001a4:	bf7d                	j	ffffffffc0200162 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001a6:	01550463          	beq	a0,s5,ffffffffc02001ae <readline+0x84>
ffffffffc02001aa:	fb651ce3          	bne	a0,s6,ffffffffc0200162 <readline+0x38>
            cputchar(c);
ffffffffc02001ae:	f69ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            buf[i] = '\0';
ffffffffc02001b2:	00009517          	auipc	a0,0x9
ffffffffc02001b6:	e7e50513          	addi	a0,a0,-386 # ffffffffc0209030 <buf>
ffffffffc02001ba:	94aa                	add	s1,s1,a0
ffffffffc02001bc:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001c0:	60a6                	ld	ra,72(sp)
ffffffffc02001c2:	6486                	ld	s1,64(sp)
ffffffffc02001c4:	7962                	ld	s2,56(sp)
ffffffffc02001c6:	79c2                	ld	s3,48(sp)
ffffffffc02001c8:	7a22                	ld	s4,40(sp)
ffffffffc02001ca:	7a82                	ld	s5,32(sp)
ffffffffc02001cc:	6b62                	ld	s6,24(sp)
ffffffffc02001ce:	6bc2                	ld	s7,16(sp)
ffffffffc02001d0:	6161                	addi	sp,sp,80
ffffffffc02001d2:	8082                	ret
            cputchar(c);
ffffffffc02001d4:	4521                	li	a0,8
ffffffffc02001d6:	f41ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            i --;
ffffffffc02001da:	34fd                	addiw	s1,s1,-1
ffffffffc02001dc:	b759                	j	ffffffffc0200162 <readline+0x38>

ffffffffc02001de <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001de:	0000d317          	auipc	t1,0xd
ffffffffc02001e2:	28a30313          	addi	t1,t1,650 # ffffffffc020d468 <is_panic>
ffffffffc02001e6:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001ea:	715d                	addi	sp,sp,-80
ffffffffc02001ec:	ec06                	sd	ra,24(sp)
ffffffffc02001ee:	e822                	sd	s0,16(sp)
ffffffffc02001f0:	f436                	sd	a3,40(sp)
ffffffffc02001f2:	f83a                	sd	a4,48(sp)
ffffffffc02001f4:	fc3e                	sd	a5,56(sp)
ffffffffc02001f6:	e0c2                	sd	a6,64(sp)
ffffffffc02001f8:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001fa:	020e1a63          	bnez	t3,ffffffffc020022e <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001fe:	4785                	li	a5,1
ffffffffc0200200:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200204:	8432                	mv	s0,a2
ffffffffc0200206:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200208:	862e                	mv	a2,a1
ffffffffc020020a:	85aa                	mv	a1,a0
ffffffffc020020c:	00004517          	auipc	a0,0x4
ffffffffc0200210:	d6450513          	addi	a0,a0,-668 # ffffffffc0203f70 <etext+0x36>
    va_start(ap, fmt);
ffffffffc0200214:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200216:	ecbff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020021a:	65a2                	ld	a1,8(sp)
ffffffffc020021c:	8522                	mv	a0,s0
ffffffffc020021e:	ea3ff0ef          	jal	ra,ffffffffc02000c0 <vcprintf>
    cprintf("\n");
ffffffffc0200222:	00005517          	auipc	a0,0x5
ffffffffc0200226:	bae50513          	addi	a0,a0,-1106 # ffffffffc0204dd0 <commands+0xc08>
ffffffffc020022a:	eb7ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020022e:	708000ef          	jal	ra,ffffffffc0200936 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200232:	4501                	li	a0,0
ffffffffc0200234:	130000ef          	jal	ra,ffffffffc0200364 <kmonitor>
    while (1) {
ffffffffc0200238:	bfed                	j	ffffffffc0200232 <__panic+0x54>

ffffffffc020023a <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc020023a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020023c:	00004517          	auipc	a0,0x4
ffffffffc0200240:	d5450513          	addi	a0,a0,-684 # ffffffffc0203f90 <etext+0x56>
{
ffffffffc0200244:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200246:	e9bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020024a:	00000597          	auipc	a1,0x0
ffffffffc020024e:	e0058593          	addi	a1,a1,-512 # ffffffffc020004a <kern_init>
ffffffffc0200252:	00004517          	auipc	a0,0x4
ffffffffc0200256:	d5e50513          	addi	a0,a0,-674 # ffffffffc0203fb0 <etext+0x76>
ffffffffc020025a:	e87ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020025e:	00004597          	auipc	a1,0x4
ffffffffc0200262:	cdc58593          	addi	a1,a1,-804 # ffffffffc0203f3a <etext>
ffffffffc0200266:	00004517          	auipc	a0,0x4
ffffffffc020026a:	d6a50513          	addi	a0,a0,-662 # ffffffffc0203fd0 <etext+0x96>
ffffffffc020026e:	e73ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200272:	00009597          	auipc	a1,0x9
ffffffffc0200276:	dbe58593          	addi	a1,a1,-578 # ffffffffc0209030 <buf>
ffffffffc020027a:	00004517          	auipc	a0,0x4
ffffffffc020027e:	d7650513          	addi	a0,a0,-650 # ffffffffc0203ff0 <etext+0xb6>
ffffffffc0200282:	e5fff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200286:	0000d597          	auipc	a1,0xd
ffffffffc020028a:	26658593          	addi	a1,a1,614 # ffffffffc020d4ec <end>
ffffffffc020028e:	00004517          	auipc	a0,0x4
ffffffffc0200292:	d8250513          	addi	a0,a0,-638 # ffffffffc0204010 <etext+0xd6>
ffffffffc0200296:	e4bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020029a:	0000d597          	auipc	a1,0xd
ffffffffc020029e:	65158593          	addi	a1,a1,1617 # ffffffffc020d8eb <end+0x3ff>
ffffffffc02002a2:	00000797          	auipc	a5,0x0
ffffffffc02002a6:	da878793          	addi	a5,a5,-600 # ffffffffc020004a <kern_init>
ffffffffc02002aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02002b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002b8:	95be                	add	a1,a1,a5
ffffffffc02002ba:	85a9                	srai	a1,a1,0xa
ffffffffc02002bc:	00004517          	auipc	a0,0x4
ffffffffc02002c0:	d7450513          	addi	a0,a0,-652 # ffffffffc0204030 <etext+0xf6>
}
ffffffffc02002c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002c6:	bd29                	j	ffffffffc02000e0 <cprintf>

ffffffffc02002c8 <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc02002c8:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002ca:	00004617          	auipc	a2,0x4
ffffffffc02002ce:	d9660613          	addi	a2,a2,-618 # ffffffffc0204060 <etext+0x126>
ffffffffc02002d2:	04900593          	li	a1,73
ffffffffc02002d6:	00004517          	auipc	a0,0x4
ffffffffc02002da:	da250513          	addi	a0,a0,-606 # ffffffffc0204078 <etext+0x13e>
{
ffffffffc02002de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002e0:	effff0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02002e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e6:	00004617          	auipc	a2,0x4
ffffffffc02002ea:	daa60613          	addi	a2,a2,-598 # ffffffffc0204090 <etext+0x156>
ffffffffc02002ee:	00004597          	auipc	a1,0x4
ffffffffc02002f2:	dc258593          	addi	a1,a1,-574 # ffffffffc02040b0 <etext+0x176>
ffffffffc02002f6:	00004517          	auipc	a0,0x4
ffffffffc02002fa:	dc250513          	addi	a0,a0,-574 # ffffffffc02040b8 <etext+0x17e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200300:	de1ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200304:	00004617          	auipc	a2,0x4
ffffffffc0200308:	dc460613          	addi	a2,a2,-572 # ffffffffc02040c8 <etext+0x18e>
ffffffffc020030c:	00004597          	auipc	a1,0x4
ffffffffc0200310:	de458593          	addi	a1,a1,-540 # ffffffffc02040f0 <etext+0x1b6>
ffffffffc0200314:	00004517          	auipc	a0,0x4
ffffffffc0200318:	da450513          	addi	a0,a0,-604 # ffffffffc02040b8 <etext+0x17e>
ffffffffc020031c:	dc5ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200320:	00004617          	auipc	a2,0x4
ffffffffc0200324:	de060613          	addi	a2,a2,-544 # ffffffffc0204100 <etext+0x1c6>
ffffffffc0200328:	00004597          	auipc	a1,0x4
ffffffffc020032c:	df858593          	addi	a1,a1,-520 # ffffffffc0204120 <etext+0x1e6>
ffffffffc0200330:	00004517          	auipc	a0,0x4
ffffffffc0200334:	d8850513          	addi	a0,a0,-632 # ffffffffc02040b8 <etext+0x17e>
ffffffffc0200338:	da9ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    return 0;
}
ffffffffc020033c:	60a2                	ld	ra,8(sp)
ffffffffc020033e:	4501                	li	a0,0
ffffffffc0200340:	0141                	addi	sp,sp,16
ffffffffc0200342:	8082                	ret

ffffffffc0200344 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200344:	1141                	addi	sp,sp,-16
ffffffffc0200346:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200348:	ef3ff0ef          	jal	ra,ffffffffc020023a <print_kerninfo>
    return 0;
}
ffffffffc020034c:	60a2                	ld	ra,8(sp)
ffffffffc020034e:	4501                	li	a0,0
ffffffffc0200350:	0141                	addi	sp,sp,16
ffffffffc0200352:	8082                	ret

ffffffffc0200354 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200354:	1141                	addi	sp,sp,-16
ffffffffc0200356:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200358:	f71ff0ef          	jal	ra,ffffffffc02002c8 <print_stackframe>
    return 0;
}
ffffffffc020035c:	60a2                	ld	ra,8(sp)
ffffffffc020035e:	4501                	li	a0,0
ffffffffc0200360:	0141                	addi	sp,sp,16
ffffffffc0200362:	8082                	ret

ffffffffc0200364 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200364:	7115                	addi	sp,sp,-224
ffffffffc0200366:	ed5e                	sd	s7,152(sp)
ffffffffc0200368:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020036a:	00004517          	auipc	a0,0x4
ffffffffc020036e:	dc650513          	addi	a0,a0,-570 # ffffffffc0204130 <etext+0x1f6>
kmonitor(struct trapframe *tf) {
ffffffffc0200372:	ed86                	sd	ra,216(sp)
ffffffffc0200374:	e9a2                	sd	s0,208(sp)
ffffffffc0200376:	e5a6                	sd	s1,200(sp)
ffffffffc0200378:	e1ca                	sd	s2,192(sp)
ffffffffc020037a:	fd4e                	sd	s3,184(sp)
ffffffffc020037c:	f952                	sd	s4,176(sp)
ffffffffc020037e:	f556                	sd	s5,168(sp)
ffffffffc0200380:	f15a                	sd	s6,160(sp)
ffffffffc0200382:	e962                	sd	s8,144(sp)
ffffffffc0200384:	e566                	sd	s9,136(sp)
ffffffffc0200386:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200388:	d59ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020038c:	00004517          	auipc	a0,0x4
ffffffffc0200390:	dcc50513          	addi	a0,a0,-564 # ffffffffc0204158 <etext+0x21e>
ffffffffc0200394:	d4dff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    if (tf != NULL) {
ffffffffc0200398:	000b8563          	beqz	s7,ffffffffc02003a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020039c:	855e                	mv	a0,s7
ffffffffc020039e:	77e000ef          	jal	ra,ffffffffc0200b1c <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02003a2:	4501                	li	a0,0
ffffffffc02003a4:	4581                	li	a1,0
ffffffffc02003a6:	4601                	li	a2,0
ffffffffc02003a8:	48a1                	li	a7,8
ffffffffc02003aa:	00000073          	ecall
ffffffffc02003ae:	00004c17          	auipc	s8,0x4
ffffffffc02003b2:	e1ac0c13          	addi	s8,s8,-486 # ffffffffc02041c8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b6:	00004917          	auipc	s2,0x4
ffffffffc02003ba:	dca90913          	addi	s2,s2,-566 # ffffffffc0204180 <etext+0x246>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003be:	00004497          	auipc	s1,0x4
ffffffffc02003c2:	dca48493          	addi	s1,s1,-566 # ffffffffc0204188 <etext+0x24e>
        if (argc == MAXARGS - 1) {
ffffffffc02003c6:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003c8:	00004b17          	auipc	s6,0x4
ffffffffc02003cc:	dc8b0b13          	addi	s6,s6,-568 # ffffffffc0204190 <etext+0x256>
        argv[argc ++] = buf;
ffffffffc02003d0:	00004a17          	auipc	s4,0x4
ffffffffc02003d4:	ce0a0a13          	addi	s4,s4,-800 # ffffffffc02040b0 <etext+0x176>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d8:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003da:	854a                	mv	a0,s2
ffffffffc02003dc:	d4fff0ef          	jal	ra,ffffffffc020012a <readline>
ffffffffc02003e0:	842a                	mv	s0,a0
ffffffffc02003e2:	dd65                	beqz	a0,ffffffffc02003da <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e4:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003e8:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ea:	e1bd                	bnez	a1,ffffffffc0200450 <kmonitor+0xec>
    if (argc == 0) {
ffffffffc02003ec:	fe0c87e3          	beqz	s9,ffffffffc02003da <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f0:	6582                	ld	a1,0(sp)
ffffffffc02003f2:	00004d17          	auipc	s10,0x4
ffffffffc02003f6:	dd6d0d13          	addi	s10,s10,-554 # ffffffffc02041c8 <commands>
        argv[argc ++] = buf;
ffffffffc02003fa:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003fc:	4401                	li	s0,0
ffffffffc02003fe:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200400:	68e030ef          	jal	ra,ffffffffc0203a8e <strcmp>
ffffffffc0200404:	c919                	beqz	a0,ffffffffc020041a <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200406:	2405                	addiw	s0,s0,1
ffffffffc0200408:	0b540063          	beq	s0,s5,ffffffffc02004a8 <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020040c:	000d3503          	ld	a0,0(s10)
ffffffffc0200410:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200412:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200414:	67a030ef          	jal	ra,ffffffffc0203a8e <strcmp>
ffffffffc0200418:	f57d                	bnez	a0,ffffffffc0200406 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020041a:	00141793          	slli	a5,s0,0x1
ffffffffc020041e:	97a2                	add	a5,a5,s0
ffffffffc0200420:	078e                	slli	a5,a5,0x3
ffffffffc0200422:	97e2                	add	a5,a5,s8
ffffffffc0200424:	6b9c                	ld	a5,16(a5)
ffffffffc0200426:	865e                	mv	a2,s7
ffffffffc0200428:	002c                	addi	a1,sp,8
ffffffffc020042a:	fffc851b          	addiw	a0,s9,-1
ffffffffc020042e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200430:	fa0555e3          	bgez	a0,ffffffffc02003da <kmonitor+0x76>
}
ffffffffc0200434:	60ee                	ld	ra,216(sp)
ffffffffc0200436:	644e                	ld	s0,208(sp)
ffffffffc0200438:	64ae                	ld	s1,200(sp)
ffffffffc020043a:	690e                	ld	s2,192(sp)
ffffffffc020043c:	79ea                	ld	s3,184(sp)
ffffffffc020043e:	7a4a                	ld	s4,176(sp)
ffffffffc0200440:	7aaa                	ld	s5,168(sp)
ffffffffc0200442:	7b0a                	ld	s6,160(sp)
ffffffffc0200444:	6bea                	ld	s7,152(sp)
ffffffffc0200446:	6c4a                	ld	s8,144(sp)
ffffffffc0200448:	6caa                	ld	s9,136(sp)
ffffffffc020044a:	6d0a                	ld	s10,128(sp)
ffffffffc020044c:	612d                	addi	sp,sp,224
ffffffffc020044e:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200450:	8526                	mv	a0,s1
ffffffffc0200452:	680030ef          	jal	ra,ffffffffc0203ad2 <strchr>
ffffffffc0200456:	c901                	beqz	a0,ffffffffc0200466 <kmonitor+0x102>
ffffffffc0200458:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020045c:	00040023          	sb	zero,0(s0)
ffffffffc0200460:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200462:	d5c9                	beqz	a1,ffffffffc02003ec <kmonitor+0x88>
ffffffffc0200464:	b7f5                	j	ffffffffc0200450 <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc0200466:	00044783          	lbu	a5,0(s0)
ffffffffc020046a:	d3c9                	beqz	a5,ffffffffc02003ec <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc020046c:	033c8963          	beq	s9,s3,ffffffffc020049e <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc0200470:	003c9793          	slli	a5,s9,0x3
ffffffffc0200474:	0118                	addi	a4,sp,128
ffffffffc0200476:	97ba                	add	a5,a5,a4
ffffffffc0200478:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020047c:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200480:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200482:	e591                	bnez	a1,ffffffffc020048e <kmonitor+0x12a>
ffffffffc0200484:	b7b5                	j	ffffffffc02003f0 <kmonitor+0x8c>
ffffffffc0200486:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020048a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020048c:	d1a5                	beqz	a1,ffffffffc02003ec <kmonitor+0x88>
ffffffffc020048e:	8526                	mv	a0,s1
ffffffffc0200490:	642030ef          	jal	ra,ffffffffc0203ad2 <strchr>
ffffffffc0200494:	d96d                	beqz	a0,ffffffffc0200486 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200496:	00044583          	lbu	a1,0(s0)
ffffffffc020049a:	d9a9                	beqz	a1,ffffffffc02003ec <kmonitor+0x88>
ffffffffc020049c:	bf55                	j	ffffffffc0200450 <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020049e:	45c1                	li	a1,16
ffffffffc02004a0:	855a                	mv	a0,s6
ffffffffc02004a2:	c3fff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc02004a6:	b7e9                	j	ffffffffc0200470 <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02004a8:	6582                	ld	a1,0(sp)
ffffffffc02004aa:	00004517          	auipc	a0,0x4
ffffffffc02004ae:	d0650513          	addi	a0,a0,-762 # ffffffffc02041b0 <etext+0x276>
ffffffffc02004b2:	c2fff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return 0;
ffffffffc02004b6:	b715                	j	ffffffffc02003da <kmonitor+0x76>

ffffffffc02004b8 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02004b8:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc02004ba:	00004517          	auipc	a0,0x4
ffffffffc02004be:	d5650513          	addi	a0,a0,-682 # ffffffffc0204210 <commands+0x48>
void dtb_init(void) {
ffffffffc02004c2:	fc86                	sd	ra,120(sp)
ffffffffc02004c4:	f8a2                	sd	s0,112(sp)
ffffffffc02004c6:	e8d2                	sd	s4,80(sp)
ffffffffc02004c8:	f4a6                	sd	s1,104(sp)
ffffffffc02004ca:	f0ca                	sd	s2,96(sp)
ffffffffc02004cc:	ecce                	sd	s3,88(sp)
ffffffffc02004ce:	e4d6                	sd	s5,72(sp)
ffffffffc02004d0:	e0da                	sd	s6,64(sp)
ffffffffc02004d2:	fc5e                	sd	s7,56(sp)
ffffffffc02004d4:	f862                	sd	s8,48(sp)
ffffffffc02004d6:	f466                	sd	s9,40(sp)
ffffffffc02004d8:	f06a                	sd	s10,32(sp)
ffffffffc02004da:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc02004dc:	c05ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02004e0:	00009597          	auipc	a1,0x9
ffffffffc02004e4:	b205b583          	ld	a1,-1248(a1) # ffffffffc0209000 <boot_hartid>
ffffffffc02004e8:	00004517          	auipc	a0,0x4
ffffffffc02004ec:	d3850513          	addi	a0,a0,-712 # ffffffffc0204220 <commands+0x58>
ffffffffc02004f0:	bf1ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02004f4:	00009417          	auipc	s0,0x9
ffffffffc02004f8:	b1440413          	addi	s0,s0,-1260 # ffffffffc0209008 <boot_dtb>
ffffffffc02004fc:	600c                	ld	a1,0(s0)
ffffffffc02004fe:	00004517          	auipc	a0,0x4
ffffffffc0200502:	d3250513          	addi	a0,a0,-718 # ffffffffc0204230 <commands+0x68>
ffffffffc0200506:	bdbff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020050a:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020050e:	00004517          	auipc	a0,0x4
ffffffffc0200512:	d3a50513          	addi	a0,a0,-710 # ffffffffc0204248 <commands+0x80>
    if (boot_dtb == 0) {
ffffffffc0200516:	120a0463          	beqz	s4,ffffffffc020063e <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc020051a:	57f5                	li	a5,-3
ffffffffc020051c:	07fa                	slli	a5,a5,0x1e
ffffffffc020051e:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200522:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200524:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200528:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020052a:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020052e:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200532:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200536:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020053a:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020053e:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200540:	8ec9                	or	a3,a3,a0
ffffffffc0200542:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200546:	1b7d                	addi	s6,s6,-1
ffffffffc0200548:	0167f7b3          	and	a5,a5,s6
ffffffffc020054c:	8dd5                	or	a1,a1,a3
ffffffffc020054e:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc0200550:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200554:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc0200556:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed2a01>
ffffffffc020055a:	10f59163          	bne	a1,a5,ffffffffc020065c <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc020055e:	471c                	lw	a5,8(a4)
ffffffffc0200560:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc0200562:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200564:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200568:	0086d51b          	srliw	a0,a3,0x8
ffffffffc020056c:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200570:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200574:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200578:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020057c:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200580:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200584:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200588:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020058c:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020058e:	01146433          	or	s0,s0,a7
ffffffffc0200592:	0086969b          	slliw	a3,a3,0x8
ffffffffc0200596:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020059a:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020059c:	0087979b          	slliw	a5,a5,0x8
ffffffffc02005a0:	8c49                	or	s0,s0,a0
ffffffffc02005a2:	0166f6b3          	and	a3,a3,s6
ffffffffc02005a6:	00ca6a33          	or	s4,s4,a2
ffffffffc02005aa:	0167f7b3          	and	a5,a5,s6
ffffffffc02005ae:	8c55                	or	s0,s0,a3
ffffffffc02005b0:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005b4:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005b6:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005b8:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005ba:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005be:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005c0:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005c2:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc02005c6:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02005c8:	00004917          	auipc	s2,0x4
ffffffffc02005cc:	cd090913          	addi	s2,s2,-816 # ffffffffc0204298 <commands+0xd0>
ffffffffc02005d0:	49bd                	li	s3,15
        switch (token) {
ffffffffc02005d2:	4d91                	li	s11,4
ffffffffc02005d4:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02005d6:	00004497          	auipc	s1,0x4
ffffffffc02005da:	cba48493          	addi	s1,s1,-838 # ffffffffc0204290 <commands+0xc8>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02005de:	000a2703          	lw	a4,0(s4)
ffffffffc02005e2:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005e6:	0087569b          	srliw	a3,a4,0x8
ffffffffc02005ea:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ee:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005f2:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005f6:	0107571b          	srliw	a4,a4,0x10
ffffffffc02005fa:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005fc:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200600:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200604:	8fd5                	or	a5,a5,a3
ffffffffc0200606:	00eb7733          	and	a4,s6,a4
ffffffffc020060a:	8fd9                	or	a5,a5,a4
ffffffffc020060c:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc020060e:	09778c63          	beq	a5,s7,ffffffffc02006a6 <dtb_init+0x1ee>
ffffffffc0200612:	00fbea63          	bltu	s7,a5,ffffffffc0200626 <dtb_init+0x16e>
ffffffffc0200616:	07a78663          	beq	a5,s10,ffffffffc0200682 <dtb_init+0x1ca>
ffffffffc020061a:	4709                	li	a4,2
ffffffffc020061c:	00e79763          	bne	a5,a4,ffffffffc020062a <dtb_init+0x172>
ffffffffc0200620:	4c81                	li	s9,0
ffffffffc0200622:	8a56                	mv	s4,s5
ffffffffc0200624:	bf6d                	j	ffffffffc02005de <dtb_init+0x126>
ffffffffc0200626:	ffb78ee3          	beq	a5,s11,ffffffffc0200622 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc020062a:	00004517          	auipc	a0,0x4
ffffffffc020062e:	ce650513          	addi	a0,a0,-794 # ffffffffc0204310 <commands+0x148>
ffffffffc0200632:	aafff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200636:	00004517          	auipc	a0,0x4
ffffffffc020063a:	d1250513          	addi	a0,a0,-750 # ffffffffc0204348 <commands+0x180>
}
ffffffffc020063e:	7446                	ld	s0,112(sp)
ffffffffc0200640:	70e6                	ld	ra,120(sp)
ffffffffc0200642:	74a6                	ld	s1,104(sp)
ffffffffc0200644:	7906                	ld	s2,96(sp)
ffffffffc0200646:	69e6                	ld	s3,88(sp)
ffffffffc0200648:	6a46                	ld	s4,80(sp)
ffffffffc020064a:	6aa6                	ld	s5,72(sp)
ffffffffc020064c:	6b06                	ld	s6,64(sp)
ffffffffc020064e:	7be2                	ld	s7,56(sp)
ffffffffc0200650:	7c42                	ld	s8,48(sp)
ffffffffc0200652:	7ca2                	ld	s9,40(sp)
ffffffffc0200654:	7d02                	ld	s10,32(sp)
ffffffffc0200656:	6de2                	ld	s11,24(sp)
ffffffffc0200658:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc020065a:	b459                	j	ffffffffc02000e0 <cprintf>
}
ffffffffc020065c:	7446                	ld	s0,112(sp)
ffffffffc020065e:	70e6                	ld	ra,120(sp)
ffffffffc0200660:	74a6                	ld	s1,104(sp)
ffffffffc0200662:	7906                	ld	s2,96(sp)
ffffffffc0200664:	69e6                	ld	s3,88(sp)
ffffffffc0200666:	6a46                	ld	s4,80(sp)
ffffffffc0200668:	6aa6                	ld	s5,72(sp)
ffffffffc020066a:	6b06                	ld	s6,64(sp)
ffffffffc020066c:	7be2                	ld	s7,56(sp)
ffffffffc020066e:	7c42                	ld	s8,48(sp)
ffffffffc0200670:	7ca2                	ld	s9,40(sp)
ffffffffc0200672:	7d02                	ld	s10,32(sp)
ffffffffc0200674:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200676:	00004517          	auipc	a0,0x4
ffffffffc020067a:	bf250513          	addi	a0,a0,-1038 # ffffffffc0204268 <commands+0xa0>
}
ffffffffc020067e:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200680:	b485                	j	ffffffffc02000e0 <cprintf>
                int name_len = strlen(name);
ffffffffc0200682:	8556                	mv	a0,s5
ffffffffc0200684:	3c2030ef          	jal	ra,ffffffffc0203a46 <strlen>
ffffffffc0200688:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020068a:	4619                	li	a2,6
ffffffffc020068c:	85a6                	mv	a1,s1
ffffffffc020068e:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc0200690:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200692:	41a030ef          	jal	ra,ffffffffc0203aac <strncmp>
ffffffffc0200696:	e111                	bnez	a0,ffffffffc020069a <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200698:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc020069a:	0a91                	addi	s5,s5,4
ffffffffc020069c:	9ad2                	add	s5,s5,s4
ffffffffc020069e:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02006a2:	8a56                	mv	s4,s5
ffffffffc02006a4:	bf2d                	j	ffffffffc02005de <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006a6:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006aa:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ae:	0087d71b          	srliw	a4,a5,0x8
ffffffffc02006b2:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b6:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ba:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006be:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02006c2:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c6:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ca:	0087979b          	slliw	a5,a5,0x8
ffffffffc02006ce:	00eaeab3          	or	s5,s5,a4
ffffffffc02006d2:	00fb77b3          	and	a5,s6,a5
ffffffffc02006d6:	00faeab3          	or	s5,s5,a5
ffffffffc02006da:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006dc:	000c9c63          	bnez	s9,ffffffffc02006f4 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02006e0:	1a82                	slli	s5,s5,0x20
ffffffffc02006e2:	00368793          	addi	a5,a3,3
ffffffffc02006e6:	020ada93          	srli	s5,s5,0x20
ffffffffc02006ea:	9abe                	add	s5,s5,a5
ffffffffc02006ec:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02006f0:	8a56                	mv	s4,s5
ffffffffc02006f2:	b5f5                	j	ffffffffc02005de <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006f4:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006f8:	85ca                	mv	a1,s2
ffffffffc02006fa:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006fc:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200700:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200704:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200708:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020070c:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200710:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200712:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200716:	0087979b          	slliw	a5,a5,0x8
ffffffffc020071a:	8d59                	or	a0,a0,a4
ffffffffc020071c:	00fb77b3          	and	a5,s6,a5
ffffffffc0200720:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200722:	1502                	slli	a0,a0,0x20
ffffffffc0200724:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200726:	9522                	add	a0,a0,s0
ffffffffc0200728:	366030ef          	jal	ra,ffffffffc0203a8e <strcmp>
ffffffffc020072c:	66a2                	ld	a3,8(sp)
ffffffffc020072e:	f94d                	bnez	a0,ffffffffc02006e0 <dtb_init+0x228>
ffffffffc0200730:	fb59f8e3          	bgeu	s3,s5,ffffffffc02006e0 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200734:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200738:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020073c:	00004517          	auipc	a0,0x4
ffffffffc0200740:	b6450513          	addi	a0,a0,-1180 # ffffffffc02042a0 <commands+0xd8>
           fdt32_to_cpu(x >> 32);
ffffffffc0200744:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200748:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc020074c:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200750:	0187de1b          	srliw	t3,a5,0x18
ffffffffc0200754:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200758:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020075c:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200760:	0187d693          	srli	a3,a5,0x18
ffffffffc0200764:	01861f1b          	slliw	t5,a2,0x18
ffffffffc0200768:	0087579b          	srliw	a5,a4,0x8
ffffffffc020076c:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200770:	0106561b          	srliw	a2,a2,0x10
ffffffffc0200774:	010f6f33          	or	t5,t5,a6
ffffffffc0200778:	0187529b          	srliw	t0,a4,0x18
ffffffffc020077c:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200780:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200784:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200788:	0186f6b3          	and	a3,a3,s8
ffffffffc020078c:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200790:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200794:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200798:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020079c:	8361                	srli	a4,a4,0x18
ffffffffc020079e:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007a2:	0105d59b          	srliw	a1,a1,0x10
ffffffffc02007a6:	01e6e6b3          	or	a3,a3,t5
ffffffffc02007aa:	00cb7633          	and	a2,s6,a2
ffffffffc02007ae:	0088181b          	slliw	a6,a6,0x8
ffffffffc02007b2:	0085959b          	slliw	a1,a1,0x8
ffffffffc02007b6:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007ba:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007be:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007c2:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007c6:	0088989b          	slliw	a7,a7,0x8
ffffffffc02007ca:	011b78b3          	and	a7,s6,a7
ffffffffc02007ce:	005eeeb3          	or	t4,t4,t0
ffffffffc02007d2:	00c6e733          	or	a4,a3,a2
ffffffffc02007d6:	006c6c33          	or	s8,s8,t1
ffffffffc02007da:	010b76b3          	and	a3,s6,a6
ffffffffc02007de:	00bb7b33          	and	s6,s6,a1
ffffffffc02007e2:	01d7e7b3          	or	a5,a5,t4
ffffffffc02007e6:	016c6b33          	or	s6,s8,s6
ffffffffc02007ea:	01146433          	or	s0,s0,a7
ffffffffc02007ee:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc02007f0:	1702                	slli	a4,a4,0x20
ffffffffc02007f2:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007f4:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02007f6:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007f8:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02007fa:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007fe:	0167eb33          	or	s6,a5,s6
ffffffffc0200802:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200804:	8ddff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200808:	85a2                	mv	a1,s0
ffffffffc020080a:	00004517          	auipc	a0,0x4
ffffffffc020080e:	ab650513          	addi	a0,a0,-1354 # ffffffffc02042c0 <commands+0xf8>
ffffffffc0200812:	8cfff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200816:	014b5613          	srli	a2,s6,0x14
ffffffffc020081a:	85da                	mv	a1,s6
ffffffffc020081c:	00004517          	auipc	a0,0x4
ffffffffc0200820:	abc50513          	addi	a0,a0,-1348 # ffffffffc02042d8 <commands+0x110>
ffffffffc0200824:	8bdff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200828:	008b05b3          	add	a1,s6,s0
ffffffffc020082c:	15fd                	addi	a1,a1,-1
ffffffffc020082e:	00004517          	auipc	a0,0x4
ffffffffc0200832:	aca50513          	addi	a0,a0,-1334 # ffffffffc02042f8 <commands+0x130>
ffffffffc0200836:	8abff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0204348 <commands+0x180>
        memory_base = mem_base;
ffffffffc0200842:	0000d797          	auipc	a5,0xd
ffffffffc0200846:	c287b723          	sd	s0,-978(a5) # ffffffffc020d470 <memory_base>
        memory_size = mem_size;
ffffffffc020084a:	0000d797          	auipc	a5,0xd
ffffffffc020084e:	c367b723          	sd	s6,-978(a5) # ffffffffc020d478 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200852:	b3f5                	j	ffffffffc020063e <dtb_init+0x186>

ffffffffc0200854 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc0200854:	0000d517          	auipc	a0,0xd
ffffffffc0200858:	c1c53503          	ld	a0,-996(a0) # ffffffffc020d470 <memory_base>
ffffffffc020085c:	8082                	ret

ffffffffc020085e <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc020085e:	0000d517          	auipc	a0,0xd
ffffffffc0200862:	c1a53503          	ld	a0,-998(a0) # ffffffffc020d478 <memory_size>
ffffffffc0200866:	8082                	ret

ffffffffc0200868 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200868:	67e1                	lui	a5,0x18
ffffffffc020086a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020086e:	0000d717          	auipc	a4,0xd
ffffffffc0200872:	c0f73d23          	sd	a5,-998(a4) # ffffffffc020d488 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200876:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020087a:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020087c:	953e                	add	a0,a0,a5
ffffffffc020087e:	4601                	li	a2,0
ffffffffc0200880:	4881                	li	a7,0
ffffffffc0200882:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200886:	02000793          	li	a5,32
ffffffffc020088a:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020088e:	00004517          	auipc	a0,0x4
ffffffffc0200892:	ad250513          	addi	a0,a0,-1326 # ffffffffc0204360 <commands+0x198>
    ticks = 0;
ffffffffc0200896:	0000d797          	auipc	a5,0xd
ffffffffc020089a:	be07b523          	sd	zero,-1046(a5) # ffffffffc020d480 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020089e:	843ff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc02008a2 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02008a2:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02008a6:	0000d797          	auipc	a5,0xd
ffffffffc02008aa:	be27b783          	ld	a5,-1054(a5) # ffffffffc020d488 <timebase>
ffffffffc02008ae:	953e                	add	a0,a0,a5
ffffffffc02008b0:	4581                	li	a1,0
ffffffffc02008b2:	4601                	li	a2,0
ffffffffc02008b4:	4881                	li	a7,0
ffffffffc02008b6:	00000073          	ecall
ffffffffc02008ba:	8082                	ret

ffffffffc02008bc <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02008bc:	8082                	ret

ffffffffc02008be <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02008be:	100027f3          	csrr	a5,sstatus
ffffffffc02008c2:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02008c4:	0ff57513          	zext.b	a0,a0
ffffffffc02008c8:	e799                	bnez	a5,ffffffffc02008d6 <cons_putc+0x18>
ffffffffc02008ca:	4581                	li	a1,0
ffffffffc02008cc:	4601                	li	a2,0
ffffffffc02008ce:	4885                	li	a7,1
ffffffffc02008d0:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02008d4:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02008d6:	1101                	addi	sp,sp,-32
ffffffffc02008d8:	ec06                	sd	ra,24(sp)
ffffffffc02008da:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02008dc:	05a000ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc02008e0:	6522                	ld	a0,8(sp)
ffffffffc02008e2:	4581                	li	a1,0
ffffffffc02008e4:	4601                	li	a2,0
ffffffffc02008e6:	4885                	li	a7,1
ffffffffc02008e8:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02008ec:	60e2                	ld	ra,24(sp)
ffffffffc02008ee:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02008f0:	a081                	j	ffffffffc0200930 <intr_enable>

ffffffffc02008f2 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02008f2:	100027f3          	csrr	a5,sstatus
ffffffffc02008f6:	8b89                	andi	a5,a5,2
ffffffffc02008f8:	eb89                	bnez	a5,ffffffffc020090a <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02008fa:	4501                	li	a0,0
ffffffffc02008fc:	4581                	li	a1,0
ffffffffc02008fe:	4601                	li	a2,0
ffffffffc0200900:	4889                	li	a7,2
ffffffffc0200902:	00000073          	ecall
ffffffffc0200906:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200908:	8082                	ret
int cons_getc(void) {
ffffffffc020090a:	1101                	addi	sp,sp,-32
ffffffffc020090c:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020090e:	028000ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0200912:	4501                	li	a0,0
ffffffffc0200914:	4581                	li	a1,0
ffffffffc0200916:	4601                	li	a2,0
ffffffffc0200918:	4889                	li	a7,2
ffffffffc020091a:	00000073          	ecall
ffffffffc020091e:	2501                	sext.w	a0,a0
ffffffffc0200920:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200922:	00e000ef          	jal	ra,ffffffffc0200930 <intr_enable>
}
ffffffffc0200926:	60e2                	ld	ra,24(sp)
ffffffffc0200928:	6522                	ld	a0,8(sp)
ffffffffc020092a:	6105                	addi	sp,sp,32
ffffffffc020092c:	8082                	ret

ffffffffc020092e <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020092e:	8082                	ret

ffffffffc0200930 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200930:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200934:	8082                	ret

ffffffffc0200936 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200936:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020093a:	8082                	ret

ffffffffc020093c <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020093c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200940:	00000797          	auipc	a5,0x0
ffffffffc0200944:	43878793          	addi	a5,a5,1080 # ffffffffc0200d78 <__alltraps>
ffffffffc0200948:	10579073          	csrw	stvec,a5
}
ffffffffc020094c:	8082                	ret

ffffffffc020094e <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020094e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200950:	1141                	addi	sp,sp,-16
ffffffffc0200952:	e022                	sd	s0,0(sp)
ffffffffc0200954:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0204380 <commands+0x1b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020095e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200960:	f80ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200964:	640c                	ld	a1,8(s0)
ffffffffc0200966:	00004517          	auipc	a0,0x4
ffffffffc020096a:	a3250513          	addi	a0,a0,-1486 # ffffffffc0204398 <commands+0x1d0>
ffffffffc020096e:	f72ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200972:	680c                	ld	a1,16(s0)
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	a3c50513          	addi	a0,a0,-1476 # ffffffffc02043b0 <commands+0x1e8>
ffffffffc020097c:	f64ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200980:	6c0c                	ld	a1,24(s0)
ffffffffc0200982:	00004517          	auipc	a0,0x4
ffffffffc0200986:	a4650513          	addi	a0,a0,-1466 # ffffffffc02043c8 <commands+0x200>
ffffffffc020098a:	f56ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc020098e:	700c                	ld	a1,32(s0)
ffffffffc0200990:	00004517          	auipc	a0,0x4
ffffffffc0200994:	a5050513          	addi	a0,a0,-1456 # ffffffffc02043e0 <commands+0x218>
ffffffffc0200998:	f48ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020099c:	740c                	ld	a1,40(s0)
ffffffffc020099e:	00004517          	auipc	a0,0x4
ffffffffc02009a2:	a5a50513          	addi	a0,a0,-1446 # ffffffffc02043f8 <commands+0x230>
ffffffffc02009a6:	f3aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02009aa:	780c                	ld	a1,48(s0)
ffffffffc02009ac:	00004517          	auipc	a0,0x4
ffffffffc02009b0:	a6450513          	addi	a0,a0,-1436 # ffffffffc0204410 <commands+0x248>
ffffffffc02009b4:	f2cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02009b8:	7c0c                	ld	a1,56(s0)
ffffffffc02009ba:	00004517          	auipc	a0,0x4
ffffffffc02009be:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0204428 <commands+0x260>
ffffffffc02009c2:	f1eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02009c6:	602c                	ld	a1,64(s0)
ffffffffc02009c8:	00004517          	auipc	a0,0x4
ffffffffc02009cc:	a7850513          	addi	a0,a0,-1416 # ffffffffc0204440 <commands+0x278>
ffffffffc02009d0:	f10ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009d4:	642c                	ld	a1,72(s0)
ffffffffc02009d6:	00004517          	auipc	a0,0x4
ffffffffc02009da:	a8250513          	addi	a0,a0,-1406 # ffffffffc0204458 <commands+0x290>
ffffffffc02009de:	f02ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009e2:	682c                	ld	a1,80(s0)
ffffffffc02009e4:	00004517          	auipc	a0,0x4
ffffffffc02009e8:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0204470 <commands+0x2a8>
ffffffffc02009ec:	ef4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009f0:	6c2c                	ld	a1,88(s0)
ffffffffc02009f2:	00004517          	auipc	a0,0x4
ffffffffc02009f6:	a9650513          	addi	a0,a0,-1386 # ffffffffc0204488 <commands+0x2c0>
ffffffffc02009fa:	ee6ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02009fe:	702c                	ld	a1,96(s0)
ffffffffc0200a00:	00004517          	auipc	a0,0x4
ffffffffc0200a04:	aa050513          	addi	a0,a0,-1376 # ffffffffc02044a0 <commands+0x2d8>
ffffffffc0200a08:	ed8ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a0c:	742c                	ld	a1,104(s0)
ffffffffc0200a0e:	00004517          	auipc	a0,0x4
ffffffffc0200a12:	aaa50513          	addi	a0,a0,-1366 # ffffffffc02044b8 <commands+0x2f0>
ffffffffc0200a16:	ecaff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200a1a:	782c                	ld	a1,112(s0)
ffffffffc0200a1c:	00004517          	auipc	a0,0x4
ffffffffc0200a20:	ab450513          	addi	a0,a0,-1356 # ffffffffc02044d0 <commands+0x308>
ffffffffc0200a24:	ebcff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200a28:	7c2c                	ld	a1,120(s0)
ffffffffc0200a2a:	00004517          	auipc	a0,0x4
ffffffffc0200a2e:	abe50513          	addi	a0,a0,-1346 # ffffffffc02044e8 <commands+0x320>
ffffffffc0200a32:	eaeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a36:	604c                	ld	a1,128(s0)
ffffffffc0200a38:	00004517          	auipc	a0,0x4
ffffffffc0200a3c:	ac850513          	addi	a0,a0,-1336 # ffffffffc0204500 <commands+0x338>
ffffffffc0200a40:	ea0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a44:	644c                	ld	a1,136(s0)
ffffffffc0200a46:	00004517          	auipc	a0,0x4
ffffffffc0200a4a:	ad250513          	addi	a0,a0,-1326 # ffffffffc0204518 <commands+0x350>
ffffffffc0200a4e:	e92ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a52:	684c                	ld	a1,144(s0)
ffffffffc0200a54:	00004517          	auipc	a0,0x4
ffffffffc0200a58:	adc50513          	addi	a0,a0,-1316 # ffffffffc0204530 <commands+0x368>
ffffffffc0200a5c:	e84ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a60:	6c4c                	ld	a1,152(s0)
ffffffffc0200a62:	00004517          	auipc	a0,0x4
ffffffffc0200a66:	ae650513          	addi	a0,a0,-1306 # ffffffffc0204548 <commands+0x380>
ffffffffc0200a6a:	e76ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a6e:	704c                	ld	a1,160(s0)
ffffffffc0200a70:	00004517          	auipc	a0,0x4
ffffffffc0200a74:	af050513          	addi	a0,a0,-1296 # ffffffffc0204560 <commands+0x398>
ffffffffc0200a78:	e68ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a7c:	744c                	ld	a1,168(s0)
ffffffffc0200a7e:	00004517          	auipc	a0,0x4
ffffffffc0200a82:	afa50513          	addi	a0,a0,-1286 # ffffffffc0204578 <commands+0x3b0>
ffffffffc0200a86:	e5aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a8a:	784c                	ld	a1,176(s0)
ffffffffc0200a8c:	00004517          	auipc	a0,0x4
ffffffffc0200a90:	b0450513          	addi	a0,a0,-1276 # ffffffffc0204590 <commands+0x3c8>
ffffffffc0200a94:	e4cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200a98:	7c4c                	ld	a1,184(s0)
ffffffffc0200a9a:	00004517          	auipc	a0,0x4
ffffffffc0200a9e:	b0e50513          	addi	a0,a0,-1266 # ffffffffc02045a8 <commands+0x3e0>
ffffffffc0200aa2:	e3eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200aa6:	606c                	ld	a1,192(s0)
ffffffffc0200aa8:	00004517          	auipc	a0,0x4
ffffffffc0200aac:	b1850513          	addi	a0,a0,-1256 # ffffffffc02045c0 <commands+0x3f8>
ffffffffc0200ab0:	e30ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200ab4:	646c                	ld	a1,200(s0)
ffffffffc0200ab6:	00004517          	auipc	a0,0x4
ffffffffc0200aba:	b2250513          	addi	a0,a0,-1246 # ffffffffc02045d8 <commands+0x410>
ffffffffc0200abe:	e22ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200ac2:	686c                	ld	a1,208(s0)
ffffffffc0200ac4:	00004517          	auipc	a0,0x4
ffffffffc0200ac8:	b2c50513          	addi	a0,a0,-1236 # ffffffffc02045f0 <commands+0x428>
ffffffffc0200acc:	e14ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200ad0:	6c6c                	ld	a1,216(s0)
ffffffffc0200ad2:	00004517          	auipc	a0,0x4
ffffffffc0200ad6:	b3650513          	addi	a0,a0,-1226 # ffffffffc0204608 <commands+0x440>
ffffffffc0200ada:	e06ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200ade:	706c                	ld	a1,224(s0)
ffffffffc0200ae0:	00004517          	auipc	a0,0x4
ffffffffc0200ae4:	b4050513          	addi	a0,a0,-1216 # ffffffffc0204620 <commands+0x458>
ffffffffc0200ae8:	df8ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200aec:	746c                	ld	a1,232(s0)
ffffffffc0200aee:	00004517          	auipc	a0,0x4
ffffffffc0200af2:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0204638 <commands+0x470>
ffffffffc0200af6:	deaff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200afa:	786c                	ld	a1,240(s0)
ffffffffc0200afc:	00004517          	auipc	a0,0x4
ffffffffc0200b00:	b5450513          	addi	a0,a0,-1196 # ffffffffc0204650 <commands+0x488>
ffffffffc0200b04:	ddcff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b08:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b0a:	6402                	ld	s0,0(sp)
ffffffffc0200b0c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b0e:	00004517          	auipc	a0,0x4
ffffffffc0200b12:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0204668 <commands+0x4a0>
}
ffffffffc0200b16:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b18:	dc8ff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200b1c <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200b1c:	1141                	addi	sp,sp,-16
ffffffffc0200b1e:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b20:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200b22:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b24:	00004517          	auipc	a0,0x4
ffffffffc0200b28:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0204680 <commands+0x4b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200b2c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b2e:	db2ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200b32:	8522                	mv	a0,s0
ffffffffc0200b34:	e1bff0ef          	jal	ra,ffffffffc020094e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200b38:	10043583          	ld	a1,256(s0)
ffffffffc0200b3c:	00004517          	auipc	a0,0x4
ffffffffc0200b40:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0204698 <commands+0x4d0>
ffffffffc0200b44:	d9cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b48:	10843583          	ld	a1,264(s0)
ffffffffc0200b4c:	00004517          	auipc	a0,0x4
ffffffffc0200b50:	b6450513          	addi	a0,a0,-1180 # ffffffffc02046b0 <commands+0x4e8>
ffffffffc0200b54:	d8cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200b58:	11043583          	ld	a1,272(s0)
ffffffffc0200b5c:	00004517          	auipc	a0,0x4
ffffffffc0200b60:	b6c50513          	addi	a0,a0,-1172 # ffffffffc02046c8 <commands+0x500>
ffffffffc0200b64:	d7cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b68:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b6c:	6402                	ld	s0,0(sp)
ffffffffc0200b6e:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b70:	00004517          	auipc	a0,0x4
ffffffffc0200b74:	b7050513          	addi	a0,a0,-1168 # ffffffffc02046e0 <commands+0x518>
}
ffffffffc0200b78:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b7a:	d66ff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200b7e <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    static int ticks = 0;
    static int print_num = 0;
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200b7e:	11853783          	ld	a5,280(a0)
ffffffffc0200b82:	472d                	li	a4,11
ffffffffc0200b84:	0786                	slli	a5,a5,0x1
ffffffffc0200b86:	8385                	srli	a5,a5,0x1
ffffffffc0200b88:	08f76263          	bltu	a4,a5,ffffffffc0200c0c <interrupt_handler+0x8e>
ffffffffc0200b8c:	00004717          	auipc	a4,0x4
ffffffffc0200b90:	c3470713          	addi	a4,a4,-972 # ffffffffc02047c0 <commands+0x5f8>
ffffffffc0200b94:	078a                	slli	a5,a5,0x2
ffffffffc0200b96:	97ba                	add	a5,a5,a4
ffffffffc0200b98:	439c                	lw	a5,0(a5)
ffffffffc0200b9a:	97ba                	add	a5,a5,a4
ffffffffc0200b9c:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc0200b9e:	00004517          	auipc	a0,0x4
ffffffffc0200ba2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0204758 <commands+0x590>
ffffffffc0200ba6:	d3aff06f          	j	ffffffffc02000e0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc0200baa:	00004517          	auipc	a0,0x4
ffffffffc0200bae:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0204738 <commands+0x570>
ffffffffc0200bb2:	d2eff06f          	j	ffffffffc02000e0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200bb6:	00004517          	auipc	a0,0x4
ffffffffc0200bba:	b4250513          	addi	a0,a0,-1214 # ffffffffc02046f8 <commands+0x530>
ffffffffc0200bbe:	d22ff06f          	j	ffffffffc02000e0 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc0200bc2:	00004517          	auipc	a0,0x4
ffffffffc0200bc6:	bb650513          	addi	a0,a0,-1098 # ffffffffc0204778 <commands+0x5b0>
ffffffffc0200bca:	d16ff06f          	j	ffffffffc02000e0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200bce:	1141                	addi	sp,sp,-16
ffffffffc0200bd0:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
ffffffffc0200bd2:	cd1ff0ef          	jal	ra,ffffffffc02008a2 <clock_set_next_event>
            ticks++;
ffffffffc0200bd6:	0000d697          	auipc	a3,0xd
ffffffffc0200bda:	8be68693          	addi	a3,a3,-1858 # ffffffffc020d494 <ticks.1>
ffffffffc0200bde:	429c                	lw	a5,0(a3)
            if (ticks % TICK_NUM == 0) {
ffffffffc0200be0:	06400713          	li	a4,100
            ticks++;
ffffffffc0200be4:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0) {
ffffffffc0200be6:	02e7e73b          	remw	a4,a5,a4
            ticks++;
ffffffffc0200bea:	c29c                	sw	a5,0(a3)
            if (ticks % TICK_NUM == 0) {
ffffffffc0200bec:	c30d                	beqz	a4,ffffffffc0200c0e <interrupt_handler+0x90>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200bee:	60a2                	ld	ra,8(sp)
ffffffffc0200bf0:	0141                	addi	sp,sp,16
ffffffffc0200bf2:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200bf4:	00004517          	auipc	a0,0x4
ffffffffc0200bf8:	bac50513          	addi	a0,a0,-1108 # ffffffffc02047a0 <commands+0x5d8>
ffffffffc0200bfc:	ce4ff06f          	j	ffffffffc02000e0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200c00:	00004517          	auipc	a0,0x4
ffffffffc0200c04:	b1850513          	addi	a0,a0,-1256 # ffffffffc0204718 <commands+0x550>
ffffffffc0200c08:	cd8ff06f          	j	ffffffffc02000e0 <cprintf>
            print_trapframe(tf);
ffffffffc0200c0c:	bf01                	j	ffffffffc0200b1c <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c0e:	06400593          	li	a1,100
ffffffffc0200c12:	00004517          	auipc	a0,0x4
ffffffffc0200c16:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0204790 <commands+0x5c8>
ffffffffc0200c1a:	cc6ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
                print_num++;
ffffffffc0200c1e:	0000d717          	auipc	a4,0xd
ffffffffc0200c22:	87270713          	addi	a4,a4,-1934 # ffffffffc020d490 <print_num.0>
ffffffffc0200c26:	431c                	lw	a5,0(a4)
                if (print_num == 10) { 
ffffffffc0200c28:	46a9                	li	a3,10
                print_num++;
ffffffffc0200c2a:	0017861b          	addiw	a2,a5,1
ffffffffc0200c2e:	c310                	sw	a2,0(a4)
                if (print_num == 10) { 
ffffffffc0200c30:	fad61fe3          	bne	a2,a3,ffffffffc0200bee <interrupt_handler+0x70>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200c34:	4501                	li	a0,0
ffffffffc0200c36:	4581                	li	a1,0
ffffffffc0200c38:	4601                	li	a2,0
ffffffffc0200c3a:	48a1                	li	a7,8
ffffffffc0200c3c:	00000073          	ecall
}
ffffffffc0200c40:	b77d                	j	ffffffffc0200bee <interrupt_handler+0x70>

ffffffffc0200c42 <exception_handler>:
    uint16_t half;
    memcpy(&half, (void *)epc, sizeof(half));
    return (half & 0x3) != 0x3 ? 2 : 4;
}

void exception_handler(struct trapframe *tf) {
ffffffffc0200c42:	7179                	addi	sp,sp,-48
ffffffffc0200c44:	ec26                	sd	s1,24(sp)
    switch (tf->cause) {
ffffffffc0200c46:	11853483          	ld	s1,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200c4a:	f406                	sd	ra,40(sp)
ffffffffc0200c4c:	f022                	sd	s0,32(sp)
ffffffffc0200c4e:	47ad                	li	a5,11
ffffffffc0200c50:	0a97e863          	bltu	a5,s1,ffffffffc0200d00 <exception_handler+0xbe>
ffffffffc0200c54:	00004697          	auipc	a3,0x4
ffffffffc0200c58:	ca868693          	addi	a3,a3,-856 # ffffffffc02048fc <commands+0x734>
ffffffffc0200c5c:	00249713          	slli	a4,s1,0x2
ffffffffc0200c60:	9736                	add	a4,a4,a3
ffffffffc0200c62:	431c                	lw	a5,0(a4)
ffffffffc0200c64:	842a                	mv	s0,a0
ffffffffc0200c66:	97b6                	add	a5,a5,a3
ffffffffc0200c68:	8782                	jr	a5
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            // 避免递归打印，这里只打印一行简讯
            cprintf("Illegal instruction at %p\n", tf->epc);
ffffffffc0200c6a:	10853583          	ld	a1,264(a0)
ffffffffc0200c6e:	00004517          	auipc	a0,0x4
ffffffffc0200c72:	b8250513          	addi	a0,a0,-1150 # ffffffffc02047f0 <commands+0x628>
ffffffffc0200c76:	c6aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
            cprintf("Exception type:Illegal instruction\n");
ffffffffc0200c7a:	00004517          	auipc	a0,0x4
ffffffffc0200c7e:	b9650513          	addi	a0,a0,-1130 # ffffffffc0204810 <commands+0x648>
ffffffffc0200c82:	c5eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    memcpy(&half, (void *)epc, sizeof(half));
ffffffffc0200c86:	10843583          	ld	a1,264(s0)
ffffffffc0200c8a:	4609                	li	a2,2
ffffffffc0200c8c:	00e10513          	addi	a0,sp,14
ffffffffc0200c90:	66b020ef          	jal	ra,ffffffffc0203afa <memcpy>
    return (half & 0x3) != 0x3 ? 2 : 4;
ffffffffc0200c94:	00e15783          	lhu	a5,14(sp)
ffffffffc0200c98:	470d                	li	a4,3
ffffffffc0200c9a:	8b8d                	andi	a5,a5,3
ffffffffc0200c9c:	06e78763          	beq	a5,a4,ffffffffc0200d0a <exception_handler+0xc8>
            tf->epc += insn_len(tf->epc);
ffffffffc0200ca0:	10843783          	ld	a5,264(s0)
ffffffffc0200ca4:	94be                	add	s1,s1,a5
ffffffffc0200ca6:	10943423          	sd	s1,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200caa:	70a2                	ld	ra,40(sp)
ffffffffc0200cac:	7402                	ld	s0,32(sp)
ffffffffc0200cae:	64e2                	ld	s1,24(sp)
ffffffffc0200cb0:	6145                	addi	sp,sp,48
ffffffffc0200cb2:	8082                	ret
            cprintf("ebreak at =%p\n", tf->epc);
ffffffffc0200cb4:	10853583          	ld	a1,264(a0)
ffffffffc0200cb8:	00004517          	auipc	a0,0x4
ffffffffc0200cbc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0204838 <commands+0x670>
ffffffffc0200cc0:	c20ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
            cprintf("Exception type:breakpoint\n");
ffffffffc0200cc4:	00004517          	auipc	a0,0x4
ffffffffc0200cc8:	b8450513          	addi	a0,a0,-1148 # ffffffffc0204848 <commands+0x680>
ffffffffc0200ccc:	c14ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    memcpy(&half, (void *)epc, sizeof(half));
ffffffffc0200cd0:	10843583          	ld	a1,264(s0)
ffffffffc0200cd4:	4609                	li	a2,2
ffffffffc0200cd6:	00e10513          	addi	a0,sp,14
ffffffffc0200cda:	621020ef          	jal	ra,ffffffffc0203afa <memcpy>
    return (half & 0x3) != 0x3 ? 2 : 4;
ffffffffc0200cde:	00e15703          	lhu	a4,14(sp)
ffffffffc0200ce2:	478d                	li	a5,3
ffffffffc0200ce4:	4689                	li	a3,2
ffffffffc0200ce6:	8b0d                	andi	a4,a4,3
ffffffffc0200ce8:	02f70363          	beq	a4,a5,ffffffffc0200d0e <exception_handler+0xcc>
            tf->epc += insn_len(tf->epc);
ffffffffc0200cec:	10843783          	ld	a5,264(s0)
}
ffffffffc0200cf0:	70a2                	ld	ra,40(sp)
ffffffffc0200cf2:	64e2                	ld	s1,24(sp)
            tf->epc += insn_len(tf->epc);
ffffffffc0200cf4:	97b6                	add	a5,a5,a3
ffffffffc0200cf6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200cfa:	7402                	ld	s0,32(sp)
ffffffffc0200cfc:	6145                	addi	sp,sp,48
ffffffffc0200cfe:	8082                	ret
ffffffffc0200d00:	7402                	ld	s0,32(sp)
ffffffffc0200d02:	70a2                	ld	ra,40(sp)
ffffffffc0200d04:	64e2                	ld	s1,24(sp)
ffffffffc0200d06:	6145                	addi	sp,sp,48
            print_trapframe(tf);
ffffffffc0200d08:	bd11                	j	ffffffffc0200b1c <print_trapframe>
    return (half & 0x3) != 0x3 ? 2 : 4;
ffffffffc0200d0a:	4491                	li	s1,4
ffffffffc0200d0c:	bf51                	j	ffffffffc0200ca0 <exception_handler+0x5e>
ffffffffc0200d0e:	4691                	li	a3,4
ffffffffc0200d10:	bff1                	j	ffffffffc0200cec <exception_handler+0xaa>
            cprintf("Load page fault: sepc=%p stval=%p\n", tf->epc, tf->badvaddr);
ffffffffc0200d12:	11053603          	ld	a2,272(a0)
ffffffffc0200d16:	10853583          	ld	a1,264(a0)
ffffffffc0200d1a:	00004517          	auipc	a0,0x4
ffffffffc0200d1e:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0204868 <commands+0x6a0>
ffffffffc0200d22:	bbeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
            panic("kernel load fault");
ffffffffc0200d26:	00004617          	auipc	a2,0x4
ffffffffc0200d2a:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0204890 <commands+0x6c8>
ffffffffc0200d2e:	0da00593          	li	a1,218
ffffffffc0200d32:	00004517          	auipc	a0,0x4
ffffffffc0200d36:	b7650513          	addi	a0,a0,-1162 # ffffffffc02048a8 <commands+0x6e0>
ffffffffc0200d3a:	ca4ff0ef          	jal	ra,ffffffffc02001de <__panic>
            cprintf("Store page fault: sepc=%p stval=%p\n", tf->epc, tf->badvaddr);
ffffffffc0200d3e:	11053603          	ld	a2,272(a0)
ffffffffc0200d42:	10853583          	ld	a1,264(a0)
ffffffffc0200d46:	00004517          	auipc	a0,0x4
ffffffffc0200d4a:	b7a50513          	addi	a0,a0,-1158 # ffffffffc02048c0 <commands+0x6f8>
ffffffffc0200d4e:	b92ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
            panic("kernel store fault");
ffffffffc0200d52:	00004617          	auipc	a2,0x4
ffffffffc0200d56:	b9660613          	addi	a2,a2,-1130 # ffffffffc02048e8 <commands+0x720>
ffffffffc0200d5a:	0df00593          	li	a1,223
ffffffffc0200d5e:	00004517          	auipc	a0,0x4
ffffffffc0200d62:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02048a8 <commands+0x6e0>
ffffffffc0200d66:	c78ff0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0200d6a <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200d6a:	11853783          	ld	a5,280(a0)
ffffffffc0200d6e:	0007c363          	bltz	a5,ffffffffc0200d74 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200d72:	bdc1                	j	ffffffffc0200c42 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200d74:	b529                	j	ffffffffc0200b7e <interrupt_handler>
	...

ffffffffc0200d78 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200d78:	14011073          	csrw	sscratch,sp
ffffffffc0200d7c:	712d                	addi	sp,sp,-288
ffffffffc0200d7e:	e406                	sd	ra,8(sp)
ffffffffc0200d80:	ec0e                	sd	gp,24(sp)
ffffffffc0200d82:	f012                	sd	tp,32(sp)
ffffffffc0200d84:	f416                	sd	t0,40(sp)
ffffffffc0200d86:	f81a                	sd	t1,48(sp)
ffffffffc0200d88:	fc1e                	sd	t2,56(sp)
ffffffffc0200d8a:	e0a2                	sd	s0,64(sp)
ffffffffc0200d8c:	e4a6                	sd	s1,72(sp)
ffffffffc0200d8e:	e8aa                	sd	a0,80(sp)
ffffffffc0200d90:	ecae                	sd	a1,88(sp)
ffffffffc0200d92:	f0b2                	sd	a2,96(sp)
ffffffffc0200d94:	f4b6                	sd	a3,104(sp)
ffffffffc0200d96:	f8ba                	sd	a4,112(sp)
ffffffffc0200d98:	fcbe                	sd	a5,120(sp)
ffffffffc0200d9a:	e142                	sd	a6,128(sp)
ffffffffc0200d9c:	e546                	sd	a7,136(sp)
ffffffffc0200d9e:	e94a                	sd	s2,144(sp)
ffffffffc0200da0:	ed4e                	sd	s3,152(sp)
ffffffffc0200da2:	f152                	sd	s4,160(sp)
ffffffffc0200da4:	f556                	sd	s5,168(sp)
ffffffffc0200da6:	f95a                	sd	s6,176(sp)
ffffffffc0200da8:	fd5e                	sd	s7,184(sp)
ffffffffc0200daa:	e1e2                	sd	s8,192(sp)
ffffffffc0200dac:	e5e6                	sd	s9,200(sp)
ffffffffc0200dae:	e9ea                	sd	s10,208(sp)
ffffffffc0200db0:	edee                	sd	s11,216(sp)
ffffffffc0200db2:	f1f2                	sd	t3,224(sp)
ffffffffc0200db4:	f5f6                	sd	t4,232(sp)
ffffffffc0200db6:	f9fa                	sd	t5,240(sp)
ffffffffc0200db8:	fdfe                	sd	t6,248(sp)
ffffffffc0200dba:	14002473          	csrr	s0,sscratch
ffffffffc0200dbe:	100024f3          	csrr	s1,sstatus
ffffffffc0200dc2:	14102973          	csrr	s2,sepc
ffffffffc0200dc6:	143029f3          	csrr	s3,stval
ffffffffc0200dca:	14202a73          	csrr	s4,scause
ffffffffc0200dce:	e822                	sd	s0,16(sp)
ffffffffc0200dd0:	e226                	sd	s1,256(sp)
ffffffffc0200dd2:	e64a                	sd	s2,264(sp)
ffffffffc0200dd4:	ea4e                	sd	s3,272(sp)
ffffffffc0200dd6:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200dd8:	850a                	mv	a0,sp
    jal trap
ffffffffc0200dda:	f91ff0ef          	jal	ra,ffffffffc0200d6a <trap>

ffffffffc0200dde <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200dde:	6492                	ld	s1,256(sp)
ffffffffc0200de0:	6932                	ld	s2,264(sp)
ffffffffc0200de2:	10049073          	csrw	sstatus,s1
ffffffffc0200de6:	14191073          	csrw	sepc,s2
ffffffffc0200dea:	60a2                	ld	ra,8(sp)
ffffffffc0200dec:	61e2                	ld	gp,24(sp)
ffffffffc0200dee:	7202                	ld	tp,32(sp)
ffffffffc0200df0:	72a2                	ld	t0,40(sp)
ffffffffc0200df2:	7342                	ld	t1,48(sp)
ffffffffc0200df4:	73e2                	ld	t2,56(sp)
ffffffffc0200df6:	6406                	ld	s0,64(sp)
ffffffffc0200df8:	64a6                	ld	s1,72(sp)
ffffffffc0200dfa:	6546                	ld	a0,80(sp)
ffffffffc0200dfc:	65e6                	ld	a1,88(sp)
ffffffffc0200dfe:	7606                	ld	a2,96(sp)
ffffffffc0200e00:	76a6                	ld	a3,104(sp)
ffffffffc0200e02:	7746                	ld	a4,112(sp)
ffffffffc0200e04:	77e6                	ld	a5,120(sp)
ffffffffc0200e06:	680a                	ld	a6,128(sp)
ffffffffc0200e08:	68aa                	ld	a7,136(sp)
ffffffffc0200e0a:	694a                	ld	s2,144(sp)
ffffffffc0200e0c:	69ea                	ld	s3,152(sp)
ffffffffc0200e0e:	7a0a                	ld	s4,160(sp)
ffffffffc0200e10:	7aaa                	ld	s5,168(sp)
ffffffffc0200e12:	7b4a                	ld	s6,176(sp)
ffffffffc0200e14:	7bea                	ld	s7,184(sp)
ffffffffc0200e16:	6c0e                	ld	s8,192(sp)
ffffffffc0200e18:	6cae                	ld	s9,200(sp)
ffffffffc0200e1a:	6d4e                	ld	s10,208(sp)
ffffffffc0200e1c:	6dee                	ld	s11,216(sp)
ffffffffc0200e1e:	7e0e                	ld	t3,224(sp)
ffffffffc0200e20:	7eae                	ld	t4,232(sp)
ffffffffc0200e22:	7f4e                	ld	t5,240(sp)
ffffffffc0200e24:	7fee                	ld	t6,248(sp)
ffffffffc0200e26:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200e28:	10200073          	sret

ffffffffc0200e2c <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200e2c:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200e2e:	bf45                	j	ffffffffc0200dde <__trapret>
	...

ffffffffc0200e32 <pa2page.part.0>:
{
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa)
ffffffffc0200e32:	1141                	addi	sp,sp,-16
{
    if (PPN(pa) >= npage)
    {
        panic("pa2page called with invalid pa");
ffffffffc0200e34:	00004617          	auipc	a2,0x4
ffffffffc0200e38:	afc60613          	addi	a2,a2,-1284 # ffffffffc0204930 <commands+0x768>
ffffffffc0200e3c:	06900593          	li	a1,105
ffffffffc0200e40:	00004517          	auipc	a0,0x4
ffffffffc0200e44:	b1050513          	addi	a0,a0,-1264 # ffffffffc0204950 <commands+0x788>
pa2page(uintptr_t pa)
ffffffffc0200e48:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e4a:	b94ff0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0200e4e <pte2page.part.0>:
{
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte)
ffffffffc0200e4e:	1141                	addi	sp,sp,-16
{
    if (!(pte & PTE_V))
    {
        panic("pte2page called with invalid pte");
ffffffffc0200e50:	00004617          	auipc	a2,0x4
ffffffffc0200e54:	b1060613          	addi	a2,a2,-1264 # ffffffffc0204960 <commands+0x798>
ffffffffc0200e58:	07f00593          	li	a1,127
ffffffffc0200e5c:	00004517          	auipc	a0,0x4
ffffffffc0200e60:	af450513          	addi	a0,a0,-1292 # ffffffffc0204950 <commands+0x788>
pte2page(pte_t pte)
ffffffffc0200e64:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0200e66:	b78ff0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0200e6a <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e6a:	100027f3          	csrr	a5,sstatus
ffffffffc0200e6e:	8b89                	andi	a5,a5,2
ffffffffc0200e70:	e799                	bnez	a5,ffffffffc0200e7e <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e72:	0000c797          	auipc	a5,0xc
ffffffffc0200e76:	6467b783          	ld	a5,1606(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0200e7a:	6f9c                	ld	a5,24(a5)
ffffffffc0200e7c:	8782                	jr	a5
{
ffffffffc0200e7e:	1141                	addi	sp,sp,-16
ffffffffc0200e80:	e406                	sd	ra,8(sp)
ffffffffc0200e82:	e022                	sd	s0,0(sp)
ffffffffc0200e84:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200e86:	ab1ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e8a:	0000c797          	auipc	a5,0xc
ffffffffc0200e8e:	62e7b783          	ld	a5,1582(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0200e92:	6f9c                	ld	a5,24(a5)
ffffffffc0200e94:	8522                	mv	a0,s0
ffffffffc0200e96:	9782                	jalr	a5
ffffffffc0200e98:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200e9a:	a97ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200e9e:	60a2                	ld	ra,8(sp)
ffffffffc0200ea0:	8522                	mv	a0,s0
ffffffffc0200ea2:	6402                	ld	s0,0(sp)
ffffffffc0200ea4:	0141                	addi	sp,sp,16
ffffffffc0200ea6:	8082                	ret

ffffffffc0200ea8 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ea8:	100027f3          	csrr	a5,sstatus
ffffffffc0200eac:	8b89                	andi	a5,a5,2
ffffffffc0200eae:	e799                	bnez	a5,ffffffffc0200ebc <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200eb0:	0000c797          	auipc	a5,0xc
ffffffffc0200eb4:	6087b783          	ld	a5,1544(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0200eb8:	739c                	ld	a5,32(a5)
ffffffffc0200eba:	8782                	jr	a5
{
ffffffffc0200ebc:	1101                	addi	sp,sp,-32
ffffffffc0200ebe:	ec06                	sd	ra,24(sp)
ffffffffc0200ec0:	e822                	sd	s0,16(sp)
ffffffffc0200ec2:	e426                	sd	s1,8(sp)
ffffffffc0200ec4:	842a                	mv	s0,a0
ffffffffc0200ec6:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200ec8:	a6fff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200ecc:	0000c797          	auipc	a5,0xc
ffffffffc0200ed0:	5ec7b783          	ld	a5,1516(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0200ed4:	739c                	ld	a5,32(a5)
ffffffffc0200ed6:	85a6                	mv	a1,s1
ffffffffc0200ed8:	8522                	mv	a0,s0
ffffffffc0200eda:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200edc:	6442                	ld	s0,16(sp)
ffffffffc0200ede:	60e2                	ld	ra,24(sp)
ffffffffc0200ee0:	64a2                	ld	s1,8(sp)
ffffffffc0200ee2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200ee4:	b4b1                	j	ffffffffc0200930 <intr_enable>

ffffffffc0200ee6 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ee6:	100027f3          	csrr	a5,sstatus
ffffffffc0200eea:	8b89                	andi	a5,a5,2
ffffffffc0200eec:	e799                	bnez	a5,ffffffffc0200efa <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200eee:	0000c797          	auipc	a5,0xc
ffffffffc0200ef2:	5ca7b783          	ld	a5,1482(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0200ef6:	779c                	ld	a5,40(a5)
ffffffffc0200ef8:	8782                	jr	a5
{
ffffffffc0200efa:	1141                	addi	sp,sp,-16
ffffffffc0200efc:	e406                	sd	ra,8(sp)
ffffffffc0200efe:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f00:	a37ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f04:	0000c797          	auipc	a5,0xc
ffffffffc0200f08:	5b47b783          	ld	a5,1460(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0200f0c:	779c                	ld	a5,40(a5)
ffffffffc0200f0e:	9782                	jalr	a5
ffffffffc0200f10:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f12:	a1fff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200f16:	60a2                	ld	ra,8(sp)
ffffffffc0200f18:	8522                	mv	a0,s0
ffffffffc0200f1a:	6402                	ld	s0,0(sp)
ffffffffc0200f1c:	0141                	addi	sp,sp,16
ffffffffc0200f1e:	8082                	ret

ffffffffc0200f20 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f20:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0200f24:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0200f28:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f2a:	078e                	slli	a5,a5,0x3
{
ffffffffc0200f2c:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f2e:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0200f32:	6094                	ld	a3,0(s1)
{
ffffffffc0200f34:	f04a                	sd	s2,32(sp)
ffffffffc0200f36:	ec4e                	sd	s3,24(sp)
ffffffffc0200f38:	e852                	sd	s4,16(sp)
ffffffffc0200f3a:	fc06                	sd	ra,56(sp)
ffffffffc0200f3c:	f822                	sd	s0,48(sp)
ffffffffc0200f3e:	e456                	sd	s5,8(sp)
ffffffffc0200f40:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0200f42:	0016f793          	andi	a5,a3,1
{
ffffffffc0200f46:	892e                	mv	s2,a1
ffffffffc0200f48:	8a32                	mv	s4,a2
ffffffffc0200f4a:	0000c997          	auipc	s3,0xc
ffffffffc0200f4e:	55e98993          	addi	s3,s3,1374 # ffffffffc020d4a8 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0200f52:	efbd                	bnez	a5,ffffffffc0200fd0 <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0200f54:	14060c63          	beqz	a2,ffffffffc02010ac <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f58:	100027f3          	csrr	a5,sstatus
ffffffffc0200f5c:	8b89                	andi	a5,a5,2
ffffffffc0200f5e:	14079963          	bnez	a5,ffffffffc02010b0 <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200f62:	0000c797          	auipc	a5,0xc
ffffffffc0200f66:	5567b783          	ld	a5,1366(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0200f6a:	6f9c                	ld	a5,24(a5)
ffffffffc0200f6c:	4505                	li	a0,1
ffffffffc0200f6e:	9782                	jalr	a5
ffffffffc0200f70:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0200f72:	12040d63          	beqz	s0,ffffffffc02010ac <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0200f76:	0000cb17          	auipc	s6,0xc
ffffffffc0200f7a:	53ab0b13          	addi	s6,s6,1338 # ffffffffc020d4b0 <pages>
ffffffffc0200f7e:	000b3503          	ld	a0,0(s6)
ffffffffc0200f82:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200f86:	0000c997          	auipc	s3,0xc
ffffffffc0200f8a:	52298993          	addi	s3,s3,1314 # ffffffffc020d4a8 <npage>
ffffffffc0200f8e:	40a40533          	sub	a0,s0,a0
ffffffffc0200f92:	8519                	srai	a0,a0,0x6
ffffffffc0200f94:	9556                	add	a0,a0,s5
ffffffffc0200f96:	0009b703          	ld	a4,0(s3)
ffffffffc0200f9a:	00c51793          	slli	a5,a0,0xc
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc0200f9e:	4685                	li	a3,1
ffffffffc0200fa0:	c014                	sw	a3,0(s0)
ffffffffc0200fa2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fa4:	0532                	slli	a0,a0,0xc
ffffffffc0200fa6:	16e7f763          	bgeu	a5,a4,ffffffffc0201114 <get_pte+0x1f4>
ffffffffc0200faa:	0000c797          	auipc	a5,0xc
ffffffffc0200fae:	5167b783          	ld	a5,1302(a5) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc0200fb2:	6605                	lui	a2,0x1
ffffffffc0200fb4:	4581                	li	a1,0
ffffffffc0200fb6:	953e                	add	a0,a0,a5
ffffffffc0200fb8:	331020ef          	jal	ra,ffffffffc0203ae8 <memset>
    return page - pages + nbase;
ffffffffc0200fbc:	000b3683          	ld	a3,0(s6)
ffffffffc0200fc0:	40d406b3          	sub	a3,s0,a3
ffffffffc0200fc4:	8699                	srai	a3,a3,0x6
ffffffffc0200fc6:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200fc8:	06aa                	slli	a3,a3,0xa
ffffffffc0200fca:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200fce:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200fd0:	77fd                	lui	a5,0xfffff
ffffffffc0200fd2:	068a                	slli	a3,a3,0x2
ffffffffc0200fd4:	0009b703          	ld	a4,0(s3)
ffffffffc0200fd8:	8efd                	and	a3,a3,a5
ffffffffc0200fda:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200fde:	10e7ff63          	bgeu	a5,a4,ffffffffc02010fc <get_pte+0x1dc>
ffffffffc0200fe2:	0000ca97          	auipc	s5,0xc
ffffffffc0200fe6:	4dea8a93          	addi	s5,s5,1246 # ffffffffc020d4c0 <va_pa_offset>
ffffffffc0200fea:	000ab403          	ld	s0,0(s5)
ffffffffc0200fee:	01595793          	srli	a5,s2,0x15
ffffffffc0200ff2:	1ff7f793          	andi	a5,a5,511
ffffffffc0200ff6:	96a2                	add	a3,a3,s0
ffffffffc0200ff8:	00379413          	slli	s0,a5,0x3
ffffffffc0200ffc:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0200ffe:	6014                	ld	a3,0(s0)
ffffffffc0201000:	0016f793          	andi	a5,a3,1
ffffffffc0201004:	ebad                	bnez	a5,ffffffffc0201076 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201006:	0a0a0363          	beqz	s4,ffffffffc02010ac <get_pte+0x18c>
ffffffffc020100a:	100027f3          	csrr	a5,sstatus
ffffffffc020100e:	8b89                	andi	a5,a5,2
ffffffffc0201010:	efcd                	bnez	a5,ffffffffc02010ca <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201012:	0000c797          	auipc	a5,0xc
ffffffffc0201016:	4a67b783          	ld	a5,1190(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc020101a:	6f9c                	ld	a5,24(a5)
ffffffffc020101c:	4505                	li	a0,1
ffffffffc020101e:	9782                	jalr	a5
ffffffffc0201020:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201022:	c4c9                	beqz	s1,ffffffffc02010ac <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0201024:	0000cb17          	auipc	s6,0xc
ffffffffc0201028:	48cb0b13          	addi	s6,s6,1164 # ffffffffc020d4b0 <pages>
ffffffffc020102c:	000b3503          	ld	a0,0(s6)
ffffffffc0201030:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201034:	0009b703          	ld	a4,0(s3)
ffffffffc0201038:	40a48533          	sub	a0,s1,a0
ffffffffc020103c:	8519                	srai	a0,a0,0x6
ffffffffc020103e:	9552                	add	a0,a0,s4
ffffffffc0201040:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201044:	4685                	li	a3,1
ffffffffc0201046:	c094                	sw	a3,0(s1)
ffffffffc0201048:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020104a:	0532                	slli	a0,a0,0xc
ffffffffc020104c:	0ee7f163          	bgeu	a5,a4,ffffffffc020112e <get_pte+0x20e>
ffffffffc0201050:	000ab783          	ld	a5,0(s5)
ffffffffc0201054:	6605                	lui	a2,0x1
ffffffffc0201056:	4581                	li	a1,0
ffffffffc0201058:	953e                	add	a0,a0,a5
ffffffffc020105a:	28f020ef          	jal	ra,ffffffffc0203ae8 <memset>
    return page - pages + nbase;
ffffffffc020105e:	000b3683          	ld	a3,0(s6)
ffffffffc0201062:	40d486b3          	sub	a3,s1,a3
ffffffffc0201066:	8699                	srai	a3,a3,0x6
ffffffffc0201068:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020106a:	06aa                	slli	a3,a3,0xa
ffffffffc020106c:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201070:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201072:	0009b703          	ld	a4,0(s3)
ffffffffc0201076:	068a                	slli	a3,a3,0x2
ffffffffc0201078:	757d                	lui	a0,0xfffff
ffffffffc020107a:	8ee9                	and	a3,a3,a0
ffffffffc020107c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201080:	06e7f263          	bgeu	a5,a4,ffffffffc02010e4 <get_pte+0x1c4>
ffffffffc0201084:	000ab503          	ld	a0,0(s5)
ffffffffc0201088:	00c95913          	srli	s2,s2,0xc
ffffffffc020108c:	1ff97913          	andi	s2,s2,511
ffffffffc0201090:	96aa                	add	a3,a3,a0
ffffffffc0201092:	00391513          	slli	a0,s2,0x3
ffffffffc0201096:	9536                	add	a0,a0,a3
}
ffffffffc0201098:	70e2                	ld	ra,56(sp)
ffffffffc020109a:	7442                	ld	s0,48(sp)
ffffffffc020109c:	74a2                	ld	s1,40(sp)
ffffffffc020109e:	7902                	ld	s2,32(sp)
ffffffffc02010a0:	69e2                	ld	s3,24(sp)
ffffffffc02010a2:	6a42                	ld	s4,16(sp)
ffffffffc02010a4:	6aa2                	ld	s5,8(sp)
ffffffffc02010a6:	6b02                	ld	s6,0(sp)
ffffffffc02010a8:	6121                	addi	sp,sp,64
ffffffffc02010aa:	8082                	ret
            return NULL;
ffffffffc02010ac:	4501                	li	a0,0
ffffffffc02010ae:	b7ed                	j	ffffffffc0201098 <get_pte+0x178>
        intr_disable();
ffffffffc02010b0:	887ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02010b4:	0000c797          	auipc	a5,0xc
ffffffffc02010b8:	4047b783          	ld	a5,1028(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02010bc:	6f9c                	ld	a5,24(a5)
ffffffffc02010be:	4505                	li	a0,1
ffffffffc02010c0:	9782                	jalr	a5
ffffffffc02010c2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02010c4:	86dff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02010c8:	b56d                	j	ffffffffc0200f72 <get_pte+0x52>
        intr_disable();
ffffffffc02010ca:	86dff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc02010ce:	0000c797          	auipc	a5,0xc
ffffffffc02010d2:	3ea7b783          	ld	a5,1002(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02010d6:	6f9c                	ld	a5,24(a5)
ffffffffc02010d8:	4505                	li	a0,1
ffffffffc02010da:	9782                	jalr	a5
ffffffffc02010dc:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc02010de:	853ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02010e2:	b781                	j	ffffffffc0201022 <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010e4:	00004617          	auipc	a2,0x4
ffffffffc02010e8:	8a460613          	addi	a2,a2,-1884 # ffffffffc0204988 <commands+0x7c0>
ffffffffc02010ec:	0fc00593          	li	a1,252
ffffffffc02010f0:	00004517          	auipc	a0,0x4
ffffffffc02010f4:	8c050513          	addi	a0,a0,-1856 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc02010f8:	8e6ff0ef          	jal	ra,ffffffffc02001de <__panic>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02010fc:	00004617          	auipc	a2,0x4
ffffffffc0201100:	88c60613          	addi	a2,a2,-1908 # ffffffffc0204988 <commands+0x7c0>
ffffffffc0201104:	0ef00593          	li	a1,239
ffffffffc0201108:	00004517          	auipc	a0,0x4
ffffffffc020110c:	8a850513          	addi	a0,a0,-1880 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201110:	8ceff0ef          	jal	ra,ffffffffc02001de <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201114:	86aa                	mv	a3,a0
ffffffffc0201116:	00004617          	auipc	a2,0x4
ffffffffc020111a:	87260613          	addi	a2,a2,-1934 # ffffffffc0204988 <commands+0x7c0>
ffffffffc020111e:	0ec00593          	li	a1,236
ffffffffc0201122:	00004517          	auipc	a0,0x4
ffffffffc0201126:	88e50513          	addi	a0,a0,-1906 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc020112a:	8b4ff0ef          	jal	ra,ffffffffc02001de <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020112e:	86aa                	mv	a3,a0
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	85860613          	addi	a2,a2,-1960 # ffffffffc0204988 <commands+0x7c0>
ffffffffc0201138:	0f900593          	li	a1,249
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	87450513          	addi	a0,a0,-1932 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201144:	89aff0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201148 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0201148:	1141                	addi	sp,sp,-16
ffffffffc020114a:	e022                	sd	s0,0(sp)
ffffffffc020114c:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020114e:	4601                	li	a2,0
{
ffffffffc0201150:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201152:	dcfff0ef          	jal	ra,ffffffffc0200f20 <get_pte>
    if (ptep_store != NULL)
ffffffffc0201156:	c011                	beqz	s0,ffffffffc020115a <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0201158:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020115a:	c511                	beqz	a0,ffffffffc0201166 <get_page+0x1e>
ffffffffc020115c:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020115e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0201160:	0017f713          	andi	a4,a5,1
ffffffffc0201164:	e709                	bnez	a4,ffffffffc020116e <get_page+0x26>
}
ffffffffc0201166:	60a2                	ld	ra,8(sp)
ffffffffc0201168:	6402                	ld	s0,0(sp)
ffffffffc020116a:	0141                	addi	sp,sp,16
ffffffffc020116c:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020116e:	078a                	slli	a5,a5,0x2
ffffffffc0201170:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201172:	0000c717          	auipc	a4,0xc
ffffffffc0201176:	33673703          	ld	a4,822(a4) # ffffffffc020d4a8 <npage>
ffffffffc020117a:	00e7ff63          	bgeu	a5,a4,ffffffffc0201198 <get_page+0x50>
ffffffffc020117e:	60a2                	ld	ra,8(sp)
ffffffffc0201180:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201182:	fff80537          	lui	a0,0xfff80
ffffffffc0201186:	97aa                	add	a5,a5,a0
ffffffffc0201188:	079a                	slli	a5,a5,0x6
ffffffffc020118a:	0000c517          	auipc	a0,0xc
ffffffffc020118e:	32653503          	ld	a0,806(a0) # ffffffffc020d4b0 <pages>
ffffffffc0201192:	953e                	add	a0,a0,a5
ffffffffc0201194:	0141                	addi	sp,sp,16
ffffffffc0201196:	8082                	ret
ffffffffc0201198:	c9bff0ef          	jal	ra,ffffffffc0200e32 <pa2page.part.0>

ffffffffc020119c <page_remove>:
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la)
{
ffffffffc020119c:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020119e:	4601                	li	a2,0
{
ffffffffc02011a0:	ec26                	sd	s1,24(sp)
ffffffffc02011a2:	f406                	sd	ra,40(sp)
ffffffffc02011a4:	f022                	sd	s0,32(sp)
ffffffffc02011a6:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02011a8:	d79ff0ef          	jal	ra,ffffffffc0200f20 <get_pte>
    if (ptep != NULL)
ffffffffc02011ac:	c511                	beqz	a0,ffffffffc02011b8 <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc02011ae:	611c                	ld	a5,0(a0)
ffffffffc02011b0:	842a                	mv	s0,a0
ffffffffc02011b2:	0017f713          	andi	a4,a5,1
ffffffffc02011b6:	e711                	bnez	a4,ffffffffc02011c2 <page_remove+0x26>
    {
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc02011b8:	70a2                	ld	ra,40(sp)
ffffffffc02011ba:	7402                	ld	s0,32(sp)
ffffffffc02011bc:	64e2                	ld	s1,24(sp)
ffffffffc02011be:	6145                	addi	sp,sp,48
ffffffffc02011c0:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02011c2:	078a                	slli	a5,a5,0x2
ffffffffc02011c4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02011c6:	0000c717          	auipc	a4,0xc
ffffffffc02011ca:	2e273703          	ld	a4,738(a4) # ffffffffc020d4a8 <npage>
ffffffffc02011ce:	06e7f363          	bgeu	a5,a4,ffffffffc0201234 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02011d2:	fff80537          	lui	a0,0xfff80
ffffffffc02011d6:	97aa                	add	a5,a5,a0
ffffffffc02011d8:	079a                	slli	a5,a5,0x6
ffffffffc02011da:	0000c517          	auipc	a0,0xc
ffffffffc02011de:	2d653503          	ld	a0,726(a0) # ffffffffc020d4b0 <pages>
ffffffffc02011e2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02011e4:	411c                	lw	a5,0(a0)
ffffffffc02011e6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02011ea:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02011ec:	cb11                	beqz	a4,ffffffffc0201200 <page_remove+0x64>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc02011ee:	00043023          	sd	zero,0(s0)
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02011f2:	12048073          	sfence.vma	s1
}
ffffffffc02011f6:	70a2                	ld	ra,40(sp)
ffffffffc02011f8:	7402                	ld	s0,32(sp)
ffffffffc02011fa:	64e2                	ld	s1,24(sp)
ffffffffc02011fc:	6145                	addi	sp,sp,48
ffffffffc02011fe:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201200:	100027f3          	csrr	a5,sstatus
ffffffffc0201204:	8b89                	andi	a5,a5,2
ffffffffc0201206:	eb89                	bnez	a5,ffffffffc0201218 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0201208:	0000c797          	auipc	a5,0xc
ffffffffc020120c:	2b07b783          	ld	a5,688(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0201210:	739c                	ld	a5,32(a5)
ffffffffc0201212:	4585                	li	a1,1
ffffffffc0201214:	9782                	jalr	a5
    if (flag) {
ffffffffc0201216:	bfe1                	j	ffffffffc02011ee <page_remove+0x52>
        intr_disable();
ffffffffc0201218:	e42a                	sd	a0,8(sp)
ffffffffc020121a:	f1cff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc020121e:	0000c797          	auipc	a5,0xc
ffffffffc0201222:	29a7b783          	ld	a5,666(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0201226:	739c                	ld	a5,32(a5)
ffffffffc0201228:	6522                	ld	a0,8(sp)
ffffffffc020122a:	4585                	li	a1,1
ffffffffc020122c:	9782                	jalr	a5
        intr_enable();
ffffffffc020122e:	f02ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0201232:	bf75                	j	ffffffffc02011ee <page_remove+0x52>
ffffffffc0201234:	bffff0ef          	jal	ra,ffffffffc0200e32 <pa2page.part.0>

ffffffffc0201238 <page_insert>:
{
ffffffffc0201238:	7139                	addi	sp,sp,-64
ffffffffc020123a:	e852                	sd	s4,16(sp)
ffffffffc020123c:	8a32                	mv	s4,a2
ffffffffc020123e:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201240:	4605                	li	a2,1
{
ffffffffc0201242:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201244:	85d2                	mv	a1,s4
{
ffffffffc0201246:	f426                	sd	s1,40(sp)
ffffffffc0201248:	fc06                	sd	ra,56(sp)
ffffffffc020124a:	f04a                	sd	s2,32(sp)
ffffffffc020124c:	ec4e                	sd	s3,24(sp)
ffffffffc020124e:	e456                	sd	s5,8(sp)
ffffffffc0201250:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201252:	ccfff0ef          	jal	ra,ffffffffc0200f20 <get_pte>
    if (ptep == NULL)
ffffffffc0201256:	c961                	beqz	a0,ffffffffc0201326 <page_insert+0xee>
    page->ref += 1;
ffffffffc0201258:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc020125a:	611c                	ld	a5,0(a0)
ffffffffc020125c:	89aa                	mv	s3,a0
ffffffffc020125e:	0016871b          	addiw	a4,a3,1
ffffffffc0201262:	c018                	sw	a4,0(s0)
ffffffffc0201264:	0017f713          	andi	a4,a5,1
ffffffffc0201268:	ef05                	bnez	a4,ffffffffc02012a0 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc020126a:	0000c717          	auipc	a4,0xc
ffffffffc020126e:	24673703          	ld	a4,582(a4) # ffffffffc020d4b0 <pages>
ffffffffc0201272:	8c19                	sub	s0,s0,a4
ffffffffc0201274:	000807b7          	lui	a5,0x80
ffffffffc0201278:	8419                	srai	s0,s0,0x6
ffffffffc020127a:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020127c:	042a                	slli	s0,s0,0xa
ffffffffc020127e:	8cc1                	or	s1,s1,s0
ffffffffc0201280:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201284:	0099b023          	sd	s1,0(s3)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201288:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc020128c:	4501                	li	a0,0
}
ffffffffc020128e:	70e2                	ld	ra,56(sp)
ffffffffc0201290:	7442                	ld	s0,48(sp)
ffffffffc0201292:	74a2                	ld	s1,40(sp)
ffffffffc0201294:	7902                	ld	s2,32(sp)
ffffffffc0201296:	69e2                	ld	s3,24(sp)
ffffffffc0201298:	6a42                	ld	s4,16(sp)
ffffffffc020129a:	6aa2                	ld	s5,8(sp)
ffffffffc020129c:	6121                	addi	sp,sp,64
ffffffffc020129e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02012a0:	078a                	slli	a5,a5,0x2
ffffffffc02012a2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02012a4:	0000c717          	auipc	a4,0xc
ffffffffc02012a8:	20473703          	ld	a4,516(a4) # ffffffffc020d4a8 <npage>
ffffffffc02012ac:	06e7ff63          	bgeu	a5,a4,ffffffffc020132a <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02012b0:	0000ca97          	auipc	s5,0xc
ffffffffc02012b4:	200a8a93          	addi	s5,s5,512 # ffffffffc020d4b0 <pages>
ffffffffc02012b8:	000ab703          	ld	a4,0(s5)
ffffffffc02012bc:	fff80937          	lui	s2,0xfff80
ffffffffc02012c0:	993e                	add	s2,s2,a5
ffffffffc02012c2:	091a                	slli	s2,s2,0x6
ffffffffc02012c4:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc02012c6:	01240c63          	beq	s0,s2,ffffffffc02012de <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02012ca:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd72b14>
ffffffffc02012ce:	fff7869b          	addiw	a3,a5,-1
ffffffffc02012d2:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc02012d6:	c691                	beqz	a3,ffffffffc02012e2 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02012d8:	120a0073          	sfence.vma	s4
}
ffffffffc02012dc:	bf59                	j	ffffffffc0201272 <page_insert+0x3a>
ffffffffc02012de:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02012e0:	bf49                	j	ffffffffc0201272 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012e2:	100027f3          	csrr	a5,sstatus
ffffffffc02012e6:	8b89                	andi	a5,a5,2
ffffffffc02012e8:	ef91                	bnez	a5,ffffffffc0201304 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02012ea:	0000c797          	auipc	a5,0xc
ffffffffc02012ee:	1ce7b783          	ld	a5,462(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02012f2:	739c                	ld	a5,32(a5)
ffffffffc02012f4:	4585                	li	a1,1
ffffffffc02012f6:	854a                	mv	a0,s2
ffffffffc02012f8:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02012fa:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02012fe:	120a0073          	sfence.vma	s4
ffffffffc0201302:	bf85                	j	ffffffffc0201272 <page_insert+0x3a>
        intr_disable();
ffffffffc0201304:	e32ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201308:	0000c797          	auipc	a5,0xc
ffffffffc020130c:	1b07b783          	ld	a5,432(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0201310:	739c                	ld	a5,32(a5)
ffffffffc0201312:	4585                	li	a1,1
ffffffffc0201314:	854a                	mv	a0,s2
ffffffffc0201316:	9782                	jalr	a5
        intr_enable();
ffffffffc0201318:	e18ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc020131c:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201320:	120a0073          	sfence.vma	s4
ffffffffc0201324:	b7b9                	j	ffffffffc0201272 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201326:	5571                	li	a0,-4
ffffffffc0201328:	b79d                	j	ffffffffc020128e <page_insert+0x56>
ffffffffc020132a:	b09ff0ef          	jal	ra,ffffffffc0200e32 <pa2page.part.0>

ffffffffc020132e <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020132e:	00004797          	auipc	a5,0x4
ffffffffc0201332:	2aa78793          	addi	a5,a5,682 # ffffffffc02055d8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201336:	638c                	ld	a1,0(a5)
{
ffffffffc0201338:	7159                	addi	sp,sp,-112
ffffffffc020133a:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020133c:	00003517          	auipc	a0,0x3
ffffffffc0201340:	68450513          	addi	a0,a0,1668 # ffffffffc02049c0 <commands+0x7f8>
    pmm_manager = &default_pmm_manager;
ffffffffc0201344:	0000cb17          	auipc	s6,0xc
ffffffffc0201348:	174b0b13          	addi	s6,s6,372 # ffffffffc020d4b8 <pmm_manager>
{
ffffffffc020134c:	f486                	sd	ra,104(sp)
ffffffffc020134e:	e8ca                	sd	s2,80(sp)
ffffffffc0201350:	e4ce                	sd	s3,72(sp)
ffffffffc0201352:	f0a2                	sd	s0,96(sp)
ffffffffc0201354:	eca6                	sd	s1,88(sp)
ffffffffc0201356:	e0d2                	sd	s4,64(sp)
ffffffffc0201358:	fc56                	sd	s5,56(sp)
ffffffffc020135a:	f45e                	sd	s7,40(sp)
ffffffffc020135c:	f062                	sd	s8,32(sp)
ffffffffc020135e:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201360:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201364:	d7dfe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    pmm_manager->init();
ffffffffc0201368:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020136c:	0000c997          	auipc	s3,0xc
ffffffffc0201370:	15498993          	addi	s3,s3,340 # ffffffffc020d4c0 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201374:	679c                	ld	a5,8(a5)
ffffffffc0201376:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201378:	57f5                	li	a5,-3
ffffffffc020137a:	07fa                	slli	a5,a5,0x1e
ffffffffc020137c:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc0201380:	cd4ff0ef          	jal	ra,ffffffffc0200854 <get_memory_base>
ffffffffc0201384:	892a                	mv	s2,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0201386:	cd8ff0ef          	jal	ra,ffffffffc020085e <get_memory_size>
    if (mem_size == 0) {
ffffffffc020138a:	200505e3          	beqz	a0,ffffffffc0201d94 <pmm_init+0xa66>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc020138e:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc0201390:	00003517          	auipc	a0,0x3
ffffffffc0201394:	66850513          	addi	a0,a0,1640 # ffffffffc02049f8 <commands+0x830>
ffffffffc0201398:	d49fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc020139c:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02013a0:	fff40693          	addi	a3,s0,-1
ffffffffc02013a4:	864a                	mv	a2,s2
ffffffffc02013a6:	85a6                	mv	a1,s1
ffffffffc02013a8:	00003517          	auipc	a0,0x3
ffffffffc02013ac:	66850513          	addi	a0,a0,1640 # ffffffffc0204a10 <commands+0x848>
ffffffffc02013b0:	d31fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02013b4:	c8000737          	lui	a4,0xc8000
ffffffffc02013b8:	87a2                	mv	a5,s0
ffffffffc02013ba:	54876163          	bltu	a4,s0,ffffffffc02018fc <pmm_init+0x5ce>
ffffffffc02013be:	757d                	lui	a0,0xfffff
ffffffffc02013c0:	0000d617          	auipc	a2,0xd
ffffffffc02013c4:	12b60613          	addi	a2,a2,299 # ffffffffc020e4eb <end+0xfff>
ffffffffc02013c8:	8e69                	and	a2,a2,a0
ffffffffc02013ca:	0000c497          	auipc	s1,0xc
ffffffffc02013ce:	0de48493          	addi	s1,s1,222 # ffffffffc020d4a8 <npage>
ffffffffc02013d2:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013d6:	0000cb97          	auipc	s7,0xc
ffffffffc02013da:	0dab8b93          	addi	s7,s7,218 # ffffffffc020d4b0 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02013de:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013e0:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02013e4:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013e8:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02013ea:	02f50863          	beq	a0,a5,ffffffffc020141a <pmm_init+0xec>
ffffffffc02013ee:	4781                	li	a5,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02013f0:	4585                	li	a1,1
ffffffffc02013f2:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc02013f6:	00679513          	slli	a0,a5,0x6
ffffffffc02013fa:	9532                	add	a0,a0,a2
ffffffffc02013fc:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fdf1b1c>
ffffffffc0201400:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0201404:	6088                	ld	a0,0(s1)
ffffffffc0201406:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0201408:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020140c:	00d50733          	add	a4,a0,a3
ffffffffc0201410:	fee7e3e3          	bltu	a5,a4,ffffffffc02013f6 <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201414:	071a                	slli	a4,a4,0x6
ffffffffc0201416:	00e606b3          	add	a3,a2,a4
ffffffffc020141a:	c02007b7          	lui	a5,0xc0200
ffffffffc020141e:	2ef6ece3          	bltu	a3,a5,ffffffffc0201f16 <pmm_init+0xbe8>
ffffffffc0201422:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0201426:	77fd                	lui	a5,0xfffff
ffffffffc0201428:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020142a:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc020142c:	5086eb63          	bltu	a3,s0,ffffffffc0201942 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0201430:	00003517          	auipc	a0,0x3
ffffffffc0201434:	63050513          	addi	a0,a0,1584 # ffffffffc0204a60 <commands+0x898>
ffffffffc0201438:	ca9fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc020143c:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0201440:	0000c917          	auipc	s2,0xc
ffffffffc0201444:	06090913          	addi	s2,s2,96 # ffffffffc020d4a0 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc0201448:	7b9c                	ld	a5,48(a5)
ffffffffc020144a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020144c:	00003517          	auipc	a0,0x3
ffffffffc0201450:	62c50513          	addi	a0,a0,1580 # ffffffffc0204a78 <commands+0x8b0>
ffffffffc0201454:	c8dfe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0201458:	00007697          	auipc	a3,0x7
ffffffffc020145c:	ba868693          	addi	a3,a3,-1112 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc0201460:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0201464:	c02007b7          	lui	a5,0xc0200
ffffffffc0201468:	28f6ebe3          	bltu	a3,a5,ffffffffc0201efe <pmm_init+0xbd0>
ffffffffc020146c:	0009b783          	ld	a5,0(s3)
ffffffffc0201470:	8e9d                	sub	a3,a3,a5
ffffffffc0201472:	0000c797          	auipc	a5,0xc
ffffffffc0201476:	02d7b323          	sd	a3,38(a5) # ffffffffc020d498 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020147a:	100027f3          	csrr	a5,sstatus
ffffffffc020147e:	8b89                	andi	a5,a5,2
ffffffffc0201480:	4a079763          	bnez	a5,ffffffffc020192e <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201484:	000b3783          	ld	a5,0(s6)
ffffffffc0201488:	779c                	ld	a5,40(a5)
ffffffffc020148a:	9782                	jalr	a5
ffffffffc020148c:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020148e:	6098                	ld	a4,0(s1)
ffffffffc0201490:	c80007b7          	lui	a5,0xc8000
ffffffffc0201494:	83b1                	srli	a5,a5,0xc
ffffffffc0201496:	66e7e363          	bltu	a5,a4,ffffffffc0201afc <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020149a:	00093503          	ld	a0,0(s2)
ffffffffc020149e:	62050f63          	beqz	a0,ffffffffc0201adc <pmm_init+0x7ae>
ffffffffc02014a2:	03451793          	slli	a5,a0,0x34
ffffffffc02014a6:	62079b63          	bnez	a5,ffffffffc0201adc <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02014aa:	4601                	li	a2,0
ffffffffc02014ac:	4581                	li	a1,0
ffffffffc02014ae:	c9bff0ef          	jal	ra,ffffffffc0201148 <get_page>
ffffffffc02014b2:	60051563          	bnez	a0,ffffffffc0201abc <pmm_init+0x78e>
ffffffffc02014b6:	100027f3          	csrr	a5,sstatus
ffffffffc02014ba:	8b89                	andi	a5,a5,2
ffffffffc02014bc:	44079e63          	bnez	a5,ffffffffc0201918 <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc02014c0:	000b3783          	ld	a5,0(s6)
ffffffffc02014c4:	4505                	li	a0,1
ffffffffc02014c6:	6f9c                	ld	a5,24(a5)
ffffffffc02014c8:	9782                	jalr	a5
ffffffffc02014ca:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02014cc:	00093503          	ld	a0,0(s2)
ffffffffc02014d0:	4681                	li	a3,0
ffffffffc02014d2:	4601                	li	a2,0
ffffffffc02014d4:	85d2                	mv	a1,s4
ffffffffc02014d6:	d63ff0ef          	jal	ra,ffffffffc0201238 <page_insert>
ffffffffc02014da:	26051ae3          	bnez	a0,ffffffffc0201f4e <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02014de:	00093503          	ld	a0,0(s2)
ffffffffc02014e2:	4601                	li	a2,0
ffffffffc02014e4:	4581                	li	a1,0
ffffffffc02014e6:	a3bff0ef          	jal	ra,ffffffffc0200f20 <get_pte>
ffffffffc02014ea:	240502e3          	beqz	a0,ffffffffc0201f2e <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc02014ee:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc02014f0:	0017f713          	andi	a4,a5,1
ffffffffc02014f4:	5a070263          	beqz	a4,ffffffffc0201a98 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc02014f8:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02014fa:	078a                	slli	a5,a5,0x2
ffffffffc02014fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02014fe:	58e7fb63          	bgeu	a5,a4,ffffffffc0201a94 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201502:	000bb683          	ld	a3,0(s7)
ffffffffc0201506:	fff80637          	lui	a2,0xfff80
ffffffffc020150a:	97b2                	add	a5,a5,a2
ffffffffc020150c:	079a                	slli	a5,a5,0x6
ffffffffc020150e:	97b6                	add	a5,a5,a3
ffffffffc0201510:	14fa17e3          	bne	s4,a5,ffffffffc0201e5e <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0201514:	000a2683          	lw	a3,0(s4) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0201518:	4785                	li	a5,1
ffffffffc020151a:	12f692e3          	bne	a3,a5,ffffffffc0201e3e <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020151e:	00093503          	ld	a0,0(s2)
ffffffffc0201522:	77fd                	lui	a5,0xfffff
ffffffffc0201524:	6114                	ld	a3,0(a0)
ffffffffc0201526:	068a                	slli	a3,a3,0x2
ffffffffc0201528:	8efd                	and	a3,a3,a5
ffffffffc020152a:	00c6d613          	srli	a2,a3,0xc
ffffffffc020152e:	0ee67ce3          	bgeu	a2,a4,ffffffffc0201e26 <pmm_init+0xaf8>
ffffffffc0201532:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201536:	96e2                	add	a3,a3,s8
ffffffffc0201538:	0006ba83          	ld	s5,0(a3)
ffffffffc020153c:	0a8a                	slli	s5,s5,0x2
ffffffffc020153e:	00fafab3          	and	s5,s5,a5
ffffffffc0201542:	00cad793          	srli	a5,s5,0xc
ffffffffc0201546:	0ce7f3e3          	bgeu	a5,a4,ffffffffc0201e0c <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020154a:	4601                	li	a2,0
ffffffffc020154c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020154e:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0201550:	9d1ff0ef          	jal	ra,ffffffffc0200f20 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201554:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0201556:	55551363          	bne	a0,s5,ffffffffc0201a9c <pmm_init+0x76e>
ffffffffc020155a:	100027f3          	csrr	a5,sstatus
ffffffffc020155e:	8b89                	andi	a5,a5,2
ffffffffc0201560:	3a079163          	bnez	a5,ffffffffc0201902 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201564:	000b3783          	ld	a5,0(s6)
ffffffffc0201568:	4505                	li	a0,1
ffffffffc020156a:	6f9c                	ld	a5,24(a5)
ffffffffc020156c:	9782                	jalr	a5
ffffffffc020156e:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201570:	00093503          	ld	a0,0(s2)
ffffffffc0201574:	46d1                	li	a3,20
ffffffffc0201576:	6605                	lui	a2,0x1
ffffffffc0201578:	85e2                	mv	a1,s8
ffffffffc020157a:	cbfff0ef          	jal	ra,ffffffffc0201238 <page_insert>
ffffffffc020157e:	060517e3          	bnez	a0,ffffffffc0201dec <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0201582:	00093503          	ld	a0,0(s2)
ffffffffc0201586:	4601                	li	a2,0
ffffffffc0201588:	6585                	lui	a1,0x1
ffffffffc020158a:	997ff0ef          	jal	ra,ffffffffc0200f20 <get_pte>
ffffffffc020158e:	02050fe3          	beqz	a0,ffffffffc0201dcc <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc0201592:	611c                	ld	a5,0(a0)
ffffffffc0201594:	0107f713          	andi	a4,a5,16
ffffffffc0201598:	7c070e63          	beqz	a4,ffffffffc0201d74 <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc020159c:	8b91                	andi	a5,a5,4
ffffffffc020159e:	7a078b63          	beqz	a5,ffffffffc0201d54 <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02015a2:	00093503          	ld	a0,0(s2)
ffffffffc02015a6:	611c                	ld	a5,0(a0)
ffffffffc02015a8:	8bc1                	andi	a5,a5,16
ffffffffc02015aa:	78078563          	beqz	a5,ffffffffc0201d34 <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc02015ae:	000c2703          	lw	a4,0(s8) # ff0000 <kern_entry-0xffffffffbf210000>
ffffffffc02015b2:	4785                	li	a5,1
ffffffffc02015b4:	76f71063          	bne	a4,a5,ffffffffc0201d14 <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02015b8:	4681                	li	a3,0
ffffffffc02015ba:	6605                	lui	a2,0x1
ffffffffc02015bc:	85d2                	mv	a1,s4
ffffffffc02015be:	c7bff0ef          	jal	ra,ffffffffc0201238 <page_insert>
ffffffffc02015c2:	72051963          	bnez	a0,ffffffffc0201cf4 <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc02015c6:	000a2703          	lw	a4,0(s4)
ffffffffc02015ca:	4789                	li	a5,2
ffffffffc02015cc:	70f71463          	bne	a4,a5,ffffffffc0201cd4 <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc02015d0:	000c2783          	lw	a5,0(s8)
ffffffffc02015d4:	6e079063          	bnez	a5,ffffffffc0201cb4 <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02015d8:	00093503          	ld	a0,0(s2)
ffffffffc02015dc:	4601                	li	a2,0
ffffffffc02015de:	6585                	lui	a1,0x1
ffffffffc02015e0:	941ff0ef          	jal	ra,ffffffffc0200f20 <get_pte>
ffffffffc02015e4:	6a050863          	beqz	a0,ffffffffc0201c94 <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc02015e8:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc02015ea:	00177793          	andi	a5,a4,1
ffffffffc02015ee:	4a078563          	beqz	a5,ffffffffc0201a98 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc02015f2:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02015f4:	00271793          	slli	a5,a4,0x2
ffffffffc02015f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02015fa:	48d7fd63          	bgeu	a5,a3,ffffffffc0201a94 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02015fe:	000bb683          	ld	a3,0(s7)
ffffffffc0201602:	fff80ab7          	lui	s5,0xfff80
ffffffffc0201606:	97d6                	add	a5,a5,s5
ffffffffc0201608:	079a                	slli	a5,a5,0x6
ffffffffc020160a:	97b6                	add	a5,a5,a3
ffffffffc020160c:	66fa1463          	bne	s4,a5,ffffffffc0201c74 <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201610:	8b41                	andi	a4,a4,16
ffffffffc0201612:	64071163          	bnez	a4,ffffffffc0201c54 <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0201616:	00093503          	ld	a0,0(s2)
ffffffffc020161a:	4581                	li	a1,0
ffffffffc020161c:	b81ff0ef          	jal	ra,ffffffffc020119c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201620:	000a2c83          	lw	s9,0(s4)
ffffffffc0201624:	4785                	li	a5,1
ffffffffc0201626:	60fc9763          	bne	s9,a5,ffffffffc0201c34 <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc020162a:	000c2783          	lw	a5,0(s8)
ffffffffc020162e:	5e079363          	bnez	a5,ffffffffc0201c14 <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0201632:	00093503          	ld	a0,0(s2)
ffffffffc0201636:	6585                	lui	a1,0x1
ffffffffc0201638:	b65ff0ef          	jal	ra,ffffffffc020119c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020163c:	000a2783          	lw	a5,0(s4)
ffffffffc0201640:	52079a63          	bnez	a5,ffffffffc0201b74 <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0201644:	000c2783          	lw	a5,0(s8)
ffffffffc0201648:	50079663          	bnez	a5,ffffffffc0201b54 <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc020164c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0201650:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201652:	000a3683          	ld	a3,0(s4)
ffffffffc0201656:	068a                	slli	a3,a3,0x2
ffffffffc0201658:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc020165a:	42b6fd63          	bgeu	a3,a1,ffffffffc0201a94 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc020165e:	000bb503          	ld	a0,0(s7)
ffffffffc0201662:	96d6                	add	a3,a3,s5
ffffffffc0201664:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0201666:	00d507b3          	add	a5,a0,a3
ffffffffc020166a:	439c                	lw	a5,0(a5)
ffffffffc020166c:	4d979463          	bne	a5,s9,ffffffffc0201b34 <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc0201670:	8699                	srai	a3,a3,0x6
ffffffffc0201672:	00080637          	lui	a2,0x80
ffffffffc0201676:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0201678:	00c69713          	slli	a4,a3,0xc
ffffffffc020167c:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020167e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201680:	48b77e63          	bgeu	a4,a1,ffffffffc0201b1c <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201684:	0009b703          	ld	a4,0(s3)
ffffffffc0201688:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc020168a:	629c                	ld	a5,0(a3)
ffffffffc020168c:	078a                	slli	a5,a5,0x2
ffffffffc020168e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201690:	40b7f263          	bgeu	a5,a1,ffffffffc0201a94 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0201694:	8f91                	sub	a5,a5,a2
ffffffffc0201696:	079a                	slli	a5,a5,0x6
ffffffffc0201698:	953e                	add	a0,a0,a5
ffffffffc020169a:	100027f3          	csrr	a5,sstatus
ffffffffc020169e:	8b89                	andi	a5,a5,2
ffffffffc02016a0:	30079963          	bnez	a5,ffffffffc02019b2 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc02016a4:	000b3783          	ld	a5,0(s6)
ffffffffc02016a8:	4585                	li	a1,1
ffffffffc02016aa:	739c                	ld	a5,32(a5)
ffffffffc02016ac:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02016ae:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc02016b2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02016b4:	078a                	slli	a5,a5,0x2
ffffffffc02016b6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02016b8:	3ce7fe63          	bgeu	a5,a4,ffffffffc0201a94 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02016bc:	000bb503          	ld	a0,0(s7)
ffffffffc02016c0:	fff80737          	lui	a4,0xfff80
ffffffffc02016c4:	97ba                	add	a5,a5,a4
ffffffffc02016c6:	079a                	slli	a5,a5,0x6
ffffffffc02016c8:	953e                	add	a0,a0,a5
ffffffffc02016ca:	100027f3          	csrr	a5,sstatus
ffffffffc02016ce:	8b89                	andi	a5,a5,2
ffffffffc02016d0:	2c079563          	bnez	a5,ffffffffc020199a <pmm_init+0x66c>
ffffffffc02016d4:	000b3783          	ld	a5,0(s6)
ffffffffc02016d8:	4585                	li	a1,1
ffffffffc02016da:	739c                	ld	a5,32(a5)
ffffffffc02016dc:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc02016de:	00093783          	ld	a5,0(s2)
ffffffffc02016e2:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdf1b14>
    asm volatile("sfence.vma");
ffffffffc02016e6:	12000073          	sfence.vma
ffffffffc02016ea:	100027f3          	csrr	a5,sstatus
ffffffffc02016ee:	8b89                	andi	a5,a5,2
ffffffffc02016f0:	28079b63          	bnez	a5,ffffffffc0201986 <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc02016f4:	000b3783          	ld	a5,0(s6)
ffffffffc02016f8:	779c                	ld	a5,40(a5)
ffffffffc02016fa:	9782                	jalr	a5
ffffffffc02016fc:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc02016fe:	4b441b63          	bne	s0,s4,ffffffffc0201bb4 <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201702:	00003517          	auipc	a0,0x3
ffffffffc0201706:	6b650513          	addi	a0,a0,1718 # ffffffffc0204db8 <commands+0xbf0>
ffffffffc020170a:	9d7fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc020170e:	100027f3          	csrr	a5,sstatus
ffffffffc0201712:	8b89                	andi	a5,a5,2
ffffffffc0201714:	24079f63          	bnez	a5,ffffffffc0201972 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201718:	000b3783          	ld	a5,0(s6)
ffffffffc020171c:	779c                	ld	a5,40(a5)
ffffffffc020171e:	9782                	jalr	a5
ffffffffc0201720:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0201722:	6098                	ld	a4,0(s1)
ffffffffc0201724:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201728:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc020172a:	00c71793          	slli	a5,a4,0xc
ffffffffc020172e:	6a05                	lui	s4,0x1
ffffffffc0201730:	02f47c63          	bgeu	s0,a5,ffffffffc0201768 <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201734:	00c45793          	srli	a5,s0,0xc
ffffffffc0201738:	00093503          	ld	a0,0(s2)
ffffffffc020173c:	2ee7ff63          	bgeu	a5,a4,ffffffffc0201a3a <pmm_init+0x70c>
ffffffffc0201740:	0009b583          	ld	a1,0(s3)
ffffffffc0201744:	4601                	li	a2,0
ffffffffc0201746:	95a2                	add	a1,a1,s0
ffffffffc0201748:	fd8ff0ef          	jal	ra,ffffffffc0200f20 <get_pte>
ffffffffc020174c:	32050463          	beqz	a0,ffffffffc0201a74 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201750:	611c                	ld	a5,0(a0)
ffffffffc0201752:	078a                	slli	a5,a5,0x2
ffffffffc0201754:	0157f7b3          	and	a5,a5,s5
ffffffffc0201758:	2e879e63          	bne	a5,s0,ffffffffc0201a54 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc020175c:	6098                	ld	a4,0(s1)
ffffffffc020175e:	9452                	add	s0,s0,s4
ffffffffc0201760:	00c71793          	slli	a5,a4,0xc
ffffffffc0201764:	fcf468e3          	bltu	s0,a5,ffffffffc0201734 <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0201768:	00093783          	ld	a5,0(s2)
ffffffffc020176c:	639c                	ld	a5,0(a5)
ffffffffc020176e:	42079363          	bnez	a5,ffffffffc0201b94 <pmm_init+0x866>
ffffffffc0201772:	100027f3          	csrr	a5,sstatus
ffffffffc0201776:	8b89                	andi	a5,a5,2
ffffffffc0201778:	24079963          	bnez	a5,ffffffffc02019ca <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc020177c:	000b3783          	ld	a5,0(s6)
ffffffffc0201780:	4505                	li	a0,1
ffffffffc0201782:	6f9c                	ld	a5,24(a5)
ffffffffc0201784:	9782                	jalr	a5
ffffffffc0201786:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201788:	00093503          	ld	a0,0(s2)
ffffffffc020178c:	4699                	li	a3,6
ffffffffc020178e:	10000613          	li	a2,256
ffffffffc0201792:	85d2                	mv	a1,s4
ffffffffc0201794:	aa5ff0ef          	jal	ra,ffffffffc0201238 <page_insert>
ffffffffc0201798:	44051e63          	bnez	a0,ffffffffc0201bf4 <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc020179c:	000a2703          	lw	a4,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02017a0:	4785                	li	a5,1
ffffffffc02017a2:	42f71963          	bne	a4,a5,ffffffffc0201bd4 <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02017a6:	00093503          	ld	a0,0(s2)
ffffffffc02017aa:	6405                	lui	s0,0x1
ffffffffc02017ac:	4699                	li	a3,6
ffffffffc02017ae:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02017b2:	85d2                	mv	a1,s4
ffffffffc02017b4:	a85ff0ef          	jal	ra,ffffffffc0201238 <page_insert>
ffffffffc02017b8:	72051363          	bnez	a0,ffffffffc0201ede <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc02017bc:	000a2703          	lw	a4,0(s4)
ffffffffc02017c0:	4789                	li	a5,2
ffffffffc02017c2:	6ef71e63          	bne	a4,a5,ffffffffc0201ebe <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02017c6:	00003597          	auipc	a1,0x3
ffffffffc02017ca:	73a58593          	addi	a1,a1,1850 # ffffffffc0204f00 <commands+0xd38>
ffffffffc02017ce:	10000513          	li	a0,256
ffffffffc02017d2:	2aa020ef          	jal	ra,ffffffffc0203a7c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02017d6:	10040593          	addi	a1,s0,256
ffffffffc02017da:	10000513          	li	a0,256
ffffffffc02017de:	2b0020ef          	jal	ra,ffffffffc0203a8e <strcmp>
ffffffffc02017e2:	6a051e63          	bnez	a0,ffffffffc0201e9e <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc02017e6:	000bb683          	ld	a3,0(s7)
ffffffffc02017ea:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02017ee:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02017f0:	40da06b3          	sub	a3,s4,a3
ffffffffc02017f4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02017f6:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02017f8:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02017fa:	8031                	srli	s0,s0,0xc
ffffffffc02017fc:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201800:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201802:	30f77d63          	bgeu	a4,a5,ffffffffc0201b1c <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201806:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020180a:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020180e:	96be                	add	a3,a3,a5
ffffffffc0201810:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201814:	232020ef          	jal	ra,ffffffffc0203a46 <strlen>
ffffffffc0201818:	66051363          	bnez	a0,ffffffffc0201e7e <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc020181c:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0201820:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201822:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fdf1b14>
ffffffffc0201826:	068a                	slli	a3,a3,0x2
ffffffffc0201828:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc020182a:	26f6f563          	bgeu	a3,a5,ffffffffc0201a94 <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc020182e:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201830:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201832:	2ef47563          	bgeu	s0,a5,ffffffffc0201b1c <pmm_init+0x7ee>
ffffffffc0201836:	0009b403          	ld	s0,0(s3)
ffffffffc020183a:	9436                	add	s0,s0,a3
ffffffffc020183c:	100027f3          	csrr	a5,sstatus
ffffffffc0201840:	8b89                	andi	a5,a5,2
ffffffffc0201842:	1e079163          	bnez	a5,ffffffffc0201a24 <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0201846:	000b3783          	ld	a5,0(s6)
ffffffffc020184a:	4585                	li	a1,1
ffffffffc020184c:	8552                	mv	a0,s4
ffffffffc020184e:	739c                	ld	a5,32(a5)
ffffffffc0201850:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201852:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0201854:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201856:	078a                	slli	a5,a5,0x2
ffffffffc0201858:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020185a:	22e7fd63          	bgeu	a5,a4,ffffffffc0201a94 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc020185e:	000bb503          	ld	a0,0(s7)
ffffffffc0201862:	fff80737          	lui	a4,0xfff80
ffffffffc0201866:	97ba                	add	a5,a5,a4
ffffffffc0201868:	079a                	slli	a5,a5,0x6
ffffffffc020186a:	953e                	add	a0,a0,a5
ffffffffc020186c:	100027f3          	csrr	a5,sstatus
ffffffffc0201870:	8b89                	andi	a5,a5,2
ffffffffc0201872:	18079d63          	bnez	a5,ffffffffc0201a0c <pmm_init+0x6de>
ffffffffc0201876:	000b3783          	ld	a5,0(s6)
ffffffffc020187a:	4585                	li	a1,1
ffffffffc020187c:	739c                	ld	a5,32(a5)
ffffffffc020187e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201880:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0201884:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201886:	078a                	slli	a5,a5,0x2
ffffffffc0201888:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020188a:	20e7f563          	bgeu	a5,a4,ffffffffc0201a94 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc020188e:	000bb503          	ld	a0,0(s7)
ffffffffc0201892:	fff80737          	lui	a4,0xfff80
ffffffffc0201896:	97ba                	add	a5,a5,a4
ffffffffc0201898:	079a                	slli	a5,a5,0x6
ffffffffc020189a:	953e                	add	a0,a0,a5
ffffffffc020189c:	100027f3          	csrr	a5,sstatus
ffffffffc02018a0:	8b89                	andi	a5,a5,2
ffffffffc02018a2:	14079963          	bnez	a5,ffffffffc02019f4 <pmm_init+0x6c6>
ffffffffc02018a6:	000b3783          	ld	a5,0(s6)
ffffffffc02018aa:	4585                	li	a1,1
ffffffffc02018ac:	739c                	ld	a5,32(a5)
ffffffffc02018ae:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc02018b0:	00093783          	ld	a5,0(s2)
ffffffffc02018b4:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc02018b8:	12000073          	sfence.vma
ffffffffc02018bc:	100027f3          	csrr	a5,sstatus
ffffffffc02018c0:	8b89                	andi	a5,a5,2
ffffffffc02018c2:	10079f63          	bnez	a5,ffffffffc02019e0 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc02018c6:	000b3783          	ld	a5,0(s6)
ffffffffc02018ca:	779c                	ld	a5,40(a5)
ffffffffc02018cc:	9782                	jalr	a5
ffffffffc02018ce:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc02018d0:	4c8c1e63          	bne	s8,s0,ffffffffc0201dac <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02018d4:	00003517          	auipc	a0,0x3
ffffffffc02018d8:	6a450513          	addi	a0,a0,1700 # ffffffffc0204f78 <commands+0xdb0>
ffffffffc02018dc:	805fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc02018e0:	7406                	ld	s0,96(sp)
ffffffffc02018e2:	70a6                	ld	ra,104(sp)
ffffffffc02018e4:	64e6                	ld	s1,88(sp)
ffffffffc02018e6:	6946                	ld	s2,80(sp)
ffffffffc02018e8:	69a6                	ld	s3,72(sp)
ffffffffc02018ea:	6a06                	ld	s4,64(sp)
ffffffffc02018ec:	7ae2                	ld	s5,56(sp)
ffffffffc02018ee:	7b42                	ld	s6,48(sp)
ffffffffc02018f0:	7ba2                	ld	s7,40(sp)
ffffffffc02018f2:	7c02                	ld	s8,32(sp)
ffffffffc02018f4:	6ce2                	ld	s9,24(sp)
ffffffffc02018f6:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc02018f8:	4ef0006f          	j	ffffffffc02025e6 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc02018fc:	c80007b7          	lui	a5,0xc8000
ffffffffc0201900:	bc7d                	j	ffffffffc02013be <pmm_init+0x90>
        intr_disable();
ffffffffc0201902:	834ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201906:	000b3783          	ld	a5,0(s6)
ffffffffc020190a:	4505                	li	a0,1
ffffffffc020190c:	6f9c                	ld	a5,24(a5)
ffffffffc020190e:	9782                	jalr	a5
ffffffffc0201910:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0201912:	81eff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0201916:	b9a9                	j	ffffffffc0201570 <pmm_init+0x242>
        intr_disable();
ffffffffc0201918:	81eff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc020191c:	000b3783          	ld	a5,0(s6)
ffffffffc0201920:	4505                	li	a0,1
ffffffffc0201922:	6f9c                	ld	a5,24(a5)
ffffffffc0201924:	9782                	jalr	a5
ffffffffc0201926:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0201928:	808ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc020192c:	b645                	j	ffffffffc02014cc <pmm_init+0x19e>
        intr_disable();
ffffffffc020192e:	808ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201932:	000b3783          	ld	a5,0(s6)
ffffffffc0201936:	779c                	ld	a5,40(a5)
ffffffffc0201938:	9782                	jalr	a5
ffffffffc020193a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020193c:	ff5fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0201940:	b6b9                	j	ffffffffc020148e <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201942:	6705                	lui	a4,0x1
ffffffffc0201944:	177d                	addi	a4,a4,-1
ffffffffc0201946:	96ba                	add	a3,a3,a4
ffffffffc0201948:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc020194a:	00c7d713          	srli	a4,a5,0xc
ffffffffc020194e:	14a77363          	bgeu	a4,a0,ffffffffc0201a94 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0201952:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0201956:	fff80537          	lui	a0,0xfff80
ffffffffc020195a:	972a                	add	a4,a4,a0
ffffffffc020195c:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020195e:	8c1d                	sub	s0,s0,a5
ffffffffc0201960:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0201964:	00c45593          	srli	a1,s0,0xc
ffffffffc0201968:	9532                	add	a0,a0,a2
ffffffffc020196a:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc020196c:	0009b583          	ld	a1,0(s3)
}
ffffffffc0201970:	b4c1                	j	ffffffffc0201430 <pmm_init+0x102>
        intr_disable();
ffffffffc0201972:	fc5fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201976:	000b3783          	ld	a5,0(s6)
ffffffffc020197a:	779c                	ld	a5,40(a5)
ffffffffc020197c:	9782                	jalr	a5
ffffffffc020197e:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0201980:	fb1fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0201984:	bb79                	j	ffffffffc0201722 <pmm_init+0x3f4>
        intr_disable();
ffffffffc0201986:	fb1fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc020198a:	000b3783          	ld	a5,0(s6)
ffffffffc020198e:	779c                	ld	a5,40(a5)
ffffffffc0201990:	9782                	jalr	a5
ffffffffc0201992:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0201994:	f9dfe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0201998:	b39d                	j	ffffffffc02016fe <pmm_init+0x3d0>
ffffffffc020199a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020199c:	f9bfe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02019a0:	000b3783          	ld	a5,0(s6)
ffffffffc02019a4:	6522                	ld	a0,8(sp)
ffffffffc02019a6:	4585                	li	a1,1
ffffffffc02019a8:	739c                	ld	a5,32(a5)
ffffffffc02019aa:	9782                	jalr	a5
        intr_enable();
ffffffffc02019ac:	f85fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02019b0:	b33d                	j	ffffffffc02016de <pmm_init+0x3b0>
ffffffffc02019b2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02019b4:	f83fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc02019b8:	000b3783          	ld	a5,0(s6)
ffffffffc02019bc:	6522                	ld	a0,8(sp)
ffffffffc02019be:	4585                	li	a1,1
ffffffffc02019c0:	739c                	ld	a5,32(a5)
ffffffffc02019c2:	9782                	jalr	a5
        intr_enable();
ffffffffc02019c4:	f6dfe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02019c8:	b1dd                	j	ffffffffc02016ae <pmm_init+0x380>
        intr_disable();
ffffffffc02019ca:	f6dfe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02019ce:	000b3783          	ld	a5,0(s6)
ffffffffc02019d2:	4505                	li	a0,1
ffffffffc02019d4:	6f9c                	ld	a5,24(a5)
ffffffffc02019d6:	9782                	jalr	a5
ffffffffc02019d8:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02019da:	f57fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02019de:	b36d                	j	ffffffffc0201788 <pmm_init+0x45a>
        intr_disable();
ffffffffc02019e0:	f57fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02019e4:	000b3783          	ld	a5,0(s6)
ffffffffc02019e8:	779c                	ld	a5,40(a5)
ffffffffc02019ea:	9782                	jalr	a5
ffffffffc02019ec:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02019ee:	f43fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02019f2:	bdf9                	j	ffffffffc02018d0 <pmm_init+0x5a2>
ffffffffc02019f4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02019f6:	f41fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02019fa:	000b3783          	ld	a5,0(s6)
ffffffffc02019fe:	6522                	ld	a0,8(sp)
ffffffffc0201a00:	4585                	li	a1,1
ffffffffc0201a02:	739c                	ld	a5,32(a5)
ffffffffc0201a04:	9782                	jalr	a5
        intr_enable();
ffffffffc0201a06:	f2bfe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0201a0a:	b55d                	j	ffffffffc02018b0 <pmm_init+0x582>
ffffffffc0201a0c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201a0e:	f29fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0201a12:	000b3783          	ld	a5,0(s6)
ffffffffc0201a16:	6522                	ld	a0,8(sp)
ffffffffc0201a18:	4585                	li	a1,1
ffffffffc0201a1a:	739c                	ld	a5,32(a5)
ffffffffc0201a1c:	9782                	jalr	a5
        intr_enable();
ffffffffc0201a1e:	f13fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0201a22:	bdb9                	j	ffffffffc0201880 <pmm_init+0x552>
        intr_disable();
ffffffffc0201a24:	f13fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0201a28:	000b3783          	ld	a5,0(s6)
ffffffffc0201a2c:	4585                	li	a1,1
ffffffffc0201a2e:	8552                	mv	a0,s4
ffffffffc0201a30:	739c                	ld	a5,32(a5)
ffffffffc0201a32:	9782                	jalr	a5
        intr_enable();
ffffffffc0201a34:	efdfe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0201a38:	bd29                	j	ffffffffc0201852 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201a3a:	86a2                	mv	a3,s0
ffffffffc0201a3c:	00003617          	auipc	a2,0x3
ffffffffc0201a40:	f4c60613          	addi	a2,a2,-180 # ffffffffc0204988 <commands+0x7c0>
ffffffffc0201a44:	1a500593          	li	a1,421
ffffffffc0201a48:	00003517          	auipc	a0,0x3
ffffffffc0201a4c:	f6850513          	addi	a0,a0,-152 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201a50:	f8efe0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201a54:	00003697          	auipc	a3,0x3
ffffffffc0201a58:	3c468693          	addi	a3,a3,964 # ffffffffc0204e18 <commands+0xc50>
ffffffffc0201a5c:	00003617          	auipc	a2,0x3
ffffffffc0201a60:	05c60613          	addi	a2,a2,92 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201a64:	1a600593          	li	a1,422
ffffffffc0201a68:	00003517          	auipc	a0,0x3
ffffffffc0201a6c:	f4850513          	addi	a0,a0,-184 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201a70:	f6efe0ef          	jal	ra,ffffffffc02001de <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201a74:	00003697          	auipc	a3,0x3
ffffffffc0201a78:	36468693          	addi	a3,a3,868 # ffffffffc0204dd8 <commands+0xc10>
ffffffffc0201a7c:	00003617          	auipc	a2,0x3
ffffffffc0201a80:	03c60613          	addi	a2,a2,60 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201a84:	1a500593          	li	a1,421
ffffffffc0201a88:	00003517          	auipc	a0,0x3
ffffffffc0201a8c:	f2850513          	addi	a0,a0,-216 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201a90:	f4efe0ef          	jal	ra,ffffffffc02001de <__panic>
ffffffffc0201a94:	b9eff0ef          	jal	ra,ffffffffc0200e32 <pa2page.part.0>
ffffffffc0201a98:	bb6ff0ef          	jal	ra,ffffffffc0200e4e <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0201a9c:	00003697          	auipc	a3,0x3
ffffffffc0201aa0:	13468693          	addi	a3,a3,308 # ffffffffc0204bd0 <commands+0xa08>
ffffffffc0201aa4:	00003617          	auipc	a2,0x3
ffffffffc0201aa8:	01460613          	addi	a2,a2,20 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201aac:	17500593          	li	a1,373
ffffffffc0201ab0:	00003517          	auipc	a0,0x3
ffffffffc0201ab4:	f0050513          	addi	a0,a0,-256 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201ab8:	f26fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0201abc:	00003697          	auipc	a3,0x3
ffffffffc0201ac0:	05468693          	addi	a3,a3,84 # ffffffffc0204b10 <commands+0x948>
ffffffffc0201ac4:	00003617          	auipc	a2,0x3
ffffffffc0201ac8:	ff460613          	addi	a2,a2,-12 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201acc:	16800593          	li	a1,360
ffffffffc0201ad0:	00003517          	auipc	a0,0x3
ffffffffc0201ad4:	ee050513          	addi	a0,a0,-288 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201ad8:	f06fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0201adc:	00003697          	auipc	a3,0x3
ffffffffc0201ae0:	ff468693          	addi	a3,a3,-12 # ffffffffc0204ad0 <commands+0x908>
ffffffffc0201ae4:	00003617          	auipc	a2,0x3
ffffffffc0201ae8:	fd460613          	addi	a2,a2,-44 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201aec:	16700593          	li	a1,359
ffffffffc0201af0:	00003517          	auipc	a0,0x3
ffffffffc0201af4:	ec050513          	addi	a0,a0,-320 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201af8:	ee6fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201afc:	00003697          	auipc	a3,0x3
ffffffffc0201b00:	f9c68693          	addi	a3,a3,-100 # ffffffffc0204a98 <commands+0x8d0>
ffffffffc0201b04:	00003617          	auipc	a2,0x3
ffffffffc0201b08:	fb460613          	addi	a2,a2,-76 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201b0c:	16600593          	li	a1,358
ffffffffc0201b10:	00003517          	auipc	a0,0x3
ffffffffc0201b14:	ea050513          	addi	a0,a0,-352 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201b18:	ec6fe0ef          	jal	ra,ffffffffc02001de <__panic>
    return KADDR(page2pa(page));
ffffffffc0201b1c:	00003617          	auipc	a2,0x3
ffffffffc0201b20:	e6c60613          	addi	a2,a2,-404 # ffffffffc0204988 <commands+0x7c0>
ffffffffc0201b24:	07100593          	li	a1,113
ffffffffc0201b28:	00003517          	auipc	a0,0x3
ffffffffc0201b2c:	e2850513          	addi	a0,a0,-472 # ffffffffc0204950 <commands+0x788>
ffffffffc0201b30:	eaefe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0201b34:	00003697          	auipc	a3,0x3
ffffffffc0201b38:	22c68693          	addi	a3,a3,556 # ffffffffc0204d60 <commands+0xb98>
ffffffffc0201b3c:	00003617          	auipc	a2,0x3
ffffffffc0201b40:	f7c60613          	addi	a2,a2,-132 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201b44:	18e00593          	li	a1,398
ffffffffc0201b48:	00003517          	auipc	a0,0x3
ffffffffc0201b4c:	e6850513          	addi	a0,a0,-408 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201b50:	e8efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201b54:	00003697          	auipc	a3,0x3
ffffffffc0201b58:	1c468693          	addi	a3,a3,452 # ffffffffc0204d18 <commands+0xb50>
ffffffffc0201b5c:	00003617          	auipc	a2,0x3
ffffffffc0201b60:	f5c60613          	addi	a2,a2,-164 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201b64:	18c00593          	li	a1,396
ffffffffc0201b68:	00003517          	auipc	a0,0x3
ffffffffc0201b6c:	e4850513          	addi	a0,a0,-440 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201b70:	e6efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201b74:	00003697          	auipc	a3,0x3
ffffffffc0201b78:	1d468693          	addi	a3,a3,468 # ffffffffc0204d48 <commands+0xb80>
ffffffffc0201b7c:	00003617          	auipc	a2,0x3
ffffffffc0201b80:	f3c60613          	addi	a2,a2,-196 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201b84:	18b00593          	li	a1,395
ffffffffc0201b88:	00003517          	auipc	a0,0x3
ffffffffc0201b8c:	e2850513          	addi	a0,a0,-472 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201b90:	e4efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0201b94:	00003697          	auipc	a3,0x3
ffffffffc0201b98:	29c68693          	addi	a3,a3,668 # ffffffffc0204e30 <commands+0xc68>
ffffffffc0201b9c:	00003617          	auipc	a2,0x3
ffffffffc0201ba0:	f1c60613          	addi	a2,a2,-228 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201ba4:	1a900593          	li	a1,425
ffffffffc0201ba8:	00003517          	auipc	a0,0x3
ffffffffc0201bac:	e0850513          	addi	a0,a0,-504 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201bb0:	e2efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0201bb4:	00003697          	auipc	a3,0x3
ffffffffc0201bb8:	1dc68693          	addi	a3,a3,476 # ffffffffc0204d90 <commands+0xbc8>
ffffffffc0201bbc:	00003617          	auipc	a2,0x3
ffffffffc0201bc0:	efc60613          	addi	a2,a2,-260 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201bc4:	19600593          	li	a1,406
ffffffffc0201bc8:	00003517          	auipc	a0,0x3
ffffffffc0201bcc:	de850513          	addi	a0,a0,-536 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201bd0:	e0efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201bd4:	00003697          	auipc	a3,0x3
ffffffffc0201bd8:	2b468693          	addi	a3,a3,692 # ffffffffc0204e88 <commands+0xcc0>
ffffffffc0201bdc:	00003617          	auipc	a2,0x3
ffffffffc0201be0:	edc60613          	addi	a2,a2,-292 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201be4:	1ae00593          	li	a1,430
ffffffffc0201be8:	00003517          	auipc	a0,0x3
ffffffffc0201bec:	dc850513          	addi	a0,a0,-568 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201bf0:	deefe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201bf4:	00003697          	auipc	a3,0x3
ffffffffc0201bf8:	25468693          	addi	a3,a3,596 # ffffffffc0204e48 <commands+0xc80>
ffffffffc0201bfc:	00003617          	auipc	a2,0x3
ffffffffc0201c00:	ebc60613          	addi	a2,a2,-324 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201c04:	1ad00593          	li	a1,429
ffffffffc0201c08:	00003517          	auipc	a0,0x3
ffffffffc0201c0c:	da850513          	addi	a0,a0,-600 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201c10:	dcefe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201c14:	00003697          	auipc	a3,0x3
ffffffffc0201c18:	10468693          	addi	a3,a3,260 # ffffffffc0204d18 <commands+0xb50>
ffffffffc0201c1c:	00003617          	auipc	a2,0x3
ffffffffc0201c20:	e9c60613          	addi	a2,a2,-356 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201c24:	18800593          	li	a1,392
ffffffffc0201c28:	00003517          	auipc	a0,0x3
ffffffffc0201c2c:	d8850513          	addi	a0,a0,-632 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201c30:	daefe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201c34:	00003697          	auipc	a3,0x3
ffffffffc0201c38:	f8468693          	addi	a3,a3,-124 # ffffffffc0204bb8 <commands+0x9f0>
ffffffffc0201c3c:	00003617          	auipc	a2,0x3
ffffffffc0201c40:	e7c60613          	addi	a2,a2,-388 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201c44:	18700593          	li	a1,391
ffffffffc0201c48:	00003517          	auipc	a0,0x3
ffffffffc0201c4c:	d6850513          	addi	a0,a0,-664 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201c50:	d8efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201c54:	00003697          	auipc	a3,0x3
ffffffffc0201c58:	0dc68693          	addi	a3,a3,220 # ffffffffc0204d30 <commands+0xb68>
ffffffffc0201c5c:	00003617          	auipc	a2,0x3
ffffffffc0201c60:	e5c60613          	addi	a2,a2,-420 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201c64:	18400593          	li	a1,388
ffffffffc0201c68:	00003517          	auipc	a0,0x3
ffffffffc0201c6c:	d4850513          	addi	a0,a0,-696 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201c70:	d6efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c74:	00003697          	auipc	a3,0x3
ffffffffc0201c78:	f2c68693          	addi	a3,a3,-212 # ffffffffc0204ba0 <commands+0x9d8>
ffffffffc0201c7c:	00003617          	auipc	a2,0x3
ffffffffc0201c80:	e3c60613          	addi	a2,a2,-452 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201c84:	18300593          	li	a1,387
ffffffffc0201c88:	00003517          	auipc	a0,0x3
ffffffffc0201c8c:	d2850513          	addi	a0,a0,-728 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201c90:	d4efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0201c94:	00003697          	auipc	a3,0x3
ffffffffc0201c98:	fac68693          	addi	a3,a3,-84 # ffffffffc0204c40 <commands+0xa78>
ffffffffc0201c9c:	00003617          	auipc	a2,0x3
ffffffffc0201ca0:	e1c60613          	addi	a2,a2,-484 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201ca4:	18200593          	li	a1,386
ffffffffc0201ca8:	00003517          	auipc	a0,0x3
ffffffffc0201cac:	d0850513          	addi	a0,a0,-760 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201cb0:	d2efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201cb4:	00003697          	auipc	a3,0x3
ffffffffc0201cb8:	06468693          	addi	a3,a3,100 # ffffffffc0204d18 <commands+0xb50>
ffffffffc0201cbc:	00003617          	auipc	a2,0x3
ffffffffc0201cc0:	dfc60613          	addi	a2,a2,-516 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201cc4:	18100593          	li	a1,385
ffffffffc0201cc8:	00003517          	auipc	a0,0x3
ffffffffc0201ccc:	ce850513          	addi	a0,a0,-792 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201cd0:	d0efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201cd4:	00003697          	auipc	a3,0x3
ffffffffc0201cd8:	02c68693          	addi	a3,a3,44 # ffffffffc0204d00 <commands+0xb38>
ffffffffc0201cdc:	00003617          	auipc	a2,0x3
ffffffffc0201ce0:	ddc60613          	addi	a2,a2,-548 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201ce4:	18000593          	li	a1,384
ffffffffc0201ce8:	00003517          	auipc	a0,0x3
ffffffffc0201cec:	cc850513          	addi	a0,a0,-824 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201cf0:	ceefe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0201cf4:	00003697          	auipc	a3,0x3
ffffffffc0201cf8:	fdc68693          	addi	a3,a3,-36 # ffffffffc0204cd0 <commands+0xb08>
ffffffffc0201cfc:	00003617          	auipc	a2,0x3
ffffffffc0201d00:	dbc60613          	addi	a2,a2,-580 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201d04:	17f00593          	li	a1,383
ffffffffc0201d08:	00003517          	auipc	a0,0x3
ffffffffc0201d0c:	ca850513          	addi	a0,a0,-856 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201d10:	ccefe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201d14:	00003697          	auipc	a3,0x3
ffffffffc0201d18:	fa468693          	addi	a3,a3,-92 # ffffffffc0204cb8 <commands+0xaf0>
ffffffffc0201d1c:	00003617          	auipc	a2,0x3
ffffffffc0201d20:	d9c60613          	addi	a2,a2,-612 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201d24:	17d00593          	li	a1,381
ffffffffc0201d28:	00003517          	auipc	a0,0x3
ffffffffc0201d2c:	c8850513          	addi	a0,a0,-888 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201d30:	caefe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0201d34:	00003697          	auipc	a3,0x3
ffffffffc0201d38:	f6468693          	addi	a3,a3,-156 # ffffffffc0204c98 <commands+0xad0>
ffffffffc0201d3c:	00003617          	auipc	a2,0x3
ffffffffc0201d40:	d7c60613          	addi	a2,a2,-644 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201d44:	17c00593          	li	a1,380
ffffffffc0201d48:	00003517          	auipc	a0,0x3
ffffffffc0201d4c:	c6850513          	addi	a0,a0,-920 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201d50:	c8efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201d54:	00003697          	auipc	a3,0x3
ffffffffc0201d58:	f3468693          	addi	a3,a3,-204 # ffffffffc0204c88 <commands+0xac0>
ffffffffc0201d5c:	00003617          	auipc	a2,0x3
ffffffffc0201d60:	d5c60613          	addi	a2,a2,-676 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201d64:	17b00593          	li	a1,379
ffffffffc0201d68:	00003517          	auipc	a0,0x3
ffffffffc0201d6c:	c4850513          	addi	a0,a0,-952 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201d70:	c6efe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201d74:	00003697          	auipc	a3,0x3
ffffffffc0201d78:	f0468693          	addi	a3,a3,-252 # ffffffffc0204c78 <commands+0xab0>
ffffffffc0201d7c:	00003617          	auipc	a2,0x3
ffffffffc0201d80:	d3c60613          	addi	a2,a2,-708 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201d84:	17a00593          	li	a1,378
ffffffffc0201d88:	00003517          	auipc	a0,0x3
ffffffffc0201d8c:	c2850513          	addi	a0,a0,-984 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201d90:	c4efe0ef          	jal	ra,ffffffffc02001de <__panic>
        panic("DTB memory info not available");
ffffffffc0201d94:	00003617          	auipc	a2,0x3
ffffffffc0201d98:	c4460613          	addi	a2,a2,-956 # ffffffffc02049d8 <commands+0x810>
ffffffffc0201d9c:	06400593          	li	a1,100
ffffffffc0201da0:	00003517          	auipc	a0,0x3
ffffffffc0201da4:	c1050513          	addi	a0,a0,-1008 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201da8:	c36fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0201dac:	00003697          	auipc	a3,0x3
ffffffffc0201db0:	fe468693          	addi	a3,a3,-28 # ffffffffc0204d90 <commands+0xbc8>
ffffffffc0201db4:	00003617          	auipc	a2,0x3
ffffffffc0201db8:	d0460613          	addi	a2,a2,-764 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201dbc:	1c000593          	li	a1,448
ffffffffc0201dc0:	00003517          	auipc	a0,0x3
ffffffffc0201dc4:	bf050513          	addi	a0,a0,-1040 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201dc8:	c16fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0201dcc:	00003697          	auipc	a3,0x3
ffffffffc0201dd0:	e7468693          	addi	a3,a3,-396 # ffffffffc0204c40 <commands+0xa78>
ffffffffc0201dd4:	00003617          	auipc	a2,0x3
ffffffffc0201dd8:	ce460613          	addi	a2,a2,-796 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201ddc:	17900593          	li	a1,377
ffffffffc0201de0:	00003517          	auipc	a0,0x3
ffffffffc0201de4:	bd050513          	addi	a0,a0,-1072 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201de8:	bf6fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201dec:	00003697          	auipc	a3,0x3
ffffffffc0201df0:	e1468693          	addi	a3,a3,-492 # ffffffffc0204c00 <commands+0xa38>
ffffffffc0201df4:	00003617          	auipc	a2,0x3
ffffffffc0201df8:	cc460613          	addi	a2,a2,-828 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201dfc:	17800593          	li	a1,376
ffffffffc0201e00:	00003517          	auipc	a0,0x3
ffffffffc0201e04:	bb050513          	addi	a0,a0,-1104 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201e08:	bd6fe0ef          	jal	ra,ffffffffc02001de <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201e0c:	86d6                	mv	a3,s5
ffffffffc0201e0e:	00003617          	auipc	a2,0x3
ffffffffc0201e12:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0204988 <commands+0x7c0>
ffffffffc0201e16:	17400593          	li	a1,372
ffffffffc0201e1a:	00003517          	auipc	a0,0x3
ffffffffc0201e1e:	b9650513          	addi	a0,a0,-1130 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201e22:	bbcfe0ef          	jal	ra,ffffffffc02001de <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0201e26:	00003617          	auipc	a2,0x3
ffffffffc0201e2a:	b6260613          	addi	a2,a2,-1182 # ffffffffc0204988 <commands+0x7c0>
ffffffffc0201e2e:	17300593          	li	a1,371
ffffffffc0201e32:	00003517          	auipc	a0,0x3
ffffffffc0201e36:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201e3a:	ba4fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201e3e:	00003697          	auipc	a3,0x3
ffffffffc0201e42:	d7a68693          	addi	a3,a3,-646 # ffffffffc0204bb8 <commands+0x9f0>
ffffffffc0201e46:	00003617          	auipc	a2,0x3
ffffffffc0201e4a:	c7260613          	addi	a2,a2,-910 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201e4e:	17100593          	li	a1,369
ffffffffc0201e52:	00003517          	auipc	a0,0x3
ffffffffc0201e56:	b5e50513          	addi	a0,a0,-1186 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201e5a:	b84fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201e5e:	00003697          	auipc	a3,0x3
ffffffffc0201e62:	d4268693          	addi	a3,a3,-702 # ffffffffc0204ba0 <commands+0x9d8>
ffffffffc0201e66:	00003617          	auipc	a2,0x3
ffffffffc0201e6a:	c5260613          	addi	a2,a2,-942 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201e6e:	17000593          	li	a1,368
ffffffffc0201e72:	00003517          	auipc	a0,0x3
ffffffffc0201e76:	b3e50513          	addi	a0,a0,-1218 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201e7a:	b64fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201e7e:	00003697          	auipc	a3,0x3
ffffffffc0201e82:	0d268693          	addi	a3,a3,210 # ffffffffc0204f50 <commands+0xd88>
ffffffffc0201e86:	00003617          	auipc	a2,0x3
ffffffffc0201e8a:	c3260613          	addi	a2,a2,-974 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201e8e:	1b700593          	li	a1,439
ffffffffc0201e92:	00003517          	auipc	a0,0x3
ffffffffc0201e96:	b1e50513          	addi	a0,a0,-1250 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201e9a:	b44fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201e9e:	00003697          	auipc	a3,0x3
ffffffffc0201ea2:	07a68693          	addi	a3,a3,122 # ffffffffc0204f18 <commands+0xd50>
ffffffffc0201ea6:	00003617          	auipc	a2,0x3
ffffffffc0201eaa:	c1260613          	addi	a2,a2,-1006 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201eae:	1b400593          	li	a1,436
ffffffffc0201eb2:	00003517          	auipc	a0,0x3
ffffffffc0201eb6:	afe50513          	addi	a0,a0,-1282 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201eba:	b24fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201ebe:	00003697          	auipc	a3,0x3
ffffffffc0201ec2:	02a68693          	addi	a3,a3,42 # ffffffffc0204ee8 <commands+0xd20>
ffffffffc0201ec6:	00003617          	auipc	a2,0x3
ffffffffc0201eca:	bf260613          	addi	a2,a2,-1038 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201ece:	1b000593          	li	a1,432
ffffffffc0201ed2:	00003517          	auipc	a0,0x3
ffffffffc0201ed6:	ade50513          	addi	a0,a0,-1314 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201eda:	b04fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201ede:	00003697          	auipc	a3,0x3
ffffffffc0201ee2:	fc268693          	addi	a3,a3,-62 # ffffffffc0204ea0 <commands+0xcd8>
ffffffffc0201ee6:	00003617          	auipc	a2,0x3
ffffffffc0201eea:	bd260613          	addi	a2,a2,-1070 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201eee:	1af00593          	li	a1,431
ffffffffc0201ef2:	00003517          	auipc	a0,0x3
ffffffffc0201ef6:	abe50513          	addi	a0,a0,-1346 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201efa:	ae4fe0ef          	jal	ra,ffffffffc02001de <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0201efe:	00003617          	auipc	a2,0x3
ffffffffc0201f02:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201f06:	0cc00593          	li	a1,204
ffffffffc0201f0a:	00003517          	auipc	a0,0x3
ffffffffc0201f0e:	aa650513          	addi	a0,a0,-1370 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201f12:	accfe0ef          	jal	ra,ffffffffc02001de <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201f16:	00003617          	auipc	a2,0x3
ffffffffc0201f1a:	b2260613          	addi	a2,a2,-1246 # ffffffffc0204a38 <commands+0x870>
ffffffffc0201f1e:	08000593          	li	a1,128
ffffffffc0201f22:	00003517          	auipc	a0,0x3
ffffffffc0201f26:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201f2a:	ab4fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0201f2e:	00003697          	auipc	a3,0x3
ffffffffc0201f32:	c4268693          	addi	a3,a3,-958 # ffffffffc0204b70 <commands+0x9a8>
ffffffffc0201f36:	00003617          	auipc	a2,0x3
ffffffffc0201f3a:	b8260613          	addi	a2,a2,-1150 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201f3e:	16f00593          	li	a1,367
ffffffffc0201f42:	00003517          	auipc	a0,0x3
ffffffffc0201f46:	a6e50513          	addi	a0,a0,-1426 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201f4a:	a94fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0201f4e:	00003697          	auipc	a3,0x3
ffffffffc0201f52:	bf268693          	addi	a3,a3,-1038 # ffffffffc0204b40 <commands+0x978>
ffffffffc0201f56:	00003617          	auipc	a2,0x3
ffffffffc0201f5a:	b6260613          	addi	a2,a2,-1182 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201f5e:	16c00593          	li	a1,364
ffffffffc0201f62:	00003517          	auipc	a0,0x3
ffffffffc0201f66:	a4e50513          	addi	a0,a0,-1458 # ffffffffc02049b0 <commands+0x7e8>
ffffffffc0201f6a:	a74fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201f6e <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0201f6e:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201f70:	00003697          	auipc	a3,0x3
ffffffffc0201f74:	02868693          	addi	a3,a3,40 # ffffffffc0204f98 <commands+0xdd0>
ffffffffc0201f78:	00003617          	auipc	a2,0x3
ffffffffc0201f7c:	b4060613          	addi	a2,a2,-1216 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0201f80:	08800593          	li	a1,136
ffffffffc0201f84:	00003517          	auipc	a0,0x3
ffffffffc0201f88:	03450513          	addi	a0,a0,52 # ffffffffc0204fb8 <commands+0xdf0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0201f8c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201f8e:	a50fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201f92 <find_vma>:
{
ffffffffc0201f92:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0201f94:	c505                	beqz	a0,ffffffffc0201fbc <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0201f96:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0201f98:	c501                	beqz	a0,ffffffffc0201fa0 <find_vma+0xe>
ffffffffc0201f9a:	651c                	ld	a5,8(a0)
ffffffffc0201f9c:	02f5f263          	bgeu	a1,a5,ffffffffc0201fc0 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201fa0:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0201fa2:	00f68d63          	beq	a3,a5,ffffffffc0201fbc <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0201fa6:	fe87b703          	ld	a4,-24(a5) # ffffffffc7ffffe8 <end+0x7df2afc>
ffffffffc0201faa:	00e5e663          	bltu	a1,a4,ffffffffc0201fb6 <find_vma+0x24>
ffffffffc0201fae:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201fb2:	00e5ec63          	bltu	a1,a4,ffffffffc0201fca <find_vma+0x38>
ffffffffc0201fb6:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0201fb8:	fef697e3          	bne	a3,a5,ffffffffc0201fa6 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0201fbc:	4501                	li	a0,0
}
ffffffffc0201fbe:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0201fc0:	691c                	ld	a5,16(a0)
ffffffffc0201fc2:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0201fa0 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0201fc6:	ea88                	sd	a0,16(a3)
ffffffffc0201fc8:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0201fca:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0201fce:	ea88                	sd	a0,16(a3)
ffffffffc0201fd0:	8082                	ret

ffffffffc0201fd2 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201fd2:	6590                	ld	a2,8(a1)
ffffffffc0201fd4:	0105b803          	ld	a6,16(a1)
{
ffffffffc0201fd8:	1141                	addi	sp,sp,-16
ffffffffc0201fda:	e406                	sd	ra,8(sp)
ffffffffc0201fdc:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201fde:	01066763          	bltu	a2,a6,ffffffffc0201fec <insert_vma_struct+0x1a>
ffffffffc0201fe2:	a085                	j	ffffffffc0202042 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0201fe4:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201fe8:	04e66863          	bltu	a2,a4,ffffffffc0202038 <insert_vma_struct+0x66>
ffffffffc0201fec:	86be                	mv	a3,a5
ffffffffc0201fee:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0201ff0:	fef51ae3          	bne	a0,a5,ffffffffc0201fe4 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0201ff4:	02a68463          	beq	a3,a0,ffffffffc020201c <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201ff8:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201ffc:	fe86b883          	ld	a7,-24(a3)
ffffffffc0202000:	08e8f163          	bgeu	a7,a4,ffffffffc0202082 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202004:	04e66f63          	bltu	a2,a4,ffffffffc0202062 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc0202008:	00f50a63          	beq	a0,a5,ffffffffc020201c <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020200c:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202010:	05076963          	bltu	a4,a6,ffffffffc0202062 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0202014:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202018:	02c77363          	bgeu	a4,a2,ffffffffc020203e <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc020201c:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc020201e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0202020:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0202024:	e390                	sd	a2,0(a5)
ffffffffc0202026:	e690                	sd	a2,8(a3)
}
ffffffffc0202028:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020202a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020202c:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc020202e:	0017079b          	addiw	a5,a4,1
ffffffffc0202032:	d11c                	sw	a5,32(a0)
}
ffffffffc0202034:	0141                	addi	sp,sp,16
ffffffffc0202036:	8082                	ret
    if (le_prev != list)
ffffffffc0202038:	fca690e3          	bne	a3,a0,ffffffffc0201ff8 <insert_vma_struct+0x26>
ffffffffc020203c:	bfd1                	j	ffffffffc0202010 <insert_vma_struct+0x3e>
ffffffffc020203e:	f31ff0ef          	jal	ra,ffffffffc0201f6e <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202042:	00003697          	auipc	a3,0x3
ffffffffc0202046:	f8668693          	addi	a3,a3,-122 # ffffffffc0204fc8 <commands+0xe00>
ffffffffc020204a:	00003617          	auipc	a2,0x3
ffffffffc020204e:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202052:	08e00593          	li	a1,142
ffffffffc0202056:	00003517          	auipc	a0,0x3
ffffffffc020205a:	f6250513          	addi	a0,a0,-158 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc020205e:	980fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202062:	00003697          	auipc	a3,0x3
ffffffffc0202066:	fa668693          	addi	a3,a3,-90 # ffffffffc0205008 <commands+0xe40>
ffffffffc020206a:	00003617          	auipc	a2,0x3
ffffffffc020206e:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202072:	08700593          	li	a1,135
ffffffffc0202076:	00003517          	auipc	a0,0x3
ffffffffc020207a:	f4250513          	addi	a0,a0,-190 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc020207e:	960fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202082:	00003697          	auipc	a3,0x3
ffffffffc0202086:	f6668693          	addi	a3,a3,-154 # ffffffffc0204fe8 <commands+0xe20>
ffffffffc020208a:	00003617          	auipc	a2,0x3
ffffffffc020208e:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202092:	08600593          	li	a1,134
ffffffffc0202096:	00003517          	auipc	a0,0x3
ffffffffc020209a:	f2250513          	addi	a0,a0,-222 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc020209e:	940fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02020a2 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc02020a2:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02020a4:	03000513          	li	a0,48
{
ffffffffc02020a8:	fc06                	sd	ra,56(sp)
ffffffffc02020aa:	f822                	sd	s0,48(sp)
ffffffffc02020ac:	f426                	sd	s1,40(sp)
ffffffffc02020ae:	f04a                	sd	s2,32(sp)
ffffffffc02020b0:	ec4e                	sd	s3,24(sp)
ffffffffc02020b2:	e852                	sd	s4,16(sp)
ffffffffc02020b4:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02020b6:	550000ef          	jal	ra,ffffffffc0202606 <kmalloc>
    if (mm != NULL)
ffffffffc02020ba:	2e050f63          	beqz	a0,ffffffffc02023b8 <vmm_init+0x316>
ffffffffc02020be:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc02020c0:	e508                	sd	a0,8(a0)
ffffffffc02020c2:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02020c4:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02020c8:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02020cc:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc02020d0:	02053423          	sd	zero,40(a0)
ffffffffc02020d4:	03200413          	li	s0,50
ffffffffc02020d8:	a811                	j	ffffffffc02020ec <vmm_init+0x4a>
        vma->vm_start = vm_start;
ffffffffc02020da:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02020dc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02020de:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc02020e2:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02020e4:	8526                	mv	a0,s1
ffffffffc02020e6:	eedff0ef          	jal	ra,ffffffffc0201fd2 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc02020ea:	c80d                	beqz	s0,ffffffffc020211c <vmm_init+0x7a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02020ec:	03000513          	li	a0,48
ffffffffc02020f0:	516000ef          	jal	ra,ffffffffc0202606 <kmalloc>
ffffffffc02020f4:	85aa                	mv	a1,a0
ffffffffc02020f6:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc02020fa:	f165                	bnez	a0,ffffffffc02020da <vmm_init+0x38>
        assert(vma != NULL);
ffffffffc02020fc:	00003697          	auipc	a3,0x3
ffffffffc0202100:	0a468693          	addi	a3,a3,164 # ffffffffc02051a0 <commands+0xfd8>
ffffffffc0202104:	00003617          	auipc	a2,0x3
ffffffffc0202108:	9b460613          	addi	a2,a2,-1612 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc020210c:	0da00593          	li	a1,218
ffffffffc0202110:	00003517          	auipc	a0,0x3
ffffffffc0202114:	ea850513          	addi	a0,a0,-344 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc0202118:	8c6fe0ef          	jal	ra,ffffffffc02001de <__panic>
ffffffffc020211c:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202120:	1f900913          	li	s2,505
ffffffffc0202124:	a819                	j	ffffffffc020213a <vmm_init+0x98>
        vma->vm_start = vm_start;
ffffffffc0202126:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202128:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020212a:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc020212e:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202130:	8526                	mv	a0,s1
ffffffffc0202132:	ea1ff0ef          	jal	ra,ffffffffc0201fd2 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202136:	03240a63          	beq	s0,s2,ffffffffc020216a <vmm_init+0xc8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020213a:	03000513          	li	a0,48
ffffffffc020213e:	4c8000ef          	jal	ra,ffffffffc0202606 <kmalloc>
ffffffffc0202142:	85aa                	mv	a1,a0
ffffffffc0202144:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0202148:	fd79                	bnez	a0,ffffffffc0202126 <vmm_init+0x84>
        assert(vma != NULL);
ffffffffc020214a:	00003697          	auipc	a3,0x3
ffffffffc020214e:	05668693          	addi	a3,a3,86 # ffffffffc02051a0 <commands+0xfd8>
ffffffffc0202152:	00003617          	auipc	a2,0x3
ffffffffc0202156:	96660613          	addi	a2,a2,-1690 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc020215a:	0e100593          	li	a1,225
ffffffffc020215e:	00003517          	auipc	a0,0x3
ffffffffc0202162:	e5a50513          	addi	a0,a0,-422 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc0202166:	878fe0ef          	jal	ra,ffffffffc02001de <__panic>
    return listelm->next;
ffffffffc020216a:	649c                	ld	a5,8(s1)
ffffffffc020216c:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc020216e:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0202172:	18f48363          	beq	s1,a5,ffffffffc02022f8 <vmm_init+0x256>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202176:	fe87b603          	ld	a2,-24(a5)
ffffffffc020217a:	ffe70693          	addi	a3,a4,-2 # ffe <kern_entry-0xffffffffc01ff002>
ffffffffc020217e:	10d61d63          	bne	a2,a3,ffffffffc0202298 <vmm_init+0x1f6>
ffffffffc0202182:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202186:	10e69963          	bne	a3,a4,ffffffffc0202298 <vmm_init+0x1f6>
    for (i = 1; i <= step2; i++)
ffffffffc020218a:	0715                	addi	a4,a4,5
ffffffffc020218c:	679c                	ld	a5,8(a5)
ffffffffc020218e:	feb712e3          	bne	a4,a1,ffffffffc0202172 <vmm_init+0xd0>
ffffffffc0202192:	4a1d                	li	s4,7
ffffffffc0202194:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0202196:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020219a:	85a2                	mv	a1,s0
ffffffffc020219c:	8526                	mv	a0,s1
ffffffffc020219e:	df5ff0ef          	jal	ra,ffffffffc0201f92 <find_vma>
ffffffffc02021a2:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02021a4:	18050a63          	beqz	a0,ffffffffc0202338 <vmm_init+0x296>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc02021a8:	00140593          	addi	a1,s0,1
ffffffffc02021ac:	8526                	mv	a0,s1
ffffffffc02021ae:	de5ff0ef          	jal	ra,ffffffffc0201f92 <find_vma>
ffffffffc02021b2:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02021b4:	16050263          	beqz	a0,ffffffffc0202318 <vmm_init+0x276>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc02021b8:	85d2                	mv	a1,s4
ffffffffc02021ba:	8526                	mv	a0,s1
ffffffffc02021bc:	dd7ff0ef          	jal	ra,ffffffffc0201f92 <find_vma>
        assert(vma3 == NULL);
ffffffffc02021c0:	18051c63          	bnez	a0,ffffffffc0202358 <vmm_init+0x2b6>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc02021c4:	00340593          	addi	a1,s0,3
ffffffffc02021c8:	8526                	mv	a0,s1
ffffffffc02021ca:	dc9ff0ef          	jal	ra,ffffffffc0201f92 <find_vma>
        assert(vma4 == NULL);
ffffffffc02021ce:	1c051563          	bnez	a0,ffffffffc0202398 <vmm_init+0x2f6>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc02021d2:	00440593          	addi	a1,s0,4
ffffffffc02021d6:	8526                	mv	a0,s1
ffffffffc02021d8:	dbbff0ef          	jal	ra,ffffffffc0201f92 <find_vma>
        assert(vma5 == NULL);
ffffffffc02021dc:	18051e63          	bnez	a0,ffffffffc0202378 <vmm_init+0x2d6>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02021e0:	00893783          	ld	a5,8(s2)
ffffffffc02021e4:	0c879a63          	bne	a5,s0,ffffffffc02022b8 <vmm_init+0x216>
ffffffffc02021e8:	01093783          	ld	a5,16(s2)
ffffffffc02021ec:	0d479663          	bne	a5,s4,ffffffffc02022b8 <vmm_init+0x216>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02021f0:	0089b783          	ld	a5,8(s3)
ffffffffc02021f4:	0e879263          	bne	a5,s0,ffffffffc02022d8 <vmm_init+0x236>
ffffffffc02021f8:	0109b783          	ld	a5,16(s3)
ffffffffc02021fc:	0d479e63          	bne	a5,s4,ffffffffc02022d8 <vmm_init+0x236>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0202200:	0415                	addi	s0,s0,5
ffffffffc0202202:	0a15                	addi	s4,s4,5
ffffffffc0202204:	f9541be3          	bne	s0,s5,ffffffffc020219a <vmm_init+0xf8>
ffffffffc0202208:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc020220a:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc020220c:	85a2                	mv	a1,s0
ffffffffc020220e:	8526                	mv	a0,s1
ffffffffc0202210:	d83ff0ef          	jal	ra,ffffffffc0201f92 <find_vma>
ffffffffc0202214:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0202218:	c90d                	beqz	a0,ffffffffc020224a <vmm_init+0x1a8>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc020221a:	6914                	ld	a3,16(a0)
ffffffffc020221c:	6510                	ld	a2,8(a0)
ffffffffc020221e:	00003517          	auipc	a0,0x3
ffffffffc0202222:	f0a50513          	addi	a0,a0,-246 # ffffffffc0205128 <commands+0xf60>
ffffffffc0202226:	ebbfd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020222a:	00003697          	auipc	a3,0x3
ffffffffc020222e:	f2668693          	addi	a3,a3,-218 # ffffffffc0205150 <commands+0xf88>
ffffffffc0202232:	00003617          	auipc	a2,0x3
ffffffffc0202236:	88660613          	addi	a2,a2,-1914 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc020223a:	10700593          	li	a1,263
ffffffffc020223e:	00003517          	auipc	a0,0x3
ffffffffc0202242:	d7a50513          	addi	a0,a0,-646 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc0202246:	f99fd0ef          	jal	ra,ffffffffc02001de <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc020224a:	147d                	addi	s0,s0,-1
ffffffffc020224c:	fd2410e3          	bne	s0,s2,ffffffffc020220c <vmm_init+0x16a>
ffffffffc0202250:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list)
ffffffffc0202252:	00a48c63          	beq	s1,a0,ffffffffc020226a <vmm_init+0x1c8>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202256:	6118                	ld	a4,0(a0)
ffffffffc0202258:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc020225a:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020225c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020225e:	e398                	sd	a4,0(a5)
ffffffffc0202260:	456000ef          	jal	ra,ffffffffc02026b6 <kfree>
    return listelm->next;
ffffffffc0202264:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list)
ffffffffc0202266:	fea498e3          	bne	s1,a0,ffffffffc0202256 <vmm_init+0x1b4>
    kfree(mm); // kfree mm
ffffffffc020226a:	8526                	mv	a0,s1
ffffffffc020226c:	44a000ef          	jal	ra,ffffffffc02026b6 <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202270:	00003517          	auipc	a0,0x3
ffffffffc0202274:	ef850513          	addi	a0,a0,-264 # ffffffffc0205168 <commands+0xfa0>
ffffffffc0202278:	e69fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc020227c:	7442                	ld	s0,48(sp)
ffffffffc020227e:	70e2                	ld	ra,56(sp)
ffffffffc0202280:	74a2                	ld	s1,40(sp)
ffffffffc0202282:	7902                	ld	s2,32(sp)
ffffffffc0202284:	69e2                	ld	s3,24(sp)
ffffffffc0202286:	6a42                	ld	s4,16(sp)
ffffffffc0202288:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020228a:	00003517          	auipc	a0,0x3
ffffffffc020228e:	efe50513          	addi	a0,a0,-258 # ffffffffc0205188 <commands+0xfc0>
}
ffffffffc0202292:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202294:	e4dfd06f          	j	ffffffffc02000e0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202298:	00003697          	auipc	a3,0x3
ffffffffc020229c:	da868693          	addi	a3,a3,-600 # ffffffffc0205040 <commands+0xe78>
ffffffffc02022a0:	00003617          	auipc	a2,0x3
ffffffffc02022a4:	81860613          	addi	a2,a2,-2024 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc02022a8:	0eb00593          	li	a1,235
ffffffffc02022ac:	00003517          	auipc	a0,0x3
ffffffffc02022b0:	d0c50513          	addi	a0,a0,-756 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc02022b4:	f2bfd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02022b8:	00003697          	auipc	a3,0x3
ffffffffc02022bc:	e1068693          	addi	a3,a3,-496 # ffffffffc02050c8 <commands+0xf00>
ffffffffc02022c0:	00002617          	auipc	a2,0x2
ffffffffc02022c4:	7f860613          	addi	a2,a2,2040 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc02022c8:	0fc00593          	li	a1,252
ffffffffc02022cc:	00003517          	auipc	a0,0x3
ffffffffc02022d0:	cec50513          	addi	a0,a0,-788 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc02022d4:	f0bfd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02022d8:	00003697          	auipc	a3,0x3
ffffffffc02022dc:	e2068693          	addi	a3,a3,-480 # ffffffffc02050f8 <commands+0xf30>
ffffffffc02022e0:	00002617          	auipc	a2,0x2
ffffffffc02022e4:	7d860613          	addi	a2,a2,2008 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc02022e8:	0fd00593          	li	a1,253
ffffffffc02022ec:	00003517          	auipc	a0,0x3
ffffffffc02022f0:	ccc50513          	addi	a0,a0,-820 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc02022f4:	eebfd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02022f8:	00003697          	auipc	a3,0x3
ffffffffc02022fc:	d3068693          	addi	a3,a3,-720 # ffffffffc0205028 <commands+0xe60>
ffffffffc0202300:	00002617          	auipc	a2,0x2
ffffffffc0202304:	7b860613          	addi	a2,a2,1976 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202308:	0e900593          	li	a1,233
ffffffffc020230c:	00003517          	auipc	a0,0x3
ffffffffc0202310:	cac50513          	addi	a0,a0,-852 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc0202314:	ecbfd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma2 != NULL);
ffffffffc0202318:	00003697          	auipc	a3,0x3
ffffffffc020231c:	d7068693          	addi	a3,a3,-656 # ffffffffc0205088 <commands+0xec0>
ffffffffc0202320:	00002617          	auipc	a2,0x2
ffffffffc0202324:	79860613          	addi	a2,a2,1944 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202328:	0f400593          	li	a1,244
ffffffffc020232c:	00003517          	auipc	a0,0x3
ffffffffc0202330:	c8c50513          	addi	a0,a0,-884 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc0202334:	eabfd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma1 != NULL);
ffffffffc0202338:	00003697          	auipc	a3,0x3
ffffffffc020233c:	d4068693          	addi	a3,a3,-704 # ffffffffc0205078 <commands+0xeb0>
ffffffffc0202340:	00002617          	auipc	a2,0x2
ffffffffc0202344:	77860613          	addi	a2,a2,1912 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202348:	0f200593          	li	a1,242
ffffffffc020234c:	00003517          	auipc	a0,0x3
ffffffffc0202350:	c6c50513          	addi	a0,a0,-916 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc0202354:	e8bfd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma3 == NULL);
ffffffffc0202358:	00003697          	auipc	a3,0x3
ffffffffc020235c:	d4068693          	addi	a3,a3,-704 # ffffffffc0205098 <commands+0xed0>
ffffffffc0202360:	00002617          	auipc	a2,0x2
ffffffffc0202364:	75860613          	addi	a2,a2,1880 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202368:	0f600593          	li	a1,246
ffffffffc020236c:	00003517          	auipc	a0,0x3
ffffffffc0202370:	c4c50513          	addi	a0,a0,-948 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc0202374:	e6bfd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma5 == NULL);
ffffffffc0202378:	00003697          	auipc	a3,0x3
ffffffffc020237c:	d4068693          	addi	a3,a3,-704 # ffffffffc02050b8 <commands+0xef0>
ffffffffc0202380:	00002617          	auipc	a2,0x2
ffffffffc0202384:	73860613          	addi	a2,a2,1848 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202388:	0fa00593          	li	a1,250
ffffffffc020238c:	00003517          	auipc	a0,0x3
ffffffffc0202390:	c2c50513          	addi	a0,a0,-980 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc0202394:	e4bfd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma4 == NULL);
ffffffffc0202398:	00003697          	auipc	a3,0x3
ffffffffc020239c:	d1068693          	addi	a3,a3,-752 # ffffffffc02050a8 <commands+0xee0>
ffffffffc02023a0:	00002617          	auipc	a2,0x2
ffffffffc02023a4:	71860613          	addi	a2,a2,1816 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc02023a8:	0f800593          	li	a1,248
ffffffffc02023ac:	00003517          	auipc	a0,0x3
ffffffffc02023b0:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc02023b4:	e2bfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(mm != NULL);
ffffffffc02023b8:	00003697          	auipc	a3,0x3
ffffffffc02023bc:	df868693          	addi	a3,a3,-520 # ffffffffc02051b0 <commands+0xfe8>
ffffffffc02023c0:	00002617          	auipc	a2,0x2
ffffffffc02023c4:	6f860613          	addi	a2,a2,1784 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc02023c8:	0d200593          	li	a1,210
ffffffffc02023cc:	00003517          	auipc	a0,0x3
ffffffffc02023d0:	bec50513          	addi	a0,a0,-1044 # ffffffffc0204fb8 <commands+0xdf0>
ffffffffc02023d4:	e0bfd0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02023d8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02023d8:	c94d                	beqz	a0,ffffffffc020248a <slob_free+0xb2>
{
ffffffffc02023da:	1141                	addi	sp,sp,-16
ffffffffc02023dc:	e022                	sd	s0,0(sp)
ffffffffc02023de:	e406                	sd	ra,8(sp)
ffffffffc02023e0:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02023e2:	e9c1                	bnez	a1,ffffffffc0202472 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02023e4:	100027f3          	csrr	a5,sstatus
ffffffffc02023e8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02023ea:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02023ec:	ebd9                	bnez	a5,ffffffffc0202482 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02023ee:	00007617          	auipc	a2,0x7
ffffffffc02023f2:	c3260613          	addi	a2,a2,-974 # ffffffffc0209020 <slobfree>
ffffffffc02023f6:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02023f8:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02023fa:	679c                	ld	a5,8(a5)
ffffffffc02023fc:	02877a63          	bgeu	a4,s0,ffffffffc0202430 <slob_free+0x58>
ffffffffc0202400:	00f46463          	bltu	s0,a5,ffffffffc0202408 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202404:	fef76ae3          	bltu	a4,a5,ffffffffc02023f8 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0202408:	400c                	lw	a1,0(s0)
ffffffffc020240a:	00459693          	slli	a3,a1,0x4
ffffffffc020240e:	96a2                	add	a3,a3,s0
ffffffffc0202410:	02d78a63          	beq	a5,a3,ffffffffc0202444 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0202414:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0202416:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0202418:	00469793          	slli	a5,a3,0x4
ffffffffc020241c:	97ba                	add	a5,a5,a4
ffffffffc020241e:	02f40e63          	beq	s0,a5,ffffffffc020245a <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc0202422:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0202424:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0202426:	e129                	bnez	a0,ffffffffc0202468 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0202428:	60a2                	ld	ra,8(sp)
ffffffffc020242a:	6402                	ld	s0,0(sp)
ffffffffc020242c:	0141                	addi	sp,sp,16
ffffffffc020242e:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202430:	fcf764e3          	bltu	a4,a5,ffffffffc02023f8 <slob_free+0x20>
ffffffffc0202434:	fcf472e3          	bgeu	s0,a5,ffffffffc02023f8 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0202438:	400c                	lw	a1,0(s0)
ffffffffc020243a:	00459693          	slli	a3,a1,0x4
ffffffffc020243e:	96a2                	add	a3,a3,s0
ffffffffc0202440:	fcd79ae3          	bne	a5,a3,ffffffffc0202414 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0202444:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0202446:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0202448:	9db5                	addw	a1,a1,a3
ffffffffc020244a:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc020244c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020244e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0202450:	00469793          	slli	a5,a3,0x4
ffffffffc0202454:	97ba                	add	a5,a5,a4
ffffffffc0202456:	fcf416e3          	bne	s0,a5,ffffffffc0202422 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020245a:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc020245c:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc020245e:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0202460:	9ebd                	addw	a3,a3,a5
ffffffffc0202462:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0202464:	e70c                	sd	a1,8(a4)
ffffffffc0202466:	d169                	beqz	a0,ffffffffc0202428 <slob_free+0x50>
}
ffffffffc0202468:	6402                	ld	s0,0(sp)
ffffffffc020246a:	60a2                	ld	ra,8(sp)
ffffffffc020246c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020246e:	cc2fe06f          	j	ffffffffc0200930 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0202472:	25bd                	addiw	a1,a1,15
ffffffffc0202474:	8191                	srli	a1,a1,0x4
ffffffffc0202476:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202478:	100027f3          	csrr	a5,sstatus
ffffffffc020247c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020247e:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202480:	d7bd                	beqz	a5,ffffffffc02023ee <slob_free+0x16>
        intr_disable();
ffffffffc0202482:	cb4fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;
ffffffffc0202486:	4505                	li	a0,1
ffffffffc0202488:	b79d                	j	ffffffffc02023ee <slob_free+0x16>
ffffffffc020248a:	8082                	ret

ffffffffc020248c <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc020248c:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020248e:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0202490:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202494:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0202496:	9d5fe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
	if (!page)
ffffffffc020249a:	c91d                	beqz	a0,ffffffffc02024d0 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc020249c:	0000b697          	auipc	a3,0xb
ffffffffc02024a0:	0146b683          	ld	a3,20(a3) # ffffffffc020d4b0 <pages>
ffffffffc02024a4:	8d15                	sub	a0,a0,a3
ffffffffc02024a6:	8519                	srai	a0,a0,0x6
ffffffffc02024a8:	00003697          	auipc	a3,0x3
ffffffffc02024ac:	5606b683          	ld	a3,1376(a3) # ffffffffc0205a08 <nbase>
ffffffffc02024b0:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02024b2:	00c51793          	slli	a5,a0,0xc
ffffffffc02024b6:	83b1                	srli	a5,a5,0xc
ffffffffc02024b8:	0000b717          	auipc	a4,0xb
ffffffffc02024bc:	ff073703          	ld	a4,-16(a4) # ffffffffc020d4a8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02024c0:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02024c2:	00e7fa63          	bgeu	a5,a4,ffffffffc02024d6 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02024c6:	0000b697          	auipc	a3,0xb
ffffffffc02024ca:	ffa6b683          	ld	a3,-6(a3) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc02024ce:	9536                	add	a0,a0,a3
}
ffffffffc02024d0:	60a2                	ld	ra,8(sp)
ffffffffc02024d2:	0141                	addi	sp,sp,16
ffffffffc02024d4:	8082                	ret
ffffffffc02024d6:	86aa                	mv	a3,a0
ffffffffc02024d8:	00002617          	auipc	a2,0x2
ffffffffc02024dc:	4b060613          	addi	a2,a2,1200 # ffffffffc0204988 <commands+0x7c0>
ffffffffc02024e0:	07100593          	li	a1,113
ffffffffc02024e4:	00002517          	auipc	a0,0x2
ffffffffc02024e8:	46c50513          	addi	a0,a0,1132 # ffffffffc0204950 <commands+0x788>
ffffffffc02024ec:	cf3fd0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02024f0 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02024f0:	1101                	addi	sp,sp,-32
ffffffffc02024f2:	ec06                	sd	ra,24(sp)
ffffffffc02024f4:	e822                	sd	s0,16(sp)
ffffffffc02024f6:	e426                	sd	s1,8(sp)
ffffffffc02024f8:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc02024fa:	01050713          	addi	a4,a0,16
ffffffffc02024fe:	6785                	lui	a5,0x1
ffffffffc0202500:	0cf77363          	bgeu	a4,a5,ffffffffc02025c6 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0202504:	00f50493          	addi	s1,a0,15
ffffffffc0202508:	8091                	srli	s1,s1,0x4
ffffffffc020250a:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020250c:	10002673          	csrr	a2,sstatus
ffffffffc0202510:	8a09                	andi	a2,a2,2
ffffffffc0202512:	e25d                	bnez	a2,ffffffffc02025b8 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0202514:	00007917          	auipc	s2,0x7
ffffffffc0202518:	b0c90913          	addi	s2,s2,-1268 # ffffffffc0209020 <slobfree>
ffffffffc020251c:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0202520:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc0202522:	4398                	lw	a4,0(a5)
ffffffffc0202524:	08975e63          	bge	a4,s1,ffffffffc02025c0 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0202528:	00d78b63          	beq	a5,a3,ffffffffc020253e <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc020252c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc020252e:	4018                	lw	a4,0(s0)
ffffffffc0202530:	02975a63          	bge	a4,s1,ffffffffc0202564 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc0202534:	00093683          	ld	a3,0(s2)
ffffffffc0202538:	87a2                	mv	a5,s0
ffffffffc020253a:	fed799e3          	bne	a5,a3,ffffffffc020252c <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc020253e:	ee31                	bnez	a2,ffffffffc020259a <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202540:	4501                	li	a0,0
ffffffffc0202542:	f4bff0ef          	jal	ra,ffffffffc020248c <__slob_get_free_pages.constprop.0>
ffffffffc0202546:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0202548:	cd05                	beqz	a0,ffffffffc0202580 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc020254a:	6585                	lui	a1,0x1
ffffffffc020254c:	e8dff0ef          	jal	ra,ffffffffc02023d8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202550:	10002673          	csrr	a2,sstatus
ffffffffc0202554:	8a09                	andi	a2,a2,2
ffffffffc0202556:	ee05                	bnez	a2,ffffffffc020258e <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0202558:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc020255c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc020255e:	4018                	lw	a4,0(s0)
ffffffffc0202560:	fc974ae3          	blt	a4,s1,ffffffffc0202534 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0202564:	04e48763          	beq	s1,a4,ffffffffc02025b2 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0202568:	00449693          	slli	a3,s1,0x4
ffffffffc020256c:	96a2                	add	a3,a3,s0
ffffffffc020256e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202570:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0202572:	9f05                	subw	a4,a4,s1
ffffffffc0202574:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202576:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0202578:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020257a:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc020257e:	e20d                	bnez	a2,ffffffffc02025a0 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0202580:	60e2                	ld	ra,24(sp)
ffffffffc0202582:	8522                	mv	a0,s0
ffffffffc0202584:	6442                	ld	s0,16(sp)
ffffffffc0202586:	64a2                	ld	s1,8(sp)
ffffffffc0202588:	6902                	ld	s2,0(sp)
ffffffffc020258a:	6105                	addi	sp,sp,32
ffffffffc020258c:	8082                	ret
        intr_disable();
ffffffffc020258e:	ba8fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
			cur = slobfree;
ffffffffc0202592:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0202596:	4605                	li	a2,1
ffffffffc0202598:	b7d1                	j	ffffffffc020255c <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc020259a:	b96fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc020259e:	b74d                	j	ffffffffc0202540 <slob_alloc.constprop.0+0x50>
ffffffffc02025a0:	b90fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
}
ffffffffc02025a4:	60e2                	ld	ra,24(sp)
ffffffffc02025a6:	8522                	mv	a0,s0
ffffffffc02025a8:	6442                	ld	s0,16(sp)
ffffffffc02025aa:	64a2                	ld	s1,8(sp)
ffffffffc02025ac:	6902                	ld	s2,0(sp)
ffffffffc02025ae:	6105                	addi	sp,sp,32
ffffffffc02025b0:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02025b2:	6418                	ld	a4,8(s0)
ffffffffc02025b4:	e798                	sd	a4,8(a5)
ffffffffc02025b6:	b7d1                	j	ffffffffc020257a <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc02025b8:	b7efe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;
ffffffffc02025bc:	4605                	li	a2,1
ffffffffc02025be:	bf99                	j	ffffffffc0202514 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc02025c0:	843e                	mv	s0,a5
ffffffffc02025c2:	87b6                	mv	a5,a3
ffffffffc02025c4:	b745                	j	ffffffffc0202564 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc02025c6:	00003697          	auipc	a3,0x3
ffffffffc02025ca:	bfa68693          	addi	a3,a3,-1030 # ffffffffc02051c0 <commands+0xff8>
ffffffffc02025ce:	00002617          	auipc	a2,0x2
ffffffffc02025d2:	4ea60613          	addi	a2,a2,1258 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc02025d6:	06300593          	li	a1,99
ffffffffc02025da:	00003517          	auipc	a0,0x3
ffffffffc02025de:	c0650513          	addi	a0,a0,-1018 # ffffffffc02051e0 <commands+0x1018>
ffffffffc02025e2:	bfdfd0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02025e6 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc02025e6:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc02025e8:	00003517          	auipc	a0,0x3
ffffffffc02025ec:	c1050513          	addi	a0,a0,-1008 # ffffffffc02051f8 <commands+0x1030>
{
ffffffffc02025f0:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc02025f2:	aeffd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02025f6:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc02025f8:	00003517          	auipc	a0,0x3
ffffffffc02025fc:	c1850513          	addi	a0,a0,-1000 # ffffffffc0205210 <commands+0x1048>
}
ffffffffc0202600:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202602:	adffd06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0202606 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0202606:	1101                	addi	sp,sp,-32
ffffffffc0202608:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc020260a:	6905                	lui	s2,0x1
{
ffffffffc020260c:	e822                	sd	s0,16(sp)
ffffffffc020260e:	ec06                	sd	ra,24(sp)
ffffffffc0202610:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0202612:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc0202616:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0202618:	04a7f963          	bgeu	a5,a0,ffffffffc020266a <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc020261c:	4561                	li	a0,24
ffffffffc020261e:	ed3ff0ef          	jal	ra,ffffffffc02024f0 <slob_alloc.constprop.0>
ffffffffc0202622:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0202624:	c929                	beqz	a0,ffffffffc0202676 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0202626:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc020262a:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc020262c:	00f95763          	bge	s2,a5,ffffffffc020263a <kmalloc+0x34>
ffffffffc0202630:	6705                	lui	a4,0x1
ffffffffc0202632:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0202634:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0202636:	fef74ee3          	blt	a4,a5,ffffffffc0202632 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc020263a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc020263c:	e51ff0ef          	jal	ra,ffffffffc020248c <__slob_get_free_pages.constprop.0>
ffffffffc0202640:	e488                	sd	a0,8(s1)
ffffffffc0202642:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0202644:	c525                	beqz	a0,ffffffffc02026ac <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202646:	100027f3          	csrr	a5,sstatus
ffffffffc020264a:	8b89                	andi	a5,a5,2
ffffffffc020264c:	ef8d                	bnez	a5,ffffffffc0202686 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc020264e:	0000b797          	auipc	a5,0xb
ffffffffc0202652:	e7a78793          	addi	a5,a5,-390 # ffffffffc020d4c8 <bigblocks>
ffffffffc0202656:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0202658:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020265a:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc020265c:	60e2                	ld	ra,24(sp)
ffffffffc020265e:	8522                	mv	a0,s0
ffffffffc0202660:	6442                	ld	s0,16(sp)
ffffffffc0202662:	64a2                	ld	s1,8(sp)
ffffffffc0202664:	6902                	ld	s2,0(sp)
ffffffffc0202666:	6105                	addi	sp,sp,32
ffffffffc0202668:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc020266a:	0541                	addi	a0,a0,16
ffffffffc020266c:	e85ff0ef          	jal	ra,ffffffffc02024f0 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202670:	01050413          	addi	s0,a0,16
ffffffffc0202674:	f565                	bnez	a0,ffffffffc020265c <kmalloc+0x56>
ffffffffc0202676:	4401                	li	s0,0
}
ffffffffc0202678:	60e2                	ld	ra,24(sp)
ffffffffc020267a:	8522                	mv	a0,s0
ffffffffc020267c:	6442                	ld	s0,16(sp)
ffffffffc020267e:	64a2                	ld	s1,8(sp)
ffffffffc0202680:	6902                	ld	s2,0(sp)
ffffffffc0202682:	6105                	addi	sp,sp,32
ffffffffc0202684:	8082                	ret
        intr_disable();
ffffffffc0202686:	ab0fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
		bb->next = bigblocks;
ffffffffc020268a:	0000b797          	auipc	a5,0xb
ffffffffc020268e:	e3e78793          	addi	a5,a5,-450 # ffffffffc020d4c8 <bigblocks>
ffffffffc0202692:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0202694:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0202696:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0202698:	a98fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
		return bb->pages;
ffffffffc020269c:	6480                	ld	s0,8(s1)
}
ffffffffc020269e:	60e2                	ld	ra,24(sp)
ffffffffc02026a0:	64a2                	ld	s1,8(sp)
ffffffffc02026a2:	8522                	mv	a0,s0
ffffffffc02026a4:	6442                	ld	s0,16(sp)
ffffffffc02026a6:	6902                	ld	s2,0(sp)
ffffffffc02026a8:	6105                	addi	sp,sp,32
ffffffffc02026aa:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02026ac:	45e1                	li	a1,24
ffffffffc02026ae:	8526                	mv	a0,s1
ffffffffc02026b0:	d29ff0ef          	jal	ra,ffffffffc02023d8 <slob_free>
	return __kmalloc(size, 0);
ffffffffc02026b4:	b765                	j	ffffffffc020265c <kmalloc+0x56>

ffffffffc02026b6 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc02026b6:	c179                	beqz	a0,ffffffffc020277c <kfree+0xc6>
{
ffffffffc02026b8:	1101                	addi	sp,sp,-32
ffffffffc02026ba:	e822                	sd	s0,16(sp)
ffffffffc02026bc:	ec06                	sd	ra,24(sp)
ffffffffc02026be:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc02026c0:	03451793          	slli	a5,a0,0x34
ffffffffc02026c4:	842a                	mv	s0,a0
ffffffffc02026c6:	e7c1                	bnez	a5,ffffffffc020274e <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02026c8:	100027f3          	csrr	a5,sstatus
ffffffffc02026cc:	8b89                	andi	a5,a5,2
ffffffffc02026ce:	ebc9                	bnez	a5,ffffffffc0202760 <kfree+0xaa>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc02026d0:	0000b797          	auipc	a5,0xb
ffffffffc02026d4:	df87b783          	ld	a5,-520(a5) # ffffffffc020d4c8 <bigblocks>
    return 0;
ffffffffc02026d8:	4601                	li	a2,0
ffffffffc02026da:	cbb5                	beqz	a5,ffffffffc020274e <kfree+0x98>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02026dc:	0000b697          	auipc	a3,0xb
ffffffffc02026e0:	dec68693          	addi	a3,a3,-532 # ffffffffc020d4c8 <bigblocks>
ffffffffc02026e4:	a021                	j	ffffffffc02026ec <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc02026e6:	01048693          	addi	a3,s1,16
ffffffffc02026ea:	c3ad                	beqz	a5,ffffffffc020274c <kfree+0x96>
		{
			if (bb->pages == block)
ffffffffc02026ec:	6798                	ld	a4,8(a5)
ffffffffc02026ee:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc02026f0:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc02026f2:	fe871ae3          	bne	a4,s0,ffffffffc02026e6 <kfree+0x30>
				*last = bb->next;
ffffffffc02026f6:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc02026f8:	ee3d                	bnez	a2,ffffffffc0202776 <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc02026fa:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02026fe:	4098                	lw	a4,0(s1)
ffffffffc0202700:	08f46b63          	bltu	s0,a5,ffffffffc0202796 <kfree+0xe0>
ffffffffc0202704:	0000b697          	auipc	a3,0xb
ffffffffc0202708:	dbc6b683          	ld	a3,-580(a3) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc020270c:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc020270e:	8031                	srli	s0,s0,0xc
ffffffffc0202710:	0000b797          	auipc	a5,0xb
ffffffffc0202714:	d987b783          	ld	a5,-616(a5) # ffffffffc020d4a8 <npage>
ffffffffc0202718:	06f47363          	bgeu	s0,a5,ffffffffc020277e <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc020271c:	00003517          	auipc	a0,0x3
ffffffffc0202720:	2ec53503          	ld	a0,748(a0) # ffffffffc0205a08 <nbase>
ffffffffc0202724:	8c09                	sub	s0,s0,a0
ffffffffc0202726:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0202728:	0000b517          	auipc	a0,0xb
ffffffffc020272c:	d8853503          	ld	a0,-632(a0) # ffffffffc020d4b0 <pages>
ffffffffc0202730:	4585                	li	a1,1
ffffffffc0202732:	9522                	add	a0,a0,s0
ffffffffc0202734:	00e595bb          	sllw	a1,a1,a4
ffffffffc0202738:	f70fe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc020273c:	6442                	ld	s0,16(sp)
ffffffffc020273e:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202740:	8526                	mv	a0,s1
}
ffffffffc0202742:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202744:	45e1                	li	a1,24
}
ffffffffc0202746:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202748:	c91ff06f          	j	ffffffffc02023d8 <slob_free>
ffffffffc020274c:	e215                	bnez	a2,ffffffffc0202770 <kfree+0xba>
ffffffffc020274e:	ff040513          	addi	a0,s0,-16
}
ffffffffc0202752:	6442                	ld	s0,16(sp)
ffffffffc0202754:	60e2                	ld	ra,24(sp)
ffffffffc0202756:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202758:	4581                	li	a1,0
}
ffffffffc020275a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020275c:	c7dff06f          	j	ffffffffc02023d8 <slob_free>
        intr_disable();
ffffffffc0202760:	9d6fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0202764:	0000b797          	auipc	a5,0xb
ffffffffc0202768:	d647b783          	ld	a5,-668(a5) # ffffffffc020d4c8 <bigblocks>
        return 1;
ffffffffc020276c:	4605                	li	a2,1
ffffffffc020276e:	f7bd                	bnez	a5,ffffffffc02026dc <kfree+0x26>
        intr_enable();
ffffffffc0202770:	9c0fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202774:	bfe9                	j	ffffffffc020274e <kfree+0x98>
ffffffffc0202776:	9bafe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc020277a:	b741                	j	ffffffffc02026fa <kfree+0x44>
ffffffffc020277c:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc020277e:	00002617          	auipc	a2,0x2
ffffffffc0202782:	1b260613          	addi	a2,a2,434 # ffffffffc0204930 <commands+0x768>
ffffffffc0202786:	06900593          	li	a1,105
ffffffffc020278a:	00002517          	auipc	a0,0x2
ffffffffc020278e:	1c650513          	addi	a0,a0,454 # ffffffffc0204950 <commands+0x788>
ffffffffc0202792:	a4dfd0ef          	jal	ra,ffffffffc02001de <__panic>
    return pa2page(PADDR(kva));
ffffffffc0202796:	86a2                	mv	a3,s0
ffffffffc0202798:	00002617          	auipc	a2,0x2
ffffffffc020279c:	2a060613          	addi	a2,a2,672 # ffffffffc0204a38 <commands+0x870>
ffffffffc02027a0:	07700593          	li	a1,119
ffffffffc02027a4:	00002517          	auipc	a0,0x2
ffffffffc02027a8:	1ac50513          	addi	a0,a0,428 # ffffffffc0204950 <commands+0x788>
ffffffffc02027ac:	a33fd0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02027b0 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02027b0:	00007797          	auipc	a5,0x7
ffffffffc02027b4:	c8078793          	addi	a5,a5,-896 # ffffffffc0209430 <free_area>
ffffffffc02027b8:	e79c                	sd	a5,8(a5)
ffffffffc02027ba:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02027bc:	0007a823          	sw	zero,16(a5)
}
ffffffffc02027c0:	8082                	ret

ffffffffc02027c2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02027c2:	00007517          	auipc	a0,0x7
ffffffffc02027c6:	c7e56503          	lwu	a0,-898(a0) # ffffffffc0209440 <free_area+0x10>
ffffffffc02027ca:	8082                	ret

ffffffffc02027cc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02027cc:	715d                	addi	sp,sp,-80
ffffffffc02027ce:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc02027d0:	00007417          	auipc	s0,0x7
ffffffffc02027d4:	c6040413          	addi	s0,s0,-928 # ffffffffc0209430 <free_area>
ffffffffc02027d8:	641c                	ld	a5,8(s0)
ffffffffc02027da:	e486                	sd	ra,72(sp)
ffffffffc02027dc:	fc26                	sd	s1,56(sp)
ffffffffc02027de:	f84a                	sd	s2,48(sp)
ffffffffc02027e0:	f44e                	sd	s3,40(sp)
ffffffffc02027e2:	f052                	sd	s4,32(sp)
ffffffffc02027e4:	ec56                	sd	s5,24(sp)
ffffffffc02027e6:	e85a                	sd	s6,16(sp)
ffffffffc02027e8:	e45e                	sd	s7,8(sp)
ffffffffc02027ea:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02027ec:	2a878d63          	beq	a5,s0,ffffffffc0202aa6 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc02027f0:	4481                	li	s1,0
ffffffffc02027f2:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02027f4:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02027f8:	8b09                	andi	a4,a4,2
ffffffffc02027fa:	2a070a63          	beqz	a4,ffffffffc0202aae <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc02027fe:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202802:	679c                	ld	a5,8(a5)
ffffffffc0202804:	2905                	addiw	s2,s2,1
ffffffffc0202806:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202808:	fe8796e3          	bne	a5,s0,ffffffffc02027f4 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020280c:	89a6                	mv	s3,s1
ffffffffc020280e:	ed8fe0ef          	jal	ra,ffffffffc0200ee6 <nr_free_pages>
ffffffffc0202812:	6f351e63          	bne	a0,s3,ffffffffc0202f0e <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202816:	4505                	li	a0,1
ffffffffc0202818:	e52fe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc020281c:	8aaa                	mv	s5,a0
ffffffffc020281e:	42050863          	beqz	a0,ffffffffc0202c4e <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202822:	4505                	li	a0,1
ffffffffc0202824:	e46fe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc0202828:	89aa                	mv	s3,a0
ffffffffc020282a:	70050263          	beqz	a0,ffffffffc0202f2e <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020282e:	4505                	li	a0,1
ffffffffc0202830:	e3afe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc0202834:	8a2a                	mv	s4,a0
ffffffffc0202836:	48050c63          	beqz	a0,ffffffffc0202cce <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020283a:	293a8a63          	beq	s5,s3,ffffffffc0202ace <default_check+0x302>
ffffffffc020283e:	28aa8863          	beq	s5,a0,ffffffffc0202ace <default_check+0x302>
ffffffffc0202842:	28a98663          	beq	s3,a0,ffffffffc0202ace <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202846:	000aa783          	lw	a5,0(s5)
ffffffffc020284a:	2a079263          	bnez	a5,ffffffffc0202aee <default_check+0x322>
ffffffffc020284e:	0009a783          	lw	a5,0(s3)
ffffffffc0202852:	28079e63          	bnez	a5,ffffffffc0202aee <default_check+0x322>
ffffffffc0202856:	411c                	lw	a5,0(a0)
ffffffffc0202858:	28079b63          	bnez	a5,ffffffffc0202aee <default_check+0x322>
    return page - pages + nbase;
ffffffffc020285c:	0000b797          	auipc	a5,0xb
ffffffffc0202860:	c547b783          	ld	a5,-940(a5) # ffffffffc020d4b0 <pages>
ffffffffc0202864:	40fa8733          	sub	a4,s5,a5
ffffffffc0202868:	00003617          	auipc	a2,0x3
ffffffffc020286c:	1a063603          	ld	a2,416(a2) # ffffffffc0205a08 <nbase>
ffffffffc0202870:	8719                	srai	a4,a4,0x6
ffffffffc0202872:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202874:	0000b697          	auipc	a3,0xb
ffffffffc0202878:	c346b683          	ld	a3,-972(a3) # ffffffffc020d4a8 <npage>
ffffffffc020287c:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020287e:	0732                	slli	a4,a4,0xc
ffffffffc0202880:	28d77763          	bgeu	a4,a3,ffffffffc0202b0e <default_check+0x342>
    return page - pages + nbase;
ffffffffc0202884:	40f98733          	sub	a4,s3,a5
ffffffffc0202888:	8719                	srai	a4,a4,0x6
ffffffffc020288a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020288c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020288e:	4cd77063          	bgeu	a4,a3,ffffffffc0202d4e <default_check+0x582>
    return page - pages + nbase;
ffffffffc0202892:	40f507b3          	sub	a5,a0,a5
ffffffffc0202896:	8799                	srai	a5,a5,0x6
ffffffffc0202898:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020289a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020289c:	30d7f963          	bgeu	a5,a3,ffffffffc0202bae <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02028a0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02028a2:	00043c03          	ld	s8,0(s0)
ffffffffc02028a6:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02028aa:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02028ae:	e400                	sd	s0,8(s0)
ffffffffc02028b0:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02028b2:	00007797          	auipc	a5,0x7
ffffffffc02028b6:	b807a723          	sw	zero,-1138(a5) # ffffffffc0209440 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02028ba:	db0fe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc02028be:	2c051863          	bnez	a0,ffffffffc0202b8e <default_check+0x3c2>
    free_page(p0);
ffffffffc02028c2:	4585                	li	a1,1
ffffffffc02028c4:	8556                	mv	a0,s5
ffffffffc02028c6:	de2fe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
    free_page(p1);
ffffffffc02028ca:	4585                	li	a1,1
ffffffffc02028cc:	854e                	mv	a0,s3
ffffffffc02028ce:	ddafe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
    free_page(p2);
ffffffffc02028d2:	4585                	li	a1,1
ffffffffc02028d4:	8552                	mv	a0,s4
ffffffffc02028d6:	dd2fe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
    assert(nr_free == 3);
ffffffffc02028da:	4818                	lw	a4,16(s0)
ffffffffc02028dc:	478d                	li	a5,3
ffffffffc02028de:	28f71863          	bne	a4,a5,ffffffffc0202b6e <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02028e2:	4505                	li	a0,1
ffffffffc02028e4:	d86fe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc02028e8:	89aa                	mv	s3,a0
ffffffffc02028ea:	26050263          	beqz	a0,ffffffffc0202b4e <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02028ee:	4505                	li	a0,1
ffffffffc02028f0:	d7afe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc02028f4:	8aaa                	mv	s5,a0
ffffffffc02028f6:	3a050c63          	beqz	a0,ffffffffc0202cae <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02028fa:	4505                	li	a0,1
ffffffffc02028fc:	d6efe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc0202900:	8a2a                	mv	s4,a0
ffffffffc0202902:	38050663          	beqz	a0,ffffffffc0202c8e <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0202906:	4505                	li	a0,1
ffffffffc0202908:	d62fe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc020290c:	36051163          	bnez	a0,ffffffffc0202c6e <default_check+0x4a2>
    free_page(p0);
ffffffffc0202910:	4585                	li	a1,1
ffffffffc0202912:	854e                	mv	a0,s3
ffffffffc0202914:	d94fe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202918:	641c                	ld	a5,8(s0)
ffffffffc020291a:	20878a63          	beq	a5,s0,ffffffffc0202b2e <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc020291e:	4505                	li	a0,1
ffffffffc0202920:	d4afe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc0202924:	30a99563          	bne	s3,a0,ffffffffc0202c2e <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0202928:	4505                	li	a0,1
ffffffffc020292a:	d40fe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc020292e:	2e051063          	bnez	a0,ffffffffc0202c0e <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0202932:	481c                	lw	a5,16(s0)
ffffffffc0202934:	2a079d63          	bnez	a5,ffffffffc0202bee <default_check+0x422>
    free_page(p);
ffffffffc0202938:	854e                	mv	a0,s3
ffffffffc020293a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020293c:	01843023          	sd	s8,0(s0)
ffffffffc0202940:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0202944:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202948:	d60fe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
    free_page(p1);
ffffffffc020294c:	4585                	li	a1,1
ffffffffc020294e:	8556                	mv	a0,s5
ffffffffc0202950:	d58fe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
    free_page(p2);
ffffffffc0202954:	4585                	li	a1,1
ffffffffc0202956:	8552                	mv	a0,s4
ffffffffc0202958:	d50fe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020295c:	4515                	li	a0,5
ffffffffc020295e:	d0cfe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc0202962:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202964:	26050563          	beqz	a0,ffffffffc0202bce <default_check+0x402>
ffffffffc0202968:	651c                	ld	a5,8(a0)
ffffffffc020296a:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc020296c:	8b85                	andi	a5,a5,1
ffffffffc020296e:	54079063          	bnez	a5,ffffffffc0202eae <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202972:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202974:	00043b03          	ld	s6,0(s0)
ffffffffc0202978:	00843a83          	ld	s5,8(s0)
ffffffffc020297c:	e000                	sd	s0,0(s0)
ffffffffc020297e:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0202980:	ceafe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc0202984:	50051563          	bnez	a0,ffffffffc0202e8e <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202988:	08098a13          	addi	s4,s3,128
ffffffffc020298c:	8552                	mv	a0,s4
ffffffffc020298e:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202990:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0202994:	00007797          	auipc	a5,0x7
ffffffffc0202998:	aa07a623          	sw	zero,-1364(a5) # ffffffffc0209440 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020299c:	d0cfe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02029a0:	4511                	li	a0,4
ffffffffc02029a2:	cc8fe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc02029a6:	4c051463          	bnez	a0,ffffffffc0202e6e <default_check+0x6a2>
ffffffffc02029aa:	0889b783          	ld	a5,136(s3)
ffffffffc02029ae:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02029b0:	8b85                	andi	a5,a5,1
ffffffffc02029b2:	48078e63          	beqz	a5,ffffffffc0202e4e <default_check+0x682>
ffffffffc02029b6:	0909a703          	lw	a4,144(s3)
ffffffffc02029ba:	478d                	li	a5,3
ffffffffc02029bc:	48f71963          	bne	a4,a5,ffffffffc0202e4e <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02029c0:	450d                	li	a0,3
ffffffffc02029c2:	ca8fe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc02029c6:	8c2a                	mv	s8,a0
ffffffffc02029c8:	46050363          	beqz	a0,ffffffffc0202e2e <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc02029cc:	4505                	li	a0,1
ffffffffc02029ce:	c9cfe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc02029d2:	42051e63          	bnez	a0,ffffffffc0202e0e <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc02029d6:	418a1c63          	bne	s4,s8,ffffffffc0202dee <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02029da:	4585                	li	a1,1
ffffffffc02029dc:	854e                	mv	a0,s3
ffffffffc02029de:	ccafe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
    free_pages(p1, 3);
ffffffffc02029e2:	458d                	li	a1,3
ffffffffc02029e4:	8552                	mv	a0,s4
ffffffffc02029e6:	cc2fe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
ffffffffc02029ea:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02029ee:	04098c13          	addi	s8,s3,64
ffffffffc02029f2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02029f4:	8b85                	andi	a5,a5,1
ffffffffc02029f6:	3c078c63          	beqz	a5,ffffffffc0202dce <default_check+0x602>
ffffffffc02029fa:	0109a703          	lw	a4,16(s3)
ffffffffc02029fe:	4785                	li	a5,1
ffffffffc0202a00:	3cf71763          	bne	a4,a5,ffffffffc0202dce <default_check+0x602>
ffffffffc0202a04:	008a3783          	ld	a5,8(s4)
ffffffffc0202a08:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202a0a:	8b85                	andi	a5,a5,1
ffffffffc0202a0c:	3a078163          	beqz	a5,ffffffffc0202dae <default_check+0x5e2>
ffffffffc0202a10:	010a2703          	lw	a4,16(s4)
ffffffffc0202a14:	478d                	li	a5,3
ffffffffc0202a16:	38f71c63          	bne	a4,a5,ffffffffc0202dae <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202a1a:	4505                	li	a0,1
ffffffffc0202a1c:	c4efe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc0202a20:	36a99763          	bne	s3,a0,ffffffffc0202d8e <default_check+0x5c2>
    free_page(p0);
ffffffffc0202a24:	4585                	li	a1,1
ffffffffc0202a26:	c82fe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202a2a:	4509                	li	a0,2
ffffffffc0202a2c:	c3efe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc0202a30:	32aa1f63          	bne	s4,a0,ffffffffc0202d6e <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0202a34:	4589                	li	a1,2
ffffffffc0202a36:	c72fe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
    free_page(p2);
ffffffffc0202a3a:	4585                	li	a1,1
ffffffffc0202a3c:	8562                	mv	a0,s8
ffffffffc0202a3e:	c6afe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202a42:	4515                	li	a0,5
ffffffffc0202a44:	c26fe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc0202a48:	89aa                	mv	s3,a0
ffffffffc0202a4a:	48050263          	beqz	a0,ffffffffc0202ece <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0202a4e:	4505                	li	a0,1
ffffffffc0202a50:	c1afe0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
ffffffffc0202a54:	2c051d63          	bnez	a0,ffffffffc0202d2e <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0202a58:	481c                	lw	a5,16(s0)
ffffffffc0202a5a:	2a079a63          	bnez	a5,ffffffffc0202d0e <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202a5e:	4595                	li	a1,5
ffffffffc0202a60:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202a62:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0202a66:	01643023          	sd	s6,0(s0)
ffffffffc0202a6a:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0202a6e:	c3afe0ef          	jal	ra,ffffffffc0200ea8 <free_pages>
    return listelm->next;
ffffffffc0202a72:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202a74:	00878963          	beq	a5,s0,ffffffffc0202a86 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202a78:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202a7c:	679c                	ld	a5,8(a5)
ffffffffc0202a7e:	397d                	addiw	s2,s2,-1
ffffffffc0202a80:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202a82:	fe879be3          	bne	a5,s0,ffffffffc0202a78 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0202a86:	26091463          	bnez	s2,ffffffffc0202cee <default_check+0x522>
    assert(total == 0);
ffffffffc0202a8a:	46049263          	bnez	s1,ffffffffc0202eee <default_check+0x722>
}
ffffffffc0202a8e:	60a6                	ld	ra,72(sp)
ffffffffc0202a90:	6406                	ld	s0,64(sp)
ffffffffc0202a92:	74e2                	ld	s1,56(sp)
ffffffffc0202a94:	7942                	ld	s2,48(sp)
ffffffffc0202a96:	79a2                	ld	s3,40(sp)
ffffffffc0202a98:	7a02                	ld	s4,32(sp)
ffffffffc0202a9a:	6ae2                	ld	s5,24(sp)
ffffffffc0202a9c:	6b42                	ld	s6,16(sp)
ffffffffc0202a9e:	6ba2                	ld	s7,8(sp)
ffffffffc0202aa0:	6c02                	ld	s8,0(sp)
ffffffffc0202aa2:	6161                	addi	sp,sp,80
ffffffffc0202aa4:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202aa6:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0202aa8:	4481                	li	s1,0
ffffffffc0202aaa:	4901                	li	s2,0
ffffffffc0202aac:	b38d                	j	ffffffffc020280e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0202aae:	00002697          	auipc	a3,0x2
ffffffffc0202ab2:	78268693          	addi	a3,a3,1922 # ffffffffc0205230 <commands+0x1068>
ffffffffc0202ab6:	00002617          	auipc	a2,0x2
ffffffffc0202aba:	00260613          	addi	a2,a2,2 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202abe:	0f000593          	li	a1,240
ffffffffc0202ac2:	00002517          	auipc	a0,0x2
ffffffffc0202ac6:	77e50513          	addi	a0,a0,1918 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202aca:	f14fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202ace:	00003697          	auipc	a3,0x3
ffffffffc0202ad2:	80a68693          	addi	a3,a3,-2038 # ffffffffc02052d8 <commands+0x1110>
ffffffffc0202ad6:	00002617          	auipc	a2,0x2
ffffffffc0202ada:	fe260613          	addi	a2,a2,-30 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202ade:	0bd00593          	li	a1,189
ffffffffc0202ae2:	00002517          	auipc	a0,0x2
ffffffffc0202ae6:	75e50513          	addi	a0,a0,1886 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202aea:	ef4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202aee:	00003697          	auipc	a3,0x3
ffffffffc0202af2:	81268693          	addi	a3,a3,-2030 # ffffffffc0205300 <commands+0x1138>
ffffffffc0202af6:	00002617          	auipc	a2,0x2
ffffffffc0202afa:	fc260613          	addi	a2,a2,-62 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202afe:	0be00593          	li	a1,190
ffffffffc0202b02:	00002517          	auipc	a0,0x2
ffffffffc0202b06:	73e50513          	addi	a0,a0,1854 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202b0a:	ed4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202b0e:	00003697          	auipc	a3,0x3
ffffffffc0202b12:	83268693          	addi	a3,a3,-1998 # ffffffffc0205340 <commands+0x1178>
ffffffffc0202b16:	00002617          	auipc	a2,0x2
ffffffffc0202b1a:	fa260613          	addi	a2,a2,-94 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202b1e:	0c000593          	li	a1,192
ffffffffc0202b22:	00002517          	auipc	a0,0x2
ffffffffc0202b26:	71e50513          	addi	a0,a0,1822 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202b2a:	eb4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202b2e:	00003697          	auipc	a3,0x3
ffffffffc0202b32:	89a68693          	addi	a3,a3,-1894 # ffffffffc02053c8 <commands+0x1200>
ffffffffc0202b36:	00002617          	auipc	a2,0x2
ffffffffc0202b3a:	f8260613          	addi	a2,a2,-126 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202b3e:	0d900593          	li	a1,217
ffffffffc0202b42:	00002517          	auipc	a0,0x2
ffffffffc0202b46:	6fe50513          	addi	a0,a0,1790 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202b4a:	e94fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202b4e:	00002697          	auipc	a3,0x2
ffffffffc0202b52:	72a68693          	addi	a3,a3,1834 # ffffffffc0205278 <commands+0x10b0>
ffffffffc0202b56:	00002617          	auipc	a2,0x2
ffffffffc0202b5a:	f6260613          	addi	a2,a2,-158 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202b5e:	0d200593          	li	a1,210
ffffffffc0202b62:	00002517          	auipc	a0,0x2
ffffffffc0202b66:	6de50513          	addi	a0,a0,1758 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202b6a:	e74fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free == 3);
ffffffffc0202b6e:	00003697          	auipc	a3,0x3
ffffffffc0202b72:	84a68693          	addi	a3,a3,-1974 # ffffffffc02053b8 <commands+0x11f0>
ffffffffc0202b76:	00002617          	auipc	a2,0x2
ffffffffc0202b7a:	f4260613          	addi	a2,a2,-190 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202b7e:	0d000593          	li	a1,208
ffffffffc0202b82:	00002517          	auipc	a0,0x2
ffffffffc0202b86:	6be50513          	addi	a0,a0,1726 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202b8a:	e54fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202b8e:	00003697          	auipc	a3,0x3
ffffffffc0202b92:	81268693          	addi	a3,a3,-2030 # ffffffffc02053a0 <commands+0x11d8>
ffffffffc0202b96:	00002617          	auipc	a2,0x2
ffffffffc0202b9a:	f2260613          	addi	a2,a2,-222 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202b9e:	0cb00593          	li	a1,203
ffffffffc0202ba2:	00002517          	auipc	a0,0x2
ffffffffc0202ba6:	69e50513          	addi	a0,a0,1694 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202baa:	e34fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202bae:	00002697          	auipc	a3,0x2
ffffffffc0202bb2:	7d268693          	addi	a3,a3,2002 # ffffffffc0205380 <commands+0x11b8>
ffffffffc0202bb6:	00002617          	auipc	a2,0x2
ffffffffc0202bba:	f0260613          	addi	a2,a2,-254 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202bbe:	0c200593          	li	a1,194
ffffffffc0202bc2:	00002517          	auipc	a0,0x2
ffffffffc0202bc6:	67e50513          	addi	a0,a0,1662 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202bca:	e14fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(p0 != NULL);
ffffffffc0202bce:	00003697          	auipc	a3,0x3
ffffffffc0202bd2:	84268693          	addi	a3,a3,-1982 # ffffffffc0205410 <commands+0x1248>
ffffffffc0202bd6:	00002617          	auipc	a2,0x2
ffffffffc0202bda:	ee260613          	addi	a2,a2,-286 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202bde:	0f800593          	li	a1,248
ffffffffc0202be2:	00002517          	auipc	a0,0x2
ffffffffc0202be6:	65e50513          	addi	a0,a0,1630 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202bea:	df4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free == 0);
ffffffffc0202bee:	00003697          	auipc	a3,0x3
ffffffffc0202bf2:	81268693          	addi	a3,a3,-2030 # ffffffffc0205400 <commands+0x1238>
ffffffffc0202bf6:	00002617          	auipc	a2,0x2
ffffffffc0202bfa:	ec260613          	addi	a2,a2,-318 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202bfe:	0df00593          	li	a1,223
ffffffffc0202c02:	00002517          	auipc	a0,0x2
ffffffffc0202c06:	63e50513          	addi	a0,a0,1598 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202c0a:	dd4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202c0e:	00002697          	auipc	a3,0x2
ffffffffc0202c12:	79268693          	addi	a3,a3,1938 # ffffffffc02053a0 <commands+0x11d8>
ffffffffc0202c16:	00002617          	auipc	a2,0x2
ffffffffc0202c1a:	ea260613          	addi	a2,a2,-350 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202c1e:	0dd00593          	li	a1,221
ffffffffc0202c22:	00002517          	auipc	a0,0x2
ffffffffc0202c26:	61e50513          	addi	a0,a0,1566 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202c2a:	db4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202c2e:	00002697          	auipc	a3,0x2
ffffffffc0202c32:	7b268693          	addi	a3,a3,1970 # ffffffffc02053e0 <commands+0x1218>
ffffffffc0202c36:	00002617          	auipc	a2,0x2
ffffffffc0202c3a:	e8260613          	addi	a2,a2,-382 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202c3e:	0dc00593          	li	a1,220
ffffffffc0202c42:	00002517          	auipc	a0,0x2
ffffffffc0202c46:	5fe50513          	addi	a0,a0,1534 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202c4a:	d94fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202c4e:	00002697          	auipc	a3,0x2
ffffffffc0202c52:	62a68693          	addi	a3,a3,1578 # ffffffffc0205278 <commands+0x10b0>
ffffffffc0202c56:	00002617          	auipc	a2,0x2
ffffffffc0202c5a:	e6260613          	addi	a2,a2,-414 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202c5e:	0b900593          	li	a1,185
ffffffffc0202c62:	00002517          	auipc	a0,0x2
ffffffffc0202c66:	5de50513          	addi	a0,a0,1502 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202c6a:	d74fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202c6e:	00002697          	auipc	a3,0x2
ffffffffc0202c72:	73268693          	addi	a3,a3,1842 # ffffffffc02053a0 <commands+0x11d8>
ffffffffc0202c76:	00002617          	auipc	a2,0x2
ffffffffc0202c7a:	e4260613          	addi	a2,a2,-446 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202c7e:	0d600593          	li	a1,214
ffffffffc0202c82:	00002517          	auipc	a0,0x2
ffffffffc0202c86:	5be50513          	addi	a0,a0,1470 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202c8a:	d54fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202c8e:	00002697          	auipc	a3,0x2
ffffffffc0202c92:	62a68693          	addi	a3,a3,1578 # ffffffffc02052b8 <commands+0x10f0>
ffffffffc0202c96:	00002617          	auipc	a2,0x2
ffffffffc0202c9a:	e2260613          	addi	a2,a2,-478 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202c9e:	0d400593          	li	a1,212
ffffffffc0202ca2:	00002517          	auipc	a0,0x2
ffffffffc0202ca6:	59e50513          	addi	a0,a0,1438 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202caa:	d34fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202cae:	00002697          	auipc	a3,0x2
ffffffffc0202cb2:	5ea68693          	addi	a3,a3,1514 # ffffffffc0205298 <commands+0x10d0>
ffffffffc0202cb6:	00002617          	auipc	a2,0x2
ffffffffc0202cba:	e0260613          	addi	a2,a2,-510 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202cbe:	0d300593          	li	a1,211
ffffffffc0202cc2:	00002517          	auipc	a0,0x2
ffffffffc0202cc6:	57e50513          	addi	a0,a0,1406 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202cca:	d14fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202cce:	00002697          	auipc	a3,0x2
ffffffffc0202cd2:	5ea68693          	addi	a3,a3,1514 # ffffffffc02052b8 <commands+0x10f0>
ffffffffc0202cd6:	00002617          	auipc	a2,0x2
ffffffffc0202cda:	de260613          	addi	a2,a2,-542 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202cde:	0bb00593          	li	a1,187
ffffffffc0202ce2:	00002517          	auipc	a0,0x2
ffffffffc0202ce6:	55e50513          	addi	a0,a0,1374 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202cea:	cf4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(count == 0);
ffffffffc0202cee:	00003697          	auipc	a3,0x3
ffffffffc0202cf2:	87268693          	addi	a3,a3,-1934 # ffffffffc0205560 <commands+0x1398>
ffffffffc0202cf6:	00002617          	auipc	a2,0x2
ffffffffc0202cfa:	dc260613          	addi	a2,a2,-574 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202cfe:	12500593          	li	a1,293
ffffffffc0202d02:	00002517          	auipc	a0,0x2
ffffffffc0202d06:	53e50513          	addi	a0,a0,1342 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202d0a:	cd4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free == 0);
ffffffffc0202d0e:	00002697          	auipc	a3,0x2
ffffffffc0202d12:	6f268693          	addi	a3,a3,1778 # ffffffffc0205400 <commands+0x1238>
ffffffffc0202d16:	00002617          	auipc	a2,0x2
ffffffffc0202d1a:	da260613          	addi	a2,a2,-606 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202d1e:	11a00593          	li	a1,282
ffffffffc0202d22:	00002517          	auipc	a0,0x2
ffffffffc0202d26:	51e50513          	addi	a0,a0,1310 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202d2a:	cb4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202d2e:	00002697          	auipc	a3,0x2
ffffffffc0202d32:	67268693          	addi	a3,a3,1650 # ffffffffc02053a0 <commands+0x11d8>
ffffffffc0202d36:	00002617          	auipc	a2,0x2
ffffffffc0202d3a:	d8260613          	addi	a2,a2,-638 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202d3e:	11800593          	li	a1,280
ffffffffc0202d42:	00002517          	auipc	a0,0x2
ffffffffc0202d46:	4fe50513          	addi	a0,a0,1278 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202d4a:	c94fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202d4e:	00002697          	auipc	a3,0x2
ffffffffc0202d52:	61268693          	addi	a3,a3,1554 # ffffffffc0205360 <commands+0x1198>
ffffffffc0202d56:	00002617          	auipc	a2,0x2
ffffffffc0202d5a:	d6260613          	addi	a2,a2,-670 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202d5e:	0c100593          	li	a1,193
ffffffffc0202d62:	00002517          	auipc	a0,0x2
ffffffffc0202d66:	4de50513          	addi	a0,a0,1246 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202d6a:	c74fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202d6e:	00002697          	auipc	a3,0x2
ffffffffc0202d72:	7b268693          	addi	a3,a3,1970 # ffffffffc0205520 <commands+0x1358>
ffffffffc0202d76:	00002617          	auipc	a2,0x2
ffffffffc0202d7a:	d4260613          	addi	a2,a2,-702 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202d7e:	11200593          	li	a1,274
ffffffffc0202d82:	00002517          	auipc	a0,0x2
ffffffffc0202d86:	4be50513          	addi	a0,a0,1214 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202d8a:	c54fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202d8e:	00002697          	auipc	a3,0x2
ffffffffc0202d92:	77268693          	addi	a3,a3,1906 # ffffffffc0205500 <commands+0x1338>
ffffffffc0202d96:	00002617          	auipc	a2,0x2
ffffffffc0202d9a:	d2260613          	addi	a2,a2,-734 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202d9e:	11000593          	li	a1,272
ffffffffc0202da2:	00002517          	auipc	a0,0x2
ffffffffc0202da6:	49e50513          	addi	a0,a0,1182 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202daa:	c34fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202dae:	00002697          	auipc	a3,0x2
ffffffffc0202db2:	72a68693          	addi	a3,a3,1834 # ffffffffc02054d8 <commands+0x1310>
ffffffffc0202db6:	00002617          	auipc	a2,0x2
ffffffffc0202dba:	d0260613          	addi	a2,a2,-766 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202dbe:	10e00593          	li	a1,270
ffffffffc0202dc2:	00002517          	auipc	a0,0x2
ffffffffc0202dc6:	47e50513          	addi	a0,a0,1150 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202dca:	c14fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202dce:	00002697          	auipc	a3,0x2
ffffffffc0202dd2:	6e268693          	addi	a3,a3,1762 # ffffffffc02054b0 <commands+0x12e8>
ffffffffc0202dd6:	00002617          	auipc	a2,0x2
ffffffffc0202dda:	ce260613          	addi	a2,a2,-798 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202dde:	10d00593          	li	a1,269
ffffffffc0202de2:	00002517          	auipc	a0,0x2
ffffffffc0202de6:	45e50513          	addi	a0,a0,1118 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202dea:	bf4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202dee:	00002697          	auipc	a3,0x2
ffffffffc0202df2:	6b268693          	addi	a3,a3,1714 # ffffffffc02054a0 <commands+0x12d8>
ffffffffc0202df6:	00002617          	auipc	a2,0x2
ffffffffc0202dfa:	cc260613          	addi	a2,a2,-830 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202dfe:	10800593          	li	a1,264
ffffffffc0202e02:	00002517          	auipc	a0,0x2
ffffffffc0202e06:	43e50513          	addi	a0,a0,1086 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202e0a:	bd4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202e0e:	00002697          	auipc	a3,0x2
ffffffffc0202e12:	59268693          	addi	a3,a3,1426 # ffffffffc02053a0 <commands+0x11d8>
ffffffffc0202e16:	00002617          	auipc	a2,0x2
ffffffffc0202e1a:	ca260613          	addi	a2,a2,-862 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202e1e:	10700593          	li	a1,263
ffffffffc0202e22:	00002517          	auipc	a0,0x2
ffffffffc0202e26:	41e50513          	addi	a0,a0,1054 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202e2a:	bb4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202e2e:	00002697          	auipc	a3,0x2
ffffffffc0202e32:	65268693          	addi	a3,a3,1618 # ffffffffc0205480 <commands+0x12b8>
ffffffffc0202e36:	00002617          	auipc	a2,0x2
ffffffffc0202e3a:	c8260613          	addi	a2,a2,-894 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202e3e:	10600593          	li	a1,262
ffffffffc0202e42:	00002517          	auipc	a0,0x2
ffffffffc0202e46:	3fe50513          	addi	a0,a0,1022 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202e4a:	b94fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202e4e:	00002697          	auipc	a3,0x2
ffffffffc0202e52:	60268693          	addi	a3,a3,1538 # ffffffffc0205450 <commands+0x1288>
ffffffffc0202e56:	00002617          	auipc	a2,0x2
ffffffffc0202e5a:	c6260613          	addi	a2,a2,-926 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202e5e:	10500593          	li	a1,261
ffffffffc0202e62:	00002517          	auipc	a0,0x2
ffffffffc0202e66:	3de50513          	addi	a0,a0,990 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202e6a:	b74fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202e6e:	00002697          	auipc	a3,0x2
ffffffffc0202e72:	5ca68693          	addi	a3,a3,1482 # ffffffffc0205438 <commands+0x1270>
ffffffffc0202e76:	00002617          	auipc	a2,0x2
ffffffffc0202e7a:	c4260613          	addi	a2,a2,-958 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202e7e:	10400593          	li	a1,260
ffffffffc0202e82:	00002517          	auipc	a0,0x2
ffffffffc0202e86:	3be50513          	addi	a0,a0,958 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202e8a:	b54fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202e8e:	00002697          	auipc	a3,0x2
ffffffffc0202e92:	51268693          	addi	a3,a3,1298 # ffffffffc02053a0 <commands+0x11d8>
ffffffffc0202e96:	00002617          	auipc	a2,0x2
ffffffffc0202e9a:	c2260613          	addi	a2,a2,-990 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202e9e:	0fe00593          	li	a1,254
ffffffffc0202ea2:	00002517          	auipc	a0,0x2
ffffffffc0202ea6:	39e50513          	addi	a0,a0,926 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202eaa:	b34fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(!PageProperty(p0));
ffffffffc0202eae:	00002697          	auipc	a3,0x2
ffffffffc0202eb2:	57268693          	addi	a3,a3,1394 # ffffffffc0205420 <commands+0x1258>
ffffffffc0202eb6:	00002617          	auipc	a2,0x2
ffffffffc0202eba:	c0260613          	addi	a2,a2,-1022 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202ebe:	0f900593          	li	a1,249
ffffffffc0202ec2:	00002517          	auipc	a0,0x2
ffffffffc0202ec6:	37e50513          	addi	a0,a0,894 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202eca:	b14fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202ece:	00002697          	auipc	a3,0x2
ffffffffc0202ed2:	67268693          	addi	a3,a3,1650 # ffffffffc0205540 <commands+0x1378>
ffffffffc0202ed6:	00002617          	auipc	a2,0x2
ffffffffc0202eda:	be260613          	addi	a2,a2,-1054 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202ede:	11700593          	li	a1,279
ffffffffc0202ee2:	00002517          	auipc	a0,0x2
ffffffffc0202ee6:	35e50513          	addi	a0,a0,862 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202eea:	af4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(total == 0);
ffffffffc0202eee:	00002697          	auipc	a3,0x2
ffffffffc0202ef2:	68268693          	addi	a3,a3,1666 # ffffffffc0205570 <commands+0x13a8>
ffffffffc0202ef6:	00002617          	auipc	a2,0x2
ffffffffc0202efa:	bc260613          	addi	a2,a2,-1086 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202efe:	12600593          	li	a1,294
ffffffffc0202f02:	00002517          	auipc	a0,0x2
ffffffffc0202f06:	33e50513          	addi	a0,a0,830 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202f0a:	ad4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(total == nr_free_pages());
ffffffffc0202f0e:	00002697          	auipc	a3,0x2
ffffffffc0202f12:	34a68693          	addi	a3,a3,842 # ffffffffc0205258 <commands+0x1090>
ffffffffc0202f16:	00002617          	auipc	a2,0x2
ffffffffc0202f1a:	ba260613          	addi	a2,a2,-1118 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202f1e:	0f300593          	li	a1,243
ffffffffc0202f22:	00002517          	auipc	a0,0x2
ffffffffc0202f26:	31e50513          	addi	a0,a0,798 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202f2a:	ab4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202f2e:	00002697          	auipc	a3,0x2
ffffffffc0202f32:	36a68693          	addi	a3,a3,874 # ffffffffc0205298 <commands+0x10d0>
ffffffffc0202f36:	00002617          	auipc	a2,0x2
ffffffffc0202f3a:	b8260613          	addi	a2,a2,-1150 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0202f3e:	0ba00593          	li	a1,186
ffffffffc0202f42:	00002517          	auipc	a0,0x2
ffffffffc0202f46:	2fe50513          	addi	a0,a0,766 # ffffffffc0205240 <commands+0x1078>
ffffffffc0202f4a:	a94fd0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0202f4e <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202f4e:	1141                	addi	sp,sp,-16
ffffffffc0202f50:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202f52:	14058463          	beqz	a1,ffffffffc020309a <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0202f56:	00659693          	slli	a3,a1,0x6
ffffffffc0202f5a:	96aa                	add	a3,a3,a0
ffffffffc0202f5c:	87aa                	mv	a5,a0
ffffffffc0202f5e:	02d50263          	beq	a0,a3,ffffffffc0202f82 <default_free_pages+0x34>
ffffffffc0202f62:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202f64:	8b05                	andi	a4,a4,1
ffffffffc0202f66:	10071a63          	bnez	a4,ffffffffc020307a <default_free_pages+0x12c>
ffffffffc0202f6a:	6798                	ld	a4,8(a5)
ffffffffc0202f6c:	8b09                	andi	a4,a4,2
ffffffffc0202f6e:	10071663          	bnez	a4,ffffffffc020307a <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0202f72:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0202f76:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202f7a:	04078793          	addi	a5,a5,64
ffffffffc0202f7e:	fed792e3          	bne	a5,a3,ffffffffc0202f62 <default_free_pages+0x14>
    base->property = n;
ffffffffc0202f82:	2581                	sext.w	a1,a1
ffffffffc0202f84:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0202f86:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202f8a:	4789                	li	a5,2
ffffffffc0202f8c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202f90:	00006697          	auipc	a3,0x6
ffffffffc0202f94:	4a068693          	addi	a3,a3,1184 # ffffffffc0209430 <free_area>
ffffffffc0202f98:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202f9a:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202f9c:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0202fa0:	9db9                	addw	a1,a1,a4
ffffffffc0202fa2:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202fa4:	0ad78463          	beq	a5,a3,ffffffffc020304c <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0202fa8:	fe878713          	addi	a4,a5,-24
ffffffffc0202fac:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202fb0:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202fb2:	00e56a63          	bltu	a0,a4,ffffffffc0202fc6 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0202fb6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202fb8:	04d70c63          	beq	a4,a3,ffffffffc0203010 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc0202fbc:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202fbe:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202fc2:	fee57ae3          	bgeu	a0,a4,ffffffffc0202fb6 <default_free_pages+0x68>
ffffffffc0202fc6:	c199                	beqz	a1,ffffffffc0202fcc <default_free_pages+0x7e>
ffffffffc0202fc8:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202fcc:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202fce:	e390                	sd	a2,0(a5)
ffffffffc0202fd0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202fd2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202fd4:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0202fd6:	00d70d63          	beq	a4,a3,ffffffffc0202ff0 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0202fda:	ff872583          	lw	a1,-8(a4) # ff8 <kern_entry-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc0202fde:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0202fe2:	02059813          	slli	a6,a1,0x20
ffffffffc0202fe6:	01a85793          	srli	a5,a6,0x1a
ffffffffc0202fea:	97b2                	add	a5,a5,a2
ffffffffc0202fec:	02f50c63          	beq	a0,a5,ffffffffc0203024 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0202ff0:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0202ff2:	00d78c63          	beq	a5,a3,ffffffffc020300a <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0202ff6:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0202ff8:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0202ffc:	02061593          	slli	a1,a2,0x20
ffffffffc0203000:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0203004:	972a                	add	a4,a4,a0
ffffffffc0203006:	04e68a63          	beq	a3,a4,ffffffffc020305a <default_free_pages+0x10c>
}
ffffffffc020300a:	60a2                	ld	ra,8(sp)
ffffffffc020300c:	0141                	addi	sp,sp,16
ffffffffc020300e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203010:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203012:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0203014:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203016:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203018:	02d70763          	beq	a4,a3,ffffffffc0203046 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020301c:	8832                	mv	a6,a2
ffffffffc020301e:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203020:	87ba                	mv	a5,a4
ffffffffc0203022:	bf71                	j	ffffffffc0202fbe <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0203024:	491c                	lw	a5,16(a0)
ffffffffc0203026:	9dbd                	addw	a1,a1,a5
ffffffffc0203028:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020302c:	57f5                	li	a5,-3
ffffffffc020302e:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203032:	01853803          	ld	a6,24(a0)
ffffffffc0203036:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0203038:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020303a:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc020303e:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0203040:	0105b023          	sd	a6,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203044:	b77d                	j	ffffffffc0202ff2 <default_free_pages+0xa4>
ffffffffc0203046:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203048:	873e                	mv	a4,a5
ffffffffc020304a:	bf41                	j	ffffffffc0202fda <default_free_pages+0x8c>
}
ffffffffc020304c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020304e:	e390                	sd	a2,0(a5)
ffffffffc0203050:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203052:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203054:	ed1c                	sd	a5,24(a0)
ffffffffc0203056:	0141                	addi	sp,sp,16
ffffffffc0203058:	8082                	ret
            base->property += p->property;
ffffffffc020305a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020305e:	ff078693          	addi	a3,a5,-16
ffffffffc0203062:	9e39                	addw	a2,a2,a4
ffffffffc0203064:	c910                	sw	a2,16(a0)
ffffffffc0203066:	5775                	li	a4,-3
ffffffffc0203068:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020306c:	6398                	ld	a4,0(a5)
ffffffffc020306e:	679c                	ld	a5,8(a5)
}
ffffffffc0203070:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203072:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203074:	e398                	sd	a4,0(a5)
ffffffffc0203076:	0141                	addi	sp,sp,16
ffffffffc0203078:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020307a:	00002697          	auipc	a3,0x2
ffffffffc020307e:	50e68693          	addi	a3,a3,1294 # ffffffffc0205588 <commands+0x13c0>
ffffffffc0203082:	00002617          	auipc	a2,0x2
ffffffffc0203086:	a3660613          	addi	a2,a2,-1482 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc020308a:	08300593          	li	a1,131
ffffffffc020308e:	00002517          	auipc	a0,0x2
ffffffffc0203092:	1b250513          	addi	a0,a0,434 # ffffffffc0205240 <commands+0x1078>
ffffffffc0203096:	948fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(n > 0);
ffffffffc020309a:	00002697          	auipc	a3,0x2
ffffffffc020309e:	4e668693          	addi	a3,a3,1254 # ffffffffc0205580 <commands+0x13b8>
ffffffffc02030a2:	00002617          	auipc	a2,0x2
ffffffffc02030a6:	a1660613          	addi	a2,a2,-1514 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc02030aa:	08000593          	li	a1,128
ffffffffc02030ae:	00002517          	auipc	a0,0x2
ffffffffc02030b2:	19250513          	addi	a0,a0,402 # ffffffffc0205240 <commands+0x1078>
ffffffffc02030b6:	928fd0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02030ba <default_alloc_pages>:
    assert(n > 0);
ffffffffc02030ba:	c941                	beqz	a0,ffffffffc020314a <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc02030bc:	00006597          	auipc	a1,0x6
ffffffffc02030c0:	37458593          	addi	a1,a1,884 # ffffffffc0209430 <free_area>
ffffffffc02030c4:	0105a803          	lw	a6,16(a1)
ffffffffc02030c8:	872a                	mv	a4,a0
ffffffffc02030ca:	02081793          	slli	a5,a6,0x20
ffffffffc02030ce:	9381                	srli	a5,a5,0x20
ffffffffc02030d0:	00a7ee63          	bltu	a5,a0,ffffffffc02030ec <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02030d4:	87ae                	mv	a5,a1
ffffffffc02030d6:	a801                	j	ffffffffc02030e6 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02030d8:	ff87a683          	lw	a3,-8(a5)
ffffffffc02030dc:	02069613          	slli	a2,a3,0x20
ffffffffc02030e0:	9201                	srli	a2,a2,0x20
ffffffffc02030e2:	00e67763          	bgeu	a2,a4,ffffffffc02030f0 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02030e6:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02030e8:	feb798e3          	bne	a5,a1,ffffffffc02030d8 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02030ec:	4501                	li	a0,0
}
ffffffffc02030ee:	8082                	ret
    return listelm->prev;
ffffffffc02030f0:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02030f4:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02030f8:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02030fc:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0203100:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203104:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0203108:	02c77863          	bgeu	a4,a2,ffffffffc0203138 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020310c:	071a                	slli	a4,a4,0x6
ffffffffc020310e:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0203110:	41c686bb          	subw	a3,a3,t3
ffffffffc0203114:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203116:	00870613          	addi	a2,a4,8
ffffffffc020311a:	4689                	li	a3,2
ffffffffc020311c:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203120:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203124:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0203128:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020312c:	e290                	sd	a2,0(a3)
ffffffffc020312e:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0203132:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0203134:	01173c23          	sd	a7,24(a4)
ffffffffc0203138:	41c8083b          	subw	a6,a6,t3
ffffffffc020313c:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203140:	5775                	li	a4,-3
ffffffffc0203142:	17c1                	addi	a5,a5,-16
ffffffffc0203144:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0203148:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020314a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020314c:	00002697          	auipc	a3,0x2
ffffffffc0203150:	43468693          	addi	a3,a3,1076 # ffffffffc0205580 <commands+0x13b8>
ffffffffc0203154:	00002617          	auipc	a2,0x2
ffffffffc0203158:	96460613          	addi	a2,a2,-1692 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc020315c:	06200593          	li	a1,98
ffffffffc0203160:	00002517          	auipc	a0,0x2
ffffffffc0203164:	0e050513          	addi	a0,a0,224 # ffffffffc0205240 <commands+0x1078>
default_alloc_pages(size_t n) {
ffffffffc0203168:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020316a:	874fd0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc020316e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020316e:	1141                	addi	sp,sp,-16
ffffffffc0203170:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203172:	c5f1                	beqz	a1,ffffffffc020323e <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0203174:	00659693          	slli	a3,a1,0x6
ffffffffc0203178:	96aa                	add	a3,a3,a0
ffffffffc020317a:	87aa                	mv	a5,a0
ffffffffc020317c:	00d50f63          	beq	a0,a3,ffffffffc020319a <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203180:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0203182:	8b05                	andi	a4,a4,1
ffffffffc0203184:	cf49                	beqz	a4,ffffffffc020321e <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0203186:	0007a823          	sw	zero,16(a5)
ffffffffc020318a:	0007b423          	sd	zero,8(a5)
ffffffffc020318e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203192:	04078793          	addi	a5,a5,64
ffffffffc0203196:	fed795e3          	bne	a5,a3,ffffffffc0203180 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020319a:	2581                	sext.w	a1,a1
ffffffffc020319c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020319e:	4789                	li	a5,2
ffffffffc02031a0:	00850713          	addi	a4,a0,8
ffffffffc02031a4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02031a8:	00006697          	auipc	a3,0x6
ffffffffc02031ac:	28868693          	addi	a3,a3,648 # ffffffffc0209430 <free_area>
ffffffffc02031b0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02031b2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02031b4:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02031b8:	9db9                	addw	a1,a1,a4
ffffffffc02031ba:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02031bc:	04d78a63          	beq	a5,a3,ffffffffc0203210 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc02031c0:	fe878713          	addi	a4,a5,-24
ffffffffc02031c4:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02031c8:	4581                	li	a1,0
            if (base < page) {
ffffffffc02031ca:	00e56a63          	bltu	a0,a4,ffffffffc02031de <default_init_memmap+0x70>
    return listelm->next;
ffffffffc02031ce:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02031d0:	02d70263          	beq	a4,a3,ffffffffc02031f4 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc02031d4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02031d6:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02031da:	fee57ae3          	bgeu	a0,a4,ffffffffc02031ce <default_init_memmap+0x60>
ffffffffc02031de:	c199                	beqz	a1,ffffffffc02031e4 <default_init_memmap+0x76>
ffffffffc02031e0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02031e4:	6398                	ld	a4,0(a5)
}
ffffffffc02031e6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02031e8:	e390                	sd	a2,0(a5)
ffffffffc02031ea:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02031ec:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02031ee:	ed18                	sd	a4,24(a0)
ffffffffc02031f0:	0141                	addi	sp,sp,16
ffffffffc02031f2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02031f4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02031f6:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02031f8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02031fa:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02031fc:	00d70663          	beq	a4,a3,ffffffffc0203208 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0203200:	8832                	mv	a6,a2
ffffffffc0203202:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203204:	87ba                	mv	a5,a4
ffffffffc0203206:	bfc1                	j	ffffffffc02031d6 <default_init_memmap+0x68>
}
ffffffffc0203208:	60a2                	ld	ra,8(sp)
ffffffffc020320a:	e290                	sd	a2,0(a3)
ffffffffc020320c:	0141                	addi	sp,sp,16
ffffffffc020320e:	8082                	ret
ffffffffc0203210:	60a2                	ld	ra,8(sp)
ffffffffc0203212:	e390                	sd	a2,0(a5)
ffffffffc0203214:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203216:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203218:	ed1c                	sd	a5,24(a0)
ffffffffc020321a:	0141                	addi	sp,sp,16
ffffffffc020321c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020321e:	00002697          	auipc	a3,0x2
ffffffffc0203222:	39268693          	addi	a3,a3,914 # ffffffffc02055b0 <commands+0x13e8>
ffffffffc0203226:	00002617          	auipc	a2,0x2
ffffffffc020322a:	89260613          	addi	a2,a2,-1902 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc020322e:	04900593          	li	a1,73
ffffffffc0203232:	00002517          	auipc	a0,0x2
ffffffffc0203236:	00e50513          	addi	a0,a0,14 # ffffffffc0205240 <commands+0x1078>
ffffffffc020323a:	fa5fc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(n > 0);
ffffffffc020323e:	00002697          	auipc	a3,0x2
ffffffffc0203242:	34268693          	addi	a3,a3,834 # ffffffffc0205580 <commands+0x13b8>
ffffffffc0203246:	00002617          	auipc	a2,0x2
ffffffffc020324a:	87260613          	addi	a2,a2,-1934 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc020324e:	04600593          	li	a1,70
ffffffffc0203252:	00002517          	auipc	a0,0x2
ffffffffc0203256:	fee50513          	addi	a0,a0,-18 # ffffffffc0205240 <commands+0x1078>
ffffffffc020325a:	f85fc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc020325e <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc020325e:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203260:	9402                	jalr	s0

	jal do_exit
ffffffffc0203262:	498000ef          	jal	ra,ffffffffc02036fa <do_exit>

ffffffffc0203266 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0203266:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020326a:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020326e:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0203270:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0203272:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0203276:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc020327a:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020327e:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0203282:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0203286:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc020328a:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc020328e:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0203292:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0203296:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc020329a:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc020329e:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02032a2:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02032a4:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02032a6:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02032aa:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02032ae:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02032b2:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02032b6:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02032ba:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02032be:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02032c2:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02032c6:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02032ca:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02032ce:	8082                	ret

ffffffffc02032d0 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc02032d0:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02032d2:	0e800513          	li	a0,232
{
ffffffffc02032d6:	e022                	sd	s0,0(sp)
ffffffffc02032d8:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02032da:	b2cff0ef          	jal	ra,ffffffffc0202606 <kmalloc>
ffffffffc02032de:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc02032e0:	c12d                	beqz	a0,ffffffffc0203342 <alloc_proc+0x72>
         *       struct trapframe *tf;                       // Trap frame for current interrupt
         *       uintptr_t pgdir;                            // the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */
        memset(proc, 0, sizeof(struct proc_struct));
ffffffffc02032e2:	0e800613          	li	a2,232
ffffffffc02032e6:	4581                	li	a1,0
ffffffffc02032e8:	001000ef          	jal	ra,ffffffffc0203ae8 <memset>
        proc->state = PROC_UNINIT;
ffffffffc02032ec:	57fd                	li	a5,-1
ffffffffc02032ee:	1782                	slli	a5,a5,0x20
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        /* context and name already zeroed by memset */
        memset(&proc->context, 0, sizeof(proc->context));
ffffffffc02032f0:	07000613          	li	a2,112
ffffffffc02032f4:	4581                	li	a1,0
        proc->state = PROC_UNINIT;
ffffffffc02032f6:	e01c                	sd	a5,0(s0)
        proc->runs = 0;
ffffffffc02032f8:	00042423          	sw	zero,8(s0)
        proc->kstack = 0;
ffffffffc02032fc:	00043823          	sd	zero,16(s0)
        proc->need_resched = 0;
ffffffffc0203300:	00042c23          	sw	zero,24(s0)
        proc->parent = NULL;
ffffffffc0203304:	02043023          	sd	zero,32(s0)
        proc->mm = NULL;
ffffffffc0203308:	02043423          	sd	zero,40(s0)
        memset(&proc->context, 0, sizeof(proc->context));
ffffffffc020330c:	03040513          	addi	a0,s0,48
ffffffffc0203310:	7d8000ef          	jal	ra,ffffffffc0203ae8 <memset>
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203314:	0000a797          	auipc	a5,0xa
ffffffffc0203318:	1847b783          	ld	a5,388(a5) # ffffffffc020d498 <boot_pgdir_pa>
ffffffffc020331c:	f45c                	sd	a5,168(s0)
        proc->tf = NULL;
ffffffffc020331e:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0203322:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203326:	4641                	li	a2,16
ffffffffc0203328:	4581                	li	a1,0
ffffffffc020332a:	0b440513          	addi	a0,s0,180
ffffffffc020332e:	7ba000ef          	jal	ra,ffffffffc0203ae8 <memset>
        /* initialize list links */
        list_init(&proc->list_link);
ffffffffc0203332:	0c840713          	addi	a4,s0,200
        list_init(&proc->hash_link);        
ffffffffc0203336:	0d840793          	addi	a5,s0,216
    elm->prev = elm->next = elm;
ffffffffc020333a:	e878                	sd	a4,208(s0)
ffffffffc020333c:	e478                	sd	a4,200(s0)
ffffffffc020333e:	f07c                	sd	a5,224(s0)
ffffffffc0203340:	ec7c                	sd	a5,216(s0)
    }
    return proc;
}
ffffffffc0203342:	60a2                	ld	ra,8(sp)
ffffffffc0203344:	8522                	mv	a0,s0
ffffffffc0203346:	6402                	ld	s0,0(sp)
ffffffffc0203348:	0141                	addi	sp,sp,16
ffffffffc020334a:	8082                	ret

ffffffffc020334c <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc020334c:	0000a797          	auipc	a5,0xa
ffffffffc0203350:	1847b783          	ld	a5,388(a5) # ffffffffc020d4d0 <current>
ffffffffc0203354:	73c8                	ld	a0,160(a5)
ffffffffc0203356:	ad7fd06f          	j	ffffffffc0200e2c <forkrets>

ffffffffc020335a <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc020335a:	7179                	addi	sp,sp,-48
ffffffffc020335c:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc020335e:	0000a497          	auipc	s1,0xa
ffffffffc0203362:	0ea48493          	addi	s1,s1,234 # ffffffffc020d448 <name.2>
{
ffffffffc0203366:	f022                	sd	s0,32(sp)
ffffffffc0203368:	e84a                	sd	s2,16(sp)
ffffffffc020336a:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020336c:	0000a917          	auipc	s2,0xa
ffffffffc0203370:	16493903          	ld	s2,356(s2) # ffffffffc020d4d0 <current>
    memset(name, 0, sizeof(name));
ffffffffc0203374:	4641                	li	a2,16
ffffffffc0203376:	4581                	li	a1,0
ffffffffc0203378:	8526                	mv	a0,s1
{
ffffffffc020337a:	f406                	sd	ra,40(sp)
ffffffffc020337c:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020337e:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc0203382:	766000ef          	jal	ra,ffffffffc0203ae8 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0203386:	0b490593          	addi	a1,s2,180
ffffffffc020338a:	463d                	li	a2,15
ffffffffc020338c:	8526                	mv	a0,s1
ffffffffc020338e:	76c000ef          	jal	ra,ffffffffc0203afa <memcpy>
ffffffffc0203392:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0203394:	85ce                	mv	a1,s3
ffffffffc0203396:	00002517          	auipc	a0,0x2
ffffffffc020339a:	27a50513          	addi	a0,a0,634 # ffffffffc0205610 <default_pmm_manager+0x38>
ffffffffc020339e:	d43fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc02033a2:	85a2                	mv	a1,s0
ffffffffc02033a4:	00002517          	auipc	a0,0x2
ffffffffc02033a8:	29450513          	addi	a0,a0,660 # ffffffffc0205638 <default_pmm_manager+0x60>
ffffffffc02033ac:	d35fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc02033b0:	00002517          	auipc	a0,0x2
ffffffffc02033b4:	29850513          	addi	a0,a0,664 # ffffffffc0205648 <default_pmm_manager+0x70>
ffffffffc02033b8:	d29fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return 0;
}
ffffffffc02033bc:	70a2                	ld	ra,40(sp)
ffffffffc02033be:	7402                	ld	s0,32(sp)
ffffffffc02033c0:	64e2                	ld	s1,24(sp)
ffffffffc02033c2:	6942                	ld	s2,16(sp)
ffffffffc02033c4:	69a2                	ld	s3,8(sp)
ffffffffc02033c6:	4501                	li	a0,0
ffffffffc02033c8:	6145                	addi	sp,sp,48
ffffffffc02033ca:	8082                	ret

ffffffffc02033cc <proc_run>:
{
ffffffffc02033cc:	7179                	addi	sp,sp,-48
ffffffffc02033ce:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc02033d0:	0000a917          	auipc	s2,0xa
ffffffffc02033d4:	10090913          	addi	s2,s2,256 # ffffffffc020d4d0 <current>
{
ffffffffc02033d8:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc02033da:	00093483          	ld	s1,0(s2)
{
ffffffffc02033de:	f406                	sd	ra,40(sp)
ffffffffc02033e0:	e84e                	sd	s3,16(sp)
    if (proc != current)
ffffffffc02033e2:	02a48963          	beq	s1,a0,ffffffffc0203414 <proc_run+0x48>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033e6:	100027f3          	csrr	a5,sstatus
ffffffffc02033ea:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02033ec:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033ee:	e3a1                	bnez	a5,ffffffffc020342e <proc_run+0x62>
            lsatp(next->pgdir);// load base addr of "proc"'s new PDT
ffffffffc02033f0:	755c                	ld	a5,168(a0)
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned int pgdir)
{
  write_csr(satp, SATP32_MODE | (pgdir >> RISCV_PGSHIFT));
ffffffffc02033f2:	80000737          	lui	a4,0x80000
            current = proc;
ffffffffc02033f6:	00a93023          	sd	a0,0(s2)
ffffffffc02033fa:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc02033fe:	8fd9                	or	a5,a5,a4
ffffffffc0203400:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0203404:	03050593          	addi	a1,a0,48
ffffffffc0203408:	03048513          	addi	a0,s1,48
ffffffffc020340c:	e5bff0ef          	jal	ra,ffffffffc0203266 <switch_to>
    if (flag) {
ffffffffc0203410:	00099863          	bnez	s3,ffffffffc0203420 <proc_run+0x54>
}
ffffffffc0203414:	70a2                	ld	ra,40(sp)
ffffffffc0203416:	7482                	ld	s1,32(sp)
ffffffffc0203418:	6962                	ld	s2,24(sp)
ffffffffc020341a:	69c2                	ld	s3,16(sp)
ffffffffc020341c:	6145                	addi	sp,sp,48
ffffffffc020341e:	8082                	ret
ffffffffc0203420:	70a2                	ld	ra,40(sp)
ffffffffc0203422:	7482                	ld	s1,32(sp)
ffffffffc0203424:	6962                	ld	s2,24(sp)
ffffffffc0203426:	69c2                	ld	s3,16(sp)
ffffffffc0203428:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc020342a:	d06fd06f          	j	ffffffffc0200930 <intr_enable>
ffffffffc020342e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203430:	d06fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;
ffffffffc0203434:	6522                	ld	a0,8(sp)
ffffffffc0203436:	4985                	li	s3,1
ffffffffc0203438:	bf65                	j	ffffffffc02033f0 <proc_run+0x24>

ffffffffc020343a <do_fork>:
{
ffffffffc020343a:	7179                	addi	sp,sp,-48
ffffffffc020343c:	ec26                	sd	s1,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc020343e:	0000a497          	auipc	s1,0xa
ffffffffc0203442:	0aa48493          	addi	s1,s1,170 # ffffffffc020d4e8 <nr_process>
ffffffffc0203446:	4098                	lw	a4,0(s1)
{
ffffffffc0203448:	f406                	sd	ra,40(sp)
ffffffffc020344a:	f022                	sd	s0,32(sp)
ffffffffc020344c:	e84a                	sd	s2,16(sp)
ffffffffc020344e:	e44e                	sd	s3,8(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0203450:	6785                	lui	a5,0x1
ffffffffc0203452:	20f75963          	bge	a4,a5,ffffffffc0203664 <do_fork+0x22a>
ffffffffc0203456:	892e                	mv	s2,a1
ffffffffc0203458:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc020345a:	e77ff0ef          	jal	ra,ffffffffc02032d0 <alloc_proc>
ffffffffc020345e:	89aa                	mv	s3,a0
ffffffffc0203460:	20050763          	beqz	a0,ffffffffc020366e <do_fork+0x234>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203464:	4509                	li	a0,2
ffffffffc0203466:	a05fd0ef          	jal	ra,ffffffffc0200e6a <alloc_pages>
    if (page != NULL)
ffffffffc020346a:	1e050863          	beqz	a0,ffffffffc020365a <do_fork+0x220>
    return page - pages + nbase;
ffffffffc020346e:	0000a697          	auipc	a3,0xa
ffffffffc0203472:	0426b683          	ld	a3,66(a3) # ffffffffc020d4b0 <pages>
ffffffffc0203476:	40d506b3          	sub	a3,a0,a3
ffffffffc020347a:	8699                	srai	a3,a3,0x6
ffffffffc020347c:	00002517          	auipc	a0,0x2
ffffffffc0203480:	58c53503          	ld	a0,1420(a0) # ffffffffc0205a08 <nbase>
ffffffffc0203484:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0203486:	00c69793          	slli	a5,a3,0xc
ffffffffc020348a:	83b1                	srli	a5,a5,0xc
ffffffffc020348c:	0000a717          	auipc	a4,0xa
ffffffffc0203490:	01c73703          	ld	a4,28(a4) # ffffffffc020d4a8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0203494:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203496:	1ee7fe63          	bgeu	a5,a4,ffffffffc0203692 <do_fork+0x258>
    assert(current->mm == NULL);
ffffffffc020349a:	0000a797          	auipc	a5,0xa
ffffffffc020349e:	0367b783          	ld	a5,54(a5) # ffffffffc020d4d0 <current>
ffffffffc02034a2:	779c                	ld	a5,40(a5)
ffffffffc02034a4:	0000a717          	auipc	a4,0xa
ffffffffc02034a8:	01c73703          	ld	a4,28(a4) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc02034ac:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02034ae:	00d9b823          	sd	a3,16(s3)
    assert(current->mm == NULL);
ffffffffc02034b2:	1c079063          	bnez	a5,ffffffffc0203672 <do_fork+0x238>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02034b6:	6789                	lui	a5,0x2
ffffffffc02034b8:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc02034bc:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02034be:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02034c0:	0ad9b023          	sd	a3,160(s3)
    *(proc->tf) = *tf;
ffffffffc02034c4:	87b6                	mv	a5,a3
ffffffffc02034c6:	12040893          	addi	a7,s0,288
ffffffffc02034ca:	00063803          	ld	a6,0(a2)
ffffffffc02034ce:	6608                	ld	a0,8(a2)
ffffffffc02034d0:	6a0c                	ld	a1,16(a2)
ffffffffc02034d2:	6e18                	ld	a4,24(a2)
ffffffffc02034d4:	0107b023          	sd	a6,0(a5)
ffffffffc02034d8:	e788                	sd	a0,8(a5)
ffffffffc02034da:	eb8c                	sd	a1,16(a5)
ffffffffc02034dc:	ef98                	sd	a4,24(a5)
ffffffffc02034de:	02060613          	addi	a2,a2,32
ffffffffc02034e2:	02078793          	addi	a5,a5,32
ffffffffc02034e6:	ff1612e3          	bne	a2,a7,ffffffffc02034ca <do_fork+0x90>
    proc->tf->gpr.a0 = 0;
ffffffffc02034ea:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02034ee:	12090463          	beqz	s2,ffffffffc0203616 <do_fork+0x1dc>
ffffffffc02034f2:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02034f6:	00000797          	auipc	a5,0x0
ffffffffc02034fa:	e5678793          	addi	a5,a5,-426 # ffffffffc020334c <forkret>
ffffffffc02034fe:	02f9b823          	sd	a5,48(s3)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0203502:	02d9bc23          	sd	a3,56(s3)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203506:	100027f3          	csrr	a5,sstatus
ffffffffc020350a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020350c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020350e:	12079563          	bnez	a5,ffffffffc0203638 <do_fork+0x1fe>
    if (++last_pid >= MAX_PID)
ffffffffc0203512:	00006817          	auipc	a6,0x6
ffffffffc0203516:	b1680813          	addi	a6,a6,-1258 # ffffffffc0209028 <last_pid.1>
ffffffffc020351a:	00082783          	lw	a5,0(a6)
ffffffffc020351e:	6709                	lui	a4,0x2
ffffffffc0203520:	0017851b          	addiw	a0,a5,1
ffffffffc0203524:	00a82023          	sw	a0,0(a6)
ffffffffc0203528:	08e55063          	bge	a0,a4,ffffffffc02035a8 <do_fork+0x16e>
    if (last_pid >= next_safe)
ffffffffc020352c:	00006317          	auipc	t1,0x6
ffffffffc0203530:	b0030313          	addi	t1,t1,-1280 # ffffffffc020902c <next_safe.0>
ffffffffc0203534:	00032783          	lw	a5,0(t1)
ffffffffc0203538:	0000a417          	auipc	s0,0xa
ffffffffc020353c:	f2040413          	addi	s0,s0,-224 # ffffffffc020d458 <proc_list>
ffffffffc0203540:	06f55c63          	bge	a0,a5,ffffffffc02035b8 <do_fork+0x17e>
        proc->pid = get_pid();
ffffffffc0203544:	00a9a223          	sw	a0,4(s3)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203548:	45a9                	li	a1,10
ffffffffc020354a:	2501                	sext.w	a0,a0
ffffffffc020354c:	1d9000ef          	jal	ra,ffffffffc0203f24 <hash32>
ffffffffc0203550:	02051793          	slli	a5,a0,0x20
ffffffffc0203554:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0203558:	00006797          	auipc	a5,0x6
ffffffffc020355c:	ef078793          	addi	a5,a5,-272 # ffffffffc0209448 <hash_list>
ffffffffc0203560:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0203562:	6510                	ld	a2,8(a0)
ffffffffc0203564:	0d898793          	addi	a5,s3,216
ffffffffc0203568:	6414                	ld	a3,8(s0)
        nr_process++;
ffffffffc020356a:	4098                	lw	a4,0(s1)
    prev->next = next->prev = elm;
ffffffffc020356c:	e21c                	sd	a5,0(a2)
ffffffffc020356e:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0203570:	0ec9b023          	sd	a2,224(s3)
        list_add(&proc_list, &(proc->list_link));
ffffffffc0203574:	0c898793          	addi	a5,s3,200
    elm->prev = prev;
ffffffffc0203578:	0ca9bc23          	sd	a0,216(s3)
    prev->next = next->prev = elm;
ffffffffc020357c:	e29c                	sd	a5,0(a3)
        nr_process++;
ffffffffc020357e:	2705                	addiw	a4,a4,1
ffffffffc0203580:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0203582:	0cd9b823          	sd	a3,208(s3)
    elm->prev = prev;
ffffffffc0203586:	0c89b423          	sd	s0,200(s3)
ffffffffc020358a:	c098                	sw	a4,0(s1)
    if (flag) {
ffffffffc020358c:	0a091a63          	bnez	s2,ffffffffc0203640 <do_fork+0x206>
    wakeup_proc(proc);
ffffffffc0203590:	854e                	mv	a0,s3
ffffffffc0203592:	3ee000ef          	jal	ra,ffffffffc0203980 <wakeup_proc>
    ret = proc->pid;
ffffffffc0203596:	0049a503          	lw	a0,4(s3)
}
ffffffffc020359a:	70a2                	ld	ra,40(sp)
ffffffffc020359c:	7402                	ld	s0,32(sp)
ffffffffc020359e:	64e2                	ld	s1,24(sp)
ffffffffc02035a0:	6942                	ld	s2,16(sp)
ffffffffc02035a2:	69a2                	ld	s3,8(sp)
ffffffffc02035a4:	6145                	addi	sp,sp,48
ffffffffc02035a6:	8082                	ret
        last_pid = 1;
ffffffffc02035a8:	4785                	li	a5,1
ffffffffc02035aa:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02035ae:	4505                	li	a0,1
ffffffffc02035b0:	00006317          	auipc	t1,0x6
ffffffffc02035b4:	a7c30313          	addi	t1,t1,-1412 # ffffffffc020902c <next_safe.0>
    return listelm->next;
ffffffffc02035b8:	0000a417          	auipc	s0,0xa
ffffffffc02035bc:	ea040413          	addi	s0,s0,-352 # ffffffffc020d458 <proc_list>
ffffffffc02035c0:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc02035c4:	6789                	lui	a5,0x2
ffffffffc02035c6:	00f32023          	sw	a5,0(t1)
ffffffffc02035ca:	86aa                	mv	a3,a0
ffffffffc02035cc:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc02035ce:	6e89                	lui	t4,0x2
ffffffffc02035d0:	088e0063          	beq	t3,s0,ffffffffc0203650 <do_fork+0x216>
ffffffffc02035d4:	88ae                	mv	a7,a1
ffffffffc02035d6:	87f2                	mv	a5,t3
ffffffffc02035d8:	6609                	lui	a2,0x2
ffffffffc02035da:	a811                	j	ffffffffc02035ee <do_fork+0x1b4>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02035dc:	00e6d663          	bge	a3,a4,ffffffffc02035e8 <do_fork+0x1ae>
ffffffffc02035e0:	00c75463          	bge	a4,a2,ffffffffc02035e8 <do_fork+0x1ae>
ffffffffc02035e4:	863a                	mv	a2,a4
ffffffffc02035e6:	4885                	li	a7,1
ffffffffc02035e8:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02035ea:	00878d63          	beq	a5,s0,ffffffffc0203604 <do_fork+0x1ca>
            if (proc->pid == last_pid)
ffffffffc02035ee:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc02035f2:	fed715e3          	bne	a4,a3,ffffffffc02035dc <do_fork+0x1a2>
                if (++last_pid >= next_safe)
ffffffffc02035f6:	2685                	addiw	a3,a3,1
ffffffffc02035f8:	04c6d763          	bge	a3,a2,ffffffffc0203646 <do_fork+0x20c>
ffffffffc02035fc:	679c                	ld	a5,8(a5)
ffffffffc02035fe:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0203600:	fe8797e3          	bne	a5,s0,ffffffffc02035ee <do_fork+0x1b4>
ffffffffc0203604:	c581                	beqz	a1,ffffffffc020360c <do_fork+0x1d2>
ffffffffc0203606:	00d82023          	sw	a3,0(a6)
ffffffffc020360a:	8536                	mv	a0,a3
ffffffffc020360c:	f2088ce3          	beqz	a7,ffffffffc0203544 <do_fork+0x10a>
ffffffffc0203610:	00c32023          	sw	a2,0(t1)
ffffffffc0203614:	bf05                	j	ffffffffc0203544 <do_fork+0x10a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203616:	8936                	mv	s2,a3
ffffffffc0203618:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020361c:	00000797          	auipc	a5,0x0
ffffffffc0203620:	d3078793          	addi	a5,a5,-720 # ffffffffc020334c <forkret>
ffffffffc0203624:	02f9b823          	sd	a5,48(s3)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0203628:	02d9bc23          	sd	a3,56(s3)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020362c:	100027f3          	csrr	a5,sstatus
ffffffffc0203630:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203632:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203634:	ec078fe3          	beqz	a5,ffffffffc0203512 <do_fork+0xd8>
        intr_disable();
ffffffffc0203638:	afefd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;
ffffffffc020363c:	4905                	li	s2,1
ffffffffc020363e:	bdd1                	j	ffffffffc0203512 <do_fork+0xd8>
        intr_enable();
ffffffffc0203640:	af0fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0203644:	b7b1                	j	ffffffffc0203590 <do_fork+0x156>
                    if (last_pid >= MAX_PID)
ffffffffc0203646:	01d6c363          	blt	a3,t4,ffffffffc020364c <do_fork+0x212>
                        last_pid = 1;
ffffffffc020364a:	4685                	li	a3,1
                    goto repeat;
ffffffffc020364c:	4585                	li	a1,1
ffffffffc020364e:	b749                	j	ffffffffc02035d0 <do_fork+0x196>
ffffffffc0203650:	cd81                	beqz	a1,ffffffffc0203668 <do_fork+0x22e>
ffffffffc0203652:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0203656:	8536                	mv	a0,a3
ffffffffc0203658:	b5f5                	j	ffffffffc0203544 <do_fork+0x10a>
    kfree(proc);
ffffffffc020365a:	854e                	mv	a0,s3
ffffffffc020365c:	85aff0ef          	jal	ra,ffffffffc02026b6 <kfree>
    ret = -E_NO_MEM;
ffffffffc0203660:	5571                	li	a0,-4
    goto fork_out;
ffffffffc0203662:	bf25                	j	ffffffffc020359a <do_fork+0x160>
    int ret = -E_NO_FREE_PROC;
ffffffffc0203664:	556d                	li	a0,-5
ffffffffc0203666:	bf15                	j	ffffffffc020359a <do_fork+0x160>
    return last_pid;
ffffffffc0203668:	00082503          	lw	a0,0(a6)
ffffffffc020366c:	bde1                	j	ffffffffc0203544 <do_fork+0x10a>
    ret = -E_NO_MEM;
ffffffffc020366e:	5571                	li	a0,-4
    return ret;
ffffffffc0203670:	b72d                	j	ffffffffc020359a <do_fork+0x160>
    assert(current->mm == NULL);
ffffffffc0203672:	00002697          	auipc	a3,0x2
ffffffffc0203676:	ff668693          	addi	a3,a3,-10 # ffffffffc0205668 <default_pmm_manager+0x90>
ffffffffc020367a:	00001617          	auipc	a2,0x1
ffffffffc020367e:	43e60613          	addi	a2,a2,1086 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0203682:	12100593          	li	a1,289
ffffffffc0203686:	00002517          	auipc	a0,0x2
ffffffffc020368a:	ffa50513          	addi	a0,a0,-6 # ffffffffc0205680 <default_pmm_manager+0xa8>
ffffffffc020368e:	b51fc0ef          	jal	ra,ffffffffc02001de <__panic>
ffffffffc0203692:	00001617          	auipc	a2,0x1
ffffffffc0203696:	2f660613          	addi	a2,a2,758 # ffffffffc0204988 <commands+0x7c0>
ffffffffc020369a:	07100593          	li	a1,113
ffffffffc020369e:	00001517          	auipc	a0,0x1
ffffffffc02036a2:	2b250513          	addi	a0,a0,690 # ffffffffc0204950 <commands+0x788>
ffffffffc02036a6:	b39fc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02036aa <kernel_thread>:
{
ffffffffc02036aa:	7129                	addi	sp,sp,-320
ffffffffc02036ac:	fa22                	sd	s0,304(sp)
ffffffffc02036ae:	f626                	sd	s1,296(sp)
ffffffffc02036b0:	f24a                	sd	s2,288(sp)
ffffffffc02036b2:	84ae                	mv	s1,a1
ffffffffc02036b4:	892a                	mv	s2,a0
ffffffffc02036b6:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02036b8:	4581                	li	a1,0
ffffffffc02036ba:	12000613          	li	a2,288
ffffffffc02036be:	850a                	mv	a0,sp
{
ffffffffc02036c0:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02036c2:	426000ef          	jal	ra,ffffffffc0203ae8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02036c6:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02036c8:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02036ca:	100027f3          	csrr	a5,sstatus
ffffffffc02036ce:	edd7f793          	andi	a5,a5,-291
ffffffffc02036d2:	1207e793          	ori	a5,a5,288
ffffffffc02036d6:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02036d8:	860a                	mv	a2,sp
ffffffffc02036da:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02036de:	00000797          	auipc	a5,0x0
ffffffffc02036e2:	b8078793          	addi	a5,a5,-1152 # ffffffffc020325e <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02036e6:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02036e8:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02036ea:	d51ff0ef          	jal	ra,ffffffffc020343a <do_fork>
}
ffffffffc02036ee:	70f2                	ld	ra,312(sp)
ffffffffc02036f0:	7452                	ld	s0,304(sp)
ffffffffc02036f2:	74b2                	ld	s1,296(sp)
ffffffffc02036f4:	7912                	ld	s2,288(sp)
ffffffffc02036f6:	6131                	addi	sp,sp,320
ffffffffc02036f8:	8082                	ret

ffffffffc02036fa <do_exit>:
{
ffffffffc02036fa:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc02036fc:	00002617          	auipc	a2,0x2
ffffffffc0203700:	f9c60613          	addi	a2,a2,-100 # ffffffffc0205698 <default_pmm_manager+0xc0>
ffffffffc0203704:	19100593          	li	a1,401
ffffffffc0203708:	00002517          	auipc	a0,0x2
ffffffffc020370c:	f7850513          	addi	a0,a0,-136 # ffffffffc0205680 <default_pmm_manager+0xa8>
{
ffffffffc0203710:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0203712:	acdfc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0203716 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0203716:	7179                	addi	sp,sp,-48
ffffffffc0203718:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc020371a:	0000a797          	auipc	a5,0xa
ffffffffc020371e:	d3e78793          	addi	a5,a5,-706 # ffffffffc020d458 <proc_list>
ffffffffc0203722:	f406                	sd	ra,40(sp)
ffffffffc0203724:	f022                	sd	s0,32(sp)
ffffffffc0203726:	e84a                	sd	s2,16(sp)
ffffffffc0203728:	e44e                	sd	s3,8(sp)
ffffffffc020372a:	00006497          	auipc	s1,0x6
ffffffffc020372e:	d1e48493          	addi	s1,s1,-738 # ffffffffc0209448 <hash_list>
ffffffffc0203732:	e79c                	sd	a5,8(a5)
ffffffffc0203734:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0203736:	0000a717          	auipc	a4,0xa
ffffffffc020373a:	d1270713          	addi	a4,a4,-750 # ffffffffc020d448 <name.2>
ffffffffc020373e:	87a6                	mv	a5,s1
ffffffffc0203740:	e79c                	sd	a5,8(a5)
ffffffffc0203742:	e39c                	sd	a5,0(a5)
ffffffffc0203744:	07c1                	addi	a5,a5,16
ffffffffc0203746:	fef71de3          	bne	a4,a5,ffffffffc0203740 <proc_init+0x2a>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc020374a:	b87ff0ef          	jal	ra,ffffffffc02032d0 <alloc_proc>
ffffffffc020374e:	0000a917          	auipc	s2,0xa
ffffffffc0203752:	d8a90913          	addi	s2,s2,-630 # ffffffffc020d4d8 <idleproc>
ffffffffc0203756:	00a93023          	sd	a0,0(s2)
ffffffffc020375a:	18050d63          	beqz	a0,ffffffffc02038f4 <proc_init+0x1de>
    {
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc020375e:	07000513          	li	a0,112
ffffffffc0203762:	ea5fe0ef          	jal	ra,ffffffffc0202606 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0203766:	07000613          	li	a2,112
ffffffffc020376a:	4581                	li	a1,0
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc020376c:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020376e:	37a000ef          	jal	ra,ffffffffc0203ae8 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc0203772:	00093503          	ld	a0,0(s2)
ffffffffc0203776:	85a2                	mv	a1,s0
ffffffffc0203778:	07000613          	li	a2,112
ffffffffc020377c:	03050513          	addi	a0,a0,48
ffffffffc0203780:	392000ef          	jal	ra,ffffffffc0203b12 <memcmp>
ffffffffc0203784:	89aa                	mv	s3,a0

    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc0203786:	453d                	li	a0,15
ffffffffc0203788:	e7ffe0ef          	jal	ra,ffffffffc0202606 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020378c:	463d                	li	a2,15
ffffffffc020378e:	4581                	li	a1,0
    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc0203790:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0203792:	356000ef          	jal	ra,ffffffffc0203ae8 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc0203796:	00093503          	ld	a0,0(s2)
ffffffffc020379a:	463d                	li	a2,15
ffffffffc020379c:	85a2                	mv	a1,s0
ffffffffc020379e:	0b450513          	addi	a0,a0,180
ffffffffc02037a2:	370000ef          	jal	ra,ffffffffc0203b12 <memcmp>

    if (idleproc->pgdir == boot_pgdir_pa && idleproc->tf == NULL && !context_init_flag && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0 && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag)
ffffffffc02037a6:	00093783          	ld	a5,0(s2)
ffffffffc02037aa:	0000a717          	auipc	a4,0xa
ffffffffc02037ae:	cee73703          	ld	a4,-786(a4) # ffffffffc020d498 <boot_pgdir_pa>
ffffffffc02037b2:	77d4                	ld	a3,168(a5)
ffffffffc02037b4:	0ee68463          	beq	a3,a4,ffffffffc020389c <proc_init+0x186>
    {
        cprintf("alloc_proc() correct!\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02037b8:	4709                	li	a4,2
ffffffffc02037ba:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02037bc:	00003717          	auipc	a4,0x3
ffffffffc02037c0:	84470713          	addi	a4,a4,-1980 # ffffffffc0206000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02037c4:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02037c8:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc02037ca:	4705                	li	a4,1
ffffffffc02037cc:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02037ce:	4641                	li	a2,16
ffffffffc02037d0:	4581                	li	a1,0
ffffffffc02037d2:	8522                	mv	a0,s0
ffffffffc02037d4:	314000ef          	jal	ra,ffffffffc0203ae8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02037d8:	463d                	li	a2,15
ffffffffc02037da:	00002597          	auipc	a1,0x2
ffffffffc02037de:	f0658593          	addi	a1,a1,-250 # ffffffffc02056e0 <default_pmm_manager+0x108>
ffffffffc02037e2:	8522                	mv	a0,s0
ffffffffc02037e4:	316000ef          	jal	ra,ffffffffc0203afa <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc02037e8:	0000a717          	auipc	a4,0xa
ffffffffc02037ec:	d0070713          	addi	a4,a4,-768 # ffffffffc020d4e8 <nr_process>
ffffffffc02037f0:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc02037f2:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02037f6:	4601                	li	a2,0
    nr_process++;
ffffffffc02037f8:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02037fa:	00002597          	auipc	a1,0x2
ffffffffc02037fe:	eee58593          	addi	a1,a1,-274 # ffffffffc02056e8 <default_pmm_manager+0x110>
ffffffffc0203802:	00000517          	auipc	a0,0x0
ffffffffc0203806:	b5850513          	addi	a0,a0,-1192 # ffffffffc020335a <init_main>
    nr_process++;
ffffffffc020380a:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc020380c:	0000a797          	auipc	a5,0xa
ffffffffc0203810:	ccd7b223          	sd	a3,-828(a5) # ffffffffc020d4d0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0203814:	e97ff0ef          	jal	ra,ffffffffc02036aa <kernel_thread>
ffffffffc0203818:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc020381a:	0ea05963          	blez	a0,ffffffffc020390c <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID)
ffffffffc020381e:	6789                	lui	a5,0x2
ffffffffc0203820:	fff5071b          	addiw	a4,a0,-1
ffffffffc0203824:	17f9                	addi	a5,a5,-2
ffffffffc0203826:	2501                	sext.w	a0,a0
ffffffffc0203828:	02e7e363          	bltu	a5,a4,ffffffffc020384e <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020382c:	45a9                	li	a1,10
ffffffffc020382e:	6f6000ef          	jal	ra,ffffffffc0203f24 <hash32>
ffffffffc0203832:	02051793          	slli	a5,a0,0x20
ffffffffc0203836:	01c7d693          	srli	a3,a5,0x1c
ffffffffc020383a:	96a6                	add	a3,a3,s1
ffffffffc020383c:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc020383e:	a029                	j	ffffffffc0203848 <proc_init+0x132>
            if (proc->pid == pid)
ffffffffc0203840:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc0203844:	0a870563          	beq	a4,s0,ffffffffc02038ee <proc_init+0x1d8>
    return listelm->next;
ffffffffc0203848:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020384a:	fef69be3          	bne	a3,a5,ffffffffc0203840 <proc_init+0x12a>
    return NULL;
ffffffffc020384e:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203850:	0b478493          	addi	s1,a5,180
ffffffffc0203854:	4641                	li	a2,16
ffffffffc0203856:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0203858:	0000a417          	auipc	s0,0xa
ffffffffc020385c:	c8840413          	addi	s0,s0,-888 # ffffffffc020d4e0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203860:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0203862:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203864:	284000ef          	jal	ra,ffffffffc0203ae8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0203868:	463d                	li	a2,15
ffffffffc020386a:	00002597          	auipc	a1,0x2
ffffffffc020386e:	eae58593          	addi	a1,a1,-338 # ffffffffc0205718 <default_pmm_manager+0x140>
ffffffffc0203872:	8526                	mv	a0,s1
ffffffffc0203874:	286000ef          	jal	ra,ffffffffc0203afa <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0203878:	00093783          	ld	a5,0(s2)
ffffffffc020387c:	c7e1                	beqz	a5,ffffffffc0203944 <proc_init+0x22e>
ffffffffc020387e:	43dc                	lw	a5,4(a5)
ffffffffc0203880:	e3f1                	bnez	a5,ffffffffc0203944 <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0203882:	601c                	ld	a5,0(s0)
ffffffffc0203884:	c3c5                	beqz	a5,ffffffffc0203924 <proc_init+0x20e>
ffffffffc0203886:	43d8                	lw	a4,4(a5)
ffffffffc0203888:	4785                	li	a5,1
ffffffffc020388a:	08f71d63          	bne	a4,a5,ffffffffc0203924 <proc_init+0x20e>
}
ffffffffc020388e:	70a2                	ld	ra,40(sp)
ffffffffc0203890:	7402                	ld	s0,32(sp)
ffffffffc0203892:	64e2                	ld	s1,24(sp)
ffffffffc0203894:	6942                	ld	s2,16(sp)
ffffffffc0203896:	69a2                	ld	s3,8(sp)
ffffffffc0203898:	6145                	addi	sp,sp,48
ffffffffc020389a:	8082                	ret
    if (idleproc->pgdir == boot_pgdir_pa && idleproc->tf == NULL && !context_init_flag && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0 && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag)
ffffffffc020389c:	73d8                	ld	a4,160(a5)
ffffffffc020389e:	ff09                	bnez	a4,ffffffffc02037b8 <proc_init+0xa2>
ffffffffc02038a0:	f0099ce3          	bnez	s3,ffffffffc02037b8 <proc_init+0xa2>
ffffffffc02038a4:	6394                	ld	a3,0(a5)
ffffffffc02038a6:	577d                	li	a4,-1
ffffffffc02038a8:	1702                	slli	a4,a4,0x20
ffffffffc02038aa:	f0e697e3          	bne	a3,a4,ffffffffc02037b8 <proc_init+0xa2>
ffffffffc02038ae:	4798                	lw	a4,8(a5)
ffffffffc02038b0:	f00714e3          	bnez	a4,ffffffffc02037b8 <proc_init+0xa2>
ffffffffc02038b4:	6b98                	ld	a4,16(a5)
ffffffffc02038b6:	f00711e3          	bnez	a4,ffffffffc02037b8 <proc_init+0xa2>
ffffffffc02038ba:	4f98                	lw	a4,24(a5)
ffffffffc02038bc:	2701                	sext.w	a4,a4
ffffffffc02038be:	ee071de3          	bnez	a4,ffffffffc02037b8 <proc_init+0xa2>
ffffffffc02038c2:	7398                	ld	a4,32(a5)
ffffffffc02038c4:	ee071ae3          	bnez	a4,ffffffffc02037b8 <proc_init+0xa2>
ffffffffc02038c8:	7798                	ld	a4,40(a5)
ffffffffc02038ca:	ee0717e3          	bnez	a4,ffffffffc02037b8 <proc_init+0xa2>
ffffffffc02038ce:	0b07a703          	lw	a4,176(a5)
ffffffffc02038d2:	8d59                	or	a0,a0,a4
ffffffffc02038d4:	0005071b          	sext.w	a4,a0
ffffffffc02038d8:	ee0710e3          	bnez	a4,ffffffffc02037b8 <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc02038dc:	00002517          	auipc	a0,0x2
ffffffffc02038e0:	dec50513          	addi	a0,a0,-532 # ffffffffc02056c8 <default_pmm_manager+0xf0>
ffffffffc02038e4:	ffcfc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    idleproc->pid = 0;
ffffffffc02038e8:	00093783          	ld	a5,0(s2)
ffffffffc02038ec:	b5f1                	j	ffffffffc02037b8 <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02038ee:	f2878793          	addi	a5,a5,-216
ffffffffc02038f2:	bfb9                	j	ffffffffc0203850 <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc02038f4:	00002617          	auipc	a2,0x2
ffffffffc02038f8:	dbc60613          	addi	a2,a2,-580 # ffffffffc02056b0 <default_pmm_manager+0xd8>
ffffffffc02038fc:	1ac00593          	li	a1,428
ffffffffc0203900:	00002517          	auipc	a0,0x2
ffffffffc0203904:	d8050513          	addi	a0,a0,-640 # ffffffffc0205680 <default_pmm_manager+0xa8>
ffffffffc0203908:	8d7fc0ef          	jal	ra,ffffffffc02001de <__panic>
        panic("create init_main failed.\n");
ffffffffc020390c:	00002617          	auipc	a2,0x2
ffffffffc0203910:	dec60613          	addi	a2,a2,-532 # ffffffffc02056f8 <default_pmm_manager+0x120>
ffffffffc0203914:	1c900593          	li	a1,457
ffffffffc0203918:	00002517          	auipc	a0,0x2
ffffffffc020391c:	d6850513          	addi	a0,a0,-664 # ffffffffc0205680 <default_pmm_manager+0xa8>
ffffffffc0203920:	8bffc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0203924:	00002697          	auipc	a3,0x2
ffffffffc0203928:	e2468693          	addi	a3,a3,-476 # ffffffffc0205748 <default_pmm_manager+0x170>
ffffffffc020392c:	00001617          	auipc	a2,0x1
ffffffffc0203930:	18c60613          	addi	a2,a2,396 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0203934:	1d000593          	li	a1,464
ffffffffc0203938:	00002517          	auipc	a0,0x2
ffffffffc020393c:	d4850513          	addi	a0,a0,-696 # ffffffffc0205680 <default_pmm_manager+0xa8>
ffffffffc0203940:	89ffc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0203944:	00002697          	auipc	a3,0x2
ffffffffc0203948:	ddc68693          	addi	a3,a3,-548 # ffffffffc0205720 <default_pmm_manager+0x148>
ffffffffc020394c:	00001617          	auipc	a2,0x1
ffffffffc0203950:	16c60613          	addi	a2,a2,364 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc0203954:	1cf00593          	li	a1,463
ffffffffc0203958:	00002517          	auipc	a0,0x2
ffffffffc020395c:	d2850513          	addi	a0,a0,-728 # ffffffffc0205680 <default_pmm_manager+0xa8>
ffffffffc0203960:	87ffc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0203964 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0203964:	1141                	addi	sp,sp,-16
ffffffffc0203966:	e022                	sd	s0,0(sp)
ffffffffc0203968:	e406                	sd	ra,8(sp)
ffffffffc020396a:	0000a417          	auipc	s0,0xa
ffffffffc020396e:	b6640413          	addi	s0,s0,-1178 # ffffffffc020d4d0 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0203972:	6018                	ld	a4,0(s0)
ffffffffc0203974:	4f1c                	lw	a5,24(a4)
ffffffffc0203976:	2781                	sext.w	a5,a5
ffffffffc0203978:	dff5                	beqz	a5,ffffffffc0203974 <cpu_idle+0x10>
        {
            schedule();
ffffffffc020397a:	038000ef          	jal	ra,ffffffffc02039b2 <schedule>
ffffffffc020397e:	bfd5                	j	ffffffffc0203972 <cpu_idle+0xe>

ffffffffc0203980 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0203980:	411c                	lw	a5,0(a0)
ffffffffc0203982:	4705                	li	a4,1
ffffffffc0203984:	37f9                	addiw	a5,a5,-2
ffffffffc0203986:	00f77563          	bgeu	a4,a5,ffffffffc0203990 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc020398a:	4789                	li	a5,2
ffffffffc020398c:	c11c                	sw	a5,0(a0)
ffffffffc020398e:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0203990:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0203992:	00002697          	auipc	a3,0x2
ffffffffc0203996:	dde68693          	addi	a3,a3,-546 # ffffffffc0205770 <default_pmm_manager+0x198>
ffffffffc020399a:	00001617          	auipc	a2,0x1
ffffffffc020399e:	11e60613          	addi	a2,a2,286 # ffffffffc0204ab8 <commands+0x8f0>
ffffffffc02039a2:	45a5                	li	a1,9
ffffffffc02039a4:	00002517          	auipc	a0,0x2
ffffffffc02039a8:	e0c50513          	addi	a0,a0,-500 # ffffffffc02057b0 <default_pmm_manager+0x1d8>
wakeup_proc(struct proc_struct *proc) {
ffffffffc02039ac:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02039ae:	831fc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02039b2 <schedule>:
}

void
schedule(void) {
ffffffffc02039b2:	1141                	addi	sp,sp,-16
ffffffffc02039b4:	e406                	sd	ra,8(sp)
ffffffffc02039b6:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02039b8:	100027f3          	csrr	a5,sstatus
ffffffffc02039bc:	8b89                	andi	a5,a5,2
ffffffffc02039be:	4401                	li	s0,0
ffffffffc02039c0:	efbd                	bnez	a5,ffffffffc0203a3e <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02039c2:	0000a897          	auipc	a7,0xa
ffffffffc02039c6:	b0e8b883          	ld	a7,-1266(a7) # ffffffffc020d4d0 <current>
ffffffffc02039ca:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02039ce:	0000a517          	auipc	a0,0xa
ffffffffc02039d2:	b0a53503          	ld	a0,-1270(a0) # ffffffffc020d4d8 <idleproc>
ffffffffc02039d6:	04a88e63          	beq	a7,a0,ffffffffc0203a32 <schedule+0x80>
ffffffffc02039da:	0c888693          	addi	a3,a7,200
ffffffffc02039de:	0000a617          	auipc	a2,0xa
ffffffffc02039e2:	a7a60613          	addi	a2,a2,-1414 # ffffffffc020d458 <proc_list>
        le = last;
ffffffffc02039e6:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02039e8:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02039ea:	4809                	li	a6,2
ffffffffc02039ec:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02039ee:	00c78863          	beq	a5,a2,ffffffffc02039fe <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02039f2:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02039f6:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02039fa:	03070163          	beq	a4,a6,ffffffffc0203a1c <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc02039fe:	fef697e3          	bne	a3,a5,ffffffffc02039ec <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0203a02:	ed89                	bnez	a1,ffffffffc0203a1c <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0203a04:	451c                	lw	a5,8(a0)
ffffffffc0203a06:	2785                	addiw	a5,a5,1
ffffffffc0203a08:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0203a0a:	00a88463          	beq	a7,a0,ffffffffc0203a12 <schedule+0x60>
            proc_run(next);
ffffffffc0203a0e:	9bfff0ef          	jal	ra,ffffffffc02033cc <proc_run>
    if (flag) {
ffffffffc0203a12:	e819                	bnez	s0,ffffffffc0203a28 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0203a14:	60a2                	ld	ra,8(sp)
ffffffffc0203a16:	6402                	ld	s0,0(sp)
ffffffffc0203a18:	0141                	addi	sp,sp,16
ffffffffc0203a1a:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0203a1c:	4198                	lw	a4,0(a1)
ffffffffc0203a1e:	4789                	li	a5,2
ffffffffc0203a20:	fef712e3          	bne	a4,a5,ffffffffc0203a04 <schedule+0x52>
ffffffffc0203a24:	852e                	mv	a0,a1
ffffffffc0203a26:	bff9                	j	ffffffffc0203a04 <schedule+0x52>
}
ffffffffc0203a28:	6402                	ld	s0,0(sp)
ffffffffc0203a2a:	60a2                	ld	ra,8(sp)
ffffffffc0203a2c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0203a2e:	f03fc06f          	j	ffffffffc0200930 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0203a32:	0000a617          	auipc	a2,0xa
ffffffffc0203a36:	a2660613          	addi	a2,a2,-1498 # ffffffffc020d458 <proc_list>
ffffffffc0203a3a:	86b2                	mv	a3,a2
ffffffffc0203a3c:	b76d                	j	ffffffffc02039e6 <schedule+0x34>
        intr_disable();
ffffffffc0203a3e:	ef9fc0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;
ffffffffc0203a42:	4405                	li	s0,1
ffffffffc0203a44:	bfbd                	j	ffffffffc02039c2 <schedule+0x10>

ffffffffc0203a46 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203a46:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203a4a:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203a4c:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203a4e:	cb81                	beqz	a5,ffffffffc0203a5e <strlen+0x18>
        cnt ++;
ffffffffc0203a50:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203a52:	00a707b3          	add	a5,a4,a0
ffffffffc0203a56:	0007c783          	lbu	a5,0(a5)
ffffffffc0203a5a:	fbfd                	bnez	a5,ffffffffc0203a50 <strlen+0xa>
ffffffffc0203a5c:	8082                	ret
    }
    return cnt;
}
ffffffffc0203a5e:	8082                	ret

ffffffffc0203a60 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203a60:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203a62:	e589                	bnez	a1,ffffffffc0203a6c <strnlen+0xc>
ffffffffc0203a64:	a811                	j	ffffffffc0203a78 <strnlen+0x18>
        cnt ++;
ffffffffc0203a66:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203a68:	00f58863          	beq	a1,a5,ffffffffc0203a78 <strnlen+0x18>
ffffffffc0203a6c:	00f50733          	add	a4,a0,a5
ffffffffc0203a70:	00074703          	lbu	a4,0(a4)
ffffffffc0203a74:	fb6d                	bnez	a4,ffffffffc0203a66 <strnlen+0x6>
ffffffffc0203a76:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203a78:	852e                	mv	a0,a1
ffffffffc0203a7a:	8082                	ret

ffffffffc0203a7c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203a7c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203a7e:	0005c703          	lbu	a4,0(a1)
ffffffffc0203a82:	0785                	addi	a5,a5,1
ffffffffc0203a84:	0585                	addi	a1,a1,1
ffffffffc0203a86:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203a8a:	fb75                	bnez	a4,ffffffffc0203a7e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203a8c:	8082                	ret

ffffffffc0203a8e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203a8e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203a92:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203a96:	cb89                	beqz	a5,ffffffffc0203aa8 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203a98:	0505                	addi	a0,a0,1
ffffffffc0203a9a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203a9c:	fee789e3          	beq	a5,a4,ffffffffc0203a8e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203aa0:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203aa4:	9d19                	subw	a0,a0,a4
ffffffffc0203aa6:	8082                	ret
ffffffffc0203aa8:	4501                	li	a0,0
ffffffffc0203aaa:	bfed                	j	ffffffffc0203aa4 <strcmp+0x16>

ffffffffc0203aac <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203aac:	c20d                	beqz	a2,ffffffffc0203ace <strncmp+0x22>
ffffffffc0203aae:	962e                	add	a2,a2,a1
ffffffffc0203ab0:	a031                	j	ffffffffc0203abc <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0203ab2:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203ab4:	00e79a63          	bne	a5,a4,ffffffffc0203ac8 <strncmp+0x1c>
ffffffffc0203ab8:	00b60b63          	beq	a2,a1,ffffffffc0203ace <strncmp+0x22>
ffffffffc0203abc:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0203ac0:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203ac2:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203ac6:	f7f5                	bnez	a5,ffffffffc0203ab2 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203ac8:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0203acc:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203ace:	4501                	li	a0,0
ffffffffc0203ad0:	8082                	ret

ffffffffc0203ad2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203ad2:	00054783          	lbu	a5,0(a0)
ffffffffc0203ad6:	c799                	beqz	a5,ffffffffc0203ae4 <strchr+0x12>
        if (*s == c) {
ffffffffc0203ad8:	00f58763          	beq	a1,a5,ffffffffc0203ae6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203adc:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203ae0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203ae2:	fbfd                	bnez	a5,ffffffffc0203ad8 <strchr+0x6>
    }
    return NULL;
ffffffffc0203ae4:	4501                	li	a0,0
}
ffffffffc0203ae6:	8082                	ret

ffffffffc0203ae8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203ae8:	ca01                	beqz	a2,ffffffffc0203af8 <memset+0x10>
ffffffffc0203aea:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203aec:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203aee:	0785                	addi	a5,a5,1
ffffffffc0203af0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203af4:	fec79de3          	bne	a5,a2,ffffffffc0203aee <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203af8:	8082                	ret

ffffffffc0203afa <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203afa:	ca19                	beqz	a2,ffffffffc0203b10 <memcpy+0x16>
ffffffffc0203afc:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203afe:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203b00:	0005c703          	lbu	a4,0(a1)
ffffffffc0203b04:	0585                	addi	a1,a1,1
ffffffffc0203b06:	0785                	addi	a5,a5,1
ffffffffc0203b08:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203b0c:	fec59ae3          	bne	a1,a2,ffffffffc0203b00 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203b10:	8082                	ret

ffffffffc0203b12 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0203b12:	c205                	beqz	a2,ffffffffc0203b32 <memcmp+0x20>
ffffffffc0203b14:	962e                	add	a2,a2,a1
ffffffffc0203b16:	a019                	j	ffffffffc0203b1c <memcmp+0xa>
ffffffffc0203b18:	00c58d63          	beq	a1,a2,ffffffffc0203b32 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0203b1c:	00054783          	lbu	a5,0(a0)
ffffffffc0203b20:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0203b24:	0505                	addi	a0,a0,1
ffffffffc0203b26:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0203b28:	fee788e3          	beq	a5,a4,ffffffffc0203b18 <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203b2c:	40e7853b          	subw	a0,a5,a4
ffffffffc0203b30:	8082                	ret
    }
    return 0;
ffffffffc0203b32:	4501                	li	a0,0
}
ffffffffc0203b34:	8082                	ret

ffffffffc0203b36 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203b36:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b3a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203b3c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b40:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203b42:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b46:	f022                	sd	s0,32(sp)
ffffffffc0203b48:	ec26                	sd	s1,24(sp)
ffffffffc0203b4a:	e84a                	sd	s2,16(sp)
ffffffffc0203b4c:	f406                	sd	ra,40(sp)
ffffffffc0203b4e:	e44e                	sd	s3,8(sp)
ffffffffc0203b50:	84aa                	mv	s1,a0
ffffffffc0203b52:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203b54:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203b58:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203b5a:	03067e63          	bgeu	a2,a6,ffffffffc0203b96 <printnum+0x60>
ffffffffc0203b5e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203b60:	00805763          	blez	s0,ffffffffc0203b6e <printnum+0x38>
ffffffffc0203b64:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203b66:	85ca                	mv	a1,s2
ffffffffc0203b68:	854e                	mv	a0,s3
ffffffffc0203b6a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203b6c:	fc65                	bnez	s0,ffffffffc0203b64 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b6e:	1a02                	slli	s4,s4,0x20
ffffffffc0203b70:	00002797          	auipc	a5,0x2
ffffffffc0203b74:	c5878793          	addi	a5,a5,-936 # ffffffffc02057c8 <default_pmm_manager+0x1f0>
ffffffffc0203b78:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203b7c:	9a3e                	add	s4,s4,a5
}
ffffffffc0203b7e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b80:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203b84:	70a2                	ld	ra,40(sp)
ffffffffc0203b86:	69a2                	ld	s3,8(sp)
ffffffffc0203b88:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b8a:	85ca                	mv	a1,s2
ffffffffc0203b8c:	87a6                	mv	a5,s1
}
ffffffffc0203b8e:	6942                	ld	s2,16(sp)
ffffffffc0203b90:	64e2                	ld	s1,24(sp)
ffffffffc0203b92:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b94:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203b96:	03065633          	divu	a2,a2,a6
ffffffffc0203b9a:	8722                	mv	a4,s0
ffffffffc0203b9c:	f9bff0ef          	jal	ra,ffffffffc0203b36 <printnum>
ffffffffc0203ba0:	b7f9                	j	ffffffffc0203b6e <printnum+0x38>

ffffffffc0203ba2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203ba2:	7119                	addi	sp,sp,-128
ffffffffc0203ba4:	f4a6                	sd	s1,104(sp)
ffffffffc0203ba6:	f0ca                	sd	s2,96(sp)
ffffffffc0203ba8:	ecce                	sd	s3,88(sp)
ffffffffc0203baa:	e8d2                	sd	s4,80(sp)
ffffffffc0203bac:	e4d6                	sd	s5,72(sp)
ffffffffc0203bae:	e0da                	sd	s6,64(sp)
ffffffffc0203bb0:	fc5e                	sd	s7,56(sp)
ffffffffc0203bb2:	f06a                	sd	s10,32(sp)
ffffffffc0203bb4:	fc86                	sd	ra,120(sp)
ffffffffc0203bb6:	f8a2                	sd	s0,112(sp)
ffffffffc0203bb8:	f862                	sd	s8,48(sp)
ffffffffc0203bba:	f466                	sd	s9,40(sp)
ffffffffc0203bbc:	ec6e                	sd	s11,24(sp)
ffffffffc0203bbe:	892a                	mv	s2,a0
ffffffffc0203bc0:	84ae                	mv	s1,a1
ffffffffc0203bc2:	8d32                	mv	s10,a2
ffffffffc0203bc4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bc6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203bca:	5b7d                	li	s6,-1
ffffffffc0203bcc:	00002a97          	auipc	s5,0x2
ffffffffc0203bd0:	c28a8a93          	addi	s5,s5,-984 # ffffffffc02057f4 <default_pmm_manager+0x21c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203bd4:	00002b97          	auipc	s7,0x2
ffffffffc0203bd8:	dfcb8b93          	addi	s7,s7,-516 # ffffffffc02059d0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bdc:	000d4503          	lbu	a0,0(s10)
ffffffffc0203be0:	001d0413          	addi	s0,s10,1
ffffffffc0203be4:	01350a63          	beq	a0,s3,ffffffffc0203bf8 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203be8:	c121                	beqz	a0,ffffffffc0203c28 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203bea:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bec:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203bee:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bf0:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203bf4:	ff351ae3          	bne	a0,s3,ffffffffc0203be8 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203bf8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203bfc:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203c00:	4c81                	li	s9,0
ffffffffc0203c02:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0203c04:	5c7d                	li	s8,-1
ffffffffc0203c06:	5dfd                	li	s11,-1
ffffffffc0203c08:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0203c0c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c0e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203c12:	0ff5f593          	zext.b	a1,a1
ffffffffc0203c16:	00140d13          	addi	s10,s0,1
ffffffffc0203c1a:	04b56263          	bltu	a0,a1,ffffffffc0203c5e <vprintfmt+0xbc>
ffffffffc0203c1e:	058a                	slli	a1,a1,0x2
ffffffffc0203c20:	95d6                	add	a1,a1,s5
ffffffffc0203c22:	4194                	lw	a3,0(a1)
ffffffffc0203c24:	96d6                	add	a3,a3,s5
ffffffffc0203c26:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203c28:	70e6                	ld	ra,120(sp)
ffffffffc0203c2a:	7446                	ld	s0,112(sp)
ffffffffc0203c2c:	74a6                	ld	s1,104(sp)
ffffffffc0203c2e:	7906                	ld	s2,96(sp)
ffffffffc0203c30:	69e6                	ld	s3,88(sp)
ffffffffc0203c32:	6a46                	ld	s4,80(sp)
ffffffffc0203c34:	6aa6                	ld	s5,72(sp)
ffffffffc0203c36:	6b06                	ld	s6,64(sp)
ffffffffc0203c38:	7be2                	ld	s7,56(sp)
ffffffffc0203c3a:	7c42                	ld	s8,48(sp)
ffffffffc0203c3c:	7ca2                	ld	s9,40(sp)
ffffffffc0203c3e:	7d02                	ld	s10,32(sp)
ffffffffc0203c40:	6de2                	ld	s11,24(sp)
ffffffffc0203c42:	6109                	addi	sp,sp,128
ffffffffc0203c44:	8082                	ret
            padc = '0';
ffffffffc0203c46:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0203c48:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c4c:	846a                	mv	s0,s10
ffffffffc0203c4e:	00140d13          	addi	s10,s0,1
ffffffffc0203c52:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203c56:	0ff5f593          	zext.b	a1,a1
ffffffffc0203c5a:	fcb572e3          	bgeu	a0,a1,ffffffffc0203c1e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0203c5e:	85a6                	mv	a1,s1
ffffffffc0203c60:	02500513          	li	a0,37
ffffffffc0203c64:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203c66:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203c6a:	8d22                	mv	s10,s0
ffffffffc0203c6c:	f73788e3          	beq	a5,s3,ffffffffc0203bdc <vprintfmt+0x3a>
ffffffffc0203c70:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0203c74:	1d7d                	addi	s10,s10,-1
ffffffffc0203c76:	ff379de3          	bne	a5,s3,ffffffffc0203c70 <vprintfmt+0xce>
ffffffffc0203c7a:	b78d                	j	ffffffffc0203bdc <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0203c7c:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0203c80:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c84:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203c86:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203c8a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203c8e:	02d86463          	bltu	a6,a3,ffffffffc0203cb6 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0203c92:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203c96:	002c169b          	slliw	a3,s8,0x2
ffffffffc0203c9a:	0186873b          	addw	a4,a3,s8
ffffffffc0203c9e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203ca2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0203ca4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0203ca8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203caa:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0203cae:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203cb2:	fed870e3          	bgeu	a6,a3,ffffffffc0203c92 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0203cb6:	f40ddce3          	bgez	s11,ffffffffc0203c0e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0203cba:	8de2                	mv	s11,s8
ffffffffc0203cbc:	5c7d                	li	s8,-1
ffffffffc0203cbe:	bf81                	j	ffffffffc0203c0e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0203cc0:	fffdc693          	not	a3,s11
ffffffffc0203cc4:	96fd                	srai	a3,a3,0x3f
ffffffffc0203cc6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cca:	00144603          	lbu	a2,1(s0)
ffffffffc0203cce:	2d81                	sext.w	s11,s11
ffffffffc0203cd0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203cd2:	bf35                	j	ffffffffc0203c0e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0203cd4:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cd8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203cdc:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cde:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0203ce0:	bfd9                	j	ffffffffc0203cb6 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0203ce2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203ce4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203ce8:	01174463          	blt	a4,a7,ffffffffc0203cf0 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0203cec:	1a088e63          	beqz	a7,ffffffffc0203ea8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0203cf0:	000a3603          	ld	a2,0(s4)
ffffffffc0203cf4:	46c1                	li	a3,16
ffffffffc0203cf6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203cf8:	2781                	sext.w	a5,a5
ffffffffc0203cfa:	876e                	mv	a4,s11
ffffffffc0203cfc:	85a6                	mv	a1,s1
ffffffffc0203cfe:	854a                	mv	a0,s2
ffffffffc0203d00:	e37ff0ef          	jal	ra,ffffffffc0203b36 <printnum>
            break;
ffffffffc0203d04:	bde1                	j	ffffffffc0203bdc <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0203d06:	000a2503          	lw	a0,0(s4)
ffffffffc0203d0a:	85a6                	mv	a1,s1
ffffffffc0203d0c:	0a21                	addi	s4,s4,8
ffffffffc0203d0e:	9902                	jalr	s2
            break;
ffffffffc0203d10:	b5f1                	j	ffffffffc0203bdc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203d12:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203d14:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203d18:	01174463          	blt	a4,a7,ffffffffc0203d20 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0203d1c:	18088163          	beqz	a7,ffffffffc0203e9e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0203d20:	000a3603          	ld	a2,0(s4)
ffffffffc0203d24:	46a9                	li	a3,10
ffffffffc0203d26:	8a2e                	mv	s4,a1
ffffffffc0203d28:	bfc1                	j	ffffffffc0203cf8 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d2a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203d2e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d30:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203d32:	bdf1                	j	ffffffffc0203c0e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0203d34:	85a6                	mv	a1,s1
ffffffffc0203d36:	02500513          	li	a0,37
ffffffffc0203d3a:	9902                	jalr	s2
            break;
ffffffffc0203d3c:	b545                	j	ffffffffc0203bdc <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d3e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0203d42:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d44:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203d46:	b5e1                	j	ffffffffc0203c0e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0203d48:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203d4a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203d4e:	01174463          	blt	a4,a7,ffffffffc0203d56 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0203d52:	14088163          	beqz	a7,ffffffffc0203e94 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0203d56:	000a3603          	ld	a2,0(s4)
ffffffffc0203d5a:	46a1                	li	a3,8
ffffffffc0203d5c:	8a2e                	mv	s4,a1
ffffffffc0203d5e:	bf69                	j	ffffffffc0203cf8 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0203d60:	03000513          	li	a0,48
ffffffffc0203d64:	85a6                	mv	a1,s1
ffffffffc0203d66:	e03e                	sd	a5,0(sp)
ffffffffc0203d68:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203d6a:	85a6                	mv	a1,s1
ffffffffc0203d6c:	07800513          	li	a0,120
ffffffffc0203d70:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203d72:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0203d74:	6782                	ld	a5,0(sp)
ffffffffc0203d76:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203d78:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0203d7c:	bfb5                	j	ffffffffc0203cf8 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203d7e:	000a3403          	ld	s0,0(s4)
ffffffffc0203d82:	008a0713          	addi	a4,s4,8
ffffffffc0203d86:	e03a                	sd	a4,0(sp)
ffffffffc0203d88:	14040263          	beqz	s0,ffffffffc0203ecc <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0203d8c:	0fb05763          	blez	s11,ffffffffc0203e7a <vprintfmt+0x2d8>
ffffffffc0203d90:	02d00693          	li	a3,45
ffffffffc0203d94:	0cd79163          	bne	a5,a3,ffffffffc0203e56 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d98:	00044783          	lbu	a5,0(s0)
ffffffffc0203d9c:	0007851b          	sext.w	a0,a5
ffffffffc0203da0:	cf85                	beqz	a5,ffffffffc0203dd8 <vprintfmt+0x236>
ffffffffc0203da2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203da6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203daa:	000c4563          	bltz	s8,ffffffffc0203db4 <vprintfmt+0x212>
ffffffffc0203dae:	3c7d                	addiw	s8,s8,-1
ffffffffc0203db0:	036c0263          	beq	s8,s6,ffffffffc0203dd4 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0203db4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203db6:	0e0c8e63          	beqz	s9,ffffffffc0203eb2 <vprintfmt+0x310>
ffffffffc0203dba:	3781                	addiw	a5,a5,-32
ffffffffc0203dbc:	0ef47b63          	bgeu	s0,a5,ffffffffc0203eb2 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0203dc0:	03f00513          	li	a0,63
ffffffffc0203dc4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203dc6:	000a4783          	lbu	a5,0(s4)
ffffffffc0203dca:	3dfd                	addiw	s11,s11,-1
ffffffffc0203dcc:	0a05                	addi	s4,s4,1
ffffffffc0203dce:	0007851b          	sext.w	a0,a5
ffffffffc0203dd2:	ffe1                	bnez	a5,ffffffffc0203daa <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0203dd4:	01b05963          	blez	s11,ffffffffc0203de6 <vprintfmt+0x244>
ffffffffc0203dd8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203dda:	85a6                	mv	a1,s1
ffffffffc0203ddc:	02000513          	li	a0,32
ffffffffc0203de0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203de2:	fe0d9be3          	bnez	s11,ffffffffc0203dd8 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203de6:	6a02                	ld	s4,0(sp)
ffffffffc0203de8:	bbd5                	j	ffffffffc0203bdc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203dea:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203dec:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0203df0:	01174463          	blt	a4,a7,ffffffffc0203df8 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0203df4:	08088d63          	beqz	a7,ffffffffc0203e8e <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0203df8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0203dfc:	0a044d63          	bltz	s0,ffffffffc0203eb6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0203e00:	8622                	mv	a2,s0
ffffffffc0203e02:	8a66                	mv	s4,s9
ffffffffc0203e04:	46a9                	li	a3,10
ffffffffc0203e06:	bdcd                	j	ffffffffc0203cf8 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0203e08:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203e0c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203e0e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0203e10:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203e14:	8fb5                	xor	a5,a5,a3
ffffffffc0203e16:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203e1a:	02d74163          	blt	a4,a3,ffffffffc0203e3c <vprintfmt+0x29a>
ffffffffc0203e1e:	00369793          	slli	a5,a3,0x3
ffffffffc0203e22:	97de                	add	a5,a5,s7
ffffffffc0203e24:	639c                	ld	a5,0(a5)
ffffffffc0203e26:	cb99                	beqz	a5,ffffffffc0203e3c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203e28:	86be                	mv	a3,a5
ffffffffc0203e2a:	00000617          	auipc	a2,0x0
ffffffffc0203e2e:	13e60613          	addi	a2,a2,318 # ffffffffc0203f68 <etext+0x2e>
ffffffffc0203e32:	85a6                	mv	a1,s1
ffffffffc0203e34:	854a                	mv	a0,s2
ffffffffc0203e36:	0ce000ef          	jal	ra,ffffffffc0203f04 <printfmt>
ffffffffc0203e3a:	b34d                	j	ffffffffc0203bdc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203e3c:	00002617          	auipc	a2,0x2
ffffffffc0203e40:	9ac60613          	addi	a2,a2,-1620 # ffffffffc02057e8 <default_pmm_manager+0x210>
ffffffffc0203e44:	85a6                	mv	a1,s1
ffffffffc0203e46:	854a                	mv	a0,s2
ffffffffc0203e48:	0bc000ef          	jal	ra,ffffffffc0203f04 <printfmt>
ffffffffc0203e4c:	bb41                	j	ffffffffc0203bdc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0203e4e:	00002417          	auipc	s0,0x2
ffffffffc0203e52:	99240413          	addi	s0,s0,-1646 # ffffffffc02057e0 <default_pmm_manager+0x208>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e56:	85e2                	mv	a1,s8
ffffffffc0203e58:	8522                	mv	a0,s0
ffffffffc0203e5a:	e43e                	sd	a5,8(sp)
ffffffffc0203e5c:	c05ff0ef          	jal	ra,ffffffffc0203a60 <strnlen>
ffffffffc0203e60:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203e64:	01b05b63          	blez	s11,ffffffffc0203e7a <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0203e68:	67a2                	ld	a5,8(sp)
ffffffffc0203e6a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e6e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0203e70:	85a6                	mv	a1,s1
ffffffffc0203e72:	8552                	mv	a0,s4
ffffffffc0203e74:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e76:	fe0d9ce3          	bnez	s11,ffffffffc0203e6e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203e7a:	00044783          	lbu	a5,0(s0)
ffffffffc0203e7e:	00140a13          	addi	s4,s0,1
ffffffffc0203e82:	0007851b          	sext.w	a0,a5
ffffffffc0203e86:	d3a5                	beqz	a5,ffffffffc0203de6 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e88:	05e00413          	li	s0,94
ffffffffc0203e8c:	bf39                	j	ffffffffc0203daa <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0203e8e:	000a2403          	lw	s0,0(s4)
ffffffffc0203e92:	b7ad                	j	ffffffffc0203dfc <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0203e94:	000a6603          	lwu	a2,0(s4)
ffffffffc0203e98:	46a1                	li	a3,8
ffffffffc0203e9a:	8a2e                	mv	s4,a1
ffffffffc0203e9c:	bdb1                	j	ffffffffc0203cf8 <vprintfmt+0x156>
ffffffffc0203e9e:	000a6603          	lwu	a2,0(s4)
ffffffffc0203ea2:	46a9                	li	a3,10
ffffffffc0203ea4:	8a2e                	mv	s4,a1
ffffffffc0203ea6:	bd89                	j	ffffffffc0203cf8 <vprintfmt+0x156>
ffffffffc0203ea8:	000a6603          	lwu	a2,0(s4)
ffffffffc0203eac:	46c1                	li	a3,16
ffffffffc0203eae:	8a2e                	mv	s4,a1
ffffffffc0203eb0:	b5a1                	j	ffffffffc0203cf8 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0203eb2:	9902                	jalr	s2
ffffffffc0203eb4:	bf09                	j	ffffffffc0203dc6 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0203eb6:	85a6                	mv	a1,s1
ffffffffc0203eb8:	02d00513          	li	a0,45
ffffffffc0203ebc:	e03e                	sd	a5,0(sp)
ffffffffc0203ebe:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0203ec0:	6782                	ld	a5,0(sp)
ffffffffc0203ec2:	8a66                	mv	s4,s9
ffffffffc0203ec4:	40800633          	neg	a2,s0
ffffffffc0203ec8:	46a9                	li	a3,10
ffffffffc0203eca:	b53d                	j	ffffffffc0203cf8 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0203ecc:	03b05163          	blez	s11,ffffffffc0203eee <vprintfmt+0x34c>
ffffffffc0203ed0:	02d00693          	li	a3,45
ffffffffc0203ed4:	f6d79de3          	bne	a5,a3,ffffffffc0203e4e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0203ed8:	00002417          	auipc	s0,0x2
ffffffffc0203edc:	90840413          	addi	s0,s0,-1784 # ffffffffc02057e0 <default_pmm_manager+0x208>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203ee0:	02800793          	li	a5,40
ffffffffc0203ee4:	02800513          	li	a0,40
ffffffffc0203ee8:	00140a13          	addi	s4,s0,1
ffffffffc0203eec:	bd6d                	j	ffffffffc0203da6 <vprintfmt+0x204>
ffffffffc0203eee:	00002a17          	auipc	s4,0x2
ffffffffc0203ef2:	8f3a0a13          	addi	s4,s4,-1805 # ffffffffc02057e1 <default_pmm_manager+0x209>
ffffffffc0203ef6:	02800513          	li	a0,40
ffffffffc0203efa:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203efe:	05e00413          	li	s0,94
ffffffffc0203f02:	b565                	j	ffffffffc0203daa <vprintfmt+0x208>

ffffffffc0203f04 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203f04:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0203f06:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203f0a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203f0c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203f0e:	ec06                	sd	ra,24(sp)
ffffffffc0203f10:	f83a                	sd	a4,48(sp)
ffffffffc0203f12:	fc3e                	sd	a5,56(sp)
ffffffffc0203f14:	e0c2                	sd	a6,64(sp)
ffffffffc0203f16:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0203f18:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203f1a:	c89ff0ef          	jal	ra,ffffffffc0203ba2 <vprintfmt>
}
ffffffffc0203f1e:	60e2                	ld	ra,24(sp)
ffffffffc0203f20:	6161                	addi	sp,sp,80
ffffffffc0203f22:	8082                	ret

ffffffffc0203f24 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0203f24:	9e3707b7          	lui	a5,0x9e370
ffffffffc0203f28:	2785                	addiw	a5,a5,1
ffffffffc0203f2a:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0203f2e:	02000793          	li	a5,32
ffffffffc0203f32:	9f8d                	subw	a5,a5,a1
}
ffffffffc0203f34:	00f5553b          	srlw	a0,a0,a5
ffffffffc0203f38:	8082                	ret
