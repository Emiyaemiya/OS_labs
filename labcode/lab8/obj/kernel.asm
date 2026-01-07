
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	00014297          	auipc	t0,0x14
ffffffffc0200004:	00028293          	mv	t0,t0
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0214000 <boot_hartid>
ffffffffc020000c:	00014297          	auipc	t0,0x14
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0214008 <boot_dtb>
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
ffffffffc0200018:	c02132b7          	lui	t0,0xc0213
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
ffffffffc0200034:	18029073          	csrw	satp,t0
ffffffffc0200038:	12000073          	sfence.vma
ffffffffc020003c:	c0213137          	lui	sp,0xc0213
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
ffffffffc020004a:	00091517          	auipc	a0,0x91
ffffffffc020004e:	01650513          	addi	a0,a0,22 # ffffffffc0291060 <buf>
ffffffffc0200052:	00097617          	auipc	a2,0x97
ffffffffc0200056:	90660613          	addi	a2,a2,-1786 # ffffffffc0296958 <end>
ffffffffc020005a:	1141                	addi	sp,sp,-16
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
ffffffffc0200060:	e406                	sd	ra,8(sp)
ffffffffc0200062:	2ca0b0ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc0200066:	209000ef          	jal	ra,ffffffffc0200a6e <cons_init>
ffffffffc020006a:	0000b597          	auipc	a1,0xb
ffffffffc020006e:	7be58593          	addi	a1,a1,1982 # ffffffffc020b828 <etext>
ffffffffc0200072:	0000b517          	auipc	a0,0xb
ffffffffc0200076:	7d650513          	addi	a0,a0,2006 # ffffffffc020b848 <etext+0x20>
ffffffffc020007a:	0b0000ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020007e:	25c000ef          	jal	ra,ffffffffc02002da <print_kerninfo>
ffffffffc0200082:	4ca000ef          	jal	ra,ffffffffc020054c <dtb_init>
ffffffffc0200086:	3c7010ef          	jal	ra,ffffffffc0201c4c <pmm_init>
ffffffffc020008a:	2ff000ef          	jal	ra,ffffffffc0200b88 <pic_init>
ffffffffc020008e:	519000ef          	jal	ra,ffffffffc0200da6 <idt_init>
ffffffffc0200092:	162030ef          	jal	ra,ffffffffc02031f4 <vmm_init>
ffffffffc0200096:	4ba070ef          	jal	ra,ffffffffc0207550 <sched_init>
ffffffffc020009a:	7d5060ef          	jal	ra,ffffffffc020706e <proc_init>
ffffffffc020009e:	2ed000ef          	jal	ra,ffffffffc0200b8a <ide_init>
ffffffffc02000a2:	02f050ef          	jal	ra,ffffffffc02058d0 <fs_init>
ffffffffc02000a6:	17f000ef          	jal	ra,ffffffffc0200a24 <clock_init>
ffffffffc02000aa:	4f1000ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02000ae:	18c070ef          	jal	ra,ffffffffc020723a <cpu_idle>

ffffffffc02000b2 <strdup>:
ffffffffc02000b2:	1101                	addi	sp,sp,-32
ffffffffc02000b4:	ec06                	sd	ra,24(sp)
ffffffffc02000b6:	e822                	sd	s0,16(sp)
ffffffffc02000b8:	e426                	sd	s1,8(sp)
ffffffffc02000ba:	e04a                	sd	s2,0(sp)
ffffffffc02000bc:	892a                	mv	s2,a0
ffffffffc02000be:	1cc0b0ef          	jal	ra,ffffffffc020b28a <strlen>
ffffffffc02000c2:	842a                	mv	s0,a0
ffffffffc02000c4:	0505                	addi	a0,a0,1
ffffffffc02000c6:	00b030ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc02000ca:	84aa                	mv	s1,a0
ffffffffc02000cc:	c901                	beqz	a0,ffffffffc02000dc <strdup+0x2a>
ffffffffc02000ce:	8622                	mv	a2,s0
ffffffffc02000d0:	85ca                	mv	a1,s2
ffffffffc02000d2:	9426                	add	s0,s0,s1
ffffffffc02000d4:	2aa0b0ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc02000d8:	00040023          	sb	zero,0(s0)
ffffffffc02000dc:	60e2                	ld	ra,24(sp)
ffffffffc02000de:	6442                	ld	s0,16(sp)
ffffffffc02000e0:	6902                	ld	s2,0(sp)
ffffffffc02000e2:	8526                	mv	a0,s1
ffffffffc02000e4:	64a2                	ld	s1,8(sp)
ffffffffc02000e6:	6105                	addi	sp,sp,32
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputch>:
ffffffffc02000ea:	1141                	addi	sp,sp,-16
ffffffffc02000ec:	e022                	sd	s0,0(sp)
ffffffffc02000ee:	e406                	sd	ra,8(sp)
ffffffffc02000f0:	842e                	mv	s0,a1
ffffffffc02000f2:	18b000ef          	jal	ra,ffffffffc0200a7c <cons_putc>
ffffffffc02000f6:	401c                	lw	a5,0(s0)
ffffffffc02000f8:	60a2                	ld	ra,8(sp)
ffffffffc02000fa:	2785                	addiw	a5,a5,1
ffffffffc02000fc:	c01c                	sw	a5,0(s0)
ffffffffc02000fe:	6402                	ld	s0,0(sp)
ffffffffc0200100:	0141                	addi	sp,sp,16
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <vcprintf>:
ffffffffc0200104:	1101                	addi	sp,sp,-32
ffffffffc0200106:	872e                	mv	a4,a1
ffffffffc0200108:	75dd                	lui	a1,0xffff7
ffffffffc020010a:	86aa                	mv	a3,a0
ffffffffc020010c:	0070                	addi	a2,sp,12
ffffffffc020010e:	00000517          	auipc	a0,0x0
ffffffffc0200112:	fdc50513          	addi	a0,a0,-36 # ffffffffc02000ea <cputch>
ffffffffc0200116:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd60181>
ffffffffc020011a:	ec06                	sd	ra,24(sp)
ffffffffc020011c:	c602                	sw	zero,12(sp)
ffffffffc020011e:	3080b0ef          	jal	ra,ffffffffc020b426 <vprintfmt>
ffffffffc0200122:	60e2                	ld	ra,24(sp)
ffffffffc0200124:	4532                	lw	a0,12(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret

ffffffffc020012a <cprintf>:
ffffffffc020012a:	711d                	addi	sp,sp,-96
ffffffffc020012c:	02810313          	addi	t1,sp,40 # ffffffffc0213028 <boot_page_table_sv39+0x28>
ffffffffc0200130:	8e2a                	mv	t3,a0
ffffffffc0200132:	f42e                	sd	a1,40(sp)
ffffffffc0200134:	75dd                	lui	a1,0xffff7
ffffffffc0200136:	f832                	sd	a2,48(sp)
ffffffffc0200138:	fc36                	sd	a3,56(sp)
ffffffffc020013a:	e0ba                	sd	a4,64(sp)
ffffffffc020013c:	00000517          	auipc	a0,0x0
ffffffffc0200140:	fae50513          	addi	a0,a0,-82 # ffffffffc02000ea <cputch>
ffffffffc0200144:	0050                	addi	a2,sp,4
ffffffffc0200146:	871a                	mv	a4,t1
ffffffffc0200148:	86f2                	mv	a3,t3
ffffffffc020014a:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd60181>
ffffffffc020014e:	ec06                	sd	ra,24(sp)
ffffffffc0200150:	e4be                	sd	a5,72(sp)
ffffffffc0200152:	e8c2                	sd	a6,80(sp)
ffffffffc0200154:	ecc6                	sd	a7,88(sp)
ffffffffc0200156:	e41a                	sd	t1,8(sp)
ffffffffc0200158:	c202                	sw	zero,4(sp)
ffffffffc020015a:	2cc0b0ef          	jal	ra,ffffffffc020b426 <vprintfmt>
ffffffffc020015e:	60e2                	ld	ra,24(sp)
ffffffffc0200160:	4512                	lw	a0,4(sp)
ffffffffc0200162:	6125                	addi	sp,sp,96
ffffffffc0200164:	8082                	ret

ffffffffc0200166 <cputchar>:
ffffffffc0200166:	1170006f          	j	ffffffffc0200a7c <cons_putc>

ffffffffc020016a <getchar>:
ffffffffc020016a:	1141                	addi	sp,sp,-16
ffffffffc020016c:	e406                	sd	ra,8(sp)
ffffffffc020016e:	163000ef          	jal	ra,ffffffffc0200ad0 <cons_getc>
ffffffffc0200172:	dd75                	beqz	a0,ffffffffc020016e <getchar+0x4>
ffffffffc0200174:	60a2                	ld	ra,8(sp)
ffffffffc0200176:	0141                	addi	sp,sp,16
ffffffffc0200178:	8082                	ret

ffffffffc020017a <readline>:
ffffffffc020017a:	715d                	addi	sp,sp,-80
ffffffffc020017c:	e486                	sd	ra,72(sp)
ffffffffc020017e:	e0a6                	sd	s1,64(sp)
ffffffffc0200180:	fc4a                	sd	s2,56(sp)
ffffffffc0200182:	f84e                	sd	s3,48(sp)
ffffffffc0200184:	f452                	sd	s4,40(sp)
ffffffffc0200186:	f056                	sd	s5,32(sp)
ffffffffc0200188:	ec5a                	sd	s6,24(sp)
ffffffffc020018a:	e85e                	sd	s7,16(sp)
ffffffffc020018c:	c901                	beqz	a0,ffffffffc020019c <readline+0x22>
ffffffffc020018e:	85aa                	mv	a1,a0
ffffffffc0200190:	0000b517          	auipc	a0,0xb
ffffffffc0200194:	6c050513          	addi	a0,a0,1728 # ffffffffc020b850 <etext+0x28>
ffffffffc0200198:	f93ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020019c:	4481                	li	s1,0
ffffffffc020019e:	497d                	li	s2,31
ffffffffc02001a0:	49a1                	li	s3,8
ffffffffc02001a2:	4aa9                	li	s5,10
ffffffffc02001a4:	4b35                	li	s6,13
ffffffffc02001a6:	00091b97          	auipc	s7,0x91
ffffffffc02001aa:	ebab8b93          	addi	s7,s7,-326 # ffffffffc0291060 <buf>
ffffffffc02001ae:	3fe00a13          	li	s4,1022
ffffffffc02001b2:	fb9ff0ef          	jal	ra,ffffffffc020016a <getchar>
ffffffffc02001b6:	00054a63          	bltz	a0,ffffffffc02001ca <readline+0x50>
ffffffffc02001ba:	00a95a63          	bge	s2,a0,ffffffffc02001ce <readline+0x54>
ffffffffc02001be:	029a5263          	bge	s4,s1,ffffffffc02001e2 <readline+0x68>
ffffffffc02001c2:	fa9ff0ef          	jal	ra,ffffffffc020016a <getchar>
ffffffffc02001c6:	fe055ae3          	bgez	a0,ffffffffc02001ba <readline+0x40>
ffffffffc02001ca:	4501                	li	a0,0
ffffffffc02001cc:	a091                	j	ffffffffc0200210 <readline+0x96>
ffffffffc02001ce:	03351463          	bne	a0,s3,ffffffffc02001f6 <readline+0x7c>
ffffffffc02001d2:	e8a9                	bnez	s1,ffffffffc0200224 <readline+0xaa>
ffffffffc02001d4:	f97ff0ef          	jal	ra,ffffffffc020016a <getchar>
ffffffffc02001d8:	fe0549e3          	bltz	a0,ffffffffc02001ca <readline+0x50>
ffffffffc02001dc:	fea959e3          	bge	s2,a0,ffffffffc02001ce <readline+0x54>
ffffffffc02001e0:	4481                	li	s1,0
ffffffffc02001e2:	e42a                	sd	a0,8(sp)
ffffffffc02001e4:	f83ff0ef          	jal	ra,ffffffffc0200166 <cputchar>
ffffffffc02001e8:	6522                	ld	a0,8(sp)
ffffffffc02001ea:	009b87b3          	add	a5,s7,s1
ffffffffc02001ee:	2485                	addiw	s1,s1,1
ffffffffc02001f0:	00a78023          	sb	a0,0(a5)
ffffffffc02001f4:	bf7d                	j	ffffffffc02001b2 <readline+0x38>
ffffffffc02001f6:	01550463          	beq	a0,s5,ffffffffc02001fe <readline+0x84>
ffffffffc02001fa:	fb651ce3          	bne	a0,s6,ffffffffc02001b2 <readline+0x38>
ffffffffc02001fe:	f69ff0ef          	jal	ra,ffffffffc0200166 <cputchar>
ffffffffc0200202:	00091517          	auipc	a0,0x91
ffffffffc0200206:	e5e50513          	addi	a0,a0,-418 # ffffffffc0291060 <buf>
ffffffffc020020a:	94aa                	add	s1,s1,a0
ffffffffc020020c:	00048023          	sb	zero,0(s1)
ffffffffc0200210:	60a6                	ld	ra,72(sp)
ffffffffc0200212:	6486                	ld	s1,64(sp)
ffffffffc0200214:	7962                	ld	s2,56(sp)
ffffffffc0200216:	79c2                	ld	s3,48(sp)
ffffffffc0200218:	7a22                	ld	s4,40(sp)
ffffffffc020021a:	7a82                	ld	s5,32(sp)
ffffffffc020021c:	6b62                	ld	s6,24(sp)
ffffffffc020021e:	6bc2                	ld	s7,16(sp)
ffffffffc0200220:	6161                	addi	sp,sp,80
ffffffffc0200222:	8082                	ret
ffffffffc0200224:	4521                	li	a0,8
ffffffffc0200226:	f41ff0ef          	jal	ra,ffffffffc0200166 <cputchar>
ffffffffc020022a:	34fd                	addiw	s1,s1,-1
ffffffffc020022c:	b759                	j	ffffffffc02001b2 <readline+0x38>

ffffffffc020022e <__panic>:
ffffffffc020022e:	00096317          	auipc	t1,0x96
ffffffffc0200232:	67a30313          	addi	t1,t1,1658 # ffffffffc02968a8 <is_panic>
ffffffffc0200236:	00033e03          	ld	t3,0(t1)
ffffffffc020023a:	715d                	addi	sp,sp,-80
ffffffffc020023c:	ec06                	sd	ra,24(sp)
ffffffffc020023e:	e822                	sd	s0,16(sp)
ffffffffc0200240:	f436                	sd	a3,40(sp)
ffffffffc0200242:	f83a                	sd	a4,48(sp)
ffffffffc0200244:	fc3e                	sd	a5,56(sp)
ffffffffc0200246:	e0c2                	sd	a6,64(sp)
ffffffffc0200248:	e4c6                	sd	a7,72(sp)
ffffffffc020024a:	020e1a63          	bnez	t3,ffffffffc020027e <__panic+0x50>
ffffffffc020024e:	4785                	li	a5,1
ffffffffc0200250:	00f33023          	sd	a5,0(t1)
ffffffffc0200254:	8432                	mv	s0,a2
ffffffffc0200256:	103c                	addi	a5,sp,40
ffffffffc0200258:	862e                	mv	a2,a1
ffffffffc020025a:	85aa                	mv	a1,a0
ffffffffc020025c:	0000b517          	auipc	a0,0xb
ffffffffc0200260:	5fc50513          	addi	a0,a0,1532 # ffffffffc020b858 <etext+0x30>
ffffffffc0200264:	e43e                	sd	a5,8(sp)
ffffffffc0200266:	ec5ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020026a:	65a2                	ld	a1,8(sp)
ffffffffc020026c:	8522                	mv	a0,s0
ffffffffc020026e:	e97ff0ef          	jal	ra,ffffffffc0200104 <vcprintf>
ffffffffc0200272:	0000c517          	auipc	a0,0xc
ffffffffc0200276:	65e50513          	addi	a0,a0,1630 # ffffffffc020c8d0 <commands+0xe00>
ffffffffc020027a:	eb1ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020027e:	4501                	li	a0,0
ffffffffc0200280:	4581                	li	a1,0
ffffffffc0200282:	4601                	li	a2,0
ffffffffc0200284:	48a1                	li	a7,8
ffffffffc0200286:	00000073          	ecall
ffffffffc020028a:	317000ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020028e:	4501                	li	a0,0
ffffffffc0200290:	174000ef          	jal	ra,ffffffffc0200404 <kmonitor>
ffffffffc0200294:	bfed                	j	ffffffffc020028e <__panic+0x60>

ffffffffc0200296 <__warn>:
ffffffffc0200296:	715d                	addi	sp,sp,-80
ffffffffc0200298:	832e                	mv	t1,a1
ffffffffc020029a:	e822                	sd	s0,16(sp)
ffffffffc020029c:	85aa                	mv	a1,a0
ffffffffc020029e:	8432                	mv	s0,a2
ffffffffc02002a0:	fc3e                	sd	a5,56(sp)
ffffffffc02002a2:	861a                	mv	a2,t1
ffffffffc02002a4:	103c                	addi	a5,sp,40
ffffffffc02002a6:	0000b517          	auipc	a0,0xb
ffffffffc02002aa:	5d250513          	addi	a0,a0,1490 # ffffffffc020b878 <etext+0x50>
ffffffffc02002ae:	ec06                	sd	ra,24(sp)
ffffffffc02002b0:	f436                	sd	a3,40(sp)
ffffffffc02002b2:	f83a                	sd	a4,48(sp)
ffffffffc02002b4:	e0c2                	sd	a6,64(sp)
ffffffffc02002b6:	e4c6                	sd	a7,72(sp)
ffffffffc02002b8:	e43e                	sd	a5,8(sp)
ffffffffc02002ba:	e71ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02002be:	65a2                	ld	a1,8(sp)
ffffffffc02002c0:	8522                	mv	a0,s0
ffffffffc02002c2:	e43ff0ef          	jal	ra,ffffffffc0200104 <vcprintf>
ffffffffc02002c6:	0000c517          	auipc	a0,0xc
ffffffffc02002ca:	60a50513          	addi	a0,a0,1546 # ffffffffc020c8d0 <commands+0xe00>
ffffffffc02002ce:	e5dff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02002d2:	60e2                	ld	ra,24(sp)
ffffffffc02002d4:	6442                	ld	s0,16(sp)
ffffffffc02002d6:	6161                	addi	sp,sp,80
ffffffffc02002d8:	8082                	ret

ffffffffc02002da <print_kerninfo>:
ffffffffc02002da:	1141                	addi	sp,sp,-16
ffffffffc02002dc:	0000b517          	auipc	a0,0xb
ffffffffc02002e0:	5bc50513          	addi	a0,a0,1468 # ffffffffc020b898 <etext+0x70>
ffffffffc02002e4:	e406                	sd	ra,8(sp)
ffffffffc02002e6:	e45ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02002ea:	00000597          	auipc	a1,0x0
ffffffffc02002ee:	d6058593          	addi	a1,a1,-672 # ffffffffc020004a <kern_init>
ffffffffc02002f2:	0000b517          	auipc	a0,0xb
ffffffffc02002f6:	5c650513          	addi	a0,a0,1478 # ffffffffc020b8b8 <etext+0x90>
ffffffffc02002fa:	e31ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02002fe:	0000b597          	auipc	a1,0xb
ffffffffc0200302:	52a58593          	addi	a1,a1,1322 # ffffffffc020b828 <etext>
ffffffffc0200306:	0000b517          	auipc	a0,0xb
ffffffffc020030a:	5d250513          	addi	a0,a0,1490 # ffffffffc020b8d8 <etext+0xb0>
ffffffffc020030e:	e1dff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200312:	00091597          	auipc	a1,0x91
ffffffffc0200316:	d4e58593          	addi	a1,a1,-690 # ffffffffc0291060 <buf>
ffffffffc020031a:	0000b517          	auipc	a0,0xb
ffffffffc020031e:	5de50513          	addi	a0,a0,1502 # ffffffffc020b8f8 <etext+0xd0>
ffffffffc0200322:	e09ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200326:	00096597          	auipc	a1,0x96
ffffffffc020032a:	63258593          	addi	a1,a1,1586 # ffffffffc0296958 <end>
ffffffffc020032e:	0000b517          	auipc	a0,0xb
ffffffffc0200332:	5ea50513          	addi	a0,a0,1514 # ffffffffc020b918 <etext+0xf0>
ffffffffc0200336:	df5ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020033a:	00097597          	auipc	a1,0x97
ffffffffc020033e:	a1d58593          	addi	a1,a1,-1507 # ffffffffc0296d57 <end+0x3ff>
ffffffffc0200342:	00000797          	auipc	a5,0x0
ffffffffc0200346:	d0878793          	addi	a5,a5,-760 # ffffffffc020004a <kern_init>
ffffffffc020034a:	40f587b3          	sub	a5,a1,a5
ffffffffc020034e:	43f7d593          	srai	a1,a5,0x3f
ffffffffc0200352:	60a2                	ld	ra,8(sp)
ffffffffc0200354:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200358:	95be                	add	a1,a1,a5
ffffffffc020035a:	85a9                	srai	a1,a1,0xa
ffffffffc020035c:	0000b517          	auipc	a0,0xb
ffffffffc0200360:	5dc50513          	addi	a0,a0,1500 # ffffffffc020b938 <etext+0x110>
ffffffffc0200364:	0141                	addi	sp,sp,16
ffffffffc0200366:	b3d1                	j	ffffffffc020012a <cprintf>

ffffffffc0200368 <print_stackframe>:
ffffffffc0200368:	1141                	addi	sp,sp,-16
ffffffffc020036a:	0000b617          	auipc	a2,0xb
ffffffffc020036e:	5fe60613          	addi	a2,a2,1534 # ffffffffc020b968 <etext+0x140>
ffffffffc0200372:	04e00593          	li	a1,78
ffffffffc0200376:	0000b517          	auipc	a0,0xb
ffffffffc020037a:	60a50513          	addi	a0,a0,1546 # ffffffffc020b980 <etext+0x158>
ffffffffc020037e:	e406                	sd	ra,8(sp)
ffffffffc0200380:	eafff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0200384 <mon_help>:
ffffffffc0200384:	1141                	addi	sp,sp,-16
ffffffffc0200386:	0000b617          	auipc	a2,0xb
ffffffffc020038a:	61260613          	addi	a2,a2,1554 # ffffffffc020b998 <etext+0x170>
ffffffffc020038e:	0000b597          	auipc	a1,0xb
ffffffffc0200392:	62a58593          	addi	a1,a1,1578 # ffffffffc020b9b8 <etext+0x190>
ffffffffc0200396:	0000b517          	auipc	a0,0xb
ffffffffc020039a:	62a50513          	addi	a0,a0,1578 # ffffffffc020b9c0 <etext+0x198>
ffffffffc020039e:	e406                	sd	ra,8(sp)
ffffffffc02003a0:	d8bff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02003a4:	0000b617          	auipc	a2,0xb
ffffffffc02003a8:	62c60613          	addi	a2,a2,1580 # ffffffffc020b9d0 <etext+0x1a8>
ffffffffc02003ac:	0000b597          	auipc	a1,0xb
ffffffffc02003b0:	64c58593          	addi	a1,a1,1612 # ffffffffc020b9f8 <etext+0x1d0>
ffffffffc02003b4:	0000b517          	auipc	a0,0xb
ffffffffc02003b8:	60c50513          	addi	a0,a0,1548 # ffffffffc020b9c0 <etext+0x198>
ffffffffc02003bc:	d6fff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02003c0:	0000b617          	auipc	a2,0xb
ffffffffc02003c4:	64860613          	addi	a2,a2,1608 # ffffffffc020ba08 <etext+0x1e0>
ffffffffc02003c8:	0000b597          	auipc	a1,0xb
ffffffffc02003cc:	66058593          	addi	a1,a1,1632 # ffffffffc020ba28 <etext+0x200>
ffffffffc02003d0:	0000b517          	auipc	a0,0xb
ffffffffc02003d4:	5f050513          	addi	a0,a0,1520 # ffffffffc020b9c0 <etext+0x198>
ffffffffc02003d8:	d53ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02003dc:	60a2                	ld	ra,8(sp)
ffffffffc02003de:	4501                	li	a0,0
ffffffffc02003e0:	0141                	addi	sp,sp,16
ffffffffc02003e2:	8082                	ret

ffffffffc02003e4 <mon_kerninfo>:
ffffffffc02003e4:	1141                	addi	sp,sp,-16
ffffffffc02003e6:	e406                	sd	ra,8(sp)
ffffffffc02003e8:	ef3ff0ef          	jal	ra,ffffffffc02002da <print_kerninfo>
ffffffffc02003ec:	60a2                	ld	ra,8(sp)
ffffffffc02003ee:	4501                	li	a0,0
ffffffffc02003f0:	0141                	addi	sp,sp,16
ffffffffc02003f2:	8082                	ret

ffffffffc02003f4 <mon_backtrace>:
ffffffffc02003f4:	1141                	addi	sp,sp,-16
ffffffffc02003f6:	e406                	sd	ra,8(sp)
ffffffffc02003f8:	f71ff0ef          	jal	ra,ffffffffc0200368 <print_stackframe>
ffffffffc02003fc:	60a2                	ld	ra,8(sp)
ffffffffc02003fe:	4501                	li	a0,0
ffffffffc0200400:	0141                	addi	sp,sp,16
ffffffffc0200402:	8082                	ret

ffffffffc0200404 <kmonitor>:
ffffffffc0200404:	7115                	addi	sp,sp,-224
ffffffffc0200406:	ed5e                	sd	s7,152(sp)
ffffffffc0200408:	8baa                	mv	s7,a0
ffffffffc020040a:	0000b517          	auipc	a0,0xb
ffffffffc020040e:	62e50513          	addi	a0,a0,1582 # ffffffffc020ba38 <etext+0x210>
ffffffffc0200412:	ed86                	sd	ra,216(sp)
ffffffffc0200414:	e9a2                	sd	s0,208(sp)
ffffffffc0200416:	e5a6                	sd	s1,200(sp)
ffffffffc0200418:	e1ca                	sd	s2,192(sp)
ffffffffc020041a:	fd4e                	sd	s3,184(sp)
ffffffffc020041c:	f952                	sd	s4,176(sp)
ffffffffc020041e:	f556                	sd	s5,168(sp)
ffffffffc0200420:	f15a                	sd	s6,160(sp)
ffffffffc0200422:	e962                	sd	s8,144(sp)
ffffffffc0200424:	e566                	sd	s9,136(sp)
ffffffffc0200426:	e16a                	sd	s10,128(sp)
ffffffffc0200428:	d03ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020042c:	0000b517          	auipc	a0,0xb
ffffffffc0200430:	63450513          	addi	a0,a0,1588 # ffffffffc020ba60 <etext+0x238>
ffffffffc0200434:	cf7ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200438:	000b8563          	beqz	s7,ffffffffc0200442 <kmonitor+0x3e>
ffffffffc020043c:	855e                	mv	a0,s7
ffffffffc020043e:	351000ef          	jal	ra,ffffffffc0200f8e <print_trapframe>
ffffffffc0200442:	0000bc17          	auipc	s8,0xb
ffffffffc0200446:	68ec0c13          	addi	s8,s8,1678 # ffffffffc020bad0 <commands>
ffffffffc020044a:	0000b917          	auipc	s2,0xb
ffffffffc020044e:	63e90913          	addi	s2,s2,1598 # ffffffffc020ba88 <etext+0x260>
ffffffffc0200452:	0000b497          	auipc	s1,0xb
ffffffffc0200456:	63e48493          	addi	s1,s1,1598 # ffffffffc020ba90 <etext+0x268>
ffffffffc020045a:	49bd                	li	s3,15
ffffffffc020045c:	0000bb17          	auipc	s6,0xb
ffffffffc0200460:	63cb0b13          	addi	s6,s6,1596 # ffffffffc020ba98 <etext+0x270>
ffffffffc0200464:	0000ba17          	auipc	s4,0xb
ffffffffc0200468:	554a0a13          	addi	s4,s4,1364 # ffffffffc020b9b8 <etext+0x190>
ffffffffc020046c:	4a8d                	li	s5,3
ffffffffc020046e:	854a                	mv	a0,s2
ffffffffc0200470:	d0bff0ef          	jal	ra,ffffffffc020017a <readline>
ffffffffc0200474:	842a                	mv	s0,a0
ffffffffc0200476:	dd65                	beqz	a0,ffffffffc020046e <kmonitor+0x6a>
ffffffffc0200478:	00054583          	lbu	a1,0(a0)
ffffffffc020047c:	4c81                	li	s9,0
ffffffffc020047e:	e1bd                	bnez	a1,ffffffffc02004e4 <kmonitor+0xe0>
ffffffffc0200480:	fe0c87e3          	beqz	s9,ffffffffc020046e <kmonitor+0x6a>
ffffffffc0200484:	6582                	ld	a1,0(sp)
ffffffffc0200486:	0000bd17          	auipc	s10,0xb
ffffffffc020048a:	64ad0d13          	addi	s10,s10,1610 # ffffffffc020bad0 <commands>
ffffffffc020048e:	8552                	mv	a0,s4
ffffffffc0200490:	4401                	li	s0,0
ffffffffc0200492:	0d61                	addi	s10,s10,24
ffffffffc0200494:	63f0a0ef          	jal	ra,ffffffffc020b2d2 <strcmp>
ffffffffc0200498:	c919                	beqz	a0,ffffffffc02004ae <kmonitor+0xaa>
ffffffffc020049a:	2405                	addiw	s0,s0,1
ffffffffc020049c:	0b540063          	beq	s0,s5,ffffffffc020053c <kmonitor+0x138>
ffffffffc02004a0:	000d3503          	ld	a0,0(s10)
ffffffffc02004a4:	6582                	ld	a1,0(sp)
ffffffffc02004a6:	0d61                	addi	s10,s10,24
ffffffffc02004a8:	62b0a0ef          	jal	ra,ffffffffc020b2d2 <strcmp>
ffffffffc02004ac:	f57d                	bnez	a0,ffffffffc020049a <kmonitor+0x96>
ffffffffc02004ae:	00141793          	slli	a5,s0,0x1
ffffffffc02004b2:	97a2                	add	a5,a5,s0
ffffffffc02004b4:	078e                	slli	a5,a5,0x3
ffffffffc02004b6:	97e2                	add	a5,a5,s8
ffffffffc02004b8:	6b9c                	ld	a5,16(a5)
ffffffffc02004ba:	865e                	mv	a2,s7
ffffffffc02004bc:	002c                	addi	a1,sp,8
ffffffffc02004be:	fffc851b          	addiw	a0,s9,-1
ffffffffc02004c2:	9782                	jalr	a5
ffffffffc02004c4:	fa0555e3          	bgez	a0,ffffffffc020046e <kmonitor+0x6a>
ffffffffc02004c8:	60ee                	ld	ra,216(sp)
ffffffffc02004ca:	644e                	ld	s0,208(sp)
ffffffffc02004cc:	64ae                	ld	s1,200(sp)
ffffffffc02004ce:	690e                	ld	s2,192(sp)
ffffffffc02004d0:	79ea                	ld	s3,184(sp)
ffffffffc02004d2:	7a4a                	ld	s4,176(sp)
ffffffffc02004d4:	7aaa                	ld	s5,168(sp)
ffffffffc02004d6:	7b0a                	ld	s6,160(sp)
ffffffffc02004d8:	6bea                	ld	s7,152(sp)
ffffffffc02004da:	6c4a                	ld	s8,144(sp)
ffffffffc02004dc:	6caa                	ld	s9,136(sp)
ffffffffc02004de:	6d0a                	ld	s10,128(sp)
ffffffffc02004e0:	612d                	addi	sp,sp,224
ffffffffc02004e2:	8082                	ret
ffffffffc02004e4:	8526                	mv	a0,s1
ffffffffc02004e6:	6310a0ef          	jal	ra,ffffffffc020b316 <strchr>
ffffffffc02004ea:	c901                	beqz	a0,ffffffffc02004fa <kmonitor+0xf6>
ffffffffc02004ec:	00144583          	lbu	a1,1(s0)
ffffffffc02004f0:	00040023          	sb	zero,0(s0)
ffffffffc02004f4:	0405                	addi	s0,s0,1
ffffffffc02004f6:	d5c9                	beqz	a1,ffffffffc0200480 <kmonitor+0x7c>
ffffffffc02004f8:	b7f5                	j	ffffffffc02004e4 <kmonitor+0xe0>
ffffffffc02004fa:	00044783          	lbu	a5,0(s0)
ffffffffc02004fe:	d3c9                	beqz	a5,ffffffffc0200480 <kmonitor+0x7c>
ffffffffc0200500:	033c8963          	beq	s9,s3,ffffffffc0200532 <kmonitor+0x12e>
ffffffffc0200504:	003c9793          	slli	a5,s9,0x3
ffffffffc0200508:	0118                	addi	a4,sp,128
ffffffffc020050a:	97ba                	add	a5,a5,a4
ffffffffc020050c:	f887b023          	sd	s0,-128(a5)
ffffffffc0200510:	00044583          	lbu	a1,0(s0)
ffffffffc0200514:	2c85                	addiw	s9,s9,1
ffffffffc0200516:	e591                	bnez	a1,ffffffffc0200522 <kmonitor+0x11e>
ffffffffc0200518:	b7b5                	j	ffffffffc0200484 <kmonitor+0x80>
ffffffffc020051a:	00144583          	lbu	a1,1(s0)
ffffffffc020051e:	0405                	addi	s0,s0,1
ffffffffc0200520:	d1a5                	beqz	a1,ffffffffc0200480 <kmonitor+0x7c>
ffffffffc0200522:	8526                	mv	a0,s1
ffffffffc0200524:	5f30a0ef          	jal	ra,ffffffffc020b316 <strchr>
ffffffffc0200528:	d96d                	beqz	a0,ffffffffc020051a <kmonitor+0x116>
ffffffffc020052a:	00044583          	lbu	a1,0(s0)
ffffffffc020052e:	d9a9                	beqz	a1,ffffffffc0200480 <kmonitor+0x7c>
ffffffffc0200530:	bf55                	j	ffffffffc02004e4 <kmonitor+0xe0>
ffffffffc0200532:	45c1                	li	a1,16
ffffffffc0200534:	855a                	mv	a0,s6
ffffffffc0200536:	bf5ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020053a:	b7e9                	j	ffffffffc0200504 <kmonitor+0x100>
ffffffffc020053c:	6582                	ld	a1,0(sp)
ffffffffc020053e:	0000b517          	auipc	a0,0xb
ffffffffc0200542:	57a50513          	addi	a0,a0,1402 # ffffffffc020bab8 <etext+0x290>
ffffffffc0200546:	be5ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020054a:	b715                	j	ffffffffc020046e <kmonitor+0x6a>

ffffffffc020054c <dtb_init>:
ffffffffc020054c:	7119                	addi	sp,sp,-128
ffffffffc020054e:	0000b517          	auipc	a0,0xb
ffffffffc0200552:	5ca50513          	addi	a0,a0,1482 # ffffffffc020bb18 <commands+0x48>
ffffffffc0200556:	fc86                	sd	ra,120(sp)
ffffffffc0200558:	f8a2                	sd	s0,112(sp)
ffffffffc020055a:	e8d2                	sd	s4,80(sp)
ffffffffc020055c:	f4a6                	sd	s1,104(sp)
ffffffffc020055e:	f0ca                	sd	s2,96(sp)
ffffffffc0200560:	ecce                	sd	s3,88(sp)
ffffffffc0200562:	e4d6                	sd	s5,72(sp)
ffffffffc0200564:	e0da                	sd	s6,64(sp)
ffffffffc0200566:	fc5e                	sd	s7,56(sp)
ffffffffc0200568:	f862                	sd	s8,48(sp)
ffffffffc020056a:	f466                	sd	s9,40(sp)
ffffffffc020056c:	f06a                	sd	s10,32(sp)
ffffffffc020056e:	ec6e                	sd	s11,24(sp)
ffffffffc0200570:	bbbff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200574:	00014597          	auipc	a1,0x14
ffffffffc0200578:	a8c5b583          	ld	a1,-1396(a1) # ffffffffc0214000 <boot_hartid>
ffffffffc020057c:	0000b517          	auipc	a0,0xb
ffffffffc0200580:	5ac50513          	addi	a0,a0,1452 # ffffffffc020bb28 <commands+0x58>
ffffffffc0200584:	ba7ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200588:	00014417          	auipc	s0,0x14
ffffffffc020058c:	a8040413          	addi	s0,s0,-1408 # ffffffffc0214008 <boot_dtb>
ffffffffc0200590:	600c                	ld	a1,0(s0)
ffffffffc0200592:	0000b517          	auipc	a0,0xb
ffffffffc0200596:	5a650513          	addi	a0,a0,1446 # ffffffffc020bb38 <commands+0x68>
ffffffffc020059a:	b91ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020059e:	00043a03          	ld	s4,0(s0)
ffffffffc02005a2:	0000b517          	auipc	a0,0xb
ffffffffc02005a6:	5ae50513          	addi	a0,a0,1454 # ffffffffc020bb50 <commands+0x80>
ffffffffc02005aa:	120a0463          	beqz	s4,ffffffffc02006d2 <dtb_init+0x186>
ffffffffc02005ae:	57f5                	li	a5,-3
ffffffffc02005b0:	07fa                	slli	a5,a5,0x1e
ffffffffc02005b2:	00fa0733          	add	a4,s4,a5
ffffffffc02005b6:	431c                	lw	a5,0(a4)
ffffffffc02005b8:	00ff0637          	lui	a2,0xff0
ffffffffc02005bc:	6b41                	lui	s6,0x10
ffffffffc02005be:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005c2:	0187969b          	slliw	a3,a5,0x18
ffffffffc02005c6:	0187d51b          	srliw	a0,a5,0x18
ffffffffc02005ca:	0105959b          	slliw	a1,a1,0x10
ffffffffc02005ce:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02005d2:	8df1                	and	a1,a1,a2
ffffffffc02005d4:	8ec9                	or	a3,a3,a0
ffffffffc02005d6:	0087979b          	slliw	a5,a5,0x8
ffffffffc02005da:	1b7d                	addi	s6,s6,-1
ffffffffc02005dc:	0167f7b3          	and	a5,a5,s6
ffffffffc02005e0:	8dd5                	or	a1,a1,a3
ffffffffc02005e2:	8ddd                	or	a1,a1,a5
ffffffffc02005e4:	d00e07b7          	lui	a5,0xd00e0
ffffffffc02005e8:	2581                	sext.w	a1,a1
ffffffffc02005ea:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe49595>
ffffffffc02005ee:	10f59163          	bne	a1,a5,ffffffffc02006f0 <dtb_init+0x1a4>
ffffffffc02005f2:	471c                	lw	a5,8(a4)
ffffffffc02005f4:	4754                	lw	a3,12(a4)
ffffffffc02005f6:	4c81                	li	s9,0
ffffffffc02005f8:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005fc:	0086d51b          	srliw	a0,a3,0x8
ffffffffc0200600:	0186941b          	slliw	s0,a3,0x18
ffffffffc0200604:	0186d89b          	srliw	a7,a3,0x18
ffffffffc0200608:	01879a1b          	slliw	s4,a5,0x18
ffffffffc020060c:	0187d81b          	srliw	a6,a5,0x18
ffffffffc0200610:	0105151b          	slliw	a0,a0,0x10
ffffffffc0200614:	0106d69b          	srliw	a3,a3,0x10
ffffffffc0200618:	0105959b          	slliw	a1,a1,0x10
ffffffffc020061c:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200620:	8d71                	and	a0,a0,a2
ffffffffc0200622:	01146433          	or	s0,s0,a7
ffffffffc0200626:	0086969b          	slliw	a3,a3,0x8
ffffffffc020062a:	010a6a33          	or	s4,s4,a6
ffffffffc020062e:	8e6d                	and	a2,a2,a1
ffffffffc0200630:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200634:	8c49                	or	s0,s0,a0
ffffffffc0200636:	0166f6b3          	and	a3,a3,s6
ffffffffc020063a:	00ca6a33          	or	s4,s4,a2
ffffffffc020063e:	0167f7b3          	and	a5,a5,s6
ffffffffc0200642:	8c55                	or	s0,s0,a3
ffffffffc0200644:	00fa6a33          	or	s4,s4,a5
ffffffffc0200648:	1402                	slli	s0,s0,0x20
ffffffffc020064a:	1a02                	slli	s4,s4,0x20
ffffffffc020064c:	9001                	srli	s0,s0,0x20
ffffffffc020064e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200652:	943a                	add	s0,s0,a4
ffffffffc0200654:	9a3a                	add	s4,s4,a4
ffffffffc0200656:	00ff0c37          	lui	s8,0xff0
ffffffffc020065a:	4b8d                	li	s7,3
ffffffffc020065c:	0000b917          	auipc	s2,0xb
ffffffffc0200660:	54490913          	addi	s2,s2,1348 # ffffffffc020bba0 <commands+0xd0>
ffffffffc0200664:	49bd                	li	s3,15
ffffffffc0200666:	4d91                	li	s11,4
ffffffffc0200668:	4d05                	li	s10,1
ffffffffc020066a:	0000b497          	auipc	s1,0xb
ffffffffc020066e:	52e48493          	addi	s1,s1,1326 # ffffffffc020bb98 <commands+0xc8>
ffffffffc0200672:	000a2703          	lw	a4,0(s4)
ffffffffc0200676:	004a0a93          	addi	s5,s4,4
ffffffffc020067a:	0087569b          	srliw	a3,a4,0x8
ffffffffc020067e:	0187179b          	slliw	a5,a4,0x18
ffffffffc0200682:	0187561b          	srliw	a2,a4,0x18
ffffffffc0200686:	0106969b          	slliw	a3,a3,0x10
ffffffffc020068a:	0107571b          	srliw	a4,a4,0x10
ffffffffc020068e:	8fd1                	or	a5,a5,a2
ffffffffc0200690:	0186f6b3          	and	a3,a3,s8
ffffffffc0200694:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200698:	8fd5                	or	a5,a5,a3
ffffffffc020069a:	00eb7733          	and	a4,s6,a4
ffffffffc020069e:	8fd9                	or	a5,a5,a4
ffffffffc02006a0:	2781                	sext.w	a5,a5
ffffffffc02006a2:	09778c63          	beq	a5,s7,ffffffffc020073a <dtb_init+0x1ee>
ffffffffc02006a6:	00fbea63          	bltu	s7,a5,ffffffffc02006ba <dtb_init+0x16e>
ffffffffc02006aa:	07a78663          	beq	a5,s10,ffffffffc0200716 <dtb_init+0x1ca>
ffffffffc02006ae:	4709                	li	a4,2
ffffffffc02006b0:	00e79763          	bne	a5,a4,ffffffffc02006be <dtb_init+0x172>
ffffffffc02006b4:	4c81                	li	s9,0
ffffffffc02006b6:	8a56                	mv	s4,s5
ffffffffc02006b8:	bf6d                	j	ffffffffc0200672 <dtb_init+0x126>
ffffffffc02006ba:	ffb78ee3          	beq	a5,s11,ffffffffc02006b6 <dtb_init+0x16a>
ffffffffc02006be:	0000b517          	auipc	a0,0xb
ffffffffc02006c2:	55a50513          	addi	a0,a0,1370 # ffffffffc020bc18 <commands+0x148>
ffffffffc02006c6:	a65ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02006ca:	0000b517          	auipc	a0,0xb
ffffffffc02006ce:	58650513          	addi	a0,a0,1414 # ffffffffc020bc50 <commands+0x180>
ffffffffc02006d2:	7446                	ld	s0,112(sp)
ffffffffc02006d4:	70e6                	ld	ra,120(sp)
ffffffffc02006d6:	74a6                	ld	s1,104(sp)
ffffffffc02006d8:	7906                	ld	s2,96(sp)
ffffffffc02006da:	69e6                	ld	s3,88(sp)
ffffffffc02006dc:	6a46                	ld	s4,80(sp)
ffffffffc02006de:	6aa6                	ld	s5,72(sp)
ffffffffc02006e0:	6b06                	ld	s6,64(sp)
ffffffffc02006e2:	7be2                	ld	s7,56(sp)
ffffffffc02006e4:	7c42                	ld	s8,48(sp)
ffffffffc02006e6:	7ca2                	ld	s9,40(sp)
ffffffffc02006e8:	7d02                	ld	s10,32(sp)
ffffffffc02006ea:	6de2                	ld	s11,24(sp)
ffffffffc02006ec:	6109                	addi	sp,sp,128
ffffffffc02006ee:	bc35                	j	ffffffffc020012a <cprintf>
ffffffffc02006f0:	7446                	ld	s0,112(sp)
ffffffffc02006f2:	70e6                	ld	ra,120(sp)
ffffffffc02006f4:	74a6                	ld	s1,104(sp)
ffffffffc02006f6:	7906                	ld	s2,96(sp)
ffffffffc02006f8:	69e6                	ld	s3,88(sp)
ffffffffc02006fa:	6a46                	ld	s4,80(sp)
ffffffffc02006fc:	6aa6                	ld	s5,72(sp)
ffffffffc02006fe:	6b06                	ld	s6,64(sp)
ffffffffc0200700:	7be2                	ld	s7,56(sp)
ffffffffc0200702:	7c42                	ld	s8,48(sp)
ffffffffc0200704:	7ca2                	ld	s9,40(sp)
ffffffffc0200706:	7d02                	ld	s10,32(sp)
ffffffffc0200708:	6de2                	ld	s11,24(sp)
ffffffffc020070a:	0000b517          	auipc	a0,0xb
ffffffffc020070e:	46650513          	addi	a0,a0,1126 # ffffffffc020bb70 <commands+0xa0>
ffffffffc0200712:	6109                	addi	sp,sp,128
ffffffffc0200714:	bc19                	j	ffffffffc020012a <cprintf>
ffffffffc0200716:	8556                	mv	a0,s5
ffffffffc0200718:	3730a0ef          	jal	ra,ffffffffc020b28a <strlen>
ffffffffc020071c:	8a2a                	mv	s4,a0
ffffffffc020071e:	4619                	li	a2,6
ffffffffc0200720:	85a6                	mv	a1,s1
ffffffffc0200722:	8556                	mv	a0,s5
ffffffffc0200724:	2a01                	sext.w	s4,s4
ffffffffc0200726:	3cb0a0ef          	jal	ra,ffffffffc020b2f0 <strncmp>
ffffffffc020072a:	e111                	bnez	a0,ffffffffc020072e <dtb_init+0x1e2>
ffffffffc020072c:	4c85                	li	s9,1
ffffffffc020072e:	0a91                	addi	s5,s5,4
ffffffffc0200730:	9ad2                	add	s5,s5,s4
ffffffffc0200732:	ffcafa93          	andi	s5,s5,-4
ffffffffc0200736:	8a56                	mv	s4,s5
ffffffffc0200738:	bf2d                	j	ffffffffc0200672 <dtb_init+0x126>
ffffffffc020073a:	004a2783          	lw	a5,4(s4)
ffffffffc020073e:	00ca0693          	addi	a3,s4,12
ffffffffc0200742:	0087d71b          	srliw	a4,a5,0x8
ffffffffc0200746:	01879a9b          	slliw	s5,a5,0x18
ffffffffc020074a:	0187d61b          	srliw	a2,a5,0x18
ffffffffc020074e:	0107171b          	slliw	a4,a4,0x10
ffffffffc0200752:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200756:	00caeab3          	or	s5,s5,a2
ffffffffc020075a:	01877733          	and	a4,a4,s8
ffffffffc020075e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200762:	00eaeab3          	or	s5,s5,a4
ffffffffc0200766:	00fb77b3          	and	a5,s6,a5
ffffffffc020076a:	00faeab3          	or	s5,s5,a5
ffffffffc020076e:	2a81                	sext.w	s5,s5
ffffffffc0200770:	000c9c63          	bnez	s9,ffffffffc0200788 <dtb_init+0x23c>
ffffffffc0200774:	1a82                	slli	s5,s5,0x20
ffffffffc0200776:	00368793          	addi	a5,a3,3
ffffffffc020077a:	020ada93          	srli	s5,s5,0x20
ffffffffc020077e:	9abe                	add	s5,s5,a5
ffffffffc0200780:	ffcafa93          	andi	s5,s5,-4
ffffffffc0200784:	8a56                	mv	s4,s5
ffffffffc0200786:	b5f5                	j	ffffffffc0200672 <dtb_init+0x126>
ffffffffc0200788:	008a2783          	lw	a5,8(s4)
ffffffffc020078c:	85ca                	mv	a1,s2
ffffffffc020078e:	e436                	sd	a3,8(sp)
ffffffffc0200790:	0087d51b          	srliw	a0,a5,0x8
ffffffffc0200794:	0187d61b          	srliw	a2,a5,0x18
ffffffffc0200798:	0187971b          	slliw	a4,a5,0x18
ffffffffc020079c:	0105151b          	slliw	a0,a0,0x10
ffffffffc02007a0:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02007a4:	8f51                	or	a4,a4,a2
ffffffffc02007a6:	01857533          	and	a0,a0,s8
ffffffffc02007aa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02007ae:	8d59                	or	a0,a0,a4
ffffffffc02007b0:	00fb77b3          	and	a5,s6,a5
ffffffffc02007b4:	8d5d                	or	a0,a0,a5
ffffffffc02007b6:	1502                	slli	a0,a0,0x20
ffffffffc02007b8:	9101                	srli	a0,a0,0x20
ffffffffc02007ba:	9522                	add	a0,a0,s0
ffffffffc02007bc:	3170a0ef          	jal	ra,ffffffffc020b2d2 <strcmp>
ffffffffc02007c0:	66a2                	ld	a3,8(sp)
ffffffffc02007c2:	f94d                	bnez	a0,ffffffffc0200774 <dtb_init+0x228>
ffffffffc02007c4:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200774 <dtb_init+0x228>
ffffffffc02007c8:	00ca3783          	ld	a5,12(s4)
ffffffffc02007cc:	014a3703          	ld	a4,20(s4)
ffffffffc02007d0:	0000b517          	auipc	a0,0xb
ffffffffc02007d4:	3d850513          	addi	a0,a0,984 # ffffffffc020bba8 <commands+0xd8>
ffffffffc02007d8:	4207d613          	srai	a2,a5,0x20
ffffffffc02007dc:	0087d31b          	srliw	t1,a5,0x8
ffffffffc02007e0:	42075593          	srai	a1,a4,0x20
ffffffffc02007e4:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02007e8:	0186581b          	srliw	a6,a2,0x18
ffffffffc02007ec:	0187941b          	slliw	s0,a5,0x18
ffffffffc02007f0:	0107d89b          	srliw	a7,a5,0x10
ffffffffc02007f4:	0187d693          	srli	a3,a5,0x18
ffffffffc02007f8:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02007fc:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200800:	0103131b          	slliw	t1,t1,0x10
ffffffffc0200804:	0106561b          	srliw	a2,a2,0x10
ffffffffc0200808:	010f6f33          	or	t5,t5,a6
ffffffffc020080c:	0187529b          	srliw	t0,a4,0x18
ffffffffc0200810:	0185df9b          	srliw	t6,a1,0x18
ffffffffc0200814:	01837333          	and	t1,t1,s8
ffffffffc0200818:	01c46433          	or	s0,s0,t3
ffffffffc020081c:	0186f6b3          	and	a3,a3,s8
ffffffffc0200820:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200824:	01871e9b          	slliw	t4,a4,0x18
ffffffffc0200828:	0107581b          	srliw	a6,a4,0x10
ffffffffc020082c:	0086161b          	slliw	a2,a2,0x8
ffffffffc0200830:	8361                	srli	a4,a4,0x18
ffffffffc0200832:	0107979b          	slliw	a5,a5,0x10
ffffffffc0200836:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020083a:	01e6e6b3          	or	a3,a3,t5
ffffffffc020083e:	00cb7633          	and	a2,s6,a2
ffffffffc0200842:	0088181b          	slliw	a6,a6,0x8
ffffffffc0200846:	0085959b          	slliw	a1,a1,0x8
ffffffffc020084a:	00646433          	or	s0,s0,t1
ffffffffc020084e:	0187f7b3          	and	a5,a5,s8
ffffffffc0200852:	01fe6333          	or	t1,t3,t6
ffffffffc0200856:	01877c33          	and	s8,a4,s8
ffffffffc020085a:	0088989b          	slliw	a7,a7,0x8
ffffffffc020085e:	011b78b3          	and	a7,s6,a7
ffffffffc0200862:	005eeeb3          	or	t4,t4,t0
ffffffffc0200866:	00c6e733          	or	a4,a3,a2
ffffffffc020086a:	006c6c33          	or	s8,s8,t1
ffffffffc020086e:	010b76b3          	and	a3,s6,a6
ffffffffc0200872:	00bb7b33          	and	s6,s6,a1
ffffffffc0200876:	01d7e7b3          	or	a5,a5,t4
ffffffffc020087a:	016c6b33          	or	s6,s8,s6
ffffffffc020087e:	01146433          	or	s0,s0,a7
ffffffffc0200882:	8fd5                	or	a5,a5,a3
ffffffffc0200884:	1702                	slli	a4,a4,0x20
ffffffffc0200886:	1b02                	slli	s6,s6,0x20
ffffffffc0200888:	1782                	slli	a5,a5,0x20
ffffffffc020088a:	9301                	srli	a4,a4,0x20
ffffffffc020088c:	1402                	slli	s0,s0,0x20
ffffffffc020088e:	020b5b13          	srli	s6,s6,0x20
ffffffffc0200892:	0167eb33          	or	s6,a5,s6
ffffffffc0200896:	8c59                	or	s0,s0,a4
ffffffffc0200898:	893ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020089c:	85a2                	mv	a1,s0
ffffffffc020089e:	0000b517          	auipc	a0,0xb
ffffffffc02008a2:	32a50513          	addi	a0,a0,810 # ffffffffc020bbc8 <commands+0xf8>
ffffffffc02008a6:	885ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02008aa:	014b5613          	srli	a2,s6,0x14
ffffffffc02008ae:	85da                	mv	a1,s6
ffffffffc02008b0:	0000b517          	auipc	a0,0xb
ffffffffc02008b4:	33050513          	addi	a0,a0,816 # ffffffffc020bbe0 <commands+0x110>
ffffffffc02008b8:	873ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02008bc:	008b05b3          	add	a1,s6,s0
ffffffffc02008c0:	15fd                	addi	a1,a1,-1
ffffffffc02008c2:	0000b517          	auipc	a0,0xb
ffffffffc02008c6:	33e50513          	addi	a0,a0,830 # ffffffffc020bc00 <commands+0x130>
ffffffffc02008ca:	861ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02008ce:	0000b517          	auipc	a0,0xb
ffffffffc02008d2:	38250513          	addi	a0,a0,898 # ffffffffc020bc50 <commands+0x180>
ffffffffc02008d6:	00096797          	auipc	a5,0x96
ffffffffc02008da:	fc87bd23          	sd	s0,-38(a5) # ffffffffc02968b0 <memory_base>
ffffffffc02008de:	00096797          	auipc	a5,0x96
ffffffffc02008e2:	fd67bd23          	sd	s6,-38(a5) # ffffffffc02968b8 <memory_size>
ffffffffc02008e6:	b3f5                	j	ffffffffc02006d2 <dtb_init+0x186>

ffffffffc02008e8 <get_memory_base>:
ffffffffc02008e8:	00096517          	auipc	a0,0x96
ffffffffc02008ec:	fc853503          	ld	a0,-56(a0) # ffffffffc02968b0 <memory_base>
ffffffffc02008f0:	8082                	ret

ffffffffc02008f2 <get_memory_size>:
ffffffffc02008f2:	00096517          	auipc	a0,0x96
ffffffffc02008f6:	fc653503          	ld	a0,-58(a0) # ffffffffc02968b8 <memory_size>
ffffffffc02008fa:	8082                	ret

ffffffffc02008fc <ramdisk_write>:
ffffffffc02008fc:	00856703          	lwu	a4,8(a0)
ffffffffc0200900:	1141                	addi	sp,sp,-16
ffffffffc0200902:	e406                	sd	ra,8(sp)
ffffffffc0200904:	8f0d                	sub	a4,a4,a1
ffffffffc0200906:	87ae                	mv	a5,a1
ffffffffc0200908:	85b2                	mv	a1,a2
ffffffffc020090a:	00e6f363          	bgeu	a3,a4,ffffffffc0200910 <ramdisk_write+0x14>
ffffffffc020090e:	8736                	mv	a4,a3
ffffffffc0200910:	6908                	ld	a0,16(a0)
ffffffffc0200912:	07a6                	slli	a5,a5,0x9
ffffffffc0200914:	00971613          	slli	a2,a4,0x9
ffffffffc0200918:	953e                	add	a0,a0,a5
ffffffffc020091a:	2650a0ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc020091e:	60a2                	ld	ra,8(sp)
ffffffffc0200920:	4501                	li	a0,0
ffffffffc0200922:	0141                	addi	sp,sp,16
ffffffffc0200924:	8082                	ret

ffffffffc0200926 <ramdisk_read>:
ffffffffc0200926:	00856783          	lwu	a5,8(a0)
ffffffffc020092a:	1141                	addi	sp,sp,-16
ffffffffc020092c:	e406                	sd	ra,8(sp)
ffffffffc020092e:	8f8d                	sub	a5,a5,a1
ffffffffc0200930:	872a                	mv	a4,a0
ffffffffc0200932:	8532                	mv	a0,a2
ffffffffc0200934:	00f6f363          	bgeu	a3,a5,ffffffffc020093a <ramdisk_read+0x14>
ffffffffc0200938:	87b6                	mv	a5,a3
ffffffffc020093a:	6b18                	ld	a4,16(a4)
ffffffffc020093c:	05a6                	slli	a1,a1,0x9
ffffffffc020093e:	00979613          	slli	a2,a5,0x9
ffffffffc0200942:	95ba                	add	a1,a1,a4
ffffffffc0200944:	23b0a0ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc0200948:	60a2                	ld	ra,8(sp)
ffffffffc020094a:	4501                	li	a0,0
ffffffffc020094c:	0141                	addi	sp,sp,16
ffffffffc020094e:	8082                	ret

ffffffffc0200950 <ramdisk_init>:
ffffffffc0200950:	1101                	addi	sp,sp,-32
ffffffffc0200952:	e822                	sd	s0,16(sp)
ffffffffc0200954:	842e                	mv	s0,a1
ffffffffc0200956:	e426                	sd	s1,8(sp)
ffffffffc0200958:	05000613          	li	a2,80
ffffffffc020095c:	84aa                	mv	s1,a0
ffffffffc020095e:	4581                	li	a1,0
ffffffffc0200960:	8522                	mv	a0,s0
ffffffffc0200962:	ec06                	sd	ra,24(sp)
ffffffffc0200964:	e04a                	sd	s2,0(sp)
ffffffffc0200966:	1c70a0ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc020096a:	4785                	li	a5,1
ffffffffc020096c:	06f48b63          	beq	s1,a5,ffffffffc02009e2 <ramdisk_init+0x92>
ffffffffc0200970:	4789                	li	a5,2
ffffffffc0200972:	00090617          	auipc	a2,0x90
ffffffffc0200976:	69e60613          	addi	a2,a2,1694 # ffffffffc0291010 <arena>
ffffffffc020097a:	0001b917          	auipc	s2,0x1b
ffffffffc020097e:	39690913          	addi	s2,s2,918 # ffffffffc021bd10 <_binary_bin_sfs_img_start>
ffffffffc0200982:	08f49563          	bne	s1,a5,ffffffffc0200a0c <ramdisk_init+0xbc>
ffffffffc0200986:	06c90863          	beq	s2,a2,ffffffffc02009f6 <ramdisk_init+0xa6>
ffffffffc020098a:	412604b3          	sub	s1,a2,s2
ffffffffc020098e:	86a6                	mv	a3,s1
ffffffffc0200990:	85ca                	mv	a1,s2
ffffffffc0200992:	167d                	addi	a2,a2,-1
ffffffffc0200994:	0000b517          	auipc	a0,0xb
ffffffffc0200998:	2ec50513          	addi	a0,a0,748 # ffffffffc020bc80 <commands+0x1b0>
ffffffffc020099c:	f8eff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02009a0:	57fd                	li	a5,-1
ffffffffc02009a2:	1782                	slli	a5,a5,0x20
ffffffffc02009a4:	0785                	addi	a5,a5,1
ffffffffc02009a6:	0094d49b          	srliw	s1,s1,0x9
ffffffffc02009aa:	e01c                	sd	a5,0(s0)
ffffffffc02009ac:	c404                	sw	s1,8(s0)
ffffffffc02009ae:	01243823          	sd	s2,16(s0)
ffffffffc02009b2:	02040513          	addi	a0,s0,32
ffffffffc02009b6:	0000b597          	auipc	a1,0xb
ffffffffc02009ba:	32258593          	addi	a1,a1,802 # ffffffffc020bcd8 <commands+0x208>
ffffffffc02009be:	1030a0ef          	jal	ra,ffffffffc020b2c0 <strcpy>
ffffffffc02009c2:	00000797          	auipc	a5,0x0
ffffffffc02009c6:	f6478793          	addi	a5,a5,-156 # ffffffffc0200926 <ramdisk_read>
ffffffffc02009ca:	e03c                	sd	a5,64(s0)
ffffffffc02009cc:	00000797          	auipc	a5,0x0
ffffffffc02009d0:	f3078793          	addi	a5,a5,-208 # ffffffffc02008fc <ramdisk_write>
ffffffffc02009d4:	60e2                	ld	ra,24(sp)
ffffffffc02009d6:	e43c                	sd	a5,72(s0)
ffffffffc02009d8:	6442                	ld	s0,16(sp)
ffffffffc02009da:	64a2                	ld	s1,8(sp)
ffffffffc02009dc:	6902                	ld	s2,0(sp)
ffffffffc02009de:	6105                	addi	sp,sp,32
ffffffffc02009e0:	8082                	ret
ffffffffc02009e2:	0001b617          	auipc	a2,0x1b
ffffffffc02009e6:	32e60613          	addi	a2,a2,814 # ffffffffc021bd10 <_binary_bin_sfs_img_start>
ffffffffc02009ea:	00013917          	auipc	s2,0x13
ffffffffc02009ee:	62690913          	addi	s2,s2,1574 # ffffffffc0214010 <_binary_bin_swap_img_start>
ffffffffc02009f2:	f8c91ce3          	bne	s2,a2,ffffffffc020098a <ramdisk_init+0x3a>
ffffffffc02009f6:	6442                	ld	s0,16(sp)
ffffffffc02009f8:	60e2                	ld	ra,24(sp)
ffffffffc02009fa:	64a2                	ld	s1,8(sp)
ffffffffc02009fc:	6902                	ld	s2,0(sp)
ffffffffc02009fe:	0000b517          	auipc	a0,0xb
ffffffffc0200a02:	26a50513          	addi	a0,a0,618 # ffffffffc020bc68 <commands+0x198>
ffffffffc0200a06:	6105                	addi	sp,sp,32
ffffffffc0200a08:	f22ff06f          	j	ffffffffc020012a <cprintf>
ffffffffc0200a0c:	0000b617          	auipc	a2,0xb
ffffffffc0200a10:	29c60613          	addi	a2,a2,668 # ffffffffc020bca8 <commands+0x1d8>
ffffffffc0200a14:	03200593          	li	a1,50
ffffffffc0200a18:	0000b517          	auipc	a0,0xb
ffffffffc0200a1c:	2a850513          	addi	a0,a0,680 # ffffffffc020bcc0 <commands+0x1f0>
ffffffffc0200a20:	80fff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0200a24 <clock_init>:
ffffffffc0200a24:	02000793          	li	a5,32
ffffffffc0200a28:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc0200a2c:	c0102573          	rdtime	a0
ffffffffc0200a30:	67e1                	lui	a5,0x18
ffffffffc0200a32:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_bin_swap_img_size+0x109a0>
ffffffffc0200a36:	953e                	add	a0,a0,a5
ffffffffc0200a38:	4581                	li	a1,0
ffffffffc0200a3a:	4601                	li	a2,0
ffffffffc0200a3c:	4881                	li	a7,0
ffffffffc0200a3e:	00000073          	ecall
ffffffffc0200a42:	0000b517          	auipc	a0,0xb
ffffffffc0200a46:	2a650513          	addi	a0,a0,678 # ffffffffc020bce8 <commands+0x218>
ffffffffc0200a4a:	00096797          	auipc	a5,0x96
ffffffffc0200a4e:	e607bb23          	sd	zero,-394(a5) # ffffffffc02968c0 <ticks>
ffffffffc0200a52:	ed8ff06f          	j	ffffffffc020012a <cprintf>

ffffffffc0200a56 <clock_set_next_event>:
ffffffffc0200a56:	c0102573          	rdtime	a0
ffffffffc0200a5a:	67e1                	lui	a5,0x18
ffffffffc0200a5c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_bin_swap_img_size+0x109a0>
ffffffffc0200a60:	953e                	add	a0,a0,a5
ffffffffc0200a62:	4581                	li	a1,0
ffffffffc0200a64:	4601                	li	a2,0
ffffffffc0200a66:	4881                	li	a7,0
ffffffffc0200a68:	00000073          	ecall
ffffffffc0200a6c:	8082                	ret

ffffffffc0200a6e <cons_init>:
ffffffffc0200a6e:	4501                	li	a0,0
ffffffffc0200a70:	4581                	li	a1,0
ffffffffc0200a72:	4601                	li	a2,0
ffffffffc0200a74:	4889                	li	a7,2
ffffffffc0200a76:	00000073          	ecall
ffffffffc0200a7a:	8082                	ret

ffffffffc0200a7c <cons_putc>:
ffffffffc0200a7c:	1101                	addi	sp,sp,-32
ffffffffc0200a7e:	ec06                	sd	ra,24(sp)
ffffffffc0200a80:	100027f3          	csrr	a5,sstatus
ffffffffc0200a84:	8b89                	andi	a5,a5,2
ffffffffc0200a86:	4701                	li	a4,0
ffffffffc0200a88:	ef95                	bnez	a5,ffffffffc0200ac4 <cons_putc+0x48>
ffffffffc0200a8a:	47a1                	li	a5,8
ffffffffc0200a8c:	00f50b63          	beq	a0,a5,ffffffffc0200aa2 <cons_putc+0x26>
ffffffffc0200a90:	4581                	li	a1,0
ffffffffc0200a92:	4601                	li	a2,0
ffffffffc0200a94:	4885                	li	a7,1
ffffffffc0200a96:	00000073          	ecall
ffffffffc0200a9a:	e315                	bnez	a4,ffffffffc0200abe <cons_putc+0x42>
ffffffffc0200a9c:	60e2                	ld	ra,24(sp)
ffffffffc0200a9e:	6105                	addi	sp,sp,32
ffffffffc0200aa0:	8082                	ret
ffffffffc0200aa2:	4521                	li	a0,8
ffffffffc0200aa4:	4581                	li	a1,0
ffffffffc0200aa6:	4601                	li	a2,0
ffffffffc0200aa8:	4885                	li	a7,1
ffffffffc0200aaa:	00000073          	ecall
ffffffffc0200aae:	02000513          	li	a0,32
ffffffffc0200ab2:	00000073          	ecall
ffffffffc0200ab6:	4521                	li	a0,8
ffffffffc0200ab8:	00000073          	ecall
ffffffffc0200abc:	d365                	beqz	a4,ffffffffc0200a9c <cons_putc+0x20>
ffffffffc0200abe:	60e2                	ld	ra,24(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
ffffffffc0200ac2:	ace1                	j	ffffffffc0200d9a <intr_enable>
ffffffffc0200ac4:	e42a                	sd	a0,8(sp)
ffffffffc0200ac6:	2da000ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0200aca:	6522                	ld	a0,8(sp)
ffffffffc0200acc:	4705                	li	a4,1
ffffffffc0200ace:	bf75                	j	ffffffffc0200a8a <cons_putc+0xe>

ffffffffc0200ad0 <cons_getc>:
ffffffffc0200ad0:	1101                	addi	sp,sp,-32
ffffffffc0200ad2:	ec06                	sd	ra,24(sp)
ffffffffc0200ad4:	100027f3          	csrr	a5,sstatus
ffffffffc0200ad8:	8b89                	andi	a5,a5,2
ffffffffc0200ada:	4801                	li	a6,0
ffffffffc0200adc:	e3d5                	bnez	a5,ffffffffc0200b80 <cons_getc+0xb0>
ffffffffc0200ade:	00091697          	auipc	a3,0x91
ffffffffc0200ae2:	98268693          	addi	a3,a3,-1662 # ffffffffc0291460 <cons>
ffffffffc0200ae6:	07f00713          	li	a4,127
ffffffffc0200aea:	20000313          	li	t1,512
ffffffffc0200aee:	a021                	j	ffffffffc0200af6 <cons_getc+0x26>
ffffffffc0200af0:	0ff57513          	zext.b	a0,a0
ffffffffc0200af4:	ef91                	bnez	a5,ffffffffc0200b10 <cons_getc+0x40>
ffffffffc0200af6:	4501                	li	a0,0
ffffffffc0200af8:	4581                	li	a1,0
ffffffffc0200afa:	4601                	li	a2,0
ffffffffc0200afc:	4889                	li	a7,2
ffffffffc0200afe:	00000073          	ecall
ffffffffc0200b02:	0005079b          	sext.w	a5,a0
ffffffffc0200b06:	0207c763          	bltz	a5,ffffffffc0200b34 <cons_getc+0x64>
ffffffffc0200b0a:	fee793e3          	bne	a5,a4,ffffffffc0200af0 <cons_getc+0x20>
ffffffffc0200b0e:	4521                	li	a0,8
ffffffffc0200b10:	2046a783          	lw	a5,516(a3)
ffffffffc0200b14:	02079613          	slli	a2,a5,0x20
ffffffffc0200b18:	9201                	srli	a2,a2,0x20
ffffffffc0200b1a:	2785                	addiw	a5,a5,1
ffffffffc0200b1c:	9636                	add	a2,a2,a3
ffffffffc0200b1e:	20f6a223          	sw	a5,516(a3)
ffffffffc0200b22:	00a60023          	sb	a0,0(a2)
ffffffffc0200b26:	fc6798e3          	bne	a5,t1,ffffffffc0200af6 <cons_getc+0x26>
ffffffffc0200b2a:	00091797          	auipc	a5,0x91
ffffffffc0200b2e:	b207ad23          	sw	zero,-1222(a5) # ffffffffc0291664 <cons+0x204>
ffffffffc0200b32:	b7d1                	j	ffffffffc0200af6 <cons_getc+0x26>
ffffffffc0200b34:	2006a783          	lw	a5,512(a3)
ffffffffc0200b38:	2046a703          	lw	a4,516(a3)
ffffffffc0200b3c:	4501                	li	a0,0
ffffffffc0200b3e:	00f70f63          	beq	a4,a5,ffffffffc0200b5c <cons_getc+0x8c>
ffffffffc0200b42:	0017861b          	addiw	a2,a5,1
ffffffffc0200b46:	1782                	slli	a5,a5,0x20
ffffffffc0200b48:	9381                	srli	a5,a5,0x20
ffffffffc0200b4a:	97b6                	add	a5,a5,a3
ffffffffc0200b4c:	20c6a023          	sw	a2,512(a3)
ffffffffc0200b50:	20000713          	li	a4,512
ffffffffc0200b54:	0007c503          	lbu	a0,0(a5)
ffffffffc0200b58:	00e60763          	beq	a2,a4,ffffffffc0200b66 <cons_getc+0x96>
ffffffffc0200b5c:	00081b63          	bnez	a6,ffffffffc0200b72 <cons_getc+0xa2>
ffffffffc0200b60:	60e2                	ld	ra,24(sp)
ffffffffc0200b62:	6105                	addi	sp,sp,32
ffffffffc0200b64:	8082                	ret
ffffffffc0200b66:	00091797          	auipc	a5,0x91
ffffffffc0200b6a:	ae07ad23          	sw	zero,-1286(a5) # ffffffffc0291660 <cons+0x200>
ffffffffc0200b6e:	fe0809e3          	beqz	a6,ffffffffc0200b60 <cons_getc+0x90>
ffffffffc0200b72:	e42a                	sd	a0,8(sp)
ffffffffc0200b74:	226000ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0200b78:	60e2                	ld	ra,24(sp)
ffffffffc0200b7a:	6522                	ld	a0,8(sp)
ffffffffc0200b7c:	6105                	addi	sp,sp,32
ffffffffc0200b7e:	8082                	ret
ffffffffc0200b80:	220000ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0200b84:	4805                	li	a6,1
ffffffffc0200b86:	bfa1                	j	ffffffffc0200ade <cons_getc+0xe>

ffffffffc0200b88 <pic_init>:
ffffffffc0200b88:	8082                	ret

ffffffffc0200b8a <ide_init>:
ffffffffc0200b8a:	1141                	addi	sp,sp,-16
ffffffffc0200b8c:	00091597          	auipc	a1,0x91
ffffffffc0200b90:	b2c58593          	addi	a1,a1,-1236 # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc0200b94:	4505                	li	a0,1
ffffffffc0200b96:	e022                	sd	s0,0(sp)
ffffffffc0200b98:	00091797          	auipc	a5,0x91
ffffffffc0200b9c:	ac07a823          	sw	zero,-1328(a5) # ffffffffc0291668 <ide_devices>
ffffffffc0200ba0:	00091797          	auipc	a5,0x91
ffffffffc0200ba4:	b007ac23          	sw	zero,-1256(a5) # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc0200ba8:	00091797          	auipc	a5,0x91
ffffffffc0200bac:	b607a023          	sw	zero,-1184(a5) # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc0200bb0:	00091797          	auipc	a5,0x91
ffffffffc0200bb4:	ba07a423          	sw	zero,-1112(a5) # ffffffffc0291758 <ide_devices+0xf0>
ffffffffc0200bb8:	e406                	sd	ra,8(sp)
ffffffffc0200bba:	00091417          	auipc	s0,0x91
ffffffffc0200bbe:	aae40413          	addi	s0,s0,-1362 # ffffffffc0291668 <ide_devices>
ffffffffc0200bc2:	d8fff0ef          	jal	ra,ffffffffc0200950 <ramdisk_init>
ffffffffc0200bc6:	483c                	lw	a5,80(s0)
ffffffffc0200bc8:	cf99                	beqz	a5,ffffffffc0200be6 <ide_init+0x5c>
ffffffffc0200bca:	00091597          	auipc	a1,0x91
ffffffffc0200bce:	b3e58593          	addi	a1,a1,-1218 # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc0200bd2:	4509                	li	a0,2
ffffffffc0200bd4:	d7dff0ef          	jal	ra,ffffffffc0200950 <ramdisk_init>
ffffffffc0200bd8:	0a042783          	lw	a5,160(s0)
ffffffffc0200bdc:	c785                	beqz	a5,ffffffffc0200c04 <ide_init+0x7a>
ffffffffc0200bde:	60a2                	ld	ra,8(sp)
ffffffffc0200be0:	6402                	ld	s0,0(sp)
ffffffffc0200be2:	0141                	addi	sp,sp,16
ffffffffc0200be4:	8082                	ret
ffffffffc0200be6:	0000b697          	auipc	a3,0xb
ffffffffc0200bea:	12268693          	addi	a3,a3,290 # ffffffffc020bd08 <commands+0x238>
ffffffffc0200bee:	0000b617          	auipc	a2,0xb
ffffffffc0200bf2:	13260613          	addi	a2,a2,306 # ffffffffc020bd20 <commands+0x250>
ffffffffc0200bf6:	45c5                	li	a1,17
ffffffffc0200bf8:	0000b517          	auipc	a0,0xb
ffffffffc0200bfc:	14050513          	addi	a0,a0,320 # ffffffffc020bd38 <commands+0x268>
ffffffffc0200c00:	e2eff0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0200c04:	0000b697          	auipc	a3,0xb
ffffffffc0200c08:	14c68693          	addi	a3,a3,332 # ffffffffc020bd50 <commands+0x280>
ffffffffc0200c0c:	0000b617          	auipc	a2,0xb
ffffffffc0200c10:	11460613          	addi	a2,a2,276 # ffffffffc020bd20 <commands+0x250>
ffffffffc0200c14:	45d1                	li	a1,20
ffffffffc0200c16:	0000b517          	auipc	a0,0xb
ffffffffc0200c1a:	12250513          	addi	a0,a0,290 # ffffffffc020bd38 <commands+0x268>
ffffffffc0200c1e:	e10ff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0200c22 <ide_device_valid>:
ffffffffc0200c22:	478d                	li	a5,3
ffffffffc0200c24:	00a7ef63          	bltu	a5,a0,ffffffffc0200c42 <ide_device_valid+0x20>
ffffffffc0200c28:	00251793          	slli	a5,a0,0x2
ffffffffc0200c2c:	953e                	add	a0,a0,a5
ffffffffc0200c2e:	0512                	slli	a0,a0,0x4
ffffffffc0200c30:	00091797          	auipc	a5,0x91
ffffffffc0200c34:	a3878793          	addi	a5,a5,-1480 # ffffffffc0291668 <ide_devices>
ffffffffc0200c38:	953e                	add	a0,a0,a5
ffffffffc0200c3a:	4108                	lw	a0,0(a0)
ffffffffc0200c3c:	00a03533          	snez	a0,a0
ffffffffc0200c40:	8082                	ret
ffffffffc0200c42:	4501                	li	a0,0
ffffffffc0200c44:	8082                	ret

ffffffffc0200c46 <ide_device_size>:
ffffffffc0200c46:	478d                	li	a5,3
ffffffffc0200c48:	02a7e163          	bltu	a5,a0,ffffffffc0200c6a <ide_device_size+0x24>
ffffffffc0200c4c:	00251793          	slli	a5,a0,0x2
ffffffffc0200c50:	953e                	add	a0,a0,a5
ffffffffc0200c52:	0512                	slli	a0,a0,0x4
ffffffffc0200c54:	00091797          	auipc	a5,0x91
ffffffffc0200c58:	a1478793          	addi	a5,a5,-1516 # ffffffffc0291668 <ide_devices>
ffffffffc0200c5c:	97aa                	add	a5,a5,a0
ffffffffc0200c5e:	4398                	lw	a4,0(a5)
ffffffffc0200c60:	4501                	li	a0,0
ffffffffc0200c62:	c709                	beqz	a4,ffffffffc0200c6c <ide_device_size+0x26>
ffffffffc0200c64:	0087e503          	lwu	a0,8(a5)
ffffffffc0200c68:	8082                	ret
ffffffffc0200c6a:	4501                	li	a0,0
ffffffffc0200c6c:	8082                	ret

ffffffffc0200c6e <ide_read_secs>:
ffffffffc0200c6e:	1141                	addi	sp,sp,-16
ffffffffc0200c70:	e406                	sd	ra,8(sp)
ffffffffc0200c72:	08000793          	li	a5,128
ffffffffc0200c76:	04d7e763          	bltu	a5,a3,ffffffffc0200cc4 <ide_read_secs+0x56>
ffffffffc0200c7a:	478d                	li	a5,3
ffffffffc0200c7c:	0005081b          	sext.w	a6,a0
ffffffffc0200c80:	04a7e263          	bltu	a5,a0,ffffffffc0200cc4 <ide_read_secs+0x56>
ffffffffc0200c84:	00281793          	slli	a5,a6,0x2
ffffffffc0200c88:	97c2                	add	a5,a5,a6
ffffffffc0200c8a:	0792                	slli	a5,a5,0x4
ffffffffc0200c8c:	00091817          	auipc	a6,0x91
ffffffffc0200c90:	9dc80813          	addi	a6,a6,-1572 # ffffffffc0291668 <ide_devices>
ffffffffc0200c94:	97c2                	add	a5,a5,a6
ffffffffc0200c96:	0007a883          	lw	a7,0(a5)
ffffffffc0200c9a:	02088563          	beqz	a7,ffffffffc0200cc4 <ide_read_secs+0x56>
ffffffffc0200c9e:	100008b7          	lui	a7,0x10000
ffffffffc0200ca2:	0515f163          	bgeu	a1,a7,ffffffffc0200ce4 <ide_read_secs+0x76>
ffffffffc0200ca6:	1582                	slli	a1,a1,0x20
ffffffffc0200ca8:	9181                	srli	a1,a1,0x20
ffffffffc0200caa:	00d58733          	add	a4,a1,a3
ffffffffc0200cae:	02e8eb63          	bltu	a7,a4,ffffffffc0200ce4 <ide_read_secs+0x76>
ffffffffc0200cb2:	00251713          	slli	a4,a0,0x2
ffffffffc0200cb6:	60a2                	ld	ra,8(sp)
ffffffffc0200cb8:	63bc                	ld	a5,64(a5)
ffffffffc0200cba:	953a                	add	a0,a0,a4
ffffffffc0200cbc:	0512                	slli	a0,a0,0x4
ffffffffc0200cbe:	9542                	add	a0,a0,a6
ffffffffc0200cc0:	0141                	addi	sp,sp,16
ffffffffc0200cc2:	8782                	jr	a5
ffffffffc0200cc4:	0000b697          	auipc	a3,0xb
ffffffffc0200cc8:	0a468693          	addi	a3,a3,164 # ffffffffc020bd68 <commands+0x298>
ffffffffc0200ccc:	0000b617          	auipc	a2,0xb
ffffffffc0200cd0:	05460613          	addi	a2,a2,84 # ffffffffc020bd20 <commands+0x250>
ffffffffc0200cd4:	02200593          	li	a1,34
ffffffffc0200cd8:	0000b517          	auipc	a0,0xb
ffffffffc0200cdc:	06050513          	addi	a0,a0,96 # ffffffffc020bd38 <commands+0x268>
ffffffffc0200ce0:	d4eff0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0200ce4:	0000b697          	auipc	a3,0xb
ffffffffc0200ce8:	0ac68693          	addi	a3,a3,172 # ffffffffc020bd90 <commands+0x2c0>
ffffffffc0200cec:	0000b617          	auipc	a2,0xb
ffffffffc0200cf0:	03460613          	addi	a2,a2,52 # ffffffffc020bd20 <commands+0x250>
ffffffffc0200cf4:	02300593          	li	a1,35
ffffffffc0200cf8:	0000b517          	auipc	a0,0xb
ffffffffc0200cfc:	04050513          	addi	a0,a0,64 # ffffffffc020bd38 <commands+0x268>
ffffffffc0200d00:	d2eff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0200d04 <ide_write_secs>:
ffffffffc0200d04:	1141                	addi	sp,sp,-16
ffffffffc0200d06:	e406                	sd	ra,8(sp)
ffffffffc0200d08:	08000793          	li	a5,128
ffffffffc0200d0c:	04d7e763          	bltu	a5,a3,ffffffffc0200d5a <ide_write_secs+0x56>
ffffffffc0200d10:	478d                	li	a5,3
ffffffffc0200d12:	0005081b          	sext.w	a6,a0
ffffffffc0200d16:	04a7e263          	bltu	a5,a0,ffffffffc0200d5a <ide_write_secs+0x56>
ffffffffc0200d1a:	00281793          	slli	a5,a6,0x2
ffffffffc0200d1e:	97c2                	add	a5,a5,a6
ffffffffc0200d20:	0792                	slli	a5,a5,0x4
ffffffffc0200d22:	00091817          	auipc	a6,0x91
ffffffffc0200d26:	94680813          	addi	a6,a6,-1722 # ffffffffc0291668 <ide_devices>
ffffffffc0200d2a:	97c2                	add	a5,a5,a6
ffffffffc0200d2c:	0007a883          	lw	a7,0(a5)
ffffffffc0200d30:	02088563          	beqz	a7,ffffffffc0200d5a <ide_write_secs+0x56>
ffffffffc0200d34:	100008b7          	lui	a7,0x10000
ffffffffc0200d38:	0515f163          	bgeu	a1,a7,ffffffffc0200d7a <ide_write_secs+0x76>
ffffffffc0200d3c:	1582                	slli	a1,a1,0x20
ffffffffc0200d3e:	9181                	srli	a1,a1,0x20
ffffffffc0200d40:	00d58733          	add	a4,a1,a3
ffffffffc0200d44:	02e8eb63          	bltu	a7,a4,ffffffffc0200d7a <ide_write_secs+0x76>
ffffffffc0200d48:	00251713          	slli	a4,a0,0x2
ffffffffc0200d4c:	60a2                	ld	ra,8(sp)
ffffffffc0200d4e:	67bc                	ld	a5,72(a5)
ffffffffc0200d50:	953a                	add	a0,a0,a4
ffffffffc0200d52:	0512                	slli	a0,a0,0x4
ffffffffc0200d54:	9542                	add	a0,a0,a6
ffffffffc0200d56:	0141                	addi	sp,sp,16
ffffffffc0200d58:	8782                	jr	a5
ffffffffc0200d5a:	0000b697          	auipc	a3,0xb
ffffffffc0200d5e:	00e68693          	addi	a3,a3,14 # ffffffffc020bd68 <commands+0x298>
ffffffffc0200d62:	0000b617          	auipc	a2,0xb
ffffffffc0200d66:	fbe60613          	addi	a2,a2,-66 # ffffffffc020bd20 <commands+0x250>
ffffffffc0200d6a:	02900593          	li	a1,41
ffffffffc0200d6e:	0000b517          	auipc	a0,0xb
ffffffffc0200d72:	fca50513          	addi	a0,a0,-54 # ffffffffc020bd38 <commands+0x268>
ffffffffc0200d76:	cb8ff0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0200d7a:	0000b697          	auipc	a3,0xb
ffffffffc0200d7e:	01668693          	addi	a3,a3,22 # ffffffffc020bd90 <commands+0x2c0>
ffffffffc0200d82:	0000b617          	auipc	a2,0xb
ffffffffc0200d86:	f9e60613          	addi	a2,a2,-98 # ffffffffc020bd20 <commands+0x250>
ffffffffc0200d8a:	02a00593          	li	a1,42
ffffffffc0200d8e:	0000b517          	auipc	a0,0xb
ffffffffc0200d92:	faa50513          	addi	a0,a0,-86 # ffffffffc020bd38 <commands+0x268>
ffffffffc0200d96:	c98ff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0200d9a <intr_enable>:
ffffffffc0200d9a:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200d9e:	8082                	ret

ffffffffc0200da0 <intr_disable>:
ffffffffc0200da0:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200da4:	8082                	ret

ffffffffc0200da6 <idt_init>:
ffffffffc0200da6:	14005073          	csrwi	sscratch,0
ffffffffc0200daa:	00000797          	auipc	a5,0x0
ffffffffc0200dae:	4fe78793          	addi	a5,a5,1278 # ffffffffc02012a8 <__alltraps>
ffffffffc0200db2:	10579073          	csrw	stvec,a5
ffffffffc0200db6:	000407b7          	lui	a5,0x40
ffffffffc0200dba:	1007a7f3          	csrrs	a5,sstatus,a5
ffffffffc0200dbe:	8082                	ret

ffffffffc0200dc0 <print_regs>:
ffffffffc0200dc0:	610c                	ld	a1,0(a0)
ffffffffc0200dc2:	1141                	addi	sp,sp,-16
ffffffffc0200dc4:	e022                	sd	s0,0(sp)
ffffffffc0200dc6:	842a                	mv	s0,a0
ffffffffc0200dc8:	0000b517          	auipc	a0,0xb
ffffffffc0200dcc:	00850513          	addi	a0,a0,8 # ffffffffc020bdd0 <commands+0x300>
ffffffffc0200dd0:	e406                	sd	ra,8(sp)
ffffffffc0200dd2:	b58ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200dd6:	640c                	ld	a1,8(s0)
ffffffffc0200dd8:	0000b517          	auipc	a0,0xb
ffffffffc0200ddc:	01050513          	addi	a0,a0,16 # ffffffffc020bde8 <commands+0x318>
ffffffffc0200de0:	b4aff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200de4:	680c                	ld	a1,16(s0)
ffffffffc0200de6:	0000b517          	auipc	a0,0xb
ffffffffc0200dea:	01a50513          	addi	a0,a0,26 # ffffffffc020be00 <commands+0x330>
ffffffffc0200dee:	b3cff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200df2:	6c0c                	ld	a1,24(s0)
ffffffffc0200df4:	0000b517          	auipc	a0,0xb
ffffffffc0200df8:	02450513          	addi	a0,a0,36 # ffffffffc020be18 <commands+0x348>
ffffffffc0200dfc:	b2eff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e00:	700c                	ld	a1,32(s0)
ffffffffc0200e02:	0000b517          	auipc	a0,0xb
ffffffffc0200e06:	02e50513          	addi	a0,a0,46 # ffffffffc020be30 <commands+0x360>
ffffffffc0200e0a:	b20ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e0e:	740c                	ld	a1,40(s0)
ffffffffc0200e10:	0000b517          	auipc	a0,0xb
ffffffffc0200e14:	03850513          	addi	a0,a0,56 # ffffffffc020be48 <commands+0x378>
ffffffffc0200e18:	b12ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e1c:	780c                	ld	a1,48(s0)
ffffffffc0200e1e:	0000b517          	auipc	a0,0xb
ffffffffc0200e22:	04250513          	addi	a0,a0,66 # ffffffffc020be60 <commands+0x390>
ffffffffc0200e26:	b04ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e2a:	7c0c                	ld	a1,56(s0)
ffffffffc0200e2c:	0000b517          	auipc	a0,0xb
ffffffffc0200e30:	04c50513          	addi	a0,a0,76 # ffffffffc020be78 <commands+0x3a8>
ffffffffc0200e34:	af6ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e38:	602c                	ld	a1,64(s0)
ffffffffc0200e3a:	0000b517          	auipc	a0,0xb
ffffffffc0200e3e:	05650513          	addi	a0,a0,86 # ffffffffc020be90 <commands+0x3c0>
ffffffffc0200e42:	ae8ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e46:	642c                	ld	a1,72(s0)
ffffffffc0200e48:	0000b517          	auipc	a0,0xb
ffffffffc0200e4c:	06050513          	addi	a0,a0,96 # ffffffffc020bea8 <commands+0x3d8>
ffffffffc0200e50:	adaff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e54:	682c                	ld	a1,80(s0)
ffffffffc0200e56:	0000b517          	auipc	a0,0xb
ffffffffc0200e5a:	06a50513          	addi	a0,a0,106 # ffffffffc020bec0 <commands+0x3f0>
ffffffffc0200e5e:	accff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e62:	6c2c                	ld	a1,88(s0)
ffffffffc0200e64:	0000b517          	auipc	a0,0xb
ffffffffc0200e68:	07450513          	addi	a0,a0,116 # ffffffffc020bed8 <commands+0x408>
ffffffffc0200e6c:	abeff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e70:	702c                	ld	a1,96(s0)
ffffffffc0200e72:	0000b517          	auipc	a0,0xb
ffffffffc0200e76:	07e50513          	addi	a0,a0,126 # ffffffffc020bef0 <commands+0x420>
ffffffffc0200e7a:	ab0ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e7e:	742c                	ld	a1,104(s0)
ffffffffc0200e80:	0000b517          	auipc	a0,0xb
ffffffffc0200e84:	08850513          	addi	a0,a0,136 # ffffffffc020bf08 <commands+0x438>
ffffffffc0200e88:	aa2ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e8c:	782c                	ld	a1,112(s0)
ffffffffc0200e8e:	0000b517          	auipc	a0,0xb
ffffffffc0200e92:	09250513          	addi	a0,a0,146 # ffffffffc020bf20 <commands+0x450>
ffffffffc0200e96:	a94ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200e9a:	7c2c                	ld	a1,120(s0)
ffffffffc0200e9c:	0000b517          	auipc	a0,0xb
ffffffffc0200ea0:	09c50513          	addi	a0,a0,156 # ffffffffc020bf38 <commands+0x468>
ffffffffc0200ea4:	a86ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200ea8:	604c                	ld	a1,128(s0)
ffffffffc0200eaa:	0000b517          	auipc	a0,0xb
ffffffffc0200eae:	0a650513          	addi	a0,a0,166 # ffffffffc020bf50 <commands+0x480>
ffffffffc0200eb2:	a78ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200eb6:	644c                	ld	a1,136(s0)
ffffffffc0200eb8:	0000b517          	auipc	a0,0xb
ffffffffc0200ebc:	0b050513          	addi	a0,a0,176 # ffffffffc020bf68 <commands+0x498>
ffffffffc0200ec0:	a6aff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200ec4:	684c                	ld	a1,144(s0)
ffffffffc0200ec6:	0000b517          	auipc	a0,0xb
ffffffffc0200eca:	0ba50513          	addi	a0,a0,186 # ffffffffc020bf80 <commands+0x4b0>
ffffffffc0200ece:	a5cff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200ed2:	6c4c                	ld	a1,152(s0)
ffffffffc0200ed4:	0000b517          	auipc	a0,0xb
ffffffffc0200ed8:	0c450513          	addi	a0,a0,196 # ffffffffc020bf98 <commands+0x4c8>
ffffffffc0200edc:	a4eff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200ee0:	704c                	ld	a1,160(s0)
ffffffffc0200ee2:	0000b517          	auipc	a0,0xb
ffffffffc0200ee6:	0ce50513          	addi	a0,a0,206 # ffffffffc020bfb0 <commands+0x4e0>
ffffffffc0200eea:	a40ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200eee:	744c                	ld	a1,168(s0)
ffffffffc0200ef0:	0000b517          	auipc	a0,0xb
ffffffffc0200ef4:	0d850513          	addi	a0,a0,216 # ffffffffc020bfc8 <commands+0x4f8>
ffffffffc0200ef8:	a32ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200efc:	784c                	ld	a1,176(s0)
ffffffffc0200efe:	0000b517          	auipc	a0,0xb
ffffffffc0200f02:	0e250513          	addi	a0,a0,226 # ffffffffc020bfe0 <commands+0x510>
ffffffffc0200f06:	a24ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f0a:	7c4c                	ld	a1,184(s0)
ffffffffc0200f0c:	0000b517          	auipc	a0,0xb
ffffffffc0200f10:	0ec50513          	addi	a0,a0,236 # ffffffffc020bff8 <commands+0x528>
ffffffffc0200f14:	a16ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f18:	606c                	ld	a1,192(s0)
ffffffffc0200f1a:	0000b517          	auipc	a0,0xb
ffffffffc0200f1e:	0f650513          	addi	a0,a0,246 # ffffffffc020c010 <commands+0x540>
ffffffffc0200f22:	a08ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f26:	646c                	ld	a1,200(s0)
ffffffffc0200f28:	0000b517          	auipc	a0,0xb
ffffffffc0200f2c:	10050513          	addi	a0,a0,256 # ffffffffc020c028 <commands+0x558>
ffffffffc0200f30:	9faff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f34:	686c                	ld	a1,208(s0)
ffffffffc0200f36:	0000b517          	auipc	a0,0xb
ffffffffc0200f3a:	10a50513          	addi	a0,a0,266 # ffffffffc020c040 <commands+0x570>
ffffffffc0200f3e:	9ecff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f42:	6c6c                	ld	a1,216(s0)
ffffffffc0200f44:	0000b517          	auipc	a0,0xb
ffffffffc0200f48:	11450513          	addi	a0,a0,276 # ffffffffc020c058 <commands+0x588>
ffffffffc0200f4c:	9deff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f50:	706c                	ld	a1,224(s0)
ffffffffc0200f52:	0000b517          	auipc	a0,0xb
ffffffffc0200f56:	11e50513          	addi	a0,a0,286 # ffffffffc020c070 <commands+0x5a0>
ffffffffc0200f5a:	9d0ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f5e:	746c                	ld	a1,232(s0)
ffffffffc0200f60:	0000b517          	auipc	a0,0xb
ffffffffc0200f64:	12850513          	addi	a0,a0,296 # ffffffffc020c088 <commands+0x5b8>
ffffffffc0200f68:	9c2ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f6c:	786c                	ld	a1,240(s0)
ffffffffc0200f6e:	0000b517          	auipc	a0,0xb
ffffffffc0200f72:	13250513          	addi	a0,a0,306 # ffffffffc020c0a0 <commands+0x5d0>
ffffffffc0200f76:	9b4ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200f7a:	7c6c                	ld	a1,248(s0)
ffffffffc0200f7c:	6402                	ld	s0,0(sp)
ffffffffc0200f7e:	60a2                	ld	ra,8(sp)
ffffffffc0200f80:	0000b517          	auipc	a0,0xb
ffffffffc0200f84:	13850513          	addi	a0,a0,312 # ffffffffc020c0b8 <commands+0x5e8>
ffffffffc0200f88:	0141                	addi	sp,sp,16
ffffffffc0200f8a:	9a0ff06f          	j	ffffffffc020012a <cprintf>

ffffffffc0200f8e <print_trapframe>:
ffffffffc0200f8e:	1141                	addi	sp,sp,-16
ffffffffc0200f90:	e022                	sd	s0,0(sp)
ffffffffc0200f92:	85aa                	mv	a1,a0
ffffffffc0200f94:	842a                	mv	s0,a0
ffffffffc0200f96:	0000b517          	auipc	a0,0xb
ffffffffc0200f9a:	13a50513          	addi	a0,a0,314 # ffffffffc020c0d0 <commands+0x600>
ffffffffc0200f9e:	e406                	sd	ra,8(sp)
ffffffffc0200fa0:	98aff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200fa4:	8522                	mv	a0,s0
ffffffffc0200fa6:	e1bff0ef          	jal	ra,ffffffffc0200dc0 <print_regs>
ffffffffc0200faa:	10043583          	ld	a1,256(s0)
ffffffffc0200fae:	0000b517          	auipc	a0,0xb
ffffffffc0200fb2:	13a50513          	addi	a0,a0,314 # ffffffffc020c0e8 <commands+0x618>
ffffffffc0200fb6:	974ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200fba:	10843583          	ld	a1,264(s0)
ffffffffc0200fbe:	0000b517          	auipc	a0,0xb
ffffffffc0200fc2:	14250513          	addi	a0,a0,322 # ffffffffc020c100 <commands+0x630>
ffffffffc0200fc6:	964ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200fca:	11043583          	ld	a1,272(s0)
ffffffffc0200fce:	0000b517          	auipc	a0,0xb
ffffffffc0200fd2:	14a50513          	addi	a0,a0,330 # ffffffffc020c118 <commands+0x648>
ffffffffc0200fd6:	954ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0200fda:	11843583          	ld	a1,280(s0)
ffffffffc0200fde:	6402                	ld	s0,0(sp)
ffffffffc0200fe0:	60a2                	ld	ra,8(sp)
ffffffffc0200fe2:	0000b517          	auipc	a0,0xb
ffffffffc0200fe6:	14650513          	addi	a0,a0,326 # ffffffffc020c128 <commands+0x658>
ffffffffc0200fea:	0141                	addi	sp,sp,16
ffffffffc0200fec:	93eff06f          	j	ffffffffc020012a <cprintf>

ffffffffc0200ff0 <interrupt_handler>:
ffffffffc0200ff0:	11853783          	ld	a5,280(a0)
ffffffffc0200ff4:	472d                	li	a4,11
ffffffffc0200ff6:	0786                	slli	a5,a5,0x1
ffffffffc0200ff8:	8385                	srli	a5,a5,0x1
ffffffffc0200ffa:	06f76c63          	bltu	a4,a5,ffffffffc0201072 <interrupt_handler+0x82>
ffffffffc0200ffe:	0000b717          	auipc	a4,0xb
ffffffffc0201002:	1e270713          	addi	a4,a4,482 # ffffffffc020c1e0 <commands+0x710>
ffffffffc0201006:	078a                	slli	a5,a5,0x2
ffffffffc0201008:	97ba                	add	a5,a5,a4
ffffffffc020100a:	439c                	lw	a5,0(a5)
ffffffffc020100c:	97ba                	add	a5,a5,a4
ffffffffc020100e:	8782                	jr	a5
ffffffffc0201010:	0000b517          	auipc	a0,0xb
ffffffffc0201014:	19050513          	addi	a0,a0,400 # ffffffffc020c1a0 <commands+0x6d0>
ffffffffc0201018:	912ff06f          	j	ffffffffc020012a <cprintf>
ffffffffc020101c:	0000b517          	auipc	a0,0xb
ffffffffc0201020:	16450513          	addi	a0,a0,356 # ffffffffc020c180 <commands+0x6b0>
ffffffffc0201024:	906ff06f          	j	ffffffffc020012a <cprintf>
ffffffffc0201028:	0000b517          	auipc	a0,0xb
ffffffffc020102c:	11850513          	addi	a0,a0,280 # ffffffffc020c140 <commands+0x670>
ffffffffc0201030:	8faff06f          	j	ffffffffc020012a <cprintf>
ffffffffc0201034:	0000b517          	auipc	a0,0xb
ffffffffc0201038:	12c50513          	addi	a0,a0,300 # ffffffffc020c160 <commands+0x690>
ffffffffc020103c:	8eeff06f          	j	ffffffffc020012a <cprintf>
ffffffffc0201040:	1141                	addi	sp,sp,-16
ffffffffc0201042:	e406                	sd	ra,8(sp)
ffffffffc0201044:	a13ff0ef          	jal	ra,ffffffffc0200a56 <clock_set_next_event>
ffffffffc0201048:	00096717          	auipc	a4,0x96
ffffffffc020104c:	87870713          	addi	a4,a4,-1928 # ffffffffc02968c0 <ticks>
ffffffffc0201050:	631c                	ld	a5,0(a4)
ffffffffc0201052:	0785                	addi	a5,a5,1
ffffffffc0201054:	e31c                	sd	a5,0(a4)
ffffffffc0201056:	00b060ef          	jal	ra,ffffffffc0207860 <run_timer_list>
ffffffffc020105a:	a77ff0ef          	jal	ra,ffffffffc0200ad0 <cons_getc>
ffffffffc020105e:	60a2                	ld	ra,8(sp)
ffffffffc0201060:	0141                	addi	sp,sp,16
ffffffffc0201062:	1250706f          	j	ffffffffc0208986 <dev_stdin_write>
ffffffffc0201066:	0000b517          	auipc	a0,0xb
ffffffffc020106a:	15a50513          	addi	a0,a0,346 # ffffffffc020c1c0 <commands+0x6f0>
ffffffffc020106e:	8bcff06f          	j	ffffffffc020012a <cprintf>
ffffffffc0201072:	bf31                	j	ffffffffc0200f8e <print_trapframe>

ffffffffc0201074 <exception_handler>:
ffffffffc0201074:	11853783          	ld	a5,280(a0)
ffffffffc0201078:	1141                	addi	sp,sp,-16
ffffffffc020107a:	e022                	sd	s0,0(sp)
ffffffffc020107c:	e406                	sd	ra,8(sp)
ffffffffc020107e:	473d                	li	a4,15
ffffffffc0201080:	842a                	mv	s0,a0
ffffffffc0201082:	16f76c63          	bltu	a4,a5,ffffffffc02011fa <exception_handler+0x186>
ffffffffc0201086:	0000b717          	auipc	a4,0xb
ffffffffc020108a:	33a70713          	addi	a4,a4,826 # ffffffffc020c3c0 <commands+0x8f0>
ffffffffc020108e:	078a                	slli	a5,a5,0x2
ffffffffc0201090:	97ba                	add	a5,a5,a4
ffffffffc0201092:	439c                	lw	a5,0(a5)
ffffffffc0201094:	97ba                	add	a5,a5,a4
ffffffffc0201096:	8782                	jr	a5
ffffffffc0201098:	0000b517          	auipc	a0,0xb
ffffffffc020109c:	28050513          	addi	a0,a0,640 # ffffffffc020c318 <commands+0x848>
ffffffffc02010a0:	88aff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02010a4:	10843783          	ld	a5,264(s0)
ffffffffc02010a8:	60a2                	ld	ra,8(sp)
ffffffffc02010aa:	0791                	addi	a5,a5,4
ffffffffc02010ac:	10f43423          	sd	a5,264(s0)
ffffffffc02010b0:	6402                	ld	s0,0(sp)
ffffffffc02010b2:	0141                	addi	sp,sp,16
ffffffffc02010b4:	1c30606f          	j	ffffffffc0207a76 <syscall>
ffffffffc02010b8:	0000b517          	auipc	a0,0xb
ffffffffc02010bc:	28050513          	addi	a0,a0,640 # ffffffffc020c338 <commands+0x868>
ffffffffc02010c0:	6402                	ld	s0,0(sp)
ffffffffc02010c2:	60a2                	ld	ra,8(sp)
ffffffffc02010c4:	0141                	addi	sp,sp,16
ffffffffc02010c6:	864ff06f          	j	ffffffffc020012a <cprintf>
ffffffffc02010ca:	0000b517          	auipc	a0,0xb
ffffffffc02010ce:	28e50513          	addi	a0,a0,654 # ffffffffc020c358 <commands+0x888>
ffffffffc02010d2:	b7fd                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc02010d4:	0000b517          	auipc	a0,0xb
ffffffffc02010d8:	2a450513          	addi	a0,a0,676 # ffffffffc020c378 <commands+0x8a8>
ffffffffc02010dc:	84eff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02010e0:	10043783          	ld	a5,256(s0)
ffffffffc02010e4:	1007f793          	andi	a5,a5,256
ffffffffc02010e8:	c385                	beqz	a5,ffffffffc0201108 <exception_handler+0x94>
ffffffffc02010ea:	60a2                	ld	ra,8(sp)
ffffffffc02010ec:	6402                	ld	s0,0(sp)
ffffffffc02010ee:	0141                	addi	sp,sp,16
ffffffffc02010f0:	8082                	ret
ffffffffc02010f2:	0000b517          	auipc	a0,0xb
ffffffffc02010f6:	29e50513          	addi	a0,a0,670 # ffffffffc020c390 <commands+0x8c0>
ffffffffc02010fa:	830ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02010fe:	10043783          	ld	a5,256(s0)
ffffffffc0201102:	1007f793          	andi	a5,a5,256
ffffffffc0201106:	f3f5                	bnez	a5,ffffffffc02010ea <exception_handler+0x76>
ffffffffc0201108:	00096797          	auipc	a5,0x96
ffffffffc020110c:	8007b783          	ld	a5,-2048(a5) # ffffffffc0296908 <current>
ffffffffc0201110:	11043603          	ld	a2,272(s0)
ffffffffc0201114:	11843583          	ld	a1,280(s0)
ffffffffc0201118:	7788                	ld	a0,40(a5)
ffffffffc020111a:	569010ef          	jal	ra,ffffffffc0202e82 <do_pgfault>
ffffffffc020111e:	d571                	beqz	a0,ffffffffc02010ea <exception_handler+0x76>
ffffffffc0201120:	a841                	j	ffffffffc02011b0 <exception_handler+0x13c>
ffffffffc0201122:	0000b517          	auipc	a0,0xb
ffffffffc0201126:	28650513          	addi	a0,a0,646 # ffffffffc020c3a8 <commands+0x8d8>
ffffffffc020112a:	800ff0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020112e:	10043783          	ld	a5,256(s0)
ffffffffc0201132:	1007f793          	andi	a5,a5,256
ffffffffc0201136:	fbd5                	bnez	a5,ffffffffc02010ea <exception_handler+0x76>
ffffffffc0201138:	bfc1                	j	ffffffffc0201108 <exception_handler+0x94>
ffffffffc020113a:	0000b517          	auipc	a0,0xb
ffffffffc020113e:	0d650513          	addi	a0,a0,214 # ffffffffc020c210 <commands+0x740>
ffffffffc0201142:	fe9fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201146:	10043783          	ld	a5,256(s0)
ffffffffc020114a:	1007f793          	andi	a5,a5,256
ffffffffc020114e:	ffd1                	bnez	a5,ffffffffc02010ea <exception_handler+0x76>
ffffffffc0201150:	a085                	j	ffffffffc02011b0 <exception_handler+0x13c>
ffffffffc0201152:	0000b517          	auipc	a0,0xb
ffffffffc0201156:	0de50513          	addi	a0,a0,222 # ffffffffc020c230 <commands+0x760>
ffffffffc020115a:	fd1fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020115e:	10043783          	ld	a5,256(s0)
ffffffffc0201162:	1007f793          	andi	a5,a5,256
ffffffffc0201166:	f3d1                	bnez	a5,ffffffffc02010ea <exception_handler+0x76>
ffffffffc0201168:	a0a1                	j	ffffffffc02011b0 <exception_handler+0x13c>
ffffffffc020116a:	0000b517          	auipc	a0,0xb
ffffffffc020116e:	10e50513          	addi	a0,a0,270 # ffffffffc020c278 <commands+0x7a8>
ffffffffc0201172:	fb9fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201176:	10043783          	ld	a5,256(s0)
ffffffffc020117a:	1007f793          	andi	a5,a5,256
ffffffffc020117e:	f7b5                	bnez	a5,ffffffffc02010ea <exception_handler+0x76>
ffffffffc0201180:	a805                	j	ffffffffc02011b0 <exception_handler+0x13c>
ffffffffc0201182:	0000b517          	auipc	a0,0xb
ffffffffc0201186:	11650513          	addi	a0,a0,278 # ffffffffc020c298 <commands+0x7c8>
ffffffffc020118a:	fa1fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020118e:	10043783          	ld	a5,256(s0)
ffffffffc0201192:	1007f793          	andi	a5,a5,256
ffffffffc0201196:	fbb1                	bnez	a5,ffffffffc02010ea <exception_handler+0x76>
ffffffffc0201198:	a821                	j	ffffffffc02011b0 <exception_handler+0x13c>
ffffffffc020119a:	0000b517          	auipc	a0,0xb
ffffffffc020119e:	11650513          	addi	a0,a0,278 # ffffffffc020c2b0 <commands+0x7e0>
ffffffffc02011a2:	f89fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02011a6:	10043783          	ld	a5,256(s0)
ffffffffc02011aa:	1007f793          	andi	a5,a5,256
ffffffffc02011ae:	ebb9                	bnez	a5,ffffffffc0201204 <exception_handler+0x190>
ffffffffc02011b0:	6402                	ld	s0,0(sp)
ffffffffc02011b2:	60a2                	ld	ra,8(sp)
ffffffffc02011b4:	555d                	li	a0,-9
ffffffffc02011b6:	0141                	addi	sp,sp,16
ffffffffc02011b8:	01e0506f          	j	ffffffffc02061d6 <do_exit>
ffffffffc02011bc:	0000b517          	auipc	a0,0xb
ffffffffc02011c0:	14450513          	addi	a0,a0,324 # ffffffffc020c300 <commands+0x830>
ffffffffc02011c4:	f67fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02011c8:	10043783          	ld	a5,256(s0)
ffffffffc02011cc:	1007f793          	andi	a5,a5,256
ffffffffc02011d0:	f0079de3          	bnez	a5,ffffffffc02010ea <exception_handler+0x76>
ffffffffc02011d4:	bff1                	j	ffffffffc02011b0 <exception_handler+0x13c>
ffffffffc02011d6:	0000b517          	auipc	a0,0xb
ffffffffc02011da:	07a50513          	addi	a0,a0,122 # ffffffffc020c250 <commands+0x780>
ffffffffc02011de:	f4dfe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02011e2:	10043783          	ld	a5,256(s0)
ffffffffc02011e6:	1007f793          	andi	a5,a5,256
ffffffffc02011ea:	f00790e3          	bnez	a5,ffffffffc02010ea <exception_handler+0x76>
ffffffffc02011ee:	b7c9                	j	ffffffffc02011b0 <exception_handler+0x13c>
ffffffffc02011f0:	0000b517          	auipc	a0,0xb
ffffffffc02011f4:	07850513          	addi	a0,a0,120 # ffffffffc020c268 <commands+0x798>
ffffffffc02011f8:	b5e1                	j	ffffffffc02010c0 <exception_handler+0x4c>
ffffffffc02011fa:	8522                	mv	a0,s0
ffffffffc02011fc:	6402                	ld	s0,0(sp)
ffffffffc02011fe:	60a2                	ld	ra,8(sp)
ffffffffc0201200:	0141                	addi	sp,sp,16
ffffffffc0201202:	b371                	j	ffffffffc0200f8e <print_trapframe>
ffffffffc0201204:	0000b617          	auipc	a2,0xb
ffffffffc0201208:	0c460613          	addi	a2,a2,196 # ffffffffc020c2c8 <commands+0x7f8>
ffffffffc020120c:	0c500593          	li	a1,197
ffffffffc0201210:	0000b517          	auipc	a0,0xb
ffffffffc0201214:	0d850513          	addi	a0,a0,216 # ffffffffc020c2e8 <commands+0x818>
ffffffffc0201218:	816ff0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020121c <trap>:
ffffffffc020121c:	1101                	addi	sp,sp,-32
ffffffffc020121e:	e822                	sd	s0,16(sp)
ffffffffc0201220:	00095417          	auipc	s0,0x95
ffffffffc0201224:	6e840413          	addi	s0,s0,1768 # ffffffffc0296908 <current>
ffffffffc0201228:	6018                	ld	a4,0(s0)
ffffffffc020122a:	ec06                	sd	ra,24(sp)
ffffffffc020122c:	e426                	sd	s1,8(sp)
ffffffffc020122e:	e04a                	sd	s2,0(sp)
ffffffffc0201230:	11853683          	ld	a3,280(a0)
ffffffffc0201234:	cf1d                	beqz	a4,ffffffffc0201272 <trap+0x56>
ffffffffc0201236:	10053483          	ld	s1,256(a0)
ffffffffc020123a:	0a073903          	ld	s2,160(a4)
ffffffffc020123e:	f348                	sd	a0,160(a4)
ffffffffc0201240:	1004f493          	andi	s1,s1,256
ffffffffc0201244:	0206c463          	bltz	a3,ffffffffc020126c <trap+0x50>
ffffffffc0201248:	e2dff0ef          	jal	ra,ffffffffc0201074 <exception_handler>
ffffffffc020124c:	601c                	ld	a5,0(s0)
ffffffffc020124e:	0b27b023          	sd	s2,160(a5)
ffffffffc0201252:	e499                	bnez	s1,ffffffffc0201260 <trap+0x44>
ffffffffc0201254:	0b07a703          	lw	a4,176(a5)
ffffffffc0201258:	8b05                	andi	a4,a4,1
ffffffffc020125a:	e329                	bnez	a4,ffffffffc020129c <trap+0x80>
ffffffffc020125c:	6f9c                	ld	a5,24(a5)
ffffffffc020125e:	eb85                	bnez	a5,ffffffffc020128e <trap+0x72>
ffffffffc0201260:	60e2                	ld	ra,24(sp)
ffffffffc0201262:	6442                	ld	s0,16(sp)
ffffffffc0201264:	64a2                	ld	s1,8(sp)
ffffffffc0201266:	6902                	ld	s2,0(sp)
ffffffffc0201268:	6105                	addi	sp,sp,32
ffffffffc020126a:	8082                	ret
ffffffffc020126c:	d85ff0ef          	jal	ra,ffffffffc0200ff0 <interrupt_handler>
ffffffffc0201270:	bff1                	j	ffffffffc020124c <trap+0x30>
ffffffffc0201272:	0006c863          	bltz	a3,ffffffffc0201282 <trap+0x66>
ffffffffc0201276:	6442                	ld	s0,16(sp)
ffffffffc0201278:	60e2                	ld	ra,24(sp)
ffffffffc020127a:	64a2                	ld	s1,8(sp)
ffffffffc020127c:	6902                	ld	s2,0(sp)
ffffffffc020127e:	6105                	addi	sp,sp,32
ffffffffc0201280:	bbd5                	j	ffffffffc0201074 <exception_handler>
ffffffffc0201282:	6442                	ld	s0,16(sp)
ffffffffc0201284:	60e2                	ld	ra,24(sp)
ffffffffc0201286:	64a2                	ld	s1,8(sp)
ffffffffc0201288:	6902                	ld	s2,0(sp)
ffffffffc020128a:	6105                	addi	sp,sp,32
ffffffffc020128c:	b395                	j	ffffffffc0200ff0 <interrupt_handler>
ffffffffc020128e:	6442                	ld	s0,16(sp)
ffffffffc0201290:	60e2                	ld	ra,24(sp)
ffffffffc0201292:	64a2                	ld	s1,8(sp)
ffffffffc0201294:	6902                	ld	s2,0(sp)
ffffffffc0201296:	6105                	addi	sp,sp,32
ffffffffc0201298:	3bc0606f          	j	ffffffffc0207654 <schedule>
ffffffffc020129c:	555d                	li	a0,-9
ffffffffc020129e:	739040ef          	jal	ra,ffffffffc02061d6 <do_exit>
ffffffffc02012a2:	601c                	ld	a5,0(s0)
ffffffffc02012a4:	bf65                	j	ffffffffc020125c <trap+0x40>
	...

ffffffffc02012a8 <__alltraps>:
ffffffffc02012a8:	14011173          	csrrw	sp,sscratch,sp
ffffffffc02012ac:	00011463          	bnez	sp,ffffffffc02012b4 <__alltraps+0xc>
ffffffffc02012b0:	14002173          	csrr	sp,sscratch
ffffffffc02012b4:	712d                	addi	sp,sp,-288
ffffffffc02012b6:	e002                	sd	zero,0(sp)
ffffffffc02012b8:	e406                	sd	ra,8(sp)
ffffffffc02012ba:	ec0e                	sd	gp,24(sp)
ffffffffc02012bc:	f012                	sd	tp,32(sp)
ffffffffc02012be:	f416                	sd	t0,40(sp)
ffffffffc02012c0:	f81a                	sd	t1,48(sp)
ffffffffc02012c2:	fc1e                	sd	t2,56(sp)
ffffffffc02012c4:	e0a2                	sd	s0,64(sp)
ffffffffc02012c6:	e4a6                	sd	s1,72(sp)
ffffffffc02012c8:	e8aa                	sd	a0,80(sp)
ffffffffc02012ca:	ecae                	sd	a1,88(sp)
ffffffffc02012cc:	f0b2                	sd	a2,96(sp)
ffffffffc02012ce:	f4b6                	sd	a3,104(sp)
ffffffffc02012d0:	f8ba                	sd	a4,112(sp)
ffffffffc02012d2:	fcbe                	sd	a5,120(sp)
ffffffffc02012d4:	e142                	sd	a6,128(sp)
ffffffffc02012d6:	e546                	sd	a7,136(sp)
ffffffffc02012d8:	e94a                	sd	s2,144(sp)
ffffffffc02012da:	ed4e                	sd	s3,152(sp)
ffffffffc02012dc:	f152                	sd	s4,160(sp)
ffffffffc02012de:	f556                	sd	s5,168(sp)
ffffffffc02012e0:	f95a                	sd	s6,176(sp)
ffffffffc02012e2:	fd5e                	sd	s7,184(sp)
ffffffffc02012e4:	e1e2                	sd	s8,192(sp)
ffffffffc02012e6:	e5e6                	sd	s9,200(sp)
ffffffffc02012e8:	e9ea                	sd	s10,208(sp)
ffffffffc02012ea:	edee                	sd	s11,216(sp)
ffffffffc02012ec:	f1f2                	sd	t3,224(sp)
ffffffffc02012ee:	f5f6                	sd	t4,232(sp)
ffffffffc02012f0:	f9fa                	sd	t5,240(sp)
ffffffffc02012f2:	fdfe                	sd	t6,248(sp)
ffffffffc02012f4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02012f8:	100024f3          	csrr	s1,sstatus
ffffffffc02012fc:	14102973          	csrr	s2,sepc
ffffffffc0201300:	143029f3          	csrr	s3,stval
ffffffffc0201304:	14202a73          	csrr	s4,scause
ffffffffc0201308:	e822                	sd	s0,16(sp)
ffffffffc020130a:	e226                	sd	s1,256(sp)
ffffffffc020130c:	e64a                	sd	s2,264(sp)
ffffffffc020130e:	ea4e                	sd	s3,272(sp)
ffffffffc0201310:	ee52                	sd	s4,280(sp)
ffffffffc0201312:	850a                	mv	a0,sp
ffffffffc0201314:	f09ff0ef          	jal	ra,ffffffffc020121c <trap>

ffffffffc0201318 <__trapret>:
ffffffffc0201318:	6492                	ld	s1,256(sp)
ffffffffc020131a:	6932                	ld	s2,264(sp)
ffffffffc020131c:	1004f413          	andi	s0,s1,256
ffffffffc0201320:	e401                	bnez	s0,ffffffffc0201328 <__trapret+0x10>
ffffffffc0201322:	1200                	addi	s0,sp,288
ffffffffc0201324:	14041073          	csrw	sscratch,s0
ffffffffc0201328:	10049073          	csrw	sstatus,s1
ffffffffc020132c:	14191073          	csrw	sepc,s2
ffffffffc0201330:	60a2                	ld	ra,8(sp)
ffffffffc0201332:	61e2                	ld	gp,24(sp)
ffffffffc0201334:	7202                	ld	tp,32(sp)
ffffffffc0201336:	72a2                	ld	t0,40(sp)
ffffffffc0201338:	7342                	ld	t1,48(sp)
ffffffffc020133a:	73e2                	ld	t2,56(sp)
ffffffffc020133c:	6406                	ld	s0,64(sp)
ffffffffc020133e:	64a6                	ld	s1,72(sp)
ffffffffc0201340:	6546                	ld	a0,80(sp)
ffffffffc0201342:	65e6                	ld	a1,88(sp)
ffffffffc0201344:	7606                	ld	a2,96(sp)
ffffffffc0201346:	76a6                	ld	a3,104(sp)
ffffffffc0201348:	7746                	ld	a4,112(sp)
ffffffffc020134a:	77e6                	ld	a5,120(sp)
ffffffffc020134c:	680a                	ld	a6,128(sp)
ffffffffc020134e:	68aa                	ld	a7,136(sp)
ffffffffc0201350:	694a                	ld	s2,144(sp)
ffffffffc0201352:	69ea                	ld	s3,152(sp)
ffffffffc0201354:	7a0a                	ld	s4,160(sp)
ffffffffc0201356:	7aaa                	ld	s5,168(sp)
ffffffffc0201358:	7b4a                	ld	s6,176(sp)
ffffffffc020135a:	7bea                	ld	s7,184(sp)
ffffffffc020135c:	6c0e                	ld	s8,192(sp)
ffffffffc020135e:	6cae                	ld	s9,200(sp)
ffffffffc0201360:	6d4e                	ld	s10,208(sp)
ffffffffc0201362:	6dee                	ld	s11,216(sp)
ffffffffc0201364:	7e0e                	ld	t3,224(sp)
ffffffffc0201366:	7eae                	ld	t4,232(sp)
ffffffffc0201368:	7f4e                	ld	t5,240(sp)
ffffffffc020136a:	7fee                	ld	t6,248(sp)
ffffffffc020136c:	6142                	ld	sp,16(sp)
ffffffffc020136e:	10200073          	sret

ffffffffc0201372 <forkrets>:
ffffffffc0201372:	812a                	mv	sp,a0
ffffffffc0201374:	b755                	j	ffffffffc0201318 <__trapret>

ffffffffc0201376 <pa2page.part.0>:
ffffffffc0201376:	1141                	addi	sp,sp,-16
ffffffffc0201378:	0000b617          	auipc	a2,0xb
ffffffffc020137c:	08860613          	addi	a2,a2,136 # ffffffffc020c400 <commands+0x930>
ffffffffc0201380:	06900593          	li	a1,105
ffffffffc0201384:	0000b517          	auipc	a0,0xb
ffffffffc0201388:	09c50513          	addi	a0,a0,156 # ffffffffc020c420 <commands+0x950>
ffffffffc020138c:	e406                	sd	ra,8(sp)
ffffffffc020138e:	ea1fe0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0201392 <pte2page.part.0>:
ffffffffc0201392:	1141                	addi	sp,sp,-16
ffffffffc0201394:	0000b617          	auipc	a2,0xb
ffffffffc0201398:	09c60613          	addi	a2,a2,156 # ffffffffc020c430 <commands+0x960>
ffffffffc020139c:	07f00593          	li	a1,127
ffffffffc02013a0:	0000b517          	auipc	a0,0xb
ffffffffc02013a4:	08050513          	addi	a0,a0,128 # ffffffffc020c420 <commands+0x950>
ffffffffc02013a8:	e406                	sd	ra,8(sp)
ffffffffc02013aa:	e85fe0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02013ae <alloc_pages>:
ffffffffc02013ae:	100027f3          	csrr	a5,sstatus
ffffffffc02013b2:	8b89                	andi	a5,a5,2
ffffffffc02013b4:	e799                	bnez	a5,ffffffffc02013c2 <alloc_pages+0x14>
ffffffffc02013b6:	00095797          	auipc	a5,0x95
ffffffffc02013ba:	5327b783          	ld	a5,1330(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc02013be:	6f9c                	ld	a5,24(a5)
ffffffffc02013c0:	8782                	jr	a5
ffffffffc02013c2:	1141                	addi	sp,sp,-16
ffffffffc02013c4:	e406                	sd	ra,8(sp)
ffffffffc02013c6:	e022                	sd	s0,0(sp)
ffffffffc02013c8:	842a                	mv	s0,a0
ffffffffc02013ca:	9d7ff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02013ce:	00095797          	auipc	a5,0x95
ffffffffc02013d2:	51a7b783          	ld	a5,1306(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc02013d6:	6f9c                	ld	a5,24(a5)
ffffffffc02013d8:	8522                	mv	a0,s0
ffffffffc02013da:	9782                	jalr	a5
ffffffffc02013dc:	842a                	mv	s0,a0
ffffffffc02013de:	9bdff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02013e2:	60a2                	ld	ra,8(sp)
ffffffffc02013e4:	8522                	mv	a0,s0
ffffffffc02013e6:	6402                	ld	s0,0(sp)
ffffffffc02013e8:	0141                	addi	sp,sp,16
ffffffffc02013ea:	8082                	ret

ffffffffc02013ec <free_pages>:
ffffffffc02013ec:	100027f3          	csrr	a5,sstatus
ffffffffc02013f0:	8b89                	andi	a5,a5,2
ffffffffc02013f2:	e799                	bnez	a5,ffffffffc0201400 <free_pages+0x14>
ffffffffc02013f4:	00095797          	auipc	a5,0x95
ffffffffc02013f8:	4f47b783          	ld	a5,1268(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc02013fc:	739c                	ld	a5,32(a5)
ffffffffc02013fe:	8782                	jr	a5
ffffffffc0201400:	1101                	addi	sp,sp,-32
ffffffffc0201402:	ec06                	sd	ra,24(sp)
ffffffffc0201404:	e822                	sd	s0,16(sp)
ffffffffc0201406:	e426                	sd	s1,8(sp)
ffffffffc0201408:	842a                	mv	s0,a0
ffffffffc020140a:	84ae                	mv	s1,a1
ffffffffc020140c:	995ff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201410:	00095797          	auipc	a5,0x95
ffffffffc0201414:	4d87b783          	ld	a5,1240(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc0201418:	739c                	ld	a5,32(a5)
ffffffffc020141a:	85a6                	mv	a1,s1
ffffffffc020141c:	8522                	mv	a0,s0
ffffffffc020141e:	9782                	jalr	a5
ffffffffc0201420:	6442                	ld	s0,16(sp)
ffffffffc0201422:	60e2                	ld	ra,24(sp)
ffffffffc0201424:	64a2                	ld	s1,8(sp)
ffffffffc0201426:	6105                	addi	sp,sp,32
ffffffffc0201428:	973ff06f          	j	ffffffffc0200d9a <intr_enable>

ffffffffc020142c <nr_free_pages>:
ffffffffc020142c:	100027f3          	csrr	a5,sstatus
ffffffffc0201430:	8b89                	andi	a5,a5,2
ffffffffc0201432:	e799                	bnez	a5,ffffffffc0201440 <nr_free_pages+0x14>
ffffffffc0201434:	00095797          	auipc	a5,0x95
ffffffffc0201438:	4b47b783          	ld	a5,1204(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc020143c:	779c                	ld	a5,40(a5)
ffffffffc020143e:	8782                	jr	a5
ffffffffc0201440:	1141                	addi	sp,sp,-16
ffffffffc0201442:	e406                	sd	ra,8(sp)
ffffffffc0201444:	e022                	sd	s0,0(sp)
ffffffffc0201446:	95bff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020144a:	00095797          	auipc	a5,0x95
ffffffffc020144e:	49e7b783          	ld	a5,1182(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc0201452:	779c                	ld	a5,40(a5)
ffffffffc0201454:	9782                	jalr	a5
ffffffffc0201456:	842a                	mv	s0,a0
ffffffffc0201458:	943ff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020145c:	60a2                	ld	ra,8(sp)
ffffffffc020145e:	8522                	mv	a0,s0
ffffffffc0201460:	6402                	ld	s0,0(sp)
ffffffffc0201462:	0141                	addi	sp,sp,16
ffffffffc0201464:	8082                	ret

ffffffffc0201466 <get_pte>:
ffffffffc0201466:	01e5d793          	srli	a5,a1,0x1e
ffffffffc020146a:	1ff7f793          	andi	a5,a5,511
ffffffffc020146e:	7139                	addi	sp,sp,-64
ffffffffc0201470:	078e                	slli	a5,a5,0x3
ffffffffc0201472:	f426                	sd	s1,40(sp)
ffffffffc0201474:	00f504b3          	add	s1,a0,a5
ffffffffc0201478:	6094                	ld	a3,0(s1)
ffffffffc020147a:	f04a                	sd	s2,32(sp)
ffffffffc020147c:	ec4e                	sd	s3,24(sp)
ffffffffc020147e:	e852                	sd	s4,16(sp)
ffffffffc0201480:	fc06                	sd	ra,56(sp)
ffffffffc0201482:	f822                	sd	s0,48(sp)
ffffffffc0201484:	e456                	sd	s5,8(sp)
ffffffffc0201486:	e05a                	sd	s6,0(sp)
ffffffffc0201488:	0016f793          	andi	a5,a3,1
ffffffffc020148c:	892e                	mv	s2,a1
ffffffffc020148e:	8a32                	mv	s4,a2
ffffffffc0201490:	00095997          	auipc	s3,0x95
ffffffffc0201494:	44898993          	addi	s3,s3,1096 # ffffffffc02968d8 <npage>
ffffffffc0201498:	efbd                	bnez	a5,ffffffffc0201516 <get_pte+0xb0>
ffffffffc020149a:	14060c63          	beqz	a2,ffffffffc02015f2 <get_pte+0x18c>
ffffffffc020149e:	100027f3          	csrr	a5,sstatus
ffffffffc02014a2:	8b89                	andi	a5,a5,2
ffffffffc02014a4:	14079963          	bnez	a5,ffffffffc02015f6 <get_pte+0x190>
ffffffffc02014a8:	00095797          	auipc	a5,0x95
ffffffffc02014ac:	4407b783          	ld	a5,1088(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc02014b0:	6f9c                	ld	a5,24(a5)
ffffffffc02014b2:	4505                	li	a0,1
ffffffffc02014b4:	9782                	jalr	a5
ffffffffc02014b6:	842a                	mv	s0,a0
ffffffffc02014b8:	12040d63          	beqz	s0,ffffffffc02015f2 <get_pte+0x18c>
ffffffffc02014bc:	00095b17          	auipc	s6,0x95
ffffffffc02014c0:	424b0b13          	addi	s6,s6,1060 # ffffffffc02968e0 <pages>
ffffffffc02014c4:	000b3503          	ld	a0,0(s6)
ffffffffc02014c8:	00080ab7          	lui	s5,0x80
ffffffffc02014cc:	00095997          	auipc	s3,0x95
ffffffffc02014d0:	40c98993          	addi	s3,s3,1036 # ffffffffc02968d8 <npage>
ffffffffc02014d4:	40a40533          	sub	a0,s0,a0
ffffffffc02014d8:	8519                	srai	a0,a0,0x6
ffffffffc02014da:	9556                	add	a0,a0,s5
ffffffffc02014dc:	0009b703          	ld	a4,0(s3)
ffffffffc02014e0:	00c51793          	slli	a5,a0,0xc
ffffffffc02014e4:	4685                	li	a3,1
ffffffffc02014e6:	c014                	sw	a3,0(s0)
ffffffffc02014e8:	83b1                	srli	a5,a5,0xc
ffffffffc02014ea:	0532                	slli	a0,a0,0xc
ffffffffc02014ec:	16e7f763          	bgeu	a5,a4,ffffffffc020165a <get_pte+0x1f4>
ffffffffc02014f0:	00095797          	auipc	a5,0x95
ffffffffc02014f4:	4007b783          	ld	a5,1024(a5) # ffffffffc02968f0 <va_pa_offset>
ffffffffc02014f8:	6605                	lui	a2,0x1
ffffffffc02014fa:	4581                	li	a1,0
ffffffffc02014fc:	953e                	add	a0,a0,a5
ffffffffc02014fe:	62f090ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc0201502:	000b3683          	ld	a3,0(s6)
ffffffffc0201506:	40d406b3          	sub	a3,s0,a3
ffffffffc020150a:	8699                	srai	a3,a3,0x6
ffffffffc020150c:	96d6                	add	a3,a3,s5
ffffffffc020150e:	06aa                	slli	a3,a3,0xa
ffffffffc0201510:	0116e693          	ori	a3,a3,17
ffffffffc0201514:	e094                	sd	a3,0(s1)
ffffffffc0201516:	77fd                	lui	a5,0xfffff
ffffffffc0201518:	068a                	slli	a3,a3,0x2
ffffffffc020151a:	0009b703          	ld	a4,0(s3)
ffffffffc020151e:	8efd                	and	a3,a3,a5
ffffffffc0201520:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201524:	10e7ff63          	bgeu	a5,a4,ffffffffc0201642 <get_pte+0x1dc>
ffffffffc0201528:	00095a97          	auipc	s5,0x95
ffffffffc020152c:	3c8a8a93          	addi	s5,s5,968 # ffffffffc02968f0 <va_pa_offset>
ffffffffc0201530:	000ab403          	ld	s0,0(s5)
ffffffffc0201534:	01595793          	srli	a5,s2,0x15
ffffffffc0201538:	1ff7f793          	andi	a5,a5,511
ffffffffc020153c:	96a2                	add	a3,a3,s0
ffffffffc020153e:	00379413          	slli	s0,a5,0x3
ffffffffc0201542:	9436                	add	s0,s0,a3
ffffffffc0201544:	6014                	ld	a3,0(s0)
ffffffffc0201546:	0016f793          	andi	a5,a3,1
ffffffffc020154a:	ebad                	bnez	a5,ffffffffc02015bc <get_pte+0x156>
ffffffffc020154c:	0a0a0363          	beqz	s4,ffffffffc02015f2 <get_pte+0x18c>
ffffffffc0201550:	100027f3          	csrr	a5,sstatus
ffffffffc0201554:	8b89                	andi	a5,a5,2
ffffffffc0201556:	efcd                	bnez	a5,ffffffffc0201610 <get_pte+0x1aa>
ffffffffc0201558:	00095797          	auipc	a5,0x95
ffffffffc020155c:	3907b783          	ld	a5,912(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc0201560:	6f9c                	ld	a5,24(a5)
ffffffffc0201562:	4505                	li	a0,1
ffffffffc0201564:	9782                	jalr	a5
ffffffffc0201566:	84aa                	mv	s1,a0
ffffffffc0201568:	c4c9                	beqz	s1,ffffffffc02015f2 <get_pte+0x18c>
ffffffffc020156a:	00095b17          	auipc	s6,0x95
ffffffffc020156e:	376b0b13          	addi	s6,s6,886 # ffffffffc02968e0 <pages>
ffffffffc0201572:	000b3503          	ld	a0,0(s6)
ffffffffc0201576:	00080a37          	lui	s4,0x80
ffffffffc020157a:	0009b703          	ld	a4,0(s3)
ffffffffc020157e:	40a48533          	sub	a0,s1,a0
ffffffffc0201582:	8519                	srai	a0,a0,0x6
ffffffffc0201584:	9552                	add	a0,a0,s4
ffffffffc0201586:	00c51793          	slli	a5,a0,0xc
ffffffffc020158a:	4685                	li	a3,1
ffffffffc020158c:	c094                	sw	a3,0(s1)
ffffffffc020158e:	83b1                	srli	a5,a5,0xc
ffffffffc0201590:	0532                	slli	a0,a0,0xc
ffffffffc0201592:	0ee7f163          	bgeu	a5,a4,ffffffffc0201674 <get_pte+0x20e>
ffffffffc0201596:	000ab783          	ld	a5,0(s5)
ffffffffc020159a:	6605                	lui	a2,0x1
ffffffffc020159c:	4581                	li	a1,0
ffffffffc020159e:	953e                	add	a0,a0,a5
ffffffffc02015a0:	58d090ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc02015a4:	000b3683          	ld	a3,0(s6)
ffffffffc02015a8:	40d486b3          	sub	a3,s1,a3
ffffffffc02015ac:	8699                	srai	a3,a3,0x6
ffffffffc02015ae:	96d2                	add	a3,a3,s4
ffffffffc02015b0:	06aa                	slli	a3,a3,0xa
ffffffffc02015b2:	0116e693          	ori	a3,a3,17
ffffffffc02015b6:	e014                	sd	a3,0(s0)
ffffffffc02015b8:	0009b703          	ld	a4,0(s3)
ffffffffc02015bc:	068a                	slli	a3,a3,0x2
ffffffffc02015be:	757d                	lui	a0,0xfffff
ffffffffc02015c0:	8ee9                	and	a3,a3,a0
ffffffffc02015c2:	00c6d793          	srli	a5,a3,0xc
ffffffffc02015c6:	06e7f263          	bgeu	a5,a4,ffffffffc020162a <get_pte+0x1c4>
ffffffffc02015ca:	000ab503          	ld	a0,0(s5)
ffffffffc02015ce:	00c95913          	srli	s2,s2,0xc
ffffffffc02015d2:	1ff97913          	andi	s2,s2,511
ffffffffc02015d6:	96aa                	add	a3,a3,a0
ffffffffc02015d8:	00391513          	slli	a0,s2,0x3
ffffffffc02015dc:	9536                	add	a0,a0,a3
ffffffffc02015de:	70e2                	ld	ra,56(sp)
ffffffffc02015e0:	7442                	ld	s0,48(sp)
ffffffffc02015e2:	74a2                	ld	s1,40(sp)
ffffffffc02015e4:	7902                	ld	s2,32(sp)
ffffffffc02015e6:	69e2                	ld	s3,24(sp)
ffffffffc02015e8:	6a42                	ld	s4,16(sp)
ffffffffc02015ea:	6aa2                	ld	s5,8(sp)
ffffffffc02015ec:	6b02                	ld	s6,0(sp)
ffffffffc02015ee:	6121                	addi	sp,sp,64
ffffffffc02015f0:	8082                	ret
ffffffffc02015f2:	4501                	li	a0,0
ffffffffc02015f4:	b7ed                	j	ffffffffc02015de <get_pte+0x178>
ffffffffc02015f6:	faaff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02015fa:	00095797          	auipc	a5,0x95
ffffffffc02015fe:	2ee7b783          	ld	a5,750(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc0201602:	6f9c                	ld	a5,24(a5)
ffffffffc0201604:	4505                	li	a0,1
ffffffffc0201606:	9782                	jalr	a5
ffffffffc0201608:	842a                	mv	s0,a0
ffffffffc020160a:	f90ff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020160e:	b56d                	j	ffffffffc02014b8 <get_pte+0x52>
ffffffffc0201610:	f90ff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201614:	00095797          	auipc	a5,0x95
ffffffffc0201618:	2d47b783          	ld	a5,724(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc020161c:	6f9c                	ld	a5,24(a5)
ffffffffc020161e:	4505                	li	a0,1
ffffffffc0201620:	9782                	jalr	a5
ffffffffc0201622:	84aa                	mv	s1,a0
ffffffffc0201624:	f76ff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0201628:	b781                	j	ffffffffc0201568 <get_pte+0x102>
ffffffffc020162a:	0000b617          	auipc	a2,0xb
ffffffffc020162e:	e2e60613          	addi	a2,a2,-466 # ffffffffc020c458 <commands+0x988>
ffffffffc0201632:	0fa00593          	li	a1,250
ffffffffc0201636:	0000b517          	auipc	a0,0xb
ffffffffc020163a:	e4a50513          	addi	a0,a0,-438 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020163e:	bf1fe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201642:	0000b617          	auipc	a2,0xb
ffffffffc0201646:	e1660613          	addi	a2,a2,-490 # ffffffffc020c458 <commands+0x988>
ffffffffc020164a:	0ed00593          	li	a1,237
ffffffffc020164e:	0000b517          	auipc	a0,0xb
ffffffffc0201652:	e3250513          	addi	a0,a0,-462 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0201656:	bd9fe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020165a:	86aa                	mv	a3,a0
ffffffffc020165c:	0000b617          	auipc	a2,0xb
ffffffffc0201660:	dfc60613          	addi	a2,a2,-516 # ffffffffc020c458 <commands+0x988>
ffffffffc0201664:	0e900593          	li	a1,233
ffffffffc0201668:	0000b517          	auipc	a0,0xb
ffffffffc020166c:	e1850513          	addi	a0,a0,-488 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0201670:	bbffe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201674:	86aa                	mv	a3,a0
ffffffffc0201676:	0000b617          	auipc	a2,0xb
ffffffffc020167a:	de260613          	addi	a2,a2,-542 # ffffffffc020c458 <commands+0x988>
ffffffffc020167e:	0f700593          	li	a1,247
ffffffffc0201682:	0000b517          	auipc	a0,0xb
ffffffffc0201686:	dfe50513          	addi	a0,a0,-514 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020168a:	ba5fe0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020168e <get_page>:
ffffffffc020168e:	1141                	addi	sp,sp,-16
ffffffffc0201690:	e022                	sd	s0,0(sp)
ffffffffc0201692:	8432                	mv	s0,a2
ffffffffc0201694:	4601                	li	a2,0
ffffffffc0201696:	e406                	sd	ra,8(sp)
ffffffffc0201698:	dcfff0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc020169c:	c011                	beqz	s0,ffffffffc02016a0 <get_page+0x12>
ffffffffc020169e:	e008                	sd	a0,0(s0)
ffffffffc02016a0:	c511                	beqz	a0,ffffffffc02016ac <get_page+0x1e>
ffffffffc02016a2:	611c                	ld	a5,0(a0)
ffffffffc02016a4:	4501                	li	a0,0
ffffffffc02016a6:	0017f713          	andi	a4,a5,1
ffffffffc02016aa:	e709                	bnez	a4,ffffffffc02016b4 <get_page+0x26>
ffffffffc02016ac:	60a2                	ld	ra,8(sp)
ffffffffc02016ae:	6402                	ld	s0,0(sp)
ffffffffc02016b0:	0141                	addi	sp,sp,16
ffffffffc02016b2:	8082                	ret
ffffffffc02016b4:	078a                	slli	a5,a5,0x2
ffffffffc02016b6:	83b1                	srli	a5,a5,0xc
ffffffffc02016b8:	00095717          	auipc	a4,0x95
ffffffffc02016bc:	22073703          	ld	a4,544(a4) # ffffffffc02968d8 <npage>
ffffffffc02016c0:	00e7ff63          	bgeu	a5,a4,ffffffffc02016de <get_page+0x50>
ffffffffc02016c4:	60a2                	ld	ra,8(sp)
ffffffffc02016c6:	6402                	ld	s0,0(sp)
ffffffffc02016c8:	fff80537          	lui	a0,0xfff80
ffffffffc02016cc:	97aa                	add	a5,a5,a0
ffffffffc02016ce:	079a                	slli	a5,a5,0x6
ffffffffc02016d0:	00095517          	auipc	a0,0x95
ffffffffc02016d4:	21053503          	ld	a0,528(a0) # ffffffffc02968e0 <pages>
ffffffffc02016d8:	953e                	add	a0,a0,a5
ffffffffc02016da:	0141                	addi	sp,sp,16
ffffffffc02016dc:	8082                	ret
ffffffffc02016de:	c99ff0ef          	jal	ra,ffffffffc0201376 <pa2page.part.0>

ffffffffc02016e2 <unmap_range>:
ffffffffc02016e2:	7159                	addi	sp,sp,-112
ffffffffc02016e4:	00c5e7b3          	or	a5,a1,a2
ffffffffc02016e8:	f486                	sd	ra,104(sp)
ffffffffc02016ea:	f0a2                	sd	s0,96(sp)
ffffffffc02016ec:	eca6                	sd	s1,88(sp)
ffffffffc02016ee:	e8ca                	sd	s2,80(sp)
ffffffffc02016f0:	e4ce                	sd	s3,72(sp)
ffffffffc02016f2:	e0d2                	sd	s4,64(sp)
ffffffffc02016f4:	fc56                	sd	s5,56(sp)
ffffffffc02016f6:	f85a                	sd	s6,48(sp)
ffffffffc02016f8:	f45e                	sd	s7,40(sp)
ffffffffc02016fa:	f062                	sd	s8,32(sp)
ffffffffc02016fc:	ec66                	sd	s9,24(sp)
ffffffffc02016fe:	e86a                	sd	s10,16(sp)
ffffffffc0201700:	17d2                	slli	a5,a5,0x34
ffffffffc0201702:	e3ed                	bnez	a5,ffffffffc02017e4 <unmap_range+0x102>
ffffffffc0201704:	002007b7          	lui	a5,0x200
ffffffffc0201708:	842e                	mv	s0,a1
ffffffffc020170a:	0ef5ed63          	bltu	a1,a5,ffffffffc0201804 <unmap_range+0x122>
ffffffffc020170e:	8932                	mv	s2,a2
ffffffffc0201710:	0ec5fa63          	bgeu	a1,a2,ffffffffc0201804 <unmap_range+0x122>
ffffffffc0201714:	4785                	li	a5,1
ffffffffc0201716:	07fe                	slli	a5,a5,0x1f
ffffffffc0201718:	0ec7e663          	bltu	a5,a2,ffffffffc0201804 <unmap_range+0x122>
ffffffffc020171c:	89aa                	mv	s3,a0
ffffffffc020171e:	6a05                	lui	s4,0x1
ffffffffc0201720:	00095c97          	auipc	s9,0x95
ffffffffc0201724:	1b8c8c93          	addi	s9,s9,440 # ffffffffc02968d8 <npage>
ffffffffc0201728:	00095c17          	auipc	s8,0x95
ffffffffc020172c:	1b8c0c13          	addi	s8,s8,440 # ffffffffc02968e0 <pages>
ffffffffc0201730:	fff80bb7          	lui	s7,0xfff80
ffffffffc0201734:	00095d17          	auipc	s10,0x95
ffffffffc0201738:	1b4d0d13          	addi	s10,s10,436 # ffffffffc02968e8 <pmm_manager>
ffffffffc020173c:	00200b37          	lui	s6,0x200
ffffffffc0201740:	ffe00ab7          	lui	s5,0xffe00
ffffffffc0201744:	4601                	li	a2,0
ffffffffc0201746:	85a2                	mv	a1,s0
ffffffffc0201748:	854e                	mv	a0,s3
ffffffffc020174a:	d1dff0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc020174e:	84aa                	mv	s1,a0
ffffffffc0201750:	cd29                	beqz	a0,ffffffffc02017aa <unmap_range+0xc8>
ffffffffc0201752:	611c                	ld	a5,0(a0)
ffffffffc0201754:	e395                	bnez	a5,ffffffffc0201778 <unmap_range+0x96>
ffffffffc0201756:	9452                	add	s0,s0,s4
ffffffffc0201758:	ff2466e3          	bltu	s0,s2,ffffffffc0201744 <unmap_range+0x62>
ffffffffc020175c:	70a6                	ld	ra,104(sp)
ffffffffc020175e:	7406                	ld	s0,96(sp)
ffffffffc0201760:	64e6                	ld	s1,88(sp)
ffffffffc0201762:	6946                	ld	s2,80(sp)
ffffffffc0201764:	69a6                	ld	s3,72(sp)
ffffffffc0201766:	6a06                	ld	s4,64(sp)
ffffffffc0201768:	7ae2                	ld	s5,56(sp)
ffffffffc020176a:	7b42                	ld	s6,48(sp)
ffffffffc020176c:	7ba2                	ld	s7,40(sp)
ffffffffc020176e:	7c02                	ld	s8,32(sp)
ffffffffc0201770:	6ce2                	ld	s9,24(sp)
ffffffffc0201772:	6d42                	ld	s10,16(sp)
ffffffffc0201774:	6165                	addi	sp,sp,112
ffffffffc0201776:	8082                	ret
ffffffffc0201778:	0017f713          	andi	a4,a5,1
ffffffffc020177c:	df69                	beqz	a4,ffffffffc0201756 <unmap_range+0x74>
ffffffffc020177e:	000cb703          	ld	a4,0(s9)
ffffffffc0201782:	078a                	slli	a5,a5,0x2
ffffffffc0201784:	83b1                	srli	a5,a5,0xc
ffffffffc0201786:	08e7ff63          	bgeu	a5,a4,ffffffffc0201824 <unmap_range+0x142>
ffffffffc020178a:	000c3503          	ld	a0,0(s8)
ffffffffc020178e:	97de                	add	a5,a5,s7
ffffffffc0201790:	079a                	slli	a5,a5,0x6
ffffffffc0201792:	953e                	add	a0,a0,a5
ffffffffc0201794:	411c                	lw	a5,0(a0)
ffffffffc0201796:	fff7871b          	addiw	a4,a5,-1
ffffffffc020179a:	c118                	sw	a4,0(a0)
ffffffffc020179c:	cf11                	beqz	a4,ffffffffc02017b8 <unmap_range+0xd6>
ffffffffc020179e:	0004b023          	sd	zero,0(s1)
ffffffffc02017a2:	12040073          	sfence.vma	s0
ffffffffc02017a6:	9452                	add	s0,s0,s4
ffffffffc02017a8:	bf45                	j	ffffffffc0201758 <unmap_range+0x76>
ffffffffc02017aa:	945a                	add	s0,s0,s6
ffffffffc02017ac:	01547433          	and	s0,s0,s5
ffffffffc02017b0:	d455                	beqz	s0,ffffffffc020175c <unmap_range+0x7a>
ffffffffc02017b2:	f92469e3          	bltu	s0,s2,ffffffffc0201744 <unmap_range+0x62>
ffffffffc02017b6:	b75d                	j	ffffffffc020175c <unmap_range+0x7a>
ffffffffc02017b8:	100027f3          	csrr	a5,sstatus
ffffffffc02017bc:	8b89                	andi	a5,a5,2
ffffffffc02017be:	e799                	bnez	a5,ffffffffc02017cc <unmap_range+0xea>
ffffffffc02017c0:	000d3783          	ld	a5,0(s10)
ffffffffc02017c4:	4585                	li	a1,1
ffffffffc02017c6:	739c                	ld	a5,32(a5)
ffffffffc02017c8:	9782                	jalr	a5
ffffffffc02017ca:	bfd1                	j	ffffffffc020179e <unmap_range+0xbc>
ffffffffc02017cc:	e42a                	sd	a0,8(sp)
ffffffffc02017ce:	dd2ff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02017d2:	000d3783          	ld	a5,0(s10)
ffffffffc02017d6:	6522                	ld	a0,8(sp)
ffffffffc02017d8:	4585                	li	a1,1
ffffffffc02017da:	739c                	ld	a5,32(a5)
ffffffffc02017dc:	9782                	jalr	a5
ffffffffc02017de:	dbcff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02017e2:	bf75                	j	ffffffffc020179e <unmap_range+0xbc>
ffffffffc02017e4:	0000b697          	auipc	a3,0xb
ffffffffc02017e8:	cac68693          	addi	a3,a3,-852 # ffffffffc020c490 <commands+0x9c0>
ffffffffc02017ec:	0000a617          	auipc	a2,0xa
ffffffffc02017f0:	53460613          	addi	a2,a2,1332 # ffffffffc020bd20 <commands+0x250>
ffffffffc02017f4:	12000593          	li	a1,288
ffffffffc02017f8:	0000b517          	auipc	a0,0xb
ffffffffc02017fc:	c8850513          	addi	a0,a0,-888 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0201800:	a2ffe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201804:	0000b697          	auipc	a3,0xb
ffffffffc0201808:	cbc68693          	addi	a3,a3,-836 # ffffffffc020c4c0 <commands+0x9f0>
ffffffffc020180c:	0000a617          	auipc	a2,0xa
ffffffffc0201810:	51460613          	addi	a2,a2,1300 # ffffffffc020bd20 <commands+0x250>
ffffffffc0201814:	12100593          	li	a1,289
ffffffffc0201818:	0000b517          	auipc	a0,0xb
ffffffffc020181c:	c6850513          	addi	a0,a0,-920 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0201820:	a0ffe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201824:	b53ff0ef          	jal	ra,ffffffffc0201376 <pa2page.part.0>

ffffffffc0201828 <exit_range>:
ffffffffc0201828:	7119                	addi	sp,sp,-128
ffffffffc020182a:	00c5e7b3          	or	a5,a1,a2
ffffffffc020182e:	fc86                	sd	ra,120(sp)
ffffffffc0201830:	f8a2                	sd	s0,112(sp)
ffffffffc0201832:	f4a6                	sd	s1,104(sp)
ffffffffc0201834:	f0ca                	sd	s2,96(sp)
ffffffffc0201836:	ecce                	sd	s3,88(sp)
ffffffffc0201838:	e8d2                	sd	s4,80(sp)
ffffffffc020183a:	e4d6                	sd	s5,72(sp)
ffffffffc020183c:	e0da                	sd	s6,64(sp)
ffffffffc020183e:	fc5e                	sd	s7,56(sp)
ffffffffc0201840:	f862                	sd	s8,48(sp)
ffffffffc0201842:	f466                	sd	s9,40(sp)
ffffffffc0201844:	f06a                	sd	s10,32(sp)
ffffffffc0201846:	ec6e                	sd	s11,24(sp)
ffffffffc0201848:	17d2                	slli	a5,a5,0x34
ffffffffc020184a:	20079a63          	bnez	a5,ffffffffc0201a5e <exit_range+0x236>
ffffffffc020184e:	002007b7          	lui	a5,0x200
ffffffffc0201852:	24f5e463          	bltu	a1,a5,ffffffffc0201a9a <exit_range+0x272>
ffffffffc0201856:	8ab2                	mv	s5,a2
ffffffffc0201858:	24c5f163          	bgeu	a1,a2,ffffffffc0201a9a <exit_range+0x272>
ffffffffc020185c:	4785                	li	a5,1
ffffffffc020185e:	07fe                	slli	a5,a5,0x1f
ffffffffc0201860:	22c7ed63          	bltu	a5,a2,ffffffffc0201a9a <exit_range+0x272>
ffffffffc0201864:	c00009b7          	lui	s3,0xc0000
ffffffffc0201868:	0135f9b3          	and	s3,a1,s3
ffffffffc020186c:	ffe00937          	lui	s2,0xffe00
ffffffffc0201870:	400007b7          	lui	a5,0x40000
ffffffffc0201874:	5cfd                	li	s9,-1
ffffffffc0201876:	8c2a                	mv	s8,a0
ffffffffc0201878:	0125f933          	and	s2,a1,s2
ffffffffc020187c:	99be                	add	s3,s3,a5
ffffffffc020187e:	00095d17          	auipc	s10,0x95
ffffffffc0201882:	05ad0d13          	addi	s10,s10,90 # ffffffffc02968d8 <npage>
ffffffffc0201886:	00ccdc93          	srli	s9,s9,0xc
ffffffffc020188a:	00095717          	auipc	a4,0x95
ffffffffc020188e:	05670713          	addi	a4,a4,86 # ffffffffc02968e0 <pages>
ffffffffc0201892:	00095d97          	auipc	s11,0x95
ffffffffc0201896:	056d8d93          	addi	s11,s11,86 # ffffffffc02968e8 <pmm_manager>
ffffffffc020189a:	c0000437          	lui	s0,0xc0000
ffffffffc020189e:	944e                	add	s0,s0,s3
ffffffffc02018a0:	8079                	srli	s0,s0,0x1e
ffffffffc02018a2:	1ff47413          	andi	s0,s0,511
ffffffffc02018a6:	040e                	slli	s0,s0,0x3
ffffffffc02018a8:	9462                	add	s0,s0,s8
ffffffffc02018aa:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_bin_sfs_img_size+0xffffffffbff8ad00>
ffffffffc02018ae:	001a7793          	andi	a5,s4,1
ffffffffc02018b2:	eb99                	bnez	a5,ffffffffc02018c8 <exit_range+0xa0>
ffffffffc02018b4:	12098463          	beqz	s3,ffffffffc02019dc <exit_range+0x1b4>
ffffffffc02018b8:	400007b7          	lui	a5,0x40000
ffffffffc02018bc:	97ce                	add	a5,a5,s3
ffffffffc02018be:	894e                	mv	s2,s3
ffffffffc02018c0:	1159fe63          	bgeu	s3,s5,ffffffffc02019dc <exit_range+0x1b4>
ffffffffc02018c4:	89be                	mv	s3,a5
ffffffffc02018c6:	bfd1                	j	ffffffffc020189a <exit_range+0x72>
ffffffffc02018c8:	000d3783          	ld	a5,0(s10)
ffffffffc02018cc:	0a0a                	slli	s4,s4,0x2
ffffffffc02018ce:	00ca5a13          	srli	s4,s4,0xc
ffffffffc02018d2:	1cfa7263          	bgeu	s4,a5,ffffffffc0201a96 <exit_range+0x26e>
ffffffffc02018d6:	fff80637          	lui	a2,0xfff80
ffffffffc02018da:	9652                	add	a2,a2,s4
ffffffffc02018dc:	000806b7          	lui	a3,0x80
ffffffffc02018e0:	96b2                	add	a3,a3,a2
ffffffffc02018e2:	0196f5b3          	and	a1,a3,s9
ffffffffc02018e6:	061a                	slli	a2,a2,0x6
ffffffffc02018e8:	06b2                	slli	a3,a3,0xc
ffffffffc02018ea:	18f5fa63          	bgeu	a1,a5,ffffffffc0201a7e <exit_range+0x256>
ffffffffc02018ee:	00095817          	auipc	a6,0x95
ffffffffc02018f2:	00280813          	addi	a6,a6,2 # ffffffffc02968f0 <va_pa_offset>
ffffffffc02018f6:	00083b03          	ld	s6,0(a6)
ffffffffc02018fa:	4b85                	li	s7,1
ffffffffc02018fc:	fff80e37          	lui	t3,0xfff80
ffffffffc0201900:	9b36                	add	s6,s6,a3
ffffffffc0201902:	00080337          	lui	t1,0x80
ffffffffc0201906:	6885                	lui	a7,0x1
ffffffffc0201908:	a819                	j	ffffffffc020191e <exit_range+0xf6>
ffffffffc020190a:	4b81                	li	s7,0
ffffffffc020190c:	002007b7          	lui	a5,0x200
ffffffffc0201910:	993e                	add	s2,s2,a5
ffffffffc0201912:	08090c63          	beqz	s2,ffffffffc02019aa <exit_range+0x182>
ffffffffc0201916:	09397a63          	bgeu	s2,s3,ffffffffc02019aa <exit_range+0x182>
ffffffffc020191a:	0f597063          	bgeu	s2,s5,ffffffffc02019fa <exit_range+0x1d2>
ffffffffc020191e:	01595493          	srli	s1,s2,0x15
ffffffffc0201922:	1ff4f493          	andi	s1,s1,511
ffffffffc0201926:	048e                	slli	s1,s1,0x3
ffffffffc0201928:	94da                	add	s1,s1,s6
ffffffffc020192a:	609c                	ld	a5,0(s1)
ffffffffc020192c:	0017f693          	andi	a3,a5,1
ffffffffc0201930:	dee9                	beqz	a3,ffffffffc020190a <exit_range+0xe2>
ffffffffc0201932:	000d3583          	ld	a1,0(s10)
ffffffffc0201936:	078a                	slli	a5,a5,0x2
ffffffffc0201938:	83b1                	srli	a5,a5,0xc
ffffffffc020193a:	14b7fe63          	bgeu	a5,a1,ffffffffc0201a96 <exit_range+0x26e>
ffffffffc020193e:	97f2                	add	a5,a5,t3
ffffffffc0201940:	006786b3          	add	a3,a5,t1
ffffffffc0201944:	0196feb3          	and	t4,a3,s9
ffffffffc0201948:	00679513          	slli	a0,a5,0x6
ffffffffc020194c:	06b2                	slli	a3,a3,0xc
ffffffffc020194e:	12bef863          	bgeu	t4,a1,ffffffffc0201a7e <exit_range+0x256>
ffffffffc0201952:	00083783          	ld	a5,0(a6)
ffffffffc0201956:	96be                	add	a3,a3,a5
ffffffffc0201958:	011685b3          	add	a1,a3,a7
ffffffffc020195c:	629c                	ld	a5,0(a3)
ffffffffc020195e:	8b85                	andi	a5,a5,1
ffffffffc0201960:	f7d5                	bnez	a5,ffffffffc020190c <exit_range+0xe4>
ffffffffc0201962:	06a1                	addi	a3,a3,8
ffffffffc0201964:	fed59ce3          	bne	a1,a3,ffffffffc020195c <exit_range+0x134>
ffffffffc0201968:	631c                	ld	a5,0(a4)
ffffffffc020196a:	953e                	add	a0,a0,a5
ffffffffc020196c:	100027f3          	csrr	a5,sstatus
ffffffffc0201970:	8b89                	andi	a5,a5,2
ffffffffc0201972:	e7d9                	bnez	a5,ffffffffc0201a00 <exit_range+0x1d8>
ffffffffc0201974:	000db783          	ld	a5,0(s11)
ffffffffc0201978:	4585                	li	a1,1
ffffffffc020197a:	e032                	sd	a2,0(sp)
ffffffffc020197c:	739c                	ld	a5,32(a5)
ffffffffc020197e:	9782                	jalr	a5
ffffffffc0201980:	6602                	ld	a2,0(sp)
ffffffffc0201982:	00095817          	auipc	a6,0x95
ffffffffc0201986:	f6e80813          	addi	a6,a6,-146 # ffffffffc02968f0 <va_pa_offset>
ffffffffc020198a:	fff80e37          	lui	t3,0xfff80
ffffffffc020198e:	00080337          	lui	t1,0x80
ffffffffc0201992:	6885                	lui	a7,0x1
ffffffffc0201994:	00095717          	auipc	a4,0x95
ffffffffc0201998:	f4c70713          	addi	a4,a4,-180 # ffffffffc02968e0 <pages>
ffffffffc020199c:	0004b023          	sd	zero,0(s1)
ffffffffc02019a0:	002007b7          	lui	a5,0x200
ffffffffc02019a4:	993e                	add	s2,s2,a5
ffffffffc02019a6:	f60918e3          	bnez	s2,ffffffffc0201916 <exit_range+0xee>
ffffffffc02019aa:	f00b85e3          	beqz	s7,ffffffffc02018b4 <exit_range+0x8c>
ffffffffc02019ae:	000d3783          	ld	a5,0(s10)
ffffffffc02019b2:	0efa7263          	bgeu	s4,a5,ffffffffc0201a96 <exit_range+0x26e>
ffffffffc02019b6:	6308                	ld	a0,0(a4)
ffffffffc02019b8:	9532                	add	a0,a0,a2
ffffffffc02019ba:	100027f3          	csrr	a5,sstatus
ffffffffc02019be:	8b89                	andi	a5,a5,2
ffffffffc02019c0:	efad                	bnez	a5,ffffffffc0201a3a <exit_range+0x212>
ffffffffc02019c2:	000db783          	ld	a5,0(s11)
ffffffffc02019c6:	4585                	li	a1,1
ffffffffc02019c8:	739c                	ld	a5,32(a5)
ffffffffc02019ca:	9782                	jalr	a5
ffffffffc02019cc:	00095717          	auipc	a4,0x95
ffffffffc02019d0:	f1470713          	addi	a4,a4,-236 # ffffffffc02968e0 <pages>
ffffffffc02019d4:	00043023          	sd	zero,0(s0)
ffffffffc02019d8:	ee0990e3          	bnez	s3,ffffffffc02018b8 <exit_range+0x90>
ffffffffc02019dc:	70e6                	ld	ra,120(sp)
ffffffffc02019de:	7446                	ld	s0,112(sp)
ffffffffc02019e0:	74a6                	ld	s1,104(sp)
ffffffffc02019e2:	7906                	ld	s2,96(sp)
ffffffffc02019e4:	69e6                	ld	s3,88(sp)
ffffffffc02019e6:	6a46                	ld	s4,80(sp)
ffffffffc02019e8:	6aa6                	ld	s5,72(sp)
ffffffffc02019ea:	6b06                	ld	s6,64(sp)
ffffffffc02019ec:	7be2                	ld	s7,56(sp)
ffffffffc02019ee:	7c42                	ld	s8,48(sp)
ffffffffc02019f0:	7ca2                	ld	s9,40(sp)
ffffffffc02019f2:	7d02                	ld	s10,32(sp)
ffffffffc02019f4:	6de2                	ld	s11,24(sp)
ffffffffc02019f6:	6109                	addi	sp,sp,128
ffffffffc02019f8:	8082                	ret
ffffffffc02019fa:	ea0b8fe3          	beqz	s7,ffffffffc02018b8 <exit_range+0x90>
ffffffffc02019fe:	bf45                	j	ffffffffc02019ae <exit_range+0x186>
ffffffffc0201a00:	e032                	sd	a2,0(sp)
ffffffffc0201a02:	e42a                	sd	a0,8(sp)
ffffffffc0201a04:	b9cff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201a08:	000db783          	ld	a5,0(s11)
ffffffffc0201a0c:	6522                	ld	a0,8(sp)
ffffffffc0201a0e:	4585                	li	a1,1
ffffffffc0201a10:	739c                	ld	a5,32(a5)
ffffffffc0201a12:	9782                	jalr	a5
ffffffffc0201a14:	b86ff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0201a18:	6602                	ld	a2,0(sp)
ffffffffc0201a1a:	00095717          	auipc	a4,0x95
ffffffffc0201a1e:	ec670713          	addi	a4,a4,-314 # ffffffffc02968e0 <pages>
ffffffffc0201a22:	6885                	lui	a7,0x1
ffffffffc0201a24:	00080337          	lui	t1,0x80
ffffffffc0201a28:	fff80e37          	lui	t3,0xfff80
ffffffffc0201a2c:	00095817          	auipc	a6,0x95
ffffffffc0201a30:	ec480813          	addi	a6,a6,-316 # ffffffffc02968f0 <va_pa_offset>
ffffffffc0201a34:	0004b023          	sd	zero,0(s1)
ffffffffc0201a38:	b7a5                	j	ffffffffc02019a0 <exit_range+0x178>
ffffffffc0201a3a:	e02a                	sd	a0,0(sp)
ffffffffc0201a3c:	b64ff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201a40:	000db783          	ld	a5,0(s11)
ffffffffc0201a44:	6502                	ld	a0,0(sp)
ffffffffc0201a46:	4585                	li	a1,1
ffffffffc0201a48:	739c                	ld	a5,32(a5)
ffffffffc0201a4a:	9782                	jalr	a5
ffffffffc0201a4c:	b4eff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0201a50:	00095717          	auipc	a4,0x95
ffffffffc0201a54:	e9070713          	addi	a4,a4,-368 # ffffffffc02968e0 <pages>
ffffffffc0201a58:	00043023          	sd	zero,0(s0)
ffffffffc0201a5c:	bfb5                	j	ffffffffc02019d8 <exit_range+0x1b0>
ffffffffc0201a5e:	0000b697          	auipc	a3,0xb
ffffffffc0201a62:	a3268693          	addi	a3,a3,-1486 # ffffffffc020c490 <commands+0x9c0>
ffffffffc0201a66:	0000a617          	auipc	a2,0xa
ffffffffc0201a6a:	2ba60613          	addi	a2,a2,698 # ffffffffc020bd20 <commands+0x250>
ffffffffc0201a6e:	13500593          	li	a1,309
ffffffffc0201a72:	0000b517          	auipc	a0,0xb
ffffffffc0201a76:	a0e50513          	addi	a0,a0,-1522 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0201a7a:	fb4fe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201a7e:	0000b617          	auipc	a2,0xb
ffffffffc0201a82:	9da60613          	addi	a2,a2,-1574 # ffffffffc020c458 <commands+0x988>
ffffffffc0201a86:	07100593          	li	a1,113
ffffffffc0201a8a:	0000b517          	auipc	a0,0xb
ffffffffc0201a8e:	99650513          	addi	a0,a0,-1642 # ffffffffc020c420 <commands+0x950>
ffffffffc0201a92:	f9cfe0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0201a96:	8e1ff0ef          	jal	ra,ffffffffc0201376 <pa2page.part.0>
ffffffffc0201a9a:	0000b697          	auipc	a3,0xb
ffffffffc0201a9e:	a2668693          	addi	a3,a3,-1498 # ffffffffc020c4c0 <commands+0x9f0>
ffffffffc0201aa2:	0000a617          	auipc	a2,0xa
ffffffffc0201aa6:	27e60613          	addi	a2,a2,638 # ffffffffc020bd20 <commands+0x250>
ffffffffc0201aaa:	13600593          	li	a1,310
ffffffffc0201aae:	0000b517          	auipc	a0,0xb
ffffffffc0201ab2:	9d250513          	addi	a0,a0,-1582 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0201ab6:	f78fe0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0201aba <page_remove>:
ffffffffc0201aba:	7179                	addi	sp,sp,-48
ffffffffc0201abc:	4601                	li	a2,0
ffffffffc0201abe:	ec26                	sd	s1,24(sp)
ffffffffc0201ac0:	f406                	sd	ra,40(sp)
ffffffffc0201ac2:	f022                	sd	s0,32(sp)
ffffffffc0201ac4:	84ae                	mv	s1,a1
ffffffffc0201ac6:	9a1ff0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc0201aca:	c511                	beqz	a0,ffffffffc0201ad6 <page_remove+0x1c>
ffffffffc0201acc:	611c                	ld	a5,0(a0)
ffffffffc0201ace:	842a                	mv	s0,a0
ffffffffc0201ad0:	0017f713          	andi	a4,a5,1
ffffffffc0201ad4:	e711                	bnez	a4,ffffffffc0201ae0 <page_remove+0x26>
ffffffffc0201ad6:	70a2                	ld	ra,40(sp)
ffffffffc0201ad8:	7402                	ld	s0,32(sp)
ffffffffc0201ada:	64e2                	ld	s1,24(sp)
ffffffffc0201adc:	6145                	addi	sp,sp,48
ffffffffc0201ade:	8082                	ret
ffffffffc0201ae0:	078a                	slli	a5,a5,0x2
ffffffffc0201ae2:	83b1                	srli	a5,a5,0xc
ffffffffc0201ae4:	00095717          	auipc	a4,0x95
ffffffffc0201ae8:	df473703          	ld	a4,-524(a4) # ffffffffc02968d8 <npage>
ffffffffc0201aec:	06e7f363          	bgeu	a5,a4,ffffffffc0201b52 <page_remove+0x98>
ffffffffc0201af0:	fff80537          	lui	a0,0xfff80
ffffffffc0201af4:	97aa                	add	a5,a5,a0
ffffffffc0201af6:	079a                	slli	a5,a5,0x6
ffffffffc0201af8:	00095517          	auipc	a0,0x95
ffffffffc0201afc:	de853503          	ld	a0,-536(a0) # ffffffffc02968e0 <pages>
ffffffffc0201b00:	953e                	add	a0,a0,a5
ffffffffc0201b02:	411c                	lw	a5,0(a0)
ffffffffc0201b04:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b08:	c118                	sw	a4,0(a0)
ffffffffc0201b0a:	cb11                	beqz	a4,ffffffffc0201b1e <page_remove+0x64>
ffffffffc0201b0c:	00043023          	sd	zero,0(s0)
ffffffffc0201b10:	12048073          	sfence.vma	s1
ffffffffc0201b14:	70a2                	ld	ra,40(sp)
ffffffffc0201b16:	7402                	ld	s0,32(sp)
ffffffffc0201b18:	64e2                	ld	s1,24(sp)
ffffffffc0201b1a:	6145                	addi	sp,sp,48
ffffffffc0201b1c:	8082                	ret
ffffffffc0201b1e:	100027f3          	csrr	a5,sstatus
ffffffffc0201b22:	8b89                	andi	a5,a5,2
ffffffffc0201b24:	eb89                	bnez	a5,ffffffffc0201b36 <page_remove+0x7c>
ffffffffc0201b26:	00095797          	auipc	a5,0x95
ffffffffc0201b2a:	dc27b783          	ld	a5,-574(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc0201b2e:	739c                	ld	a5,32(a5)
ffffffffc0201b30:	4585                	li	a1,1
ffffffffc0201b32:	9782                	jalr	a5
ffffffffc0201b34:	bfe1                	j	ffffffffc0201b0c <page_remove+0x52>
ffffffffc0201b36:	e42a                	sd	a0,8(sp)
ffffffffc0201b38:	a68ff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201b3c:	00095797          	auipc	a5,0x95
ffffffffc0201b40:	dac7b783          	ld	a5,-596(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc0201b44:	739c                	ld	a5,32(a5)
ffffffffc0201b46:	6522                	ld	a0,8(sp)
ffffffffc0201b48:	4585                	li	a1,1
ffffffffc0201b4a:	9782                	jalr	a5
ffffffffc0201b4c:	a4eff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0201b50:	bf75                	j	ffffffffc0201b0c <page_remove+0x52>
ffffffffc0201b52:	825ff0ef          	jal	ra,ffffffffc0201376 <pa2page.part.0>

ffffffffc0201b56 <page_insert>:
ffffffffc0201b56:	7139                	addi	sp,sp,-64
ffffffffc0201b58:	e852                	sd	s4,16(sp)
ffffffffc0201b5a:	8a32                	mv	s4,a2
ffffffffc0201b5c:	f822                	sd	s0,48(sp)
ffffffffc0201b5e:	4605                	li	a2,1
ffffffffc0201b60:	842e                	mv	s0,a1
ffffffffc0201b62:	85d2                	mv	a1,s4
ffffffffc0201b64:	f426                	sd	s1,40(sp)
ffffffffc0201b66:	fc06                	sd	ra,56(sp)
ffffffffc0201b68:	f04a                	sd	s2,32(sp)
ffffffffc0201b6a:	ec4e                	sd	s3,24(sp)
ffffffffc0201b6c:	e456                	sd	s5,8(sp)
ffffffffc0201b6e:	84b6                	mv	s1,a3
ffffffffc0201b70:	8f7ff0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc0201b74:	c961                	beqz	a0,ffffffffc0201c44 <page_insert+0xee>
ffffffffc0201b76:	4014                	lw	a3,0(s0)
ffffffffc0201b78:	611c                	ld	a5,0(a0)
ffffffffc0201b7a:	89aa                	mv	s3,a0
ffffffffc0201b7c:	0016871b          	addiw	a4,a3,1
ffffffffc0201b80:	c018                	sw	a4,0(s0)
ffffffffc0201b82:	0017f713          	andi	a4,a5,1
ffffffffc0201b86:	ef05                	bnez	a4,ffffffffc0201bbe <page_insert+0x68>
ffffffffc0201b88:	00095717          	auipc	a4,0x95
ffffffffc0201b8c:	d5873703          	ld	a4,-680(a4) # ffffffffc02968e0 <pages>
ffffffffc0201b90:	8c19                	sub	s0,s0,a4
ffffffffc0201b92:	000807b7          	lui	a5,0x80
ffffffffc0201b96:	8419                	srai	s0,s0,0x6
ffffffffc0201b98:	943e                	add	s0,s0,a5
ffffffffc0201b9a:	042a                	slli	s0,s0,0xa
ffffffffc0201b9c:	8cc1                	or	s1,s1,s0
ffffffffc0201b9e:	0014e493          	ori	s1,s1,1
ffffffffc0201ba2:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_bin_sfs_img_size+0xffffffffbff8ad00>
ffffffffc0201ba6:	120a0073          	sfence.vma	s4
ffffffffc0201baa:	4501                	li	a0,0
ffffffffc0201bac:	70e2                	ld	ra,56(sp)
ffffffffc0201bae:	7442                	ld	s0,48(sp)
ffffffffc0201bb0:	74a2                	ld	s1,40(sp)
ffffffffc0201bb2:	7902                	ld	s2,32(sp)
ffffffffc0201bb4:	69e2                	ld	s3,24(sp)
ffffffffc0201bb6:	6a42                	ld	s4,16(sp)
ffffffffc0201bb8:	6aa2                	ld	s5,8(sp)
ffffffffc0201bba:	6121                	addi	sp,sp,64
ffffffffc0201bbc:	8082                	ret
ffffffffc0201bbe:	078a                	slli	a5,a5,0x2
ffffffffc0201bc0:	83b1                	srli	a5,a5,0xc
ffffffffc0201bc2:	00095717          	auipc	a4,0x95
ffffffffc0201bc6:	d1673703          	ld	a4,-746(a4) # ffffffffc02968d8 <npage>
ffffffffc0201bca:	06e7ff63          	bgeu	a5,a4,ffffffffc0201c48 <page_insert+0xf2>
ffffffffc0201bce:	00095a97          	auipc	s5,0x95
ffffffffc0201bd2:	d12a8a93          	addi	s5,s5,-750 # ffffffffc02968e0 <pages>
ffffffffc0201bd6:	000ab703          	ld	a4,0(s5)
ffffffffc0201bda:	fff80937          	lui	s2,0xfff80
ffffffffc0201bde:	993e                	add	s2,s2,a5
ffffffffc0201be0:	091a                	slli	s2,s2,0x6
ffffffffc0201be2:	993a                	add	s2,s2,a4
ffffffffc0201be4:	01240c63          	beq	s0,s2,ffffffffc0201bfc <page_insert+0xa6>
ffffffffc0201be8:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fce96a8>
ffffffffc0201bec:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201bf0:	00d92023          	sw	a3,0(s2)
ffffffffc0201bf4:	c691                	beqz	a3,ffffffffc0201c00 <page_insert+0xaa>
ffffffffc0201bf6:	120a0073          	sfence.vma	s4
ffffffffc0201bfa:	bf59                	j	ffffffffc0201b90 <page_insert+0x3a>
ffffffffc0201bfc:	c014                	sw	a3,0(s0)
ffffffffc0201bfe:	bf49                	j	ffffffffc0201b90 <page_insert+0x3a>
ffffffffc0201c00:	100027f3          	csrr	a5,sstatus
ffffffffc0201c04:	8b89                	andi	a5,a5,2
ffffffffc0201c06:	ef91                	bnez	a5,ffffffffc0201c22 <page_insert+0xcc>
ffffffffc0201c08:	00095797          	auipc	a5,0x95
ffffffffc0201c0c:	ce07b783          	ld	a5,-800(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc0201c10:	739c                	ld	a5,32(a5)
ffffffffc0201c12:	4585                	li	a1,1
ffffffffc0201c14:	854a                	mv	a0,s2
ffffffffc0201c16:	9782                	jalr	a5
ffffffffc0201c18:	000ab703          	ld	a4,0(s5)
ffffffffc0201c1c:	120a0073          	sfence.vma	s4
ffffffffc0201c20:	bf85                	j	ffffffffc0201b90 <page_insert+0x3a>
ffffffffc0201c22:	97eff0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0201c26:	00095797          	auipc	a5,0x95
ffffffffc0201c2a:	cc27b783          	ld	a5,-830(a5) # ffffffffc02968e8 <pmm_manager>
ffffffffc0201c2e:	739c                	ld	a5,32(a5)
ffffffffc0201c30:	4585                	li	a1,1
ffffffffc0201c32:	854a                	mv	a0,s2
ffffffffc0201c34:	9782                	jalr	a5
ffffffffc0201c36:	964ff0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0201c3a:	000ab703          	ld	a4,0(s5)
ffffffffc0201c3e:	120a0073          	sfence.vma	s4
ffffffffc0201c42:	b7b9                	j	ffffffffc0201b90 <page_insert+0x3a>
ffffffffc0201c44:	5571                	li	a0,-4
ffffffffc0201c46:	b79d                	j	ffffffffc0201bac <page_insert+0x56>
ffffffffc0201c48:	f2eff0ef          	jal	ra,ffffffffc0201376 <pa2page.part.0>

ffffffffc0201c4c <pmm_init>:
ffffffffc0201c4c:	0000b797          	auipc	a5,0xb
ffffffffc0201c50:	6d478793          	addi	a5,a5,1748 # ffffffffc020d320 <default_pmm_manager>
ffffffffc0201c54:	638c                	ld	a1,0(a5)
ffffffffc0201c56:	7159                	addi	sp,sp,-112
ffffffffc0201c58:	f85a                	sd	s6,48(sp)
ffffffffc0201c5a:	0000b517          	auipc	a0,0xb
ffffffffc0201c5e:	87e50513          	addi	a0,a0,-1922 # ffffffffc020c4d8 <commands+0xa08>
ffffffffc0201c62:	00095b17          	auipc	s6,0x95
ffffffffc0201c66:	c86b0b13          	addi	s6,s6,-890 # ffffffffc02968e8 <pmm_manager>
ffffffffc0201c6a:	f486                	sd	ra,104(sp)
ffffffffc0201c6c:	e8ca                	sd	s2,80(sp)
ffffffffc0201c6e:	e4ce                	sd	s3,72(sp)
ffffffffc0201c70:	f0a2                	sd	s0,96(sp)
ffffffffc0201c72:	eca6                	sd	s1,88(sp)
ffffffffc0201c74:	e0d2                	sd	s4,64(sp)
ffffffffc0201c76:	fc56                	sd	s5,56(sp)
ffffffffc0201c78:	f45e                	sd	s7,40(sp)
ffffffffc0201c7a:	f062                	sd	s8,32(sp)
ffffffffc0201c7c:	ec66                	sd	s9,24(sp)
ffffffffc0201c7e:	00fb3023          	sd	a5,0(s6)
ffffffffc0201c82:	ca8fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201c86:	000b3783          	ld	a5,0(s6)
ffffffffc0201c8a:	00095997          	auipc	s3,0x95
ffffffffc0201c8e:	c6698993          	addi	s3,s3,-922 # ffffffffc02968f0 <va_pa_offset>
ffffffffc0201c92:	679c                	ld	a5,8(a5)
ffffffffc0201c94:	9782                	jalr	a5
ffffffffc0201c96:	57f5                	li	a5,-3
ffffffffc0201c98:	07fa                	slli	a5,a5,0x1e
ffffffffc0201c9a:	00f9b023          	sd	a5,0(s3)
ffffffffc0201c9e:	c4bfe0ef          	jal	ra,ffffffffc02008e8 <get_memory_base>
ffffffffc0201ca2:	892a                	mv	s2,a0
ffffffffc0201ca4:	c4ffe0ef          	jal	ra,ffffffffc02008f2 <get_memory_size>
ffffffffc0201ca8:	200505e3          	beqz	a0,ffffffffc02026b2 <pmm_init+0xa66>
ffffffffc0201cac:	84aa                	mv	s1,a0
ffffffffc0201cae:	0000b517          	auipc	a0,0xb
ffffffffc0201cb2:	86250513          	addi	a0,a0,-1950 # ffffffffc020c510 <commands+0xa40>
ffffffffc0201cb6:	c74fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201cba:	00990433          	add	s0,s2,s1
ffffffffc0201cbe:	fff40693          	addi	a3,s0,-1
ffffffffc0201cc2:	864a                	mv	a2,s2
ffffffffc0201cc4:	85a6                	mv	a1,s1
ffffffffc0201cc6:	0000b517          	auipc	a0,0xb
ffffffffc0201cca:	86250513          	addi	a0,a0,-1950 # ffffffffc020c528 <commands+0xa58>
ffffffffc0201cce:	c5cfe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201cd2:	c8000737          	lui	a4,0xc8000
ffffffffc0201cd6:	87a2                	mv	a5,s0
ffffffffc0201cd8:	54876163          	bltu	a4,s0,ffffffffc020221a <pmm_init+0x5ce>
ffffffffc0201cdc:	757d                	lui	a0,0xfffff
ffffffffc0201cde:	00096617          	auipc	a2,0x96
ffffffffc0201ce2:	c7960613          	addi	a2,a2,-903 # ffffffffc0297957 <end+0xfff>
ffffffffc0201ce6:	8e69                	and	a2,a2,a0
ffffffffc0201ce8:	00095497          	auipc	s1,0x95
ffffffffc0201cec:	bf048493          	addi	s1,s1,-1040 # ffffffffc02968d8 <npage>
ffffffffc0201cf0:	00c7d513          	srli	a0,a5,0xc
ffffffffc0201cf4:	00095b97          	auipc	s7,0x95
ffffffffc0201cf8:	becb8b93          	addi	s7,s7,-1044 # ffffffffc02968e0 <pages>
ffffffffc0201cfc:	e088                	sd	a0,0(s1)
ffffffffc0201cfe:	00cbb023          	sd	a2,0(s7)
ffffffffc0201d02:	000807b7          	lui	a5,0x80
ffffffffc0201d06:	86b2                	mv	a3,a2
ffffffffc0201d08:	02f50863          	beq	a0,a5,ffffffffc0201d38 <pmm_init+0xec>
ffffffffc0201d0c:	4781                	li	a5,0
ffffffffc0201d0e:	4585                	li	a1,1
ffffffffc0201d10:	fff806b7          	lui	a3,0xfff80
ffffffffc0201d14:	00679513          	slli	a0,a5,0x6
ffffffffc0201d18:	9532                	add	a0,a0,a2
ffffffffc0201d1a:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd686b0>
ffffffffc0201d1e:	40b7302f          	amoor.d	zero,a1,(a4)
ffffffffc0201d22:	6088                	ld	a0,0(s1)
ffffffffc0201d24:	0785                	addi	a5,a5,1
ffffffffc0201d26:	000bb603          	ld	a2,0(s7)
ffffffffc0201d2a:	00d50733          	add	a4,a0,a3
ffffffffc0201d2e:	fee7e3e3          	bltu	a5,a4,ffffffffc0201d14 <pmm_init+0xc8>
ffffffffc0201d32:	071a                	slli	a4,a4,0x6
ffffffffc0201d34:	00e606b3          	add	a3,a2,a4
ffffffffc0201d38:	c02007b7          	lui	a5,0xc0200
ffffffffc0201d3c:	2ef6ece3          	bltu	a3,a5,ffffffffc0202834 <pmm_init+0xbe8>
ffffffffc0201d40:	0009b583          	ld	a1,0(s3)
ffffffffc0201d44:	77fd                	lui	a5,0xfffff
ffffffffc0201d46:	8c7d                	and	s0,s0,a5
ffffffffc0201d48:	8e8d                	sub	a3,a3,a1
ffffffffc0201d4a:	5086eb63          	bltu	a3,s0,ffffffffc0202260 <pmm_init+0x614>
ffffffffc0201d4e:	0000b517          	auipc	a0,0xb
ffffffffc0201d52:	82a50513          	addi	a0,a0,-2006 # ffffffffc020c578 <commands+0xaa8>
ffffffffc0201d56:	bd4fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201d5a:	000b3783          	ld	a5,0(s6)
ffffffffc0201d5e:	00095917          	auipc	s2,0x95
ffffffffc0201d62:	b7290913          	addi	s2,s2,-1166 # ffffffffc02968d0 <boot_pgdir_va>
ffffffffc0201d66:	7b9c                	ld	a5,48(a5)
ffffffffc0201d68:	9782                	jalr	a5
ffffffffc0201d6a:	0000b517          	auipc	a0,0xb
ffffffffc0201d6e:	82650513          	addi	a0,a0,-2010 # ffffffffc020c590 <commands+0xac0>
ffffffffc0201d72:	bb8fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0201d76:	00011697          	auipc	a3,0x11
ffffffffc0201d7a:	28a68693          	addi	a3,a3,650 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc0201d7e:	00d93023          	sd	a3,0(s2)
ffffffffc0201d82:	c02007b7          	lui	a5,0xc0200
ffffffffc0201d86:	28f6ebe3          	bltu	a3,a5,ffffffffc020281c <pmm_init+0xbd0>
ffffffffc0201d8a:	0009b783          	ld	a5,0(s3)
ffffffffc0201d8e:	8e9d                	sub	a3,a3,a5
ffffffffc0201d90:	00095797          	auipc	a5,0x95
ffffffffc0201d94:	b2d7bc23          	sd	a3,-1224(a5) # ffffffffc02968c8 <boot_pgdir_pa>
ffffffffc0201d98:	100027f3          	csrr	a5,sstatus
ffffffffc0201d9c:	8b89                	andi	a5,a5,2
ffffffffc0201d9e:	4a079763          	bnez	a5,ffffffffc020224c <pmm_init+0x600>
ffffffffc0201da2:	000b3783          	ld	a5,0(s6)
ffffffffc0201da6:	779c                	ld	a5,40(a5)
ffffffffc0201da8:	9782                	jalr	a5
ffffffffc0201daa:	842a                	mv	s0,a0
ffffffffc0201dac:	6098                	ld	a4,0(s1)
ffffffffc0201dae:	c80007b7          	lui	a5,0xc8000
ffffffffc0201db2:	83b1                	srli	a5,a5,0xc
ffffffffc0201db4:	66e7e363          	bltu	a5,a4,ffffffffc020241a <pmm_init+0x7ce>
ffffffffc0201db8:	00093503          	ld	a0,0(s2)
ffffffffc0201dbc:	62050f63          	beqz	a0,ffffffffc02023fa <pmm_init+0x7ae>
ffffffffc0201dc0:	03451793          	slli	a5,a0,0x34
ffffffffc0201dc4:	62079b63          	bnez	a5,ffffffffc02023fa <pmm_init+0x7ae>
ffffffffc0201dc8:	4601                	li	a2,0
ffffffffc0201dca:	4581                	li	a1,0
ffffffffc0201dcc:	8c3ff0ef          	jal	ra,ffffffffc020168e <get_page>
ffffffffc0201dd0:	60051563          	bnez	a0,ffffffffc02023da <pmm_init+0x78e>
ffffffffc0201dd4:	100027f3          	csrr	a5,sstatus
ffffffffc0201dd8:	8b89                	andi	a5,a5,2
ffffffffc0201dda:	44079e63          	bnez	a5,ffffffffc0202236 <pmm_init+0x5ea>
ffffffffc0201dde:	000b3783          	ld	a5,0(s6)
ffffffffc0201de2:	4505                	li	a0,1
ffffffffc0201de4:	6f9c                	ld	a5,24(a5)
ffffffffc0201de6:	9782                	jalr	a5
ffffffffc0201de8:	8a2a                	mv	s4,a0
ffffffffc0201dea:	00093503          	ld	a0,0(s2)
ffffffffc0201dee:	4681                	li	a3,0
ffffffffc0201df0:	4601                	li	a2,0
ffffffffc0201df2:	85d2                	mv	a1,s4
ffffffffc0201df4:	d63ff0ef          	jal	ra,ffffffffc0201b56 <page_insert>
ffffffffc0201df8:	26051ae3          	bnez	a0,ffffffffc020286c <pmm_init+0xc20>
ffffffffc0201dfc:	00093503          	ld	a0,0(s2)
ffffffffc0201e00:	4601                	li	a2,0
ffffffffc0201e02:	4581                	li	a1,0
ffffffffc0201e04:	e62ff0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc0201e08:	240502e3          	beqz	a0,ffffffffc020284c <pmm_init+0xc00>
ffffffffc0201e0c:	611c                	ld	a5,0(a0)
ffffffffc0201e0e:	0017f713          	andi	a4,a5,1
ffffffffc0201e12:	5a070263          	beqz	a4,ffffffffc02023b6 <pmm_init+0x76a>
ffffffffc0201e16:	6098                	ld	a4,0(s1)
ffffffffc0201e18:	078a                	slli	a5,a5,0x2
ffffffffc0201e1a:	83b1                	srli	a5,a5,0xc
ffffffffc0201e1c:	58e7fb63          	bgeu	a5,a4,ffffffffc02023b2 <pmm_init+0x766>
ffffffffc0201e20:	000bb683          	ld	a3,0(s7)
ffffffffc0201e24:	fff80637          	lui	a2,0xfff80
ffffffffc0201e28:	97b2                	add	a5,a5,a2
ffffffffc0201e2a:	079a                	slli	a5,a5,0x6
ffffffffc0201e2c:	97b6                	add	a5,a5,a3
ffffffffc0201e2e:	14fa17e3          	bne	s4,a5,ffffffffc020277c <pmm_init+0xb30>
ffffffffc0201e32:	000a2683          	lw	a3,0(s4) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0201e36:	4785                	li	a5,1
ffffffffc0201e38:	12f692e3          	bne	a3,a5,ffffffffc020275c <pmm_init+0xb10>
ffffffffc0201e3c:	00093503          	ld	a0,0(s2)
ffffffffc0201e40:	77fd                	lui	a5,0xfffff
ffffffffc0201e42:	6114                	ld	a3,0(a0)
ffffffffc0201e44:	068a                	slli	a3,a3,0x2
ffffffffc0201e46:	8efd                	and	a3,a3,a5
ffffffffc0201e48:	00c6d613          	srli	a2,a3,0xc
ffffffffc0201e4c:	0ee67ce3          	bgeu	a2,a4,ffffffffc0202744 <pmm_init+0xaf8>
ffffffffc0201e50:	0009bc03          	ld	s8,0(s3)
ffffffffc0201e54:	96e2                	add	a3,a3,s8
ffffffffc0201e56:	0006ba83          	ld	s5,0(a3)
ffffffffc0201e5a:	0a8a                	slli	s5,s5,0x2
ffffffffc0201e5c:	00fafab3          	and	s5,s5,a5
ffffffffc0201e60:	00cad793          	srli	a5,s5,0xc
ffffffffc0201e64:	0ce7f3e3          	bgeu	a5,a4,ffffffffc020272a <pmm_init+0xade>
ffffffffc0201e68:	4601                	li	a2,0
ffffffffc0201e6a:	6585                	lui	a1,0x1
ffffffffc0201e6c:	9ae2                	add	s5,s5,s8
ffffffffc0201e6e:	df8ff0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc0201e72:	0aa1                	addi	s5,s5,8
ffffffffc0201e74:	55551363          	bne	a0,s5,ffffffffc02023ba <pmm_init+0x76e>
ffffffffc0201e78:	100027f3          	csrr	a5,sstatus
ffffffffc0201e7c:	8b89                	andi	a5,a5,2
ffffffffc0201e7e:	3a079163          	bnez	a5,ffffffffc0202220 <pmm_init+0x5d4>
ffffffffc0201e82:	000b3783          	ld	a5,0(s6)
ffffffffc0201e86:	4505                	li	a0,1
ffffffffc0201e88:	6f9c                	ld	a5,24(a5)
ffffffffc0201e8a:	9782                	jalr	a5
ffffffffc0201e8c:	8c2a                	mv	s8,a0
ffffffffc0201e8e:	00093503          	ld	a0,0(s2)
ffffffffc0201e92:	46d1                	li	a3,20
ffffffffc0201e94:	6605                	lui	a2,0x1
ffffffffc0201e96:	85e2                	mv	a1,s8
ffffffffc0201e98:	cbfff0ef          	jal	ra,ffffffffc0201b56 <page_insert>
ffffffffc0201e9c:	060517e3          	bnez	a0,ffffffffc020270a <pmm_init+0xabe>
ffffffffc0201ea0:	00093503          	ld	a0,0(s2)
ffffffffc0201ea4:	4601                	li	a2,0
ffffffffc0201ea6:	6585                	lui	a1,0x1
ffffffffc0201ea8:	dbeff0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc0201eac:	02050fe3          	beqz	a0,ffffffffc02026ea <pmm_init+0xa9e>
ffffffffc0201eb0:	611c                	ld	a5,0(a0)
ffffffffc0201eb2:	0107f713          	andi	a4,a5,16
ffffffffc0201eb6:	7c070e63          	beqz	a4,ffffffffc0202692 <pmm_init+0xa46>
ffffffffc0201eba:	8b91                	andi	a5,a5,4
ffffffffc0201ebc:	7a078b63          	beqz	a5,ffffffffc0202672 <pmm_init+0xa26>
ffffffffc0201ec0:	00093503          	ld	a0,0(s2)
ffffffffc0201ec4:	611c                	ld	a5,0(a0)
ffffffffc0201ec6:	8bc1                	andi	a5,a5,16
ffffffffc0201ec8:	78078563          	beqz	a5,ffffffffc0202652 <pmm_init+0xa06>
ffffffffc0201ecc:	000c2703          	lw	a4,0(s8)
ffffffffc0201ed0:	4785                	li	a5,1
ffffffffc0201ed2:	76f71063          	bne	a4,a5,ffffffffc0202632 <pmm_init+0x9e6>
ffffffffc0201ed6:	4681                	li	a3,0
ffffffffc0201ed8:	6605                	lui	a2,0x1
ffffffffc0201eda:	85d2                	mv	a1,s4
ffffffffc0201edc:	c7bff0ef          	jal	ra,ffffffffc0201b56 <page_insert>
ffffffffc0201ee0:	72051963          	bnez	a0,ffffffffc0202612 <pmm_init+0x9c6>
ffffffffc0201ee4:	000a2703          	lw	a4,0(s4)
ffffffffc0201ee8:	4789                	li	a5,2
ffffffffc0201eea:	70f71463          	bne	a4,a5,ffffffffc02025f2 <pmm_init+0x9a6>
ffffffffc0201eee:	000c2783          	lw	a5,0(s8)
ffffffffc0201ef2:	6e079063          	bnez	a5,ffffffffc02025d2 <pmm_init+0x986>
ffffffffc0201ef6:	00093503          	ld	a0,0(s2)
ffffffffc0201efa:	4601                	li	a2,0
ffffffffc0201efc:	6585                	lui	a1,0x1
ffffffffc0201efe:	d68ff0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc0201f02:	6a050863          	beqz	a0,ffffffffc02025b2 <pmm_init+0x966>
ffffffffc0201f06:	6118                	ld	a4,0(a0)
ffffffffc0201f08:	00177793          	andi	a5,a4,1
ffffffffc0201f0c:	4a078563          	beqz	a5,ffffffffc02023b6 <pmm_init+0x76a>
ffffffffc0201f10:	6094                	ld	a3,0(s1)
ffffffffc0201f12:	00271793          	slli	a5,a4,0x2
ffffffffc0201f16:	83b1                	srli	a5,a5,0xc
ffffffffc0201f18:	48d7fd63          	bgeu	a5,a3,ffffffffc02023b2 <pmm_init+0x766>
ffffffffc0201f1c:	000bb683          	ld	a3,0(s7)
ffffffffc0201f20:	fff80ab7          	lui	s5,0xfff80
ffffffffc0201f24:	97d6                	add	a5,a5,s5
ffffffffc0201f26:	079a                	slli	a5,a5,0x6
ffffffffc0201f28:	97b6                	add	a5,a5,a3
ffffffffc0201f2a:	66fa1463          	bne	s4,a5,ffffffffc0202592 <pmm_init+0x946>
ffffffffc0201f2e:	8b41                	andi	a4,a4,16
ffffffffc0201f30:	64071163          	bnez	a4,ffffffffc0202572 <pmm_init+0x926>
ffffffffc0201f34:	00093503          	ld	a0,0(s2)
ffffffffc0201f38:	4581                	li	a1,0
ffffffffc0201f3a:	b81ff0ef          	jal	ra,ffffffffc0201aba <page_remove>
ffffffffc0201f3e:	000a2c83          	lw	s9,0(s4)
ffffffffc0201f42:	4785                	li	a5,1
ffffffffc0201f44:	60fc9763          	bne	s9,a5,ffffffffc0202552 <pmm_init+0x906>
ffffffffc0201f48:	000c2783          	lw	a5,0(s8)
ffffffffc0201f4c:	5e079363          	bnez	a5,ffffffffc0202532 <pmm_init+0x8e6>
ffffffffc0201f50:	00093503          	ld	a0,0(s2)
ffffffffc0201f54:	6585                	lui	a1,0x1
ffffffffc0201f56:	b65ff0ef          	jal	ra,ffffffffc0201aba <page_remove>
ffffffffc0201f5a:	000a2783          	lw	a5,0(s4)
ffffffffc0201f5e:	52079a63          	bnez	a5,ffffffffc0202492 <pmm_init+0x846>
ffffffffc0201f62:	000c2783          	lw	a5,0(s8)
ffffffffc0201f66:	50079663          	bnez	a5,ffffffffc0202472 <pmm_init+0x826>
ffffffffc0201f6a:	00093a03          	ld	s4,0(s2)
ffffffffc0201f6e:	608c                	ld	a1,0(s1)
ffffffffc0201f70:	000a3683          	ld	a3,0(s4)
ffffffffc0201f74:	068a                	slli	a3,a3,0x2
ffffffffc0201f76:	82b1                	srli	a3,a3,0xc
ffffffffc0201f78:	42b6fd63          	bgeu	a3,a1,ffffffffc02023b2 <pmm_init+0x766>
ffffffffc0201f7c:	000bb503          	ld	a0,0(s7)
ffffffffc0201f80:	96d6                	add	a3,a3,s5
ffffffffc0201f82:	069a                	slli	a3,a3,0x6
ffffffffc0201f84:	00d507b3          	add	a5,a0,a3
ffffffffc0201f88:	439c                	lw	a5,0(a5)
ffffffffc0201f8a:	4d979463          	bne	a5,s9,ffffffffc0202452 <pmm_init+0x806>
ffffffffc0201f8e:	8699                	srai	a3,a3,0x6
ffffffffc0201f90:	00080637          	lui	a2,0x80
ffffffffc0201f94:	96b2                	add	a3,a3,a2
ffffffffc0201f96:	00c69713          	slli	a4,a3,0xc
ffffffffc0201f9a:	8331                	srli	a4,a4,0xc
ffffffffc0201f9c:	06b2                	slli	a3,a3,0xc
ffffffffc0201f9e:	48b77e63          	bgeu	a4,a1,ffffffffc020243a <pmm_init+0x7ee>
ffffffffc0201fa2:	0009b703          	ld	a4,0(s3)
ffffffffc0201fa6:	96ba                	add	a3,a3,a4
ffffffffc0201fa8:	629c                	ld	a5,0(a3)
ffffffffc0201faa:	078a                	slli	a5,a5,0x2
ffffffffc0201fac:	83b1                	srli	a5,a5,0xc
ffffffffc0201fae:	40b7f263          	bgeu	a5,a1,ffffffffc02023b2 <pmm_init+0x766>
ffffffffc0201fb2:	8f91                	sub	a5,a5,a2
ffffffffc0201fb4:	079a                	slli	a5,a5,0x6
ffffffffc0201fb6:	953e                	add	a0,a0,a5
ffffffffc0201fb8:	100027f3          	csrr	a5,sstatus
ffffffffc0201fbc:	8b89                	andi	a5,a5,2
ffffffffc0201fbe:	30079963          	bnez	a5,ffffffffc02022d0 <pmm_init+0x684>
ffffffffc0201fc2:	000b3783          	ld	a5,0(s6)
ffffffffc0201fc6:	4585                	li	a1,1
ffffffffc0201fc8:	739c                	ld	a5,32(a5)
ffffffffc0201fca:	9782                	jalr	a5
ffffffffc0201fcc:	000a3783          	ld	a5,0(s4)
ffffffffc0201fd0:	6098                	ld	a4,0(s1)
ffffffffc0201fd2:	078a                	slli	a5,a5,0x2
ffffffffc0201fd4:	83b1                	srli	a5,a5,0xc
ffffffffc0201fd6:	3ce7fe63          	bgeu	a5,a4,ffffffffc02023b2 <pmm_init+0x766>
ffffffffc0201fda:	000bb503          	ld	a0,0(s7)
ffffffffc0201fde:	fff80737          	lui	a4,0xfff80
ffffffffc0201fe2:	97ba                	add	a5,a5,a4
ffffffffc0201fe4:	079a                	slli	a5,a5,0x6
ffffffffc0201fe6:	953e                	add	a0,a0,a5
ffffffffc0201fe8:	100027f3          	csrr	a5,sstatus
ffffffffc0201fec:	8b89                	andi	a5,a5,2
ffffffffc0201fee:	2c079563          	bnez	a5,ffffffffc02022b8 <pmm_init+0x66c>
ffffffffc0201ff2:	000b3783          	ld	a5,0(s6)
ffffffffc0201ff6:	4585                	li	a1,1
ffffffffc0201ff8:	739c                	ld	a5,32(a5)
ffffffffc0201ffa:	9782                	jalr	a5
ffffffffc0201ffc:	00093783          	ld	a5,0(s2)
ffffffffc0202000:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd686a8>
ffffffffc0202004:	12000073          	sfence.vma
ffffffffc0202008:	100027f3          	csrr	a5,sstatus
ffffffffc020200c:	8b89                	andi	a5,a5,2
ffffffffc020200e:	28079b63          	bnez	a5,ffffffffc02022a4 <pmm_init+0x658>
ffffffffc0202012:	000b3783          	ld	a5,0(s6)
ffffffffc0202016:	779c                	ld	a5,40(a5)
ffffffffc0202018:	9782                	jalr	a5
ffffffffc020201a:	8a2a                	mv	s4,a0
ffffffffc020201c:	4b441b63          	bne	s0,s4,ffffffffc02024d2 <pmm_init+0x886>
ffffffffc0202020:	0000b517          	auipc	a0,0xb
ffffffffc0202024:	89850513          	addi	a0,a0,-1896 # ffffffffc020c8b8 <commands+0xde8>
ffffffffc0202028:	902fe0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020202c:	100027f3          	csrr	a5,sstatus
ffffffffc0202030:	8b89                	andi	a5,a5,2
ffffffffc0202032:	24079f63          	bnez	a5,ffffffffc0202290 <pmm_init+0x644>
ffffffffc0202036:	000b3783          	ld	a5,0(s6)
ffffffffc020203a:	779c                	ld	a5,40(a5)
ffffffffc020203c:	9782                	jalr	a5
ffffffffc020203e:	8c2a                	mv	s8,a0
ffffffffc0202040:	6098                	ld	a4,0(s1)
ffffffffc0202042:	c0200437          	lui	s0,0xc0200
ffffffffc0202046:	7afd                	lui	s5,0xfffff
ffffffffc0202048:	00c71793          	slli	a5,a4,0xc
ffffffffc020204c:	6a05                	lui	s4,0x1
ffffffffc020204e:	02f47c63          	bgeu	s0,a5,ffffffffc0202086 <pmm_init+0x43a>
ffffffffc0202052:	00c45793          	srli	a5,s0,0xc
ffffffffc0202056:	00093503          	ld	a0,0(s2)
ffffffffc020205a:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202358 <pmm_init+0x70c>
ffffffffc020205e:	0009b583          	ld	a1,0(s3)
ffffffffc0202062:	4601                	li	a2,0
ffffffffc0202064:	95a2                	add	a1,a1,s0
ffffffffc0202066:	c00ff0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc020206a:	32050463          	beqz	a0,ffffffffc0202392 <pmm_init+0x746>
ffffffffc020206e:	611c                	ld	a5,0(a0)
ffffffffc0202070:	078a                	slli	a5,a5,0x2
ffffffffc0202072:	0157f7b3          	and	a5,a5,s5
ffffffffc0202076:	2e879e63          	bne	a5,s0,ffffffffc0202372 <pmm_init+0x726>
ffffffffc020207a:	6098                	ld	a4,0(s1)
ffffffffc020207c:	9452                	add	s0,s0,s4
ffffffffc020207e:	00c71793          	slli	a5,a4,0xc
ffffffffc0202082:	fcf468e3          	bltu	s0,a5,ffffffffc0202052 <pmm_init+0x406>
ffffffffc0202086:	00093783          	ld	a5,0(s2)
ffffffffc020208a:	639c                	ld	a5,0(a5)
ffffffffc020208c:	42079363          	bnez	a5,ffffffffc02024b2 <pmm_init+0x866>
ffffffffc0202090:	100027f3          	csrr	a5,sstatus
ffffffffc0202094:	8b89                	andi	a5,a5,2
ffffffffc0202096:	24079963          	bnez	a5,ffffffffc02022e8 <pmm_init+0x69c>
ffffffffc020209a:	000b3783          	ld	a5,0(s6)
ffffffffc020209e:	4505                	li	a0,1
ffffffffc02020a0:	6f9c                	ld	a5,24(a5)
ffffffffc02020a2:	9782                	jalr	a5
ffffffffc02020a4:	8a2a                	mv	s4,a0
ffffffffc02020a6:	00093503          	ld	a0,0(s2)
ffffffffc02020aa:	4699                	li	a3,6
ffffffffc02020ac:	10000613          	li	a2,256
ffffffffc02020b0:	85d2                	mv	a1,s4
ffffffffc02020b2:	aa5ff0ef          	jal	ra,ffffffffc0201b56 <page_insert>
ffffffffc02020b6:	44051e63          	bnez	a0,ffffffffc0202512 <pmm_init+0x8c6>
ffffffffc02020ba:	000a2703          	lw	a4,0(s4) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc02020be:	4785                	li	a5,1
ffffffffc02020c0:	42f71963          	bne	a4,a5,ffffffffc02024f2 <pmm_init+0x8a6>
ffffffffc02020c4:	00093503          	ld	a0,0(s2)
ffffffffc02020c8:	6405                	lui	s0,0x1
ffffffffc02020ca:	4699                	li	a3,6
ffffffffc02020cc:	10040613          	addi	a2,s0,256 # 1100 <_binary_bin_swap_img_size-0x6c00>
ffffffffc02020d0:	85d2                	mv	a1,s4
ffffffffc02020d2:	a85ff0ef          	jal	ra,ffffffffc0201b56 <page_insert>
ffffffffc02020d6:	72051363          	bnez	a0,ffffffffc02027fc <pmm_init+0xbb0>
ffffffffc02020da:	000a2703          	lw	a4,0(s4)
ffffffffc02020de:	4789                	li	a5,2
ffffffffc02020e0:	6ef71e63          	bne	a4,a5,ffffffffc02027dc <pmm_init+0xb90>
ffffffffc02020e4:	0000b597          	auipc	a1,0xb
ffffffffc02020e8:	91c58593          	addi	a1,a1,-1764 # ffffffffc020ca00 <commands+0xf30>
ffffffffc02020ec:	10000513          	li	a0,256
ffffffffc02020f0:	1d0090ef          	jal	ra,ffffffffc020b2c0 <strcpy>
ffffffffc02020f4:	10040593          	addi	a1,s0,256
ffffffffc02020f8:	10000513          	li	a0,256
ffffffffc02020fc:	1d6090ef          	jal	ra,ffffffffc020b2d2 <strcmp>
ffffffffc0202100:	6a051e63          	bnez	a0,ffffffffc02027bc <pmm_init+0xb70>
ffffffffc0202104:	000bb683          	ld	a3,0(s7)
ffffffffc0202108:	00080737          	lui	a4,0x80
ffffffffc020210c:	547d                	li	s0,-1
ffffffffc020210e:	40da06b3          	sub	a3,s4,a3
ffffffffc0202112:	8699                	srai	a3,a3,0x6
ffffffffc0202114:	609c                	ld	a5,0(s1)
ffffffffc0202116:	96ba                	add	a3,a3,a4
ffffffffc0202118:	8031                	srli	s0,s0,0xc
ffffffffc020211a:	0086f733          	and	a4,a3,s0
ffffffffc020211e:	06b2                	slli	a3,a3,0xc
ffffffffc0202120:	30f77d63          	bgeu	a4,a5,ffffffffc020243a <pmm_init+0x7ee>
ffffffffc0202124:	0009b783          	ld	a5,0(s3)
ffffffffc0202128:	10000513          	li	a0,256
ffffffffc020212c:	96be                	add	a3,a3,a5
ffffffffc020212e:	10068023          	sb	zero,256(a3)
ffffffffc0202132:	158090ef          	jal	ra,ffffffffc020b28a <strlen>
ffffffffc0202136:	66051363          	bnez	a0,ffffffffc020279c <pmm_init+0xb50>
ffffffffc020213a:	00093a83          	ld	s5,0(s2)
ffffffffc020213e:	609c                	ld	a5,0(s1)
ffffffffc0202140:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd686a8>
ffffffffc0202144:	068a                	slli	a3,a3,0x2
ffffffffc0202146:	82b1                	srli	a3,a3,0xc
ffffffffc0202148:	26f6f563          	bgeu	a3,a5,ffffffffc02023b2 <pmm_init+0x766>
ffffffffc020214c:	8c75                	and	s0,s0,a3
ffffffffc020214e:	06b2                	slli	a3,a3,0xc
ffffffffc0202150:	2ef47563          	bgeu	s0,a5,ffffffffc020243a <pmm_init+0x7ee>
ffffffffc0202154:	0009b403          	ld	s0,0(s3)
ffffffffc0202158:	9436                	add	s0,s0,a3
ffffffffc020215a:	100027f3          	csrr	a5,sstatus
ffffffffc020215e:	8b89                	andi	a5,a5,2
ffffffffc0202160:	1e079163          	bnez	a5,ffffffffc0202342 <pmm_init+0x6f6>
ffffffffc0202164:	000b3783          	ld	a5,0(s6)
ffffffffc0202168:	4585                	li	a1,1
ffffffffc020216a:	8552                	mv	a0,s4
ffffffffc020216c:	739c                	ld	a5,32(a5)
ffffffffc020216e:	9782                	jalr	a5
ffffffffc0202170:	601c                	ld	a5,0(s0)
ffffffffc0202172:	6098                	ld	a4,0(s1)
ffffffffc0202174:	078a                	slli	a5,a5,0x2
ffffffffc0202176:	83b1                	srli	a5,a5,0xc
ffffffffc0202178:	22e7fd63          	bgeu	a5,a4,ffffffffc02023b2 <pmm_init+0x766>
ffffffffc020217c:	000bb503          	ld	a0,0(s7)
ffffffffc0202180:	fff80737          	lui	a4,0xfff80
ffffffffc0202184:	97ba                	add	a5,a5,a4
ffffffffc0202186:	079a                	slli	a5,a5,0x6
ffffffffc0202188:	953e                	add	a0,a0,a5
ffffffffc020218a:	100027f3          	csrr	a5,sstatus
ffffffffc020218e:	8b89                	andi	a5,a5,2
ffffffffc0202190:	18079d63          	bnez	a5,ffffffffc020232a <pmm_init+0x6de>
ffffffffc0202194:	000b3783          	ld	a5,0(s6)
ffffffffc0202198:	4585                	li	a1,1
ffffffffc020219a:	739c                	ld	a5,32(a5)
ffffffffc020219c:	9782                	jalr	a5
ffffffffc020219e:	000ab783          	ld	a5,0(s5)
ffffffffc02021a2:	6098                	ld	a4,0(s1)
ffffffffc02021a4:	078a                	slli	a5,a5,0x2
ffffffffc02021a6:	83b1                	srli	a5,a5,0xc
ffffffffc02021a8:	20e7f563          	bgeu	a5,a4,ffffffffc02023b2 <pmm_init+0x766>
ffffffffc02021ac:	000bb503          	ld	a0,0(s7)
ffffffffc02021b0:	fff80737          	lui	a4,0xfff80
ffffffffc02021b4:	97ba                	add	a5,a5,a4
ffffffffc02021b6:	079a                	slli	a5,a5,0x6
ffffffffc02021b8:	953e                	add	a0,a0,a5
ffffffffc02021ba:	100027f3          	csrr	a5,sstatus
ffffffffc02021be:	8b89                	andi	a5,a5,2
ffffffffc02021c0:	14079963          	bnez	a5,ffffffffc0202312 <pmm_init+0x6c6>
ffffffffc02021c4:	000b3783          	ld	a5,0(s6)
ffffffffc02021c8:	4585                	li	a1,1
ffffffffc02021ca:	739c                	ld	a5,32(a5)
ffffffffc02021cc:	9782                	jalr	a5
ffffffffc02021ce:	00093783          	ld	a5,0(s2)
ffffffffc02021d2:	0007b023          	sd	zero,0(a5)
ffffffffc02021d6:	12000073          	sfence.vma
ffffffffc02021da:	100027f3          	csrr	a5,sstatus
ffffffffc02021de:	8b89                	andi	a5,a5,2
ffffffffc02021e0:	10079f63          	bnez	a5,ffffffffc02022fe <pmm_init+0x6b2>
ffffffffc02021e4:	000b3783          	ld	a5,0(s6)
ffffffffc02021e8:	779c                	ld	a5,40(a5)
ffffffffc02021ea:	9782                	jalr	a5
ffffffffc02021ec:	842a                	mv	s0,a0
ffffffffc02021ee:	4c8c1e63          	bne	s8,s0,ffffffffc02026ca <pmm_init+0xa7e>
ffffffffc02021f2:	0000b517          	auipc	a0,0xb
ffffffffc02021f6:	88650513          	addi	a0,a0,-1914 # ffffffffc020ca78 <commands+0xfa8>
ffffffffc02021fa:	f31fd0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02021fe:	7406                	ld	s0,96(sp)
ffffffffc0202200:	70a6                	ld	ra,104(sp)
ffffffffc0202202:	64e6                	ld	s1,88(sp)
ffffffffc0202204:	6946                	ld	s2,80(sp)
ffffffffc0202206:	69a6                	ld	s3,72(sp)
ffffffffc0202208:	6a06                	ld	s4,64(sp)
ffffffffc020220a:	7ae2                	ld	s5,56(sp)
ffffffffc020220c:	7b42                	ld	s6,48(sp)
ffffffffc020220e:	7ba2                	ld	s7,40(sp)
ffffffffc0202210:	7c02                	ld	s8,32(sp)
ffffffffc0202212:	6ce2                	ld	s9,24(sp)
ffffffffc0202214:	6165                	addi	sp,sp,112
ffffffffc0202216:	6960106f          	j	ffffffffc02038ac <kmalloc_init>
ffffffffc020221a:	c80007b7          	lui	a5,0xc8000
ffffffffc020221e:	bc7d                	j	ffffffffc0201cdc <pmm_init+0x90>
ffffffffc0202220:	b81fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202224:	000b3783          	ld	a5,0(s6)
ffffffffc0202228:	4505                	li	a0,1
ffffffffc020222a:	6f9c                	ld	a5,24(a5)
ffffffffc020222c:	9782                	jalr	a5
ffffffffc020222e:	8c2a                	mv	s8,a0
ffffffffc0202230:	b6bfe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202234:	b9a9                	j	ffffffffc0201e8e <pmm_init+0x242>
ffffffffc0202236:	b6bfe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020223a:	000b3783          	ld	a5,0(s6)
ffffffffc020223e:	4505                	li	a0,1
ffffffffc0202240:	6f9c                	ld	a5,24(a5)
ffffffffc0202242:	9782                	jalr	a5
ffffffffc0202244:	8a2a                	mv	s4,a0
ffffffffc0202246:	b55fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020224a:	b645                	j	ffffffffc0201dea <pmm_init+0x19e>
ffffffffc020224c:	b55fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202250:	000b3783          	ld	a5,0(s6)
ffffffffc0202254:	779c                	ld	a5,40(a5)
ffffffffc0202256:	9782                	jalr	a5
ffffffffc0202258:	842a                	mv	s0,a0
ffffffffc020225a:	b41fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020225e:	b6b9                	j	ffffffffc0201dac <pmm_init+0x160>
ffffffffc0202260:	6705                	lui	a4,0x1
ffffffffc0202262:	177d                	addi	a4,a4,-1
ffffffffc0202264:	96ba                	add	a3,a3,a4
ffffffffc0202266:	8ff5                	and	a5,a5,a3
ffffffffc0202268:	00c7d713          	srli	a4,a5,0xc
ffffffffc020226c:	14a77363          	bgeu	a4,a0,ffffffffc02023b2 <pmm_init+0x766>
ffffffffc0202270:	000b3683          	ld	a3,0(s6)
ffffffffc0202274:	fff80537          	lui	a0,0xfff80
ffffffffc0202278:	972a                	add	a4,a4,a0
ffffffffc020227a:	6a94                	ld	a3,16(a3)
ffffffffc020227c:	8c1d                	sub	s0,s0,a5
ffffffffc020227e:	00671513          	slli	a0,a4,0x6
ffffffffc0202282:	00c45593          	srli	a1,s0,0xc
ffffffffc0202286:	9532                	add	a0,a0,a2
ffffffffc0202288:	9682                	jalr	a3
ffffffffc020228a:	0009b583          	ld	a1,0(s3)
ffffffffc020228e:	b4c1                	j	ffffffffc0201d4e <pmm_init+0x102>
ffffffffc0202290:	b11fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202294:	000b3783          	ld	a5,0(s6)
ffffffffc0202298:	779c                	ld	a5,40(a5)
ffffffffc020229a:	9782                	jalr	a5
ffffffffc020229c:	8c2a                	mv	s8,a0
ffffffffc020229e:	afdfe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02022a2:	bb79                	j	ffffffffc0202040 <pmm_init+0x3f4>
ffffffffc02022a4:	afdfe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02022a8:	000b3783          	ld	a5,0(s6)
ffffffffc02022ac:	779c                	ld	a5,40(a5)
ffffffffc02022ae:	9782                	jalr	a5
ffffffffc02022b0:	8a2a                	mv	s4,a0
ffffffffc02022b2:	ae9fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02022b6:	b39d                	j	ffffffffc020201c <pmm_init+0x3d0>
ffffffffc02022b8:	e42a                	sd	a0,8(sp)
ffffffffc02022ba:	ae7fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02022be:	000b3783          	ld	a5,0(s6)
ffffffffc02022c2:	6522                	ld	a0,8(sp)
ffffffffc02022c4:	4585                	li	a1,1
ffffffffc02022c6:	739c                	ld	a5,32(a5)
ffffffffc02022c8:	9782                	jalr	a5
ffffffffc02022ca:	ad1fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02022ce:	b33d                	j	ffffffffc0201ffc <pmm_init+0x3b0>
ffffffffc02022d0:	e42a                	sd	a0,8(sp)
ffffffffc02022d2:	acffe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02022d6:	000b3783          	ld	a5,0(s6)
ffffffffc02022da:	6522                	ld	a0,8(sp)
ffffffffc02022dc:	4585                	li	a1,1
ffffffffc02022de:	739c                	ld	a5,32(a5)
ffffffffc02022e0:	9782                	jalr	a5
ffffffffc02022e2:	ab9fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02022e6:	b1dd                	j	ffffffffc0201fcc <pmm_init+0x380>
ffffffffc02022e8:	ab9fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02022ec:	000b3783          	ld	a5,0(s6)
ffffffffc02022f0:	4505                	li	a0,1
ffffffffc02022f2:	6f9c                	ld	a5,24(a5)
ffffffffc02022f4:	9782                	jalr	a5
ffffffffc02022f6:	8a2a                	mv	s4,a0
ffffffffc02022f8:	aa3fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02022fc:	b36d                	j	ffffffffc02020a6 <pmm_init+0x45a>
ffffffffc02022fe:	aa3fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202302:	000b3783          	ld	a5,0(s6)
ffffffffc0202306:	779c                	ld	a5,40(a5)
ffffffffc0202308:	9782                	jalr	a5
ffffffffc020230a:	842a                	mv	s0,a0
ffffffffc020230c:	a8ffe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202310:	bdf9                	j	ffffffffc02021ee <pmm_init+0x5a2>
ffffffffc0202312:	e42a                	sd	a0,8(sp)
ffffffffc0202314:	a8dfe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202318:	000b3783          	ld	a5,0(s6)
ffffffffc020231c:	6522                	ld	a0,8(sp)
ffffffffc020231e:	4585                	li	a1,1
ffffffffc0202320:	739c                	ld	a5,32(a5)
ffffffffc0202322:	9782                	jalr	a5
ffffffffc0202324:	a77fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202328:	b55d                	j	ffffffffc02021ce <pmm_init+0x582>
ffffffffc020232a:	e42a                	sd	a0,8(sp)
ffffffffc020232c:	a75fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202330:	000b3783          	ld	a5,0(s6)
ffffffffc0202334:	6522                	ld	a0,8(sp)
ffffffffc0202336:	4585                	li	a1,1
ffffffffc0202338:	739c                	ld	a5,32(a5)
ffffffffc020233a:	9782                	jalr	a5
ffffffffc020233c:	a5ffe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202340:	bdb9                	j	ffffffffc020219e <pmm_init+0x552>
ffffffffc0202342:	a5ffe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202346:	000b3783          	ld	a5,0(s6)
ffffffffc020234a:	4585                	li	a1,1
ffffffffc020234c:	8552                	mv	a0,s4
ffffffffc020234e:	739c                	ld	a5,32(a5)
ffffffffc0202350:	9782                	jalr	a5
ffffffffc0202352:	a49fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202356:	bd29                	j	ffffffffc0202170 <pmm_init+0x524>
ffffffffc0202358:	86a2                	mv	a3,s0
ffffffffc020235a:	0000a617          	auipc	a2,0xa
ffffffffc020235e:	0fe60613          	addi	a2,a2,254 # ffffffffc020c458 <commands+0x988>
ffffffffc0202362:	24400593          	li	a1,580
ffffffffc0202366:	0000a517          	auipc	a0,0xa
ffffffffc020236a:	11a50513          	addi	a0,a0,282 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020236e:	ec1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202372:	0000a697          	auipc	a3,0xa
ffffffffc0202376:	5a668693          	addi	a3,a3,1446 # ffffffffc020c918 <commands+0xe48>
ffffffffc020237a:	0000a617          	auipc	a2,0xa
ffffffffc020237e:	9a660613          	addi	a2,a2,-1626 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202382:	24500593          	li	a1,581
ffffffffc0202386:	0000a517          	auipc	a0,0xa
ffffffffc020238a:	0fa50513          	addi	a0,a0,250 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020238e:	ea1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202392:	0000a697          	auipc	a3,0xa
ffffffffc0202396:	54668693          	addi	a3,a3,1350 # ffffffffc020c8d8 <commands+0xe08>
ffffffffc020239a:	0000a617          	auipc	a2,0xa
ffffffffc020239e:	98660613          	addi	a2,a2,-1658 # ffffffffc020bd20 <commands+0x250>
ffffffffc02023a2:	24400593          	li	a1,580
ffffffffc02023a6:	0000a517          	auipc	a0,0xa
ffffffffc02023aa:	0da50513          	addi	a0,a0,218 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02023ae:	e81fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02023b2:	fc5fe0ef          	jal	ra,ffffffffc0201376 <pa2page.part.0>
ffffffffc02023b6:	fddfe0ef          	jal	ra,ffffffffc0201392 <pte2page.part.0>
ffffffffc02023ba:	0000a697          	auipc	a3,0xa
ffffffffc02023be:	31668693          	addi	a3,a3,790 # ffffffffc020c6d0 <commands+0xc00>
ffffffffc02023c2:	0000a617          	auipc	a2,0xa
ffffffffc02023c6:	95e60613          	addi	a2,a2,-1698 # ffffffffc020bd20 <commands+0x250>
ffffffffc02023ca:	21400593          	li	a1,532
ffffffffc02023ce:	0000a517          	auipc	a0,0xa
ffffffffc02023d2:	0b250513          	addi	a0,a0,178 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02023d6:	e59fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02023da:	0000a697          	auipc	a3,0xa
ffffffffc02023de:	23668693          	addi	a3,a3,566 # ffffffffc020c610 <commands+0xb40>
ffffffffc02023e2:	0000a617          	auipc	a2,0xa
ffffffffc02023e6:	93e60613          	addi	a2,a2,-1730 # ffffffffc020bd20 <commands+0x250>
ffffffffc02023ea:	20700593          	li	a1,519
ffffffffc02023ee:	0000a517          	auipc	a0,0xa
ffffffffc02023f2:	09250513          	addi	a0,a0,146 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02023f6:	e39fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02023fa:	0000a697          	auipc	a3,0xa
ffffffffc02023fe:	1d668693          	addi	a3,a3,470 # ffffffffc020c5d0 <commands+0xb00>
ffffffffc0202402:	0000a617          	auipc	a2,0xa
ffffffffc0202406:	91e60613          	addi	a2,a2,-1762 # ffffffffc020bd20 <commands+0x250>
ffffffffc020240a:	20600593          	li	a1,518
ffffffffc020240e:	0000a517          	auipc	a0,0xa
ffffffffc0202412:	07250513          	addi	a0,a0,114 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202416:	e19fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020241a:	0000a697          	auipc	a3,0xa
ffffffffc020241e:	19668693          	addi	a3,a3,406 # ffffffffc020c5b0 <commands+0xae0>
ffffffffc0202422:	0000a617          	auipc	a2,0xa
ffffffffc0202426:	8fe60613          	addi	a2,a2,-1794 # ffffffffc020bd20 <commands+0x250>
ffffffffc020242a:	20500593          	li	a1,517
ffffffffc020242e:	0000a517          	auipc	a0,0xa
ffffffffc0202432:	05250513          	addi	a0,a0,82 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202436:	df9fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020243a:	0000a617          	auipc	a2,0xa
ffffffffc020243e:	01e60613          	addi	a2,a2,30 # ffffffffc020c458 <commands+0x988>
ffffffffc0202442:	07100593          	li	a1,113
ffffffffc0202446:	0000a517          	auipc	a0,0xa
ffffffffc020244a:	fda50513          	addi	a0,a0,-38 # ffffffffc020c420 <commands+0x950>
ffffffffc020244e:	de1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202452:	0000a697          	auipc	a3,0xa
ffffffffc0202456:	40e68693          	addi	a3,a3,1038 # ffffffffc020c860 <commands+0xd90>
ffffffffc020245a:	0000a617          	auipc	a2,0xa
ffffffffc020245e:	8c660613          	addi	a2,a2,-1850 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202462:	22d00593          	li	a1,557
ffffffffc0202466:	0000a517          	auipc	a0,0xa
ffffffffc020246a:	01a50513          	addi	a0,a0,26 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020246e:	dc1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202472:	0000a697          	auipc	a3,0xa
ffffffffc0202476:	3a668693          	addi	a3,a3,934 # ffffffffc020c818 <commands+0xd48>
ffffffffc020247a:	0000a617          	auipc	a2,0xa
ffffffffc020247e:	8a660613          	addi	a2,a2,-1882 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202482:	22b00593          	li	a1,555
ffffffffc0202486:	0000a517          	auipc	a0,0xa
ffffffffc020248a:	ffa50513          	addi	a0,a0,-6 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020248e:	da1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202492:	0000a697          	auipc	a3,0xa
ffffffffc0202496:	3b668693          	addi	a3,a3,950 # ffffffffc020c848 <commands+0xd78>
ffffffffc020249a:	0000a617          	auipc	a2,0xa
ffffffffc020249e:	88660613          	addi	a2,a2,-1914 # ffffffffc020bd20 <commands+0x250>
ffffffffc02024a2:	22a00593          	li	a1,554
ffffffffc02024a6:	0000a517          	auipc	a0,0xa
ffffffffc02024aa:	fda50513          	addi	a0,a0,-38 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02024ae:	d81fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02024b2:	0000a697          	auipc	a3,0xa
ffffffffc02024b6:	47e68693          	addi	a3,a3,1150 # ffffffffc020c930 <commands+0xe60>
ffffffffc02024ba:	0000a617          	auipc	a2,0xa
ffffffffc02024be:	86660613          	addi	a2,a2,-1946 # ffffffffc020bd20 <commands+0x250>
ffffffffc02024c2:	24800593          	li	a1,584
ffffffffc02024c6:	0000a517          	auipc	a0,0xa
ffffffffc02024ca:	fba50513          	addi	a0,a0,-70 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02024ce:	d61fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02024d2:	0000a697          	auipc	a3,0xa
ffffffffc02024d6:	3be68693          	addi	a3,a3,958 # ffffffffc020c890 <commands+0xdc0>
ffffffffc02024da:	0000a617          	auipc	a2,0xa
ffffffffc02024de:	84660613          	addi	a2,a2,-1978 # ffffffffc020bd20 <commands+0x250>
ffffffffc02024e2:	23500593          	li	a1,565
ffffffffc02024e6:	0000a517          	auipc	a0,0xa
ffffffffc02024ea:	f9a50513          	addi	a0,a0,-102 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02024ee:	d41fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02024f2:	0000a697          	auipc	a3,0xa
ffffffffc02024f6:	49668693          	addi	a3,a3,1174 # ffffffffc020c988 <commands+0xeb8>
ffffffffc02024fa:	0000a617          	auipc	a2,0xa
ffffffffc02024fe:	82660613          	addi	a2,a2,-2010 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202502:	24d00593          	li	a1,589
ffffffffc0202506:	0000a517          	auipc	a0,0xa
ffffffffc020250a:	f7a50513          	addi	a0,a0,-134 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020250e:	d21fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202512:	0000a697          	auipc	a3,0xa
ffffffffc0202516:	43668693          	addi	a3,a3,1078 # ffffffffc020c948 <commands+0xe78>
ffffffffc020251a:	0000a617          	auipc	a2,0xa
ffffffffc020251e:	80660613          	addi	a2,a2,-2042 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202522:	24c00593          	li	a1,588
ffffffffc0202526:	0000a517          	auipc	a0,0xa
ffffffffc020252a:	f5a50513          	addi	a0,a0,-166 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020252e:	d01fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202532:	0000a697          	auipc	a3,0xa
ffffffffc0202536:	2e668693          	addi	a3,a3,742 # ffffffffc020c818 <commands+0xd48>
ffffffffc020253a:	00009617          	auipc	a2,0x9
ffffffffc020253e:	7e660613          	addi	a2,a2,2022 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202542:	22700593          	li	a1,551
ffffffffc0202546:	0000a517          	auipc	a0,0xa
ffffffffc020254a:	f3a50513          	addi	a0,a0,-198 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020254e:	ce1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202552:	0000a697          	auipc	a3,0xa
ffffffffc0202556:	16668693          	addi	a3,a3,358 # ffffffffc020c6b8 <commands+0xbe8>
ffffffffc020255a:	00009617          	auipc	a2,0x9
ffffffffc020255e:	7c660613          	addi	a2,a2,1990 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202562:	22600593          	li	a1,550
ffffffffc0202566:	0000a517          	auipc	a0,0xa
ffffffffc020256a:	f1a50513          	addi	a0,a0,-230 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020256e:	cc1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202572:	0000a697          	auipc	a3,0xa
ffffffffc0202576:	2be68693          	addi	a3,a3,702 # ffffffffc020c830 <commands+0xd60>
ffffffffc020257a:	00009617          	auipc	a2,0x9
ffffffffc020257e:	7a660613          	addi	a2,a2,1958 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202582:	22300593          	li	a1,547
ffffffffc0202586:	0000a517          	auipc	a0,0xa
ffffffffc020258a:	efa50513          	addi	a0,a0,-262 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020258e:	ca1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202592:	0000a697          	auipc	a3,0xa
ffffffffc0202596:	10e68693          	addi	a3,a3,270 # ffffffffc020c6a0 <commands+0xbd0>
ffffffffc020259a:	00009617          	auipc	a2,0x9
ffffffffc020259e:	78660613          	addi	a2,a2,1926 # ffffffffc020bd20 <commands+0x250>
ffffffffc02025a2:	22200593          	li	a1,546
ffffffffc02025a6:	0000a517          	auipc	a0,0xa
ffffffffc02025aa:	eda50513          	addi	a0,a0,-294 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02025ae:	c81fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02025b2:	0000a697          	auipc	a3,0xa
ffffffffc02025b6:	18e68693          	addi	a3,a3,398 # ffffffffc020c740 <commands+0xc70>
ffffffffc02025ba:	00009617          	auipc	a2,0x9
ffffffffc02025be:	76660613          	addi	a2,a2,1894 # ffffffffc020bd20 <commands+0x250>
ffffffffc02025c2:	22100593          	li	a1,545
ffffffffc02025c6:	0000a517          	auipc	a0,0xa
ffffffffc02025ca:	eba50513          	addi	a0,a0,-326 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02025ce:	c61fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02025d2:	0000a697          	auipc	a3,0xa
ffffffffc02025d6:	24668693          	addi	a3,a3,582 # ffffffffc020c818 <commands+0xd48>
ffffffffc02025da:	00009617          	auipc	a2,0x9
ffffffffc02025de:	74660613          	addi	a2,a2,1862 # ffffffffc020bd20 <commands+0x250>
ffffffffc02025e2:	22000593          	li	a1,544
ffffffffc02025e6:	0000a517          	auipc	a0,0xa
ffffffffc02025ea:	e9a50513          	addi	a0,a0,-358 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02025ee:	c41fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02025f2:	0000a697          	auipc	a3,0xa
ffffffffc02025f6:	20e68693          	addi	a3,a3,526 # ffffffffc020c800 <commands+0xd30>
ffffffffc02025fa:	00009617          	auipc	a2,0x9
ffffffffc02025fe:	72660613          	addi	a2,a2,1830 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202602:	21f00593          	li	a1,543
ffffffffc0202606:	0000a517          	auipc	a0,0xa
ffffffffc020260a:	e7a50513          	addi	a0,a0,-390 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020260e:	c21fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202612:	0000a697          	auipc	a3,0xa
ffffffffc0202616:	1be68693          	addi	a3,a3,446 # ffffffffc020c7d0 <commands+0xd00>
ffffffffc020261a:	00009617          	auipc	a2,0x9
ffffffffc020261e:	70660613          	addi	a2,a2,1798 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202622:	21e00593          	li	a1,542
ffffffffc0202626:	0000a517          	auipc	a0,0xa
ffffffffc020262a:	e5a50513          	addi	a0,a0,-422 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020262e:	c01fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202632:	0000a697          	auipc	a3,0xa
ffffffffc0202636:	18668693          	addi	a3,a3,390 # ffffffffc020c7b8 <commands+0xce8>
ffffffffc020263a:	00009617          	auipc	a2,0x9
ffffffffc020263e:	6e660613          	addi	a2,a2,1766 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202642:	21c00593          	li	a1,540
ffffffffc0202646:	0000a517          	auipc	a0,0xa
ffffffffc020264a:	e3a50513          	addi	a0,a0,-454 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020264e:	be1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202652:	0000a697          	auipc	a3,0xa
ffffffffc0202656:	14668693          	addi	a3,a3,326 # ffffffffc020c798 <commands+0xcc8>
ffffffffc020265a:	00009617          	auipc	a2,0x9
ffffffffc020265e:	6c660613          	addi	a2,a2,1734 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202662:	21b00593          	li	a1,539
ffffffffc0202666:	0000a517          	auipc	a0,0xa
ffffffffc020266a:	e1a50513          	addi	a0,a0,-486 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020266e:	bc1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202672:	0000a697          	auipc	a3,0xa
ffffffffc0202676:	11668693          	addi	a3,a3,278 # ffffffffc020c788 <commands+0xcb8>
ffffffffc020267a:	00009617          	auipc	a2,0x9
ffffffffc020267e:	6a660613          	addi	a2,a2,1702 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202682:	21a00593          	li	a1,538
ffffffffc0202686:	0000a517          	auipc	a0,0xa
ffffffffc020268a:	dfa50513          	addi	a0,a0,-518 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020268e:	ba1fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202692:	0000a697          	auipc	a3,0xa
ffffffffc0202696:	0e668693          	addi	a3,a3,230 # ffffffffc020c778 <commands+0xca8>
ffffffffc020269a:	00009617          	auipc	a2,0x9
ffffffffc020269e:	68660613          	addi	a2,a2,1670 # ffffffffc020bd20 <commands+0x250>
ffffffffc02026a2:	21900593          	li	a1,537
ffffffffc02026a6:	0000a517          	auipc	a0,0xa
ffffffffc02026aa:	dda50513          	addi	a0,a0,-550 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02026ae:	b81fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02026b2:	0000a617          	auipc	a2,0xa
ffffffffc02026b6:	e3e60613          	addi	a2,a2,-450 # ffffffffc020c4f0 <commands+0xa20>
ffffffffc02026ba:	06500593          	li	a1,101
ffffffffc02026be:	0000a517          	auipc	a0,0xa
ffffffffc02026c2:	dc250513          	addi	a0,a0,-574 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02026c6:	b69fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02026ca:	0000a697          	auipc	a3,0xa
ffffffffc02026ce:	1c668693          	addi	a3,a3,454 # ffffffffc020c890 <commands+0xdc0>
ffffffffc02026d2:	00009617          	auipc	a2,0x9
ffffffffc02026d6:	64e60613          	addi	a2,a2,1614 # ffffffffc020bd20 <commands+0x250>
ffffffffc02026da:	25f00593          	li	a1,607
ffffffffc02026de:	0000a517          	auipc	a0,0xa
ffffffffc02026e2:	da250513          	addi	a0,a0,-606 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02026e6:	b49fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02026ea:	0000a697          	auipc	a3,0xa
ffffffffc02026ee:	05668693          	addi	a3,a3,86 # ffffffffc020c740 <commands+0xc70>
ffffffffc02026f2:	00009617          	auipc	a2,0x9
ffffffffc02026f6:	62e60613          	addi	a2,a2,1582 # ffffffffc020bd20 <commands+0x250>
ffffffffc02026fa:	21800593          	li	a1,536
ffffffffc02026fe:	0000a517          	auipc	a0,0xa
ffffffffc0202702:	d8250513          	addi	a0,a0,-638 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202706:	b29fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020270a:	0000a697          	auipc	a3,0xa
ffffffffc020270e:	ff668693          	addi	a3,a3,-10 # ffffffffc020c700 <commands+0xc30>
ffffffffc0202712:	00009617          	auipc	a2,0x9
ffffffffc0202716:	60e60613          	addi	a2,a2,1550 # ffffffffc020bd20 <commands+0x250>
ffffffffc020271a:	21700593          	li	a1,535
ffffffffc020271e:	0000a517          	auipc	a0,0xa
ffffffffc0202722:	d6250513          	addi	a0,a0,-670 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202726:	b09fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020272a:	86d6                	mv	a3,s5
ffffffffc020272c:	0000a617          	auipc	a2,0xa
ffffffffc0202730:	d2c60613          	addi	a2,a2,-724 # ffffffffc020c458 <commands+0x988>
ffffffffc0202734:	21300593          	li	a1,531
ffffffffc0202738:	0000a517          	auipc	a0,0xa
ffffffffc020273c:	d4850513          	addi	a0,a0,-696 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202740:	aeffd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202744:	0000a617          	auipc	a2,0xa
ffffffffc0202748:	d1460613          	addi	a2,a2,-748 # ffffffffc020c458 <commands+0x988>
ffffffffc020274c:	21200593          	li	a1,530
ffffffffc0202750:	0000a517          	auipc	a0,0xa
ffffffffc0202754:	d3050513          	addi	a0,a0,-720 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202758:	ad7fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020275c:	0000a697          	auipc	a3,0xa
ffffffffc0202760:	f5c68693          	addi	a3,a3,-164 # ffffffffc020c6b8 <commands+0xbe8>
ffffffffc0202764:	00009617          	auipc	a2,0x9
ffffffffc0202768:	5bc60613          	addi	a2,a2,1468 # ffffffffc020bd20 <commands+0x250>
ffffffffc020276c:	21000593          	li	a1,528
ffffffffc0202770:	0000a517          	auipc	a0,0xa
ffffffffc0202774:	d1050513          	addi	a0,a0,-752 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202778:	ab7fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020277c:	0000a697          	auipc	a3,0xa
ffffffffc0202780:	f2468693          	addi	a3,a3,-220 # ffffffffc020c6a0 <commands+0xbd0>
ffffffffc0202784:	00009617          	auipc	a2,0x9
ffffffffc0202788:	59c60613          	addi	a2,a2,1436 # ffffffffc020bd20 <commands+0x250>
ffffffffc020278c:	20f00593          	li	a1,527
ffffffffc0202790:	0000a517          	auipc	a0,0xa
ffffffffc0202794:	cf050513          	addi	a0,a0,-784 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202798:	a97fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020279c:	0000a697          	auipc	a3,0xa
ffffffffc02027a0:	2b468693          	addi	a3,a3,692 # ffffffffc020ca50 <commands+0xf80>
ffffffffc02027a4:	00009617          	auipc	a2,0x9
ffffffffc02027a8:	57c60613          	addi	a2,a2,1404 # ffffffffc020bd20 <commands+0x250>
ffffffffc02027ac:	25600593          	li	a1,598
ffffffffc02027b0:	0000a517          	auipc	a0,0xa
ffffffffc02027b4:	cd050513          	addi	a0,a0,-816 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02027b8:	a77fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02027bc:	0000a697          	auipc	a3,0xa
ffffffffc02027c0:	25c68693          	addi	a3,a3,604 # ffffffffc020ca18 <commands+0xf48>
ffffffffc02027c4:	00009617          	auipc	a2,0x9
ffffffffc02027c8:	55c60613          	addi	a2,a2,1372 # ffffffffc020bd20 <commands+0x250>
ffffffffc02027cc:	25300593          	li	a1,595
ffffffffc02027d0:	0000a517          	auipc	a0,0xa
ffffffffc02027d4:	cb050513          	addi	a0,a0,-848 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02027d8:	a57fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02027dc:	0000a697          	auipc	a3,0xa
ffffffffc02027e0:	20c68693          	addi	a3,a3,524 # ffffffffc020c9e8 <commands+0xf18>
ffffffffc02027e4:	00009617          	auipc	a2,0x9
ffffffffc02027e8:	53c60613          	addi	a2,a2,1340 # ffffffffc020bd20 <commands+0x250>
ffffffffc02027ec:	24f00593          	li	a1,591
ffffffffc02027f0:	0000a517          	auipc	a0,0xa
ffffffffc02027f4:	c9050513          	addi	a0,a0,-880 # ffffffffc020c480 <commands+0x9b0>
ffffffffc02027f8:	a37fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02027fc:	0000a697          	auipc	a3,0xa
ffffffffc0202800:	1a468693          	addi	a3,a3,420 # ffffffffc020c9a0 <commands+0xed0>
ffffffffc0202804:	00009617          	auipc	a2,0x9
ffffffffc0202808:	51c60613          	addi	a2,a2,1308 # ffffffffc020bd20 <commands+0x250>
ffffffffc020280c:	24e00593          	li	a1,590
ffffffffc0202810:	0000a517          	auipc	a0,0xa
ffffffffc0202814:	c7050513          	addi	a0,a0,-912 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202818:	a17fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020281c:	0000a617          	auipc	a2,0xa
ffffffffc0202820:	d3460613          	addi	a2,a2,-716 # ffffffffc020c550 <commands+0xa80>
ffffffffc0202824:	0c900593          	li	a1,201
ffffffffc0202828:	0000a517          	auipc	a0,0xa
ffffffffc020282c:	c5850513          	addi	a0,a0,-936 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202830:	9fffd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202834:	0000a617          	auipc	a2,0xa
ffffffffc0202838:	d1c60613          	addi	a2,a2,-740 # ffffffffc020c550 <commands+0xa80>
ffffffffc020283c:	08100593          	li	a1,129
ffffffffc0202840:	0000a517          	auipc	a0,0xa
ffffffffc0202844:	c4050513          	addi	a0,a0,-960 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202848:	9e7fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020284c:	0000a697          	auipc	a3,0xa
ffffffffc0202850:	e2468693          	addi	a3,a3,-476 # ffffffffc020c670 <commands+0xba0>
ffffffffc0202854:	00009617          	auipc	a2,0x9
ffffffffc0202858:	4cc60613          	addi	a2,a2,1228 # ffffffffc020bd20 <commands+0x250>
ffffffffc020285c:	20e00593          	li	a1,526
ffffffffc0202860:	0000a517          	auipc	a0,0xa
ffffffffc0202864:	c2050513          	addi	a0,a0,-992 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202868:	9c7fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020286c:	0000a697          	auipc	a3,0xa
ffffffffc0202870:	dd468693          	addi	a3,a3,-556 # ffffffffc020c640 <commands+0xb70>
ffffffffc0202874:	00009617          	auipc	a2,0x9
ffffffffc0202878:	4ac60613          	addi	a2,a2,1196 # ffffffffc020bd20 <commands+0x250>
ffffffffc020287c:	20b00593          	li	a1,523
ffffffffc0202880:	0000a517          	auipc	a0,0xa
ffffffffc0202884:	c0050513          	addi	a0,a0,-1024 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202888:	9a7fd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020288c <copy_range>:
ffffffffc020288c:	7119                	addi	sp,sp,-128
ffffffffc020288e:	00d667b3          	or	a5,a2,a3
ffffffffc0202892:	fc86                	sd	ra,120(sp)
ffffffffc0202894:	f8a2                	sd	s0,112(sp)
ffffffffc0202896:	f4a6                	sd	s1,104(sp)
ffffffffc0202898:	f0ca                	sd	s2,96(sp)
ffffffffc020289a:	ecce                	sd	s3,88(sp)
ffffffffc020289c:	e8d2                	sd	s4,80(sp)
ffffffffc020289e:	e4d6                	sd	s5,72(sp)
ffffffffc02028a0:	e0da                	sd	s6,64(sp)
ffffffffc02028a2:	fc5e                	sd	s7,56(sp)
ffffffffc02028a4:	f862                	sd	s8,48(sp)
ffffffffc02028a6:	f466                	sd	s9,40(sp)
ffffffffc02028a8:	f06a                	sd	s10,32(sp)
ffffffffc02028aa:	ec6e                	sd	s11,24(sp)
ffffffffc02028ac:	17d2                	slli	a5,a5,0x34
ffffffffc02028ae:	22079263          	bnez	a5,ffffffffc0202ad2 <copy_range+0x246>
ffffffffc02028b2:	002007b7          	lui	a5,0x200
ffffffffc02028b6:	8432                	mv	s0,a2
ffffffffc02028b8:	1cf66163          	bltu	a2,a5,ffffffffc0202a7a <copy_range+0x1ee>
ffffffffc02028bc:	84b6                	mv	s1,a3
ffffffffc02028be:	1ad67e63          	bgeu	a2,a3,ffffffffc0202a7a <copy_range+0x1ee>
ffffffffc02028c2:	4785                	li	a5,1
ffffffffc02028c4:	07fe                	slli	a5,a5,0x1f
ffffffffc02028c6:	1ad7ea63          	bltu	a5,a3,ffffffffc0202a7a <copy_range+0x1ee>
ffffffffc02028ca:	5cfd                	li	s9,-1
ffffffffc02028cc:	00ccd793          	srli	a5,s9,0xc
ffffffffc02028d0:	8a2a                	mv	s4,a0
ffffffffc02028d2:	892e                	mv	s2,a1
ffffffffc02028d4:	8aba                	mv	s5,a4
ffffffffc02028d6:	6985                	lui	s3,0x1
ffffffffc02028d8:	00094b97          	auipc	s7,0x94
ffffffffc02028dc:	000b8b93          	mv	s7,s7
ffffffffc02028e0:	00094b17          	auipc	s6,0x94
ffffffffc02028e4:	000b0b13          	mv	s6,s6
ffffffffc02028e8:	fff80c37          	lui	s8,0xfff80
ffffffffc02028ec:	e03e                	sd	a5,0(sp)
ffffffffc02028ee:	00094d17          	auipc	s10,0x94
ffffffffc02028f2:	ffad0d13          	addi	s10,s10,-6 # ffffffffc02968e8 <pmm_manager>
ffffffffc02028f6:	4601                	li	a2,0
ffffffffc02028f8:	85a2                	mv	a1,s0
ffffffffc02028fa:	854a                	mv	a0,s2
ffffffffc02028fc:	b6bfe0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc0202900:	8caa                	mv	s9,a0
ffffffffc0202902:	cd51                	beqz	a0,ffffffffc020299e <copy_range+0x112>
ffffffffc0202904:	6118                	ld	a4,0(a0)
ffffffffc0202906:	8b05                	andi	a4,a4,1
ffffffffc0202908:	e705                	bnez	a4,ffffffffc0202930 <copy_range+0xa4>
ffffffffc020290a:	944e                	add	s0,s0,s3
ffffffffc020290c:	fe9465e3          	bltu	s0,s1,ffffffffc02028f6 <copy_range+0x6a>
ffffffffc0202910:	4501                	li	a0,0
ffffffffc0202912:	70e6                	ld	ra,120(sp)
ffffffffc0202914:	7446                	ld	s0,112(sp)
ffffffffc0202916:	74a6                	ld	s1,104(sp)
ffffffffc0202918:	7906                	ld	s2,96(sp)
ffffffffc020291a:	69e6                	ld	s3,88(sp)
ffffffffc020291c:	6a46                	ld	s4,80(sp)
ffffffffc020291e:	6aa6                	ld	s5,72(sp)
ffffffffc0202920:	6b06                	ld	s6,64(sp)
ffffffffc0202922:	7be2                	ld	s7,56(sp)
ffffffffc0202924:	7c42                	ld	s8,48(sp)
ffffffffc0202926:	7ca2                	ld	s9,40(sp)
ffffffffc0202928:	7d02                	ld	s10,32(sp)
ffffffffc020292a:	6de2                	ld	s11,24(sp)
ffffffffc020292c:	6109                	addi	sp,sp,128
ffffffffc020292e:	8082                	ret
ffffffffc0202930:	4605                	li	a2,1
ffffffffc0202932:	85a2                	mv	a1,s0
ffffffffc0202934:	8552                	mv	a0,s4
ffffffffc0202936:	b31fe0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc020293a:	12050263          	beqz	a0,ffffffffc0202a5e <copy_range+0x1d2>
ffffffffc020293e:	000cb783          	ld	a5,0(s9)
ffffffffc0202942:	0017f613          	andi	a2,a5,1
ffffffffc0202946:	0007871b          	sext.w	a4,a5
ffffffffc020294a:	01f7fc93          	andi	s9,a5,31
ffffffffc020294e:	10060a63          	beqz	a2,ffffffffc0202a62 <copy_range+0x1d6>
ffffffffc0202952:	000bb603          	ld	a2,0(s7) # ffffffffc02968d8 <npage>
ffffffffc0202956:	078a                	slli	a5,a5,0x2
ffffffffc0202958:	83b1                	srli	a5,a5,0xc
ffffffffc020295a:	14c7f063          	bgeu	a5,a2,ffffffffc0202a9a <copy_range+0x20e>
ffffffffc020295e:	000b3583          	ld	a1,0(s6) # ffffffffc02968e0 <pages>
ffffffffc0202962:	97e2                	add	a5,a5,s8
ffffffffc0202964:	079a                	slli	a5,a5,0x6
ffffffffc0202966:	95be                	add	a1,a1,a5
ffffffffc0202968:	040a8563          	beqz	s5,ffffffffc02029b2 <copy_range+0x126>
ffffffffc020296c:	00477793          	andi	a5,a4,4
ffffffffc0202970:	efdd                	bnez	a5,ffffffffc0202a2e <copy_range+0x1a2>
ffffffffc0202972:	86e6                	mv	a3,s9
ffffffffc0202974:	8622                	mv	a2,s0
ffffffffc0202976:	8552                	mv	a0,s4
ffffffffc0202978:	9deff0ef          	jal	ra,ffffffffc0201b56 <page_insert>
ffffffffc020297c:	d559                	beqz	a0,ffffffffc020290a <copy_range+0x7e>
ffffffffc020297e:	0000a697          	auipc	a3,0xa
ffffffffc0202982:	13a68693          	addi	a3,a3,314 # ffffffffc020cab8 <commands+0xfe8>
ffffffffc0202986:	00009617          	auipc	a2,0x9
ffffffffc020298a:	39a60613          	addi	a2,a2,922 # ffffffffc020bd20 <commands+0x250>
ffffffffc020298e:	1a300593          	li	a1,419
ffffffffc0202992:	0000a517          	auipc	a0,0xa
ffffffffc0202996:	aee50513          	addi	a0,a0,-1298 # ffffffffc020c480 <commands+0x9b0>
ffffffffc020299a:	895fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020299e:	00200637          	lui	a2,0x200
ffffffffc02029a2:	9432                	add	s0,s0,a2
ffffffffc02029a4:	ffe00637          	lui	a2,0xffe00
ffffffffc02029a8:	8c71                	and	s0,s0,a2
ffffffffc02029aa:	d03d                	beqz	s0,ffffffffc0202910 <copy_range+0x84>
ffffffffc02029ac:	f49465e3          	bltu	s0,s1,ffffffffc02028f6 <copy_range+0x6a>
ffffffffc02029b0:	b785                	j	ffffffffc0202910 <copy_range+0x84>
ffffffffc02029b2:	100027f3          	csrr	a5,sstatus
ffffffffc02029b6:	8b89                	andi	a5,a5,2
ffffffffc02029b8:	e42e                	sd	a1,8(sp)
ffffffffc02029ba:	e7d1                	bnez	a5,ffffffffc0202a46 <copy_range+0x1ba>
ffffffffc02029bc:	000d3783          	ld	a5,0(s10)
ffffffffc02029c0:	4505                	li	a0,1
ffffffffc02029c2:	6f9c                	ld	a5,24(a5)
ffffffffc02029c4:	9782                	jalr	a5
ffffffffc02029c6:	65a2                	ld	a1,8(sp)
ffffffffc02029c8:	8daa                	mv	s11,a0
ffffffffc02029ca:	0e058463          	beqz	a1,ffffffffc0202ab2 <copy_range+0x226>
ffffffffc02029ce:	140d8c63          	beqz	s11,ffffffffc0202b26 <copy_range+0x29a>
ffffffffc02029d2:	000b3703          	ld	a4,0(s6)
ffffffffc02029d6:	6682                	ld	a3,0(sp)
ffffffffc02029d8:	000808b7          	lui	a7,0x80
ffffffffc02029dc:	40e587b3          	sub	a5,a1,a4
ffffffffc02029e0:	8799                	srai	a5,a5,0x6
ffffffffc02029e2:	000bb603          	ld	a2,0(s7)
ffffffffc02029e6:	97c6                	add	a5,a5,a7
ffffffffc02029e8:	00d7f5b3          	and	a1,a5,a3
ffffffffc02029ec:	07b2                	slli	a5,a5,0xc
ffffffffc02029ee:	10c5ff63          	bgeu	a1,a2,ffffffffc0202b0c <copy_range+0x280>
ffffffffc02029f2:	00094697          	auipc	a3,0x94
ffffffffc02029f6:	efe68693          	addi	a3,a3,-258 # ffffffffc02968f0 <va_pa_offset>
ffffffffc02029fa:	6288                	ld	a0,0(a3)
ffffffffc02029fc:	40ed8733          	sub	a4,s11,a4
ffffffffc0202a00:	6682                	ld	a3,0(sp)
ffffffffc0202a02:	8719                	srai	a4,a4,0x6
ffffffffc0202a04:	9746                	add	a4,a4,a7
ffffffffc0202a06:	00d778b3          	and	a7,a4,a3
ffffffffc0202a0a:	00a785b3          	add	a1,a5,a0
ffffffffc0202a0e:	0732                	slli	a4,a4,0xc
ffffffffc0202a10:	0ec8f163          	bgeu	a7,a2,ffffffffc0202af2 <copy_range+0x266>
ffffffffc0202a14:	6605                	lui	a2,0x1
ffffffffc0202a16:	953a                	add	a0,a0,a4
ffffffffc0202a18:	167080ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc0202a1c:	86e6                	mv	a3,s9
ffffffffc0202a1e:	8622                	mv	a2,s0
ffffffffc0202a20:	85ee                	mv	a1,s11
ffffffffc0202a22:	8552                	mv	a0,s4
ffffffffc0202a24:	932ff0ef          	jal	ra,ffffffffc0201b56 <page_insert>
ffffffffc0202a28:	ee0501e3          	beqz	a0,ffffffffc020290a <copy_range+0x7e>
ffffffffc0202a2c:	bf89                	j	ffffffffc020297e <copy_range+0xf2>
ffffffffc0202a2e:	01b77693          	andi	a3,a4,27
ffffffffc0202a32:	1006ec93          	ori	s9,a3,256
ffffffffc0202a36:	86e6                	mv	a3,s9
ffffffffc0202a38:	8622                	mv	a2,s0
ffffffffc0202a3a:	854a                	mv	a0,s2
ffffffffc0202a3c:	e42e                	sd	a1,8(sp)
ffffffffc0202a3e:	918ff0ef          	jal	ra,ffffffffc0201b56 <page_insert>
ffffffffc0202a42:	65a2                	ld	a1,8(sp)
ffffffffc0202a44:	b73d                	j	ffffffffc0202972 <copy_range+0xe6>
ffffffffc0202a46:	b5afe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202a4a:	000d3783          	ld	a5,0(s10)
ffffffffc0202a4e:	4505                	li	a0,1
ffffffffc0202a50:	6f9c                	ld	a5,24(a5)
ffffffffc0202a52:	9782                	jalr	a5
ffffffffc0202a54:	8daa                	mv	s11,a0
ffffffffc0202a56:	b44fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202a5a:	65a2                	ld	a1,8(sp)
ffffffffc0202a5c:	b7bd                	j	ffffffffc02029ca <copy_range+0x13e>
ffffffffc0202a5e:	5571                	li	a0,-4
ffffffffc0202a60:	bd4d                	j	ffffffffc0202912 <copy_range+0x86>
ffffffffc0202a62:	0000a617          	auipc	a2,0xa
ffffffffc0202a66:	9ce60613          	addi	a2,a2,-1586 # ffffffffc020c430 <commands+0x960>
ffffffffc0202a6a:	07f00593          	li	a1,127
ffffffffc0202a6e:	0000a517          	auipc	a0,0xa
ffffffffc0202a72:	9b250513          	addi	a0,a0,-1614 # ffffffffc020c420 <commands+0x950>
ffffffffc0202a76:	fb8fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202a7a:	0000a697          	auipc	a3,0xa
ffffffffc0202a7e:	a4668693          	addi	a3,a3,-1466 # ffffffffc020c4c0 <commands+0x9f0>
ffffffffc0202a82:	00009617          	auipc	a2,0x9
ffffffffc0202a86:	29e60613          	addi	a2,a2,670 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202a8a:	17c00593          	li	a1,380
ffffffffc0202a8e:	0000a517          	auipc	a0,0xa
ffffffffc0202a92:	9f250513          	addi	a0,a0,-1550 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202a96:	f98fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202a9a:	0000a617          	auipc	a2,0xa
ffffffffc0202a9e:	96660613          	addi	a2,a2,-1690 # ffffffffc020c400 <commands+0x930>
ffffffffc0202aa2:	06900593          	li	a1,105
ffffffffc0202aa6:	0000a517          	auipc	a0,0xa
ffffffffc0202aaa:	97a50513          	addi	a0,a0,-1670 # ffffffffc020c420 <commands+0x950>
ffffffffc0202aae:	f80fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202ab2:	0000a697          	auipc	a3,0xa
ffffffffc0202ab6:	fe668693          	addi	a3,a3,-26 # ffffffffc020ca98 <commands+0xfc8>
ffffffffc0202aba:	00009617          	auipc	a2,0x9
ffffffffc0202abe:	26660613          	addi	a2,a2,614 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202ac2:	19c00593          	li	a1,412
ffffffffc0202ac6:	0000a517          	auipc	a0,0xa
ffffffffc0202aca:	9ba50513          	addi	a0,a0,-1606 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202ace:	f60fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202ad2:	0000a697          	auipc	a3,0xa
ffffffffc0202ad6:	9be68693          	addi	a3,a3,-1602 # ffffffffc020c490 <commands+0x9c0>
ffffffffc0202ada:	00009617          	auipc	a2,0x9
ffffffffc0202ade:	24660613          	addi	a2,a2,582 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202ae2:	17b00593          	li	a1,379
ffffffffc0202ae6:	0000a517          	auipc	a0,0xa
ffffffffc0202aea:	99a50513          	addi	a0,a0,-1638 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202aee:	f40fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202af2:	86ba                	mv	a3,a4
ffffffffc0202af4:	0000a617          	auipc	a2,0xa
ffffffffc0202af8:	96460613          	addi	a2,a2,-1692 # ffffffffc020c458 <commands+0x988>
ffffffffc0202afc:	07100593          	li	a1,113
ffffffffc0202b00:	0000a517          	auipc	a0,0xa
ffffffffc0202b04:	92050513          	addi	a0,a0,-1760 # ffffffffc020c420 <commands+0x950>
ffffffffc0202b08:	f26fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202b0c:	86be                	mv	a3,a5
ffffffffc0202b0e:	0000a617          	auipc	a2,0xa
ffffffffc0202b12:	94a60613          	addi	a2,a2,-1718 # ffffffffc020c458 <commands+0x988>
ffffffffc0202b16:	07100593          	li	a1,113
ffffffffc0202b1a:	0000a517          	auipc	a0,0xa
ffffffffc0202b1e:	90650513          	addi	a0,a0,-1786 # ffffffffc020c420 <commands+0x950>
ffffffffc0202b22:	f0cfd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202b26:	0000a697          	auipc	a3,0xa
ffffffffc0202b2a:	f8268693          	addi	a3,a3,-126 # ffffffffc020caa8 <commands+0xfd8>
ffffffffc0202b2e:	00009617          	auipc	a2,0x9
ffffffffc0202b32:	1f260613          	addi	a2,a2,498 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202b36:	19d00593          	li	a1,413
ffffffffc0202b3a:	0000a517          	auipc	a0,0xa
ffffffffc0202b3e:	94650513          	addi	a0,a0,-1722 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202b42:	eecfd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202b46 <tlb_invalidate>:
ffffffffc0202b46:	12058073          	sfence.vma	a1
ffffffffc0202b4a:	8082                	ret

ffffffffc0202b4c <pgdir_alloc_page>:
ffffffffc0202b4c:	7179                	addi	sp,sp,-48
ffffffffc0202b4e:	ec26                	sd	s1,24(sp)
ffffffffc0202b50:	e84a                	sd	s2,16(sp)
ffffffffc0202b52:	e052                	sd	s4,0(sp)
ffffffffc0202b54:	f406                	sd	ra,40(sp)
ffffffffc0202b56:	f022                	sd	s0,32(sp)
ffffffffc0202b58:	e44e                	sd	s3,8(sp)
ffffffffc0202b5a:	8a2a                	mv	s4,a0
ffffffffc0202b5c:	84ae                	mv	s1,a1
ffffffffc0202b5e:	8932                	mv	s2,a2
ffffffffc0202b60:	100027f3          	csrr	a5,sstatus
ffffffffc0202b64:	8b89                	andi	a5,a5,2
ffffffffc0202b66:	00094997          	auipc	s3,0x94
ffffffffc0202b6a:	d8298993          	addi	s3,s3,-638 # ffffffffc02968e8 <pmm_manager>
ffffffffc0202b6e:	ef8d                	bnez	a5,ffffffffc0202ba8 <pgdir_alloc_page+0x5c>
ffffffffc0202b70:	0009b783          	ld	a5,0(s3)
ffffffffc0202b74:	4505                	li	a0,1
ffffffffc0202b76:	6f9c                	ld	a5,24(a5)
ffffffffc0202b78:	9782                	jalr	a5
ffffffffc0202b7a:	842a                	mv	s0,a0
ffffffffc0202b7c:	cc09                	beqz	s0,ffffffffc0202b96 <pgdir_alloc_page+0x4a>
ffffffffc0202b7e:	86ca                	mv	a3,s2
ffffffffc0202b80:	8626                	mv	a2,s1
ffffffffc0202b82:	85a2                	mv	a1,s0
ffffffffc0202b84:	8552                	mv	a0,s4
ffffffffc0202b86:	fd1fe0ef          	jal	ra,ffffffffc0201b56 <page_insert>
ffffffffc0202b8a:	e915                	bnez	a0,ffffffffc0202bbe <pgdir_alloc_page+0x72>
ffffffffc0202b8c:	4018                	lw	a4,0(s0)
ffffffffc0202b8e:	fc04                	sd	s1,56(s0)
ffffffffc0202b90:	4785                	li	a5,1
ffffffffc0202b92:	04f71e63          	bne	a4,a5,ffffffffc0202bee <pgdir_alloc_page+0xa2>
ffffffffc0202b96:	70a2                	ld	ra,40(sp)
ffffffffc0202b98:	8522                	mv	a0,s0
ffffffffc0202b9a:	7402                	ld	s0,32(sp)
ffffffffc0202b9c:	64e2                	ld	s1,24(sp)
ffffffffc0202b9e:	6942                	ld	s2,16(sp)
ffffffffc0202ba0:	69a2                	ld	s3,8(sp)
ffffffffc0202ba2:	6a02                	ld	s4,0(sp)
ffffffffc0202ba4:	6145                	addi	sp,sp,48
ffffffffc0202ba6:	8082                	ret
ffffffffc0202ba8:	9f8fe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202bac:	0009b783          	ld	a5,0(s3)
ffffffffc0202bb0:	4505                	li	a0,1
ffffffffc0202bb2:	6f9c                	ld	a5,24(a5)
ffffffffc0202bb4:	9782                	jalr	a5
ffffffffc0202bb6:	842a                	mv	s0,a0
ffffffffc0202bb8:	9e2fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202bbc:	b7c1                	j	ffffffffc0202b7c <pgdir_alloc_page+0x30>
ffffffffc0202bbe:	100027f3          	csrr	a5,sstatus
ffffffffc0202bc2:	8b89                	andi	a5,a5,2
ffffffffc0202bc4:	eb89                	bnez	a5,ffffffffc0202bd6 <pgdir_alloc_page+0x8a>
ffffffffc0202bc6:	0009b783          	ld	a5,0(s3)
ffffffffc0202bca:	8522                	mv	a0,s0
ffffffffc0202bcc:	4585                	li	a1,1
ffffffffc0202bce:	739c                	ld	a5,32(a5)
ffffffffc0202bd0:	4401                	li	s0,0
ffffffffc0202bd2:	9782                	jalr	a5
ffffffffc0202bd4:	b7c9                	j	ffffffffc0202b96 <pgdir_alloc_page+0x4a>
ffffffffc0202bd6:	9cafe0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0202bda:	0009b783          	ld	a5,0(s3)
ffffffffc0202bde:	8522                	mv	a0,s0
ffffffffc0202be0:	4585                	li	a1,1
ffffffffc0202be2:	739c                	ld	a5,32(a5)
ffffffffc0202be4:	4401                	li	s0,0
ffffffffc0202be6:	9782                	jalr	a5
ffffffffc0202be8:	9b2fe0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0202bec:	b76d                	j	ffffffffc0202b96 <pgdir_alloc_page+0x4a>
ffffffffc0202bee:	0000a697          	auipc	a3,0xa
ffffffffc0202bf2:	eda68693          	addi	a3,a3,-294 # ffffffffc020cac8 <commands+0xff8>
ffffffffc0202bf6:	00009617          	auipc	a2,0x9
ffffffffc0202bfa:	12a60613          	addi	a2,a2,298 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202bfe:	1ec00593          	li	a1,492
ffffffffc0202c02:	0000a517          	auipc	a0,0xa
ffffffffc0202c06:	87e50513          	addi	a0,a0,-1922 # ffffffffc020c480 <commands+0x9b0>
ffffffffc0202c0a:	e24fd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202c0e <check_vma_overlap.part.0>:
ffffffffc0202c0e:	1141                	addi	sp,sp,-16
ffffffffc0202c10:	0000a697          	auipc	a3,0xa
ffffffffc0202c14:	ed068693          	addi	a3,a3,-304 # ffffffffc020cae0 <commands+0x1010>
ffffffffc0202c18:	00009617          	auipc	a2,0x9
ffffffffc0202c1c:	10860613          	addi	a2,a2,264 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202c20:	07500593          	li	a1,117
ffffffffc0202c24:	0000a517          	auipc	a0,0xa
ffffffffc0202c28:	edc50513          	addi	a0,a0,-292 # ffffffffc020cb00 <commands+0x1030>
ffffffffc0202c2c:	e406                	sd	ra,8(sp)
ffffffffc0202c2e:	e00fd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202c32 <mm_create>:
ffffffffc0202c32:	1141                	addi	sp,sp,-16
ffffffffc0202c34:	05800513          	li	a0,88
ffffffffc0202c38:	e022                	sd	s0,0(sp)
ffffffffc0202c3a:	e406                	sd	ra,8(sp)
ffffffffc0202c3c:	495000ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0202c40:	842a                	mv	s0,a0
ffffffffc0202c42:	c115                	beqz	a0,ffffffffc0202c66 <mm_create+0x34>
ffffffffc0202c44:	e408                	sd	a0,8(s0)
ffffffffc0202c46:	e008                	sd	a0,0(s0)
ffffffffc0202c48:	00053823          	sd	zero,16(a0)
ffffffffc0202c4c:	00053c23          	sd	zero,24(a0)
ffffffffc0202c50:	02052023          	sw	zero,32(a0)
ffffffffc0202c54:	02053423          	sd	zero,40(a0)
ffffffffc0202c58:	02052823          	sw	zero,48(a0)
ffffffffc0202c5c:	4585                	li	a1,1
ffffffffc0202c5e:	03850513          	addi	a0,a0,56
ffffffffc0202c62:	3eb010ef          	jal	ra,ffffffffc020484c <sem_init>
ffffffffc0202c66:	60a2                	ld	ra,8(sp)
ffffffffc0202c68:	8522                	mv	a0,s0
ffffffffc0202c6a:	6402                	ld	s0,0(sp)
ffffffffc0202c6c:	0141                	addi	sp,sp,16
ffffffffc0202c6e:	8082                	ret

ffffffffc0202c70 <find_vma>:
ffffffffc0202c70:	86aa                	mv	a3,a0
ffffffffc0202c72:	c505                	beqz	a0,ffffffffc0202c9a <find_vma+0x2a>
ffffffffc0202c74:	6908                	ld	a0,16(a0)
ffffffffc0202c76:	c501                	beqz	a0,ffffffffc0202c7e <find_vma+0xe>
ffffffffc0202c78:	651c                	ld	a5,8(a0)
ffffffffc0202c7a:	02f5f263          	bgeu	a1,a5,ffffffffc0202c9e <find_vma+0x2e>
ffffffffc0202c7e:	669c                	ld	a5,8(a3)
ffffffffc0202c80:	00f68d63          	beq	a3,a5,ffffffffc0202c9a <find_vma+0x2a>
ffffffffc0202c84:	fe87b703          	ld	a4,-24(a5) # 1fffe8 <_binary_bin_sfs_img_size+0x18ace8>
ffffffffc0202c88:	00e5e663          	bltu	a1,a4,ffffffffc0202c94 <find_vma+0x24>
ffffffffc0202c8c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202c90:	00e5ec63          	bltu	a1,a4,ffffffffc0202ca8 <find_vma+0x38>
ffffffffc0202c94:	679c                	ld	a5,8(a5)
ffffffffc0202c96:	fef697e3          	bne	a3,a5,ffffffffc0202c84 <find_vma+0x14>
ffffffffc0202c9a:	4501                	li	a0,0
ffffffffc0202c9c:	8082                	ret
ffffffffc0202c9e:	691c                	ld	a5,16(a0)
ffffffffc0202ca0:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0202c7e <find_vma+0xe>
ffffffffc0202ca4:	ea88                	sd	a0,16(a3)
ffffffffc0202ca6:	8082                	ret
ffffffffc0202ca8:	fe078513          	addi	a0,a5,-32
ffffffffc0202cac:	ea88                	sd	a0,16(a3)
ffffffffc0202cae:	8082                	ret

ffffffffc0202cb0 <insert_vma_struct>:
ffffffffc0202cb0:	6590                	ld	a2,8(a1)
ffffffffc0202cb2:	0105b803          	ld	a6,16(a1)
ffffffffc0202cb6:	1141                	addi	sp,sp,-16
ffffffffc0202cb8:	e406                	sd	ra,8(sp)
ffffffffc0202cba:	87aa                	mv	a5,a0
ffffffffc0202cbc:	01066763          	bltu	a2,a6,ffffffffc0202cca <insert_vma_struct+0x1a>
ffffffffc0202cc0:	a085                	j	ffffffffc0202d20 <insert_vma_struct+0x70>
ffffffffc0202cc2:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202cc6:	04e66863          	bltu	a2,a4,ffffffffc0202d16 <insert_vma_struct+0x66>
ffffffffc0202cca:	86be                	mv	a3,a5
ffffffffc0202ccc:	679c                	ld	a5,8(a5)
ffffffffc0202cce:	fef51ae3          	bne	a0,a5,ffffffffc0202cc2 <insert_vma_struct+0x12>
ffffffffc0202cd2:	02a68463          	beq	a3,a0,ffffffffc0202cfa <insert_vma_struct+0x4a>
ffffffffc0202cd6:	ff06b703          	ld	a4,-16(a3)
ffffffffc0202cda:	fe86b883          	ld	a7,-24(a3)
ffffffffc0202cde:	08e8f163          	bgeu	a7,a4,ffffffffc0202d60 <insert_vma_struct+0xb0>
ffffffffc0202ce2:	04e66f63          	bltu	a2,a4,ffffffffc0202d40 <insert_vma_struct+0x90>
ffffffffc0202ce6:	00f50a63          	beq	a0,a5,ffffffffc0202cfa <insert_vma_struct+0x4a>
ffffffffc0202cea:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202cee:	05076963          	bltu	a4,a6,ffffffffc0202d40 <insert_vma_struct+0x90>
ffffffffc0202cf2:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202cf6:	02c77363          	bgeu	a4,a2,ffffffffc0202d1c <insert_vma_struct+0x6c>
ffffffffc0202cfa:	5118                	lw	a4,32(a0)
ffffffffc0202cfc:	e188                	sd	a0,0(a1)
ffffffffc0202cfe:	02058613          	addi	a2,a1,32
ffffffffc0202d02:	e390                	sd	a2,0(a5)
ffffffffc0202d04:	e690                	sd	a2,8(a3)
ffffffffc0202d06:	60a2                	ld	ra,8(sp)
ffffffffc0202d08:	f59c                	sd	a5,40(a1)
ffffffffc0202d0a:	f194                	sd	a3,32(a1)
ffffffffc0202d0c:	0017079b          	addiw	a5,a4,1
ffffffffc0202d10:	d11c                	sw	a5,32(a0)
ffffffffc0202d12:	0141                	addi	sp,sp,16
ffffffffc0202d14:	8082                	ret
ffffffffc0202d16:	fca690e3          	bne	a3,a0,ffffffffc0202cd6 <insert_vma_struct+0x26>
ffffffffc0202d1a:	bfd1                	j	ffffffffc0202cee <insert_vma_struct+0x3e>
ffffffffc0202d1c:	ef3ff0ef          	jal	ra,ffffffffc0202c0e <check_vma_overlap.part.0>
ffffffffc0202d20:	0000a697          	auipc	a3,0xa
ffffffffc0202d24:	df068693          	addi	a3,a3,-528 # ffffffffc020cb10 <commands+0x1040>
ffffffffc0202d28:	00009617          	auipc	a2,0x9
ffffffffc0202d2c:	ff860613          	addi	a2,a2,-8 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202d30:	07b00593          	li	a1,123
ffffffffc0202d34:	0000a517          	auipc	a0,0xa
ffffffffc0202d38:	dcc50513          	addi	a0,a0,-564 # ffffffffc020cb00 <commands+0x1030>
ffffffffc0202d3c:	cf2fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202d40:	0000a697          	auipc	a3,0xa
ffffffffc0202d44:	e1068693          	addi	a3,a3,-496 # ffffffffc020cb50 <commands+0x1080>
ffffffffc0202d48:	00009617          	auipc	a2,0x9
ffffffffc0202d4c:	fd860613          	addi	a2,a2,-40 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202d50:	07400593          	li	a1,116
ffffffffc0202d54:	0000a517          	auipc	a0,0xa
ffffffffc0202d58:	dac50513          	addi	a0,a0,-596 # ffffffffc020cb00 <commands+0x1030>
ffffffffc0202d5c:	cd2fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0202d60:	0000a697          	auipc	a3,0xa
ffffffffc0202d64:	dd068693          	addi	a3,a3,-560 # ffffffffc020cb30 <commands+0x1060>
ffffffffc0202d68:	00009617          	auipc	a2,0x9
ffffffffc0202d6c:	fb860613          	addi	a2,a2,-72 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202d70:	07300593          	li	a1,115
ffffffffc0202d74:	0000a517          	auipc	a0,0xa
ffffffffc0202d78:	d8c50513          	addi	a0,a0,-628 # ffffffffc020cb00 <commands+0x1030>
ffffffffc0202d7c:	cb2fd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202d80 <mm_destroy>:
ffffffffc0202d80:	591c                	lw	a5,48(a0)
ffffffffc0202d82:	1141                	addi	sp,sp,-16
ffffffffc0202d84:	e406                	sd	ra,8(sp)
ffffffffc0202d86:	e022                	sd	s0,0(sp)
ffffffffc0202d88:	e78d                	bnez	a5,ffffffffc0202db2 <mm_destroy+0x32>
ffffffffc0202d8a:	842a                	mv	s0,a0
ffffffffc0202d8c:	6508                	ld	a0,8(a0)
ffffffffc0202d8e:	00a40c63          	beq	s0,a0,ffffffffc0202da6 <mm_destroy+0x26>
ffffffffc0202d92:	6118                	ld	a4,0(a0)
ffffffffc0202d94:	651c                	ld	a5,8(a0)
ffffffffc0202d96:	1501                	addi	a0,a0,-32
ffffffffc0202d98:	e71c                	sd	a5,8(a4)
ffffffffc0202d9a:	e398                	sd	a4,0(a5)
ffffffffc0202d9c:	3e5000ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0202da0:	6408                	ld	a0,8(s0)
ffffffffc0202da2:	fea418e3          	bne	s0,a0,ffffffffc0202d92 <mm_destroy+0x12>
ffffffffc0202da6:	8522                	mv	a0,s0
ffffffffc0202da8:	6402                	ld	s0,0(sp)
ffffffffc0202daa:	60a2                	ld	ra,8(sp)
ffffffffc0202dac:	0141                	addi	sp,sp,16
ffffffffc0202dae:	3d30006f          	j	ffffffffc0203980 <kfree>
ffffffffc0202db2:	0000a697          	auipc	a3,0xa
ffffffffc0202db6:	dbe68693          	addi	a3,a3,-578 # ffffffffc020cb70 <commands+0x10a0>
ffffffffc0202dba:	00009617          	auipc	a2,0x9
ffffffffc0202dbe:	f6660613          	addi	a2,a2,-154 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202dc2:	09f00593          	li	a1,159
ffffffffc0202dc6:	0000a517          	auipc	a0,0xa
ffffffffc0202dca:	d3a50513          	addi	a0,a0,-710 # ffffffffc020cb00 <commands+0x1030>
ffffffffc0202dce:	c60fd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202dd2 <mm_map>:
ffffffffc0202dd2:	7139                	addi	sp,sp,-64
ffffffffc0202dd4:	f822                	sd	s0,48(sp)
ffffffffc0202dd6:	6405                	lui	s0,0x1
ffffffffc0202dd8:	147d                	addi	s0,s0,-1
ffffffffc0202dda:	77fd                	lui	a5,0xfffff
ffffffffc0202ddc:	9622                	add	a2,a2,s0
ffffffffc0202dde:	962e                	add	a2,a2,a1
ffffffffc0202de0:	f426                	sd	s1,40(sp)
ffffffffc0202de2:	fc06                	sd	ra,56(sp)
ffffffffc0202de4:	00f5f4b3          	and	s1,a1,a5
ffffffffc0202de8:	f04a                	sd	s2,32(sp)
ffffffffc0202dea:	ec4e                	sd	s3,24(sp)
ffffffffc0202dec:	e852                	sd	s4,16(sp)
ffffffffc0202dee:	e456                	sd	s5,8(sp)
ffffffffc0202df0:	002005b7          	lui	a1,0x200
ffffffffc0202df4:	00f67433          	and	s0,a2,a5
ffffffffc0202df8:	06b4e363          	bltu	s1,a1,ffffffffc0202e5e <mm_map+0x8c>
ffffffffc0202dfc:	0684f163          	bgeu	s1,s0,ffffffffc0202e5e <mm_map+0x8c>
ffffffffc0202e00:	4785                	li	a5,1
ffffffffc0202e02:	07fe                	slli	a5,a5,0x1f
ffffffffc0202e04:	0487ed63          	bltu	a5,s0,ffffffffc0202e5e <mm_map+0x8c>
ffffffffc0202e08:	89aa                	mv	s3,a0
ffffffffc0202e0a:	cd21                	beqz	a0,ffffffffc0202e62 <mm_map+0x90>
ffffffffc0202e0c:	85a6                	mv	a1,s1
ffffffffc0202e0e:	8ab6                	mv	s5,a3
ffffffffc0202e10:	8a3a                	mv	s4,a4
ffffffffc0202e12:	e5fff0ef          	jal	ra,ffffffffc0202c70 <find_vma>
ffffffffc0202e16:	c501                	beqz	a0,ffffffffc0202e1e <mm_map+0x4c>
ffffffffc0202e18:	651c                	ld	a5,8(a0)
ffffffffc0202e1a:	0487e263          	bltu	a5,s0,ffffffffc0202e5e <mm_map+0x8c>
ffffffffc0202e1e:	03000513          	li	a0,48
ffffffffc0202e22:	2af000ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0202e26:	892a                	mv	s2,a0
ffffffffc0202e28:	5571                	li	a0,-4
ffffffffc0202e2a:	02090163          	beqz	s2,ffffffffc0202e4c <mm_map+0x7a>
ffffffffc0202e2e:	854e                	mv	a0,s3
ffffffffc0202e30:	00993423          	sd	s1,8(s2)
ffffffffc0202e34:	00893823          	sd	s0,16(s2)
ffffffffc0202e38:	01592c23          	sw	s5,24(s2)
ffffffffc0202e3c:	85ca                	mv	a1,s2
ffffffffc0202e3e:	e73ff0ef          	jal	ra,ffffffffc0202cb0 <insert_vma_struct>
ffffffffc0202e42:	4501                	li	a0,0
ffffffffc0202e44:	000a0463          	beqz	s4,ffffffffc0202e4c <mm_map+0x7a>
ffffffffc0202e48:	012a3023          	sd	s2,0(s4)
ffffffffc0202e4c:	70e2                	ld	ra,56(sp)
ffffffffc0202e4e:	7442                	ld	s0,48(sp)
ffffffffc0202e50:	74a2                	ld	s1,40(sp)
ffffffffc0202e52:	7902                	ld	s2,32(sp)
ffffffffc0202e54:	69e2                	ld	s3,24(sp)
ffffffffc0202e56:	6a42                	ld	s4,16(sp)
ffffffffc0202e58:	6aa2                	ld	s5,8(sp)
ffffffffc0202e5a:	6121                	addi	sp,sp,64
ffffffffc0202e5c:	8082                	ret
ffffffffc0202e5e:	5575                	li	a0,-3
ffffffffc0202e60:	b7f5                	j	ffffffffc0202e4c <mm_map+0x7a>
ffffffffc0202e62:	0000a697          	auipc	a3,0xa
ffffffffc0202e66:	d2668693          	addi	a3,a3,-730 # ffffffffc020cb88 <commands+0x10b8>
ffffffffc0202e6a:	00009617          	auipc	a2,0x9
ffffffffc0202e6e:	eb660613          	addi	a2,a2,-330 # ffffffffc020bd20 <commands+0x250>
ffffffffc0202e72:	0b400593          	li	a1,180
ffffffffc0202e76:	0000a517          	auipc	a0,0xa
ffffffffc0202e7a:	c8a50513          	addi	a0,a0,-886 # ffffffffc020cb00 <commands+0x1030>
ffffffffc0202e7e:	bb0fd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0202e82 <do_pgfault>:
ffffffffc0202e82:	715d                	addi	sp,sp,-80
ffffffffc0202e84:	e0a2                	sd	s0,64(sp)
ffffffffc0202e86:	842e                	mv	s0,a1
ffffffffc0202e88:	85b2                	mv	a1,a2
ffffffffc0202e8a:	fc26                	sd	s1,56(sp)
ffffffffc0202e8c:	f84a                	sd	s2,48(sp)
ffffffffc0202e8e:	e486                	sd	ra,72(sp)
ffffffffc0202e90:	f44e                	sd	s3,40(sp)
ffffffffc0202e92:	f052                	sd	s4,32(sp)
ffffffffc0202e94:	ec56                	sd	s5,24(sp)
ffffffffc0202e96:	e85a                	sd	s6,16(sp)
ffffffffc0202e98:	e45e                	sd	s7,8(sp)
ffffffffc0202e9a:	84b2                	mv	s1,a2
ffffffffc0202e9c:	892a                	mv	s2,a0
ffffffffc0202e9e:	dd3ff0ef          	jal	ra,ffffffffc0202c70 <find_vma>
ffffffffc0202ea2:	00094797          	auipc	a5,0x94
ffffffffc0202ea6:	a567a783          	lw	a5,-1450(a5) # ffffffffc02968f8 <pgfault_num>
ffffffffc0202eaa:	2785                	addiw	a5,a5,1
ffffffffc0202eac:	00094717          	auipc	a4,0x94
ffffffffc0202eb0:	a4f72623          	sw	a5,-1460(a4) # ffffffffc02968f8 <pgfault_num>
ffffffffc0202eb4:	16050b63          	beqz	a0,ffffffffc020302a <do_pgfault+0x1a8>
ffffffffc0202eb8:	651c                	ld	a5,8(a0)
ffffffffc0202eba:	16f4e863          	bltu	s1,a5,ffffffffc020302a <do_pgfault+0x1a8>
ffffffffc0202ebe:	00347593          	andi	a1,s0,3
ffffffffc0202ec2:	10058863          	beqz	a1,ffffffffc0202fd2 <do_pgfault+0x150>
ffffffffc0202ec6:	4785                	li	a5,1
ffffffffc0202ec8:	0ef58363          	beq	a1,a5,ffffffffc0202fae <do_pgfault+0x12c>
ffffffffc0202ecc:	4d1c                	lw	a5,24(a0)
ffffffffc0202ece:	49d9                	li	s3,22
ffffffffc0202ed0:	0027f713          	andi	a4,a5,2
ffffffffc0202ed4:	18070663          	beqz	a4,ffffffffc0203060 <do_pgfault+0x1de>
ffffffffc0202ed8:	0017f713          	andi	a4,a5,1
ffffffffc0202edc:	c319                	beqz	a4,ffffffffc0202ee2 <do_pgfault+0x60>
ffffffffc0202ede:	0029e993          	ori	s3,s3,2
ffffffffc0202ee2:	8b91                	andi	a5,a5,4
ffffffffc0202ee4:	c399                	beqz	a5,ffffffffc0202eea <do_pgfault+0x68>
ffffffffc0202ee6:	0089e993          	ori	s3,s3,8
ffffffffc0202eea:	767d                	lui	a2,0xfffff
ffffffffc0202eec:	01893503          	ld	a0,24(s2)
ffffffffc0202ef0:	8cf1                	and	s1,s1,a2
ffffffffc0202ef2:	85a6                	mv	a1,s1
ffffffffc0202ef4:	4605                	li	a2,1
ffffffffc0202ef6:	d70fe0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc0202efa:	872a                	mv	a4,a0
ffffffffc0202efc:	16050a63          	beqz	a0,ffffffffc0203070 <do_pgfault+0x1ee>
ffffffffc0202f00:	610c                	ld	a1,0(a0)
ffffffffc0202f02:	c1fd                	beqz	a1,ffffffffc0202fe8 <do_pgfault+0x166>
ffffffffc0202f04:	1005f793          	andi	a5,a1,256
ffffffffc0202f08:	12078a63          	beqz	a5,ffffffffc020303c <do_pgfault+0x1ba>
ffffffffc0202f0c:	0015f793          	andi	a5,a1,1
ffffffffc0202f10:	16078863          	beqz	a5,ffffffffc0203080 <do_pgfault+0x1fe>
ffffffffc0202f14:	00094b17          	auipc	s6,0x94
ffffffffc0202f18:	9c4b0b13          	addi	s6,s6,-1596 # ffffffffc02968d8 <npage>
ffffffffc0202f1c:	000b3683          	ld	a3,0(s6)
ffffffffc0202f20:	00259793          	slli	a5,a1,0x2
ffffffffc0202f24:	83b1                	srli	a5,a5,0xc
ffffffffc0202f26:	16d7f963          	bgeu	a5,a3,ffffffffc0203098 <do_pgfault+0x216>
ffffffffc0202f2a:	00094b97          	auipc	s7,0x94
ffffffffc0202f2e:	9b6b8b93          	addi	s7,s7,-1610 # ffffffffc02968e0 <pages>
ffffffffc0202f32:	000bb403          	ld	s0,0(s7)
ffffffffc0202f36:	0000da97          	auipc	s5,0xd
ffffffffc0202f3a:	c92aba83          	ld	s5,-878(s5) # ffffffffc020fbc8 <nbase>
ffffffffc0202f3e:	415787b3          	sub	a5,a5,s5
ffffffffc0202f42:	079a                	slli	a5,a5,0x6
ffffffffc0202f44:	943e                	add	s0,s0,a5
ffffffffc0202f46:	4014                	lw	a3,0(s0)
ffffffffc0202f48:	4785                	li	a5,1
ffffffffc0202f4a:	0ad7de63          	bge	a5,a3,ffffffffc0203006 <do_pgfault+0x184>
ffffffffc0202f4e:	4505                	li	a0,1
ffffffffc0202f50:	c5efe0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0202f54:	8a2a                	mv	s4,a0
ffffffffc0202f56:	0e050b63          	beqz	a0,ffffffffc020304c <do_pgfault+0x1ca>
ffffffffc0202f5a:	000bb603          	ld	a2,0(s7)
ffffffffc0202f5e:	577d                	li	a4,-1
ffffffffc0202f60:	000b3683          	ld	a3,0(s6)
ffffffffc0202f64:	40c507b3          	sub	a5,a0,a2
ffffffffc0202f68:	8799                	srai	a5,a5,0x6
ffffffffc0202f6a:	97d6                	add	a5,a5,s5
ffffffffc0202f6c:	8331                	srli	a4,a4,0xc
ffffffffc0202f6e:	00e7f5b3          	and	a1,a5,a4
ffffffffc0202f72:	07b2                	slli	a5,a5,0xc
ffffffffc0202f74:	14d5fb63          	bgeu	a1,a3,ffffffffc02030ca <do_pgfault+0x248>
ffffffffc0202f78:	8c11                	sub	s0,s0,a2
ffffffffc0202f7a:	8419                	srai	s0,s0,0x6
ffffffffc0202f7c:	9456                	add	s0,s0,s5
ffffffffc0202f7e:	00094597          	auipc	a1,0x94
ffffffffc0202f82:	9725b583          	ld	a1,-1678(a1) # ffffffffc02968f0 <va_pa_offset>
ffffffffc0202f86:	8f61                	and	a4,a4,s0
ffffffffc0202f88:	00b78533          	add	a0,a5,a1
ffffffffc0202f8c:	0432                	slli	s0,s0,0xc
ffffffffc0202f8e:	12d77163          	bgeu	a4,a3,ffffffffc02030b0 <do_pgfault+0x22e>
ffffffffc0202f92:	6605                	lui	a2,0x1
ffffffffc0202f94:	95a2                	add	a1,a1,s0
ffffffffc0202f96:	3e8080ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc0202f9a:	01893503          	ld	a0,24(s2)
ffffffffc0202f9e:	86ce                	mv	a3,s3
ffffffffc0202fa0:	8626                	mv	a2,s1
ffffffffc0202fa2:	85d2                	mv	a1,s4
ffffffffc0202fa4:	bb3fe0ef          	jal	ra,ffffffffc0201b56 <page_insert>
ffffffffc0202fa8:	e93d                	bnez	a0,ffffffffc020301e <do_pgfault+0x19c>
ffffffffc0202faa:	4501                	li	a0,0
ffffffffc0202fac:	a801                	j	ffffffffc0202fbc <do_pgfault+0x13a>
ffffffffc0202fae:	0000a517          	auipc	a0,0xa
ffffffffc0202fb2:	c7a50513          	addi	a0,a0,-902 # ffffffffc020cc28 <commands+0x1158>
ffffffffc0202fb6:	974fd0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0202fba:	5575                	li	a0,-3
ffffffffc0202fbc:	60a6                	ld	ra,72(sp)
ffffffffc0202fbe:	6406                	ld	s0,64(sp)
ffffffffc0202fc0:	74e2                	ld	s1,56(sp)
ffffffffc0202fc2:	7942                	ld	s2,48(sp)
ffffffffc0202fc4:	79a2                	ld	s3,40(sp)
ffffffffc0202fc6:	7a02                	ld	s4,32(sp)
ffffffffc0202fc8:	6ae2                	ld	s5,24(sp)
ffffffffc0202fca:	6b42                	ld	s6,16(sp)
ffffffffc0202fcc:	6ba2                	ld	s7,8(sp)
ffffffffc0202fce:	6161                	addi	sp,sp,80
ffffffffc0202fd0:	8082                	ret
ffffffffc0202fd2:	4d1c                	lw	a5,24(a0)
ffffffffc0202fd4:	0057f713          	andi	a4,a5,5
ffffffffc0202fd8:	cf25                	beqz	a4,ffffffffc0203050 <do_pgfault+0x1ce>
ffffffffc0202fda:	0027f713          	andi	a4,a5,2
ffffffffc0202fde:	49c1                	li	s3,16
ffffffffc0202fe0:	ee070ce3          	beqz	a4,ffffffffc0202ed8 <do_pgfault+0x56>
ffffffffc0202fe4:	49d9                	li	s3,22
ffffffffc0202fe6:	bdcd                	j	ffffffffc0202ed8 <do_pgfault+0x56>
ffffffffc0202fe8:	01893503          	ld	a0,24(s2)
ffffffffc0202fec:	864e                	mv	a2,s3
ffffffffc0202fee:	85a6                	mv	a1,s1
ffffffffc0202ff0:	b5dff0ef          	jal	ra,ffffffffc0202b4c <pgdir_alloc_page>
ffffffffc0202ff4:	f95d                	bnez	a0,ffffffffc0202faa <do_pgfault+0x128>
ffffffffc0202ff6:	0000a517          	auipc	a0,0xa
ffffffffc0202ffa:	cf250513          	addi	a0,a0,-782 # ffffffffc020cce8 <commands+0x1218>
ffffffffc0202ffe:	92cfd0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0203002:	5571                	li	a0,-4
ffffffffc0203004:	bf65                	j	ffffffffc0202fbc <do_pgfault+0x13a>
ffffffffc0203006:	01893503          	ld	a0,24(s2)
ffffffffc020300a:	eff5f593          	andi	a1,a1,-257
ffffffffc020300e:	0045e593          	ori	a1,a1,4
ffffffffc0203012:	e30c                	sd	a1,0(a4)
ffffffffc0203014:	85a6                	mv	a1,s1
ffffffffc0203016:	b31ff0ef          	jal	ra,ffffffffc0202b46 <tlb_invalidate>
ffffffffc020301a:	4501                	li	a0,0
ffffffffc020301c:	b745                	j	ffffffffc0202fbc <do_pgfault+0x13a>
ffffffffc020301e:	8552                	mv	a0,s4
ffffffffc0203020:	4585                	li	a1,1
ffffffffc0203022:	bcafe0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203026:	5571                	li	a0,-4
ffffffffc0203028:	bf51                	j	ffffffffc0202fbc <do_pgfault+0x13a>
ffffffffc020302a:	85a6                	mv	a1,s1
ffffffffc020302c:	0000a517          	auipc	a0,0xa
ffffffffc0203030:	b6c50513          	addi	a0,a0,-1172 # ffffffffc020cb98 <commands+0x10c8>
ffffffffc0203034:	8f6fd0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0203038:	5575                	li	a0,-3
ffffffffc020303a:	b749                	j	ffffffffc0202fbc <do_pgfault+0x13a>
ffffffffc020303c:	0000a517          	auipc	a0,0xa
ffffffffc0203040:	cd450513          	addi	a0,a0,-812 # ffffffffc020cd10 <commands+0x1240>
ffffffffc0203044:	8e6fd0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0203048:	5571                	li	a0,-4
ffffffffc020304a:	bf8d                	j	ffffffffc0202fbc <do_pgfault+0x13a>
ffffffffc020304c:	5571                	li	a0,-4
ffffffffc020304e:	b7bd                	j	ffffffffc0202fbc <do_pgfault+0x13a>
ffffffffc0203050:	0000a517          	auipc	a0,0xa
ffffffffc0203054:	c1050513          	addi	a0,a0,-1008 # ffffffffc020cc60 <commands+0x1190>
ffffffffc0203058:	8d2fd0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020305c:	5575                	li	a0,-3
ffffffffc020305e:	bfb9                	j	ffffffffc0202fbc <do_pgfault+0x13a>
ffffffffc0203060:	0000a517          	auipc	a0,0xa
ffffffffc0203064:	b6850513          	addi	a0,a0,-1176 # ffffffffc020cbc8 <commands+0x10f8>
ffffffffc0203068:	8c2fd0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020306c:	5575                	li	a0,-3
ffffffffc020306e:	b7b9                	j	ffffffffc0202fbc <do_pgfault+0x13a>
ffffffffc0203070:	0000a517          	auipc	a0,0xa
ffffffffc0203074:	c5850513          	addi	a0,a0,-936 # ffffffffc020ccc8 <commands+0x11f8>
ffffffffc0203078:	8b2fd0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020307c:	5571                	li	a0,-4
ffffffffc020307e:	bf3d                	j	ffffffffc0202fbc <do_pgfault+0x13a>
ffffffffc0203080:	00009617          	auipc	a2,0x9
ffffffffc0203084:	3b060613          	addi	a2,a2,944 # ffffffffc020c430 <commands+0x960>
ffffffffc0203088:	07f00593          	li	a1,127
ffffffffc020308c:	00009517          	auipc	a0,0x9
ffffffffc0203090:	39450513          	addi	a0,a0,916 # ffffffffc020c420 <commands+0x950>
ffffffffc0203094:	99afd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203098:	00009617          	auipc	a2,0x9
ffffffffc020309c:	36860613          	addi	a2,a2,872 # ffffffffc020c400 <commands+0x930>
ffffffffc02030a0:	06900593          	li	a1,105
ffffffffc02030a4:	00009517          	auipc	a0,0x9
ffffffffc02030a8:	37c50513          	addi	a0,a0,892 # ffffffffc020c420 <commands+0x950>
ffffffffc02030ac:	982fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02030b0:	86a2                	mv	a3,s0
ffffffffc02030b2:	00009617          	auipc	a2,0x9
ffffffffc02030b6:	3a660613          	addi	a2,a2,934 # ffffffffc020c458 <commands+0x988>
ffffffffc02030ba:	07100593          	li	a1,113
ffffffffc02030be:	00009517          	auipc	a0,0x9
ffffffffc02030c2:	36250513          	addi	a0,a0,866 # ffffffffc020c420 <commands+0x950>
ffffffffc02030c6:	968fd0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02030ca:	86be                	mv	a3,a5
ffffffffc02030cc:	00009617          	auipc	a2,0x9
ffffffffc02030d0:	38c60613          	addi	a2,a2,908 # ffffffffc020c458 <commands+0x988>
ffffffffc02030d4:	07100593          	li	a1,113
ffffffffc02030d8:	00009517          	auipc	a0,0x9
ffffffffc02030dc:	34850513          	addi	a0,a0,840 # ffffffffc020c420 <commands+0x950>
ffffffffc02030e0:	94efd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02030e4 <dup_mmap>:
ffffffffc02030e4:	7139                	addi	sp,sp,-64
ffffffffc02030e6:	fc06                	sd	ra,56(sp)
ffffffffc02030e8:	f822                	sd	s0,48(sp)
ffffffffc02030ea:	f426                	sd	s1,40(sp)
ffffffffc02030ec:	f04a                	sd	s2,32(sp)
ffffffffc02030ee:	ec4e                	sd	s3,24(sp)
ffffffffc02030f0:	e852                	sd	s4,16(sp)
ffffffffc02030f2:	e456                	sd	s5,8(sp)
ffffffffc02030f4:	c52d                	beqz	a0,ffffffffc020315e <dup_mmap+0x7a>
ffffffffc02030f6:	892a                	mv	s2,a0
ffffffffc02030f8:	84ae                	mv	s1,a1
ffffffffc02030fa:	842e                	mv	s0,a1
ffffffffc02030fc:	e595                	bnez	a1,ffffffffc0203128 <dup_mmap+0x44>
ffffffffc02030fe:	a085                	j	ffffffffc020315e <dup_mmap+0x7a>
ffffffffc0203100:	854a                	mv	a0,s2
ffffffffc0203102:	0155b423          	sd	s5,8(a1)
ffffffffc0203106:	0145b823          	sd	s4,16(a1)
ffffffffc020310a:	0135ac23          	sw	s3,24(a1)
ffffffffc020310e:	ba3ff0ef          	jal	ra,ffffffffc0202cb0 <insert_vma_struct>
ffffffffc0203112:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_bin_swap_img_size-0x6d10>
ffffffffc0203116:	fe843603          	ld	a2,-24(s0)
ffffffffc020311a:	6c8c                	ld	a1,24(s1)
ffffffffc020311c:	01893503          	ld	a0,24(s2)
ffffffffc0203120:	4701                	li	a4,0
ffffffffc0203122:	f6aff0ef          	jal	ra,ffffffffc020288c <copy_range>
ffffffffc0203126:	e105                	bnez	a0,ffffffffc0203146 <dup_mmap+0x62>
ffffffffc0203128:	6000                	ld	s0,0(s0)
ffffffffc020312a:	02848863          	beq	s1,s0,ffffffffc020315a <dup_mmap+0x76>
ffffffffc020312e:	03000513          	li	a0,48
ffffffffc0203132:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203136:	ff043a03          	ld	s4,-16(s0)
ffffffffc020313a:	ff842983          	lw	s3,-8(s0)
ffffffffc020313e:	792000ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0203142:	85aa                	mv	a1,a0
ffffffffc0203144:	fd55                	bnez	a0,ffffffffc0203100 <dup_mmap+0x1c>
ffffffffc0203146:	5571                	li	a0,-4
ffffffffc0203148:	70e2                	ld	ra,56(sp)
ffffffffc020314a:	7442                	ld	s0,48(sp)
ffffffffc020314c:	74a2                	ld	s1,40(sp)
ffffffffc020314e:	7902                	ld	s2,32(sp)
ffffffffc0203150:	69e2                	ld	s3,24(sp)
ffffffffc0203152:	6a42                	ld	s4,16(sp)
ffffffffc0203154:	6aa2                	ld	s5,8(sp)
ffffffffc0203156:	6121                	addi	sp,sp,64
ffffffffc0203158:	8082                	ret
ffffffffc020315a:	4501                	li	a0,0
ffffffffc020315c:	b7f5                	j	ffffffffc0203148 <dup_mmap+0x64>
ffffffffc020315e:	0000a697          	auipc	a3,0xa
ffffffffc0203162:	be268693          	addi	a3,a3,-1054 # ffffffffc020cd40 <commands+0x1270>
ffffffffc0203166:	00009617          	auipc	a2,0x9
ffffffffc020316a:	bba60613          	addi	a2,a2,-1094 # ffffffffc020bd20 <commands+0x250>
ffffffffc020316e:	12200593          	li	a1,290
ffffffffc0203172:	0000a517          	auipc	a0,0xa
ffffffffc0203176:	98e50513          	addi	a0,a0,-1650 # ffffffffc020cb00 <commands+0x1030>
ffffffffc020317a:	8b4fd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020317e <exit_mmap>:
ffffffffc020317e:	1101                	addi	sp,sp,-32
ffffffffc0203180:	ec06                	sd	ra,24(sp)
ffffffffc0203182:	e822                	sd	s0,16(sp)
ffffffffc0203184:	e426                	sd	s1,8(sp)
ffffffffc0203186:	e04a                	sd	s2,0(sp)
ffffffffc0203188:	c531                	beqz	a0,ffffffffc02031d4 <exit_mmap+0x56>
ffffffffc020318a:	591c                	lw	a5,48(a0)
ffffffffc020318c:	84aa                	mv	s1,a0
ffffffffc020318e:	e3b9                	bnez	a5,ffffffffc02031d4 <exit_mmap+0x56>
ffffffffc0203190:	6500                	ld	s0,8(a0)
ffffffffc0203192:	01853903          	ld	s2,24(a0)
ffffffffc0203196:	02850663          	beq	a0,s0,ffffffffc02031c2 <exit_mmap+0x44>
ffffffffc020319a:	ff043603          	ld	a2,-16(s0)
ffffffffc020319e:	fe843583          	ld	a1,-24(s0)
ffffffffc02031a2:	854a                	mv	a0,s2
ffffffffc02031a4:	d3efe0ef          	jal	ra,ffffffffc02016e2 <unmap_range>
ffffffffc02031a8:	6400                	ld	s0,8(s0)
ffffffffc02031aa:	fe8498e3          	bne	s1,s0,ffffffffc020319a <exit_mmap+0x1c>
ffffffffc02031ae:	6400                	ld	s0,8(s0)
ffffffffc02031b0:	00848c63          	beq	s1,s0,ffffffffc02031c8 <exit_mmap+0x4a>
ffffffffc02031b4:	ff043603          	ld	a2,-16(s0)
ffffffffc02031b8:	fe843583          	ld	a1,-24(s0)
ffffffffc02031bc:	854a                	mv	a0,s2
ffffffffc02031be:	e6afe0ef          	jal	ra,ffffffffc0201828 <exit_range>
ffffffffc02031c2:	6400                	ld	s0,8(s0)
ffffffffc02031c4:	fe8498e3          	bne	s1,s0,ffffffffc02031b4 <exit_mmap+0x36>
ffffffffc02031c8:	60e2                	ld	ra,24(sp)
ffffffffc02031ca:	6442                	ld	s0,16(sp)
ffffffffc02031cc:	64a2                	ld	s1,8(sp)
ffffffffc02031ce:	6902                	ld	s2,0(sp)
ffffffffc02031d0:	6105                	addi	sp,sp,32
ffffffffc02031d2:	8082                	ret
ffffffffc02031d4:	0000a697          	auipc	a3,0xa
ffffffffc02031d8:	b8c68693          	addi	a3,a3,-1140 # ffffffffc020cd60 <commands+0x1290>
ffffffffc02031dc:	00009617          	auipc	a2,0x9
ffffffffc02031e0:	b4460613          	addi	a2,a2,-1212 # ffffffffc020bd20 <commands+0x250>
ffffffffc02031e4:	13b00593          	li	a1,315
ffffffffc02031e8:	0000a517          	auipc	a0,0xa
ffffffffc02031ec:	91850513          	addi	a0,a0,-1768 # ffffffffc020cb00 <commands+0x1030>
ffffffffc02031f0:	83efd0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02031f4 <vmm_init>:
ffffffffc02031f4:	7139                	addi	sp,sp,-64
ffffffffc02031f6:	05800513          	li	a0,88
ffffffffc02031fa:	fc06                	sd	ra,56(sp)
ffffffffc02031fc:	f822                	sd	s0,48(sp)
ffffffffc02031fe:	f426                	sd	s1,40(sp)
ffffffffc0203200:	f04a                	sd	s2,32(sp)
ffffffffc0203202:	ec4e                	sd	s3,24(sp)
ffffffffc0203204:	e852                	sd	s4,16(sp)
ffffffffc0203206:	e456                	sd	s5,8(sp)
ffffffffc0203208:	6c8000ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc020320c:	2e050963          	beqz	a0,ffffffffc02034fe <vmm_init+0x30a>
ffffffffc0203210:	e508                	sd	a0,8(a0)
ffffffffc0203212:	e108                	sd	a0,0(a0)
ffffffffc0203214:	00053823          	sd	zero,16(a0)
ffffffffc0203218:	00053c23          	sd	zero,24(a0)
ffffffffc020321c:	02052023          	sw	zero,32(a0)
ffffffffc0203220:	02053423          	sd	zero,40(a0)
ffffffffc0203224:	02052823          	sw	zero,48(a0)
ffffffffc0203228:	84aa                	mv	s1,a0
ffffffffc020322a:	4585                	li	a1,1
ffffffffc020322c:	03850513          	addi	a0,a0,56
ffffffffc0203230:	61c010ef          	jal	ra,ffffffffc020484c <sem_init>
ffffffffc0203234:	03200413          	li	s0,50
ffffffffc0203238:	a811                	j	ffffffffc020324c <vmm_init+0x58>
ffffffffc020323a:	e500                	sd	s0,8(a0)
ffffffffc020323c:	e91c                	sd	a5,16(a0)
ffffffffc020323e:	00052c23          	sw	zero,24(a0)
ffffffffc0203242:	146d                	addi	s0,s0,-5
ffffffffc0203244:	8526                	mv	a0,s1
ffffffffc0203246:	a6bff0ef          	jal	ra,ffffffffc0202cb0 <insert_vma_struct>
ffffffffc020324a:	c80d                	beqz	s0,ffffffffc020327c <vmm_init+0x88>
ffffffffc020324c:	03000513          	li	a0,48
ffffffffc0203250:	680000ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0203254:	85aa                	mv	a1,a0
ffffffffc0203256:	00240793          	addi	a5,s0,2
ffffffffc020325a:	f165                	bnez	a0,ffffffffc020323a <vmm_init+0x46>
ffffffffc020325c:	0000a697          	auipc	a3,0xa
ffffffffc0203260:	c9c68693          	addi	a3,a3,-868 # ffffffffc020cef8 <commands+0x1428>
ffffffffc0203264:	00009617          	auipc	a2,0x9
ffffffffc0203268:	abc60613          	addi	a2,a2,-1348 # ffffffffc020bd20 <commands+0x250>
ffffffffc020326c:	17f00593          	li	a1,383
ffffffffc0203270:	0000a517          	auipc	a0,0xa
ffffffffc0203274:	89050513          	addi	a0,a0,-1904 # ffffffffc020cb00 <commands+0x1030>
ffffffffc0203278:	fb7fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020327c:	03700413          	li	s0,55
ffffffffc0203280:	1f900913          	li	s2,505
ffffffffc0203284:	a819                	j	ffffffffc020329a <vmm_init+0xa6>
ffffffffc0203286:	e500                	sd	s0,8(a0)
ffffffffc0203288:	e91c                	sd	a5,16(a0)
ffffffffc020328a:	00052c23          	sw	zero,24(a0)
ffffffffc020328e:	0415                	addi	s0,s0,5
ffffffffc0203290:	8526                	mv	a0,s1
ffffffffc0203292:	a1fff0ef          	jal	ra,ffffffffc0202cb0 <insert_vma_struct>
ffffffffc0203296:	03240a63          	beq	s0,s2,ffffffffc02032ca <vmm_init+0xd6>
ffffffffc020329a:	03000513          	li	a0,48
ffffffffc020329e:	632000ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc02032a2:	85aa                	mv	a1,a0
ffffffffc02032a4:	00240793          	addi	a5,s0,2
ffffffffc02032a8:	fd79                	bnez	a0,ffffffffc0203286 <vmm_init+0x92>
ffffffffc02032aa:	0000a697          	auipc	a3,0xa
ffffffffc02032ae:	c4e68693          	addi	a3,a3,-946 # ffffffffc020cef8 <commands+0x1428>
ffffffffc02032b2:	00009617          	auipc	a2,0x9
ffffffffc02032b6:	a6e60613          	addi	a2,a2,-1426 # ffffffffc020bd20 <commands+0x250>
ffffffffc02032ba:	18600593          	li	a1,390
ffffffffc02032be:	0000a517          	auipc	a0,0xa
ffffffffc02032c2:	84250513          	addi	a0,a0,-1982 # ffffffffc020cb00 <commands+0x1030>
ffffffffc02032c6:	f69fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02032ca:	649c                	ld	a5,8(s1)
ffffffffc02032cc:	471d                	li	a4,7
ffffffffc02032ce:	1fb00593          	li	a1,507
ffffffffc02032d2:	16f48663          	beq	s1,a5,ffffffffc020343e <vmm_init+0x24a>
ffffffffc02032d6:	fe87b603          	ld	a2,-24(a5)
ffffffffc02032da:	ffe70693          	addi	a3,a4,-2
ffffffffc02032de:	10d61063          	bne	a2,a3,ffffffffc02033de <vmm_init+0x1ea>
ffffffffc02032e2:	ff07b683          	ld	a3,-16(a5)
ffffffffc02032e6:	0ed71c63          	bne	a4,a3,ffffffffc02033de <vmm_init+0x1ea>
ffffffffc02032ea:	0715                	addi	a4,a4,5
ffffffffc02032ec:	679c                	ld	a5,8(a5)
ffffffffc02032ee:	feb712e3          	bne	a4,a1,ffffffffc02032d2 <vmm_init+0xde>
ffffffffc02032f2:	4a1d                	li	s4,7
ffffffffc02032f4:	4415                	li	s0,5
ffffffffc02032f6:	1f900a93          	li	s5,505
ffffffffc02032fa:	85a2                	mv	a1,s0
ffffffffc02032fc:	8526                	mv	a0,s1
ffffffffc02032fe:	973ff0ef          	jal	ra,ffffffffc0202c70 <find_vma>
ffffffffc0203302:	892a                	mv	s2,a0
ffffffffc0203304:	16050d63          	beqz	a0,ffffffffc020347e <vmm_init+0x28a>
ffffffffc0203308:	00140593          	addi	a1,s0,1
ffffffffc020330c:	8526                	mv	a0,s1
ffffffffc020330e:	963ff0ef          	jal	ra,ffffffffc0202c70 <find_vma>
ffffffffc0203312:	89aa                	mv	s3,a0
ffffffffc0203314:	14050563          	beqz	a0,ffffffffc020345e <vmm_init+0x26a>
ffffffffc0203318:	85d2                	mv	a1,s4
ffffffffc020331a:	8526                	mv	a0,s1
ffffffffc020331c:	955ff0ef          	jal	ra,ffffffffc0202c70 <find_vma>
ffffffffc0203320:	16051f63          	bnez	a0,ffffffffc020349e <vmm_init+0x2aa>
ffffffffc0203324:	00340593          	addi	a1,s0,3
ffffffffc0203328:	8526                	mv	a0,s1
ffffffffc020332a:	947ff0ef          	jal	ra,ffffffffc0202c70 <find_vma>
ffffffffc020332e:	1a051863          	bnez	a0,ffffffffc02034de <vmm_init+0x2ea>
ffffffffc0203332:	00440593          	addi	a1,s0,4
ffffffffc0203336:	8526                	mv	a0,s1
ffffffffc0203338:	939ff0ef          	jal	ra,ffffffffc0202c70 <find_vma>
ffffffffc020333c:	18051163          	bnez	a0,ffffffffc02034be <vmm_init+0x2ca>
ffffffffc0203340:	00893783          	ld	a5,8(s2)
ffffffffc0203344:	0a879d63          	bne	a5,s0,ffffffffc02033fe <vmm_init+0x20a>
ffffffffc0203348:	01093783          	ld	a5,16(s2)
ffffffffc020334c:	0b479963          	bne	a5,s4,ffffffffc02033fe <vmm_init+0x20a>
ffffffffc0203350:	0089b783          	ld	a5,8(s3)
ffffffffc0203354:	0c879563          	bne	a5,s0,ffffffffc020341e <vmm_init+0x22a>
ffffffffc0203358:	0109b783          	ld	a5,16(s3)
ffffffffc020335c:	0d479163          	bne	a5,s4,ffffffffc020341e <vmm_init+0x22a>
ffffffffc0203360:	0415                	addi	s0,s0,5
ffffffffc0203362:	0a15                	addi	s4,s4,5
ffffffffc0203364:	f9541be3          	bne	s0,s5,ffffffffc02032fa <vmm_init+0x106>
ffffffffc0203368:	4411                	li	s0,4
ffffffffc020336a:	597d                	li	s2,-1
ffffffffc020336c:	85a2                	mv	a1,s0
ffffffffc020336e:	8526                	mv	a0,s1
ffffffffc0203370:	901ff0ef          	jal	ra,ffffffffc0202c70 <find_vma>
ffffffffc0203374:	0004059b          	sext.w	a1,s0
ffffffffc0203378:	c90d                	beqz	a0,ffffffffc02033aa <vmm_init+0x1b6>
ffffffffc020337a:	6914                	ld	a3,16(a0)
ffffffffc020337c:	6510                	ld	a2,8(a0)
ffffffffc020337e:	0000a517          	auipc	a0,0xa
ffffffffc0203382:	b0250513          	addi	a0,a0,-1278 # ffffffffc020ce80 <commands+0x13b0>
ffffffffc0203386:	da5fc0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020338a:	0000a697          	auipc	a3,0xa
ffffffffc020338e:	b1e68693          	addi	a3,a3,-1250 # ffffffffc020cea8 <commands+0x13d8>
ffffffffc0203392:	00009617          	auipc	a2,0x9
ffffffffc0203396:	98e60613          	addi	a2,a2,-1650 # ffffffffc020bd20 <commands+0x250>
ffffffffc020339a:	1ac00593          	li	a1,428
ffffffffc020339e:	00009517          	auipc	a0,0x9
ffffffffc02033a2:	76250513          	addi	a0,a0,1890 # ffffffffc020cb00 <commands+0x1030>
ffffffffc02033a6:	e89fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02033aa:	147d                	addi	s0,s0,-1
ffffffffc02033ac:	fd2410e3          	bne	s0,s2,ffffffffc020336c <vmm_init+0x178>
ffffffffc02033b0:	8526                	mv	a0,s1
ffffffffc02033b2:	9cfff0ef          	jal	ra,ffffffffc0202d80 <mm_destroy>
ffffffffc02033b6:	0000a517          	auipc	a0,0xa
ffffffffc02033ba:	b0a50513          	addi	a0,a0,-1270 # ffffffffc020cec0 <commands+0x13f0>
ffffffffc02033be:	d6dfc0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02033c2:	7442                	ld	s0,48(sp)
ffffffffc02033c4:	70e2                	ld	ra,56(sp)
ffffffffc02033c6:	74a2                	ld	s1,40(sp)
ffffffffc02033c8:	7902                	ld	s2,32(sp)
ffffffffc02033ca:	69e2                	ld	s3,24(sp)
ffffffffc02033cc:	6a42                	ld	s4,16(sp)
ffffffffc02033ce:	6aa2                	ld	s5,8(sp)
ffffffffc02033d0:	0000a517          	auipc	a0,0xa
ffffffffc02033d4:	b1050513          	addi	a0,a0,-1264 # ffffffffc020cee0 <commands+0x1410>
ffffffffc02033d8:	6121                	addi	sp,sp,64
ffffffffc02033da:	d51fc06f          	j	ffffffffc020012a <cprintf>
ffffffffc02033de:	0000a697          	auipc	a3,0xa
ffffffffc02033e2:	9ba68693          	addi	a3,a3,-1606 # ffffffffc020cd98 <commands+0x12c8>
ffffffffc02033e6:	00009617          	auipc	a2,0x9
ffffffffc02033ea:	93a60613          	addi	a2,a2,-1734 # ffffffffc020bd20 <commands+0x250>
ffffffffc02033ee:	19000593          	li	a1,400
ffffffffc02033f2:	00009517          	auipc	a0,0x9
ffffffffc02033f6:	70e50513          	addi	a0,a0,1806 # ffffffffc020cb00 <commands+0x1030>
ffffffffc02033fa:	e35fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02033fe:	0000a697          	auipc	a3,0xa
ffffffffc0203402:	a2268693          	addi	a3,a3,-1502 # ffffffffc020ce20 <commands+0x1350>
ffffffffc0203406:	00009617          	auipc	a2,0x9
ffffffffc020340a:	91a60613          	addi	a2,a2,-1766 # ffffffffc020bd20 <commands+0x250>
ffffffffc020340e:	1a100593          	li	a1,417
ffffffffc0203412:	00009517          	auipc	a0,0x9
ffffffffc0203416:	6ee50513          	addi	a0,a0,1774 # ffffffffc020cb00 <commands+0x1030>
ffffffffc020341a:	e15fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020341e:	0000a697          	auipc	a3,0xa
ffffffffc0203422:	a3268693          	addi	a3,a3,-1486 # ffffffffc020ce50 <commands+0x1380>
ffffffffc0203426:	00009617          	auipc	a2,0x9
ffffffffc020342a:	8fa60613          	addi	a2,a2,-1798 # ffffffffc020bd20 <commands+0x250>
ffffffffc020342e:	1a200593          	li	a1,418
ffffffffc0203432:	00009517          	auipc	a0,0x9
ffffffffc0203436:	6ce50513          	addi	a0,a0,1742 # ffffffffc020cb00 <commands+0x1030>
ffffffffc020343a:	df5fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020343e:	0000a697          	auipc	a3,0xa
ffffffffc0203442:	94268693          	addi	a3,a3,-1726 # ffffffffc020cd80 <commands+0x12b0>
ffffffffc0203446:	00009617          	auipc	a2,0x9
ffffffffc020344a:	8da60613          	addi	a2,a2,-1830 # ffffffffc020bd20 <commands+0x250>
ffffffffc020344e:	18e00593          	li	a1,398
ffffffffc0203452:	00009517          	auipc	a0,0x9
ffffffffc0203456:	6ae50513          	addi	a0,a0,1710 # ffffffffc020cb00 <commands+0x1030>
ffffffffc020345a:	dd5fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020345e:	0000a697          	auipc	a3,0xa
ffffffffc0203462:	98268693          	addi	a3,a3,-1662 # ffffffffc020cde0 <commands+0x1310>
ffffffffc0203466:	00009617          	auipc	a2,0x9
ffffffffc020346a:	8ba60613          	addi	a2,a2,-1862 # ffffffffc020bd20 <commands+0x250>
ffffffffc020346e:	19900593          	li	a1,409
ffffffffc0203472:	00009517          	auipc	a0,0x9
ffffffffc0203476:	68e50513          	addi	a0,a0,1678 # ffffffffc020cb00 <commands+0x1030>
ffffffffc020347a:	db5fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020347e:	0000a697          	auipc	a3,0xa
ffffffffc0203482:	95268693          	addi	a3,a3,-1710 # ffffffffc020cdd0 <commands+0x1300>
ffffffffc0203486:	00009617          	auipc	a2,0x9
ffffffffc020348a:	89a60613          	addi	a2,a2,-1894 # ffffffffc020bd20 <commands+0x250>
ffffffffc020348e:	19700593          	li	a1,407
ffffffffc0203492:	00009517          	auipc	a0,0x9
ffffffffc0203496:	66e50513          	addi	a0,a0,1646 # ffffffffc020cb00 <commands+0x1030>
ffffffffc020349a:	d95fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020349e:	0000a697          	auipc	a3,0xa
ffffffffc02034a2:	95268693          	addi	a3,a3,-1710 # ffffffffc020cdf0 <commands+0x1320>
ffffffffc02034a6:	00009617          	auipc	a2,0x9
ffffffffc02034aa:	87a60613          	addi	a2,a2,-1926 # ffffffffc020bd20 <commands+0x250>
ffffffffc02034ae:	19b00593          	li	a1,411
ffffffffc02034b2:	00009517          	auipc	a0,0x9
ffffffffc02034b6:	64e50513          	addi	a0,a0,1614 # ffffffffc020cb00 <commands+0x1030>
ffffffffc02034ba:	d75fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02034be:	0000a697          	auipc	a3,0xa
ffffffffc02034c2:	95268693          	addi	a3,a3,-1710 # ffffffffc020ce10 <commands+0x1340>
ffffffffc02034c6:	00009617          	auipc	a2,0x9
ffffffffc02034ca:	85a60613          	addi	a2,a2,-1958 # ffffffffc020bd20 <commands+0x250>
ffffffffc02034ce:	19f00593          	li	a1,415
ffffffffc02034d2:	00009517          	auipc	a0,0x9
ffffffffc02034d6:	62e50513          	addi	a0,a0,1582 # ffffffffc020cb00 <commands+0x1030>
ffffffffc02034da:	d55fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02034de:	0000a697          	auipc	a3,0xa
ffffffffc02034e2:	92268693          	addi	a3,a3,-1758 # ffffffffc020ce00 <commands+0x1330>
ffffffffc02034e6:	00009617          	auipc	a2,0x9
ffffffffc02034ea:	83a60613          	addi	a2,a2,-1990 # ffffffffc020bd20 <commands+0x250>
ffffffffc02034ee:	19d00593          	li	a1,413
ffffffffc02034f2:	00009517          	auipc	a0,0x9
ffffffffc02034f6:	60e50513          	addi	a0,a0,1550 # ffffffffc020cb00 <commands+0x1030>
ffffffffc02034fa:	d35fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02034fe:	00009697          	auipc	a3,0x9
ffffffffc0203502:	68a68693          	addi	a3,a3,1674 # ffffffffc020cb88 <commands+0x10b8>
ffffffffc0203506:	00009617          	auipc	a2,0x9
ffffffffc020350a:	81a60613          	addi	a2,a2,-2022 # ffffffffc020bd20 <commands+0x250>
ffffffffc020350e:	17700593          	li	a1,375
ffffffffc0203512:	00009517          	auipc	a0,0x9
ffffffffc0203516:	5ee50513          	addi	a0,a0,1518 # ffffffffc020cb00 <commands+0x1030>
ffffffffc020351a:	d15fc0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020351e <user_mem_check>:
ffffffffc020351e:	7179                	addi	sp,sp,-48
ffffffffc0203520:	f022                	sd	s0,32(sp)
ffffffffc0203522:	f406                	sd	ra,40(sp)
ffffffffc0203524:	ec26                	sd	s1,24(sp)
ffffffffc0203526:	e84a                	sd	s2,16(sp)
ffffffffc0203528:	e44e                	sd	s3,8(sp)
ffffffffc020352a:	e052                	sd	s4,0(sp)
ffffffffc020352c:	842e                	mv	s0,a1
ffffffffc020352e:	c135                	beqz	a0,ffffffffc0203592 <user_mem_check+0x74>
ffffffffc0203530:	002007b7          	lui	a5,0x200
ffffffffc0203534:	04f5e663          	bltu	a1,a5,ffffffffc0203580 <user_mem_check+0x62>
ffffffffc0203538:	00c584b3          	add	s1,a1,a2
ffffffffc020353c:	0495f263          	bgeu	a1,s1,ffffffffc0203580 <user_mem_check+0x62>
ffffffffc0203540:	4785                	li	a5,1
ffffffffc0203542:	07fe                	slli	a5,a5,0x1f
ffffffffc0203544:	0297ee63          	bltu	a5,s1,ffffffffc0203580 <user_mem_check+0x62>
ffffffffc0203548:	892a                	mv	s2,a0
ffffffffc020354a:	89b6                	mv	s3,a3
ffffffffc020354c:	6a05                	lui	s4,0x1
ffffffffc020354e:	a821                	j	ffffffffc0203566 <user_mem_check+0x48>
ffffffffc0203550:	0027f693          	andi	a3,a5,2
ffffffffc0203554:	9752                	add	a4,a4,s4
ffffffffc0203556:	8ba1                	andi	a5,a5,8
ffffffffc0203558:	c685                	beqz	a3,ffffffffc0203580 <user_mem_check+0x62>
ffffffffc020355a:	c399                	beqz	a5,ffffffffc0203560 <user_mem_check+0x42>
ffffffffc020355c:	02e46263          	bltu	s0,a4,ffffffffc0203580 <user_mem_check+0x62>
ffffffffc0203560:	6900                	ld	s0,16(a0)
ffffffffc0203562:	04947663          	bgeu	s0,s1,ffffffffc02035ae <user_mem_check+0x90>
ffffffffc0203566:	85a2                	mv	a1,s0
ffffffffc0203568:	854a                	mv	a0,s2
ffffffffc020356a:	f06ff0ef          	jal	ra,ffffffffc0202c70 <find_vma>
ffffffffc020356e:	c909                	beqz	a0,ffffffffc0203580 <user_mem_check+0x62>
ffffffffc0203570:	6518                	ld	a4,8(a0)
ffffffffc0203572:	00e46763          	bltu	s0,a4,ffffffffc0203580 <user_mem_check+0x62>
ffffffffc0203576:	4d1c                	lw	a5,24(a0)
ffffffffc0203578:	fc099ce3          	bnez	s3,ffffffffc0203550 <user_mem_check+0x32>
ffffffffc020357c:	8b85                	andi	a5,a5,1
ffffffffc020357e:	f3ed                	bnez	a5,ffffffffc0203560 <user_mem_check+0x42>
ffffffffc0203580:	4501                	li	a0,0
ffffffffc0203582:	70a2                	ld	ra,40(sp)
ffffffffc0203584:	7402                	ld	s0,32(sp)
ffffffffc0203586:	64e2                	ld	s1,24(sp)
ffffffffc0203588:	6942                	ld	s2,16(sp)
ffffffffc020358a:	69a2                	ld	s3,8(sp)
ffffffffc020358c:	6a02                	ld	s4,0(sp)
ffffffffc020358e:	6145                	addi	sp,sp,48
ffffffffc0203590:	8082                	ret
ffffffffc0203592:	c02007b7          	lui	a5,0xc0200
ffffffffc0203596:	4501                	li	a0,0
ffffffffc0203598:	fef5e5e3          	bltu	a1,a5,ffffffffc0203582 <user_mem_check+0x64>
ffffffffc020359c:	962e                	add	a2,a2,a1
ffffffffc020359e:	fec5f2e3          	bgeu	a1,a2,ffffffffc0203582 <user_mem_check+0x64>
ffffffffc02035a2:	c8000537          	lui	a0,0xc8000
ffffffffc02035a6:	0505                	addi	a0,a0,1
ffffffffc02035a8:	00a63533          	sltu	a0,a2,a0
ffffffffc02035ac:	bfd9                	j	ffffffffc0203582 <user_mem_check+0x64>
ffffffffc02035ae:	4505                	li	a0,1
ffffffffc02035b0:	bfc9                	j	ffffffffc0203582 <user_mem_check+0x64>

ffffffffc02035b2 <copy_from_user>:
ffffffffc02035b2:	1101                	addi	sp,sp,-32
ffffffffc02035b4:	e822                	sd	s0,16(sp)
ffffffffc02035b6:	e426                	sd	s1,8(sp)
ffffffffc02035b8:	8432                	mv	s0,a2
ffffffffc02035ba:	84b6                	mv	s1,a3
ffffffffc02035bc:	e04a                	sd	s2,0(sp)
ffffffffc02035be:	86ba                	mv	a3,a4
ffffffffc02035c0:	892e                	mv	s2,a1
ffffffffc02035c2:	8626                	mv	a2,s1
ffffffffc02035c4:	85a2                	mv	a1,s0
ffffffffc02035c6:	ec06                	sd	ra,24(sp)
ffffffffc02035c8:	f57ff0ef          	jal	ra,ffffffffc020351e <user_mem_check>
ffffffffc02035cc:	c519                	beqz	a0,ffffffffc02035da <copy_from_user+0x28>
ffffffffc02035ce:	8626                	mv	a2,s1
ffffffffc02035d0:	85a2                	mv	a1,s0
ffffffffc02035d2:	854a                	mv	a0,s2
ffffffffc02035d4:	5ab070ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc02035d8:	4505                	li	a0,1
ffffffffc02035da:	60e2                	ld	ra,24(sp)
ffffffffc02035dc:	6442                	ld	s0,16(sp)
ffffffffc02035de:	64a2                	ld	s1,8(sp)
ffffffffc02035e0:	6902                	ld	s2,0(sp)
ffffffffc02035e2:	6105                	addi	sp,sp,32
ffffffffc02035e4:	8082                	ret

ffffffffc02035e6 <copy_to_user>:
ffffffffc02035e6:	1101                	addi	sp,sp,-32
ffffffffc02035e8:	e822                	sd	s0,16(sp)
ffffffffc02035ea:	8436                	mv	s0,a3
ffffffffc02035ec:	e04a                	sd	s2,0(sp)
ffffffffc02035ee:	4685                	li	a3,1
ffffffffc02035f0:	8932                	mv	s2,a2
ffffffffc02035f2:	8622                	mv	a2,s0
ffffffffc02035f4:	e426                	sd	s1,8(sp)
ffffffffc02035f6:	ec06                	sd	ra,24(sp)
ffffffffc02035f8:	84ae                	mv	s1,a1
ffffffffc02035fa:	f25ff0ef          	jal	ra,ffffffffc020351e <user_mem_check>
ffffffffc02035fe:	c519                	beqz	a0,ffffffffc020360c <copy_to_user+0x26>
ffffffffc0203600:	8622                	mv	a2,s0
ffffffffc0203602:	85ca                	mv	a1,s2
ffffffffc0203604:	8526                	mv	a0,s1
ffffffffc0203606:	579070ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc020360a:	4505                	li	a0,1
ffffffffc020360c:	60e2                	ld	ra,24(sp)
ffffffffc020360e:	6442                	ld	s0,16(sp)
ffffffffc0203610:	64a2                	ld	s1,8(sp)
ffffffffc0203612:	6902                	ld	s2,0(sp)
ffffffffc0203614:	6105                	addi	sp,sp,32
ffffffffc0203616:	8082                	ret

ffffffffc0203618 <copy_string>:
ffffffffc0203618:	7139                	addi	sp,sp,-64
ffffffffc020361a:	ec4e                	sd	s3,24(sp)
ffffffffc020361c:	6985                	lui	s3,0x1
ffffffffc020361e:	99b2                	add	s3,s3,a2
ffffffffc0203620:	77fd                	lui	a5,0xfffff
ffffffffc0203622:	00f9f9b3          	and	s3,s3,a5
ffffffffc0203626:	f426                	sd	s1,40(sp)
ffffffffc0203628:	f04a                	sd	s2,32(sp)
ffffffffc020362a:	e852                	sd	s4,16(sp)
ffffffffc020362c:	e456                	sd	s5,8(sp)
ffffffffc020362e:	fc06                	sd	ra,56(sp)
ffffffffc0203630:	f822                	sd	s0,48(sp)
ffffffffc0203632:	84b2                	mv	s1,a2
ffffffffc0203634:	8aaa                	mv	s5,a0
ffffffffc0203636:	8a2e                	mv	s4,a1
ffffffffc0203638:	8936                	mv	s2,a3
ffffffffc020363a:	40c989b3          	sub	s3,s3,a2
ffffffffc020363e:	a015                	j	ffffffffc0203662 <copy_string+0x4a>
ffffffffc0203640:	465070ef          	jal	ra,ffffffffc020b2a4 <strnlen>
ffffffffc0203644:	87aa                	mv	a5,a0
ffffffffc0203646:	85a6                	mv	a1,s1
ffffffffc0203648:	8552                	mv	a0,s4
ffffffffc020364a:	8622                	mv	a2,s0
ffffffffc020364c:	0487e363          	bltu	a5,s0,ffffffffc0203692 <copy_string+0x7a>
ffffffffc0203650:	0329f763          	bgeu	s3,s2,ffffffffc020367e <copy_string+0x66>
ffffffffc0203654:	52b070ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc0203658:	9a22                	add	s4,s4,s0
ffffffffc020365a:	94a2                	add	s1,s1,s0
ffffffffc020365c:	40890933          	sub	s2,s2,s0
ffffffffc0203660:	6985                	lui	s3,0x1
ffffffffc0203662:	4681                	li	a3,0
ffffffffc0203664:	85a6                	mv	a1,s1
ffffffffc0203666:	8556                	mv	a0,s5
ffffffffc0203668:	844a                	mv	s0,s2
ffffffffc020366a:	0129f363          	bgeu	s3,s2,ffffffffc0203670 <copy_string+0x58>
ffffffffc020366e:	844e                	mv	s0,s3
ffffffffc0203670:	8622                	mv	a2,s0
ffffffffc0203672:	eadff0ef          	jal	ra,ffffffffc020351e <user_mem_check>
ffffffffc0203676:	87aa                	mv	a5,a0
ffffffffc0203678:	85a2                	mv	a1,s0
ffffffffc020367a:	8526                	mv	a0,s1
ffffffffc020367c:	f3f1                	bnez	a5,ffffffffc0203640 <copy_string+0x28>
ffffffffc020367e:	4501                	li	a0,0
ffffffffc0203680:	70e2                	ld	ra,56(sp)
ffffffffc0203682:	7442                	ld	s0,48(sp)
ffffffffc0203684:	74a2                	ld	s1,40(sp)
ffffffffc0203686:	7902                	ld	s2,32(sp)
ffffffffc0203688:	69e2                	ld	s3,24(sp)
ffffffffc020368a:	6a42                	ld	s4,16(sp)
ffffffffc020368c:	6aa2                	ld	s5,8(sp)
ffffffffc020368e:	6121                	addi	sp,sp,64
ffffffffc0203690:	8082                	ret
ffffffffc0203692:	00178613          	addi	a2,a5,1 # fffffffffffff001 <end+0x3fd686a9>
ffffffffc0203696:	4e9070ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc020369a:	4505                	li	a0,1
ffffffffc020369c:	b7d5                	j	ffffffffc0203680 <copy_string+0x68>

ffffffffc020369e <slob_free>:
ffffffffc020369e:	c94d                	beqz	a0,ffffffffc0203750 <slob_free+0xb2>
ffffffffc02036a0:	1141                	addi	sp,sp,-16
ffffffffc02036a2:	e022                	sd	s0,0(sp)
ffffffffc02036a4:	e406                	sd	ra,8(sp)
ffffffffc02036a6:	842a                	mv	s0,a0
ffffffffc02036a8:	e9c1                	bnez	a1,ffffffffc0203738 <slob_free+0x9a>
ffffffffc02036aa:	100027f3          	csrr	a5,sstatus
ffffffffc02036ae:	8b89                	andi	a5,a5,2
ffffffffc02036b0:	4501                	li	a0,0
ffffffffc02036b2:	ebd9                	bnez	a5,ffffffffc0203748 <slob_free+0xaa>
ffffffffc02036b4:	0008e617          	auipc	a2,0x8e
ffffffffc02036b8:	99c60613          	addi	a2,a2,-1636 # ffffffffc0291050 <slobfree>
ffffffffc02036bc:	621c                	ld	a5,0(a2)
ffffffffc02036be:	873e                	mv	a4,a5
ffffffffc02036c0:	679c                	ld	a5,8(a5)
ffffffffc02036c2:	02877a63          	bgeu	a4,s0,ffffffffc02036f6 <slob_free+0x58>
ffffffffc02036c6:	00f46463          	bltu	s0,a5,ffffffffc02036ce <slob_free+0x30>
ffffffffc02036ca:	fef76ae3          	bltu	a4,a5,ffffffffc02036be <slob_free+0x20>
ffffffffc02036ce:	400c                	lw	a1,0(s0)
ffffffffc02036d0:	00459693          	slli	a3,a1,0x4
ffffffffc02036d4:	96a2                	add	a3,a3,s0
ffffffffc02036d6:	02d78a63          	beq	a5,a3,ffffffffc020370a <slob_free+0x6c>
ffffffffc02036da:	4314                	lw	a3,0(a4)
ffffffffc02036dc:	e41c                	sd	a5,8(s0)
ffffffffc02036de:	00469793          	slli	a5,a3,0x4
ffffffffc02036e2:	97ba                	add	a5,a5,a4
ffffffffc02036e4:	02f40e63          	beq	s0,a5,ffffffffc0203720 <slob_free+0x82>
ffffffffc02036e8:	e700                	sd	s0,8(a4)
ffffffffc02036ea:	e218                	sd	a4,0(a2)
ffffffffc02036ec:	e129                	bnez	a0,ffffffffc020372e <slob_free+0x90>
ffffffffc02036ee:	60a2                	ld	ra,8(sp)
ffffffffc02036f0:	6402                	ld	s0,0(sp)
ffffffffc02036f2:	0141                	addi	sp,sp,16
ffffffffc02036f4:	8082                	ret
ffffffffc02036f6:	fcf764e3          	bltu	a4,a5,ffffffffc02036be <slob_free+0x20>
ffffffffc02036fa:	fcf472e3          	bgeu	s0,a5,ffffffffc02036be <slob_free+0x20>
ffffffffc02036fe:	400c                	lw	a1,0(s0)
ffffffffc0203700:	00459693          	slli	a3,a1,0x4
ffffffffc0203704:	96a2                	add	a3,a3,s0
ffffffffc0203706:	fcd79ae3          	bne	a5,a3,ffffffffc02036da <slob_free+0x3c>
ffffffffc020370a:	4394                	lw	a3,0(a5)
ffffffffc020370c:	679c                	ld	a5,8(a5)
ffffffffc020370e:	9db5                	addw	a1,a1,a3
ffffffffc0203710:	c00c                	sw	a1,0(s0)
ffffffffc0203712:	4314                	lw	a3,0(a4)
ffffffffc0203714:	e41c                	sd	a5,8(s0)
ffffffffc0203716:	00469793          	slli	a5,a3,0x4
ffffffffc020371a:	97ba                	add	a5,a5,a4
ffffffffc020371c:	fcf416e3          	bne	s0,a5,ffffffffc02036e8 <slob_free+0x4a>
ffffffffc0203720:	401c                	lw	a5,0(s0)
ffffffffc0203722:	640c                	ld	a1,8(s0)
ffffffffc0203724:	e218                	sd	a4,0(a2)
ffffffffc0203726:	9ebd                	addw	a3,a3,a5
ffffffffc0203728:	c314                	sw	a3,0(a4)
ffffffffc020372a:	e70c                	sd	a1,8(a4)
ffffffffc020372c:	d169                	beqz	a0,ffffffffc02036ee <slob_free+0x50>
ffffffffc020372e:	6402                	ld	s0,0(sp)
ffffffffc0203730:	60a2                	ld	ra,8(sp)
ffffffffc0203732:	0141                	addi	sp,sp,16
ffffffffc0203734:	e66fd06f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc0203738:	25bd                	addiw	a1,a1,15
ffffffffc020373a:	8191                	srli	a1,a1,0x4
ffffffffc020373c:	c10c                	sw	a1,0(a0)
ffffffffc020373e:	100027f3          	csrr	a5,sstatus
ffffffffc0203742:	8b89                	andi	a5,a5,2
ffffffffc0203744:	4501                	li	a0,0
ffffffffc0203746:	d7bd                	beqz	a5,ffffffffc02036b4 <slob_free+0x16>
ffffffffc0203748:	e58fd0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020374c:	4505                	li	a0,1
ffffffffc020374e:	b79d                	j	ffffffffc02036b4 <slob_free+0x16>
ffffffffc0203750:	8082                	ret

ffffffffc0203752 <__slob_get_free_pages.constprop.0>:
ffffffffc0203752:	4785                	li	a5,1
ffffffffc0203754:	1141                	addi	sp,sp,-16
ffffffffc0203756:	00a7953b          	sllw	a0,a5,a0
ffffffffc020375a:	e406                	sd	ra,8(sp)
ffffffffc020375c:	c53fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203760:	c91d                	beqz	a0,ffffffffc0203796 <__slob_get_free_pages.constprop.0+0x44>
ffffffffc0203762:	00093697          	auipc	a3,0x93
ffffffffc0203766:	17e6b683          	ld	a3,382(a3) # ffffffffc02968e0 <pages>
ffffffffc020376a:	8d15                	sub	a0,a0,a3
ffffffffc020376c:	8519                	srai	a0,a0,0x6
ffffffffc020376e:	0000c697          	auipc	a3,0xc
ffffffffc0203772:	45a6b683          	ld	a3,1114(a3) # ffffffffc020fbc8 <nbase>
ffffffffc0203776:	9536                	add	a0,a0,a3
ffffffffc0203778:	00c51793          	slli	a5,a0,0xc
ffffffffc020377c:	83b1                	srli	a5,a5,0xc
ffffffffc020377e:	00093717          	auipc	a4,0x93
ffffffffc0203782:	15a73703          	ld	a4,346(a4) # ffffffffc02968d8 <npage>
ffffffffc0203786:	0532                	slli	a0,a0,0xc
ffffffffc0203788:	00e7fa63          	bgeu	a5,a4,ffffffffc020379c <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc020378c:	00093697          	auipc	a3,0x93
ffffffffc0203790:	1646b683          	ld	a3,356(a3) # ffffffffc02968f0 <va_pa_offset>
ffffffffc0203794:	9536                	add	a0,a0,a3
ffffffffc0203796:	60a2                	ld	ra,8(sp)
ffffffffc0203798:	0141                	addi	sp,sp,16
ffffffffc020379a:	8082                	ret
ffffffffc020379c:	86aa                	mv	a3,a0
ffffffffc020379e:	00009617          	auipc	a2,0x9
ffffffffc02037a2:	cba60613          	addi	a2,a2,-838 # ffffffffc020c458 <commands+0x988>
ffffffffc02037a6:	07100593          	li	a1,113
ffffffffc02037aa:	00009517          	auipc	a0,0x9
ffffffffc02037ae:	c7650513          	addi	a0,a0,-906 # ffffffffc020c420 <commands+0x950>
ffffffffc02037b2:	a7dfc0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02037b6 <slob_alloc.constprop.0>:
ffffffffc02037b6:	1101                	addi	sp,sp,-32
ffffffffc02037b8:	ec06                	sd	ra,24(sp)
ffffffffc02037ba:	e822                	sd	s0,16(sp)
ffffffffc02037bc:	e426                	sd	s1,8(sp)
ffffffffc02037be:	e04a                	sd	s2,0(sp)
ffffffffc02037c0:	01050713          	addi	a4,a0,16
ffffffffc02037c4:	6785                	lui	a5,0x1
ffffffffc02037c6:	0cf77363          	bgeu	a4,a5,ffffffffc020388c <slob_alloc.constprop.0+0xd6>
ffffffffc02037ca:	00f50493          	addi	s1,a0,15
ffffffffc02037ce:	8091                	srli	s1,s1,0x4
ffffffffc02037d0:	2481                	sext.w	s1,s1
ffffffffc02037d2:	10002673          	csrr	a2,sstatus
ffffffffc02037d6:	8a09                	andi	a2,a2,2
ffffffffc02037d8:	e25d                	bnez	a2,ffffffffc020387e <slob_alloc.constprop.0+0xc8>
ffffffffc02037da:	0008e917          	auipc	s2,0x8e
ffffffffc02037de:	87690913          	addi	s2,s2,-1930 # ffffffffc0291050 <slobfree>
ffffffffc02037e2:	00093683          	ld	a3,0(s2)
ffffffffc02037e6:	669c                	ld	a5,8(a3)
ffffffffc02037e8:	4398                	lw	a4,0(a5)
ffffffffc02037ea:	08975e63          	bge	a4,s1,ffffffffc0203886 <slob_alloc.constprop.0+0xd0>
ffffffffc02037ee:	00f68b63          	beq	a3,a5,ffffffffc0203804 <slob_alloc.constprop.0+0x4e>
ffffffffc02037f2:	6780                	ld	s0,8(a5)
ffffffffc02037f4:	4018                	lw	a4,0(s0)
ffffffffc02037f6:	02975a63          	bge	a4,s1,ffffffffc020382a <slob_alloc.constprop.0+0x74>
ffffffffc02037fa:	00093683          	ld	a3,0(s2)
ffffffffc02037fe:	87a2                	mv	a5,s0
ffffffffc0203800:	fef699e3          	bne	a3,a5,ffffffffc02037f2 <slob_alloc.constprop.0+0x3c>
ffffffffc0203804:	ee31                	bnez	a2,ffffffffc0203860 <slob_alloc.constprop.0+0xaa>
ffffffffc0203806:	4501                	li	a0,0
ffffffffc0203808:	f4bff0ef          	jal	ra,ffffffffc0203752 <__slob_get_free_pages.constprop.0>
ffffffffc020380c:	842a                	mv	s0,a0
ffffffffc020380e:	cd05                	beqz	a0,ffffffffc0203846 <slob_alloc.constprop.0+0x90>
ffffffffc0203810:	6585                	lui	a1,0x1
ffffffffc0203812:	e8dff0ef          	jal	ra,ffffffffc020369e <slob_free>
ffffffffc0203816:	10002673          	csrr	a2,sstatus
ffffffffc020381a:	8a09                	andi	a2,a2,2
ffffffffc020381c:	ee05                	bnez	a2,ffffffffc0203854 <slob_alloc.constprop.0+0x9e>
ffffffffc020381e:	00093783          	ld	a5,0(s2)
ffffffffc0203822:	6780                	ld	s0,8(a5)
ffffffffc0203824:	4018                	lw	a4,0(s0)
ffffffffc0203826:	fc974ae3          	blt	a4,s1,ffffffffc02037fa <slob_alloc.constprop.0+0x44>
ffffffffc020382a:	04e48763          	beq	s1,a4,ffffffffc0203878 <slob_alloc.constprop.0+0xc2>
ffffffffc020382e:	00449693          	slli	a3,s1,0x4
ffffffffc0203832:	96a2                	add	a3,a3,s0
ffffffffc0203834:	e794                	sd	a3,8(a5)
ffffffffc0203836:	640c                	ld	a1,8(s0)
ffffffffc0203838:	9f05                	subw	a4,a4,s1
ffffffffc020383a:	c298                	sw	a4,0(a3)
ffffffffc020383c:	e68c                	sd	a1,8(a3)
ffffffffc020383e:	c004                	sw	s1,0(s0)
ffffffffc0203840:	00f93023          	sd	a5,0(s2)
ffffffffc0203844:	e20d                	bnez	a2,ffffffffc0203866 <slob_alloc.constprop.0+0xb0>
ffffffffc0203846:	60e2                	ld	ra,24(sp)
ffffffffc0203848:	8522                	mv	a0,s0
ffffffffc020384a:	6442                	ld	s0,16(sp)
ffffffffc020384c:	64a2                	ld	s1,8(sp)
ffffffffc020384e:	6902                	ld	s2,0(sp)
ffffffffc0203850:	6105                	addi	sp,sp,32
ffffffffc0203852:	8082                	ret
ffffffffc0203854:	d4cfd0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0203858:	00093783          	ld	a5,0(s2)
ffffffffc020385c:	4605                	li	a2,1
ffffffffc020385e:	b7d1                	j	ffffffffc0203822 <slob_alloc.constprop.0+0x6c>
ffffffffc0203860:	d3afd0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0203864:	b74d                	j	ffffffffc0203806 <slob_alloc.constprop.0+0x50>
ffffffffc0203866:	d34fd0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020386a:	60e2                	ld	ra,24(sp)
ffffffffc020386c:	8522                	mv	a0,s0
ffffffffc020386e:	6442                	ld	s0,16(sp)
ffffffffc0203870:	64a2                	ld	s1,8(sp)
ffffffffc0203872:	6902                	ld	s2,0(sp)
ffffffffc0203874:	6105                	addi	sp,sp,32
ffffffffc0203876:	8082                	ret
ffffffffc0203878:	6418                	ld	a4,8(s0)
ffffffffc020387a:	e798                	sd	a4,8(a5)
ffffffffc020387c:	b7d1                	j	ffffffffc0203840 <slob_alloc.constprop.0+0x8a>
ffffffffc020387e:	d22fd0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0203882:	4605                	li	a2,1
ffffffffc0203884:	bf99                	j	ffffffffc02037da <slob_alloc.constprop.0+0x24>
ffffffffc0203886:	843e                	mv	s0,a5
ffffffffc0203888:	87b6                	mv	a5,a3
ffffffffc020388a:	b745                	j	ffffffffc020382a <slob_alloc.constprop.0+0x74>
ffffffffc020388c:	00009697          	auipc	a3,0x9
ffffffffc0203890:	67c68693          	addi	a3,a3,1660 # ffffffffc020cf08 <commands+0x1438>
ffffffffc0203894:	00008617          	auipc	a2,0x8
ffffffffc0203898:	48c60613          	addi	a2,a2,1164 # ffffffffc020bd20 <commands+0x250>
ffffffffc020389c:	06300593          	li	a1,99
ffffffffc02038a0:	00009517          	auipc	a0,0x9
ffffffffc02038a4:	68850513          	addi	a0,a0,1672 # ffffffffc020cf28 <commands+0x1458>
ffffffffc02038a8:	987fc0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02038ac <kmalloc_init>:
ffffffffc02038ac:	1141                	addi	sp,sp,-16
ffffffffc02038ae:	00009517          	auipc	a0,0x9
ffffffffc02038b2:	69250513          	addi	a0,a0,1682 # ffffffffc020cf40 <commands+0x1470>
ffffffffc02038b6:	e406                	sd	ra,8(sp)
ffffffffc02038b8:	873fc0ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02038bc:	60a2                	ld	ra,8(sp)
ffffffffc02038be:	00009517          	auipc	a0,0x9
ffffffffc02038c2:	69a50513          	addi	a0,a0,1690 # ffffffffc020cf58 <commands+0x1488>
ffffffffc02038c6:	0141                	addi	sp,sp,16
ffffffffc02038c8:	863fc06f          	j	ffffffffc020012a <cprintf>

ffffffffc02038cc <kallocated>:
ffffffffc02038cc:	4501                	li	a0,0
ffffffffc02038ce:	8082                	ret

ffffffffc02038d0 <kmalloc>:
ffffffffc02038d0:	1101                	addi	sp,sp,-32
ffffffffc02038d2:	e04a                	sd	s2,0(sp)
ffffffffc02038d4:	6905                	lui	s2,0x1
ffffffffc02038d6:	e822                	sd	s0,16(sp)
ffffffffc02038d8:	ec06                	sd	ra,24(sp)
ffffffffc02038da:	e426                	sd	s1,8(sp)
ffffffffc02038dc:	fef90793          	addi	a5,s2,-17 # fef <_binary_bin_swap_img_size-0x6d11>
ffffffffc02038e0:	842a                	mv	s0,a0
ffffffffc02038e2:	04a7f963          	bgeu	a5,a0,ffffffffc0203934 <kmalloc+0x64>
ffffffffc02038e6:	4561                	li	a0,24
ffffffffc02038e8:	ecfff0ef          	jal	ra,ffffffffc02037b6 <slob_alloc.constprop.0>
ffffffffc02038ec:	84aa                	mv	s1,a0
ffffffffc02038ee:	c929                	beqz	a0,ffffffffc0203940 <kmalloc+0x70>
ffffffffc02038f0:	0004079b          	sext.w	a5,s0
ffffffffc02038f4:	4501                	li	a0,0
ffffffffc02038f6:	00f95763          	bge	s2,a5,ffffffffc0203904 <kmalloc+0x34>
ffffffffc02038fa:	6705                	lui	a4,0x1
ffffffffc02038fc:	8785                	srai	a5,a5,0x1
ffffffffc02038fe:	2505                	addiw	a0,a0,1
ffffffffc0203900:	fef74ee3          	blt	a4,a5,ffffffffc02038fc <kmalloc+0x2c>
ffffffffc0203904:	c088                	sw	a0,0(s1)
ffffffffc0203906:	e4dff0ef          	jal	ra,ffffffffc0203752 <__slob_get_free_pages.constprop.0>
ffffffffc020390a:	e488                	sd	a0,8(s1)
ffffffffc020390c:	842a                	mv	s0,a0
ffffffffc020390e:	c525                	beqz	a0,ffffffffc0203976 <kmalloc+0xa6>
ffffffffc0203910:	100027f3          	csrr	a5,sstatus
ffffffffc0203914:	8b89                	andi	a5,a5,2
ffffffffc0203916:	ef8d                	bnez	a5,ffffffffc0203950 <kmalloc+0x80>
ffffffffc0203918:	00093797          	auipc	a5,0x93
ffffffffc020391c:	fe878793          	addi	a5,a5,-24 # ffffffffc0296900 <bigblocks>
ffffffffc0203920:	6398                	ld	a4,0(a5)
ffffffffc0203922:	e384                	sd	s1,0(a5)
ffffffffc0203924:	e898                	sd	a4,16(s1)
ffffffffc0203926:	60e2                	ld	ra,24(sp)
ffffffffc0203928:	8522                	mv	a0,s0
ffffffffc020392a:	6442                	ld	s0,16(sp)
ffffffffc020392c:	64a2                	ld	s1,8(sp)
ffffffffc020392e:	6902                	ld	s2,0(sp)
ffffffffc0203930:	6105                	addi	sp,sp,32
ffffffffc0203932:	8082                	ret
ffffffffc0203934:	0541                	addi	a0,a0,16
ffffffffc0203936:	e81ff0ef          	jal	ra,ffffffffc02037b6 <slob_alloc.constprop.0>
ffffffffc020393a:	01050413          	addi	s0,a0,16
ffffffffc020393e:	f565                	bnez	a0,ffffffffc0203926 <kmalloc+0x56>
ffffffffc0203940:	4401                	li	s0,0
ffffffffc0203942:	60e2                	ld	ra,24(sp)
ffffffffc0203944:	8522                	mv	a0,s0
ffffffffc0203946:	6442                	ld	s0,16(sp)
ffffffffc0203948:	64a2                	ld	s1,8(sp)
ffffffffc020394a:	6902                	ld	s2,0(sp)
ffffffffc020394c:	6105                	addi	sp,sp,32
ffffffffc020394e:	8082                	ret
ffffffffc0203950:	c50fd0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0203954:	00093797          	auipc	a5,0x93
ffffffffc0203958:	fac78793          	addi	a5,a5,-84 # ffffffffc0296900 <bigblocks>
ffffffffc020395c:	6398                	ld	a4,0(a5)
ffffffffc020395e:	e384                	sd	s1,0(a5)
ffffffffc0203960:	e898                	sd	a4,16(s1)
ffffffffc0203962:	c38fd0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0203966:	6480                	ld	s0,8(s1)
ffffffffc0203968:	60e2                	ld	ra,24(sp)
ffffffffc020396a:	64a2                	ld	s1,8(sp)
ffffffffc020396c:	8522                	mv	a0,s0
ffffffffc020396e:	6442                	ld	s0,16(sp)
ffffffffc0203970:	6902                	ld	s2,0(sp)
ffffffffc0203972:	6105                	addi	sp,sp,32
ffffffffc0203974:	8082                	ret
ffffffffc0203976:	45e1                	li	a1,24
ffffffffc0203978:	8526                	mv	a0,s1
ffffffffc020397a:	d25ff0ef          	jal	ra,ffffffffc020369e <slob_free>
ffffffffc020397e:	b765                	j	ffffffffc0203926 <kmalloc+0x56>

ffffffffc0203980 <kfree>:
ffffffffc0203980:	c179                	beqz	a0,ffffffffc0203a46 <kfree+0xc6>
ffffffffc0203982:	1101                	addi	sp,sp,-32
ffffffffc0203984:	e822                	sd	s0,16(sp)
ffffffffc0203986:	ec06                	sd	ra,24(sp)
ffffffffc0203988:	e426                	sd	s1,8(sp)
ffffffffc020398a:	03451793          	slli	a5,a0,0x34
ffffffffc020398e:	842a                	mv	s0,a0
ffffffffc0203990:	e7c1                	bnez	a5,ffffffffc0203a18 <kfree+0x98>
ffffffffc0203992:	100027f3          	csrr	a5,sstatus
ffffffffc0203996:	8b89                	andi	a5,a5,2
ffffffffc0203998:	ebc9                	bnez	a5,ffffffffc0203a2a <kfree+0xaa>
ffffffffc020399a:	00093797          	auipc	a5,0x93
ffffffffc020399e:	f667b783          	ld	a5,-154(a5) # ffffffffc0296900 <bigblocks>
ffffffffc02039a2:	4601                	li	a2,0
ffffffffc02039a4:	cbb5                	beqz	a5,ffffffffc0203a18 <kfree+0x98>
ffffffffc02039a6:	00093697          	auipc	a3,0x93
ffffffffc02039aa:	f5a68693          	addi	a3,a3,-166 # ffffffffc0296900 <bigblocks>
ffffffffc02039ae:	a021                	j	ffffffffc02039b6 <kfree+0x36>
ffffffffc02039b0:	01048693          	addi	a3,s1,16
ffffffffc02039b4:	c3ad                	beqz	a5,ffffffffc0203a16 <kfree+0x96>
ffffffffc02039b6:	6798                	ld	a4,8(a5)
ffffffffc02039b8:	84be                	mv	s1,a5
ffffffffc02039ba:	6b9c                	ld	a5,16(a5)
ffffffffc02039bc:	fe871ae3          	bne	a4,s0,ffffffffc02039b0 <kfree+0x30>
ffffffffc02039c0:	e29c                	sd	a5,0(a3)
ffffffffc02039c2:	ee3d                	bnez	a2,ffffffffc0203a40 <kfree+0xc0>
ffffffffc02039c4:	c02007b7          	lui	a5,0xc0200
ffffffffc02039c8:	4098                	lw	a4,0(s1)
ffffffffc02039ca:	08f46b63          	bltu	s0,a5,ffffffffc0203a60 <kfree+0xe0>
ffffffffc02039ce:	00093697          	auipc	a3,0x93
ffffffffc02039d2:	f226b683          	ld	a3,-222(a3) # ffffffffc02968f0 <va_pa_offset>
ffffffffc02039d6:	8c15                	sub	s0,s0,a3
ffffffffc02039d8:	8031                	srli	s0,s0,0xc
ffffffffc02039da:	00093797          	auipc	a5,0x93
ffffffffc02039de:	efe7b783          	ld	a5,-258(a5) # ffffffffc02968d8 <npage>
ffffffffc02039e2:	06f47363          	bgeu	s0,a5,ffffffffc0203a48 <kfree+0xc8>
ffffffffc02039e6:	0000c517          	auipc	a0,0xc
ffffffffc02039ea:	1e253503          	ld	a0,482(a0) # ffffffffc020fbc8 <nbase>
ffffffffc02039ee:	8c09                	sub	s0,s0,a0
ffffffffc02039f0:	041a                	slli	s0,s0,0x6
ffffffffc02039f2:	00093517          	auipc	a0,0x93
ffffffffc02039f6:	eee53503          	ld	a0,-274(a0) # ffffffffc02968e0 <pages>
ffffffffc02039fa:	4585                	li	a1,1
ffffffffc02039fc:	9522                	add	a0,a0,s0
ffffffffc02039fe:	00e595bb          	sllw	a1,a1,a4
ffffffffc0203a02:	9ebfd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203a06:	6442                	ld	s0,16(sp)
ffffffffc0203a08:	60e2                	ld	ra,24(sp)
ffffffffc0203a0a:	8526                	mv	a0,s1
ffffffffc0203a0c:	64a2                	ld	s1,8(sp)
ffffffffc0203a0e:	45e1                	li	a1,24
ffffffffc0203a10:	6105                	addi	sp,sp,32
ffffffffc0203a12:	c8dff06f          	j	ffffffffc020369e <slob_free>
ffffffffc0203a16:	e215                	bnez	a2,ffffffffc0203a3a <kfree+0xba>
ffffffffc0203a18:	ff040513          	addi	a0,s0,-16
ffffffffc0203a1c:	6442                	ld	s0,16(sp)
ffffffffc0203a1e:	60e2                	ld	ra,24(sp)
ffffffffc0203a20:	64a2                	ld	s1,8(sp)
ffffffffc0203a22:	4581                	li	a1,0
ffffffffc0203a24:	6105                	addi	sp,sp,32
ffffffffc0203a26:	c79ff06f          	j	ffffffffc020369e <slob_free>
ffffffffc0203a2a:	b76fd0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0203a2e:	00093797          	auipc	a5,0x93
ffffffffc0203a32:	ed27b783          	ld	a5,-302(a5) # ffffffffc0296900 <bigblocks>
ffffffffc0203a36:	4605                	li	a2,1
ffffffffc0203a38:	f7bd                	bnez	a5,ffffffffc02039a6 <kfree+0x26>
ffffffffc0203a3a:	b60fd0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0203a3e:	bfe9                	j	ffffffffc0203a18 <kfree+0x98>
ffffffffc0203a40:	b5afd0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0203a44:	b741                	j	ffffffffc02039c4 <kfree+0x44>
ffffffffc0203a46:	8082                	ret
ffffffffc0203a48:	00009617          	auipc	a2,0x9
ffffffffc0203a4c:	9b860613          	addi	a2,a2,-1608 # ffffffffc020c400 <commands+0x930>
ffffffffc0203a50:	06900593          	li	a1,105
ffffffffc0203a54:	00009517          	auipc	a0,0x9
ffffffffc0203a58:	9cc50513          	addi	a0,a0,-1588 # ffffffffc020c420 <commands+0x950>
ffffffffc0203a5c:	fd2fc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203a60:	86a2                	mv	a3,s0
ffffffffc0203a62:	00009617          	auipc	a2,0x9
ffffffffc0203a66:	aee60613          	addi	a2,a2,-1298 # ffffffffc020c550 <commands+0xa80>
ffffffffc0203a6a:	07700593          	li	a1,119
ffffffffc0203a6e:	00009517          	auipc	a0,0x9
ffffffffc0203a72:	9b250513          	addi	a0,a0,-1614 # ffffffffc020c420 <commands+0x950>
ffffffffc0203a76:	fb8fc0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0203a7a <default_init>:
ffffffffc0203a7a:	0008e797          	auipc	a5,0x8e
ffffffffc0203a7e:	d2e78793          	addi	a5,a5,-722 # ffffffffc02917a8 <free_area>
ffffffffc0203a82:	e79c                	sd	a5,8(a5)
ffffffffc0203a84:	e39c                	sd	a5,0(a5)
ffffffffc0203a86:	0007a823          	sw	zero,16(a5)
ffffffffc0203a8a:	8082                	ret

ffffffffc0203a8c <default_nr_free_pages>:
ffffffffc0203a8c:	0008e517          	auipc	a0,0x8e
ffffffffc0203a90:	d2c56503          	lwu	a0,-724(a0) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0203a94:	8082                	ret

ffffffffc0203a96 <default_check>:
ffffffffc0203a96:	715d                	addi	sp,sp,-80
ffffffffc0203a98:	e0a2                	sd	s0,64(sp)
ffffffffc0203a9a:	0008e417          	auipc	s0,0x8e
ffffffffc0203a9e:	d0e40413          	addi	s0,s0,-754 # ffffffffc02917a8 <free_area>
ffffffffc0203aa2:	641c                	ld	a5,8(s0)
ffffffffc0203aa4:	e486                	sd	ra,72(sp)
ffffffffc0203aa6:	fc26                	sd	s1,56(sp)
ffffffffc0203aa8:	f84a                	sd	s2,48(sp)
ffffffffc0203aaa:	f44e                	sd	s3,40(sp)
ffffffffc0203aac:	f052                	sd	s4,32(sp)
ffffffffc0203aae:	ec56                	sd	s5,24(sp)
ffffffffc0203ab0:	e85a                	sd	s6,16(sp)
ffffffffc0203ab2:	e45e                	sd	s7,8(sp)
ffffffffc0203ab4:	e062                	sd	s8,0(sp)
ffffffffc0203ab6:	2a878d63          	beq	a5,s0,ffffffffc0203d70 <default_check+0x2da>
ffffffffc0203aba:	4481                	li	s1,0
ffffffffc0203abc:	4901                	li	s2,0
ffffffffc0203abe:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203ac2:	8b09                	andi	a4,a4,2
ffffffffc0203ac4:	2a070a63          	beqz	a4,ffffffffc0203d78 <default_check+0x2e2>
ffffffffc0203ac8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203acc:	679c                	ld	a5,8(a5)
ffffffffc0203ace:	2905                	addiw	s2,s2,1
ffffffffc0203ad0:	9cb9                	addw	s1,s1,a4
ffffffffc0203ad2:	fe8796e3          	bne	a5,s0,ffffffffc0203abe <default_check+0x28>
ffffffffc0203ad6:	89a6                	mv	s3,s1
ffffffffc0203ad8:	955fd0ef          	jal	ra,ffffffffc020142c <nr_free_pages>
ffffffffc0203adc:	6f351e63          	bne	a0,s3,ffffffffc02041d8 <default_check+0x742>
ffffffffc0203ae0:	4505                	li	a0,1
ffffffffc0203ae2:	8cdfd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203ae6:	8aaa                	mv	s5,a0
ffffffffc0203ae8:	42050863          	beqz	a0,ffffffffc0203f18 <default_check+0x482>
ffffffffc0203aec:	4505                	li	a0,1
ffffffffc0203aee:	8c1fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203af2:	89aa                	mv	s3,a0
ffffffffc0203af4:	70050263          	beqz	a0,ffffffffc02041f8 <default_check+0x762>
ffffffffc0203af8:	4505                	li	a0,1
ffffffffc0203afa:	8b5fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203afe:	8a2a                	mv	s4,a0
ffffffffc0203b00:	48050c63          	beqz	a0,ffffffffc0203f98 <default_check+0x502>
ffffffffc0203b04:	293a8a63          	beq	s5,s3,ffffffffc0203d98 <default_check+0x302>
ffffffffc0203b08:	28aa8863          	beq	s5,a0,ffffffffc0203d98 <default_check+0x302>
ffffffffc0203b0c:	28a98663          	beq	s3,a0,ffffffffc0203d98 <default_check+0x302>
ffffffffc0203b10:	000aa783          	lw	a5,0(s5)
ffffffffc0203b14:	2a079263          	bnez	a5,ffffffffc0203db8 <default_check+0x322>
ffffffffc0203b18:	0009a783          	lw	a5,0(s3) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0203b1c:	28079e63          	bnez	a5,ffffffffc0203db8 <default_check+0x322>
ffffffffc0203b20:	411c                	lw	a5,0(a0)
ffffffffc0203b22:	28079b63          	bnez	a5,ffffffffc0203db8 <default_check+0x322>
ffffffffc0203b26:	00093797          	auipc	a5,0x93
ffffffffc0203b2a:	dba7b783          	ld	a5,-582(a5) # ffffffffc02968e0 <pages>
ffffffffc0203b2e:	40fa8733          	sub	a4,s5,a5
ffffffffc0203b32:	0000c617          	auipc	a2,0xc
ffffffffc0203b36:	09663603          	ld	a2,150(a2) # ffffffffc020fbc8 <nbase>
ffffffffc0203b3a:	8719                	srai	a4,a4,0x6
ffffffffc0203b3c:	9732                	add	a4,a4,a2
ffffffffc0203b3e:	00093697          	auipc	a3,0x93
ffffffffc0203b42:	d9a6b683          	ld	a3,-614(a3) # ffffffffc02968d8 <npage>
ffffffffc0203b46:	06b2                	slli	a3,a3,0xc
ffffffffc0203b48:	0732                	slli	a4,a4,0xc
ffffffffc0203b4a:	28d77763          	bgeu	a4,a3,ffffffffc0203dd8 <default_check+0x342>
ffffffffc0203b4e:	40f98733          	sub	a4,s3,a5
ffffffffc0203b52:	8719                	srai	a4,a4,0x6
ffffffffc0203b54:	9732                	add	a4,a4,a2
ffffffffc0203b56:	0732                	slli	a4,a4,0xc
ffffffffc0203b58:	4cd77063          	bgeu	a4,a3,ffffffffc0204018 <default_check+0x582>
ffffffffc0203b5c:	40f507b3          	sub	a5,a0,a5
ffffffffc0203b60:	8799                	srai	a5,a5,0x6
ffffffffc0203b62:	97b2                	add	a5,a5,a2
ffffffffc0203b64:	07b2                	slli	a5,a5,0xc
ffffffffc0203b66:	30d7f963          	bgeu	a5,a3,ffffffffc0203e78 <default_check+0x3e2>
ffffffffc0203b6a:	4505                	li	a0,1
ffffffffc0203b6c:	00043c03          	ld	s8,0(s0)
ffffffffc0203b70:	00843b83          	ld	s7,8(s0)
ffffffffc0203b74:	01042b03          	lw	s6,16(s0)
ffffffffc0203b78:	e400                	sd	s0,8(s0)
ffffffffc0203b7a:	e000                	sd	s0,0(s0)
ffffffffc0203b7c:	0008e797          	auipc	a5,0x8e
ffffffffc0203b80:	c207ae23          	sw	zero,-964(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0203b84:	82bfd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203b88:	2c051863          	bnez	a0,ffffffffc0203e58 <default_check+0x3c2>
ffffffffc0203b8c:	4585                	li	a1,1
ffffffffc0203b8e:	8556                	mv	a0,s5
ffffffffc0203b90:	85dfd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203b94:	4585                	li	a1,1
ffffffffc0203b96:	854e                	mv	a0,s3
ffffffffc0203b98:	855fd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203b9c:	4585                	li	a1,1
ffffffffc0203b9e:	8552                	mv	a0,s4
ffffffffc0203ba0:	84dfd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203ba4:	4818                	lw	a4,16(s0)
ffffffffc0203ba6:	478d                	li	a5,3
ffffffffc0203ba8:	28f71863          	bne	a4,a5,ffffffffc0203e38 <default_check+0x3a2>
ffffffffc0203bac:	4505                	li	a0,1
ffffffffc0203bae:	801fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203bb2:	89aa                	mv	s3,a0
ffffffffc0203bb4:	26050263          	beqz	a0,ffffffffc0203e18 <default_check+0x382>
ffffffffc0203bb8:	4505                	li	a0,1
ffffffffc0203bba:	ff4fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203bbe:	8aaa                	mv	s5,a0
ffffffffc0203bc0:	3a050c63          	beqz	a0,ffffffffc0203f78 <default_check+0x4e2>
ffffffffc0203bc4:	4505                	li	a0,1
ffffffffc0203bc6:	fe8fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203bca:	8a2a                	mv	s4,a0
ffffffffc0203bcc:	38050663          	beqz	a0,ffffffffc0203f58 <default_check+0x4c2>
ffffffffc0203bd0:	4505                	li	a0,1
ffffffffc0203bd2:	fdcfd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203bd6:	36051163          	bnez	a0,ffffffffc0203f38 <default_check+0x4a2>
ffffffffc0203bda:	4585                	li	a1,1
ffffffffc0203bdc:	854e                	mv	a0,s3
ffffffffc0203bde:	80ffd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203be2:	641c                	ld	a5,8(s0)
ffffffffc0203be4:	20878a63          	beq	a5,s0,ffffffffc0203df8 <default_check+0x362>
ffffffffc0203be8:	4505                	li	a0,1
ffffffffc0203bea:	fc4fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203bee:	30a99563          	bne	s3,a0,ffffffffc0203ef8 <default_check+0x462>
ffffffffc0203bf2:	4505                	li	a0,1
ffffffffc0203bf4:	fbafd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203bf8:	2e051063          	bnez	a0,ffffffffc0203ed8 <default_check+0x442>
ffffffffc0203bfc:	481c                	lw	a5,16(s0)
ffffffffc0203bfe:	2a079d63          	bnez	a5,ffffffffc0203eb8 <default_check+0x422>
ffffffffc0203c02:	854e                	mv	a0,s3
ffffffffc0203c04:	4585                	li	a1,1
ffffffffc0203c06:	01843023          	sd	s8,0(s0)
ffffffffc0203c0a:	01743423          	sd	s7,8(s0)
ffffffffc0203c0e:	01642823          	sw	s6,16(s0)
ffffffffc0203c12:	fdafd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203c16:	4585                	li	a1,1
ffffffffc0203c18:	8556                	mv	a0,s5
ffffffffc0203c1a:	fd2fd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203c1e:	4585                	li	a1,1
ffffffffc0203c20:	8552                	mv	a0,s4
ffffffffc0203c22:	fcafd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203c26:	4515                	li	a0,5
ffffffffc0203c28:	f86fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203c2c:	89aa                	mv	s3,a0
ffffffffc0203c2e:	26050563          	beqz	a0,ffffffffc0203e98 <default_check+0x402>
ffffffffc0203c32:	651c                	ld	a5,8(a0)
ffffffffc0203c34:	8385                	srli	a5,a5,0x1
ffffffffc0203c36:	8b85                	andi	a5,a5,1
ffffffffc0203c38:	54079063          	bnez	a5,ffffffffc0204178 <default_check+0x6e2>
ffffffffc0203c3c:	4505                	li	a0,1
ffffffffc0203c3e:	00043b03          	ld	s6,0(s0)
ffffffffc0203c42:	00843a83          	ld	s5,8(s0)
ffffffffc0203c46:	e000                	sd	s0,0(s0)
ffffffffc0203c48:	e400                	sd	s0,8(s0)
ffffffffc0203c4a:	f64fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203c4e:	50051563          	bnez	a0,ffffffffc0204158 <default_check+0x6c2>
ffffffffc0203c52:	08098a13          	addi	s4,s3,128
ffffffffc0203c56:	8552                	mv	a0,s4
ffffffffc0203c58:	458d                	li	a1,3
ffffffffc0203c5a:	01042b83          	lw	s7,16(s0)
ffffffffc0203c5e:	0008e797          	auipc	a5,0x8e
ffffffffc0203c62:	b407ad23          	sw	zero,-1190(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0203c66:	f86fd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203c6a:	4511                	li	a0,4
ffffffffc0203c6c:	f42fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203c70:	4c051463          	bnez	a0,ffffffffc0204138 <default_check+0x6a2>
ffffffffc0203c74:	0889b783          	ld	a5,136(s3)
ffffffffc0203c78:	8385                	srli	a5,a5,0x1
ffffffffc0203c7a:	8b85                	andi	a5,a5,1
ffffffffc0203c7c:	48078e63          	beqz	a5,ffffffffc0204118 <default_check+0x682>
ffffffffc0203c80:	0909a703          	lw	a4,144(s3)
ffffffffc0203c84:	478d                	li	a5,3
ffffffffc0203c86:	48f71963          	bne	a4,a5,ffffffffc0204118 <default_check+0x682>
ffffffffc0203c8a:	450d                	li	a0,3
ffffffffc0203c8c:	f22fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203c90:	8c2a                	mv	s8,a0
ffffffffc0203c92:	46050363          	beqz	a0,ffffffffc02040f8 <default_check+0x662>
ffffffffc0203c96:	4505                	li	a0,1
ffffffffc0203c98:	f16fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203c9c:	42051e63          	bnez	a0,ffffffffc02040d8 <default_check+0x642>
ffffffffc0203ca0:	418a1c63          	bne	s4,s8,ffffffffc02040b8 <default_check+0x622>
ffffffffc0203ca4:	4585                	li	a1,1
ffffffffc0203ca6:	854e                	mv	a0,s3
ffffffffc0203ca8:	f44fd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203cac:	458d                	li	a1,3
ffffffffc0203cae:	8552                	mv	a0,s4
ffffffffc0203cb0:	f3cfd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203cb4:	0089b783          	ld	a5,8(s3)
ffffffffc0203cb8:	04098c13          	addi	s8,s3,64
ffffffffc0203cbc:	8385                	srli	a5,a5,0x1
ffffffffc0203cbe:	8b85                	andi	a5,a5,1
ffffffffc0203cc0:	3c078c63          	beqz	a5,ffffffffc0204098 <default_check+0x602>
ffffffffc0203cc4:	0109a703          	lw	a4,16(s3)
ffffffffc0203cc8:	4785                	li	a5,1
ffffffffc0203cca:	3cf71763          	bne	a4,a5,ffffffffc0204098 <default_check+0x602>
ffffffffc0203cce:	008a3783          	ld	a5,8(s4) # 1008 <_binary_bin_swap_img_size-0x6cf8>
ffffffffc0203cd2:	8385                	srli	a5,a5,0x1
ffffffffc0203cd4:	8b85                	andi	a5,a5,1
ffffffffc0203cd6:	3a078163          	beqz	a5,ffffffffc0204078 <default_check+0x5e2>
ffffffffc0203cda:	010a2703          	lw	a4,16(s4)
ffffffffc0203cde:	478d                	li	a5,3
ffffffffc0203ce0:	38f71c63          	bne	a4,a5,ffffffffc0204078 <default_check+0x5e2>
ffffffffc0203ce4:	4505                	li	a0,1
ffffffffc0203ce6:	ec8fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203cea:	36a99763          	bne	s3,a0,ffffffffc0204058 <default_check+0x5c2>
ffffffffc0203cee:	4585                	li	a1,1
ffffffffc0203cf0:	efcfd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203cf4:	4509                	li	a0,2
ffffffffc0203cf6:	eb8fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203cfa:	32aa1f63          	bne	s4,a0,ffffffffc0204038 <default_check+0x5a2>
ffffffffc0203cfe:	4589                	li	a1,2
ffffffffc0203d00:	eecfd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203d04:	4585                	li	a1,1
ffffffffc0203d06:	8562                	mv	a0,s8
ffffffffc0203d08:	ee4fd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203d0c:	4515                	li	a0,5
ffffffffc0203d0e:	ea0fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203d12:	89aa                	mv	s3,a0
ffffffffc0203d14:	48050263          	beqz	a0,ffffffffc0204198 <default_check+0x702>
ffffffffc0203d18:	4505                	li	a0,1
ffffffffc0203d1a:	e94fd0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0203d1e:	2c051d63          	bnez	a0,ffffffffc0203ff8 <default_check+0x562>
ffffffffc0203d22:	481c                	lw	a5,16(s0)
ffffffffc0203d24:	2a079a63          	bnez	a5,ffffffffc0203fd8 <default_check+0x542>
ffffffffc0203d28:	4595                	li	a1,5
ffffffffc0203d2a:	854e                	mv	a0,s3
ffffffffc0203d2c:	01742823          	sw	s7,16(s0)
ffffffffc0203d30:	01643023          	sd	s6,0(s0)
ffffffffc0203d34:	01543423          	sd	s5,8(s0)
ffffffffc0203d38:	eb4fd0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc0203d3c:	641c                	ld	a5,8(s0)
ffffffffc0203d3e:	00878963          	beq	a5,s0,ffffffffc0203d50 <default_check+0x2ba>
ffffffffc0203d42:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203d46:	679c                	ld	a5,8(a5)
ffffffffc0203d48:	397d                	addiw	s2,s2,-1
ffffffffc0203d4a:	9c99                	subw	s1,s1,a4
ffffffffc0203d4c:	fe879be3          	bne	a5,s0,ffffffffc0203d42 <default_check+0x2ac>
ffffffffc0203d50:	26091463          	bnez	s2,ffffffffc0203fb8 <default_check+0x522>
ffffffffc0203d54:	46049263          	bnez	s1,ffffffffc02041b8 <default_check+0x722>
ffffffffc0203d58:	60a6                	ld	ra,72(sp)
ffffffffc0203d5a:	6406                	ld	s0,64(sp)
ffffffffc0203d5c:	74e2                	ld	s1,56(sp)
ffffffffc0203d5e:	7942                	ld	s2,48(sp)
ffffffffc0203d60:	79a2                	ld	s3,40(sp)
ffffffffc0203d62:	7a02                	ld	s4,32(sp)
ffffffffc0203d64:	6ae2                	ld	s5,24(sp)
ffffffffc0203d66:	6b42                	ld	s6,16(sp)
ffffffffc0203d68:	6ba2                	ld	s7,8(sp)
ffffffffc0203d6a:	6c02                	ld	s8,0(sp)
ffffffffc0203d6c:	6161                	addi	sp,sp,80
ffffffffc0203d6e:	8082                	ret
ffffffffc0203d70:	4981                	li	s3,0
ffffffffc0203d72:	4481                	li	s1,0
ffffffffc0203d74:	4901                	li	s2,0
ffffffffc0203d76:	b38d                	j	ffffffffc0203ad8 <default_check+0x42>
ffffffffc0203d78:	00009697          	auipc	a3,0x9
ffffffffc0203d7c:	20068693          	addi	a3,a3,512 # ffffffffc020cf78 <commands+0x14a8>
ffffffffc0203d80:	00008617          	auipc	a2,0x8
ffffffffc0203d84:	fa060613          	addi	a2,a2,-96 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203d88:	0ef00593          	li	a1,239
ffffffffc0203d8c:	00009517          	auipc	a0,0x9
ffffffffc0203d90:	1fc50513          	addi	a0,a0,508 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203d94:	c9afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203d98:	00009697          	auipc	a3,0x9
ffffffffc0203d9c:	28868693          	addi	a3,a3,648 # ffffffffc020d020 <commands+0x1550>
ffffffffc0203da0:	00008617          	auipc	a2,0x8
ffffffffc0203da4:	f8060613          	addi	a2,a2,-128 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203da8:	0bc00593          	li	a1,188
ffffffffc0203dac:	00009517          	auipc	a0,0x9
ffffffffc0203db0:	1dc50513          	addi	a0,a0,476 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203db4:	c7afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203db8:	00009697          	auipc	a3,0x9
ffffffffc0203dbc:	29068693          	addi	a3,a3,656 # ffffffffc020d048 <commands+0x1578>
ffffffffc0203dc0:	00008617          	auipc	a2,0x8
ffffffffc0203dc4:	f6060613          	addi	a2,a2,-160 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203dc8:	0bd00593          	li	a1,189
ffffffffc0203dcc:	00009517          	auipc	a0,0x9
ffffffffc0203dd0:	1bc50513          	addi	a0,a0,444 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203dd4:	c5afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203dd8:	00009697          	auipc	a3,0x9
ffffffffc0203ddc:	2b068693          	addi	a3,a3,688 # ffffffffc020d088 <commands+0x15b8>
ffffffffc0203de0:	00008617          	auipc	a2,0x8
ffffffffc0203de4:	f4060613          	addi	a2,a2,-192 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203de8:	0bf00593          	li	a1,191
ffffffffc0203dec:	00009517          	auipc	a0,0x9
ffffffffc0203df0:	19c50513          	addi	a0,a0,412 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203df4:	c3afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203df8:	00009697          	auipc	a3,0x9
ffffffffc0203dfc:	31868693          	addi	a3,a3,792 # ffffffffc020d110 <commands+0x1640>
ffffffffc0203e00:	00008617          	auipc	a2,0x8
ffffffffc0203e04:	f2060613          	addi	a2,a2,-224 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203e08:	0d800593          	li	a1,216
ffffffffc0203e0c:	00009517          	auipc	a0,0x9
ffffffffc0203e10:	17c50513          	addi	a0,a0,380 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203e14:	c1afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203e18:	00009697          	auipc	a3,0x9
ffffffffc0203e1c:	1a868693          	addi	a3,a3,424 # ffffffffc020cfc0 <commands+0x14f0>
ffffffffc0203e20:	00008617          	auipc	a2,0x8
ffffffffc0203e24:	f0060613          	addi	a2,a2,-256 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203e28:	0d100593          	li	a1,209
ffffffffc0203e2c:	00009517          	auipc	a0,0x9
ffffffffc0203e30:	15c50513          	addi	a0,a0,348 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203e34:	bfafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203e38:	00009697          	auipc	a3,0x9
ffffffffc0203e3c:	2c868693          	addi	a3,a3,712 # ffffffffc020d100 <commands+0x1630>
ffffffffc0203e40:	00008617          	auipc	a2,0x8
ffffffffc0203e44:	ee060613          	addi	a2,a2,-288 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203e48:	0cf00593          	li	a1,207
ffffffffc0203e4c:	00009517          	auipc	a0,0x9
ffffffffc0203e50:	13c50513          	addi	a0,a0,316 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203e54:	bdafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203e58:	00009697          	auipc	a3,0x9
ffffffffc0203e5c:	29068693          	addi	a3,a3,656 # ffffffffc020d0e8 <commands+0x1618>
ffffffffc0203e60:	00008617          	auipc	a2,0x8
ffffffffc0203e64:	ec060613          	addi	a2,a2,-320 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203e68:	0ca00593          	li	a1,202
ffffffffc0203e6c:	00009517          	auipc	a0,0x9
ffffffffc0203e70:	11c50513          	addi	a0,a0,284 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203e74:	bbafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203e78:	00009697          	auipc	a3,0x9
ffffffffc0203e7c:	25068693          	addi	a3,a3,592 # ffffffffc020d0c8 <commands+0x15f8>
ffffffffc0203e80:	00008617          	auipc	a2,0x8
ffffffffc0203e84:	ea060613          	addi	a2,a2,-352 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203e88:	0c100593          	li	a1,193
ffffffffc0203e8c:	00009517          	auipc	a0,0x9
ffffffffc0203e90:	0fc50513          	addi	a0,a0,252 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203e94:	b9afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203e98:	00009697          	auipc	a3,0x9
ffffffffc0203e9c:	2c068693          	addi	a3,a3,704 # ffffffffc020d158 <commands+0x1688>
ffffffffc0203ea0:	00008617          	auipc	a2,0x8
ffffffffc0203ea4:	e8060613          	addi	a2,a2,-384 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203ea8:	0f700593          	li	a1,247
ffffffffc0203eac:	00009517          	auipc	a0,0x9
ffffffffc0203eb0:	0dc50513          	addi	a0,a0,220 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203eb4:	b7afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203eb8:	00009697          	auipc	a3,0x9
ffffffffc0203ebc:	29068693          	addi	a3,a3,656 # ffffffffc020d148 <commands+0x1678>
ffffffffc0203ec0:	00008617          	auipc	a2,0x8
ffffffffc0203ec4:	e6060613          	addi	a2,a2,-416 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203ec8:	0de00593          	li	a1,222
ffffffffc0203ecc:	00009517          	auipc	a0,0x9
ffffffffc0203ed0:	0bc50513          	addi	a0,a0,188 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203ed4:	b5afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203ed8:	00009697          	auipc	a3,0x9
ffffffffc0203edc:	21068693          	addi	a3,a3,528 # ffffffffc020d0e8 <commands+0x1618>
ffffffffc0203ee0:	00008617          	auipc	a2,0x8
ffffffffc0203ee4:	e4060613          	addi	a2,a2,-448 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203ee8:	0dc00593          	li	a1,220
ffffffffc0203eec:	00009517          	auipc	a0,0x9
ffffffffc0203ef0:	09c50513          	addi	a0,a0,156 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203ef4:	b3afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203ef8:	00009697          	auipc	a3,0x9
ffffffffc0203efc:	23068693          	addi	a3,a3,560 # ffffffffc020d128 <commands+0x1658>
ffffffffc0203f00:	00008617          	auipc	a2,0x8
ffffffffc0203f04:	e2060613          	addi	a2,a2,-480 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203f08:	0db00593          	li	a1,219
ffffffffc0203f0c:	00009517          	auipc	a0,0x9
ffffffffc0203f10:	07c50513          	addi	a0,a0,124 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203f14:	b1afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203f18:	00009697          	auipc	a3,0x9
ffffffffc0203f1c:	0a868693          	addi	a3,a3,168 # ffffffffc020cfc0 <commands+0x14f0>
ffffffffc0203f20:	00008617          	auipc	a2,0x8
ffffffffc0203f24:	e0060613          	addi	a2,a2,-512 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203f28:	0b800593          	li	a1,184
ffffffffc0203f2c:	00009517          	auipc	a0,0x9
ffffffffc0203f30:	05c50513          	addi	a0,a0,92 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203f34:	afafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203f38:	00009697          	auipc	a3,0x9
ffffffffc0203f3c:	1b068693          	addi	a3,a3,432 # ffffffffc020d0e8 <commands+0x1618>
ffffffffc0203f40:	00008617          	auipc	a2,0x8
ffffffffc0203f44:	de060613          	addi	a2,a2,-544 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203f48:	0d500593          	li	a1,213
ffffffffc0203f4c:	00009517          	auipc	a0,0x9
ffffffffc0203f50:	03c50513          	addi	a0,a0,60 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203f54:	adafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203f58:	00009697          	auipc	a3,0x9
ffffffffc0203f5c:	0a868693          	addi	a3,a3,168 # ffffffffc020d000 <commands+0x1530>
ffffffffc0203f60:	00008617          	auipc	a2,0x8
ffffffffc0203f64:	dc060613          	addi	a2,a2,-576 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203f68:	0d300593          	li	a1,211
ffffffffc0203f6c:	00009517          	auipc	a0,0x9
ffffffffc0203f70:	01c50513          	addi	a0,a0,28 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203f74:	abafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203f78:	00009697          	auipc	a3,0x9
ffffffffc0203f7c:	06868693          	addi	a3,a3,104 # ffffffffc020cfe0 <commands+0x1510>
ffffffffc0203f80:	00008617          	auipc	a2,0x8
ffffffffc0203f84:	da060613          	addi	a2,a2,-608 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203f88:	0d200593          	li	a1,210
ffffffffc0203f8c:	00009517          	auipc	a0,0x9
ffffffffc0203f90:	ffc50513          	addi	a0,a0,-4 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203f94:	a9afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203f98:	00009697          	auipc	a3,0x9
ffffffffc0203f9c:	06868693          	addi	a3,a3,104 # ffffffffc020d000 <commands+0x1530>
ffffffffc0203fa0:	00008617          	auipc	a2,0x8
ffffffffc0203fa4:	d8060613          	addi	a2,a2,-640 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203fa8:	0ba00593          	li	a1,186
ffffffffc0203fac:	00009517          	auipc	a0,0x9
ffffffffc0203fb0:	fdc50513          	addi	a0,a0,-36 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203fb4:	a7afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203fb8:	00009697          	auipc	a3,0x9
ffffffffc0203fbc:	2f068693          	addi	a3,a3,752 # ffffffffc020d2a8 <commands+0x17d8>
ffffffffc0203fc0:	00008617          	auipc	a2,0x8
ffffffffc0203fc4:	d6060613          	addi	a2,a2,-672 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203fc8:	12400593          	li	a1,292
ffffffffc0203fcc:	00009517          	auipc	a0,0x9
ffffffffc0203fd0:	fbc50513          	addi	a0,a0,-68 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203fd4:	a5afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203fd8:	00009697          	auipc	a3,0x9
ffffffffc0203fdc:	17068693          	addi	a3,a3,368 # ffffffffc020d148 <commands+0x1678>
ffffffffc0203fe0:	00008617          	auipc	a2,0x8
ffffffffc0203fe4:	d4060613          	addi	a2,a2,-704 # ffffffffc020bd20 <commands+0x250>
ffffffffc0203fe8:	11900593          	li	a1,281
ffffffffc0203fec:	00009517          	auipc	a0,0x9
ffffffffc0203ff0:	f9c50513          	addi	a0,a0,-100 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0203ff4:	a3afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0203ff8:	00009697          	auipc	a3,0x9
ffffffffc0203ffc:	0f068693          	addi	a3,a3,240 # ffffffffc020d0e8 <commands+0x1618>
ffffffffc0204000:	00008617          	auipc	a2,0x8
ffffffffc0204004:	d2060613          	addi	a2,a2,-736 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204008:	11700593          	li	a1,279
ffffffffc020400c:	00009517          	auipc	a0,0x9
ffffffffc0204010:	f7c50513          	addi	a0,a0,-132 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204014:	a1afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204018:	00009697          	auipc	a3,0x9
ffffffffc020401c:	09068693          	addi	a3,a3,144 # ffffffffc020d0a8 <commands+0x15d8>
ffffffffc0204020:	00008617          	auipc	a2,0x8
ffffffffc0204024:	d0060613          	addi	a2,a2,-768 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204028:	0c000593          	li	a1,192
ffffffffc020402c:	00009517          	auipc	a0,0x9
ffffffffc0204030:	f5c50513          	addi	a0,a0,-164 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204034:	9fafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204038:	00009697          	auipc	a3,0x9
ffffffffc020403c:	23068693          	addi	a3,a3,560 # ffffffffc020d268 <commands+0x1798>
ffffffffc0204040:	00008617          	auipc	a2,0x8
ffffffffc0204044:	ce060613          	addi	a2,a2,-800 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204048:	11100593          	li	a1,273
ffffffffc020404c:	00009517          	auipc	a0,0x9
ffffffffc0204050:	f3c50513          	addi	a0,a0,-196 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204054:	9dafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204058:	00009697          	auipc	a3,0x9
ffffffffc020405c:	1f068693          	addi	a3,a3,496 # ffffffffc020d248 <commands+0x1778>
ffffffffc0204060:	00008617          	auipc	a2,0x8
ffffffffc0204064:	cc060613          	addi	a2,a2,-832 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204068:	10f00593          	li	a1,271
ffffffffc020406c:	00009517          	auipc	a0,0x9
ffffffffc0204070:	f1c50513          	addi	a0,a0,-228 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204074:	9bafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204078:	00009697          	auipc	a3,0x9
ffffffffc020407c:	1a868693          	addi	a3,a3,424 # ffffffffc020d220 <commands+0x1750>
ffffffffc0204080:	00008617          	auipc	a2,0x8
ffffffffc0204084:	ca060613          	addi	a2,a2,-864 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204088:	10d00593          	li	a1,269
ffffffffc020408c:	00009517          	auipc	a0,0x9
ffffffffc0204090:	efc50513          	addi	a0,a0,-260 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204094:	99afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204098:	00009697          	auipc	a3,0x9
ffffffffc020409c:	16068693          	addi	a3,a3,352 # ffffffffc020d1f8 <commands+0x1728>
ffffffffc02040a0:	00008617          	auipc	a2,0x8
ffffffffc02040a4:	c8060613          	addi	a2,a2,-896 # ffffffffc020bd20 <commands+0x250>
ffffffffc02040a8:	10c00593          	li	a1,268
ffffffffc02040ac:	00009517          	auipc	a0,0x9
ffffffffc02040b0:	edc50513          	addi	a0,a0,-292 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc02040b4:	97afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02040b8:	00009697          	auipc	a3,0x9
ffffffffc02040bc:	13068693          	addi	a3,a3,304 # ffffffffc020d1e8 <commands+0x1718>
ffffffffc02040c0:	00008617          	auipc	a2,0x8
ffffffffc02040c4:	c6060613          	addi	a2,a2,-928 # ffffffffc020bd20 <commands+0x250>
ffffffffc02040c8:	10700593          	li	a1,263
ffffffffc02040cc:	00009517          	auipc	a0,0x9
ffffffffc02040d0:	ebc50513          	addi	a0,a0,-324 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc02040d4:	95afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02040d8:	00009697          	auipc	a3,0x9
ffffffffc02040dc:	01068693          	addi	a3,a3,16 # ffffffffc020d0e8 <commands+0x1618>
ffffffffc02040e0:	00008617          	auipc	a2,0x8
ffffffffc02040e4:	c4060613          	addi	a2,a2,-960 # ffffffffc020bd20 <commands+0x250>
ffffffffc02040e8:	10600593          	li	a1,262
ffffffffc02040ec:	00009517          	auipc	a0,0x9
ffffffffc02040f0:	e9c50513          	addi	a0,a0,-356 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc02040f4:	93afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02040f8:	00009697          	auipc	a3,0x9
ffffffffc02040fc:	0d068693          	addi	a3,a3,208 # ffffffffc020d1c8 <commands+0x16f8>
ffffffffc0204100:	00008617          	auipc	a2,0x8
ffffffffc0204104:	c2060613          	addi	a2,a2,-992 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204108:	10500593          	li	a1,261
ffffffffc020410c:	00009517          	auipc	a0,0x9
ffffffffc0204110:	e7c50513          	addi	a0,a0,-388 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204114:	91afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204118:	00009697          	auipc	a3,0x9
ffffffffc020411c:	08068693          	addi	a3,a3,128 # ffffffffc020d198 <commands+0x16c8>
ffffffffc0204120:	00008617          	auipc	a2,0x8
ffffffffc0204124:	c0060613          	addi	a2,a2,-1024 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204128:	10400593          	li	a1,260
ffffffffc020412c:	00009517          	auipc	a0,0x9
ffffffffc0204130:	e5c50513          	addi	a0,a0,-420 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204134:	8fafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204138:	00009697          	auipc	a3,0x9
ffffffffc020413c:	04868693          	addi	a3,a3,72 # ffffffffc020d180 <commands+0x16b0>
ffffffffc0204140:	00008617          	auipc	a2,0x8
ffffffffc0204144:	be060613          	addi	a2,a2,-1056 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204148:	10300593          	li	a1,259
ffffffffc020414c:	00009517          	auipc	a0,0x9
ffffffffc0204150:	e3c50513          	addi	a0,a0,-452 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204154:	8dafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204158:	00009697          	auipc	a3,0x9
ffffffffc020415c:	f9068693          	addi	a3,a3,-112 # ffffffffc020d0e8 <commands+0x1618>
ffffffffc0204160:	00008617          	auipc	a2,0x8
ffffffffc0204164:	bc060613          	addi	a2,a2,-1088 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204168:	0fd00593          	li	a1,253
ffffffffc020416c:	00009517          	auipc	a0,0x9
ffffffffc0204170:	e1c50513          	addi	a0,a0,-484 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204174:	8bafc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204178:	00009697          	auipc	a3,0x9
ffffffffc020417c:	ff068693          	addi	a3,a3,-16 # ffffffffc020d168 <commands+0x1698>
ffffffffc0204180:	00008617          	auipc	a2,0x8
ffffffffc0204184:	ba060613          	addi	a2,a2,-1120 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204188:	0f800593          	li	a1,248
ffffffffc020418c:	00009517          	auipc	a0,0x9
ffffffffc0204190:	dfc50513          	addi	a0,a0,-516 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204194:	89afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204198:	00009697          	auipc	a3,0x9
ffffffffc020419c:	0f068693          	addi	a3,a3,240 # ffffffffc020d288 <commands+0x17b8>
ffffffffc02041a0:	00008617          	auipc	a2,0x8
ffffffffc02041a4:	b8060613          	addi	a2,a2,-1152 # ffffffffc020bd20 <commands+0x250>
ffffffffc02041a8:	11600593          	li	a1,278
ffffffffc02041ac:	00009517          	auipc	a0,0x9
ffffffffc02041b0:	ddc50513          	addi	a0,a0,-548 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc02041b4:	87afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02041b8:	00009697          	auipc	a3,0x9
ffffffffc02041bc:	10068693          	addi	a3,a3,256 # ffffffffc020d2b8 <commands+0x17e8>
ffffffffc02041c0:	00008617          	auipc	a2,0x8
ffffffffc02041c4:	b6060613          	addi	a2,a2,-1184 # ffffffffc020bd20 <commands+0x250>
ffffffffc02041c8:	12500593          	li	a1,293
ffffffffc02041cc:	00009517          	auipc	a0,0x9
ffffffffc02041d0:	dbc50513          	addi	a0,a0,-580 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc02041d4:	85afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02041d8:	00009697          	auipc	a3,0x9
ffffffffc02041dc:	dc868693          	addi	a3,a3,-568 # ffffffffc020cfa0 <commands+0x14d0>
ffffffffc02041e0:	00008617          	auipc	a2,0x8
ffffffffc02041e4:	b4060613          	addi	a2,a2,-1216 # ffffffffc020bd20 <commands+0x250>
ffffffffc02041e8:	0f200593          	li	a1,242
ffffffffc02041ec:	00009517          	auipc	a0,0x9
ffffffffc02041f0:	d9c50513          	addi	a0,a0,-612 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc02041f4:	83afc0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02041f8:	00009697          	auipc	a3,0x9
ffffffffc02041fc:	de868693          	addi	a3,a3,-536 # ffffffffc020cfe0 <commands+0x1510>
ffffffffc0204200:	00008617          	auipc	a2,0x8
ffffffffc0204204:	b2060613          	addi	a2,a2,-1248 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204208:	0b900593          	li	a1,185
ffffffffc020420c:	00009517          	auipc	a0,0x9
ffffffffc0204210:	d7c50513          	addi	a0,a0,-644 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204214:	81afc0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204218 <default_free_pages>:
ffffffffc0204218:	1141                	addi	sp,sp,-16
ffffffffc020421a:	e406                	sd	ra,8(sp)
ffffffffc020421c:	14058463          	beqz	a1,ffffffffc0204364 <default_free_pages+0x14c>
ffffffffc0204220:	00659693          	slli	a3,a1,0x6
ffffffffc0204224:	96aa                	add	a3,a3,a0
ffffffffc0204226:	87aa                	mv	a5,a0
ffffffffc0204228:	02d50263          	beq	a0,a3,ffffffffc020424c <default_free_pages+0x34>
ffffffffc020422c:	6798                	ld	a4,8(a5)
ffffffffc020422e:	8b05                	andi	a4,a4,1
ffffffffc0204230:	10071a63          	bnez	a4,ffffffffc0204344 <default_free_pages+0x12c>
ffffffffc0204234:	6798                	ld	a4,8(a5)
ffffffffc0204236:	8b09                	andi	a4,a4,2
ffffffffc0204238:	10071663          	bnez	a4,ffffffffc0204344 <default_free_pages+0x12c>
ffffffffc020423c:	0007b423          	sd	zero,8(a5)
ffffffffc0204240:	0007a023          	sw	zero,0(a5)
ffffffffc0204244:	04078793          	addi	a5,a5,64
ffffffffc0204248:	fed792e3          	bne	a5,a3,ffffffffc020422c <default_free_pages+0x14>
ffffffffc020424c:	2581                	sext.w	a1,a1
ffffffffc020424e:	c90c                	sw	a1,16(a0)
ffffffffc0204250:	00850893          	addi	a7,a0,8
ffffffffc0204254:	4789                	li	a5,2
ffffffffc0204256:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc020425a:	0008d697          	auipc	a3,0x8d
ffffffffc020425e:	54e68693          	addi	a3,a3,1358 # ffffffffc02917a8 <free_area>
ffffffffc0204262:	4a98                	lw	a4,16(a3)
ffffffffc0204264:	669c                	ld	a5,8(a3)
ffffffffc0204266:	01850613          	addi	a2,a0,24
ffffffffc020426a:	9db9                	addw	a1,a1,a4
ffffffffc020426c:	ca8c                	sw	a1,16(a3)
ffffffffc020426e:	0ad78463          	beq	a5,a3,ffffffffc0204316 <default_free_pages+0xfe>
ffffffffc0204272:	fe878713          	addi	a4,a5,-24
ffffffffc0204276:	0006b803          	ld	a6,0(a3)
ffffffffc020427a:	4581                	li	a1,0
ffffffffc020427c:	00e56a63          	bltu	a0,a4,ffffffffc0204290 <default_free_pages+0x78>
ffffffffc0204280:	6798                	ld	a4,8(a5)
ffffffffc0204282:	04d70c63          	beq	a4,a3,ffffffffc02042da <default_free_pages+0xc2>
ffffffffc0204286:	87ba                	mv	a5,a4
ffffffffc0204288:	fe878713          	addi	a4,a5,-24
ffffffffc020428c:	fee57ae3          	bgeu	a0,a4,ffffffffc0204280 <default_free_pages+0x68>
ffffffffc0204290:	c199                	beqz	a1,ffffffffc0204296 <default_free_pages+0x7e>
ffffffffc0204292:	0106b023          	sd	a6,0(a3)
ffffffffc0204296:	6398                	ld	a4,0(a5)
ffffffffc0204298:	e390                	sd	a2,0(a5)
ffffffffc020429a:	e710                	sd	a2,8(a4)
ffffffffc020429c:	f11c                	sd	a5,32(a0)
ffffffffc020429e:	ed18                	sd	a4,24(a0)
ffffffffc02042a0:	00d70d63          	beq	a4,a3,ffffffffc02042ba <default_free_pages+0xa2>
ffffffffc02042a4:	ff872583          	lw	a1,-8(a4) # ff8 <_binary_bin_swap_img_size-0x6d08>
ffffffffc02042a8:	fe870613          	addi	a2,a4,-24
ffffffffc02042ac:	02059813          	slli	a6,a1,0x20
ffffffffc02042b0:	01a85793          	srli	a5,a6,0x1a
ffffffffc02042b4:	97b2                	add	a5,a5,a2
ffffffffc02042b6:	02f50c63          	beq	a0,a5,ffffffffc02042ee <default_free_pages+0xd6>
ffffffffc02042ba:	711c                	ld	a5,32(a0)
ffffffffc02042bc:	00d78c63          	beq	a5,a3,ffffffffc02042d4 <default_free_pages+0xbc>
ffffffffc02042c0:	4910                	lw	a2,16(a0)
ffffffffc02042c2:	fe878693          	addi	a3,a5,-24
ffffffffc02042c6:	02061593          	slli	a1,a2,0x20
ffffffffc02042ca:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02042ce:	972a                	add	a4,a4,a0
ffffffffc02042d0:	04e68a63          	beq	a3,a4,ffffffffc0204324 <default_free_pages+0x10c>
ffffffffc02042d4:	60a2                	ld	ra,8(sp)
ffffffffc02042d6:	0141                	addi	sp,sp,16
ffffffffc02042d8:	8082                	ret
ffffffffc02042da:	e790                	sd	a2,8(a5)
ffffffffc02042dc:	f114                	sd	a3,32(a0)
ffffffffc02042de:	6798                	ld	a4,8(a5)
ffffffffc02042e0:	ed1c                	sd	a5,24(a0)
ffffffffc02042e2:	02d70763          	beq	a4,a3,ffffffffc0204310 <default_free_pages+0xf8>
ffffffffc02042e6:	8832                	mv	a6,a2
ffffffffc02042e8:	4585                	li	a1,1
ffffffffc02042ea:	87ba                	mv	a5,a4
ffffffffc02042ec:	bf71                	j	ffffffffc0204288 <default_free_pages+0x70>
ffffffffc02042ee:	491c                	lw	a5,16(a0)
ffffffffc02042f0:	9dbd                	addw	a1,a1,a5
ffffffffc02042f2:	feb72c23          	sw	a1,-8(a4)
ffffffffc02042f6:	57f5                	li	a5,-3
ffffffffc02042f8:	60f8b02f          	amoand.d	zero,a5,(a7)
ffffffffc02042fc:	01853803          	ld	a6,24(a0)
ffffffffc0204300:	710c                	ld	a1,32(a0)
ffffffffc0204302:	8532                	mv	a0,a2
ffffffffc0204304:	00b83423          	sd	a1,8(a6)
ffffffffc0204308:	671c                	ld	a5,8(a4)
ffffffffc020430a:	0105b023          	sd	a6,0(a1) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc020430e:	b77d                	j	ffffffffc02042bc <default_free_pages+0xa4>
ffffffffc0204310:	e290                	sd	a2,0(a3)
ffffffffc0204312:	873e                	mv	a4,a5
ffffffffc0204314:	bf41                	j	ffffffffc02042a4 <default_free_pages+0x8c>
ffffffffc0204316:	60a2                	ld	ra,8(sp)
ffffffffc0204318:	e390                	sd	a2,0(a5)
ffffffffc020431a:	e790                	sd	a2,8(a5)
ffffffffc020431c:	f11c                	sd	a5,32(a0)
ffffffffc020431e:	ed1c                	sd	a5,24(a0)
ffffffffc0204320:	0141                	addi	sp,sp,16
ffffffffc0204322:	8082                	ret
ffffffffc0204324:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204328:	ff078693          	addi	a3,a5,-16
ffffffffc020432c:	9e39                	addw	a2,a2,a4
ffffffffc020432e:	c910                	sw	a2,16(a0)
ffffffffc0204330:	5775                	li	a4,-3
ffffffffc0204332:	60e6b02f          	amoand.d	zero,a4,(a3)
ffffffffc0204336:	6398                	ld	a4,0(a5)
ffffffffc0204338:	679c                	ld	a5,8(a5)
ffffffffc020433a:	60a2                	ld	ra,8(sp)
ffffffffc020433c:	e71c                	sd	a5,8(a4)
ffffffffc020433e:	e398                	sd	a4,0(a5)
ffffffffc0204340:	0141                	addi	sp,sp,16
ffffffffc0204342:	8082                	ret
ffffffffc0204344:	00009697          	auipc	a3,0x9
ffffffffc0204348:	f8c68693          	addi	a3,a3,-116 # ffffffffc020d2d0 <commands+0x1800>
ffffffffc020434c:	00008617          	auipc	a2,0x8
ffffffffc0204350:	9d460613          	addi	a2,a2,-1580 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204354:	08200593          	li	a1,130
ffffffffc0204358:	00009517          	auipc	a0,0x9
ffffffffc020435c:	c3050513          	addi	a0,a0,-976 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204360:	ecffb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204364:	00009697          	auipc	a3,0x9
ffffffffc0204368:	f6468693          	addi	a3,a3,-156 # ffffffffc020d2c8 <commands+0x17f8>
ffffffffc020436c:	00008617          	auipc	a2,0x8
ffffffffc0204370:	9b460613          	addi	a2,a2,-1612 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204374:	07f00593          	li	a1,127
ffffffffc0204378:	00009517          	auipc	a0,0x9
ffffffffc020437c:	c1050513          	addi	a0,a0,-1008 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204380:	eaffb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204384 <default_alloc_pages>:
ffffffffc0204384:	c941                	beqz	a0,ffffffffc0204414 <default_alloc_pages+0x90>
ffffffffc0204386:	0008d597          	auipc	a1,0x8d
ffffffffc020438a:	42258593          	addi	a1,a1,1058 # ffffffffc02917a8 <free_area>
ffffffffc020438e:	0105a803          	lw	a6,16(a1)
ffffffffc0204392:	872a                	mv	a4,a0
ffffffffc0204394:	02081793          	slli	a5,a6,0x20
ffffffffc0204398:	9381                	srli	a5,a5,0x20
ffffffffc020439a:	00a7ee63          	bltu	a5,a0,ffffffffc02043b6 <default_alloc_pages+0x32>
ffffffffc020439e:	87ae                	mv	a5,a1
ffffffffc02043a0:	a801                	j	ffffffffc02043b0 <default_alloc_pages+0x2c>
ffffffffc02043a2:	ff87a683          	lw	a3,-8(a5)
ffffffffc02043a6:	02069613          	slli	a2,a3,0x20
ffffffffc02043aa:	9201                	srli	a2,a2,0x20
ffffffffc02043ac:	00e67763          	bgeu	a2,a4,ffffffffc02043ba <default_alloc_pages+0x36>
ffffffffc02043b0:	679c                	ld	a5,8(a5)
ffffffffc02043b2:	feb798e3          	bne	a5,a1,ffffffffc02043a2 <default_alloc_pages+0x1e>
ffffffffc02043b6:	4501                	li	a0,0
ffffffffc02043b8:	8082                	ret
ffffffffc02043ba:	0007b883          	ld	a7,0(a5)
ffffffffc02043be:	0087b303          	ld	t1,8(a5)
ffffffffc02043c2:	fe878513          	addi	a0,a5,-24
ffffffffc02043c6:	00070e1b          	sext.w	t3,a4
ffffffffc02043ca:	0068b423          	sd	t1,8(a7) # 80008 <_binary_bin_sfs_img_size+0xad08>
ffffffffc02043ce:	01133023          	sd	a7,0(t1) # 80000 <_binary_bin_sfs_img_size+0xad00>
ffffffffc02043d2:	02c77863          	bgeu	a4,a2,ffffffffc0204402 <default_alloc_pages+0x7e>
ffffffffc02043d6:	071a                	slli	a4,a4,0x6
ffffffffc02043d8:	972a                	add	a4,a4,a0
ffffffffc02043da:	41c686bb          	subw	a3,a3,t3
ffffffffc02043de:	cb14                	sw	a3,16(a4)
ffffffffc02043e0:	00870613          	addi	a2,a4,8
ffffffffc02043e4:	4689                	li	a3,2
ffffffffc02043e6:	40d6302f          	amoor.d	zero,a3,(a2)
ffffffffc02043ea:	0088b683          	ld	a3,8(a7)
ffffffffc02043ee:	01870613          	addi	a2,a4,24
ffffffffc02043f2:	0105a803          	lw	a6,16(a1)
ffffffffc02043f6:	e290                	sd	a2,0(a3)
ffffffffc02043f8:	00c8b423          	sd	a2,8(a7)
ffffffffc02043fc:	f314                	sd	a3,32(a4)
ffffffffc02043fe:	01173c23          	sd	a7,24(a4)
ffffffffc0204402:	41c8083b          	subw	a6,a6,t3
ffffffffc0204406:	0105a823          	sw	a6,16(a1)
ffffffffc020440a:	5775                	li	a4,-3
ffffffffc020440c:	17c1                	addi	a5,a5,-16
ffffffffc020440e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0204412:	8082                	ret
ffffffffc0204414:	1141                	addi	sp,sp,-16
ffffffffc0204416:	00009697          	auipc	a3,0x9
ffffffffc020441a:	eb268693          	addi	a3,a3,-334 # ffffffffc020d2c8 <commands+0x17f8>
ffffffffc020441e:	00008617          	auipc	a2,0x8
ffffffffc0204422:	90260613          	addi	a2,a2,-1790 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204426:	06100593          	li	a1,97
ffffffffc020442a:	00009517          	auipc	a0,0x9
ffffffffc020442e:	b5e50513          	addi	a0,a0,-1186 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204432:	e406                	sd	ra,8(sp)
ffffffffc0204434:	dfbfb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204438 <default_init_memmap>:
ffffffffc0204438:	1141                	addi	sp,sp,-16
ffffffffc020443a:	e406                	sd	ra,8(sp)
ffffffffc020443c:	c5f1                	beqz	a1,ffffffffc0204508 <default_init_memmap+0xd0>
ffffffffc020443e:	00659693          	slli	a3,a1,0x6
ffffffffc0204442:	96aa                	add	a3,a3,a0
ffffffffc0204444:	87aa                	mv	a5,a0
ffffffffc0204446:	00d50f63          	beq	a0,a3,ffffffffc0204464 <default_init_memmap+0x2c>
ffffffffc020444a:	6798                	ld	a4,8(a5)
ffffffffc020444c:	8b05                	andi	a4,a4,1
ffffffffc020444e:	cf49                	beqz	a4,ffffffffc02044e8 <default_init_memmap+0xb0>
ffffffffc0204450:	0007a823          	sw	zero,16(a5)
ffffffffc0204454:	0007b423          	sd	zero,8(a5)
ffffffffc0204458:	0007a023          	sw	zero,0(a5)
ffffffffc020445c:	04078793          	addi	a5,a5,64
ffffffffc0204460:	fed795e3          	bne	a5,a3,ffffffffc020444a <default_init_memmap+0x12>
ffffffffc0204464:	2581                	sext.w	a1,a1
ffffffffc0204466:	c90c                	sw	a1,16(a0)
ffffffffc0204468:	4789                	li	a5,2
ffffffffc020446a:	00850713          	addi	a4,a0,8
ffffffffc020446e:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0204472:	0008d697          	auipc	a3,0x8d
ffffffffc0204476:	33668693          	addi	a3,a3,822 # ffffffffc02917a8 <free_area>
ffffffffc020447a:	4a98                	lw	a4,16(a3)
ffffffffc020447c:	669c                	ld	a5,8(a3)
ffffffffc020447e:	01850613          	addi	a2,a0,24
ffffffffc0204482:	9db9                	addw	a1,a1,a4
ffffffffc0204484:	ca8c                	sw	a1,16(a3)
ffffffffc0204486:	04d78a63          	beq	a5,a3,ffffffffc02044da <default_init_memmap+0xa2>
ffffffffc020448a:	fe878713          	addi	a4,a5,-24
ffffffffc020448e:	0006b803          	ld	a6,0(a3)
ffffffffc0204492:	4581                	li	a1,0
ffffffffc0204494:	00e56a63          	bltu	a0,a4,ffffffffc02044a8 <default_init_memmap+0x70>
ffffffffc0204498:	6798                	ld	a4,8(a5)
ffffffffc020449a:	02d70263          	beq	a4,a3,ffffffffc02044be <default_init_memmap+0x86>
ffffffffc020449e:	87ba                	mv	a5,a4
ffffffffc02044a0:	fe878713          	addi	a4,a5,-24
ffffffffc02044a4:	fee57ae3          	bgeu	a0,a4,ffffffffc0204498 <default_init_memmap+0x60>
ffffffffc02044a8:	c199                	beqz	a1,ffffffffc02044ae <default_init_memmap+0x76>
ffffffffc02044aa:	0106b023          	sd	a6,0(a3)
ffffffffc02044ae:	6398                	ld	a4,0(a5)
ffffffffc02044b0:	60a2                	ld	ra,8(sp)
ffffffffc02044b2:	e390                	sd	a2,0(a5)
ffffffffc02044b4:	e710                	sd	a2,8(a4)
ffffffffc02044b6:	f11c                	sd	a5,32(a0)
ffffffffc02044b8:	ed18                	sd	a4,24(a0)
ffffffffc02044ba:	0141                	addi	sp,sp,16
ffffffffc02044bc:	8082                	ret
ffffffffc02044be:	e790                	sd	a2,8(a5)
ffffffffc02044c0:	f114                	sd	a3,32(a0)
ffffffffc02044c2:	6798                	ld	a4,8(a5)
ffffffffc02044c4:	ed1c                	sd	a5,24(a0)
ffffffffc02044c6:	00d70663          	beq	a4,a3,ffffffffc02044d2 <default_init_memmap+0x9a>
ffffffffc02044ca:	8832                	mv	a6,a2
ffffffffc02044cc:	4585                	li	a1,1
ffffffffc02044ce:	87ba                	mv	a5,a4
ffffffffc02044d0:	bfc1                	j	ffffffffc02044a0 <default_init_memmap+0x68>
ffffffffc02044d2:	60a2                	ld	ra,8(sp)
ffffffffc02044d4:	e290                	sd	a2,0(a3)
ffffffffc02044d6:	0141                	addi	sp,sp,16
ffffffffc02044d8:	8082                	ret
ffffffffc02044da:	60a2                	ld	ra,8(sp)
ffffffffc02044dc:	e390                	sd	a2,0(a5)
ffffffffc02044de:	e790                	sd	a2,8(a5)
ffffffffc02044e0:	f11c                	sd	a5,32(a0)
ffffffffc02044e2:	ed1c                	sd	a5,24(a0)
ffffffffc02044e4:	0141                	addi	sp,sp,16
ffffffffc02044e6:	8082                	ret
ffffffffc02044e8:	00009697          	auipc	a3,0x9
ffffffffc02044ec:	e1068693          	addi	a3,a3,-496 # ffffffffc020d2f8 <commands+0x1828>
ffffffffc02044f0:	00008617          	auipc	a2,0x8
ffffffffc02044f4:	83060613          	addi	a2,a2,-2000 # ffffffffc020bd20 <commands+0x250>
ffffffffc02044f8:	04800593          	li	a1,72
ffffffffc02044fc:	00009517          	auipc	a0,0x9
ffffffffc0204500:	a8c50513          	addi	a0,a0,-1396 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204504:	d2bfb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204508:	00009697          	auipc	a3,0x9
ffffffffc020450c:	dc068693          	addi	a3,a3,-576 # ffffffffc020d2c8 <commands+0x17f8>
ffffffffc0204510:	00008617          	auipc	a2,0x8
ffffffffc0204514:	81060613          	addi	a2,a2,-2032 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204518:	04500593          	li	a1,69
ffffffffc020451c:	00009517          	auipc	a0,0x9
ffffffffc0204520:	a6c50513          	addi	a0,a0,-1428 # ffffffffc020cf88 <commands+0x14b8>
ffffffffc0204524:	d0bfb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204528 <wait_queue_init>:
ffffffffc0204528:	e508                	sd	a0,8(a0)
ffffffffc020452a:	e108                	sd	a0,0(a0)
ffffffffc020452c:	8082                	ret

ffffffffc020452e <wait_queue_del>:
ffffffffc020452e:	7198                	ld	a4,32(a1)
ffffffffc0204530:	01858793          	addi	a5,a1,24
ffffffffc0204534:	00e78b63          	beq	a5,a4,ffffffffc020454a <wait_queue_del+0x1c>
ffffffffc0204538:	6994                	ld	a3,16(a1)
ffffffffc020453a:	00a69863          	bne	a3,a0,ffffffffc020454a <wait_queue_del+0x1c>
ffffffffc020453e:	6d94                	ld	a3,24(a1)
ffffffffc0204540:	e698                	sd	a4,8(a3)
ffffffffc0204542:	e314                	sd	a3,0(a4)
ffffffffc0204544:	f19c                	sd	a5,32(a1)
ffffffffc0204546:	ed9c                	sd	a5,24(a1)
ffffffffc0204548:	8082                	ret
ffffffffc020454a:	1141                	addi	sp,sp,-16
ffffffffc020454c:	00009697          	auipc	a3,0x9
ffffffffc0204550:	e5c68693          	addi	a3,a3,-420 # ffffffffc020d3a8 <default_pmm_manager+0x88>
ffffffffc0204554:	00007617          	auipc	a2,0x7
ffffffffc0204558:	7cc60613          	addi	a2,a2,1996 # ffffffffc020bd20 <commands+0x250>
ffffffffc020455c:	45f1                	li	a1,28
ffffffffc020455e:	00009517          	auipc	a0,0x9
ffffffffc0204562:	e3250513          	addi	a0,a0,-462 # ffffffffc020d390 <default_pmm_manager+0x70>
ffffffffc0204566:	e406                	sd	ra,8(sp)
ffffffffc0204568:	cc7fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020456c <wait_queue_first>:
ffffffffc020456c:	651c                	ld	a5,8(a0)
ffffffffc020456e:	00f50563          	beq	a0,a5,ffffffffc0204578 <wait_queue_first+0xc>
ffffffffc0204572:	fe878513          	addi	a0,a5,-24
ffffffffc0204576:	8082                	ret
ffffffffc0204578:	4501                	li	a0,0
ffffffffc020457a:	8082                	ret

ffffffffc020457c <wait_queue_empty>:
ffffffffc020457c:	651c                	ld	a5,8(a0)
ffffffffc020457e:	40a78533          	sub	a0,a5,a0
ffffffffc0204582:	00153513          	seqz	a0,a0
ffffffffc0204586:	8082                	ret

ffffffffc0204588 <wait_in_queue>:
ffffffffc0204588:	711c                	ld	a5,32(a0)
ffffffffc020458a:	0561                	addi	a0,a0,24
ffffffffc020458c:	40a78533          	sub	a0,a5,a0
ffffffffc0204590:	00a03533          	snez	a0,a0
ffffffffc0204594:	8082                	ret

ffffffffc0204596 <wakeup_wait>:
ffffffffc0204596:	e689                	bnez	a3,ffffffffc02045a0 <wakeup_wait+0xa>
ffffffffc0204598:	6188                	ld	a0,0(a1)
ffffffffc020459a:	c590                	sw	a2,8(a1)
ffffffffc020459c:	0060306f          	j	ffffffffc02075a2 <wakeup_proc>
ffffffffc02045a0:	7198                	ld	a4,32(a1)
ffffffffc02045a2:	01858793          	addi	a5,a1,24
ffffffffc02045a6:	00e78e63          	beq	a5,a4,ffffffffc02045c2 <wakeup_wait+0x2c>
ffffffffc02045aa:	6994                	ld	a3,16(a1)
ffffffffc02045ac:	00d51b63          	bne	a0,a3,ffffffffc02045c2 <wakeup_wait+0x2c>
ffffffffc02045b0:	6d94                	ld	a3,24(a1)
ffffffffc02045b2:	6188                	ld	a0,0(a1)
ffffffffc02045b4:	e698                	sd	a4,8(a3)
ffffffffc02045b6:	e314                	sd	a3,0(a4)
ffffffffc02045b8:	f19c                	sd	a5,32(a1)
ffffffffc02045ba:	ed9c                	sd	a5,24(a1)
ffffffffc02045bc:	c590                	sw	a2,8(a1)
ffffffffc02045be:	7e50206f          	j	ffffffffc02075a2 <wakeup_proc>
ffffffffc02045c2:	1141                	addi	sp,sp,-16
ffffffffc02045c4:	00009697          	auipc	a3,0x9
ffffffffc02045c8:	de468693          	addi	a3,a3,-540 # ffffffffc020d3a8 <default_pmm_manager+0x88>
ffffffffc02045cc:	00007617          	auipc	a2,0x7
ffffffffc02045d0:	75460613          	addi	a2,a2,1876 # ffffffffc020bd20 <commands+0x250>
ffffffffc02045d4:	45f1                	li	a1,28
ffffffffc02045d6:	00009517          	auipc	a0,0x9
ffffffffc02045da:	dba50513          	addi	a0,a0,-582 # ffffffffc020d390 <default_pmm_manager+0x70>
ffffffffc02045de:	e406                	sd	ra,8(sp)
ffffffffc02045e0:	c4ffb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02045e4 <wakeup_queue>:
ffffffffc02045e4:	651c                	ld	a5,8(a0)
ffffffffc02045e6:	0ca78563          	beq	a5,a0,ffffffffc02046b0 <wakeup_queue+0xcc>
ffffffffc02045ea:	1101                	addi	sp,sp,-32
ffffffffc02045ec:	e822                	sd	s0,16(sp)
ffffffffc02045ee:	e426                	sd	s1,8(sp)
ffffffffc02045f0:	e04a                	sd	s2,0(sp)
ffffffffc02045f2:	ec06                	sd	ra,24(sp)
ffffffffc02045f4:	84aa                	mv	s1,a0
ffffffffc02045f6:	892e                	mv	s2,a1
ffffffffc02045f8:	fe878413          	addi	s0,a5,-24
ffffffffc02045fc:	e23d                	bnez	a2,ffffffffc0204662 <wakeup_queue+0x7e>
ffffffffc02045fe:	6008                	ld	a0,0(s0)
ffffffffc0204600:	01242423          	sw	s2,8(s0)
ffffffffc0204604:	79f020ef          	jal	ra,ffffffffc02075a2 <wakeup_proc>
ffffffffc0204608:	701c                	ld	a5,32(s0)
ffffffffc020460a:	01840713          	addi	a4,s0,24
ffffffffc020460e:	02e78463          	beq	a5,a4,ffffffffc0204636 <wakeup_queue+0x52>
ffffffffc0204612:	6818                	ld	a4,16(s0)
ffffffffc0204614:	02e49163          	bne	s1,a4,ffffffffc0204636 <wakeup_queue+0x52>
ffffffffc0204618:	02f48f63          	beq	s1,a5,ffffffffc0204656 <wakeup_queue+0x72>
ffffffffc020461c:	fe87b503          	ld	a0,-24(a5)
ffffffffc0204620:	ff27a823          	sw	s2,-16(a5)
ffffffffc0204624:	fe878413          	addi	s0,a5,-24
ffffffffc0204628:	77b020ef          	jal	ra,ffffffffc02075a2 <wakeup_proc>
ffffffffc020462c:	701c                	ld	a5,32(s0)
ffffffffc020462e:	01840713          	addi	a4,s0,24
ffffffffc0204632:	fee790e3          	bne	a5,a4,ffffffffc0204612 <wakeup_queue+0x2e>
ffffffffc0204636:	00009697          	auipc	a3,0x9
ffffffffc020463a:	d7268693          	addi	a3,a3,-654 # ffffffffc020d3a8 <default_pmm_manager+0x88>
ffffffffc020463e:	00007617          	auipc	a2,0x7
ffffffffc0204642:	6e260613          	addi	a2,a2,1762 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204646:	02200593          	li	a1,34
ffffffffc020464a:	00009517          	auipc	a0,0x9
ffffffffc020464e:	d4650513          	addi	a0,a0,-698 # ffffffffc020d390 <default_pmm_manager+0x70>
ffffffffc0204652:	bddfb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204656:	60e2                	ld	ra,24(sp)
ffffffffc0204658:	6442                	ld	s0,16(sp)
ffffffffc020465a:	64a2                	ld	s1,8(sp)
ffffffffc020465c:	6902                	ld	s2,0(sp)
ffffffffc020465e:	6105                	addi	sp,sp,32
ffffffffc0204660:	8082                	ret
ffffffffc0204662:	6798                	ld	a4,8(a5)
ffffffffc0204664:	02f70763          	beq	a4,a5,ffffffffc0204692 <wakeup_queue+0xae>
ffffffffc0204668:	6814                	ld	a3,16(s0)
ffffffffc020466a:	02d49463          	bne	s1,a3,ffffffffc0204692 <wakeup_queue+0xae>
ffffffffc020466e:	6c14                	ld	a3,24(s0)
ffffffffc0204670:	6008                	ld	a0,0(s0)
ffffffffc0204672:	e698                	sd	a4,8(a3)
ffffffffc0204674:	e314                	sd	a3,0(a4)
ffffffffc0204676:	f01c                	sd	a5,32(s0)
ffffffffc0204678:	ec1c                	sd	a5,24(s0)
ffffffffc020467a:	01242423          	sw	s2,8(s0)
ffffffffc020467e:	725020ef          	jal	ra,ffffffffc02075a2 <wakeup_proc>
ffffffffc0204682:	6480                	ld	s0,8(s1)
ffffffffc0204684:	fc8489e3          	beq	s1,s0,ffffffffc0204656 <wakeup_queue+0x72>
ffffffffc0204688:	6418                	ld	a4,8(s0)
ffffffffc020468a:	87a2                	mv	a5,s0
ffffffffc020468c:	1421                	addi	s0,s0,-24
ffffffffc020468e:	fce79de3          	bne	a5,a4,ffffffffc0204668 <wakeup_queue+0x84>
ffffffffc0204692:	00009697          	auipc	a3,0x9
ffffffffc0204696:	d1668693          	addi	a3,a3,-746 # ffffffffc020d3a8 <default_pmm_manager+0x88>
ffffffffc020469a:	00007617          	auipc	a2,0x7
ffffffffc020469e:	68660613          	addi	a2,a2,1670 # ffffffffc020bd20 <commands+0x250>
ffffffffc02046a2:	45f1                	li	a1,28
ffffffffc02046a4:	00009517          	auipc	a0,0x9
ffffffffc02046a8:	cec50513          	addi	a0,a0,-788 # ffffffffc020d390 <default_pmm_manager+0x70>
ffffffffc02046ac:	b83fb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02046b0:	8082                	ret

ffffffffc02046b2 <wait_current_set>:
ffffffffc02046b2:	00092797          	auipc	a5,0x92
ffffffffc02046b6:	2567b783          	ld	a5,598(a5) # ffffffffc0296908 <current>
ffffffffc02046ba:	c39d                	beqz	a5,ffffffffc02046e0 <wait_current_set+0x2e>
ffffffffc02046bc:	01858713          	addi	a4,a1,24
ffffffffc02046c0:	800006b7          	lui	a3,0x80000
ffffffffc02046c4:	ed98                	sd	a4,24(a1)
ffffffffc02046c6:	e19c                	sd	a5,0(a1)
ffffffffc02046c8:	c594                	sw	a3,8(a1)
ffffffffc02046ca:	4685                	li	a3,1
ffffffffc02046cc:	c394                	sw	a3,0(a5)
ffffffffc02046ce:	0ec7a623          	sw	a2,236(a5)
ffffffffc02046d2:	611c                	ld	a5,0(a0)
ffffffffc02046d4:	e988                	sd	a0,16(a1)
ffffffffc02046d6:	e118                	sd	a4,0(a0)
ffffffffc02046d8:	e798                	sd	a4,8(a5)
ffffffffc02046da:	f188                	sd	a0,32(a1)
ffffffffc02046dc:	ed9c                	sd	a5,24(a1)
ffffffffc02046de:	8082                	ret
ffffffffc02046e0:	1141                	addi	sp,sp,-16
ffffffffc02046e2:	00009697          	auipc	a3,0x9
ffffffffc02046e6:	d0668693          	addi	a3,a3,-762 # ffffffffc020d3e8 <default_pmm_manager+0xc8>
ffffffffc02046ea:	00007617          	auipc	a2,0x7
ffffffffc02046ee:	63660613          	addi	a2,a2,1590 # ffffffffc020bd20 <commands+0x250>
ffffffffc02046f2:	07400593          	li	a1,116
ffffffffc02046f6:	00009517          	auipc	a0,0x9
ffffffffc02046fa:	c9a50513          	addi	a0,a0,-870 # ffffffffc020d390 <default_pmm_manager+0x70>
ffffffffc02046fe:	e406                	sd	ra,8(sp)
ffffffffc0204700:	b2ffb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204704 <__down.constprop.0>:
ffffffffc0204704:	715d                	addi	sp,sp,-80
ffffffffc0204706:	e0a2                	sd	s0,64(sp)
ffffffffc0204708:	e486                	sd	ra,72(sp)
ffffffffc020470a:	fc26                	sd	s1,56(sp)
ffffffffc020470c:	842a                	mv	s0,a0
ffffffffc020470e:	100027f3          	csrr	a5,sstatus
ffffffffc0204712:	8b89                	andi	a5,a5,2
ffffffffc0204714:	ebb1                	bnez	a5,ffffffffc0204768 <__down.constprop.0+0x64>
ffffffffc0204716:	411c                	lw	a5,0(a0)
ffffffffc0204718:	00f05a63          	blez	a5,ffffffffc020472c <__down.constprop.0+0x28>
ffffffffc020471c:	37fd                	addiw	a5,a5,-1
ffffffffc020471e:	c11c                	sw	a5,0(a0)
ffffffffc0204720:	4501                	li	a0,0
ffffffffc0204722:	60a6                	ld	ra,72(sp)
ffffffffc0204724:	6406                	ld	s0,64(sp)
ffffffffc0204726:	74e2                	ld	s1,56(sp)
ffffffffc0204728:	6161                	addi	sp,sp,80
ffffffffc020472a:	8082                	ret
ffffffffc020472c:	00850413          	addi	s0,a0,8
ffffffffc0204730:	0024                	addi	s1,sp,8
ffffffffc0204732:	10000613          	li	a2,256
ffffffffc0204736:	85a6                	mv	a1,s1
ffffffffc0204738:	8522                	mv	a0,s0
ffffffffc020473a:	f79ff0ef          	jal	ra,ffffffffc02046b2 <wait_current_set>
ffffffffc020473e:	717020ef          	jal	ra,ffffffffc0207654 <schedule>
ffffffffc0204742:	100027f3          	csrr	a5,sstatus
ffffffffc0204746:	8b89                	andi	a5,a5,2
ffffffffc0204748:	efb9                	bnez	a5,ffffffffc02047a6 <__down.constprop.0+0xa2>
ffffffffc020474a:	8526                	mv	a0,s1
ffffffffc020474c:	e3dff0ef          	jal	ra,ffffffffc0204588 <wait_in_queue>
ffffffffc0204750:	e531                	bnez	a0,ffffffffc020479c <__down.constprop.0+0x98>
ffffffffc0204752:	4542                	lw	a0,16(sp)
ffffffffc0204754:	10000793          	li	a5,256
ffffffffc0204758:	fcf515e3          	bne	a0,a5,ffffffffc0204722 <__down.constprop.0+0x1e>
ffffffffc020475c:	60a6                	ld	ra,72(sp)
ffffffffc020475e:	6406                	ld	s0,64(sp)
ffffffffc0204760:	74e2                	ld	s1,56(sp)
ffffffffc0204762:	4501                	li	a0,0
ffffffffc0204764:	6161                	addi	sp,sp,80
ffffffffc0204766:	8082                	ret
ffffffffc0204768:	e38fc0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020476c:	401c                	lw	a5,0(s0)
ffffffffc020476e:	00f05c63          	blez	a5,ffffffffc0204786 <__down.constprop.0+0x82>
ffffffffc0204772:	37fd                	addiw	a5,a5,-1
ffffffffc0204774:	c01c                	sw	a5,0(s0)
ffffffffc0204776:	e24fc0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020477a:	60a6                	ld	ra,72(sp)
ffffffffc020477c:	6406                	ld	s0,64(sp)
ffffffffc020477e:	74e2                	ld	s1,56(sp)
ffffffffc0204780:	4501                	li	a0,0
ffffffffc0204782:	6161                	addi	sp,sp,80
ffffffffc0204784:	8082                	ret
ffffffffc0204786:	0421                	addi	s0,s0,8
ffffffffc0204788:	0024                	addi	s1,sp,8
ffffffffc020478a:	10000613          	li	a2,256
ffffffffc020478e:	85a6                	mv	a1,s1
ffffffffc0204790:	8522                	mv	a0,s0
ffffffffc0204792:	f21ff0ef          	jal	ra,ffffffffc02046b2 <wait_current_set>
ffffffffc0204796:	e04fc0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020479a:	b755                	j	ffffffffc020473e <__down.constprop.0+0x3a>
ffffffffc020479c:	85a6                	mv	a1,s1
ffffffffc020479e:	8522                	mv	a0,s0
ffffffffc02047a0:	d8fff0ef          	jal	ra,ffffffffc020452e <wait_queue_del>
ffffffffc02047a4:	b77d                	j	ffffffffc0204752 <__down.constprop.0+0x4e>
ffffffffc02047a6:	dfafc0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02047aa:	8526                	mv	a0,s1
ffffffffc02047ac:	dddff0ef          	jal	ra,ffffffffc0204588 <wait_in_queue>
ffffffffc02047b0:	e501                	bnez	a0,ffffffffc02047b8 <__down.constprop.0+0xb4>
ffffffffc02047b2:	de8fc0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02047b6:	bf71                	j	ffffffffc0204752 <__down.constprop.0+0x4e>
ffffffffc02047b8:	85a6                	mv	a1,s1
ffffffffc02047ba:	8522                	mv	a0,s0
ffffffffc02047bc:	d73ff0ef          	jal	ra,ffffffffc020452e <wait_queue_del>
ffffffffc02047c0:	bfcd                	j	ffffffffc02047b2 <__down.constprop.0+0xae>

ffffffffc02047c2 <__up.constprop.0>:
ffffffffc02047c2:	1101                	addi	sp,sp,-32
ffffffffc02047c4:	e822                	sd	s0,16(sp)
ffffffffc02047c6:	ec06                	sd	ra,24(sp)
ffffffffc02047c8:	e426                	sd	s1,8(sp)
ffffffffc02047ca:	e04a                	sd	s2,0(sp)
ffffffffc02047cc:	842a                	mv	s0,a0
ffffffffc02047ce:	100027f3          	csrr	a5,sstatus
ffffffffc02047d2:	8b89                	andi	a5,a5,2
ffffffffc02047d4:	4901                	li	s2,0
ffffffffc02047d6:	eba1                	bnez	a5,ffffffffc0204826 <__up.constprop.0+0x64>
ffffffffc02047d8:	00840493          	addi	s1,s0,8
ffffffffc02047dc:	8526                	mv	a0,s1
ffffffffc02047de:	d8fff0ef          	jal	ra,ffffffffc020456c <wait_queue_first>
ffffffffc02047e2:	85aa                	mv	a1,a0
ffffffffc02047e4:	cd0d                	beqz	a0,ffffffffc020481e <__up.constprop.0+0x5c>
ffffffffc02047e6:	6118                	ld	a4,0(a0)
ffffffffc02047e8:	10000793          	li	a5,256
ffffffffc02047ec:	0ec72703          	lw	a4,236(a4)
ffffffffc02047f0:	02f71f63          	bne	a4,a5,ffffffffc020482e <__up.constprop.0+0x6c>
ffffffffc02047f4:	4685                	li	a3,1
ffffffffc02047f6:	10000613          	li	a2,256
ffffffffc02047fa:	8526                	mv	a0,s1
ffffffffc02047fc:	d9bff0ef          	jal	ra,ffffffffc0204596 <wakeup_wait>
ffffffffc0204800:	00091863          	bnez	s2,ffffffffc0204810 <__up.constprop.0+0x4e>
ffffffffc0204804:	60e2                	ld	ra,24(sp)
ffffffffc0204806:	6442                	ld	s0,16(sp)
ffffffffc0204808:	64a2                	ld	s1,8(sp)
ffffffffc020480a:	6902                	ld	s2,0(sp)
ffffffffc020480c:	6105                	addi	sp,sp,32
ffffffffc020480e:	8082                	ret
ffffffffc0204810:	6442                	ld	s0,16(sp)
ffffffffc0204812:	60e2                	ld	ra,24(sp)
ffffffffc0204814:	64a2                	ld	s1,8(sp)
ffffffffc0204816:	6902                	ld	s2,0(sp)
ffffffffc0204818:	6105                	addi	sp,sp,32
ffffffffc020481a:	d80fc06f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc020481e:	401c                	lw	a5,0(s0)
ffffffffc0204820:	2785                	addiw	a5,a5,1
ffffffffc0204822:	c01c                	sw	a5,0(s0)
ffffffffc0204824:	bff1                	j	ffffffffc0204800 <__up.constprop.0+0x3e>
ffffffffc0204826:	d7afc0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020482a:	4905                	li	s2,1
ffffffffc020482c:	b775                	j	ffffffffc02047d8 <__up.constprop.0+0x16>
ffffffffc020482e:	00009697          	auipc	a3,0x9
ffffffffc0204832:	bca68693          	addi	a3,a3,-1078 # ffffffffc020d3f8 <default_pmm_manager+0xd8>
ffffffffc0204836:	00007617          	auipc	a2,0x7
ffffffffc020483a:	4ea60613          	addi	a2,a2,1258 # ffffffffc020bd20 <commands+0x250>
ffffffffc020483e:	45e5                	li	a1,25
ffffffffc0204840:	00009517          	auipc	a0,0x9
ffffffffc0204844:	be050513          	addi	a0,a0,-1056 # ffffffffc020d420 <default_pmm_manager+0x100>
ffffffffc0204848:	9e7fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020484c <sem_init>:
ffffffffc020484c:	c10c                	sw	a1,0(a0)
ffffffffc020484e:	0521                	addi	a0,a0,8
ffffffffc0204850:	cd9ff06f          	j	ffffffffc0204528 <wait_queue_init>

ffffffffc0204854 <up>:
ffffffffc0204854:	f6fff06f          	j	ffffffffc02047c2 <__up.constprop.0>

ffffffffc0204858 <down>:
ffffffffc0204858:	1141                	addi	sp,sp,-16
ffffffffc020485a:	e406                	sd	ra,8(sp)
ffffffffc020485c:	ea9ff0ef          	jal	ra,ffffffffc0204704 <__down.constprop.0>
ffffffffc0204860:	2501                	sext.w	a0,a0
ffffffffc0204862:	e501                	bnez	a0,ffffffffc020486a <down+0x12>
ffffffffc0204864:	60a2                	ld	ra,8(sp)
ffffffffc0204866:	0141                	addi	sp,sp,16
ffffffffc0204868:	8082                	ret
ffffffffc020486a:	00009697          	auipc	a3,0x9
ffffffffc020486e:	bc668693          	addi	a3,a3,-1082 # ffffffffc020d430 <default_pmm_manager+0x110>
ffffffffc0204872:	00007617          	auipc	a2,0x7
ffffffffc0204876:	4ae60613          	addi	a2,a2,1198 # ffffffffc020bd20 <commands+0x250>
ffffffffc020487a:	04000593          	li	a1,64
ffffffffc020487e:	00009517          	auipc	a0,0x9
ffffffffc0204882:	ba250513          	addi	a0,a0,-1118 # ffffffffc020d420 <default_pmm_manager+0x100>
ffffffffc0204886:	9a9fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020488a <copy_path>:
ffffffffc020488a:	7139                	addi	sp,sp,-64
ffffffffc020488c:	f04a                	sd	s2,32(sp)
ffffffffc020488e:	00092917          	auipc	s2,0x92
ffffffffc0204892:	07a90913          	addi	s2,s2,122 # ffffffffc0296908 <current>
ffffffffc0204896:	00093703          	ld	a4,0(s2)
ffffffffc020489a:	ec4e                	sd	s3,24(sp)
ffffffffc020489c:	89aa                	mv	s3,a0
ffffffffc020489e:	6505                	lui	a0,0x1
ffffffffc02048a0:	f426                	sd	s1,40(sp)
ffffffffc02048a2:	e852                	sd	s4,16(sp)
ffffffffc02048a4:	fc06                	sd	ra,56(sp)
ffffffffc02048a6:	f822                	sd	s0,48(sp)
ffffffffc02048a8:	e456                	sd	s5,8(sp)
ffffffffc02048aa:	02873a03          	ld	s4,40(a4)
ffffffffc02048ae:	84ae                	mv	s1,a1
ffffffffc02048b0:	820ff0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc02048b4:	c141                	beqz	a0,ffffffffc0204934 <copy_path+0xaa>
ffffffffc02048b6:	842a                	mv	s0,a0
ffffffffc02048b8:	040a0563          	beqz	s4,ffffffffc0204902 <copy_path+0x78>
ffffffffc02048bc:	038a0a93          	addi	s5,s4,56
ffffffffc02048c0:	8556                	mv	a0,s5
ffffffffc02048c2:	f97ff0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc02048c6:	00093783          	ld	a5,0(s2)
ffffffffc02048ca:	cba1                	beqz	a5,ffffffffc020491a <copy_path+0x90>
ffffffffc02048cc:	43dc                	lw	a5,4(a5)
ffffffffc02048ce:	6685                	lui	a3,0x1
ffffffffc02048d0:	8626                	mv	a2,s1
ffffffffc02048d2:	04fa2823          	sw	a5,80(s4)
ffffffffc02048d6:	85a2                	mv	a1,s0
ffffffffc02048d8:	8552                	mv	a0,s4
ffffffffc02048da:	d3ffe0ef          	jal	ra,ffffffffc0203618 <copy_string>
ffffffffc02048de:	c529                	beqz	a0,ffffffffc0204928 <copy_path+0x9e>
ffffffffc02048e0:	8556                	mv	a0,s5
ffffffffc02048e2:	f73ff0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc02048e6:	040a2823          	sw	zero,80(s4)
ffffffffc02048ea:	0089b023          	sd	s0,0(s3)
ffffffffc02048ee:	4501                	li	a0,0
ffffffffc02048f0:	70e2                	ld	ra,56(sp)
ffffffffc02048f2:	7442                	ld	s0,48(sp)
ffffffffc02048f4:	74a2                	ld	s1,40(sp)
ffffffffc02048f6:	7902                	ld	s2,32(sp)
ffffffffc02048f8:	69e2                	ld	s3,24(sp)
ffffffffc02048fa:	6a42                	ld	s4,16(sp)
ffffffffc02048fc:	6aa2                	ld	s5,8(sp)
ffffffffc02048fe:	6121                	addi	sp,sp,64
ffffffffc0204900:	8082                	ret
ffffffffc0204902:	85aa                	mv	a1,a0
ffffffffc0204904:	6685                	lui	a3,0x1
ffffffffc0204906:	8626                	mv	a2,s1
ffffffffc0204908:	4501                	li	a0,0
ffffffffc020490a:	d0ffe0ef          	jal	ra,ffffffffc0203618 <copy_string>
ffffffffc020490e:	fd71                	bnez	a0,ffffffffc02048ea <copy_path+0x60>
ffffffffc0204910:	8522                	mv	a0,s0
ffffffffc0204912:	86eff0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0204916:	5575                	li	a0,-3
ffffffffc0204918:	bfe1                	j	ffffffffc02048f0 <copy_path+0x66>
ffffffffc020491a:	6685                	lui	a3,0x1
ffffffffc020491c:	8626                	mv	a2,s1
ffffffffc020491e:	85a2                	mv	a1,s0
ffffffffc0204920:	8552                	mv	a0,s4
ffffffffc0204922:	cf7fe0ef          	jal	ra,ffffffffc0203618 <copy_string>
ffffffffc0204926:	fd4d                	bnez	a0,ffffffffc02048e0 <copy_path+0x56>
ffffffffc0204928:	8556                	mv	a0,s5
ffffffffc020492a:	f2bff0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020492e:	040a2823          	sw	zero,80(s4)
ffffffffc0204932:	bff9                	j	ffffffffc0204910 <copy_path+0x86>
ffffffffc0204934:	5571                	li	a0,-4
ffffffffc0204936:	bf6d                	j	ffffffffc02048f0 <copy_path+0x66>

ffffffffc0204938 <sysfile_open>:
ffffffffc0204938:	7179                	addi	sp,sp,-48
ffffffffc020493a:	872a                	mv	a4,a0
ffffffffc020493c:	ec26                	sd	s1,24(sp)
ffffffffc020493e:	0028                	addi	a0,sp,8
ffffffffc0204940:	84ae                	mv	s1,a1
ffffffffc0204942:	85ba                	mv	a1,a4
ffffffffc0204944:	f022                	sd	s0,32(sp)
ffffffffc0204946:	f406                	sd	ra,40(sp)
ffffffffc0204948:	f43ff0ef          	jal	ra,ffffffffc020488a <copy_path>
ffffffffc020494c:	842a                	mv	s0,a0
ffffffffc020494e:	e909                	bnez	a0,ffffffffc0204960 <sysfile_open+0x28>
ffffffffc0204950:	6522                	ld	a0,8(sp)
ffffffffc0204952:	85a6                	mv	a1,s1
ffffffffc0204954:	7ba000ef          	jal	ra,ffffffffc020510e <file_open>
ffffffffc0204958:	842a                	mv	s0,a0
ffffffffc020495a:	6522                	ld	a0,8(sp)
ffffffffc020495c:	824ff0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0204960:	70a2                	ld	ra,40(sp)
ffffffffc0204962:	8522                	mv	a0,s0
ffffffffc0204964:	7402                	ld	s0,32(sp)
ffffffffc0204966:	64e2                	ld	s1,24(sp)
ffffffffc0204968:	6145                	addi	sp,sp,48
ffffffffc020496a:	8082                	ret

ffffffffc020496c <sysfile_close>:
ffffffffc020496c:	0a10006f          	j	ffffffffc020520c <file_close>

ffffffffc0204970 <sysfile_read>:
ffffffffc0204970:	7159                	addi	sp,sp,-112
ffffffffc0204972:	f0a2                	sd	s0,96(sp)
ffffffffc0204974:	f486                	sd	ra,104(sp)
ffffffffc0204976:	eca6                	sd	s1,88(sp)
ffffffffc0204978:	e8ca                	sd	s2,80(sp)
ffffffffc020497a:	e4ce                	sd	s3,72(sp)
ffffffffc020497c:	e0d2                	sd	s4,64(sp)
ffffffffc020497e:	fc56                	sd	s5,56(sp)
ffffffffc0204980:	f85a                	sd	s6,48(sp)
ffffffffc0204982:	f45e                	sd	s7,40(sp)
ffffffffc0204984:	f062                	sd	s8,32(sp)
ffffffffc0204986:	ec66                	sd	s9,24(sp)
ffffffffc0204988:	4401                	li	s0,0
ffffffffc020498a:	ee19                	bnez	a2,ffffffffc02049a8 <sysfile_read+0x38>
ffffffffc020498c:	70a6                	ld	ra,104(sp)
ffffffffc020498e:	8522                	mv	a0,s0
ffffffffc0204990:	7406                	ld	s0,96(sp)
ffffffffc0204992:	64e6                	ld	s1,88(sp)
ffffffffc0204994:	6946                	ld	s2,80(sp)
ffffffffc0204996:	69a6                	ld	s3,72(sp)
ffffffffc0204998:	6a06                	ld	s4,64(sp)
ffffffffc020499a:	7ae2                	ld	s5,56(sp)
ffffffffc020499c:	7b42                	ld	s6,48(sp)
ffffffffc020499e:	7ba2                	ld	s7,40(sp)
ffffffffc02049a0:	7c02                	ld	s8,32(sp)
ffffffffc02049a2:	6ce2                	ld	s9,24(sp)
ffffffffc02049a4:	6165                	addi	sp,sp,112
ffffffffc02049a6:	8082                	ret
ffffffffc02049a8:	00092c97          	auipc	s9,0x92
ffffffffc02049ac:	f60c8c93          	addi	s9,s9,-160 # ffffffffc0296908 <current>
ffffffffc02049b0:	000cb783          	ld	a5,0(s9)
ffffffffc02049b4:	84b2                	mv	s1,a2
ffffffffc02049b6:	8b2e                	mv	s6,a1
ffffffffc02049b8:	4601                	li	a2,0
ffffffffc02049ba:	4585                	li	a1,1
ffffffffc02049bc:	0287b903          	ld	s2,40(a5)
ffffffffc02049c0:	8aaa                	mv	s5,a0
ffffffffc02049c2:	6f8000ef          	jal	ra,ffffffffc02050ba <file_testfd>
ffffffffc02049c6:	c959                	beqz	a0,ffffffffc0204a5c <sysfile_read+0xec>
ffffffffc02049c8:	6505                	lui	a0,0x1
ffffffffc02049ca:	f07fe0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc02049ce:	89aa                	mv	s3,a0
ffffffffc02049d0:	c941                	beqz	a0,ffffffffc0204a60 <sysfile_read+0xf0>
ffffffffc02049d2:	4b81                	li	s7,0
ffffffffc02049d4:	6a05                	lui	s4,0x1
ffffffffc02049d6:	03890c13          	addi	s8,s2,56
ffffffffc02049da:	0744ec63          	bltu	s1,s4,ffffffffc0204a52 <sysfile_read+0xe2>
ffffffffc02049de:	e452                	sd	s4,8(sp)
ffffffffc02049e0:	6605                	lui	a2,0x1
ffffffffc02049e2:	0034                	addi	a3,sp,8
ffffffffc02049e4:	85ce                	mv	a1,s3
ffffffffc02049e6:	8556                	mv	a0,s5
ffffffffc02049e8:	07b000ef          	jal	ra,ffffffffc0205262 <file_read>
ffffffffc02049ec:	66a2                	ld	a3,8(sp)
ffffffffc02049ee:	842a                	mv	s0,a0
ffffffffc02049f0:	ca9d                	beqz	a3,ffffffffc0204a26 <sysfile_read+0xb6>
ffffffffc02049f2:	00090c63          	beqz	s2,ffffffffc0204a0a <sysfile_read+0x9a>
ffffffffc02049f6:	8562                	mv	a0,s8
ffffffffc02049f8:	e61ff0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc02049fc:	000cb783          	ld	a5,0(s9)
ffffffffc0204a00:	cfa1                	beqz	a5,ffffffffc0204a58 <sysfile_read+0xe8>
ffffffffc0204a02:	43dc                	lw	a5,4(a5)
ffffffffc0204a04:	66a2                	ld	a3,8(sp)
ffffffffc0204a06:	04f92823          	sw	a5,80(s2)
ffffffffc0204a0a:	864e                	mv	a2,s3
ffffffffc0204a0c:	85da                	mv	a1,s6
ffffffffc0204a0e:	854a                	mv	a0,s2
ffffffffc0204a10:	bd7fe0ef          	jal	ra,ffffffffc02035e6 <copy_to_user>
ffffffffc0204a14:	c50d                	beqz	a0,ffffffffc0204a3e <sysfile_read+0xce>
ffffffffc0204a16:	67a2                	ld	a5,8(sp)
ffffffffc0204a18:	04f4e663          	bltu	s1,a5,ffffffffc0204a64 <sysfile_read+0xf4>
ffffffffc0204a1c:	9b3e                	add	s6,s6,a5
ffffffffc0204a1e:	8c9d                	sub	s1,s1,a5
ffffffffc0204a20:	9bbe                	add	s7,s7,a5
ffffffffc0204a22:	02091263          	bnez	s2,ffffffffc0204a46 <sysfile_read+0xd6>
ffffffffc0204a26:	e401                	bnez	s0,ffffffffc0204a2e <sysfile_read+0xbe>
ffffffffc0204a28:	67a2                	ld	a5,8(sp)
ffffffffc0204a2a:	c391                	beqz	a5,ffffffffc0204a2e <sysfile_read+0xbe>
ffffffffc0204a2c:	f4dd                	bnez	s1,ffffffffc02049da <sysfile_read+0x6a>
ffffffffc0204a2e:	854e                	mv	a0,s3
ffffffffc0204a30:	f51fe0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0204a34:	f40b8ce3          	beqz	s7,ffffffffc020498c <sysfile_read+0x1c>
ffffffffc0204a38:	000b841b          	sext.w	s0,s7
ffffffffc0204a3c:	bf81                	j	ffffffffc020498c <sysfile_read+0x1c>
ffffffffc0204a3e:	e011                	bnez	s0,ffffffffc0204a42 <sysfile_read+0xd2>
ffffffffc0204a40:	5475                	li	s0,-3
ffffffffc0204a42:	fe0906e3          	beqz	s2,ffffffffc0204a2e <sysfile_read+0xbe>
ffffffffc0204a46:	8562                	mv	a0,s8
ffffffffc0204a48:	e0dff0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0204a4c:	04092823          	sw	zero,80(s2)
ffffffffc0204a50:	bfd9                	j	ffffffffc0204a26 <sysfile_read+0xb6>
ffffffffc0204a52:	e426                	sd	s1,8(sp)
ffffffffc0204a54:	8626                	mv	a2,s1
ffffffffc0204a56:	b771                	j	ffffffffc02049e2 <sysfile_read+0x72>
ffffffffc0204a58:	66a2                	ld	a3,8(sp)
ffffffffc0204a5a:	bf45                	j	ffffffffc0204a0a <sysfile_read+0x9a>
ffffffffc0204a5c:	5475                	li	s0,-3
ffffffffc0204a5e:	b73d                	j	ffffffffc020498c <sysfile_read+0x1c>
ffffffffc0204a60:	5471                	li	s0,-4
ffffffffc0204a62:	b72d                	j	ffffffffc020498c <sysfile_read+0x1c>
ffffffffc0204a64:	00009697          	auipc	a3,0x9
ffffffffc0204a68:	9dc68693          	addi	a3,a3,-1572 # ffffffffc020d440 <default_pmm_manager+0x120>
ffffffffc0204a6c:	00007617          	auipc	a2,0x7
ffffffffc0204a70:	2b460613          	addi	a2,a2,692 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204a74:	05500593          	li	a1,85
ffffffffc0204a78:	00009517          	auipc	a0,0x9
ffffffffc0204a7c:	9d850513          	addi	a0,a0,-1576 # ffffffffc020d450 <default_pmm_manager+0x130>
ffffffffc0204a80:	faefb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204a84 <sysfile_write>:
ffffffffc0204a84:	7159                	addi	sp,sp,-112
ffffffffc0204a86:	e8ca                	sd	s2,80(sp)
ffffffffc0204a88:	f486                	sd	ra,104(sp)
ffffffffc0204a8a:	f0a2                	sd	s0,96(sp)
ffffffffc0204a8c:	eca6                	sd	s1,88(sp)
ffffffffc0204a8e:	e4ce                	sd	s3,72(sp)
ffffffffc0204a90:	e0d2                	sd	s4,64(sp)
ffffffffc0204a92:	fc56                	sd	s5,56(sp)
ffffffffc0204a94:	f85a                	sd	s6,48(sp)
ffffffffc0204a96:	f45e                	sd	s7,40(sp)
ffffffffc0204a98:	f062                	sd	s8,32(sp)
ffffffffc0204a9a:	ec66                	sd	s9,24(sp)
ffffffffc0204a9c:	4901                	li	s2,0
ffffffffc0204a9e:	ee19                	bnez	a2,ffffffffc0204abc <sysfile_write+0x38>
ffffffffc0204aa0:	70a6                	ld	ra,104(sp)
ffffffffc0204aa2:	7406                	ld	s0,96(sp)
ffffffffc0204aa4:	64e6                	ld	s1,88(sp)
ffffffffc0204aa6:	69a6                	ld	s3,72(sp)
ffffffffc0204aa8:	6a06                	ld	s4,64(sp)
ffffffffc0204aaa:	7ae2                	ld	s5,56(sp)
ffffffffc0204aac:	7b42                	ld	s6,48(sp)
ffffffffc0204aae:	7ba2                	ld	s7,40(sp)
ffffffffc0204ab0:	7c02                	ld	s8,32(sp)
ffffffffc0204ab2:	6ce2                	ld	s9,24(sp)
ffffffffc0204ab4:	854a                	mv	a0,s2
ffffffffc0204ab6:	6946                	ld	s2,80(sp)
ffffffffc0204ab8:	6165                	addi	sp,sp,112
ffffffffc0204aba:	8082                	ret
ffffffffc0204abc:	00092c17          	auipc	s8,0x92
ffffffffc0204ac0:	e4cc0c13          	addi	s8,s8,-436 # ffffffffc0296908 <current>
ffffffffc0204ac4:	000c3783          	ld	a5,0(s8)
ffffffffc0204ac8:	8432                	mv	s0,a2
ffffffffc0204aca:	89ae                	mv	s3,a1
ffffffffc0204acc:	4605                	li	a2,1
ffffffffc0204ace:	4581                	li	a1,0
ffffffffc0204ad0:	7784                	ld	s1,40(a5)
ffffffffc0204ad2:	8baa                	mv	s7,a0
ffffffffc0204ad4:	5e6000ef          	jal	ra,ffffffffc02050ba <file_testfd>
ffffffffc0204ad8:	cd59                	beqz	a0,ffffffffc0204b76 <sysfile_write+0xf2>
ffffffffc0204ada:	6505                	lui	a0,0x1
ffffffffc0204adc:	df5fe0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0204ae0:	8a2a                	mv	s4,a0
ffffffffc0204ae2:	cd41                	beqz	a0,ffffffffc0204b7a <sysfile_write+0xf6>
ffffffffc0204ae4:	4c81                	li	s9,0
ffffffffc0204ae6:	6a85                	lui	s5,0x1
ffffffffc0204ae8:	03848b13          	addi	s6,s1,56
ffffffffc0204aec:	05546a63          	bltu	s0,s5,ffffffffc0204b40 <sysfile_write+0xbc>
ffffffffc0204af0:	e456                	sd	s5,8(sp)
ffffffffc0204af2:	c8a9                	beqz	s1,ffffffffc0204b44 <sysfile_write+0xc0>
ffffffffc0204af4:	855a                	mv	a0,s6
ffffffffc0204af6:	d63ff0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc0204afa:	000c3783          	ld	a5,0(s8)
ffffffffc0204afe:	c399                	beqz	a5,ffffffffc0204b04 <sysfile_write+0x80>
ffffffffc0204b00:	43dc                	lw	a5,4(a5)
ffffffffc0204b02:	c8bc                	sw	a5,80(s1)
ffffffffc0204b04:	66a2                	ld	a3,8(sp)
ffffffffc0204b06:	4701                	li	a4,0
ffffffffc0204b08:	864e                	mv	a2,s3
ffffffffc0204b0a:	85d2                	mv	a1,s4
ffffffffc0204b0c:	8526                	mv	a0,s1
ffffffffc0204b0e:	aa5fe0ef          	jal	ra,ffffffffc02035b2 <copy_from_user>
ffffffffc0204b12:	c139                	beqz	a0,ffffffffc0204b58 <sysfile_write+0xd4>
ffffffffc0204b14:	855a                	mv	a0,s6
ffffffffc0204b16:	d3fff0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0204b1a:	0404a823          	sw	zero,80(s1)
ffffffffc0204b1e:	6622                	ld	a2,8(sp)
ffffffffc0204b20:	0034                	addi	a3,sp,8
ffffffffc0204b22:	85d2                	mv	a1,s4
ffffffffc0204b24:	855e                	mv	a0,s7
ffffffffc0204b26:	023000ef          	jal	ra,ffffffffc0205348 <file_write>
ffffffffc0204b2a:	67a2                	ld	a5,8(sp)
ffffffffc0204b2c:	892a                	mv	s2,a0
ffffffffc0204b2e:	ef85                	bnez	a5,ffffffffc0204b66 <sysfile_write+0xe2>
ffffffffc0204b30:	8552                	mv	a0,s4
ffffffffc0204b32:	e4ffe0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0204b36:	f60c85e3          	beqz	s9,ffffffffc0204aa0 <sysfile_write+0x1c>
ffffffffc0204b3a:	000c891b          	sext.w	s2,s9
ffffffffc0204b3e:	b78d                	j	ffffffffc0204aa0 <sysfile_write+0x1c>
ffffffffc0204b40:	e422                	sd	s0,8(sp)
ffffffffc0204b42:	f8cd                	bnez	s1,ffffffffc0204af4 <sysfile_write+0x70>
ffffffffc0204b44:	66a2                	ld	a3,8(sp)
ffffffffc0204b46:	4701                	li	a4,0
ffffffffc0204b48:	864e                	mv	a2,s3
ffffffffc0204b4a:	85d2                	mv	a1,s4
ffffffffc0204b4c:	4501                	li	a0,0
ffffffffc0204b4e:	a65fe0ef          	jal	ra,ffffffffc02035b2 <copy_from_user>
ffffffffc0204b52:	f571                	bnez	a0,ffffffffc0204b1e <sysfile_write+0x9a>
ffffffffc0204b54:	5975                	li	s2,-3
ffffffffc0204b56:	bfe9                	j	ffffffffc0204b30 <sysfile_write+0xac>
ffffffffc0204b58:	855a                	mv	a0,s6
ffffffffc0204b5a:	cfbff0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0204b5e:	5975                	li	s2,-3
ffffffffc0204b60:	0404a823          	sw	zero,80(s1)
ffffffffc0204b64:	b7f1                	j	ffffffffc0204b30 <sysfile_write+0xac>
ffffffffc0204b66:	00f46c63          	bltu	s0,a5,ffffffffc0204b7e <sysfile_write+0xfa>
ffffffffc0204b6a:	99be                	add	s3,s3,a5
ffffffffc0204b6c:	8c1d                	sub	s0,s0,a5
ffffffffc0204b6e:	9cbe                	add	s9,s9,a5
ffffffffc0204b70:	f161                	bnez	a0,ffffffffc0204b30 <sysfile_write+0xac>
ffffffffc0204b72:	fc2d                	bnez	s0,ffffffffc0204aec <sysfile_write+0x68>
ffffffffc0204b74:	bf75                	j	ffffffffc0204b30 <sysfile_write+0xac>
ffffffffc0204b76:	5975                	li	s2,-3
ffffffffc0204b78:	b725                	j	ffffffffc0204aa0 <sysfile_write+0x1c>
ffffffffc0204b7a:	5971                	li	s2,-4
ffffffffc0204b7c:	b715                	j	ffffffffc0204aa0 <sysfile_write+0x1c>
ffffffffc0204b7e:	00009697          	auipc	a3,0x9
ffffffffc0204b82:	8c268693          	addi	a3,a3,-1854 # ffffffffc020d440 <default_pmm_manager+0x120>
ffffffffc0204b86:	00007617          	auipc	a2,0x7
ffffffffc0204b8a:	19a60613          	addi	a2,a2,410 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204b8e:	08a00593          	li	a1,138
ffffffffc0204b92:	00009517          	auipc	a0,0x9
ffffffffc0204b96:	8be50513          	addi	a0,a0,-1858 # ffffffffc020d450 <default_pmm_manager+0x130>
ffffffffc0204b9a:	e94fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204b9e <sysfile_seek>:
ffffffffc0204b9e:	0910006f          	j	ffffffffc020542e <file_seek>

ffffffffc0204ba2 <sysfile_fstat>:
ffffffffc0204ba2:	715d                	addi	sp,sp,-80
ffffffffc0204ba4:	f44e                	sd	s3,40(sp)
ffffffffc0204ba6:	00092997          	auipc	s3,0x92
ffffffffc0204baa:	d6298993          	addi	s3,s3,-670 # ffffffffc0296908 <current>
ffffffffc0204bae:	0009b703          	ld	a4,0(s3)
ffffffffc0204bb2:	fc26                	sd	s1,56(sp)
ffffffffc0204bb4:	84ae                	mv	s1,a1
ffffffffc0204bb6:	858a                	mv	a1,sp
ffffffffc0204bb8:	e0a2                	sd	s0,64(sp)
ffffffffc0204bba:	f84a                	sd	s2,48(sp)
ffffffffc0204bbc:	e486                	sd	ra,72(sp)
ffffffffc0204bbe:	02873903          	ld	s2,40(a4)
ffffffffc0204bc2:	f052                	sd	s4,32(sp)
ffffffffc0204bc4:	18b000ef          	jal	ra,ffffffffc020554e <file_fstat>
ffffffffc0204bc8:	842a                	mv	s0,a0
ffffffffc0204bca:	e91d                	bnez	a0,ffffffffc0204c00 <sysfile_fstat+0x5e>
ffffffffc0204bcc:	04090363          	beqz	s2,ffffffffc0204c12 <sysfile_fstat+0x70>
ffffffffc0204bd0:	03890a13          	addi	s4,s2,56
ffffffffc0204bd4:	8552                	mv	a0,s4
ffffffffc0204bd6:	c83ff0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc0204bda:	0009b783          	ld	a5,0(s3)
ffffffffc0204bde:	c3b9                	beqz	a5,ffffffffc0204c24 <sysfile_fstat+0x82>
ffffffffc0204be0:	43dc                	lw	a5,4(a5)
ffffffffc0204be2:	02000693          	li	a3,32
ffffffffc0204be6:	860a                	mv	a2,sp
ffffffffc0204be8:	04f92823          	sw	a5,80(s2)
ffffffffc0204bec:	85a6                	mv	a1,s1
ffffffffc0204bee:	854a                	mv	a0,s2
ffffffffc0204bf0:	9f7fe0ef          	jal	ra,ffffffffc02035e6 <copy_to_user>
ffffffffc0204bf4:	c121                	beqz	a0,ffffffffc0204c34 <sysfile_fstat+0x92>
ffffffffc0204bf6:	8552                	mv	a0,s4
ffffffffc0204bf8:	c5dff0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0204bfc:	04092823          	sw	zero,80(s2)
ffffffffc0204c00:	60a6                	ld	ra,72(sp)
ffffffffc0204c02:	8522                	mv	a0,s0
ffffffffc0204c04:	6406                	ld	s0,64(sp)
ffffffffc0204c06:	74e2                	ld	s1,56(sp)
ffffffffc0204c08:	7942                	ld	s2,48(sp)
ffffffffc0204c0a:	79a2                	ld	s3,40(sp)
ffffffffc0204c0c:	7a02                	ld	s4,32(sp)
ffffffffc0204c0e:	6161                	addi	sp,sp,80
ffffffffc0204c10:	8082                	ret
ffffffffc0204c12:	02000693          	li	a3,32
ffffffffc0204c16:	860a                	mv	a2,sp
ffffffffc0204c18:	85a6                	mv	a1,s1
ffffffffc0204c1a:	9cdfe0ef          	jal	ra,ffffffffc02035e6 <copy_to_user>
ffffffffc0204c1e:	f16d                	bnez	a0,ffffffffc0204c00 <sysfile_fstat+0x5e>
ffffffffc0204c20:	5475                	li	s0,-3
ffffffffc0204c22:	bff9                	j	ffffffffc0204c00 <sysfile_fstat+0x5e>
ffffffffc0204c24:	02000693          	li	a3,32
ffffffffc0204c28:	860a                	mv	a2,sp
ffffffffc0204c2a:	85a6                	mv	a1,s1
ffffffffc0204c2c:	854a                	mv	a0,s2
ffffffffc0204c2e:	9b9fe0ef          	jal	ra,ffffffffc02035e6 <copy_to_user>
ffffffffc0204c32:	f171                	bnez	a0,ffffffffc0204bf6 <sysfile_fstat+0x54>
ffffffffc0204c34:	8552                	mv	a0,s4
ffffffffc0204c36:	c1fff0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0204c3a:	5475                	li	s0,-3
ffffffffc0204c3c:	04092823          	sw	zero,80(s2)
ffffffffc0204c40:	b7c1                	j	ffffffffc0204c00 <sysfile_fstat+0x5e>

ffffffffc0204c42 <sysfile_fsync>:
ffffffffc0204c42:	1cd0006f          	j	ffffffffc020560e <file_fsync>

ffffffffc0204c46 <sysfile_getcwd>:
ffffffffc0204c46:	715d                	addi	sp,sp,-80
ffffffffc0204c48:	f44e                	sd	s3,40(sp)
ffffffffc0204c4a:	00092997          	auipc	s3,0x92
ffffffffc0204c4e:	cbe98993          	addi	s3,s3,-834 # ffffffffc0296908 <current>
ffffffffc0204c52:	0009b783          	ld	a5,0(s3)
ffffffffc0204c56:	f84a                	sd	s2,48(sp)
ffffffffc0204c58:	e486                	sd	ra,72(sp)
ffffffffc0204c5a:	e0a2                	sd	s0,64(sp)
ffffffffc0204c5c:	fc26                	sd	s1,56(sp)
ffffffffc0204c5e:	f052                	sd	s4,32(sp)
ffffffffc0204c60:	0287b903          	ld	s2,40(a5)
ffffffffc0204c64:	cda9                	beqz	a1,ffffffffc0204cbe <sysfile_getcwd+0x78>
ffffffffc0204c66:	842e                	mv	s0,a1
ffffffffc0204c68:	84aa                	mv	s1,a0
ffffffffc0204c6a:	04090363          	beqz	s2,ffffffffc0204cb0 <sysfile_getcwd+0x6a>
ffffffffc0204c6e:	03890a13          	addi	s4,s2,56
ffffffffc0204c72:	8552                	mv	a0,s4
ffffffffc0204c74:	be5ff0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc0204c78:	0009b783          	ld	a5,0(s3)
ffffffffc0204c7c:	c781                	beqz	a5,ffffffffc0204c84 <sysfile_getcwd+0x3e>
ffffffffc0204c7e:	43dc                	lw	a5,4(a5)
ffffffffc0204c80:	04f92823          	sw	a5,80(s2)
ffffffffc0204c84:	4685                	li	a3,1
ffffffffc0204c86:	8622                	mv	a2,s0
ffffffffc0204c88:	85a6                	mv	a1,s1
ffffffffc0204c8a:	854a                	mv	a0,s2
ffffffffc0204c8c:	893fe0ef          	jal	ra,ffffffffc020351e <user_mem_check>
ffffffffc0204c90:	e90d                	bnez	a0,ffffffffc0204cc2 <sysfile_getcwd+0x7c>
ffffffffc0204c92:	5475                	li	s0,-3
ffffffffc0204c94:	8552                	mv	a0,s4
ffffffffc0204c96:	bbfff0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0204c9a:	04092823          	sw	zero,80(s2)
ffffffffc0204c9e:	60a6                	ld	ra,72(sp)
ffffffffc0204ca0:	8522                	mv	a0,s0
ffffffffc0204ca2:	6406                	ld	s0,64(sp)
ffffffffc0204ca4:	74e2                	ld	s1,56(sp)
ffffffffc0204ca6:	7942                	ld	s2,48(sp)
ffffffffc0204ca8:	79a2                	ld	s3,40(sp)
ffffffffc0204caa:	7a02                	ld	s4,32(sp)
ffffffffc0204cac:	6161                	addi	sp,sp,80
ffffffffc0204cae:	8082                	ret
ffffffffc0204cb0:	862e                	mv	a2,a1
ffffffffc0204cb2:	4685                	li	a3,1
ffffffffc0204cb4:	85aa                	mv	a1,a0
ffffffffc0204cb6:	4501                	li	a0,0
ffffffffc0204cb8:	867fe0ef          	jal	ra,ffffffffc020351e <user_mem_check>
ffffffffc0204cbc:	ed09                	bnez	a0,ffffffffc0204cd6 <sysfile_getcwd+0x90>
ffffffffc0204cbe:	5475                	li	s0,-3
ffffffffc0204cc0:	bff9                	j	ffffffffc0204c9e <sysfile_getcwd+0x58>
ffffffffc0204cc2:	8622                	mv	a2,s0
ffffffffc0204cc4:	4681                	li	a3,0
ffffffffc0204cc6:	85a6                	mv	a1,s1
ffffffffc0204cc8:	850a                	mv	a0,sp
ffffffffc0204cca:	371000ef          	jal	ra,ffffffffc020583a <iobuf_init>
ffffffffc0204cce:	32c030ef          	jal	ra,ffffffffc0207ffa <vfs_getcwd>
ffffffffc0204cd2:	842a                	mv	s0,a0
ffffffffc0204cd4:	b7c1                	j	ffffffffc0204c94 <sysfile_getcwd+0x4e>
ffffffffc0204cd6:	8622                	mv	a2,s0
ffffffffc0204cd8:	4681                	li	a3,0
ffffffffc0204cda:	85a6                	mv	a1,s1
ffffffffc0204cdc:	850a                	mv	a0,sp
ffffffffc0204cde:	35d000ef          	jal	ra,ffffffffc020583a <iobuf_init>
ffffffffc0204ce2:	318030ef          	jal	ra,ffffffffc0207ffa <vfs_getcwd>
ffffffffc0204ce6:	842a                	mv	s0,a0
ffffffffc0204ce8:	bf5d                	j	ffffffffc0204c9e <sysfile_getcwd+0x58>

ffffffffc0204cea <sysfile_getdirentry>:
ffffffffc0204cea:	7139                	addi	sp,sp,-64
ffffffffc0204cec:	e852                	sd	s4,16(sp)
ffffffffc0204cee:	00092a17          	auipc	s4,0x92
ffffffffc0204cf2:	c1aa0a13          	addi	s4,s4,-998 # ffffffffc0296908 <current>
ffffffffc0204cf6:	000a3703          	ld	a4,0(s4)
ffffffffc0204cfa:	ec4e                	sd	s3,24(sp)
ffffffffc0204cfc:	89aa                	mv	s3,a0
ffffffffc0204cfe:	10800513          	li	a0,264
ffffffffc0204d02:	f426                	sd	s1,40(sp)
ffffffffc0204d04:	f04a                	sd	s2,32(sp)
ffffffffc0204d06:	fc06                	sd	ra,56(sp)
ffffffffc0204d08:	f822                	sd	s0,48(sp)
ffffffffc0204d0a:	e456                	sd	s5,8(sp)
ffffffffc0204d0c:	7704                	ld	s1,40(a4)
ffffffffc0204d0e:	892e                	mv	s2,a1
ffffffffc0204d10:	bc1fe0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0204d14:	c169                	beqz	a0,ffffffffc0204dd6 <sysfile_getdirentry+0xec>
ffffffffc0204d16:	842a                	mv	s0,a0
ffffffffc0204d18:	c8c1                	beqz	s1,ffffffffc0204da8 <sysfile_getdirentry+0xbe>
ffffffffc0204d1a:	03848a93          	addi	s5,s1,56
ffffffffc0204d1e:	8556                	mv	a0,s5
ffffffffc0204d20:	b39ff0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc0204d24:	000a3783          	ld	a5,0(s4)
ffffffffc0204d28:	c399                	beqz	a5,ffffffffc0204d2e <sysfile_getdirentry+0x44>
ffffffffc0204d2a:	43dc                	lw	a5,4(a5)
ffffffffc0204d2c:	c8bc                	sw	a5,80(s1)
ffffffffc0204d2e:	4705                	li	a4,1
ffffffffc0204d30:	46a1                	li	a3,8
ffffffffc0204d32:	864a                	mv	a2,s2
ffffffffc0204d34:	85a2                	mv	a1,s0
ffffffffc0204d36:	8526                	mv	a0,s1
ffffffffc0204d38:	87bfe0ef          	jal	ra,ffffffffc02035b2 <copy_from_user>
ffffffffc0204d3c:	e505                	bnez	a0,ffffffffc0204d64 <sysfile_getdirentry+0x7a>
ffffffffc0204d3e:	8556                	mv	a0,s5
ffffffffc0204d40:	b15ff0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0204d44:	59f5                	li	s3,-3
ffffffffc0204d46:	0404a823          	sw	zero,80(s1)
ffffffffc0204d4a:	8522                	mv	a0,s0
ffffffffc0204d4c:	c35fe0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0204d50:	70e2                	ld	ra,56(sp)
ffffffffc0204d52:	7442                	ld	s0,48(sp)
ffffffffc0204d54:	74a2                	ld	s1,40(sp)
ffffffffc0204d56:	7902                	ld	s2,32(sp)
ffffffffc0204d58:	6a42                	ld	s4,16(sp)
ffffffffc0204d5a:	6aa2                	ld	s5,8(sp)
ffffffffc0204d5c:	854e                	mv	a0,s3
ffffffffc0204d5e:	69e2                	ld	s3,24(sp)
ffffffffc0204d60:	6121                	addi	sp,sp,64
ffffffffc0204d62:	8082                	ret
ffffffffc0204d64:	8556                	mv	a0,s5
ffffffffc0204d66:	aefff0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0204d6a:	854e                	mv	a0,s3
ffffffffc0204d6c:	85a2                	mv	a1,s0
ffffffffc0204d6e:	0404a823          	sw	zero,80(s1)
ffffffffc0204d72:	14b000ef          	jal	ra,ffffffffc02056bc <file_getdirentry>
ffffffffc0204d76:	89aa                	mv	s3,a0
ffffffffc0204d78:	f969                	bnez	a0,ffffffffc0204d4a <sysfile_getdirentry+0x60>
ffffffffc0204d7a:	8556                	mv	a0,s5
ffffffffc0204d7c:	addff0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc0204d80:	000a3783          	ld	a5,0(s4)
ffffffffc0204d84:	c399                	beqz	a5,ffffffffc0204d8a <sysfile_getdirentry+0xa0>
ffffffffc0204d86:	43dc                	lw	a5,4(a5)
ffffffffc0204d88:	c8bc                	sw	a5,80(s1)
ffffffffc0204d8a:	10800693          	li	a3,264
ffffffffc0204d8e:	8622                	mv	a2,s0
ffffffffc0204d90:	85ca                	mv	a1,s2
ffffffffc0204d92:	8526                	mv	a0,s1
ffffffffc0204d94:	853fe0ef          	jal	ra,ffffffffc02035e6 <copy_to_user>
ffffffffc0204d98:	e111                	bnez	a0,ffffffffc0204d9c <sysfile_getdirentry+0xb2>
ffffffffc0204d9a:	59f5                	li	s3,-3
ffffffffc0204d9c:	8556                	mv	a0,s5
ffffffffc0204d9e:	ab7ff0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0204da2:	0404a823          	sw	zero,80(s1)
ffffffffc0204da6:	b755                	j	ffffffffc0204d4a <sysfile_getdirentry+0x60>
ffffffffc0204da8:	85aa                	mv	a1,a0
ffffffffc0204daa:	4705                	li	a4,1
ffffffffc0204dac:	46a1                	li	a3,8
ffffffffc0204dae:	864a                	mv	a2,s2
ffffffffc0204db0:	4501                	li	a0,0
ffffffffc0204db2:	801fe0ef          	jal	ra,ffffffffc02035b2 <copy_from_user>
ffffffffc0204db6:	cd11                	beqz	a0,ffffffffc0204dd2 <sysfile_getdirentry+0xe8>
ffffffffc0204db8:	854e                	mv	a0,s3
ffffffffc0204dba:	85a2                	mv	a1,s0
ffffffffc0204dbc:	101000ef          	jal	ra,ffffffffc02056bc <file_getdirentry>
ffffffffc0204dc0:	89aa                	mv	s3,a0
ffffffffc0204dc2:	f541                	bnez	a0,ffffffffc0204d4a <sysfile_getdirentry+0x60>
ffffffffc0204dc4:	10800693          	li	a3,264
ffffffffc0204dc8:	8622                	mv	a2,s0
ffffffffc0204dca:	85ca                	mv	a1,s2
ffffffffc0204dcc:	81bfe0ef          	jal	ra,ffffffffc02035e6 <copy_to_user>
ffffffffc0204dd0:	fd2d                	bnez	a0,ffffffffc0204d4a <sysfile_getdirentry+0x60>
ffffffffc0204dd2:	59f5                	li	s3,-3
ffffffffc0204dd4:	bf9d                	j	ffffffffc0204d4a <sysfile_getdirentry+0x60>
ffffffffc0204dd6:	59f1                	li	s3,-4
ffffffffc0204dd8:	bfa5                	j	ffffffffc0204d50 <sysfile_getdirentry+0x66>

ffffffffc0204dda <sysfile_dup>:
ffffffffc0204dda:	1c90006f          	j	ffffffffc02057a2 <file_dup>

ffffffffc0204dde <get_fd_array.part.0>:
ffffffffc0204dde:	1141                	addi	sp,sp,-16
ffffffffc0204de0:	00008697          	auipc	a3,0x8
ffffffffc0204de4:	68868693          	addi	a3,a3,1672 # ffffffffc020d468 <default_pmm_manager+0x148>
ffffffffc0204de8:	00007617          	auipc	a2,0x7
ffffffffc0204dec:	f3860613          	addi	a2,a2,-200 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204df0:	45d1                	li	a1,20
ffffffffc0204df2:	00008517          	auipc	a0,0x8
ffffffffc0204df6:	6a650513          	addi	a0,a0,1702 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0204dfa:	e406                	sd	ra,8(sp)
ffffffffc0204dfc:	c32fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204e00 <fd_array_alloc>:
ffffffffc0204e00:	00092797          	auipc	a5,0x92
ffffffffc0204e04:	b087b783          	ld	a5,-1272(a5) # ffffffffc0296908 <current>
ffffffffc0204e08:	1487b783          	ld	a5,328(a5)
ffffffffc0204e0c:	1141                	addi	sp,sp,-16
ffffffffc0204e0e:	e406                	sd	ra,8(sp)
ffffffffc0204e10:	c3a5                	beqz	a5,ffffffffc0204e70 <fd_array_alloc+0x70>
ffffffffc0204e12:	4b98                	lw	a4,16(a5)
ffffffffc0204e14:	04e05e63          	blez	a4,ffffffffc0204e70 <fd_array_alloc+0x70>
ffffffffc0204e18:	775d                	lui	a4,0xffff7
ffffffffc0204e1a:	ad970713          	addi	a4,a4,-1319 # ffffffffffff6ad9 <end+0x3fd60181>
ffffffffc0204e1e:	679c                	ld	a5,8(a5)
ffffffffc0204e20:	02e50863          	beq	a0,a4,ffffffffc0204e50 <fd_array_alloc+0x50>
ffffffffc0204e24:	04700713          	li	a4,71
ffffffffc0204e28:	04a76263          	bltu	a4,a0,ffffffffc0204e6c <fd_array_alloc+0x6c>
ffffffffc0204e2c:	00351713          	slli	a4,a0,0x3
ffffffffc0204e30:	40a70533          	sub	a0,a4,a0
ffffffffc0204e34:	050e                	slli	a0,a0,0x3
ffffffffc0204e36:	97aa                	add	a5,a5,a0
ffffffffc0204e38:	4398                	lw	a4,0(a5)
ffffffffc0204e3a:	e71d                	bnez	a4,ffffffffc0204e68 <fd_array_alloc+0x68>
ffffffffc0204e3c:	5b88                	lw	a0,48(a5)
ffffffffc0204e3e:	e91d                	bnez	a0,ffffffffc0204e74 <fd_array_alloc+0x74>
ffffffffc0204e40:	4705                	li	a4,1
ffffffffc0204e42:	c398                	sw	a4,0(a5)
ffffffffc0204e44:	0207b423          	sd	zero,40(a5)
ffffffffc0204e48:	e19c                	sd	a5,0(a1)
ffffffffc0204e4a:	60a2                	ld	ra,8(sp)
ffffffffc0204e4c:	0141                	addi	sp,sp,16
ffffffffc0204e4e:	8082                	ret
ffffffffc0204e50:	6685                	lui	a3,0x1
ffffffffc0204e52:	fc068693          	addi	a3,a3,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc0204e56:	96be                	add	a3,a3,a5
ffffffffc0204e58:	4398                	lw	a4,0(a5)
ffffffffc0204e5a:	d36d                	beqz	a4,ffffffffc0204e3c <fd_array_alloc+0x3c>
ffffffffc0204e5c:	03878793          	addi	a5,a5,56
ffffffffc0204e60:	fef69ce3          	bne	a3,a5,ffffffffc0204e58 <fd_array_alloc+0x58>
ffffffffc0204e64:	5529                	li	a0,-22
ffffffffc0204e66:	b7d5                	j	ffffffffc0204e4a <fd_array_alloc+0x4a>
ffffffffc0204e68:	5545                	li	a0,-15
ffffffffc0204e6a:	b7c5                	j	ffffffffc0204e4a <fd_array_alloc+0x4a>
ffffffffc0204e6c:	5575                	li	a0,-3
ffffffffc0204e6e:	bff1                	j	ffffffffc0204e4a <fd_array_alloc+0x4a>
ffffffffc0204e70:	f6fff0ef          	jal	ra,ffffffffc0204dde <get_fd_array.part.0>
ffffffffc0204e74:	00008697          	auipc	a3,0x8
ffffffffc0204e78:	63468693          	addi	a3,a3,1588 # ffffffffc020d4a8 <default_pmm_manager+0x188>
ffffffffc0204e7c:	00007617          	auipc	a2,0x7
ffffffffc0204e80:	ea460613          	addi	a2,a2,-348 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204e84:	03b00593          	li	a1,59
ffffffffc0204e88:	00008517          	auipc	a0,0x8
ffffffffc0204e8c:	61050513          	addi	a0,a0,1552 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0204e90:	b9efb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204e94 <fd_array_free>:
ffffffffc0204e94:	411c                	lw	a5,0(a0)
ffffffffc0204e96:	1141                	addi	sp,sp,-16
ffffffffc0204e98:	e022                	sd	s0,0(sp)
ffffffffc0204e9a:	e406                	sd	ra,8(sp)
ffffffffc0204e9c:	4705                	li	a4,1
ffffffffc0204e9e:	842a                	mv	s0,a0
ffffffffc0204ea0:	04e78063          	beq	a5,a4,ffffffffc0204ee0 <fd_array_free+0x4c>
ffffffffc0204ea4:	470d                	li	a4,3
ffffffffc0204ea6:	04e79563          	bne	a5,a4,ffffffffc0204ef0 <fd_array_free+0x5c>
ffffffffc0204eaa:	591c                	lw	a5,48(a0)
ffffffffc0204eac:	c38d                	beqz	a5,ffffffffc0204ece <fd_array_free+0x3a>
ffffffffc0204eae:	00008697          	auipc	a3,0x8
ffffffffc0204eb2:	5fa68693          	addi	a3,a3,1530 # ffffffffc020d4a8 <default_pmm_manager+0x188>
ffffffffc0204eb6:	00007617          	auipc	a2,0x7
ffffffffc0204eba:	e6a60613          	addi	a2,a2,-406 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204ebe:	04500593          	li	a1,69
ffffffffc0204ec2:	00008517          	auipc	a0,0x8
ffffffffc0204ec6:	5d650513          	addi	a0,a0,1494 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0204eca:	b64fb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204ece:	7408                	ld	a0,40(s0)
ffffffffc0204ed0:	01b030ef          	jal	ra,ffffffffc02086ea <vfs_close>
ffffffffc0204ed4:	60a2                	ld	ra,8(sp)
ffffffffc0204ed6:	00042023          	sw	zero,0(s0)
ffffffffc0204eda:	6402                	ld	s0,0(sp)
ffffffffc0204edc:	0141                	addi	sp,sp,16
ffffffffc0204ede:	8082                	ret
ffffffffc0204ee0:	591c                	lw	a5,48(a0)
ffffffffc0204ee2:	f7f1                	bnez	a5,ffffffffc0204eae <fd_array_free+0x1a>
ffffffffc0204ee4:	60a2                	ld	ra,8(sp)
ffffffffc0204ee6:	00042023          	sw	zero,0(s0)
ffffffffc0204eea:	6402                	ld	s0,0(sp)
ffffffffc0204eec:	0141                	addi	sp,sp,16
ffffffffc0204eee:	8082                	ret
ffffffffc0204ef0:	00008697          	auipc	a3,0x8
ffffffffc0204ef4:	5f068693          	addi	a3,a3,1520 # ffffffffc020d4e0 <default_pmm_manager+0x1c0>
ffffffffc0204ef8:	00007617          	auipc	a2,0x7
ffffffffc0204efc:	e2860613          	addi	a2,a2,-472 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204f00:	04400593          	li	a1,68
ffffffffc0204f04:	00008517          	auipc	a0,0x8
ffffffffc0204f08:	59450513          	addi	a0,a0,1428 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0204f0c:	b22fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204f10 <fd_array_release>:
ffffffffc0204f10:	4118                	lw	a4,0(a0)
ffffffffc0204f12:	1141                	addi	sp,sp,-16
ffffffffc0204f14:	e406                	sd	ra,8(sp)
ffffffffc0204f16:	4685                	li	a3,1
ffffffffc0204f18:	3779                	addiw	a4,a4,-2
ffffffffc0204f1a:	04e6e063          	bltu	a3,a4,ffffffffc0204f5a <fd_array_release+0x4a>
ffffffffc0204f1e:	5918                	lw	a4,48(a0)
ffffffffc0204f20:	00e05d63          	blez	a4,ffffffffc0204f3a <fd_array_release+0x2a>
ffffffffc0204f24:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f28:	d914                	sw	a3,48(a0)
ffffffffc0204f2a:	c681                	beqz	a3,ffffffffc0204f32 <fd_array_release+0x22>
ffffffffc0204f2c:	60a2                	ld	ra,8(sp)
ffffffffc0204f2e:	0141                	addi	sp,sp,16
ffffffffc0204f30:	8082                	ret
ffffffffc0204f32:	60a2                	ld	ra,8(sp)
ffffffffc0204f34:	0141                	addi	sp,sp,16
ffffffffc0204f36:	f5fff06f          	j	ffffffffc0204e94 <fd_array_free>
ffffffffc0204f3a:	00008697          	auipc	a3,0x8
ffffffffc0204f3e:	61668693          	addi	a3,a3,1558 # ffffffffc020d550 <default_pmm_manager+0x230>
ffffffffc0204f42:	00007617          	auipc	a2,0x7
ffffffffc0204f46:	dde60613          	addi	a2,a2,-546 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204f4a:	05600593          	li	a1,86
ffffffffc0204f4e:	00008517          	auipc	a0,0x8
ffffffffc0204f52:	54a50513          	addi	a0,a0,1354 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0204f56:	ad8fb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0204f5a:	00008697          	auipc	a3,0x8
ffffffffc0204f5e:	5be68693          	addi	a3,a3,1470 # ffffffffc020d518 <default_pmm_manager+0x1f8>
ffffffffc0204f62:	00007617          	auipc	a2,0x7
ffffffffc0204f66:	dbe60613          	addi	a2,a2,-578 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204f6a:	05500593          	li	a1,85
ffffffffc0204f6e:	00008517          	auipc	a0,0x8
ffffffffc0204f72:	52a50513          	addi	a0,a0,1322 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0204f76:	ab8fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204f7a <fd_array_open.part.0>:
ffffffffc0204f7a:	1141                	addi	sp,sp,-16
ffffffffc0204f7c:	00008697          	auipc	a3,0x8
ffffffffc0204f80:	5ec68693          	addi	a3,a3,1516 # ffffffffc020d568 <default_pmm_manager+0x248>
ffffffffc0204f84:	00007617          	auipc	a2,0x7
ffffffffc0204f88:	d9c60613          	addi	a2,a2,-612 # ffffffffc020bd20 <commands+0x250>
ffffffffc0204f8c:	05f00593          	li	a1,95
ffffffffc0204f90:	00008517          	auipc	a0,0x8
ffffffffc0204f94:	50850513          	addi	a0,a0,1288 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0204f98:	e406                	sd	ra,8(sp)
ffffffffc0204f9a:	a94fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0204f9e <fd_array_init>:
ffffffffc0204f9e:	4781                	li	a5,0
ffffffffc0204fa0:	04800713          	li	a4,72
ffffffffc0204fa4:	cd1c                	sw	a5,24(a0)
ffffffffc0204fa6:	02052823          	sw	zero,48(a0)
ffffffffc0204faa:	00052023          	sw	zero,0(a0)
ffffffffc0204fae:	2785                	addiw	a5,a5,1
ffffffffc0204fb0:	03850513          	addi	a0,a0,56
ffffffffc0204fb4:	fee798e3          	bne	a5,a4,ffffffffc0204fa4 <fd_array_init+0x6>
ffffffffc0204fb8:	8082                	ret

ffffffffc0204fba <fd_array_close>:
ffffffffc0204fba:	4118                	lw	a4,0(a0)
ffffffffc0204fbc:	1141                	addi	sp,sp,-16
ffffffffc0204fbe:	e406                	sd	ra,8(sp)
ffffffffc0204fc0:	e022                	sd	s0,0(sp)
ffffffffc0204fc2:	4789                	li	a5,2
ffffffffc0204fc4:	04f71a63          	bne	a4,a5,ffffffffc0205018 <fd_array_close+0x5e>
ffffffffc0204fc8:	591c                	lw	a5,48(a0)
ffffffffc0204fca:	842a                	mv	s0,a0
ffffffffc0204fcc:	02f05663          	blez	a5,ffffffffc0204ff8 <fd_array_close+0x3e>
ffffffffc0204fd0:	37fd                	addiw	a5,a5,-1
ffffffffc0204fd2:	470d                	li	a4,3
ffffffffc0204fd4:	c118                	sw	a4,0(a0)
ffffffffc0204fd6:	d91c                	sw	a5,48(a0)
ffffffffc0204fd8:	0007871b          	sext.w	a4,a5
ffffffffc0204fdc:	c709                	beqz	a4,ffffffffc0204fe6 <fd_array_close+0x2c>
ffffffffc0204fde:	60a2                	ld	ra,8(sp)
ffffffffc0204fe0:	6402                	ld	s0,0(sp)
ffffffffc0204fe2:	0141                	addi	sp,sp,16
ffffffffc0204fe4:	8082                	ret
ffffffffc0204fe6:	7508                	ld	a0,40(a0)
ffffffffc0204fe8:	702030ef          	jal	ra,ffffffffc02086ea <vfs_close>
ffffffffc0204fec:	60a2                	ld	ra,8(sp)
ffffffffc0204fee:	00042023          	sw	zero,0(s0)
ffffffffc0204ff2:	6402                	ld	s0,0(sp)
ffffffffc0204ff4:	0141                	addi	sp,sp,16
ffffffffc0204ff6:	8082                	ret
ffffffffc0204ff8:	00008697          	auipc	a3,0x8
ffffffffc0204ffc:	55868693          	addi	a3,a3,1368 # ffffffffc020d550 <default_pmm_manager+0x230>
ffffffffc0205000:	00007617          	auipc	a2,0x7
ffffffffc0205004:	d2060613          	addi	a2,a2,-736 # ffffffffc020bd20 <commands+0x250>
ffffffffc0205008:	06800593          	li	a1,104
ffffffffc020500c:	00008517          	auipc	a0,0x8
ffffffffc0205010:	48c50513          	addi	a0,a0,1164 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0205014:	a1afb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0205018:	00008697          	auipc	a3,0x8
ffffffffc020501c:	4a868693          	addi	a3,a3,1192 # ffffffffc020d4c0 <default_pmm_manager+0x1a0>
ffffffffc0205020:	00007617          	auipc	a2,0x7
ffffffffc0205024:	d0060613          	addi	a2,a2,-768 # ffffffffc020bd20 <commands+0x250>
ffffffffc0205028:	06700593          	li	a1,103
ffffffffc020502c:	00008517          	auipc	a0,0x8
ffffffffc0205030:	46c50513          	addi	a0,a0,1132 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0205034:	9fafb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0205038 <fd_array_dup>:
ffffffffc0205038:	7179                	addi	sp,sp,-48
ffffffffc020503a:	e84a                	sd	s2,16(sp)
ffffffffc020503c:	00052903          	lw	s2,0(a0)
ffffffffc0205040:	f406                	sd	ra,40(sp)
ffffffffc0205042:	f022                	sd	s0,32(sp)
ffffffffc0205044:	ec26                	sd	s1,24(sp)
ffffffffc0205046:	e44e                	sd	s3,8(sp)
ffffffffc0205048:	4785                	li	a5,1
ffffffffc020504a:	04f91663          	bne	s2,a5,ffffffffc0205096 <fd_array_dup+0x5e>
ffffffffc020504e:	0005a983          	lw	s3,0(a1)
ffffffffc0205052:	4789                	li	a5,2
ffffffffc0205054:	04f99163          	bne	s3,a5,ffffffffc0205096 <fd_array_dup+0x5e>
ffffffffc0205058:	7584                	ld	s1,40(a1)
ffffffffc020505a:	699c                	ld	a5,16(a1)
ffffffffc020505c:	7194                	ld	a3,32(a1)
ffffffffc020505e:	6598                	ld	a4,8(a1)
ffffffffc0205060:	842a                	mv	s0,a0
ffffffffc0205062:	e91c                	sd	a5,16(a0)
ffffffffc0205064:	f114                	sd	a3,32(a0)
ffffffffc0205066:	e518                	sd	a4,8(a0)
ffffffffc0205068:	8526                	mv	a0,s1
ffffffffc020506a:	2c2030ef          	jal	ra,ffffffffc020832c <inode_ref_inc>
ffffffffc020506e:	8526                	mv	a0,s1
ffffffffc0205070:	2c8030ef          	jal	ra,ffffffffc0208338 <inode_open_inc>
ffffffffc0205074:	401c                	lw	a5,0(s0)
ffffffffc0205076:	f404                	sd	s1,40(s0)
ffffffffc0205078:	03279f63          	bne	a5,s2,ffffffffc02050b6 <fd_array_dup+0x7e>
ffffffffc020507c:	cc8d                	beqz	s1,ffffffffc02050b6 <fd_array_dup+0x7e>
ffffffffc020507e:	581c                	lw	a5,48(s0)
ffffffffc0205080:	01342023          	sw	s3,0(s0)
ffffffffc0205084:	70a2                	ld	ra,40(sp)
ffffffffc0205086:	2785                	addiw	a5,a5,1
ffffffffc0205088:	d81c                	sw	a5,48(s0)
ffffffffc020508a:	7402                	ld	s0,32(sp)
ffffffffc020508c:	64e2                	ld	s1,24(sp)
ffffffffc020508e:	6942                	ld	s2,16(sp)
ffffffffc0205090:	69a2                	ld	s3,8(sp)
ffffffffc0205092:	6145                	addi	sp,sp,48
ffffffffc0205094:	8082                	ret
ffffffffc0205096:	00008697          	auipc	a3,0x8
ffffffffc020509a:	50268693          	addi	a3,a3,1282 # ffffffffc020d598 <default_pmm_manager+0x278>
ffffffffc020509e:	00007617          	auipc	a2,0x7
ffffffffc02050a2:	c8260613          	addi	a2,a2,-894 # ffffffffc020bd20 <commands+0x250>
ffffffffc02050a6:	07300593          	li	a1,115
ffffffffc02050aa:	00008517          	auipc	a0,0x8
ffffffffc02050ae:	3ee50513          	addi	a0,a0,1006 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc02050b2:	97cfb0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02050b6:	ec5ff0ef          	jal	ra,ffffffffc0204f7a <fd_array_open.part.0>

ffffffffc02050ba <file_testfd>:
ffffffffc02050ba:	04700793          	li	a5,71
ffffffffc02050be:	04a7e263          	bltu	a5,a0,ffffffffc0205102 <file_testfd+0x48>
ffffffffc02050c2:	00092797          	auipc	a5,0x92
ffffffffc02050c6:	8467b783          	ld	a5,-1978(a5) # ffffffffc0296908 <current>
ffffffffc02050ca:	1487b783          	ld	a5,328(a5)
ffffffffc02050ce:	cf85                	beqz	a5,ffffffffc0205106 <file_testfd+0x4c>
ffffffffc02050d0:	4b98                	lw	a4,16(a5)
ffffffffc02050d2:	02e05a63          	blez	a4,ffffffffc0205106 <file_testfd+0x4c>
ffffffffc02050d6:	6798                	ld	a4,8(a5)
ffffffffc02050d8:	00351793          	slli	a5,a0,0x3
ffffffffc02050dc:	8f89                	sub	a5,a5,a0
ffffffffc02050de:	078e                	slli	a5,a5,0x3
ffffffffc02050e0:	97ba                	add	a5,a5,a4
ffffffffc02050e2:	4394                	lw	a3,0(a5)
ffffffffc02050e4:	4709                	li	a4,2
ffffffffc02050e6:	00e69e63          	bne	a3,a4,ffffffffc0205102 <file_testfd+0x48>
ffffffffc02050ea:	4f98                	lw	a4,24(a5)
ffffffffc02050ec:	00a71b63          	bne	a4,a0,ffffffffc0205102 <file_testfd+0x48>
ffffffffc02050f0:	c199                	beqz	a1,ffffffffc02050f6 <file_testfd+0x3c>
ffffffffc02050f2:	6788                	ld	a0,8(a5)
ffffffffc02050f4:	c901                	beqz	a0,ffffffffc0205104 <file_testfd+0x4a>
ffffffffc02050f6:	4505                	li	a0,1
ffffffffc02050f8:	c611                	beqz	a2,ffffffffc0205104 <file_testfd+0x4a>
ffffffffc02050fa:	6b88                	ld	a0,16(a5)
ffffffffc02050fc:	00a03533          	snez	a0,a0
ffffffffc0205100:	8082                	ret
ffffffffc0205102:	4501                	li	a0,0
ffffffffc0205104:	8082                	ret
ffffffffc0205106:	1141                	addi	sp,sp,-16
ffffffffc0205108:	e406                	sd	ra,8(sp)
ffffffffc020510a:	cd5ff0ef          	jal	ra,ffffffffc0204dde <get_fd_array.part.0>

ffffffffc020510e <file_open>:
ffffffffc020510e:	711d                	addi	sp,sp,-96
ffffffffc0205110:	ec86                	sd	ra,88(sp)
ffffffffc0205112:	e8a2                	sd	s0,80(sp)
ffffffffc0205114:	e4a6                	sd	s1,72(sp)
ffffffffc0205116:	e0ca                	sd	s2,64(sp)
ffffffffc0205118:	fc4e                	sd	s3,56(sp)
ffffffffc020511a:	f852                	sd	s4,48(sp)
ffffffffc020511c:	0035f793          	andi	a5,a1,3
ffffffffc0205120:	470d                	li	a4,3
ffffffffc0205122:	0ce78163          	beq	a5,a4,ffffffffc02051e4 <file_open+0xd6>
ffffffffc0205126:	078e                	slli	a5,a5,0x3
ffffffffc0205128:	00008717          	auipc	a4,0x8
ffffffffc020512c:	6e070713          	addi	a4,a4,1760 # ffffffffc020d808 <CSWTCH.79>
ffffffffc0205130:	892a                	mv	s2,a0
ffffffffc0205132:	00008697          	auipc	a3,0x8
ffffffffc0205136:	6be68693          	addi	a3,a3,1726 # ffffffffc020d7f0 <CSWTCH.78>
ffffffffc020513a:	755d                	lui	a0,0xffff7
ffffffffc020513c:	96be                	add	a3,a3,a5
ffffffffc020513e:	84ae                	mv	s1,a1
ffffffffc0205140:	97ba                	add	a5,a5,a4
ffffffffc0205142:	858a                	mv	a1,sp
ffffffffc0205144:	ad950513          	addi	a0,a0,-1319 # ffffffffffff6ad9 <end+0x3fd60181>
ffffffffc0205148:	0006ba03          	ld	s4,0(a3)
ffffffffc020514c:	0007b983          	ld	s3,0(a5)
ffffffffc0205150:	cb1ff0ef          	jal	ra,ffffffffc0204e00 <fd_array_alloc>
ffffffffc0205154:	842a                	mv	s0,a0
ffffffffc0205156:	c911                	beqz	a0,ffffffffc020516a <file_open+0x5c>
ffffffffc0205158:	60e6                	ld	ra,88(sp)
ffffffffc020515a:	8522                	mv	a0,s0
ffffffffc020515c:	6446                	ld	s0,80(sp)
ffffffffc020515e:	64a6                	ld	s1,72(sp)
ffffffffc0205160:	6906                	ld	s2,64(sp)
ffffffffc0205162:	79e2                	ld	s3,56(sp)
ffffffffc0205164:	7a42                	ld	s4,48(sp)
ffffffffc0205166:	6125                	addi	sp,sp,96
ffffffffc0205168:	8082                	ret
ffffffffc020516a:	0030                	addi	a2,sp,8
ffffffffc020516c:	85a6                	mv	a1,s1
ffffffffc020516e:	854a                	mv	a0,s2
ffffffffc0205170:	3d4030ef          	jal	ra,ffffffffc0208544 <vfs_open>
ffffffffc0205174:	842a                	mv	s0,a0
ffffffffc0205176:	e13d                	bnez	a0,ffffffffc02051dc <file_open+0xce>
ffffffffc0205178:	6782                	ld	a5,0(sp)
ffffffffc020517a:	0204f493          	andi	s1,s1,32
ffffffffc020517e:	6422                	ld	s0,8(sp)
ffffffffc0205180:	0207b023          	sd	zero,32(a5)
ffffffffc0205184:	c885                	beqz	s1,ffffffffc02051b4 <file_open+0xa6>
ffffffffc0205186:	c03d                	beqz	s0,ffffffffc02051ec <file_open+0xde>
ffffffffc0205188:	783c                	ld	a5,112(s0)
ffffffffc020518a:	c3ad                	beqz	a5,ffffffffc02051ec <file_open+0xde>
ffffffffc020518c:	779c                	ld	a5,40(a5)
ffffffffc020518e:	cfb9                	beqz	a5,ffffffffc02051ec <file_open+0xde>
ffffffffc0205190:	8522                	mv	a0,s0
ffffffffc0205192:	00008597          	auipc	a1,0x8
ffffffffc0205196:	48e58593          	addi	a1,a1,1166 # ffffffffc020d620 <default_pmm_manager+0x300>
ffffffffc020519a:	1aa030ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc020519e:	783c                	ld	a5,112(s0)
ffffffffc02051a0:	6522                	ld	a0,8(sp)
ffffffffc02051a2:	080c                	addi	a1,sp,16
ffffffffc02051a4:	779c                	ld	a5,40(a5)
ffffffffc02051a6:	9782                	jalr	a5
ffffffffc02051a8:	842a                	mv	s0,a0
ffffffffc02051aa:	e515                	bnez	a0,ffffffffc02051d6 <file_open+0xc8>
ffffffffc02051ac:	6782                	ld	a5,0(sp)
ffffffffc02051ae:	7722                	ld	a4,40(sp)
ffffffffc02051b0:	6422                	ld	s0,8(sp)
ffffffffc02051b2:	f398                	sd	a4,32(a5)
ffffffffc02051b4:	4394                	lw	a3,0(a5)
ffffffffc02051b6:	f780                	sd	s0,40(a5)
ffffffffc02051b8:	0147b423          	sd	s4,8(a5)
ffffffffc02051bc:	0137b823          	sd	s3,16(a5)
ffffffffc02051c0:	4705                	li	a4,1
ffffffffc02051c2:	02e69363          	bne	a3,a4,ffffffffc02051e8 <file_open+0xda>
ffffffffc02051c6:	c00d                	beqz	s0,ffffffffc02051e8 <file_open+0xda>
ffffffffc02051c8:	5b98                	lw	a4,48(a5)
ffffffffc02051ca:	4689                	li	a3,2
ffffffffc02051cc:	4f80                	lw	s0,24(a5)
ffffffffc02051ce:	2705                	addiw	a4,a4,1
ffffffffc02051d0:	c394                	sw	a3,0(a5)
ffffffffc02051d2:	db98                	sw	a4,48(a5)
ffffffffc02051d4:	b751                	j	ffffffffc0205158 <file_open+0x4a>
ffffffffc02051d6:	6522                	ld	a0,8(sp)
ffffffffc02051d8:	512030ef          	jal	ra,ffffffffc02086ea <vfs_close>
ffffffffc02051dc:	6502                	ld	a0,0(sp)
ffffffffc02051de:	cb7ff0ef          	jal	ra,ffffffffc0204e94 <fd_array_free>
ffffffffc02051e2:	bf9d                	j	ffffffffc0205158 <file_open+0x4a>
ffffffffc02051e4:	5475                	li	s0,-3
ffffffffc02051e6:	bf8d                	j	ffffffffc0205158 <file_open+0x4a>
ffffffffc02051e8:	d93ff0ef          	jal	ra,ffffffffc0204f7a <fd_array_open.part.0>
ffffffffc02051ec:	00008697          	auipc	a3,0x8
ffffffffc02051f0:	3e468693          	addi	a3,a3,996 # ffffffffc020d5d0 <default_pmm_manager+0x2b0>
ffffffffc02051f4:	00007617          	auipc	a2,0x7
ffffffffc02051f8:	b2c60613          	addi	a2,a2,-1236 # ffffffffc020bd20 <commands+0x250>
ffffffffc02051fc:	0b500593          	li	a1,181
ffffffffc0205200:	00008517          	auipc	a0,0x8
ffffffffc0205204:	29850513          	addi	a0,a0,664 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0205208:	826fb0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020520c <file_close>:
ffffffffc020520c:	04700713          	li	a4,71
ffffffffc0205210:	04a76563          	bltu	a4,a0,ffffffffc020525a <file_close+0x4e>
ffffffffc0205214:	00091717          	auipc	a4,0x91
ffffffffc0205218:	6f473703          	ld	a4,1780(a4) # ffffffffc0296908 <current>
ffffffffc020521c:	14873703          	ld	a4,328(a4)
ffffffffc0205220:	1141                	addi	sp,sp,-16
ffffffffc0205222:	e406                	sd	ra,8(sp)
ffffffffc0205224:	cf0d                	beqz	a4,ffffffffc020525e <file_close+0x52>
ffffffffc0205226:	4b14                	lw	a3,16(a4)
ffffffffc0205228:	02d05b63          	blez	a3,ffffffffc020525e <file_close+0x52>
ffffffffc020522c:	6718                	ld	a4,8(a4)
ffffffffc020522e:	87aa                	mv	a5,a0
ffffffffc0205230:	050e                	slli	a0,a0,0x3
ffffffffc0205232:	8d1d                	sub	a0,a0,a5
ffffffffc0205234:	050e                	slli	a0,a0,0x3
ffffffffc0205236:	953a                	add	a0,a0,a4
ffffffffc0205238:	4114                	lw	a3,0(a0)
ffffffffc020523a:	4709                	li	a4,2
ffffffffc020523c:	00e69b63          	bne	a3,a4,ffffffffc0205252 <file_close+0x46>
ffffffffc0205240:	4d18                	lw	a4,24(a0)
ffffffffc0205242:	00f71863          	bne	a4,a5,ffffffffc0205252 <file_close+0x46>
ffffffffc0205246:	d75ff0ef          	jal	ra,ffffffffc0204fba <fd_array_close>
ffffffffc020524a:	60a2                	ld	ra,8(sp)
ffffffffc020524c:	4501                	li	a0,0
ffffffffc020524e:	0141                	addi	sp,sp,16
ffffffffc0205250:	8082                	ret
ffffffffc0205252:	60a2                	ld	ra,8(sp)
ffffffffc0205254:	5575                	li	a0,-3
ffffffffc0205256:	0141                	addi	sp,sp,16
ffffffffc0205258:	8082                	ret
ffffffffc020525a:	5575                	li	a0,-3
ffffffffc020525c:	8082                	ret
ffffffffc020525e:	b81ff0ef          	jal	ra,ffffffffc0204dde <get_fd_array.part.0>

ffffffffc0205262 <file_read>:
ffffffffc0205262:	715d                	addi	sp,sp,-80
ffffffffc0205264:	e486                	sd	ra,72(sp)
ffffffffc0205266:	e0a2                	sd	s0,64(sp)
ffffffffc0205268:	fc26                	sd	s1,56(sp)
ffffffffc020526a:	f84a                	sd	s2,48(sp)
ffffffffc020526c:	f44e                	sd	s3,40(sp)
ffffffffc020526e:	f052                	sd	s4,32(sp)
ffffffffc0205270:	0006b023          	sd	zero,0(a3)
ffffffffc0205274:	04700793          	li	a5,71
ffffffffc0205278:	0aa7e463          	bltu	a5,a0,ffffffffc0205320 <file_read+0xbe>
ffffffffc020527c:	00091797          	auipc	a5,0x91
ffffffffc0205280:	68c7b783          	ld	a5,1676(a5) # ffffffffc0296908 <current>
ffffffffc0205284:	1487b783          	ld	a5,328(a5)
ffffffffc0205288:	cfd1                	beqz	a5,ffffffffc0205324 <file_read+0xc2>
ffffffffc020528a:	4b98                	lw	a4,16(a5)
ffffffffc020528c:	08e05c63          	blez	a4,ffffffffc0205324 <file_read+0xc2>
ffffffffc0205290:	6780                	ld	s0,8(a5)
ffffffffc0205292:	00351793          	slli	a5,a0,0x3
ffffffffc0205296:	8f89                	sub	a5,a5,a0
ffffffffc0205298:	078e                	slli	a5,a5,0x3
ffffffffc020529a:	943e                	add	s0,s0,a5
ffffffffc020529c:	00042983          	lw	s3,0(s0)
ffffffffc02052a0:	4789                	li	a5,2
ffffffffc02052a2:	06f99f63          	bne	s3,a5,ffffffffc0205320 <file_read+0xbe>
ffffffffc02052a6:	4c1c                	lw	a5,24(s0)
ffffffffc02052a8:	06a79c63          	bne	a5,a0,ffffffffc0205320 <file_read+0xbe>
ffffffffc02052ac:	641c                	ld	a5,8(s0)
ffffffffc02052ae:	cbad                	beqz	a5,ffffffffc0205320 <file_read+0xbe>
ffffffffc02052b0:	581c                	lw	a5,48(s0)
ffffffffc02052b2:	8a36                	mv	s4,a3
ffffffffc02052b4:	7014                	ld	a3,32(s0)
ffffffffc02052b6:	2785                	addiw	a5,a5,1
ffffffffc02052b8:	850a                	mv	a0,sp
ffffffffc02052ba:	d81c                	sw	a5,48(s0)
ffffffffc02052bc:	57e000ef          	jal	ra,ffffffffc020583a <iobuf_init>
ffffffffc02052c0:	02843903          	ld	s2,40(s0)
ffffffffc02052c4:	84aa                	mv	s1,a0
ffffffffc02052c6:	06090163          	beqz	s2,ffffffffc0205328 <file_read+0xc6>
ffffffffc02052ca:	07093783          	ld	a5,112(s2)
ffffffffc02052ce:	cfa9                	beqz	a5,ffffffffc0205328 <file_read+0xc6>
ffffffffc02052d0:	6f9c                	ld	a5,24(a5)
ffffffffc02052d2:	cbb9                	beqz	a5,ffffffffc0205328 <file_read+0xc6>
ffffffffc02052d4:	00008597          	auipc	a1,0x8
ffffffffc02052d8:	3a458593          	addi	a1,a1,932 # ffffffffc020d678 <default_pmm_manager+0x358>
ffffffffc02052dc:	854a                	mv	a0,s2
ffffffffc02052de:	066030ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc02052e2:	07093783          	ld	a5,112(s2)
ffffffffc02052e6:	7408                	ld	a0,40(s0)
ffffffffc02052e8:	85a6                	mv	a1,s1
ffffffffc02052ea:	6f9c                	ld	a5,24(a5)
ffffffffc02052ec:	9782                	jalr	a5
ffffffffc02052ee:	689c                	ld	a5,16(s1)
ffffffffc02052f0:	6c94                	ld	a3,24(s1)
ffffffffc02052f2:	4018                	lw	a4,0(s0)
ffffffffc02052f4:	84aa                	mv	s1,a0
ffffffffc02052f6:	8f95                	sub	a5,a5,a3
ffffffffc02052f8:	03370063          	beq	a4,s3,ffffffffc0205318 <file_read+0xb6>
ffffffffc02052fc:	00fa3023          	sd	a5,0(s4)
ffffffffc0205300:	8522                	mv	a0,s0
ffffffffc0205302:	c0fff0ef          	jal	ra,ffffffffc0204f10 <fd_array_release>
ffffffffc0205306:	60a6                	ld	ra,72(sp)
ffffffffc0205308:	6406                	ld	s0,64(sp)
ffffffffc020530a:	7942                	ld	s2,48(sp)
ffffffffc020530c:	79a2                	ld	s3,40(sp)
ffffffffc020530e:	7a02                	ld	s4,32(sp)
ffffffffc0205310:	8526                	mv	a0,s1
ffffffffc0205312:	74e2                	ld	s1,56(sp)
ffffffffc0205314:	6161                	addi	sp,sp,80
ffffffffc0205316:	8082                	ret
ffffffffc0205318:	7018                	ld	a4,32(s0)
ffffffffc020531a:	973e                	add	a4,a4,a5
ffffffffc020531c:	f018                	sd	a4,32(s0)
ffffffffc020531e:	bff9                	j	ffffffffc02052fc <file_read+0x9a>
ffffffffc0205320:	54f5                	li	s1,-3
ffffffffc0205322:	b7d5                	j	ffffffffc0205306 <file_read+0xa4>
ffffffffc0205324:	abbff0ef          	jal	ra,ffffffffc0204dde <get_fd_array.part.0>
ffffffffc0205328:	00008697          	auipc	a3,0x8
ffffffffc020532c:	30068693          	addi	a3,a3,768 # ffffffffc020d628 <default_pmm_manager+0x308>
ffffffffc0205330:	00007617          	auipc	a2,0x7
ffffffffc0205334:	9f060613          	addi	a2,a2,-1552 # ffffffffc020bd20 <commands+0x250>
ffffffffc0205338:	0de00593          	li	a1,222
ffffffffc020533c:	00008517          	auipc	a0,0x8
ffffffffc0205340:	15c50513          	addi	a0,a0,348 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0205344:	eebfa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0205348 <file_write>:
ffffffffc0205348:	715d                	addi	sp,sp,-80
ffffffffc020534a:	e486                	sd	ra,72(sp)
ffffffffc020534c:	e0a2                	sd	s0,64(sp)
ffffffffc020534e:	fc26                	sd	s1,56(sp)
ffffffffc0205350:	f84a                	sd	s2,48(sp)
ffffffffc0205352:	f44e                	sd	s3,40(sp)
ffffffffc0205354:	f052                	sd	s4,32(sp)
ffffffffc0205356:	0006b023          	sd	zero,0(a3)
ffffffffc020535a:	04700793          	li	a5,71
ffffffffc020535e:	0aa7e463          	bltu	a5,a0,ffffffffc0205406 <file_write+0xbe>
ffffffffc0205362:	00091797          	auipc	a5,0x91
ffffffffc0205366:	5a67b783          	ld	a5,1446(a5) # ffffffffc0296908 <current>
ffffffffc020536a:	1487b783          	ld	a5,328(a5)
ffffffffc020536e:	cfd1                	beqz	a5,ffffffffc020540a <file_write+0xc2>
ffffffffc0205370:	4b98                	lw	a4,16(a5)
ffffffffc0205372:	08e05c63          	blez	a4,ffffffffc020540a <file_write+0xc2>
ffffffffc0205376:	6780                	ld	s0,8(a5)
ffffffffc0205378:	00351793          	slli	a5,a0,0x3
ffffffffc020537c:	8f89                	sub	a5,a5,a0
ffffffffc020537e:	078e                	slli	a5,a5,0x3
ffffffffc0205380:	943e                	add	s0,s0,a5
ffffffffc0205382:	00042983          	lw	s3,0(s0)
ffffffffc0205386:	4789                	li	a5,2
ffffffffc0205388:	06f99f63          	bne	s3,a5,ffffffffc0205406 <file_write+0xbe>
ffffffffc020538c:	4c1c                	lw	a5,24(s0)
ffffffffc020538e:	06a79c63          	bne	a5,a0,ffffffffc0205406 <file_write+0xbe>
ffffffffc0205392:	681c                	ld	a5,16(s0)
ffffffffc0205394:	cbad                	beqz	a5,ffffffffc0205406 <file_write+0xbe>
ffffffffc0205396:	581c                	lw	a5,48(s0)
ffffffffc0205398:	8a36                	mv	s4,a3
ffffffffc020539a:	7014                	ld	a3,32(s0)
ffffffffc020539c:	2785                	addiw	a5,a5,1
ffffffffc020539e:	850a                	mv	a0,sp
ffffffffc02053a0:	d81c                	sw	a5,48(s0)
ffffffffc02053a2:	498000ef          	jal	ra,ffffffffc020583a <iobuf_init>
ffffffffc02053a6:	02843903          	ld	s2,40(s0)
ffffffffc02053aa:	84aa                	mv	s1,a0
ffffffffc02053ac:	06090163          	beqz	s2,ffffffffc020540e <file_write+0xc6>
ffffffffc02053b0:	07093783          	ld	a5,112(s2)
ffffffffc02053b4:	cfa9                	beqz	a5,ffffffffc020540e <file_write+0xc6>
ffffffffc02053b6:	739c                	ld	a5,32(a5)
ffffffffc02053b8:	cbb9                	beqz	a5,ffffffffc020540e <file_write+0xc6>
ffffffffc02053ba:	00008597          	auipc	a1,0x8
ffffffffc02053be:	31658593          	addi	a1,a1,790 # ffffffffc020d6d0 <default_pmm_manager+0x3b0>
ffffffffc02053c2:	854a                	mv	a0,s2
ffffffffc02053c4:	781020ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc02053c8:	07093783          	ld	a5,112(s2)
ffffffffc02053cc:	7408                	ld	a0,40(s0)
ffffffffc02053ce:	85a6                	mv	a1,s1
ffffffffc02053d0:	739c                	ld	a5,32(a5)
ffffffffc02053d2:	9782                	jalr	a5
ffffffffc02053d4:	689c                	ld	a5,16(s1)
ffffffffc02053d6:	6c94                	ld	a3,24(s1)
ffffffffc02053d8:	4018                	lw	a4,0(s0)
ffffffffc02053da:	84aa                	mv	s1,a0
ffffffffc02053dc:	8f95                	sub	a5,a5,a3
ffffffffc02053de:	03370063          	beq	a4,s3,ffffffffc02053fe <file_write+0xb6>
ffffffffc02053e2:	00fa3023          	sd	a5,0(s4)
ffffffffc02053e6:	8522                	mv	a0,s0
ffffffffc02053e8:	b29ff0ef          	jal	ra,ffffffffc0204f10 <fd_array_release>
ffffffffc02053ec:	60a6                	ld	ra,72(sp)
ffffffffc02053ee:	6406                	ld	s0,64(sp)
ffffffffc02053f0:	7942                	ld	s2,48(sp)
ffffffffc02053f2:	79a2                	ld	s3,40(sp)
ffffffffc02053f4:	7a02                	ld	s4,32(sp)
ffffffffc02053f6:	8526                	mv	a0,s1
ffffffffc02053f8:	74e2                	ld	s1,56(sp)
ffffffffc02053fa:	6161                	addi	sp,sp,80
ffffffffc02053fc:	8082                	ret
ffffffffc02053fe:	7018                	ld	a4,32(s0)
ffffffffc0205400:	973e                	add	a4,a4,a5
ffffffffc0205402:	f018                	sd	a4,32(s0)
ffffffffc0205404:	bff9                	j	ffffffffc02053e2 <file_write+0x9a>
ffffffffc0205406:	54f5                	li	s1,-3
ffffffffc0205408:	b7d5                	j	ffffffffc02053ec <file_write+0xa4>
ffffffffc020540a:	9d5ff0ef          	jal	ra,ffffffffc0204dde <get_fd_array.part.0>
ffffffffc020540e:	00008697          	auipc	a3,0x8
ffffffffc0205412:	27268693          	addi	a3,a3,626 # ffffffffc020d680 <default_pmm_manager+0x360>
ffffffffc0205416:	00007617          	auipc	a2,0x7
ffffffffc020541a:	90a60613          	addi	a2,a2,-1782 # ffffffffc020bd20 <commands+0x250>
ffffffffc020541e:	0f800593          	li	a1,248
ffffffffc0205422:	00008517          	auipc	a0,0x8
ffffffffc0205426:	07650513          	addi	a0,a0,118 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc020542a:	e05fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020542e <file_seek>:
ffffffffc020542e:	7139                	addi	sp,sp,-64
ffffffffc0205430:	fc06                	sd	ra,56(sp)
ffffffffc0205432:	f822                	sd	s0,48(sp)
ffffffffc0205434:	f426                	sd	s1,40(sp)
ffffffffc0205436:	f04a                	sd	s2,32(sp)
ffffffffc0205438:	04700793          	li	a5,71
ffffffffc020543c:	08a7e863          	bltu	a5,a0,ffffffffc02054cc <file_seek+0x9e>
ffffffffc0205440:	00091797          	auipc	a5,0x91
ffffffffc0205444:	4c87b783          	ld	a5,1224(a5) # ffffffffc0296908 <current>
ffffffffc0205448:	1487b783          	ld	a5,328(a5)
ffffffffc020544c:	cfdd                	beqz	a5,ffffffffc020550a <file_seek+0xdc>
ffffffffc020544e:	4b98                	lw	a4,16(a5)
ffffffffc0205450:	0ae05d63          	blez	a4,ffffffffc020550a <file_seek+0xdc>
ffffffffc0205454:	6780                	ld	s0,8(a5)
ffffffffc0205456:	00351793          	slli	a5,a0,0x3
ffffffffc020545a:	8f89                	sub	a5,a5,a0
ffffffffc020545c:	078e                	slli	a5,a5,0x3
ffffffffc020545e:	943e                	add	s0,s0,a5
ffffffffc0205460:	4018                	lw	a4,0(s0)
ffffffffc0205462:	4789                	li	a5,2
ffffffffc0205464:	06f71463          	bne	a4,a5,ffffffffc02054cc <file_seek+0x9e>
ffffffffc0205468:	4c1c                	lw	a5,24(s0)
ffffffffc020546a:	06a79163          	bne	a5,a0,ffffffffc02054cc <file_seek+0x9e>
ffffffffc020546e:	581c                	lw	a5,48(s0)
ffffffffc0205470:	4685                	li	a3,1
ffffffffc0205472:	892e                	mv	s2,a1
ffffffffc0205474:	2785                	addiw	a5,a5,1
ffffffffc0205476:	d81c                	sw	a5,48(s0)
ffffffffc0205478:	02d60063          	beq	a2,a3,ffffffffc0205498 <file_seek+0x6a>
ffffffffc020547c:	06e60063          	beq	a2,a4,ffffffffc02054dc <file_seek+0xae>
ffffffffc0205480:	54f5                	li	s1,-3
ffffffffc0205482:	ce11                	beqz	a2,ffffffffc020549e <file_seek+0x70>
ffffffffc0205484:	8522                	mv	a0,s0
ffffffffc0205486:	a8bff0ef          	jal	ra,ffffffffc0204f10 <fd_array_release>
ffffffffc020548a:	70e2                	ld	ra,56(sp)
ffffffffc020548c:	7442                	ld	s0,48(sp)
ffffffffc020548e:	7902                	ld	s2,32(sp)
ffffffffc0205490:	8526                	mv	a0,s1
ffffffffc0205492:	74a2                	ld	s1,40(sp)
ffffffffc0205494:	6121                	addi	sp,sp,64
ffffffffc0205496:	8082                	ret
ffffffffc0205498:	701c                	ld	a5,32(s0)
ffffffffc020549a:	00f58933          	add	s2,a1,a5
ffffffffc020549e:	7404                	ld	s1,40(s0)
ffffffffc02054a0:	c4bd                	beqz	s1,ffffffffc020550e <file_seek+0xe0>
ffffffffc02054a2:	78bc                	ld	a5,112(s1)
ffffffffc02054a4:	c7ad                	beqz	a5,ffffffffc020550e <file_seek+0xe0>
ffffffffc02054a6:	6fbc                	ld	a5,88(a5)
ffffffffc02054a8:	c3bd                	beqz	a5,ffffffffc020550e <file_seek+0xe0>
ffffffffc02054aa:	8526                	mv	a0,s1
ffffffffc02054ac:	00008597          	auipc	a1,0x8
ffffffffc02054b0:	27c58593          	addi	a1,a1,636 # ffffffffc020d728 <default_pmm_manager+0x408>
ffffffffc02054b4:	691020ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc02054b8:	78bc                	ld	a5,112(s1)
ffffffffc02054ba:	7408                	ld	a0,40(s0)
ffffffffc02054bc:	85ca                	mv	a1,s2
ffffffffc02054be:	6fbc                	ld	a5,88(a5)
ffffffffc02054c0:	9782                	jalr	a5
ffffffffc02054c2:	84aa                	mv	s1,a0
ffffffffc02054c4:	f161                	bnez	a0,ffffffffc0205484 <file_seek+0x56>
ffffffffc02054c6:	03243023          	sd	s2,32(s0)
ffffffffc02054ca:	bf6d                	j	ffffffffc0205484 <file_seek+0x56>
ffffffffc02054cc:	70e2                	ld	ra,56(sp)
ffffffffc02054ce:	7442                	ld	s0,48(sp)
ffffffffc02054d0:	54f5                	li	s1,-3
ffffffffc02054d2:	7902                	ld	s2,32(sp)
ffffffffc02054d4:	8526                	mv	a0,s1
ffffffffc02054d6:	74a2                	ld	s1,40(sp)
ffffffffc02054d8:	6121                	addi	sp,sp,64
ffffffffc02054da:	8082                	ret
ffffffffc02054dc:	7404                	ld	s1,40(s0)
ffffffffc02054de:	c8a1                	beqz	s1,ffffffffc020552e <file_seek+0x100>
ffffffffc02054e0:	78bc                	ld	a5,112(s1)
ffffffffc02054e2:	c7b1                	beqz	a5,ffffffffc020552e <file_seek+0x100>
ffffffffc02054e4:	779c                	ld	a5,40(a5)
ffffffffc02054e6:	c7a1                	beqz	a5,ffffffffc020552e <file_seek+0x100>
ffffffffc02054e8:	8526                	mv	a0,s1
ffffffffc02054ea:	00008597          	auipc	a1,0x8
ffffffffc02054ee:	13658593          	addi	a1,a1,310 # ffffffffc020d620 <default_pmm_manager+0x300>
ffffffffc02054f2:	653020ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc02054f6:	78bc                	ld	a5,112(s1)
ffffffffc02054f8:	7408                	ld	a0,40(s0)
ffffffffc02054fa:	858a                	mv	a1,sp
ffffffffc02054fc:	779c                	ld	a5,40(a5)
ffffffffc02054fe:	9782                	jalr	a5
ffffffffc0205500:	84aa                	mv	s1,a0
ffffffffc0205502:	f149                	bnez	a0,ffffffffc0205484 <file_seek+0x56>
ffffffffc0205504:	67e2                	ld	a5,24(sp)
ffffffffc0205506:	993e                	add	s2,s2,a5
ffffffffc0205508:	bf59                	j	ffffffffc020549e <file_seek+0x70>
ffffffffc020550a:	8d5ff0ef          	jal	ra,ffffffffc0204dde <get_fd_array.part.0>
ffffffffc020550e:	00008697          	auipc	a3,0x8
ffffffffc0205512:	1ca68693          	addi	a3,a3,458 # ffffffffc020d6d8 <default_pmm_manager+0x3b8>
ffffffffc0205516:	00007617          	auipc	a2,0x7
ffffffffc020551a:	80a60613          	addi	a2,a2,-2038 # ffffffffc020bd20 <commands+0x250>
ffffffffc020551e:	11a00593          	li	a1,282
ffffffffc0205522:	00008517          	auipc	a0,0x8
ffffffffc0205526:	f7650513          	addi	a0,a0,-138 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc020552a:	d05fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020552e:	00008697          	auipc	a3,0x8
ffffffffc0205532:	0a268693          	addi	a3,a3,162 # ffffffffc020d5d0 <default_pmm_manager+0x2b0>
ffffffffc0205536:	00006617          	auipc	a2,0x6
ffffffffc020553a:	7ea60613          	addi	a2,a2,2026 # ffffffffc020bd20 <commands+0x250>
ffffffffc020553e:	11200593          	li	a1,274
ffffffffc0205542:	00008517          	auipc	a0,0x8
ffffffffc0205546:	f5650513          	addi	a0,a0,-170 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc020554a:	ce5fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020554e <file_fstat>:
ffffffffc020554e:	1101                	addi	sp,sp,-32
ffffffffc0205550:	ec06                	sd	ra,24(sp)
ffffffffc0205552:	e822                	sd	s0,16(sp)
ffffffffc0205554:	e426                	sd	s1,8(sp)
ffffffffc0205556:	e04a                	sd	s2,0(sp)
ffffffffc0205558:	04700793          	li	a5,71
ffffffffc020555c:	06a7ef63          	bltu	a5,a0,ffffffffc02055da <file_fstat+0x8c>
ffffffffc0205560:	00091797          	auipc	a5,0x91
ffffffffc0205564:	3a87b783          	ld	a5,936(a5) # ffffffffc0296908 <current>
ffffffffc0205568:	1487b783          	ld	a5,328(a5)
ffffffffc020556c:	cfd9                	beqz	a5,ffffffffc020560a <file_fstat+0xbc>
ffffffffc020556e:	4b98                	lw	a4,16(a5)
ffffffffc0205570:	08e05d63          	blez	a4,ffffffffc020560a <file_fstat+0xbc>
ffffffffc0205574:	6780                	ld	s0,8(a5)
ffffffffc0205576:	00351793          	slli	a5,a0,0x3
ffffffffc020557a:	8f89                	sub	a5,a5,a0
ffffffffc020557c:	078e                	slli	a5,a5,0x3
ffffffffc020557e:	943e                	add	s0,s0,a5
ffffffffc0205580:	4018                	lw	a4,0(s0)
ffffffffc0205582:	4789                	li	a5,2
ffffffffc0205584:	04f71b63          	bne	a4,a5,ffffffffc02055da <file_fstat+0x8c>
ffffffffc0205588:	4c1c                	lw	a5,24(s0)
ffffffffc020558a:	04a79863          	bne	a5,a0,ffffffffc02055da <file_fstat+0x8c>
ffffffffc020558e:	581c                	lw	a5,48(s0)
ffffffffc0205590:	02843903          	ld	s2,40(s0)
ffffffffc0205594:	2785                	addiw	a5,a5,1
ffffffffc0205596:	d81c                	sw	a5,48(s0)
ffffffffc0205598:	04090963          	beqz	s2,ffffffffc02055ea <file_fstat+0x9c>
ffffffffc020559c:	07093783          	ld	a5,112(s2)
ffffffffc02055a0:	c7a9                	beqz	a5,ffffffffc02055ea <file_fstat+0x9c>
ffffffffc02055a2:	779c                	ld	a5,40(a5)
ffffffffc02055a4:	c3b9                	beqz	a5,ffffffffc02055ea <file_fstat+0x9c>
ffffffffc02055a6:	84ae                	mv	s1,a1
ffffffffc02055a8:	854a                	mv	a0,s2
ffffffffc02055aa:	00008597          	auipc	a1,0x8
ffffffffc02055ae:	07658593          	addi	a1,a1,118 # ffffffffc020d620 <default_pmm_manager+0x300>
ffffffffc02055b2:	593020ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc02055b6:	07093783          	ld	a5,112(s2)
ffffffffc02055ba:	7408                	ld	a0,40(s0)
ffffffffc02055bc:	85a6                	mv	a1,s1
ffffffffc02055be:	779c                	ld	a5,40(a5)
ffffffffc02055c0:	9782                	jalr	a5
ffffffffc02055c2:	87aa                	mv	a5,a0
ffffffffc02055c4:	8522                	mv	a0,s0
ffffffffc02055c6:	843e                	mv	s0,a5
ffffffffc02055c8:	949ff0ef          	jal	ra,ffffffffc0204f10 <fd_array_release>
ffffffffc02055cc:	60e2                	ld	ra,24(sp)
ffffffffc02055ce:	8522                	mv	a0,s0
ffffffffc02055d0:	6442                	ld	s0,16(sp)
ffffffffc02055d2:	64a2                	ld	s1,8(sp)
ffffffffc02055d4:	6902                	ld	s2,0(sp)
ffffffffc02055d6:	6105                	addi	sp,sp,32
ffffffffc02055d8:	8082                	ret
ffffffffc02055da:	5475                	li	s0,-3
ffffffffc02055dc:	60e2                	ld	ra,24(sp)
ffffffffc02055de:	8522                	mv	a0,s0
ffffffffc02055e0:	6442                	ld	s0,16(sp)
ffffffffc02055e2:	64a2                	ld	s1,8(sp)
ffffffffc02055e4:	6902                	ld	s2,0(sp)
ffffffffc02055e6:	6105                	addi	sp,sp,32
ffffffffc02055e8:	8082                	ret
ffffffffc02055ea:	00008697          	auipc	a3,0x8
ffffffffc02055ee:	fe668693          	addi	a3,a3,-26 # ffffffffc020d5d0 <default_pmm_manager+0x2b0>
ffffffffc02055f2:	00006617          	auipc	a2,0x6
ffffffffc02055f6:	72e60613          	addi	a2,a2,1838 # ffffffffc020bd20 <commands+0x250>
ffffffffc02055fa:	12c00593          	li	a1,300
ffffffffc02055fe:	00008517          	auipc	a0,0x8
ffffffffc0205602:	e9a50513          	addi	a0,a0,-358 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc0205606:	c29fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020560a:	fd4ff0ef          	jal	ra,ffffffffc0204dde <get_fd_array.part.0>

ffffffffc020560e <file_fsync>:
ffffffffc020560e:	1101                	addi	sp,sp,-32
ffffffffc0205610:	ec06                	sd	ra,24(sp)
ffffffffc0205612:	e822                	sd	s0,16(sp)
ffffffffc0205614:	e426                	sd	s1,8(sp)
ffffffffc0205616:	04700793          	li	a5,71
ffffffffc020561a:	06a7e863          	bltu	a5,a0,ffffffffc020568a <file_fsync+0x7c>
ffffffffc020561e:	00091797          	auipc	a5,0x91
ffffffffc0205622:	2ea7b783          	ld	a5,746(a5) # ffffffffc0296908 <current>
ffffffffc0205626:	1487b783          	ld	a5,328(a5)
ffffffffc020562a:	c7d9                	beqz	a5,ffffffffc02056b8 <file_fsync+0xaa>
ffffffffc020562c:	4b98                	lw	a4,16(a5)
ffffffffc020562e:	08e05563          	blez	a4,ffffffffc02056b8 <file_fsync+0xaa>
ffffffffc0205632:	6780                	ld	s0,8(a5)
ffffffffc0205634:	00351793          	slli	a5,a0,0x3
ffffffffc0205638:	8f89                	sub	a5,a5,a0
ffffffffc020563a:	078e                	slli	a5,a5,0x3
ffffffffc020563c:	943e                	add	s0,s0,a5
ffffffffc020563e:	4018                	lw	a4,0(s0)
ffffffffc0205640:	4789                	li	a5,2
ffffffffc0205642:	04f71463          	bne	a4,a5,ffffffffc020568a <file_fsync+0x7c>
ffffffffc0205646:	4c1c                	lw	a5,24(s0)
ffffffffc0205648:	04a79163          	bne	a5,a0,ffffffffc020568a <file_fsync+0x7c>
ffffffffc020564c:	581c                	lw	a5,48(s0)
ffffffffc020564e:	7404                	ld	s1,40(s0)
ffffffffc0205650:	2785                	addiw	a5,a5,1
ffffffffc0205652:	d81c                	sw	a5,48(s0)
ffffffffc0205654:	c0b1                	beqz	s1,ffffffffc0205698 <file_fsync+0x8a>
ffffffffc0205656:	78bc                	ld	a5,112(s1)
ffffffffc0205658:	c3a1                	beqz	a5,ffffffffc0205698 <file_fsync+0x8a>
ffffffffc020565a:	7b9c                	ld	a5,48(a5)
ffffffffc020565c:	cf95                	beqz	a5,ffffffffc0205698 <file_fsync+0x8a>
ffffffffc020565e:	00008597          	auipc	a1,0x8
ffffffffc0205662:	12258593          	addi	a1,a1,290 # ffffffffc020d780 <default_pmm_manager+0x460>
ffffffffc0205666:	8526                	mv	a0,s1
ffffffffc0205668:	4dd020ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc020566c:	78bc                	ld	a5,112(s1)
ffffffffc020566e:	7408                	ld	a0,40(s0)
ffffffffc0205670:	7b9c                	ld	a5,48(a5)
ffffffffc0205672:	9782                	jalr	a5
ffffffffc0205674:	87aa                	mv	a5,a0
ffffffffc0205676:	8522                	mv	a0,s0
ffffffffc0205678:	843e                	mv	s0,a5
ffffffffc020567a:	897ff0ef          	jal	ra,ffffffffc0204f10 <fd_array_release>
ffffffffc020567e:	60e2                	ld	ra,24(sp)
ffffffffc0205680:	8522                	mv	a0,s0
ffffffffc0205682:	6442                	ld	s0,16(sp)
ffffffffc0205684:	64a2                	ld	s1,8(sp)
ffffffffc0205686:	6105                	addi	sp,sp,32
ffffffffc0205688:	8082                	ret
ffffffffc020568a:	5475                	li	s0,-3
ffffffffc020568c:	60e2                	ld	ra,24(sp)
ffffffffc020568e:	8522                	mv	a0,s0
ffffffffc0205690:	6442                	ld	s0,16(sp)
ffffffffc0205692:	64a2                	ld	s1,8(sp)
ffffffffc0205694:	6105                	addi	sp,sp,32
ffffffffc0205696:	8082                	ret
ffffffffc0205698:	00008697          	auipc	a3,0x8
ffffffffc020569c:	09868693          	addi	a3,a3,152 # ffffffffc020d730 <default_pmm_manager+0x410>
ffffffffc02056a0:	00006617          	auipc	a2,0x6
ffffffffc02056a4:	68060613          	addi	a2,a2,1664 # ffffffffc020bd20 <commands+0x250>
ffffffffc02056a8:	13a00593          	li	a1,314
ffffffffc02056ac:	00008517          	auipc	a0,0x8
ffffffffc02056b0:	dec50513          	addi	a0,a0,-532 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc02056b4:	b7bfa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02056b8:	f26ff0ef          	jal	ra,ffffffffc0204dde <get_fd_array.part.0>

ffffffffc02056bc <file_getdirentry>:
ffffffffc02056bc:	715d                	addi	sp,sp,-80
ffffffffc02056be:	e486                	sd	ra,72(sp)
ffffffffc02056c0:	e0a2                	sd	s0,64(sp)
ffffffffc02056c2:	fc26                	sd	s1,56(sp)
ffffffffc02056c4:	f84a                	sd	s2,48(sp)
ffffffffc02056c6:	f44e                	sd	s3,40(sp)
ffffffffc02056c8:	04700793          	li	a5,71
ffffffffc02056cc:	0aa7e063          	bltu	a5,a0,ffffffffc020576c <file_getdirentry+0xb0>
ffffffffc02056d0:	00091797          	auipc	a5,0x91
ffffffffc02056d4:	2387b783          	ld	a5,568(a5) # ffffffffc0296908 <current>
ffffffffc02056d8:	1487b783          	ld	a5,328(a5)
ffffffffc02056dc:	c3e9                	beqz	a5,ffffffffc020579e <file_getdirentry+0xe2>
ffffffffc02056de:	4b98                	lw	a4,16(a5)
ffffffffc02056e0:	0ae05f63          	blez	a4,ffffffffc020579e <file_getdirentry+0xe2>
ffffffffc02056e4:	6780                	ld	s0,8(a5)
ffffffffc02056e6:	00351793          	slli	a5,a0,0x3
ffffffffc02056ea:	8f89                	sub	a5,a5,a0
ffffffffc02056ec:	078e                	slli	a5,a5,0x3
ffffffffc02056ee:	943e                	add	s0,s0,a5
ffffffffc02056f0:	4018                	lw	a4,0(s0)
ffffffffc02056f2:	4789                	li	a5,2
ffffffffc02056f4:	06f71c63          	bne	a4,a5,ffffffffc020576c <file_getdirentry+0xb0>
ffffffffc02056f8:	4c1c                	lw	a5,24(s0)
ffffffffc02056fa:	06a79963          	bne	a5,a0,ffffffffc020576c <file_getdirentry+0xb0>
ffffffffc02056fe:	581c                	lw	a5,48(s0)
ffffffffc0205700:	6194                	ld	a3,0(a1)
ffffffffc0205702:	84ae                	mv	s1,a1
ffffffffc0205704:	2785                	addiw	a5,a5,1
ffffffffc0205706:	10000613          	li	a2,256
ffffffffc020570a:	d81c                	sw	a5,48(s0)
ffffffffc020570c:	05a1                	addi	a1,a1,8
ffffffffc020570e:	850a                	mv	a0,sp
ffffffffc0205710:	12a000ef          	jal	ra,ffffffffc020583a <iobuf_init>
ffffffffc0205714:	02843983          	ld	s3,40(s0)
ffffffffc0205718:	892a                	mv	s2,a0
ffffffffc020571a:	06098263          	beqz	s3,ffffffffc020577e <file_getdirentry+0xc2>
ffffffffc020571e:	0709b783          	ld	a5,112(s3)
ffffffffc0205722:	cfb1                	beqz	a5,ffffffffc020577e <file_getdirentry+0xc2>
ffffffffc0205724:	63bc                	ld	a5,64(a5)
ffffffffc0205726:	cfa1                	beqz	a5,ffffffffc020577e <file_getdirentry+0xc2>
ffffffffc0205728:	854e                	mv	a0,s3
ffffffffc020572a:	00008597          	auipc	a1,0x8
ffffffffc020572e:	0b658593          	addi	a1,a1,182 # ffffffffc020d7e0 <default_pmm_manager+0x4c0>
ffffffffc0205732:	413020ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc0205736:	0709b783          	ld	a5,112(s3)
ffffffffc020573a:	7408                	ld	a0,40(s0)
ffffffffc020573c:	85ca                	mv	a1,s2
ffffffffc020573e:	63bc                	ld	a5,64(a5)
ffffffffc0205740:	9782                	jalr	a5
ffffffffc0205742:	89aa                	mv	s3,a0
ffffffffc0205744:	e909                	bnez	a0,ffffffffc0205756 <file_getdirentry+0x9a>
ffffffffc0205746:	609c                	ld	a5,0(s1)
ffffffffc0205748:	01093683          	ld	a3,16(s2)
ffffffffc020574c:	01893703          	ld	a4,24(s2)
ffffffffc0205750:	97b6                	add	a5,a5,a3
ffffffffc0205752:	8f99                	sub	a5,a5,a4
ffffffffc0205754:	e09c                	sd	a5,0(s1)
ffffffffc0205756:	8522                	mv	a0,s0
ffffffffc0205758:	fb8ff0ef          	jal	ra,ffffffffc0204f10 <fd_array_release>
ffffffffc020575c:	60a6                	ld	ra,72(sp)
ffffffffc020575e:	6406                	ld	s0,64(sp)
ffffffffc0205760:	74e2                	ld	s1,56(sp)
ffffffffc0205762:	7942                	ld	s2,48(sp)
ffffffffc0205764:	854e                	mv	a0,s3
ffffffffc0205766:	79a2                	ld	s3,40(sp)
ffffffffc0205768:	6161                	addi	sp,sp,80
ffffffffc020576a:	8082                	ret
ffffffffc020576c:	60a6                	ld	ra,72(sp)
ffffffffc020576e:	6406                	ld	s0,64(sp)
ffffffffc0205770:	59f5                	li	s3,-3
ffffffffc0205772:	74e2                	ld	s1,56(sp)
ffffffffc0205774:	7942                	ld	s2,48(sp)
ffffffffc0205776:	854e                	mv	a0,s3
ffffffffc0205778:	79a2                	ld	s3,40(sp)
ffffffffc020577a:	6161                	addi	sp,sp,80
ffffffffc020577c:	8082                	ret
ffffffffc020577e:	00008697          	auipc	a3,0x8
ffffffffc0205782:	00a68693          	addi	a3,a3,10 # ffffffffc020d788 <default_pmm_manager+0x468>
ffffffffc0205786:	00006617          	auipc	a2,0x6
ffffffffc020578a:	59a60613          	addi	a2,a2,1434 # ffffffffc020bd20 <commands+0x250>
ffffffffc020578e:	14a00593          	li	a1,330
ffffffffc0205792:	00008517          	auipc	a0,0x8
ffffffffc0205796:	d0650513          	addi	a0,a0,-762 # ffffffffc020d498 <default_pmm_manager+0x178>
ffffffffc020579a:	a95fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020579e:	e40ff0ef          	jal	ra,ffffffffc0204dde <get_fd_array.part.0>

ffffffffc02057a2 <file_dup>:
ffffffffc02057a2:	04700713          	li	a4,71
ffffffffc02057a6:	06a76463          	bltu	a4,a0,ffffffffc020580e <file_dup+0x6c>
ffffffffc02057aa:	00091717          	auipc	a4,0x91
ffffffffc02057ae:	15e73703          	ld	a4,350(a4) # ffffffffc0296908 <current>
ffffffffc02057b2:	14873703          	ld	a4,328(a4)
ffffffffc02057b6:	1101                	addi	sp,sp,-32
ffffffffc02057b8:	ec06                	sd	ra,24(sp)
ffffffffc02057ba:	e822                	sd	s0,16(sp)
ffffffffc02057bc:	cb39                	beqz	a4,ffffffffc0205812 <file_dup+0x70>
ffffffffc02057be:	4b14                	lw	a3,16(a4)
ffffffffc02057c0:	04d05963          	blez	a3,ffffffffc0205812 <file_dup+0x70>
ffffffffc02057c4:	6700                	ld	s0,8(a4)
ffffffffc02057c6:	00351713          	slli	a4,a0,0x3
ffffffffc02057ca:	8f09                	sub	a4,a4,a0
ffffffffc02057cc:	070e                	slli	a4,a4,0x3
ffffffffc02057ce:	943a                	add	s0,s0,a4
ffffffffc02057d0:	4014                	lw	a3,0(s0)
ffffffffc02057d2:	4709                	li	a4,2
ffffffffc02057d4:	02e69863          	bne	a3,a4,ffffffffc0205804 <file_dup+0x62>
ffffffffc02057d8:	4c18                	lw	a4,24(s0)
ffffffffc02057da:	02a71563          	bne	a4,a0,ffffffffc0205804 <file_dup+0x62>
ffffffffc02057de:	852e                	mv	a0,a1
ffffffffc02057e0:	002c                	addi	a1,sp,8
ffffffffc02057e2:	e1eff0ef          	jal	ra,ffffffffc0204e00 <fd_array_alloc>
ffffffffc02057e6:	c509                	beqz	a0,ffffffffc02057f0 <file_dup+0x4e>
ffffffffc02057e8:	60e2                	ld	ra,24(sp)
ffffffffc02057ea:	6442                	ld	s0,16(sp)
ffffffffc02057ec:	6105                	addi	sp,sp,32
ffffffffc02057ee:	8082                	ret
ffffffffc02057f0:	6522                	ld	a0,8(sp)
ffffffffc02057f2:	85a2                	mv	a1,s0
ffffffffc02057f4:	845ff0ef          	jal	ra,ffffffffc0205038 <fd_array_dup>
ffffffffc02057f8:	67a2                	ld	a5,8(sp)
ffffffffc02057fa:	60e2                	ld	ra,24(sp)
ffffffffc02057fc:	6442                	ld	s0,16(sp)
ffffffffc02057fe:	4f88                	lw	a0,24(a5)
ffffffffc0205800:	6105                	addi	sp,sp,32
ffffffffc0205802:	8082                	ret
ffffffffc0205804:	60e2                	ld	ra,24(sp)
ffffffffc0205806:	6442                	ld	s0,16(sp)
ffffffffc0205808:	5575                	li	a0,-3
ffffffffc020580a:	6105                	addi	sp,sp,32
ffffffffc020580c:	8082                	ret
ffffffffc020580e:	5575                	li	a0,-3
ffffffffc0205810:	8082                	ret
ffffffffc0205812:	dccff0ef          	jal	ra,ffffffffc0204dde <get_fd_array.part.0>

ffffffffc0205816 <iobuf_skip.part.0>:
ffffffffc0205816:	1141                	addi	sp,sp,-16
ffffffffc0205818:	00008697          	auipc	a3,0x8
ffffffffc020581c:	00868693          	addi	a3,a3,8 # ffffffffc020d820 <CSWTCH.79+0x18>
ffffffffc0205820:	00006617          	auipc	a2,0x6
ffffffffc0205824:	50060613          	addi	a2,a2,1280 # ffffffffc020bd20 <commands+0x250>
ffffffffc0205828:	04a00593          	li	a1,74
ffffffffc020582c:	00008517          	auipc	a0,0x8
ffffffffc0205830:	00c50513          	addi	a0,a0,12 # ffffffffc020d838 <CSWTCH.79+0x30>
ffffffffc0205834:	e406                	sd	ra,8(sp)
ffffffffc0205836:	9f9fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020583a <iobuf_init>:
ffffffffc020583a:	e10c                	sd	a1,0(a0)
ffffffffc020583c:	e514                	sd	a3,8(a0)
ffffffffc020583e:	ed10                	sd	a2,24(a0)
ffffffffc0205840:	e910                	sd	a2,16(a0)
ffffffffc0205842:	8082                	ret

ffffffffc0205844 <iobuf_move>:
ffffffffc0205844:	7179                	addi	sp,sp,-48
ffffffffc0205846:	ec26                	sd	s1,24(sp)
ffffffffc0205848:	6d04                	ld	s1,24(a0)
ffffffffc020584a:	f022                	sd	s0,32(sp)
ffffffffc020584c:	e84a                	sd	s2,16(sp)
ffffffffc020584e:	e44e                	sd	s3,8(sp)
ffffffffc0205850:	f406                	sd	ra,40(sp)
ffffffffc0205852:	842a                	mv	s0,a0
ffffffffc0205854:	8932                	mv	s2,a2
ffffffffc0205856:	852e                	mv	a0,a1
ffffffffc0205858:	89ba                	mv	s3,a4
ffffffffc020585a:	00967363          	bgeu	a2,s1,ffffffffc0205860 <iobuf_move+0x1c>
ffffffffc020585e:	84b2                	mv	s1,a2
ffffffffc0205860:	c495                	beqz	s1,ffffffffc020588c <iobuf_move+0x48>
ffffffffc0205862:	600c                	ld	a1,0(s0)
ffffffffc0205864:	c681                	beqz	a3,ffffffffc020586c <iobuf_move+0x28>
ffffffffc0205866:	87ae                	mv	a5,a1
ffffffffc0205868:	85aa                	mv	a1,a0
ffffffffc020586a:	853e                	mv	a0,a5
ffffffffc020586c:	8626                	mv	a2,s1
ffffffffc020586e:	2d1050ef          	jal	ra,ffffffffc020b33e <memmove>
ffffffffc0205872:	6c1c                	ld	a5,24(s0)
ffffffffc0205874:	0297ea63          	bltu	a5,s1,ffffffffc02058a8 <iobuf_move+0x64>
ffffffffc0205878:	6014                	ld	a3,0(s0)
ffffffffc020587a:	6418                	ld	a4,8(s0)
ffffffffc020587c:	8f85                	sub	a5,a5,s1
ffffffffc020587e:	96a6                	add	a3,a3,s1
ffffffffc0205880:	9726                	add	a4,a4,s1
ffffffffc0205882:	e014                	sd	a3,0(s0)
ffffffffc0205884:	e418                	sd	a4,8(s0)
ffffffffc0205886:	ec1c                	sd	a5,24(s0)
ffffffffc0205888:	40990933          	sub	s2,s2,s1
ffffffffc020588c:	00098463          	beqz	s3,ffffffffc0205894 <iobuf_move+0x50>
ffffffffc0205890:	0099b023          	sd	s1,0(s3)
ffffffffc0205894:	4501                	li	a0,0
ffffffffc0205896:	00091b63          	bnez	s2,ffffffffc02058ac <iobuf_move+0x68>
ffffffffc020589a:	70a2                	ld	ra,40(sp)
ffffffffc020589c:	7402                	ld	s0,32(sp)
ffffffffc020589e:	64e2                	ld	s1,24(sp)
ffffffffc02058a0:	6942                	ld	s2,16(sp)
ffffffffc02058a2:	69a2                	ld	s3,8(sp)
ffffffffc02058a4:	6145                	addi	sp,sp,48
ffffffffc02058a6:	8082                	ret
ffffffffc02058a8:	f6fff0ef          	jal	ra,ffffffffc0205816 <iobuf_skip.part.0>
ffffffffc02058ac:	5571                	li	a0,-4
ffffffffc02058ae:	b7f5                	j	ffffffffc020589a <iobuf_move+0x56>

ffffffffc02058b0 <iobuf_skip>:
ffffffffc02058b0:	6d1c                	ld	a5,24(a0)
ffffffffc02058b2:	00b7eb63          	bltu	a5,a1,ffffffffc02058c8 <iobuf_skip+0x18>
ffffffffc02058b6:	6114                	ld	a3,0(a0)
ffffffffc02058b8:	6518                	ld	a4,8(a0)
ffffffffc02058ba:	8f8d                	sub	a5,a5,a1
ffffffffc02058bc:	96ae                	add	a3,a3,a1
ffffffffc02058be:	95ba                	add	a1,a1,a4
ffffffffc02058c0:	e114                	sd	a3,0(a0)
ffffffffc02058c2:	e50c                	sd	a1,8(a0)
ffffffffc02058c4:	ed1c                	sd	a5,24(a0)
ffffffffc02058c6:	8082                	ret
ffffffffc02058c8:	1141                	addi	sp,sp,-16
ffffffffc02058ca:	e406                	sd	ra,8(sp)
ffffffffc02058cc:	f4bff0ef          	jal	ra,ffffffffc0205816 <iobuf_skip.part.0>

ffffffffc02058d0 <fs_init>:
ffffffffc02058d0:	1141                	addi	sp,sp,-16
ffffffffc02058d2:	e406                	sd	ra,8(sp)
ffffffffc02058d4:	651020ef          	jal	ra,ffffffffc0208724 <vfs_init>
ffffffffc02058d8:	089030ef          	jal	ra,ffffffffc0209160 <dev_init>
ffffffffc02058dc:	60a2                	ld	ra,8(sp)
ffffffffc02058de:	0141                	addi	sp,sp,16
ffffffffc02058e0:	0c10306f          	j	ffffffffc02091a0 <sfs_init>

ffffffffc02058e4 <fs_cleanup>:
ffffffffc02058e4:	37a0206f          	j	ffffffffc0207c5e <vfs_cleanup>

ffffffffc02058e8 <lock_files>:
ffffffffc02058e8:	0561                	addi	a0,a0,24
ffffffffc02058ea:	f6ffe06f          	j	ffffffffc0204858 <down>

ffffffffc02058ee <unlock_files>:
ffffffffc02058ee:	0561                	addi	a0,a0,24
ffffffffc02058f0:	f65fe06f          	j	ffffffffc0204854 <up>

ffffffffc02058f4 <files_create>:
ffffffffc02058f4:	1141                	addi	sp,sp,-16
ffffffffc02058f6:	6505                	lui	a0,0x1
ffffffffc02058f8:	e022                	sd	s0,0(sp)
ffffffffc02058fa:	e406                	sd	ra,8(sp)
ffffffffc02058fc:	fd5fd0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0205900:	842a                	mv	s0,a0
ffffffffc0205902:	cd19                	beqz	a0,ffffffffc0205920 <files_create+0x2c>
ffffffffc0205904:	03050793          	addi	a5,a0,48 # 1030 <_binary_bin_swap_img_size-0x6cd0>
ffffffffc0205908:	00043023          	sd	zero,0(s0)
ffffffffc020590c:	0561                	addi	a0,a0,24
ffffffffc020590e:	e41c                	sd	a5,8(s0)
ffffffffc0205910:	00042823          	sw	zero,16(s0)
ffffffffc0205914:	4585                	li	a1,1
ffffffffc0205916:	f37fe0ef          	jal	ra,ffffffffc020484c <sem_init>
ffffffffc020591a:	6408                	ld	a0,8(s0)
ffffffffc020591c:	e82ff0ef          	jal	ra,ffffffffc0204f9e <fd_array_init>
ffffffffc0205920:	60a2                	ld	ra,8(sp)
ffffffffc0205922:	8522                	mv	a0,s0
ffffffffc0205924:	6402                	ld	s0,0(sp)
ffffffffc0205926:	0141                	addi	sp,sp,16
ffffffffc0205928:	8082                	ret

ffffffffc020592a <files_destroy>:
ffffffffc020592a:	7179                	addi	sp,sp,-48
ffffffffc020592c:	f406                	sd	ra,40(sp)
ffffffffc020592e:	f022                	sd	s0,32(sp)
ffffffffc0205930:	ec26                	sd	s1,24(sp)
ffffffffc0205932:	e84a                	sd	s2,16(sp)
ffffffffc0205934:	e44e                	sd	s3,8(sp)
ffffffffc0205936:	c52d                	beqz	a0,ffffffffc02059a0 <files_destroy+0x76>
ffffffffc0205938:	491c                	lw	a5,16(a0)
ffffffffc020593a:	89aa                	mv	s3,a0
ffffffffc020593c:	e3b5                	bnez	a5,ffffffffc02059a0 <files_destroy+0x76>
ffffffffc020593e:	6108                	ld	a0,0(a0)
ffffffffc0205940:	c119                	beqz	a0,ffffffffc0205946 <files_destroy+0x1c>
ffffffffc0205942:	2b9020ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc0205946:	0089b403          	ld	s0,8(s3)
ffffffffc020594a:	6485                	lui	s1,0x1
ffffffffc020594c:	fc048493          	addi	s1,s1,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc0205950:	94a2                	add	s1,s1,s0
ffffffffc0205952:	4909                	li	s2,2
ffffffffc0205954:	401c                	lw	a5,0(s0)
ffffffffc0205956:	03278063          	beq	a5,s2,ffffffffc0205976 <files_destroy+0x4c>
ffffffffc020595a:	e39d                	bnez	a5,ffffffffc0205980 <files_destroy+0x56>
ffffffffc020595c:	03840413          	addi	s0,s0,56
ffffffffc0205960:	fe849ae3          	bne	s1,s0,ffffffffc0205954 <files_destroy+0x2a>
ffffffffc0205964:	7402                	ld	s0,32(sp)
ffffffffc0205966:	70a2                	ld	ra,40(sp)
ffffffffc0205968:	64e2                	ld	s1,24(sp)
ffffffffc020596a:	6942                	ld	s2,16(sp)
ffffffffc020596c:	854e                	mv	a0,s3
ffffffffc020596e:	69a2                	ld	s3,8(sp)
ffffffffc0205970:	6145                	addi	sp,sp,48
ffffffffc0205972:	80efe06f          	j	ffffffffc0203980 <kfree>
ffffffffc0205976:	8522                	mv	a0,s0
ffffffffc0205978:	e42ff0ef          	jal	ra,ffffffffc0204fba <fd_array_close>
ffffffffc020597c:	401c                	lw	a5,0(s0)
ffffffffc020597e:	bff1                	j	ffffffffc020595a <files_destroy+0x30>
ffffffffc0205980:	00008697          	auipc	a3,0x8
ffffffffc0205984:	f0868693          	addi	a3,a3,-248 # ffffffffc020d888 <CSWTCH.79+0x80>
ffffffffc0205988:	00006617          	auipc	a2,0x6
ffffffffc020598c:	39860613          	addi	a2,a2,920 # ffffffffc020bd20 <commands+0x250>
ffffffffc0205990:	03d00593          	li	a1,61
ffffffffc0205994:	00008517          	auipc	a0,0x8
ffffffffc0205998:	ee450513          	addi	a0,a0,-284 # ffffffffc020d878 <CSWTCH.79+0x70>
ffffffffc020599c:	893fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02059a0:	00008697          	auipc	a3,0x8
ffffffffc02059a4:	ea868693          	addi	a3,a3,-344 # ffffffffc020d848 <CSWTCH.79+0x40>
ffffffffc02059a8:	00006617          	auipc	a2,0x6
ffffffffc02059ac:	37860613          	addi	a2,a2,888 # ffffffffc020bd20 <commands+0x250>
ffffffffc02059b0:	03300593          	li	a1,51
ffffffffc02059b4:	00008517          	auipc	a0,0x8
ffffffffc02059b8:	ec450513          	addi	a0,a0,-316 # ffffffffc020d878 <CSWTCH.79+0x70>
ffffffffc02059bc:	873fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02059c0 <files_closeall>:
ffffffffc02059c0:	1101                	addi	sp,sp,-32
ffffffffc02059c2:	ec06                	sd	ra,24(sp)
ffffffffc02059c4:	e822                	sd	s0,16(sp)
ffffffffc02059c6:	e426                	sd	s1,8(sp)
ffffffffc02059c8:	e04a                	sd	s2,0(sp)
ffffffffc02059ca:	c129                	beqz	a0,ffffffffc0205a0c <files_closeall+0x4c>
ffffffffc02059cc:	491c                	lw	a5,16(a0)
ffffffffc02059ce:	02f05f63          	blez	a5,ffffffffc0205a0c <files_closeall+0x4c>
ffffffffc02059d2:	6504                	ld	s1,8(a0)
ffffffffc02059d4:	6785                	lui	a5,0x1
ffffffffc02059d6:	fc078793          	addi	a5,a5,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc02059da:	07048413          	addi	s0,s1,112
ffffffffc02059de:	4909                	li	s2,2
ffffffffc02059e0:	94be                	add	s1,s1,a5
ffffffffc02059e2:	a029                	j	ffffffffc02059ec <files_closeall+0x2c>
ffffffffc02059e4:	03840413          	addi	s0,s0,56
ffffffffc02059e8:	00848c63          	beq	s1,s0,ffffffffc0205a00 <files_closeall+0x40>
ffffffffc02059ec:	401c                	lw	a5,0(s0)
ffffffffc02059ee:	ff279be3          	bne	a5,s2,ffffffffc02059e4 <files_closeall+0x24>
ffffffffc02059f2:	8522                	mv	a0,s0
ffffffffc02059f4:	03840413          	addi	s0,s0,56
ffffffffc02059f8:	dc2ff0ef          	jal	ra,ffffffffc0204fba <fd_array_close>
ffffffffc02059fc:	fe8498e3          	bne	s1,s0,ffffffffc02059ec <files_closeall+0x2c>
ffffffffc0205a00:	60e2                	ld	ra,24(sp)
ffffffffc0205a02:	6442                	ld	s0,16(sp)
ffffffffc0205a04:	64a2                	ld	s1,8(sp)
ffffffffc0205a06:	6902                	ld	s2,0(sp)
ffffffffc0205a08:	6105                	addi	sp,sp,32
ffffffffc0205a0a:	8082                	ret
ffffffffc0205a0c:	00008697          	auipc	a3,0x8
ffffffffc0205a10:	a5c68693          	addi	a3,a3,-1444 # ffffffffc020d468 <default_pmm_manager+0x148>
ffffffffc0205a14:	00006617          	auipc	a2,0x6
ffffffffc0205a18:	30c60613          	addi	a2,a2,780 # ffffffffc020bd20 <commands+0x250>
ffffffffc0205a1c:	04500593          	li	a1,69
ffffffffc0205a20:	00008517          	auipc	a0,0x8
ffffffffc0205a24:	e5850513          	addi	a0,a0,-424 # ffffffffc020d878 <CSWTCH.79+0x70>
ffffffffc0205a28:	807fa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0205a2c <dup_files>:
ffffffffc0205a2c:	7179                	addi	sp,sp,-48
ffffffffc0205a2e:	f406                	sd	ra,40(sp)
ffffffffc0205a30:	f022                	sd	s0,32(sp)
ffffffffc0205a32:	ec26                	sd	s1,24(sp)
ffffffffc0205a34:	e84a                	sd	s2,16(sp)
ffffffffc0205a36:	e44e                	sd	s3,8(sp)
ffffffffc0205a38:	e052                	sd	s4,0(sp)
ffffffffc0205a3a:	c52d                	beqz	a0,ffffffffc0205aa4 <dup_files+0x78>
ffffffffc0205a3c:	842e                	mv	s0,a1
ffffffffc0205a3e:	c1bd                	beqz	a1,ffffffffc0205aa4 <dup_files+0x78>
ffffffffc0205a40:	491c                	lw	a5,16(a0)
ffffffffc0205a42:	84aa                	mv	s1,a0
ffffffffc0205a44:	e3c1                	bnez	a5,ffffffffc0205ac4 <dup_files+0x98>
ffffffffc0205a46:	499c                	lw	a5,16(a1)
ffffffffc0205a48:	06f05e63          	blez	a5,ffffffffc0205ac4 <dup_files+0x98>
ffffffffc0205a4c:	6188                	ld	a0,0(a1)
ffffffffc0205a4e:	e088                	sd	a0,0(s1)
ffffffffc0205a50:	c119                	beqz	a0,ffffffffc0205a56 <dup_files+0x2a>
ffffffffc0205a52:	0db020ef          	jal	ra,ffffffffc020832c <inode_ref_inc>
ffffffffc0205a56:	6400                	ld	s0,8(s0)
ffffffffc0205a58:	6905                	lui	s2,0x1
ffffffffc0205a5a:	fc090913          	addi	s2,s2,-64 # fc0 <_binary_bin_swap_img_size-0x6d40>
ffffffffc0205a5e:	6484                	ld	s1,8(s1)
ffffffffc0205a60:	9922                	add	s2,s2,s0
ffffffffc0205a62:	4989                	li	s3,2
ffffffffc0205a64:	4a05                	li	s4,1
ffffffffc0205a66:	a039                	j	ffffffffc0205a74 <dup_files+0x48>
ffffffffc0205a68:	03840413          	addi	s0,s0,56
ffffffffc0205a6c:	03848493          	addi	s1,s1,56
ffffffffc0205a70:	02890163          	beq	s2,s0,ffffffffc0205a92 <dup_files+0x66>
ffffffffc0205a74:	401c                	lw	a5,0(s0)
ffffffffc0205a76:	ff3799e3          	bne	a5,s3,ffffffffc0205a68 <dup_files+0x3c>
ffffffffc0205a7a:	0144a023          	sw	s4,0(s1)
ffffffffc0205a7e:	85a2                	mv	a1,s0
ffffffffc0205a80:	8526                	mv	a0,s1
ffffffffc0205a82:	03840413          	addi	s0,s0,56
ffffffffc0205a86:	db2ff0ef          	jal	ra,ffffffffc0205038 <fd_array_dup>
ffffffffc0205a8a:	03848493          	addi	s1,s1,56
ffffffffc0205a8e:	fe8913e3          	bne	s2,s0,ffffffffc0205a74 <dup_files+0x48>
ffffffffc0205a92:	70a2                	ld	ra,40(sp)
ffffffffc0205a94:	7402                	ld	s0,32(sp)
ffffffffc0205a96:	64e2                	ld	s1,24(sp)
ffffffffc0205a98:	6942                	ld	s2,16(sp)
ffffffffc0205a9a:	69a2                	ld	s3,8(sp)
ffffffffc0205a9c:	6a02                	ld	s4,0(sp)
ffffffffc0205a9e:	4501                	li	a0,0
ffffffffc0205aa0:	6145                	addi	sp,sp,48
ffffffffc0205aa2:	8082                	ret
ffffffffc0205aa4:	00007697          	auipc	a3,0x7
ffffffffc0205aa8:	29c68693          	addi	a3,a3,668 # ffffffffc020cd40 <commands+0x1270>
ffffffffc0205aac:	00006617          	auipc	a2,0x6
ffffffffc0205ab0:	27460613          	addi	a2,a2,628 # ffffffffc020bd20 <commands+0x250>
ffffffffc0205ab4:	05300593          	li	a1,83
ffffffffc0205ab8:	00008517          	auipc	a0,0x8
ffffffffc0205abc:	dc050513          	addi	a0,a0,-576 # ffffffffc020d878 <CSWTCH.79+0x70>
ffffffffc0205ac0:	f6efa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0205ac4:	00008697          	auipc	a3,0x8
ffffffffc0205ac8:	ddc68693          	addi	a3,a3,-548 # ffffffffc020d8a0 <CSWTCH.79+0x98>
ffffffffc0205acc:	00006617          	auipc	a2,0x6
ffffffffc0205ad0:	25460613          	addi	a2,a2,596 # ffffffffc020bd20 <commands+0x250>
ffffffffc0205ad4:	05400593          	li	a1,84
ffffffffc0205ad8:	00008517          	auipc	a0,0x8
ffffffffc0205adc:	da050513          	addi	a0,a0,-608 # ffffffffc020d878 <CSWTCH.79+0x70>
ffffffffc0205ae0:	f4efa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0205ae4 <kernel_thread_entry>:
ffffffffc0205ae4:	8526                	mv	a0,s1
ffffffffc0205ae6:	9402                	jalr	s0
ffffffffc0205ae8:	6ee000ef          	jal	ra,ffffffffc02061d6 <do_exit>

ffffffffc0205aec <switch_to>:
ffffffffc0205aec:	00153023          	sd	ra,0(a0)
ffffffffc0205af0:	00253423          	sd	sp,8(a0)
ffffffffc0205af4:	e900                	sd	s0,16(a0)
ffffffffc0205af6:	ed04                	sd	s1,24(a0)
ffffffffc0205af8:	03253023          	sd	s2,32(a0)
ffffffffc0205afc:	03353423          	sd	s3,40(a0)
ffffffffc0205b00:	03453823          	sd	s4,48(a0)
ffffffffc0205b04:	03553c23          	sd	s5,56(a0)
ffffffffc0205b08:	05653023          	sd	s6,64(a0)
ffffffffc0205b0c:	05753423          	sd	s7,72(a0)
ffffffffc0205b10:	05853823          	sd	s8,80(a0)
ffffffffc0205b14:	05953c23          	sd	s9,88(a0)
ffffffffc0205b18:	07a53023          	sd	s10,96(a0)
ffffffffc0205b1c:	07b53423          	sd	s11,104(a0)
ffffffffc0205b20:	0005b083          	ld	ra,0(a1)
ffffffffc0205b24:	0085b103          	ld	sp,8(a1)
ffffffffc0205b28:	6980                	ld	s0,16(a1)
ffffffffc0205b2a:	6d84                	ld	s1,24(a1)
ffffffffc0205b2c:	0205b903          	ld	s2,32(a1)
ffffffffc0205b30:	0285b983          	ld	s3,40(a1)
ffffffffc0205b34:	0305ba03          	ld	s4,48(a1)
ffffffffc0205b38:	0385ba83          	ld	s5,56(a1)
ffffffffc0205b3c:	0405bb03          	ld	s6,64(a1)
ffffffffc0205b40:	0485bb83          	ld	s7,72(a1)
ffffffffc0205b44:	0505bc03          	ld	s8,80(a1)
ffffffffc0205b48:	0585bc83          	ld	s9,88(a1)
ffffffffc0205b4c:	0605bd03          	ld	s10,96(a1)
ffffffffc0205b50:	0685bd83          	ld	s11,104(a1)
ffffffffc0205b54:	8082                	ret

ffffffffc0205b56 <alloc_proc>:
ffffffffc0205b56:	1141                	addi	sp,sp,-16
ffffffffc0205b58:	15000513          	li	a0,336
ffffffffc0205b5c:	e022                	sd	s0,0(sp)
ffffffffc0205b5e:	e406                	sd	ra,8(sp)
ffffffffc0205b60:	d71fd0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0205b64:	842a                	mv	s0,a0
ffffffffc0205b66:	c141                	beqz	a0,ffffffffc0205be6 <alloc_proc+0x90>
ffffffffc0205b68:	57fd                	li	a5,-1
ffffffffc0205b6a:	1782                	slli	a5,a5,0x20
ffffffffc0205b6c:	e11c                	sd	a5,0(a0)
ffffffffc0205b6e:	07000613          	li	a2,112
ffffffffc0205b72:	4581                	li	a1,0
ffffffffc0205b74:	00052423          	sw	zero,8(a0)
ffffffffc0205b78:	00053823          	sd	zero,16(a0)
ffffffffc0205b7c:	00053c23          	sd	zero,24(a0)
ffffffffc0205b80:	02053023          	sd	zero,32(a0)
ffffffffc0205b84:	02053423          	sd	zero,40(a0)
ffffffffc0205b88:	03050513          	addi	a0,a0,48
ffffffffc0205b8c:	7a0050ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc0205b90:	00091797          	auipc	a5,0x91
ffffffffc0205b94:	d387b783          	ld	a5,-712(a5) # ffffffffc02968c8 <boot_pgdir_pa>
ffffffffc0205b98:	f45c                	sd	a5,168(s0)
ffffffffc0205b9a:	0a043023          	sd	zero,160(s0)
ffffffffc0205b9e:	0a042823          	sw	zero,176(s0)
ffffffffc0205ba2:	463d                	li	a2,15
ffffffffc0205ba4:	4581                	li	a1,0
ffffffffc0205ba6:	0b440513          	addi	a0,s0,180
ffffffffc0205baa:	782050ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc0205bae:	11040793          	addi	a5,s0,272
ffffffffc0205bb2:	0e042623          	sw	zero,236(s0)
ffffffffc0205bb6:	0e043c23          	sd	zero,248(s0)
ffffffffc0205bba:	10043023          	sd	zero,256(s0)
ffffffffc0205bbe:	0e043823          	sd	zero,240(s0)
ffffffffc0205bc2:	10043423          	sd	zero,264(s0)
ffffffffc0205bc6:	10f43c23          	sd	a5,280(s0)
ffffffffc0205bca:	10f43823          	sd	a5,272(s0)
ffffffffc0205bce:	12042023          	sw	zero,288(s0)
ffffffffc0205bd2:	12043423          	sd	zero,296(s0)
ffffffffc0205bd6:	12043823          	sd	zero,304(s0)
ffffffffc0205bda:	12043c23          	sd	zero,312(s0)
ffffffffc0205bde:	14043023          	sd	zero,320(s0)
ffffffffc0205be2:	14043423          	sd	zero,328(s0)
ffffffffc0205be6:	60a2                	ld	ra,8(sp)
ffffffffc0205be8:	8522                	mv	a0,s0
ffffffffc0205bea:	6402                	ld	s0,0(sp)
ffffffffc0205bec:	0141                	addi	sp,sp,16
ffffffffc0205bee:	8082                	ret

ffffffffc0205bf0 <forkret>:
ffffffffc0205bf0:	00091797          	auipc	a5,0x91
ffffffffc0205bf4:	d187b783          	ld	a5,-744(a5) # ffffffffc0296908 <current>
ffffffffc0205bf8:	73c8                	ld	a0,160(a5)
ffffffffc0205bfa:	f78fb06f          	j	ffffffffc0201372 <forkrets>

ffffffffc0205bfe <put_pgdir.isra.0>:
ffffffffc0205bfe:	1141                	addi	sp,sp,-16
ffffffffc0205c00:	e406                	sd	ra,8(sp)
ffffffffc0205c02:	c02007b7          	lui	a5,0xc0200
ffffffffc0205c06:	02f56e63          	bltu	a0,a5,ffffffffc0205c42 <put_pgdir.isra.0+0x44>
ffffffffc0205c0a:	00091697          	auipc	a3,0x91
ffffffffc0205c0e:	ce66b683          	ld	a3,-794(a3) # ffffffffc02968f0 <va_pa_offset>
ffffffffc0205c12:	8d15                	sub	a0,a0,a3
ffffffffc0205c14:	8131                	srli	a0,a0,0xc
ffffffffc0205c16:	00091797          	auipc	a5,0x91
ffffffffc0205c1a:	cc27b783          	ld	a5,-830(a5) # ffffffffc02968d8 <npage>
ffffffffc0205c1e:	02f57f63          	bgeu	a0,a5,ffffffffc0205c5c <put_pgdir.isra.0+0x5e>
ffffffffc0205c22:	0000a697          	auipc	a3,0xa
ffffffffc0205c26:	fa66b683          	ld	a3,-90(a3) # ffffffffc020fbc8 <nbase>
ffffffffc0205c2a:	60a2                	ld	ra,8(sp)
ffffffffc0205c2c:	8d15                	sub	a0,a0,a3
ffffffffc0205c2e:	00091797          	auipc	a5,0x91
ffffffffc0205c32:	cb27b783          	ld	a5,-846(a5) # ffffffffc02968e0 <pages>
ffffffffc0205c36:	051a                	slli	a0,a0,0x6
ffffffffc0205c38:	4585                	li	a1,1
ffffffffc0205c3a:	953e                	add	a0,a0,a5
ffffffffc0205c3c:	0141                	addi	sp,sp,16
ffffffffc0205c3e:	faefb06f          	j	ffffffffc02013ec <free_pages>
ffffffffc0205c42:	86aa                	mv	a3,a0
ffffffffc0205c44:	00007617          	auipc	a2,0x7
ffffffffc0205c48:	90c60613          	addi	a2,a2,-1780 # ffffffffc020c550 <commands+0xa80>
ffffffffc0205c4c:	07700593          	li	a1,119
ffffffffc0205c50:	00006517          	auipc	a0,0x6
ffffffffc0205c54:	7d050513          	addi	a0,a0,2000 # ffffffffc020c420 <commands+0x950>
ffffffffc0205c58:	dd6fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0205c5c:	00006617          	auipc	a2,0x6
ffffffffc0205c60:	7a460613          	addi	a2,a2,1956 # ffffffffc020c400 <commands+0x930>
ffffffffc0205c64:	06900593          	li	a1,105
ffffffffc0205c68:	00006517          	auipc	a0,0x6
ffffffffc0205c6c:	7b850513          	addi	a0,a0,1976 # ffffffffc020c420 <commands+0x950>
ffffffffc0205c70:	dbefa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0205c74 <setup_pgdir>:
ffffffffc0205c74:	1101                	addi	sp,sp,-32
ffffffffc0205c76:	e426                	sd	s1,8(sp)
ffffffffc0205c78:	84aa                	mv	s1,a0
ffffffffc0205c7a:	4505                	li	a0,1
ffffffffc0205c7c:	ec06                	sd	ra,24(sp)
ffffffffc0205c7e:	e822                	sd	s0,16(sp)
ffffffffc0205c80:	f2efb0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0205c84:	c939                	beqz	a0,ffffffffc0205cda <setup_pgdir+0x66>
ffffffffc0205c86:	00091697          	auipc	a3,0x91
ffffffffc0205c8a:	c5a6b683          	ld	a3,-934(a3) # ffffffffc02968e0 <pages>
ffffffffc0205c8e:	40d506b3          	sub	a3,a0,a3
ffffffffc0205c92:	8699                	srai	a3,a3,0x6
ffffffffc0205c94:	0000a417          	auipc	s0,0xa
ffffffffc0205c98:	f3443403          	ld	s0,-204(s0) # ffffffffc020fbc8 <nbase>
ffffffffc0205c9c:	96a2                	add	a3,a3,s0
ffffffffc0205c9e:	00c69793          	slli	a5,a3,0xc
ffffffffc0205ca2:	83b1                	srli	a5,a5,0xc
ffffffffc0205ca4:	00091717          	auipc	a4,0x91
ffffffffc0205ca8:	c3473703          	ld	a4,-972(a4) # ffffffffc02968d8 <npage>
ffffffffc0205cac:	06b2                	slli	a3,a3,0xc
ffffffffc0205cae:	02e7f863          	bgeu	a5,a4,ffffffffc0205cde <setup_pgdir+0x6a>
ffffffffc0205cb2:	00091417          	auipc	s0,0x91
ffffffffc0205cb6:	c3e43403          	ld	s0,-962(s0) # ffffffffc02968f0 <va_pa_offset>
ffffffffc0205cba:	9436                	add	s0,s0,a3
ffffffffc0205cbc:	6605                	lui	a2,0x1
ffffffffc0205cbe:	00091597          	auipc	a1,0x91
ffffffffc0205cc2:	c125b583          	ld	a1,-1006(a1) # ffffffffc02968d0 <boot_pgdir_va>
ffffffffc0205cc6:	8522                	mv	a0,s0
ffffffffc0205cc8:	6b6050ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc0205ccc:	4501                	li	a0,0
ffffffffc0205cce:	ec80                	sd	s0,24(s1)
ffffffffc0205cd0:	60e2                	ld	ra,24(sp)
ffffffffc0205cd2:	6442                	ld	s0,16(sp)
ffffffffc0205cd4:	64a2                	ld	s1,8(sp)
ffffffffc0205cd6:	6105                	addi	sp,sp,32
ffffffffc0205cd8:	8082                	ret
ffffffffc0205cda:	5571                	li	a0,-4
ffffffffc0205cdc:	bfd5                	j	ffffffffc0205cd0 <setup_pgdir+0x5c>
ffffffffc0205cde:	00006617          	auipc	a2,0x6
ffffffffc0205ce2:	77a60613          	addi	a2,a2,1914 # ffffffffc020c458 <commands+0x988>
ffffffffc0205ce6:	07100593          	li	a1,113
ffffffffc0205cea:	00006517          	auipc	a0,0x6
ffffffffc0205cee:	73650513          	addi	a0,a0,1846 # ffffffffc020c420 <commands+0x950>
ffffffffc0205cf2:	d3cfa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0205cf6 <proc_run>:
ffffffffc0205cf6:	7179                	addi	sp,sp,-48
ffffffffc0205cf8:	ec26                	sd	s1,24(sp)
ffffffffc0205cfa:	00091497          	auipc	s1,0x91
ffffffffc0205cfe:	c0e48493          	addi	s1,s1,-1010 # ffffffffc0296908 <current>
ffffffffc0205d02:	f022                	sd	s0,32(sp)
ffffffffc0205d04:	e44e                	sd	s3,8(sp)
ffffffffc0205d06:	f406                	sd	ra,40(sp)
ffffffffc0205d08:	0004b983          	ld	s3,0(s1)
ffffffffc0205d0c:	e84a                	sd	s2,16(sp)
ffffffffc0205d0e:	842a                	mv	s0,a0
ffffffffc0205d10:	100027f3          	csrr	a5,sstatus
ffffffffc0205d14:	8b89                	andi	a5,a5,2
ffffffffc0205d16:	4901                	li	s2,0
ffffffffc0205d18:	e3b1                	bnez	a5,ffffffffc0205d5c <proc_run+0x66>
ffffffffc0205d1a:	745c                	ld	a5,168(s0)
ffffffffc0205d1c:	577d                	li	a4,-1
ffffffffc0205d1e:	177e                	slli	a4,a4,0x3f
ffffffffc0205d20:	83b1                	srli	a5,a5,0xc
ffffffffc0205d22:	e080                	sd	s0,0(s1)
ffffffffc0205d24:	8fd9                	or	a5,a5,a4
ffffffffc0205d26:	18079073          	csrw	satp,a5
ffffffffc0205d2a:	12000073          	sfence.vma
ffffffffc0205d2e:	03040593          	addi	a1,s0,48
ffffffffc0205d32:	03098513          	addi	a0,s3,48
ffffffffc0205d36:	db7ff0ef          	jal	ra,ffffffffc0205aec <switch_to>
ffffffffc0205d3a:	00091963          	bnez	s2,ffffffffc0205d4c <proc_run+0x56>
ffffffffc0205d3e:	70a2                	ld	ra,40(sp)
ffffffffc0205d40:	7402                	ld	s0,32(sp)
ffffffffc0205d42:	64e2                	ld	s1,24(sp)
ffffffffc0205d44:	6942                	ld	s2,16(sp)
ffffffffc0205d46:	69a2                	ld	s3,8(sp)
ffffffffc0205d48:	6145                	addi	sp,sp,48
ffffffffc0205d4a:	8082                	ret
ffffffffc0205d4c:	7402                	ld	s0,32(sp)
ffffffffc0205d4e:	70a2                	ld	ra,40(sp)
ffffffffc0205d50:	64e2                	ld	s1,24(sp)
ffffffffc0205d52:	6942                	ld	s2,16(sp)
ffffffffc0205d54:	69a2                	ld	s3,8(sp)
ffffffffc0205d56:	6145                	addi	sp,sp,48
ffffffffc0205d58:	842fb06f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc0205d5c:	844fb0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0205d60:	4905                	li	s2,1
ffffffffc0205d62:	bf65                	j	ffffffffc0205d1a <proc_run+0x24>

ffffffffc0205d64 <do_fork>:
ffffffffc0205d64:	7159                	addi	sp,sp,-112
ffffffffc0205d66:	e8ca                	sd	s2,80(sp)
ffffffffc0205d68:	00091917          	auipc	s2,0x91
ffffffffc0205d6c:	bb890913          	addi	s2,s2,-1096 # ffffffffc0296920 <nr_process>
ffffffffc0205d70:	00092783          	lw	a5,0(s2)
ffffffffc0205d74:	e4ce                	sd	s3,72(sp)
ffffffffc0205d76:	f486                	sd	ra,104(sp)
ffffffffc0205d78:	f0a2                	sd	s0,96(sp)
ffffffffc0205d7a:	eca6                	sd	s1,88(sp)
ffffffffc0205d7c:	e0d2                	sd	s4,64(sp)
ffffffffc0205d7e:	fc56                	sd	s5,56(sp)
ffffffffc0205d80:	f85a                	sd	s6,48(sp)
ffffffffc0205d82:	f45e                	sd	s7,40(sp)
ffffffffc0205d84:	f062                	sd	s8,32(sp)
ffffffffc0205d86:	ec66                	sd	s9,24(sp)
ffffffffc0205d88:	e86a                	sd	s10,16(sp)
ffffffffc0205d8a:	e46e                	sd	s11,8(sp)
ffffffffc0205d8c:	6985                	lui	s3,0x1
ffffffffc0205d8e:	3337dc63          	bge	a5,s3,ffffffffc02060c6 <do_fork+0x362>
ffffffffc0205d92:	8a2a                	mv	s4,a0
ffffffffc0205d94:	8aae                	mv	s5,a1
ffffffffc0205d96:	84b2                	mv	s1,a2
ffffffffc0205d98:	dbfff0ef          	jal	ra,ffffffffc0205b56 <alloc_proc>
ffffffffc0205d9c:	842a                	mv	s0,a0
ffffffffc0205d9e:	30050d63          	beqz	a0,ffffffffc02060b8 <do_fork+0x354>
ffffffffc0205da2:	00091b17          	auipc	s6,0x91
ffffffffc0205da6:	b66b0b13          	addi	s6,s6,-1178 # ffffffffc0296908 <current>
ffffffffc0205daa:	000b3783          	ld	a5,0(s6)
ffffffffc0205dae:	0ec7a703          	lw	a4,236(a5)
ffffffffc0205db2:	f11c                	sd	a5,32(a0)
ffffffffc0205db4:	38071d63          	bnez	a4,ffffffffc020614e <do_fork+0x3ea>
ffffffffc0205db8:	4509                	li	a0,2
ffffffffc0205dba:	df4fb0ef          	jal	ra,ffffffffc02013ae <alloc_pages>
ffffffffc0205dbe:	2e050a63          	beqz	a0,ffffffffc02060b2 <do_fork+0x34e>
ffffffffc0205dc2:	00091c17          	auipc	s8,0x91
ffffffffc0205dc6:	b1ec0c13          	addi	s8,s8,-1250 # ffffffffc02968e0 <pages>
ffffffffc0205dca:	000c3683          	ld	a3,0(s8)
ffffffffc0205dce:	0000ab97          	auipc	s7,0xa
ffffffffc0205dd2:	dfabbb83          	ld	s7,-518(s7) # ffffffffc020fbc8 <nbase>
ffffffffc0205dd6:	00091c97          	auipc	s9,0x91
ffffffffc0205dda:	b02c8c93          	addi	s9,s9,-1278 # ffffffffc02968d8 <npage>
ffffffffc0205dde:	40d506b3          	sub	a3,a0,a3
ffffffffc0205de2:	8699                	srai	a3,a3,0x6
ffffffffc0205de4:	96de                	add	a3,a3,s7
ffffffffc0205de6:	000cb703          	ld	a4,0(s9)
ffffffffc0205dea:	00c69793          	slli	a5,a3,0xc
ffffffffc0205dee:	83b1                	srli	a5,a5,0xc
ffffffffc0205df0:	06b2                	slli	a3,a3,0xc
ffffffffc0205df2:	2ce7ff63          	bgeu	a5,a4,ffffffffc02060d0 <do_fork+0x36c>
ffffffffc0205df6:	000b3703          	ld	a4,0(s6)
ffffffffc0205dfa:	00091d17          	auipc	s10,0x91
ffffffffc0205dfe:	af6d0d13          	addi	s10,s10,-1290 # ffffffffc02968f0 <va_pa_offset>
ffffffffc0205e02:	000d3783          	ld	a5,0(s10)
ffffffffc0205e06:	14873d83          	ld	s11,328(a4)
ffffffffc0205e0a:	96be                	add	a3,a3,a5
ffffffffc0205e0c:	e814                	sd	a3,16(s0)
ffffffffc0205e0e:	2e0d8963          	beqz	s11,ffffffffc0206100 <do_fork+0x39c>
ffffffffc0205e12:	80098993          	addi	s3,s3,-2048 # 800 <_binary_bin_swap_img_size-0x7500>
ffffffffc0205e16:	013a79b3          	and	s3,s4,s3
ffffffffc0205e1a:	1e098063          	beqz	s3,ffffffffc0205ffa <do_fork+0x296>
ffffffffc0205e1e:	010da783          	lw	a5,16(s11)
ffffffffc0205e22:	02873983          	ld	s3,40(a4)
ffffffffc0205e26:	2785                	addiw	a5,a5,1
ffffffffc0205e28:	00fda823          	sw	a5,16(s11)
ffffffffc0205e2c:	15b43423          	sd	s11,328(s0)
ffffffffc0205e30:	02098763          	beqz	s3,ffffffffc0205e5e <do_fork+0xfa>
ffffffffc0205e34:	100a7a13          	andi	s4,s4,256
ffffffffc0205e38:	1c0a0d63          	beqz	s4,ffffffffc0206012 <do_fork+0x2ae>
ffffffffc0205e3c:	0309a783          	lw	a5,48(s3)
ffffffffc0205e40:	0189b683          	ld	a3,24(s3)
ffffffffc0205e44:	c0200737          	lui	a4,0xc0200
ffffffffc0205e48:	2785                	addiw	a5,a5,1
ffffffffc0205e4a:	02f9a823          	sw	a5,48(s3)
ffffffffc0205e4e:	03343423          	sd	s3,40(s0)
ffffffffc0205e52:	30e6ee63          	bltu	a3,a4,ffffffffc020616e <do_fork+0x40a>
ffffffffc0205e56:	000d3783          	ld	a5,0(s10)
ffffffffc0205e5a:	8e9d                	sub	a3,a3,a5
ffffffffc0205e5c:	f454                	sd	a3,168(s0)
ffffffffc0205e5e:	6818                	ld	a4,16(s0)
ffffffffc0205e60:	6789                	lui	a5,0x2
ffffffffc0205e62:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_bin_swap_img_size-0x5e20>
ffffffffc0205e66:	973e                	add	a4,a4,a5
ffffffffc0205e68:	8626                	mv	a2,s1
ffffffffc0205e6a:	f058                	sd	a4,160(s0)
ffffffffc0205e6c:	87ba                	mv	a5,a4
ffffffffc0205e6e:	12048893          	addi	a7,s1,288
ffffffffc0205e72:	00063803          	ld	a6,0(a2)
ffffffffc0205e76:	6608                	ld	a0,8(a2)
ffffffffc0205e78:	6a0c                	ld	a1,16(a2)
ffffffffc0205e7a:	6e14                	ld	a3,24(a2)
ffffffffc0205e7c:	0107b023          	sd	a6,0(a5)
ffffffffc0205e80:	e788                	sd	a0,8(a5)
ffffffffc0205e82:	eb8c                	sd	a1,16(a5)
ffffffffc0205e84:	ef94                	sd	a3,24(a5)
ffffffffc0205e86:	02060613          	addi	a2,a2,32
ffffffffc0205e8a:	02078793          	addi	a5,a5,32
ffffffffc0205e8e:	ff1612e3          	bne	a2,a7,ffffffffc0205e72 <do_fork+0x10e>
ffffffffc0205e92:	04073823          	sd	zero,80(a4) # ffffffffc0200050 <kern_init+0x6>
ffffffffc0205e96:	120a8f63          	beqz	s5,ffffffffc0205fd4 <do_fork+0x270>
ffffffffc0205e9a:	01573823          	sd	s5,16(a4)
ffffffffc0205e9e:	00000797          	auipc	a5,0x0
ffffffffc0205ea2:	d5278793          	addi	a5,a5,-686 # ffffffffc0205bf0 <forkret>
ffffffffc0205ea6:	f81c                	sd	a5,48(s0)
ffffffffc0205ea8:	fc18                	sd	a4,56(s0)
ffffffffc0205eaa:	100027f3          	csrr	a5,sstatus
ffffffffc0205eae:	8b89                	andi	a5,a5,2
ffffffffc0205eb0:	4981                	li	s3,0
ffffffffc0205eb2:	14079063          	bnez	a5,ffffffffc0205ff2 <do_fork+0x28e>
ffffffffc0205eb6:	0008b817          	auipc	a6,0x8b
ffffffffc0205eba:	1a280813          	addi	a6,a6,418 # ffffffffc0291058 <last_pid.1>
ffffffffc0205ebe:	00082783          	lw	a5,0(a6)
ffffffffc0205ec2:	6709                	lui	a4,0x2
ffffffffc0205ec4:	0017851b          	addiw	a0,a5,1
ffffffffc0205ec8:	00a82023          	sw	a0,0(a6)
ffffffffc0205ecc:	08e55d63          	bge	a0,a4,ffffffffc0205f66 <do_fork+0x202>
ffffffffc0205ed0:	0008b317          	auipc	t1,0x8b
ffffffffc0205ed4:	18c30313          	addi	t1,t1,396 # ffffffffc029105c <next_safe.0>
ffffffffc0205ed8:	00032783          	lw	a5,0(t1)
ffffffffc0205edc:	00090497          	auipc	s1,0x90
ffffffffc0205ee0:	8e448493          	addi	s1,s1,-1820 # ffffffffc02957c0 <proc_list>
ffffffffc0205ee4:	08f55963          	bge	a0,a5,ffffffffc0205f76 <do_fork+0x212>
ffffffffc0205ee8:	c048                	sw	a0,4(s0)
ffffffffc0205eea:	45a9                	li	a1,10
ffffffffc0205eec:	2501                	sext.w	a0,a0
ffffffffc0205eee:	125050ef          	jal	ra,ffffffffc020b812 <hash32>
ffffffffc0205ef2:	02051793          	slli	a5,a0,0x20
ffffffffc0205ef6:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205efa:	0008c797          	auipc	a5,0x8c
ffffffffc0205efe:	8c678793          	addi	a5,a5,-1850 # ffffffffc02917c0 <hash_list>
ffffffffc0205f02:	953e                	add	a0,a0,a5
ffffffffc0205f04:	650c                	ld	a1,8(a0)
ffffffffc0205f06:	7014                	ld	a3,32(s0)
ffffffffc0205f08:	0d840793          	addi	a5,s0,216
ffffffffc0205f0c:	e19c                	sd	a5,0(a1)
ffffffffc0205f0e:	6490                	ld	a2,8(s1)
ffffffffc0205f10:	e51c                	sd	a5,8(a0)
ffffffffc0205f12:	7af8                	ld	a4,240(a3)
ffffffffc0205f14:	0c840793          	addi	a5,s0,200
ffffffffc0205f18:	f06c                	sd	a1,224(s0)
ffffffffc0205f1a:	ec68                	sd	a0,216(s0)
ffffffffc0205f1c:	e21c                	sd	a5,0(a2)
ffffffffc0205f1e:	e49c                	sd	a5,8(s1)
ffffffffc0205f20:	e870                	sd	a2,208(s0)
ffffffffc0205f22:	e464                	sd	s1,200(s0)
ffffffffc0205f24:	0e043c23          	sd	zero,248(s0)
ffffffffc0205f28:	10e43023          	sd	a4,256(s0)
ffffffffc0205f2c:	c311                	beqz	a4,ffffffffc0205f30 <do_fork+0x1cc>
ffffffffc0205f2e:	ff60                	sd	s0,248(a4)
ffffffffc0205f30:	00092783          	lw	a5,0(s2)
ffffffffc0205f34:	fae0                	sd	s0,240(a3)
ffffffffc0205f36:	2785                	addiw	a5,a5,1
ffffffffc0205f38:	00f92023          	sw	a5,0(s2)
ffffffffc0205f3c:	10099063          	bnez	s3,ffffffffc020603c <do_fork+0x2d8>
ffffffffc0205f40:	8522                	mv	a0,s0
ffffffffc0205f42:	660010ef          	jal	ra,ffffffffc02075a2 <wakeup_proc>
ffffffffc0205f46:	4048                	lw	a0,4(s0)
ffffffffc0205f48:	70a6                	ld	ra,104(sp)
ffffffffc0205f4a:	7406                	ld	s0,96(sp)
ffffffffc0205f4c:	64e6                	ld	s1,88(sp)
ffffffffc0205f4e:	6946                	ld	s2,80(sp)
ffffffffc0205f50:	69a6                	ld	s3,72(sp)
ffffffffc0205f52:	6a06                	ld	s4,64(sp)
ffffffffc0205f54:	7ae2                	ld	s5,56(sp)
ffffffffc0205f56:	7b42                	ld	s6,48(sp)
ffffffffc0205f58:	7ba2                	ld	s7,40(sp)
ffffffffc0205f5a:	7c02                	ld	s8,32(sp)
ffffffffc0205f5c:	6ce2                	ld	s9,24(sp)
ffffffffc0205f5e:	6d42                	ld	s10,16(sp)
ffffffffc0205f60:	6da2                	ld	s11,8(sp)
ffffffffc0205f62:	6165                	addi	sp,sp,112
ffffffffc0205f64:	8082                	ret
ffffffffc0205f66:	4785                	li	a5,1
ffffffffc0205f68:	00f82023          	sw	a5,0(a6)
ffffffffc0205f6c:	4505                	li	a0,1
ffffffffc0205f6e:	0008b317          	auipc	t1,0x8b
ffffffffc0205f72:	0ee30313          	addi	t1,t1,238 # ffffffffc029105c <next_safe.0>
ffffffffc0205f76:	00090497          	auipc	s1,0x90
ffffffffc0205f7a:	84a48493          	addi	s1,s1,-1974 # ffffffffc02957c0 <proc_list>
ffffffffc0205f7e:	0084be03          	ld	t3,8(s1)
ffffffffc0205f82:	6789                	lui	a5,0x2
ffffffffc0205f84:	00f32023          	sw	a5,0(t1)
ffffffffc0205f88:	86aa                	mv	a3,a0
ffffffffc0205f8a:	4581                	li	a1,0
ffffffffc0205f8c:	6e89                	lui	t4,0x2
ffffffffc0205f8e:	129e0763          	beq	t3,s1,ffffffffc02060bc <do_fork+0x358>
ffffffffc0205f92:	88ae                	mv	a7,a1
ffffffffc0205f94:	87f2                	mv	a5,t3
ffffffffc0205f96:	6609                	lui	a2,0x2
ffffffffc0205f98:	a811                	j	ffffffffc0205fac <do_fork+0x248>
ffffffffc0205f9a:	00e6d663          	bge	a3,a4,ffffffffc0205fa6 <do_fork+0x242>
ffffffffc0205f9e:	00c75463          	bge	a4,a2,ffffffffc0205fa6 <do_fork+0x242>
ffffffffc0205fa2:	863a                	mv	a2,a4
ffffffffc0205fa4:	4885                	li	a7,1
ffffffffc0205fa6:	679c                	ld	a5,8(a5)
ffffffffc0205fa8:	00978d63          	beq	a5,s1,ffffffffc0205fc2 <do_fork+0x25e>
ffffffffc0205fac:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_bin_swap_img_size-0x5dc4>
ffffffffc0205fb0:	fed715e3          	bne	a4,a3,ffffffffc0205f9a <do_fork+0x236>
ffffffffc0205fb4:	2685                	addiw	a3,a3,1
ffffffffc0205fb6:	0ac6df63          	bge	a3,a2,ffffffffc0206074 <do_fork+0x310>
ffffffffc0205fba:	679c                	ld	a5,8(a5)
ffffffffc0205fbc:	4585                	li	a1,1
ffffffffc0205fbe:	fe9797e3          	bne	a5,s1,ffffffffc0205fac <do_fork+0x248>
ffffffffc0205fc2:	c581                	beqz	a1,ffffffffc0205fca <do_fork+0x266>
ffffffffc0205fc4:	00d82023          	sw	a3,0(a6)
ffffffffc0205fc8:	8536                	mv	a0,a3
ffffffffc0205fca:	f0088fe3          	beqz	a7,ffffffffc0205ee8 <do_fork+0x184>
ffffffffc0205fce:	00c32023          	sw	a2,0(t1)
ffffffffc0205fd2:	bf19                	j	ffffffffc0205ee8 <do_fork+0x184>
ffffffffc0205fd4:	8aba                	mv	s5,a4
ffffffffc0205fd6:	01573823          	sd	s5,16(a4) # 2010 <_binary_bin_swap_img_size-0x5cf0>
ffffffffc0205fda:	00000797          	auipc	a5,0x0
ffffffffc0205fde:	c1678793          	addi	a5,a5,-1002 # ffffffffc0205bf0 <forkret>
ffffffffc0205fe2:	f81c                	sd	a5,48(s0)
ffffffffc0205fe4:	fc18                	sd	a4,56(s0)
ffffffffc0205fe6:	100027f3          	csrr	a5,sstatus
ffffffffc0205fea:	8b89                	andi	a5,a5,2
ffffffffc0205fec:	4981                	li	s3,0
ffffffffc0205fee:	ec0784e3          	beqz	a5,ffffffffc0205eb6 <do_fork+0x152>
ffffffffc0205ff2:	daffa0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0205ff6:	4985                	li	s3,1
ffffffffc0205ff8:	bd7d                	j	ffffffffc0205eb6 <do_fork+0x152>
ffffffffc0205ffa:	8fbff0ef          	jal	ra,ffffffffc02058f4 <files_create>
ffffffffc0205ffe:	89aa                	mv	s3,a0
ffffffffc0206000:	c151                	beqz	a0,ffffffffc0206084 <do_fork+0x320>
ffffffffc0206002:	85ee                	mv	a1,s11
ffffffffc0206004:	a29ff0ef          	jal	ra,ffffffffc0205a2c <dup_files>
ffffffffc0206008:	e93d                	bnez	a0,ffffffffc020607e <do_fork+0x31a>
ffffffffc020600a:	000b3703          	ld	a4,0(s6)
ffffffffc020600e:	8dce                	mv	s11,s3
ffffffffc0206010:	b539                	j	ffffffffc0205e1e <do_fork+0xba>
ffffffffc0206012:	c21fc0ef          	jal	ra,ffffffffc0202c32 <mm_create>
ffffffffc0206016:	8a2a                	mv	s4,a0
ffffffffc0206018:	c519                	beqz	a0,ffffffffc0206026 <do_fork+0x2c2>
ffffffffc020601a:	c5bff0ef          	jal	ra,ffffffffc0205c74 <setup_pgdir>
ffffffffc020601e:	c115                	beqz	a0,ffffffffc0206042 <do_fork+0x2de>
ffffffffc0206020:	8552                	mv	a0,s4
ffffffffc0206022:	d5ffc0ef          	jal	ra,ffffffffc0202d80 <mm_destroy>
ffffffffc0206026:	14843503          	ld	a0,328(s0)
ffffffffc020602a:	cd29                	beqz	a0,ffffffffc0206084 <do_fork+0x320>
ffffffffc020602c:	491c                	lw	a5,16(a0)
ffffffffc020602e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0206032:	c918                	sw	a4,16(a0)
ffffffffc0206034:	eb21                	bnez	a4,ffffffffc0206084 <do_fork+0x320>
ffffffffc0206036:	8f5ff0ef          	jal	ra,ffffffffc020592a <files_destroy>
ffffffffc020603a:	a0a9                	j	ffffffffc0206084 <do_fork+0x320>
ffffffffc020603c:	d5ffa0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0206040:	b701                	j	ffffffffc0205f40 <do_fork+0x1dc>
ffffffffc0206042:	03898d93          	addi	s11,s3,56
ffffffffc0206046:	856e                	mv	a0,s11
ffffffffc0206048:	811fe0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc020604c:	000b3783          	ld	a5,0(s6)
ffffffffc0206050:	c781                	beqz	a5,ffffffffc0206058 <do_fork+0x2f4>
ffffffffc0206052:	43dc                	lw	a5,4(a5)
ffffffffc0206054:	04f9a823          	sw	a5,80(s3)
ffffffffc0206058:	85ce                	mv	a1,s3
ffffffffc020605a:	8552                	mv	a0,s4
ffffffffc020605c:	888fd0ef          	jal	ra,ffffffffc02030e4 <dup_mmap>
ffffffffc0206060:	8b2a                	mv	s6,a0
ffffffffc0206062:	856e                	mv	a0,s11
ffffffffc0206064:	ff0fe0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0206068:	0409a823          	sw	zero,80(s3)
ffffffffc020606c:	0a0b1a63          	bnez	s6,ffffffffc0206120 <do_fork+0x3bc>
ffffffffc0206070:	89d2                	mv	s3,s4
ffffffffc0206072:	b3e9                	j	ffffffffc0205e3c <do_fork+0xd8>
ffffffffc0206074:	01d6c363          	blt	a3,t4,ffffffffc020607a <do_fork+0x316>
ffffffffc0206078:	4685                	li	a3,1
ffffffffc020607a:	4585                	li	a1,1
ffffffffc020607c:	bf09                	j	ffffffffc0205f8e <do_fork+0x22a>
ffffffffc020607e:	854e                	mv	a0,s3
ffffffffc0206080:	8abff0ef          	jal	ra,ffffffffc020592a <files_destroy>
ffffffffc0206084:	6814                	ld	a3,16(s0)
ffffffffc0206086:	c02007b7          	lui	a5,0xc0200
ffffffffc020608a:	04f6ef63          	bltu	a3,a5,ffffffffc02060e8 <do_fork+0x384>
ffffffffc020608e:	000d3783          	ld	a5,0(s10)
ffffffffc0206092:	000cb703          	ld	a4,0(s9)
ffffffffc0206096:	40f687b3          	sub	a5,a3,a5
ffffffffc020609a:	83b1                	srli	a5,a5,0xc
ffffffffc020609c:	08e7fd63          	bgeu	a5,a4,ffffffffc0206136 <do_fork+0x3d2>
ffffffffc02060a0:	000c3503          	ld	a0,0(s8)
ffffffffc02060a4:	417787b3          	sub	a5,a5,s7
ffffffffc02060a8:	079a                	slli	a5,a5,0x6
ffffffffc02060aa:	4589                	li	a1,2
ffffffffc02060ac:	953e                	add	a0,a0,a5
ffffffffc02060ae:	b3efb0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc02060b2:	8522                	mv	a0,s0
ffffffffc02060b4:	8cdfd0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc02060b8:	5571                	li	a0,-4
ffffffffc02060ba:	b579                	j	ffffffffc0205f48 <do_fork+0x1e4>
ffffffffc02060bc:	c599                	beqz	a1,ffffffffc02060ca <do_fork+0x366>
ffffffffc02060be:	00d82023          	sw	a3,0(a6)
ffffffffc02060c2:	8536                	mv	a0,a3
ffffffffc02060c4:	b515                	j	ffffffffc0205ee8 <do_fork+0x184>
ffffffffc02060c6:	556d                	li	a0,-5
ffffffffc02060c8:	b541                	j	ffffffffc0205f48 <do_fork+0x1e4>
ffffffffc02060ca:	00082503          	lw	a0,0(a6)
ffffffffc02060ce:	bd29                	j	ffffffffc0205ee8 <do_fork+0x184>
ffffffffc02060d0:	00006617          	auipc	a2,0x6
ffffffffc02060d4:	38860613          	addi	a2,a2,904 # ffffffffc020c458 <commands+0x988>
ffffffffc02060d8:	07100593          	li	a1,113
ffffffffc02060dc:	00006517          	auipc	a0,0x6
ffffffffc02060e0:	34450513          	addi	a0,a0,836 # ffffffffc020c420 <commands+0x950>
ffffffffc02060e4:	94afa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02060e8:	00006617          	auipc	a2,0x6
ffffffffc02060ec:	46860613          	addi	a2,a2,1128 # ffffffffc020c550 <commands+0xa80>
ffffffffc02060f0:	07700593          	li	a1,119
ffffffffc02060f4:	00006517          	auipc	a0,0x6
ffffffffc02060f8:	32c50513          	addi	a0,a0,812 # ffffffffc020c420 <commands+0x950>
ffffffffc02060fc:	932fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206100:	00008697          	auipc	a3,0x8
ffffffffc0206104:	80868693          	addi	a3,a3,-2040 # ffffffffc020d908 <CSWTCH.79+0x100>
ffffffffc0206108:	00006617          	auipc	a2,0x6
ffffffffc020610c:	c1860613          	addi	a2,a2,-1000 # ffffffffc020bd20 <commands+0x250>
ffffffffc0206110:	1cc00593          	li	a1,460
ffffffffc0206114:	00007517          	auipc	a0,0x7
ffffffffc0206118:	7dc50513          	addi	a0,a0,2012 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc020611c:	912fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206120:	8552                	mv	a0,s4
ffffffffc0206122:	85cfd0ef          	jal	ra,ffffffffc020317e <exit_mmap>
ffffffffc0206126:	018a3503          	ld	a0,24(s4)
ffffffffc020612a:	ad5ff0ef          	jal	ra,ffffffffc0205bfe <put_pgdir.isra.0>
ffffffffc020612e:	8552                	mv	a0,s4
ffffffffc0206130:	c51fc0ef          	jal	ra,ffffffffc0202d80 <mm_destroy>
ffffffffc0206134:	bdcd                	j	ffffffffc0206026 <do_fork+0x2c2>
ffffffffc0206136:	00006617          	auipc	a2,0x6
ffffffffc020613a:	2ca60613          	addi	a2,a2,714 # ffffffffc020c400 <commands+0x930>
ffffffffc020613e:	06900593          	li	a1,105
ffffffffc0206142:	00006517          	auipc	a0,0x6
ffffffffc0206146:	2de50513          	addi	a0,a0,734 # ffffffffc020c420 <commands+0x950>
ffffffffc020614a:	8e4fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020614e:	00007697          	auipc	a3,0x7
ffffffffc0206152:	78268693          	addi	a3,a3,1922 # ffffffffc020d8d0 <CSWTCH.79+0xc8>
ffffffffc0206156:	00006617          	auipc	a2,0x6
ffffffffc020615a:	bca60613          	addi	a2,a2,-1078 # ffffffffc020bd20 <commands+0x250>
ffffffffc020615e:	21e00593          	li	a1,542
ffffffffc0206162:	00007517          	auipc	a0,0x7
ffffffffc0206166:	78e50513          	addi	a0,a0,1934 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc020616a:	8c4fa0ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020616e:	00006617          	auipc	a2,0x6
ffffffffc0206172:	3e260613          	addi	a2,a2,994 # ffffffffc020c550 <commands+0xa80>
ffffffffc0206176:	1ac00593          	li	a1,428
ffffffffc020617a:	00007517          	auipc	a0,0x7
ffffffffc020617e:	77650513          	addi	a0,a0,1910 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206182:	8acfa0ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0206186 <kernel_thread>:
ffffffffc0206186:	7129                	addi	sp,sp,-320
ffffffffc0206188:	fa22                	sd	s0,304(sp)
ffffffffc020618a:	f626                	sd	s1,296(sp)
ffffffffc020618c:	f24a                	sd	s2,288(sp)
ffffffffc020618e:	84ae                	mv	s1,a1
ffffffffc0206190:	892a                	mv	s2,a0
ffffffffc0206192:	8432                	mv	s0,a2
ffffffffc0206194:	4581                	li	a1,0
ffffffffc0206196:	12000613          	li	a2,288
ffffffffc020619a:	850a                	mv	a0,sp
ffffffffc020619c:	fe06                	sd	ra,312(sp)
ffffffffc020619e:	18e050ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc02061a2:	e0ca                	sd	s2,64(sp)
ffffffffc02061a4:	e4a6                	sd	s1,72(sp)
ffffffffc02061a6:	100027f3          	csrr	a5,sstatus
ffffffffc02061aa:	edd7f793          	andi	a5,a5,-291
ffffffffc02061ae:	1207e793          	ori	a5,a5,288
ffffffffc02061b2:	e23e                	sd	a5,256(sp)
ffffffffc02061b4:	860a                	mv	a2,sp
ffffffffc02061b6:	10046513          	ori	a0,s0,256
ffffffffc02061ba:	00000797          	auipc	a5,0x0
ffffffffc02061be:	92a78793          	addi	a5,a5,-1750 # ffffffffc0205ae4 <kernel_thread_entry>
ffffffffc02061c2:	4581                	li	a1,0
ffffffffc02061c4:	e63e                	sd	a5,264(sp)
ffffffffc02061c6:	b9fff0ef          	jal	ra,ffffffffc0205d64 <do_fork>
ffffffffc02061ca:	70f2                	ld	ra,312(sp)
ffffffffc02061cc:	7452                	ld	s0,304(sp)
ffffffffc02061ce:	74b2                	ld	s1,296(sp)
ffffffffc02061d0:	7912                	ld	s2,288(sp)
ffffffffc02061d2:	6131                	addi	sp,sp,320
ffffffffc02061d4:	8082                	ret

ffffffffc02061d6 <do_exit>:
ffffffffc02061d6:	7179                	addi	sp,sp,-48
ffffffffc02061d8:	f022                	sd	s0,32(sp)
ffffffffc02061da:	00090417          	auipc	s0,0x90
ffffffffc02061de:	72e40413          	addi	s0,s0,1838 # ffffffffc0296908 <current>
ffffffffc02061e2:	601c                	ld	a5,0(s0)
ffffffffc02061e4:	f406                	sd	ra,40(sp)
ffffffffc02061e6:	ec26                	sd	s1,24(sp)
ffffffffc02061e8:	e84a                	sd	s2,16(sp)
ffffffffc02061ea:	e44e                	sd	s3,8(sp)
ffffffffc02061ec:	e052                	sd	s4,0(sp)
ffffffffc02061ee:	00090717          	auipc	a4,0x90
ffffffffc02061f2:	72273703          	ld	a4,1826(a4) # ffffffffc0296910 <idleproc>
ffffffffc02061f6:	0ee78763          	beq	a5,a4,ffffffffc02062e4 <do_exit+0x10e>
ffffffffc02061fa:	00090497          	auipc	s1,0x90
ffffffffc02061fe:	71e48493          	addi	s1,s1,1822 # ffffffffc0296918 <initproc>
ffffffffc0206202:	6098                	ld	a4,0(s1)
ffffffffc0206204:	10e78763          	beq	a5,a4,ffffffffc0206312 <do_exit+0x13c>
ffffffffc0206208:	0287b983          	ld	s3,40(a5)
ffffffffc020620c:	892a                	mv	s2,a0
ffffffffc020620e:	02098e63          	beqz	s3,ffffffffc020624a <do_exit+0x74>
ffffffffc0206212:	00090797          	auipc	a5,0x90
ffffffffc0206216:	6b67b783          	ld	a5,1718(a5) # ffffffffc02968c8 <boot_pgdir_pa>
ffffffffc020621a:	577d                	li	a4,-1
ffffffffc020621c:	177e                	slli	a4,a4,0x3f
ffffffffc020621e:	83b1                	srli	a5,a5,0xc
ffffffffc0206220:	8fd9                	or	a5,a5,a4
ffffffffc0206222:	18079073          	csrw	satp,a5
ffffffffc0206226:	0309a783          	lw	a5,48(s3)
ffffffffc020622a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020622e:	02e9a823          	sw	a4,48(s3)
ffffffffc0206232:	c769                	beqz	a4,ffffffffc02062fc <do_exit+0x126>
ffffffffc0206234:	601c                	ld	a5,0(s0)
ffffffffc0206236:	1487b503          	ld	a0,328(a5)
ffffffffc020623a:	0207b423          	sd	zero,40(a5)
ffffffffc020623e:	c511                	beqz	a0,ffffffffc020624a <do_exit+0x74>
ffffffffc0206240:	491c                	lw	a5,16(a0)
ffffffffc0206242:	fff7871b          	addiw	a4,a5,-1
ffffffffc0206246:	c918                	sw	a4,16(a0)
ffffffffc0206248:	cb59                	beqz	a4,ffffffffc02062de <do_exit+0x108>
ffffffffc020624a:	601c                	ld	a5,0(s0)
ffffffffc020624c:	470d                	li	a4,3
ffffffffc020624e:	c398                	sw	a4,0(a5)
ffffffffc0206250:	0f27a423          	sw	s2,232(a5)
ffffffffc0206254:	100027f3          	csrr	a5,sstatus
ffffffffc0206258:	8b89                	andi	a5,a5,2
ffffffffc020625a:	4a01                	li	s4,0
ffffffffc020625c:	e7f9                	bnez	a5,ffffffffc020632a <do_exit+0x154>
ffffffffc020625e:	6018                	ld	a4,0(s0)
ffffffffc0206260:	800007b7          	lui	a5,0x80000
ffffffffc0206264:	0785                	addi	a5,a5,1
ffffffffc0206266:	7308                	ld	a0,32(a4)
ffffffffc0206268:	0ec52703          	lw	a4,236(a0)
ffffffffc020626c:	0cf70363          	beq	a4,a5,ffffffffc0206332 <do_exit+0x15c>
ffffffffc0206270:	6018                	ld	a4,0(s0)
ffffffffc0206272:	7b7c                	ld	a5,240(a4)
ffffffffc0206274:	c3a1                	beqz	a5,ffffffffc02062b4 <do_exit+0xde>
ffffffffc0206276:	800009b7          	lui	s3,0x80000
ffffffffc020627a:	490d                	li	s2,3
ffffffffc020627c:	0985                	addi	s3,s3,1
ffffffffc020627e:	a021                	j	ffffffffc0206286 <do_exit+0xb0>
ffffffffc0206280:	6018                	ld	a4,0(s0)
ffffffffc0206282:	7b7c                	ld	a5,240(a4)
ffffffffc0206284:	cb85                	beqz	a5,ffffffffc02062b4 <do_exit+0xde>
ffffffffc0206286:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_bin_sfs_img_size+0xffffffff7ff8ae00>
ffffffffc020628a:	6088                	ld	a0,0(s1)
ffffffffc020628c:	fb74                	sd	a3,240(a4)
ffffffffc020628e:	7978                	ld	a4,240(a0)
ffffffffc0206290:	0e07bc23          	sd	zero,248(a5)
ffffffffc0206294:	10e7b023          	sd	a4,256(a5)
ffffffffc0206298:	c311                	beqz	a4,ffffffffc020629c <do_exit+0xc6>
ffffffffc020629a:	ff7c                	sd	a5,248(a4)
ffffffffc020629c:	4398                	lw	a4,0(a5)
ffffffffc020629e:	f388                	sd	a0,32(a5)
ffffffffc02062a0:	f97c                	sd	a5,240(a0)
ffffffffc02062a2:	fd271fe3          	bne	a4,s2,ffffffffc0206280 <do_exit+0xaa>
ffffffffc02062a6:	0ec52783          	lw	a5,236(a0)
ffffffffc02062aa:	fd379be3          	bne	a5,s3,ffffffffc0206280 <do_exit+0xaa>
ffffffffc02062ae:	2f4010ef          	jal	ra,ffffffffc02075a2 <wakeup_proc>
ffffffffc02062b2:	b7f9                	j	ffffffffc0206280 <do_exit+0xaa>
ffffffffc02062b4:	020a1263          	bnez	s4,ffffffffc02062d8 <do_exit+0x102>
ffffffffc02062b8:	39c010ef          	jal	ra,ffffffffc0207654 <schedule>
ffffffffc02062bc:	601c                	ld	a5,0(s0)
ffffffffc02062be:	00007617          	auipc	a2,0x7
ffffffffc02062c2:	68260613          	addi	a2,a2,1666 # ffffffffc020d940 <CSWTCH.79+0x138>
ffffffffc02062c6:	28400593          	li	a1,644
ffffffffc02062ca:	43d4                	lw	a3,4(a5)
ffffffffc02062cc:	00007517          	auipc	a0,0x7
ffffffffc02062d0:	62450513          	addi	a0,a0,1572 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc02062d4:	f5bf90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02062d8:	ac3fa0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02062dc:	bff1                	j	ffffffffc02062b8 <do_exit+0xe2>
ffffffffc02062de:	e4cff0ef          	jal	ra,ffffffffc020592a <files_destroy>
ffffffffc02062e2:	b7a5                	j	ffffffffc020624a <do_exit+0x74>
ffffffffc02062e4:	00007617          	auipc	a2,0x7
ffffffffc02062e8:	63c60613          	addi	a2,a2,1596 # ffffffffc020d920 <CSWTCH.79+0x118>
ffffffffc02062ec:	24f00593          	li	a1,591
ffffffffc02062f0:	00007517          	auipc	a0,0x7
ffffffffc02062f4:	60050513          	addi	a0,a0,1536 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc02062f8:	f37f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02062fc:	854e                	mv	a0,s3
ffffffffc02062fe:	e81fc0ef          	jal	ra,ffffffffc020317e <exit_mmap>
ffffffffc0206302:	0189b503          	ld	a0,24(s3) # ffffffff80000018 <_binary_bin_sfs_img_size+0xffffffff7ff8ad18>
ffffffffc0206306:	8f9ff0ef          	jal	ra,ffffffffc0205bfe <put_pgdir.isra.0>
ffffffffc020630a:	854e                	mv	a0,s3
ffffffffc020630c:	a75fc0ef          	jal	ra,ffffffffc0202d80 <mm_destroy>
ffffffffc0206310:	b715                	j	ffffffffc0206234 <do_exit+0x5e>
ffffffffc0206312:	00007617          	auipc	a2,0x7
ffffffffc0206316:	61e60613          	addi	a2,a2,1566 # ffffffffc020d930 <CSWTCH.79+0x128>
ffffffffc020631a:	25300593          	li	a1,595
ffffffffc020631e:	00007517          	auipc	a0,0x7
ffffffffc0206322:	5d250513          	addi	a0,a0,1490 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206326:	f09f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020632a:	a77fa0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020632e:	4a05                	li	s4,1
ffffffffc0206330:	b73d                	j	ffffffffc020625e <do_exit+0x88>
ffffffffc0206332:	270010ef          	jal	ra,ffffffffc02075a2 <wakeup_proc>
ffffffffc0206336:	bf2d                	j	ffffffffc0206270 <do_exit+0x9a>

ffffffffc0206338 <do_wait.part.0>:
ffffffffc0206338:	715d                	addi	sp,sp,-80
ffffffffc020633a:	f84a                	sd	s2,48(sp)
ffffffffc020633c:	f44e                	sd	s3,40(sp)
ffffffffc020633e:	80000937          	lui	s2,0x80000
ffffffffc0206342:	6989                	lui	s3,0x2
ffffffffc0206344:	fc26                	sd	s1,56(sp)
ffffffffc0206346:	f052                	sd	s4,32(sp)
ffffffffc0206348:	ec56                	sd	s5,24(sp)
ffffffffc020634a:	e85a                	sd	s6,16(sp)
ffffffffc020634c:	e45e                	sd	s7,8(sp)
ffffffffc020634e:	e486                	sd	ra,72(sp)
ffffffffc0206350:	e0a2                	sd	s0,64(sp)
ffffffffc0206352:	84aa                	mv	s1,a0
ffffffffc0206354:	8a2e                	mv	s4,a1
ffffffffc0206356:	00090b97          	auipc	s7,0x90
ffffffffc020635a:	5b2b8b93          	addi	s7,s7,1458 # ffffffffc0296908 <current>
ffffffffc020635e:	00050b1b          	sext.w	s6,a0
ffffffffc0206362:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0206366:	19f9                	addi	s3,s3,-2
ffffffffc0206368:	0905                	addi	s2,s2,1
ffffffffc020636a:	ccbd                	beqz	s1,ffffffffc02063e8 <do_wait.part.0+0xb0>
ffffffffc020636c:	0359e863          	bltu	s3,s5,ffffffffc020639c <do_wait.part.0+0x64>
ffffffffc0206370:	45a9                	li	a1,10
ffffffffc0206372:	855a                	mv	a0,s6
ffffffffc0206374:	49e050ef          	jal	ra,ffffffffc020b812 <hash32>
ffffffffc0206378:	02051793          	slli	a5,a0,0x20
ffffffffc020637c:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0206380:	0008b797          	auipc	a5,0x8b
ffffffffc0206384:	44078793          	addi	a5,a5,1088 # ffffffffc02917c0 <hash_list>
ffffffffc0206388:	953e                	add	a0,a0,a5
ffffffffc020638a:	842a                	mv	s0,a0
ffffffffc020638c:	a029                	j	ffffffffc0206396 <do_wait.part.0+0x5e>
ffffffffc020638e:	f2c42783          	lw	a5,-212(s0)
ffffffffc0206392:	02978163          	beq	a5,s1,ffffffffc02063b4 <do_wait.part.0+0x7c>
ffffffffc0206396:	6400                	ld	s0,8(s0)
ffffffffc0206398:	fe851be3          	bne	a0,s0,ffffffffc020638e <do_wait.part.0+0x56>
ffffffffc020639c:	5579                	li	a0,-2
ffffffffc020639e:	60a6                	ld	ra,72(sp)
ffffffffc02063a0:	6406                	ld	s0,64(sp)
ffffffffc02063a2:	74e2                	ld	s1,56(sp)
ffffffffc02063a4:	7942                	ld	s2,48(sp)
ffffffffc02063a6:	79a2                	ld	s3,40(sp)
ffffffffc02063a8:	7a02                	ld	s4,32(sp)
ffffffffc02063aa:	6ae2                	ld	s5,24(sp)
ffffffffc02063ac:	6b42                	ld	s6,16(sp)
ffffffffc02063ae:	6ba2                	ld	s7,8(sp)
ffffffffc02063b0:	6161                	addi	sp,sp,80
ffffffffc02063b2:	8082                	ret
ffffffffc02063b4:	000bb683          	ld	a3,0(s7)
ffffffffc02063b8:	f4843783          	ld	a5,-184(s0)
ffffffffc02063bc:	fed790e3          	bne	a5,a3,ffffffffc020639c <do_wait.part.0+0x64>
ffffffffc02063c0:	f2842703          	lw	a4,-216(s0)
ffffffffc02063c4:	478d                	li	a5,3
ffffffffc02063c6:	0ef70b63          	beq	a4,a5,ffffffffc02064bc <do_wait.part.0+0x184>
ffffffffc02063ca:	4785                	li	a5,1
ffffffffc02063cc:	c29c                	sw	a5,0(a3)
ffffffffc02063ce:	0f26a623          	sw	s2,236(a3)
ffffffffc02063d2:	282010ef          	jal	ra,ffffffffc0207654 <schedule>
ffffffffc02063d6:	000bb783          	ld	a5,0(s7)
ffffffffc02063da:	0b07a783          	lw	a5,176(a5)
ffffffffc02063de:	8b85                	andi	a5,a5,1
ffffffffc02063e0:	d7c9                	beqz	a5,ffffffffc020636a <do_wait.part.0+0x32>
ffffffffc02063e2:	555d                	li	a0,-9
ffffffffc02063e4:	df3ff0ef          	jal	ra,ffffffffc02061d6 <do_exit>
ffffffffc02063e8:	000bb683          	ld	a3,0(s7)
ffffffffc02063ec:	7ae0                	ld	s0,240(a3)
ffffffffc02063ee:	d45d                	beqz	s0,ffffffffc020639c <do_wait.part.0+0x64>
ffffffffc02063f0:	470d                	li	a4,3
ffffffffc02063f2:	a021                	j	ffffffffc02063fa <do_wait.part.0+0xc2>
ffffffffc02063f4:	10043403          	ld	s0,256(s0)
ffffffffc02063f8:	d869                	beqz	s0,ffffffffc02063ca <do_wait.part.0+0x92>
ffffffffc02063fa:	401c                	lw	a5,0(s0)
ffffffffc02063fc:	fee79ce3          	bne	a5,a4,ffffffffc02063f4 <do_wait.part.0+0xbc>
ffffffffc0206400:	00090797          	auipc	a5,0x90
ffffffffc0206404:	5107b783          	ld	a5,1296(a5) # ffffffffc0296910 <idleproc>
ffffffffc0206408:	0c878963          	beq	a5,s0,ffffffffc02064da <do_wait.part.0+0x1a2>
ffffffffc020640c:	00090797          	auipc	a5,0x90
ffffffffc0206410:	50c7b783          	ld	a5,1292(a5) # ffffffffc0296918 <initproc>
ffffffffc0206414:	0cf40363          	beq	s0,a5,ffffffffc02064da <do_wait.part.0+0x1a2>
ffffffffc0206418:	000a0663          	beqz	s4,ffffffffc0206424 <do_wait.part.0+0xec>
ffffffffc020641c:	0e842783          	lw	a5,232(s0)
ffffffffc0206420:	00fa2023          	sw	a5,0(s4)
ffffffffc0206424:	100027f3          	csrr	a5,sstatus
ffffffffc0206428:	8b89                	andi	a5,a5,2
ffffffffc020642a:	4581                	li	a1,0
ffffffffc020642c:	e7c1                	bnez	a5,ffffffffc02064b4 <do_wait.part.0+0x17c>
ffffffffc020642e:	6c70                	ld	a2,216(s0)
ffffffffc0206430:	7074                	ld	a3,224(s0)
ffffffffc0206432:	10043703          	ld	a4,256(s0)
ffffffffc0206436:	7c7c                	ld	a5,248(s0)
ffffffffc0206438:	e614                	sd	a3,8(a2)
ffffffffc020643a:	e290                	sd	a2,0(a3)
ffffffffc020643c:	6470                	ld	a2,200(s0)
ffffffffc020643e:	6874                	ld	a3,208(s0)
ffffffffc0206440:	e614                	sd	a3,8(a2)
ffffffffc0206442:	e290                	sd	a2,0(a3)
ffffffffc0206444:	c319                	beqz	a4,ffffffffc020644a <do_wait.part.0+0x112>
ffffffffc0206446:	ff7c                	sd	a5,248(a4)
ffffffffc0206448:	7c7c                	ld	a5,248(s0)
ffffffffc020644a:	c3b5                	beqz	a5,ffffffffc02064ae <do_wait.part.0+0x176>
ffffffffc020644c:	10e7b023          	sd	a4,256(a5)
ffffffffc0206450:	00090717          	auipc	a4,0x90
ffffffffc0206454:	4d070713          	addi	a4,a4,1232 # ffffffffc0296920 <nr_process>
ffffffffc0206458:	431c                	lw	a5,0(a4)
ffffffffc020645a:	37fd                	addiw	a5,a5,-1
ffffffffc020645c:	c31c                	sw	a5,0(a4)
ffffffffc020645e:	e5a9                	bnez	a1,ffffffffc02064a8 <do_wait.part.0+0x170>
ffffffffc0206460:	6814                	ld	a3,16(s0)
ffffffffc0206462:	c02007b7          	lui	a5,0xc0200
ffffffffc0206466:	04f6ee63          	bltu	a3,a5,ffffffffc02064c2 <do_wait.part.0+0x18a>
ffffffffc020646a:	00090797          	auipc	a5,0x90
ffffffffc020646e:	4867b783          	ld	a5,1158(a5) # ffffffffc02968f0 <va_pa_offset>
ffffffffc0206472:	8e9d                	sub	a3,a3,a5
ffffffffc0206474:	82b1                	srli	a3,a3,0xc
ffffffffc0206476:	00090797          	auipc	a5,0x90
ffffffffc020647a:	4627b783          	ld	a5,1122(a5) # ffffffffc02968d8 <npage>
ffffffffc020647e:	06f6fa63          	bgeu	a3,a5,ffffffffc02064f2 <do_wait.part.0+0x1ba>
ffffffffc0206482:	00009517          	auipc	a0,0x9
ffffffffc0206486:	74653503          	ld	a0,1862(a0) # ffffffffc020fbc8 <nbase>
ffffffffc020648a:	8e89                	sub	a3,a3,a0
ffffffffc020648c:	069a                	slli	a3,a3,0x6
ffffffffc020648e:	00090517          	auipc	a0,0x90
ffffffffc0206492:	45253503          	ld	a0,1106(a0) # ffffffffc02968e0 <pages>
ffffffffc0206496:	9536                	add	a0,a0,a3
ffffffffc0206498:	4589                	li	a1,2
ffffffffc020649a:	f53fa0ef          	jal	ra,ffffffffc02013ec <free_pages>
ffffffffc020649e:	8522                	mv	a0,s0
ffffffffc02064a0:	ce0fd0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc02064a4:	4501                	li	a0,0
ffffffffc02064a6:	bde5                	j	ffffffffc020639e <do_wait.part.0+0x66>
ffffffffc02064a8:	8f3fa0ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02064ac:	bf55                	j	ffffffffc0206460 <do_wait.part.0+0x128>
ffffffffc02064ae:	701c                	ld	a5,32(s0)
ffffffffc02064b0:	fbf8                	sd	a4,240(a5)
ffffffffc02064b2:	bf79                	j	ffffffffc0206450 <do_wait.part.0+0x118>
ffffffffc02064b4:	8edfa0ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02064b8:	4585                	li	a1,1
ffffffffc02064ba:	bf95                	j	ffffffffc020642e <do_wait.part.0+0xf6>
ffffffffc02064bc:	f2840413          	addi	s0,s0,-216
ffffffffc02064c0:	b781                	j	ffffffffc0206400 <do_wait.part.0+0xc8>
ffffffffc02064c2:	00006617          	auipc	a2,0x6
ffffffffc02064c6:	08e60613          	addi	a2,a2,142 # ffffffffc020c550 <commands+0xa80>
ffffffffc02064ca:	07700593          	li	a1,119
ffffffffc02064ce:	00006517          	auipc	a0,0x6
ffffffffc02064d2:	f5250513          	addi	a0,a0,-174 # ffffffffc020c420 <commands+0x950>
ffffffffc02064d6:	d59f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02064da:	00007617          	auipc	a2,0x7
ffffffffc02064de:	48660613          	addi	a2,a2,1158 # ffffffffc020d960 <CSWTCH.79+0x158>
ffffffffc02064e2:	44100593          	li	a1,1089
ffffffffc02064e6:	00007517          	auipc	a0,0x7
ffffffffc02064ea:	40a50513          	addi	a0,a0,1034 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc02064ee:	d41f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02064f2:	00006617          	auipc	a2,0x6
ffffffffc02064f6:	f0e60613          	addi	a2,a2,-242 # ffffffffc020c400 <commands+0x930>
ffffffffc02064fa:	06900593          	li	a1,105
ffffffffc02064fe:	00006517          	auipc	a0,0x6
ffffffffc0206502:	f2250513          	addi	a0,a0,-222 # ffffffffc020c420 <commands+0x950>
ffffffffc0206506:	d29f90ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020650a <init_main>:
ffffffffc020650a:	1141                	addi	sp,sp,-16
ffffffffc020650c:	00007517          	auipc	a0,0x7
ffffffffc0206510:	47450513          	addi	a0,a0,1140 # ffffffffc020d980 <CSWTCH.79+0x178>
ffffffffc0206514:	e406                	sd	ra,8(sp)
ffffffffc0206516:	228020ef          	jal	ra,ffffffffc020873e <vfs_set_bootfs>
ffffffffc020651a:	e179                	bnez	a0,ffffffffc02065e0 <init_main+0xd6>
ffffffffc020651c:	f11fa0ef          	jal	ra,ffffffffc020142c <nr_free_pages>
ffffffffc0206520:	bacfd0ef          	jal	ra,ffffffffc02038cc <kallocated>
ffffffffc0206524:	4601                	li	a2,0
ffffffffc0206526:	4581                	li	a1,0
ffffffffc0206528:	00001517          	auipc	a0,0x1
ffffffffc020652c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0206f10 <user_main>
ffffffffc0206530:	c57ff0ef          	jal	ra,ffffffffc0206186 <kernel_thread>
ffffffffc0206534:	00a04563          	bgtz	a0,ffffffffc020653e <init_main+0x34>
ffffffffc0206538:	a841                	j	ffffffffc02065c8 <init_main+0xbe>
ffffffffc020653a:	11a010ef          	jal	ra,ffffffffc0207654 <schedule>
ffffffffc020653e:	4581                	li	a1,0
ffffffffc0206540:	4501                	li	a0,0
ffffffffc0206542:	df7ff0ef          	jal	ra,ffffffffc0206338 <do_wait.part.0>
ffffffffc0206546:	d975                	beqz	a0,ffffffffc020653a <init_main+0x30>
ffffffffc0206548:	b9cff0ef          	jal	ra,ffffffffc02058e4 <fs_cleanup>
ffffffffc020654c:	00007517          	auipc	a0,0x7
ffffffffc0206550:	47c50513          	addi	a0,a0,1148 # ffffffffc020d9c8 <CSWTCH.79+0x1c0>
ffffffffc0206554:	bd7f90ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0206558:	00090797          	auipc	a5,0x90
ffffffffc020655c:	3c07b783          	ld	a5,960(a5) # ffffffffc0296918 <initproc>
ffffffffc0206560:	7bf8                	ld	a4,240(a5)
ffffffffc0206562:	e339                	bnez	a4,ffffffffc02065a8 <init_main+0x9e>
ffffffffc0206564:	7ff8                	ld	a4,248(a5)
ffffffffc0206566:	e329                	bnez	a4,ffffffffc02065a8 <init_main+0x9e>
ffffffffc0206568:	1007b703          	ld	a4,256(a5)
ffffffffc020656c:	ef15                	bnez	a4,ffffffffc02065a8 <init_main+0x9e>
ffffffffc020656e:	00090697          	auipc	a3,0x90
ffffffffc0206572:	3b26a683          	lw	a3,946(a3) # ffffffffc0296920 <nr_process>
ffffffffc0206576:	4709                	li	a4,2
ffffffffc0206578:	0ce69163          	bne	a3,a4,ffffffffc020663a <init_main+0x130>
ffffffffc020657c:	0008f717          	auipc	a4,0x8f
ffffffffc0206580:	24470713          	addi	a4,a4,580 # ffffffffc02957c0 <proc_list>
ffffffffc0206584:	6714                	ld	a3,8(a4)
ffffffffc0206586:	0c878793          	addi	a5,a5,200
ffffffffc020658a:	08d79863          	bne	a5,a3,ffffffffc020661a <init_main+0x110>
ffffffffc020658e:	6318                	ld	a4,0(a4)
ffffffffc0206590:	06e79563          	bne	a5,a4,ffffffffc02065fa <init_main+0xf0>
ffffffffc0206594:	00007517          	auipc	a0,0x7
ffffffffc0206598:	51c50513          	addi	a0,a0,1308 # ffffffffc020dab0 <CSWTCH.79+0x2a8>
ffffffffc020659c:	b8ff90ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02065a0:	60a2                	ld	ra,8(sp)
ffffffffc02065a2:	4501                	li	a0,0
ffffffffc02065a4:	0141                	addi	sp,sp,16
ffffffffc02065a6:	8082                	ret
ffffffffc02065a8:	00007697          	auipc	a3,0x7
ffffffffc02065ac:	44868693          	addi	a3,a3,1096 # ffffffffc020d9f0 <CSWTCH.79+0x1e8>
ffffffffc02065b0:	00005617          	auipc	a2,0x5
ffffffffc02065b4:	77060613          	addi	a2,a2,1904 # ffffffffc020bd20 <commands+0x250>
ffffffffc02065b8:	4b700593          	li	a1,1207
ffffffffc02065bc:	00007517          	auipc	a0,0x7
ffffffffc02065c0:	33450513          	addi	a0,a0,820 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc02065c4:	c6bf90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02065c8:	00007617          	auipc	a2,0x7
ffffffffc02065cc:	3e060613          	addi	a2,a2,992 # ffffffffc020d9a8 <CSWTCH.79+0x1a0>
ffffffffc02065d0:	4aa00593          	li	a1,1194
ffffffffc02065d4:	00007517          	auipc	a0,0x7
ffffffffc02065d8:	31c50513          	addi	a0,a0,796 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc02065dc:	c53f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02065e0:	86aa                	mv	a3,a0
ffffffffc02065e2:	00007617          	auipc	a2,0x7
ffffffffc02065e6:	3a660613          	addi	a2,a2,934 # ffffffffc020d988 <CSWTCH.79+0x180>
ffffffffc02065ea:	4a200593          	li	a1,1186
ffffffffc02065ee:	00007517          	auipc	a0,0x7
ffffffffc02065f2:	30250513          	addi	a0,a0,770 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc02065f6:	c39f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02065fa:	00007697          	auipc	a3,0x7
ffffffffc02065fe:	48668693          	addi	a3,a3,1158 # ffffffffc020da80 <CSWTCH.79+0x278>
ffffffffc0206602:	00005617          	auipc	a2,0x5
ffffffffc0206606:	71e60613          	addi	a2,a2,1822 # ffffffffc020bd20 <commands+0x250>
ffffffffc020660a:	4ba00593          	li	a1,1210
ffffffffc020660e:	00007517          	auipc	a0,0x7
ffffffffc0206612:	2e250513          	addi	a0,a0,738 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206616:	c19f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020661a:	00007697          	auipc	a3,0x7
ffffffffc020661e:	43668693          	addi	a3,a3,1078 # ffffffffc020da50 <CSWTCH.79+0x248>
ffffffffc0206622:	00005617          	auipc	a2,0x5
ffffffffc0206626:	6fe60613          	addi	a2,a2,1790 # ffffffffc020bd20 <commands+0x250>
ffffffffc020662a:	4b900593          	li	a1,1209
ffffffffc020662e:	00007517          	auipc	a0,0x7
ffffffffc0206632:	2c250513          	addi	a0,a0,706 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206636:	bf9f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020663a:	00007697          	auipc	a3,0x7
ffffffffc020663e:	40668693          	addi	a3,a3,1030 # ffffffffc020da40 <CSWTCH.79+0x238>
ffffffffc0206642:	00005617          	auipc	a2,0x5
ffffffffc0206646:	6de60613          	addi	a2,a2,1758 # ffffffffc020bd20 <commands+0x250>
ffffffffc020664a:	4b800593          	li	a1,1208
ffffffffc020664e:	00007517          	auipc	a0,0x7
ffffffffc0206652:	2a250513          	addi	a0,a0,674 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206656:	bd9f90ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020665a <do_execve>:
ffffffffc020665a:	db010113          	addi	sp,sp,-592
ffffffffc020665e:	23313423          	sd	s3,552(sp)
ffffffffc0206662:	00090997          	auipc	s3,0x90
ffffffffc0206666:	2a698993          	addi	s3,s3,678 # ffffffffc0296908 <current>
ffffffffc020666a:	0009b683          	ld	a3,0(s3)
ffffffffc020666e:	f7ee                	sd	s11,488(sp)
ffffffffc0206670:	fff58d9b          	addiw	s11,a1,-1
ffffffffc0206674:	21613823          	sd	s6,528(sp)
ffffffffc0206678:	24113423          	sd	ra,584(sp)
ffffffffc020667c:	24813023          	sd	s0,576(sp)
ffffffffc0206680:	22913c23          	sd	s1,568(sp)
ffffffffc0206684:	23213823          	sd	s2,560(sp)
ffffffffc0206688:	23413023          	sd	s4,544(sp)
ffffffffc020668c:	21513c23          	sd	s5,536(sp)
ffffffffc0206690:	21713423          	sd	s7,520(sp)
ffffffffc0206694:	21813023          	sd	s8,512(sp)
ffffffffc0206698:	ffe6                	sd	s9,504(sp)
ffffffffc020669a:	fbea                	sd	s10,496(sp)
ffffffffc020669c:	000d871b          	sext.w	a4,s11
ffffffffc02066a0:	47fd                	li	a5,31
ffffffffc02066a2:	0286bb03          	ld	s6,40(a3)
ffffffffc02066a6:	6ae7eb63          	bltu	a5,a4,ffffffffc0206d5c <do_execve+0x702>
ffffffffc02066aa:	84ae                	mv	s1,a1
ffffffffc02066ac:	842a                	mv	s0,a0
ffffffffc02066ae:	8cb2                	mv	s9,a2
ffffffffc02066b0:	4581                	li	a1,0
ffffffffc02066b2:	4641                	li	a2,16
ffffffffc02066b4:	08a8                	addi	a0,sp,88
ffffffffc02066b6:	477040ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc02066ba:	000b0c63          	beqz	s6,ffffffffc02066d2 <do_execve+0x78>
ffffffffc02066be:	038b0513          	addi	a0,s6,56
ffffffffc02066c2:	996fe0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc02066c6:	0009b783          	ld	a5,0(s3)
ffffffffc02066ca:	c781                	beqz	a5,ffffffffc02066d2 <do_execve+0x78>
ffffffffc02066cc:	43dc                	lw	a5,4(a5)
ffffffffc02066ce:	04fb2823          	sw	a5,80(s6)
ffffffffc02066d2:	1a040f63          	beqz	s0,ffffffffc0206890 <do_execve+0x236>
ffffffffc02066d6:	46c1                	li	a3,16
ffffffffc02066d8:	8622                	mv	a2,s0
ffffffffc02066da:	08ac                	addi	a1,sp,88
ffffffffc02066dc:	855a                	mv	a0,s6
ffffffffc02066de:	f3bfc0ef          	jal	ra,ffffffffc0203618 <copy_string>
ffffffffc02066e2:	72050063          	beqz	a0,ffffffffc0206e02 <do_execve+0x7a8>
ffffffffc02066e6:	00349b93          	slli	s7,s1,0x3
ffffffffc02066ea:	4681                	li	a3,0
ffffffffc02066ec:	865e                	mv	a2,s7
ffffffffc02066ee:	85e6                	mv	a1,s9
ffffffffc02066f0:	855a                	mv	a0,s6
ffffffffc02066f2:	e2dfc0ef          	jal	ra,ffffffffc020351e <user_mem_check>
ffffffffc02066f6:	8a66                	mv	s4,s9
ffffffffc02066f8:	6e050f63          	beqz	a0,ffffffffc0206df6 <do_execve+0x79c>
ffffffffc02066fc:	0e010a93          	addi	s5,sp,224
ffffffffc0206700:	8c56                	mv	s8,s5
ffffffffc0206702:	4401                	li	s0,0
ffffffffc0206704:	a011                	j	ffffffffc0206708 <do_execve+0xae>
ffffffffc0206706:	843e                	mv	s0,a5
ffffffffc0206708:	6505                	lui	a0,0x1
ffffffffc020670a:	9c6fd0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc020670e:	892a                	mv	s2,a0
ffffffffc0206710:	0e050f63          	beqz	a0,ffffffffc020680e <do_execve+0x1b4>
ffffffffc0206714:	000a3603          	ld	a2,0(s4)
ffffffffc0206718:	85aa                	mv	a1,a0
ffffffffc020671a:	6685                	lui	a3,0x1
ffffffffc020671c:	855a                	mv	a0,s6
ffffffffc020671e:	efbfc0ef          	jal	ra,ffffffffc0203618 <copy_string>
ffffffffc0206722:	16050263          	beqz	a0,ffffffffc0206886 <do_execve+0x22c>
ffffffffc0206726:	012c3023          	sd	s2,0(s8)
ffffffffc020672a:	0014079b          	addiw	a5,s0,1
ffffffffc020672e:	0c21                	addi	s8,s8,8
ffffffffc0206730:	0a21                	addi	s4,s4,8
ffffffffc0206732:	fcf49ae3          	bne	s1,a5,ffffffffc0206706 <do_execve+0xac>
ffffffffc0206736:	000cb903          	ld	s2,0(s9)
ffffffffc020673a:	080b0d63          	beqz	s6,ffffffffc02067d4 <do_execve+0x17a>
ffffffffc020673e:	038b0513          	addi	a0,s6,56
ffffffffc0206742:	912fe0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0206746:	0009b783          	ld	a5,0(s3)
ffffffffc020674a:	040b2823          	sw	zero,80(s6)
ffffffffc020674e:	1487b503          	ld	a0,328(a5)
ffffffffc0206752:	a6eff0ef          	jal	ra,ffffffffc02059c0 <files_closeall>
ffffffffc0206756:	4581                	li	a1,0
ffffffffc0206758:	854a                	mv	a0,s2
ffffffffc020675a:	9defe0ef          	jal	ra,ffffffffc0204938 <sysfile_open>
ffffffffc020675e:	8a2a                	mv	s4,a0
ffffffffc0206760:	04054463          	bltz	a0,ffffffffc02067a8 <do_execve+0x14e>
ffffffffc0206764:	00090797          	auipc	a5,0x90
ffffffffc0206768:	1647b783          	ld	a5,356(a5) # ffffffffc02968c8 <boot_pgdir_pa>
ffffffffc020676c:	577d                	li	a4,-1
ffffffffc020676e:	177e                	slli	a4,a4,0x3f
ffffffffc0206770:	83b1                	srli	a5,a5,0xc
ffffffffc0206772:	8fd9                	or	a5,a5,a4
ffffffffc0206774:	18079073          	csrw	satp,a5
ffffffffc0206778:	030b2783          	lw	a5,48(s6)
ffffffffc020677c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0206780:	02eb2823          	sw	a4,48(s6)
ffffffffc0206784:	14070963          	beqz	a4,ffffffffc02068d6 <do_execve+0x27c>
ffffffffc0206788:	0009b783          	ld	a5,0(s3)
ffffffffc020678c:	0207b423          	sd	zero,40(a5)
ffffffffc0206790:	ca2fc0ef          	jal	ra,ffffffffc0202c32 <mm_create>
ffffffffc0206794:	8b2a                	mv	s6,a0
ffffffffc0206796:	c901                	beqz	a0,ffffffffc02067a6 <do_execve+0x14c>
ffffffffc0206798:	cdcff0ef          	jal	ra,ffffffffc0205c74 <setup_pgdir>
ffffffffc020679c:	10050663          	beqz	a0,ffffffffc02068a8 <do_execve+0x24e>
ffffffffc02067a0:	855a                	mv	a0,s6
ffffffffc02067a2:	ddefc0ef          	jal	ra,ffffffffc0202d80 <mm_destroy>
ffffffffc02067a6:	5a71                	li	s4,-4
ffffffffc02067a8:	ff0a8413          	addi	s0,s5,-16 # ff0 <_binary_bin_swap_img_size-0x6d10>
ffffffffc02067ac:	fff48793          	addi	a5,s1,-1
ffffffffc02067b0:	020d9693          	slli	a3,s11,0x20
ffffffffc02067b4:	078e                	slli	a5,a5,0x3
ffffffffc02067b6:	945e                	add	s0,s0,s7
ffffffffc02067b8:	01d6d713          	srli	a4,a3,0x1d
ffffffffc02067bc:	9abe                	add	s5,s5,a5
ffffffffc02067be:	8c19                	sub	s0,s0,a4
ffffffffc02067c0:	000ab503          	ld	a0,0(s5)
ffffffffc02067c4:	1ae1                	addi	s5,s5,-8
ffffffffc02067c6:	9bafd0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc02067ca:	fe8a9be3          	bne	s5,s0,ffffffffc02067c0 <do_execve+0x166>
ffffffffc02067ce:	8552                	mv	a0,s4
ffffffffc02067d0:	a07ff0ef          	jal	ra,ffffffffc02061d6 <do_exit>
ffffffffc02067d4:	0009b783          	ld	a5,0(s3)
ffffffffc02067d8:	1487b503          	ld	a0,328(a5)
ffffffffc02067dc:	9e4ff0ef          	jal	ra,ffffffffc02059c0 <files_closeall>
ffffffffc02067e0:	4581                	li	a1,0
ffffffffc02067e2:	854a                	mv	a0,s2
ffffffffc02067e4:	954fe0ef          	jal	ra,ffffffffc0204938 <sysfile_open>
ffffffffc02067e8:	8a2a                	mv	s4,a0
ffffffffc02067ea:	fa054fe3          	bltz	a0,ffffffffc02067a8 <do_execve+0x14e>
ffffffffc02067ee:	0009b783          	ld	a5,0(s3)
ffffffffc02067f2:	779c                	ld	a5,40(a5)
ffffffffc02067f4:	dfd1                	beqz	a5,ffffffffc0206790 <do_execve+0x136>
ffffffffc02067f6:	00007617          	auipc	a2,0x7
ffffffffc02067fa:	2ea60613          	addi	a2,a2,746 # ffffffffc020dae0 <CSWTCH.79+0x2d8>
ffffffffc02067fe:	2a700593          	li	a1,679
ffffffffc0206802:	00007517          	auipc	a0,0x7
ffffffffc0206806:	0ee50513          	addi	a0,a0,238 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc020680a:	a25f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020680e:	5971                	li	s2,-4
ffffffffc0206810:	c805                	beqz	s0,ffffffffc0206840 <do_execve+0x1e6>
ffffffffc0206812:	00341693          	slli	a3,s0,0x3
ffffffffc0206816:	fff40793          	addi	a5,s0,-1
ffffffffc020681a:	ff0a8713          	addi	a4,s5,-16
ffffffffc020681e:	347d                	addiw	s0,s0,-1
ffffffffc0206820:	9736                	add	a4,a4,a3
ffffffffc0206822:	02041693          	slli	a3,s0,0x20
ffffffffc0206826:	078e                	slli	a5,a5,0x3
ffffffffc0206828:	01d6d413          	srli	s0,a3,0x1d
ffffffffc020682c:	9abe                	add	s5,s5,a5
ffffffffc020682e:	40870433          	sub	s0,a4,s0
ffffffffc0206832:	000ab503          	ld	a0,0(s5)
ffffffffc0206836:	1ae1                	addi	s5,s5,-8
ffffffffc0206838:	948fd0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020683c:	ff541be3          	bne	s0,s5,ffffffffc0206832 <do_execve+0x1d8>
ffffffffc0206840:	000b0863          	beqz	s6,ffffffffc0206850 <do_execve+0x1f6>
ffffffffc0206844:	038b0513          	addi	a0,s6,56
ffffffffc0206848:	80cfe0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020684c:	040b2823          	sw	zero,80(s6)
ffffffffc0206850:	24813083          	ld	ra,584(sp)
ffffffffc0206854:	24013403          	ld	s0,576(sp)
ffffffffc0206858:	23813483          	ld	s1,568(sp)
ffffffffc020685c:	22813983          	ld	s3,552(sp)
ffffffffc0206860:	22013a03          	ld	s4,544(sp)
ffffffffc0206864:	21813a83          	ld	s5,536(sp)
ffffffffc0206868:	21013b03          	ld	s6,528(sp)
ffffffffc020686c:	20813b83          	ld	s7,520(sp)
ffffffffc0206870:	20013c03          	ld	s8,512(sp)
ffffffffc0206874:	7cfe                	ld	s9,504(sp)
ffffffffc0206876:	7d5e                	ld	s10,496(sp)
ffffffffc0206878:	7dbe                	ld	s11,488(sp)
ffffffffc020687a:	854a                	mv	a0,s2
ffffffffc020687c:	23013903          	ld	s2,560(sp)
ffffffffc0206880:	25010113          	addi	sp,sp,592
ffffffffc0206884:	8082                	ret
ffffffffc0206886:	854a                	mv	a0,s2
ffffffffc0206888:	8f8fd0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020688c:	5975                	li	s2,-3
ffffffffc020688e:	b749                	j	ffffffffc0206810 <do_execve+0x1b6>
ffffffffc0206890:	0009b783          	ld	a5,0(s3)
ffffffffc0206894:	00007617          	auipc	a2,0x7
ffffffffc0206898:	23c60613          	addi	a2,a2,572 # ffffffffc020dad0 <CSWTCH.79+0x2c8>
ffffffffc020689c:	45c1                	li	a1,16
ffffffffc020689e:	43d4                	lw	a3,4(a5)
ffffffffc02068a0:	08a8                	addi	a0,sp,88
ffffffffc02068a2:	723040ef          	jal	ra,ffffffffc020b7c4 <snprintf>
ffffffffc02068a6:	b581                	j	ffffffffc02066e6 <do_execve+0x8c>
ffffffffc02068a8:	4601                	li	a2,0
ffffffffc02068aa:	4581                	li	a1,0
ffffffffc02068ac:	8552                	mv	a0,s4
ffffffffc02068ae:	af0fe0ef          	jal	ra,ffffffffc0204b9e <sysfile_seek>
ffffffffc02068b2:	892a                	mv	s2,a0
ffffffffc02068b4:	ed51                	bnez	a0,ffffffffc0206950 <do_execve+0x2f6>
ffffffffc02068b6:	04000613          	li	a2,64
ffffffffc02068ba:	110c                	addi	a1,sp,160
ffffffffc02068bc:	8552                	mv	a0,s4
ffffffffc02068be:	8b2fe0ef          	jal	ra,ffffffffc0204970 <sysfile_read>
ffffffffc02068c2:	04000793          	li	a5,64
ffffffffc02068c6:	02f50363          	beq	a0,a5,ffffffffc02068ec <do_execve+0x292>
ffffffffc02068ca:	0005091b          	sext.w	s2,a0
ffffffffc02068ce:	08054163          	bltz	a0,ffffffffc0206950 <do_execve+0x2f6>
ffffffffc02068d2:	597d                	li	s2,-1
ffffffffc02068d4:	a8b5                	j	ffffffffc0206950 <do_execve+0x2f6>
ffffffffc02068d6:	855a                	mv	a0,s6
ffffffffc02068d8:	8a7fc0ef          	jal	ra,ffffffffc020317e <exit_mmap>
ffffffffc02068dc:	018b3503          	ld	a0,24(s6)
ffffffffc02068e0:	b1eff0ef          	jal	ra,ffffffffc0205bfe <put_pgdir.isra.0>
ffffffffc02068e4:	855a                	mv	a0,s6
ffffffffc02068e6:	c9afc0ef          	jal	ra,ffffffffc0202d80 <mm_destroy>
ffffffffc02068ea:	bd79                	j	ffffffffc0206788 <do_execve+0x12e>
ffffffffc02068ec:	570a                	lw	a4,160(sp)
ffffffffc02068ee:	464c47b7          	lui	a5,0x464c4
ffffffffc02068f2:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_bin_sfs_img_size+0x4644f27f>
ffffffffc02068f6:	3af71e63          	bne	a4,a5,ffffffffc0206cb2 <do_execve+0x658>
ffffffffc02068fa:	0d815783          	lhu	a5,216(sp)
ffffffffc02068fe:	f802                	sd	zero,48(sp)
ffffffffc0206900:	fc02                	sd	zero,56(sp)
ffffffffc0206902:	18078563          	beqz	a5,ffffffffc0206a8c <do_execve+0x432>
ffffffffc0206906:	57fd                	li	a5,-1
ffffffffc0206908:	83b1                	srli	a5,a5,0xc
ffffffffc020690a:	e83e                	sd	a5,16(sp)
ffffffffc020690c:	ec5e                	sd	s7,24(sp)
ffffffffc020690e:	e4a2                	sd	s0,72(sp)
ffffffffc0206910:	f026                	sd	s1,32(sp)
ffffffffc0206912:	d66e                	sw	s11,44(sp)
ffffffffc0206914:	658e                	ld	a1,192(sp)
ffffffffc0206916:	77c2                	ld	a5,48(sp)
ffffffffc0206918:	4601                	li	a2,0
ffffffffc020691a:	8552                	mv	a0,s4
ffffffffc020691c:	95be                	add	a1,a1,a5
ffffffffc020691e:	a80fe0ef          	jal	ra,ffffffffc0204b9e <sysfile_seek>
ffffffffc0206922:	12051d63          	bnez	a0,ffffffffc0206a5c <do_execve+0x402>
ffffffffc0206926:	03800613          	li	a2,56
ffffffffc020692a:	10ac                	addi	a1,sp,104
ffffffffc020692c:	8552                	mv	a0,s4
ffffffffc020692e:	842fe0ef          	jal	ra,ffffffffc0204970 <sysfile_read>
ffffffffc0206932:	03800793          	li	a5,56
ffffffffc0206936:	12f50863          	beq	a0,a5,ffffffffc0206a66 <do_execve+0x40c>
ffffffffc020693a:	6be2                	ld	s7,24(sp)
ffffffffc020693c:	7482                	ld	s1,32(sp)
ffffffffc020693e:	5db2                	lw	s11,44(sp)
ffffffffc0206940:	0005091b          	sext.w	s2,a0
ffffffffc0206944:	00054363          	bltz	a0,ffffffffc020694a <do_execve+0x2f0>
ffffffffc0206948:	597d                	li	s2,-1
ffffffffc020694a:	855a                	mv	a0,s6
ffffffffc020694c:	833fc0ef          	jal	ra,ffffffffc020317e <exit_mmap>
ffffffffc0206950:	018b3503          	ld	a0,24(s6)
ffffffffc0206954:	8a4a                	mv	s4,s2
ffffffffc0206956:	aa8ff0ef          	jal	ra,ffffffffc0205bfe <put_pgdir.isra.0>
ffffffffc020695a:	855a                	mv	a0,s6
ffffffffc020695c:	c24fc0ef          	jal	ra,ffffffffc0202d80 <mm_destroy>
ffffffffc0206960:	b5a1                	j	ffffffffc02067a8 <do_execve+0x14e>
ffffffffc0206962:	664a                	ld	a2,144(sp)
ffffffffc0206964:	67aa                	ld	a5,136(sp)
ffffffffc0206966:	4af66f63          	bltu	a2,a5,ffffffffc0206e24 <do_execve+0x7ca>
ffffffffc020696a:	57b6                	lw	a5,108(sp)
ffffffffc020696c:	0017f693          	andi	a3,a5,1
ffffffffc0206970:	c291                	beqz	a3,ffffffffc0206974 <do_execve+0x31a>
ffffffffc0206972:	4691                	li	a3,4
ffffffffc0206974:	0027f713          	andi	a4,a5,2
ffffffffc0206978:	8b91                	andi	a5,a5,4
ffffffffc020697a:	34071563          	bnez	a4,ffffffffc0206cc4 <do_execve+0x66a>
ffffffffc020697e:	4745                	li	a4,17
ffffffffc0206980:	e0ba                	sd	a4,64(sp)
ffffffffc0206982:	c789                	beqz	a5,ffffffffc020698c <do_execve+0x332>
ffffffffc0206984:	47cd                	li	a5,19
ffffffffc0206986:	0016e693          	ori	a3,a3,1
ffffffffc020698a:	e0be                	sd	a5,64(sp)
ffffffffc020698c:	0026f793          	andi	a5,a3,2
ffffffffc0206990:	32079e63          	bnez	a5,ffffffffc0206ccc <do_execve+0x672>
ffffffffc0206994:	0046f793          	andi	a5,a3,4
ffffffffc0206998:	c789                	beqz	a5,ffffffffc02069a2 <do_execve+0x348>
ffffffffc020699a:	6786                	ld	a5,64(sp)
ffffffffc020699c:	0087e793          	ori	a5,a5,8
ffffffffc02069a0:	e0be                	sd	a5,64(sp)
ffffffffc02069a2:	75e6                	ld	a1,120(sp)
ffffffffc02069a4:	4701                	li	a4,0
ffffffffc02069a6:	855a                	mv	a0,s6
ffffffffc02069a8:	c2afc0ef          	jal	ra,ffffffffc0202dd2 <mm_map>
ffffffffc02069ac:	e945                	bnez	a0,ffffffffc0206a5c <do_execve+0x402>
ffffffffc02069ae:	7de6                	ld	s11,120(sp)
ffffffffc02069b0:	6caa                	ld	s9,136(sp)
ffffffffc02069b2:	76fd                	lui	a3,0xfffff
ffffffffc02069b4:	7c46                	ld	s8,112(sp)
ffffffffc02069b6:	9cee                	add	s9,s9,s11
ffffffffc02069b8:	00ddf4b3          	and	s1,s11,a3
ffffffffc02069bc:	459dfd63          	bgeu	s11,s9,ffffffffc0206e16 <do_execve+0x7bc>
ffffffffc02069c0:	6906                	ld	s2,64(sp)
ffffffffc02069c2:	8d26                	mv	s10,s1
ffffffffc02069c4:	a01d                	j	ffffffffc02069ea <do_execve+0x390>
ffffffffc02069c6:	6702                	ld	a4,0(sp)
ffffffffc02069c8:	67a2                	ld	a5,8(sp)
ffffffffc02069ca:	41ad8d33          	sub	s10,s11,s10
ffffffffc02069ce:	865e                	mv	a2,s7
ffffffffc02069d0:	00f705b3          	add	a1,a4,a5
ffffffffc02069d4:	95ea                	add	a1,a1,s10
ffffffffc02069d6:	8552                	mv	a0,s4
ffffffffc02069d8:	f99fd0ef          	jal	ra,ffffffffc0204970 <sysfile_read>
ffffffffc02069dc:	f4ab9fe3          	bne	s7,a0,ffffffffc020693a <do_execve+0x2e0>
ffffffffc02069e0:	9dde                	add	s11,s11,s7
ffffffffc02069e2:	9c5e                	add	s8,s8,s7
ffffffffc02069e4:	379dfe63          	bgeu	s11,s9,ffffffffc0206d60 <do_execve+0x706>
ffffffffc02069e8:	8d26                	mv	s10,s1
ffffffffc02069ea:	018b3503          	ld	a0,24(s6)
ffffffffc02069ee:	864a                	mv	a2,s2
ffffffffc02069f0:	85ea                	mv	a1,s10
ffffffffc02069f2:	95afc0ef          	jal	ra,ffffffffc0202b4c <pgdir_alloc_page>
ffffffffc02069f6:	842a                	mv	s0,a0
ffffffffc02069f8:	34050d63          	beqz	a0,ffffffffc0206d52 <do_execve+0x6f8>
ffffffffc02069fc:	6785                	lui	a5,0x1
ffffffffc02069fe:	00fd04b3          	add	s1,s10,a5
ffffffffc0206a02:	41b48bb3          	sub	s7,s1,s11
ffffffffc0206a06:	009cf463          	bgeu	s9,s1,ffffffffc0206a0e <do_execve+0x3b4>
ffffffffc0206a0a:	41bc8bb3          	sub	s7,s9,s11
ffffffffc0206a0e:	00090797          	auipc	a5,0x90
ffffffffc0206a12:	ed278793          	addi	a5,a5,-302 # ffffffffc02968e0 <pages>
ffffffffc0206a16:	638c                	ld	a1,0(a5)
ffffffffc0206a18:	00009797          	auipc	a5,0x9
ffffffffc0206a1c:	1b078793          	addi	a5,a5,432 # ffffffffc020fbc8 <nbase>
ffffffffc0206a20:	6390                	ld	a2,0(a5)
ffffffffc0206a22:	00090797          	auipc	a5,0x90
ffffffffc0206a26:	eb678793          	addi	a5,a5,-330 # ffffffffc02968d8 <npage>
ffffffffc0206a2a:	6394                	ld	a3,0(a5)
ffffffffc0206a2c:	40b405b3          	sub	a1,s0,a1
ffffffffc0206a30:	67c2                	ld	a5,16(sp)
ffffffffc0206a32:	8599                	srai	a1,a1,0x6
ffffffffc0206a34:	95b2                	add	a1,a1,a2
ffffffffc0206a36:	00f5f633          	and	a2,a1,a5
ffffffffc0206a3a:	00c59793          	slli	a5,a1,0xc
ffffffffc0206a3e:	e03e                	sd	a5,0(sp)
ffffffffc0206a40:	4ad67b63          	bgeu	a2,a3,ffffffffc0206ef6 <do_execve+0x89c>
ffffffffc0206a44:	00090797          	auipc	a5,0x90
ffffffffc0206a48:	eac78793          	addi	a5,a5,-340 # ffffffffc02968f0 <va_pa_offset>
ffffffffc0206a4c:	639c                	ld	a5,0(a5)
ffffffffc0206a4e:	4601                	li	a2,0
ffffffffc0206a50:	85e2                	mv	a1,s8
ffffffffc0206a52:	8552                	mv	a0,s4
ffffffffc0206a54:	e43e                	sd	a5,8(sp)
ffffffffc0206a56:	948fe0ef          	jal	ra,ffffffffc0204b9e <sysfile_seek>
ffffffffc0206a5a:	d535                	beqz	a0,ffffffffc02069c6 <do_execve+0x36c>
ffffffffc0206a5c:	6be2                	ld	s7,24(sp)
ffffffffc0206a5e:	7482                	ld	s1,32(sp)
ffffffffc0206a60:	5db2                	lw	s11,44(sp)
ffffffffc0206a62:	892a                	mv	s2,a0
ffffffffc0206a64:	b5dd                	j	ffffffffc020694a <do_execve+0x2f0>
ffffffffc0206a66:	5726                	lw	a4,104(sp)
ffffffffc0206a68:	4785                	li	a5,1
ffffffffc0206a6a:	eef70ce3          	beq	a4,a5,ffffffffc0206962 <do_execve+0x308>
ffffffffc0206a6e:	7762                	ld	a4,56(sp)
ffffffffc0206a70:	76c2                	ld	a3,48(sp)
ffffffffc0206a72:	0d815783          	lhu	a5,216(sp)
ffffffffc0206a76:	2705                	addiw	a4,a4,1
ffffffffc0206a78:	03868693          	addi	a3,a3,56 # fffffffffffff038 <end+0x3fd686e0>
ffffffffc0206a7c:	fc3a                	sd	a4,56(sp)
ffffffffc0206a7e:	f836                	sd	a3,48(sp)
ffffffffc0206a80:	e8f76ae3          	bltu	a4,a5,ffffffffc0206914 <do_execve+0x2ba>
ffffffffc0206a84:	6be2                	ld	s7,24(sp)
ffffffffc0206a86:	6426                	ld	s0,72(sp)
ffffffffc0206a88:	7482                	ld	s1,32(sp)
ffffffffc0206a8a:	5db2                	lw	s11,44(sp)
ffffffffc0206a8c:	8552                	mv	a0,s4
ffffffffc0206a8e:	edffd0ef          	jal	ra,ffffffffc020496c <sysfile_close>
ffffffffc0206a92:	4701                	li	a4,0
ffffffffc0206a94:	46ad                	li	a3,11
ffffffffc0206a96:	00100637          	lui	a2,0x100
ffffffffc0206a9a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0206a9e:	855a                	mv	a0,s6
ffffffffc0206aa0:	b32fc0ef          	jal	ra,ffffffffc0202dd2 <mm_map>
ffffffffc0206aa4:	892a                	mv	s2,a0
ffffffffc0206aa6:	ea0512e3          	bnez	a0,ffffffffc020694a <do_execve+0x2f0>
ffffffffc0206aaa:	018b3503          	ld	a0,24(s6)
ffffffffc0206aae:	467d                	li	a2,31
ffffffffc0206ab0:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0206ab4:	898fc0ef          	jal	ra,ffffffffc0202b4c <pgdir_alloc_page>
ffffffffc0206ab8:	40050363          	beqz	a0,ffffffffc0206ebe <do_execve+0x864>
ffffffffc0206abc:	018b3503          	ld	a0,24(s6)
ffffffffc0206ac0:	467d                	li	a2,31
ffffffffc0206ac2:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0206ac6:	886fc0ef          	jal	ra,ffffffffc0202b4c <pgdir_alloc_page>
ffffffffc0206aca:	3c050a63          	beqz	a0,ffffffffc0206e9e <do_execve+0x844>
ffffffffc0206ace:	018b3503          	ld	a0,24(s6)
ffffffffc0206ad2:	467d                	li	a2,31
ffffffffc0206ad4:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0206ad8:	874fc0ef          	jal	ra,ffffffffc0202b4c <pgdir_alloc_page>
ffffffffc0206adc:	3a050163          	beqz	a0,ffffffffc0206e7e <do_execve+0x824>
ffffffffc0206ae0:	018b3503          	ld	a0,24(s6)
ffffffffc0206ae4:	467d                	li	a2,31
ffffffffc0206ae6:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0206aea:	862fc0ef          	jal	ra,ffffffffc0202b4c <pgdir_alloc_page>
ffffffffc0206aee:	36050863          	beqz	a0,ffffffffc0206e5e <do_execve+0x804>
ffffffffc0206af2:	030b2783          	lw	a5,48(s6)
ffffffffc0206af6:	0009b703          	ld	a4,0(s3)
ffffffffc0206afa:	018b3683          	ld	a3,24(s6)
ffffffffc0206afe:	2785                	addiw	a5,a5,1
ffffffffc0206b00:	02fb2823          	sw	a5,48(s6)
ffffffffc0206b04:	03673423          	sd	s6,40(a4)
ffffffffc0206b08:	c02007b7          	lui	a5,0xc0200
ffffffffc0206b0c:	3cf6e963          	bltu	a3,a5,ffffffffc0206ede <do_execve+0x884>
ffffffffc0206b10:	00090d17          	auipc	s10,0x90
ffffffffc0206b14:	de0d0d13          	addi	s10,s10,-544 # ffffffffc02968f0 <va_pa_offset>
ffffffffc0206b18:	000d3783          	ld	a5,0(s10)
ffffffffc0206b1c:	8e9d                	sub	a3,a3,a5
ffffffffc0206b1e:	f754                	sd	a3,168(a4)
ffffffffc0206b20:	577d                	li	a4,-1
ffffffffc0206b22:	00c6d793          	srli	a5,a3,0xc
ffffffffc0206b26:	177e                	slli	a4,a4,0x3f
ffffffffc0206b28:	8fd9                	or	a5,a5,a4
ffffffffc0206b2a:	18079073          	csrw	satp,a5
ffffffffc0206b2e:	4c81                	li	s9,0
ffffffffc0206b30:	8c56                	mv	s8,s5
ffffffffc0206b32:	4a01                	li	s4,0
ffffffffc0206b34:	000c3503          	ld	a0,0(s8)
ffffffffc0206b38:	6585                	lui	a1,0x1
ffffffffc0206b3a:	0c21                	addi	s8,s8,8
ffffffffc0206b3c:	768040ef          	jal	ra,ffffffffc020b2a4 <strnlen>
ffffffffc0206b40:	00150793          	addi	a5,a0,1
ffffffffc0206b44:	8766                	mv	a4,s9
ffffffffc0206b46:	01478a3b          	addw	s4,a5,s4
ffffffffc0206b4a:	2c85                	addiw	s9,s9,1
ffffffffc0206b4c:	fe8744e3          	blt	a4,s0,ffffffffc0206b34 <do_execve+0x4da>
ffffffffc0206b50:	1a02                	slli	s4,s4,0x20
ffffffffc0206b52:	4c05                	li	s8,1
ffffffffc0206b54:	0c7e                	slli	s8,s8,0x1f
ffffffffc0206b56:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206b5a:	414c0a33          	sub	s4,s8,s4
ffffffffc0206b5e:	ff8a7c13          	andi	s8,s4,-8
ffffffffc0206b62:	6785                	lui	a5,0x1
ffffffffc0206b64:	17fd                	addi	a5,a5,-1
ffffffffc0206b66:	417c0a33          	sub	s4,s8,s7
ffffffffc0206b6a:	4701                	li	a4,0
ffffffffc0206b6c:	ec3e                	sd	a5,24(sp)
ffffffffc0206b6e:	415a07b3          	sub	a5,s4,s5
ffffffffc0206b72:	e426                	sd	s1,8(sp)
ffffffffc0206b74:	8cd6                	mv	s9,s5
ffffffffc0206b76:	f03e                	sd	a5,32(sp)
ffffffffc0206b78:	e05e                	sd	s7,0(sp)
ffffffffc0206b7a:	e84a                	sd	s2,16(sp)
ffffffffc0206b7c:	84ba                	mv	s1,a4
ffffffffc0206b7e:	a011                	j	ffffffffc0206b82 <do_execve+0x528>
ffffffffc0206b80:	84ba                	mv	s1,a4
ffffffffc0206b82:	000cb903          	ld	s2,0(s9)
ffffffffc0206b86:	6585                	lui	a1,0x1
ffffffffc0206b88:	854a                	mv	a0,s2
ffffffffc0206b8a:	71a040ef          	jal	ra,ffffffffc020b2a4 <strnlen>
ffffffffc0206b8e:	8baa                	mv	s7,a0
ffffffffc0206b90:	018b3503          	ld	a0,24(s6)
ffffffffc0206b94:	4601                	li	a2,0
ffffffffc0206b96:	85e2                	mv	a1,s8
ffffffffc0206b98:	0b85                	addi	s7,s7,1
ffffffffc0206b9a:	8cdfa0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc0206b9e:	26050f63          	beqz	a0,ffffffffc0206e1c <do_execve+0x7c2>
ffffffffc0206ba2:	611c                	ld	a5,0(a0)
ffffffffc0206ba4:	0017f693          	andi	a3,a5,1
ffffffffc0206ba8:	26068a63          	beqz	a3,ffffffffc0206e1c <do_execve+0x7c2>
ffffffffc0206bac:	00279693          	slli	a3,a5,0x2
ffffffffc0206bb0:	77fd                	lui	a5,0xfffff
ffffffffc0206bb2:	8efd                	and	a3,a3,a5
ffffffffc0206bb4:	67e2                	ld	a5,24(sp)
ffffffffc0206bb6:	00090717          	auipc	a4,0x90
ffffffffc0206bba:	d2270713          	addi	a4,a4,-734 # ffffffffc02968d8 <npage>
ffffffffc0206bbe:	6310                	ld	a2,0(a4)
ffffffffc0206bc0:	00fc77b3          	and	a5,s8,a5
ffffffffc0206bc4:	8edd                	or	a3,a3,a5
ffffffffc0206bc6:	00c6d793          	srli	a5,a3,0xc
ffffffffc0206bca:	26c7fe63          	bgeu	a5,a2,ffffffffc0206e46 <do_execve+0x7ec>
ffffffffc0206bce:	000d3503          	ld	a0,0(s10)
ffffffffc0206bd2:	85ca                	mv	a1,s2
ffffffffc0206bd4:	865e                	mv	a2,s7
ffffffffc0206bd6:	9536                	add	a0,a0,a3
ffffffffc0206bd8:	7a6040ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc0206bdc:	7782                	ld	a5,32(sp)
ffffffffc0206bde:	018b3503          	ld	a0,24(s6)
ffffffffc0206be2:	4601                	li	a2,0
ffffffffc0206be4:	01978933          	add	s2,a5,s9
ffffffffc0206be8:	85ca                	mv	a1,s2
ffffffffc0206bea:	87dfa0ef          	jal	ra,ffffffffc0201466 <get_pte>
ffffffffc0206bee:	22050763          	beqz	a0,ffffffffc0206e1c <do_execve+0x7c2>
ffffffffc0206bf2:	611c                	ld	a5,0(a0)
ffffffffc0206bf4:	0017f713          	andi	a4,a5,1
ffffffffc0206bf8:	22070263          	beqz	a4,ffffffffc0206e1c <do_execve+0x7c2>
ffffffffc0206bfc:	00279693          	slli	a3,a5,0x2
ffffffffc0206c00:	77fd                	lui	a5,0xfffff
ffffffffc0206c02:	8efd                	and	a3,a3,a5
ffffffffc0206c04:	67e2                	ld	a5,24(sp)
ffffffffc0206c06:	00f975b3          	and	a1,s2,a5
ffffffffc0206c0a:	00090797          	auipc	a5,0x90
ffffffffc0206c0e:	cce78793          	addi	a5,a5,-818 # ffffffffc02968d8 <npage>
ffffffffc0206c12:	639c                	ld	a5,0(a5)
ffffffffc0206c14:	8ecd                	or	a3,a3,a1
ffffffffc0206c16:	00c6d713          	srli	a4,a3,0xc
ffffffffc0206c1a:	20f77a63          	bgeu	a4,a5,ffffffffc0206e2e <do_execve+0x7d4>
ffffffffc0206c1e:	000d3783          	ld	a5,0(s10)
ffffffffc0206c22:	0014871b          	addiw	a4,s1,1
ffffffffc0206c26:	0ca1                	addi	s9,s9,8
ffffffffc0206c28:	96be                	add	a3,a3,a5
ffffffffc0206c2a:	0186b023          	sd	s8,0(a3)
ffffffffc0206c2e:	9c5e                	add	s8,s8,s7
ffffffffc0206c30:	f484c8e3          	blt	s1,s0,ffffffffc0206b80 <do_execve+0x526>
ffffffffc0206c34:	0009b783          	ld	a5,0(s3)
ffffffffc0206c38:	64a2                	ld	s1,8(sp)
ffffffffc0206c3a:	12000613          	li	a2,288
ffffffffc0206c3e:	73c0                	ld	s0,160(a5)
ffffffffc0206c40:	4581                	li	a1,0
ffffffffc0206c42:	6b82                	ld	s7,0(sp)
ffffffffc0206c44:	10043b03          	ld	s6,256(s0)
ffffffffc0206c48:	8522                	mv	a0,s0
ffffffffc0206c4a:	6942                	ld	s2,16(sp)
ffffffffc0206c4c:	6e0040ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc0206c50:	76ea                	ld	a3,184(sp)
ffffffffc0206c52:	ff0a8713          	addi	a4,s5,-16
ffffffffc0206c56:	edfb7b13          	andi	s6,s6,-289
ffffffffc0206c5a:	fff48793          	addi	a5,s1,-1
ffffffffc0206c5e:	020d9613          	slli	a2,s11,0x20
ffffffffc0206c62:	9bba                	add	s7,s7,a4
ffffffffc0206c64:	020b6b13          	ori	s6,s6,32
ffffffffc0206c68:	078e                	slli	a5,a5,0x3
ffffffffc0206c6a:	01d65713          	srli	a4,a2,0x1d
ffffffffc0206c6e:	01443823          	sd	s4,16(s0)
ffffffffc0206c72:	10d43423          	sd	a3,264(s0)
ffffffffc0206c76:	11643023          	sd	s6,256(s0)
ffffffffc0206c7a:	e824                	sd	s1,80(s0)
ffffffffc0206c7c:	05443c23          	sd	s4,88(s0)
ffffffffc0206c80:	9abe                	add	s5,s5,a5
ffffffffc0206c82:	40eb8bb3          	sub	s7,s7,a4
ffffffffc0206c86:	000ab503          	ld	a0,0(s5)
ffffffffc0206c8a:	1ae1                	addi	s5,s5,-8
ffffffffc0206c8c:	cf5fc0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0206c90:	ff5b9be3          	bne	s7,s5,ffffffffc0206c86 <do_execve+0x62c>
ffffffffc0206c94:	0009b403          	ld	s0,0(s3)
ffffffffc0206c98:	4641                	li	a2,16
ffffffffc0206c9a:	4581                	li	a1,0
ffffffffc0206c9c:	0b440413          	addi	s0,s0,180
ffffffffc0206ca0:	8522                	mv	a0,s0
ffffffffc0206ca2:	68a040ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc0206ca6:	463d                	li	a2,15
ffffffffc0206ca8:	08ac                	addi	a1,sp,88
ffffffffc0206caa:	8522                	mv	a0,s0
ffffffffc0206cac:	6d2040ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc0206cb0:	b645                	j	ffffffffc0206850 <do_execve+0x1f6>
ffffffffc0206cb2:	018b3503          	ld	a0,24(s6)
ffffffffc0206cb6:	5a61                	li	s4,-8
ffffffffc0206cb8:	f47fe0ef          	jal	ra,ffffffffc0205bfe <put_pgdir.isra.0>
ffffffffc0206cbc:	855a                	mv	a0,s6
ffffffffc0206cbe:	8c2fc0ef          	jal	ra,ffffffffc0202d80 <mm_destroy>
ffffffffc0206cc2:	b4dd                	j	ffffffffc02067a8 <do_execve+0x14e>
ffffffffc0206cc4:	0026e693          	ori	a3,a3,2
ffffffffc0206cc8:	ca079ee3          	bnez	a5,ffffffffc0206984 <do_execve+0x32a>
ffffffffc0206ccc:	47dd                	li	a5,23
ffffffffc0206cce:	e0be                	sd	a5,64(sp)
ffffffffc0206cd0:	b1d1                	j	ffffffffc0206994 <do_execve+0x33a>
ffffffffc0206cd2:	11779263          	bne	a5,s7,ffffffffc0206dd6 <do_execve+0x77c>
ffffffffc0206cd6:	8dde                	mv	s11,s7
ffffffffc0206cd8:	d98dfbe3          	bgeu	s11,s8,ffffffffc0206a6e <do_execve+0x414>
ffffffffc0206cdc:	6906                	ld	s2,64(sp)
ffffffffc0206cde:	6485                	lui	s1,0x1
ffffffffc0206ce0:	00090d17          	auipc	s10,0x90
ffffffffc0206ce4:	bf8d0d13          	addi	s10,s10,-1032 # ffffffffc02968d8 <npage>
ffffffffc0206ce8:	00090c97          	auipc	s9,0x90
ffffffffc0206cec:	c08c8c93          	addi	s9,s9,-1016 # ffffffffc02968f0 <va_pa_offset>
ffffffffc0206cf0:	a889                	j	ffffffffc0206d42 <do_execve+0x6e8>
ffffffffc0206cf2:	417d8533          	sub	a0,s11,s7
ffffffffc0206cf6:	9ba6                	add	s7,s7,s1
ffffffffc0206cf8:	41bb8633          	sub	a2,s7,s11
ffffffffc0206cfc:	017c7463          	bgeu	s8,s7,ffffffffc0206d04 <do_execve+0x6aa>
ffffffffc0206d00:	41bc0633          	sub	a2,s8,s11
ffffffffc0206d04:	00090797          	auipc	a5,0x90
ffffffffc0206d08:	bdc78793          	addi	a5,a5,-1060 # ffffffffc02968e0 <pages>
ffffffffc0206d0c:	639c                	ld	a5,0(a5)
ffffffffc0206d0e:	00009717          	auipc	a4,0x9
ffffffffc0206d12:	eba70713          	addi	a4,a4,-326 # ffffffffc020fbc8 <nbase>
ffffffffc0206d16:	6314                	ld	a3,0(a4)
ffffffffc0206d18:	40f407b3          	sub	a5,s0,a5
ffffffffc0206d1c:	8799                	srai	a5,a5,0x6
ffffffffc0206d1e:	97b6                	add	a5,a5,a3
ffffffffc0206d20:	66c2                	ld	a3,16(sp)
ffffffffc0206d22:	000d3703          	ld	a4,0(s10)
ffffffffc0206d26:	8efd                	and	a3,a3,a5
ffffffffc0206d28:	07b2                	slli	a5,a5,0xc
ffffffffc0206d2a:	1ce6f663          	bgeu	a3,a4,ffffffffc0206ef6 <do_execve+0x89c>
ffffffffc0206d2e:	000cb703          	ld	a4,0(s9)
ffffffffc0206d32:	9db2                	add	s11,s11,a2
ffffffffc0206d34:	4581                	li	a1,0
ffffffffc0206d36:	97ba                	add	a5,a5,a4
ffffffffc0206d38:	953e                	add	a0,a0,a5
ffffffffc0206d3a:	5f2040ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc0206d3e:	0d8df063          	bgeu	s11,s8,ffffffffc0206dfe <do_execve+0x7a4>
ffffffffc0206d42:	018b3503          	ld	a0,24(s6)
ffffffffc0206d46:	864a                	mv	a2,s2
ffffffffc0206d48:	85de                	mv	a1,s7
ffffffffc0206d4a:	e03fb0ef          	jal	ra,ffffffffc0202b4c <pgdir_alloc_page>
ffffffffc0206d4e:	842a                	mv	s0,a0
ffffffffc0206d50:	f14d                	bnez	a0,ffffffffc0206cf2 <do_execve+0x698>
ffffffffc0206d52:	6be2                	ld	s7,24(sp)
ffffffffc0206d54:	7482                	ld	s1,32(sp)
ffffffffc0206d56:	5db2                	lw	s11,44(sp)
ffffffffc0206d58:	5971                	li	s2,-4
ffffffffc0206d5a:	bec5                	j	ffffffffc020694a <do_execve+0x2f0>
ffffffffc0206d5c:	5975                	li	s2,-3
ffffffffc0206d5e:	bccd                	j	ffffffffc0206850 <do_execve+0x1f6>
ffffffffc0206d60:	7c66                	ld	s8,120(sp)
ffffffffc0206d62:	8ba6                	mv	s7,s1
ffffffffc0206d64:	8d22                	mv	s10,s0
ffffffffc0206d66:	66ca                	ld	a3,144(sp)
ffffffffc0206d68:	9c36                	add	s8,s8,a3
ffffffffc0206d6a:	f77df7e3          	bgeu	s11,s7,ffffffffc0206cd8 <do_execve+0x67e>
ffffffffc0206d6e:	d18d80e3          	beq	s11,s8,ffffffffc0206a6e <do_execve+0x414>
ffffffffc0206d72:	6505                	lui	a0,0x1
ffffffffc0206d74:	956e                	add	a0,a0,s11
ffffffffc0206d76:	41750533          	sub	a0,a0,s7
ffffffffc0206d7a:	41bc0cb3          	sub	s9,s8,s11
ffffffffc0206d7e:	017c6463          	bltu	s8,s7,ffffffffc0206d86 <do_execve+0x72c>
ffffffffc0206d82:	41bb8cb3          	sub	s9,s7,s11
ffffffffc0206d86:	00090797          	auipc	a5,0x90
ffffffffc0206d8a:	b5a78793          	addi	a5,a5,-1190 # ffffffffc02968e0 <pages>
ffffffffc0206d8e:	6394                	ld	a3,0(a5)
ffffffffc0206d90:	00009797          	auipc	a5,0x9
ffffffffc0206d94:	e3878793          	addi	a5,a5,-456 # ffffffffc020fbc8 <nbase>
ffffffffc0206d98:	638c                	ld	a1,0(a5)
ffffffffc0206d9a:	40dd06b3          	sub	a3,s10,a3
ffffffffc0206d9e:	67c2                	ld	a5,16(sp)
ffffffffc0206da0:	8699                	srai	a3,a3,0x6
ffffffffc0206da2:	96ae                	add	a3,a3,a1
ffffffffc0206da4:	00f6f5b3          	and	a1,a3,a5
ffffffffc0206da8:	00090617          	auipc	a2,0x90
ffffffffc0206dac:	b3063603          	ld	a2,-1232(a2) # ffffffffc02968d8 <npage>
ffffffffc0206db0:	06b2                	slli	a3,a3,0xc
ffffffffc0206db2:	14c5f363          	bgeu	a1,a2,ffffffffc0206ef8 <do_execve+0x89e>
ffffffffc0206db6:	00090617          	auipc	a2,0x90
ffffffffc0206dba:	b3a63603          	ld	a2,-1222(a2) # ffffffffc02968f0 <va_pa_offset>
ffffffffc0206dbe:	96b2                	add	a3,a3,a2
ffffffffc0206dc0:	4581                	li	a1,0
ffffffffc0206dc2:	8666                	mv	a2,s9
ffffffffc0206dc4:	9536                	add	a0,a0,a3
ffffffffc0206dc6:	566040ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc0206dca:	019d87b3          	add	a5,s11,s9
ffffffffc0206dce:	f17c72e3          	bgeu	s8,s7,ffffffffc0206cd2 <do_execve+0x678>
ffffffffc0206dd2:	c8fc0ee3          	beq	s8,a5,ffffffffc0206a6e <do_execve+0x414>
ffffffffc0206dd6:	00007697          	auipc	a3,0x7
ffffffffc0206dda:	d3268693          	addi	a3,a3,-718 # ffffffffc020db08 <CSWTCH.79+0x300>
ffffffffc0206dde:	00005617          	auipc	a2,0x5
ffffffffc0206de2:	f4260613          	addi	a2,a2,-190 # ffffffffc020bd20 <commands+0x250>
ffffffffc0206de6:	31700593          	li	a1,791
ffffffffc0206dea:	00007517          	auipc	a0,0x7
ffffffffc0206dee:	b0650513          	addi	a0,a0,-1274 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206df2:	c3cf90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206df6:	5975                	li	s2,-3
ffffffffc0206df8:	a40b16e3          	bnez	s6,ffffffffc0206844 <do_execve+0x1ea>
ffffffffc0206dfc:	bc91                	j	ffffffffc0206850 <do_execve+0x1f6>
ffffffffc0206dfe:	8d22                	mv	s10,s0
ffffffffc0206e00:	b1bd                	j	ffffffffc0206a6e <do_execve+0x414>
ffffffffc0206e02:	f40b0de3          	beqz	s6,ffffffffc0206d5c <do_execve+0x702>
ffffffffc0206e06:	038b0513          	addi	a0,s6,56
ffffffffc0206e0a:	a4bfd0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0206e0e:	5975                	li	s2,-3
ffffffffc0206e10:	040b2823          	sw	zero,80(s6)
ffffffffc0206e14:	bc35                	j	ffffffffc0206850 <do_execve+0x1f6>
ffffffffc0206e16:	8c6e                	mv	s8,s11
ffffffffc0206e18:	8ba6                	mv	s7,s1
ffffffffc0206e1a:	b7b1                	j	ffffffffc0206d66 <do_execve+0x70c>
ffffffffc0206e1c:	6b82                	ld	s7,0(sp)
ffffffffc0206e1e:	64a2                	ld	s1,8(sp)
ffffffffc0206e20:	5971                	li	s2,-4
ffffffffc0206e22:	b625                	j	ffffffffc020694a <do_execve+0x2f0>
ffffffffc0206e24:	6be2                	ld	s7,24(sp)
ffffffffc0206e26:	7482                	ld	s1,32(sp)
ffffffffc0206e28:	5db2                	lw	s11,44(sp)
ffffffffc0206e2a:	5961                	li	s2,-8
ffffffffc0206e2c:	be39                	j	ffffffffc020694a <do_execve+0x2f0>
ffffffffc0206e2e:	00005617          	auipc	a2,0x5
ffffffffc0206e32:	62a60613          	addi	a2,a2,1578 # ffffffffc020c458 <commands+0x988>
ffffffffc0206e36:	36e00593          	li	a1,878
ffffffffc0206e3a:	00007517          	auipc	a0,0x7
ffffffffc0206e3e:	ab650513          	addi	a0,a0,-1354 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206e42:	becf90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206e46:	00005617          	auipc	a2,0x5
ffffffffc0206e4a:	61260613          	addi	a2,a2,1554 # ffffffffc020c458 <commands+0x988>
ffffffffc0206e4e:	36300593          	li	a1,867
ffffffffc0206e52:	00007517          	auipc	a0,0x7
ffffffffc0206e56:	a9e50513          	addi	a0,a0,-1378 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206e5a:	bd4f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206e5e:	00007697          	auipc	a3,0x7
ffffffffc0206e62:	dc268693          	addi	a3,a3,-574 # ffffffffc020dc20 <CSWTCH.79+0x418>
ffffffffc0206e66:	00005617          	auipc	a2,0x5
ffffffffc0206e6a:	eba60613          	addi	a2,a2,-326 # ffffffffc020bd20 <commands+0x250>
ffffffffc0206e6e:	33400593          	li	a1,820
ffffffffc0206e72:	00007517          	auipc	a0,0x7
ffffffffc0206e76:	a7e50513          	addi	a0,a0,-1410 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206e7a:	bb4f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206e7e:	00007697          	auipc	a3,0x7
ffffffffc0206e82:	d5a68693          	addi	a3,a3,-678 # ffffffffc020dbd8 <CSWTCH.79+0x3d0>
ffffffffc0206e86:	00005617          	auipc	a2,0x5
ffffffffc0206e8a:	e9a60613          	addi	a2,a2,-358 # ffffffffc020bd20 <commands+0x250>
ffffffffc0206e8e:	33300593          	li	a1,819
ffffffffc0206e92:	00007517          	auipc	a0,0x7
ffffffffc0206e96:	a5e50513          	addi	a0,a0,-1442 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206e9a:	b94f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206e9e:	00007697          	auipc	a3,0x7
ffffffffc0206ea2:	cf268693          	addi	a3,a3,-782 # ffffffffc020db90 <CSWTCH.79+0x388>
ffffffffc0206ea6:	00005617          	auipc	a2,0x5
ffffffffc0206eaa:	e7a60613          	addi	a2,a2,-390 # ffffffffc020bd20 <commands+0x250>
ffffffffc0206eae:	33200593          	li	a1,818
ffffffffc0206eb2:	00007517          	auipc	a0,0x7
ffffffffc0206eb6:	a3e50513          	addi	a0,a0,-1474 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206eba:	b74f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206ebe:	00007697          	auipc	a3,0x7
ffffffffc0206ec2:	c8a68693          	addi	a3,a3,-886 # ffffffffc020db48 <CSWTCH.79+0x340>
ffffffffc0206ec6:	00005617          	auipc	a2,0x5
ffffffffc0206eca:	e5a60613          	addi	a2,a2,-422 # ffffffffc020bd20 <commands+0x250>
ffffffffc0206ece:	33100593          	li	a1,817
ffffffffc0206ed2:	00007517          	auipc	a0,0x7
ffffffffc0206ed6:	a1e50513          	addi	a0,a0,-1506 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206eda:	b54f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206ede:	00005617          	auipc	a2,0x5
ffffffffc0206ee2:	67260613          	addi	a2,a2,1650 # ffffffffc020c550 <commands+0xa80>
ffffffffc0206ee6:	33900593          	li	a1,825
ffffffffc0206eea:	00007517          	auipc	a0,0x7
ffffffffc0206eee:	a0650513          	addi	a0,a0,-1530 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206ef2:	b3cf90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206ef6:	86be                	mv	a3,a5
ffffffffc0206ef8:	00005617          	auipc	a2,0x5
ffffffffc0206efc:	56060613          	addi	a2,a2,1376 # ffffffffc020c458 <commands+0x988>
ffffffffc0206f00:	07100593          	li	a1,113
ffffffffc0206f04:	00005517          	auipc	a0,0x5
ffffffffc0206f08:	51c50513          	addi	a0,a0,1308 # ffffffffc020c420 <commands+0x950>
ffffffffc0206f0c:	b22f90ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0206f10 <user_main>:
ffffffffc0206f10:	7179                	addi	sp,sp,-48
ffffffffc0206f12:	e84a                	sd	s2,16(sp)
ffffffffc0206f14:	00090917          	auipc	s2,0x90
ffffffffc0206f18:	9f490913          	addi	s2,s2,-1548 # ffffffffc0296908 <current>
ffffffffc0206f1c:	00093783          	ld	a5,0(s2)
ffffffffc0206f20:	00007617          	auipc	a2,0x7
ffffffffc0206f24:	d4860613          	addi	a2,a2,-696 # ffffffffc020dc68 <CSWTCH.79+0x460>
ffffffffc0206f28:	00007517          	auipc	a0,0x7
ffffffffc0206f2c:	d4850513          	addi	a0,a0,-696 # ffffffffc020dc70 <CSWTCH.79+0x468>
ffffffffc0206f30:	43cc                	lw	a1,4(a5)
ffffffffc0206f32:	f406                	sd	ra,40(sp)
ffffffffc0206f34:	f022                	sd	s0,32(sp)
ffffffffc0206f36:	ec26                	sd	s1,24(sp)
ffffffffc0206f38:	e032                	sd	a2,0(sp)
ffffffffc0206f3a:	e402                	sd	zero,8(sp)
ffffffffc0206f3c:	9eef90ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0206f40:	6782                	ld	a5,0(sp)
ffffffffc0206f42:	cfb9                	beqz	a5,ffffffffc0206fa0 <user_main+0x90>
ffffffffc0206f44:	003c                	addi	a5,sp,8
ffffffffc0206f46:	4401                	li	s0,0
ffffffffc0206f48:	6398                	ld	a4,0(a5)
ffffffffc0206f4a:	0405                	addi	s0,s0,1
ffffffffc0206f4c:	07a1                	addi	a5,a5,8
ffffffffc0206f4e:	ff6d                	bnez	a4,ffffffffc0206f48 <user_main+0x38>
ffffffffc0206f50:	00093783          	ld	a5,0(s2)
ffffffffc0206f54:	12000613          	li	a2,288
ffffffffc0206f58:	6b84                	ld	s1,16(a5)
ffffffffc0206f5a:	73cc                	ld	a1,160(a5)
ffffffffc0206f5c:	6789                	lui	a5,0x2
ffffffffc0206f5e:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_bin_swap_img_size-0x5e20>
ffffffffc0206f62:	94be                	add	s1,s1,a5
ffffffffc0206f64:	8526                	mv	a0,s1
ffffffffc0206f66:	418040ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc0206f6a:	00093783          	ld	a5,0(s2)
ffffffffc0206f6e:	860a                	mv	a2,sp
ffffffffc0206f70:	0004059b          	sext.w	a1,s0
ffffffffc0206f74:	f3c4                	sd	s1,160(a5)
ffffffffc0206f76:	00007517          	auipc	a0,0x7
ffffffffc0206f7a:	cf250513          	addi	a0,a0,-782 # ffffffffc020dc68 <CSWTCH.79+0x460>
ffffffffc0206f7e:	edcff0ef          	jal	ra,ffffffffc020665a <do_execve>
ffffffffc0206f82:	8126                	mv	sp,s1
ffffffffc0206f84:	b94fa06f          	j	ffffffffc0201318 <__trapret>
ffffffffc0206f88:	00007617          	auipc	a2,0x7
ffffffffc0206f8c:	d1060613          	addi	a2,a2,-752 # ffffffffc020dc98 <CSWTCH.79+0x490>
ffffffffc0206f90:	49800593          	li	a1,1176
ffffffffc0206f94:	00007517          	auipc	a0,0x7
ffffffffc0206f98:	95c50513          	addi	a0,a0,-1700 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0206f9c:	a92f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0206fa0:	4401                	li	s0,0
ffffffffc0206fa2:	b77d                	j	ffffffffc0206f50 <user_main+0x40>

ffffffffc0206fa4 <do_yield>:
ffffffffc0206fa4:	00090797          	auipc	a5,0x90
ffffffffc0206fa8:	9647b783          	ld	a5,-1692(a5) # ffffffffc0296908 <current>
ffffffffc0206fac:	4705                	li	a4,1
ffffffffc0206fae:	ef98                	sd	a4,24(a5)
ffffffffc0206fb0:	4501                	li	a0,0
ffffffffc0206fb2:	8082                	ret

ffffffffc0206fb4 <do_wait>:
ffffffffc0206fb4:	1101                	addi	sp,sp,-32
ffffffffc0206fb6:	e822                	sd	s0,16(sp)
ffffffffc0206fb8:	e426                	sd	s1,8(sp)
ffffffffc0206fba:	ec06                	sd	ra,24(sp)
ffffffffc0206fbc:	842e                	mv	s0,a1
ffffffffc0206fbe:	84aa                	mv	s1,a0
ffffffffc0206fc0:	c999                	beqz	a1,ffffffffc0206fd6 <do_wait+0x22>
ffffffffc0206fc2:	00090797          	auipc	a5,0x90
ffffffffc0206fc6:	9467b783          	ld	a5,-1722(a5) # ffffffffc0296908 <current>
ffffffffc0206fca:	7788                	ld	a0,40(a5)
ffffffffc0206fcc:	4685                	li	a3,1
ffffffffc0206fce:	4611                	li	a2,4
ffffffffc0206fd0:	d4efc0ef          	jal	ra,ffffffffc020351e <user_mem_check>
ffffffffc0206fd4:	c909                	beqz	a0,ffffffffc0206fe6 <do_wait+0x32>
ffffffffc0206fd6:	85a2                	mv	a1,s0
ffffffffc0206fd8:	6442                	ld	s0,16(sp)
ffffffffc0206fda:	60e2                	ld	ra,24(sp)
ffffffffc0206fdc:	8526                	mv	a0,s1
ffffffffc0206fde:	64a2                	ld	s1,8(sp)
ffffffffc0206fe0:	6105                	addi	sp,sp,32
ffffffffc0206fe2:	b56ff06f          	j	ffffffffc0206338 <do_wait.part.0>
ffffffffc0206fe6:	60e2                	ld	ra,24(sp)
ffffffffc0206fe8:	6442                	ld	s0,16(sp)
ffffffffc0206fea:	64a2                	ld	s1,8(sp)
ffffffffc0206fec:	5575                	li	a0,-3
ffffffffc0206fee:	6105                	addi	sp,sp,32
ffffffffc0206ff0:	8082                	ret

ffffffffc0206ff2 <do_kill>:
ffffffffc0206ff2:	1141                	addi	sp,sp,-16
ffffffffc0206ff4:	6789                	lui	a5,0x2
ffffffffc0206ff6:	e406                	sd	ra,8(sp)
ffffffffc0206ff8:	e022                	sd	s0,0(sp)
ffffffffc0206ffa:	fff5071b          	addiw	a4,a0,-1
ffffffffc0206ffe:	17f9                	addi	a5,a5,-2
ffffffffc0207000:	02e7e963          	bltu	a5,a4,ffffffffc0207032 <do_kill+0x40>
ffffffffc0207004:	842a                	mv	s0,a0
ffffffffc0207006:	45a9                	li	a1,10
ffffffffc0207008:	2501                	sext.w	a0,a0
ffffffffc020700a:	009040ef          	jal	ra,ffffffffc020b812 <hash32>
ffffffffc020700e:	02051793          	slli	a5,a0,0x20
ffffffffc0207012:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0207016:	0008a797          	auipc	a5,0x8a
ffffffffc020701a:	7aa78793          	addi	a5,a5,1962 # ffffffffc02917c0 <hash_list>
ffffffffc020701e:	953e                	add	a0,a0,a5
ffffffffc0207020:	87aa                	mv	a5,a0
ffffffffc0207022:	a029                	j	ffffffffc020702c <do_kill+0x3a>
ffffffffc0207024:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0207028:	00870b63          	beq	a4,s0,ffffffffc020703e <do_kill+0x4c>
ffffffffc020702c:	679c                	ld	a5,8(a5)
ffffffffc020702e:	fef51be3          	bne	a0,a5,ffffffffc0207024 <do_kill+0x32>
ffffffffc0207032:	5475                	li	s0,-3
ffffffffc0207034:	60a2                	ld	ra,8(sp)
ffffffffc0207036:	8522                	mv	a0,s0
ffffffffc0207038:	6402                	ld	s0,0(sp)
ffffffffc020703a:	0141                	addi	sp,sp,16
ffffffffc020703c:	8082                	ret
ffffffffc020703e:	fd87a703          	lw	a4,-40(a5)
ffffffffc0207042:	00177693          	andi	a3,a4,1
ffffffffc0207046:	e295                	bnez	a3,ffffffffc020706a <do_kill+0x78>
ffffffffc0207048:	4bd4                	lw	a3,20(a5)
ffffffffc020704a:	00176713          	ori	a4,a4,1
ffffffffc020704e:	fce7ac23          	sw	a4,-40(a5)
ffffffffc0207052:	4401                	li	s0,0
ffffffffc0207054:	fe06d0e3          	bgez	a3,ffffffffc0207034 <do_kill+0x42>
ffffffffc0207058:	f2878513          	addi	a0,a5,-216
ffffffffc020705c:	546000ef          	jal	ra,ffffffffc02075a2 <wakeup_proc>
ffffffffc0207060:	60a2                	ld	ra,8(sp)
ffffffffc0207062:	8522                	mv	a0,s0
ffffffffc0207064:	6402                	ld	s0,0(sp)
ffffffffc0207066:	0141                	addi	sp,sp,16
ffffffffc0207068:	8082                	ret
ffffffffc020706a:	545d                	li	s0,-9
ffffffffc020706c:	b7e1                	j	ffffffffc0207034 <do_kill+0x42>

ffffffffc020706e <proc_init>:
ffffffffc020706e:	1101                	addi	sp,sp,-32
ffffffffc0207070:	e426                	sd	s1,8(sp)
ffffffffc0207072:	0008e797          	auipc	a5,0x8e
ffffffffc0207076:	74e78793          	addi	a5,a5,1870 # ffffffffc02957c0 <proc_list>
ffffffffc020707a:	ec06                	sd	ra,24(sp)
ffffffffc020707c:	e822                	sd	s0,16(sp)
ffffffffc020707e:	e04a                	sd	s2,0(sp)
ffffffffc0207080:	0008a497          	auipc	s1,0x8a
ffffffffc0207084:	74048493          	addi	s1,s1,1856 # ffffffffc02917c0 <hash_list>
ffffffffc0207088:	e79c                	sd	a5,8(a5)
ffffffffc020708a:	e39c                	sd	a5,0(a5)
ffffffffc020708c:	0008e717          	auipc	a4,0x8e
ffffffffc0207090:	73470713          	addi	a4,a4,1844 # ffffffffc02957c0 <proc_list>
ffffffffc0207094:	87a6                	mv	a5,s1
ffffffffc0207096:	e79c                	sd	a5,8(a5)
ffffffffc0207098:	e39c                	sd	a5,0(a5)
ffffffffc020709a:	07c1                	addi	a5,a5,16
ffffffffc020709c:	fef71de3          	bne	a4,a5,ffffffffc0207096 <proc_init+0x28>
ffffffffc02070a0:	ab7fe0ef          	jal	ra,ffffffffc0205b56 <alloc_proc>
ffffffffc02070a4:	00090917          	auipc	s2,0x90
ffffffffc02070a8:	86c90913          	addi	s2,s2,-1940 # ffffffffc0296910 <idleproc>
ffffffffc02070ac:	00a93023          	sd	a0,0(s2)
ffffffffc02070b0:	842a                	mv	s0,a0
ffffffffc02070b2:	12050863          	beqz	a0,ffffffffc02071e2 <proc_init+0x174>
ffffffffc02070b6:	4789                	li	a5,2
ffffffffc02070b8:	e11c                	sd	a5,0(a0)
ffffffffc02070ba:	0000a797          	auipc	a5,0xa
ffffffffc02070be:	f4678793          	addi	a5,a5,-186 # ffffffffc0211000 <bootstack>
ffffffffc02070c2:	e91c                	sd	a5,16(a0)
ffffffffc02070c4:	4785                	li	a5,1
ffffffffc02070c6:	ed1c                	sd	a5,24(a0)
ffffffffc02070c8:	82dfe0ef          	jal	ra,ffffffffc02058f4 <files_create>
ffffffffc02070cc:	14a43423          	sd	a0,328(s0)
ffffffffc02070d0:	0e050d63          	beqz	a0,ffffffffc02071ca <proc_init+0x15c>
ffffffffc02070d4:	00093403          	ld	s0,0(s2)
ffffffffc02070d8:	4641                	li	a2,16
ffffffffc02070da:	4581                	li	a1,0
ffffffffc02070dc:	14843703          	ld	a4,328(s0)
ffffffffc02070e0:	0b440413          	addi	s0,s0,180
ffffffffc02070e4:	8522                	mv	a0,s0
ffffffffc02070e6:	4b1c                	lw	a5,16(a4)
ffffffffc02070e8:	2785                	addiw	a5,a5,1
ffffffffc02070ea:	cb1c                	sw	a5,16(a4)
ffffffffc02070ec:	240040ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc02070f0:	463d                	li	a2,15
ffffffffc02070f2:	00007597          	auipc	a1,0x7
ffffffffc02070f6:	c0658593          	addi	a1,a1,-1018 # ffffffffc020dcf8 <CSWTCH.79+0x4f0>
ffffffffc02070fa:	8522                	mv	a0,s0
ffffffffc02070fc:	282040ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc0207100:	00090717          	auipc	a4,0x90
ffffffffc0207104:	82070713          	addi	a4,a4,-2016 # ffffffffc0296920 <nr_process>
ffffffffc0207108:	431c                	lw	a5,0(a4)
ffffffffc020710a:	00093683          	ld	a3,0(s2)
ffffffffc020710e:	4601                	li	a2,0
ffffffffc0207110:	2785                	addiw	a5,a5,1
ffffffffc0207112:	4581                	li	a1,0
ffffffffc0207114:	fffff517          	auipc	a0,0xfffff
ffffffffc0207118:	3f650513          	addi	a0,a0,1014 # ffffffffc020650a <init_main>
ffffffffc020711c:	c31c                	sw	a5,0(a4)
ffffffffc020711e:	0008f797          	auipc	a5,0x8f
ffffffffc0207122:	7ed7b523          	sd	a3,2026(a5) # ffffffffc0296908 <current>
ffffffffc0207126:	860ff0ef          	jal	ra,ffffffffc0206186 <kernel_thread>
ffffffffc020712a:	842a                	mv	s0,a0
ffffffffc020712c:	08a05363          	blez	a0,ffffffffc02071b2 <proc_init+0x144>
ffffffffc0207130:	6789                	lui	a5,0x2
ffffffffc0207132:	fff5071b          	addiw	a4,a0,-1
ffffffffc0207136:	17f9                	addi	a5,a5,-2
ffffffffc0207138:	2501                	sext.w	a0,a0
ffffffffc020713a:	02e7e363          	bltu	a5,a4,ffffffffc0207160 <proc_init+0xf2>
ffffffffc020713e:	45a9                	li	a1,10
ffffffffc0207140:	6d2040ef          	jal	ra,ffffffffc020b812 <hash32>
ffffffffc0207144:	02051793          	slli	a5,a0,0x20
ffffffffc0207148:	01c7d693          	srli	a3,a5,0x1c
ffffffffc020714c:	96a6                	add	a3,a3,s1
ffffffffc020714e:	87b6                	mv	a5,a3
ffffffffc0207150:	a029                	j	ffffffffc020715a <proc_init+0xec>
ffffffffc0207152:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_bin_swap_img_size-0x5dd4>
ffffffffc0207156:	04870b63          	beq	a4,s0,ffffffffc02071ac <proc_init+0x13e>
ffffffffc020715a:	679c                	ld	a5,8(a5)
ffffffffc020715c:	fef69be3          	bne	a3,a5,ffffffffc0207152 <proc_init+0xe4>
ffffffffc0207160:	4781                	li	a5,0
ffffffffc0207162:	0b478493          	addi	s1,a5,180
ffffffffc0207166:	4641                	li	a2,16
ffffffffc0207168:	4581                	li	a1,0
ffffffffc020716a:	0008f417          	auipc	s0,0x8f
ffffffffc020716e:	7ae40413          	addi	s0,s0,1966 # ffffffffc0296918 <initproc>
ffffffffc0207172:	8526                	mv	a0,s1
ffffffffc0207174:	e01c                	sd	a5,0(s0)
ffffffffc0207176:	1b6040ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc020717a:	463d                	li	a2,15
ffffffffc020717c:	00007597          	auipc	a1,0x7
ffffffffc0207180:	ba458593          	addi	a1,a1,-1116 # ffffffffc020dd20 <CSWTCH.79+0x518>
ffffffffc0207184:	8526                	mv	a0,s1
ffffffffc0207186:	1f8040ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc020718a:	00093783          	ld	a5,0(s2)
ffffffffc020718e:	c7d1                	beqz	a5,ffffffffc020721a <proc_init+0x1ac>
ffffffffc0207190:	43dc                	lw	a5,4(a5)
ffffffffc0207192:	e7c1                	bnez	a5,ffffffffc020721a <proc_init+0x1ac>
ffffffffc0207194:	601c                	ld	a5,0(s0)
ffffffffc0207196:	c3b5                	beqz	a5,ffffffffc02071fa <proc_init+0x18c>
ffffffffc0207198:	43d8                	lw	a4,4(a5)
ffffffffc020719a:	4785                	li	a5,1
ffffffffc020719c:	04f71f63          	bne	a4,a5,ffffffffc02071fa <proc_init+0x18c>
ffffffffc02071a0:	60e2                	ld	ra,24(sp)
ffffffffc02071a2:	6442                	ld	s0,16(sp)
ffffffffc02071a4:	64a2                	ld	s1,8(sp)
ffffffffc02071a6:	6902                	ld	s2,0(sp)
ffffffffc02071a8:	6105                	addi	sp,sp,32
ffffffffc02071aa:	8082                	ret
ffffffffc02071ac:	f2878793          	addi	a5,a5,-216
ffffffffc02071b0:	bf4d                	j	ffffffffc0207162 <proc_init+0xf4>
ffffffffc02071b2:	00007617          	auipc	a2,0x7
ffffffffc02071b6:	b4e60613          	addi	a2,a2,-1202 # ffffffffc020dd00 <CSWTCH.79+0x4f8>
ffffffffc02071ba:	4e400593          	li	a1,1252
ffffffffc02071be:	00006517          	auipc	a0,0x6
ffffffffc02071c2:	73250513          	addi	a0,a0,1842 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc02071c6:	868f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02071ca:	00007617          	auipc	a2,0x7
ffffffffc02071ce:	b0660613          	addi	a2,a2,-1274 # ffffffffc020dcd0 <CSWTCH.79+0x4c8>
ffffffffc02071d2:	4d800593          	li	a1,1240
ffffffffc02071d6:	00006517          	auipc	a0,0x6
ffffffffc02071da:	71a50513          	addi	a0,a0,1818 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc02071de:	850f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02071e2:	00007617          	auipc	a2,0x7
ffffffffc02071e6:	ad660613          	addi	a2,a2,-1322 # ffffffffc020dcb8 <CSWTCH.79+0x4b0>
ffffffffc02071ea:	4ce00593          	li	a1,1230
ffffffffc02071ee:	00006517          	auipc	a0,0x6
ffffffffc02071f2:	70250513          	addi	a0,a0,1794 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc02071f6:	838f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02071fa:	00007697          	auipc	a3,0x7
ffffffffc02071fe:	b5668693          	addi	a3,a3,-1194 # ffffffffc020dd50 <CSWTCH.79+0x548>
ffffffffc0207202:	00005617          	auipc	a2,0x5
ffffffffc0207206:	b1e60613          	addi	a2,a2,-1250 # ffffffffc020bd20 <commands+0x250>
ffffffffc020720a:	4eb00593          	li	a1,1259
ffffffffc020720e:	00006517          	auipc	a0,0x6
ffffffffc0207212:	6e250513          	addi	a0,a0,1762 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0207216:	818f90ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020721a:	00007697          	auipc	a3,0x7
ffffffffc020721e:	b0e68693          	addi	a3,a3,-1266 # ffffffffc020dd28 <CSWTCH.79+0x520>
ffffffffc0207222:	00005617          	auipc	a2,0x5
ffffffffc0207226:	afe60613          	addi	a2,a2,-1282 # ffffffffc020bd20 <commands+0x250>
ffffffffc020722a:	4ea00593          	li	a1,1258
ffffffffc020722e:	00006517          	auipc	a0,0x6
ffffffffc0207232:	6c250513          	addi	a0,a0,1730 # ffffffffc020d8f0 <CSWTCH.79+0xe8>
ffffffffc0207236:	ff9f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020723a <cpu_idle>:
ffffffffc020723a:	1141                	addi	sp,sp,-16
ffffffffc020723c:	e022                	sd	s0,0(sp)
ffffffffc020723e:	e406                	sd	ra,8(sp)
ffffffffc0207240:	0008f417          	auipc	s0,0x8f
ffffffffc0207244:	6c840413          	addi	s0,s0,1736 # ffffffffc0296908 <current>
ffffffffc0207248:	6018                	ld	a4,0(s0)
ffffffffc020724a:	6f1c                	ld	a5,24(a4)
ffffffffc020724c:	dffd                	beqz	a5,ffffffffc020724a <cpu_idle+0x10>
ffffffffc020724e:	406000ef          	jal	ra,ffffffffc0207654 <schedule>
ffffffffc0207252:	bfdd                	j	ffffffffc0207248 <cpu_idle+0xe>

ffffffffc0207254 <lab6_set_priority>:
ffffffffc0207254:	1141                	addi	sp,sp,-16
ffffffffc0207256:	e022                	sd	s0,0(sp)
ffffffffc0207258:	85aa                	mv	a1,a0
ffffffffc020725a:	842a                	mv	s0,a0
ffffffffc020725c:	00007517          	auipc	a0,0x7
ffffffffc0207260:	b1c50513          	addi	a0,a0,-1252 # ffffffffc020dd78 <CSWTCH.79+0x570>
ffffffffc0207264:	e406                	sd	ra,8(sp)
ffffffffc0207266:	ec5f80ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020726a:	0008f797          	auipc	a5,0x8f
ffffffffc020726e:	69e7b783          	ld	a5,1694(a5) # ffffffffc0296908 <current>
ffffffffc0207272:	e801                	bnez	s0,ffffffffc0207282 <lab6_set_priority+0x2e>
ffffffffc0207274:	60a2                	ld	ra,8(sp)
ffffffffc0207276:	6402                	ld	s0,0(sp)
ffffffffc0207278:	4705                	li	a4,1
ffffffffc020727a:	14e7a223          	sw	a4,324(a5)
ffffffffc020727e:	0141                	addi	sp,sp,16
ffffffffc0207280:	8082                	ret
ffffffffc0207282:	60a2                	ld	ra,8(sp)
ffffffffc0207284:	1487a223          	sw	s0,324(a5)
ffffffffc0207288:	6402                	ld	s0,0(sp)
ffffffffc020728a:	0141                	addi	sp,sp,16
ffffffffc020728c:	8082                	ret

ffffffffc020728e <do_sleep>:
ffffffffc020728e:	c539                	beqz	a0,ffffffffc02072dc <do_sleep+0x4e>
ffffffffc0207290:	7179                	addi	sp,sp,-48
ffffffffc0207292:	f022                	sd	s0,32(sp)
ffffffffc0207294:	f406                	sd	ra,40(sp)
ffffffffc0207296:	842a                	mv	s0,a0
ffffffffc0207298:	100027f3          	csrr	a5,sstatus
ffffffffc020729c:	8b89                	andi	a5,a5,2
ffffffffc020729e:	e3a9                	bnez	a5,ffffffffc02072e0 <do_sleep+0x52>
ffffffffc02072a0:	0008f797          	auipc	a5,0x8f
ffffffffc02072a4:	6687b783          	ld	a5,1640(a5) # ffffffffc0296908 <current>
ffffffffc02072a8:	0818                	addi	a4,sp,16
ffffffffc02072aa:	c02a                	sw	a0,0(sp)
ffffffffc02072ac:	ec3a                	sd	a4,24(sp)
ffffffffc02072ae:	e83a                	sd	a4,16(sp)
ffffffffc02072b0:	e43e                	sd	a5,8(sp)
ffffffffc02072b2:	4705                	li	a4,1
ffffffffc02072b4:	c398                	sw	a4,0(a5)
ffffffffc02072b6:	80000737          	lui	a4,0x80000
ffffffffc02072ba:	840a                	mv	s0,sp
ffffffffc02072bc:	0709                	addi	a4,a4,2
ffffffffc02072be:	0ee7a623          	sw	a4,236(a5)
ffffffffc02072c2:	8522                	mv	a0,s0
ffffffffc02072c4:	450000ef          	jal	ra,ffffffffc0207714 <add_timer>
ffffffffc02072c8:	38c000ef          	jal	ra,ffffffffc0207654 <schedule>
ffffffffc02072cc:	8522                	mv	a0,s0
ffffffffc02072ce:	50e000ef          	jal	ra,ffffffffc02077dc <del_timer>
ffffffffc02072d2:	70a2                	ld	ra,40(sp)
ffffffffc02072d4:	7402                	ld	s0,32(sp)
ffffffffc02072d6:	4501                	li	a0,0
ffffffffc02072d8:	6145                	addi	sp,sp,48
ffffffffc02072da:	8082                	ret
ffffffffc02072dc:	4501                	li	a0,0
ffffffffc02072de:	8082                	ret
ffffffffc02072e0:	ac1f90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02072e4:	0008f797          	auipc	a5,0x8f
ffffffffc02072e8:	6247b783          	ld	a5,1572(a5) # ffffffffc0296908 <current>
ffffffffc02072ec:	0818                	addi	a4,sp,16
ffffffffc02072ee:	c022                	sw	s0,0(sp)
ffffffffc02072f0:	e43e                	sd	a5,8(sp)
ffffffffc02072f2:	ec3a                	sd	a4,24(sp)
ffffffffc02072f4:	e83a                	sd	a4,16(sp)
ffffffffc02072f6:	4705                	li	a4,1
ffffffffc02072f8:	c398                	sw	a4,0(a5)
ffffffffc02072fa:	80000737          	lui	a4,0x80000
ffffffffc02072fe:	0709                	addi	a4,a4,2
ffffffffc0207300:	840a                	mv	s0,sp
ffffffffc0207302:	8522                	mv	a0,s0
ffffffffc0207304:	0ee7a623          	sw	a4,236(a5)
ffffffffc0207308:	40c000ef          	jal	ra,ffffffffc0207714 <add_timer>
ffffffffc020730c:	a8ff90ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0207310:	bf65                	j	ffffffffc02072c8 <do_sleep+0x3a>

ffffffffc0207312 <MLFQ_init>:
ffffffffc0207312:	0008e797          	auipc	a5,0x8e
ffffffffc0207316:	4ce78793          	addi	a5,a5,1230 # ffffffffc02957e0 <mlfq_queues>
ffffffffc020731a:	0008e617          	auipc	a2,0x8e
ffffffffc020731e:	4d660613          	addi	a2,a2,1238 # ffffffffc02957f0 <mlfq_queues+0x10>
ffffffffc0207322:	0008e697          	auipc	a3,0x8e
ffffffffc0207326:	4de68693          	addi	a3,a3,1246 # ffffffffc0295800 <mlfq_queues+0x20>
ffffffffc020732a:	0008e717          	auipc	a4,0x8e
ffffffffc020732e:	4a670713          	addi	a4,a4,1190 # ffffffffc02957d0 <mlfq_queue_sizes>
ffffffffc0207332:	ef90                	sd	a2,24(a5)
ffffffffc0207334:	eb90                	sd	a2,16(a5)
ffffffffc0207336:	f794                	sd	a3,40(a5)
ffffffffc0207338:	f394                	sd	a3,32(a5)
ffffffffc020733a:	e79c                	sd	a5,8(a5)
ffffffffc020733c:	e39c                	sd	a5,0(a5)
ffffffffc020733e:	00073023          	sd	zero,0(a4)
ffffffffc0207342:	00072423          	sw	zero,8(a4)
ffffffffc0207346:	00052823          	sw	zero,16(a0)
ffffffffc020734a:	0008f797          	auipc	a5,0x8f
ffffffffc020734e:	5c07ad23          	sw	zero,1498(a5) # ffffffffc0296924 <mlfq_boost_counter>
ffffffffc0207352:	8082                	ret

ffffffffc0207354 <MLFQ_enqueue>:
ffffffffc0207354:	1405a603          	lw	a2,320(a1)
ffffffffc0207358:	4789                	li	a5,2
ffffffffc020735a:	1205a683          	lw	a3,288(a1)
ffffffffc020735e:	02c7e463          	bltu	a5,a2,ffffffffc0207386 <MLFQ_enqueue+0x32>
ffffffffc0207362:	0006071b          	sext.w	a4,a2
ffffffffc0207366:	eac9                	bnez	a3,ffffffffc02073f8 <MLFQ_enqueue+0xa4>
ffffffffc0207368:	0af61763          	bne	a2,a5,ffffffffc0207416 <MLFQ_enqueue+0xc2>
ffffffffc020736c:	4ea1                	li	t4,8
ffffffffc020736e:	0008ee17          	auipc	t3,0x8e
ffffffffc0207372:	492e0e13          	addi	t3,t3,1170 # ffffffffc0295800 <mlfq_queues+0x20>
ffffffffc0207376:	4709                	li	a4,2
ffffffffc0207378:	0008e797          	auipc	a5,0x8e
ffffffffc020737c:	46878793          	addi	a5,a5,1128 # ffffffffc02957e0 <mlfq_queues>
ffffffffc0207380:	02000693          	li	a3,32
ffffffffc0207384:	a819                	j	ffffffffc020739a <MLFQ_enqueue+0x46>
ffffffffc0207386:	ceb1                	beqz	a3,ffffffffc02073e2 <MLFQ_enqueue+0x8e>
ffffffffc0207388:	0008e797          	auipc	a5,0x8e
ffffffffc020738c:	45878793          	addi	a5,a5,1112 # ffffffffc02957e0 <mlfq_queues>
ffffffffc0207390:	4e89                	li	t4,2
ffffffffc0207392:	8e3e                	mv	t3,a5
ffffffffc0207394:	4601                	li	a2,0
ffffffffc0207396:	4701                	li	a4,0
ffffffffc0207398:	4681                	li	a3,0
ffffffffc020739a:	97b6                	add	a5,a5,a3
ffffffffc020739c:	00271693          	slli	a3,a4,0x2
ffffffffc02073a0:	0008e717          	auipc	a4,0x8e
ffffffffc02073a4:	43070713          	addi	a4,a4,1072 # ffffffffc02957d0 <mlfq_queue_sizes>
ffffffffc02073a8:	0007b883          	ld	a7,0(a5)
ffffffffc02073ac:	9736                	add	a4,a4,a3
ffffffffc02073ae:	00072803          	lw	a6,0(a4)
ffffffffc02073b2:	4914                	lw	a3,16(a0)
ffffffffc02073b4:	11058313          	addi	t1,a1,272
ffffffffc02073b8:	14c5a023          	sw	a2,320(a1)
ffffffffc02073bc:	0067b023          	sd	t1,0(a5)
ffffffffc02073c0:	13d5a023          	sw	t4,288(a1)
ffffffffc02073c4:	0068b423          	sd	t1,8(a7)
ffffffffc02073c8:	11c5bc23          	sd	t3,280(a1)
ffffffffc02073cc:	1115b823          	sd	a7,272(a1)
ffffffffc02073d0:	0018061b          	addiw	a2,a6,1
ffffffffc02073d4:	10a5b423          	sd	a0,264(a1)
ffffffffc02073d8:	0016879b          	addiw	a5,a3,1
ffffffffc02073dc:	c310                	sw	a2,0(a4)
ffffffffc02073de:	c91c                	sw	a5,16(a0)
ffffffffc02073e0:	8082                	ret
ffffffffc02073e2:	4e91                	li	t4,4
ffffffffc02073e4:	4605                	li	a2,1
ffffffffc02073e6:	4e41                	li	t3,16
ffffffffc02073e8:	4705                	li	a4,1
ffffffffc02073ea:	46c1                	li	a3,16
ffffffffc02073ec:	0008e797          	auipc	a5,0x8e
ffffffffc02073f0:	3f478793          	addi	a5,a5,1012 # ffffffffc02957e0 <mlfq_queues>
ffffffffc02073f4:	9e3e                	add	t3,t3,a5
ffffffffc02073f6:	b755                	j	ffffffffc020739a <MLFQ_enqueue+0x46>
ffffffffc02073f8:	02061693          	slli	a3,a2,0x20
ffffffffc02073fc:	01c6de13          	srli	t3,a3,0x1c
ffffffffc0207400:	0008e797          	auipc	a5,0x8e
ffffffffc0207404:	3e078793          	addi	a5,a5,992 # ffffffffc02957e0 <mlfq_queues>
ffffffffc0207408:	4e89                	li	t4,2
ffffffffc020740a:	9e3e                	add	t3,t3,a5
ffffffffc020740c:	00ee9ebb          	sllw	t4,t4,a4
ffffffffc0207410:	00471693          	slli	a3,a4,0x4
ffffffffc0207414:	b759                	j	ffffffffc020739a <MLFQ_enqueue+0x46>
ffffffffc0207416:	2705                	addiw	a4,a4,1
ffffffffc0207418:	00471693          	slli	a3,a4,0x4
ffffffffc020741c:	4e89                	li	t4,2
ffffffffc020741e:	8e36                	mv	t3,a3
ffffffffc0207420:	863a                	mv	a2,a4
ffffffffc0207422:	00ee9ebb          	sllw	t4,t4,a4
ffffffffc0207426:	b7d9                	j	ffffffffc02073ec <MLFQ_enqueue+0x98>

ffffffffc0207428 <MLFQ_dequeue>:
ffffffffc0207428:	1405a783          	lw	a5,320(a1)
ffffffffc020742c:	4709                	li	a4,2
ffffffffc020742e:	02f76963          	bltu	a4,a5,ffffffffc0207460 <MLFQ_dequeue+0x38>
ffffffffc0207432:	0008e717          	auipc	a4,0x8e
ffffffffc0207436:	39e70713          	addi	a4,a4,926 # ffffffffc02957d0 <mlfq_queue_sizes>
ffffffffc020743a:	078a                	slli	a5,a5,0x2
ffffffffc020743c:	1105b803          	ld	a6,272(a1)
ffffffffc0207440:	1185b603          	ld	a2,280(a1)
ffffffffc0207444:	97ba                	add	a5,a5,a4
ffffffffc0207446:	4398                	lw	a4,0(a5)
ffffffffc0207448:	00c83423          	sd	a2,8(a6)
ffffffffc020744c:	11058693          	addi	a3,a1,272
ffffffffc0207450:	01063023          	sd	a6,0(a2)
ffffffffc0207454:	377d                	addiw	a4,a4,-1
ffffffffc0207456:	10d5bc23          	sd	a3,280(a1)
ffffffffc020745a:	10d5b823          	sd	a3,272(a1)
ffffffffc020745e:	c398                	sw	a4,0(a5)
ffffffffc0207460:	491c                	lw	a5,16(a0)
ffffffffc0207462:	37fd                	addiw	a5,a5,-1
ffffffffc0207464:	c91c                	sw	a5,16(a0)
ffffffffc0207466:	8082                	ret

ffffffffc0207468 <MLFQ_pick_next>:
ffffffffc0207468:	0008e717          	auipc	a4,0x8e
ffffffffc020746c:	37870713          	addi	a4,a4,888 # ffffffffc02957e0 <mlfq_queues>
ffffffffc0207470:	671c                	ld	a5,8(a4)
ffffffffc0207472:	02e79263          	bne	a5,a4,ffffffffc0207496 <MLFQ_pick_next+0x2e>
ffffffffc0207476:	6f9c                	ld	a5,24(a5)
ffffffffc0207478:	0008e697          	auipc	a3,0x8e
ffffffffc020747c:	37868693          	addi	a3,a3,888 # ffffffffc02957f0 <mlfq_queues+0x10>
ffffffffc0207480:	00d79b63          	bne	a5,a3,ffffffffc0207496 <MLFQ_pick_next+0x2e>
ffffffffc0207484:	771c                	ld	a5,40(a4)
ffffffffc0207486:	0008e717          	auipc	a4,0x8e
ffffffffc020748a:	37a70713          	addi	a4,a4,890 # ffffffffc0295800 <mlfq_queues+0x20>
ffffffffc020748e:	4501                	li	a0,0
ffffffffc0207490:	00e79363          	bne	a5,a4,ffffffffc0207496 <MLFQ_pick_next+0x2e>
ffffffffc0207494:	8082                	ret
ffffffffc0207496:	ef078513          	addi	a0,a5,-272
ffffffffc020749a:	8082                	ret

ffffffffc020749c <MLFQ_proc_tick>:
ffffffffc020749c:	1205a783          	lw	a5,288(a1)
ffffffffc02074a0:	00f05563          	blez	a5,ffffffffc02074aa <MLFQ_proc_tick+0xe>
ffffffffc02074a4:	37fd                	addiw	a5,a5,-1
ffffffffc02074a6:	12f5a023          	sw	a5,288(a1)
ffffffffc02074aa:	e399                	bnez	a5,ffffffffc02074b0 <MLFQ_proc_tick+0x14>
ffffffffc02074ac:	4785                	li	a5,1
ffffffffc02074ae:	ed9c                	sd	a5,24(a1)
ffffffffc02074b0:	0008f717          	auipc	a4,0x8f
ffffffffc02074b4:	47470713          	addi	a4,a4,1140 # ffffffffc0296924 <mlfq_boost_counter>
ffffffffc02074b8:	431c                	lw	a5,0(a4)
ffffffffc02074ba:	06300693          	li	a3,99
ffffffffc02074be:	0017861b          	addiw	a2,a5,1
ffffffffc02074c2:	00c6e463          	bltu	a3,a2,ffffffffc02074ca <MLFQ_proc_tick+0x2e>
ffffffffc02074c6:	c310                	sw	a2,0(a4)
ffffffffc02074c8:	8082                	ret
ffffffffc02074ca:	0008ef17          	auipc	t5,0x8e
ffffffffc02074ce:	306f0f13          	addi	t5,t5,774 # ffffffffc02957d0 <mlfq_queue_sizes>
ffffffffc02074d2:	000f2303          	lw	t1,0(t5)
ffffffffc02074d6:	0008f797          	auipc	a5,0x8f
ffffffffc02074da:	4407a723          	sw	zero,1102(a5) # ffffffffc0296924 <mlfq_boost_counter>
ffffffffc02074de:	0008e817          	auipc	a6,0x8e
ffffffffc02074e2:	31280813          	addi	a6,a6,786 # ffffffffc02957f0 <mlfq_queues+0x10>
ffffffffc02074e6:	8efa                	mv	t4,t5
ffffffffc02074e8:	0008ef97          	auipc	t6,0x8e
ffffffffc02074ec:	328f8f93          	addi	t6,t6,808 # ffffffffc0295810 <__rq>
ffffffffc02074f0:	4701                	li	a4,0
ffffffffc02074f2:	0008e617          	auipc	a2,0x8e
ffffffffc02074f6:	2ee60613          	addi	a2,a2,750 # ffffffffc02957e0 <mlfq_queues>
ffffffffc02074fa:	4e09                	li	t3,2
ffffffffc02074fc:	00883783          	ld	a5,8(a6)
ffffffffc0207500:	05078063          	beq	a5,a6,ffffffffc0207540 <MLFQ_proc_tick+0xa4>
ffffffffc0207504:	004ea883          	lw	a7,4(t4) # 2004 <_binary_bin_swap_img_size-0x5cfc>
ffffffffc0207508:	8746                	mv	a4,a7
ffffffffc020750a:	6388                	ld	a0,0(a5)
ffffffffc020750c:	678c                	ld	a1,8(a5)
ffffffffc020750e:	377d                	addiw	a4,a4,-1
ffffffffc0207510:	40e306bb          	subw	a3,t1,a4
ffffffffc0207514:	e50c                	sd	a1,8(a0)
ffffffffc0207516:	e188                	sd	a0,0(a1)
ffffffffc0207518:	e39c                	sd	a5,0(a5)
ffffffffc020751a:	620c                	ld	a1,0(a2)
ffffffffc020751c:	0207a823          	sw	zero,48(a5)
ffffffffc0207520:	01c7a823          	sw	t3,16(a5)
ffffffffc0207524:	e59c                	sd	a5,8(a1)
ffffffffc0207526:	e21c                	sd	a5,0(a2)
ffffffffc0207528:	e790                	sd	a2,8(a5)
ffffffffc020752a:	e38c                	sd	a1,0(a5)
ffffffffc020752c:	00883783          	ld	a5,8(a6)
ffffffffc0207530:	011686bb          	addw	a3,a3,a7
ffffffffc0207534:	fd079be3          	bne	a5,a6,ffffffffc020750a <MLFQ_proc_tick+0x6e>
ffffffffc0207538:	00eea223          	sw	a4,4(t4)
ffffffffc020753c:	8336                	mv	t1,a3
ffffffffc020753e:	4705                	li	a4,1
ffffffffc0207540:	0841                	addi	a6,a6,16
ffffffffc0207542:	0e91                	addi	t4,t4,4
ffffffffc0207544:	fbf81ce3          	bne	a6,t6,ffffffffc02074fc <MLFQ_proc_tick+0x60>
ffffffffc0207548:	c319                	beqz	a4,ffffffffc020754e <MLFQ_proc_tick+0xb2>
ffffffffc020754a:	006f2023          	sw	t1,0(t5)
ffffffffc020754e:	8082                	ret

ffffffffc0207550 <sched_init>:
ffffffffc0207550:	1141                	addi	sp,sp,-16
ffffffffc0207552:	0008a717          	auipc	a4,0x8a
ffffffffc0207556:	ace70713          	addi	a4,a4,-1330 # ffffffffc0291020 <MLFQ_sched_class>
ffffffffc020755a:	e022                	sd	s0,0(sp)
ffffffffc020755c:	e406                	sd	ra,8(sp)
ffffffffc020755e:	0008e797          	auipc	a5,0x8e
ffffffffc0207562:	2d278793          	addi	a5,a5,722 # ffffffffc0295830 <timer_list>
ffffffffc0207566:	6714                	ld	a3,8(a4)
ffffffffc0207568:	0008e517          	auipc	a0,0x8e
ffffffffc020756c:	2a850513          	addi	a0,a0,680 # ffffffffc0295810 <__rq>
ffffffffc0207570:	e79c                	sd	a5,8(a5)
ffffffffc0207572:	e39c                	sd	a5,0(a5)
ffffffffc0207574:	4795                	li	a5,5
ffffffffc0207576:	c95c                	sw	a5,20(a0)
ffffffffc0207578:	0008f417          	auipc	s0,0x8f
ffffffffc020757c:	3b840413          	addi	s0,s0,952 # ffffffffc0296930 <sched_class>
ffffffffc0207580:	0008f797          	auipc	a5,0x8f
ffffffffc0207584:	3aa7b423          	sd	a0,936(a5) # ffffffffc0296928 <rq>
ffffffffc0207588:	e018                	sd	a4,0(s0)
ffffffffc020758a:	9682                	jalr	a3
ffffffffc020758c:	601c                	ld	a5,0(s0)
ffffffffc020758e:	6402                	ld	s0,0(sp)
ffffffffc0207590:	60a2                	ld	ra,8(sp)
ffffffffc0207592:	638c                	ld	a1,0(a5)
ffffffffc0207594:	00007517          	auipc	a0,0x7
ffffffffc0207598:	80c50513          	addi	a0,a0,-2036 # ffffffffc020dda0 <CSWTCH.79+0x598>
ffffffffc020759c:	0141                	addi	sp,sp,16
ffffffffc020759e:	b8df806f          	j	ffffffffc020012a <cprintf>

ffffffffc02075a2 <wakeup_proc>:
ffffffffc02075a2:	4118                	lw	a4,0(a0)
ffffffffc02075a4:	1101                	addi	sp,sp,-32
ffffffffc02075a6:	ec06                	sd	ra,24(sp)
ffffffffc02075a8:	e822                	sd	s0,16(sp)
ffffffffc02075aa:	e426                	sd	s1,8(sp)
ffffffffc02075ac:	478d                	li	a5,3
ffffffffc02075ae:	08f70363          	beq	a4,a5,ffffffffc0207634 <wakeup_proc+0x92>
ffffffffc02075b2:	842a                	mv	s0,a0
ffffffffc02075b4:	100027f3          	csrr	a5,sstatus
ffffffffc02075b8:	8b89                	andi	a5,a5,2
ffffffffc02075ba:	4481                	li	s1,0
ffffffffc02075bc:	e7bd                	bnez	a5,ffffffffc020762a <wakeup_proc+0x88>
ffffffffc02075be:	4789                	li	a5,2
ffffffffc02075c0:	04f70863          	beq	a4,a5,ffffffffc0207610 <wakeup_proc+0x6e>
ffffffffc02075c4:	c01c                	sw	a5,0(s0)
ffffffffc02075c6:	0e042623          	sw	zero,236(s0)
ffffffffc02075ca:	0008f797          	auipc	a5,0x8f
ffffffffc02075ce:	33e7b783          	ld	a5,830(a5) # ffffffffc0296908 <current>
ffffffffc02075d2:	02878363          	beq	a5,s0,ffffffffc02075f8 <wakeup_proc+0x56>
ffffffffc02075d6:	0008f797          	auipc	a5,0x8f
ffffffffc02075da:	33a7b783          	ld	a5,826(a5) # ffffffffc0296910 <idleproc>
ffffffffc02075de:	00f40d63          	beq	s0,a5,ffffffffc02075f8 <wakeup_proc+0x56>
ffffffffc02075e2:	0008f797          	auipc	a5,0x8f
ffffffffc02075e6:	34e7b783          	ld	a5,846(a5) # ffffffffc0296930 <sched_class>
ffffffffc02075ea:	6b9c                	ld	a5,16(a5)
ffffffffc02075ec:	85a2                	mv	a1,s0
ffffffffc02075ee:	0008f517          	auipc	a0,0x8f
ffffffffc02075f2:	33a53503          	ld	a0,826(a0) # ffffffffc0296928 <rq>
ffffffffc02075f6:	9782                	jalr	a5
ffffffffc02075f8:	e491                	bnez	s1,ffffffffc0207604 <wakeup_proc+0x62>
ffffffffc02075fa:	60e2                	ld	ra,24(sp)
ffffffffc02075fc:	6442                	ld	s0,16(sp)
ffffffffc02075fe:	64a2                	ld	s1,8(sp)
ffffffffc0207600:	6105                	addi	sp,sp,32
ffffffffc0207602:	8082                	ret
ffffffffc0207604:	6442                	ld	s0,16(sp)
ffffffffc0207606:	60e2                	ld	ra,24(sp)
ffffffffc0207608:	64a2                	ld	s1,8(sp)
ffffffffc020760a:	6105                	addi	sp,sp,32
ffffffffc020760c:	f8ef906f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc0207610:	00006617          	auipc	a2,0x6
ffffffffc0207614:	7e060613          	addi	a2,a2,2016 # ffffffffc020ddf0 <CSWTCH.79+0x5e8>
ffffffffc0207618:	06d00593          	li	a1,109
ffffffffc020761c:	00006517          	auipc	a0,0x6
ffffffffc0207620:	7bc50513          	addi	a0,a0,1980 # ffffffffc020ddd8 <CSWTCH.79+0x5d0>
ffffffffc0207624:	c73f80ef          	jal	ra,ffffffffc0200296 <__warn>
ffffffffc0207628:	bfc1                	j	ffffffffc02075f8 <wakeup_proc+0x56>
ffffffffc020762a:	f76f90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020762e:	4018                	lw	a4,0(s0)
ffffffffc0207630:	4485                	li	s1,1
ffffffffc0207632:	b771                	j	ffffffffc02075be <wakeup_proc+0x1c>
ffffffffc0207634:	00006697          	auipc	a3,0x6
ffffffffc0207638:	78468693          	addi	a3,a3,1924 # ffffffffc020ddb8 <CSWTCH.79+0x5b0>
ffffffffc020763c:	00004617          	auipc	a2,0x4
ffffffffc0207640:	6e460613          	addi	a2,a2,1764 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207644:	05e00593          	li	a1,94
ffffffffc0207648:	00006517          	auipc	a0,0x6
ffffffffc020764c:	79050513          	addi	a0,a0,1936 # ffffffffc020ddd8 <CSWTCH.79+0x5d0>
ffffffffc0207650:	bdff80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207654 <schedule>:
ffffffffc0207654:	7179                	addi	sp,sp,-48
ffffffffc0207656:	f406                	sd	ra,40(sp)
ffffffffc0207658:	f022                	sd	s0,32(sp)
ffffffffc020765a:	ec26                	sd	s1,24(sp)
ffffffffc020765c:	e84a                	sd	s2,16(sp)
ffffffffc020765e:	e44e                	sd	s3,8(sp)
ffffffffc0207660:	e052                	sd	s4,0(sp)
ffffffffc0207662:	100027f3          	csrr	a5,sstatus
ffffffffc0207666:	8b89                	andi	a5,a5,2
ffffffffc0207668:	4a01                	li	s4,0
ffffffffc020766a:	e3cd                	bnez	a5,ffffffffc020770c <schedule+0xb8>
ffffffffc020766c:	0008f497          	auipc	s1,0x8f
ffffffffc0207670:	29c48493          	addi	s1,s1,668 # ffffffffc0296908 <current>
ffffffffc0207674:	608c                	ld	a1,0(s1)
ffffffffc0207676:	0008f997          	auipc	s3,0x8f
ffffffffc020767a:	2ba98993          	addi	s3,s3,698 # ffffffffc0296930 <sched_class>
ffffffffc020767e:	0008f917          	auipc	s2,0x8f
ffffffffc0207682:	2aa90913          	addi	s2,s2,682 # ffffffffc0296928 <rq>
ffffffffc0207686:	4194                	lw	a3,0(a1)
ffffffffc0207688:	0005bc23          	sd	zero,24(a1)
ffffffffc020768c:	4709                	li	a4,2
ffffffffc020768e:	0009b783          	ld	a5,0(s3)
ffffffffc0207692:	00093503          	ld	a0,0(s2)
ffffffffc0207696:	04e68e63          	beq	a3,a4,ffffffffc02076f2 <schedule+0x9e>
ffffffffc020769a:	739c                	ld	a5,32(a5)
ffffffffc020769c:	9782                	jalr	a5
ffffffffc020769e:	842a                	mv	s0,a0
ffffffffc02076a0:	c521                	beqz	a0,ffffffffc02076e8 <schedule+0x94>
ffffffffc02076a2:	0009b783          	ld	a5,0(s3)
ffffffffc02076a6:	00093503          	ld	a0,0(s2)
ffffffffc02076aa:	85a2                	mv	a1,s0
ffffffffc02076ac:	6f9c                	ld	a5,24(a5)
ffffffffc02076ae:	9782                	jalr	a5
ffffffffc02076b0:	441c                	lw	a5,8(s0)
ffffffffc02076b2:	6098                	ld	a4,0(s1)
ffffffffc02076b4:	2785                	addiw	a5,a5,1
ffffffffc02076b6:	c41c                	sw	a5,8(s0)
ffffffffc02076b8:	00870563          	beq	a4,s0,ffffffffc02076c2 <schedule+0x6e>
ffffffffc02076bc:	8522                	mv	a0,s0
ffffffffc02076be:	e38fe0ef          	jal	ra,ffffffffc0205cf6 <proc_run>
ffffffffc02076c2:	000a1a63          	bnez	s4,ffffffffc02076d6 <schedule+0x82>
ffffffffc02076c6:	70a2                	ld	ra,40(sp)
ffffffffc02076c8:	7402                	ld	s0,32(sp)
ffffffffc02076ca:	64e2                	ld	s1,24(sp)
ffffffffc02076cc:	6942                	ld	s2,16(sp)
ffffffffc02076ce:	69a2                	ld	s3,8(sp)
ffffffffc02076d0:	6a02                	ld	s4,0(sp)
ffffffffc02076d2:	6145                	addi	sp,sp,48
ffffffffc02076d4:	8082                	ret
ffffffffc02076d6:	7402                	ld	s0,32(sp)
ffffffffc02076d8:	70a2                	ld	ra,40(sp)
ffffffffc02076da:	64e2                	ld	s1,24(sp)
ffffffffc02076dc:	6942                	ld	s2,16(sp)
ffffffffc02076de:	69a2                	ld	s3,8(sp)
ffffffffc02076e0:	6a02                	ld	s4,0(sp)
ffffffffc02076e2:	6145                	addi	sp,sp,48
ffffffffc02076e4:	eb6f906f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc02076e8:	0008f417          	auipc	s0,0x8f
ffffffffc02076ec:	22843403          	ld	s0,552(s0) # ffffffffc0296910 <idleproc>
ffffffffc02076f0:	b7c1                	j	ffffffffc02076b0 <schedule+0x5c>
ffffffffc02076f2:	0008f717          	auipc	a4,0x8f
ffffffffc02076f6:	21e73703          	ld	a4,542(a4) # ffffffffc0296910 <idleproc>
ffffffffc02076fa:	fae580e3          	beq	a1,a4,ffffffffc020769a <schedule+0x46>
ffffffffc02076fe:	6b9c                	ld	a5,16(a5)
ffffffffc0207700:	9782                	jalr	a5
ffffffffc0207702:	0009b783          	ld	a5,0(s3)
ffffffffc0207706:	00093503          	ld	a0,0(s2)
ffffffffc020770a:	bf41                	j	ffffffffc020769a <schedule+0x46>
ffffffffc020770c:	e94f90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0207710:	4a05                	li	s4,1
ffffffffc0207712:	bfa9                	j	ffffffffc020766c <schedule+0x18>

ffffffffc0207714 <add_timer>:
ffffffffc0207714:	1141                	addi	sp,sp,-16
ffffffffc0207716:	e022                	sd	s0,0(sp)
ffffffffc0207718:	e406                	sd	ra,8(sp)
ffffffffc020771a:	842a                	mv	s0,a0
ffffffffc020771c:	100027f3          	csrr	a5,sstatus
ffffffffc0207720:	8b89                	andi	a5,a5,2
ffffffffc0207722:	4501                	li	a0,0
ffffffffc0207724:	eba5                	bnez	a5,ffffffffc0207794 <add_timer+0x80>
ffffffffc0207726:	401c                	lw	a5,0(s0)
ffffffffc0207728:	cbb5                	beqz	a5,ffffffffc020779c <add_timer+0x88>
ffffffffc020772a:	6418                	ld	a4,8(s0)
ffffffffc020772c:	cb25                	beqz	a4,ffffffffc020779c <add_timer+0x88>
ffffffffc020772e:	6c18                	ld	a4,24(s0)
ffffffffc0207730:	01040593          	addi	a1,s0,16
ffffffffc0207734:	08e59463          	bne	a1,a4,ffffffffc02077bc <add_timer+0xa8>
ffffffffc0207738:	0008e617          	auipc	a2,0x8e
ffffffffc020773c:	0f860613          	addi	a2,a2,248 # ffffffffc0295830 <timer_list>
ffffffffc0207740:	6618                	ld	a4,8(a2)
ffffffffc0207742:	00c71863          	bne	a4,a2,ffffffffc0207752 <add_timer+0x3e>
ffffffffc0207746:	a80d                	j	ffffffffc0207778 <add_timer+0x64>
ffffffffc0207748:	6718                	ld	a4,8(a4)
ffffffffc020774a:	9f95                	subw	a5,a5,a3
ffffffffc020774c:	c01c                	sw	a5,0(s0)
ffffffffc020774e:	02c70563          	beq	a4,a2,ffffffffc0207778 <add_timer+0x64>
ffffffffc0207752:	ff072683          	lw	a3,-16(a4)
ffffffffc0207756:	fed7f9e3          	bgeu	a5,a3,ffffffffc0207748 <add_timer+0x34>
ffffffffc020775a:	40f687bb          	subw	a5,a3,a5
ffffffffc020775e:	fef72823          	sw	a5,-16(a4)
ffffffffc0207762:	631c                	ld	a5,0(a4)
ffffffffc0207764:	e30c                	sd	a1,0(a4)
ffffffffc0207766:	e78c                	sd	a1,8(a5)
ffffffffc0207768:	ec18                	sd	a4,24(s0)
ffffffffc020776a:	e81c                	sd	a5,16(s0)
ffffffffc020776c:	c105                	beqz	a0,ffffffffc020778c <add_timer+0x78>
ffffffffc020776e:	6402                	ld	s0,0(sp)
ffffffffc0207770:	60a2                	ld	ra,8(sp)
ffffffffc0207772:	0141                	addi	sp,sp,16
ffffffffc0207774:	e26f906f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc0207778:	0008e717          	auipc	a4,0x8e
ffffffffc020777c:	0b870713          	addi	a4,a4,184 # ffffffffc0295830 <timer_list>
ffffffffc0207780:	631c                	ld	a5,0(a4)
ffffffffc0207782:	e30c                	sd	a1,0(a4)
ffffffffc0207784:	e78c                	sd	a1,8(a5)
ffffffffc0207786:	ec18                	sd	a4,24(s0)
ffffffffc0207788:	e81c                	sd	a5,16(s0)
ffffffffc020778a:	f175                	bnez	a0,ffffffffc020776e <add_timer+0x5a>
ffffffffc020778c:	60a2                	ld	ra,8(sp)
ffffffffc020778e:	6402                	ld	s0,0(sp)
ffffffffc0207790:	0141                	addi	sp,sp,16
ffffffffc0207792:	8082                	ret
ffffffffc0207794:	e0cf90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0207798:	4505                	li	a0,1
ffffffffc020779a:	b771                	j	ffffffffc0207726 <add_timer+0x12>
ffffffffc020779c:	00006697          	auipc	a3,0x6
ffffffffc02077a0:	67468693          	addi	a3,a3,1652 # ffffffffc020de10 <CSWTCH.79+0x608>
ffffffffc02077a4:	00004617          	auipc	a2,0x4
ffffffffc02077a8:	57c60613          	addi	a2,a2,1404 # ffffffffc020bd20 <commands+0x250>
ffffffffc02077ac:	09500593          	li	a1,149
ffffffffc02077b0:	00006517          	auipc	a0,0x6
ffffffffc02077b4:	62850513          	addi	a0,a0,1576 # ffffffffc020ddd8 <CSWTCH.79+0x5d0>
ffffffffc02077b8:	a77f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02077bc:	00006697          	auipc	a3,0x6
ffffffffc02077c0:	68468693          	addi	a3,a3,1668 # ffffffffc020de40 <CSWTCH.79+0x638>
ffffffffc02077c4:	00004617          	auipc	a2,0x4
ffffffffc02077c8:	55c60613          	addi	a2,a2,1372 # ffffffffc020bd20 <commands+0x250>
ffffffffc02077cc:	09600593          	li	a1,150
ffffffffc02077d0:	00006517          	auipc	a0,0x6
ffffffffc02077d4:	60850513          	addi	a0,a0,1544 # ffffffffc020ddd8 <CSWTCH.79+0x5d0>
ffffffffc02077d8:	a57f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02077dc <del_timer>:
ffffffffc02077dc:	1101                	addi	sp,sp,-32
ffffffffc02077de:	e822                	sd	s0,16(sp)
ffffffffc02077e0:	ec06                	sd	ra,24(sp)
ffffffffc02077e2:	e426                	sd	s1,8(sp)
ffffffffc02077e4:	842a                	mv	s0,a0
ffffffffc02077e6:	100027f3          	csrr	a5,sstatus
ffffffffc02077ea:	8b89                	andi	a5,a5,2
ffffffffc02077ec:	01050493          	addi	s1,a0,16
ffffffffc02077f0:	eb9d                	bnez	a5,ffffffffc0207826 <del_timer+0x4a>
ffffffffc02077f2:	6d1c                	ld	a5,24(a0)
ffffffffc02077f4:	02978463          	beq	a5,s1,ffffffffc020781c <del_timer+0x40>
ffffffffc02077f8:	4114                	lw	a3,0(a0)
ffffffffc02077fa:	6918                	ld	a4,16(a0)
ffffffffc02077fc:	ce81                	beqz	a3,ffffffffc0207814 <del_timer+0x38>
ffffffffc02077fe:	0008e617          	auipc	a2,0x8e
ffffffffc0207802:	03260613          	addi	a2,a2,50 # ffffffffc0295830 <timer_list>
ffffffffc0207806:	00c78763          	beq	a5,a2,ffffffffc0207814 <del_timer+0x38>
ffffffffc020780a:	ff07a603          	lw	a2,-16(a5)
ffffffffc020780e:	9eb1                	addw	a3,a3,a2
ffffffffc0207810:	fed7a823          	sw	a3,-16(a5)
ffffffffc0207814:	e71c                	sd	a5,8(a4)
ffffffffc0207816:	e398                	sd	a4,0(a5)
ffffffffc0207818:	ec04                	sd	s1,24(s0)
ffffffffc020781a:	e804                	sd	s1,16(s0)
ffffffffc020781c:	60e2                	ld	ra,24(sp)
ffffffffc020781e:	6442                	ld	s0,16(sp)
ffffffffc0207820:	64a2                	ld	s1,8(sp)
ffffffffc0207822:	6105                	addi	sp,sp,32
ffffffffc0207824:	8082                	ret
ffffffffc0207826:	d7af90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc020782a:	6c1c                	ld	a5,24(s0)
ffffffffc020782c:	02978463          	beq	a5,s1,ffffffffc0207854 <del_timer+0x78>
ffffffffc0207830:	4014                	lw	a3,0(s0)
ffffffffc0207832:	6818                	ld	a4,16(s0)
ffffffffc0207834:	ce81                	beqz	a3,ffffffffc020784c <del_timer+0x70>
ffffffffc0207836:	0008e617          	auipc	a2,0x8e
ffffffffc020783a:	ffa60613          	addi	a2,a2,-6 # ffffffffc0295830 <timer_list>
ffffffffc020783e:	00c78763          	beq	a5,a2,ffffffffc020784c <del_timer+0x70>
ffffffffc0207842:	ff07a603          	lw	a2,-16(a5)
ffffffffc0207846:	9eb1                	addw	a3,a3,a2
ffffffffc0207848:	fed7a823          	sw	a3,-16(a5)
ffffffffc020784c:	e71c                	sd	a5,8(a4)
ffffffffc020784e:	e398                	sd	a4,0(a5)
ffffffffc0207850:	ec04                	sd	s1,24(s0)
ffffffffc0207852:	e804                	sd	s1,16(s0)
ffffffffc0207854:	6442                	ld	s0,16(sp)
ffffffffc0207856:	60e2                	ld	ra,24(sp)
ffffffffc0207858:	64a2                	ld	s1,8(sp)
ffffffffc020785a:	6105                	addi	sp,sp,32
ffffffffc020785c:	d3ef906f          	j	ffffffffc0200d9a <intr_enable>

ffffffffc0207860 <run_timer_list>:
ffffffffc0207860:	7139                	addi	sp,sp,-64
ffffffffc0207862:	fc06                	sd	ra,56(sp)
ffffffffc0207864:	f822                	sd	s0,48(sp)
ffffffffc0207866:	f426                	sd	s1,40(sp)
ffffffffc0207868:	f04a                	sd	s2,32(sp)
ffffffffc020786a:	ec4e                	sd	s3,24(sp)
ffffffffc020786c:	e852                	sd	s4,16(sp)
ffffffffc020786e:	e456                	sd	s5,8(sp)
ffffffffc0207870:	e05a                	sd	s6,0(sp)
ffffffffc0207872:	100027f3          	csrr	a5,sstatus
ffffffffc0207876:	8b89                	andi	a5,a5,2
ffffffffc0207878:	4b01                	li	s6,0
ffffffffc020787a:	efe9                	bnez	a5,ffffffffc0207954 <run_timer_list+0xf4>
ffffffffc020787c:	0008e997          	auipc	s3,0x8e
ffffffffc0207880:	fb498993          	addi	s3,s3,-76 # ffffffffc0295830 <timer_list>
ffffffffc0207884:	0089b403          	ld	s0,8(s3)
ffffffffc0207888:	07340a63          	beq	s0,s3,ffffffffc02078fc <run_timer_list+0x9c>
ffffffffc020788c:	ff042783          	lw	a5,-16(s0)
ffffffffc0207890:	ff040913          	addi	s2,s0,-16
ffffffffc0207894:	0e078763          	beqz	a5,ffffffffc0207982 <run_timer_list+0x122>
ffffffffc0207898:	fff7871b          	addiw	a4,a5,-1
ffffffffc020789c:	fee42823          	sw	a4,-16(s0)
ffffffffc02078a0:	ef31                	bnez	a4,ffffffffc02078fc <run_timer_list+0x9c>
ffffffffc02078a2:	00006a97          	auipc	s5,0x6
ffffffffc02078a6:	606a8a93          	addi	s5,s5,1542 # ffffffffc020dea8 <CSWTCH.79+0x6a0>
ffffffffc02078aa:	00006a17          	auipc	s4,0x6
ffffffffc02078ae:	52ea0a13          	addi	s4,s4,1326 # ffffffffc020ddd8 <CSWTCH.79+0x5d0>
ffffffffc02078b2:	a005                	j	ffffffffc02078d2 <run_timer_list+0x72>
ffffffffc02078b4:	0a07d763          	bgez	a5,ffffffffc0207962 <run_timer_list+0x102>
ffffffffc02078b8:	8526                	mv	a0,s1
ffffffffc02078ba:	ce9ff0ef          	jal	ra,ffffffffc02075a2 <wakeup_proc>
ffffffffc02078be:	854a                	mv	a0,s2
ffffffffc02078c0:	f1dff0ef          	jal	ra,ffffffffc02077dc <del_timer>
ffffffffc02078c4:	03340c63          	beq	s0,s3,ffffffffc02078fc <run_timer_list+0x9c>
ffffffffc02078c8:	ff042783          	lw	a5,-16(s0)
ffffffffc02078cc:	ff040913          	addi	s2,s0,-16
ffffffffc02078d0:	e795                	bnez	a5,ffffffffc02078fc <run_timer_list+0x9c>
ffffffffc02078d2:	00893483          	ld	s1,8(s2)
ffffffffc02078d6:	6400                	ld	s0,8(s0)
ffffffffc02078d8:	0ec4a783          	lw	a5,236(s1)
ffffffffc02078dc:	ffe1                	bnez	a5,ffffffffc02078b4 <run_timer_list+0x54>
ffffffffc02078de:	40d4                	lw	a3,4(s1)
ffffffffc02078e0:	8656                	mv	a2,s5
ffffffffc02078e2:	0d500593          	li	a1,213
ffffffffc02078e6:	8552                	mv	a0,s4
ffffffffc02078e8:	9aff80ef          	jal	ra,ffffffffc0200296 <__warn>
ffffffffc02078ec:	8526                	mv	a0,s1
ffffffffc02078ee:	cb5ff0ef          	jal	ra,ffffffffc02075a2 <wakeup_proc>
ffffffffc02078f2:	854a                	mv	a0,s2
ffffffffc02078f4:	ee9ff0ef          	jal	ra,ffffffffc02077dc <del_timer>
ffffffffc02078f8:	fd3418e3          	bne	s0,s3,ffffffffc02078c8 <run_timer_list+0x68>
ffffffffc02078fc:	0008f597          	auipc	a1,0x8f
ffffffffc0207900:	00c5b583          	ld	a1,12(a1) # ffffffffc0296908 <current>
ffffffffc0207904:	c18d                	beqz	a1,ffffffffc0207926 <run_timer_list+0xc6>
ffffffffc0207906:	0008f797          	auipc	a5,0x8f
ffffffffc020790a:	00a7b783          	ld	a5,10(a5) # ffffffffc0296910 <idleproc>
ffffffffc020790e:	04f58763          	beq	a1,a5,ffffffffc020795c <run_timer_list+0xfc>
ffffffffc0207912:	0008f797          	auipc	a5,0x8f
ffffffffc0207916:	01e7b783          	ld	a5,30(a5) # ffffffffc0296930 <sched_class>
ffffffffc020791a:	779c                	ld	a5,40(a5)
ffffffffc020791c:	0008f517          	auipc	a0,0x8f
ffffffffc0207920:	00c53503          	ld	a0,12(a0) # ffffffffc0296928 <rq>
ffffffffc0207924:	9782                	jalr	a5
ffffffffc0207926:	000b1c63          	bnez	s6,ffffffffc020793e <run_timer_list+0xde>
ffffffffc020792a:	70e2                	ld	ra,56(sp)
ffffffffc020792c:	7442                	ld	s0,48(sp)
ffffffffc020792e:	74a2                	ld	s1,40(sp)
ffffffffc0207930:	7902                	ld	s2,32(sp)
ffffffffc0207932:	69e2                	ld	s3,24(sp)
ffffffffc0207934:	6a42                	ld	s4,16(sp)
ffffffffc0207936:	6aa2                	ld	s5,8(sp)
ffffffffc0207938:	6b02                	ld	s6,0(sp)
ffffffffc020793a:	6121                	addi	sp,sp,64
ffffffffc020793c:	8082                	ret
ffffffffc020793e:	7442                	ld	s0,48(sp)
ffffffffc0207940:	70e2                	ld	ra,56(sp)
ffffffffc0207942:	74a2                	ld	s1,40(sp)
ffffffffc0207944:	7902                	ld	s2,32(sp)
ffffffffc0207946:	69e2                	ld	s3,24(sp)
ffffffffc0207948:	6a42                	ld	s4,16(sp)
ffffffffc020794a:	6aa2                	ld	s5,8(sp)
ffffffffc020794c:	6b02                	ld	s6,0(sp)
ffffffffc020794e:	6121                	addi	sp,sp,64
ffffffffc0207950:	c4af906f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc0207954:	c4cf90ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0207958:	4b05                	li	s6,1
ffffffffc020795a:	b70d                	j	ffffffffc020787c <run_timer_list+0x1c>
ffffffffc020795c:	4785                	li	a5,1
ffffffffc020795e:	ed9c                	sd	a5,24(a1)
ffffffffc0207960:	b7d9                	j	ffffffffc0207926 <run_timer_list+0xc6>
ffffffffc0207962:	00006697          	auipc	a3,0x6
ffffffffc0207966:	51e68693          	addi	a3,a3,1310 # ffffffffc020de80 <CSWTCH.79+0x678>
ffffffffc020796a:	00004617          	auipc	a2,0x4
ffffffffc020796e:	3b660613          	addi	a2,a2,950 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207972:	0d100593          	li	a1,209
ffffffffc0207976:	00006517          	auipc	a0,0x6
ffffffffc020797a:	46250513          	addi	a0,a0,1122 # ffffffffc020ddd8 <CSWTCH.79+0x5d0>
ffffffffc020797e:	8b1f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0207982:	00006697          	auipc	a3,0x6
ffffffffc0207986:	4e668693          	addi	a3,a3,1254 # ffffffffc020de68 <CSWTCH.79+0x660>
ffffffffc020798a:	00004617          	auipc	a2,0x4
ffffffffc020798e:	39660613          	addi	a2,a2,918 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207992:	0c900593          	li	a1,201
ffffffffc0207996:	00006517          	auipc	a0,0x6
ffffffffc020799a:	44250513          	addi	a0,a0,1090 # ffffffffc020ddd8 <CSWTCH.79+0x5d0>
ffffffffc020799e:	891f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02079a2 <sys_getpid>:
ffffffffc02079a2:	0008f797          	auipc	a5,0x8f
ffffffffc02079a6:	f667b783          	ld	a5,-154(a5) # ffffffffc0296908 <current>
ffffffffc02079aa:	43c8                	lw	a0,4(a5)
ffffffffc02079ac:	8082                	ret

ffffffffc02079ae <sys_pgdir>:
ffffffffc02079ae:	4501                	li	a0,0
ffffffffc02079b0:	8082                	ret

ffffffffc02079b2 <sys_gettime>:
ffffffffc02079b2:	0008f797          	auipc	a5,0x8f
ffffffffc02079b6:	f0e7b783          	ld	a5,-242(a5) # ffffffffc02968c0 <ticks>
ffffffffc02079ba:	0027951b          	slliw	a0,a5,0x2
ffffffffc02079be:	9d3d                	addw	a0,a0,a5
ffffffffc02079c0:	0015151b          	slliw	a0,a0,0x1
ffffffffc02079c4:	8082                	ret

ffffffffc02079c6 <sys_lab6_set_priority>:
ffffffffc02079c6:	4108                	lw	a0,0(a0)
ffffffffc02079c8:	1141                	addi	sp,sp,-16
ffffffffc02079ca:	e406                	sd	ra,8(sp)
ffffffffc02079cc:	889ff0ef          	jal	ra,ffffffffc0207254 <lab6_set_priority>
ffffffffc02079d0:	60a2                	ld	ra,8(sp)
ffffffffc02079d2:	4501                	li	a0,0
ffffffffc02079d4:	0141                	addi	sp,sp,16
ffffffffc02079d6:	8082                	ret

ffffffffc02079d8 <sys_dup>:
ffffffffc02079d8:	450c                	lw	a1,8(a0)
ffffffffc02079da:	4108                	lw	a0,0(a0)
ffffffffc02079dc:	bfefd06f          	j	ffffffffc0204dda <sysfile_dup>

ffffffffc02079e0 <sys_getdirentry>:
ffffffffc02079e0:	650c                	ld	a1,8(a0)
ffffffffc02079e2:	4108                	lw	a0,0(a0)
ffffffffc02079e4:	b06fd06f          	j	ffffffffc0204cea <sysfile_getdirentry>

ffffffffc02079e8 <sys_getcwd>:
ffffffffc02079e8:	650c                	ld	a1,8(a0)
ffffffffc02079ea:	6108                	ld	a0,0(a0)
ffffffffc02079ec:	a5afd06f          	j	ffffffffc0204c46 <sysfile_getcwd>

ffffffffc02079f0 <sys_fsync>:
ffffffffc02079f0:	4108                	lw	a0,0(a0)
ffffffffc02079f2:	a50fd06f          	j	ffffffffc0204c42 <sysfile_fsync>

ffffffffc02079f6 <sys_fstat>:
ffffffffc02079f6:	650c                	ld	a1,8(a0)
ffffffffc02079f8:	4108                	lw	a0,0(a0)
ffffffffc02079fa:	9a8fd06f          	j	ffffffffc0204ba2 <sysfile_fstat>

ffffffffc02079fe <sys_seek>:
ffffffffc02079fe:	4910                	lw	a2,16(a0)
ffffffffc0207a00:	650c                	ld	a1,8(a0)
ffffffffc0207a02:	4108                	lw	a0,0(a0)
ffffffffc0207a04:	99afd06f          	j	ffffffffc0204b9e <sysfile_seek>

ffffffffc0207a08 <sys_write>:
ffffffffc0207a08:	6910                	ld	a2,16(a0)
ffffffffc0207a0a:	650c                	ld	a1,8(a0)
ffffffffc0207a0c:	4108                	lw	a0,0(a0)
ffffffffc0207a0e:	876fd06f          	j	ffffffffc0204a84 <sysfile_write>

ffffffffc0207a12 <sys_read>:
ffffffffc0207a12:	6910                	ld	a2,16(a0)
ffffffffc0207a14:	650c                	ld	a1,8(a0)
ffffffffc0207a16:	4108                	lw	a0,0(a0)
ffffffffc0207a18:	f59fc06f          	j	ffffffffc0204970 <sysfile_read>

ffffffffc0207a1c <sys_close>:
ffffffffc0207a1c:	4108                	lw	a0,0(a0)
ffffffffc0207a1e:	f4ffc06f          	j	ffffffffc020496c <sysfile_close>

ffffffffc0207a22 <sys_open>:
ffffffffc0207a22:	450c                	lw	a1,8(a0)
ffffffffc0207a24:	6108                	ld	a0,0(a0)
ffffffffc0207a26:	f13fc06f          	j	ffffffffc0204938 <sysfile_open>

ffffffffc0207a2a <sys_putc>:
ffffffffc0207a2a:	4108                	lw	a0,0(a0)
ffffffffc0207a2c:	1141                	addi	sp,sp,-16
ffffffffc0207a2e:	e406                	sd	ra,8(sp)
ffffffffc0207a30:	f36f80ef          	jal	ra,ffffffffc0200166 <cputchar>
ffffffffc0207a34:	60a2                	ld	ra,8(sp)
ffffffffc0207a36:	4501                	li	a0,0
ffffffffc0207a38:	0141                	addi	sp,sp,16
ffffffffc0207a3a:	8082                	ret

ffffffffc0207a3c <sys_kill>:
ffffffffc0207a3c:	4108                	lw	a0,0(a0)
ffffffffc0207a3e:	db4ff06f          	j	ffffffffc0206ff2 <do_kill>

ffffffffc0207a42 <sys_sleep>:
ffffffffc0207a42:	4108                	lw	a0,0(a0)
ffffffffc0207a44:	84bff06f          	j	ffffffffc020728e <do_sleep>

ffffffffc0207a48 <sys_yield>:
ffffffffc0207a48:	d5cff06f          	j	ffffffffc0206fa4 <do_yield>

ffffffffc0207a4c <sys_exec>:
ffffffffc0207a4c:	6910                	ld	a2,16(a0)
ffffffffc0207a4e:	450c                	lw	a1,8(a0)
ffffffffc0207a50:	6108                	ld	a0,0(a0)
ffffffffc0207a52:	c09fe06f          	j	ffffffffc020665a <do_execve>

ffffffffc0207a56 <sys_wait>:
ffffffffc0207a56:	650c                	ld	a1,8(a0)
ffffffffc0207a58:	4108                	lw	a0,0(a0)
ffffffffc0207a5a:	d5aff06f          	j	ffffffffc0206fb4 <do_wait>

ffffffffc0207a5e <sys_fork>:
ffffffffc0207a5e:	0008f797          	auipc	a5,0x8f
ffffffffc0207a62:	eaa7b783          	ld	a5,-342(a5) # ffffffffc0296908 <current>
ffffffffc0207a66:	73d0                	ld	a2,160(a5)
ffffffffc0207a68:	4501                	li	a0,0
ffffffffc0207a6a:	6a0c                	ld	a1,16(a2)
ffffffffc0207a6c:	af8fe06f          	j	ffffffffc0205d64 <do_fork>

ffffffffc0207a70 <sys_exit>:
ffffffffc0207a70:	4108                	lw	a0,0(a0)
ffffffffc0207a72:	f64fe06f          	j	ffffffffc02061d6 <do_exit>

ffffffffc0207a76 <syscall>:
ffffffffc0207a76:	715d                	addi	sp,sp,-80
ffffffffc0207a78:	fc26                	sd	s1,56(sp)
ffffffffc0207a7a:	0008f497          	auipc	s1,0x8f
ffffffffc0207a7e:	e8e48493          	addi	s1,s1,-370 # ffffffffc0296908 <current>
ffffffffc0207a82:	6098                	ld	a4,0(s1)
ffffffffc0207a84:	e0a2                	sd	s0,64(sp)
ffffffffc0207a86:	f84a                	sd	s2,48(sp)
ffffffffc0207a88:	7340                	ld	s0,160(a4)
ffffffffc0207a8a:	e486                	sd	ra,72(sp)
ffffffffc0207a8c:	0ff00793          	li	a5,255
ffffffffc0207a90:	05042903          	lw	s2,80(s0)
ffffffffc0207a94:	0327ee63          	bltu	a5,s2,ffffffffc0207ad0 <syscall+0x5a>
ffffffffc0207a98:	00391713          	slli	a4,s2,0x3
ffffffffc0207a9c:	00006797          	auipc	a5,0x6
ffffffffc0207aa0:	47478793          	addi	a5,a5,1140 # ffffffffc020df10 <syscalls>
ffffffffc0207aa4:	97ba                	add	a5,a5,a4
ffffffffc0207aa6:	639c                	ld	a5,0(a5)
ffffffffc0207aa8:	c785                	beqz	a5,ffffffffc0207ad0 <syscall+0x5a>
ffffffffc0207aaa:	6c28                	ld	a0,88(s0)
ffffffffc0207aac:	702c                	ld	a1,96(s0)
ffffffffc0207aae:	7430                	ld	a2,104(s0)
ffffffffc0207ab0:	7834                	ld	a3,112(s0)
ffffffffc0207ab2:	7c38                	ld	a4,120(s0)
ffffffffc0207ab4:	e42a                	sd	a0,8(sp)
ffffffffc0207ab6:	e82e                	sd	a1,16(sp)
ffffffffc0207ab8:	ec32                	sd	a2,24(sp)
ffffffffc0207aba:	f036                	sd	a3,32(sp)
ffffffffc0207abc:	f43a                	sd	a4,40(sp)
ffffffffc0207abe:	0028                	addi	a0,sp,8
ffffffffc0207ac0:	9782                	jalr	a5
ffffffffc0207ac2:	60a6                	ld	ra,72(sp)
ffffffffc0207ac4:	e828                	sd	a0,80(s0)
ffffffffc0207ac6:	6406                	ld	s0,64(sp)
ffffffffc0207ac8:	74e2                	ld	s1,56(sp)
ffffffffc0207aca:	7942                	ld	s2,48(sp)
ffffffffc0207acc:	6161                	addi	sp,sp,80
ffffffffc0207ace:	8082                	ret
ffffffffc0207ad0:	8522                	mv	a0,s0
ffffffffc0207ad2:	cbcf90ef          	jal	ra,ffffffffc0200f8e <print_trapframe>
ffffffffc0207ad6:	609c                	ld	a5,0(s1)
ffffffffc0207ad8:	86ca                	mv	a3,s2
ffffffffc0207ada:	00006617          	auipc	a2,0x6
ffffffffc0207ade:	3ee60613          	addi	a2,a2,1006 # ffffffffc020dec8 <CSWTCH.79+0x6c0>
ffffffffc0207ae2:	43d8                	lw	a4,4(a5)
ffffffffc0207ae4:	0d800593          	li	a1,216
ffffffffc0207ae8:	0b478793          	addi	a5,a5,180
ffffffffc0207aec:	00006517          	auipc	a0,0x6
ffffffffc0207af0:	40c50513          	addi	a0,a0,1036 # ffffffffc020def8 <CSWTCH.79+0x6f0>
ffffffffc0207af4:	f3af80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207af8 <vfs_do_add>:
ffffffffc0207af8:	7139                	addi	sp,sp,-64
ffffffffc0207afa:	fc06                	sd	ra,56(sp)
ffffffffc0207afc:	f822                	sd	s0,48(sp)
ffffffffc0207afe:	f426                	sd	s1,40(sp)
ffffffffc0207b00:	f04a                	sd	s2,32(sp)
ffffffffc0207b02:	ec4e                	sd	s3,24(sp)
ffffffffc0207b04:	e852                	sd	s4,16(sp)
ffffffffc0207b06:	e456                	sd	s5,8(sp)
ffffffffc0207b08:	e05a                	sd	s6,0(sp)
ffffffffc0207b0a:	0e050b63          	beqz	a0,ffffffffc0207c00 <vfs_do_add+0x108>
ffffffffc0207b0e:	842a                	mv	s0,a0
ffffffffc0207b10:	8a2e                	mv	s4,a1
ffffffffc0207b12:	8b32                	mv	s6,a2
ffffffffc0207b14:	8ab6                	mv	s5,a3
ffffffffc0207b16:	c5cd                	beqz	a1,ffffffffc0207bc0 <vfs_do_add+0xc8>
ffffffffc0207b18:	4db8                	lw	a4,88(a1)
ffffffffc0207b1a:	6785                	lui	a5,0x1
ffffffffc0207b1c:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0207b20:	0af71163          	bne	a4,a5,ffffffffc0207bc2 <vfs_do_add+0xca>
ffffffffc0207b24:	8522                	mv	a0,s0
ffffffffc0207b26:	764030ef          	jal	ra,ffffffffc020b28a <strlen>
ffffffffc0207b2a:	47fd                	li	a5,31
ffffffffc0207b2c:	0ca7e663          	bltu	a5,a0,ffffffffc0207bf8 <vfs_do_add+0x100>
ffffffffc0207b30:	8522                	mv	a0,s0
ffffffffc0207b32:	d80f80ef          	jal	ra,ffffffffc02000b2 <strdup>
ffffffffc0207b36:	84aa                	mv	s1,a0
ffffffffc0207b38:	c171                	beqz	a0,ffffffffc0207bfc <vfs_do_add+0x104>
ffffffffc0207b3a:	03000513          	li	a0,48
ffffffffc0207b3e:	d93fb0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0207b42:	89aa                	mv	s3,a0
ffffffffc0207b44:	c92d                	beqz	a0,ffffffffc0207bb6 <vfs_do_add+0xbe>
ffffffffc0207b46:	0008e517          	auipc	a0,0x8e
ffffffffc0207b4a:	d0a50513          	addi	a0,a0,-758 # ffffffffc0295850 <vdev_list_sem>
ffffffffc0207b4e:	0008e917          	auipc	s2,0x8e
ffffffffc0207b52:	cf290913          	addi	s2,s2,-782 # ffffffffc0295840 <vdev_list>
ffffffffc0207b56:	d03fc0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc0207b5a:	844a                	mv	s0,s2
ffffffffc0207b5c:	a039                	j	ffffffffc0207b6a <vfs_do_add+0x72>
ffffffffc0207b5e:	fe043503          	ld	a0,-32(s0)
ffffffffc0207b62:	85a6                	mv	a1,s1
ffffffffc0207b64:	76e030ef          	jal	ra,ffffffffc020b2d2 <strcmp>
ffffffffc0207b68:	cd2d                	beqz	a0,ffffffffc0207be2 <vfs_do_add+0xea>
ffffffffc0207b6a:	6400                	ld	s0,8(s0)
ffffffffc0207b6c:	ff2419e3          	bne	s0,s2,ffffffffc0207b5e <vfs_do_add+0x66>
ffffffffc0207b70:	6418                	ld	a4,8(s0)
ffffffffc0207b72:	02098793          	addi	a5,s3,32
ffffffffc0207b76:	0099b023          	sd	s1,0(s3)
ffffffffc0207b7a:	0149b423          	sd	s4,8(s3)
ffffffffc0207b7e:	0159bc23          	sd	s5,24(s3)
ffffffffc0207b82:	0169b823          	sd	s6,16(s3)
ffffffffc0207b86:	e31c                	sd	a5,0(a4)
ffffffffc0207b88:	0289b023          	sd	s0,32(s3)
ffffffffc0207b8c:	02e9b423          	sd	a4,40(s3)
ffffffffc0207b90:	0008e517          	auipc	a0,0x8e
ffffffffc0207b94:	cc050513          	addi	a0,a0,-832 # ffffffffc0295850 <vdev_list_sem>
ffffffffc0207b98:	e41c                	sd	a5,8(s0)
ffffffffc0207b9a:	4401                	li	s0,0
ffffffffc0207b9c:	cb9fc0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0207ba0:	70e2                	ld	ra,56(sp)
ffffffffc0207ba2:	8522                	mv	a0,s0
ffffffffc0207ba4:	7442                	ld	s0,48(sp)
ffffffffc0207ba6:	74a2                	ld	s1,40(sp)
ffffffffc0207ba8:	7902                	ld	s2,32(sp)
ffffffffc0207baa:	69e2                	ld	s3,24(sp)
ffffffffc0207bac:	6a42                	ld	s4,16(sp)
ffffffffc0207bae:	6aa2                	ld	s5,8(sp)
ffffffffc0207bb0:	6b02                	ld	s6,0(sp)
ffffffffc0207bb2:	6121                	addi	sp,sp,64
ffffffffc0207bb4:	8082                	ret
ffffffffc0207bb6:	5471                	li	s0,-4
ffffffffc0207bb8:	8526                	mv	a0,s1
ffffffffc0207bba:	dc7fb0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0207bbe:	b7cd                	j	ffffffffc0207ba0 <vfs_do_add+0xa8>
ffffffffc0207bc0:	d2b5                	beqz	a3,ffffffffc0207b24 <vfs_do_add+0x2c>
ffffffffc0207bc2:	00007697          	auipc	a3,0x7
ffffffffc0207bc6:	b7668693          	addi	a3,a3,-1162 # ffffffffc020e738 <syscalls+0x828>
ffffffffc0207bca:	00004617          	auipc	a2,0x4
ffffffffc0207bce:	15660613          	addi	a2,a2,342 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207bd2:	08f00593          	li	a1,143
ffffffffc0207bd6:	00007517          	auipc	a0,0x7
ffffffffc0207bda:	b4a50513          	addi	a0,a0,-1206 # ffffffffc020e720 <syscalls+0x810>
ffffffffc0207bde:	e50f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0207be2:	0008e517          	auipc	a0,0x8e
ffffffffc0207be6:	c6e50513          	addi	a0,a0,-914 # ffffffffc0295850 <vdev_list_sem>
ffffffffc0207bea:	c6bfc0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0207bee:	854e                	mv	a0,s3
ffffffffc0207bf0:	d91fb0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0207bf4:	5425                	li	s0,-23
ffffffffc0207bf6:	b7c9                	j	ffffffffc0207bb8 <vfs_do_add+0xc0>
ffffffffc0207bf8:	5451                	li	s0,-12
ffffffffc0207bfa:	b75d                	j	ffffffffc0207ba0 <vfs_do_add+0xa8>
ffffffffc0207bfc:	5471                	li	s0,-4
ffffffffc0207bfe:	b74d                	j	ffffffffc0207ba0 <vfs_do_add+0xa8>
ffffffffc0207c00:	00007697          	auipc	a3,0x7
ffffffffc0207c04:	b1068693          	addi	a3,a3,-1264 # ffffffffc020e710 <syscalls+0x800>
ffffffffc0207c08:	00004617          	auipc	a2,0x4
ffffffffc0207c0c:	11860613          	addi	a2,a2,280 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207c10:	08e00593          	li	a1,142
ffffffffc0207c14:	00007517          	auipc	a0,0x7
ffffffffc0207c18:	b0c50513          	addi	a0,a0,-1268 # ffffffffc020e720 <syscalls+0x810>
ffffffffc0207c1c:	e12f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207c20 <find_mount.part.0>:
ffffffffc0207c20:	1141                	addi	sp,sp,-16
ffffffffc0207c22:	00007697          	auipc	a3,0x7
ffffffffc0207c26:	aee68693          	addi	a3,a3,-1298 # ffffffffc020e710 <syscalls+0x800>
ffffffffc0207c2a:	00004617          	auipc	a2,0x4
ffffffffc0207c2e:	0f660613          	addi	a2,a2,246 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207c32:	0cd00593          	li	a1,205
ffffffffc0207c36:	00007517          	auipc	a0,0x7
ffffffffc0207c3a:	aea50513          	addi	a0,a0,-1302 # ffffffffc020e720 <syscalls+0x810>
ffffffffc0207c3e:	e406                	sd	ra,8(sp)
ffffffffc0207c40:	deef80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207c44 <vfs_devlist_init>:
ffffffffc0207c44:	0008e797          	auipc	a5,0x8e
ffffffffc0207c48:	bfc78793          	addi	a5,a5,-1028 # ffffffffc0295840 <vdev_list>
ffffffffc0207c4c:	4585                	li	a1,1
ffffffffc0207c4e:	0008e517          	auipc	a0,0x8e
ffffffffc0207c52:	c0250513          	addi	a0,a0,-1022 # ffffffffc0295850 <vdev_list_sem>
ffffffffc0207c56:	e79c                	sd	a5,8(a5)
ffffffffc0207c58:	e39c                	sd	a5,0(a5)
ffffffffc0207c5a:	bf3fc06f          	j	ffffffffc020484c <sem_init>

ffffffffc0207c5e <vfs_cleanup>:
ffffffffc0207c5e:	1101                	addi	sp,sp,-32
ffffffffc0207c60:	e426                	sd	s1,8(sp)
ffffffffc0207c62:	0008e497          	auipc	s1,0x8e
ffffffffc0207c66:	bde48493          	addi	s1,s1,-1058 # ffffffffc0295840 <vdev_list>
ffffffffc0207c6a:	649c                	ld	a5,8(s1)
ffffffffc0207c6c:	ec06                	sd	ra,24(sp)
ffffffffc0207c6e:	e822                	sd	s0,16(sp)
ffffffffc0207c70:	02978e63          	beq	a5,s1,ffffffffc0207cac <vfs_cleanup+0x4e>
ffffffffc0207c74:	0008e517          	auipc	a0,0x8e
ffffffffc0207c78:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0295850 <vdev_list_sem>
ffffffffc0207c7c:	bddfc0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc0207c80:	6480                	ld	s0,8(s1)
ffffffffc0207c82:	00940b63          	beq	s0,s1,ffffffffc0207c98 <vfs_cleanup+0x3a>
ffffffffc0207c86:	ff043783          	ld	a5,-16(s0)
ffffffffc0207c8a:	853e                	mv	a0,a5
ffffffffc0207c8c:	c399                	beqz	a5,ffffffffc0207c92 <vfs_cleanup+0x34>
ffffffffc0207c8e:	6bfc                	ld	a5,208(a5)
ffffffffc0207c90:	9782                	jalr	a5
ffffffffc0207c92:	6400                	ld	s0,8(s0)
ffffffffc0207c94:	fe9419e3          	bne	s0,s1,ffffffffc0207c86 <vfs_cleanup+0x28>
ffffffffc0207c98:	6442                	ld	s0,16(sp)
ffffffffc0207c9a:	60e2                	ld	ra,24(sp)
ffffffffc0207c9c:	64a2                	ld	s1,8(sp)
ffffffffc0207c9e:	0008e517          	auipc	a0,0x8e
ffffffffc0207ca2:	bb250513          	addi	a0,a0,-1102 # ffffffffc0295850 <vdev_list_sem>
ffffffffc0207ca6:	6105                	addi	sp,sp,32
ffffffffc0207ca8:	badfc06f          	j	ffffffffc0204854 <up>
ffffffffc0207cac:	60e2                	ld	ra,24(sp)
ffffffffc0207cae:	6442                	ld	s0,16(sp)
ffffffffc0207cb0:	64a2                	ld	s1,8(sp)
ffffffffc0207cb2:	6105                	addi	sp,sp,32
ffffffffc0207cb4:	8082                	ret

ffffffffc0207cb6 <vfs_get_root>:
ffffffffc0207cb6:	7179                	addi	sp,sp,-48
ffffffffc0207cb8:	f406                	sd	ra,40(sp)
ffffffffc0207cba:	f022                	sd	s0,32(sp)
ffffffffc0207cbc:	ec26                	sd	s1,24(sp)
ffffffffc0207cbe:	e84a                	sd	s2,16(sp)
ffffffffc0207cc0:	e44e                	sd	s3,8(sp)
ffffffffc0207cc2:	e052                	sd	s4,0(sp)
ffffffffc0207cc4:	c541                	beqz	a0,ffffffffc0207d4c <vfs_get_root+0x96>
ffffffffc0207cc6:	0008e917          	auipc	s2,0x8e
ffffffffc0207cca:	b7a90913          	addi	s2,s2,-1158 # ffffffffc0295840 <vdev_list>
ffffffffc0207cce:	00893783          	ld	a5,8(s2)
ffffffffc0207cd2:	07278b63          	beq	a5,s2,ffffffffc0207d48 <vfs_get_root+0x92>
ffffffffc0207cd6:	89aa                	mv	s3,a0
ffffffffc0207cd8:	0008e517          	auipc	a0,0x8e
ffffffffc0207cdc:	b7850513          	addi	a0,a0,-1160 # ffffffffc0295850 <vdev_list_sem>
ffffffffc0207ce0:	8a2e                	mv	s4,a1
ffffffffc0207ce2:	844a                	mv	s0,s2
ffffffffc0207ce4:	b75fc0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc0207ce8:	a801                	j	ffffffffc0207cf8 <vfs_get_root+0x42>
ffffffffc0207cea:	fe043583          	ld	a1,-32(s0)
ffffffffc0207cee:	854e                	mv	a0,s3
ffffffffc0207cf0:	5e2030ef          	jal	ra,ffffffffc020b2d2 <strcmp>
ffffffffc0207cf4:	84aa                	mv	s1,a0
ffffffffc0207cf6:	c505                	beqz	a0,ffffffffc0207d1e <vfs_get_root+0x68>
ffffffffc0207cf8:	6400                	ld	s0,8(s0)
ffffffffc0207cfa:	ff2418e3          	bne	s0,s2,ffffffffc0207cea <vfs_get_root+0x34>
ffffffffc0207cfe:	54cd                	li	s1,-13
ffffffffc0207d00:	0008e517          	auipc	a0,0x8e
ffffffffc0207d04:	b5050513          	addi	a0,a0,-1200 # ffffffffc0295850 <vdev_list_sem>
ffffffffc0207d08:	b4dfc0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0207d0c:	70a2                	ld	ra,40(sp)
ffffffffc0207d0e:	7402                	ld	s0,32(sp)
ffffffffc0207d10:	6942                	ld	s2,16(sp)
ffffffffc0207d12:	69a2                	ld	s3,8(sp)
ffffffffc0207d14:	6a02                	ld	s4,0(sp)
ffffffffc0207d16:	8526                	mv	a0,s1
ffffffffc0207d18:	64e2                	ld	s1,24(sp)
ffffffffc0207d1a:	6145                	addi	sp,sp,48
ffffffffc0207d1c:	8082                	ret
ffffffffc0207d1e:	ff043503          	ld	a0,-16(s0)
ffffffffc0207d22:	c519                	beqz	a0,ffffffffc0207d30 <vfs_get_root+0x7a>
ffffffffc0207d24:	617c                	ld	a5,192(a0)
ffffffffc0207d26:	9782                	jalr	a5
ffffffffc0207d28:	c519                	beqz	a0,ffffffffc0207d36 <vfs_get_root+0x80>
ffffffffc0207d2a:	00aa3023          	sd	a0,0(s4)
ffffffffc0207d2e:	bfc9                	j	ffffffffc0207d00 <vfs_get_root+0x4a>
ffffffffc0207d30:	ff843783          	ld	a5,-8(s0)
ffffffffc0207d34:	c399                	beqz	a5,ffffffffc0207d3a <vfs_get_root+0x84>
ffffffffc0207d36:	54c9                	li	s1,-14
ffffffffc0207d38:	b7e1                	j	ffffffffc0207d00 <vfs_get_root+0x4a>
ffffffffc0207d3a:	fe843503          	ld	a0,-24(s0)
ffffffffc0207d3e:	5ee000ef          	jal	ra,ffffffffc020832c <inode_ref_inc>
ffffffffc0207d42:	fe843503          	ld	a0,-24(s0)
ffffffffc0207d46:	b7cd                	j	ffffffffc0207d28 <vfs_get_root+0x72>
ffffffffc0207d48:	54cd                	li	s1,-13
ffffffffc0207d4a:	b7c9                	j	ffffffffc0207d0c <vfs_get_root+0x56>
ffffffffc0207d4c:	00007697          	auipc	a3,0x7
ffffffffc0207d50:	9c468693          	addi	a3,a3,-1596 # ffffffffc020e710 <syscalls+0x800>
ffffffffc0207d54:	00004617          	auipc	a2,0x4
ffffffffc0207d58:	fcc60613          	addi	a2,a2,-52 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207d5c:	04500593          	li	a1,69
ffffffffc0207d60:	00007517          	auipc	a0,0x7
ffffffffc0207d64:	9c050513          	addi	a0,a0,-1600 # ffffffffc020e720 <syscalls+0x810>
ffffffffc0207d68:	cc6f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207d6c <vfs_get_devname>:
ffffffffc0207d6c:	0008e697          	auipc	a3,0x8e
ffffffffc0207d70:	ad468693          	addi	a3,a3,-1324 # ffffffffc0295840 <vdev_list>
ffffffffc0207d74:	87b6                	mv	a5,a3
ffffffffc0207d76:	e511                	bnez	a0,ffffffffc0207d82 <vfs_get_devname+0x16>
ffffffffc0207d78:	a829                	j	ffffffffc0207d92 <vfs_get_devname+0x26>
ffffffffc0207d7a:	ff07b703          	ld	a4,-16(a5)
ffffffffc0207d7e:	00a70763          	beq	a4,a0,ffffffffc0207d8c <vfs_get_devname+0x20>
ffffffffc0207d82:	679c                	ld	a5,8(a5)
ffffffffc0207d84:	fed79be3          	bne	a5,a3,ffffffffc0207d7a <vfs_get_devname+0xe>
ffffffffc0207d88:	4501                	li	a0,0
ffffffffc0207d8a:	8082                	ret
ffffffffc0207d8c:	fe07b503          	ld	a0,-32(a5)
ffffffffc0207d90:	8082                	ret
ffffffffc0207d92:	1141                	addi	sp,sp,-16
ffffffffc0207d94:	00007697          	auipc	a3,0x7
ffffffffc0207d98:	a0468693          	addi	a3,a3,-1532 # ffffffffc020e798 <syscalls+0x888>
ffffffffc0207d9c:	00004617          	auipc	a2,0x4
ffffffffc0207da0:	f8460613          	addi	a2,a2,-124 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207da4:	06a00593          	li	a1,106
ffffffffc0207da8:	00007517          	auipc	a0,0x7
ffffffffc0207dac:	97850513          	addi	a0,a0,-1672 # ffffffffc020e720 <syscalls+0x810>
ffffffffc0207db0:	e406                	sd	ra,8(sp)
ffffffffc0207db2:	c7cf80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207db6 <vfs_add_dev>:
ffffffffc0207db6:	86b2                	mv	a3,a2
ffffffffc0207db8:	4601                	li	a2,0
ffffffffc0207dba:	d3fff06f          	j	ffffffffc0207af8 <vfs_do_add>

ffffffffc0207dbe <vfs_mount>:
ffffffffc0207dbe:	7179                	addi	sp,sp,-48
ffffffffc0207dc0:	e84a                	sd	s2,16(sp)
ffffffffc0207dc2:	892a                	mv	s2,a0
ffffffffc0207dc4:	0008e517          	auipc	a0,0x8e
ffffffffc0207dc8:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0295850 <vdev_list_sem>
ffffffffc0207dcc:	e44e                	sd	s3,8(sp)
ffffffffc0207dce:	f406                	sd	ra,40(sp)
ffffffffc0207dd0:	f022                	sd	s0,32(sp)
ffffffffc0207dd2:	ec26                	sd	s1,24(sp)
ffffffffc0207dd4:	89ae                	mv	s3,a1
ffffffffc0207dd6:	a83fc0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc0207dda:	08090a63          	beqz	s2,ffffffffc0207e6e <vfs_mount+0xb0>
ffffffffc0207dde:	0008e497          	auipc	s1,0x8e
ffffffffc0207de2:	a6248493          	addi	s1,s1,-1438 # ffffffffc0295840 <vdev_list>
ffffffffc0207de6:	6480                	ld	s0,8(s1)
ffffffffc0207de8:	00941663          	bne	s0,s1,ffffffffc0207df4 <vfs_mount+0x36>
ffffffffc0207dec:	a8ad                	j	ffffffffc0207e66 <vfs_mount+0xa8>
ffffffffc0207dee:	6400                	ld	s0,8(s0)
ffffffffc0207df0:	06940b63          	beq	s0,s1,ffffffffc0207e66 <vfs_mount+0xa8>
ffffffffc0207df4:	ff843783          	ld	a5,-8(s0)
ffffffffc0207df8:	dbfd                	beqz	a5,ffffffffc0207dee <vfs_mount+0x30>
ffffffffc0207dfa:	fe043503          	ld	a0,-32(s0)
ffffffffc0207dfe:	85ca                	mv	a1,s2
ffffffffc0207e00:	4d2030ef          	jal	ra,ffffffffc020b2d2 <strcmp>
ffffffffc0207e04:	f56d                	bnez	a0,ffffffffc0207dee <vfs_mount+0x30>
ffffffffc0207e06:	ff043783          	ld	a5,-16(s0)
ffffffffc0207e0a:	e3a5                	bnez	a5,ffffffffc0207e6a <vfs_mount+0xac>
ffffffffc0207e0c:	fe043783          	ld	a5,-32(s0)
ffffffffc0207e10:	c3c9                	beqz	a5,ffffffffc0207e92 <vfs_mount+0xd4>
ffffffffc0207e12:	ff843783          	ld	a5,-8(s0)
ffffffffc0207e16:	cfb5                	beqz	a5,ffffffffc0207e92 <vfs_mount+0xd4>
ffffffffc0207e18:	fe843503          	ld	a0,-24(s0)
ffffffffc0207e1c:	c939                	beqz	a0,ffffffffc0207e72 <vfs_mount+0xb4>
ffffffffc0207e1e:	4d38                	lw	a4,88(a0)
ffffffffc0207e20:	6785                	lui	a5,0x1
ffffffffc0207e22:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0207e26:	04f71663          	bne	a4,a5,ffffffffc0207e72 <vfs_mount+0xb4>
ffffffffc0207e2a:	ff040593          	addi	a1,s0,-16
ffffffffc0207e2e:	9982                	jalr	s3
ffffffffc0207e30:	84aa                	mv	s1,a0
ffffffffc0207e32:	ed01                	bnez	a0,ffffffffc0207e4a <vfs_mount+0x8c>
ffffffffc0207e34:	ff043783          	ld	a5,-16(s0)
ffffffffc0207e38:	cfad                	beqz	a5,ffffffffc0207eb2 <vfs_mount+0xf4>
ffffffffc0207e3a:	fe043583          	ld	a1,-32(s0)
ffffffffc0207e3e:	00007517          	auipc	a0,0x7
ffffffffc0207e42:	9ea50513          	addi	a0,a0,-1558 # ffffffffc020e828 <syscalls+0x918>
ffffffffc0207e46:	ae4f80ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0207e4a:	0008e517          	auipc	a0,0x8e
ffffffffc0207e4e:	a0650513          	addi	a0,a0,-1530 # ffffffffc0295850 <vdev_list_sem>
ffffffffc0207e52:	a03fc0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0207e56:	70a2                	ld	ra,40(sp)
ffffffffc0207e58:	7402                	ld	s0,32(sp)
ffffffffc0207e5a:	6942                	ld	s2,16(sp)
ffffffffc0207e5c:	69a2                	ld	s3,8(sp)
ffffffffc0207e5e:	8526                	mv	a0,s1
ffffffffc0207e60:	64e2                	ld	s1,24(sp)
ffffffffc0207e62:	6145                	addi	sp,sp,48
ffffffffc0207e64:	8082                	ret
ffffffffc0207e66:	54cd                	li	s1,-13
ffffffffc0207e68:	b7cd                	j	ffffffffc0207e4a <vfs_mount+0x8c>
ffffffffc0207e6a:	54c5                	li	s1,-15
ffffffffc0207e6c:	bff9                	j	ffffffffc0207e4a <vfs_mount+0x8c>
ffffffffc0207e6e:	db3ff0ef          	jal	ra,ffffffffc0207c20 <find_mount.part.0>
ffffffffc0207e72:	00007697          	auipc	a3,0x7
ffffffffc0207e76:	96668693          	addi	a3,a3,-1690 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc0207e7a:	00004617          	auipc	a2,0x4
ffffffffc0207e7e:	ea660613          	addi	a2,a2,-346 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207e82:	0ed00593          	li	a1,237
ffffffffc0207e86:	00007517          	auipc	a0,0x7
ffffffffc0207e8a:	89a50513          	addi	a0,a0,-1894 # ffffffffc020e720 <syscalls+0x810>
ffffffffc0207e8e:	ba0f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0207e92:	00007697          	auipc	a3,0x7
ffffffffc0207e96:	91668693          	addi	a3,a3,-1770 # ffffffffc020e7a8 <syscalls+0x898>
ffffffffc0207e9a:	00004617          	auipc	a2,0x4
ffffffffc0207e9e:	e8660613          	addi	a2,a2,-378 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207ea2:	0eb00593          	li	a1,235
ffffffffc0207ea6:	00007517          	auipc	a0,0x7
ffffffffc0207eaa:	87a50513          	addi	a0,a0,-1926 # ffffffffc020e720 <syscalls+0x810>
ffffffffc0207eae:	b80f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0207eb2:	00007697          	auipc	a3,0x7
ffffffffc0207eb6:	95e68693          	addi	a3,a3,-1698 # ffffffffc020e810 <syscalls+0x900>
ffffffffc0207eba:	00004617          	auipc	a2,0x4
ffffffffc0207ebe:	e6660613          	addi	a2,a2,-410 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207ec2:	0ef00593          	li	a1,239
ffffffffc0207ec6:	00007517          	auipc	a0,0x7
ffffffffc0207eca:	85a50513          	addi	a0,a0,-1958 # ffffffffc020e720 <syscalls+0x810>
ffffffffc0207ece:	b60f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207ed2 <vfs_get_curdir>:
ffffffffc0207ed2:	0008f797          	auipc	a5,0x8f
ffffffffc0207ed6:	a367b783          	ld	a5,-1482(a5) # ffffffffc0296908 <current>
ffffffffc0207eda:	1487b783          	ld	a5,328(a5)
ffffffffc0207ede:	1101                	addi	sp,sp,-32
ffffffffc0207ee0:	e426                	sd	s1,8(sp)
ffffffffc0207ee2:	6384                	ld	s1,0(a5)
ffffffffc0207ee4:	ec06                	sd	ra,24(sp)
ffffffffc0207ee6:	e822                	sd	s0,16(sp)
ffffffffc0207ee8:	cc81                	beqz	s1,ffffffffc0207f00 <vfs_get_curdir+0x2e>
ffffffffc0207eea:	842a                	mv	s0,a0
ffffffffc0207eec:	8526                	mv	a0,s1
ffffffffc0207eee:	43e000ef          	jal	ra,ffffffffc020832c <inode_ref_inc>
ffffffffc0207ef2:	4501                	li	a0,0
ffffffffc0207ef4:	e004                	sd	s1,0(s0)
ffffffffc0207ef6:	60e2                	ld	ra,24(sp)
ffffffffc0207ef8:	6442                	ld	s0,16(sp)
ffffffffc0207efa:	64a2                	ld	s1,8(sp)
ffffffffc0207efc:	6105                	addi	sp,sp,32
ffffffffc0207efe:	8082                	ret
ffffffffc0207f00:	5541                	li	a0,-16
ffffffffc0207f02:	bfd5                	j	ffffffffc0207ef6 <vfs_get_curdir+0x24>

ffffffffc0207f04 <vfs_set_curdir>:
ffffffffc0207f04:	7139                	addi	sp,sp,-64
ffffffffc0207f06:	f04a                	sd	s2,32(sp)
ffffffffc0207f08:	0008f917          	auipc	s2,0x8f
ffffffffc0207f0c:	a0090913          	addi	s2,s2,-1536 # ffffffffc0296908 <current>
ffffffffc0207f10:	00093783          	ld	a5,0(s2)
ffffffffc0207f14:	f822                	sd	s0,48(sp)
ffffffffc0207f16:	842a                	mv	s0,a0
ffffffffc0207f18:	1487b503          	ld	a0,328(a5)
ffffffffc0207f1c:	ec4e                	sd	s3,24(sp)
ffffffffc0207f1e:	fc06                	sd	ra,56(sp)
ffffffffc0207f20:	f426                	sd	s1,40(sp)
ffffffffc0207f22:	9c7fd0ef          	jal	ra,ffffffffc02058e8 <lock_files>
ffffffffc0207f26:	00093783          	ld	a5,0(s2)
ffffffffc0207f2a:	1487b503          	ld	a0,328(a5)
ffffffffc0207f2e:	00053983          	ld	s3,0(a0)
ffffffffc0207f32:	07340963          	beq	s0,s3,ffffffffc0207fa4 <vfs_set_curdir+0xa0>
ffffffffc0207f36:	cc39                	beqz	s0,ffffffffc0207f94 <vfs_set_curdir+0x90>
ffffffffc0207f38:	783c                	ld	a5,112(s0)
ffffffffc0207f3a:	c7bd                	beqz	a5,ffffffffc0207fa8 <vfs_set_curdir+0xa4>
ffffffffc0207f3c:	6bbc                	ld	a5,80(a5)
ffffffffc0207f3e:	c7ad                	beqz	a5,ffffffffc0207fa8 <vfs_set_curdir+0xa4>
ffffffffc0207f40:	00007597          	auipc	a1,0x7
ffffffffc0207f44:	96058593          	addi	a1,a1,-1696 # ffffffffc020e8a0 <syscalls+0x990>
ffffffffc0207f48:	8522                	mv	a0,s0
ffffffffc0207f4a:	3fa000ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc0207f4e:	783c                	ld	a5,112(s0)
ffffffffc0207f50:	006c                	addi	a1,sp,12
ffffffffc0207f52:	8522                	mv	a0,s0
ffffffffc0207f54:	6bbc                	ld	a5,80(a5)
ffffffffc0207f56:	9782                	jalr	a5
ffffffffc0207f58:	84aa                	mv	s1,a0
ffffffffc0207f5a:	e901                	bnez	a0,ffffffffc0207f6a <vfs_set_curdir+0x66>
ffffffffc0207f5c:	47b2                	lw	a5,12(sp)
ffffffffc0207f5e:	669d                	lui	a3,0x7
ffffffffc0207f60:	6709                	lui	a4,0x2
ffffffffc0207f62:	8ff5                	and	a5,a5,a3
ffffffffc0207f64:	54b9                	li	s1,-18
ffffffffc0207f66:	02e78063          	beq	a5,a4,ffffffffc0207f86 <vfs_set_curdir+0x82>
ffffffffc0207f6a:	00093783          	ld	a5,0(s2)
ffffffffc0207f6e:	1487b503          	ld	a0,328(a5)
ffffffffc0207f72:	97dfd0ef          	jal	ra,ffffffffc02058ee <unlock_files>
ffffffffc0207f76:	70e2                	ld	ra,56(sp)
ffffffffc0207f78:	7442                	ld	s0,48(sp)
ffffffffc0207f7a:	7902                	ld	s2,32(sp)
ffffffffc0207f7c:	69e2                	ld	s3,24(sp)
ffffffffc0207f7e:	8526                	mv	a0,s1
ffffffffc0207f80:	74a2                	ld	s1,40(sp)
ffffffffc0207f82:	6121                	addi	sp,sp,64
ffffffffc0207f84:	8082                	ret
ffffffffc0207f86:	8522                	mv	a0,s0
ffffffffc0207f88:	3a4000ef          	jal	ra,ffffffffc020832c <inode_ref_inc>
ffffffffc0207f8c:	00093783          	ld	a5,0(s2)
ffffffffc0207f90:	1487b503          	ld	a0,328(a5)
ffffffffc0207f94:	e100                	sd	s0,0(a0)
ffffffffc0207f96:	4481                	li	s1,0
ffffffffc0207f98:	fc098de3          	beqz	s3,ffffffffc0207f72 <vfs_set_curdir+0x6e>
ffffffffc0207f9c:	854e                	mv	a0,s3
ffffffffc0207f9e:	45c000ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc0207fa2:	b7e1                	j	ffffffffc0207f6a <vfs_set_curdir+0x66>
ffffffffc0207fa4:	4481                	li	s1,0
ffffffffc0207fa6:	b7f1                	j	ffffffffc0207f72 <vfs_set_curdir+0x6e>
ffffffffc0207fa8:	00007697          	auipc	a3,0x7
ffffffffc0207fac:	89068693          	addi	a3,a3,-1904 # ffffffffc020e838 <syscalls+0x928>
ffffffffc0207fb0:	00004617          	auipc	a2,0x4
ffffffffc0207fb4:	d7060613          	addi	a2,a2,-656 # ffffffffc020bd20 <commands+0x250>
ffffffffc0207fb8:	04300593          	li	a1,67
ffffffffc0207fbc:	00007517          	auipc	a0,0x7
ffffffffc0207fc0:	8cc50513          	addi	a0,a0,-1844 # ffffffffc020e888 <syscalls+0x978>
ffffffffc0207fc4:	a6af80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0207fc8 <vfs_chdir>:
ffffffffc0207fc8:	1101                	addi	sp,sp,-32
ffffffffc0207fca:	002c                	addi	a1,sp,8
ffffffffc0207fcc:	e822                	sd	s0,16(sp)
ffffffffc0207fce:	ec06                	sd	ra,24(sp)
ffffffffc0207fd0:	21e000ef          	jal	ra,ffffffffc02081ee <vfs_lookup>
ffffffffc0207fd4:	842a                	mv	s0,a0
ffffffffc0207fd6:	c511                	beqz	a0,ffffffffc0207fe2 <vfs_chdir+0x1a>
ffffffffc0207fd8:	60e2                	ld	ra,24(sp)
ffffffffc0207fda:	8522                	mv	a0,s0
ffffffffc0207fdc:	6442                	ld	s0,16(sp)
ffffffffc0207fde:	6105                	addi	sp,sp,32
ffffffffc0207fe0:	8082                	ret
ffffffffc0207fe2:	6522                	ld	a0,8(sp)
ffffffffc0207fe4:	f21ff0ef          	jal	ra,ffffffffc0207f04 <vfs_set_curdir>
ffffffffc0207fe8:	842a                	mv	s0,a0
ffffffffc0207fea:	6522                	ld	a0,8(sp)
ffffffffc0207fec:	40e000ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc0207ff0:	60e2                	ld	ra,24(sp)
ffffffffc0207ff2:	8522                	mv	a0,s0
ffffffffc0207ff4:	6442                	ld	s0,16(sp)
ffffffffc0207ff6:	6105                	addi	sp,sp,32
ffffffffc0207ff8:	8082                	ret

ffffffffc0207ffa <vfs_getcwd>:
ffffffffc0207ffa:	0008f797          	auipc	a5,0x8f
ffffffffc0207ffe:	90e7b783          	ld	a5,-1778(a5) # ffffffffc0296908 <current>
ffffffffc0208002:	1487b783          	ld	a5,328(a5)
ffffffffc0208006:	7179                	addi	sp,sp,-48
ffffffffc0208008:	ec26                	sd	s1,24(sp)
ffffffffc020800a:	6384                	ld	s1,0(a5)
ffffffffc020800c:	f406                	sd	ra,40(sp)
ffffffffc020800e:	f022                	sd	s0,32(sp)
ffffffffc0208010:	e84a                	sd	s2,16(sp)
ffffffffc0208012:	ccbd                	beqz	s1,ffffffffc0208090 <vfs_getcwd+0x96>
ffffffffc0208014:	892a                	mv	s2,a0
ffffffffc0208016:	8526                	mv	a0,s1
ffffffffc0208018:	314000ef          	jal	ra,ffffffffc020832c <inode_ref_inc>
ffffffffc020801c:	74a8                	ld	a0,104(s1)
ffffffffc020801e:	c93d                	beqz	a0,ffffffffc0208094 <vfs_getcwd+0x9a>
ffffffffc0208020:	d4dff0ef          	jal	ra,ffffffffc0207d6c <vfs_get_devname>
ffffffffc0208024:	842a                	mv	s0,a0
ffffffffc0208026:	264030ef          	jal	ra,ffffffffc020b28a <strlen>
ffffffffc020802a:	862a                	mv	a2,a0
ffffffffc020802c:	85a2                	mv	a1,s0
ffffffffc020802e:	4701                	li	a4,0
ffffffffc0208030:	4685                	li	a3,1
ffffffffc0208032:	854a                	mv	a0,s2
ffffffffc0208034:	811fd0ef          	jal	ra,ffffffffc0205844 <iobuf_move>
ffffffffc0208038:	842a                	mv	s0,a0
ffffffffc020803a:	c919                	beqz	a0,ffffffffc0208050 <vfs_getcwd+0x56>
ffffffffc020803c:	8526                	mv	a0,s1
ffffffffc020803e:	3bc000ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc0208042:	70a2                	ld	ra,40(sp)
ffffffffc0208044:	8522                	mv	a0,s0
ffffffffc0208046:	7402                	ld	s0,32(sp)
ffffffffc0208048:	64e2                	ld	s1,24(sp)
ffffffffc020804a:	6942                	ld	s2,16(sp)
ffffffffc020804c:	6145                	addi	sp,sp,48
ffffffffc020804e:	8082                	ret
ffffffffc0208050:	03a00793          	li	a5,58
ffffffffc0208054:	4701                	li	a4,0
ffffffffc0208056:	4685                	li	a3,1
ffffffffc0208058:	4605                	li	a2,1
ffffffffc020805a:	00f10593          	addi	a1,sp,15
ffffffffc020805e:	854a                	mv	a0,s2
ffffffffc0208060:	00f107a3          	sb	a5,15(sp)
ffffffffc0208064:	fe0fd0ef          	jal	ra,ffffffffc0205844 <iobuf_move>
ffffffffc0208068:	842a                	mv	s0,a0
ffffffffc020806a:	f969                	bnez	a0,ffffffffc020803c <vfs_getcwd+0x42>
ffffffffc020806c:	78bc                	ld	a5,112(s1)
ffffffffc020806e:	c3b9                	beqz	a5,ffffffffc02080b4 <vfs_getcwd+0xba>
ffffffffc0208070:	7f9c                	ld	a5,56(a5)
ffffffffc0208072:	c3a9                	beqz	a5,ffffffffc02080b4 <vfs_getcwd+0xba>
ffffffffc0208074:	00007597          	auipc	a1,0x7
ffffffffc0208078:	8a458593          	addi	a1,a1,-1884 # ffffffffc020e918 <syscalls+0xa08>
ffffffffc020807c:	8526                	mv	a0,s1
ffffffffc020807e:	2c6000ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc0208082:	78bc                	ld	a5,112(s1)
ffffffffc0208084:	85ca                	mv	a1,s2
ffffffffc0208086:	8526                	mv	a0,s1
ffffffffc0208088:	7f9c                	ld	a5,56(a5)
ffffffffc020808a:	9782                	jalr	a5
ffffffffc020808c:	842a                	mv	s0,a0
ffffffffc020808e:	b77d                	j	ffffffffc020803c <vfs_getcwd+0x42>
ffffffffc0208090:	5441                	li	s0,-16
ffffffffc0208092:	bf45                	j	ffffffffc0208042 <vfs_getcwd+0x48>
ffffffffc0208094:	00007697          	auipc	a3,0x7
ffffffffc0208098:	81468693          	addi	a3,a3,-2028 # ffffffffc020e8a8 <syscalls+0x998>
ffffffffc020809c:	00004617          	auipc	a2,0x4
ffffffffc02080a0:	c8460613          	addi	a2,a2,-892 # ffffffffc020bd20 <commands+0x250>
ffffffffc02080a4:	06e00593          	li	a1,110
ffffffffc02080a8:	00006517          	auipc	a0,0x6
ffffffffc02080ac:	7e050513          	addi	a0,a0,2016 # ffffffffc020e888 <syscalls+0x978>
ffffffffc02080b0:	97ef80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02080b4:	00007697          	auipc	a3,0x7
ffffffffc02080b8:	80c68693          	addi	a3,a3,-2036 # ffffffffc020e8c0 <syscalls+0x9b0>
ffffffffc02080bc:	00004617          	auipc	a2,0x4
ffffffffc02080c0:	c6460613          	addi	a2,a2,-924 # ffffffffc020bd20 <commands+0x250>
ffffffffc02080c4:	07800593          	li	a1,120
ffffffffc02080c8:	00006517          	auipc	a0,0x6
ffffffffc02080cc:	7c050513          	addi	a0,a0,1984 # ffffffffc020e888 <syscalls+0x978>
ffffffffc02080d0:	95ef80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02080d4 <get_device>:
ffffffffc02080d4:	7179                	addi	sp,sp,-48
ffffffffc02080d6:	ec26                	sd	s1,24(sp)
ffffffffc02080d8:	e84a                	sd	s2,16(sp)
ffffffffc02080da:	f406                	sd	ra,40(sp)
ffffffffc02080dc:	f022                	sd	s0,32(sp)
ffffffffc02080de:	00054303          	lbu	t1,0(a0)
ffffffffc02080e2:	892e                	mv	s2,a1
ffffffffc02080e4:	84b2                	mv	s1,a2
ffffffffc02080e6:	02030463          	beqz	t1,ffffffffc020810e <get_device+0x3a>
ffffffffc02080ea:	00150413          	addi	s0,a0,1
ffffffffc02080ee:	86a2                	mv	a3,s0
ffffffffc02080f0:	879a                	mv	a5,t1
ffffffffc02080f2:	4701                	li	a4,0
ffffffffc02080f4:	03a00813          	li	a6,58
ffffffffc02080f8:	02f00893          	li	a7,47
ffffffffc02080fc:	03078363          	beq	a5,a6,ffffffffc0208122 <get_device+0x4e>
ffffffffc0208100:	05178a63          	beq	a5,a7,ffffffffc0208154 <get_device+0x80>
ffffffffc0208104:	0006c783          	lbu	a5,0(a3)
ffffffffc0208108:	2705                	addiw	a4,a4,1
ffffffffc020810a:	0685                	addi	a3,a3,1
ffffffffc020810c:	fbe5                	bnez	a5,ffffffffc02080fc <get_device+0x28>
ffffffffc020810e:	7402                	ld	s0,32(sp)
ffffffffc0208110:	00a93023          	sd	a0,0(s2)
ffffffffc0208114:	70a2                	ld	ra,40(sp)
ffffffffc0208116:	6942                	ld	s2,16(sp)
ffffffffc0208118:	8526                	mv	a0,s1
ffffffffc020811a:	64e2                	ld	s1,24(sp)
ffffffffc020811c:	6145                	addi	sp,sp,48
ffffffffc020811e:	db5ff06f          	j	ffffffffc0207ed2 <vfs_get_curdir>
ffffffffc0208122:	cb15                	beqz	a4,ffffffffc0208156 <get_device+0x82>
ffffffffc0208124:	00e507b3          	add	a5,a0,a4
ffffffffc0208128:	0705                	addi	a4,a4,1
ffffffffc020812a:	00078023          	sb	zero,0(a5)
ffffffffc020812e:	972a                	add	a4,a4,a0
ffffffffc0208130:	02f00613          	li	a2,47
ffffffffc0208134:	00074783          	lbu	a5,0(a4) # 2000 <_binary_bin_swap_img_size-0x5d00>
ffffffffc0208138:	86ba                	mv	a3,a4
ffffffffc020813a:	0705                	addi	a4,a4,1
ffffffffc020813c:	fec78ce3          	beq	a5,a2,ffffffffc0208134 <get_device+0x60>
ffffffffc0208140:	7402                	ld	s0,32(sp)
ffffffffc0208142:	70a2                	ld	ra,40(sp)
ffffffffc0208144:	00d93023          	sd	a3,0(s2)
ffffffffc0208148:	85a6                	mv	a1,s1
ffffffffc020814a:	6942                	ld	s2,16(sp)
ffffffffc020814c:	64e2                	ld	s1,24(sp)
ffffffffc020814e:	6145                	addi	sp,sp,48
ffffffffc0208150:	b67ff06f          	j	ffffffffc0207cb6 <vfs_get_root>
ffffffffc0208154:	ff4d                	bnez	a4,ffffffffc020810e <get_device+0x3a>
ffffffffc0208156:	02f00793          	li	a5,47
ffffffffc020815a:	04f30563          	beq	t1,a5,ffffffffc02081a4 <get_device+0xd0>
ffffffffc020815e:	03a00793          	li	a5,58
ffffffffc0208162:	06f31663          	bne	t1,a5,ffffffffc02081ce <get_device+0xfa>
ffffffffc0208166:	0028                	addi	a0,sp,8
ffffffffc0208168:	d6bff0ef          	jal	ra,ffffffffc0207ed2 <vfs_get_curdir>
ffffffffc020816c:	e515                	bnez	a0,ffffffffc0208198 <get_device+0xc4>
ffffffffc020816e:	67a2                	ld	a5,8(sp)
ffffffffc0208170:	77a8                	ld	a0,104(a5)
ffffffffc0208172:	cd15                	beqz	a0,ffffffffc02081ae <get_device+0xda>
ffffffffc0208174:	617c                	ld	a5,192(a0)
ffffffffc0208176:	9782                	jalr	a5
ffffffffc0208178:	87aa                	mv	a5,a0
ffffffffc020817a:	6522                	ld	a0,8(sp)
ffffffffc020817c:	e09c                	sd	a5,0(s1)
ffffffffc020817e:	27c000ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc0208182:	02f00713          	li	a4,47
ffffffffc0208186:	a011                	j	ffffffffc020818a <get_device+0xb6>
ffffffffc0208188:	0405                	addi	s0,s0,1
ffffffffc020818a:	00044783          	lbu	a5,0(s0)
ffffffffc020818e:	fee78de3          	beq	a5,a4,ffffffffc0208188 <get_device+0xb4>
ffffffffc0208192:	00893023          	sd	s0,0(s2)
ffffffffc0208196:	4501                	li	a0,0
ffffffffc0208198:	70a2                	ld	ra,40(sp)
ffffffffc020819a:	7402                	ld	s0,32(sp)
ffffffffc020819c:	64e2                	ld	s1,24(sp)
ffffffffc020819e:	6942                	ld	s2,16(sp)
ffffffffc02081a0:	6145                	addi	sp,sp,48
ffffffffc02081a2:	8082                	ret
ffffffffc02081a4:	8526                	mv	a0,s1
ffffffffc02081a6:	616000ef          	jal	ra,ffffffffc02087bc <vfs_get_bootfs>
ffffffffc02081aa:	dd61                	beqz	a0,ffffffffc0208182 <get_device+0xae>
ffffffffc02081ac:	b7f5                	j	ffffffffc0208198 <get_device+0xc4>
ffffffffc02081ae:	00006697          	auipc	a3,0x6
ffffffffc02081b2:	6fa68693          	addi	a3,a3,1786 # ffffffffc020e8a8 <syscalls+0x998>
ffffffffc02081b6:	00004617          	auipc	a2,0x4
ffffffffc02081ba:	b6a60613          	addi	a2,a2,-1174 # ffffffffc020bd20 <commands+0x250>
ffffffffc02081be:	03900593          	li	a1,57
ffffffffc02081c2:	00006517          	auipc	a0,0x6
ffffffffc02081c6:	77650513          	addi	a0,a0,1910 # ffffffffc020e938 <syscalls+0xa28>
ffffffffc02081ca:	864f80ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02081ce:	00006697          	auipc	a3,0x6
ffffffffc02081d2:	75a68693          	addi	a3,a3,1882 # ffffffffc020e928 <syscalls+0xa18>
ffffffffc02081d6:	00004617          	auipc	a2,0x4
ffffffffc02081da:	b4a60613          	addi	a2,a2,-1206 # ffffffffc020bd20 <commands+0x250>
ffffffffc02081de:	03300593          	li	a1,51
ffffffffc02081e2:	00006517          	auipc	a0,0x6
ffffffffc02081e6:	75650513          	addi	a0,a0,1878 # ffffffffc020e938 <syscalls+0xa28>
ffffffffc02081ea:	844f80ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02081ee <vfs_lookup>:
ffffffffc02081ee:	7139                	addi	sp,sp,-64
ffffffffc02081f0:	f426                	sd	s1,40(sp)
ffffffffc02081f2:	0830                	addi	a2,sp,24
ffffffffc02081f4:	84ae                	mv	s1,a1
ffffffffc02081f6:	002c                	addi	a1,sp,8
ffffffffc02081f8:	f822                	sd	s0,48(sp)
ffffffffc02081fa:	fc06                	sd	ra,56(sp)
ffffffffc02081fc:	f04a                	sd	s2,32(sp)
ffffffffc02081fe:	e42a                	sd	a0,8(sp)
ffffffffc0208200:	ed5ff0ef          	jal	ra,ffffffffc02080d4 <get_device>
ffffffffc0208204:	842a                	mv	s0,a0
ffffffffc0208206:	ed1d                	bnez	a0,ffffffffc0208244 <vfs_lookup+0x56>
ffffffffc0208208:	67a2                	ld	a5,8(sp)
ffffffffc020820a:	6962                	ld	s2,24(sp)
ffffffffc020820c:	0007c783          	lbu	a5,0(a5)
ffffffffc0208210:	c3a9                	beqz	a5,ffffffffc0208252 <vfs_lookup+0x64>
ffffffffc0208212:	04090963          	beqz	s2,ffffffffc0208264 <vfs_lookup+0x76>
ffffffffc0208216:	07093783          	ld	a5,112(s2)
ffffffffc020821a:	c7a9                	beqz	a5,ffffffffc0208264 <vfs_lookup+0x76>
ffffffffc020821c:	7bbc                	ld	a5,112(a5)
ffffffffc020821e:	c3b9                	beqz	a5,ffffffffc0208264 <vfs_lookup+0x76>
ffffffffc0208220:	854a                	mv	a0,s2
ffffffffc0208222:	00006597          	auipc	a1,0x6
ffffffffc0208226:	77e58593          	addi	a1,a1,1918 # ffffffffc020e9a0 <syscalls+0xa90>
ffffffffc020822a:	11a000ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc020822e:	07093783          	ld	a5,112(s2)
ffffffffc0208232:	65a2                	ld	a1,8(sp)
ffffffffc0208234:	6562                	ld	a0,24(sp)
ffffffffc0208236:	7bbc                	ld	a5,112(a5)
ffffffffc0208238:	8626                	mv	a2,s1
ffffffffc020823a:	9782                	jalr	a5
ffffffffc020823c:	842a                	mv	s0,a0
ffffffffc020823e:	6562                	ld	a0,24(sp)
ffffffffc0208240:	1ba000ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc0208244:	70e2                	ld	ra,56(sp)
ffffffffc0208246:	8522                	mv	a0,s0
ffffffffc0208248:	7442                	ld	s0,48(sp)
ffffffffc020824a:	74a2                	ld	s1,40(sp)
ffffffffc020824c:	7902                	ld	s2,32(sp)
ffffffffc020824e:	6121                	addi	sp,sp,64
ffffffffc0208250:	8082                	ret
ffffffffc0208252:	70e2                	ld	ra,56(sp)
ffffffffc0208254:	8522                	mv	a0,s0
ffffffffc0208256:	7442                	ld	s0,48(sp)
ffffffffc0208258:	0124b023          	sd	s2,0(s1)
ffffffffc020825c:	74a2                	ld	s1,40(sp)
ffffffffc020825e:	7902                	ld	s2,32(sp)
ffffffffc0208260:	6121                	addi	sp,sp,64
ffffffffc0208262:	8082                	ret
ffffffffc0208264:	00006697          	auipc	a3,0x6
ffffffffc0208268:	6ec68693          	addi	a3,a3,1772 # ffffffffc020e950 <syscalls+0xa40>
ffffffffc020826c:	00004617          	auipc	a2,0x4
ffffffffc0208270:	ab460613          	addi	a2,a2,-1356 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208274:	04f00593          	li	a1,79
ffffffffc0208278:	00006517          	auipc	a0,0x6
ffffffffc020827c:	6c050513          	addi	a0,a0,1728 # ffffffffc020e938 <syscalls+0xa28>
ffffffffc0208280:	faff70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208284 <vfs_lookup_parent>:
ffffffffc0208284:	7139                	addi	sp,sp,-64
ffffffffc0208286:	f822                	sd	s0,48(sp)
ffffffffc0208288:	f426                	sd	s1,40(sp)
ffffffffc020828a:	842e                	mv	s0,a1
ffffffffc020828c:	84b2                	mv	s1,a2
ffffffffc020828e:	002c                	addi	a1,sp,8
ffffffffc0208290:	0830                	addi	a2,sp,24
ffffffffc0208292:	fc06                	sd	ra,56(sp)
ffffffffc0208294:	e42a                	sd	a0,8(sp)
ffffffffc0208296:	e3fff0ef          	jal	ra,ffffffffc02080d4 <get_device>
ffffffffc020829a:	e509                	bnez	a0,ffffffffc02082a4 <vfs_lookup_parent+0x20>
ffffffffc020829c:	67a2                	ld	a5,8(sp)
ffffffffc020829e:	e09c                	sd	a5,0(s1)
ffffffffc02082a0:	67e2                	ld	a5,24(sp)
ffffffffc02082a2:	e01c                	sd	a5,0(s0)
ffffffffc02082a4:	70e2                	ld	ra,56(sp)
ffffffffc02082a6:	7442                	ld	s0,48(sp)
ffffffffc02082a8:	74a2                	ld	s1,40(sp)
ffffffffc02082aa:	6121                	addi	sp,sp,64
ffffffffc02082ac:	8082                	ret

ffffffffc02082ae <__alloc_inode>:
ffffffffc02082ae:	1141                	addi	sp,sp,-16
ffffffffc02082b0:	e022                	sd	s0,0(sp)
ffffffffc02082b2:	842a                	mv	s0,a0
ffffffffc02082b4:	07800513          	li	a0,120
ffffffffc02082b8:	e406                	sd	ra,8(sp)
ffffffffc02082ba:	e16fb0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc02082be:	c111                	beqz	a0,ffffffffc02082c2 <__alloc_inode+0x14>
ffffffffc02082c0:	cd20                	sw	s0,88(a0)
ffffffffc02082c2:	60a2                	ld	ra,8(sp)
ffffffffc02082c4:	6402                	ld	s0,0(sp)
ffffffffc02082c6:	0141                	addi	sp,sp,16
ffffffffc02082c8:	8082                	ret

ffffffffc02082ca <inode_init>:
ffffffffc02082ca:	4785                	li	a5,1
ffffffffc02082cc:	06052023          	sw	zero,96(a0)
ffffffffc02082d0:	f92c                	sd	a1,112(a0)
ffffffffc02082d2:	f530                	sd	a2,104(a0)
ffffffffc02082d4:	cd7c                	sw	a5,92(a0)
ffffffffc02082d6:	8082                	ret

ffffffffc02082d8 <inode_kill>:
ffffffffc02082d8:	4d78                	lw	a4,92(a0)
ffffffffc02082da:	1141                	addi	sp,sp,-16
ffffffffc02082dc:	e406                	sd	ra,8(sp)
ffffffffc02082de:	e719                	bnez	a4,ffffffffc02082ec <inode_kill+0x14>
ffffffffc02082e0:	513c                	lw	a5,96(a0)
ffffffffc02082e2:	e78d                	bnez	a5,ffffffffc020830c <inode_kill+0x34>
ffffffffc02082e4:	60a2                	ld	ra,8(sp)
ffffffffc02082e6:	0141                	addi	sp,sp,16
ffffffffc02082e8:	e98fb06f          	j	ffffffffc0203980 <kfree>
ffffffffc02082ec:	00006697          	auipc	a3,0x6
ffffffffc02082f0:	6bc68693          	addi	a3,a3,1724 # ffffffffc020e9a8 <syscalls+0xa98>
ffffffffc02082f4:	00004617          	auipc	a2,0x4
ffffffffc02082f8:	a2c60613          	addi	a2,a2,-1492 # ffffffffc020bd20 <commands+0x250>
ffffffffc02082fc:	02900593          	li	a1,41
ffffffffc0208300:	00006517          	auipc	a0,0x6
ffffffffc0208304:	6c850513          	addi	a0,a0,1736 # ffffffffc020e9c8 <syscalls+0xab8>
ffffffffc0208308:	f27f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020830c:	00006697          	auipc	a3,0x6
ffffffffc0208310:	6d468693          	addi	a3,a3,1748 # ffffffffc020e9e0 <syscalls+0xad0>
ffffffffc0208314:	00004617          	auipc	a2,0x4
ffffffffc0208318:	a0c60613          	addi	a2,a2,-1524 # ffffffffc020bd20 <commands+0x250>
ffffffffc020831c:	02a00593          	li	a1,42
ffffffffc0208320:	00006517          	auipc	a0,0x6
ffffffffc0208324:	6a850513          	addi	a0,a0,1704 # ffffffffc020e9c8 <syscalls+0xab8>
ffffffffc0208328:	f07f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020832c <inode_ref_inc>:
ffffffffc020832c:	4d7c                	lw	a5,92(a0)
ffffffffc020832e:	2785                	addiw	a5,a5,1
ffffffffc0208330:	cd7c                	sw	a5,92(a0)
ffffffffc0208332:	0007851b          	sext.w	a0,a5
ffffffffc0208336:	8082                	ret

ffffffffc0208338 <inode_open_inc>:
ffffffffc0208338:	513c                	lw	a5,96(a0)
ffffffffc020833a:	2785                	addiw	a5,a5,1
ffffffffc020833c:	d13c                	sw	a5,96(a0)
ffffffffc020833e:	0007851b          	sext.w	a0,a5
ffffffffc0208342:	8082                	ret

ffffffffc0208344 <inode_check>:
ffffffffc0208344:	1141                	addi	sp,sp,-16
ffffffffc0208346:	e406                	sd	ra,8(sp)
ffffffffc0208348:	c90d                	beqz	a0,ffffffffc020837a <inode_check+0x36>
ffffffffc020834a:	793c                	ld	a5,112(a0)
ffffffffc020834c:	c79d                	beqz	a5,ffffffffc020837a <inode_check+0x36>
ffffffffc020834e:	6398                	ld	a4,0(a5)
ffffffffc0208350:	4625d7b7          	lui	a5,0x4625d
ffffffffc0208354:	0786                	slli	a5,a5,0x1
ffffffffc0208356:	47678793          	addi	a5,a5,1142 # 4625d476 <_binary_bin_sfs_img_size+0x461e8176>
ffffffffc020835a:	08f71063          	bne	a4,a5,ffffffffc02083da <inode_check+0x96>
ffffffffc020835e:	4d78                	lw	a4,92(a0)
ffffffffc0208360:	513c                	lw	a5,96(a0)
ffffffffc0208362:	04f74c63          	blt	a4,a5,ffffffffc02083ba <inode_check+0x76>
ffffffffc0208366:	0407ca63          	bltz	a5,ffffffffc02083ba <inode_check+0x76>
ffffffffc020836a:	66c1                	lui	a3,0x10
ffffffffc020836c:	02d75763          	bge	a4,a3,ffffffffc020839a <inode_check+0x56>
ffffffffc0208370:	02d7d563          	bge	a5,a3,ffffffffc020839a <inode_check+0x56>
ffffffffc0208374:	60a2                	ld	ra,8(sp)
ffffffffc0208376:	0141                	addi	sp,sp,16
ffffffffc0208378:	8082                	ret
ffffffffc020837a:	00006697          	auipc	a3,0x6
ffffffffc020837e:	68668693          	addi	a3,a3,1670 # ffffffffc020ea00 <syscalls+0xaf0>
ffffffffc0208382:	00004617          	auipc	a2,0x4
ffffffffc0208386:	99e60613          	addi	a2,a2,-1634 # ffffffffc020bd20 <commands+0x250>
ffffffffc020838a:	06e00593          	li	a1,110
ffffffffc020838e:	00006517          	auipc	a0,0x6
ffffffffc0208392:	63a50513          	addi	a0,a0,1594 # ffffffffc020e9c8 <syscalls+0xab8>
ffffffffc0208396:	e99f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020839a:	00006697          	auipc	a3,0x6
ffffffffc020839e:	6e668693          	addi	a3,a3,1766 # ffffffffc020ea80 <syscalls+0xb70>
ffffffffc02083a2:	00004617          	auipc	a2,0x4
ffffffffc02083a6:	97e60613          	addi	a2,a2,-1666 # ffffffffc020bd20 <commands+0x250>
ffffffffc02083aa:	07200593          	li	a1,114
ffffffffc02083ae:	00006517          	auipc	a0,0x6
ffffffffc02083b2:	61a50513          	addi	a0,a0,1562 # ffffffffc020e9c8 <syscalls+0xab8>
ffffffffc02083b6:	e79f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02083ba:	00006697          	auipc	a3,0x6
ffffffffc02083be:	69668693          	addi	a3,a3,1686 # ffffffffc020ea50 <syscalls+0xb40>
ffffffffc02083c2:	00004617          	auipc	a2,0x4
ffffffffc02083c6:	95e60613          	addi	a2,a2,-1698 # ffffffffc020bd20 <commands+0x250>
ffffffffc02083ca:	07100593          	li	a1,113
ffffffffc02083ce:	00006517          	auipc	a0,0x6
ffffffffc02083d2:	5fa50513          	addi	a0,a0,1530 # ffffffffc020e9c8 <syscalls+0xab8>
ffffffffc02083d6:	e59f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02083da:	00006697          	auipc	a3,0x6
ffffffffc02083de:	64e68693          	addi	a3,a3,1614 # ffffffffc020ea28 <syscalls+0xb18>
ffffffffc02083e2:	00004617          	auipc	a2,0x4
ffffffffc02083e6:	93e60613          	addi	a2,a2,-1730 # ffffffffc020bd20 <commands+0x250>
ffffffffc02083ea:	06f00593          	li	a1,111
ffffffffc02083ee:	00006517          	auipc	a0,0x6
ffffffffc02083f2:	5da50513          	addi	a0,a0,1498 # ffffffffc020e9c8 <syscalls+0xab8>
ffffffffc02083f6:	e39f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02083fa <inode_ref_dec>:
ffffffffc02083fa:	4d7c                	lw	a5,92(a0)
ffffffffc02083fc:	1101                	addi	sp,sp,-32
ffffffffc02083fe:	ec06                	sd	ra,24(sp)
ffffffffc0208400:	e822                	sd	s0,16(sp)
ffffffffc0208402:	e426                	sd	s1,8(sp)
ffffffffc0208404:	e04a                	sd	s2,0(sp)
ffffffffc0208406:	06f05e63          	blez	a5,ffffffffc0208482 <inode_ref_dec+0x88>
ffffffffc020840a:	fff7849b          	addiw	s1,a5,-1
ffffffffc020840e:	cd64                	sw	s1,92(a0)
ffffffffc0208410:	842a                	mv	s0,a0
ffffffffc0208412:	e09d                	bnez	s1,ffffffffc0208438 <inode_ref_dec+0x3e>
ffffffffc0208414:	793c                	ld	a5,112(a0)
ffffffffc0208416:	c7b1                	beqz	a5,ffffffffc0208462 <inode_ref_dec+0x68>
ffffffffc0208418:	0487b903          	ld	s2,72(a5)
ffffffffc020841c:	04090363          	beqz	s2,ffffffffc0208462 <inode_ref_dec+0x68>
ffffffffc0208420:	00006597          	auipc	a1,0x6
ffffffffc0208424:	71058593          	addi	a1,a1,1808 # ffffffffc020eb30 <syscalls+0xc20>
ffffffffc0208428:	f1dff0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc020842c:	8522                	mv	a0,s0
ffffffffc020842e:	9902                	jalr	s2
ffffffffc0208430:	c501                	beqz	a0,ffffffffc0208438 <inode_ref_dec+0x3e>
ffffffffc0208432:	57c5                	li	a5,-15
ffffffffc0208434:	00f51963          	bne	a0,a5,ffffffffc0208446 <inode_ref_dec+0x4c>
ffffffffc0208438:	60e2                	ld	ra,24(sp)
ffffffffc020843a:	6442                	ld	s0,16(sp)
ffffffffc020843c:	6902                	ld	s2,0(sp)
ffffffffc020843e:	8526                	mv	a0,s1
ffffffffc0208440:	64a2                	ld	s1,8(sp)
ffffffffc0208442:	6105                	addi	sp,sp,32
ffffffffc0208444:	8082                	ret
ffffffffc0208446:	85aa                	mv	a1,a0
ffffffffc0208448:	00006517          	auipc	a0,0x6
ffffffffc020844c:	6f050513          	addi	a0,a0,1776 # ffffffffc020eb38 <syscalls+0xc28>
ffffffffc0208450:	cdbf70ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0208454:	60e2                	ld	ra,24(sp)
ffffffffc0208456:	6442                	ld	s0,16(sp)
ffffffffc0208458:	6902                	ld	s2,0(sp)
ffffffffc020845a:	8526                	mv	a0,s1
ffffffffc020845c:	64a2                	ld	s1,8(sp)
ffffffffc020845e:	6105                	addi	sp,sp,32
ffffffffc0208460:	8082                	ret
ffffffffc0208462:	00006697          	auipc	a3,0x6
ffffffffc0208466:	67e68693          	addi	a3,a3,1662 # ffffffffc020eae0 <syscalls+0xbd0>
ffffffffc020846a:	00004617          	auipc	a2,0x4
ffffffffc020846e:	8b660613          	addi	a2,a2,-1866 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208472:	04400593          	li	a1,68
ffffffffc0208476:	00006517          	auipc	a0,0x6
ffffffffc020847a:	55250513          	addi	a0,a0,1362 # ffffffffc020e9c8 <syscalls+0xab8>
ffffffffc020847e:	db1f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208482:	00006697          	auipc	a3,0x6
ffffffffc0208486:	63e68693          	addi	a3,a3,1598 # ffffffffc020eac0 <syscalls+0xbb0>
ffffffffc020848a:	00004617          	auipc	a2,0x4
ffffffffc020848e:	89660613          	addi	a2,a2,-1898 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208492:	03f00593          	li	a1,63
ffffffffc0208496:	00006517          	auipc	a0,0x6
ffffffffc020849a:	53250513          	addi	a0,a0,1330 # ffffffffc020e9c8 <syscalls+0xab8>
ffffffffc020849e:	d91f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02084a2 <inode_open_dec>:
ffffffffc02084a2:	513c                	lw	a5,96(a0)
ffffffffc02084a4:	1101                	addi	sp,sp,-32
ffffffffc02084a6:	ec06                	sd	ra,24(sp)
ffffffffc02084a8:	e822                	sd	s0,16(sp)
ffffffffc02084aa:	e426                	sd	s1,8(sp)
ffffffffc02084ac:	e04a                	sd	s2,0(sp)
ffffffffc02084ae:	06f05b63          	blez	a5,ffffffffc0208524 <inode_open_dec+0x82>
ffffffffc02084b2:	fff7849b          	addiw	s1,a5,-1
ffffffffc02084b6:	d124                	sw	s1,96(a0)
ffffffffc02084b8:	842a                	mv	s0,a0
ffffffffc02084ba:	e085                	bnez	s1,ffffffffc02084da <inode_open_dec+0x38>
ffffffffc02084bc:	793c                	ld	a5,112(a0)
ffffffffc02084be:	c3b9                	beqz	a5,ffffffffc0208504 <inode_open_dec+0x62>
ffffffffc02084c0:	0107b903          	ld	s2,16(a5)
ffffffffc02084c4:	04090063          	beqz	s2,ffffffffc0208504 <inode_open_dec+0x62>
ffffffffc02084c8:	00006597          	auipc	a1,0x6
ffffffffc02084cc:	70058593          	addi	a1,a1,1792 # ffffffffc020ebc8 <syscalls+0xcb8>
ffffffffc02084d0:	e75ff0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc02084d4:	8522                	mv	a0,s0
ffffffffc02084d6:	9902                	jalr	s2
ffffffffc02084d8:	e901                	bnez	a0,ffffffffc02084e8 <inode_open_dec+0x46>
ffffffffc02084da:	60e2                	ld	ra,24(sp)
ffffffffc02084dc:	6442                	ld	s0,16(sp)
ffffffffc02084de:	6902                	ld	s2,0(sp)
ffffffffc02084e0:	8526                	mv	a0,s1
ffffffffc02084e2:	64a2                	ld	s1,8(sp)
ffffffffc02084e4:	6105                	addi	sp,sp,32
ffffffffc02084e6:	8082                	ret
ffffffffc02084e8:	85aa                	mv	a1,a0
ffffffffc02084ea:	00006517          	auipc	a0,0x6
ffffffffc02084ee:	6e650513          	addi	a0,a0,1766 # ffffffffc020ebd0 <syscalls+0xcc0>
ffffffffc02084f2:	c39f70ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02084f6:	60e2                	ld	ra,24(sp)
ffffffffc02084f8:	6442                	ld	s0,16(sp)
ffffffffc02084fa:	6902                	ld	s2,0(sp)
ffffffffc02084fc:	8526                	mv	a0,s1
ffffffffc02084fe:	64a2                	ld	s1,8(sp)
ffffffffc0208500:	6105                	addi	sp,sp,32
ffffffffc0208502:	8082                	ret
ffffffffc0208504:	00006697          	auipc	a3,0x6
ffffffffc0208508:	67468693          	addi	a3,a3,1652 # ffffffffc020eb78 <syscalls+0xc68>
ffffffffc020850c:	00004617          	auipc	a2,0x4
ffffffffc0208510:	81460613          	addi	a2,a2,-2028 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208514:	06100593          	li	a1,97
ffffffffc0208518:	00006517          	auipc	a0,0x6
ffffffffc020851c:	4b050513          	addi	a0,a0,1200 # ffffffffc020e9c8 <syscalls+0xab8>
ffffffffc0208520:	d0ff70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208524:	00006697          	auipc	a3,0x6
ffffffffc0208528:	63468693          	addi	a3,a3,1588 # ffffffffc020eb58 <syscalls+0xc48>
ffffffffc020852c:	00003617          	auipc	a2,0x3
ffffffffc0208530:	7f460613          	addi	a2,a2,2036 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208534:	05c00593          	li	a1,92
ffffffffc0208538:	00006517          	auipc	a0,0x6
ffffffffc020853c:	49050513          	addi	a0,a0,1168 # ffffffffc020e9c8 <syscalls+0xab8>
ffffffffc0208540:	ceff70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208544 <vfs_open>:
ffffffffc0208544:	711d                	addi	sp,sp,-96
ffffffffc0208546:	e4a6                	sd	s1,72(sp)
ffffffffc0208548:	e0ca                	sd	s2,64(sp)
ffffffffc020854a:	fc4e                	sd	s3,56(sp)
ffffffffc020854c:	ec86                	sd	ra,88(sp)
ffffffffc020854e:	e8a2                	sd	s0,80(sp)
ffffffffc0208550:	f852                	sd	s4,48(sp)
ffffffffc0208552:	f456                	sd	s5,40(sp)
ffffffffc0208554:	0035f793          	andi	a5,a1,3
ffffffffc0208558:	84ae                	mv	s1,a1
ffffffffc020855a:	892a                	mv	s2,a0
ffffffffc020855c:	89b2                	mv	s3,a2
ffffffffc020855e:	0e078663          	beqz	a5,ffffffffc020864a <vfs_open+0x106>
ffffffffc0208562:	470d                	li	a4,3
ffffffffc0208564:	0105fa93          	andi	s5,a1,16
ffffffffc0208568:	0ce78f63          	beq	a5,a4,ffffffffc0208646 <vfs_open+0x102>
ffffffffc020856c:	002c                	addi	a1,sp,8
ffffffffc020856e:	854a                	mv	a0,s2
ffffffffc0208570:	c7fff0ef          	jal	ra,ffffffffc02081ee <vfs_lookup>
ffffffffc0208574:	842a                	mv	s0,a0
ffffffffc0208576:	0044fa13          	andi	s4,s1,4
ffffffffc020857a:	e159                	bnez	a0,ffffffffc0208600 <vfs_open+0xbc>
ffffffffc020857c:	00c4f793          	andi	a5,s1,12
ffffffffc0208580:	4731                	li	a4,12
ffffffffc0208582:	0ee78263          	beq	a5,a4,ffffffffc0208666 <vfs_open+0x122>
ffffffffc0208586:	6422                	ld	s0,8(sp)
ffffffffc0208588:	12040163          	beqz	s0,ffffffffc02086aa <vfs_open+0x166>
ffffffffc020858c:	783c                	ld	a5,112(s0)
ffffffffc020858e:	cff1                	beqz	a5,ffffffffc020866a <vfs_open+0x126>
ffffffffc0208590:	679c                	ld	a5,8(a5)
ffffffffc0208592:	cfe1                	beqz	a5,ffffffffc020866a <vfs_open+0x126>
ffffffffc0208594:	8522                	mv	a0,s0
ffffffffc0208596:	00006597          	auipc	a1,0x6
ffffffffc020859a:	72a58593          	addi	a1,a1,1834 # ffffffffc020ecc0 <syscalls+0xdb0>
ffffffffc020859e:	da7ff0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc02085a2:	783c                	ld	a5,112(s0)
ffffffffc02085a4:	6522                	ld	a0,8(sp)
ffffffffc02085a6:	85a6                	mv	a1,s1
ffffffffc02085a8:	679c                	ld	a5,8(a5)
ffffffffc02085aa:	9782                	jalr	a5
ffffffffc02085ac:	842a                	mv	s0,a0
ffffffffc02085ae:	6522                	ld	a0,8(sp)
ffffffffc02085b0:	e845                	bnez	s0,ffffffffc0208660 <vfs_open+0x11c>
ffffffffc02085b2:	015a6a33          	or	s4,s4,s5
ffffffffc02085b6:	d83ff0ef          	jal	ra,ffffffffc0208338 <inode_open_inc>
ffffffffc02085ba:	020a0663          	beqz	s4,ffffffffc02085e6 <vfs_open+0xa2>
ffffffffc02085be:	64a2                	ld	s1,8(sp)
ffffffffc02085c0:	c4e9                	beqz	s1,ffffffffc020868a <vfs_open+0x146>
ffffffffc02085c2:	78bc                	ld	a5,112(s1)
ffffffffc02085c4:	c3f9                	beqz	a5,ffffffffc020868a <vfs_open+0x146>
ffffffffc02085c6:	73bc                	ld	a5,96(a5)
ffffffffc02085c8:	c3e9                	beqz	a5,ffffffffc020868a <vfs_open+0x146>
ffffffffc02085ca:	00006597          	auipc	a1,0x6
ffffffffc02085ce:	75658593          	addi	a1,a1,1878 # ffffffffc020ed20 <syscalls+0xe10>
ffffffffc02085d2:	8526                	mv	a0,s1
ffffffffc02085d4:	d71ff0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc02085d8:	78bc                	ld	a5,112(s1)
ffffffffc02085da:	6522                	ld	a0,8(sp)
ffffffffc02085dc:	4581                	li	a1,0
ffffffffc02085de:	73bc                	ld	a5,96(a5)
ffffffffc02085e0:	9782                	jalr	a5
ffffffffc02085e2:	87aa                	mv	a5,a0
ffffffffc02085e4:	e92d                	bnez	a0,ffffffffc0208656 <vfs_open+0x112>
ffffffffc02085e6:	67a2                	ld	a5,8(sp)
ffffffffc02085e8:	00f9b023          	sd	a5,0(s3)
ffffffffc02085ec:	60e6                	ld	ra,88(sp)
ffffffffc02085ee:	8522                	mv	a0,s0
ffffffffc02085f0:	6446                	ld	s0,80(sp)
ffffffffc02085f2:	64a6                	ld	s1,72(sp)
ffffffffc02085f4:	6906                	ld	s2,64(sp)
ffffffffc02085f6:	79e2                	ld	s3,56(sp)
ffffffffc02085f8:	7a42                	ld	s4,48(sp)
ffffffffc02085fa:	7aa2                	ld	s5,40(sp)
ffffffffc02085fc:	6125                	addi	sp,sp,96
ffffffffc02085fe:	8082                	ret
ffffffffc0208600:	57c1                	li	a5,-16
ffffffffc0208602:	fef515e3          	bne	a0,a5,ffffffffc02085ec <vfs_open+0xa8>
ffffffffc0208606:	fe0a03e3          	beqz	s4,ffffffffc02085ec <vfs_open+0xa8>
ffffffffc020860a:	0810                	addi	a2,sp,16
ffffffffc020860c:	082c                	addi	a1,sp,24
ffffffffc020860e:	854a                	mv	a0,s2
ffffffffc0208610:	c75ff0ef          	jal	ra,ffffffffc0208284 <vfs_lookup_parent>
ffffffffc0208614:	842a                	mv	s0,a0
ffffffffc0208616:	f979                	bnez	a0,ffffffffc02085ec <vfs_open+0xa8>
ffffffffc0208618:	6462                	ld	s0,24(sp)
ffffffffc020861a:	c845                	beqz	s0,ffffffffc02086ca <vfs_open+0x186>
ffffffffc020861c:	783c                	ld	a5,112(s0)
ffffffffc020861e:	c7d5                	beqz	a5,ffffffffc02086ca <vfs_open+0x186>
ffffffffc0208620:	77bc                	ld	a5,104(a5)
ffffffffc0208622:	c7c5                	beqz	a5,ffffffffc02086ca <vfs_open+0x186>
ffffffffc0208624:	8522                	mv	a0,s0
ffffffffc0208626:	00006597          	auipc	a1,0x6
ffffffffc020862a:	63258593          	addi	a1,a1,1586 # ffffffffc020ec58 <syscalls+0xd48>
ffffffffc020862e:	d17ff0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc0208632:	783c                	ld	a5,112(s0)
ffffffffc0208634:	65c2                	ld	a1,16(sp)
ffffffffc0208636:	6562                	ld	a0,24(sp)
ffffffffc0208638:	77bc                	ld	a5,104(a5)
ffffffffc020863a:	4034d613          	srai	a2,s1,0x3
ffffffffc020863e:	0034                	addi	a3,sp,8
ffffffffc0208640:	8a05                	andi	a2,a2,1
ffffffffc0208642:	9782                	jalr	a5
ffffffffc0208644:	b789                	j	ffffffffc0208586 <vfs_open+0x42>
ffffffffc0208646:	5475                	li	s0,-3
ffffffffc0208648:	b755                	j	ffffffffc02085ec <vfs_open+0xa8>
ffffffffc020864a:	0105fa93          	andi	s5,a1,16
ffffffffc020864e:	5475                	li	s0,-3
ffffffffc0208650:	f80a9ee3          	bnez	s5,ffffffffc02085ec <vfs_open+0xa8>
ffffffffc0208654:	bf21                	j	ffffffffc020856c <vfs_open+0x28>
ffffffffc0208656:	6522                	ld	a0,8(sp)
ffffffffc0208658:	843e                	mv	s0,a5
ffffffffc020865a:	e49ff0ef          	jal	ra,ffffffffc02084a2 <inode_open_dec>
ffffffffc020865e:	6522                	ld	a0,8(sp)
ffffffffc0208660:	d9bff0ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc0208664:	b761                	j	ffffffffc02085ec <vfs_open+0xa8>
ffffffffc0208666:	5425                	li	s0,-23
ffffffffc0208668:	b751                	j	ffffffffc02085ec <vfs_open+0xa8>
ffffffffc020866a:	00006697          	auipc	a3,0x6
ffffffffc020866e:	60668693          	addi	a3,a3,1542 # ffffffffc020ec70 <syscalls+0xd60>
ffffffffc0208672:	00003617          	auipc	a2,0x3
ffffffffc0208676:	6ae60613          	addi	a2,a2,1710 # ffffffffc020bd20 <commands+0x250>
ffffffffc020867a:	03300593          	li	a1,51
ffffffffc020867e:	00006517          	auipc	a0,0x6
ffffffffc0208682:	5c250513          	addi	a0,a0,1474 # ffffffffc020ec40 <syscalls+0xd30>
ffffffffc0208686:	ba9f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020868a:	00006697          	auipc	a3,0x6
ffffffffc020868e:	63e68693          	addi	a3,a3,1598 # ffffffffc020ecc8 <syscalls+0xdb8>
ffffffffc0208692:	00003617          	auipc	a2,0x3
ffffffffc0208696:	68e60613          	addi	a2,a2,1678 # ffffffffc020bd20 <commands+0x250>
ffffffffc020869a:	03a00593          	li	a1,58
ffffffffc020869e:	00006517          	auipc	a0,0x6
ffffffffc02086a2:	5a250513          	addi	a0,a0,1442 # ffffffffc020ec40 <syscalls+0xd30>
ffffffffc02086a6:	b89f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02086aa:	00006697          	auipc	a3,0x6
ffffffffc02086ae:	5b668693          	addi	a3,a3,1462 # ffffffffc020ec60 <syscalls+0xd50>
ffffffffc02086b2:	00003617          	auipc	a2,0x3
ffffffffc02086b6:	66e60613          	addi	a2,a2,1646 # ffffffffc020bd20 <commands+0x250>
ffffffffc02086ba:	03100593          	li	a1,49
ffffffffc02086be:	00006517          	auipc	a0,0x6
ffffffffc02086c2:	58250513          	addi	a0,a0,1410 # ffffffffc020ec40 <syscalls+0xd30>
ffffffffc02086c6:	b69f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02086ca:	00006697          	auipc	a3,0x6
ffffffffc02086ce:	52668693          	addi	a3,a3,1318 # ffffffffc020ebf0 <syscalls+0xce0>
ffffffffc02086d2:	00003617          	auipc	a2,0x3
ffffffffc02086d6:	64e60613          	addi	a2,a2,1614 # ffffffffc020bd20 <commands+0x250>
ffffffffc02086da:	02c00593          	li	a1,44
ffffffffc02086de:	00006517          	auipc	a0,0x6
ffffffffc02086e2:	56250513          	addi	a0,a0,1378 # ffffffffc020ec40 <syscalls+0xd30>
ffffffffc02086e6:	b49f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02086ea <vfs_close>:
ffffffffc02086ea:	1141                	addi	sp,sp,-16
ffffffffc02086ec:	e406                	sd	ra,8(sp)
ffffffffc02086ee:	e022                	sd	s0,0(sp)
ffffffffc02086f0:	842a                	mv	s0,a0
ffffffffc02086f2:	db1ff0ef          	jal	ra,ffffffffc02084a2 <inode_open_dec>
ffffffffc02086f6:	8522                	mv	a0,s0
ffffffffc02086f8:	d03ff0ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc02086fc:	60a2                	ld	ra,8(sp)
ffffffffc02086fe:	6402                	ld	s0,0(sp)
ffffffffc0208700:	4501                	li	a0,0
ffffffffc0208702:	0141                	addi	sp,sp,16
ffffffffc0208704:	8082                	ret

ffffffffc0208706 <__alloc_fs>:
ffffffffc0208706:	1141                	addi	sp,sp,-16
ffffffffc0208708:	e022                	sd	s0,0(sp)
ffffffffc020870a:	842a                	mv	s0,a0
ffffffffc020870c:	0d800513          	li	a0,216
ffffffffc0208710:	e406                	sd	ra,8(sp)
ffffffffc0208712:	9befb0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0208716:	c119                	beqz	a0,ffffffffc020871c <__alloc_fs+0x16>
ffffffffc0208718:	0a852823          	sw	s0,176(a0)
ffffffffc020871c:	60a2                	ld	ra,8(sp)
ffffffffc020871e:	6402                	ld	s0,0(sp)
ffffffffc0208720:	0141                	addi	sp,sp,16
ffffffffc0208722:	8082                	ret

ffffffffc0208724 <vfs_init>:
ffffffffc0208724:	1141                	addi	sp,sp,-16
ffffffffc0208726:	4585                	li	a1,1
ffffffffc0208728:	0008d517          	auipc	a0,0x8d
ffffffffc020872c:	14050513          	addi	a0,a0,320 # ffffffffc0295868 <bootfs_sem>
ffffffffc0208730:	e406                	sd	ra,8(sp)
ffffffffc0208732:	91afc0ef          	jal	ra,ffffffffc020484c <sem_init>
ffffffffc0208736:	60a2                	ld	ra,8(sp)
ffffffffc0208738:	0141                	addi	sp,sp,16
ffffffffc020873a:	d0aff06f          	j	ffffffffc0207c44 <vfs_devlist_init>

ffffffffc020873e <vfs_set_bootfs>:
ffffffffc020873e:	7179                	addi	sp,sp,-48
ffffffffc0208740:	f022                	sd	s0,32(sp)
ffffffffc0208742:	f406                	sd	ra,40(sp)
ffffffffc0208744:	ec26                	sd	s1,24(sp)
ffffffffc0208746:	e402                	sd	zero,8(sp)
ffffffffc0208748:	842a                	mv	s0,a0
ffffffffc020874a:	c915                	beqz	a0,ffffffffc020877e <vfs_set_bootfs+0x40>
ffffffffc020874c:	03a00593          	li	a1,58
ffffffffc0208750:	3c7020ef          	jal	ra,ffffffffc020b316 <strchr>
ffffffffc0208754:	c135                	beqz	a0,ffffffffc02087b8 <vfs_set_bootfs+0x7a>
ffffffffc0208756:	00154783          	lbu	a5,1(a0)
ffffffffc020875a:	efb9                	bnez	a5,ffffffffc02087b8 <vfs_set_bootfs+0x7a>
ffffffffc020875c:	8522                	mv	a0,s0
ffffffffc020875e:	86bff0ef          	jal	ra,ffffffffc0207fc8 <vfs_chdir>
ffffffffc0208762:	842a                	mv	s0,a0
ffffffffc0208764:	c519                	beqz	a0,ffffffffc0208772 <vfs_set_bootfs+0x34>
ffffffffc0208766:	70a2                	ld	ra,40(sp)
ffffffffc0208768:	8522                	mv	a0,s0
ffffffffc020876a:	7402                	ld	s0,32(sp)
ffffffffc020876c:	64e2                	ld	s1,24(sp)
ffffffffc020876e:	6145                	addi	sp,sp,48
ffffffffc0208770:	8082                	ret
ffffffffc0208772:	0028                	addi	a0,sp,8
ffffffffc0208774:	f5eff0ef          	jal	ra,ffffffffc0207ed2 <vfs_get_curdir>
ffffffffc0208778:	842a                	mv	s0,a0
ffffffffc020877a:	f575                	bnez	a0,ffffffffc0208766 <vfs_set_bootfs+0x28>
ffffffffc020877c:	6422                	ld	s0,8(sp)
ffffffffc020877e:	0008d517          	auipc	a0,0x8d
ffffffffc0208782:	0ea50513          	addi	a0,a0,234 # ffffffffc0295868 <bootfs_sem>
ffffffffc0208786:	8d2fc0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc020878a:	0008e797          	auipc	a5,0x8e
ffffffffc020878e:	1ae78793          	addi	a5,a5,430 # ffffffffc0296938 <bootfs_node>
ffffffffc0208792:	6384                	ld	s1,0(a5)
ffffffffc0208794:	0008d517          	auipc	a0,0x8d
ffffffffc0208798:	0d450513          	addi	a0,a0,212 # ffffffffc0295868 <bootfs_sem>
ffffffffc020879c:	e380                	sd	s0,0(a5)
ffffffffc020879e:	4401                	li	s0,0
ffffffffc02087a0:	8b4fc0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc02087a4:	d0e9                	beqz	s1,ffffffffc0208766 <vfs_set_bootfs+0x28>
ffffffffc02087a6:	8526                	mv	a0,s1
ffffffffc02087a8:	c53ff0ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc02087ac:	70a2                	ld	ra,40(sp)
ffffffffc02087ae:	8522                	mv	a0,s0
ffffffffc02087b0:	7402                	ld	s0,32(sp)
ffffffffc02087b2:	64e2                	ld	s1,24(sp)
ffffffffc02087b4:	6145                	addi	sp,sp,48
ffffffffc02087b6:	8082                	ret
ffffffffc02087b8:	5475                	li	s0,-3
ffffffffc02087ba:	b775                	j	ffffffffc0208766 <vfs_set_bootfs+0x28>

ffffffffc02087bc <vfs_get_bootfs>:
ffffffffc02087bc:	1101                	addi	sp,sp,-32
ffffffffc02087be:	e426                	sd	s1,8(sp)
ffffffffc02087c0:	0008e497          	auipc	s1,0x8e
ffffffffc02087c4:	17848493          	addi	s1,s1,376 # ffffffffc0296938 <bootfs_node>
ffffffffc02087c8:	609c                	ld	a5,0(s1)
ffffffffc02087ca:	ec06                	sd	ra,24(sp)
ffffffffc02087cc:	e822                	sd	s0,16(sp)
ffffffffc02087ce:	c3a1                	beqz	a5,ffffffffc020880e <vfs_get_bootfs+0x52>
ffffffffc02087d0:	842a                	mv	s0,a0
ffffffffc02087d2:	0008d517          	auipc	a0,0x8d
ffffffffc02087d6:	09650513          	addi	a0,a0,150 # ffffffffc0295868 <bootfs_sem>
ffffffffc02087da:	87efc0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc02087de:	6084                	ld	s1,0(s1)
ffffffffc02087e0:	c08d                	beqz	s1,ffffffffc0208802 <vfs_get_bootfs+0x46>
ffffffffc02087e2:	8526                	mv	a0,s1
ffffffffc02087e4:	b49ff0ef          	jal	ra,ffffffffc020832c <inode_ref_inc>
ffffffffc02087e8:	0008d517          	auipc	a0,0x8d
ffffffffc02087ec:	08050513          	addi	a0,a0,128 # ffffffffc0295868 <bootfs_sem>
ffffffffc02087f0:	864fc0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc02087f4:	4501                	li	a0,0
ffffffffc02087f6:	e004                	sd	s1,0(s0)
ffffffffc02087f8:	60e2                	ld	ra,24(sp)
ffffffffc02087fa:	6442                	ld	s0,16(sp)
ffffffffc02087fc:	64a2                	ld	s1,8(sp)
ffffffffc02087fe:	6105                	addi	sp,sp,32
ffffffffc0208800:	8082                	ret
ffffffffc0208802:	0008d517          	auipc	a0,0x8d
ffffffffc0208806:	06650513          	addi	a0,a0,102 # ffffffffc0295868 <bootfs_sem>
ffffffffc020880a:	84afc0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020880e:	5541                	li	a0,-16
ffffffffc0208810:	b7e5                	j	ffffffffc02087f8 <vfs_get_bootfs+0x3c>

ffffffffc0208812 <stdin_open>:
ffffffffc0208812:	4501                	li	a0,0
ffffffffc0208814:	e191                	bnez	a1,ffffffffc0208818 <stdin_open+0x6>
ffffffffc0208816:	8082                	ret
ffffffffc0208818:	5575                	li	a0,-3
ffffffffc020881a:	8082                	ret

ffffffffc020881c <stdin_close>:
ffffffffc020881c:	4501                	li	a0,0
ffffffffc020881e:	8082                	ret

ffffffffc0208820 <stdin_ioctl>:
ffffffffc0208820:	5575                	li	a0,-3
ffffffffc0208822:	8082                	ret

ffffffffc0208824 <stdin_io>:
ffffffffc0208824:	7135                	addi	sp,sp,-160
ffffffffc0208826:	ed06                	sd	ra,152(sp)
ffffffffc0208828:	e922                	sd	s0,144(sp)
ffffffffc020882a:	e526                	sd	s1,136(sp)
ffffffffc020882c:	e14a                	sd	s2,128(sp)
ffffffffc020882e:	fcce                	sd	s3,120(sp)
ffffffffc0208830:	f8d2                	sd	s4,112(sp)
ffffffffc0208832:	f4d6                	sd	s5,104(sp)
ffffffffc0208834:	f0da                	sd	s6,96(sp)
ffffffffc0208836:	ecde                	sd	s7,88(sp)
ffffffffc0208838:	e8e2                	sd	s8,80(sp)
ffffffffc020883a:	e4e6                	sd	s9,72(sp)
ffffffffc020883c:	e0ea                	sd	s10,64(sp)
ffffffffc020883e:	fc6e                	sd	s11,56(sp)
ffffffffc0208840:	14061163          	bnez	a2,ffffffffc0208982 <stdin_io+0x15e>
ffffffffc0208844:	0005bd83          	ld	s11,0(a1)
ffffffffc0208848:	0185bd03          	ld	s10,24(a1)
ffffffffc020884c:	8b2e                	mv	s6,a1
ffffffffc020884e:	100027f3          	csrr	a5,sstatus
ffffffffc0208852:	8b89                	andi	a5,a5,2
ffffffffc0208854:	10079e63          	bnez	a5,ffffffffc0208970 <stdin_io+0x14c>
ffffffffc0208858:	4401                	li	s0,0
ffffffffc020885a:	100d0963          	beqz	s10,ffffffffc020896c <stdin_io+0x148>
ffffffffc020885e:	0008e997          	auipc	s3,0x8e
ffffffffc0208862:	0e298993          	addi	s3,s3,226 # ffffffffc0296940 <p_rpos>
ffffffffc0208866:	0009b783          	ld	a5,0(s3)
ffffffffc020886a:	800004b7          	lui	s1,0x80000
ffffffffc020886e:	6c85                	lui	s9,0x1
ffffffffc0208870:	4a81                	li	s5,0
ffffffffc0208872:	0008ea17          	auipc	s4,0x8e
ffffffffc0208876:	0d6a0a13          	addi	s4,s4,214 # ffffffffc0296948 <p_wpos>
ffffffffc020887a:	0491                	addi	s1,s1,4
ffffffffc020887c:	0008d917          	auipc	s2,0x8d
ffffffffc0208880:	00490913          	addi	s2,s2,4 # ffffffffc0295880 <__wait_queue>
ffffffffc0208884:	1cfd                	addi	s9,s9,-1
ffffffffc0208886:	000a3703          	ld	a4,0(s4)
ffffffffc020888a:	000a8c1b          	sext.w	s8,s5
ffffffffc020888e:	8be2                	mv	s7,s8
ffffffffc0208890:	02e7d763          	bge	a5,a4,ffffffffc02088be <stdin_io+0x9a>
ffffffffc0208894:	a859                	j	ffffffffc020892a <stdin_io+0x106>
ffffffffc0208896:	dbffe0ef          	jal	ra,ffffffffc0207654 <schedule>
ffffffffc020889a:	100027f3          	csrr	a5,sstatus
ffffffffc020889e:	8b89                	andi	a5,a5,2
ffffffffc02088a0:	4401                	li	s0,0
ffffffffc02088a2:	ef8d                	bnez	a5,ffffffffc02088dc <stdin_io+0xb8>
ffffffffc02088a4:	0028                	addi	a0,sp,8
ffffffffc02088a6:	ce3fb0ef          	jal	ra,ffffffffc0204588 <wait_in_queue>
ffffffffc02088aa:	e121                	bnez	a0,ffffffffc02088ea <stdin_io+0xc6>
ffffffffc02088ac:	47c2                	lw	a5,16(sp)
ffffffffc02088ae:	04979563          	bne	a5,s1,ffffffffc02088f8 <stdin_io+0xd4>
ffffffffc02088b2:	0009b783          	ld	a5,0(s3)
ffffffffc02088b6:	000a3703          	ld	a4,0(s4)
ffffffffc02088ba:	06e7c863          	blt	a5,a4,ffffffffc020892a <stdin_io+0x106>
ffffffffc02088be:	8626                	mv	a2,s1
ffffffffc02088c0:	002c                	addi	a1,sp,8
ffffffffc02088c2:	854a                	mv	a0,s2
ffffffffc02088c4:	deffb0ef          	jal	ra,ffffffffc02046b2 <wait_current_set>
ffffffffc02088c8:	d479                	beqz	s0,ffffffffc0208896 <stdin_io+0x72>
ffffffffc02088ca:	cd0f80ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc02088ce:	d87fe0ef          	jal	ra,ffffffffc0207654 <schedule>
ffffffffc02088d2:	100027f3          	csrr	a5,sstatus
ffffffffc02088d6:	8b89                	andi	a5,a5,2
ffffffffc02088d8:	4401                	li	s0,0
ffffffffc02088da:	d7e9                	beqz	a5,ffffffffc02088a4 <stdin_io+0x80>
ffffffffc02088dc:	cc4f80ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc02088e0:	0028                	addi	a0,sp,8
ffffffffc02088e2:	4405                	li	s0,1
ffffffffc02088e4:	ca5fb0ef          	jal	ra,ffffffffc0204588 <wait_in_queue>
ffffffffc02088e8:	d171                	beqz	a0,ffffffffc02088ac <stdin_io+0x88>
ffffffffc02088ea:	002c                	addi	a1,sp,8
ffffffffc02088ec:	854a                	mv	a0,s2
ffffffffc02088ee:	c41fb0ef          	jal	ra,ffffffffc020452e <wait_queue_del>
ffffffffc02088f2:	47c2                	lw	a5,16(sp)
ffffffffc02088f4:	fa978fe3          	beq	a5,s1,ffffffffc02088b2 <stdin_io+0x8e>
ffffffffc02088f8:	e435                	bnez	s0,ffffffffc0208964 <stdin_io+0x140>
ffffffffc02088fa:	060b8963          	beqz	s7,ffffffffc020896c <stdin_io+0x148>
ffffffffc02088fe:	018b3783          	ld	a5,24(s6)
ffffffffc0208902:	41578ab3          	sub	s5,a5,s5
ffffffffc0208906:	015b3c23          	sd	s5,24(s6)
ffffffffc020890a:	60ea                	ld	ra,152(sp)
ffffffffc020890c:	644a                	ld	s0,144(sp)
ffffffffc020890e:	64aa                	ld	s1,136(sp)
ffffffffc0208910:	690a                	ld	s2,128(sp)
ffffffffc0208912:	79e6                	ld	s3,120(sp)
ffffffffc0208914:	7a46                	ld	s4,112(sp)
ffffffffc0208916:	7aa6                	ld	s5,104(sp)
ffffffffc0208918:	7b06                	ld	s6,96(sp)
ffffffffc020891a:	6c46                	ld	s8,80(sp)
ffffffffc020891c:	6ca6                	ld	s9,72(sp)
ffffffffc020891e:	6d06                	ld	s10,64(sp)
ffffffffc0208920:	7de2                	ld	s11,56(sp)
ffffffffc0208922:	855e                	mv	a0,s7
ffffffffc0208924:	6be6                	ld	s7,88(sp)
ffffffffc0208926:	610d                	addi	sp,sp,160
ffffffffc0208928:	8082                	ret
ffffffffc020892a:	43f7d713          	srai	a4,a5,0x3f
ffffffffc020892e:	03475693          	srli	a3,a4,0x34
ffffffffc0208932:	00d78733          	add	a4,a5,a3
ffffffffc0208936:	01977733          	and	a4,a4,s9
ffffffffc020893a:	8f15                	sub	a4,a4,a3
ffffffffc020893c:	0008d697          	auipc	a3,0x8d
ffffffffc0208940:	f5468693          	addi	a3,a3,-172 # ffffffffc0295890 <stdin_buffer>
ffffffffc0208944:	9736                	add	a4,a4,a3
ffffffffc0208946:	00074683          	lbu	a3,0(a4)
ffffffffc020894a:	0785                	addi	a5,a5,1
ffffffffc020894c:	015d8733          	add	a4,s11,s5
ffffffffc0208950:	00d70023          	sb	a3,0(a4)
ffffffffc0208954:	00f9b023          	sd	a5,0(s3)
ffffffffc0208958:	0a85                	addi	s5,s5,1
ffffffffc020895a:	001c0b9b          	addiw	s7,s8,1
ffffffffc020895e:	f3aae4e3          	bltu	s5,s10,ffffffffc0208886 <stdin_io+0x62>
ffffffffc0208962:	dc51                	beqz	s0,ffffffffc02088fe <stdin_io+0xda>
ffffffffc0208964:	c36f80ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc0208968:	f80b9be3          	bnez	s7,ffffffffc02088fe <stdin_io+0xda>
ffffffffc020896c:	4b81                	li	s7,0
ffffffffc020896e:	bf71                	j	ffffffffc020890a <stdin_io+0xe6>
ffffffffc0208970:	c30f80ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0208974:	4405                	li	s0,1
ffffffffc0208976:	ee0d14e3          	bnez	s10,ffffffffc020885e <stdin_io+0x3a>
ffffffffc020897a:	c20f80ef          	jal	ra,ffffffffc0200d9a <intr_enable>
ffffffffc020897e:	4b81                	li	s7,0
ffffffffc0208980:	b769                	j	ffffffffc020890a <stdin_io+0xe6>
ffffffffc0208982:	5bf5                	li	s7,-3
ffffffffc0208984:	b759                	j	ffffffffc020890a <stdin_io+0xe6>

ffffffffc0208986 <dev_stdin_write>:
ffffffffc0208986:	e111                	bnez	a0,ffffffffc020898a <dev_stdin_write+0x4>
ffffffffc0208988:	8082                	ret
ffffffffc020898a:	1101                	addi	sp,sp,-32
ffffffffc020898c:	e822                	sd	s0,16(sp)
ffffffffc020898e:	ec06                	sd	ra,24(sp)
ffffffffc0208990:	e426                	sd	s1,8(sp)
ffffffffc0208992:	842a                	mv	s0,a0
ffffffffc0208994:	100027f3          	csrr	a5,sstatus
ffffffffc0208998:	8b89                	andi	a5,a5,2
ffffffffc020899a:	4481                	li	s1,0
ffffffffc020899c:	e3c1                	bnez	a5,ffffffffc0208a1c <dev_stdin_write+0x96>
ffffffffc020899e:	0008e597          	auipc	a1,0x8e
ffffffffc02089a2:	faa58593          	addi	a1,a1,-86 # ffffffffc0296948 <p_wpos>
ffffffffc02089a6:	6198                	ld	a4,0(a1)
ffffffffc02089a8:	6605                	lui	a2,0x1
ffffffffc02089aa:	fff60513          	addi	a0,a2,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc02089ae:	43f75693          	srai	a3,a4,0x3f
ffffffffc02089b2:	92d1                	srli	a3,a3,0x34
ffffffffc02089b4:	00d707b3          	add	a5,a4,a3
ffffffffc02089b8:	8fe9                	and	a5,a5,a0
ffffffffc02089ba:	8f95                	sub	a5,a5,a3
ffffffffc02089bc:	0008d697          	auipc	a3,0x8d
ffffffffc02089c0:	ed468693          	addi	a3,a3,-300 # ffffffffc0295890 <stdin_buffer>
ffffffffc02089c4:	97b6                	add	a5,a5,a3
ffffffffc02089c6:	00878023          	sb	s0,0(a5)
ffffffffc02089ca:	0008e797          	auipc	a5,0x8e
ffffffffc02089ce:	f767b783          	ld	a5,-138(a5) # ffffffffc0296940 <p_rpos>
ffffffffc02089d2:	40f707b3          	sub	a5,a4,a5
ffffffffc02089d6:	00c7d463          	bge	a5,a2,ffffffffc02089de <dev_stdin_write+0x58>
ffffffffc02089da:	0705                	addi	a4,a4,1
ffffffffc02089dc:	e198                	sd	a4,0(a1)
ffffffffc02089de:	0008d517          	auipc	a0,0x8d
ffffffffc02089e2:	ea250513          	addi	a0,a0,-350 # ffffffffc0295880 <__wait_queue>
ffffffffc02089e6:	b97fb0ef          	jal	ra,ffffffffc020457c <wait_queue_empty>
ffffffffc02089ea:	cd09                	beqz	a0,ffffffffc0208a04 <dev_stdin_write+0x7e>
ffffffffc02089ec:	e491                	bnez	s1,ffffffffc02089f8 <dev_stdin_write+0x72>
ffffffffc02089ee:	60e2                	ld	ra,24(sp)
ffffffffc02089f0:	6442                	ld	s0,16(sp)
ffffffffc02089f2:	64a2                	ld	s1,8(sp)
ffffffffc02089f4:	6105                	addi	sp,sp,32
ffffffffc02089f6:	8082                	ret
ffffffffc02089f8:	6442                	ld	s0,16(sp)
ffffffffc02089fa:	60e2                	ld	ra,24(sp)
ffffffffc02089fc:	64a2                	ld	s1,8(sp)
ffffffffc02089fe:	6105                	addi	sp,sp,32
ffffffffc0208a00:	b9af806f          	j	ffffffffc0200d9a <intr_enable>
ffffffffc0208a04:	800005b7          	lui	a1,0x80000
ffffffffc0208a08:	4605                	li	a2,1
ffffffffc0208a0a:	0591                	addi	a1,a1,4
ffffffffc0208a0c:	0008d517          	auipc	a0,0x8d
ffffffffc0208a10:	e7450513          	addi	a0,a0,-396 # ffffffffc0295880 <__wait_queue>
ffffffffc0208a14:	bd1fb0ef          	jal	ra,ffffffffc02045e4 <wakeup_queue>
ffffffffc0208a18:	d8f9                	beqz	s1,ffffffffc02089ee <dev_stdin_write+0x68>
ffffffffc0208a1a:	bff9                	j	ffffffffc02089f8 <dev_stdin_write+0x72>
ffffffffc0208a1c:	b84f80ef          	jal	ra,ffffffffc0200da0 <intr_disable>
ffffffffc0208a20:	4485                	li	s1,1
ffffffffc0208a22:	bfb5                	j	ffffffffc020899e <dev_stdin_write+0x18>

ffffffffc0208a24 <dev_init_stdin>:
ffffffffc0208a24:	1141                	addi	sp,sp,-16
ffffffffc0208a26:	e406                	sd	ra,8(sp)
ffffffffc0208a28:	e022                	sd	s0,0(sp)
ffffffffc0208a2a:	74a000ef          	jal	ra,ffffffffc0209174 <dev_create_inode>
ffffffffc0208a2e:	c93d                	beqz	a0,ffffffffc0208aa4 <dev_init_stdin+0x80>
ffffffffc0208a30:	4d38                	lw	a4,88(a0)
ffffffffc0208a32:	6785                	lui	a5,0x1
ffffffffc0208a34:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208a38:	842a                	mv	s0,a0
ffffffffc0208a3a:	08f71e63          	bne	a4,a5,ffffffffc0208ad6 <dev_init_stdin+0xb2>
ffffffffc0208a3e:	4785                	li	a5,1
ffffffffc0208a40:	e41c                	sd	a5,8(s0)
ffffffffc0208a42:	00000797          	auipc	a5,0x0
ffffffffc0208a46:	dd078793          	addi	a5,a5,-560 # ffffffffc0208812 <stdin_open>
ffffffffc0208a4a:	e81c                	sd	a5,16(s0)
ffffffffc0208a4c:	00000797          	auipc	a5,0x0
ffffffffc0208a50:	dd078793          	addi	a5,a5,-560 # ffffffffc020881c <stdin_close>
ffffffffc0208a54:	ec1c                	sd	a5,24(s0)
ffffffffc0208a56:	00000797          	auipc	a5,0x0
ffffffffc0208a5a:	dce78793          	addi	a5,a5,-562 # ffffffffc0208824 <stdin_io>
ffffffffc0208a5e:	f01c                	sd	a5,32(s0)
ffffffffc0208a60:	00000797          	auipc	a5,0x0
ffffffffc0208a64:	dc078793          	addi	a5,a5,-576 # ffffffffc0208820 <stdin_ioctl>
ffffffffc0208a68:	f41c                	sd	a5,40(s0)
ffffffffc0208a6a:	0008d517          	auipc	a0,0x8d
ffffffffc0208a6e:	e1650513          	addi	a0,a0,-490 # ffffffffc0295880 <__wait_queue>
ffffffffc0208a72:	00043023          	sd	zero,0(s0)
ffffffffc0208a76:	0008e797          	auipc	a5,0x8e
ffffffffc0208a7a:	ec07b923          	sd	zero,-302(a5) # ffffffffc0296948 <p_wpos>
ffffffffc0208a7e:	0008e797          	auipc	a5,0x8e
ffffffffc0208a82:	ec07b123          	sd	zero,-318(a5) # ffffffffc0296940 <p_rpos>
ffffffffc0208a86:	aa3fb0ef          	jal	ra,ffffffffc0204528 <wait_queue_init>
ffffffffc0208a8a:	4601                	li	a2,0
ffffffffc0208a8c:	85a2                	mv	a1,s0
ffffffffc0208a8e:	00006517          	auipc	a0,0x6
ffffffffc0208a92:	2e250513          	addi	a0,a0,738 # ffffffffc020ed70 <syscalls+0xe60>
ffffffffc0208a96:	b20ff0ef          	jal	ra,ffffffffc0207db6 <vfs_add_dev>
ffffffffc0208a9a:	e10d                	bnez	a0,ffffffffc0208abc <dev_init_stdin+0x98>
ffffffffc0208a9c:	60a2                	ld	ra,8(sp)
ffffffffc0208a9e:	6402                	ld	s0,0(sp)
ffffffffc0208aa0:	0141                	addi	sp,sp,16
ffffffffc0208aa2:	8082                	ret
ffffffffc0208aa4:	00006617          	auipc	a2,0x6
ffffffffc0208aa8:	28c60613          	addi	a2,a2,652 # ffffffffc020ed30 <syscalls+0xe20>
ffffffffc0208aac:	07500593          	li	a1,117
ffffffffc0208ab0:	00006517          	auipc	a0,0x6
ffffffffc0208ab4:	2a050513          	addi	a0,a0,672 # ffffffffc020ed50 <syscalls+0xe40>
ffffffffc0208ab8:	f76f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208abc:	86aa                	mv	a3,a0
ffffffffc0208abe:	00006617          	auipc	a2,0x6
ffffffffc0208ac2:	2ba60613          	addi	a2,a2,698 # ffffffffc020ed78 <syscalls+0xe68>
ffffffffc0208ac6:	07b00593          	li	a1,123
ffffffffc0208aca:	00006517          	auipc	a0,0x6
ffffffffc0208ace:	28650513          	addi	a0,a0,646 # ffffffffc020ed50 <syscalls+0xe40>
ffffffffc0208ad2:	f5cf70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208ad6:	00006697          	auipc	a3,0x6
ffffffffc0208ada:	d0268693          	addi	a3,a3,-766 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc0208ade:	00003617          	auipc	a2,0x3
ffffffffc0208ae2:	24260613          	addi	a2,a2,578 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208ae6:	07700593          	li	a1,119
ffffffffc0208aea:	00006517          	auipc	a0,0x6
ffffffffc0208aee:	26650513          	addi	a0,a0,614 # ffffffffc020ed50 <syscalls+0xe40>
ffffffffc0208af2:	f3cf70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208af6 <disk0_open>:
ffffffffc0208af6:	4501                	li	a0,0
ffffffffc0208af8:	8082                	ret

ffffffffc0208afa <disk0_close>:
ffffffffc0208afa:	4501                	li	a0,0
ffffffffc0208afc:	8082                	ret

ffffffffc0208afe <disk0_ioctl>:
ffffffffc0208afe:	5531                	li	a0,-20
ffffffffc0208b00:	8082                	ret

ffffffffc0208b02 <disk0_io>:
ffffffffc0208b02:	659c                	ld	a5,8(a1)
ffffffffc0208b04:	7159                	addi	sp,sp,-112
ffffffffc0208b06:	eca6                	sd	s1,88(sp)
ffffffffc0208b08:	f45e                	sd	s7,40(sp)
ffffffffc0208b0a:	6d84                	ld	s1,24(a1)
ffffffffc0208b0c:	6b85                	lui	s7,0x1
ffffffffc0208b0e:	1bfd                	addi	s7,s7,-1
ffffffffc0208b10:	e4ce                	sd	s3,72(sp)
ffffffffc0208b12:	43f7d993          	srai	s3,a5,0x3f
ffffffffc0208b16:	0179f9b3          	and	s3,s3,s7
ffffffffc0208b1a:	99be                	add	s3,s3,a5
ffffffffc0208b1c:	8fc5                	or	a5,a5,s1
ffffffffc0208b1e:	f486                	sd	ra,104(sp)
ffffffffc0208b20:	f0a2                	sd	s0,96(sp)
ffffffffc0208b22:	e8ca                	sd	s2,80(sp)
ffffffffc0208b24:	e0d2                	sd	s4,64(sp)
ffffffffc0208b26:	fc56                	sd	s5,56(sp)
ffffffffc0208b28:	f85a                	sd	s6,48(sp)
ffffffffc0208b2a:	f062                	sd	s8,32(sp)
ffffffffc0208b2c:	ec66                	sd	s9,24(sp)
ffffffffc0208b2e:	e86a                	sd	s10,16(sp)
ffffffffc0208b30:	0177f7b3          	and	a5,a5,s7
ffffffffc0208b34:	10079d63          	bnez	a5,ffffffffc0208c4e <disk0_io+0x14c>
ffffffffc0208b38:	40c9d993          	srai	s3,s3,0xc
ffffffffc0208b3c:	00c4d713          	srli	a4,s1,0xc
ffffffffc0208b40:	2981                	sext.w	s3,s3
ffffffffc0208b42:	2701                	sext.w	a4,a4
ffffffffc0208b44:	00e987bb          	addw	a5,s3,a4
ffffffffc0208b48:	6114                	ld	a3,0(a0)
ffffffffc0208b4a:	1782                	slli	a5,a5,0x20
ffffffffc0208b4c:	9381                	srli	a5,a5,0x20
ffffffffc0208b4e:	10f6e063          	bltu	a3,a5,ffffffffc0208c4e <disk0_io+0x14c>
ffffffffc0208b52:	4501                	li	a0,0
ffffffffc0208b54:	ef19                	bnez	a4,ffffffffc0208b72 <disk0_io+0x70>
ffffffffc0208b56:	70a6                	ld	ra,104(sp)
ffffffffc0208b58:	7406                	ld	s0,96(sp)
ffffffffc0208b5a:	64e6                	ld	s1,88(sp)
ffffffffc0208b5c:	6946                	ld	s2,80(sp)
ffffffffc0208b5e:	69a6                	ld	s3,72(sp)
ffffffffc0208b60:	6a06                	ld	s4,64(sp)
ffffffffc0208b62:	7ae2                	ld	s5,56(sp)
ffffffffc0208b64:	7b42                	ld	s6,48(sp)
ffffffffc0208b66:	7ba2                	ld	s7,40(sp)
ffffffffc0208b68:	7c02                	ld	s8,32(sp)
ffffffffc0208b6a:	6ce2                	ld	s9,24(sp)
ffffffffc0208b6c:	6d42                	ld	s10,16(sp)
ffffffffc0208b6e:	6165                	addi	sp,sp,112
ffffffffc0208b70:	8082                	ret
ffffffffc0208b72:	0008e517          	auipc	a0,0x8e
ffffffffc0208b76:	d1e50513          	addi	a0,a0,-738 # ffffffffc0296890 <disk0_sem>
ffffffffc0208b7a:	8b2e                	mv	s6,a1
ffffffffc0208b7c:	8c32                	mv	s8,a2
ffffffffc0208b7e:	0008ea97          	auipc	s5,0x8e
ffffffffc0208b82:	dd2a8a93          	addi	s5,s5,-558 # ffffffffc0296950 <disk0_buffer>
ffffffffc0208b86:	cd3fb0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc0208b8a:	6c91                	lui	s9,0x4
ffffffffc0208b8c:	e4b9                	bnez	s1,ffffffffc0208bda <disk0_io+0xd8>
ffffffffc0208b8e:	a845                	j	ffffffffc0208c3e <disk0_io+0x13c>
ffffffffc0208b90:	00c4d413          	srli	s0,s1,0xc
ffffffffc0208b94:	0034169b          	slliw	a3,s0,0x3
ffffffffc0208b98:	00068d1b          	sext.w	s10,a3
ffffffffc0208b9c:	1682                	slli	a3,a3,0x20
ffffffffc0208b9e:	2401                	sext.w	s0,s0
ffffffffc0208ba0:	9281                	srli	a3,a3,0x20
ffffffffc0208ba2:	8926                	mv	s2,s1
ffffffffc0208ba4:	00399a1b          	slliw	s4,s3,0x3
ffffffffc0208ba8:	862e                	mv	a2,a1
ffffffffc0208baa:	4509                	li	a0,2
ffffffffc0208bac:	85d2                	mv	a1,s4
ffffffffc0208bae:	8c0f80ef          	jal	ra,ffffffffc0200c6e <ide_read_secs>
ffffffffc0208bb2:	e165                	bnez	a0,ffffffffc0208c92 <disk0_io+0x190>
ffffffffc0208bb4:	000ab583          	ld	a1,0(s5)
ffffffffc0208bb8:	0038                	addi	a4,sp,8
ffffffffc0208bba:	4685                	li	a3,1
ffffffffc0208bbc:	864a                	mv	a2,s2
ffffffffc0208bbe:	855a                	mv	a0,s6
ffffffffc0208bc0:	c85fc0ef          	jal	ra,ffffffffc0205844 <iobuf_move>
ffffffffc0208bc4:	67a2                	ld	a5,8(sp)
ffffffffc0208bc6:	09279663          	bne	a5,s2,ffffffffc0208c52 <disk0_io+0x150>
ffffffffc0208bca:	017977b3          	and	a5,s2,s7
ffffffffc0208bce:	e3d1                	bnez	a5,ffffffffc0208c52 <disk0_io+0x150>
ffffffffc0208bd0:	412484b3          	sub	s1,s1,s2
ffffffffc0208bd4:	013409bb          	addw	s3,s0,s3
ffffffffc0208bd8:	c0bd                	beqz	s1,ffffffffc0208c3e <disk0_io+0x13c>
ffffffffc0208bda:	000ab583          	ld	a1,0(s5)
ffffffffc0208bde:	000c1b63          	bnez	s8,ffffffffc0208bf4 <disk0_io+0xf2>
ffffffffc0208be2:	fb94e7e3          	bltu	s1,s9,ffffffffc0208b90 <disk0_io+0x8e>
ffffffffc0208be6:	02000693          	li	a3,32
ffffffffc0208bea:	02000d13          	li	s10,32
ffffffffc0208bee:	4411                	li	s0,4
ffffffffc0208bf0:	6911                	lui	s2,0x4
ffffffffc0208bf2:	bf4d                	j	ffffffffc0208ba4 <disk0_io+0xa2>
ffffffffc0208bf4:	0038                	addi	a4,sp,8
ffffffffc0208bf6:	4681                	li	a3,0
ffffffffc0208bf8:	6611                	lui	a2,0x4
ffffffffc0208bfa:	855a                	mv	a0,s6
ffffffffc0208bfc:	c49fc0ef          	jal	ra,ffffffffc0205844 <iobuf_move>
ffffffffc0208c00:	6422                	ld	s0,8(sp)
ffffffffc0208c02:	c825                	beqz	s0,ffffffffc0208c72 <disk0_io+0x170>
ffffffffc0208c04:	0684e763          	bltu	s1,s0,ffffffffc0208c72 <disk0_io+0x170>
ffffffffc0208c08:	017477b3          	and	a5,s0,s7
ffffffffc0208c0c:	e3bd                	bnez	a5,ffffffffc0208c72 <disk0_io+0x170>
ffffffffc0208c0e:	8031                	srli	s0,s0,0xc
ffffffffc0208c10:	0034179b          	slliw	a5,s0,0x3
ffffffffc0208c14:	000ab603          	ld	a2,0(s5)
ffffffffc0208c18:	0039991b          	slliw	s2,s3,0x3
ffffffffc0208c1c:	02079693          	slli	a3,a5,0x20
ffffffffc0208c20:	9281                	srli	a3,a3,0x20
ffffffffc0208c22:	85ca                	mv	a1,s2
ffffffffc0208c24:	4509                	li	a0,2
ffffffffc0208c26:	2401                	sext.w	s0,s0
ffffffffc0208c28:	00078a1b          	sext.w	s4,a5
ffffffffc0208c2c:	8d8f80ef          	jal	ra,ffffffffc0200d04 <ide_write_secs>
ffffffffc0208c30:	e151                	bnez	a0,ffffffffc0208cb4 <disk0_io+0x1b2>
ffffffffc0208c32:	6922                	ld	s2,8(sp)
ffffffffc0208c34:	013409bb          	addw	s3,s0,s3
ffffffffc0208c38:	412484b3          	sub	s1,s1,s2
ffffffffc0208c3c:	fcd9                	bnez	s1,ffffffffc0208bda <disk0_io+0xd8>
ffffffffc0208c3e:	0008e517          	auipc	a0,0x8e
ffffffffc0208c42:	c5250513          	addi	a0,a0,-942 # ffffffffc0296890 <disk0_sem>
ffffffffc0208c46:	c0ffb0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0208c4a:	4501                	li	a0,0
ffffffffc0208c4c:	b729                	j	ffffffffc0208b56 <disk0_io+0x54>
ffffffffc0208c4e:	5575                	li	a0,-3
ffffffffc0208c50:	b719                	j	ffffffffc0208b56 <disk0_io+0x54>
ffffffffc0208c52:	00006697          	auipc	a3,0x6
ffffffffc0208c56:	23e68693          	addi	a3,a3,574 # ffffffffc020ee90 <syscalls+0xf80>
ffffffffc0208c5a:	00003617          	auipc	a2,0x3
ffffffffc0208c5e:	0c660613          	addi	a2,a2,198 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208c62:	06200593          	li	a1,98
ffffffffc0208c66:	00006517          	auipc	a0,0x6
ffffffffc0208c6a:	17250513          	addi	a0,a0,370 # ffffffffc020edd8 <syscalls+0xec8>
ffffffffc0208c6e:	dc0f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208c72:	00006697          	auipc	a3,0x6
ffffffffc0208c76:	12668693          	addi	a3,a3,294 # ffffffffc020ed98 <syscalls+0xe88>
ffffffffc0208c7a:	00003617          	auipc	a2,0x3
ffffffffc0208c7e:	0a660613          	addi	a2,a2,166 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208c82:	05700593          	li	a1,87
ffffffffc0208c86:	00006517          	auipc	a0,0x6
ffffffffc0208c8a:	15250513          	addi	a0,a0,338 # ffffffffc020edd8 <syscalls+0xec8>
ffffffffc0208c8e:	da0f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208c92:	88aa                	mv	a7,a0
ffffffffc0208c94:	886a                	mv	a6,s10
ffffffffc0208c96:	87a2                	mv	a5,s0
ffffffffc0208c98:	8752                	mv	a4,s4
ffffffffc0208c9a:	86ce                	mv	a3,s3
ffffffffc0208c9c:	00006617          	auipc	a2,0x6
ffffffffc0208ca0:	1ac60613          	addi	a2,a2,428 # ffffffffc020ee48 <syscalls+0xf38>
ffffffffc0208ca4:	02d00593          	li	a1,45
ffffffffc0208ca8:	00006517          	auipc	a0,0x6
ffffffffc0208cac:	13050513          	addi	a0,a0,304 # ffffffffc020edd8 <syscalls+0xec8>
ffffffffc0208cb0:	d7ef70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208cb4:	88aa                	mv	a7,a0
ffffffffc0208cb6:	8852                	mv	a6,s4
ffffffffc0208cb8:	87a2                	mv	a5,s0
ffffffffc0208cba:	874a                	mv	a4,s2
ffffffffc0208cbc:	86ce                	mv	a3,s3
ffffffffc0208cbe:	00006617          	auipc	a2,0x6
ffffffffc0208cc2:	13a60613          	addi	a2,a2,314 # ffffffffc020edf8 <syscalls+0xee8>
ffffffffc0208cc6:	03700593          	li	a1,55
ffffffffc0208cca:	00006517          	auipc	a0,0x6
ffffffffc0208cce:	10e50513          	addi	a0,a0,270 # ffffffffc020edd8 <syscalls+0xec8>
ffffffffc0208cd2:	d5cf70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208cd6 <dev_init_disk0>:
ffffffffc0208cd6:	1101                	addi	sp,sp,-32
ffffffffc0208cd8:	ec06                	sd	ra,24(sp)
ffffffffc0208cda:	e822                	sd	s0,16(sp)
ffffffffc0208cdc:	e426                	sd	s1,8(sp)
ffffffffc0208cde:	496000ef          	jal	ra,ffffffffc0209174 <dev_create_inode>
ffffffffc0208ce2:	c541                	beqz	a0,ffffffffc0208d6a <dev_init_disk0+0x94>
ffffffffc0208ce4:	4d38                	lw	a4,88(a0)
ffffffffc0208ce6:	6485                	lui	s1,0x1
ffffffffc0208ce8:	23448793          	addi	a5,s1,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208cec:	842a                	mv	s0,a0
ffffffffc0208cee:	0cf71f63          	bne	a4,a5,ffffffffc0208dcc <dev_init_disk0+0xf6>
ffffffffc0208cf2:	4509                	li	a0,2
ffffffffc0208cf4:	f2ff70ef          	jal	ra,ffffffffc0200c22 <ide_device_valid>
ffffffffc0208cf8:	cd55                	beqz	a0,ffffffffc0208db4 <dev_init_disk0+0xde>
ffffffffc0208cfa:	4509                	li	a0,2
ffffffffc0208cfc:	f4bf70ef          	jal	ra,ffffffffc0200c46 <ide_device_size>
ffffffffc0208d00:	00355793          	srli	a5,a0,0x3
ffffffffc0208d04:	e01c                	sd	a5,0(s0)
ffffffffc0208d06:	00000797          	auipc	a5,0x0
ffffffffc0208d0a:	df078793          	addi	a5,a5,-528 # ffffffffc0208af6 <disk0_open>
ffffffffc0208d0e:	e81c                	sd	a5,16(s0)
ffffffffc0208d10:	00000797          	auipc	a5,0x0
ffffffffc0208d14:	dea78793          	addi	a5,a5,-534 # ffffffffc0208afa <disk0_close>
ffffffffc0208d18:	ec1c                	sd	a5,24(s0)
ffffffffc0208d1a:	00000797          	auipc	a5,0x0
ffffffffc0208d1e:	de878793          	addi	a5,a5,-536 # ffffffffc0208b02 <disk0_io>
ffffffffc0208d22:	f01c                	sd	a5,32(s0)
ffffffffc0208d24:	00000797          	auipc	a5,0x0
ffffffffc0208d28:	dda78793          	addi	a5,a5,-550 # ffffffffc0208afe <disk0_ioctl>
ffffffffc0208d2c:	f41c                	sd	a5,40(s0)
ffffffffc0208d2e:	4585                	li	a1,1
ffffffffc0208d30:	0008e517          	auipc	a0,0x8e
ffffffffc0208d34:	b6050513          	addi	a0,a0,-1184 # ffffffffc0296890 <disk0_sem>
ffffffffc0208d38:	e404                	sd	s1,8(s0)
ffffffffc0208d3a:	b13fb0ef          	jal	ra,ffffffffc020484c <sem_init>
ffffffffc0208d3e:	6511                	lui	a0,0x4
ffffffffc0208d40:	b91fa0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0208d44:	0008e797          	auipc	a5,0x8e
ffffffffc0208d48:	c0a7b623          	sd	a0,-1012(a5) # ffffffffc0296950 <disk0_buffer>
ffffffffc0208d4c:	c921                	beqz	a0,ffffffffc0208d9c <dev_init_disk0+0xc6>
ffffffffc0208d4e:	4605                	li	a2,1
ffffffffc0208d50:	85a2                	mv	a1,s0
ffffffffc0208d52:	00006517          	auipc	a0,0x6
ffffffffc0208d56:	1ce50513          	addi	a0,a0,462 # ffffffffc020ef20 <syscalls+0x1010>
ffffffffc0208d5a:	85cff0ef          	jal	ra,ffffffffc0207db6 <vfs_add_dev>
ffffffffc0208d5e:	e115                	bnez	a0,ffffffffc0208d82 <dev_init_disk0+0xac>
ffffffffc0208d60:	60e2                	ld	ra,24(sp)
ffffffffc0208d62:	6442                	ld	s0,16(sp)
ffffffffc0208d64:	64a2                	ld	s1,8(sp)
ffffffffc0208d66:	6105                	addi	sp,sp,32
ffffffffc0208d68:	8082                	ret
ffffffffc0208d6a:	00006617          	auipc	a2,0x6
ffffffffc0208d6e:	15660613          	addi	a2,a2,342 # ffffffffc020eec0 <syscalls+0xfb0>
ffffffffc0208d72:	08700593          	li	a1,135
ffffffffc0208d76:	00006517          	auipc	a0,0x6
ffffffffc0208d7a:	06250513          	addi	a0,a0,98 # ffffffffc020edd8 <syscalls+0xec8>
ffffffffc0208d7e:	cb0f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208d82:	86aa                	mv	a3,a0
ffffffffc0208d84:	00006617          	auipc	a2,0x6
ffffffffc0208d88:	1a460613          	addi	a2,a2,420 # ffffffffc020ef28 <syscalls+0x1018>
ffffffffc0208d8c:	08d00593          	li	a1,141
ffffffffc0208d90:	00006517          	auipc	a0,0x6
ffffffffc0208d94:	04850513          	addi	a0,a0,72 # ffffffffc020edd8 <syscalls+0xec8>
ffffffffc0208d98:	c96f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208d9c:	00006617          	auipc	a2,0x6
ffffffffc0208da0:	16460613          	addi	a2,a2,356 # ffffffffc020ef00 <syscalls+0xff0>
ffffffffc0208da4:	07f00593          	li	a1,127
ffffffffc0208da8:	00006517          	auipc	a0,0x6
ffffffffc0208dac:	03050513          	addi	a0,a0,48 # ffffffffc020edd8 <syscalls+0xec8>
ffffffffc0208db0:	c7ef70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208db4:	00006617          	auipc	a2,0x6
ffffffffc0208db8:	12c60613          	addi	a2,a2,300 # ffffffffc020eee0 <syscalls+0xfd0>
ffffffffc0208dbc:	07300593          	li	a1,115
ffffffffc0208dc0:	00006517          	auipc	a0,0x6
ffffffffc0208dc4:	01850513          	addi	a0,a0,24 # ffffffffc020edd8 <syscalls+0xec8>
ffffffffc0208dc8:	c66f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208dcc:	00006697          	auipc	a3,0x6
ffffffffc0208dd0:	a0c68693          	addi	a3,a3,-1524 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc0208dd4:	00003617          	auipc	a2,0x3
ffffffffc0208dd8:	f4c60613          	addi	a2,a2,-180 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208ddc:	08900593          	li	a1,137
ffffffffc0208de0:	00006517          	auipc	a0,0x6
ffffffffc0208de4:	ff850513          	addi	a0,a0,-8 # ffffffffc020edd8 <syscalls+0xec8>
ffffffffc0208de8:	c46f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208dec <stdout_open>:
ffffffffc0208dec:	4785                	li	a5,1
ffffffffc0208dee:	4501                	li	a0,0
ffffffffc0208df0:	00f59363          	bne	a1,a5,ffffffffc0208df6 <stdout_open+0xa>
ffffffffc0208df4:	8082                	ret
ffffffffc0208df6:	5575                	li	a0,-3
ffffffffc0208df8:	8082                	ret

ffffffffc0208dfa <stdout_close>:
ffffffffc0208dfa:	4501                	li	a0,0
ffffffffc0208dfc:	8082                	ret

ffffffffc0208dfe <stdout_ioctl>:
ffffffffc0208dfe:	5575                	li	a0,-3
ffffffffc0208e00:	8082                	ret

ffffffffc0208e02 <stdout_io>:
ffffffffc0208e02:	ca05                	beqz	a2,ffffffffc0208e32 <stdout_io+0x30>
ffffffffc0208e04:	6d9c                	ld	a5,24(a1)
ffffffffc0208e06:	1101                	addi	sp,sp,-32
ffffffffc0208e08:	e822                	sd	s0,16(sp)
ffffffffc0208e0a:	e426                	sd	s1,8(sp)
ffffffffc0208e0c:	ec06                	sd	ra,24(sp)
ffffffffc0208e0e:	6180                	ld	s0,0(a1)
ffffffffc0208e10:	84ae                	mv	s1,a1
ffffffffc0208e12:	cb91                	beqz	a5,ffffffffc0208e26 <stdout_io+0x24>
ffffffffc0208e14:	00044503          	lbu	a0,0(s0)
ffffffffc0208e18:	0405                	addi	s0,s0,1
ffffffffc0208e1a:	b4cf70ef          	jal	ra,ffffffffc0200166 <cputchar>
ffffffffc0208e1e:	6c9c                	ld	a5,24(s1)
ffffffffc0208e20:	17fd                	addi	a5,a5,-1
ffffffffc0208e22:	ec9c                	sd	a5,24(s1)
ffffffffc0208e24:	fbe5                	bnez	a5,ffffffffc0208e14 <stdout_io+0x12>
ffffffffc0208e26:	60e2                	ld	ra,24(sp)
ffffffffc0208e28:	6442                	ld	s0,16(sp)
ffffffffc0208e2a:	64a2                	ld	s1,8(sp)
ffffffffc0208e2c:	4501                	li	a0,0
ffffffffc0208e2e:	6105                	addi	sp,sp,32
ffffffffc0208e30:	8082                	ret
ffffffffc0208e32:	5575                	li	a0,-3
ffffffffc0208e34:	8082                	ret

ffffffffc0208e36 <dev_init_stdout>:
ffffffffc0208e36:	1141                	addi	sp,sp,-16
ffffffffc0208e38:	e406                	sd	ra,8(sp)
ffffffffc0208e3a:	33a000ef          	jal	ra,ffffffffc0209174 <dev_create_inode>
ffffffffc0208e3e:	c939                	beqz	a0,ffffffffc0208e94 <dev_init_stdout+0x5e>
ffffffffc0208e40:	4d38                	lw	a4,88(a0)
ffffffffc0208e42:	6785                	lui	a5,0x1
ffffffffc0208e44:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208e48:	85aa                	mv	a1,a0
ffffffffc0208e4a:	06f71e63          	bne	a4,a5,ffffffffc0208ec6 <dev_init_stdout+0x90>
ffffffffc0208e4e:	4785                	li	a5,1
ffffffffc0208e50:	e51c                	sd	a5,8(a0)
ffffffffc0208e52:	00000797          	auipc	a5,0x0
ffffffffc0208e56:	f9a78793          	addi	a5,a5,-102 # ffffffffc0208dec <stdout_open>
ffffffffc0208e5a:	e91c                	sd	a5,16(a0)
ffffffffc0208e5c:	00000797          	auipc	a5,0x0
ffffffffc0208e60:	f9e78793          	addi	a5,a5,-98 # ffffffffc0208dfa <stdout_close>
ffffffffc0208e64:	ed1c                	sd	a5,24(a0)
ffffffffc0208e66:	00000797          	auipc	a5,0x0
ffffffffc0208e6a:	f9c78793          	addi	a5,a5,-100 # ffffffffc0208e02 <stdout_io>
ffffffffc0208e6e:	f11c                	sd	a5,32(a0)
ffffffffc0208e70:	00000797          	auipc	a5,0x0
ffffffffc0208e74:	f8e78793          	addi	a5,a5,-114 # ffffffffc0208dfe <stdout_ioctl>
ffffffffc0208e78:	00053023          	sd	zero,0(a0)
ffffffffc0208e7c:	f51c                	sd	a5,40(a0)
ffffffffc0208e7e:	4601                	li	a2,0
ffffffffc0208e80:	00006517          	auipc	a0,0x6
ffffffffc0208e84:	10850513          	addi	a0,a0,264 # ffffffffc020ef88 <syscalls+0x1078>
ffffffffc0208e88:	f2ffe0ef          	jal	ra,ffffffffc0207db6 <vfs_add_dev>
ffffffffc0208e8c:	e105                	bnez	a0,ffffffffc0208eac <dev_init_stdout+0x76>
ffffffffc0208e8e:	60a2                	ld	ra,8(sp)
ffffffffc0208e90:	0141                	addi	sp,sp,16
ffffffffc0208e92:	8082                	ret
ffffffffc0208e94:	00006617          	auipc	a2,0x6
ffffffffc0208e98:	0b460613          	addi	a2,a2,180 # ffffffffc020ef48 <syscalls+0x1038>
ffffffffc0208e9c:	03700593          	li	a1,55
ffffffffc0208ea0:	00006517          	auipc	a0,0x6
ffffffffc0208ea4:	0c850513          	addi	a0,a0,200 # ffffffffc020ef68 <syscalls+0x1058>
ffffffffc0208ea8:	b86f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208eac:	86aa                	mv	a3,a0
ffffffffc0208eae:	00006617          	auipc	a2,0x6
ffffffffc0208eb2:	0e260613          	addi	a2,a2,226 # ffffffffc020ef90 <syscalls+0x1080>
ffffffffc0208eb6:	03d00593          	li	a1,61
ffffffffc0208eba:	00006517          	auipc	a0,0x6
ffffffffc0208ebe:	0ae50513          	addi	a0,a0,174 # ffffffffc020ef68 <syscalls+0x1058>
ffffffffc0208ec2:	b6cf70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208ec6:	00006697          	auipc	a3,0x6
ffffffffc0208eca:	91268693          	addi	a3,a3,-1774 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc0208ece:	00003617          	auipc	a2,0x3
ffffffffc0208ed2:	e5260613          	addi	a2,a2,-430 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208ed6:	03900593          	li	a1,57
ffffffffc0208eda:	00006517          	auipc	a0,0x6
ffffffffc0208ede:	08e50513          	addi	a0,a0,142 # ffffffffc020ef68 <syscalls+0x1058>
ffffffffc0208ee2:	b4cf70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208ee6 <dev_lookup>:
ffffffffc0208ee6:	0005c783          	lbu	a5,0(a1) # ffffffff80000000 <_binary_bin_sfs_img_size+0xffffffff7ff8ad00>
ffffffffc0208eea:	e385                	bnez	a5,ffffffffc0208f0a <dev_lookup+0x24>
ffffffffc0208eec:	1101                	addi	sp,sp,-32
ffffffffc0208eee:	e822                	sd	s0,16(sp)
ffffffffc0208ef0:	e426                	sd	s1,8(sp)
ffffffffc0208ef2:	ec06                	sd	ra,24(sp)
ffffffffc0208ef4:	84aa                	mv	s1,a0
ffffffffc0208ef6:	8432                	mv	s0,a2
ffffffffc0208ef8:	c34ff0ef          	jal	ra,ffffffffc020832c <inode_ref_inc>
ffffffffc0208efc:	60e2                	ld	ra,24(sp)
ffffffffc0208efe:	e004                	sd	s1,0(s0)
ffffffffc0208f00:	6442                	ld	s0,16(sp)
ffffffffc0208f02:	64a2                	ld	s1,8(sp)
ffffffffc0208f04:	4501                	li	a0,0
ffffffffc0208f06:	6105                	addi	sp,sp,32
ffffffffc0208f08:	8082                	ret
ffffffffc0208f0a:	5541                	li	a0,-16
ffffffffc0208f0c:	8082                	ret

ffffffffc0208f0e <dev_fstat>:
ffffffffc0208f0e:	1101                	addi	sp,sp,-32
ffffffffc0208f10:	e426                	sd	s1,8(sp)
ffffffffc0208f12:	84ae                	mv	s1,a1
ffffffffc0208f14:	e822                	sd	s0,16(sp)
ffffffffc0208f16:	02000613          	li	a2,32
ffffffffc0208f1a:	842a                	mv	s0,a0
ffffffffc0208f1c:	4581                	li	a1,0
ffffffffc0208f1e:	8526                	mv	a0,s1
ffffffffc0208f20:	ec06                	sd	ra,24(sp)
ffffffffc0208f22:	40a020ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc0208f26:	c429                	beqz	s0,ffffffffc0208f70 <dev_fstat+0x62>
ffffffffc0208f28:	783c                	ld	a5,112(s0)
ffffffffc0208f2a:	c3b9                	beqz	a5,ffffffffc0208f70 <dev_fstat+0x62>
ffffffffc0208f2c:	6bbc                	ld	a5,80(a5)
ffffffffc0208f2e:	c3a9                	beqz	a5,ffffffffc0208f70 <dev_fstat+0x62>
ffffffffc0208f30:	00006597          	auipc	a1,0x6
ffffffffc0208f34:	97058593          	addi	a1,a1,-1680 # ffffffffc020e8a0 <syscalls+0x990>
ffffffffc0208f38:	8522                	mv	a0,s0
ffffffffc0208f3a:	c0aff0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc0208f3e:	783c                	ld	a5,112(s0)
ffffffffc0208f40:	85a6                	mv	a1,s1
ffffffffc0208f42:	8522                	mv	a0,s0
ffffffffc0208f44:	6bbc                	ld	a5,80(a5)
ffffffffc0208f46:	9782                	jalr	a5
ffffffffc0208f48:	ed19                	bnez	a0,ffffffffc0208f66 <dev_fstat+0x58>
ffffffffc0208f4a:	4c38                	lw	a4,88(s0)
ffffffffc0208f4c:	6785                	lui	a5,0x1
ffffffffc0208f4e:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208f52:	02f71f63          	bne	a4,a5,ffffffffc0208f90 <dev_fstat+0x82>
ffffffffc0208f56:	6018                	ld	a4,0(s0)
ffffffffc0208f58:	641c                	ld	a5,8(s0)
ffffffffc0208f5a:	4685                	li	a3,1
ffffffffc0208f5c:	e494                	sd	a3,8(s1)
ffffffffc0208f5e:	02e787b3          	mul	a5,a5,a4
ffffffffc0208f62:	e898                	sd	a4,16(s1)
ffffffffc0208f64:	ec9c                	sd	a5,24(s1)
ffffffffc0208f66:	60e2                	ld	ra,24(sp)
ffffffffc0208f68:	6442                	ld	s0,16(sp)
ffffffffc0208f6a:	64a2                	ld	s1,8(sp)
ffffffffc0208f6c:	6105                	addi	sp,sp,32
ffffffffc0208f6e:	8082                	ret
ffffffffc0208f70:	00006697          	auipc	a3,0x6
ffffffffc0208f74:	8c868693          	addi	a3,a3,-1848 # ffffffffc020e838 <syscalls+0x928>
ffffffffc0208f78:	00003617          	auipc	a2,0x3
ffffffffc0208f7c:	da860613          	addi	a2,a2,-600 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208f80:	04200593          	li	a1,66
ffffffffc0208f84:	00006517          	auipc	a0,0x6
ffffffffc0208f88:	02c50513          	addi	a0,a0,44 # ffffffffc020efb0 <syscalls+0x10a0>
ffffffffc0208f8c:	aa2f70ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0208f90:	00006697          	auipc	a3,0x6
ffffffffc0208f94:	84868693          	addi	a3,a3,-1976 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc0208f98:	00003617          	auipc	a2,0x3
ffffffffc0208f9c:	d8860613          	addi	a2,a2,-632 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208fa0:	04500593          	li	a1,69
ffffffffc0208fa4:	00006517          	auipc	a0,0x6
ffffffffc0208fa8:	00c50513          	addi	a0,a0,12 # ffffffffc020efb0 <syscalls+0x10a0>
ffffffffc0208fac:	a82f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208fb0 <dev_ioctl>:
ffffffffc0208fb0:	c909                	beqz	a0,ffffffffc0208fc2 <dev_ioctl+0x12>
ffffffffc0208fb2:	4d34                	lw	a3,88(a0)
ffffffffc0208fb4:	6705                	lui	a4,0x1
ffffffffc0208fb6:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208fba:	00e69463          	bne	a3,a4,ffffffffc0208fc2 <dev_ioctl+0x12>
ffffffffc0208fbe:	751c                	ld	a5,40(a0)
ffffffffc0208fc0:	8782                	jr	a5
ffffffffc0208fc2:	1141                	addi	sp,sp,-16
ffffffffc0208fc4:	00006697          	auipc	a3,0x6
ffffffffc0208fc8:	81468693          	addi	a3,a3,-2028 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc0208fcc:	00003617          	auipc	a2,0x3
ffffffffc0208fd0:	d5460613          	addi	a2,a2,-684 # ffffffffc020bd20 <commands+0x250>
ffffffffc0208fd4:	03500593          	li	a1,53
ffffffffc0208fd8:	00006517          	auipc	a0,0x6
ffffffffc0208fdc:	fd850513          	addi	a0,a0,-40 # ffffffffc020efb0 <syscalls+0x10a0>
ffffffffc0208fe0:	e406                	sd	ra,8(sp)
ffffffffc0208fe2:	a4cf70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0208fe6 <dev_tryseek>:
ffffffffc0208fe6:	c51d                	beqz	a0,ffffffffc0209014 <dev_tryseek+0x2e>
ffffffffc0208fe8:	4d38                	lw	a4,88(a0)
ffffffffc0208fea:	6785                	lui	a5,0x1
ffffffffc0208fec:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208ff0:	02f71263          	bne	a4,a5,ffffffffc0209014 <dev_tryseek+0x2e>
ffffffffc0208ff4:	611c                	ld	a5,0(a0)
ffffffffc0208ff6:	cf89                	beqz	a5,ffffffffc0209010 <dev_tryseek+0x2a>
ffffffffc0208ff8:	6518                	ld	a4,8(a0)
ffffffffc0208ffa:	02e5f6b3          	remu	a3,a1,a4
ffffffffc0208ffe:	ea89                	bnez	a3,ffffffffc0209010 <dev_tryseek+0x2a>
ffffffffc0209000:	0005c863          	bltz	a1,ffffffffc0209010 <dev_tryseek+0x2a>
ffffffffc0209004:	02e787b3          	mul	a5,a5,a4
ffffffffc0209008:	00f5f463          	bgeu	a1,a5,ffffffffc0209010 <dev_tryseek+0x2a>
ffffffffc020900c:	4501                	li	a0,0
ffffffffc020900e:	8082                	ret
ffffffffc0209010:	5575                	li	a0,-3
ffffffffc0209012:	8082                	ret
ffffffffc0209014:	1141                	addi	sp,sp,-16
ffffffffc0209016:	00005697          	auipc	a3,0x5
ffffffffc020901a:	7c268693          	addi	a3,a3,1986 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc020901e:	00003617          	auipc	a2,0x3
ffffffffc0209022:	d0260613          	addi	a2,a2,-766 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209026:	05f00593          	li	a1,95
ffffffffc020902a:	00006517          	auipc	a0,0x6
ffffffffc020902e:	f8650513          	addi	a0,a0,-122 # ffffffffc020efb0 <syscalls+0x10a0>
ffffffffc0209032:	e406                	sd	ra,8(sp)
ffffffffc0209034:	9faf70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209038 <dev_gettype>:
ffffffffc0209038:	c10d                	beqz	a0,ffffffffc020905a <dev_gettype+0x22>
ffffffffc020903a:	4d38                	lw	a4,88(a0)
ffffffffc020903c:	6785                	lui	a5,0x1
ffffffffc020903e:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0209042:	00f71c63          	bne	a4,a5,ffffffffc020905a <dev_gettype+0x22>
ffffffffc0209046:	6118                	ld	a4,0(a0)
ffffffffc0209048:	6795                	lui	a5,0x5
ffffffffc020904a:	c701                	beqz	a4,ffffffffc0209052 <dev_gettype+0x1a>
ffffffffc020904c:	c19c                	sw	a5,0(a1)
ffffffffc020904e:	4501                	li	a0,0
ffffffffc0209050:	8082                	ret
ffffffffc0209052:	6791                	lui	a5,0x4
ffffffffc0209054:	c19c                	sw	a5,0(a1)
ffffffffc0209056:	4501                	li	a0,0
ffffffffc0209058:	8082                	ret
ffffffffc020905a:	1141                	addi	sp,sp,-16
ffffffffc020905c:	00005697          	auipc	a3,0x5
ffffffffc0209060:	77c68693          	addi	a3,a3,1916 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc0209064:	00003617          	auipc	a2,0x3
ffffffffc0209068:	cbc60613          	addi	a2,a2,-836 # ffffffffc020bd20 <commands+0x250>
ffffffffc020906c:	05300593          	li	a1,83
ffffffffc0209070:	00006517          	auipc	a0,0x6
ffffffffc0209074:	f4050513          	addi	a0,a0,-192 # ffffffffc020efb0 <syscalls+0x10a0>
ffffffffc0209078:	e406                	sd	ra,8(sp)
ffffffffc020907a:	9b4f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020907e <dev_write>:
ffffffffc020907e:	c911                	beqz	a0,ffffffffc0209092 <dev_write+0x14>
ffffffffc0209080:	4d34                	lw	a3,88(a0)
ffffffffc0209082:	6705                	lui	a4,0x1
ffffffffc0209084:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0209088:	00e69563          	bne	a3,a4,ffffffffc0209092 <dev_write+0x14>
ffffffffc020908c:	711c                	ld	a5,32(a0)
ffffffffc020908e:	4605                	li	a2,1
ffffffffc0209090:	8782                	jr	a5
ffffffffc0209092:	1141                	addi	sp,sp,-16
ffffffffc0209094:	00005697          	auipc	a3,0x5
ffffffffc0209098:	74468693          	addi	a3,a3,1860 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc020909c:	00003617          	auipc	a2,0x3
ffffffffc02090a0:	c8460613          	addi	a2,a2,-892 # ffffffffc020bd20 <commands+0x250>
ffffffffc02090a4:	02c00593          	li	a1,44
ffffffffc02090a8:	00006517          	auipc	a0,0x6
ffffffffc02090ac:	f0850513          	addi	a0,a0,-248 # ffffffffc020efb0 <syscalls+0x10a0>
ffffffffc02090b0:	e406                	sd	ra,8(sp)
ffffffffc02090b2:	97cf70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02090b6 <dev_read>:
ffffffffc02090b6:	c911                	beqz	a0,ffffffffc02090ca <dev_read+0x14>
ffffffffc02090b8:	4d34                	lw	a3,88(a0)
ffffffffc02090ba:	6705                	lui	a4,0x1
ffffffffc02090bc:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02090c0:	00e69563          	bne	a3,a4,ffffffffc02090ca <dev_read+0x14>
ffffffffc02090c4:	711c                	ld	a5,32(a0)
ffffffffc02090c6:	4601                	li	a2,0
ffffffffc02090c8:	8782                	jr	a5
ffffffffc02090ca:	1141                	addi	sp,sp,-16
ffffffffc02090cc:	00005697          	auipc	a3,0x5
ffffffffc02090d0:	70c68693          	addi	a3,a3,1804 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc02090d4:	00003617          	auipc	a2,0x3
ffffffffc02090d8:	c4c60613          	addi	a2,a2,-948 # ffffffffc020bd20 <commands+0x250>
ffffffffc02090dc:	02300593          	li	a1,35
ffffffffc02090e0:	00006517          	auipc	a0,0x6
ffffffffc02090e4:	ed050513          	addi	a0,a0,-304 # ffffffffc020efb0 <syscalls+0x10a0>
ffffffffc02090e8:	e406                	sd	ra,8(sp)
ffffffffc02090ea:	944f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02090ee <dev_close>:
ffffffffc02090ee:	c909                	beqz	a0,ffffffffc0209100 <dev_close+0x12>
ffffffffc02090f0:	4d34                	lw	a3,88(a0)
ffffffffc02090f2:	6705                	lui	a4,0x1
ffffffffc02090f4:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02090f8:	00e69463          	bne	a3,a4,ffffffffc0209100 <dev_close+0x12>
ffffffffc02090fc:	6d1c                	ld	a5,24(a0)
ffffffffc02090fe:	8782                	jr	a5
ffffffffc0209100:	1141                	addi	sp,sp,-16
ffffffffc0209102:	00005697          	auipc	a3,0x5
ffffffffc0209106:	6d668693          	addi	a3,a3,1750 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc020910a:	00003617          	auipc	a2,0x3
ffffffffc020910e:	c1660613          	addi	a2,a2,-1002 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209112:	45e9                	li	a1,26
ffffffffc0209114:	00006517          	auipc	a0,0x6
ffffffffc0209118:	e9c50513          	addi	a0,a0,-356 # ffffffffc020efb0 <syscalls+0x10a0>
ffffffffc020911c:	e406                	sd	ra,8(sp)
ffffffffc020911e:	910f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209122 <dev_open>:
ffffffffc0209122:	03c5f713          	andi	a4,a1,60
ffffffffc0209126:	eb11                	bnez	a4,ffffffffc020913a <dev_open+0x18>
ffffffffc0209128:	c919                	beqz	a0,ffffffffc020913e <dev_open+0x1c>
ffffffffc020912a:	4d34                	lw	a3,88(a0)
ffffffffc020912c:	6705                	lui	a4,0x1
ffffffffc020912e:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0209132:	00e69663          	bne	a3,a4,ffffffffc020913e <dev_open+0x1c>
ffffffffc0209136:	691c                	ld	a5,16(a0)
ffffffffc0209138:	8782                	jr	a5
ffffffffc020913a:	5575                	li	a0,-3
ffffffffc020913c:	8082                	ret
ffffffffc020913e:	1141                	addi	sp,sp,-16
ffffffffc0209140:	00005697          	auipc	a3,0x5
ffffffffc0209144:	69868693          	addi	a3,a3,1688 # ffffffffc020e7d8 <syscalls+0x8c8>
ffffffffc0209148:	00003617          	auipc	a2,0x3
ffffffffc020914c:	bd860613          	addi	a2,a2,-1064 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209150:	45c5                	li	a1,17
ffffffffc0209152:	00006517          	auipc	a0,0x6
ffffffffc0209156:	e5e50513          	addi	a0,a0,-418 # ffffffffc020efb0 <syscalls+0x10a0>
ffffffffc020915a:	e406                	sd	ra,8(sp)
ffffffffc020915c:	8d2f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209160 <dev_init>:
ffffffffc0209160:	1141                	addi	sp,sp,-16
ffffffffc0209162:	e406                	sd	ra,8(sp)
ffffffffc0209164:	8c1ff0ef          	jal	ra,ffffffffc0208a24 <dev_init_stdin>
ffffffffc0209168:	ccfff0ef          	jal	ra,ffffffffc0208e36 <dev_init_stdout>
ffffffffc020916c:	60a2                	ld	ra,8(sp)
ffffffffc020916e:	0141                	addi	sp,sp,16
ffffffffc0209170:	b67ff06f          	j	ffffffffc0208cd6 <dev_init_disk0>

ffffffffc0209174 <dev_create_inode>:
ffffffffc0209174:	6505                	lui	a0,0x1
ffffffffc0209176:	1141                	addi	sp,sp,-16
ffffffffc0209178:	23450513          	addi	a0,a0,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc020917c:	e022                	sd	s0,0(sp)
ffffffffc020917e:	e406                	sd	ra,8(sp)
ffffffffc0209180:	92eff0ef          	jal	ra,ffffffffc02082ae <__alloc_inode>
ffffffffc0209184:	842a                	mv	s0,a0
ffffffffc0209186:	c901                	beqz	a0,ffffffffc0209196 <dev_create_inode+0x22>
ffffffffc0209188:	4601                	li	a2,0
ffffffffc020918a:	00006597          	auipc	a1,0x6
ffffffffc020918e:	e3e58593          	addi	a1,a1,-450 # ffffffffc020efc8 <dev_node_ops>
ffffffffc0209192:	938ff0ef          	jal	ra,ffffffffc02082ca <inode_init>
ffffffffc0209196:	60a2                	ld	ra,8(sp)
ffffffffc0209198:	8522                	mv	a0,s0
ffffffffc020919a:	6402                	ld	s0,0(sp)
ffffffffc020919c:	0141                	addi	sp,sp,16
ffffffffc020919e:	8082                	ret

ffffffffc02091a0 <sfs_init>:
ffffffffc02091a0:	1141                	addi	sp,sp,-16
ffffffffc02091a2:	00006517          	auipc	a0,0x6
ffffffffc02091a6:	d7e50513          	addi	a0,a0,-642 # ffffffffc020ef20 <syscalls+0x1010>
ffffffffc02091aa:	e406                	sd	ra,8(sp)
ffffffffc02091ac:	574000ef          	jal	ra,ffffffffc0209720 <sfs_mount>
ffffffffc02091b0:	e501                	bnez	a0,ffffffffc02091b8 <sfs_init+0x18>
ffffffffc02091b2:	60a2                	ld	ra,8(sp)
ffffffffc02091b4:	0141                	addi	sp,sp,16
ffffffffc02091b6:	8082                	ret
ffffffffc02091b8:	86aa                	mv	a3,a0
ffffffffc02091ba:	00006617          	auipc	a2,0x6
ffffffffc02091be:	e8e60613          	addi	a2,a2,-370 # ffffffffc020f048 <dev_node_ops+0x80>
ffffffffc02091c2:	45c1                	li	a1,16
ffffffffc02091c4:	00006517          	auipc	a0,0x6
ffffffffc02091c8:	ea450513          	addi	a0,a0,-348 # ffffffffc020f068 <dev_node_ops+0xa0>
ffffffffc02091cc:	862f70ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02091d0 <lock_sfs_fs>:
ffffffffc02091d0:	05050513          	addi	a0,a0,80
ffffffffc02091d4:	e84fb06f          	j	ffffffffc0204858 <down>

ffffffffc02091d8 <lock_sfs_io>:
ffffffffc02091d8:	06850513          	addi	a0,a0,104
ffffffffc02091dc:	e7cfb06f          	j	ffffffffc0204858 <down>

ffffffffc02091e0 <unlock_sfs_fs>:
ffffffffc02091e0:	05050513          	addi	a0,a0,80
ffffffffc02091e4:	e70fb06f          	j	ffffffffc0204854 <up>

ffffffffc02091e8 <unlock_sfs_io>:
ffffffffc02091e8:	06850513          	addi	a0,a0,104
ffffffffc02091ec:	e68fb06f          	j	ffffffffc0204854 <up>

ffffffffc02091f0 <sfs_unmount>:
ffffffffc02091f0:	1141                	addi	sp,sp,-16
ffffffffc02091f2:	e406                	sd	ra,8(sp)
ffffffffc02091f4:	e022                	sd	s0,0(sp)
ffffffffc02091f6:	cd1d                	beqz	a0,ffffffffc0209234 <sfs_unmount+0x44>
ffffffffc02091f8:	0b052783          	lw	a5,176(a0)
ffffffffc02091fc:	842a                	mv	s0,a0
ffffffffc02091fe:	eb9d                	bnez	a5,ffffffffc0209234 <sfs_unmount+0x44>
ffffffffc0209200:	7158                	ld	a4,160(a0)
ffffffffc0209202:	09850793          	addi	a5,a0,152
ffffffffc0209206:	02f71563          	bne	a4,a5,ffffffffc0209230 <sfs_unmount+0x40>
ffffffffc020920a:	613c                	ld	a5,64(a0)
ffffffffc020920c:	e7a1                	bnez	a5,ffffffffc0209254 <sfs_unmount+0x64>
ffffffffc020920e:	7d08                	ld	a0,56(a0)
ffffffffc0209210:	50b010ef          	jal	ra,ffffffffc020af1a <bitmap_destroy>
ffffffffc0209214:	6428                	ld	a0,72(s0)
ffffffffc0209216:	f6afa0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020921a:	7448                	ld	a0,168(s0)
ffffffffc020921c:	f64fa0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0209220:	8522                	mv	a0,s0
ffffffffc0209222:	f5efa0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0209226:	4501                	li	a0,0
ffffffffc0209228:	60a2                	ld	ra,8(sp)
ffffffffc020922a:	6402                	ld	s0,0(sp)
ffffffffc020922c:	0141                	addi	sp,sp,16
ffffffffc020922e:	8082                	ret
ffffffffc0209230:	5545                	li	a0,-15
ffffffffc0209232:	bfdd                	j	ffffffffc0209228 <sfs_unmount+0x38>
ffffffffc0209234:	00006697          	auipc	a3,0x6
ffffffffc0209238:	e4c68693          	addi	a3,a3,-436 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc020923c:	00003617          	auipc	a2,0x3
ffffffffc0209240:	ae460613          	addi	a2,a2,-1308 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209244:	04100593          	li	a1,65
ffffffffc0209248:	00006517          	auipc	a0,0x6
ffffffffc020924c:	e6850513          	addi	a0,a0,-408 # ffffffffc020f0b0 <dev_node_ops+0xe8>
ffffffffc0209250:	fdff60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209254:	00006697          	auipc	a3,0x6
ffffffffc0209258:	e7468693          	addi	a3,a3,-396 # ffffffffc020f0c8 <dev_node_ops+0x100>
ffffffffc020925c:	00003617          	auipc	a2,0x3
ffffffffc0209260:	ac460613          	addi	a2,a2,-1340 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209264:	04500593          	li	a1,69
ffffffffc0209268:	00006517          	auipc	a0,0x6
ffffffffc020926c:	e4850513          	addi	a0,a0,-440 # ffffffffc020f0b0 <dev_node_ops+0xe8>
ffffffffc0209270:	fbff60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209274 <sfs_cleanup>:
ffffffffc0209274:	1101                	addi	sp,sp,-32
ffffffffc0209276:	ec06                	sd	ra,24(sp)
ffffffffc0209278:	e822                	sd	s0,16(sp)
ffffffffc020927a:	e426                	sd	s1,8(sp)
ffffffffc020927c:	e04a                	sd	s2,0(sp)
ffffffffc020927e:	c525                	beqz	a0,ffffffffc02092e6 <sfs_cleanup+0x72>
ffffffffc0209280:	0b052783          	lw	a5,176(a0)
ffffffffc0209284:	84aa                	mv	s1,a0
ffffffffc0209286:	e3a5                	bnez	a5,ffffffffc02092e6 <sfs_cleanup+0x72>
ffffffffc0209288:	4158                	lw	a4,4(a0)
ffffffffc020928a:	4514                	lw	a3,8(a0)
ffffffffc020928c:	00c50913          	addi	s2,a0,12
ffffffffc0209290:	85ca                	mv	a1,s2
ffffffffc0209292:	40d7063b          	subw	a2,a4,a3
ffffffffc0209296:	00006517          	auipc	a0,0x6
ffffffffc020929a:	e4a50513          	addi	a0,a0,-438 # ffffffffc020f0e0 <dev_node_ops+0x118>
ffffffffc020929e:	e8df60ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc02092a2:	02000413          	li	s0,32
ffffffffc02092a6:	a019                	j	ffffffffc02092ac <sfs_cleanup+0x38>
ffffffffc02092a8:	347d                	addiw	s0,s0,-1
ffffffffc02092aa:	c819                	beqz	s0,ffffffffc02092c0 <sfs_cleanup+0x4c>
ffffffffc02092ac:	7cdc                	ld	a5,184(s1)
ffffffffc02092ae:	8526                	mv	a0,s1
ffffffffc02092b0:	9782                	jalr	a5
ffffffffc02092b2:	f97d                	bnez	a0,ffffffffc02092a8 <sfs_cleanup+0x34>
ffffffffc02092b4:	60e2                	ld	ra,24(sp)
ffffffffc02092b6:	6442                	ld	s0,16(sp)
ffffffffc02092b8:	64a2                	ld	s1,8(sp)
ffffffffc02092ba:	6902                	ld	s2,0(sp)
ffffffffc02092bc:	6105                	addi	sp,sp,32
ffffffffc02092be:	8082                	ret
ffffffffc02092c0:	6442                	ld	s0,16(sp)
ffffffffc02092c2:	60e2                	ld	ra,24(sp)
ffffffffc02092c4:	64a2                	ld	s1,8(sp)
ffffffffc02092c6:	86ca                	mv	a3,s2
ffffffffc02092c8:	6902                	ld	s2,0(sp)
ffffffffc02092ca:	872a                	mv	a4,a0
ffffffffc02092cc:	00006617          	auipc	a2,0x6
ffffffffc02092d0:	e3460613          	addi	a2,a2,-460 # ffffffffc020f100 <dev_node_ops+0x138>
ffffffffc02092d4:	05f00593          	li	a1,95
ffffffffc02092d8:	00006517          	auipc	a0,0x6
ffffffffc02092dc:	dd850513          	addi	a0,a0,-552 # ffffffffc020f0b0 <dev_node_ops+0xe8>
ffffffffc02092e0:	6105                	addi	sp,sp,32
ffffffffc02092e2:	fb5f606f          	j	ffffffffc0200296 <__warn>
ffffffffc02092e6:	00006697          	auipc	a3,0x6
ffffffffc02092ea:	d9a68693          	addi	a3,a3,-614 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc02092ee:	00003617          	auipc	a2,0x3
ffffffffc02092f2:	a3260613          	addi	a2,a2,-1486 # ffffffffc020bd20 <commands+0x250>
ffffffffc02092f6:	05400593          	li	a1,84
ffffffffc02092fa:	00006517          	auipc	a0,0x6
ffffffffc02092fe:	db650513          	addi	a0,a0,-586 # ffffffffc020f0b0 <dev_node_ops+0xe8>
ffffffffc0209302:	f2df60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209306 <sfs_sync>:
ffffffffc0209306:	7179                	addi	sp,sp,-48
ffffffffc0209308:	f406                	sd	ra,40(sp)
ffffffffc020930a:	f022                	sd	s0,32(sp)
ffffffffc020930c:	ec26                	sd	s1,24(sp)
ffffffffc020930e:	e84a                	sd	s2,16(sp)
ffffffffc0209310:	e44e                	sd	s3,8(sp)
ffffffffc0209312:	e052                	sd	s4,0(sp)
ffffffffc0209314:	cd4d                	beqz	a0,ffffffffc02093ce <sfs_sync+0xc8>
ffffffffc0209316:	0b052783          	lw	a5,176(a0)
ffffffffc020931a:	8a2a                	mv	s4,a0
ffffffffc020931c:	ebcd                	bnez	a5,ffffffffc02093ce <sfs_sync+0xc8>
ffffffffc020931e:	eb3ff0ef          	jal	ra,ffffffffc02091d0 <lock_sfs_fs>
ffffffffc0209322:	0a0a3403          	ld	s0,160(s4)
ffffffffc0209326:	098a0913          	addi	s2,s4,152
ffffffffc020932a:	02890763          	beq	s2,s0,ffffffffc0209358 <sfs_sync+0x52>
ffffffffc020932e:	00004997          	auipc	s3,0x4
ffffffffc0209332:	45298993          	addi	s3,s3,1106 # ffffffffc020d780 <default_pmm_manager+0x460>
ffffffffc0209336:	7c1c                	ld	a5,56(s0)
ffffffffc0209338:	fc840493          	addi	s1,s0,-56
ffffffffc020933c:	cbb5                	beqz	a5,ffffffffc02093b0 <sfs_sync+0xaa>
ffffffffc020933e:	7b9c                	ld	a5,48(a5)
ffffffffc0209340:	cba5                	beqz	a5,ffffffffc02093b0 <sfs_sync+0xaa>
ffffffffc0209342:	85ce                	mv	a1,s3
ffffffffc0209344:	8526                	mv	a0,s1
ffffffffc0209346:	ffffe0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc020934a:	7c1c                	ld	a5,56(s0)
ffffffffc020934c:	8526                	mv	a0,s1
ffffffffc020934e:	7b9c                	ld	a5,48(a5)
ffffffffc0209350:	9782                	jalr	a5
ffffffffc0209352:	6400                	ld	s0,8(s0)
ffffffffc0209354:	fe8911e3          	bne	s2,s0,ffffffffc0209336 <sfs_sync+0x30>
ffffffffc0209358:	8552                	mv	a0,s4
ffffffffc020935a:	e87ff0ef          	jal	ra,ffffffffc02091e0 <unlock_sfs_fs>
ffffffffc020935e:	040a3783          	ld	a5,64(s4)
ffffffffc0209362:	4501                	li	a0,0
ffffffffc0209364:	eb89                	bnez	a5,ffffffffc0209376 <sfs_sync+0x70>
ffffffffc0209366:	70a2                	ld	ra,40(sp)
ffffffffc0209368:	7402                	ld	s0,32(sp)
ffffffffc020936a:	64e2                	ld	s1,24(sp)
ffffffffc020936c:	6942                	ld	s2,16(sp)
ffffffffc020936e:	69a2                	ld	s3,8(sp)
ffffffffc0209370:	6a02                	ld	s4,0(sp)
ffffffffc0209372:	6145                	addi	sp,sp,48
ffffffffc0209374:	8082                	ret
ffffffffc0209376:	040a3023          	sd	zero,64(s4)
ffffffffc020937a:	8552                	mv	a0,s4
ffffffffc020937c:	5f3010ef          	jal	ra,ffffffffc020b16e <sfs_sync_super>
ffffffffc0209380:	cd01                	beqz	a0,ffffffffc0209398 <sfs_sync+0x92>
ffffffffc0209382:	70a2                	ld	ra,40(sp)
ffffffffc0209384:	7402                	ld	s0,32(sp)
ffffffffc0209386:	4785                	li	a5,1
ffffffffc0209388:	04fa3023          	sd	a5,64(s4)
ffffffffc020938c:	64e2                	ld	s1,24(sp)
ffffffffc020938e:	6942                	ld	s2,16(sp)
ffffffffc0209390:	69a2                	ld	s3,8(sp)
ffffffffc0209392:	6a02                	ld	s4,0(sp)
ffffffffc0209394:	6145                	addi	sp,sp,48
ffffffffc0209396:	8082                	ret
ffffffffc0209398:	8552                	mv	a0,s4
ffffffffc020939a:	61b010ef          	jal	ra,ffffffffc020b1b4 <sfs_sync_freemap>
ffffffffc020939e:	f175                	bnez	a0,ffffffffc0209382 <sfs_sync+0x7c>
ffffffffc02093a0:	70a2                	ld	ra,40(sp)
ffffffffc02093a2:	7402                	ld	s0,32(sp)
ffffffffc02093a4:	64e2                	ld	s1,24(sp)
ffffffffc02093a6:	6942                	ld	s2,16(sp)
ffffffffc02093a8:	69a2                	ld	s3,8(sp)
ffffffffc02093aa:	6a02                	ld	s4,0(sp)
ffffffffc02093ac:	6145                	addi	sp,sp,48
ffffffffc02093ae:	8082                	ret
ffffffffc02093b0:	00004697          	auipc	a3,0x4
ffffffffc02093b4:	38068693          	addi	a3,a3,896 # ffffffffc020d730 <default_pmm_manager+0x410>
ffffffffc02093b8:	00003617          	auipc	a2,0x3
ffffffffc02093bc:	96860613          	addi	a2,a2,-1688 # ffffffffc020bd20 <commands+0x250>
ffffffffc02093c0:	45ed                	li	a1,27
ffffffffc02093c2:	00006517          	auipc	a0,0x6
ffffffffc02093c6:	cee50513          	addi	a0,a0,-786 # ffffffffc020f0b0 <dev_node_ops+0xe8>
ffffffffc02093ca:	e65f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02093ce:	00006697          	auipc	a3,0x6
ffffffffc02093d2:	cb268693          	addi	a3,a3,-846 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc02093d6:	00003617          	auipc	a2,0x3
ffffffffc02093da:	94a60613          	addi	a2,a2,-1718 # ffffffffc020bd20 <commands+0x250>
ffffffffc02093de:	45d5                	li	a1,21
ffffffffc02093e0:	00006517          	auipc	a0,0x6
ffffffffc02093e4:	cd050513          	addi	a0,a0,-816 # ffffffffc020f0b0 <dev_node_ops+0xe8>
ffffffffc02093e8:	e47f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02093ec <sfs_get_root>:
ffffffffc02093ec:	1101                	addi	sp,sp,-32
ffffffffc02093ee:	ec06                	sd	ra,24(sp)
ffffffffc02093f0:	cd09                	beqz	a0,ffffffffc020940a <sfs_get_root+0x1e>
ffffffffc02093f2:	0b052783          	lw	a5,176(a0)
ffffffffc02093f6:	eb91                	bnez	a5,ffffffffc020940a <sfs_get_root+0x1e>
ffffffffc02093f8:	4605                	li	a2,1
ffffffffc02093fa:	002c                	addi	a1,sp,8
ffffffffc02093fc:	35e010ef          	jal	ra,ffffffffc020a75a <sfs_load_inode>
ffffffffc0209400:	e50d                	bnez	a0,ffffffffc020942a <sfs_get_root+0x3e>
ffffffffc0209402:	60e2                	ld	ra,24(sp)
ffffffffc0209404:	6522                	ld	a0,8(sp)
ffffffffc0209406:	6105                	addi	sp,sp,32
ffffffffc0209408:	8082                	ret
ffffffffc020940a:	00006697          	auipc	a3,0x6
ffffffffc020940e:	c7668693          	addi	a3,a3,-906 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc0209412:	00003617          	auipc	a2,0x3
ffffffffc0209416:	90e60613          	addi	a2,a2,-1778 # ffffffffc020bd20 <commands+0x250>
ffffffffc020941a:	03600593          	li	a1,54
ffffffffc020941e:	00006517          	auipc	a0,0x6
ffffffffc0209422:	c9250513          	addi	a0,a0,-878 # ffffffffc020f0b0 <dev_node_ops+0xe8>
ffffffffc0209426:	e09f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020942a:	86aa                	mv	a3,a0
ffffffffc020942c:	00006617          	auipc	a2,0x6
ffffffffc0209430:	cf460613          	addi	a2,a2,-780 # ffffffffc020f120 <dev_node_ops+0x158>
ffffffffc0209434:	03700593          	li	a1,55
ffffffffc0209438:	00006517          	auipc	a0,0x6
ffffffffc020943c:	c7850513          	addi	a0,a0,-904 # ffffffffc020f0b0 <dev_node_ops+0xe8>
ffffffffc0209440:	deff60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209444 <sfs_do_mount>:
ffffffffc0209444:	6518                	ld	a4,8(a0)
ffffffffc0209446:	7171                	addi	sp,sp,-176
ffffffffc0209448:	f506                	sd	ra,168(sp)
ffffffffc020944a:	f122                	sd	s0,160(sp)
ffffffffc020944c:	ed26                	sd	s1,152(sp)
ffffffffc020944e:	e94a                	sd	s2,144(sp)
ffffffffc0209450:	e54e                	sd	s3,136(sp)
ffffffffc0209452:	e152                	sd	s4,128(sp)
ffffffffc0209454:	fcd6                	sd	s5,120(sp)
ffffffffc0209456:	f8da                	sd	s6,112(sp)
ffffffffc0209458:	f4de                	sd	s7,104(sp)
ffffffffc020945a:	f0e2                	sd	s8,96(sp)
ffffffffc020945c:	ece6                	sd	s9,88(sp)
ffffffffc020945e:	e8ea                	sd	s10,80(sp)
ffffffffc0209460:	e4ee                	sd	s11,72(sp)
ffffffffc0209462:	6785                	lui	a5,0x1
ffffffffc0209464:	24f71663          	bne	a4,a5,ffffffffc02096b0 <sfs_do_mount+0x26c>
ffffffffc0209468:	892a                	mv	s2,a0
ffffffffc020946a:	4501                	li	a0,0
ffffffffc020946c:	8aae                	mv	s5,a1
ffffffffc020946e:	a98ff0ef          	jal	ra,ffffffffc0208706 <__alloc_fs>
ffffffffc0209472:	842a                	mv	s0,a0
ffffffffc0209474:	24050463          	beqz	a0,ffffffffc02096bc <sfs_do_mount+0x278>
ffffffffc0209478:	0b052b03          	lw	s6,176(a0)
ffffffffc020947c:	260b1263          	bnez	s6,ffffffffc02096e0 <sfs_do_mount+0x29c>
ffffffffc0209480:	03253823          	sd	s2,48(a0)
ffffffffc0209484:	6505                	lui	a0,0x1
ffffffffc0209486:	c4afa0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc020948a:	e428                	sd	a0,72(s0)
ffffffffc020948c:	84aa                	mv	s1,a0
ffffffffc020948e:	16050363          	beqz	a0,ffffffffc02095f4 <sfs_do_mount+0x1b0>
ffffffffc0209492:	85aa                	mv	a1,a0
ffffffffc0209494:	4681                	li	a3,0
ffffffffc0209496:	6605                	lui	a2,0x1
ffffffffc0209498:	1008                	addi	a0,sp,32
ffffffffc020949a:	ba0fc0ef          	jal	ra,ffffffffc020583a <iobuf_init>
ffffffffc020949e:	02093783          	ld	a5,32(s2) # 4020 <_binary_bin_swap_img_size-0x3ce0>
ffffffffc02094a2:	85aa                	mv	a1,a0
ffffffffc02094a4:	4601                	li	a2,0
ffffffffc02094a6:	854a                	mv	a0,s2
ffffffffc02094a8:	9782                	jalr	a5
ffffffffc02094aa:	8a2a                	mv	s4,a0
ffffffffc02094ac:	10051e63          	bnez	a0,ffffffffc02095c8 <sfs_do_mount+0x184>
ffffffffc02094b0:	408c                	lw	a1,0(s1)
ffffffffc02094b2:	2f8dc637          	lui	a2,0x2f8dc
ffffffffc02094b6:	e2a60613          	addi	a2,a2,-470 # 2f8dbe2a <_binary_bin_sfs_img_size+0x2f866b2a>
ffffffffc02094ba:	14c59863          	bne	a1,a2,ffffffffc020960a <sfs_do_mount+0x1c6>
ffffffffc02094be:	40dc                	lw	a5,4(s1)
ffffffffc02094c0:	00093603          	ld	a2,0(s2)
ffffffffc02094c4:	02079713          	slli	a4,a5,0x20
ffffffffc02094c8:	9301                	srli	a4,a4,0x20
ffffffffc02094ca:	12e66763          	bltu	a2,a4,ffffffffc02095f8 <sfs_do_mount+0x1b4>
ffffffffc02094ce:	020485a3          	sb	zero,43(s1)
ffffffffc02094d2:	0084af03          	lw	t5,8(s1)
ffffffffc02094d6:	00c4ae83          	lw	t4,12(s1)
ffffffffc02094da:	0104ae03          	lw	t3,16(s1)
ffffffffc02094de:	0144a303          	lw	t1,20(s1)
ffffffffc02094e2:	0184a883          	lw	a7,24(s1)
ffffffffc02094e6:	01c4a803          	lw	a6,28(s1)
ffffffffc02094ea:	5090                	lw	a2,32(s1)
ffffffffc02094ec:	50d4                	lw	a3,36(s1)
ffffffffc02094ee:	5498                	lw	a4,40(s1)
ffffffffc02094f0:	6511                	lui	a0,0x4
ffffffffc02094f2:	c00c                	sw	a1,0(s0)
ffffffffc02094f4:	c05c                	sw	a5,4(s0)
ffffffffc02094f6:	01e42423          	sw	t5,8(s0)
ffffffffc02094fa:	01d42623          	sw	t4,12(s0)
ffffffffc02094fe:	01c42823          	sw	t3,16(s0)
ffffffffc0209502:	00642a23          	sw	t1,20(s0)
ffffffffc0209506:	01142c23          	sw	a7,24(s0)
ffffffffc020950a:	01042e23          	sw	a6,28(s0)
ffffffffc020950e:	d010                	sw	a2,32(s0)
ffffffffc0209510:	d054                	sw	a3,36(s0)
ffffffffc0209512:	d418                	sw	a4,40(s0)
ffffffffc0209514:	bbcfa0ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc0209518:	f448                	sd	a0,168(s0)
ffffffffc020951a:	8c2a                	mv	s8,a0
ffffffffc020951c:	18050c63          	beqz	a0,ffffffffc02096b4 <sfs_do_mount+0x270>
ffffffffc0209520:	6711                	lui	a4,0x4
ffffffffc0209522:	87aa                	mv	a5,a0
ffffffffc0209524:	972a                	add	a4,a4,a0
ffffffffc0209526:	e79c                	sd	a5,8(a5)
ffffffffc0209528:	e39c                	sd	a5,0(a5)
ffffffffc020952a:	07c1                	addi	a5,a5,16
ffffffffc020952c:	fee79de3          	bne	a5,a4,ffffffffc0209526 <sfs_do_mount+0xe2>
ffffffffc0209530:	0044eb83          	lwu	s7,4(s1)
ffffffffc0209534:	67a1                	lui	a5,0x8
ffffffffc0209536:	fff78993          	addi	s3,a5,-1 # 7fff <_binary_bin_swap_img_size+0x2ff>
ffffffffc020953a:	9bce                	add	s7,s7,s3
ffffffffc020953c:	77e1                	lui	a5,0xffff8
ffffffffc020953e:	00fbfbb3          	and	s7,s7,a5
ffffffffc0209542:	2b81                	sext.w	s7,s7
ffffffffc0209544:	855e                	mv	a0,s7
ffffffffc0209546:	7da010ef          	jal	ra,ffffffffc020ad20 <bitmap_create>
ffffffffc020954a:	fc08                	sd	a0,56(s0)
ffffffffc020954c:	8d2a                	mv	s10,a0
ffffffffc020954e:	14050f63          	beqz	a0,ffffffffc02096ac <sfs_do_mount+0x268>
ffffffffc0209552:	0044e783          	lwu	a5,4(s1)
ffffffffc0209556:	082c                	addi	a1,sp,24
ffffffffc0209558:	97ce                	add	a5,a5,s3
ffffffffc020955a:	00f7d713          	srli	a4,a5,0xf
ffffffffc020955e:	e43a                	sd	a4,8(sp)
ffffffffc0209560:	40f7d993          	srai	s3,a5,0xf
ffffffffc0209564:	1d1010ef          	jal	ra,ffffffffc020af34 <bitmap_getdata>
ffffffffc0209568:	14050c63          	beqz	a0,ffffffffc02096c0 <sfs_do_mount+0x27c>
ffffffffc020956c:	00c9979b          	slliw	a5,s3,0xc
ffffffffc0209570:	66e2                	ld	a3,24(sp)
ffffffffc0209572:	1782                	slli	a5,a5,0x20
ffffffffc0209574:	9381                	srli	a5,a5,0x20
ffffffffc0209576:	14d79563          	bne	a5,a3,ffffffffc02096c0 <sfs_do_mount+0x27c>
ffffffffc020957a:	6722                	ld	a4,8(sp)
ffffffffc020957c:	6d89                	lui	s11,0x2
ffffffffc020957e:	89aa                	mv	s3,a0
ffffffffc0209580:	00c71c93          	slli	s9,a4,0xc
ffffffffc0209584:	9caa                	add	s9,s9,a0
ffffffffc0209586:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020958a:	e711                	bnez	a4,ffffffffc0209596 <sfs_do_mount+0x152>
ffffffffc020958c:	a079                	j	ffffffffc020961a <sfs_do_mount+0x1d6>
ffffffffc020958e:	6785                	lui	a5,0x1
ffffffffc0209590:	99be                	add	s3,s3,a5
ffffffffc0209592:	093c8463          	beq	s9,s3,ffffffffc020961a <sfs_do_mount+0x1d6>
ffffffffc0209596:	013d86bb          	addw	a3,s11,s3
ffffffffc020959a:	1682                	slli	a3,a3,0x20
ffffffffc020959c:	6605                	lui	a2,0x1
ffffffffc020959e:	85ce                	mv	a1,s3
ffffffffc02095a0:	9281                	srli	a3,a3,0x20
ffffffffc02095a2:	1008                	addi	a0,sp,32
ffffffffc02095a4:	a96fc0ef          	jal	ra,ffffffffc020583a <iobuf_init>
ffffffffc02095a8:	02093783          	ld	a5,32(s2)
ffffffffc02095ac:	85aa                	mv	a1,a0
ffffffffc02095ae:	4601                	li	a2,0
ffffffffc02095b0:	854a                	mv	a0,s2
ffffffffc02095b2:	9782                	jalr	a5
ffffffffc02095b4:	dd69                	beqz	a0,ffffffffc020958e <sfs_do_mount+0x14a>
ffffffffc02095b6:	e42a                	sd	a0,8(sp)
ffffffffc02095b8:	856a                	mv	a0,s10
ffffffffc02095ba:	161010ef          	jal	ra,ffffffffc020af1a <bitmap_destroy>
ffffffffc02095be:	67a2                	ld	a5,8(sp)
ffffffffc02095c0:	8a3e                	mv	s4,a5
ffffffffc02095c2:	8562                	mv	a0,s8
ffffffffc02095c4:	bbcfa0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc02095c8:	8526                	mv	a0,s1
ffffffffc02095ca:	bb6fa0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc02095ce:	8522                	mv	a0,s0
ffffffffc02095d0:	bb0fa0ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc02095d4:	70aa                	ld	ra,168(sp)
ffffffffc02095d6:	740a                	ld	s0,160(sp)
ffffffffc02095d8:	64ea                	ld	s1,152(sp)
ffffffffc02095da:	694a                	ld	s2,144(sp)
ffffffffc02095dc:	69aa                	ld	s3,136(sp)
ffffffffc02095de:	7ae6                	ld	s5,120(sp)
ffffffffc02095e0:	7b46                	ld	s6,112(sp)
ffffffffc02095e2:	7ba6                	ld	s7,104(sp)
ffffffffc02095e4:	7c06                	ld	s8,96(sp)
ffffffffc02095e6:	6ce6                	ld	s9,88(sp)
ffffffffc02095e8:	6d46                	ld	s10,80(sp)
ffffffffc02095ea:	6da6                	ld	s11,72(sp)
ffffffffc02095ec:	8552                	mv	a0,s4
ffffffffc02095ee:	6a0a                	ld	s4,128(sp)
ffffffffc02095f0:	614d                	addi	sp,sp,176
ffffffffc02095f2:	8082                	ret
ffffffffc02095f4:	5a71                	li	s4,-4
ffffffffc02095f6:	bfe1                	j	ffffffffc02095ce <sfs_do_mount+0x18a>
ffffffffc02095f8:	85be                	mv	a1,a5
ffffffffc02095fa:	00006517          	auipc	a0,0x6
ffffffffc02095fe:	b7e50513          	addi	a0,a0,-1154 # ffffffffc020f178 <dev_node_ops+0x1b0>
ffffffffc0209602:	b29f60ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0209606:	5a75                	li	s4,-3
ffffffffc0209608:	b7c1                	j	ffffffffc02095c8 <sfs_do_mount+0x184>
ffffffffc020960a:	00006517          	auipc	a0,0x6
ffffffffc020960e:	b3650513          	addi	a0,a0,-1226 # ffffffffc020f140 <dev_node_ops+0x178>
ffffffffc0209612:	b19f60ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc0209616:	5a75                	li	s4,-3
ffffffffc0209618:	bf45                	j	ffffffffc02095c8 <sfs_do_mount+0x184>
ffffffffc020961a:	00442903          	lw	s2,4(s0)
ffffffffc020961e:	4481                	li	s1,0
ffffffffc0209620:	080b8c63          	beqz	s7,ffffffffc02096b8 <sfs_do_mount+0x274>
ffffffffc0209624:	85a6                	mv	a1,s1
ffffffffc0209626:	856a                	mv	a0,s10
ffffffffc0209628:	079010ef          	jal	ra,ffffffffc020aea0 <bitmap_test>
ffffffffc020962c:	c111                	beqz	a0,ffffffffc0209630 <sfs_do_mount+0x1ec>
ffffffffc020962e:	2b05                	addiw	s6,s6,1
ffffffffc0209630:	2485                	addiw	s1,s1,1
ffffffffc0209632:	fe9b99e3          	bne	s7,s1,ffffffffc0209624 <sfs_do_mount+0x1e0>
ffffffffc0209636:	441c                	lw	a5,8(s0)
ffffffffc0209638:	0d679463          	bne	a5,s6,ffffffffc0209700 <sfs_do_mount+0x2bc>
ffffffffc020963c:	4585                	li	a1,1
ffffffffc020963e:	05040513          	addi	a0,s0,80
ffffffffc0209642:	04043023          	sd	zero,64(s0)
ffffffffc0209646:	a06fb0ef          	jal	ra,ffffffffc020484c <sem_init>
ffffffffc020964a:	4585                	li	a1,1
ffffffffc020964c:	06840513          	addi	a0,s0,104
ffffffffc0209650:	9fcfb0ef          	jal	ra,ffffffffc020484c <sem_init>
ffffffffc0209654:	4585                	li	a1,1
ffffffffc0209656:	08040513          	addi	a0,s0,128
ffffffffc020965a:	9f2fb0ef          	jal	ra,ffffffffc020484c <sem_init>
ffffffffc020965e:	09840793          	addi	a5,s0,152
ffffffffc0209662:	f05c                	sd	a5,160(s0)
ffffffffc0209664:	ec5c                	sd	a5,152(s0)
ffffffffc0209666:	874a                	mv	a4,s2
ffffffffc0209668:	86da                	mv	a3,s6
ffffffffc020966a:	4169063b          	subw	a2,s2,s6
ffffffffc020966e:	00c40593          	addi	a1,s0,12
ffffffffc0209672:	00006517          	auipc	a0,0x6
ffffffffc0209676:	b9650513          	addi	a0,a0,-1130 # ffffffffc020f208 <dev_node_ops+0x240>
ffffffffc020967a:	ab1f60ef          	jal	ra,ffffffffc020012a <cprintf>
ffffffffc020967e:	00000797          	auipc	a5,0x0
ffffffffc0209682:	c8878793          	addi	a5,a5,-888 # ffffffffc0209306 <sfs_sync>
ffffffffc0209686:	fc5c                	sd	a5,184(s0)
ffffffffc0209688:	00000797          	auipc	a5,0x0
ffffffffc020968c:	d6478793          	addi	a5,a5,-668 # ffffffffc02093ec <sfs_get_root>
ffffffffc0209690:	e07c                	sd	a5,192(s0)
ffffffffc0209692:	00000797          	auipc	a5,0x0
ffffffffc0209696:	b5e78793          	addi	a5,a5,-1186 # ffffffffc02091f0 <sfs_unmount>
ffffffffc020969a:	e47c                	sd	a5,200(s0)
ffffffffc020969c:	00000797          	auipc	a5,0x0
ffffffffc02096a0:	bd878793          	addi	a5,a5,-1064 # ffffffffc0209274 <sfs_cleanup>
ffffffffc02096a4:	e87c                	sd	a5,208(s0)
ffffffffc02096a6:	008ab023          	sd	s0,0(s5)
ffffffffc02096aa:	b72d                	j	ffffffffc02095d4 <sfs_do_mount+0x190>
ffffffffc02096ac:	5a71                	li	s4,-4
ffffffffc02096ae:	bf11                	j	ffffffffc02095c2 <sfs_do_mount+0x17e>
ffffffffc02096b0:	5a49                	li	s4,-14
ffffffffc02096b2:	b70d                	j	ffffffffc02095d4 <sfs_do_mount+0x190>
ffffffffc02096b4:	5a71                	li	s4,-4
ffffffffc02096b6:	bf09                	j	ffffffffc02095c8 <sfs_do_mount+0x184>
ffffffffc02096b8:	4b01                	li	s6,0
ffffffffc02096ba:	bfb5                	j	ffffffffc0209636 <sfs_do_mount+0x1f2>
ffffffffc02096bc:	5a71                	li	s4,-4
ffffffffc02096be:	bf19                	j	ffffffffc02095d4 <sfs_do_mount+0x190>
ffffffffc02096c0:	00006697          	auipc	a3,0x6
ffffffffc02096c4:	ae868693          	addi	a3,a3,-1304 # ffffffffc020f1a8 <dev_node_ops+0x1e0>
ffffffffc02096c8:	00002617          	auipc	a2,0x2
ffffffffc02096cc:	65860613          	addi	a2,a2,1624 # ffffffffc020bd20 <commands+0x250>
ffffffffc02096d0:	08300593          	li	a1,131
ffffffffc02096d4:	00006517          	auipc	a0,0x6
ffffffffc02096d8:	9dc50513          	addi	a0,a0,-1572 # ffffffffc020f0b0 <dev_node_ops+0xe8>
ffffffffc02096dc:	b53f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02096e0:	00006697          	auipc	a3,0x6
ffffffffc02096e4:	9a068693          	addi	a3,a3,-1632 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc02096e8:	00002617          	auipc	a2,0x2
ffffffffc02096ec:	63860613          	addi	a2,a2,1592 # ffffffffc020bd20 <commands+0x250>
ffffffffc02096f0:	0a300593          	li	a1,163
ffffffffc02096f4:	00006517          	auipc	a0,0x6
ffffffffc02096f8:	9bc50513          	addi	a0,a0,-1604 # ffffffffc020f0b0 <dev_node_ops+0xe8>
ffffffffc02096fc:	b33f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209700:	00006697          	auipc	a3,0x6
ffffffffc0209704:	ad868693          	addi	a3,a3,-1320 # ffffffffc020f1d8 <dev_node_ops+0x210>
ffffffffc0209708:	00002617          	auipc	a2,0x2
ffffffffc020970c:	61860613          	addi	a2,a2,1560 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209710:	0e000593          	li	a1,224
ffffffffc0209714:	00006517          	auipc	a0,0x6
ffffffffc0209718:	99c50513          	addi	a0,a0,-1636 # ffffffffc020f0b0 <dev_node_ops+0xe8>
ffffffffc020971c:	b13f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209720 <sfs_mount>:
ffffffffc0209720:	00000597          	auipc	a1,0x0
ffffffffc0209724:	d2458593          	addi	a1,a1,-732 # ffffffffc0209444 <sfs_do_mount>
ffffffffc0209728:	e96fe06f          	j	ffffffffc0207dbe <vfs_mount>

ffffffffc020972c <sfs_opendir>:
ffffffffc020972c:	0235f593          	andi	a1,a1,35
ffffffffc0209730:	4501                	li	a0,0
ffffffffc0209732:	e191                	bnez	a1,ffffffffc0209736 <sfs_opendir+0xa>
ffffffffc0209734:	8082                	ret
ffffffffc0209736:	553d                	li	a0,-17
ffffffffc0209738:	8082                	ret

ffffffffc020973a <sfs_openfile>:
ffffffffc020973a:	4501                	li	a0,0
ffffffffc020973c:	8082                	ret

ffffffffc020973e <sfs_gettype>:
ffffffffc020973e:	1141                	addi	sp,sp,-16
ffffffffc0209740:	e406                	sd	ra,8(sp)
ffffffffc0209742:	c939                	beqz	a0,ffffffffc0209798 <sfs_gettype+0x5a>
ffffffffc0209744:	4d34                	lw	a3,88(a0)
ffffffffc0209746:	6785                	lui	a5,0x1
ffffffffc0209748:	23578713          	addi	a4,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020974c:	04e69663          	bne	a3,a4,ffffffffc0209798 <sfs_gettype+0x5a>
ffffffffc0209750:	6114                	ld	a3,0(a0)
ffffffffc0209752:	4709                	li	a4,2
ffffffffc0209754:	0046d683          	lhu	a3,4(a3)
ffffffffc0209758:	02e68a63          	beq	a3,a4,ffffffffc020978c <sfs_gettype+0x4e>
ffffffffc020975c:	470d                	li	a4,3
ffffffffc020975e:	02e68163          	beq	a3,a4,ffffffffc0209780 <sfs_gettype+0x42>
ffffffffc0209762:	4705                	li	a4,1
ffffffffc0209764:	00e68f63          	beq	a3,a4,ffffffffc0209782 <sfs_gettype+0x44>
ffffffffc0209768:	00006617          	auipc	a2,0x6
ffffffffc020976c:	b1060613          	addi	a2,a2,-1264 # ffffffffc020f278 <dev_node_ops+0x2b0>
ffffffffc0209770:	39600593          	li	a1,918
ffffffffc0209774:	00006517          	auipc	a0,0x6
ffffffffc0209778:	aec50513          	addi	a0,a0,-1300 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020977c:	ab3f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209780:	678d                	lui	a5,0x3
ffffffffc0209782:	60a2                	ld	ra,8(sp)
ffffffffc0209784:	c19c                	sw	a5,0(a1)
ffffffffc0209786:	4501                	li	a0,0
ffffffffc0209788:	0141                	addi	sp,sp,16
ffffffffc020978a:	8082                	ret
ffffffffc020978c:	60a2                	ld	ra,8(sp)
ffffffffc020978e:	6789                	lui	a5,0x2
ffffffffc0209790:	c19c                	sw	a5,0(a1)
ffffffffc0209792:	4501                	li	a0,0
ffffffffc0209794:	0141                	addi	sp,sp,16
ffffffffc0209796:	8082                	ret
ffffffffc0209798:	00006697          	auipc	a3,0x6
ffffffffc020979c:	a9068693          	addi	a3,a3,-1392 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc02097a0:	00002617          	auipc	a2,0x2
ffffffffc02097a4:	58060613          	addi	a2,a2,1408 # ffffffffc020bd20 <commands+0x250>
ffffffffc02097a8:	38a00593          	li	a1,906
ffffffffc02097ac:	00006517          	auipc	a0,0x6
ffffffffc02097b0:	ab450513          	addi	a0,a0,-1356 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc02097b4:	a7bf60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02097b8 <sfs_fsync>:
ffffffffc02097b8:	7179                	addi	sp,sp,-48
ffffffffc02097ba:	ec26                	sd	s1,24(sp)
ffffffffc02097bc:	7524                	ld	s1,104(a0)
ffffffffc02097be:	f406                	sd	ra,40(sp)
ffffffffc02097c0:	f022                	sd	s0,32(sp)
ffffffffc02097c2:	e84a                	sd	s2,16(sp)
ffffffffc02097c4:	e44e                	sd	s3,8(sp)
ffffffffc02097c6:	c4bd                	beqz	s1,ffffffffc0209834 <sfs_fsync+0x7c>
ffffffffc02097c8:	0b04a783          	lw	a5,176(s1)
ffffffffc02097cc:	e7a5                	bnez	a5,ffffffffc0209834 <sfs_fsync+0x7c>
ffffffffc02097ce:	4d38                	lw	a4,88(a0)
ffffffffc02097d0:	6785                	lui	a5,0x1
ffffffffc02097d2:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc02097d6:	842a                	mv	s0,a0
ffffffffc02097d8:	06f71e63          	bne	a4,a5,ffffffffc0209854 <sfs_fsync+0x9c>
ffffffffc02097dc:	691c                	ld	a5,16(a0)
ffffffffc02097de:	4901                	li	s2,0
ffffffffc02097e0:	eb89                	bnez	a5,ffffffffc02097f2 <sfs_fsync+0x3a>
ffffffffc02097e2:	70a2                	ld	ra,40(sp)
ffffffffc02097e4:	7402                	ld	s0,32(sp)
ffffffffc02097e6:	64e2                	ld	s1,24(sp)
ffffffffc02097e8:	69a2                	ld	s3,8(sp)
ffffffffc02097ea:	854a                	mv	a0,s2
ffffffffc02097ec:	6942                	ld	s2,16(sp)
ffffffffc02097ee:	6145                	addi	sp,sp,48
ffffffffc02097f0:	8082                	ret
ffffffffc02097f2:	02050993          	addi	s3,a0,32
ffffffffc02097f6:	854e                	mv	a0,s3
ffffffffc02097f8:	860fb0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc02097fc:	681c                	ld	a5,16(s0)
ffffffffc02097fe:	ef81                	bnez	a5,ffffffffc0209816 <sfs_fsync+0x5e>
ffffffffc0209800:	854e                	mv	a0,s3
ffffffffc0209802:	852fb0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc0209806:	70a2                	ld	ra,40(sp)
ffffffffc0209808:	7402                	ld	s0,32(sp)
ffffffffc020980a:	64e2                	ld	s1,24(sp)
ffffffffc020980c:	69a2                	ld	s3,8(sp)
ffffffffc020980e:	854a                	mv	a0,s2
ffffffffc0209810:	6942                	ld	s2,16(sp)
ffffffffc0209812:	6145                	addi	sp,sp,48
ffffffffc0209814:	8082                	ret
ffffffffc0209816:	4414                	lw	a3,8(s0)
ffffffffc0209818:	600c                	ld	a1,0(s0)
ffffffffc020981a:	00043823          	sd	zero,16(s0)
ffffffffc020981e:	4701                	li	a4,0
ffffffffc0209820:	04000613          	li	a2,64
ffffffffc0209824:	8526                	mv	a0,s1
ffffffffc0209826:	0b5010ef          	jal	ra,ffffffffc020b0da <sfs_wbuf>
ffffffffc020982a:	892a                	mv	s2,a0
ffffffffc020982c:	d971                	beqz	a0,ffffffffc0209800 <sfs_fsync+0x48>
ffffffffc020982e:	4785                	li	a5,1
ffffffffc0209830:	e81c                	sd	a5,16(s0)
ffffffffc0209832:	b7f9                	j	ffffffffc0209800 <sfs_fsync+0x48>
ffffffffc0209834:	00006697          	auipc	a3,0x6
ffffffffc0209838:	84c68693          	addi	a3,a3,-1972 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc020983c:	00002617          	auipc	a2,0x2
ffffffffc0209840:	4e460613          	addi	a2,a2,1252 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209844:	2ce00593          	li	a1,718
ffffffffc0209848:	00006517          	auipc	a0,0x6
ffffffffc020984c:	a1850513          	addi	a0,a0,-1512 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209850:	9dff60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209854:	00006697          	auipc	a3,0x6
ffffffffc0209858:	9d468693          	addi	a3,a3,-1580 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc020985c:	00002617          	auipc	a2,0x2
ffffffffc0209860:	4c460613          	addi	a2,a2,1220 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209864:	2cf00593          	li	a1,719
ffffffffc0209868:	00006517          	auipc	a0,0x6
ffffffffc020986c:	9f850513          	addi	a0,a0,-1544 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209870:	9bff60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209874 <sfs_fstat>:
ffffffffc0209874:	1101                	addi	sp,sp,-32
ffffffffc0209876:	e426                	sd	s1,8(sp)
ffffffffc0209878:	84ae                	mv	s1,a1
ffffffffc020987a:	e822                	sd	s0,16(sp)
ffffffffc020987c:	02000613          	li	a2,32
ffffffffc0209880:	842a                	mv	s0,a0
ffffffffc0209882:	4581                	li	a1,0
ffffffffc0209884:	8526                	mv	a0,s1
ffffffffc0209886:	ec06                	sd	ra,24(sp)
ffffffffc0209888:	2a5010ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc020988c:	c439                	beqz	s0,ffffffffc02098da <sfs_fstat+0x66>
ffffffffc020988e:	783c                	ld	a5,112(s0)
ffffffffc0209890:	c7a9                	beqz	a5,ffffffffc02098da <sfs_fstat+0x66>
ffffffffc0209892:	6bbc                	ld	a5,80(a5)
ffffffffc0209894:	c3b9                	beqz	a5,ffffffffc02098da <sfs_fstat+0x66>
ffffffffc0209896:	00005597          	auipc	a1,0x5
ffffffffc020989a:	00a58593          	addi	a1,a1,10 # ffffffffc020e8a0 <syscalls+0x990>
ffffffffc020989e:	8522                	mv	a0,s0
ffffffffc02098a0:	aa5fe0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc02098a4:	783c                	ld	a5,112(s0)
ffffffffc02098a6:	85a6                	mv	a1,s1
ffffffffc02098a8:	8522                	mv	a0,s0
ffffffffc02098aa:	6bbc                	ld	a5,80(a5)
ffffffffc02098ac:	9782                	jalr	a5
ffffffffc02098ae:	e10d                	bnez	a0,ffffffffc02098d0 <sfs_fstat+0x5c>
ffffffffc02098b0:	4c38                	lw	a4,88(s0)
ffffffffc02098b2:	6785                	lui	a5,0x1
ffffffffc02098b4:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc02098b8:	04f71163          	bne	a4,a5,ffffffffc02098fa <sfs_fstat+0x86>
ffffffffc02098bc:	601c                	ld	a5,0(s0)
ffffffffc02098be:	0067d683          	lhu	a3,6(a5)
ffffffffc02098c2:	0087e703          	lwu	a4,8(a5)
ffffffffc02098c6:	0007e783          	lwu	a5,0(a5)
ffffffffc02098ca:	e494                	sd	a3,8(s1)
ffffffffc02098cc:	e898                	sd	a4,16(s1)
ffffffffc02098ce:	ec9c                	sd	a5,24(s1)
ffffffffc02098d0:	60e2                	ld	ra,24(sp)
ffffffffc02098d2:	6442                	ld	s0,16(sp)
ffffffffc02098d4:	64a2                	ld	s1,8(sp)
ffffffffc02098d6:	6105                	addi	sp,sp,32
ffffffffc02098d8:	8082                	ret
ffffffffc02098da:	00005697          	auipc	a3,0x5
ffffffffc02098de:	f5e68693          	addi	a3,a3,-162 # ffffffffc020e838 <syscalls+0x928>
ffffffffc02098e2:	00002617          	auipc	a2,0x2
ffffffffc02098e6:	43e60613          	addi	a2,a2,1086 # ffffffffc020bd20 <commands+0x250>
ffffffffc02098ea:	2bf00593          	li	a1,703
ffffffffc02098ee:	00006517          	auipc	a0,0x6
ffffffffc02098f2:	97250513          	addi	a0,a0,-1678 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc02098f6:	939f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc02098fa:	00006697          	auipc	a3,0x6
ffffffffc02098fe:	92e68693          	addi	a3,a3,-1746 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc0209902:	00002617          	auipc	a2,0x2
ffffffffc0209906:	41e60613          	addi	a2,a2,1054 # ffffffffc020bd20 <commands+0x250>
ffffffffc020990a:	2c200593          	li	a1,706
ffffffffc020990e:	00006517          	auipc	a0,0x6
ffffffffc0209912:	95250513          	addi	a0,a0,-1710 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209916:	919f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020991a <sfs_tryseek>:
ffffffffc020991a:	080007b7          	lui	a5,0x8000
ffffffffc020991e:	04f5fd63          	bgeu	a1,a5,ffffffffc0209978 <sfs_tryseek+0x5e>
ffffffffc0209922:	1101                	addi	sp,sp,-32
ffffffffc0209924:	e822                	sd	s0,16(sp)
ffffffffc0209926:	ec06                	sd	ra,24(sp)
ffffffffc0209928:	e426                	sd	s1,8(sp)
ffffffffc020992a:	842a                	mv	s0,a0
ffffffffc020992c:	c921                	beqz	a0,ffffffffc020997c <sfs_tryseek+0x62>
ffffffffc020992e:	4d38                	lw	a4,88(a0)
ffffffffc0209930:	6785                	lui	a5,0x1
ffffffffc0209932:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209936:	04f71363          	bne	a4,a5,ffffffffc020997c <sfs_tryseek+0x62>
ffffffffc020993a:	611c                	ld	a5,0(a0)
ffffffffc020993c:	84ae                	mv	s1,a1
ffffffffc020993e:	0007e783          	lwu	a5,0(a5)
ffffffffc0209942:	02b7d563          	bge	a5,a1,ffffffffc020996c <sfs_tryseek+0x52>
ffffffffc0209946:	793c                	ld	a5,112(a0)
ffffffffc0209948:	cbb1                	beqz	a5,ffffffffc020999c <sfs_tryseek+0x82>
ffffffffc020994a:	73bc                	ld	a5,96(a5)
ffffffffc020994c:	cba1                	beqz	a5,ffffffffc020999c <sfs_tryseek+0x82>
ffffffffc020994e:	00005597          	auipc	a1,0x5
ffffffffc0209952:	3d258593          	addi	a1,a1,978 # ffffffffc020ed20 <syscalls+0xe10>
ffffffffc0209956:	9effe0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc020995a:	783c                	ld	a5,112(s0)
ffffffffc020995c:	8522                	mv	a0,s0
ffffffffc020995e:	6442                	ld	s0,16(sp)
ffffffffc0209960:	60e2                	ld	ra,24(sp)
ffffffffc0209962:	73bc                	ld	a5,96(a5)
ffffffffc0209964:	85a6                	mv	a1,s1
ffffffffc0209966:	64a2                	ld	s1,8(sp)
ffffffffc0209968:	6105                	addi	sp,sp,32
ffffffffc020996a:	8782                	jr	a5
ffffffffc020996c:	60e2                	ld	ra,24(sp)
ffffffffc020996e:	6442                	ld	s0,16(sp)
ffffffffc0209970:	64a2                	ld	s1,8(sp)
ffffffffc0209972:	4501                	li	a0,0
ffffffffc0209974:	6105                	addi	sp,sp,32
ffffffffc0209976:	8082                	ret
ffffffffc0209978:	5575                	li	a0,-3
ffffffffc020997a:	8082                	ret
ffffffffc020997c:	00006697          	auipc	a3,0x6
ffffffffc0209980:	8ac68693          	addi	a3,a3,-1876 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc0209984:	00002617          	auipc	a2,0x2
ffffffffc0209988:	39c60613          	addi	a2,a2,924 # ffffffffc020bd20 <commands+0x250>
ffffffffc020998c:	3a100593          	li	a1,929
ffffffffc0209990:	00006517          	auipc	a0,0x6
ffffffffc0209994:	8d050513          	addi	a0,a0,-1840 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209998:	897f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020999c:	00005697          	auipc	a3,0x5
ffffffffc02099a0:	32c68693          	addi	a3,a3,812 # ffffffffc020ecc8 <syscalls+0xdb8>
ffffffffc02099a4:	00002617          	auipc	a2,0x2
ffffffffc02099a8:	37c60613          	addi	a2,a2,892 # ffffffffc020bd20 <commands+0x250>
ffffffffc02099ac:	3a300593          	li	a1,931
ffffffffc02099b0:	00006517          	auipc	a0,0x6
ffffffffc02099b4:	8b050513          	addi	a0,a0,-1872 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc02099b8:	877f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc02099bc <sfs_close>:
ffffffffc02099bc:	1141                	addi	sp,sp,-16
ffffffffc02099be:	e406                	sd	ra,8(sp)
ffffffffc02099c0:	e022                	sd	s0,0(sp)
ffffffffc02099c2:	c11d                	beqz	a0,ffffffffc02099e8 <sfs_close+0x2c>
ffffffffc02099c4:	793c                	ld	a5,112(a0)
ffffffffc02099c6:	842a                	mv	s0,a0
ffffffffc02099c8:	c385                	beqz	a5,ffffffffc02099e8 <sfs_close+0x2c>
ffffffffc02099ca:	7b9c                	ld	a5,48(a5)
ffffffffc02099cc:	cf91                	beqz	a5,ffffffffc02099e8 <sfs_close+0x2c>
ffffffffc02099ce:	00004597          	auipc	a1,0x4
ffffffffc02099d2:	db258593          	addi	a1,a1,-590 # ffffffffc020d780 <default_pmm_manager+0x460>
ffffffffc02099d6:	96ffe0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc02099da:	783c                	ld	a5,112(s0)
ffffffffc02099dc:	8522                	mv	a0,s0
ffffffffc02099de:	6402                	ld	s0,0(sp)
ffffffffc02099e0:	60a2                	ld	ra,8(sp)
ffffffffc02099e2:	7b9c                	ld	a5,48(a5)
ffffffffc02099e4:	0141                	addi	sp,sp,16
ffffffffc02099e6:	8782                	jr	a5
ffffffffc02099e8:	00004697          	auipc	a3,0x4
ffffffffc02099ec:	d4868693          	addi	a3,a3,-696 # ffffffffc020d730 <default_pmm_manager+0x410>
ffffffffc02099f0:	00002617          	auipc	a2,0x2
ffffffffc02099f4:	33060613          	addi	a2,a2,816 # ffffffffc020bd20 <commands+0x250>
ffffffffc02099f8:	21c00593          	li	a1,540
ffffffffc02099fc:	00006517          	auipc	a0,0x6
ffffffffc0209a00:	86450513          	addi	a0,a0,-1948 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209a04:	82bf60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209a08 <sfs_io.part.0>:
ffffffffc0209a08:	1141                	addi	sp,sp,-16
ffffffffc0209a0a:	00006697          	auipc	a3,0x6
ffffffffc0209a0e:	81e68693          	addi	a3,a3,-2018 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc0209a12:	00002617          	auipc	a2,0x2
ffffffffc0209a16:	30e60613          	addi	a2,a2,782 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209a1a:	29e00593          	li	a1,670
ffffffffc0209a1e:	00006517          	auipc	a0,0x6
ffffffffc0209a22:	84250513          	addi	a0,a0,-1982 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209a26:	e406                	sd	ra,8(sp)
ffffffffc0209a28:	807f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209a2c <sfs_block_free>:
ffffffffc0209a2c:	1101                	addi	sp,sp,-32
ffffffffc0209a2e:	e426                	sd	s1,8(sp)
ffffffffc0209a30:	ec06                	sd	ra,24(sp)
ffffffffc0209a32:	e822                	sd	s0,16(sp)
ffffffffc0209a34:	4154                	lw	a3,4(a0)
ffffffffc0209a36:	84ae                	mv	s1,a1
ffffffffc0209a38:	c595                	beqz	a1,ffffffffc0209a64 <sfs_block_free+0x38>
ffffffffc0209a3a:	02d5f563          	bgeu	a1,a3,ffffffffc0209a64 <sfs_block_free+0x38>
ffffffffc0209a3e:	842a                	mv	s0,a0
ffffffffc0209a40:	7d08                	ld	a0,56(a0)
ffffffffc0209a42:	45e010ef          	jal	ra,ffffffffc020aea0 <bitmap_test>
ffffffffc0209a46:	ed05                	bnez	a0,ffffffffc0209a7e <sfs_block_free+0x52>
ffffffffc0209a48:	7c08                	ld	a0,56(s0)
ffffffffc0209a4a:	85a6                	mv	a1,s1
ffffffffc0209a4c:	47c010ef          	jal	ra,ffffffffc020aec8 <bitmap_free>
ffffffffc0209a50:	441c                	lw	a5,8(s0)
ffffffffc0209a52:	4705                	li	a4,1
ffffffffc0209a54:	60e2                	ld	ra,24(sp)
ffffffffc0209a56:	2785                	addiw	a5,a5,1
ffffffffc0209a58:	e038                	sd	a4,64(s0)
ffffffffc0209a5a:	c41c                	sw	a5,8(s0)
ffffffffc0209a5c:	6442                	ld	s0,16(sp)
ffffffffc0209a5e:	64a2                	ld	s1,8(sp)
ffffffffc0209a60:	6105                	addi	sp,sp,32
ffffffffc0209a62:	8082                	ret
ffffffffc0209a64:	8726                	mv	a4,s1
ffffffffc0209a66:	00006617          	auipc	a2,0x6
ffffffffc0209a6a:	82a60613          	addi	a2,a2,-2006 # ffffffffc020f290 <dev_node_ops+0x2c8>
ffffffffc0209a6e:	05300593          	li	a1,83
ffffffffc0209a72:	00005517          	auipc	a0,0x5
ffffffffc0209a76:	7ee50513          	addi	a0,a0,2030 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209a7a:	fb4f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209a7e:	00006697          	auipc	a3,0x6
ffffffffc0209a82:	84a68693          	addi	a3,a3,-1974 # ffffffffc020f2c8 <dev_node_ops+0x300>
ffffffffc0209a86:	00002617          	auipc	a2,0x2
ffffffffc0209a8a:	29a60613          	addi	a2,a2,666 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209a8e:	06a00593          	li	a1,106
ffffffffc0209a92:	00005517          	auipc	a0,0x5
ffffffffc0209a96:	7ce50513          	addi	a0,a0,1998 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209a9a:	f94f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209a9e <sfs_reclaim>:
ffffffffc0209a9e:	1101                	addi	sp,sp,-32
ffffffffc0209aa0:	e426                	sd	s1,8(sp)
ffffffffc0209aa2:	7524                	ld	s1,104(a0)
ffffffffc0209aa4:	ec06                	sd	ra,24(sp)
ffffffffc0209aa6:	e822                	sd	s0,16(sp)
ffffffffc0209aa8:	e04a                	sd	s2,0(sp)
ffffffffc0209aaa:	0e048a63          	beqz	s1,ffffffffc0209b9e <sfs_reclaim+0x100>
ffffffffc0209aae:	0b04a783          	lw	a5,176(s1)
ffffffffc0209ab2:	0e079663          	bnez	a5,ffffffffc0209b9e <sfs_reclaim+0x100>
ffffffffc0209ab6:	4d38                	lw	a4,88(a0)
ffffffffc0209ab8:	6785                	lui	a5,0x1
ffffffffc0209aba:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209abe:	842a                	mv	s0,a0
ffffffffc0209ac0:	10f71f63          	bne	a4,a5,ffffffffc0209bde <sfs_reclaim+0x140>
ffffffffc0209ac4:	8526                	mv	a0,s1
ffffffffc0209ac6:	f0aff0ef          	jal	ra,ffffffffc02091d0 <lock_sfs_fs>
ffffffffc0209aca:	4c1c                	lw	a5,24(s0)
ffffffffc0209acc:	0ef05963          	blez	a5,ffffffffc0209bbe <sfs_reclaim+0x120>
ffffffffc0209ad0:	fff7871b          	addiw	a4,a5,-1
ffffffffc0209ad4:	cc18                	sw	a4,24(s0)
ffffffffc0209ad6:	eb59                	bnez	a4,ffffffffc0209b6c <sfs_reclaim+0xce>
ffffffffc0209ad8:	05c42903          	lw	s2,92(s0)
ffffffffc0209adc:	08091863          	bnez	s2,ffffffffc0209b6c <sfs_reclaim+0xce>
ffffffffc0209ae0:	601c                	ld	a5,0(s0)
ffffffffc0209ae2:	0067d783          	lhu	a5,6(a5)
ffffffffc0209ae6:	e785                	bnez	a5,ffffffffc0209b0e <sfs_reclaim+0x70>
ffffffffc0209ae8:	783c                	ld	a5,112(s0)
ffffffffc0209aea:	10078a63          	beqz	a5,ffffffffc0209bfe <sfs_reclaim+0x160>
ffffffffc0209aee:	73bc                	ld	a5,96(a5)
ffffffffc0209af0:	10078763          	beqz	a5,ffffffffc0209bfe <sfs_reclaim+0x160>
ffffffffc0209af4:	00005597          	auipc	a1,0x5
ffffffffc0209af8:	22c58593          	addi	a1,a1,556 # ffffffffc020ed20 <syscalls+0xe10>
ffffffffc0209afc:	8522                	mv	a0,s0
ffffffffc0209afe:	847fe0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc0209b02:	783c                	ld	a5,112(s0)
ffffffffc0209b04:	4581                	li	a1,0
ffffffffc0209b06:	8522                	mv	a0,s0
ffffffffc0209b08:	73bc                	ld	a5,96(a5)
ffffffffc0209b0a:	9782                	jalr	a5
ffffffffc0209b0c:	e559                	bnez	a0,ffffffffc0209b9a <sfs_reclaim+0xfc>
ffffffffc0209b0e:	681c                	ld	a5,16(s0)
ffffffffc0209b10:	c39d                	beqz	a5,ffffffffc0209b36 <sfs_reclaim+0x98>
ffffffffc0209b12:	783c                	ld	a5,112(s0)
ffffffffc0209b14:	10078563          	beqz	a5,ffffffffc0209c1e <sfs_reclaim+0x180>
ffffffffc0209b18:	7b9c                	ld	a5,48(a5)
ffffffffc0209b1a:	10078263          	beqz	a5,ffffffffc0209c1e <sfs_reclaim+0x180>
ffffffffc0209b1e:	8522                	mv	a0,s0
ffffffffc0209b20:	00004597          	auipc	a1,0x4
ffffffffc0209b24:	c6058593          	addi	a1,a1,-928 # ffffffffc020d780 <default_pmm_manager+0x460>
ffffffffc0209b28:	81dfe0ef          	jal	ra,ffffffffc0208344 <inode_check>
ffffffffc0209b2c:	783c                	ld	a5,112(s0)
ffffffffc0209b2e:	8522                	mv	a0,s0
ffffffffc0209b30:	7b9c                	ld	a5,48(a5)
ffffffffc0209b32:	9782                	jalr	a5
ffffffffc0209b34:	e13d                	bnez	a0,ffffffffc0209b9a <sfs_reclaim+0xfc>
ffffffffc0209b36:	7c18                	ld	a4,56(s0)
ffffffffc0209b38:	603c                	ld	a5,64(s0)
ffffffffc0209b3a:	8526                	mv	a0,s1
ffffffffc0209b3c:	e71c                	sd	a5,8(a4)
ffffffffc0209b3e:	e398                	sd	a4,0(a5)
ffffffffc0209b40:	6438                	ld	a4,72(s0)
ffffffffc0209b42:	683c                	ld	a5,80(s0)
ffffffffc0209b44:	e71c                	sd	a5,8(a4)
ffffffffc0209b46:	e398                	sd	a4,0(a5)
ffffffffc0209b48:	e98ff0ef          	jal	ra,ffffffffc02091e0 <unlock_sfs_fs>
ffffffffc0209b4c:	6008                	ld	a0,0(s0)
ffffffffc0209b4e:	00655783          	lhu	a5,6(a0)
ffffffffc0209b52:	cb85                	beqz	a5,ffffffffc0209b82 <sfs_reclaim+0xe4>
ffffffffc0209b54:	e2df90ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc0209b58:	8522                	mv	a0,s0
ffffffffc0209b5a:	f7efe0ef          	jal	ra,ffffffffc02082d8 <inode_kill>
ffffffffc0209b5e:	60e2                	ld	ra,24(sp)
ffffffffc0209b60:	6442                	ld	s0,16(sp)
ffffffffc0209b62:	64a2                	ld	s1,8(sp)
ffffffffc0209b64:	854a                	mv	a0,s2
ffffffffc0209b66:	6902                	ld	s2,0(sp)
ffffffffc0209b68:	6105                	addi	sp,sp,32
ffffffffc0209b6a:	8082                	ret
ffffffffc0209b6c:	5945                	li	s2,-15
ffffffffc0209b6e:	8526                	mv	a0,s1
ffffffffc0209b70:	e70ff0ef          	jal	ra,ffffffffc02091e0 <unlock_sfs_fs>
ffffffffc0209b74:	60e2                	ld	ra,24(sp)
ffffffffc0209b76:	6442                	ld	s0,16(sp)
ffffffffc0209b78:	64a2                	ld	s1,8(sp)
ffffffffc0209b7a:	854a                	mv	a0,s2
ffffffffc0209b7c:	6902                	ld	s2,0(sp)
ffffffffc0209b7e:	6105                	addi	sp,sp,32
ffffffffc0209b80:	8082                	ret
ffffffffc0209b82:	440c                	lw	a1,8(s0)
ffffffffc0209b84:	8526                	mv	a0,s1
ffffffffc0209b86:	ea7ff0ef          	jal	ra,ffffffffc0209a2c <sfs_block_free>
ffffffffc0209b8a:	6008                	ld	a0,0(s0)
ffffffffc0209b8c:	5d4c                	lw	a1,60(a0)
ffffffffc0209b8e:	d1f9                	beqz	a1,ffffffffc0209b54 <sfs_reclaim+0xb6>
ffffffffc0209b90:	8526                	mv	a0,s1
ffffffffc0209b92:	e9bff0ef          	jal	ra,ffffffffc0209a2c <sfs_block_free>
ffffffffc0209b96:	6008                	ld	a0,0(s0)
ffffffffc0209b98:	bf75                	j	ffffffffc0209b54 <sfs_reclaim+0xb6>
ffffffffc0209b9a:	892a                	mv	s2,a0
ffffffffc0209b9c:	bfc9                	j	ffffffffc0209b6e <sfs_reclaim+0xd0>
ffffffffc0209b9e:	00005697          	auipc	a3,0x5
ffffffffc0209ba2:	4e268693          	addi	a3,a3,1250 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc0209ba6:	00002617          	auipc	a2,0x2
ffffffffc0209baa:	17a60613          	addi	a2,a2,378 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209bae:	35f00593          	li	a1,863
ffffffffc0209bb2:	00005517          	auipc	a0,0x5
ffffffffc0209bb6:	6ae50513          	addi	a0,a0,1710 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209bba:	e74f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209bbe:	00005697          	auipc	a3,0x5
ffffffffc0209bc2:	72a68693          	addi	a3,a3,1834 # ffffffffc020f2e8 <dev_node_ops+0x320>
ffffffffc0209bc6:	00002617          	auipc	a2,0x2
ffffffffc0209bca:	15a60613          	addi	a2,a2,346 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209bce:	36500593          	li	a1,869
ffffffffc0209bd2:	00005517          	auipc	a0,0x5
ffffffffc0209bd6:	68e50513          	addi	a0,a0,1678 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209bda:	e54f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209bde:	00005697          	auipc	a3,0x5
ffffffffc0209be2:	64a68693          	addi	a3,a3,1610 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc0209be6:	00002617          	auipc	a2,0x2
ffffffffc0209bea:	13a60613          	addi	a2,a2,314 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209bee:	36000593          	li	a1,864
ffffffffc0209bf2:	00005517          	auipc	a0,0x5
ffffffffc0209bf6:	66e50513          	addi	a0,a0,1646 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209bfa:	e34f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209bfe:	00005697          	auipc	a3,0x5
ffffffffc0209c02:	0ca68693          	addi	a3,a3,202 # ffffffffc020ecc8 <syscalls+0xdb8>
ffffffffc0209c06:	00002617          	auipc	a2,0x2
ffffffffc0209c0a:	11a60613          	addi	a2,a2,282 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209c0e:	36a00593          	li	a1,874
ffffffffc0209c12:	00005517          	auipc	a0,0x5
ffffffffc0209c16:	64e50513          	addi	a0,a0,1614 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209c1a:	e14f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209c1e:	00004697          	auipc	a3,0x4
ffffffffc0209c22:	b1268693          	addi	a3,a3,-1262 # ffffffffc020d730 <default_pmm_manager+0x410>
ffffffffc0209c26:	00002617          	auipc	a2,0x2
ffffffffc0209c2a:	0fa60613          	addi	a2,a2,250 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209c2e:	36f00593          	li	a1,879
ffffffffc0209c32:	00005517          	auipc	a0,0x5
ffffffffc0209c36:	62e50513          	addi	a0,a0,1582 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209c3a:	df4f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209c3e <sfs_block_alloc>:
ffffffffc0209c3e:	1101                	addi	sp,sp,-32
ffffffffc0209c40:	e822                	sd	s0,16(sp)
ffffffffc0209c42:	842a                	mv	s0,a0
ffffffffc0209c44:	7d08                	ld	a0,56(a0)
ffffffffc0209c46:	e426                	sd	s1,8(sp)
ffffffffc0209c48:	ec06                	sd	ra,24(sp)
ffffffffc0209c4a:	84ae                	mv	s1,a1
ffffffffc0209c4c:	1e4010ef          	jal	ra,ffffffffc020ae30 <bitmap_alloc>
ffffffffc0209c50:	e90d                	bnez	a0,ffffffffc0209c82 <sfs_block_alloc+0x44>
ffffffffc0209c52:	441c                	lw	a5,8(s0)
ffffffffc0209c54:	cbad                	beqz	a5,ffffffffc0209cc6 <sfs_block_alloc+0x88>
ffffffffc0209c56:	37fd                	addiw	a5,a5,-1
ffffffffc0209c58:	c41c                	sw	a5,8(s0)
ffffffffc0209c5a:	408c                	lw	a1,0(s1)
ffffffffc0209c5c:	4785                	li	a5,1
ffffffffc0209c5e:	e03c                	sd	a5,64(s0)
ffffffffc0209c60:	4054                	lw	a3,4(s0)
ffffffffc0209c62:	c58d                	beqz	a1,ffffffffc0209c8c <sfs_block_alloc+0x4e>
ffffffffc0209c64:	02d5f463          	bgeu	a1,a3,ffffffffc0209c8c <sfs_block_alloc+0x4e>
ffffffffc0209c68:	7c08                	ld	a0,56(s0)
ffffffffc0209c6a:	236010ef          	jal	ra,ffffffffc020aea0 <bitmap_test>
ffffffffc0209c6e:	ed05                	bnez	a0,ffffffffc0209ca6 <sfs_block_alloc+0x68>
ffffffffc0209c70:	8522                	mv	a0,s0
ffffffffc0209c72:	6442                	ld	s0,16(sp)
ffffffffc0209c74:	408c                	lw	a1,0(s1)
ffffffffc0209c76:	60e2                	ld	ra,24(sp)
ffffffffc0209c78:	64a2                	ld	s1,8(sp)
ffffffffc0209c7a:	4605                	li	a2,1
ffffffffc0209c7c:	6105                	addi	sp,sp,32
ffffffffc0209c7e:	5ac0106f          	j	ffffffffc020b22a <sfs_clear_block>
ffffffffc0209c82:	60e2                	ld	ra,24(sp)
ffffffffc0209c84:	6442                	ld	s0,16(sp)
ffffffffc0209c86:	64a2                	ld	s1,8(sp)
ffffffffc0209c88:	6105                	addi	sp,sp,32
ffffffffc0209c8a:	8082                	ret
ffffffffc0209c8c:	872e                	mv	a4,a1
ffffffffc0209c8e:	00005617          	auipc	a2,0x5
ffffffffc0209c92:	60260613          	addi	a2,a2,1538 # ffffffffc020f290 <dev_node_ops+0x2c8>
ffffffffc0209c96:	05300593          	li	a1,83
ffffffffc0209c9a:	00005517          	auipc	a0,0x5
ffffffffc0209c9e:	5c650513          	addi	a0,a0,1478 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209ca2:	d8cf60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209ca6:	00005697          	auipc	a3,0x5
ffffffffc0209caa:	67a68693          	addi	a3,a3,1658 # ffffffffc020f320 <dev_node_ops+0x358>
ffffffffc0209cae:	00002617          	auipc	a2,0x2
ffffffffc0209cb2:	07260613          	addi	a2,a2,114 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209cb6:	06100593          	li	a1,97
ffffffffc0209cba:	00005517          	auipc	a0,0x5
ffffffffc0209cbe:	5a650513          	addi	a0,a0,1446 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209cc2:	d6cf60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209cc6:	00005697          	auipc	a3,0x5
ffffffffc0209cca:	63a68693          	addi	a3,a3,1594 # ffffffffc020f300 <dev_node_ops+0x338>
ffffffffc0209cce:	00002617          	auipc	a2,0x2
ffffffffc0209cd2:	05260613          	addi	a2,a2,82 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209cd6:	05f00593          	li	a1,95
ffffffffc0209cda:	00005517          	auipc	a0,0x5
ffffffffc0209cde:	58650513          	addi	a0,a0,1414 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209ce2:	d4cf60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209ce6 <sfs_bmap_load_nolock>:
ffffffffc0209ce6:	7159                	addi	sp,sp,-112
ffffffffc0209ce8:	f85a                	sd	s6,48(sp)
ffffffffc0209cea:	0005bb03          	ld	s6,0(a1)
ffffffffc0209cee:	f45e                	sd	s7,40(sp)
ffffffffc0209cf0:	f486                	sd	ra,104(sp)
ffffffffc0209cf2:	008b2b83          	lw	s7,8(s6)
ffffffffc0209cf6:	f0a2                	sd	s0,96(sp)
ffffffffc0209cf8:	eca6                	sd	s1,88(sp)
ffffffffc0209cfa:	e8ca                	sd	s2,80(sp)
ffffffffc0209cfc:	e4ce                	sd	s3,72(sp)
ffffffffc0209cfe:	e0d2                	sd	s4,64(sp)
ffffffffc0209d00:	fc56                	sd	s5,56(sp)
ffffffffc0209d02:	f062                	sd	s8,32(sp)
ffffffffc0209d04:	ec66                	sd	s9,24(sp)
ffffffffc0209d06:	18cbe363          	bltu	s7,a2,ffffffffc0209e8c <sfs_bmap_load_nolock+0x1a6>
ffffffffc0209d0a:	47ad                	li	a5,11
ffffffffc0209d0c:	8aae                	mv	s5,a1
ffffffffc0209d0e:	8432                	mv	s0,a2
ffffffffc0209d10:	84aa                	mv	s1,a0
ffffffffc0209d12:	89b6                	mv	s3,a3
ffffffffc0209d14:	04c7f563          	bgeu	a5,a2,ffffffffc0209d5e <sfs_bmap_load_nolock+0x78>
ffffffffc0209d18:	ff46071b          	addiw	a4,a2,-12
ffffffffc0209d1c:	0007069b          	sext.w	a3,a4
ffffffffc0209d20:	3ff00793          	li	a5,1023
ffffffffc0209d24:	1ad7e163          	bltu	a5,a3,ffffffffc0209ec6 <sfs_bmap_load_nolock+0x1e0>
ffffffffc0209d28:	03cb2a03          	lw	s4,60(s6)
ffffffffc0209d2c:	02071793          	slli	a5,a4,0x20
ffffffffc0209d30:	c602                	sw	zero,12(sp)
ffffffffc0209d32:	c452                	sw	s4,8(sp)
ffffffffc0209d34:	01e7dc13          	srli	s8,a5,0x1e
ffffffffc0209d38:	0e0a1e63          	bnez	s4,ffffffffc0209e34 <sfs_bmap_load_nolock+0x14e>
ffffffffc0209d3c:	0acb8663          	beq	s7,a2,ffffffffc0209de8 <sfs_bmap_load_nolock+0x102>
ffffffffc0209d40:	4a01                	li	s4,0
ffffffffc0209d42:	40d4                	lw	a3,4(s1)
ffffffffc0209d44:	8752                	mv	a4,s4
ffffffffc0209d46:	00005617          	auipc	a2,0x5
ffffffffc0209d4a:	54a60613          	addi	a2,a2,1354 # ffffffffc020f290 <dev_node_ops+0x2c8>
ffffffffc0209d4e:	05300593          	li	a1,83
ffffffffc0209d52:	00005517          	auipc	a0,0x5
ffffffffc0209d56:	50e50513          	addi	a0,a0,1294 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209d5a:	cd4f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209d5e:	02061793          	slli	a5,a2,0x20
ffffffffc0209d62:	01e7da13          	srli	s4,a5,0x1e
ffffffffc0209d66:	9a5a                	add	s4,s4,s6
ffffffffc0209d68:	00ca2583          	lw	a1,12(s4)
ffffffffc0209d6c:	c22e                	sw	a1,4(sp)
ffffffffc0209d6e:	ed99                	bnez	a1,ffffffffc0209d8c <sfs_bmap_load_nolock+0xa6>
ffffffffc0209d70:	fccb98e3          	bne	s7,a2,ffffffffc0209d40 <sfs_bmap_load_nolock+0x5a>
ffffffffc0209d74:	004c                	addi	a1,sp,4
ffffffffc0209d76:	ec9ff0ef          	jal	ra,ffffffffc0209c3e <sfs_block_alloc>
ffffffffc0209d7a:	892a                	mv	s2,a0
ffffffffc0209d7c:	e921                	bnez	a0,ffffffffc0209dcc <sfs_bmap_load_nolock+0xe6>
ffffffffc0209d7e:	4592                	lw	a1,4(sp)
ffffffffc0209d80:	4705                	li	a4,1
ffffffffc0209d82:	00ba2623          	sw	a1,12(s4)
ffffffffc0209d86:	00eab823          	sd	a4,16(s5)
ffffffffc0209d8a:	d9dd                	beqz	a1,ffffffffc0209d40 <sfs_bmap_load_nolock+0x5a>
ffffffffc0209d8c:	40d4                	lw	a3,4(s1)
ffffffffc0209d8e:	10d5ff63          	bgeu	a1,a3,ffffffffc0209eac <sfs_bmap_load_nolock+0x1c6>
ffffffffc0209d92:	7c88                	ld	a0,56(s1)
ffffffffc0209d94:	10c010ef          	jal	ra,ffffffffc020aea0 <bitmap_test>
ffffffffc0209d98:	18051363          	bnez	a0,ffffffffc0209f1e <sfs_bmap_load_nolock+0x238>
ffffffffc0209d9c:	4a12                	lw	s4,4(sp)
ffffffffc0209d9e:	fa0a02e3          	beqz	s4,ffffffffc0209d42 <sfs_bmap_load_nolock+0x5c>
ffffffffc0209da2:	40dc                	lw	a5,4(s1)
ffffffffc0209da4:	f8fa7fe3          	bgeu	s4,a5,ffffffffc0209d42 <sfs_bmap_load_nolock+0x5c>
ffffffffc0209da8:	7c88                	ld	a0,56(s1)
ffffffffc0209daa:	85d2                	mv	a1,s4
ffffffffc0209dac:	0f4010ef          	jal	ra,ffffffffc020aea0 <bitmap_test>
ffffffffc0209db0:	12051763          	bnez	a0,ffffffffc0209ede <sfs_bmap_load_nolock+0x1f8>
ffffffffc0209db4:	008b9763          	bne	s7,s0,ffffffffc0209dc2 <sfs_bmap_load_nolock+0xdc>
ffffffffc0209db8:	008b2783          	lw	a5,8(s6)
ffffffffc0209dbc:	2785                	addiw	a5,a5,1
ffffffffc0209dbe:	00fb2423          	sw	a5,8(s6)
ffffffffc0209dc2:	4901                	li	s2,0
ffffffffc0209dc4:	00098463          	beqz	s3,ffffffffc0209dcc <sfs_bmap_load_nolock+0xe6>
ffffffffc0209dc8:	0149a023          	sw	s4,0(s3)
ffffffffc0209dcc:	70a6                	ld	ra,104(sp)
ffffffffc0209dce:	7406                	ld	s0,96(sp)
ffffffffc0209dd0:	64e6                	ld	s1,88(sp)
ffffffffc0209dd2:	69a6                	ld	s3,72(sp)
ffffffffc0209dd4:	6a06                	ld	s4,64(sp)
ffffffffc0209dd6:	7ae2                	ld	s5,56(sp)
ffffffffc0209dd8:	7b42                	ld	s6,48(sp)
ffffffffc0209dda:	7ba2                	ld	s7,40(sp)
ffffffffc0209ddc:	7c02                	ld	s8,32(sp)
ffffffffc0209dde:	6ce2                	ld	s9,24(sp)
ffffffffc0209de0:	854a                	mv	a0,s2
ffffffffc0209de2:	6946                	ld	s2,80(sp)
ffffffffc0209de4:	6165                	addi	sp,sp,112
ffffffffc0209de6:	8082                	ret
ffffffffc0209de8:	002c                	addi	a1,sp,8
ffffffffc0209dea:	e55ff0ef          	jal	ra,ffffffffc0209c3e <sfs_block_alloc>
ffffffffc0209dee:	892a                	mv	s2,a0
ffffffffc0209df0:	00c10c93          	addi	s9,sp,12
ffffffffc0209df4:	fd61                	bnez	a0,ffffffffc0209dcc <sfs_bmap_load_nolock+0xe6>
ffffffffc0209df6:	85e6                	mv	a1,s9
ffffffffc0209df8:	8526                	mv	a0,s1
ffffffffc0209dfa:	e45ff0ef          	jal	ra,ffffffffc0209c3e <sfs_block_alloc>
ffffffffc0209dfe:	892a                	mv	s2,a0
ffffffffc0209e00:	e925                	bnez	a0,ffffffffc0209e70 <sfs_bmap_load_nolock+0x18a>
ffffffffc0209e02:	46a2                	lw	a3,8(sp)
ffffffffc0209e04:	85e6                	mv	a1,s9
ffffffffc0209e06:	8762                	mv	a4,s8
ffffffffc0209e08:	4611                	li	a2,4
ffffffffc0209e0a:	8526                	mv	a0,s1
ffffffffc0209e0c:	2ce010ef          	jal	ra,ffffffffc020b0da <sfs_wbuf>
ffffffffc0209e10:	45b2                	lw	a1,12(sp)
ffffffffc0209e12:	892a                	mv	s2,a0
ffffffffc0209e14:	e939                	bnez	a0,ffffffffc0209e6a <sfs_bmap_load_nolock+0x184>
ffffffffc0209e16:	03cb2683          	lw	a3,60(s6)
ffffffffc0209e1a:	4722                	lw	a4,8(sp)
ffffffffc0209e1c:	c22e                	sw	a1,4(sp)
ffffffffc0209e1e:	f6d706e3          	beq	a4,a3,ffffffffc0209d8a <sfs_bmap_load_nolock+0xa4>
ffffffffc0209e22:	eef1                	bnez	a3,ffffffffc0209efe <sfs_bmap_load_nolock+0x218>
ffffffffc0209e24:	02eb2e23          	sw	a4,60(s6)
ffffffffc0209e28:	4705                	li	a4,1
ffffffffc0209e2a:	00eab823          	sd	a4,16(s5)
ffffffffc0209e2e:	f00589e3          	beqz	a1,ffffffffc0209d40 <sfs_bmap_load_nolock+0x5a>
ffffffffc0209e32:	bfa9                	j	ffffffffc0209d8c <sfs_bmap_load_nolock+0xa6>
ffffffffc0209e34:	00c10c93          	addi	s9,sp,12
ffffffffc0209e38:	8762                	mv	a4,s8
ffffffffc0209e3a:	86d2                	mv	a3,s4
ffffffffc0209e3c:	4611                	li	a2,4
ffffffffc0209e3e:	85e6                	mv	a1,s9
ffffffffc0209e40:	21a010ef          	jal	ra,ffffffffc020b05a <sfs_rbuf>
ffffffffc0209e44:	892a                	mv	s2,a0
ffffffffc0209e46:	f159                	bnez	a0,ffffffffc0209dcc <sfs_bmap_load_nolock+0xe6>
ffffffffc0209e48:	45b2                	lw	a1,12(sp)
ffffffffc0209e4a:	e995                	bnez	a1,ffffffffc0209e7e <sfs_bmap_load_nolock+0x198>
ffffffffc0209e4c:	fa8b85e3          	beq	s7,s0,ffffffffc0209df6 <sfs_bmap_load_nolock+0x110>
ffffffffc0209e50:	03cb2703          	lw	a4,60(s6)
ffffffffc0209e54:	47a2                	lw	a5,8(sp)
ffffffffc0209e56:	c202                	sw	zero,4(sp)
ffffffffc0209e58:	eee784e3          	beq	a5,a4,ffffffffc0209d40 <sfs_bmap_load_nolock+0x5a>
ffffffffc0209e5c:	e34d                	bnez	a4,ffffffffc0209efe <sfs_bmap_load_nolock+0x218>
ffffffffc0209e5e:	02fb2e23          	sw	a5,60(s6)
ffffffffc0209e62:	4785                	li	a5,1
ffffffffc0209e64:	00fab823          	sd	a5,16(s5)
ffffffffc0209e68:	bde1                	j	ffffffffc0209d40 <sfs_bmap_load_nolock+0x5a>
ffffffffc0209e6a:	8526                	mv	a0,s1
ffffffffc0209e6c:	bc1ff0ef          	jal	ra,ffffffffc0209a2c <sfs_block_free>
ffffffffc0209e70:	45a2                	lw	a1,8(sp)
ffffffffc0209e72:	f4ba0de3          	beq	s4,a1,ffffffffc0209dcc <sfs_bmap_load_nolock+0xe6>
ffffffffc0209e76:	8526                	mv	a0,s1
ffffffffc0209e78:	bb5ff0ef          	jal	ra,ffffffffc0209a2c <sfs_block_free>
ffffffffc0209e7c:	bf81                	j	ffffffffc0209dcc <sfs_bmap_load_nolock+0xe6>
ffffffffc0209e7e:	03cb2683          	lw	a3,60(s6)
ffffffffc0209e82:	4722                	lw	a4,8(sp)
ffffffffc0209e84:	c22e                	sw	a1,4(sp)
ffffffffc0209e86:	f8e69ee3          	bne	a3,a4,ffffffffc0209e22 <sfs_bmap_load_nolock+0x13c>
ffffffffc0209e8a:	b709                	j	ffffffffc0209d8c <sfs_bmap_load_nolock+0xa6>
ffffffffc0209e8c:	00005697          	auipc	a3,0x5
ffffffffc0209e90:	4bc68693          	addi	a3,a3,1212 # ffffffffc020f348 <dev_node_ops+0x380>
ffffffffc0209e94:	00002617          	auipc	a2,0x2
ffffffffc0209e98:	e8c60613          	addi	a2,a2,-372 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209e9c:	16400593          	li	a1,356
ffffffffc0209ea0:	00005517          	auipc	a0,0x5
ffffffffc0209ea4:	3c050513          	addi	a0,a0,960 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209ea8:	b86f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209eac:	872e                	mv	a4,a1
ffffffffc0209eae:	00005617          	auipc	a2,0x5
ffffffffc0209eb2:	3e260613          	addi	a2,a2,994 # ffffffffc020f290 <dev_node_ops+0x2c8>
ffffffffc0209eb6:	05300593          	li	a1,83
ffffffffc0209eba:	00005517          	auipc	a0,0x5
ffffffffc0209ebe:	3a650513          	addi	a0,a0,934 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209ec2:	b6cf60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209ec6:	00005617          	auipc	a2,0x5
ffffffffc0209eca:	4b260613          	addi	a2,a2,1202 # ffffffffc020f378 <dev_node_ops+0x3b0>
ffffffffc0209ece:	11e00593          	li	a1,286
ffffffffc0209ed2:	00005517          	auipc	a0,0x5
ffffffffc0209ed6:	38e50513          	addi	a0,a0,910 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209eda:	b54f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209ede:	00005697          	auipc	a3,0x5
ffffffffc0209ee2:	3ea68693          	addi	a3,a3,1002 # ffffffffc020f2c8 <dev_node_ops+0x300>
ffffffffc0209ee6:	00002617          	auipc	a2,0x2
ffffffffc0209eea:	e3a60613          	addi	a2,a2,-454 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209eee:	16b00593          	li	a1,363
ffffffffc0209ef2:	00005517          	auipc	a0,0x5
ffffffffc0209ef6:	36e50513          	addi	a0,a0,878 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209efa:	b34f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209efe:	00005697          	auipc	a3,0x5
ffffffffc0209f02:	46268693          	addi	a3,a3,1122 # ffffffffc020f360 <dev_node_ops+0x398>
ffffffffc0209f06:	00002617          	auipc	a2,0x2
ffffffffc0209f0a:	e1a60613          	addi	a2,a2,-486 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209f0e:	11800593          	li	a1,280
ffffffffc0209f12:	00005517          	auipc	a0,0x5
ffffffffc0209f16:	34e50513          	addi	a0,a0,846 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209f1a:	b14f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc0209f1e:	00005697          	auipc	a3,0x5
ffffffffc0209f22:	48a68693          	addi	a3,a3,1162 # ffffffffc020f3a8 <dev_node_ops+0x3e0>
ffffffffc0209f26:	00002617          	auipc	a2,0x2
ffffffffc0209f2a:	dfa60613          	addi	a2,a2,-518 # ffffffffc020bd20 <commands+0x250>
ffffffffc0209f2e:	12100593          	li	a1,289
ffffffffc0209f32:	00005517          	auipc	a0,0x5
ffffffffc0209f36:	32e50513          	addi	a0,a0,814 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc0209f3a:	af4f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc0209f3e <sfs_io_nolock>:
ffffffffc0209f3e:	7175                	addi	sp,sp,-144
ffffffffc0209f40:	f4ce                	sd	s3,104(sp)
ffffffffc0209f42:	89ae                	mv	s3,a1
ffffffffc0209f44:	618c                	ld	a1,0(a1)
ffffffffc0209f46:	e506                	sd	ra,136(sp)
ffffffffc0209f48:	e122                	sd	s0,128(sp)
ffffffffc0209f4a:	0045d883          	lhu	a7,4(a1)
ffffffffc0209f4e:	fca6                	sd	s1,120(sp)
ffffffffc0209f50:	f8ca                	sd	s2,112(sp)
ffffffffc0209f52:	f0d2                	sd	s4,96(sp)
ffffffffc0209f54:	ecd6                	sd	s5,88(sp)
ffffffffc0209f56:	e8da                	sd	s6,80(sp)
ffffffffc0209f58:	e4de                	sd	s7,72(sp)
ffffffffc0209f5a:	e0e2                	sd	s8,64(sp)
ffffffffc0209f5c:	fc66                	sd	s9,56(sp)
ffffffffc0209f5e:	f86a                	sd	s10,48(sp)
ffffffffc0209f60:	f46e                	sd	s11,40(sp)
ffffffffc0209f62:	4809                	li	a6,2
ffffffffc0209f64:	19088363          	beq	a7,a6,ffffffffc020a0ea <sfs_io_nolock+0x1ac>
ffffffffc0209f68:	00073b03          	ld	s6,0(a4) # 4000 <_binary_bin_swap_img_size-0x3d00>
ffffffffc0209f6c:	8bba                	mv	s7,a4
ffffffffc0209f6e:	000bb023          	sd	zero,0(s7) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0209f72:	08000737          	lui	a4,0x8000
ffffffffc0209f76:	8a36                	mv	s4,a3
ffffffffc0209f78:	9b36                	add	s6,s6,a3
ffffffffc0209f7a:	16e6f463          	bgeu	a3,a4,ffffffffc020a0e2 <sfs_io_nolock+0x1a4>
ffffffffc0209f7e:	16db4263          	blt	s6,a3,ffffffffc020a0e2 <sfs_io_nolock+0x1a4>
ffffffffc0209f82:	892a                	mv	s2,a0
ffffffffc0209f84:	4501                	li	a0,0
ffffffffc0209f86:	09668563          	beq	a3,s6,ffffffffc020a010 <sfs_io_nolock+0xd2>
ffffffffc0209f8a:	8432                	mv	s0,a2
ffffffffc0209f8c:	01677463          	bgeu	a4,s6,ffffffffc0209f94 <sfs_io_nolock+0x56>
ffffffffc0209f90:	08000b37          	lui	s6,0x8000
ffffffffc0209f94:	cfc9                	beqz	a5,ffffffffc020a02e <sfs_io_nolock+0xf0>
ffffffffc0209f96:	00001c17          	auipc	s8,0x1
ffffffffc0209f9a:	064c0c13          	addi	s8,s8,100 # ffffffffc020affa <sfs_wblock>
ffffffffc0209f9e:	00001d17          	auipc	s10,0x1
ffffffffc0209fa2:	13cd0d13          	addi	s10,s10,316 # ffffffffc020b0da <sfs_wbuf>
ffffffffc0209fa6:	6c85                	lui	s9,0x1
ffffffffc0209fa8:	40ca5d93          	srai	s11,s4,0xc
ffffffffc0209fac:	40cb5a93          	srai	s5,s6,0xc
ffffffffc0209fb0:	fffc8493          	addi	s1,s9,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0209fb4:	41ba87bb          	subw	a5,s5,s11
ffffffffc0209fb8:	009a74b3          	and	s1,s4,s1
ffffffffc0209fbc:	8abe                	mv	s5,a5
ffffffffc0209fbe:	2d81                	sext.w	s11,s11
ffffffffc0209fc0:	e4d9                	bnez	s1,ffffffffc020a04e <sfs_io_nolock+0x110>
ffffffffc0209fc2:	01b78cbb          	addw	s9,a5,s11
ffffffffc0209fc6:	6a85                	lui	s5,0x1
ffffffffc0209fc8:	ef89                	bnez	a5,ffffffffc0209fe2 <sfs_io_nolock+0xa4>
ffffffffc0209fca:	aa31                	j	ffffffffc020a0e6 <sfs_io_nolock+0x1a8>
ffffffffc0209fcc:	4672                	lw	a2,28(sp)
ffffffffc0209fce:	4685                	li	a3,1
ffffffffc0209fd0:	85a2                	mv	a1,s0
ffffffffc0209fd2:	854a                	mv	a0,s2
ffffffffc0209fd4:	9c02                	jalr	s8
ffffffffc0209fd6:	ed09                	bnez	a0,ffffffffc0209ff0 <sfs_io_nolock+0xb2>
ffffffffc0209fd8:	2d85                	addiw	s11,s11,1
ffffffffc0209fda:	94d6                	add	s1,s1,s5
ffffffffc0209fdc:	9456                	add	s0,s0,s5
ffffffffc0209fde:	0d9d8863          	beq	s11,s9,ffffffffc020a0ae <sfs_io_nolock+0x170>
ffffffffc0209fe2:	0874                	addi	a3,sp,28
ffffffffc0209fe4:	866e                	mv	a2,s11
ffffffffc0209fe6:	85ce                	mv	a1,s3
ffffffffc0209fe8:	854a                	mv	a0,s2
ffffffffc0209fea:	cfdff0ef          	jal	ra,ffffffffc0209ce6 <sfs_bmap_load_nolock>
ffffffffc0209fee:	dd79                	beqz	a0,ffffffffc0209fcc <sfs_io_nolock+0x8e>
ffffffffc0209ff0:	009a0ab3          	add	s5,s4,s1
ffffffffc0209ff4:	0009b783          	ld	a5,0(s3)
ffffffffc0209ff8:	009bb023          	sd	s1,0(s7)
ffffffffc0209ffc:	0007e703          	lwu	a4,0(a5)
ffffffffc020a000:	01577863          	bgeu	a4,s5,ffffffffc020a010 <sfs_io_nolock+0xd2>
ffffffffc020a004:	009a04bb          	addw	s1,s4,s1
ffffffffc020a008:	c384                	sw	s1,0(a5)
ffffffffc020a00a:	4785                	li	a5,1
ffffffffc020a00c:	00f9b823          	sd	a5,16(s3)
ffffffffc020a010:	60aa                	ld	ra,136(sp)
ffffffffc020a012:	640a                	ld	s0,128(sp)
ffffffffc020a014:	74e6                	ld	s1,120(sp)
ffffffffc020a016:	7946                	ld	s2,112(sp)
ffffffffc020a018:	79a6                	ld	s3,104(sp)
ffffffffc020a01a:	7a06                	ld	s4,96(sp)
ffffffffc020a01c:	6ae6                	ld	s5,88(sp)
ffffffffc020a01e:	6b46                	ld	s6,80(sp)
ffffffffc020a020:	6ba6                	ld	s7,72(sp)
ffffffffc020a022:	6c06                	ld	s8,64(sp)
ffffffffc020a024:	7ce2                	ld	s9,56(sp)
ffffffffc020a026:	7d42                	ld	s10,48(sp)
ffffffffc020a028:	7da2                	ld	s11,40(sp)
ffffffffc020a02a:	6149                	addi	sp,sp,144
ffffffffc020a02c:	8082                	ret
ffffffffc020a02e:	0005e783          	lwu	a5,0(a1)
ffffffffc020a032:	4501                	li	a0,0
ffffffffc020a034:	fcfa5ee3          	bge	s4,a5,ffffffffc020a010 <sfs_io_nolock+0xd2>
ffffffffc020a038:	0567c463          	blt	a5,s6,ffffffffc020a080 <sfs_io_nolock+0x142>
ffffffffc020a03c:	00001c17          	auipc	s8,0x1
ffffffffc020a040:	f5ec0c13          	addi	s8,s8,-162 # ffffffffc020af9a <sfs_rblock>
ffffffffc020a044:	00001d17          	auipc	s10,0x1
ffffffffc020a048:	016d0d13          	addi	s10,s10,22 # ffffffffc020b05a <sfs_rbuf>
ffffffffc020a04c:	bfa9                	j	ffffffffc0209fa6 <sfs_io_nolock+0x68>
ffffffffc020a04e:	0874                	addi	a3,sp,28
ffffffffc020a050:	866e                	mv	a2,s11
ffffffffc020a052:	85ce                	mv	a1,s3
ffffffffc020a054:	854a                	mv	a0,s2
ffffffffc020a056:	e426                	sd	s1,8(sp)
ffffffffc020a058:	e03e                	sd	a5,0(sp)
ffffffffc020a05a:	c8dff0ef          	jal	ra,ffffffffc0209ce6 <sfs_bmap_load_nolock>
ffffffffc020a05e:	e131                	bnez	a0,ffffffffc020a0a2 <sfs_io_nolock+0x164>
ffffffffc020a060:	6782                	ld	a5,0(sp)
ffffffffc020a062:	46f2                	lw	a3,28(sp)
ffffffffc020a064:	6722                	ld	a4,8(sp)
ffffffffc020a066:	c79d                	beqz	a5,ffffffffc020a094 <sfs_io_nolock+0x156>
ffffffffc020a068:	409c84b3          	sub	s1,s9,s1
ffffffffc020a06c:	8626                	mv	a2,s1
ffffffffc020a06e:	85a2                	mv	a1,s0
ffffffffc020a070:	854a                	mv	a0,s2
ffffffffc020a072:	9d02                	jalr	s10
ffffffffc020a074:	e51d                	bnez	a0,ffffffffc020a0a2 <sfs_io_nolock+0x164>
ffffffffc020a076:	9426                	add	s0,s0,s1
ffffffffc020a078:	2d85                	addiw	s11,s11,1
ffffffffc020a07a:	fffa879b          	addiw	a5,s5,-1
ffffffffc020a07e:	b791                	j	ffffffffc0209fc2 <sfs_io_nolock+0x84>
ffffffffc020a080:	8b3e                	mv	s6,a5
ffffffffc020a082:	00001c17          	auipc	s8,0x1
ffffffffc020a086:	f18c0c13          	addi	s8,s8,-232 # ffffffffc020af9a <sfs_rblock>
ffffffffc020a08a:	00001d17          	auipc	s10,0x1
ffffffffc020a08e:	fd0d0d13          	addi	s10,s10,-48 # ffffffffc020b05a <sfs_rbuf>
ffffffffc020a092:	bf11                	j	ffffffffc0209fa6 <sfs_io_nolock+0x68>
ffffffffc020a094:	414b04b3          	sub	s1,s6,s4
ffffffffc020a098:	8626                	mv	a2,s1
ffffffffc020a09a:	85a2                	mv	a1,s0
ffffffffc020a09c:	854a                	mv	a0,s2
ffffffffc020a09e:	9d02                	jalr	s10
ffffffffc020a0a0:	c501                	beqz	a0,ffffffffc020a0a8 <sfs_io_nolock+0x16a>
ffffffffc020a0a2:	8ad2                	mv	s5,s4
ffffffffc020a0a4:	4481                	li	s1,0
ffffffffc020a0a6:	b7b9                	j	ffffffffc0209ff4 <sfs_io_nolock+0xb6>
ffffffffc020a0a8:	9426                	add	s0,s0,s1
ffffffffc020a0aa:	001d8c9b          	addiw	s9,s11,1
ffffffffc020a0ae:	034b1793          	slli	a5,s6,0x34
ffffffffc020a0b2:	0347dc13          	srli	s8,a5,0x34
ffffffffc020a0b6:	009a0ab3          	add	s5,s4,s1
ffffffffc020a0ba:	4501                	li	a0,0
ffffffffc020a0bc:	df85                	beqz	a5,ffffffffc0209ff4 <sfs_io_nolock+0xb6>
ffffffffc020a0be:	f36afbe3          	bgeu	s5,s6,ffffffffc0209ff4 <sfs_io_nolock+0xb6>
ffffffffc020a0c2:	0874                	addi	a3,sp,28
ffffffffc020a0c4:	8666                	mv	a2,s9
ffffffffc020a0c6:	85ce                	mv	a1,s3
ffffffffc020a0c8:	854a                	mv	a0,s2
ffffffffc020a0ca:	c1dff0ef          	jal	ra,ffffffffc0209ce6 <sfs_bmap_load_nolock>
ffffffffc020a0ce:	f11d                	bnez	a0,ffffffffc0209ff4 <sfs_io_nolock+0xb6>
ffffffffc020a0d0:	46f2                	lw	a3,28(sp)
ffffffffc020a0d2:	4701                	li	a4,0
ffffffffc020a0d4:	8662                	mv	a2,s8
ffffffffc020a0d6:	85a2                	mv	a1,s0
ffffffffc020a0d8:	854a                	mv	a0,s2
ffffffffc020a0da:	9d02                	jalr	s10
ffffffffc020a0dc:	fd01                	bnez	a0,ffffffffc0209ff4 <sfs_io_nolock+0xb6>
ffffffffc020a0de:	94e2                	add	s1,s1,s8
ffffffffc020a0e0:	bf01                	j	ffffffffc0209ff0 <sfs_io_nolock+0xb2>
ffffffffc020a0e2:	5575                	li	a0,-3
ffffffffc020a0e4:	b735                	j	ffffffffc020a010 <sfs_io_nolock+0xd2>
ffffffffc020a0e6:	8cee                	mv	s9,s11
ffffffffc020a0e8:	b7d9                	j	ffffffffc020a0ae <sfs_io_nolock+0x170>
ffffffffc020a0ea:	00005697          	auipc	a3,0x5
ffffffffc020a0ee:	2e668693          	addi	a3,a3,742 # ffffffffc020f3d0 <dev_node_ops+0x408>
ffffffffc020a0f2:	00002617          	auipc	a2,0x2
ffffffffc020a0f6:	c2e60613          	addi	a2,a2,-978 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a0fa:	22b00593          	li	a1,555
ffffffffc020a0fe:	00005517          	auipc	a0,0x5
ffffffffc020a102:	16250513          	addi	a0,a0,354 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a106:	928f60ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a10a <sfs_read>:
ffffffffc020a10a:	7139                	addi	sp,sp,-64
ffffffffc020a10c:	f04a                	sd	s2,32(sp)
ffffffffc020a10e:	06853903          	ld	s2,104(a0)
ffffffffc020a112:	fc06                	sd	ra,56(sp)
ffffffffc020a114:	f822                	sd	s0,48(sp)
ffffffffc020a116:	f426                	sd	s1,40(sp)
ffffffffc020a118:	ec4e                	sd	s3,24(sp)
ffffffffc020a11a:	04090f63          	beqz	s2,ffffffffc020a178 <sfs_read+0x6e>
ffffffffc020a11e:	0b092783          	lw	a5,176(s2)
ffffffffc020a122:	ebb9                	bnez	a5,ffffffffc020a178 <sfs_read+0x6e>
ffffffffc020a124:	4d38                	lw	a4,88(a0)
ffffffffc020a126:	6785                	lui	a5,0x1
ffffffffc020a128:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a12c:	842a                	mv	s0,a0
ffffffffc020a12e:	06f71563          	bne	a4,a5,ffffffffc020a198 <sfs_read+0x8e>
ffffffffc020a132:	02050993          	addi	s3,a0,32
ffffffffc020a136:	854e                	mv	a0,s3
ffffffffc020a138:	84ae                	mv	s1,a1
ffffffffc020a13a:	f1efa0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc020a13e:	0184b803          	ld	a6,24(s1)
ffffffffc020a142:	6494                	ld	a3,8(s1)
ffffffffc020a144:	6090                	ld	a2,0(s1)
ffffffffc020a146:	85a2                	mv	a1,s0
ffffffffc020a148:	4781                	li	a5,0
ffffffffc020a14a:	0038                	addi	a4,sp,8
ffffffffc020a14c:	854a                	mv	a0,s2
ffffffffc020a14e:	e442                	sd	a6,8(sp)
ffffffffc020a150:	defff0ef          	jal	ra,ffffffffc0209f3e <sfs_io_nolock>
ffffffffc020a154:	65a2                	ld	a1,8(sp)
ffffffffc020a156:	842a                	mv	s0,a0
ffffffffc020a158:	ed81                	bnez	a1,ffffffffc020a170 <sfs_read+0x66>
ffffffffc020a15a:	854e                	mv	a0,s3
ffffffffc020a15c:	ef8fa0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020a160:	70e2                	ld	ra,56(sp)
ffffffffc020a162:	8522                	mv	a0,s0
ffffffffc020a164:	7442                	ld	s0,48(sp)
ffffffffc020a166:	74a2                	ld	s1,40(sp)
ffffffffc020a168:	7902                	ld	s2,32(sp)
ffffffffc020a16a:	69e2                	ld	s3,24(sp)
ffffffffc020a16c:	6121                	addi	sp,sp,64
ffffffffc020a16e:	8082                	ret
ffffffffc020a170:	8526                	mv	a0,s1
ffffffffc020a172:	f3efb0ef          	jal	ra,ffffffffc02058b0 <iobuf_skip>
ffffffffc020a176:	b7d5                	j	ffffffffc020a15a <sfs_read+0x50>
ffffffffc020a178:	00005697          	auipc	a3,0x5
ffffffffc020a17c:	f0868693          	addi	a3,a3,-248 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc020a180:	00002617          	auipc	a2,0x2
ffffffffc020a184:	ba060613          	addi	a2,a2,-1120 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a188:	29d00593          	li	a1,669
ffffffffc020a18c:	00005517          	auipc	a0,0x5
ffffffffc020a190:	0d450513          	addi	a0,a0,212 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a194:	89af60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a198:	871ff0ef          	jal	ra,ffffffffc0209a08 <sfs_io.part.0>

ffffffffc020a19c <sfs_write>:
ffffffffc020a19c:	7139                	addi	sp,sp,-64
ffffffffc020a19e:	f04a                	sd	s2,32(sp)
ffffffffc020a1a0:	06853903          	ld	s2,104(a0)
ffffffffc020a1a4:	fc06                	sd	ra,56(sp)
ffffffffc020a1a6:	f822                	sd	s0,48(sp)
ffffffffc020a1a8:	f426                	sd	s1,40(sp)
ffffffffc020a1aa:	ec4e                	sd	s3,24(sp)
ffffffffc020a1ac:	04090f63          	beqz	s2,ffffffffc020a20a <sfs_write+0x6e>
ffffffffc020a1b0:	0b092783          	lw	a5,176(s2)
ffffffffc020a1b4:	ebb9                	bnez	a5,ffffffffc020a20a <sfs_write+0x6e>
ffffffffc020a1b6:	4d38                	lw	a4,88(a0)
ffffffffc020a1b8:	6785                	lui	a5,0x1
ffffffffc020a1ba:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a1be:	842a                	mv	s0,a0
ffffffffc020a1c0:	06f71563          	bne	a4,a5,ffffffffc020a22a <sfs_write+0x8e>
ffffffffc020a1c4:	02050993          	addi	s3,a0,32
ffffffffc020a1c8:	854e                	mv	a0,s3
ffffffffc020a1ca:	84ae                	mv	s1,a1
ffffffffc020a1cc:	e8cfa0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc020a1d0:	0184b803          	ld	a6,24(s1)
ffffffffc020a1d4:	6494                	ld	a3,8(s1)
ffffffffc020a1d6:	6090                	ld	a2,0(s1)
ffffffffc020a1d8:	85a2                	mv	a1,s0
ffffffffc020a1da:	4785                	li	a5,1
ffffffffc020a1dc:	0038                	addi	a4,sp,8
ffffffffc020a1de:	854a                	mv	a0,s2
ffffffffc020a1e0:	e442                	sd	a6,8(sp)
ffffffffc020a1e2:	d5dff0ef          	jal	ra,ffffffffc0209f3e <sfs_io_nolock>
ffffffffc020a1e6:	65a2                	ld	a1,8(sp)
ffffffffc020a1e8:	842a                	mv	s0,a0
ffffffffc020a1ea:	ed81                	bnez	a1,ffffffffc020a202 <sfs_write+0x66>
ffffffffc020a1ec:	854e                	mv	a0,s3
ffffffffc020a1ee:	e66fa0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020a1f2:	70e2                	ld	ra,56(sp)
ffffffffc020a1f4:	8522                	mv	a0,s0
ffffffffc020a1f6:	7442                	ld	s0,48(sp)
ffffffffc020a1f8:	74a2                	ld	s1,40(sp)
ffffffffc020a1fa:	7902                	ld	s2,32(sp)
ffffffffc020a1fc:	69e2                	ld	s3,24(sp)
ffffffffc020a1fe:	6121                	addi	sp,sp,64
ffffffffc020a200:	8082                	ret
ffffffffc020a202:	8526                	mv	a0,s1
ffffffffc020a204:	eacfb0ef          	jal	ra,ffffffffc02058b0 <iobuf_skip>
ffffffffc020a208:	b7d5                	j	ffffffffc020a1ec <sfs_write+0x50>
ffffffffc020a20a:	00005697          	auipc	a3,0x5
ffffffffc020a20e:	e7668693          	addi	a3,a3,-394 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc020a212:	00002617          	auipc	a2,0x2
ffffffffc020a216:	b0e60613          	addi	a2,a2,-1266 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a21a:	29d00593          	li	a1,669
ffffffffc020a21e:	00005517          	auipc	a0,0x5
ffffffffc020a222:	04250513          	addi	a0,a0,66 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a226:	808f60ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a22a:	fdeff0ef          	jal	ra,ffffffffc0209a08 <sfs_io.part.0>

ffffffffc020a22e <sfs_dirent_read_nolock>:
ffffffffc020a22e:	6198                	ld	a4,0(a1)
ffffffffc020a230:	7179                	addi	sp,sp,-48
ffffffffc020a232:	f406                	sd	ra,40(sp)
ffffffffc020a234:	00475883          	lhu	a7,4(a4) # 8000004 <_binary_bin_sfs_img_size+0x7f8ad04>
ffffffffc020a238:	f022                	sd	s0,32(sp)
ffffffffc020a23a:	ec26                	sd	s1,24(sp)
ffffffffc020a23c:	4809                	li	a6,2
ffffffffc020a23e:	05089b63          	bne	a7,a6,ffffffffc020a294 <sfs_dirent_read_nolock+0x66>
ffffffffc020a242:	4718                	lw	a4,8(a4)
ffffffffc020a244:	87b2                	mv	a5,a2
ffffffffc020a246:	2601                	sext.w	a2,a2
ffffffffc020a248:	04e7f663          	bgeu	a5,a4,ffffffffc020a294 <sfs_dirent_read_nolock+0x66>
ffffffffc020a24c:	84b6                	mv	s1,a3
ffffffffc020a24e:	0074                	addi	a3,sp,12
ffffffffc020a250:	842a                	mv	s0,a0
ffffffffc020a252:	a95ff0ef          	jal	ra,ffffffffc0209ce6 <sfs_bmap_load_nolock>
ffffffffc020a256:	c511                	beqz	a0,ffffffffc020a262 <sfs_dirent_read_nolock+0x34>
ffffffffc020a258:	70a2                	ld	ra,40(sp)
ffffffffc020a25a:	7402                	ld	s0,32(sp)
ffffffffc020a25c:	64e2                	ld	s1,24(sp)
ffffffffc020a25e:	6145                	addi	sp,sp,48
ffffffffc020a260:	8082                	ret
ffffffffc020a262:	45b2                	lw	a1,12(sp)
ffffffffc020a264:	4054                	lw	a3,4(s0)
ffffffffc020a266:	c5b9                	beqz	a1,ffffffffc020a2b4 <sfs_dirent_read_nolock+0x86>
ffffffffc020a268:	04d5f663          	bgeu	a1,a3,ffffffffc020a2b4 <sfs_dirent_read_nolock+0x86>
ffffffffc020a26c:	7c08                	ld	a0,56(s0)
ffffffffc020a26e:	433000ef          	jal	ra,ffffffffc020aea0 <bitmap_test>
ffffffffc020a272:	ed31                	bnez	a0,ffffffffc020a2ce <sfs_dirent_read_nolock+0xa0>
ffffffffc020a274:	46b2                	lw	a3,12(sp)
ffffffffc020a276:	4701                	li	a4,0
ffffffffc020a278:	10400613          	li	a2,260
ffffffffc020a27c:	85a6                	mv	a1,s1
ffffffffc020a27e:	8522                	mv	a0,s0
ffffffffc020a280:	5db000ef          	jal	ra,ffffffffc020b05a <sfs_rbuf>
ffffffffc020a284:	f971                	bnez	a0,ffffffffc020a258 <sfs_dirent_read_nolock+0x2a>
ffffffffc020a286:	100481a3          	sb	zero,259(s1)
ffffffffc020a28a:	70a2                	ld	ra,40(sp)
ffffffffc020a28c:	7402                	ld	s0,32(sp)
ffffffffc020a28e:	64e2                	ld	s1,24(sp)
ffffffffc020a290:	6145                	addi	sp,sp,48
ffffffffc020a292:	8082                	ret
ffffffffc020a294:	00005697          	auipc	a3,0x5
ffffffffc020a298:	15c68693          	addi	a3,a3,348 # ffffffffc020f3f0 <dev_node_ops+0x428>
ffffffffc020a29c:	00002617          	auipc	a2,0x2
ffffffffc020a2a0:	a8460613          	addi	a2,a2,-1404 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a2a4:	18e00593          	li	a1,398
ffffffffc020a2a8:	00005517          	auipc	a0,0x5
ffffffffc020a2ac:	fb850513          	addi	a0,a0,-72 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a2b0:	f7ff50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a2b4:	872e                	mv	a4,a1
ffffffffc020a2b6:	00005617          	auipc	a2,0x5
ffffffffc020a2ba:	fda60613          	addi	a2,a2,-38 # ffffffffc020f290 <dev_node_ops+0x2c8>
ffffffffc020a2be:	05300593          	li	a1,83
ffffffffc020a2c2:	00005517          	auipc	a0,0x5
ffffffffc020a2c6:	f9e50513          	addi	a0,a0,-98 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a2ca:	f65f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a2ce:	00005697          	auipc	a3,0x5
ffffffffc020a2d2:	ffa68693          	addi	a3,a3,-6 # ffffffffc020f2c8 <dev_node_ops+0x300>
ffffffffc020a2d6:	00002617          	auipc	a2,0x2
ffffffffc020a2da:	a4a60613          	addi	a2,a2,-1462 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a2de:	19500593          	li	a1,405
ffffffffc020a2e2:	00005517          	auipc	a0,0x5
ffffffffc020a2e6:	f7e50513          	addi	a0,a0,-130 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a2ea:	f45f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a2ee <sfs_getdirentry>:
ffffffffc020a2ee:	715d                	addi	sp,sp,-80
ffffffffc020a2f0:	ec56                	sd	s5,24(sp)
ffffffffc020a2f2:	8aaa                	mv	s5,a0
ffffffffc020a2f4:	10400513          	li	a0,260
ffffffffc020a2f8:	e85a                	sd	s6,16(sp)
ffffffffc020a2fa:	e486                	sd	ra,72(sp)
ffffffffc020a2fc:	e0a2                	sd	s0,64(sp)
ffffffffc020a2fe:	fc26                	sd	s1,56(sp)
ffffffffc020a300:	f84a                	sd	s2,48(sp)
ffffffffc020a302:	f44e                	sd	s3,40(sp)
ffffffffc020a304:	f052                	sd	s4,32(sp)
ffffffffc020a306:	e45e                	sd	s7,8(sp)
ffffffffc020a308:	e062                	sd	s8,0(sp)
ffffffffc020a30a:	8b2e                	mv	s6,a1
ffffffffc020a30c:	dc4f90ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc020a310:	cd61                	beqz	a0,ffffffffc020a3e8 <sfs_getdirentry+0xfa>
ffffffffc020a312:	068abb83          	ld	s7,104(s5) # 1068 <_binary_bin_swap_img_size-0x6c98>
ffffffffc020a316:	0c0b8b63          	beqz	s7,ffffffffc020a3ec <sfs_getdirentry+0xfe>
ffffffffc020a31a:	0b0ba783          	lw	a5,176(s7)
ffffffffc020a31e:	e7f9                	bnez	a5,ffffffffc020a3ec <sfs_getdirentry+0xfe>
ffffffffc020a320:	058aa703          	lw	a4,88(s5)
ffffffffc020a324:	6785                	lui	a5,0x1
ffffffffc020a326:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a32a:	0ef71163          	bne	a4,a5,ffffffffc020a40c <sfs_getdirentry+0x11e>
ffffffffc020a32e:	008b3983          	ld	s3,8(s6) # 8000008 <_binary_bin_sfs_img_size+0x7f8ad08>
ffffffffc020a332:	892a                	mv	s2,a0
ffffffffc020a334:	0a09c163          	bltz	s3,ffffffffc020a3d6 <sfs_getdirentry+0xe8>
ffffffffc020a338:	0ff9f793          	zext.b	a5,s3
ffffffffc020a33c:	efc9                	bnez	a5,ffffffffc020a3d6 <sfs_getdirentry+0xe8>
ffffffffc020a33e:	000ab783          	ld	a5,0(s5)
ffffffffc020a342:	0089d993          	srli	s3,s3,0x8
ffffffffc020a346:	2981                	sext.w	s3,s3
ffffffffc020a348:	479c                	lw	a5,8(a5)
ffffffffc020a34a:	0937eb63          	bltu	a5,s3,ffffffffc020a3e0 <sfs_getdirentry+0xf2>
ffffffffc020a34e:	020a8c13          	addi	s8,s5,32
ffffffffc020a352:	8562                	mv	a0,s8
ffffffffc020a354:	d04fa0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc020a358:	000ab783          	ld	a5,0(s5)
ffffffffc020a35c:	0087aa03          	lw	s4,8(a5)
ffffffffc020a360:	07405663          	blez	s4,ffffffffc020a3cc <sfs_getdirentry+0xde>
ffffffffc020a364:	4481                	li	s1,0
ffffffffc020a366:	a811                	j	ffffffffc020a37a <sfs_getdirentry+0x8c>
ffffffffc020a368:	00092783          	lw	a5,0(s2)
ffffffffc020a36c:	c781                	beqz	a5,ffffffffc020a374 <sfs_getdirentry+0x86>
ffffffffc020a36e:	02098263          	beqz	s3,ffffffffc020a392 <sfs_getdirentry+0xa4>
ffffffffc020a372:	39fd                	addiw	s3,s3,-1
ffffffffc020a374:	2485                	addiw	s1,s1,1
ffffffffc020a376:	049a0b63          	beq	s4,s1,ffffffffc020a3cc <sfs_getdirentry+0xde>
ffffffffc020a37a:	86ca                	mv	a3,s2
ffffffffc020a37c:	8626                	mv	a2,s1
ffffffffc020a37e:	85d6                	mv	a1,s5
ffffffffc020a380:	855e                	mv	a0,s7
ffffffffc020a382:	eadff0ef          	jal	ra,ffffffffc020a22e <sfs_dirent_read_nolock>
ffffffffc020a386:	842a                	mv	s0,a0
ffffffffc020a388:	d165                	beqz	a0,ffffffffc020a368 <sfs_getdirentry+0x7a>
ffffffffc020a38a:	8562                	mv	a0,s8
ffffffffc020a38c:	cc8fa0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020a390:	a831                	j	ffffffffc020a3ac <sfs_getdirentry+0xbe>
ffffffffc020a392:	8562                	mv	a0,s8
ffffffffc020a394:	cc0fa0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020a398:	4701                	li	a4,0
ffffffffc020a39a:	4685                	li	a3,1
ffffffffc020a39c:	10000613          	li	a2,256
ffffffffc020a3a0:	00490593          	addi	a1,s2,4
ffffffffc020a3a4:	855a                	mv	a0,s6
ffffffffc020a3a6:	c9efb0ef          	jal	ra,ffffffffc0205844 <iobuf_move>
ffffffffc020a3aa:	842a                	mv	s0,a0
ffffffffc020a3ac:	854a                	mv	a0,s2
ffffffffc020a3ae:	dd2f90ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020a3b2:	60a6                	ld	ra,72(sp)
ffffffffc020a3b4:	8522                	mv	a0,s0
ffffffffc020a3b6:	6406                	ld	s0,64(sp)
ffffffffc020a3b8:	74e2                	ld	s1,56(sp)
ffffffffc020a3ba:	7942                	ld	s2,48(sp)
ffffffffc020a3bc:	79a2                	ld	s3,40(sp)
ffffffffc020a3be:	7a02                	ld	s4,32(sp)
ffffffffc020a3c0:	6ae2                	ld	s5,24(sp)
ffffffffc020a3c2:	6b42                	ld	s6,16(sp)
ffffffffc020a3c4:	6ba2                	ld	s7,8(sp)
ffffffffc020a3c6:	6c02                	ld	s8,0(sp)
ffffffffc020a3c8:	6161                	addi	sp,sp,80
ffffffffc020a3ca:	8082                	ret
ffffffffc020a3cc:	8562                	mv	a0,s8
ffffffffc020a3ce:	5441                	li	s0,-16
ffffffffc020a3d0:	c84fa0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020a3d4:	bfe1                	j	ffffffffc020a3ac <sfs_getdirentry+0xbe>
ffffffffc020a3d6:	854a                	mv	a0,s2
ffffffffc020a3d8:	da8f90ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020a3dc:	5475                	li	s0,-3
ffffffffc020a3de:	bfd1                	j	ffffffffc020a3b2 <sfs_getdirentry+0xc4>
ffffffffc020a3e0:	da0f90ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020a3e4:	5441                	li	s0,-16
ffffffffc020a3e6:	b7f1                	j	ffffffffc020a3b2 <sfs_getdirentry+0xc4>
ffffffffc020a3e8:	5471                	li	s0,-4
ffffffffc020a3ea:	b7e1                	j	ffffffffc020a3b2 <sfs_getdirentry+0xc4>
ffffffffc020a3ec:	00005697          	auipc	a3,0x5
ffffffffc020a3f0:	c9468693          	addi	a3,a3,-876 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc020a3f4:	00002617          	auipc	a2,0x2
ffffffffc020a3f8:	92c60613          	addi	a2,a2,-1748 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a3fc:	34100593          	li	a1,833
ffffffffc020a400:	00005517          	auipc	a0,0x5
ffffffffc020a404:	e6050513          	addi	a0,a0,-416 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a408:	e27f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a40c:	00005697          	auipc	a3,0x5
ffffffffc020a410:	e1c68693          	addi	a3,a3,-484 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc020a414:	00002617          	auipc	a2,0x2
ffffffffc020a418:	90c60613          	addi	a2,a2,-1780 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a41c:	34200593          	li	a1,834
ffffffffc020a420:	00005517          	auipc	a0,0x5
ffffffffc020a424:	e4050513          	addi	a0,a0,-448 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a428:	e07f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a42c <sfs_dirent_search_nolock.constprop.0>:
ffffffffc020a42c:	715d                	addi	sp,sp,-80
ffffffffc020a42e:	f052                	sd	s4,32(sp)
ffffffffc020a430:	8a2a                	mv	s4,a0
ffffffffc020a432:	8532                	mv	a0,a2
ffffffffc020a434:	f44e                	sd	s3,40(sp)
ffffffffc020a436:	e85a                	sd	s6,16(sp)
ffffffffc020a438:	e45e                	sd	s7,8(sp)
ffffffffc020a43a:	e486                	sd	ra,72(sp)
ffffffffc020a43c:	e0a2                	sd	s0,64(sp)
ffffffffc020a43e:	fc26                	sd	s1,56(sp)
ffffffffc020a440:	f84a                	sd	s2,48(sp)
ffffffffc020a442:	ec56                	sd	s5,24(sp)
ffffffffc020a444:	e062                	sd	s8,0(sp)
ffffffffc020a446:	8b32                	mv	s6,a2
ffffffffc020a448:	89ae                	mv	s3,a1
ffffffffc020a44a:	8bb6                	mv	s7,a3
ffffffffc020a44c:	63f000ef          	jal	ra,ffffffffc020b28a <strlen>
ffffffffc020a450:	0ff00793          	li	a5,255
ffffffffc020a454:	06a7ef63          	bltu	a5,a0,ffffffffc020a4d2 <sfs_dirent_search_nolock.constprop.0+0xa6>
ffffffffc020a458:	10400513          	li	a0,260
ffffffffc020a45c:	c74f90ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc020a460:	892a                	mv	s2,a0
ffffffffc020a462:	c535                	beqz	a0,ffffffffc020a4ce <sfs_dirent_search_nolock.constprop.0+0xa2>
ffffffffc020a464:	0009b783          	ld	a5,0(s3)
ffffffffc020a468:	0087aa83          	lw	s5,8(a5)
ffffffffc020a46c:	05505a63          	blez	s5,ffffffffc020a4c0 <sfs_dirent_search_nolock.constprop.0+0x94>
ffffffffc020a470:	4481                	li	s1,0
ffffffffc020a472:	00450c13          	addi	s8,a0,4
ffffffffc020a476:	a829                	j	ffffffffc020a490 <sfs_dirent_search_nolock.constprop.0+0x64>
ffffffffc020a478:	00092783          	lw	a5,0(s2)
ffffffffc020a47c:	c799                	beqz	a5,ffffffffc020a48a <sfs_dirent_search_nolock.constprop.0+0x5e>
ffffffffc020a47e:	85e2                	mv	a1,s8
ffffffffc020a480:	855a                	mv	a0,s6
ffffffffc020a482:	651000ef          	jal	ra,ffffffffc020b2d2 <strcmp>
ffffffffc020a486:	842a                	mv	s0,a0
ffffffffc020a488:	cd15                	beqz	a0,ffffffffc020a4c4 <sfs_dirent_search_nolock.constprop.0+0x98>
ffffffffc020a48a:	2485                	addiw	s1,s1,1
ffffffffc020a48c:	029a8a63          	beq	s5,s1,ffffffffc020a4c0 <sfs_dirent_search_nolock.constprop.0+0x94>
ffffffffc020a490:	86ca                	mv	a3,s2
ffffffffc020a492:	8626                	mv	a2,s1
ffffffffc020a494:	85ce                	mv	a1,s3
ffffffffc020a496:	8552                	mv	a0,s4
ffffffffc020a498:	d97ff0ef          	jal	ra,ffffffffc020a22e <sfs_dirent_read_nolock>
ffffffffc020a49c:	842a                	mv	s0,a0
ffffffffc020a49e:	dd69                	beqz	a0,ffffffffc020a478 <sfs_dirent_search_nolock.constprop.0+0x4c>
ffffffffc020a4a0:	854a                	mv	a0,s2
ffffffffc020a4a2:	cdef90ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020a4a6:	60a6                	ld	ra,72(sp)
ffffffffc020a4a8:	8522                	mv	a0,s0
ffffffffc020a4aa:	6406                	ld	s0,64(sp)
ffffffffc020a4ac:	74e2                	ld	s1,56(sp)
ffffffffc020a4ae:	7942                	ld	s2,48(sp)
ffffffffc020a4b0:	79a2                	ld	s3,40(sp)
ffffffffc020a4b2:	7a02                	ld	s4,32(sp)
ffffffffc020a4b4:	6ae2                	ld	s5,24(sp)
ffffffffc020a4b6:	6b42                	ld	s6,16(sp)
ffffffffc020a4b8:	6ba2                	ld	s7,8(sp)
ffffffffc020a4ba:	6c02                	ld	s8,0(sp)
ffffffffc020a4bc:	6161                	addi	sp,sp,80
ffffffffc020a4be:	8082                	ret
ffffffffc020a4c0:	5441                	li	s0,-16
ffffffffc020a4c2:	bff9                	j	ffffffffc020a4a0 <sfs_dirent_search_nolock.constprop.0+0x74>
ffffffffc020a4c4:	00092783          	lw	a5,0(s2)
ffffffffc020a4c8:	00fba023          	sw	a5,0(s7)
ffffffffc020a4cc:	bfd1                	j	ffffffffc020a4a0 <sfs_dirent_search_nolock.constprop.0+0x74>
ffffffffc020a4ce:	5471                	li	s0,-4
ffffffffc020a4d0:	bfd9                	j	ffffffffc020a4a6 <sfs_dirent_search_nolock.constprop.0+0x7a>
ffffffffc020a4d2:	00005697          	auipc	a3,0x5
ffffffffc020a4d6:	f6e68693          	addi	a3,a3,-146 # ffffffffc020f440 <dev_node_ops+0x478>
ffffffffc020a4da:	00002617          	auipc	a2,0x2
ffffffffc020a4de:	84660613          	addi	a2,a2,-1978 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a4e2:	1ba00593          	li	a1,442
ffffffffc020a4e6:	00005517          	auipc	a0,0x5
ffffffffc020a4ea:	d7a50513          	addi	a0,a0,-646 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a4ee:	d41f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a4f2 <sfs_truncfile>:
ffffffffc020a4f2:	7175                	addi	sp,sp,-144
ffffffffc020a4f4:	e506                	sd	ra,136(sp)
ffffffffc020a4f6:	e122                	sd	s0,128(sp)
ffffffffc020a4f8:	fca6                	sd	s1,120(sp)
ffffffffc020a4fa:	f8ca                	sd	s2,112(sp)
ffffffffc020a4fc:	f4ce                	sd	s3,104(sp)
ffffffffc020a4fe:	f0d2                	sd	s4,96(sp)
ffffffffc020a500:	ecd6                	sd	s5,88(sp)
ffffffffc020a502:	e8da                	sd	s6,80(sp)
ffffffffc020a504:	e4de                	sd	s7,72(sp)
ffffffffc020a506:	e0e2                	sd	s8,64(sp)
ffffffffc020a508:	fc66                	sd	s9,56(sp)
ffffffffc020a50a:	f86a                	sd	s10,48(sp)
ffffffffc020a50c:	f46e                	sd	s11,40(sp)
ffffffffc020a50e:	080007b7          	lui	a5,0x8000
ffffffffc020a512:	16b7e463          	bltu	a5,a1,ffffffffc020a67a <sfs_truncfile+0x188>
ffffffffc020a516:	06853c83          	ld	s9,104(a0)
ffffffffc020a51a:	89aa                	mv	s3,a0
ffffffffc020a51c:	160c8163          	beqz	s9,ffffffffc020a67e <sfs_truncfile+0x18c>
ffffffffc020a520:	0b0ca783          	lw	a5,176(s9)
ffffffffc020a524:	14079d63          	bnez	a5,ffffffffc020a67e <sfs_truncfile+0x18c>
ffffffffc020a528:	4d38                	lw	a4,88(a0)
ffffffffc020a52a:	6405                	lui	s0,0x1
ffffffffc020a52c:	23540793          	addi	a5,s0,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a530:	16f71763          	bne	a4,a5,ffffffffc020a69e <sfs_truncfile+0x1ac>
ffffffffc020a534:	00053a83          	ld	s5,0(a0)
ffffffffc020a538:	147d                	addi	s0,s0,-1
ffffffffc020a53a:	942e                	add	s0,s0,a1
ffffffffc020a53c:	000ae783          	lwu	a5,0(s5)
ffffffffc020a540:	8031                	srli	s0,s0,0xc
ffffffffc020a542:	8a2e                	mv	s4,a1
ffffffffc020a544:	2401                	sext.w	s0,s0
ffffffffc020a546:	02b79763          	bne	a5,a1,ffffffffc020a574 <sfs_truncfile+0x82>
ffffffffc020a54a:	008aa783          	lw	a5,8(s5)
ffffffffc020a54e:	4901                	li	s2,0
ffffffffc020a550:	18879763          	bne	a5,s0,ffffffffc020a6de <sfs_truncfile+0x1ec>
ffffffffc020a554:	60aa                	ld	ra,136(sp)
ffffffffc020a556:	640a                	ld	s0,128(sp)
ffffffffc020a558:	74e6                	ld	s1,120(sp)
ffffffffc020a55a:	79a6                	ld	s3,104(sp)
ffffffffc020a55c:	7a06                	ld	s4,96(sp)
ffffffffc020a55e:	6ae6                	ld	s5,88(sp)
ffffffffc020a560:	6b46                	ld	s6,80(sp)
ffffffffc020a562:	6ba6                	ld	s7,72(sp)
ffffffffc020a564:	6c06                	ld	s8,64(sp)
ffffffffc020a566:	7ce2                	ld	s9,56(sp)
ffffffffc020a568:	7d42                	ld	s10,48(sp)
ffffffffc020a56a:	7da2                	ld	s11,40(sp)
ffffffffc020a56c:	854a                	mv	a0,s2
ffffffffc020a56e:	7946                	ld	s2,112(sp)
ffffffffc020a570:	6149                	addi	sp,sp,144
ffffffffc020a572:	8082                	ret
ffffffffc020a574:	02050b13          	addi	s6,a0,32
ffffffffc020a578:	855a                	mv	a0,s6
ffffffffc020a57a:	adefa0ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc020a57e:	008aa483          	lw	s1,8(s5)
ffffffffc020a582:	0a84e663          	bltu	s1,s0,ffffffffc020a62e <sfs_truncfile+0x13c>
ffffffffc020a586:	0c947163          	bgeu	s0,s1,ffffffffc020a648 <sfs_truncfile+0x156>
ffffffffc020a58a:	4dad                	li	s11,11
ffffffffc020a58c:	4b85                	li	s7,1
ffffffffc020a58e:	a09d                	j	ffffffffc020a5f4 <sfs_truncfile+0x102>
ffffffffc020a590:	ff37091b          	addiw	s2,a4,-13
ffffffffc020a594:	0009079b          	sext.w	a5,s2
ffffffffc020a598:	3ff00713          	li	a4,1023
ffffffffc020a59c:	04f76563          	bltu	a4,a5,ffffffffc020a5e6 <sfs_truncfile+0xf4>
ffffffffc020a5a0:	03cd2c03          	lw	s8,60(s10)
ffffffffc020a5a4:	040c0163          	beqz	s8,ffffffffc020a5e6 <sfs_truncfile+0xf4>
ffffffffc020a5a8:	004ca783          	lw	a5,4(s9)
ffffffffc020a5ac:	18fc7963          	bgeu	s8,a5,ffffffffc020a73e <sfs_truncfile+0x24c>
ffffffffc020a5b0:	038cb503          	ld	a0,56(s9)
ffffffffc020a5b4:	85e2                	mv	a1,s8
ffffffffc020a5b6:	0eb000ef          	jal	ra,ffffffffc020aea0 <bitmap_test>
ffffffffc020a5ba:	16051263          	bnez	a0,ffffffffc020a71e <sfs_truncfile+0x22c>
ffffffffc020a5be:	02091793          	slli	a5,s2,0x20
ffffffffc020a5c2:	01e7d713          	srli	a4,a5,0x1e
ffffffffc020a5c6:	86e2                	mv	a3,s8
ffffffffc020a5c8:	4611                	li	a2,4
ffffffffc020a5ca:	082c                	addi	a1,sp,24
ffffffffc020a5cc:	8566                	mv	a0,s9
ffffffffc020a5ce:	e43a                	sd	a4,8(sp)
ffffffffc020a5d0:	ce02                	sw	zero,28(sp)
ffffffffc020a5d2:	289000ef          	jal	ra,ffffffffc020b05a <sfs_rbuf>
ffffffffc020a5d6:	892a                	mv	s2,a0
ffffffffc020a5d8:	e141                	bnez	a0,ffffffffc020a658 <sfs_truncfile+0x166>
ffffffffc020a5da:	47e2                	lw	a5,24(sp)
ffffffffc020a5dc:	6722                	ld	a4,8(sp)
ffffffffc020a5de:	e3c9                	bnez	a5,ffffffffc020a660 <sfs_truncfile+0x16e>
ffffffffc020a5e0:	008d2603          	lw	a2,8(s10)
ffffffffc020a5e4:	367d                	addiw	a2,a2,-1
ffffffffc020a5e6:	00cd2423          	sw	a2,8(s10)
ffffffffc020a5ea:	0179b823          	sd	s7,16(s3)
ffffffffc020a5ee:	34fd                	addiw	s1,s1,-1
ffffffffc020a5f0:	04940a63          	beq	s0,s1,ffffffffc020a644 <sfs_truncfile+0x152>
ffffffffc020a5f4:	0009bd03          	ld	s10,0(s3)
ffffffffc020a5f8:	008d2703          	lw	a4,8(s10)
ffffffffc020a5fc:	c369                	beqz	a4,ffffffffc020a6be <sfs_truncfile+0x1cc>
ffffffffc020a5fe:	fff7079b          	addiw	a5,a4,-1
ffffffffc020a602:	0007861b          	sext.w	a2,a5
ffffffffc020a606:	f8cde5e3          	bltu	s11,a2,ffffffffc020a590 <sfs_truncfile+0x9e>
ffffffffc020a60a:	02079713          	slli	a4,a5,0x20
ffffffffc020a60e:	01e75793          	srli	a5,a4,0x1e
ffffffffc020a612:	00fd0933          	add	s2,s10,a5
ffffffffc020a616:	00c92583          	lw	a1,12(s2)
ffffffffc020a61a:	d5f1                	beqz	a1,ffffffffc020a5e6 <sfs_truncfile+0xf4>
ffffffffc020a61c:	8566                	mv	a0,s9
ffffffffc020a61e:	c0eff0ef          	jal	ra,ffffffffc0209a2c <sfs_block_free>
ffffffffc020a622:	00092623          	sw	zero,12(s2)
ffffffffc020a626:	008d2603          	lw	a2,8(s10)
ffffffffc020a62a:	367d                	addiw	a2,a2,-1
ffffffffc020a62c:	bf6d                	j	ffffffffc020a5e6 <sfs_truncfile+0xf4>
ffffffffc020a62e:	4681                	li	a3,0
ffffffffc020a630:	8626                	mv	a2,s1
ffffffffc020a632:	85ce                	mv	a1,s3
ffffffffc020a634:	8566                	mv	a0,s9
ffffffffc020a636:	eb0ff0ef          	jal	ra,ffffffffc0209ce6 <sfs_bmap_load_nolock>
ffffffffc020a63a:	892a                	mv	s2,a0
ffffffffc020a63c:	ed11                	bnez	a0,ffffffffc020a658 <sfs_truncfile+0x166>
ffffffffc020a63e:	2485                	addiw	s1,s1,1
ffffffffc020a640:	fe9417e3          	bne	s0,s1,ffffffffc020a62e <sfs_truncfile+0x13c>
ffffffffc020a644:	008aa483          	lw	s1,8(s5)
ffffffffc020a648:	0a941b63          	bne	s0,s1,ffffffffc020a6fe <sfs_truncfile+0x20c>
ffffffffc020a64c:	014aa023          	sw	s4,0(s5)
ffffffffc020a650:	4785                	li	a5,1
ffffffffc020a652:	00f9b823          	sd	a5,16(s3)
ffffffffc020a656:	4901                	li	s2,0
ffffffffc020a658:	855a                	mv	a0,s6
ffffffffc020a65a:	9fafa0ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020a65e:	bddd                	j	ffffffffc020a554 <sfs_truncfile+0x62>
ffffffffc020a660:	86e2                	mv	a3,s8
ffffffffc020a662:	4611                	li	a2,4
ffffffffc020a664:	086c                	addi	a1,sp,28
ffffffffc020a666:	8566                	mv	a0,s9
ffffffffc020a668:	273000ef          	jal	ra,ffffffffc020b0da <sfs_wbuf>
ffffffffc020a66c:	892a                	mv	s2,a0
ffffffffc020a66e:	f56d                	bnez	a0,ffffffffc020a658 <sfs_truncfile+0x166>
ffffffffc020a670:	45e2                	lw	a1,24(sp)
ffffffffc020a672:	8566                	mv	a0,s9
ffffffffc020a674:	bb8ff0ef          	jal	ra,ffffffffc0209a2c <sfs_block_free>
ffffffffc020a678:	b7a5                	j	ffffffffc020a5e0 <sfs_truncfile+0xee>
ffffffffc020a67a:	5975                	li	s2,-3
ffffffffc020a67c:	bde1                	j	ffffffffc020a554 <sfs_truncfile+0x62>
ffffffffc020a67e:	00005697          	auipc	a3,0x5
ffffffffc020a682:	a0268693          	addi	a3,a3,-1534 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc020a686:	00001617          	auipc	a2,0x1
ffffffffc020a68a:	69a60613          	addi	a2,a2,1690 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a68e:	3b000593          	li	a1,944
ffffffffc020a692:	00005517          	auipc	a0,0x5
ffffffffc020a696:	bce50513          	addi	a0,a0,-1074 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a69a:	b95f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a69e:	00005697          	auipc	a3,0x5
ffffffffc020a6a2:	b8a68693          	addi	a3,a3,-1142 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc020a6a6:	00001617          	auipc	a2,0x1
ffffffffc020a6aa:	67a60613          	addi	a2,a2,1658 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a6ae:	3b100593          	li	a1,945
ffffffffc020a6b2:	00005517          	auipc	a0,0x5
ffffffffc020a6b6:	bae50513          	addi	a0,a0,-1106 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a6ba:	b75f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a6be:	00005697          	auipc	a3,0x5
ffffffffc020a6c2:	dc268693          	addi	a3,a3,-574 # ffffffffc020f480 <dev_node_ops+0x4b8>
ffffffffc020a6c6:	00001617          	auipc	a2,0x1
ffffffffc020a6ca:	65a60613          	addi	a2,a2,1626 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a6ce:	17b00593          	li	a1,379
ffffffffc020a6d2:	00005517          	auipc	a0,0x5
ffffffffc020a6d6:	b8e50513          	addi	a0,a0,-1138 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a6da:	b55f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a6de:	00005697          	auipc	a3,0x5
ffffffffc020a6e2:	d8a68693          	addi	a3,a3,-630 # ffffffffc020f468 <dev_node_ops+0x4a0>
ffffffffc020a6e6:	00001617          	auipc	a2,0x1
ffffffffc020a6ea:	63a60613          	addi	a2,a2,1594 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a6ee:	3b800593          	li	a1,952
ffffffffc020a6f2:	00005517          	auipc	a0,0x5
ffffffffc020a6f6:	b6e50513          	addi	a0,a0,-1170 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a6fa:	b35f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a6fe:	00005697          	auipc	a3,0x5
ffffffffc020a702:	dd268693          	addi	a3,a3,-558 # ffffffffc020f4d0 <dev_node_ops+0x508>
ffffffffc020a706:	00001617          	auipc	a2,0x1
ffffffffc020a70a:	61a60613          	addi	a2,a2,1562 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a70e:	3d100593          	li	a1,977
ffffffffc020a712:	00005517          	auipc	a0,0x5
ffffffffc020a716:	b4e50513          	addi	a0,a0,-1202 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a71a:	b15f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a71e:	00005697          	auipc	a3,0x5
ffffffffc020a722:	d7a68693          	addi	a3,a3,-646 # ffffffffc020f498 <dev_node_ops+0x4d0>
ffffffffc020a726:	00001617          	auipc	a2,0x1
ffffffffc020a72a:	5fa60613          	addi	a2,a2,1530 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a72e:	12b00593          	li	a1,299
ffffffffc020a732:	00005517          	auipc	a0,0x5
ffffffffc020a736:	b2e50513          	addi	a0,a0,-1234 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a73a:	af5f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a73e:	8762                	mv	a4,s8
ffffffffc020a740:	86be                	mv	a3,a5
ffffffffc020a742:	00005617          	auipc	a2,0x5
ffffffffc020a746:	b4e60613          	addi	a2,a2,-1202 # ffffffffc020f290 <dev_node_ops+0x2c8>
ffffffffc020a74a:	05300593          	li	a1,83
ffffffffc020a74e:	00005517          	auipc	a0,0x5
ffffffffc020a752:	b1250513          	addi	a0,a0,-1262 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a756:	ad9f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a75a <sfs_load_inode>:
ffffffffc020a75a:	7139                	addi	sp,sp,-64
ffffffffc020a75c:	fc06                	sd	ra,56(sp)
ffffffffc020a75e:	f822                	sd	s0,48(sp)
ffffffffc020a760:	f426                	sd	s1,40(sp)
ffffffffc020a762:	f04a                	sd	s2,32(sp)
ffffffffc020a764:	84b2                	mv	s1,a2
ffffffffc020a766:	892a                	mv	s2,a0
ffffffffc020a768:	ec4e                	sd	s3,24(sp)
ffffffffc020a76a:	e852                	sd	s4,16(sp)
ffffffffc020a76c:	89ae                	mv	s3,a1
ffffffffc020a76e:	e456                	sd	s5,8(sp)
ffffffffc020a770:	a61fe0ef          	jal	ra,ffffffffc02091d0 <lock_sfs_fs>
ffffffffc020a774:	45a9                	li	a1,10
ffffffffc020a776:	8526                	mv	a0,s1
ffffffffc020a778:	0a893403          	ld	s0,168(s2)
ffffffffc020a77c:	096010ef          	jal	ra,ffffffffc020b812 <hash32>
ffffffffc020a780:	02051793          	slli	a5,a0,0x20
ffffffffc020a784:	01c7d713          	srli	a4,a5,0x1c
ffffffffc020a788:	9722                	add	a4,a4,s0
ffffffffc020a78a:	843a                	mv	s0,a4
ffffffffc020a78c:	a029                	j	ffffffffc020a796 <sfs_load_inode+0x3c>
ffffffffc020a78e:	fc042783          	lw	a5,-64(s0)
ffffffffc020a792:	10978863          	beq	a5,s1,ffffffffc020a8a2 <sfs_load_inode+0x148>
ffffffffc020a796:	6400                	ld	s0,8(s0)
ffffffffc020a798:	fe871be3          	bne	a4,s0,ffffffffc020a78e <sfs_load_inode+0x34>
ffffffffc020a79c:	04000513          	li	a0,64
ffffffffc020a7a0:	930f90ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc020a7a4:	8aaa                	mv	s5,a0
ffffffffc020a7a6:	16050563          	beqz	a0,ffffffffc020a910 <sfs_load_inode+0x1b6>
ffffffffc020a7aa:	00492683          	lw	a3,4(s2)
ffffffffc020a7ae:	18048363          	beqz	s1,ffffffffc020a934 <sfs_load_inode+0x1da>
ffffffffc020a7b2:	18d4f163          	bgeu	s1,a3,ffffffffc020a934 <sfs_load_inode+0x1da>
ffffffffc020a7b6:	03893503          	ld	a0,56(s2)
ffffffffc020a7ba:	85a6                	mv	a1,s1
ffffffffc020a7bc:	6e4000ef          	jal	ra,ffffffffc020aea0 <bitmap_test>
ffffffffc020a7c0:	18051763          	bnez	a0,ffffffffc020a94e <sfs_load_inode+0x1f4>
ffffffffc020a7c4:	4701                	li	a4,0
ffffffffc020a7c6:	86a6                	mv	a3,s1
ffffffffc020a7c8:	04000613          	li	a2,64
ffffffffc020a7cc:	85d6                	mv	a1,s5
ffffffffc020a7ce:	854a                	mv	a0,s2
ffffffffc020a7d0:	08b000ef          	jal	ra,ffffffffc020b05a <sfs_rbuf>
ffffffffc020a7d4:	842a                	mv	s0,a0
ffffffffc020a7d6:	0e051563          	bnez	a0,ffffffffc020a8c0 <sfs_load_inode+0x166>
ffffffffc020a7da:	006ad783          	lhu	a5,6(s5)
ffffffffc020a7de:	12078b63          	beqz	a5,ffffffffc020a914 <sfs_load_inode+0x1ba>
ffffffffc020a7e2:	6405                	lui	s0,0x1
ffffffffc020a7e4:	23540513          	addi	a0,s0,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a7e8:	ac7fd0ef          	jal	ra,ffffffffc02082ae <__alloc_inode>
ffffffffc020a7ec:	8a2a                	mv	s4,a0
ffffffffc020a7ee:	c961                	beqz	a0,ffffffffc020a8be <sfs_load_inode+0x164>
ffffffffc020a7f0:	004ad683          	lhu	a3,4(s5)
ffffffffc020a7f4:	4785                	li	a5,1
ffffffffc020a7f6:	0cf69c63          	bne	a3,a5,ffffffffc020a8ce <sfs_load_inode+0x174>
ffffffffc020a7fa:	864a                	mv	a2,s2
ffffffffc020a7fc:	00005597          	auipc	a1,0x5
ffffffffc020a800:	de458593          	addi	a1,a1,-540 # ffffffffc020f5e0 <sfs_node_fileops>
ffffffffc020a804:	ac7fd0ef          	jal	ra,ffffffffc02082ca <inode_init>
ffffffffc020a808:	058a2783          	lw	a5,88(s4)
ffffffffc020a80c:	23540413          	addi	s0,s0,565
ffffffffc020a810:	0e879063          	bne	a5,s0,ffffffffc020a8f0 <sfs_load_inode+0x196>
ffffffffc020a814:	4785                	li	a5,1
ffffffffc020a816:	00fa2c23          	sw	a5,24(s4)
ffffffffc020a81a:	015a3023          	sd	s5,0(s4)
ffffffffc020a81e:	009a2423          	sw	s1,8(s4)
ffffffffc020a822:	000a3823          	sd	zero,16(s4)
ffffffffc020a826:	4585                	li	a1,1
ffffffffc020a828:	020a0513          	addi	a0,s4,32
ffffffffc020a82c:	820fa0ef          	jal	ra,ffffffffc020484c <sem_init>
ffffffffc020a830:	058a2703          	lw	a4,88(s4)
ffffffffc020a834:	6785                	lui	a5,0x1
ffffffffc020a836:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a83a:	14f71663          	bne	a4,a5,ffffffffc020a986 <sfs_load_inode+0x22c>
ffffffffc020a83e:	0a093703          	ld	a4,160(s2)
ffffffffc020a842:	038a0793          	addi	a5,s4,56
ffffffffc020a846:	008a2503          	lw	a0,8(s4)
ffffffffc020a84a:	e31c                	sd	a5,0(a4)
ffffffffc020a84c:	0af93023          	sd	a5,160(s2)
ffffffffc020a850:	09890793          	addi	a5,s2,152
ffffffffc020a854:	0a893403          	ld	s0,168(s2)
ffffffffc020a858:	45a9                	li	a1,10
ffffffffc020a85a:	04ea3023          	sd	a4,64(s4)
ffffffffc020a85e:	02fa3c23          	sd	a5,56(s4)
ffffffffc020a862:	7b1000ef          	jal	ra,ffffffffc020b812 <hash32>
ffffffffc020a866:	02051713          	slli	a4,a0,0x20
ffffffffc020a86a:	01c75793          	srli	a5,a4,0x1c
ffffffffc020a86e:	97a2                	add	a5,a5,s0
ffffffffc020a870:	6798                	ld	a4,8(a5)
ffffffffc020a872:	048a0693          	addi	a3,s4,72
ffffffffc020a876:	e314                	sd	a3,0(a4)
ffffffffc020a878:	e794                	sd	a3,8(a5)
ffffffffc020a87a:	04ea3823          	sd	a4,80(s4)
ffffffffc020a87e:	04fa3423          	sd	a5,72(s4)
ffffffffc020a882:	854a                	mv	a0,s2
ffffffffc020a884:	95dfe0ef          	jal	ra,ffffffffc02091e0 <unlock_sfs_fs>
ffffffffc020a888:	4401                	li	s0,0
ffffffffc020a88a:	0149b023          	sd	s4,0(s3)
ffffffffc020a88e:	70e2                	ld	ra,56(sp)
ffffffffc020a890:	8522                	mv	a0,s0
ffffffffc020a892:	7442                	ld	s0,48(sp)
ffffffffc020a894:	74a2                	ld	s1,40(sp)
ffffffffc020a896:	7902                	ld	s2,32(sp)
ffffffffc020a898:	69e2                	ld	s3,24(sp)
ffffffffc020a89a:	6a42                	ld	s4,16(sp)
ffffffffc020a89c:	6aa2                	ld	s5,8(sp)
ffffffffc020a89e:	6121                	addi	sp,sp,64
ffffffffc020a8a0:	8082                	ret
ffffffffc020a8a2:	fb840a13          	addi	s4,s0,-72
ffffffffc020a8a6:	8552                	mv	a0,s4
ffffffffc020a8a8:	a85fd0ef          	jal	ra,ffffffffc020832c <inode_ref_inc>
ffffffffc020a8ac:	4785                	li	a5,1
ffffffffc020a8ae:	fcf51ae3          	bne	a0,a5,ffffffffc020a882 <sfs_load_inode+0x128>
ffffffffc020a8b2:	fd042783          	lw	a5,-48(s0)
ffffffffc020a8b6:	2785                	addiw	a5,a5,1
ffffffffc020a8b8:	fcf42823          	sw	a5,-48(s0)
ffffffffc020a8bc:	b7d9                	j	ffffffffc020a882 <sfs_load_inode+0x128>
ffffffffc020a8be:	5471                	li	s0,-4
ffffffffc020a8c0:	8556                	mv	a0,s5
ffffffffc020a8c2:	8bef90ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020a8c6:	854a                	mv	a0,s2
ffffffffc020a8c8:	919fe0ef          	jal	ra,ffffffffc02091e0 <unlock_sfs_fs>
ffffffffc020a8cc:	b7c9                	j	ffffffffc020a88e <sfs_load_inode+0x134>
ffffffffc020a8ce:	4789                	li	a5,2
ffffffffc020a8d0:	08f69f63          	bne	a3,a5,ffffffffc020a96e <sfs_load_inode+0x214>
ffffffffc020a8d4:	864a                	mv	a2,s2
ffffffffc020a8d6:	00005597          	auipc	a1,0x5
ffffffffc020a8da:	c8a58593          	addi	a1,a1,-886 # ffffffffc020f560 <sfs_node_dirops>
ffffffffc020a8de:	9edfd0ef          	jal	ra,ffffffffc02082ca <inode_init>
ffffffffc020a8e2:	058a2703          	lw	a4,88(s4)
ffffffffc020a8e6:	6785                	lui	a5,0x1
ffffffffc020a8e8:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a8ec:	f2f704e3          	beq	a4,a5,ffffffffc020a814 <sfs_load_inode+0xba>
ffffffffc020a8f0:	00005697          	auipc	a3,0x5
ffffffffc020a8f4:	93868693          	addi	a3,a3,-1736 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc020a8f8:	00001617          	auipc	a2,0x1
ffffffffc020a8fc:	42860613          	addi	a2,a2,1064 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a900:	07700593          	li	a1,119
ffffffffc020a904:	00005517          	auipc	a0,0x5
ffffffffc020a908:	95c50513          	addi	a0,a0,-1700 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a90c:	923f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a910:	5471                	li	s0,-4
ffffffffc020a912:	bf55                	j	ffffffffc020a8c6 <sfs_load_inode+0x16c>
ffffffffc020a914:	00005697          	auipc	a3,0x5
ffffffffc020a918:	bd468693          	addi	a3,a3,-1068 # ffffffffc020f4e8 <dev_node_ops+0x520>
ffffffffc020a91c:	00001617          	auipc	a2,0x1
ffffffffc020a920:	40460613          	addi	a2,a2,1028 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a924:	0ad00593          	li	a1,173
ffffffffc020a928:	00005517          	auipc	a0,0x5
ffffffffc020a92c:	93850513          	addi	a0,a0,-1736 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a930:	8fff50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a934:	8726                	mv	a4,s1
ffffffffc020a936:	00005617          	auipc	a2,0x5
ffffffffc020a93a:	95a60613          	addi	a2,a2,-1702 # ffffffffc020f290 <dev_node_ops+0x2c8>
ffffffffc020a93e:	05300593          	li	a1,83
ffffffffc020a942:	00005517          	auipc	a0,0x5
ffffffffc020a946:	91e50513          	addi	a0,a0,-1762 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a94a:	8e5f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a94e:	00005697          	auipc	a3,0x5
ffffffffc020a952:	97a68693          	addi	a3,a3,-1670 # ffffffffc020f2c8 <dev_node_ops+0x300>
ffffffffc020a956:	00001617          	auipc	a2,0x1
ffffffffc020a95a:	3ca60613          	addi	a2,a2,970 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a95e:	0a800593          	li	a1,168
ffffffffc020a962:	00005517          	auipc	a0,0x5
ffffffffc020a966:	8fe50513          	addi	a0,a0,-1794 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a96a:	8c5f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a96e:	00005617          	auipc	a2,0x5
ffffffffc020a972:	90a60613          	addi	a2,a2,-1782 # ffffffffc020f278 <dev_node_ops+0x2b0>
ffffffffc020a976:	02e00593          	li	a1,46
ffffffffc020a97a:	00005517          	auipc	a0,0x5
ffffffffc020a97e:	8e650513          	addi	a0,a0,-1818 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a982:	8adf50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020a986:	00005697          	auipc	a3,0x5
ffffffffc020a98a:	8a268693          	addi	a3,a3,-1886 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc020a98e:	00001617          	auipc	a2,0x1
ffffffffc020a992:	39260613          	addi	a2,a2,914 # ffffffffc020bd20 <commands+0x250>
ffffffffc020a996:	0b100593          	li	a1,177
ffffffffc020a99a:	00005517          	auipc	a0,0x5
ffffffffc020a99e:	8c650513          	addi	a0,a0,-1850 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020a9a2:	88df50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020a9a6 <sfs_lookup>:
ffffffffc020a9a6:	7139                	addi	sp,sp,-64
ffffffffc020a9a8:	ec4e                	sd	s3,24(sp)
ffffffffc020a9aa:	06853983          	ld	s3,104(a0)
ffffffffc020a9ae:	fc06                	sd	ra,56(sp)
ffffffffc020a9b0:	f822                	sd	s0,48(sp)
ffffffffc020a9b2:	f426                	sd	s1,40(sp)
ffffffffc020a9b4:	f04a                	sd	s2,32(sp)
ffffffffc020a9b6:	e852                	sd	s4,16(sp)
ffffffffc020a9b8:	0a098c63          	beqz	s3,ffffffffc020aa70 <sfs_lookup+0xca>
ffffffffc020a9bc:	0b09a783          	lw	a5,176(s3)
ffffffffc020a9c0:	ebc5                	bnez	a5,ffffffffc020aa70 <sfs_lookup+0xca>
ffffffffc020a9c2:	0005c783          	lbu	a5,0(a1)
ffffffffc020a9c6:	84ae                	mv	s1,a1
ffffffffc020a9c8:	c7c1                	beqz	a5,ffffffffc020aa50 <sfs_lookup+0xaa>
ffffffffc020a9ca:	02f00713          	li	a4,47
ffffffffc020a9ce:	08e78163          	beq	a5,a4,ffffffffc020aa50 <sfs_lookup+0xaa>
ffffffffc020a9d2:	842a                	mv	s0,a0
ffffffffc020a9d4:	8a32                	mv	s4,a2
ffffffffc020a9d6:	957fd0ef          	jal	ra,ffffffffc020832c <inode_ref_inc>
ffffffffc020a9da:	4c38                	lw	a4,88(s0)
ffffffffc020a9dc:	6785                	lui	a5,0x1
ffffffffc020a9de:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a9e2:	0af71763          	bne	a4,a5,ffffffffc020aa90 <sfs_lookup+0xea>
ffffffffc020a9e6:	6018                	ld	a4,0(s0)
ffffffffc020a9e8:	4789                	li	a5,2
ffffffffc020a9ea:	00475703          	lhu	a4,4(a4)
ffffffffc020a9ee:	04f71c63          	bne	a4,a5,ffffffffc020aa46 <sfs_lookup+0xa0>
ffffffffc020a9f2:	02040913          	addi	s2,s0,32
ffffffffc020a9f6:	854a                	mv	a0,s2
ffffffffc020a9f8:	e61f90ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc020a9fc:	8626                	mv	a2,s1
ffffffffc020a9fe:	0054                	addi	a3,sp,4
ffffffffc020aa00:	85a2                	mv	a1,s0
ffffffffc020aa02:	854e                	mv	a0,s3
ffffffffc020aa04:	a29ff0ef          	jal	ra,ffffffffc020a42c <sfs_dirent_search_nolock.constprop.0>
ffffffffc020aa08:	84aa                	mv	s1,a0
ffffffffc020aa0a:	854a                	mv	a0,s2
ffffffffc020aa0c:	e49f90ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020aa10:	cc89                	beqz	s1,ffffffffc020aa2a <sfs_lookup+0x84>
ffffffffc020aa12:	8522                	mv	a0,s0
ffffffffc020aa14:	9e7fd0ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc020aa18:	70e2                	ld	ra,56(sp)
ffffffffc020aa1a:	7442                	ld	s0,48(sp)
ffffffffc020aa1c:	7902                	ld	s2,32(sp)
ffffffffc020aa1e:	69e2                	ld	s3,24(sp)
ffffffffc020aa20:	6a42                	ld	s4,16(sp)
ffffffffc020aa22:	8526                	mv	a0,s1
ffffffffc020aa24:	74a2                	ld	s1,40(sp)
ffffffffc020aa26:	6121                	addi	sp,sp,64
ffffffffc020aa28:	8082                	ret
ffffffffc020aa2a:	4612                	lw	a2,4(sp)
ffffffffc020aa2c:	002c                	addi	a1,sp,8
ffffffffc020aa2e:	854e                	mv	a0,s3
ffffffffc020aa30:	d2bff0ef          	jal	ra,ffffffffc020a75a <sfs_load_inode>
ffffffffc020aa34:	84aa                	mv	s1,a0
ffffffffc020aa36:	8522                	mv	a0,s0
ffffffffc020aa38:	9c3fd0ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc020aa3c:	fcf1                	bnez	s1,ffffffffc020aa18 <sfs_lookup+0x72>
ffffffffc020aa3e:	67a2                	ld	a5,8(sp)
ffffffffc020aa40:	00fa3023          	sd	a5,0(s4)
ffffffffc020aa44:	bfd1                	j	ffffffffc020aa18 <sfs_lookup+0x72>
ffffffffc020aa46:	8522                	mv	a0,s0
ffffffffc020aa48:	9b3fd0ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc020aa4c:	54b9                	li	s1,-18
ffffffffc020aa4e:	b7e9                	j	ffffffffc020aa18 <sfs_lookup+0x72>
ffffffffc020aa50:	00005697          	auipc	a3,0x5
ffffffffc020aa54:	ab068693          	addi	a3,a3,-1360 # ffffffffc020f500 <dev_node_ops+0x538>
ffffffffc020aa58:	00001617          	auipc	a2,0x1
ffffffffc020aa5c:	2c860613          	addi	a2,a2,712 # ffffffffc020bd20 <commands+0x250>
ffffffffc020aa60:	3e200593          	li	a1,994
ffffffffc020aa64:	00004517          	auipc	a0,0x4
ffffffffc020aa68:	7fc50513          	addi	a0,a0,2044 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020aa6c:	fc2f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020aa70:	00004697          	auipc	a3,0x4
ffffffffc020aa74:	61068693          	addi	a3,a3,1552 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc020aa78:	00001617          	auipc	a2,0x1
ffffffffc020aa7c:	2a860613          	addi	a2,a2,680 # ffffffffc020bd20 <commands+0x250>
ffffffffc020aa80:	3e100593          	li	a1,993
ffffffffc020aa84:	00004517          	auipc	a0,0x4
ffffffffc020aa88:	7dc50513          	addi	a0,a0,2012 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020aa8c:	fa2f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020aa90:	00004697          	auipc	a3,0x4
ffffffffc020aa94:	79868693          	addi	a3,a3,1944 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc020aa98:	00001617          	auipc	a2,0x1
ffffffffc020aa9c:	28860613          	addi	a2,a2,648 # ffffffffc020bd20 <commands+0x250>
ffffffffc020aaa0:	3e400593          	li	a1,996
ffffffffc020aaa4:	00004517          	auipc	a0,0x4
ffffffffc020aaa8:	7bc50513          	addi	a0,a0,1980 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020aaac:	f82f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020aab0 <sfs_namefile>:
ffffffffc020aab0:	6d98                	ld	a4,24(a1)
ffffffffc020aab2:	7175                	addi	sp,sp,-144
ffffffffc020aab4:	e506                	sd	ra,136(sp)
ffffffffc020aab6:	e122                	sd	s0,128(sp)
ffffffffc020aab8:	fca6                	sd	s1,120(sp)
ffffffffc020aaba:	f8ca                	sd	s2,112(sp)
ffffffffc020aabc:	f4ce                	sd	s3,104(sp)
ffffffffc020aabe:	f0d2                	sd	s4,96(sp)
ffffffffc020aac0:	ecd6                	sd	s5,88(sp)
ffffffffc020aac2:	e8da                	sd	s6,80(sp)
ffffffffc020aac4:	e4de                	sd	s7,72(sp)
ffffffffc020aac6:	e0e2                	sd	s8,64(sp)
ffffffffc020aac8:	fc66                	sd	s9,56(sp)
ffffffffc020aaca:	f86a                	sd	s10,48(sp)
ffffffffc020aacc:	f46e                	sd	s11,40(sp)
ffffffffc020aace:	e42e                	sd	a1,8(sp)
ffffffffc020aad0:	4789                	li	a5,2
ffffffffc020aad2:	1ae7f363          	bgeu	a5,a4,ffffffffc020ac78 <sfs_namefile+0x1c8>
ffffffffc020aad6:	89aa                	mv	s3,a0
ffffffffc020aad8:	10400513          	li	a0,260
ffffffffc020aadc:	df5f80ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc020aae0:	842a                	mv	s0,a0
ffffffffc020aae2:	18050b63          	beqz	a0,ffffffffc020ac78 <sfs_namefile+0x1c8>
ffffffffc020aae6:	0689b483          	ld	s1,104(s3)
ffffffffc020aaea:	1e048963          	beqz	s1,ffffffffc020acdc <sfs_namefile+0x22c>
ffffffffc020aaee:	0b04a783          	lw	a5,176(s1)
ffffffffc020aaf2:	1e079563          	bnez	a5,ffffffffc020acdc <sfs_namefile+0x22c>
ffffffffc020aaf6:	0589ac83          	lw	s9,88(s3)
ffffffffc020aafa:	6785                	lui	a5,0x1
ffffffffc020aafc:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020ab00:	1afc9e63          	bne	s9,a5,ffffffffc020acbc <sfs_namefile+0x20c>
ffffffffc020ab04:	6722                	ld	a4,8(sp)
ffffffffc020ab06:	854e                	mv	a0,s3
ffffffffc020ab08:	8ace                	mv	s5,s3
ffffffffc020ab0a:	6f1c                	ld	a5,24(a4)
ffffffffc020ab0c:	00073b03          	ld	s6,0(a4)
ffffffffc020ab10:	02098a13          	addi	s4,s3,32
ffffffffc020ab14:	ffe78b93          	addi	s7,a5,-2
ffffffffc020ab18:	9b3e                	add	s6,s6,a5
ffffffffc020ab1a:	00005d17          	auipc	s10,0x5
ffffffffc020ab1e:	a06d0d13          	addi	s10,s10,-1530 # ffffffffc020f520 <dev_node_ops+0x558>
ffffffffc020ab22:	80bfd0ef          	jal	ra,ffffffffc020832c <inode_ref_inc>
ffffffffc020ab26:	00440c13          	addi	s8,s0,4
ffffffffc020ab2a:	e066                	sd	s9,0(sp)
ffffffffc020ab2c:	8552                	mv	a0,s4
ffffffffc020ab2e:	d2bf90ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc020ab32:	0854                	addi	a3,sp,20
ffffffffc020ab34:	866a                	mv	a2,s10
ffffffffc020ab36:	85d6                	mv	a1,s5
ffffffffc020ab38:	8526                	mv	a0,s1
ffffffffc020ab3a:	8f3ff0ef          	jal	ra,ffffffffc020a42c <sfs_dirent_search_nolock.constprop.0>
ffffffffc020ab3e:	8daa                	mv	s11,a0
ffffffffc020ab40:	8552                	mv	a0,s4
ffffffffc020ab42:	d13f90ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020ab46:	020d8863          	beqz	s11,ffffffffc020ab76 <sfs_namefile+0xc6>
ffffffffc020ab4a:	854e                	mv	a0,s3
ffffffffc020ab4c:	8affd0ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc020ab50:	8522                	mv	a0,s0
ffffffffc020ab52:	e2ff80ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020ab56:	60aa                	ld	ra,136(sp)
ffffffffc020ab58:	640a                	ld	s0,128(sp)
ffffffffc020ab5a:	74e6                	ld	s1,120(sp)
ffffffffc020ab5c:	7946                	ld	s2,112(sp)
ffffffffc020ab5e:	79a6                	ld	s3,104(sp)
ffffffffc020ab60:	7a06                	ld	s4,96(sp)
ffffffffc020ab62:	6ae6                	ld	s5,88(sp)
ffffffffc020ab64:	6b46                	ld	s6,80(sp)
ffffffffc020ab66:	6ba6                	ld	s7,72(sp)
ffffffffc020ab68:	6c06                	ld	s8,64(sp)
ffffffffc020ab6a:	7ce2                	ld	s9,56(sp)
ffffffffc020ab6c:	7d42                	ld	s10,48(sp)
ffffffffc020ab6e:	856e                	mv	a0,s11
ffffffffc020ab70:	7da2                	ld	s11,40(sp)
ffffffffc020ab72:	6149                	addi	sp,sp,144
ffffffffc020ab74:	8082                	ret
ffffffffc020ab76:	4652                	lw	a2,20(sp)
ffffffffc020ab78:	082c                	addi	a1,sp,24
ffffffffc020ab7a:	8526                	mv	a0,s1
ffffffffc020ab7c:	bdfff0ef          	jal	ra,ffffffffc020a75a <sfs_load_inode>
ffffffffc020ab80:	8daa                	mv	s11,a0
ffffffffc020ab82:	f561                	bnez	a0,ffffffffc020ab4a <sfs_namefile+0x9a>
ffffffffc020ab84:	854e                	mv	a0,s3
ffffffffc020ab86:	008aa903          	lw	s2,8(s5)
ffffffffc020ab8a:	871fd0ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc020ab8e:	6ce2                	ld	s9,24(sp)
ffffffffc020ab90:	0b3c8463          	beq	s9,s3,ffffffffc020ac38 <sfs_namefile+0x188>
ffffffffc020ab94:	100c8463          	beqz	s9,ffffffffc020ac9c <sfs_namefile+0x1ec>
ffffffffc020ab98:	058ca703          	lw	a4,88(s9)
ffffffffc020ab9c:	6782                	ld	a5,0(sp)
ffffffffc020ab9e:	0ef71f63          	bne	a4,a5,ffffffffc020ac9c <sfs_namefile+0x1ec>
ffffffffc020aba2:	008ca703          	lw	a4,8(s9)
ffffffffc020aba6:	8ae6                	mv	s5,s9
ffffffffc020aba8:	0d270a63          	beq	a4,s2,ffffffffc020ac7c <sfs_namefile+0x1cc>
ffffffffc020abac:	000cb703          	ld	a4,0(s9)
ffffffffc020abb0:	4789                	li	a5,2
ffffffffc020abb2:	00475703          	lhu	a4,4(a4)
ffffffffc020abb6:	0cf71363          	bne	a4,a5,ffffffffc020ac7c <sfs_namefile+0x1cc>
ffffffffc020abba:	020c8a13          	addi	s4,s9,32
ffffffffc020abbe:	8552                	mv	a0,s4
ffffffffc020abc0:	c99f90ef          	jal	ra,ffffffffc0204858 <down>
ffffffffc020abc4:	000cb703          	ld	a4,0(s9)
ffffffffc020abc8:	00872983          	lw	s3,8(a4)
ffffffffc020abcc:	01304963          	bgtz	s3,ffffffffc020abde <sfs_namefile+0x12e>
ffffffffc020abd0:	a899                	j	ffffffffc020ac26 <sfs_namefile+0x176>
ffffffffc020abd2:	4018                	lw	a4,0(s0)
ffffffffc020abd4:	01270e63          	beq	a4,s2,ffffffffc020abf0 <sfs_namefile+0x140>
ffffffffc020abd8:	2d85                	addiw	s11,s11,1
ffffffffc020abda:	05b98663          	beq	s3,s11,ffffffffc020ac26 <sfs_namefile+0x176>
ffffffffc020abde:	86a2                	mv	a3,s0
ffffffffc020abe0:	866e                	mv	a2,s11
ffffffffc020abe2:	85e6                	mv	a1,s9
ffffffffc020abe4:	8526                	mv	a0,s1
ffffffffc020abe6:	e48ff0ef          	jal	ra,ffffffffc020a22e <sfs_dirent_read_nolock>
ffffffffc020abea:	872a                	mv	a4,a0
ffffffffc020abec:	d17d                	beqz	a0,ffffffffc020abd2 <sfs_namefile+0x122>
ffffffffc020abee:	a82d                	j	ffffffffc020ac28 <sfs_namefile+0x178>
ffffffffc020abf0:	8552                	mv	a0,s4
ffffffffc020abf2:	c63f90ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020abf6:	8562                	mv	a0,s8
ffffffffc020abf8:	692000ef          	jal	ra,ffffffffc020b28a <strlen>
ffffffffc020abfc:	00150793          	addi	a5,a0,1
ffffffffc020ac00:	862a                	mv	a2,a0
ffffffffc020ac02:	06fbe863          	bltu	s7,a5,ffffffffc020ac72 <sfs_namefile+0x1c2>
ffffffffc020ac06:	fff64913          	not	s2,a2
ffffffffc020ac0a:	995a                	add	s2,s2,s6
ffffffffc020ac0c:	85e2                	mv	a1,s8
ffffffffc020ac0e:	854a                	mv	a0,s2
ffffffffc020ac10:	40fb8bb3          	sub	s7,s7,a5
ffffffffc020ac14:	76a000ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc020ac18:	02f00793          	li	a5,47
ffffffffc020ac1c:	fefb0fa3          	sb	a5,-1(s6)
ffffffffc020ac20:	89e6                	mv	s3,s9
ffffffffc020ac22:	8b4a                	mv	s6,s2
ffffffffc020ac24:	b721                	j	ffffffffc020ab2c <sfs_namefile+0x7c>
ffffffffc020ac26:	5741                	li	a4,-16
ffffffffc020ac28:	8552                	mv	a0,s4
ffffffffc020ac2a:	e03a                	sd	a4,0(sp)
ffffffffc020ac2c:	c29f90ef          	jal	ra,ffffffffc0204854 <up>
ffffffffc020ac30:	6702                	ld	a4,0(sp)
ffffffffc020ac32:	89e6                	mv	s3,s9
ffffffffc020ac34:	8dba                	mv	s11,a4
ffffffffc020ac36:	bf11                	j	ffffffffc020ab4a <sfs_namefile+0x9a>
ffffffffc020ac38:	854e                	mv	a0,s3
ffffffffc020ac3a:	fc0fd0ef          	jal	ra,ffffffffc02083fa <inode_ref_dec>
ffffffffc020ac3e:	64a2                	ld	s1,8(sp)
ffffffffc020ac40:	85da                	mv	a1,s6
ffffffffc020ac42:	6c98                	ld	a4,24(s1)
ffffffffc020ac44:	6088                	ld	a0,0(s1)
ffffffffc020ac46:	1779                	addi	a4,a4,-2
ffffffffc020ac48:	41770bb3          	sub	s7,a4,s7
ffffffffc020ac4c:	865e                	mv	a2,s7
ffffffffc020ac4e:	0505                	addi	a0,a0,1
ffffffffc020ac50:	6ee000ef          	jal	ra,ffffffffc020b33e <memmove>
ffffffffc020ac54:	02f00713          	li	a4,47
ffffffffc020ac58:	fee50fa3          	sb	a4,-1(a0)
ffffffffc020ac5c:	955e                	add	a0,a0,s7
ffffffffc020ac5e:	00050023          	sb	zero,0(a0)
ffffffffc020ac62:	85de                	mv	a1,s7
ffffffffc020ac64:	8526                	mv	a0,s1
ffffffffc020ac66:	c4bfa0ef          	jal	ra,ffffffffc02058b0 <iobuf_skip>
ffffffffc020ac6a:	8522                	mv	a0,s0
ffffffffc020ac6c:	d15f80ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020ac70:	b5dd                	j	ffffffffc020ab56 <sfs_namefile+0xa6>
ffffffffc020ac72:	89e6                	mv	s3,s9
ffffffffc020ac74:	5df1                	li	s11,-4
ffffffffc020ac76:	bdd1                	j	ffffffffc020ab4a <sfs_namefile+0x9a>
ffffffffc020ac78:	5df1                	li	s11,-4
ffffffffc020ac7a:	bdf1                	j	ffffffffc020ab56 <sfs_namefile+0xa6>
ffffffffc020ac7c:	00005697          	auipc	a3,0x5
ffffffffc020ac80:	8ac68693          	addi	a3,a3,-1876 # ffffffffc020f528 <dev_node_ops+0x560>
ffffffffc020ac84:	00001617          	auipc	a2,0x1
ffffffffc020ac88:	09c60613          	addi	a2,a2,156 # ffffffffc020bd20 <commands+0x250>
ffffffffc020ac8c:	30000593          	li	a1,768
ffffffffc020ac90:	00004517          	auipc	a0,0x4
ffffffffc020ac94:	5d050513          	addi	a0,a0,1488 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020ac98:	d96f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020ac9c:	00004697          	auipc	a3,0x4
ffffffffc020aca0:	58c68693          	addi	a3,a3,1420 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc020aca4:	00001617          	auipc	a2,0x1
ffffffffc020aca8:	07c60613          	addi	a2,a2,124 # ffffffffc020bd20 <commands+0x250>
ffffffffc020acac:	2ff00593          	li	a1,767
ffffffffc020acb0:	00004517          	auipc	a0,0x4
ffffffffc020acb4:	5b050513          	addi	a0,a0,1456 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020acb8:	d76f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020acbc:	00004697          	auipc	a3,0x4
ffffffffc020acc0:	56c68693          	addi	a3,a3,1388 # ffffffffc020f228 <dev_node_ops+0x260>
ffffffffc020acc4:	00001617          	auipc	a2,0x1
ffffffffc020acc8:	05c60613          	addi	a2,a2,92 # ffffffffc020bd20 <commands+0x250>
ffffffffc020accc:	2ec00593          	li	a1,748
ffffffffc020acd0:	00004517          	auipc	a0,0x4
ffffffffc020acd4:	59050513          	addi	a0,a0,1424 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020acd8:	d56f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020acdc:	00004697          	auipc	a3,0x4
ffffffffc020ace0:	3a468693          	addi	a3,a3,932 # ffffffffc020f080 <dev_node_ops+0xb8>
ffffffffc020ace4:	00001617          	auipc	a2,0x1
ffffffffc020ace8:	03c60613          	addi	a2,a2,60 # ffffffffc020bd20 <commands+0x250>
ffffffffc020acec:	2eb00593          	li	a1,747
ffffffffc020acf0:	00004517          	auipc	a0,0x4
ffffffffc020acf4:	57050513          	addi	a0,a0,1392 # ffffffffc020f260 <dev_node_ops+0x298>
ffffffffc020acf8:	d36f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020acfc <bitmap_translate.part.0>:
ffffffffc020acfc:	1141                	addi	sp,sp,-16
ffffffffc020acfe:	00005697          	auipc	a3,0x5
ffffffffc020ad02:	96268693          	addi	a3,a3,-1694 # ffffffffc020f660 <sfs_node_fileops+0x80>
ffffffffc020ad06:	00001617          	auipc	a2,0x1
ffffffffc020ad0a:	01a60613          	addi	a2,a2,26 # ffffffffc020bd20 <commands+0x250>
ffffffffc020ad0e:	04c00593          	li	a1,76
ffffffffc020ad12:	00005517          	auipc	a0,0x5
ffffffffc020ad16:	96650513          	addi	a0,a0,-1690 # ffffffffc020f678 <sfs_node_fileops+0x98>
ffffffffc020ad1a:	e406                	sd	ra,8(sp)
ffffffffc020ad1c:	d12f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020ad20 <bitmap_create>:
ffffffffc020ad20:	7139                	addi	sp,sp,-64
ffffffffc020ad22:	fc06                	sd	ra,56(sp)
ffffffffc020ad24:	f822                	sd	s0,48(sp)
ffffffffc020ad26:	f426                	sd	s1,40(sp)
ffffffffc020ad28:	f04a                	sd	s2,32(sp)
ffffffffc020ad2a:	ec4e                	sd	s3,24(sp)
ffffffffc020ad2c:	e852                	sd	s4,16(sp)
ffffffffc020ad2e:	e456                	sd	s5,8(sp)
ffffffffc020ad30:	c14d                	beqz	a0,ffffffffc020add2 <bitmap_create+0xb2>
ffffffffc020ad32:	842a                	mv	s0,a0
ffffffffc020ad34:	4541                	li	a0,16
ffffffffc020ad36:	b9bf80ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc020ad3a:	84aa                	mv	s1,a0
ffffffffc020ad3c:	cd25                	beqz	a0,ffffffffc020adb4 <bitmap_create+0x94>
ffffffffc020ad3e:	02041a13          	slli	s4,s0,0x20
ffffffffc020ad42:	020a5a13          	srli	s4,s4,0x20
ffffffffc020ad46:	01fa0793          	addi	a5,s4,31
ffffffffc020ad4a:	0057d993          	srli	s3,a5,0x5
ffffffffc020ad4e:	00299a93          	slli	s5,s3,0x2
ffffffffc020ad52:	8556                	mv	a0,s5
ffffffffc020ad54:	894e                	mv	s2,s3
ffffffffc020ad56:	b7bf80ef          	jal	ra,ffffffffc02038d0 <kmalloc>
ffffffffc020ad5a:	c53d                	beqz	a0,ffffffffc020adc8 <bitmap_create+0xa8>
ffffffffc020ad5c:	0134a223          	sw	s3,4(s1)
ffffffffc020ad60:	c080                	sw	s0,0(s1)
ffffffffc020ad62:	8656                	mv	a2,s5
ffffffffc020ad64:	0ff00593          	li	a1,255
ffffffffc020ad68:	5c4000ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc020ad6c:	e488                	sd	a0,8(s1)
ffffffffc020ad6e:	0996                	slli	s3,s3,0x5
ffffffffc020ad70:	053a0263          	beq	s4,s3,ffffffffc020adb4 <bitmap_create+0x94>
ffffffffc020ad74:	fff9079b          	addiw	a5,s2,-1
ffffffffc020ad78:	0057969b          	slliw	a3,a5,0x5
ffffffffc020ad7c:	0054561b          	srliw	a2,s0,0x5
ffffffffc020ad80:	40d4073b          	subw	a4,s0,a3
ffffffffc020ad84:	0054541b          	srliw	s0,s0,0x5
ffffffffc020ad88:	08f61463          	bne	a2,a5,ffffffffc020ae10 <bitmap_create+0xf0>
ffffffffc020ad8c:	fff7069b          	addiw	a3,a4,-1
ffffffffc020ad90:	47f9                	li	a5,30
ffffffffc020ad92:	04d7ef63          	bltu	a5,a3,ffffffffc020adf0 <bitmap_create+0xd0>
ffffffffc020ad96:	1402                	slli	s0,s0,0x20
ffffffffc020ad98:	8079                	srli	s0,s0,0x1e
ffffffffc020ad9a:	9522                	add	a0,a0,s0
ffffffffc020ad9c:	411c                	lw	a5,0(a0)
ffffffffc020ad9e:	4585                	li	a1,1
ffffffffc020ada0:	02000613          	li	a2,32
ffffffffc020ada4:	00e596bb          	sllw	a3,a1,a4
ffffffffc020ada8:	8fb5                	xor	a5,a5,a3
ffffffffc020adaa:	2705                	addiw	a4,a4,1
ffffffffc020adac:	2781                	sext.w	a5,a5
ffffffffc020adae:	fec71be3          	bne	a4,a2,ffffffffc020ada4 <bitmap_create+0x84>
ffffffffc020adb2:	c11c                	sw	a5,0(a0)
ffffffffc020adb4:	70e2                	ld	ra,56(sp)
ffffffffc020adb6:	7442                	ld	s0,48(sp)
ffffffffc020adb8:	7902                	ld	s2,32(sp)
ffffffffc020adba:	69e2                	ld	s3,24(sp)
ffffffffc020adbc:	6a42                	ld	s4,16(sp)
ffffffffc020adbe:	6aa2                	ld	s5,8(sp)
ffffffffc020adc0:	8526                	mv	a0,s1
ffffffffc020adc2:	74a2                	ld	s1,40(sp)
ffffffffc020adc4:	6121                	addi	sp,sp,64
ffffffffc020adc6:	8082                	ret
ffffffffc020adc8:	8526                	mv	a0,s1
ffffffffc020adca:	bb7f80ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020adce:	4481                	li	s1,0
ffffffffc020add0:	b7d5                	j	ffffffffc020adb4 <bitmap_create+0x94>
ffffffffc020add2:	00005697          	auipc	a3,0x5
ffffffffc020add6:	8be68693          	addi	a3,a3,-1858 # ffffffffc020f690 <sfs_node_fileops+0xb0>
ffffffffc020adda:	00001617          	auipc	a2,0x1
ffffffffc020adde:	f4660613          	addi	a2,a2,-186 # ffffffffc020bd20 <commands+0x250>
ffffffffc020ade2:	45d5                	li	a1,21
ffffffffc020ade4:	00005517          	auipc	a0,0x5
ffffffffc020ade8:	89450513          	addi	a0,a0,-1900 # ffffffffc020f678 <sfs_node_fileops+0x98>
ffffffffc020adec:	c42f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020adf0:	00005697          	auipc	a3,0x5
ffffffffc020adf4:	8e068693          	addi	a3,a3,-1824 # ffffffffc020f6d0 <sfs_node_fileops+0xf0>
ffffffffc020adf8:	00001617          	auipc	a2,0x1
ffffffffc020adfc:	f2860613          	addi	a2,a2,-216 # ffffffffc020bd20 <commands+0x250>
ffffffffc020ae00:	02b00593          	li	a1,43
ffffffffc020ae04:	00005517          	auipc	a0,0x5
ffffffffc020ae08:	87450513          	addi	a0,a0,-1932 # ffffffffc020f678 <sfs_node_fileops+0x98>
ffffffffc020ae0c:	c22f50ef          	jal	ra,ffffffffc020022e <__panic>
ffffffffc020ae10:	00005697          	auipc	a3,0x5
ffffffffc020ae14:	8a868693          	addi	a3,a3,-1880 # ffffffffc020f6b8 <sfs_node_fileops+0xd8>
ffffffffc020ae18:	00001617          	auipc	a2,0x1
ffffffffc020ae1c:	f0860613          	addi	a2,a2,-248 # ffffffffc020bd20 <commands+0x250>
ffffffffc020ae20:	02a00593          	li	a1,42
ffffffffc020ae24:	00005517          	auipc	a0,0x5
ffffffffc020ae28:	85450513          	addi	a0,a0,-1964 # ffffffffc020f678 <sfs_node_fileops+0x98>
ffffffffc020ae2c:	c02f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020ae30 <bitmap_alloc>:
ffffffffc020ae30:	4150                	lw	a2,4(a0)
ffffffffc020ae32:	651c                	ld	a5,8(a0)
ffffffffc020ae34:	c231                	beqz	a2,ffffffffc020ae78 <bitmap_alloc+0x48>
ffffffffc020ae36:	4701                	li	a4,0
ffffffffc020ae38:	a029                	j	ffffffffc020ae42 <bitmap_alloc+0x12>
ffffffffc020ae3a:	2705                	addiw	a4,a4,1
ffffffffc020ae3c:	0791                	addi	a5,a5,4
ffffffffc020ae3e:	02e60d63          	beq	a2,a4,ffffffffc020ae78 <bitmap_alloc+0x48>
ffffffffc020ae42:	4394                	lw	a3,0(a5)
ffffffffc020ae44:	dafd                	beqz	a3,ffffffffc020ae3a <bitmap_alloc+0xa>
ffffffffc020ae46:	4501                	li	a0,0
ffffffffc020ae48:	4885                	li	a7,1
ffffffffc020ae4a:	8e36                	mv	t3,a3
ffffffffc020ae4c:	02000313          	li	t1,32
ffffffffc020ae50:	a021                	j	ffffffffc020ae58 <bitmap_alloc+0x28>
ffffffffc020ae52:	2505                	addiw	a0,a0,1
ffffffffc020ae54:	02650463          	beq	a0,t1,ffffffffc020ae7c <bitmap_alloc+0x4c>
ffffffffc020ae58:	00a8983b          	sllw	a6,a7,a0
ffffffffc020ae5c:	0106f633          	and	a2,a3,a6
ffffffffc020ae60:	2601                	sext.w	a2,a2
ffffffffc020ae62:	da65                	beqz	a2,ffffffffc020ae52 <bitmap_alloc+0x22>
ffffffffc020ae64:	010e4833          	xor	a6,t3,a6
ffffffffc020ae68:	0057171b          	slliw	a4,a4,0x5
ffffffffc020ae6c:	9f29                	addw	a4,a4,a0
ffffffffc020ae6e:	0107a023          	sw	a6,0(a5)
ffffffffc020ae72:	c198                	sw	a4,0(a1)
ffffffffc020ae74:	4501                	li	a0,0
ffffffffc020ae76:	8082                	ret
ffffffffc020ae78:	5571                	li	a0,-4
ffffffffc020ae7a:	8082                	ret
ffffffffc020ae7c:	1141                	addi	sp,sp,-16
ffffffffc020ae7e:	00002697          	auipc	a3,0x2
ffffffffc020ae82:	9da68693          	addi	a3,a3,-1574 # ffffffffc020c858 <commands+0xd88>
ffffffffc020ae86:	00001617          	auipc	a2,0x1
ffffffffc020ae8a:	e9a60613          	addi	a2,a2,-358 # ffffffffc020bd20 <commands+0x250>
ffffffffc020ae8e:	04300593          	li	a1,67
ffffffffc020ae92:	00004517          	auipc	a0,0x4
ffffffffc020ae96:	7e650513          	addi	a0,a0,2022 # ffffffffc020f678 <sfs_node_fileops+0x98>
ffffffffc020ae9a:	e406                	sd	ra,8(sp)
ffffffffc020ae9c:	b92f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020aea0 <bitmap_test>:
ffffffffc020aea0:	411c                	lw	a5,0(a0)
ffffffffc020aea2:	00f5ff63          	bgeu	a1,a5,ffffffffc020aec0 <bitmap_test+0x20>
ffffffffc020aea6:	651c                	ld	a5,8(a0)
ffffffffc020aea8:	0055d71b          	srliw	a4,a1,0x5
ffffffffc020aeac:	070a                	slli	a4,a4,0x2
ffffffffc020aeae:	97ba                	add	a5,a5,a4
ffffffffc020aeb0:	4388                	lw	a0,0(a5)
ffffffffc020aeb2:	4785                	li	a5,1
ffffffffc020aeb4:	00b795bb          	sllw	a1,a5,a1
ffffffffc020aeb8:	8d6d                	and	a0,a0,a1
ffffffffc020aeba:	1502                	slli	a0,a0,0x20
ffffffffc020aebc:	9101                	srli	a0,a0,0x20
ffffffffc020aebe:	8082                	ret
ffffffffc020aec0:	1141                	addi	sp,sp,-16
ffffffffc020aec2:	e406                	sd	ra,8(sp)
ffffffffc020aec4:	e39ff0ef          	jal	ra,ffffffffc020acfc <bitmap_translate.part.0>

ffffffffc020aec8 <bitmap_free>:
ffffffffc020aec8:	411c                	lw	a5,0(a0)
ffffffffc020aeca:	1141                	addi	sp,sp,-16
ffffffffc020aecc:	e406                	sd	ra,8(sp)
ffffffffc020aece:	02f5f463          	bgeu	a1,a5,ffffffffc020aef6 <bitmap_free+0x2e>
ffffffffc020aed2:	651c                	ld	a5,8(a0)
ffffffffc020aed4:	0055d71b          	srliw	a4,a1,0x5
ffffffffc020aed8:	070a                	slli	a4,a4,0x2
ffffffffc020aeda:	97ba                	add	a5,a5,a4
ffffffffc020aedc:	4398                	lw	a4,0(a5)
ffffffffc020aede:	4685                	li	a3,1
ffffffffc020aee0:	00b695bb          	sllw	a1,a3,a1
ffffffffc020aee4:	00b776b3          	and	a3,a4,a1
ffffffffc020aee8:	2681                	sext.w	a3,a3
ffffffffc020aeea:	ea81                	bnez	a3,ffffffffc020aefa <bitmap_free+0x32>
ffffffffc020aeec:	60a2                	ld	ra,8(sp)
ffffffffc020aeee:	8f4d                	or	a4,a4,a1
ffffffffc020aef0:	c398                	sw	a4,0(a5)
ffffffffc020aef2:	0141                	addi	sp,sp,16
ffffffffc020aef4:	8082                	ret
ffffffffc020aef6:	e07ff0ef          	jal	ra,ffffffffc020acfc <bitmap_translate.part.0>
ffffffffc020aefa:	00004697          	auipc	a3,0x4
ffffffffc020aefe:	7fe68693          	addi	a3,a3,2046 # ffffffffc020f6f8 <sfs_node_fileops+0x118>
ffffffffc020af02:	00001617          	auipc	a2,0x1
ffffffffc020af06:	e1e60613          	addi	a2,a2,-482 # ffffffffc020bd20 <commands+0x250>
ffffffffc020af0a:	05f00593          	li	a1,95
ffffffffc020af0e:	00004517          	auipc	a0,0x4
ffffffffc020af12:	76a50513          	addi	a0,a0,1898 # ffffffffc020f678 <sfs_node_fileops+0x98>
ffffffffc020af16:	b18f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020af1a <bitmap_destroy>:
ffffffffc020af1a:	1141                	addi	sp,sp,-16
ffffffffc020af1c:	e022                	sd	s0,0(sp)
ffffffffc020af1e:	842a                	mv	s0,a0
ffffffffc020af20:	6508                	ld	a0,8(a0)
ffffffffc020af22:	e406                	sd	ra,8(sp)
ffffffffc020af24:	a5df80ef          	jal	ra,ffffffffc0203980 <kfree>
ffffffffc020af28:	8522                	mv	a0,s0
ffffffffc020af2a:	6402                	ld	s0,0(sp)
ffffffffc020af2c:	60a2                	ld	ra,8(sp)
ffffffffc020af2e:	0141                	addi	sp,sp,16
ffffffffc020af30:	a51f806f          	j	ffffffffc0203980 <kfree>

ffffffffc020af34 <bitmap_getdata>:
ffffffffc020af34:	c589                	beqz	a1,ffffffffc020af3e <bitmap_getdata+0xa>
ffffffffc020af36:	00456783          	lwu	a5,4(a0)
ffffffffc020af3a:	078a                	slli	a5,a5,0x2
ffffffffc020af3c:	e19c                	sd	a5,0(a1)
ffffffffc020af3e:	6508                	ld	a0,8(a0)
ffffffffc020af40:	8082                	ret

ffffffffc020af42 <sfs_rwblock_nolock>:
ffffffffc020af42:	7139                	addi	sp,sp,-64
ffffffffc020af44:	f822                	sd	s0,48(sp)
ffffffffc020af46:	f426                	sd	s1,40(sp)
ffffffffc020af48:	fc06                	sd	ra,56(sp)
ffffffffc020af4a:	842a                	mv	s0,a0
ffffffffc020af4c:	84b6                	mv	s1,a3
ffffffffc020af4e:	e211                	bnez	a2,ffffffffc020af52 <sfs_rwblock_nolock+0x10>
ffffffffc020af50:	e715                	bnez	a4,ffffffffc020af7c <sfs_rwblock_nolock+0x3a>
ffffffffc020af52:	405c                	lw	a5,4(s0)
ffffffffc020af54:	02f67463          	bgeu	a2,a5,ffffffffc020af7c <sfs_rwblock_nolock+0x3a>
ffffffffc020af58:	00c6169b          	slliw	a3,a2,0xc
ffffffffc020af5c:	1682                	slli	a3,a3,0x20
ffffffffc020af5e:	6605                	lui	a2,0x1
ffffffffc020af60:	9281                	srli	a3,a3,0x20
ffffffffc020af62:	850a                	mv	a0,sp
ffffffffc020af64:	8d7fa0ef          	jal	ra,ffffffffc020583a <iobuf_init>
ffffffffc020af68:	85aa                	mv	a1,a0
ffffffffc020af6a:	7808                	ld	a0,48(s0)
ffffffffc020af6c:	8626                	mv	a2,s1
ffffffffc020af6e:	7118                	ld	a4,32(a0)
ffffffffc020af70:	9702                	jalr	a4
ffffffffc020af72:	70e2                	ld	ra,56(sp)
ffffffffc020af74:	7442                	ld	s0,48(sp)
ffffffffc020af76:	74a2                	ld	s1,40(sp)
ffffffffc020af78:	6121                	addi	sp,sp,64
ffffffffc020af7a:	8082                	ret
ffffffffc020af7c:	00004697          	auipc	a3,0x4
ffffffffc020af80:	78c68693          	addi	a3,a3,1932 # ffffffffc020f708 <sfs_node_fileops+0x128>
ffffffffc020af84:	00001617          	auipc	a2,0x1
ffffffffc020af88:	d9c60613          	addi	a2,a2,-612 # ffffffffc020bd20 <commands+0x250>
ffffffffc020af8c:	45d5                	li	a1,21
ffffffffc020af8e:	00004517          	auipc	a0,0x4
ffffffffc020af92:	7b250513          	addi	a0,a0,1970 # ffffffffc020f740 <sfs_node_fileops+0x160>
ffffffffc020af96:	a98f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020af9a <sfs_rblock>:
ffffffffc020af9a:	7139                	addi	sp,sp,-64
ffffffffc020af9c:	ec4e                	sd	s3,24(sp)
ffffffffc020af9e:	89b6                	mv	s3,a3
ffffffffc020afa0:	f822                	sd	s0,48(sp)
ffffffffc020afa2:	f04a                	sd	s2,32(sp)
ffffffffc020afa4:	e852                	sd	s4,16(sp)
ffffffffc020afa6:	fc06                	sd	ra,56(sp)
ffffffffc020afa8:	f426                	sd	s1,40(sp)
ffffffffc020afaa:	e456                	sd	s5,8(sp)
ffffffffc020afac:	8a2a                	mv	s4,a0
ffffffffc020afae:	892e                	mv	s2,a1
ffffffffc020afb0:	8432                	mv	s0,a2
ffffffffc020afb2:	a26fe0ef          	jal	ra,ffffffffc02091d8 <lock_sfs_io>
ffffffffc020afb6:	04098063          	beqz	s3,ffffffffc020aff6 <sfs_rblock+0x5c>
ffffffffc020afba:	013409bb          	addw	s3,s0,s3
ffffffffc020afbe:	6a85                	lui	s5,0x1
ffffffffc020afc0:	a021                	j	ffffffffc020afc8 <sfs_rblock+0x2e>
ffffffffc020afc2:	9956                	add	s2,s2,s5
ffffffffc020afc4:	02898963          	beq	s3,s0,ffffffffc020aff6 <sfs_rblock+0x5c>
ffffffffc020afc8:	8622                	mv	a2,s0
ffffffffc020afca:	85ca                	mv	a1,s2
ffffffffc020afcc:	4705                	li	a4,1
ffffffffc020afce:	4681                	li	a3,0
ffffffffc020afd0:	8552                	mv	a0,s4
ffffffffc020afd2:	f71ff0ef          	jal	ra,ffffffffc020af42 <sfs_rwblock_nolock>
ffffffffc020afd6:	84aa                	mv	s1,a0
ffffffffc020afd8:	2405                	addiw	s0,s0,1
ffffffffc020afda:	d565                	beqz	a0,ffffffffc020afc2 <sfs_rblock+0x28>
ffffffffc020afdc:	8552                	mv	a0,s4
ffffffffc020afde:	a0afe0ef          	jal	ra,ffffffffc02091e8 <unlock_sfs_io>
ffffffffc020afe2:	70e2                	ld	ra,56(sp)
ffffffffc020afe4:	7442                	ld	s0,48(sp)
ffffffffc020afe6:	7902                	ld	s2,32(sp)
ffffffffc020afe8:	69e2                	ld	s3,24(sp)
ffffffffc020afea:	6a42                	ld	s4,16(sp)
ffffffffc020afec:	6aa2                	ld	s5,8(sp)
ffffffffc020afee:	8526                	mv	a0,s1
ffffffffc020aff0:	74a2                	ld	s1,40(sp)
ffffffffc020aff2:	6121                	addi	sp,sp,64
ffffffffc020aff4:	8082                	ret
ffffffffc020aff6:	4481                	li	s1,0
ffffffffc020aff8:	b7d5                	j	ffffffffc020afdc <sfs_rblock+0x42>

ffffffffc020affa <sfs_wblock>:
ffffffffc020affa:	7139                	addi	sp,sp,-64
ffffffffc020affc:	ec4e                	sd	s3,24(sp)
ffffffffc020affe:	89b6                	mv	s3,a3
ffffffffc020b000:	f822                	sd	s0,48(sp)
ffffffffc020b002:	f04a                	sd	s2,32(sp)
ffffffffc020b004:	e852                	sd	s4,16(sp)
ffffffffc020b006:	fc06                	sd	ra,56(sp)
ffffffffc020b008:	f426                	sd	s1,40(sp)
ffffffffc020b00a:	e456                	sd	s5,8(sp)
ffffffffc020b00c:	8a2a                	mv	s4,a0
ffffffffc020b00e:	892e                	mv	s2,a1
ffffffffc020b010:	8432                	mv	s0,a2
ffffffffc020b012:	9c6fe0ef          	jal	ra,ffffffffc02091d8 <lock_sfs_io>
ffffffffc020b016:	04098063          	beqz	s3,ffffffffc020b056 <sfs_wblock+0x5c>
ffffffffc020b01a:	013409bb          	addw	s3,s0,s3
ffffffffc020b01e:	6a85                	lui	s5,0x1
ffffffffc020b020:	a021                	j	ffffffffc020b028 <sfs_wblock+0x2e>
ffffffffc020b022:	9956                	add	s2,s2,s5
ffffffffc020b024:	02898963          	beq	s3,s0,ffffffffc020b056 <sfs_wblock+0x5c>
ffffffffc020b028:	8622                	mv	a2,s0
ffffffffc020b02a:	85ca                	mv	a1,s2
ffffffffc020b02c:	4705                	li	a4,1
ffffffffc020b02e:	4685                	li	a3,1
ffffffffc020b030:	8552                	mv	a0,s4
ffffffffc020b032:	f11ff0ef          	jal	ra,ffffffffc020af42 <sfs_rwblock_nolock>
ffffffffc020b036:	84aa                	mv	s1,a0
ffffffffc020b038:	2405                	addiw	s0,s0,1
ffffffffc020b03a:	d565                	beqz	a0,ffffffffc020b022 <sfs_wblock+0x28>
ffffffffc020b03c:	8552                	mv	a0,s4
ffffffffc020b03e:	9aafe0ef          	jal	ra,ffffffffc02091e8 <unlock_sfs_io>
ffffffffc020b042:	70e2                	ld	ra,56(sp)
ffffffffc020b044:	7442                	ld	s0,48(sp)
ffffffffc020b046:	7902                	ld	s2,32(sp)
ffffffffc020b048:	69e2                	ld	s3,24(sp)
ffffffffc020b04a:	6a42                	ld	s4,16(sp)
ffffffffc020b04c:	6aa2                	ld	s5,8(sp)
ffffffffc020b04e:	8526                	mv	a0,s1
ffffffffc020b050:	74a2                	ld	s1,40(sp)
ffffffffc020b052:	6121                	addi	sp,sp,64
ffffffffc020b054:	8082                	ret
ffffffffc020b056:	4481                	li	s1,0
ffffffffc020b058:	b7d5                	j	ffffffffc020b03c <sfs_wblock+0x42>

ffffffffc020b05a <sfs_rbuf>:
ffffffffc020b05a:	7179                	addi	sp,sp,-48
ffffffffc020b05c:	f406                	sd	ra,40(sp)
ffffffffc020b05e:	f022                	sd	s0,32(sp)
ffffffffc020b060:	ec26                	sd	s1,24(sp)
ffffffffc020b062:	e84a                	sd	s2,16(sp)
ffffffffc020b064:	e44e                	sd	s3,8(sp)
ffffffffc020b066:	e052                	sd	s4,0(sp)
ffffffffc020b068:	6785                	lui	a5,0x1
ffffffffc020b06a:	04f77863          	bgeu	a4,a5,ffffffffc020b0ba <sfs_rbuf+0x60>
ffffffffc020b06e:	84ba                	mv	s1,a4
ffffffffc020b070:	9732                	add	a4,a4,a2
ffffffffc020b072:	89b2                	mv	s3,a2
ffffffffc020b074:	04e7e363          	bltu	a5,a4,ffffffffc020b0ba <sfs_rbuf+0x60>
ffffffffc020b078:	8936                	mv	s2,a3
ffffffffc020b07a:	842a                	mv	s0,a0
ffffffffc020b07c:	8a2e                	mv	s4,a1
ffffffffc020b07e:	95afe0ef          	jal	ra,ffffffffc02091d8 <lock_sfs_io>
ffffffffc020b082:	642c                	ld	a1,72(s0)
ffffffffc020b084:	864a                	mv	a2,s2
ffffffffc020b086:	4705                	li	a4,1
ffffffffc020b088:	4681                	li	a3,0
ffffffffc020b08a:	8522                	mv	a0,s0
ffffffffc020b08c:	eb7ff0ef          	jal	ra,ffffffffc020af42 <sfs_rwblock_nolock>
ffffffffc020b090:	892a                	mv	s2,a0
ffffffffc020b092:	cd09                	beqz	a0,ffffffffc020b0ac <sfs_rbuf+0x52>
ffffffffc020b094:	8522                	mv	a0,s0
ffffffffc020b096:	952fe0ef          	jal	ra,ffffffffc02091e8 <unlock_sfs_io>
ffffffffc020b09a:	70a2                	ld	ra,40(sp)
ffffffffc020b09c:	7402                	ld	s0,32(sp)
ffffffffc020b09e:	64e2                	ld	s1,24(sp)
ffffffffc020b0a0:	69a2                	ld	s3,8(sp)
ffffffffc020b0a2:	6a02                	ld	s4,0(sp)
ffffffffc020b0a4:	854a                	mv	a0,s2
ffffffffc020b0a6:	6942                	ld	s2,16(sp)
ffffffffc020b0a8:	6145                	addi	sp,sp,48
ffffffffc020b0aa:	8082                	ret
ffffffffc020b0ac:	642c                	ld	a1,72(s0)
ffffffffc020b0ae:	864e                	mv	a2,s3
ffffffffc020b0b0:	8552                	mv	a0,s4
ffffffffc020b0b2:	95a6                	add	a1,a1,s1
ffffffffc020b0b4:	2ca000ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc020b0b8:	bff1                	j	ffffffffc020b094 <sfs_rbuf+0x3a>
ffffffffc020b0ba:	00004697          	auipc	a3,0x4
ffffffffc020b0be:	69e68693          	addi	a3,a3,1694 # ffffffffc020f758 <sfs_node_fileops+0x178>
ffffffffc020b0c2:	00001617          	auipc	a2,0x1
ffffffffc020b0c6:	c5e60613          	addi	a2,a2,-930 # ffffffffc020bd20 <commands+0x250>
ffffffffc020b0ca:	05500593          	li	a1,85
ffffffffc020b0ce:	00004517          	auipc	a0,0x4
ffffffffc020b0d2:	67250513          	addi	a0,a0,1650 # ffffffffc020f740 <sfs_node_fileops+0x160>
ffffffffc020b0d6:	958f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020b0da <sfs_wbuf>:
ffffffffc020b0da:	7139                	addi	sp,sp,-64
ffffffffc020b0dc:	fc06                	sd	ra,56(sp)
ffffffffc020b0de:	f822                	sd	s0,48(sp)
ffffffffc020b0e0:	f426                	sd	s1,40(sp)
ffffffffc020b0e2:	f04a                	sd	s2,32(sp)
ffffffffc020b0e4:	ec4e                	sd	s3,24(sp)
ffffffffc020b0e6:	e852                	sd	s4,16(sp)
ffffffffc020b0e8:	e456                	sd	s5,8(sp)
ffffffffc020b0ea:	6785                	lui	a5,0x1
ffffffffc020b0ec:	06f77163          	bgeu	a4,a5,ffffffffc020b14e <sfs_wbuf+0x74>
ffffffffc020b0f0:	893a                	mv	s2,a4
ffffffffc020b0f2:	9732                	add	a4,a4,a2
ffffffffc020b0f4:	8a32                	mv	s4,a2
ffffffffc020b0f6:	04e7ec63          	bltu	a5,a4,ffffffffc020b14e <sfs_wbuf+0x74>
ffffffffc020b0fa:	842a                	mv	s0,a0
ffffffffc020b0fc:	89b6                	mv	s3,a3
ffffffffc020b0fe:	8aae                	mv	s5,a1
ffffffffc020b100:	8d8fe0ef          	jal	ra,ffffffffc02091d8 <lock_sfs_io>
ffffffffc020b104:	642c                	ld	a1,72(s0)
ffffffffc020b106:	4705                	li	a4,1
ffffffffc020b108:	4681                	li	a3,0
ffffffffc020b10a:	864e                	mv	a2,s3
ffffffffc020b10c:	8522                	mv	a0,s0
ffffffffc020b10e:	e35ff0ef          	jal	ra,ffffffffc020af42 <sfs_rwblock_nolock>
ffffffffc020b112:	84aa                	mv	s1,a0
ffffffffc020b114:	cd11                	beqz	a0,ffffffffc020b130 <sfs_wbuf+0x56>
ffffffffc020b116:	8522                	mv	a0,s0
ffffffffc020b118:	8d0fe0ef          	jal	ra,ffffffffc02091e8 <unlock_sfs_io>
ffffffffc020b11c:	70e2                	ld	ra,56(sp)
ffffffffc020b11e:	7442                	ld	s0,48(sp)
ffffffffc020b120:	7902                	ld	s2,32(sp)
ffffffffc020b122:	69e2                	ld	s3,24(sp)
ffffffffc020b124:	6a42                	ld	s4,16(sp)
ffffffffc020b126:	6aa2                	ld	s5,8(sp)
ffffffffc020b128:	8526                	mv	a0,s1
ffffffffc020b12a:	74a2                	ld	s1,40(sp)
ffffffffc020b12c:	6121                	addi	sp,sp,64
ffffffffc020b12e:	8082                	ret
ffffffffc020b130:	6428                	ld	a0,72(s0)
ffffffffc020b132:	8652                	mv	a2,s4
ffffffffc020b134:	85d6                	mv	a1,s5
ffffffffc020b136:	954a                	add	a0,a0,s2
ffffffffc020b138:	246000ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc020b13c:	642c                	ld	a1,72(s0)
ffffffffc020b13e:	4705                	li	a4,1
ffffffffc020b140:	4685                	li	a3,1
ffffffffc020b142:	864e                	mv	a2,s3
ffffffffc020b144:	8522                	mv	a0,s0
ffffffffc020b146:	dfdff0ef          	jal	ra,ffffffffc020af42 <sfs_rwblock_nolock>
ffffffffc020b14a:	84aa                	mv	s1,a0
ffffffffc020b14c:	b7e9                	j	ffffffffc020b116 <sfs_wbuf+0x3c>
ffffffffc020b14e:	00004697          	auipc	a3,0x4
ffffffffc020b152:	60a68693          	addi	a3,a3,1546 # ffffffffc020f758 <sfs_node_fileops+0x178>
ffffffffc020b156:	00001617          	auipc	a2,0x1
ffffffffc020b15a:	bca60613          	addi	a2,a2,-1078 # ffffffffc020bd20 <commands+0x250>
ffffffffc020b15e:	06b00593          	li	a1,107
ffffffffc020b162:	00004517          	auipc	a0,0x4
ffffffffc020b166:	5de50513          	addi	a0,a0,1502 # ffffffffc020f740 <sfs_node_fileops+0x160>
ffffffffc020b16a:	8c4f50ef          	jal	ra,ffffffffc020022e <__panic>

ffffffffc020b16e <sfs_sync_super>:
ffffffffc020b16e:	1101                	addi	sp,sp,-32
ffffffffc020b170:	ec06                	sd	ra,24(sp)
ffffffffc020b172:	e822                	sd	s0,16(sp)
ffffffffc020b174:	e426                	sd	s1,8(sp)
ffffffffc020b176:	842a                	mv	s0,a0
ffffffffc020b178:	860fe0ef          	jal	ra,ffffffffc02091d8 <lock_sfs_io>
ffffffffc020b17c:	6428                	ld	a0,72(s0)
ffffffffc020b17e:	6605                	lui	a2,0x1
ffffffffc020b180:	4581                	li	a1,0
ffffffffc020b182:	1aa000ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc020b186:	6428                	ld	a0,72(s0)
ffffffffc020b188:	85a2                	mv	a1,s0
ffffffffc020b18a:	02c00613          	li	a2,44
ffffffffc020b18e:	1f0000ef          	jal	ra,ffffffffc020b37e <memcpy>
ffffffffc020b192:	642c                	ld	a1,72(s0)
ffffffffc020b194:	4701                	li	a4,0
ffffffffc020b196:	4685                	li	a3,1
ffffffffc020b198:	4601                	li	a2,0
ffffffffc020b19a:	8522                	mv	a0,s0
ffffffffc020b19c:	da7ff0ef          	jal	ra,ffffffffc020af42 <sfs_rwblock_nolock>
ffffffffc020b1a0:	84aa                	mv	s1,a0
ffffffffc020b1a2:	8522                	mv	a0,s0
ffffffffc020b1a4:	844fe0ef          	jal	ra,ffffffffc02091e8 <unlock_sfs_io>
ffffffffc020b1a8:	60e2                	ld	ra,24(sp)
ffffffffc020b1aa:	6442                	ld	s0,16(sp)
ffffffffc020b1ac:	8526                	mv	a0,s1
ffffffffc020b1ae:	64a2                	ld	s1,8(sp)
ffffffffc020b1b0:	6105                	addi	sp,sp,32
ffffffffc020b1b2:	8082                	ret

ffffffffc020b1b4 <sfs_sync_freemap>:
ffffffffc020b1b4:	7139                	addi	sp,sp,-64
ffffffffc020b1b6:	ec4e                	sd	s3,24(sp)
ffffffffc020b1b8:	e852                	sd	s4,16(sp)
ffffffffc020b1ba:	00456983          	lwu	s3,4(a0)
ffffffffc020b1be:	8a2a                	mv	s4,a0
ffffffffc020b1c0:	7d08                	ld	a0,56(a0)
ffffffffc020b1c2:	67a1                	lui	a5,0x8
ffffffffc020b1c4:	17fd                	addi	a5,a5,-1
ffffffffc020b1c6:	4581                	li	a1,0
ffffffffc020b1c8:	f822                	sd	s0,48(sp)
ffffffffc020b1ca:	fc06                	sd	ra,56(sp)
ffffffffc020b1cc:	f426                	sd	s1,40(sp)
ffffffffc020b1ce:	f04a                	sd	s2,32(sp)
ffffffffc020b1d0:	e456                	sd	s5,8(sp)
ffffffffc020b1d2:	99be                	add	s3,s3,a5
ffffffffc020b1d4:	d61ff0ef          	jal	ra,ffffffffc020af34 <bitmap_getdata>
ffffffffc020b1d8:	00f9d993          	srli	s3,s3,0xf
ffffffffc020b1dc:	842a                	mv	s0,a0
ffffffffc020b1de:	8552                	mv	a0,s4
ffffffffc020b1e0:	ff9fd0ef          	jal	ra,ffffffffc02091d8 <lock_sfs_io>
ffffffffc020b1e4:	04098163          	beqz	s3,ffffffffc020b226 <sfs_sync_freemap+0x72>
ffffffffc020b1e8:	09b2                	slli	s3,s3,0xc
ffffffffc020b1ea:	99a2                	add	s3,s3,s0
ffffffffc020b1ec:	4909                	li	s2,2
ffffffffc020b1ee:	6a85                	lui	s5,0x1
ffffffffc020b1f0:	a021                	j	ffffffffc020b1f8 <sfs_sync_freemap+0x44>
ffffffffc020b1f2:	2905                	addiw	s2,s2,1
ffffffffc020b1f4:	02898963          	beq	s3,s0,ffffffffc020b226 <sfs_sync_freemap+0x72>
ffffffffc020b1f8:	85a2                	mv	a1,s0
ffffffffc020b1fa:	864a                	mv	a2,s2
ffffffffc020b1fc:	4705                	li	a4,1
ffffffffc020b1fe:	4685                	li	a3,1
ffffffffc020b200:	8552                	mv	a0,s4
ffffffffc020b202:	d41ff0ef          	jal	ra,ffffffffc020af42 <sfs_rwblock_nolock>
ffffffffc020b206:	84aa                	mv	s1,a0
ffffffffc020b208:	9456                	add	s0,s0,s5
ffffffffc020b20a:	d565                	beqz	a0,ffffffffc020b1f2 <sfs_sync_freemap+0x3e>
ffffffffc020b20c:	8552                	mv	a0,s4
ffffffffc020b20e:	fdbfd0ef          	jal	ra,ffffffffc02091e8 <unlock_sfs_io>
ffffffffc020b212:	70e2                	ld	ra,56(sp)
ffffffffc020b214:	7442                	ld	s0,48(sp)
ffffffffc020b216:	7902                	ld	s2,32(sp)
ffffffffc020b218:	69e2                	ld	s3,24(sp)
ffffffffc020b21a:	6a42                	ld	s4,16(sp)
ffffffffc020b21c:	6aa2                	ld	s5,8(sp)
ffffffffc020b21e:	8526                	mv	a0,s1
ffffffffc020b220:	74a2                	ld	s1,40(sp)
ffffffffc020b222:	6121                	addi	sp,sp,64
ffffffffc020b224:	8082                	ret
ffffffffc020b226:	4481                	li	s1,0
ffffffffc020b228:	b7d5                	j	ffffffffc020b20c <sfs_sync_freemap+0x58>

ffffffffc020b22a <sfs_clear_block>:
ffffffffc020b22a:	7179                	addi	sp,sp,-48
ffffffffc020b22c:	f022                	sd	s0,32(sp)
ffffffffc020b22e:	e84a                	sd	s2,16(sp)
ffffffffc020b230:	e44e                	sd	s3,8(sp)
ffffffffc020b232:	f406                	sd	ra,40(sp)
ffffffffc020b234:	89b2                	mv	s3,a2
ffffffffc020b236:	ec26                	sd	s1,24(sp)
ffffffffc020b238:	892a                	mv	s2,a0
ffffffffc020b23a:	842e                	mv	s0,a1
ffffffffc020b23c:	f9dfd0ef          	jal	ra,ffffffffc02091d8 <lock_sfs_io>
ffffffffc020b240:	04893503          	ld	a0,72(s2)
ffffffffc020b244:	6605                	lui	a2,0x1
ffffffffc020b246:	4581                	li	a1,0
ffffffffc020b248:	0e4000ef          	jal	ra,ffffffffc020b32c <memset>
ffffffffc020b24c:	02098d63          	beqz	s3,ffffffffc020b286 <sfs_clear_block+0x5c>
ffffffffc020b250:	013409bb          	addw	s3,s0,s3
ffffffffc020b254:	a019                	j	ffffffffc020b25a <sfs_clear_block+0x30>
ffffffffc020b256:	02898863          	beq	s3,s0,ffffffffc020b286 <sfs_clear_block+0x5c>
ffffffffc020b25a:	04893583          	ld	a1,72(s2)
ffffffffc020b25e:	8622                	mv	a2,s0
ffffffffc020b260:	4705                	li	a4,1
ffffffffc020b262:	4685                	li	a3,1
ffffffffc020b264:	854a                	mv	a0,s2
ffffffffc020b266:	cddff0ef          	jal	ra,ffffffffc020af42 <sfs_rwblock_nolock>
ffffffffc020b26a:	84aa                	mv	s1,a0
ffffffffc020b26c:	2405                	addiw	s0,s0,1
ffffffffc020b26e:	d565                	beqz	a0,ffffffffc020b256 <sfs_clear_block+0x2c>
ffffffffc020b270:	854a                	mv	a0,s2
ffffffffc020b272:	f77fd0ef          	jal	ra,ffffffffc02091e8 <unlock_sfs_io>
ffffffffc020b276:	70a2                	ld	ra,40(sp)
ffffffffc020b278:	7402                	ld	s0,32(sp)
ffffffffc020b27a:	6942                	ld	s2,16(sp)
ffffffffc020b27c:	69a2                	ld	s3,8(sp)
ffffffffc020b27e:	8526                	mv	a0,s1
ffffffffc020b280:	64e2                	ld	s1,24(sp)
ffffffffc020b282:	6145                	addi	sp,sp,48
ffffffffc020b284:	8082                	ret
ffffffffc020b286:	4481                	li	s1,0
ffffffffc020b288:	b7e5                	j	ffffffffc020b270 <sfs_clear_block+0x46>

ffffffffc020b28a <strlen>:
ffffffffc020b28a:	00054783          	lbu	a5,0(a0)
ffffffffc020b28e:	872a                	mv	a4,a0
ffffffffc020b290:	4501                	li	a0,0
ffffffffc020b292:	cb81                	beqz	a5,ffffffffc020b2a2 <strlen+0x18>
ffffffffc020b294:	0505                	addi	a0,a0,1
ffffffffc020b296:	00a707b3          	add	a5,a4,a0
ffffffffc020b29a:	0007c783          	lbu	a5,0(a5) # 8000 <_binary_bin_swap_img_size+0x300>
ffffffffc020b29e:	fbfd                	bnez	a5,ffffffffc020b294 <strlen+0xa>
ffffffffc020b2a0:	8082                	ret
ffffffffc020b2a2:	8082                	ret

ffffffffc020b2a4 <strnlen>:
ffffffffc020b2a4:	4781                	li	a5,0
ffffffffc020b2a6:	e589                	bnez	a1,ffffffffc020b2b0 <strnlen+0xc>
ffffffffc020b2a8:	a811                	j	ffffffffc020b2bc <strnlen+0x18>
ffffffffc020b2aa:	0785                	addi	a5,a5,1
ffffffffc020b2ac:	00f58863          	beq	a1,a5,ffffffffc020b2bc <strnlen+0x18>
ffffffffc020b2b0:	00f50733          	add	a4,a0,a5
ffffffffc020b2b4:	00074703          	lbu	a4,0(a4)
ffffffffc020b2b8:	fb6d                	bnez	a4,ffffffffc020b2aa <strnlen+0x6>
ffffffffc020b2ba:	85be                	mv	a1,a5
ffffffffc020b2bc:	852e                	mv	a0,a1
ffffffffc020b2be:	8082                	ret

ffffffffc020b2c0 <strcpy>:
ffffffffc020b2c0:	87aa                	mv	a5,a0
ffffffffc020b2c2:	0005c703          	lbu	a4,0(a1)
ffffffffc020b2c6:	0785                	addi	a5,a5,1
ffffffffc020b2c8:	0585                	addi	a1,a1,1
ffffffffc020b2ca:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b2ce:	fb75                	bnez	a4,ffffffffc020b2c2 <strcpy+0x2>
ffffffffc020b2d0:	8082                	ret

ffffffffc020b2d2 <strcmp>:
ffffffffc020b2d2:	00054783          	lbu	a5,0(a0)
ffffffffc020b2d6:	0005c703          	lbu	a4,0(a1)
ffffffffc020b2da:	cb89                	beqz	a5,ffffffffc020b2ec <strcmp+0x1a>
ffffffffc020b2dc:	0505                	addi	a0,a0,1
ffffffffc020b2de:	0585                	addi	a1,a1,1
ffffffffc020b2e0:	fee789e3          	beq	a5,a4,ffffffffc020b2d2 <strcmp>
ffffffffc020b2e4:	0007851b          	sext.w	a0,a5
ffffffffc020b2e8:	9d19                	subw	a0,a0,a4
ffffffffc020b2ea:	8082                	ret
ffffffffc020b2ec:	4501                	li	a0,0
ffffffffc020b2ee:	bfed                	j	ffffffffc020b2e8 <strcmp+0x16>

ffffffffc020b2f0 <strncmp>:
ffffffffc020b2f0:	c20d                	beqz	a2,ffffffffc020b312 <strncmp+0x22>
ffffffffc020b2f2:	962e                	add	a2,a2,a1
ffffffffc020b2f4:	a031                	j	ffffffffc020b300 <strncmp+0x10>
ffffffffc020b2f6:	0505                	addi	a0,a0,1
ffffffffc020b2f8:	00e79a63          	bne	a5,a4,ffffffffc020b30c <strncmp+0x1c>
ffffffffc020b2fc:	00b60b63          	beq	a2,a1,ffffffffc020b312 <strncmp+0x22>
ffffffffc020b300:	00054783          	lbu	a5,0(a0)
ffffffffc020b304:	0585                	addi	a1,a1,1
ffffffffc020b306:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020b30a:	f7f5                	bnez	a5,ffffffffc020b2f6 <strncmp+0x6>
ffffffffc020b30c:	40e7853b          	subw	a0,a5,a4
ffffffffc020b310:	8082                	ret
ffffffffc020b312:	4501                	li	a0,0
ffffffffc020b314:	8082                	ret

ffffffffc020b316 <strchr>:
ffffffffc020b316:	00054783          	lbu	a5,0(a0)
ffffffffc020b31a:	c799                	beqz	a5,ffffffffc020b328 <strchr+0x12>
ffffffffc020b31c:	00f58763          	beq	a1,a5,ffffffffc020b32a <strchr+0x14>
ffffffffc020b320:	00154783          	lbu	a5,1(a0)
ffffffffc020b324:	0505                	addi	a0,a0,1
ffffffffc020b326:	fbfd                	bnez	a5,ffffffffc020b31c <strchr+0x6>
ffffffffc020b328:	4501                	li	a0,0
ffffffffc020b32a:	8082                	ret

ffffffffc020b32c <memset>:
ffffffffc020b32c:	ca01                	beqz	a2,ffffffffc020b33c <memset+0x10>
ffffffffc020b32e:	962a                	add	a2,a2,a0
ffffffffc020b330:	87aa                	mv	a5,a0
ffffffffc020b332:	0785                	addi	a5,a5,1
ffffffffc020b334:	feb78fa3          	sb	a1,-1(a5)
ffffffffc020b338:	fec79de3          	bne	a5,a2,ffffffffc020b332 <memset+0x6>
ffffffffc020b33c:	8082                	ret

ffffffffc020b33e <memmove>:
ffffffffc020b33e:	02a5f263          	bgeu	a1,a0,ffffffffc020b362 <memmove+0x24>
ffffffffc020b342:	00c587b3          	add	a5,a1,a2
ffffffffc020b346:	00f57e63          	bgeu	a0,a5,ffffffffc020b362 <memmove+0x24>
ffffffffc020b34a:	00c50733          	add	a4,a0,a2
ffffffffc020b34e:	c615                	beqz	a2,ffffffffc020b37a <memmove+0x3c>
ffffffffc020b350:	fff7c683          	lbu	a3,-1(a5)
ffffffffc020b354:	17fd                	addi	a5,a5,-1
ffffffffc020b356:	177d                	addi	a4,a4,-1
ffffffffc020b358:	00d70023          	sb	a3,0(a4)
ffffffffc020b35c:	fef59ae3          	bne	a1,a5,ffffffffc020b350 <memmove+0x12>
ffffffffc020b360:	8082                	ret
ffffffffc020b362:	00c586b3          	add	a3,a1,a2
ffffffffc020b366:	87aa                	mv	a5,a0
ffffffffc020b368:	ca11                	beqz	a2,ffffffffc020b37c <memmove+0x3e>
ffffffffc020b36a:	0005c703          	lbu	a4,0(a1)
ffffffffc020b36e:	0585                	addi	a1,a1,1
ffffffffc020b370:	0785                	addi	a5,a5,1
ffffffffc020b372:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b376:	fed59ae3          	bne	a1,a3,ffffffffc020b36a <memmove+0x2c>
ffffffffc020b37a:	8082                	ret
ffffffffc020b37c:	8082                	ret

ffffffffc020b37e <memcpy>:
ffffffffc020b37e:	ca19                	beqz	a2,ffffffffc020b394 <memcpy+0x16>
ffffffffc020b380:	962e                	add	a2,a2,a1
ffffffffc020b382:	87aa                	mv	a5,a0
ffffffffc020b384:	0005c703          	lbu	a4,0(a1)
ffffffffc020b388:	0585                	addi	a1,a1,1
ffffffffc020b38a:	0785                	addi	a5,a5,1
ffffffffc020b38c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b390:	fec59ae3          	bne	a1,a2,ffffffffc020b384 <memcpy+0x6>
ffffffffc020b394:	8082                	ret

ffffffffc020b396 <printnum>:
ffffffffc020b396:	02071893          	slli	a7,a4,0x20
ffffffffc020b39a:	7139                	addi	sp,sp,-64
ffffffffc020b39c:	0208d893          	srli	a7,a7,0x20
ffffffffc020b3a0:	e456                	sd	s5,8(sp)
ffffffffc020b3a2:	0316fab3          	remu	s5,a3,a7
ffffffffc020b3a6:	f822                	sd	s0,48(sp)
ffffffffc020b3a8:	f426                	sd	s1,40(sp)
ffffffffc020b3aa:	f04a                	sd	s2,32(sp)
ffffffffc020b3ac:	ec4e                	sd	s3,24(sp)
ffffffffc020b3ae:	fc06                	sd	ra,56(sp)
ffffffffc020b3b0:	e852                	sd	s4,16(sp)
ffffffffc020b3b2:	84aa                	mv	s1,a0
ffffffffc020b3b4:	89ae                	mv	s3,a1
ffffffffc020b3b6:	8932                	mv	s2,a2
ffffffffc020b3b8:	fff7841b          	addiw	s0,a5,-1
ffffffffc020b3bc:	2a81                	sext.w	s5,s5
ffffffffc020b3be:	0516f163          	bgeu	a3,a7,ffffffffc020b400 <printnum+0x6a>
ffffffffc020b3c2:	8a42                	mv	s4,a6
ffffffffc020b3c4:	00805863          	blez	s0,ffffffffc020b3d4 <printnum+0x3e>
ffffffffc020b3c8:	347d                	addiw	s0,s0,-1
ffffffffc020b3ca:	864e                	mv	a2,s3
ffffffffc020b3cc:	85ca                	mv	a1,s2
ffffffffc020b3ce:	8552                	mv	a0,s4
ffffffffc020b3d0:	9482                	jalr	s1
ffffffffc020b3d2:	f87d                	bnez	s0,ffffffffc020b3c8 <printnum+0x32>
ffffffffc020b3d4:	1a82                	slli	s5,s5,0x20
ffffffffc020b3d6:	00004797          	auipc	a5,0x4
ffffffffc020b3da:	3ca78793          	addi	a5,a5,970 # ffffffffc020f7a0 <sfs_node_fileops+0x1c0>
ffffffffc020b3de:	020ada93          	srli	s5,s5,0x20
ffffffffc020b3e2:	9abe                	add	s5,s5,a5
ffffffffc020b3e4:	7442                	ld	s0,48(sp)
ffffffffc020b3e6:	000ac503          	lbu	a0,0(s5) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc020b3ea:	70e2                	ld	ra,56(sp)
ffffffffc020b3ec:	6a42                	ld	s4,16(sp)
ffffffffc020b3ee:	6aa2                	ld	s5,8(sp)
ffffffffc020b3f0:	864e                	mv	a2,s3
ffffffffc020b3f2:	85ca                	mv	a1,s2
ffffffffc020b3f4:	69e2                	ld	s3,24(sp)
ffffffffc020b3f6:	7902                	ld	s2,32(sp)
ffffffffc020b3f8:	87a6                	mv	a5,s1
ffffffffc020b3fa:	74a2                	ld	s1,40(sp)
ffffffffc020b3fc:	6121                	addi	sp,sp,64
ffffffffc020b3fe:	8782                	jr	a5
ffffffffc020b400:	0316d6b3          	divu	a3,a3,a7
ffffffffc020b404:	87a2                	mv	a5,s0
ffffffffc020b406:	f91ff0ef          	jal	ra,ffffffffc020b396 <printnum>
ffffffffc020b40a:	b7e9                	j	ffffffffc020b3d4 <printnum+0x3e>

ffffffffc020b40c <sprintputch>:
ffffffffc020b40c:	499c                	lw	a5,16(a1)
ffffffffc020b40e:	6198                	ld	a4,0(a1)
ffffffffc020b410:	6594                	ld	a3,8(a1)
ffffffffc020b412:	2785                	addiw	a5,a5,1
ffffffffc020b414:	c99c                	sw	a5,16(a1)
ffffffffc020b416:	00d77763          	bgeu	a4,a3,ffffffffc020b424 <sprintputch+0x18>
ffffffffc020b41a:	00170793          	addi	a5,a4,1
ffffffffc020b41e:	e19c                	sd	a5,0(a1)
ffffffffc020b420:	00a70023          	sb	a0,0(a4)
ffffffffc020b424:	8082                	ret

ffffffffc020b426 <vprintfmt>:
ffffffffc020b426:	7119                	addi	sp,sp,-128
ffffffffc020b428:	f4a6                	sd	s1,104(sp)
ffffffffc020b42a:	f0ca                	sd	s2,96(sp)
ffffffffc020b42c:	ecce                	sd	s3,88(sp)
ffffffffc020b42e:	e8d2                	sd	s4,80(sp)
ffffffffc020b430:	e4d6                	sd	s5,72(sp)
ffffffffc020b432:	e0da                	sd	s6,64(sp)
ffffffffc020b434:	fc5e                	sd	s7,56(sp)
ffffffffc020b436:	ec6e                	sd	s11,24(sp)
ffffffffc020b438:	fc86                	sd	ra,120(sp)
ffffffffc020b43a:	f8a2                	sd	s0,112(sp)
ffffffffc020b43c:	f862                	sd	s8,48(sp)
ffffffffc020b43e:	f466                	sd	s9,40(sp)
ffffffffc020b440:	f06a                	sd	s10,32(sp)
ffffffffc020b442:	89aa                	mv	s3,a0
ffffffffc020b444:	892e                	mv	s2,a1
ffffffffc020b446:	84b2                	mv	s1,a2
ffffffffc020b448:	8db6                	mv	s11,a3
ffffffffc020b44a:	8aba                	mv	s5,a4
ffffffffc020b44c:	02500a13          	li	s4,37
ffffffffc020b450:	5bfd                	li	s7,-1
ffffffffc020b452:	00004b17          	auipc	s6,0x4
ffffffffc020b456:	37ab0b13          	addi	s6,s6,890 # ffffffffc020f7cc <sfs_node_fileops+0x1ec>
ffffffffc020b45a:	000dc503          	lbu	a0,0(s11) # 2000 <_binary_bin_swap_img_size-0x5d00>
ffffffffc020b45e:	001d8413          	addi	s0,s11,1
ffffffffc020b462:	01450b63          	beq	a0,s4,ffffffffc020b478 <vprintfmt+0x52>
ffffffffc020b466:	c129                	beqz	a0,ffffffffc020b4a8 <vprintfmt+0x82>
ffffffffc020b468:	864a                	mv	a2,s2
ffffffffc020b46a:	85a6                	mv	a1,s1
ffffffffc020b46c:	0405                	addi	s0,s0,1
ffffffffc020b46e:	9982                	jalr	s3
ffffffffc020b470:	fff44503          	lbu	a0,-1(s0)
ffffffffc020b474:	ff4519e3          	bne	a0,s4,ffffffffc020b466 <vprintfmt+0x40>
ffffffffc020b478:	00044583          	lbu	a1,0(s0)
ffffffffc020b47c:	02000813          	li	a6,32
ffffffffc020b480:	4d01                	li	s10,0
ffffffffc020b482:	4301                	li	t1,0
ffffffffc020b484:	5cfd                	li	s9,-1
ffffffffc020b486:	5c7d                	li	s8,-1
ffffffffc020b488:	05500513          	li	a0,85
ffffffffc020b48c:	48a5                	li	a7,9
ffffffffc020b48e:	fdd5861b          	addiw	a2,a1,-35
ffffffffc020b492:	0ff67613          	zext.b	a2,a2
ffffffffc020b496:	00140d93          	addi	s11,s0,1
ffffffffc020b49a:	04c56263          	bltu	a0,a2,ffffffffc020b4de <vprintfmt+0xb8>
ffffffffc020b49e:	060a                	slli	a2,a2,0x2
ffffffffc020b4a0:	965a                	add	a2,a2,s6
ffffffffc020b4a2:	4214                	lw	a3,0(a2)
ffffffffc020b4a4:	96da                	add	a3,a3,s6
ffffffffc020b4a6:	8682                	jr	a3
ffffffffc020b4a8:	70e6                	ld	ra,120(sp)
ffffffffc020b4aa:	7446                	ld	s0,112(sp)
ffffffffc020b4ac:	74a6                	ld	s1,104(sp)
ffffffffc020b4ae:	7906                	ld	s2,96(sp)
ffffffffc020b4b0:	69e6                	ld	s3,88(sp)
ffffffffc020b4b2:	6a46                	ld	s4,80(sp)
ffffffffc020b4b4:	6aa6                	ld	s5,72(sp)
ffffffffc020b4b6:	6b06                	ld	s6,64(sp)
ffffffffc020b4b8:	7be2                	ld	s7,56(sp)
ffffffffc020b4ba:	7c42                	ld	s8,48(sp)
ffffffffc020b4bc:	7ca2                	ld	s9,40(sp)
ffffffffc020b4be:	7d02                	ld	s10,32(sp)
ffffffffc020b4c0:	6de2                	ld	s11,24(sp)
ffffffffc020b4c2:	6109                	addi	sp,sp,128
ffffffffc020b4c4:	8082                	ret
ffffffffc020b4c6:	882e                	mv	a6,a1
ffffffffc020b4c8:	00144583          	lbu	a1,1(s0)
ffffffffc020b4cc:	846e                	mv	s0,s11
ffffffffc020b4ce:	00140d93          	addi	s11,s0,1
ffffffffc020b4d2:	fdd5861b          	addiw	a2,a1,-35
ffffffffc020b4d6:	0ff67613          	zext.b	a2,a2
ffffffffc020b4da:	fcc572e3          	bgeu	a0,a2,ffffffffc020b49e <vprintfmt+0x78>
ffffffffc020b4de:	864a                	mv	a2,s2
ffffffffc020b4e0:	85a6                	mv	a1,s1
ffffffffc020b4e2:	02500513          	li	a0,37
ffffffffc020b4e6:	9982                	jalr	s3
ffffffffc020b4e8:	fff44783          	lbu	a5,-1(s0)
ffffffffc020b4ec:	8da2                	mv	s11,s0
ffffffffc020b4ee:	f74786e3          	beq	a5,s4,ffffffffc020b45a <vprintfmt+0x34>
ffffffffc020b4f2:	ffedc783          	lbu	a5,-2(s11)
ffffffffc020b4f6:	1dfd                	addi	s11,s11,-1
ffffffffc020b4f8:	ff479de3          	bne	a5,s4,ffffffffc020b4f2 <vprintfmt+0xcc>
ffffffffc020b4fc:	bfb9                	j	ffffffffc020b45a <vprintfmt+0x34>
ffffffffc020b4fe:	fd058c9b          	addiw	s9,a1,-48
ffffffffc020b502:	00144583          	lbu	a1,1(s0)
ffffffffc020b506:	846e                	mv	s0,s11
ffffffffc020b508:	fd05869b          	addiw	a3,a1,-48
ffffffffc020b50c:	0005861b          	sext.w	a2,a1
ffffffffc020b510:	02d8e463          	bltu	a7,a3,ffffffffc020b538 <vprintfmt+0x112>
ffffffffc020b514:	00144583          	lbu	a1,1(s0)
ffffffffc020b518:	002c969b          	slliw	a3,s9,0x2
ffffffffc020b51c:	0196873b          	addw	a4,a3,s9
ffffffffc020b520:	0017171b          	slliw	a4,a4,0x1
ffffffffc020b524:	9f31                	addw	a4,a4,a2
ffffffffc020b526:	fd05869b          	addiw	a3,a1,-48
ffffffffc020b52a:	0405                	addi	s0,s0,1
ffffffffc020b52c:	fd070c9b          	addiw	s9,a4,-48
ffffffffc020b530:	0005861b          	sext.w	a2,a1
ffffffffc020b534:	fed8f0e3          	bgeu	a7,a3,ffffffffc020b514 <vprintfmt+0xee>
ffffffffc020b538:	f40c5be3          	bgez	s8,ffffffffc020b48e <vprintfmt+0x68>
ffffffffc020b53c:	8c66                	mv	s8,s9
ffffffffc020b53e:	5cfd                	li	s9,-1
ffffffffc020b540:	b7b9                	j	ffffffffc020b48e <vprintfmt+0x68>
ffffffffc020b542:	fffc4693          	not	a3,s8
ffffffffc020b546:	96fd                	srai	a3,a3,0x3f
ffffffffc020b548:	00dc77b3          	and	a5,s8,a3
ffffffffc020b54c:	00144583          	lbu	a1,1(s0)
ffffffffc020b550:	00078c1b          	sext.w	s8,a5
ffffffffc020b554:	846e                	mv	s0,s11
ffffffffc020b556:	bf25                	j	ffffffffc020b48e <vprintfmt+0x68>
ffffffffc020b558:	000aac83          	lw	s9,0(s5)
ffffffffc020b55c:	00144583          	lbu	a1,1(s0)
ffffffffc020b560:	0aa1                	addi	s5,s5,8
ffffffffc020b562:	846e                	mv	s0,s11
ffffffffc020b564:	bfd1                	j	ffffffffc020b538 <vprintfmt+0x112>
ffffffffc020b566:	4705                	li	a4,1
ffffffffc020b568:	008a8613          	addi	a2,s5,8
ffffffffc020b56c:	00674463          	blt	a4,t1,ffffffffc020b574 <vprintfmt+0x14e>
ffffffffc020b570:	1c030c63          	beqz	t1,ffffffffc020b748 <vprintfmt+0x322>
ffffffffc020b574:	000ab683          	ld	a3,0(s5)
ffffffffc020b578:	4741                	li	a4,16
ffffffffc020b57a:	8ab2                	mv	s5,a2
ffffffffc020b57c:	2801                	sext.w	a6,a6
ffffffffc020b57e:	87e2                	mv	a5,s8
ffffffffc020b580:	8626                	mv	a2,s1
ffffffffc020b582:	85ca                	mv	a1,s2
ffffffffc020b584:	854e                	mv	a0,s3
ffffffffc020b586:	e11ff0ef          	jal	ra,ffffffffc020b396 <printnum>
ffffffffc020b58a:	bdc1                	j	ffffffffc020b45a <vprintfmt+0x34>
ffffffffc020b58c:	000aa503          	lw	a0,0(s5)
ffffffffc020b590:	864a                	mv	a2,s2
ffffffffc020b592:	85a6                	mv	a1,s1
ffffffffc020b594:	0aa1                	addi	s5,s5,8
ffffffffc020b596:	9982                	jalr	s3
ffffffffc020b598:	b5c9                	j	ffffffffc020b45a <vprintfmt+0x34>
ffffffffc020b59a:	4705                	li	a4,1
ffffffffc020b59c:	008a8613          	addi	a2,s5,8
ffffffffc020b5a0:	00674463          	blt	a4,t1,ffffffffc020b5a8 <vprintfmt+0x182>
ffffffffc020b5a4:	18030d63          	beqz	t1,ffffffffc020b73e <vprintfmt+0x318>
ffffffffc020b5a8:	000ab683          	ld	a3,0(s5)
ffffffffc020b5ac:	4729                	li	a4,10
ffffffffc020b5ae:	8ab2                	mv	s5,a2
ffffffffc020b5b0:	b7f1                	j	ffffffffc020b57c <vprintfmt+0x156>
ffffffffc020b5b2:	00144583          	lbu	a1,1(s0)
ffffffffc020b5b6:	4d05                	li	s10,1
ffffffffc020b5b8:	846e                	mv	s0,s11
ffffffffc020b5ba:	bdd1                	j	ffffffffc020b48e <vprintfmt+0x68>
ffffffffc020b5bc:	864a                	mv	a2,s2
ffffffffc020b5be:	85a6                	mv	a1,s1
ffffffffc020b5c0:	02500513          	li	a0,37
ffffffffc020b5c4:	9982                	jalr	s3
ffffffffc020b5c6:	bd51                	j	ffffffffc020b45a <vprintfmt+0x34>
ffffffffc020b5c8:	00144583          	lbu	a1,1(s0)
ffffffffc020b5cc:	2305                	addiw	t1,t1,1
ffffffffc020b5ce:	846e                	mv	s0,s11
ffffffffc020b5d0:	bd7d                	j	ffffffffc020b48e <vprintfmt+0x68>
ffffffffc020b5d2:	4705                	li	a4,1
ffffffffc020b5d4:	008a8613          	addi	a2,s5,8
ffffffffc020b5d8:	00674463          	blt	a4,t1,ffffffffc020b5e0 <vprintfmt+0x1ba>
ffffffffc020b5dc:	14030c63          	beqz	t1,ffffffffc020b734 <vprintfmt+0x30e>
ffffffffc020b5e0:	000ab683          	ld	a3,0(s5)
ffffffffc020b5e4:	4721                	li	a4,8
ffffffffc020b5e6:	8ab2                	mv	s5,a2
ffffffffc020b5e8:	bf51                	j	ffffffffc020b57c <vprintfmt+0x156>
ffffffffc020b5ea:	03000513          	li	a0,48
ffffffffc020b5ee:	864a                	mv	a2,s2
ffffffffc020b5f0:	85a6                	mv	a1,s1
ffffffffc020b5f2:	e042                	sd	a6,0(sp)
ffffffffc020b5f4:	9982                	jalr	s3
ffffffffc020b5f6:	864a                	mv	a2,s2
ffffffffc020b5f8:	85a6                	mv	a1,s1
ffffffffc020b5fa:	07800513          	li	a0,120
ffffffffc020b5fe:	9982                	jalr	s3
ffffffffc020b600:	0aa1                	addi	s5,s5,8
ffffffffc020b602:	6802                	ld	a6,0(sp)
ffffffffc020b604:	4741                	li	a4,16
ffffffffc020b606:	ff8ab683          	ld	a3,-8(s5)
ffffffffc020b60a:	bf8d                	j	ffffffffc020b57c <vprintfmt+0x156>
ffffffffc020b60c:	000ab403          	ld	s0,0(s5)
ffffffffc020b610:	008a8793          	addi	a5,s5,8
ffffffffc020b614:	e03e                	sd	a5,0(sp)
ffffffffc020b616:	14040c63          	beqz	s0,ffffffffc020b76e <vprintfmt+0x348>
ffffffffc020b61a:	11805063          	blez	s8,ffffffffc020b71a <vprintfmt+0x2f4>
ffffffffc020b61e:	02d00693          	li	a3,45
ffffffffc020b622:	0cd81963          	bne	a6,a3,ffffffffc020b6f4 <vprintfmt+0x2ce>
ffffffffc020b626:	00044683          	lbu	a3,0(s0)
ffffffffc020b62a:	0006851b          	sext.w	a0,a3
ffffffffc020b62e:	ce8d                	beqz	a3,ffffffffc020b668 <vprintfmt+0x242>
ffffffffc020b630:	00140a93          	addi	s5,s0,1
ffffffffc020b634:	05e00413          	li	s0,94
ffffffffc020b638:	000cc563          	bltz	s9,ffffffffc020b642 <vprintfmt+0x21c>
ffffffffc020b63c:	3cfd                	addiw	s9,s9,-1
ffffffffc020b63e:	037c8363          	beq	s9,s7,ffffffffc020b664 <vprintfmt+0x23e>
ffffffffc020b642:	864a                	mv	a2,s2
ffffffffc020b644:	85a6                	mv	a1,s1
ffffffffc020b646:	100d0663          	beqz	s10,ffffffffc020b752 <vprintfmt+0x32c>
ffffffffc020b64a:	3681                	addiw	a3,a3,-32
ffffffffc020b64c:	10d47363          	bgeu	s0,a3,ffffffffc020b752 <vprintfmt+0x32c>
ffffffffc020b650:	03f00513          	li	a0,63
ffffffffc020b654:	9982                	jalr	s3
ffffffffc020b656:	000ac683          	lbu	a3,0(s5)
ffffffffc020b65a:	3c7d                	addiw	s8,s8,-1
ffffffffc020b65c:	0a85                	addi	s5,s5,1
ffffffffc020b65e:	0006851b          	sext.w	a0,a3
ffffffffc020b662:	faf9                	bnez	a3,ffffffffc020b638 <vprintfmt+0x212>
ffffffffc020b664:	01805a63          	blez	s8,ffffffffc020b678 <vprintfmt+0x252>
ffffffffc020b668:	3c7d                	addiw	s8,s8,-1
ffffffffc020b66a:	864a                	mv	a2,s2
ffffffffc020b66c:	85a6                	mv	a1,s1
ffffffffc020b66e:	02000513          	li	a0,32
ffffffffc020b672:	9982                	jalr	s3
ffffffffc020b674:	fe0c1ae3          	bnez	s8,ffffffffc020b668 <vprintfmt+0x242>
ffffffffc020b678:	6a82                	ld	s5,0(sp)
ffffffffc020b67a:	b3c5                	j	ffffffffc020b45a <vprintfmt+0x34>
ffffffffc020b67c:	4705                	li	a4,1
ffffffffc020b67e:	008a8d13          	addi	s10,s5,8
ffffffffc020b682:	00674463          	blt	a4,t1,ffffffffc020b68a <vprintfmt+0x264>
ffffffffc020b686:	0a030463          	beqz	t1,ffffffffc020b72e <vprintfmt+0x308>
ffffffffc020b68a:	000ab403          	ld	s0,0(s5)
ffffffffc020b68e:	0c044463          	bltz	s0,ffffffffc020b756 <vprintfmt+0x330>
ffffffffc020b692:	86a2                	mv	a3,s0
ffffffffc020b694:	8aea                	mv	s5,s10
ffffffffc020b696:	4729                	li	a4,10
ffffffffc020b698:	b5d5                	j	ffffffffc020b57c <vprintfmt+0x156>
ffffffffc020b69a:	000aa783          	lw	a5,0(s5)
ffffffffc020b69e:	46e1                	li	a3,24
ffffffffc020b6a0:	0aa1                	addi	s5,s5,8
ffffffffc020b6a2:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020b6a6:	8fb9                	xor	a5,a5,a4
ffffffffc020b6a8:	40e7873b          	subw	a4,a5,a4
ffffffffc020b6ac:	02e6c663          	blt	a3,a4,ffffffffc020b6d8 <vprintfmt+0x2b2>
ffffffffc020b6b0:	00371793          	slli	a5,a4,0x3
ffffffffc020b6b4:	00004697          	auipc	a3,0x4
ffffffffc020b6b8:	44c68693          	addi	a3,a3,1100 # ffffffffc020fb00 <error_string>
ffffffffc020b6bc:	97b6                	add	a5,a5,a3
ffffffffc020b6be:	639c                	ld	a5,0(a5)
ffffffffc020b6c0:	cf81                	beqz	a5,ffffffffc020b6d8 <vprintfmt+0x2b2>
ffffffffc020b6c2:	873e                	mv	a4,a5
ffffffffc020b6c4:	00000697          	auipc	a3,0x0
ffffffffc020b6c8:	18c68693          	addi	a3,a3,396 # ffffffffc020b850 <etext+0x28>
ffffffffc020b6cc:	8626                	mv	a2,s1
ffffffffc020b6ce:	85ca                	mv	a1,s2
ffffffffc020b6d0:	854e                	mv	a0,s3
ffffffffc020b6d2:	0d4000ef          	jal	ra,ffffffffc020b7a6 <printfmt>
ffffffffc020b6d6:	b351                	j	ffffffffc020b45a <vprintfmt+0x34>
ffffffffc020b6d8:	00004697          	auipc	a3,0x4
ffffffffc020b6dc:	0e868693          	addi	a3,a3,232 # ffffffffc020f7c0 <sfs_node_fileops+0x1e0>
ffffffffc020b6e0:	8626                	mv	a2,s1
ffffffffc020b6e2:	85ca                	mv	a1,s2
ffffffffc020b6e4:	854e                	mv	a0,s3
ffffffffc020b6e6:	0c0000ef          	jal	ra,ffffffffc020b7a6 <printfmt>
ffffffffc020b6ea:	bb85                	j	ffffffffc020b45a <vprintfmt+0x34>
ffffffffc020b6ec:	00004417          	auipc	s0,0x4
ffffffffc020b6f0:	0cc40413          	addi	s0,s0,204 # ffffffffc020f7b8 <sfs_node_fileops+0x1d8>
ffffffffc020b6f4:	85e6                	mv	a1,s9
ffffffffc020b6f6:	8522                	mv	a0,s0
ffffffffc020b6f8:	e442                	sd	a6,8(sp)
ffffffffc020b6fa:	babff0ef          	jal	ra,ffffffffc020b2a4 <strnlen>
ffffffffc020b6fe:	40ac0c3b          	subw	s8,s8,a0
ffffffffc020b702:	01805c63          	blez	s8,ffffffffc020b71a <vprintfmt+0x2f4>
ffffffffc020b706:	6822                	ld	a6,8(sp)
ffffffffc020b708:	00080a9b          	sext.w	s5,a6
ffffffffc020b70c:	3c7d                	addiw	s8,s8,-1
ffffffffc020b70e:	864a                	mv	a2,s2
ffffffffc020b710:	85a6                	mv	a1,s1
ffffffffc020b712:	8556                	mv	a0,s5
ffffffffc020b714:	9982                	jalr	s3
ffffffffc020b716:	fe0c1be3          	bnez	s8,ffffffffc020b70c <vprintfmt+0x2e6>
ffffffffc020b71a:	00044683          	lbu	a3,0(s0)
ffffffffc020b71e:	00140a93          	addi	s5,s0,1
ffffffffc020b722:	0006851b          	sext.w	a0,a3
ffffffffc020b726:	daa9                	beqz	a3,ffffffffc020b678 <vprintfmt+0x252>
ffffffffc020b728:	05e00413          	li	s0,94
ffffffffc020b72c:	b731                	j	ffffffffc020b638 <vprintfmt+0x212>
ffffffffc020b72e:	000aa403          	lw	s0,0(s5)
ffffffffc020b732:	bfb1                	j	ffffffffc020b68e <vprintfmt+0x268>
ffffffffc020b734:	000ae683          	lwu	a3,0(s5)
ffffffffc020b738:	4721                	li	a4,8
ffffffffc020b73a:	8ab2                	mv	s5,a2
ffffffffc020b73c:	b581                	j	ffffffffc020b57c <vprintfmt+0x156>
ffffffffc020b73e:	000ae683          	lwu	a3,0(s5)
ffffffffc020b742:	4729                	li	a4,10
ffffffffc020b744:	8ab2                	mv	s5,a2
ffffffffc020b746:	bd1d                	j	ffffffffc020b57c <vprintfmt+0x156>
ffffffffc020b748:	000ae683          	lwu	a3,0(s5)
ffffffffc020b74c:	4741                	li	a4,16
ffffffffc020b74e:	8ab2                	mv	s5,a2
ffffffffc020b750:	b535                	j	ffffffffc020b57c <vprintfmt+0x156>
ffffffffc020b752:	9982                	jalr	s3
ffffffffc020b754:	b709                	j	ffffffffc020b656 <vprintfmt+0x230>
ffffffffc020b756:	864a                	mv	a2,s2
ffffffffc020b758:	85a6                	mv	a1,s1
ffffffffc020b75a:	02d00513          	li	a0,45
ffffffffc020b75e:	e042                	sd	a6,0(sp)
ffffffffc020b760:	9982                	jalr	s3
ffffffffc020b762:	6802                	ld	a6,0(sp)
ffffffffc020b764:	8aea                	mv	s5,s10
ffffffffc020b766:	408006b3          	neg	a3,s0
ffffffffc020b76a:	4729                	li	a4,10
ffffffffc020b76c:	bd01                	j	ffffffffc020b57c <vprintfmt+0x156>
ffffffffc020b76e:	03805163          	blez	s8,ffffffffc020b790 <vprintfmt+0x36a>
ffffffffc020b772:	02d00693          	li	a3,45
ffffffffc020b776:	f6d81be3          	bne	a6,a3,ffffffffc020b6ec <vprintfmt+0x2c6>
ffffffffc020b77a:	00004417          	auipc	s0,0x4
ffffffffc020b77e:	03e40413          	addi	s0,s0,62 # ffffffffc020f7b8 <sfs_node_fileops+0x1d8>
ffffffffc020b782:	02800693          	li	a3,40
ffffffffc020b786:	02800513          	li	a0,40
ffffffffc020b78a:	00140a93          	addi	s5,s0,1
ffffffffc020b78e:	b55d                	j	ffffffffc020b634 <vprintfmt+0x20e>
ffffffffc020b790:	00004a97          	auipc	s5,0x4
ffffffffc020b794:	029a8a93          	addi	s5,s5,41 # ffffffffc020f7b9 <sfs_node_fileops+0x1d9>
ffffffffc020b798:	02800513          	li	a0,40
ffffffffc020b79c:	02800693          	li	a3,40
ffffffffc020b7a0:	05e00413          	li	s0,94
ffffffffc020b7a4:	bd51                	j	ffffffffc020b638 <vprintfmt+0x212>

ffffffffc020b7a6 <printfmt>:
ffffffffc020b7a6:	7139                	addi	sp,sp,-64
ffffffffc020b7a8:	02010313          	addi	t1,sp,32
ffffffffc020b7ac:	f03a                	sd	a4,32(sp)
ffffffffc020b7ae:	871a                	mv	a4,t1
ffffffffc020b7b0:	ec06                	sd	ra,24(sp)
ffffffffc020b7b2:	f43e                	sd	a5,40(sp)
ffffffffc020b7b4:	f842                	sd	a6,48(sp)
ffffffffc020b7b6:	fc46                	sd	a7,56(sp)
ffffffffc020b7b8:	e41a                	sd	t1,8(sp)
ffffffffc020b7ba:	c6dff0ef          	jal	ra,ffffffffc020b426 <vprintfmt>
ffffffffc020b7be:	60e2                	ld	ra,24(sp)
ffffffffc020b7c0:	6121                	addi	sp,sp,64
ffffffffc020b7c2:	8082                	ret

ffffffffc020b7c4 <snprintf>:
ffffffffc020b7c4:	711d                	addi	sp,sp,-96
ffffffffc020b7c6:	15fd                	addi	a1,a1,-1
ffffffffc020b7c8:	03810313          	addi	t1,sp,56
ffffffffc020b7cc:	95aa                	add	a1,a1,a0
ffffffffc020b7ce:	f406                	sd	ra,40(sp)
ffffffffc020b7d0:	fc36                	sd	a3,56(sp)
ffffffffc020b7d2:	e0ba                	sd	a4,64(sp)
ffffffffc020b7d4:	e4be                	sd	a5,72(sp)
ffffffffc020b7d6:	e8c2                	sd	a6,80(sp)
ffffffffc020b7d8:	ecc6                	sd	a7,88(sp)
ffffffffc020b7da:	e01a                	sd	t1,0(sp)
ffffffffc020b7dc:	e42a                	sd	a0,8(sp)
ffffffffc020b7de:	e82e                	sd	a1,16(sp)
ffffffffc020b7e0:	cc02                	sw	zero,24(sp)
ffffffffc020b7e2:	c515                	beqz	a0,ffffffffc020b80e <snprintf+0x4a>
ffffffffc020b7e4:	02a5e563          	bltu	a1,a0,ffffffffc020b80e <snprintf+0x4a>
ffffffffc020b7e8:	75dd                	lui	a1,0xffff7
ffffffffc020b7ea:	86b2                	mv	a3,a2
ffffffffc020b7ec:	00000517          	auipc	a0,0x0
ffffffffc020b7f0:	c2050513          	addi	a0,a0,-992 # ffffffffc020b40c <sprintputch>
ffffffffc020b7f4:	871a                	mv	a4,t1
ffffffffc020b7f6:	0030                	addi	a2,sp,8
ffffffffc020b7f8:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd60181>
ffffffffc020b7fc:	c2bff0ef          	jal	ra,ffffffffc020b426 <vprintfmt>
ffffffffc020b800:	67a2                	ld	a5,8(sp)
ffffffffc020b802:	00078023          	sb	zero,0(a5)
ffffffffc020b806:	4562                	lw	a0,24(sp)
ffffffffc020b808:	70a2                	ld	ra,40(sp)
ffffffffc020b80a:	6125                	addi	sp,sp,96
ffffffffc020b80c:	8082                	ret
ffffffffc020b80e:	5575                	li	a0,-3
ffffffffc020b810:	bfe5                	j	ffffffffc020b808 <snprintf+0x44>

ffffffffc020b812 <hash32>:
ffffffffc020b812:	9e3707b7          	lui	a5,0x9e370
ffffffffc020b816:	2785                	addiw	a5,a5,1
ffffffffc020b818:	02a7853b          	mulw	a0,a5,a0
ffffffffc020b81c:	02000793          	li	a5,32
ffffffffc020b820:	9f8d                	subw	a5,a5,a1
ffffffffc020b822:	00f5553b          	srlw	a0,a0,a5
ffffffffc020b826:	8082                	ret
