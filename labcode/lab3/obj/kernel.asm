
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00007297          	auipc	t0,0x7
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0207000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00007297          	auipc	t0,0x7
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0207008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02062b7          	lui	t0,0xc0206
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
ffffffffc020003c:	c0206137          	lui	sp,0xc0206

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 1. 使用临时寄存器 t1 计算栈顶的精确地址
    lui t1, %hi(bootstacktop)
ffffffffc0200040:	c0206337          	lui	t1,0xc0206
    addi t1, t1, %lo(bootstacktop)
ffffffffc0200044:	00030313          	mv	t1,t1
    # 2. 将精确地址一次性地、安全地传给 sp
    mv sp, t1
ffffffffc0200048:	811a                	mv	sp,t1
    # 现在栈指针已经完美设置，可以安全地调用任何C函数了
    # 然后跳转到 kern_init (不再返回)
    lui t0, %hi(kern_init)
ffffffffc020004a:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020004e:	05428293          	addi	t0,t0,84 # ffffffffc0200054 <kern_init>
    jr t0
ffffffffc0200052:	8282                	jr	t0

ffffffffc0200054 <kern_init>:
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    // 先清零 BSS，再读取并保存 DTB 的内存信息，避免被清零覆盖（为了解释变化 正式上传时我觉得应该删去这句话）
    memset(edata, 0, end - edata);
ffffffffc0200054:	00007517          	auipc	a0,0x7
ffffffffc0200058:	fd450513          	addi	a0,a0,-44 # ffffffffc0207028 <free_area>
ffffffffc020005c:	00007617          	auipc	a2,0x7
ffffffffc0200060:	44460613          	addi	a2,a2,1092 # ffffffffc02074a0 <end>
int kern_init(void) {
ffffffffc0200064:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200066:	8e09                	sub	a2,a2,a0
ffffffffc0200068:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020006a:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020006c:	285010ef          	jal	ra,ffffffffc0201af0 <memset>
    dtb_init();
ffffffffc0200070:	3c2000ef          	jal	ra,ffffffffc0200432 <dtb_init>
    cons_init();  // init the console
ffffffffc0200074:	7b2000ef          	jal	ra,ffffffffc0200826 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200078:	00002517          	auipc	a0,0x2
ffffffffc020007c:	fb050513          	addi	a0,a0,-80 # ffffffffc0202028 <etext+0x2>
ffffffffc0200080:	094000ef          	jal	ra,ffffffffc0200114 <cputs>

    print_kerninfo();
ffffffffc0200084:	13c000ef          	jal	ra,ffffffffc02001c0 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200088:	7b8000ef          	jal	ra,ffffffffc0200840 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020008c:	51d000ef          	jal	ra,ffffffffc0200da8 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc0200090:	7b0000ef          	jal	ra,ffffffffc0200840 <idt_init>
    clock_init();   // init clock interrupt
ffffffffc0200094:	74e000ef          	jal	ra,ffffffffc02007e2 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200098:	79c000ef          	jal	ra,ffffffffc0200834 <intr_enable>
ffffffffc020009c:	ffff                	0xffff
ffffffffc020009e:	ffff                	0xffff
    /* do nothing */
    //asm volatile("ebreak");            // 触发 breakpoint 异常
    asm volatile(".4byte 0xffffffff"); // 明确的非法 32 位指令，触发 illegal instruction
    
    while (1)
ffffffffc02000a0:	a001                	j	ffffffffc02000a0 <kern_init+0x4c>

ffffffffc02000a2 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc02000a2:	1141                	addi	sp,sp,-16
ffffffffc02000a4:	e022                	sd	s0,0(sp)
ffffffffc02000a6:	e406                	sd	ra,8(sp)
ffffffffc02000a8:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc02000aa:	77e000ef          	jal	ra,ffffffffc0200828 <cons_putc>
    (*cnt) ++;
ffffffffc02000ae:	401c                	lw	a5,0(s0)
}
ffffffffc02000b0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000b2:	2785                	addiw	a5,a5,1
ffffffffc02000b4:	c01c                	sw	a5,0(s0)
}
ffffffffc02000b6:	6402                	ld	s0,0(sp)
ffffffffc02000b8:	0141                	addi	sp,sp,16
ffffffffc02000ba:	8082                	ret

ffffffffc02000bc <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000bc:	1101                	addi	sp,sp,-32
ffffffffc02000be:	862a                	mv	a2,a0
ffffffffc02000c0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	00000517          	auipc	a0,0x0
ffffffffc02000c6:	fe050513          	addi	a0,a0,-32 # ffffffffc02000a2 <cputch>
ffffffffc02000ca:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000cc:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ce:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000d0:	2b7010ef          	jal	ra,ffffffffc0201b86 <vprintfmt>
    return cnt;
}
ffffffffc02000d4:	60e2                	ld	ra,24(sp)
ffffffffc02000d6:	4532                	lw	a0,12(sp)
ffffffffc02000d8:	6105                	addi	sp,sp,32
ffffffffc02000da:	8082                	ret

ffffffffc02000dc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000dc:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000de:	02810313          	addi	t1,sp,40 # ffffffffc0206028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000e2:	8e2a                	mv	t3,a0
ffffffffc02000e4:	f42e                	sd	a1,40(sp)
ffffffffc02000e6:	f832                	sd	a2,48(sp)
ffffffffc02000e8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ea:	00000517          	auipc	a0,0x0
ffffffffc02000ee:	fb850513          	addi	a0,a0,-72 # ffffffffc02000a2 <cputch>
ffffffffc02000f2:	004c                	addi	a1,sp,4
ffffffffc02000f4:	869a                	mv	a3,t1
ffffffffc02000f6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000f8:	ec06                	sd	ra,24(sp)
ffffffffc02000fa:	e0ba                	sd	a4,64(sp)
ffffffffc02000fc:	e4be                	sd	a5,72(sp)
ffffffffc02000fe:	e8c2                	sd	a6,80(sp)
ffffffffc0200100:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200102:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200104:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200106:	281010ef          	jal	ra,ffffffffc0201b86 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020010a:	60e2                	ld	ra,24(sp)
ffffffffc020010c:	4512                	lw	a0,4(sp)
ffffffffc020010e:	6125                	addi	sp,sp,96
ffffffffc0200110:	8082                	ret

ffffffffc0200112 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200112:	af19                	j	ffffffffc0200828 <cons_putc>

ffffffffc0200114 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200114:	1101                	addi	sp,sp,-32
ffffffffc0200116:	e822                	sd	s0,16(sp)
ffffffffc0200118:	ec06                	sd	ra,24(sp)
ffffffffc020011a:	e426                	sd	s1,8(sp)
ffffffffc020011c:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020011e:	00054503          	lbu	a0,0(a0)
ffffffffc0200122:	c51d                	beqz	a0,ffffffffc0200150 <cputs+0x3c>
ffffffffc0200124:	0405                	addi	s0,s0,1
ffffffffc0200126:	4485                	li	s1,1
ffffffffc0200128:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020012a:	6fe000ef          	jal	ra,ffffffffc0200828 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020012e:	00044503          	lbu	a0,0(s0)
ffffffffc0200132:	008487bb          	addw	a5,s1,s0
ffffffffc0200136:	0405                	addi	s0,s0,1
ffffffffc0200138:	f96d                	bnez	a0,ffffffffc020012a <cputs+0x16>
    (*cnt) ++;
ffffffffc020013a:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020013e:	4529                	li	a0,10
ffffffffc0200140:	6e8000ef          	jal	ra,ffffffffc0200828 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	8522                	mv	a0,s0
ffffffffc0200148:	6442                	ld	s0,16(sp)
ffffffffc020014a:	64a2                	ld	s1,8(sp)
ffffffffc020014c:	6105                	addi	sp,sp,32
ffffffffc020014e:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200150:	4405                	li	s0,1
ffffffffc0200152:	b7f5                	j	ffffffffc020013e <cputs+0x2a>

ffffffffc0200154 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200158:	6d8000ef          	jal	ra,ffffffffc0200830 <cons_getc>
ffffffffc020015c:	dd75                	beqz	a0,ffffffffc0200158 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020015e:	60a2                	ld	ra,8(sp)
ffffffffc0200160:	0141                	addi	sp,sp,16
ffffffffc0200162:	8082                	ret

ffffffffc0200164 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200164:	00007317          	auipc	t1,0x7
ffffffffc0200168:	2dc30313          	addi	t1,t1,732 # ffffffffc0207440 <is_panic>
ffffffffc020016c:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200170:	715d                	addi	sp,sp,-80
ffffffffc0200172:	ec06                	sd	ra,24(sp)
ffffffffc0200174:	e822                	sd	s0,16(sp)
ffffffffc0200176:	f436                	sd	a3,40(sp)
ffffffffc0200178:	f83a                	sd	a4,48(sp)
ffffffffc020017a:	fc3e                	sd	a5,56(sp)
ffffffffc020017c:	e0c2                	sd	a6,64(sp)
ffffffffc020017e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200180:	020e1a63          	bnez	t3,ffffffffc02001b4 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200184:	4785                	li	a5,1
ffffffffc0200186:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020018a:	8432                	mv	s0,a2
ffffffffc020018c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020018e:	862e                	mv	a2,a1
ffffffffc0200190:	85aa                	mv	a1,a0
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	eb650513          	addi	a0,a0,-330 # ffffffffc0202048 <etext+0x22>
    va_start(ap, fmt);
ffffffffc020019a:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020019c:	f41ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    vcprintf(fmt, ap);
ffffffffc02001a0:	65a2                	ld	a1,8(sp)
ffffffffc02001a2:	8522                	mv	a0,s0
ffffffffc02001a4:	f19ff0ef          	jal	ra,ffffffffc02000bc <vcprintf>
    cprintf("\n");
ffffffffc02001a8:	00002517          	auipc	a0,0x2
ffffffffc02001ac:	f8850513          	addi	a0,a0,-120 # ffffffffc0202130 <etext+0x10a>
ffffffffc02001b0:	f2dff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02001b4:	686000ef          	jal	ra,ffffffffc020083a <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02001b8:	4501                	li	a0,0
ffffffffc02001ba:	130000ef          	jal	ra,ffffffffc02002ea <kmonitor>
    while (1) {
ffffffffc02001be:	bfed                	j	ffffffffc02001b8 <__panic+0x54>

ffffffffc02001c0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001c0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001c2:	00002517          	auipc	a0,0x2
ffffffffc02001c6:	ea650513          	addi	a0,a0,-346 # ffffffffc0202068 <etext+0x42>
void print_kerninfo(void) {
ffffffffc02001ca:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001cc:	f11ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001d0:	00000597          	auipc	a1,0x0
ffffffffc02001d4:	e8458593          	addi	a1,a1,-380 # ffffffffc0200054 <kern_init>
ffffffffc02001d8:	00002517          	auipc	a0,0x2
ffffffffc02001dc:	eb050513          	addi	a0,a0,-336 # ffffffffc0202088 <etext+0x62>
ffffffffc02001e0:	efdff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001e4:	00002597          	auipc	a1,0x2
ffffffffc02001e8:	e4258593          	addi	a1,a1,-446 # ffffffffc0202026 <etext>
ffffffffc02001ec:	00002517          	auipc	a0,0x2
ffffffffc02001f0:	ebc50513          	addi	a0,a0,-324 # ffffffffc02020a8 <etext+0x82>
ffffffffc02001f4:	ee9ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001f8:	00007597          	auipc	a1,0x7
ffffffffc02001fc:	e3058593          	addi	a1,a1,-464 # ffffffffc0207028 <free_area>
ffffffffc0200200:	00002517          	auipc	a0,0x2
ffffffffc0200204:	ec850513          	addi	a0,a0,-312 # ffffffffc02020c8 <etext+0xa2>
ffffffffc0200208:	ed5ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020020c:	00007597          	auipc	a1,0x7
ffffffffc0200210:	29458593          	addi	a1,a1,660 # ffffffffc02074a0 <end>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	ed450513          	addi	a0,a0,-300 # ffffffffc02020e8 <etext+0xc2>
ffffffffc020021c:	ec1ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200220:	00007597          	auipc	a1,0x7
ffffffffc0200224:	67f58593          	addi	a1,a1,1663 # ffffffffc020789f <end+0x3ff>
ffffffffc0200228:	00000797          	auipc	a5,0x0
ffffffffc020022c:	e2c78793          	addi	a5,a5,-468 # ffffffffc0200054 <kern_init>
ffffffffc0200230:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200234:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200238:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020023a:	3ff5f593          	andi	a1,a1,1023
ffffffffc020023e:	95be                	add	a1,a1,a5
ffffffffc0200240:	85a9                	srai	a1,a1,0xa
ffffffffc0200242:	00002517          	auipc	a0,0x2
ffffffffc0200246:	ec650513          	addi	a0,a0,-314 # ffffffffc0202108 <etext+0xe2>
}
ffffffffc020024a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024c:	bd41                	j	ffffffffc02000dc <cprintf>

ffffffffc020024e <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020024e:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200250:	00002617          	auipc	a2,0x2
ffffffffc0200254:	ee860613          	addi	a2,a2,-280 # ffffffffc0202138 <etext+0x112>
ffffffffc0200258:	04d00593          	li	a1,77
ffffffffc020025c:	00002517          	auipc	a0,0x2
ffffffffc0200260:	ef450513          	addi	a0,a0,-268 # ffffffffc0202150 <etext+0x12a>
void print_stackframe(void) {
ffffffffc0200264:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200266:	effff0ef          	jal	ra,ffffffffc0200164 <__panic>

ffffffffc020026a <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020026a:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020026c:	00002617          	auipc	a2,0x2
ffffffffc0200270:	efc60613          	addi	a2,a2,-260 # ffffffffc0202168 <etext+0x142>
ffffffffc0200274:	00002597          	auipc	a1,0x2
ffffffffc0200278:	f1458593          	addi	a1,a1,-236 # ffffffffc0202188 <etext+0x162>
ffffffffc020027c:	00002517          	auipc	a0,0x2
ffffffffc0200280:	f1450513          	addi	a0,a0,-236 # ffffffffc0202190 <etext+0x16a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200284:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200286:	e57ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
ffffffffc020028a:	00002617          	auipc	a2,0x2
ffffffffc020028e:	f1660613          	addi	a2,a2,-234 # ffffffffc02021a0 <etext+0x17a>
ffffffffc0200292:	00002597          	auipc	a1,0x2
ffffffffc0200296:	f3658593          	addi	a1,a1,-202 # ffffffffc02021c8 <etext+0x1a2>
ffffffffc020029a:	00002517          	auipc	a0,0x2
ffffffffc020029e:	ef650513          	addi	a0,a0,-266 # ffffffffc0202190 <etext+0x16a>
ffffffffc02002a2:	e3bff0ef          	jal	ra,ffffffffc02000dc <cprintf>
ffffffffc02002a6:	00002617          	auipc	a2,0x2
ffffffffc02002aa:	f3260613          	addi	a2,a2,-206 # ffffffffc02021d8 <etext+0x1b2>
ffffffffc02002ae:	00002597          	auipc	a1,0x2
ffffffffc02002b2:	f4a58593          	addi	a1,a1,-182 # ffffffffc02021f8 <etext+0x1d2>
ffffffffc02002b6:	00002517          	auipc	a0,0x2
ffffffffc02002ba:	eda50513          	addi	a0,a0,-294 # ffffffffc0202190 <etext+0x16a>
ffffffffc02002be:	e1fff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    }
    return 0;
}
ffffffffc02002c2:	60a2                	ld	ra,8(sp)
ffffffffc02002c4:	4501                	li	a0,0
ffffffffc02002c6:	0141                	addi	sp,sp,16
ffffffffc02002c8:	8082                	ret

ffffffffc02002ca <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ca:	1141                	addi	sp,sp,-16
ffffffffc02002cc:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002ce:	ef3ff0ef          	jal	ra,ffffffffc02001c0 <print_kerninfo>
    return 0;
}
ffffffffc02002d2:	60a2                	ld	ra,8(sp)
ffffffffc02002d4:	4501                	li	a0,0
ffffffffc02002d6:	0141                	addi	sp,sp,16
ffffffffc02002d8:	8082                	ret

ffffffffc02002da <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002da:	1141                	addi	sp,sp,-16
ffffffffc02002dc:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002de:	f71ff0ef          	jal	ra,ffffffffc020024e <print_stackframe>
    return 0;
}
ffffffffc02002e2:	60a2                	ld	ra,8(sp)
ffffffffc02002e4:	4501                	li	a0,0
ffffffffc02002e6:	0141                	addi	sp,sp,16
ffffffffc02002e8:	8082                	ret

