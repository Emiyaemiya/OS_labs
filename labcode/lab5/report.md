# 操作系统 Lab 5 实验报告

## 练习 0：填写已有实验

本实验依赖于 Lab 2/3/4。在 `kern/process/proc.c` 的 `alloc_proc` 函数中，我们需要初始化进程控制块（PCB）。除了 Lab 4 中初始化的字段（如 `state`, `pid`, `kstack` 等），Lab 5 还需要初始化用于进程管理的字段。

### 代码实现与讲解
在 `alloc_proc` 函数中，我们补充了以下初始化代码：

```c
// Lab 5 新增初始化
proc->wait_state = 0;      // 初始化等待状态，表示当前没有在等待子进程
proc->cptr = NULL;         // 子进程指针初始化为空
proc->optr = NULL;         // 兄弟进程指针初始化为空
proc->yptr = NULL;         // 较年轻的兄弟进程指针初始化为空
```

**讲解**：
这些字段构成了进程树的核心结构：
*   `cptr` (Child Pointer): 指向该进程的第一个子进程。
*   `optr` (Older Sibling Pointer): 指向比该进程创建更早的兄弟进程。
*   `yptr` (Younger Sibling Pointer): 指向比该进程创建更晚的兄弟进程。
这些指针使得内核能够高效地遍历进程家族树，这对于 `do_wait`（回收子进程）和 `do_exit`（父进程退出时接管其子进程）等操作至关重要。

## 练习 1: 加载应用程序并执行

### 1. 设计实现过程 (`load_icode`)

`load_icode` 的主要功能是将 ELF 格式的二进制程序加载到用户空间，并设置好进程的 Trapframe，以便进程返回用户态时能从正确的入口点开始执行。

### 代码实现与讲解

我们需要在 `load_icode` 函数的最后补充设置 Trapframe 的代码：

```c
    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
    
    // 设置用户栈顶
    tf->gpr.sp = USTACKTOP;
    // 设置程序入口地址
    tf->epc = elf->e_entry;
    
    // 设置状态寄存器
    // SSTATUS_SPP = 0: 确保 sret 返回时进入 User Mode (0) 而不是 Supervisor Mode (1)
    // SSTATUS_SPIE = 1: 开启用户态下的中断，允许进程在运行时响应中断
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE | SSTATUS_SIE);
    tf->status |= SSTATUS_SPIE;
```

**讲解**：
*   **`tf->gpr.sp = USTACKTOP`**: 用户程序在用户态运行时需要栈来保存局部变量和函数调用链。我们在前面的步骤中已经建立了 `[USTACKTOP - USTACKSIZE, USTACKTOP)` 的虚拟内存映射，这里将栈指针 SP 指向栈顶。
*   **`tf->epc = elf->e_entry`**: `epc` (Exception Program Counter) 决定了 `sret` 指令执行后 CPU 跳转的地址。这里将其设置为 ELF Header 中记录的程序入口点。
*   **`tf->status`**: 这是最关键的一步。
    *   清除 `SSTATUS_SPP` 位：SPP (Previous Privilege) 记录了进入 Trap 前的特权级。将其设为 0，意味着 `sret` 后 CPU 将切换到 User Mode。
    *   设置 `SSTATUS_SPIE` 位：SPIE (Previous Interrupt Enable) 记录了进入 Trap 前的中断使能状态。将其设为 1，确保用户程序运行时 CPU 能够响应时钟中断（用于调度）和外部中断。

### 2. 执行流程描述

从 `ucore` 选择该进程占用 CPU 到执行第一条指令的经过：

1.  **调度**：`schedule()` 函数根据调度算法选择该进程（`proc`），调用 `proc_run(proc)`。
2.  **上下文切换**：`proc_run` 调用 `switch_to`，切换 CPU 上下文（寄存器状态）到新进程的内核栈。
3.  **返回用户态准备**：新进程从 `forkret` 开始执行（因为 `context.ra` 指向 `forkret`），调用 `forkrets(current->tf)`。
4.  **恢复中断帧**：`forkrets` 跳转到 `__trapret`（在 `trapentry.S` 中），从 `current->tf` 中恢复通用寄存器和 CSR 寄存器（包括 `sstatus` 和 `sepc`）。
5.  **模式切换**：执行 `sret` 指令。CPU 根据 `sstatus.SPP=0` 切换到用户模式，跳转到 `sepc` 指向的地址（即应用程序入口）。
6.  **执行**：CPU 开始执行应用程序的第一条指令。

