# <center>lab03实验报告</center>


### Challenge3：完善异常中断

这里我们实现的主要是非法指令异常和断点异常的捕获，并完成了异常返回时的指令长度感知修正。

首先我们需要在 `trap.c` 找到对应的异常所在部分，两个异常分别是 `CAUSE_ILLEGAL_INSTRUCTION` 和 `CAUSE_BREAKPOINT`。我们在这里做的只是输出异常指令类型、地址及更新寄存器 `epc`。具体实现如下：

```c
case CAUSE_ILLEGAL_INSTRUCTION:
    cprintf("Illegal instruction at sepc=%p\n", tf->epc);
    tf->epc += insn_len(tf->epc);
    break;
case CAUSE_BREAKPOINT:
    cprintf("Breakpoint at sepc=%p\n", tf->epc);
    tf->epc += insn_len(tf->epc);
    break;
```

这个部分还是相当简单的，需要重点提的是这里 `epc` 寄存器的更新，一开始，我想当然的认为每条指令都是4个字节，直接写了 `tf->epc += 4`，在测试的时候却出现了问题，当我在某些地方写入内联汇编时，得不到我想要的结果，异常处理直接进入 `default` 而不是预期的中断指令，略微换个位置，又可以获取到我想要的对应的异常信息的输出，这令我十分困惑。

漫长debug过程中，我尝试输出了 `epc` 的具体值，然后通过编译，得到汇编码，定位到 `epc` ，找到其内容，我惊奇的发现如下内容：

```asm
ffffffffc0200098:       79e000ef                jal     ra,ffffffffc0200836 <intr_enable>
ffffffffc020009c:       9002                    ebreak
ffffffffc020009e:       ffff                    0xffff
```

也就是说这里的 `ebreak` 指令只有两个字节！经过查阅资料我发现这是RISC-V指令集中的压缩指令（RVC）。RVC 是 RISC‑V 的 C 扩展，提供 16 位长度的“压缩指令”以替代常见的 32 位指令，主要用于提升代码密度，从而减少指令缓存/总线压力，带来能耗和性能的综合收益。

RVC实际上是有一定的判定规则的，我们可以通过插卡指令最低两位来确定，倘若指令的最低两位是二进制的 `11`，则该指令为32位，否则则为16位的压缩指令。由此我们可以写出以下的寄存器偏移计算函数。

```c
static inline int insn_len(uintptr_t epc) {
    // RISC-V: if low 2 bits != 0b 11, it's a 16-bit compressed instruction
    // challenge3 的核心修改部分，触发指令（ebreak、明确的非法 .4byte 或者汇编器生成的非法）在 RISC‑V 开了压缩指令（RVC）时，常常是 16 位的编码（比如 C.EBREAK，长度 2 字节）。如果异常处理里一律 tf->epc += 4，就会把返回地址推进到“错误的边界”：要么跳过了下一条 16 位指令，要么直接落到“某条指令的中间”。
    //RISC‑V 指令按“Quadrant（四分象限）”编码：16 位压缩指令的最低两位属于 Q0/Q1/Q2，均不等于 0b11。32 位标准指令的最低两位固定是 0b11。硬件取指就是用这两位来区分 16/32 位长度的，所以我们在软件里用同样的判据推进 sepc 是最稳妥的。
    uint16_t half;
    memcpy(&half, (void *)epc, sizeof(half));
    return (half & 0x3) != 0x3 ? 2 : 4;
}
```

这也就是我们在 `excption handler` 函数中使用 `insn_len` 函数来更新 `epc` 而不是简单的加4处理的原因。

我们选择在 `init.c` 中 `while(1)` 的前面加入两条内联汇编。

```c
asm volatile("ebreak");            // 触发 breakpoint 异常
asm volatile(".4byte 0xffffffff"); // 明确的非法 32 位指令，触发 illegal instruction
```

在使用合理的偏移计算之前，breakpoint异常不会被触发，而是发生大面积的default的异常，因为 `epc` 的具体值已经和具体指令错开。使用 `insn_len` 函数后，我们可以得到正常的输出。

需要指出的是，其实这里 `insn_len` 函数并不是一定要使用的，我们完全可以在中断的 `case` 下直接让 `epc` 加2，但这样倘若后续要加入对其他异常的处理，就需要重新规划，让后续所有工作失去了普适性，这并不是我们所期望的。