ffffffffc02002ea <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002ea:	7115                	addi	sp,sp,-224
ffffffffc02002ec:	ed5e                	sd	s7,152(sp)
ffffffffc02002ee:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002f0:	00002517          	auipc	a0,0x2
ffffffffc02002f4:	f1850513          	addi	a0,a0,-232 # ffffffffc0202208 <etext+0x1e2>
kmonitor(struct trapframe *tf) {
ffffffffc02002f8:	ed86                	sd	ra,216(sp)
ffffffffc02002fa:	e9a2                	sd	s0,208(sp)
ffffffffc02002fc:	e5a6                	sd	s1,200(sp)
ffffffffc02002fe:	e1ca                	sd	s2,192(sp)
ffffffffc0200300:	fd4e                	sd	s3,184(sp)
ffffffffc0200302:	f952                	sd	s4,176(sp)
ffffffffc0200304:	f556                	sd	s5,168(sp)
ffffffffc0200306:	f15a                	sd	s6,160(sp)
ffffffffc0200308:	e962                	sd	s8,144(sp)
ffffffffc020030a:	e566                	sd	s9,136(sp)
ffffffffc020030c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020030e:	dcfff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200312:	00002517          	auipc	a0,0x2
ffffffffc0200316:	f1e50513          	addi	a0,a0,-226 # ffffffffc0202230 <etext+0x20a>
ffffffffc020031a:	dc3ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    if (tf != NULL) {
ffffffffc020031e:	000b8563          	beqz	s7,ffffffffc0200328 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200322:	855e                	mv	a0,s7
ffffffffc0200324:	6fc000ef          	jal	ra,ffffffffc0200a20 <print_trapframe>
ffffffffc0200328:	00002c17          	auipc	s8,0x2
ffffffffc020032c:	f78c0c13          	addi	s8,s8,-136 # ffffffffc02022a0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200330:	00002917          	auipc	s2,0x2
ffffffffc0200334:	f2890913          	addi	s2,s2,-216 # ffffffffc0202258 <etext+0x232>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200338:	00002497          	auipc	s1,0x2
ffffffffc020033c:	f2848493          	addi	s1,s1,-216 # ffffffffc0202260 <etext+0x23a>
        if (argc == MAXARGS - 1) {
ffffffffc0200340:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200342:	00002b17          	auipc	s6,0x2
ffffffffc0200346:	f26b0b13          	addi	s6,s6,-218 # ffffffffc0202268 <etext+0x242>
        argv[argc ++] = buf;
ffffffffc020034a:	00002a17          	auipc	s4,0x2
ffffffffc020034e:	e3ea0a13          	addi	s4,s4,-450 # ffffffffc0202188 <etext+0x162>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200352:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200354:	854a                	mv	a0,s2
ffffffffc0200356:	3b3010ef          	jal	ra,ffffffffc0201f08 <readline>
ffffffffc020035a:	842a                	mv	s0,a0
ffffffffc020035c:	dd65                	beqz	a0,ffffffffc0200354 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020035e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200362:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200364:	e1bd                	bnez	a1,ffffffffc02003ca <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200366:	fe0c87e3          	beqz	s9,ffffffffc0200354 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036a:	6582                	ld	a1,0(sp)
ffffffffc020036c:	00002d17          	auipc	s10,0x2
ffffffffc0200370:	f34d0d13          	addi	s10,s10,-204 # ffffffffc02022a0 <commands>
        argv[argc ++] = buf;
ffffffffc0200374:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200376:	4401                	li	s0,0
ffffffffc0200378:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037a:	71c010ef          	jal	ra,ffffffffc0201a96 <strcmp>
ffffffffc020037e:	c919                	beqz	a0,ffffffffc0200394 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200380:	2405                	addiw	s0,s0,1
ffffffffc0200382:	0b540063          	beq	s0,s5,ffffffffc0200422 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200386:	000d3503          	ld	a0,0(s10)
ffffffffc020038a:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020038c:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020038e:	708010ef          	jal	ra,ffffffffc0201a96 <strcmp>
ffffffffc0200392:	f57d                	bnez	a0,ffffffffc0200380 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200394:	00141793          	slli	a5,s0,0x1
ffffffffc0200398:	97a2                	add	a5,a5,s0
ffffffffc020039a:	078e                	slli	a5,a5,0x3
ffffffffc020039c:	97e2                	add	a5,a5,s8
ffffffffc020039e:	6b9c                	ld	a5,16(a5)
ffffffffc02003a0:	865e                	mv	a2,s7
ffffffffc02003a2:	002c                	addi	a1,sp,8
ffffffffc02003a4:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003a8:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003aa:	fa0555e3          	bgez	a0,ffffffffc0200354 <kmonitor+0x6a>
}
ffffffffc02003ae:	60ee                	ld	ra,216(sp)
ffffffffc02003b0:	644e                	ld	s0,208(sp)
ffffffffc02003b2:	64ae                	ld	s1,200(sp)
ffffffffc02003b4:	690e                	ld	s2,192(sp)
ffffffffc02003b6:	79ea                	ld	s3,184(sp)
ffffffffc02003b8:	7a4a                	ld	s4,176(sp)
ffffffffc02003ba:	7aaa                	ld	s5,168(sp)
ffffffffc02003bc:	7b0a                	ld	s6,160(sp)
ffffffffc02003be:	6bea                	ld	s7,152(sp)
ffffffffc02003c0:	6c4a                	ld	s8,144(sp)
ffffffffc02003c2:	6caa                	ld	s9,136(sp)
ffffffffc02003c4:	6d0a                	ld	s10,128(sp)
ffffffffc02003c6:	612d                	addi	sp,sp,224
ffffffffc02003c8:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ca:	8526                	mv	a0,s1
ffffffffc02003cc:	70e010ef          	jal	ra,ffffffffc0201ada <strchr>
ffffffffc02003d0:	c901                	beqz	a0,ffffffffc02003e0 <kmonitor+0xf6>
ffffffffc02003d2:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003d6:	00040023          	sb	zero,0(s0)
ffffffffc02003da:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003dc:	d5c9                	beqz	a1,ffffffffc0200366 <kmonitor+0x7c>
ffffffffc02003de:	b7f5                	j	ffffffffc02003ca <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003e0:	00044783          	lbu	a5,0(s0)
ffffffffc02003e4:	d3c9                	beqz	a5,ffffffffc0200366 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003e6:	033c8963          	beq	s9,s3,ffffffffc0200418 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003ea:	003c9793          	slli	a5,s9,0x3
ffffffffc02003ee:	0118                	addi	a4,sp,128
ffffffffc02003f0:	97ba                	add	a5,a5,a4
ffffffffc02003f2:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003f6:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003fa:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003fc:	e591                	bnez	a1,ffffffffc0200408 <kmonitor+0x11e>
ffffffffc02003fe:	b7b5                	j	ffffffffc020036a <kmonitor+0x80>
ffffffffc0200400:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200404:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200406:	d1a5                	beqz	a1,ffffffffc0200366 <kmonitor+0x7c>
ffffffffc0200408:	8526                	mv	a0,s1
ffffffffc020040a:	6d0010ef          	jal	ra,ffffffffc0201ada <strchr>
ffffffffc020040e:	d96d                	beqz	a0,ffffffffc0200400 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200410:	00044583          	lbu	a1,0(s0)
ffffffffc0200414:	d9a9                	beqz	a1,ffffffffc0200366 <kmonitor+0x7c>
ffffffffc0200416:	bf55                	j	ffffffffc02003ca <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200418:	45c1                	li	a1,16
ffffffffc020041a:	855a                	mv	a0,s6
ffffffffc020041c:	cc1ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
ffffffffc0200420:	b7e9                	j	ffffffffc02003ea <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200422:	6582                	ld	a1,0(sp)
ffffffffc0200424:	00002517          	auipc	a0,0x2
ffffffffc0200428:	e6450513          	addi	a0,a0,-412 # ffffffffc0202288 <etext+0x262>
ffffffffc020042c:	cb1ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    return 0;
ffffffffc0200430:	b715                	j	ffffffffc0200354 <kmonitor+0x6a>

ffffffffc0200432 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200432:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200434:	00002517          	auipc	a0,0x2
ffffffffc0200438:	eb450513          	addi	a0,a0,-332 # ffffffffc02022e8 <commands+0x48>
void dtb_init(void) {
ffffffffc020043c:	fc86                	sd	ra,120(sp)
ffffffffc020043e:	f8a2                	sd	s0,112(sp)
ffffffffc0200440:	e8d2                	sd	s4,80(sp)
ffffffffc0200442:	f4a6                	sd	s1,104(sp)
ffffffffc0200444:	f0ca                	sd	s2,96(sp)
ffffffffc0200446:	ecce                	sd	s3,88(sp)
ffffffffc0200448:	e4d6                	sd	s5,72(sp)
ffffffffc020044a:	e0da                	sd	s6,64(sp)
ffffffffc020044c:	fc5e                	sd	s7,56(sp)
ffffffffc020044e:	f862                	sd	s8,48(sp)
ffffffffc0200450:	f466                	sd	s9,40(sp)
ffffffffc0200452:	f06a                	sd	s10,32(sp)
ffffffffc0200454:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200456:	c87ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc020045a:	00007597          	auipc	a1,0x7
ffffffffc020045e:	ba65b583          	ld	a1,-1114(a1) # ffffffffc0207000 <boot_hartid>
ffffffffc0200462:	00002517          	auipc	a0,0x2
ffffffffc0200466:	e9650513          	addi	a0,a0,-362 # ffffffffc02022f8 <commands+0x58>
ffffffffc020046a:	c73ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020046e:	00007417          	auipc	s0,0x7
ffffffffc0200472:	b9a40413          	addi	s0,s0,-1126 # ffffffffc0207008 <boot_dtb>
ffffffffc0200476:	600c                	ld	a1,0(s0)
ffffffffc0200478:	00002517          	auipc	a0,0x2
ffffffffc020047c:	e9050513          	addi	a0,a0,-368 # ffffffffc0202308 <commands+0x68>
ffffffffc0200480:	c5dff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200484:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200488:	00002517          	auipc	a0,0x2
ffffffffc020048c:	e9850513          	addi	a0,a0,-360 # ffffffffc0202320 <commands+0x80>
    if (boot_dtb == 0) {
ffffffffc0200490:	120a0463          	beqz	s4,ffffffffc02005b8 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200494:	57f5                	li	a5,-3
ffffffffc0200496:	07fa                	slli	a5,a5,0x1e
ffffffffc0200498:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc020049c:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020049e:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004a2:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004a4:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02004a8:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ac:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b0:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004b4:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b8:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ba:	8ec9                	or	a3,a3,a0
ffffffffc02004bc:	0087979b          	slliw	a5,a5,0x8
ffffffffc02004c0:	1b7d                	addi	s6,s6,-1
ffffffffc02004c2:	0167f7b3          	and	a5,a5,s6
ffffffffc02004c6:	8dd5                	or	a1,a1,a3
ffffffffc02004c8:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02004ca:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ce:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02004d0:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed8a4d>
ffffffffc02004d4:	10f59163          	bne	a1,a5,ffffffffc02005d6 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02004d8:	471c                	lw	a5,8(a4)
ffffffffc02004da:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02004dc:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004de:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02004e2:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02004e6:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ea:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004ee:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004f2:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f6:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004fa:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004fe:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200502:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200506:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200508:	01146433          	or	s0,s0,a7
ffffffffc020050c:	0086969b          	slliw	a3,a3,0x8
ffffffffc0200510:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200514:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200516:	0087979b          	slliw	a5,a5,0x8
ffffffffc020051a:	8c49                	or	s0,s0,a0
ffffffffc020051c:	0166f6b3          	and	a3,a3,s6
ffffffffc0200520:	00ca6a33          	or	s4,s4,a2
ffffffffc0200524:	0167f7b3          	and	a5,a5,s6
ffffffffc0200528:	8c55                	or	s0,s0,a3
ffffffffc020052a:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020052e:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200530:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200532:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200534:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200538:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020053a:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020053c:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc0200540:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200542:	00002917          	auipc	s2,0x2
ffffffffc0200546:	e2e90913          	addi	s2,s2,-466 # ffffffffc0202370 <commands+0xd0>
ffffffffc020054a:	49bd                	li	s3,15
        switch (token) {
ffffffffc020054c:	4d91                	li	s11,4
ffffffffc020054e:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200550:	00002497          	auipc	s1,0x2
ffffffffc0200554:	e1848493          	addi	s1,s1,-488 # ffffffffc0202368 <commands+0xc8>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200558:	000a2703          	lw	a4,0(s4)
ffffffffc020055c:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200560:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200564:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200568:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020056c:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200570:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200574:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200576:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020057a:	0087171b          	slliw	a4,a4,0x8
ffffffffc020057e:	8fd5                	or	a5,a5,a3
ffffffffc0200580:	00eb7733          	and	a4,s6,a4
ffffffffc0200584:	8fd9                	or	a5,a5,a4
ffffffffc0200586:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200588:	09778c63          	beq	a5,s7,ffffffffc0200620 <dtb_init+0x1ee>
ffffffffc020058c:	00fbea63          	bltu	s7,a5,ffffffffc02005a0 <dtb_init+0x16e>
ffffffffc0200590:	07a78663          	beq	a5,s10,ffffffffc02005fc <dtb_init+0x1ca>
ffffffffc0200594:	4709                	li	a4,2
ffffffffc0200596:	00e79763          	bne	a5,a4,ffffffffc02005a4 <dtb_init+0x172>
ffffffffc020059a:	4c81                	li	s9,0
ffffffffc020059c:	8a56                	mv	s4,s5
ffffffffc020059e:	bf6d                	j	ffffffffc0200558 <dtb_init+0x126>
ffffffffc02005a0:	ffb78ee3          	beq	a5,s11,ffffffffc020059c <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc02005a4:	00002517          	auipc	a0,0x2
ffffffffc02005a8:	e4450513          	addi	a0,a0,-444 # ffffffffc02023e8 <commands+0x148>
ffffffffc02005ac:	b31ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02005b0:	00002517          	auipc	a0,0x2
ffffffffc02005b4:	e7050513          	addi	a0,a0,-400 # ffffffffc0202420 <commands+0x180>
}
ffffffffc02005b8:	7446                	ld	s0,112(sp)
ffffffffc02005ba:	70e6                	ld	ra,120(sp)
ffffffffc02005bc:	74a6                	ld	s1,104(sp)
ffffffffc02005be:	7906                	ld	s2,96(sp)
ffffffffc02005c0:	69e6                	ld	s3,88(sp)
ffffffffc02005c2:	6a46                	ld	s4,80(sp)
ffffffffc02005c4:	6aa6                	ld	s5,72(sp)
ffffffffc02005c6:	6b06                	ld	s6,64(sp)
ffffffffc02005c8:	7be2                	ld	s7,56(sp)
ffffffffc02005ca:	7c42                	ld	s8,48(sp)
ffffffffc02005cc:	7ca2                	ld	s9,40(sp)
ffffffffc02005ce:	7d02                	ld	s10,32(sp)
ffffffffc02005d0:	6de2                	ld	s11,24(sp)
ffffffffc02005d2:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02005d4:	b621                	j	ffffffffc02000dc <cprintf>
}
ffffffffc02005d6:	7446                	ld	s0,112(sp)
ffffffffc02005d8:	70e6                	ld	ra,120(sp)
ffffffffc02005da:	74a6                	ld	s1,104(sp)
ffffffffc02005dc:	7906                	ld	s2,96(sp)
ffffffffc02005de:	69e6                	ld	s3,88(sp)
ffffffffc02005e0:	6a46                	ld	s4,80(sp)
ffffffffc02005e2:	6aa6                	ld	s5,72(sp)
ffffffffc02005e4:	6b06                	ld	s6,64(sp)
ffffffffc02005e6:	7be2                	ld	s7,56(sp)
ffffffffc02005e8:	7c42                	ld	s8,48(sp)
ffffffffc02005ea:	7ca2                	ld	s9,40(sp)
ffffffffc02005ec:	7d02                	ld	s10,32(sp)
ffffffffc02005ee:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02005f0:	00002517          	auipc	a0,0x2
ffffffffc02005f4:	d5050513          	addi	a0,a0,-688 # ffffffffc0202340 <commands+0xa0>
}
ffffffffc02005f8:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02005fa:	b4cd                	j	ffffffffc02000dc <cprintf>
                int name_len = strlen(name);
ffffffffc02005fc:	8556                	mv	a0,s5
ffffffffc02005fe:	462010ef          	jal	ra,ffffffffc0201a60 <strlen>
ffffffffc0200602:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200604:	4619                	li	a2,6
ffffffffc0200606:	85a6                	mv	a1,s1
ffffffffc0200608:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc020060a:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020060c:	4a8010ef          	jal	ra,ffffffffc0201ab4 <strncmp>
ffffffffc0200610:	e111                	bnez	a0,ffffffffc0200614 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200612:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200614:	0a91                	addi	s5,s5,4
ffffffffc0200616:	9ad2                	add	s5,s5,s4
ffffffffc0200618:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020061c:	8a56                	mv	s4,s5
ffffffffc020061e:	bf2d                	j	ffffffffc0200558 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200620:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200624:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200628:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020062c:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200630:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200634:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200638:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020063c:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200640:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200644:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200648:	00eaeab3          	or	s5,s5,a4
ffffffffc020064c:	00fb77b3          	and	a5,s6,a5
ffffffffc0200650:	00faeab3          	or	s5,s5,a5
ffffffffc0200654:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200656:	000c9c63          	bnez	s9,ffffffffc020066e <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc020065a:	1a82                	slli	s5,s5,0x20
ffffffffc020065c:	00368793          	addi	a5,a3,3
ffffffffc0200660:	020ada93          	srli	s5,s5,0x20
ffffffffc0200664:	9abe                	add	s5,s5,a5
ffffffffc0200666:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020066a:	8a56                	mv	s4,s5
ffffffffc020066c:	b5f5                	j	ffffffffc0200558 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020066e:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200672:	85ca                	mv	a1,s2
ffffffffc0200674:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200676:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020067a:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020067e:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200682:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200686:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020068a:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020068c:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200690:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200694:	8d59                	or	a0,a0,a4
ffffffffc0200696:	00fb77b3          	and	a5,s6,a5
ffffffffc020069a:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc020069c:	1502                	slli	a0,a0,0x20
ffffffffc020069e:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006a0:	9522                	add	a0,a0,s0
ffffffffc02006a2:	3f4010ef          	jal	ra,ffffffffc0201a96 <strcmp>
ffffffffc02006a6:	66a2                	ld	a3,8(sp)
ffffffffc02006a8:	f94d                	bnez	a0,ffffffffc020065a <dtb_init+0x228>
ffffffffc02006aa:	fb59f8e3          	bgeu	s3,s5,ffffffffc020065a <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02006ae:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02006b2:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02006b6:	00002517          	auipc	a0,0x2
ffffffffc02006ba:	cc250513          	addi	a0,a0,-830 # ffffffffc0202378 <commands+0xd8>
           fdt32_to_cpu(x >> 32);
ffffffffc02006be:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c2:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02006c6:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ca:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02006ce:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d2:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006d6:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006da:	0187d693          	srli	a3,a5,0x18
ffffffffc02006de:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02006e2:	0087579b          	srliw	a5,a4,0x8
ffffffffc02006e6:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ea:	0106561b          	srliw	a2,a2,0x10
ffffffffc02006ee:	010f6f33          	or	t5,t5,a6
ffffffffc02006f2:	0187529b          	srliw	t0,a4,0x18
ffffffffc02006f6:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006fa:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006fe:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200702:	0186f6b3          	and	a3,a3,s8
ffffffffc0200706:	01859e1b          	slliw	t3,a1,0x18
ffffffffc020070a:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020070e:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200712:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200716:	8361                	srli	a4,a4,0x18
ffffffffc0200718:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020071c:	0105d59b          	srliw	a1,a1,0x10
ffffffffc0200720:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200724:	00cb7633          	and	a2,s6,a2
ffffffffc0200728:	0088181b          	slliw	a6,a6,0x8
ffffffffc020072c:	0085959b          	slliw	a1,a1,0x8
ffffffffc0200730:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200734:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200738:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020073c:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200740:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200744:	011b78b3          	and	a7,s6,a7
ffffffffc0200748:	005eeeb3          	or	t4,t4,t0
ffffffffc020074c:	00c6e733          	or	a4,a3,a2
ffffffffc0200750:	006c6c33          	or	s8,s8,t1
ffffffffc0200754:	010b76b3          	and	a3,s6,a6
ffffffffc0200758:	00bb7b33          	and	s6,s6,a1
ffffffffc020075c:	01d7e7b3          	or	a5,a5,t4
ffffffffc0200760:	016c6b33          	or	s6,s8,s6
ffffffffc0200764:	01146433          	or	s0,s0,a7
ffffffffc0200768:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc020076a:	1702                	slli	a4,a4,0x20
ffffffffc020076c:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020076e:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200770:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200772:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200774:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200778:	0167eb33          	or	s6,a5,s6
ffffffffc020077c:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020077e:	95fff0ef          	jal	ra,ffffffffc02000dc <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200782:	85a2                	mv	a1,s0
ffffffffc0200784:	00002517          	auipc	a0,0x2
ffffffffc0200788:	c1450513          	addi	a0,a0,-1004 # ffffffffc0202398 <commands+0xf8>
ffffffffc020078c:	951ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200790:	014b5613          	srli	a2,s6,0x14
ffffffffc0200794:	85da                	mv	a1,s6
ffffffffc0200796:	00002517          	auipc	a0,0x2
ffffffffc020079a:	c1a50513          	addi	a0,a0,-998 # ffffffffc02023b0 <commands+0x110>
ffffffffc020079e:	93fff0ef          	jal	ra,ffffffffc02000dc <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02007a2:	008b05b3          	add	a1,s6,s0
ffffffffc02007a6:	15fd                	addi	a1,a1,-1
ffffffffc02007a8:	00002517          	auipc	a0,0x2
ffffffffc02007ac:	c2850513          	addi	a0,a0,-984 # ffffffffc02023d0 <commands+0x130>
ffffffffc02007b0:	92dff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02007b4:	00002517          	auipc	a0,0x2
ffffffffc02007b8:	c6c50513          	addi	a0,a0,-916 # ffffffffc0202420 <commands+0x180>
        memory_base = mem_base;
ffffffffc02007bc:	00007797          	auipc	a5,0x7
ffffffffc02007c0:	c887b623          	sd	s0,-884(a5) # ffffffffc0207448 <memory_base>
        memory_size = mem_size;
ffffffffc02007c4:	00007797          	auipc	a5,0x7
ffffffffc02007c8:	c967b623          	sd	s6,-884(a5) # ffffffffc0207450 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02007cc:	b3f5                	j	ffffffffc02005b8 <dtb_init+0x186>

ffffffffc02007ce <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02007ce:	00007517          	auipc	a0,0x7
ffffffffc02007d2:	c7a53503          	ld	a0,-902(a0) # ffffffffc0207448 <memory_base>
ffffffffc02007d6:	8082                	ret

ffffffffc02007d8 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02007d8:	00007517          	auipc	a0,0x7
ffffffffc02007dc:	c7853503          	ld	a0,-904(a0) # ffffffffc0207450 <memory_size>
ffffffffc02007e0:	8082                	ret

ffffffffc02007e2 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc02007e2:	1141                	addi	sp,sp,-16
ffffffffc02007e4:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc02007e6:	02000793          	li	a5,32
ffffffffc02007ea:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02007ee:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02007f2:	67e1                	lui	a5,0x18
ffffffffc02007f4:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02007f8:	953e                	add	a0,a0,a5
ffffffffc02007fa:	7dc010ef          	jal	ra,ffffffffc0201fd6 <sbi_set_timer>
}
ffffffffc02007fe:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200800:	00007797          	auipc	a5,0x7
ffffffffc0200804:	c407bc23          	sd	zero,-936(a5) # ffffffffc0207458 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200808:	00002517          	auipc	a0,0x2
ffffffffc020080c:	c3050513          	addi	a0,a0,-976 # ffffffffc0202438 <commands+0x198>
}
ffffffffc0200810:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200812:	8cbff06f          	j	ffffffffc02000dc <cprintf>

ffffffffc0200816 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200816:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020081a:	67e1                	lui	a5,0x18
ffffffffc020081c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200820:	953e                	add	a0,a0,a5
ffffffffc0200822:	7b40106f          	j	ffffffffc0201fd6 <sbi_set_timer>

ffffffffc0200826 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200826:	8082                	ret

ffffffffc0200828 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200828:	0ff57513          	zext.b	a0,a0
ffffffffc020082c:	7900106f          	j	ffffffffc0201fbc <sbi_console_putchar>

ffffffffc0200830 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200830:	7c00106f          	j	ffffffffc0201ff0 <sbi_console_getchar>

ffffffffc0200834 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200834:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200838:	8082                	ret

ffffffffc020083a <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020083a:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020083e:	8082                	ret

ffffffffc0200840 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200840:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200844:	00000797          	auipc	a5,0x0
ffffffffc0200848:	3f878793          	addi	a5,a5,1016 # ffffffffc0200c3c <__alltraps>
ffffffffc020084c:	10579073          	csrw	stvec,a5
}
ffffffffc0200850:	8082                	ret

