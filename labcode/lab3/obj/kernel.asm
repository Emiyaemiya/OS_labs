
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00006297          	auipc	t0,0x6
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0206000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00006297          	auipc	t0,0x6
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0206008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02052b7          	lui	t0,0xc0205
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
ffffffffc020003c:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 1. 使用临时寄存器 t1 计算栈顶的精确地址
    lui t1, %hi(bootstacktop)
ffffffffc0200040:	c0205337          	lui	t1,0xc0205
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
ffffffffc0200054:	00006517          	auipc	a0,0x6
ffffffffc0200058:	fd450513          	addi	a0,a0,-44 # ffffffffc0206028 <free_area>
ffffffffc020005c:	00006617          	auipc	a2,0x6
ffffffffc0200060:	44460613          	addi	a2,a2,1092 # ffffffffc02064a0 <end>
int kern_init(void) {
ffffffffc0200064:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200066:	8e09                	sub	a2,a2,a0
ffffffffc0200068:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020006a:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020006c:	0c9010ef          	jal	ra,ffffffffc0201934 <memset>
    dtb_init();
ffffffffc0200070:	3c4000ef          	jal	ra,ffffffffc0200434 <dtb_init>
    cons_init();  // init the console
ffffffffc0200074:	7b4000ef          	jal	ra,ffffffffc0200828 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200078:	00002517          	auipc	a0,0x2
ffffffffc020007c:	df850513          	addi	a0,a0,-520 # ffffffffc0201e70 <etext+0x6>
ffffffffc0200080:	096000ef          	jal	ra,ffffffffc0200116 <cputs>

    print_kerninfo();
ffffffffc0200084:	13e000ef          	jal	ra,ffffffffc02001c2 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200088:	7ba000ef          	jal	ra,ffffffffc0200842 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020008c:	361000ef          	jal	ra,ffffffffc0200bec <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc0200090:	7b2000ef          	jal	ra,ffffffffc0200842 <idt_init>
    clock_init();   // init clock interrupt
ffffffffc0200094:	750000ef          	jal	ra,ffffffffc02007e4 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200098:	79e000ef          	jal	ra,ffffffffc0200836 <intr_enable>
    /* do nothing */
  asm volatile("ebreak");            // 触发 breakpoint 异常
ffffffffc020009c:	9002                	ebreak
ffffffffc020009e:	ffff                	0xffff
ffffffffc02000a0:	ffff                	0xffff
    asm volatile(".4byte 0xffffffff"); // 明确的非法 32 位指令，触发 illegal instruction
    
    while (1)
ffffffffc02000a2:	a001                	j	ffffffffc02000a2 <kern_init+0x4e>

ffffffffc02000a4 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc02000a4:	1141                	addi	sp,sp,-16
ffffffffc02000a6:	e022                	sd	s0,0(sp)
ffffffffc02000a8:	e406                	sd	ra,8(sp)
ffffffffc02000aa:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc02000ac:	77e000ef          	jal	ra,ffffffffc020082a <cons_putc>
    (*cnt) ++;
ffffffffc02000b0:	401c                	lw	a5,0(s0)
}
ffffffffc02000b2:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000b4:	2785                	addiw	a5,a5,1
ffffffffc02000b6:	c01c                	sw	a5,0(s0)
}
ffffffffc02000b8:	6402                	ld	s0,0(sp)
ffffffffc02000ba:	0141                	addi	sp,sp,16
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000be:	1101                	addi	sp,sp,-32
ffffffffc02000c0:	862a                	mv	a2,a0
ffffffffc02000c2:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	00000517          	auipc	a0,0x0
ffffffffc02000c8:	fe050513          	addi	a0,a0,-32 # ffffffffc02000a4 <cputch>
ffffffffc02000cc:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000d0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000d2:	0f9010ef          	jal	ra,ffffffffc02019ca <vprintfmt>
    return cnt;
}
ffffffffc02000d6:	60e2                	ld	ra,24(sp)
ffffffffc02000d8:	4532                	lw	a0,12(sp)
ffffffffc02000da:	6105                	addi	sp,sp,32
ffffffffc02000dc:	8082                	ret

ffffffffc02000de <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000de:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000e0:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000e4:	8e2a                	mv	t3,a0
ffffffffc02000e6:	f42e                	sd	a1,40(sp)
ffffffffc02000e8:	f832                	sd	a2,48(sp)
ffffffffc02000ea:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ec:	00000517          	auipc	a0,0x0
ffffffffc02000f0:	fb850513          	addi	a0,a0,-72 # ffffffffc02000a4 <cputch>
ffffffffc02000f4:	004c                	addi	a1,sp,4
ffffffffc02000f6:	869a                	mv	a3,t1
ffffffffc02000f8:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000fa:	ec06                	sd	ra,24(sp)
ffffffffc02000fc:	e0ba                	sd	a4,64(sp)
ffffffffc02000fe:	e4be                	sd	a5,72(sp)
ffffffffc0200100:	e8c2                	sd	a6,80(sp)
ffffffffc0200102:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200104:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200106:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200108:	0c3010ef          	jal	ra,ffffffffc02019ca <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020010c:	60e2                	ld	ra,24(sp)
ffffffffc020010e:	4512                	lw	a0,4(sp)
ffffffffc0200110:	6125                	addi	sp,sp,96
ffffffffc0200112:	8082                	ret

ffffffffc0200114 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200114:	af19                	j	ffffffffc020082a <cons_putc>

ffffffffc0200116 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200116:	1101                	addi	sp,sp,-32
ffffffffc0200118:	e822                	sd	s0,16(sp)
ffffffffc020011a:	ec06                	sd	ra,24(sp)
ffffffffc020011c:	e426                	sd	s1,8(sp)
ffffffffc020011e:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200120:	00054503          	lbu	a0,0(a0)
ffffffffc0200124:	c51d                	beqz	a0,ffffffffc0200152 <cputs+0x3c>
ffffffffc0200126:	0405                	addi	s0,s0,1
ffffffffc0200128:	4485                	li	s1,1
ffffffffc020012a:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020012c:	6fe000ef          	jal	ra,ffffffffc020082a <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200130:	00044503          	lbu	a0,0(s0)
ffffffffc0200134:	008487bb          	addw	a5,s1,s0
ffffffffc0200138:	0405                	addi	s0,s0,1
ffffffffc020013a:	f96d                	bnez	a0,ffffffffc020012c <cputs+0x16>
    (*cnt) ++;
ffffffffc020013c:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200140:	4529                	li	a0,10
ffffffffc0200142:	6e8000ef          	jal	ra,ffffffffc020082a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200146:	60e2                	ld	ra,24(sp)
ffffffffc0200148:	8522                	mv	a0,s0
ffffffffc020014a:	6442                	ld	s0,16(sp)
ffffffffc020014c:	64a2                	ld	s1,8(sp)
ffffffffc020014e:	6105                	addi	sp,sp,32
ffffffffc0200150:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200152:	4405                	li	s0,1
ffffffffc0200154:	b7f5                	j	ffffffffc0200140 <cputs+0x2a>

ffffffffc0200156 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200156:	1141                	addi	sp,sp,-16
ffffffffc0200158:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020015a:	6d8000ef          	jal	ra,ffffffffc0200832 <cons_getc>
ffffffffc020015e:	dd75                	beqz	a0,ffffffffc020015a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200160:	60a2                	ld	ra,8(sp)
ffffffffc0200162:	0141                	addi	sp,sp,16
ffffffffc0200164:	8082                	ret

ffffffffc0200166 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200166:	00006317          	auipc	t1,0x6
ffffffffc020016a:	2da30313          	addi	t1,t1,730 # ffffffffc0206440 <is_panic>
ffffffffc020016e:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200172:	715d                	addi	sp,sp,-80
ffffffffc0200174:	ec06                	sd	ra,24(sp)
ffffffffc0200176:	e822                	sd	s0,16(sp)
ffffffffc0200178:	f436                	sd	a3,40(sp)
ffffffffc020017a:	f83a                	sd	a4,48(sp)
ffffffffc020017c:	fc3e                	sd	a5,56(sp)
ffffffffc020017e:	e0c2                	sd	a6,64(sp)
ffffffffc0200180:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200182:	020e1a63          	bnez	t3,ffffffffc02001b6 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200186:	4785                	li	a5,1
ffffffffc0200188:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020018c:	8432                	mv	s0,a2
ffffffffc020018e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200190:	862e                	mv	a2,a1
ffffffffc0200192:	85aa                	mv	a1,a0
ffffffffc0200194:	00002517          	auipc	a0,0x2
ffffffffc0200198:	cfc50513          	addi	a0,a0,-772 # ffffffffc0201e90 <etext+0x26>
    va_start(ap, fmt);
ffffffffc020019c:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020019e:	f41ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    vcprintf(fmt, ap);
ffffffffc02001a2:	65a2                	ld	a1,8(sp)
ffffffffc02001a4:	8522                	mv	a0,s0
ffffffffc02001a6:	f19ff0ef          	jal	ra,ffffffffc02000be <vcprintf>
    cprintf("\n");
ffffffffc02001aa:	00002517          	auipc	a0,0x2
ffffffffc02001ae:	dce50513          	addi	a0,a0,-562 # ffffffffc0201f78 <etext+0x10e>
ffffffffc02001b2:	f2dff0ef          	jal	ra,ffffffffc02000de <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02001b6:	686000ef          	jal	ra,ffffffffc020083c <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02001ba:	4501                	li	a0,0
ffffffffc02001bc:	130000ef          	jal	ra,ffffffffc02002ec <kmonitor>
    while (1) {
ffffffffc02001c0:	bfed                	j	ffffffffc02001ba <__panic+0x54>

ffffffffc02001c2 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001c2:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001c4:	00002517          	auipc	a0,0x2
ffffffffc02001c8:	cec50513          	addi	a0,a0,-788 # ffffffffc0201eb0 <etext+0x46>
void print_kerninfo(void) {
ffffffffc02001cc:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001ce:	f11ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001d2:	00000597          	auipc	a1,0x0
ffffffffc02001d6:	e8258593          	addi	a1,a1,-382 # ffffffffc0200054 <kern_init>
ffffffffc02001da:	00002517          	auipc	a0,0x2
ffffffffc02001de:	cf650513          	addi	a0,a0,-778 # ffffffffc0201ed0 <etext+0x66>
ffffffffc02001e2:	efdff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001e6:	00002597          	auipc	a1,0x2
ffffffffc02001ea:	c8458593          	addi	a1,a1,-892 # ffffffffc0201e6a <etext>
ffffffffc02001ee:	00002517          	auipc	a0,0x2
ffffffffc02001f2:	d0250513          	addi	a0,a0,-766 # ffffffffc0201ef0 <etext+0x86>
ffffffffc02001f6:	ee9ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001fa:	00006597          	auipc	a1,0x6
ffffffffc02001fe:	e2e58593          	addi	a1,a1,-466 # ffffffffc0206028 <free_area>
ffffffffc0200202:	00002517          	auipc	a0,0x2
ffffffffc0200206:	d0e50513          	addi	a0,a0,-754 # ffffffffc0201f10 <etext+0xa6>
ffffffffc020020a:	ed5ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020020e:	00006597          	auipc	a1,0x6
ffffffffc0200212:	29258593          	addi	a1,a1,658 # ffffffffc02064a0 <end>
ffffffffc0200216:	00002517          	auipc	a0,0x2
ffffffffc020021a:	d1a50513          	addi	a0,a0,-742 # ffffffffc0201f30 <etext+0xc6>
ffffffffc020021e:	ec1ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200222:	00006597          	auipc	a1,0x6
ffffffffc0200226:	67d58593          	addi	a1,a1,1661 # ffffffffc020689f <end+0x3ff>
ffffffffc020022a:	00000797          	auipc	a5,0x0
ffffffffc020022e:	e2a78793          	addi	a5,a5,-470 # ffffffffc0200054 <kern_init>
ffffffffc0200232:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200236:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020023a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020023c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200240:	95be                	add	a1,a1,a5
ffffffffc0200242:	85a9                	srai	a1,a1,0xa
ffffffffc0200244:	00002517          	auipc	a0,0x2
ffffffffc0200248:	d0c50513          	addi	a0,a0,-756 # ffffffffc0201f50 <etext+0xe6>
}
ffffffffc020024c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024e:	bd41                	j	ffffffffc02000de <cprintf>

ffffffffc0200250 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200250:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200252:	00002617          	auipc	a2,0x2
ffffffffc0200256:	d2e60613          	addi	a2,a2,-722 # ffffffffc0201f80 <etext+0x116>
ffffffffc020025a:	04d00593          	li	a1,77
ffffffffc020025e:	00002517          	auipc	a0,0x2
ffffffffc0200262:	d3a50513          	addi	a0,a0,-710 # ffffffffc0201f98 <etext+0x12e>
void print_stackframe(void) {
ffffffffc0200266:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200268:	effff0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc020026c <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020026c:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020026e:	00002617          	auipc	a2,0x2
ffffffffc0200272:	d4260613          	addi	a2,a2,-702 # ffffffffc0201fb0 <etext+0x146>
ffffffffc0200276:	00002597          	auipc	a1,0x2
ffffffffc020027a:	d5a58593          	addi	a1,a1,-678 # ffffffffc0201fd0 <etext+0x166>
ffffffffc020027e:	00002517          	auipc	a0,0x2
ffffffffc0200282:	d5a50513          	addi	a0,a0,-678 # ffffffffc0201fd8 <etext+0x16e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200286:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200288:	e57ff0ef          	jal	ra,ffffffffc02000de <cprintf>
ffffffffc020028c:	00002617          	auipc	a2,0x2
ffffffffc0200290:	d5c60613          	addi	a2,a2,-676 # ffffffffc0201fe8 <etext+0x17e>
ffffffffc0200294:	00002597          	auipc	a1,0x2
ffffffffc0200298:	d7c58593          	addi	a1,a1,-644 # ffffffffc0202010 <etext+0x1a6>
ffffffffc020029c:	00002517          	auipc	a0,0x2
ffffffffc02002a0:	d3c50513          	addi	a0,a0,-708 # ffffffffc0201fd8 <etext+0x16e>
ffffffffc02002a4:	e3bff0ef          	jal	ra,ffffffffc02000de <cprintf>
ffffffffc02002a8:	00002617          	auipc	a2,0x2
ffffffffc02002ac:	d7860613          	addi	a2,a2,-648 # ffffffffc0202020 <etext+0x1b6>
ffffffffc02002b0:	00002597          	auipc	a1,0x2
ffffffffc02002b4:	d9058593          	addi	a1,a1,-624 # ffffffffc0202040 <etext+0x1d6>
ffffffffc02002b8:	00002517          	auipc	a0,0x2
ffffffffc02002bc:	d2050513          	addi	a0,a0,-736 # ffffffffc0201fd8 <etext+0x16e>
ffffffffc02002c0:	e1fff0ef          	jal	ra,ffffffffc02000de <cprintf>
    }
    return 0;
}
ffffffffc02002c4:	60a2                	ld	ra,8(sp)
ffffffffc02002c6:	4501                	li	a0,0
ffffffffc02002c8:	0141                	addi	sp,sp,16
ffffffffc02002ca:	8082                	ret

ffffffffc02002cc <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002cc:	1141                	addi	sp,sp,-16
ffffffffc02002ce:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002d0:	ef3ff0ef          	jal	ra,ffffffffc02001c2 <print_kerninfo>
    return 0;
}
ffffffffc02002d4:	60a2                	ld	ra,8(sp)
ffffffffc02002d6:	4501                	li	a0,0
ffffffffc02002d8:	0141                	addi	sp,sp,16
ffffffffc02002da:	8082                	ret

ffffffffc02002dc <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002dc:	1141                	addi	sp,sp,-16
ffffffffc02002de:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002e0:	f71ff0ef          	jal	ra,ffffffffc0200250 <print_stackframe>
    return 0;
}
ffffffffc02002e4:	60a2                	ld	ra,8(sp)
ffffffffc02002e6:	4501                	li	a0,0
ffffffffc02002e8:	0141                	addi	sp,sp,16
ffffffffc02002ea:	8082                	ret

