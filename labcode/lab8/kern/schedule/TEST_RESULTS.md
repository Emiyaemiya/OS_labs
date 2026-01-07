# RR
================================================
   Challenge 2: Scheduler Performance Test
================================================

========== Test 1: Short-Long Job Mix ==========
Job mix: LONG-SHORT-LONG-SHORT-SHORT

Job 0 (work=5000): turnaround=0 ms
Job 1 (work=500): turnaround=0 ms
Job 2 (work=5000): turnaround=10 ms
Job 3 (work=500): turnaround=10 ms
Job 4 (work=500): turnaround=10 ms

[Result] Average Turnaround: 6 ms
[Expect] SJF should have lower avg than FIFO

========== Test 2: Fairness Test ==========
5 processes with same priority compete for CPU

set priority to 6
set priority to 5
set priority to 5
set priority to 5
set priority to 5
set priority to 5
Process 0: work = 940000
Process 1: work = 1042000
Process 2: work = 1054000
Process 3: work = 1058000
Process 4: work = 1042000

[Result] max=1058000, min=940000
[Result] Ratio: 1.12 (1.00 = perfect)
[Expect] RR: ~1.0, FIFO: >>1.0

========== Test 3: Priority/Stride Test ==========
5 processes with priorities 1,2,3,4,5

set priority to 6
set priority to 1
set priority to 2
set priority to 3
set priority to 4
set priority to 5
P0 (pri=1): work=910000
P1 (pri=2): work=1030000
P2 (pri=3): work=1016000
P3 (pri=4): work=1024000
P4 (pri=5): work=1020000

[Expect] Stride ratio: 5:4:3:2:1
[Result] Actual: 1:1:1:1:1

========== Test 4: Context Switch Test ==========
Measuring 500 yield() calls

Parent: 0 ms for 500 yields
Child:  0 ms for 500 yields

[Result] Lower time = less overhead

========== Test 5: Convoy Effect Test ==========
1 long job, then 4 short jobs

Long job done:  10 ms
Short job 1: 10 ms
Short job 2: 10 ms
Short job 3: 10 ms
Short job 4: 10 ms

[Result] Short jobs avg: 10 ms
[Expect] FIFO: high (convoy), RR/SJF: low

================================================
             All Tests Completed!
================================================

To compare schedulers:
1. Edit kern/schedule/sched.c
2. make clean && make
3. make qemu -> run sched_test
4. Record and compare results

================================================
     Scheduler Benchmark Suite
================================================

[Bench 1] CPU-Bound Workload
set priority to 1
set priority to 2
set priority to 3
set priority to 4
set priority to 5
Total throughput: 69535 work units
Per-process: 13864 14040 13995 14047 13589 

[Bench 2] Mixed Workload (2 CPU + 3 IO)
set priority to 3
set priority to 3
set priority to 3
set priority to 3
set priority to 3
CPU-bound total: 70142
IO-bound total:  87

[Bench 3] Response Latency
Response latencies: 0 0 0 0 0 
Average latency: 0 ms

[Bench 4] Priority Ratio Test
Expected ratio (Stride): 5:4:3:2:1
set priority to 6
set priority to 1
set priority to 2
set priority to 3
set priority to 4
set priority to 5
Work done: 27243 27634 27368 27050 27472 
Actual ratio: 1.0:1.0:1.0:1.0:1.0

