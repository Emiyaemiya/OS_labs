# 操作系统实验报告 - Lab6 & Lab8

---

## Lab6: 调度器

### 练习1: 理解调度器框架的实现

#### 1.1 调度类结构体 sched_class 分析

`sched_class` 结构体定义在 `kern/schedule/sched.h` 中：

```c
struct sched_class {
    const char *name;                                    // 调度器名称
    void (*init)(struct run_queue *rq);                  // 初始化运行队列
    void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);  // 入队
    void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);  // 出队
    struct proc_struct *(*pick_next)(struct run_queue *rq);           // 选择下一个进程
    void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc); // 时钟中断处理
};
```

**各函数指针的作用和调用时机：**

| 函数指针 | 作用 | 调用时机 |
|---------|------|---------|
| `init` | 初始化运行队列数据结构 | 系统启动时 `sched_init()` 调用 |
| `enqueue` | 将进程加入就绪队列 | 进程变为就绪状态、时间片用完时 |
| `dequeue` | 将进程从就绪队列移除 | 进程被选中执行时 |
| `pick_next` | 选择下一个要执行的进程 | `schedule()` 中选择新进程时 |
| `proc_tick` | 处理时钟中断对进程的影响 | 每次时钟中断触发时 |

**为什么使用函数指针而不是直接实现？**

1. **解耦设计**：调度框架与具体调度算法分离，框架只调用函数指针，不关心具体实现
2. **易于扩展**：添加新调度算法只需实现 `sched_class` 接口，无需修改框架代码
3. **运行时切换**：理论上可以在运行时动态切换调度算法
4. **代码复用**：多种调度算法可以共用同一个调度框架

#### 1.2 运行队列结构体 run_queue 分析

```c
struct run_queue {
    list_entry_t run_list;              // 链表头
    unsigned int proc_num;              // 就绪进程数
    int max_time_slice;                 // 最大时间片
    skew_heap_entry_t *lab6_run_pool;   // 斜堆（Lab6新增）
};
```

**Lab5 vs Lab6 的 run_queue 差异：**

| 特性 | Lab5 | Lab6 |
|------|------|------|
| 数据结构 | 仅链表 | 链表 + 斜堆 |
| 支持的算法 | 简单 FIFO/RR | RR、Stride、优先级等 |
| 复杂度 | O(n) 查找 | 斜堆 O(log n) |

**为什么需要两种数据结构？**

1. **链表**：适合 RR 算法，O(1) 的头尾操作
2. **斜堆**：适合 Stride/优先级算法，O(log n) 获取最小/最大元素
3. **灵活性**：不同调度算法可选择合适的数据结构

#### 1.3 调度器框架函数分析

**sched_init() 函数：**
```c
void sched_init(void) {
    list_init(&timer_list);
    sched_class = &default_sched_class;  // 选择调度算法
    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);               // 调用具体算法的初始化
}
```

**wakeup_proc() 函数：**
```c
void wakeup_proc(struct proc_struct *proc) {
    if (proc->state != PROC_RUNNABLE) {
        proc->state = PROC_RUNNABLE;
        proc->wait_state = 0;
        if (proc != current) {
            sched_class_enqueue(proc);   // 通过框架入队
        }
    }
}
```

**schedule() 函数：**
```c
void schedule(void) {
    current->need_resched = 0;
    if (current->state == PROC_RUNNABLE) {
        sched_class_enqueue(current);    // 当前进程重新入队
    }
    next = sched_class_pick_next();      // 选择下一个进程
    if (next != NULL) {
        sched_class_dequeue(next);       // 出队
    }
    if (next != current) {
        proc_run(next);                  // 切换进程
    }
}
```

#### 1.4 调度类初始化流程

```
kern_init()
    └── sched_init()
            ├── list_init(&timer_list)      // 初始化定时器链表
            ├── sched_class = &default_sched_class  // 绑定调度算法
            ├── rq->max_time_slice = MAX_TIME_SLICE
            └── sched_class->init(rq)       // 调用 RR_init()
                    ├── list_init(&rq->run_list)
                    └── rq->proc_num = 0
```

#### 1.5 进程调度流程图

```
┌─────────────────┐
│    时钟中断      │
└────────┬────────┘
         ↓
┌─────────────────┐
│ trap_dispatch() │
└────────┬────────┘
         ↓
┌─────────────────┐
│run_timer_list() │
└────────┬────────┘
         ↓
┌─────────────────────────┐
│ sched_class_proc_tick() │  ← 调用 RR_proc_tick()
│   proc->time_slice--    │
│   if (time_slice == 0)  │
│     need_resched = 1    │
└────────┬────────────────┘
         ↓
┌─────────────────┐
│ 中断返回前检查   │
│ need_resched?   │
└────────┬────────┘
         ↓ (yes)
┌─────────────────┐
│   schedule()    │
├─────────────────┤
│ 1. enqueue(cur) │  ← 当前进程入队
│ 2. pick_next()  │  ← 选择下一个
│ 3. dequeue(next)│  ← 新进程出队
│ 4. proc_run()   │  ← 切换执行
└─────────────────┘
```

**need_resched 标志位的作用：**
- 延迟调度决策：不在中断处理中直接调度，而是设置标志
- 在中断返回前检查标志，决定是否调用 `schedule()`
- 避免在中断上下文中进行复杂的进程切换

#### 1.6 调度算法切换机制

**添加新调度算法的步骤：**

1. 创建新文件（如 `sched_new.c`）
2. 实现 `sched_class` 的所有函数接口
3. 定义 `struct sched_class new_sched_class`
4. 在 `sched.c` 中声明并选择新调度器

