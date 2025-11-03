
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
ffffffffc020006c:	1f5010ef          	jal	ra,ffffffffc0201a60 <memset>
    dtb_init();
ffffffffc0200070:	3c4000ef          	jal	ra,ffffffffc0200434 <dtb_init>
    cons_init();  // init the console
ffffffffc0200074:	7b4000ef          	jal	ra,ffffffffc0200828 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200078:	00002517          	auipc	a0,0x2
ffffffffc020007c:	f2050513          	addi	a0,a0,-224 # ffffffffc0201f98 <etext+0x2>
ffffffffc0200080:	096000ef          	jal	ra,ffffffffc0200116 <cputs>

    print_kerninfo();
ffffffffc0200084:	13e000ef          	jal	ra,ffffffffc02001c2 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200088:	7ba000ef          	jal	ra,ffffffffc0200842 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020008c:	559000ef          	jal	ra,ffffffffc0200de4 <pmm_init>

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
ffffffffc02000d2:	225010ef          	jal	ra,ffffffffc0201af6 <vprintfmt>
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
ffffffffc02000e0:	02810313          	addi	t1,sp,40 # ffffffffc0206028 <boot_page_table_sv39+0x28>
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
ffffffffc0200108:	1ef010ef          	jal	ra,ffffffffc0201af6 <vprintfmt>
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
ffffffffc0200166:	00007317          	auipc	t1,0x7
ffffffffc020016a:	2da30313          	addi	t1,t1,730 # ffffffffc0207440 <is_panic>
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
ffffffffc0200198:	e2450513          	addi	a0,a0,-476 # ffffffffc0201fb8 <etext+0x22>
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
ffffffffc02001ae:	ef650513          	addi	a0,a0,-266 # ffffffffc02020a0 <etext+0x10a>
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
ffffffffc02001c8:	e1450513          	addi	a0,a0,-492 # ffffffffc0201fd8 <etext+0x42>
void print_kerninfo(void) {
ffffffffc02001cc:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001ce:	f11ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001d2:	00000597          	auipc	a1,0x0
ffffffffc02001d6:	e8258593          	addi	a1,a1,-382 # ffffffffc0200054 <kern_init>
ffffffffc02001da:	00002517          	auipc	a0,0x2
ffffffffc02001de:	e1e50513          	addi	a0,a0,-482 # ffffffffc0201ff8 <etext+0x62>
ffffffffc02001e2:	efdff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001e6:	00002597          	auipc	a1,0x2
ffffffffc02001ea:	db058593          	addi	a1,a1,-592 # ffffffffc0201f96 <etext>
ffffffffc02001ee:	00002517          	auipc	a0,0x2
ffffffffc02001f2:	e2a50513          	addi	a0,a0,-470 # ffffffffc0202018 <etext+0x82>
ffffffffc02001f6:	ee9ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001fa:	00007597          	auipc	a1,0x7
ffffffffc02001fe:	e2e58593          	addi	a1,a1,-466 # ffffffffc0207028 <free_area>
ffffffffc0200202:	00002517          	auipc	a0,0x2
ffffffffc0200206:	e3650513          	addi	a0,a0,-458 # ffffffffc0202038 <etext+0xa2>
ffffffffc020020a:	ed5ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020020e:	00007597          	auipc	a1,0x7
ffffffffc0200212:	29258593          	addi	a1,a1,658 # ffffffffc02074a0 <end>
ffffffffc0200216:	00002517          	auipc	a0,0x2
ffffffffc020021a:	e4250513          	addi	a0,a0,-446 # ffffffffc0202058 <etext+0xc2>
ffffffffc020021e:	ec1ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200222:	00007597          	auipc	a1,0x7
ffffffffc0200226:	67d58593          	addi	a1,a1,1661 # ffffffffc020789f <end+0x3ff>
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
ffffffffc0200248:	e3450513          	addi	a0,a0,-460 # ffffffffc0202078 <etext+0xe2>
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
ffffffffc0200256:	e5660613          	addi	a2,a2,-426 # ffffffffc02020a8 <etext+0x112>
ffffffffc020025a:	04d00593          	li	a1,77
ffffffffc020025e:	00002517          	auipc	a0,0x2
ffffffffc0200262:	e6250513          	addi	a0,a0,-414 # ffffffffc02020c0 <etext+0x12a>
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
ffffffffc0200272:	e6a60613          	addi	a2,a2,-406 # ffffffffc02020d8 <etext+0x142>
ffffffffc0200276:	00002597          	auipc	a1,0x2
ffffffffc020027a:	e8258593          	addi	a1,a1,-382 # ffffffffc02020f8 <etext+0x162>
ffffffffc020027e:	00002517          	auipc	a0,0x2
ffffffffc0200282:	e8250513          	addi	a0,a0,-382 # ffffffffc0202100 <etext+0x16a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200286:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200288:	e57ff0ef          	jal	ra,ffffffffc02000de <cprintf>
ffffffffc020028c:	00002617          	auipc	a2,0x2
ffffffffc0200290:	e8460613          	addi	a2,a2,-380 # ffffffffc0202110 <etext+0x17a>
ffffffffc0200294:	00002597          	auipc	a1,0x2
ffffffffc0200298:	ea458593          	addi	a1,a1,-348 # ffffffffc0202138 <etext+0x1a2>
ffffffffc020029c:	00002517          	auipc	a0,0x2
ffffffffc02002a0:	e6450513          	addi	a0,a0,-412 # ffffffffc0202100 <etext+0x16a>
ffffffffc02002a4:	e3bff0ef          	jal	ra,ffffffffc02000de <cprintf>
ffffffffc02002a8:	00002617          	auipc	a2,0x2
ffffffffc02002ac:	ea060613          	addi	a2,a2,-352 # ffffffffc0202148 <etext+0x1b2>
ffffffffc02002b0:	00002597          	auipc	a1,0x2
ffffffffc02002b4:	eb858593          	addi	a1,a1,-328 # ffffffffc0202168 <etext+0x1d2>
ffffffffc02002b8:	00002517          	auipc	a0,0x2
ffffffffc02002bc:	e4850513          	addi	a0,a0,-440 # ffffffffc0202100 <etext+0x16a>
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
ffffffffc02002f6:	e8650513          	addi	a0,a0,-378 # ffffffffc0202178 <etext+0x1e2>
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
ffffffffc0200318:	e8c50513          	addi	a0,a0,-372 # ffffffffc02021a0 <etext+0x20a>
ffffffffc020031c:	dc3ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    if (tf != NULL) {
ffffffffc0200320:	000b8563          	beqz	s7,ffffffffc020032a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200324:	855e                	mv	a0,s7
ffffffffc0200326:	6fc000ef          	jal	ra,ffffffffc0200a22 <print_trapframe>
ffffffffc020032a:	00002c17          	auipc	s8,0x2
ffffffffc020032e:	ee6c0c13          	addi	s8,s8,-282 # ffffffffc0202210 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200332:	00002917          	auipc	s2,0x2
ffffffffc0200336:	e9690913          	addi	s2,s2,-362 # ffffffffc02021c8 <etext+0x232>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020033a:	00002497          	auipc	s1,0x2
ffffffffc020033e:	e9648493          	addi	s1,s1,-362 # ffffffffc02021d0 <etext+0x23a>
        if (argc == MAXARGS - 1) {
ffffffffc0200342:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200344:	00002b17          	auipc	s6,0x2
ffffffffc0200348:	e94b0b13          	addi	s6,s6,-364 # ffffffffc02021d8 <etext+0x242>
        argv[argc ++] = buf;
ffffffffc020034c:	00002a17          	auipc	s4,0x2
ffffffffc0200350:	daca0a13          	addi	s4,s4,-596 # ffffffffc02020f8 <etext+0x162>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200354:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200356:	854a                	mv	a0,s2
ffffffffc0200358:	321010ef          	jal	ra,ffffffffc0201e78 <readline>
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
ffffffffc0200372:	ea2d0d13          	addi	s10,s10,-350 # ffffffffc0202210 <commands>
        argv[argc ++] = buf;
ffffffffc0200376:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200378:	4401                	li	s0,0
ffffffffc020037a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	68a010ef          	jal	ra,ffffffffc0201a06 <strcmp>
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
ffffffffc0200390:	676010ef          	jal	ra,ffffffffc0201a06 <strcmp>
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
ffffffffc02003ce:	67c010ef          	jal	ra,ffffffffc0201a4a <strchr>
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
ffffffffc020040c:	63e010ef          	jal	ra,ffffffffc0201a4a <strchr>
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
ffffffffc020042a:	dd250513          	addi	a0,a0,-558 # ffffffffc02021f8 <etext+0x262>
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
ffffffffc020043a:	e2250513          	addi	a0,a0,-478 # ffffffffc0202258 <commands+0x48>
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
ffffffffc020045c:	00007597          	auipc	a1,0x7
ffffffffc0200460:	ba45b583          	ld	a1,-1116(a1) # ffffffffc0207000 <boot_hartid>
ffffffffc0200464:	00002517          	auipc	a0,0x2
ffffffffc0200468:	e0450513          	addi	a0,a0,-508 # ffffffffc0202268 <commands+0x58>
ffffffffc020046c:	c73ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200470:	00007417          	auipc	s0,0x7
ffffffffc0200474:	b9840413          	addi	s0,s0,-1128 # ffffffffc0207008 <boot_dtb>
ffffffffc0200478:	600c                	ld	a1,0(s0)
ffffffffc020047a:	00002517          	auipc	a0,0x2
ffffffffc020047e:	dfe50513          	addi	a0,a0,-514 # ffffffffc0202278 <commands+0x68>
ffffffffc0200482:	c5dff0ef          	jal	ra,ffffffffc02000de <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200486:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020048a:	00002517          	auipc	a0,0x2
ffffffffc020048e:	e0650513          	addi	a0,a0,-506 # ffffffffc0202290 <commands+0x80>
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
ffffffffc02004d2:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed8a4d>
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
ffffffffc0200548:	d9c90913          	addi	s2,s2,-612 # ffffffffc02022e0 <commands+0xd0>
ffffffffc020054c:	49bd                	li	s3,15
        switch (token) {
ffffffffc020054e:	4d91                	li	s11,4
ffffffffc0200550:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200552:	00002497          	auipc	s1,0x2
ffffffffc0200556:	d8648493          	addi	s1,s1,-634 # ffffffffc02022d8 <commands+0xc8>
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
ffffffffc02005aa:	db250513          	addi	a0,a0,-590 # ffffffffc0202358 <commands+0x148>
ffffffffc02005ae:	b31ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02005b2:	00002517          	auipc	a0,0x2
ffffffffc02005b6:	dde50513          	addi	a0,a0,-546 # ffffffffc0202390 <commands+0x180>
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
ffffffffc02005f6:	cbe50513          	addi	a0,a0,-834 # ffffffffc02022b0 <commands+0xa0>
}
ffffffffc02005fa:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02005fc:	b4cd                	j	ffffffffc02000de <cprintf>
                int name_len = strlen(name);
ffffffffc02005fe:	8556                	mv	a0,s5
ffffffffc0200600:	3d0010ef          	jal	ra,ffffffffc02019d0 <strlen>
ffffffffc0200604:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200606:	4619                	li	a2,6
ffffffffc0200608:	85a6                	mv	a1,s1
ffffffffc020060a:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc020060c:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020060e:	416010ef          	jal	ra,ffffffffc0201a24 <strncmp>
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
ffffffffc02006a4:	362010ef          	jal	ra,ffffffffc0201a06 <strcmp>
ffffffffc02006a8:	66a2                	ld	a3,8(sp)
ffffffffc02006aa:	f94d                	bnez	a0,ffffffffc020065c <dtb_init+0x228>
ffffffffc02006ac:	fb59f8e3          	bgeu	s3,s5,ffffffffc020065c <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02006b0:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02006b4:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02006b8:	00002517          	auipc	a0,0x2
ffffffffc02006bc:	c3050513          	addi	a0,a0,-976 # ffffffffc02022e8 <commands+0xd8>
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
ffffffffc020078a:	b8250513          	addi	a0,a0,-1150 # ffffffffc0202308 <commands+0xf8>
ffffffffc020078e:	951ff0ef          	jal	ra,ffffffffc02000de <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200792:	014b5613          	srli	a2,s6,0x14
ffffffffc0200796:	85da                	mv	a1,s6
ffffffffc0200798:	00002517          	auipc	a0,0x2
ffffffffc020079c:	b8850513          	addi	a0,a0,-1144 # ffffffffc0202320 <commands+0x110>
ffffffffc02007a0:	93fff0ef          	jal	ra,ffffffffc02000de <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02007a4:	008b05b3          	add	a1,s6,s0
ffffffffc02007a8:	15fd                	addi	a1,a1,-1
ffffffffc02007aa:	00002517          	auipc	a0,0x2
ffffffffc02007ae:	b9650513          	addi	a0,a0,-1130 # ffffffffc0202340 <commands+0x130>
ffffffffc02007b2:	92dff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02007b6:	00002517          	auipc	a0,0x2
ffffffffc02007ba:	bda50513          	addi	a0,a0,-1062 # ffffffffc0202390 <commands+0x180>
        memory_base = mem_base;
ffffffffc02007be:	00007797          	auipc	a5,0x7
ffffffffc02007c2:	c887b523          	sd	s0,-886(a5) # ffffffffc0207448 <memory_base>
        memory_size = mem_size;
ffffffffc02007c6:	00007797          	auipc	a5,0x7
ffffffffc02007ca:	c967b523          	sd	s6,-886(a5) # ffffffffc0207450 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02007ce:	b3f5                	j	ffffffffc02005ba <dtb_init+0x186>

ffffffffc02007d0 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02007d0:	00007517          	auipc	a0,0x7
ffffffffc02007d4:	c7853503          	ld	a0,-904(a0) # ffffffffc0207448 <memory_base>
ffffffffc02007d8:	8082                	ret

ffffffffc02007da <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02007da:	00007517          	auipc	a0,0x7
ffffffffc02007de:	c7653503          	ld	a0,-906(a0) # ffffffffc0207450 <memory_size>
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
ffffffffc02007fc:	74a010ef          	jal	ra,ffffffffc0201f46 <sbi_set_timer>
}
ffffffffc0200800:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200802:	00007797          	auipc	a5,0x7
ffffffffc0200806:	c407bb23          	sd	zero,-938(a5) # ffffffffc0207458 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020080a:	00002517          	auipc	a0,0x2
ffffffffc020080e:	b9e50513          	addi	a0,a0,-1122 # ffffffffc02023a8 <commands+0x198>
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
ffffffffc0200824:	7220106f          	j	ffffffffc0201f46 <sbi_set_timer>

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
ffffffffc020082e:	6fe0106f          	j	ffffffffc0201f2c <sbi_console_putchar>

ffffffffc0200832 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200832:	72e0106f          	j	ffffffffc0201f60 <sbi_console_getchar>

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
ffffffffc020084a:	43278793          	addi	a5,a5,1074 # ffffffffc0200c78 <__alltraps>
ffffffffc020084e:	10579073          	csrw	stvec,a5
}
ffffffffc0200852:	8082                	ret

ffffffffc0200854 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200854:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200856:	1141                	addi	sp,sp,-16
ffffffffc0200858:	e022                	sd	s0,0(sp)
ffffffffc020085a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020085c:	00002517          	auipc	a0,0x2
ffffffffc0200860:	b6c50513          	addi	a0,a0,-1172 # ffffffffc02023c8 <commands+0x1b8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200864:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200866:	879ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020086a:	640c                	ld	a1,8(s0)
ffffffffc020086c:	00002517          	auipc	a0,0x2
ffffffffc0200870:	b7450513          	addi	a0,a0,-1164 # ffffffffc02023e0 <commands+0x1d0>
ffffffffc0200874:	86bff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200878:	680c                	ld	a1,16(s0)
ffffffffc020087a:	00002517          	auipc	a0,0x2
ffffffffc020087e:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02023f8 <commands+0x1e8>
ffffffffc0200882:	85dff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200886:	6c0c                	ld	a1,24(s0)
ffffffffc0200888:	00002517          	auipc	a0,0x2
ffffffffc020088c:	b8850513          	addi	a0,a0,-1144 # ffffffffc0202410 <commands+0x200>
ffffffffc0200890:	84fff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200894:	700c                	ld	a1,32(s0)
ffffffffc0200896:	00002517          	auipc	a0,0x2
ffffffffc020089a:	b9250513          	addi	a0,a0,-1134 # ffffffffc0202428 <commands+0x218>
ffffffffc020089e:	841ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02008a2:	740c                	ld	a1,40(s0)
ffffffffc02008a4:	00002517          	auipc	a0,0x2
ffffffffc02008a8:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0202440 <commands+0x230>
ffffffffc02008ac:	833ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02008b0:	780c                	ld	a1,48(s0)
ffffffffc02008b2:	00002517          	auipc	a0,0x2
ffffffffc02008b6:	ba650513          	addi	a0,a0,-1114 # ffffffffc0202458 <commands+0x248>
ffffffffc02008ba:	825ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02008be:	7c0c                	ld	a1,56(s0)
ffffffffc02008c0:	00002517          	auipc	a0,0x2
ffffffffc02008c4:	bb050513          	addi	a0,a0,-1104 # ffffffffc0202470 <commands+0x260>
ffffffffc02008c8:	817ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02008cc:	602c                	ld	a1,64(s0)
ffffffffc02008ce:	00002517          	auipc	a0,0x2
ffffffffc02008d2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0202488 <commands+0x278>
ffffffffc02008d6:	809ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02008da:	642c                	ld	a1,72(s0)
ffffffffc02008dc:	00002517          	auipc	a0,0x2
ffffffffc02008e0:	bc450513          	addi	a0,a0,-1084 # ffffffffc02024a0 <commands+0x290>
ffffffffc02008e4:	ffaff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02008e8:	682c                	ld	a1,80(s0)
ffffffffc02008ea:	00002517          	auipc	a0,0x2
ffffffffc02008ee:	bce50513          	addi	a0,a0,-1074 # ffffffffc02024b8 <commands+0x2a8>
ffffffffc02008f2:	fecff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02008f6:	6c2c                	ld	a1,88(s0)
ffffffffc02008f8:	00002517          	auipc	a0,0x2
ffffffffc02008fc:	bd850513          	addi	a0,a0,-1064 # ffffffffc02024d0 <commands+0x2c0>
ffffffffc0200900:	fdeff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200904:	702c                	ld	a1,96(s0)
ffffffffc0200906:	00002517          	auipc	a0,0x2
ffffffffc020090a:	be250513          	addi	a0,a0,-1054 # ffffffffc02024e8 <commands+0x2d8>
ffffffffc020090e:	fd0ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200912:	742c                	ld	a1,104(s0)
ffffffffc0200914:	00002517          	auipc	a0,0x2
ffffffffc0200918:	bec50513          	addi	a0,a0,-1044 # ffffffffc0202500 <commands+0x2f0>
ffffffffc020091c:	fc2ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200920:	782c                	ld	a1,112(s0)
ffffffffc0200922:	00002517          	auipc	a0,0x2
ffffffffc0200926:	bf650513          	addi	a0,a0,-1034 # ffffffffc0202518 <commands+0x308>
ffffffffc020092a:	fb4ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020092e:	7c2c                	ld	a1,120(s0)
ffffffffc0200930:	00002517          	auipc	a0,0x2
ffffffffc0200934:	c0050513          	addi	a0,a0,-1024 # ffffffffc0202530 <commands+0x320>
ffffffffc0200938:	fa6ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020093c:	604c                	ld	a1,128(s0)
ffffffffc020093e:	00002517          	auipc	a0,0x2
ffffffffc0200942:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0202548 <commands+0x338>
ffffffffc0200946:	f98ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020094a:	644c                	ld	a1,136(s0)
ffffffffc020094c:	00002517          	auipc	a0,0x2
ffffffffc0200950:	c1450513          	addi	a0,a0,-1004 # ffffffffc0202560 <commands+0x350>
ffffffffc0200954:	f8aff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200958:	684c                	ld	a1,144(s0)
ffffffffc020095a:	00002517          	auipc	a0,0x2
ffffffffc020095e:	c1e50513          	addi	a0,a0,-994 # ffffffffc0202578 <commands+0x368>
ffffffffc0200962:	f7cff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200966:	6c4c                	ld	a1,152(s0)
ffffffffc0200968:	00002517          	auipc	a0,0x2
ffffffffc020096c:	c2850513          	addi	a0,a0,-984 # ffffffffc0202590 <commands+0x380>
ffffffffc0200970:	f6eff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200974:	704c                	ld	a1,160(s0)
ffffffffc0200976:	00002517          	auipc	a0,0x2
ffffffffc020097a:	c3250513          	addi	a0,a0,-974 # ffffffffc02025a8 <commands+0x398>
ffffffffc020097e:	f60ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200982:	744c                	ld	a1,168(s0)
ffffffffc0200984:	00002517          	auipc	a0,0x2
ffffffffc0200988:	c3c50513          	addi	a0,a0,-964 # ffffffffc02025c0 <commands+0x3b0>
ffffffffc020098c:	f52ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200990:	784c                	ld	a1,176(s0)
ffffffffc0200992:	00002517          	auipc	a0,0x2
ffffffffc0200996:	c4650513          	addi	a0,a0,-954 # ffffffffc02025d8 <commands+0x3c8>
ffffffffc020099a:	f44ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020099e:	7c4c                	ld	a1,184(s0)
ffffffffc02009a0:	00002517          	auipc	a0,0x2
ffffffffc02009a4:	c5050513          	addi	a0,a0,-944 # ffffffffc02025f0 <commands+0x3e0>
ffffffffc02009a8:	f36ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02009ac:	606c                	ld	a1,192(s0)
ffffffffc02009ae:	00002517          	auipc	a0,0x2
ffffffffc02009b2:	c5a50513          	addi	a0,a0,-934 # ffffffffc0202608 <commands+0x3f8>
ffffffffc02009b6:	f28ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02009ba:	646c                	ld	a1,200(s0)
ffffffffc02009bc:	00002517          	auipc	a0,0x2
ffffffffc02009c0:	c6450513          	addi	a0,a0,-924 # ffffffffc0202620 <commands+0x410>
ffffffffc02009c4:	f1aff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02009c8:	686c                	ld	a1,208(s0)
ffffffffc02009ca:	00002517          	auipc	a0,0x2
ffffffffc02009ce:	c6e50513          	addi	a0,a0,-914 # ffffffffc0202638 <commands+0x428>
ffffffffc02009d2:	f0cff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02009d6:	6c6c                	ld	a1,216(s0)
ffffffffc02009d8:	00002517          	auipc	a0,0x2
ffffffffc02009dc:	c7850513          	addi	a0,a0,-904 # ffffffffc0202650 <commands+0x440>
ffffffffc02009e0:	efeff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02009e4:	706c                	ld	a1,224(s0)
ffffffffc02009e6:	00002517          	auipc	a0,0x2
ffffffffc02009ea:	c8250513          	addi	a0,a0,-894 # ffffffffc0202668 <commands+0x458>
ffffffffc02009ee:	ef0ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02009f2:	746c                	ld	a1,232(s0)
ffffffffc02009f4:	00002517          	auipc	a0,0x2
ffffffffc02009f8:	c8c50513          	addi	a0,a0,-884 # ffffffffc0202680 <commands+0x470>
ffffffffc02009fc:	ee2ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200a00:	786c                	ld	a1,240(s0)
ffffffffc0200a02:	00002517          	auipc	a0,0x2
ffffffffc0200a06:	c9650513          	addi	a0,a0,-874 # ffffffffc0202698 <commands+0x488>
ffffffffc0200a0a:	ed4ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a0e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200a10:	6402                	ld	s0,0(sp)
ffffffffc0200a12:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a14:	00002517          	auipc	a0,0x2
ffffffffc0200a18:	c9c50513          	addi	a0,a0,-868 # ffffffffc02026b0 <commands+0x4a0>
}
ffffffffc0200a1c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a1e:	ec0ff06f          	j	ffffffffc02000de <cprintf>

