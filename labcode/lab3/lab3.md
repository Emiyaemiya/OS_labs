# <center>lab03实验报告</center>


### Exercise1: 完善中断处理
在这里我们需要编程完善trap.c中的中断处理函数trap，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用sbi.h中的shut_down()函数关机。

具体实现代码如下：

```c
 // 设置下一次时钟中断
            clock_set_next_event();
            
            // 计数器加一
            ticks++;
            
            // 每100次清屏输出一个dot，同时输出100 ticks
            if (ticks % TICK_NUM == 0) {
                print_ticks();
                print_num++;
                if (print_num == 10) {
                    cprintf("\nShutting down...\n");
                    sbi_shutdown();
                }
            }
```

通过我们的代码可以看到，在完善中断处理的时候，我们的实现流程就和问题描述一样，在需要时钟中断的时候，先通过`clock_set_next_event`函数来设置下一次时钟中断，具体函数代码如下：
```c
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
```
该函数具体的作用就是：先通过`get_cycles`函数，使用 RISC‑V 的 rdtime/rdtimeh 指令读取机器当前的时间/时钟计数，在此基础上加上`timebase`作为下一次中断的触发时刻，从而安排下一次时钟中断。

在设置好下一次时钟中断之后我们进行ticks的增加记录时钟中断次数，然后就是进行打印操作，这里就是非常易懂的去实现每一百次中断触发一次打印函数，在触发十次之后调用`sbi_shutdown`函数进行关机操作，对应函数代码如下：
```c
void sbi_shutdown(void) {
    sbi_call(SBI_SHUTDOWN, 0, 0, 0);
    while (1); // 防止返回
}
```

通过代码我们可以看到该函数在实现过程中首先调用下面的`sbi_call`函数：
```c
uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
        "mv x17, %[sbi_type]\n"
        "mv x10, %[arg0]\n"
        "mv x11, %[arg1]\n"
        "mv x12, %[arg2]\n"
        "ecall\n"
        "mv %[ret_val], x10"
        : [ret_val] "=r" (ret_val)
        : [sbi_type] "r" (sbi_type), [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2)
        : "memory"
    );
    return ret_val;
}
```

该函数通过 ecall 指令触发从 S-mode 到 M-mode 的切换，请求固件完成特权操作，在这里我们传入的参数就表明我们需要请求固件完成shutdown操作。

在编写代码之后，我们可以了解到定时器中断处理的流程如下：
1. 中断触发与分发
```c
void trap(struct trapframe *tf) {
    trap_dispatch(tf);
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
        // interrupts
        interrupt_handler(tf);
    }
}
```

当定时器中断发生时，首先进入 `trap()`，然后通过 `trap_dispatch()` 判断是中断（cause < 0）还是异常，定时器中断会进入`interrupt_handler()`
2. 中断类型判断
```c
void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;  // 去掉最高位的中断标志位
    switch (cause) {
        case IRQ_S_TIMER:  // supervisor 级别的定时器中断
```

在 interrupt_handler 中，通过 cause 字段判断具体是哪种中断，定时器中断对应 IRQ_S_TIMER 分支。
3. 定时器中断处理
```c
case IRQ_S_TIMER:
    // 设置下一次时钟中断
    clock_set_next_event();
    
    // 计数器加一
    ticks++;
    
    // 每100次清屏输出一个dot，同时输出100 ticks
    if (ticks % TICK_NUM == 0) {
        print_ticks();      // 打印 "100 ticks"
        print_num++;
        if (print_num == 10) {
            cprintf("\nShutting down...\n");
            sbi_shutdown();  // 打印10次后关机
        }
    }
    break;
```

这一部分在上面已经做过介绍在这里就不多赘述。

4. 初始化相关
```c
void clock_init(void) {
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    clock_set_next_event();
    ticks = 0;
    cprintf("++ setup timer interrupts\n");
}
```

在系统初始化时，会：

1) 使能时钟中断（设置 sie 寄存器）
2) 设置第一次时钟中断
3) 初始化 ticks 计数器


### Challenge1：描述与理解中断流程

#### 1.中断处理流程

首先，保存中断发生时的`pc`值到`sepc`寄存器中。然后，记录异常的类型，并将其写入`scause`寄存器。

接下来，保存相关的辅助信息。如果异常与缺页或访问错误相关，将相关的地址或数据保存到`stval`寄存器，以便中断处理程序在后续处理中使用。

紧接着，保存并修改中断使能状态。将当前的中断使能状态`sstatus.SIE`保存到`sstatus.SPIE`中，并且会将`sstatus.SIE`清零，从而禁用 `S` 模式下的中断。

之后，保存当前的特权级信息。将当前特权级（即 `U` 模式，值为 `0`）保存到`sstatus.SPP`中，并将当前特权级切换到 `S` 模式。此时，系统已经进入 `S` 模式，准备跳转到中断处理程序。将`pc`设置为`stvec`寄存器中的值，并跳转到中断处理程序的入口。

跳转之后，先保存完整上下文，传递上下文参数并调用 C 层异常处理函数。

异常处理完成之后先进行上下文的恢复。

接着，根据异常的类型重新设置`sepc`，确保程序能够从正确的地址继续执行。这里有时候需要`sepc+4`，有时候`sepc+2`（比如`ebreak`指令）。

然后，将`sstatus.SPP`设置为 `0`，表示要返回到 `U` 模式。