ffffffffc02002ec <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002ec:	7115                	addi	sp,sp,-224
ffffffffc02002ee:	ed5e                	sd	s7,152(sp)
ffffffffc02002f0:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002f2:	00002517          	auipc	a0,0x2
ffffffffc02002f6:	d5e50513          	addi	a0,a0,-674 # ffffffffc0202050 <etext+0x1e6>
kmonitor(struct trapframe *tf) {
ffffffffc02002fa:	ed86                	sd	ra,216(sp)
ffffffffc02002fc:	e9a2                	sd	s0,208(sp)
ffffffffc02002fe:	e5a6                	sd	s1,200(sp)
ffffffffc0200300:	e1ca                	sd	s2,192(sp)
ffffffffc0200302:	fd4e                	sd	s3,184(sp)
ffffffffc0200304:	f952                	sd	s4,176(sp)
ffffffffc0200306:	f556                	sd	s5,168(sp)
ffffffffc0200308:	f15a                	sd	s6,160(sp)
ffffffffc020030a:	e962                	sd	s8,144(sp)
ffffffffc020030c:	e566                	sd	s9,136(sp)
ffffffffc020030e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200310:	dcfff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200314:	00002517          	auipc	a0,0x2
ffffffffc0200318:	d6450513          	addi	a0,a0,-668 # ffffffffc0202078 <etext+0x20e>
ffffffffc020031c:	dc3ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    if (tf != NULL) {
ffffffffc0200320:	000b8563          	beqz	s7,ffffffffc020032a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200324:	855e                	mv	a0,s7
ffffffffc0200326:	52e000ef          	jal	ra,ffffffffc0200854 <print_trapframe>
ffffffffc020032a:	00002c17          	auipc	s8,0x2
ffffffffc020032e:	dbec0c13          	addi	s8,s8,-578 # ffffffffc02020e8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200332:	00002917          	auipc	s2,0x2
ffffffffc0200336:	d6e90913          	addi	s2,s2,-658 # ffffffffc02020a0 <etext+0x236>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020033a:	00002497          	auipc	s1,0x2
ffffffffc020033e:	d6e48493          	addi	s1,s1,-658 # ffffffffc02020a8 <etext+0x23e>
        if (argc == MAXARGS - 1) {
ffffffffc0200342:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200344:	00002b17          	auipc	s6,0x2
ffffffffc0200348:	d6cb0b13          	addi	s6,s6,-660 # ffffffffc02020b0 <etext+0x246>
        argv[argc ++] = buf;
ffffffffc020034c:	00002a17          	auipc	s4,0x2
ffffffffc0200350:	c84a0a13          	addi	s4,s4,-892 # ffffffffc0201fd0 <etext+0x166>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200354:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200356:	854a                	mv	a0,s2
ffffffffc0200358:	1f5010ef          	jal	ra,ffffffffc0201d4c <readline>
ffffffffc020035c:	842a                	mv	s0,a0
ffffffffc020035e:	dd65                	beqz	a0,ffffffffc0200356 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200360:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200364:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200366:	e1bd                	bnez	a1,ffffffffc02003cc <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200368:	fe0c87e3          	beqz	s9,ffffffffc0200356 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036c:	6582                	ld	a1,0(sp)
ffffffffc020036e:	00002d17          	auipc	s10,0x2
ffffffffc0200372:	d7ad0d13          	addi	s10,s10,-646 # ffffffffc02020e8 <commands>
        argv[argc ++] = buf;
ffffffffc0200376:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200378:	4401                	li	s0,0
ffffffffc020037a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	55e010ef          	jal	ra,ffffffffc02018da <strcmp>
ffffffffc0200380:	c919                	beqz	a0,ffffffffc0200396 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200382:	2405                	addiw	s0,s0,1
ffffffffc0200384:	0b540063          	beq	s0,s5,ffffffffc0200424 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200388:	000d3503          	ld	a0,0(s10)
ffffffffc020038c:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020038e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200390:	54a010ef          	jal	ra,ffffffffc02018da <strcmp>
ffffffffc0200394:	f57d                	bnez	a0,ffffffffc0200382 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200396:	00141793          	slli	a5,s0,0x1
ffffffffc020039a:	97a2                	add	a5,a5,s0
ffffffffc020039c:	078e                	slli	a5,a5,0x3
ffffffffc020039e:	97e2                	add	a5,a5,s8
ffffffffc02003a0:	6b9c                	ld	a5,16(a5)
ffffffffc02003a2:	865e                	mv	a2,s7
ffffffffc02003a4:	002c                	addi	a1,sp,8
ffffffffc02003a6:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003aa:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003ac:	fa0555e3          	bgez	a0,ffffffffc0200356 <kmonitor+0x6a>
}
ffffffffc02003b0:	60ee                	ld	ra,216(sp)
ffffffffc02003b2:	644e                	ld	s0,208(sp)
ffffffffc02003b4:	64ae                	ld	s1,200(sp)
ffffffffc02003b6:	690e                	ld	s2,192(sp)
ffffffffc02003b8:	79ea                	ld	s3,184(sp)
ffffffffc02003ba:	7a4a                	ld	s4,176(sp)
ffffffffc02003bc:	7aaa                	ld	s5,168(sp)
ffffffffc02003be:	7b0a                	ld	s6,160(sp)
ffffffffc02003c0:	6bea                	ld	s7,152(sp)
ffffffffc02003c2:	6c4a                	ld	s8,144(sp)
ffffffffc02003c4:	6caa                	ld	s9,136(sp)
ffffffffc02003c6:	6d0a                	ld	s10,128(sp)
ffffffffc02003c8:	612d                	addi	sp,sp,224
ffffffffc02003ca:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003cc:	8526                	mv	a0,s1
ffffffffc02003ce:	550010ef          	jal	ra,ffffffffc020191e <strchr>
ffffffffc02003d2:	c901                	beqz	a0,ffffffffc02003e2 <kmonitor+0xf6>
ffffffffc02003d4:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003d8:	00040023          	sb	zero,0(s0)
ffffffffc02003dc:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003de:	d5c9                	beqz	a1,ffffffffc0200368 <kmonitor+0x7c>
ffffffffc02003e0:	b7f5                	j	ffffffffc02003cc <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003e2:	00044783          	lbu	a5,0(s0)
ffffffffc02003e6:	d3c9                	beqz	a5,ffffffffc0200368 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003e8:	033c8963          	beq	s9,s3,ffffffffc020041a <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003ec:	003c9793          	slli	a5,s9,0x3
ffffffffc02003f0:	0118                	addi	a4,sp,128
ffffffffc02003f2:	97ba                	add	a5,a5,a4
ffffffffc02003f4:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003f8:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003fc:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003fe:	e591                	bnez	a1,ffffffffc020040a <kmonitor+0x11e>
ffffffffc0200400:	b7b5                	j	ffffffffc020036c <kmonitor+0x80>
ffffffffc0200402:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200406:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200408:	d1a5                	beqz	a1,ffffffffc0200368 <kmonitor+0x7c>
ffffffffc020040a:	8526                	mv	a0,s1
ffffffffc020040c:	512010ef          	jal	ra,ffffffffc020191e <strchr>
ffffffffc0200410:	d96d                	beqz	a0,ffffffffc0200402 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200412:	00044583          	lbu	a1,0(s0)
ffffffffc0200416:	d9a9                	beqz	a1,ffffffffc0200368 <kmonitor+0x7c>
ffffffffc0200418:	bf55                	j	ffffffffc02003cc <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020041a:	45c1                	li	a1,16
ffffffffc020041c:	855a                	mv	a0,s6
ffffffffc020041e:	cc1ff0ef          	jal	ra,ffffffffc02000de <cprintf>
ffffffffc0200422:	b7e9                	j	ffffffffc02003ec <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200424:	6582                	ld	a1,0(sp)
ffffffffc0200426:	00002517          	auipc	a0,0x2
ffffffffc020042a:	caa50513          	addi	a0,a0,-854 # ffffffffc02020d0 <etext+0x266>
ffffffffc020042e:	cb1ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    return 0;
ffffffffc0200432:	b715                	j	ffffffffc0200356 <kmonitor+0x6a>

ffffffffc0200434 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200434:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200436:	00002517          	auipc	a0,0x2
ffffffffc020043a:	cfa50513          	addi	a0,a0,-774 # ffffffffc0202130 <commands+0x48>
void dtb_init(void) {
ffffffffc020043e:	fc86                	sd	ra,120(sp)
ffffffffc0200440:	f8a2                	sd	s0,112(sp)
ffffffffc0200442:	e8d2                	sd	s4,80(sp)
ffffffffc0200444:	f4a6                	sd	s1,104(sp)
ffffffffc0200446:	f0ca                	sd	s2,96(sp)
ffffffffc0200448:	ecce                	sd	s3,88(sp)
ffffffffc020044a:	e4d6                	sd	s5,72(sp)
ffffffffc020044c:	e0da                	sd	s6,64(sp)
ffffffffc020044e:	fc5e                	sd	s7,56(sp)
ffffffffc0200450:	f862                	sd	s8,48(sp)
ffffffffc0200452:	f466                	sd	s9,40(sp)
ffffffffc0200454:	f06a                	sd	s10,32(sp)
ffffffffc0200456:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200458:	c87ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc020045c:	00006597          	auipc	a1,0x6
ffffffffc0200460:	ba45b583          	ld	a1,-1116(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200464:	00002517          	auipc	a0,0x2
ffffffffc0200468:	cdc50513          	addi	a0,a0,-804 # ffffffffc0202140 <commands+0x58>
ffffffffc020046c:	c73ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200470:	00006417          	auipc	s0,0x6
ffffffffc0200474:	b9840413          	addi	s0,s0,-1128 # ffffffffc0206008 <boot_dtb>
ffffffffc0200478:	600c                	ld	a1,0(s0)
ffffffffc020047a:	00002517          	auipc	a0,0x2
ffffffffc020047e:	cd650513          	addi	a0,a0,-810 # ffffffffc0202150 <commands+0x68>
ffffffffc0200482:	c5dff0ef          	jal	ra,ffffffffc02000de <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200486:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020048a:	00002517          	auipc	a0,0x2
ffffffffc020048e:	cde50513          	addi	a0,a0,-802 # ffffffffc0202168 <commands+0x80>
    if (boot_dtb == 0) {
ffffffffc0200492:	120a0463          	beqz	s4,ffffffffc02005ba <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200496:	57f5                	li	a5,-3
ffffffffc0200498:	07fa                	slli	a5,a5,0x1e
ffffffffc020049a:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc020049e:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004a0:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004a4:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004a6:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02004aa:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ae:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b2:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004b6:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004ba:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004bc:	8ec9                	or	a3,a3,a0
ffffffffc02004be:	0087979b          	slliw	a5,a5,0x8
ffffffffc02004c2:	1b7d                	addi	s6,s6,-1
ffffffffc02004c4:	0167f7b3          	and	a5,a5,s6
ffffffffc02004c8:	8dd5                	or	a1,a1,a3
ffffffffc02004ca:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02004cc:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004d0:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02004d2:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed9a4d>
ffffffffc02004d6:	10f59163          	bne	a1,a5,ffffffffc02005d8 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02004da:	471c                	lw	a5,8(a4)
ffffffffc02004dc:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02004de:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004e0:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02004e4:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02004e8:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ec:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f0:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004f4:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f8:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004fc:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200500:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200504:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200508:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020050a:	01146433          	or	s0,s0,a7
ffffffffc020050e:	0086969b          	slliw	a3,a3,0x8
ffffffffc0200512:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200516:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200518:	0087979b          	slliw	a5,a5,0x8
ffffffffc020051c:	8c49                	or	s0,s0,a0
ffffffffc020051e:	0166f6b3          	and	a3,a3,s6
ffffffffc0200522:	00ca6a33          	or	s4,s4,a2
ffffffffc0200526:	0167f7b3          	and	a5,a5,s6
ffffffffc020052a:	8c55                	or	s0,s0,a3
ffffffffc020052c:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200530:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200532:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200534:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200536:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020053a:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020053c:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020053e:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc0200542:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200544:	00002917          	auipc	s2,0x2
ffffffffc0200548:	c7490913          	addi	s2,s2,-908 # ffffffffc02021b8 <commands+0xd0>
ffffffffc020054c:	49bd                	li	s3,15
        switch (token) {
ffffffffc020054e:	4d91                	li	s11,4
ffffffffc0200550:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200552:	00002497          	auipc	s1,0x2
ffffffffc0200556:	c5e48493          	addi	s1,s1,-930 # ffffffffc02021b0 <commands+0xc8>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020055a:	000a2703          	lw	a4,0(s4)
ffffffffc020055e:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200562:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200566:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020056a:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020056e:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200572:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200576:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200578:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020057c:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200580:	8fd5                	or	a5,a5,a3
ffffffffc0200582:	00eb7733          	and	a4,s6,a4
ffffffffc0200586:	8fd9                	or	a5,a5,a4
ffffffffc0200588:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc020058a:	09778c63          	beq	a5,s7,ffffffffc0200622 <dtb_init+0x1ee>
ffffffffc020058e:	00fbea63          	bltu	s7,a5,ffffffffc02005a2 <dtb_init+0x16e>
ffffffffc0200592:	07a78663          	beq	a5,s10,ffffffffc02005fe <dtb_init+0x1ca>
ffffffffc0200596:	4709                	li	a4,2
ffffffffc0200598:	00e79763          	bne	a5,a4,ffffffffc02005a6 <dtb_init+0x172>
ffffffffc020059c:	4c81                	li	s9,0
ffffffffc020059e:	8a56                	mv	s4,s5
ffffffffc02005a0:	bf6d                	j	ffffffffc020055a <dtb_init+0x126>
ffffffffc02005a2:	ffb78ee3          	beq	a5,s11,ffffffffc020059e <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	c8a50513          	addi	a0,a0,-886 # ffffffffc0202230 <commands+0x148>
ffffffffc02005ae:	b31ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02005b2:	00002517          	auipc	a0,0x2
ffffffffc02005b6:	cb650513          	addi	a0,a0,-842 # ffffffffc0202268 <commands+0x180>
}
ffffffffc02005ba:	7446                	ld	s0,112(sp)
ffffffffc02005bc:	70e6                	ld	ra,120(sp)
ffffffffc02005be:	74a6                	ld	s1,104(sp)
ffffffffc02005c0:	7906                	ld	s2,96(sp)
ffffffffc02005c2:	69e6                	ld	s3,88(sp)
ffffffffc02005c4:	6a46                	ld	s4,80(sp)
ffffffffc02005c6:	6aa6                	ld	s5,72(sp)
ffffffffc02005c8:	6b06                	ld	s6,64(sp)
ffffffffc02005ca:	7be2                	ld	s7,56(sp)
ffffffffc02005cc:	7c42                	ld	s8,48(sp)
ffffffffc02005ce:	7ca2                	ld	s9,40(sp)
ffffffffc02005d0:	7d02                	ld	s10,32(sp)
ffffffffc02005d2:	6de2                	ld	s11,24(sp)
ffffffffc02005d4:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02005d6:	b621                	j	ffffffffc02000de <cprintf>
}
ffffffffc02005d8:	7446                	ld	s0,112(sp)
ffffffffc02005da:	70e6                	ld	ra,120(sp)
ffffffffc02005dc:	74a6                	ld	s1,104(sp)
ffffffffc02005de:	7906                	ld	s2,96(sp)
ffffffffc02005e0:	69e6                	ld	s3,88(sp)
ffffffffc02005e2:	6a46                	ld	s4,80(sp)
ffffffffc02005e4:	6aa6                	ld	s5,72(sp)
ffffffffc02005e6:	6b06                	ld	s6,64(sp)
ffffffffc02005e8:	7be2                	ld	s7,56(sp)
ffffffffc02005ea:	7c42                	ld	s8,48(sp)
ffffffffc02005ec:	7ca2                	ld	s9,40(sp)
ffffffffc02005ee:	7d02                	ld	s10,32(sp)
ffffffffc02005f0:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	b9650513          	addi	a0,a0,-1130 # ffffffffc0202188 <commands+0xa0>
}
ffffffffc02005fa:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02005fc:	b4cd                	j	ffffffffc02000de <cprintf>
                int name_len = strlen(name);
ffffffffc02005fe:	8556                	mv	a0,s5
ffffffffc0200600:	2a4010ef          	jal	ra,ffffffffc02018a4 <strlen>
ffffffffc0200604:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200606:	4619                	li	a2,6
ffffffffc0200608:	85a6                	mv	a1,s1
ffffffffc020060a:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc020060c:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020060e:	2ea010ef          	jal	ra,ffffffffc02018f8 <strncmp>
ffffffffc0200612:	e111                	bnez	a0,ffffffffc0200616 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200614:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200616:	0a91                	addi	s5,s5,4
ffffffffc0200618:	9ad2                	add	s5,s5,s4
ffffffffc020061a:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020061e:	8a56                	mv	s4,s5
ffffffffc0200620:	bf2d                	j	ffffffffc020055a <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200622:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200626:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020062a:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020062e:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200632:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200636:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020063a:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020063e:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200642:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200646:	0087979b          	slliw	a5,a5,0x8
ffffffffc020064a:	00eaeab3          	or	s5,s5,a4
ffffffffc020064e:	00fb77b3          	and	a5,s6,a5
ffffffffc0200652:	00faeab3          	or	s5,s5,a5
ffffffffc0200656:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200658:	000c9c63          	bnez	s9,ffffffffc0200670 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc020065c:	1a82                	slli	s5,s5,0x20
ffffffffc020065e:	00368793          	addi	a5,a3,3
ffffffffc0200662:	020ada93          	srli	s5,s5,0x20
ffffffffc0200666:	9abe                	add	s5,s5,a5
ffffffffc0200668:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020066c:	8a56                	mv	s4,s5
ffffffffc020066e:	b5f5                	j	ffffffffc020055a <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200670:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200674:	85ca                	mv	a1,s2
ffffffffc0200676:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200678:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020067c:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200680:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200684:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200688:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020068c:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020068e:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200692:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200696:	8d59                	or	a0,a0,a4
ffffffffc0200698:	00fb77b3          	and	a5,s6,a5
ffffffffc020069c:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc020069e:	1502                	slli	a0,a0,0x20
ffffffffc02006a0:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006a2:	9522                	add	a0,a0,s0
ffffffffc02006a4:	236010ef          	jal	ra,ffffffffc02018da <strcmp>
ffffffffc02006a8:	66a2                	ld	a3,8(sp)
ffffffffc02006aa:	f94d                	bnez	a0,ffffffffc020065c <dtb_init+0x228>
ffffffffc02006ac:	fb59f8e3          	bgeu	s3,s5,ffffffffc020065c <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02006b0:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02006b4:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02006b8:	00002517          	auipc	a0,0x2
ffffffffc02006bc:	b0850513          	addi	a0,a0,-1272 # ffffffffc02021c0 <commands+0xd8>
           fdt32_to_cpu(x >> 32);
ffffffffc02006c0:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c4:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02006c8:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006cc:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02006d0:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d4:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006d8:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006dc:	0187d693          	srli	a3,a5,0x18
ffffffffc02006e0:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02006e4:	0087579b          	srliw	a5,a4,0x8
ffffffffc02006e8:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ec:	0106561b          	srliw	a2,a2,0x10
ffffffffc02006f0:	010f6f33          	or	t5,t5,a6
ffffffffc02006f4:	0187529b          	srliw	t0,a4,0x18
ffffffffc02006f8:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006fc:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200700:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200704:	0186f6b3          	and	a3,a3,s8
ffffffffc0200708:	01859e1b          	slliw	t3,a1,0x18
ffffffffc020070c:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200710:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200714:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200718:	8361                	srli	a4,a4,0x18
ffffffffc020071a:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020071e:	0105d59b          	srliw	a1,a1,0x10
ffffffffc0200722:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200726:	00cb7633          	and	a2,s6,a2
ffffffffc020072a:	0088181b          	slliw	a6,a6,0x8
ffffffffc020072e:	0085959b          	slliw	a1,a1,0x8
ffffffffc0200732:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200736:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020073a:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020073e:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200742:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200746:	011b78b3          	and	a7,s6,a7
ffffffffc020074a:	005eeeb3          	or	t4,t4,t0
ffffffffc020074e:	00c6e733          	or	a4,a3,a2
ffffffffc0200752:	006c6c33          	or	s8,s8,t1
ffffffffc0200756:	010b76b3          	and	a3,s6,a6
ffffffffc020075a:	00bb7b33          	and	s6,s6,a1
ffffffffc020075e:	01d7e7b3          	or	a5,a5,t4
ffffffffc0200762:	016c6b33          	or	s6,s8,s6
ffffffffc0200766:	01146433          	or	s0,s0,a7
ffffffffc020076a:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc020076c:	1702                	slli	a4,a4,0x20
ffffffffc020076e:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200770:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200772:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200774:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200776:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020077a:	0167eb33          	or	s6,a5,s6
ffffffffc020077e:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200780:	95fff0ef          	jal	ra,ffffffffc02000de <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200784:	85a2                	mv	a1,s0
ffffffffc0200786:	00002517          	auipc	a0,0x2
ffffffffc020078a:	a5a50513          	addi	a0,a0,-1446 # ffffffffc02021e0 <commands+0xf8>
ffffffffc020078e:	951ff0ef          	jal	ra,ffffffffc02000de <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200792:	014b5613          	srli	a2,s6,0x14
ffffffffc0200796:	85da                	mv	a1,s6
ffffffffc0200798:	00002517          	auipc	a0,0x2
ffffffffc020079c:	a6050513          	addi	a0,a0,-1440 # ffffffffc02021f8 <commands+0x110>
ffffffffc02007a0:	93fff0ef          	jal	ra,ffffffffc02000de <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02007a4:	008b05b3          	add	a1,s6,s0
ffffffffc02007a8:	15fd                	addi	a1,a1,-1
ffffffffc02007aa:	00002517          	auipc	a0,0x2
ffffffffc02007ae:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0202218 <commands+0x130>
ffffffffc02007b2:	92dff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02007b6:	00002517          	auipc	a0,0x2
ffffffffc02007ba:	ab250513          	addi	a0,a0,-1358 # ffffffffc0202268 <commands+0x180>
        memory_base = mem_base;
ffffffffc02007be:	00006797          	auipc	a5,0x6
ffffffffc02007c2:	c887b523          	sd	s0,-886(a5) # ffffffffc0206448 <memory_base>
        memory_size = mem_size;
ffffffffc02007c6:	00006797          	auipc	a5,0x6
ffffffffc02007ca:	c967b523          	sd	s6,-886(a5) # ffffffffc0206450 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02007ce:	b3f5                	j	ffffffffc02005ba <dtb_init+0x186>

ffffffffc02007d0 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	c7853503          	ld	a0,-904(a0) # ffffffffc0206448 <memory_base>
ffffffffc02007d8:	8082                	ret

ffffffffc02007da <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02007da:	00006517          	auipc	a0,0x6
ffffffffc02007de:	c7653503          	ld	a0,-906(a0) # ffffffffc0206450 <memory_size>
ffffffffc02007e2:	8082                	ret

ffffffffc02007e4 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc02007e4:	1141                	addi	sp,sp,-16
ffffffffc02007e6:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc02007e8:	02000793          	li	a5,32
ffffffffc02007ec:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02007f0:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02007f4:	67e1                	lui	a5,0x18
ffffffffc02007f6:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02007fa:	953e                	add	a0,a0,a5
ffffffffc02007fc:	61e010ef          	jal	ra,ffffffffc0201e1a <sbi_set_timer>
}
ffffffffc0200800:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	c407bb23          	sd	zero,-938(a5) # ffffffffc0206458 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020080a:	00002517          	auipc	a0,0x2
ffffffffc020080e:	a7650513          	addi	a0,a0,-1418 # ffffffffc0202280 <commands+0x198>
}
ffffffffc0200812:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200814:	8cbff06f          	j	ffffffffc02000de <cprintf>

ffffffffc0200818 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200818:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020081c:	67e1                	lui	a5,0x18
ffffffffc020081e:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200822:	953e                	add	a0,a0,a5
ffffffffc0200824:	5f60106f          	j	ffffffffc0201e1a <sbi_set_timer>

ffffffffc0200828 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200828:	8082                	ret

ffffffffc020082a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020082a:	0ff57513          	zext.b	a0,a0
ffffffffc020082e:	5d20106f          	j	ffffffffc0201e00 <sbi_console_putchar>

ffffffffc0200832 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200832:	6020106f          	j	ffffffffc0201e34 <sbi_console_getchar>

ffffffffc0200836 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200836:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020083a:	8082                	ret

ffffffffc020083c <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020083c:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200840:	8082                	ret

ffffffffc0200842 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200842:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200846:	00000797          	auipc	a5,0x0
ffffffffc020084a:	23a78793          	addi	a5,a5,570 # ffffffffc0200a80 <__alltraps>
ffffffffc020084e:	10579073          	csrw	stvec,a5
}
ffffffffc0200852:	8082                	ret

ffffffffc0200854 <print_trapframe>:
/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
}