ffffffffc0200852 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200852:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200854:	1141                	addi	sp,sp,-16
ffffffffc0200856:	e022                	sd	s0,0(sp)
ffffffffc0200858:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020085a:	00002517          	auipc	a0,0x2
ffffffffc020085e:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0202458 <commands+0x1b8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200862:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200864:	879ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200868:	640c                	ld	a1,8(s0)
ffffffffc020086a:	00002517          	auipc	a0,0x2
ffffffffc020086e:	c0650513          	addi	a0,a0,-1018 # ffffffffc0202470 <commands+0x1d0>
ffffffffc0200872:	86bff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200876:	680c                	ld	a1,16(s0)
ffffffffc0200878:	00002517          	auipc	a0,0x2
ffffffffc020087c:	c1050513          	addi	a0,a0,-1008 # ffffffffc0202488 <commands+0x1e8>
ffffffffc0200880:	85dff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200884:	6c0c                	ld	a1,24(s0)
ffffffffc0200886:	00002517          	auipc	a0,0x2
ffffffffc020088a:	c1a50513          	addi	a0,a0,-998 # ffffffffc02024a0 <commands+0x200>
ffffffffc020088e:	84fff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200892:	700c                	ld	a1,32(s0)
ffffffffc0200894:	00002517          	auipc	a0,0x2
ffffffffc0200898:	c2450513          	addi	a0,a0,-988 # ffffffffc02024b8 <commands+0x218>
ffffffffc020089c:	841ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02008a0:	740c                	ld	a1,40(s0)
ffffffffc02008a2:	00002517          	auipc	a0,0x2
ffffffffc02008a6:	c2e50513          	addi	a0,a0,-978 # ffffffffc02024d0 <commands+0x230>
ffffffffc02008aa:	833ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02008ae:	780c                	ld	a1,48(s0)
ffffffffc02008b0:	00002517          	auipc	a0,0x2
ffffffffc02008b4:	c3850513          	addi	a0,a0,-968 # ffffffffc02024e8 <commands+0x248>
ffffffffc02008b8:	825ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02008bc:	7c0c                	ld	a1,56(s0)
ffffffffc02008be:	00002517          	auipc	a0,0x2
ffffffffc02008c2:	c4250513          	addi	a0,a0,-958 # ffffffffc0202500 <commands+0x260>
ffffffffc02008c6:	817ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02008ca:	602c                	ld	a1,64(s0)
ffffffffc02008cc:	00002517          	auipc	a0,0x2
ffffffffc02008d0:	c4c50513          	addi	a0,a0,-948 # ffffffffc0202518 <commands+0x278>
ffffffffc02008d4:	809ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02008d8:	642c                	ld	a1,72(s0)
ffffffffc02008da:	00002517          	auipc	a0,0x2
ffffffffc02008de:	c5650513          	addi	a0,a0,-938 # ffffffffc0202530 <commands+0x290>
ffffffffc02008e2:	ffaff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02008e6:	682c                	ld	a1,80(s0)
ffffffffc02008e8:	00002517          	auipc	a0,0x2
ffffffffc02008ec:	c6050513          	addi	a0,a0,-928 # ffffffffc0202548 <commands+0x2a8>
ffffffffc02008f0:	fecff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02008f4:	6c2c                	ld	a1,88(s0)
ffffffffc02008f6:	00002517          	auipc	a0,0x2
ffffffffc02008fa:	c6a50513          	addi	a0,a0,-918 # ffffffffc0202560 <commands+0x2c0>
ffffffffc02008fe:	fdeff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200902:	702c                	ld	a1,96(s0)
ffffffffc0200904:	00002517          	auipc	a0,0x2
ffffffffc0200908:	c7450513          	addi	a0,a0,-908 # ffffffffc0202578 <commands+0x2d8>
ffffffffc020090c:	fd0ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200910:	742c                	ld	a1,104(s0)
ffffffffc0200912:	00002517          	auipc	a0,0x2
ffffffffc0200916:	c7e50513          	addi	a0,a0,-898 # ffffffffc0202590 <commands+0x2f0>
ffffffffc020091a:	fc2ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020091e:	782c                	ld	a1,112(s0)
ffffffffc0200920:	00002517          	auipc	a0,0x2
ffffffffc0200924:	c8850513          	addi	a0,a0,-888 # ffffffffc02025a8 <commands+0x308>
ffffffffc0200928:	fb4ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020092c:	7c2c                	ld	a1,120(s0)
ffffffffc020092e:	00002517          	auipc	a0,0x2
ffffffffc0200932:	c9250513          	addi	a0,a0,-878 # ffffffffc02025c0 <commands+0x320>
ffffffffc0200936:	fa6ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020093a:	604c                	ld	a1,128(s0)
ffffffffc020093c:	00002517          	auipc	a0,0x2
ffffffffc0200940:	c9c50513          	addi	a0,a0,-868 # ffffffffc02025d8 <commands+0x338>
ffffffffc0200944:	f98ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200948:	644c                	ld	a1,136(s0)
ffffffffc020094a:	00002517          	auipc	a0,0x2
ffffffffc020094e:	ca650513          	addi	a0,a0,-858 # ffffffffc02025f0 <commands+0x350>
ffffffffc0200952:	f8aff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200956:	684c                	ld	a1,144(s0)
ffffffffc0200958:	00002517          	auipc	a0,0x2
ffffffffc020095c:	cb050513          	addi	a0,a0,-848 # ffffffffc0202608 <commands+0x368>
ffffffffc0200960:	f7cff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200964:	6c4c                	ld	a1,152(s0)
ffffffffc0200966:	00002517          	auipc	a0,0x2
ffffffffc020096a:	cba50513          	addi	a0,a0,-838 # ffffffffc0202620 <commands+0x380>
ffffffffc020096e:	f6eff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200972:	704c                	ld	a1,160(s0)
ffffffffc0200974:	00002517          	auipc	a0,0x2
ffffffffc0200978:	cc450513          	addi	a0,a0,-828 # ffffffffc0202638 <commands+0x398>
ffffffffc020097c:	f60ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200980:	744c                	ld	a1,168(s0)
ffffffffc0200982:	00002517          	auipc	a0,0x2
ffffffffc0200986:	cce50513          	addi	a0,a0,-818 # ffffffffc0202650 <commands+0x3b0>
ffffffffc020098a:	f52ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020098e:	784c                	ld	a1,176(s0)
ffffffffc0200990:	00002517          	auipc	a0,0x2
ffffffffc0200994:	cd850513          	addi	a0,a0,-808 # ffffffffc0202668 <commands+0x3c8>
ffffffffc0200998:	f44ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020099c:	7c4c                	ld	a1,184(s0)
ffffffffc020099e:	00002517          	auipc	a0,0x2
ffffffffc02009a2:	ce250513          	addi	a0,a0,-798 # ffffffffc0202680 <commands+0x3e0>
ffffffffc02009a6:	f36ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02009aa:	606c                	ld	a1,192(s0)
ffffffffc02009ac:	00002517          	auipc	a0,0x2
ffffffffc02009b0:	cec50513          	addi	a0,a0,-788 # ffffffffc0202698 <commands+0x3f8>
ffffffffc02009b4:	f28ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02009b8:	646c                	ld	a1,200(s0)
ffffffffc02009ba:	00002517          	auipc	a0,0x2
ffffffffc02009be:	cf650513          	addi	a0,a0,-778 # ffffffffc02026b0 <commands+0x410>
ffffffffc02009c2:	f1aff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02009c6:	686c                	ld	a1,208(s0)
ffffffffc02009c8:	00002517          	auipc	a0,0x2
ffffffffc02009cc:	d0050513          	addi	a0,a0,-768 # ffffffffc02026c8 <commands+0x428>
ffffffffc02009d0:	f0cff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02009d4:	6c6c                	ld	a1,216(s0)
ffffffffc02009d6:	00002517          	auipc	a0,0x2
ffffffffc02009da:	d0a50513          	addi	a0,a0,-758 # ffffffffc02026e0 <commands+0x440>
ffffffffc02009de:	efeff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02009e2:	706c                	ld	a1,224(s0)
ffffffffc02009e4:	00002517          	auipc	a0,0x2
ffffffffc02009e8:	d1450513          	addi	a0,a0,-748 # ffffffffc02026f8 <commands+0x458>
ffffffffc02009ec:	ef0ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02009f0:	746c                	ld	a1,232(s0)
ffffffffc02009f2:	00002517          	auipc	a0,0x2
ffffffffc02009f6:	d1e50513          	addi	a0,a0,-738 # ffffffffc0202710 <commands+0x470>
ffffffffc02009fa:	ee2ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02009fe:	786c                	ld	a1,240(s0)
ffffffffc0200a00:	00002517          	auipc	a0,0x2
ffffffffc0200a04:	d2850513          	addi	a0,a0,-728 # ffffffffc0202728 <commands+0x488>
ffffffffc0200a08:	ed4ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a0c:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200a0e:	6402                	ld	s0,0(sp)
ffffffffc0200a10:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a12:	00002517          	auipc	a0,0x2
ffffffffc0200a16:	d2e50513          	addi	a0,a0,-722 # ffffffffc0202740 <commands+0x4a0>
}
ffffffffc0200a1a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a1c:	ec0ff06f          	j	ffffffffc02000dc <cprintf>

ffffffffc0200a20 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a20:	1141                	addi	sp,sp,-16
ffffffffc0200a22:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a24:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a26:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a28:	00002517          	auipc	a0,0x2
ffffffffc0200a2c:	d3050513          	addi	a0,a0,-720 # ffffffffc0202758 <commands+0x4b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a30:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a32:	eaaff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200a36:	8522                	mv	a0,s0
ffffffffc0200a38:	e1bff0ef          	jal	ra,ffffffffc0200852 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200a3c:	10043583          	ld	a1,256(s0)
ffffffffc0200a40:	00002517          	auipc	a0,0x2
ffffffffc0200a44:	d3050513          	addi	a0,a0,-720 # ffffffffc0202770 <commands+0x4d0>
ffffffffc0200a48:	e94ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200a4c:	10843583          	ld	a1,264(s0)
ffffffffc0200a50:	00002517          	auipc	a0,0x2
ffffffffc0200a54:	d3850513          	addi	a0,a0,-712 # ffffffffc0202788 <commands+0x4e8>
ffffffffc0200a58:	e84ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200a5c:	11043583          	ld	a1,272(s0)
ffffffffc0200a60:	00002517          	auipc	a0,0x2
ffffffffc0200a64:	d4050513          	addi	a0,a0,-704 # ffffffffc02027a0 <commands+0x500>
ffffffffc0200a68:	e74ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200a6c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200a70:	6402                	ld	s0,0(sp)
ffffffffc0200a72:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200a74:	00002517          	auipc	a0,0x2
ffffffffc0200a78:	d4450513          	addi	a0,a0,-700 # ffffffffc02027b8 <commands+0x518>
}
ffffffffc0200a7c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200a7e:	e5eff06f          	j	ffffffffc02000dc <cprintf>

ffffffffc0200a82 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    static int ticks = 0;
    static int print_num = 0;
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200a82:	11853783          	ld	a5,280(a0)
ffffffffc0200a86:	472d                	li	a4,11
ffffffffc0200a88:	0786                	slli	a5,a5,0x1
ffffffffc0200a8a:	8385                	srli	a5,a5,0x1
ffffffffc0200a8c:	08f76263          	bltu	a4,a5,ffffffffc0200b10 <interrupt_handler+0x8e>
ffffffffc0200a90:	00002717          	auipc	a4,0x2
ffffffffc0200a94:	e0870713          	addi	a4,a4,-504 # ffffffffc0202898 <commands+0x5f8>
ffffffffc0200a98:	078a                	slli	a5,a5,0x2
ffffffffc0200a9a:	97ba                	add	a5,a5,a4
ffffffffc0200a9c:	439c                	lw	a5,0(a5)
ffffffffc0200a9e:	97ba                	add	a5,a5,a4
ffffffffc0200aa0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc0200aa2:	00002517          	auipc	a0,0x2
ffffffffc0200aa6:	d8e50513          	addi	a0,a0,-626 # ffffffffc0202830 <commands+0x590>
ffffffffc0200aaa:	e32ff06f          	j	ffffffffc02000dc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc0200aae:	00002517          	auipc	a0,0x2
ffffffffc0200ab2:	d6250513          	addi	a0,a0,-670 # ffffffffc0202810 <commands+0x570>
ffffffffc0200ab6:	e26ff06f          	j	ffffffffc02000dc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200aba:	00002517          	auipc	a0,0x2
ffffffffc0200abe:	d1650513          	addi	a0,a0,-746 # ffffffffc02027d0 <commands+0x530>
ffffffffc0200ac2:	e1aff06f          	j	ffffffffc02000dc <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc0200ac6:	00002517          	auipc	a0,0x2
ffffffffc0200aca:	d8a50513          	addi	a0,a0,-630 # ffffffffc0202850 <commands+0x5b0>
ffffffffc0200ace:	e0eff06f          	j	ffffffffc02000dc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200ad2:	1141                	addi	sp,sp,-16
ffffffffc0200ad4:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
ffffffffc0200ad6:	d41ff0ef          	jal	ra,ffffffffc0200816 <clock_set_next_event>
            ticks++;
