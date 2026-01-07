
obj/__user_sched_test.out:     file format elf64-littleriscv


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
  800034:	cf050513          	addi	a0,a0,-784 # 800d20 <main+0xd4>
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
  800054:	35850513          	addi	a0,a0,856 # 8013a8 <error_string+0x280>
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
  80011c:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <status+0xffffffffff7f4ac1>
  800120:	ec06                	sd	ra,24(sp)
  800122:	c602                	sw	zero,12(sp)
  800124:	1bc000ef          	jal	ra,8002e0 <vprintfmt>
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
  800150:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <status+0xffffffffff7f4ac1>
  800154:	ec06                	sd	ra,24(sp)
  800156:	e4be                	sd	a5,72(sp)
  800158:	e8c2                	sd	a6,80(sp)
  80015a:	ecc6                	sd	a7,88(sp)
  80015c:	e41a                	sd	t1,8(sp)
  80015e:	c202                	sw	zero,4(sp)
  800160:	180000ef          	jal	ra,8002e0 <vprintfmt>
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
  8001c0:	b8458593          	addi	a1,a1,-1148 # 800d40 <main+0xf4>
  8001c4:	4501                	li	a0,0
  8001c6:	ec06                	sd	ra,24(sp)
  8001c8:	fa5ff0ef          	jal	ra,80016c <initfd>
  8001cc:	02054263          	bltz	a0,8001f0 <umain+0x40>
  8001d0:	4605                	li	a2,1
  8001d2:	00001597          	auipc	a1,0x1
  8001d6:	bae58593          	addi	a1,a1,-1106 # 800d80 <main+0x134>
  8001da:	4505                	li	a0,1
  8001dc:	f91ff0ef          	jal	ra,80016c <initfd>
  8001e0:	02054563          	bltz	a0,80020a <umain+0x5a>
  8001e4:	85a6                	mv	a1,s1
  8001e6:	8522                	mv	a0,s0
  8001e8:	265000ef          	jal	ra,800c4c <main>
  8001ec:	038000ef          	jal	ra,800224 <exit>
  8001f0:	86aa                	mv	a3,a0
  8001f2:	00001617          	auipc	a2,0x1
  8001f6:	b5660613          	addi	a2,a2,-1194 # 800d48 <main+0xfc>
  8001fa:	45e9                	li	a1,26
  8001fc:	00001517          	auipc	a0,0x1
  800200:	b6c50513          	addi	a0,a0,-1172 # 800d68 <main+0x11c>
  800204:	e1dff0ef          	jal	ra,800020 <__warn>
  800208:	b7e1                	j	8001d0 <umain+0x20>
  80020a:	86aa                	mv	a3,a0
  80020c:	00001617          	auipc	a2,0x1
  800210:	b7c60613          	addi	a2,a2,-1156 # 800d88 <main+0x13c>
  800214:	45f5                	li	a1,29
  800216:	00001517          	auipc	a0,0x1
  80021a:	b5250513          	addi	a0,a0,-1198 # 800d68 <main+0x11c>
  80021e:	e03ff0ef          	jal	ra,800020 <__warn>
  800222:	b7c9                	j	8001e4 <umain+0x34>

0000000000800224 <exit>:
  800224:	1141                	addi	sp,sp,-16
  800226:	e406                	sd	ra,8(sp)
  800228:	e75ff0ef          	jal	ra,80009c <sys_exit>
  80022c:	00001517          	auipc	a0,0x1
  800230:	b7c50513          	addi	a0,a0,-1156 # 800da8 <main+0x15c>
  800234:	efdff0ef          	jal	ra,800130 <cprintf>
  800238:	a001                	j	800238 <exit+0x14>

000000000080023a <fork>:
  80023a:	b5a5                	j	8000a2 <sys_fork>

000000000080023c <wait>:
  80023c:	4581                	li	a1,0
  80023e:	4501                	li	a0,0
  800240:	b59d                	j	8000a6 <sys_wait>

0000000000800242 <waitpid>:
  800242:	b595                	j	8000a6 <sys_wait>

0000000000800244 <yield>:
  800244:	b5ad                	j	8000ae <sys_yield>

0000000000800246 <gettime_msec>:
  800246:	bdad                	j	8000c0 <sys_gettime>

0000000000800248 <lab6_set_priority>:
  800248:	1502                	slli	a0,a0,0x20
  80024a:	9101                	srli	a0,a0,0x20
  80024c:	b5b5                	j	8000b8 <sys_lab6_set_priority>

000000000080024e <strnlen>:
  80024e:	4781                	li	a5,0
  800250:	e589                	bnez	a1,80025a <strnlen+0xc>
  800252:	a811                	j	800266 <strnlen+0x18>
  800254:	0785                	addi	a5,a5,1
  800256:	00f58863          	beq	a1,a5,800266 <strnlen+0x18>
  80025a:	00f50733          	add	a4,a0,a5
  80025e:	00074703          	lbu	a4,0(a4)
  800262:	fb6d                	bnez	a4,800254 <strnlen+0x6>
  800264:	85be                	mv	a1,a5
  800266:	852e                	mv	a0,a1
  800268:	8082                	ret

000000000080026a <printnum>:
  80026a:	02071893          	slli	a7,a4,0x20
  80026e:	7139                	addi	sp,sp,-64
  800270:	0208d893          	srli	a7,a7,0x20
  800274:	e456                	sd	s5,8(sp)
  800276:	0316fab3          	remu	s5,a3,a7
  80027a:	f822                	sd	s0,48(sp)
  80027c:	f426                	sd	s1,40(sp)
  80027e:	f04a                	sd	s2,32(sp)
  800280:	ec4e                	sd	s3,24(sp)
  800282:	fc06                	sd	ra,56(sp)
  800284:	e852                	sd	s4,16(sp)
  800286:	84aa                	mv	s1,a0
  800288:	89ae                	mv	s3,a1
  80028a:	8932                	mv	s2,a2
  80028c:	fff7841b          	addiw	s0,a5,-1
  800290:	2a81                	sext.w	s5,s5
  800292:	0516f163          	bgeu	a3,a7,8002d4 <printnum+0x6a>
  800296:	8a42                	mv	s4,a6
  800298:	00805863          	blez	s0,8002a8 <printnum+0x3e>
  80029c:	347d                	addiw	s0,s0,-1
  80029e:	864e                	mv	a2,s3
  8002a0:	85ca                	mv	a1,s2
  8002a2:	8552                	mv	a0,s4
  8002a4:	9482                	jalr	s1
  8002a6:	f87d                	bnez	s0,80029c <printnum+0x32>
  8002a8:	1a82                	slli	s5,s5,0x20
  8002aa:	00001797          	auipc	a5,0x1
  8002ae:	b1678793          	addi	a5,a5,-1258 # 800dc0 <main+0x174>
  8002b2:	020ada93          	srli	s5,s5,0x20
  8002b6:	9abe                	add	s5,s5,a5
  8002b8:	7442                	ld	s0,48(sp)
  8002ba:	000ac503          	lbu	a0,0(s5)
  8002be:	70e2                	ld	ra,56(sp)
  8002c0:	6a42                	ld	s4,16(sp)
  8002c2:	6aa2                	ld	s5,8(sp)
  8002c4:	864e                	mv	a2,s3
  8002c6:	85ca                	mv	a1,s2
  8002c8:	69e2                	ld	s3,24(sp)
  8002ca:	7902                	ld	s2,32(sp)
  8002cc:	87a6                	mv	a5,s1
  8002ce:	74a2                	ld	s1,40(sp)
  8002d0:	6121                	addi	sp,sp,64
  8002d2:	8782                	jr	a5
  8002d4:	0316d6b3          	divu	a3,a3,a7
  8002d8:	87a2                	mv	a5,s0
  8002da:	f91ff0ef          	jal	ra,80026a <printnum>
  8002de:	b7e9                	j	8002a8 <printnum+0x3e>