void print_trapframe(struct trapframe *tf) {
ffffffffc0200854:	85aa                	mv	a1,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200856:	00002517          	auipc	a0,0x2
ffffffffc020085a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc02022a0 <commands+0x1b8>
ffffffffc020085e:	881ff06f          	j	ffffffffc02000de <cprintf>

ffffffffc0200862 <interrupt_handler>:
}

void interrupt_handler(struct trapframe *tf) {
    static int ticks = 0;
    static int print_num = 0;
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200862:	11853783          	ld	a5,280(a0)
ffffffffc0200866:	472d                	li	a4,11
ffffffffc0200868:	0786                	slli	a5,a5,0x1
ffffffffc020086a:	8385                	srli	a5,a5,0x1
ffffffffc020086c:	08f76263          	bltu	a4,a5,ffffffffc02008f0 <interrupt_handler+0x8e>
ffffffffc0200870:	00002717          	auipc	a4,0x2
ffffffffc0200874:	b1070713          	addi	a4,a4,-1264 # ffffffffc0202380 <commands+0x298>
ffffffffc0200878:	078a                	slli	a5,a5,0x2
ffffffffc020087a:	97ba                	add	a5,a5,a4
ffffffffc020087c:	439c                	lw	a5,0(a5)
ffffffffc020087e:	97ba                	add	a5,a5,a4
ffffffffc0200880:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc0200882:	00002517          	auipc	a0,0x2
ffffffffc0200886:	a9650513          	addi	a0,a0,-1386 # ffffffffc0202318 <commands+0x230>
ffffffffc020088a:	855ff06f          	j	ffffffffc02000de <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc020088e:	00002517          	auipc	a0,0x2
ffffffffc0200892:	a6a50513          	addi	a0,a0,-1430 # ffffffffc02022f8 <commands+0x210>
ffffffffc0200896:	849ff06f          	j	ffffffffc02000de <cprintf>
            cprintf("User software interrupt\n");
ffffffffc020089a:	00002517          	auipc	a0,0x2
ffffffffc020089e:	a1e50513          	addi	a0,a0,-1506 # ffffffffc02022b8 <commands+0x1d0>
ffffffffc02008a2:	83dff06f          	j	ffffffffc02000de <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02008a6:	00002517          	auipc	a0,0x2
ffffffffc02008aa:	a9250513          	addi	a0,a0,-1390 # ffffffffc0202338 <commands+0x250>
ffffffffc02008ae:	831ff06f          	j	ffffffffc02000de <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008b2:	1141                	addi	sp,sp,-16
ffffffffc02008b4:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
ffffffffc02008b6:	f63ff0ef          	jal	ra,ffffffffc0200818 <clock_set_next_event>
            ticks++;
ffffffffc02008ba:	00006697          	auipc	a3,0x6
ffffffffc02008be:	baa68693          	addi	a3,a3,-1110 # ffffffffc0206464 <ticks.1>
ffffffffc02008c2:	429c                	lw	a5,0(a3)
            if (ticks % TICK_NUM == 0) {
ffffffffc02008c4:	06400713          	li	a4,100
            ticks++;
ffffffffc02008c8:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0) {
ffffffffc02008ca:	02e7e73b          	remw	a4,a5,a4
            ticks++;
ffffffffc02008ce:	c29c                	sw	a5,0(a3)
            if (ticks % TICK_NUM == 0) {
ffffffffc02008d0:	c71d                	beqz	a4,ffffffffc02008fe <interrupt_handler+0x9c>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008d2:	60a2                	ld	ra,8(sp)
ffffffffc02008d4:	0141                	addi	sp,sp,16
ffffffffc02008d6:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc02008d8:	00002517          	auipc	a0,0x2
ffffffffc02008dc:	a8850513          	addi	a0,a0,-1400 # ffffffffc0202360 <commands+0x278>
ffffffffc02008e0:	ffeff06f          	j	ffffffffc02000de <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008e4:	00002517          	auipc	a0,0x2
ffffffffc02008e8:	9f450513          	addi	a0,a0,-1548 # ffffffffc02022d8 <commands+0x1f0>
ffffffffc02008ec:	ff2ff06f          	j	ffffffffc02000de <cprintf>
    cprintf("trapframe at %p\n", tf);
ffffffffc02008f0:	85aa                	mv	a1,a0
ffffffffc02008f2:	00002517          	auipc	a0,0x2
ffffffffc02008f6:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02022a0 <commands+0x1b8>
ffffffffc02008fa:	fe4ff06f          	j	ffffffffc02000de <cprintf>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc02008fe:	06400593          	li	a1,100
ffffffffc0200902:	00002517          	auipc	a0,0x2
ffffffffc0200906:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0202350 <commands+0x268>
ffffffffc020090a:	fd4ff0ef          	jal	ra,ffffffffc02000de <cprintf>
                print_num++;
ffffffffc020090e:	00006717          	auipc	a4,0x6
ffffffffc0200912:	b5270713          	addi	a4,a4,-1198 # ffffffffc0206460 <print_num.0>
ffffffffc0200916:	431c                	lw	a5,0(a4)
                if (print_num == 10) {
ffffffffc0200918:	46a9                	li	a3,10
                print_num++;
ffffffffc020091a:	0017861b          	addiw	a2,a5,1
ffffffffc020091e:	c310                	sw	a2,0(a4)
                if (print_num == 10) {
ffffffffc0200920:	fad619e3          	bne	a2,a3,ffffffffc02008d2 <interrupt_handler+0x70>
}
ffffffffc0200924:	60a2                	ld	ra,8(sp)
ffffffffc0200926:	0141                	addi	sp,sp,16
                    sbi_shutdown();
ffffffffc0200928:	5280106f          	j	ffffffffc0201e50 <sbi_shutdown>

ffffffffc020092c <exception_handler>:
    uint16_t half;
    memcpy(&half, (void *)epc, sizeof(half));
    return (half & 0x3) != 0x3 ? 2 : 4;
}

void exception_handler(struct trapframe *tf) {
ffffffffc020092c:	7179                	addi	sp,sp,-48
ffffffffc020092e:	ec26                	sd	s1,24(sp)
    switch (tf->cause) {
ffffffffc0200930:	11853483          	ld	s1,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200934:	f022                	sd	s0,32(sp)
ffffffffc0200936:	f406                	sd	ra,40(sp)
ffffffffc0200938:	47ad                	li	a5,11
ffffffffc020093a:	842a                	mv	s0,a0
ffffffffc020093c:	0897eb63          	bltu	a5,s1,ffffffffc02009d2 <exception_handler+0xa6>
ffffffffc0200940:	00002697          	auipc	a3,0x2
ffffffffc0200944:	b8468693          	addi	a3,a3,-1148 # ffffffffc02024c4 <commands+0x3dc>
ffffffffc0200948:	00249713          	slli	a4,s1,0x2
ffffffffc020094c:	9736                	add	a4,a4,a3
ffffffffc020094e:	431c                	lw	a5,0(a4)
ffffffffc0200950:	97b6                	add	a5,a5,a3
ffffffffc0200952:	8782                	jr	a5
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            // 避免递归打印，这里只打印一行简讯
            cprintf("Illegal instruction at sepc=%p\n", tf->epc);
ffffffffc0200954:	10853583          	ld	a1,264(a0)
ffffffffc0200958:	00002517          	auipc	a0,0x2
ffffffffc020095c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0202410 <commands+0x328>
ffffffffc0200960:	f7eff0ef          	jal	ra,ffffffffc02000de <cprintf>
    memcpy(&half, (void *)epc, sizeof(half));
ffffffffc0200964:	10843583          	ld	a1,264(s0)
ffffffffc0200968:	4609                	li	a2,2
ffffffffc020096a:	00e10513          	addi	a0,sp,14
ffffffffc020096e:	7d9000ef          	jal	ra,ffffffffc0201946 <memcpy>
    return (half & 0x3) != 0x3 ? 2 : 4;
ffffffffc0200972:	00e15783          	lhu	a5,14(sp)
ffffffffc0200976:	470d                	li	a4,3
ffffffffc0200978:	8b8d                	andi	a5,a5,3
ffffffffc020097a:	06e78763          	beq	a5,a4,ffffffffc02009e8 <exception_handler+0xbc>
            tf->epc += insn_len(tf->epc);
ffffffffc020097e:	10843783          	ld	a5,264(s0)
ffffffffc0200982:	94be                	add	s1,s1,a5
ffffffffc0200984:	10943423          	sd	s1,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200988:	70a2                	ld	ra,40(sp)
ffffffffc020098a:	7402                	ld	s0,32(sp)
ffffffffc020098c:	64e2                	ld	s1,24(sp)
ffffffffc020098e:	6145                	addi	sp,sp,48
ffffffffc0200990:	8082                	ret
            cprintf("Breakpoint at sepc=%p\n", tf->epc);
ffffffffc0200992:	10853583          	ld	a1,264(a0)
ffffffffc0200996:	00002517          	auipc	a0,0x2
ffffffffc020099a:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0202430 <commands+0x348>
ffffffffc020099e:	f40ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    memcpy(&half, (void *)epc, sizeof(half));
ffffffffc02009a2:	10843583          	ld	a1,264(s0)
ffffffffc02009a6:	4609                	li	a2,2
ffffffffc02009a8:	00e10513          	addi	a0,sp,14
ffffffffc02009ac:	79b000ef          	jal	ra,ffffffffc0201946 <memcpy>
    return (half & 0x3) != 0x3 ? 2 : 4;
ffffffffc02009b0:	00e15703          	lhu	a4,14(sp)
ffffffffc02009b4:	478d                	li	a5,3
ffffffffc02009b6:	4689                	li	a3,2
ffffffffc02009b8:	8b0d                	andi	a4,a4,3
ffffffffc02009ba:	02f70963          	beq	a4,a5,ffffffffc02009ec <exception_handler+0xc0>
            tf->epc += insn_len(tf->epc);
ffffffffc02009be:	10843783          	ld	a5,264(s0)
}
ffffffffc02009c2:	70a2                	ld	ra,40(sp)
ffffffffc02009c4:	64e2                	ld	s1,24(sp)
            tf->epc += insn_len(tf->epc);
ffffffffc02009c6:	97b6                	add	a5,a5,a3
ffffffffc02009c8:	10f43423          	sd	a5,264(s0)
}
ffffffffc02009cc:	7402                	ld	s0,32(sp)
ffffffffc02009ce:	6145                	addi	sp,sp,48
ffffffffc02009d0:	8082                	ret
ffffffffc02009d2:	7402                	ld	s0,32(sp)
ffffffffc02009d4:	70a2                	ld	ra,40(sp)
ffffffffc02009d6:	64e2                	ld	s1,24(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc02009d8:	85aa                	mv	a1,a0
ffffffffc02009da:	00002517          	auipc	a0,0x2
ffffffffc02009de:	8c650513          	addi	a0,a0,-1850 # ffffffffc02022a0 <commands+0x1b8>
}
ffffffffc02009e2:	6145                	addi	sp,sp,48
    cprintf("trapframe at %p\n", tf);
ffffffffc02009e4:	efaff06f          	j	ffffffffc02000de <cprintf>
    return (half & 0x3) != 0x3 ? 2 : 4;
ffffffffc02009e8:	4491                	li	s1,4
ffffffffc02009ea:	bf51                	j	ffffffffc020097e <exception_handler+0x52>
ffffffffc02009ec:	4691                	li	a3,4
ffffffffc02009ee:	bfc1                	j	ffffffffc02009be <exception_handler+0x92>
            cprintf("Load page fault: sepc=%p stval=%p\n", tf->epc, tf->badvaddr);
ffffffffc02009f0:	11053603          	ld	a2,272(a0)
ffffffffc02009f4:	10853583          	ld	a1,264(a0)
ffffffffc02009f8:	00002517          	auipc	a0,0x2
ffffffffc02009fc:	a5050513          	addi	a0,a0,-1456 # ffffffffc0202448 <commands+0x360>
ffffffffc0200a00:	edeff0ef          	jal	ra,ffffffffc02000de <cprintf>
            panic("kernel load fault");
ffffffffc0200a04:	00002617          	auipc	a2,0x2
ffffffffc0200a08:	a6c60613          	addi	a2,a2,-1428 # ffffffffc0202470 <commands+0x388>
ffffffffc0200a0c:	0d400593          	li	a1,212
ffffffffc0200a10:	00002517          	auipc	a0,0x2
ffffffffc0200a14:	9e850513          	addi	a0,a0,-1560 # ffffffffc02023f8 <commands+0x310>
ffffffffc0200a18:	f4eff0ef          	jal	ra,ffffffffc0200166 <__panic>
            cprintf("Instruction page fault: sepc=%p stval=%p\n", tf->epc, tf->badvaddr);
ffffffffc0200a1c:	11053603          	ld	a2,272(a0)
ffffffffc0200a20:	10853583          	ld	a1,264(a0)
ffffffffc0200a24:	00002517          	auipc	a0,0x2
ffffffffc0200a28:	98c50513          	addi	a0,a0,-1652 # ffffffffc02023b0 <commands+0x2c8>
ffffffffc0200a2c:	eb2ff0ef          	jal	ra,ffffffffc02000de <cprintf>
            panic("kernel instr fault");
ffffffffc0200a30:	00002617          	auipc	a2,0x2
ffffffffc0200a34:	9b060613          	addi	a2,a2,-1616 # ffffffffc02023e0 <commands+0x2f8>
ffffffffc0200a38:	0ba00593          	li	a1,186
ffffffffc0200a3c:	00002517          	auipc	a0,0x2
ffffffffc0200a40:	9bc50513          	addi	a0,a0,-1604 # ffffffffc02023f8 <commands+0x310>
ffffffffc0200a44:	f22ff0ef          	jal	ra,ffffffffc0200166 <__panic>
            cprintf("Store page fault: sepc=%p stval=%p\n", tf->epc, tf->badvaddr);
ffffffffc0200a48:	11053603          	ld	a2,272(a0)
ffffffffc0200a4c:	10853583          	ld	a1,264(a0)
ffffffffc0200a50:	00002517          	auipc	a0,0x2
ffffffffc0200a54:	a3850513          	addi	a0,a0,-1480 # ffffffffc0202488 <commands+0x3a0>
ffffffffc0200a58:	e86ff0ef          	jal	ra,ffffffffc02000de <cprintf>
            panic("kernel store fault");
ffffffffc0200a5c:	00002617          	auipc	a2,0x2
ffffffffc0200a60:	a5460613          	addi	a2,a2,-1452 # ffffffffc02024b0 <commands+0x3c8>
ffffffffc0200a64:	0d900593          	li	a1,217
ffffffffc0200a68:	00002517          	auipc	a0,0x2
ffffffffc0200a6c:	99050513          	addi	a0,a0,-1648 # ffffffffc02023f8 <commands+0x310>
ffffffffc0200a70:	ef6ff0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc0200a74 <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a74:	11853783          	ld	a5,280(a0)
ffffffffc0200a78:	0007c363          	bltz	a5,ffffffffc0200a7e <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a7c:	bd45                	j	ffffffffc020092c <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a7e:	b3d5                	j	ffffffffc0200862 <interrupt_handler>

ffffffffc0200a80 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200a80:	14011073          	csrw	sscratch,sp
ffffffffc0200a84:	712d                	addi	sp,sp,-288
ffffffffc0200a86:	e002                	sd	zero,0(sp)
ffffffffc0200a88:	e406                	sd	ra,8(sp)
ffffffffc0200a8a:	ec0e                	sd	gp,24(sp)
ffffffffc0200a8c:	f012                	sd	tp,32(sp)
ffffffffc0200a8e:	f416                	sd	t0,40(sp)
ffffffffc0200a90:	f81a                	sd	t1,48(sp)
ffffffffc0200a92:	fc1e                	sd	t2,56(sp)
ffffffffc0200a94:	e0a2                	sd	s0,64(sp)
ffffffffc0200a96:	e4a6                	sd	s1,72(sp)
ffffffffc0200a98:	e8aa                	sd	a0,80(sp)
ffffffffc0200a9a:	ecae                	sd	a1,88(sp)
ffffffffc0200a9c:	f0b2                	sd	a2,96(sp)
ffffffffc0200a9e:	f4b6                	sd	a3,104(sp)
ffffffffc0200aa0:	f8ba                	sd	a4,112(sp)
ffffffffc0200aa2:	fcbe                	sd	a5,120(sp)
ffffffffc0200aa4:	e142                	sd	a6,128(sp)
ffffffffc0200aa6:	e546                	sd	a7,136(sp)
ffffffffc0200aa8:	e94a                	sd	s2,144(sp)
ffffffffc0200aaa:	ed4e                	sd	s3,152(sp)
ffffffffc0200aac:	f152                	sd	s4,160(sp)
ffffffffc0200aae:	f556                	sd	s5,168(sp)
ffffffffc0200ab0:	f95a                	sd	s6,176(sp)
ffffffffc0200ab2:	fd5e                	sd	s7,184(sp)
ffffffffc0200ab4:	e1e2                	sd	s8,192(sp)
ffffffffc0200ab6:	e5e6                	sd	s9,200(sp)
ffffffffc0200ab8:	e9ea                	sd	s10,208(sp)
ffffffffc0200aba:	edee                	sd	s11,216(sp)
ffffffffc0200abc:	f1f2                	sd	t3,224(sp)
ffffffffc0200abe:	f5f6                	sd	t4,232(sp)
ffffffffc0200ac0:	f9fa                	sd	t5,240(sp)
ffffffffc0200ac2:	fdfe                	sd	t6,248(sp)
ffffffffc0200ac4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200ac8:	100024f3          	csrr	s1,sstatus
ffffffffc0200acc:	14102973          	csrr	s2,sepc
ffffffffc0200ad0:	143029f3          	csrr	s3,stval
ffffffffc0200ad4:	14202a73          	csrr	s4,scause
ffffffffc0200ad8:	e822                	sd	s0,16(sp)
ffffffffc0200ada:	e226                	sd	s1,256(sp)
ffffffffc0200adc:	e64a                	sd	s2,264(sp)
ffffffffc0200ade:	ea4e                	sd	s3,272(sp)
ffffffffc0200ae0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ae2:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ae4:	f91ff0ef          	jal	ra,ffffffffc0200a74 <trap>

ffffffffc0200ae8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ae8:	6492                	ld	s1,256(sp)
ffffffffc0200aea:	6932                	ld	s2,264(sp)
ffffffffc0200aec:	10049073          	csrw	sstatus,s1
ffffffffc0200af0:	14191073          	csrw	sepc,s2
ffffffffc0200af4:	60a2                	ld	ra,8(sp)
ffffffffc0200af6:	61e2                	ld	gp,24(sp)
ffffffffc0200af8:	7202                	ld	tp,32(sp)
ffffffffc0200afa:	72a2                	ld	t0,40(sp)
ffffffffc0200afc:	7342                	ld	t1,48(sp)
ffffffffc0200afe:	73e2                	ld	t2,56(sp)
ffffffffc0200b00:	6406                	ld	s0,64(sp)
ffffffffc0200b02:	64a6                	ld	s1,72(sp)
ffffffffc0200b04:	6546                	ld	a0,80(sp)
ffffffffc0200b06:	65e6                	ld	a1,88(sp)
ffffffffc0200b08:	7606                	ld	a2,96(sp)
ffffffffc0200b0a:	76a6                	ld	a3,104(sp)
ffffffffc0200b0c:	7746                	ld	a4,112(sp)
ffffffffc0200b0e:	77e6                	ld	a5,120(sp)
ffffffffc0200b10:	680a                	ld	a6,128(sp)
ffffffffc0200b12:	68aa                	ld	a7,136(sp)
ffffffffc0200b14:	694a                	ld	s2,144(sp)
ffffffffc0200b16:	69ea                	ld	s3,152(sp)
ffffffffc0200b18:	7a0a                	ld	s4,160(sp)
ffffffffc0200b1a:	7aaa                	ld	s5,168(sp)
ffffffffc0200b1c:	7b4a                	ld	s6,176(sp)
ffffffffc0200b1e:	7bea                	ld	s7,184(sp)
ffffffffc0200b20:	6c0e                	ld	s8,192(sp)
ffffffffc0200b22:	6cae                	ld	s9,200(sp)
ffffffffc0200b24:	6d4e                	ld	s10,208(sp)
ffffffffc0200b26:	6dee                	ld	s11,216(sp)
ffffffffc0200b28:	7e0e                	ld	t3,224(sp)
ffffffffc0200b2a:	7eae                	ld	t4,232(sp)
ffffffffc0200b2c:	7f4e                	ld	t5,240(sp)
ffffffffc0200b2e:	7fee                	ld	t6,248(sp)
ffffffffc0200b30:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200b32:	10200073          	sret

ffffffffc0200b36 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b36:	100027f3          	csrr	a5,sstatus
ffffffffc0200b3a:	8b89                	andi	a5,a5,2
ffffffffc0200b3c:	e799                	bnez	a5,ffffffffc0200b4a <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200b3e:	00006797          	auipc	a5,0x6
ffffffffc0200b42:	93a7b783          	ld	a5,-1734(a5) # ffffffffc0206478 <pmm_manager>
ffffffffc0200b46:	6f9c                	ld	a5,24(a5)
ffffffffc0200b48:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200b4a:	1141                	addi	sp,sp,-16
ffffffffc0200b4c:	e406                	sd	ra,8(sp)
ffffffffc0200b4e:	e022                	sd	s0,0(sp)
ffffffffc0200b50:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200b52:	cebff0ef          	jal	ra,ffffffffc020083c <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200b56:	00006797          	auipc	a5,0x6
ffffffffc0200b5a:	9227b783          	ld	a5,-1758(a5) # ffffffffc0206478 <pmm_manager>
ffffffffc0200b5e:	6f9c                	ld	a5,24(a5)
ffffffffc0200b60:	8522                	mv	a0,s0
ffffffffc0200b62:	9782                	jalr	a5
ffffffffc0200b64:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200b66:	cd1ff0ef          	jal	ra,ffffffffc0200836 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200b6a:	60a2                	ld	ra,8(sp)
ffffffffc0200b6c:	8522                	mv	a0,s0
ffffffffc0200b6e:	6402                	ld	s0,0(sp)
ffffffffc0200b70:	0141                	addi	sp,sp,16
ffffffffc0200b72:	8082                	ret

ffffffffc0200b74 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b74:	100027f3          	csrr	a5,sstatus
ffffffffc0200b78:	8b89                	andi	a5,a5,2
ffffffffc0200b7a:	e799                	bnez	a5,ffffffffc0200b88 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200b7c:	00006797          	auipc	a5,0x6
ffffffffc0200b80:	8fc7b783          	ld	a5,-1796(a5) # ffffffffc0206478 <pmm_manager>
ffffffffc0200b84:	739c                	ld	a5,32(a5)
ffffffffc0200b86:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200b88:	1101                	addi	sp,sp,-32
ffffffffc0200b8a:	ec06                	sd	ra,24(sp)
ffffffffc0200b8c:	e822                	sd	s0,16(sp)
ffffffffc0200b8e:	e426                	sd	s1,8(sp)
ffffffffc0200b90:	842a                	mv	s0,a0
ffffffffc0200b92:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200b94:	ca9ff0ef          	jal	ra,ffffffffc020083c <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200b98:	00006797          	auipc	a5,0x6
ffffffffc0200b9c:	8e07b783          	ld	a5,-1824(a5) # ffffffffc0206478 <pmm_manager>
ffffffffc0200ba0:	739c                	ld	a5,32(a5)
ffffffffc0200ba2:	85a6                	mv	a1,s1
ffffffffc0200ba4:	8522                	mv	a0,s0
ffffffffc0200ba6:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200ba8:	6442                	ld	s0,16(sp)
ffffffffc0200baa:	60e2                	ld	ra,24(sp)
ffffffffc0200bac:	64a2                	ld	s1,8(sp)
ffffffffc0200bae:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200bb0:	b159                	j	ffffffffc0200836 <intr_enable>

ffffffffc0200bb2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200bb2:	100027f3          	csrr	a5,sstatus
ffffffffc0200bb6:	8b89                	andi	a5,a5,2
ffffffffc0200bb8:	e799                	bnez	a5,ffffffffc0200bc6 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200bba:	00006797          	auipc	a5,0x6
ffffffffc0200bbe:	8be7b783          	ld	a5,-1858(a5) # ffffffffc0206478 <pmm_manager>
ffffffffc0200bc2:	779c                	ld	a5,40(a5)
ffffffffc0200bc4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200bc6:	1141                	addi	sp,sp,-16
ffffffffc0200bc8:	e406                	sd	ra,8(sp)
ffffffffc0200bca:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200bcc:	c71ff0ef          	jal	ra,ffffffffc020083c <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200bd0:	00006797          	auipc	a5,0x6
ffffffffc0200bd4:	8a87b783          	ld	a5,-1880(a5) # ffffffffc0206478 <pmm_manager>
ffffffffc0200bd8:	779c                	ld	a5,40(a5)
ffffffffc0200bda:	9782                	jalr	a5
ffffffffc0200bdc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200bde:	c59ff0ef          	jal	ra,ffffffffc0200836 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200be2:	60a2                	ld	ra,8(sp)
ffffffffc0200be4:	8522                	mv	a0,s0
ffffffffc0200be6:	6402                	ld	s0,0(sp)
ffffffffc0200be8:	0141                	addi	sp,sp,16
ffffffffc0200bea:	8082                	ret

ffffffffc0200bec <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0200bec:	00002797          	auipc	a5,0x2
ffffffffc0200bf0:	e1478793          	addi	a5,a5,-492 # ffffffffc0202a00 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200bf4:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200bf6:	7179                	addi	sp,sp,-48
ffffffffc0200bf8:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200bfa:	00002517          	auipc	a0,0x2
ffffffffc0200bfe:	8fe50513          	addi	a0,a0,-1794 # ffffffffc02024f8 <commands+0x410>
    pmm_manager = &default_pmm_manager;
ffffffffc0200c02:	00006417          	auipc	s0,0x6
ffffffffc0200c06:	87640413          	addi	s0,s0,-1930 # ffffffffc0206478 <pmm_manager>
void pmm_init(void) {
ffffffffc0200c0a:	f406                	sd	ra,40(sp)
ffffffffc0200c0c:	ec26                	sd	s1,24(sp)
ffffffffc0200c0e:	e44e                	sd	s3,8(sp)
ffffffffc0200c10:	e84a                	sd	s2,16(sp)
ffffffffc0200c12:	e052                	sd	s4,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0200c14:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200c16:	cc8ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    pmm_manager->init();
ffffffffc0200c1a:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200c1c:	00006497          	auipc	s1,0x6
ffffffffc0200c20:	87448493          	addi	s1,s1,-1932 # ffffffffc0206490 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200c24:	679c                	ld	a5,8(a5)
ffffffffc0200c26:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200c28:	57f5                	li	a5,-3
ffffffffc0200c2a:	07fa                	slli	a5,a5,0x1e
ffffffffc0200c2c:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0200c2e:	ba3ff0ef          	jal	ra,ffffffffc02007d0 <get_memory_base>
ffffffffc0200c32:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200c34:	ba7ff0ef          	jal	ra,ffffffffc02007da <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200c38:	16050163          	beqz	a0,ffffffffc0200d9a <pmm_init+0x1ae>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200c3c:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200c3e:	00002517          	auipc	a0,0x2
ffffffffc0200c42:	90250513          	addi	a0,a0,-1790 # ffffffffc0202540 <commands+0x458>
ffffffffc0200c46:	c98ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200c4a:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200c4e:	864e                	mv	a2,s3
ffffffffc0200c50:	fffa0693          	addi	a3,s4,-1
ffffffffc0200c54:	85ca                	mv	a1,s2
ffffffffc0200c56:	00002517          	auipc	a0,0x2
ffffffffc0200c5a:	90250513          	addi	a0,a0,-1790 # ffffffffc0202558 <commands+0x470>
ffffffffc0200c5e:	c80ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200c62:	c80007b7          	lui	a5,0xc8000
ffffffffc0200c66:	8652                	mv	a2,s4
ffffffffc0200c68:	0d47e863          	bltu	a5,s4,ffffffffc0200d38 <pmm_init+0x14c>
ffffffffc0200c6c:	00007797          	auipc	a5,0x7
ffffffffc0200c70:	83378793          	addi	a5,a5,-1997 # ffffffffc020749f <end+0xfff>
ffffffffc0200c74:	757d                	lui	a0,0xfffff
ffffffffc0200c76:	8d7d                	and	a0,a0,a5
ffffffffc0200c78:	8231                	srli	a2,a2,0xc
ffffffffc0200c7a:	00005597          	auipc	a1,0x5
ffffffffc0200c7e:	7ee58593          	addi	a1,a1,2030 # ffffffffc0206468 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200c82:	00005817          	auipc	a6,0x5
ffffffffc0200c86:	7ee80813          	addi	a6,a6,2030 # ffffffffc0206470 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200c8a:	e190                	sd	a2,0(a1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200c8c:	00a83023          	sd	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200c90:	000807b7          	lui	a5,0x80
ffffffffc0200c94:	02f60663          	beq	a2,a5,ffffffffc0200cc0 <pmm_init+0xd4>
ffffffffc0200c98:	4701                	li	a4,0
ffffffffc0200c9a:	4781                	li	a5,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c9c:	4305                	li	t1,1
ffffffffc0200c9e:	fff808b7          	lui	a7,0xfff80
        SetPageReserved(pages + i);
ffffffffc0200ca2:	953a                	add	a0,a0,a4
ffffffffc0200ca4:	00850693          	addi	a3,a0,8 # fffffffffffff008 <end+0x3fdf8b68>
ffffffffc0200ca8:	4066b02f          	amoor.d	zero,t1,(a3)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200cac:	6190                	ld	a2,0(a1)
ffffffffc0200cae:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0200cb0:	00083503          	ld	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200cb4:	011606b3          	add	a3,a2,a7
ffffffffc0200cb8:	02870713          	addi	a4,a4,40
ffffffffc0200cbc:	fed7e3e3          	bltu	a5,a3,ffffffffc0200ca2 <pmm_init+0xb6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200cc0:	00261693          	slli	a3,a2,0x2
ffffffffc0200cc4:	96b2                	add	a3,a3,a2
ffffffffc0200cc6:	fec007b7          	lui	a5,0xfec00
ffffffffc0200cca:	97aa                	add	a5,a5,a0
ffffffffc0200ccc:	068e                	slli	a3,a3,0x3
ffffffffc0200cce:	96be                	add	a3,a3,a5
ffffffffc0200cd0:	c02007b7          	lui	a5,0xc0200
ffffffffc0200cd4:	0af6e763          	bltu	a3,a5,ffffffffc0200d82 <pmm_init+0x196>
ffffffffc0200cd8:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0200cda:	77fd                	lui	a5,0xfffff
ffffffffc0200cdc:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ce0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200ce2:	04b6ee63          	bltu	a3,a1,ffffffffc0200d3e <pmm_init+0x152>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200ce6:	601c                	ld	a5,0(s0)
ffffffffc0200ce8:	7b9c                	ld	a5,48(a5)
ffffffffc0200cea:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200cec:	00002517          	auipc	a0,0x2
ffffffffc0200cf0:	8f450513          	addi	a0,a0,-1804 # ffffffffc02025e0 <commands+0x4f8>
ffffffffc0200cf4:	beaff0ef          	jal	ra,ffffffffc02000de <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200cf8:	00004597          	auipc	a1,0x4
ffffffffc0200cfc:	30858593          	addi	a1,a1,776 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200d00:	00005797          	auipc	a5,0x5
ffffffffc0200d04:	78b7b423          	sd	a1,1928(a5) # ffffffffc0206488 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200d08:	c02007b7          	lui	a5,0xc0200
ffffffffc0200d0c:	0af5e363          	bltu	a1,a5,ffffffffc0200db2 <pmm_init+0x1c6>
ffffffffc0200d10:	6090                	ld	a2,0(s1)
}
ffffffffc0200d12:	7402                	ld	s0,32(sp)
ffffffffc0200d14:	70a2                	ld	ra,40(sp)
ffffffffc0200d16:	64e2                	ld	s1,24(sp)
ffffffffc0200d18:	6942                	ld	s2,16(sp)
ffffffffc0200d1a:	69a2                	ld	s3,8(sp)
ffffffffc0200d1c:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200d1e:	40c58633          	sub	a2,a1,a2
ffffffffc0200d22:	00005797          	auipc	a5,0x5
ffffffffc0200d26:	74c7bf23          	sd	a2,1886(a5) # ffffffffc0206480 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200d2a:	00002517          	auipc	a0,0x2
ffffffffc0200d2e:	8d650513          	addi	a0,a0,-1834 # ffffffffc0202600 <commands+0x518>
}
ffffffffc0200d32:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200d34:	baaff06f          	j	ffffffffc02000de <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200d38:	c8000637          	lui	a2,0xc8000
ffffffffc0200d3c:	bf05                	j	ffffffffc0200c6c <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200d3e:	6705                	lui	a4,0x1
ffffffffc0200d40:	177d                	addi	a4,a4,-1
ffffffffc0200d42:	96ba                	add	a3,a3,a4
ffffffffc0200d44:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200d46:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d4a:	02c7f063          	bgeu	a5,a2,ffffffffc0200d6a <pmm_init+0x17e>
    pmm_manager->init_memmap(base, n);
ffffffffc0200d4e:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200d50:	fff80737          	lui	a4,0xfff80
ffffffffc0200d54:	973e                	add	a4,a4,a5
ffffffffc0200d56:	00271793          	slli	a5,a4,0x2
ffffffffc0200d5a:	97ba                	add	a5,a5,a4
ffffffffc0200d5c:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200d5e:	8d95                	sub	a1,a1,a3
ffffffffc0200d60:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200d62:	81b1                	srli	a1,a1,0xc
ffffffffc0200d64:	953e                	add	a0,a0,a5
ffffffffc0200d66:	9702                	jalr	a4
}
ffffffffc0200d68:	bfbd                	j	ffffffffc0200ce6 <pmm_init+0xfa>
        panic("pa2page called with invalid pa");
ffffffffc0200d6a:	00002617          	auipc	a2,0x2
ffffffffc0200d6e:	84660613          	addi	a2,a2,-1978 # ffffffffc02025b0 <commands+0x4c8>
ffffffffc0200d72:	06b00593          	li	a1,107
ffffffffc0200d76:	00002517          	auipc	a0,0x2
ffffffffc0200d7a:	85a50513          	addi	a0,a0,-1958 # ffffffffc02025d0 <commands+0x4e8>
ffffffffc0200d7e:	be8ff0ef          	jal	ra,ffffffffc0200166 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200d82:	00002617          	auipc	a2,0x2
ffffffffc0200d86:	80660613          	addi	a2,a2,-2042 # ffffffffc0202588 <commands+0x4a0>
ffffffffc0200d8a:	07100593          	li	a1,113
ffffffffc0200d8e:	00001517          	auipc	a0,0x1
ffffffffc0200d92:	7a250513          	addi	a0,a0,1954 # ffffffffc0202530 <commands+0x448>
ffffffffc0200d96:	bd0ff0ef          	jal	ra,ffffffffc0200166 <__panic>
        panic("DTB memory info not available");
ffffffffc0200d9a:	00001617          	auipc	a2,0x1
ffffffffc0200d9e:	77660613          	addi	a2,a2,1910 # ffffffffc0202510 <commands+0x428>
ffffffffc0200da2:	05a00593          	li	a1,90
ffffffffc0200da6:	00001517          	auipc	a0,0x1
ffffffffc0200daa:	78a50513          	addi	a0,a0,1930 # ffffffffc0202530 <commands+0x448>
ffffffffc0200dae:	bb8ff0ef          	jal	ra,ffffffffc0200166 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200db2:	86ae                	mv	a3,a1
ffffffffc0200db4:	00001617          	auipc	a2,0x1
ffffffffc0200db8:	7d460613          	addi	a2,a2,2004 # ffffffffc0202588 <commands+0x4a0>
ffffffffc0200dbc:	08c00593          	li	a1,140
ffffffffc0200dc0:	00001517          	auipc	a0,0x1
ffffffffc0200dc4:	77050513          	addi	a0,a0,1904 # ffffffffc0202530 <commands+0x448>
ffffffffc0200dc8:	b9eff0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc0200dcc <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200dcc:	00005797          	auipc	a5,0x5
ffffffffc0200dd0:	25c78793          	addi	a5,a5,604 # ffffffffc0206028 <free_area>
ffffffffc0200dd4:	e79c                	sd	a5,8(a5)
ffffffffc0200dd6:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200dd8:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ddc:	8082                	ret

ffffffffc0200dde <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200dde:	00005517          	auipc	a0,0x5
ffffffffc0200de2:	25a56503          	lwu	a0,602(a0) # ffffffffc0206038 <free_area+0x10>
ffffffffc0200de6:	8082                	ret

ffffffffc0200de8 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200de8:	715d                	addi	sp,sp,-80
ffffffffc0200dea:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200dec:	00005417          	auipc	s0,0x5
ffffffffc0200df0:	23c40413          	addi	s0,s0,572 # ffffffffc0206028 <free_area>
ffffffffc0200df4:	641c                	ld	a5,8(s0)
ffffffffc0200df6:	e486                	sd	ra,72(sp)
ffffffffc0200df8:	fc26                	sd	s1,56(sp)
ffffffffc0200dfa:	f84a                	sd	s2,48(sp)
ffffffffc0200dfc:	f44e                	sd	s3,40(sp)
ffffffffc0200dfe:	f052                	sd	s4,32(sp)
ffffffffc0200e00:	ec56                	sd	s5,24(sp)
ffffffffc0200e02:	e85a                	sd	s6,16(sp)
ffffffffc0200e04:	e45e                	sd	s7,8(sp)
ffffffffc0200e06:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e08:	2c878763          	beq	a5,s0,ffffffffc02010d6 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200e0c:	4481                	li	s1,0
ffffffffc0200e0e:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e10:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e14:	8b09                	andi	a4,a4,2
ffffffffc0200e16:	2c070463          	beqz	a4,ffffffffc02010de <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200e1a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e1e:	679c                	ld	a5,8(a5)
ffffffffc0200e20:	2905                	addiw	s2,s2,1
ffffffffc0200e22:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e24:	fe8796e3          	bne	a5,s0,ffffffffc0200e10 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200e28:	89a6                	mv	s3,s1
ffffffffc0200e2a:	d89ff0ef          	jal	ra,ffffffffc0200bb2 <nr_free_pages>
ffffffffc0200e2e:	71351863          	bne	a0,s3,ffffffffc020153e <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e32:	4505                	li	a0,1
ffffffffc0200e34:	d03ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200e38:	8a2a                	mv	s4,a0
ffffffffc0200e3a:	44050263          	beqz	a0,ffffffffc020127e <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e3e:	4505                	li	a0,1
ffffffffc0200e40:	cf7ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200e44:	89aa                	mv	s3,a0
ffffffffc0200e46:	70050c63          	beqz	a0,ffffffffc020155e <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e4a:	4505                	li	a0,1
ffffffffc0200e4c:	cebff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200e50:	8aaa                	mv	s5,a0
ffffffffc0200e52:	4a050663          	beqz	a0,ffffffffc02012fe <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e56:	2b3a0463          	beq	s4,s3,ffffffffc02010fe <default_check+0x316>
ffffffffc0200e5a:	2aaa0263          	beq	s4,a0,ffffffffc02010fe <default_check+0x316>
ffffffffc0200e5e:	2aa98063          	beq	s3,a0,ffffffffc02010fe <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e62:	000a2783          	lw	a5,0(s4)
ffffffffc0200e66:	2a079c63          	bnez	a5,ffffffffc020111e <default_check+0x336>
ffffffffc0200e6a:	0009a783          	lw	a5,0(s3)
ffffffffc0200e6e:	2a079863          	bnez	a5,ffffffffc020111e <default_check+0x336>
ffffffffc0200e72:	411c                	lw	a5,0(a0)
ffffffffc0200e74:	2a079563          	bnez	a5,ffffffffc020111e <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e78:	00005797          	auipc	a5,0x5
ffffffffc0200e7c:	5f87b783          	ld	a5,1528(a5) # ffffffffc0206470 <pages>
ffffffffc0200e80:	40fa0733          	sub	a4,s4,a5
ffffffffc0200e84:	870d                	srai	a4,a4,0x3
ffffffffc0200e86:	00002597          	auipc	a1,0x2
ffffffffc0200e8a:	e025b583          	ld	a1,-510(a1) # ffffffffc0202c88 <nbase+0x8>
ffffffffc0200e8e:	02b70733          	mul	a4,a4,a1
ffffffffc0200e92:	00002617          	auipc	a2,0x2
ffffffffc0200e96:	dee63603          	ld	a2,-530(a2) # ffffffffc0202c80 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e9a:	00005697          	auipc	a3,0x5
ffffffffc0200e9e:	5ce6b683          	ld	a3,1486(a3) # ffffffffc0206468 <npage>
ffffffffc0200ea2:	06b2                	slli	a3,a3,0xc
ffffffffc0200ea4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ea6:	0732                	slli	a4,a4,0xc
ffffffffc0200ea8:	28d77b63          	bgeu	a4,a3,ffffffffc020113e <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200eac:	40f98733          	sub	a4,s3,a5
ffffffffc0200eb0:	870d                	srai	a4,a4,0x3
ffffffffc0200eb2:	02b70733          	mul	a4,a4,a1
ffffffffc0200eb6:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200eb8:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200eba:	4cd77263          	bgeu	a4,a3,ffffffffc020137e <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ebe:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ec2:	878d                	srai	a5,a5,0x3
ffffffffc0200ec4:	02b787b3          	mul	a5,a5,a1
ffffffffc0200ec8:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200eca:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ecc:	30d7f963          	bgeu	a5,a3,ffffffffc02011de <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200ed0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ed2:	00043c03          	ld	s8,0(s0)
ffffffffc0200ed6:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200eda:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200ede:	e400                	sd	s0,8(s0)
ffffffffc0200ee0:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200ee2:	00005797          	auipc	a5,0x5
ffffffffc0200ee6:	1407ab23          	sw	zero,342(a5) # ffffffffc0206038 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200eea:	c4dff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200eee:	2c051863          	bnez	a0,ffffffffc02011be <default_check+0x3d6>
    free_page(p0);
ffffffffc0200ef2:	4585                	li	a1,1
ffffffffc0200ef4:	8552                	mv	a0,s4
ffffffffc0200ef6:	c7fff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p1);
ffffffffc0200efa:	4585                	li	a1,1
ffffffffc0200efc:	854e                	mv	a0,s3
ffffffffc0200efe:	c77ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p2);
ffffffffc0200f02:	4585                	li	a1,1
ffffffffc0200f04:	8556                	mv	a0,s5
ffffffffc0200f06:	c6fff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f0a:	4818                	lw	a4,16(s0)
ffffffffc0200f0c:	478d                	li	a5,3
ffffffffc0200f0e:	28f71863          	bne	a4,a5,ffffffffc020119e <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f12:	4505                	li	a0,1
ffffffffc0200f14:	c23ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200f18:	89aa                	mv	s3,a0
ffffffffc0200f1a:	26050263          	beqz	a0,ffffffffc020117e <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f1e:	4505                	li	a0,1
ffffffffc0200f20:	c17ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200f24:	8aaa                	mv	s5,a0
ffffffffc0200f26:	3a050c63          	beqz	a0,ffffffffc02012de <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f2a:	4505                	li	a0,1
ffffffffc0200f2c:	c0bff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200f30:	8a2a                	mv	s4,a0
ffffffffc0200f32:	38050663          	beqz	a0,ffffffffc02012be <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200f36:	4505                	li	a0,1
ffffffffc0200f38:	bffff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200f3c:	36051163          	bnez	a0,ffffffffc020129e <default_check+0x4b6>
    free_page(p0);
