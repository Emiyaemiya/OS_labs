# <center>lab02实验报告</center>
### 任务一
### 任务二
### 扩展练习一：buddy system 分配算法

本次扩展实现了一个完整可用的伙伴系统物理内存管理器，它将物理内存划分为 2 的幂次大小的块进行管理，以减少外部碎片。

#### 设计文档

**1. 结构设计**

首先设定 `MAX_ORDER` ，我们可以通过直接输出函数 `buddy_init_memmap` 的参数 `n` 来获取最大空闲页数量，可知结果为31929，我们知道2^14是小于该数的最大的2的n次幂，所以我们可以将 `MAX_ORDER` 定为15。

```c
#define MAX_ORDER 15
static free_area_t free_areas[MAX_ORDER];
#define free_list_for_order(order) (free_areas[order].free_list)//
#define nr_free_for_order(order) (free_areas[order].nr_free)

static size_t total_free_pages;//总的空闲页数
static struct Page *buddy_base;//保存最初的base
static size_t buddy_total_pages;//总的纳入buddy算法的页的跨度
```

这里我们根据 `MAX_ORDER` 依次创建了 `free_areas` 的对应数组和起相关方法的宏定义。接着创建了我们的算法（尤其是寻找buddy）中需要用到的几个重要变量。

**2. buddy及memmap的初始化**

```c
static void
buddy_init(void) {
    for (int i = 0; i < MAX_ORDER; i++) {
        list_init(&free_list_for_order(i));
        nr_free_for_order(i) = 0;
    }//初始化整个数组
    total_free_pages = 0;
    buddy_base = NULL;
    buddy_total_pages = 0;//初始化基地址和总页数
}


static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    if (buddy_base == NULL) {
        buddy_base = base;
        buddy_total_pages = 0;
    } else {
        assert(base >= buddy_base);
    }//确保是连续内存块

    for (struct Page *p = base; p < base + n; p++) {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = 0;
        set_page_ref(p, 0);
    }//初始化每个Page结构体

    total_free_pages += n;

    size_t base_offset = base - buddy_base;
    //将连续的 n 页划分成若干个不同 order 的块并加入空闲链表
    size_t offset = 0;
    while (offset < n) {
        size_t remaining = n - offset;//剩余页数
        size_t order = 0;
        while (order + 1 < MAX_ORDER) {
            size_t block_size = 1UL << (order + 1);
            if (block_size > remaining) {//不能再更大了
                break;
            }
            size_t global_offset = base_offset + offset;
            if (global_offset & (block_size - 1)) {
                break;
            }//地址未对齐，不能再更大了
            order++;
        }//找到最大的order
        
        struct Page* page = base + offset;//当前块的起始页
        page->property = order;//设置块的order
        SetPageProperty(page);//加入空闲链表
        __free_page(page, order);
        
        offset += (1UL << order);//移动偏移
    }

    size_t new_total = base_offset + n;
    if (new_total > buddy_total_pages) {
        buddy_total_pages = new_total;
    }//更新总页数
}
```

这里我们需要着重讲解memmap的初始化。因为我们知道，一开始初始化的 `n` 并不是一个2的幂的形式。一般的处理思路是简单的把其中最大的、页数是2的幂的部分空间划出，作为buddy system可分配的空间。但这并不是一个合理的处理方式，因为这样会浪费大量内存看空间。我们本次实验就是个很好的例子，`n` 的值为31929，倘若我们只是简单的割出16384大小的空间，会有将近一半的空间被浪费。因此我们采取了一个贪心的策略，通过设置 `remianing` 变量，逐次向下划分空闲块，直至所有空间都被划为空闲块，大大增加了可分配空间。

这就引出了一个问题，这样真的能实现一个合理的buddy system吗，不会出现合并错误的问题吗？对于一个块来说，当他需要合并时，它需要基于 `buddy_base` ，确定自己到底属于前一个块还是后一个块，换言之，是应该和后一个块结合还是跟前一个块结合。在简单的、由单一最大块分出的buddy system中，这个问题是容易解决的，但我们实现的内容中，这个确实需要思考，会不会出现合并之后造成和最初的分块完全不同的情况，这不是我们所想见到的。

