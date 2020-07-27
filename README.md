### 环境配置

实验环境：`ubuntu 16.04 32bit`，使用docker创建Ububtu环境

首先安装有关工具

```bash
apt-get update
mkdir ~/6.828
cd ~/6.828
git clone https://github.com/mit-pdos/6.828-qemu.git qemu
./configure --disable-kvm --disable-werror --target-list="i386-softmmu x86_64-softmmu"
sudo apt-get install libsdl1.2-dev libtool-bin libglib2.0-dev libz-dev libpixman-1-dev
make && make install
```

环境配置过程中出现多处bug，使用https://xinqiu.me/2016/10/15/MIT-6.828-1/中提供的方法做了修复

# Lab1

clone项目

```bash
mkdir ~/6.828
cd ~/6.828
git clone https://pdos.csail.mit.edu/6.828/2018/jos.git lab` `cd lab
```

运行qemu-nox（qemu为有GUI版本，对于Linux Server需要运行qemu-nox）

```bash
make qemu-nox
```

运行成功

## Part 1: PC Bootstrap

物理空间内存地址可以由下图描述：

```bash
+------------------+  <- 0xFFFFFFFF (4GB)
|      32-bit      |
|  memory mapped   |
|     devices      |
|                  |
/\/\/\/\/\/\/\/\/\/\

/\/\/\/\/\/\/\/\/\/\
|                  |
|      Unused      |
|                  |
+------------------+  <- depends on amount of RAM
|                  |
|                  |
| Extended Memory  |
|                  |
|                  |
+------------------+  <- 0x00100000 (1MB)
|     BIOS ROM     |
+------------------+  <- 0x000F0000 (960KB)
|  16-bit devices, |
|  expansion ROMs  |
+------------------+  <- 0x000C0000 (768KB)
|   VGA Display    |
+------------------+  <- 0x000A0000 (640KB)
|                  |
|    Low Memory    |
|                  |
+------------------+  <- 0x00000000
```

### Exercise 1 

熟悉6.828参考页上提供的汇编语言材料。您现在不必阅读它们，但是几乎可以肯定的是，在读写x86程序集时，您会希望参考其中的一些内容。

我们建议阅读Brennan的《内联汇编指南》中的“语法”部分。它很好地（并且非常简短地）描述了我们将与JOS中的GNU汇编器一起使用的AT＆T汇编语法。

开两个终端： （都是在lab/中） 一个`make qemu-nox-gdb` 一个`make gdb` 就可以进入调试窗口

![figure1](/Users/xuedixuedi/lxdThings/Code/github/OS_MIT_Labs/figure/figure1.png)

### Exercise 2

在gdb窗口看到了`[f000:fff0] 0xffff0: ljmp $0xf000,$0xe05b`，这个是第一条指令

这条指令说明执行的起始物理地址为$0xf000

前面`[f000:fff0]`分别表示代码寄存器CS内容为f000，指针寄存器IP内容为fff0，8086CPU会从内存CS*16+IP的位置开始，读取并执行一条指令。

当前情况下就是 16 * 0xf000 + 0xfff0 = 0xf0000 + 0xfff0 = 0xffff0

ljmp是跳转指令，CS不变还是0xf000，IP从0xfff0跳到0xe05b

## Part2: The Boot Loader

在地址0x7c00处设置断点，然后c运行到断点处，使用x/i来查看当前指令

```bash
(gdb) b *0x7c00
Breakpoint 1 at 0x7c00
(gdb) c
Continuing.
[   0:7c00] => 0x7c00:	cli

Breakpoint 1, 0x00007c00 in ?? ()
(gdb) x/i
   0x7c01:	cld
(gdb) x/16i
   0x7c12:	out    %al,$0x64
   0x7c14:	in     $0x64,%al
   0x7c16:	test   $0x2,%al
   0x7c18:	jne    0x7c14
   0x7c1a:	mov    $0xdf,%al
   0x7c1c:	out    %al,$0x60
   0x7c1e:	lgdtw  0x7c64
   0x7c23:	mov    %cr0,%eax
   0x7c26:	or     $0x1,%eax
   0x7c2a:	mov    %eax,%cr0
   0x7c2d:	ljmp   $0x8,$0x7c32
   0x7c32:	mov    $0xd88e0010,%eax
   0x7c38:	mov    %ax,%es
   0x7c3a:	mov    %ax,%fs
   0x7c3c:	mov    %ax,%gs
   0x7c3e:	mov    %ax,%ss
```