00000000008002e0 <vprintfmt>:
  8002e0:	7119                	addi	sp,sp,-128
  8002e2:	f4a6                	sd	s1,104(sp)
  8002e4:	f0ca                	sd	s2,96(sp)
  8002e6:	ecce                	sd	s3,88(sp)
  8002e8:	e8d2                	sd	s4,80(sp)
  8002ea:	e4d6                	sd	s5,72(sp)
  8002ec:	e0da                	sd	s6,64(sp)
  8002ee:	fc5e                	sd	s7,56(sp)
  8002f0:	ec6e                	sd	s11,24(sp)
  8002f2:	fc86                	sd	ra,120(sp)
  8002f4:	f8a2                	sd	s0,112(sp)
  8002f6:	f862                	sd	s8,48(sp)
  8002f8:	f466                	sd	s9,40(sp)
  8002fa:	f06a                	sd	s10,32(sp)
  8002fc:	89aa                	mv	s3,a0
  8002fe:	892e                	mv	s2,a1
  800300:	84b2                	mv	s1,a2
  800302:	8db6                	mv	s11,a3
  800304:	8aba                	mv	s5,a4
  800306:	02500a13          	li	s4,37
  80030a:	5bfd                	li	s7,-1
  80030c:	00001b17          	auipc	s6,0x1
  800310:	ae8b0b13          	addi	s6,s6,-1304 # 800df4 <main+0x1a8>
  800314:	000dc503          	lbu	a0,0(s11)
  800318:	001d8413          	addi	s0,s11,1
  80031c:	01450b63          	beq	a0,s4,800332 <vprintfmt+0x52>
  800320:	c129                	beqz	a0,800362 <vprintfmt+0x82>
  800322:	864a                	mv	a2,s2
  800324:	85a6                	mv	a1,s1
  800326:	0405                	addi	s0,s0,1
  800328:	9982                	jalr	s3
  80032a:	fff44503          	lbu	a0,-1(s0)
  80032e:	ff4519e3          	bne	a0,s4,800320 <vprintfmt+0x40>
  800332:	00044583          	lbu	a1,0(s0)
  800336:	02000813          	li	a6,32
  80033a:	4d01                	li	s10,0
  80033c:	4301                	li	t1,0
  80033e:	5cfd                	li	s9,-1
  800340:	5c7d                	li	s8,-1
  800342:	05500513          	li	a0,85
  800346:	48a5                	li	a7,9
  800348:	fdd5861b          	addiw	a2,a1,-35
  80034c:	0ff67613          	zext.b	a2,a2
  800350:	00140d93          	addi	s11,s0,1
  800354:	04c56263          	bltu	a0,a2,800398 <vprintfmt+0xb8>
  800358:	060a                	slli	a2,a2,0x2
  80035a:	965a                	add	a2,a2,s6
  80035c:	4214                	lw	a3,0(a2)
  80035e:	96da                	add	a3,a3,s6
  800360:	8682                	jr	a3
  800362:	70e6                	ld	ra,120(sp)
  800364:	7446                	ld	s0,112(sp)
  800366:	74a6                	ld	s1,104(sp)
  800368:	7906                	ld	s2,96(sp)
  80036a:	69e6                	ld	s3,88(sp)
  80036c:	6a46                	ld	s4,80(sp)
  80036e:	6aa6                	ld	s5,72(sp)
  800370:	6b06                	ld	s6,64(sp)
  800372:	7be2                	ld	s7,56(sp)
  800374:	7c42                	ld	s8,48(sp)
  800376:	7ca2                	ld	s9,40(sp)
  800378:	7d02                	ld	s10,32(sp)
  80037a:	6de2                	ld	s11,24(sp)
  80037c:	6109                	addi	sp,sp,128
  80037e:	8082                	ret
  800380:	882e                	mv	a6,a1
  800382:	00144583          	lbu	a1,1(s0)
  800386:	846e                	mv	s0,s11
  800388:	00140d93          	addi	s11,s0,1
  80038c:	fdd5861b          	addiw	a2,a1,-35
  800390:	0ff67613          	zext.b	a2,a2
  800394:	fcc572e3          	bgeu	a0,a2,800358 <vprintfmt+0x78>
  800398:	864a                	mv	a2,s2
  80039a:	85a6                	mv	a1,s1
  80039c:	02500513          	li	a0,37
  8003a0:	9982                	jalr	s3
  8003a2:	fff44783          	lbu	a5,-1(s0)
  8003a6:	8da2                	mv	s11,s0
  8003a8:	f74786e3          	beq	a5,s4,800314 <vprintfmt+0x34>
  8003ac:	ffedc783          	lbu	a5,-2(s11)
  8003b0:	1dfd                	addi	s11,s11,-1
  8003b2:	ff479de3          	bne	a5,s4,8003ac <vprintfmt+0xcc>
  8003b6:	bfb9                	j	800314 <vprintfmt+0x34>
  8003b8:	fd058c9b          	addiw	s9,a1,-48
  8003bc:	00144583          	lbu	a1,1(s0)
  8003c0:	846e                	mv	s0,s11
  8003c2:	fd05869b          	addiw	a3,a1,-48
  8003c6:	0005861b          	sext.w	a2,a1
  8003ca:	02d8e463          	bltu	a7,a3,8003f2 <vprintfmt+0x112>
  8003ce:	00144583          	lbu	a1,1(s0)
  8003d2:	002c969b          	slliw	a3,s9,0x2
  8003d6:	0196873b          	addw	a4,a3,s9
  8003da:	0017171b          	slliw	a4,a4,0x1
  8003de:	9f31                	addw	a4,a4,a2
  8003e0:	fd05869b          	addiw	a3,a1,-48
  8003e4:	0405                	addi	s0,s0,1
  8003e6:	fd070c9b          	addiw	s9,a4,-48
  8003ea:	0005861b          	sext.w	a2,a1
  8003ee:	fed8f0e3          	bgeu	a7,a3,8003ce <vprintfmt+0xee>
  8003f2:	f40c5be3          	bgez	s8,800348 <vprintfmt+0x68>
  8003f6:	8c66                	mv	s8,s9
  8003f8:	5cfd                	li	s9,-1
  8003fa:	b7b9                	j	800348 <vprintfmt+0x68>
  8003fc:	fffc4693          	not	a3,s8
  800400:	96fd                	srai	a3,a3,0x3f
  800402:	00dc77b3          	and	a5,s8,a3
  800406:	00144583          	lbu	a1,1(s0)
  80040a:	00078c1b          	sext.w	s8,a5
  80040e:	846e                	mv	s0,s11
  800410:	bf25                	j	800348 <vprintfmt+0x68>
  800412:	000aac83          	lw	s9,0(s5)
  800416:	00144583          	lbu	a1,1(s0)
  80041a:	0aa1                	addi	s5,s5,8
  80041c:	846e                	mv	s0,s11
  80041e:	bfd1                	j	8003f2 <vprintfmt+0x112>
  800420:	4705                	li	a4,1
  800422:	008a8613          	addi	a2,s5,8
  800426:	00674463          	blt	a4,t1,80042e <vprintfmt+0x14e>
  80042a:	1c030c63          	beqz	t1,800602 <vprintfmt+0x322>
  80042e:	000ab683          	ld	a3,0(s5)
  800432:	4741                	li	a4,16
  800434:	8ab2                	mv	s5,a2
  800436:	2801                	sext.w	a6,a6
  800438:	87e2                	mv	a5,s8
  80043a:	8626                	mv	a2,s1
  80043c:	85ca                	mv	a1,s2
  80043e:	854e                	mv	a0,s3
  800440:	e2bff0ef          	jal	ra,80026a <printnum>
  800444:	bdc1                	j	800314 <vprintfmt+0x34>
  800446:	000aa503          	lw	a0,0(s5)
  80044a:	864a                	mv	a2,s2
  80044c:	85a6                	mv	a1,s1
  80044e:	0aa1                	addi	s5,s5,8
  800450:	9982                	jalr	s3
  800452:	b5c9                	j	800314 <vprintfmt+0x34>
  800454:	4705                	li	a4,1
  800456:	008a8613          	addi	a2,s5,8
  80045a:	00674463          	blt	a4,t1,800462 <vprintfmt+0x182>
  80045e:	18030d63          	beqz	t1,8005f8 <vprintfmt+0x318>
  800462:	000ab683          	ld	a3,0(s5)
  800466:	4729                	li	a4,10
  800468:	8ab2                	mv	s5,a2
  80046a:	b7f1                	j	800436 <vprintfmt+0x156>
  80046c:	00144583          	lbu	a1,1(s0)
  800470:	4d05                	li	s10,1
  800472:	846e                	mv	s0,s11
  800474:	bdd1                	j	800348 <vprintfmt+0x68>
  800476:	864a                	mv	a2,s2
  800478:	85a6                	mv	a1,s1
  80047a:	02500513          	li	a0,37
  80047e:	9982                	jalr	s3
  800480:	bd51                	j	800314 <vprintfmt+0x34>
  800482:	00144583          	lbu	a1,1(s0)
  800486:	2305                	addiw	t1,t1,1
  800488:	846e                	mv	s0,s11
  80048a:	bd7d                	j	800348 <vprintfmt+0x68>
  80048c:	4705                	li	a4,1
  80048e:	008a8613          	addi	a2,s5,8
  800492:	00674463          	blt	a4,t1,80049a <vprintfmt+0x1ba>
  800496:	14030c63          	beqz	t1,8005ee <vprintfmt+0x30e>
  80049a:	000ab683          	ld	a3,0(s5)
  80049e:	4721                	li	a4,8
  8004a0:	8ab2                	mv	s5,a2
  8004a2:	bf51                	j	800436 <vprintfmt+0x156>
  8004a4:	03000513          	li	a0,48
  8004a8:	864a                	mv	a2,s2
  8004aa:	85a6                	mv	a1,s1
  8004ac:	e042                	sd	a6,0(sp)
  8004ae:	9982                	jalr	s3
  8004b0:	864a                	mv	a2,s2
  8004b2:	85a6                	mv	a1,s1
  8004b4:	07800513          	li	a0,120
  8004b8:	9982                	jalr	s3
  8004ba:	0aa1                	addi	s5,s5,8
  8004bc:	6802                	ld	a6,0(sp)
  8004be:	4741                	li	a4,16
  8004c0:	ff8ab683          	ld	a3,-8(s5)
  8004c4:	bf8d                	j	800436 <vprintfmt+0x156>
  8004c6:	000ab403          	ld	s0,0(s5)
  8004ca:	008a8793          	addi	a5,s5,8
  8004ce:	e03e                	sd	a5,0(sp)
  8004d0:	14040c63          	beqz	s0,800628 <vprintfmt+0x348>
  8004d4:	11805063          	blez	s8,8005d4 <vprintfmt+0x2f4>
  8004d8:	02d00693          	li	a3,45
  8004dc:	0cd81963          	bne	a6,a3,8005ae <vprintfmt+0x2ce>
  8004e0:	00044683          	lbu	a3,0(s0)
  8004e4:	0006851b          	sext.w	a0,a3
  8004e8:	ce8d                	beqz	a3,800522 <vprintfmt+0x242>
  8004ea:	00140a93          	addi	s5,s0,1
  8004ee:	05e00413          	li	s0,94
  8004f2:	000cc563          	bltz	s9,8004fc <vprintfmt+0x21c>
  8004f6:	3cfd                	addiw	s9,s9,-1
  8004f8:	037c8363          	beq	s9,s7,80051e <vprintfmt+0x23e>
  8004fc:	864a                	mv	a2,s2
  8004fe:	85a6                	mv	a1,s1
  800500:	100d0663          	beqz	s10,80060c <vprintfmt+0x32c>
  800504:	3681                	addiw	a3,a3,-32
  800506:	10d47363          	bgeu	s0,a3,80060c <vprintfmt+0x32c>
  80050a:	03f00513          	li	a0,63
  80050e:	9982                	jalr	s3
  800510:	000ac683          	lbu	a3,0(s5)
  800514:	3c7d                	addiw	s8,s8,-1
  800516:	0a85                	addi	s5,s5,1
  800518:	0006851b          	sext.w	a0,a3
  80051c:	faf9                	bnez	a3,8004f2 <vprintfmt+0x212>
  80051e:	01805a63          	blez	s8,800532 <vprintfmt+0x252>
  800522:	3c7d                	addiw	s8,s8,-1
  800524:	864a                	mv	a2,s2
  800526:	85a6                	mv	a1,s1
  800528:	02000513          	li	a0,32
  80052c:	9982                	jalr	s3
  80052e:	fe0c1ae3          	bnez	s8,800522 <vprintfmt+0x242>
  800532:	6a82                	ld	s5,0(sp)
  800534:	b3c5                	j	800314 <vprintfmt+0x34>
  800536:	4705                	li	a4,1
  800538:	008a8d13          	addi	s10,s5,8
  80053c:	00674463          	blt	a4,t1,800544 <vprintfmt+0x264>
  800540:	0a030463          	beqz	t1,8005e8 <vprintfmt+0x308>
  800544:	000ab403          	ld	s0,0(s5)
  800548:	0c044463          	bltz	s0,800610 <vprintfmt+0x330>
  80054c:	86a2                	mv	a3,s0
  80054e:	8aea                	mv	s5,s10
  800550:	4729                	li	a4,10
  800552:	b5d5                	j	800436 <vprintfmt+0x156>
  800554:	000aa783          	lw	a5,0(s5)
  800558:	46e1                	li	a3,24
  80055a:	0aa1                	addi	s5,s5,8
  80055c:	41f7d71b          	sraiw	a4,a5,0x1f
  800560:	8fb9                	xor	a5,a5,a4
  800562:	40e7873b          	subw	a4,a5,a4
  800566:	02e6c663          	blt	a3,a4,800592 <vprintfmt+0x2b2>
  80056a:	00371793          	slli	a5,a4,0x3
  80056e:	00001697          	auipc	a3,0x1
  800572:	bba68693          	addi	a3,a3,-1094 # 801128 <error_string>
  800576:	97b6                	add	a5,a5,a3
  800578:	639c                	ld	a5,0(a5)
  80057a:	cf81                	beqz	a5,800592 <vprintfmt+0x2b2>
  80057c:	873e                	mv	a4,a5
  80057e:	00001697          	auipc	a3,0x1
  800582:	87268693          	addi	a3,a3,-1934 # 800df0 <main+0x1a4>
  800586:	8626                	mv	a2,s1
  800588:	85ca                	mv	a1,s2
  80058a:	854e                	mv	a0,s3
  80058c:	0d4000ef          	jal	ra,800660 <printfmt>
  800590:	b351                	j	800314 <vprintfmt+0x34>
  800592:	00001697          	auipc	a3,0x1
  800596:	84e68693          	addi	a3,a3,-1970 # 800de0 <main+0x194>
  80059a:	8626                	mv	a2,s1
  80059c:	85ca                	mv	a1,s2
  80059e:	854e                	mv	a0,s3
  8005a0:	0c0000ef          	jal	ra,800660 <printfmt>
  8005a4:	bb85                	j	800314 <vprintfmt+0x34>
  8005a6:	00001417          	auipc	s0,0x1
  8005aa:	83240413          	addi	s0,s0,-1998 # 800dd8 <main+0x18c>
  8005ae:	85e6                	mv	a1,s9
  8005b0:	8522                	mv	a0,s0
  8005b2:	e442                	sd	a6,8(sp)
  8005b4:	c9bff0ef          	jal	ra,80024e <strnlen>
  8005b8:	40ac0c3b          	subw	s8,s8,a0
  8005bc:	01805c63          	blez	s8,8005d4 <vprintfmt+0x2f4>
  8005c0:	6822                	ld	a6,8(sp)
  8005c2:	00080a9b          	sext.w	s5,a6
  8005c6:	3c7d                	addiw	s8,s8,-1
  8005c8:	864a                	mv	a2,s2
  8005ca:	85a6                	mv	a1,s1
  8005cc:	8556                	mv	a0,s5
  8005ce:	9982                	jalr	s3
  8005d0:	fe0c1be3          	bnez	s8,8005c6 <vprintfmt+0x2e6>
  8005d4:	00044683          	lbu	a3,0(s0)
  8005d8:	00140a93          	addi	s5,s0,1
  8005dc:	0006851b          	sext.w	a0,a3
  8005e0:	daa9                	beqz	a3,800532 <vprintfmt+0x252>
  8005e2:	05e00413          	li	s0,94
  8005e6:	b731                	j	8004f2 <vprintfmt+0x212>
  8005e8:	000aa403          	lw	s0,0(s5)
  8005ec:	bfb1                	j	800548 <vprintfmt+0x268>
  8005ee:	000ae683          	lwu	a3,0(s5)
  8005f2:	4721                	li	a4,8
  8005f4:	8ab2                	mv	s5,a2
  8005f6:	b581                	j	800436 <vprintfmt+0x156>
  8005f8:	000ae683          	lwu	a3,0(s5)
  8005fc:	4729                	li	a4,10
  8005fe:	8ab2                	mv	s5,a2
  800600:	bd1d                	j	800436 <vprintfmt+0x156>
  800602:	000ae683          	lwu	a3,0(s5)
  800606:	4741                	li	a4,16
  800608:	8ab2                	mv	s5,a2
  80060a:	b535                	j	800436 <vprintfmt+0x156>
  80060c:	9982                	jalr	s3
  80060e:	b709                	j	800510 <vprintfmt+0x230>
  800610:	864a                	mv	a2,s2
  800612:	85a6                	mv	a1,s1
  800614:	02d00513          	li	a0,45
  800618:	e042                	sd	a6,0(sp)
  80061a:	9982                	jalr	s3
  80061c:	6802                	ld	a6,0(sp)
  80061e:	8aea                	mv	s5,s10
  800620:	408006b3          	neg	a3,s0
  800624:	4729                	li	a4,10
  800626:	bd01                	j	800436 <vprintfmt+0x156>
  800628:	03805163          	blez	s8,80064a <vprintfmt+0x36a>
  80062c:	02d00693          	li	a3,45
  800630:	f6d81be3          	bne	a6,a3,8005a6 <vprintfmt+0x2c6>
  800634:	00000417          	auipc	s0,0x0
  800638:	7a440413          	addi	s0,s0,1956 # 800dd8 <main+0x18c>
  80063c:	02800693          	li	a3,40
  800640:	02800513          	li	a0,40
  800644:	00140a93          	addi	s5,s0,1
  800648:	b55d                	j	8004ee <vprintfmt+0x20e>
  80064a:	00000a97          	auipc	s5,0x0
  80064e:	78fa8a93          	addi	s5,s5,1935 # 800dd9 <main+0x18d>
  800652:	02800513          	li	a0,40
  800656:	02800693          	li	a3,40
  80065a:	05e00413          	li	s0,94
  80065e:	bd51                	j	8004f2 <vprintfmt+0x212>

