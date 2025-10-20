
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
ffffffffc020004c:	00002517          	auipc	a0,0x2
ffffffffc0200050:	88c50513          	addi	a0,a0,-1908 # ffffffffc02018d8 <etext>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00002517          	auipc	a0,0x2
ffffffffc0200066:	89650513          	addi	a0,a0,-1898 # ffffffffc02018f8 <etext+0x20>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00002597          	auipc	a1,0x2
ffffffffc0200072:	86a58593          	addi	a1,a1,-1942 # ffffffffc02018d8 <etext>
ffffffffc0200076:	00002517          	auipc	a0,0x2
ffffffffc020007a:	8a250513          	addi	a0,a0,-1886 # ffffffffc0201918 <etext+0x40>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <kmalloc_caches>
ffffffffc020008a:	00002517          	auipc	a0,0x2
ffffffffc020008e:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0201938 <etext+0x60>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00006597          	auipc	a1,0x6
ffffffffc020009a:	30a58593          	addi	a1,a1,778 # ffffffffc02063a0 <end>
ffffffffc020009e:	00002517          	auipc	a0,0x2
ffffffffc02000a2:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0201958 <etext+0x80>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00006597          	auipc	a1,0x6
ffffffffc02000ae:	6f558593          	addi	a1,a1,1781 # ffffffffc020679f <end+0x3ff>
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
ffffffffc02000cc:	00002517          	auipc	a0,0x2
ffffffffc02000d0:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0201978 <etext+0xa0>
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
ffffffffc02000e4:	2c060613          	addi	a2,a2,704 # ffffffffc02063a0 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	3ce010ef          	jal	ra,ffffffffc02014be <memset>
    dtb_init();
ffffffffc02000f4:	122000ef          	jal	ra,ffffffffc0200216 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	4ce000ef          	jal	ra,ffffffffc02005c6 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00002517          	auipc	a0,0x2
ffffffffc0200100:	8ac50513          	addi	a0,a0,-1876 # ffffffffc02019a8 <etext+0xd0>
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
ffffffffc0200140:	3fc010ef          	jal	ra,ffffffffc020153c <vprintfmt>
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
ffffffffc0200176:	3c6010ef          	jal	ra,ffffffffc020153c <vprintfmt>
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
ffffffffc02001c6:	17e30313          	addi	t1,t1,382 # ffffffffc0206340 <is_panic>
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
ffffffffc02001f6:	7d650513          	addi	a0,a0,2006 # ffffffffc02019c8 <etext+0xf0>
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
ffffffffc020020c:	e9050513          	addi	a0,a0,-368 # ffffffffc0202098 <kmalloc_sizes+0x328>
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
ffffffffc020021c:	7d050513          	addi	a0,a0,2000 # ffffffffc02019e8 <etext+0x110>
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
ffffffffc020024a:	7b250513          	addi	a0,a0,1970 # ffffffffc02019f8 <etext+0x120>
ffffffffc020024e:	effff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200252:	00006417          	auipc	s0,0x6
ffffffffc0200256:	db640413          	addi	s0,s0,-586 # ffffffffc0206008 <boot_dtb>
ffffffffc020025a:	600c                	ld	a1,0(s0)
ffffffffc020025c:	00001517          	auipc	a0,0x1
ffffffffc0200260:	7ac50513          	addi	a0,a0,1964 # ffffffffc0201a08 <etext+0x130>
ffffffffc0200264:	ee9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200268:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020026c:	00001517          	auipc	a0,0x1
ffffffffc0200270:	7b450513          	addi	a0,a0,1972 # ffffffffc0201a20 <etext+0x148>
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
ffffffffc02002b4:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed9b4d>
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
ffffffffc020032a:	74a90913          	addi	s2,s2,1866 # ffffffffc0201a70 <etext+0x198>
ffffffffc020032e:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200330:	4d91                	li	s11,4
ffffffffc0200332:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200334:	00001497          	auipc	s1,0x1
ffffffffc0200338:	73448493          	addi	s1,s1,1844 # ffffffffc0201a68 <etext+0x190>
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
ffffffffc020038c:	76050513          	addi	a0,a0,1888 # ffffffffc0201ae8 <etext+0x210>
ffffffffc0200390:	dbdff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200394:	00001517          	auipc	a0,0x1
ffffffffc0200398:	78c50513          	addi	a0,a0,1932 # ffffffffc0201b20 <etext+0x248>
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
ffffffffc02003d8:	66c50513          	addi	a0,a0,1644 # ffffffffc0201a40 <etext+0x168>
}
ffffffffc02003dc:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003de:	b3bd                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003e0:	8556                	mv	a0,s5
ffffffffc02003e2:	062010ef          	jal	ra,ffffffffc0201444 <strlen>
ffffffffc02003e6:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e8:	4619                	li	a2,6
ffffffffc02003ea:	85a6                	mv	a1,s1
ffffffffc02003ec:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003ee:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f0:	0a8010ef          	jal	ra,ffffffffc0201498 <strncmp>
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
ffffffffc0200486:	7f5000ef          	jal	ra,ffffffffc020147a <strcmp>
ffffffffc020048a:	66a2                	ld	a3,8(sp)
ffffffffc020048c:	f94d                	bnez	a0,ffffffffc020043e <dtb_init+0x228>
ffffffffc020048e:	fb59f8e3          	bgeu	s3,s5,ffffffffc020043e <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200492:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200496:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020049a:	00001517          	auipc	a0,0x1
ffffffffc020049e:	5de50513          	addi	a0,a0,1502 # ffffffffc0201a78 <etext+0x1a0>
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
ffffffffc020056c:	53050513          	addi	a0,a0,1328 # ffffffffc0201a98 <etext+0x1c0>
ffffffffc0200570:	bddff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200574:	014b5613          	srli	a2,s6,0x14
ffffffffc0200578:	85da                	mv	a1,s6
ffffffffc020057a:	00001517          	auipc	a0,0x1
ffffffffc020057e:	53650513          	addi	a0,a0,1334 # ffffffffc0201ab0 <etext+0x1d8>
ffffffffc0200582:	bcbff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200586:	008b05b3          	add	a1,s6,s0
ffffffffc020058a:	15fd                	addi	a1,a1,-1
ffffffffc020058c:	00001517          	auipc	a0,0x1
ffffffffc0200590:	54450513          	addi	a0,a0,1348 # ffffffffc0201ad0 <etext+0x1f8>
ffffffffc0200594:	bb9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	58850513          	addi	a0,a0,1416 # ffffffffc0201b20 <etext+0x248>
        memory_base = mem_base;
ffffffffc02005a0:	00006797          	auipc	a5,0x6
ffffffffc02005a4:	da87b423          	sd	s0,-600(a5) # ffffffffc0206348 <memory_base>
        memory_size = mem_size;
ffffffffc02005a8:	00006797          	auipc	a5,0x6
ffffffffc02005ac:	db67b423          	sd	s6,-600(a5) # ffffffffc0206350 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005b0:	b3f5                	j	ffffffffc020039c <dtb_init+0x186>

ffffffffc02005b2 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005b2:	00006517          	auipc	a0,0x6
ffffffffc02005b6:	d9653503          	ld	a0,-618(a0) # ffffffffc0206348 <memory_base>
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005bc:	00006517          	auipc	a0,0x6
ffffffffc02005c0:	d9453503          	ld	a0,-620(a0) # ffffffffc0206350 <memory_size>
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
ffffffffc02005cc:	2f20106f          	j	ffffffffc02018be <sbi_console_putchar>

ffffffffc02005d0 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc02005d0:	00006797          	auipc	a5,0x6
ffffffffc02005d4:	d987b783          	ld	a5,-616(a5) # ffffffffc0206368 <pmm_manager>
ffffffffc02005d8:	6f9c                	ld	a5,24(a5)
ffffffffc02005da:	8782                	jr	a5

ffffffffc02005dc <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc02005dc:	00006797          	auipc	a5,0x6
ffffffffc02005e0:	d8c7b783          	ld	a5,-628(a5) # ffffffffc0206368 <pmm_manager>
ffffffffc02005e4:	739c                	ld	a5,32(a5)
ffffffffc02005e6:	8782                	jr	a5

ffffffffc02005e8 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc02005e8:	00002797          	auipc	a5,0x2
ffffffffc02005ec:	b0078793          	addi	a5,a5,-1280 # ffffffffc02020e8 <buddy_pmm_manager>
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
ffffffffc02005fa:	54250513          	addi	a0,a0,1346 # ffffffffc0201b38 <etext+0x260>
    pmm_manager = &buddy_pmm_manager;
ffffffffc02005fe:	00006417          	auipc	s0,0x6
ffffffffc0200602:	d6a40413          	addi	s0,s0,-662 # ffffffffc0206368 <pmm_manager>
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
ffffffffc020061c:	d6848493          	addi	s1,s1,-664 # ffffffffc0206380 <va_pa_offset>
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
ffffffffc020063e:	54650513          	addi	a0,a0,1350 # ffffffffc0201b80 <etext+0x2a8>
ffffffffc0200642:	b0bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200646:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020064a:	864e                	mv	a2,s3
ffffffffc020064c:	fffa0693          	addi	a3,s4,-1
ffffffffc0200650:	85ca                	mv	a1,s2
ffffffffc0200652:	00001517          	auipc	a0,0x1
ffffffffc0200656:	54650513          	addi	a0,a0,1350 # ffffffffc0201b98 <etext+0x2c0>
ffffffffc020065a:	af3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020065e:	c80007b7          	lui	a5,0xc8000
ffffffffc0200662:	8652                	mv	a2,s4
ffffffffc0200664:	0d47e563          	bltu	a5,s4,ffffffffc020072e <pmm_init+0x146>
ffffffffc0200668:	00007797          	auipc	a5,0x7
ffffffffc020066c:	d3778793          	addi	a5,a5,-713 # ffffffffc020739f <end+0xfff>
ffffffffc0200670:	757d                	lui	a0,0xfffff
ffffffffc0200672:	8d7d                	and	a0,a0,a5
ffffffffc0200674:	8231                	srli	a2,a2,0xc
ffffffffc0200676:	00006797          	auipc	a5,0x6
ffffffffc020067a:	cec7b123          	sd	a2,-798(a5) # ffffffffc0206358 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020067e:	00006797          	auipc	a5,0x6
ffffffffc0200682:	cea7b123          	sd	a0,-798(a5) # ffffffffc0206360 <pages>
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
ffffffffc02006a8:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f9c88>
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
ffffffffc02006e4:	54050513          	addi	a0,a0,1344 # ffffffffc0201c20 <etext+0x348>
ffffffffc02006e8:	a65ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    slub_check();
ffffffffc02006ec:	280000ef          	jal	ra,ffffffffc020096c <slub_check>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02006f0:	00005597          	auipc	a1,0x5
ffffffffc02006f4:	91058593          	addi	a1,a1,-1776 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02006f8:	00006797          	auipc	a5,0x6
ffffffffc02006fc:	c8b7b023          	sd	a1,-896(a5) # ffffffffc0206378 <satp_virtual>
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
ffffffffc020071e:	c4c7bb23          	sd	a2,-938(a5) # ffffffffc0206370 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200722:	00001517          	auipc	a0,0x1
ffffffffc0200726:	51e50513          	addi	a0,a0,1310 # ffffffffc0201c40 <etext+0x368>
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
ffffffffc0200764:	49060613          	addi	a2,a2,1168 # ffffffffc0201bf0 <etext+0x318>
ffffffffc0200768:	06800593          	li	a1,104
ffffffffc020076c:	00001517          	auipc	a0,0x1
ffffffffc0200770:	4a450513          	addi	a0,a0,1188 # ffffffffc0201c10 <etext+0x338>
ffffffffc0200774:	a4fff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200778:	00001617          	auipc	a2,0x1
ffffffffc020077c:	45060613          	addi	a2,a2,1104 # ffffffffc0201bc8 <etext+0x2f0>
ffffffffc0200780:	06000593          	li	a1,96
ffffffffc0200784:	00001517          	auipc	a0,0x1
ffffffffc0200788:	3ec50513          	addi	a0,a0,1004 # ffffffffc0201b70 <etext+0x298>
ffffffffc020078c:	a37ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc0200790:	00001617          	auipc	a2,0x1
ffffffffc0200794:	3c060613          	addi	a2,a2,960 # ffffffffc0201b50 <etext+0x278>
ffffffffc0200798:	04800593          	li	a1,72
ffffffffc020079c:	00001517          	auipc	a0,0x1
ffffffffc02007a0:	3d450513          	addi	a0,a0,980 # ffffffffc0201b70 <etext+0x298>
ffffffffc02007a4:	a1fff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02007a8:	86ae                	mv	a3,a1
ffffffffc02007aa:	00001617          	auipc	a2,0x1
ffffffffc02007ae:	41e60613          	addi	a2,a2,1054 # ffffffffc0201bc8 <etext+0x2f0>
ffffffffc02007b2:	07b00593          	li	a1,123
ffffffffc02007b6:	00001517          	auipc	a0,0x1
ffffffffc02007ba:	3ba50513          	addi	a0,a0,954 # ffffffffc0201b70 <etext+0x298>
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
ffffffffc02007f6:	02868713          	addi	a4,a3,40 # fffffffffec00028 <end+0x3e9f9c88>
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
ffffffffc0200824:	b406b683          	ld	a3,-1216(a3) # ffffffffc0206360 <pages>
ffffffffc0200828:	40d506b3          	sub	a3,a0,a3
ffffffffc020082c:	00002797          	auipc	a5,0x2
ffffffffc0200830:	b447b783          	ld	a5,-1212(a5) # ffffffffc0202370 <nbase+0x8>
ffffffffc0200834:	868d                	srai	a3,a3,0x3
ffffffffc0200836:	02f686b3          	mul	a3,a3,a5
ffffffffc020083a:	00002797          	auipc	a5,0x2
ffffffffc020083e:	b2e7b783          	ld	a5,-1234(a5) # ffffffffc0202368 <nbase>
        struct slab *ns = (struct slab*)KADDR(page2pa(page));
