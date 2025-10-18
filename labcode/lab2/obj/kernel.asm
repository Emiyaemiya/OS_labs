
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
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	0d828293          	addi	t0,t0,216 # ffffffffc02000d8 <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020004a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[];
    cprintf("Special kernel symbols:\n");
ffffffffc020004c:	00001517          	auipc	a0,0x1
ffffffffc0200050:	6ac50513          	addi	a0,a0,1708 # ffffffffc02016f8 <etext+0x2>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00001517          	auipc	a0,0x1
ffffffffc0200066:	6b650513          	addi	a0,a0,1718 # ffffffffc0201718 <etext+0x22>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00001597          	auipc	a1,0x1
ffffffffc0200072:	68858593          	addi	a1,a1,1672 # ffffffffc02016f6 <etext>
ffffffffc0200076:	00001517          	auipc	a0,0x1
ffffffffc020007a:	6c250513          	addi	a0,a0,1730 # ffffffffc0201738 <etext+0x42>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <kmalloc_caches>
ffffffffc020008a:	00001517          	auipc	a0,0x1
ffffffffc020008e:	6ce50513          	addi	a0,a0,1742 # ffffffffc0201758 <etext+0x62>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00006597          	auipc	a1,0x6
ffffffffc020009a:	38258593          	addi	a1,a1,898 # ffffffffc0206418 <end>
ffffffffc020009e:	00001517          	auipc	a0,0x1
ffffffffc02000a2:	6da50513          	addi	a0,a0,1754 # ffffffffc0201778 <etext+0x82>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00006597          	auipc	a1,0x6
ffffffffc02000ae:	76d58593          	addi	a1,a1,1901 # ffffffffc0206817 <end+0x3ff>
ffffffffc02000b2:	00000797          	auipc	a5,0x0
ffffffffc02000b6:	02678793          	addi	a5,a5,38 # ffffffffc02000d8 <kern_init>
ffffffffc02000ba:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000be:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000c2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000c4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c8:	95be                	add	a1,a1,a5
ffffffffc02000ca:	85a9                	srai	a1,a1,0xa
ffffffffc02000cc:	00001517          	auipc	a0,0x1
ffffffffc02000d0:	6cc50513          	addi	a0,a0,1740 # ffffffffc0201798 <etext+0xa2>
}
ffffffffc02000d4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d8:	00006517          	auipc	a0,0x6
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0206018 <kmalloc_caches>
ffffffffc02000e0:	00006617          	auipc	a2,0x6
ffffffffc02000e4:	33860613          	addi	a2,a2,824 # ffffffffc0206418 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	1ec010ef          	jal	ra,ffffffffc02012dc <memset>
    dtb_init();
ffffffffc02000f4:	122000ef          	jal	ra,ffffffffc0200216 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	4ce000ef          	jal	ra,ffffffffc02005c6 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00001517          	auipc	a0,0x1
ffffffffc0200100:	6cc50513          	addi	a0,a0,1740 # ffffffffc02017c8 <etext+0xd2>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	4dc000ef          	jal	ra,ffffffffc02005e8 <pmm_init>

    /* do nothing */
    while (1)
ffffffffc0200110:	a001                	j	ffffffffc0200110 <kern_init+0x38>

ffffffffc0200112 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200112:	1141                	addi	sp,sp,-16
ffffffffc0200114:	e022                	sd	s0,0(sp)
ffffffffc0200116:	e406                	sd	ra,8(sp)
ffffffffc0200118:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020011a:	4ae000ef          	jal	ra,ffffffffc02005c8 <cons_putc>
    (*cnt) ++;
ffffffffc020011e:	401c                	lw	a5,0(s0)
}
ffffffffc0200120:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200122:	2785                	addiw	a5,a5,1
ffffffffc0200124:	c01c                	sw	a5,0(s0)
}
ffffffffc0200126:	6402                	ld	s0,0(sp)
ffffffffc0200128:	0141                	addi	sp,sp,16
ffffffffc020012a:	8082                	ret

ffffffffc020012c <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020012c:	1101                	addi	sp,sp,-32
ffffffffc020012e:	862a                	mv	a2,a0
ffffffffc0200130:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200132:	00000517          	auipc	a0,0x0
ffffffffc0200136:	fe050513          	addi	a0,a0,-32 # ffffffffc0200112 <cputch>
ffffffffc020013a:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc020013c:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020013e:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200140:	21a010ef          	jal	ra,ffffffffc020135a <vprintfmt>
    return cnt;
}
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	4532                	lw	a0,12(sp)
ffffffffc0200148:	6105                	addi	sp,sp,32
ffffffffc020014a:	8082                	ret

ffffffffc020014c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020014c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200152:	8e2a                	mv	t3,a0
ffffffffc0200154:	f42e                	sd	a1,40(sp)
ffffffffc0200156:	f832                	sd	a2,48(sp)
ffffffffc0200158:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb850513          	addi	a0,a0,-72 # ffffffffc0200112 <cputch>
ffffffffc0200162:	004c                	addi	a1,sp,4
ffffffffc0200164:	869a                	mv	a3,t1
ffffffffc0200166:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc0200168:	ec06                	sd	ra,24(sp)
ffffffffc020016a:	e0ba                	sd	a4,64(sp)
ffffffffc020016c:	e4be                	sd	a5,72(sp)
ffffffffc020016e:	e8c2                	sd	a6,80(sp)
ffffffffc0200170:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200172:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200174:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200176:	1e4010ef          	jal	ra,ffffffffc020135a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020017a:	60e2                	ld	ra,24(sp)
ffffffffc020017c:	4512                	lw	a0,4(sp)
ffffffffc020017e:	6125                	addi	sp,sp,96
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200182:	1101                	addi	sp,sp,-32
ffffffffc0200184:	e822                	sd	s0,16(sp)
ffffffffc0200186:	ec06                	sd	ra,24(sp)
ffffffffc0200188:	e426                	sd	s1,8(sp)
ffffffffc020018a:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020018c:	00054503          	lbu	a0,0(a0)
ffffffffc0200190:	c51d                	beqz	a0,ffffffffc02001be <cputs+0x3c>
ffffffffc0200192:	0405                	addi	s0,s0,1
ffffffffc0200194:	4485                	li	s1,1
ffffffffc0200196:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200198:	430000ef          	jal	ra,ffffffffc02005c8 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020019c:	00044503          	lbu	a0,0(s0)
ffffffffc02001a0:	008487bb          	addw	a5,s1,s0
ffffffffc02001a4:	0405                	addi	s0,s0,1
ffffffffc02001a6:	f96d                	bnez	a0,ffffffffc0200198 <cputs+0x16>
    (*cnt) ++;
ffffffffc02001a8:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001ac:	4529                	li	a0,10
ffffffffc02001ae:	41a000ef          	jal	ra,ffffffffc02005c8 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	8522                	mv	a0,s0
ffffffffc02001b6:	6442                	ld	s0,16(sp)
ffffffffc02001b8:	64a2                	ld	s1,8(sp)
ffffffffc02001ba:	6105                	addi	sp,sp,32
ffffffffc02001bc:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001be:	4405                	li	s0,1
ffffffffc02001c0:	b7f5                	j	ffffffffc02001ac <cputs+0x2a>

