#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

//LAB2 EXERCISE 2: YOUR CODE
// buddy system logic

#define MAX_ORDER 20

static free_area_t free_areas[MAX_ORDER];
#define free_list_for_order(order) (free_areas[order].free_list)
#define nr_free_for_order(order) (free_areas[order].nr_free)

static size_t total_free_pages;
static struct Page *buddy_base;
static size_t buddy_total_pages;

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
            }
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
static size_t
buddy_nr_free_pages(void) {
    return total_free_pages;
}

static void
buddy_dump_free_pages(void) {
    cprintf("------ Buddy System Free Page Dump ------\n");
    for (int order = 14; order >=0; order--) {
        if (!list_empty(&free_list_for_order(order))) {
            cprintf("Order %d (size %lu), %u blocks:\n", order, (1UL << order), nr_free_for_order(order));
            list_entry_t *le = &free_list_for_order(order);
            while ((le = list_next(le)) != &free_list_for_order(order)) {
                struct Page *p = le2page(le, page_link);
                cprintf("  - Block at physical address 0x%016lx (page index %ld)\n", page2pa(p), p - pages);
            }
        }
    }
    cprintf("Total free pages: %lu\n", total_free_pages);
    cprintf("-----------------------------------------\n");
}//展示空闲页信息

static void
buddy_check(void) {
    struct Page *p0, *p1, *p2, *p3, *p4, *p5;
    p0 = p1 = p2 = p3 = p4 = p5 = NULL;
    cprintf("Original State:\n");
    buddy_dump_free_pages();

    assert((p0 = alloc_pages(16383)) != NULL);
    cprintf("Allocated p0: %p\n", p0);
    buddy_dump_free_pages();
    free_pages(p0, 16383);
    
    assert((p1 = alloc_pages(8191)) != NULL);
    cprintf("Allocated p1: 8191\n", p1);
    buddy_dump_free_pages();
    assert((p2 = alloc_pages(8191)) != NULL);
    cprintf("Allocated p2: 8191\n", p2);
    buddy_dump_free_pages();
    assert((p3 = alloc_pages(8191)) != NULL);
    cprintf("Allocated p3: 8191\n", p3);
    buddy_dump_free_pages();
    assert((p4 = alloc_pages(8191)) == NULL);
    cprintf("Attempted to allocate p4: 8191, expected NULL, got %p\n", p4);
    buddy_dump_free_pages();


    free_pages(p1, 8191);
    free_pages(p2, 8191);
    free_pages(p3, 8191);
    
    cprintf("Freed p1, p2, p3:\n");
    buddy_dump_free_pages();
    assert((p4 = alloc_pages(129)) != NULL);
    cprintf("Allocated p4: 129\n", p4);
    buddy_dump_free_pages();

    assert((p5 = alloc_pages(513)) != NULL);
    cprintf("Allocated p5: 513\n", p5);
    buddy_dump_free_pages();

    free_pages(p4, 129);
    free_pages(p5, 513);
    cprintf("Freed p4, p5:\n");
    buddy_dump_free_pages();
    cprintf("buddy_check() succeeded!\n");



}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
