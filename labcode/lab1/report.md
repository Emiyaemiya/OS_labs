# <center>lab01实验报告</center>

### 任务一：内核启动程序入口操作解析
#### 1. 指令 `la sp, bootstacktop` 的操作与目的
##### （1）核心操作

&emsp;&emsp;`la` 是 RISC-V 汇编的“加载地址”（Load Address）指令，该指令的核心功能是：**将符号 `bootstacktop` 对应的地址，加载到栈指针寄存器 `sp` 中**。  

&emsp;&emsp;结合代码中 `bootstack` 的定义（`.data` 段分配 `KSTACKSIZE` 大小的栈空间，`bootstack` 为栈的低地址“底部”，`bootstacktop` 为栈的高地址“顶部”），这条指令本质是将 `sp` 精准指向内核专属栈的“顶部”（高地址端）——而 RISC-V 栈遵循“向下生长”规则（压栈时 `sp` 向低地址移动，出栈时向高地址移动），因此 `bootstacktop` 是栈的合法起始位置。


##### （2）核心目的

&emsp;&emsp;内核从 OpenSBI 接管控制权时，`sp` 寄存器处于**未初始化状态**（OpenSBI 仅负责加载内核、移交 CPU，不提供内核专用栈）。若不初始化 `sp`，后续执行`kern_init`（C 语言函数）会直接崩溃，因此该指令的核心目的是**为内核构建合法的函数执行环境**，具体解决两个关键问题：
- 保障函数调用的正确性：C 语言函数调用时，需通过栈保存“返回地址”（确保函数执行完后能回到调用处），未初始化的 `sp` 会导致返回地址无处存储，调用后“迷路”；
- 保障局部变量的合法性：函数的局部变量（如 `kern_init` 中的 `message`）需暂存到栈中，未初始化的 `sp` 会导致局部变量访问“非法内存”，触发内存错误。


#### 2. 指令 `tail kern_init` 的操作与目的
##### （1）核心操作

&emsp;&emsp;`tail` 是 RISC-V 汇编的“尾跳转”指令，该指令的核心功能是：**将程序计数器（PC）设置为目标函数 `kern_init` 的入口地址**，强制 CPU 从 `kern_init` 的第一条指令开始执行。  
&emsp;&emsp;与普通跳转指令（如 `j`）相比，`tail` 有关键优化：由于 `kern_entry`（汇编入口）在 `tail kern_init` 之后无任何代码，跳转后无需返回，因此 `tail` 会**省略“将返回地址保存到栈”的操作**，减少指令开销，提升执行效率。


##### （2）核心目的

&emsp;&emsp;`kern_entry` 作为内核的“汇编入口”，仅能完成“硬件级基础初始化”（如栈初始化），无法处理复杂逻辑——用汇编写内存管理、设备驱动不仅繁琐，还易出错。因此该指令的核心目的是：
- 实现“执行流程切换”：将 CPU 控制权从“简单的汇编代码”，无缝转移到“功能完整的 C 语言初始化函数 `kern_init`”，利用 C 语言的可读性和扩展性完成后续复杂工作；
- 启动内核核心流程：`kern_init` 负责清零 `.bss` 段、打印启动日志、初始化硬件等关键操作，`tail kern_init` 是触发这些操作的“开关”，为后续内存管理、中断处理、进程调度等内核功能铺路。

### 任务二：使用GDB验证启动流程
#### 1. 调试过程
&emsp;&emsp;根据任务指导书的内容，我们首先使用 `make qemu` 进行测试，得到如下结果，说明环境配置完成。可以看到这里已经成功输出字符串 ```(THU.CST) os is loading ...\n``` ，同时陷入 ```while(1)``` 的死循环。

<center><img src=picture/1.png width=400></center>

&emsp;&emsp;我们接下来尝试对其进行GDB调试。首先，我们打开两个终端，分别输入 ```make debug``` 和 ```make gdb``` ，在GDB调试的界面，我们可以看到语句 ```0x0000000000001000 in ?? ()``` ，也就是说现在的PC在复位地址 ```0x1000``` 地址处。

&emsp;&emsp;我们接下来使用语句 ```x/10i $pc``` 来获取将要执行的10条指令，得到如下结果。
```assembly
0x1000:      auipc   t0,0x0        # 将PC的值加载到t0中
0x1004:      addi    a1,t0,32      # a1 = t0 + 32
0x1008:      csrr    a0,mhartid    # 获取当前 CPU 核心的 ID，并将其值存入 a0
0x100c:      ld      t0,24(t0)     # 在 t0 + 24 所在地址处读取一个64位的值，加载入 t0
0x1010:      jr      t0            # 跳转t0存储的地址。
0x1014:      unimp
0x1016:      unimp
0x1018:      unimp
0x101a:      0x8000
0x101c:      unimp
```