ffffffffc0200ada:	00007697          	auipc	a3,0x7
ffffffffc0200ade:	98a68693          	addi	a3,a3,-1654 # ffffffffc0207464 <ticks.1>
ffffffffc0200ae2:	429c                	lw	a5,0(a3)
            if (ticks % TICK_NUM == 0) {
ffffffffc0200ae4:	06400713          	li	a4,100
            ticks++;
ffffffffc0200ae8:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0) {
ffffffffc0200aea:	02e7e73b          	remw	a4,a5,a4
            ticks++;
ffffffffc0200aee:	c29c                	sw	a5,0(a3)
            if (ticks % TICK_NUM == 0) {
ffffffffc0200af0:	c30d                	beqz	a4,ffffffffc0200b12 <interrupt_handler+0x90>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200af2:	60a2                	ld	ra,8(sp)
ffffffffc0200af4:	0141                	addi	sp,sp,16
ffffffffc0200af6:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200af8:	00002517          	auipc	a0,0x2
ffffffffc0200afc:	d8050513          	addi	a0,a0,-640 # ffffffffc0202878 <commands+0x5d8>
ffffffffc0200b00:	ddcff06f          	j	ffffffffc02000dc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200b04:	00002517          	auipc	a0,0x2
ffffffffc0200b08:	cec50513          	addi	a0,a0,-788 # ffffffffc02027f0 <commands+0x550>
ffffffffc0200b0c:	dd0ff06f          	j	ffffffffc02000dc <cprintf>
            print_trapframe(tf);
ffffffffc0200b10:	bf01                	j	ffffffffc0200a20 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200b12:	06400593          	li	a1,100
ffffffffc0200b16:	00002517          	auipc	a0,0x2
ffffffffc0200b1a:	d5250513          	addi	a0,a0,-686 # ffffffffc0202868 <commands+0x5c8>
ffffffffc0200b1e:	dbeff0ef          	jal	ra,ffffffffc02000dc <cprintf>
                print_num++;
ffffffffc0200b22:	00007717          	auipc	a4,0x7
ffffffffc0200b26:	93e70713          	addi	a4,a4,-1730 # ffffffffc0207460 <print_num.0>
ffffffffc0200b2a:	431c                	lw	a5,0(a4)
                if (print_num == 10) {
ffffffffc0200b2c:	46a9                	li	a3,10
                print_num++;
ffffffffc0200b2e:	0017861b          	addiw	a2,a5,1
ffffffffc0200b32:	c310                	sw	a2,0(a4)
                if (print_num == 10) {
ffffffffc0200b34:	fad61fe3          	bne	a2,a3,ffffffffc0200af2 <interrupt_handler+0x70>
}
ffffffffc0200b38:	60a2                	ld	ra,8(sp)
ffffffffc0200b3a:	0141                	addi	sp,sp,16
                    sbi_shutdown();
ffffffffc0200b3c:	4d00106f          	j	ffffffffc020200c <sbi_shutdown>

ffffffffc0200b40 <exception_handler>:
    uint16_t half;
    memcpy(&half, (void *)epc, sizeof(half));
    return (half & 0x3) != 0x3 ? 2 : 4;
}

void exception_handler(struct trapframe *tf) {
ffffffffc0200b40:	7179                	addi	sp,sp,-48
ffffffffc0200b42:	ec26                	sd	s1,24(sp)
    switch (tf->cause) {
ffffffffc0200b44:	11853483          	ld	s1,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200b48:	f406                	sd	ra,40(sp)
ffffffffc0200b4a:	f022                	sd	s0,32(sp)
ffffffffc0200b4c:	47ad                	li	a5,11
ffffffffc0200b4e:	0697ee63          	bltu	a5,s1,ffffffffc0200bca <exception_handler+0x8a>
ffffffffc0200b52:	00002697          	auipc	a3,0x2
ffffffffc0200b56:	e4268693          	addi	a3,a3,-446 # ffffffffc0202994 <commands+0x6f4>
ffffffffc0200b5a:	00249713          	slli	a4,s1,0x2
ffffffffc0200b5e:	9736                	add	a4,a4,a3
ffffffffc0200b60:	431c                	lw	a5,0(a4)
ffffffffc0200b62:	842a                	mv	s0,a0
ffffffffc0200b64:	97b6                	add	a5,a5,a3
ffffffffc0200b66:	8782                	jr	a5
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            // 避免递归打印，这里只打印一行简讯
            cprintf("Illegal instruction at sepc=%p\n", tf->epc);
ffffffffc0200b68:	10853583          	ld	a1,264(a0)
ffffffffc0200b6c:	00002517          	auipc	a0,0x2
ffffffffc0200b70:	d5c50513          	addi	a0,a0,-676 # ffffffffc02028c8 <commands+0x628>
ffffffffc0200b74:	d68ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    memcpy(&half, (void *)epc, sizeof(half));
ffffffffc0200b78:	10843583          	ld	a1,264(s0)
ffffffffc0200b7c:	4609                	li	a2,2
ffffffffc0200b7e:	00e10513          	addi	a0,sp,14
ffffffffc0200b82:	781000ef          	jal	ra,ffffffffc0201b02 <memcpy>
    return (half & 0x3) != 0x3 ? 2 : 4;
ffffffffc0200b86:	00e15783          	lhu	a5,14(sp)
ffffffffc0200b8a:	470d                	li	a4,3
ffffffffc0200b8c:	8b8d                	andi	a5,a5,3
ffffffffc0200b8e:	04e78363          	beq	a5,a4,ffffffffc0200bd4 <exception_handler+0x94>
            tf->epc += insn_len(tf->epc);
ffffffffc0200b92:	10843783          	ld	a5,264(s0)
ffffffffc0200b96:	94be                	add	s1,s1,a5
ffffffffc0200b98:	10943423          	sd	s1,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200b9c:	70a2                	ld	ra,40(sp)
ffffffffc0200b9e:	7402                	ld	s0,32(sp)
ffffffffc0200ba0:	64e2                	ld	s1,24(sp)
ffffffffc0200ba2:	6145                	addi	sp,sp,48
ffffffffc0200ba4:	8082                	ret
            cprintf("Breakpoint at sepc=%p\n", tf->epc);
ffffffffc0200ba6:	10853583          	ld	a1,264(a0)
ffffffffc0200baa:	00002517          	auipc	a0,0x2
ffffffffc0200bae:	d3e50513          	addi	a0,a0,-706 # ffffffffc02028e8 <commands+0x648>
ffffffffc0200bb2:	d2aff0ef          	jal	ra,ffffffffc02000dc <cprintf>
            tf->epc += 4;
ffffffffc0200bb6:	10843783          	ld	a5,264(s0)
}
ffffffffc0200bba:	70a2                	ld	ra,40(sp)
ffffffffc0200bbc:	64e2                	ld	s1,24(sp)
            tf->epc += 4;
ffffffffc0200bbe:	0791                	addi	a5,a5,4
ffffffffc0200bc0:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200bc4:	7402                	ld	s0,32(sp)
ffffffffc0200bc6:	6145                	addi	sp,sp,48
ffffffffc0200bc8:	8082                	ret
ffffffffc0200bca:	7402                	ld	s0,32(sp)
ffffffffc0200bcc:	70a2                	ld	ra,40(sp)
ffffffffc0200bce:	64e2                	ld	s1,24(sp)
ffffffffc0200bd0:	6145                	addi	sp,sp,48
            print_trapframe(tf);
ffffffffc0200bd2:	b5b9                	j	ffffffffc0200a20 <print_trapframe>
    return (half & 0x3) != 0x3 ? 2 : 4;
ffffffffc0200bd4:	4491                	li	s1,4
ffffffffc0200bd6:	bf75                	j	ffffffffc0200b92 <exception_handler+0x52>
            cprintf("Load page fault: sepc=%p stval=%p\n", tf->epc, tf->badvaddr);
ffffffffc0200bd8:	11053603          	ld	a2,272(a0)
ffffffffc0200bdc:	10853583          	ld	a1,264(a0)
ffffffffc0200be0:	00002517          	auipc	a0,0x2
ffffffffc0200be4:	d2050513          	addi	a0,a0,-736 # ffffffffc0202900 <commands+0x660>
ffffffffc0200be8:	cf4ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
            panic("kernel load fault");
ffffffffc0200bec:	00002617          	auipc	a2,0x2
ffffffffc0200bf0:	d3c60613          	addi	a2,a2,-708 # ffffffffc0202928 <commands+0x688>
ffffffffc0200bf4:	0d600593          	li	a1,214
ffffffffc0200bf8:	00002517          	auipc	a0,0x2
ffffffffc0200bfc:	d4850513          	addi	a0,a0,-696 # ffffffffc0202940 <commands+0x6a0>
ffffffffc0200c00:	d64ff0ef          	jal	ra,ffffffffc0200164 <__panic>
            cprintf("Store page fault: sepc=%p stval=%p\n", tf->epc, tf->badvaddr);
ffffffffc0200c04:	11053603          	ld	a2,272(a0)
ffffffffc0200c08:	10853583          	ld	a1,264(a0)
ffffffffc0200c0c:	00002517          	auipc	a0,0x2
ffffffffc0200c10:	d4c50513          	addi	a0,a0,-692 # ffffffffc0202958 <commands+0x6b8>
ffffffffc0200c14:	cc8ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
            panic("kernel store fault");
ffffffffc0200c18:	00002617          	auipc	a2,0x2
ffffffffc0200c1c:	d6860613          	addi	a2,a2,-664 # ffffffffc0202980 <commands+0x6e0>
ffffffffc0200c20:	0db00593          	li	a1,219
ffffffffc0200c24:	00002517          	auipc	a0,0x2
ffffffffc0200c28:	d1c50513          	addi	a0,a0,-740 # ffffffffc0202940 <commands+0x6a0>
ffffffffc0200c2c:	d38ff0ef          	jal	ra,ffffffffc0200164 <__panic>

ffffffffc0200c30 <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c30:	11853783          	ld	a5,280(a0)
ffffffffc0200c34:	0007c363          	bltz	a5,ffffffffc0200c3a <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200c38:	b721                	j	ffffffffc0200b40 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200c3a:	b5a1                	j	ffffffffc0200a82 <interrupt_handler>

ffffffffc0200c3c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200c3c:	14011073          	csrw	sscratch,sp
ffffffffc0200c40:	712d                	addi	sp,sp,-288
ffffffffc0200c42:	e002                	sd	zero,0(sp)
ffffffffc0200c44:	e406                	sd	ra,8(sp)
ffffffffc0200c46:	ec0e                	sd	gp,24(sp)
ffffffffc0200c48:	f012                	sd	tp,32(sp)
ffffffffc0200c4a:	f416                	sd	t0,40(sp)
ffffffffc0200c4c:	f81a                	sd	t1,48(sp)
ffffffffc0200c4e:	fc1e                	sd	t2,56(sp)
ffffffffc0200c50:	e0a2                	sd	s0,64(sp)
ffffffffc0200c52:	e4a6                	sd	s1,72(sp)
ffffffffc0200c54:	e8aa                	sd	a0,80(sp)
ffffffffc0200c56:	ecae                	sd	a1,88(sp)
ffffffffc0200c58:	f0b2                	sd	a2,96(sp)
ffffffffc0200c5a:	f4b6                	sd	a3,104(sp)
ffffffffc0200c5c:	f8ba                	sd	a4,112(sp)
ffffffffc0200c5e:	fcbe                	sd	a5,120(sp)
ffffffffc0200c60:	e142                	sd	a6,128(sp)
ffffffffc0200c62:	e546                	sd	a7,136(sp)
ffffffffc0200c64:	e94a                	sd	s2,144(sp)
ffffffffc0200c66:	ed4e                	sd	s3,152(sp)
ffffffffc0200c68:	f152                	sd	s4,160(sp)
ffffffffc0200c6a:	f556                	sd	s5,168(sp)
ffffffffc0200c6c:	f95a                	sd	s6,176(sp)
ffffffffc0200c6e:	fd5e                	sd	s7,184(sp)
ffffffffc0200c70:	e1e2                	sd	s8,192(sp)
ffffffffc0200c72:	e5e6                	sd	s9,200(sp)
ffffffffc0200c74:	e9ea                	sd	s10,208(sp)
ffffffffc0200c76:	edee                	sd	s11,216(sp)
ffffffffc0200c78:	f1f2                	sd	t3,224(sp)
ffffffffc0200c7a:	f5f6                	sd	t4,232(sp)
ffffffffc0200c7c:	f9fa                	sd	t5,240(sp)
ffffffffc0200c7e:	fdfe                	sd	t6,248(sp)
ffffffffc0200c80:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200c84:	100024f3          	csrr	s1,sstatus
ffffffffc0200c88:	14102973          	csrr	s2,sepc
ffffffffc0200c8c:	143029f3          	csrr	s3,stval
ffffffffc0200c90:	14202a73          	csrr	s4,scause
ffffffffc0200c94:	e822                	sd	s0,16(sp)
ffffffffc0200c96:	e226                	sd	s1,256(sp)
ffffffffc0200c98:	e64a                	sd	s2,264(sp)
ffffffffc0200c9a:	ea4e                	sd	s3,272(sp)
ffffffffc0200c9c:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200c9e:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ca0:	f91ff0ef          	jal	ra,ffffffffc0200c30 <trap>

ffffffffc0200ca4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ca4:	6492                	ld	s1,256(sp)
ffffffffc0200ca6:	6932                	ld	s2,264(sp)
ffffffffc0200ca8:	10049073          	csrw	sstatus,s1
ffffffffc0200cac:	14191073          	csrw	sepc,s2
ffffffffc0200cb0:	60a2                	ld	ra,8(sp)
ffffffffc0200cb2:	61e2                	ld	gp,24(sp)
ffffffffc0200cb4:	7202                	ld	tp,32(sp)
ffffffffc0200cb6:	72a2                	ld	t0,40(sp)
ffffffffc0200cb8:	7342                	ld	t1,48(sp)
ffffffffc0200cba:	73e2                	ld	t2,56(sp)
ffffffffc0200cbc:	6406                	ld	s0,64(sp)
ffffffffc0200cbe:	64a6                	ld	s1,72(sp)
ffffffffc0200cc0:	6546                	ld	a0,80(sp)
ffffffffc0200cc2:	65e6                	ld	a1,88(sp)
ffffffffc0200cc4:	7606                	ld	a2,96(sp)
ffffffffc0200cc6:	76a6                	ld	a3,104(sp)
ffffffffc0200cc8:	7746                	ld	a4,112(sp)
ffffffffc0200cca:	77e6                	ld	a5,120(sp)
ffffffffc0200ccc:	680a                	ld	a6,128(sp)
ffffffffc0200cce:	68aa                	ld	a7,136(sp)
ffffffffc0200cd0:	694a                	ld	s2,144(sp)
ffffffffc0200cd2:	69ea                	ld	s3,152(sp)
ffffffffc0200cd4:	7a0a                	ld	s4,160(sp)
ffffffffc0200cd6:	7aaa                	ld	s5,168(sp)
ffffffffc0200cd8:	7b4a                	ld	s6,176(sp)
ffffffffc0200cda:	7bea                	ld	s7,184(sp)
ffffffffc0200cdc:	6c0e                	ld	s8,192(sp)
ffffffffc0200cde:	6cae                	ld	s9,200(sp)
ffffffffc0200ce0:	6d4e                	ld	s10,208(sp)
ffffffffc0200ce2:	6dee                	ld	s11,216(sp)
ffffffffc0200ce4:	7e0e                	ld	t3,224(sp)
ffffffffc0200ce6:	7eae                	ld	t4,232(sp)
ffffffffc0200ce8:	7f4e                	ld	t5,240(sp)
ffffffffc0200cea:	7fee                	ld	t6,248(sp)
ffffffffc0200cec:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200cee:	10200073          	sret

ffffffffc0200cf2 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200cf2:	100027f3          	csrr	a5,sstatus
ffffffffc0200cf6:	8b89                	andi	a5,a5,2
ffffffffc0200cf8:	e799                	bnez	a5,ffffffffc0200d06 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200cfa:	00006797          	auipc	a5,0x6
ffffffffc0200cfe:	77e7b783          	ld	a5,1918(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200d02:	6f9c                	ld	a5,24(a5)
ffffffffc0200d04:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200d06:	1141                	addi	sp,sp,-16
ffffffffc0200d08:	e406                	sd	ra,8(sp)
ffffffffc0200d0a:	e022                	sd	s0,0(sp)
ffffffffc0200d0c:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200d0e:	b2dff0ef          	jal	ra,ffffffffc020083a <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200d12:	00006797          	auipc	a5,0x6
ffffffffc0200d16:	7667b783          	ld	a5,1894(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200d1a:	6f9c                	ld	a5,24(a5)
ffffffffc0200d1c:	8522                	mv	a0,s0
ffffffffc0200d1e:	9782                	jalr	a5
ffffffffc0200d20:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200d22:	b13ff0ef          	jal	ra,ffffffffc0200834 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200d26:	60a2                	ld	ra,8(sp)
ffffffffc0200d28:	8522                	mv	a0,s0
ffffffffc0200d2a:	6402                	ld	s0,0(sp)
ffffffffc0200d2c:	0141                	addi	sp,sp,16
ffffffffc0200d2e:	8082                	ret

ffffffffc0200d30 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200d30:	100027f3          	csrr	a5,sstatus
ffffffffc0200d34:	8b89                	andi	a5,a5,2
ffffffffc0200d36:	e799                	bnez	a5,ffffffffc0200d44 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200d38:	00006797          	auipc	a5,0x6
ffffffffc0200d3c:	7407b783          	ld	a5,1856(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200d40:	739c                	ld	a5,32(a5)
ffffffffc0200d42:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200d44:	1101                	addi	sp,sp,-32
ffffffffc0200d46:	ec06                	sd	ra,24(sp)
ffffffffc0200d48:	e822                	sd	s0,16(sp)
ffffffffc0200d4a:	e426                	sd	s1,8(sp)
ffffffffc0200d4c:	842a                	mv	s0,a0
ffffffffc0200d4e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200d50:	aebff0ef          	jal	ra,ffffffffc020083a <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200d54:	00006797          	auipc	a5,0x6
ffffffffc0200d58:	7247b783          	ld	a5,1828(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200d5c:	739c                	ld	a5,32(a5)
ffffffffc0200d5e:	85a6                	mv	a1,s1
ffffffffc0200d60:	8522                	mv	a0,s0
ffffffffc0200d62:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200d64:	6442                	ld	s0,16(sp)
ffffffffc0200d66:	60e2                	ld	ra,24(sp)
ffffffffc0200d68:	64a2                	ld	s1,8(sp)
ffffffffc0200d6a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200d6c:	b4e1                	j	ffffffffc0200834 <intr_enable>

ffffffffc0200d6e <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200d6e:	100027f3          	csrr	a5,sstatus
ffffffffc0200d72:	8b89                	andi	a5,a5,2
ffffffffc0200d74:	e799                	bnez	a5,ffffffffc0200d82 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200d76:	00006797          	auipc	a5,0x6
ffffffffc0200d7a:	7027b783          	ld	a5,1794(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200d7e:	779c                	ld	a5,40(a5)
ffffffffc0200d80:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200d82:	1141                	addi	sp,sp,-16
ffffffffc0200d84:	e406                	sd	ra,8(sp)
ffffffffc0200d86:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200d88:	ab3ff0ef          	jal	ra,ffffffffc020083a <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200d8c:	00006797          	auipc	a5,0x6
ffffffffc0200d90:	6ec7b783          	ld	a5,1772(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200d94:	779c                	ld	a5,40(a5)
ffffffffc0200d96:	9782                	jalr	a5
ffffffffc0200d98:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200d9a:	a9bff0ef          	jal	ra,ffffffffc0200834 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200d9e:	60a2                	ld	ra,8(sp)
ffffffffc0200da0:	8522                	mv	a0,s0
ffffffffc0200da2:	6402                	ld	s0,0(sp)
ffffffffc0200da4:	0141                	addi	sp,sp,16
ffffffffc0200da6:	8082                	ret

ffffffffc0200da8 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0200da8:	00002797          	auipc	a5,0x2
ffffffffc0200dac:	12878793          	addi	a5,a5,296 # ffffffffc0202ed0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200db0:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200db2:	7179                	addi	sp,sp,-48
ffffffffc0200db4:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200db6:	00002517          	auipc	a0,0x2
ffffffffc0200dba:	c1250513          	addi	a0,a0,-1006 # ffffffffc02029c8 <commands+0x728>
    pmm_manager = &default_pmm_manager;
ffffffffc0200dbe:	00006417          	auipc	s0,0x6
ffffffffc0200dc2:	6ba40413          	addi	s0,s0,1722 # ffffffffc0207478 <pmm_manager>
void pmm_init(void) {
ffffffffc0200dc6:	f406                	sd	ra,40(sp)
ffffffffc0200dc8:	ec26                	sd	s1,24(sp)
ffffffffc0200dca:	e44e                	sd	s3,8(sp)
ffffffffc0200dcc:	e84a                	sd	s2,16(sp)
ffffffffc0200dce:	e052                	sd	s4,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0200dd0:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200dd2:	b0aff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    pmm_manager->init();
ffffffffc0200dd6:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200dd8:	00006497          	auipc	s1,0x6
ffffffffc0200ddc:	6b848493          	addi	s1,s1,1720 # ffffffffc0207490 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200de0:	679c                	ld	a5,8(a5)
ffffffffc0200de2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200de4:	57f5                	li	a5,-3
ffffffffc0200de6:	07fa                	slli	a5,a5,0x1e
ffffffffc0200de8:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0200dea:	9e5ff0ef          	jal	ra,ffffffffc02007ce <get_memory_base>
ffffffffc0200dee:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200df0:	9e9ff0ef          	jal	ra,ffffffffc02007d8 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200df4:	16050163          	beqz	a0,ffffffffc0200f56 <pmm_init+0x1ae>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200df8:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200dfa:	00002517          	auipc	a0,0x2
ffffffffc0200dfe:	c1650513          	addi	a0,a0,-1002 # ffffffffc0202a10 <commands+0x770>
ffffffffc0200e02:	adaff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200e06:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200e0a:	864e                	mv	a2,s3
ffffffffc0200e0c:	fffa0693          	addi	a3,s4,-1
ffffffffc0200e10:	85ca                	mv	a1,s2
ffffffffc0200e12:	00002517          	auipc	a0,0x2
ffffffffc0200e16:	c1650513          	addi	a0,a0,-1002 # ffffffffc0202a28 <commands+0x788>
ffffffffc0200e1a:	ac2ff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200e1e:	c80007b7          	lui	a5,0xc8000
ffffffffc0200e22:	8652                	mv	a2,s4
ffffffffc0200e24:	0d47e863          	bltu	a5,s4,ffffffffc0200ef4 <pmm_init+0x14c>
ffffffffc0200e28:	00007797          	auipc	a5,0x7
ffffffffc0200e2c:	67778793          	addi	a5,a5,1655 # ffffffffc020849f <end+0xfff>
ffffffffc0200e30:	757d                	lui	a0,0xfffff
ffffffffc0200e32:	8d7d                	and	a0,a0,a5
ffffffffc0200e34:	8231                	srli	a2,a2,0xc
ffffffffc0200e36:	00006597          	auipc	a1,0x6
ffffffffc0200e3a:	63258593          	addi	a1,a1,1586 # ffffffffc0207468 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e3e:	00006817          	auipc	a6,0x6
ffffffffc0200e42:	63280813          	addi	a6,a6,1586 # ffffffffc0207470 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200e46:	e190                	sd	a2,0(a1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e48:	00a83023          	sd	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e4c:	000807b7          	lui	a5,0x80
ffffffffc0200e50:	02f60663          	beq	a2,a5,ffffffffc0200e7c <pmm_init+0xd4>
ffffffffc0200e54:	4701                	li	a4,0
ffffffffc0200e56:	4781                	li	a5,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200e58:	4305                	li	t1,1
ffffffffc0200e5a:	fff808b7          	lui	a7,0xfff80
        SetPageReserved(pages + i);
ffffffffc0200e5e:	953a                	add	a0,a0,a4
ffffffffc0200e60:	00850693          	addi	a3,a0,8 # fffffffffffff008 <end+0x3fdf7b68>
ffffffffc0200e64:	4066b02f          	amoor.d	zero,t1,(a3)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e68:	6190                	ld	a2,0(a1)
ffffffffc0200e6a:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0200e6c:	00083503          	ld	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e70:	011606b3          	add	a3,a2,a7
ffffffffc0200e74:	02870713          	addi	a4,a4,40
ffffffffc0200e78:	fed7e3e3          	bltu	a5,a3,ffffffffc0200e5e <pmm_init+0xb6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e7c:	00261693          	slli	a3,a2,0x2
ffffffffc0200e80:	96b2                	add	a3,a3,a2
ffffffffc0200e82:	fec007b7          	lui	a5,0xfec00
ffffffffc0200e86:	97aa                	add	a5,a5,a0
ffffffffc0200e88:	068e                	slli	a3,a3,0x3
ffffffffc0200e8a:	96be                	add	a3,a3,a5
ffffffffc0200e8c:	c02007b7          	lui	a5,0xc0200
ffffffffc0200e90:	0af6e763          	bltu	a3,a5,ffffffffc0200f3e <pmm_init+0x196>
ffffffffc0200e94:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0200e96:	77fd                	lui	a5,0xfffff
ffffffffc0200e98:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e9c:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200e9e:	04b6ee63          	bltu	a3,a1,ffffffffc0200efa <pmm_init+0x152>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200ea2:	601c                	ld	a5,0(s0)
ffffffffc0200ea4:	7b9c                	ld	a5,48(a5)
ffffffffc0200ea6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200ea8:	00002517          	auipc	a0,0x2
ffffffffc0200eac:	c0850513          	addi	a0,a0,-1016 # ffffffffc0202ab0 <commands+0x810>
ffffffffc0200eb0:	a2cff0ef          	jal	ra,ffffffffc02000dc <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200eb4:	00005597          	auipc	a1,0x5
ffffffffc0200eb8:	14c58593          	addi	a1,a1,332 # ffffffffc0206000 <boot_page_table_sv39>
ffffffffc0200ebc:	00006797          	auipc	a5,0x6
ffffffffc0200ec0:	5cb7b623          	sd	a1,1484(a5) # ffffffffc0207488 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200ec4:	c02007b7          	lui	a5,0xc0200
ffffffffc0200ec8:	0af5e363          	bltu	a1,a5,ffffffffc0200f6e <pmm_init+0x1c6>
ffffffffc0200ecc:	6090                	ld	a2,0(s1)
}
ffffffffc0200ece:	7402                	ld	s0,32(sp)
ffffffffc0200ed0:	70a2                	ld	ra,40(sp)
ffffffffc0200ed2:	64e2                	ld	s1,24(sp)
ffffffffc0200ed4:	6942                	ld	s2,16(sp)
ffffffffc0200ed6:	69a2                	ld	s3,8(sp)
ffffffffc0200ed8:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200eda:	40c58633          	sub	a2,a1,a2
ffffffffc0200ede:	00006797          	auipc	a5,0x6
ffffffffc0200ee2:	5ac7b123          	sd	a2,1442(a5) # ffffffffc0207480 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ee6:	00002517          	auipc	a0,0x2
ffffffffc0200eea:	bea50513          	addi	a0,a0,-1046 # ffffffffc0202ad0 <commands+0x830>
}
ffffffffc0200eee:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ef0:	9ecff06f          	j	ffffffffc02000dc <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200ef4:	c8000637          	lui	a2,0xc8000
ffffffffc0200ef8:	bf05                	j	ffffffffc0200e28 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200efa:	6705                	lui	a4,0x1
ffffffffc0200efc:	177d                	addi	a4,a4,-1
ffffffffc0200efe:	96ba                	add	a3,a3,a4
ffffffffc0200f00:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200f02:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200f06:	02c7f063          	bgeu	a5,a2,ffffffffc0200f26 <pmm_init+0x17e>
    pmm_manager->init_memmap(base, n);
ffffffffc0200f0a:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200f0c:	fff80737          	lui	a4,0xfff80
ffffffffc0200f10:	973e                	add	a4,a4,a5
ffffffffc0200f12:	00271793          	slli	a5,a4,0x2
ffffffffc0200f16:	97ba                	add	a5,a5,a4
ffffffffc0200f18:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200f1a:	8d95                	sub	a1,a1,a3
ffffffffc0200f1c:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200f1e:	81b1                	srli	a1,a1,0xc
ffffffffc0200f20:	953e                	add	a0,a0,a5
ffffffffc0200f22:	9702                	jalr	a4
}
ffffffffc0200f24:	bfbd                	j	ffffffffc0200ea2 <pmm_init+0xfa>
        panic("pa2page called with invalid pa");
ffffffffc0200f26:	00002617          	auipc	a2,0x2
ffffffffc0200f2a:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0202a80 <commands+0x7e0>
ffffffffc0200f2e:	06b00593          	li	a1,107
ffffffffc0200f32:	00002517          	auipc	a0,0x2
ffffffffc0200f36:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0202aa0 <commands+0x800>
ffffffffc0200f3a:	a2aff0ef          	jal	ra,ffffffffc0200164 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f3e:	00002617          	auipc	a2,0x2
ffffffffc0200f42:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0202a58 <commands+0x7b8>
ffffffffc0200f46:	07100593          	li	a1,113
ffffffffc0200f4a:	00002517          	auipc	a0,0x2
ffffffffc0200f4e:	ab650513          	addi	a0,a0,-1354 # ffffffffc0202a00 <commands+0x760>
ffffffffc0200f52:	a12ff0ef          	jal	ra,ffffffffc0200164 <__panic>
        panic("DTB memory info not available");
ffffffffc0200f56:	00002617          	auipc	a2,0x2
ffffffffc0200f5a:	a8a60613          	addi	a2,a2,-1398 # ffffffffc02029e0 <commands+0x740>
ffffffffc0200f5e:	05a00593          	li	a1,90
ffffffffc0200f62:	00002517          	auipc	a0,0x2
ffffffffc0200f66:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0202a00 <commands+0x760>
ffffffffc0200f6a:	9faff0ef          	jal	ra,ffffffffc0200164 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f6e:	86ae                	mv	a3,a1
ffffffffc0200f70:	00002617          	auipc	a2,0x2
ffffffffc0200f74:	ae860613          	addi	a2,a2,-1304 # ffffffffc0202a58 <commands+0x7b8>
ffffffffc0200f78:	08c00593          	li	a1,140
ffffffffc0200f7c:	00002517          	auipc	a0,0x2
ffffffffc0200f80:	a8450513          	addi	a0,a0,-1404 # ffffffffc0202a00 <commands+0x760>
ffffffffc0200f84:	9e0ff0ef          	jal	ra,ffffffffc0200164 <__panic>

ffffffffc0200f88 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200f88:	00006797          	auipc	a5,0x6
ffffffffc0200f8c:	0a078793          	addi	a5,a5,160 # ffffffffc0207028 <free_area>
ffffffffc0200f90:	e79c                	sd	a5,8(a5)
ffffffffc0200f92:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200f94:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200f98:	8082                	ret

ffffffffc0200f9a <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200f9a:	00006517          	auipc	a0,0x6
ffffffffc0200f9e:	09e56503          	lwu	a0,158(a0) # ffffffffc0207038 <free_area+0x10>
ffffffffc0200fa2:	8082                	ret

ffffffffc0200fa4 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200fa4:	715d                	addi	sp,sp,-80
ffffffffc0200fa6:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200fa8:	00006417          	auipc	s0,0x6
ffffffffc0200fac:	08040413          	addi	s0,s0,128 # ffffffffc0207028 <free_area>
ffffffffc0200fb0:	641c                	ld	a5,8(s0)
ffffffffc0200fb2:	e486                	sd	ra,72(sp)
ffffffffc0200fb4:	fc26                	sd	s1,56(sp)
ffffffffc0200fb6:	f84a                	sd	s2,48(sp)
ffffffffc0200fb8:	f44e                	sd	s3,40(sp)
ffffffffc0200fba:	f052                	sd	s4,32(sp)
ffffffffc0200fbc:	ec56                	sd	s5,24(sp)
ffffffffc0200fbe:	e85a                	sd	s6,16(sp)
ffffffffc0200fc0:	e45e                	sd	s7,8(sp)
ffffffffc0200fc2:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200fc4:	2c878763          	beq	a5,s0,ffffffffc0201292 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200fc8:	4481                	li	s1,0
ffffffffc0200fca:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200fcc:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200fd0:	8b09                	andi	a4,a4,2
ffffffffc0200fd2:	2c070463          	beqz	a4,ffffffffc020129a <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200fd6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200fda:	679c                	ld	a5,8(a5)
ffffffffc0200fdc:	2905                	addiw	s2,s2,1
ffffffffc0200fde:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200fe0:	fe8796e3          	bne	a5,s0,ffffffffc0200fcc <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200fe4:	89a6                	mv	s3,s1
ffffffffc0200fe6:	d89ff0ef          	jal	ra,ffffffffc0200d6e <nr_free_pages>
ffffffffc0200fea:	71351863          	bne	a0,s3,ffffffffc02016fa <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fee:	4505                	li	a0,1
ffffffffc0200ff0:	d03ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc0200ff4:	8a2a                	mv	s4,a0
ffffffffc0200ff6:	44050263          	beqz	a0,ffffffffc020143a <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ffa:	4505                	li	a0,1
ffffffffc0200ffc:	cf7ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc0201000:	89aa                	mv	s3,a0
ffffffffc0201002:	70050c63          	beqz	a0,ffffffffc020171a <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201006:	4505                	li	a0,1
ffffffffc0201008:	cebff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc020100c:	8aaa                	mv	s5,a0
ffffffffc020100e:	4a050663          	beqz	a0,ffffffffc02014ba <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201012:	2b3a0463          	beq	s4,s3,ffffffffc02012ba <default_check+0x316>
ffffffffc0201016:	2aaa0263          	beq	s4,a0,ffffffffc02012ba <default_check+0x316>
ffffffffc020101a:	2aa98063          	beq	s3,a0,ffffffffc02012ba <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020101e:	000a2783          	lw	a5,0(s4)
ffffffffc0201022:	2a079c63          	bnez	a5,ffffffffc02012da <default_check+0x336>
ffffffffc0201026:	0009a783          	lw	a5,0(s3)
ffffffffc020102a:	2a079863          	bnez	a5,ffffffffc02012da <default_check+0x336>
ffffffffc020102e:	411c                	lw	a5,0(a0)
ffffffffc0201030:	2a079563          	bnez	a5,ffffffffc02012da <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201034:	00006797          	auipc	a5,0x6
ffffffffc0201038:	43c7b783          	ld	a5,1084(a5) # ffffffffc0207470 <pages>
ffffffffc020103c:	40fa0733          	sub	a4,s4,a5
ffffffffc0201040:	870d                	srai	a4,a4,0x3
ffffffffc0201042:	00002597          	auipc	a1,0x2
ffffffffc0201046:	1165b583          	ld	a1,278(a1) # ffffffffc0203158 <nbase+0x8>
ffffffffc020104a:	02b70733          	mul	a4,a4,a1
ffffffffc020104e:	00002617          	auipc	a2,0x2
ffffffffc0201052:	10263603          	ld	a2,258(a2) # ffffffffc0203150 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201056:	00006697          	auipc	a3,0x6
ffffffffc020105a:	4126b683          	ld	a3,1042(a3) # ffffffffc0207468 <npage>
ffffffffc020105e:	06b2                	slli	a3,a3,0xc
ffffffffc0201060:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201062:	0732                	slli	a4,a4,0xc
ffffffffc0201064:	28d77b63          	bgeu	a4,a3,ffffffffc02012fa <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201068:	40f98733          	sub	a4,s3,a5
ffffffffc020106c:	870d                	srai	a4,a4,0x3
ffffffffc020106e:	02b70733          	mul	a4,a4,a1
ffffffffc0201072:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201074:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201076:	4cd77263          	bgeu	a4,a3,ffffffffc020153a <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020107a:	40f507b3          	sub	a5,a0,a5
ffffffffc020107e:	878d                	srai	a5,a5,0x3
ffffffffc0201080:	02b787b3          	mul	a5,a5,a1
ffffffffc0201084:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201086:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201088:	30d7f963          	bgeu	a5,a3,ffffffffc020139a <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc020108c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020108e:	00043c03          	ld	s8,0(s0)
ffffffffc0201092:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201096:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc020109a:	e400                	sd	s0,8(s0)
ffffffffc020109c:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc020109e:	00006797          	auipc	a5,0x6
ffffffffc02010a2:	f807ad23          	sw	zero,-102(a5) # ffffffffc0207038 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02010a6:	c4dff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc02010aa:	2c051863          	bnez	a0,ffffffffc020137a <default_check+0x3d6>
    free_page(p0);
ffffffffc02010ae:	4585                	li	a1,1
ffffffffc02010b0:	8552                	mv	a0,s4
ffffffffc02010b2:	c7fff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
    free_page(p1);
ffffffffc02010b6:	4585                	li	a1,1
ffffffffc02010b8:	854e                	mv	a0,s3
ffffffffc02010ba:	c77ff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
    free_page(p2);
ffffffffc02010be:	4585                	li	a1,1
ffffffffc02010c0:	8556                	mv	a0,s5
ffffffffc02010c2:	c6fff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
    assert(nr_free == 3);
ffffffffc02010c6:	4818                	lw	a4,16(s0)
ffffffffc02010c8:	478d                	li	a5,3
ffffffffc02010ca:	28f71863          	bne	a4,a5,ffffffffc020135a <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010ce:	4505                	li	a0,1
ffffffffc02010d0:	c23ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc02010d4:	89aa                	mv	s3,a0
ffffffffc02010d6:	26050263          	beqz	a0,ffffffffc020133a <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010da:	4505                	li	a0,1
ffffffffc02010dc:	c17ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc02010e0:	8aaa                	mv	s5,a0
ffffffffc02010e2:	3a050c63          	beqz	a0,ffffffffc020149a <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010e6:	4505                	li	a0,1
ffffffffc02010e8:	c0bff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc02010ec:	8a2a                	mv	s4,a0
ffffffffc02010ee:	38050663          	beqz	a0,ffffffffc020147a <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc02010f2:	4505                	li	a0,1
ffffffffc02010f4:	bffff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc02010f8:	36051163          	bnez	a0,ffffffffc020145a <default_check+0x4b6>
    free_page(p0);
ffffffffc02010fc:	4585                	li	a1,1
ffffffffc02010fe:	854e                	mv	a0,s3
ffffffffc0201100:	c31ff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201104:	641c                	ld	a5,8(s0)
ffffffffc0201106:	20878a63          	beq	a5,s0,ffffffffc020131a <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc020110a:	4505                	li	a0,1
ffffffffc020110c:	be7ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc0201110:	30a99563          	bne	s3,a0,ffffffffc020141a <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0201114:	4505                	li	a0,1
ffffffffc0201116:	bddff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc020111a:	2e051063          	bnez	a0,ffffffffc02013fa <default_check+0x456>
    assert(nr_free == 0);
ffffffffc020111e:	481c                	lw	a5,16(s0)
ffffffffc0201120:	2a079d63          	bnez	a5,ffffffffc02013da <default_check+0x436>
    free_page(p);
ffffffffc0201124:	854e                	mv	a0,s3
ffffffffc0201126:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201128:	01843023          	sd	s8,0(s0)
ffffffffc020112c:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0201130:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0201134:	bfdff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
    free_page(p1);
ffffffffc0201138:	4585                	li	a1,1
ffffffffc020113a:	8556                	mv	a0,s5
ffffffffc020113c:	bf5ff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
    free_page(p2);
ffffffffc0201140:	4585                	li	a1,1
ffffffffc0201142:	8552                	mv	a0,s4
ffffffffc0201144:	bedff0ef          	jal	ra,ffffffffc0200d30 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201148:	4515                	li	a0,5
ffffffffc020114a:	ba9ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc020114e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201150:	26050563          	beqz	a0,ffffffffc02013ba <default_check+0x416>
ffffffffc0201154:	651c                	ld	a5,8(a0)
ffffffffc0201156:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0201158:	8b85                	andi	a5,a5,1
ffffffffc020115a:	54079063          	bnez	a5,ffffffffc020169a <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020115e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201160:	00043b03          	ld	s6,0(s0)
ffffffffc0201164:	00843a83          	ld	s5,8(s0)
ffffffffc0201168:	e000                	sd	s0,0(s0)
ffffffffc020116a:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc020116c:	b87ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc0201170:	50051563          	bnez	a0,ffffffffc020167a <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201174:	05098a13          	addi	s4,s3,80
ffffffffc0201178:	8552                	mv	a0,s4
ffffffffc020117a:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020117c:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201180:	00006797          	auipc	a5,0x6
ffffffffc0201184:	ea07ac23          	sw	zero,-328(a5) # ffffffffc0207038 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201188:	ba9ff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020118c:	4511                	li	a0,4
ffffffffc020118e:	b65ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc0201192:	4c051463          	bnez	a0,ffffffffc020165a <default_check+0x6b6>
ffffffffc0201196:	0589b783          	ld	a5,88(s3)
ffffffffc020119a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020119c:	8b85                	andi	a5,a5,1
ffffffffc020119e:	48078e63          	beqz	a5,ffffffffc020163a <default_check+0x696>
ffffffffc02011a2:	0609a703          	lw	a4,96(s3)
ffffffffc02011a6:	478d                	li	a5,3
ffffffffc02011a8:	48f71963          	bne	a4,a5,ffffffffc020163a <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011ac:	450d                	li	a0,3
ffffffffc02011ae:	b45ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc02011b2:	8c2a                	mv	s8,a0
ffffffffc02011b4:	46050363          	beqz	a0,ffffffffc020161a <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc02011b8:	4505                	li	a0,1
ffffffffc02011ba:	b39ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc02011be:	42051e63          	bnez	a0,ffffffffc02015fa <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc02011c2:	418a1c63          	bne	s4,s8,ffffffffc02015da <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02011c6:	4585                	li	a1,1
ffffffffc02011c8:	854e                	mv	a0,s3
ffffffffc02011ca:	b67ff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
    free_pages(p1, 3);
ffffffffc02011ce:	458d                	li	a1,3
ffffffffc02011d0:	8552                	mv	a0,s4
ffffffffc02011d2:	b5fff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
ffffffffc02011d6:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02011da:	02898c13          	addi	s8,s3,40
ffffffffc02011de:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02011e0:	8b85                	andi	a5,a5,1
ffffffffc02011e2:	3c078c63          	beqz	a5,ffffffffc02015ba <default_check+0x616>
ffffffffc02011e6:	0109a703          	lw	a4,16(s3)
ffffffffc02011ea:	4785                	li	a5,1
ffffffffc02011ec:	3cf71763          	bne	a4,a5,ffffffffc02015ba <default_check+0x616>
ffffffffc02011f0:	008a3783          	ld	a5,8(s4)
ffffffffc02011f4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02011f6:	8b85                	andi	a5,a5,1
ffffffffc02011f8:	3a078163          	beqz	a5,ffffffffc020159a <default_check+0x5f6>
ffffffffc02011fc:	010a2703          	lw	a4,16(s4)
ffffffffc0201200:	478d                	li	a5,3
ffffffffc0201202:	38f71c63          	bne	a4,a5,ffffffffc020159a <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201206:	4505                	li	a0,1
ffffffffc0201208:	aebff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc020120c:	36a99763          	bne	s3,a0,ffffffffc020157a <default_check+0x5d6>
    free_page(p0);
ffffffffc0201210:	4585                	li	a1,1
ffffffffc0201212:	b1fff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201216:	4509                	li	a0,2
ffffffffc0201218:	adbff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc020121c:	32aa1f63          	bne	s4,a0,ffffffffc020155a <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0201220:	4589                	li	a1,2
ffffffffc0201222:	b0fff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
    free_page(p2);
ffffffffc0201226:	4585                	li	a1,1
ffffffffc0201228:	8562                	mv	a0,s8
ffffffffc020122a:	b07ff0ef          	jal	ra,ffffffffc0200d30 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020122e:	4515                	li	a0,5
ffffffffc0201230:	ac3ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc0201234:	89aa                	mv	s3,a0
ffffffffc0201236:	48050263          	beqz	a0,ffffffffc02016ba <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc020123a:	4505                	li	a0,1
ffffffffc020123c:	ab7ff0ef          	jal	ra,ffffffffc0200cf2 <alloc_pages>
ffffffffc0201240:	2c051d63          	bnez	a0,ffffffffc020151a <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0201244:	481c                	lw	a5,16(s0)
ffffffffc0201246:	2a079a63          	bnez	a5,ffffffffc02014fa <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020124a:	4595                	li	a1,5
ffffffffc020124c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020124e:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0201252:	01643023          	sd	s6,0(s0)
ffffffffc0201256:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc020125a:	ad7ff0ef          	jal	ra,ffffffffc0200d30 <free_pages>
    return listelm->next;
ffffffffc020125e:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201260:	00878963          	beq	a5,s0,ffffffffc0201272 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201264:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201268:	679c                	ld	a5,8(a5)
ffffffffc020126a:	397d                	addiw	s2,s2,-1
ffffffffc020126c:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020126e:	fe879be3          	bne	a5,s0,ffffffffc0201264 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0201272:	26091463          	bnez	s2,ffffffffc02014da <default_check+0x536>
    assert(total == 0);
ffffffffc0201276:	46049263          	bnez	s1,ffffffffc02016da <default_check+0x736>
}
ffffffffc020127a:	60a6                	ld	ra,72(sp)
ffffffffc020127c:	6406                	ld	s0,64(sp)
ffffffffc020127e:	74e2                	ld	s1,56(sp)
ffffffffc0201280:	7942                	ld	s2,48(sp)
ffffffffc0201282:	79a2                	ld	s3,40(sp)
ffffffffc0201284:	7a02                	ld	s4,32(sp)
ffffffffc0201286:	6ae2                	ld	s5,24(sp)
ffffffffc0201288:	6b42                	ld	s6,16(sp)
ffffffffc020128a:	6ba2                	ld	s7,8(sp)
ffffffffc020128c:	6c02                	ld	s8,0(sp)
ffffffffc020128e:	6161                	addi	sp,sp,80
ffffffffc0201290:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201292:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201294:	4481                	li	s1,0
ffffffffc0201296:	4901                	li	s2,0
ffffffffc0201298:	b3b9                	j	ffffffffc0200fe6 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc020129a:	00002697          	auipc	a3,0x2
ffffffffc020129e:	87668693          	addi	a3,a3,-1930 # ffffffffc0202b10 <commands+0x870>
ffffffffc02012a2:	00002617          	auipc	a2,0x2
ffffffffc02012a6:	87e60613          	addi	a2,a2,-1922 # ffffffffc0202b20 <commands+0x880>
ffffffffc02012aa:	0f000593          	li	a1,240
ffffffffc02012ae:	00002517          	auipc	a0,0x2
ffffffffc02012b2:	88a50513          	addi	a0,a0,-1910 # ffffffffc0202b38 <commands+0x898>
ffffffffc02012b6:	eaffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02012ba:	00002697          	auipc	a3,0x2
ffffffffc02012be:	91668693          	addi	a3,a3,-1770 # ffffffffc0202bd0 <commands+0x930>
ffffffffc02012c2:	00002617          	auipc	a2,0x2
ffffffffc02012c6:	85e60613          	addi	a2,a2,-1954 # ffffffffc0202b20 <commands+0x880>
ffffffffc02012ca:	0bd00593          	li	a1,189
ffffffffc02012ce:	00002517          	auipc	a0,0x2
ffffffffc02012d2:	86a50513          	addi	a0,a0,-1942 # ffffffffc0202b38 <commands+0x898>
ffffffffc02012d6:	e8ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02012da:	00002697          	auipc	a3,0x2
ffffffffc02012de:	91e68693          	addi	a3,a3,-1762 # ffffffffc0202bf8 <commands+0x958>
ffffffffc02012e2:	00002617          	auipc	a2,0x2
ffffffffc02012e6:	83e60613          	addi	a2,a2,-1986 # ffffffffc0202b20 <commands+0x880>
ffffffffc02012ea:	0be00593          	li	a1,190
ffffffffc02012ee:	00002517          	auipc	a0,0x2
ffffffffc02012f2:	84a50513          	addi	a0,a0,-1974 # ffffffffc0202b38 <commands+0x898>
ffffffffc02012f6:	e6ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02012fa:	00002697          	auipc	a3,0x2
ffffffffc02012fe:	93e68693          	addi	a3,a3,-1730 # ffffffffc0202c38 <commands+0x998>
ffffffffc0201302:	00002617          	auipc	a2,0x2
ffffffffc0201306:	81e60613          	addi	a2,a2,-2018 # ffffffffc0202b20 <commands+0x880>
ffffffffc020130a:	0c000593          	li	a1,192
ffffffffc020130e:	00002517          	auipc	a0,0x2
ffffffffc0201312:	82a50513          	addi	a0,a0,-2006 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201316:	e4ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020131a:	00002697          	auipc	a3,0x2
ffffffffc020131e:	9a668693          	addi	a3,a3,-1626 # ffffffffc0202cc0 <commands+0xa20>
ffffffffc0201322:	00001617          	auipc	a2,0x1
ffffffffc0201326:	7fe60613          	addi	a2,a2,2046 # ffffffffc0202b20 <commands+0x880>
ffffffffc020132a:	0d900593          	li	a1,217
ffffffffc020132e:	00002517          	auipc	a0,0x2
ffffffffc0201332:	80a50513          	addi	a0,a0,-2038 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201336:	e2ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020133a:	00002697          	auipc	a3,0x2
ffffffffc020133e:	83668693          	addi	a3,a3,-1994 # ffffffffc0202b70 <commands+0x8d0>
ffffffffc0201342:	00001617          	auipc	a2,0x1
ffffffffc0201346:	7de60613          	addi	a2,a2,2014 # ffffffffc0202b20 <commands+0x880>
ffffffffc020134a:	0d200593          	li	a1,210
ffffffffc020134e:	00001517          	auipc	a0,0x1
ffffffffc0201352:	7ea50513          	addi	a0,a0,2026 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201356:	e0ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(nr_free == 3);
ffffffffc020135a:	00002697          	auipc	a3,0x2
ffffffffc020135e:	95668693          	addi	a3,a3,-1706 # ffffffffc0202cb0 <commands+0xa10>
ffffffffc0201362:	00001617          	auipc	a2,0x1
ffffffffc0201366:	7be60613          	addi	a2,a2,1982 # ffffffffc0202b20 <commands+0x880>
ffffffffc020136a:	0d000593          	li	a1,208
ffffffffc020136e:	00001517          	auipc	a0,0x1
ffffffffc0201372:	7ca50513          	addi	a0,a0,1994 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201376:	deffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020137a:	00002697          	auipc	a3,0x2
ffffffffc020137e:	91e68693          	addi	a3,a3,-1762 # ffffffffc0202c98 <commands+0x9f8>
ffffffffc0201382:	00001617          	auipc	a2,0x1
ffffffffc0201386:	79e60613          	addi	a2,a2,1950 # ffffffffc0202b20 <commands+0x880>
ffffffffc020138a:	0cb00593          	li	a1,203
ffffffffc020138e:	00001517          	auipc	a0,0x1
ffffffffc0201392:	7aa50513          	addi	a0,a0,1962 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201396:	dcffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020139a:	00002697          	auipc	a3,0x2
ffffffffc020139e:	8de68693          	addi	a3,a3,-1826 # ffffffffc0202c78 <commands+0x9d8>
ffffffffc02013a2:	00001617          	auipc	a2,0x1
ffffffffc02013a6:	77e60613          	addi	a2,a2,1918 # ffffffffc0202b20 <commands+0x880>
ffffffffc02013aa:	0c200593          	li	a1,194
ffffffffc02013ae:	00001517          	auipc	a0,0x1
ffffffffc02013b2:	78a50513          	addi	a0,a0,1930 # ffffffffc0202b38 <commands+0x898>
ffffffffc02013b6:	daffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(p0 != NULL);
ffffffffc02013ba:	00002697          	auipc	a3,0x2
ffffffffc02013be:	94e68693          	addi	a3,a3,-1714 # ffffffffc0202d08 <commands+0xa68>
ffffffffc02013c2:	00001617          	auipc	a2,0x1
ffffffffc02013c6:	75e60613          	addi	a2,a2,1886 # ffffffffc0202b20 <commands+0x880>
ffffffffc02013ca:	0f800593          	li	a1,248
ffffffffc02013ce:	00001517          	auipc	a0,0x1
ffffffffc02013d2:	76a50513          	addi	a0,a0,1898 # ffffffffc0202b38 <commands+0x898>
ffffffffc02013d6:	d8ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(nr_free == 0);
ffffffffc02013da:	00002697          	auipc	a3,0x2
ffffffffc02013de:	91e68693          	addi	a3,a3,-1762 # ffffffffc0202cf8 <commands+0xa58>
ffffffffc02013e2:	00001617          	auipc	a2,0x1
ffffffffc02013e6:	73e60613          	addi	a2,a2,1854 # ffffffffc0202b20 <commands+0x880>
ffffffffc02013ea:	0df00593          	li	a1,223
ffffffffc02013ee:	00001517          	auipc	a0,0x1
ffffffffc02013f2:	74a50513          	addi	a0,a0,1866 # ffffffffc0202b38 <commands+0x898>
ffffffffc02013f6:	d6ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013fa:	00002697          	auipc	a3,0x2
ffffffffc02013fe:	89e68693          	addi	a3,a3,-1890 # ffffffffc0202c98 <commands+0x9f8>
ffffffffc0201402:	00001617          	auipc	a2,0x1
ffffffffc0201406:	71e60613          	addi	a2,a2,1822 # ffffffffc0202b20 <commands+0x880>
ffffffffc020140a:	0dd00593          	li	a1,221
ffffffffc020140e:	00001517          	auipc	a0,0x1
ffffffffc0201412:	72a50513          	addi	a0,a0,1834 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201416:	d4ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020141a:	00002697          	auipc	a3,0x2
ffffffffc020141e:	8be68693          	addi	a3,a3,-1858 # ffffffffc0202cd8 <commands+0xa38>
ffffffffc0201422:	00001617          	auipc	a2,0x1
ffffffffc0201426:	6fe60613          	addi	a2,a2,1790 # ffffffffc0202b20 <commands+0x880>
ffffffffc020142a:	0dc00593          	li	a1,220
ffffffffc020142e:	00001517          	auipc	a0,0x1
ffffffffc0201432:	70a50513          	addi	a0,a0,1802 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201436:	d2ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020143a:	00001697          	auipc	a3,0x1
ffffffffc020143e:	73668693          	addi	a3,a3,1846 # ffffffffc0202b70 <commands+0x8d0>
ffffffffc0201442:	00001617          	auipc	a2,0x1
ffffffffc0201446:	6de60613          	addi	a2,a2,1758 # ffffffffc0202b20 <commands+0x880>
ffffffffc020144a:	0b900593          	li	a1,185
ffffffffc020144e:	00001517          	auipc	a0,0x1
ffffffffc0201452:	6ea50513          	addi	a0,a0,1770 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201456:	d0ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020145a:	00002697          	auipc	a3,0x2
ffffffffc020145e:	83e68693          	addi	a3,a3,-1986 # ffffffffc0202c98 <commands+0x9f8>
ffffffffc0201462:	00001617          	auipc	a2,0x1
ffffffffc0201466:	6be60613          	addi	a2,a2,1726 # ffffffffc0202b20 <commands+0x880>
ffffffffc020146a:	0d600593          	li	a1,214
ffffffffc020146e:	00001517          	auipc	a0,0x1
ffffffffc0201472:	6ca50513          	addi	a0,a0,1738 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201476:	ceffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020147a:	00001697          	auipc	a3,0x1
ffffffffc020147e:	73668693          	addi	a3,a3,1846 # ffffffffc0202bb0 <commands+0x910>
ffffffffc0201482:	00001617          	auipc	a2,0x1
ffffffffc0201486:	69e60613          	addi	a2,a2,1694 # ffffffffc0202b20 <commands+0x880>
ffffffffc020148a:	0d400593          	li	a1,212
ffffffffc020148e:	00001517          	auipc	a0,0x1
ffffffffc0201492:	6aa50513          	addi	a0,a0,1706 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201496:	ccffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020149a:	00001697          	auipc	a3,0x1
ffffffffc020149e:	6f668693          	addi	a3,a3,1782 # ffffffffc0202b90 <commands+0x8f0>
ffffffffc02014a2:	00001617          	auipc	a2,0x1
ffffffffc02014a6:	67e60613          	addi	a2,a2,1662 # ffffffffc0202b20 <commands+0x880>
ffffffffc02014aa:	0d300593          	li	a1,211
ffffffffc02014ae:	00001517          	auipc	a0,0x1
ffffffffc02014b2:	68a50513          	addi	a0,a0,1674 # ffffffffc0202b38 <commands+0x898>
ffffffffc02014b6:	caffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014ba:	00001697          	auipc	a3,0x1
ffffffffc02014be:	6f668693          	addi	a3,a3,1782 # ffffffffc0202bb0 <commands+0x910>
ffffffffc02014c2:	00001617          	auipc	a2,0x1
ffffffffc02014c6:	65e60613          	addi	a2,a2,1630 # ffffffffc0202b20 <commands+0x880>
ffffffffc02014ca:	0bb00593          	li	a1,187
ffffffffc02014ce:	00001517          	auipc	a0,0x1
ffffffffc02014d2:	66a50513          	addi	a0,a0,1642 # ffffffffc0202b38 <commands+0x898>
ffffffffc02014d6:	c8ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(count == 0);
ffffffffc02014da:	00002697          	auipc	a3,0x2
ffffffffc02014de:	97e68693          	addi	a3,a3,-1666 # ffffffffc0202e58 <commands+0xbb8>
ffffffffc02014e2:	00001617          	auipc	a2,0x1
ffffffffc02014e6:	63e60613          	addi	a2,a2,1598 # ffffffffc0202b20 <commands+0x880>
ffffffffc02014ea:	12500593          	li	a1,293
ffffffffc02014ee:	00001517          	auipc	a0,0x1
ffffffffc02014f2:	64a50513          	addi	a0,a0,1610 # ffffffffc0202b38 <commands+0x898>
ffffffffc02014f6:	c6ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(nr_free == 0);
ffffffffc02014fa:	00001697          	auipc	a3,0x1
ffffffffc02014fe:	7fe68693          	addi	a3,a3,2046 # ffffffffc0202cf8 <commands+0xa58>
ffffffffc0201502:	00001617          	auipc	a2,0x1
ffffffffc0201506:	61e60613          	addi	a2,a2,1566 # ffffffffc0202b20 <commands+0x880>
ffffffffc020150a:	11a00593          	li	a1,282
ffffffffc020150e:	00001517          	auipc	a0,0x1
ffffffffc0201512:	62a50513          	addi	a0,a0,1578 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201516:	c4ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020151a:	00001697          	auipc	a3,0x1
ffffffffc020151e:	77e68693          	addi	a3,a3,1918 # ffffffffc0202c98 <commands+0x9f8>
ffffffffc0201522:	00001617          	auipc	a2,0x1
ffffffffc0201526:	5fe60613          	addi	a2,a2,1534 # ffffffffc0202b20 <commands+0x880>
ffffffffc020152a:	11800593          	li	a1,280
ffffffffc020152e:	00001517          	auipc	a0,0x1
ffffffffc0201532:	60a50513          	addi	a0,a0,1546 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201536:	c2ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020153a:	00001697          	auipc	a3,0x1
ffffffffc020153e:	71e68693          	addi	a3,a3,1822 # ffffffffc0202c58 <commands+0x9b8>
ffffffffc0201542:	00001617          	auipc	a2,0x1
ffffffffc0201546:	5de60613          	addi	a2,a2,1502 # ffffffffc0202b20 <commands+0x880>
ffffffffc020154a:	0c100593          	li	a1,193
ffffffffc020154e:	00001517          	auipc	a0,0x1
ffffffffc0201552:	5ea50513          	addi	a0,a0,1514 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201556:	c0ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020155a:	00002697          	auipc	a3,0x2
ffffffffc020155e:	8be68693          	addi	a3,a3,-1858 # ffffffffc0202e18 <commands+0xb78>
ffffffffc0201562:	00001617          	auipc	a2,0x1
ffffffffc0201566:	5be60613          	addi	a2,a2,1470 # ffffffffc0202b20 <commands+0x880>
ffffffffc020156a:	11200593          	li	a1,274
ffffffffc020156e:	00001517          	auipc	a0,0x1
ffffffffc0201572:	5ca50513          	addi	a0,a0,1482 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201576:	beffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020157a:	00002697          	auipc	a3,0x2
ffffffffc020157e:	87e68693          	addi	a3,a3,-1922 # ffffffffc0202df8 <commands+0xb58>
ffffffffc0201582:	00001617          	auipc	a2,0x1
ffffffffc0201586:	59e60613          	addi	a2,a2,1438 # ffffffffc0202b20 <commands+0x880>
ffffffffc020158a:	11000593          	li	a1,272
ffffffffc020158e:	00001517          	auipc	a0,0x1
ffffffffc0201592:	5aa50513          	addi	a0,a0,1450 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201596:	bcffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020159a:	00002697          	auipc	a3,0x2
ffffffffc020159e:	83668693          	addi	a3,a3,-1994 # ffffffffc0202dd0 <commands+0xb30>
ffffffffc02015a2:	00001617          	auipc	a2,0x1
ffffffffc02015a6:	57e60613          	addi	a2,a2,1406 # ffffffffc0202b20 <commands+0x880>
ffffffffc02015aa:	10e00593          	li	a1,270
ffffffffc02015ae:	00001517          	auipc	a0,0x1
ffffffffc02015b2:	58a50513          	addi	a0,a0,1418 # ffffffffc0202b38 <commands+0x898>
ffffffffc02015b6:	baffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02015ba:	00001697          	auipc	a3,0x1
ffffffffc02015be:	7ee68693          	addi	a3,a3,2030 # ffffffffc0202da8 <commands+0xb08>
ffffffffc02015c2:	00001617          	auipc	a2,0x1
ffffffffc02015c6:	55e60613          	addi	a2,a2,1374 # ffffffffc0202b20 <commands+0x880>
ffffffffc02015ca:	10d00593          	li	a1,269
ffffffffc02015ce:	00001517          	auipc	a0,0x1
ffffffffc02015d2:	56a50513          	addi	a0,a0,1386 # ffffffffc0202b38 <commands+0x898>
ffffffffc02015d6:	b8ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02015da:	00001697          	auipc	a3,0x1
ffffffffc02015de:	7be68693          	addi	a3,a3,1982 # ffffffffc0202d98 <commands+0xaf8>
ffffffffc02015e2:	00001617          	auipc	a2,0x1
ffffffffc02015e6:	53e60613          	addi	a2,a2,1342 # ffffffffc0202b20 <commands+0x880>
ffffffffc02015ea:	10800593          	li	a1,264
ffffffffc02015ee:	00001517          	auipc	a0,0x1
ffffffffc02015f2:	54a50513          	addi	a0,a0,1354 # ffffffffc0202b38 <commands+0x898>
ffffffffc02015f6:	b6ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015fa:	00001697          	auipc	a3,0x1
ffffffffc02015fe:	69e68693          	addi	a3,a3,1694 # ffffffffc0202c98 <commands+0x9f8>
ffffffffc0201602:	00001617          	auipc	a2,0x1
ffffffffc0201606:	51e60613          	addi	a2,a2,1310 # ffffffffc0202b20 <commands+0x880>
ffffffffc020160a:	10700593          	li	a1,263
ffffffffc020160e:	00001517          	auipc	a0,0x1
ffffffffc0201612:	52a50513          	addi	a0,a0,1322 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201616:	b4ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020161a:	00001697          	auipc	a3,0x1
ffffffffc020161e:	75e68693          	addi	a3,a3,1886 # ffffffffc0202d78 <commands+0xad8>
ffffffffc0201622:	00001617          	auipc	a2,0x1
ffffffffc0201626:	4fe60613          	addi	a2,a2,1278 # ffffffffc0202b20 <commands+0x880>
ffffffffc020162a:	10600593          	li	a1,262
ffffffffc020162e:	00001517          	auipc	a0,0x1
ffffffffc0201632:	50a50513          	addi	a0,a0,1290 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201636:	b2ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020163a:	00001697          	auipc	a3,0x1
ffffffffc020163e:	70e68693          	addi	a3,a3,1806 # ffffffffc0202d48 <commands+0xaa8>
ffffffffc0201642:	00001617          	auipc	a2,0x1
ffffffffc0201646:	4de60613          	addi	a2,a2,1246 # ffffffffc0202b20 <commands+0x880>
ffffffffc020164a:	10500593          	li	a1,261
ffffffffc020164e:	00001517          	auipc	a0,0x1
ffffffffc0201652:	4ea50513          	addi	a0,a0,1258 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201656:	b0ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020165a:	00001697          	auipc	a3,0x1
ffffffffc020165e:	6d668693          	addi	a3,a3,1750 # ffffffffc0202d30 <commands+0xa90>
ffffffffc0201662:	00001617          	auipc	a2,0x1
ffffffffc0201666:	4be60613          	addi	a2,a2,1214 # ffffffffc0202b20 <commands+0x880>
ffffffffc020166a:	10400593          	li	a1,260
ffffffffc020166e:	00001517          	auipc	a0,0x1
ffffffffc0201672:	4ca50513          	addi	a0,a0,1226 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201676:	aeffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020167a:	00001697          	auipc	a3,0x1
ffffffffc020167e:	61e68693          	addi	a3,a3,1566 # ffffffffc0202c98 <commands+0x9f8>
ffffffffc0201682:	00001617          	auipc	a2,0x1
ffffffffc0201686:	49e60613          	addi	a2,a2,1182 # ffffffffc0202b20 <commands+0x880>
ffffffffc020168a:	0fe00593          	li	a1,254
ffffffffc020168e:	00001517          	auipc	a0,0x1
ffffffffc0201692:	4aa50513          	addi	a0,a0,1194 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201696:	acffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(!PageProperty(p0));
ffffffffc020169a:	00001697          	auipc	a3,0x1
ffffffffc020169e:	67e68693          	addi	a3,a3,1662 # ffffffffc0202d18 <commands+0xa78>
ffffffffc02016a2:	00001617          	auipc	a2,0x1
ffffffffc02016a6:	47e60613          	addi	a2,a2,1150 # ffffffffc0202b20 <commands+0x880>
ffffffffc02016aa:	0f900593          	li	a1,249
ffffffffc02016ae:	00001517          	auipc	a0,0x1
ffffffffc02016b2:	48a50513          	addi	a0,a0,1162 # ffffffffc0202b38 <commands+0x898>
ffffffffc02016b6:	aaffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02016ba:	00001697          	auipc	a3,0x1
ffffffffc02016be:	77e68693          	addi	a3,a3,1918 # ffffffffc0202e38 <commands+0xb98>
ffffffffc02016c2:	00001617          	auipc	a2,0x1
ffffffffc02016c6:	45e60613          	addi	a2,a2,1118 # ffffffffc0202b20 <commands+0x880>
ffffffffc02016ca:	11700593          	li	a1,279
ffffffffc02016ce:	00001517          	auipc	a0,0x1
ffffffffc02016d2:	46a50513          	addi	a0,a0,1130 # ffffffffc0202b38 <commands+0x898>
ffffffffc02016d6:	a8ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(total == 0);
ffffffffc02016da:	00001697          	auipc	a3,0x1
ffffffffc02016de:	78e68693          	addi	a3,a3,1934 # ffffffffc0202e68 <commands+0xbc8>
ffffffffc02016e2:	00001617          	auipc	a2,0x1
ffffffffc02016e6:	43e60613          	addi	a2,a2,1086 # ffffffffc0202b20 <commands+0x880>
ffffffffc02016ea:	12600593          	li	a1,294
ffffffffc02016ee:	00001517          	auipc	a0,0x1
ffffffffc02016f2:	44a50513          	addi	a0,a0,1098 # ffffffffc0202b38 <commands+0x898>
ffffffffc02016f6:	a6ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(total == nr_free_pages());
ffffffffc02016fa:	00001697          	auipc	a3,0x1
ffffffffc02016fe:	45668693          	addi	a3,a3,1110 # ffffffffc0202b50 <commands+0x8b0>
ffffffffc0201702:	00001617          	auipc	a2,0x1
ffffffffc0201706:	41e60613          	addi	a2,a2,1054 # ffffffffc0202b20 <commands+0x880>
ffffffffc020170a:	0f300593          	li	a1,243
ffffffffc020170e:	00001517          	auipc	a0,0x1
ffffffffc0201712:	42a50513          	addi	a0,a0,1066 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201716:	a4ffe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020171a:	00001697          	auipc	a3,0x1
ffffffffc020171e:	47668693          	addi	a3,a3,1142 # ffffffffc0202b90 <commands+0x8f0>
ffffffffc0201722:	00001617          	auipc	a2,0x1
ffffffffc0201726:	3fe60613          	addi	a2,a2,1022 # ffffffffc0202b20 <commands+0x880>
ffffffffc020172a:	0ba00593          	li	a1,186
ffffffffc020172e:	00001517          	auipc	a0,0x1
ffffffffc0201732:	40a50513          	addi	a0,a0,1034 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201736:	a2ffe0ef          	jal	ra,ffffffffc0200164 <__panic>

ffffffffc020173a <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020173a:	1141                	addi	sp,sp,-16
ffffffffc020173c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020173e:	14058a63          	beqz	a1,ffffffffc0201892 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0201742:	00259693          	slli	a3,a1,0x2
ffffffffc0201746:	96ae                	add	a3,a3,a1
ffffffffc0201748:	068e                	slli	a3,a3,0x3
ffffffffc020174a:	96aa                	add	a3,a3,a0
ffffffffc020174c:	87aa                	mv	a5,a0
ffffffffc020174e:	02d50263          	beq	a0,a3,ffffffffc0201772 <default_free_pages+0x38>
ffffffffc0201752:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201754:	8b05                	andi	a4,a4,1
ffffffffc0201756:	10071e63          	bnez	a4,ffffffffc0201872 <default_free_pages+0x138>
ffffffffc020175a:	6798                	ld	a4,8(a5)
ffffffffc020175c:	8b09                	andi	a4,a4,2
ffffffffc020175e:	10071a63          	bnez	a4,ffffffffc0201872 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc0201762:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201766:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020176a:	02878793          	addi	a5,a5,40
ffffffffc020176e:	fed792e3          	bne	a5,a3,ffffffffc0201752 <default_free_pages+0x18>
    base->property = n;
ffffffffc0201772:	2581                	sext.w	a1,a1
ffffffffc0201774:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201776:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020177a:	4789                	li	a5,2
ffffffffc020177c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201780:	00006697          	auipc	a3,0x6
ffffffffc0201784:	8a868693          	addi	a3,a3,-1880 # ffffffffc0207028 <free_area>
ffffffffc0201788:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020178a:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020178c:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201790:	9db9                	addw	a1,a1,a4
ffffffffc0201792:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201794:	0ad78863          	beq	a5,a3,ffffffffc0201844 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201798:	fe878713          	addi	a4,a5,-24
ffffffffc020179c:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02017a0:	4581                	li	a1,0
            if (base < page) {
ffffffffc02017a2:	00e56a63          	bltu	a0,a4,ffffffffc02017b6 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02017a6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02017a8:	06d70263          	beq	a4,a3,ffffffffc020180c <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02017ac:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02017ae:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02017b2:	fee57ae3          	bgeu	a0,a4,ffffffffc02017a6 <default_free_pages+0x6c>
ffffffffc02017b6:	c199                	beqz	a1,ffffffffc02017bc <default_free_pages+0x82>
ffffffffc02017b8:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02017bc:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02017be:	e390                	sd	a2,0(a5)
ffffffffc02017c0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02017c2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02017c4:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02017c6:	02d70063          	beq	a4,a3,ffffffffc02017e6 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02017ca:	ff872803          	lw	a6,-8(a4) # fffffffffff7fff8 <end+0x3fd78b58>
        p = le2page(le, page_link);
ffffffffc02017ce:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc02017d2:	02081613          	slli	a2,a6,0x20
ffffffffc02017d6:	9201                	srli	a2,a2,0x20
ffffffffc02017d8:	00261793          	slli	a5,a2,0x2
ffffffffc02017dc:	97b2                	add	a5,a5,a2
ffffffffc02017de:	078e                	slli	a5,a5,0x3
ffffffffc02017e0:	97ae                	add	a5,a5,a1
ffffffffc02017e2:	02f50f63          	beq	a0,a5,ffffffffc0201820 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02017e6:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc02017e8:	00d70f63          	beq	a4,a3,ffffffffc0201806 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02017ec:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc02017ee:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc02017f2:	02059613          	slli	a2,a1,0x20
ffffffffc02017f6:	9201                	srli	a2,a2,0x20
ffffffffc02017f8:	00261793          	slli	a5,a2,0x2
ffffffffc02017fc:	97b2                	add	a5,a5,a2
ffffffffc02017fe:	078e                	slli	a5,a5,0x3
ffffffffc0201800:	97aa                	add	a5,a5,a0
ffffffffc0201802:	04f68863          	beq	a3,a5,ffffffffc0201852 <default_free_pages+0x118>
}
ffffffffc0201806:	60a2                	ld	ra,8(sp)
ffffffffc0201808:	0141                	addi	sp,sp,16
ffffffffc020180a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020180c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020180e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201810:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201812:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201814:	02d70563          	beq	a4,a3,ffffffffc020183e <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201818:	8832                	mv	a6,a2
ffffffffc020181a:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020181c:	87ba                	mv	a5,a4
ffffffffc020181e:	bf41                	j	ffffffffc02017ae <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0201820:	491c                	lw	a5,16(a0)
ffffffffc0201822:	0107883b          	addw	a6,a5,a6
ffffffffc0201826:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020182a:	57f5                	li	a5,-3
ffffffffc020182c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201830:	6d10                	ld	a2,24(a0)
ffffffffc0201832:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc0201834:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201836:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201838:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc020183a:	e390                	sd	a2,0(a5)
ffffffffc020183c:	b775                	j	ffffffffc02017e8 <default_free_pages+0xae>
ffffffffc020183e:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201840:	873e                	mv	a4,a5
ffffffffc0201842:	b761                	j	ffffffffc02017ca <default_free_pages+0x90>
}
ffffffffc0201844:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201846:	e390                	sd	a2,0(a5)
ffffffffc0201848:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020184a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020184c:	ed1c                	sd	a5,24(a0)
ffffffffc020184e:	0141                	addi	sp,sp,16
ffffffffc0201850:	8082                	ret
            base->property += p->property;
ffffffffc0201852:	ff872783          	lw	a5,-8(a4)
ffffffffc0201856:	ff070693          	addi	a3,a4,-16
ffffffffc020185a:	9dbd                	addw	a1,a1,a5
ffffffffc020185c:	c90c                	sw	a1,16(a0)
ffffffffc020185e:	57f5                	li	a5,-3
ffffffffc0201860:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201864:	6314                	ld	a3,0(a4)
ffffffffc0201866:	671c                	ld	a5,8(a4)
}
ffffffffc0201868:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020186a:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020186c:	e394                	sd	a3,0(a5)
ffffffffc020186e:	0141                	addi	sp,sp,16
ffffffffc0201870:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201872:	00001697          	auipc	a3,0x1
ffffffffc0201876:	60e68693          	addi	a3,a3,1550 # ffffffffc0202e80 <commands+0xbe0>
ffffffffc020187a:	00001617          	auipc	a2,0x1
ffffffffc020187e:	2a660613          	addi	a2,a2,678 # ffffffffc0202b20 <commands+0x880>
ffffffffc0201882:	08300593          	li	a1,131
ffffffffc0201886:	00001517          	auipc	a0,0x1
ffffffffc020188a:	2b250513          	addi	a0,a0,690 # ffffffffc0202b38 <commands+0x898>
ffffffffc020188e:	8d7fe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(n > 0);
ffffffffc0201892:	00001697          	auipc	a3,0x1
ffffffffc0201896:	5e668693          	addi	a3,a3,1510 # ffffffffc0202e78 <commands+0xbd8>
ffffffffc020189a:	00001617          	auipc	a2,0x1
ffffffffc020189e:	28660613          	addi	a2,a2,646 # ffffffffc0202b20 <commands+0x880>
ffffffffc02018a2:	08000593          	li	a1,128
ffffffffc02018a6:	00001517          	auipc	a0,0x1
ffffffffc02018aa:	29250513          	addi	a0,a0,658 # ffffffffc0202b38 <commands+0x898>
ffffffffc02018ae:	8b7fe0ef          	jal	ra,ffffffffc0200164 <__panic>

ffffffffc02018b2 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02018b2:	c959                	beqz	a0,ffffffffc0201948 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02018b4:	00005597          	auipc	a1,0x5
ffffffffc02018b8:	77458593          	addi	a1,a1,1908 # ffffffffc0207028 <free_area>
ffffffffc02018bc:	0105a803          	lw	a6,16(a1)
ffffffffc02018c0:	862a                	mv	a2,a0
ffffffffc02018c2:	02081793          	slli	a5,a6,0x20
ffffffffc02018c6:	9381                	srli	a5,a5,0x20
ffffffffc02018c8:	00a7ee63          	bltu	a5,a0,ffffffffc02018e4 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02018cc:	87ae                	mv	a5,a1
ffffffffc02018ce:	a801                	j	ffffffffc02018de <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02018d0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02018d4:	02071693          	slli	a3,a4,0x20
ffffffffc02018d8:	9281                	srli	a3,a3,0x20
ffffffffc02018da:	00c6f763          	bgeu	a3,a2,ffffffffc02018e8 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02018de:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02018e0:	feb798e3          	bne	a5,a1,ffffffffc02018d0 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02018e4:	4501                	li	a0,0
}
ffffffffc02018e6:	8082                	ret
    return listelm->prev;
ffffffffc02018e8:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02018ec:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02018f0:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02018f4:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02018f8:	0068b423          	sd	t1,8(a7) # fffffffffff80008 <end+0x3fd78b68>
    next->prev = prev;
ffffffffc02018fc:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201900:	02d67b63          	bgeu	a2,a3,ffffffffc0201936 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc0201904:	00261693          	slli	a3,a2,0x2
ffffffffc0201908:	96b2                	add	a3,a3,a2
ffffffffc020190a:	068e                	slli	a3,a3,0x3
ffffffffc020190c:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc020190e:	41c7073b          	subw	a4,a4,t3
ffffffffc0201912:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201914:	00868613          	addi	a2,a3,8
ffffffffc0201918:	4709                	li	a4,2
ffffffffc020191a:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020191e:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201922:	01868613          	addi	a2,a3,24
        nr_free -= n;
ffffffffc0201926:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020192a:	e310                	sd	a2,0(a4)
ffffffffc020192c:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201930:	f298                	sd	a4,32(a3)
    elm->prev = prev;
ffffffffc0201932:	0116bc23          	sd	a7,24(a3)
ffffffffc0201936:	41c8083b          	subw	a6,a6,t3
ffffffffc020193a:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020193e:	5775                	li	a4,-3
ffffffffc0201940:	17c1                	addi	a5,a5,-16
ffffffffc0201942:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201946:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201948:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020194a:	00001697          	auipc	a3,0x1
ffffffffc020194e:	52e68693          	addi	a3,a3,1326 # ffffffffc0202e78 <commands+0xbd8>
ffffffffc0201952:	00001617          	auipc	a2,0x1
ffffffffc0201956:	1ce60613          	addi	a2,a2,462 # ffffffffc0202b20 <commands+0x880>
ffffffffc020195a:	06200593          	li	a1,98
ffffffffc020195e:	00001517          	auipc	a0,0x1
ffffffffc0201962:	1da50513          	addi	a0,a0,474 # ffffffffc0202b38 <commands+0x898>
default_alloc_pages(size_t n) {
ffffffffc0201966:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201968:	ffcfe0ef          	jal	ra,ffffffffc0200164 <__panic>

ffffffffc020196c <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020196c:	1141                	addi	sp,sp,-16
ffffffffc020196e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201970:	c9e1                	beqz	a1,ffffffffc0201a40 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201972:	00259693          	slli	a3,a1,0x2
ffffffffc0201976:	96ae                	add	a3,a3,a1
ffffffffc0201978:	068e                	slli	a3,a3,0x3
ffffffffc020197a:	96aa                	add	a3,a3,a0
ffffffffc020197c:	87aa                	mv	a5,a0
ffffffffc020197e:	00d50f63          	beq	a0,a3,ffffffffc020199c <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201982:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201984:	8b05                	andi	a4,a4,1
ffffffffc0201986:	cf49                	beqz	a4,ffffffffc0201a20 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201988:	0007a823          	sw	zero,16(a5)
ffffffffc020198c:	0007b423          	sd	zero,8(a5)
ffffffffc0201990:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201994:	02878793          	addi	a5,a5,40
ffffffffc0201998:	fed795e3          	bne	a5,a3,ffffffffc0201982 <default_init_memmap+0x16>
    base->property = n;
ffffffffc020199c:	2581                	sext.w	a1,a1
ffffffffc020199e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02019a0:	4789                	li	a5,2
ffffffffc02019a2:	00850713          	addi	a4,a0,8
ffffffffc02019a6:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02019aa:	00005697          	auipc	a3,0x5
ffffffffc02019ae:	67e68693          	addi	a3,a3,1662 # ffffffffc0207028 <free_area>
ffffffffc02019b2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02019b4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02019b6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02019ba:	9db9                	addw	a1,a1,a4
ffffffffc02019bc:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02019be:	04d78a63          	beq	a5,a3,ffffffffc0201a12 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02019c2:	fe878713          	addi	a4,a5,-24
ffffffffc02019c6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02019ca:	4581                	li	a1,0
            if (base < page) {
ffffffffc02019cc:	00e56a63          	bltu	a0,a4,ffffffffc02019e0 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02019d0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02019d2:	02d70263          	beq	a4,a3,ffffffffc02019f6 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02019d6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02019d8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02019dc:	fee57ae3          	bgeu	a0,a4,ffffffffc02019d0 <default_init_memmap+0x64>
ffffffffc02019e0:	c199                	beqz	a1,ffffffffc02019e6 <default_init_memmap+0x7a>
ffffffffc02019e2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02019e6:	6398                	ld	a4,0(a5)
}
ffffffffc02019e8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02019ea:	e390                	sd	a2,0(a5)
ffffffffc02019ec:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02019ee:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02019f0:	ed18                	sd	a4,24(a0)
ffffffffc02019f2:	0141                	addi	sp,sp,16
ffffffffc02019f4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02019f6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02019f8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02019fa:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02019fc:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02019fe:	00d70663          	beq	a4,a3,ffffffffc0201a0a <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0201a02:	8832                	mv	a6,a2
ffffffffc0201a04:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201a06:	87ba                	mv	a5,a4
ffffffffc0201a08:	bfc1                	j	ffffffffc02019d8 <default_init_memmap+0x6c>
}
ffffffffc0201a0a:	60a2                	ld	ra,8(sp)
ffffffffc0201a0c:	e290                	sd	a2,0(a3)
ffffffffc0201a0e:	0141                	addi	sp,sp,16
ffffffffc0201a10:	8082                	ret
ffffffffc0201a12:	60a2                	ld	ra,8(sp)
ffffffffc0201a14:	e390                	sd	a2,0(a5)
ffffffffc0201a16:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201a18:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201a1a:	ed1c                	sd	a5,24(a0)
ffffffffc0201a1c:	0141                	addi	sp,sp,16
ffffffffc0201a1e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201a20:	00001697          	auipc	a3,0x1
ffffffffc0201a24:	48868693          	addi	a3,a3,1160 # ffffffffc0202ea8 <commands+0xc08>
ffffffffc0201a28:	00001617          	auipc	a2,0x1
ffffffffc0201a2c:	0f860613          	addi	a2,a2,248 # ffffffffc0202b20 <commands+0x880>
ffffffffc0201a30:	04900593          	li	a1,73
ffffffffc0201a34:	00001517          	auipc	a0,0x1
ffffffffc0201a38:	10450513          	addi	a0,a0,260 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201a3c:	f28fe0ef          	jal	ra,ffffffffc0200164 <__panic>
    assert(n > 0);
ffffffffc0201a40:	00001697          	auipc	a3,0x1
ffffffffc0201a44:	43868693          	addi	a3,a3,1080 # ffffffffc0202e78 <commands+0xbd8>
ffffffffc0201a48:	00001617          	auipc	a2,0x1
ffffffffc0201a4c:	0d860613          	addi	a2,a2,216 # ffffffffc0202b20 <commands+0x880>
ffffffffc0201a50:	04600593          	li	a1,70
ffffffffc0201a54:	00001517          	auipc	a0,0x1
ffffffffc0201a58:	0e450513          	addi	a0,a0,228 # ffffffffc0202b38 <commands+0x898>
ffffffffc0201a5c:	f08fe0ef          	jal	ra,ffffffffc0200164 <__panic>

ffffffffc0201a60 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201a60:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0201a64:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0201a66:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0201a68:	cb81                	beqz	a5,ffffffffc0201a78 <strlen+0x18>
        cnt ++;
ffffffffc0201a6a:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0201a6c:	00a707b3          	add	a5,a4,a0
ffffffffc0201a70:	0007c783          	lbu	a5,0(a5)
ffffffffc0201a74:	fbfd                	bnez	a5,ffffffffc0201a6a <strlen+0xa>
ffffffffc0201a76:	8082                	ret
    }
    return cnt;
}
ffffffffc0201a78:	8082                	ret

ffffffffc0201a7a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201a7a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a7c:	e589                	bnez	a1,ffffffffc0201a86 <strnlen+0xc>
ffffffffc0201a7e:	a811                	j	ffffffffc0201a92 <strnlen+0x18>
        cnt ++;
ffffffffc0201a80:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a82:	00f58863          	beq	a1,a5,ffffffffc0201a92 <strnlen+0x18>
ffffffffc0201a86:	00f50733          	add	a4,a0,a5
ffffffffc0201a8a:	00074703          	lbu	a4,0(a4)
ffffffffc0201a8e:	fb6d                	bnez	a4,ffffffffc0201a80 <strnlen+0x6>
ffffffffc0201a90:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201a92:	852e                	mv	a0,a1
ffffffffc0201a94:	8082                	ret

ffffffffc0201a96 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a96:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a9a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a9e:	cb89                	beqz	a5,ffffffffc0201ab0 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201aa0:	0505                	addi	a0,a0,1
ffffffffc0201aa2:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201aa4:	fee789e3          	beq	a5,a4,ffffffffc0201a96 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201aa8:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201aac:	9d19                	subw	a0,a0,a4
ffffffffc0201aae:	8082                	ret
ffffffffc0201ab0:	4501                	li	a0,0
ffffffffc0201ab2:	bfed                	j	ffffffffc0201aac <strcmp+0x16>

ffffffffc0201ab4 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201ab4:	c20d                	beqz	a2,ffffffffc0201ad6 <strncmp+0x22>
ffffffffc0201ab6:	962e                	add	a2,a2,a1
ffffffffc0201ab8:	a031                	j	ffffffffc0201ac4 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201aba:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201abc:	00e79a63          	bne	a5,a4,ffffffffc0201ad0 <strncmp+0x1c>
ffffffffc0201ac0:	00b60b63          	beq	a2,a1,ffffffffc0201ad6 <strncmp+0x22>
ffffffffc0201ac4:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201ac8:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201aca:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201ace:	f7f5                	bnez	a5,ffffffffc0201aba <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201ad0:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201ad4:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201ad6:	4501                	li	a0,0
ffffffffc0201ad8:	8082                	ret

ffffffffc0201ada <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201ada:	00054783          	lbu	a5,0(a0)
ffffffffc0201ade:	c799                	beqz	a5,ffffffffc0201aec <strchr+0x12>
        if (*s == c) {
ffffffffc0201ae0:	00f58763          	beq	a1,a5,ffffffffc0201aee <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201ae4:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201ae8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201aea:	fbfd                	bnez	a5,ffffffffc0201ae0 <strchr+0x6>
    }
    return NULL;
ffffffffc0201aec:	4501                	li	a0,0
}
ffffffffc0201aee:	8082                	ret