**为什么切换容易？**
- 调度框架通过函数指针调用，与具体实现解耦
- 只需修改 `sched_init()` 中的一行赋值语句
- 新算法无需修改任何框架代码

---

### 练习2: 实现 Round Robin 调度算法

#### 2.1 Lab5 vs Lab6 函数差异比较

以 `sched.c` 中的 `schedule()` 函数为例：

**Lab5 实现：**
```c
void schedule(void) {
    list_entry_t *le, *last;
    // 直接遍历进程链表查找下一个就绪进程
    le = last = &(current->list_link);
    do {
        le = list_next(le);
        if (le != &proc_list) {
            next = le2proc(le, list_link);
            if (next->state == PROC_RUNNABLE) break;
        }
    } while (le != last);
}
```

**Lab6 实现：**
```c
void schedule(void) {
    if (current->state == PROC_RUNNABLE) {
        sched_class_enqueue(current);    // 通过调度类入队
    }
    next = sched_class_pick_next();      // 通过调度类选择
    if (next != NULL) {
        sched_class_dequeue(next);
    }
    proc_run(next);
}
```

**为什么要做这个改动？**
- Lab5 直接遍历进程链表，调度算法硬编码在 `schedule()` 中
- Lab6 通过调度类接口间接调用，实现了调度算法的可插拔
- 不做改动的问题：无法轻松切换调度算法，代码耦合度高

#### 2.2 RR 算法实现

**RR_init：初始化运行队列**
```c
static void RR_init(struct run_queue *rq) {
    list_init(&(rq->run_list));  // 初始化链表头
    rq->proc_num = 0;            // 进程数置零
}
```

**RR_enqueue：进程入队**
```c
static void RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    assert(list_empty(&(proc->run_link)));
    list_add_before(&(rq->run_list), &(proc->run_link));  // 添加到队尾
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;  // 重置时间片
    }
    proc->rq = rq;
    rq->proc_num++;
}
```

**设计思路：**
- 使用 `list_add_before` 添加到链表尾部（run_list 是循环链表头）
- 时间片为 0 或超过最大值时重置
- 维护 `proc_num` 计数

**RR_dequeue：进程出队**
```c
static void RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
    list_del_init(&(proc->run_link));  // 从链表删除
    rq->proc_num--;
}
```

**RR_pick_next：选择下一个进程**
```c
static struct proc_struct *RR_pick_next(struct run_queue *rq) {
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {
        return le2proc(le, run_link);  // 返回队首进程
    }
    return NULL;  // 队列为空
}
```

**RR_proc_tick：时钟中断处理**
```c
static void RR_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0) {
        proc->time_slice--;      // 减少时间片
    }
    if (proc->time_slice == 0) {
        proc->need_resched = 1;  // 标记需要重新调度
    }
}
```

#### 2.3 边界情况处理

| 边界情况 | 处理方式 |
|---------|---------|
| 空队列 | `pick_next` 返回 NULL |
| 时间片为 0 | `enqueue` 时重置为 max_time_slice |
| 空闲进程 | `sched_class_proc_tick` 中特殊处理 |

#### 2.4 RR 调度算法优缺点

**优点：**
- 实现简单，O(1) 入队出队
- 公平性好，每个进程获得相等的 CPU 时间
- 响应时间有保证，最多等待 (n-1) × 时间片
- 无饥饿问题

**缺点：**
- 上下文切换开销大
- 不区分进程优先级
- 时间片大小难以选择

**时间片大小的影响：**
- **太大**：退化为 FIFO，响应时间变长
- **太小**：上下文切换频繁，吞吐量下降
- **建议**：10-100ms，根据系统类型调整

**为什么在 RR_proc_tick 中设置 need_resched？**
- 延迟调度决策到中断返回时
- 避免在中断处理中进行进程切换
- 保证中断处理的原子性

#### 2.5 扩展思考

**实现优先级 RR 调度：**
```c
// 1. 使用斜堆或多级链表存储
// 2. enqueue 时按优先级插入
// 3. pick_next 选择最高优先级进程
static int priority_compare(skew_heap_entry_t *a, skew_heap_entry_t *b) {
    struct proc_struct *p = le2proc(a, lab6_run_pool);
    struct proc_struct *q = le2proc(b, lab6_run_pool);
    return q->lab6_priority - p->lab6_priority;
}
```

**多核调度支持：**
当前实现不支持多核，需要改进：
1. 每个 CPU 有独立的运行队列
2. 添加自旋锁保护共享数据
3. 实现负载均衡机制
4. 考虑缓存亲和性

---

### 扩展练习 Challenge 1: Stride Scheduling

#### 3.1 Stride 算法设计实现

**核心思想：**
- 每个进程有一个 stride 值（步幅）
- 每次选择 stride 最小的进程执行
- 执行后 stride += BIG_STRIDE / priority
- 优先级高的进程 stride 增长慢，被调度更频繁

**关键代码：**
```c
#define BIG_STRIDE (1 << 30)

static struct proc_struct *stride_pick_next(struct run_queue *rq) {
    if (rq->lab6_run_pool == NULL) return NULL;
    struct proc_struct *proc = le2proc(rq->lab6_run_pool, lab6_run_pool);
    proc->lab6_stride += BIG_STRIDE / proc->lab6_priority;
    return proc;
}
```

#### 3.2 多级反馈队列（MLFQ）设计

**概要设计：**
```c
#define MLFQ_LEVELS 3
static list_entry_t mlfq_queues[MLFQ_LEVELS];  // 3 级队列
static int time_slices[MLFQ_LEVELS] = {2, 4, 8};  // 时间片递增

// 规则1: 新进程进入最高优先级队列
// 规则2: 时间片用完降级
// 规则3: 定期提升所有进程优先级（防止饥饿）
```

