
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00005297          	auipc	t0,0x5
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0205000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00005297          	auipc	t0,0x5
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0205008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02042b7          	lui	t0,0xc0204
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
ffffffffc020003c:	c0204137          	lui	sp,0xc0204

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
ffffffffc0200050:	3ec50513          	addi	a0,a0,1004 # ffffffffc0201438 <etext+0x2>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00001517          	auipc	a0,0x1
ffffffffc0200066:	3f650513          	addi	a0,a0,1014 # ffffffffc0201458 <etext+0x22>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00001597          	auipc	a1,0x1
ffffffffc0200072:	3c858593          	addi	a1,a1,968 # ffffffffc0201436 <etext>
ffffffffc0200076:	00001517          	auipc	a0,0x1
ffffffffc020007a:	40250513          	addi	a0,a0,1026 # ffffffffc0201478 <etext+0x42>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00005597          	auipc	a1,0x5
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0205018 <free_areas>
ffffffffc020008a:	00001517          	auipc	a0,0x1
ffffffffc020008e:	40e50513          	addi	a0,a0,1038 # ffffffffc0201498 <etext+0x62>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00005597          	auipc	a1,0x5
ffffffffc020009a:	1c258593          	addi	a1,a1,450 # ffffffffc0205258 <end>
ffffffffc020009e:	00001517          	auipc	a0,0x1
ffffffffc02000a2:	41a50513          	addi	a0,a0,1050 # ffffffffc02014b8 <etext+0x82>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00005597          	auipc	a1,0x5
ffffffffc02000ae:	5ad58593          	addi	a1,a1,1453 # ffffffffc0205657 <end+0x3ff>
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
ffffffffc02000d0:	40c50513          	addi	a0,a0,1036 # ffffffffc02014d8 <etext+0xa2>
}
ffffffffc02000d4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d8:	00005517          	auipc	a0,0x5
ffffffffc02000dc:	f4050513          	addi	a0,a0,-192 # ffffffffc0205018 <free_areas>
ffffffffc02000e0:	00005617          	auipc	a2,0x5
ffffffffc02000e4:	17860613          	addi	a2,a2,376 # ffffffffc0205258 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	72d000ef          	jal	ra,ffffffffc020101c <memset>
    dtb_init();
ffffffffc02000f4:	122000ef          	jal	ra,ffffffffc0200216 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	4ce000ef          	jal	ra,ffffffffc02005c6 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00001517          	auipc	a0,0x1
ffffffffc0200100:	40c50513          	addi	a0,a0,1036 # ffffffffc0201508 <etext+0xd2>
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
ffffffffc0200140:	75b000ef          	jal	ra,ffffffffc020109a <vprintfmt>
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
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0204028 <boot_page_table_sv39+0x28>
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
ffffffffc0200176:	725000ef          	jal	ra,ffffffffc020109a <vprintfmt>
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
ffffffffc02001c2:	00005317          	auipc	t1,0x5
ffffffffc02001c6:	03630313          	addi	t1,t1,54 # ffffffffc02051f8 <is_panic>
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
ffffffffc02001f6:	33650513          	addi	a0,a0,822 # ffffffffc0201528 <etext+0xf2>
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
ffffffffc020020c:	91050513          	addi	a0,a0,-1776 # ffffffffc0201b18 <etext+0x6e2>
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
ffffffffc020021c:	33050513          	addi	a0,a0,816 # ffffffffc0201548 <etext+0x112>
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
ffffffffc020023e:	00005597          	auipc	a1,0x5
ffffffffc0200242:	dc25b583          	ld	a1,-574(a1) # ffffffffc0205000 <boot_hartid>
ffffffffc0200246:	00001517          	auipc	a0,0x1
ffffffffc020024a:	31250513          	addi	a0,a0,786 # ffffffffc0201558 <etext+0x122>
ffffffffc020024e:	effff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200252:	00005417          	auipc	s0,0x5
ffffffffc0200256:	db640413          	addi	s0,s0,-586 # ffffffffc0205008 <boot_dtb>
ffffffffc020025a:	600c                	ld	a1,0(s0)
ffffffffc020025c:	00001517          	auipc	a0,0x1
ffffffffc0200260:	30c50513          	addi	a0,a0,780 # ffffffffc0201568 <etext+0x132>
ffffffffc0200264:	ee9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200268:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020026c:	00001517          	auipc	a0,0x1
ffffffffc0200270:	31450513          	addi	a0,a0,788 # ffffffffc0201580 <etext+0x14a>
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
ffffffffc02002b4:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfedac95>
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
ffffffffc020032a:	2aa90913          	addi	s2,s2,682 # ffffffffc02015d0 <etext+0x19a>
ffffffffc020032e:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200330:	4d91                	li	s11,4
ffffffffc0200332:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200334:	00001497          	auipc	s1,0x1
ffffffffc0200338:	29448493          	addi	s1,s1,660 # ffffffffc02015c8 <etext+0x192>
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
ffffffffc020038c:	2c050513          	addi	a0,a0,704 # ffffffffc0201648 <etext+0x212>
ffffffffc0200390:	dbdff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200394:	00001517          	auipc	a0,0x1
ffffffffc0200398:	2ec50513          	addi	a0,a0,748 # ffffffffc0201680 <etext+0x24a>
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
ffffffffc02003d8:	1cc50513          	addi	a0,a0,460 # ffffffffc02015a0 <etext+0x16a>
}
ffffffffc02003dc:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003de:	b3bd                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003e0:	8556                	mv	a0,s5
ffffffffc02003e2:	3c1000ef          	jal	ra,ffffffffc0200fa2 <strlen>
ffffffffc02003e6:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e8:	4619                	li	a2,6
ffffffffc02003ea:	85a6                	mv	a1,s1
ffffffffc02003ec:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003ee:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f0:	407000ef          	jal	ra,ffffffffc0200ff6 <strncmp>
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
ffffffffc0200486:	353000ef          	jal	ra,ffffffffc0200fd8 <strcmp>
ffffffffc020048a:	66a2                	ld	a3,8(sp)
ffffffffc020048c:	f94d                	bnez	a0,ffffffffc020043e <dtb_init+0x228>
ffffffffc020048e:	fb59f8e3          	bgeu	s3,s5,ffffffffc020043e <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200492:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200496:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020049a:	00001517          	auipc	a0,0x1
ffffffffc020049e:	13e50513          	addi	a0,a0,318 # ffffffffc02015d8 <etext+0x1a2>
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
ffffffffc020056c:	09050513          	addi	a0,a0,144 # ffffffffc02015f8 <etext+0x1c2>
ffffffffc0200570:	bddff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200574:	014b5613          	srli	a2,s6,0x14
ffffffffc0200578:	85da                	mv	a1,s6
ffffffffc020057a:	00001517          	auipc	a0,0x1
ffffffffc020057e:	09650513          	addi	a0,a0,150 # ffffffffc0201610 <etext+0x1da>
ffffffffc0200582:	bcbff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200586:	008b05b3          	add	a1,s6,s0
ffffffffc020058a:	15fd                	addi	a1,a1,-1
ffffffffc020058c:	00001517          	auipc	a0,0x1
ffffffffc0200590:	0a450513          	addi	a0,a0,164 # ffffffffc0201630 <etext+0x1fa>
ffffffffc0200594:	bb9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	0e850513          	addi	a0,a0,232 # ffffffffc0201680 <etext+0x24a>
        memory_base = mem_base;
ffffffffc02005a0:	00005797          	auipc	a5,0x5
ffffffffc02005a4:	c687b023          	sd	s0,-928(a5) # ffffffffc0205200 <memory_base>
        memory_size = mem_size;
ffffffffc02005a8:	00005797          	auipc	a5,0x5
ffffffffc02005ac:	c767b023          	sd	s6,-928(a5) # ffffffffc0205208 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005b0:	b3f5                	j	ffffffffc020039c <dtb_init+0x186>

ffffffffc02005b2 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005b2:	00005517          	auipc	a0,0x5
ffffffffc02005b6:	c4e53503          	ld	a0,-946(a0) # ffffffffc0205200 <memory_base>
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005bc:	00005517          	auipc	a0,0x5
ffffffffc02005c0:	c4c53503          	ld	a0,-948(a0) # ffffffffc0205208 <memory_size>
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
ffffffffc02005cc:	6510006f          	j	ffffffffc020141c <sbi_console_putchar>

ffffffffc02005d0 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc02005d0:	00005797          	auipc	a5,0x5
ffffffffc02005d4:	c507b783          	ld	a5,-944(a5) # ffffffffc0205220 <pmm_manager>
ffffffffc02005d8:	6f9c                	ld	a5,24(a5)
ffffffffc02005da:	8782                	jr	a5

ffffffffc02005dc <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc02005dc:	00005797          	auipc	a5,0x5
ffffffffc02005e0:	c447b783          	ld	a5,-956(a5) # ffffffffc0205220 <pmm_manager>
ffffffffc02005e4:	739c                	ld	a5,32(a5)
ffffffffc02005e6:	8782                	jr	a5

ffffffffc02005e8 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc02005e8:	00001797          	auipc	a5,0x1
ffffffffc02005ec:	58078793          	addi	a5,a5,1408 # ffffffffc0201b68 <buddy_pmm_manager>
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
ffffffffc02005fa:	0a250513          	addi	a0,a0,162 # ffffffffc0201698 <etext+0x262>
    pmm_manager = &buddy_pmm_manager;
ffffffffc02005fe:	00005417          	auipc	s0,0x5
ffffffffc0200602:	c2240413          	addi	s0,s0,-990 # ffffffffc0205220 <pmm_manager>
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
ffffffffc0200618:	00005497          	auipc	s1,0x5
ffffffffc020061c:	c2048493          	addi	s1,s1,-992 # ffffffffc0205238 <va_pa_offset>
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
ffffffffc0200634:	14050c63          	beqz	a0,ffffffffc020078c <pmm_init+0x1a4>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200638:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc020063a:	00001517          	auipc	a0,0x1
ffffffffc020063e:	0a650513          	addi	a0,a0,166 # ffffffffc02016e0 <etext+0x2aa>
ffffffffc0200642:	b0bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200646:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020064a:	864e                	mv	a2,s3
ffffffffc020064c:	fffa0693          	addi	a3,s4,-1
ffffffffc0200650:	85ca                	mv	a1,s2
ffffffffc0200652:	00001517          	auipc	a0,0x1
ffffffffc0200656:	0a650513          	addi	a0,a0,166 # ffffffffc02016f8 <etext+0x2c2>
ffffffffc020065a:	af3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020065e:	c80007b7          	lui	a5,0xc8000
ffffffffc0200662:	8652                	mv	a2,s4
ffffffffc0200664:	0d47e363          	bltu	a5,s4,ffffffffc020072a <pmm_init+0x142>
ffffffffc0200668:	00006797          	auipc	a5,0x6
ffffffffc020066c:	bef78793          	addi	a5,a5,-1041 # ffffffffc0206257 <end+0xfff>
ffffffffc0200670:	757d                	lui	a0,0xfffff
ffffffffc0200672:	8d7d                	and	a0,a0,a5
ffffffffc0200674:	8231                	srli	a2,a2,0xc
ffffffffc0200676:	00005797          	auipc	a5,0x5
ffffffffc020067a:	b8c7bd23          	sd	a2,-1126(a5) # ffffffffc0205210 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020067e:	00005797          	auipc	a5,0x5
ffffffffc0200682:	b8a7bd23          	sd	a0,-1126(a5) # ffffffffc0205218 <pages>
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
ffffffffc02006a8:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9fadd0>
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
ffffffffc02006c8:	0af6e663          	bltu	a3,a5,ffffffffc0200774 <pmm_init+0x18c>
ffffffffc02006cc:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02006ce:	77fd                	lui	a5,0xfffff
ffffffffc02006d0:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006d4:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02006d6:	04b6ed63          	bltu	a3,a1,ffffffffc0200730 <pmm_init+0x148>
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
ffffffffc02006e4:	0a050513          	addi	a0,a0,160 # ffffffffc0201780 <etext+0x34a>
ffffffffc02006e8:	a65ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02006ec:	00004597          	auipc	a1,0x4
ffffffffc02006f0:	91458593          	addi	a1,a1,-1772 # ffffffffc0204000 <boot_page_table_sv39>
ffffffffc02006f4:	00005797          	auipc	a5,0x5
ffffffffc02006f8:	b2b7be23          	sd	a1,-1220(a5) # ffffffffc0205230 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02006fc:	c02007b7          	lui	a5,0xc0200
ffffffffc0200700:	0af5e263          	bltu	a1,a5,ffffffffc02007a4 <pmm_init+0x1bc>
ffffffffc0200704:	6090                	ld	a2,0(s1)
}
ffffffffc0200706:	7402                	ld	s0,32(sp)
ffffffffc0200708:	70a2                	ld	ra,40(sp)
ffffffffc020070a:	64e2                	ld	s1,24(sp)
ffffffffc020070c:	6942                	ld	s2,16(sp)
ffffffffc020070e:	69a2                	ld	s3,8(sp)
ffffffffc0200710:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200712:	40c58633          	sub	a2,a1,a2
ffffffffc0200716:	00005797          	auipc	a5,0x5
ffffffffc020071a:	b0c7b923          	sd	a2,-1262(a5) # ffffffffc0205228 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020071e:	00001517          	auipc	a0,0x1
ffffffffc0200722:	08250513          	addi	a0,a0,130 # ffffffffc02017a0 <etext+0x36a>
}
ffffffffc0200726:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200728:	b415                	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020072a:	c8000637          	lui	a2,0xc8000
ffffffffc020072e:	bf2d                	j	ffffffffc0200668 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200730:	6705                	lui	a4,0x1
ffffffffc0200732:	177d                	addi	a4,a4,-1
ffffffffc0200734:	96ba                	add	a3,a3,a4
ffffffffc0200736:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200738:	00c6d793          	srli	a5,a3,0xc
ffffffffc020073c:	02c7f063          	bgeu	a5,a2,ffffffffc020075c <pmm_init+0x174>
    pmm_manager->init_memmap(base, n);