ffffffffc0201af0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201af0:	ca01                	beqz	a2,ffffffffc0201b00 <memset+0x10>
ffffffffc0201af2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201af4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201af6:	0785                	addi	a5,a5,1
ffffffffc0201af8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201afc:	fec79de3          	bne	a5,a2,ffffffffc0201af6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201b00:	8082                	ret

ffffffffc0201b02 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0201b02:	ca19                	beqz	a2,ffffffffc0201b18 <memcpy+0x16>
ffffffffc0201b04:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0201b06:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0201b08:	0005c703          	lbu	a4,0(a1)
ffffffffc0201b0c:	0585                	addi	a1,a1,1
ffffffffc0201b0e:	0785                	addi	a5,a5,1
ffffffffc0201b10:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0201b14:	fec59ae3          	bne	a1,a2,ffffffffc0201b08 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0201b18:	8082                	ret

ffffffffc0201b1a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201b1a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201b1e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201b20:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201b24:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201b26:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201b2a:	f022                	sd	s0,32(sp)
ffffffffc0201b2c:	ec26                	sd	s1,24(sp)
ffffffffc0201b2e:	e84a                	sd	s2,16(sp)
ffffffffc0201b30:	f406                	sd	ra,40(sp)
ffffffffc0201b32:	e44e                	sd	s3,8(sp)
ffffffffc0201b34:	84aa                	mv	s1,a0
ffffffffc0201b36:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201b38:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201b3c:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201b3e:	03067e63          	bgeu	a2,a6,ffffffffc0201b7a <printnum+0x60>
ffffffffc0201b42:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201b44:	00805763          	blez	s0,ffffffffc0201b52 <printnum+0x38>
ffffffffc0201b48:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201b4a:	85ca                	mv	a1,s2
ffffffffc0201b4c:	854e                	mv	a0,s3
ffffffffc0201b4e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201b50:	fc65                	bnez	s0,ffffffffc0201b48 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201b52:	1a02                	slli	s4,s4,0x20
ffffffffc0201b54:	00001797          	auipc	a5,0x1
ffffffffc0201b58:	3b478793          	addi	a5,a5,948 # ffffffffc0202f08 <default_pmm_manager+0x38>
ffffffffc0201b5c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201b60:	9a3e                	add	s4,s4,a5
}
ffffffffc0201b62:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201b64:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201b68:	70a2                	ld	ra,40(sp)
ffffffffc0201b6a:	69a2                	ld	s3,8(sp)
ffffffffc0201b6c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201b6e:	85ca                	mv	a1,s2
ffffffffc0201b70:	87a6                	mv	a5,s1
}
ffffffffc0201b72:	6942                	ld	s2,16(sp)
ffffffffc0201b74:	64e2                	ld	s1,24(sp)
ffffffffc0201b76:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201b78:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201b7a:	03065633          	divu	a2,a2,a6
ffffffffc0201b7e:	8722                	mv	a4,s0
ffffffffc0201b80:	f9bff0ef          	jal	ra,ffffffffc0201b1a <printnum>
ffffffffc0201b84:	b7f9                	j	ffffffffc0201b52 <printnum+0x38>