**详细设计：**
- 队列 0：时间片 2，最高优先级，交互式进程
- 队列 1：时间片 4，中等优先级
- 队列 2：时间片 8，最低优先级，CPU 密集型

#### 3.3 Stride 算法正比性证明

**证明思路：**

设进程 A 优先级为 $p_A$，进程 B 优先级为 $p_B$

每次执行后：
- $stride_A += \frac{BIG\_STRIDE}{p_A}$

- $stride_B += \frac{BIG\_STRIDE}{p_B}$

经过足够长时间 T，设 A 被调度 $n_A$ 次，B 被调度 $n_B$ 次

由于 Stride 算法总是选择 stride 最小的进程，长期来看各进程 stride 趋于相等：

$$n_A \times \frac{BIG\_STRIDE}{p_A} \approx n_B \times \frac{BIG\_STRIDE}{p_B}$$

化简得：

$$\frac{n_A}{n_B} = \frac{p_A}{p_B}$$

即**调度次数与优先级成正比**。

---

### 扩展练习 Challenge 2: 实现多种调度算法并定量分析

#### 4.1 实现的调度算法概述

在 uCore 中实现了以下 **6 种调度算法**：

| 算法 | 文件 | 数据结构 | 抢占式 | 复杂度 |
|------|------|----------|--------|--------|
| RR (Round Robin) | default_sched.c | 链表 | 是 | O(1) |
| Stride | default_sched_stride.c | 斜堆 | 是 | O(log n) |
| FIFO | sched_FIFO.c | 链表 | 否 | O(1) |
| SJF | sched_SJF.c | 斜堆 | 否 | O(log n) |
| Priority | sched_Priority.c | 斜堆 | 是 | O(log n) |
| MLFQ | sched_MLFQ.c | 多级链表 | 是 | O(1) |

#### 4.2 各算法详细实现

##### 4.2.1 FIFO（先来先服务）

```c
/* FIFO 入队：添加到队列尾部 */
static void FIFO_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    list_add_before(&(rq->run_list), &(proc->run_link));
    proc->time_slice = 0x7FFFFFFF;  // 无时间片限制
    proc->rq = rq;
    rq->proc_num++;
}

/* FIFO 选择下一个进程：队首 */
static struct proc_struct *FIFO_pick_next(struct run_queue *rq) {
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {
        return le2proc(le, run_link);
    }
    return NULL;
}

/* FIFO 时钟处理：非抢占式，不做处理 */
static void FIFO_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    // 非抢占式，进程一直运行到完成或阻塞
}
```

**特点**：进程一旦获得 CPU 就运行到完成，不会被时间片中断。

##### 4.2.2 SJF（最短作业优先）

```c
/* 比较函数：执行时间短的优先（lab6_priority 小的优先） */
static int SJF_compare(skew_heap_entry_t *a, skew_heap_entry_t *b) {
    struct proc_struct *p = le2proc(a, lab6_run_pool);
    struct proc_struct *q = le2proc(b, lab6_run_pool);
    int32_t diff = (int32_t)(p->lab6_priority) - (int32_t)(q->lab6_priority);
    if (diff != 0) return diff;
    return (p->pid - q->pid);  // 相同则按 PID
}

/* SJF 入队：按预估执行时间插入斜堆 */
static void SJF_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->lab6_priority == 0) {
        proc->lab6_priority = 100;  // 默认执行时间
    }
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, 
                                          &(proc->lab6_run_pool), 
                                          SJF_compare);
    proc->time_slice = 0x7FFFFFFF;
    proc->rq = rq;
    rq->proc_num++;
}

/* SJF 选择：返回预估执行时间最短的 */
static struct proc_struct *SJF_pick_next(struct run_queue *rq) {
    if (rq->lab6_run_pool == NULL) return NULL;
    return le2proc(rq->lab6_run_pool, lab6_run_pool);
}
```

**特点**：使用 `lab6_priority` 表示预估执行时间，值越小越优先。

##### 4.2.3 Priority（优先级调度）

```c
/* 比较函数：优先级高的优先（lab6_priority 大的优先） */
static int Priority_compare(skew_heap_entry_t *a, skew_heap_entry_t *b) {
    struct proc_struct *p = le2proc(a, lab6_run_pool);
    struct proc_struct *q = le2proc(b, lab6_run_pool);
    return (int32_t)(q->lab6_priority) - (int32_t)(p->lab6_priority);
}

/* Priority 入队 */
static void Priority_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->lab6_priority == 0) {
        proc->lab6_priority = 10;  // 默认优先级
    }
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, 
                                          &(proc->lab6_run_pool), 
                                          Priority_compare);
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;
    }
    proc->rq = rq;
    rq->proc_num++;
}

/* Priority 时钟处理：支持时间片 */
static void Priority_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0) proc->time_slice--;
    if (proc->time_slice == 0) proc->need_resched = 1;
}
```

**特点**：与 SJF 相反，`lab6_priority` 值越大优先级越高。

##### 4.2.4 MLFQ（多级反馈队列）