ffffffffc0200f40:	4585                	li	a1,1
ffffffffc0200f42:	854e                	mv	a0,s3
ffffffffc0200f44:	c31ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f48:	641c                	ld	a5,8(s0)
ffffffffc0200f4a:	20878a63          	beq	a5,s0,ffffffffc020115e <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200f4e:	4505                	li	a0,1
ffffffffc0200f50:	be7ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200f54:	30a99563          	bne	s3,a0,ffffffffc020125e <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200f58:	4505                	li	a0,1
ffffffffc0200f5a:	bddff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200f5e:	2e051063          	bnez	a0,ffffffffc020123e <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200f62:	481c                	lw	a5,16(s0)
ffffffffc0200f64:	2a079d63          	bnez	a5,ffffffffc020121e <default_check+0x436>
    free_page(p);
ffffffffc0200f68:	854e                	mv	a0,s3
ffffffffc0200f6a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200f6c:	01843023          	sd	s8,0(s0)
ffffffffc0200f70:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200f74:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200f78:	bfdff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p1);
ffffffffc0200f7c:	4585                	li	a1,1
ffffffffc0200f7e:	8556                	mv	a0,s5
ffffffffc0200f80:	bf5ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p2);
ffffffffc0200f84:	4585                	li	a1,1
ffffffffc0200f86:	8552                	mv	a0,s4
ffffffffc0200f88:	bedff0ef          	jal	ra,ffffffffc0200b74 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200f8c:	4515                	li	a0,5
ffffffffc0200f8e:	ba9ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200f92:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200f94:	26050563          	beqz	a0,ffffffffc02011fe <default_check+0x416>
ffffffffc0200f98:	651c                	ld	a5,8(a0)
ffffffffc0200f9a:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200f9c:	8b85                	andi	a5,a5,1
ffffffffc0200f9e:	54079063          	bnez	a5,ffffffffc02014de <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200fa2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fa4:	00043b03          	ld	s6,0(s0)
ffffffffc0200fa8:	00843a83          	ld	s5,8(s0)
ffffffffc0200fac:	e000                	sd	s0,0(s0)
ffffffffc0200fae:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200fb0:	b87ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200fb4:	50051563          	bnez	a0,ffffffffc02014be <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200fb8:	05098a13          	addi	s4,s3,80
ffffffffc0200fbc:	8552                	mv	a0,s4
ffffffffc0200fbe:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200fc0:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200fc4:	00005797          	auipc	a5,0x5
ffffffffc0200fc8:	0607aa23          	sw	zero,116(a5) # ffffffffc0206038 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200fcc:	ba9ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200fd0:	4511                	li	a0,4
ffffffffc0200fd2:	b65ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200fd6:	4c051463          	bnez	a0,ffffffffc020149e <default_check+0x6b6>
ffffffffc0200fda:	0589b783          	ld	a5,88(s3)
ffffffffc0200fde:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200fe0:	8b85                	andi	a5,a5,1
ffffffffc0200fe2:	48078e63          	beqz	a5,ffffffffc020147e <default_check+0x696>
ffffffffc0200fe6:	0609a703          	lw	a4,96(s3)
ffffffffc0200fea:	478d                	li	a5,3
ffffffffc0200fec:	48f71963          	bne	a4,a5,ffffffffc020147e <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200ff0:	450d                	li	a0,3
ffffffffc0200ff2:	b45ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0200ff6:	8c2a                	mv	s8,a0
ffffffffc0200ff8:	46050363          	beqz	a0,ffffffffc020145e <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200ffc:	4505                	li	a0,1
ffffffffc0200ffe:	b39ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0201002:	42051e63          	bnez	a0,ffffffffc020143e <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0201006:	418a1c63          	bne	s4,s8,ffffffffc020141e <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020100a:	4585                	li	a1,1
ffffffffc020100c:	854e                	mv	a0,s3
ffffffffc020100e:	b67ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_pages(p1, 3);
ffffffffc0201012:	458d                	li	a1,3
ffffffffc0201014:	8552                	mv	a0,s4
ffffffffc0201016:	b5fff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
ffffffffc020101a:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020101e:	02898c13          	addi	s8,s3,40
ffffffffc0201022:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201024:	8b85                	andi	a5,a5,1
ffffffffc0201026:	3c078c63          	beqz	a5,ffffffffc02013fe <default_check+0x616>
ffffffffc020102a:	0109a703          	lw	a4,16(s3)
ffffffffc020102e:	4785                	li	a5,1
ffffffffc0201030:	3cf71763          	bne	a4,a5,ffffffffc02013fe <default_check+0x616>
ffffffffc0201034:	008a3783          	ld	a5,8(s4)
ffffffffc0201038:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020103a:	8b85                	andi	a5,a5,1
ffffffffc020103c:	3a078163          	beqz	a5,ffffffffc02013de <default_check+0x5f6>
ffffffffc0201040:	010a2703          	lw	a4,16(s4)
ffffffffc0201044:	478d                	li	a5,3
ffffffffc0201046:	38f71c63          	bne	a4,a5,ffffffffc02013de <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020104a:	4505                	li	a0,1
ffffffffc020104c:	aebff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0201050:	36a99763          	bne	s3,a0,ffffffffc02013be <default_check+0x5d6>
    free_page(p0);