ffffffffc0201b86 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201b86:	7119                	addi	sp,sp,-128
ffffffffc0201b88:	f4a6                	sd	s1,104(sp)
ffffffffc0201b8a:	f0ca                	sd	s2,96(sp)
ffffffffc0201b8c:	ecce                	sd	s3,88(sp)
ffffffffc0201b8e:	e8d2                	sd	s4,80(sp)
ffffffffc0201b90:	e4d6                	sd	s5,72(sp)
ffffffffc0201b92:	e0da                	sd	s6,64(sp)
ffffffffc0201b94:	fc5e                	sd	s7,56(sp)
ffffffffc0201b96:	f06a                	sd	s10,32(sp)
ffffffffc0201b98:	fc86                	sd	ra,120(sp)
ffffffffc0201b9a:	f8a2                	sd	s0,112(sp)
ffffffffc0201b9c:	f862                	sd	s8,48(sp)
ffffffffc0201b9e:	f466                	sd	s9,40(sp)
ffffffffc0201ba0:	ec6e                	sd	s11,24(sp)
ffffffffc0201ba2:	892a                	mv	s2,a0
ffffffffc0201ba4:	84ae                	mv	s1,a1
ffffffffc0201ba6:	8d32                	mv	s10,a2
ffffffffc0201ba8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201baa:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201bae:	5b7d                	li	s6,-1
ffffffffc0201bb0:	00001a97          	auipc	s5,0x1
ffffffffc0201bb4:	38ca8a93          	addi	s5,s5,908 # ffffffffc0202f3c <default_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201bb8:	00001b97          	auipc	s7,0x1
ffffffffc0201bbc:	560b8b93          	addi	s7,s7,1376 # ffffffffc0203118 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201bc0:	000d4503          	lbu	a0,0(s10)
ffffffffc0201bc4:	001d0413          	addi	s0,s10,1
ffffffffc0201bc8:	01350a63          	beq	a0,s3,ffffffffc0201bdc <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201bcc:	c121                	beqz	a0,ffffffffc0201c0c <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201bce:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201bd0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201bd2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201bd4:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201bd8:	ff351ae3          	bne	a0,s3,ffffffffc0201bcc <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bdc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201be0:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201be4:	4c81                	li	s9,0
ffffffffc0201be6:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201be8:	5c7d                	li	s8,-1
ffffffffc0201bea:	5dfd                	li	s11,-1
ffffffffc0201bec:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201bf0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bf2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201bf6:	0ff5f593          	zext.b	a1,a1
ffffffffc0201bfa:	00140d13          	addi	s10,s0,1
ffffffffc0201bfe:	04b56263          	bltu	a0,a1,ffffffffc0201c42 <vprintfmt+0xbc>
ffffffffc0201c02:	058a                	slli	a1,a1,0x2
ffffffffc0201c04:	95d6                	add	a1,a1,s5
ffffffffc0201c06:	4194                	lw	a3,0(a1)
ffffffffc0201c08:	96d6                	add	a3,a3,s5
ffffffffc0201c0a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201c0c:	70e6                	ld	ra,120(sp)
ffffffffc0201c0e:	7446                	ld	s0,112(sp)
ffffffffc0201c10:	74a6                	ld	s1,104(sp)
ffffffffc0201c12:	7906                	ld	s2,96(sp)
ffffffffc0201c14:	69e6                	ld	s3,88(sp)
ffffffffc0201c16:	6a46                	ld	s4,80(sp)
ffffffffc0201c18:	6aa6                	ld	s5,72(sp)
ffffffffc0201c1a:	6b06                	ld	s6,64(sp)
ffffffffc0201c1c:	7be2                	ld	s7,56(sp)
ffffffffc0201c1e:	7c42                	ld	s8,48(sp)
ffffffffc0201c20:	7ca2                	ld	s9,40(sp)
ffffffffc0201c22:	7d02                	ld	s10,32(sp)
ffffffffc0201c24:	6de2                	ld	s11,24(sp)
ffffffffc0201c26:	6109                	addi	sp,sp,128
ffffffffc0201c28:	8082                	ret
            padc = '0';