```c
#define MLFQ_LEVELS 3
#define MLFQ_BASE_SLICE 2
#define MLFQ_BOOST_INTERVAL 100

static list_entry_t mlfq_queues[MLFQ_LEVELS];
static unsigned int mlfq_boost_counter = 0;

/* 获取队列对应的时间片 */
static int MLFQ_get_time_slice(int level) {
    return MLFQ_BASE_SLICE << level;  // 2, 4, 8
}

/* MLFQ 入队 */
static void MLFQ_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    int level = proc->lab6_stride;  // 使用 lab6_stride 存储队列级别
    
    if (level < 0 || level >= MLFQ_LEVELS) level = 0;
    
    // 时间片用完，降级
    if (proc->time_slice == 0 && level < MLFQ_LEVELS - 1) {
        level++;
    }
    
    proc->lab6_stride = level;
    proc->time_slice = MLFQ_get_time_slice(level);
    list_add_before(&mlfq_queues[level], &(proc->run_link));
    proc->rq = rq;
    rq->proc_num++;
}

/* MLFQ 选择：从高优先级队列开始找 */
static struct proc_struct *MLFQ_pick_next(struct run_queue *rq) {
    for (int i = 0; i < MLFQ_LEVELS; i++) {
        if (!list_empty(&mlfq_queues[i])) {
            list_entry_t *le = list_next(&mlfq_queues[i]);
            return le2proc(le, run_link);
        }
    }
    return NULL;
}

/* 优先级提升：防止饥饿 */
static void MLFQ_boost_priority(struct run_queue *rq) {
    for (int i = 1; i < MLFQ_LEVELS; i++) {
        while (!list_empty(&mlfq_queues[i])) {
            list_entry_t *le = list_next(&mlfq_queues[i]);
            struct proc_struct *proc = le2proc(le, run_link);
            list_del_init(le);
            proc->lab6_stride = 0;
            proc->time_slice = MLFQ_get_time_slice(0);
            list_add_before(&mlfq_queues[0], &(proc->run_link));
        }
    }
}

/* MLFQ 时钟处理 */
static void MLFQ_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0) proc->time_slice--;
    if (proc->time_slice == 0) proc->need_resched = 1;
    
    // 定期提升优先级
    mlfq_boost_counter++;
    if (mlfq_boost_counter >= MLFQ_BOOST_INTERVAL) {
        mlfq_boost_counter = 0;
        MLFQ_boost_priority(rq);
    }
}
```

**特点**：
- 3 级队列，时间片分别为 2、4、8
- 新进程从最高优先级开始
- 时间片用完降级
- 每 100 ticks 提升所有进程到最高优先级（防止饥饿）

#### 4.3 调度器切换方法

在 `sched.c` 的 `sched_init()` 函数中修改：

```c
void sched_init(void) {
    list_init(&timer_list);

    // 选择调度算法（修改这一行来切换）
    sched_class = &default_sched_class;   // RR
    // sched_class = &stride_sched_class;    // Stride
    // sched_class = &FIFO_sched_class;      // FIFO
    // sched_class = &SJF_sched_class;       // SJF
    // sched_class = &Priority_sched_class;  // Priority
    // sched_class = &MLFQ_sched_class;      // MLFQ

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
}
```

#### 4.4 测试用例设计

为了定量分析各调度算法的性能差异，设计了两个测试程序：

##### 4.4.1 sched_test.c - 综合测试程序

```c
/* 测试程序核心结构 */
#define MAX_CHILDREN 5
#define MAX_TIME 2000    // 最大运行时间(ms)

// CPU工作负载模拟
static void spin_delay(void) {
    int i;
    volatile int j;
    for (i = 0; i != 200; ++i) { j = !j; }
}
```

**Test 1: 短作业-长作业混合测试**
- **目的**：测试调度器对不同长度作业的处理
- **方法**：创建5个进程，工作量分别为 5000-500-5000-500-500
- **指标**：平均周转时间
- **预期**：SJF 应该有最短的平均周转时间

**Test 2: 公平性测试**
- **目的**：测试相同优先级进程的CPU时间分配
- **方法**：创建5个优先级相同的进程，竞争2秒CPU时间
- **指标**：Max/Min 比值（越接近1.0越公平）
- **预期**：RR 最公平，FIFO 最不公平

**Test 3: 优先级/Stride测试**
- **目的**：验证优先级调度的正确性
- **方法**：创建5个进程，优先级分别为 1,2,3,4,5
- **指标**：各进程工作量比例
- **预期**：Stride 调度器应显示 5:4:3:2:1 的比例

**Test 4: 上下文切换开销测试**
- **目的**：测量调度器的上下文切换开销
- **方法**：两个进程交替调用 yield() 500次
- **指标**：总耗时
- **预期**：时间越短，开销越低

**Test 5: 护航效应测试**
- **目的**：测试护航效应（Convoy Effect）
- **方法**：先启动1个长作业，再启动4个短作业
- **指标**：短作业平均周转时间
- **预期**：FIFO 短作业需等待长作业完成，RR/SJF 能更快响应

##### 4.4.2 sched_bench.c - 基准测试程序

**Bench 1: CPU密集型吞吐量测试**
```c
// 测试纯CPU负载下的吞吐量分配
for (i = 0; i < N; i++) {
    if ((pids[i] = fork()) == 0) {
        lab6_set_priority(i + 1);
        int work = 0;
        while (gettime_msec() - start < TIME_LIMIT) {
            spin(100); work++;
        }
        exit(work);
    }
}
```

**Bench 5: Jain's 公平性指数**
$$JFI = \frac{(\sum_{i=1}^{n} x_i)^2}{n \cdot \sum_{i=1}^{n} x_i^2}$$

- 范围：$[1/n, 1.0]$
- 1.0 表示完全公平
- 1/n 表示只有一个进程获得资源

#### 4.5 实验结果与分析

##### 4.5.1 RR (Round Robin) 调度器结果

| 测试项 | 结果 | 分析 |
|--------|------|------|
| **Test 2 公平性** | Ratio = 1.12 | ✅ 接近1.0，RR公平分配CPU |
| **Test 3 优先级** | 比例 = 1:1:1:1:1 | ✅ RR不关心优先级，所有进程平等 |
| **Bench 5 JFI** | 0.999 | ✅ 近乎完美的公平性 |
| **Bench 1 吞吐量** | 13864:14040:13995:14047:13589 | ✅ 均匀分配 |