### Exercise 3

> 处理器在什么时候开始执行32位代码?
> 究竟是什么原因导致从16位模式切换到32位模式?

在`0x7c2d: ljmp $0x8,$0x7c32`指令之后，地址从16位变为了32位形式 代码在`boot/boot.S`中，还有注释：

**At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?**

```bash
# Jump to next instruction, but in 32-bit code segment.
# Switches processor into 32-bit mode.
ljmp    $PROT_MODE_CSEG, $protcseg
```

> 引导加载程序执行的最后一条指令是什么?它刚刚加载的内核的第一条指令是什么?

boot loader的最后一条就在`boot/main.c`中： `((void (*)(void)) (ELFHDR->e_entry))();`

在`kern/entry.S`中能找到第一条指令，其地址为`0x0010000c`，和kernel信息中的起始地址一致

```bash
entry:
	movw	$0x1234,0x472			# warm boot
```

> 内核的第一条指令在哪里?

第一条指令是`movw $0x1234,0x472`，地址为`0x0010000c`

> 引导加载程序如何决定必须读取多少扇区才能从磁盘获取整个内核?
> 它在哪里找到这些信息?

`boot/main.c`中有代码，可以通过`ELFHDR->e_phnum`来获取扇区数量 通过`objdump -h obj/kern/kernel`可以获得kernel信息

### Loading the kernel

ELF文件头 .text段：存放所有程序的可执行代码 .rodata段：存放所有只读数据的数据段，比如字符串常量。 .data段：存放所有被初始化过的数据段，比如有初始值的全局变量

```bash
root@c665a16a36dc:~/6.828/lab# objdump -h obj/kern/kernel

obj/kern/kernel:     file format elf32-i386

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         000019d9  f0100000  00100000  00001000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .rodata       000006c0  f01019e0  001019e0  000029e0  2**5
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .stab         00003b7d  f01020a0  001020a0  000030a0  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .stabstr      00001953  f0105c1d  00105c1d  00006c1d  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .data         00009300  f0108000  00108000  00009000  2**12
                  CONTENTS, ALLOC, LOAD, DATA
  5 .got          00000008  f0111300  00111300  00012300  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  6 .got.plt      0000000c  f0111308  00111308  00012308  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  7 .data.rel.local 00001000  f0112000  00112000  00013000  2**12
                  CONTENTS, ALLOC, LOAD, DATA
  8 .data.rel.ro.local 00000060  f0113000  00113000  00014000  2**5
                  CONTENTS, ALLOC, LOAD, DATA
  9 .bss          00000644  f0113060  00113060  00014060  2**5
                  ALLOC
 10 .comment      00000029  00000000  00000000  00014060  2**0
                  CONTENTS, READONLY
```