ffffffffc02001c2 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c2:	00006317          	auipc	t1,0x6
ffffffffc02001c6:	1f630313          	addi	t1,t1,502 # ffffffffc02063b8 <is_panic>
ffffffffc02001ca:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001ce:	715d                	addi	sp,sp,-80
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001de:	000e0363          	beqz	t3,ffffffffc02001e4 <__panic+0x22>
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    while (1) {
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x20>
    is_panic = 1;
ffffffffc02001e4:	4785                	li	a5,1
ffffffffc02001e6:	00f32023          	sw	a5,0(t1)
    va_start(ap, fmt);
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001ee:	862e                	mv	a2,a1
ffffffffc02001f0:	85aa                	mv	a1,a0
ffffffffc02001f2:	00001517          	auipc	a0,0x1
ffffffffc02001f6:	5f650513          	addi	a0,a0,1526 # ffffffffc02017e8 <etext+0xf2>
    va_start(ap, fmt);
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
    cprintf("\n");
ffffffffc0200208:	00002517          	auipc	a0,0x2
ffffffffc020020c:	c7850513          	addi	a0,a0,-904 # ffffffffc0201e80 <kmalloc_sizes+0x378>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200216:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200218:	00001517          	auipc	a0,0x1
ffffffffc020021c:	5f050513          	addi	a0,a0,1520 # ffffffffc0201808 <etext+0x112>
void dtb_init(void) {
ffffffffc0200220:	fc86                	sd	ra,120(sp)
ffffffffc0200222:	f8a2                	sd	s0,112(sp)
ffffffffc0200224:	e8d2                	sd	s4,80(sp)
ffffffffc0200226:	f4a6                	sd	s1,104(sp)
ffffffffc0200228:	f0ca                	sd	s2,96(sp)
ffffffffc020022a:	ecce                	sd	s3,88(sp)
ffffffffc020022c:	e4d6                	sd	s5,72(sp)
ffffffffc020022e:	e0da                	sd	s6,64(sp)
ffffffffc0200230:	fc5e                	sd	s7,56(sp)
ffffffffc0200232:	f862                	sd	s8,48(sp)
ffffffffc0200234:	f466                	sd	s9,40(sp)
ffffffffc0200236:	f06a                	sd	s10,32(sp)
ffffffffc0200238:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc020023a:	f13ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc020023e:	00006597          	auipc	a1,0x6
ffffffffc0200242:	dc25b583          	ld	a1,-574(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200246:	00001517          	auipc	a0,0x1
ffffffffc020024a:	5d250513          	addi	a0,a0,1490 # ffffffffc0201818 <etext+0x122>
ffffffffc020024e:	effff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200252:	00006417          	auipc	s0,0x6
ffffffffc0200256:	db640413          	addi	s0,s0,-586 # ffffffffc0206008 <boot_dtb>
ffffffffc020025a:	600c                	ld	a1,0(s0)
ffffffffc020025c:	00001517          	auipc	a0,0x1
ffffffffc0200260:	5cc50513          	addi	a0,a0,1484 # ffffffffc0201828 <etext+0x132>
ffffffffc0200264:	ee9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200268:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020026c:	00001517          	auipc	a0,0x1
ffffffffc0200270:	5d450513          	addi	a0,a0,1492 # ffffffffc0201840 <etext+0x14a>
    if (boot_dtb == 0) {
ffffffffc0200274:	120a0463          	beqz	s4,ffffffffc020039c <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200278:	57f5                	li	a5,-3
ffffffffc020027a:	07fa                	slli	a5,a5,0x1e
ffffffffc020027c:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200280:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200282:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200286:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200288:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020028c:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200290:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200294:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200298:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020029c:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020029e:	8ec9                	or	a3,a3,a0
ffffffffc02002a0:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002a4:	1b7d                	addi	s6,s6,-1
ffffffffc02002a6:	0167f7b3          	and	a5,a5,s6
ffffffffc02002aa:	8dd5                	or	a1,a1,a3
ffffffffc02002ac:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02002ae:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002b2:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02002b4:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed9ad5>
ffffffffc02002b8:	10f59163          	bne	a1,a5,ffffffffc02003ba <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02002bc:	471c                	lw	a5,8(a4)
ffffffffc02002be:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02002c0:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002c2:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02002c6:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02002ca:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ce:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002d2:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002d6:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002da:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002de:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002e2:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e6:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002ea:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ec:	01146433          	or	s0,s0,a7
ffffffffc02002f0:	0086969b          	slliw	a3,a3,0x8
ffffffffc02002f4:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002f8:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002fa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002fe:	8c49                	or	s0,s0,a0
ffffffffc0200300:	0166f6b3          	and	a3,a3,s6
ffffffffc0200304:	00ca6a33          	or	s4,s4,a2
ffffffffc0200308:	0167f7b3          	and	a5,a5,s6
ffffffffc020030c:	8c55                	or	s0,s0,a3
ffffffffc020030e:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200312:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200314:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200316:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200318:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020031c:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020031e:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200320:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc0200324:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200326:	00001917          	auipc	s2,0x1
ffffffffc020032a:	56a90913          	addi	s2,s2,1386 # ffffffffc0201890 <etext+0x19a>
ffffffffc020032e:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200330:	4d91                	li	s11,4
ffffffffc0200332:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200334:	00001497          	auipc	s1,0x1
ffffffffc0200338:	55448493          	addi	s1,s1,1364 # ffffffffc0201888 <etext+0x192>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020033c:	000a2703          	lw	a4,0(s4)
ffffffffc0200340:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200344:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200348:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020034c:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200350:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200354:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200358:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020035a:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020035e:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200362:	8fd5                	or	a5,a5,a3
ffffffffc0200364:	00eb7733          	and	a4,s6,a4
ffffffffc0200368:	8fd9                	or	a5,a5,a4
ffffffffc020036a:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc020036c:	09778c63          	beq	a5,s7,ffffffffc0200404 <dtb_init+0x1ee>
ffffffffc0200370:	00fbea63          	bltu	s7,a5,ffffffffc0200384 <dtb_init+0x16e>
ffffffffc0200374:	07a78663          	beq	a5,s10,ffffffffc02003e0 <dtb_init+0x1ca>
ffffffffc0200378:	4709                	li	a4,2
ffffffffc020037a:	00e79763          	bne	a5,a4,ffffffffc0200388 <dtb_init+0x172>
ffffffffc020037e:	4c81                	li	s9,0
ffffffffc0200380:	8a56                	mv	s4,s5
ffffffffc0200382:	bf6d                	j	ffffffffc020033c <dtb_init+0x126>
ffffffffc0200384:	ffb78ee3          	beq	a5,s11,ffffffffc0200380 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200388:	00001517          	auipc	a0,0x1
ffffffffc020038c:	58050513          	addi	a0,a0,1408 # ffffffffc0201908 <etext+0x212>
ffffffffc0200390:	dbdff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200394:	00001517          	auipc	a0,0x1
ffffffffc0200398:	5ac50513          	addi	a0,a0,1452 # ffffffffc0201940 <etext+0x24a>
}
ffffffffc020039c:	7446                	ld	s0,112(sp)
ffffffffc020039e:	70e6                	ld	ra,120(sp)
ffffffffc02003a0:	74a6                	ld	s1,104(sp)
ffffffffc02003a2:	7906                	ld	s2,96(sp)
ffffffffc02003a4:	69e6                	ld	s3,88(sp)
ffffffffc02003a6:	6a46                	ld	s4,80(sp)
ffffffffc02003a8:	6aa6                	ld	s5,72(sp)
ffffffffc02003aa:	6b06                	ld	s6,64(sp)
ffffffffc02003ac:	7be2                	ld	s7,56(sp)
ffffffffc02003ae:	7c42                	ld	s8,48(sp)
ffffffffc02003b0:	7ca2                	ld	s9,40(sp)
ffffffffc02003b2:	7d02                	ld	s10,32(sp)
ffffffffc02003b4:	6de2                	ld	s11,24(sp)
ffffffffc02003b6:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02003b8:	bb51                	j	ffffffffc020014c <cprintf>
}
ffffffffc02003ba:	7446                	ld	s0,112(sp)
ffffffffc02003bc:	70e6                	ld	ra,120(sp)
ffffffffc02003be:	74a6                	ld	s1,104(sp)
ffffffffc02003c0:	7906                	ld	s2,96(sp)
ffffffffc02003c2:	69e6                	ld	s3,88(sp)
ffffffffc02003c4:	6a46                	ld	s4,80(sp)
ffffffffc02003c6:	6aa6                	ld	s5,72(sp)
ffffffffc02003c8:	6b06                	ld	s6,64(sp)
ffffffffc02003ca:	7be2                	ld	s7,56(sp)
ffffffffc02003cc:	7c42                	ld	s8,48(sp)
ffffffffc02003ce:	7ca2                	ld	s9,40(sp)
ffffffffc02003d0:	7d02                	ld	s10,32(sp)
ffffffffc02003d2:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003d4:	00001517          	auipc	a0,0x1
ffffffffc02003d8:	48c50513          	addi	a0,a0,1164 # ffffffffc0201860 <etext+0x16a>
}
ffffffffc02003dc:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003de:	b3bd                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003e0:	8556                	mv	a0,s5
ffffffffc02003e2:	681000ef          	jal	ra,ffffffffc0201262 <strlen>
ffffffffc02003e6:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e8:	4619                	li	a2,6
ffffffffc02003ea:	85a6                	mv	a1,s1
ffffffffc02003ec:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003ee:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f0:	6c7000ef          	jal	ra,ffffffffc02012b6 <strncmp>
ffffffffc02003f4:	e111                	bnez	a0,ffffffffc02003f8 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc02003f6:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003f8:	0a91                	addi	s5,s5,4
ffffffffc02003fa:	9ad2                	add	s5,s5,s4
ffffffffc02003fc:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200400:	8a56                	mv	s4,s5
ffffffffc0200402:	bf2d                	j	ffffffffc020033c <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200404:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200408:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020040c:	0087d71b          	srliw	a4,a5,0x8
ffffffffc0200410:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200414:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200418:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020041c:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200420:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200424:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200428:	0087979b          	slliw	a5,a5,0x8
ffffffffc020042c:	00eaeab3          	or	s5,s5,a4
ffffffffc0200430:	00fb77b3          	and	a5,s6,a5
ffffffffc0200434:	00faeab3          	or	s5,s5,a5
ffffffffc0200438:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020043a:	000c9c63          	bnez	s9,ffffffffc0200452 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc020043e:	1a82                	slli	s5,s5,0x20
ffffffffc0200440:	00368793          	addi	a5,a3,3
ffffffffc0200444:	020ada93          	srli	s5,s5,0x20
ffffffffc0200448:	9abe                	add	s5,s5,a5
ffffffffc020044a:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020044e:	8a56                	mv	s4,s5
ffffffffc0200450:	b5f5                	j	ffffffffc020033c <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200452:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200456:	85ca                	mv	a1,s2
ffffffffc0200458:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020045a:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020045e:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200462:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200466:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020046a:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020046e:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200470:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200474:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200478:	8d59                	or	a0,a0,a4
ffffffffc020047a:	00fb77b3          	and	a5,s6,a5
ffffffffc020047e:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200480:	1502                	slli	a0,a0,0x20
ffffffffc0200482:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200484:	9522                	add	a0,a0,s0
ffffffffc0200486:	613000ef          	jal	ra,ffffffffc0201298 <strcmp>
ffffffffc020048a:	66a2                	ld	a3,8(sp)
ffffffffc020048c:	f94d                	bnez	a0,ffffffffc020043e <dtb_init+0x228>
ffffffffc020048e:	fb59f8e3          	bgeu	s3,s5,ffffffffc020043e <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200492:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200496:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020049a:	00001517          	auipc	a0,0x1
ffffffffc020049e:	3fe50513          	addi	a0,a0,1022 # ffffffffc0201898 <etext+0x1a2>
           fdt32_to_cpu(x >> 32);
ffffffffc02004a2:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004a6:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02004aa:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ae:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02004b2:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b6:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ba:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004be:	0187d693          	srli	a3,a5,0x18
ffffffffc02004c2:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02004c6:	0087579b          	srliw	a5,a4,0x8
ffffffffc02004ca:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ce:	0106561b          	srliw	a2,a2,0x10
ffffffffc02004d2:	010f6f33          	or	t5,t5,a6
ffffffffc02004d6:	0187529b          	srliw	t0,a4,0x18
ffffffffc02004da:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004de:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004e2:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004e6:	0186f6b3          	and	a3,a3,s8
ffffffffc02004ea:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02004ee:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004f2:	0107581b          	srliw	a6,a4,0x10
ffffffffc02004f6:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004fa:	8361                	srli	a4,a4,0x18
ffffffffc02004fc:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200500:	0105d59b          	srliw	a1,a1,0x10
ffffffffc0200504:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200508:	00cb7633          	and	a2,s6,a2
ffffffffc020050c:	0088181b          	slliw	a6,a6,0x8
ffffffffc0200510:	0085959b          	slliw	a1,a1,0x8
ffffffffc0200514:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200518:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020051c:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200520:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200524:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200528:	011b78b3          	and	a7,s6,a7
ffffffffc020052c:	005eeeb3          	or	t4,t4,t0
ffffffffc0200530:	00c6e733          	or	a4,a3,a2
ffffffffc0200534:	006c6c33          	or	s8,s8,t1
ffffffffc0200538:	010b76b3          	and	a3,s6,a6
ffffffffc020053c:	00bb7b33          	and	s6,s6,a1
ffffffffc0200540:	01d7e7b3          	or	a5,a5,t4
ffffffffc0200544:	016c6b33          	or	s6,s8,s6
ffffffffc0200548:	01146433          	or	s0,s0,a7
ffffffffc020054c:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc020054e:	1702                	slli	a4,a4,0x20
ffffffffc0200550:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200552:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200554:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200556:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200558:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020055c:	0167eb33          	or	s6,a5,s6
ffffffffc0200560:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200562:	bebff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200566:	85a2                	mv	a1,s0
ffffffffc0200568:	00001517          	auipc	a0,0x1
ffffffffc020056c:	35050513          	addi	a0,a0,848 # ffffffffc02018b8 <etext+0x1c2>
ffffffffc0200570:	bddff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200574:	014b5613          	srli	a2,s6,0x14
ffffffffc0200578:	85da                	mv	a1,s6
ffffffffc020057a:	00001517          	auipc	a0,0x1
ffffffffc020057e:	35650513          	addi	a0,a0,854 # ffffffffc02018d0 <etext+0x1da>
ffffffffc0200582:	bcbff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200586:	008b05b3          	add	a1,s6,s0
ffffffffc020058a:	15fd                	addi	a1,a1,-1
ffffffffc020058c:	00001517          	auipc	a0,0x1
ffffffffc0200590:	36450513          	addi	a0,a0,868 # ffffffffc02018f0 <etext+0x1fa>
ffffffffc0200594:	bb9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	3a850513          	addi	a0,a0,936 # ffffffffc0201940 <etext+0x24a>
        memory_base = mem_base;
ffffffffc02005a0:	00006797          	auipc	a5,0x6
ffffffffc02005a4:	e287b023          	sd	s0,-480(a5) # ffffffffc02063c0 <memory_base>
        memory_size = mem_size;
ffffffffc02005a8:	00006797          	auipc	a5,0x6
ffffffffc02005ac:	e367b023          	sd	s6,-480(a5) # ffffffffc02063c8 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005b0:	b3f5                	j	ffffffffc020039c <dtb_init+0x186>

ffffffffc02005b2 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005b2:	00006517          	auipc	a0,0x6
ffffffffc02005b6:	e0e53503          	ld	a0,-498(a0) # ffffffffc02063c0 <memory_base>
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005bc:	00006517          	auipc	a0,0x6
ffffffffc02005c0:	e0c53503          	ld	a0,-500(a0) # ffffffffc02063c8 <memory_size>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005c6:	8082                	ret

ffffffffc02005c8 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc02005c8:	0ff57513          	zext.b	a0,a0
ffffffffc02005cc:	1100106f          	j	ffffffffc02016dc <sbi_console_putchar>

ffffffffc02005d0 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc02005d0:	00006797          	auipc	a5,0x6
ffffffffc02005d4:	e107b783          	ld	a5,-496(a5) # ffffffffc02063e0 <pmm_manager>
ffffffffc02005d8:	6f9c                	ld	a5,24(a5)
ffffffffc02005da:	8782                	jr	a5

ffffffffc02005dc <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc02005dc:	00006797          	auipc	a5,0x6
ffffffffc02005e0:	e047b783          	ld	a5,-508(a5) # ffffffffc02063e0 <pmm_manager>
ffffffffc02005e4:	739c                	ld	a5,32(a5)
ffffffffc02005e6:	8782                	jr	a5

ffffffffc02005e8 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc02005e8:	00002797          	auipc	a5,0x2
ffffffffc02005ec:	8e878793          	addi	a5,a5,-1816 # ffffffffc0201ed0 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005f0:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02005f2:	7179                	addi	sp,sp,-48
ffffffffc02005f4:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005f6:	00001517          	auipc	a0,0x1
ffffffffc02005fa:	36250513          	addi	a0,a0,866 # ffffffffc0201958 <etext+0x262>
    pmm_manager = &buddy_pmm_manager;
ffffffffc02005fe:	00006417          	auipc	s0,0x6
ffffffffc0200602:	de240413          	addi	s0,s0,-542 # ffffffffc02063e0 <pmm_manager>
void pmm_init(void) {
ffffffffc0200606:	f406                	sd	ra,40(sp)
ffffffffc0200608:	ec26                	sd	s1,24(sp)
ffffffffc020060a:	e44e                	sd	s3,8(sp)
ffffffffc020060c:	e84a                	sd	s2,16(sp)
ffffffffc020060e:	e052                	sd	s4,0(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200610:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200612:	b3bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0200616:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200618:	00006497          	auipc	s1,0x6
ffffffffc020061c:	de048493          	addi	s1,s1,-544 # ffffffffc02063f8 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200620:	679c                	ld	a5,8(a5)
ffffffffc0200622:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200624:	57f5                	li	a5,-3
ffffffffc0200626:	07fa                	slli	a5,a5,0x1e
ffffffffc0200628:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc020062a:	f89ff0ef          	jal	ra,ffffffffc02005b2 <get_memory_base>
ffffffffc020062e:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200630:	f8dff0ef          	jal	ra,ffffffffc02005bc <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200634:	14050e63          	beqz	a0,ffffffffc0200790 <pmm_init+0x1a8>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200638:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc020063a:	00001517          	auipc	a0,0x1
ffffffffc020063e:	36650513          	addi	a0,a0,870 # ffffffffc02019a0 <etext+0x2aa>
ffffffffc0200642:	b0bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200646:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020064a:	864e                	mv	a2,s3
ffffffffc020064c:	fffa0693          	addi	a3,s4,-1
ffffffffc0200650:	85ca                	mv	a1,s2
ffffffffc0200652:	00001517          	auipc	a0,0x1
ffffffffc0200656:	36650513          	addi	a0,a0,870 # ffffffffc02019b8 <etext+0x2c2>
ffffffffc020065a:	af3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020065e:	c80007b7          	lui	a5,0xc8000
ffffffffc0200662:	8652                	mv	a2,s4
ffffffffc0200664:	0d47e563          	bltu	a5,s4,ffffffffc020072e <pmm_init+0x146>
ffffffffc0200668:	00007797          	auipc	a5,0x7
ffffffffc020066c:	daf78793          	addi	a5,a5,-593 # ffffffffc0207417 <end+0xfff>
ffffffffc0200670:	757d                	lui	a0,0xfffff
ffffffffc0200672:	8d7d                	and	a0,a0,a5
ffffffffc0200674:	8231                	srli	a2,a2,0xc
ffffffffc0200676:	00006797          	auipc	a5,0x6
ffffffffc020067a:	d4c7bd23          	sd	a2,-678(a5) # ffffffffc02063d0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020067e:	00006797          	auipc	a5,0x6
ffffffffc0200682:	d4a7bd23          	sd	a0,-678(a5) # ffffffffc02063d8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200686:	000807b7          	lui	a5,0x80
ffffffffc020068a:	002005b7          	lui	a1,0x200
ffffffffc020068e:	02f60563          	beq	a2,a5,ffffffffc02006b8 <pmm_init+0xd0>
ffffffffc0200692:	00261593          	slli	a1,a2,0x2
ffffffffc0200696:	00c586b3          	add	a3,a1,a2
ffffffffc020069a:	fec007b7          	lui	a5,0xfec00
ffffffffc020069e:	97aa                	add	a5,a5,a0
ffffffffc02006a0:	068e                	slli	a3,a3,0x3
ffffffffc02006a2:	96be                	add	a3,a3,a5
ffffffffc02006a4:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc02006a6:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02006a8:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f9c10>
        SetPageReserved(pages + i);
ffffffffc02006ac:	00176713          	ori	a4,a4,1
ffffffffc02006b0:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02006b4:	fef699e3          	bne	a3,a5,ffffffffc02006a6 <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006b8:	95b2                	add	a1,a1,a2
ffffffffc02006ba:	fec006b7          	lui	a3,0xfec00
ffffffffc02006be:	96aa                	add	a3,a3,a0
ffffffffc02006c0:	058e                	slli	a1,a1,0x3
ffffffffc02006c2:	96ae                	add	a3,a3,a1
ffffffffc02006c4:	c02007b7          	lui	a5,0xc0200
ffffffffc02006c8:	0af6e863          	bltu	a3,a5,ffffffffc0200778 <pmm_init+0x190>
ffffffffc02006cc:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02006ce:	77fd                	lui	a5,0xfffff
ffffffffc02006d0:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006d4:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02006d6:	04b6ef63          	bltu	a3,a1,ffffffffc0200734 <pmm_init+0x14c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02006da:	601c                	ld	a5,0(s0)
ffffffffc02006dc:	7b9c                	ld	a5,48(a5)
ffffffffc02006de:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	36050513          	addi	a0,a0,864 # ffffffffc0201a40 <etext+0x34a>
ffffffffc02006e8:	a65ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    slub_check();
ffffffffc02006ec:	280000ef          	jal	ra,ffffffffc020096c <slub_check>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02006f0:	00005597          	auipc	a1,0x5
ffffffffc02006f4:	91058593          	addi	a1,a1,-1776 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02006f8:	00006797          	auipc	a5,0x6
ffffffffc02006fc:	ceb7bc23          	sd	a1,-776(a5) # ffffffffc02063f0 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200700:	c02007b7          	lui	a5,0xc0200
ffffffffc0200704:	0af5e263          	bltu	a1,a5,ffffffffc02007a8 <pmm_init+0x1c0>
ffffffffc0200708:	6090                	ld	a2,0(s1)
}
ffffffffc020070a:	7402                	ld	s0,32(sp)
ffffffffc020070c:	70a2                	ld	ra,40(sp)
ffffffffc020070e:	64e2                	ld	s1,24(sp)
ffffffffc0200710:	6942                	ld	s2,16(sp)
ffffffffc0200712:	69a2                	ld	s3,8(sp)
ffffffffc0200714:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200716:	40c58633          	sub	a2,a1,a2
ffffffffc020071a:	00006797          	auipc	a5,0x6
ffffffffc020071e:	ccc7b723          	sd	a2,-818(a5) # ffffffffc02063e8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200722:	00001517          	auipc	a0,0x1
ffffffffc0200726:	33e50513          	addi	a0,a0,830 # ffffffffc0201a60 <etext+0x36a>
}
ffffffffc020072a:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020072c:	b405                	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020072e:	c8000637          	lui	a2,0xc8000
ffffffffc0200732:	bf1d                	j	ffffffffc0200668 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200734:	6705                	lui	a4,0x1
ffffffffc0200736:	177d                	addi	a4,a4,-1
ffffffffc0200738:	96ba                	add	a3,a3,a4
ffffffffc020073a:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020073c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200740:	02c7f063          	bgeu	a5,a2,ffffffffc0200760 <pmm_init+0x178>
    pmm_manager->init_memmap(base, n);
ffffffffc0200744:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200746:	fff80737          	lui	a4,0xfff80
ffffffffc020074a:	973e                	add	a4,a4,a5
ffffffffc020074c:	00271793          	slli	a5,a4,0x2
ffffffffc0200750:	97ba                	add	a5,a5,a4
ffffffffc0200752:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200754:	8d95                	sub	a1,a1,a3
ffffffffc0200756:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200758:	81b1                	srli	a1,a1,0xc
ffffffffc020075a:	953e                	add	a0,a0,a5
ffffffffc020075c:	9702                	jalr	a4
}
ffffffffc020075e:	bfb5                	j	ffffffffc02006da <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc0200760:	00001617          	auipc	a2,0x1
ffffffffc0200764:	2b060613          	addi	a2,a2,688 # ffffffffc0201a10 <etext+0x31a>
ffffffffc0200768:	06800593          	li	a1,104
ffffffffc020076c:	00001517          	auipc	a0,0x1
ffffffffc0200770:	2c450513          	addi	a0,a0,708 # ffffffffc0201a30 <etext+0x33a>
ffffffffc0200774:	a4fff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200778:	00001617          	auipc	a2,0x1
ffffffffc020077c:	27060613          	addi	a2,a2,624 # ffffffffc02019e8 <etext+0x2f2>
ffffffffc0200780:	06000593          	li	a1,96
ffffffffc0200784:	00001517          	auipc	a0,0x1
ffffffffc0200788:	20c50513          	addi	a0,a0,524 # ffffffffc0201990 <etext+0x29a>
ffffffffc020078c:	a37ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc0200790:	00001617          	auipc	a2,0x1
ffffffffc0200794:	1e060613          	addi	a2,a2,480 # ffffffffc0201970 <etext+0x27a>
ffffffffc0200798:	04800593          	li	a1,72
ffffffffc020079c:	00001517          	auipc	a0,0x1
ffffffffc02007a0:	1f450513          	addi	a0,a0,500 # ffffffffc0201990 <etext+0x29a>
ffffffffc02007a4:	a1fff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02007a8:	86ae                	mv	a3,a1
ffffffffc02007aa:	00001617          	auipc	a2,0x1
ffffffffc02007ae:	23e60613          	addi	a2,a2,574 # ffffffffc02019e8 <etext+0x2f2>
ffffffffc02007b2:	07b00593          	li	a1,123
ffffffffc02007b6:	00001517          	auipc	a0,0x1
ffffffffc02007ba:	1da50513          	addi	a0,a0,474 # ffffffffc0201990 <etext+0x29a>
ffffffffc02007be:	a05ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02007c2 <__cache_alloc>:

// -------------------------
// SLUB 内部分配接口
// -------------------------

