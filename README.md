# LAB 5

在该lab实现一个文件系统以及相关功能。

> 该文件系统比较简单，不包括inode，仅有基本的功能

### File System Preliminaries

#### On-Disk File System Structure
- 不使用inode
- 块大小为4096byte
- block 0 保存boot loader和分区表
- block 1 保存super block
- block 2 保存bitmap
- 之后的block保存文件

##### Super Block
```C
struct Super {
    uint32_t s_magic;       // Magic number: FS_MAGIC
    uint32_t s_nblocks;     // Total number of blocks on disk
    struct File s_root;     // Root directory node
};
```
##### File Meta-data
File结构定义在inc/fs.h中
```C
struct File {
    char f_name[MAXNAMELEN];    // filename
    off_t f_size;           // file size in bytes
    uint32_t f_type;        // file type
    // Block pointers.
    // A block is allocated iff its value is != 0.
    uint32_t f_direct[NDIRECT]; // direct blocks
    uint32_t f_indirect;        // indirect block
    // Pad out to 256 bytes; must do arithmetic in case we're compiling
    // fsformat on a 64-bit machine.
    uint8_t f_pad[256 - MAXNAMELEN - 8 - 4*NDIRECT - 4];
} __attribute__((packed));  // required only on some 64-bit machines
```
我们知道super block中也有一个File结构，为root。File决定了文件类型是file还是directory，同时file的两个数组，直接指向10个，间接指向1024个，总计1034个block号，大约3GB的空间。

### The File System
#### Disk Access
##### Exercise 1
文件系统进程的type为ENV_TYPE_FS，需要修改env_create()，如果type是ENV_TYPE_FS，需要给该进程IO权限。
```C
if (type == ENV_TYPE_FS) {
    e->env_tf.tf_eflags |= FL_IOPL_MASK;
}
```
仅当进程type是FS的时候，拥有访问IO的权限。
#### The Block Cache
文件系统进程保留从0x10000000 (DISKMAP)到0xD0000000 (DISKMAP+DISKMAX)固定3GB的内存空间作为磁盘的缓存。需要像LAB 2一样进行映射。
同时我们使用按需加载。
##### Exercise 2
实现bc_pgfault()和flush_block()。
`bc_pgfault()`
```C
static void bc_pgfault(struct UTrapframe *utf) {
  void *addr = (void *)utf->utf_fault_va;
  uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  int r;

  // Check that the fault was within the block cache region
  if (addr < (void *)DISKMAP || addr >= (void *)(DISKMAP + DISKSIZE))
    panic("page fault in FS: eip %08x, va %08x, err %04x", utf->utf_eip, addr,
          utf->utf_err);

  // Sanity check the block number.
  if (super && blockno >= super->s_nblocks)
    panic("reading non-existent block %08x\n", blockno);

  // Allocate a page in the disk map region, read the contents
  // of the block from the disk into that page.
  // Hint: first round addr to page boundary. fs/ide.c has code to read
  // the disk.
  //
  // LAB 5: you code here:
  addr = ROUNDDOWN(addr, PGSIZE);
  sys_page_alloc(0, addr, PTE_W | PTE_U | PTE_P);
  if ((r = ide_read(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
    panic("ide_read: %e", r);

  // Clear the dirty bit for the disk block page since we just read the
  // block from disk
  if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
    panic("in bc_pgfault, sys_page_map: %e", r);

  // Check that the block we read was allocated. (exercise for
  // the reader: why do we do this *after* reading the block
  // in?)
  if (bitmap && block_is_free(blockno))
    panic("reading free block %08x\n", blockno);
}
```
缺页处理函数，主要步骤为：
1. 将地址对齐
1. 分配一段内存
1. 读ide磁盘的内容
1. 拷贝页表
1. 检查是否分配成功

`flush_block()`
```C
void flush_block(void *addr) {
  uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  int r;
  if (addr < (void *)DISKMAP || addr >= (void *)(DISKMAP + DISKSIZE))
    panic("flush_block of bad va %08x", addr);

  // LAB 5: Your code here.
  addr = ROUNDDOWN(addr, PGSIZE);
  if (!va_is_mapped(addr) || !va_is_dirty(addr)) {
    return;
  }
  if ((r = ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0) {
    panic("in flush_block, ide_write(): %e", r);
  }
  if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
    panic("in bc_pgfault, sys_page_map: %e", r);
}
```
写回磁盘函数，主要步骤为：
1. 如果未映射或者未修改，直接退出
1. 写回
1. 清空PTE_D位
#### The Block Bitmap
bitmap中，1为未使用，0为已使用
##### Exercise 3
实现fs/fs.c中的alloc_block()，该函数搜索bitmap位数组，返回一个未使用的block，并将其标记为已使用。
```C
int alloc_block(void) {
  // The bitmap consists of one or more blocks.  A single bitmap block
  // contains the in-use bits for BLKBITSIZE blocks.  There are
  // super->s_nblocks blocks in the disk altogether.

  // LAB 5: Your code here.
  uint32_t bmpblock_start = 2;
  for (uint32_t blockno = 0; blockno < super->s_nblocks; blockno++) {
    if (block_is_free(blockno)) {                     //搜索free的block
      bitmap[blockno / 32] &= ~(1 << (blockno % 32)); //标记为已使用
      flush_block(diskaddr(bmpblock_start +
                           (blockno / 32) /
                               NINDIRECT)); //将刚刚修改的bitmap block写到磁盘中
      return blockno;
    }
  }
  return -E_NO_DISK;
}
```
遍历查找。

