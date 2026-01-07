/*
 * MLFQ (Multi-Level Feedback Queue) 多级反馈队列调度算法
 * 
 * 特点：
 * - 多个优先级队列，每个队列有不同的时间片
 * - 新进程进入最高优先级队列
 * - 时间片用完降级到下一级队列
 * - 等待过久的进程可以升级（防止饥饿）
 * - 自动区分 CPU 密集型和 I/O 密集型进程
 * 
 * 适用场景：
 * - 通用操作系统
 * - 交互式和批处理混合的环境
 * 
 * 优点：
 * - 兼顾响应时间和吞吐量
 * - 自适应进程行为
 * 
 * 实现说明：
 * - 使用 3 个优先级队列
 * - 队列 0: 时间片 2，最高优先级
 * - 队列 1: 时间片 4，中等优先级
 * - 队列 2: 时间片 8，最低优先级
 */

#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <sched.h>

#define MLFQ_LEVELS 3
#define MLFQ_BASE_SLICE 2
#define MLFQ_BOOST_INTERVAL 100  // 每 100 ticks 提升所有进程优先级

static list_entry_t mlfq_queues[MLFQ_LEVELS];
static unsigned int mlfq_queue_sizes[MLFQ_LEVELS];
static unsigned int mlfq_boost_counter = 0;

/* 获取队列对应的时间片 */
static int
MLFQ_get_time_slice(int level) {
    return MLFQ_BASE_SLICE << level;  // 2, 4, 8
}

/* MLFQ 初始化 */
static void
MLFQ_init(struct run_queue *rq) {
    for (int i = 0; i < MLFQ_LEVELS; i++) {
        list_init(&mlfq_queues[i]);
        mlfq_queue_sizes[i] = 0;
    }
    rq->proc_num = 0;
    mlfq_boost_counter = 0;
}

/* MLFQ 入队 */
static void
MLFQ_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    // 获取当前队列级别（存储在 lab6_stride 中）
    int level = proc->lab6_stride;
    
    // 新进程从最高优先级开始
    if (level < 0 || level >= MLFQ_LEVELS) {
        level = 0;
    }
    
    // 如果时间片用完，降级到下一级队列
    if (proc->time_slice == 0 && level < MLFQ_LEVELS - 1) {
        level++;
    }
    
    proc->lab6_stride = level;
    proc->time_slice = MLFQ_get_time_slice(level);
    
    // 添加到对应队列尾部
    list_add_before(&mlfq_queues[level], &(proc->run_link));
    mlfq_queue_sizes[level]++;
    proc->rq = rq;
    rq->proc_num++;
}

/* MLFQ 出队 */
static void
MLFQ_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    int level = proc->lab6_stride;
    if (level >= 0 && level < MLFQ_LEVELS) {
        list_del_init(&(proc->run_link));
        mlfq_queue_sizes[level]--;
    }
    rq->proc_num--;
}

/* MLFQ 选择下一个进程：从高优先级队列开始找 */
static struct proc_struct *
MLFQ_pick_next(struct run_queue *rq) {
    for (int i = 0; i < MLFQ_LEVELS; i++) {
        if (!list_empty(&mlfq_queues[i])) {
            list_entry_t *le = list_next(&mlfq_queues[i]);
            return le2proc(le, run_link);
        }
    }
    return NULL;
}

/* 优先级提升：将所有进程移到最高优先级队列（防止饥饿） */
static void
MLFQ_boost_priority(struct run_queue *rq) {
    for (int i = 1; i < MLFQ_LEVELS; i++) {
        while (!list_empty(&mlfq_queues[i])) {
            list_entry_t *le = list_next(&mlfq_queues[i]);
            struct proc_struct *proc = le2proc(le, run_link);
            list_del_init(le);
            mlfq_queue_sizes[i]--;
            
            // 移到最高优先级队列
            proc->lab6_stride = 0;
            proc->time_slice = MLFQ_get_time_slice(0);
            list_add_before(&mlfq_queues[0], &(proc->run_link));
            mlfq_queue_sizes[0]++;
        }
    }
}

/* MLFQ 时钟处理 */
static void
MLFQ_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0) {
        proc->time_slice--;
    }
    if (proc->time_slice == 0) {
        proc->need_resched = 1;
    }
    
    // 定期提升优先级防止饥饿
    mlfq_boost_counter++;
    if (mlfq_boost_counter >= MLFQ_BOOST_INTERVAL) {
        mlfq_boost_counter = 0;
        MLFQ_boost_priority(rq);
    }
}

struct sched_class MLFQ_sched_class = {
    .name = "MLFQ_scheduler",
    .init = MLFQ_init,
    .enqueue = MLFQ_enqueue,
    .dequeue = MLFQ_dequeue,
    .pick_next = MLFQ_pick_next,
    .proc_tick = MLFQ_proc_tick,
};