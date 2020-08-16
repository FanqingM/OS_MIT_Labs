# Lab3

### Lab3介绍

提交`make clean && make handin`

Lab3的任务是提供一个用户保护的运行环境

### Lab3实现目标

+ 需要增强JOS内核，建立一个数据结构来跟踪记录用户环境
+ 创建单用户的用户环境，把运行程序镜像载入，并运行
+ 你的内核还要能处理相应用户环境里的程序的系统调用以及各种异常

### Lab3可以分为2部分

+ Part A
  用户环境和异常处理
+ Part B
  页面错误处理、断点处理、系统调用处理

## Part A : User Environments and Exception Handling

在这部分，我们需要设计JOS内核来创建和支持用户环境。

阅读`inc/env.h`，可以看到Env结构体，内核要用该结构体来跟踪用户环境。

接下来看`kern/env.c`

```c
struct Env *envs = NULL;                // All environments
struct Env *curenv = NULL;              // The current env
static struct Env *env_free_list;       // Free environment list
                                        // (linked by Env->env_link)
```

内核用这三个结构来控制用户环境

内核运行开始时，`envs`指向一个Env数组（该数组一一对应所有的Environment）和之前Page的思想蕾丝。在JOS里，作者设计的是最多同时运行NEVN个environment，也就是说初始化时NEVN是数组的个数。

#### Environment State

```c
struct Env {
	struct Trapframe env_tf;	// Saved registers
	struct Env *env_link;		// Next free Env
	envid_t env_id;			// Unique environment identifier
	envid_t env_parent_id;		// env_id of this env's parent
	enum EnvType env_type;		// Indicates special system environments
	unsigned env_status;		// Status of the environment
	uint32_t env_runs;		// Number of times environment has run

	// Address space
	pde_t *env_pgdir;		// Kernel virtual address of page dir
};
```

变量说明

**env_tf**:

这个结构体⽤于保存寄存器,内核切换environment时⽤的。

**env_link**:

⽤于env_free_list,指向下⼀个空闲environment

**env_id**:

内核⽤该值储存⼀个唯⼀标识. 在⼀个⽤户environment终⽌后,内核可⽤重申请同⼀个Env结构⽤ 于不同的environment,新的environment会有不同的env_id.

**env_parent_id**:

内核⽤该值存创建该environment的environment，这样environment就可以形成⼀个树,可以 ⽤于做安全判断environment是否被允许对某物做某事.

**env_type**:

⽤于区分ENV_TYPE_USER(⼤多数)和ENV_TYPE_IDLE,在未来的lab⾥会⽤

**env_status**:

This variable holds one of the following values:

- `ENV_FREE`:

  ⾮活跃 在env_free_list中

- `ENV_RUNNABLE`:

  活跃 已准备好 等待run

- `ENV_RUNNING`:

  活跃 当前正在 run

- `ENV_NOT_RUNNABLE`:

  活跃 但未准备好，⽐如在等待另⼀个environment的interprocess communication (IPC)

**env_pgdir**:

保存kernel virtual address of this environment's page directory.

### Exercise 1

> 修改 `kern/pmap.c` 中的 `mem_init()` 申请并映射envs数组. 数组元素为NENV个,同时envs的权限为 (user read-only)只读,最终⽤ `check_kern_pgdir() `检测是否正确。

查看`inc.memlayout.h`看到UENVS这一块大小为PTSIZE

所以新增两段代码为（在对应提示位置）

```c
				//////////////////////////////////////////////////////////////////////
        // Make 'envs' point to an array of size 'NENV' of 'struct Env'.
        // LAB 3: Your code here.
        envs = (struct Env*) boot_alloc(sizeof(struct Env) * NENV); //allocated
```

```c
        //////////////////////////////////////////////////////////////////////
        // Map 'pages' read-only by the user at linear address UPAGES
        // Permissions:
        //    - the new image at UPAGES -- kernel R, user R
        //      (ie. perm = PTE_U | PTE_P)
        //    - pages itself -- kernel RW, user NONE
        // Your code goes here:
        boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
```

运行`make emu-nox`可以看到

```bash
check_kern_pgdir() succeeded!
check_page_free_list done
check_page_installed_pgdir() succeeded!
kernel panic at kern/env.c:460: env_run not yet implemented
```

#### Creating and Running Environments

因为我们尚⽆⽂件系统,我们要运⾏的程序都是嵌⼊在kernel内部的,作为elf镜像嵌⼊,我们将要运⾏的源 程序都在 `user/ `⾥,编译后的在 `obj/user/` ⾥。

### Exercise 2

> 在`kern/env.c`z中实现特定的函数

#### env_init()

`env_init()` 初始化envs并且把它们加⼊` env_free_list `. 并调⽤ `env_init_percpu()` (它配置段硬 件并配置权限0(内核)权限3(⽤户)),参照` pages_init() `实现如下

```c
// Mark all environments in 'envs' as free, set their env_ids to 0,
// and insert them into the env_free_list.
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
        // Set up envs array
        // LAB 3: Your code here.
        int i;
        for(i = NENV - 1;i >= 0; i--){
                envs[i].env_link = env_free_list;
                env_free_list = &envs[i];
        }
        // Per-CPU part of the initialization
        env_init_percpu();
}
```

#### Env_setup_vm

`env_setup_vm()` 为新环境申请⼀个⻚页⽬录 ，并初始化这个新的environment的内核地址空间部分。

这⾥建⽴⼀个独⾃的pgdir,但只拷⻉贝UTOP以上,故可以⽤ `memmove(e->env_pgdir, kern_pgdir, PGSIZE)` 把 `kern_pgdir` 复制⼀份放到 e->env_pgdir 并设置 UVPT 在PD中的对应位置的PDE。

```c
// Initialize the kernel virtual memory layout for environment e.
// Allocate a page directory, set e->env_pgdir accordingly,
// and initialize the kernel portion of the new environment's address space.
// Do NOT (yet) map anything into the user portion
// of the environment's virtual address space.
//
// Returns 0 on success, < 0 on error.  Errors include:
//      -E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
        int i;
        struct PageInfo *p = NULL;

        // Allocate a page for the page directory
        if (!(p = page_alloc(ALLOC_ZERO)))
                return -E_NO_MEM;

        // Now, set e->env_pgdir and initialize the page directory.
        //
        // Hint:
        //    - The VA space of all envs is identical above UTOP
        //      (except at UVPT, which we've set below).
        //      See inc/memlayout.h for permissions and layout.
        //      Can you use kern_pgdir as a template?  Hint: Yes.
        //      (Make sure you got the permissions right in Lab 2.)
        //    - The initial VA below UTOP is empty.
        //    - You do not need to make any more calls to page_alloc.
        //    - Note: In general, pp_ref is not maintained for
        //      physical pages mapped only above UTOP, but env_pgdir
        //      is an exception -- you need to increment env_pgdir's
        //      pp_ref for env_free to work correctly.
        //    - The functions in kern/pmap.h are handy.

        // LAB 3: Your code here.
        p->pp_ref++;
        e->env_pgdir = (pde_t*) page2kva(p);
        memcpy(e->env_pgdir,kern_pgdir,PGSIZE);//kern_pgdir as template

        // UVPT maps the env's own page table read-only.
        // Permissions: kernel R, user R
        e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;

        return 0;
}
```