```bash
root@c665a16a36dc:~/6.828/lab# objdump -h obj/kern/kernel

obj/kern/kernel:     file format elf32-i386

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         000019d9  f0100000  00100000  00001000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .rodata       000006c0  f01019e0  001019e0  000029e0  2**5
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .stab         00003b7d  f01020a0  001020a0  000030a0  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .stabstr      00001953  f0105c1d  00105c1d  00006c1d  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .data         00009300  f0108000  00108000  00009000  2**12
                  CONTENTS, ALLOC, LOAD, DATA
  5 .got          00000008  f0111300  00111300  00012300  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  6 .got.plt      0000000c  f0111308  00111308  00012308  2**2
                  CONTENTS, ALLOC, LOAD, DATA
  7 .data.rel.local 00001000  f0112000  00112000  00013000  2**12
                  CONTENTS, ALLOC, LOAD, DATA
  8 .data.rel.ro.local 00000060  f0113000  00113000  00014000  2**5
                  CONTENTS, ALLOC, LOAD, DATA
  9 .bss          00000644  f0113060  00113060  00014060  2**5
                  ALLOC
 10 .comment      00000029  00000000  00000000  00014060  2**0
                  CONTENTS, READONLY
root@c665a16a36dc:~/6.828/lab# objdump -x obj/kern/kernel

obj/kern/kernel:     file format elf32-i386
obj/kern/kernel
architecture: i386, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x0010000c

Program Header:
    LOAD off    0x00001000 vaddr 0xf0100000 paddr 0x00100000 align 2**12
         filesz 0x00007570 memsz 0x00007570 flags r-x
    LOAD off    0x00009000 vaddr 0xf0108000 paddr 0x00108000 align 2**12
         filesz 0x0000b060 memsz 0x0000b6a4 flags rw-
   STACK off    0x00000000 vaddr 0x00000000 paddr 0x00000000 align 2**4
         filesz 0x00000000 memsz 0x00000000 flags rwx

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         000019d9  f0100000  00100000  00001000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .rodata       000006c0  f01019e0  001019e0  000029e0  2**5
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .stab         00003b7d  f01020a0  001020a0  000030a0  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .stabstr      00001953  f0105c1d  00105c1d  00006c1d  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
···

SYMBOL TABLE:
f0100000 l    d  .text	00000000 .text
f01019e0 l    d  .rodata	00000000 .rodata
f01020a0 l    d  .stab	00000000 .stab
f0105c1d l    d  .stabstr	00000000 .stabstr
f0108000 l    d  .data	00000000 .data
f0111300 l    d  .got	00000000 .got
f0111308 l    d  .got.plt	00000000 .got.plt
f0112000 l    d  .data.rel.local	00000000 .data.rel.local
f0113000 l    d  .data.rel.ro.local	00000000 .data.rel.ro.local
f0113060 l    d  .bss	00000000 .bss

···

```

### Exercise 5

> 将boot/Makefrag中的链接地址更改为错误，运行make clean，用make重新编译实验室，然后再次跟踪引导加载程序，看看会发生什么。
> 别忘了把链接地址改回来，然后再清理!

查看`boot/Makefrag`，找到-Ttext后面的入口地址`start -Ttext 0x7C00` 把0x7C00修改为另一个值，让其错误，比如改为`0x7C04`

`make clean`并重新`make`后再次开启gdb调试 同样在`b *0x7c00`处打上断点并运行到此，`ci`当运行到`0:7c2d`处时发生报错

```bash
(gdb) si
[   0:7c2d] => 0x7c2d:	ljmp   $0x8,$0x7c36
0x00007c2d in ?? ()

DR6=ffff0ff0 DR7=00000400
EFER=0000000000000000
Triple fault.  Halting for inspection via QEMU monitor.
```

后面的`0x7c36`地址比正确地址多了4，而BIOS 将 boot loader固定加载在`0x7c00`开始的地方，所以这次的跳转就发生了错误

### Exercise 6

> 在BIOS进入引导加载程序时，然后在引导加载程序进入内核时，检查0x00100000处的8个单词的内存。
> 为什么会有不同?
> 第二个断点是什么?

`0x00100000`是从BIOS进入到boot loader的地址查看`0x00100000`处的8个word的值

```bash
(gdb) x/8x 0x00100000
0x100000:	0x00000000	0x00000000	0x00000000	0x00000000
0x100010:	0x00000000	0x00000000	0x00000000	0x00000000
```

程序的入口点是`0x10000c`，在此处打断点，看后面的8个字

```bash
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x0000b812	0x220f0011	0xc0200
```

## Part 3: The Kernel

