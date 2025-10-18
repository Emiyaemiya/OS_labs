#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>


#define MAX_OBJ_SIZE 1024   // 最大对象大小
#define MIN_OBJ_SIZE 8      // 最小对象大小
#define PGSIZE 4096         // 页大小 4KB
#define NUM_KMALLOC_CLASSES 8   // 支持的size class数量
#define ALIGN_UP(x, a) (((x) + ((a)-1)) & ~((a)-1))

// -------------------------
// SLUB 核心数据结构
// -------------------------

struct slab {
    struct kmem_cache *cache;   // 属于哪个 cache
    struct Page *page;          // 对应物理页
    size_t inuse;               // 当前使用对象数量
    struct list_entry free_list; // slab 中的空闲对象链表
    struct list_entry list_link; // 链入 cache 的 slab 链表
};

struct kmem_cache {
    const char *name;
    size_t obj_size;             // 对象大小（已对齐）
    size_t objs_per_slab;        // 每个 slab 的对象数
    struct list_entry slabs_partial; // 部分使用 slab
    struct list_entry slabs_full;    // 满的 slab
};

// -------------------------
// 辅助函数
// -------------------------

static size_t
slab_objs_per_slab(size_t obj_size) {
    size_t usable = PGSIZE - sizeof(struct slab);
    return usable / obj_size;
}

static struct slab *
le2slab(struct list_entry *le) {
    return (struct slab*)((char*)le - offsetof(struct slab, list_link));
}

// -------------------------
// SLUB 内部分配接口
// -------------------------

void *__cache_alloc(struct kmem_cache *cache) {
    struct slab *slab = NULL;

    // 若有未满的 slab，直接使用
    if (!list_empty(&cache->slabs_partial)) {
        slab = le2slab(list_next(&cache->slabs_partial));
    } else {
        // 分配新页作为 slab
        struct Page *page = alloc_pages(1);
        if (!page) return NULL;

        struct slab *ns = (struct slab*)KADDR(page2pa(page));
        ns->cache = cache;
        ns->page = page;
        ns->inuse = 0;
        list_init(&ns->free_list);

        // 构造 slab 中的对象链表
        char *obj_base = (char*)ns + sizeof(struct slab);
        for (size_t i = 0; i < cache->objs_per_slab; i++) {
            struct list_entry *le = (struct list_entry*)(obj_base + i * cache->obj_size);
            list_add(&ns->free_list, le);
        }

        list_add(&cache->slabs_partial, &ns->list_link);
        slab = ns;
    }

    // 从 free_list 中取出一个对象
    struct list_entry *obj = list_prev(&slab->free_list);
    list_del(obj);
    slab->inuse++;

    // slab 已满则移入 full 链表
    if (slab->inuse == cache->objs_per_slab) {
        list_del(&slab->list_link);
        list_add(&cache->slabs_full, &slab->list_link);
    }

    return (void*)obj;
}

void __cache_free(struct kmem_cache *cache, void *obj) {
    struct slab *slab = (struct slab*)((uintptr_t)obj & ~(PGSIZE - 1));
    list_add(&slab->free_list, (struct list_entry*)obj);
    slab->inuse--;

    // slab 从 full 变为 partial
    if (slab->inuse + 1 == cache->objs_per_slab) {
        list_del(&slab->list_link);
        list_add(&cache->slabs_partial, &slab->list_link);
    }

    // 目前实现：slab 空了，释放整页

    if (slab->inuse == 0) {
        list_del(&slab->list_link);
        free_pages(slab->page, 1);


        // 真实实现：加载在slabs_partial上，当内存紧张时才将其释放回物理页。                
        // 比如：每释放10个 slab 就真正 free 一次
        
        // static int free_slab_counter = 0;
        // if (++free_slab_counter >= 10) {
        //     free_slab_counter = 0;
        //     list_del(&slab->list_link);
        //     free_pages(slab->page, 1);
        //     return;
        // }

        // // 否则将其放入 partial 链表，等未来重用
        // list_del(&slab->list_link);
        // list_add(&cache->slabs_partial, &slab->list_link);
    }
}

// -------------------------
// kmalloc/kfree 实现（仅小对象）
// -------------------------

static size_t kmalloc_sizes[NUM_KMALLOC_CLASSES] = {8,16,32,64,128,256,512,1024};
static struct kmem_cache kmalloc_caches[NUM_KMALLOC_CLASSES];

static int size_to_class_index(size_t size) {
    if (size == 0) return -1;
    if (size <= MIN_OBJ_SIZE) size = MIN_OBJ_SIZE;
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
        if (size <= kmalloc_caches[i].obj_size)
            return i;
    }
    return NUM_KMALLOC_CLASSES - 1; // 默认取最大1024字节类
}

void slub_init(void) {
    for (int i = 0; i < NUM_KMALLOC_CLASSES; i++) {
        size_t s = ALIGN_UP(kmalloc_sizes[i], sizeof(void*));
        kmalloc_caches[i].name = NULL;
        kmalloc_caches[i].obj_size = s;
        kmalloc_caches[i].objs_per_slab = slab_objs_per_slab(s);
        list_init(&kmalloc_caches[i].slabs_partial);
        list_init(&kmalloc_caches[i].slabs_full);
    }
}

void *kmalloc_bytes(size_t size) {
    if (size == 0) return NULL;
    int idx = size_to_class_index(size);
    return __cache_alloc(&kmalloc_caches[idx]);
}

void kfree_bytes(void *ptr) {
    if (!ptr) return;
    struct slab *sl = (struct slab*)((uintptr_t)ptr & ~(PGSIZE - 1));
    __cache_free(sl->cache, ptr);
}

// -------------------------
// 测试函数
// -------------------------

void slub_check(void) {
    slub_init();

    void *p1 = kmalloc_bytes(32);
    void *p2 = kmalloc_bytes(64);
    void *p3 = kmalloc_bytes(128);

    cprintf("p1=%p, p2=%p, p3=%p\n", p1, p2, p3);

    kfree_bytes(p1);
    kfree_bytes(p2);
    kfree_bytes(p3);

    cprintf("SLUB-only test done.\n");
}