ffffffffc0201054:	4585                	li	a1,1
ffffffffc0201056:	b1fff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020105a:	4509                	li	a0,2
ffffffffc020105c:	adbff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0201060:	32aa1f63          	bne	s4,a0,ffffffffc020139e <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0201064:	4589                	li	a1,2
ffffffffc0201066:	b0fff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p2);
ffffffffc020106a:	4585                	li	a1,1
ffffffffc020106c:	8562                	mv	a0,s8
ffffffffc020106e:	b07ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201072:	4515                	li	a0,5
ffffffffc0201074:	ac3ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0201078:	89aa                	mv	s3,a0
ffffffffc020107a:	48050263          	beqz	a0,ffffffffc02014fe <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc020107e:	4505                	li	a0,1
ffffffffc0201080:	ab7ff0ef          	jal	ra,ffffffffc0200b36 <alloc_pages>
ffffffffc0201084:	2c051d63          	bnez	a0,ffffffffc020135e <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0201088:	481c                	lw	a5,16(s0)
ffffffffc020108a:	2a079a63          	bnez	a5,ffffffffc020133e <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020108e:	4595                	li	a1,5
ffffffffc0201090:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201092:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0201096:	01643023          	sd	s6,0(s0)
ffffffffc020109a:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc020109e:	ad7ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    return listelm->next;
ffffffffc02010a2:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010a4:	00878963          	beq	a5,s0,ffffffffc02010b6 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02010a8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010ac:	679c                	ld	a5,8(a5)
ffffffffc02010ae:	397d                	addiw	s2,s2,-1
ffffffffc02010b0:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010b2:	fe879be3          	bne	a5,s0,ffffffffc02010a8 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc02010b6:	26091463          	bnez	s2,ffffffffc020131e <default_check+0x536>
    assert(total == 0);
