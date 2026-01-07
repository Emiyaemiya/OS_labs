/*
 * 多种调度算法声明头文件
 * 
 * Lab6 Challenge 2: 实现多种调度算法
 * 
 * 包含以下调度算法：
 * 1. FIFO (First In First Out) - 先来先服务
 * 2. SJF (Shortest Job First) - 最短作业优先
 * 3. Priority - 优先级调度
 * 4. RR (Round Robin) - 时间片轮转
 * 5. MLFQ (Multi-Level Feedback Queue) - 多级反馈队列
 * 6. Lottery - 彩票调度
 * 7. Stride - 步幅调度（默认实现）
 */

#ifndef __KERN_SCHEDULE_SCHED_ALL_H__
#define __KERN_SCHEDULE_SCHED_ALL_H__

#include <sched.h>

/* 声明各调度算法的 sched_class */

// FIFO: 先来先服务，非抢占式
extern struct sched_class FIFO_sched_class;

// SJF: 最短作业优先
extern struct sched_class SJF_sched_class;

// Priority: 优先级调度
extern struct sched_class Priority_sched_class;

// RR: 时间片轮转
extern struct sched_class RR_sched_class;

// MLFQ: 多级反馈队列
extern struct sched_class MLFQ_sched_class;

// Lottery: 彩票调度
extern struct sched_class Lottery_sched_class;

// Stride: 步幅调度 (默认)
extern struct sched_class stride_sched_class;
extern struct sched_class default_sched_class;

/*
 * 调度算法选择
 * 
 * 要使用不同的调度算法，可以：
 * 1. 修改 sched.c 中的 sched_init() 函数
 * 2. 将 sched_class = &default_sched_class; 改为想要的算法
 * 
 * 例如：
 *   sched_class = &FIFO_sched_class;
 *   sched_class = &SJF_sched_class;
 *   sched_class = &Priority_sched_class;
 *   sched_class = &RR_sched_class;
 *   sched_class = &MLFQ_sched_class;
 *   sched_class = &Lottery_sched_class;
 */

/*
 * 调度算法特性对比表：
 * 
 * | 算法     | 抢占式 | 时间片 | 优先级 | 公平性 | 响应时间 | 吞吐量 | 复杂度 |
 * |----------|--------|--------|--------|--------|----------|--------|--------|
 * | FIFO     | 否     | 无     | 无     | 低     | 差       | 中     | O(1)   |
 * | SJF      | 否     | 无     | 有*    | 低     | 好       | 高     | O(logn)|
 * | Priority | 是     | 有     | 有     | 中     | 好       | 中     | O(logn)|
 * | RR       | 是     | 有     | 无     | 高     | 好       | 中     | O(1)   |
 * | MLFQ     | 是     | 多级   | 动态   | 高     | 好       | 高     | O(1)   |
 * | Lottery  | 是     | 有     | 概率   | 高     | 中       | 中     | O(n)   |
 * | Stride   | 是     | 有     | 有     | 高     | 好       | 高     | O(logn)|
 * 
 * * SJF 使用预估执行时间作为优先级
 */

#endif /* !__KERN_SCHEDULE_SCHED_ALL_H__ */
