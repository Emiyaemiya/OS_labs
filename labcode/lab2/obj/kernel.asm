
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
ffffffffc0200050:	b0450513          	addi	a0,a0,-1276 # ffffffffc0201b50 <etext+0x4>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00002517          	auipc	a0,0x2
ffffffffc0200066:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0201b70 <etext+0x24>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00002597          	auipc	a1,0x2
ffffffffc0200072:	ade58593          	addi	a1,a1,-1314 # ffffffffc0201b4c <etext>
ffffffffc0200076:	00002517          	auipc	a0,0x2
ffffffffc020007a:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0201b90 <etext+0x44>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <kmalloc_caches>
ffffffffc020008a:	00002517          	auipc	a0,0x2
ffffffffc020008e:	b2650513          	addi	a0,a0,-1242 # ffffffffc0201bb0 <etext+0x64>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00006597          	auipc	a1,0x6
ffffffffc020009a:	1a258593          	addi	a1,a1,418 # ffffffffc0206238 <end>
ffffffffc020009e:	00002517          	auipc	a0,0x2
ffffffffc02000a2:	b3250513          	addi	a0,a0,-1230 # ffffffffc0201bd0 <etext+0x84>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00006597          	auipc	a1,0x6
ffffffffc02000ae:	58d58593          	addi	a1,a1,1421 # ffffffffc0206637 <end+0x3ff>
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
ffffffffc02000d0:	b2450513          	addi	a0,a0,-1244 # ffffffffc0201bf0 <etext+0xa4>
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
ffffffffc02000e4:	15860613          	addi	a2,a2,344 # ffffffffc0206238 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	642010ef          	jal	ra,ffffffffc0201732 <memset>
    dtb_init();
ffffffffc02000f4:	122000ef          	jal	ra,ffffffffc0200216 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	4ce000ef          	jal	ra,ffffffffc02005c6 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00002517          	auipc	a0,0x2
ffffffffc0200100:	b2450513          	addi	a0,a0,-1244 # ffffffffc0201c20 <etext+0xd4>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	4e8000ef          	jal	ra,ffffffffc02005f4 <pmm_init>

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
ffffffffc0200140:	670010ef          	jal	ra,ffffffffc02017b0 <vprintfmt>
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
ffffffffc0200176:	63a010ef          	jal	ra,ffffffffc02017b0 <vprintfmt>
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
ffffffffc02001c6:	02e30313          	addi	t1,t1,46 # ffffffffc02061f0 <is_panic>
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
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0201c40 <etext+0xf4>
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
ffffffffc020020c:	a1050513          	addi	a0,a0,-1520 # ffffffffc0201c18 <etext+0xcc>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200216:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200218:	00002517          	auipc	a0,0x2
ffffffffc020021c:	a4850513          	addi	a0,a0,-1464 # ffffffffc0201c60 <etext+0x114>
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
ffffffffc0200246:	00002517          	auipc	a0,0x2
ffffffffc020024a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0201c70 <etext+0x124>
ffffffffc020024e:	effff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200252:	00006417          	auipc	s0,0x6
ffffffffc0200256:	db640413          	addi	s0,s0,-586 # ffffffffc0206008 <boot_dtb>
ffffffffc020025a:	600c                	ld	a1,0(s0)
ffffffffc020025c:	00002517          	auipc	a0,0x2
ffffffffc0200260:	a2450513          	addi	a0,a0,-1500 # ffffffffc0201c80 <etext+0x134>
ffffffffc0200264:	ee9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200268:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020026c:	00002517          	auipc	a0,0x2
ffffffffc0200270:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0201c98 <etext+0x14c>
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
ffffffffc02002b4:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed9cb5>
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
ffffffffc0200326:	00002917          	auipc	s2,0x2
ffffffffc020032a:	9c290913          	addi	s2,s2,-1598 # ffffffffc0201ce8 <etext+0x19c>
ffffffffc020032e:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200330:	4d91                	li	s11,4
ffffffffc0200332:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200334:	00002497          	auipc	s1,0x2
ffffffffc0200338:	9ac48493          	addi	s1,s1,-1620 # ffffffffc0201ce0 <etext+0x194>
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
ffffffffc0200388:	00002517          	auipc	a0,0x2
ffffffffc020038c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0201d60 <etext+0x214>
ffffffffc0200390:	dbdff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200394:	00002517          	auipc	a0,0x2
ffffffffc0200398:	a0450513          	addi	a0,a0,-1532 # ffffffffc0201d98 <etext+0x24c>
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
ffffffffc02003d4:	00002517          	auipc	a0,0x2
ffffffffc02003d8:	8e450513          	addi	a0,a0,-1820 # ffffffffc0201cb8 <etext+0x16c>
}
ffffffffc02003dc:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003de:	b3bd                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003e0:	8556                	mv	a0,s5
ffffffffc02003e2:	2d6010ef          	jal	ra,ffffffffc02016b8 <strlen>
ffffffffc02003e6:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e8:	4619                	li	a2,6
ffffffffc02003ea:	85a6                	mv	a1,s1
ffffffffc02003ec:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003ee:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f0:	31c010ef          	jal	ra,ffffffffc020170c <strncmp>
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
ffffffffc0200486:	268010ef          	jal	ra,ffffffffc02016ee <strcmp>
ffffffffc020048a:	66a2                	ld	a3,8(sp)
ffffffffc020048c:	f94d                	bnez	a0,ffffffffc020043e <dtb_init+0x228>
ffffffffc020048e:	fb59f8e3          	bgeu	s3,s5,ffffffffc020043e <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200492:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200496:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020049a:	00002517          	auipc	a0,0x2
ffffffffc020049e:	85650513          	addi	a0,a0,-1962 # ffffffffc0201cf0 <etext+0x1a4>
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
ffffffffc020056c:	7a850513          	addi	a0,a0,1960 # ffffffffc0201d10 <etext+0x1c4>
ffffffffc0200570:	bddff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200574:	014b5613          	srli	a2,s6,0x14
ffffffffc0200578:	85da                	mv	a1,s6
ffffffffc020057a:	00001517          	auipc	a0,0x1
ffffffffc020057e:	7ae50513          	addi	a0,a0,1966 # ffffffffc0201d28 <etext+0x1dc>
ffffffffc0200582:	bcbff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200586:	008b05b3          	add	a1,s6,s0
ffffffffc020058a:	15fd                	addi	a1,a1,-1
ffffffffc020058c:	00001517          	auipc	a0,0x1
ffffffffc0200590:	7bc50513          	addi	a0,a0,1980 # ffffffffc0201d48 <etext+0x1fc>
ffffffffc0200594:	bb9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	80050513          	addi	a0,a0,-2048 # ffffffffc0201d98 <etext+0x24c>
        memory_base = mem_base;
ffffffffc02005a0:	00006797          	auipc	a5,0x6
ffffffffc02005a4:	c487bc23          	sd	s0,-936(a5) # ffffffffc02061f8 <memory_base>
        memory_size = mem_size;
ffffffffc02005a8:	00006797          	auipc	a5,0x6
ffffffffc02005ac:	c567bc23          	sd	s6,-936(a5) # ffffffffc0206200 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005b0:	b3f5                	j	ffffffffc020039c <dtb_init+0x186>

ffffffffc02005b2 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005b2:	00006517          	auipc	a0,0x6
ffffffffc02005b6:	c4653503          	ld	a0,-954(a0) # ffffffffc02061f8 <memory_base>
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005bc:	00006517          	auipc	a0,0x6
ffffffffc02005c0:	c4453503          	ld	a0,-956(a0) # ffffffffc0206200 <memory_size>
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
ffffffffc02005cc:	5660106f          	j	ffffffffc0201b32 <sbi_console_putchar>

ffffffffc02005d0 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc02005d0:	00006797          	auipc	a5,0x6
ffffffffc02005d4:	c487b783          	ld	a5,-952(a5) # ffffffffc0206218 <pmm_manager>
ffffffffc02005d8:	6f9c                	ld	a5,24(a5)
ffffffffc02005da:	8782                	jr	a5

ffffffffc02005dc <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc02005dc:	00006797          	auipc	a5,0x6
ffffffffc02005e0:	c3c7b783          	ld	a5,-964(a5) # ffffffffc0206218 <pmm_manager>
ffffffffc02005e4:	739c                	ld	a5,32(a5)
ffffffffc02005e6:	8782                	jr	a5

ffffffffc02005e8 <nr_free_pages>:
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
size_t nr_free_pages(void) {
    return pmm_manager->nr_free_pages();
ffffffffc02005e8:	00006797          	auipc	a5,0x6
ffffffffc02005ec:	c307b783          	ld	a5,-976(a5) # ffffffffc0206218 <pmm_manager>
ffffffffc02005f0:	779c                	ld	a5,40(a5)
ffffffffc02005f2:	8782                	jr	a5

ffffffffc02005f4 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02005f4:	00002797          	auipc	a5,0x2
ffffffffc02005f8:	d6478793          	addi	a5,a5,-668 # ffffffffc0202358 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005fc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02005fe:	7179                	addi	sp,sp,-48
ffffffffc0200600:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200602:	00001517          	auipc	a0,0x1
ffffffffc0200606:	7ae50513          	addi	a0,a0,1966 # ffffffffc0201db0 <etext+0x264>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020060a:	00006417          	auipc	s0,0x6
ffffffffc020060e:	c0e40413          	addi	s0,s0,-1010 # ffffffffc0206218 <pmm_manager>
void pmm_init(void) {
ffffffffc0200612:	f406                	sd	ra,40(sp)
ffffffffc0200614:	ec26                	sd	s1,24(sp)
ffffffffc0200616:	e44e                	sd	s3,8(sp)
ffffffffc0200618:	e84a                	sd	s2,16(sp)
ffffffffc020061a:	e052                	sd	s4,0(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020061c:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020061e:	b2fff0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0200622:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200624:	00006497          	auipc	s1,0x6
ffffffffc0200628:	c0c48493          	addi	s1,s1,-1012 # ffffffffc0206230 <va_pa_offset>
    pmm_manager->init();
ffffffffc020062c:	679c                	ld	a5,8(a5)
ffffffffc020062e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200630:	57f5                	li	a5,-3
ffffffffc0200632:	07fa                	slli	a5,a5,0x1e
ffffffffc0200634:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0200636:	f7dff0ef          	jal	ra,ffffffffc02005b2 <get_memory_base>
ffffffffc020063a:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc020063c:	f81ff0ef          	jal	ra,ffffffffc02005bc <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200640:	14050e63          	beqz	a0,ffffffffc020079c <pmm_init+0x1a8>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200644:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200646:	00001517          	auipc	a0,0x1
ffffffffc020064a:	7b250513          	addi	a0,a0,1970 # ffffffffc0201df8 <etext+0x2ac>
ffffffffc020064e:	affff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200652:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200656:	864e                	mv	a2,s3
ffffffffc0200658:	fffa0693          	addi	a3,s4,-1
ffffffffc020065c:	85ca                	mv	a1,s2
ffffffffc020065e:	00001517          	auipc	a0,0x1
ffffffffc0200662:	7b250513          	addi	a0,a0,1970 # ffffffffc0201e10 <etext+0x2c4>
ffffffffc0200666:	ae7ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020066a:	c80007b7          	lui	a5,0xc8000
ffffffffc020066e:	8652                	mv	a2,s4
ffffffffc0200670:	0d47e563          	bltu	a5,s4,ffffffffc020073a <pmm_init+0x146>
ffffffffc0200674:	00007797          	auipc	a5,0x7
ffffffffc0200678:	bc378793          	addi	a5,a5,-1085 # ffffffffc0207237 <end+0xfff>
ffffffffc020067c:	757d                	lui	a0,0xfffff
ffffffffc020067e:	8d7d                	and	a0,a0,a5
ffffffffc0200680:	8231                	srli	a2,a2,0xc
ffffffffc0200682:	00006797          	auipc	a5,0x6
ffffffffc0200686:	b8c7b323          	sd	a2,-1146(a5) # ffffffffc0206208 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020068a:	00006797          	auipc	a5,0x6
ffffffffc020068e:	b8a7b323          	sd	a0,-1146(a5) # ffffffffc0206210 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200692:	000807b7          	lui	a5,0x80
ffffffffc0200696:	002005b7          	lui	a1,0x200
ffffffffc020069a:	02f60563          	beq	a2,a5,ffffffffc02006c4 <pmm_init+0xd0>
ffffffffc020069e:	00261593          	slli	a1,a2,0x2
ffffffffc02006a2:	00c586b3          	add	a3,a1,a2
ffffffffc02006a6:	fec007b7          	lui	a5,0xfec00
ffffffffc02006aa:	97aa                	add	a5,a5,a0
ffffffffc02006ac:	068e                	slli	a3,a3,0x3
ffffffffc02006ae:	96be                	add	a3,a3,a5
ffffffffc02006b0:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc02006b2:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02006b4:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f9df0>
        SetPageReserved(pages + i);
ffffffffc02006b8:	00176713          	ori	a4,a4,1
ffffffffc02006bc:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02006c0:	fef699e3          	bne	a3,a5,ffffffffc02006b2 <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006c4:	95b2                	add	a1,a1,a2
ffffffffc02006c6:	fec006b7          	lui	a3,0xfec00
ffffffffc02006ca:	96aa                	add	a3,a3,a0
ffffffffc02006cc:	058e                	slli	a1,a1,0x3
ffffffffc02006ce:	96ae                	add	a3,a3,a1
ffffffffc02006d0:	c02007b7          	lui	a5,0xc0200
ffffffffc02006d4:	0af6e863          	bltu	a3,a5,ffffffffc0200784 <pmm_init+0x190>
ffffffffc02006d8:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02006da:	77fd                	lui	a5,0xfffff
ffffffffc02006dc:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006e0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02006e2:	04b6ef63          	bltu	a3,a1,ffffffffc0200740 <pmm_init+0x14c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02006e6:	601c                	ld	a5,0(s0)
ffffffffc02006e8:	7b9c                	ld	a5,48(a5)
ffffffffc02006ea:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02006ec:	00001517          	auipc	a0,0x1
ffffffffc02006f0:	7ac50513          	addi	a0,a0,1964 # ffffffffc0201e98 <etext+0x34c>
ffffffffc02006f4:	a59ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    //slub_check();
ffffffffc02006f8:	280000ef          	jal	ra,ffffffffc0200978 <slub_check>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02006fc:	00005597          	auipc	a1,0x5
ffffffffc0200700:	90458593          	addi	a1,a1,-1788 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200704:	00006797          	auipc	a5,0x6
ffffffffc0200708:	b2b7b223          	sd	a1,-1244(a5) # ffffffffc0206228 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020070c:	c02007b7          	lui	a5,0xc0200
ffffffffc0200710:	0af5e263          	bltu	a1,a5,ffffffffc02007b4 <pmm_init+0x1c0>
ffffffffc0200714:	6090                	ld	a2,0(s1)
}
ffffffffc0200716:	7402                	ld	s0,32(sp)
ffffffffc0200718:	70a2                	ld	ra,40(sp)
ffffffffc020071a:	64e2                	ld	s1,24(sp)
ffffffffc020071c:	6942                	ld	s2,16(sp)
ffffffffc020071e:	69a2                	ld	s3,8(sp)
ffffffffc0200720:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200722:	40c58633          	sub	a2,a1,a2
ffffffffc0200726:	00006797          	auipc	a5,0x6
ffffffffc020072a:	aec7bd23          	sd	a2,-1286(a5) # ffffffffc0206220 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020072e:	00001517          	auipc	a0,0x1
ffffffffc0200732:	78a50513          	addi	a0,a0,1930 # ffffffffc0201eb8 <etext+0x36c>
}
ffffffffc0200736:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200738:	bc11                	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020073a:	c8000637          	lui	a2,0xc8000
ffffffffc020073e:	bf1d                	j	ffffffffc0200674 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200740:	6705                	lui	a4,0x1
ffffffffc0200742:	177d                	addi	a4,a4,-1
ffffffffc0200744:	96ba                	add	a3,a3,a4
ffffffffc0200746:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200748:	00c6d793          	srli	a5,a3,0xc
ffffffffc020074c:	02c7f063          	bgeu	a5,a2,ffffffffc020076c <pmm_init+0x178>
    pmm_manager->init_memmap(base, n);
ffffffffc0200750:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200752:	fff80737          	lui	a4,0xfff80
ffffffffc0200756:	973e                	add	a4,a4,a5
ffffffffc0200758:	00271793          	slli	a5,a4,0x2
ffffffffc020075c:	97ba                	add	a5,a5,a4
ffffffffc020075e:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200760:	8d95                	sub	a1,a1,a3
ffffffffc0200762:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200764:	81b1                	srli	a1,a1,0xc
ffffffffc0200766:	953e                	add	a0,a0,a5
ffffffffc0200768:	9702                	jalr	a4
}
ffffffffc020076a:	bfb5                	j	ffffffffc02006e6 <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc020076c:	00001617          	auipc	a2,0x1
ffffffffc0200770:	6fc60613          	addi	a2,a2,1788 # ffffffffc0201e68 <etext+0x31c>
ffffffffc0200774:	06800593          	li	a1,104
ffffffffc0200778:	00001517          	auipc	a0,0x1
ffffffffc020077c:	71050513          	addi	a0,a0,1808 # ffffffffc0201e88 <etext+0x33c>
ffffffffc0200780:	a43ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200784:	00001617          	auipc	a2,0x1
ffffffffc0200788:	6bc60613          	addi	a2,a2,1724 # ffffffffc0201e40 <etext+0x2f4>
ffffffffc020078c:	06000593          	li	a1,96
ffffffffc0200790:	00001517          	auipc	a0,0x1
ffffffffc0200794:	65850513          	addi	a0,a0,1624 # ffffffffc0201de8 <etext+0x29c>
ffffffffc0200798:	a2bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc020079c:	00001617          	auipc	a2,0x1
ffffffffc02007a0:	62c60613          	addi	a2,a2,1580 # ffffffffc0201dc8 <etext+0x27c>
ffffffffc02007a4:	04800593          	li	a1,72
ffffffffc02007a8:	00001517          	auipc	a0,0x1
ffffffffc02007ac:	64050513          	addi	a0,a0,1600 # ffffffffc0201de8 <etext+0x29c>
ffffffffc02007b0:	a13ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02007b4:	86ae                	mv	a3,a1
ffffffffc02007b6:	00001617          	auipc	a2,0x1
ffffffffc02007ba:	68a60613          	addi	a2,a2,1674 # ffffffffc0201e40 <etext+0x2f4>
ffffffffc02007be:	07b00593          	li	a1,123
ffffffffc02007c2:	00001517          	auipc	a0,0x1
ffffffffc02007c6:	62650513          	addi	a0,a0,1574 # ffffffffc0201de8 <etext+0x29c>
ffffffffc02007ca:	9f9ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02007ce <__cache_alloc>:

// -------------------------
// SLUB 内部分配接口
// -------------------------

void *__cache_alloc(struct kmem_cache *cache) {
ffffffffc02007ce:	1101                	addi	sp,sp,-32
ffffffffc02007d0:	e426                	sd	s1,8(sp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc02007d2:	7104                	ld	s1,32(a0)
ffffffffc02007d4:	e822                	sd	s0,16(sp)
ffffffffc02007d6:	ec06                	sd	ra,24(sp)
    struct slab *slab = NULL;

    // 若有未满的 slab，直接使用
    if (!list_empty(&cache->slabs_partial)) {
ffffffffc02007d8:	01850793          	addi	a5,a0,24
void *__cache_alloc(struct kmem_cache *cache) {
ffffffffc02007dc:	842a                	mv	s0,a0
    if (!list_empty(&cache->slabs_partial)) {
ffffffffc02007de:	04f48363          	beq	s1,a5,ffffffffc0200824 <__cache_alloc+0x56>
    }

    // 从 free_list 中取出一个对象
    struct list_entry *obj = list_prev(&slab->free_list);
    list_del(obj);
    slab->inuse++;
ffffffffc02007e2:	fe84b783          	ld	a5,-24(s1)

    // slab 已满则移入 full 链表
    if (slab->inuse == cache->objs_per_slab) {
ffffffffc02007e6:	690c                	ld	a1,16(a0)
    return (struct slab*)((char*)le - offsetof(struct slab, list_link));
ffffffffc02007e8:	fd848693          	addi	a3,s1,-40
    slab->inuse++;
ffffffffc02007ec:	0785                	addi	a5,a5,1
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc02007ee:	6e88                	ld	a0,24(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02007f0:	6110                	ld	a2,0(a0)
ffffffffc02007f2:	6518                	ld	a4,8(a0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02007f4:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02007f6:	e310                	sd	a2,0(a4)
ffffffffc02007f8:	ea9c                	sd	a5,16(a3)
    if (slab->inuse == cache->objs_per_slab) {
ffffffffc02007fa:	02b79063          	bne	a5,a1,ffffffffc020081a <__cache_alloc+0x4c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02007fe:	768c                	ld	a1,40(a3)
ffffffffc0200800:	7a90                	ld	a2,48(a3)
        list_del(&slab->list_link);
        list_add(&cache->slabs_full, &slab->list_link);
ffffffffc0200802:	02868713          	addi	a4,a3,40 # fffffffffec00028 <end+0x3e9f9df0>
ffffffffc0200806:	02840813          	addi	a6,s0,40
    prev->next = next;
ffffffffc020080a:	e590                	sd	a2,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020080c:	781c                	ld	a5,48(s0)
    next->prev = prev;
ffffffffc020080e:	e20c                	sd	a1,0(a2)
    prev->next = next->prev = elm;
ffffffffc0200810:	e398                	sd	a4,0(a5)
ffffffffc0200812:	f818                	sd	a4,48(s0)
    elm->next = next;
ffffffffc0200814:	fa9c                	sd	a5,48(a3)
    elm->prev = prev;
ffffffffc0200816:	0306b423          	sd	a6,40(a3)
    }

    return (void*)obj;
}
ffffffffc020081a:	60e2                	ld	ra,24(sp)
ffffffffc020081c:	6442                	ld	s0,16(sp)
ffffffffc020081e:	64a2                	ld	s1,8(sp)
ffffffffc0200820:	6105                	addi	sp,sp,32
ffffffffc0200822:	8082                	ret
        struct Page *page = alloc_pages(1);
ffffffffc0200824:	4505                	li	a0,1
ffffffffc0200826:	dabff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
        if (!page) return NULL;
ffffffffc020082a:	d965                	beqz	a0,ffffffffc020081a <__cache_alloc+0x4c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020082c:	00006697          	auipc	a3,0x6
ffffffffc0200830:	9e46b683          	ld	a3,-1564(a3) # ffffffffc0206210 <pages>
ffffffffc0200834:	40d506b3          	sub	a3,a0,a3
ffffffffc0200838:	00002797          	auipc	a5,0x2
ffffffffc020083c:	da87b783          	ld	a5,-600(a5) # ffffffffc02025e0 <nbase+0x8>
ffffffffc0200840:	868d                	srai	a3,a3,0x3
ffffffffc0200842:	02f686b3          	mul	a3,a3,a5
ffffffffc0200846:	00002797          	auipc	a5,0x2
ffffffffc020084a:	d927b783          	ld	a5,-622(a5) # ffffffffc02025d8 <nbase>
        struct slab *ns = (struct slab*)KADDR(page2pa(page));
ffffffffc020084e:	00006717          	auipc	a4,0x6
ffffffffc0200852:	9ba73703          	ld	a4,-1606(a4) # ffffffffc0206208 <npage>
ffffffffc0200856:	96be                	add	a3,a3,a5
ffffffffc0200858:	00c69793          	slli	a5,a3,0xc
ffffffffc020085c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020085e:	06b2                	slli	a3,a3,0xc
ffffffffc0200860:	04e7fc63          	bgeu	a5,a4,ffffffffc02008b8 <__cache_alloc+0xea>
ffffffffc0200864:	00006797          	auipc	a5,0x6
ffffffffc0200868:	9cc7b783          	ld	a5,-1588(a5) # ffffffffc0206230 <va_pa_offset>
ffffffffc020086c:	96be                	add	a3,a3,a5
        for (size_t i = 0; i < cache->objs_per_slab; i++) {
ffffffffc020086e:	680c                	ld	a1,16(s0)
        list_init(&ns->free_list);
ffffffffc0200870:	01868813          	addi	a6,a3,24
        ns->cache = cache;
ffffffffc0200874:	e280                	sd	s0,0(a3)
        ns->page = page;
ffffffffc0200876:	e688                	sd	a0,8(a3)
        ns->inuse = 0;
ffffffffc0200878:	0006b823          	sd	zero,16(a3)
    elm->prev = elm->next = elm;
ffffffffc020087c:	0306b023          	sd	a6,32(a3)
ffffffffc0200880:	0106bc23          	sd	a6,24(a3)
        for (size_t i = 0; i < cache->objs_per_slab; i++) {
ffffffffc0200884:	c18d                	beqz	a1,ffffffffc02008a6 <__cache_alloc+0xd8>
            struct list_entry *le = (struct list_entry*)(obj_base + i * cache->obj_size);
ffffffffc0200886:	6408                	ld	a0,8(s0)
ffffffffc0200888:	03868793          	addi	a5,a3,56
ffffffffc020088c:	8642                	mv	a2,a6
        for (size_t i = 0; i < cache->objs_per_slab; i++) {
ffffffffc020088e:	4701                	li	a4,0
ffffffffc0200890:	a011                	j	ffffffffc0200894 <__cache_alloc+0xc6>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200892:	7290                	ld	a2,32(a3)
    prev->next = next->prev = elm;
ffffffffc0200894:	e21c                	sd	a5,0(a2)
ffffffffc0200896:	f29c                	sd	a5,32(a3)
    elm->next = next;
ffffffffc0200898:	e790                	sd	a2,8(a5)
    elm->prev = prev;
ffffffffc020089a:	0107b023          	sd	a6,0(a5)
ffffffffc020089e:	0705                	addi	a4,a4,1
ffffffffc02008a0:	97aa                	add	a5,a5,a0
ffffffffc02008a2:	feb718e3          	bne	a4,a1,ffffffffc0200892 <__cache_alloc+0xc4>
    __list_add(elm, listelm, listelm->next);
ffffffffc02008a6:	7010                	ld	a2,32(s0)
        list_add(&cache->slabs_partial, &ns->list_link);
ffffffffc02008a8:	02868713          	addi	a4,a3,40
    elm->prev = prev;
ffffffffc02008ac:	4785                	li	a5,1
    prev->next = next->prev = elm;
ffffffffc02008ae:	e218                	sd	a4,0(a2)
ffffffffc02008b0:	f018                	sd	a4,32(s0)
    elm->next = next;
ffffffffc02008b2:	fa90                	sd	a2,48(a3)
    elm->prev = prev;
ffffffffc02008b4:	f684                	sd	s1,40(a3)
        slab = ns;
ffffffffc02008b6:	bf25                	j	ffffffffc02007ee <__cache_alloc+0x20>
        struct slab *ns = (struct slab*)KADDR(page2pa(page));
ffffffffc02008b8:	00001617          	auipc	a2,0x1
ffffffffc02008bc:	64060613          	addi	a2,a2,1600 # ffffffffc0201ef8 <etext+0x3ac>
ffffffffc02008c0:	04000593          	li	a1,64
ffffffffc02008c4:	00001517          	auipc	a0,0x1
ffffffffc02008c8:	65c50513          	addi	a0,a0,1628 # ffffffffc0201f20 <etext+0x3d4>
ffffffffc02008cc:	8f7ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02008d0 <__cache_free>:

void __cache_free(struct kmem_cache *cache, void *obj) {
    struct slab *slab = (struct slab*)((uintptr_t)obj & ~(PGSIZE - 1));
ffffffffc02008d0:	77fd                	lui	a5,0xfffff
ffffffffc02008d2:	8fed                	and	a5,a5,a1
    __list_add(elm, listelm, listelm->next);
ffffffffc02008d4:	7398                	ld	a4,32(a5)
    list_add(&slab->free_list, (struct list_entry*)obj);
    slab->inuse--;
ffffffffc02008d6:	6b94                	ld	a3,16(a5)

    // slab 从 full 变为 partial
    if (slab->inuse + 1 == cache->objs_per_slab) {
ffffffffc02008d8:	6910                	ld	a2,16(a0)
    prev->next = next->prev = elm;
ffffffffc02008da:	e30c                	sd	a1,0(a4)
ffffffffc02008dc:	f38c                	sd	a1,32(a5)
    list_add(&slab->free_list, (struct list_entry*)obj);
ffffffffc02008de:	01878813          	addi	a6,a5,24 # fffffffffffff018 <end+0x3fdf8de0>
    elm->next = next;
ffffffffc02008e2:	e598                	sd	a4,8(a1)
    elm->prev = prev;
ffffffffc02008e4:	0105b023          	sd	a6,0(a1)
    slab->inuse--;
ffffffffc02008e8:	fff68713          	addi	a4,a3,-1
ffffffffc02008ec:	eb98                	sd	a4,16(a5)
    if (slab->inuse + 1 == cache->objs_per_slab) {
ffffffffc02008ee:	00c68463          	beq	a3,a2,ffffffffc02008f6 <__cache_free+0x26>
        list_add(&cache->slabs_partial, &slab->list_link);
    }

    // 目前实现：slab 空了，释放整页

    if (slab->inuse == 0) {
ffffffffc02008f2:	c705                	beqz	a4,ffffffffc020091a <__cache_free+0x4a>
        // else{
        //     list_del(&slab->list_link);
        //     free_pages(slab->page, 1);
        // }
    }
}
ffffffffc02008f4:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc02008f6:	0287b803          	ld	a6,40(a5)
ffffffffc02008fa:	7b8c                	ld	a1,48(a5)
        list_add(&cache->slabs_partial, &slab->list_link);
ffffffffc02008fc:	02878693          	addi	a3,a5,40
ffffffffc0200900:	01850893          	addi	a7,a0,24
    prev->next = next;
ffffffffc0200904:	00b83423          	sd	a1,8(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200908:	7110                	ld	a2,32(a0)
    next->prev = prev;
ffffffffc020090a:	0105b023          	sd	a6,0(a1)
    prev->next = next->prev = elm;
ffffffffc020090e:	e214                	sd	a3,0(a2)
ffffffffc0200910:	f114                	sd	a3,32(a0)
    elm->next = next;
ffffffffc0200912:	fb90                	sd	a2,48(a5)
    elm->prev = prev;
ffffffffc0200914:	0317b423          	sd	a7,40(a5)
    if (slab->inuse == 0) {
ffffffffc0200918:	ff71                	bnez	a4,ffffffffc02008f4 <__cache_free+0x24>
    __list_del(listelm->prev, listelm->next);
ffffffffc020091a:	7794                	ld	a3,40(a5)
ffffffffc020091c:	7b98                	ld	a4,48(a5)
        free_pages(slab->page, 1);
ffffffffc020091e:	6788                	ld	a0,8(a5)
ffffffffc0200920:	4585                	li	a1,1
    prev->next = next;
ffffffffc0200922:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0200924:	e314                	sd	a3,0(a4)
ffffffffc0200926:	b95d                	j	ffffffffc02005dc <free_pages>

ffffffffc0200928 <slub_init>:
    return usable / obj_size;
ffffffffc0200928:	6505                	lui	a0,0x1
ffffffffc020092a:	00005797          	auipc	a5,0x5
ffffffffc020092e:	70678793          	addi	a5,a5,1798 # ffffffffc0206030 <kmalloc_caches+0x18>
ffffffffc0200932:	00001697          	auipc	a3,0x1
ffffffffc0200936:	6b668693          	addi	a3,a3,1718 # ffffffffc0201fe8 <kmalloc_sizes>
ffffffffc020093a:	00006817          	auipc	a6,0x6
ffffffffc020093e:	8b680813          	addi	a6,a6,-1866 # ffffffffc02061f0 <is_panic>
            return i;
    }
    return NUM_KMALLOC_CLASSES - 1; // 默认取最大1024字节类
}

void slub_init(void) {
ffffffffc0200942:	4721                	li	a4,8
    return usable / obj_size;
ffffffffc0200944:	fc850513          	addi	a0,a0,-56 # fc8 <kern_entry-0xffffffffc01ff038>
ffffffffc0200948:	a011                	j	ffffffffc020094c <slub_init+0x24>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
        size_t s = ALIGN_UP(kmalloc_sizes[i], sizeof(void*));
ffffffffc020094a:	6298                	ld	a4,0(a3)
ffffffffc020094c:	071d                	addi	a4,a4,7
ffffffffc020094e:	9b61                	andi	a4,a4,-8
    return usable / obj_size;
ffffffffc0200950:	02e555b3          	divu	a1,a0,a4
ffffffffc0200954:	01078613          	addi	a2,a5,16
        kmalloc_caches[i].name = NULL;
ffffffffc0200958:	fe07b423          	sd	zero,-24(a5)
        kmalloc_caches[i].obj_size = s;
ffffffffc020095c:	fee7b823          	sd	a4,-16(a5)
    elm->prev = elm->next = elm;
ffffffffc0200960:	e79c                	sd	a5,8(a5)
ffffffffc0200962:	e39c                	sd	a5,0(a5)
ffffffffc0200964:	ef90                	sd	a2,24(a5)
ffffffffc0200966:	eb90                	sd	a2,16(a5)
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200968:	03878793          	addi	a5,a5,56
ffffffffc020096c:	06a1                	addi	a3,a3,8
        kmalloc_caches[i].objs_per_slab = slab_objs_per_slab(s);
ffffffffc020096e:	fcb7b023          	sd	a1,-64(a5)
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200972:	fd079ce3          	bne	a5,a6,ffffffffc020094a <slub_init+0x22>
        list_init(&kmalloc_caches[i].slabs_partial);
        list_init(&kmalloc_caches[i].slabs_full);
    }
}
ffffffffc0200976:	8082                	ret

ffffffffc0200978 <slub_check>:

// -------------------------
// 测试函数
// -------------------------

void slub_check(void) {
ffffffffc0200978:	715d                	addi	sp,sp,-80
ffffffffc020097a:	e0a2                	sd	s0,64(sp)
ffffffffc020097c:	fc26                	sd	s1,56(sp)
ffffffffc020097e:	00005417          	auipc	s0,0x5
ffffffffc0200982:	69a40413          	addi	s0,s0,1690 # ffffffffc0206018 <kmalloc_caches>
ffffffffc0200986:	e486                	sd	ra,72(sp)
ffffffffc0200988:	f84a                	sd	s2,48(sp)
ffffffffc020098a:	f44e                	sd	s3,40(sp)
ffffffffc020098c:	f052                	sd	s4,32(sp)
ffffffffc020098e:	ec56                	sd	s5,24(sp)
ffffffffc0200990:	e85a                	sd	s6,16(sp)
ffffffffc0200992:	e45e                	sd	s7,8(sp)
    slub_init();
ffffffffc0200994:	f95ff0ef          	jal	ra,ffffffffc0200928 <slub_init>
ffffffffc0200998:	84a2                	mv	s1,s0
ffffffffc020099a:	8722                	mv	a4,s0
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc020099c:	4781                	li	a5,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc020099e:	07f00613          	li	a2,127
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009a2:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009a4:	6714                	ld	a3,8(a4)
ffffffffc02009a6:	24d66163          	bltu	a2,a3,ffffffffc0200be8 <slub_check+0x270>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009aa:	2785                	addiw	a5,a5,1
ffffffffc02009ac:	03870713          	addi	a4,a4,56
ffffffffc02009b0:	feb79ae3          	bne	a5,a1,ffffffffc02009a4 <slub_check+0x2c>
ffffffffc02009b4:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc02009b8:	9526                	add	a0,a0,s1
ffffffffc02009ba:	e15ff0ef          	jal	ra,ffffffffc02007ce <__cache_alloc>
ffffffffc02009be:	00005497          	auipc	s1,0x5
ffffffffc02009c2:	65a48493          	addi	s1,s1,1626 # ffffffffc0206018 <kmalloc_caches>
ffffffffc02009c6:	892a                	mv	s2,a0
ffffffffc02009c8:	8726                	mv	a4,s1
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009ca:	4781                	li	a5,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009cc:	07f00613          	li	a2,127
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009d0:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009d2:	6714                	ld	a3,8(a4)
ffffffffc02009d4:	24d66c63          	bltu	a2,a3,ffffffffc0200c2c <slub_check+0x2b4>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009d8:	2785                	addiw	a5,a5,1
ffffffffc02009da:	03870713          	addi	a4,a4,56
ffffffffc02009de:	feb79ae3          	bne	a5,a1,ffffffffc02009d2 <slub_check+0x5a>
ffffffffc02009e2:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc02009e6:	9526                	add	a0,a0,s1
ffffffffc02009e8:	de7ff0ef          	jal	ra,ffffffffc02007ce <__cache_alloc>
ffffffffc02009ec:	00005497          	auipc	s1,0x5
ffffffffc02009f0:	62c48493          	addi	s1,s1,1580 # ffffffffc0206018 <kmalloc_caches>
ffffffffc02009f4:	89aa                	mv	s3,a0
ffffffffc02009f6:	8726                	mv	a4,s1
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009f8:	4781                	li	a5,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc02009fa:	3ff00613          	li	a2,1023
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc02009fe:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a00:	6714                	ld	a3,8(a4)
ffffffffc0200a02:	20d66e63          	bltu	a2,a3,ffffffffc0200c1e <slub_check+0x2a6>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a06:	2785                	addiw	a5,a5,1
ffffffffc0200a08:	03870713          	addi	a4,a4,56
ffffffffc0200a0c:	feb79ae3          	bne	a5,a1,ffffffffc0200a00 <slub_check+0x88>
ffffffffc0200a10:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200a14:	9526                	add	a0,a0,s1
ffffffffc0200a16:	db9ff0ef          	jal	ra,ffffffffc02007ce <__cache_alloc>
ffffffffc0200a1a:	00005497          	auipc	s1,0x5
ffffffffc0200a1e:	5fe48493          	addi	s1,s1,1534 # ffffffffc0206018 <kmalloc_caches>
ffffffffc0200a22:	8aaa                	mv	s5,a0
ffffffffc0200a24:	8726                	mv	a4,s1
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a26:	4781                	li	a5,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a28:	3ff00613          	li	a2,1023
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a2c:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a2e:	6714                	ld	a3,8(a4)
ffffffffc0200a30:	1ed66063          	bltu	a2,a3,ffffffffc0200c10 <slub_check+0x298>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a34:	2785                	addiw	a5,a5,1
ffffffffc0200a36:	03870713          	addi	a4,a4,56
ffffffffc0200a3a:	feb79ae3          	bne	a5,a1,ffffffffc0200a2e <slub_check+0xb6>
ffffffffc0200a3e:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200a42:	9526                	add	a0,a0,s1
ffffffffc0200a44:	d8bff0ef          	jal	ra,ffffffffc02007ce <__cache_alloc>
ffffffffc0200a48:	00005497          	auipc	s1,0x5
ffffffffc0200a4c:	5d048493          	addi	s1,s1,1488 # ffffffffc0206018 <kmalloc_caches>
ffffffffc0200a50:	8a2a                	mv	s4,a0
ffffffffc0200a52:	8826                	mv	a6,s1
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a54:	4781                	li	a5,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a56:	3ff00693          	li	a3,1023
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a5a:	4621                	li	a2,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a5c:	00883703          	ld	a4,8(a6)
ffffffffc0200a60:	1ae6e163          	bltu	a3,a4,ffffffffc0200c02 <slub_check+0x28a>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a64:	2785                	addiw	a5,a5,1
ffffffffc0200a66:	03880813          	addi	a6,a6,56
ffffffffc0200a6a:	fec799e3          	bne	a5,a2,ffffffffc0200a5c <slub_check+0xe4>
ffffffffc0200a6e:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200a72:	9526                	add	a0,a0,s1
ffffffffc0200a74:	d5bff0ef          	jal	ra,ffffffffc02007ce <__cache_alloc>
ffffffffc0200a78:	00005497          	auipc	s1,0x5
ffffffffc0200a7c:	5a048493          	addi	s1,s1,1440 # ffffffffc0206018 <kmalloc_caches>
ffffffffc0200a80:	8b2a                	mv	s6,a0
ffffffffc0200a82:	88a6                	mv	a7,s1
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a84:	4801                	li	a6,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a86:	3ff00713          	li	a4,1023
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a8a:	46a1                	li	a3,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200a8c:	0088b783          	ld	a5,8(a7)
ffffffffc0200a90:	16f76363          	bltu	a4,a5,ffffffffc0200bf6 <slub_check+0x27e>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200a94:	2805                	addiw	a6,a6,1
ffffffffc0200a96:	03888893          	addi	a7,a7,56
ffffffffc0200a9a:	fed819e3          	bne	a6,a3,ffffffffc0200a8c <slub_check+0x114>
ffffffffc0200a9e:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200aa2:	9526                	add	a0,a0,s1
ffffffffc0200aa4:	d2bff0ef          	jal	ra,ffffffffc02007ce <__cache_alloc>
ffffffffc0200aa8:	8baa                	mv	s7,a0
    void *p4 = kmalloc_bytes(1024);  // 映射到1024B等级
    void *p5 = kmalloc_bytes(1024);  // 映射到1024B等级
    void *p6 = kmalloc_bytes(1024);  // 映射到1024B等级

    // 验证分配成功（地址非空）
    cprintf("p1=%p, p2=%p, p3=%p,p4=%p, p5=%p, p6=%p\n",p1, p2, p3, p4, p5, p6);
ffffffffc0200aaa:	882a                	mv	a6,a0
ffffffffc0200aac:	87da                	mv	a5,s6
ffffffffc0200aae:	8752                	mv	a4,s4
ffffffffc0200ab0:	86d6                	mv	a3,s5
ffffffffc0200ab2:	864e                	mv	a2,s3
ffffffffc0200ab4:	85ca                	mv	a1,s2
ffffffffc0200ab6:	00001517          	auipc	a0,0x1
ffffffffc0200aba:	47a50513          	addi	a0,a0,1146 # ffffffffc0201f30 <etext+0x3e4>
ffffffffc0200abe:	e8eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200ac2:	18090a63          	beqz	s2,ffffffffc0200c56 <slub_check+0x2de>
ffffffffc0200ac6:	18098863          	beqz	s3,ffffffffc0200c56 <slub_check+0x2de>
ffffffffc0200aca:	180a8663          	beqz	s5,ffffffffc0200c56 <slub_check+0x2de>
ffffffffc0200ace:	180a0463          	beqz	s4,ffffffffc0200c56 <slub_check+0x2de>
ffffffffc0200ad2:	180b0263          	beqz	s6,ffffffffc0200c56 <slub_check+0x2de>
ffffffffc0200ad6:	180b8063          	beqz	s7,ffffffffc0200c56 <slub_check+0x2de>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200ada:	77fd                	lui	a5,0xfffff
ffffffffc0200adc:	00faf7b3          	and	a5,s5,a5
    __cache_free(sl->cache, ptr);
ffffffffc0200ae0:	6388                	ld	a0,0(a5)
ffffffffc0200ae2:	85d6                	mv	a1,s5
ffffffffc0200ae4:	dedff0ef          	jal	ra,ffffffffc02008d0 <__cache_free>
ffffffffc0200ae8:	00005617          	auipc	a2,0x5
ffffffffc0200aec:	53060613          	addi	a2,a2,1328 # ffffffffc0206018 <kmalloc_caches>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200af0:	4681                	li	a3,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200af2:	07f00713          	li	a4,127
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200af6:	45a1                	li	a1,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200af8:	661c                	ld	a5,8(a2)
ffffffffc0200afa:	14f76763          	bltu	a4,a5,ffffffffc0200c48 <slub_check+0x2d0>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200afe:	2685                	addiw	a3,a3,1
ffffffffc0200b00:	03860613          	addi	a2,a2,56
ffffffffc0200b04:	feb69ae3          	bne	a3,a1,ffffffffc0200af8 <slub_check+0x180>
ffffffffc0200b08:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200b0c:	9526                	add	a0,a0,s1
ffffffffc0200b0e:	cc1ff0ef          	jal	ra,ffffffffc02007ce <__cache_alloc>
ffffffffc0200b12:	8aaa                	mv	s5,a0
    kfree_bytes(p3);

    p3 = kmalloc_bytes(128);   // 映射到128B等级

    // 验证分配成功（地址非空）
    cprintf("p1=%p, p2=%p, p3=%p,p4=%p, p5=%p, p6=%p\n",p1, p2, p3, p4, p5, p6);
ffffffffc0200b14:	86aa                	mv	a3,a0
ffffffffc0200b16:	885e                	mv	a6,s7
ffffffffc0200b18:	87da                	mv	a5,s6
ffffffffc0200b1a:	8752                	mv	a4,s4
ffffffffc0200b1c:	864e                	mv	a2,s3
ffffffffc0200b1e:	85ca                	mv	a1,s2
ffffffffc0200b20:	00001517          	auipc	a0,0x1
ffffffffc0200b24:	41050513          	addi	a0,a0,1040 # ffffffffc0201f30 <etext+0x3e4>
ffffffffc0200b28:	e24ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200b2c:	140a8563          	beqz	s5,ffffffffc0200c76 <slub_check+0x2fe>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200b30:	77fd                	lui	a5,0xfffff
ffffffffc0200b32:	00faf7b3          	and	a5,s5,a5
    __cache_free(sl->cache, ptr);
ffffffffc0200b36:	6388                	ld	a0,0(a5)
ffffffffc0200b38:	85d6                	mv	a1,s5
ffffffffc0200b3a:	d97ff0ef          	jal	ra,ffffffffc02008d0 <__cache_free>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200b3e:	4681                	li	a3,0
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200b40:	3ff00713          	li	a4,1023
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200b44:	4621                	li	a2,8
        if (size <= kmalloc_caches[i].obj_size)
ffffffffc0200b46:	641c                	ld	a5,8(s0)
ffffffffc0200b48:	0ef76963          	bltu	a4,a5,ffffffffc0200c3a <slub_check+0x2c2>
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
ffffffffc0200b4c:	2685                	addiw	a3,a3,1
ffffffffc0200b4e:	03840413          	addi	s0,s0,56
ffffffffc0200b52:	fec69ae3          	bne	a3,a2,ffffffffc0200b46 <slub_check+0x1ce>
ffffffffc0200b56:	18800513          	li	a0,392
    return __cache_alloc(&kmalloc_caches[idx]);
ffffffffc0200b5a:	9526                	add	a0,a0,s1
ffffffffc0200b5c:	c73ff0ef          	jal	ra,ffffffffc02007ce <__cache_alloc>
ffffffffc0200b60:	84aa                	mv	s1,a0

    kfree_bytes(p3);

    p3 = kmalloc_bytes(1024);   // 映射到1024B等级

    cprintf("p1=%p, p2=%p, p3=%p,p4=%p, p5=%p, p6=%p\n", p1, p2, p3, p4, p5, p6);
ffffffffc0200b62:	86aa                	mv	a3,a0
ffffffffc0200b64:	885e                	mv	a6,s7
ffffffffc0200b66:	87da                	mv	a5,s6
ffffffffc0200b68:	8752                	mv	a4,s4
ffffffffc0200b6a:	864e                	mv	a2,s3
ffffffffc0200b6c:	85ca                	mv	a1,s2
ffffffffc0200b6e:	00001517          	auipc	a0,0x1
ffffffffc0200b72:	3c250513          	addi	a0,a0,962 # ffffffffc0201f30 <etext+0x3e4>
ffffffffc0200b76:	dd6ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200b7a:	10048e63          	beqz	s1,ffffffffc0200c96 <slub_check+0x31e>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200b7e:	747d                	lui	s0,0xfffff
ffffffffc0200b80:	008977b3          	and	a5,s2,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200b84:	6388                	ld	a0,0(a5)
ffffffffc0200b86:	85ca                	mv	a1,s2
ffffffffc0200b88:	d49ff0ef          	jal	ra,ffffffffc02008d0 <__cache_free>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200b8c:	0089f7b3          	and	a5,s3,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200b90:	6388                	ld	a0,0(a5)
ffffffffc0200b92:	85ce                	mv	a1,s3
ffffffffc0200b94:	d3dff0ef          	jal	ra,ffffffffc02008d0 <__cache_free>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200b98:	0084f7b3          	and	a5,s1,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200b9c:	6388                	ld	a0,0(a5)
ffffffffc0200b9e:	85a6                	mv	a1,s1
ffffffffc0200ba0:	d31ff0ef          	jal	ra,ffffffffc02008d0 <__cache_free>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200ba4:	008a77b3          	and	a5,s4,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200ba8:	6388                	ld	a0,0(a5)
ffffffffc0200baa:	85d2                	mv	a1,s4
ffffffffc0200bac:	d25ff0ef          	jal	ra,ffffffffc02008d0 <__cache_free>
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200bb0:	008b77b3          	and	a5,s6,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200bb4:	6388                	ld	a0,0(a5)
ffffffffc0200bb6:	85da                	mv	a1,s6
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
ffffffffc0200bb8:	008bf433          	and	s0,s7,s0
    __cache_free(sl->cache, ptr);
ffffffffc0200bbc:	d15ff0ef          	jal	ra,ffffffffc02008d0 <__cache_free>
ffffffffc0200bc0:	6008                	ld	a0,0(s0)
ffffffffc0200bc2:	85de                	mv	a1,s7
ffffffffc0200bc4:	d0dff0ef          	jal	ra,ffffffffc02008d0 <__cache_free>
    kfree_bytes(p4);
    kfree_bytes(p5);
    kfree_bytes(p6);

    cprintf("SLUB-only test done.\n");
}
ffffffffc0200bc8:	6406                	ld	s0,64(sp)
ffffffffc0200bca:	60a6                	ld	ra,72(sp)
ffffffffc0200bcc:	74e2                	ld	s1,56(sp)
ffffffffc0200bce:	7942                	ld	s2,48(sp)
ffffffffc0200bd0:	79a2                	ld	s3,40(sp)
ffffffffc0200bd2:	7a02                	ld	s4,32(sp)
ffffffffc0200bd4:	6ae2                	ld	s5,24(sp)
ffffffffc0200bd6:	6b42                	ld	s6,16(sp)
ffffffffc0200bd8:	6ba2                	ld	s7,8(sp)
    cprintf("SLUB-only test done.\n");
ffffffffc0200bda:	00001517          	auipc	a0,0x1
ffffffffc0200bde:	3f650513          	addi	a0,a0,1014 # ffffffffc0201fd0 <etext+0x484>
}
ffffffffc0200be2:	6161                	addi	sp,sp,80
    cprintf("SLUB-only test done.\n");
ffffffffc0200be4:	d68ff06f          	j	ffffffffc020014c <cprintf>
ffffffffc0200be8:	00379513          	slli	a0,a5,0x3
ffffffffc0200bec:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bf0:	00379513          	slli	a0,a5,0x3
ffffffffc0200bf4:	b3d1                	j	ffffffffc02009b8 <slub_check+0x40>
ffffffffc0200bf6:	00381513          	slli	a0,a6,0x3
ffffffffc0200bfa:	41050533          	sub	a0,a0,a6
ffffffffc0200bfe:	050e                	slli	a0,a0,0x3
ffffffffc0200c00:	b54d                	j	ffffffffc0200aa2 <slub_check+0x12a>
ffffffffc0200c02:	00379513          	slli	a0,a5,0x3
ffffffffc0200c06:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c0a:	00379513          	slli	a0,a5,0x3
ffffffffc0200c0e:	b595                	j	ffffffffc0200a72 <slub_check+0xfa>
ffffffffc0200c10:	00379513          	slli	a0,a5,0x3
ffffffffc0200c14:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c18:	00379513          	slli	a0,a5,0x3
ffffffffc0200c1c:	b51d                	j	ffffffffc0200a42 <slub_check+0xca>
ffffffffc0200c1e:	00379513          	slli	a0,a5,0x3
ffffffffc0200c22:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c26:	00379513          	slli	a0,a5,0x3
ffffffffc0200c2a:	b3ed                	j	ffffffffc0200a14 <slub_check+0x9c>
ffffffffc0200c2c:	00379513          	slli	a0,a5,0x3
ffffffffc0200c30:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c34:	00379513          	slli	a0,a5,0x3
ffffffffc0200c38:	b37d                	j	ffffffffc02009e6 <slub_check+0x6e>
ffffffffc0200c3a:	00369513          	slli	a0,a3,0x3
ffffffffc0200c3e:	40d506b3          	sub	a3,a0,a3
ffffffffc0200c42:	00369513          	slli	a0,a3,0x3
ffffffffc0200c46:	bf11                	j	ffffffffc0200b5a <slub_check+0x1e2>
ffffffffc0200c48:	00369513          	slli	a0,a3,0x3
ffffffffc0200c4c:	40d506b3          	sub	a3,a0,a3
ffffffffc0200c50:	00369513          	slli	a0,a3,0x3
ffffffffc0200c54:	bd65                	j	ffffffffc0200b0c <slub_check+0x194>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200c56:	00001697          	auipc	a3,0x1
ffffffffc0200c5a:	30a68693          	addi	a3,a3,778 # ffffffffc0201f60 <etext+0x414>
ffffffffc0200c5e:	00001617          	auipc	a2,0x1
ffffffffc0200c62:	35a60613          	addi	a2,a2,858 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc0200c66:	0ba00593          	li	a1,186
ffffffffc0200c6a:	00001517          	auipc	a0,0x1
ffffffffc0200c6e:	2b650513          	addi	a0,a0,694 # ffffffffc0201f20 <etext+0x3d4>
ffffffffc0200c72:	d50ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200c76:	00001697          	auipc	a3,0x1
ffffffffc0200c7a:	2ea68693          	addi	a3,a3,746 # ffffffffc0201f60 <etext+0x414>
ffffffffc0200c7e:	00001617          	auipc	a2,0x1
ffffffffc0200c82:	33a60613          	addi	a2,a2,826 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc0200c86:	0c300593          	li	a1,195
ffffffffc0200c8a:	00001517          	auipc	a0,0x1
ffffffffc0200c8e:	29650513          	addi	a0,a0,662 # ffffffffc0201f20 <etext+0x3d4>
ffffffffc0200c92:	d30ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p1 != NULL && p2 != NULL && p3 != NULL && p4 != NULL && p5 != NULL && p6 != NULL);
ffffffffc0200c96:	00001697          	auipc	a3,0x1
ffffffffc0200c9a:	2ca68693          	addi	a3,a3,714 # ffffffffc0201f60 <etext+0x414>
ffffffffc0200c9e:	00001617          	auipc	a2,0x1
ffffffffc0200ca2:	31a60613          	addi	a2,a2,794 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc0200ca6:	0ca00593          	li	a1,202
ffffffffc0200caa:	00001517          	auipc	a0,0x1
ffffffffc0200cae:	27650513          	addi	a0,a0,630 # ffffffffc0201f20 <etext+0x3d4>
ffffffffc0200cb2:	d10ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200cb6 <best_fit_init>:
ffffffffc0200cb6:	00005797          	auipc	a5,0x5
ffffffffc0200cba:	52278793          	addi	a5,a5,1314 # ffffffffc02061d8 <free_area>
ffffffffc0200cbe:	e79c                	sd	a5,8(a5)
ffffffffc0200cc0:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200cc2:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200cc6:	8082                	ret

ffffffffc0200cc8 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200cc8:	00005517          	auipc	a0,0x5
ffffffffc0200ccc:	52056503          	lwu	a0,1312(a0) # ffffffffc02061e8 <free_area+0x10>
ffffffffc0200cd0:	8082                	ret

ffffffffc0200cd2 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200cd2:	cd49                	beqz	a0,ffffffffc0200d6c <best_fit_alloc_pages+0x9a>
    if (n > nr_free) {
ffffffffc0200cd4:	00005617          	auipc	a2,0x5
ffffffffc0200cd8:	50460613          	addi	a2,a2,1284 # ffffffffc02061d8 <free_area>
ffffffffc0200cdc:	01062803          	lw	a6,16(a2)
ffffffffc0200ce0:	86aa                	mv	a3,a0
ffffffffc0200ce2:	02081793          	slli	a5,a6,0x20
ffffffffc0200ce6:	9381                	srli	a5,a5,0x20
ffffffffc0200ce8:	08a7e063          	bltu	a5,a0,ffffffffc0200d68 <best_fit_alloc_pages+0x96>
    return listelm->next;
ffffffffc0200cec:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc0200cee:	0018059b          	addiw	a1,a6,1
ffffffffc0200cf2:	1582                	slli	a1,a1,0x20
ffffffffc0200cf4:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0200cf6:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200cf8:	06c78763          	beq	a5,a2,ffffffffc0200d66 <best_fit_alloc_pages+0x94>
        if (p->property >= n) {
ffffffffc0200cfc:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200d00:	00d76763          	bltu	a4,a3,ffffffffc0200d0e <best_fit_alloc_pages+0x3c>
            if(p->property < min_size){
ffffffffc0200d04:	00b77563          	bgeu	a4,a1,ffffffffc0200d0e <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200d08:	fe878513          	addi	a0,a5,-24
ffffffffc0200d0c:	85ba                	mv	a1,a4
ffffffffc0200d0e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d10:	fec796e3          	bne	a5,a2,ffffffffc0200cfc <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200d14:	c929                	beqz	a0,ffffffffc0200d66 <best_fit_alloc_pages+0x94>
        if (page->property > n) {
ffffffffc0200d16:	01052883          	lw	a7,16(a0)
    return listelm->prev;
ffffffffc0200d1a:	6d18                	ld	a4,24(a0)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d1c:	710c                	ld	a1,32(a0)
ffffffffc0200d1e:	02089793          	slli	a5,a7,0x20
ffffffffc0200d22:	9381                	srli	a5,a5,0x20
    prev->next = next;
ffffffffc0200d24:	e70c                	sd	a1,8(a4)
    next->prev = prev;
ffffffffc0200d26:	e198                	sd	a4,0(a1)
            p->property = page->property - n;
ffffffffc0200d28:	0006831b          	sext.w	t1,a3
        if (page->property > n) {
ffffffffc0200d2c:	02f6f563          	bgeu	a3,a5,ffffffffc0200d56 <best_fit_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc0200d30:	00269793          	slli	a5,a3,0x2
ffffffffc0200d34:	97b6                	add	a5,a5,a3
ffffffffc0200d36:	078e                	slli	a5,a5,0x3
ffffffffc0200d38:	97aa                	add	a5,a5,a0
            SetPageProperty(p);
ffffffffc0200d3a:	6794                	ld	a3,8(a5)
            p->property = page->property - n;
ffffffffc0200d3c:	406888bb          	subw	a7,a7,t1
ffffffffc0200d40:	0117a823          	sw	a7,16(a5)
            SetPageProperty(p);
ffffffffc0200d44:	0026e693          	ori	a3,a3,2
ffffffffc0200d48:	e794                	sd	a3,8(a5)
            list_add(prev, &(p->page_link));
ffffffffc0200d4a:	01878693          	addi	a3,a5,24
    prev->next = next->prev = elm;
ffffffffc0200d4e:	e194                	sd	a3,0(a1)
ffffffffc0200d50:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc0200d52:	f38c                	sd	a1,32(a5)
    elm->prev = prev;
ffffffffc0200d54:	ef98                	sd	a4,24(a5)
        ClearPageProperty(page);
ffffffffc0200d56:	651c                	ld	a5,8(a0)
        nr_free -= n;
ffffffffc0200d58:	4068083b          	subw	a6,a6,t1
ffffffffc0200d5c:	01062823          	sw	a6,16(a2)
        ClearPageProperty(page);
ffffffffc0200d60:	9bf5                	andi	a5,a5,-3
ffffffffc0200d62:	e51c                	sd	a5,8(a0)
ffffffffc0200d64:	8082                	ret
}
ffffffffc0200d66:	8082                	ret
        return NULL;
ffffffffc0200d68:	4501                	li	a0,0
ffffffffc0200d6a:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200d6c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200d6e:	00001697          	auipc	a3,0x1
ffffffffc0200d72:	2ba68693          	addi	a3,a3,698 # ffffffffc0202028 <kmalloc_sizes+0x40>
ffffffffc0200d76:	00001617          	auipc	a2,0x1
ffffffffc0200d7a:	24260613          	addi	a2,a2,578 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc0200d7e:	06300593          	li	a1,99
ffffffffc0200d82:	00001517          	auipc	a0,0x1
ffffffffc0200d86:	2ae50513          	addi	a0,a0,686 # ffffffffc0202030 <kmalloc_sizes+0x48>
best_fit_alloc_pages(size_t n) {
ffffffffc0200d8a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200d8c:	c36ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200d90 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200d90:	715d                	addi	sp,sp,-80
ffffffffc0200d92:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0200d94:	00005417          	auipc	s0,0x5
ffffffffc0200d98:	44440413          	addi	s0,s0,1092 # ffffffffc02061d8 <free_area>
ffffffffc0200d9c:	641c                	ld	a5,8(s0)
ffffffffc0200d9e:	e486                	sd	ra,72(sp)
ffffffffc0200da0:	fc26                	sd	s1,56(sp)
ffffffffc0200da2:	f84a                	sd	s2,48(sp)
ffffffffc0200da4:	f44e                	sd	s3,40(sp)
ffffffffc0200da6:	f052                	sd	s4,32(sp)
ffffffffc0200da8:	ec56                	sd	s5,24(sp)
ffffffffc0200daa:	e85a                	sd	s6,16(sp)
ffffffffc0200dac:	e45e                	sd	s7,8(sp)
ffffffffc0200dae:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200db0:	26878963          	beq	a5,s0,ffffffffc0201022 <best_fit_check+0x292>
    int count = 0, total = 0;
ffffffffc0200db4:	4481                	li	s1,0
ffffffffc0200db6:	4901                	li	s2,0
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200db8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200dbc:	8b09                	andi	a4,a4,2
ffffffffc0200dbe:	26070663          	beqz	a4,ffffffffc020102a <best_fit_check+0x29a>
        count ++, total += p->property;
ffffffffc0200dc2:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200dc6:	679c                	ld	a5,8(a5)
ffffffffc0200dc8:	2905                	addiw	s2,s2,1
ffffffffc0200dca:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dcc:	fe8796e3          	bne	a5,s0,ffffffffc0200db8 <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200dd0:	89a6                	mv	s3,s1
ffffffffc0200dd2:	817ff0ef          	jal	ra,ffffffffc02005e8 <nr_free_pages>
ffffffffc0200dd6:	33351a63          	bne	a0,s3,ffffffffc020110a <best_fit_check+0x37a>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200dda:	4505                	li	a0,1
ffffffffc0200ddc:	ff4ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200de0:	8a2a                	mv	s4,a0
ffffffffc0200de2:	36050463          	beqz	a0,ffffffffc020114a <best_fit_check+0x3ba>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200de6:	4505                	li	a0,1
ffffffffc0200de8:	fe8ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200dec:	89aa                	mv	s3,a0
ffffffffc0200dee:	32050e63          	beqz	a0,ffffffffc020112a <best_fit_check+0x39a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200df2:	4505                	li	a0,1
ffffffffc0200df4:	fdcff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200df8:	8aaa                	mv	s5,a0
ffffffffc0200dfa:	2c050863          	beqz	a0,ffffffffc02010ca <best_fit_check+0x33a>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200dfe:	253a0663          	beq	s4,s3,ffffffffc020104a <best_fit_check+0x2ba>
ffffffffc0200e02:	24aa0463          	beq	s4,a0,ffffffffc020104a <best_fit_check+0x2ba>
ffffffffc0200e06:	24a98263          	beq	s3,a0,ffffffffc020104a <best_fit_check+0x2ba>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e0a:	000a2783          	lw	a5,0(s4)
ffffffffc0200e0e:	24079e63          	bnez	a5,ffffffffc020106a <best_fit_check+0x2da>
ffffffffc0200e12:	0009a783          	lw	a5,0(s3)
ffffffffc0200e16:	24079a63          	bnez	a5,ffffffffc020106a <best_fit_check+0x2da>
ffffffffc0200e1a:	411c                	lw	a5,0(a0)
ffffffffc0200e1c:	24079763          	bnez	a5,ffffffffc020106a <best_fit_check+0x2da>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e20:	00005797          	auipc	a5,0x5
ffffffffc0200e24:	3f07b783          	ld	a5,1008(a5) # ffffffffc0206210 <pages>
ffffffffc0200e28:	40fa0733          	sub	a4,s4,a5
ffffffffc0200e2c:	870d                	srai	a4,a4,0x3
ffffffffc0200e2e:	00001597          	auipc	a1,0x1
ffffffffc0200e32:	7b25b583          	ld	a1,1970(a1) # ffffffffc02025e0 <nbase+0x8>
ffffffffc0200e36:	02b70733          	mul	a4,a4,a1
ffffffffc0200e3a:	00001617          	auipc	a2,0x1
ffffffffc0200e3e:	79e63603          	ld	a2,1950(a2) # ffffffffc02025d8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e42:	00005697          	auipc	a3,0x5
ffffffffc0200e46:	3c66b683          	ld	a3,966(a3) # ffffffffc0206208 <npage>
ffffffffc0200e4a:	06b2                	slli	a3,a3,0xc
ffffffffc0200e4c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e4e:	0732                	slli	a4,a4,0xc
ffffffffc0200e50:	22d77d63          	bgeu	a4,a3,ffffffffc020108a <best_fit_check+0x2fa>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e54:	40f98733          	sub	a4,s3,a5
ffffffffc0200e58:	870d                	srai	a4,a4,0x3
ffffffffc0200e5a:	02b70733          	mul	a4,a4,a1
ffffffffc0200e5e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e60:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e62:	3ed77463          	bgeu	a4,a3,ffffffffc020124a <best_fit_check+0x4ba>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e66:	40f507b3          	sub	a5,a0,a5
ffffffffc0200e6a:	878d                	srai	a5,a5,0x3
ffffffffc0200e6c:	02b787b3          	mul	a5,a5,a1
ffffffffc0200e70:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e72:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e74:	3ad7fb63          	bgeu	a5,a3,ffffffffc020122a <best_fit_check+0x49a>
    assert(alloc_page() == NULL);
ffffffffc0200e78:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200e7a:	00043c03          	ld	s8,0(s0)
ffffffffc0200e7e:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200e82:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200e86:	e400                	sd	s0,8(s0)
ffffffffc0200e88:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200e8a:	00005797          	auipc	a5,0x5
ffffffffc0200e8e:	3407af23          	sw	zero,862(a5) # ffffffffc02061e8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200e92:	f3eff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200e96:	36051a63          	bnez	a0,ffffffffc020120a <best_fit_check+0x47a>
    free_page(p0);
ffffffffc0200e9a:	4585                	li	a1,1
ffffffffc0200e9c:	8552                	mv	a0,s4
ffffffffc0200e9e:	f3eff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p1);
ffffffffc0200ea2:	4585                	li	a1,1
ffffffffc0200ea4:	854e                	mv	a0,s3
ffffffffc0200ea6:	f36ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p2);
ffffffffc0200eaa:	4585                	li	a1,1
ffffffffc0200eac:	8556                	mv	a0,s5
ffffffffc0200eae:	f2eff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert(nr_free == 3);
ffffffffc0200eb2:	4818                	lw	a4,16(s0)
ffffffffc0200eb4:	478d                	li	a5,3
ffffffffc0200eb6:	32f71a63          	bne	a4,a5,ffffffffc02011ea <best_fit_check+0x45a>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200eba:	4505                	li	a0,1
ffffffffc0200ebc:	f14ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ec0:	89aa                	mv	s3,a0
ffffffffc0200ec2:	30050463          	beqz	a0,ffffffffc02011ca <best_fit_check+0x43a>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ec6:	4505                	li	a0,1
ffffffffc0200ec8:	f08ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ecc:	8aaa                	mv	s5,a0
ffffffffc0200ece:	2c050e63          	beqz	a0,ffffffffc02011aa <best_fit_check+0x41a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ed2:	4505                	li	a0,1
ffffffffc0200ed4:	efcff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ed8:	8a2a                	mv	s4,a0
ffffffffc0200eda:	2a050863          	beqz	a0,ffffffffc020118a <best_fit_check+0x3fa>
    assert(alloc_page() == NULL);
ffffffffc0200ede:	4505                	li	a0,1
ffffffffc0200ee0:	ef0ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ee4:	28051363          	bnez	a0,ffffffffc020116a <best_fit_check+0x3da>
    free_page(p0);
ffffffffc0200ee8:	4585                	li	a1,1
ffffffffc0200eea:	854e                	mv	a0,s3
ffffffffc0200eec:	ef0ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200ef0:	641c                	ld	a5,8(s0)
ffffffffc0200ef2:	1a878c63          	beq	a5,s0,ffffffffc02010aa <best_fit_check+0x31a>
    assert((p = alloc_page()) == p0);
ffffffffc0200ef6:	4505                	li	a0,1
ffffffffc0200ef8:	ed8ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200efc:	52a99763          	bne	s3,a0,ffffffffc020142a <best_fit_check+0x69a>
    assert(alloc_page() == NULL);
ffffffffc0200f00:	4505                	li	a0,1
ffffffffc0200f02:	eceff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200f06:	50051263          	bnez	a0,ffffffffc020140a <best_fit_check+0x67a>
    assert(nr_free == 0);
ffffffffc0200f0a:	481c                	lw	a5,16(s0)
ffffffffc0200f0c:	4c079f63          	bnez	a5,ffffffffc02013ea <best_fit_check+0x65a>
    free_page(p);
ffffffffc0200f10:	854e                	mv	a0,s3
ffffffffc0200f12:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200f14:	01843023          	sd	s8,0(s0)
ffffffffc0200f18:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200f1c:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200f20:	ebcff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p1);
ffffffffc0200f24:	4585                	li	a1,1
ffffffffc0200f26:	8556                	mv	a0,s5
ffffffffc0200f28:	eb4ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p2);
ffffffffc0200f2c:	4585                	li	a1,1
ffffffffc0200f2e:	8552                	mv	a0,s4
ffffffffc0200f30:	eacff0ef          	jal	ra,ffffffffc02005dc <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200f34:	4515                	li	a0,5
ffffffffc0200f36:	e9aff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200f3a:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200f3c:	48050763          	beqz	a0,ffffffffc02013ca <best_fit_check+0x63a>
    assert(!PageProperty(p0));
ffffffffc0200f40:	651c                	ld	a5,8(a0)
ffffffffc0200f42:	8b89                	andi	a5,a5,2
ffffffffc0200f44:	46079363          	bnez	a5,ffffffffc02013aa <best_fit_check+0x61a>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200f48:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f4a:	00043b03          	ld	s6,0(s0)
ffffffffc0200f4e:	00843a83          	ld	s5,8(s0)
ffffffffc0200f52:	e000                	sd	s0,0(s0)
ffffffffc0200f54:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200f56:	e7aff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200f5a:	42051863          	bnez	a0,ffffffffc020138a <best_fit_check+0x5fa>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200f5e:	4589                	li	a1,2
ffffffffc0200f60:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200f64:	01042b83          	lw	s7,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200f68:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200f6c:	00005797          	auipc	a5,0x5
ffffffffc0200f70:	2607ae23          	sw	zero,636(a5) # ffffffffc02061e8 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200f74:	e68ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200f78:	8562                	mv	a0,s8
ffffffffc0200f7a:	4585                	li	a1,1
ffffffffc0200f7c:	e60ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f80:	4511                	li	a0,4
ffffffffc0200f82:	e4eff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200f86:	3e051263          	bnez	a0,ffffffffc020136a <best_fit_check+0x5da>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200f8a:	0309b783          	ld	a5,48(s3)
ffffffffc0200f8e:	8b89                	andi	a5,a5,2
ffffffffc0200f90:	3a078d63          	beqz	a5,ffffffffc020134a <best_fit_check+0x5ba>
ffffffffc0200f94:	0389a703          	lw	a4,56(s3)
ffffffffc0200f98:	4789                	li	a5,2
ffffffffc0200f9a:	3af71863          	bne	a4,a5,ffffffffc020134a <best_fit_check+0x5ba>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200f9e:	4505                	li	a0,1
ffffffffc0200fa0:	e30ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200fa4:	8a2a                	mv	s4,a0
ffffffffc0200fa6:	38050263          	beqz	a0,ffffffffc020132a <best_fit_check+0x59a>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200faa:	4509                	li	a0,2
ffffffffc0200fac:	e24ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200fb0:	34050d63          	beqz	a0,ffffffffc020130a <best_fit_check+0x57a>
    assert(p0 + 4 == p1);
ffffffffc0200fb4:	334c1b63          	bne	s8,s4,ffffffffc02012ea <best_fit_check+0x55a>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200fb8:	854e                	mv	a0,s3
ffffffffc0200fba:	4595                	li	a1,5
ffffffffc0200fbc:	e20ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200fc0:	4515                	li	a0,5
ffffffffc0200fc2:	e0eff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200fc6:	89aa                	mv	s3,a0
ffffffffc0200fc8:	30050163          	beqz	a0,ffffffffc02012ca <best_fit_check+0x53a>
    assert(alloc_page() == NULL);
ffffffffc0200fcc:	4505                	li	a0,1
ffffffffc0200fce:	e02ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200fd2:	2c051c63          	bnez	a0,ffffffffc02012aa <best_fit_check+0x51a>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200fd6:	481c                	lw	a5,16(s0)
ffffffffc0200fd8:	2a079963          	bnez	a5,ffffffffc020128a <best_fit_check+0x4fa>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200fdc:	4595                	li	a1,5
ffffffffc0200fde:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200fe0:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200fe4:	01643023          	sd	s6,0(s0)
ffffffffc0200fe8:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200fec:	df0ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    return listelm->next;
ffffffffc0200ff0:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ff2:	00878963          	beq	a5,s0,ffffffffc0201004 <best_fit_check+0x274>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200ff6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ffa:	679c                	ld	a5,8(a5)
ffffffffc0200ffc:	397d                	addiw	s2,s2,-1
ffffffffc0200ffe:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201000:	fe879be3          	bne	a5,s0,ffffffffc0200ff6 <best_fit_check+0x266>
    }
    assert(count == 0);
ffffffffc0201004:	26091363          	bnez	s2,ffffffffc020126a <best_fit_check+0x4da>
    assert(total == 0);
ffffffffc0201008:	e0ed                	bnez	s1,ffffffffc02010ea <best_fit_check+0x35a>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc020100a:	60a6                	ld	ra,72(sp)
ffffffffc020100c:	6406                	ld	s0,64(sp)
ffffffffc020100e:	74e2                	ld	s1,56(sp)
ffffffffc0201010:	7942                	ld	s2,48(sp)
ffffffffc0201012:	79a2                	ld	s3,40(sp)
ffffffffc0201014:	7a02                	ld	s4,32(sp)
ffffffffc0201016:	6ae2                	ld	s5,24(sp)
ffffffffc0201018:	6b42                	ld	s6,16(sp)
ffffffffc020101a:	6ba2                	ld	s7,8(sp)
ffffffffc020101c:	6c02                	ld	s8,0(sp)
ffffffffc020101e:	6161                	addi	sp,sp,80
ffffffffc0201020:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201022:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201024:	4481                	li	s1,0
ffffffffc0201026:	4901                	li	s2,0
ffffffffc0201028:	b36d                	j	ffffffffc0200dd2 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc020102a:	00001697          	auipc	a3,0x1
ffffffffc020102e:	01e68693          	addi	a3,a3,30 # ffffffffc0202048 <kmalloc_sizes+0x60>
ffffffffc0201032:	00001617          	auipc	a2,0x1
ffffffffc0201036:	f8660613          	addi	a2,a2,-122 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020103a:	10700593          	li	a1,263
ffffffffc020103e:	00001517          	auipc	a0,0x1
ffffffffc0201042:	ff250513          	addi	a0,a0,-14 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201046:	97cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020104a:	00001697          	auipc	a3,0x1
ffffffffc020104e:	08e68693          	addi	a3,a3,142 # ffffffffc02020d8 <kmalloc_sizes+0xf0>
ffffffffc0201052:	00001617          	auipc	a2,0x1
ffffffffc0201056:	f6660613          	addi	a2,a2,-154 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020105a:	0d300593          	li	a1,211
ffffffffc020105e:	00001517          	auipc	a0,0x1
ffffffffc0201062:	fd250513          	addi	a0,a0,-46 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201066:	95cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020106a:	00001697          	auipc	a3,0x1
ffffffffc020106e:	09668693          	addi	a3,a3,150 # ffffffffc0202100 <kmalloc_sizes+0x118>
ffffffffc0201072:	00001617          	auipc	a2,0x1
ffffffffc0201076:	f4660613          	addi	a2,a2,-186 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020107a:	0d400593          	li	a1,212
ffffffffc020107e:	00001517          	auipc	a0,0x1
ffffffffc0201082:	fb250513          	addi	a0,a0,-78 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201086:	93cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020108a:	00001697          	auipc	a3,0x1
ffffffffc020108e:	0b668693          	addi	a3,a3,182 # ffffffffc0202140 <kmalloc_sizes+0x158>
ffffffffc0201092:	00001617          	auipc	a2,0x1
ffffffffc0201096:	f2660613          	addi	a2,a2,-218 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020109a:	0d600593          	li	a1,214
ffffffffc020109e:	00001517          	auipc	a0,0x1
ffffffffc02010a2:	f9250513          	addi	a0,a0,-110 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02010a6:	91cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02010aa:	00001697          	auipc	a3,0x1
ffffffffc02010ae:	11e68693          	addi	a3,a3,286 # ffffffffc02021c8 <kmalloc_sizes+0x1e0>
ffffffffc02010b2:	00001617          	auipc	a2,0x1
ffffffffc02010b6:	f0660613          	addi	a2,a2,-250 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02010ba:	0ef00593          	li	a1,239
ffffffffc02010be:	00001517          	auipc	a0,0x1
ffffffffc02010c2:	f7250513          	addi	a0,a0,-142 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02010c6:	8fcff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010ca:	00001697          	auipc	a3,0x1
ffffffffc02010ce:	fee68693          	addi	a3,a3,-18 # ffffffffc02020b8 <kmalloc_sizes+0xd0>
ffffffffc02010d2:	00001617          	auipc	a2,0x1
ffffffffc02010d6:	ee660613          	addi	a2,a2,-282 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02010da:	0d100593          	li	a1,209
ffffffffc02010de:	00001517          	auipc	a0,0x1
ffffffffc02010e2:	f5250513          	addi	a0,a0,-174 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02010e6:	8dcff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(total == 0);
ffffffffc02010ea:	00001697          	auipc	a3,0x1
ffffffffc02010ee:	20e68693          	addi	a3,a3,526 # ffffffffc02022f8 <kmalloc_sizes+0x310>
ffffffffc02010f2:	00001617          	auipc	a2,0x1
ffffffffc02010f6:	ec660613          	addi	a2,a2,-314 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02010fa:	14900593          	li	a1,329
ffffffffc02010fe:	00001517          	auipc	a0,0x1
ffffffffc0201102:	f3250513          	addi	a0,a0,-206 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201106:	8bcff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(total == nr_free_pages());
ffffffffc020110a:	00001697          	auipc	a3,0x1
ffffffffc020110e:	f4e68693          	addi	a3,a3,-178 # ffffffffc0202058 <kmalloc_sizes+0x70>
ffffffffc0201112:	00001617          	auipc	a2,0x1
ffffffffc0201116:	ea660613          	addi	a2,a2,-346 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020111a:	10a00593          	li	a1,266
ffffffffc020111e:	00001517          	auipc	a0,0x1
ffffffffc0201122:	f1250513          	addi	a0,a0,-238 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201126:	89cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020112a:	00001697          	auipc	a3,0x1
ffffffffc020112e:	f6e68693          	addi	a3,a3,-146 # ffffffffc0202098 <kmalloc_sizes+0xb0>
ffffffffc0201132:	00001617          	auipc	a2,0x1
ffffffffc0201136:	e8660613          	addi	a2,a2,-378 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020113a:	0d000593          	li	a1,208
ffffffffc020113e:	00001517          	auipc	a0,0x1
ffffffffc0201142:	ef250513          	addi	a0,a0,-270 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201146:	87cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020114a:	00001697          	auipc	a3,0x1
ffffffffc020114e:	f2e68693          	addi	a3,a3,-210 # ffffffffc0202078 <kmalloc_sizes+0x90>
ffffffffc0201152:	00001617          	auipc	a2,0x1
ffffffffc0201156:	e6660613          	addi	a2,a2,-410 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020115a:	0cf00593          	li	a1,207
ffffffffc020115e:	00001517          	auipc	a0,0x1
ffffffffc0201162:	ed250513          	addi	a0,a0,-302 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201166:	85cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020116a:	00001697          	auipc	a3,0x1
ffffffffc020116e:	03668693          	addi	a3,a3,54 # ffffffffc02021a0 <kmalloc_sizes+0x1b8>
ffffffffc0201172:	00001617          	auipc	a2,0x1
ffffffffc0201176:	e4660613          	addi	a2,a2,-442 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020117a:	0ec00593          	li	a1,236
ffffffffc020117e:	00001517          	auipc	a0,0x1
ffffffffc0201182:	eb250513          	addi	a0,a0,-334 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201186:	83cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020118a:	00001697          	auipc	a3,0x1
ffffffffc020118e:	f2e68693          	addi	a3,a3,-210 # ffffffffc02020b8 <kmalloc_sizes+0xd0>
ffffffffc0201192:	00001617          	auipc	a2,0x1
ffffffffc0201196:	e2660613          	addi	a2,a2,-474 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020119a:	0ea00593          	li	a1,234
ffffffffc020119e:	00001517          	auipc	a0,0x1
ffffffffc02011a2:	e9250513          	addi	a0,a0,-366 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02011a6:	81cff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02011aa:	00001697          	auipc	a3,0x1
ffffffffc02011ae:	eee68693          	addi	a3,a3,-274 # ffffffffc0202098 <kmalloc_sizes+0xb0>
ffffffffc02011b2:	00001617          	auipc	a2,0x1
ffffffffc02011b6:	e0660613          	addi	a2,a2,-506 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02011ba:	0e900593          	li	a1,233
ffffffffc02011be:	00001517          	auipc	a0,0x1
ffffffffc02011c2:	e7250513          	addi	a0,a0,-398 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02011c6:	ffdfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011ca:	00001697          	auipc	a3,0x1
ffffffffc02011ce:	eae68693          	addi	a3,a3,-338 # ffffffffc0202078 <kmalloc_sizes+0x90>
ffffffffc02011d2:	00001617          	auipc	a2,0x1
ffffffffc02011d6:	de660613          	addi	a2,a2,-538 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02011da:	0e800593          	li	a1,232
ffffffffc02011de:	00001517          	auipc	a0,0x1
ffffffffc02011e2:	e5250513          	addi	a0,a0,-430 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02011e6:	fddfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free == 3);
ffffffffc02011ea:	00001697          	auipc	a3,0x1
ffffffffc02011ee:	fce68693          	addi	a3,a3,-50 # ffffffffc02021b8 <kmalloc_sizes+0x1d0>
ffffffffc02011f2:	00001617          	auipc	a2,0x1
ffffffffc02011f6:	dc660613          	addi	a2,a2,-570 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02011fa:	0e600593          	li	a1,230
ffffffffc02011fe:	00001517          	auipc	a0,0x1
ffffffffc0201202:	e3250513          	addi	a0,a0,-462 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201206:	fbdfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020120a:	00001697          	auipc	a3,0x1
ffffffffc020120e:	f9668693          	addi	a3,a3,-106 # ffffffffc02021a0 <kmalloc_sizes+0x1b8>
ffffffffc0201212:	00001617          	auipc	a2,0x1
ffffffffc0201216:	da660613          	addi	a2,a2,-602 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020121a:	0e100593          	li	a1,225
ffffffffc020121e:	00001517          	auipc	a0,0x1
ffffffffc0201222:	e1250513          	addi	a0,a0,-494 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201226:	f9dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020122a:	00001697          	auipc	a3,0x1
ffffffffc020122e:	f5668693          	addi	a3,a3,-170 # ffffffffc0202180 <kmalloc_sizes+0x198>
ffffffffc0201232:	00001617          	auipc	a2,0x1
ffffffffc0201236:	d8660613          	addi	a2,a2,-634 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020123a:	0d800593          	li	a1,216
ffffffffc020123e:	00001517          	auipc	a0,0x1
ffffffffc0201242:	df250513          	addi	a0,a0,-526 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201246:	f7dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020124a:	00001697          	auipc	a3,0x1
ffffffffc020124e:	f1668693          	addi	a3,a3,-234 # ffffffffc0202160 <kmalloc_sizes+0x178>
ffffffffc0201252:	00001617          	auipc	a2,0x1
ffffffffc0201256:	d6660613          	addi	a2,a2,-666 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020125a:	0d700593          	li	a1,215
ffffffffc020125e:	00001517          	auipc	a0,0x1
ffffffffc0201262:	dd250513          	addi	a0,a0,-558 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201266:	f5dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(count == 0);
ffffffffc020126a:	00001697          	auipc	a3,0x1
ffffffffc020126e:	07e68693          	addi	a3,a3,126 # ffffffffc02022e8 <kmalloc_sizes+0x300>
ffffffffc0201272:	00001617          	auipc	a2,0x1
ffffffffc0201276:	d4660613          	addi	a2,a2,-698 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020127a:	14800593          	li	a1,328
ffffffffc020127e:	00001517          	auipc	a0,0x1
ffffffffc0201282:	db250513          	addi	a0,a0,-590 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201286:	f3dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free == 0);
ffffffffc020128a:	00001697          	auipc	a3,0x1
ffffffffc020128e:	f7668693          	addi	a3,a3,-138 # ffffffffc0202200 <kmalloc_sizes+0x218>
ffffffffc0201292:	00001617          	auipc	a2,0x1
ffffffffc0201296:	d2660613          	addi	a2,a2,-730 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020129a:	13d00593          	li	a1,317
ffffffffc020129e:	00001517          	auipc	a0,0x1
ffffffffc02012a2:	d9250513          	addi	a0,a0,-622 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02012a6:	f1dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012aa:	00001697          	auipc	a3,0x1
ffffffffc02012ae:	ef668693          	addi	a3,a3,-266 # ffffffffc02021a0 <kmalloc_sizes+0x1b8>
ffffffffc02012b2:	00001617          	auipc	a2,0x1
ffffffffc02012b6:	d0660613          	addi	a2,a2,-762 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02012ba:	13700593          	li	a1,311
ffffffffc02012be:	00001517          	auipc	a0,0x1
ffffffffc02012c2:	d7250513          	addi	a0,a0,-654 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02012c6:	efdfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012ca:	00001697          	auipc	a3,0x1
ffffffffc02012ce:	ffe68693          	addi	a3,a3,-2 # ffffffffc02022c8 <kmalloc_sizes+0x2e0>
ffffffffc02012d2:	00001617          	auipc	a2,0x1
ffffffffc02012d6:	ce660613          	addi	a2,a2,-794 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02012da:	13600593          	li	a1,310
ffffffffc02012de:	00001517          	auipc	a0,0x1
ffffffffc02012e2:	d5250513          	addi	a0,a0,-686 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02012e6:	eddfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 + 4 == p1);
ffffffffc02012ea:	00001697          	auipc	a3,0x1
ffffffffc02012ee:	fce68693          	addi	a3,a3,-50 # ffffffffc02022b8 <kmalloc_sizes+0x2d0>
ffffffffc02012f2:	00001617          	auipc	a2,0x1
ffffffffc02012f6:	cc660613          	addi	a2,a2,-826 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02012fa:	12e00593          	li	a1,302
ffffffffc02012fe:	00001517          	auipc	a0,0x1
ffffffffc0201302:	d3250513          	addi	a0,a0,-718 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201306:	ebdfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc020130a:	00001697          	auipc	a3,0x1
ffffffffc020130e:	f9668693          	addi	a3,a3,-106 # ffffffffc02022a0 <kmalloc_sizes+0x2b8>
ffffffffc0201312:	00001617          	auipc	a2,0x1
ffffffffc0201316:	ca660613          	addi	a2,a2,-858 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020131a:	12d00593          	li	a1,301
ffffffffc020131e:	00001517          	auipc	a0,0x1
ffffffffc0201322:	d1250513          	addi	a0,a0,-750 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201326:	e9dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc020132a:	00001697          	auipc	a3,0x1
ffffffffc020132e:	f5668693          	addi	a3,a3,-170 # ffffffffc0202280 <kmalloc_sizes+0x298>
ffffffffc0201332:	00001617          	auipc	a2,0x1
ffffffffc0201336:	c8660613          	addi	a2,a2,-890 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020133a:	12c00593          	li	a1,300
ffffffffc020133e:	00001517          	auipc	a0,0x1
ffffffffc0201342:	cf250513          	addi	a0,a0,-782 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201346:	e7dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc020134a:	00001697          	auipc	a3,0x1
ffffffffc020134e:	f0668693          	addi	a3,a3,-250 # ffffffffc0202250 <kmalloc_sizes+0x268>
ffffffffc0201352:	00001617          	auipc	a2,0x1
ffffffffc0201356:	c6660613          	addi	a2,a2,-922 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020135a:	12a00593          	li	a1,298
ffffffffc020135e:	00001517          	auipc	a0,0x1
ffffffffc0201362:	cd250513          	addi	a0,a0,-814 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201366:	e5dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020136a:	00001697          	auipc	a3,0x1
ffffffffc020136e:	ece68693          	addi	a3,a3,-306 # ffffffffc0202238 <kmalloc_sizes+0x250>
ffffffffc0201372:	00001617          	auipc	a2,0x1
ffffffffc0201376:	c4660613          	addi	a2,a2,-954 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020137a:	12900593          	li	a1,297
ffffffffc020137e:	00001517          	auipc	a0,0x1
ffffffffc0201382:	cb250513          	addi	a0,a0,-846 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201386:	e3dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020138a:	00001697          	auipc	a3,0x1
ffffffffc020138e:	e1668693          	addi	a3,a3,-490 # ffffffffc02021a0 <kmalloc_sizes+0x1b8>
ffffffffc0201392:	00001617          	auipc	a2,0x1
ffffffffc0201396:	c2660613          	addi	a2,a2,-986 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020139a:	11d00593          	li	a1,285
ffffffffc020139e:	00001517          	auipc	a0,0x1
ffffffffc02013a2:	c9250513          	addi	a0,a0,-878 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02013a6:	e1dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(!PageProperty(p0));
ffffffffc02013aa:	00001697          	auipc	a3,0x1
ffffffffc02013ae:	e7668693          	addi	a3,a3,-394 # ffffffffc0202220 <kmalloc_sizes+0x238>
ffffffffc02013b2:	00001617          	auipc	a2,0x1
ffffffffc02013b6:	c0660613          	addi	a2,a2,-1018 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02013ba:	11400593          	li	a1,276
ffffffffc02013be:	00001517          	auipc	a0,0x1
ffffffffc02013c2:	c7250513          	addi	a0,a0,-910 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02013c6:	dfdfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 != NULL);
ffffffffc02013ca:	00001697          	auipc	a3,0x1
ffffffffc02013ce:	e4668693          	addi	a3,a3,-442 # ffffffffc0202210 <kmalloc_sizes+0x228>
ffffffffc02013d2:	00001617          	auipc	a2,0x1
ffffffffc02013d6:	be660613          	addi	a2,a2,-1050 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02013da:	11300593          	li	a1,275
ffffffffc02013de:	00001517          	auipc	a0,0x1
ffffffffc02013e2:	c5250513          	addi	a0,a0,-942 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02013e6:	dddfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free == 0);
ffffffffc02013ea:	00001697          	auipc	a3,0x1
ffffffffc02013ee:	e1668693          	addi	a3,a3,-490 # ffffffffc0202200 <kmalloc_sizes+0x218>
ffffffffc02013f2:	00001617          	auipc	a2,0x1
ffffffffc02013f6:	bc660613          	addi	a2,a2,-1082 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02013fa:	0f500593          	li	a1,245
ffffffffc02013fe:	00001517          	auipc	a0,0x1
ffffffffc0201402:	c3250513          	addi	a0,a0,-974 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201406:	dbdfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020140a:	00001697          	auipc	a3,0x1
ffffffffc020140e:	d9668693          	addi	a3,a3,-618 # ffffffffc02021a0 <kmalloc_sizes+0x1b8>
ffffffffc0201412:	00001617          	auipc	a2,0x1
ffffffffc0201416:	ba660613          	addi	a2,a2,-1114 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020141a:	0f300593          	li	a1,243
ffffffffc020141e:	00001517          	auipc	a0,0x1
ffffffffc0201422:	c1250513          	addi	a0,a0,-1006 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201426:	d9dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020142a:	00001697          	auipc	a3,0x1
ffffffffc020142e:	db668693          	addi	a3,a3,-586 # ffffffffc02021e0 <kmalloc_sizes+0x1f8>
ffffffffc0201432:	00001617          	auipc	a2,0x1
ffffffffc0201436:	b8660613          	addi	a2,a2,-1146 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc020143a:	0f200593          	li	a1,242
ffffffffc020143e:	00001517          	auipc	a0,0x1
ffffffffc0201442:	bf250513          	addi	a0,a0,-1038 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201446:	d7dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020144a <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc020144a:	1141                	addi	sp,sp,-16
ffffffffc020144c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020144e:	14058c63          	beqz	a1,ffffffffc02015a6 <best_fit_free_pages+0x15c>
    for (; p != base + n; p ++) {
ffffffffc0201452:	00259693          	slli	a3,a1,0x2
ffffffffc0201456:	96ae                	add	a3,a3,a1
ffffffffc0201458:	068e                	slli	a3,a3,0x3
ffffffffc020145a:	96aa                	add	a3,a3,a0
ffffffffc020145c:	87aa                	mv	a5,a0
ffffffffc020145e:	00d50e63          	beq	a0,a3,ffffffffc020147a <best_fit_free_pages+0x30>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201462:	6798                	ld	a4,8(a5)
ffffffffc0201464:	8b0d                	andi	a4,a4,3
ffffffffc0201466:	12071063          	bnez	a4,ffffffffc0201586 <best_fit_free_pages+0x13c>
        p->flags = 0;
ffffffffc020146a:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020146e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201472:	02878793          	addi	a5,a5,40
ffffffffc0201476:	fed796e3          	bne	a5,a3,ffffffffc0201462 <best_fit_free_pages+0x18>
    SetPageProperty(base);
ffffffffc020147a:	00853883          	ld	a7,8(a0)
    nr_free += n;
ffffffffc020147e:	00005697          	auipc	a3,0x5
ffffffffc0201482:	d5a68693          	addi	a3,a3,-678 # ffffffffc02061d8 <free_area>
ffffffffc0201486:	4a98                	lw	a4,16(a3)
    base->property = n;
ffffffffc0201488:	2581                	sext.w	a1,a1
    SetPageProperty(base);
ffffffffc020148a:	0028e613          	ori	a2,a7,2
    return list->next == list;
ffffffffc020148e:	669c                	ld	a5,8(a3)
    base->property = n;
ffffffffc0201490:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201492:	e510                	sd	a2,8(a0)
    nr_free += n;
ffffffffc0201494:	9f2d                	addw	a4,a4,a1
ffffffffc0201496:	ca98                	sw	a4,16(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201498:	01850613          	addi	a2,a0,24
    if (list_empty(&free_list)) {
ffffffffc020149c:	0ad78b63          	beq	a5,a3,ffffffffc0201552 <best_fit_free_pages+0x108>
            struct Page* page = le2page(le, page_link);
ffffffffc02014a0:	fe878713          	addi	a4,a5,-24
ffffffffc02014a4:	0006b303          	ld	t1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02014a8:	4801                	li	a6,0
            if (base < page) {
ffffffffc02014aa:	00e56a63          	bltu	a0,a4,ffffffffc02014be <best_fit_free_pages+0x74>
    return listelm->next;
ffffffffc02014ae:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02014b0:	06d70563          	beq	a4,a3,ffffffffc020151a <best_fit_free_pages+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02014b4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02014b6:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02014ba:	fee57ae3          	bgeu	a0,a4,ffffffffc02014ae <best_fit_free_pages+0x64>
ffffffffc02014be:	00080463          	beqz	a6,ffffffffc02014c6 <best_fit_free_pages+0x7c>
ffffffffc02014c2:	0066b023          	sd	t1,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02014c6:	0007b803          	ld	a6,0(a5)
    prev->next = next->prev = elm;
ffffffffc02014ca:	e390                	sd	a2,0(a5)
ffffffffc02014cc:	00c83423          	sd	a2,8(a6)
    elm->next = next;
ffffffffc02014d0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014d2:	01053c23          	sd	a6,24(a0)
    if (le != &free_list) {
ffffffffc02014d6:	02d80463          	beq	a6,a3,ffffffffc02014fe <best_fit_free_pages+0xb4>
        if (p + p->property == base) {
ffffffffc02014da:	ff882e03          	lw	t3,-8(a6)
        p = le2page(le, page_link);
ffffffffc02014de:	fe880313          	addi	t1,a6,-24
        if (p + p->property == base) {
ffffffffc02014e2:	020e1613          	slli	a2,t3,0x20
ffffffffc02014e6:	9201                	srli	a2,a2,0x20
ffffffffc02014e8:	00261713          	slli	a4,a2,0x2
ffffffffc02014ec:	9732                	add	a4,a4,a2
ffffffffc02014ee:	070e                	slli	a4,a4,0x3
ffffffffc02014f0:	971a                	add	a4,a4,t1
ffffffffc02014f2:	02e50e63          	beq	a0,a4,ffffffffc020152e <best_fit_free_pages+0xe4>
    if (le != &free_list) {
ffffffffc02014f6:	00d78f63          	beq	a5,a3,ffffffffc0201514 <best_fit_free_pages+0xca>
ffffffffc02014fa:	fe878713          	addi	a4,a5,-24
        if (base + base->property == p) {
ffffffffc02014fe:	490c                	lw	a1,16(a0)
ffffffffc0201500:	02059613          	slli	a2,a1,0x20
ffffffffc0201504:	9201                	srli	a2,a2,0x20
ffffffffc0201506:	00261693          	slli	a3,a2,0x2
ffffffffc020150a:	96b2                	add	a3,a3,a2
ffffffffc020150c:	068e                	slli	a3,a3,0x3
ffffffffc020150e:	96aa                	add	a3,a3,a0
ffffffffc0201510:	04d70863          	beq	a4,a3,ffffffffc0201560 <best_fit_free_pages+0x116>
}
ffffffffc0201514:	60a2                	ld	ra,8(sp)
ffffffffc0201516:	0141                	addi	sp,sp,16
ffffffffc0201518:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020151a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020151c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020151e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201520:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201522:	02d70463          	beq	a4,a3,ffffffffc020154a <best_fit_free_pages+0x100>
    prev->next = next->prev = elm;
ffffffffc0201526:	8332                	mv	t1,a2
ffffffffc0201528:	4805                	li	a6,1
    for (; p != base + n; p ++) {
ffffffffc020152a:	87ba                	mv	a5,a4
ffffffffc020152c:	b769                	j	ffffffffc02014b6 <best_fit_free_pages+0x6c>
            p->property += base->property;
ffffffffc020152e:	01c585bb          	addw	a1,a1,t3
ffffffffc0201532:	feb82c23          	sw	a1,-8(a6)
            ClearPageProperty(base);
ffffffffc0201536:	ffd8f893          	andi	a7,a7,-3
ffffffffc020153a:	01153423          	sd	a7,8(a0)
    prev->next = next;
ffffffffc020153e:	00f83423          	sd	a5,8(a6)
    next->prev = prev;
ffffffffc0201542:	0107b023          	sd	a6,0(a5)
            base = p;
ffffffffc0201546:	851a                	mv	a0,t1
ffffffffc0201548:	b77d                	j	ffffffffc02014f6 <best_fit_free_pages+0xac>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020154a:	883e                	mv	a6,a5
ffffffffc020154c:	e290                	sd	a2,0(a3)
ffffffffc020154e:	87b6                	mv	a5,a3
ffffffffc0201550:	b769                	j	ffffffffc02014da <best_fit_free_pages+0x90>
}
ffffffffc0201552:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201554:	e390                	sd	a2,0(a5)
ffffffffc0201556:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201558:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020155a:	ed1c                	sd	a5,24(a0)
ffffffffc020155c:	0141                	addi	sp,sp,16
ffffffffc020155e:	8082                	ret
            base->property += p->property;
ffffffffc0201560:	ff87a683          	lw	a3,-8(a5)
            ClearPageProperty(p);
ffffffffc0201564:	ff07b703          	ld	a4,-16(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201568:	0007b803          	ld	a6,0(a5)
ffffffffc020156c:	6790                	ld	a2,8(a5)
            base->property += p->property;
ffffffffc020156e:	9db5                	addw	a1,a1,a3
ffffffffc0201570:	c90c                	sw	a1,16(a0)
            ClearPageProperty(p);
ffffffffc0201572:	9b75                	andi	a4,a4,-3
ffffffffc0201574:	fee7b823          	sd	a4,-16(a5)
}
ffffffffc0201578:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020157a:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020157e:	01063023          	sd	a6,0(a2)
ffffffffc0201582:	0141                	addi	sp,sp,16
ffffffffc0201584:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201586:	00001697          	auipc	a3,0x1
ffffffffc020158a:	d8268693          	addi	a3,a3,-638 # ffffffffc0202308 <kmalloc_sizes+0x320>
ffffffffc020158e:	00001617          	auipc	a2,0x1
ffffffffc0201592:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc0201596:	08e00593          	li	a1,142
ffffffffc020159a:	00001517          	auipc	a0,0x1
ffffffffc020159e:	a9650513          	addi	a0,a0,-1386 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02015a2:	c21fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02015a6:	00001697          	auipc	a3,0x1
ffffffffc02015aa:	a8268693          	addi	a3,a3,-1406 # ffffffffc0202028 <kmalloc_sizes+0x40>
ffffffffc02015ae:	00001617          	auipc	a2,0x1
ffffffffc02015b2:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02015b6:	08b00593          	li	a1,139
ffffffffc02015ba:	00001517          	auipc	a0,0x1
ffffffffc02015be:	a7650513          	addi	a0,a0,-1418 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02015c2:	c01fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02015c6 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02015c6:	1141                	addi	sp,sp,-16
ffffffffc02015c8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015ca:	c5f9                	beqz	a1,ffffffffc0201698 <best_fit_init_memmap+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02015cc:	00259693          	slli	a3,a1,0x2
ffffffffc02015d0:	96ae                	add	a3,a3,a1
ffffffffc02015d2:	068e                	slli	a3,a3,0x3
ffffffffc02015d4:	96aa                	add	a3,a3,a0
ffffffffc02015d6:	87aa                	mv	a5,a0
ffffffffc02015d8:	00d50f63          	beq	a0,a3,ffffffffc02015f6 <best_fit_init_memmap+0x30>
        assert(PageReserved(p));
ffffffffc02015dc:	6798                	ld	a4,8(a5)
ffffffffc02015de:	8b05                	andi	a4,a4,1
ffffffffc02015e0:	cf41                	beqz	a4,ffffffffc0201678 <best_fit_init_memmap+0xb2>
        p->flags = p->property = 0;
ffffffffc02015e2:	0007a823          	sw	zero,16(a5)
ffffffffc02015e6:	0007b423          	sd	zero,8(a5)
ffffffffc02015ea:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015ee:	02878793          	addi	a5,a5,40
ffffffffc02015f2:	fed795e3          	bne	a5,a3,ffffffffc02015dc <best_fit_init_memmap+0x16>
    SetPageProperty(base);
ffffffffc02015f6:	6510                	ld	a2,8(a0)
    nr_free += n;
ffffffffc02015f8:	00005697          	auipc	a3,0x5
ffffffffc02015fc:	be068693          	addi	a3,a3,-1056 # ffffffffc02061d8 <free_area>
ffffffffc0201600:	4a98                	lw	a4,16(a3)
    base->property = n;
ffffffffc0201602:	2581                	sext.w	a1,a1
    SetPageProperty(base);
ffffffffc0201604:	00266613          	ori	a2,a2,2
    return list->next == list;
ffffffffc0201608:	669c                	ld	a5,8(a3)
    base->property = n;
ffffffffc020160a:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020160c:	e510                	sd	a2,8(a0)
    nr_free += n;
ffffffffc020160e:	9db9                	addw	a1,a1,a4
ffffffffc0201610:	ca8c                	sw	a1,16(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201612:	01850613          	addi	a2,a0,24
    if (list_empty(&free_list)) {
ffffffffc0201616:	04d78a63          	beq	a5,a3,ffffffffc020166a <best_fit_init_memmap+0xa4>
            struct Page* page = le2page(le, page_link);
ffffffffc020161a:	fe878713          	addi	a4,a5,-24
ffffffffc020161e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201622:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201624:	00e56a63          	bltu	a0,a4,ffffffffc0201638 <best_fit_init_memmap+0x72>
    return listelm->next;
ffffffffc0201628:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020162a:	02d70263          	beq	a4,a3,ffffffffc020164e <best_fit_init_memmap+0x88>
    for (; p != base + n; p ++) {
ffffffffc020162e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201630:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201634:	fee57ae3          	bgeu	a0,a4,ffffffffc0201628 <best_fit_init_memmap+0x62>
ffffffffc0201638:	c199                	beqz	a1,ffffffffc020163e <best_fit_init_memmap+0x78>
ffffffffc020163a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020163e:	6398                	ld	a4,0(a5)
}
ffffffffc0201640:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201642:	e390                	sd	a2,0(a5)
ffffffffc0201644:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201646:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201648:	ed18                	sd	a4,24(a0)
ffffffffc020164a:	0141                	addi	sp,sp,16
ffffffffc020164c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020164e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201650:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201652:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201654:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201656:	00d70663          	beq	a4,a3,ffffffffc0201662 <best_fit_init_memmap+0x9c>
    prev->next = next->prev = elm;
ffffffffc020165a:	8832                	mv	a6,a2
ffffffffc020165c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020165e:	87ba                	mv	a5,a4
ffffffffc0201660:	bfc1                	j	ffffffffc0201630 <best_fit_init_memmap+0x6a>
}
ffffffffc0201662:	60a2                	ld	ra,8(sp)
ffffffffc0201664:	e290                	sd	a2,0(a3)
ffffffffc0201666:	0141                	addi	sp,sp,16
ffffffffc0201668:	8082                	ret
ffffffffc020166a:	60a2                	ld	ra,8(sp)
ffffffffc020166c:	e390                	sd	a2,0(a5)
ffffffffc020166e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201670:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201672:	ed1c                	sd	a5,24(a0)
ffffffffc0201674:	0141                	addi	sp,sp,16
ffffffffc0201676:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201678:	00001697          	auipc	a3,0x1
ffffffffc020167c:	cb868693          	addi	a3,a3,-840 # ffffffffc0202330 <kmalloc_sizes+0x348>
ffffffffc0201680:	00001617          	auipc	a2,0x1
ffffffffc0201684:	93860613          	addi	a2,a2,-1736 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc0201688:	04a00593          	li	a1,74
ffffffffc020168c:	00001517          	auipc	a0,0x1
ffffffffc0201690:	9a450513          	addi	a0,a0,-1628 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc0201694:	b2ffe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0201698:	00001697          	auipc	a3,0x1
ffffffffc020169c:	99068693          	addi	a3,a3,-1648 # ffffffffc0202028 <kmalloc_sizes+0x40>
ffffffffc02016a0:	00001617          	auipc	a2,0x1
ffffffffc02016a4:	91860613          	addi	a2,a2,-1768 # ffffffffc0201fb8 <etext+0x46c>
ffffffffc02016a8:	04700593          	li	a1,71
ffffffffc02016ac:	00001517          	auipc	a0,0x1
ffffffffc02016b0:	98450513          	addi	a0,a0,-1660 # ffffffffc0202030 <kmalloc_sizes+0x48>
ffffffffc02016b4:	b0ffe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02016b8 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02016b8:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02016bc:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02016be:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02016c0:	cb81                	beqz	a5,ffffffffc02016d0 <strlen+0x18>
        cnt ++;
ffffffffc02016c2:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02016c4:	00a707b3          	add	a5,a4,a0
ffffffffc02016c8:	0007c783          	lbu	a5,0(a5)
ffffffffc02016cc:	fbfd                	bnez	a5,ffffffffc02016c2 <strlen+0xa>
ffffffffc02016ce:	8082                	ret
    }
    return cnt;
}
ffffffffc02016d0:	8082                	ret

ffffffffc02016d2 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02016d2:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02016d4:	e589                	bnez	a1,ffffffffc02016de <strnlen+0xc>
ffffffffc02016d6:	a811                	j	ffffffffc02016ea <strnlen+0x18>
        cnt ++;
ffffffffc02016d8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02016da:	00f58863          	beq	a1,a5,ffffffffc02016ea <strnlen+0x18>
ffffffffc02016de:	00f50733          	add	a4,a0,a5
ffffffffc02016e2:	00074703          	lbu	a4,0(a4)
ffffffffc02016e6:	fb6d                	bnez	a4,ffffffffc02016d8 <strnlen+0x6>
ffffffffc02016e8:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02016ea:	852e                	mv	a0,a1
ffffffffc02016ec:	8082                	ret

ffffffffc02016ee <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02016ee:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02016f2:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02016f6:	cb89                	beqz	a5,ffffffffc0201708 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02016f8:	0505                	addi	a0,a0,1
ffffffffc02016fa:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02016fc:	fee789e3          	beq	a5,a4,ffffffffc02016ee <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201700:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201704:	9d19                	subw	a0,a0,a4
ffffffffc0201706:	8082                	ret
ffffffffc0201708:	4501                	li	a0,0
ffffffffc020170a:	bfed                	j	ffffffffc0201704 <strcmp+0x16>

ffffffffc020170c <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020170c:	c20d                	beqz	a2,ffffffffc020172e <strncmp+0x22>
ffffffffc020170e:	962e                	add	a2,a2,a1
ffffffffc0201710:	a031                	j	ffffffffc020171c <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201712:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201714:	00e79a63          	bne	a5,a4,ffffffffc0201728 <strncmp+0x1c>
ffffffffc0201718:	00b60b63          	beq	a2,a1,ffffffffc020172e <strncmp+0x22>
ffffffffc020171c:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201720:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201722:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201726:	f7f5                	bnez	a5,ffffffffc0201712 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201728:	40e7853b          	subw	a0,a5,a4
}
ffffffffc020172c:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020172e:	4501                	li	a0,0
ffffffffc0201730:	8082                	ret

ffffffffc0201732 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201732:	ca01                	beqz	a2,ffffffffc0201742 <memset+0x10>
ffffffffc0201734:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201736:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201738:	0785                	addi	a5,a5,1
ffffffffc020173a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020173e:	fec79de3          	bne	a5,a2,ffffffffc0201738 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201742:	8082                	ret

ffffffffc0201744 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201744:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201748:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020174a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020174e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201750:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201754:	f022                	sd	s0,32(sp)
ffffffffc0201756:	ec26                	sd	s1,24(sp)
ffffffffc0201758:	e84a                	sd	s2,16(sp)
ffffffffc020175a:	f406                	sd	ra,40(sp)
ffffffffc020175c:	e44e                	sd	s3,8(sp)
ffffffffc020175e:	84aa                	mv	s1,a0
ffffffffc0201760:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201762:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201766:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201768:	03067e63          	bgeu	a2,a6,ffffffffc02017a4 <printnum+0x60>
ffffffffc020176c:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020176e:	00805763          	blez	s0,ffffffffc020177c <printnum+0x38>
ffffffffc0201772:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201774:	85ca                	mv	a1,s2
ffffffffc0201776:	854e                	mv	a0,s3
ffffffffc0201778:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020177a:	fc65                	bnez	s0,ffffffffc0201772 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020177c:	1a02                	slli	s4,s4,0x20
ffffffffc020177e:	00001797          	auipc	a5,0x1
ffffffffc0201782:	c1278793          	addi	a5,a5,-1006 # ffffffffc0202390 <best_fit_pmm_manager+0x38>
ffffffffc0201786:	020a5a13          	srli	s4,s4,0x20
ffffffffc020178a:	9a3e                	add	s4,s4,a5
}
ffffffffc020178c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020178e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201792:	70a2                	ld	ra,40(sp)
ffffffffc0201794:	69a2                	ld	s3,8(sp)
ffffffffc0201796:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201798:	85ca                	mv	a1,s2
ffffffffc020179a:	87a6                	mv	a5,s1
}
ffffffffc020179c:	6942                	ld	s2,16(sp)
ffffffffc020179e:	64e2                	ld	s1,24(sp)
ffffffffc02017a0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02017a2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02017a4:	03065633          	divu	a2,a2,a6
ffffffffc02017a8:	8722                	mv	a4,s0
ffffffffc02017aa:	f9bff0ef          	jal	ra,ffffffffc0201744 <printnum>
ffffffffc02017ae:	b7f9                	j	ffffffffc020177c <printnum+0x38>

ffffffffc02017b0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02017b0:	7119                	addi	sp,sp,-128
ffffffffc02017b2:	f4a6                	sd	s1,104(sp)
ffffffffc02017b4:	f0ca                	sd	s2,96(sp)
ffffffffc02017b6:	ecce                	sd	s3,88(sp)
ffffffffc02017b8:	e8d2                	sd	s4,80(sp)
ffffffffc02017ba:	e4d6                	sd	s5,72(sp)
ffffffffc02017bc:	e0da                	sd	s6,64(sp)
ffffffffc02017be:	fc5e                	sd	s7,56(sp)
ffffffffc02017c0:	f06a                	sd	s10,32(sp)
ffffffffc02017c2:	fc86                	sd	ra,120(sp)
ffffffffc02017c4:	f8a2                	sd	s0,112(sp)
ffffffffc02017c6:	f862                	sd	s8,48(sp)
ffffffffc02017c8:	f466                	sd	s9,40(sp)
ffffffffc02017ca:	ec6e                	sd	s11,24(sp)
ffffffffc02017cc:	892a                	mv	s2,a0
ffffffffc02017ce:	84ae                	mv	s1,a1
ffffffffc02017d0:	8d32                	mv	s10,a2
ffffffffc02017d2:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02017d4:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02017d8:	5b7d                	li	s6,-1
ffffffffc02017da:	00001a97          	auipc	s5,0x1
ffffffffc02017de:	beaa8a93          	addi	s5,s5,-1046 # ffffffffc02023c4 <best_fit_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017e2:	00001b97          	auipc	s7,0x1
ffffffffc02017e6:	dbeb8b93          	addi	s7,s7,-578 # ffffffffc02025a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02017ea:	000d4503          	lbu	a0,0(s10)
ffffffffc02017ee:	001d0413          	addi	s0,s10,1
ffffffffc02017f2:	01350a63          	beq	a0,s3,ffffffffc0201806 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02017f6:	c121                	beqz	a0,ffffffffc0201836 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02017f8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02017fa:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02017fc:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02017fe:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201802:	ff351ae3          	bne	a0,s3,ffffffffc02017f6 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201806:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020180a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020180e:	4c81                	li	s9,0
ffffffffc0201810:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201812:	5c7d                	li	s8,-1
ffffffffc0201814:	5dfd                	li	s11,-1
ffffffffc0201816:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020181a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020181c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201820:	0ff5f593          	zext.b	a1,a1
ffffffffc0201824:	00140d13          	addi	s10,s0,1
ffffffffc0201828:	04b56263          	bltu	a0,a1,ffffffffc020186c <vprintfmt+0xbc>
ffffffffc020182c:	058a                	slli	a1,a1,0x2
ffffffffc020182e:	95d6                	add	a1,a1,s5
ffffffffc0201830:	4194                	lw	a3,0(a1)
ffffffffc0201832:	96d6                	add	a3,a3,s5
ffffffffc0201834:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201836:	70e6                	ld	ra,120(sp)
ffffffffc0201838:	7446                	ld	s0,112(sp)
ffffffffc020183a:	74a6                	ld	s1,104(sp)
ffffffffc020183c:	7906                	ld	s2,96(sp)
ffffffffc020183e:	69e6                	ld	s3,88(sp)
ffffffffc0201840:	6a46                	ld	s4,80(sp)
ffffffffc0201842:	6aa6                	ld	s5,72(sp)
ffffffffc0201844:	6b06                	ld	s6,64(sp)
ffffffffc0201846:	7be2                	ld	s7,56(sp)
ffffffffc0201848:	7c42                	ld	s8,48(sp)
ffffffffc020184a:	7ca2                	ld	s9,40(sp)
ffffffffc020184c:	7d02                	ld	s10,32(sp)
ffffffffc020184e:	6de2                	ld	s11,24(sp)
ffffffffc0201850:	6109                	addi	sp,sp,128
ffffffffc0201852:	8082                	ret
            padc = '0';
ffffffffc0201854:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201856:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020185a:	846a                	mv	s0,s10
ffffffffc020185c:	00140d13          	addi	s10,s0,1
ffffffffc0201860:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201864:	0ff5f593          	zext.b	a1,a1
ffffffffc0201868:	fcb572e3          	bgeu	a0,a1,ffffffffc020182c <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020186c:	85a6                	mv	a1,s1
ffffffffc020186e:	02500513          	li	a0,37
ffffffffc0201872:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201874:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201878:	8d22                	mv	s10,s0
ffffffffc020187a:	f73788e3          	beq	a5,s3,ffffffffc02017ea <vprintfmt+0x3a>
ffffffffc020187e:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201882:	1d7d                	addi	s10,s10,-1
ffffffffc0201884:	ff379de3          	bne	a5,s3,ffffffffc020187e <vprintfmt+0xce>
ffffffffc0201888:	b78d                	j	ffffffffc02017ea <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020188a:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020188e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201892:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201894:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201898:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020189c:	02d86463          	bltu	a6,a3,ffffffffc02018c4 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02018a0:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02018a4:	002c169b          	slliw	a3,s8,0x2
ffffffffc02018a8:	0186873b          	addw	a4,a3,s8
ffffffffc02018ac:	0017171b          	slliw	a4,a4,0x1
ffffffffc02018b0:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02018b2:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02018b6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02018b8:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02018bc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02018c0:	fed870e3          	bgeu	a6,a3,ffffffffc02018a0 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02018c4:	f40ddce3          	bgez	s11,ffffffffc020181c <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02018c8:	8de2                	mv	s11,s8
ffffffffc02018ca:	5c7d                	li	s8,-1
ffffffffc02018cc:	bf81                	j	ffffffffc020181c <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02018ce:	fffdc693          	not	a3,s11
ffffffffc02018d2:	96fd                	srai	a3,a3,0x3f
ffffffffc02018d4:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018d8:	00144603          	lbu	a2,1(s0)
ffffffffc02018dc:	2d81                	sext.w	s11,s11
ffffffffc02018de:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02018e0:	bf35                	j	ffffffffc020181c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02018e2:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018e6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02018ea:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018ec:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02018ee:	bfd9                	j	ffffffffc02018c4 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02018f0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02018f2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02018f6:	01174463          	blt	a4,a7,ffffffffc02018fe <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02018fa:	1a088e63          	beqz	a7,ffffffffc0201ab6 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02018fe:	000a3603          	ld	a2,0(s4)
ffffffffc0201902:	46c1                	li	a3,16
ffffffffc0201904:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201906:	2781                	sext.w	a5,a5
ffffffffc0201908:	876e                	mv	a4,s11
ffffffffc020190a:	85a6                	mv	a1,s1
ffffffffc020190c:	854a                	mv	a0,s2
ffffffffc020190e:	e37ff0ef          	jal	ra,ffffffffc0201744 <printnum>
            break;
ffffffffc0201912:	bde1                	j	ffffffffc02017ea <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201914:	000a2503          	lw	a0,0(s4)
ffffffffc0201918:	85a6                	mv	a1,s1
ffffffffc020191a:	0a21                	addi	s4,s4,8
ffffffffc020191c:	9902                	jalr	s2
            break;
ffffffffc020191e:	b5f1                	j	ffffffffc02017ea <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201920:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201922:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201926:	01174463          	blt	a4,a7,ffffffffc020192e <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020192a:	18088163          	beqz	a7,ffffffffc0201aac <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020192e:	000a3603          	ld	a2,0(s4)
ffffffffc0201932:	46a9                	li	a3,10
ffffffffc0201934:	8a2e                	mv	s4,a1
ffffffffc0201936:	bfc1                	j	ffffffffc0201906 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201938:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020193c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020193e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201940:	bdf1                	j	ffffffffc020181c <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201942:	85a6                	mv	a1,s1
ffffffffc0201944:	02500513          	li	a0,37
ffffffffc0201948:	9902                	jalr	s2
            break;
ffffffffc020194a:	b545                	j	ffffffffc02017ea <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020194c:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201950:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201952:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201954:	b5e1                	j	ffffffffc020181c <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201956:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201958:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020195c:	01174463          	blt	a4,a7,ffffffffc0201964 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201960:	14088163          	beqz	a7,ffffffffc0201aa2 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201964:	000a3603          	ld	a2,0(s4)
ffffffffc0201968:	46a1                	li	a3,8
ffffffffc020196a:	8a2e                	mv	s4,a1
ffffffffc020196c:	bf69                	j	ffffffffc0201906 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020196e:	03000513          	li	a0,48
ffffffffc0201972:	85a6                	mv	a1,s1
ffffffffc0201974:	e03e                	sd	a5,0(sp)
ffffffffc0201976:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201978:	85a6                	mv	a1,s1
ffffffffc020197a:	07800513          	li	a0,120
ffffffffc020197e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201980:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201982:	6782                	ld	a5,0(sp)
ffffffffc0201984:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201986:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020198a:	bfb5                	j	ffffffffc0201906 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020198c:	000a3403          	ld	s0,0(s4)
ffffffffc0201990:	008a0713          	addi	a4,s4,8
ffffffffc0201994:	e03a                	sd	a4,0(sp)
ffffffffc0201996:	14040263          	beqz	s0,ffffffffc0201ada <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020199a:	0fb05763          	blez	s11,ffffffffc0201a88 <vprintfmt+0x2d8>
ffffffffc020199e:	02d00693          	li	a3,45
ffffffffc02019a2:	0cd79163          	bne	a5,a3,ffffffffc0201a64 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019a6:	00044783          	lbu	a5,0(s0)
ffffffffc02019aa:	0007851b          	sext.w	a0,a5
ffffffffc02019ae:	cf85                	beqz	a5,ffffffffc02019e6 <vprintfmt+0x236>
ffffffffc02019b0:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02019b4:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019b8:	000c4563          	bltz	s8,ffffffffc02019c2 <vprintfmt+0x212>
ffffffffc02019bc:	3c7d                	addiw	s8,s8,-1
ffffffffc02019be:	036c0263          	beq	s8,s6,ffffffffc02019e2 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02019c2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02019c4:	0e0c8e63          	beqz	s9,ffffffffc0201ac0 <vprintfmt+0x310>
ffffffffc02019c8:	3781                	addiw	a5,a5,-32
ffffffffc02019ca:	0ef47b63          	bgeu	s0,a5,ffffffffc0201ac0 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02019ce:	03f00513          	li	a0,63
ffffffffc02019d2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019d4:	000a4783          	lbu	a5,0(s4)
ffffffffc02019d8:	3dfd                	addiw	s11,s11,-1
ffffffffc02019da:	0a05                	addi	s4,s4,1
ffffffffc02019dc:	0007851b          	sext.w	a0,a5
ffffffffc02019e0:	ffe1                	bnez	a5,ffffffffc02019b8 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02019e2:	01b05963          	blez	s11,ffffffffc02019f4 <vprintfmt+0x244>
ffffffffc02019e6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02019e8:	85a6                	mv	a1,s1
ffffffffc02019ea:	02000513          	li	a0,32
ffffffffc02019ee:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02019f0:	fe0d9be3          	bnez	s11,ffffffffc02019e6 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02019f4:	6a02                	ld	s4,0(sp)
ffffffffc02019f6:	bbd5                	j	ffffffffc02017ea <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02019f8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02019fa:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02019fe:	01174463          	blt	a4,a7,ffffffffc0201a06 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201a02:	08088d63          	beqz	a7,ffffffffc0201a9c <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201a06:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201a0a:	0a044d63          	bltz	s0,ffffffffc0201ac4 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201a0e:	8622                	mv	a2,s0
ffffffffc0201a10:	8a66                	mv	s4,s9
ffffffffc0201a12:	46a9                	li	a3,10
ffffffffc0201a14:	bdcd                	j	ffffffffc0201906 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201a16:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201a1a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201a1c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201a1e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201a22:	8fb5                	xor	a5,a5,a3
ffffffffc0201a24:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201a28:	02d74163          	blt	a4,a3,ffffffffc0201a4a <vprintfmt+0x29a>
ffffffffc0201a2c:	00369793          	slli	a5,a3,0x3
ffffffffc0201a30:	97de                	add	a5,a5,s7
ffffffffc0201a32:	639c                	ld	a5,0(a5)
ffffffffc0201a34:	cb99                	beqz	a5,ffffffffc0201a4a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201a36:	86be                	mv	a3,a5
ffffffffc0201a38:	00001617          	auipc	a2,0x1
ffffffffc0201a3c:	98860613          	addi	a2,a2,-1656 # ffffffffc02023c0 <best_fit_pmm_manager+0x68>
ffffffffc0201a40:	85a6                	mv	a1,s1
ffffffffc0201a42:	854a                	mv	a0,s2
ffffffffc0201a44:	0ce000ef          	jal	ra,ffffffffc0201b12 <printfmt>
ffffffffc0201a48:	b34d                	j	ffffffffc02017ea <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201a4a:	00001617          	auipc	a2,0x1
ffffffffc0201a4e:	96660613          	addi	a2,a2,-1690 # ffffffffc02023b0 <best_fit_pmm_manager+0x58>
ffffffffc0201a52:	85a6                	mv	a1,s1
ffffffffc0201a54:	854a                	mv	a0,s2
ffffffffc0201a56:	0bc000ef          	jal	ra,ffffffffc0201b12 <printfmt>
ffffffffc0201a5a:	bb41                	j	ffffffffc02017ea <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201a5c:	00001417          	auipc	s0,0x1
ffffffffc0201a60:	94c40413          	addi	s0,s0,-1716 # ffffffffc02023a8 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201a64:	85e2                	mv	a1,s8
ffffffffc0201a66:	8522                	mv	a0,s0
ffffffffc0201a68:	e43e                	sd	a5,8(sp)
ffffffffc0201a6a:	c69ff0ef          	jal	ra,ffffffffc02016d2 <strnlen>
ffffffffc0201a6e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201a72:	01b05b63          	blez	s11,ffffffffc0201a88 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201a76:	67a2                	ld	a5,8(sp)
ffffffffc0201a78:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201a7c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201a7e:	85a6                	mv	a1,s1
ffffffffc0201a80:	8552                	mv	a0,s4
ffffffffc0201a82:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201a84:	fe0d9ce3          	bnez	s11,ffffffffc0201a7c <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a88:	00044783          	lbu	a5,0(s0)
ffffffffc0201a8c:	00140a13          	addi	s4,s0,1
ffffffffc0201a90:	0007851b          	sext.w	a0,a5
ffffffffc0201a94:	d3a5                	beqz	a5,ffffffffc02019f4 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a96:	05e00413          	li	s0,94
ffffffffc0201a9a:	bf39                	j	ffffffffc02019b8 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201a9c:	000a2403          	lw	s0,0(s4)
ffffffffc0201aa0:	b7ad                	j	ffffffffc0201a0a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201aa2:	000a6603          	lwu	a2,0(s4)
ffffffffc0201aa6:	46a1                	li	a3,8
ffffffffc0201aa8:	8a2e                	mv	s4,a1
ffffffffc0201aaa:	bdb1                	j	ffffffffc0201906 <vprintfmt+0x156>
ffffffffc0201aac:	000a6603          	lwu	a2,0(s4)
ffffffffc0201ab0:	46a9                	li	a3,10
ffffffffc0201ab2:	8a2e                	mv	s4,a1
ffffffffc0201ab4:	bd89                	j	ffffffffc0201906 <vprintfmt+0x156>
ffffffffc0201ab6:	000a6603          	lwu	a2,0(s4)
ffffffffc0201aba:	46c1                	li	a3,16
ffffffffc0201abc:	8a2e                	mv	s4,a1
ffffffffc0201abe:	b5a1                	j	ffffffffc0201906 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201ac0:	9902                	jalr	s2
ffffffffc0201ac2:	bf09                	j	ffffffffc02019d4 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201ac4:	85a6                	mv	a1,s1
ffffffffc0201ac6:	02d00513          	li	a0,45
ffffffffc0201aca:	e03e                	sd	a5,0(sp)
ffffffffc0201acc:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201ace:	6782                	ld	a5,0(sp)
ffffffffc0201ad0:	8a66                	mv	s4,s9
ffffffffc0201ad2:	40800633          	neg	a2,s0
ffffffffc0201ad6:	46a9                	li	a3,10
ffffffffc0201ad8:	b53d                	j	ffffffffc0201906 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201ada:	03b05163          	blez	s11,ffffffffc0201afc <vprintfmt+0x34c>
ffffffffc0201ade:	02d00693          	li	a3,45
ffffffffc0201ae2:	f6d79de3          	bne	a5,a3,ffffffffc0201a5c <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201ae6:	00001417          	auipc	s0,0x1
ffffffffc0201aea:	8c240413          	addi	s0,s0,-1854 # ffffffffc02023a8 <best_fit_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201aee:	02800793          	li	a5,40
ffffffffc0201af2:	02800513          	li	a0,40
ffffffffc0201af6:	00140a13          	addi	s4,s0,1
ffffffffc0201afa:	bd6d                	j	ffffffffc02019b4 <vprintfmt+0x204>
ffffffffc0201afc:	00001a17          	auipc	s4,0x1
ffffffffc0201b00:	8ada0a13          	addi	s4,s4,-1875 # ffffffffc02023a9 <best_fit_pmm_manager+0x51>
ffffffffc0201b04:	02800513          	li	a0,40
ffffffffc0201b08:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201b0c:	05e00413          	li	s0,94
ffffffffc0201b10:	b565                	j	ffffffffc02019b8 <vprintfmt+0x208>

ffffffffc0201b12 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b12:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201b14:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b18:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201b1a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b1c:	ec06                	sd	ra,24(sp)
ffffffffc0201b1e:	f83a                	sd	a4,48(sp)
ffffffffc0201b20:	fc3e                	sd	a5,56(sp)
ffffffffc0201b22:	e0c2                	sd	a6,64(sp)
ffffffffc0201b24:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201b26:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201b28:	c89ff0ef          	jal	ra,ffffffffc02017b0 <vprintfmt>
}
ffffffffc0201b2c:	60e2                	ld	ra,24(sp)
ffffffffc0201b2e:	6161                	addi	sp,sp,80
ffffffffc0201b30:	8082                	ret

ffffffffc0201b32 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201b32:	4781                	li	a5,0
ffffffffc0201b34:	00004717          	auipc	a4,0x4
ffffffffc0201b38:	4dc73703          	ld	a4,1244(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201b3c:	88ba                	mv	a7,a4
ffffffffc0201b3e:	852a                	mv	a0,a0
ffffffffc0201b40:	85be                	mv	a1,a5
ffffffffc0201b42:	863e                	mv	a2,a5
ffffffffc0201b44:	00000073          	ecall
ffffffffc0201b48:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201b4a:	8082                	ret