ffffffffc02010ba:	46049263          	bnez	s1,ffffffffc020151e <default_check+0x736>
}
ffffffffc02010be:	60a6                	ld	ra,72(sp)
ffffffffc02010c0:	6406                	ld	s0,64(sp)
ffffffffc02010c2:	74e2                	ld	s1,56(sp)
ffffffffc02010c4:	7942                	ld	s2,48(sp)
ffffffffc02010c6:	79a2                	ld	s3,40(sp)
ffffffffc02010c8:	7a02                	ld	s4,32(sp)
ffffffffc02010ca:	6ae2                	ld	s5,24(sp)
ffffffffc02010cc:	6b42                	ld	s6,16(sp)
ffffffffc02010ce:	6ba2                	ld	s7,8(sp)
ffffffffc02010d0:	6c02                	ld	s8,0(sp)
ffffffffc02010d2:	6161                	addi	sp,sp,80
ffffffffc02010d4:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010d6:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02010d8:	4481                	li	s1,0
ffffffffc02010da:	4901                	li	s2,0
ffffffffc02010dc:	b3b9                	j	ffffffffc0200e2a <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02010de:	00001697          	auipc	a3,0x1
ffffffffc02010e2:	56268693          	addi	a3,a3,1378 # ffffffffc0202640 <commands+0x558>
ffffffffc02010e6:	00001617          	auipc	a2,0x1
ffffffffc02010ea:	56a60613          	addi	a2,a2,1386 # ffffffffc0202650 <commands+0x568>
ffffffffc02010ee:	0f000593          	li	a1,240
ffffffffc02010f2:	00001517          	auipc	a0,0x1
ffffffffc02010f6:	57650513          	addi	a0,a0,1398 # ffffffffc0202668 <commands+0x580>
ffffffffc02010fa:	86cff0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02010fe:	00001697          	auipc	a3,0x1
ffffffffc0201102:	60268693          	addi	a3,a3,1538 # ffffffffc0202700 <commands+0x618>
ffffffffc0201106:	00001617          	auipc	a2,0x1
ffffffffc020110a:	54a60613          	addi	a2,a2,1354 # ffffffffc0202650 <commands+0x568>
ffffffffc020110e:	0bd00593          	li	a1,189
ffffffffc0201112:	00001517          	auipc	a0,0x1
ffffffffc0201116:	55650513          	addi	a0,a0,1366 # ffffffffc0202668 <commands+0x580>
ffffffffc020111a:	84cff0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020111e:	00001697          	auipc	a3,0x1
ffffffffc0201122:	60a68693          	addi	a3,a3,1546 # ffffffffc0202728 <commands+0x640>
ffffffffc0201126:	00001617          	auipc	a2,0x1
ffffffffc020112a:	52a60613          	addi	a2,a2,1322 # ffffffffc0202650 <commands+0x568>
ffffffffc020112e:	0be00593          	li	a1,190
ffffffffc0201132:	00001517          	auipc	a0,0x1
ffffffffc0201136:	53650513          	addi	a0,a0,1334 # ffffffffc0202668 <commands+0x580>
ffffffffc020113a:	82cff0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020113e:	00001697          	auipc	a3,0x1
ffffffffc0201142:	62a68693          	addi	a3,a3,1578 # ffffffffc0202768 <commands+0x680>
ffffffffc0201146:	00001617          	auipc	a2,0x1
ffffffffc020114a:	50a60613          	addi	a2,a2,1290 # ffffffffc0202650 <commands+0x568>
ffffffffc020114e:	0c000593          	li	a1,192
ffffffffc0201152:	00001517          	auipc	a0,0x1
ffffffffc0201156:	51650513          	addi	a0,a0,1302 # ffffffffc0202668 <commands+0x580>
ffffffffc020115a:	80cff0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020115e:	00001697          	auipc	a3,0x1
ffffffffc0201162:	69268693          	addi	a3,a3,1682 # ffffffffc02027f0 <commands+0x708>
ffffffffc0201166:	00001617          	auipc	a2,0x1
ffffffffc020116a:	4ea60613          	addi	a2,a2,1258 # ffffffffc0202650 <commands+0x568>
ffffffffc020116e:	0d900593          	li	a1,217
ffffffffc0201172:	00001517          	auipc	a0,0x1
ffffffffc0201176:	4f650513          	addi	a0,a0,1270 # ffffffffc0202668 <commands+0x580>
ffffffffc020117a:	fedfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020117e:	00001697          	auipc	a3,0x1
ffffffffc0201182:	52268693          	addi	a3,a3,1314 # ffffffffc02026a0 <commands+0x5b8>
ffffffffc0201186:	00001617          	auipc	a2,0x1
ffffffffc020118a:	4ca60613          	addi	a2,a2,1226 # ffffffffc0202650 <commands+0x568>
ffffffffc020118e:	0d200593          	li	a1,210
ffffffffc0201192:	00001517          	auipc	a0,0x1
ffffffffc0201196:	4d650513          	addi	a0,a0,1238 # ffffffffc0202668 <commands+0x580>
ffffffffc020119a:	fcdfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(nr_free == 3);
ffffffffc020119e:	00001697          	auipc	a3,0x1
ffffffffc02011a2:	64268693          	addi	a3,a3,1602 # ffffffffc02027e0 <commands+0x6f8>
ffffffffc02011a6:	00001617          	auipc	a2,0x1
ffffffffc02011aa:	4aa60613          	addi	a2,a2,1194 # ffffffffc0202650 <commands+0x568>
ffffffffc02011ae:	0d000593          	li	a1,208
ffffffffc02011b2:	00001517          	auipc	a0,0x1
ffffffffc02011b6:	4b650513          	addi	a0,a0,1206 # ffffffffc0202668 <commands+0x580>
ffffffffc02011ba:	fadfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011be:	00001697          	auipc	a3,0x1
ffffffffc02011c2:	60a68693          	addi	a3,a3,1546 # ffffffffc02027c8 <commands+0x6e0>
ffffffffc02011c6:	00001617          	auipc	a2,0x1
ffffffffc02011ca:	48a60613          	addi	a2,a2,1162 # ffffffffc0202650 <commands+0x568>
ffffffffc02011ce:	0cb00593          	li	a1,203
ffffffffc02011d2:	00001517          	auipc	a0,0x1
ffffffffc02011d6:	49650513          	addi	a0,a0,1174 # ffffffffc0202668 <commands+0x580>
ffffffffc02011da:	f8dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02011de:	00001697          	auipc	a3,0x1
ffffffffc02011e2:	5ca68693          	addi	a3,a3,1482 # ffffffffc02027a8 <commands+0x6c0>
ffffffffc02011e6:	00001617          	auipc	a2,0x1
ffffffffc02011ea:	46a60613          	addi	a2,a2,1130 # ffffffffc0202650 <commands+0x568>
ffffffffc02011ee:	0c200593          	li	a1,194
ffffffffc02011f2:	00001517          	auipc	a0,0x1
ffffffffc02011f6:	47650513          	addi	a0,a0,1142 # ffffffffc0202668 <commands+0x580>
ffffffffc02011fa:	f6dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(p0 != NULL);
ffffffffc02011fe:	00001697          	auipc	a3,0x1
ffffffffc0201202:	63a68693          	addi	a3,a3,1594 # ffffffffc0202838 <commands+0x750>
ffffffffc0201206:	00001617          	auipc	a2,0x1
ffffffffc020120a:	44a60613          	addi	a2,a2,1098 # ffffffffc0202650 <commands+0x568>
ffffffffc020120e:	0f800593          	li	a1,248
ffffffffc0201212:	00001517          	auipc	a0,0x1
ffffffffc0201216:	45650513          	addi	a0,a0,1110 # ffffffffc0202668 <commands+0x580>
ffffffffc020121a:	f4dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(nr_free == 0);
ffffffffc020121e:	00001697          	auipc	a3,0x1
ffffffffc0201222:	60a68693          	addi	a3,a3,1546 # ffffffffc0202828 <commands+0x740>
ffffffffc0201226:	00001617          	auipc	a2,0x1
ffffffffc020122a:	42a60613          	addi	a2,a2,1066 # ffffffffc0202650 <commands+0x568>
ffffffffc020122e:	0df00593          	li	a1,223
ffffffffc0201232:	00001517          	auipc	a0,0x1
ffffffffc0201236:	43650513          	addi	a0,a0,1078 # ffffffffc0202668 <commands+0x580>
ffffffffc020123a:	f2dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020123e:	00001697          	auipc	a3,0x1
ffffffffc0201242:	58a68693          	addi	a3,a3,1418 # ffffffffc02027c8 <commands+0x6e0>
ffffffffc0201246:	00001617          	auipc	a2,0x1
ffffffffc020124a:	40a60613          	addi	a2,a2,1034 # ffffffffc0202650 <commands+0x568>
ffffffffc020124e:	0dd00593          	li	a1,221
ffffffffc0201252:	00001517          	auipc	a0,0x1
ffffffffc0201256:	41650513          	addi	a0,a0,1046 # ffffffffc0202668 <commands+0x580>
ffffffffc020125a:	f0dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020125e:	00001697          	auipc	a3,0x1
ffffffffc0201262:	5aa68693          	addi	a3,a3,1450 # ffffffffc0202808 <commands+0x720>
ffffffffc0201266:	00001617          	auipc	a2,0x1
ffffffffc020126a:	3ea60613          	addi	a2,a2,1002 # ffffffffc0202650 <commands+0x568>
ffffffffc020126e:	0dc00593          	li	a1,220
ffffffffc0201272:	00001517          	auipc	a0,0x1
ffffffffc0201276:	3f650513          	addi	a0,a0,1014 # ffffffffc0202668 <commands+0x580>
ffffffffc020127a:	eedfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020127e:	00001697          	auipc	a3,0x1
ffffffffc0201282:	42268693          	addi	a3,a3,1058 # ffffffffc02026a0 <commands+0x5b8>
ffffffffc0201286:	00001617          	auipc	a2,0x1
ffffffffc020128a:	3ca60613          	addi	a2,a2,970 # ffffffffc0202650 <commands+0x568>
ffffffffc020128e:	0b900593          	li	a1,185
ffffffffc0201292:	00001517          	auipc	a0,0x1
ffffffffc0201296:	3d650513          	addi	a0,a0,982 # ffffffffc0202668 <commands+0x580>
ffffffffc020129a:	ecdfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020129e:	00001697          	auipc	a3,0x1
ffffffffc02012a2:	52a68693          	addi	a3,a3,1322 # ffffffffc02027c8 <commands+0x6e0>
ffffffffc02012a6:	00001617          	auipc	a2,0x1
ffffffffc02012aa:	3aa60613          	addi	a2,a2,938 # ffffffffc0202650 <commands+0x568>
ffffffffc02012ae:	0d600593          	li	a1,214
ffffffffc02012b2:	00001517          	auipc	a0,0x1
ffffffffc02012b6:	3b650513          	addi	a0,a0,950 # ffffffffc0202668 <commands+0x580>
ffffffffc02012ba:	eadfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02012be:	00001697          	auipc	a3,0x1
ffffffffc02012c2:	42268693          	addi	a3,a3,1058 # ffffffffc02026e0 <commands+0x5f8>
ffffffffc02012c6:	00001617          	auipc	a2,0x1
ffffffffc02012ca:	38a60613          	addi	a2,a2,906 # ffffffffc0202650 <commands+0x568>
ffffffffc02012ce:	0d400593          	li	a1,212
ffffffffc02012d2:	00001517          	auipc	a0,0x1
ffffffffc02012d6:	39650513          	addi	a0,a0,918 # ffffffffc0202668 <commands+0x580>
ffffffffc02012da:	e8dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012de:	00001697          	auipc	a3,0x1
ffffffffc02012e2:	3e268693          	addi	a3,a3,994 # ffffffffc02026c0 <commands+0x5d8>
ffffffffc02012e6:	00001617          	auipc	a2,0x1
ffffffffc02012ea:	36a60613          	addi	a2,a2,874 # ffffffffc0202650 <commands+0x568>
ffffffffc02012ee:	0d300593          	li	a1,211
ffffffffc02012f2:	00001517          	auipc	a0,0x1
ffffffffc02012f6:	37650513          	addi	a0,a0,886 # ffffffffc0202668 <commands+0x580>
ffffffffc02012fa:	e6dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02012fe:	00001697          	auipc	a3,0x1
ffffffffc0201302:	3e268693          	addi	a3,a3,994 # ffffffffc02026e0 <commands+0x5f8>
ffffffffc0201306:	00001617          	auipc	a2,0x1
ffffffffc020130a:	34a60613          	addi	a2,a2,842 # ffffffffc0202650 <commands+0x568>
ffffffffc020130e:	0bb00593          	li	a1,187
ffffffffc0201312:	00001517          	auipc	a0,0x1
ffffffffc0201316:	35650513          	addi	a0,a0,854 # ffffffffc0202668 <commands+0x580>
ffffffffc020131a:	e4dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(count == 0);
ffffffffc020131e:	00001697          	auipc	a3,0x1
ffffffffc0201322:	66a68693          	addi	a3,a3,1642 # ffffffffc0202988 <commands+0x8a0>
ffffffffc0201326:	00001617          	auipc	a2,0x1
ffffffffc020132a:	32a60613          	addi	a2,a2,810 # ffffffffc0202650 <commands+0x568>
ffffffffc020132e:	12500593          	li	a1,293
ffffffffc0201332:	00001517          	auipc	a0,0x1
ffffffffc0201336:	33650513          	addi	a0,a0,822 # ffffffffc0202668 <commands+0x580>
ffffffffc020133a:	e2dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(nr_free == 0);
ffffffffc020133e:	00001697          	auipc	a3,0x1
ffffffffc0201342:	4ea68693          	addi	a3,a3,1258 # ffffffffc0202828 <commands+0x740>
ffffffffc0201346:	00001617          	auipc	a2,0x1
ffffffffc020134a:	30a60613          	addi	a2,a2,778 # ffffffffc0202650 <commands+0x568>
ffffffffc020134e:	11a00593          	li	a1,282
ffffffffc0201352:	00001517          	auipc	a0,0x1
ffffffffc0201356:	31650513          	addi	a0,a0,790 # ffffffffc0202668 <commands+0x580>
ffffffffc020135a:	e0dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020135e:	00001697          	auipc	a3,0x1
ffffffffc0201362:	46a68693          	addi	a3,a3,1130 # ffffffffc02027c8 <commands+0x6e0>
ffffffffc0201366:	00001617          	auipc	a2,0x1
ffffffffc020136a:	2ea60613          	addi	a2,a2,746 # ffffffffc0202650 <commands+0x568>
ffffffffc020136e:	11800593          	li	a1,280
ffffffffc0201372:	00001517          	auipc	a0,0x1
ffffffffc0201376:	2f650513          	addi	a0,a0,758 # ffffffffc0202668 <commands+0x580>
ffffffffc020137a:	dedfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020137e:	00001697          	auipc	a3,0x1
ffffffffc0201382:	40a68693          	addi	a3,a3,1034 # ffffffffc0202788 <commands+0x6a0>
ffffffffc0201386:	00001617          	auipc	a2,0x1
ffffffffc020138a:	2ca60613          	addi	a2,a2,714 # ffffffffc0202650 <commands+0x568>
ffffffffc020138e:	0c100593          	li	a1,193
ffffffffc0201392:	00001517          	auipc	a0,0x1
ffffffffc0201396:	2d650513          	addi	a0,a0,726 # ffffffffc0202668 <commands+0x580>
ffffffffc020139a:	dcdfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020139e:	00001697          	auipc	a3,0x1
ffffffffc02013a2:	5aa68693          	addi	a3,a3,1450 # ffffffffc0202948 <commands+0x860>
ffffffffc02013a6:	00001617          	auipc	a2,0x1
ffffffffc02013aa:	2aa60613          	addi	a2,a2,682 # ffffffffc0202650 <commands+0x568>
ffffffffc02013ae:	11200593          	li	a1,274
ffffffffc02013b2:	00001517          	auipc	a0,0x1
ffffffffc02013b6:	2b650513          	addi	a0,a0,694 # ffffffffc0202668 <commands+0x580>
ffffffffc02013ba:	dadfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02013be:	00001697          	auipc	a3,0x1
ffffffffc02013c2:	56a68693          	addi	a3,a3,1386 # ffffffffc0202928 <commands+0x840>
ffffffffc02013c6:	00001617          	auipc	a2,0x1
ffffffffc02013ca:	28a60613          	addi	a2,a2,650 # ffffffffc0202650 <commands+0x568>
ffffffffc02013ce:	11000593          	li	a1,272
ffffffffc02013d2:	00001517          	auipc	a0,0x1
ffffffffc02013d6:	29650513          	addi	a0,a0,662 # ffffffffc0202668 <commands+0x580>
ffffffffc02013da:	d8dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02013de:	00001697          	auipc	a3,0x1
ffffffffc02013e2:	52268693          	addi	a3,a3,1314 # ffffffffc0202900 <commands+0x818>
ffffffffc02013e6:	00001617          	auipc	a2,0x1
ffffffffc02013ea:	26a60613          	addi	a2,a2,618 # ffffffffc0202650 <commands+0x568>
ffffffffc02013ee:	10e00593          	li	a1,270
ffffffffc02013f2:	00001517          	auipc	a0,0x1
ffffffffc02013f6:	27650513          	addi	a0,a0,630 # ffffffffc0202668 <commands+0x580>
ffffffffc02013fa:	d6dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02013fe:	00001697          	auipc	a3,0x1
ffffffffc0201402:	4da68693          	addi	a3,a3,1242 # ffffffffc02028d8 <commands+0x7f0>
ffffffffc0201406:	00001617          	auipc	a2,0x1
ffffffffc020140a:	24a60613          	addi	a2,a2,586 # ffffffffc0202650 <commands+0x568>
ffffffffc020140e:	10d00593          	li	a1,269
ffffffffc0201412:	00001517          	auipc	a0,0x1
ffffffffc0201416:	25650513          	addi	a0,a0,598 # ffffffffc0202668 <commands+0x580>
ffffffffc020141a:	d4dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020141e:	00001697          	auipc	a3,0x1
ffffffffc0201422:	4aa68693          	addi	a3,a3,1194 # ffffffffc02028c8 <commands+0x7e0>
ffffffffc0201426:	00001617          	auipc	a2,0x1
ffffffffc020142a:	22a60613          	addi	a2,a2,554 # ffffffffc0202650 <commands+0x568>
ffffffffc020142e:	10800593          	li	a1,264
ffffffffc0201432:	00001517          	auipc	a0,0x1
ffffffffc0201436:	23650513          	addi	a0,a0,566 # ffffffffc0202668 <commands+0x580>
ffffffffc020143a:	d2dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020143e:	00001697          	auipc	a3,0x1
ffffffffc0201442:	38a68693          	addi	a3,a3,906 # ffffffffc02027c8 <commands+0x6e0>
ffffffffc0201446:	00001617          	auipc	a2,0x1
ffffffffc020144a:	20a60613          	addi	a2,a2,522 # ffffffffc0202650 <commands+0x568>
ffffffffc020144e:	10700593          	li	a1,263
ffffffffc0201452:	00001517          	auipc	a0,0x1
ffffffffc0201456:	21650513          	addi	a0,a0,534 # ffffffffc0202668 <commands+0x580>
ffffffffc020145a:	d0dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020145e:	00001697          	auipc	a3,0x1
ffffffffc0201462:	44a68693          	addi	a3,a3,1098 # ffffffffc02028a8 <commands+0x7c0>
ffffffffc0201466:	00001617          	auipc	a2,0x1
ffffffffc020146a:	1ea60613          	addi	a2,a2,490 # ffffffffc0202650 <commands+0x568>
ffffffffc020146e:	10600593          	li	a1,262
ffffffffc0201472:	00001517          	auipc	a0,0x1
ffffffffc0201476:	1f650513          	addi	a0,a0,502 # ffffffffc0202668 <commands+0x580>
ffffffffc020147a:	cedfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020147e:	00001697          	auipc	a3,0x1
ffffffffc0201482:	3fa68693          	addi	a3,a3,1018 # ffffffffc0202878 <commands+0x790>
ffffffffc0201486:	00001617          	auipc	a2,0x1
ffffffffc020148a:	1ca60613          	addi	a2,a2,458 # ffffffffc0202650 <commands+0x568>
ffffffffc020148e:	10500593          	li	a1,261
ffffffffc0201492:	00001517          	auipc	a0,0x1
ffffffffc0201496:	1d650513          	addi	a0,a0,470 # ffffffffc0202668 <commands+0x580>
ffffffffc020149a:	ccdfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020149e:	00001697          	auipc	a3,0x1
ffffffffc02014a2:	3c268693          	addi	a3,a3,962 # ffffffffc0202860 <commands+0x778>
ffffffffc02014a6:	00001617          	auipc	a2,0x1
ffffffffc02014aa:	1aa60613          	addi	a2,a2,426 # ffffffffc0202650 <commands+0x568>
ffffffffc02014ae:	10400593          	li	a1,260
ffffffffc02014b2:	00001517          	auipc	a0,0x1
ffffffffc02014b6:	1b650513          	addi	a0,a0,438 # ffffffffc0202668 <commands+0x580>
ffffffffc02014ba:	cadfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014be:	00001697          	auipc	a3,0x1
ffffffffc02014c2:	30a68693          	addi	a3,a3,778 # ffffffffc02027c8 <commands+0x6e0>
ffffffffc02014c6:	00001617          	auipc	a2,0x1
ffffffffc02014ca:	18a60613          	addi	a2,a2,394 # ffffffffc0202650 <commands+0x568>
ffffffffc02014ce:	0fe00593          	li	a1,254
ffffffffc02014d2:	00001517          	auipc	a0,0x1
ffffffffc02014d6:	19650513          	addi	a0,a0,406 # ffffffffc0202668 <commands+0x580>
ffffffffc02014da:	c8dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(!PageProperty(p0));
ffffffffc02014de:	00001697          	auipc	a3,0x1
ffffffffc02014e2:	36a68693          	addi	a3,a3,874 # ffffffffc0202848 <commands+0x760>
ffffffffc02014e6:	00001617          	auipc	a2,0x1
ffffffffc02014ea:	16a60613          	addi	a2,a2,362 # ffffffffc0202650 <commands+0x568>
ffffffffc02014ee:	0f900593          	li	a1,249
ffffffffc02014f2:	00001517          	auipc	a0,0x1
ffffffffc02014f6:	17650513          	addi	a0,a0,374 # ffffffffc0202668 <commands+0x580>
ffffffffc02014fa:	c6dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02014fe:	00001697          	auipc	a3,0x1
ffffffffc0201502:	46a68693          	addi	a3,a3,1130 # ffffffffc0202968 <commands+0x880>
ffffffffc0201506:	00001617          	auipc	a2,0x1
ffffffffc020150a:	14a60613          	addi	a2,a2,330 # ffffffffc0202650 <commands+0x568>
ffffffffc020150e:	11700593          	li	a1,279
ffffffffc0201512:	00001517          	auipc	a0,0x1
ffffffffc0201516:	15650513          	addi	a0,a0,342 # ffffffffc0202668 <commands+0x580>
ffffffffc020151a:	c4dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(total == 0);
ffffffffc020151e:	00001697          	auipc	a3,0x1
ffffffffc0201522:	47a68693          	addi	a3,a3,1146 # ffffffffc0202998 <commands+0x8b0>
ffffffffc0201526:	00001617          	auipc	a2,0x1
ffffffffc020152a:	12a60613          	addi	a2,a2,298 # ffffffffc0202650 <commands+0x568>
ffffffffc020152e:	12600593          	li	a1,294
ffffffffc0201532:	00001517          	auipc	a0,0x1
ffffffffc0201536:	13650513          	addi	a0,a0,310 # ffffffffc0202668 <commands+0x580>
ffffffffc020153a:	c2dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(total == nr_free_pages());
ffffffffc020153e:	00001697          	auipc	a3,0x1
ffffffffc0201542:	14268693          	addi	a3,a3,322 # ffffffffc0202680 <commands+0x598>
ffffffffc0201546:	00001617          	auipc	a2,0x1
ffffffffc020154a:	10a60613          	addi	a2,a2,266 # ffffffffc0202650 <commands+0x568>
ffffffffc020154e:	0f300593          	li	a1,243
ffffffffc0201552:	00001517          	auipc	a0,0x1
ffffffffc0201556:	11650513          	addi	a0,a0,278 # ffffffffc0202668 <commands+0x580>
ffffffffc020155a:	c0dfe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020155e:	00001697          	auipc	a3,0x1
ffffffffc0201562:	16268693          	addi	a3,a3,354 # ffffffffc02026c0 <commands+0x5d8>
ffffffffc0201566:	00001617          	auipc	a2,0x1
ffffffffc020156a:	0ea60613          	addi	a2,a2,234 # ffffffffc0202650 <commands+0x568>
ffffffffc020156e:	0ba00593          	li	a1,186
ffffffffc0201572:	00001517          	auipc	a0,0x1
ffffffffc0201576:	0f650513          	addi	a0,a0,246 # ffffffffc0202668 <commands+0x580>
ffffffffc020157a:	bedfe0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc020157e <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020157e:	1141                	addi	sp,sp,-16
ffffffffc0201580:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201582:	14058a63          	beqz	a1,ffffffffc02016d6 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0201586:	00259693          	slli	a3,a1,0x2
ffffffffc020158a:	96ae                	add	a3,a3,a1
ffffffffc020158c:	068e                	slli	a3,a3,0x3
ffffffffc020158e:	96aa                	add	a3,a3,a0
ffffffffc0201590:	87aa                	mv	a5,a0
ffffffffc0201592:	02d50263          	beq	a0,a3,ffffffffc02015b6 <default_free_pages+0x38>
ffffffffc0201596:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201598:	8b05                	andi	a4,a4,1
ffffffffc020159a:	10071e63          	bnez	a4,ffffffffc02016b6 <default_free_pages+0x138>
ffffffffc020159e:	6798                	ld	a4,8(a5)
ffffffffc02015a0:	8b09                	andi	a4,a4,2
ffffffffc02015a2:	10071a63          	bnez	a4,ffffffffc02016b6 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc02015a6:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02015aa:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015ae:	02878793          	addi	a5,a5,40
ffffffffc02015b2:	fed792e3          	bne	a5,a3,ffffffffc0201596 <default_free_pages+0x18>
    base->property = n;
ffffffffc02015b6:	2581                	sext.w	a1,a1
ffffffffc02015b8:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02015ba:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015be:	4789                	li	a5,2
ffffffffc02015c0:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02015c4:	00005697          	auipc	a3,0x5
ffffffffc02015c8:	a6468693          	addi	a3,a3,-1436 # ffffffffc0206028 <free_area>
ffffffffc02015cc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015ce:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02015d0:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02015d4:	9db9                	addw	a1,a1,a4
ffffffffc02015d6:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02015d8:	0ad78863          	beq	a5,a3,ffffffffc0201688 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02015dc:	fe878713          	addi	a4,a5,-24
ffffffffc02015e0:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015e4:	4581                	li	a1,0
            if (base < page) {
ffffffffc02015e6:	00e56a63          	bltu	a0,a4,ffffffffc02015fa <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02015ea:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015ec:	06d70263          	beq	a4,a3,ffffffffc0201650 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02015f0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02015f2:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02015f6:	fee57ae3          	bgeu	a0,a4,ffffffffc02015ea <default_free_pages+0x6c>
ffffffffc02015fa:	c199                	beqz	a1,ffffffffc0201600 <default_free_pages+0x82>
ffffffffc02015fc:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201600:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201602:	e390                	sd	a2,0(a5)
ffffffffc0201604:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201606:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201608:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc020160a:	02d70063          	beq	a4,a3,ffffffffc020162a <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc020160e:	ff872803          	lw	a6,-8(a4) # fffffffffff7fff8 <end+0x3fd79b58>
        p = le2page(le, page_link);
ffffffffc0201612:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc0201616:	02081613          	slli	a2,a6,0x20
ffffffffc020161a:	9201                	srli	a2,a2,0x20
ffffffffc020161c:	00261793          	slli	a5,a2,0x2
ffffffffc0201620:	97b2                	add	a5,a5,a2
ffffffffc0201622:	078e                	slli	a5,a5,0x3
ffffffffc0201624:	97ae                	add	a5,a5,a1
ffffffffc0201626:	02f50f63          	beq	a0,a5,ffffffffc0201664 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020162a:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc020162c:	00d70f63          	beq	a4,a3,ffffffffc020164a <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201630:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201632:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0201636:	02059613          	slli	a2,a1,0x20
ffffffffc020163a:	9201                	srli	a2,a2,0x20
ffffffffc020163c:	00261793          	slli	a5,a2,0x2
ffffffffc0201640:	97b2                	add	a5,a5,a2
ffffffffc0201642:	078e                	slli	a5,a5,0x3
ffffffffc0201644:	97aa                	add	a5,a5,a0
ffffffffc0201646:	04f68863          	beq	a3,a5,ffffffffc0201696 <default_free_pages+0x118>
}
ffffffffc020164a:	60a2                	ld	ra,8(sp)
ffffffffc020164c:	0141                	addi	sp,sp,16
ffffffffc020164e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201650:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201652:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201654:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201656:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201658:	02d70563          	beq	a4,a3,ffffffffc0201682 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc020165c:	8832                	mv	a6,a2
ffffffffc020165e:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201660:	87ba                	mv	a5,a4
ffffffffc0201662:	bf41                	j	ffffffffc02015f2 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0201664:	491c                	lw	a5,16(a0)
ffffffffc0201666:	0107883b          	addw	a6,a5,a6
ffffffffc020166a:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020166e:	57f5                	li	a5,-3
ffffffffc0201670:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201674:	6d10                	ld	a2,24(a0)
ffffffffc0201676:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc0201678:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020167a:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc020167c:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc020167e:	e390                	sd	a2,0(a5)
ffffffffc0201680:	b775                	j	ffffffffc020162c <default_free_pages+0xae>
ffffffffc0201682:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201684:	873e                	mv	a4,a5
ffffffffc0201686:	b761                	j	ffffffffc020160e <default_free_pages+0x90>
}
ffffffffc0201688:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020168a:	e390                	sd	a2,0(a5)
ffffffffc020168c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020168e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201690:	ed1c                	sd	a5,24(a0)
ffffffffc0201692:	0141                	addi	sp,sp,16
ffffffffc0201694:	8082                	ret
            base->property += p->property;