## 练习 2: 父进程复制自己的内存空间给子进程

### 1. 设计实现过程 (`do_fork`)

`do_fork` 是创建新进程的核心函数。在 Lab 5 中，它不仅要复制内存和上下文，还需要维护进程树关系（父子、兄弟链表）。

**代码实现与讲解**：

```c
    // 1. 分配并初始化进程控制块 (alloc_proc)
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
    }
    proc->parent = current; // 设置父进程
    assert(current->wait_state == 0); // 确保父进程当前没有处于等待状态

    // 2. 分配内核栈 (setup_kstack)
    if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_proc;
    }

    // 3. 复制或共享内存空间 (copy_mm)
    // 根据 clone_flags 决定是复制 (dup_mmap) 还是共享 (share)
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }

    // 4. 设置中断帧和上下文 (copy_thread)
    // 设置子进程的 trapframe 和 context (ra 指向 forkret, sp 指向内核栈顶)
    copy_thread(proc, stack, tf);

    // 5. 插入进程链表和哈希表
    bool intr_flag;
    local_intr_save(intr_flag); // 关中断保证原子性
    {
        proc->pid = get_pid();
        hash_proc(proc);
        set_links(proc); // Lab 5 关键：设置进程树关系 (cptr, yptr, optr)
    }
    local_intr_restore(intr_flag);

    // 6. 唤醒子进程
    wakeup_proc(proc);

    // 7. 返回子进程 PID
    ret = proc->pid;
```

**讲解**：
*   **`assert(current->wait_state == 0)`**: 确保当前进程（父进程）在 fork 子进程时，没有处于等待状态（例如正在等待另一个子进程退出）。这是一个重要的状态检查，防止逻辑错误。
*   **`set_links(proc)`**：这是 Lab 5 中非常重要的一步。它将新进程插入到父进程的子进程链表 (`cptr`) 中，并维护兄弟进程链表 (`optr`, `yptr`)。这确保了操作系统能够正确追踪进程间的关系，从而实现 `wait`（父进程等待子进程退出）和 `exit`（父进程退出时将子进程过继给 init 进程）的功能。

### 2. 设计实现过程 (`copy_range`)

`do_fork` 调用 `copy_mm`，进而调用 `dup_mmap`，最终通过 `copy_range` 复制内存。

### 代码实现与讲解

在 `kern/mm/pmm.c` 的 `copy_range` 函数中，我们实现了内存复制逻辑。这里展示了支持 COW 的改进版本：

```c
            // get page from ptep
            struct Page *page = pte2page(*ptep);
            int ret = 0;
            
            // 如果开启了共享 (COW)
            if (share) {
                // 1. 清除写权限，标记为 COW
                perm = (perm & ~PTE_W) | PTE_COW;
                
                // 2. 重新映射父进程的页表项（更新权限）
                page_insert(from, page, start, perm);
                
                // 3. 映射子进程的页表项（指向同一个物理页）
                ret = page_insert(to, page, start, perm);
            } else {
                // 非 COW 模式：深拷贝
                struct Page *npage = alloc_page();
                assert(page != NULL);
                assert(npage != NULL);
                
                // 获取内核虚拟地址进行内存拷贝
                void *src_kvaddr = page2kva(page);
                void *dst_kvaddr = page2kva(npage);
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
                
                // 建立映射
                ret = page_insert(to, npage, start, perm);
            }
```

**讲解**：
*   **非 COW 模式**：这是最基础的实现。父进程有物理页 A，我们为子进程分配物理页 B，然后把 A 的内容完全拷贝给 B。这样父子进程互不干扰，但内存消耗大，拷贝耗时。
*   **COW 模式**：我们不分配新页，而是让子进程的 PTE 也指向物理页 A。关键在于**权限控制**：我们将父子进程对该页的权限都设为**只读** (`~PTE_W`)，并打上 `PTE_COW` 标记。这样，当任一进程试图写入时，CPU 会触发缺页异常，内核就能捕获这个写操作并进行“延迟拷贝”。