0000000000800660 <printfmt>:
  800660:	7139                	addi	sp,sp,-64
  800662:	02010313          	addi	t1,sp,32
  800666:	f03a                	sd	a4,32(sp)
  800668:	871a                	mv	a4,t1
  80066a:	ec06                	sd	ra,24(sp)
  80066c:	f43e                	sd	a5,40(sp)
  80066e:	f842                	sd	a6,48(sp)
  800670:	fc46                	sd	a7,56(sp)
  800672:	e41a                	sd	t1,8(sp)
  800674:	c6dff0ef          	jal	ra,8002e0 <vprintfmt>
  800678:	60e2                	ld	ra,24(sp)
  80067a:	6121                	addi	sp,sp,64
  80067c:	8082                	ret

000000000080067e <test_short_long_mix>:
  80067e:	715d                	addi	sp,sp,-80
  800680:	e486                	sd	ra,72(sp)
  800682:	e0a2                	sd	s0,64(sp)
  800684:	fc26                	sd	s1,56(sp)
  800686:	f84a                	sd	s2,48(sp)
  800688:	f44e                	sd	s3,40(sp)
  80068a:	f052                	sd	s4,32(sp)
  80068c:	bbbff0ef          	jal	ra,800246 <gettime_msec>
  800690:	8a2a                	mv	s4,a0
  800692:	00001517          	auipc	a0,0x1
  800696:	b5e50513          	addi	a0,a0,-1186 # 8011f0 <error_string+0xc8>
  80069a:	a97ff0ef          	jal	ra,800130 <cprintf>
  80069e:	00001517          	auipc	a0,0x1
  8006a2:	b8a50513          	addi	a0,a0,-1142 # 801228 <error_string+0x100>
  8006a6:	a8bff0ef          	jal	ra,800130 <cprintf>
  8006aa:	00001797          	auipc	a5,0x1
  8006ae:	11e7b783          	ld	a5,286(a5) # 8017c8 <error_string+0x6a0>
  8006b2:	00002497          	auipc	s1,0x2
  8006b6:	94e48493          	addi	s1,s1,-1714 # 802000 <pids>
  8006ba:	e43e                	sd	a5,8(sp)
  8006bc:	e83e                	sd	a5,16(sp)
  8006be:	1f400793          	li	a5,500
  8006c2:	2a01                	sext.w	s4,s4
  8006c4:	cc3e                	sw	a5,24(sp)
  8006c6:	8426                	mv	s0,s1
  8006c8:	4901                	li	s2,0
  8006ca:	4995                	li	s3,5
  8006cc:	b6fff0ef          	jal	ra,80023a <fork>
  8006d0:	c008                	sw	a0,0(s0)
  8006d2:	c535                	beqz	a0,80073e <test_short_long_mix+0xc0>
  8006d4:	06054063          	bltz	a0,800734 <test_short_long_mix+0xb6>
  8006d8:	2905                	addiw	s2,s2,1
  8006da:	0411                	addi	s0,s0,4
  8006dc:	ff3918e3          	bne	s2,s3,8006cc <test_short_long_mix+0x4e>
  8006e0:	00002417          	auipc	s0,0x2
  8006e4:	93840413          	addi	s0,s0,-1736 # 802018 <status>
  8006e8:	00002997          	auipc	s3,0x2
  8006ec:	94498993          	addi	s3,s3,-1724 # 80202c <status+0x14>
  8006f0:	4901                	li	s2,0
  8006f2:	4088                	lw	a0,0(s1)
  8006f4:	85a2                	mv	a1,s0
  8006f6:	0411                	addi	s0,s0,4
  8006f8:	b4bff0ef          	jal	ra,800242 <waitpid>
  8006fc:	ffc42783          	lw	a5,-4(s0)
  800700:	0491                	addi	s1,s1,4
  800702:	0127893b          	addw	s2,a5,s2
  800706:	fe8996e3          	bne	s3,s0,8006f2 <test_short_long_mix+0x74>
  80070a:	4595                	li	a1,5
  80070c:	02b945bb          	divw	a1,s2,a1
  800710:	00001517          	auipc	a0,0x1
  800714:	b7850513          	addi	a0,a0,-1160 # 801288 <error_string+0x160>
  800718:	a19ff0ef          	jal	ra,800130 <cprintf>
  80071c:	00001517          	auipc	a0,0x1
  800720:	b9450513          	addi	a0,a0,-1132 # 8012b0 <error_string+0x188>
  800724:	6406                	ld	s0,64(sp)
  800726:	60a6                	ld	ra,72(sp)
  800728:	74e2                	ld	s1,56(sp)
  80072a:	7942                	ld	s2,48(sp)
  80072c:	79a2                	ld	s3,40(sp)
  80072e:	7a02                	ld	s4,32(sp)
  800730:	6161                	addi	sp,sp,80
  800732:	bafd                	j	800130 <cprintf>
  800734:	00001517          	auipc	a0,0x1
  800738:	b4450513          	addi	a0,a0,-1212 # 801278 <error_string+0x150>
  80073c:	b7e5                	j	800724 <test_short_long_mix+0xa6>
  80073e:	00291793          	slli	a5,s2,0x2
  800742:	1018                	addi	a4,sp,32
  800744:	97ba                	add	a5,a5,a4
  800746:	fe87a403          	lw	s0,-24(a5)
  80074a:	00805e63          	blez	s0,800766 <test_short_long_mix+0xe8>
  80074e:	86a2                	mv	a3,s0
  800750:	0c800713          	li	a4,200
  800754:	4792                	lw	a5,4(sp)
  800756:	377d                	addiw	a4,a4,-1
  800758:	2781                	sext.w	a5,a5
  80075a:	0017b793          	seqz	a5,a5
  80075e:	c23e                	sw	a5,4(sp)
  800760:	fb75                	bnez	a4,800754 <test_short_long_mix+0xd6>
  800762:	36fd                	addiw	a3,a3,-1
  800764:	f6f5                	bnez	a3,800750 <test_short_long_mix+0xd2>
  800766:	ae1ff0ef          	jal	ra,800246 <gettime_msec>
  80076a:	41450a3b          	subw	s4,a0,s4
  80076e:	86d2                	mv	a3,s4
  800770:	8622                	mv	a2,s0
  800772:	85ca                	mv	a1,s2
  800774:	00001517          	auipc	a0,0x1
  800778:	adc50513          	addi	a0,a0,-1316 # 801250 <error_string+0x128>
  80077c:	9b5ff0ef          	jal	ra,800130 <cprintf>
  800780:	8552                	mv	a0,s4
  800782:	aa3ff0ef          	jal	ra,800224 <exit>