#### region_alloc()

`region_alloc(struct Env *e, void *va, size_t len) `申请len字节的物理地址地址空间,并把它

映射到虚拟地址va上。

注释提示不要初始化为0或其它操作,⻚页需要能被⽤户写,如果任何步骤出错panic，另外需要注意⻚页对 ⻬齐。

回想lab2 我们有把物理地址和虚拟地址的映射的函数,也有把虚拟地址和PageInfo做映射的函数，实现 思路为:

+ 计算va起始和末尾

+ for(起始 to 末尾){

  申请页 不要做任何初始化操作

  申请失败则Panic

  把该页和for的va映射 注意权限位

  }

实现如下：

```c
// Allocate len bytes of physical memory for environment env,
// and map it at virtual address va in the environment's address space.
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
        // LAB 3: Your code here.
        // (But only if you need it for load_icode.)
        //
        // Hint: It is easier to use region_alloc if the caller can pass
        //   'va' and 'len' values that are not page-aligned.
        //   You should round va down, and round (va + len) up.
        //   (Watch out for corner-cases!)
        uintptr_t va_start = (uintptr_t)ROUNDDOWN(va , PGSIZE);
        uintptr_t va_end = (uintptr_t)ROUNDUP(va + len, PGSIZE);
        uintptr_t i;
        for(i = va_start; i < va_end; i += PGSIZE){
                struct PageInfo *pg = page_alloc(0);//no initialization
                if(!pg){
                        panic("region_alloc failed!");
                }
                page_insert(e->env_pgdir, pg, (void*)i, PTE_W|PTE_U);//read and write
        }

}
```

#### load_icode

`load_icode(struct Env *e, uint8_t *binary, size_t size)` 是⽤来解析ELF⼆进制⽂件的,和

boot loader已经完成了的⼯作很像,把⽂件内容装载进新的⽤户环境。该函数只会在内核初始化时,第⼀ 个⽤户模式环境开始前,调⽤。

该函数把ELF⽂件装载到适当的⽤户环境中,从适当的虚拟地址位置开始执⾏,清零程序头部标记的段,可以 参考 `boot/main.c` (该部分是从磁盘读取的)

阅读注释，我们需要加载 `ph->p_type == ELF_PROG_LOAD` 的 ph 的,

+ 每个段的虚拟地址`ph->p_va`
+ 内存⼤⼩ `ph->p_memsz` 字节
+ ⽂件⼤⼩ `ph->p_filesz` 字节 
+ 需要把 `binary + ph->p_offset `拷⻉贝到 `ph->p_va` ,其余的内存需要被清零 
+ 设置其对于⽤户可写 
+ ELF 段不必⻚页对⻬齐,可以假设没有两个段会使⽤同⼀个虚拟⻚页⾯ 
+ 建议函数` region_alloc`

参考 `boot/main.c` 中的` bootmain() `函数,其中readseg为读磁盘,之后为获得ph,把 `ph~eph `读⼊了内存, 然后执⾏,那我们的实现思路为:

+ 读取binary 判断是否为ELF 

+ 切换cr3 

+ for(ph~eph){ 

  注意判断是否为`ELF_PROG_LOAD `

  通过 `region_alloc` 来申请va以及memsz 

  清零所有 

  复制程序的ﬁlesz

   } 

+ 复原cr3 为 `kern_pgdir`

实现如下：

```c
// Set up the initial program binary, stack, and processor flags
// for a user process.
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
//
// This function loads all loadable segments from the ELF binary image
// into the environment's user memory, starting at the appropriate
// virtual addresses indicated in the ELF program header.
// At the same time it clears to zero any portions of these segments
// that are marked in the program header as being mapped
// but not actually present in the ELF file - i.e., the program's bss section.
//
// All this is very similar to what our boot loader does, except the boot
// loader also needs to read the code from disk.  Take a look at
// boot/main.c to get ideas.
//
// Finally, this function maps one page for the program's initial stack.
//
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
        // Hints:
        //  Load each program segment into virtual memory
        //  at the address specified in the ELF segment header.
        //  You should only load segments with ph->p_type == ELF_PROG_LOAD.
        //  Each segment's virtual address can be found in ph->p_va
        //  and its size in memory can be found in ph->p_memsz.
        //  The ph->p_filesz bytes from the ELF binary, starting at
        //  'binary + ph->p_offset', should be copied to virtual address
        //  ph->p_va.  Any remaining memory bytes should be cleared to zero.
        //  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
        //  Use functions from the previous lab to allocate and map pages.
        //
        //  All page protection bits should be user read/write for now.
        //  ELF segments are not necessarily page-aligned, but you can
        //  assume for this function that no two segments will touch
        //  the same virtual page.
        //
        //  You may find a function like region_alloc useful.
        //
        //  Loading the segments is much simpler if you can move data
        //  directly into the virtual addresses stored in the ELF binary.
        //  So which page directory should be in force during
        //  this function?
        //
        //  You must also do something with the program's entry point,
        //  to make sure that the environment starts executing there.
        //  What?  (See env_run() and env_pop_tf() below.)

        // LAB 3: Your code here.
        struct Elf * elf = (struct Elf *) binary;
        struct Proghdr *ph, *eph;
        //valid elf?
        if(elf->e_magic != ELF_MAGIC){
                panic("load_icode failed! invalid ELF!");
        }
        ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
              eph = ph +elf->e_phnum;

              //switch cr3
              lcr3(PADDR(e->env_pgdir));

              for(;ph < eph;ph++){
                      if(ph->p_type == ELF_PROG_LOAD){
                              region_alloc(e,(void*)ph->p_va,ph->p_memsz);
                              memset((void*)ph->p_va,0,ph->p_memsz);
                              memmove((void*)ph->p_va,
                              binary+ph->p_offset,ph->p_filesz);
                      }
              }
              lcr3(PADDR(kern_pgdir));
              e->env_tf.tf_eip = elf->e_entry;
              // Now map one page for the program's initial stack
              // at virtual address USTACKTOP - PGSIZE.

              // LAB 3: Your code here.
              region_alloc(e,(void*)(USTACKTOP-PGSIZE),PGSIZE);
      }

  
```