ffffffffc0201c2a:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201c2c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c30:	846a                	mv	s0,s10
ffffffffc0201c32:	00140d13          	addi	s10,s0,1
ffffffffc0201c36:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201c3a:	0ff5f593          	zext.b	a1,a1
ffffffffc0201c3e:	fcb572e3          	bgeu	a0,a1,ffffffffc0201c02 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201c42:	85a6                	mv	a1,s1
ffffffffc0201c44:	02500513          	li	a0,37
ffffffffc0201c48:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201c4a:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201c4e:	8d22                	mv	s10,s0
ffffffffc0201c50:	f73788e3          	beq	a5,s3,ffffffffc0201bc0 <vprintfmt+0x3a>
ffffffffc0201c54:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201c58:	1d7d                	addi	s10,s10,-1
ffffffffc0201c5a:	ff379de3          	bne	a5,s3,ffffffffc0201c54 <vprintfmt+0xce>
ffffffffc0201c5e:	b78d                	j	ffffffffc0201bc0 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201c60:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201c64:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c68:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201c6a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201c6e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201c72:	02d86463          	bltu	a6,a3,ffffffffc0201c9a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201c76:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201c7a:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201c7e:	0186873b          	addw	a4,a3,s8
ffffffffc0201c82:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201c86:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201c88:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201c8c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201c8e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201c92:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201c96:	fed870e3          	bgeu	a6,a3,ffffffffc0201c76 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201c9a:	f40ddce3          	bgez	s11,ffffffffc0201bf2 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201c9e:	8de2                	mv	s11,s8
ffffffffc0201ca0:	5c7d                	li	s8,-1
ffffffffc0201ca2:	bf81                	j	ffffffffc0201bf2 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201ca4:	fffdc693          	not	a3,s11
ffffffffc0201ca8:	96fd                	srai	a3,a3,0x3f
ffffffffc0201caa:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201cae:	00144603          	lbu	a2,1(s0)
ffffffffc0201cb2:	2d81                	sext.w	s11,s11
ffffffffc0201cb4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201cb6:	bf35                	j	ffffffffc0201bf2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201cb8:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201cbc:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201cc0:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201cc2:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201cc4:	bfd9                	j	ffffffffc0201c9a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201cc6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201cc8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201ccc:	01174463          	blt	a4,a7,ffffffffc0201cd4 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201cd0:	1a088e63          	beqz	a7,ffffffffc0201e8c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201cd4:	000a3603          	ld	a2,0(s4)
ffffffffc0201cd8:	46c1                	li	a3,16
ffffffffc0201cda:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201cdc:	2781                	sext.w	a5,a5
ffffffffc0201cde:	876e                	mv	a4,s11
ffffffffc0201ce0:	85a6                	mv	a1,s1
ffffffffc0201ce2:	854a                	mv	a0,s2
ffffffffc0201ce4:	e37ff0ef          	jal	ra,ffffffffc0201b1a <printnum>
            break;