0000000000800786 <test_fairness>:
  800786:	7139                	addi	sp,sp,-64
  800788:	00001517          	auipc	a0,0x1
  80078c:	b5850513          	addi	a0,a0,-1192 # 8012e0 <error_string+0x1b8>
  800790:	fc06                	sd	ra,56(sp)
  800792:	f822                	sd	s0,48(sp)
  800794:	f426                	sd	s1,40(sp)
  800796:	f04a                	sd	s2,32(sp)
  800798:	ec4e                	sd	s3,24(sp)
  80079a:	e852                	sd	s4,16(sp)
  80079c:	995ff0ef          	jal	ra,800130 <cprintf>
  8007a0:	00001517          	auipc	a0,0x1
  8007a4:	b7050513          	addi	a0,a0,-1168 # 801310 <error_string+0x1e8>
  8007a8:	989ff0ef          	jal	ra,800130 <cprintf>
  8007ac:	4519                	li	a0,6
  8007ae:	00002417          	auipc	s0,0x2
  8007b2:	85240413          	addi	s0,s0,-1966 # 802000 <pids>
  8007b6:	a93ff0ef          	jal	ra,800248 <lab6_set_priority>
  8007ba:	84a2                	mv	s1,s0
  8007bc:	4901                	li	s2,0
  8007be:	4995                	li	s3,5
  8007c0:	a7bff0ef          	jal	ra,80023a <fork>
  8007c4:	c088                	sw	a0,0(s1)
  8007c6:	cd4d                	beqz	a0,800880 <test_fairness+0xfa>
  8007c8:	0a054763          	bltz	a0,800876 <test_fairness+0xf0>
  8007cc:	2905                	addiw	s2,s2,1
  8007ce:	0491                	addi	s1,s1,4
  8007d0:	ff3918e3          	bne	s2,s3,8007c0 <test_fairness+0x3a>
  8007d4:	00002497          	auipc	s1,0x2
  8007d8:	84448493          	addi	s1,s1,-1980 # 802018 <status>
  8007dc:	00002997          	auipc	s3,0x2
  8007e0:	83898993          	addi	s3,s3,-1992 # 802014 <pids+0x14>
  8007e4:	8a26                	mv	s4,s1
  8007e6:	8926                	mv	s2,s1
  8007e8:	4008                	lw	a0,0(s0)
  8007ea:	85ca                	mv	a1,s2
  8007ec:	0411                	addi	s0,s0,4
  8007ee:	a55ff0ef          	jal	ra,800242 <waitpid>
  8007f2:	0911                	addi	s2,s2,4
  8007f4:	fe899ae3          	bne	s3,s0,8007e8 <test_fairness+0x62>
  8007f8:	000a2403          	lw	s0,0(s4)
  8007fc:	00002697          	auipc	a3,0x2
  800800:	82c68693          	addi	a3,a3,-2004 # 802028 <status+0x10>
  800804:	8922                	mv	s2,s0
  800806:	40dc                	lw	a5,4(s1)
  800808:	873e                	mv	a4,a5
  80080a:	0087d363          	bge	a5,s0,800810 <test_fairness+0x8a>
  80080e:	8722                	mv	a4,s0
  800810:	0007041b          	sext.w	s0,a4
  800814:	873e                	mv	a4,a5
  800816:	00f95363          	bge	s2,a5,80081c <test_fairness+0x96>
  80081a:	874a                	mv	a4,s2
  80081c:	0491                	addi	s1,s1,4
  80081e:	0007091b          	sext.w	s2,a4
  800822:	fed492e3          	bne	s1,a3,800806 <test_fairness+0x80>
  800826:	864a                	mv	a2,s2
  800828:	85a2                	mv	a1,s0
  80082a:	00001517          	auipc	a0,0x1
  80082e:	b3650513          	addi	a0,a0,-1226 # 801360 <error_string+0x238>
  800832:	8ffff0ef          	jal	ra,800130 <cprintf>
  800836:	01204f63          	bgtz	s2,800854 <test_fairness+0xce>
  80083a:	00001517          	auipc	a0,0x1
  80083e:	b7650513          	addi	a0,a0,-1162 # 8013b0 <error_string+0x288>
  800842:	7442                	ld	s0,48(sp)
  800844:	70e2                	ld	ra,56(sp)
  800846:	74a2                	ld	s1,40(sp)
  800848:	7902                	ld	s2,32(sp)
  80084a:	69e2                	ld	s3,24(sp)
  80084c:	6a42                	ld	s4,16(sp)
  80084e:	6121                	addi	sp,sp,64
  800850:	8e1ff06f          	j	800130 <cprintf>
  800854:	06400593          	li	a1,100
  800858:	0285843b          	mulw	s0,a1,s0
  80085c:	00001517          	auipc	a0,0x1
  800860:	b2450513          	addi	a0,a0,-1244 # 801380 <error_string+0x258>
  800864:	0324443b          	divw	s0,s0,s2
  800868:	02b4663b          	remw	a2,s0,a1
  80086c:	02b445bb          	divw	a1,s0,a1
  800870:	8c1ff0ef          	jal	ra,800130 <cprintf>
  800874:	b7d9                	j	80083a <test_fairness+0xb4>
  800876:	00001517          	auipc	a0,0x1
  80087a:	a0250513          	addi	a0,a0,-1534 # 801278 <error_string+0x150>
  80087e:	b7d1                	j	800842 <test_fairness+0xbc>
  800880:	4515                	li	a0,5
  800882:	9c7ff0ef          	jal	ra,800248 <lab6_set_priority>
  800886:	9c1ff0ef          	jal	ra,800246 <gettime_msec>
  80088a:	0005049b          	sext.w	s1,a0
  80088e:	4401                	li	s0,0
  800890:	7d000a13          	li	s4,2000
  800894:	7d000993          	li	s3,2000
  800898:	0c800713          	li	a4,200
  80089c:	47b2                	lw	a5,12(sp)
  80089e:	377d                	addiw	a4,a4,-1
  8008a0:	2781                	sext.w	a5,a5
  8008a2:	0017b793          	seqz	a5,a5
  8008a6:	c63e                	sw	a5,12(sp)
  8008a8:	fb75                	bnez	a4,80089c <test_fairness+0x116>
  8008aa:	2405                	addiw	s0,s0,1
  8008ac:	034477bb          	remuw	a5,s0,s4
  8008b0:	f7e5                	bnez	a5,800898 <test_fairness+0x112>
  8008b2:	995ff0ef          	jal	ra,800246 <gettime_msec>
  8008b6:	409507bb          	subw	a5,a0,s1
  8008ba:	fcf9ffe3          	bgeu	s3,a5,800898 <test_fairness+0x112>
  8008be:	8622                	mv	a2,s0
  8008c0:	85ca                	mv	a1,s2
  8008c2:	00001517          	auipc	a0,0x1
  8008c6:	a8650513          	addi	a0,a0,-1402 # 801348 <error_string+0x220>
  8008ca:	867ff0ef          	jal	ra,800130 <cprintf>
  8008ce:	8522                	mv	a0,s0
  8008d0:	955ff0ef          	jal	ra,800224 <exit>

