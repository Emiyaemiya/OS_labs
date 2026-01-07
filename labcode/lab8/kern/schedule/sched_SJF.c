/*
 * SJF (Shortest Job First) / SRTF (Shortest Remaining Time First) 调度算法
 * 
 * 特点：
 * - 优先调度预计执行时间最短的进程
 * - SJF 是非抢占式，SRTF 是抢占式
 * - 理论上能最小化平均等待时间
 * 
 * 适用场景：
 * - 批处理系统
 * - 进程执行时间可预测的情况
 * 
 * 缺点：
 * - 需要预先知道进程执行时间（实际中很难获得）
 * - 可能导致长进程饥饿
 * 
 * 实现说明：
 * - 使用 proc->lab6_priority 作为预估执行时间（值越小越优先）
 * - 使用斜堆（skew heap）维护优先级队列
 */

#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <sched.h>
#include <skew_heap.h>

/* 比较函数：执行时间短的优先级高（lab6_priority 小的优先） */
static int
SJF_compare(skew_heap_entry_t *a, skew_heap_entry_t *b) {
    struct proc_struct *p = le2proc(a, lab6_run_pool);
    struct proc_struct *q = le2proc(b, lab6_run_pool);
    // 返回负数表示 a 优先级更高
    int32_t diff = (int32_t)(p->lab6_priority) - (int32_t)(q->lab6_priority);
    if (diff != 0) return diff;
    // 如果优先级相同，先到先服务
    return (p->pid - q->pid);
}

/* SJF 初始化 */
static void
SJF_init(struct run_queue *rq) {
    rq->lab6_run_pool = NULL;
    rq->proc_num = 0;
}

/* SJF 入队：按预估执行时间插入斜堆 */
static void
SJF_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    // 如果没有设置优先级，默认为中等值
    if (proc->lab6_priority == 0) {
        proc->lab6_priority = 100;
    }
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, 
                                          &(proc->lab6_run_pool), 
                                          SJF_compare);
    // SJF 非抢占式，时间片设为最大
    proc->time_slice = 0x7FFFFFFF;
    proc->rq = rq;
    rq->proc_num++;
}

/* SJF 出队 */
static void
SJF_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, 
                                          &(proc->lab6_run_pool), 
                                          SJF_compare);
    rq->proc_num--;
}

/* SJF 选择下一个进程：选择预估执行时间最短的 */
static struct proc_struct *
SJF_pick_next(struct run_queue *rq) {
    if (rq->lab6_run_pool == NULL) {
        return NULL;
    }
    return le2proc(rq->lab6_run_pool, lab6_run_pool);
}

/* SJF 时钟处理：非抢占式不处理，抢占式 (SRTF) 需要重新调度 */
static void
SJF_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    // 非抢占式 SJF：不做处理
    // 如果要实现 SRTF（抢占式），可以减少剩余时间并触发重调度
    // proc->lab6_priority--;  // 减少剩余时间
    // proc->need_resched = 1; // 抢占式
}

struct sched_class SJF_sched_class = {
    .name = "SJF_scheduler",
    .init = SJF_init,
    .enqueue = SJF_enqueue,
    .dequeue = SJF_dequeue,
    .pick_next = SJF_pick_next,
    .proc_tick = SJF_proc_tick,
};