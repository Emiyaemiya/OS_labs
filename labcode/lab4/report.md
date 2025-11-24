# <center>lab04实验报告</center>

## 练习1：分配并初始化一个进程控制块

alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

### 1. 代码实现

我们实验补全的alloc_proc函数实现代码如下：

```c
static struct proc_struct *
alloc_proc(void)
{
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL)
    {
        memset(proc, 0, sizeof(struct proc_struct));
        proc->state = PROC_UNINIT;
        proc->pid = -1;
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&proc->context, 0, sizeof(proc->context));
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
        proc->flags = 0;
        memset(proc->name, 0, sizeof(proc->name));
        list_init(&proc->list_link);
        list_init(&proc->hash_link);        
    }
    return proc;
}
```

### 2. 设计思路

在 `alloc_proc` 函数中，我们需要负责初始化一个新的进程控制块（PCB）。由于 `kmalloc` 分配的内存内容是不确定的，我们首先使用 `memset` 将整块内存清零，以防止未初始化的垃圾数据导致错误。

针对特定成员变量的初始化说明如下：
*   **`state` (进程状态)**：初始化为 `PROC_UNINIT`，表示该进程尚处于未初始化完成的状态，还不能被调度。
*   **`pid` (进程ID)**：初始化为 -1。因为 0 号 PID 通常预留给 `idle` 进程，且合法的 PID 都是正数，-1 表示尚未分配有效的 PID。
*   **`cr3` / `pgdir` (页目录基址)**：对于内核线程，它们共享内核的地址空间，因此直接指向内核页表 `boot_pgdir_pa`。
*   **`kstack` (内核栈)**：初始化为 0，表示尚未分配内核栈。
*   **`context` (上下文)**：清零。该结构体将在后续的 `copy_thread` 中被进一步设置（如设置 `ra` 为 `forkret`）。
*   **`tf` (中断帧指针)**：初始化为 NULL。它将在 `copy_thread` 中指向内核栈的顶部。
*   **链表节点**：调用 `list_init` 初始化 `list_link` 和 `hash_link`，防止链表操作时访问非法指针。

### 3. 问题回答：context 和 tf 的含义与作用

在 `proc_struct` 结构中，`struct context context` 和 `struct trapframe *tf` 都用于保存进程的执行状态，但它们的作用时机和保存的内容有所不同：

1.  **`struct context context` (内核上下文)**：
    *   **含义**：保存了进程在内核态进行上下文切换（Context Switch）时所需的寄存器状态。主要包括 **被调用者保存（Callee-saved）** 的寄存器（如 `s0`-`s11`, `ra`, `sp`）。
    *   **作用**：当调度器调用 `switch_to` 函数切换进程时，CPU 会将当前进程的寄存器保存到其 `context` 中，并从下一个进程的 `context` 中恢复寄存器。
    *   **在本实验中**：对于新创建的进程，`context.ra` 被设置为 `forkret` 的地址，`context.sp` 被设置为 `tf` 的地址。这使得新进程被调度时，能够“跳转”到 `forkret` 函数，进而开始执行。

2.  **`struct trapframe *tf` (中断帧)**：
    *   **含义**：保存了进程在发生中断、异常或系统调用瞬间的 **完整 CPU 状态**。包括所有通用寄存器（`x0`-`x31`）、状态寄存器（`sstatus`）、异常指令地址（`sepc`）等。
    *   **作用**：用于中断处理后的现场恢复。当内核需要从中断返回（`sret`）到用户态或内核态的断点时，会使用 `tf` 中的数据恢复寄存器。
    *   **在本实验中**：
        *   `tf` 指针指向进程内核栈的顶部。
        *   对于新创建的内核线程，`tf` 被用来构造一个“伪造”的中断现场。`forkret` 函数会将 `tf` 中的内容加载到 CPU 中，并通过 `sret` 跳转到 `tf->epc`（即 `kernel_thread_entry`），从而启动线程的执行。
        *   它也用于传递参数（如 `s0` 保存函数指针，`s1` 保存参数）。

**总结**：`context` 用于**进程切换**（内核态函数调用栈的切换），而 `tf` 用于**中断返回**（特权级切换和通用寄存器恢复）。新进程的启动是先通过 `context` 切换到 `forkret`，再通过 `tf` 切换到 `kernel_thread_entry`。
##