ffffffffc0200740:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200742:	fff80737          	lui	a4,0xfff80
ffffffffc0200746:	973e                	add	a4,a4,a5
ffffffffc0200748:	00271793          	slli	a5,a4,0x2
ffffffffc020074c:	97ba                	add	a5,a5,a4
ffffffffc020074e:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200750:	8d95                	sub	a1,a1,a3
ffffffffc0200752:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200754:	81b1                	srli	a1,a1,0xc
ffffffffc0200756:	953e                	add	a0,a0,a5
ffffffffc0200758:	9702                	jalr	a4
}
ffffffffc020075a:	b741                	j	ffffffffc02006da <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc020075c:	00001617          	auipc	a2,0x1
ffffffffc0200760:	ff460613          	addi	a2,a2,-12 # ffffffffc0201750 <etext+0x31a>
ffffffffc0200764:	06a00593          	li	a1,106
ffffffffc0200768:	00001517          	auipc	a0,0x1
ffffffffc020076c:	00850513          	addi	a0,a0,8 # ffffffffc0201770 <etext+0x33a>
ffffffffc0200770:	a53ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200774:	00001617          	auipc	a2,0x1
ffffffffc0200778:	fb460613          	addi	a2,a2,-76 # ffffffffc0201728 <etext+0x2f2>
ffffffffc020077c:	05f00593          	li	a1,95
ffffffffc0200780:	00001517          	auipc	a0,0x1
ffffffffc0200784:	f5050513          	addi	a0,a0,-176 # ffffffffc02016d0 <etext+0x29a>
ffffffffc0200788:	a3bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc020078c:	00001617          	auipc	a2,0x1
ffffffffc0200790:	f2460613          	addi	a2,a2,-220 # ffffffffc02016b0 <etext+0x27a>
ffffffffc0200794:	04700593          	li	a1,71
ffffffffc0200798:	00001517          	auipc	a0,0x1
ffffffffc020079c:	f3850513          	addi	a0,a0,-200 # ffffffffc02016d0 <etext+0x29a>
ffffffffc02007a0:	a23ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02007a4:	86ae                	mv	a3,a1
ffffffffc02007a6:	00001617          	auipc	a2,0x1
ffffffffc02007aa:	f8260613          	addi	a2,a2,-126 # ffffffffc0201728 <etext+0x2f2>
ffffffffc02007ae:	07a00593          	li	a1,122
ffffffffc02007b2:	00001517          	auipc	a0,0x1
ffffffffc02007b6:	f1e50513          	addi	a0,a0,-226 # ffffffffc02016d0 <etext+0x29a>
ffffffffc02007ba:	a09ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02007be <buddy_init>:
    return buddy_base + buddy_offset;
}

static void
buddy_init(void) {
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc02007be:	00005797          	auipc	a5,0x5
ffffffffc02007c2:	85a78793          	addi	a5,a5,-1958 # ffffffffc0205018 <free_areas>
ffffffffc02007c6:	00005717          	auipc	a4,0x5
ffffffffc02007ca:	a3270713          	addi	a4,a4,-1486 # ffffffffc02051f8 <is_panic>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02007ce:	e79c                	sd	a5,8(a5)
ffffffffc02007d0:	e39c                	sd	a5,0(a5)
        list_init(&free_list_for_order(i));
        nr_free_for_order(i) = 0;
ffffffffc02007d2:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i < MAX_ORDER; i++) {
ffffffffc02007d6:	07e1                	addi	a5,a5,24
ffffffffc02007d8:	fee79be3          	bne	a5,a4,ffffffffc02007ce <buddy_init+0x10>
    }
    total_free_pages = 0;
ffffffffc02007dc:	00005797          	auipc	a5,0x5
ffffffffc02007e0:	a607ba23          	sd	zero,-1420(a5) # ffffffffc0205250 <total_free_pages>
    buddy_base = NULL;
ffffffffc02007e4:	00005797          	auipc	a5,0x5
ffffffffc02007e8:	a407be23          	sd	zero,-1444(a5) # ffffffffc0205240 <buddy_base>
    buddy_total_pages = 0;
ffffffffc02007ec:	00005797          	auipc	a5,0x5
ffffffffc02007f0:	a407be23          	sd	zero,-1444(a5) # ffffffffc0205248 <buddy_total_pages>
}
ffffffffc02007f4:	8082                	ret

ffffffffc02007f6 <buddy_nr_free_pages>:
    }
}
static size_t
buddy_nr_free_pages(void) {
    return total_free_pages;
}
ffffffffc02007f6:	00005517          	auipc	a0,0x5
ffffffffc02007fa:	a5a53503          	ld	a0,-1446(a0) # ffffffffc0205250 <total_free_pages>
ffffffffc02007fe:	8082                	ret

ffffffffc0200800 <buddy_dump_free_pages>:

static void
buddy_dump_free_pages(void) {
ffffffffc0200800:	711d                	addi	sp,sp,-96
    cprintf("------ Buddy System Free Page Dump ------\n");
ffffffffc0200802:	00001517          	auipc	a0,0x1
ffffffffc0200806:	fde50513          	addi	a0,a0,-34 # ffffffffc02017e0 <etext+0x3aa>
buddy_dump_free_pages(void) {
ffffffffc020080a:	e8a2                	sd	s0,80(sp)
ffffffffc020080c:	e0ca                	sd	s2,64(sp)
ffffffffc020080e:	fc4e                	sd	s3,56(sp)
ffffffffc0200810:	f852                	sd	s4,48(sp)
ffffffffc0200812:	f456                	sd	s5,40(sp)
ffffffffc0200814:	f05a                	sd	s6,32(sp)
ffffffffc0200816:	ec5e                	sd	s7,24(sp)
ffffffffc0200818:	e862                	sd	s8,16(sp)
ffffffffc020081a:	e06a                	sd	s10,0(sp)
ffffffffc020081c:	ec86                	sd	ra,88(sp)
ffffffffc020081e:	e4a6                	sd	s1,72(sp)
ffffffffc0200820:	e466                	sd	s9,8(sp)
ffffffffc0200822:	00005d17          	auipc	s10,0x5
ffffffffc0200826:	946d0d13          	addi	s10,s10,-1722 # ffffffffc0205168 <free_areas+0x150>
    cprintf("------ Buddy System Free Page Dump ------\n");
ffffffffc020082a:	923ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    for (int order = 14; order >=0; order--) {
ffffffffc020082e:	4439                	li	s0,14
        if (!list_empty(&free_list_for_order(order))) {
            cprintf("Order %d (size %lu), %u blocks:\n", order, (1UL << order), nr_free_for_order(order));
ffffffffc0200830:	4b85                	li	s7,1
ffffffffc0200832:	00001b17          	auipc	s6,0x1
ffffffffc0200836:	fdeb0b13          	addi	s6,s6,-34 # ffffffffc0201810 <etext+0x3da>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020083a:	00001c17          	auipc	s8,0x1
ffffffffc020083e:	5aec0c13          	addi	s8,s8,1454 # ffffffffc0201de8 <nbase>
ffffffffc0200842:	00005a17          	auipc	s4,0x5
ffffffffc0200846:	9d6a0a13          	addi	s4,s4,-1578 # ffffffffc0205218 <pages>
ffffffffc020084a:	00001997          	auipc	s3,0x1
ffffffffc020084e:	5a69b983          	ld	s3,1446(s3) # ffffffffc0201df0 <nbase+0x8>
            list_entry_t *le = &free_list_for_order(order);
            while ((le = list_next(le)) != &free_list_for_order(order)) {
                struct Page *p = le2page(le, page_link);
                cprintf("  - Block at physical address 0x%016lx (page index %ld)\n", page2pa(p), p - pages);
ffffffffc0200852:	00001917          	auipc	s2,0x1
ffffffffc0200856:	fe690913          	addi	s2,s2,-26 # ffffffffc0201838 <etext+0x402>
    for (int order = 14; order >=0; order--) {
ffffffffc020085a:	5afd                	li	s5,-1
ffffffffc020085c:	a029                	j	ffffffffc0200866 <buddy_dump_free_pages+0x66>
ffffffffc020085e:	347d                	addiw	s0,s0,-1
ffffffffc0200860:	1d21                	addi	s10,s10,-24
ffffffffc0200862:	05540a63          	beq	s0,s5,ffffffffc02008b6 <buddy_dump_free_pages+0xb6>
        if (!list_empty(&free_list_for_order(order))) {
ffffffffc0200866:	008d3783          	ld	a5,8(s10)
ffffffffc020086a:	ffa78ae3          	beq	a5,s10,ffffffffc020085e <buddy_dump_free_pages+0x5e>
            cprintf("Order %d (size %lu), %u blocks:\n", order, (1UL << order), nr_free_for_order(order));
ffffffffc020086e:	010d2683          	lw	a3,16(s10)
ffffffffc0200872:	008b9633          	sll	a2,s7,s0
ffffffffc0200876:	85a2                	mv	a1,s0
ffffffffc0200878:	855a                	mv	a0,s6
ffffffffc020087a:	8d3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020087e:	008d3c83          	ld	s9,8(s10)
            while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200882:	fdac8ee3          	beq	s9,s10,ffffffffc020085e <buddy_dump_free_pages+0x5e>
ffffffffc0200886:	000c3483          	ld	s1,0(s8)
ffffffffc020088a:	000a3783          	ld	a5,0(s4)
                struct Page *p = le2page(le, page_link);
ffffffffc020088e:	fe8c8613          	addi	a2,s9,-24
                cprintf("  - Block at physical address 0x%016lx (page index %ld)\n", page2pa(p), p - pages);
ffffffffc0200892:	854a                	mv	a0,s2
ffffffffc0200894:	8e1d                	sub	a2,a2,a5
ffffffffc0200896:	860d                	srai	a2,a2,0x3
ffffffffc0200898:	03360633          	mul	a2,a2,s3
ffffffffc020089c:	009605b3          	add	a1,a2,s1
ffffffffc02008a0:	05b2                	slli	a1,a1,0xc
ffffffffc02008a2:	8abff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc02008a6:	008cbc83          	ld	s9,8(s9)
            while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc02008aa:	ffac90e3          	bne	s9,s10,ffffffffc020088a <buddy_dump_free_pages+0x8a>
    for (int order = 14; order >=0; order--) {
ffffffffc02008ae:	347d                	addiw	s0,s0,-1
ffffffffc02008b0:	1d21                	addi	s10,s10,-24
ffffffffc02008b2:	fb541ae3          	bne	s0,s5,ffffffffc0200866 <buddy_dump_free_pages+0x66>
            }
        }
    }
    cprintf("Total free pages: %lu\n", total_free_pages);
ffffffffc02008b6:	00005597          	auipc	a1,0x5
ffffffffc02008ba:	99a5b583          	ld	a1,-1638(a1) # ffffffffc0205250 <total_free_pages>
ffffffffc02008be:	00001517          	auipc	a0,0x1
ffffffffc02008c2:	fba50513          	addi	a0,a0,-70 # ffffffffc0201878 <etext+0x442>
ffffffffc02008c6:	887ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("-----------------------------------------\n");
}
ffffffffc02008ca:	6446                	ld	s0,80(sp)
ffffffffc02008cc:	60e6                	ld	ra,88(sp)
ffffffffc02008ce:	64a6                	ld	s1,72(sp)
ffffffffc02008d0:	6906                	ld	s2,64(sp)
ffffffffc02008d2:	79e2                	ld	s3,56(sp)
ffffffffc02008d4:	7a42                	ld	s4,48(sp)
ffffffffc02008d6:	7aa2                	ld	s5,40(sp)
ffffffffc02008d8:	7b02                	ld	s6,32(sp)
ffffffffc02008da:	6be2                	ld	s7,24(sp)
ffffffffc02008dc:	6c42                	ld	s8,16(sp)
ffffffffc02008de:	6ca2                	ld	s9,8(sp)
ffffffffc02008e0:	6d02                	ld	s10,0(sp)
    cprintf("-----------------------------------------\n");
ffffffffc02008e2:	00001517          	auipc	a0,0x1
ffffffffc02008e6:	fae50513          	addi	a0,a0,-82 # ffffffffc0201890 <etext+0x45a>
}
ffffffffc02008ea:	6125                	addi	sp,sp,96
    cprintf("-----------------------------------------\n");
ffffffffc02008ec:	861ff06f          	j	ffffffffc020014c <cprintf>

ffffffffc02008f0 <buddy_check>:

static void
buddy_check(void) {
ffffffffc02008f0:	7179                	addi	sp,sp,-48
    struct Page *p0, *p1, *p2, *p3, *p4, *p5;
    p0 = p1 = p2 = p3 = p4 = p5 = NULL;
    cprintf("Original State:\n");
ffffffffc02008f2:	00001517          	auipc	a0,0x1
ffffffffc02008f6:	fce50513          	addi	a0,a0,-50 # ffffffffc02018c0 <etext+0x48a>
buddy_check(void) {
ffffffffc02008fa:	f406                	sd	ra,40(sp)
ffffffffc02008fc:	ec26                	sd	s1,24(sp)
ffffffffc02008fe:	f022                	sd	s0,32(sp)
ffffffffc0200900:	e84a                	sd	s2,16(sp)
ffffffffc0200902:	e44e                	sd	s3,8(sp)
    cprintf("Original State:\n");
ffffffffc0200904:	849ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200908:	ef9ff0ef          	jal	ra,ffffffffc0200800 <buddy_dump_free_pages>

    assert((p0 = alloc_pages(16383)) != NULL);
ffffffffc020090c:	6491                	lui	s1,0x4
ffffffffc020090e:	fff48513          	addi	a0,s1,-1 # 3fff <kern_entry-0xffffffffc01fc001>
ffffffffc0200912:	cbfff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200916:	14050463          	beqz	a0,ffffffffc0200a5e <buddy_check+0x16e>
    cprintf("Allocated p0: %p\n", p0);
ffffffffc020091a:	85aa                	mv	a1,a0
ffffffffc020091c:	842a                	mv	s0,a0
ffffffffc020091e:	00001517          	auipc	a0,0x1
ffffffffc0200922:	01250513          	addi	a0,a0,18 # ffffffffc0201930 <etext+0x4fa>
ffffffffc0200926:	827ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc020092a:	ed7ff0ef          	jal	ra,ffffffffc0200800 <buddy_dump_free_pages>
    free_pages(p0, 16383);
ffffffffc020092e:	fff48593          	addi	a1,s1,-1
ffffffffc0200932:	8522                	mv	a0,s0
ffffffffc0200934:	ca9ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    
    assert((p1 = alloc_pages(8191)) != NULL);
ffffffffc0200938:	6409                	lui	s0,0x2
ffffffffc020093a:	fff40513          	addi	a0,s0,-1 # 1fff <kern_entry-0xffffffffc01fe001>
ffffffffc020093e:	c93ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200942:	84aa                	mv	s1,a0
ffffffffc0200944:	1c050d63          	beqz	a0,ffffffffc0200b1e <buddy_check+0x22e>
    cprintf("Allocated p1: 8191\n", p1);
ffffffffc0200948:	85aa                	mv	a1,a0
ffffffffc020094a:	00001517          	auipc	a0,0x1
ffffffffc020094e:	02650513          	addi	a0,a0,38 # ffffffffc0201970 <etext+0x53a>
ffffffffc0200952:	ffaff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200956:	eabff0ef          	jal	ra,ffffffffc0200800 <buddy_dump_free_pages>
    assert((p2 = alloc_pages(8191)) != NULL);
ffffffffc020095a:	fff40513          	addi	a0,s0,-1
ffffffffc020095e:	c73ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200962:	892a                	mv	s2,a0
ffffffffc0200964:	18050d63          	beqz	a0,ffffffffc0200afe <buddy_check+0x20e>
    cprintf("Allocated p2: 8191\n", p2);
ffffffffc0200968:	85aa                	mv	a1,a0
ffffffffc020096a:	00001517          	auipc	a0,0x1
ffffffffc020096e:	04650513          	addi	a0,a0,70 # ffffffffc02019b0 <etext+0x57a>
ffffffffc0200972:	fdaff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200976:	e8bff0ef          	jal	ra,ffffffffc0200800 <buddy_dump_free_pages>
    assert((p3 = alloc_pages(8191)) != NULL);
ffffffffc020097a:	fff40513          	addi	a0,s0,-1
ffffffffc020097e:	c53ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200982:	89aa                	mv	s3,a0
ffffffffc0200984:	14050d63          	beqz	a0,ffffffffc0200ade <buddy_check+0x1ee>
    cprintf("Allocated p3: 8191\n", p3);
ffffffffc0200988:	85aa                	mv	a1,a0
ffffffffc020098a:	00001517          	auipc	a0,0x1
ffffffffc020098e:	06650513          	addi	a0,a0,102 # ffffffffc02019f0 <etext+0x5ba>
ffffffffc0200992:	fbaff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200996:	e6bff0ef          	jal	ra,ffffffffc0200800 <buddy_dump_free_pages>
    assert((p4 = alloc_pages(8191)) == NULL);
ffffffffc020099a:	fff40513          	addi	a0,s0,-1
ffffffffc020099e:	c33ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc02009a2:	10051e63          	bnez	a0,ffffffffc0200abe <buddy_check+0x1ce>
    cprintf("Attempted to allocate p4: 8191, expected NULL, got %p\n", p4);
ffffffffc02009a6:	4581                	li	a1,0
ffffffffc02009a8:	00001517          	auipc	a0,0x1
ffffffffc02009ac:	08850513          	addi	a0,a0,136 # ffffffffc0201a30 <etext+0x5fa>
ffffffffc02009b0:	f9cff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc02009b4:	e4dff0ef          	jal	ra,ffffffffc0200800 <buddy_dump_free_pages>


    free_pages(p1, 8191);
ffffffffc02009b8:	fff40593          	addi	a1,s0,-1
ffffffffc02009bc:	8526                	mv	a0,s1
ffffffffc02009be:	c1fff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(p2, 8191);
ffffffffc02009c2:	fff40593          	addi	a1,s0,-1
ffffffffc02009c6:	854a                	mv	a0,s2
ffffffffc02009c8:	c15ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(p3, 8191);
ffffffffc02009cc:	fff40593          	addi	a1,s0,-1
ffffffffc02009d0:	854e                	mv	a0,s3
ffffffffc02009d2:	c0bff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    
    cprintf("Freed p1, p2, p3:\n");
ffffffffc02009d6:	00001517          	auipc	a0,0x1
ffffffffc02009da:	09250513          	addi	a0,a0,146 # ffffffffc0201a68 <etext+0x632>
ffffffffc02009de:	f6eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc02009e2:	e1fff0ef          	jal	ra,ffffffffc0200800 <buddy_dump_free_pages>
    assert((p4 = alloc_pages(129)) != NULL);
ffffffffc02009e6:	08100513          	li	a0,129
ffffffffc02009ea:	be7ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc02009ee:	842a                	mv	s0,a0
ffffffffc02009f0:	c55d                	beqz	a0,ffffffffc0200a9e <buddy_check+0x1ae>
    cprintf("Allocated p4: 129\n", p4);
ffffffffc02009f2:	85aa                	mv	a1,a0
ffffffffc02009f4:	00001517          	auipc	a0,0x1
ffffffffc02009f8:	0ac50513          	addi	a0,a0,172 # ffffffffc0201aa0 <etext+0x66a>
ffffffffc02009fc:	f50ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200a00:	e01ff0ef          	jal	ra,ffffffffc0200800 <buddy_dump_free_pages>

    assert((p5 = alloc_pages(513)) != NULL);
ffffffffc0200a04:	20100513          	li	a0,513
ffffffffc0200a08:	bc9ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200a0c:	84aa                	mv	s1,a0
ffffffffc0200a0e:	c925                	beqz	a0,ffffffffc0200a7e <buddy_check+0x18e>
    cprintf("Allocated p5: 513\n", p5);
ffffffffc0200a10:	85aa                	mv	a1,a0
ffffffffc0200a12:	00001517          	auipc	a0,0x1
ffffffffc0200a16:	0c650513          	addi	a0,a0,198 # ffffffffc0201ad8 <etext+0x6a2>
ffffffffc0200a1a:	f32ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200a1e:	de3ff0ef          	jal	ra,ffffffffc0200800 <buddy_dump_free_pages>

    free_pages(p4, 129);
ffffffffc0200a22:	8522                	mv	a0,s0
ffffffffc0200a24:	08100593          	li	a1,129
ffffffffc0200a28:	bb5ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(p5, 513);
ffffffffc0200a2c:	20100593          	li	a1,513
ffffffffc0200a30:	8526                	mv	a0,s1
ffffffffc0200a32:	babff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    cprintf("Freed p4, p5:\n");
ffffffffc0200a36:	00001517          	auipc	a0,0x1
ffffffffc0200a3a:	0ba50513          	addi	a0,a0,186 # ffffffffc0201af0 <etext+0x6ba>
ffffffffc0200a3e:	f0eff0ef          	jal	ra,ffffffffc020014c <cprintf>
    buddy_dump_free_pages();
ffffffffc0200a42:	dbfff0ef          	jal	ra,ffffffffc0200800 <buddy_dump_free_pages>
    cprintf("buddy_check() succeeded!\n");



}
ffffffffc0200a46:	7402                	ld	s0,32(sp)
ffffffffc0200a48:	70a2                	ld	ra,40(sp)
ffffffffc0200a4a:	64e2                	ld	s1,24(sp)
ffffffffc0200a4c:	6942                	ld	s2,16(sp)
ffffffffc0200a4e:	69a2                	ld	s3,8(sp)
    cprintf("buddy_check() succeeded!\n");
ffffffffc0200a50:	00001517          	auipc	a0,0x1
ffffffffc0200a54:	0b050513          	addi	a0,a0,176 # ffffffffc0201b00 <etext+0x6ca>
}
ffffffffc0200a58:	6145                	addi	sp,sp,48
    cprintf("buddy_check() succeeded!\n");
ffffffffc0200a5a:	ef2ff06f          	j	ffffffffc020014c <cprintf>
    assert((p0 = alloc_pages(16383)) != NULL);
ffffffffc0200a5e:	00001697          	auipc	a3,0x1
ffffffffc0200a62:	e7a68693          	addi	a3,a3,-390 # ffffffffc02018d8 <etext+0x4a2>
ffffffffc0200a66:	00001617          	auipc	a2,0x1
ffffffffc0200a6a:	e9a60613          	addi	a2,a2,-358 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200a6e:	0f000593          	li	a1,240
ffffffffc0200a72:	00001517          	auipc	a0,0x1
ffffffffc0200a76:	ea650513          	addi	a0,a0,-346 # ffffffffc0201918 <etext+0x4e2>
ffffffffc0200a7a:	f48ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p5 = alloc_pages(513)) != NULL);
ffffffffc0200a7e:	00001697          	auipc	a3,0x1
ffffffffc0200a82:	03a68693          	addi	a3,a3,58 # ffffffffc0201ab8 <etext+0x682>
ffffffffc0200a86:	00001617          	auipc	a2,0x1
ffffffffc0200a8a:	e7a60613          	addi	a2,a2,-390 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200a8e:	10d00593          	li	a1,269
ffffffffc0200a92:	00001517          	auipc	a0,0x1
ffffffffc0200a96:	e8650513          	addi	a0,a0,-378 # ffffffffc0201918 <etext+0x4e2>
ffffffffc0200a9a:	f28ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p4 = alloc_pages(129)) != NULL);
ffffffffc0200a9e:	00001697          	auipc	a3,0x1
ffffffffc0200aa2:	fe268693          	addi	a3,a3,-30 # ffffffffc0201a80 <etext+0x64a>
ffffffffc0200aa6:	00001617          	auipc	a2,0x1
ffffffffc0200aaa:	e5a60613          	addi	a2,a2,-422 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200aae:	10900593          	li	a1,265
ffffffffc0200ab2:	00001517          	auipc	a0,0x1
ffffffffc0200ab6:	e6650513          	addi	a0,a0,-410 # ffffffffc0201918 <etext+0x4e2>
ffffffffc0200aba:	f08ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p4 = alloc_pages(8191)) == NULL);
ffffffffc0200abe:	00001697          	auipc	a3,0x1
ffffffffc0200ac2:	f4a68693          	addi	a3,a3,-182 # ffffffffc0201a08 <etext+0x5d2>
ffffffffc0200ac6:	00001617          	auipc	a2,0x1
ffffffffc0200aca:	e3a60613          	addi	a2,a2,-454 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200ace:	0fe00593          	li	a1,254
ffffffffc0200ad2:	00001517          	auipc	a0,0x1
ffffffffc0200ad6:	e4650513          	addi	a0,a0,-442 # ffffffffc0201918 <etext+0x4e2>
ffffffffc0200ada:	ee8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p3 = alloc_pages(8191)) != NULL);
ffffffffc0200ade:	00001697          	auipc	a3,0x1
ffffffffc0200ae2:	eea68693          	addi	a3,a3,-278 # ffffffffc02019c8 <etext+0x592>
ffffffffc0200ae6:	00001617          	auipc	a2,0x1
ffffffffc0200aea:	e1a60613          	addi	a2,a2,-486 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200aee:	0fb00593          	li	a1,251
ffffffffc0200af2:	00001517          	auipc	a0,0x1
ffffffffc0200af6:	e2650513          	addi	a0,a0,-474 # ffffffffc0201918 <etext+0x4e2>
ffffffffc0200afa:	ec8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_pages(8191)) != NULL);
ffffffffc0200afe:	00001697          	auipc	a3,0x1
ffffffffc0200b02:	e8a68693          	addi	a3,a3,-374 # ffffffffc0201988 <etext+0x552>
ffffffffc0200b06:	00001617          	auipc	a2,0x1
ffffffffc0200b0a:	dfa60613          	addi	a2,a2,-518 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200b0e:	0f800593          	li	a1,248
ffffffffc0200b12:	00001517          	auipc	a0,0x1
ffffffffc0200b16:	e0650513          	addi	a0,a0,-506 # ffffffffc0201918 <etext+0x4e2>
ffffffffc0200b1a:	ea8ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_pages(8191)) != NULL);
ffffffffc0200b1e:	00001697          	auipc	a3,0x1
ffffffffc0200b22:	e2a68693          	addi	a3,a3,-470 # ffffffffc0201948 <etext+0x512>
ffffffffc0200b26:	00001617          	auipc	a2,0x1
ffffffffc0200b2a:	dda60613          	addi	a2,a2,-550 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200b2e:	0f500593          	li	a1,245
ffffffffc0200b32:	00001517          	auipc	a0,0x1
ffffffffc0200b36:	de650513          	addi	a0,a0,-538 # ffffffffc0201918 <etext+0x4e2>
ffffffffc0200b3a:	e88ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200b3e <buddy_free_pages>:
    assert(n > 0);