void *__cache_alloc(struct kmem_cache *cache) {
ffffffffc02007c2:	1101                	addi	sp,sp,-32
ffffffffc02007c4:	e426                	sd	s1,8(sp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc02007c6:	7104                	ld	s1,32(a0)
ffffffffc02007c8:	e822                	sd	s0,16(sp)
ffffffffc02007ca:	ec06                	sd	ra,24(sp)
    struct slab *slab = NULL;

    // 若有未满的 slab，直接使用
    if (!list_empty(&cache->slabs_partial)) {
ffffffffc02007cc:	01850793          	addi	a5,a0,24
void *__cache_alloc(struct kmem_cache *cache) {
ffffffffc02007d0:	842a                	mv	s0,a0
    if (!list_empty(&cache->slabs_partial)) {
ffffffffc02007d2:	04f48363          	beq	s1,a5,ffffffffc0200818 <__cache_alloc+0x56>
    }

    // 从 free_list 中取出一个对象
    struct list_entry *obj = list_prev(&slab->free_list);
    list_del(obj);
    slab->inuse++;
ffffffffc02007d6:	fe84b783          	ld	a5,-24(s1)

    // slab 已满则移入 full 链表
    if (slab->inuse == cache->objs_per_slab) {
ffffffffc02007da:	690c                	ld	a1,16(a0)
    return (struct slab*)((char*)le - offsetof(struct slab, list_link));
ffffffffc02007dc:	fd848693          	addi	a3,s1,-40
    slab->inuse++;
ffffffffc02007e0:	0785                	addi	a5,a5,1
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc02007e2:	6e88                	ld	a0,24(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02007e4:	6110                	ld	a2,0(a0)
ffffffffc02007e6:	6518                	ld	a4,8(a0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02007e8:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02007ea:	e310                	sd	a2,0(a4)
ffffffffc02007ec:	ea9c                	sd	a5,16(a3)
    if (slab->inuse == cache->objs_per_slab) {
ffffffffc02007ee:	02b79063          	bne	a5,a1,ffffffffc020080e <__cache_alloc+0x4c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02007f2:	768c                	ld	a1,40(a3)
ffffffffc02007f4:	7a90                	ld	a2,48(a3)
        list_del(&slab->list_link);
        list_add(&cache->slabs_full, &slab->list_link);
ffffffffc02007f6:	02868713          	addi	a4,a3,40 # fffffffffec00028 <end+0x3e9f9c10>
ffffffffc02007fa:	02840813          	addi	a6,s0,40
    prev->next = next;
ffffffffc02007fe:	e590                	sd	a2,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200800:	781c                	ld	a5,48(s0)
    next->prev = prev;
ffffffffc0200802:	e20c                	sd	a1,0(a2)
    prev->next = next->prev = elm;
ffffffffc0200804:	e398                	sd	a4,0(a5)
ffffffffc0200806:	f818                	sd	a4,48(s0)
    elm->next = next;
ffffffffc0200808:	fa9c                	sd	a5,48(a3)
    elm->prev = prev;
ffffffffc020080a:	0306b423          	sd	a6,40(a3)
    }

    return (void*)obj;
}
ffffffffc020080e:	60e2                	ld	ra,24(sp)
ffffffffc0200810:	6442                	ld	s0,16(sp)
ffffffffc0200812:	64a2                	ld	s1,8(sp)
ffffffffc0200814:	6105                	addi	sp,sp,32
ffffffffc0200816:	8082                	ret
        struct Page *page = alloc_pages(1);
ffffffffc0200818:	4505                	li	a0,1
ffffffffc020081a:	db7ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
        if (!page) return NULL;
ffffffffc020081e:	d965                	beqz	a0,ffffffffc020080e <__cache_alloc+0x4c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200820:	00006697          	auipc	a3,0x6
ffffffffc0200824:	bb86b683          	ld	a3,-1096(a3) # ffffffffc02063d8 <pages>
ffffffffc0200828:	40d506b3          	sub	a3,a0,a3
ffffffffc020082c:	00002797          	auipc	a5,0x2
ffffffffc0200830:	92c7b783          	ld	a5,-1748(a5) # ffffffffc0202158 <nbase+0x8>
ffffffffc0200834:	868d                	srai	a3,a3,0x3
ffffffffc0200836:	02f686b3          	mul	a3,a3,a5
ffffffffc020083a:	00002797          	auipc	a5,0x2
ffffffffc020083e:	9167b783          	ld	a5,-1770(a5) # ffffffffc0202150 <nbase>
        struct slab *ns = (struct slab*)KADDR(page2pa(page));
ffffffffc0200842:	00006717          	auipc	a4,0x6
ffffffffc0200846:	b8e73703          	ld	a4,-1138(a4) # ffffffffc02063d0 <npage>
ffffffffc020084a:	96be                	add	a3,a3,a5
ffffffffc020084c:	00c69793          	slli	a5,a3,0xc
ffffffffc0200850:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200852:	06b2                	slli	a3,a3,0xc
ffffffffc0200854:	04e7fc63          	bgeu	a5,a4,ffffffffc02008ac <__cache_alloc+0xea>
ffffffffc0200858:	00006797          	auipc	a5,0x6
ffffffffc020085c:	ba07b783          	ld	a5,-1120(a5) # ffffffffc02063f8 <va_pa_offset>
ffffffffc0200860:	96be                	add	a3,a3,a5
        for (size_t i = 0; i < cache->objs_per_slab; i++) {
ffffffffc0200862:	680c                	ld	a1,16(s0)
        list_init(&ns->free_list);
ffffffffc0200864:	01868813          	addi	a6,a3,24
        ns->cache = cache;
ffffffffc0200868:	e280                	sd	s0,0(a3)
        ns->page = page;
ffffffffc020086a:	e688                	sd	a0,8(a3)
        ns->inuse = 0;
ffffffffc020086c:	0006b823          	sd	zero,16(a3)
    elm->prev = elm->next = elm;
ffffffffc0200870:	0306b023          	sd	a6,32(a3)
ffffffffc0200874:	0106bc23          	sd	a6,24(a3)
        for (size_t i = 0; i < cache->objs_per_slab; i++) {
ffffffffc0200878:	c18d                	beqz	a1,ffffffffc020089a <__cache_alloc+0xd8>
            struct list_entry *le = (struct list_entry*)(obj_base + i * cache->obj_size);
ffffffffc020087a:	6408                	ld	a0,8(s0)
ffffffffc020087c:	03868793          	addi	a5,a3,56
ffffffffc0200880:	8642                	mv	a2,a6
        for (size_t i = 0; i < cache->objs_per_slab; i++) {
ffffffffc0200882:	4701                	li	a4,0
ffffffffc0200884:	a011                	j	ffffffffc0200888 <__cache_alloc+0xc6>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200886:	7290                	ld	a2,32(a3)
    prev->next = next->prev = elm;
ffffffffc0200888:	e21c                	sd	a5,0(a2)
ffffffffc020088a:	f29c                	sd	a5,32(a3)
    elm->next = next;
ffffffffc020088c:	e790                	sd	a2,8(a5)
    elm->prev = prev;
ffffffffc020088e:	0107b023          	sd	a6,0(a5)
ffffffffc0200892:	0705                	addi	a4,a4,1
ffffffffc0200894:	97aa                	add	a5,a5,a0
ffffffffc0200896:	feb718e3          	bne	a4,a1,ffffffffc0200886 <__cache_alloc+0xc4>
    __list_add(elm, listelm, listelm->next);
ffffffffc020089a:	7010                	ld	a2,32(s0)
        list_add(&cache->slabs_partial, &ns->list_link);
ffffffffc020089c:	02868713          	addi	a4,a3,40
    elm->prev = prev;
ffffffffc02008a0:	4785                	li	a5,1
    prev->next = next->prev = elm;
ffffffffc02008a2:	e218                	sd	a4,0(a2)
ffffffffc02008a4:	f018                	sd	a4,32(s0)
    elm->next = next;
ffffffffc02008a6:	fa90                	sd	a2,48(a3)
    elm->prev = prev;
ffffffffc02008a8:	f684                	sd	s1,40(a3)
        slab = ns;
ffffffffc02008aa:	bf25                	j	ffffffffc02007e2 <__cache_alloc+0x20>
        struct slab *ns = (struct slab*)KADDR(page2pa(page));
ffffffffc02008ac:	00001617          	auipc	a2,0x1
ffffffffc02008b0:	1f460613          	addi	a2,a2,500 # ffffffffc0201aa0 <etext+0x3aa>
ffffffffc02008b4:	04000593          	li	a1,64
ffffffffc02008b8:	00001517          	auipc	a0,0x1
ffffffffc02008bc:	21050513          	addi	a0,a0,528 # ffffffffc0201ac8 <etext+0x3d2>
ffffffffc02008c0:	903ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02008c4 <__cache_free>:

void __cache_free(struct kmem_cache *cache, void *obj) {
    struct slab *slab = (struct slab*)((uintptr_t)obj & ~(PGSIZE - 1));
ffffffffc02008c4:	77fd                	lui	a5,0xfffff
ffffffffc02008c6:	8fed                	and	a5,a5,a1
    __list_add(elm, listelm, listelm->next);
ffffffffc02008c8:	7398                	ld	a4,32(a5)
    list_add(&slab->free_list, (struct list_entry*)obj);
    slab->inuse--;
ffffffffc02008ca:	6b94                	ld	a3,16(a5)

    // slab 从 full 变为 partial
    if (slab->inuse + 1 == cache->objs_per_slab) {
ffffffffc02008cc:	6910                	ld	a2,16(a0)
    prev->next = next->prev = elm;
ffffffffc02008ce:	e30c                	sd	a1,0(a4)
ffffffffc02008d0:	f38c                	sd	a1,32(a5)
    list_add(&slab->free_list, (struct list_entry*)obj);
ffffffffc02008d2:	01878813          	addi	a6,a5,24 # fffffffffffff018 <end+0x3fdf8c00>
    elm->next = next;
ffffffffc02008d6:	e598                	sd	a4,8(a1)
    elm->prev = prev;
ffffffffc02008d8:	0105b023          	sd	a6,0(a1)
    slab->inuse--;
ffffffffc02008dc:	fff68713          	addi	a4,a3,-1
ffffffffc02008e0:	eb98                	sd	a4,16(a5)
    if (slab->inuse + 1 == cache->objs_per_slab) {
ffffffffc02008e2:	00c68463          	beq	a3,a2,ffffffffc02008ea <__cache_free+0x26>
        list_add(&cache->slabs_partial, &slab->list_link);
    }

    // 目前实现：slab 空了，释放整页

    if (slab->inuse == 0) {
ffffffffc02008e6:	c705                	beqz	a4,ffffffffc020090e <__cache_free+0x4a>

        // // 否则将其放入 partial 链表，等未来重用
        // list_del(&slab->list_link);
        // list_add(&cache->slabs_partial, &slab->list_link);
    }
}
ffffffffc02008e8:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc02008ea:	0287b803          	ld	a6,40(a5)
ffffffffc02008ee:	7b8c                	ld	a1,48(a5)
        list_add(&cache->slabs_partial, &slab->list_link);
ffffffffc02008f0:	02878693          	addi	a3,a5,40
ffffffffc02008f4:	01850893          	addi	a7,a0,24
    prev->next = next;
ffffffffc02008f8:	00b83423          	sd	a1,8(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008fc:	7110                	ld	a2,32(a0)
    next->prev = prev;
ffffffffc02008fe:	0105b023          	sd	a6,0(a1)
    prev->next = next->prev = elm;
ffffffffc0200902:	e214                	sd	a3,0(a2)
ffffffffc0200904:	f114                	sd	a3,32(a0)
    elm->next = next;
ffffffffc0200906:	fb90                	sd	a2,48(a5)
    elm->prev = prev;
ffffffffc0200908:	0317b423          	sd	a7,40(a5)
    if (slab->inuse == 0) {
ffffffffc020090c:	ff71                	bnez	a4,ffffffffc02008e8 <__cache_free+0x24>
    __list_del(listelm->prev, listelm->next);
ffffffffc020090e:	7794                	ld	a3,40(a5)
ffffffffc0200910:	7b98                	ld	a4,48(a5)
        free_pages(slab->page, 1);
ffffffffc0200912:	6788                	ld	a0,8(a5)
ffffffffc0200914:	4585                	li	a1,1
    prev->next = next;
ffffffffc0200916:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200918:	e314                	sd	a3,0(a4)
ffffffffc020091a:	b1c9                	j	ffffffffc02005dc <free_pages>

ffffffffc020091c <slub_init>:
    return usable / obj_size;
ffffffffc020091c:	6505                	lui	a0,0x1
ffffffffc020091e:	00005797          	auipc	a5,0x5
ffffffffc0200922:	71278793          	addi	a5,a5,1810 # ffffffffc0206030 <kmalloc_caches+0x18>
ffffffffc0200926:	00001697          	auipc	a3,0x1
ffffffffc020092a:	1e268693          	addi	a3,a3,482 # ffffffffc0201b08 <kmalloc_sizes>
ffffffffc020092e:	00006817          	auipc	a6,0x6
ffffffffc0200932:	8c280813          	addi	a6,a6,-1854 # ffffffffc02061f0 <free_areas+0x18>
            return i;
    }
    return NUM_KMALLOC_CLASSES - 1; // 默认取最大1024字节类
}

void slub_init(void) {
ffffffffc0200936:	4721                	li	a4,8
    return usable / obj_size;
ffffffffc0200938:	fc850513          	addi	a0,a0,-56 # fc8 <kern_entry-0xffffffffc01ff038>
ffffffffc020093c:	a011                	j	ffffffffc0200940 <slub_init+0x24>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
        size_t s = ALIGN_UP(kmalloc_sizes[i], sizeof(void*));
ffffffffc020093e:	6298                	ld	a4,0(a3)
ffffffffc0200940:	071d                	addi	a4,a4,7
ffffffffc0200942:	9b61                	andi	a4,a4,-8
    return usable / obj_size;
ffffffffc0200944:	02e555b3          	divu	a1,a0,a4
ffffffffc0200948:	01078613          	addi	a2,a5,16
        kmalloc_caches[i].name = NULL;
ffffffffc020094c:	fe07b423          	sd	zero,-24(a5)
        kmalloc_caches[i].obj_size = s;
ffffffffc0200950:	fee7b823          	sd	a4,-16(a5)
    elm->prev = elm->next = elm;
ffffffffc0200954:	e79c                	sd	a5,8(a5)
ffffffffc0200956:	e39c                	sd	a5,0(a5)
ffffffffc0200958:	ef90                	sd	a2,24(a5)
ffffffffc020095a:	eb90                	sd	a2,16(a5)
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc020095c:	03878793          	addi	a5,a5,56
ffffffffc0200960:	06a1                	addi	a3,a3,8
        kmalloc_caches[i].objs_per_slab = slab_objs_per_slab(s);
ffffffffc0200962:	fcb7b023          	sd	a1,-64(a5)
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200966:	fd079ce3          	bne	a5,a6,ffffffffc020093e <slub_init+0x22>
        list_init(&kmalloc_caches[i].slabs_partial);
        list_init(&kmalloc_caches[i].slabs_full);
    }
}
ffffffffc020096a:	8082                	ret

ffffffffc020096c <slub_check>:

// -------------------------
// 测试函数
// -------------------------

void slub_check(void) {
ffffffffc020096c:	7179                	addi	sp,sp,-48
ffffffffc020096e:	f022                	sd	s0,32(sp)
ffffffffc0200970:	e44e                	sd	s3,8(sp)
ffffffffc0200972:	00005417          	auipc	s0,0x5
ffffffffc0200976:	6a640413          	addi	s0,s0,1702 # ffffffffc0206018 <kmalloc_caches>
ffffffffc020097a:	f406                	sd	ra,40(sp)
ffffffffc020097c:	ec26                	sd	s1,24(sp)
ffffffffc020097e:	e84a                	sd	s2,16(sp)
    slub_init();
ffffffffc0200980:	f9dff0ef          	jal	ra,ffffffffc020091c <slub_init>
ffffffffc0200984:	89a2                	mv	s3,s0
ffffffffc0200986:	87a2                	mv	a5,s0
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200988:	4701                	li	a4,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc020098a:	467d                	li	a2,31
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc020098c:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc020098e:	6794                	ld	a3,8(a5)
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200990:	03878793          	addi	a5,a5,56
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200994:	0cd66063          	bltu	a2,a3,ffffffffc0200a54 <slub_check+0xe8>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200998:	2705                	addiw	a4,a4,1
ffffffffc020099a:	feb71ae3          	bne	a4,a1,ffffffffc020098e <slub_check+0x22>
ffffffffc020099e:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc02009a2:	954e                	add	a0,a0,s3
ffffffffc02009a4:	e1fff0ef          	jal	ra,ffffffffc02007c2 <__cache_alloc>
ffffffffc02009a8:	00005997          	auipc	s3,0x5
ffffffffc02009ac:	67098993          	addi	s3,s3,1648 # ffffffffc0206018 <kmalloc_caches>
ffffffffc02009b0:	892a                	mv	s2,a0
ffffffffc02009b2:	87ce                	mv	a5,s3
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009b4:	4701                	li	a4,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009b6:	03f00613          	li	a2,63
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009ba:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009bc:	6794                	ld	a3,8(a5)
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009be:	03878793          	addi	a5,a5,56
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009c2:	0ad66763          	bltu	a2,a3,ffffffffc0200a70 <slub_check+0x104>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009c6:	2705                	addiw	a4,a4,1
ffffffffc02009c8:	feb71ae3          	bne	a4,a1,ffffffffc02009bc <slub_check+0x50>
ffffffffc02009cc:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc02009d0:	954e                	add	a0,a0,s3
ffffffffc02009d2:	df1ff0ef          	jal	ra,ffffffffc02007c2 <__cache_alloc>
ffffffffc02009d6:	84aa                	mv	s1,a0
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009d8:	4781                	li	a5,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009da:	07f00693          	li	a3,127
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009de:	4621                	li	a2,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009e0:	6418                	ld	a4,8(s0)
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009e2:	03840413          	addi	s0,s0,56
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009e6:	06e6ee63          	bltu	a3,a4,ffffffffc0200a62 <slub_check+0xf6>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009ea:	2785                	addiw	a5,a5,1
ffffffffc02009ec:	fec79ae3          	bne	a5,a2,ffffffffc02009e0 <slub_check+0x74>
ffffffffc02009f0:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc02009f4:	954e                	add	a0,a0,s3
ffffffffc02009f6:	dcdff0ef          	jal	ra,ffffffffc02007c2 <__cache_alloc>
ffffffffc02009fa:	842a                	mv	s0,a0

    void *p1 = kmalloc_bytes(32);
    void *p2 = kmalloc_bytes(64);
    void *p3 = kmalloc_bytes(128);

    cprintf("p1=%p, p2=%p, p3=%p\n", p1, p2, p3);
ffffffffc02009fc:	86aa                	mv	a3,a0
ffffffffc02009fe:	8626                	mv	a2,s1
ffffffffc0200a00:	85ca                	mv	a1,s2
ffffffffc0200a02:	00001517          	auipc	a0,0x1
ffffffffc0200a06:	0d650513          	addi	a0,a0,214 # ffffffffc0201ad8 <etext+0x3e2>
ffffffffc0200a0a:	f42ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    if (!ptr) return;
ffffffffc0200a0e:	00090963          	beqz	s2,ffffffffc0200a20 <slub_check+0xb4>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200a12:	77fd                	lui	a5,0xfffff
ffffffffc0200a14:	00f977b3          	and	a5,s2,a5
    __cache_free(sl->cache, ptr);
ffffffffc0200a18:	6388                	ld	a0,0(a5)
ffffffffc0200a1a:	85ca                	mv	a1,s2
ffffffffc0200a1c:	ea9ff0ef          	jal	ra,ffffffffc02008c4 <__cache_free>
    if (!ptr) return;
ffffffffc0200a20:	c499                	beqz	s1,ffffffffc0200a2e <slub_check+0xc2>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200a22:	77fd                	lui	a5,0xfffff
ffffffffc0200a24:	8fe5                	and	a5,a5,s1
    __cache_free(sl->cache, ptr);
ffffffffc0200a26:	6388                	ld	a0,0(a5)
ffffffffc0200a28:	85a6                	mv	a1,s1
ffffffffc0200a2a:	e9bff0ef          	jal	ra,ffffffffc02008c4 <__cache_free>
    if (!ptr) return;
ffffffffc0200a2e:	c419                	beqz	s0,ffffffffc0200a3c <slub_check+0xd0>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200a30:	77fd                	lui	a5,0xfffff
ffffffffc0200a32:	8fe1                	and	a5,a5,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200a34:	6388                	ld	a0,0(a5)
ffffffffc0200a36:	85a2                	mv	a1,s0
ffffffffc0200a38:	e8dff0ef          	jal	ra,ffffffffc02008c4 <__cache_free>
    kfree_bytes(p1);
    kfree_bytes(p2);
    kfree_bytes(p3);

    cprintf("SLUB-only test done.\n");
}
ffffffffc0200a3c:	7402                	ld	s0,32(sp)
ffffffffc0200a3e:	70a2                	ld	ra,40(sp)
ffffffffc0200a40:	64e2                	ld	s1,24(sp)
ffffffffc0200a42:	6942                	ld	s2,16(sp)
ffffffffc0200a44:	69a2                	ld	s3,8(sp)
    cprintf("SLUB-only test done.\n");
ffffffffc0200a46:	00001517          	auipc	a0,0x1
ffffffffc0200a4a:	0aa50513          	addi	a0,a0,170 # ffffffffc0201af0 <etext+0x3fa>
}
ffffffffc0200a4e:	6145                	addi	sp,sp,48
    cprintf("SLUB-only test done.\n");
ffffffffc0200a50:	efcff06f          	j	ffffffffc020014c <cprintf>
ffffffffc0200a54:	00371513          	slli	a0,a4,0x3
ffffffffc0200a58:	40e50733          	sub	a4,a0,a4
ffffffffc0200a5c:	00371513          	slli	a0,a4,0x3
ffffffffc0200a60:	b789                	j	ffffffffc02009a2 <slub_check+0x36>
ffffffffc0200a62:	00379513          	slli	a0,a5,0x3
ffffffffc0200a66:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a6a:	00379513          	slli	a0,a5,0x3
ffffffffc0200a6e:	b759                	j	ffffffffc02009f4 <slub_check+0x88>
ffffffffc0200a70:	00371513          	slli	a0,a4,0x3
ffffffffc0200a74:	40e50733          	sub	a4,a0,a4
ffffffffc0200a78:	00371513          	slli	a0,a4,0x3
ffffffffc0200a7c:	bf91                	j	ffffffffc02009d0 <slub_check+0x64>

ffffffffc0200a7e <buddy_init>:
    return buddy_base + buddy_offset;//返回伙伴的Page结构体指针
}

static void
buddy_init(void) {
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200a7e:	00005797          	auipc	a5,0x5
ffffffffc0200a82:	75a78793          	addi	a5,a5,1882 # ffffffffc02061d8 <free_areas>
ffffffffc0200a86:	00006717          	auipc	a4,0x6
ffffffffc0200a8a:	93270713          	addi	a4,a4,-1742 # ffffffffc02063b8 <is_panic>
ffffffffc0200a8e:	e79c                	sd	a5,8(a5)
ffffffffc0200a90:	e39c                	sd	a5,0(a5)
        list_init(&free_list_for_order(i));
        nr_free_for_order(i) = 0;
ffffffffc0200a92:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200a96:	07e1                	addi	a5,a5,24
ffffffffc0200a98:	fee79be3          	bne	a5,a4,ffffffffc0200a8e <buddy_init+0x10>
    }//初始化整个数组
    total_free_pages = 0;
ffffffffc0200a9c:	00006797          	auipc	a5,0x6
ffffffffc0200aa0:	9607ba23          	sd	zero,-1676(a5) # ffffffffc0206410 <total_free_pages>
    buddy_base = NULL;
ffffffffc0200aa4:	00006797          	auipc	a5,0x6
ffffffffc0200aa8:	9407be23          	sd	zero,-1700(a5) # ffffffffc0206400 <buddy_base>
    buddy_total_pages = 0;//初始化基地址和总页数
ffffffffc0200aac:	00006797          	auipc	a5,0x6
ffffffffc0200ab0:	9407be23          	sd	zero,-1700(a5) # ffffffffc0206408 <buddy_total_pages>
}
ffffffffc0200ab4:	8082                	ret

ffffffffc0200ab6 <buddy_nr_free_pages>:
    }
}
static size_t
buddy_nr_free_pages(void) {
    return total_free_pages;
}
ffffffffc0200ab6:	00006517          	auipc	a0,0x6
ffffffffc0200aba:	95a53503          	ld	a0,-1702(a0) # ffffffffc0206410 <total_free_pages>
ffffffffc0200abe:	8082                	ret

ffffffffc0200ac0 <buddy_dump_free_pages>:

static void
buddy_dump_free_pages(void) {
ffffffffc0200ac0:	711d                	addi	sp,sp,-96
    cprintf("------ Buddy System Free Page Dump ------\n");
ffffffffc0200ac2:	00001517          	auipc	a0,0x1
ffffffffc0200ac6:	08650513          	addi	a0,a0,134 # ffffffffc0201b48 <kmalloc_sizes+0x40>
buddy_dump_free_pages(void) {
ffffffffc0200aca:	e8a2                	sd	s0,80(sp)
ffffffffc0200acc:	e0ca                	sd	s2,64(sp)
ffffffffc0200ace:	fc4e                	sd	s3,56(sp)
ffffffffc0200ad0:	f852                	sd	s4,48(sp)
ffffffffc0200ad2:	f456                	sd	s5,40(sp)
ffffffffc0200ad4:	f05a                	sd	s6,32(sp)
ffffffffc0200ad6:	ec5e                	sd	s7,24(sp)
ffffffffc0200ad8:	e862                	sd	s8,16(sp)
ffffffffc0200ada:	e06a                	sd	s10,0(sp)
ffffffffc0200adc:	ec86                	sd	ra,88(sp)
ffffffffc0200ade:	e4a6                	sd	s1,72(sp)
ffffffffc0200ae0:	e466                	sd	s9,8(sp)
ffffffffc0200ae2:	00006d17          	auipc	s10,0x6
ffffffffc0200ae6:	846d0d13          	addi	s10,s10,-1978 # ffffffffc0206328 <free_areas+0x150>
    cprintf("------ Buddy System Free Page Dump ------\n");
ffffffffc0200aea:	e62ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int order = 14; order >=0; order--) {
ffffffffc0200aee:	4439                	li	s0,14
        if (!list_empty(&free_list_for_order(order))) {
            cprintf("Order %d (size %lu), %u blocks:\n", order, (1UL << order), nr_free_for_order(order));
ffffffffc0200af0:	4b85                	li	s7,1
ffffffffc0200af2:	00001b17          	auipc	s6,0x1
ffffffffc0200af6:	086b0b13          	addi	s6,s6,134 # ffffffffc0201b78 <kmalloc_sizes+0x70>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200afa:	00001c17          	auipc	s8,0x1
ffffffffc0200afe:	656c0c13          	addi	s8,s8,1622 # ffffffffc0202150 <nbase>
ffffffffc0200b02:	00006a17          	auipc	s4,0x6
ffffffffc0200b06:	8d6a0a13          	addi	s4,s4,-1834 # ffffffffc02063d8 <pages>
ffffffffc0200b0a:	00001997          	auipc	s3,0x1
ffffffffc0200b0e:	64e9b983          	ld	s3,1614(s3) # ffffffffc0202158 <nbase+0x8>
            list_entry_t *le = &free_list_for_order(order);
            while ((le = list_next(le)) != &free_list_for_order(order)) {
                struct Page *p = le2page(le, page_link);
                cprintf("  - Block at physical address 0x%016lx (page index %ld)\n", page2pa(p), p - pages);
ffffffffc0200b12:	00001917          	auipc	s2,0x1
ffffffffc0200b16:	08e90913          	addi	s2,s2,142 # ffffffffc0201ba0 <kmalloc_sizes+0x98>
    for (int order = 14; order >=0; order--) {
ffffffffc0200b1a:	5afd                	li	s5,-1
ffffffffc0200b1c:	a029                	j	ffffffffc0200b26 <buddy_dump_free_pages+0x66>
ffffffffc0200b1e:	347d                	addiw	s0,s0,-1
ffffffffc0200b20:	1d21                	addi	s10,s10,-24
ffffffffc0200b22:	05540a63          	beq	s0,s5,ffffffffc0200b76 <buddy_dump_free_pages+0xb6>
        if (!list_empty(&free_list_for_order(order))) {
ffffffffc0200b26:	008d3783          	ld	a5,8(s10)
ffffffffc0200b2a:	ffa78ae3          	beq	a5,s10,ffffffffc0200b1e <buddy_dump_free_pages+0x5e>
            cprintf("Order %d (size %lu), %u blocks:\n", order, (1UL << order), nr_free_for_order(order));
ffffffffc0200b2e:	010d2683          	lw	a3,16(s10)
ffffffffc0200b32:	008b9633          	sll	a2,s7,s0
ffffffffc0200b36:	85a2                	mv	a1,s0
ffffffffc0200b38:	855a                	mv	a0,s6
ffffffffc0200b3a:	e12ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    return listelm->next;
ffffffffc0200b3e:	008d3c83          	ld	s9,8(s10)
            while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200b42:	fdac8ee3          	beq	s9,s10,ffffffffc0200b1e <buddy_dump_free_pages+0x5e>
ffffffffc0200b46:	000c3483          	ld	s1,0(s8)
ffffffffc0200b4a:	000a3783          	ld	a5,0(s4)
                struct Page *p = le2page(le, page_link);
ffffffffc0200b4e:	fe8c8613          	addi	a2,s9,-24
                cprintf("  - Block at physical address 0x%016lx (page index %ld)\n", page2pa(p), p - pages);
ffffffffc0200b52:	854a                	mv	a0,s2
ffffffffc0200b54:	8e1d                	sub	a2,a2,a5
ffffffffc0200b56:	860d                	srai	a2,a2,0x3
ffffffffc0200b58:	03360633          	mul	a2,a2,s3
ffffffffc0200b5c:	009605b3          	add	a1,a2,s1
ffffffffc0200b60:	05b2                	slli	a1,a1,0xc
ffffffffc0200b62:	deaff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200b66:	008cbc83          	ld	s9,8(s9)
            while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200b6a:	ffac90e3          	bne	s9,s10,ffffffffc0200b4a <buddy_dump_free_pages+0x8a>
    for (int order = 14; order >=0; order--) {
ffffffffc0200b6e:	347d                	addiw	s0,s0,-1
ffffffffc0200b70:	1d21                	addi	s10,s10,-24
ffffffffc0200b72:	fb541ae3          	bne	s0,s5,ffffffffc0200b26 <buddy_dump_free_pages+0x66>
            }
        }
    }
    cprintf("Total free pages: %lu\n", total_free_pages);
ffffffffc0200b76:	00006597          	auipc	a1,0x6
ffffffffc0200b7a:	89a5b583          	ld	a1,-1894(a1) # ffffffffc0206410 <total_free_pages>
ffffffffc0200b7e:	00001517          	auipc	a0,0x1
ffffffffc0200b82:	06250513          	addi	a0,a0,98 # ffffffffc0201be0 <kmalloc_sizes+0xd8>
ffffffffc0200b86:	dc6ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("-----------------------------------------\n");
}//展示空闲页信息
ffffffffc0200b8a:	6446                	ld	s0,80(sp)
ffffffffc0200b8c:	60e6                	ld	ra,88(sp)
ffffffffc0200b8e:	64a6                	ld	s1,72(sp)
ffffffffc0200b90:	6906                	ld	s2,64(sp)
ffffffffc0200b92:	79e2                	ld	s3,56(sp)
ffffffffc0200b94:	7a42                	ld	s4,48(sp)
ffffffffc0200b96:	7aa2                	ld	s5,40(sp)
ffffffffc0200b98:	7b02                	ld	s6,32(sp)
ffffffffc0200b9a:	6be2                	ld	s7,24(sp)
ffffffffc0200b9c:	6c42                	ld	s8,16(sp)
ffffffffc0200b9e:	6ca2                	ld	s9,8(sp)
ffffffffc0200ba0:	6d02                	ld	s10,0(sp)
    cprintf("-----------------------------------------\n");
ffffffffc0200ba2:	00001517          	auipc	a0,0x1
ffffffffc0200ba6:	05650513          	addi	a0,a0,86 # ffffffffc0201bf8 <kmalloc_sizes+0xf0>
}//展示空闲页信息
ffffffffc0200baa:	6125                	addi	sp,sp,96
    cprintf("-----------------------------------------\n");
ffffffffc0200bac:	da0ff06f          	j	ffffffffc020014c <cprintf>

ffffffffc0200bb0 <buddy_check>:

static void
buddy_check(void) {
ffffffffc0200bb0:	7179                	addi	sp,sp,-48
    struct Page *p0, *p1, *p2, *p3, *p4, *p5;
    p0 = p1 = p2 = p3 = p4 = p5 = NULL;
    cprintf("Original State:\n");
ffffffffc0200bb2:	00001517          	auipc	a0,0x1
ffffffffc0200bb6:	07650513          	addi	a0,a0,118 # ffffffffc0201c28 <kmalloc_sizes+0x120>
buddy_check(void) {
ffffffffc0200bba:	f406                	sd	ra,40(sp)
ffffffffc0200bbc:	ec26                	sd	s1,24(sp)
ffffffffc0200bbe:	f022                	sd	s0,32(sp)
ffffffffc0200bc0:	e84a                	sd	s2,16(sp)
ffffffffc0200bc2:	e44e                	sd	s3,8(sp)
    cprintf("Original State:\n");
ffffffffc0200bc4:	d88ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200bc8:	ef9ff0ef          	jal	ra,ffffffffc0200ac0 <buddy_dump_free_pages>

    assert((p0 = alloc_pages(16383)) != NULL);
ffffffffc0200bcc:	6491                	lui	s1,0x4
ffffffffc0200bce:	fff48513          	addi	a0,s1,-1 # 3fff <kern_entry-0xffffffffc01fc001>
ffffffffc0200bd2:	9ffff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200bd6:	14050463          	beqz	a0,ffffffffc0200d1e <buddy_check+0x16e>
    cprintf("Allocated p0: %p\n", p0);
ffffffffc0200bda:	85aa                	mv	a1,a0
ffffffffc0200bdc:	842a                	mv	s0,a0
ffffffffc0200bde:	00001517          	auipc	a0,0x1
ffffffffc0200be2:	0ba50513          	addi	a0,a0,186 # ffffffffc0201c98 <kmalloc_sizes+0x190>
ffffffffc0200be6:	d66ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200bea:	ed7ff0ef          	jal	ra,ffffffffc0200ac0 <buddy_dump_free_pages>
    free_pages(p0, 16383);
ffffffffc0200bee:	fff48593          	addi	a1,s1,-1
ffffffffc0200bf2:	8522                	mv	a0,s0
ffffffffc0200bf4:	9e9ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    
    assert((p1 = alloc_pages(8191)) != NULL);
ffffffffc0200bf8:	6409                	lui	s0,0x2
ffffffffc0200bfa:	fff40513          	addi	a0,s0,-1 # 1fff <kern_entry-0xffffffffc01fe001>
ffffffffc0200bfe:	9d3ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200c02:	84aa                	mv	s1,a0
ffffffffc0200c04:	1c050d63          	beqz	a0,ffffffffc0200dde <buddy_check+0x22e>
    cprintf("Allocated p1: 8191\n", p1);
ffffffffc0200c08:	85aa                	mv	a1,a0
ffffffffc0200c0a:	00001517          	auipc	a0,0x1
ffffffffc0200c0e:	0ce50513          	addi	a0,a0,206 # ffffffffc0201cd8 <kmalloc_sizes+0x1d0>
ffffffffc0200c12:	d3aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200c16:	eabff0ef          	jal	ra,ffffffffc0200ac0 <buddy_dump_free_pages>
    assert((p2 = alloc_pages(8191)) != NULL);
ffffffffc0200c1a:	fff40513          	addi	a0,s0,-1
ffffffffc0200c1e:	9b3ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200c22:	892a                	mv	s2,a0
ffffffffc0200c24:	18050d63          	beqz	a0,ffffffffc0200dbe <buddy_check+0x20e>
    cprintf("Allocated p2: 8191\n", p2);
ffffffffc0200c28:	85aa                	mv	a1,a0
ffffffffc0200c2a:	00001517          	auipc	a0,0x1
ffffffffc0200c2e:	0ee50513          	addi	a0,a0,238 # ffffffffc0201d18 <kmalloc_sizes+0x210>
ffffffffc0200c32:	d1aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200c36:	e8bff0ef          	jal	ra,ffffffffc0200ac0 <buddy_dump_free_pages>
    assert((p3 = alloc_pages(8191)) != NULL);
ffffffffc0200c3a:	fff40513          	addi	a0,s0,-1
ffffffffc0200c3e:	993ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200c42:	89aa                	mv	s3,a0
ffffffffc0200c44:	14050d63          	beqz	a0,ffffffffc0200d9e <buddy_check+0x1ee>
    cprintf("Allocated p3: 8191\n", p3);
ffffffffc0200c48:	85aa                	mv	a1,a0
ffffffffc0200c4a:	00001517          	auipc	a0,0x1
ffffffffc0200c4e:	10e50513          	addi	a0,a0,270 # ffffffffc0201d58 <kmalloc_sizes+0x250>
ffffffffc0200c52:	cfaff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200c56:	e6bff0ef          	jal	ra,ffffffffc0200ac0 <buddy_dump_free_pages>
    assert((p4 = alloc_pages(8191)) == NULL);
ffffffffc0200c5a:	fff40513          	addi	a0,s0,-1
ffffffffc0200c5e:	973ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200c62:	10051e63          	bnez	a0,ffffffffc0200d7e <buddy_check+0x1ce>
    cprintf("Attempted to allocate p4: 8191, expected NULL, got %p\n", p4);
ffffffffc0200c66:	4581                	li	a1,0
ffffffffc0200c68:	00001517          	auipc	a0,0x1
ffffffffc0200c6c:	13050513          	addi	a0,a0,304 # ffffffffc0201d98 <kmalloc_sizes+0x290>
ffffffffc0200c70:	cdcff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200c74:	e4dff0ef          	jal	ra,ffffffffc0200ac0 <buddy_dump_free_pages>


    free_pages(p1, 8191);
ffffffffc0200c78:	fff40593          	addi	a1,s0,-1
ffffffffc0200c7c:	8526                	mv	a0,s1
ffffffffc0200c7e:	95fff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(p2, 8191);
ffffffffc0200c82:	fff40593          	addi	a1,s0,-1
ffffffffc0200c86:	854a                	mv	a0,s2
ffffffffc0200c88:	955ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(p3, 8191);
ffffffffc0200c8c:	fff40593          	addi	a1,s0,-1
ffffffffc0200c90:	854e                	mv	a0,s3
ffffffffc0200c92:	94bff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    
    cprintf("Freed p1, p2, p3:\n");
ffffffffc0200c96:	00001517          	auipc	a0,0x1
ffffffffc0200c9a:	13a50513          	addi	a0,a0,314 # ffffffffc0201dd0 <kmalloc_sizes+0x2c8>
ffffffffc0200c9e:	caeff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200ca2:	e1fff0ef          	jal	ra,ffffffffc0200ac0 <buddy_dump_free_pages>
    assert((p4 = alloc_pages(129)) != NULL);
ffffffffc0200ca6:	08100513          	li	a0,129
ffffffffc0200caa:	927ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200cae:	842a                	mv	s0,a0
ffffffffc0200cb0:	c55d                	beqz	a0,ffffffffc0200d5e <buddy_check+0x1ae>
    cprintf("Allocated p4: 129\n", p4);
ffffffffc0200cb2:	85aa                	mv	a1,a0
ffffffffc0200cb4:	00001517          	auipc	a0,0x1
ffffffffc0200cb8:	15450513          	addi	a0,a0,340 # ffffffffc0201e08 <kmalloc_sizes+0x300>
ffffffffc0200cbc:	c90ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200cc0:	e01ff0ef          	jal	ra,ffffffffc0200ac0 <buddy_dump_free_pages>

    assert((p5 = alloc_pages(513)) != NULL);
ffffffffc0200cc4:	20100513          	li	a0,513
ffffffffc0200cc8:	909ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ccc:	84aa                	mv	s1,a0
ffffffffc0200cce:	c925                	beqz	a0,ffffffffc0200d3e <buddy_check+0x18e>
    cprintf("Allocated p5: 513\n", p5);
ffffffffc0200cd0:	85aa                	mv	a1,a0
ffffffffc0200cd2:	00001517          	auipc	a0,0x1
ffffffffc0200cd6:	16e50513          	addi	a0,a0,366 # ffffffffc0201e40 <kmalloc_sizes+0x338>
ffffffffc0200cda:	c72ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200cde:	de3ff0ef          	jal	ra,ffffffffc0200ac0 <buddy_dump_free_pages>

    free_pages(p4, 129);
ffffffffc0200ce2:	8522                	mv	a0,s0
ffffffffc0200ce4:	08100593          	li	a1,129
ffffffffc0200ce8:	8f5ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(p5, 513);
ffffffffc0200cec:	20100593          	li	a1,513
ffffffffc0200cf0:	8526                	mv	a0,s1
ffffffffc0200cf2:	8ebff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    cprintf("Freed p4, p5:\n");
ffffffffc0200cf6:	00001517          	auipc	a0,0x1
ffffffffc0200cfa:	16250513          	addi	a0,a0,354 # ffffffffc0201e58 <kmalloc_sizes+0x350>
ffffffffc0200cfe:	c4eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200d02:	dbfff0ef          	jal	ra,ffffffffc0200ac0 <buddy_dump_free_pages>
    cprintf("buddy_check() succeeded!\n");



}
ffffffffc0200d06:	7402                	ld	s0,32(sp)
ffffffffc0200d08:	70a2                	ld	ra,40(sp)
ffffffffc0200d0a:	64e2                	ld	s1,24(sp)
ffffffffc0200d0c:	6942                	ld	s2,16(sp)
ffffffffc0200d0e:	69a2                	ld	s3,8(sp)
    cprintf("buddy_check() succeeded!\n");
ffffffffc0200d10:	00001517          	auipc	a0,0x1
ffffffffc0200d14:	15850513          	addi	a0,a0,344 # ffffffffc0201e68 <kmalloc_sizes+0x360>
}
ffffffffc0200d18:	6145                	addi	sp,sp,48
    cprintf("buddy_check() succeeded!\n");
ffffffffc0200d1a:	c32ff06f          	j	ffffffffc020014c <cprintf>
    assert((p0 = alloc_pages(16383)) != NULL);
ffffffffc0200d1e:	00001697          	auipc	a3,0x1
ffffffffc0200d22:	f2268693          	addi	a3,a3,-222 # ffffffffc0201c40 <kmalloc_sizes+0x138>
ffffffffc0200d26:	00001617          	auipc	a2,0x1
ffffffffc0200d2a:	f4260613          	addi	a2,a2,-190 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc0200d2e:	0e300593          	li	a1,227
ffffffffc0200d32:	00001517          	auipc	a0,0x1
ffffffffc0200d36:	f4e50513          	addi	a0,a0,-178 # ffffffffc0201c80 <kmalloc_sizes+0x178>
ffffffffc0200d3a:	c88ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p5 = alloc_pages(513)) != NULL);
ffffffffc0200d3e:	00001697          	auipc	a3,0x1
ffffffffc0200d42:	0e268693          	addi	a3,a3,226 # ffffffffc0201e20 <kmalloc_sizes+0x318>
ffffffffc0200d46:	00001617          	auipc	a2,0x1
ffffffffc0200d4a:	f2260613          	addi	a2,a2,-222 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc0200d4e:	10000593          	li	a1,256
ffffffffc0200d52:	00001517          	auipc	a0,0x1
ffffffffc0200d56:	f2e50513          	addi	a0,a0,-210 # ffffffffc0201c80 <kmalloc_sizes+0x178>
ffffffffc0200d5a:	c68ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p4 = alloc_pages(129)) != NULL);
ffffffffc0200d5e:	00001697          	auipc	a3,0x1
ffffffffc0200d62:	08a68693          	addi	a3,a3,138 # ffffffffc0201de8 <kmalloc_sizes+0x2e0>
ffffffffc0200d66:	00001617          	auipc	a2,0x1
ffffffffc0200d6a:	f0260613          	addi	a2,a2,-254 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc0200d6e:	0fc00593          	li	a1,252
ffffffffc0200d72:	00001517          	auipc	a0,0x1
ffffffffc0200d76:	f0e50513          	addi	a0,a0,-242 # ffffffffc0201c80 <kmalloc_sizes+0x178>
ffffffffc0200d7a:	c48ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p4 = alloc_pages(8191)) == NULL);
ffffffffc0200d7e:	00001697          	auipc	a3,0x1
ffffffffc0200d82:	ff268693          	addi	a3,a3,-14 # ffffffffc0201d70 <kmalloc_sizes+0x268>
ffffffffc0200d86:	00001617          	auipc	a2,0x1
ffffffffc0200d8a:	ee260613          	addi	a2,a2,-286 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc0200d8e:	0f100593          	li	a1,241
ffffffffc0200d92:	00001517          	auipc	a0,0x1
ffffffffc0200d96:	eee50513          	addi	a0,a0,-274 # ffffffffc0201c80 <kmalloc_sizes+0x178>
ffffffffc0200d9a:	c28ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p3 = alloc_pages(8191)) != NULL);
ffffffffc0200d9e:	00001697          	auipc	a3,0x1
ffffffffc0200da2:	f9268693          	addi	a3,a3,-110 # ffffffffc0201d30 <kmalloc_sizes+0x228>
ffffffffc0200da6:	00001617          	auipc	a2,0x1
ffffffffc0200daa:	ec260613          	addi	a2,a2,-318 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc0200dae:	0ee00593          	li	a1,238
ffffffffc0200db2:	00001517          	auipc	a0,0x1
ffffffffc0200db6:	ece50513          	addi	a0,a0,-306 # ffffffffc0201c80 <kmalloc_sizes+0x178>
ffffffffc0200dba:	c08ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_pages(8191)) != NULL);
ffffffffc0200dbe:	00001697          	auipc	a3,0x1
ffffffffc0200dc2:	f3268693          	addi	a3,a3,-206 # ffffffffc0201cf0 <kmalloc_sizes+0x1e8>
ffffffffc0200dc6:	00001617          	auipc	a2,0x1
ffffffffc0200dca:	ea260613          	addi	a2,a2,-350 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc0200dce:	0eb00593          	li	a1,235
ffffffffc0200dd2:	00001517          	auipc	a0,0x1
ffffffffc0200dd6:	eae50513          	addi	a0,a0,-338 # ffffffffc0201c80 <kmalloc_sizes+0x178>
ffffffffc0200dda:	be8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_pages(8191)) != NULL);
ffffffffc0200dde:	00001697          	auipc	a3,0x1
ffffffffc0200de2:	ed268693          	addi	a3,a3,-302 # ffffffffc0201cb0 <kmalloc_sizes+0x1a8>
ffffffffc0200de6:	00001617          	auipc	a2,0x1
ffffffffc0200dea:	e8260613          	addi	a2,a2,-382 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc0200dee:	0e800593          	li	a1,232
ffffffffc0200df2:	00001517          	auipc	a0,0x1
ffffffffc0200df6:	e8e50513          	addi	a0,a0,-370 # ffffffffc0201c80 <kmalloc_sizes+0x178>
ffffffffc0200dfa:	bc8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200dfe <buddy_free_pages>:
    assert(n > 0);