**结论**：RR调度器行为完全符合预期：
- 公平地轮转所有进程
- 完全忽略优先级设置
- 时间片机制避免了护航效应

##### 4.5.2 Stride 调度器结果

| 测试项 | 结果 | 分析 |
|--------|------|------|
| **Bench 1 吞吐量** | 5756:9379:13507:18064:20587 | ✅ 按优先级分配 |
| **Bench 4 比例** | 0.3:0.4:0.6:0.9:1.0 | ✅ 接近理论值 1:2:3:4:5 的倒数 |
| **Test 5 护航** | 短作业平均 2ms | ✅ 无护航效应 |
| **Bench 5 JFI** | 0.999 | ✅ 相同优先级时公平 |

**Stride 优先级语义**：
- priority 数值越小 = stride（步长）越大 = CPU份额越少
- priority=5 获得最多CPU时间

**Bench 4 比例验证**：
```
实际比例:   0.26 : 0.43 : 0.65 : 0.85 : 1.0
理论比例:   0.2  : 0.4  : 0.6  : 0.8  : 1.0
误差范围:   ±10%
```

**结论**：Stride调度器正确实现了按优先级比例分配CPU时间。

##### 4.5.3 FIFO 调度器结果

| 测试项 | 结果 | 分析 |
|--------|------|------|
| **Bench 1 吞吐量** | 68422:0:0:0:0 | ✅ 只有P0执行（非抢占） |
| **Bench 4** | 136873:0:0:0:0 | ✅ 先来先服务 |
| **Bench 5 JFI** | **0.200** | ✅ 极度不公平 (1/5) |
| **Test 2 公平性** | Ratio = 1.03 | ⚠️ 顺序执行导致 |

**FIFO 关键特征**：
1. **非抢占式**：一个进程独占CPU直到完成
2. **极度不公平**：JFI = 0.200 = 1/5
3. **忽略优先级**：严格按到达顺序执行
4. **有护航效应**：短作业必须等待长作业完成

**Test 2 为何显示公平？**

FIFO 的 Ratio=1.03 看似公平，实际上是因为每个进程**顺序独占运行**至完成：
```
时间轴: |--P0独占--|--P1独占--|--P2独占--|--P3独占--|--P4独占--|
```
每个进程工作量相近，但这不是真正的公平，而是**顺序执行**。

##### 4.5.4 SJF 调度器结果

| 测试项 | 结果 | 分析 |
|--------|------|------|
| **Bench 1** | 0:0:0:0:68374 | ✅ 最后进程（最短）先执行 |
| **Bench 5 JFI** | **0.200** | ✅ 非抢占，一个进程独占 |
| **Test 5 护航** | 短作业平均 7ms | ✅ 部分避免护航效应 |

**SJF 调度逻辑**：
- 使用 `lab6_priority` 表示预估执行时间
- priority 值越小 = 作业越短 = 越优先执行
- 非抢占式实现

**Test 5 结果对比**：
| 调度器 | 短作业平均周转时间 |
|--------|-------------------|
| FIFO | 10 ms |
| SJF | 7 ms |
| RR | 10 ms |
| Stride | 2 ms |

SJF 能部分避免护航效应，短作业可以优先执行。

##### 4.5.5 Priority 调度器结果

| 测试项 | 结果 | 分析 |
|--------|------|------|
| **Test 2 公平性** | Ratio = 1.06 | ✅ 相同优先级时较公平 |
| **Bench 1 吞吐量** | 0:0:0:0:68232 | ✅ 最高优先级进程独占 |
| **Bench 5 JFI** | **0.200** | ⚠️ 非抢占特性导致不公平 |
| **Test 5 护航** | 短作业平均 5ms | ✅ 高优先级短作业先完成 |

**Priority 调度特征**：

```
Test 3 原始数据:
P4 (pri=5): work=4590000  → 高优先级，最先执行
P2 (pri=3): work=4654000
P0 (pri=1): work=4692000  → 低优先级，最后执行
```

**关键观察**：
1. **优先级语义**：priority 值越大 = 优先级越高
2. **非抢占式**：一旦开始执行，直到完成才切换
3. **Bench 测试**：限时内只有最高优先级进程执行（P4）
4. **饥饿风险**：低优先级进程可能长时间得不到执行

**Test 2 vs Bench 5 的差异解释**：
- Test 2：所有进程**相同优先级(5)**，退化为 FIFO 行为，顺序完成
- Bench 5：限时测试，只有一个进程能执行完

##### 4.5.6 MLFQ 调度器结果

| 测试项 | 结果 | 分析 |
|--------|------|------|
| **Test 2 公平性** | Ratio = 1.13 | ✅ 类似RR的公平性 |
| **Bench 5 JFI** | **0.995** | ✅ 接近完美公平 |
| **Bench 1 吞吐量** | 14731:14211:14375:12633:12435 | ✅ 相对均匀分配 |
| **Bench 4 比例** | 1.2:1.2:1.2:1.0:1.0 | ⚠️ 不支持外部优先级 |

**MLFQ 独特行为**：

```
Bench 2 混合负载测试:
CPU-bound total: 4242
IO-bound total:  287949   ← IO密集型获得更多执行机会！
```

这是 MLFQ 的**核心特性**：
- **IO密集型进程**：频繁 yield，保持在高优先级队列
- **CPU密集型进程**：时间片用完后降级到低优先级队列
- **结果**：IO进程响应更快，CPU进程吞吐量较低