由于我们的块是从大到小排列的，对于每一个页对，初始的分配方式即为其默认分配方式，不会出现配对错误的情况。但倘若我们的块按从小到大排列，就会出现问题：前方的小块会和后面大块中的部分配对，导致整个buddy system一团乱麻。这也是我们选择贪心分配、大块在前的重要原因。

同时这里的对齐检测也是必要的，以便于多次调用 `init_memmap` 后仍可正常执行功能（不过本次实验不会多次调用就是了）。

**3. 占用空闲块**
```c
static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    size_t order = 0;
    while ((1UL << order) < n) {
        order++;
    }//计算需要的最小order

    if (total_free_pages < (1UL << order)) {
        return NULL;
    }//没有足够的页

    size_t current_order;
    for (current_order = order; current_order < MAX_ORDER; current_order++) {
        if (!list_empty(&free_list_for_order(current_order))) {
            break;
        }
    }//找到第一个有空闲块的order

    if (current_order == MAX_ORDER) {
        return NULL;
    }//没有找到合适的块

    list_entry_t* le = list_next(&free_list_for_order(current_order));//取出第一个空闲块
    struct Page* page = le2page(le, page_link);
    list_del(le);//从链表中删除该块
    nr_free_for_order(current_order)--;//减少该order的空闲块计数

    while (current_order > order) {
        current_order--;
        
        // 一个 (current_order + 1) 的块 page，分裂成两个 current_order 的块。
        // 高地址的伙伴块地址 = page 地址 + (1 << current_order)
        struct Page* buddy = page + (1UL << current_order);
        
        // 将高地址的 buddy 块放回空闲链表，并设置正确的 property
        buddy->property = current_order;
        SetPageProperty(buddy);
        __free_page(buddy, current_order);
    }

    ClearPageProperty(page);
    total_free_pages -= (1UL << order);//更新总空闲页数
    return page;
}
```

这部分的逻辑还是相当清晰的。首先计算最小 `order`，在对应的 `free_list` 中寻找对应块，倘若没有则向上遍历，寻找 `order` 更大的快。对于直接找到的块，直接将其在 `free_list` 删除即可；对于向上寻找的到的块，则需将其分裂，直至得到最小 `order`。此时，将位置最低的大小为最小`order`的块删除，其余由大块逐个分割出的小块则放入对应`free_list`。

**4. 释放空闲块**

```c
static struct Page*
get_buddy(struct Page* page, size_t order) {
    if (buddy_base == NULL) {
        return NULL;
    }
    size_t offset = page - buddy_base;//相对base的偏移
    size_t buddy_offset = offset ^ (1UL << order);//取异或找到伙伴
    if (buddy_offset >= buddy_total_pages) {
        return NULL;
    }
    return buddy_base + buddy_offset;//返回伙伴的Page结构体指针
}

static void
__free_page(struct Page* page, size_t order) {
    list_entry_t *le = &free_list_for_order(order);
    while ((le = list_next(le)) != &free_list_for_order(order)) {
        struct Page *p = le2page(le, page_link);
        if (page < p) {
            break;
        }
    }//找到第一个比page大的位置
    list_add_before(le, &(page->page_link));//插入该位置
    nr_free_for_order(order)++;//增加该order的空闲块计数
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    
    size_t order = 0;
    while ((1UL << order) < n) {
        order++;
    }//计算需要的最小order

    struct Page* page = base;
    total_free_pages += (1UL << order);//更新总空闲页数
    // 在尝试合并之前，必须先将当前块加入空闲链表
    page->property = order;
    SetPageProperty(page);
    __free_page(page, order);

    // 合并循环
    while (order < MAX_ORDER - 1) {
        struct Page* buddy = get_buddy(page, order);
        if (buddy == NULL || !PageProperty(buddy) || buddy->property != order) {
            break; // 找不到空闲的、order 相同的伙伴，停止合并
        }

        // 找到了伙伴，可以合并
        // 先将两个子块从低一级的链表中删除
        list_del(&(page->page_link));
        nr_free_for_order(order)--;
        list_del(&(buddy->page_link));
        nr_free_for_order(order)--;
        ClearPageProperty(page);
        
        ClearPageProperty(buddy);

        if (buddy < page) {
            page = buddy;
        }
        order++;//提升到更高的 order
        
        // 将合并后的大块加入高一级的链表
        page->property = order;
        SetPageProperty(page);
        __free_page(page, order);
    }
}
```