### 3. Copy on Write (COW) 机制设计

**概要设计**：
COW 是一种推迟内存复制的优化策略。父子进程在 fork 时不立即复制物理内存，而是共享同一份物理页，并将这些页标记为“只读”。只有当任一进程尝试写入时，才触发缺页异常，进行真正的物理页复制。

**详细设计与实现**：

1.  **标记共享 (`copy_range`)**：
    *   在 `fork` 时，`copy_range` 不分配新页。
    *   将父子进程的 PTE 都指向同一个物理页。
    *   **关键点**：将 PTE 的写权限 (`PTE_W`) 清除，并设置自定义的 `PTE_COW` 标志位（利用 RISC-V PTE 的保留位，如 RSW 位）。
    *   增加物理页的引用计数 (`page_ref_inc`)。

2.  **处理写异常 (`do_pgfault`)**：
    *   当进程尝试写入这些只读页面时，CPU 触发 `Store/AMO Page Fault`。
    *   在 `do_pgfault` 中检测异常原因：如果是写异常且 PTE 中有 `PTE_COW` 标志。
    *   **处理逻辑**：
        *   如果 `page_ref > 1`（共享中）：分配新物理页，拷贝原页内容，将新页映射到当前进程地址，设置 `PTE_W`，清除 `PTE_COW`，原页引用计数减 1。
        *   如果 `page_ref == 1`（独占）：说明其他进程已经释放或拷贝了该页，当前进程直接恢复 `PTE_W`，清除 `PTE_COW` 即可。

## 练习 3: 阅读分析源代码

### 1. fork/exec/wait/exit 分析

*   **fork**：
    *   **执行流程**：用户态调用 `fork()` -> `ecall` -> `trap` -> `sys_fork` -> `do_fork`。
    *   **内核操作**：分配 PCB，分配内核栈，复制内存 (`copy_mm`)，复制上下文 (`copy_thread`)，加入进程链表，唤醒子进程。
    *   **返回**：父进程返回子进程 PID，子进程返回 0（通过修改 `tf->gpr.a0`）。

*   **exec**：
    *   **执行流程**：用户态调用 `exec()` -> ... -> `do_execve`。
    *   **内核操作**：检查文件名，回收当前进程内存 (`exit_mmap`)，加载新程序 (`load_icode`)，设置新 Trapframe。
    *   **返回**：不返回原程序，而是从新程序的入口点开始执行。

*   **wait**：
    *   **执行流程**：用户态调用 `wait()` -> ... -> `do_wait`。
    *   **内核操作**：查找状态为 `ZOMBIE` 的子进程。如果找到，回收其剩余资源（PCB、内核栈），返回 PID。如果子进程还在运行，父进程进入 `SLEEPING` 状态等待。

*   **exit**：
    *   **执行流程**：用户态调用 `exit()` -> ... -> `do_exit`。
    *   **内核操作**：回收页表和内存 (`mm_destroy`)，将状态设为 `ZOMBIE`，唤醒父进程，主动调度 (`schedule`)。

**内核态与用户态交错**：
程序在用户态执行，遇到系统调用或中断时，硬件自动保存现场并跳转到内核态中断处理程序。内核处理完毕后，恢复现场并执行 `sret` 返回用户态。

### 2. 进程生命周期图

```text
      (alloc_proc)          (wakeup_proc)
UNINIT ------------> RUNNABLE <----------> RUNNING
                        ^    (schedule)      |
                        |                    | (do_wait/do_sleep)
                        |                    v
                        +--------------- SLEEPING
                        |
    (do_exit)           |
RUNNING ----------------> ZOMBIE ------------> DEAD
                                (kfree proc)
```

## 扩展练习 Challenge: Copy on Write 实现

### 1. 实现源码说明
我在 `kern/mm/pmm.c` 和 `kern/mm/vmm.c` 中实现了 COW。

**`libs/riscv.h`**:
```c
#define PTE_COW 0x100  // 定义 COW 标志位，使用 RSW (Reserved for Software) 位
```

