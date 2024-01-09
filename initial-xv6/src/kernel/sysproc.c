#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if (growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n)
  {
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_waitx(void)
{
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
  argaddr(1, &addr1); // user virtual memory
  argaddr(2, &addr2);
  int ret = waitx(addr, &wtime, &rtime);
  struct proc *p = myproc();
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    return -1;
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    return -1;
  return ret;
}

// for PBS
int smax(int a, int b)
{
  if (a > b)
    return a;
  return b;
}

int smin(int a, int b)
{
  if (a < b)
    return a;
  return b;
}

int sdp_priority(struct proc *p)
{
  int sp = p->pbs_static_priority;
  int rtime = p->pbs_rtime;
  int wtime = p->pbs_wtime;
  int stime = p->pbs_stime;

  int temp = (3 * rtime - wtime - stime) * 50;
  int temp1 = 1 + rtime + stime + wtime;
  int temp2 = (int)temp / temp1;

  int rbi = smax(0, temp2);
  int dp = smin(100, sp + rbi);

  p->pbs_rbi = rbi;
  p->pbs_dynamic_priority = dp;

  return dp;
}


uint64
sys_setpriority(void)
{
  int pid, priority;
  argint(0, &pid);
  argint(1, &priority);
  int old_static_priority = setpriority(pid, priority);

  if (old_static_priority != -1) 
  {
    int old_dynamic_priority = -1;
    int new_dynamic_priority = -1;
    for (int i = 0; i < NPROC; i++)
    {
      if (proc[i].pid == pid)
      {
        old_dynamic_priority = proc[i].pbs_dynamic_priority;
        // printf("old_dynamic_priority: %d\n", old_dynamic_priority);
        new_dynamic_priority = sdp_priority(&proc[i]);
        // printf("new_dynamic_priority: %d\n", new_dynamic_priority);
        break;
      }
    }

    if (new_dynamic_priority < old_dynamic_priority)
      yield();

  }

  return old_static_priority;
}