00000000008008d4 <test_priority>:
  8008d4:	715d                	addi	sp,sp,-80
  8008d6:	00001517          	auipc	a0,0x1
  8008da:	afa50513          	addi	a0,a0,-1286 # 8013d0 <error_string+0x2a8>
  8008de:	e486                	sd	ra,72(sp)
  8008e0:	e0a2                	sd	s0,64(sp)
  8008e2:	fc26                	sd	s1,56(sp)
  8008e4:	f84a                	sd	s2,48(sp)
  8008e6:	f44e                	sd	s3,40(sp)
  8008e8:	f052                	sd	s4,32(sp)
  8008ea:	ec56                	sd	s5,24(sp)
  8008ec:	845ff0ef          	jal	ra,800130 <cprintf>
  8008f0:	00001517          	auipc	a0,0x1
  8008f4:	b1850513          	addi	a0,a0,-1256 # 801408 <error_string+0x2e0>
  8008f8:	839ff0ef          	jal	ra,800130 <cprintf>
  8008fc:	4519                	li	a0,6
  8008fe:	00001417          	auipc	s0,0x1
  800902:	70240413          	addi	s0,s0,1794 # 802000 <pids>
  800906:	943ff0ef          	jal	ra,800248 <lab6_set_priority>
  80090a:	84a2                	mv	s1,s0
  80090c:	4901                	li	s2,0
  80090e:	4995                	li	s3,5
  800910:	92bff0ef          	jal	ra,80023a <fork>
  800914:	c088                	sw	a0,0(s1)
  800916:	cd71                	beqz	a0,8009f2 <test_priority+0x11e>
  800918:	0c054863          	bltz	a0,8009e8 <test_priority+0x114>
  80091c:	2905                	addiw	s2,s2,1
  80091e:	0491                	addi	s1,s1,4
  800920:	ff3918e3          	bne	s2,s3,800910 <test_priority+0x3c>
  800924:	00001917          	auipc	s2,0x1
  800928:	6f490913          	addi	s2,s2,1780 # 802018 <status>
  80092c:	00001997          	auipc	s3,0x1
  800930:	6e898993          	addi	s3,s3,1768 # 802014 <pids+0x14>
  800934:	8a4a                	mv	s4,s2
  800936:	84ca                	mv	s1,s2
  800938:	4008                	lw	a0,0(s0)
  80093a:	85a6                	mv	a1,s1
  80093c:	0411                	addi	s0,s0,4
  80093e:	905ff0ef          	jal	ra,800242 <waitpid>
  800942:	0491                	addi	s1,s1,4
  800944:	ff341ae3          	bne	s0,s3,800938 <test_priority+0x64>
  800948:	00001517          	auipc	a0,0x1
  80094c:	b0050513          	addi	a0,a0,-1280 # 801448 <error_string+0x320>
  800950:	fe0ff0ef          	jal	ra,800130 <cprintf>
  800954:	00001517          	auipc	a0,0x1
  800958:	b1c50513          	addi	a0,a0,-1252 # 801470 <error_string+0x348>
  80095c:	fd4ff0ef          	jal	ra,800130 <cprintf>
  800960:	010a2783          	lw	a5,16(s4)
  800964:	06f05463          	blez	a5,8009cc <test_priority+0xf8>
  800968:	000a2583          	lw	a1,0(s4)
  80096c:	00001517          	auipc	a0,0x1
  800970:	b2450513          	addi	a0,a0,-1244 # 801490 <error_string+0x368>
  800974:	00001997          	auipc	s3,0x1
  800978:	6b498993          	addi	s3,s3,1716 # 802028 <status+0x10>
  80097c:	0015959b          	slliw	a1,a1,0x1
  800980:	02f5c5bb          	divw	a1,a1,a5
  800984:	00001497          	auipc	s1,0x1
  800988:	b0448493          	addi	s1,s1,-1276 # 801488 <error_string+0x360>
  80098c:	842a                	mv	s0,a0
  80098e:	2585                	addiw	a1,a1,1
  800990:	01f5d79b          	srliw	a5,a1,0x1f
  800994:	9dbd                	addw	a1,a1,a5
  800996:	4015d59b          	sraiw	a1,a1,0x1
  80099a:	f96ff0ef          	jal	ra,800130 <cprintf>
  80099e:	8526                	mv	a0,s1
  8009a0:	f90ff0ef          	jal	ra,800130 <cprintf>
  8009a4:	00492583          	lw	a1,4(s2)
  8009a8:	010a2783          	lw	a5,16(s4)
  8009ac:	0911                	addi	s2,s2,4
  8009ae:	0015959b          	slliw	a1,a1,0x1
  8009b2:	02f5c5bb          	divw	a1,a1,a5
  8009b6:	8522                	mv	a0,s0
  8009b8:	2585                	addiw	a1,a1,1
  8009ba:	01f5d79b          	srliw	a5,a1,0x1f
  8009be:	9dbd                	addw	a1,a1,a5
  8009c0:	4015d59b          	sraiw	a1,a1,0x1
  8009c4:	f6cff0ef          	jal	ra,800130 <cprintf>
  8009c8:	fd391be3          	bne	s2,s3,80099e <test_priority+0xca>
  8009cc:	00001517          	auipc	a0,0x1
  8009d0:	9dc50513          	addi	a0,a0,-1572 # 8013a8 <error_string+0x280>
  8009d4:	6406                	ld	s0,64(sp)
  8009d6:	60a6                	ld	ra,72(sp)
  8009d8:	74e2                	ld	s1,56(sp)
  8009da:	7942                	ld	s2,48(sp)
  8009dc:	79a2                	ld	s3,40(sp)
  8009de:	7a02                	ld	s4,32(sp)
  8009e0:	6ae2                	ld	s5,24(sp)
  8009e2:	6161                	addi	sp,sp,80
  8009e4:	f4cff06f          	j	800130 <cprintf>
  8009e8:	00001517          	auipc	a0,0x1
  8009ec:	89050513          	addi	a0,a0,-1904 # 801278 <error_string+0x150>
  8009f0:	b7d5                	j	8009d4 <test_priority+0x100>
  8009f2:	00190a1b          	addiw	s4,s2,1
  8009f6:	8552                	mv	a0,s4
  8009f8:	851ff0ef          	jal	ra,800248 <lab6_set_priority>
  8009fc:	84bff0ef          	jal	ra,800246 <gettime_msec>
  800a00:	0005049b          	sext.w	s1,a0
  800a04:	4401                	li	s0,0
  800a06:	7d000a93          	li	s5,2000
  800a0a:	7d000993          	li	s3,2000
  800a0e:	0c800713          	li	a4,200
  800a12:	47b2                	lw	a5,12(sp)
  800a14:	377d                	addiw	a4,a4,-1
  800a16:	2781                	sext.w	a5,a5
  800a18:	0017b793          	seqz	a5,a5
  800a1c:	c63e                	sw	a5,12(sp)
  800a1e:	fb75                	bnez	a4,800a12 <test_priority+0x13e>
  800a20:	2405                	addiw	s0,s0,1
  800a22:	035477bb          	remuw	a5,s0,s5
  800a26:	f7e5                	bnez	a5,800a0e <test_priority+0x13a>
  800a28:	81fff0ef          	jal	ra,800246 <gettime_msec>
  800a2c:	409507bb          	subw	a5,a0,s1
  800a30:	fcf9ffe3          	bgeu	s3,a5,800a0e <test_priority+0x13a>
  800a34:	86a2                	mv	a3,s0
  800a36:	8652                	mv	a2,s4
  800a38:	85ca                	mv	a1,s2
  800a3a:	00001517          	auipc	a0,0x1
  800a3e:	9f650513          	addi	a0,a0,-1546 # 801430 <error_string+0x308>
  800a42:	eeeff0ef          	jal	ra,800130 <cprintf>
  800a46:	8522                	mv	a0,s0
  800a48:	fdcff0ef          	jal	ra,800224 <exit>