ffffffffc0200b3e:	16058b63          	beqz	a1,ffffffffc0200cb4 <buddy_free_pages+0x176>
    while ((1UL << order) < n) {
ffffffffc0200b42:	4785                	li	a5,1
    size_t order = 0;
ffffffffc0200b44:	4601                	li	a2,0
    while ((1UL << order) < n) {
ffffffffc0200b46:	4685                	li	a3,1
ffffffffc0200b48:	14f58e63          	beq	a1,a5,ffffffffc0200ca4 <buddy_free_pages+0x166>
        order++;
ffffffffc0200b4c:	0605                	addi	a2,a2,1
    while ((1UL << order) < n) {
ffffffffc0200b4e:	00c697b3          	sll	a5,a3,a2
ffffffffc0200b52:	0006071b          	sext.w	a4,a2
ffffffffc0200b56:	feb7ebe3          	bltu	a5,a1,ffffffffc0200b4c <buddy_free_pages+0xe>
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0200b5a:	00161813          	slli	a6,a2,0x1
ffffffffc0200b5e:	00c805b3          	add	a1,a6,a2
ffffffffc0200b62:	00004697          	auipc	a3,0x4
ffffffffc0200b66:	4b668693          	addi	a3,a3,1206 # ffffffffc0205018 <free_areas>
ffffffffc0200b6a:	058e                	slli	a1,a1,0x3
ffffffffc0200b6c:	95b6                	add	a1,a1,a3
    total_free_pages += (1UL << order);
ffffffffc0200b6e:	00004e17          	auipc	t3,0x4
ffffffffc0200b72:	6e2e0e13          	addi	t3,t3,1762 # ffffffffc0205250 <total_free_pages>
ffffffffc0200b76:	000e3303          	ld	t1,0(t3)
    SetPageProperty(page);
ffffffffc0200b7a:	00853883          	ld	a7,8(a0)
    page->property = order;
ffffffffc0200b7e:	c918                	sw	a4,16(a0)
    total_free_pages += (1UL << order);
ffffffffc0200b80:	00f30733          	add	a4,t1,a5
    SetPageProperty(page);
ffffffffc0200b84:	0028e793          	ori	a5,a7,2
ffffffffc0200b88:	e51c                	sd	a5,8(a0)
    total_free_pages += (1UL << order);
ffffffffc0200b8a:	00ee3023          	sd	a4,0(t3)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0200b8e:	87ae                	mv	a5,a1
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200b90:	a029                	j	ffffffffc0200b9a <buddy_free_pages+0x5c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200b92:	fe878713          	addi	a4,a5,-24
        if (page < p) {
ffffffffc0200b96:	00e56563          	bltu	a0,a4,ffffffffc0200ba0 <buddy_free_pages+0x62>
ffffffffc0200b9a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200b9c:	feb79be3          	bne	a5,a1,ffffffffc0200b92 <buddy_free_pages+0x54>
    nr_free_for_order(order)++;
ffffffffc0200ba0:	00c80733          	add	a4,a6,a2
ffffffffc0200ba4:	070e                	slli	a4,a4,0x3
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200ba6:	0007b883          	ld	a7,0(a5)
ffffffffc0200baa:	9736                	add	a4,a4,a3
ffffffffc0200bac:	4b0c                	lw	a1,16(a4)
    list_add_before(le, &(page->page_link));
ffffffffc0200bae:	01850813          	addi	a6,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200bb2:	0107b023          	sd	a6,0(a5)
ffffffffc0200bb6:	0108b423          	sd	a6,8(a7)
    elm->next = next;
ffffffffc0200bba:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200bbc:	01153c23          	sd	a7,24(a0)
    nr_free_for_order(order)++;
ffffffffc0200bc0:	0015879b          	addiw	a5,a1,1
ffffffffc0200bc4:	cb1c                	sw	a5,16(a4)
    while (order < MAX_ORDER - 1) {
ffffffffc0200bc6:	47c9                	li	a5,18
ffffffffc0200bc8:	0cc7ed63          	bltu	a5,a2,ffffffffc0200ca2 <buddy_free_pages+0x164>
ffffffffc0200bcc:	00160713          	addi	a4,a2,1
ffffffffc0200bd0:	00171793          	slli	a5,a4,0x1
ffffffffc0200bd4:	97ba                	add	a5,a5,a4
ffffffffc0200bd6:	078e                	slli	a5,a5,0x3
    if (buddy_base == NULL) {
ffffffffc0200bd8:	00004597          	auipc	a1,0x4
ffffffffc0200bdc:	6685b583          	ld	a1,1640(a1) # ffffffffc0205240 <buddy_base>
    if (buddy_offset >= buddy_total_pages) {
ffffffffc0200be0:	00004e97          	auipc	t4,0x4
ffffffffc0200be4:	668ebe83          	ld	t4,1640(t4) # ffffffffc0205248 <buddy_total_pages>
ffffffffc0200be8:	96be                	add	a3,a3,a5
    size_t offset = page - buddy_base;
ffffffffc0200bea:	00001e17          	auipc	t3,0x1
ffffffffc0200bee:	206e3e03          	ld	t3,518(t3) # ffffffffc0201df0 <nbase+0x8>
    size_t buddy_offset = offset ^ (1UL << order);
ffffffffc0200bf2:	4305                	li	t1,1
    while (order < MAX_ORDER - 1) {
ffffffffc0200bf4:	48cd                	li	a7,19
    if (buddy_base == NULL) {
ffffffffc0200bf6:	c5d5                	beqz	a1,ffffffffc0200ca2 <buddy_free_pages+0x164>
    size_t offset = page - buddy_base;
ffffffffc0200bf8:	40b507b3          	sub	a5,a0,a1
ffffffffc0200bfc:	878d                	srai	a5,a5,0x3
ffffffffc0200bfe:	03c787b3          	mul	a5,a5,t3
    size_t buddy_offset = offset ^ (1UL << order);
ffffffffc0200c02:	00c31733          	sll	a4,t1,a2
ffffffffc0200c06:	8f3d                	xor	a4,a4,a5
    if (buddy_offset >= buddy_total_pages) {
ffffffffc0200c08:	09d77d63          	bgeu	a4,t4,ffffffffc0200ca2 <buddy_free_pages+0x164>
    return buddy_base + buddy_offset;
ffffffffc0200c0c:	00271793          	slli	a5,a4,0x2
ffffffffc0200c10:	97ba                	add	a5,a5,a4
ffffffffc0200c12:	078e                	slli	a5,a5,0x3
ffffffffc0200c14:	97ae                	add	a5,a5,a1
        if (buddy == NULL || !PageProperty(buddy) || buddy->property != order) {
ffffffffc0200c16:	6798                	ld	a4,8(a5)
ffffffffc0200c18:	8b09                	andi	a4,a4,2
ffffffffc0200c1a:	c741                	beqz	a4,ffffffffc0200ca2 <buddy_free_pages+0x164>
ffffffffc0200c1c:	0107e703          	lwu	a4,16(a5)
ffffffffc0200c20:	08c71163          	bne	a4,a2,ffffffffc0200ca2 <buddy_free_pages+0x164>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c24:	01853283          	ld	t0,24(a0)
ffffffffc0200c28:	02053f83          	ld	t6,32(a0)
        nr_free_for_order(order)--;
ffffffffc0200c2c:	ff86af03          	lw	t5,-8(a3)
        ClearPageProperty(page);
ffffffffc0200c30:	6518                	ld	a4,8(a0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c32:	01f2b423          	sd	t6,8(t0)
    next->prev = prev;
ffffffffc0200c36:	005fb023          	sd	t0,0(t6)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c3a:	0187b283          	ld	t0,24(a5)
ffffffffc0200c3e:	0207bf83          	ld	t6,32(a5)
        nr_free_for_order(order)--;
ffffffffc0200c42:	3f79                	addiw	t5,t5,-2
        ClearPageProperty(page);
ffffffffc0200c44:	9b75                	andi	a4,a4,-3
    prev->next = next;
ffffffffc0200c46:	01f2b423          	sd	t6,8(t0)
    next->prev = prev;
ffffffffc0200c4a:	005fb023          	sd	t0,0(t6)
        nr_free_for_order(order)--;
ffffffffc0200c4e:	ffe6ac23          	sw	t5,-8(a3)
        ClearPageProperty(page);
ffffffffc0200c52:	e518                	sd	a4,8(a0)
        ClearPageProperty(buddy);
ffffffffc0200c54:	6798                	ld	a4,8(a5)
ffffffffc0200c56:	9b75                	andi	a4,a4,-3
ffffffffc0200c58:	e798                	sd	a4,8(a5)
        if (buddy < page) {
ffffffffc0200c5a:	00a7f563          	bgeu	a5,a0,ffffffffc0200c64 <buddy_free_pages+0x126>
ffffffffc0200c5e:	853e                	mv	a0,a5
ffffffffc0200c60:	01878813          	addi	a6,a5,24
        SetPageProperty(page);
ffffffffc0200c64:	651c                	ld	a5,8(a0)
        order++;
ffffffffc0200c66:	0605                	addi	a2,a2,1
        page->property = order;
ffffffffc0200c68:	c910                	sw	a2,16(a0)
        SetPageProperty(page);
ffffffffc0200c6a:	0027e793          	ori	a5,a5,2
ffffffffc0200c6e:	e51c                	sd	a5,8(a0)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200c70:	87b6                	mv	a5,a3
ffffffffc0200c72:	a029                	j	ffffffffc0200c7c <buddy_free_pages+0x13e>
        struct Page *p = le2page(le, page_link);
ffffffffc0200c74:	fe878713          	addi	a4,a5,-24
        if (page < p) {
ffffffffc0200c78:	00e56563          	bltu	a0,a4,ffffffffc0200c82 <buddy_free_pages+0x144>
    return listelm->next;
ffffffffc0200c7c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200c7e:	fed79be3          	bne	a5,a3,ffffffffc0200c74 <buddy_free_pages+0x136>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200c82:	0007bf03          	ld	t5,0(a5)
    nr_free_for_order(order)++;
ffffffffc0200c86:	4a98                	lw	a4,16(a3)
    prev->next = next->prev = elm;
ffffffffc0200c88:	0107b023          	sd	a6,0(a5)
ffffffffc0200c8c:	010f3423          	sd	a6,8(t5)
    elm->next = next;
ffffffffc0200c90:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200c92:	01e53c23          	sd	t5,24(a0)
ffffffffc0200c96:	0017079b          	addiw	a5,a4,1
ffffffffc0200c9a:	ca9c                	sw	a5,16(a3)
    while (order < MAX_ORDER - 1) {
ffffffffc0200c9c:	06e1                	addi	a3,a3,24
ffffffffc0200c9e:	f5161ce3          	bne	a2,a7,ffffffffc0200bf6 <buddy_free_pages+0xb8>
ffffffffc0200ca2:	8082                	ret
    while ((1UL << order) < n) {
ffffffffc0200ca4:	00004697          	auipc	a3,0x4
ffffffffc0200ca8:	37468693          	addi	a3,a3,884 # ffffffffc0205018 <free_areas>
ffffffffc0200cac:	85b6                	mv	a1,a3
ffffffffc0200cae:	4701                	li	a4,0
ffffffffc0200cb0:	4801                	li	a6,0
ffffffffc0200cb2:	bd75                	j	ffffffffc0200b6e <buddy_free_pages+0x30>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200cb4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200cb6:	00001697          	auipc	a3,0x1
ffffffffc0200cba:	e6a68693          	addi	a3,a3,-406 # ffffffffc0201b20 <etext+0x6ea>
ffffffffc0200cbe:	00001617          	auipc	a2,0x1
ffffffffc0200cc2:	c4260613          	addi	a2,a2,-958 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200cc6:	0a800593          	li	a1,168
ffffffffc0200cca:	00001517          	auipc	a0,0x1
ffffffffc0200cce:	c4e50513          	addi	a0,a0,-946 # ffffffffc0201918 <etext+0x4e2>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200cd2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200cd4:	ceeff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200cd8 <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc0200cd8:	10050863          	beqz	a0,ffffffffc0200de8 <buddy_alloc_pages+0x110>
    if (total_free_pages < (1UL << order)) {
ffffffffc0200cdc:	00004297          	auipc	t0,0x4
ffffffffc0200ce0:	57428293          	addi	t0,t0,1396 # ffffffffc0205250 <total_free_pages>
    while ((1UL << order) < n) {
ffffffffc0200ce4:	4705                	li	a4,1
    if (total_free_pages < (1UL << order)) {
ffffffffc0200ce6:	0002bf83          	ld	t6,0(t0)
    size_t order = 0;
ffffffffc0200cea:	4801                	li	a6,0
    while ((1UL << order) < n) {
ffffffffc0200cec:	4785                	li	a5,1
ffffffffc0200cee:	0ee50963          	beq	a0,a4,ffffffffc0200de0 <buddy_alloc_pages+0x108>
        order++;
ffffffffc0200cf2:	0805                	addi	a6,a6,1
    while ((1UL << order) < n) {
ffffffffc0200cf4:	010798b3          	sll	a7,a5,a6
ffffffffc0200cf8:	fea8ede3          	bltu	a7,a0,ffffffffc0200cf2 <buddy_alloc_pages+0x1a>
    if (total_free_pages < (1UL << order)) {
ffffffffc0200cfc:	0d1fe063          	bltu	t6,a7,ffffffffc0200dbc <buddy_alloc_pages+0xe4>
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
ffffffffc0200d00:	47cd                	li	a5,19
ffffffffc0200d02:	0b07ef63          	bltu	a5,a6,ffffffffc0200dc0 <buddy_alloc_pages+0xe8>
ffffffffc0200d06:	00181793          	slli	a5,a6,0x1
ffffffffc0200d0a:	97c2                	add	a5,a5,a6
ffffffffc0200d0c:	00004617          	auipc	a2,0x4
ffffffffc0200d10:	30c60613          	addi	a2,a2,780 # ffffffffc0205018 <free_areas>
ffffffffc0200d14:	078e                	slli	a5,a5,0x3
ffffffffc0200d16:	97b2                	add	a5,a5,a2
    size_t order = 0;
ffffffffc0200d18:	85c2                	mv	a1,a6
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
ffffffffc0200d1a:	4751                	li	a4,20
ffffffffc0200d1c:	a029                	j	ffffffffc0200d26 <buddy_alloc_pages+0x4e>
ffffffffc0200d1e:	0585                	addi	a1,a1,1
ffffffffc0200d20:	07e1                	addi	a5,a5,24
ffffffffc0200d22:	08e58d63          	beq	a1,a4,ffffffffc0200dbc <buddy_alloc_pages+0xe4>
    return list->next == list;
ffffffffc0200d26:	0087b303          	ld	t1,8(a5)
        if (!list_empty(&free_list_for_order(current_order))) {
ffffffffc0200d2a:	fef30ae3          	beq	t1,a5,ffffffffc0200d1e <buddy_alloc_pages+0x46>
    nr_free_for_order(current_order)--;
ffffffffc0200d2e:	00159793          	slli	a5,a1,0x1
ffffffffc0200d32:	97ae                	add	a5,a5,a1
ffffffffc0200d34:	078e                	slli	a5,a5,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d36:	00833503          	ld	a0,8(t1)
ffffffffc0200d3a:	00f606b3          	add	a3,a2,a5
ffffffffc0200d3e:	00033e03          	ld	t3,0(t1)
ffffffffc0200d42:	4a98                	lw	a4,16(a3)
ffffffffc0200d44:	17a1                	addi	a5,a5,-24
    prev->next = next;
ffffffffc0200d46:	00ae3423          	sd	a0,8(t3)
    next->prev = prev;
ffffffffc0200d4a:	01c53023          	sd	t3,0(a0)
ffffffffc0200d4e:	377d                	addiw	a4,a4,-1
ffffffffc0200d50:	ca98                	sw	a4,16(a3)
    struct Page* page = le2page(le, page_link);
ffffffffc0200d52:	fe830513          	addi	a0,t1,-24
    while (current_order > order) {
ffffffffc0200d56:	963e                	add	a2,a2,a5
        struct Page* buddy = page + (1UL << current_order);
ffffffffc0200d58:	02800f13          	li	t5,40
    while (current_order > order) {
ffffffffc0200d5c:	04b87663          	bgeu	a6,a1,ffffffffc0200da8 <buddy_alloc_pages+0xd0>
        current_order--;
ffffffffc0200d60:	15fd                	addi	a1,a1,-1
        struct Page* buddy = page + (1UL << current_order);
ffffffffc0200d62:	00bf1733          	sll	a4,t5,a1
ffffffffc0200d66:	972a                	add	a4,a4,a0
        SetPageProperty(buddy);
ffffffffc0200d68:	6714                	ld	a3,8(a4)
        buddy->property = current_order;
ffffffffc0200d6a:	cb0c                	sw	a1,16(a4)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0200d6c:	87b2                	mv	a5,a2
        SetPageProperty(buddy);
ffffffffc0200d6e:	0026e693          	ori	a3,a3,2
ffffffffc0200d72:	e714                	sd	a3,8(a4)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200d74:	a029                	j	ffffffffc0200d7e <buddy_alloc_pages+0xa6>
        struct Page *p = le2page(le, page_link);
ffffffffc0200d76:	fe878693          	addi	a3,a5,-24
        if (page < p) {
ffffffffc0200d7a:	00d76563          	bltu	a4,a3,ffffffffc0200d84 <buddy_alloc_pages+0xac>
    return listelm->next;
ffffffffc0200d7e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200d80:	fec79be3          	bne	a5,a2,ffffffffc0200d76 <buddy_alloc_pages+0x9e>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200d84:	0007be03          	ld	t3,0(a5)
    nr_free_for_order(order)++;
ffffffffc0200d88:	4a14                	lw	a3,16(a2)
    list_add_before(le, &(page->page_link));
ffffffffc0200d8a:	01870e93          	addi	t4,a4,24
    prev->next = next->prev = elm;
ffffffffc0200d8e:	01d7b023          	sd	t4,0(a5)
ffffffffc0200d92:	01de3423          	sd	t4,8(t3)
    elm->next = next;
ffffffffc0200d96:	f31c                	sd	a5,32(a4)
    elm->prev = prev;
ffffffffc0200d98:	01c73c23          	sd	t3,24(a4)
    nr_free_for_order(order)++;
ffffffffc0200d9c:	0016879b          	addiw	a5,a3,1
ffffffffc0200da0:	ca1c                	sw	a5,16(a2)
    while (current_order > order) {
ffffffffc0200da2:	1621                	addi	a2,a2,-24
ffffffffc0200da4:	fb059ee3          	bne	a1,a6,ffffffffc0200d60 <buddy_alloc_pages+0x88>
    ClearPageProperty(page);
ffffffffc0200da8:	ff033783          	ld	a5,-16(t1)
    total_free_pages -= (1UL << order);
ffffffffc0200dac:	411f88b3          	sub	a7,t6,a7
ffffffffc0200db0:	0112b023          	sd	a7,0(t0)
    ClearPageProperty(page);
ffffffffc0200db4:	9bf5                	andi	a5,a5,-3
ffffffffc0200db6:	fef33823          	sd	a5,-16(t1)
    return page;
ffffffffc0200dba:	8082                	ret
        return NULL;
ffffffffc0200dbc:	4501                	li	a0,0
}
ffffffffc0200dbe:	8082                	ret
    if (current_order == MAX_ORDER) {
ffffffffc0200dc0:	47d1                	li	a5,20
ffffffffc0200dc2:	fef80de3          	beq	a6,a5,ffffffffc0200dbc <buddy_alloc_pages+0xe4>
    return listelm->next;
ffffffffc0200dc6:	00181793          	slli	a5,a6,0x1
ffffffffc0200dca:	97c2                	add	a5,a5,a6
ffffffffc0200dcc:	00004617          	auipc	a2,0x4
ffffffffc0200dd0:	24c60613          	addi	a2,a2,588 # ffffffffc0205018 <free_areas>
ffffffffc0200dd4:	078e                	slli	a5,a5,0x3
ffffffffc0200dd6:	97b2                	add	a5,a5,a2
ffffffffc0200dd8:	0087b303          	ld	t1,8(a5)
ffffffffc0200ddc:	85c2                	mv	a1,a6
ffffffffc0200dde:	bf81                	j	ffffffffc0200d2e <buddy_alloc_pages+0x56>
    if (total_free_pages < (1UL << order)) {
ffffffffc0200de0:	fc0f8ee3          	beqz	t6,ffffffffc0200dbc <buddy_alloc_pages+0xe4>
    while ((1UL << order) < n) {
ffffffffc0200de4:	4885                	li	a7,1
ffffffffc0200de6:	b705                	j	ffffffffc0200d06 <buddy_alloc_pages+0x2e>
buddy_alloc_pages(size_t n) {
ffffffffc0200de8:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200dea:	00001697          	auipc	a3,0x1
ffffffffc0200dee:	d3668693          	addi	a3,a3,-714 # ffffffffc0201b20 <etext+0x6ea>
ffffffffc0200df2:	00001617          	auipc	a2,0x1
ffffffffc0200df6:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200dfa:	07700593          	li	a1,119
ffffffffc0200dfe:	00001517          	auipc	a0,0x1
ffffffffc0200e02:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0201918 <etext+0x4e2>
buddy_alloc_pages(size_t n) {
ffffffffc0200e06:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200e08:	bbaff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200e0c <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200e0c:	1141                	addi	sp,sp,-16
ffffffffc0200e0e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200e10:	14058963          	beqz	a1,ffffffffc0200f62 <buddy_init_memmap+0x156>
    if (buddy_base == NULL) {
ffffffffc0200e14:	00004617          	auipc	a2,0x4
ffffffffc0200e18:	42c60613          	addi	a2,a2,1068 # ffffffffc0205240 <buddy_base>
ffffffffc0200e1c:	621c                	ld	a5,0(a2)
ffffffffc0200e1e:	10078c63          	beqz	a5,ffffffffc0200f36 <buddy_init_memmap+0x12a>
        assert(base >= buddy_base);
ffffffffc0200e22:	16f56063          	bltu	a0,a5,ffffffffc0200f82 <buddy_init_memmap+0x176>
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200e26:	00259693          	slli	a3,a1,0x2
ffffffffc0200e2a:	96ae                	add	a3,a3,a1
ffffffffc0200e2c:	068e                	slli	a3,a3,0x3
ffffffffc0200e2e:	96aa                	add	a3,a3,a0
ffffffffc0200e30:	87aa                	mv	a5,a0
ffffffffc0200e32:	02d57063          	bgeu	a0,a3,ffffffffc0200e52 <buddy_init_memmap+0x46>
        assert(PageReserved(p));
ffffffffc0200e36:	6798                	ld	a4,8(a5)
ffffffffc0200e38:	8b05                	andi	a4,a4,1
ffffffffc0200e3a:	10070463          	beqz	a4,ffffffffc0200f42 <buddy_init_memmap+0x136>
        p->flags = 0;
ffffffffc0200e3e:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0200e42:	0007a823          	sw	zero,16(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200e46:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc0200e4a:	02878793          	addi	a5,a5,40
ffffffffc0200e4e:	fed7e4e3          	bltu	a5,a3,ffffffffc0200e36 <buddy_init_memmap+0x2a>
    size_t base_offset = base - buddy_base;
ffffffffc0200e52:	00063f83          	ld	t6,0(a2)
ffffffffc0200e56:	00001697          	auipc	a3,0x1
ffffffffc0200e5a:	f9a6b683          	ld	a3,-102(a3) # ffffffffc0201df0 <nbase+0x8>
    total_free_pages += n;
ffffffffc0200e5e:	00004717          	auipc	a4,0x4
ffffffffc0200e62:	3f270713          	addi	a4,a4,1010 # ffffffffc0205250 <total_free_pages>
    size_t base_offset = base - buddy_base;
ffffffffc0200e66:	41f50fb3          	sub	t6,a0,t6
ffffffffc0200e6a:	403fdf93          	srai	t6,t6,0x3
ffffffffc0200e6e:	02df8fb3          	mul	t6,t6,a3
    total_free_pages += n;
ffffffffc0200e72:	631c                	ld	a5,0(a4)
    size_t offset = 0;
ffffffffc0200e74:	4e81                	li	t4,0
ffffffffc0200e76:	00004f17          	auipc	t5,0x4
ffffffffc0200e7a:	1a2f0f13          	addi	t5,t5,418 # ffffffffc0205018 <free_areas>
    total_free_pages += n;
ffffffffc0200e7e:	97ae                	add	a5,a5,a1
ffffffffc0200e80:	e31c                	sd	a5,0(a4)
            size_t block_size = 1UL << (order + 1);
ffffffffc0200e82:	4305                	li	t1,1
        while (order + 1 < MAX_ORDER) {
ffffffffc0200e84:	4e4d                	li	t3,19
        size_t remaining = n - offset;
ffffffffc0200e86:	41d586b3          	sub	a3,a1,t4
ffffffffc0200e8a:	4701                	li	a4,0
            size_t global_offset = base_offset + offset;
ffffffffc0200e8c:	01df8833          	add	a6,t6,t4
            size_t block_size = 1UL << (order + 1);
ffffffffc0200e90:	0017079b          	addiw	a5,a4,1
ffffffffc0200e94:	00f317b3          	sll	a5,t1,a5
            if (block_size > remaining) {
ffffffffc0200e98:	0007061b          	sext.w	a2,a4
ffffffffc0200e9c:	08f6e563          	bltu	a3,a5,ffffffffc0200f26 <buddy_init_memmap+0x11a>
            if (global_offset & (block_size - 1)) {
ffffffffc0200ea0:	17fd                	addi	a5,a5,-1
ffffffffc0200ea2:	0107f7b3          	and	a5,a5,a6
ffffffffc0200ea6:	e3c1                	bnez	a5,ffffffffc0200f26 <buddy_init_memmap+0x11a>
        while (order + 1 < MAX_ORDER) {
ffffffffc0200ea8:	0705                	addi	a4,a4,1
ffffffffc0200eaa:	ffc713e3          	bne	a4,t3,ffffffffc0200e90 <buddy_init_memmap+0x84>
ffffffffc0200eae:	000802b7          	lui	t0,0x80
ffffffffc0200eb2:	464d                	li	a2,19
ffffffffc0200eb4:	1c800813          	li	a6,456
ffffffffc0200eb8:	00171893          	slli	a7,a4,0x1
        struct Page* page = base + offset;
ffffffffc0200ebc:	002e9693          	slli	a3,t4,0x2
ffffffffc0200ec0:	96f6                	add	a3,a3,t4
ffffffffc0200ec2:	068e                	slli	a3,a3,0x3
ffffffffc0200ec4:	96aa                	add	a3,a3,a0
        SetPageProperty(page);
ffffffffc0200ec6:	669c                	ld	a5,8(a3)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0200ec8:	987a                	add	a6,a6,t5
        page->property = order;
ffffffffc0200eca:	ca90                	sw	a2,16(a3)
        SetPageProperty(page);
ffffffffc0200ecc:	0027e793          	ori	a5,a5,2
ffffffffc0200ed0:	e69c                	sd	a5,8(a3)
    list_entry_t *le = &free_list_for_order(order);
ffffffffc0200ed2:	87c2                	mv	a5,a6
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200ed4:	a029                	j	ffffffffc0200ede <buddy_init_memmap+0xd2>
        struct Page *p = le2page(le, page_link);
ffffffffc0200ed6:	fe878613          	addi	a2,a5,-24
        if (page < p) {
ffffffffc0200eda:	00c6e563          	bltu	a3,a2,ffffffffc0200ee4 <buddy_init_memmap+0xd8>
ffffffffc0200ede:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list_for_order(order)) {
ffffffffc0200ee0:	fef81be3          	bne	a6,a5,ffffffffc0200ed6 <buddy_init_memmap+0xca>
    nr_free_for_order(order)++;
ffffffffc0200ee4:	9746                	add	a4,a4,a7
ffffffffc0200ee6:	070e                	slli	a4,a4,0x3
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200ee8:	0007b803          	ld	a6,0(a5)
ffffffffc0200eec:	977a                	add	a4,a4,t5
ffffffffc0200eee:	4b10                	lw	a2,16(a4)
    list_add_before(le, &(page->page_link));
ffffffffc0200ef0:	01868893          	addi	a7,a3,24
    prev->next = next->prev = elm;
ffffffffc0200ef4:	0117b023          	sd	a7,0(a5)
ffffffffc0200ef8:	01183423          	sd	a7,8(a6)
    elm->next = next;
ffffffffc0200efc:	f29c                	sd	a5,32(a3)
    elm->prev = prev;
ffffffffc0200efe:	0106bc23          	sd	a6,24(a3)
    nr_free_for_order(order)++;
ffffffffc0200f02:	0016079b          	addiw	a5,a2,1
ffffffffc0200f06:	cb1c                	sw	a5,16(a4)
        offset += (1UL << order);
ffffffffc0200f08:	9e96                	add	t4,t4,t0
    while (offset < n) {
ffffffffc0200f0a:	f6beeee3          	bltu	t4,a1,ffffffffc0200e86 <buddy_init_memmap+0x7a>
    if (new_total > buddy_total_pages) {
ffffffffc0200f0e:	00004797          	auipc	a5,0x4
ffffffffc0200f12:	33a78793          	addi	a5,a5,826 # ffffffffc0205248 <buddy_total_pages>
ffffffffc0200f16:	6398                	ld	a4,0(a5)
    size_t new_total = base_offset + n;
ffffffffc0200f18:	95fe                	add	a1,a1,t6
    if (new_total > buddy_total_pages) {
ffffffffc0200f1a:	00b77363          	bgeu	a4,a1,ffffffffc0200f20 <buddy_init_memmap+0x114>
        buddy_total_pages = new_total;
ffffffffc0200f1e:	e38c                	sd	a1,0(a5)
}
ffffffffc0200f20:	60a2                	ld	ra,8(sp)
ffffffffc0200f22:	0141                	addi	sp,sp,16
ffffffffc0200f24:	8082                	ret
ffffffffc0200f26:	00171893          	slli	a7,a4,0x1
ffffffffc0200f2a:	00e88833          	add	a6,a7,a4
ffffffffc0200f2e:	080e                	slli	a6,a6,0x3
        offset += (1UL << order);
ffffffffc0200f30:	00c312b3          	sll	t0,t1,a2
ffffffffc0200f34:	b761                	j	ffffffffc0200ebc <buddy_init_memmap+0xb0>
        buddy_base = base;
ffffffffc0200f36:	e208                	sd	a0,0(a2)
        buddy_total_pages = 0;
ffffffffc0200f38:	00004797          	auipc	a5,0x4
ffffffffc0200f3c:	3007b823          	sd	zero,784(a5) # ffffffffc0205248 <buddy_total_pages>
ffffffffc0200f40:	b5dd                	j	ffffffffc0200e26 <buddy_init_memmap+0x1a>
        assert(PageReserved(p));
ffffffffc0200f42:	00001697          	auipc	a3,0x1
ffffffffc0200f46:	bfe68693          	addi	a3,a3,-1026 # ffffffffc0201b40 <etext+0x70a>
ffffffffc0200f4a:	00001617          	auipc	a2,0x1
ffffffffc0200f4e:	9b660613          	addi	a2,a2,-1610 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200f52:	04d00593          	li	a1,77
ffffffffc0200f56:	00001517          	auipc	a0,0x1
ffffffffc0200f5a:	9c250513          	addi	a0,a0,-1598 # ffffffffc0201918 <etext+0x4e2>
ffffffffc0200f5e:	a64ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0200f62:	00001697          	auipc	a3,0x1
ffffffffc0200f66:	bbe68693          	addi	a3,a3,-1090 # ffffffffc0201b20 <etext+0x6ea>
ffffffffc0200f6a:	00001617          	auipc	a2,0x1
ffffffffc0200f6e:	99660613          	addi	a2,a2,-1642 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200f72:	04400593          	li	a1,68
ffffffffc0200f76:	00001517          	auipc	a0,0x1
ffffffffc0200f7a:	9a250513          	addi	a0,a0,-1630 # ffffffffc0201918 <etext+0x4e2>
ffffffffc0200f7e:	a44ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        assert(base >= buddy_base);
ffffffffc0200f82:	00001697          	auipc	a3,0x1
ffffffffc0200f86:	ba668693          	addi	a3,a3,-1114 # ffffffffc0201b28 <etext+0x6f2>
ffffffffc0200f8a:	00001617          	auipc	a2,0x1
ffffffffc0200f8e:	97660613          	addi	a2,a2,-1674 # ffffffffc0201900 <etext+0x4ca>
ffffffffc0200f92:	04900593          	li	a1,73
ffffffffc0200f96:	00001517          	auipc	a0,0x1
ffffffffc0200f9a:	98250513          	addi	a0,a0,-1662 # ffffffffc0201918 <etext+0x4e2>
ffffffffc0200f9e:	a24ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200fa2 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0200fa2:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0200fa6:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0200fa8:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0200faa:	cb81                	beqz	a5,ffffffffc0200fba <strlen+0x18>
        cnt ++;
ffffffffc0200fac:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0200fae:	00a707b3          	add	a5,a4,a0
ffffffffc0200fb2:	0007c783          	lbu	a5,0(a5)
ffffffffc0200fb6:	fbfd                	bnez	a5,ffffffffc0200fac <strlen+0xa>
ffffffffc0200fb8:	8082                	ret
    }
    return cnt;
}
ffffffffc0200fba:	8082                	ret

ffffffffc0200fbc <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0200fbc:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200fbe:	e589                	bnez	a1,ffffffffc0200fc8 <strnlen+0xc>
ffffffffc0200fc0:	a811                	j	ffffffffc0200fd4 <strnlen+0x18>
        cnt ++;
ffffffffc0200fc2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0200fc4:	00f58863          	beq	a1,a5,ffffffffc0200fd4 <strnlen+0x18>
ffffffffc0200fc8:	00f50733          	add	a4,a0,a5
ffffffffc0200fcc:	00074703          	lbu	a4,0(a4)
ffffffffc0200fd0:	fb6d                	bnez	a4,ffffffffc0200fc2 <strnlen+0x6>
ffffffffc0200fd2:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0200fd4:	852e                	mv	a0,a1
ffffffffc0200fd6:	8082                	ret

ffffffffc0200fd8 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200fd8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0200fdc:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200fe0:	cb89                	beqz	a5,ffffffffc0200ff2 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0200fe2:	0505                	addi	a0,a0,1
ffffffffc0200fe4:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0200fe6:	fee789e3          	beq	a5,a4,ffffffffc0200fd8 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0200fea:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0200fee:	9d19                	subw	a0,a0,a4
ffffffffc0200ff0:	8082                	ret
ffffffffc0200ff2:	4501                	li	a0,0
ffffffffc0200ff4:	bfed                	j	ffffffffc0200fee <strcmp+0x16>

ffffffffc0200ff6 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0200ff6:	c20d                	beqz	a2,ffffffffc0201018 <strncmp+0x22>
ffffffffc0200ff8:	962e                	add	a2,a2,a1
ffffffffc0200ffa:	a031                	j	ffffffffc0201006 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0200ffc:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0200ffe:	00e79a63          	bne	a5,a4,ffffffffc0201012 <strncmp+0x1c>
ffffffffc0201002:	00b60b63          	beq	a2,a1,ffffffffc0201018 <strncmp+0x22>
ffffffffc0201006:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc020100a:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020100c:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201010:	f7f5                	bnez	a5,ffffffffc0200ffc <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201012:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201016:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201018:	4501                	li	a0,0
ffffffffc020101a:	8082                	ret

ffffffffc020101c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020101c:	ca01                	beqz	a2,ffffffffc020102c <memset+0x10>
ffffffffc020101e:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201020:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201022:	0785                	addi	a5,a5,1
ffffffffc0201024:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201028:	fec79de3          	bne	a5,a2,ffffffffc0201022 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020102c:	8082                	ret

ffffffffc020102e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020102e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201032:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201034:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201038:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020103a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020103e:	f022                	sd	s0,32(sp)
ffffffffc0201040:	ec26                	sd	s1,24(sp)
ffffffffc0201042:	e84a                	sd	s2,16(sp)
ffffffffc0201044:	f406                	sd	ra,40(sp)
ffffffffc0201046:	e44e                	sd	s3,8(sp)
ffffffffc0201048:	84aa                	mv	s1,a0
ffffffffc020104a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020104c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201050:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201052:	03067e63          	bgeu	a2,a6,ffffffffc020108e <printnum+0x60>
ffffffffc0201056:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201058:	00805763          	blez	s0,ffffffffc0201066 <printnum+0x38>
ffffffffc020105c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020105e:	85ca                	mv	a1,s2
ffffffffc0201060:	854e                	mv	a0,s3
ffffffffc0201062:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201064:	fc65                	bnez	s0,ffffffffc020105c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201066:	1a02                	slli	s4,s4,0x20
ffffffffc0201068:	00001797          	auipc	a5,0x1
ffffffffc020106c:	b3878793          	addi	a5,a5,-1224 # ffffffffc0201ba0 <buddy_pmm_manager+0x38>
ffffffffc0201070:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201074:	9a3e                	add	s4,s4,a5
}
ffffffffc0201076:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201078:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020107c:	70a2                	ld	ra,40(sp)
ffffffffc020107e:	69a2                	ld	s3,8(sp)
ffffffffc0201080:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201082:	85ca                	mv	a1,s2
ffffffffc0201084:	87a6                	mv	a5,s1
}
ffffffffc0201086:	6942                	ld	s2,16(sp)
ffffffffc0201088:	64e2                	ld	s1,24(sp)
ffffffffc020108a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020108c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020108e:	03065633          	divu	a2,a2,a6
ffffffffc0201092:	8722                	mv	a4,s0
ffffffffc0201094:	f9bff0ef          	jal	ra,ffffffffc020102e <printnum>
ffffffffc0201098:	b7f9                	j	ffffffffc0201066 <printnum+0x38>

ffffffffc020109a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020109a:	7119                	addi	sp,sp,-128
ffffffffc020109c:	f4a6                	sd	s1,104(sp)
ffffffffc020109e:	f0ca                	sd	s2,96(sp)
ffffffffc02010a0:	ecce                	sd	s3,88(sp)
ffffffffc02010a2:	e8d2                	sd	s4,80(sp)
ffffffffc02010a4:	e4d6                	sd	s5,72(sp)
ffffffffc02010a6:	e0da                	sd	s6,64(sp)
ffffffffc02010a8:	fc5e                	sd	s7,56(sp)
ffffffffc02010aa:	f06a                	sd	s10,32(sp)
ffffffffc02010ac:	fc86                	sd	ra,120(sp)
ffffffffc02010ae:	f8a2                	sd	s0,112(sp)
ffffffffc02010b0:	f862                	sd	s8,48(sp)
ffffffffc02010b2:	f466                	sd	s9,40(sp)
ffffffffc02010b4:	ec6e                	sd	s11,24(sp)
ffffffffc02010b6:	892a                	mv	s2,a0
ffffffffc02010b8:	84ae                	mv	s1,a1
ffffffffc02010ba:	8d32                	mv	s10,a2
ffffffffc02010bc:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010be:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02010c2:	5b7d                	li	s6,-1
ffffffffc02010c4:	00001a97          	auipc	s5,0x1
ffffffffc02010c8:	b10a8a93          	addi	s5,s5,-1264 # ffffffffc0201bd4 <buddy_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02010cc:	00001b97          	auipc	s7,0x1
ffffffffc02010d0:	ce4b8b93          	addi	s7,s7,-796 # ffffffffc0201db0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010d4:	000d4503          	lbu	a0,0(s10)
ffffffffc02010d8:	001d0413          	addi	s0,s10,1
ffffffffc02010dc:	01350a63          	beq	a0,s3,ffffffffc02010f0 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02010e0:	c121                	beqz	a0,ffffffffc0201120 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02010e2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010e4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02010e6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02010e8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02010ec:	ff351ae3          	bne	a0,s3,ffffffffc02010e0 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010f0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02010f4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02010f8:	4c81                	li	s9,0
ffffffffc02010fa:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02010fc:	5c7d                	li	s8,-1
ffffffffc02010fe:	5dfd                	li	s11,-1
ffffffffc0201100:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201104:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201106:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020110a:	0ff5f593          	zext.b	a1,a1
ffffffffc020110e:	00140d13          	addi	s10,s0,1
ffffffffc0201112:	04b56263          	bltu	a0,a1,ffffffffc0201156 <vprintfmt+0xbc>
ffffffffc0201116:	058a                	slli	a1,a1,0x2
ffffffffc0201118:	95d6                	add	a1,a1,s5
ffffffffc020111a:	4194                	lw	a3,0(a1)
ffffffffc020111c:	96d6                	add	a3,a3,s5
ffffffffc020111e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201120:	70e6                	ld	ra,120(sp)
ffffffffc0201122:	7446                	ld	s0,112(sp)
ffffffffc0201124:	74a6                	ld	s1,104(sp)
ffffffffc0201126:	7906                	ld	s2,96(sp)
ffffffffc0201128:	69e6                	ld	s3,88(sp)
ffffffffc020112a:	6a46                	ld	s4,80(sp)
ffffffffc020112c:	6aa6                	ld	s5,72(sp)
ffffffffc020112e:	6b06                	ld	s6,64(sp)
ffffffffc0201130:	7be2                	ld	s7,56(sp)
ffffffffc0201132:	7c42                	ld	s8,48(sp)
ffffffffc0201134:	7ca2                	ld	s9,40(sp)
ffffffffc0201136:	7d02                	ld	s10,32(sp)
ffffffffc0201138:	6de2                	ld	s11,24(sp)
ffffffffc020113a:	6109                	addi	sp,sp,128
ffffffffc020113c:	8082                	ret
            padc = '0';
ffffffffc020113e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201140:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201144:	846a                	mv	s0,s10
ffffffffc0201146:	00140d13          	addi	s10,s0,1
ffffffffc020114a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020114e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201152:	fcb572e3          	bgeu	a0,a1,ffffffffc0201116 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201156:	85a6                	mv	a1,s1
ffffffffc0201158:	02500513          	li	a0,37
ffffffffc020115c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020115e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201162:	8d22                	mv	s10,s0
ffffffffc0201164:	f73788e3          	beq	a5,s3,ffffffffc02010d4 <vprintfmt+0x3a>
ffffffffc0201168:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020116c:	1d7d                	addi	s10,s10,-1
ffffffffc020116e:	ff379de3          	bne	a5,s3,ffffffffc0201168 <vprintfmt+0xce>
ffffffffc0201172:	b78d                	j	ffffffffc02010d4 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201174:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201178:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020117c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020117e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201182:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201186:	02d86463          	bltu	a6,a3,ffffffffc02011ae <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020118a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020118e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201192:	0186873b          	addw	a4,a3,s8
ffffffffc0201196:	0017171b          	slliw	a4,a4,0x1
ffffffffc020119a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020119c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02011a0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02011a2:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02011a6:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02011aa:	fed870e3          	bgeu	a6,a3,ffffffffc020118a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02011ae:	f40ddce3          	bgez	s11,ffffffffc0201106 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02011b2:	8de2                	mv	s11,s8
ffffffffc02011b4:	5c7d                	li	s8,-1
ffffffffc02011b6:	bf81                	j	ffffffffc0201106 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02011b8:	fffdc693          	not	a3,s11
ffffffffc02011bc:	96fd                	srai	a3,a3,0x3f
ffffffffc02011be:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011c2:	00144603          	lbu	a2,1(s0)
ffffffffc02011c6:	2d81                	sext.w	s11,s11
ffffffffc02011c8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011ca:	bf35                	j	ffffffffc0201106 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02011cc:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011d0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02011d4:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011d6:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02011d8:	bfd9                	j	ffffffffc02011ae <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02011da:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011dc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02011e0:	01174463          	blt	a4,a7,ffffffffc02011e8 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02011e4:	1a088e63          	beqz	a7,ffffffffc02013a0 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02011e8:	000a3603          	ld	a2,0(s4)
ffffffffc02011ec:	46c1                	li	a3,16
ffffffffc02011ee:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02011f0:	2781                	sext.w	a5,a5
ffffffffc02011f2:	876e                	mv	a4,s11
ffffffffc02011f4:	85a6                	mv	a1,s1
ffffffffc02011f6:	854a                	mv	a0,s2
ffffffffc02011f8:	e37ff0ef          	jal	ra,ffffffffc020102e <printnum>
            break;
ffffffffc02011fc:	bde1                	j	ffffffffc02010d4 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02011fe:	000a2503          	lw	a0,0(s4)
ffffffffc0201202:	85a6                	mv	a1,s1
ffffffffc0201204:	0a21                	addi	s4,s4,8
ffffffffc0201206:	9902                	jalr	s2
            break;
ffffffffc0201208:	b5f1                	j	ffffffffc02010d4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020120a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020120c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201210:	01174463          	blt	a4,a7,ffffffffc0201218 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201214:	18088163          	beqz	a7,ffffffffc0201396 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201218:	000a3603          	ld	a2,0(s4)
ffffffffc020121c:	46a9                	li	a3,10
ffffffffc020121e:	8a2e                	mv	s4,a1
ffffffffc0201220:	bfc1                	j	ffffffffc02011f0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201222:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201226:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201228:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020122a:	bdf1                	j	ffffffffc0201106 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020122c:	85a6                	mv	a1,s1
ffffffffc020122e:	02500513          	li	a0,37
ffffffffc0201232:	9902                	jalr	s2
            break;
ffffffffc0201234:	b545                	j	ffffffffc02010d4 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201236:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020123a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020123c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020123e:	b5e1                	j	ffffffffc0201106 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201240:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201242:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201246:	01174463          	blt	a4,a7,ffffffffc020124e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020124a:	14088163          	beqz	a7,ffffffffc020138c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020124e:	000a3603          	ld	a2,0(s4)
ffffffffc0201252:	46a1                	li	a3,8
ffffffffc0201254:	8a2e                	mv	s4,a1
ffffffffc0201256:	bf69                	j	ffffffffc02011f0 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201258:	03000513          	li	a0,48
ffffffffc020125c:	85a6                	mv	a1,s1
ffffffffc020125e:	e03e                	sd	a5,0(sp)
ffffffffc0201260:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201262:	85a6                	mv	a1,s1
ffffffffc0201264:	07800513          	li	a0,120
ffffffffc0201268:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020126a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020126c:	6782                	ld	a5,0(sp)
ffffffffc020126e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201270:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201274:	bfb5                	j	ffffffffc02011f0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201276:	000a3403          	ld	s0,0(s4)
ffffffffc020127a:	008a0713          	addi	a4,s4,8
ffffffffc020127e:	e03a                	sd	a4,0(sp)
ffffffffc0201280:	14040263          	beqz	s0,ffffffffc02013c4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201284:	0fb05763          	blez	s11,ffffffffc0201372 <vprintfmt+0x2d8>
ffffffffc0201288:	02d00693          	li	a3,45
ffffffffc020128c:	0cd79163          	bne	a5,a3,ffffffffc020134e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201290:	00044783          	lbu	a5,0(s0)
ffffffffc0201294:	0007851b          	sext.w	a0,a5
ffffffffc0201298:	cf85                	beqz	a5,ffffffffc02012d0 <vprintfmt+0x236>
ffffffffc020129a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020129e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012a2:	000c4563          	bltz	s8,ffffffffc02012ac <vprintfmt+0x212>
ffffffffc02012a6:	3c7d                	addiw	s8,s8,-1
ffffffffc02012a8:	036c0263          	beq	s8,s6,ffffffffc02012cc <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02012ac:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02012ae:	0e0c8e63          	beqz	s9,ffffffffc02013aa <vprintfmt+0x310>
ffffffffc02012b2:	3781                	addiw	a5,a5,-32
ffffffffc02012b4:	0ef47b63          	bgeu	s0,a5,ffffffffc02013aa <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02012b8:	03f00513          	li	a0,63
ffffffffc02012bc:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012be:	000a4783          	lbu	a5,0(s4)
ffffffffc02012c2:	3dfd                	addiw	s11,s11,-1
ffffffffc02012c4:	0a05                	addi	s4,s4,1
ffffffffc02012c6:	0007851b          	sext.w	a0,a5
ffffffffc02012ca:	ffe1                	bnez	a5,ffffffffc02012a2 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02012cc:	01b05963          	blez	s11,ffffffffc02012de <vprintfmt+0x244>
ffffffffc02012d0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02012d2:	85a6                	mv	a1,s1
ffffffffc02012d4:	02000513          	li	a0,32
ffffffffc02012d8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02012da:	fe0d9be3          	bnez	s11,ffffffffc02012d0 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02012de:	6a02                	ld	s4,0(sp)
ffffffffc02012e0:	bbd5                	j	ffffffffc02010d4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02012e2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012e4:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02012e8:	01174463          	blt	a4,a7,ffffffffc02012f0 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02012ec:	08088d63          	beqz	a7,ffffffffc0201386 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02012f0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02012f4:	0a044d63          	bltz	s0,ffffffffc02013ae <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02012f8:	8622                	mv	a2,s0
ffffffffc02012fa:	8a66                	mv	s4,s9
ffffffffc02012fc:	46a9                	li	a3,10
ffffffffc02012fe:	bdcd                	j	ffffffffc02011f0 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201300:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201304:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201306:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201308:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020130c:	8fb5                	xor	a5,a5,a3
ffffffffc020130e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201312:	02d74163          	blt	a4,a3,ffffffffc0201334 <vprintfmt+0x29a>
ffffffffc0201316:	00369793          	slli	a5,a3,0x3
ffffffffc020131a:	97de                	add	a5,a5,s7
ffffffffc020131c:	639c                	ld	a5,0(a5)
ffffffffc020131e:	cb99                	beqz	a5,ffffffffc0201334 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201320:	86be                	mv	a3,a5
ffffffffc0201322:	00001617          	auipc	a2,0x1
ffffffffc0201326:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0201bd0 <buddy_pmm_manager+0x68>
ffffffffc020132a:	85a6                	mv	a1,s1
ffffffffc020132c:	854a                	mv	a0,s2
ffffffffc020132e:	0ce000ef          	jal	ra,ffffffffc02013fc <printfmt>
ffffffffc0201332:	b34d                	j	ffffffffc02010d4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201334:	00001617          	auipc	a2,0x1
ffffffffc0201338:	88c60613          	addi	a2,a2,-1908 # ffffffffc0201bc0 <buddy_pmm_manager+0x58>
ffffffffc020133c:	85a6                	mv	a1,s1
ffffffffc020133e:	854a                	mv	a0,s2
ffffffffc0201340:	0bc000ef          	jal	ra,ffffffffc02013fc <printfmt>
ffffffffc0201344:	bb41                	j	ffffffffc02010d4 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201346:	00001417          	auipc	s0,0x1
ffffffffc020134a:	87240413          	addi	s0,s0,-1934 # ffffffffc0201bb8 <buddy_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020134e:	85e2                	mv	a1,s8
ffffffffc0201350:	8522                	mv	a0,s0
ffffffffc0201352:	e43e                	sd	a5,8(sp)
ffffffffc0201354:	c69ff0ef          	jal	ra,ffffffffc0200fbc <strnlen>
ffffffffc0201358:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020135c:	01b05b63          	blez	s11,ffffffffc0201372 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201360:	67a2                	ld	a5,8(sp)
ffffffffc0201362:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201366:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201368:	85a6                	mv	a1,s1
ffffffffc020136a:	8552                	mv	a0,s4
ffffffffc020136c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020136e:	fe0d9ce3          	bnez	s11,ffffffffc0201366 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201372:	00044783          	lbu	a5,0(s0)
ffffffffc0201376:	00140a13          	addi	s4,s0,1
ffffffffc020137a:	0007851b          	sext.w	a0,a5
ffffffffc020137e:	d3a5                	beqz	a5,ffffffffc02012de <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201380:	05e00413          	li	s0,94
ffffffffc0201384:	bf39                	j	ffffffffc02012a2 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201386:	000a2403          	lw	s0,0(s4)
ffffffffc020138a:	b7ad                	j	ffffffffc02012f4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020138c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201390:	46a1                	li	a3,8
ffffffffc0201392:	8a2e                	mv	s4,a1
ffffffffc0201394:	bdb1                	j	ffffffffc02011f0 <vprintfmt+0x156>
ffffffffc0201396:	000a6603          	lwu	a2,0(s4)
ffffffffc020139a:	46a9                	li	a3,10
ffffffffc020139c:	8a2e                	mv	s4,a1
ffffffffc020139e:	bd89                	j	ffffffffc02011f0 <vprintfmt+0x156>
ffffffffc02013a0:	000a6603          	lwu	a2,0(s4)
ffffffffc02013a4:	46c1                	li	a3,16
ffffffffc02013a6:	8a2e                	mv	s4,a1
ffffffffc02013a8:	b5a1                	j	ffffffffc02011f0 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02013aa:	9902                	jalr	s2
ffffffffc02013ac:	bf09                	j	ffffffffc02012be <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02013ae:	85a6                	mv	a1,s1
ffffffffc02013b0:	02d00513          	li	a0,45
ffffffffc02013b4:	e03e                	sd	a5,0(sp)
ffffffffc02013b6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02013b8:	6782                	ld	a5,0(sp)
ffffffffc02013ba:	8a66                	mv	s4,s9
ffffffffc02013bc:	40800633          	neg	a2,s0
ffffffffc02013c0:	46a9                	li	a3,10
ffffffffc02013c2:	b53d                	j	ffffffffc02011f0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02013c4:	03b05163          	blez	s11,ffffffffc02013e6 <vprintfmt+0x34c>
ffffffffc02013c8:	02d00693          	li	a3,45
ffffffffc02013cc:	f6d79de3          	bne	a5,a3,ffffffffc0201346 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02013d0:	00000417          	auipc	s0,0x0
ffffffffc02013d4:	7e840413          	addi	s0,s0,2024 # ffffffffc0201bb8 <buddy_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013d8:	02800793          	li	a5,40
ffffffffc02013dc:	02800513          	li	a0,40
ffffffffc02013e0:	00140a13          	addi	s4,s0,1
ffffffffc02013e4:	bd6d                	j	ffffffffc020129e <vprintfmt+0x204>
ffffffffc02013e6:	00000a17          	auipc	s4,0x0
ffffffffc02013ea:	7d3a0a13          	addi	s4,s4,2003 # ffffffffc0201bb9 <buddy_pmm_manager+0x51>
ffffffffc02013ee:	02800513          	li	a0,40
ffffffffc02013f2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013f6:	05e00413          	li	s0,94
ffffffffc02013fa:	b565                	j	ffffffffc02012a2 <vprintfmt+0x208>

ffffffffc02013fc <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02013fc:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02013fe:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201402:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201404:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201406:	ec06                	sd	ra,24(sp)
ffffffffc0201408:	f83a                	sd	a4,48(sp)
ffffffffc020140a:	fc3e                	sd	a5,56(sp)
ffffffffc020140c:	e0c2                	sd	a6,64(sp)
ffffffffc020140e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201410:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201412:	c89ff0ef          	jal	ra,ffffffffc020109a <vprintfmt>
}
ffffffffc0201416:	60e2                	ld	ra,24(sp)
ffffffffc0201418:	6161                	addi	sp,sp,80
ffffffffc020141a:	8082                	ret

ffffffffc020141c <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc020141c:	4781                	li	a5,0
ffffffffc020141e:	00004717          	auipc	a4,0x4
ffffffffc0201422:	bf273703          	ld	a4,-1038(a4) # ffffffffc0205010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201426:	88ba                	mv	a7,a4
ffffffffc0201428:	852a                	mv	a0,a0
ffffffffc020142a:	85be                	mv	a1,a5
ffffffffc020142c:	863e                	mv	a2,a5
ffffffffc020142e:	00000073          	ecall
ffffffffc0201432:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201434:	8082                	ret