**MLFQ 三级队列机制**：
```
Level 0 (高优先级): time_slice = 2  ← 新进程/IO进程
Level 1 (中优先级): time_slice = 4  ← 时间片用完降级
Level 2 (低优先级): time_slice = 8  ← CPU密集型进程
```

**与其他调度器对比**：

| 混合负载测试 | CPU-bound | IO-bound | 特点 |
|-------------|-----------|----------|------|
| RR | 70142 | 87 | CPU和IO平等对待 |
| Stride | 69505 | 90 | CPU和IO平等对待 |
| FIFO | 69022 | 0 | IO进程饥饿 |
| SJF | 0 | 317231 | IO进程优先 |
| Priority | 0 | 314581 | 按优先级执行 |
| **MLFQ** | **4242** | **287949** | **自动偏向IO** |

**MLFQ 优势**：
1. 无需预知进程类型，自动适应
2. IO密集型进程获得快速响应
3. 防止饥饿（周期性优先级提升）
4. 综合性能良好

#### 4.6 各调度算法对比总结

##### 4.6.1 量化指标对比

| 指标 | RR | Stride | FIFO | SJF | Priority | MLFQ |
|------|-----|--------|------|-----|----------|------|
| **Jain公平性指数** | 0.999 | 0.999 | 0.200 | 0.200 | 0.200 | 0.995 |
| **优先级比例** | 1:1:1:1:1 | ~1:2:3:4:5 | N/A | N/A | 按优先级 | 自适应 |
| **护航效应** | 无 | 无 | 严重 | 部分 | 部分 | 无 |
| **短作业平均(ms)** | 10 | 2 | 10 | 7 | 5 | 10 |
| **抢占式** | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |

##### 4.6.2 Bench 1 吞吐量分布对比

```
RR:       |████|████|████|████|████|  均匀分配
Stride:   |██|███|█████|██████|███████|  按优先级比例
FIFO:     |████████████████████|    |  仅第一个进程
SJF:      |    |    |    |    |████████████████████|  仅最后进程
Priority: |    |    |    |    |████████████████████|  仅最高优先级
MLFQ:     |████|████|████|███|███|  相对均匀（略有差异）
```

##### 4.6.3 综合评价

| 特性 | RR | Stride | FIFO | SJF | Priority | MLFQ |
|------|:--:|:------:|:----:|:---:|:--------:|:----:|
| 公平性 | ◎ | ◎ | × | × | × | ◎ |
| 响应时间 | ◎ | ○ | × | ○ | ○ | ◎ |
| 优先级支持 | × | ◎ | × | × | ◎ | ○ |
| 周转时间 | ○ | ○ | △ | ◎ | ○ | ○ |
| IO友好性 | ○ | ○ | × | ○ | ○ | ◎ |
| 实现复杂度 | 低 | 中 | 低 | 中 | 中 | 高 |
| 饥饿风险 | 无 | 低 | 高 | 中 | 高 | 低 |

**图例**：◎优秀 ○良好 △一般 ×较差

##### 4.6.4 适用场景建议

| 调度算法 | 适用场景 |
|----------|----------|
| **RR** | 通用分时系统，交互式应用，需要公平性 |
| **Stride** | 需要按比例分配CPU的场景（虚拟机、容器） |
| **FIFO** | 批处理系统，任务执行时间相近且简单 |
| **SJF** | 已知作业长度，追求最短平均周转时间 |
| **Priority** | 实时系统，有明确优先级需求 |
| **MLFQ** | 通用操作系统，需自动适应IO/CPU密集型任务 |

##### 4.6.5 关键发现

1. **抢占 vs 非抢占**
   - 抢占式（RR、Stride、MLFQ）：JFI ≈ 1.0，公平性好
   - 非抢占式（FIFO、SJF、Priority）：JFI = 0.2，只有一个进程能在限时测试中执行

2. **优先级实现差异**
   - RR：完全忽略优先级
   - Stride：按优先级**比例**分配（数学精确）
   - Priority：高优先级**优先**执行（可能饥饿）
   - MLFQ：自动调整（IO密集型自动提升）

3. **护航效应对比**
   | 调度器 | 短作业平均周转时间 | 评价 |
   |--------|-------------------|------|
   | Stride | 2 ms | ◎ 最佳 |
   | Priority | 5 ms | ○ 良好 |
   | SJF | 7 ms | ○ 良好 |
   | RR | 10 ms | △ 一般 |
   | FIFO | 10 ms | × 较差 |
   | MLFQ | 10 ms | △ 一般 |

4. **IO/CPU混合负载表现**
   | 调度器 | IO进程获得比例 | 评价 |
   |--------|---------------|------|
   | MLFQ | 98.5% | ◎ IO友好 |
   | SJF | 100% | ◎ IO优先 |
   | Priority | 100% | ◎ 按优先级 |
   | RR | 0.1% | × IO饥饿 |
   | Stride | 0.1% | × IO饥饿 |
   | FIFO | 0% | × IO饥饿 |

5. **实践建议**
   - **通用桌面系统**：首选 MLFQ（自适应）或 RR（公平）
   - **服务器/虚拟化**：选 Stride（精确控制资源比例）
   - **实时系统**：选 Priority（严格优先级）
   - **批处理系统**：选 SJF（最优周转时间）或 FIFO（简单）

##### 4.6.6 实验数据完整汇总

**sched_test 结果汇总**：

| 调度器 | Test1 平均周转 | Test2 公平比 | Test5 短作业平均 |
|--------|---------------|--------------|-----------------|
| RR | 6 ms | 1.12 | 10 ms |
| Stride | 4 ms | 1.52 | 2 ms |
| FIFO | 6 ms | 1.03 | 10 ms |
| SJF | 6 ms | 1.01 | 7 ms |
| Priority | 8 ms | 1.06 | 5 ms |
| MLFQ | 6 ms | 1.13 | 10 ms |