ffffffffc0200a22 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a22:	1141                	addi	sp,sp,-16
ffffffffc0200a24:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a26:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a28:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a2a:	00002517          	auipc	a0,0x2
ffffffffc0200a2e:	c9e50513          	addi	a0,a0,-866 # ffffffffc02026c8 <commands+0x4b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a32:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a34:	eaaff0ef          	jal	ra,ffffffffc02000de <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200a38:	8522                	mv	a0,s0
ffffffffc0200a3a:	e1bff0ef          	jal	ra,ffffffffc0200854 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200a3e:	10043583          	ld	a1,256(s0)
ffffffffc0200a42:	00002517          	auipc	a0,0x2
ffffffffc0200a46:	c9e50513          	addi	a0,a0,-866 # ffffffffc02026e0 <commands+0x4d0>
ffffffffc0200a4a:	e94ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200a4e:	10843583          	ld	a1,264(s0)
ffffffffc0200a52:	00002517          	auipc	a0,0x2
ffffffffc0200a56:	ca650513          	addi	a0,a0,-858 # ffffffffc02026f8 <commands+0x4e8>
ffffffffc0200a5a:	e84ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200a5e:	11043583          	ld	a1,272(s0)
ffffffffc0200a62:	00002517          	auipc	a0,0x2
ffffffffc0200a66:	cae50513          	addi	a0,a0,-850 # ffffffffc0202710 <commands+0x500>
ffffffffc0200a6a:	e74ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200a6e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200a72:	6402                	ld	s0,0(sp)
ffffffffc0200a74:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200a76:	00002517          	auipc	a0,0x2
ffffffffc0200a7a:	cb250513          	addi	a0,a0,-846 # ffffffffc0202728 <commands+0x518>
}
ffffffffc0200a7e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200a80:	e5eff06f          	j	ffffffffc02000de <cprintf>

ffffffffc0200a84 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    static int ticks = 0;
    static int print_num = 0;
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200a84:	11853783          	ld	a5,280(a0)
ffffffffc0200a88:	472d                	li	a4,11
ffffffffc0200a8a:	0786                	slli	a5,a5,0x1
ffffffffc0200a8c:	8385                	srli	a5,a5,0x1
ffffffffc0200a8e:	08f76263          	bltu	a4,a5,ffffffffc0200b12 <interrupt_handler+0x8e>
ffffffffc0200a92:	00002717          	auipc	a4,0x2
ffffffffc0200a96:	d7670713          	addi	a4,a4,-650 # ffffffffc0202808 <commands+0x5f8>
ffffffffc0200a9a:	078a                	slli	a5,a5,0x2
ffffffffc0200a9c:	97ba                	add	a5,a5,a4
ffffffffc0200a9e:	439c                	lw	a5,0(a5)
ffffffffc0200aa0:	97ba                	add	a5,a5,a4
ffffffffc0200aa2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc0200aa4:	00002517          	auipc	a0,0x2
ffffffffc0200aa8:	cfc50513          	addi	a0,a0,-772 # ffffffffc02027a0 <commands+0x590>
ffffffffc0200aac:	e32ff06f          	j	ffffffffc02000de <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc0200ab0:	00002517          	auipc	a0,0x2
ffffffffc0200ab4:	cd050513          	addi	a0,a0,-816 # ffffffffc0202780 <commands+0x570>
ffffffffc0200ab8:	e26ff06f          	j	ffffffffc02000de <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200abc:	00002517          	auipc	a0,0x2
ffffffffc0200ac0:	c8450513          	addi	a0,a0,-892 # ffffffffc0202740 <commands+0x530>
ffffffffc0200ac4:	e1aff06f          	j	ffffffffc02000de <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc0200ac8:	00002517          	auipc	a0,0x2
ffffffffc0200acc:	cf850513          	addi	a0,a0,-776 # ffffffffc02027c0 <commands+0x5b0>
ffffffffc0200ad0:	e0eff06f          	j	ffffffffc02000de <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200ad4:	1141                	addi	sp,sp,-16
ffffffffc0200ad6:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
ffffffffc0200ad8:	d41ff0ef          	jal	ra,ffffffffc0200818 <clock_set_next_event>
            ticks++;