这里我们使用 `get_buddy` 函数获取对应块的伙伴快地址。主要思路是首先获取其对于 `base` 的偏移，接着对其进行`size_t buddy_offset = offset ^ (1UL << order)` 找到其伙伴的偏移。如该偏移和泛，则将其返回。

对于 `buddy_free_pages` 函数，也是类似的计算最小 `order`，然后将其加入链表。接着使用上面的 `get_buddy` 找到伙伴、合并、并向上一层 `order` 递归，直至找不到对应伙伴。

**4. 样例测试**

我们创建了函数 `buddy_dump_free_pages` 和 `buddy_check`，分别用展示空闲页信息和样例测试。首先我们可以观测一下初始状态。

```
------ Buddy System Free Page Dump ------
Order 14 (size 16384), 1 blocks:
  - Block at physical address 0x0000000080347000 (page index 839)
Order 13 (size 8192), 1 blocks:
  - Block at physical address 0x0000000084347000 (page index 17223)
Order 12 (size 4096), 1 blocks:
  - Block at physical address 0x0000000086347000 (page index 25415)
Order 11 (size 2048), 1 blocks:
  - Block at physical address 0x0000000087347000 (page index 29511)
Order 10 (size 1024), 1 blocks:
  - Block at physical address 0x0000000087b47000 (page index 31559)
Order 7 (size 128), 1 blocks:
  - Block at physical address 0x0000000087f47000 (page index 32583)
Order 5 (size 32), 1 blocks:
  - Block at physical address 0x0000000087fc7000 (page index 32711)
Order 4 (size 16), 1 blocks:
  - Block at physical address 0x0000000087fe7000 (page index 32743)
Order 3 (size 8), 1 blocks:
  - Block at physical address 0x0000000087ff7000 (page index 32759)
Order 0 (size 1), 1 blocks:
  - Block at physical address 0x0000000087fff000 (page index 32767)
Total free pages: 31929
```

可以看到完全按照我们的思路，从空闲块在内存地址上从大到小排列。

我们首先分配一个大小为16383的空间。
```
------ Buddy System Free Page Dump ------
Order 13 (size 8192), 1 blocks:
  - Block at physical address 0x0000000084347000 (page index 17223)
Order 12 (size 4096), 1 blocks:
  - Block at physical address 0x0000000086347000 (page index 25415)
...
```
order为14的块已被分配

我们接下来连续分配三个大小为8191的空间。

```
Allocated p1: 8191
------ Buddy System Free Page Dump ------
Order 14 (size 16384), 1 blocks:
  - Block at physical address 0x0000000080347000 (page index 839)
Order 12 (size 4096), 1 blocks:
  - Block at physical address 0x0000000086347000 (page index 25415)
...
```

```
Allocated p2: 8191
------ Buddy System Free Page Dump ------
Order 13 (size 8192), 1 blocks:
  - Block at physical address 0x0000000082347000 (page index 9031)
Order 12 (size 4096), 1 blocks:
  - Block at physical address 0x0000000086347000 (page index 25415)
...
```

```
Allocated p3: 8191
------ Buddy System Free Page Dump ------
Order 12 (size 4096), 1 blocks:
  - Block at physical address 0x0000000086347000 (page index 25415)
...
```

分配完后，我们继续 `assert((p4 = alloc_pages(8191)) == NULL);`。运行过程中没有报错，说明这个也通过了，说明没有可被分配的空间。我们把分配的三个8191释放。

接下来分配一个大小为129的空间，尝试把大小为1024的块分裂。

```
...
Order 9 (size 512), 1 blocks:
  - Block at physical address 0x0000000087d47000 (page index 32071)
Order 8 (size 256), 1 blocks:
  - Block at physical address 0x0000000087c47000 (page index 31815)
...
```

可以看到确实被分裂，而且256的块物理地址小于512的块，完全符合预期。


最后，释放所有分配的内容，看到恢复原状，说明我们成功完成了一个完备的buddy system的功能。



### 扩展练习二
### 扩展练习三