**sched_bench 结果汇总**：

| 调度器 | Bench1 总吞吐 | Bench5 JFI | Bench2 IO占比 |
|--------|--------------|------------|---------------|
| RR | 69535 | 0.999 | 0.1% |
| Stride | 67293 | 0.999 | 0.1% |
| FIFO | 68422 | 0.200 | 0% |
| SJF | 68374 | 0.200 | 100% |
| Priority | 68232 | 0.200 | 100% |
| MLFQ | 68385 | 0.995 | 98.5% |

---

## Lab8: 文件系统

### 练习1: 完成读文件操作的实现

#### 1.1 sfs_io_nolock 函数实现

**设计思路：**

文件读取分为三部分：
1. **首块**：处理起始偏移不对齐的情况
2. **中间块**：批量读取对齐的完整块
3. **尾块**：处理结束位置不对齐的情况

```
  |<---- 文件数据 ---->|
  +----+----+----+----+
  | B0 | B1 | B2 | B3 |
  +----+----+----+----+
       ^            ^
       |            |
     offset      endpos
     
  首块(部分) | 中间块(完整) | 尾块(部分)
```

**实现代码：**
```c
static int sfs_io_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, 
                         void *buf, off_t offset, size_t *alenp, bool write) {
    struct sfs_disk_inode *din = sin->din;
    size_t endpos = offset + *alenp;
    size_t blkoff, nblks;
    uint32_t ino;
    int ret = 0;
    size_t alen = 0;
    
    // 边界检查
    if (offset >= din->size) {
        *alenp = 0;
        return 0;
    }
    if (endpos > din->size) {
        endpos = din->size;
    }
    
    // 第一部分：处理首块（可能不对齐）
    blkoff = offset % SFS_BLKSIZE;
    if (blkoff != 0) {
        size_t nread = SFS_BLKSIZE - blkoff;
        if (offset + nread > endpos) {
            nread = endpos - offset;
        }
        ret = sfs_bmap_load_nolock(sfs, sin, offset / SFS_BLKSIZE, &ino);
        if (ret != 0) goto out;
        ret = sfs_buf_op(sfs, buf, nread, ino, blkoff);
        if (ret != 0) goto out;
        alen += nread;
        buf += nread;
        offset += nread;
    }
    
    // 第二部分：处理中间完整块
    nblks = (endpos - offset) / SFS_BLKSIZE;
    if (nblks > 0) {
        ret = sfs_bmap_load_nolock(sfs, sin, offset / SFS_BLKSIZE, &ino);
        if (ret != 0) goto out;
        ret = sfs_block_op(sfs, buf, ino, nblks);
        if (ret != 0) goto out;
        size_t nbytes = nblks * SFS_BLKSIZE;
        alen += nbytes;
        buf += nbytes;
        offset += nbytes;
    }
    
    // 第三部分：处理尾块（可能不对齐）
    if (offset < endpos) {
        size_t nread = endpos - offset;
        ret = sfs_bmap_load_nolock(sfs, sin, offset / SFS_BLKSIZE, &ino);
        if (ret != 0) goto out;
        ret = sfs_buf_op(sfs, buf, nread, ino, 0);
        if (ret != 0) goto out;
        alen += nread;
    }
    
out:
    *alenp = alen;
    return ret;
}
```

---

### 练习2: 完成基于文件系统的执行程序机制

#### 2.1 load_icode 函数实现

**主要步骤：**
1. 创建新的内存管理结构
2. 设置页目录
3. 从文件读取 ELF 头
4. 解析并加载各个程序段
5. 建立用户栈
6. 设置命令行参数
7. 设置 trapframe

**关键代码：**
```c
static int load_icode(int fd, int argc, char **kargv) {
    struct mm_struct *mm;
    
    // 1. 创建 mm_struct
    if ((mm = mm_create()) == NULL) goto bad_mm;
    
    // 2. 创建页目录
    if (setup_pgdir(mm) != 0) goto bad_pgdir_cleanup_mm;
    
    // 3. 读取 ELF 头
    struct elfhdr elf;
    if (load_icode_read(fd, &elf, sizeof(elf), 0) != 0) goto bad_elf_cleanup_pgdir;
    
    // 4. 加载程序段
    struct proghdr ph;
    for (int i = 0; i < elf.e_phnum; i++) {
        load_icode_read(fd, &ph, sizeof(ph), elf.e_phoff + i * sizeof(ph));
        if (ph.p_type == ELF_PT_LOAD) {
            // 分配内存并映射
            vm_flags = 0;
            if (ph.p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
            if (ph.p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
            if (ph.p_flags & ELF_PF_R) vm_flags |= VM_READ;
            
            mm_map(mm, ph.p_va, ph.p_memsz, vm_flags, NULL);
            
            // 从文件读取数据到内存
            // ...
        }
    }
    
    // 5. 建立用户栈
    mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, VM_READ|VM_WRITE|VM_STACK, NULL);
    
    // 6. 设置命令行参数
    uintptr_t stacktop = USTACKTOP;
    // 复制 argv 字符串到用户栈
    // ...
    
    // 7. 设置 trapframe
    struct trapframe *tf = current->tf;
    memset(tf, 0, sizeof(struct trapframe));
    tf->gpr.sp = stacktop;
    tf->epc = elf.e_entry;
    tf->status = sstatus & ~SSTATUS_SPP | SSTATUS_SPIE;
    
    return 0;
}
```

---

### 扩展练习 Challenge1: UNIX PIPE 机制设计

#### 数据结构设计