## 练习2：为新创建的内核线程分配资源

创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用do_fork函数完成具体内核线程的创建工作。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。

### 1. 代码实现

```c
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
    {
        goto fork_out;
    }
    ret = -E_NO_MEM;

    // 1. 分配并初始化进程控制块
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
    }
    
    // 2. 分配内核栈
    if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_proc;
    }
    
    // 3. 复制/共享内存管理信息 (内核线程为空操作)
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
    
    // 4. 设置中断帧和上下文
    copy_thread(proc, stack, tf);
    
    // 5. 分配PID并加入进程链表 (需要原子操作)
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
        hash_proc(proc);
        list_add(&proc_list, &(proc->list_link));
        nr_process++;
    }
    local_intr_restore(intr_flag);
    
    // 6. 唤醒新进程
    wakeup_proc(proc);
    
    // 7. 返回新进程的PID
    ret = proc->pid;
    
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

### 2. 设计思路

`do_fork` 函数是创建新进程/线程的核心，其执行流程如下：

1.  **资源分配**：首先调用 `alloc_proc` 分配一个 PCB。如果失败直接返回。
2.  **内核栈分配**：调用 `setup_kstack` 为新进程分配 2 页（8KB）的内核栈空间。这是每个进程独立拥有的，用于保存内核态执行时的栈帧。
3.  **内存复制**：调用 `copy_mm`。对于内核线程（`CLONE_VM` 被设置），我们不需要复制页表，因为内核线程共享内核地址空间。
4.  **线程上下文设置**：调用 `copy_thread`。这是关键步骤：
    *   它在内核栈的顶部预留了 `struct trapframe` 的空间，并将父进程的 `tf` 复制进去。
    *   设置 `tf->gpr.a0 = 0`，这样子进程在 `fork` 返回时会得到返回值 0。
    *   设置 `proc->context.ra = forkret` 和 `proc->context.sp = tf`。这确保了新进程被调度时，会从 `forkret` 开始执行。
5.  **加入进程集合**：
    *   调用 `get_pid` 获取唯一的 PID。
    *   将进程加入全局链表 `proc_list` 和哈希表 `hash_list`。
    *   **注意**：这一步涉及对全局共享数据结构的修改，必须使用 `local_intr_save/restore` 关闭中断，防止并发竞争（Race Condition）。
6.  **唤醒进程**：调用 `wakeup_proc` 将进程状态设置为 `PROC_RUNNABLE`，使其可以被调度器选中。

### 3. 问题回答：ucore 是否给每个新 fork 的线程一个唯一的 ID？

**结论**：是的，ucore 能够保证给每个新 fork 的线程分配一个唯一的 PID。

**分析与理由**：

1.  **PID 分配算法 (`get_pid`)**：
    *   ucore 使用 `get_pid` 函数来分配 PID。该函数维护了两个静态变量 `last_pid` (上一次分配的 PID) 和 `next_safe` (下一个已占用 PID 的边界)。
    *   算法会尝试简单的自增 `last_pid`。如果 `last_pid` 小于 `next_safe`，则直接分配，这保证了在一段连续空闲区间内的分配是 O(1) 的且唯一的。
    *   如果 `last_pid` 超过了 `next_safe`，算法会遍历整个 `proc_list` 链表，寻找下一个合法的空闲 PID，并更新 `next_safe`。这确保了即使发生回绕（Wrap-around），也不会分配出重复的 PID。

2.  **并发保护**：
    *   在 `do_fork` 中，调用 `get_pid` 以及将进程加入链表的操作被包裹在 `local_intr_save(intr_flag)` 和 `local_intr_restore(intr_flag)` 之间。
    *   这关闭了中断，保证了在分配 PID 和插入链表这一系列操作的原子性。即使在多进程环境下（虽然 Lab4 主要是单核），也不会出现两个进程同时拿到同一个 PID 的情况。

3.  **唯一性验证**：
    *   `get_pid` 内部的遍历逻辑显式地检查了 `proc->pid == last_pid` 的冲突情况。
    *   此外，`find_proc` 函数可以通过 PID 在哈希表中查找进程，如果 PID 分配机制失效，哈希表冲突也会暴露问题，但 `get_pid` 的逻辑从根本上避免了这种情况。

## 练习3：编写 proc_run 函数

### 1. 设计思路

`proc_run` 函数的主要作用是将 CPU 的控制权从当前进程（`current`）切换到指定的进程（`proc`）。其核心流程如下：

1.  **检查是否需要切换**：首先判断要切换的目标进程 `proc` 是否就是当前正在运行的进程 `current`。如果是，则无需进行任何操作，直接返回。
2.  **屏蔽中断**：为了保证进程切换过程的原子性，避免在切换过程中被中断打断导致状态不一致，需要先调用 `local_intr_save(intr_flag)` 关闭中断。
3.  **更新当前进程指针**：将 `current` 指针指向新的进程控制块 `proc`。
4.  **切换页表**：调用 `lsatp(next->pgdir)` 切换页表基址寄存器（SATP）。这使得 CPU 开始使用新进程的地址空间（虽然在 Lab4 中所有内核线程共用内核页表 `boot_pgdir`，但这一步是为后续实验和用户进程打基础）。
5.  **上下文切换**：调用汇编函数 `switch_to(&(prev->context), &(next->context))`。
    *   该函数会保存当前进程 `prev` 的寄存器状态（ra, sp, s0-s11）到 `prev->context` 中。
    *   然后从 `next->context` 中恢复新进程的寄存器状态。
    *   最后执行 `ret` 指令，跳转到新进程的 `ra` 指向的代码处（对于新创建的进程是 `forkret`，对于旧进程是 `switch_to` 返回后的指令）。
6.  **恢复中断**：上下文切换完成后（此时 CPU 已经在运行新进程的代码了），调用 `local_intr_restore(intr_flag)` 恢复中断状态。

### 2. 代码实现

```c
void proc_run(struct proc_struct *proc) {
    if (proc != current) {
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(intr_flag);
        {
            current = proc;
            lsatp(next->pgdir);
            switch_to(&(prev->context), &(next->context));
        }
        local_intr_restore(intr_flag);
    }
}
```

### 3. 问题回答

**问题：在本实验的执行过程中，创建且运行了几个内核线程？**

在本实验中，总共创建并运行了 **2** 个内核线程。
1.  **第 0 号内核线程 (`idleproc`)**：
    *   **创建**：在 `proc_init` 函数中，通过 `alloc_proc` 手动创建了第一个内核线程 `idleproc`。
    *   **初始化**：它的 `pid` 被设为 0，状态被设为 `PROC_RUNNABLE`，内核栈指向 `bootstack`。
    *   **运行**：`proc_init` 执行完后，内核直接将 `current` 指向 `idleproc`，并由 `kern_init` 继续执行到 `cpu_idle` 函数。`idleproc` 是系统启动后的第一个进程，也是调度器的“保底”进程。

2.  **第 1 号内核线程 (`initproc`)**：
    *   **创建**：在 `proc_init` 函数中，调用 `kernel_thread` 创建。`kernel_thread` 内部调用 `do_fork`，从 `idleproc` 复制并创建了 `initproc`。
    *   **初始化**：它的 `pid` 被分配为 1，执行函数为 `init_main`。
    *   **运行**：当 `idleproc` 执行 `cpu_idle` 并调用 `schedule` 时，调度器发现 `initproc` 处于就绪状态，于是调用 `proc_run` 切换到 `initproc`。`initproc` 随后开始执行 `init_main` 函数，打印 "Hello world!!"。

因此，整个执行流程中涉及了 `idleproc` (pid=0) 和 `initproc` (pid=1) 这两个内核线程。

##

## 扩展练习：

### 1. 说明语句 local_intr_save(intr_flag);....local_intr_restore(intr_flag); 是如何实现开关中断的？

`local_intr_save` 和 `local_intr_restore` 是 uCore 中用于保护临界区（Critical Section）的一对宏，它们通过保存当前中断状态并关闭中断，以及恢复之前保存的中断状态，来实现原子操作。

**实现原理：**

1.  **`local_intr_save(x)`**：
    *   该宏展开后调用 `__intr_save()`。
    *   `__intr_save` 首先使用 `read_csr(sstatus)` 读取当前的 `sstatus` 寄存器，检查 `SSTATUS_SIE`（Supervisor Interrupt Enable）位。
    *   如果 `SIE` 位为 1（表示中断开启），则调用 `intr_disable()`（即 `clear_csr(sstatus, SSTATUS_SIE)`）将该位清零，从而关闭中断，并返回 1。
    *   如果 `SIE` 位为 0（表示中断已关闭），则直接返回 0。
    *   返回的状态值被保存在变量 `x`（即 `intr_flag`）中。

2.  **`local_intr_restore(x)`**：
    *   该宏展开后调用 `__intr_restore(x)`。
    *   `__intr_restore` 检查传入的标志位 `x`。
    *   如果 `x` 为 1（表示进入临界区前中断是开启的），则调用 `intr_enable()`（即 `set_csr(sstatus, SSTATUS_SIE)`）将 `SIE` 位置 1，重新开启中断。
    *   如果 `x` 为 0，则不做任何操作，保持中断关闭状态。

这种设计（Save/Restore）优于简单的 Disable/Enable，因为它支持**嵌套调用**。如果函数 A 关了中断调用函数 B，函数 B 也关中断。如果 B 返回时直接开中断，就会破坏 A 的原子性保护。使用 Save/Restore 机制，B 发现进入时中断已经是关的（flag=0），返回时就不会错误地打开中断，从而保证了中断只在最外层被重新开启。

### 2. 深入理解不同分页模式的工作原理

#### (1) get_pte()函数中有两段形式类似的代码，结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。

在 uCore Lab4 中，我们使用的是 RISC-V 的 **Sv39** 分页模式。Sv39 采用 **3 级页表**结构：

`get_pte` 的任务是找到（或创建）指向最终物理页的 Level 0 页表项。为了到达 Level 0，它必须逐级向下遍历。

*   **第一段代码**：处理 **Level 2 -> Level 1** 的过渡。检查 Level 2 表项是否有效，如果无效且允许创建，则分配一个物理页作为 Level 1 页表。
*   **第二段代码**：处理 **Level 1 -> Level 0** 的过渡。检查 Level 1 表项是否有效，如果无效且允许创建，则分配一个物理页作为 Level 0 页表。

**为什么相像？**
因为多级页表的本质是**递归**的。每一级页表（除了最后一级）都存储着下一级页表的物理地址。无论是在哪一级，查找下一级的逻辑都是一致的：
1.  根据虚拟地址的索引找到当前级的页表项 (PTE)。
2.  检查 PTE 的有效位 (PTE_V)。
3.  如果无效，根据 `create` 标志决定是否分配新的物理页并初始化。
4.  获取下一级页表的基址。

**结合 Sv32/Sv39/Sv48 的异同：**
*   **Sv32** (2级页表)：只需要一段这样的逻辑（PD -> PT）。
*   **Sv39** (3级页表)：需要两段这样的逻辑（PDPT -> PD -> PT），正是代码中呈现的样子。
*   **Sv48** (4级页表)：需要三段这样的逻辑（PML4 -> PDPT -> PD -> PT）。

这两段代码的重复，正是 Sv39 三级页表结构在代码层面的直接体现。

#### (2) 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

**我认为这种写法是好的，没有必要拆开。**

**理由如下：**

1.  **符合使用场景**：在内核内存管理中，`get_pte` 的使用场景高度集中在两种情况：
    *   **建立映射**（如 `page_insert`）：需要查找，如果不存在则必须创建。
    *   **查询/解除映射**（如 `page_remove`）：只需要查找，不存在则返回 NULL。
    通过一个 `create` 参数，一个函数就能高效地覆盖这两种高频场景，接口设计简洁明了。

2.  **减少代码冗余与性能开销**：
    如果拆分成 `lookup_pte` 和 `alloc_pte`：
    *   `alloc_pte` 的逻辑必然包含 `lookup`（因为要先检查是否存在）。
    *   如果外部调用者先调 `lookup` 失败后再调 `alloc`，会导致对页表的**两次遍历**，增加了不必要的性能开销。
    *   现在的写法在一次遍历中同时完成检查和创建，效率最高。