[Bench 5] Fairness Index (Jain's)
set priority to 6
set priority to 5
set priority to 5
set priority to 5
set priority to 5
set priority to 5
Work done: 27268 27364 27468 27789 27507 
Jain's Fairness Index: 0.999 (1.000 = perfect)

================================================
           Benchmark Complete
================================================

# stride
$ sched_test
================================================
   Challenge 2: Scheduler Performance Test
================================================

========== Test 1: Short-Long Job Mix ==========
Job mix: LONG-SHORT-LONG-SHORT-SHORT

Job 4 (work=500): turnaround=0 ms
Job 3 (work=500): turnaround=0 ms
Job 2 (work=5000): turnaround=0 ms
Job 1 (work=500): turnaround=10 ms
Job 0 (work=5000): turnaround=10 ms

[Result] Average Turnaround: 4 ms
[Expect] SJF should have lower avg than FIFO

========== Test 2: Fairness Test ==========
5 processes with same priority compete for CPU

set priority to 6
set priority to 5
set priority to 5
set priority to 5
set priority to 5
set priority to 5
Process 4: work = 914000
Process 3: work = 930000
Process 1: work = 1154000
Process 2: work = 1128000
Process 0: work = 1392000

[Result] max=1392000, min=914000
[Result] Ratio: 1.52 (1.00 = perfect)
[Expect] RR: ~1.0, FIFO: >>1.0

========== Test 3: Priority/Stride Test ==========
5 processes with priorities 1,2,3,4,5

set priority to 6
set priority to 5
set priority to 4
set priority to 3
set priority to 2
set priority to 1
P4 (pri=5): work=1370000
P3 (pri=4): work=1248000
P2 (pri=3): work=1140000
P1 (pri=2): work=926000
P0 (pri=1): work=766000

[Expect] Stride ratio: 5:4:3:2:1
[Result] Actual: 1:1:1:1:1

========== Test 4: Context Switch Test ==========
Measuring 500 yield() calls

Child:  0 ms for 500 yields
Parent: 0 ms for 500 yields

[Result] Lower time = less overhead

========== Test 5: Convoy Effect Test ==========
1 long job, then 4 short jobs

Short job 4: 0 ms
Short job 3: 0 ms
Short job 2: 0 ms
Short job 1: 10 ms
Long job done:  10 ms

[Result] Short jobs avg: 2 ms
[Expect] FIFO: high (convoy), RR/SJF: low

================================================
             All Tests Completed!
================================================

To compare schedulers:
1. Edit kern/schedule/sched.c
2. make clean && make
3. make qemu -> run sched_test
4. Record and compare results

$ sched_bench
================================================
     Scheduler Benchmark Suite
================================================

[Bench 1] CPU-Bound Workload
set priority to 5
set priority to 4
set priority to 3
set priority to 2
set priority to 1
Total throughput: 67293 work units
Per-process: 5756 9379 13507 18064 20587 

[Bench 2] Mixed Workload (2 CPU + 3 IO)
set priority to 3
set priority to 3
set priority to 3
set priority to 3
set priority to 3
CPU-bound total: 69505
IO-bound total:  90

[Bench 3] Response Latency
Response latencies: 0 0 0 0 0 
Average latency: 0 ms

[Bench 4] Priority Ratio Test
Expected ratio (Stride): 5:4:3:2:1
set priority to 6
set priority to 5
set priority to 4
set priority to 3
set priority to 2
set priority to 1
Work done: 11245 18275 27652 36497 42775 
Actual ratio: 0.3:0.4:0.6:0.9:1.0

[Bench 5] Fairness Index (Jain's)
set priority to 6
set priority to 5
set priority to 5
set priority to 5
set priority to 5
set priority to 5
Work done: 27580 27380 27752 27511 27199 
Jain's Fairness Index: 0.999 (1.000 = perfect)

================================================
           Benchmark Complete
================================================

# FIFO
$ sched_test
================================================
   Challenge 2: Scheduler Performance Test
================================================

========== Test 1: Short-Long Job Mix ==========
Job mix: LONG-SHORT-LONG-SHORT-SHORT

Job 0 (work=5000): turnaround=0 ms
Job 1 (work=500): turnaround=0 ms
Job 2 (work=5000): turnaround=10 ms
Job 3 (work=500): turnaround=10 ms
Job 4 (work=500): turnaround=10 ms

[Result] Average Turnaround: 6 ms
[Expect] SJF should have lower avg than FIFO

========== Test 2: Fairness Test ==========
5 processes with same priority compete for CPU

set priority to 6
set priority to 5
Process 0: work = 4440000
set priority to 5
Process 1: work = 4316000
set priority to 5
Process 2: work = 4354000
set priority to 5
Process 3: work = 4444000
set priority to 5
Process 4: work = 4478000

[Result] max=4478000, min=4316000
[Result] Ratio: 1.03 (1.00 = perfect)
[Expect] RR: ~1.0, FIFO: >>1.0

========== Test 3: Priority/Stride Test ==========
5 processes with priorities 1,2,3,4,5

set priority to 6
set priority to 1
P0 (pri=1): work=4544000
set priority to 2
P1 (pri=2): work=4528000
set priority to 3
P2 (pri=3): work=4628000
set priority to 4
P3 (pri=4): work=4524000
set priority to 5
P4 (pri=5): work=4528000

[Expect] Stride ratio: 5:4:3:2:1
[Result] Actual: 1:1:1:1:1

========== Test 4: Context Switch Test ==========
Measuring 500 yield() calls

Parent: 0 ms for 500 yields
Child:  0 ms for 500 yields

[Result] Lower time = less overhead

========== Test 5: Convoy Effect Test ==========
1 long job, then 4 short jobs

Long job done:  10 ms
Short job 1: 10 ms
Short job 2: 10 ms
Short job 3: 10 ms
Short job 4: 10 ms

[Result] Short jobs avg: 10 ms
[Expect] FIFO: high (convoy), RR/SJF: low

================================================
             All Tests Completed!
================================================

To compare schedulers:
1. Edit kern/schedule/sched.c
2. make clean && make
3. make qemu -> run sched_test
4. Record and compare results

$ sched_bench
================================================
     Scheduler Benchmark Suite
================================================

[Bench 1] CPU-Bound Workload
set priority to 1
set priority to 2
set priority to 3
set priority to 4
set priority to 5
Total throughput: 68422 work units
Per-process: 68422 0 0 0 0 

[Bench 2] Mixed Workload (2 CPU + 3 IO)
set priority to 3
set priority to 3
set priority to 3
set priority to 3
set priority to 3
CPU-bound total: 69022
IO-bound total:  0

[Bench 3] Response Latency
Response latencies: 0 0 0 0 0 
Average latency: 0 ms

[Bench 4] Priority Ratio Test
Expected ratio (Stride): 5:4:3:2:1
set priority to 6
set priority to 1
set priority to 2
set priority to 3
set priority to 4
set priority to 5
Work done: 136873 0 0 0 0 
Actual ratio: 

[Bench 5] Fairness Index (Jain's)
set priority to 6
set priority to 5
set priority to 5
set priority to 5
set priority to 5
set priority to 5
Work done: 138846 0 0 0 0 
Jain's Fairness Index: 0.200 (1.000 = perfect)

================================================
           Benchmark Complete
================================================
# SJF
$ sched_test
================================================
   Challenge 2: Scheduler Performance Test
================================================

========== Test 1: Short-Long Job Mix ==========
Job mix: LONG-SHORT-LONG-SHORT-SHORT

Job 4 (work=500): turnaround=0 ms
Job 2 (work=5000): turnaround=0 ms
Job 0 (work=5000): turnaround=10 ms
Job 1 (work=500): turnaround=10 ms
Job 3 (work=500): turnaround=10 ms

[Result] Average Turnaround: 6 ms
[Expect] SJF should have lower avg than FIFO

========== Test 2: Fairness Test ==========
5 processes with same priority compete for CPU

set priority to 6
set priority to 5
Process 4: work = 4512000
set priority to 5
Process 2: work = 4530000
set priority to 5
Process 0: work = 4568000
set priority to 5
Process 1: work = 4562000
set priority to 5
Process 3: work = 4598000

[Result] max=4598000, min=4512000
[Result] Ratio: 1.01 (1.00 = perfect)
[Expect] RR: ~1.0, FIFO: >>1.0

========== Test 3: Priority/Stride Test ==========
5 processes with priorities 1,2,3,4,5

set priority to 6
set priority to 5
P4 (pri=5): work=4520000
set priority to 3
P2 (pri=3): work=4526000
set priority to 1
P0 (pri=1): work=4304000
set priority to 2
P1 (pri=2): work=4408000
set priority to 4
P3 (pri=4): work=4510000

[Expect] Stride ratio: 5:4:3:2:1
[Result] Actual: 1:1:1:1:1

========== Test 4: Context Switch Test ==========
Measuring 500 yield() calls

Parent: 0 ms for 500 yields
Child:  0 ms for 500 yields

[Result] Lower time = less overhead

========== Test 5: Convoy Effect Test ==========
1 long job, then 4 short jobs

Short job 4: 0 ms
Short job 2: 0 ms
Long job done:  10 ms
Short job 1: 10 ms
Short job 3: 10 ms

[Result] Short jobs avg: 7 ms
[Expect] FIFO: high (convoy), RR/SJF: low

================================================
             All Tests Completed!
================================================

To compare schedulers:
1. Edit kern/schedule/sched.c
2. make clean && make
3. make qemu -> run sched_test
4. Record and compare results

$ sched_bench
================================================
     Scheduler Benchmark Suite
================================================

[Bench 1] CPU-Bound Workload
set priority to 5
set priority to 3
set priority to 1
set priority to 2
set priority to 4
Total throughput: 68374 work units
Per-process: 0 0 0 0 68374 

[Bench 2] Mixed Workload (2 CPU + 3 IO)
set priority to 3
set priority to 3
set priority to 3
set priority to 3
set priority to 3
CPU-bound total: 0
IO-bound total:  317231

[Bench 3] Response Latency
Response latencies: 0 0 0 0 0 
Average latency: 0 ms

[Bench 4] Priority Ratio Test
Expected ratio (Stride): 5:4:3:2:1
set priority to 6
set priority to 5
set priority to 3
set priority to 1
set priority to 2
set priority to 4
Work done: 0 0 0 0 139806 
Actual ratio: 0.0:0.0:0.0:0.0:1.0

[Bench 5] Fairness Index (Jain's)
set priority to 6
set priority to 5
set priority to 5
set priority to 5
set priority to 5
set priority to 5
Work done: 0 0 0 0 139579 
Jain's Fairness Index: 0.200 (1.000 = perfect)

================================================
           Benchmark Complete
================================================

# priority
$ sched_test
================================================
   Challenge 2: Scheduler Performance Test
================================================

========== Test 1: Short-Long Job Mix ==========
Job mix: LONG-SHORT-LONG-SHORT-SHORT

Job 4 (work=500): turnaround=0 ms
Job 2 (work=5000): turnaround=10 ms
Job 0 (work=5000): turnaround=10 ms
Job 1 (work=500): turnaround=10 ms
Job 3 (work=500): turnaround=10 ms

[Result] Average Turnaround: 8 ms
[Expect] SJF should have lower avg than FIFO

========== Test 2: Fairness Test ==========
5 processes with same priority compete for CPU

set priority to 6
set priority to 5
Process 4: work = 4414000
set priority to 5
Process 2: work = 4648000
set priority to 5
Process 0: work = 4682000
set priority to 5
Process 1: work = 4674000
set priority to 5
Process 3: work = 4556000

[Result] max=4682000, min=4414000
[Result] Ratio: 1.06 (1.00 = perfect)
[Expect] RR: ~1.0, FIFO: >>1.0

========== Test 3: Priority/Stride Test ==========
5 processes with priorities 1,2,3,4,5

set priority to 6
set priority to 5
P4 (pri=5): work=4590000
set priority to 3
P2 (pri=3): work=4654000
set priority to 1
P0 (pri=1): work=4692000
set priority to 2
P1 (pri=2): work=4616000
set priority to 4
P3 (pri=4): work=4632000

[Expect] Stride ratio: 5:4:3:2:1
[Result] Actual: 1:1:1:1:1

========== Test 4: Context Switch Test ==========
Measuring 500 yield() calls

Parent: 0 ms for 500 yields
Child:  0 ms for 500 yields

[Result] Lower time = less overhead

========== Test 5: Convoy Effect Test ==========
1 long job, then 4 short jobs

Short job 4: 0 ms
Short job 2: 0 ms
Long job done:  10 ms
Short job 1: 10 ms
Short job 3: 10 ms

[Result] Short jobs avg: 5 ms
[Expect] FIFO: high (convoy), RR/SJF: low

================================================
             All Tests Completed!
================================================

To compare schedulers:
1. Edit kern/schedule/sched.c
2. make clean && make
3. make qemu -> run sched_test
4. Record and compare results

$ sched_bench
================================================
     Scheduler Benchmark Suite
================================================

[Bench 1] CPU-Bound Workload
set priority to 5
set priority to 3
set priority to 1
set priority to 2
set priority to 4
Total throughput: 68232 work units
Per-process: 0 0 0 0 68232 

[Bench 2] Mixed Workload (2 CPU + 3 IO)
set priority to 3
set priority to 3
set priority to 3
set priority to 3
set priority to 3
CPU-bound total: 0
IO-bound total:  314581

[Bench 3] Response Latency
Response latencies: 0 0 0 0 0 
Average latency: 0 ms

[Bench 4] Priority Ratio Test
Expected ratio (Stride): 5:4:3:2:1
set priority to 6
set priority to 5
set priority to 3
set priority to 1
set priority to 2
set priority to 4
Work done: 0 0 0 0 137240 
Actual ratio: 0.0:0.0:0.0:0.0:1.0

[Bench 5] Fairness Index (Jain's)
set priority to 6
set priority to 5
set priority to 5
set priority to 5
set priority to 5
set priority to 5
Work done: 0 0 0 0 132404 
Jain's Fairness Index: 0.200 (1.000 = perfect)

================================================
           Benchmark Complete
================================================

# MLFQ
$ sched_test
================================================
   Challenge 2: Scheduler Performance Test
================================================

========== Test 1: Short-Long Job Mix ==========
Job mix: LONG-SHORT-LONG-SHORT-SHORT

Job 0 (work=5000): turnaround=0 ms
Job 1 (work=500): turnaround=0 ms
Job 2 (work=5000): turnaround=10 ms
Job 3 (work=500): turnaround=10 ms
Job 4 (work=500): turnaround=10 ms

[Result] Average Turnaround: 6 ms
[Expect] SJF should have lower avg than FIFO

========== Test 2: Fairness Test ==========
5 processes with same priority compete for CPU

set priority to 6
set priority to 5
set priority to 5
set priority to 5
set priority to 5
set priority to 5
Process 0: work = 930000
Process 1: work = 982000
Process 2: work = 1018000
Process 3: work = 978000
Process 4: work = 1058000

[Result] max=1058000, min=930000
[Result] Ratio: 1.13 (1.00 = perfect)
[Expect] RR: ~1.0, FIFO: >>1.0

========== Test 3: Priority/Stride Test ==========
5 processes with priorities 1,2,3,4,5

set priority to 6
set priority to 1
set priority to 2
set priority to 3
set priority to 4
set priority to 5
P0 (pri=1): work=994000
P1 (pri=2): work=954000
P2 (pri=3): work=972000
P3 (pri=4): work=996000
P4 (pri=5): work=1000000

[Expect] Stride ratio: 5:4:3:2:1
[Result] Actual: 1:1:1:1:1

========== Test 4: Context Switch Test ==========
Measuring 500 yield() calls

Parent: 0 ms for 500 yields
Child:  0 ms for 500 yields

[Result] Lower time = less overhead

========== Test 5: Convoy Effect Test ==========
1 long job, then 4 short jobs

Long job done:  10 ms
Short job 1: 10 ms
Short job 2: 10 ms
Short job 3: 10 ms
Short job 4: 10 ms

[Result] Short jobs avg: 10 ms
[Expect] FIFO: high (convoy), RR/SJF: low

================================================
             All Tests Completed!
================================================

To compare schedulers:
1. Edit kern/schedule/sched.c
2. make clean && make
3. make qemu -> run sched_test
4. Record and compare results

$ sched_bench
================================================
     Scheduler Benchmark Suite
================================================

[Bench 1] CPU-Bound Workload
set priority to 1
set priority to 2
set priority to 3
set priority to 4
set priority to 5
Total throughput: 68385 work units
Per-process: 14731 14211 14375 12633 12435 

[Bench 2] Mixed Workload (2 CPU + 3 IO)
set priority to 3
set priority to 3
set priority to 3
set priority to 3
set priority to 3
CPU-bound total: 4242
IO-bound total:  287949

[Bench 3] Response Latency
Response latencies: 0 0 0 0 0 
Average latency: 0 ms

[Bench 4] Priority Ratio Test
Expected ratio (Stride): 5:4:3:2:1
set priority to 6
set priority to 1
set priority to 2
set priority to 3
set priority to 4
set priority to 5
Work done: 28024 27549 28319 24332 23741 
Actual ratio: 1.2:1.2:1.2:1.0:1.0

[Bench 5] Fairness Index (Jain's)
set priority to 6
set priority to 5
set priority to 5
set priority to 5
set priority to 5
set priority to 5
Work done: 28482 28169 28439 24915 24154 
Jain's Fairness Index: 0.995 (1.000 = perfect)

================================================
           Benchmark Complete
================================================