ffffffffc0200adc:	00007697          	auipc	a3,0x7
ffffffffc0200ae0:	98868693          	addi	a3,a3,-1656 # ffffffffc0207464 <ticks.1>
ffffffffc0200ae4:	429c                	lw	a5,0(a3)
            if (ticks % TICK_NUM == 0) {
ffffffffc0200ae6:	06400713          	li	a4,100
            ticks++;
ffffffffc0200aea:	2785                	addiw	a5,a5,1
            if (ticks % TICK_NUM == 0) {
ffffffffc0200aec:	02e7e73b          	remw	a4,a5,a4
            ticks++;
ffffffffc0200af0:	c29c                	sw	a5,0(a3)
            if (ticks % TICK_NUM == 0) {
ffffffffc0200af2:	c30d                	beqz	a4,ffffffffc0200b14 <interrupt_handler+0x90>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200af4:	60a2                	ld	ra,8(sp)
ffffffffc0200af6:	0141                	addi	sp,sp,16
ffffffffc0200af8:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200afa:	00002517          	auipc	a0,0x2
ffffffffc0200afe:	cee50513          	addi	a0,a0,-786 # ffffffffc02027e8 <commands+0x5d8>
ffffffffc0200b02:	ddcff06f          	j	ffffffffc02000de <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200b06:	00002517          	auipc	a0,0x2
ffffffffc0200b0a:	c5a50513          	addi	a0,a0,-934 # ffffffffc0202760 <commands+0x550>
ffffffffc0200b0e:	dd0ff06f          	j	ffffffffc02000de <cprintf>
            print_trapframe(tf);
ffffffffc0200b12:	bf01                	j	ffffffffc0200a22 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200b14:	06400593          	li	a1,100
ffffffffc0200b18:	00002517          	auipc	a0,0x2
ffffffffc0200b1c:	cc050513          	addi	a0,a0,-832 # ffffffffc02027d8 <commands+0x5c8>
ffffffffc0200b20:	dbeff0ef          	jal	ra,ffffffffc02000de <cprintf>
                print_num++;
ffffffffc0200b24:	00007717          	auipc	a4,0x7
ffffffffc0200b28:	93c70713          	addi	a4,a4,-1732 # ffffffffc0207460 <print_num.0>
ffffffffc0200b2c:	431c                	lw	a5,0(a4)
                if (print_num == 10) { 
ffffffffc0200b2e:	46a9                	li	a3,10
                print_num++;
ffffffffc0200b30:	0017861b          	addiw	a2,a5,1
ffffffffc0200b34:	c310                	sw	a2,0(a4)
                if (print_num == 10) { 
ffffffffc0200b36:	fad61fe3          	bne	a2,a3,ffffffffc0200af4 <interrupt_handler+0x70>
}
ffffffffc0200b3a:	60a2                	ld	ra,8(sp)
ffffffffc0200b3c:	0141                	addi	sp,sp,16
                    sbi_shutdown();
ffffffffc0200b3e:	43e0106f          	j	ffffffffc0201f7c <sbi_shutdown>

ffffffffc0200b42 <exception_handler>:
    uint16_t half;
    memcpy(&half, (void *)epc, sizeof(half));
    return (half & 0x3) != 0x3 ? 2 : 4;
}

void exception_handler(struct trapframe *tf) {
ffffffffc0200b42:	7179                	addi	sp,sp,-48
ffffffffc0200b44:	ec26                	sd	s1,24(sp)
    switch (tf->cause) {
ffffffffc0200b46:	11853483          	ld	s1,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200b4a:	f406                	sd	ra,40(sp)
ffffffffc0200b4c:	f022                	sd	s0,32(sp)
ffffffffc0200b4e:	47ad                	li	a5,11
ffffffffc0200b50:	0a97e863          	bltu	a5,s1,ffffffffc0200c00 <exception_handler+0xbe>
ffffffffc0200b54:	00002697          	auipc	a3,0x2
ffffffffc0200b58:	df068693          	addi	a3,a3,-528 # ffffffffc0202944 <commands+0x734>
ffffffffc0200b5c:	00249713          	slli	a4,s1,0x2
ffffffffc0200b60:	9736                	add	a4,a4,a3
ffffffffc0200b62:	431c                	lw	a5,0(a4)
ffffffffc0200b64:	842a                	mv	s0,a0
ffffffffc0200b66:	97b6                	add	a5,a5,a3
ffffffffc0200b68:	8782                	jr	a5
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            // 避免递归打印，这里只打印一行简讯
            cprintf("Illegal instruction at %p\n", tf->epc);
ffffffffc0200b6a:	10853583          	ld	a1,264(a0)
ffffffffc0200b6e:	00002517          	auipc	a0,0x2
ffffffffc0200b72:	cca50513          	addi	a0,a0,-822 # ffffffffc0202838 <commands+0x628>
ffffffffc0200b76:	d68ff0ef          	jal	ra,ffffffffc02000de <cprintf>
            cprintf("Exception type:Illegal instruction\n");
ffffffffc0200b7a:	00002517          	auipc	a0,0x2
ffffffffc0200b7e:	cde50513          	addi	a0,a0,-802 # ffffffffc0202858 <commands+0x648>
ffffffffc0200b82:	d5cff0ef          	jal	ra,ffffffffc02000de <cprintf>
    memcpy(&half, (void *)epc, sizeof(half));
ffffffffc0200b86:	10843583          	ld	a1,264(s0)
ffffffffc0200b8a:	4609                	li	a2,2
ffffffffc0200b8c:	00e10513          	addi	a0,sp,14
ffffffffc0200b90:	6e3000ef          	jal	ra,ffffffffc0201a72 <memcpy>
    return (half & 0x3) != 0x3 ? 2 : 4;
ffffffffc0200b94:	00e15783          	lhu	a5,14(sp)
ffffffffc0200b98:	470d                	li	a4,3
ffffffffc0200b9a:	8b8d                	andi	a5,a5,3
ffffffffc0200b9c:	06e78763          	beq	a5,a4,ffffffffc0200c0a <exception_handler+0xc8>
            tf->epc += insn_len(tf->epc);
ffffffffc0200ba0:	10843783          	ld	a5,264(s0)
ffffffffc0200ba4:	94be                	add	s1,s1,a5
ffffffffc0200ba6:	10943423          	sd	s1,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200baa:	70a2                	ld	ra,40(sp)
ffffffffc0200bac:	7402                	ld	s0,32(sp)
ffffffffc0200bae:	64e2                	ld	s1,24(sp)
ffffffffc0200bb0:	6145                	addi	sp,sp,48
ffffffffc0200bb2:	8082                	ret
            cprintf("ebreak at =%p\n", tf->epc);
ffffffffc0200bb4:	10853583          	ld	a1,264(a0)
ffffffffc0200bb8:	00002517          	auipc	a0,0x2
ffffffffc0200bbc:	cc850513          	addi	a0,a0,-824 # ffffffffc0202880 <commands+0x670>
ffffffffc0200bc0:	d1eff0ef          	jal	ra,ffffffffc02000de <cprintf>
            cprintf("Exception type:breakpoint\n");
ffffffffc0200bc4:	00002517          	auipc	a0,0x2
ffffffffc0200bc8:	ccc50513          	addi	a0,a0,-820 # ffffffffc0202890 <commands+0x680>
ffffffffc0200bcc:	d12ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    memcpy(&half, (void *)epc, sizeof(half));
ffffffffc0200bd0:	10843583          	ld	a1,264(s0)
ffffffffc0200bd4:	4609                	li	a2,2
ffffffffc0200bd6:	00e10513          	addi	a0,sp,14
ffffffffc0200bda:	699000ef          	jal	ra,ffffffffc0201a72 <memcpy>
    return (half & 0x3) != 0x3 ? 2 : 4;
ffffffffc0200bde:	00e15703          	lhu	a4,14(sp)
ffffffffc0200be2:	478d                	li	a5,3
ffffffffc0200be4:	4689                	li	a3,2
ffffffffc0200be6:	8b0d                	andi	a4,a4,3
ffffffffc0200be8:	02f70363          	beq	a4,a5,ffffffffc0200c0e <exception_handler+0xcc>
            tf->epc += insn_len(tf->epc);
ffffffffc0200bec:	10843783          	ld	a5,264(s0)
}
ffffffffc0200bf0:	70a2                	ld	ra,40(sp)
ffffffffc0200bf2:	64e2                	ld	s1,24(sp)
            tf->epc += insn_len(tf->epc);
ffffffffc0200bf4:	97b6                	add	a5,a5,a3
ffffffffc0200bf6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200bfa:	7402                	ld	s0,32(sp)
ffffffffc0200bfc:	6145                	addi	sp,sp,48
ffffffffc0200bfe:	8082                	ret
ffffffffc0200c00:	7402                	ld	s0,32(sp)
ffffffffc0200c02:	70a2                	ld	ra,40(sp)
ffffffffc0200c04:	64e2                	ld	s1,24(sp)
ffffffffc0200c06:	6145                	addi	sp,sp,48
            print_trapframe(tf);
ffffffffc0200c08:	bd29                	j	ffffffffc0200a22 <print_trapframe>
    return (half & 0x3) != 0x3 ? 2 : 4;
ffffffffc0200c0a:	4491                	li	s1,4
ffffffffc0200c0c:	bf51                	j	ffffffffc0200ba0 <exception_handler+0x5e>
ffffffffc0200c0e:	4691                	li	a3,4
ffffffffc0200c10:	bff1                	j	ffffffffc0200bec <exception_handler+0xaa>
            cprintf("Load page fault: sepc=%p stval=%p\n", tf->epc, tf->badvaddr);
ffffffffc0200c12:	11053603          	ld	a2,272(a0)
ffffffffc0200c16:	10853583          	ld	a1,264(a0)
ffffffffc0200c1a:	00002517          	auipc	a0,0x2
ffffffffc0200c1e:	c9650513          	addi	a0,a0,-874 # ffffffffc02028b0 <commands+0x6a0>
ffffffffc0200c22:	cbcff0ef          	jal	ra,ffffffffc02000de <cprintf>
            panic("kernel load fault");
ffffffffc0200c26:	00002617          	auipc	a2,0x2
ffffffffc0200c2a:	cb260613          	addi	a2,a2,-846 # ffffffffc02028d8 <commands+0x6c8>
ffffffffc0200c2e:	0da00593          	li	a1,218
ffffffffc0200c32:	00002517          	auipc	a0,0x2
ffffffffc0200c36:	cbe50513          	addi	a0,a0,-834 # ffffffffc02028f0 <commands+0x6e0>
ffffffffc0200c3a:	d2cff0ef          	jal	ra,ffffffffc0200166 <__panic>
            cprintf("Store page fault: sepc=%p stval=%p\n", tf->epc, tf->badvaddr);
ffffffffc0200c3e:	11053603          	ld	a2,272(a0)
ffffffffc0200c42:	10853583          	ld	a1,264(a0)
ffffffffc0200c46:	00002517          	auipc	a0,0x2
ffffffffc0200c4a:	cc250513          	addi	a0,a0,-830 # ffffffffc0202908 <commands+0x6f8>
ffffffffc0200c4e:	c90ff0ef          	jal	ra,ffffffffc02000de <cprintf>
            panic("kernel store fault");
ffffffffc0200c52:	00002617          	auipc	a2,0x2
ffffffffc0200c56:	cde60613          	addi	a2,a2,-802 # ffffffffc0202930 <commands+0x720>
ffffffffc0200c5a:	0df00593          	li	a1,223
ffffffffc0200c5e:	00002517          	auipc	a0,0x2
ffffffffc0200c62:	c9250513          	addi	a0,a0,-878 # ffffffffc02028f0 <commands+0x6e0>
ffffffffc0200c66:	d00ff0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc0200c6a <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c6a:	11853783          	ld	a5,280(a0)
ffffffffc0200c6e:	0007c363          	bltz	a5,ffffffffc0200c74 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200c72:	bdc1                	j	ffffffffc0200b42 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200c74:	bd01                	j	ffffffffc0200a84 <interrupt_handler>
	...

ffffffffc0200c78 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200c78:	14011073          	csrw	sscratch,sp
ffffffffc0200c7c:	712d                	addi	sp,sp,-288
ffffffffc0200c7e:	e002                	sd	zero,0(sp)
ffffffffc0200c80:	e406                	sd	ra,8(sp)
ffffffffc0200c82:	ec0e                	sd	gp,24(sp)
ffffffffc0200c84:	f012                	sd	tp,32(sp)
ffffffffc0200c86:	f416                	sd	t0,40(sp)
ffffffffc0200c88:	f81a                	sd	t1,48(sp)
ffffffffc0200c8a:	fc1e                	sd	t2,56(sp)
ffffffffc0200c8c:	e0a2                	sd	s0,64(sp)
ffffffffc0200c8e:	e4a6                	sd	s1,72(sp)
ffffffffc0200c90:	e8aa                	sd	a0,80(sp)
ffffffffc0200c92:	ecae                	sd	a1,88(sp)
ffffffffc0200c94:	f0b2                	sd	a2,96(sp)
ffffffffc0200c96:	f4b6                	sd	a3,104(sp)
ffffffffc0200c98:	f8ba                	sd	a4,112(sp)
ffffffffc0200c9a:	fcbe                	sd	a5,120(sp)
ffffffffc0200c9c:	e142                	sd	a6,128(sp)
ffffffffc0200c9e:	e546                	sd	a7,136(sp)
ffffffffc0200ca0:	e94a                	sd	s2,144(sp)
ffffffffc0200ca2:	ed4e                	sd	s3,152(sp)
ffffffffc0200ca4:	f152                	sd	s4,160(sp)
ffffffffc0200ca6:	f556                	sd	s5,168(sp)
ffffffffc0200ca8:	f95a                	sd	s6,176(sp)
ffffffffc0200caa:	fd5e                	sd	s7,184(sp)
ffffffffc0200cac:	e1e2                	sd	s8,192(sp)
ffffffffc0200cae:	e5e6                	sd	s9,200(sp)
ffffffffc0200cb0:	e9ea                	sd	s10,208(sp)
ffffffffc0200cb2:	edee                	sd	s11,216(sp)
ffffffffc0200cb4:	f1f2                	sd	t3,224(sp)
ffffffffc0200cb6:	f5f6                	sd	t4,232(sp)
ffffffffc0200cb8:	f9fa                	sd	t5,240(sp)
ffffffffc0200cba:	fdfe                	sd	t6,248(sp)
ffffffffc0200cbc:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cc0:	100024f3          	csrr	s1,sstatus
ffffffffc0200cc4:	14102973          	csrr	s2,sepc
ffffffffc0200cc8:	143029f3          	csrr	s3,stval
ffffffffc0200ccc:	14202a73          	csrr	s4,scause
ffffffffc0200cd0:	e822                	sd	s0,16(sp)
ffffffffc0200cd2:	e226                	sd	s1,256(sp)
ffffffffc0200cd4:	e64a                	sd	s2,264(sp)
ffffffffc0200cd6:	ea4e                	sd	s3,272(sp)
ffffffffc0200cd8:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200cda:	850a                	mv	a0,sp
    jal trap
ffffffffc0200cdc:	f8fff0ef          	jal	ra,ffffffffc0200c6a <trap>

ffffffffc0200ce0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ce0:	6492                	ld	s1,256(sp)
ffffffffc0200ce2:	6932                	ld	s2,264(sp)
ffffffffc0200ce4:	10049073          	csrw	sstatus,s1
ffffffffc0200ce8:	14191073          	csrw	sepc,s2
ffffffffc0200cec:	60a2                	ld	ra,8(sp)
ffffffffc0200cee:	61e2                	ld	gp,24(sp)
ffffffffc0200cf0:	7202                	ld	tp,32(sp)
ffffffffc0200cf2:	72a2                	ld	t0,40(sp)
ffffffffc0200cf4:	7342                	ld	t1,48(sp)
ffffffffc0200cf6:	73e2                	ld	t2,56(sp)
ffffffffc0200cf8:	6406                	ld	s0,64(sp)
ffffffffc0200cfa:	64a6                	ld	s1,72(sp)
ffffffffc0200cfc:	6546                	ld	a0,80(sp)
ffffffffc0200cfe:	65e6                	ld	a1,88(sp)
ffffffffc0200d00:	7606                	ld	a2,96(sp)
ffffffffc0200d02:	76a6                	ld	a3,104(sp)
ffffffffc0200d04:	7746                	ld	a4,112(sp)
ffffffffc0200d06:	77e6                	ld	a5,120(sp)
ffffffffc0200d08:	680a                	ld	a6,128(sp)
ffffffffc0200d0a:	68aa                	ld	a7,136(sp)
ffffffffc0200d0c:	694a                	ld	s2,144(sp)
ffffffffc0200d0e:	69ea                	ld	s3,152(sp)
ffffffffc0200d10:	7a0a                	ld	s4,160(sp)
ffffffffc0200d12:	7aaa                	ld	s5,168(sp)
ffffffffc0200d14:	7b4a                	ld	s6,176(sp)
ffffffffc0200d16:	7bea                	ld	s7,184(sp)
ffffffffc0200d18:	6c0e                	ld	s8,192(sp)
ffffffffc0200d1a:	6cae                	ld	s9,200(sp)
ffffffffc0200d1c:	6d4e                	ld	s10,208(sp)
ffffffffc0200d1e:	6dee                	ld	s11,216(sp)
ffffffffc0200d20:	7e0e                	ld	t3,224(sp)
ffffffffc0200d22:	7eae                	ld	t4,232(sp)
ffffffffc0200d24:	7f4e                	ld	t5,240(sp)
ffffffffc0200d26:	7fee                	ld	t6,248(sp)
ffffffffc0200d28:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d2a:	10200073          	sret

ffffffffc0200d2e <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200d2e:	100027f3          	csrr	a5,sstatus
ffffffffc0200d32:	8b89                	andi	a5,a5,2
ffffffffc0200d34:	e799                	bnez	a5,ffffffffc0200d42 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200d36:	00006797          	auipc	a5,0x6
ffffffffc0200d3a:	7427b783          	ld	a5,1858(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200d3e:	6f9c                	ld	a5,24(a5)
ffffffffc0200d40:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200d42:	1141                	addi	sp,sp,-16
ffffffffc0200d44:	e406                	sd	ra,8(sp)
ffffffffc0200d46:	e022                	sd	s0,0(sp)
ffffffffc0200d48:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200d4a:	af3ff0ef          	jal	ra,ffffffffc020083c <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200d4e:	00006797          	auipc	a5,0x6
ffffffffc0200d52:	72a7b783          	ld	a5,1834(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200d56:	6f9c                	ld	a5,24(a5)
ffffffffc0200d58:	8522                	mv	a0,s0
ffffffffc0200d5a:	9782                	jalr	a5
ffffffffc0200d5c:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200d5e:	ad9ff0ef          	jal	ra,ffffffffc0200836 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200d62:	60a2                	ld	ra,8(sp)
ffffffffc0200d64:	8522                	mv	a0,s0
ffffffffc0200d66:	6402                	ld	s0,0(sp)
ffffffffc0200d68:	0141                	addi	sp,sp,16
ffffffffc0200d6a:	8082                	ret

ffffffffc0200d6c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200d6c:	100027f3          	csrr	a5,sstatus
ffffffffc0200d70:	8b89                	andi	a5,a5,2
ffffffffc0200d72:	e799                	bnez	a5,ffffffffc0200d80 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200d74:	00006797          	auipc	a5,0x6
ffffffffc0200d78:	7047b783          	ld	a5,1796(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200d7c:	739c                	ld	a5,32(a5)
ffffffffc0200d7e:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200d80:	1101                	addi	sp,sp,-32
ffffffffc0200d82:	ec06                	sd	ra,24(sp)
ffffffffc0200d84:	e822                	sd	s0,16(sp)
ffffffffc0200d86:	e426                	sd	s1,8(sp)
ffffffffc0200d88:	842a                	mv	s0,a0
ffffffffc0200d8a:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200d8c:	ab1ff0ef          	jal	ra,ffffffffc020083c <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200d90:	00006797          	auipc	a5,0x6
ffffffffc0200d94:	6e87b783          	ld	a5,1768(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200d98:	739c                	ld	a5,32(a5)
ffffffffc0200d9a:	85a6                	mv	a1,s1
ffffffffc0200d9c:	8522                	mv	a0,s0
ffffffffc0200d9e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200da0:	6442                	ld	s0,16(sp)
ffffffffc0200da2:	60e2                	ld	ra,24(sp)
ffffffffc0200da4:	64a2                	ld	s1,8(sp)
ffffffffc0200da6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200da8:	b479                	j	ffffffffc0200836 <intr_enable>

ffffffffc0200daa <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200daa:	100027f3          	csrr	a5,sstatus
ffffffffc0200dae:	8b89                	andi	a5,a5,2
ffffffffc0200db0:	e799                	bnez	a5,ffffffffc0200dbe <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200db2:	00006797          	auipc	a5,0x6
ffffffffc0200db6:	6c67b783          	ld	a5,1734(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200dba:	779c                	ld	a5,40(a5)
ffffffffc0200dbc:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200dbe:	1141                	addi	sp,sp,-16
ffffffffc0200dc0:	e406                	sd	ra,8(sp)
ffffffffc0200dc2:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200dc4:	a79ff0ef          	jal	ra,ffffffffc020083c <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200dc8:	00006797          	auipc	a5,0x6
ffffffffc0200dcc:	6b07b783          	ld	a5,1712(a5) # ffffffffc0207478 <pmm_manager>
ffffffffc0200dd0:	779c                	ld	a5,40(a5)
ffffffffc0200dd2:	9782                	jalr	a5
ffffffffc0200dd4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200dd6:	a61ff0ef          	jal	ra,ffffffffc0200836 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200dda:	60a2                	ld	ra,8(sp)
ffffffffc0200ddc:	8522                	mv	a0,s0
ffffffffc0200dde:	6402                	ld	s0,0(sp)
ffffffffc0200de0:	0141                	addi	sp,sp,16
ffffffffc0200de2:	8082                	ret

ffffffffc0200de4 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200de4:	00002797          	auipc	a5,0x2
ffffffffc0200de8:	02478793          	addi	a5,a5,36 # ffffffffc0202e08 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200dec:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200dee:	7179                	addi	sp,sp,-48
ffffffffc0200df0:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200df2:	00002517          	auipc	a0,0x2
ffffffffc0200df6:	b8650513          	addi	a0,a0,-1146 # ffffffffc0202978 <commands+0x768>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200dfa:	00006417          	auipc	s0,0x6
ffffffffc0200dfe:	67e40413          	addi	s0,s0,1662 # ffffffffc0207478 <pmm_manager>
void pmm_init(void) {
ffffffffc0200e02:	f406                	sd	ra,40(sp)
ffffffffc0200e04:	ec26                	sd	s1,24(sp)
ffffffffc0200e06:	e44e                	sd	s3,8(sp)
ffffffffc0200e08:	e84a                	sd	s2,16(sp)
ffffffffc0200e0a:	e052                	sd	s4,0(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200e0c:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e0e:	ad0ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    pmm_manager->init();
ffffffffc0200e12:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e14:	00006497          	auipc	s1,0x6
ffffffffc0200e18:	67c48493          	addi	s1,s1,1660 # ffffffffc0207490 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200e1c:	679c                	ld	a5,8(a5)
ffffffffc0200e1e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e20:	57f5                	li	a5,-3
ffffffffc0200e22:	07fa                	slli	a5,a5,0x1e
ffffffffc0200e24:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0200e26:	9abff0ef          	jal	ra,ffffffffc02007d0 <get_memory_base>
ffffffffc0200e2a:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200e2c:	9afff0ef          	jal	ra,ffffffffc02007da <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200e30:	16050163          	beqz	a0,ffffffffc0200f92 <pmm_init+0x1ae>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200e34:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200e36:	00002517          	auipc	a0,0x2
ffffffffc0200e3a:	b8a50513          	addi	a0,a0,-1142 # ffffffffc02029c0 <commands+0x7b0>
ffffffffc0200e3e:	aa0ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200e42:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200e46:	864e                	mv	a2,s3
ffffffffc0200e48:	fffa0693          	addi	a3,s4,-1
ffffffffc0200e4c:	85ca                	mv	a1,s2
ffffffffc0200e4e:	00002517          	auipc	a0,0x2
ffffffffc0200e52:	b8a50513          	addi	a0,a0,-1142 # ffffffffc02029d8 <commands+0x7c8>
ffffffffc0200e56:	a88ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200e5a:	c80007b7          	lui	a5,0xc8000
ffffffffc0200e5e:	8652                	mv	a2,s4
ffffffffc0200e60:	0d47e863          	bltu	a5,s4,ffffffffc0200f30 <pmm_init+0x14c>
ffffffffc0200e64:	00007797          	auipc	a5,0x7
ffffffffc0200e68:	63b78793          	addi	a5,a5,1595 # ffffffffc020849f <end+0xfff>
ffffffffc0200e6c:	757d                	lui	a0,0xfffff
ffffffffc0200e6e:	8d7d                	and	a0,a0,a5
ffffffffc0200e70:	8231                	srli	a2,a2,0xc
ffffffffc0200e72:	00006597          	auipc	a1,0x6
ffffffffc0200e76:	5f658593          	addi	a1,a1,1526 # ffffffffc0207468 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e7a:	00006817          	auipc	a6,0x6
ffffffffc0200e7e:	5f680813          	addi	a6,a6,1526 # ffffffffc0207470 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200e82:	e190                	sd	a2,0(a1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e84:	00a83023          	sd	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e88:	000807b7          	lui	a5,0x80
ffffffffc0200e8c:	02f60663          	beq	a2,a5,ffffffffc0200eb8 <pmm_init+0xd4>
ffffffffc0200e90:	4701                	li	a4,0
ffffffffc0200e92:	4781                	li	a5,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200e94:	4305                	li	t1,1
ffffffffc0200e96:	fff808b7          	lui	a7,0xfff80
        SetPageReserved(pages + i);
ffffffffc0200e9a:	953a                	add	a0,a0,a4
ffffffffc0200e9c:	00850693          	addi	a3,a0,8 # fffffffffffff008 <end+0x3fdf7b68>
ffffffffc0200ea0:	4066b02f          	amoor.d	zero,t1,(a3)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200ea4:	6190                	ld	a2,0(a1)
ffffffffc0200ea6:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0200ea8:	00083503          	ld	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200eac:	011606b3          	add	a3,a2,a7
ffffffffc0200eb0:	02870713          	addi	a4,a4,40
ffffffffc0200eb4:	fed7e3e3          	bltu	a5,a3,ffffffffc0200e9a <pmm_init+0xb6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200eb8:	00261693          	slli	a3,a2,0x2
ffffffffc0200ebc:	96b2                	add	a3,a3,a2
ffffffffc0200ebe:	fec007b7          	lui	a5,0xfec00
ffffffffc0200ec2:	97aa                	add	a5,a5,a0
ffffffffc0200ec4:	068e                	slli	a3,a3,0x3
ffffffffc0200ec6:	96be                	add	a3,a3,a5
ffffffffc0200ec8:	c02007b7          	lui	a5,0xc0200
ffffffffc0200ecc:	0af6e763          	bltu	a3,a5,ffffffffc0200f7a <pmm_init+0x196>
ffffffffc0200ed0:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0200ed2:	77fd                	lui	a5,0xfffff
ffffffffc0200ed4:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ed8:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200eda:	04b6ee63          	bltu	a3,a1,ffffffffc0200f36 <pmm_init+0x152>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200ede:	601c                	ld	a5,0(s0)
ffffffffc0200ee0:	7b9c                	ld	a5,48(a5)
ffffffffc0200ee2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200ee4:	00002517          	auipc	a0,0x2
ffffffffc0200ee8:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0202a60 <commands+0x850>
ffffffffc0200eec:	9f2ff0ef          	jal	ra,ffffffffc02000de <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200ef0:	00005597          	auipc	a1,0x5
ffffffffc0200ef4:	11058593          	addi	a1,a1,272 # ffffffffc0206000 <boot_page_table_sv39>
ffffffffc0200ef8:	00006797          	auipc	a5,0x6
ffffffffc0200efc:	58b7b823          	sd	a1,1424(a5) # ffffffffc0207488 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f00:	c02007b7          	lui	a5,0xc0200
ffffffffc0200f04:	0af5e363          	bltu	a1,a5,ffffffffc0200faa <pmm_init+0x1c6>
ffffffffc0200f08:	6090                	ld	a2,0(s1)
}
ffffffffc0200f0a:	7402                	ld	s0,32(sp)
ffffffffc0200f0c:	70a2                	ld	ra,40(sp)
ffffffffc0200f0e:	64e2                	ld	s1,24(sp)
ffffffffc0200f10:	6942                	ld	s2,16(sp)
ffffffffc0200f12:	69a2                	ld	s3,8(sp)
ffffffffc0200f14:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f16:	40c58633          	sub	a2,a1,a2
ffffffffc0200f1a:	00006797          	auipc	a5,0x6
ffffffffc0200f1e:	56c7b323          	sd	a2,1382(a5) # ffffffffc0207480 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f22:	00002517          	auipc	a0,0x2
ffffffffc0200f26:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0202a80 <commands+0x870>
}
ffffffffc0200f2a:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f2c:	9b2ff06f          	j	ffffffffc02000de <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200f30:	c8000637          	lui	a2,0xc8000
ffffffffc0200f34:	bf05                	j	ffffffffc0200e64 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200f36:	6705                	lui	a4,0x1
ffffffffc0200f38:	177d                	addi	a4,a4,-1
ffffffffc0200f3a:	96ba                	add	a3,a3,a4
ffffffffc0200f3c:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200f3e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200f42:	02c7f063          	bgeu	a5,a2,ffffffffc0200f62 <pmm_init+0x17e>
    pmm_manager->init_memmap(base, n);
ffffffffc0200f46:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200f48:	fff80737          	lui	a4,0xfff80
ffffffffc0200f4c:	973e                	add	a4,a4,a5
ffffffffc0200f4e:	00271793          	slli	a5,a4,0x2
ffffffffc0200f52:	97ba                	add	a5,a5,a4
ffffffffc0200f54:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200f56:	8d95                	sub	a1,a1,a3
ffffffffc0200f58:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200f5a:	81b1                	srli	a1,a1,0xc
ffffffffc0200f5c:	953e                	add	a0,a0,a5
ffffffffc0200f5e:	9702                	jalr	a4
}
ffffffffc0200f60:	bfbd                	j	ffffffffc0200ede <pmm_init+0xfa>
        panic("pa2page called with invalid pa");
ffffffffc0200f62:	00002617          	auipc	a2,0x2
ffffffffc0200f66:	ace60613          	addi	a2,a2,-1330 # ffffffffc0202a30 <commands+0x820>
ffffffffc0200f6a:	06b00593          	li	a1,107
ffffffffc0200f6e:	00002517          	auipc	a0,0x2
ffffffffc0200f72:	ae250513          	addi	a0,a0,-1310 # ffffffffc0202a50 <commands+0x840>
ffffffffc0200f76:	9f0ff0ef          	jal	ra,ffffffffc0200166 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f7a:	00002617          	auipc	a2,0x2
ffffffffc0200f7e:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0202a08 <commands+0x7f8>
ffffffffc0200f82:	07100593          	li	a1,113
ffffffffc0200f86:	00002517          	auipc	a0,0x2
ffffffffc0200f8a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc02029b0 <commands+0x7a0>
ffffffffc0200f8e:	9d8ff0ef          	jal	ra,ffffffffc0200166 <__panic>
        panic("DTB memory info not available");
ffffffffc0200f92:	00002617          	auipc	a2,0x2
ffffffffc0200f96:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0202990 <commands+0x780>
ffffffffc0200f9a:	05a00593          	li	a1,90
ffffffffc0200f9e:	00002517          	auipc	a0,0x2
ffffffffc0200fa2:	a1250513          	addi	a0,a0,-1518 # ffffffffc02029b0 <commands+0x7a0>
ffffffffc0200fa6:	9c0ff0ef          	jal	ra,ffffffffc0200166 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200faa:	86ae                	mv	a3,a1
ffffffffc0200fac:	00002617          	auipc	a2,0x2
ffffffffc0200fb0:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0202a08 <commands+0x7f8>
ffffffffc0200fb4:	08c00593          	li	a1,140
ffffffffc0200fb8:	00002517          	auipc	a0,0x2
ffffffffc0200fbc:	9f850513          	addi	a0,a0,-1544 # ffffffffc02029b0 <commands+0x7a0>
ffffffffc0200fc0:	9a6ff0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc0200fc4 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200fc4:	00006797          	auipc	a5,0x6
ffffffffc0200fc8:	06478793          	addi	a5,a5,100 # ffffffffc0207028 <free_area>
ffffffffc0200fcc:	e79c                	sd	a5,8(a5)
ffffffffc0200fce:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200fd0:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200fd4:	8082                	ret

ffffffffc0200fd6 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200fd6:	00006517          	auipc	a0,0x6
ffffffffc0200fda:	06256503          	lwu	a0,98(a0) # ffffffffc0207038 <free_area+0x10>
ffffffffc0200fde:	8082                	ret

ffffffffc0200fe0 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200fe0:	c14d                	beqz	a0,ffffffffc0201082 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200fe2:	00006617          	auipc	a2,0x6
ffffffffc0200fe6:	04660613          	addi	a2,a2,70 # ffffffffc0207028 <free_area>
ffffffffc0200fea:	01062803          	lw	a6,16(a2)
ffffffffc0200fee:	86aa                	mv	a3,a0
ffffffffc0200ff0:	02081793          	slli	a5,a6,0x20
ffffffffc0200ff4:	9381                	srli	a5,a5,0x20
ffffffffc0200ff6:	08a7e463          	bltu	a5,a0,ffffffffc020107e <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ffa:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc0200ffc:	0018059b          	addiw	a1,a6,1
ffffffffc0201000:	1582                	slli	a1,a1,0x20
ffffffffc0201002:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0201004:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201006:	06c78b63          	beq	a5,a2,ffffffffc020107c <best_fit_alloc_pages+0x9c>
        if (p->property >= n) {
ffffffffc020100a:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020100e:	00d76763          	bltu	a4,a3,ffffffffc020101c <best_fit_alloc_pages+0x3c>
            if(p->property < min_size){
ffffffffc0201012:	00b77563          	bgeu	a4,a1,ffffffffc020101c <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0201016:	fe878513          	addi	a0,a5,-24
ffffffffc020101a:	85ba                	mv	a1,a4
ffffffffc020101c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020101e:	fec796e3          	bne	a5,a2,ffffffffc020100a <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0201022:	cd29                	beqz	a0,ffffffffc020107c <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201024:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0201026:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc0201028:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc020102a:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020102e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201030:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc0201032:	02059793          	slli	a5,a1,0x20
ffffffffc0201036:	9381                	srli	a5,a5,0x20
ffffffffc0201038:	02f6f863          	bgeu	a3,a5,ffffffffc0201068 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc020103c:	00269793          	slli	a5,a3,0x2
ffffffffc0201040:	97b6                	add	a5,a5,a3
ffffffffc0201042:	078e                	slli	a5,a5,0x3
ffffffffc0201044:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0201046:	411585bb          	subw	a1,a1,a7
ffffffffc020104a:	cb8c                	sw	a1,16(a5)
ffffffffc020104c:	4689                	li	a3,2
ffffffffc020104e:	00878593          	addi	a1,a5,8
ffffffffc0201052:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201056:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0201058:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc020105c:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc0201060:	e28c                	sd	a1,0(a3)
ffffffffc0201062:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0201064:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0201066:	ef98                	sd	a4,24(a5)
ffffffffc0201068:	4118083b          	subw	a6,a6,a7
ffffffffc020106c:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201070:	57f5                	li	a5,-3
ffffffffc0201072:	00850713          	addi	a4,a0,8
ffffffffc0201076:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc020107a:	8082                	ret
}
ffffffffc020107c:	8082                	ret
        return NULL;
ffffffffc020107e:	4501                	li	a0,0
ffffffffc0201080:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0201082:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201084:	00002697          	auipc	a3,0x2
ffffffffc0201088:	a3c68693          	addi	a3,a3,-1476 # ffffffffc0202ac0 <commands+0x8b0>
ffffffffc020108c:	00002617          	auipc	a2,0x2
ffffffffc0201090:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201094:	06300593          	li	a1,99
ffffffffc0201098:	00002517          	auipc	a0,0x2
ffffffffc020109c:	a4850513          	addi	a0,a0,-1464 # ffffffffc0202ae0 <commands+0x8d0>
best_fit_alloc_pages(size_t n) {
ffffffffc02010a0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02010a2:	8c4ff0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc02010a6 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc02010a6:	715d                	addi	sp,sp,-80
ffffffffc02010a8:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc02010aa:	00006417          	auipc	s0,0x6
ffffffffc02010ae:	f7e40413          	addi	s0,s0,-130 # ffffffffc0207028 <free_area>
ffffffffc02010b2:	641c                	ld	a5,8(s0)
ffffffffc02010b4:	e486                	sd	ra,72(sp)
ffffffffc02010b6:	fc26                	sd	s1,56(sp)
ffffffffc02010b8:	f84a                	sd	s2,48(sp)
ffffffffc02010ba:	f44e                	sd	s3,40(sp)
ffffffffc02010bc:	f052                	sd	s4,32(sp)
ffffffffc02010be:	ec56                	sd	s5,24(sp)
ffffffffc02010c0:	e85a                	sd	s6,16(sp)
ffffffffc02010c2:	e45e                	sd	s7,8(sp)
ffffffffc02010c4:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010c6:	26878b63          	beq	a5,s0,ffffffffc020133c <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc02010ca:	4481                	li	s1,0
ffffffffc02010cc:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02010ce:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02010d2:	8b09                	andi	a4,a4,2
ffffffffc02010d4:	26070863          	beqz	a4,ffffffffc0201344 <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc02010d8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010dc:	679c                	ld	a5,8(a5)
ffffffffc02010de:	2905                	addiw	s2,s2,1
ffffffffc02010e0:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010e2:	fe8796e3          	bne	a5,s0,ffffffffc02010ce <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02010e6:	89a6                	mv	s3,s1
ffffffffc02010e8:	cc3ff0ef          	jal	ra,ffffffffc0200daa <nr_free_pages>
ffffffffc02010ec:	33351c63          	bne	a0,s3,ffffffffc0201424 <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010f0:	4505                	li	a0,1
ffffffffc02010f2:	c3dff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc02010f6:	8a2a                	mv	s4,a0
ffffffffc02010f8:	36050663          	beqz	a0,ffffffffc0201464 <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010fc:	4505                	li	a0,1
ffffffffc02010fe:	c31ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc0201102:	89aa                	mv	s3,a0
ffffffffc0201104:	34050063          	beqz	a0,ffffffffc0201444 <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201108:	4505                	li	a0,1
ffffffffc020110a:	c25ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc020110e:	8aaa                	mv	s5,a0
ffffffffc0201110:	2c050a63          	beqz	a0,ffffffffc02013e4 <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201114:	253a0863          	beq	s4,s3,ffffffffc0201364 <best_fit_check+0x2be>
ffffffffc0201118:	24aa0663          	beq	s4,a0,ffffffffc0201364 <best_fit_check+0x2be>
ffffffffc020111c:	24a98463          	beq	s3,a0,ffffffffc0201364 <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201120:	000a2783          	lw	a5,0(s4)
ffffffffc0201124:	26079063          	bnez	a5,ffffffffc0201384 <best_fit_check+0x2de>
ffffffffc0201128:	0009a783          	lw	a5,0(s3)
ffffffffc020112c:	24079c63          	bnez	a5,ffffffffc0201384 <best_fit_check+0x2de>
ffffffffc0201130:	411c                	lw	a5,0(a0)
ffffffffc0201132:	24079963          	bnez	a5,ffffffffc0201384 <best_fit_check+0x2de>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201136:	00006797          	auipc	a5,0x6
ffffffffc020113a:	33a7b783          	ld	a5,826(a5) # ffffffffc0207470 <pages>
ffffffffc020113e:	40fa0733          	sub	a4,s4,a5
ffffffffc0201142:	870d                	srai	a4,a4,0x3
ffffffffc0201144:	00002597          	auipc	a1,0x2
ffffffffc0201148:	f4c5b583          	ld	a1,-180(a1) # ffffffffc0203090 <nbase+0x8>
ffffffffc020114c:	02b70733          	mul	a4,a4,a1
ffffffffc0201150:	00002617          	auipc	a2,0x2
ffffffffc0201154:	f3863603          	ld	a2,-200(a2) # ffffffffc0203088 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201158:	00006697          	auipc	a3,0x6
ffffffffc020115c:	3106b683          	ld	a3,784(a3) # ffffffffc0207468 <npage>
ffffffffc0201160:	06b2                	slli	a3,a3,0xc
ffffffffc0201162:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201164:	0732                	slli	a4,a4,0xc
ffffffffc0201166:	22d77f63          	bgeu	a4,a3,ffffffffc02013a4 <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020116a:	40f98733          	sub	a4,s3,a5
ffffffffc020116e:	870d                	srai	a4,a4,0x3
ffffffffc0201170:	02b70733          	mul	a4,a4,a1
ffffffffc0201174:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201176:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201178:	3ed77663          	bgeu	a4,a3,ffffffffc0201564 <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020117c:	40f507b3          	sub	a5,a0,a5
ffffffffc0201180:	878d                	srai	a5,a5,0x3
ffffffffc0201182:	02b787b3          	mul	a5,a5,a1
ffffffffc0201186:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201188:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020118a:	3ad7fd63          	bgeu	a5,a3,ffffffffc0201544 <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc020118e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201190:	00043c03          	ld	s8,0(s0)
ffffffffc0201194:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201198:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc020119c:	e400                	sd	s0,8(s0)
ffffffffc020119e:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02011a0:	00006797          	auipc	a5,0x6
ffffffffc02011a4:	e807ac23          	sw	zero,-360(a5) # ffffffffc0207038 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02011a8:	b87ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc02011ac:	36051c63          	bnez	a0,ffffffffc0201524 <best_fit_check+0x47e>
    free_page(p0);
ffffffffc02011b0:	4585                	li	a1,1
ffffffffc02011b2:	8552                	mv	a0,s4
ffffffffc02011b4:	bb9ff0ef          	jal	ra,ffffffffc0200d6c <free_pages>
    free_page(p1);
ffffffffc02011b8:	4585                	li	a1,1
ffffffffc02011ba:	854e                	mv	a0,s3
ffffffffc02011bc:	bb1ff0ef          	jal	ra,ffffffffc0200d6c <free_pages>
    free_page(p2);
ffffffffc02011c0:	4585                	li	a1,1
ffffffffc02011c2:	8556                	mv	a0,s5
ffffffffc02011c4:	ba9ff0ef          	jal	ra,ffffffffc0200d6c <free_pages>
    assert(nr_free == 3);
ffffffffc02011c8:	4818                	lw	a4,16(s0)
ffffffffc02011ca:	478d                	li	a5,3
ffffffffc02011cc:	32f71c63          	bne	a4,a5,ffffffffc0201504 <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011d0:	4505                	li	a0,1
ffffffffc02011d2:	b5dff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc02011d6:	89aa                	mv	s3,a0
ffffffffc02011d8:	30050663          	beqz	a0,ffffffffc02014e4 <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02011dc:	4505                	li	a0,1
ffffffffc02011de:	b51ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc02011e2:	8aaa                	mv	s5,a0
ffffffffc02011e4:	2e050063          	beqz	a0,ffffffffc02014c4 <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02011e8:	4505                	li	a0,1
ffffffffc02011ea:	b45ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc02011ee:	8a2a                	mv	s4,a0
ffffffffc02011f0:	2a050a63          	beqz	a0,ffffffffc02014a4 <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc02011f4:	4505                	li	a0,1
ffffffffc02011f6:	b39ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc02011fa:	28051563          	bnez	a0,ffffffffc0201484 <best_fit_check+0x3de>
    free_page(p0);
ffffffffc02011fe:	4585                	li	a1,1
ffffffffc0201200:	854e                	mv	a0,s3
ffffffffc0201202:	b6bff0ef          	jal	ra,ffffffffc0200d6c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201206:	641c                	ld	a5,8(s0)
ffffffffc0201208:	1a878e63          	beq	a5,s0,ffffffffc02013c4 <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc020120c:	4505                	li	a0,1
ffffffffc020120e:	b21ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc0201212:	52a99963          	bne	s3,a0,ffffffffc0201744 <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc0201216:	4505                	li	a0,1
ffffffffc0201218:	b17ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc020121c:	50051463          	bnez	a0,ffffffffc0201724 <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0201220:	481c                	lw	a5,16(s0)
ffffffffc0201222:	4e079163          	bnez	a5,ffffffffc0201704 <best_fit_check+0x65e>
    free_page(p);
ffffffffc0201226:	854e                	mv	a0,s3
ffffffffc0201228:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020122a:	01843023          	sd	s8,0(s0)
ffffffffc020122e:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0201232:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0201236:	b37ff0ef          	jal	ra,ffffffffc0200d6c <free_pages>
    free_page(p1);
ffffffffc020123a:	4585                	li	a1,1
ffffffffc020123c:	8556                	mv	a0,s5
ffffffffc020123e:	b2fff0ef          	jal	ra,ffffffffc0200d6c <free_pages>
    free_page(p2);
ffffffffc0201242:	4585                	li	a1,1
ffffffffc0201244:	8552                	mv	a0,s4
ffffffffc0201246:	b27ff0ef          	jal	ra,ffffffffc0200d6c <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020124a:	4515                	li	a0,5
ffffffffc020124c:	ae3ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc0201250:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201252:	48050963          	beqz	a0,ffffffffc02016e4 <best_fit_check+0x63e>
ffffffffc0201256:	651c                	ld	a5,8(a0)
ffffffffc0201258:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc020125a:	8b85                	andi	a5,a5,1
ffffffffc020125c:	46079463          	bnez	a5,ffffffffc02016c4 <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201260:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201262:	00043a83          	ld	s5,0(s0)
ffffffffc0201266:	00843a03          	ld	s4,8(s0)
ffffffffc020126a:	e000                	sd	s0,0(s0)
ffffffffc020126c:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc020126e:	ac1ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc0201272:	42051963          	bnez	a0,ffffffffc02016a4 <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0201276:	4589                	li	a1,2
ffffffffc0201278:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc020127c:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0201280:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0201284:	00006797          	auipc	a5,0x6
ffffffffc0201288:	da07aa23          	sw	zero,-588(a5) # ffffffffc0207038 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc020128c:	ae1ff0ef          	jal	ra,ffffffffc0200d6c <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0201290:	8562                	mv	a0,s8
ffffffffc0201292:	4585                	li	a1,1
ffffffffc0201294:	ad9ff0ef          	jal	ra,ffffffffc0200d6c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201298:	4511                	li	a0,4
ffffffffc020129a:	a95ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc020129e:	3e051363          	bnez	a0,ffffffffc0201684 <best_fit_check+0x5de>
ffffffffc02012a2:	0309b783          	ld	a5,48(s3)
ffffffffc02012a6:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc02012a8:	8b85                	andi	a5,a5,1
ffffffffc02012aa:	3a078d63          	beqz	a5,ffffffffc0201664 <best_fit_check+0x5be>
ffffffffc02012ae:	0389a703          	lw	a4,56(s3)
ffffffffc02012b2:	4789                	li	a5,2
ffffffffc02012b4:	3af71863          	bne	a4,a5,ffffffffc0201664 <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc02012b8:	4505                	li	a0,1
ffffffffc02012ba:	a75ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc02012be:	8baa                	mv	s7,a0
ffffffffc02012c0:	38050263          	beqz	a0,ffffffffc0201644 <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc02012c4:	4509                	li	a0,2
ffffffffc02012c6:	a69ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc02012ca:	34050d63          	beqz	a0,ffffffffc0201624 <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc02012ce:	337c1b63          	bne	s8,s7,ffffffffc0201604 <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc02012d2:	854e                	mv	a0,s3
ffffffffc02012d4:	4595                	li	a1,5
ffffffffc02012d6:	a97ff0ef          	jal	ra,ffffffffc0200d6c <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012da:	4515                	li	a0,5
ffffffffc02012dc:	a53ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc02012e0:	89aa                	mv	s3,a0
ffffffffc02012e2:	30050163          	beqz	a0,ffffffffc02015e4 <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc02012e6:	4505                	li	a0,1
ffffffffc02012e8:	a47ff0ef          	jal	ra,ffffffffc0200d2e <alloc_pages>
ffffffffc02012ec:	2c051c63          	bnez	a0,ffffffffc02015c4 <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc02012f0:	481c                	lw	a5,16(s0)
ffffffffc02012f2:	2a079963          	bnez	a5,ffffffffc02015a4 <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02012f6:	4595                	li	a1,5
ffffffffc02012f8:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02012fa:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc02012fe:	01543023          	sd	s5,0(s0)
ffffffffc0201302:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0201306:	a67ff0ef          	jal	ra,ffffffffc0200d6c <free_pages>
    return listelm->next;
ffffffffc020130a:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020130c:	00878963          	beq	a5,s0,ffffffffc020131e <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201310:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201314:	679c                	ld	a5,8(a5)
ffffffffc0201316:	397d                	addiw	s2,s2,-1
ffffffffc0201318:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020131a:	fe879be3          	bne	a5,s0,ffffffffc0201310 <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc020131e:	26091363          	bnez	s2,ffffffffc0201584 <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0201322:	e0ed                	bnez	s1,ffffffffc0201404 <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0201324:	60a6                	ld	ra,72(sp)
ffffffffc0201326:	6406                	ld	s0,64(sp)
ffffffffc0201328:	74e2                	ld	s1,56(sp)
ffffffffc020132a:	7942                	ld	s2,48(sp)
ffffffffc020132c:	79a2                	ld	s3,40(sp)
ffffffffc020132e:	7a02                	ld	s4,32(sp)
ffffffffc0201330:	6ae2                	ld	s5,24(sp)
ffffffffc0201332:	6b42                	ld	s6,16(sp)
ffffffffc0201334:	6ba2                	ld	s7,8(sp)
ffffffffc0201336:	6c02                	ld	s8,0(sp)
ffffffffc0201338:	6161                	addi	sp,sp,80
ffffffffc020133a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020133c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020133e:	4481                	li	s1,0
ffffffffc0201340:	4901                	li	s2,0
ffffffffc0201342:	b35d                	j	ffffffffc02010e8 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0201344:	00001697          	auipc	a3,0x1
ffffffffc0201348:	7b468693          	addi	a3,a3,1972 # ffffffffc0202af8 <commands+0x8e8>
ffffffffc020134c:	00001617          	auipc	a2,0x1
ffffffffc0201350:	77c60613          	addi	a2,a2,1916 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201354:	10700593          	li	a1,263
ffffffffc0201358:	00001517          	auipc	a0,0x1
ffffffffc020135c:	78850513          	addi	a0,a0,1928 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201360:	e07fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201364:	00002697          	auipc	a3,0x2
ffffffffc0201368:	82468693          	addi	a3,a3,-2012 # ffffffffc0202b88 <commands+0x978>
ffffffffc020136c:	00001617          	auipc	a2,0x1
ffffffffc0201370:	75c60613          	addi	a2,a2,1884 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201374:	0d300593          	li	a1,211
ffffffffc0201378:	00001517          	auipc	a0,0x1
ffffffffc020137c:	76850513          	addi	a0,a0,1896 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201380:	de7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201384:	00002697          	auipc	a3,0x2
ffffffffc0201388:	82c68693          	addi	a3,a3,-2004 # ffffffffc0202bb0 <commands+0x9a0>
ffffffffc020138c:	00001617          	auipc	a2,0x1
ffffffffc0201390:	73c60613          	addi	a2,a2,1852 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201394:	0d400593          	li	a1,212
ffffffffc0201398:	00001517          	auipc	a0,0x1
ffffffffc020139c:	74850513          	addi	a0,a0,1864 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02013a0:	dc7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02013a4:	00002697          	auipc	a3,0x2
ffffffffc02013a8:	84c68693          	addi	a3,a3,-1972 # ffffffffc0202bf0 <commands+0x9e0>
ffffffffc02013ac:	00001617          	auipc	a2,0x1
ffffffffc02013b0:	71c60613          	addi	a2,a2,1820 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02013b4:	0d600593          	li	a1,214
ffffffffc02013b8:	00001517          	auipc	a0,0x1
ffffffffc02013bc:	72850513          	addi	a0,a0,1832 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02013c0:	da7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02013c4:	00002697          	auipc	a3,0x2
ffffffffc02013c8:	8b468693          	addi	a3,a3,-1868 # ffffffffc0202c78 <commands+0xa68>
ffffffffc02013cc:	00001617          	auipc	a2,0x1
ffffffffc02013d0:	6fc60613          	addi	a2,a2,1788 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02013d4:	0ef00593          	li	a1,239
ffffffffc02013d8:	00001517          	auipc	a0,0x1
ffffffffc02013dc:	70850513          	addi	a0,a0,1800 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02013e0:	d87fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013e4:	00001697          	auipc	a3,0x1
ffffffffc02013e8:	78468693          	addi	a3,a3,1924 # ffffffffc0202b68 <commands+0x958>
ffffffffc02013ec:	00001617          	auipc	a2,0x1
ffffffffc02013f0:	6dc60613          	addi	a2,a2,1756 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02013f4:	0d100593          	li	a1,209
ffffffffc02013f8:	00001517          	auipc	a0,0x1
ffffffffc02013fc:	6e850513          	addi	a0,a0,1768 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201400:	d67fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(total == 0);
ffffffffc0201404:	00002697          	auipc	a3,0x2
ffffffffc0201408:	9a468693          	addi	a3,a3,-1628 # ffffffffc0202da8 <commands+0xb98>
ffffffffc020140c:	00001617          	auipc	a2,0x1
ffffffffc0201410:	6bc60613          	addi	a2,a2,1724 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201414:	14900593          	li	a1,329
ffffffffc0201418:	00001517          	auipc	a0,0x1
ffffffffc020141c:	6c850513          	addi	a0,a0,1736 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201420:	d47fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201424:	00001697          	auipc	a3,0x1
ffffffffc0201428:	6e468693          	addi	a3,a3,1764 # ffffffffc0202b08 <commands+0x8f8>
ffffffffc020142c:	00001617          	auipc	a2,0x1
ffffffffc0201430:	69c60613          	addi	a2,a2,1692 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201434:	10a00593          	li	a1,266
ffffffffc0201438:	00001517          	auipc	a0,0x1
ffffffffc020143c:	6a850513          	addi	a0,a0,1704 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201440:	d27fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201444:	00001697          	auipc	a3,0x1
ffffffffc0201448:	70468693          	addi	a3,a3,1796 # ffffffffc0202b48 <commands+0x938>
ffffffffc020144c:	00001617          	auipc	a2,0x1
ffffffffc0201450:	67c60613          	addi	a2,a2,1660 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201454:	0d000593          	li	a1,208
ffffffffc0201458:	00001517          	auipc	a0,0x1
ffffffffc020145c:	68850513          	addi	a0,a0,1672 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201460:	d07fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201464:	00001697          	auipc	a3,0x1
ffffffffc0201468:	6c468693          	addi	a3,a3,1732 # ffffffffc0202b28 <commands+0x918>
ffffffffc020146c:	00001617          	auipc	a2,0x1
ffffffffc0201470:	65c60613          	addi	a2,a2,1628 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201474:	0cf00593          	li	a1,207
ffffffffc0201478:	00001517          	auipc	a0,0x1
ffffffffc020147c:	66850513          	addi	a0,a0,1640 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201480:	ce7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201484:	00001697          	auipc	a3,0x1
ffffffffc0201488:	7cc68693          	addi	a3,a3,1996 # ffffffffc0202c50 <commands+0xa40>
ffffffffc020148c:	00001617          	auipc	a2,0x1
ffffffffc0201490:	63c60613          	addi	a2,a2,1596 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201494:	0ec00593          	li	a1,236
ffffffffc0201498:	00001517          	auipc	a0,0x1
ffffffffc020149c:	64850513          	addi	a0,a0,1608 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02014a0:	cc7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014a4:	00001697          	auipc	a3,0x1
ffffffffc02014a8:	6c468693          	addi	a3,a3,1732 # ffffffffc0202b68 <commands+0x958>
ffffffffc02014ac:	00001617          	auipc	a2,0x1
ffffffffc02014b0:	61c60613          	addi	a2,a2,1564 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02014b4:	0ea00593          	li	a1,234
ffffffffc02014b8:	00001517          	auipc	a0,0x1
ffffffffc02014bc:	62850513          	addi	a0,a0,1576 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02014c0:	ca7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02014c4:	00001697          	auipc	a3,0x1
ffffffffc02014c8:	68468693          	addi	a3,a3,1668 # ffffffffc0202b48 <commands+0x938>
ffffffffc02014cc:	00001617          	auipc	a2,0x1
ffffffffc02014d0:	5fc60613          	addi	a2,a2,1532 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02014d4:	0e900593          	li	a1,233
ffffffffc02014d8:	00001517          	auipc	a0,0x1
ffffffffc02014dc:	60850513          	addi	a0,a0,1544 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02014e0:	c87fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02014e4:	00001697          	auipc	a3,0x1
ffffffffc02014e8:	64468693          	addi	a3,a3,1604 # ffffffffc0202b28 <commands+0x918>
ffffffffc02014ec:	00001617          	auipc	a2,0x1
ffffffffc02014f0:	5dc60613          	addi	a2,a2,1500 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02014f4:	0e800593          	li	a1,232
ffffffffc02014f8:	00001517          	auipc	a0,0x1
ffffffffc02014fc:	5e850513          	addi	a0,a0,1512 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201500:	c67fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(nr_free == 3);
ffffffffc0201504:	00001697          	auipc	a3,0x1
ffffffffc0201508:	76468693          	addi	a3,a3,1892 # ffffffffc0202c68 <commands+0xa58>
ffffffffc020150c:	00001617          	auipc	a2,0x1
ffffffffc0201510:	5bc60613          	addi	a2,a2,1468 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201514:	0e600593          	li	a1,230
ffffffffc0201518:	00001517          	auipc	a0,0x1
ffffffffc020151c:	5c850513          	addi	a0,a0,1480 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201520:	c47fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201524:	00001697          	auipc	a3,0x1
ffffffffc0201528:	72c68693          	addi	a3,a3,1836 # ffffffffc0202c50 <commands+0xa40>
ffffffffc020152c:	00001617          	auipc	a2,0x1
ffffffffc0201530:	59c60613          	addi	a2,a2,1436 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201534:	0e100593          	li	a1,225
ffffffffc0201538:	00001517          	auipc	a0,0x1
ffffffffc020153c:	5a850513          	addi	a0,a0,1448 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201540:	c27fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201544:	00001697          	auipc	a3,0x1
ffffffffc0201548:	6ec68693          	addi	a3,a3,1772 # ffffffffc0202c30 <commands+0xa20>
ffffffffc020154c:	00001617          	auipc	a2,0x1
ffffffffc0201550:	57c60613          	addi	a2,a2,1404 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201554:	0d800593          	li	a1,216
ffffffffc0201558:	00001517          	auipc	a0,0x1
ffffffffc020155c:	58850513          	addi	a0,a0,1416 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201560:	c07fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201564:	00001697          	auipc	a3,0x1
ffffffffc0201568:	6ac68693          	addi	a3,a3,1708 # ffffffffc0202c10 <commands+0xa00>
ffffffffc020156c:	00001617          	auipc	a2,0x1
ffffffffc0201570:	55c60613          	addi	a2,a2,1372 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201574:	0d700593          	li	a1,215
ffffffffc0201578:	00001517          	auipc	a0,0x1
ffffffffc020157c:	56850513          	addi	a0,a0,1384 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201580:	be7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(count == 0);
ffffffffc0201584:	00002697          	auipc	a3,0x2
ffffffffc0201588:	81468693          	addi	a3,a3,-2028 # ffffffffc0202d98 <commands+0xb88>
ffffffffc020158c:	00001617          	auipc	a2,0x1
ffffffffc0201590:	53c60613          	addi	a2,a2,1340 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201594:	14800593          	li	a1,328
ffffffffc0201598:	00001517          	auipc	a0,0x1
ffffffffc020159c:	54850513          	addi	a0,a0,1352 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02015a0:	bc7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(nr_free == 0);
ffffffffc02015a4:	00001697          	auipc	a3,0x1
ffffffffc02015a8:	70c68693          	addi	a3,a3,1804 # ffffffffc0202cb0 <commands+0xaa0>
ffffffffc02015ac:	00001617          	auipc	a2,0x1
ffffffffc02015b0:	51c60613          	addi	a2,a2,1308 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02015b4:	13d00593          	li	a1,317
ffffffffc02015b8:	00001517          	auipc	a0,0x1
ffffffffc02015bc:	52850513          	addi	a0,a0,1320 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02015c0:	ba7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015c4:	00001697          	auipc	a3,0x1
ffffffffc02015c8:	68c68693          	addi	a3,a3,1676 # ffffffffc0202c50 <commands+0xa40>
ffffffffc02015cc:	00001617          	auipc	a2,0x1
ffffffffc02015d0:	4fc60613          	addi	a2,a2,1276 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02015d4:	13700593          	li	a1,311
ffffffffc02015d8:	00001517          	auipc	a0,0x1
ffffffffc02015dc:	50850513          	addi	a0,a0,1288 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02015e0:	b87fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015e4:	00001697          	auipc	a3,0x1
ffffffffc02015e8:	79468693          	addi	a3,a3,1940 # ffffffffc0202d78 <commands+0xb68>
ffffffffc02015ec:	00001617          	auipc	a2,0x1
ffffffffc02015f0:	4dc60613          	addi	a2,a2,1244 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02015f4:	13600593          	li	a1,310
ffffffffc02015f8:	00001517          	auipc	a0,0x1
ffffffffc02015fc:	4e850513          	addi	a0,a0,1256 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201600:	b67fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0201604:	00001697          	auipc	a3,0x1
ffffffffc0201608:	76468693          	addi	a3,a3,1892 # ffffffffc0202d68 <commands+0xb58>
ffffffffc020160c:	00001617          	auipc	a2,0x1
ffffffffc0201610:	4bc60613          	addi	a2,a2,1212 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201614:	12e00593          	li	a1,302
ffffffffc0201618:	00001517          	auipc	a0,0x1
ffffffffc020161c:	4c850513          	addi	a0,a0,1224 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201620:	b47fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0201624:	00001697          	auipc	a3,0x1
ffffffffc0201628:	72c68693          	addi	a3,a3,1836 # ffffffffc0202d50 <commands+0xb40>
ffffffffc020162c:	00001617          	auipc	a2,0x1
ffffffffc0201630:	49c60613          	addi	a2,a2,1180 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201634:	12d00593          	li	a1,301
ffffffffc0201638:	00001517          	auipc	a0,0x1
ffffffffc020163c:	4a850513          	addi	a0,a0,1192 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201640:	b27fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0201644:	00001697          	auipc	a3,0x1
ffffffffc0201648:	6ec68693          	addi	a3,a3,1772 # ffffffffc0202d30 <commands+0xb20>
ffffffffc020164c:	00001617          	auipc	a2,0x1
ffffffffc0201650:	47c60613          	addi	a2,a2,1148 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201654:	12c00593          	li	a1,300
ffffffffc0201658:	00001517          	auipc	a0,0x1
ffffffffc020165c:	48850513          	addi	a0,a0,1160 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201660:	b07fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0201664:	00001697          	auipc	a3,0x1
ffffffffc0201668:	69c68693          	addi	a3,a3,1692 # ffffffffc0202d00 <commands+0xaf0>
ffffffffc020166c:	00001617          	auipc	a2,0x1
ffffffffc0201670:	45c60613          	addi	a2,a2,1116 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201674:	12a00593          	li	a1,298
ffffffffc0201678:	00001517          	auipc	a0,0x1
ffffffffc020167c:	46850513          	addi	a0,a0,1128 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201680:	ae7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201684:	00001697          	auipc	a3,0x1
ffffffffc0201688:	66468693          	addi	a3,a3,1636 # ffffffffc0202ce8 <commands+0xad8>
ffffffffc020168c:	00001617          	auipc	a2,0x1
ffffffffc0201690:	43c60613          	addi	a2,a2,1084 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201694:	12900593          	li	a1,297
ffffffffc0201698:	00001517          	auipc	a0,0x1
ffffffffc020169c:	44850513          	addi	a0,a0,1096 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02016a0:	ac7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02016a4:	00001697          	auipc	a3,0x1
ffffffffc02016a8:	5ac68693          	addi	a3,a3,1452 # ffffffffc0202c50 <commands+0xa40>
ffffffffc02016ac:	00001617          	auipc	a2,0x1
ffffffffc02016b0:	41c60613          	addi	a2,a2,1052 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02016b4:	11d00593          	li	a1,285
ffffffffc02016b8:	00001517          	auipc	a0,0x1
ffffffffc02016bc:	42850513          	addi	a0,a0,1064 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02016c0:	aa7fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(!PageProperty(p0));
ffffffffc02016c4:	00001697          	auipc	a3,0x1
ffffffffc02016c8:	60c68693          	addi	a3,a3,1548 # ffffffffc0202cd0 <commands+0xac0>
ffffffffc02016cc:	00001617          	auipc	a2,0x1
ffffffffc02016d0:	3fc60613          	addi	a2,a2,1020 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02016d4:	11400593          	li	a1,276
ffffffffc02016d8:	00001517          	auipc	a0,0x1
ffffffffc02016dc:	40850513          	addi	a0,a0,1032 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02016e0:	a87fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(p0 != NULL);
ffffffffc02016e4:	00001697          	auipc	a3,0x1
ffffffffc02016e8:	5dc68693          	addi	a3,a3,1500 # ffffffffc0202cc0 <commands+0xab0>
ffffffffc02016ec:	00001617          	auipc	a2,0x1
ffffffffc02016f0:	3dc60613          	addi	a2,a2,988 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02016f4:	11300593          	li	a1,275
ffffffffc02016f8:	00001517          	auipc	a0,0x1
ffffffffc02016fc:	3e850513          	addi	a0,a0,1000 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201700:	a67fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(nr_free == 0);
ffffffffc0201704:	00001697          	auipc	a3,0x1
ffffffffc0201708:	5ac68693          	addi	a3,a3,1452 # ffffffffc0202cb0 <commands+0xaa0>
ffffffffc020170c:	00001617          	auipc	a2,0x1
ffffffffc0201710:	3bc60613          	addi	a2,a2,956 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201714:	0f500593          	li	a1,245
ffffffffc0201718:	00001517          	auipc	a0,0x1
ffffffffc020171c:	3c850513          	addi	a0,a0,968 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201720:	a47fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201724:	00001697          	auipc	a3,0x1
ffffffffc0201728:	52c68693          	addi	a3,a3,1324 # ffffffffc0202c50 <commands+0xa40>
ffffffffc020172c:	00001617          	auipc	a2,0x1
ffffffffc0201730:	39c60613          	addi	a2,a2,924 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201734:	0f300593          	li	a1,243
ffffffffc0201738:	00001517          	auipc	a0,0x1
ffffffffc020173c:	3a850513          	addi	a0,a0,936 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201740:	a27fe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201744:	00001697          	auipc	a3,0x1
ffffffffc0201748:	54c68693          	addi	a3,a3,1356 # ffffffffc0202c90 <commands+0xa80>
ffffffffc020174c:	00001617          	auipc	a2,0x1
ffffffffc0201750:	37c60613          	addi	a2,a2,892 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc0201754:	0f200593          	li	a1,242
ffffffffc0201758:	00001517          	auipc	a0,0x1
ffffffffc020175c:	38850513          	addi	a0,a0,904 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc0201760:	a07fe0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc0201764 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201764:	1141                	addi	sp,sp,-16
ffffffffc0201766:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201768:	14058a63          	beqz	a1,ffffffffc02018bc <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020176c:	00259693          	slli	a3,a1,0x2
ffffffffc0201770:	96ae                	add	a3,a3,a1
ffffffffc0201772:	068e                	slli	a3,a3,0x3
ffffffffc0201774:	96aa                	add	a3,a3,a0
ffffffffc0201776:	87aa                	mv	a5,a0
ffffffffc0201778:	02d50263          	beq	a0,a3,ffffffffc020179c <best_fit_free_pages+0x38>
ffffffffc020177c:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020177e:	8b05                	andi	a4,a4,1
ffffffffc0201780:	10071e63          	bnez	a4,ffffffffc020189c <best_fit_free_pages+0x138>
ffffffffc0201784:	6798                	ld	a4,8(a5)
ffffffffc0201786:	8b09                	andi	a4,a4,2
ffffffffc0201788:	10071a63          	bnez	a4,ffffffffc020189c <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc020178c:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201790:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201794:	02878793          	addi	a5,a5,40
ffffffffc0201798:	fed792e3          	bne	a5,a3,ffffffffc020177c <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc020179c:	2581                	sext.w	a1,a1
ffffffffc020179e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02017a0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017a4:	4789                	li	a5,2
ffffffffc02017a6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02017aa:	00006697          	auipc	a3,0x6
ffffffffc02017ae:	87e68693          	addi	a3,a3,-1922 # ffffffffc0207028 <free_area>
ffffffffc02017b2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02017b4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02017b6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02017ba:	9db9                	addw	a1,a1,a4
ffffffffc02017bc:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02017be:	0ad78863          	beq	a5,a3,ffffffffc020186e <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02017c2:	fe878713          	addi	a4,a5,-24
ffffffffc02017c6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02017ca:	4581                	li	a1,0
            if (base < page) {
ffffffffc02017cc:	00e56a63          	bltu	a0,a4,ffffffffc02017e0 <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc02017d0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02017d2:	06d70263          	beq	a4,a3,ffffffffc0201836 <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02017d6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02017d8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02017dc:	fee57ae3          	bgeu	a0,a4,ffffffffc02017d0 <best_fit_free_pages+0x6c>
ffffffffc02017e0:	c199                	beqz	a1,ffffffffc02017e6 <best_fit_free_pages+0x82>
ffffffffc02017e2:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02017e6:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02017e8:	e390                	sd	a2,0(a5)
ffffffffc02017ea:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02017ec:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02017ee:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02017f0:	02d70063          	beq	a4,a3,ffffffffc0201810 <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02017f4:	ff872803          	lw	a6,-8(a4) # fffffffffff7fff8 <end+0x3fd78b58>
        p = le2page(le, page_link);
ffffffffc02017f8:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc02017fc:	02081613          	slli	a2,a6,0x20
ffffffffc0201800:	9201                	srli	a2,a2,0x20
ffffffffc0201802:	00261793          	slli	a5,a2,0x2
ffffffffc0201806:	97b2                	add	a5,a5,a2
ffffffffc0201808:	078e                	slli	a5,a5,0x3
ffffffffc020180a:	97ae                	add	a5,a5,a1
ffffffffc020180c:	02f50f63          	beq	a0,a5,ffffffffc020184a <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc0201810:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0201812:	00d70f63          	beq	a4,a3,ffffffffc0201830 <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201816:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201818:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc020181c:	02059613          	slli	a2,a1,0x20
ffffffffc0201820:	9201                	srli	a2,a2,0x20
ffffffffc0201822:	00261793          	slli	a5,a2,0x2
ffffffffc0201826:	97b2                	add	a5,a5,a2
ffffffffc0201828:	078e                	slli	a5,a5,0x3
ffffffffc020182a:	97aa                	add	a5,a5,a0
ffffffffc020182c:	04f68863          	beq	a3,a5,ffffffffc020187c <best_fit_free_pages+0x118>
}
ffffffffc0201830:	60a2                	ld	ra,8(sp)
ffffffffc0201832:	0141                	addi	sp,sp,16
ffffffffc0201834:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201836:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201838:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020183a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020183c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020183e:	02d70563          	beq	a4,a3,ffffffffc0201868 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201842:	8832                	mv	a6,a2
ffffffffc0201844:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201846:	87ba                	mv	a5,a4
ffffffffc0201848:	bf41                	j	ffffffffc02017d8 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc020184a:	491c                	lw	a5,16(a0)
ffffffffc020184c:	0107883b          	addw	a6,a5,a6
ffffffffc0201850:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201854:	57f5                	li	a5,-3
ffffffffc0201856:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020185a:	6d10                	ld	a2,24(a0)
ffffffffc020185c:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc020185e:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0201860:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201862:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201864:	e390                	sd	a2,0(a5)
ffffffffc0201866:	b775                	j	ffffffffc0201812 <best_fit_free_pages+0xae>
ffffffffc0201868:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020186a:	873e                	mv	a4,a5
ffffffffc020186c:	b761                	j	ffffffffc02017f4 <best_fit_free_pages+0x90>
}
ffffffffc020186e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201870:	e390                	sd	a2,0(a5)
ffffffffc0201872:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201874:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201876:	ed1c                	sd	a5,24(a0)
ffffffffc0201878:	0141                	addi	sp,sp,16
ffffffffc020187a:	8082                	ret
            base->property += p->property;
ffffffffc020187c:	ff872783          	lw	a5,-8(a4)
ffffffffc0201880:	ff070693          	addi	a3,a4,-16
ffffffffc0201884:	9dbd                	addw	a1,a1,a5
ffffffffc0201886:	c90c                	sw	a1,16(a0)
ffffffffc0201888:	57f5                	li	a5,-3
ffffffffc020188a:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020188e:	6314                	ld	a3,0(a4)
ffffffffc0201890:	671c                	ld	a5,8(a4)
}
ffffffffc0201892:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201894:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201896:	e394                	sd	a3,0(a5)
ffffffffc0201898:	0141                	addi	sp,sp,16
ffffffffc020189a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020189c:	00001697          	auipc	a3,0x1
ffffffffc02018a0:	51c68693          	addi	a3,a3,1308 # ffffffffc0202db8 <commands+0xba8>
ffffffffc02018a4:	00001617          	auipc	a2,0x1
ffffffffc02018a8:	22460613          	addi	a2,a2,548 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02018ac:	08e00593          	li	a1,142
ffffffffc02018b0:	00001517          	auipc	a0,0x1
ffffffffc02018b4:	23050513          	addi	a0,a0,560 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02018b8:	8affe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(n > 0);
ffffffffc02018bc:	00001697          	auipc	a3,0x1
ffffffffc02018c0:	20468693          	addi	a3,a3,516 # ffffffffc0202ac0 <commands+0x8b0>
ffffffffc02018c4:	00001617          	auipc	a2,0x1
ffffffffc02018c8:	20460613          	addi	a2,a2,516 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02018cc:	08b00593          	li	a1,139
ffffffffc02018d0:	00001517          	auipc	a0,0x1
ffffffffc02018d4:	21050513          	addi	a0,a0,528 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02018d8:	88ffe0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc02018dc <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02018dc:	1141                	addi	sp,sp,-16
ffffffffc02018de:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018e0:	c9e1                	beqz	a1,ffffffffc02019b0 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc02018e2:	00259693          	slli	a3,a1,0x2
ffffffffc02018e6:	96ae                	add	a3,a3,a1
ffffffffc02018e8:	068e                	slli	a3,a3,0x3
ffffffffc02018ea:	96aa                	add	a3,a3,a0
ffffffffc02018ec:	87aa                	mv	a5,a0
ffffffffc02018ee:	00d50f63          	beq	a0,a3,ffffffffc020190c <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018f2:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02018f4:	8b05                	andi	a4,a4,1
ffffffffc02018f6:	cf49                	beqz	a4,ffffffffc0201990 <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02018f8:	0007a823          	sw	zero,16(a5)
ffffffffc02018fc:	0007b423          	sd	zero,8(a5)
ffffffffc0201900:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201904:	02878793          	addi	a5,a5,40
ffffffffc0201908:	fed795e3          	bne	a5,a3,ffffffffc02018f2 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc020190c:	2581                	sext.w	a1,a1
ffffffffc020190e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201910:	4789                	li	a5,2
ffffffffc0201912:	00850713          	addi	a4,a0,8
ffffffffc0201916:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020191a:	00005697          	auipc	a3,0x5
ffffffffc020191e:	70e68693          	addi	a3,a3,1806 # ffffffffc0207028 <free_area>
ffffffffc0201922:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201924:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201926:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020192a:	9db9                	addw	a1,a1,a4
ffffffffc020192c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020192e:	04d78a63          	beq	a5,a3,ffffffffc0201982 <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201932:	fe878713          	addi	a4,a5,-24
ffffffffc0201936:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020193a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020193c:	00e56a63          	bltu	a0,a4,ffffffffc0201950 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc0201940:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201942:	02d70263          	beq	a4,a3,ffffffffc0201966 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201946:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201948:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020194c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201940 <best_fit_init_memmap+0x64>
ffffffffc0201950:	c199                	beqz	a1,ffffffffc0201956 <best_fit_init_memmap+0x7a>
ffffffffc0201952:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201956:	6398                	ld	a4,0(a5)
}
ffffffffc0201958:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020195a:	e390                	sd	a2,0(a5)
ffffffffc020195c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020195e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201960:	ed18                	sd	a4,24(a0)
ffffffffc0201962:	0141                	addi	sp,sp,16
ffffffffc0201964:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201966:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201968:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020196a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020196c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020196e:	00d70663          	beq	a4,a3,ffffffffc020197a <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc0201972:	8832                	mv	a6,a2
ffffffffc0201974:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201976:	87ba                	mv	a5,a4
ffffffffc0201978:	bfc1                	j	ffffffffc0201948 <best_fit_init_memmap+0x6c>
}
ffffffffc020197a:	60a2                	ld	ra,8(sp)
ffffffffc020197c:	e290                	sd	a2,0(a3)
ffffffffc020197e:	0141                	addi	sp,sp,16
ffffffffc0201980:	8082                	ret
ffffffffc0201982:	60a2                	ld	ra,8(sp)
ffffffffc0201984:	e390                	sd	a2,0(a5)
ffffffffc0201986:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201988:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020198a:	ed1c                	sd	a5,24(a0)
ffffffffc020198c:	0141                	addi	sp,sp,16
ffffffffc020198e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201990:	00001697          	auipc	a3,0x1
ffffffffc0201994:	45068693          	addi	a3,a3,1104 # ffffffffc0202de0 <commands+0xbd0>
ffffffffc0201998:	00001617          	auipc	a2,0x1
ffffffffc020199c:	13060613          	addi	a2,a2,304 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02019a0:	04a00593          	li	a1,74
ffffffffc02019a4:	00001517          	auipc	a0,0x1
ffffffffc02019a8:	13c50513          	addi	a0,a0,316 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02019ac:	fbafe0ef          	jal	ra,ffffffffc0200166 <__panic>
    assert(n > 0);
ffffffffc02019b0:	00001697          	auipc	a3,0x1
ffffffffc02019b4:	11068693          	addi	a3,a3,272 # ffffffffc0202ac0 <commands+0x8b0>
ffffffffc02019b8:	00001617          	auipc	a2,0x1
ffffffffc02019bc:	11060613          	addi	a2,a2,272 # ffffffffc0202ac8 <commands+0x8b8>
ffffffffc02019c0:	04700593          	li	a1,71
ffffffffc02019c4:	00001517          	auipc	a0,0x1
ffffffffc02019c8:	11c50513          	addi	a0,a0,284 # ffffffffc0202ae0 <commands+0x8d0>
ffffffffc02019cc:	f9afe0ef          	jal	ra,ffffffffc0200166 <__panic>

ffffffffc02019d0 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02019d0:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02019d4:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02019d6:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02019d8:	cb81                	beqz	a5,ffffffffc02019e8 <strlen+0x18>
        cnt ++;
ffffffffc02019da:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02019dc:	00a707b3          	add	a5,a4,a0
ffffffffc02019e0:	0007c783          	lbu	a5,0(a5)
ffffffffc02019e4:	fbfd                	bnez	a5,ffffffffc02019da <strlen+0xa>
ffffffffc02019e6:	8082                	ret
    }
    return cnt;
}
ffffffffc02019e8:	8082                	ret

ffffffffc02019ea <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02019ea:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02019ec:	e589                	bnez	a1,ffffffffc02019f6 <strnlen+0xc>
ffffffffc02019ee:	a811                	j	ffffffffc0201a02 <strnlen+0x18>
        cnt ++;
ffffffffc02019f0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02019f2:	00f58863          	beq	a1,a5,ffffffffc0201a02 <strnlen+0x18>
ffffffffc02019f6:	00f50733          	add	a4,a0,a5
ffffffffc02019fa:	00074703          	lbu	a4,0(a4)
ffffffffc02019fe:	fb6d                	bnez	a4,ffffffffc02019f0 <strnlen+0x6>
ffffffffc0201a00:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201a02:	852e                	mv	a0,a1
ffffffffc0201a04:	8082                	ret

ffffffffc0201a06 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a06:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a0a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a0e:	cb89                	beqz	a5,ffffffffc0201a20 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201a10:	0505                	addi	a0,a0,1
ffffffffc0201a12:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a14:	fee789e3          	beq	a5,a4,ffffffffc0201a06 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a18:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a1c:	9d19                	subw	a0,a0,a4
ffffffffc0201a1e:	8082                	ret
ffffffffc0201a20:	4501                	li	a0,0
ffffffffc0201a22:	bfed                	j	ffffffffc0201a1c <strcmp+0x16>

ffffffffc0201a24 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201a24:	c20d                	beqz	a2,ffffffffc0201a46 <strncmp+0x22>
ffffffffc0201a26:	962e                	add	a2,a2,a1
ffffffffc0201a28:	a031                	j	ffffffffc0201a34 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201a2a:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201a2c:	00e79a63          	bne	a5,a4,ffffffffc0201a40 <strncmp+0x1c>
ffffffffc0201a30:	00b60b63          	beq	a2,a1,ffffffffc0201a46 <strncmp+0x22>
ffffffffc0201a34:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201a38:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201a3a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201a3e:	f7f5                	bnez	a5,ffffffffc0201a2a <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a40:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201a44:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a46:	4501                	li	a0,0
ffffffffc0201a48:	8082                	ret

ffffffffc0201a4a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201a4a:	00054783          	lbu	a5,0(a0)
ffffffffc0201a4e:	c799                	beqz	a5,ffffffffc0201a5c <strchr+0x12>
        if (*s == c) {
ffffffffc0201a50:	00f58763          	beq	a1,a5,ffffffffc0201a5e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201a54:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201a58:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201a5a:	fbfd                	bnez	a5,ffffffffc0201a50 <strchr+0x6>
    }
    return NULL;
ffffffffc0201a5c:	4501                	li	a0,0
}
ffffffffc0201a5e:	8082                	ret

ffffffffc0201a60 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201a60:	ca01                	beqz	a2,ffffffffc0201a70 <memset+0x10>
ffffffffc0201a62:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201a64:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201a66:	0785                	addi	a5,a5,1
ffffffffc0201a68:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201a6c:	fec79de3          	bne	a5,a2,ffffffffc0201a66 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201a70:	8082                	ret

ffffffffc0201a72 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0201a72:	ca19                	beqz	a2,ffffffffc0201a88 <memcpy+0x16>
ffffffffc0201a74:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0201a76:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0201a78:	0005c703          	lbu	a4,0(a1)
ffffffffc0201a7c:	0585                	addi	a1,a1,1
ffffffffc0201a7e:	0785                	addi	a5,a5,1
ffffffffc0201a80:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0201a84:	fec59ae3          	bne	a1,a2,ffffffffc0201a78 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0201a88:	8082                	ret

ffffffffc0201a8a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201a8a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201a8e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201a90:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201a94:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201a96:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201a9a:	f022                	sd	s0,32(sp)
ffffffffc0201a9c:	ec26                	sd	s1,24(sp)
ffffffffc0201a9e:	e84a                	sd	s2,16(sp)
ffffffffc0201aa0:	f406                	sd	ra,40(sp)
ffffffffc0201aa2:	e44e                	sd	s3,8(sp)
ffffffffc0201aa4:	84aa                	mv	s1,a0
ffffffffc0201aa6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201aa8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201aac:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201aae:	03067e63          	bgeu	a2,a6,ffffffffc0201aea <printnum+0x60>
ffffffffc0201ab2:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201ab4:	00805763          	blez	s0,ffffffffc0201ac2 <printnum+0x38>
ffffffffc0201ab8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201aba:	85ca                	mv	a1,s2
ffffffffc0201abc:	854e                	mv	a0,s3
ffffffffc0201abe:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201ac0:	fc65                	bnez	s0,ffffffffc0201ab8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201ac2:	1a02                	slli	s4,s4,0x20
ffffffffc0201ac4:	00001797          	auipc	a5,0x1
ffffffffc0201ac8:	37c78793          	addi	a5,a5,892 # ffffffffc0202e40 <best_fit_pmm_manager+0x38>
ffffffffc0201acc:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201ad0:	9a3e                	add	s4,s4,a5
}
ffffffffc0201ad2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201ad4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201ad8:	70a2                	ld	ra,40(sp)
ffffffffc0201ada:	69a2                	ld	s3,8(sp)
ffffffffc0201adc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201ade:	85ca                	mv	a1,s2
ffffffffc0201ae0:	87a6                	mv	a5,s1
}
ffffffffc0201ae2:	6942                	ld	s2,16(sp)
ffffffffc0201ae4:	64e2                	ld	s1,24(sp)
ffffffffc0201ae6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201ae8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201aea:	03065633          	divu	a2,a2,a6
ffffffffc0201aee:	8722                	mv	a4,s0
ffffffffc0201af0:	f9bff0ef          	jal	ra,ffffffffc0201a8a <printnum>
ffffffffc0201af4:	b7f9                	j	ffffffffc0201ac2 <printnum+0x38>

ffffffffc0201af6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201af6:	7119                	addi	sp,sp,-128
ffffffffc0201af8:	f4a6                	sd	s1,104(sp)
ffffffffc0201afa:	f0ca                	sd	s2,96(sp)
ffffffffc0201afc:	ecce                	sd	s3,88(sp)
ffffffffc0201afe:	e8d2                	sd	s4,80(sp)
ffffffffc0201b00:	e4d6                	sd	s5,72(sp)
ffffffffc0201b02:	e0da                	sd	s6,64(sp)
ffffffffc0201b04:	fc5e                	sd	s7,56(sp)
ffffffffc0201b06:	f06a                	sd	s10,32(sp)
ffffffffc0201b08:	fc86                	sd	ra,120(sp)
ffffffffc0201b0a:	f8a2                	sd	s0,112(sp)
ffffffffc0201b0c:	f862                	sd	s8,48(sp)
ffffffffc0201b0e:	f466                	sd	s9,40(sp)
ffffffffc0201b10:	ec6e                	sd	s11,24(sp)
ffffffffc0201b12:	892a                	mv	s2,a0
ffffffffc0201b14:	84ae                	mv	s1,a1
ffffffffc0201b16:	8d32                	mv	s10,a2
ffffffffc0201b18:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201b1a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201b1e:	5b7d                	li	s6,-1
ffffffffc0201b20:	00001a97          	auipc	s5,0x1
ffffffffc0201b24:	354a8a93          	addi	s5,s5,852 # ffffffffc0202e74 <best_fit_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201b28:	00001b97          	auipc	s7,0x1
ffffffffc0201b2c:	528b8b93          	addi	s7,s7,1320 # ffffffffc0203050 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201b30:	000d4503          	lbu	a0,0(s10)
ffffffffc0201b34:	001d0413          	addi	s0,s10,1
ffffffffc0201b38:	01350a63          	beq	a0,s3,ffffffffc0201b4c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201b3c:	c121                	beqz	a0,ffffffffc0201b7c <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201b3e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201b40:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201b42:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201b44:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201b48:	ff351ae3          	bne	a0,s3,ffffffffc0201b3c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b4c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201b50:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201b54:	4c81                	li	s9,0
ffffffffc0201b56:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201b58:	5c7d                	li	s8,-1
ffffffffc0201b5a:	5dfd                	li	s11,-1
ffffffffc0201b5c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201b60:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b62:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201b66:	0ff5f593          	zext.b	a1,a1
ffffffffc0201b6a:	00140d13          	addi	s10,s0,1
ffffffffc0201b6e:	04b56263          	bltu	a0,a1,ffffffffc0201bb2 <vprintfmt+0xbc>
ffffffffc0201b72:	058a                	slli	a1,a1,0x2
ffffffffc0201b74:	95d6                	add	a1,a1,s5
ffffffffc0201b76:	4194                	lw	a3,0(a1)
ffffffffc0201b78:	96d6                	add	a3,a3,s5
ffffffffc0201b7a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201b7c:	70e6                	ld	ra,120(sp)
ffffffffc0201b7e:	7446                	ld	s0,112(sp)
ffffffffc0201b80:	74a6                	ld	s1,104(sp)
ffffffffc0201b82:	7906                	ld	s2,96(sp)
ffffffffc0201b84:	69e6                	ld	s3,88(sp)
ffffffffc0201b86:	6a46                	ld	s4,80(sp)
ffffffffc0201b88:	6aa6                	ld	s5,72(sp)
ffffffffc0201b8a:	6b06                	ld	s6,64(sp)
ffffffffc0201b8c:	7be2                	ld	s7,56(sp)
ffffffffc0201b8e:	7c42                	ld	s8,48(sp)
ffffffffc0201b90:	7ca2                	ld	s9,40(sp)
ffffffffc0201b92:	7d02                	ld	s10,32(sp)
ffffffffc0201b94:	6de2                	ld	s11,24(sp)
ffffffffc0201b96:	6109                	addi	sp,sp,128
ffffffffc0201b98:	8082                	ret
            padc = '0';
ffffffffc0201b9a:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201b9c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ba0:	846a                	mv	s0,s10
ffffffffc0201ba2:	00140d13          	addi	s10,s0,1
ffffffffc0201ba6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201baa:	0ff5f593          	zext.b	a1,a1
ffffffffc0201bae:	fcb572e3          	bgeu	a0,a1,ffffffffc0201b72 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201bb2:	85a6                	mv	a1,s1
ffffffffc0201bb4:	02500513          	li	a0,37
ffffffffc0201bb8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201bba:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201bbe:	8d22                	mv	s10,s0
ffffffffc0201bc0:	f73788e3          	beq	a5,s3,ffffffffc0201b30 <vprintfmt+0x3a>
ffffffffc0201bc4:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201bc8:	1d7d                	addi	s10,s10,-1
ffffffffc0201bca:	ff379de3          	bne	a5,s3,ffffffffc0201bc4 <vprintfmt+0xce>
ffffffffc0201bce:	b78d                	j	ffffffffc0201b30 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201bd0:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201bd4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bd8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201bda:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201bde:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201be2:	02d86463          	bltu	a6,a3,ffffffffc0201c0a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201be6:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201bea:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201bee:	0186873b          	addw	a4,a3,s8
ffffffffc0201bf2:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201bf6:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201bf8:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201bfc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201bfe:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201c02:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201c06:	fed870e3          	bgeu	a6,a3,ffffffffc0201be6 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201c0a:	f40ddce3          	bgez	s11,ffffffffc0201b62 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201c0e:	8de2                	mv	s11,s8
ffffffffc0201c10:	5c7d                	li	s8,-1
ffffffffc0201c12:	bf81                	j	ffffffffc0201b62 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201c14:	fffdc693          	not	a3,s11
ffffffffc0201c18:	96fd                	srai	a3,a3,0x3f
ffffffffc0201c1a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c1e:	00144603          	lbu	a2,1(s0)
ffffffffc0201c22:	2d81                	sext.w	s11,s11
ffffffffc0201c24:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201c26:	bf35                	j	ffffffffc0201b62 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201c28:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c2c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201c30:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c32:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201c34:	bfd9                	j	ffffffffc0201c0a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201c36:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c38:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201c3c:	01174463          	blt	a4,a7,ffffffffc0201c44 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201c40:	1a088e63          	beqz	a7,ffffffffc0201dfc <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201c44:	000a3603          	ld	a2,0(s4)
ffffffffc0201c48:	46c1                	li	a3,16
ffffffffc0201c4a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201c4c:	2781                	sext.w	a5,a5
ffffffffc0201c4e:	876e                	mv	a4,s11
ffffffffc0201c50:	85a6                	mv	a1,s1
ffffffffc0201c52:	854a                	mv	a0,s2
ffffffffc0201c54:	e37ff0ef          	jal	ra,ffffffffc0201a8a <printnum>
            break;
ffffffffc0201c58:	bde1                	j	ffffffffc0201b30 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201c5a:	000a2503          	lw	a0,0(s4)
ffffffffc0201c5e:	85a6                	mv	a1,s1
ffffffffc0201c60:	0a21                	addi	s4,s4,8
ffffffffc0201c62:	9902                	jalr	s2
            break;
ffffffffc0201c64:	b5f1                	j	ffffffffc0201b30 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201c66:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c68:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201c6c:	01174463          	blt	a4,a7,ffffffffc0201c74 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201c70:	18088163          	beqz	a7,ffffffffc0201df2 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201c74:	000a3603          	ld	a2,0(s4)
ffffffffc0201c78:	46a9                	li	a3,10
ffffffffc0201c7a:	8a2e                	mv	s4,a1
ffffffffc0201c7c:	bfc1                	j	ffffffffc0201c4c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c7e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201c82:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c84:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201c86:	bdf1                	j	ffffffffc0201b62 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201c88:	85a6                	mv	a1,s1
ffffffffc0201c8a:	02500513          	li	a0,37
ffffffffc0201c8e:	9902                	jalr	s2
            break;
ffffffffc0201c90:	b545                	j	ffffffffc0201b30 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c92:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201c96:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c98:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201c9a:	b5e1                	j	ffffffffc0201b62 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201c9c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c9e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201ca2:	01174463          	blt	a4,a7,ffffffffc0201caa <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201ca6:	14088163          	beqz	a7,ffffffffc0201de8 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201caa:	000a3603          	ld	a2,0(s4)
ffffffffc0201cae:	46a1                	li	a3,8
ffffffffc0201cb0:	8a2e                	mv	s4,a1
ffffffffc0201cb2:	bf69                	j	ffffffffc0201c4c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201cb4:	03000513          	li	a0,48
ffffffffc0201cb8:	85a6                	mv	a1,s1
ffffffffc0201cba:	e03e                	sd	a5,0(sp)
ffffffffc0201cbc:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201cbe:	85a6                	mv	a1,s1
ffffffffc0201cc0:	07800513          	li	a0,120
ffffffffc0201cc4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201cc6:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201cc8:	6782                	ld	a5,0(sp)
ffffffffc0201cca:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201ccc:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201cd0:	bfb5                	j	ffffffffc0201c4c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201cd2:	000a3403          	ld	s0,0(s4)
ffffffffc0201cd6:	008a0713          	addi	a4,s4,8
ffffffffc0201cda:	e03a                	sd	a4,0(sp)
ffffffffc0201cdc:	14040263          	beqz	s0,ffffffffc0201e20 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201ce0:	0fb05763          	blez	s11,ffffffffc0201dce <vprintfmt+0x2d8>
ffffffffc0201ce4:	02d00693          	li	a3,45
ffffffffc0201ce8:	0cd79163          	bne	a5,a3,ffffffffc0201daa <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201cec:	00044783          	lbu	a5,0(s0)
ffffffffc0201cf0:	0007851b          	sext.w	a0,a5
ffffffffc0201cf4:	cf85                	beqz	a5,ffffffffc0201d2c <vprintfmt+0x236>
ffffffffc0201cf6:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201cfa:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201cfe:	000c4563          	bltz	s8,ffffffffc0201d08 <vprintfmt+0x212>
ffffffffc0201d02:	3c7d                	addiw	s8,s8,-1
ffffffffc0201d04:	036c0263          	beq	s8,s6,ffffffffc0201d28 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201d08:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201d0a:	0e0c8e63          	beqz	s9,ffffffffc0201e06 <vprintfmt+0x310>
ffffffffc0201d0e:	3781                	addiw	a5,a5,-32
ffffffffc0201d10:	0ef47b63          	bgeu	s0,a5,ffffffffc0201e06 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201d14:	03f00513          	li	a0,63
ffffffffc0201d18:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d1a:	000a4783          	lbu	a5,0(s4)
ffffffffc0201d1e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201d20:	0a05                	addi	s4,s4,1
ffffffffc0201d22:	0007851b          	sext.w	a0,a5
ffffffffc0201d26:	ffe1                	bnez	a5,ffffffffc0201cfe <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201d28:	01b05963          	blez	s11,ffffffffc0201d3a <vprintfmt+0x244>
ffffffffc0201d2c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201d2e:	85a6                	mv	a1,s1
ffffffffc0201d30:	02000513          	li	a0,32
ffffffffc0201d34:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201d36:	fe0d9be3          	bnez	s11,ffffffffc0201d2c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201d3a:	6a02                	ld	s4,0(sp)
ffffffffc0201d3c:	bbd5                	j	ffffffffc0201b30 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201d3e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201d40:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201d44:	01174463          	blt	a4,a7,ffffffffc0201d4c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201d48:	08088d63          	beqz	a7,ffffffffc0201de2 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201d4c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201d50:	0a044d63          	bltz	s0,ffffffffc0201e0a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201d54:	8622                	mv	a2,s0
ffffffffc0201d56:	8a66                	mv	s4,s9
ffffffffc0201d58:	46a9                	li	a3,10
ffffffffc0201d5a:	bdcd                	j	ffffffffc0201c4c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201d5c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201d60:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201d62:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201d64:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201d68:	8fb5                	xor	a5,a5,a3
ffffffffc0201d6a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201d6e:	02d74163          	blt	a4,a3,ffffffffc0201d90 <vprintfmt+0x29a>
ffffffffc0201d72:	00369793          	slli	a5,a3,0x3
ffffffffc0201d76:	97de                	add	a5,a5,s7
ffffffffc0201d78:	639c                	ld	a5,0(a5)
ffffffffc0201d7a:	cb99                	beqz	a5,ffffffffc0201d90 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201d7c:	86be                	mv	a3,a5
ffffffffc0201d7e:	00001617          	auipc	a2,0x1
ffffffffc0201d82:	0f260613          	addi	a2,a2,242 # ffffffffc0202e70 <best_fit_pmm_manager+0x68>
ffffffffc0201d86:	85a6                	mv	a1,s1
ffffffffc0201d88:	854a                	mv	a0,s2
ffffffffc0201d8a:	0ce000ef          	jal	ra,ffffffffc0201e58 <printfmt>
ffffffffc0201d8e:	b34d                	j	ffffffffc0201b30 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201d90:	00001617          	auipc	a2,0x1
ffffffffc0201d94:	0d060613          	addi	a2,a2,208 # ffffffffc0202e60 <best_fit_pmm_manager+0x58>
ffffffffc0201d98:	85a6                	mv	a1,s1
ffffffffc0201d9a:	854a                	mv	a0,s2
ffffffffc0201d9c:	0bc000ef          	jal	ra,ffffffffc0201e58 <printfmt>
ffffffffc0201da0:	bb41                	j	ffffffffc0201b30 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201da2:	00001417          	auipc	s0,0x1
ffffffffc0201da6:	0b640413          	addi	s0,s0,182 # ffffffffc0202e58 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201daa:	85e2                	mv	a1,s8
ffffffffc0201dac:	8522                	mv	a0,s0
ffffffffc0201dae:	e43e                	sd	a5,8(sp)
ffffffffc0201db0:	c3bff0ef          	jal	ra,ffffffffc02019ea <strnlen>
ffffffffc0201db4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201db8:	01b05b63          	blez	s11,ffffffffc0201dce <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201dbc:	67a2                	ld	a5,8(sp)
ffffffffc0201dbe:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201dc2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201dc4:	85a6                	mv	a1,s1
ffffffffc0201dc6:	8552                	mv	a0,s4
ffffffffc0201dc8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201dca:	fe0d9ce3          	bnez	s11,ffffffffc0201dc2 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201dce:	00044783          	lbu	a5,0(s0)
ffffffffc0201dd2:	00140a13          	addi	s4,s0,1
ffffffffc0201dd6:	0007851b          	sext.w	a0,a5
ffffffffc0201dda:	d3a5                	beqz	a5,ffffffffc0201d3a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201ddc:	05e00413          	li	s0,94
ffffffffc0201de0:	bf39                	j	ffffffffc0201cfe <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201de2:	000a2403          	lw	s0,0(s4)
ffffffffc0201de6:	b7ad                	j	ffffffffc0201d50 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201de8:	000a6603          	lwu	a2,0(s4)
ffffffffc0201dec:	46a1                	li	a3,8
ffffffffc0201dee:	8a2e                	mv	s4,a1
ffffffffc0201df0:	bdb1                	j	ffffffffc0201c4c <vprintfmt+0x156>
ffffffffc0201df2:	000a6603          	lwu	a2,0(s4)
ffffffffc0201df6:	46a9                	li	a3,10
ffffffffc0201df8:	8a2e                	mv	s4,a1
ffffffffc0201dfa:	bd89                	j	ffffffffc0201c4c <vprintfmt+0x156>
ffffffffc0201dfc:	000a6603          	lwu	a2,0(s4)
ffffffffc0201e00:	46c1                	li	a3,16
ffffffffc0201e02:	8a2e                	mv	s4,a1
ffffffffc0201e04:	b5a1                	j	ffffffffc0201c4c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201e06:	9902                	jalr	s2
ffffffffc0201e08:	bf09                	j	ffffffffc0201d1a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201e0a:	85a6                	mv	a1,s1
ffffffffc0201e0c:	02d00513          	li	a0,45
ffffffffc0201e10:	e03e                	sd	a5,0(sp)
ffffffffc0201e12:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201e14:	6782                	ld	a5,0(sp)
ffffffffc0201e16:	8a66                	mv	s4,s9
ffffffffc0201e18:	40800633          	neg	a2,s0
ffffffffc0201e1c:	46a9                	li	a3,10
ffffffffc0201e1e:	b53d                	j	ffffffffc0201c4c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201e20:	03b05163          	blez	s11,ffffffffc0201e42 <vprintfmt+0x34c>
ffffffffc0201e24:	02d00693          	li	a3,45
ffffffffc0201e28:	f6d79de3          	bne	a5,a3,ffffffffc0201da2 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201e2c:	00001417          	auipc	s0,0x1
ffffffffc0201e30:	02c40413          	addi	s0,s0,44 # ffffffffc0202e58 <best_fit_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201e34:	02800793          	li	a5,40
ffffffffc0201e38:	02800513          	li	a0,40
ffffffffc0201e3c:	00140a13          	addi	s4,s0,1
ffffffffc0201e40:	bd6d                	j	ffffffffc0201cfa <vprintfmt+0x204>
ffffffffc0201e42:	00001a17          	auipc	s4,0x1
ffffffffc0201e46:	017a0a13          	addi	s4,s4,23 # ffffffffc0202e59 <best_fit_pmm_manager+0x51>
ffffffffc0201e4a:	02800513          	li	a0,40
ffffffffc0201e4e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201e52:	05e00413          	li	s0,94
ffffffffc0201e56:	b565                	j	ffffffffc0201cfe <vprintfmt+0x208>

ffffffffc0201e58 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201e58:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201e5a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201e5e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201e60:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201e62:	ec06                	sd	ra,24(sp)
ffffffffc0201e64:	f83a                	sd	a4,48(sp)
ffffffffc0201e66:	fc3e                	sd	a5,56(sp)
ffffffffc0201e68:	e0c2                	sd	a6,64(sp)
ffffffffc0201e6a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201e6c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201e6e:	c89ff0ef          	jal	ra,ffffffffc0201af6 <vprintfmt>
}
ffffffffc0201e72:	60e2                	ld	ra,24(sp)
ffffffffc0201e74:	6161                	addi	sp,sp,80
ffffffffc0201e76:	8082                	ret