#### env_create()

`env_create() `申请 environment并调⽤` load_icode` 来装载ELF binary到申请的environment中，只会在kernel初始化的时候执⾏⼀次,并且new environment的parent id设为0。注释提示使⽤函数 `env_alloc()`

```c
// Allocates a new env with env_alloc, loads the named elf
// binary into it with load_icode, and sets its env_type.
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
        // LAB 3: Your code here.
        struct Env *e;
        int i = env_alloc(&e,0);
        if(i != 0){
                panic("env_create: %e",i);
        }
        e->env_type = type;
        load_icode(e,binary);
}
```

#### env_run()

`env_run(struct Env *e) `在⽤户态运⾏给定的environment。

查看注释

+ 如果有正在运⾏的程序并且不是它⾃⼰,则把当前运⾏的程序设为RUNNABLE ( `curenv , env_status` ) 
+ 设置当前正在运⾏的为e ( `curenv , env_status` ) 
+ 更新 `e->env_runs` 的计数 
+ 和上⾯⼀样⽤ `lcr3()` 切换cr3 
+ ⽤ `env_pop_tf()` 重新加载环境寄存器 
+ 检查之前的函数 `e->env_tf` 的值是否正确

```c
// Context switch from curenv to env e.
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e)
{
        // Step 1: If this is a context switch (a new environment is running):
        //         1. Set the current environment (if any) back to
        //            ENV_RUNNABLE if it is ENV_RUNNING (think about
        //            what other states it can be in),
        //         2. Set 'curenv' to the new environment,
        //         3. Set its status to ENV_RUNNING,
        //         4. Update its 'env_runs' counter,
        //         5. Use lcr3() to switch to its address space.
        // Step 2: Use env_pop_tf() to restore the environment's
        //         registers and drop into user mode in the
        //         environment.

        // Hint: This function loads the new environment's state from
        //      e->env_tf.  Go back through the code you wrote above
        //      and make sure you have set the relevant parts of
        //      e->env_tf to sensible values.

        // LAB 3: Your code here.
        if(curenv != e){
                if(curenv && curenv->env_status == ENV_RUNNING){
                        curenv->env_status = ENV_RUNNABLE;
                }
                curenv = e;
                e->env_status = ENV_RUNNING;
                e->env_runs++;
                lcr3(PADDR(e->env_pgdir));

        }
        env_pop_tf(&e->env_tf);
        //panic("env_run not yet implemented");
}
```

⾄此 我们实现了⽤户环境的装⼊、运⾏、切换。 

⽤户程序的唤起顺序如下:

1. start (kern/entry.S)
2. i386_init (kern/init.c)
   + cons_init
   + mem_init
   + env_init
   + trap_init (still incomplete at this point)
   + env_create
   + env_run
     + env_pop_tf

现在我们可以使⽤gdb查看函数是否⼯作正常：