ffffffffc0201696:	ff872783          	lw	a5,-8(a4)
ffffffffc020169a:	ff070693          	addi	a3,a4,-16
ffffffffc020169e:	9dbd                	addw	a1,a1,a5
ffffffffc02016a0:	c90c                	sw	a1,16(a0)
ffffffffc02016a2:	57f5                	li	a5,-3
ffffffffc02016a4:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016a8:	6314                	ld	a3,0(a4)
ffffffffc02016aa:	671c                	ld	a5,8(a4)
}
ffffffffc02016ac:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02016ae:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02016b0:	e394                	sd	a3,0(a5)
ffffffffc02016b2:	0141                	addi	sp,sp,16
ffffffffc02016b4:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016b6:	00001697          	auipc	a3,0x1
ffffffffc02016ba:	2fa68693          	addi	a3,a3,762 # ffffffffc02029b0 <commands+0x8c8>
ffffffffc02016be:	00001617          	auipc	a2,0x1
ffffffffc02016c2:	f9260613          	addi	a2,a2,-110 # ffffffffc0202650 <commands+0x568>
ffffffffc02016c6:	08300593          	li	a1,131
ffffffffc02016ca:	00001517          	auipc	a0,0x1
ffffffffc02016ce:	f9e50513          	addi	a0,a0,-98 # ffffffffc0202668 <commands+0x580>
ffffffffc02016d2:	a95fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(n > 0);
ffffffffc02016d6:	00001697          	auipc	a3,0x1
ffffffffc02016da:	2d268693          	addi	a3,a3,722 # ffffffffc02029a8 <commands+0x8c0>
ffffffffc02016de:	00001617          	auipc	a2,0x1
ffffffffc02016e2:	f7260613          	addi	a2,a2,-142 # ffffffffc0202650 <commands+0x568>
ffffffffc02016e6:	08000593          	li	a1,128
ffffffffc02016ea:	00001517          	auipc	a0,0x1
ffffffffc02016ee:	f7e50513          	addi	a0,a0,-130 # ffffffffc0202668 <commands+0x580>
ffffffffc02016f2:	a75fe0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc02016f6 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02016f6:	c959                	beqz	a0,ffffffffc020178c <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02016f8:	00005597          	auipc	a1,0x5
ffffffffc02016fc:	93058593          	addi	a1,a1,-1744 # ffffffffc0206028 <free_area>
ffffffffc0201700:	0105a803          	lw	a6,16(a1)
ffffffffc0201704:	862a                	mv	a2,a0
ffffffffc0201706:	02081793          	slli	a5,a6,0x20
ffffffffc020170a:	9381                	srli	a5,a5,0x20
ffffffffc020170c:	00a7ee63          	bltu	a5,a0,ffffffffc0201728 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201710:	87ae                	mv	a5,a1
ffffffffc0201712:	a801                	j	ffffffffc0201722 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201714:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201718:	02071693          	slli	a3,a4,0x20
ffffffffc020171c:	9281                	srli	a3,a3,0x20
ffffffffc020171e:	00c6f763          	bgeu	a3,a2,ffffffffc020172c <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201722:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201724:	feb798e3          	bne	a5,a1,ffffffffc0201714 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201728:	4501                	li	a0,0
}
ffffffffc020172a:	8082                	ret
    return listelm->prev;
ffffffffc020172c:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201730:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201734:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201738:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc020173c:	0068b423          	sd	t1,8(a7) # fffffffffff80008 <end+0x3fd79b68>
    next->prev = prev;
ffffffffc0201740:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201744:	02d67b63          	bgeu	a2,a3,ffffffffc020177a <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc0201748:	00261693          	slli	a3,a2,0x2
ffffffffc020174c:	96b2                	add	a3,a3,a2
ffffffffc020174e:	068e                	slli	a3,a3,0x3
ffffffffc0201750:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201752:	41c7073b          	subw	a4,a4,t3
ffffffffc0201756:	ca98                	sw	a4,16(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201758:	00868613          	addi	a2,a3,8
ffffffffc020175c:	4709                	li	a4,2
ffffffffc020175e:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201762:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201766:	01868613          	addi	a2,a3,24
        nr_free -= n;
ffffffffc020176a:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020176e:	e310                	sd	a2,0(a4)
ffffffffc0201770:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201774:	f298                	sd	a4,32(a3)
    elm->prev = prev;
ffffffffc0201776:	0116bc23          	sd	a7,24(a3)
ffffffffc020177a:	41c8083b          	subw	a6,a6,t3
ffffffffc020177e:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201782:	5775                	li	a4,-3
ffffffffc0201784:	17c1                	addi	a5,a5,-16
ffffffffc0201786:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020178a:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020178c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020178e:	00001697          	auipc	a3,0x1
ffffffffc0201792:	21a68693          	addi	a3,a3,538 # ffffffffc02029a8 <commands+0x8c0>
ffffffffc0201796:	00001617          	auipc	a2,0x1
ffffffffc020179a:	eba60613          	addi	a2,a2,-326 # ffffffffc0202650 <commands+0x568>
ffffffffc020179e:	06200593          	li	a1,98
ffffffffc02017a2:	00001517          	auipc	a0,0x1
ffffffffc02017a6:	ec650513          	addi	a0,a0,-314 # ffffffffc0202668 <commands+0x580>
default_alloc_pages(size_t n) {
ffffffffc02017aa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017ac:	9bbfe0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc02017b0 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02017b0:	1141                	addi	sp,sp,-16
ffffffffc02017b2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017b4:	c9e1                	beqz	a1,ffffffffc0201884 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02017b6:	00259693          	slli	a3,a1,0x2
ffffffffc02017ba:	96ae                	add	a3,a3,a1
ffffffffc02017bc:	068e                	slli	a3,a3,0x3
ffffffffc02017be:	96aa                	add	a3,a3,a0
ffffffffc02017c0:	87aa                	mv	a5,a0
ffffffffc02017c2:	00d50f63          	beq	a0,a3,ffffffffc02017e0 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02017c6:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02017c8:	8b05                	andi	a4,a4,1
ffffffffc02017ca:	cf49                	beqz	a4,ffffffffc0201864 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02017cc:	0007a823          	sw	zero,16(a5)
ffffffffc02017d0:	0007b423          	sd	zero,8(a5)
ffffffffc02017d4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02017d8:	02878793          	addi	a5,a5,40
ffffffffc02017dc:	fed795e3          	bne	a5,a3,ffffffffc02017c6 <default_init_memmap+0x16>
    base->property = n;
ffffffffc02017e0:	2581                	sext.w	a1,a1
ffffffffc02017e2:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017e4:	4789                	li	a5,2
ffffffffc02017e6:	00850713          	addi	a4,a0,8
ffffffffc02017ea:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02017ee:	00005697          	auipc	a3,0x5
ffffffffc02017f2:	83a68693          	addi	a3,a3,-1990 # ffffffffc0206028 <free_area>
ffffffffc02017f6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02017f8:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02017fa:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02017fe:	9db9                	addw	a1,a1,a4
ffffffffc0201800:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201802:	04d78a63          	beq	a5,a3,ffffffffc0201856 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201806:	fe878713          	addi	a4,a5,-24
ffffffffc020180a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020180e:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201810:	00e56a63          	bltu	a0,a4,ffffffffc0201824 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0201814:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201816:	02d70263          	beq	a4,a3,ffffffffc020183a <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc020181a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020181c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201820:	fee57ae3          	bgeu	a0,a4,ffffffffc0201814 <default_init_memmap+0x64>
ffffffffc0201824:	c199                	beqz	a1,ffffffffc020182a <default_init_memmap+0x7a>
ffffffffc0201826:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020182a:	6398                	ld	a4,0(a5)
}
ffffffffc020182c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020182e:	e390                	sd	a2,0(a5)
ffffffffc0201830:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201832:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201834:	ed18                	sd	a4,24(a0)
ffffffffc0201836:	0141                	addi	sp,sp,16
ffffffffc0201838:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020183a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020183c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020183e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201840:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201842:	00d70663          	beq	a4,a3,ffffffffc020184e <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0201846:	8832                	mv	a6,a2
ffffffffc0201848:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020184a:	87ba                	mv	a5,a4
ffffffffc020184c:	bfc1                	j	ffffffffc020181c <default_init_memmap+0x6c>
}
ffffffffc020184e:	60a2                	ld	ra,8(sp)
ffffffffc0201850:	e290                	sd	a2,0(a3)
ffffffffc0201852:	0141                	addi	sp,sp,16
ffffffffc0201854:	8082                	ret
ffffffffc0201856:	60a2                	ld	ra,8(sp)
ffffffffc0201858:	e390                	sd	a2,0(a5)
ffffffffc020185a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020185c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020185e:	ed1c                	sd	a5,24(a0)
ffffffffc0201860:	0141                	addi	sp,sp,16
ffffffffc0201862:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201864:	00001697          	auipc	a3,0x1
ffffffffc0201868:	17468693          	addi	a3,a3,372 # ffffffffc02029d8 <commands+0x8f0>
ffffffffc020186c:	00001617          	auipc	a2,0x1
ffffffffc0201870:	de460613          	addi	a2,a2,-540 # ffffffffc0202650 <commands+0x568>
ffffffffc0201874:	04900593          	li	a1,73
ffffffffc0201878:	00001517          	auipc	a0,0x1
ffffffffc020187c:	df050513          	addi	a0,a0,-528 # ffffffffc0202668 <commands+0x580>
ffffffffc0201880:	8e7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(n > 0);
ffffffffc0201884:	00001697          	auipc	a3,0x1
ffffffffc0201888:	12468693          	addi	a3,a3,292 # ffffffffc02029a8 <commands+0x8c0>
ffffffffc020188c:	00001617          	auipc	a2,0x1
ffffffffc0201890:	dc460613          	addi	a2,a2,-572 # ffffffffc0202650 <commands+0x568>
ffffffffc0201894:	04600593          	li	a1,70
ffffffffc0201898:	00001517          	auipc	a0,0x1
ffffffffc020189c:	dd050513          	addi	a0,a0,-560 # ffffffffc0202668 <commands+0x580>
ffffffffc02018a0:	8c7fe0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc02018a4 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02018a4:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02018a8:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02018aa:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02018ac:	cb81                	beqz	a5,ffffffffc02018bc <strlen+0x18>
        cnt ++;
ffffffffc02018ae:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02018b0:	00a707b3          	add	a5,a4,a0
ffffffffc02018b4:	0007c783          	lbu	a5,0(a5)
ffffffffc02018b8:	fbfd                	bnez	a5,ffffffffc02018ae <strlen+0xa>
ffffffffc02018ba:	8082                	ret
    }
    return cnt;
}
ffffffffc02018bc:	8082                	ret

ffffffffc02018be <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02018be:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02018c0:	e589                	bnez	a1,ffffffffc02018ca <strnlen+0xc>
ffffffffc02018c2:	a811                	j	ffffffffc02018d6 <strnlen+0x18>
        cnt ++;
ffffffffc02018c4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02018c6:	00f58863          	beq	a1,a5,ffffffffc02018d6 <strnlen+0x18>
ffffffffc02018ca:	00f50733          	add	a4,a0,a5
ffffffffc02018ce:	00074703          	lbu	a4,0(a4)
ffffffffc02018d2:	fb6d                	bnez	a4,ffffffffc02018c4 <strnlen+0x6>
ffffffffc02018d4:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02018d6:	852e                	mv	a0,a1
ffffffffc02018d8:	8082                	ret

ffffffffc02018da <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02018da:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02018de:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02018e2:	cb89                	beqz	a5,ffffffffc02018f4 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02018e4:	0505                	addi	a0,a0,1
ffffffffc02018e6:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02018e8:	fee789e3          	beq	a5,a4,ffffffffc02018da <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02018ec:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02018f0:	9d19                	subw	a0,a0,a4
ffffffffc02018f2:	8082                	ret
ffffffffc02018f4:	4501                	li	a0,0
ffffffffc02018f6:	bfed                	j	ffffffffc02018f0 <strcmp+0x16>

ffffffffc02018f8 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02018f8:	c20d                	beqz	a2,ffffffffc020191a <strncmp+0x22>
ffffffffc02018fa:	962e                	add	a2,a2,a1
ffffffffc02018fc:	a031                	j	ffffffffc0201908 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc02018fe:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201900:	00e79a63          	bne	a5,a4,ffffffffc0201914 <strncmp+0x1c>
ffffffffc0201904:	00b60b63          	beq	a2,a1,ffffffffc020191a <strncmp+0x22>
ffffffffc0201908:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc020190c:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020190e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201912:	f7f5                	bnez	a5,ffffffffc02018fe <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201914:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201918:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020191a:	4501                	li	a0,0
ffffffffc020191c:	8082                	ret

ffffffffc020191e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020191e:	00054783          	lbu	a5,0(a0)
ffffffffc0201922:	c799                	beqz	a5,ffffffffc0201930 <strchr+0x12>
        if (*s == c) {
ffffffffc0201924:	00f58763          	beq	a1,a5,ffffffffc0201932 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201928:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020192c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020192e:	fbfd                	bnez	a5,ffffffffc0201924 <strchr+0x6>
    }
    return NULL;
ffffffffc0201930:	4501                	li	a0,0
}
ffffffffc0201932:	8082                	ret

ffffffffc0201934 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201934:	ca01                	beqz	a2,ffffffffc0201944 <memset+0x10>
ffffffffc0201936:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201938:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020193a:	0785                	addi	a5,a5,1
ffffffffc020193c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201940:	fec79de3          	bne	a5,a2,ffffffffc020193a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201944:	8082                	ret

ffffffffc0201946 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0201946:	ca19                	beqz	a2,ffffffffc020195c <memcpy+0x16>
ffffffffc0201948:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020194a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020194c:	0005c703          	lbu	a4,0(a1)
ffffffffc0201950:	0585                	addi	a1,a1,1
ffffffffc0201952:	0785                	addi	a5,a5,1
ffffffffc0201954:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0201958:	fec59ae3          	bne	a1,a2,ffffffffc020194c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020195c:	8082                	ret

ffffffffc020195e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020195e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201962:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201964:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201968:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020196a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020196e:	f022                	sd	s0,32(sp)
ffffffffc0201970:	ec26                	sd	s1,24(sp)
ffffffffc0201972:	e84a                	sd	s2,16(sp)
ffffffffc0201974:	f406                	sd	ra,40(sp)
ffffffffc0201976:	e44e                	sd	s3,8(sp)
ffffffffc0201978:	84aa                	mv	s1,a0
ffffffffc020197a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020197c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201980:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201982:	03067e63          	bgeu	a2,a6,ffffffffc02019be <printnum+0x60>
ffffffffc0201986:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201988:	00805763          	blez	s0,ffffffffc0201996 <printnum+0x38>
ffffffffc020198c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020198e:	85ca                	mv	a1,s2
ffffffffc0201990:	854e                	mv	a0,s3
ffffffffc0201992:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201994:	fc65                	bnez	s0,ffffffffc020198c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201996:	1a02                	slli	s4,s4,0x20
ffffffffc0201998:	00001797          	auipc	a5,0x1
ffffffffc020199c:	0a078793          	addi	a5,a5,160 # ffffffffc0202a38 <default_pmm_manager+0x38>
ffffffffc02019a0:	020a5a13          	srli	s4,s4,0x20
ffffffffc02019a4:	9a3e                	add	s4,s4,a5
}
ffffffffc02019a6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019a8:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02019ac:	70a2                	ld	ra,40(sp)
ffffffffc02019ae:	69a2                	ld	s3,8(sp)
ffffffffc02019b0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019b2:	85ca                	mv	a1,s2
ffffffffc02019b4:	87a6                	mv	a5,s1
}
ffffffffc02019b6:	6942                	ld	s2,16(sp)
ffffffffc02019b8:	64e2                	ld	s1,24(sp)
ffffffffc02019ba:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019bc:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02019be:	03065633          	divu	a2,a2,a6
ffffffffc02019c2:	8722                	mv	a4,s0
ffffffffc02019c4:	f9bff0ef          	jal	ra,ffffffffc020195e <printnum>
ffffffffc02019c8:	b7f9                	j	ffffffffc0201996 <printnum+0x38>

ffffffffc02019ca <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02019ca:	7119                	addi	sp,sp,-128
ffffffffc02019cc:	f4a6                	sd	s1,104(sp)
ffffffffc02019ce:	f0ca                	sd	s2,96(sp)
ffffffffc02019d0:	ecce                	sd	s3,88(sp)
ffffffffc02019d2:	e8d2                	sd	s4,80(sp)
ffffffffc02019d4:	e4d6                	sd	s5,72(sp)
ffffffffc02019d6:	e0da                	sd	s6,64(sp)
ffffffffc02019d8:	fc5e                	sd	s7,56(sp)
ffffffffc02019da:	f06a                	sd	s10,32(sp)
ffffffffc02019dc:	fc86                	sd	ra,120(sp)
ffffffffc02019de:	f8a2                	sd	s0,112(sp)
ffffffffc02019e0:	f862                	sd	s8,48(sp)
ffffffffc02019e2:	f466                	sd	s9,40(sp)
ffffffffc02019e4:	ec6e                	sd	s11,24(sp)
ffffffffc02019e6:	892a                	mv	s2,a0
ffffffffc02019e8:	84ae                	mv	s1,a1
ffffffffc02019ea:	8d32                	mv	s10,a2
ffffffffc02019ec:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02019ee:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02019f2:	5b7d                	li	s6,-1
ffffffffc02019f4:	00001a97          	auipc	s5,0x1
ffffffffc02019f8:	078a8a93          	addi	s5,s5,120 # ffffffffc0202a6c <default_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02019fc:	00001b97          	auipc	s7,0x1
ffffffffc0201a00:	24cb8b93          	addi	s7,s7,588 # ffffffffc0202c48 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a04:	000d4503          	lbu	a0,0(s10)
ffffffffc0201a08:	001d0413          	addi	s0,s10,1
ffffffffc0201a0c:	01350a63          	beq	a0,s3,ffffffffc0201a20 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201a10:	c121                	beqz	a0,ffffffffc0201a50 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201a12:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a14:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201a16:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a18:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201a1c:	ff351ae3          	bne	a0,s3,ffffffffc0201a10 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a20:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201a24:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201a28:	4c81                	li	s9,0
ffffffffc0201a2a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201a2c:	5c7d                	li	s8,-1
ffffffffc0201a2e:	5dfd                	li	s11,-1
ffffffffc0201a30:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201a34:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a36:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201a3a:	0ff5f593          	zext.b	a1,a1
ffffffffc0201a3e:	00140d13          	addi	s10,s0,1
ffffffffc0201a42:	04b56263          	bltu	a0,a1,ffffffffc0201a86 <vprintfmt+0xbc>
ffffffffc0201a46:	058a                	slli	a1,a1,0x2
ffffffffc0201a48:	95d6                	add	a1,a1,s5
ffffffffc0201a4a:	4194                	lw	a3,0(a1)
ffffffffc0201a4c:	96d6                	add	a3,a3,s5
ffffffffc0201a4e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201a50:	70e6                	ld	ra,120(sp)
ffffffffc0201a52:	7446                	ld	s0,112(sp)
ffffffffc0201a54:	74a6                	ld	s1,104(sp)
ffffffffc0201a56:	7906                	ld	s2,96(sp)
ffffffffc0201a58:	69e6                	ld	s3,88(sp)
ffffffffc0201a5a:	6a46                	ld	s4,80(sp)
ffffffffc0201a5c:	6aa6                	ld	s5,72(sp)
ffffffffc0201a5e:	6b06                	ld	s6,64(sp)
ffffffffc0201a60:	7be2                	ld	s7,56(sp)
ffffffffc0201a62:	7c42                	ld	s8,48(sp)
ffffffffc0201a64:	7ca2                	ld	s9,40(sp)
ffffffffc0201a66:	7d02                	ld	s10,32(sp)
ffffffffc0201a68:	6de2                	ld	s11,24(sp)
ffffffffc0201a6a:	6109                	addi	sp,sp,128
ffffffffc0201a6c:	8082                	ret
            padc = '0';