ffffffffc0200842:	00006717          	auipc	a4,0x6
ffffffffc0200846:	b1673703          	ld	a4,-1258(a4) # ffffffffc0206358 <npage>
ffffffffc020084a:	96be                	add	a3,a3,a5
ffffffffc020084c:	00c69793          	slli	a5,a3,0xc
ffffffffc0200850:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200852:	06b2                	slli	a3,a3,0xc
ffffffffc0200854:	04e7fc63          	bgeu	a5,a4,ffffffffc02008ac <__cache_alloc+0xea>
ffffffffc0200858:	00006797          	auipc	a5,0x6
ffffffffc020085c:	b287b783          	ld	a5,-1240(a5) # ffffffffc0206380 <va_pa_offset>
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
ffffffffc02008b0:	3d460613          	addi	a2,a2,980 # ffffffffc0201c80 <etext+0x3a8>
ffffffffc02008b4:	04000593          	li	a1,64
ffffffffc02008b8:	00001517          	auipc	a0,0x1
ffffffffc02008bc:	3f050513          	addi	a0,a0,1008 # ffffffffc0201ca8 <etext+0x3d0>
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
ffffffffc02008d2:	01878813          	addi	a6,a5,24 # fffffffffffff018 <end+0x3fdf8c78>
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
        // else{
        //     list_del(&slab->list_link);
        //     free_pages(slab->page, 1);
        // }
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
ffffffffc020092a:	44a68693          	addi	a3,a3,1098 # ffffffffc0201d70 <kmalloc_sizes>
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
ffffffffc020096c:	715d                	addi	sp,sp,-80
ffffffffc020096e:	e0a2                	sd	s0,64(sp)
ffffffffc0200970:	fc26                	sd	s1,56(sp)
ffffffffc0200972:	00005417          	auipc	s0,0x5
ffffffffc0200976:	6a640413          	addi	s0,s0,1702 # ffffffffc0206018 <kmalloc_caches>
ffffffffc020097a:	e486                	sd	ra,72(sp)
ffffffffc020097c:	f84a                	sd	s2,48(sp)
ffffffffc020097e:	f44e                	sd	s3,40(sp)
ffffffffc0200980:	f052                	sd	s4,32(sp)
ffffffffc0200982:	ec56                	sd	s5,24(sp)
ffffffffc0200984:	e85a                	sd	s6,16(sp)
ffffffffc0200986:	e45e                	sd	s7,8(sp)
    slub_init();
ffffffffc0200988:	f95ff0ef          	jal	ra,ffffffffc020091c <slub_init>
ffffffffc020098c:	84a2                	mv	s1,s0
ffffffffc020098e:	8722                	mv	a4,s0
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200990:	4781                	li	a5,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200992:	07f00613          	li	a2,127
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200996:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200998:	6714                	ld	a3,8(a4)
ffffffffc020099a:	24d66163          	bltu	a2,a3,ffffffffc0200bdc <slub_check+0x270>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc020099e:	2785                	addiw	a5,a5,1
ffffffffc02009a0:	03870713          	addi	a4,a4,56
ffffffffc02009a4:	feb79ae3          	bne	a5,a1,ffffffffc0200998 <slub_check+0x2c>
ffffffffc02009a8:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc02009ac:	9526                	add	a0,a0,s1
ffffffffc02009ae:	e15ff0ef          	jal	ra,ffffffffc02007c2 <__cache_alloc>
ffffffffc02009b2:	00005497          	auipc	s1,0x5
ffffffffc02009b6:	66648493          	addi	s1,s1,1638 # ffffffffc0206018 <kmalloc_caches>
ffffffffc02009ba:	892a                	mv	s2,a0
ffffffffc02009bc:	8726                	mv	a4,s1
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009be:	4781                	li	a5,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009c0:	07f00613          	li	a2,127
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009c4:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009c6:	6714                	ld	a3,8(a4)
ffffffffc02009c8:	24d66c63          	bltu	a2,a3,ffffffffc0200c20 <slub_check+0x2b4>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009cc:	2785                	addiw	a5,a5,1
ffffffffc02009ce:	03870713          	addi	a4,a4,56
ffffffffc02009d2:	feb79ae3          	bne	a5,a1,ffffffffc02009c6 <slub_check+0x5a>
ffffffffc02009d6:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc02009da:	9526                	add	a0,a0,s1
ffffffffc02009dc:	de7ff0ef          	jal	ra,ffffffffc02007c2 <__cache_alloc>
ffffffffc02009e0:	00005497          	auipc	s1,0x5
ffffffffc02009e4:	63848493          	addi	s1,s1,1592 # ffffffffc0206018 <kmalloc_caches>
ffffffffc02009e8:	89aa                	mv	s3,a0
ffffffffc02009ea:	8726                	mv	a4,s1
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009ec:	4781                	li	a5,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009ee:	3ff00613          	li	a2,1023
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009f2:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009f4:	6714                	ld	a3,8(a4)
ffffffffc02009f6:	20d66e63          	bltu	a2,a3,ffffffffc0200c12 <slub_check+0x2a6>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009fa:	2785                	addiw	a5,a5,1
ffffffffc02009fc:	03870713          	addi	a4,a4,56
ffffffffc0200a00:	feb79ae3          	bne	a5,a1,ffffffffc02009f4 <slub_check+0x88>
ffffffffc0200a04:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200a08:	9526                	add	a0,a0,s1
ffffffffc0200a0a:	db9ff0ef          	jal	ra,ffffffffc02007c2 <__cache_alloc>
ffffffffc0200a0e:	00005497          	auipc	s1,0x5
ffffffffc0200a12:	60a48493          	addi	s1,s1,1546 # ffffffffc0206018 <kmalloc_caches>
ffffffffc0200a16:	8aaa                	mv	s5,a0
ffffffffc0200a18:	8726                	mv	a4,s1
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a1a:	4781                	li	a5,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a1c:	3ff00613          	li	a2,1023
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a20:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a22:	6714                	ld	a3,8(a4)
ffffffffc0200a24:	1ed66063          	bltu	a2,a3,ffffffffc0200c04 <slub_check+0x298>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a28:	2785                	addiw	a5,a5,1
ffffffffc0200a2a:	03870713          	addi	a4,a4,56
ffffffffc0200a2e:	feb79ae3          	bne	a5,a1,ffffffffc0200a22 <slub_check+0xb6>
ffffffffc0200a32:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200a36:	9526                	add	a0,a0,s1
ffffffffc0200a38:	d8bff0ef          	jal	ra,ffffffffc02007c2 <__cache_alloc>
ffffffffc0200a3c:	00005497          	auipc	s1,0x5
ffffffffc0200a40:	5dc48493          	addi	s1,s1,1500 # ffffffffc0206018 <kmalloc_caches>
ffffffffc0200a44:	8a2a                	mv	s4,a0
ffffffffc0200a46:	8826                	mv	a6,s1
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a48:	4781                	li	a5,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a4a:	3ff00693          	li	a3,1023
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a4e:	4621                	li	a2,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a50:	00883703          	ld	a4,8(a6)
ffffffffc0200a54:	1ae6e163          	bltu	a3,a4,ffffffffc0200bf6 <slub_check+0x28a>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a58:	2785                	addiw	a5,a5,1
ffffffffc0200a5a:	03880813          	addi	a6,a6,56
ffffffffc0200a5e:	fec799e3          	bne	a5,a2,ffffffffc0200a50 <slub_check+0xe4>
ffffffffc0200a62:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200a66:	9526                	add	a0,a0,s1
ffffffffc0200a68:	d5bff0ef          	jal	ra,ffffffffc02007c2 <__cache_alloc>
ffffffffc0200a6c:	00005497          	auipc	s1,0x5
ffffffffc0200a70:	5ac48493          	addi	s1,s1,1452 # ffffffffc0206018 <kmalloc_caches>
ffffffffc0200a74:	8b2a                	mv	s6,a0
ffffffffc0200a76:	88a6                	mv	a7,s1
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a78:	4801                	li	a6,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a7a:	3ff00713          	li	a4,1023
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a7e:	46a1                	li	a3,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a80:	0088b783          	ld	a5,8(a7)
ffffffffc0200a84:	16f76363          	bltu	a4,a5,ffffffffc0200bea <slub_check+0x27e>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a88:	2805                	addiw	a6,a6,1
ffffffffc0200a8a:	03888893          	addi	a7,a7,56
ffffffffc0200a8e:	fed819e3          	bne	a6,a3,ffffffffc0200a80 <slub_check+0x114>
ffffffffc0200a92:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200a96:	9526                	add	a0,a0,s1
ffffffffc0200a98:	d2bff0ef          	jal	ra,ffffffffc02007c2 <__cache_alloc>
ffffffffc0200a9c:	8baa                	mv	s7,a0
    void *p4 = kmalloc_bytes(1024);  // 映射到1024B等级
    void *p5 = kmalloc_bytes(1024);  // 映射到1024B等级
    void *p6 = kmalloc_bytes(1024);  // 映射到1024B等级

    // 验证分配成功（地址非空）
    cprintf("p1=%p, p2=%p, p3=%p,p4=%p, p5=%p, p6=%p\n",p1, p2, p3, p4, p5, p6);
ffffffffc0200a9e:	882a                	mv	a6,a0
ffffffffc0200aa0:	87da                	mv	a5,s6
ffffffffc0200aa2:	8752                	mv	a4,s4
ffffffffc0200aa4:	86d6                	mv	a3,s5
ffffffffc0200aa6:	864e                	mv	a2,s3
ffffffffc0200aa8:	85ca                	mv	a1,s2
ffffffffc0200aaa:	00001517          	auipc	a0,0x1
ffffffffc0200aae:	20e50513          	addi	a0,a0,526 # ffffffffc0201cb8 <etext+0x3e0>
ffffffffc0200ab2:	e9aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200ab6:	18090a63          	beqz	s2,ffffffffc0200c4a <slub_check+0x2de>
ffffffffc0200aba:	18098863          	beqz	s3,ffffffffc0200c4a <slub_check+0x2de>
ffffffffc0200abe:	180a8663          	beqz	s5,ffffffffc0200c4a <slub_check+0x2de>
ffffffffc0200ac2:	180a0463          	beqz	s4,ffffffffc0200c4a <slub_check+0x2de>
ffffffffc0200ac6:	180b0263          	beqz	s6,ffffffffc0200c4a <slub_check+0x2de>
ffffffffc0200aca:	180b8063          	beqz	s7,ffffffffc0200c4a <slub_check+0x2de>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200ace:	77fd                	lui	a5,0xfffff
ffffffffc0200ad0:	00faf7b3          	and	a5,s5,a5
    __cache_free(sl->cache, ptr);
ffffffffc0200ad4:	6388                	ld	a0,0(a5)
ffffffffc0200ad6:	85d6                	mv	a1,s5
ffffffffc0200ad8:	dedff0ef          	jal	ra,ffffffffc02008c4 <__cache_free>
ffffffffc0200adc:	00005617          	auipc	a2,0x5
ffffffffc0200ae0:	53c60613          	addi	a2,a2,1340 # ffffffffc0206018 <kmalloc_caches>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200ae4:	4681                	li	a3,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200ae6:	07f00713          	li	a4,127
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200aea:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200aec:	661c                	ld	a5,8(a2)
ffffffffc0200aee:	14f76763          	bltu	a4,a5,ffffffffc0200c3c <slub_check+0x2d0>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200af2:	2685                	addiw	a3,a3,1
ffffffffc0200af4:	03860613          	addi	a2,a2,56
ffffffffc0200af8:	feb69ae3          	bne	a3,a1,ffffffffc0200aec <slub_check+0x180>
ffffffffc0200afc:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200b00:	9526                	add	a0,a0,s1
ffffffffc0200b02:	cc1ff0ef          	jal	ra,ffffffffc02007c2 <__cache_alloc>
ffffffffc0200b06:	8aaa                	mv	s5,a0
    kfree_bytes(p3);

    p3 = kmalloc_bytes(128);   // 映射到128B等级

    // 验证分配成功（地址非空）
    cprintf("p1=%p, p2=%p, p3=%p,p4=%p, p5=%p, p6=%p\n",p1, p2, p3, p4, p5, p6);
ffffffffc0200b08:	86aa                	mv	a3,a0
ffffffffc0200b0a:	885e                	mv	a6,s7
ffffffffc0200b0c:	87da                	mv	a5,s6
ffffffffc0200b0e:	8752                	mv	a4,s4
ffffffffc0200b10:	864e                	mv	a2,s3
ffffffffc0200b12:	85ca                	mv	a1,s2
ffffffffc0200b14:	00001517          	auipc	a0,0x1
ffffffffc0200b18:	1a450513          	addi	a0,a0,420 # ffffffffc0201cb8 <etext+0x3e0>
ffffffffc0200b1c:	e30ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200b20:	140a8563          	beqz	s5,ffffffffc0200c6a <slub_check+0x2fe>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200b24:	77fd                	lui	a5,0xfffff
ffffffffc0200b26:	00faf7b3          	and	a5,s5,a5
    __cache_free(sl->cache, ptr);
ffffffffc0200b2a:	6388                	ld	a0,0(a5)
ffffffffc0200b2c:	85d6                	mv	a1,s5
ffffffffc0200b2e:	d97ff0ef          	jal	ra,ffffffffc02008c4 <__cache_free>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200b32:	4681                	li	a3,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200b34:	3ff00713          	li	a4,1023
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200b38:	4621                	li	a2,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200b3a:	641c                	ld	a5,8(s0)
ffffffffc0200b3c:	0ef76963          	bltu	a4,a5,ffffffffc0200c2e <slub_check+0x2c2>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200b40:	2685                	addiw	a3,a3,1
ffffffffc0200b42:	03840413          	addi	s0,s0,56
ffffffffc0200b46:	fec69ae3          	bne	a3,a2,ffffffffc0200b3a <slub_check+0x1ce>
ffffffffc0200b4a:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200b4e:	9526                	add	a0,a0,s1
ffffffffc0200b50:	c73ff0ef          	jal	ra,ffffffffc02007c2 <__cache_alloc>
ffffffffc0200b54:	84aa                	mv	s1,a0

    kfree_bytes(p3);

    p3 = kmalloc_bytes(1024);   // 映射到1024B等级

    cprintf("p1=%p, p2=%p, p3=%p,p4=%p, p5=%p, p6=%p\n", p1, p2, p3, p4, p5, p6);