当准备工作完成后，会执行`sret`指令，根据`sstatus.SPP`的值（此时为 `0`）切换回 `U` 模式。随后，恢复中断使能状态，将`sstatus.SIE`恢复为`sstatus.SPIE`的值。接着，更新`sstatus`，将`sstatus.SPIE`设置为 `1`,`sstatus.SPP`设置为 `0`，为下一次中断做准备。最后，将`sepc`的值赋给`pc`，并跳转回用户程序（`sepc`指向的地址）继续执行。

#### 2.move a0, sp的目的

在 RISC-V 架构中，函数调用的参数通过通用寄存器`a0-a7`传递。此处`move a0, sp`的作用是：将当前栈指针（sp）的值（即`SAVE_ALL`保存的完整现场栈帧的起始地址）作为参数传递给`trap`函数。
栈帧中包含了所有通用寄存器（`x0-x31`）和关键 `CSR（sstatus、sepc、scause等）`的值， trap函数需要通过该栈帧地址访问这些信息，以判断异常类型（从`scause`获取）、处理异常（根据`sepc`定位错误指令），并在处理完成后确保能正确恢复原程序状态。

#### 3.SAVE_ALL中寄存器保存在栈中的位置

`SAVE_ALL`中寄存器在栈中的位置由预设的 “陷阱帧（`trapframe`）结构” 确定。定义一个统一的栈帧布局，约定每个通用寄存器 / `CSR` 在栈中的偏移量（如`x0`对应`0*REGBYTES`，`x1`对应`1*REGBYTES`，`sstatus`对应`32*REGBYTES`等）。

#### 4.对于任何中断，__alltraps 中都需要保存所有寄存器

中断 / 异常可能在程序执行的任意时刻发生（无论是用户态还是内核态），被中断的程序可能正在使用任何通用寄存器（如`x5`存放临时变量、`x1`存放返回地址`ra`）。若未保存所有寄存器，异常处理过程中对寄存器的修改会覆盖原程序的状态，导致恢复后程序执行错误。

### Challenge2：理解上下文切换机制

#### 1.csrw sscratch, sp与csrrw s0, sscratch, x0的操作及目的

`csrw sscratch, sp`：将当前栈指针（`sp`）的值写入`sscratch`寄存器。此时的`sp`是异常发生前的栈指针。
`csrrw s0, sscratch, x0`：这是一条原子读写指令，功能是：读取`sscratch`寄存器的当前值（即上一步存入的 “异常前`sp`”），并写入通用寄存器`s0`；同时将`x0`（值恒为 0）写入`sscratch`，清空该寄存器。

这两条指令配合完成了 **“异常前栈指针的暂存与提取”**，是保存上下文的关键步骤，具体原因如下：

暂存异常前的`sp`：后续需要通过`addi sp, sp, -36 * REGBYTES`调整栈指针，为`trapframe`分配空间。此时原`sp`（异常发生时的栈指针）会被新的`sp`覆盖，必须提前通过`sscratch`暂存，否则会永久丢失。

提取暂存的`sp`并保存到`trapframe`：通过`csrrw`将`sscratch`中暂存的原`sp`读取到`s0`后，再通过`STORE s0, 2*REGBYTES(sp)`写入栈中`pushregs.sp`的位置（对应`x2`寄存器的保存），确保上下文的完整性。

#### 2.保存 stval scause 这些 CSR 的意义

`scause、sbadaddr`等 `CSR` 是当前异常的关键元数据，保存它们的目的是为 C 层的`trap`函数提供处理依据：

`scause`用于判断异常类型（如系统调用、外部中断、页错误、非法指令等），`trap`函数需根据其值执行不同逻辑（如系统调用服务、中断响应、缺页修复）。

`sbadaddr`用于定位地址相关异常（如页错误的虚拟地址、非法访问的地址），是修复错误的必要信息（如为缺页异常分配物理页并映射）。

这些值被保存到`trapframe`中，`trap`函数通过`tf`指针即可访问，确保处理逻辑能正确识别和处理异常。

#### 3.不还原这些 CSR 的原因

`scause、sbadaddr`等 `CSR` 是临时的、与当前异常强绑定的信息，而非原程序执行所需的上下文，因此无需还原。

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



### 知识点汇总

#### 时间片与抢占

时间片是操作系统在多任务之间分配 CPU 的基本单位，指一个任务在被抢占前可连续运行的时间窗口。它通常由定时器中断驱动的时间记账来实现：当任务的时间片耗尽，调度器标记其需要让出处理器并切换到下一个可运行任务。时间片越小，交互性越好，但上下文切换更频繁、缓存与 TLB 污染更重；时间片越大，吞吐更高，但响应延迟上升。

可抢占调度决定了切换发生的时机。可抢占内核允许在内核态（不处于临界区时）也能被抢占，降低尾延迟；不可抢占则把切换推迟到明确的安全点，简化并发控制。现代通用系统多采用公平分享思想：不再给固定大小的时间片，而是通过“虚拟运行时间”等度量在一定的目标调度周期内按权重分配运行窗口，进程多时单次运行更短、进程少时更长。

定时器模式也影响时间片实现。传统做法使用固定频率的周期性 tick 进行时间记账与过期检查；更先进的“无周期 tick（tickless）”结合高精度定时器，按实际事件预约唤醒点，降低空负载下的中断开销。多核环境中，调度还需兼顾亲和性与迁移成本，尽量在本地核消化时间片以保留缓存局部性，同时通过负载均衡避免个别核心饱和。