ffffffffc0200dfe:	16058b63          	beqz	a1,ffffffffc0200f74 <buddy_free_pages+0x176>
    while ((1UL << order) < n) {
ffffffffc0200e02:	4785                	li	a5,1
    size_t order = 0;
ffffffffc0200e04:	4601                	li	a2,0
    while ((1UL << order) < n) {
ffffffffc0200e06:	4685                	li	a3,1
ffffffffc0200e08:	14f58e63          	beq	a1,a5,ffffffffc0200f64 <buddy_free_pages+0x166>
        order++;
ffffffffc0200e0c:	0605                	addi	a2,a2,1
    while ((1UL << order) < n) {
ffffffffc0200e0e:	00c697b3          	sll	a5,a3,a2
ffffffffc0200e12:	0006071b          	sext.w	a4,a2
ffffffffc0200e16:	feb7ebe3          	bltu	a5,a1,ffffffffc0200e0c <buddy_free_pages+0xe>
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0200e1a:	00161813          	slli	a6,a2,0x1
ffffffffc0200e1e:	00c805b3          	add	a1,a6,a2
ffffffffc0200e22:	00005697          	auipc	a3,0x5
ffffffffc0200e26:	3b668693          	addi	a3,a3,950 # ffffffffc02061d8 <free_areas>
ffffffffc0200e2a:	058e                	slli	a1,a1,0x3
ffffffffc0200e2c:	95b6                	add	a1,a1,a3
    total_free_pages += (1UL << order);//更新总空闲页数
ffffffffc0200e2e:	00005e17          	auipc	t3,0x5
ffffffffc0200e32:	5e2e0e13          	addi	t3,t3,1506 # ffffffffc0206410 <total_free_pages>
ffffffffc0200e36:	000e3303          	ld	t1,0(t3)
    SetPageProperty(page);
ffffffffc0200e3a:	00853883          	ld	a7,8(a0)
    page->property = order;
ffffffffc0200e3e:	c918                	sw	a4,16(a0)
    total_free_pages += (1UL << order);//更新总空闲页数
ffffffffc0200e40:	00f30733          	add	a4,t1,a5
    SetPageProperty(page);
ffffffffc0200e44:	0028e793          	ori	a5,a7,2
ffffffffc0200e48:	e51c                	sd	a5,8(a0)
    total_free_pages += (1UL << order);//更新总空闲页数
ffffffffc0200e4a:	00ee3023          	sd	a4,0(t3)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0200e4e:	87ae                	mv	a5,a1
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200e50:	a029                	j	ffffffffc0200e5a <buddy_free_pages+0x5c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200e52:	fe878713          	addi	a4,a5,-24
        if (page < p) {
ffffffffc0200e56:	00e56563          	bltu	a0,a4,ffffffffc0200e60 <buddy_free_pages+0x62>
ffffffffc0200e5a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200e5c:	feb79be3          	bne	a5,a1,ffffffffc0200e52 <buddy_free_pages+0x54>
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc0200e60:	00c80733          	add	a4,a6,a2
ffffffffc0200e64:	070e                	slli	a4,a4,0x3
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200e66:	0007b883          	ld	a7,0(a5)
ffffffffc0200e6a:	9736                	add	a4,a4,a3
ffffffffc0200e6c:	4b0c                	lw	a1,16(a4)
    list_add_before(le, &(page->page_link));//插入该位置
ffffffffc0200e6e:	01850813          	addi	a6,a0,24
    prev->next = next->prev = elm;
ffffffffc0200e72:	0107b023          	sd	a6,0(a5)
ffffffffc0200e76:	0108b423          	sd	a6,8(a7)
    elm->next = next;
ffffffffc0200e7a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200e7c:	01153c23          	sd	a7,24(a0)
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc0200e80:	0015879b          	addiw	a5,a1,1
ffffffffc0200e84:	cb1c                	sw	a5,16(a4)
    while (order < MAX_ORDER - 1) {
ffffffffc0200e86:	47c9                	li	a5,18
ffffffffc0200e88:	0cc7ed63          	bltu	a5,a2,ffffffffc0200f62 <buddy_free_pages+0x164>
ffffffffc0200e8c:	00160713          	addi	a4,a2,1
ffffffffc0200e90:	00171793          	slli	a5,a4,0x1
ffffffffc0200e94:	97ba                	add	a5,a5,a4
ffffffffc0200e96:	078e                	slli	a5,a5,0x3
    if (buddy_base == NULL) {
ffffffffc0200e98:	00005597          	auipc	a1,0x5
ffffffffc0200e9c:	5685b583          	ld	a1,1384(a1) # ffffffffc0206400 <buddy_base>
    if (buddy_offset >= buddy_total_pages) {
ffffffffc0200ea0:	00005e97          	auipc	t4,0x5
ffffffffc0200ea4:	568ebe83          	ld	t4,1384(t4) # ffffffffc0206408 <buddy_total_pages>
ffffffffc0200ea8:	96be                	add	a3,a3,a5
    size_t offset = page - buddy_base;//相对base的偏移
ffffffffc0200eaa:	00001e17          	auipc	t3,0x1
ffffffffc0200eae:	2aee3e03          	ld	t3,686(t3) # ffffffffc0202158 <nbase+0x8>
    size_t buddy_offset = offset ^ (1UL << order);//取异或找到伙伴
ffffffffc0200eb2:	4305                	li	t1,1
    while (order < MAX_ORDER - 1) {
ffffffffc0200eb4:	48cd                	li	a7,19
    if (buddy_base == NULL) {
ffffffffc0200eb6:	c5d5                	beqz	a1,ffffffffc0200f62 <buddy_free_pages+0x164>
    size_t offset = page - buddy_base;//相对base的偏移
ffffffffc0200eb8:	40b507b3          	sub	a5,a0,a1
ffffffffc0200ebc:	878d                	srai	a5,a5,0x3
ffffffffc0200ebe:	03c787b3          	mul	a5,a5,t3
    size_t buddy_offset = offset ^ (1UL << order);//取异或找到伙伴
ffffffffc0200ec2:	00c31733          	sll	a4,t1,a2
ffffffffc0200ec6:	8f3d                	xor	a4,a4,a5
    if (buddy_offset >= buddy_total_pages) {
ffffffffc0200ec8:	09d77d63          	bgeu	a4,t4,ffffffffc0200f62 <buddy_free_pages+0x164>
    return buddy_base + buddy_offset;//返回伙伴的Page结构体指针
ffffffffc0200ecc:	00271793          	slli	a5,a4,0x2
ffffffffc0200ed0:	97ba                	add	a5,a5,a4
ffffffffc0200ed2:	078e                	slli	a5,a5,0x3
ffffffffc0200ed4:	97ae                	add	a5,a5,a1
        if (buddy == NULL || !PageProperty(buddy) || buddy->property != order) {
ffffffffc0200ed6:	6798                	ld	a4,8(a5)
ffffffffc0200ed8:	8b09                	andi	a4,a4,2
ffffffffc0200eda:	c741                	beqz	a4,ffffffffc0200f62 <buddy_free_pages+0x164>
ffffffffc0200edc:	0107e703          	lwu	a4,16(a5)
ffffffffc0200ee0:	08c71163          	bne	a4,a2,ffffffffc0200f62 <buddy_free_pages+0x164>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ee4:	01853283          	ld	t0,24(a0)
ffffffffc0200ee8:	02053f83          	ld	t6,32(a0)
        nr_free_for_order(order)--;
ffffffffc0200eec:	ff86af03          	lw	t5,-8(a3)
        ClearPageProperty(page);
ffffffffc0200ef0:	6518                	ld	a4,8(a0)
    prev->next = next;
ffffffffc0200ef2:	01f2b423          	sd	t6,8(t0)
    next->prev = prev;
ffffffffc0200ef6:	005fb023          	sd	t0,0(t6)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200efa:	0187b283          	ld	t0,24(a5)
ffffffffc0200efe:	0207bf83          	ld	t6,32(a5)
        nr_free_for_order(order)--;
ffffffffc0200f02:	3f79                	addiw	t5,t5,-2
        ClearPageProperty(page);
ffffffffc0200f04:	9b75                	andi	a4,a4,-3
    prev->next = next;
ffffffffc0200f06:	01f2b423          	sd	t6,8(t0)
    next->prev = prev;
ffffffffc0200f0a:	005fb023          	sd	t0,0(t6)
        nr_free_for_order(order)--;
ffffffffc0200f0e:	ffe6ac23          	sw	t5,-8(a3)
        ClearPageProperty(page);
ffffffffc0200f12:	e518                	sd	a4,8(a0)
        ClearPageProperty(buddy);
ffffffffc0200f14:	6798                	ld	a4,8(a5)
ffffffffc0200f16:	9b75                	andi	a4,a4,-3
ffffffffc0200f18:	e798                	sd	a4,8(a5)
        if (buddy < page) {
ffffffffc0200f1a:	00a7f563          	bgeu	a5,a0,ffffffffc0200f24 <buddy_free_pages+0x126>
ffffffffc0200f1e:	853e                	mv	a0,a5
ffffffffc0200f20:	01878813          	addi	a6,a5,24
        SetPageProperty(page);
ffffffffc0200f24:	651c                	ld	a5,8(a0)
        order++;//提升到更高的 order
ffffffffc0200f26:	0605                	addi	a2,a2,1
        page->property = order;
ffffffffc0200f28:	c910                	sw	a2,16(a0)
        SetPageProperty(page);
ffffffffc0200f2a:	0027e793          	ori	a5,a5,2
ffffffffc0200f2e:	e51c                	sd	a5,8(a0)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200f30:	87b6                	mv	a5,a3
ffffffffc0200f32:	a029                	j	ffffffffc0200f3c <buddy_free_pages+0x13e>
        struct Page *p = le2page(le, page_link);
ffffffffc0200f34:	fe878713          	addi	a4,a5,-24
        if (page < p) {
ffffffffc0200f38:	00e56563          	bltu	a0,a4,ffffffffc0200f42 <buddy_free_pages+0x144>
    return listelm->next;
ffffffffc0200f3c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200f3e:	fed79be3          	bne	a5,a3,ffffffffc0200f34 <buddy_free_pages+0x136>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200f42:	0007bf03          	ld	t5,0(a5)
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc0200f46:	4a98                	lw	a4,16(a3)
    prev->next = next->prev = elm;
ffffffffc0200f48:	0107b023          	sd	a6,0(a5)
ffffffffc0200f4c:	010f3423          	sd	a6,8(t5)
    elm->next = next;
ffffffffc0200f50:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200f52:	01e53c23          	sd	t5,24(a0)
ffffffffc0200f56:	0017079b          	addiw	a5,a4,1
ffffffffc0200f5a:	ca9c                	sw	a5,16(a3)
    while (order < MAX_ORDER - 1) {
ffffffffc0200f5c:	06e1                	addi	a3,a3,24
ffffffffc0200f5e:	f5161ce3          	bne	a2,a7,ffffffffc0200eb6 <buddy_free_pages+0xb8>
ffffffffc0200f62:	8082                	ret
    while ((1UL << order) < n) {
ffffffffc0200f64:	00005697          	auipc	a3,0x5
ffffffffc0200f68:	27468693          	addi	a3,a3,628 # ffffffffc02061d8 <free_areas>
ffffffffc0200f6c:	85b6                	mv	a1,a3
ffffffffc0200f6e:	4701                	li	a4,0
ffffffffc0200f70:	4801                	li	a6,0
ffffffffc0200f72:	bd75                	j	ffffffffc0200e2e <buddy_free_pages+0x30>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200f74:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200f76:	00001697          	auipc	a3,0x1
ffffffffc0200f7a:	f1268693          	addi	a3,a3,-238 # ffffffffc0201e88 <kmalloc_sizes+0x380>
ffffffffc0200f7e:	00001617          	auipc	a2,0x1
ffffffffc0200f82:	cea60613          	addi	a2,a2,-790 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc0200f86:	09c00593          	li	a1,156
ffffffffc0200f8a:	00001517          	auipc	a0,0x1
ffffffffc0200f8e:	cf650513          	addi	a0,a0,-778 # ffffffffc0201c80 <kmalloc_sizes+0x178>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200f92:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200f94:	a2eff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200f98 <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc0200f98:	10050863          	beqz	a0,ffffffffc02010a8 <buddy_alloc_pages+0x110>
    if (total_free_pages < (1UL << order)) {
ffffffffc0200f9c:	00005297          	auipc	t0,0x5
ffffffffc0200fa0:	47428293          	addi	t0,t0,1140 # ffffffffc0206410 <total_free_pages>
    while ((1UL << order) < n) {
ffffffffc0200fa4:	4705                	li	a4,1
    if (total_free_pages < (1UL << order)) {
ffffffffc0200fa6:	0002bf83          	ld	t6,0(t0)
    size_t order = 0;
ffffffffc0200faa:	4801                	li	a6,0
    while ((1UL << order) < n) {
ffffffffc0200fac:	4785                	li	a5,1
ffffffffc0200fae:	0ee50963          	beq	a0,a4,ffffffffc02010a0 <buddy_alloc_pages+0x108>
        order++;
ffffffffc0200fb2:	0805                	addi	a6,a6,1
    while ((1UL << order) < n) {
ffffffffc0200fb4:	010798b3          	sll	a7,a5,a6
ffffffffc0200fb8:	fea8ede3          	bltu	a7,a0,ffffffffc0200fb2 <buddy_alloc_pages+0x1a>
    if (total_free_pages < (1UL << order)) {
ffffffffc0200fbc:	0d1fe063          	bltu	t6,a7,ffffffffc020107c <buddy_alloc_pages+0xe4>
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
ffffffffc0200fc0:	47cd                	li	a5,19
ffffffffc0200fc2:	0b07ef63          	bltu	a5,a6,ffffffffc0201080 <buddy_alloc_pages+0xe8>
ffffffffc0200fc6:	00181793          	slli	a5,a6,0x1
ffffffffc0200fca:	97c2                	add	a5,a5,a6
ffffffffc0200fcc:	00005617          	auipc	a2,0x5
ffffffffc0200fd0:	20c60613          	addi	a2,a2,524 # ffffffffc02061d8 <free_areas>
ffffffffc0200fd4:	078e                	slli	a5,a5,0x3
ffffffffc0200fd6:	97b2                	add	a5,a5,a2
    size_t order = 0;
ffffffffc0200fd8:	85c2                	mv	a1,a6
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
ffffffffc0200fda:	4751                	li	a4,20
ffffffffc0200fdc:	a029                	j	ffffffffc0200fe6 <buddy_alloc_pages+0x4e>
ffffffffc0200fde:	0585                	addi	a1,a1,1
ffffffffc0200fe0:	07e1                	addi	a5,a5,24
ffffffffc0200fe2:	08e58d63          	beq	a1,a4,ffffffffc020107c <buddy_alloc_pages+0xe4>
    return list->next == list;
ffffffffc0200fe6:	0087b303          	ld	t1,8(a5)
        if (!list_empty(&free_list_for_order(current_order))) {
ffffffffc0200fea:	fef30ae3          	beq	t1,a5,ffffffffc0200fde <buddy_alloc_pages+0x46>
    nr_free_for_order(current_order)--;//减少该order的空闲块计数
ffffffffc0200fee:	00159793          	slli	a5,a1,0x1
ffffffffc0200ff2:	97ae                	add	a5,a5,a1
ffffffffc0200ff4:	078e                	slli	a5,a5,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ff6:	00833503          	ld	a0,8(t1)
ffffffffc0200ffa:	00f606b3          	add	a3,a2,a5
ffffffffc0200ffe:	00033e03          	ld	t3,0(t1)
ffffffffc0201002:	4a98                	lw	a4,16(a3)
ffffffffc0201004:	17a1                	addi	a5,a5,-24
    prev->next = next;
ffffffffc0201006:	00ae3423          	sd	a0,8(t3)
    next->prev = prev;
ffffffffc020100a:	01c53023          	sd	t3,0(a0)
ffffffffc020100e:	377d                	addiw	a4,a4,-1
ffffffffc0201010:	ca98                	sw	a4,16(a3)
    struct Page* page = le2page(le, page_link);
ffffffffc0201012:	fe830513          	addi	a0,t1,-24
    while (current_order > order) {
ffffffffc0201016:	963e                	add	a2,a2,a5
        struct Page* buddy = page + (1UL << current_order);
ffffffffc0201018:	02800f13          	li	t5,40
    while (current_order > order) {
ffffffffc020101c:	04b87663          	bgeu	a6,a1,ffffffffc0201068 <buddy_alloc_pages+0xd0>
        current_order--;
ffffffffc0201020:	15fd                	addi	a1,a1,-1
        struct Page* buddy = page + (1UL << current_order);
ffffffffc0201022:	00bf1733          	sll	a4,t5,a1
ffffffffc0201026:	972a                	add	a4,a4,a0
        SetPageProperty(buddy);
ffffffffc0201028:	6714                	ld	a3,8(a4)
        buddy->property = current_order;
ffffffffc020102a:	cb0c                	sw	a1,16(a4)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc020102c:	87b2                	mv	a5,a2
        SetPageProperty(buddy);
ffffffffc020102e:	0026e693          	ori	a3,a3,2
ffffffffc0201032:	e714                	sd	a3,8(a4)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0201034:	a029                	j	ffffffffc020103e <buddy_alloc_pages+0xa6>
        struct Page *p = le2page(le, page_link);
ffffffffc0201036:	fe878693          	addi	a3,a5,-24
        if (page < p) {
ffffffffc020103a:	00d76563          	bltu	a4,a3,ffffffffc0201044 <buddy_alloc_pages+0xac>
    return listelm->next;
ffffffffc020103e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0201040:	fec79be3          	bne	a5,a2,ffffffffc0201036 <buddy_alloc_pages+0x9e>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201044:	0007be03          	ld	t3,0(a5)
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc0201048:	4a14                	lw	a3,16(a2)
    list_add_before(le, &(page->page_link));//插入该位置
ffffffffc020104a:	01870e93          	addi	t4,a4,24
    prev->next = next->prev = elm;
ffffffffc020104e:	01d7b023          	sd	t4,0(a5)
ffffffffc0201052:	01de3423          	sd	t4,8(t3)
    elm->next = next;
ffffffffc0201056:	f31c                	sd	a5,32(a4)
    elm->prev = prev;
ffffffffc0201058:	01c73c23          	sd	t3,24(a4)
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc020105c:	0016879b          	addiw	a5,a3,1
ffffffffc0201060:	ca1c                	sw	a5,16(a2)
    while (current_order > order) {
ffffffffc0201062:	1621                	addi	a2,a2,-24
ffffffffc0201064:	fb059ee3          	bne	a1,a6,ffffffffc0201020 <buddy_alloc_pages+0x88>
    ClearPageProperty(page);
ffffffffc0201068:	ff033783          	ld	a5,-16(t1)
    total_free_pages -= (1UL << order);//更新总空闲页数
ffffffffc020106c:	411f88b3          	sub	a7,t6,a7
ffffffffc0201070:	0112b023          	sd	a7,0(t0)
    ClearPageProperty(page);
ffffffffc0201074:	9bf5                	andi	a5,a5,-3
ffffffffc0201076:	fef33823          	sd	a5,-16(t1)
    return page;
ffffffffc020107a:	8082                	ret
        return NULL;
ffffffffc020107c:	4501                	li	a0,0
}
ffffffffc020107e:	8082                	ret
    if (current_order == MAX_ORDER) {
ffffffffc0201080:	47d1                	li	a5,20
ffffffffc0201082:	fef80de3          	beq	a6,a5,ffffffffc020107c <buddy_alloc_pages+0xe4>
    return listelm->next;
ffffffffc0201086:	00181793          	slli	a5,a6,0x1
ffffffffc020108a:	97c2                	add	a5,a5,a6
ffffffffc020108c:	00005617          	auipc	a2,0x5
ffffffffc0201090:	14c60613          	addi	a2,a2,332 # ffffffffc02061d8 <free_areas>
ffffffffc0201094:	078e                	slli	a5,a5,0x3
ffffffffc0201096:	97b2                	add	a5,a5,a2
ffffffffc0201098:	0087b303          	ld	t1,8(a5)
ffffffffc020109c:	85c2                	mv	a1,a6
ffffffffc020109e:	bf81                	j	ffffffffc0200fee <buddy_alloc_pages+0x56>
    if (total_free_pages < (1UL << order)) {
ffffffffc02010a0:	fc0f8ee3          	beqz	t6,ffffffffc020107c <buddy_alloc_pages+0xe4>
    while ((1UL << order) < n) {
ffffffffc02010a4:	4885                	li	a7,1
ffffffffc02010a6:	b705                	j	ffffffffc0200fc6 <buddy_alloc_pages+0x2e>
buddy_alloc_pages(size_t n) {
ffffffffc02010a8:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02010aa:	00001697          	auipc	a3,0x1
ffffffffc02010ae:	dde68693          	addi	a3,a3,-546 # ffffffffc0201e88 <kmalloc_sizes+0x380>
ffffffffc02010b2:	00001617          	auipc	a2,0x1
ffffffffc02010b6:	bb660613          	addi	a2,a2,-1098 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc02010ba:	06e00593          	li	a1,110
ffffffffc02010be:	00001517          	auipc	a0,0x1
ffffffffc02010c2:	bc250513          	addi	a0,a0,-1086 # ffffffffc0201c80 <kmalloc_sizes+0x178>
buddy_alloc_pages(size_t n) {
ffffffffc02010c6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02010c8:	8faff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02010cc <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc02010cc:	1141                	addi	sp,sp,-16
ffffffffc02010ce:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02010d0:	14058963          	beqz	a1,ffffffffc0201222 <buddy_init_memmap+0x156>
    if (buddy_base == NULL) {
ffffffffc02010d4:	00005617          	auipc	a2,0x5
ffffffffc02010d8:	32c60613          	addi	a2,a2,812 # ffffffffc0206400 <buddy_base>
ffffffffc02010dc:	621c                	ld	a5,0(a2)
ffffffffc02010de:	10078c63          	beqz	a5,ffffffffc02011f6 <buddy_init_memmap+0x12a>
        assert(base >= buddy_base);
ffffffffc02010e2:	16f56063          	bltu	a0,a5,ffffffffc0201242 <buddy_init_memmap+0x176>
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc02010e6:	00259693          	slli	a3,a1,0x2
ffffffffc02010ea:	96ae                	add	a3,a3,a1
ffffffffc02010ec:	068e                	slli	a3,a3,0x3
ffffffffc02010ee:	96aa                	add	a3,a3,a0
ffffffffc02010f0:	87aa                	mv	a5,a0
ffffffffc02010f2:	02d57063          	bgeu	a0,a3,ffffffffc0201112 <buddy_init_memmap+0x46>
        assert(PageReserved(p));
ffffffffc02010f6:	6798                	ld	a4,8(a5)
ffffffffc02010f8:	8b05                	andi	a4,a4,1
ffffffffc02010fa:	10070463          	beqz	a4,ffffffffc0201202 <buddy_init_memmap+0x136>
        p->flags = 0;
ffffffffc02010fe:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0201102:	0007a823          	sw	zero,16(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201106:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc020110a:	02878793          	addi	a5,a5,40
ffffffffc020110e:	fed7e4e3          	bltu	a5,a3,ffffffffc02010f6 <buddy_init_memmap+0x2a>
    size_t base_offset = base - buddy_base;
ffffffffc0201112:	00063f83          	ld	t6,0(a2)
ffffffffc0201116:	00001697          	auipc	a3,0x1
ffffffffc020111a:	0426b683          	ld	a3,66(a3) # ffffffffc0202158 <nbase+0x8>
    total_free_pages += n;
ffffffffc020111e:	00005717          	auipc	a4,0x5
ffffffffc0201122:	2f270713          	addi	a4,a4,754 # ffffffffc0206410 <total_free_pages>
    size_t base_offset = base - buddy_base;
ffffffffc0201126:	41f50fb3          	sub	t6,a0,t6
ffffffffc020112a:	403fdf93          	srai	t6,t6,0x3
ffffffffc020112e:	02df8fb3          	mul	t6,t6,a3
    total_free_pages += n;
ffffffffc0201132:	631c                	ld	a5,0(a4)
    size_t offset = 0;
ffffffffc0201134:	4e81                	li	t4,0
ffffffffc0201136:	00005f17          	auipc	t5,0x5
ffffffffc020113a:	0a2f0f13          	addi	t5,t5,162 # ffffffffc02061d8 <free_areas>
    total_free_pages += n;
ffffffffc020113e:	97ae                	add	a5,a5,a1
ffffffffc0201140:	e31c                	sd	a5,0(a4)
            size_t block_size = 1UL << (order + 1);
ffffffffc0201142:	4305                	li	t1,1
        while (order + 1 < MAX_ORDER) {
ffffffffc0201144:	4e4d                	li	t3,19
        size_t remaining = n - offset;//剩余页数
ffffffffc0201146:	41d586b3          	sub	a3,a1,t4
ffffffffc020114a:	4701                	li	a4,0
            size_t global_offset = base_offset + offset;
ffffffffc020114c:	01df8833          	add	a6,t6,t4
            size_t block_size = 1UL << (order + 1);
ffffffffc0201150:	0017079b          	addiw	a5,a4,1
ffffffffc0201154:	00f317b3          	sll	a5,t1,a5
            if (block_size > remaining) {//不能再更大了
ffffffffc0201158:	0007061b          	sext.w	a2,a4
ffffffffc020115c:	08f6e563          	bltu	a3,a5,ffffffffc02011e6 <buddy_init_memmap+0x11a>
            if (global_offset & (block_size - 1)) {
ffffffffc0201160:	17fd                	addi	a5,a5,-1
ffffffffc0201162:	0107f7b3          	and	a5,a5,a6
ffffffffc0201166:	e3c1                	bnez	a5,ffffffffc02011e6 <buddy_init_memmap+0x11a>
        while (order + 1 < MAX_ORDER) {
ffffffffc0201168:	0705                	addi	a4,a4,1
ffffffffc020116a:	ffc713e3          	bne	a4,t3,ffffffffc0201150 <buddy_init_memmap+0x84>
ffffffffc020116e:	000802b7          	lui	t0,0x80
ffffffffc0201172:	464d                	li	a2,19
ffffffffc0201174:	1c800813          	li	a6,456
ffffffffc0201178:	00171893          	slli	a7,a4,0x1
        struct Page* page = base + offset;//当前块的起始页
ffffffffc020117c:	002e9693          	slli	a3,t4,0x2
ffffffffc0201180:	96f6                	add	a3,a3,t4
ffffffffc0201182:	068e                	slli	a3,a3,0x3
ffffffffc0201184:	96aa                	add	a3,a3,a0
        SetPageProperty(page);//加入空闲链表
ffffffffc0201186:	669c                	ld	a5,8(a3)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0201188:	987a                	add	a6,a6,t5
        page->property = order;//设置块的order
ffffffffc020118a:	ca90                	sw	a2,16(a3)
        SetPageProperty(page);//加入空闲链表
ffffffffc020118c:	0027e793          	ori	a5,a5,2
ffffffffc0201190:	e69c                	sd	a5,8(a3)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0201192:	87c2                	mv	a5,a6
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0201194:	a029                	j	ffffffffc020119e <buddy_init_memmap+0xd2>
        struct Page *p = le2page(le, page_link);
ffffffffc0201196:	fe878613          	addi	a2,a5,-24
        if (page < p) {
ffffffffc020119a:	00c6e563          	bltu	a3,a2,ffffffffc02011a4 <buddy_init_memmap+0xd8>
ffffffffc020119e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc02011a0:	fef81be3          	bne	a6,a5,ffffffffc0201196 <buddy_init_memmap+0xca>
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc02011a4:	9746                	add	a4,a4,a7
ffffffffc02011a6:	070e                	slli	a4,a4,0x3
    __list_add(elm, listelm->prev, listelm);
ffffffffc02011a8:	0007b803          	ld	a6,0(a5)
ffffffffc02011ac:	977a                	add	a4,a4,t5
ffffffffc02011ae:	4b10                	lw	a2,16(a4)
    list_add_before(le, &(page->page_link));//插入该位置
ffffffffc02011b0:	01868893          	addi	a7,a3,24
    prev->next = next->prev = elm;
ffffffffc02011b4:	0117b023          	sd	a7,0(a5)
ffffffffc02011b8:	01183423          	sd	a7,8(a6)
    elm->next = next;
ffffffffc02011bc:	f29c                	sd	a5,32(a3)
    elm->prev = prev;
ffffffffc02011be:	0106bc23          	sd	a6,24(a3)
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc02011c2:	0016079b          	addiw	a5,a2,1
ffffffffc02011c6:	cb1c                	sw	a5,16(a4)
        offset += (1UL << order);//移动偏移
ffffffffc02011c8:	9e96                	add	t4,t4,t0
    while (offset < n) {
ffffffffc02011ca:	f6beeee3          	bltu	t4,a1,ffffffffc0201146 <buddy_init_memmap+0x7a>
    if (new_total > buddy_total_pages) {
ffffffffc02011ce:	00005797          	auipc	a5,0x5
ffffffffc02011d2:	23a78793          	addi	a5,a5,570 # ffffffffc0206408 <buddy_total_pages>
ffffffffc02011d6:	6398                	ld	a4,0(a5)
    size_t new_total = base_offset + n;
ffffffffc02011d8:	95fe                	add	a1,a1,t6
    if (new_total > buddy_total_pages) {
ffffffffc02011da:	00b77363          	bgeu	a4,a1,ffffffffc02011e0 <buddy_init_memmap+0x114>
        buddy_total_pages = new_total;
ffffffffc02011de:	e38c                	sd	a1,0(a5)
}
ffffffffc02011e0:	60a2                	ld	ra,8(sp)
ffffffffc02011e2:	0141                	addi	sp,sp,16
ffffffffc02011e4:	8082                	ret
ffffffffc02011e6:	00171893          	slli	a7,a4,0x1
ffffffffc02011ea:	00e88833          	add	a6,a7,a4
ffffffffc02011ee:	080e                	slli	a6,a6,0x3
        offset += (1UL << order);//移动偏移
ffffffffc02011f0:	00c312b3          	sll	t0,t1,a2
ffffffffc02011f4:	b761                	j	ffffffffc020117c <buddy_init_memmap+0xb0>
        buddy_base = base;
ffffffffc02011f6:	e208                	sd	a0,0(a2)
        buddy_total_pages = 0;
ffffffffc02011f8:	00005797          	auipc	a5,0x5
ffffffffc02011fc:	2007b823          	sd	zero,528(a5) # ffffffffc0206408 <buddy_total_pages>
ffffffffc0201200:	b5dd                	j	ffffffffc02010e6 <buddy_init_memmap+0x1a>
        assert(PageReserved(p));
ffffffffc0201202:	00001697          	auipc	a3,0x1
ffffffffc0201206:	ca668693          	addi	a3,a3,-858 # ffffffffc0201ea8 <kmalloc_sizes+0x3a0>
ffffffffc020120a:	00001617          	auipc	a2,0x1
ffffffffc020120e:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc0201212:	04400593          	li	a1,68
ffffffffc0201216:	00001517          	auipc	a0,0x1
ffffffffc020121a:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0201c80 <kmalloc_sizes+0x178>
ffffffffc020121e:	fa5fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0201222:	00001697          	auipc	a3,0x1
ffffffffc0201226:	c6668693          	addi	a3,a3,-922 # ffffffffc0201e88 <kmalloc_sizes+0x380>
ffffffffc020122a:	00001617          	auipc	a2,0x1
ffffffffc020122e:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc0201232:	03b00593          	li	a1,59
ffffffffc0201236:	00001517          	auipc	a0,0x1
ffffffffc020123a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0201c80 <kmalloc_sizes+0x178>
ffffffffc020123e:	f85fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(base >= buddy_base);
ffffffffc0201242:	00001697          	auipc	a3,0x1
ffffffffc0201246:	c4e68693          	addi	a3,a3,-946 # ffffffffc0201e90 <kmalloc_sizes+0x388>
ffffffffc020124a:	00001617          	auipc	a2,0x1
ffffffffc020124e:	a1e60613          	addi	a2,a2,-1506 # ffffffffc0201c68 <kmalloc_sizes+0x160>
ffffffffc0201252:	04000593          	li	a1,64
ffffffffc0201256:	00001517          	auipc	a0,0x1
ffffffffc020125a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0201c80 <kmalloc_sizes+0x178>
ffffffffc020125e:	f65fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0201262 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201262:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0201266:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0201268:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020126a:	cb81                	beqz	a5,ffffffffc020127a <strlen+0x18>
        cnt ++;
ffffffffc020126c:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020126e:	00a707b3          	add	a5,a4,a0
ffffffffc0201272:	0007c783          	lbu	a5,0(a5)
ffffffffc0201276:	fbfd                	bnez	a5,ffffffffc020126c <strlen+0xa>
ffffffffc0201278:	8082                	ret
    }
    return cnt;
}
ffffffffc020127a:	8082                	ret

ffffffffc020127c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020127c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020127e:	e589                	bnez	a1,ffffffffc0201288 <strnlen+0xc>
ffffffffc0201280:	a811                	j	ffffffffc0201294 <strnlen+0x18>
        cnt ++;
ffffffffc0201282:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201284:	00f58863          	beq	a1,a5,ffffffffc0201294 <strnlen+0x18>
ffffffffc0201288:	00f50733          	add	a4,a0,a5
ffffffffc020128c:	00074703          	lbu	a4,0(a4)
ffffffffc0201290:	fb6d                	bnez	a4,ffffffffc0201282 <strnlen+0x6>
ffffffffc0201292:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201294:	852e                	mv	a0,a1
ffffffffc0201296:	8082                	ret

ffffffffc0201298 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201298:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020129c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02012a0:	cb89                	beqz	a5,ffffffffc02012b2 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02012a2:	0505                	addi	a0,a0,1
ffffffffc02012a4:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02012a6:	fee789e3          	beq	a5,a4,ffffffffc0201298 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02012aa:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02012ae:	9d19                	subw	a0,a0,a4
ffffffffc02012b0:	8082                	ret
ffffffffc02012b2:	4501                	li	a0,0
ffffffffc02012b4:	bfed                	j	ffffffffc02012ae <strcmp+0x16>

ffffffffc02012b6 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02012b6:	c20d                	beqz	a2,ffffffffc02012d8 <strncmp+0x22>
ffffffffc02012b8:	962e                	add	a2,a2,a1
ffffffffc02012ba:	a031                	j	ffffffffc02012c6 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc02012bc:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02012be:	00e79a63          	bne	a5,a4,ffffffffc02012d2 <strncmp+0x1c>
ffffffffc02012c2:	00b60b63          	beq	a2,a1,ffffffffc02012d8 <strncmp+0x22>
ffffffffc02012c6:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02012ca:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02012cc:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02012d0:	f7f5                	bnez	a5,ffffffffc02012bc <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02012d2:	40e7853b          	subw	a0,a5,a4
}
ffffffffc02012d6:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02012d8:	4501                	li	a0,0
ffffffffc02012da:	8082                	ret

ffffffffc02012dc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02012dc:	ca01                	beqz	a2,ffffffffc02012ec <memset+0x10>
ffffffffc02012de:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02012e0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02012e2:	0785                	addi	a5,a5,1
ffffffffc02012e4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02012e8:	fec79de3          	bne	a5,a2,ffffffffc02012e2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02012ec:	8082                	ret

ffffffffc02012ee <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02012ee:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012f2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02012f4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012f8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02012fa:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012fe:	f022                	sd	s0,32(sp)
ffffffffc0201300:	ec26                	sd	s1,24(sp)
ffffffffc0201302:	e84a                	sd	s2,16(sp)
ffffffffc0201304:	f406                	sd	ra,40(sp)
ffffffffc0201306:	e44e                	sd	s3,8(sp)
ffffffffc0201308:	84aa                	mv	s1,a0
ffffffffc020130a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020130c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201310:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201312:	03067e63          	bgeu	a2,a6,ffffffffc020134e <printnum+0x60>
ffffffffc0201316:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201318:	00805763          	blez	s0,ffffffffc0201326 <printnum+0x38>
ffffffffc020131c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020131e:	85ca                	mv	a1,s2
ffffffffc0201320:	854e                	mv	a0,s3
ffffffffc0201322:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201324:	fc65                	bnez	s0,ffffffffc020131c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201326:	1a02                	slli	s4,s4,0x20
ffffffffc0201328:	00001797          	auipc	a5,0x1
ffffffffc020132c:	be078793          	addi	a5,a5,-1056 # ffffffffc0201f08 <buddy_pmm_manager+0x38>
ffffffffc0201330:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201334:	9a3e                	add	s4,s4,a5
}
ffffffffc0201336:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201338:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020133c:	70a2                	ld	ra,40(sp)
ffffffffc020133e:	69a2                	ld	s3,8(sp)
ffffffffc0201340:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201342:	85ca                	mv	a1,s2
ffffffffc0201344:	87a6                	mv	a5,s1
}
ffffffffc0201346:	6942                	ld	s2,16(sp)
ffffffffc0201348:	64e2                	ld	s1,24(sp)
ffffffffc020134a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020134c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020134e:	03065633          	divu	a2,a2,a6
ffffffffc0201352:	8722                	mv	a4,s0
ffffffffc0201354:	f9bff0ef          	jal	ra,ffffffffc02012ee <printnum>
ffffffffc0201358:	b7f9                	j	ffffffffc0201326 <printnum+0x38>

ffffffffc020135a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020135a:	7119                	addi	sp,sp,-128
ffffffffc020135c:	f4a6                	sd	s1,104(sp)
ffffffffc020135e:	f0ca                	sd	s2,96(sp)
ffffffffc0201360:	ecce                	sd	s3,88(sp)
ffffffffc0201362:	e8d2                	sd	s4,80(sp)
ffffffffc0201364:	e4d6                	sd	s5,72(sp)
ffffffffc0201366:	e0da                	sd	s6,64(sp)
ffffffffc0201368:	fc5e                	sd	s7,56(sp)
ffffffffc020136a:	f06a                	sd	s10,32(sp)
ffffffffc020136c:	fc86                	sd	ra,120(sp)
ffffffffc020136e:	f8a2                	sd	s0,112(sp)
ffffffffc0201370:	f862                	sd	s8,48(sp)
ffffffffc0201372:	f466                	sd	s9,40(sp)
ffffffffc0201374:	ec6e                	sd	s11,24(sp)
ffffffffc0201376:	892a                	mv	s2,a0
ffffffffc0201378:	84ae                	mv	s1,a1
ffffffffc020137a:	8d32                	mv	s10,a2
ffffffffc020137c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020137e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201382:	5b7d                	li	s6,-1
ffffffffc0201384:	00001a97          	auipc	s5,0x1
ffffffffc0201388:	bb8a8a93          	addi	s5,s5,-1096 # ffffffffc0201f3c <buddy_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020138c:	00001b97          	auipc	s7,0x1
ffffffffc0201390:	d8cb8b93          	addi	s7,s7,-628 # ffffffffc0202118 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201394:	000d4503          	lbu	a0,0(s10)
ffffffffc0201398:	001d0413          	addi	s0,s10,1
ffffffffc020139c:	01350a63          	beq	a0,s3,ffffffffc02013b0 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02013a0:	c121                	beqz	a0,ffffffffc02013e0 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02013a2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013a4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02013a6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013a8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02013ac:	ff351ae3          	bne	a0,s3,ffffffffc02013a0 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013b0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02013b4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02013b8:	4c81                	li	s9,0
ffffffffc02013ba:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02013bc:	5c7d                	li	s8,-1
ffffffffc02013be:	5dfd                	li	s11,-1
ffffffffc02013c0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02013c4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013c6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02013ca:	0ff5f593          	zext.b	a1,a1
ffffffffc02013ce:	00140d13          	addi	s10,s0,1
ffffffffc02013d2:	04b56263          	bltu	a0,a1,ffffffffc0201416 <vprintfmt+0xbc>
ffffffffc02013d6:	058a                	slli	a1,a1,0x2
ffffffffc02013d8:	95d6                	add	a1,a1,s5
ffffffffc02013da:	4194                	lw	a3,0(a1)
ffffffffc02013dc:	96d6                	add	a3,a3,s5
ffffffffc02013de:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02013e0:	70e6                	ld	ra,120(sp)
ffffffffc02013e2:	7446                	ld	s0,112(sp)
ffffffffc02013e4:	74a6                	ld	s1,104(sp)
ffffffffc02013e6:	7906                	ld	s2,96(sp)
ffffffffc02013e8:	69e6                	ld	s3,88(sp)
ffffffffc02013ea:	6a46                	ld	s4,80(sp)
ffffffffc02013ec:	6aa6                	ld	s5,72(sp)
ffffffffc02013ee:	6b06                	ld	s6,64(sp)
ffffffffc02013f0:	7be2                	ld	s7,56(sp)
ffffffffc02013f2:	7c42                	ld	s8,48(sp)
ffffffffc02013f4:	7ca2                	ld	s9,40(sp)
ffffffffc02013f6:	7d02                	ld	s10,32(sp)
ffffffffc02013f8:	6de2                	ld	s11,24(sp)
ffffffffc02013fa:	6109                	addi	sp,sp,128
ffffffffc02013fc:	8082                	ret
            padc = '0';
ffffffffc02013fe:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201400:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201404:	846a                	mv	s0,s10
ffffffffc0201406:	00140d13          	addi	s10,s0,1
ffffffffc020140a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020140e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201412:	fcb572e3          	bgeu	a0,a1,ffffffffc02013d6 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201416:	85a6                	mv	a1,s1
ffffffffc0201418:	02500513          	li	a0,37
ffffffffc020141c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020141e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201422:	8d22                	mv	s10,s0
ffffffffc0201424:	f73788e3          	beq	a5,s3,ffffffffc0201394 <vprintfmt+0x3a>
ffffffffc0201428:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020142c:	1d7d                	addi	s10,s10,-1
ffffffffc020142e:	ff379de3          	bne	a5,s3,ffffffffc0201428 <vprintfmt+0xce>
ffffffffc0201432:	b78d                	j	ffffffffc0201394 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201434:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201438:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020143c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020143e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201442:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201446:	02d86463          	bltu	a6,a3,ffffffffc020146e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020144a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020144e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201452:	0186873b          	addw	a4,a3,s8
ffffffffc0201456:	0017171b          	slliw	a4,a4,0x1
ffffffffc020145a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020145c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201460:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201462:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201466:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020146a:	fed870e3          	bgeu	a6,a3,ffffffffc020144a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020146e:	f40ddce3          	bgez	s11,ffffffffc02013c6 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201472:	8de2                	mv	s11,s8
ffffffffc0201474:	5c7d                	li	s8,-1
ffffffffc0201476:	bf81                	j	ffffffffc02013c6 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201478:	fffdc693          	not	a3,s11
ffffffffc020147c:	96fd                	srai	a3,a3,0x3f
ffffffffc020147e:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201482:	00144603          	lbu	a2,1(s0)
ffffffffc0201486:	2d81                	sext.w	s11,s11
ffffffffc0201488:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020148a:	bf35                	j	ffffffffc02013c6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020148c:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201490:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201494:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201496:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201498:	bfd9                	j	ffffffffc020146e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020149a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020149c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02014a0:	01174463          	blt	a4,a7,ffffffffc02014a8 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02014a4:	1a088e63          	beqz	a7,ffffffffc0201660 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02014a8:	000a3603          	ld	a2,0(s4)
ffffffffc02014ac:	46c1                	li	a3,16
ffffffffc02014ae:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02014b0:	2781                	sext.w	a5,a5
ffffffffc02014b2:	876e                	mv	a4,s11
ffffffffc02014b4:	85a6                	mv	a1,s1
ffffffffc02014b6:	854a                	mv	a0,s2
ffffffffc02014b8:	e37ff0ef          	jal	ra,ffffffffc02012ee <printnum>
            break;
ffffffffc02014bc:	bde1                	j	ffffffffc0201394 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02014be:	000a2503          	lw	a0,0(s4)
ffffffffc02014c2:	85a6                	mv	a1,s1
ffffffffc02014c4:	0a21                	addi	s4,s4,8
ffffffffc02014c6:	9902                	jalr	s2
            break;
ffffffffc02014c8:	b5f1                	j	ffffffffc0201394 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02014ca:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02014cc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02014d0:	01174463          	blt	a4,a7,ffffffffc02014d8 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02014d4:	18088163          	beqz	a7,ffffffffc0201656 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02014d8:	000a3603          	ld	a2,0(s4)
ffffffffc02014dc:	46a9                	li	a3,10
ffffffffc02014de:	8a2e                	mv	s4,a1
ffffffffc02014e0:	bfc1                	j	ffffffffc02014b0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014e2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02014e6:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014e8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014ea:	bdf1                	j	ffffffffc02013c6 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02014ec:	85a6                	mv	a1,s1
ffffffffc02014ee:	02500513          	li	a0,37
ffffffffc02014f2:	9902                	jalr	s2
            break;
ffffffffc02014f4:	b545                	j	ffffffffc0201394 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014f6:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02014fa:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014fc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014fe:	b5e1                	j	ffffffffc02013c6 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201500:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201502:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201506:	01174463          	blt	a4,a7,ffffffffc020150e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020150a:	14088163          	beqz	a7,ffffffffc020164c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020150e:	000a3603          	ld	a2,0(s4)
ffffffffc0201512:	46a1                	li	a3,8
ffffffffc0201514:	8a2e                	mv	s4,a1
ffffffffc0201516:	bf69                	j	ffffffffc02014b0 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201518:	03000513          	li	a0,48
ffffffffc020151c:	85a6                	mv	a1,s1
ffffffffc020151e:	e03e                	sd	a5,0(sp)
ffffffffc0201520:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201522:	85a6                	mv	a1,s1
ffffffffc0201524:	07800513          	li	a0,120
ffffffffc0201528:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020152a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020152c:	6782                	ld	a5,0(sp)
ffffffffc020152e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201530:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201534:	bfb5                	j	ffffffffc02014b0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201536:	000a3403          	ld	s0,0(s4)
ffffffffc020153a:	008a0713          	addi	a4,s4,8
ffffffffc020153e:	e03a                	sd	a4,0(sp)
ffffffffc0201540:	14040263          	beqz	s0,ffffffffc0201684 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201544:	0fb05763          	blez	s11,ffffffffc0201632 <vprintfmt+0x2d8>
ffffffffc0201548:	02d00693          	li	a3,45
ffffffffc020154c:	0cd79163          	bne	a5,a3,ffffffffc020160e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201550:	00044783          	lbu	a5,0(s0)
ffffffffc0201554:	0007851b          	sext.w	a0,a5
ffffffffc0201558:	cf85                	beqz	a5,ffffffffc0201590 <vprintfmt+0x236>
ffffffffc020155a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020155e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201562:	000c4563          	bltz	s8,ffffffffc020156c <vprintfmt+0x212>
ffffffffc0201566:	3c7d                	addiw	s8,s8,-1
ffffffffc0201568:	036c0263          	beq	s8,s6,ffffffffc020158c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020156c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020156e:	0e0c8e63          	beqz	s9,ffffffffc020166a <vprintfmt+0x310>
ffffffffc0201572:	3781                	addiw	a5,a5,-32
ffffffffc0201574:	0ef47b63          	bgeu	s0,a5,ffffffffc020166a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201578:	03f00513          	li	a0,63
ffffffffc020157c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020157e:	000a4783          	lbu	a5,0(s4)
ffffffffc0201582:	3dfd                	addiw	s11,s11,-1
ffffffffc0201584:	0a05                	addi	s4,s4,1
ffffffffc0201586:	0007851b          	sext.w	a0,a5
ffffffffc020158a:	ffe1                	bnez	a5,ffffffffc0201562 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020158c:	01b05963          	blez	s11,ffffffffc020159e <vprintfmt+0x244>
ffffffffc0201590:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201592:	85a6                	mv	a1,s1
ffffffffc0201594:	02000513          	li	a0,32
ffffffffc0201598:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020159a:	fe0d9be3          	bnez	s11,ffffffffc0201590 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020159e:	6a02                	ld	s4,0(sp)
ffffffffc02015a0:	bbd5                	j	ffffffffc0201394 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02015a2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02015a4:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02015a8:	01174463          	blt	a4,a7,ffffffffc02015b0 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02015ac:	08088d63          	beqz	a7,ffffffffc0201646 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02015b0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02015b4:	0a044d63          	bltz	s0,ffffffffc020166e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02015b8:	8622                	mv	a2,s0
ffffffffc02015ba:	8a66                	mv	s4,s9
ffffffffc02015bc:	46a9                	li	a3,10
ffffffffc02015be:	bdcd                	j	ffffffffc02014b0 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02015c0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015c4:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02015c6:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02015c8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02015cc:	8fb5                	xor	a5,a5,a3
ffffffffc02015ce:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015d2:	02d74163          	blt	a4,a3,ffffffffc02015f4 <vprintfmt+0x29a>
ffffffffc02015d6:	00369793          	slli	a5,a3,0x3
ffffffffc02015da:	97de                	add	a5,a5,s7
ffffffffc02015dc:	639c                	ld	a5,0(a5)
ffffffffc02015de:	cb99                	beqz	a5,ffffffffc02015f4 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02015e0:	86be                	mv	a3,a5
ffffffffc02015e2:	00001617          	auipc	a2,0x1
ffffffffc02015e6:	95660613          	addi	a2,a2,-1706 # ffffffffc0201f38 <buddy_pmm_manager+0x68>
ffffffffc02015ea:	85a6                	mv	a1,s1
ffffffffc02015ec:	854a                	mv	a0,s2
ffffffffc02015ee:	0ce000ef          	jal	ra,ffffffffc02016bc <printfmt>
ffffffffc02015f2:	b34d                	j	ffffffffc0201394 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02015f4:	00001617          	auipc	a2,0x1
ffffffffc02015f8:	93460613          	addi	a2,a2,-1740 # ffffffffc0201f28 <buddy_pmm_manager+0x58>
ffffffffc02015fc:	85a6                	mv	a1,s1
ffffffffc02015fe:	854a                	mv	a0,s2
ffffffffc0201600:	0bc000ef          	jal	ra,ffffffffc02016bc <printfmt>
ffffffffc0201604:	bb41                	j	ffffffffc0201394 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201606:	00001417          	auipc	s0,0x1
ffffffffc020160a:	91a40413          	addi	s0,s0,-1766 # ffffffffc0201f20 <buddy_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020160e:	85e2                	mv	a1,s8
ffffffffc0201610:	8522                	mv	a0,s0
ffffffffc0201612:	e43e                	sd	a5,8(sp)
ffffffffc0201614:	c69ff0ef          	jal	ra,ffffffffc020127c <strnlen>
ffffffffc0201618:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020161c:	01b05b63          	blez	s11,ffffffffc0201632 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201620:	67a2                	ld	a5,8(sp)
ffffffffc0201622:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201626:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201628:	85a6                	mv	a1,s1
ffffffffc020162a:	8552                	mv	a0,s4
ffffffffc020162c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020162e:	fe0d9ce3          	bnez	s11,ffffffffc0201626 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201632:	00044783          	lbu	a5,0(s0)
ffffffffc0201636:	00140a13          	addi	s4,s0,1
ffffffffc020163a:	0007851b          	sext.w	a0,a5
ffffffffc020163e:	d3a5                	beqz	a5,ffffffffc020159e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201640:	05e00413          	li	s0,94
ffffffffc0201644:	bf39                	j	ffffffffc0201562 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201646:	000a2403          	lw	s0,0(s4)
ffffffffc020164a:	b7ad                	j	ffffffffc02015b4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020164c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201650:	46a1                	li	a3,8
ffffffffc0201652:	8a2e                	mv	s4,a1
ffffffffc0201654:	bdb1                	j	ffffffffc02014b0 <vprintfmt+0x156>
ffffffffc0201656:	000a6603          	lwu	a2,0(s4)
ffffffffc020165a:	46a9                	li	a3,10
ffffffffc020165c:	8a2e                	mv	s4,a1
ffffffffc020165e:	bd89                	j	ffffffffc02014b0 <vprintfmt+0x156>
ffffffffc0201660:	000a6603          	lwu	a2,0(s4)
ffffffffc0201664:	46c1                	li	a3,16
ffffffffc0201666:	8a2e                	mv	s4,a1
ffffffffc0201668:	b5a1                	j	ffffffffc02014b0 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020166a:	9902                	jalr	s2
ffffffffc020166c:	bf09                	j	ffffffffc020157e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020166e:	85a6                	mv	a1,s1
ffffffffc0201670:	02d00513          	li	a0,45
ffffffffc0201674:	e03e                	sd	a5,0(sp)
ffffffffc0201676:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201678:	6782                	ld	a5,0(sp)
ffffffffc020167a:	8a66                	mv	s4,s9
ffffffffc020167c:	40800633          	neg	a2,s0
ffffffffc0201680:	46a9                	li	a3,10
ffffffffc0201682:	b53d                	j	ffffffffc02014b0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201684:	03b05163          	blez	s11,ffffffffc02016a6 <vprintfmt+0x34c>
ffffffffc0201688:	02d00693          	li	a3,45
ffffffffc020168c:	f6d79de3          	bne	a5,a3,ffffffffc0201606 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201690:	00001417          	auipc	s0,0x1
ffffffffc0201694:	89040413          	addi	s0,s0,-1904 # ffffffffc0201f20 <buddy_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201698:	02800793          	li	a5,40
ffffffffc020169c:	02800513          	li	a0,40
ffffffffc02016a0:	00140a13          	addi	s4,s0,1
ffffffffc02016a4:	bd6d                	j	ffffffffc020155e <vprintfmt+0x204>
ffffffffc02016a6:	00001a17          	auipc	s4,0x1
ffffffffc02016aa:	87ba0a13          	addi	s4,s4,-1925 # ffffffffc0201f21 <buddy_pmm_manager+0x51>
ffffffffc02016ae:	02800513          	li	a0,40
ffffffffc02016b2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016b6:	05e00413          	li	s0,94
ffffffffc02016ba:	b565                	j	ffffffffc0201562 <vprintfmt+0x208>

ffffffffc02016bc <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016bc:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02016be:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016c2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02016c4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016c6:	ec06                	sd	ra,24(sp)
ffffffffc02016c8:	f83a                	sd	a4,48(sp)
ffffffffc02016ca:	fc3e                	sd	a5,56(sp)
ffffffffc02016cc:	e0c2                	sd	a6,64(sp)
ffffffffc02016ce:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02016d0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02016d2:	c89ff0ef          	jal	ra,ffffffffc020135a <vprintfmt>
}
ffffffffc02016d6:	60e2                	ld	ra,24(sp)
ffffffffc02016d8:	6161                	addi	sp,sp,80
ffffffffc02016da:	8082                	ret

ffffffffc02016dc <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02016dc:	4781                	li	a5,0
ffffffffc02016de:	00005717          	auipc	a4,0x5
ffffffffc02016e2:	93273703          	ld	a4,-1742(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc02016e6:	88ba                	mv	a7,a4
ffffffffc02016e8:	852a                	mv	a0,a0
ffffffffc02016ea:	85be                	mv	a1,a5
ffffffffc02016ec:	863e                	mv	a2,a5
ffffffffc02016ee:	00000073          	ecall
ffffffffc02016f2:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02016f4:	8082                	ret