ffffffffc0200b56:	86aa                	mv	a3,a0
ffffffffc0200b58:	885e                	mv	a6,s7
ffffffffc0200b5a:	87da                	mv	a5,s6
ffffffffc0200b5c:	8752                	mv	a4,s4
ffffffffc0200b5e:	864e                	mv	a2,s3
ffffffffc0200b60:	85ca                	mv	a1,s2
ffffffffc0200b62:	00001517          	auipc	a0,0x1
ffffffffc0200b66:	15650513          	addi	a0,a0,342 # ffffffffc0201cb8 <etext+0x3e0>
ffffffffc0200b6a:	de2ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200b6e:	10048e63          	beqz	s1,ffffffffc0200c8a <slub_check+0x31e>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200b72:	747d                	lui	s0,0xfffff
ffffffffc0200b74:	008977b3          	and	a5,s2,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200b78:	6388                	ld	a0,0(a5)
ffffffffc0200b7a:	85ca                	mv	a1,s2
ffffffffc0200b7c:	d49ff0ef          	jal	ra,ffffffffc02008c4 <__cache_free>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200b80:	0089f7b3          	and	a5,s3,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200b84:	6388                	ld	a0,0(a5)
ffffffffc0200b86:	85ce                	mv	a1,s3
ffffffffc0200b88:	d3dff0ef          	jal	ra,ffffffffc02008c4 <__cache_free>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200b8c:	0084f7b3          	and	a5,s1,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200b90:	6388                	ld	a0,0(a5)
ffffffffc0200b92:	85a6                	mv	a1,s1
ffffffffc0200b94:	d31ff0ef          	jal	ra,ffffffffc02008c4 <__cache_free>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200b98:	008a77b3          	and	a5,s4,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200b9c:	6388                	ld	a0,0(a5)
ffffffffc0200b9e:	85d2                	mv	a1,s4
ffffffffc0200ba0:	d25ff0ef          	jal	ra,ffffffffc02008c4 <__cache_free>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200ba4:	008b77b3          	and	a5,s6,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200ba8:	6388                	ld	a0,0(a5)
ffffffffc0200baa:	85da                	mv	a1,s6
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200bac:	008bf433          	and	s0,s7,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200bb0:	d15ff0ef          	jal	ra,ffffffffc02008c4 <__cache_free>
ffffffffc0200bb4:	6008                	ld	a0,0(s0)
ffffffffc0200bb6:	85de                	mv	a1,s7
ffffffffc0200bb8:	d0dff0ef          	jal	ra,ffffffffc02008c4 <__cache_free>
    kfree_bytes(p4);
    kfree_bytes(p5);
    kfree_bytes(p6);

    cprintf("SLUB-only test done.\n");
}
ffffffffc0200bbc:	6406                	ld	s0,64(sp)
ffffffffc0200bbe:	60a6                	ld	ra,72(sp)
ffffffffc0200bc0:	74e2                	ld	s1,56(sp)
ffffffffc0200bc2:	7942                	ld	s2,48(sp)
ffffffffc0200bc4:	79a2                	ld	s3,40(sp)
ffffffffc0200bc6:	7a02                	ld	s4,32(sp)
ffffffffc0200bc8:	6ae2                	ld	s5,24(sp)
ffffffffc0200bca:	6b42                	ld	s6,16(sp)
ffffffffc0200bcc:	6ba2                	ld	s7,8(sp)
    cprintf("SLUB-only test done.\n");
ffffffffc0200bce:	00001517          	auipc	a0,0x1
ffffffffc0200bd2:	18a50513          	addi	a0,a0,394 # ffffffffc0201d58 <etext+0x480>
}
ffffffffc0200bd6:	6161                	addi	sp,sp,80
    cprintf("SLUB-only test done.\n");
ffffffffc0200bd8:	d74ff06f          	j	ffffffffc020014c <cprintf>
ffffffffc0200bdc:	00379513          	slli	a0,a5,0x3
ffffffffc0200be0:	40f507b3          	sub	a5,a0,a5
ffffffffc0200be4:	00379513          	slli	a0,a5,0x3
ffffffffc0200be8:	b3d1                	j	ffffffffc02009ac <slub_check+0x40>
ffffffffc0200bea:	00381513          	slli	a0,a6,0x3
ffffffffc0200bee:	41050533          	sub	a0,a0,a6
ffffffffc0200bf2:	050e                	slli	a0,a0,0x3
ffffffffc0200bf4:	b54d                	j	ffffffffc0200a96 <slub_check+0x12a>
ffffffffc0200bf6:	00379513          	slli	a0,a5,0x3
ffffffffc0200bfa:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bfe:	00379513          	slli	a0,a5,0x3
ffffffffc0200c02:	b595                	j	ffffffffc0200a66 <slub_check+0xfa>
ffffffffc0200c04:	00379513          	slli	a0,a5,0x3
ffffffffc0200c08:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c0c:	00379513          	slli	a0,a5,0x3
ffffffffc0200c10:	b51d                	j	ffffffffc0200a36 <slub_check+0xca>
ffffffffc0200c12:	00379513          	slli	a0,a5,0x3
ffffffffc0200c16:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c1a:	00379513          	slli	a0,a5,0x3
ffffffffc0200c1e:	b3ed                	j	ffffffffc0200a08 <slub_check+0x9c>
ffffffffc0200c20:	00379513          	slli	a0,a5,0x3
ffffffffc0200c24:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c28:	00379513          	slli	a0,a5,0x3
ffffffffc0200c2c:	b37d                	j	ffffffffc02009da <slub_check+0x6e>
ffffffffc0200c2e:	00369513          	slli	a0,a3,0x3
ffffffffc0200c32:	40d506b3          	sub	a3,a0,a3
ffffffffc0200c36:	00369513          	slli	a0,a3,0x3
ffffffffc0200c3a:	bf11                	j	ffffffffc0200b4e <slub_check+0x1e2>
ffffffffc0200c3c:	00369513          	slli	a0,a3,0x3
ffffffffc0200c40:	40d506b3          	sub	a3,a0,a3
ffffffffc0200c44:	00369513          	slli	a0,a3,0x3
ffffffffc0200c48:	bd65                	j	ffffffffc0200b00 <slub_check+0x194>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200c4a:	00001697          	auipc	a3,0x1
ffffffffc0200c4e:	09e68693          	addi	a3,a3,158 # ffffffffc0201ce8 <etext+0x410>
ffffffffc0200c52:	00001617          	auipc	a2,0x1
ffffffffc0200c56:	0ee60613          	addi	a2,a2,238 # ffffffffc0201d40 <etext+0x468>
ffffffffc0200c5a:	0ba00593          	li	a1,186
ffffffffc0200c5e:	00001517          	auipc	a0,0x1
ffffffffc0200c62:	04a50513          	addi	a0,a0,74 # ffffffffc0201ca8 <etext+0x3d0>
ffffffffc0200c66:	d5cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200c6a:	00001697          	auipc	a3,0x1
ffffffffc0200c6e:	07e68693          	addi	a3,a3,126 # ffffffffc0201ce8 <etext+0x410>
ffffffffc0200c72:	00001617          	auipc	a2,0x1
ffffffffc0200c76:	0ce60613          	addi	a2,a2,206 # ffffffffc0201d40 <etext+0x468>
ffffffffc0200c7a:	0c300593          	li	a1,195
ffffffffc0200c7e:	00001517          	auipc	a0,0x1
ffffffffc0200c82:	02a50513          	addi	a0,a0,42 # ffffffffc0201ca8 <etext+0x3d0>
ffffffffc0200c86:	d3cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200c8a:	00001697          	auipc	a3,0x1
ffffffffc0200c8e:	05e68693          	addi	a3,a3,94 # ffffffffc0201ce8 <etext+0x410>
ffffffffc0200c92:	00001617          	auipc	a2,0x1
ffffffffc0200c96:	0ae60613          	addi	a2,a2,174 # ffffffffc0201d40 <etext+0x468>
ffffffffc0200c9a:	0ca00593          	li	a1,202
ffffffffc0200c9e:	00001517          	auipc	a0,0x1
ffffffffc0200ca2:	00a50513          	addi	a0,a0,10 # ffffffffc0201ca8 <etext+0x3d0>
ffffffffc0200ca6:	d1cff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200caa <buddy_init>:
    return buddy_base + buddy_offset;//返回伙伴的Page结构体指针
}

static void
buddy_init(void) {
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200caa:	00005797          	auipc	a5,0x5
ffffffffc0200cae:	52e78793          	addi	a5,a5,1326 # ffffffffc02061d8 <free_areas>
ffffffffc0200cb2:	00005717          	auipc	a4,0x5
ffffffffc0200cb6:	68e70713          	addi	a4,a4,1678 # ffffffffc0206340 <is_panic>
ffffffffc0200cba:	e79c                	sd	a5,8(a5)
ffffffffc0200cbc:	e39c                	sd	a5,0(a5)
        list_init(&free_list_for_order(i));
        nr_free_for_order(i) = 0;
ffffffffc0200cbe:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200cc2:	07e1                	addi	a5,a5,24
ffffffffc0200cc4:	fee79be3          	bne	a5,a4,ffffffffc0200cba <buddy_init+0x10>
    }//初始化整个数组
    total_free_pages = 0;
ffffffffc0200cc8:	00005797          	auipc	a5,0x5
ffffffffc0200ccc:	6c07b823          	sd	zero,1744(a5) # ffffffffc0206398 <total_free_pages>
    buddy_base = NULL;
ffffffffc0200cd0:	00005797          	auipc	a5,0x5
ffffffffc0200cd4:	6a07bc23          	sd	zero,1720(a5) # ffffffffc0206388 <buddy_base>
    buddy_total_pages = 0;//初始化基地址和总页数
ffffffffc0200cd8:	00005797          	auipc	a5,0x5
ffffffffc0200cdc:	6a07bc23          	sd	zero,1720(a5) # ffffffffc0206390 <buddy_total_pages>
}
ffffffffc0200ce0:	8082                	ret

ffffffffc0200ce2 <buddy_nr_free_pages>:
    }
}
static size_t
buddy_nr_free_pages(void) {
    return total_free_pages;
}
ffffffffc0200ce2:	00005517          	auipc	a0,0x5
ffffffffc0200ce6:	6b653503          	ld	a0,1718(a0) # ffffffffc0206398 <total_free_pages>
ffffffffc0200cea:	8082                	ret

ffffffffc0200cec <buddy_dump_free_pages>:

