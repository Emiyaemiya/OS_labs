/*
 * Priority 优先级调度算法（带时间片的抢占式）
 * 
 * 特点：
 * - 根据进程优先级进行调度
 * - 优先级高的进程优先执行
 * - 同优先级采用时间片轮转
 * - 抢占式：高优先级进程可抢占低优先级进程
 * 
 * 适用场景：
 * - 交互式系统
 * - 需要区分进程重要性的场景
 * 
 * 缺点：
 * - 低优先级进程可能饥饿
 * - 需要合理设置优先级
 * 
 * 实现说明：
 * - 使用 proc->lab6_priority 作为优先级（值越大优先级越高）
 * - 使用斜堆维护优先级队列
 */

#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <sched.h>
#include <skew_heap.h>

/* 比较函数：优先级高的优先（lab6_priority 大的优先） */
static int
Priority_compare(skew_heap_entry_t *a, skew_heap_entry_t *b) {
    struct proc_struct *p = le2proc(a, lab6_run_pool);
    struct proc_struct *q = le2proc(b, lab6_run_pool);
    // 返回负数表示 a 优先级更高（priority 大的优先）
    int32_t diff = (int32_t)(q->lab6_priority) - (int32_t)(p->lab6_priority);
    if (diff != 0) return diff;
    // 优先级相同，先到先服务
    return (p->pid - q->pid);
}

/* Priority 初始化 */
static void
Priority_init(struct run_queue *rq) {
    rq->lab6_run_pool = NULL;
    rq->proc_num = 0;
    rq->max_time_slice = MAX_TIME_SLICE;
}

/* Priority 入队 */
static void
Priority_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    // 默认优先级
    if (proc->lab6_priority == 0) {
        proc->lab6_priority = 10;
    }
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, 
                                          &(proc->lab6_run_pool), 
                                          Priority_compare);
    // 设置时间片
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;
    }
    proc->rq = rq;
    rq->proc_num++;
}

/* Priority 出队 */
static void
Priority_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, 
                                          &(proc->lab6_run_pool), 
                                          Priority_compare);
    rq->proc_num--;
}

/* Priority 选择下一个进程 */
static struct proc_struct *
Priority_pick_next(struct run_queue *rq) {
    if (rq->lab6_run_pool == NULL) {
        return NULL;
    }
    return le2proc(rq->lab6_run_pool, lab6_run_pool);
}

/* Priority 时钟处理：时间片用完需要重新调度 */
static void
Priority_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0) {
        proc->time_slice--;
    }
    if (proc->time_slice == 0) {
        proc->need_resched = 1;
    }
}

struct sched_class Priority_sched_class = {
    .name = "Priority_scheduler",
    .init = Priority_init,
    .enqueue = Priority_enqueue,
    .dequeue = Priority_dequeue,
    .pick_next = Priority_pick_next,
    .proc_tick = Priority_proc_tick,
};