// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

#define TEMP (PGROUNDUP(PHYSTOP) / PGSIZE)

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run
{
  struct run *next;
};

struct
{
  struct spinlock lock;
  struct run *freelist;
} kmem;


// for COW
int temp[TEMP];
struct spinlock temp_lock;

void check_and_increment(uint64 pno)
{

  if (temp[pno] < 0)
  {
    panic("Increment problem");
  }
  else
  {
    acquire(&temp_lock);
    temp[pno]++;
    release(&temp_lock);
  }
}

void kinit()
{
  initlock(&kmem.lock, "kmem");

  // for COw
  initlock(&temp_lock, "temp_lock");
  acquire(&temp_lock);
  for (int i = 0; i < TEMP; i++)
  {
    temp[i] = 1;
  }
  release(&temp_lock);

  freerange(end, (void *)PHYSTOP);
}

void freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char *)PGROUNDUP((uint64)pa_start);
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
  struct run *r;

  // if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
  //   panic("kfree");

  // for COW
  acquire(&temp_lock);
  uint64 pno = (uint64)pa / PGSIZE;
  int flag = temp[pno];
  
  if (flag > 0)
  {
    temp[pno]--;
    release(&temp_lock);
    if (flag>1)
    {
      return;
    }
  }
  else
  {
    panic("Error");
    release(&temp_lock);
  }

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run *)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if (r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk

  // for COw
  if (r)
  {
    check_and_increment((uint64)r / PGSIZE);
  }

  return (void *)r;
}