static void
buddy_dump_free_pages(void) {
ffffffffc0200cec:	711d                	addi	sp,sp,-96
    cprintf("------ Buddy System Free Page Dump ------\n");
ffffffffc0200cee:	00001517          	auipc	a0,0x1
ffffffffc0200cf2:	0c250513          	addi	a0,a0,194 # ffffffffc0201db0 <kmalloc_sizes+0x40>
buddy_dump_free_pages(void) {
ffffffffc0200cf6:	e8a2                	sd	s0,80(sp)
ffffffffc0200cf8:	e0ca                	sd	s2,64(sp)
ffffffffc0200cfa:	fc4e                	sd	s3,56(sp)
ffffffffc0200cfc:	f852                	sd	s4,48(sp)
ffffffffc0200cfe:	f456                	sd	s5,40(sp)
ffffffffc0200d00:	f05a                	sd	s6,32(sp)
ffffffffc0200d02:	ec5e                	sd	s7,24(sp)
ffffffffc0200d04:	e862                	sd	s8,16(sp)
ffffffffc0200d06:	e06a                	sd	s10,0(sp)
ffffffffc0200d08:	ec86                	sd	ra,88(sp)
ffffffffc0200d0a:	e4a6                	sd	s1,72(sp)
ffffffffc0200d0c:	e466                	sd	s9,8(sp)
ffffffffc0200d0e:	00005d17          	auipc	s10,0x5
ffffffffc0200d12:	61ad0d13          	addi	s10,s10,1562 # ffffffffc0206328 <free_areas+0x150>
    cprintf("------ Buddy System Free Page Dump ------\n");
ffffffffc0200d16:	c36ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int order = 14; order >=0; order--) {
ffffffffc0200d1a:	4439                	li	s0,14
        if (!list_empty(&free_list_for_order(order))) {
            cprintf("Order %d (size %lu), %u blocks:\n", order, (1UL << order), nr_free_for_order(order));
ffffffffc0200d1c:	4b85                	li	s7,1
ffffffffc0200d1e:	00001b17          	auipc	s6,0x1
ffffffffc0200d22:	0c2b0b13          	addi	s6,s6,194 # ffffffffc0201de0 <kmalloc_sizes+0x70>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d26:	00001c17          	auipc	s8,0x1
ffffffffc0200d2a:	642c0c13          	addi	s8,s8,1602 # ffffffffc0202368 <nbase>
ffffffffc0200d2e:	00005a17          	auipc	s4,0x5
ffffffffc0200d32:	632a0a13          	addi	s4,s4,1586 # ffffffffc0206360 <pages>
ffffffffc0200d36:	00001997          	auipc	s3,0x1
ffffffffc0200d3a:	63a9b983          	ld	s3,1594(s3) # ffffffffc0202370 <nbase+0x8>
            list_entry_t *le = &free_list_for_order(order);
            while ((le = list_next(le)) != &free_list_for_order(order)) {
                struct Page *p = le2page(le, page_link);
                cprintf("  - Block at physical address 0x%016lx (page index %ld)\n", page2pa(p), p - pages);
ffffffffc0200d3e:	00001917          	auipc	s2,0x1
ffffffffc0200d42:	0ca90913          	addi	s2,s2,202 # ffffffffc0201e08 <kmalloc_sizes+0x98>
    for (int order = 14; order >=0; order--) {
ffffffffc0200d46:	5afd                	li	s5,-1
ffffffffc0200d48:	a029                	j	ffffffffc0200d52 <buddy_dump_free_pages+0x66>
ffffffffc0200d4a:	347d                	addiw	s0,s0,-1
ffffffffc0200d4c:	1d21                	addi	s10,s10,-24
ffffffffc0200d4e:	05540a63          	beq	s0,s5,ffffffffc0200da2 <buddy_dump_free_pages+0xb6>
        if (!list_empty(&free_list_for_order(order))) {
ffffffffc0200d52:	008d3783          	ld	a5,8(s10)
ffffffffc0200d56:	ffa78ae3          	beq	a5,s10,ffffffffc0200d4a <buddy_dump_free_pages+0x5e>
            cprintf("Order %d (size %lu), %u blocks:\n", order, (1UL << order), nr_free_for_order(order));
ffffffffc0200d5a:	010d2683          	lw	a3,16(s10)
ffffffffc0200d5e:	008b9633          	sll	a2,s7,s0
ffffffffc0200d62:	85a2                	mv	a1,s0
ffffffffc0200d64:	855a                	mv	a0,s6
ffffffffc0200d66:	be6ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    return listelm->next;
ffffffffc0200d6a:	008d3c83          	ld	s9,8(s10)
            while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200d6e:	fdac8ee3          	beq	s9,s10,ffffffffc0200d4a <buddy_dump_free_pages+0x5e>
ffffffffc0200d72:	000c3483          	ld	s1,0(s8)
ffffffffc0200d76:	000a3783          	ld	a5,0(s4)
                struct Page *p = le2page(le, page_link);
ffffffffc0200d7a:	fe8c8613          	addi	a2,s9,-24
                cprintf("  - Block at physical address 0x%016lx (page index %ld)\n", page2pa(p), p - pages);
ffffffffc0200d7e:	854a                	mv	a0,s2
ffffffffc0200d80:	8e1d                	sub	a2,a2,a5
ffffffffc0200d82:	860d                	srai	a2,a2,0x3
ffffffffc0200d84:	03360633          	mul	a2,a2,s3
ffffffffc0200d88:	009605b3          	add	a1,a2,s1
ffffffffc0200d8c:	05b2                	slli	a1,a1,0xc
ffffffffc0200d8e:	bbeff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200d92:	008cbc83          	ld	s9,8(s9)
            while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200d96:	ffac90e3          	bne	s9,s10,ffffffffc0200d76 <buddy_dump_free_pages+0x8a>
    for (int order = 14; order >=0; order--) {
ffffffffc0200d9a:	347d                	addiw	s0,s0,-1
ffffffffc0200d9c:	1d21                	addi	s10,s10,-24
ffffffffc0200d9e:	fb541ae3          	bne	s0,s5,ffffffffc0200d52 <buddy_dump_free_pages+0x66>
            }
        }
    }
    cprintf("Total free pages: %lu\n", total_free_pages);
ffffffffc0200da2:	00005597          	auipc	a1,0x5
ffffffffc0200da6:	5f65b583          	ld	a1,1526(a1) # ffffffffc0206398 <total_free_pages>
ffffffffc0200daa:	00001517          	auipc	a0,0x1
ffffffffc0200dae:	09e50513          	addi	a0,a0,158 # ffffffffc0201e48 <kmalloc_sizes+0xd8>
ffffffffc0200db2:	b9aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("-----------------------------------------\n");
}//展示空闲页信息
ffffffffc0200db6:	6446                	ld	s0,80(sp)
ffffffffc0200db8:	60e6                	ld	ra,88(sp)
ffffffffc0200dba:	64a6                	ld	s1,72(sp)
ffffffffc0200dbc:	6906                	ld	s2,64(sp)
ffffffffc0200dbe:	79e2                	ld	s3,56(sp)
ffffffffc0200dc0:	7a42                	ld	s4,48(sp)
ffffffffc0200dc2:	7aa2                	ld	s5,40(sp)
ffffffffc0200dc4:	7b02                	ld	s6,32(sp)
ffffffffc0200dc6:	6be2                	ld	s7,24(sp)
ffffffffc0200dc8:	6c42                	ld	s8,16(sp)
ffffffffc0200dca:	6ca2                	ld	s9,8(sp)
ffffffffc0200dcc:	6d02                	ld	s10,0(sp)
    cprintf("-----------------------------------------\n");
ffffffffc0200dce:	00001517          	auipc	a0,0x1
ffffffffc0200dd2:	09250513          	addi	a0,a0,146 # ffffffffc0201e60 <kmalloc_sizes+0xf0>
}//展示空闲页信息
ffffffffc0200dd6:	6125                	addi	sp,sp,96
    cprintf("-----------------------------------------\n");
ffffffffc0200dd8:	b74ff06f          	j	ffffffffc020014c <cprintf>

ffffffffc0200ddc <buddy_check>:

static void
buddy_check(void) {
ffffffffc0200ddc:	7179                	addi	sp,sp,-48
    struct Page *p0, *p1, *p2, *p3, *p4;
    p0 = p1 = p2 = p3 = p4= NULL;
    cprintf("Original State:\n");
ffffffffc0200dde:	00001517          	auipc	a0,0x1
ffffffffc0200de2:	0b250513          	addi	a0,a0,178 # ffffffffc0201e90 <kmalloc_sizes+0x120>
buddy_check(void) {
ffffffffc0200de6:	f406                	sd	ra,40(sp)
ffffffffc0200de8:	ec26                	sd	s1,24(sp)
ffffffffc0200dea:	f022                	sd	s0,32(sp)
ffffffffc0200dec:	e84a                	sd	s2,16(sp)
ffffffffc0200dee:	e44e                	sd	s3,8(sp)
    cprintf("Original State:\n");
ffffffffc0200df0:	b5cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200df4:	ef9ff0ef          	jal	ra,ffffffffc0200cec <buddy_dump_free_pages>

    assert((p0 = alloc_pages(16383)) != NULL);
ffffffffc0200df8:	6491                	lui	s1,0x4
ffffffffc0200dfa:	fff48513          	addi	a0,s1,-1 # 3fff <kern_entry-0xffffffffc01fc001>
ffffffffc0200dfe:	fd2ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200e02:	12050063          	beqz	a0,ffffffffc0200f22 <buddy_check+0x146>
    cprintf("Allocated p0: 16383\n", p0);
ffffffffc0200e06:	85aa                	mv	a1,a0
ffffffffc0200e08:	842a                	mv	s0,a0
ffffffffc0200e0a:	00001517          	auipc	a0,0x1
ffffffffc0200e0e:	0de50513          	addi	a0,a0,222 # ffffffffc0201ee8 <kmalloc_sizes+0x178>
ffffffffc0200e12:	b3aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200e16:	ed7ff0ef          	jal	ra,ffffffffc0200cec <buddy_dump_free_pages>
    free_pages(p0, 16383);
ffffffffc0200e1a:	fff48593          	addi	a1,s1,-1
ffffffffc0200e1e:	8522                	mv	a0,s0
ffffffffc0200e20:	fbcff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    
    assert((p1 = alloc_pages(8191)) != NULL);
ffffffffc0200e24:	6409                	lui	s0,0x2
ffffffffc0200e26:	fff40513          	addi	a0,s0,-1 # 1fff <kern_entry-0xffffffffc01fe001>
ffffffffc0200e2a:	fa6ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200e2e:	84aa                	mv	s1,a0
ffffffffc0200e30:	18050963          	beqz	a0,ffffffffc0200fc2 <buddy_check+0x1e6>
    cprintf("Allocated p1: 8191\n", p1);
ffffffffc0200e34:	85aa                	mv	a1,a0
ffffffffc0200e36:	00001517          	auipc	a0,0x1
ffffffffc0200e3a:	0f250513          	addi	a0,a0,242 # ffffffffc0201f28 <kmalloc_sizes+0x1b8>
ffffffffc0200e3e:	b0eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200e42:	eabff0ef          	jal	ra,ffffffffc0200cec <buddy_dump_free_pages>
    assert((p2 = alloc_pages(8191)) != NULL);
ffffffffc0200e46:	fff40513          	addi	a0,s0,-1
ffffffffc0200e4a:	f86ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200e4e:	892a                	mv	s2,a0
ffffffffc0200e50:	14050963          	beqz	a0,ffffffffc0200fa2 <buddy_check+0x1c6>
    cprintf("Allocated p2: 8191\n", p2);
ffffffffc0200e54:	85aa                	mv	a1,a0
ffffffffc0200e56:	00001517          	auipc	a0,0x1
ffffffffc0200e5a:	11250513          	addi	a0,a0,274 # ffffffffc0201f68 <kmalloc_sizes+0x1f8>
ffffffffc0200e5e:	aeeff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200e62:	e8bff0ef          	jal	ra,ffffffffc0200cec <buddy_dump_free_pages>
    assert((p3 = alloc_pages(8191)) != NULL);
ffffffffc0200e66:	fff40513          	addi	a0,s0,-1
ffffffffc0200e6a:	f66ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200e6e:	89aa                	mv	s3,a0
ffffffffc0200e70:	10050963          	beqz	a0,ffffffffc0200f82 <buddy_check+0x1a6>
    cprintf("Allocated p3: 8191\n", p3);
ffffffffc0200e74:	85aa                	mv	a1,a0
ffffffffc0200e76:	00001517          	auipc	a0,0x1
ffffffffc0200e7a:	13250513          	addi	a0,a0,306 # ffffffffc0201fa8 <kmalloc_sizes+0x238>
ffffffffc0200e7e:	aceff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200e82:	e6bff0ef          	jal	ra,ffffffffc0200cec <buddy_dump_free_pages>
    assert((p4 = alloc_pages(8191)) == NULL);
ffffffffc0200e86:	fff40513          	addi	a0,s0,-1
ffffffffc0200e8a:	f46ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200e8e:	0c051a63          	bnez	a0,ffffffffc0200f62 <buddy_check+0x186>
    cprintf("Attempted to allocate p4: 8191, expected NULL, got %p\n", p4);
ffffffffc0200e92:	4581                	li	a1,0
ffffffffc0200e94:	00001517          	auipc	a0,0x1
ffffffffc0200e98:	15450513          	addi	a0,a0,340 # ffffffffc0201fe8 <kmalloc_sizes+0x278>
ffffffffc0200e9c:	ab0ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200ea0:	e4dff0ef          	jal	ra,ffffffffc0200cec <buddy_dump_free_pages>


    free_pages(p1, 8191);
ffffffffc0200ea4:	fff40593          	addi	a1,s0,-1
ffffffffc0200ea8:	8526                	mv	a0,s1
ffffffffc0200eaa:	f32ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(p2, 8191);
ffffffffc0200eae:	fff40593          	addi	a1,s0,-1
ffffffffc0200eb2:	854a                	mv	a0,s2
ffffffffc0200eb4:	f28ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(p3, 8191);
ffffffffc0200eb8:	fff40593          	addi	a1,s0,-1
ffffffffc0200ebc:	854e                	mv	a0,s3
ffffffffc0200ebe:	f1eff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    
    cprintf("Freed p1, p2, p3:\n");
ffffffffc0200ec2:	00001517          	auipc	a0,0x1
ffffffffc0200ec6:	15e50513          	addi	a0,a0,350 # ffffffffc0202020 <kmalloc_sizes+0x2b0>
ffffffffc0200eca:	a82ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200ece:	e1fff0ef          	jal	ra,ffffffffc0200cec <buddy_dump_free_pages>
    assert((p4 = alloc_pages(129)) != NULL);
ffffffffc0200ed2:	08100513          	li	a0,129
ffffffffc0200ed6:	efaff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200eda:	842a                	mv	s0,a0
ffffffffc0200edc:	c13d                	beqz	a0,ffffffffc0200f42 <buddy_check+0x166>
    cprintf("Allocated p4: 129\n", p4);
ffffffffc0200ede:	85aa                	mv	a1,a0
ffffffffc0200ee0:	00001517          	auipc	a0,0x1
ffffffffc0200ee4:	17850513          	addi	a0,a0,376 # ffffffffc0202058 <kmalloc_sizes+0x2e8>
ffffffffc0200ee8:	a64ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200eec:	e01ff0ef          	jal	ra,ffffffffc0200cec <buddy_dump_free_pages>


    free_pages(p4, 129);
ffffffffc0200ef0:	08100593          	li	a1,129
ffffffffc0200ef4:	8522                	mv	a0,s0
ffffffffc0200ef6:	ee6ff0ef          	jal	ra,ffffffffc02005dc <free_pages>

    cprintf("Freed p4:\n");
ffffffffc0200efa:	00001517          	auipc	a0,0x1
ffffffffc0200efe:	17650513          	addi	a0,a0,374 # ffffffffc0202070 <kmalloc_sizes+0x300>
ffffffffc0200f02:	a4aff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200f06:	de7ff0ef          	jal	ra,ffffffffc0200cec <buddy_dump_free_pages>
    cprintf("buddy_check() succeeded!\n");



}
ffffffffc0200f0a:	7402                	ld	s0,32(sp)
ffffffffc0200f0c:	70a2                	ld	ra,40(sp)
ffffffffc0200f0e:	64e2                	ld	s1,24(sp)
ffffffffc0200f10:	6942                	ld	s2,16(sp)
ffffffffc0200f12:	69a2                	ld	s3,8(sp)
    cprintf("buddy_check() succeeded!\n");
ffffffffc0200f14:	00001517          	auipc	a0,0x1
ffffffffc0200f18:	16c50513          	addi	a0,a0,364 # ffffffffc0202080 <kmalloc_sizes+0x310>
}
ffffffffc0200f1c:	6145                	addi	sp,sp,48
    cprintf("buddy_check() succeeded!\n");
ffffffffc0200f1e:	a2eff06f          	j	ffffffffc020014c <cprintf>
    assert((p0 = alloc_pages(16383)) != NULL);
ffffffffc0200f22:	00001697          	auipc	a3,0x1
ffffffffc0200f26:	f8668693          	addi	a3,a3,-122 # ffffffffc0201ea8 <kmalloc_sizes+0x138>
ffffffffc0200f2a:	00001617          	auipc	a2,0x1
ffffffffc0200f2e:	e1660613          	addi	a2,a2,-490 # ffffffffc0201d40 <etext+0x468>
ffffffffc0200f32:	0e300593          	li	a1,227
ffffffffc0200f36:	00001517          	auipc	a0,0x1
ffffffffc0200f3a:	f9a50513          	addi	a0,a0,-102 # ffffffffc0201ed0 <kmalloc_sizes+0x160>
ffffffffc0200f3e:	a84ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p4 = alloc_pages(129)) != NULL);
ffffffffc0200f42:	00001697          	auipc	a3,0x1
ffffffffc0200f46:	0f668693          	addi	a3,a3,246 # ffffffffc0202038 <kmalloc_sizes+0x2c8>
ffffffffc0200f4a:	00001617          	auipc	a2,0x1
ffffffffc0200f4e:	df660613          	addi	a2,a2,-522 # ffffffffc0201d40 <etext+0x468>
ffffffffc0200f52:	0fc00593          	li	a1,252
ffffffffc0200f56:	00001517          	auipc	a0,0x1
ffffffffc0200f5a:	f7a50513          	addi	a0,a0,-134 # ffffffffc0201ed0 <kmalloc_sizes+0x160>
ffffffffc0200f5e:	a64ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p4 = alloc_pages(8191)) == NULL);
ffffffffc0200f62:	00001697          	auipc	a3,0x1
ffffffffc0200f66:	05e68693          	addi	a3,a3,94 # ffffffffc0201fc0 <kmalloc_sizes+0x250>
ffffffffc0200f6a:	00001617          	auipc	a2,0x1
ffffffffc0200f6e:	dd660613          	addi	a2,a2,-554 # ffffffffc0201d40 <etext+0x468>
ffffffffc0200f72:	0f100593          	li	a1,241
ffffffffc0200f76:	00001517          	auipc	a0,0x1
ffffffffc0200f7a:	f5a50513          	addi	a0,a0,-166 # ffffffffc0201ed0 <kmalloc_sizes+0x160>
ffffffffc0200f7e:	a44ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p3 = alloc_pages(8191)) != NULL);
ffffffffc0200f82:	00001697          	auipc	a3,0x1
ffffffffc0200f86:	ffe68693          	addi	a3,a3,-2 # ffffffffc0201f80 <kmalloc_sizes+0x210>
ffffffffc0200f8a:	00001617          	auipc	a2,0x1
ffffffffc0200f8e:	db660613          	addi	a2,a2,-586 # ffffffffc0201d40 <etext+0x468>
ffffffffc0200f92:	0ee00593          	li	a1,238
ffffffffc0200f96:	00001517          	auipc	a0,0x1
ffffffffc0200f9a:	f3a50513          	addi	a0,a0,-198 # ffffffffc0201ed0 <kmalloc_sizes+0x160>
ffffffffc0200f9e:	a24ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_pages(8191)) != NULL);
ffffffffc0200fa2:	00001697          	auipc	a3,0x1
ffffffffc0200fa6:	f9e68693          	addi	a3,a3,-98 # ffffffffc0201f40 <kmalloc_sizes+0x1d0>
ffffffffc0200faa:	00001617          	auipc	a2,0x1
ffffffffc0200fae:	d9660613          	addi	a2,a2,-618 # ffffffffc0201d40 <etext+0x468>
ffffffffc0200fb2:	0eb00593          	li	a1,235
ffffffffc0200fb6:	00001517          	auipc	a0,0x1
ffffffffc0200fba:	f1a50513          	addi	a0,a0,-230 # ffffffffc0201ed0 <kmalloc_sizes+0x160>
ffffffffc0200fbe:	a04ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_pages(8191)) != NULL);
ffffffffc0200fc2:	00001697          	auipc	a3,0x1
ffffffffc0200fc6:	f3e68693          	addi	a3,a3,-194 # ffffffffc0201f00 <kmalloc_sizes+0x190>
ffffffffc0200fca:	00001617          	auipc	a2,0x1
ffffffffc0200fce:	d7660613          	addi	a2,a2,-650 # ffffffffc0201d40 <etext+0x468>
ffffffffc0200fd2:	0e800593          	li	a1,232
ffffffffc0200fd6:	00001517          	auipc	a0,0x1
ffffffffc0200fda:	efa50513          	addi	a0,a0,-262 # ffffffffc0201ed0 <kmalloc_sizes+0x160>
ffffffffc0200fde:	9e4ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200fe2 <buddy_free_pages>:
    assert(n > 0);