&emsp;&emsp;对于a1所存内容具体是什么，我们进行了研究。根据RISC-V的引导规范，`a1`寄存器用于传递设备树（Device Tree Blob, DTB）的地址。设备树是一个描述硬件平台详细信息的数据结构，它让操作系统内核可以动态地了解自己运行在什么样的硬件上，从而实现与硬件的解耦。

&emsp;&emsp;为了验证这一点，我们尝试在GDB中查看`a1`指向的地址`0x1020`。
首先，我们尝试将其当作指令来反汇编：`x/10i 0x1020`，结果得到一堆奇怪的指令、夹杂着`unimp`的乱码指令。接着，我们尝试通过`x/wx 0x1020`，我们看到了类似`0xedfe0dd0`这样的十六进制数字。经过分析，我们确认这是设备树二进制文件的头部“魔数”（Magic Number）`0xd00dfeed`，由于GDB在小端序环境下而显示成了`0xedfe0dd0`。这一系列操作雄辩地证明了：`a1`寄存器确实指向了设备树数据块的起始地址。同时，我还对其中的奇怪指令得到了解决：因为这里存着信息，倘若进行反汇编，部分机器码信息会被译为对应的指令，但实际上这里存的并不是指令，而是设备树的内容。

&emsp;&emsp;接着我们尝试获取了设备树，通过查阅资料，我们注意到设备树的头部包含了自身的总大小信息。该字段位于起始地址 `0x1020` 偏移量为 +4 的位置，即 `0x1024`。我们可以使用 `x/wx 0x1024` 获取其设备树大小 `0x1024: 0x260d0000`，这样我们就可以尝试获取其设备树内容。使用 `dump binary memory my_device_tree.dtb 0x1020 0x1d46` 指令，以获取其对应内容，接着使用 `dtc -I dtb -O dts my_device_tree.dtb` 指令获取其可视化，部分形如下。

```
cpus {
        #address-cells = <0x01>;
        #size-cells = <0x00>;
        timebase-frequency = <0x989680>;

        cpu-map {

                cluster0 {

                        core0 {
                                cpu = <0x01>;
                        };
                };
        };

        cpu@0 {
                linux,phandle = <0x01>;
                phandle = <0x01>;
                device_type = "cpu";
                reg = <0x00>;
                status = "okay";
                compatible = "riscv";
                riscv,isa = "rv64imafdcsu";
                mmu-type = "riscv,sv48";
                clock-frequency = <0x3b9aca00>;

                interrupt-controller {
                        #interrupt-cells = <0x01>;
                        interrupt-controller;
                        compatible = "riscv,cpu-intc";
                        linux,phandle = <0x02>;
                        phandle = <0x02>;
                };
        };
};
```

&emsp;&emsp;该部分包含了所有CPU信息，是一份详尽的CPU简历，告诉了操作系统内核关于它即将运行的处理器的一切关键信息：
*   **`cpus` 节点**: 这是一个容器，定义了所有CPU核心共享的一些属性，例如`timebase-frequency`，它定义了时钟基准频率为10MHz，这对操作系统的定时和调度至关重要。
*   **`cpu@0` 节点**: 这是对第一个CPU核心（ID为0）的具体描述。
    *   **`riscv,isa = "rv64imafdcsu";`**: 定义了CPU支持的完整指令集架构，包括64位基础指令、乘除法、原子操作、单双精度浮点、压缩指令以及监督模式和用户模式。
    *   **`mmu-type = "riscv,sv48";`**: 说明了内存管理单元（MMU）支持sv48分页模式，即48位的虚拟地址空间。
    *   **`clock-frequency = <0x3b9aca00>;`**: 定义了CPU的主频为1GHz。
*   **`interrupt-controller` 节点**: 描述了与该核心紧密集成的本地中断控制器，用于处理时钟中断、软件中断等。

&emsp;&emsp;内核会解析这些信息，来正确地配置自己的调度器、定时器、内存管理以及中断处理系统，从而与底层硬件完美适配。

&emsp;&emsp;综上所述， `0x1000` 处的引导代码通过为 `a0` 和 `a1` 寄存器赋值，严格遵循了RISC-V标准引导协议。 `a0` 负责传递当前核心的ID，而`a1` 则传递了设备树的地址。这两个寄存器如同标准化的“信使”，确保了下一阶段的OpenSBI固件在启动时，能够准确无误地接收到必要的硬件环境参数。


&emsp;&emsp;而后，我们可以看到这里最后跳转的相当于是 ```0x1018``` 的值，我们可以尝试读取一下，看其具体是什么。使用指令 ```x/1x 0x1018``` 进行读取，发现该地址上存着值 ```0x80000000``` ，也就是说PC直接跳转到了 ```0x80000000``` ，与我们的bootloader的初始加载地址相同，我们可以使用 ```b *0x80000000``` 在该地址打上断点，然后直接输入指令 ```c``` 运行到该地址。