#### File Operations
文件系统应该提供一些基本的操作。
##### Exercise 4
实现file_block_walk()和file_get_block()。
`file_block_walk()`
```C
static int file_block_walk(struct File *f, uint32_t filebno,
                           uint32_t **ppdiskbno, bool alloc) {
  // LAB 5: Your code here.
  int bn;
  uint32_t *indirects;
  if (filebno >= NDIRECT + NINDIRECT)
    return -E_INVAL;

  if (filebno < NDIRECT) {
    *ppdiskbno = &(f->f_direct[filebno]);
  } else {
    if (f->f_indirect) {
      indirects = diskaddr(f->f_indirect);
      *ppdiskbno = &(indirects[filebno - NDIRECT]);
    } else {
      if (!alloc)
        return -E_NOT_FOUND;
      if ((bn = alloc_block()) < 0)
        return bn;
      f->f_indirect = bn;
      flush_block(diskaddr(bn));
      indirects = diskaddr(bn);
      *ppdiskbno = &(indirects[filebno - NDIRECT]);
    }
  }

  return 0;
}
```
查找f指向文件结构的第filebno个block的存储地址，保存到ppdiskbno中。如果f->f_indirect还没有分配，且alloc为真，那么将分配要给新的block作为该文件的f->f_indirect。类比页表管理的pgdir_walk()。

`file_get_block()`
```C
int file_get_block(struct File *f, uint32_t filebno, char **blk) {
  // LAB 5: Your code here.
  int r;
  uint32_t *pdiskbno;
  if ((r = file_block_walk(f, filebno, &pdiskbno, true)) < 0) {
    return r;
  }

  int bn;
  if (*pdiskbno == 0) {
    if ((bn = alloc_block()) < 0) {
      return bn;
    }
    *pdiskbno = bn;
    flush_block(diskaddr(bn));
  }
  *blk = diskaddr(*pdiskbno);
  return 0;
}
```
该函数查找文件第filebno个block对应的虚拟地址addr，将其保存到blk地址处。
#### The file system interface
由于其他用户进程不能直接调用这些File system函数，需要通过RPC调用，本质上RPC还是借助IPC机制实现的，普通进程通过IPC向FS进程间发送具体操作和操作数据，然后FS进程执行文件操作，最后又将结果通过IPC返回给普通进程。
##### Exercise 5
实现fs/serv.c中的serve_read()。
```C
int serve_read(envid_t envid, union Fsipc *ipc) {
  struct Fsreq_read *req = &ipc->read;
  struct Fsret_read *ret = &ipc->readRet;

  if (debug)
    cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

  // Lab 5: Your code here:
  struct OpenFile *o;
  int r;
  r = openfile_lookup(envid, req->req_fileid, &o);
  // cprintf("serve_read():req->req_fileid = %d\n", req->req_fileid);
  if (r < 0)
    return r;
  if ((r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) <
      0)
    return r;
  o->o_fd->fd_offset += r;

  return r;
}
```
通过File ID查找openfile，找到后通过调用fs.c中的函数进行操作。
##### Exercise 6
实现fs/serv.c中的serve_write()和lib/file.c中的devfile_write()。
`serve_write()`
```C
int serve_write(envid_t envid, struct Fsreq_write *req) {
  if (debug)
    cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

  // LAB 5: Your code here.
  struct OpenFile *o;
  int r;
  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
    return r;
  }
  int total = 0;
  while (1) {
    r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset);
    if (r < 0)
      return r;
    total += r;
    o->o_fd->fd_offset += r;
    if (req->req_n <= total)
      break;
  }
  return total;
}
```
类似于serve_read()。

`devfile_write()`
```C
static ssize_t devfile_write(struct Fd *fd, const void *buf, size_t n)
{
    // Make an FSREQ_WRITE request to the file system server.  Be
    // careful: fsipcbuf.write.req_buf is only so large, but
    // remember that write is always allowed to write *fewer*
    // bytes than requested.
    // LAB 5: Your code here
    int r;
    fsipcbuf.write.req_fileid = fd->fd_file.id;
    fsipcbuf.write.req_n = n;
    memmove(fsipcbuf.write.req_buf, buf, n);
    return fsipc(FSREQ_WRITE, NULL);
}
```

### Spawning Processes
##### Exercise 7
实现sys_env_set_trapframe()系统调用。
```C
static int sys_env_set_trapframe(envid_t envid, struct Trapframe *tf) {
  // LAB 5: Your code here.
  // Remember to check whether the user has supplied us with a good
  // address!
  int r;
  struct Env *e;
  if ((r = envid2env(envid, &e, 1)) < 0) {
    return r;
  }
  tf->tf_eflags |= FL_IF;
  tf->tf_eflags &= ~FL_IOPL_MASK; //普通进程不能有IO权限
  tf->tf_cs = GD_UT | 3;
  e->env_tf = *tf;
  return 0;
}
```
##### Exercise 8
修改lib/fork.c中的duppage()，使之正确处理有PTE_SHARE标志的页表条目。同时实现lib/spawn.c中的copy_shared_pages()。
`copy_shared_pages()`
```C
static int copy_shared_pages(envid_t child)
{
    // LAB 5: Your code here.
    uintptr_t addr;
    for (addr = 0; addr < UTOP; addr += PGSIZE) {
        if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
                (uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
            sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
        }
    }
    return 0;
}
```
### The keyboard interface
##### Exercise 9
```C
// Handle keyboard and serial interrupts.
if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
  kbd_intr();
  return;
}
if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
  serial_intr();
  return;
}
```

### The Shell
##### Exercise 10
目前shell还不支持IO重定向，修改user/sh.c，增加IO该功能。
```C
if ((fd = open(t, O_RDONLY)) < 0) {
    cprintf("open %s for write: %e", t, fd);
    exit();
}
if (fd != 0) {
    dup(fd, 0);
    close(fd);
}
```