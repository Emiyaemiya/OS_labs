
obj/__user_sched_bench.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__warn>:
  800020:	715d                	addi	sp,sp,-80
  800022:	832e                	mv	t1,a1
  800024:	e822                	sd	s0,16(sp)
  800026:	85aa                	mv	a1,a0
  800028:	8432                	mv	s0,a2
  80002a:	fc3e                	sd	a5,56(sp)
  80002c:	861a                	mv	a2,t1
  80002e:	103c                	addi	a5,sp,40
  800030:	00001517          	auipc	a0,0x1
  800034:	ce050513          	addi	a0,a0,-800 # 800d10 <main+0xa4>
  800038:	ec06                	sd	ra,24(sp)
  80003a:	f436                	sd	a3,40(sp)
  80003c:	f83a                	sd	a4,48(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e43e                	sd	a5,8(sp)
  800044:	0ec000ef          	jal	ra,800130 <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0be000ef          	jal	ra,80010a <vcprintf>
  800050:	00001517          	auipc	a0,0x1
  800054:	21850513          	addi	a0,a0,536 # 801268 <error_string+0x150>
  800058:	0d8000ef          	jal	ra,800130 <cprintf>
  80005c:	60e2                	ld	ra,24(sp)
  80005e:	6442                	ld	s0,16(sp)
  800060:	6161                	addi	sp,sp,80
  800062:	8082                	ret

0000000000800064 <syscall>:
  800064:	7175                	addi	sp,sp,-144
  800066:	f8ba                	sd	a4,112(sp)
  800068:	e0ba                	sd	a4,64(sp)
  80006a:	0118                	addi	a4,sp,128
  80006c:	e42a                	sd	a0,8(sp)
  80006e:	ecae                	sd	a1,88(sp)
  800070:	f0b2                	sd	a2,96(sp)
  800072:	f4b6                	sd	a3,104(sp)
  800074:	fcbe                	sd	a5,120(sp)
  800076:	e142                	sd	a6,128(sp)
  800078:	e546                	sd	a7,136(sp)
  80007a:	f42e                	sd	a1,40(sp)
  80007c:	f832                	sd	a2,48(sp)
  80007e:	fc36                	sd	a3,56(sp)
  800080:	f03a                	sd	a4,32(sp)
  800082:	e4be                	sd	a5,72(sp)
  800084:	4522                	lw	a0,8(sp)
  800086:	55a2                	lw	a1,40(sp)
  800088:	5642                	lw	a2,48(sp)
  80008a:	56e2                	lw	a3,56(sp)
  80008c:	4706                	lw	a4,64(sp)
  80008e:	47a6                	lw	a5,72(sp)
  800090:	00000073          	ecall
  800094:	ce2a                	sw	a0,28(sp)
  800096:	4572                	lw	a0,28(sp)
  800098:	6149                	addi	sp,sp,144
  80009a:	8082                	ret

000000000080009c <sys_exit>:
  80009c:	85aa                	mv	a1,a0
  80009e:	4505                	li	a0,1
  8000a0:	b7d1                	j	800064 <syscall>

00000000008000a2 <sys_fork>:
  8000a2:	4509                	li	a0,2
  8000a4:	b7c1                	j	800064 <syscall>

00000000008000a6 <sys_wait>:
  8000a6:	862e                	mv	a2,a1
  8000a8:	85aa                	mv	a1,a0
  8000aa:	450d                	li	a0,3
  8000ac:	bf65                	j	800064 <syscall>

00000000008000ae <sys_yield>:
  8000ae:	4529                	li	a0,10
  8000b0:	bf55                	j	800064 <syscall>

00000000008000b2 <sys_putc>:
  8000b2:	85aa                	mv	a1,a0
  8000b4:	4579                	li	a0,30
  8000b6:	b77d                	j	800064 <syscall>

00000000008000b8 <sys_lab6_set_priority>:
  8000b8:	85aa                	mv	a1,a0
  8000ba:	0ff00513          	li	a0,255
  8000be:	b75d                	j	800064 <syscall>

00000000008000c0 <sys_gettime>:
  8000c0:	4545                	li	a0,17
  8000c2:	b74d                	j	800064 <syscall>

00000000008000c4 <sys_open>:
  8000c4:	862e                	mv	a2,a1
  8000c6:	85aa                	mv	a1,a0
  8000c8:	06400513          	li	a0,100
  8000cc:	bf61                	j	800064 <syscall>

00000000008000ce <sys_close>:
  8000ce:	85aa                	mv	a1,a0
  8000d0:	06500513          	li	a0,101
  8000d4:	bf41                	j	800064 <syscall>

00000000008000d6 <sys_dup>:
  8000d6:	862e                	mv	a2,a1
  8000d8:	85aa                	mv	a1,a0
  8000da:	08200513          	li	a0,130
  8000de:	b759                	j	800064 <syscall>

00000000008000e0 <_start>:
  8000e0:	0d0000ef          	jal	ra,8001b0 <umain>
  8000e4:	a001                	j	8000e4 <_start+0x4>

00000000008000e6 <open>:
  8000e6:	1582                	slli	a1,a1,0x20
  8000e8:	9181                	srli	a1,a1,0x20
  8000ea:	bfe9                	j	8000c4 <sys_open>

00000000008000ec <close>:
  8000ec:	b7cd                	j	8000ce <sys_close>

00000000008000ee <dup2>:
  8000ee:	b7e5                	j	8000d6 <sys_dup>

00000000008000f0 <cputch>:
  8000f0:	1141                	addi	sp,sp,-16
  8000f2:	e022                	sd	s0,0(sp)
  8000f4:	e406                	sd	ra,8(sp)
  8000f6:	842e                	mv	s0,a1
  8000f8:	fbbff0ef          	jal	ra,8000b2 <sys_putc>
  8000fc:	401c                	lw	a5,0(s0)
  8000fe:	60a2                	ld	ra,8(sp)
  800100:	2785                	addiw	a5,a5,1
  800102:	c01c                	sw	a5,0(s0)
  800104:	6402                	ld	s0,0(sp)
  800106:	0141                	addi	sp,sp,16
  800108:	8082                	ret

000000000080010a <vcprintf>:
  80010a:	1101                	addi	sp,sp,-32
  80010c:	872e                	mv	a4,a1
  80010e:	75dd                	lui	a1,0xffff7
  800110:	86aa                	mv	a3,a0
  800112:	0070                	addi	a2,sp,12
  800114:	00000517          	auipc	a0,0x0
  800118:	fdc50513          	addi	a0,a0,-36 # 8000f0 <cputch>
  80011c:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <results+0xffffffffff7f4ac1>
  800120:	ec06                	sd	ra,24(sp)
  800122:	c602                	sw	zero,12(sp)
  800124:	1b6000ef          	jal	ra,8002da <vprintfmt>
  800128:	60e2                	ld	ra,24(sp)
  80012a:	4532                	lw	a0,12(sp)
  80012c:	6105                	addi	sp,sp,32
  80012e:	8082                	ret

0000000000800130 <cprintf>:
  800130:	711d                	addi	sp,sp,-96
  800132:	02810313          	addi	t1,sp,40
  800136:	8e2a                	mv	t3,a0
  800138:	f42e                	sd	a1,40(sp)
  80013a:	75dd                	lui	a1,0xffff7
  80013c:	f832                	sd	a2,48(sp)
  80013e:	fc36                	sd	a3,56(sp)
  800140:	e0ba                	sd	a4,64(sp)
  800142:	00000517          	auipc	a0,0x0
  800146:	fae50513          	addi	a0,a0,-82 # 8000f0 <cputch>
  80014a:	0050                	addi	a2,sp,4
  80014c:	871a                	mv	a4,t1
  80014e:	86f2                	mv	a3,t3
  800150:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <results+0xffffffffff7f4ac1>
  800154:	ec06                	sd	ra,24(sp)
  800156:	e4be                	sd	a5,72(sp)
  800158:	e8c2                	sd	a6,80(sp)
  80015a:	ecc6                	sd	a7,88(sp)
  80015c:	e41a                	sd	t1,8(sp)
  80015e:	c202                	sw	zero,4(sp)
  800160:	17a000ef          	jal	ra,8002da <vprintfmt>
  800164:	60e2                	ld	ra,24(sp)
  800166:	4512                	lw	a0,4(sp)
  800168:	6125                	addi	sp,sp,96
  80016a:	8082                	ret

000000000080016c <initfd>:
  80016c:	1101                	addi	sp,sp,-32
  80016e:	87ae                	mv	a5,a1
  800170:	e426                	sd	s1,8(sp)
  800172:	85b2                	mv	a1,a2
  800174:	84aa                	mv	s1,a0
  800176:	853e                	mv	a0,a5
  800178:	e822                	sd	s0,16(sp)
  80017a:	ec06                	sd	ra,24(sp)
  80017c:	f6bff0ef          	jal	ra,8000e6 <open>
  800180:	842a                	mv	s0,a0
  800182:	00054463          	bltz	a0,80018a <initfd+0x1e>
  800186:	00951863          	bne	a0,s1,800196 <initfd+0x2a>
  80018a:	60e2                	ld	ra,24(sp)
  80018c:	8522                	mv	a0,s0
  80018e:	6442                	ld	s0,16(sp)
  800190:	64a2                	ld	s1,8(sp)
  800192:	6105                	addi	sp,sp,32
  800194:	8082                	ret
  800196:	8526                	mv	a0,s1
  800198:	f55ff0ef          	jal	ra,8000ec <close>
  80019c:	85a6                	mv	a1,s1
  80019e:	8522                	mv	a0,s0
  8001a0:	f4fff0ef          	jal	ra,8000ee <dup2>
  8001a4:	84aa                	mv	s1,a0
  8001a6:	8522                	mv	a0,s0
  8001a8:	f45ff0ef          	jal	ra,8000ec <close>
  8001ac:	8426                	mv	s0,s1
  8001ae:	bff1                	j	80018a <initfd+0x1e>

00000000008001b0 <umain>:
  8001b0:	1101                	addi	sp,sp,-32
  8001b2:	e822                	sd	s0,16(sp)
  8001b4:	e426                	sd	s1,8(sp)
  8001b6:	842a                	mv	s0,a0
  8001b8:	84ae                	mv	s1,a1
  8001ba:	4601                	li	a2,0
  8001bc:	00001597          	auipc	a1,0x1
  8001c0:	b7458593          	addi	a1,a1,-1164 # 800d30 <main+0xc4>
  8001c4:	4501                	li	a0,0
  8001c6:	ec06                	sd	ra,24(sp)
  8001c8:	fa5ff0ef          	jal	ra,80016c <initfd>
  8001cc:	02054263          	bltz	a0,8001f0 <umain+0x40>
  8001d0:	4605                	li	a2,1
  8001d2:	00001597          	auipc	a1,0x1
  8001d6:	b9e58593          	addi	a1,a1,-1122 # 800d70 <main+0x104>
  8001da:	4505                	li	a0,1
  8001dc:	f91ff0ef          	jal	ra,80016c <initfd>
  8001e0:	02054563          	bltz	a0,80020a <umain+0x5a>
  8001e4:	85a6                	mv	a1,s1
  8001e6:	8522                	mv	a0,s0
  8001e8:	285000ef          	jal	ra,800c6c <main>
  8001ec:	038000ef          	jal	ra,800224 <exit>
  8001f0:	86aa                	mv	a3,a0
  8001f2:	00001617          	auipc	a2,0x1
  8001f6:	b4660613          	addi	a2,a2,-1210 # 800d38 <main+0xcc>
  8001fa:	45e9                	li	a1,26
  8001fc:	00001517          	auipc	a0,0x1
  800200:	b5c50513          	addi	a0,a0,-1188 # 800d58 <main+0xec>
  800204:	e1dff0ef          	jal	ra,800020 <__warn>
  800208:	b7e1                	j	8001d0 <umain+0x20>
  80020a:	86aa                	mv	a3,a0
  80020c:	00001617          	auipc	a2,0x1
  800210:	b6c60613          	addi	a2,a2,-1172 # 800d78 <main+0x10c>
  800214:	45f5                	li	a1,29
  800216:	00001517          	auipc	a0,0x1
  80021a:	b4250513          	addi	a0,a0,-1214 # 800d58 <main+0xec>
  80021e:	e03ff0ef          	jal	ra,800020 <__warn>
  800222:	b7c9                	j	8001e4 <umain+0x34>

0000000000800224 <exit>:
  800224:	1141                	addi	sp,sp,-16
  800226:	e406                	sd	ra,8(sp)
  800228:	e75ff0ef          	jal	ra,80009c <sys_exit>
  80022c:	00001517          	auipc	a0,0x1
  800230:	b6c50513          	addi	a0,a0,-1172 # 800d98 <main+0x12c>
  800234:	efdff0ef          	jal	ra,800130 <cprintf>
  800238:	a001                	j	800238 <exit+0x14>

000000000080023a <fork>:
  80023a:	b5a5                	j	8000a2 <sys_fork>

000000000080023c <waitpid>:
  80023c:	b5ad                	j	8000a6 <sys_wait>

000000000080023e <yield>:
  80023e:	bd85                	j	8000ae <sys_yield>

0000000000800240 <gettime_msec>:
  800240:	b541                	j	8000c0 <sys_gettime>

0000000000800242 <lab6_set_priority>:
  800242:	1502                	slli	a0,a0,0x20
  800244:	9101                	srli	a0,a0,0x20
  800246:	bd8d                	j	8000b8 <sys_lab6_set_priority>

0000000000800248 <strnlen>:
  800248:	4781                	li	a5,0
  80024a:	e589                	bnez	a1,800254 <strnlen+0xc>
  80024c:	a811                	j	800260 <strnlen+0x18>
  80024e:	0785                	addi	a5,a5,1
  800250:	00f58863          	beq	a1,a5,800260 <strnlen+0x18>
  800254:	00f50733          	add	a4,a0,a5
  800258:	00074703          	lbu	a4,0(a4)
  80025c:	fb6d                	bnez	a4,80024e <strnlen+0x6>
  80025e:	85be                	mv	a1,a5
  800260:	852e                	mv	a0,a1
  800262:	8082                	ret

0000000000800264 <printnum>:
  800264:	02071893          	slli	a7,a4,0x20
  800268:	7139                	addi	sp,sp,-64
  80026a:	0208d893          	srli	a7,a7,0x20
  80026e:	e456                	sd	s5,8(sp)
  800270:	0316fab3          	remu	s5,a3,a7
  800274:	f822                	sd	s0,48(sp)
  800276:	f426                	sd	s1,40(sp)
  800278:	f04a                	sd	s2,32(sp)
  80027a:	ec4e                	sd	s3,24(sp)
  80027c:	fc06                	sd	ra,56(sp)
  80027e:	e852                	sd	s4,16(sp)
  800280:	84aa                	mv	s1,a0
  800282:	89ae                	mv	s3,a1
  800284:	8932                	mv	s2,a2
  800286:	fff7841b          	addiw	s0,a5,-1
  80028a:	2a81                	sext.w	s5,s5
  80028c:	0516f163          	bgeu	a3,a7,8002ce <printnum+0x6a>
  800290:	8a42                	mv	s4,a6
  800292:	00805863          	blez	s0,8002a2 <printnum+0x3e>
  800296:	347d                	addiw	s0,s0,-1
  800298:	864e                	mv	a2,s3
  80029a:	85ca                	mv	a1,s2
  80029c:	8552                	mv	a0,s4
  80029e:	9482                	jalr	s1
  8002a0:	f87d                	bnez	s0,800296 <printnum+0x32>
  8002a2:	1a82                	slli	s5,s5,0x20
  8002a4:	00001797          	auipc	a5,0x1
  8002a8:	b0c78793          	addi	a5,a5,-1268 # 800db0 <main+0x144>
  8002ac:	020ada93          	srli	s5,s5,0x20
  8002b0:	9abe                	add	s5,s5,a5
  8002b2:	7442                	ld	s0,48(sp)
  8002b4:	000ac503          	lbu	a0,0(s5)
  8002b8:	70e2                	ld	ra,56(sp)
  8002ba:	6a42                	ld	s4,16(sp)
  8002bc:	6aa2                	ld	s5,8(sp)
  8002be:	864e                	mv	a2,s3
  8002c0:	85ca                	mv	a1,s2
  8002c2:	69e2                	ld	s3,24(sp)
  8002c4:	7902                	ld	s2,32(sp)
  8002c6:	87a6                	mv	a5,s1
  8002c8:	74a2                	ld	s1,40(sp)
  8002ca:	6121                	addi	sp,sp,64
  8002cc:	8782                	jr	a5
  8002ce:	0316d6b3          	divu	a3,a3,a7
  8002d2:	87a2                	mv	a5,s0
  8002d4:	f91ff0ef          	jal	ra,800264 <printnum>
  8002d8:	b7e9                	j	8002a2 <printnum+0x3e>

00000000008002da <vprintfmt>:
  8002da:	7119                	addi	sp,sp,-128
  8002dc:	f4a6                	sd	s1,104(sp)
  8002de:	f0ca                	sd	s2,96(sp)
  8002e0:	ecce                	sd	s3,88(sp)
  8002e2:	e8d2                	sd	s4,80(sp)
  8002e4:	e4d6                	sd	s5,72(sp)
  8002e6:	e0da                	sd	s6,64(sp)
  8002e8:	fc5e                	sd	s7,56(sp)
  8002ea:	ec6e                	sd	s11,24(sp)
  8002ec:	fc86                	sd	ra,120(sp)
  8002ee:	f8a2                	sd	s0,112(sp)
  8002f0:	f862                	sd	s8,48(sp)
  8002f2:	f466                	sd	s9,40(sp)
  8002f4:	f06a                	sd	s10,32(sp)
  8002f6:	89aa                	mv	s3,a0
  8002f8:	892e                	mv	s2,a1
  8002fa:	84b2                	mv	s1,a2
  8002fc:	8db6                	mv	s11,a3
  8002fe:	8aba                	mv	s5,a4
  800300:	02500a13          	li	s4,37
  800304:	5bfd                	li	s7,-1
  800306:	00001b17          	auipc	s6,0x1
  80030a:	adeb0b13          	addi	s6,s6,-1314 # 800de4 <main+0x178>
  80030e:	000dc503          	lbu	a0,0(s11)
  800312:	001d8413          	addi	s0,s11,1
  800316:	01450b63          	beq	a0,s4,80032c <vprintfmt+0x52>
  80031a:	c129                	beqz	a0,80035c <vprintfmt+0x82>
  80031c:	864a                	mv	a2,s2
  80031e:	85a6                	mv	a1,s1
  800320:	0405                	addi	s0,s0,1
  800322:	9982                	jalr	s3
  800324:	fff44503          	lbu	a0,-1(s0)
  800328:	ff4519e3          	bne	a0,s4,80031a <vprintfmt+0x40>
  80032c:	00044583          	lbu	a1,0(s0)
  800330:	02000813          	li	a6,32
  800334:	4d01                	li	s10,0
  800336:	4301                	li	t1,0
  800338:	5cfd                	li	s9,-1
  80033a:	5c7d                	li	s8,-1
  80033c:	05500513          	li	a0,85
  800340:	48a5                	li	a7,9
  800342:	fdd5861b          	addiw	a2,a1,-35
  800346:	0ff67613          	zext.b	a2,a2
  80034a:	00140d93          	addi	s11,s0,1
  80034e:	04c56263          	bltu	a0,a2,800392 <vprintfmt+0xb8>
  800352:	060a                	slli	a2,a2,0x2
  800354:	965a                	add	a2,a2,s6
  800356:	4214                	lw	a3,0(a2)
  800358:	96da                	add	a3,a3,s6
  80035a:	8682                	jr	a3
  80035c:	70e6                	ld	ra,120(sp)
  80035e:	7446                	ld	s0,112(sp)
  800360:	74a6                	ld	s1,104(sp)
  800362:	7906                	ld	s2,96(sp)
  800364:	69e6                	ld	s3,88(sp)
  800366:	6a46                	ld	s4,80(sp)
  800368:	6aa6                	ld	s5,72(sp)
  80036a:	6b06                	ld	s6,64(sp)
  80036c:	7be2                	ld	s7,56(sp)
  80036e:	7c42                	ld	s8,48(sp)
  800370:	7ca2                	ld	s9,40(sp)
  800372:	7d02                	ld	s10,32(sp)
  800374:	6de2                	ld	s11,24(sp)
  800376:	6109                	addi	sp,sp,128
  800378:	8082                	ret
  80037a:	882e                	mv	a6,a1
  80037c:	00144583          	lbu	a1,1(s0)
  800380:	846e                	mv	s0,s11
  800382:	00140d93          	addi	s11,s0,1
  800386:	fdd5861b          	addiw	a2,a1,-35
  80038a:	0ff67613          	zext.b	a2,a2
  80038e:	fcc572e3          	bgeu	a0,a2,800352 <vprintfmt+0x78>
  800392:	864a                	mv	a2,s2
  800394:	85a6                	mv	a1,s1
  800396:	02500513          	li	a0,37
  80039a:	9982                	jalr	s3
  80039c:	fff44783          	lbu	a5,-1(s0)
  8003a0:	8da2                	mv	s11,s0
  8003a2:	f74786e3          	beq	a5,s4,80030e <vprintfmt+0x34>
  8003a6:	ffedc783          	lbu	a5,-2(s11)
  8003aa:	1dfd                	addi	s11,s11,-1
  8003ac:	ff479de3          	bne	a5,s4,8003a6 <vprintfmt+0xcc>
  8003b0:	bfb9                	j	80030e <vprintfmt+0x34>
  8003b2:	fd058c9b          	addiw	s9,a1,-48
  8003b6:	00144583          	lbu	a1,1(s0)
  8003ba:	846e                	mv	s0,s11
  8003bc:	fd05869b          	addiw	a3,a1,-48
  8003c0:	0005861b          	sext.w	a2,a1
  8003c4:	02d8e463          	bltu	a7,a3,8003ec <vprintfmt+0x112>
  8003c8:	00144583          	lbu	a1,1(s0)
  8003cc:	002c969b          	slliw	a3,s9,0x2
  8003d0:	0196873b          	addw	a4,a3,s9
  8003d4:	0017171b          	slliw	a4,a4,0x1
  8003d8:	9f31                	addw	a4,a4,a2
  8003da:	fd05869b          	addiw	a3,a1,-48
  8003de:	0405                	addi	s0,s0,1
  8003e0:	fd070c9b          	addiw	s9,a4,-48
  8003e4:	0005861b          	sext.w	a2,a1
  8003e8:	fed8f0e3          	bgeu	a7,a3,8003c8 <vprintfmt+0xee>
  8003ec:	f40c5be3          	bgez	s8,800342 <vprintfmt+0x68>
  8003f0:	8c66                	mv	s8,s9
  8003f2:	5cfd                	li	s9,-1
  8003f4:	b7b9                	j	800342 <vprintfmt+0x68>
  8003f6:	fffc4693          	not	a3,s8
  8003fa:	96fd                	srai	a3,a3,0x3f
  8003fc:	00dc77b3          	and	a5,s8,a3
  800400:	00144583          	lbu	a1,1(s0)
  800404:	00078c1b          	sext.w	s8,a5
  800408:	846e                	mv	s0,s11
  80040a:	bf25                	j	800342 <vprintfmt+0x68>
  80040c:	000aac83          	lw	s9,0(s5)
  800410:	00144583          	lbu	a1,1(s0)
  800414:	0aa1                	addi	s5,s5,8
  800416:	846e                	mv	s0,s11
  800418:	bfd1                	j	8003ec <vprintfmt+0x112>
  80041a:	4705                	li	a4,1
  80041c:	008a8613          	addi	a2,s5,8
  800420:	00674463          	blt	a4,t1,800428 <vprintfmt+0x14e>
  800424:	1c030c63          	beqz	t1,8005fc <vprintfmt+0x322>
  800428:	000ab683          	ld	a3,0(s5)
  80042c:	4741                	li	a4,16
  80042e:	8ab2                	mv	s5,a2
  800430:	2801                	sext.w	a6,a6
  800432:	87e2                	mv	a5,s8
  800434:	8626                	mv	a2,s1
  800436:	85ca                	mv	a1,s2
  800438:	854e                	mv	a0,s3
  80043a:	e2bff0ef          	jal	ra,800264 <printnum>
  80043e:	bdc1                	j	80030e <vprintfmt+0x34>
  800440:	000aa503          	lw	a0,0(s5)
  800444:	864a                	mv	a2,s2
  800446:	85a6                	mv	a1,s1
  800448:	0aa1                	addi	s5,s5,8
  80044a:	9982                	jalr	s3
  80044c:	b5c9                	j	80030e <vprintfmt+0x34>
  80044e:	4705                	li	a4,1
  800450:	008a8613          	addi	a2,s5,8
  800454:	00674463          	blt	a4,t1,80045c <vprintfmt+0x182>
  800458:	18030d63          	beqz	t1,8005f2 <vprintfmt+0x318>
  80045c:	000ab683          	ld	a3,0(s5)
  800460:	4729                	li	a4,10
  800462:	8ab2                	mv	s5,a2
  800464:	b7f1                	j	800430 <vprintfmt+0x156>
  800466:	00144583          	lbu	a1,1(s0)
  80046a:	4d05                	li	s10,1
  80046c:	846e                	mv	s0,s11
  80046e:	bdd1                	j	800342 <vprintfmt+0x68>
  800470:	864a                	mv	a2,s2
  800472:	85a6                	mv	a1,s1
  800474:	02500513          	li	a0,37
  800478:	9982                	jalr	s3
  80047a:	bd51                	j	80030e <vprintfmt+0x34>
  80047c:	00144583          	lbu	a1,1(s0)
  800480:	2305                	addiw	t1,t1,1
  800482:	846e                	mv	s0,s11
  800484:	bd7d                	j	800342 <vprintfmt+0x68>
  800486:	4705                	li	a4,1
  800488:	008a8613          	addi	a2,s5,8
  80048c:	00674463          	blt	a4,t1,800494 <vprintfmt+0x1ba>
  800490:	14030c63          	beqz	t1,8005e8 <vprintfmt+0x30e>
  800494:	000ab683          	ld	a3,0(s5)
  800498:	4721                	li	a4,8
  80049a:	8ab2                	mv	s5,a2
  80049c:	bf51                	j	800430 <vprintfmt+0x156>
  80049e:	03000513          	li	a0,48
  8004a2:	864a                	mv	a2,s2
  8004a4:	85a6                	mv	a1,s1
  8004a6:	e042                	sd	a6,0(sp)
  8004a8:	9982                	jalr	s3
  8004aa:	864a                	mv	a2,s2
  8004ac:	85a6                	mv	a1,s1
  8004ae:	07800513          	li	a0,120
  8004b2:	9982                	jalr	s3
  8004b4:	0aa1                	addi	s5,s5,8
  8004b6:	6802                	ld	a6,0(sp)
  8004b8:	4741                	li	a4,16
  8004ba:	ff8ab683          	ld	a3,-8(s5)
  8004be:	bf8d                	j	800430 <vprintfmt+0x156>
  8004c0:	000ab403          	ld	s0,0(s5)
  8004c4:	008a8793          	addi	a5,s5,8
  8004c8:	e03e                	sd	a5,0(sp)
  8004ca:	14040c63          	beqz	s0,800622 <vprintfmt+0x348>
  8004ce:	11805063          	blez	s8,8005ce <vprintfmt+0x2f4>
  8004d2:	02d00693          	li	a3,45
  8004d6:	0cd81963          	bne	a6,a3,8005a8 <vprintfmt+0x2ce>
  8004da:	00044683          	lbu	a3,0(s0)
  8004de:	0006851b          	sext.w	a0,a3
  8004e2:	ce8d                	beqz	a3,80051c <vprintfmt+0x242>
  8004e4:	00140a93          	addi	s5,s0,1
  8004e8:	05e00413          	li	s0,94
  8004ec:	000cc563          	bltz	s9,8004f6 <vprintfmt+0x21c>
  8004f0:	3cfd                	addiw	s9,s9,-1
  8004f2:	037c8363          	beq	s9,s7,800518 <vprintfmt+0x23e>
  8004f6:	864a                	mv	a2,s2
  8004f8:	85a6                	mv	a1,s1
  8004fa:	100d0663          	beqz	s10,800606 <vprintfmt+0x32c>
  8004fe:	3681                	addiw	a3,a3,-32
  800500:	10d47363          	bgeu	s0,a3,800606 <vprintfmt+0x32c>
  800504:	03f00513          	li	a0,63
  800508:	9982                	jalr	s3
  80050a:	000ac683          	lbu	a3,0(s5)
  80050e:	3c7d                	addiw	s8,s8,-1
  800510:	0a85                	addi	s5,s5,1
  800512:	0006851b          	sext.w	a0,a3
  800516:	faf9                	bnez	a3,8004ec <vprintfmt+0x212>
  800518:	01805a63          	blez	s8,80052c <vprintfmt+0x252>
  80051c:	3c7d                	addiw	s8,s8,-1
  80051e:	864a                	mv	a2,s2
  800520:	85a6                	mv	a1,s1
  800522:	02000513          	li	a0,32
  800526:	9982                	jalr	s3
  800528:	fe0c1ae3          	bnez	s8,80051c <vprintfmt+0x242>
  80052c:	6a82                	ld	s5,0(sp)
  80052e:	b3c5                	j	80030e <vprintfmt+0x34>
  800530:	4705                	li	a4,1
  800532:	008a8d13          	addi	s10,s5,8
  800536:	00674463          	blt	a4,t1,80053e <vprintfmt+0x264>
  80053a:	0a030463          	beqz	t1,8005e2 <vprintfmt+0x308>
  80053e:	000ab403          	ld	s0,0(s5)
  800542:	0c044463          	bltz	s0,80060a <vprintfmt+0x330>
  800546:	86a2                	mv	a3,s0
  800548:	8aea                	mv	s5,s10
  80054a:	4729                	li	a4,10
  80054c:	b5d5                	j	800430 <vprintfmt+0x156>
  80054e:	000aa783          	lw	a5,0(s5)
  800552:	46e1                	li	a3,24
  800554:	0aa1                	addi	s5,s5,8
  800556:	41f7d71b          	sraiw	a4,a5,0x1f
  80055a:	8fb9                	xor	a5,a5,a4
  80055c:	40e7873b          	subw	a4,a5,a4
  800560:	02e6c663          	blt	a3,a4,80058c <vprintfmt+0x2b2>
  800564:	00371793          	slli	a5,a4,0x3
  800568:	00001697          	auipc	a3,0x1
  80056c:	bb068693          	addi	a3,a3,-1104 # 801118 <error_string>
  800570:	97b6                	add	a5,a5,a3
  800572:	639c                	ld	a5,0(a5)
  800574:	cf81                	beqz	a5,80058c <vprintfmt+0x2b2>
  800576:	873e                	mv	a4,a5
  800578:	00001697          	auipc	a3,0x1
  80057c:	86868693          	addi	a3,a3,-1944 # 800de0 <main+0x174>
  800580:	8626                	mv	a2,s1
  800582:	85ca                	mv	a1,s2
  800584:	854e                	mv	a0,s3
  800586:	0d4000ef          	jal	ra,80065a <printfmt>
  80058a:	b351                	j	80030e <vprintfmt+0x34>
  80058c:	00001697          	auipc	a3,0x1
  800590:	84468693          	addi	a3,a3,-1980 # 800dd0 <main+0x164>
  800594:	8626                	mv	a2,s1
  800596:	85ca                	mv	a1,s2
  800598:	854e                	mv	a0,s3
  80059a:	0c0000ef          	jal	ra,80065a <printfmt>
  80059e:	bb85                	j	80030e <vprintfmt+0x34>
  8005a0:	00001417          	auipc	s0,0x1
  8005a4:	82840413          	addi	s0,s0,-2008 # 800dc8 <main+0x15c>
  8005a8:	85e6                	mv	a1,s9
  8005aa:	8522                	mv	a0,s0
  8005ac:	e442                	sd	a6,8(sp)
  8005ae:	c9bff0ef          	jal	ra,800248 <strnlen>
  8005b2:	40ac0c3b          	subw	s8,s8,a0
  8005b6:	01805c63          	blez	s8,8005ce <vprintfmt+0x2f4>
  8005ba:	6822                	ld	a6,8(sp)
  8005bc:	00080a9b          	sext.w	s5,a6
  8005c0:	3c7d                	addiw	s8,s8,-1
  8005c2:	864a                	mv	a2,s2
  8005c4:	85a6                	mv	a1,s1
  8005c6:	8556                	mv	a0,s5
  8005c8:	9982                	jalr	s3
  8005ca:	fe0c1be3          	bnez	s8,8005c0 <vprintfmt+0x2e6>
  8005ce:	00044683          	lbu	a3,0(s0)
  8005d2:	00140a93          	addi	s5,s0,1
  8005d6:	0006851b          	sext.w	a0,a3
  8005da:	daa9                	beqz	a3,80052c <vprintfmt+0x252>
  8005dc:	05e00413          	li	s0,94
  8005e0:	b731                	j	8004ec <vprintfmt+0x212>
  8005e2:	000aa403          	lw	s0,0(s5)
  8005e6:	bfb1                	j	800542 <vprintfmt+0x268>
  8005e8:	000ae683          	lwu	a3,0(s5)
  8005ec:	4721                	li	a4,8
  8005ee:	8ab2                	mv	s5,a2
  8005f0:	b581                	j	800430 <vprintfmt+0x156>
  8005f2:	000ae683          	lwu	a3,0(s5)
  8005f6:	4729                	li	a4,10
  8005f8:	8ab2                	mv	s5,a2
  8005fa:	bd1d                	j	800430 <vprintfmt+0x156>
  8005fc:	000ae683          	lwu	a3,0(s5)
  800600:	4741                	li	a4,16
  800602:	8ab2                	mv	s5,a2
  800604:	b535                	j	800430 <vprintfmt+0x156>
  800606:	9982                	jalr	s3
  800608:	b709                	j	80050a <vprintfmt+0x230>
  80060a:	864a                	mv	a2,s2
  80060c:	85a6                	mv	a1,s1
  80060e:	02d00513          	li	a0,45
  800612:	e042                	sd	a6,0(sp)
  800614:	9982                	jalr	s3
  800616:	6802                	ld	a6,0(sp)
  800618:	8aea                	mv	s5,s10
  80061a:	408006b3          	neg	a3,s0
  80061e:	4729                	li	a4,10
  800620:	bd01                	j	800430 <vprintfmt+0x156>
  800622:	03805163          	blez	s8,800644 <vprintfmt+0x36a>
  800626:	02d00693          	li	a3,45
  80062a:	f6d81be3          	bne	a6,a3,8005a0 <vprintfmt+0x2c6>
  80062e:	00000417          	auipc	s0,0x0
  800632:	79a40413          	addi	s0,s0,1946 # 800dc8 <main+0x15c>
  800636:	02800693          	li	a3,40
  80063a:	02800513          	li	a0,40
  80063e:	00140a93          	addi	s5,s0,1
  800642:	b55d                	j	8004e8 <vprintfmt+0x20e>
  800644:	00000a97          	auipc	s5,0x0
  800648:	785a8a93          	addi	s5,s5,1925 # 800dc9 <main+0x15d>
  80064c:	02800513          	li	a0,40
  800650:	02800693          	li	a3,40
  800654:	05e00413          	li	s0,94
  800658:	bd51                	j	8004ec <vprintfmt+0x212>

000000000080065a <printfmt>:
  80065a:	7139                	addi	sp,sp,-64
  80065c:	02010313          	addi	t1,sp,32
  800660:	f03a                	sd	a4,32(sp)
  800662:	871a                	mv	a4,t1
  800664:	ec06                	sd	ra,24(sp)
  800666:	f43e                	sd	a5,40(sp)
  800668:	f842                	sd	a6,48(sp)
  80066a:	fc46                	sd	a7,56(sp)
  80066c:	e41a                	sd	t1,8(sp)
  80066e:	c6dff0ef          	jal	ra,8002da <vprintfmt>
  800672:	60e2                	ld	ra,24(sp)
  800674:	6121                	addi	sp,sp,64
  800676:	8082                	ret

0000000000800678 <bench_cpu_bound>:
  800678:	715d                	addi	sp,sp,-80
  80067a:	e486                	sd	ra,72(sp)
  80067c:	fc26                	sd	s1,56(sp)
  80067e:	f84a                	sd	s2,48(sp)
  800680:	f44e                	sd	s3,40(sp)
  800682:	f052                	sd	s4,32(sp)
  800684:	ec56                	sd	s5,24(sp)
  800686:	e0a2                	sd	s0,64(sp)
  800688:	bb9ff0ef          	jal	ra,800240 <gettime_msec>
  80068c:	8aaa                	mv	s5,a0
  80068e:	00002917          	auipc	s2,0x2
  800692:	97290913          	addi	s2,s2,-1678 # 802000 <pids>
  800696:	00001517          	auipc	a0,0x1
  80069a:	b4a50513          	addi	a0,a0,-1206 # 8011e0 <error_string+0xc8>
  80069e:	2a81                	sext.w	s5,s5
  8006a0:	89ca                	mv	s3,s2
  8006a2:	a8fff0ef          	jal	ra,800130 <cprintf>
  8006a6:	4481                	li	s1,0
  8006a8:	4a15                	li	s4,5
  8006aa:	b91ff0ef          	jal	ra,80023a <fork>
  8006ae:	00a9a023          	sw	a0,0(s3)
  8006b2:	842a                	mv	s0,a0
  8006b4:	2485                	addiw	s1,s1,1
  8006b6:	c141                	beqz	a0,800736 <bench_cpu_bound+0xbe>
  8006b8:	0991                	addi	s3,s3,4
  8006ba:	ff4498e3          	bne	s1,s4,8006aa <bench_cpu_bound+0x32>
  8006be:	00002497          	auipc	s1,0x2
  8006c2:	95a48493          	addi	s1,s1,-1702 # 802018 <results>
  8006c6:	00002a17          	auipc	s4,0x2
  8006ca:	966a0a13          	addi	s4,s4,-1690 # 80202c <results+0x14>
  8006ce:	8426                	mv	s0,s1
  8006d0:	4981                	li	s3,0
  8006d2:	00092503          	lw	a0,0(s2)
  8006d6:	85a2                	mv	a1,s0
  8006d8:	0411                	addi	s0,s0,4
  8006da:	b63ff0ef          	jal	ra,80023c <waitpid>
  8006de:	ffc42783          	lw	a5,-4(s0)
  8006e2:	0911                	addi	s2,s2,4
  8006e4:	013789bb          	addw	s3,a5,s3
  8006e8:	ff4415e3          	bne	s0,s4,8006d2 <bench_cpu_bound+0x5a>
  8006ec:	85ce                	mv	a1,s3
  8006ee:	00001517          	auipc	a0,0x1
  8006f2:	b1250513          	addi	a0,a0,-1262 # 801200 <error_string+0xe8>
  8006f6:	a3bff0ef          	jal	ra,800130 <cprintf>
  8006fa:	00001517          	auipc	a0,0x1
  8006fe:	b2e50513          	addi	a0,a0,-1234 # 801228 <error_string+0x110>
  800702:	a2fff0ef          	jal	ra,800130 <cprintf>
  800706:	00001417          	auipc	s0,0x1
  80070a:	b3240413          	addi	s0,s0,-1230 # 801238 <error_string+0x120>
  80070e:	408c                	lw	a1,0(s1)
  800710:	8522                	mv	a0,s0
  800712:	0491                	addi	s1,s1,4
  800714:	a1dff0ef          	jal	ra,800130 <cprintf>
  800718:	ff449be3          	bne	s1,s4,80070e <bench_cpu_bound+0x96>
  80071c:	6406                	ld	s0,64(sp)
  80071e:	60a6                	ld	ra,72(sp)
  800720:	74e2                	ld	s1,56(sp)
  800722:	7942                	ld	s2,48(sp)
  800724:	79a2                	ld	s3,40(sp)
  800726:	7a02                	ld	s4,32(sp)
  800728:	6ae2                	ld	s5,24(sp)
  80072a:	00001517          	auipc	a0,0x1
  80072e:	b3e50513          	addi	a0,a0,-1218 # 801268 <error_string+0x150>
  800732:	6161                	addi	sp,sp,80
  800734:	baf5                	j	800130 <cprintf>
  800736:	8526                	mv	a0,s1
  800738:	6905                	lui	s2,0x1
  80073a:	b09ff0ef          	jal	ra,800242 <lab6_set_priority>
  80073e:	bb790913          	addi	s2,s2,-1097 # bb7 <__warn-0x7ff469>
  800742:	0c700493          	li	s1,199
  800746:	afbff0ef          	jal	ra,800240 <gettime_msec>
  80074a:	415507bb          	subw	a5,a0,s5
  80074e:	02f96463          	bltu	s2,a5,800776 <bench_cpu_bound+0xfe>
  800752:	06400713          	li	a4,100
  800756:	c602                	sw	zero,12(sp)
  800758:	47b2                	lw	a5,12(sp)
  80075a:	2781                	sext.w	a5,a5
  80075c:	00f4c963          	blt	s1,a5,80076e <bench_cpu_bound+0xf6>
  800760:	47b2                	lw	a5,12(sp)
  800762:	2785                	addiw	a5,a5,1
  800764:	c63e                	sw	a5,12(sp)
  800766:	47b2                	lw	a5,12(sp)
  800768:	2781                	sext.w	a5,a5
  80076a:	fef4dbe3          	bge	s1,a5,800760 <bench_cpu_bound+0xe8>
  80076e:	377d                	addiw	a4,a4,-1
  800770:	f37d                	bnez	a4,800756 <bench_cpu_bound+0xde>
  800772:	2405                	addiw	s0,s0,1
  800774:	bfc9                	j	800746 <bench_cpu_bound+0xce>
  800776:	8522                	mv	a0,s0
  800778:	aadff0ef          	jal	ra,800224 <exit>

000000000080077c <bench_mixed>:
  80077c:	715d                	addi	sp,sp,-80
  80077e:	e486                	sd	ra,72(sp)
  800780:	fc26                	sd	s1,56(sp)
  800782:	f84a                	sd	s2,48(sp)
  800784:	f44e                	sd	s3,40(sp)
  800786:	f052                	sd	s4,32(sp)
  800788:	ec56                	sd	s5,24(sp)
  80078a:	e0a2                	sd	s0,64(sp)
  80078c:	e85a                	sd	s6,16(sp)
  80078e:	ab3ff0ef          	jal	ra,800240 <gettime_msec>
  800792:	8aaa                	mv	s5,a0
  800794:	00002997          	auipc	s3,0x2
  800798:	86c98993          	addi	s3,s3,-1940 # 802000 <pids>
  80079c:	00001517          	auipc	a0,0x1
  8007a0:	aa450513          	addi	a0,a0,-1372 # 801240 <error_string+0x128>
  8007a4:	2a81                	sext.w	s5,s5
  8007a6:	894e                	mv	s2,s3
  8007a8:	989ff0ef          	jal	ra,800130 <cprintf>
  8007ac:	4481                	li	s1,0
  8007ae:	4a15                	li	s4,5
  8007b0:	a8bff0ef          	jal	ra,80023a <fork>
  8007b4:	00a92023          	sw	a0,0(s2)
  8007b8:	842a                	mv	s0,a0
  8007ba:	c159                	beqz	a0,800840 <bench_mixed+0xc4>
  8007bc:	2485                	addiw	s1,s1,1
  8007be:	0911                	addi	s2,s2,4
  8007c0:	ff4498e3          	bne	s1,s4,8007b0 <bench_mixed+0x34>
  8007c4:	0009a503          	lw	a0,0(s3)
  8007c8:	00002417          	auipc	s0,0x2
  8007cc:	85040413          	addi	s0,s0,-1968 # 802018 <results>
  8007d0:	85a2                	mv	a1,s0
  8007d2:	a6bff0ef          	jal	ra,80023c <waitpid>
  8007d6:	4481                	li	s1,0
  8007d8:	4a05                	li	s4,1
  8007da:	4018                	lw	a4,0(s0)
  8007dc:	4901                	li	s2,0
  8007de:	4a81                	li	s5,0
  8007e0:	4b15                	li	s6,5
  8007e2:	0014879b          	addiw	a5,s1,1
  8007e6:	029a7363          	bgeu	s4,s1,80080c <bench_mixed+0x90>
  8007ea:	0127093b          	addw	s2,a4,s2
  8007ee:	03678263          	beq	a5,s6,800812 <bench_mixed+0x96>
  8007f2:	0049a503          	lw	a0,4(s3)
  8007f6:	0411                	addi	s0,s0,4
  8007f8:	85a2                	mv	a1,s0
  8007fa:	84be                	mv	s1,a5
  8007fc:	a41ff0ef          	jal	ra,80023c <waitpid>
  800800:	0991                	addi	s3,s3,4
  800802:	4018                	lw	a4,0(s0)
  800804:	0014879b          	addiw	a5,s1,1
  800808:	fe9a61e3          	bltu	s4,s1,8007ea <bench_mixed+0x6e>
  80080c:	01570abb          	addw	s5,a4,s5
  800810:	b7cd                	j	8007f2 <bench_mixed+0x76>
  800812:	85d6                	mv	a1,s5
  800814:	00001517          	auipc	a0,0x1
  800818:	a5c50513          	addi	a0,a0,-1444 # 801270 <error_string+0x158>
  80081c:	915ff0ef          	jal	ra,800130 <cprintf>
  800820:	6406                	ld	s0,64(sp)
  800822:	60a6                	ld	ra,72(sp)
  800824:	74e2                	ld	s1,56(sp)
  800826:	79a2                	ld	s3,40(sp)
  800828:	7a02                	ld	s4,32(sp)
  80082a:	6ae2                	ld	s5,24(sp)
  80082c:	6b42                	ld	s6,16(sp)
  80082e:	85ca                	mv	a1,s2
  800830:	7942                	ld	s2,48(sp)
  800832:	00001517          	auipc	a0,0x1
  800836:	a5650513          	addi	a0,a0,-1450 # 801288 <error_string+0x170>
  80083a:	6161                	addi	sp,sp,80
  80083c:	8f5ff06f          	j	800130 <cprintf>
  800840:	450d                	li	a0,3
  800842:	6905                	lui	s2,0x1
  800844:	9ffff0ef          	jal	ra,800242 <lab6_set_priority>
  800848:	bb790913          	addi	s2,s2,-1097 # bb7 <__warn-0x7ff469>
  80084c:	4985                	li	s3,1
  80084e:	0c700a13          	li	s4,199
  800852:	9efff0ef          	jal	ra,800240 <gettime_msec>
  800856:	415507bb          	subw	a5,a0,s5
  80085a:	04f96963          	bltu	s2,a5,8008ac <bench_mixed+0x130>
  80085e:	0299d563          	bge	s3,s1,800888 <bench_mixed+0x10c>
  800862:	4751                	li	a4,20
  800864:	c402                	sw	zero,8(sp)
  800866:	47a2                	lw	a5,8(sp)
  800868:	2781                	sext.w	a5,a5
  80086a:	00fa4963          	blt	s4,a5,80087c <bench_mixed+0x100>
  80086e:	47a2                	lw	a5,8(sp)
  800870:	2785                	addiw	a5,a5,1
  800872:	c43e                	sw	a5,8(sp)
  800874:	47a2                	lw	a5,8(sp)
  800876:	2781                	sext.w	a5,a5
  800878:	fefa5be3          	bge	s4,a5,80086e <bench_mixed+0xf2>
  80087c:	377d                	addiw	a4,a4,-1
  80087e:	f37d                	bnez	a4,800864 <bench_mixed+0xe8>
  800880:	9bfff0ef          	jal	ra,80023e <yield>
  800884:	2405                	addiw	s0,s0,1
  800886:	b7f1                	j	800852 <bench_mixed+0xd6>
  800888:	06400713          	li	a4,100
  80088c:	c602                	sw	zero,12(sp)
  80088e:	47b2                	lw	a5,12(sp)
  800890:	2781                	sext.w	a5,a5
  800892:	00fa4963          	blt	s4,a5,8008a4 <bench_mixed+0x128>
  800896:	47b2                	lw	a5,12(sp)
  800898:	2785                	addiw	a5,a5,1
  80089a:	c63e                	sw	a5,12(sp)
  80089c:	47b2                	lw	a5,12(sp)
  80089e:	2781                	sext.w	a5,a5
  8008a0:	fefa5be3          	bge	s4,a5,800896 <bench_mixed+0x11a>
  8008a4:	377d                	addiw	a4,a4,-1
  8008a6:	f37d                	bnez	a4,80088c <bench_mixed+0x110>
  8008a8:	2405                	addiw	s0,s0,1
  8008aa:	b765                	j	800852 <bench_mixed+0xd6>
  8008ac:	8522                	mv	a0,s0
  8008ae:	977ff0ef          	jal	ra,800224 <exit>

00000000008008b2 <bench_latency>:
  8008b2:	711d                	addi	sp,sp,-96
  8008b4:	e4a6                	sd	s1,72(sp)
  8008b6:	00001517          	auipc	a0,0x1
  8008ba:	9ea50513          	addi	a0,a0,-1558 # 8012a0 <error_string+0x188>
  8008be:	00001497          	auipc	s1,0x1
  8008c2:	74248493          	addi	s1,s1,1858 # 802000 <pids>
  8008c6:	e8a2                	sd	s0,80(sp)
  8008c8:	f456                	sd	s5,40(sp)
  8008ca:	ec86                	sd	ra,88(sp)
  8008cc:	e0ca                	sd	s2,64(sp)
  8008ce:	fc4e                	sd	s3,56(sp)
  8008d0:	f852                	sd	s4,48(sp)
  8008d2:	00001a97          	auipc	s5,0x1
  8008d6:	742a8a93          	addi	s5,s5,1858 # 802014 <pids+0x14>
  8008da:	857ff0ef          	jal	ra,800130 <cprintf>
  8008de:	8426                	mv	s0,s1
  8008e0:	961ff0ef          	jal	ra,800240 <gettime_msec>
  8008e4:	0005091b          	sext.w	s2,a0
  8008e8:	953ff0ef          	jal	ra,80023a <fork>
  8008ec:	c008                	sw	a0,0(s0)
  8008ee:	c541                	beqz	a0,800976 <bench_latency+0xc4>
  8008f0:	0411                	addi	s0,s0,4
  8008f2:	ff5417e3          	bne	s0,s5,8008e0 <bench_latency+0x2e>
  8008f6:	0020                	addi	s0,sp,8
  8008f8:	00001917          	auipc	s2,0x1
  8008fc:	72090913          	addi	s2,s2,1824 # 802018 <results>
  800900:	89a2                	mv	s3,s0
  800902:	4a01                	li	s4,0
  800904:	4088                	lw	a0,0(s1)
  800906:	85ca                	mv	a1,s2
  800908:	0991                	addi	s3,s3,4
  80090a:	933ff0ef          	jal	ra,80023c <waitpid>
  80090e:	00092783          	lw	a5,0(s2)
  800912:	0491                	addi	s1,s1,4
  800914:	0911                	addi	s2,s2,4
  800916:	fef9ae23          	sw	a5,-4(s3)
  80091a:	01478a3b          	addw	s4,a5,s4
  80091e:	ff5493e3          	bne	s1,s5,800904 <bench_latency+0x52>
  800922:	00001517          	auipc	a0,0x1
  800926:	99e50513          	addi	a0,a0,-1634 # 8012c0 <error_string+0x1a8>
  80092a:	807ff0ef          	jal	ra,800130 <cprintf>
  80092e:	01440913          	addi	s2,s0,20
  800932:	00001497          	auipc	s1,0x1
  800936:	90648493          	addi	s1,s1,-1786 # 801238 <error_string+0x120>
  80093a:	400c                	lw	a1,0(s0)
  80093c:	8526                	mv	a0,s1
  80093e:	0411                	addi	s0,s0,4
  800940:	ff0ff0ef          	jal	ra,800130 <cprintf>
  800944:	ff241be3          	bne	s0,s2,80093a <bench_latency+0x88>
  800948:	00001517          	auipc	a0,0x1
  80094c:	92050513          	addi	a0,a0,-1760 # 801268 <error_string+0x150>
  800950:	fe0ff0ef          	jal	ra,800130 <cprintf>
  800954:	4595                	li	a1,5
  800956:	02ba45bb          	divw	a1,s4,a1
  80095a:	6446                	ld	s0,80(sp)
  80095c:	60e6                	ld	ra,88(sp)
  80095e:	64a6                	ld	s1,72(sp)
  800960:	6906                	ld	s2,64(sp)
  800962:	79e2                	ld	s3,56(sp)
  800964:	7a42                	ld	s4,48(sp)
  800966:	7aa2                	ld	s5,40(sp)
  800968:	00001517          	auipc	a0,0x1
  80096c:	97050513          	addi	a0,a0,-1680 # 8012d8 <error_string+0x1c0>
  800970:	6125                	addi	sp,sp,96
  800972:	fbeff06f          	j	800130 <cprintf>
  800976:	8cbff0ef          	jal	ra,800240 <gettime_msec>
  80097a:	4125053b          	subw	a0,a0,s2
  80097e:	8a7ff0ef          	jal	ra,800224 <exit>

0000000000800982 <bench_priority_ratio>:
  800982:	715d                	addi	sp,sp,-80
  800984:	e486                	sd	ra,72(sp)
  800986:	fc26                	sd	s1,56(sp)
  800988:	f84a                	sd	s2,48(sp)
  80098a:	f44e                	sd	s3,40(sp)
  80098c:	f052                	sd	s4,32(sp)
  80098e:	ec56                	sd	s5,24(sp)
  800990:	e0a2                	sd	s0,64(sp)
  800992:	e85a                	sd	s6,16(sp)
  800994:	8adff0ef          	jal	ra,800240 <gettime_msec>
  800998:	8aaa                	mv	s5,a0
  80099a:	00001517          	auipc	a0,0x1
  80099e:	95650513          	addi	a0,a0,-1706 # 8012f0 <error_string+0x1d8>
  8009a2:	f8eff0ef          	jal	ra,800130 <cprintf>
  8009a6:	00001517          	auipc	a0,0x1
  8009aa:	96a50513          	addi	a0,a0,-1686 # 801310 <error_string+0x1f8>
  8009ae:	f82ff0ef          	jal	ra,800130 <cprintf>
  8009b2:	4519                	li	a0,6
  8009b4:	00001497          	auipc	s1,0x1
  8009b8:	64c48493          	addi	s1,s1,1612 # 802000 <pids>
  8009bc:	2a81                	sext.w	s5,s5
  8009be:	885ff0ef          	jal	ra,800242 <lab6_set_priority>
  8009c2:	89a6                	mv	s3,s1
  8009c4:	4901                	li	s2,0
  8009c6:	4a15                	li	s4,5
  8009c8:	873ff0ef          	jal	ra,80023a <fork>
  8009cc:	00a9a023          	sw	a0,0(s3)
  8009d0:	842a                	mv	s0,a0
  8009d2:	2905                	addiw	s2,s2,1
  8009d4:	10050a63          	beqz	a0,800ae8 <bench_priority_ratio+0x166>
  8009d8:	0991                	addi	s3,s3,4
  8009da:	ff4917e3          	bne	s2,s4,8009c8 <bench_priority_ratio+0x46>
  8009de:	00001917          	auipc	s2,0x1
  8009e2:	63a90913          	addi	s2,s2,1594 # 802018 <results>
  8009e6:	00001997          	auipc	s3,0x1
  8009ea:	62e98993          	addi	s3,s3,1582 # 802014 <pids+0x14>
  8009ee:	8a4a                	mv	s4,s2
  8009f0:	844a                	mv	s0,s2
  8009f2:	4088                	lw	a0,0(s1)
  8009f4:	85a2                	mv	a1,s0
  8009f6:	0491                	addi	s1,s1,4
  8009f8:	845ff0ef          	jal	ra,80023c <waitpid>
  8009fc:	0411                	addi	s0,s0,4
  8009fe:	ff349ae3          	bne	s1,s3,8009f2 <bench_priority_ratio+0x70>
  800a02:	00001517          	auipc	a0,0x1
  800a06:	93650513          	addi	a0,a0,-1738 # 801338 <error_string+0x220>
  800a0a:	f26ff0ef          	jal	ra,800130 <cprintf>
  800a0e:	00001997          	auipc	s3,0x1
  800a12:	61e98993          	addi	s3,s3,1566 # 80202c <results+0x14>
  800a16:	00001417          	auipc	s0,0x1
  800a1a:	60240413          	addi	s0,s0,1538 # 802018 <results>
  800a1e:	00001497          	auipc	s1,0x1
  800a22:	81a48493          	addi	s1,s1,-2022 # 801238 <error_string+0x120>
  800a26:	400c                	lw	a1,0(s0)
  800a28:	8526                	mv	a0,s1
  800a2a:	0411                	addi	s0,s0,4
  800a2c:	f04ff0ef          	jal	ra,800130 <cprintf>
  800a30:	ff341be3          	bne	s0,s3,800a26 <bench_priority_ratio+0xa4>
  800a34:	00001517          	auipc	a0,0x1
  800a38:	83450513          	addi	a0,a0,-1996 # 801268 <error_string+0x150>
  800a3c:	ef4ff0ef          	jal	ra,800130 <cprintf>
  800a40:	010a2403          	lw	s0,16(s4)
  800a44:	00001517          	auipc	a0,0x1
  800a48:	90450513          	addi	a0,a0,-1788 # 801348 <error_string+0x230>
  800a4c:	ee4ff0ef          	jal	ra,800130 <cprintf>
  800a50:	06805d63          	blez	s0,800aca <bench_priority_ratio+0x148>
  800a54:	000a2683          	lw	a3,0(s4)
  800a58:	4014579b          	sraiw	a5,s0,0x1
  800a5c:	45a9                	li	a1,10
  800a5e:	0026971b          	slliw	a4,a3,0x2
  800a62:	9f35                	addw	a4,a4,a3
  800a64:	0017171b          	slliw	a4,a4,0x1
  800a68:	9fb9                	addw	a5,a5,a4
  800a6a:	0287c7bb          	divw	a5,a5,s0
  800a6e:	00001517          	auipc	a0,0x1
  800a72:	8f250513          	addi	a0,a0,-1806 # 801360 <error_string+0x248>
  800a76:	40145b13          	srai	s6,s0,0x1
  800a7a:	00001a97          	auipc	s5,0x1
  800a7e:	5aea8a93          	addi	s5,s5,1454 # 802028 <results+0x10>
  800a82:	00001a17          	auipc	s4,0x1
  800a86:	8d6a0a13          	addi	s4,s4,-1834 # 801358 <error_string+0x240>
  800a8a:	44a9                	li	s1,10
  800a8c:	89aa                	mv	s3,a0
  800a8e:	02b7e63b          	remw	a2,a5,a1
  800a92:	02b7c5bb          	divw	a1,a5,a1
  800a96:	e9aff0ef          	jal	ra,800130 <cprintf>
  800a9a:	8552                	mv	a0,s4
  800a9c:	e94ff0ef          	jal	ra,800130 <cprintf>
  800aa0:	00492783          	lw	a5,4(s2)
  800aa4:	854e                	mv	a0,s3
  800aa6:	0911                	addi	s2,s2,4
  800aa8:	0027959b          	slliw	a1,a5,0x2
  800aac:	9dbd                	addw	a1,a1,a5
  800aae:	0015959b          	slliw	a1,a1,0x1
  800ab2:	016585bb          	addw	a1,a1,s6
  800ab6:	0285c5bb          	divw	a1,a1,s0
  800aba:	0295e63b          	remw	a2,a1,s1
  800abe:	0295c5bb          	divw	a1,a1,s1
  800ac2:	e6eff0ef          	jal	ra,800130 <cprintf>
  800ac6:	fd591ae3          	bne	s2,s5,800a9a <bench_priority_ratio+0x118>
  800aca:	6406                	ld	s0,64(sp)
  800acc:	60a6                	ld	ra,72(sp)
  800ace:	74e2                	ld	s1,56(sp)
  800ad0:	7942                	ld	s2,48(sp)
  800ad2:	79a2                	ld	s3,40(sp)
  800ad4:	7a02                	ld	s4,32(sp)
  800ad6:	6ae2                	ld	s5,24(sp)
  800ad8:	6b42                	ld	s6,16(sp)
  800ada:	00000517          	auipc	a0,0x0
  800ade:	78e50513          	addi	a0,a0,1934 # 801268 <error_string+0x150>
  800ae2:	6161                	addi	sp,sp,80
  800ae4:	e4cff06f          	j	800130 <cprintf>
  800ae8:	854a                	mv	a0,s2
  800aea:	6905                	lui	s2,0x1
  800aec:	f56ff0ef          	jal	ra,800242 <lab6_set_priority>
  800af0:	bb790913          	addi	s2,s2,-1097 # bb7 <__warn-0x7ff469>
  800af4:	0c700493          	li	s1,199
  800af8:	f48ff0ef          	jal	ra,800240 <gettime_msec>
  800afc:	415507bb          	subw	a5,a0,s5
  800b00:	02f96463          	bltu	s2,a5,800b28 <bench_priority_ratio+0x1a6>
  800b04:	03200713          	li	a4,50
  800b08:	c602                	sw	zero,12(sp)
  800b0a:	47b2                	lw	a5,12(sp)
  800b0c:	2781                	sext.w	a5,a5
  800b0e:	00f4c963          	blt	s1,a5,800b20 <bench_priority_ratio+0x19e>
  800b12:	47b2                	lw	a5,12(sp)
  800b14:	2785                	addiw	a5,a5,1
  800b16:	c63e                	sw	a5,12(sp)
  800b18:	47b2                	lw	a5,12(sp)
  800b1a:	2781                	sext.w	a5,a5
  800b1c:	fef4dbe3          	bge	s1,a5,800b12 <bench_priority_ratio+0x190>
  800b20:	377d                	addiw	a4,a4,-1
  800b22:	f37d                	bnez	a4,800b08 <bench_priority_ratio+0x186>
  800b24:	2405                	addiw	s0,s0,1
  800b26:	bfc9                	j	800af8 <bench_priority_ratio+0x176>
  800b28:	8522                	mv	a0,s0
  800b2a:	efaff0ef          	jal	ra,800224 <exit>

0000000000800b2e <bench_fairness>:
  800b2e:	715d                	addi	sp,sp,-80
  800b30:	e486                	sd	ra,72(sp)
  800b32:	fc26                	sd	s1,56(sp)
  800b34:	f84a                	sd	s2,48(sp)
  800b36:	f44e                	sd	s3,40(sp)
  800b38:	f052                	sd	s4,32(sp)
  800b3a:	e0a2                	sd	s0,64(sp)
  800b3c:	ec56                	sd	s5,24(sp)
  800b3e:	f02ff0ef          	jal	ra,800240 <gettime_msec>
  800b42:	8a2a                	mv	s4,a0
  800b44:	00001517          	auipc	a0,0x1
  800b48:	82450513          	addi	a0,a0,-2012 # 801368 <error_string+0x250>
  800b4c:	de4ff0ef          	jal	ra,800130 <cprintf>
  800b50:	4519                	li	a0,6
  800b52:	00001917          	auipc	s2,0x1
  800b56:	4ae90913          	addi	s2,s2,1198 # 802000 <pids>
  800b5a:	2a01                	sext.w	s4,s4
  800b5c:	ee6ff0ef          	jal	ra,800242 <lab6_set_priority>
  800b60:	00001997          	auipc	s3,0x1
  800b64:	4b498993          	addi	s3,s3,1204 # 802014 <pids+0x14>
  800b68:	84ca                	mv	s1,s2
  800b6a:	ed0ff0ef          	jal	ra,80023a <fork>
  800b6e:	c088                	sw	a0,0(s1)
  800b70:	842a                	mv	s0,a0
  800b72:	c955                	beqz	a0,800c26 <bench_fairness+0xf8>
  800b74:	0491                	addi	s1,s1,4
  800b76:	ff349ae3          	bne	s1,s3,800b6a <bench_fairness+0x3c>
  800b7a:	00001497          	auipc	s1,0x1
  800b7e:	49e48493          	addi	s1,s1,1182 # 802018 <results>
  800b82:	00001a97          	auipc	s5,0x1
  800b86:	4aaa8a93          	addi	s5,s5,1194 # 80202c <results+0x14>
  800b8a:	8426                	mv	s0,s1
  800b8c:	4a01                	li	s4,0
  800b8e:	4981                	li	s3,0
  800b90:	00092503          	lw	a0,0(s2)
  800b94:	85a2                	mv	a1,s0
  800b96:	0411                	addi	s0,s0,4
  800b98:	ea4ff0ef          	jal	ra,80023c <waitpid>
  800b9c:	ffc42783          	lw	a5,-4(s0)
  800ba0:	0911                	addi	s2,s2,4
  800ba2:	02f78733          	mul	a4,a5,a5
  800ba6:	99be                	add	s3,s3,a5
  800ba8:	9a3a                	add	s4,s4,a4
  800baa:	ff5413e3          	bne	s0,s5,800b90 <bench_fairness+0x62>
  800bae:	00000517          	auipc	a0,0x0
  800bb2:	78a50513          	addi	a0,a0,1930 # 801338 <error_string+0x220>
  800bb6:	d7aff0ef          	jal	ra,800130 <cprintf>
  800bba:	00000417          	auipc	s0,0x0
  800bbe:	67e40413          	addi	s0,s0,1662 # 801238 <error_string+0x120>
  800bc2:	408c                	lw	a1,0(s1)
  800bc4:	8522                	mv	a0,s0
  800bc6:	0491                	addi	s1,s1,4
  800bc8:	d68ff0ef          	jal	ra,800130 <cprintf>
  800bcc:	ff549be3          	bne	s1,s5,800bc2 <bench_fairness+0x94>
  800bd0:	00000517          	auipc	a0,0x0
  800bd4:	69850513          	addi	a0,a0,1688 # 801268 <error_string+0x150>
  800bd8:	d58ff0ef          	jal	ra,800130 <cprintf>
  800bdc:	01404b63          	bgtz	s4,800bf2 <bench_fairness+0xc4>
  800be0:	60a6                	ld	ra,72(sp)
  800be2:	6406                	ld	s0,64(sp)
  800be4:	74e2                	ld	s1,56(sp)
  800be6:	7942                	ld	s2,48(sp)
  800be8:	79a2                	ld	s3,40(sp)
  800bea:	7a02                	ld	s4,32(sp)
  800bec:	6ae2                	ld	s5,24(sp)
  800bee:	6161                	addi	sp,sp,80
  800bf0:	8082                	ret
  800bf2:	033989b3          	mul	s3,s3,s3
  800bf6:	002a1593          	slli	a1,s4,0x2
  800bfa:	9a2e                	add	s4,s4,a1
  800bfc:	3e800593          	li	a1,1000
  800c00:	6406                	ld	s0,64(sp)
  800c02:	60a6                	ld	ra,72(sp)
  800c04:	74e2                	ld	s1,56(sp)
  800c06:	7942                	ld	s2,48(sp)
  800c08:	6ae2                	ld	s5,24(sp)
  800c0a:	00000517          	auipc	a0,0x0
  800c0e:	78650513          	addi	a0,a0,1926 # 801390 <error_string+0x278>
  800c12:	02b985b3          	mul	a1,s3,a1
  800c16:	79a2                	ld	s3,40(sp)
  800c18:	0345c5b3          	div	a1,a1,s4
  800c1c:	7a02                	ld	s4,32(sp)
  800c1e:	6161                	addi	sp,sp,80
  800c20:	2581                	sext.w	a1,a1
  800c22:	d0eff06f          	j	800130 <cprintf>
  800c26:	4515                	li	a0,5
  800c28:	6905                	lui	s2,0x1
  800c2a:	e18ff0ef          	jal	ra,800242 <lab6_set_priority>
  800c2e:	bb790913          	addi	s2,s2,-1097 # bb7 <__warn-0x7ff469>
  800c32:	0c700493          	li	s1,199
  800c36:	e0aff0ef          	jal	ra,800240 <gettime_msec>
  800c3a:	414507bb          	subw	a5,a0,s4
  800c3e:	02f96463          	bltu	s2,a5,800c66 <bench_fairness+0x138>
  800c42:	03200713          	li	a4,50
  800c46:	c602                	sw	zero,12(sp)
  800c48:	47b2                	lw	a5,12(sp)
  800c4a:	2781                	sext.w	a5,a5
  800c4c:	00f4c963          	blt	s1,a5,800c5e <bench_fairness+0x130>
  800c50:	47b2                	lw	a5,12(sp)
  800c52:	2785                	addiw	a5,a5,1
  800c54:	c63e                	sw	a5,12(sp)
  800c56:	47b2                	lw	a5,12(sp)
  800c58:	2781                	sext.w	a5,a5
  800c5a:	fef4dbe3          	bge	s1,a5,800c50 <bench_fairness+0x122>
  800c5e:	377d                	addiw	a4,a4,-1
  800c60:	f37d                	bnez	a4,800c46 <bench_fairness+0x118>
  800c62:	2405                	addiw	s0,s0,1
  800c64:	bfc9                	j	800c36 <bench_fairness+0x108>
  800c66:	8522                	mv	a0,s0
  800c68:	dbcff0ef          	jal	ra,800224 <exit>

0000000000800c6c <main>:
  800c6c:	1141                	addi	sp,sp,-16
  800c6e:	00000517          	auipc	a0,0x0
  800c72:	5fa50513          	addi	a0,a0,1530 # 801268 <error_string+0x150>
  800c76:	e406                	sd	ra,8(sp)
  800c78:	cb8ff0ef          	jal	ra,800130 <cprintf>
  800c7c:	00000517          	auipc	a0,0x0
  800c80:	74c50513          	addi	a0,a0,1868 # 8013c8 <error_string+0x2b0>
  800c84:	cacff0ef          	jal	ra,800130 <cprintf>
  800c88:	00000517          	auipc	a0,0x0
  800c8c:	77850513          	addi	a0,a0,1912 # 801400 <error_string+0x2e8>
  800c90:	ca0ff0ef          	jal	ra,800130 <cprintf>
  800c94:	00000517          	auipc	a0,0x0
  800c98:	73450513          	addi	a0,a0,1844 # 8013c8 <error_string+0x2b0>
  800c9c:	c94ff0ef          	jal	ra,800130 <cprintf>
  800ca0:	9d9ff0ef          	jal	ra,800678 <bench_cpu_bound>
  800ca4:	ad9ff0ef          	jal	ra,80077c <bench_mixed>
  800ca8:	c0bff0ef          	jal	ra,8008b2 <bench_latency>
  800cac:	cd7ff0ef          	jal	ra,800982 <bench_priority_ratio>
  800cb0:	e7fff0ef          	jal	ra,800b2e <bench_fairness>
  800cb4:	00000517          	auipc	a0,0x0
  800cb8:	5b450513          	addi	a0,a0,1460 # 801268 <error_string+0x150>
  800cbc:	c74ff0ef          	jal	ra,800130 <cprintf>
  800cc0:	00000517          	auipc	a0,0x0
  800cc4:	70850513          	addi	a0,a0,1800 # 8013c8 <error_string+0x2b0>
  800cc8:	c68ff0ef          	jal	ra,800130 <cprintf>
  800ccc:	00000517          	auipc	a0,0x0
  800cd0:	75450513          	addi	a0,a0,1876 # 801420 <error_string+0x308>
  800cd4:	c5cff0ef          	jal	ra,800130 <cprintf>
  800cd8:	00000517          	auipc	a0,0x0
  800cdc:	76850513          	addi	a0,a0,1896 # 801440 <error_string+0x328>
  800ce0:	c50ff0ef          	jal	ra,800130 <cprintf>
  800ce4:	60a2                	ld	ra,8(sp)
  800ce6:	4501                	li	a0,0
  800ce8:	0141                	addi	sp,sp,16
  800cea:	8082                	ret
