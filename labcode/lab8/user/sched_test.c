/*
 * sched_test.c - Challenge 2 调度算法综合测试程序
 * 
 * 测试指标：
 *   1. 周转时间 (Turnaround Time)
 *   2. 公平性 (Fairness)
 *   3. 优先级调度正确性
 *   4. 上下文切换开销
 *   5. 护航效应 (Convoy Effect)
 * 
 * 使用方法：
 *   1. 修改 kern/schedule/sched.c 选择调度器
 *   2. make clean && make
 *   3. make qemu
 *   4. 在shell中运行 sched_test
 */

#include <ulib.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_CHILDREN 5
#define MAX_TIME 2000    // 最大运行时间(ms)

int pids[MAX_CHILDREN];
int status[MAX_CHILDREN];

// 简单的延迟函数（参考priority.c）
static void spin_delay(void) {
    int i;
    volatile int j;
    for (i = 0; i != 200; ++i) {
        j = !j;
    }
}

/*
 * 测试1: 短作业与长作业混合
 * 目的：测试SJF是否能优化短作业的周转时间
 * 预期：SJF < RR < FIFO 的平均周转时间
 */
void test_short_long_mix(void) {
    int i;
    unsigned int start_time = gettime_msec();
    
    cprintf("\n========== Test 1: Short-Long Job Mix ==========\n");
    cprintf("Job mix: LONG-SHORT-LONG-SHORT-SHORT\n\n");
    
    // 工作量: 长-短-长-短-短 (单位：spin_delay次数)
    int job_lengths[5] = {5000, 500, 5000, 500, 500};
    
    for (i = 0; i < 5; i++) {
        if ((pids[i] = fork()) == 0) {
            int work = job_lengths[i];
            while (work > 0) {
                spin_delay();
                work--;
            }
            
            unsigned int turnaround = gettime_msec() - start_time;
            cprintf("Job %d (work=%d): turnaround=%d ms\n", 
                    i, job_lengths[i], turnaround);
            exit(turnaround);
        }
        if (pids[i] < 0) {
            cprintf("fork failed!\n");
            return;
        }
    }
    
    // 等待所有子进程
    int total = 0;
    for (i = 0; i < 5; i++) {
        waitpid(pids[i], &status[i]);
        total += status[i];
    }
    
    cprintf("\n[Result] Average Turnaround: %d ms\n", total / 5);
    cprintf("[Expect] SJF should have lower avg than FIFO\n");
}

/*
 * 测试2: 公平性测试
 * 目的：测试相同优先级进程是否获得相似的CPU时间
 * 预期：RR最公平，FIFO最不公平
 */
void test_fairness(void) {
    int i;
    
    cprintf("\n========== Test 2: Fairness Test ==========\n");
    cprintf("5 processes with same priority compete for CPU\n\n");
    
    lab6_set_priority(MAX_CHILDREN + 1);
    
    for (i = 0; i < MAX_CHILDREN; i++) {
        if ((pids[i] = fork()) == 0) {
            // 所有进程相同优先级
            lab6_set_priority(5);
            
            unsigned int count = 0;
            unsigned int start = gettime_msec();
            
            while (1) {
                spin_delay();
                count++;
                
                if (count % 2000 == 0) {
                    if (gettime_msec() - start > MAX_TIME) {
                        cprintf("Process %d: work = %d\n", i, count);
                        exit(count);
                    }
                }
            }
        }
        if (pids[i] < 0) {
            cprintf("fork failed!\n");
            return;
        }
    }
    
    for (i = 0; i < MAX_CHILDREN; i++) {
        waitpid(pids[i], &status[i]);
    }
    
    // 计算公平性指标
    int max_w = status[0], min_w = status[0];
    for (i = 1; i < MAX_CHILDREN; i++) {
        if (status[i] > max_w) max_w = status[i];
        if (status[i] < min_w) min_w = status[i];
    }
    
    cprintf("\n[Result] max=%d, min=%d\n", max_w, min_w);
    if (min_w > 0) {
        int ratio = (max_w * 100) / min_w;
        cprintf("[Result] Ratio: %d.%02d (1.00 = perfect)\n", 
                ratio/100, ratio%100);
    }
    cprintf("[Expect] RR: ~1.0, FIFO: >>1.0\n");
}

/*
 * 测试3: 优先级/Stride测试
 * 目的：验证优先级调度是否正确分配CPU时间
 * 预期：Stride调度器的结果接近 5:4:3:2:1
 */