进入内核后，JOS主要进行了

1. 开启分页模式，将虚拟地址[0, 4MB)映射到物理地址[0, 4MB)，[0xF0000000, 0xF0000000+4MB)映射到[0, 4MB）（/kern/entry.S）
2. 在控制台输出字符串（/kern/init.c）
3. 测试函数的调用过程 （/kern/init.c）

#### 开启分页模式

操作系统经常被加载到高虚拟地址处，比如0xf0100000，但是并不是所有机器都有这么大的物理内存。可以使用内存管理硬件做到将高地址虚拟地址映射到低地址物理内存。

#### 格式化输出到控制的台

这一小结提供了一些函数，用于将字符串输出到控制台。这些函数分布在kern/printf.c, lib/printfmt.c, kern/console.c中。可以发现真正实现字符串输出的是vprintfmt()函数，其他函数都是对它的包装。vprintfmt()函数很长，大的框架是一个while循环，while循环中首先会处理常规字符。

```c
while ((ch = *(unsigned char *) fmt++) != '%') {        //先将非格式化字符输出到控制台。
            if (ch == '\0')                                     //如果没有格式化字符直接返回
                return;
            putch(ch, putdat);
        }
```

### Exercise 8

> 我们省略了一小段代码——使用“%o”形式的模式打印八进制数所必需的代码。
> 查找并填充此代码片段。

在`vprintfmt()`中找到case 'o'的地方

```c
// 从ap指向的可变字符串中获取输出的值
            num = getuint(&ap, lflag);
            //设置基数为8
            base = 8;
            goto number;
```

> Explain the interface between `printf.c` and `console.c`. Specifically, what function does `console.c`export? How is this function used by `printf.c`?

这两者的接口为`cputchar`，作用是往输出流中放入一个字符



> Explain the following from `console.c`:
>
> ```c
> if (crt_pos >= CRT_SIZE) {
> 	int i;
> memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
> for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
> 		crt_buf[i] = 0x0700 | ' ';
> 	crt_pos -= CRT_COLS;
>   }
> ```

整体上移一行，并在新的一行中填入空格



> For the following questions you might wish to consult the notes for Lecture 2. These notes cover GCC’s calling convention on the x86.
>
> Trace the execution of the following code step-by-step:
>
> ```c
> int x = 1, y = 3, z = 4;
> cprintf("x %d, y %x, z %d\n", x, y, z);
> ```
>
> - In the call to `cprintf()`, to what does `fmt` point? To what does `ap` point?

`fmt`指向格式化字符串 `"x %d,y %x,z %d\n"`,`ap`指向第一个可选参数`x`



> Run the following code.
>
> ```c
> unsigned int i = 0x00646c72;
>     cprintf("H%x Wo%s", 57616, &i);
> ```
>
> What is the output? Explain how this output is arrived out in the step-by-step manner of the previous exercise

output：

```c
He110 World
```

- 57616 == 0xe110
- 0x64 == ‘d’, 0x6c == ‘l’, 0x72 == ‘r’



> In the following code, what is going to be printed after`y=`? (note: the answer is not a specific value.) Why does this happen?
>
> ```c
> cprintf("x=%d y=%d", 3);
> ```

一个在栈上相邻的值



> 让我们假设GCC改变了它的调用约定，以便它按照声明顺序将参数推入堆栈，从而最后一个参数被推入。
> 你必须如何改变cprintfor它的接口，以便它仍然有可能传递一个可变数量的参数?

分析：

- 对于`cprintf`而言，需要知道`fmt`的内容才能确定参数的数量
- 对于这一种传参方式，需要知道参数的数量才能确定第一个参数的位置

所以解决方案可能有：

1. 新增一个参数，内容为参数数量，在参数表的末尾
2. 只接受固定的两个参数，第一个为`fmt`，第二个为以NULL结尾的链表的首地址，链表中为参数，类似于`char **argv`
3. 将可选参数放在前面，`fmt`在最后



### The Stack

1. 执行call指令前，函数调用者将参数入栈，按照函数列表从右到左的顺序入栈。
2. call指令会自动将当前eip入栈，ret指令将自动从栈中弹出该值到eip寄存器。
3. 被调用函数负责：将ebp入栈，esp的值赋给ebp。

![lab1_3](https://github.com/PtNan/OSCD/raw/lab1/assets/lab1_3.png)

### Exercise 9

> 确定内核初始化其堆栈的位置，以及它的堆栈在内存中的确切位置。
> 内核如何为它的堆栈保留空间?
> 并且在这个保留区域的“结束”是堆栈指针初始化指向?

/kern/entry.S:75

```bash
# Set the stack pointer
movl	$(bootstacktop),%esp
```

### Exercise10

> 要熟悉x86上的C调用约定，可以在`obj/kern/kernel.asm`中找到`test_backtrace`函数的地址。
> 在那里设置一个断点，并检查在内核启动后每次调用断点时会发生什么。
> 每个`test_backtrace`的递归嵌套层在堆栈上推入多少32位的单词，这些单词是什么?

发现每次调用esp缩小0x20，即8 words

### Exercise 11

> 实现上面指定的backtrace函数。
> 请使用与示例相同的格式，否则评分脚本将会混淆。
> 当您认为您已经使它正常工作时，运行make grade，看看它的输出是否符合我们的评分脚本的期望，如果不符合，就修复它。
> 在你提交了你的实验1代码之后，你可以随意改变backtrace函数的输出格式。

既然已经提供了`read_ebp`函数，那么顺着ebp一路摸上去就能得到`return address`和各个参数：

```c
ebp = (unsigned int *)read_ebp();
for (;ebp != NULL;) {
	cprintf("eip %8x  ebp %8x  args %08x %08x %08x %08x %08x\n", 
			ebp[1], ebp, ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
	ebp = (unsigned int *)(*ebp);
}
```

这些在ics的buffer overflow中见的多了。另一个问题是什么时候停止循环。在entry.S中发现:(entry.S:73)

```bash
movl	$0x0,%ebp			# nuke frame pointer
```

也就是说，初始化时ebp为0，当发现ebp为0(NULL)时即可停止循环。

### Exercise 12

> 通过插入对stab_binsearch的调用来查找地址的行号，完成debuginfo_eip的实现。
> 向内核监视器添加一个backtrace命令，并扩展mon_backtrace的实现，调用debuginfo_eip并为表单的每个堆栈帧打印一行:

```c
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
    uint32_t ebp, *ptr_ebp;
    struct Eipdebuginfo info;
    ebp = read_ebp();
    cprintf("Stack backtrace:\n");
    while (ebp != 0) {
        ptr_ebp = (uint32_t *)ebp;
        cprintf("\tebp %x  eip %x  args %08x %08x %08x %08x %08x\n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
        if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
            uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr;
            cprintf("\t\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line,info.eip_fn_namelen,  info.eip_fn_name, fn_offset);
        }
        ebp = *ptr_ebp;
    }
    return 0;
}
```

### Lab1 总结

------

经过这个Lab，我们主要了解了以下内容：

1. 启动顺序：BIOS -> Boot Loader -> Kernel
2. 各自的简介：

- BIOS:
  位于 `0x000F 0000` 至 `0x0010 0000`共 64kB 空间中。
  初始化 PCI 总线以及其他设备，搜索能启动的设备例如软盘、硬盘、光驱等，如果发现了启动盘，就读取盘内的 boot loader 并移交控制权。
- Boot Loader:
  位于 `0x7c00`与`0x7dff` 共 512 byte 空间之中。
  从实模式切换到保护模式，并将 kernel 读取到内存中。跳转到kernel执行。
- Kernel:
  位于 `0x10 0000` 开始的物理内存中。被映射到了`0xf010 0000`的高位地址上。
  开启内存分页机制，启用虚拟内存，I/O的实现，栈的初始化。