0000000000800a4c <test_context_switch>:
  800a4c:	1101                	addi	sp,sp,-32
  800a4e:	00001517          	auipc	a0,0x1
  800a52:	a4a50513          	addi	a0,a0,-1462 # 801498 <error_string+0x370>
  800a56:	ec06                	sd	ra,24(sp)
  800a58:	e822                	sd	s0,16(sp)
  800a5a:	e426                	sd	s1,8(sp)
  800a5c:	ed4ff0ef          	jal	ra,800130 <cprintf>
  800a60:	1f400593          	li	a1,500
  800a64:	00001517          	auipc	a0,0x1
  800a68:	a6c50513          	addi	a0,a0,-1428 # 8014d0 <error_string+0x3a8>
  800a6c:	ec4ff0ef          	jal	ra,800130 <cprintf>
  800a70:	fcaff0ef          	jal	ra,80023a <fork>
  800a74:	c139                	beqz	a0,800aba <test_context_switch+0x6e>
  800a76:	fd0ff0ef          	jal	ra,800246 <gettime_msec>
  800a7a:	0005049b          	sext.w	s1,a0
  800a7e:	1f400413          	li	s0,500
  800a82:	347d                	addiw	s0,s0,-1
  800a84:	fc0ff0ef          	jal	ra,800244 <yield>
  800a88:	fc6d                	bnez	s0,800a82 <test_context_switch+0x36>
  800a8a:	fbcff0ef          	jal	ra,800246 <gettime_msec>
  800a8e:	409505bb          	subw	a1,a0,s1
  800a92:	1f400613          	li	a2,500
  800a96:	00001517          	auipc	a0,0x1
  800a9a:	a7a50513          	addi	a0,a0,-1414 # 801510 <error_string+0x3e8>
  800a9e:	e92ff0ef          	jal	ra,800130 <cprintf>
  800aa2:	f9aff0ef          	jal	ra,80023c <wait>
  800aa6:	6442                	ld	s0,16(sp)
  800aa8:	60e2                	ld	ra,24(sp)
  800aaa:	64a2                	ld	s1,8(sp)
  800aac:	00001517          	auipc	a0,0x1
  800ab0:	a8450513          	addi	a0,a0,-1404 # 801530 <error_string+0x408>
  800ab4:	6105                	addi	sp,sp,32
  800ab6:	e7aff06f          	j	800130 <cprintf>
  800aba:	f8cff0ef          	jal	ra,800246 <gettime_msec>
  800abe:	0005041b          	sext.w	s0,a0
  800ac2:	1f400493          	li	s1,500
  800ac6:	34fd                	addiw	s1,s1,-1
  800ac8:	f7cff0ef          	jal	ra,800244 <yield>
  800acc:	fced                	bnez	s1,800ac6 <test_context_switch+0x7a>
  800ace:	f78ff0ef          	jal	ra,800246 <gettime_msec>
  800ad2:	408505bb          	subw	a1,a0,s0
  800ad6:	1f400613          	li	a2,500
  800ada:	00001517          	auipc	a0,0x1
  800ade:	a1650513          	addi	a0,a0,-1514 # 8014f0 <error_string+0x3c8>
  800ae2:	e4eff0ef          	jal	ra,800130 <cprintf>
  800ae6:	4501                	li	a0,0
  800ae8:	f3cff0ef          	jal	ra,800224 <exit>