```bash
(gdb) b env_pop_tf
Breakpoint 1 at 0xf01039ee: file kern/env.c, line 469.
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0xf01039ee <env_pop_tf>:	push   %ebp

Breakpoint 1, env_pop_tf (tf=0xf01b2000) at kern/env.c:469
469	{
(gdb) s
=> 0xf0103a00 <env_pop_tf+18>:	mov    0x8(%ebp),%esp
470		asm volatile(
(gdb) si
=> 0xf0103a03 <env_pop_tf+21>:	popa
0xf0103a03	470		asm volatile(
(gdb) si
=> 0xf0103a04 <env_pop_tf+22>:	pop    %es
0xf0103a04 in env_pop_tf (tf=<error reading variable: Unknown argument list address for `tf'.>) at kern/env.c:470
470		asm volatile(
(gdb) si
=> 0xf0103a05 <env_pop_tf+23>:	pop    %ds
0xf0103a05	470		asm volatile(
(gdb) si
=> 0xf0103a06 <env_pop_tf+24>:	add    $0x8,%esp
0xf0103a06	470		asm volatile(
(gdb) si
=> 0xf0103a09 <env_pop_tf+27>:	iret
0xf0103a09	470		asm volatile(
(gdb) si
=> 0x800020:	cmp    $0xeebfe000,%esp
0x00800020 in ?? ()
```

到⽬前这步， `int $0x30 system`的⽤户系统调⽤是⼀个死循环,⼀旦从内核态进⼊⽤户态就回不来了, 现在要实现基本的 exception和系统调⽤的处理,以致内核能从⽤户态代码拿回处理器控制权。

### Exercise 3

#### Basics of Protected Control Transfer

Exceptions 和 interrupts 都是 protected control transfers ,都是让处理器从⽤户态(CPL=3) 转为 内核态(CPL=0)。 同时也不会给⽤户态代码任何⼲扰内核运⾏的机会,在intel的术语中interrupt通常为处 理器外部异步事件引起的 protected control transfers ，⽐如外部I/O活动。作为对⽐，exception 为同步事件引起的 protected control transfers ，例如除0、访问⽆效内存等。

为了确保这些 protected control transfers 能真正的起到保护作⽤,因此设计的是当exception或 interrupt发⽣时,并不是任意的进⼊内核,⽽是处理器要确保内核能控制才会进⼊,⽤了以下两个⽅法:

1. The Interrupt Descriptor Table

   也就是IDT,该表让processer设置内核对特定中断的特定的⼊⼝点，⽽不会继续执⾏错误的代码，x86系 统允许256个不同的interrupt/exception⼊⼝点，即interrupt vector (也就是0~255的整数)，中断类型 决定⼀个数值，CPU⽤interrupt vector的值作为index在IDT中找值放⼊eip，也就是指向内核处理该错 误的函数⼊⼝。另外，加载到代码段(CS)寄存器中的值,第0-1位包括要运⾏异常处理程序的权限级别。 (在JOS中,所有异常都在内核模式下处理,权限级别为0)。

   简单的说就是不同的错误(interrupt/exception)会发出不同的值(0~255)，然后cpu再根据该值在IDT中找 处理函数⼊⼝，所以我们的任务要去配置IDT表，以及实现对应的处理函数。

2. The Task State Segment.

   在中断前需要保存当前程序的寄存器等，在处理完后回重新赋值这些寄存器，所以保存的位置需要不被 ⽤户修改 否则在重载时可能造成危害。

   因此x86在 处理interrupt/trap，模式从⽤户转换到内核时,它还会转换到⼀个内核内存⾥的栈(⼀个叫做 TSS(task state segment )的结构体)，处理器把SS, ESP, EFLAGS, CS, EIP, 和⼀个 optional error code push到这个栈上,然后它再从IDT的配置⾥设置CS和EIP的值，再根据新的栈设置ESP和SS。

   虽然 TSS很⼤并有很多⽤途,但对于jos的lab我们只⽤它来定义处理器在从⽤户模式转换到内核模式时,应 切换的堆栈。x86上JOS在kernel态的权限级别为0，在进⼊内核模式时，处理器⽤TSS的ESP0 和SS0两 个字段来定义内核栈 ，JOS不使⽤其它的TSS字段。

#### Types of Exceptions and Interrupts

x86 能⽣成的所有同步exceptions的值(interrupt vector) 在0~31,⽐如page fault 会触发14号,＞31的部 分是给软件中断使⽤的,可以由int 指令⽣成或外部异步硬件产⽣。

#### An Example

⽤⼀个example来说明,如果⽤户程序执⾏除0

1. 处理器根据TSS的SS0和ESP0字段切换栈(这两个字段在JOS会分别设为 GD_KD 和 KSTACKTOP )
2. 处理器按照以下格式push exception参数到 内核栈上

```bash
                     +--------------------+ KSTACKTOP             
                     | 0x00000 | old SS   |     " - 4
                     |      old ESP       |     " - 8
                     |     old EFLAGS     |     " - 12
                     | 0x00000 | old CS   |     " - 16
                     |      old EIP       |     " - 20 <---- ESP 
                     +--------------------+   
```

3. 因为我们要处理 除0 错误,对应 interrupt vector的值为0,在x86中处理器去读配置的IDT表配置的0号的⼊⼝，然后设置CS:EIP指向该⼊⼝
4. 然后该处理函数处理，⽐如终⽌⽤户程序。

对于明确的错误 ⽐如上⾯的除0 ,处理器还会把 错误号push上去 也就是interrupt vector

```bash
                     +--------------------+ KSTACKTOP             
                     | 0x00000 | old SS   |     " - 4
                     |      old ESP       |     " - 8
                     |     old EFLAGS     |     " - 12
                     | 0x00000 | old CS   |     " - 16
                     |      old EIP       |     " - 20
                     |     error code     |     " - 24 <---- ESP
                     +--------------------+ 
```

#### Nested Exceptions and Interrupts

处理器在内核态和⽤户态都可以处理 exceptions和interrupts。但只有从⽤户态转换到内核态时，在 push old 寄存器前，处理器会⾃动转换栈，并根据IDT配置调⽤适当的exception处理程序。如果发⽣interrupt/exception时 已经在内核态( CS寄存器的低两位为0)，那么CPT只会push 更多的值在同⼀个内核栈上，这种情况下，内核可以优雅的处理内核⾃⼰引发的嵌套exceptions。这种能⼒是实现保护的重要途径。

如果说发⽣exceptions或interrupts时本身就在内核态，那么也就不需要储存old SS和EIP，以不push error code 的exception/interrupt为例,内核栈⻓长这样

```bash
                     +--------------------+ <---- old ESP
                     |     old EFLAGS     |     " - 4
                     | 0x00000 | old CS   |     " - 8
                     |      old EIP       |     " - 12
                     +--------------------+
```

⼀个需要注意的点是，内核处理嵌套exceptions能⼒有限，若已经在内核态并接受到⼀个exception， ⽽且还不能push它old state到内核栈上(⽐如栈空间不够了)，那么这样的处理⽆法恢复，因此它会简单 地reset它⾃⼰,我们不应让这样的情况发⽣。

#### Setting Up the IDT

接下来，我们将要设置 IDT的0~31,⼀会还要设置system call interrupt,在未来的lab会设置 32~47(device IRQ)

阅读 inc/trap.h 和 kern/trap.h , inc/trap.h 定义了 ⼀些interrupt vector的常量宏和两个数据结 构PushRegs和Trapframe。 kern/trap.h 则定义的是两个全局变量 extern struct Gatedesc idt[]; 和 extern struct Pseudodesc idt_pd; 以及⼀堆函数的申明

关于 Gatedesc 和 Pseudodesc 这两个结构体的定义可以在inc/mmu.h中找到

Note: 0~31 有些是保留定义的,但在lab⾥并不会由processer产⽣,它们的处理函数怎么写也⽆所谓,可以

按我们认为最简洁的处理。

整个流程如下所画：

```bash
      IDT                   trapentry.S         trap.c
   
+----------------+                        
|   &handler1    |---------> handler1:          trap (struct Trapframe *tf)
|                |             // do stuff      {
|                |             call trap          // handle the exception/interrupt
|                |             // ...           }
+----------------+
|   &handler2    |--------> handler2:
|                |            // do stuff
|                |            call trap
|                |            // ...
+----------------+
       .
       .
       .
+----------------+
|   &handlerX    |--------> handlerX:
|                |             // do stuff
|                |             call trap
|                |             // ...
+----------------+
```

每⼀个 exception/interrupt 需要在trapentry.S有它⾃⼰的handler, trap_init() 函数要做的是把 IDT 中填上这些handler函数的地址,每⼀个handler需要建⽴⼀个 struct Trapframe 在 //do stuff 的位 置,然后 调⽤trap.c中的trap函数,然后trap再处理具体的exception/interrupt或者分发给更具体的处理函 数。

### Exercise 4

分析：

先看宏 `TRAPHANDLER(name, num)` 注释中说需要在trap.c中定义⼀个类似 `void NAME()`; 的函数，然 后把NAME作为参数传给 TRAPHANDLER(name, num) ，num为错误号， TRAPHANDLER_NOEC 是NO ERROR CODE的版本。这两个宏实际是函数模板,这⾥我们⽤这两个宏来实现上⾯图中trapentry.S的 handlerX的部分,关于哪个vector会push 错误号。

再根据trap.h⾥定义的,我们的实现为

```c
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(DivideEntry, T_DIVIDE) // 0 divide error
TRAPHANDLER_NOEC(DebugEntry, T_DEBUG) // 1 debug exception
TRAPHANDLER_NOEC(NoMaskEntry, T_NMI) // 2 non-maskable interrupt
TRAPHANDLER_NOEC(BreakEntry, T_BRKPT) // 3 break point
TRAPHANDLER_NOEC(OverFlowEntry,T_OFLOW) // 4 over flow
TRAPHANDLER_NOEC(BoundsEntry, T_BOUND) // 5 bounds check
TRAPHANDLER_NOEC(OpCodeEntry, T_ILLOP) // 6 illegal opcode
TRAPHANDLER_NOEC(DeviceEntry, T_DEVICE) // 7 device not available

TRAPHANDLER(SysErrorEntry,  T_DBLFLT) // 8 system error

TRAPHANDLER(TaskSwitchEntry, T_TSS) // 10 invalid task switch segment
TRAPHANDLER(SegmentEntry, T_SEGNP) // 11 segment not present
TRAPHANDLER(StackEntry, T_STACK) // 12 stack exception
TRAPHANDLER(ProtectEntry, T_GPFLT) // 13 general protection error
TRAPHANDLER(PageEntry, T_PGFLT) // 14 page fault

TRAPHANDLER_NOEC(FloatEntry, T_FPERR) // 16 floating point error
TRAPHANDLER_NOEC(AlignEntry, T_ALIGN) // 17 aligment check
TRAPHANDLER_NOEC(MachineEntry, T_MCHK) // 18 machine check
TRAPHANDLER_NOEC(SIMDFloatEntry, T_SIMDERR) // 19 SIMD floating point error
TRAPHANDLER_NOEC(SysCallEntry, T_SYSCALL) // 48 system call
```

这样 我们 完成了handlerX中具有每个特性的东⻄西。

下⾯在 `_alltraps` 中实现它们共性的东⻄西——按照Trapframe结构push数据

我们现在还 剩下的就是把 顶部5个push,设置ds和es,再把最后的栈顶地址作为结构体⾸部地址压栈。调⽤trap(也就 是上⾯写的应该满⾜)。

```c
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushl %ds;
    pushl %es;
    pushal;
    pushl $GD_KD;
    popl %ds;
    pushl $GD_KD;
    popl %es;
    pushl %esp;
    call trap

```

接下来，开始实现trap函数` trap_init `，需要⽤到宏 `SETGATE(gate, istrap, sel, off, dpl) `， 该宏定义在 inc/mmu.h 中。

⾸先声明前⾯汇编中的函数名

```c
				void DivideEntry ();// 0 divide error
        void DebugEntry  ();//1 debug exception
        void NoMaskEntry    ();//  2 non-maskable interrupt
        void BreakEntry  ();//  3 breakpoint
        void OverFlowEntry  ();//  4 overflow
        void BoundsEntry  ();//  5 bounds check
        void OpCodeEntry  ();//  6 illegal opcode
        void DeviceEntry ();//  7 device not available
        void SysErrorEntry ();//  8 double fault
        void TaskSwitchEntry    ();//10 invalid task switch segment
        void SegmentEntry  ();// 11 segment not present
        void StackEntry  ();// 12 stack exception
        void ProtectEntry  ();// 13 general protection fault
        void PageEntry  ();// 14 page fault
        void FloatEntry  ();// 16 floating point error
        void AlignEntry  ();// 17 aligment check
        void MachineEntry  ();// 18 machine check
        void SIMDFloatEntry();// 19 SIMD floating point error
        void SysCallEntry();// 48 system call
```

然后配置IDT表。

```c
				SETGATE(idt[T_DIVIDE ],0,GD_KT,DivideEntry ,0);
        SETGATE(idt[T_DEBUG  ],0,GD_KT,DebugEntry  ,0);
        SETGATE(idt[T_NMI    ],0,GD_KT,NoMaskEntry    ,0);
        SETGATE(idt[T_BRKPT  ],0,GD_KT,BreakEntry  ,3);
        SETGATE(idt[T_OFLOW  ],0,GD_KT,OverFlowEntry  ,0);
        SETGATE(idt[T_BOUND  ],0,GD_KT,BoundsEntry  ,0);
        SETGATE(idt[T_ILLOP  ],0,GD_KT,OpCodeEntry  ,0);
        SETGATE(idt[T_DEVICE ],0,GD_KT,DeviceEntry ,0);
        SETGATE(idt[T_DBLFLT ],0,GD_KT,SysErrorEntry ,0);
        SETGATE(idt[T_TSS    ],0,GD_KT,TaskSwitchEntry    ,0);
        SETGATE(idt[T_SEGNP  ],0,GD_KT,SegmentEntry  ,0);
        SETGATE(idt[T_STACK  ],0,GD_KT,StackEntry  ,0);
        SETGATE(idt[T_GPFLT  ],0,GD_KT,ProtectEntry  ,0);
        SETGATE(idt[T_PGFLT  ],0,GD_KT,PageEntry  ,0);
        SETGATE(idt[T_FPERR  ],0,GD_KT,FloatEntry  ,0);
        SETGATE(idt[T_ALIGN  ],0,GD_KT,AlignEntry  ,0);
        SETGATE(idt[T_MCHK   ],0,GD_KT,MachineEntry   ,0);
        SETGATE(idt[T_SIMDERR],0,GD_KT,SIMDFloatEntry,0);
        SETGATE(idt[T_SYSCALL],0,GD_KT,SysCallEntry,3);
```

⾄此 若⽤户除零中断发⽣则->硬件检测并push需要push的值->硬件根据我们在 `trap_init()` 中 SETGATE配的IDT表找到我们的处理函数⼊⼝-> 该处理函数是由trapentry.S中TRAPHANDLER模板实现, 并调⽤ `_alltraps -> _alltraps` 在之前push的基础上再push上Trapframe结构体相复合的数据，放置 其头部地址(指针)->调⽤trap(已经由作者实现)->调⽤ `trap_dispatch` (需要我们补充)。在这⾥ `divzero` ,` softint `以及 `badsegment` 的处理都只是 `print_trapframe + env_destroy` 。

执⾏ `make grade` 根据检测代码，PartA的测试已经通过。

```bash
divzero: OK (1.3s)
softint: OK (1.0s)
badsegment: OK (0.9s)
Part A score: 30/30
```

### Challenge

我们现在肯定有许多相似度很⾼的代码，你可以修改 trapentry.S 中的宏以及 trap.c 中的IDT设置， 让代码更简洁、⾃然。提示：可以使⽤ laying down code 以及 data in the assembler ，具体 为 directives .text and .data 

分析：

参考xv6中的 `trap_init()``,我们可以在 trapentry.S 中定义⼀个 funtion array ： vectors

```SAS
.data
    .globl  vectors

vectors:
```

通过使⽤ directives .text and .data ，我们可以实现 laying down code 以及 data in the assembler 。我们对宏 TRAPHANDLER 进⾏如下修改，使之兼容 TRAPHANDLER_NOEC ：

```bash
#define TRAPHANDLER(name, num)                                          \
    .data;  \
        .long name; \
    .text;  \
        .globl name;            /* define global symbol for 'name' */   \
        .type name, @function;  /* symbol type is function */           \
        .align 2;               /* align function definition */         \
        name:                   /* function starts here */              \
        .if !(num == 8 || num == 17 || (num >= 10 && num <= 14));   \
        pushl $0;   \
        .endif;     \
        pushl $(num);                                                   \
        jmp _alltraps

```

然后我们对这两个宏的使⽤进⾏修改，修改为：

```bash
    TRAPHANDLER(vector0, T_DIVIDE) // 0 divide error
    TRAPHANDLER(vector1, T_DEBUG) // 1 debug exception
    TRAPHANDLER(vector2, T_NMI) // 2 non-maskable interrupt
    TRAPHANDLER(vector3, T_BRKPT) // 3 break point
    TRAPHANDLER(vector4,T_OFLOW) // 4 over flow
    TRAPHANDLER(vector5, T_BOUND) // 5 bounds check
    TRAPHANDLER(vector6, T_ILLOP) // 6 illegal opcode
    TRAPHANDLER(vector7, T_DEVICE) // 7 device not available
    TRAPHANDLER(vector8,  T_DBLFLT) // 8 system error
    TRAPHANDLER(vector9, 9)
    TRAPHANDLER(vector10, T_TSS) // 10 invalid task switch segment
    TRAPHANDLER(vector11, T_SEGNP) // 11 segment not present
    TRAPHANDLER(vector12, T_STACK) // 12 stack exception
    TRAPHANDLER(vector13, T_GPFLT) // 13 general protection error
    TRAPHANDLER(vector14, T_PGFLT) // 14 page fault
    TRAPHANDLER(vector15, 15)
    TRAPHANDLER(vector16, T_FPERR) // 16 floating point error
    TRAPHANDLER(vector17, T_ALIGN) // 17 aligment check
    TRAPHANDLER(vector18, T_MCHK) // 18 machine check
    TRAPHANDLER(vector19, T_SIMDERR) // 19 SIMD floating point error
    TRAPHANDLER(vector20, 20)
    TRAPHANDLER(vector21, 21)
    TRAPHANDLER(vector22, 22)
    TRAPHANDLER(vector23, 23)
    TRAPHANDLER(vector24, 24)
    TRAPHANDLER(vector25, 25)
    TRAPHANDLER(vector26, 26)
    TRAPHANDLER(vector27, 27)
    TRAPHANDLER(vector28, 28)
    TRAPHANDLER(vector29, 29)
    TRAPHANDLER(vector30, 30)
    TRAPHANDLER(vector31, 31)
    TRAPHANDLER(vector32, 32)
    TRAPHANDLER(vector33, 33)
    TRAPHANDLER(vector34, 34)
    TRAPHANDLER(vector35, 35)
    TRAPHANDLER(vector36, 36)
    TRAPHANDLER(vector37, 37)
    TRAPHANDLER(vector38, 38)
    TRAPHANDLER(vector39, 39)
    TRAPHANDLER(vector40, 40)
    TRAPHANDLER(vector41, 41)
    TRAPHANDLER(vector42, 42)
    TRAPHANDLER(vector43, 43)
    TRAPHANDLER(vector44, 44)
    TRAPHANDLER(vector45, 45)
    TRAPHANDLER(vector46, 46)
    TRAPHANDLER(vector47, 47)
    TRAPHANDLER(vector48, T_SYSCALL) // 48 system call
```

最后修改 trap.c 中对应的代码，改为：

```c
 //Challenge
        extern uint32_t vectors[];
        int i;
        for(i = 0; i <= T_SYSCALL; i++){
                switch(i){
                        case T_BRKPT:
                        case T_SYSCALL:
                                SETGATE(idt[i],0,GD_KT,vectors[i],3);
                                break;
                        default:
                                SETGATE(idt[i],0,GD_KT,vectors[i],0);
                }
        }

```

> What is the purpose of having an individual handler function for each exception/interrupt? (i.e., if all exceptions/interrupts were delivered to the same handler, what feature that exists in the current implementation could not be provided?)

A1: 因为不同的 exception和interrupt有不同的处理机制，每个exception/interrupt需要各⾃独⽴的处 理函数。如果⽤同⼀个处理函数则⽆法区分错误类型。

> Did you have to do anything to make the user/softint program behave correctly? The grade script expects it to produce a general protection fault (trap 13), but softint's code says int \$14. Why should this produce interrupt vector 13? What happens if the kernel actually allows softint's int $14 instruction to invoke the kernel's page fault handler (which is interrupt vector 14)?

当前softint是运⾏在⽤户模式下，dlp为3，但是int 指令是系统级别指令，它的dlp为0，所以⽤户 不能产⽣int \$14，⽽是引发general protection(trap 13)。如果要让 softint产⽣int $14,那就把对应的 权限位dpl 设为3即 SETGATE(idt[T_PGFLT ],0,GD_KT,ENTRY_PGFLT ,3) ,但是这样会让⽤户有管理 内存的权限，这是越权的。

## Part B: Page Faults, Breakpoints Exceptions, and System Calls

现在有基本处理机制了，现在需要实现更强⼤的exception的处理机制。

The page fault exception , interrupt vector 14 ( T_PGFLT ), 是⼀个⾮常重要的⼀个中断，(前⾯的lab只实现了⻚页的⼯作相关函数，测试都是⽤硬编码测试没有中断机制)。当处理器产⽣了⼀个page fault,，它会保存引发错误的线性/虚拟地址到CR2。作者已经在 trap.c 中的 page_fault_handler() 实现了部分(kernel态的page fault没有处理)，我们之后需要完全实现它。

### Exercise 5

编辑 trap_dispatch() 来分发⻚页错误到 page_fault_handler() 然后需要通过 make grade 的 faultread, faultreadkernel, faultwrite, 和 faultwritekernel tests.测试，你可以⽤ make run-x 或 make run-x-nox 来运⾏特殊的⽤户程序 ,⽐如 make run-faultread-nox .

实现如下值得注意的是 page_fault_handler 是⽆返回的 它会销毁当前的⽤户程序 所以 这⾥有没有 break是⼀样的

```c
static void
trap_dispatch(struct Trapframe *tf)
{
        // Handle processor exceptions.
        // LAB 3: Your code here.
        if (tf->tf_trapno == T_PGFLT) {
                page_fault_handler(tf);
                return;
        }
        if(tf->tf_trapno == T_BRKPT){
                monitor(tf);
                return;
        }
        if(tf->tf_trapno == T_SYSCALL){
                cprintf("SYSTEM CALL\n");
                tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
                                              tf->tf_regs.reg_edx,
                                              tf->tf_regs.reg_ecx,
                                              tf->tf_regs.reg_ebx,
                                              tf->tf_regs.reg_edi,
                                              tf->tf_regs.reg_esi);
                return;
        }
        // Unexpected trap: The user process or the kernel has a bug.
        print_trapframe(tf);
        if (tf->tf_cs == GD_KT)
                panic("unhandled trap in kernel");
        else {
                env_destroy(curenv);
                return;
        }
}
```

**The Breakpoint Exception**

断点异常 也就是 int 3 ( T_BRKPT ),是允许调试程序向⽤户代码中临时"插⼊/取代"的断点指令，在Lab 中我们将轻微地滥⽤该指令，将它转化为任何⽤户程序都可以⽤来调⽤内核monitor的 原始伪系统，这 种⽅法也有它的合理性，⽐如你可以直接把jos kernel看成⼀个原始调试器, ⽐如⽤户模式 下 lib/panic.c 中的 panic 在输出panic信息后会 while(1){int 3}

### Exercise 6

编辑` trap_dispatch()` 让断点异常能调⽤kernel monitor.你现在需要通过 `make grade` 的 breakpoint 测试。

先看 `kern/monitor.c` 的 `monitor(struct Trapframe *tf) `接受参数tf，那在 `trap_dispatch `中加上

```c
case T_BRKPT:

	cprintf("trap T_BRKPT:breakpoint\n"); 
	monitor(tf); 
	return ;
```

然后我们需要在 trap.c 中修改 T_BRKPT 的 dpl 使得⽤户有权限触发 breakpoint exceptions

```c
        extern uint32_t vectors[];
        int i;
        for(i = 0; i <= T_SYSCALL; i++){
                switch(i){
                        case T_BRKPT:
                        case T_SYSCALL:
                                SETGATE(idt[i],0,GD_KT,vectors[i],3);
                                break;
                        default:
                                SETGATE(idt[i],0,GD_KT,vectors[i],0);
                }
        }
```

make grade 得到 55/80

> The break point test case will either generate a break point exception or a general protection fault depending on how you initialized the break point entry in the IDT (i.e., your call to SETGATE from trap_init). Why? How do you need to set it up in order to get the breakpoint exception to work as specified above and what incorrect setup would cause it to trigger a general protection fault?

将break point exception 的dlp设为3即可。

> What do you think is the point of these mechanisms, particularly in light of what the user/softint test program does?

这些机制的重点就是保护，保护内核环境不被其他⽤户环境所破坏，所以⽤dlp对⽤户权限进⾏限 制。

#### System call

⽤户程序通过使⽤系统调⽤来让内核帮它们完成它们⾃⼰权限所不能完成的事情，当⽤户程序调 ⽤ System Call 时 处理器进⼊内核态，处理器+内核合作⼀起保存⽤户态的状态，内核再执⾏对应的 System Call 的代码，完成后再返回⽤户态。但⽤户如何调⽤ System Call 的内容和过程因系统⽽ 异。

程序会⽤寄存器传递系统调⽤号和系统调⽤参数，系统调⽤号放在%eax中，参数依次放 在 %edx ， %ecx ， %ebx ， %edi 中，内核执⾏完后返回值放在%eax中，在 lib/syscall.c 的 syscall() 函数中已经写好了汇编的系统调⽤函数的⼀部分。

### Exercise 7

> 为内核加上 T_SYSCALL 的处理⽅法，我们需要修改 kern/trapentry.S 和 kern/trap.c's trap_init() ，并且要使得 trap_dispatch() 可以处理 syscall() 引起的中断，然后考虑返回给 user process 的 %eax 。最后，完成 syscall() 函数，如果 syscall() 的 number 是⾮法的，也需 要返回 -E_INVAL 。
>
> 可以阅读 lib/syscall.c 的代码，以便更好地理解，我们需要处理 inc/syscall.h 列举的所 有 system calls 。

⾸先我们完善 syscall 函数

```c
// Dispatches to the correct kernel function, passing the arguments. 
int32_t syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5) {

// Call the function corresponding to the 'syscallno' parameter. // Return any appropriate return value.

// LAB 3: Your code here.

//panic("syscall not implemented");

	switch (syscallno) { 
    case SYS_cputs:
      sys_cputs((char *)a1,(size_t)a2);
      return 0; 
    case SYS_cgetc:
      return sys_cgetc(); 
    case SYS_getenvid:
      return sys_getenvid(); 
    case SYS_env_destroy:
      return sys_env_destroy((envid_t) a1);
    default:
      return -E_INVAL; 
  }
}
```

然后我们需要调⽤ user_mem_assert 确认⽤户模式下是否有权限在 sys_cputs 中读取内存

```c
// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
        // Check that the user has permission to read memory [s, s+len).
        // Destroy the environment if not.

        // LAB 3: Your code here.
        if(curenv->env_tf.tf_cs & 3){
                user_mem_assert(curenv,s,len,0);
        }
        // Print the string supplied by the user.
        cprintf("%.*s", len, s);
}
```

最后，我们修改 trap_dispatch 函数，加上⼀段代码，使之能处理 T_SYSCALL 中断：

```c
if(tf->tf_trapno == T_SYSCALL){
  cprintf("SYSTEM CALL\n"); 
  tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, 
                                tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx, 
                                tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
  return;
}
```

#### User-mode startup

⽤户程序开始运⾏于 `lib/entry.S` 。 在⼀些配置后代码调⽤发⽣在 `lib/libmain.c` 中的 `libmain()` 。 我们需要修改 `libmain()` ：初始化全局指针 `thisenv` 指向当前⽤户环境的Env. (提示： Part A的 lib/entry.S 已经定义了 envs 指向UENVS个environments。可以查看 inc/env.h 并使 ⽤ sys_getenvid )。

libmain() 之后会调⽤ umain() ,也就是 每⼀个函数的 主函数 ， user/hello.c 在主函数结束后会尝 试访问 thisenv->env_id 。之前我们没有实现，这⾥会报错。现在应该正确了，如果还报错请检查它 的是否是⽤户可读

### Exercise 8

> 在 libmain() 添加代码，让user/hello能输出 "i am environment 00001000"。 user/hello 然后尝试
>
> sys_env_destroy() 来退出 (see lib/libmain.c and lib/exit.c)。 因为现在只有⼀个⽤户环境，因此内 核应该报告销毁了唯⼀⽤户环境并进⼊内核monitor。
>
> 需要 make grade 通过 hello 测试。

sys_getenvid() 可以得到当前 env_id ,通过 kern/env.c 中 envid2env() 函数中的⽅式，实现如下

```c
thisenv = &envs[ENVX(sys_getenvid())];
```

#### Page faults and memory protection

内存保护是操作系统的⼀个重要的功能,确保⼀个程序的bug不会破坏操作系统和其它程序。操作系统总 是依赖于硬件的⽀持来实现内存保护。操作系统记录了哪些虚拟地址是有效的，哪些是⽆效的。 当⼀个 程序尝试访问⽆效的地址或者它没有权限的地址，处理器在这个引发fault的程序的指令位置停⽌然后 trap进内核 with information about the attempted operation。如果fault可以修复，则内核可以修复 它让程序继续运⾏，如果不能修复则不会执⾏该指令及以后的指令。

举⼀个修复的例⼦，考虑⾃动增加的stack。在很多系统中内核初始化只申请了⼀个stack⻚页, 如果⼀个程 序访问的超过了⻚页⼤⼩,内核需要申请新的⻚页让程序继续。通过这样，内核只申请这个程序真实需要的 stack内存, 但在程序看来它⼀直有很⼤内存。

系统调⽤给内存保护带来了⼀个有趣的问题。⼤多数系统调⽤接⼝允许⽤户传递指向内核传递了⼀个指 针，这些指针指向⽤户的⽤来读或者写的buﬀer，然后内核使⽤这些指针⼯作，这样有两个问题：

1. 内核⾥的⻚页错误相对于⽤户的⻚页错误是有更⼤的潜在危险。如果管理数据结构时内核⻚页错误，那会 引起内核的bug, 并且错误会使整个内核异常。但是当内核使⽤这些⽤户给的指针时，应该只属于⽤户的 ⾏为错误，不应产⽣内核bug。
2. 内核有更多的内存读写权限。⽤户传来的指针也可能指向⼀个内核才有权限的地址，内核需要能分 辨它对⽤户的权限是否满⾜要求。

根据上⾯两个原因，我们都应该⼩⼼的处理⽤户程序。

可以⽤审查所有从⽤户传给内核的指针的⽅法来解决这两个问题，检查它是否是⽤户可访问的以及它是 否已经分配。

如果本身内核的⻚页错误，那内核应该panic并终⽌。

### Exercise 9

修改 `kern/trap.c` 使之若在kernel mode 发⽣⻚页错误则panic，提示通过 `tf_cs` 的低位检测当前处于 什么模式 阅读 `kern/pmap.c` 中的 `user_mem_assert()` 函数并实现 `user_mem_check()` 函数.

修改 `kern/syscall.c` 以⾄能健全的检查系统调⽤的参数.

运⾏ `user/buggyhello` ⽤户环境应当被销毁，但内核不应panic. 你应该看到:

```bash
[00001000] user_mem_check assertion failure for va 00000001
[00001000] free env 00001000 
Destroyed the only environment - nothing more to do!
```

最后修改 `kern/kdebug.c` 中的 `debuginfo_eip` 让它在 `usd` ,` stabs` ,和 `stabstr` 上调⽤调⽤ `user_mem_check` 。

如果你运⾏ `user/breakpoint` ，你必须在终端上可以运⾏ `backtrace` 在 `page fualt` 产⽣ `panic` 之前来跟踪 `lib/libmain.c` 。

提示：你刚刚实现的机制对 malicious user applications 也试⽤(such as user/evilhello) ⼀步⼀步，先 kern/trap.c 的 page_fault_handler 加上 是否是内核态的检测

```c
if ((tf->tf_cs & 0x3) == 0) 
  panic("kernel page fault");
```

然后看 `user_mem_assert` 发现它是对 `user_mem_check `的⼀个封装，如果 `user_mem_check` 出错 `user_mem_assert` 就直接destroy⽤户环境了

`user_mem_check` 说 va 和len都没有⻚页对⻬齐，我们应该检查它覆盖的所有部分，权限应满⾜ `perm | PTE_P` ， 地址应⼩于ULIM。如果出错设置 `user_mem_check_addr` 的值为第⼀个出错的虚拟地址，正 确则返回0，失败返回` -E_FAULT`

回顾 `pte_t * pgdir_walk(pde_t *pgdir, const void *va, int create) `函数 传⼊ (⻚页⽬录,虚 拟地址,是否新建) 返回 ⻚页表项，我们对 `user_mem_check` 实现如下

```c
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
        // LAB 3: Your code here.
        uint32_t start = (uint32_t)ROUNDDOWN((char *)va, PGSIZE);
        uint32_t end = (uint32_t)ROUNDUP((char *)va+len, PGSIZE);
        for(; start < end; start += PGSIZE) {
                pte_t *pte = pgdir_walk(env->env_pgdir, (void*)start, 0);
                if((start >= ULIM) || (pte == NULL) || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
                        user_mem_check_addr = (start < (uint32_t)va ? (uint32_t)va : start);
                        return -E_FAULT;
                }
        }
        return 0;
}
```

最后修改 `kern/kdebug.c` 函数，加上对usd，stabs,stabstr的地址的检测，实现如下：

```c
 // Make sure this memory is valid.
                // Return -1 if it is not.  Hint: Call user_mem_check.
                // LAB 3: Your code here.
                if(user_mem_check(curenv,usd,sizeof(struct UserStabData),                       PTE_U)){
                        return -1;
                }
                stabs = usd->stabs;
                stab_end = usd->stab_end;
                stabstr = usd->stabstr;
                stabstr_end = usd->stabstr_end;

                // Make sure the STABS and string table memory is valid.
                // LAB 3: Your code here.
                if(user_mem_check(curenv,stabs,sizeof(struct Stab),PTE_U)){
                        return -1;
                }
                if(user_mem_check(curenv,stabstr,stabstr_end-stabstr,PTE_U)){
                        return -1;
                }
```

⾄此 make grade 已经 80/80

我们在终端中调⽤ `bakctrace `，可以看到` page fault` 是由 `accessing memory Oxeebfe000` 引起 的：

```bash
K> backtrace 
Stack backtrace:
ebp efffff20 eip f01008df args 00000001 efffff38 f01a0000 00000000 f017da40
			kern/monitor.c:147: monitor+276 
ebp efffff90 eip f01034ff args f01a0000 efffffbc 00000000 00000082 00000000
			kern/trap.c:161: trap+153 
ebp efffffb0 eip f0103733 args efffffbc 00000000 00000000 eebfdfd0 efffffdc
			kern/syscall.c:69: syscall+0 ebp eebfdfd0 
eip 00800073 args 00000000 00000000 eebfdff0 00800049 00000000
			lib/libmain.c:28: libmain+58 
ebp eebfdff0 eip 00800031 args 00000000 00000000Incoming TRAP frame at 
0xeffffea4 
kernel panic at kern/trap.c:240: Page fault in kernel mode
```