```c
#define PIPE_BUF_SIZE 4096

struct pipe {
    char buffer[PIPE_BUF_SIZE];   // 环形缓冲区
    size_t read_pos;              // 读位置
    size_t write_pos;             // 写位置
    size_t count;                 // 缓冲区中的数据量
    
    int readers;                  // 读端引用计数
    int writers;                  // 写端引用计数
    
    semaphore_t mutex;            // 互斥锁
    semaphore_t not_full;         // 非满信号量
    semaphore_t not_empty;        // 非空信号量
};

struct pipe_file {
    struct pipe *pipe;            // 指向管道
    bool is_read_end;             // 是否是读端
};
```

#### 接口设计

```c
// 创建管道，返回两个文件描述符
int pipe(int fd[2]);
// fd[0] 为读端，fd[1] 为写端

// 读管道
ssize_t pipe_read(struct pipe *p, void *buf, size_t n);

// 写管道
ssize_t pipe_write(struct pipe *p, const void *buf, size_t n);

// 关闭管道端
int pipe_close(struct pipe *p, bool is_read_end);
```

#### 同步互斥处理

```c
ssize_t pipe_read(struct pipe *p, void *buf, size_t n) {
    down(&p->mutex);                    // 获取互斥锁
    while (p->count == 0) {
        if (p->writers == 0) {          // 没有写者，返回 EOF
            up(&p->mutex);
            return 0;
        }
        up(&p->mutex);
        down(&p->not_empty);            // 等待数据
        down(&p->mutex);
    }
    // 从缓冲区读取数据...
    up(&p->not_full);                   // 通知写者
    up(&p->mutex);
    return bytes_read;
}
```

---

### 扩展练习 Challenge2: 软连接和硬连接设计

#### 数据结构设计

```c
// 修改 sfs_disk_inode 支持符号链接
struct sfs_disk_inode {
    uint32_t size;
    uint16_t type;          // SFS_TYPE_FILE, SFS_TYPE_DIR, SFS_TYPE_LINK
    uint16_t nlinks;        // 硬连接计数
    uint32_t blocks;
    uint32_t direct[SFS_NDIRECT];
    uint32_t indirect;
    // 对于符号链接，如果路径较短，直接存储在 direct 数组中
    // 否则存储在数据块中
};

#define SFS_TYPE_FILE  1
#define SFS_TYPE_DIR   2
#define SFS_TYPE_LINK  3    // 符号链接

// 符号链接结构
struct sfs_symlink {
    char target[SFS_MAX_PATH];  // 目标路径
};
```

#### 接口设计

```c
// 创建硬连接
// 语义：在 newpath 处创建指向 oldpath 的硬连接
int link(const char *oldpath, const char *newpath);

// 创建软连接（符号链接）
// 语义：在 linkpath 处创建指向 target 的符号链接
int symlink(const char *target, const char *linkpath);

// 读取符号链接目标
// 语义：读取 path 指向的符号链接的目标路径
ssize_t readlink(const char *path, char *buf, size_t bufsiz);

// 删除链接
// 语义：删除 pathname 处的链接，如果是硬连接则减少引用计数
int unlink(const char *pathname);
```

#### 硬连接实现要点

```c
int sfs_link(const char *oldpath, const char *newpath) {
    // 1. 查找 oldpath 对应的 inode
    struct sfs_inode *sin = sfs_lookup(oldpath);
    
    // 2. 检查：不能对目录创建硬连接
    if (sin->din->type == SFS_TYPE_DIR) return -E_ISDIR;
    
    // 3. 在 newpath 的父目录中添加目录项，指向同一个 inode
    sfs_add_dirent(parent_dir, newname, sin->ino);
    
    // 4. 增加硬连接计数
    sin->din->nlinks++;
    
    return 0;
}
```

#### 软连接实现要点

```c
int sfs_symlink(const char *target, const char *linkpath) {
    // 1. 创建新的 inode，类型为 SFS_TYPE_LINK
    struct sfs_inode *sin = sfs_create_inode(SFS_TYPE_LINK);
    
    // 2. 将目标路径存储在 inode 中
    strcpy(sin->symlink_target, target);
    
    // 3. 在父目录中添加目录项
    sfs_add_dirent(parent_dir, linkname, sin->ino);
    
    return 0;
}

// 路径解析时处理符号链接
struct sfs_inode *sfs_lookup_with_symlink(const char *path, int follow_count) {
    struct sfs_inode *sin = sfs_lookup_nofollow(path);
    
    // 检测循环引用
    if (follow_count > MAX_SYMLINK_DEPTH) return NULL;
    
    if (sin->din->type == SFS_TYPE_LINK) {
        // 递归解析符号链接
        return sfs_lookup_with_symlink(sin->symlink_target, follow_count + 1);
    }
    return sin;
}
```

---

## 实验总结

### 主要完成内容

1. **Lab6**：
   - 理解调度器框架设计
   - 实现 RR 调度算法
   - 实现 Stride 调度算法
   - 实现多种扩展调度算法（FIFO、SJF、Priority、MLFQ）

2. **Lab8**：
   - 实现文件读取操作 `sfs_io_nolock`
   - 实现基于文件系统的程序加载 `load_icode`
   - 设计 PIPE 和链接机制

### 心得体会

1. **设计模式的重要性**：调度器框架使用策略模式，通过函数指针实现算法的可插拔，这种设计极大提高了代码的可扩展性。

2. **理论与实践结合**：通过实现多种调度算法，深入理解了各算法的优缺点和适用场景。

3. **文件系统的复杂性**：文件系统涉及多层抽象（VFS、SFS、设备），理解这些抽象层次对于实现功能至关重要。