0000000000800aec <test_convoy>:
  800aec:	7139                	addi	sp,sp,-64
  800aee:	00001517          	auipc	a0,0x1
  800af2:	a6a50513          	addi	a0,a0,-1430 # 801558 <error_string+0x430>
  800af6:	fc06                	sd	ra,56(sp)
  800af8:	f822                	sd	s0,48(sp)
  800afa:	f426                	sd	s1,40(sp)
  800afc:	f04a                	sd	s2,32(sp)
  800afe:	ec4e                	sd	s3,24(sp)
  800b00:	e852                	sd	s4,16(sp)
  800b02:	e2eff0ef          	jal	ra,800130 <cprintf>
  800b06:	00001517          	auipc	a0,0x1
  800b0a:	a8a50513          	addi	a0,a0,-1398 # 801590 <error_string+0x468>
  800b0e:	e22ff0ef          	jal	ra,800130 <cprintf>
  800b12:	f34ff0ef          	jal	ra,800246 <gettime_msec>
  800b16:	0005041b          	sext.w	s0,a0
  800b1a:	f20ff0ef          	jal	ra,80023a <fork>
  800b1e:	00001797          	auipc	a5,0x1
  800b22:	4ea7a123          	sw	a0,1250(a5) # 802000 <pids>
  800b26:	c94d                	beqz	a0,800bd8 <test_convoy+0xec>
  800b28:	0c800713          	li	a4,200
  800b2c:	47a2                	lw	a5,8(sp)
  800b2e:	377d                	addiw	a4,a4,-1
  800b30:	2781                	sext.w	a5,a5
  800b32:	0017b793          	seqz	a5,a5
  800b36:	c43e                	sw	a5,8(sp)
  800b38:	fb75                	bnez	a4,800b2c <test_convoy+0x40>
  800b3a:	0c800713          	li	a4,200
  800b3e:	4792                	lw	a5,4(sp)
  800b40:	377d                	addiw	a4,a4,-1
  800b42:	2781                	sext.w	a5,a5
  800b44:	0017b793          	seqz	a5,a5
  800b48:	c23e                	sw	a5,4(sp)
  800b4a:	fb75                	bnez	a4,800b3e <test_convoy+0x52>
  800b4c:	00001497          	auipc	s1,0x1
  800b50:	4b448493          	addi	s1,s1,1204 # 802000 <pids>
  800b54:	89a6                	mv	s3,s1
  800b56:	4905                	li	s2,1
  800b58:	4a15                	li	s4,5
  800b5a:	ee0ff0ef          	jal	ra,80023a <fork>
  800b5e:	00a9a223          	sw	a0,4(s3)
  800b62:	c945                	beqz	a0,800c12 <test_convoy+0x126>
  800b64:	2905                	addiw	s2,s2,1
  800b66:	0991                	addi	s3,s3,4
  800b68:	ff4919e3          	bne	s2,s4,800b5a <test_convoy+0x6e>
  800b6c:	00001917          	auipc	s2,0x1
  800b70:	4ac90913          	addi	s2,s2,1196 # 802018 <status>
  800b74:	844a                	mv	s0,s2
  800b76:	00001997          	auipc	s3,0x1
  800b7a:	49e98993          	addi	s3,s3,1182 # 802014 <pids+0x14>
  800b7e:	4088                	lw	a0,0(s1)
  800b80:	85a2                	mv	a1,s0
  800b82:	0491                	addi	s1,s1,4
  800b84:	ebeff0ef          	jal	ra,800242 <waitpid>
  800b88:	0411                	addi	s0,s0,4
  800b8a:	fe999ae3          	bne	s3,s1,800b7e <test_convoy+0x92>
  800b8e:	00492703          	lw	a4,4(s2)
  800b92:	00892683          	lw	a3,8(s2)
  800b96:	00c92583          	lw	a1,12(s2)
  800b9a:	01092783          	lw	a5,16(s2)
  800b9e:	9f35                	addw	a4,a4,a3
  800ba0:	9db9                	addw	a1,a1,a4
  800ba2:	9fad                	addw	a5,a5,a1
  800ba4:	41f7d59b          	sraiw	a1,a5,0x1f
  800ba8:	01e5d59b          	srliw	a1,a1,0x1e
  800bac:	9dbd                	addw	a1,a1,a5
  800bae:	4025d59b          	sraiw	a1,a1,0x2
  800bb2:	00001517          	auipc	a0,0x1
  800bb6:	a2e50513          	addi	a0,a0,-1490 # 8015e0 <error_string+0x4b8>
  800bba:	d76ff0ef          	jal	ra,800130 <cprintf>
  800bbe:	7442                	ld	s0,48(sp)
  800bc0:	70e2                	ld	ra,56(sp)
  800bc2:	74a2                	ld	s1,40(sp)
  800bc4:	7902                	ld	s2,32(sp)
  800bc6:	69e2                	ld	s3,24(sp)
  800bc8:	6a42                	ld	s4,16(sp)
  800bca:	00001517          	auipc	a0,0x1
  800bce:	a3e50513          	addi	a0,a0,-1474 # 801608 <error_string+0x4e0>
  800bd2:	6121                	addi	sp,sp,64
  800bd4:	d5cff06f          	j	800130 <cprintf>
  800bd8:	6689                	lui	a3,0x2
  800bda:	f4068693          	addi	a3,a3,-192 # 1f40 <__warn-0x7fe0e0>
  800bde:	0c800713          	li	a4,200
  800be2:	47b2                	lw	a5,12(sp)
  800be4:	377d                	addiw	a4,a4,-1
  800be6:	2781                	sext.w	a5,a5
  800be8:	0017b793          	seqz	a5,a5
  800bec:	c63e                	sw	a5,12(sp)
  800bee:	fb75                	bnez	a4,800be2 <test_convoy+0xf6>
  800bf0:	36fd                	addiw	a3,a3,-1
  800bf2:	f6f5                	bnez	a3,800bde <test_convoy+0xf2>
  800bf4:	e52ff0ef          	jal	ra,800246 <gettime_msec>
  800bf8:	408505bb          	subw	a1,a0,s0
  800bfc:	00001517          	auipc	a0,0x1
  800c00:	9b450513          	addi	a0,a0,-1612 # 8015b0 <error_string+0x488>
  800c04:	d2cff0ef          	jal	ra,800130 <cprintf>
  800c08:	e3eff0ef          	jal	ra,800246 <gettime_msec>
  800c0c:	9d01                	subw	a0,a0,s0
  800c0e:	e16ff0ef          	jal	ra,800224 <exit>
  800c12:	1f400693          	li	a3,500
  800c16:	0c800713          	li	a4,200
  800c1a:	47b2                	lw	a5,12(sp)
  800c1c:	377d                	addiw	a4,a4,-1
  800c1e:	2781                	sext.w	a5,a5
  800c20:	0017b793          	seqz	a5,a5
  800c24:	c63e                	sw	a5,12(sp)
  800c26:	fb75                	bnez	a4,800c1a <test_convoy+0x12e>
  800c28:	36fd                	addiw	a3,a3,-1
  800c2a:	f6f5                	bnez	a3,800c16 <test_convoy+0x12a>
  800c2c:	e1aff0ef          	jal	ra,800246 <gettime_msec>
  800c30:	4085063b          	subw	a2,a0,s0
  800c34:	85ca                	mv	a1,s2
  800c36:	00001517          	auipc	a0,0x1
  800c3a:	99250513          	addi	a0,a0,-1646 # 8015c8 <error_string+0x4a0>
  800c3e:	cf2ff0ef          	jal	ra,800130 <cprintf>
  800c42:	e04ff0ef          	jal	ra,800246 <gettime_msec>
  800c46:	9d01                	subw	a0,a0,s0
  800c48:	ddcff0ef          	jal	ra,800224 <exit>

