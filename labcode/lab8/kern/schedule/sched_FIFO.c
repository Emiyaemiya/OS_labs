/*
 * FIFO (First In First Out) 调度算法
 * 
 * 特点：
 * - 非抢占式调度
 * - 先到先服务
 * - 进程一旦获得 CPU 就一直运行直到完成或阻塞
 * 
 * 适用场景：
 * - 批处理系统
 * - 进程执行时间相近的情况
 * 
 * 缺点：
 * - 平均等待时间可能很长（护航效应）
 * - 对短进程不公平
 */

#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <sched.h>

/* FIFO 初始化运行队列 */
static void
FIFO_init(struct run_queue *rq) {
    list_init(&(rq->run_list));
    rq->proc_num = 0;
}

/* FIFO 入队：添加到队列尾部 */
static void
FIFO_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    assert(list_empty(&(proc->run_link)));
    // 添加到队列尾部
    list_add_before(&(rq->run_list), &(proc->run_link));
    // FIFO 不需要时间片，设置为最大值表示不会被时间片中断
    proc->time_slice = 0x7FFFFFFF;
    proc->rq = rq;
    rq->proc_num++;
}

/* FIFO 出队 */
static void
FIFO_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
    list_del_init(&(proc->run_link));
    rq->proc_num--;
}

/* FIFO 选择下一个进程：选择队列头部（最早到达的进程） */
static struct proc_struct *
FIFO_pick_next(struct run_queue *rq) {
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {
        return le2proc(le, run_link);
    }
    return NULL;
}

/* FIFO 时钟中断处理：非抢占式，不做任何处理 */
static void
FIFO_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    // FIFO 是非抢占式的，时钟中断不会导致进程切换
    // 进程只有在主动让出 CPU（完成或阻塞）时才会切换
}

struct sched_class FIFO_sched_class = {
    .name = "FIFO_scheduler",
    .init = FIFO_init,
    .enqueue = FIFO_enqueue,
    .dequeue = FIFO_dequeue,
    .pick_next = FIFO_pick_next,
    .proc_tick = FIFO_proc_tick,
};