&emsp;&emsp;接下来使用和刚刚相同的 ```x/10i $pc``` 来获取将要执行的10条指令，得到如下结果。

```assembly
0x80000000:  csrr    a6,mhartid
0x80000004:  bgtz    a6,0x80000108
0x80000008:  auipc   t0,0x0
0x8000000c:  addi    t0,t0,1032
0x80000010:  auipc   t1,0x0
0x80000014:  addi    t1,t1,-16
0x80000018:  sd      t1,0(t0)
0x8000001c:  auipc   t0,0x0
0x80000020:  addi    t0,t0,1020
0x80000024:  ld      t0,0(t0)
```

&emsp;&emsp;这里主要执行的是区分主/从核，仅让主核（Hart 0）执行初始化，并准备跳转到内核阶段。至于具体在哪里进入内核，我们马上会看到。

&emsp;&emsp;使用指令 ```b* kern_entry``` ，在内核的入口函数 `kern_entry` 处设置一个断点。然后输入 `c` 继续执行，程序便会停在 `kern/init/entry.S` 中，这证明 OpenSBI 已经完成了它的引导任务，并将控制权成功移交给了我们的内核。此时再次使用 `x/10i $pc` 查看，可以看到我们自己编写的内核汇编代码：

```assembly
0x80200000 <kern_entry>:     auipc   sp,0x3
0x80200004 <kern_entry+4>:   mv      sp,sp
0x80200008 <kern_entry+8>:   j       0x8020000a <kern_init>
0x8020000a <kern_init>:      auipc   a0,0x3
0x8020000e <kern_init+4>:    addi    a0,a0,-2
0x80200012 <kern_init+8>:    auipc   a2,0x3
0x80200016 <kern_init+12>:   addi    a2,a2,-10
0x8020001a <kern_init+16>:   addi    sp,sp,-16
0x8020001c <kern_init+18>:   li      a1,0
0x8020001e <kern_init+20>:   sub     a2,a2,a0
```

&emsp;&emsp;前两条指令实际上是汇编代码中的 `la sp, bootstacktop` ，也就是加载 bootstacktop 的地址到栈指针 sp，设置了初始的栈指针。且此时OpenSBI界面出现，也就是说内核正式启动。之后的一条命令则代表调用 `kern_init` 函数。

&emsp;&emsp;接下来就是 `init.c` 的具体实现，整体相对“白盒”。主要是通过 `memset` 清空 `BSS` 段，确保全局变量的初始值为 0。再调用我们创造的 `cprintf` 函数，接着进入待机死循环状态。
```c
int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    while (1);
}
```

#### 2. 练习回答

1. RISC-V 硬件加电后最初执行的几条指令位于什么地址？

    加电后最初执行的指令位于地址 `0x1000` 到地址 `0x1010` 。
2. 它们主要完成了哪些功能？

    1.  **准备参数**：
        *   通过 `csrr a0, mhartid` 获取当前 CPU 核心的 ID，并存入 `a0` 寄存器。
        *   通过 `auipc` 和 `addi` 指令计算出的地址，并存入 `a1` 寄存器。
        这两个参数会传递给后续的 OpenSBI 和操作系统内核。
    2.  **加载目标地址**：
        *   通过 `ld t0, 24(t0)` 指令，从一个约定好的内存地址 `0x1018` 加载下一阶段的入口地址（即 OpenSBI 的入口地址 `0x80000000`）到 `t0` 寄存器。
    3.  **移交控制权**：
        *   执行 `jr t0` 指令，将 CPU 的控制权无条件地跳转到 `t0` 寄存器中的地址，即 OpenSBI 的入口，从而完成第一阶段的引导任务。  
 
### 任务三：列出本实验中重要的知识点

&emsp;&emsp;注意到，在entry.S中存在`.align PGSHIFT`指令，这条指令的作用是将代码段的起始地址对齐到4K的边界，以便于后续的页表映射。`PGSHIFT` 是一个宏定义，在`mmu.h`中设置为12，表示页大小的对数（以 2 为底）。同时也能看到`PGSIZE`为4096，表示页大小为 4KB（$2^{12}$）。

&emsp;&emsp;不妨回顾一下页大小为4KB的推导过程：32位系统上，页表项PTE大小为4B，在二级页表情况下，设`PGSIZE`为n个字节，则第一级页表和第二级页表均有$log_2(2^n/4)=n-2$个页表项，根据二级页表找到物理页后，需要根据页偏移地址计算出物理地址，这需要$n$位完成(页大小)。于是可以得到表达式$(n-2)+(n-2)+n=32$，得到$n=12$，于是我们得到了页大小为4KB。