ffffffffc0200fe2:	16058b63          	beqz	a1,ffffffffc0201158 <buddy_free_pages+0x176>
    while ((1UL << order) < n) {
ffffffffc0200fe6:	4785                	li	a5,1
    size_t order = 0;
ffffffffc0200fe8:	4601                	li	a2,0
    while ((1UL << order) < n) {
ffffffffc0200fea:	4685                	li	a3,1
ffffffffc0200fec:	14f58e63          	beq	a1,a5,ffffffffc0201148 <buddy_free_pages+0x166>
        order++;
ffffffffc0200ff0:	0605                	addi	a2,a2,1
    while ((1UL << order) < n) {
ffffffffc0200ff2:	00c697b3          	sll	a5,a3,a2
ffffffffc0200ff6:	0006071b          	sext.w	a4,a2
ffffffffc0200ffa:	feb7ebe3          	bltu	a5,a1,ffffffffc0200ff0 <buddy_free_pages+0xe>
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0200ffe:	00161813          	slli	a6,a2,0x1
ffffffffc0201002:	00c805b3          	add	a1,a6,a2
ffffffffc0201006:	00005697          	auipc	a3,0x5
ffffffffc020100a:	1d268693          	addi	a3,a3,466 # ffffffffc02061d8 <free_areas>
ffffffffc020100e:	058e                	slli	a1,a1,0x3
ffffffffc0201010:	95b6                	add	a1,a1,a3
    total_free_pages += (1UL << order);//更新总空闲页数
ffffffffc0201012:	00005e17          	auipc	t3,0x5
ffffffffc0201016:	386e0e13          	addi	t3,t3,902 # ffffffffc0206398 <total_free_pages>
ffffffffc020101a:	000e3303          	ld	t1,0(t3)
    SetPageProperty(page);
ffffffffc020101e:	00853883          	ld	a7,8(a0)
    page->property = order;
ffffffffc0201022:	c918                	sw	a4,16(a0)
    total_free_pages += (1UL << order);//更新总空闲页数
ffffffffc0201024:	00f30733          	add	a4,t1,a5
    SetPageProperty(page);
ffffffffc0201028:	0028e793          	ori	a5,a7,2
ffffffffc020102c:	e51c                	sd	a5,8(a0)
    total_free_pages += (1UL << order);//更新总空闲页数
ffffffffc020102e:	00ee3023          	sd	a4,0(t3)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0201032:	87ae                	mv	a5,a1
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0201034:	a029                	j	ffffffffc020103e <buddy_free_pages+0x5c>
        struct Page *p = le2page(le, page_link);
ffffffffc0201036:	fe878713          	addi	a4,a5,-24
        if (page < p) {
ffffffffc020103a:	00e56563          	bltu	a0,a4,ffffffffc0201044 <buddy_free_pages+0x62>
ffffffffc020103e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0201040:	feb79be3          	bne	a5,a1,ffffffffc0201036 <buddy_free_pages+0x54>
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc0201044:	00c80733          	add	a4,a6,a2
ffffffffc0201048:	070e                	slli	a4,a4,0x3
    __list_add(elm, listelm->prev, listelm);
ffffffffc020104a:	0007b883          	ld	a7,0(a5)
ffffffffc020104e:	9736                	add	a4,a4,a3
ffffffffc0201050:	4b0c                	lw	a1,16(a4)
    list_add_before(le, &(page->page_link));//插入该位置
ffffffffc0201052:	01850813          	addi	a6,a0,24
    prev->next = next->prev = elm;
ffffffffc0201056:	0107b023          	sd	a6,0(a5)
ffffffffc020105a:	0108b423          	sd	a6,8(a7)
    elm->next = next;
ffffffffc020105e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201060:	01153c23          	sd	a7,24(a0)
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc0201064:	0015879b          	addiw	a5,a1,1
ffffffffc0201068:	cb1c                	sw	a5,16(a4)
    while (order < MAX_ORDER - 1) {
ffffffffc020106a:	47b5                	li	a5,13
ffffffffc020106c:	0cc7ed63          	bltu	a5,a2,ffffffffc0201146 <buddy_free_pages+0x164>
ffffffffc0201070:	00160713          	addi	a4,a2,1
ffffffffc0201074:	00171793          	slli	a5,a4,0x1
ffffffffc0201078:	97ba                	add	a5,a5,a4
ffffffffc020107a:	078e                	slli	a5,a5,0x3
    if (buddy_base == NULL) {
ffffffffc020107c:	00005597          	auipc	a1,0x5
ffffffffc0201080:	30c5b583          	ld	a1,780(a1) # ffffffffc0206388 <buddy_base>
    if (buddy_offset >= buddy_total_pages) {
ffffffffc0201084:	00005e97          	auipc	t4,0x5
ffffffffc0201088:	30cebe83          	ld	t4,780(t4) # ffffffffc0206390 <buddy_total_pages>
ffffffffc020108c:	96be                	add	a3,a3,a5
    size_t offset = page - buddy_base;//相对base的偏移
ffffffffc020108e:	00001e17          	auipc	t3,0x1
ffffffffc0201092:	2e2e3e03          	ld	t3,738(t3) # ffffffffc0202370 <nbase+0x8>
    size_t buddy_offset = offset ^ (1UL << order);//取异或找到伙伴
ffffffffc0201096:	4305                	li	t1,1
    while (order < MAX_ORDER - 1) {
ffffffffc0201098:	48b9                	li	a7,14
    if (buddy_base == NULL) {
ffffffffc020109a:	c5d5                	beqz	a1,ffffffffc0201146 <buddy_free_pages+0x164>
    size_t offset = page - buddy_base;//相对base的偏移
ffffffffc020109c:	40b507b3          	sub	a5,a0,a1
ffffffffc02010a0:	878d                	srai	a5,a5,0x3
ffffffffc02010a2:	03c787b3          	mul	a5,a5,t3
    size_t buddy_offset = offset ^ (1UL << order);//取异或找到伙伴
ffffffffc02010a6:	00c31733          	sll	a4,t1,a2
ffffffffc02010aa:	8f3d                	xor	a4,a4,a5
    if (buddy_offset >= buddy_total_pages) {
ffffffffc02010ac:	09d77d63          	bgeu	a4,t4,ffffffffc0201146 <buddy_free_pages+0x164>
    return buddy_base + buddy_offset;//返回伙伴的Page结构体指针
ffffffffc02010b0:	00271793          	slli	a5,a4,0x2
ffffffffc02010b4:	97ba                	add	a5,a5,a4
ffffffffc02010b6:	078e                	slli	a5,a5,0x3
ffffffffc02010b8:	97ae                	add	a5,a5,a1
        if (buddy == NULL || !PageProperty(buddy) || buddy->property != order) {
ffffffffc02010ba:	6798                	ld	a4,8(a5)
ffffffffc02010bc:	8b09                	andi	a4,a4,2
ffffffffc02010be:	c741                	beqz	a4,ffffffffc0201146 <buddy_free_pages+0x164>
ffffffffc02010c0:	0107e703          	lwu	a4,16(a5)
ffffffffc02010c4:	08c71163          	bne	a4,a2,ffffffffc0201146 <buddy_free_pages+0x164>
    __list_del(listelm->prev, listelm->next);
ffffffffc02010c8:	01853283          	ld	t0,24(a0)
ffffffffc02010cc:	02053f83          	ld	t6,32(a0)
        nr_free_for_order(order)--;
ffffffffc02010d0:	ff86af03          	lw	t5,-8(a3)
        ClearPageProperty(page);
ffffffffc02010d4:	6518                	ld	a4,8(a0)
    prev->next = next;
ffffffffc02010d6:	01f2b423          	sd	t6,8(t0)
    next->prev = prev;
ffffffffc02010da:	005fb023          	sd	t0,0(t6)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010de:	0187b283          	ld	t0,24(a5)
ffffffffc02010e2:	0207bf83          	ld	t6,32(a5)
        nr_free_for_order(order)--;
ffffffffc02010e6:	3f79                	addiw	t5,t5,-2
        ClearPageProperty(page);
ffffffffc02010e8:	9b75                	andi	a4,a4,-3
    prev->next = next;
ffffffffc02010ea:	01f2b423          	sd	t6,8(t0)
    next->prev = prev;
ffffffffc02010ee:	005fb023          	sd	t0,0(t6)
        nr_free_for_order(order)--;
ffffffffc02010f2:	ffe6ac23          	sw	t5,-8(a3)
        ClearPageProperty(page);
ffffffffc02010f6:	e518                	sd	a4,8(a0)
        ClearPageProperty(buddy);
ffffffffc02010f8:	6798                	ld	a4,8(a5)
ffffffffc02010fa:	9b75                	andi	a4,a4,-3
ffffffffc02010fc:	e798                	sd	a4,8(a5)
        if (buddy < page) {
ffffffffc02010fe:	00a7f563          	bgeu	a5,a0,ffffffffc0201108 <buddy_free_pages+0x126>
ffffffffc0201102:	853e                	mv	a0,a5
ffffffffc0201104:	01878813          	addi	a6,a5,24
        SetPageProperty(page);
ffffffffc0201108:	651c                	ld	a5,8(a0)
        order++;//提升到更高的 order
ffffffffc020110a:	0605                	addi	a2,a2,1
        page->property = order;
ffffffffc020110c:	c910                	sw	a2,16(a0)
        SetPageProperty(page);
ffffffffc020110e:	0027e793          	ori	a5,a5,2
ffffffffc0201112:	e51c                	sd	a5,8(a0)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0201114:	87b6                	mv	a5,a3
ffffffffc0201116:	a029                	j	ffffffffc0201120 <buddy_free_pages+0x13e>
        struct Page *p = le2page(le, page_link);
ffffffffc0201118:	fe878713          	addi	a4,a5,-24
        if (page < p) {
ffffffffc020111c:	00e56563          	bltu	a0,a4,ffffffffc0201126 <buddy_free_pages+0x144>
    return listelm->next;
ffffffffc0201120:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0201122:	fed79be3          	bne	a5,a3,ffffffffc0201118 <buddy_free_pages+0x136>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201126:	0007bf03          	ld	t5,0(a5)
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc020112a:	4a98                	lw	a4,16(a3)
    prev->next = next->prev = elm;
ffffffffc020112c:	0107b023          	sd	a6,0(a5)
ffffffffc0201130:	010f3423          	sd	a6,8(t5)
    elm->next = next;
ffffffffc0201134:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201136:	01e53c23          	sd	t5,24(a0)
ffffffffc020113a:	0017079b          	addiw	a5,a4,1
ffffffffc020113e:	ca9c                	sw	a5,16(a3)
    while (order < MAX_ORDER - 1) {
ffffffffc0201140:	06e1                	addi	a3,a3,24
ffffffffc0201142:	f5161ce3          	bne	a2,a7,ffffffffc020109a <buddy_free_pages+0xb8>
ffffffffc0201146:	8082                	ret
    while ((1UL << order) < n) {
ffffffffc0201148:	00005697          	auipc	a3,0x5
ffffffffc020114c:	09068693          	addi	a3,a3,144 # ffffffffc02061d8 <free_areas>
ffffffffc0201150:	85b6                	mv	a1,a3
ffffffffc0201152:	4701                	li	a4,0
ffffffffc0201154:	4801                	li	a6,0
ffffffffc0201156:	bd75                	j	ffffffffc0201012 <buddy_free_pages+0x30>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0201158:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020115a:	00001697          	auipc	a3,0x1
ffffffffc020115e:	f4668693          	addi	a3,a3,-186 # ffffffffc02020a0 <kmalloc_sizes+0x330>
ffffffffc0201162:	00001617          	auipc	a2,0x1
ffffffffc0201166:	bde60613          	addi	a2,a2,-1058 # ffffffffc0201d40 <etext+0x468>
ffffffffc020116a:	09c00593          	li	a1,156
ffffffffc020116e:	00001517          	auipc	a0,0x1
ffffffffc0201172:	d6250513          	addi	a0,a0,-670 # ffffffffc0201ed0 <kmalloc_sizes+0x160>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0201176:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201178:	84aff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020117c <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc020117c:	10050863          	beqz	a0,ffffffffc020128c <buddy_alloc_pages+0x110>
    if (total_free_pages < (1UL << order)) {
ffffffffc0201180:	00005297          	auipc	t0,0x5
ffffffffc0201184:	21828293          	addi	t0,t0,536 # ffffffffc0206398 <total_free_pages>
    while ((1UL << order) < n) {
ffffffffc0201188:	4705                	li	a4,1
    if (total_free_pages < (1UL << order)) {
ffffffffc020118a:	0002bf83          	ld	t6,0(t0)
    size_t order = 0;
ffffffffc020118e:	4801                	li	a6,0
    while ((1UL << order) < n) {
ffffffffc0201190:	4785                	li	a5,1
ffffffffc0201192:	0ee50963          	beq	a0,a4,ffffffffc0201284 <buddy_alloc_pages+0x108>
        order++;
ffffffffc0201196:	0805                	addi	a6,a6,1
    while ((1UL << order) < n) {
ffffffffc0201198:	010798b3          	sll	a7,a5,a6
ffffffffc020119c:	fea8ede3          	bltu	a7,a0,ffffffffc0201196 <buddy_alloc_pages+0x1a>
    if (total_free_pages < (1UL << order)) {
ffffffffc02011a0:	0d1fe063          	bltu	t6,a7,ffffffffc0201260 <buddy_alloc_pages+0xe4>
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
ffffffffc02011a4:	47b9                	li	a5,14
ffffffffc02011a6:	0b07ef63          	bltu	a5,a6,ffffffffc0201264 <buddy_alloc_pages+0xe8>
ffffffffc02011aa:	00181793          	slli	a5,a6,0x1
ffffffffc02011ae:	97c2                	add	a5,a5,a6
ffffffffc02011b0:	00005617          	auipc	a2,0x5
ffffffffc02011b4:	02860613          	addi	a2,a2,40 # ffffffffc02061d8 <free_areas>
ffffffffc02011b8:	078e                	slli	a5,a5,0x3
ffffffffc02011ba:	97b2                	add	a5,a5,a2
    size_t order = 0;
ffffffffc02011bc:	85c2                	mv	a1,a6
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
ffffffffc02011be:	473d                	li	a4,15
ffffffffc02011c0:	a029                	j	ffffffffc02011ca <buddy_alloc_pages+0x4e>
ffffffffc02011c2:	0585                	addi	a1,a1,1
ffffffffc02011c4:	07e1                	addi	a5,a5,24
ffffffffc02011c6:	08e58d63          	beq	a1,a4,ffffffffc0201260 <buddy_alloc_pages+0xe4>
    return list->next == list;
ffffffffc02011ca:	0087b303          	ld	t1,8(a5)
        if (!list_empty(&free_list_for_order(current_order))) {
ffffffffc02011ce:	fef30ae3          	beq	t1,a5,ffffffffc02011c2 <buddy_alloc_pages+0x46>
    nr_free_for_order(current_order)--;//减少该order的空闲块计数
ffffffffc02011d2:	00159793          	slli	a5,a1,0x1
ffffffffc02011d6:	97ae                	add	a5,a5,a1
ffffffffc02011d8:	078e                	slli	a5,a5,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc02011da:	00833503          	ld	a0,8(t1)
ffffffffc02011de:	00f606b3          	add	a3,a2,a5
ffffffffc02011e2:	00033e03          	ld	t3,0(t1)
ffffffffc02011e6:	4a98                	lw	a4,16(a3)
ffffffffc02011e8:	17a1                	addi	a5,a5,-24
    prev->next = next;
ffffffffc02011ea:	00ae3423          	sd	a0,8(t3)
    next->prev = prev;
ffffffffc02011ee:	01c53023          	sd	t3,0(a0)
ffffffffc02011f2:	377d                	addiw	a4,a4,-1
ffffffffc02011f4:	ca98                	sw	a4,16(a3)
    struct Page* page = le2page(le, page_link);
ffffffffc02011f6:	fe830513          	addi	a0,t1,-24
    while (current_order > order) {
ffffffffc02011fa:	963e                	add	a2,a2,a5
        struct Page* buddy = page + (1UL << current_order);
ffffffffc02011fc:	02800f13          	li	t5,40
    while (current_order > order) {
ffffffffc0201200:	04b87663          	bgeu	a6,a1,ffffffffc020124c <buddy_alloc_pages+0xd0>
        current_order--;
ffffffffc0201204:	15fd                	addi	a1,a1,-1
        struct Page* buddy = page + (1UL << current_order);
ffffffffc0201206:	00bf1733          	sll	a4,t5,a1
ffffffffc020120a:	972a                	add	a4,a4,a0
        SetPageProperty(buddy);
ffffffffc020120c:	6714                	ld	a3,8(a4)
        buddy->property = current_order;
ffffffffc020120e:	cb0c                	sw	a1,16(a4)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0201210:	87b2                	mv	a5,a2
        SetPageProperty(buddy);
ffffffffc0201212:	0026e693          	ori	a3,a3,2
ffffffffc0201216:	e714                	sd	a3,8(a4)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0201218:	a029                	j	ffffffffc0201222 <buddy_alloc_pages+0xa6>
        struct Page *p = le2page(le, page_link);
ffffffffc020121a:	fe878693          	addi	a3,a5,-24
        if (page < p) {
ffffffffc020121e:	00d76563          	bltu	a4,a3,ffffffffc0201228 <buddy_alloc_pages+0xac>
    return listelm->next;
ffffffffc0201222:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0201224:	fec79be3          	bne	a5,a2,ffffffffc020121a <buddy_alloc_pages+0x9e>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201228:	0007be03          	ld	t3,0(a5)
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc020122c:	4a14                	lw	a3,16(a2)
    list_add_before(le, &(page->page_link));//插入该位置
ffffffffc020122e:	01870e93          	addi	t4,a4,24
    prev->next = next->prev = elm;
ffffffffc0201232:	01d7b023          	sd	t4,0(a5)
ffffffffc0201236:	01de3423          	sd	t4,8(t3)
    elm->next = next;
ffffffffc020123a:	f31c                	sd	a5,32(a4)
    elm->prev = prev;
ffffffffc020123c:	01c73c23          	sd	t3,24(a4)
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc0201240:	0016879b          	addiw	a5,a3,1
ffffffffc0201244:	ca1c                	sw	a5,16(a2)
    while (current_order > order) {
ffffffffc0201246:	1621                	addi	a2,a2,-24
ffffffffc0201248:	fb059ee3          	bne	a1,a6,ffffffffc0201204 <buddy_alloc_pages+0x88>
    ClearPageProperty(page);
ffffffffc020124c:	ff033783          	ld	a5,-16(t1)
    total_free_pages -= (1UL << order);//更新总空闲页数
ffffffffc0201250:	411f88b3          	sub	a7,t6,a7
ffffffffc0201254:	0112b023          	sd	a7,0(t0)
    ClearPageProperty(page);
ffffffffc0201258:	9bf5                	andi	a5,a5,-3
ffffffffc020125a:	fef33823          	sd	a5,-16(t1)
    return page;
ffffffffc020125e:	8082                	ret
        return NULL;
ffffffffc0201260:	4501                	li	a0,0
}
ffffffffc0201262:	8082                	ret
    if (current_order == MAX_ORDER) {
ffffffffc0201264:	47bd                	li	a5,15
ffffffffc0201266:	fef80de3          	beq	a6,a5,ffffffffc0201260 <buddy_alloc_pages+0xe4>
    return listelm->next;
ffffffffc020126a:	00181793          	slli	a5,a6,0x1
ffffffffc020126e:	97c2                	add	a5,a5,a6
ffffffffc0201270:	00005617          	auipc	a2,0x5
ffffffffc0201274:	f6860613          	addi	a2,a2,-152 # ffffffffc02061d8 <free_areas>
ffffffffc0201278:	078e                	slli	a5,a5,0x3
ffffffffc020127a:	97b2                	add	a5,a5,a2
ffffffffc020127c:	0087b303          	ld	t1,8(a5)
ffffffffc0201280:	85c2                	mv	a1,a6
ffffffffc0201282:	bf81                	j	ffffffffc02011d2 <buddy_alloc_pages+0x56>
    if (total_free_pages < (1UL << order)) {
ffffffffc0201284:	fc0f8ee3          	beqz	t6,ffffffffc0201260 <buddy_alloc_pages+0xe4>
    while ((1UL << order) < n) {
ffffffffc0201288:	4885                	li	a7,1
ffffffffc020128a:	b705                	j	ffffffffc02011aa <buddy_alloc_pages+0x2e>
buddy_alloc_pages(size_t n) {
ffffffffc020128c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020128e:	00001697          	auipc	a3,0x1
ffffffffc0201292:	e1268693          	addi	a3,a3,-494 # ffffffffc02020a0 <kmalloc_sizes+0x330>
ffffffffc0201296:	00001617          	auipc	a2,0x1
ffffffffc020129a:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0201d40 <etext+0x468>
ffffffffc020129e:	06e00593          	li	a1,110
ffffffffc02012a2:	00001517          	auipc	a0,0x1
ffffffffc02012a6:	c2e50513          	addi	a0,a0,-978 # ffffffffc0201ed0 <kmalloc_sizes+0x160>
buddy_alloc_pages(size_t n) {
ffffffffc02012aa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012ac:	f17fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02012b0 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc02012b0:	1141                	addi	sp,sp,-16
ffffffffc02012b2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012b4:	14058863          	beqz	a1,ffffffffc0201404 <buddy_init_memmap+0x154>
    if (buddy_base == NULL) {
ffffffffc02012b8:	00005617          	auipc	a2,0x5
ffffffffc02012bc:	0d060613          	addi	a2,a2,208 # ffffffffc0206388 <buddy_base>
ffffffffc02012c0:	621c                	ld	a5,0(a2)
ffffffffc02012c2:	10078b63          	beqz	a5,ffffffffc02013d8 <buddy_init_memmap+0x128>
        assert(base >= buddy_base);
ffffffffc02012c6:	14f56f63          	bltu	a0,a5,ffffffffc0201424 <buddy_init_memmap+0x174>
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc02012ca:	00259693          	slli	a3,a1,0x2
ffffffffc02012ce:	96ae                	add	a3,a3,a1
ffffffffc02012d0:	068e                	slli	a3,a3,0x3
ffffffffc02012d2:	96aa                	add	a3,a3,a0
ffffffffc02012d4:	87aa                	mv	a5,a0
ffffffffc02012d6:	02d57063          	bgeu	a0,a3,ffffffffc02012f6 <buddy_init_memmap+0x46>
        assert(PageReserved(p));
ffffffffc02012da:	6798                	ld	a4,8(a5)
ffffffffc02012dc:	8b05                	andi	a4,a4,1
ffffffffc02012de:	10070363          	beqz	a4,ffffffffc02013e4 <buddy_init_memmap+0x134>
        p->flags = 0;
ffffffffc02012e2:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc02012e6:	0007a823          	sw	zero,16(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012ea:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc02012ee:	02878793          	addi	a5,a5,40
ffffffffc02012f2:	fed7e4e3          	bltu	a5,a3,ffffffffc02012da <buddy_init_memmap+0x2a>
    size_t base_offset = base - buddy_base;
ffffffffc02012f6:	00063f83          	ld	t6,0(a2)
ffffffffc02012fa:	00001697          	auipc	a3,0x1
ffffffffc02012fe:	0766b683          	ld	a3,118(a3) # ffffffffc0202370 <nbase+0x8>
    total_free_pages += n;
ffffffffc0201302:	00005717          	auipc	a4,0x5
ffffffffc0201306:	09670713          	addi	a4,a4,150 # ffffffffc0206398 <total_free_pages>
    size_t base_offset = base - buddy_base;
ffffffffc020130a:	41f50fb3          	sub	t6,a0,t6
ffffffffc020130e:	403fdf93          	srai	t6,t6,0x3
ffffffffc0201312:	02df8fb3          	mul	t6,t6,a3
    total_free_pages += n;
ffffffffc0201316:	631c                	ld	a5,0(a4)
    size_t offset = 0;
ffffffffc0201318:	4e01                	li	t3,0
ffffffffc020131a:	00005f17          	auipc	t5,0x5
ffffffffc020131e:	ebef0f13          	addi	t5,t5,-322 # ffffffffc02061d8 <free_areas>
    total_free_pages += n;
ffffffffc0201322:	97ae                	add	a5,a5,a1
ffffffffc0201324:	e31c                	sd	a5,0(a4)
            size_t block_size = 1UL << (order + 1);
ffffffffc0201326:	4305                	li	t1,1
        while (order + 1 < MAX_ORDER) {
ffffffffc0201328:	4eb9                	li	t4,14
        size_t remaining = n - offset;//剩余页数
ffffffffc020132a:	41c586b3          	sub	a3,a1,t3
ffffffffc020132e:	4701                	li	a4,0
            size_t global_offset = base_offset + offset;
ffffffffc0201330:	01cf8833          	add	a6,t6,t3
            size_t block_size = 1UL << (order + 1);
ffffffffc0201334:	0017079b          	addiw	a5,a4,1
ffffffffc0201338:	00f317b3          	sll	a5,t1,a5
            if (block_size > remaining) {//不能再更大了
ffffffffc020133c:	0007061b          	sext.w	a2,a4
ffffffffc0201340:	08f6e463          	bltu	a3,a5,ffffffffc02013c8 <buddy_init_memmap+0x118>
            if (global_offset & (block_size - 1)) {
ffffffffc0201344:	17fd                	addi	a5,a5,-1
ffffffffc0201346:	0107f7b3          	and	a5,a5,a6
ffffffffc020134a:	efbd                	bnez	a5,ffffffffc02013c8 <buddy_init_memmap+0x118>
        while (order + 1 < MAX_ORDER) {
ffffffffc020134c:	0705                	addi	a4,a4,1
ffffffffc020134e:	ffd713e3          	bne	a4,t4,ffffffffc0201334 <buddy_init_memmap+0x84>
ffffffffc0201352:	6291                	lui	t0,0x4
ffffffffc0201354:	4639                	li	a2,14
ffffffffc0201356:	15000813          	li	a6,336
ffffffffc020135a:	00171893          	slli	a7,a4,0x1
        struct Page* page = base + offset;//当前块的起始页
ffffffffc020135e:	002e1693          	slli	a3,t3,0x2
ffffffffc0201362:	96f2                	add	a3,a3,t3
ffffffffc0201364:	068e                	slli	a3,a3,0x3
ffffffffc0201366:	96aa                	add	a3,a3,a0
        SetPageProperty(page);//加入空闲链表
ffffffffc0201368:	669c                	ld	a5,8(a3)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc020136a:	987a                	add	a6,a6,t5
        page->property = order;//设置块的order
ffffffffc020136c:	ca90                	sw	a2,16(a3)
        SetPageProperty(page);//加入空闲链表
ffffffffc020136e:	0027e793          	ori	a5,a5,2
ffffffffc0201372:	e69c                	sd	a5,8(a3)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0201374:	87c2                	mv	a5,a6
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0201376:	a029                	j	ffffffffc0201380 <buddy_init_memmap+0xd0>
        struct Page *p = le2page(le, page_link);
ffffffffc0201378:	fe878613          	addi	a2,a5,-24
        if (page < p) {
ffffffffc020137c:	00c6e563          	bltu	a3,a2,ffffffffc0201386 <buddy_init_memmap+0xd6>
ffffffffc0201380:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0201382:	fef81be3          	bne	a6,a5,ffffffffc0201378 <buddy_init_memmap+0xc8>
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc0201386:	9746                	add	a4,a4,a7
ffffffffc0201388:	070e                	slli	a4,a4,0x3
    __list_add(elm, listelm->prev, listelm);
ffffffffc020138a:	0007b803          	ld	a6,0(a5)
ffffffffc020138e:	977a                	add	a4,a4,t5
ffffffffc0201390:	4b10                	lw	a2,16(a4)
    list_add_before(le, &(page->page_link));//插入该位置
ffffffffc0201392:	01868893          	addi	a7,a3,24
    prev->next = next->prev = elm;
ffffffffc0201396:	0117b023          	sd	a7,0(a5)
ffffffffc020139a:	01183423          	sd	a7,8(a6)
    elm->next = next;
ffffffffc020139e:	f29c                	sd	a5,32(a3)
    elm->prev = prev;
ffffffffc02013a0:	0106bc23          	sd	a6,24(a3)
    nr_free_for_order(order)++;//增加该order的空闲块计数
ffffffffc02013a4:	0016079b          	addiw	a5,a2,1
ffffffffc02013a8:	cb1c                	sw	a5,16(a4)
        offset += (1UL << order);//移动偏移
ffffffffc02013aa:	9e16                	add	t3,t3,t0
    while (offset < n) {
ffffffffc02013ac:	f6be6fe3          	bltu	t3,a1,ffffffffc020132a <buddy_init_memmap+0x7a>
    if (new_total > buddy_total_pages) {
ffffffffc02013b0:	00005797          	auipc	a5,0x5
ffffffffc02013b4:	fe078793          	addi	a5,a5,-32 # ffffffffc0206390 <buddy_total_pages>
ffffffffc02013b8:	6398                	ld	a4,0(a5)
    size_t new_total = base_offset + n;
ffffffffc02013ba:	95fe                	add	a1,a1,t6
    if (new_total > buddy_total_pages) {
ffffffffc02013bc:	00b77363          	bgeu	a4,a1,ffffffffc02013c2 <buddy_init_memmap+0x112>
        buddy_total_pages = new_total;
ffffffffc02013c0:	e38c                	sd	a1,0(a5)
}
ffffffffc02013c2:	60a2                	ld	ra,8(sp)
ffffffffc02013c4:	0141                	addi	sp,sp,16
ffffffffc02013c6:	8082                	ret
ffffffffc02013c8:	00171893          	slli	a7,a4,0x1
ffffffffc02013cc:	00e88833          	add	a6,a7,a4
ffffffffc02013d0:	080e                	slli	a6,a6,0x3
        offset += (1UL << order);//移动偏移
ffffffffc02013d2:	00c312b3          	sll	t0,t1,a2
ffffffffc02013d6:	b761                	j	ffffffffc020135e <buddy_init_memmap+0xae>
        buddy_base = base;
ffffffffc02013d8:	e208                	sd	a0,0(a2)
        buddy_total_pages = 0;
ffffffffc02013da:	00005797          	auipc	a5,0x5
ffffffffc02013de:	fa07bb23          	sd	zero,-74(a5) # ffffffffc0206390 <buddy_total_pages>
ffffffffc02013e2:	b5e5                	j	ffffffffc02012ca <buddy_init_memmap+0x1a>
        assert(PageReserved(p));
ffffffffc02013e4:	00001697          	auipc	a3,0x1
ffffffffc02013e8:	cdc68693          	addi	a3,a3,-804 # ffffffffc02020c0 <kmalloc_sizes+0x350>
ffffffffc02013ec:	00001617          	auipc	a2,0x1
ffffffffc02013f0:	95460613          	addi	a2,a2,-1708 # ffffffffc0201d40 <etext+0x468>
ffffffffc02013f4:	04400593          	li	a1,68
ffffffffc02013f8:	00001517          	auipc	a0,0x1
ffffffffc02013fc:	ad850513          	addi	a0,a0,-1320 # ffffffffc0201ed0 <kmalloc_sizes+0x160>
ffffffffc0201400:	dc3fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0201404:	00001697          	auipc	a3,0x1
ffffffffc0201408:	c9c68693          	addi	a3,a3,-868 # ffffffffc02020a0 <kmalloc_sizes+0x330>
ffffffffc020140c:	00001617          	auipc	a2,0x1
ffffffffc0201410:	93460613          	addi	a2,a2,-1740 # ffffffffc0201d40 <etext+0x468>
ffffffffc0201414:	03b00593          	li	a1,59
ffffffffc0201418:	00001517          	auipc	a0,0x1
ffffffffc020141c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0201ed0 <kmalloc_sizes+0x160>
ffffffffc0201420:	da3fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(base >= buddy_base);
ffffffffc0201424:	00001697          	auipc	a3,0x1
ffffffffc0201428:	c8468693          	addi	a3,a3,-892 # ffffffffc02020a8 <kmalloc_sizes+0x338>
ffffffffc020142c:	00001617          	auipc	a2,0x1
ffffffffc0201430:	91460613          	addi	a2,a2,-1772 # ffffffffc0201d40 <etext+0x468>
ffffffffc0201434:	04000593          	li	a1,64
ffffffffc0201438:	00001517          	auipc	a0,0x1
ffffffffc020143c:	a9850513          	addi	a0,a0,-1384 # ffffffffc0201ed0 <kmalloc_sizes+0x160>
ffffffffc0201440:	d83fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0201444 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201444:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0201448:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020144a:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020144c:	cb81                	beqz	a5,ffffffffc020145c <strlen+0x18>
        cnt ++;
ffffffffc020144e:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0201450:	00a707b3          	add	a5,a4,a0
ffffffffc0201454:	0007c783          	lbu	a5,0(a5)
ffffffffc0201458:	fbfd                	bnez	a5,ffffffffc020144e <strlen+0xa>
ffffffffc020145a:	8082                	ret
    }
    return cnt;
}
ffffffffc020145c:	8082                	ret

ffffffffc020145e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020145e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201460:	e589                	bnez	a1,ffffffffc020146a <strnlen+0xc>
ffffffffc0201462:	a811                	j	ffffffffc0201476 <strnlen+0x18>
        cnt ++;
ffffffffc0201464:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201466:	00f58863          	beq	a1,a5,ffffffffc0201476 <strnlen+0x18>
ffffffffc020146a:	00f50733          	add	a4,a0,a5
ffffffffc020146e:	00074703          	lbu	a4,0(a4)
ffffffffc0201472:	fb6d                	bnez	a4,ffffffffc0201464 <strnlen+0x6>
ffffffffc0201474:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201476:	852e                	mv	a0,a1
ffffffffc0201478:	8082                	ret

ffffffffc020147a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020147a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020147e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201482:	cb89                	beqz	a5,ffffffffc0201494 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201484:	0505                	addi	a0,a0,1
ffffffffc0201486:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201488:	fee789e3          	beq	a5,a4,ffffffffc020147a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020148c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201490:	9d19                	subw	a0,a0,a4
ffffffffc0201492:	8082                	ret
ffffffffc0201494:	4501                	li	a0,0
ffffffffc0201496:	bfed                	j	ffffffffc0201490 <strcmp+0x16>

ffffffffc0201498 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201498:	c20d                	beqz	a2,ffffffffc02014ba <strncmp+0x22>
ffffffffc020149a:	962e                	add	a2,a2,a1
ffffffffc020149c:	a031                	j	ffffffffc02014a8 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc020149e:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02014a0:	00e79a63          	bne	a5,a4,ffffffffc02014b4 <strncmp+0x1c>
ffffffffc02014a4:	00b60b63          	beq	a2,a1,ffffffffc02014ba <strncmp+0x22>
ffffffffc02014a8:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02014ac:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02014ae:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02014b2:	f7f5                	bnez	a5,ffffffffc020149e <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02014b4:	40e7853b          	subw	a0,a5,a4
}
ffffffffc02014b8:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02014ba:	4501                	li	a0,0
ffffffffc02014bc:	8082                	ret

ffffffffc02014be <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02014be:	ca01                	beqz	a2,ffffffffc02014ce <memset+0x10>
ffffffffc02014c0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02014c2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02014c4:	0785                	addi	a5,a5,1
ffffffffc02014c6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02014ca:	fec79de3          	bne	a5,a2,ffffffffc02014c4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02014ce:	8082                	ret

ffffffffc02014d0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02014d0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014d4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02014d6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014da:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02014dc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014e0:	f022                	sd	s0,32(sp)
ffffffffc02014e2:	ec26                	sd	s1,24(sp)
ffffffffc02014e4:	e84a                	sd	s2,16(sp)
ffffffffc02014e6:	f406                	sd	ra,40(sp)
ffffffffc02014e8:	e44e                	sd	s3,8(sp)
ffffffffc02014ea:	84aa                	mv	s1,a0
ffffffffc02014ec:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02014ee:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02014f2:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02014f4:	03067e63          	bgeu	a2,a6,ffffffffc0201530 <printnum+0x60>
ffffffffc02014f8:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02014fa:	00805763          	blez	s0,ffffffffc0201508 <printnum+0x38>
ffffffffc02014fe:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201500:	85ca                	mv	a1,s2
ffffffffc0201502:	854e                	mv	a0,s3
ffffffffc0201504:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201506:	fc65                	bnez	s0,ffffffffc02014fe <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201508:	1a02                	slli	s4,s4,0x20
ffffffffc020150a:	00001797          	auipc	a5,0x1
ffffffffc020150e:	c1678793          	addi	a5,a5,-1002 # ffffffffc0202120 <buddy_pmm_manager+0x38>
ffffffffc0201512:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201516:	9a3e                	add	s4,s4,a5
}
ffffffffc0201518:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020151a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020151e:	70a2                	ld	ra,40(sp)
ffffffffc0201520:	69a2                	ld	s3,8(sp)
ffffffffc0201522:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201524:	85ca                	mv	a1,s2
ffffffffc0201526:	87a6                	mv	a5,s1
}
ffffffffc0201528:	6942                	ld	s2,16(sp)
ffffffffc020152a:	64e2                	ld	s1,24(sp)
ffffffffc020152c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020152e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201530:	03065633          	divu	a2,a2,a6
ffffffffc0201534:	8722                	mv	a4,s0
ffffffffc0201536:	f9bff0ef          	jal	ra,ffffffffc02014d0 <printnum>
ffffffffc020153a:	b7f9                	j	ffffffffc0201508 <printnum+0x38>

ffffffffc020153c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020153c:	7119                	addi	sp,sp,-128
ffffffffc020153e:	f4a6                	sd	s1,104(sp)
ffffffffc0201540:	f0ca                	sd	s2,96(sp)
ffffffffc0201542:	ecce                	sd	s3,88(sp)
ffffffffc0201544:	e8d2                	sd	s4,80(sp)
ffffffffc0201546:	e4d6                	sd	s5,72(sp)
ffffffffc0201548:	e0da                	sd	s6,64(sp)
ffffffffc020154a:	fc5e                	sd	s7,56(sp)
ffffffffc020154c:	f06a                	sd	s10,32(sp)
ffffffffc020154e:	fc86                	sd	ra,120(sp)
ffffffffc0201550:	f8a2                	sd	s0,112(sp)
ffffffffc0201552:	f862                	sd	s8,48(sp)
ffffffffc0201554:	f466                	sd	s9,40(sp)
ffffffffc0201556:	ec6e                	sd	s11,24(sp)
ffffffffc0201558:	892a                	mv	s2,a0
ffffffffc020155a:	84ae                	mv	s1,a1
ffffffffc020155c:	8d32                	mv	s10,a2
ffffffffc020155e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201560:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201564:	5b7d                	li	s6,-1
ffffffffc0201566:	00001a97          	auipc	s5,0x1
ffffffffc020156a:	beea8a93          	addi	s5,s5,-1042 # ffffffffc0202154 <buddy_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020156e:	00001b97          	auipc	s7,0x1
ffffffffc0201572:	dc2b8b93          	addi	s7,s7,-574 # ffffffffc0202330 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201576:	000d4503          	lbu	a0,0(s10)
ffffffffc020157a:	001d0413          	addi	s0,s10,1
ffffffffc020157e:	01350a63          	beq	a0,s3,ffffffffc0201592 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201582:	c121                	beqz	a0,ffffffffc02015c2 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201584:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201586:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201588:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020158a:	fff44503          	lbu	a0,-1(s0)
ffffffffc020158e:	ff351ae3          	bne	a0,s3,ffffffffc0201582 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201592:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201596:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020159a:	4c81                	li	s9,0
ffffffffc020159c:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020159e:	5c7d                	li	s8,-1
ffffffffc02015a0:	5dfd                	li	s11,-1
ffffffffc02015a2:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02015a6:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015a8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02015ac:	0ff5f593          	zext.b	a1,a1
ffffffffc02015b0:	00140d13          	addi	s10,s0,1
ffffffffc02015b4:	04b56263          	bltu	a0,a1,ffffffffc02015f8 <vprintfmt+0xbc>
ffffffffc02015b8:	058a                	slli	a1,a1,0x2
ffffffffc02015ba:	95d6                	add	a1,a1,s5
ffffffffc02015bc:	4194                	lw	a3,0(a1)
ffffffffc02015be:	96d6                	add	a3,a3,s5
ffffffffc02015c0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02015c2:	70e6                	ld	ra,120(sp)
ffffffffc02015c4:	7446                	ld	s0,112(sp)
ffffffffc02015c6:	74a6                	ld	s1,104(sp)
ffffffffc02015c8:	7906                	ld	s2,96(sp)
ffffffffc02015ca:	69e6                	ld	s3,88(sp)
ffffffffc02015cc:	6a46                	ld	s4,80(sp)
ffffffffc02015ce:	6aa6                	ld	s5,72(sp)
ffffffffc02015d0:	6b06                	ld	s6,64(sp)
ffffffffc02015d2:	7be2                	ld	s7,56(sp)
ffffffffc02015d4:	7c42                	ld	s8,48(sp)
ffffffffc02015d6:	7ca2                	ld	s9,40(sp)
ffffffffc02015d8:	7d02                	ld	s10,32(sp)
ffffffffc02015da:	6de2                	ld	s11,24(sp)
ffffffffc02015dc:	6109                	addi	sp,sp,128
ffffffffc02015de:	8082                	ret
            padc = '0';
ffffffffc02015e0:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02015e2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015e6:	846a                	mv	s0,s10
ffffffffc02015e8:	00140d13          	addi	s10,s0,1
ffffffffc02015ec:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02015f0:	0ff5f593          	zext.b	a1,a1
ffffffffc02015f4:	fcb572e3          	bgeu	a0,a1,ffffffffc02015b8 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02015f8:	85a6                	mv	a1,s1
ffffffffc02015fa:	02500513          	li	a0,37
ffffffffc02015fe:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201600:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201604:	8d22                	mv	s10,s0
ffffffffc0201606:	f73788e3          	beq	a5,s3,ffffffffc0201576 <vprintfmt+0x3a>
ffffffffc020160a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020160e:	1d7d                	addi	s10,s10,-1
ffffffffc0201610:	ff379de3          	bne	a5,s3,ffffffffc020160a <vprintfmt+0xce>
ffffffffc0201614:	b78d                	j	ffffffffc0201576 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201616:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020161a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020161e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201620:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201624:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201628:	02d86463          	bltu	a6,a3,ffffffffc0201650 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020162c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201630:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201634:	0186873b          	addw	a4,a3,s8
ffffffffc0201638:	0017171b          	slliw	a4,a4,0x1
ffffffffc020163c:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020163e:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201642:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201644:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201648:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020164c:	fed870e3          	bgeu	a6,a3,ffffffffc020162c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201650:	f40ddce3          	bgez	s11,ffffffffc02015a8 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201654:	8de2                	mv	s11,s8
ffffffffc0201656:	5c7d                	li	s8,-1
ffffffffc0201658:	bf81                	j	ffffffffc02015a8 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020165a:	fffdc693          	not	a3,s11
ffffffffc020165e:	96fd                	srai	a3,a3,0x3f
ffffffffc0201660:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201664:	00144603          	lbu	a2,1(s0)
ffffffffc0201668:	2d81                	sext.w	s11,s11
ffffffffc020166a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020166c:	bf35                	j	ffffffffc02015a8 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020166e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201672:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201676:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201678:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020167a:	bfd9                	j	ffffffffc0201650 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020167c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020167e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201682:	01174463          	blt	a4,a7,ffffffffc020168a <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201686:	1a088e63          	beqz	a7,ffffffffc0201842 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020168a:	000a3603          	ld	a2,0(s4)
ffffffffc020168e:	46c1                	li	a3,16
ffffffffc0201690:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201692:	2781                	sext.w	a5,a5
ffffffffc0201694:	876e                	mv	a4,s11
ffffffffc0201696:	85a6                	mv	a1,s1
ffffffffc0201698:	854a                	mv	a0,s2
ffffffffc020169a:	e37ff0ef          	jal	ra,ffffffffc02014d0 <printnum>
            break;
ffffffffc020169e:	bde1                	j	ffffffffc0201576 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02016a0:	000a2503          	lw	a0,0(s4)
ffffffffc02016a4:	85a6                	mv	a1,s1
ffffffffc02016a6:	0a21                	addi	s4,s4,8
ffffffffc02016a8:	9902                	jalr	s2
            break;
ffffffffc02016aa:	b5f1                	j	ffffffffc0201576 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02016ac:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016ae:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016b2:	01174463          	blt	a4,a7,ffffffffc02016ba <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02016b6:	18088163          	beqz	a7,ffffffffc0201838 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02016ba:	000a3603          	ld	a2,0(s4)
ffffffffc02016be:	46a9                	li	a3,10
ffffffffc02016c0:	8a2e                	mv	s4,a1
ffffffffc02016c2:	bfc1                	j	ffffffffc0201692 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016c4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02016c8:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ca:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016cc:	bdf1                	j	ffffffffc02015a8 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02016ce:	85a6                	mv	a1,s1
ffffffffc02016d0:	02500513          	li	a0,37
ffffffffc02016d4:	9902                	jalr	s2
            break;
ffffffffc02016d6:	b545                	j	ffffffffc0201576 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016d8:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02016dc:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016de:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016e0:	b5e1                	j	ffffffffc02015a8 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02016e2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016e4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016e8:	01174463          	blt	a4,a7,ffffffffc02016f0 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02016ec:	14088163          	beqz	a7,ffffffffc020182e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02016f0:	000a3603          	ld	a2,0(s4)
ffffffffc02016f4:	46a1                	li	a3,8
ffffffffc02016f6:	8a2e                	mv	s4,a1
ffffffffc02016f8:	bf69                	j	ffffffffc0201692 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02016fa:	03000513          	li	a0,48
ffffffffc02016fe:	85a6                	mv	a1,s1
ffffffffc0201700:	e03e                	sd	a5,0(sp)
ffffffffc0201702:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201704:	85a6                	mv	a1,s1
ffffffffc0201706:	07800513          	li	a0,120
ffffffffc020170a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020170c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020170e:	6782                	ld	a5,0(sp)
ffffffffc0201710:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201712:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201716:	bfb5                	j	ffffffffc0201692 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201718:	000a3403          	ld	s0,0(s4)
ffffffffc020171c:	008a0713          	addi	a4,s4,8
ffffffffc0201720:	e03a                	sd	a4,0(sp)
ffffffffc0201722:	14040263          	beqz	s0,ffffffffc0201866 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201726:	0fb05763          	blez	s11,ffffffffc0201814 <vprintfmt+0x2d8>
ffffffffc020172a:	02d00693          	li	a3,45
ffffffffc020172e:	0cd79163          	bne	a5,a3,ffffffffc02017f0 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201732:	00044783          	lbu	a5,0(s0)
ffffffffc0201736:	0007851b          	sext.w	a0,a5
ffffffffc020173a:	cf85                	beqz	a5,ffffffffc0201772 <vprintfmt+0x236>
ffffffffc020173c:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201740:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201744:	000c4563          	bltz	s8,ffffffffc020174e <vprintfmt+0x212>
ffffffffc0201748:	3c7d                	addiw	s8,s8,-1
ffffffffc020174a:	036c0263          	beq	s8,s6,ffffffffc020176e <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020174e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201750:	0e0c8e63          	beqz	s9,ffffffffc020184c <vprintfmt+0x310>
ffffffffc0201754:	3781                	addiw	a5,a5,-32
ffffffffc0201756:	0ef47b63          	bgeu	s0,a5,ffffffffc020184c <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020175a:	03f00513          	li	a0,63
ffffffffc020175e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201760:	000a4783          	lbu	a5,0(s4)
ffffffffc0201764:	3dfd                	addiw	s11,s11,-1
ffffffffc0201766:	0a05                	addi	s4,s4,1
ffffffffc0201768:	0007851b          	sext.w	a0,a5
ffffffffc020176c:	ffe1                	bnez	a5,ffffffffc0201744 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020176e:	01b05963          	blez	s11,ffffffffc0201780 <vprintfmt+0x244>
ffffffffc0201772:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201774:	85a6                	mv	a1,s1
ffffffffc0201776:	02000513          	li	a0,32
ffffffffc020177a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020177c:	fe0d9be3          	bnez	s11,ffffffffc0201772 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201780:	6a02                	ld	s4,0(sp)
ffffffffc0201782:	bbd5                	j	ffffffffc0201576 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201784:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201786:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020178a:	01174463          	blt	a4,a7,ffffffffc0201792 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020178e:	08088d63          	beqz	a7,ffffffffc0201828 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201792:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201796:	0a044d63          	bltz	s0,ffffffffc0201850 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020179a:	8622                	mv	a2,s0
ffffffffc020179c:	8a66                	mv	s4,s9
ffffffffc020179e:	46a9                	li	a3,10
ffffffffc02017a0:	bdcd                	j	ffffffffc0201692 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02017a2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017a6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02017a8:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02017aa:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02017ae:	8fb5                	xor	a5,a5,a3
ffffffffc02017b0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017b4:	02d74163          	blt	a4,a3,ffffffffc02017d6 <vprintfmt+0x29a>
ffffffffc02017b8:	00369793          	slli	a5,a3,0x3
ffffffffc02017bc:	97de                	add	a5,a5,s7
ffffffffc02017be:	639c                	ld	a5,0(a5)
ffffffffc02017c0:	cb99                	beqz	a5,ffffffffc02017d6 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02017c2:	86be                	mv	a3,a5
ffffffffc02017c4:	00001617          	auipc	a2,0x1
ffffffffc02017c8:	98c60613          	addi	a2,a2,-1652 # ffffffffc0202150 <buddy_pmm_manager+0x68>
ffffffffc02017cc:	85a6                	mv	a1,s1
ffffffffc02017ce:	854a                	mv	a0,s2
ffffffffc02017d0:	0ce000ef          	jal	ra,ffffffffc020189e <printfmt>
ffffffffc02017d4:	b34d                	j	ffffffffc0201576 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02017d6:	00001617          	auipc	a2,0x1
ffffffffc02017da:	96a60613          	addi	a2,a2,-1686 # ffffffffc0202140 <buddy_pmm_manager+0x58>
ffffffffc02017de:	85a6                	mv	a1,s1
ffffffffc02017e0:	854a                	mv	a0,s2
ffffffffc02017e2:	0bc000ef          	jal	ra,ffffffffc020189e <printfmt>
ffffffffc02017e6:	bb41                	j	ffffffffc0201576 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02017e8:	00001417          	auipc	s0,0x1
ffffffffc02017ec:	95040413          	addi	s0,s0,-1712 # ffffffffc0202138 <buddy_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017f0:	85e2                	mv	a1,s8
ffffffffc02017f2:	8522                	mv	a0,s0
ffffffffc02017f4:	e43e                	sd	a5,8(sp)
ffffffffc02017f6:	c69ff0ef          	jal	ra,ffffffffc020145e <strnlen>
ffffffffc02017fa:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02017fe:	01b05b63          	blez	s11,ffffffffc0201814 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201802:	67a2                	ld	a5,8(sp)
ffffffffc0201804:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201808:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020180a:	85a6                	mv	a1,s1
ffffffffc020180c:	8552                	mv	a0,s4
ffffffffc020180e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201810:	fe0d9ce3          	bnez	s11,ffffffffc0201808 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201814:	00044783          	lbu	a5,0(s0)
ffffffffc0201818:	00140a13          	addi	s4,s0,1
ffffffffc020181c:	0007851b          	sext.w	a0,a5
ffffffffc0201820:	d3a5                	beqz	a5,ffffffffc0201780 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201822:	05e00413          	li	s0,94
ffffffffc0201826:	bf39                	j	ffffffffc0201744 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201828:	000a2403          	lw	s0,0(s4)
ffffffffc020182c:	b7ad                	j	ffffffffc0201796 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020182e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201832:	46a1                	li	a3,8
ffffffffc0201834:	8a2e                	mv	s4,a1
ffffffffc0201836:	bdb1                	j	ffffffffc0201692 <vprintfmt+0x156>
ffffffffc0201838:	000a6603          	lwu	a2,0(s4)
ffffffffc020183c:	46a9                	li	a3,10
ffffffffc020183e:	8a2e                	mv	s4,a1
ffffffffc0201840:	bd89                	j	ffffffffc0201692 <vprintfmt+0x156>
ffffffffc0201842:	000a6603          	lwu	a2,0(s4)
ffffffffc0201846:	46c1                	li	a3,16
ffffffffc0201848:	8a2e                	mv	s4,a1
ffffffffc020184a:	b5a1                	j	ffffffffc0201692 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020184c:	9902                	jalr	s2
ffffffffc020184e:	bf09                	j	ffffffffc0201760 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201850:	85a6                	mv	a1,s1
ffffffffc0201852:	02d00513          	li	a0,45
ffffffffc0201856:	e03e                	sd	a5,0(sp)
ffffffffc0201858:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020185a:	6782                	ld	a5,0(sp)
ffffffffc020185c:	8a66                	mv	s4,s9
ffffffffc020185e:	40800633          	neg	a2,s0
ffffffffc0201862:	46a9                	li	a3,10
ffffffffc0201864:	b53d                	j	ffffffffc0201692 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201866:	03b05163          	blez	s11,ffffffffc0201888 <vprintfmt+0x34c>
ffffffffc020186a:	02d00693          	li	a3,45
ffffffffc020186e:	f6d79de3          	bne	a5,a3,ffffffffc02017e8 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201872:	00001417          	auipc	s0,0x1
ffffffffc0201876:	8c640413          	addi	s0,s0,-1850 # ffffffffc0202138 <buddy_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020187a:	02800793          	li	a5,40
ffffffffc020187e:	02800513          	li	a0,40
ffffffffc0201882:	00140a13          	addi	s4,s0,1
ffffffffc0201886:	bd6d                	j	ffffffffc0201740 <vprintfmt+0x204>
ffffffffc0201888:	00001a17          	auipc	s4,0x1
ffffffffc020188c:	8b1a0a13          	addi	s4,s4,-1871 # ffffffffc0202139 <buddy_pmm_manager+0x51>
ffffffffc0201890:	02800513          	li	a0,40
ffffffffc0201894:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201898:	05e00413          	li	s0,94
ffffffffc020189c:	b565                	j	ffffffffc0201744 <vprintfmt+0x208>

ffffffffc020189e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020189e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02018a0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018a4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02018a6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018a8:	ec06                	sd	ra,24(sp)
ffffffffc02018aa:	f83a                	sd	a4,48(sp)
ffffffffc02018ac:	fc3e                	sd	a5,56(sp)
ffffffffc02018ae:	e0c2                	sd	a6,64(sp)
ffffffffc02018b0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02018b2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02018b4:	c89ff0ef          	jal	ra,ffffffffc020153c <vprintfmt>
}
ffffffffc02018b8:	60e2                	ld	ra,24(sp)
ffffffffc02018ba:	6161                	addi	sp,sp,80
ffffffffc02018bc:	8082                	ret

ffffffffc02018be <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02018be:	4781                	li	a5,0
ffffffffc02018c0:	00004717          	auipc	a4,0x4
ffffffffc02018c4:	75073703          	ld	a4,1872(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc02018c8:	88ba                	mv	a7,a4
ffffffffc02018ca:	852a                	mv	a0,a0
ffffffffc02018cc:	85be                	mv	a1,a5
ffffffffc02018ce:	863e                	mv	a2,a5
ffffffffc02018d0:	00000073          	ecall
ffffffffc02018d4:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02018d6:	8082                	ret