ffffffffc0201e78 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201e78:	715d                	addi	sp,sp,-80
ffffffffc0201e7a:	e486                	sd	ra,72(sp)
ffffffffc0201e7c:	e0a6                	sd	s1,64(sp)
ffffffffc0201e7e:	fc4a                	sd	s2,56(sp)
ffffffffc0201e80:	f84e                	sd	s3,48(sp)
ffffffffc0201e82:	f452                	sd	s4,40(sp)
ffffffffc0201e84:	f056                	sd	s5,32(sp)
ffffffffc0201e86:	ec5a                	sd	s6,24(sp)
ffffffffc0201e88:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201e8a:	c901                	beqz	a0,ffffffffc0201e9a <readline+0x22>
ffffffffc0201e8c:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201e8e:	00001517          	auipc	a0,0x1
ffffffffc0201e92:	fe250513          	addi	a0,a0,-30 # ffffffffc0202e70 <best_fit_pmm_manager+0x68>
ffffffffc0201e96:	a48fe0ef          	jal	ra,ffffffffc02000de <cprintf>
readline(const char *prompt) {
ffffffffc0201e9a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201e9c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201e9e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201ea0:	4aa9                	li	s5,10
ffffffffc0201ea2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201ea4:	00005b97          	auipc	s7,0x5
ffffffffc0201ea8:	19cb8b93          	addi	s7,s7,412 # ffffffffc0207040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201eac:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201eb0:	aa6fe0ef          	jal	ra,ffffffffc0200156 <getchar>
        if (c < 0) {
ffffffffc0201eb4:	00054a63          	bltz	a0,ffffffffc0201ec8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201eb8:	00a95a63          	bge	s2,a0,ffffffffc0201ecc <readline+0x54>
ffffffffc0201ebc:	029a5263          	bge	s4,s1,ffffffffc0201ee0 <readline+0x68>
        c = getchar();
ffffffffc0201ec0:	a96fe0ef          	jal	ra,ffffffffc0200156 <getchar>
        if (c < 0) {
ffffffffc0201ec4:	fe055ae3          	bgez	a0,ffffffffc0201eb8 <readline+0x40>
            return NULL;
ffffffffc0201ec8:	4501                	li	a0,0
ffffffffc0201eca:	a091                	j	ffffffffc0201f0e <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201ecc:	03351463          	bne	a0,s3,ffffffffc0201ef4 <readline+0x7c>
ffffffffc0201ed0:	e8a9                	bnez	s1,ffffffffc0201f22 <readline+0xaa>
        c = getchar();
ffffffffc0201ed2:	a84fe0ef          	jal	ra,ffffffffc0200156 <getchar>
        if (c < 0) {
ffffffffc0201ed6:	fe0549e3          	bltz	a0,ffffffffc0201ec8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201eda:	fea959e3          	bge	s2,a0,ffffffffc0201ecc <readline+0x54>
ffffffffc0201ede:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201ee0:	e42a                	sd	a0,8(sp)
ffffffffc0201ee2:	a32fe0ef          	jal	ra,ffffffffc0200114 <cputchar>
            buf[i ++] = c;
ffffffffc0201ee6:	6522                	ld	a0,8(sp)
ffffffffc0201ee8:	009b87b3          	add	a5,s7,s1
ffffffffc0201eec:	2485                	addiw	s1,s1,1
ffffffffc0201eee:	00a78023          	sb	a0,0(a5)
ffffffffc0201ef2:	bf7d                	j	ffffffffc0201eb0 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201ef4:	01550463          	beq	a0,s5,ffffffffc0201efc <readline+0x84>
ffffffffc0201ef8:	fb651ce3          	bne	a0,s6,ffffffffc0201eb0 <readline+0x38>
            cputchar(c);
ffffffffc0201efc:	a18fe0ef          	jal	ra,ffffffffc0200114 <cputchar>
            buf[i] = '\0';
ffffffffc0201f00:	00005517          	auipc	a0,0x5
ffffffffc0201f04:	14050513          	addi	a0,a0,320 # ffffffffc0207040 <buf>
ffffffffc0201f08:	94aa                	add	s1,s1,a0
ffffffffc0201f0a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201f0e:	60a6                	ld	ra,72(sp)
ffffffffc0201f10:	6486                	ld	s1,64(sp)
ffffffffc0201f12:	7962                	ld	s2,56(sp)
ffffffffc0201f14:	79c2                	ld	s3,48(sp)
ffffffffc0201f16:	7a22                	ld	s4,40(sp)
ffffffffc0201f18:	7a82                	ld	s5,32(sp)
ffffffffc0201f1a:	6b62                	ld	s6,24(sp)
ffffffffc0201f1c:	6bc2                	ld	s7,16(sp)
ffffffffc0201f1e:	6161                	addi	sp,sp,80
ffffffffc0201f20:	8082                	ret
            cputchar(c);
ffffffffc0201f22:	4521                	li	a0,8
ffffffffc0201f24:	9f0fe0ef          	jal	ra,ffffffffc0200114 <cputchar>
            i --;
ffffffffc0201f28:	34fd                	addiw	s1,s1,-1
ffffffffc0201f2a:	b759                	j	ffffffffc0201eb0 <readline+0x38>

ffffffffc0201f2c <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201f2c:	4781                	li	a5,0
ffffffffc0201f2e:	00005717          	auipc	a4,0x5
ffffffffc0201f32:	0ea73703          	ld	a4,234(a4) # ffffffffc0207018 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201f36:	88ba                	mv	a7,a4
ffffffffc0201f38:	852a                	mv	a0,a0
ffffffffc0201f3a:	85be                	mv	a1,a5
ffffffffc0201f3c:	863e                	mv	a2,a5
ffffffffc0201f3e:	00000073          	ecall
ffffffffc0201f42:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201f44:	8082                	ret

ffffffffc0201f46 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201f46:	4781                	li	a5,0
ffffffffc0201f48:	00005717          	auipc	a4,0x5
ffffffffc0201f4c:	55073703          	ld	a4,1360(a4) # ffffffffc0207498 <SBI_SET_TIMER>
ffffffffc0201f50:	88ba                	mv	a7,a4
ffffffffc0201f52:	852a                	mv	a0,a0
ffffffffc0201f54:	85be                	mv	a1,a5
ffffffffc0201f56:	863e                	mv	a2,a5
ffffffffc0201f58:	00000073          	ecall
ffffffffc0201f5c:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201f5e:	8082                	ret

ffffffffc0201f60 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201f60:	4501                	li	a0,0
ffffffffc0201f62:	00005797          	auipc	a5,0x5
ffffffffc0201f66:	0ae7b783          	ld	a5,174(a5) # ffffffffc0207010 <SBI_CONSOLE_GETCHAR>
ffffffffc0201f6a:	88be                	mv	a7,a5
ffffffffc0201f6c:	852a                	mv	a0,a0
ffffffffc0201f6e:	85aa                	mv	a1,a0
ffffffffc0201f70:	862a                	mv	a2,a0
ffffffffc0201f72:	00000073          	ecall
ffffffffc0201f76:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201f78:	2501                	sext.w	a0,a0
ffffffffc0201f7a:	8082                	ret

ffffffffc0201f7c <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201f7c:	4781                	li	a5,0
ffffffffc0201f7e:	00005717          	auipc	a4,0x5
ffffffffc0201f82:	0a273703          	ld	a4,162(a4) # ffffffffc0207020 <SBI_SHUTDOWN>
ffffffffc0201f86:	88ba                	mv	a7,a4
ffffffffc0201f88:	853e                	mv	a0,a5
ffffffffc0201f8a:	85be                	mv	a1,a5
ffffffffc0201f8c:	863e                	mv	a2,a5
ffffffffc0201f8e:	00000073          	ecall
ffffffffc0201f92:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
	sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0201f94:	8082                	ret
