/*
 * sched_bench.c - 调度算法基准测试程序
 * 
 * 提供标准化的测试，方便记录和比较不同调度器的数据
 */

#include <ulib.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define N 5
#define TIME_LIMIT 3000  // 3秒

int pids[N];
int results[N];

static void spin(int cnt) {
    int i;
    volatile int j;
    for (i = 0; i < cnt; i++) {
        for (j = 0; j < 200; j++) { }
    }
}

/*
 * Benchmark 1: CPU-Bound Workload
 * 纯CPU密集型，测试吞吐量
 */
void bench_cpu_bound(void) {
    int i;
    unsigned int start = gettime_msec();
    
    cprintf("\n[Bench 1] CPU-Bound Workload\n");
    
    for (i = 0; i < N; i++) {
        if ((pids[i] = fork()) == 0) {
            lab6_set_priority(i + 1);
            
            int work = 0;
            while (gettime_msec() - start < TIME_LIMIT) {
                spin(100);
                work++;
            }
            exit(work);
        }
    }
    
    int total = 0;
    for (i = 0; i < N; i++) {
        waitpid(pids[i], &results[i]);
        total += results[i];
    }
    
    cprintf("Total throughput: %d work units\n", total);
    cprintf("Per-process: ");
    for (i = 0; i < N; i++) {
        cprintf("%d ", results[i]);
    }
    cprintf("\n");
}

/*
 * Benchmark 2: Mixed Workload
 * 混合负载：2个CPU密集型 + 3个IO密集型
 */
void bench_mixed(void) {
    int i;
    unsigned int start = gettime_msec();
    
    cprintf("\n[Bench 2] Mixed Workload (2 CPU + 3 IO)\n");
    
    for (i = 0; i < N; i++) {
        if ((pids[i] = fork()) == 0) {
            lab6_set_priority(3);  // 相同优先级
            
            int work = 0;
            int is_io = (i >= 2);  // 后3个是IO密集型
            
            while (gettime_msec() - start < TIME_LIMIT) {
                if (is_io) {
                    spin(20);     // 少量计算
                    yield();      // 模拟IO等待
                } else {
                    spin(100);    // 大量计算
                }
                work++;
            }
            exit(work);
        }
    }
    
    int cpu_total = 0, io_total = 0;
    for (i = 0; i < N; i++) {
        waitpid(pids[i], &results[i]);
        if (i < 2) cpu_total += results[i];
        else io_total += results[i];
    }
    
    cprintf("CPU-bound total: %d\n", cpu_total);
    cprintf("IO-bound total:  %d\n", io_total);
}

/*
 * Benchmark 3: Latency Test
 * 测试响应延迟
 */
void bench_latency(void) {
    int i;
    
    cprintf("\n[Bench 3] Response Latency\n");
    
    unsigned int latencies[N];
    
    for (i = 0; i < N; i++) {
        unsigned int t1 = gettime_msec();
        
        if ((pids[i] = fork()) == 0) {
            // 子进程立即退出，返回创建到执行的延迟
            exit(gettime_msec() - t1);
        }
    }
    
    int total_lat = 0;
    for (i = 0; i < N; i++) {
        waitpid(pids[i], &results[i]);
        latencies[i] = results[i];
        total_lat += results[i];
    }
    
    cprintf("Response latencies: ");
    for (i = 0; i < N; i++) {
        cprintf("%d ", latencies[i]);
    }
    cprintf("\n");
    cprintf("Average latency: %d ms\n", total_lat / N);
}

/*
 * Benchmark 4: Priority Ratio
 * 测试优先级比例是否正确
 */
void bench_priority_ratio(void) {
    int i;
    unsigned int start = gettime_msec();
    
    cprintf("\n[Bench 4] Priority Ratio Test\n");
    cprintf("Expected ratio (Stride): 5:4:3:2:1\n");
    
    lab6_set_priority(N + 1);
    
    for (i = 0; i < N; i++) {
        if ((pids[i] = fork()) == 0) {
            lab6_set_priority(i + 1);  // pri: 1,2,3,4,5
            
            int work = 0;
            while (gettime_msec() - start < TIME_LIMIT) {
                spin(50);
                work++;
            }
            exit(work);
        }
    }
    
    for (i = 0; i < N; i++) {
        waitpid(pids[i], &results[i]);
    }
    
    cprintf("Work done: ");
    for (i = 0; i < N; i++) {
        cprintf("%d ", results[i]);
    }
    cprintf("\n");
    
    // 计算比例
    int base = results[N-1];
    cprintf("Actual ratio: ");
    if (base > 0) {
        for (i = 0; i < N; i++) {
            int r = (results[i] * 10 + base/2) / base;  // 四舍五入
            cprintf("%d.%d", r/10, r%10);
            if (i < N-1) cprintf(":");
        }
    }
    cprintf("\n");
}

/*
 * Benchmark 5: Fairness Index
 * 计算 Jain's Fairness Index
 */
void bench_fairness(void) {
    int i;
    unsigned int start = gettime_msec();
    
    cprintf("\n[Bench 5] Fairness Index (Jain's)\n");
    
    lab6_set_priority(N + 1);
    
    for (i = 0; i < N; i++) {
        if ((pids[i] = fork()) == 0) {
            lab6_set_priority(5);  // 所有进程相同优先级
            
            int work = 0;
            while (gettime_msec() - start < TIME_LIMIT) {
                spin(50);
                work++;
            }
            exit(work);
        }
    }
    
    long long sum = 0, sum_sq = 0;
    for (i = 0; i < N; i++) {
        waitpid(pids[i], &results[i]);
        sum += results[i];
        sum_sq += (long long)results[i] * results[i];
    }
    
    cprintf("Work done: ");
    for (i = 0; i < N; i++) {
        cprintf("%d ", results[i]);
    }
    cprintf("\n");
    
    // Jain's Fairness Index = (sum(xi))^2 / (n * sum(xi^2))
    // 范围 1/n 到 1.0，1.0表示完全公平
    if (sum_sq > 0) {
        long long numerator = sum * sum;
        long long denominator = N * sum_sq;
        int jfi = (int)((numerator * 1000) / denominator);
        cprintf("Jain's Fairness Index: 0.%03d (1.000 = perfect)\n", jfi);
    }
}

int main(void) {
    cprintf("\n");
    cprintf("================================================\n");
    cprintf("     Scheduler Benchmark Suite\n");
    cprintf("================================================\n");
    
    bench_cpu_bound();
    bench_mixed();
    bench_latency();
    bench_priority_ratio();
    bench_fairness();
    
    cprintf("\n");
    cprintf("================================================\n");
    cprintf("           Benchmark Complete\n");
    cprintf("================================================\n\n");
    
    return 0;
}