**`kern/mm/vmm.c` - `do_pgfault`**:
这是 COW 的核心处理逻辑。同时，我们需要确保在处理缺页异常时，根据 VMA 的属性正确设置页表项的权限（特别是执行权限 `PTE_X`）：

```c
    // 根据 VMA 属性设置权限
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
    }
    if (vma->vm_flags & VM_READ) {
        perm |= PTE_R;
    }
    if (vma->vm_flags & VM_EXEC) {
        perm |= PTE_X; // 关键：确保可执行权限
    }

    // ...

    } else {
        // 检查是否为 COW 页面
        if (*ptep & PTE_COW) {
            struct Page *page = pte2page(*ptep);
            // 如果引用计数 > 1，说明还有其他进程共享此页
            if (page_ref(page) > 1) {
                struct Page *npage = alloc_page(); // 分配新页
                if (npage == NULL) {
                    goto failed;
                }
                // 复制内容
                memcpy(page2kva(npage), page2kva(page), PGSIZE);
                // 建立新映射：可写，无 COW 标志
                if (page_insert(mm->pgdir, npage, addr, perm) != 0) {
                    free_page(npage);
                    goto failed;
                }
            } else {
                // 如果引用计数 == 1，说明只剩当前进程在使用，直接恢复写权限
                *ptep &= ~PTE_COW;
                *ptep |= PTE_W;
                tlb_invalidate(mm->pgdir, addr); // 刷新 TLB
            }
        } else {
            cprintf("ptep is %x, but no swap support, failed\n",*ptep);
            goto failed;
        }
   }
```

**注意**：在 `do_pgfault` 中，必须根据 `vma->vm_flags` 正确设置 `perm`。如果忽略了 `VM_EXEC` 到 `PTE_X` 的映射，那么当程序尝试执行该页面上的指令时，会再次触发 Instruction Page Fault，导致死循环。这是 Lab 5 中容易被忽视的一个细节。

### 2. Dirty COW 漏洞分析
**Dirty COW (CVE-2016-5195)** 是 Linux 内核的一个竞争条件漏洞。
*   **原理**：COW 的过程通常是：(1) 检查页是否共享 -> (2) 如果共享，分配新页并复制 -> (3) 替换页表项。
*   **漏洞点**：在多线程环境下，如果步骤 (1) 和 (3) 之间，另一个线程通过 `madvise(MADV_DONTNEED)` 丢弃了该页的映射，导致步骤 (3) 写入时重新从磁盘加载（或重新获取）了**原始的只读页**，并且错误地赋予了写权限。这使得攻击者可以修改只读文件（如 `/etc/passwd`）。
*   **ucore 中的模拟**：在当前的 ucore Lab 5 环境中，由于是单核且内核不可抢占（大部分时间），很难直接复现这种竞争条件。要模拟它，需要在 `do_pgfault` 的关键路径（检查 COW 和写入页表之间）人为插入延时或调度点，并构造并发线程尝试修改内存映射。

## 问题回答：用户程序预加载

**问题**：该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？

**回答**：
1.  **何时加载**：
    在 Lab 5 中，用户程序（如 `spin`, `exit`）是在**编译内核时**直接链接到内核镜像（Kernel Image）中的。通过宏 `KERNEL_EXECVE`，利用链接器生成的符号（如 `_binary_obj___user_spin_out_start`）直接获取程序在内核数据段中的起始地址和大小，然后通过 `load_icode` 拷贝到新进程的内存空间。因此，它们在**系统启动时**就已经随内核一起加载到物理内存中了。

2.  **与常用 OS 的区别**：
    *   **常用 OS**：用户程序存储在磁盘的文件系统中。当执行 `exec` 时，操作系统通过文件系统驱动从磁盘读取 ELF 文件头，按需将代码段和数据段读入内存（通常结合缺页中断机制）。
    *   **ucore Lab 5**：没有完整的文件系统支持，程序作为静态数据“内嵌”在内核里。

3.  **原因**：
    这是为了简化实验难度。在 Lab 5 阶段，我们主要关注进程管理和虚拟内存，尚未实现完善的文件系统（这是 Lab 8 的内容）。将程序直接链接进内核可以避免处理复杂的磁盘 I/O 和文件系统接口。