0000000000800c4c <main>:
  800c4c:	1141                	addi	sp,sp,-16
  800c4e:	00000517          	auipc	a0,0x0
  800c52:	75a50513          	addi	a0,a0,1882 # 8013a8 <error_string+0x280>
  800c56:	e406                	sd	ra,8(sp)
  800c58:	cd8ff0ef          	jal	ra,800130 <cprintf>
  800c5c:	00001517          	auipc	a0,0x1
  800c60:	9dc50513          	addi	a0,a0,-1572 # 801638 <error_string+0x510>
  800c64:	cccff0ef          	jal	ra,800130 <cprintf>
  800c68:	00001517          	auipc	a0,0x1
  800c6c:	a0850513          	addi	a0,a0,-1528 # 801670 <error_string+0x548>
  800c70:	cc0ff0ef          	jal	ra,800130 <cprintf>
  800c74:	00001517          	auipc	a0,0x1
  800c78:	9c450513          	addi	a0,a0,-1596 # 801638 <error_string+0x510>
  800c7c:	cb4ff0ef          	jal	ra,800130 <cprintf>
  800c80:	9ffff0ef          	jal	ra,80067e <test_short_long_mix>
  800c84:	b03ff0ef          	jal	ra,800786 <test_fairness>
  800c88:	c4dff0ef          	jal	ra,8008d4 <test_priority>
  800c8c:	dc1ff0ef          	jal	ra,800a4c <test_context_switch>
  800c90:	e5dff0ef          	jal	ra,800aec <test_convoy>
  800c94:	00001517          	auipc	a0,0x1
  800c98:	a0c50513          	addi	a0,a0,-1524 # 8016a0 <error_string+0x578>
  800c9c:	c94ff0ef          	jal	ra,800130 <cprintf>
  800ca0:	00001517          	auipc	a0,0x1
  800ca4:	a3850513          	addi	a0,a0,-1480 # 8016d8 <error_string+0x5b0>
  800ca8:	c88ff0ef          	jal	ra,800130 <cprintf>
  800cac:	00001517          	auipc	a0,0x1
  800cb0:	a5450513          	addi	a0,a0,-1452 # 801700 <error_string+0x5d8>
  800cb4:	c7cff0ef          	jal	ra,800130 <cprintf>
  800cb8:	00001517          	auipc	a0,0x1
  800cbc:	a8050513          	addi	a0,a0,-1408 # 801738 <error_string+0x610>
  800cc0:	c70ff0ef          	jal	ra,800130 <cprintf>
  800cc4:	00001517          	auipc	a0,0x1
  800cc8:	a8c50513          	addi	a0,a0,-1396 # 801750 <error_string+0x628>
  800ccc:	c64ff0ef          	jal	ra,800130 <cprintf>
  800cd0:	00001517          	auipc	a0,0x1
  800cd4:	aa050513          	addi	a0,a0,-1376 # 801770 <error_string+0x648>
  800cd8:	c58ff0ef          	jal	ra,800130 <cprintf>
  800cdc:	00001517          	auipc	a0,0x1
  800ce0:	aac50513          	addi	a0,a0,-1364 # 801788 <error_string+0x660>
  800ce4:	c4cff0ef          	jal	ra,800130 <cprintf>
  800ce8:	00001517          	auipc	a0,0x1
  800cec:	ac050513          	addi	a0,a0,-1344 # 8017a8 <error_string+0x680>
  800cf0:	c40ff0ef          	jal	ra,800130 <cprintf>
  800cf4:	60a2                	ld	ra,8(sp)
  800cf6:	4501                	li	a0,0
  800cf8:	0141                	addi	sp,sp,16
  800cfa:	8082                	ret