ffffffffc0201ce8:	bde1                	j	ffffffffc0201bc0 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201cea:	000a2503          	lw	a0,0(s4)
ffffffffc0201cee:	85a6                	mv	a1,s1
ffffffffc0201cf0:	0a21                	addi	s4,s4,8
ffffffffc0201cf2:	9902                	jalr	s2
            break;
ffffffffc0201cf4:	b5f1                	j	ffffffffc0201bc0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201cf6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201cf8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201cfc:	01174463          	blt	a4,a7,ffffffffc0201d04 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201d00:	18088163          	beqz	a7,ffffffffc0201e82 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201d04:	000a3603          	ld	a2,0(s4)
ffffffffc0201d08:	46a9                	li	a3,10
ffffffffc0201d0a:	8a2e                	mv	s4,a1
ffffffffc0201d0c:	bfc1                	j	ffffffffc0201cdc <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201d0e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201d12:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201d14:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201d16:	bdf1                	j	ffffffffc0201bf2 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201d18:	85a6                	mv	a1,s1
ffffffffc0201d1a:	02500513          	li	a0,37
ffffffffc0201d1e:	9902                	jalr	s2
            break;
ffffffffc0201d20:	b545                	j	ffffffffc0201bc0 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201d22:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201d26:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201d28:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201d2a:	b5e1                	j	ffffffffc0201bf2 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201d2c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201d2e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201d32:	01174463          	blt	a4,a7,ffffffffc0201d3a <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201d36:	14088163          	beqz	a7,ffffffffc0201e78 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201d3a:	000a3603          	ld	a2,0(s4)
ffffffffc0201d3e:	46a1                	li	a3,8
ffffffffc0201d40:	8a2e                	mv	s4,a1
ffffffffc0201d42:	bf69                	j	ffffffffc0201cdc <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201d44:	03000513          	li	a0,48
ffffffffc0201d48:	85a6                	mv	a1,s1
ffffffffc0201d4a:	e03e                	sd	a5,0(sp)
ffffffffc0201d4c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201d4e:	85a6                	mv	a1,s1
ffffffffc0201d50:	07800513          	li	a0,120
ffffffffc0201d54:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201d56:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201d58:	6782                	ld	a5,0(sp)
ffffffffc0201d5a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201d5c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201d60:	bfb5                	j	ffffffffc0201cdc <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201d62:	000a3403          	ld	s0,0(s4)
ffffffffc0201d66:	008a0713          	addi	a4,s4,8
ffffffffc0201d6a:	e03a                	sd	a4,0(sp)
ffffffffc0201d6c:	14040263          	beqz	s0,ffffffffc0201eb0 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201d70:	0fb05763          	blez	s11,ffffffffc0201e5e <vprintfmt+0x2d8>
ffffffffc0201d74:	02d00693          	li	a3,45
ffffffffc0201d78:	0cd79163          	bne	a5,a3,ffffffffc0201e3a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d7c:	00044783          	lbu	a5,0(s0)
ffffffffc0201d80:	0007851b          	sext.w	a0,a5
ffffffffc0201d84:	cf85                	beqz	a5,ffffffffc0201dbc <vprintfmt+0x236>
ffffffffc0201d86:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201d8a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d8e:	000c4563          	bltz	s8,ffffffffc0201d98 <vprintfmt+0x212>
ffffffffc0201d92:	3c7d                	addiw	s8,s8,-1
ffffffffc0201d94:	036c0263          	beq	s8,s6,ffffffffc0201db8 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201d98:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201d9a:	0e0c8e63          	beqz	s9,ffffffffc0201e96 <vprintfmt+0x310>
ffffffffc0201d9e:	3781                	addiw	a5,a5,-32
ffffffffc0201da0:	0ef47b63          	bgeu	s0,a5,ffffffffc0201e96 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201da4:	03f00513          	li	a0,63
ffffffffc0201da8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201daa:	000a4783          	lbu	a5,0(s4)
ffffffffc0201dae:	3dfd                	addiw	s11,s11,-1
ffffffffc0201db0:	0a05                	addi	s4,s4,1
ffffffffc0201db2:	0007851b          	sext.w	a0,a5
ffffffffc0201db6:	ffe1                	bnez	a5,ffffffffc0201d8e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201db8:	01b05963          	blez	s11,ffffffffc0201dca <vprintfmt+0x244>
ffffffffc0201dbc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201dbe:	85a6                	mv	a1,s1
ffffffffc0201dc0:	02000513          	li	a0,32
ffffffffc0201dc4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201dc6:	fe0d9be3          	bnez	s11,ffffffffc0201dbc <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201dca:	6a02                	ld	s4,0(sp)
ffffffffc0201dcc:	bbd5                	j	ffffffffc0201bc0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201dce:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201dd0:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201dd4:	01174463          	blt	a4,a7,ffffffffc0201ddc <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201dd8:	08088d63          	beqz	a7,ffffffffc0201e72 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201ddc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201de0:	0a044d63          	bltz	s0,ffffffffc0201e9a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201de4:	8622                	mv	a2,s0
ffffffffc0201de6:	8a66                	mv	s4,s9
ffffffffc0201de8:	46a9                	li	a3,10
ffffffffc0201dea:	bdcd                	j	ffffffffc0201cdc <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201dec:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201df0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201df2:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201df4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201df8:	8fb5                	xor	a5,a5,a3
ffffffffc0201dfa:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201dfe:	02d74163          	blt	a4,a3,ffffffffc0201e20 <vprintfmt+0x29a>
ffffffffc0201e02:	00369793          	slli	a5,a3,0x3
ffffffffc0201e06:	97de                	add	a5,a5,s7
ffffffffc0201e08:	639c                	ld	a5,0(a5)
ffffffffc0201e0a:	cb99                	beqz	a5,ffffffffc0201e20 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201e0c:	86be                	mv	a3,a5
ffffffffc0201e0e:	00001617          	auipc	a2,0x1
ffffffffc0201e12:	12a60613          	addi	a2,a2,298 # ffffffffc0202f38 <default_pmm_manager+0x68>
ffffffffc0201e16:	85a6                	mv	a1,s1
ffffffffc0201e18:	854a                	mv	a0,s2
ffffffffc0201e1a:	0ce000ef          	jal	ra,ffffffffc0201ee8 <printfmt>
ffffffffc0201e1e:	b34d                	j	ffffffffc0201bc0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201e20:	00001617          	auipc	a2,0x1
ffffffffc0201e24:	10860613          	addi	a2,a2,264 # ffffffffc0202f28 <default_pmm_manager+0x58>
ffffffffc0201e28:	85a6                	mv	a1,s1
ffffffffc0201e2a:	854a                	mv	a0,s2
ffffffffc0201e2c:	0bc000ef          	jal	ra,ffffffffc0201ee8 <printfmt>
ffffffffc0201e30:	bb41                	j	ffffffffc0201bc0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201e32:	00001417          	auipc	s0,0x1
ffffffffc0201e36:	0ee40413          	addi	s0,s0,238 # ffffffffc0202f20 <default_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201e3a:	85e2                	mv	a1,s8
ffffffffc0201e3c:	8522                	mv	a0,s0
ffffffffc0201e3e:	e43e                	sd	a5,8(sp)
ffffffffc0201e40:	c3bff0ef          	jal	ra,ffffffffc0201a7a <strnlen>
ffffffffc0201e44:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201e48:	01b05b63          	blez	s11,ffffffffc0201e5e <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201e4c:	67a2                	ld	a5,8(sp)
ffffffffc0201e4e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201e52:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201e54:	85a6                	mv	a1,s1
ffffffffc0201e56:	8552                	mv	a0,s4
ffffffffc0201e58:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201e5a:	fe0d9ce3          	bnez	s11,ffffffffc0201e52 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201e5e:	00044783          	lbu	a5,0(s0)
ffffffffc0201e62:	00140a13          	addi	s4,s0,1
ffffffffc0201e66:	0007851b          	sext.w	a0,a5
ffffffffc0201e6a:	d3a5                	beqz	a5,ffffffffc0201dca <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201e6c:	05e00413          	li	s0,94
ffffffffc0201e70:	bf39                	j	ffffffffc0201d8e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201e72:	000a2403          	lw	s0,0(s4)
ffffffffc0201e76:	b7ad                	j	ffffffffc0201de0 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201e78:	000a6603          	lwu	a2,0(s4)
ffffffffc0201e7c:	46a1                	li	a3,8
ffffffffc0201e7e:	8a2e                	mv	s4,a1
ffffffffc0201e80:	bdb1                	j	ffffffffc0201cdc <vprintfmt+0x156>
ffffffffc0201e82:	000a6603          	lwu	a2,0(s4)
ffffffffc0201e86:	46a9                	li	a3,10
ffffffffc0201e88:	8a2e                	mv	s4,a1
ffffffffc0201e8a:	bd89                	j	ffffffffc0201cdc <vprintfmt+0x156>
ffffffffc0201e8c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201e90:	46c1                	li	a3,16
ffffffffc0201e92:	8a2e                	mv	s4,a1
ffffffffc0201e94:	b5a1                	j	ffffffffc0201cdc <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201e96:	9902                	jalr	s2
ffffffffc0201e98:	bf09                	j	ffffffffc0201daa <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201e9a:	85a6                	mv	a1,s1
ffffffffc0201e9c:	02d00513          	li	a0,45
ffffffffc0201ea0:	e03e                	sd	a5,0(sp)
ffffffffc0201ea2:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201ea4:	6782                	ld	a5,0(sp)
ffffffffc0201ea6:	8a66                	mv	s4,s9
ffffffffc0201ea8:	40800633          	neg	a2,s0
ffffffffc0201eac:	46a9                	li	a3,10
ffffffffc0201eae:	b53d                	j	ffffffffc0201cdc <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201eb0:	03b05163          	blez	s11,ffffffffc0201ed2 <vprintfmt+0x34c>
ffffffffc0201eb4:	02d00693          	li	a3,45
ffffffffc0201eb8:	f6d79de3          	bne	a5,a3,ffffffffc0201e32 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201ebc:	00001417          	auipc	s0,0x1
ffffffffc0201ec0:	06440413          	addi	s0,s0,100 # ffffffffc0202f20 <default_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201ec4:	02800793          	li	a5,40
ffffffffc0201ec8:	02800513          	li	a0,40
ffffffffc0201ecc:	00140a13          	addi	s4,s0,1
ffffffffc0201ed0:	bd6d                	j	ffffffffc0201d8a <vprintfmt+0x204>
ffffffffc0201ed2:	00001a17          	auipc	s4,0x1
ffffffffc0201ed6:	04fa0a13          	addi	s4,s4,79 # ffffffffc0202f21 <default_pmm_manager+0x51>
ffffffffc0201eda:	02800513          	li	a0,40
ffffffffc0201ede:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201ee2:	05e00413          	li	s0,94
ffffffffc0201ee6:	b565                	j	ffffffffc0201d8e <vprintfmt+0x208>

ffffffffc0201ee8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201ee8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201eea:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201eee:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201ef0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201ef2:	ec06                	sd	ra,24(sp)
ffffffffc0201ef4:	f83a                	sd	a4,48(sp)
ffffffffc0201ef6:	fc3e                	sd	a5,56(sp)
ffffffffc0201ef8:	e0c2                	sd	a6,64(sp)
ffffffffc0201efa:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201efc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201efe:	c89ff0ef          	jal	ra,ffffffffc0201b86 <vprintfmt>
}
ffffffffc0201f02:	60e2                	ld	ra,24(sp)
ffffffffc0201f04:	6161                	addi	sp,sp,80
ffffffffc0201f06:	8082                	ret

ffffffffc0201f08 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201f08:	715d                	addi	sp,sp,-80
ffffffffc0201f0a:	e486                	sd	ra,72(sp)
ffffffffc0201f0c:	e0a6                	sd	s1,64(sp)
ffffffffc0201f0e:	fc4a                	sd	s2,56(sp)
ffffffffc0201f10:	f84e                	sd	s3,48(sp)
ffffffffc0201f12:	f452                	sd	s4,40(sp)
ffffffffc0201f14:	f056                	sd	s5,32(sp)
ffffffffc0201f16:	ec5a                	sd	s6,24(sp)
ffffffffc0201f18:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201f1a:	c901                	beqz	a0,ffffffffc0201f2a <readline+0x22>
ffffffffc0201f1c:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201f1e:	00001517          	auipc	a0,0x1
ffffffffc0201f22:	01a50513          	addi	a0,a0,26 # ffffffffc0202f38 <default_pmm_manager+0x68>
ffffffffc0201f26:	9b6fe0ef          	jal	ra,ffffffffc02000dc <cprintf>
readline(const char *prompt) {
ffffffffc0201f2a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201f2c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201f2e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201f30:	4aa9                	li	s5,10
ffffffffc0201f32:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201f34:	00005b97          	auipc	s7,0x5
ffffffffc0201f38:	10cb8b93          	addi	s7,s7,268 # ffffffffc0207040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201f3c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201f40:	a14fe0ef          	jal	ra,ffffffffc0200154 <getchar>
        if (c < 0) {
ffffffffc0201f44:	00054a63          	bltz	a0,ffffffffc0201f58 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201f48:	00a95a63          	bge	s2,a0,ffffffffc0201f5c <readline+0x54>
ffffffffc0201f4c:	029a5263          	bge	s4,s1,ffffffffc0201f70 <readline+0x68>
        c = getchar();
ffffffffc0201f50:	a04fe0ef          	jal	ra,ffffffffc0200154 <getchar>
        if (c < 0) {
ffffffffc0201f54:	fe055ae3          	bgez	a0,ffffffffc0201f48 <readline+0x40>
            return NULL;
ffffffffc0201f58:	4501                	li	a0,0
ffffffffc0201f5a:	a091                	j	ffffffffc0201f9e <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201f5c:	03351463          	bne	a0,s3,ffffffffc0201f84 <readline+0x7c>
ffffffffc0201f60:	e8a9                	bnez	s1,ffffffffc0201fb2 <readline+0xaa>
        c = getchar();
ffffffffc0201f62:	9f2fe0ef          	jal	ra,ffffffffc0200154 <getchar>
        if (c < 0) {
ffffffffc0201f66:	fe0549e3          	bltz	a0,ffffffffc0201f58 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201f6a:	fea959e3          	bge	s2,a0,ffffffffc0201f5c <readline+0x54>
ffffffffc0201f6e:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201f70:	e42a                	sd	a0,8(sp)
ffffffffc0201f72:	9a0fe0ef          	jal	ra,ffffffffc0200112 <cputchar>
            buf[i ++] = c;
ffffffffc0201f76:	6522                	ld	a0,8(sp)
ffffffffc0201f78:	009b87b3          	add	a5,s7,s1
ffffffffc0201f7c:	2485                	addiw	s1,s1,1
ffffffffc0201f7e:	00a78023          	sb	a0,0(a5)
ffffffffc0201f82:	bf7d                	j	ffffffffc0201f40 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201f84:	01550463          	beq	a0,s5,ffffffffc0201f8c <readline+0x84>
ffffffffc0201f88:	fb651ce3          	bne	a0,s6,ffffffffc0201f40 <readline+0x38>
            cputchar(c);
ffffffffc0201f8c:	986fe0ef          	jal	ra,ffffffffc0200112 <cputchar>
            buf[i] = '\0';
ffffffffc0201f90:	00005517          	auipc	a0,0x5
ffffffffc0201f94:	0b050513          	addi	a0,a0,176 # ffffffffc0207040 <buf>
ffffffffc0201f98:	94aa                	add	s1,s1,a0
ffffffffc0201f9a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201f9e:	60a6                	ld	ra,72(sp)
ffffffffc0201fa0:	6486                	ld	s1,64(sp)
ffffffffc0201fa2:	7962                	ld	s2,56(sp)
ffffffffc0201fa4:	79c2                	ld	s3,48(sp)
ffffffffc0201fa6:	7a22                	ld	s4,40(sp)
ffffffffc0201fa8:	7a82                	ld	s5,32(sp)
ffffffffc0201faa:	6b62                	ld	s6,24(sp)
ffffffffc0201fac:	6bc2                	ld	s7,16(sp)
ffffffffc0201fae:	6161                	addi	sp,sp,80
ffffffffc0201fb0:	8082                	ret
            cputchar(c);
ffffffffc0201fb2:	4521                	li	a0,8
ffffffffc0201fb4:	95efe0ef          	jal	ra,ffffffffc0200112 <cputchar>
            i --;
ffffffffc0201fb8:	34fd                	addiw	s1,s1,-1
ffffffffc0201fba:	b759                	j	ffffffffc0201f40 <readline+0x38>

ffffffffc0201fbc <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201fbc:	4781                	li	a5,0
ffffffffc0201fbe:	00005717          	auipc	a4,0x5
ffffffffc0201fc2:	05a73703          	ld	a4,90(a4) # ffffffffc0207018 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201fc6:	88ba                	mv	a7,a4
ffffffffc0201fc8:	852a                	mv	a0,a0
ffffffffc0201fca:	85be                	mv	a1,a5
ffffffffc0201fcc:	863e                	mv	a2,a5
ffffffffc0201fce:	00000073          	ecall
ffffffffc0201fd2:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201fd4:	8082                	ret

ffffffffc0201fd6 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201fd6:	4781                	li	a5,0
ffffffffc0201fd8:	00005717          	auipc	a4,0x5
ffffffffc0201fdc:	4c073703          	ld	a4,1216(a4) # ffffffffc0207498 <SBI_SET_TIMER>
ffffffffc0201fe0:	88ba                	mv	a7,a4
ffffffffc0201fe2:	852a                	mv	a0,a0
ffffffffc0201fe4:	85be                	mv	a1,a5
ffffffffc0201fe6:	863e                	mv	a2,a5
ffffffffc0201fe8:	00000073          	ecall
ffffffffc0201fec:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201fee:	8082                	ret

ffffffffc0201ff0 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201ff0:	4501                	li	a0,0
ffffffffc0201ff2:	00005797          	auipc	a5,0x5
ffffffffc0201ff6:	01e7b783          	ld	a5,30(a5) # ffffffffc0207010 <SBI_CONSOLE_GETCHAR>
ffffffffc0201ffa:	88be                	mv	a7,a5
ffffffffc0201ffc:	852a                	mv	a0,a0
ffffffffc0201ffe:	85aa                	mv	a1,a0
ffffffffc0202000:	862a                	mv	a2,a0
ffffffffc0202002:	00000073          	ecall
ffffffffc0202006:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0202008:	2501                	sext.w	a0,a0
ffffffffc020200a:	8082                	ret

ffffffffc020200c <sbi_shutdown>:
    __asm__ volatile (
ffffffffc020200c:	4781                	li	a5,0
ffffffffc020200e:	00005717          	auipc	a4,0x5
ffffffffc0202012:	01273703          	ld	a4,18(a4) # ffffffffc0207020 <SBI_SHUTDOWN>
ffffffffc0202016:	88ba                	mv	a7,a4
ffffffffc0202018:	853e                	mv	a0,a5
ffffffffc020201a:	85be                	mv	a1,a5
ffffffffc020201c:	863e                	mv	a2,a5
ffffffffc020201e:	00000073          	ecall
ffffffffc0202022:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
	sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0202024:	8082                	ret