ffffffffc0201a6e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201a70:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a74:	846a                	mv	s0,s10
ffffffffc0201a76:	00140d13          	addi	s10,s0,1
ffffffffc0201a7a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201a7e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201a82:	fcb572e3          	bgeu	a0,a1,ffffffffc0201a46 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201a86:	85a6                	mv	a1,s1
ffffffffc0201a88:	02500513          	li	a0,37
ffffffffc0201a8c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201a8e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201a92:	8d22                	mv	s10,s0
ffffffffc0201a94:	f73788e3          	beq	a5,s3,ffffffffc0201a04 <vprintfmt+0x3a>
ffffffffc0201a98:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201a9c:	1d7d                	addi	s10,s10,-1
ffffffffc0201a9e:	ff379de3          	bne	a5,s3,ffffffffc0201a98 <vprintfmt+0xce>
ffffffffc0201aa2:	b78d                	j	ffffffffc0201a04 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201aa4:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201aa8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201aac:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201aae:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201ab2:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201ab6:	02d86463          	bltu	a6,a3,ffffffffc0201ade <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201aba:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201abe:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201ac2:	0186873b          	addw	a4,a3,s8
ffffffffc0201ac6:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201aca:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201acc:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201ad0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201ad2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201ad6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201ada:	fed870e3          	bgeu	a6,a3,ffffffffc0201aba <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201ade:	f40ddce3          	bgez	s11,ffffffffc0201a36 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201ae2:	8de2                	mv	s11,s8
ffffffffc0201ae4:	5c7d                	li	s8,-1
ffffffffc0201ae6:	bf81                	j	ffffffffc0201a36 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201ae8:	fffdc693          	not	a3,s11
ffffffffc0201aec:	96fd                	srai	a3,a3,0x3f
ffffffffc0201aee:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201af2:	00144603          	lbu	a2,1(s0)
ffffffffc0201af6:	2d81                	sext.w	s11,s11
ffffffffc0201af8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201afa:	bf35                	j	ffffffffc0201a36 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201afc:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b00:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201b04:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b06:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201b08:	bfd9                	j	ffffffffc0201ade <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201b0a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b0c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b10:	01174463          	blt	a4,a7,ffffffffc0201b18 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201b14:	1a088e63          	beqz	a7,ffffffffc0201cd0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201b18:	000a3603          	ld	a2,0(s4)
ffffffffc0201b1c:	46c1                	li	a3,16
ffffffffc0201b1e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201b20:	2781                	sext.w	a5,a5
ffffffffc0201b22:	876e                	mv	a4,s11
ffffffffc0201b24:	85a6                	mv	a1,s1
ffffffffc0201b26:	854a                	mv	a0,s2
ffffffffc0201b28:	e37ff0ef          	jal	ra,ffffffffc020195e <printnum>
            break;
ffffffffc0201b2c:	bde1                	j	ffffffffc0201a04 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201b2e:	000a2503          	lw	a0,0(s4)
ffffffffc0201b32:	85a6                	mv	a1,s1
ffffffffc0201b34:	0a21                	addi	s4,s4,8
ffffffffc0201b36:	9902                	jalr	s2
            break;
ffffffffc0201b38:	b5f1                	j	ffffffffc0201a04 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201b3a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b3c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b40:	01174463          	blt	a4,a7,ffffffffc0201b48 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201b44:	18088163          	beqz	a7,ffffffffc0201cc6 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201b48:	000a3603          	ld	a2,0(s4)
ffffffffc0201b4c:	46a9                	li	a3,10
ffffffffc0201b4e:	8a2e                	mv	s4,a1
ffffffffc0201b50:	bfc1                	j	ffffffffc0201b20 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b52:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201b56:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b58:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b5a:	bdf1                	j	ffffffffc0201a36 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201b5c:	85a6                	mv	a1,s1
ffffffffc0201b5e:	02500513          	li	a0,37
ffffffffc0201b62:	9902                	jalr	s2
            break;
ffffffffc0201b64:	b545                	j	ffffffffc0201a04 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b66:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201b6a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b6c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b6e:	b5e1                	j	ffffffffc0201a36 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201b70:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b72:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b76:	01174463          	blt	a4,a7,ffffffffc0201b7e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201b7a:	14088163          	beqz	a7,ffffffffc0201cbc <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201b7e:	000a3603          	ld	a2,0(s4)
ffffffffc0201b82:	46a1                	li	a3,8
ffffffffc0201b84:	8a2e                	mv	s4,a1
ffffffffc0201b86:	bf69                	j	ffffffffc0201b20 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201b88:	03000513          	li	a0,48
ffffffffc0201b8c:	85a6                	mv	a1,s1
ffffffffc0201b8e:	e03e                	sd	a5,0(sp)
ffffffffc0201b90:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201b92:	85a6                	mv	a1,s1
ffffffffc0201b94:	07800513          	li	a0,120
ffffffffc0201b98:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201b9a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201b9c:	6782                	ld	a5,0(sp)
ffffffffc0201b9e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201ba0:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201ba4:	bfb5                	j	ffffffffc0201b20 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201ba6:	000a3403          	ld	s0,0(s4)
ffffffffc0201baa:	008a0713          	addi	a4,s4,8
ffffffffc0201bae:	e03a                	sd	a4,0(sp)
ffffffffc0201bb0:	14040263          	beqz	s0,ffffffffc0201cf4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201bb4:	0fb05763          	blez	s11,ffffffffc0201ca2 <vprintfmt+0x2d8>
ffffffffc0201bb8:	02d00693          	li	a3,45
ffffffffc0201bbc:	0cd79163          	bne	a5,a3,ffffffffc0201c7e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bc0:	00044783          	lbu	a5,0(s0)
ffffffffc0201bc4:	0007851b          	sext.w	a0,a5
ffffffffc0201bc8:	cf85                	beqz	a5,ffffffffc0201c00 <vprintfmt+0x236>
ffffffffc0201bca:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201bce:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bd2:	000c4563          	bltz	s8,ffffffffc0201bdc <vprintfmt+0x212>
ffffffffc0201bd6:	3c7d                	addiw	s8,s8,-1
ffffffffc0201bd8:	036c0263          	beq	s8,s6,ffffffffc0201bfc <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201bdc:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201bde:	0e0c8e63          	beqz	s9,ffffffffc0201cda <vprintfmt+0x310>
ffffffffc0201be2:	3781                	addiw	a5,a5,-32
ffffffffc0201be4:	0ef47b63          	bgeu	s0,a5,ffffffffc0201cda <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201be8:	03f00513          	li	a0,63
ffffffffc0201bec:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bee:	000a4783          	lbu	a5,0(s4)
ffffffffc0201bf2:	3dfd                	addiw	s11,s11,-1
ffffffffc0201bf4:	0a05                	addi	s4,s4,1
ffffffffc0201bf6:	0007851b          	sext.w	a0,a5
ffffffffc0201bfa:	ffe1                	bnez	a5,ffffffffc0201bd2 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201bfc:	01b05963          	blez	s11,ffffffffc0201c0e <vprintfmt+0x244>
ffffffffc0201c00:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201c02:	85a6                	mv	a1,s1
ffffffffc0201c04:	02000513          	li	a0,32
ffffffffc0201c08:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201c0a:	fe0d9be3          	bnez	s11,ffffffffc0201c00 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201c0e:	6a02                	ld	s4,0(sp)
ffffffffc0201c10:	bbd5                	j	ffffffffc0201a04 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201c12:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c14:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201c18:	01174463          	blt	a4,a7,ffffffffc0201c20 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201c1c:	08088d63          	beqz	a7,ffffffffc0201cb6 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201c20:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201c24:	0a044d63          	bltz	s0,ffffffffc0201cde <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201c28:	8622                	mv	a2,s0
ffffffffc0201c2a:	8a66                	mv	s4,s9
ffffffffc0201c2c:	46a9                	li	a3,10
ffffffffc0201c2e:	bdcd                	j	ffffffffc0201b20 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201c30:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201c34:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201c36:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201c38:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201c3c:	8fb5                	xor	a5,a5,a3
ffffffffc0201c3e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201c42:	02d74163          	blt	a4,a3,ffffffffc0201c64 <vprintfmt+0x29a>
ffffffffc0201c46:	00369793          	slli	a5,a3,0x3
ffffffffc0201c4a:	97de                	add	a5,a5,s7
ffffffffc0201c4c:	639c                	ld	a5,0(a5)
ffffffffc0201c4e:	cb99                	beqz	a5,ffffffffc0201c64 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201c50:	86be                	mv	a3,a5
ffffffffc0201c52:	00001617          	auipc	a2,0x1
ffffffffc0201c56:	e1660613          	addi	a2,a2,-490 # ffffffffc0202a68 <default_pmm_manager+0x68>
ffffffffc0201c5a:	85a6                	mv	a1,s1
ffffffffc0201c5c:	854a                	mv	a0,s2
ffffffffc0201c5e:	0ce000ef          	jal	ra,ffffffffc0201d2c <printfmt>
ffffffffc0201c62:	b34d                	j	ffffffffc0201a04 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201c64:	00001617          	auipc	a2,0x1
ffffffffc0201c68:	df460613          	addi	a2,a2,-524 # ffffffffc0202a58 <default_pmm_manager+0x58>
ffffffffc0201c6c:	85a6                	mv	a1,s1
ffffffffc0201c6e:	854a                	mv	a0,s2
ffffffffc0201c70:	0bc000ef          	jal	ra,ffffffffc0201d2c <printfmt>
ffffffffc0201c74:	bb41                	j	ffffffffc0201a04 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201c76:	00001417          	auipc	s0,0x1
ffffffffc0201c7a:	dda40413          	addi	s0,s0,-550 # ffffffffc0202a50 <default_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201c7e:	85e2                	mv	a1,s8
ffffffffc0201c80:	8522                	mv	a0,s0
ffffffffc0201c82:	e43e                	sd	a5,8(sp)
ffffffffc0201c84:	c3bff0ef          	jal	ra,ffffffffc02018be <strnlen>
ffffffffc0201c88:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201c8c:	01b05b63          	blez	s11,ffffffffc0201ca2 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201c90:	67a2                	ld	a5,8(sp)
ffffffffc0201c92:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201c96:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201c98:	85a6                	mv	a1,s1
ffffffffc0201c9a:	8552                	mv	a0,s4
ffffffffc0201c9c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201c9e:	fe0d9ce3          	bnez	s11,ffffffffc0201c96 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201ca2:	00044783          	lbu	a5,0(s0)
ffffffffc0201ca6:	00140a13          	addi	s4,s0,1
ffffffffc0201caa:	0007851b          	sext.w	a0,a5
ffffffffc0201cae:	d3a5                	beqz	a5,ffffffffc0201c0e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201cb0:	05e00413          	li	s0,94
ffffffffc0201cb4:	bf39                	j	ffffffffc0201bd2 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201cb6:	000a2403          	lw	s0,0(s4)
ffffffffc0201cba:	b7ad                	j	ffffffffc0201c24 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201cbc:	000a6603          	lwu	a2,0(s4)
ffffffffc0201cc0:	46a1                	li	a3,8
ffffffffc0201cc2:	8a2e                	mv	s4,a1
ffffffffc0201cc4:	bdb1                	j	ffffffffc0201b20 <vprintfmt+0x156>
ffffffffc0201cc6:	000a6603          	lwu	a2,0(s4)
ffffffffc0201cca:	46a9                	li	a3,10
ffffffffc0201ccc:	8a2e                	mv	s4,a1
ffffffffc0201cce:	bd89                	j	ffffffffc0201b20 <vprintfmt+0x156>
ffffffffc0201cd0:	000a6603          	lwu	a2,0(s4)
ffffffffc0201cd4:	46c1                	li	a3,16
ffffffffc0201cd6:	8a2e                	mv	s4,a1
ffffffffc0201cd8:	b5a1                	j	ffffffffc0201b20 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201cda:	9902                	jalr	s2
ffffffffc0201cdc:	bf09                	j	ffffffffc0201bee <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201cde:	85a6                	mv	a1,s1
ffffffffc0201ce0:	02d00513          	li	a0,45
ffffffffc0201ce4:	e03e                	sd	a5,0(sp)
ffffffffc0201ce6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201ce8:	6782                	ld	a5,0(sp)
ffffffffc0201cea:	8a66                	mv	s4,s9
ffffffffc0201cec:	40800633          	neg	a2,s0
ffffffffc0201cf0:	46a9                	li	a3,10
ffffffffc0201cf2:	b53d                	j	ffffffffc0201b20 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201cf4:	03b05163          	blez	s11,ffffffffc0201d16 <vprintfmt+0x34c>
ffffffffc0201cf8:	02d00693          	li	a3,45
ffffffffc0201cfc:	f6d79de3          	bne	a5,a3,ffffffffc0201c76 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201d00:	00001417          	auipc	s0,0x1
ffffffffc0201d04:	d5040413          	addi	s0,s0,-688 # ffffffffc0202a50 <default_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d08:	02800793          	li	a5,40
ffffffffc0201d0c:	02800513          	li	a0,40
ffffffffc0201d10:	00140a13          	addi	s4,s0,1
ffffffffc0201d14:	bd6d                	j	ffffffffc0201bce <vprintfmt+0x204>
ffffffffc0201d16:	00001a17          	auipc	s4,0x1
ffffffffc0201d1a:	d3ba0a13          	addi	s4,s4,-709 # ffffffffc0202a51 <default_pmm_manager+0x51>
ffffffffc0201d1e:	02800513          	li	a0,40
ffffffffc0201d22:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201d26:	05e00413          	li	s0,94
ffffffffc0201d2a:	b565                	j	ffffffffc0201bd2 <vprintfmt+0x208>

ffffffffc0201d2c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d2c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201d2e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d32:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201d34:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d36:	ec06                	sd	ra,24(sp)
ffffffffc0201d38:	f83a                	sd	a4,48(sp)
ffffffffc0201d3a:	fc3e                	sd	a5,56(sp)
ffffffffc0201d3c:	e0c2                	sd	a6,64(sp)
ffffffffc0201d3e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201d40:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201d42:	c89ff0ef          	jal	ra,ffffffffc02019ca <vprintfmt>
}
ffffffffc0201d46:	60e2                	ld	ra,24(sp)
ffffffffc0201d48:	6161                	addi	sp,sp,80
ffffffffc0201d4a:	8082                	ret

ffffffffc0201d4c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201d4c:	715d                	addi	sp,sp,-80
ffffffffc0201d4e:	e486                	sd	ra,72(sp)
ffffffffc0201d50:	e0a6                	sd	s1,64(sp)
ffffffffc0201d52:	fc4a                	sd	s2,56(sp)
ffffffffc0201d54:	f84e                	sd	s3,48(sp)
ffffffffc0201d56:	f452                	sd	s4,40(sp)
ffffffffc0201d58:	f056                	sd	s5,32(sp)
ffffffffc0201d5a:	ec5a                	sd	s6,24(sp)
ffffffffc0201d5c:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201d5e:	c901                	beqz	a0,ffffffffc0201d6e <readline+0x22>
ffffffffc0201d60:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201d62:	00001517          	auipc	a0,0x1
ffffffffc0201d66:	d0650513          	addi	a0,a0,-762 # ffffffffc0202a68 <default_pmm_manager+0x68>
ffffffffc0201d6a:	b74fe0ef          	jal	ra,ffffffffc02000de <cprintf>
readline(const char *prompt) {
ffffffffc0201d6e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201d70:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201d72:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201d74:	4aa9                	li	s5,10
ffffffffc0201d76:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201d78:	00004b97          	auipc	s7,0x4
ffffffffc0201d7c:	2c8b8b93          	addi	s7,s7,712 # ffffffffc0206040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201d80:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201d84:	bd2fe0ef          	jal	ra,ffffffffc0200156 <getchar>
        if (c < 0) {
ffffffffc0201d88:	00054a63          	bltz	a0,ffffffffc0201d9c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201d8c:	00a95a63          	bge	s2,a0,ffffffffc0201da0 <readline+0x54>
ffffffffc0201d90:	029a5263          	bge	s4,s1,ffffffffc0201db4 <readline+0x68>
        c = getchar();
ffffffffc0201d94:	bc2fe0ef          	jal	ra,ffffffffc0200156 <getchar>
        if (c < 0) {
ffffffffc0201d98:	fe055ae3          	bgez	a0,ffffffffc0201d8c <readline+0x40>
            return NULL;
ffffffffc0201d9c:	4501                	li	a0,0
ffffffffc0201d9e:	a091                	j	ffffffffc0201de2 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201da0:	03351463          	bne	a0,s3,ffffffffc0201dc8 <readline+0x7c>
ffffffffc0201da4:	e8a9                	bnez	s1,ffffffffc0201df6 <readline+0xaa>
        c = getchar();
ffffffffc0201da6:	bb0fe0ef          	jal	ra,ffffffffc0200156 <getchar>
        if (c < 0) {
ffffffffc0201daa:	fe0549e3          	bltz	a0,ffffffffc0201d9c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201dae:	fea959e3          	bge	s2,a0,ffffffffc0201da0 <readline+0x54>
ffffffffc0201db2:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201db4:	e42a                	sd	a0,8(sp)
ffffffffc0201db6:	b5efe0ef          	jal	ra,ffffffffc0200114 <cputchar>
            buf[i ++] = c;
ffffffffc0201dba:	6522                	ld	a0,8(sp)
ffffffffc0201dbc:	009b87b3          	add	a5,s7,s1
ffffffffc0201dc0:	2485                	addiw	s1,s1,1
ffffffffc0201dc2:	00a78023          	sb	a0,0(a5)
ffffffffc0201dc6:	bf7d                	j	ffffffffc0201d84 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201dc8:	01550463          	beq	a0,s5,ffffffffc0201dd0 <readline+0x84>
ffffffffc0201dcc:	fb651ce3          	bne	a0,s6,ffffffffc0201d84 <readline+0x38>
            cputchar(c);
ffffffffc0201dd0:	b44fe0ef          	jal	ra,ffffffffc0200114 <cputchar>
            buf[i] = '\0';
ffffffffc0201dd4:	00004517          	auipc	a0,0x4
ffffffffc0201dd8:	26c50513          	addi	a0,a0,620 # ffffffffc0206040 <buf>
ffffffffc0201ddc:	94aa                	add	s1,s1,a0
ffffffffc0201dde:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201de2:	60a6                	ld	ra,72(sp)
ffffffffc0201de4:	6486                	ld	s1,64(sp)
ffffffffc0201de6:	7962                	ld	s2,56(sp)
ffffffffc0201de8:	79c2                	ld	s3,48(sp)
ffffffffc0201dea:	7a22                	ld	s4,40(sp)
ffffffffc0201dec:	7a82                	ld	s5,32(sp)
ffffffffc0201dee:	6b62                	ld	s6,24(sp)
ffffffffc0201df0:	6bc2                	ld	s7,16(sp)
ffffffffc0201df2:	6161                	addi	sp,sp,80
ffffffffc0201df4:	8082                	ret
            cputchar(c);
ffffffffc0201df6:	4521                	li	a0,8
ffffffffc0201df8:	b1cfe0ef          	jal	ra,ffffffffc0200114 <cputchar>
            i --;
ffffffffc0201dfc:	34fd                	addiw	s1,s1,-1
ffffffffc0201dfe:	b759                	j	ffffffffc0201d84 <readline+0x38>

ffffffffc0201e00 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201e00:	4781                	li	a5,0
ffffffffc0201e02:	00004717          	auipc	a4,0x4
ffffffffc0201e06:	21673703          	ld	a4,534(a4) # ffffffffc0206018 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201e0a:	88ba                	mv	a7,a4
ffffffffc0201e0c:	852a                	mv	a0,a0
ffffffffc0201e0e:	85be                	mv	a1,a5
ffffffffc0201e10:	863e                	mv	a2,a5
ffffffffc0201e12:	00000073          	ecall
ffffffffc0201e16:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201e18:	8082                	ret

ffffffffc0201e1a <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201e1a:	4781                	li	a5,0
ffffffffc0201e1c:	00004717          	auipc	a4,0x4
ffffffffc0201e20:	67c73703          	ld	a4,1660(a4) # ffffffffc0206498 <SBI_SET_TIMER>
ffffffffc0201e24:	88ba                	mv	a7,a4
ffffffffc0201e26:	852a                	mv	a0,a0
ffffffffc0201e28:	85be                	mv	a1,a5
ffffffffc0201e2a:	863e                	mv	a2,a5
ffffffffc0201e2c:	00000073          	ecall
ffffffffc0201e30:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201e32:	8082                	ret

ffffffffc0201e34 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201e34:	4501                	li	a0,0
ffffffffc0201e36:	00004797          	auipc	a5,0x4
ffffffffc0201e3a:	1da7b783          	ld	a5,474(a5) # ffffffffc0206010 <SBI_CONSOLE_GETCHAR>
ffffffffc0201e3e:	88be                	mv	a7,a5
ffffffffc0201e40:	852a                	mv	a0,a0
ffffffffc0201e42:	85aa                	mv	a1,a0
ffffffffc0201e44:	862a                	mv	a2,a0
ffffffffc0201e46:	00000073          	ecall
ffffffffc0201e4a:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201e4c:	2501                	sext.w	a0,a0
ffffffffc0201e4e:	8082                	ret

ffffffffc0201e50 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201e50:	4781                	li	a5,0
ffffffffc0201e52:	00004717          	auipc	a4,0x4
ffffffffc0201e56:	1ce73703          	ld	a4,462(a4) # ffffffffc0206020 <SBI_SHUTDOWN>
ffffffffc0201e5a:	88ba                	mv	a7,a4
ffffffffc0201e5c:	853e                	mv	a0,a5
ffffffffc0201e5e:	85be                	mv	a1,a5
ffffffffc0201e60:	863e                	mv	a2,a5
ffffffffc0201e62:	00000073          	ecall
ffffffffc0201e66:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
	sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0201e68:	8082                	ret