void test_priority(void) {
    int i;
    
    cprintf("\n========== Test 3: Priority/Stride Test ==========\n");
    cprintf("5 processes with priorities 1,2,3,4,5\n\n");
    
    lab6_set_priority(MAX_CHILDREN + 1);
    
    for (i = 0; i < MAX_CHILDREN; i++) {
        if ((pids[i] = fork()) == 0) {
            // 优先级: 1, 2, 3, 4, 5
            lab6_set_priority(i + 1);
            
            unsigned int count = 0;
            unsigned int start = gettime_msec();
            
            while (1) {
                spin_delay();
                count++;
                
                if (count % 2000 == 0) {
                    if (gettime_msec() - start > MAX_TIME) {
                        cprintf("P%d (pri=%d): work=%d\n", i, i+1, count);
                        exit(count);
                    }
                }
            }
        }
        if (pids[i] < 0) {
            cprintf("fork failed!\n");
            return;
        }
    }
    
    for (i = 0; i < MAX_CHILDREN; i++) {
        waitpid(pids[i], &status[i]);
    }
    
    cprintf("\n[Expect] Stride ratio: 5:4:3:2:1\n");
    cprintf("[Result] Actual: ");
    if (status[MAX_CHILDREN-1] > 0) {
        for (i = 0; i < MAX_CHILDREN; i++) {
            int r = (status[i] * 2 / status[MAX_CHILDREN-1] + 1) / 2;
            cprintf("%d", r);
            if (i < MAX_CHILDREN - 1) cprintf(":");
        }
    }
    cprintf("\n");
}

/*
 * 测试4: 上下文切换开销
 * 目的：测量调度器的上下文切换开销
 * 方法：两个进程交替yield
 */
void test_context_switch(void) {
    int i;
    unsigned int start, end;
    int yields = 500;
    
    cprintf("\n========== Test 4: Context Switch Test ==========\n");
    cprintf("Measuring %d yield() calls\n\n", yields);
    
    if (fork() == 0) {
        start = gettime_msec();
        for (i = 0; i < yields; i++) {
            yield();
        }
        end = gettime_msec();
        cprintf("Child:  %d ms for %d yields\n", end - start, yields);
        exit(0);
    } else {
        start = gettime_msec();
        for (i = 0; i < yields; i++) {
            yield();
        }
        end = gettime_msec();
        cprintf("Parent: %d ms for %d yields\n", end - start, yields);
        wait();
    }
    cprintf("\n[Result] Lower time = less overhead\n");
}

/*
 * 测试5: 护航效应测试
 * 目的：测试FIFO的护航效应问题
 * 方法：先启动长作业，再启动短作业
 * 预期：FIFO下短作业等待时间很长，RR/SJF则较短
 */
void test_convoy(void) {
    int i;
    
    cprintf("\n========== Test 5: Convoy Effect Test ==========\n");
    cprintf("1 long job, then 4 short jobs\n\n");
    
    unsigned int start = gettime_msec();
    
    // 先创建一个长作业
    if ((pids[0] = fork()) == 0) {
        int work = 8000;
        while (work > 0) {
            spin_delay();
            work--;
        }
        cprintf("Long job done:  %d ms\n", gettime_msec() - start);
        exit(gettime_msec() - start);
    }
    
    // 稍等让长作业开始
    spin_delay();
    spin_delay();
    
    // 再创建短作业
    for (i = 1; i < MAX_CHILDREN; i++) {
        if ((pids[i] = fork()) == 0) {
            int work = 500;
            while (work > 0) {
                spin_delay();
                work--;
            }
            cprintf("Short job %d: %d ms\n", i, gettime_msec() - start);
            exit(gettime_msec() - start);
        }
    }
    
    for (i = 0; i < MAX_CHILDREN; i++) {
        waitpid(pids[i], &status[i]);
    }
    
    // 计算短作业平均周转时间
    int short_avg = 0;
    for (i = 1; i < MAX_CHILDREN; i++) {
        short_avg += status[i];
    }
    short_avg /= (MAX_CHILDREN - 1);
    
    cprintf("\n[Result] Short jobs avg: %d ms\n", short_avg);
    cprintf("[Expect] FIFO: high (convoy), RR/SJF: low\n");
}

/*
 * 主函数
 */
int main(void) {
    cprintf("\n");
    cprintf("================================================\n");
    cprintf("   Challenge 2: Scheduler Performance Test\n");
    cprintf("================================================\n");
    
    test_short_long_mix();
    test_fairness();
    test_priority();
    test_context_switch();
    test_convoy();
    
    cprintf("\n================================================\n");
    cprintf("             All Tests Completed!\n");
    cprintf("================================================\n\n");
    cprintf("To compare schedulers:\n");
    cprintf("1. Edit kern/schedule/sched.c\n");
    cprintf("2. make clean && make\n");
    cprintf("3. make qemu -> run sched_test\n");
    cprintf("4. Record and compare results\n\n");
    
    return 0;
}
