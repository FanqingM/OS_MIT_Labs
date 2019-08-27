
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:


// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 6b 01 00 00       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 72 01 00    	add    $0x172be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 d8 ce fe ff    	lea    -0x13128(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 d4 30 00 00       	call   f0103137 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 b5 08 00 00       	call   f010092d <backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 f4 ce fe ff    	lea    -0x1310c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 ac 30 00 00       	call   f0103137 <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:


void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 03 01 00 00       	call   f01001b5 <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 72 01 00    	add    $0x17256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 90 11 f0    	mov    $0xf0119060,%edx
f01000be:	c7 c0 c0 96 11 f0    	mov    $0xf01196c0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 d2 3c 00 00       	call   f0103da1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 48 05 00 00       	call   f010061c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 0f cf fe ff    	lea    -0x130f1(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 4f 30 00 00       	call   f0103137 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000e8:	e8 cc 13 00 00       	call   f01014b9 <mem_init>
f01000ed:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f0:	83 ec 0c             	sub    $0xc,%esp
f01000f3:	6a 00                	push   $0x0
f01000f5:	e8 09 09 00 00       	call   f0100a03 <monitor>
f01000fa:	83 c4 10             	add    $0x10,%esp
f01000fd:	eb f1                	jmp    f01000f0 <i386_init+0x4a>

f01000ff <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000ff:	55                   	push   %ebp
f0100100:	89 e5                	mov    %esp,%ebp
f0100102:	57                   	push   %edi
f0100103:	56                   	push   %esi
f0100104:	53                   	push   %ebx
f0100105:	83 ec 0c             	sub    $0xc,%esp
f0100108:	e8 a8 00 00 00       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010010d:	81 c3 fb 71 01 00    	add    $0x171fb,%ebx
f0100113:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100116:	c7 c0 c4 96 11 f0    	mov    $0xf01196c4,%eax
f010011c:	83 38 00             	cmpl   $0x0,(%eax)
f010011f:	74 0f                	je     f0100130 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100121:	83 ec 0c             	sub    $0xc,%esp
f0100124:	6a 00                	push   $0x0
f0100126:	e8 d8 08 00 00       	call   f0100a03 <monitor>
f010012b:	83 c4 10             	add    $0x10,%esp
f010012e:	eb f1                	jmp    f0100121 <_panic+0x22>
	panicstr = fmt;
f0100130:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100132:	fa                   	cli    
f0100133:	fc                   	cld    
	va_start(ap, fmt);
f0100134:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100137:	83 ec 04             	sub    $0x4,%esp
f010013a:	ff 75 0c             	pushl  0xc(%ebp)
f010013d:	ff 75 08             	pushl  0x8(%ebp)
f0100140:	8d 83 2a cf fe ff    	lea    -0x130d6(%ebx),%eax
f0100146:	50                   	push   %eax
f0100147:	e8 eb 2f 00 00       	call   f0103137 <cprintf>
	vcprintf(fmt, ap);
f010014c:	83 c4 08             	add    $0x8,%esp
f010014f:	56                   	push   %esi
f0100150:	57                   	push   %edi
f0100151:	e8 aa 2f 00 00       	call   f0103100 <vcprintf>
	cprintf("\n");
f0100156:	8d 83 f3 d6 fe ff    	lea    -0x1290d(%ebx),%eax
f010015c:	89 04 24             	mov    %eax,(%esp)
f010015f:	e8 d3 2f 00 00       	call   f0103137 <cprintf>
f0100164:	83 c4 10             	add    $0x10,%esp
f0100167:	eb b8                	jmp    f0100121 <_panic+0x22>

f0100169 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100169:	55                   	push   %ebp
f010016a:	89 e5                	mov    %esp,%ebp
f010016c:	56                   	push   %esi
f010016d:	53                   	push   %ebx
f010016e:	e8 42 00 00 00       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0100173:	81 c3 95 71 01 00    	add    $0x17195,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100179:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010017c:	83 ec 04             	sub    $0x4,%esp
f010017f:	ff 75 0c             	pushl  0xc(%ebp)
f0100182:	ff 75 08             	pushl  0x8(%ebp)
f0100185:	8d 83 42 cf fe ff    	lea    -0x130be(%ebx),%eax
f010018b:	50                   	push   %eax
f010018c:	e8 a6 2f 00 00       	call   f0103137 <cprintf>
	vcprintf(fmt, ap);
f0100191:	83 c4 08             	add    $0x8,%esp
f0100194:	56                   	push   %esi
f0100195:	ff 75 10             	pushl  0x10(%ebp)
f0100198:	e8 63 2f 00 00       	call   f0103100 <vcprintf>
	cprintf("\n");
f010019d:	8d 83 f3 d6 fe ff    	lea    -0x1290d(%ebx),%eax
f01001a3:	89 04 24             	mov    %eax,(%esp)
f01001a6:	e8 8c 2f 00 00       	call   f0103137 <cprintf>
	va_end(ap);
}
f01001ab:	83 c4 10             	add    $0x10,%esp
f01001ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b1:	5b                   	pop    %ebx
f01001b2:	5e                   	pop    %esi
f01001b3:	5d                   	pop    %ebp
f01001b4:	c3                   	ret    

f01001b5 <__x86.get_pc_thunk.bx>:
f01001b5:	8b 1c 24             	mov    (%esp),%ebx
f01001b8:	c3                   	ret    

f01001b9 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001b9:	55                   	push   %ebp
f01001ba:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001bc:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c1:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c2:	a8 01                	test   $0x1,%al
f01001c4:	74 0b                	je     f01001d1 <serial_proc_data+0x18>
f01001c6:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001cb:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001cc:	0f b6 c0             	movzbl %al,%eax
}
f01001cf:	5d                   	pop    %ebp
f01001d0:	c3                   	ret    
		return -1;
f01001d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001d6:	eb f7                	jmp    f01001cf <serial_proc_data+0x16>

f01001d8 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001d8:	55                   	push   %ebp
f01001d9:	89 e5                	mov    %esp,%ebp
f01001db:	56                   	push   %esi
f01001dc:	53                   	push   %ebx
f01001dd:	e8 d3 ff ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f01001e2:	81 c3 26 71 01 00    	add    $0x17126,%ebx
f01001e8:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001ea:	ff d6                	call   *%esi
f01001ec:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001ef:	74 2e                	je     f010021f <cons_intr+0x47>
		if (c == 0)
f01001f1:	85 c0                	test   %eax,%eax
f01001f3:	74 f5                	je     f01001ea <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001f5:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f01001fb:	8d 51 01             	lea    0x1(%ecx),%edx
f01001fe:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f0100204:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f010020b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100211:	75 d7                	jne    f01001ea <cons_intr+0x12>
			cons.wpos = 0;
f0100213:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f010021a:	00 00 00 
f010021d:	eb cb                	jmp    f01001ea <cons_intr+0x12>
	}
}
f010021f:	5b                   	pop    %ebx
f0100220:	5e                   	pop    %esi
f0100221:	5d                   	pop    %ebp
f0100222:	c3                   	ret    

f0100223 <kbd_proc_data>:
{
f0100223:	55                   	push   %ebp
f0100224:	89 e5                	mov    %esp,%ebp
f0100226:	56                   	push   %esi
f0100227:	53                   	push   %ebx
f0100228:	e8 88 ff ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010022d:	81 c3 db 70 01 00    	add    $0x170db,%ebx
f0100233:	ba 64 00 00 00       	mov    $0x64,%edx
f0100238:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100239:	a8 01                	test   $0x1,%al
f010023b:	0f 84 06 01 00 00    	je     f0100347 <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100241:	a8 20                	test   $0x20,%al
f0100243:	0f 85 05 01 00 00    	jne    f010034e <kbd_proc_data+0x12b>
f0100249:	ba 60 00 00 00       	mov    $0x60,%edx
f010024e:	ec                   	in     (%dx),%al
f010024f:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100251:	3c e0                	cmp    $0xe0,%al
f0100253:	0f 84 93 00 00 00    	je     f01002ec <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100259:	84 c0                	test   %al,%al
f010025b:	0f 88 a0 00 00 00    	js     f0100301 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100261:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100267:	f6 c1 40             	test   $0x40,%cl
f010026a:	74 0e                	je     f010027a <kbd_proc_data+0x57>
		data |= 0x80;
f010026c:	83 c8 80             	or     $0xffffff80,%eax
f010026f:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100271:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100274:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f010027a:	0f b6 d2             	movzbl %dl,%edx
f010027d:	0f b6 84 13 98 d0 fe 	movzbl -0x12f68(%ebx,%edx,1),%eax
f0100284:	ff 
f0100285:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f010028b:	0f b6 8c 13 98 cf fe 	movzbl -0x13068(%ebx,%edx,1),%ecx
f0100292:	ff 
f0100293:	31 c8                	xor    %ecx,%eax
f0100295:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010029b:	89 c1                	mov    %eax,%ecx
f010029d:	83 e1 03             	and    $0x3,%ecx
f01002a0:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002a7:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002ab:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002ae:	a8 08                	test   $0x8,%al
f01002b0:	74 0d                	je     f01002bf <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b2:	89 f2                	mov    %esi,%edx
f01002b4:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002b7:	83 f9 19             	cmp    $0x19,%ecx
f01002ba:	77 7a                	ja     f0100336 <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002bc:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002bf:	f7 d0                	not    %eax
f01002c1:	a8 06                	test   $0x6,%al
f01002c3:	75 33                	jne    f01002f8 <kbd_proc_data+0xd5>
f01002c5:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002cb:	75 2b                	jne    f01002f8 <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002cd:	83 ec 0c             	sub    $0xc,%esp
f01002d0:	8d 83 5c cf fe ff    	lea    -0x130a4(%ebx),%eax
f01002d6:	50                   	push   %eax
f01002d7:	e8 5b 2e 00 00       	call   f0103137 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002dc:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e1:	ba 92 00 00 00       	mov    $0x92,%edx
f01002e6:	ee                   	out    %al,(%dx)
f01002e7:	83 c4 10             	add    $0x10,%esp
f01002ea:	eb 0c                	jmp    f01002f8 <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002ec:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002f3:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002f8:	89 f0                	mov    %esi,%eax
f01002fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002fd:	5b                   	pop    %ebx
f01002fe:	5e                   	pop    %esi
f01002ff:	5d                   	pop    %ebp
f0100300:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100301:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100307:	89 ce                	mov    %ecx,%esi
f0100309:	83 e6 40             	and    $0x40,%esi
f010030c:	83 e0 7f             	and    $0x7f,%eax
f010030f:	85 f6                	test   %esi,%esi
f0100311:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100314:	0f b6 d2             	movzbl %dl,%edx
f0100317:	0f b6 84 13 98 d0 fe 	movzbl -0x12f68(%ebx,%edx,1),%eax
f010031e:	ff 
f010031f:	83 c8 40             	or     $0x40,%eax
f0100322:	0f b6 c0             	movzbl %al,%eax
f0100325:	f7 d0                	not    %eax
f0100327:	21 c8                	and    %ecx,%eax
f0100329:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f010032f:	be 00 00 00 00       	mov    $0x0,%esi
f0100334:	eb c2                	jmp    f01002f8 <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f0100336:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100339:	8d 4e 20             	lea    0x20(%esi),%ecx
f010033c:	83 fa 1a             	cmp    $0x1a,%edx
f010033f:	0f 42 f1             	cmovb  %ecx,%esi
f0100342:	e9 78 ff ff ff       	jmp    f01002bf <kbd_proc_data+0x9c>
		return -1;
f0100347:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010034c:	eb aa                	jmp    f01002f8 <kbd_proc_data+0xd5>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb a3                	jmp    f01002f8 <kbd_proc_data+0xd5>

f0100355 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100355:	55                   	push   %ebp
f0100356:	89 e5                	mov    %esp,%ebp
f0100358:	57                   	push   %edi
f0100359:	56                   	push   %esi
f010035a:	53                   	push   %ebx
f010035b:	83 ec 1c             	sub    $0x1c,%esp
f010035e:	e8 52 fe ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0100363:	81 c3 a5 6f 01 00    	add    $0x16fa5,%ebx
f0100369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010036c:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100371:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100376:	b9 84 00 00 00       	mov    $0x84,%ecx
f010037b:	eb 09                	jmp    f0100386 <cons_putc+0x31>
f010037d:	89 ca                	mov    %ecx,%edx
f010037f:	ec                   	in     (%dx),%al
f0100380:	ec                   	in     (%dx),%al
f0100381:	ec                   	in     (%dx),%al
f0100382:	ec                   	in     (%dx),%al
	     i++)
f0100383:	83 c6 01             	add    $0x1,%esi
f0100386:	89 fa                	mov    %edi,%edx
f0100388:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100389:	a8 20                	test   $0x20,%al
f010038b:	75 08                	jne    f0100395 <cons_putc+0x40>
f010038d:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100393:	7e e8                	jle    f010037d <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f0100395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100398:	89 f8                	mov    %edi,%eax
f010039a:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010039d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a2:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003a3:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a8:	bf 79 03 00 00       	mov    $0x379,%edi
f01003ad:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b2:	eb 09                	jmp    f01003bd <cons_putc+0x68>
f01003b4:	89 ca                	mov    %ecx,%edx
f01003b6:	ec                   	in     (%dx),%al
f01003b7:	ec                   	in     (%dx),%al
f01003b8:	ec                   	in     (%dx),%al
f01003b9:	ec                   	in     (%dx),%al
f01003ba:	83 c6 01             	add    $0x1,%esi
f01003bd:	89 fa                	mov    %edi,%edx
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003c6:	7f 04                	jg     f01003cc <cons_putc+0x77>
f01003c8:	84 c0                	test   %al,%al
f01003ca:	79 e8                	jns    f01003b4 <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cc:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d1:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003d5:	ee                   	out    %al,(%dx)
f01003d6:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003db:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e0:	ee                   	out    %al,(%dx)
f01003e1:	b8 08 00 00 00       	mov    $0x8,%eax
f01003e6:	ee                   	out    %al,(%dx)
	if(!csa) csa = 0x0700;
f01003e7:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01003ed:	83 38 00             	cmpl   $0x0,(%eax)
f01003f0:	75 06                	jne    f01003f8 <cons_putc+0xa3>
f01003f2:	c7 00 00 07 00 00    	movl   $0x700,(%eax)
	if (!(c & ~0xFF))
f01003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003fb:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100401:	75 0d                	jne    f0100410 <cons_putc+0xbb>
		c |= csa;
f0100403:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f0100409:	8b 00                	mov    (%eax),%eax
f010040b:	09 c7                	or     %eax,%edi
f010040d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	switch (c & 0xff) {
f0100410:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100414:	83 f8 09             	cmp    $0x9,%eax
f0100417:	0f 84 b9 00 00 00    	je     f01004d6 <cons_putc+0x181>
f010041d:	83 f8 09             	cmp    $0x9,%eax
f0100420:	7e 74                	jle    f0100496 <cons_putc+0x141>
f0100422:	83 f8 0a             	cmp    $0xa,%eax
f0100425:	0f 84 9e 00 00 00    	je     f01004c9 <cons_putc+0x174>
f010042b:	83 f8 0d             	cmp    $0xd,%eax
f010042e:	0f 85 d9 00 00 00    	jne    f010050d <cons_putc+0x1b8>
		crt_pos -= (crt_pos % CRT_COLS);
f0100434:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010043b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100441:	c1 e8 16             	shr    $0x16,%eax
f0100444:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100447:	c1 e0 04             	shl    $0x4,%eax
f010044a:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100451:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f0100458:	cf 07 
f010045a:	0f 87 d4 00 00 00    	ja     f0100534 <cons_putc+0x1df>
	outb(addr_6845, 14);
f0100460:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f0100466:	b8 0e 00 00 00       	mov    $0xe,%eax
f010046b:	89 ca                	mov    %ecx,%edx
f010046d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010046e:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f0100475:	8d 71 01             	lea    0x1(%ecx),%esi
f0100478:	89 d8                	mov    %ebx,%eax
f010047a:	66 c1 e8 08          	shr    $0x8,%ax
f010047e:	89 f2                	mov    %esi,%edx
f0100480:	ee                   	out    %al,(%dx)
f0100481:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100486:	89 ca                	mov    %ecx,%edx
f0100488:	ee                   	out    %al,(%dx)
f0100489:	89 d8                	mov    %ebx,%eax
f010048b:	89 f2                	mov    %esi,%edx
f010048d:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010048e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100491:	5b                   	pop    %ebx
f0100492:	5e                   	pop    %esi
f0100493:	5f                   	pop    %edi
f0100494:	5d                   	pop    %ebp
f0100495:	c3                   	ret    
	switch (c & 0xff) {
f0100496:	83 f8 08             	cmp    $0x8,%eax
f0100499:	75 72                	jne    f010050d <cons_putc+0x1b8>
		if (crt_pos > 0) {
f010049b:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004a2:	66 85 c0             	test   %ax,%ax
f01004a5:	74 b9                	je     f0100460 <cons_putc+0x10b>
			crt_pos--;
f01004a7:	83 e8 01             	sub    $0x1,%eax
f01004aa:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b1:	0f b7 c0             	movzwl %ax,%eax
f01004b4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004b8:	b2 00                	mov    $0x0,%dl
f01004ba:	83 ca 20             	or     $0x20,%edx
f01004bd:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004c3:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004c7:	eb 88                	jmp    f0100451 <cons_putc+0xfc>
		crt_pos += CRT_COLS;
f01004c9:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004d0:	50 
f01004d1:	e9 5e ff ff ff       	jmp    f0100434 <cons_putc+0xdf>
		cons_putc(' ');
f01004d6:	b8 20 00 00 00       	mov    $0x20,%eax
f01004db:	e8 75 fe ff ff       	call   f0100355 <cons_putc>
		cons_putc(' ');
f01004e0:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e5:	e8 6b fe ff ff       	call   f0100355 <cons_putc>
		cons_putc(' ');
f01004ea:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ef:	e8 61 fe ff ff       	call   f0100355 <cons_putc>
		cons_putc(' ');
f01004f4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f9:	e8 57 fe ff ff       	call   f0100355 <cons_putc>
		cons_putc(' ');
f01004fe:	b8 20 00 00 00       	mov    $0x20,%eax
f0100503:	e8 4d fe ff ff       	call   f0100355 <cons_putc>
f0100508:	e9 44 ff ff ff       	jmp    f0100451 <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f010050d:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100514:	8d 50 01             	lea    0x1(%eax),%edx
f0100517:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f010051e:	0f b7 c0             	movzwl %ax,%eax
f0100521:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100527:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f010052b:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010052f:	e9 1d ff ff ff       	jmp    f0100451 <cons_putc+0xfc>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100534:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010053a:	83 ec 04             	sub    $0x4,%esp
f010053d:	68 00 0f 00 00       	push   $0xf00
f0100542:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100548:	52                   	push   %edx
f0100549:	50                   	push   %eax
f010054a:	e8 9f 38 00 00       	call   f0103dee <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010054f:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100555:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010055b:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100561:	83 c4 10             	add    $0x10,%esp
f0100564:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100569:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010056c:	39 d0                	cmp    %edx,%eax
f010056e:	75 f4                	jne    f0100564 <cons_putc+0x20f>
		crt_pos -= CRT_COLS;
f0100570:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f0100577:	50 
f0100578:	e9 e3 fe ff ff       	jmp    f0100460 <cons_putc+0x10b>

f010057d <serial_intr>:
{
f010057d:	e8 e7 01 00 00       	call   f0100769 <__x86.get_pc_thunk.ax>
f0100582:	05 86 6d 01 00       	add    $0x16d86,%eax
	if (serial_exists)
f0100587:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f010058e:	75 02                	jne    f0100592 <serial_intr+0x15>
f0100590:	f3 c3                	repz ret 
{
f0100592:	55                   	push   %ebp
f0100593:	89 e5                	mov    %esp,%ebp
f0100595:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100598:	8d 80 b1 8e fe ff    	lea    -0x1714f(%eax),%eax
f010059e:	e8 35 fc ff ff       	call   f01001d8 <cons_intr>
}
f01005a3:	c9                   	leave  
f01005a4:	c3                   	ret    

f01005a5 <kbd_intr>:
{
f01005a5:	55                   	push   %ebp
f01005a6:	89 e5                	mov    %esp,%ebp
f01005a8:	83 ec 08             	sub    $0x8,%esp
f01005ab:	e8 b9 01 00 00       	call   f0100769 <__x86.get_pc_thunk.ax>
f01005b0:	05 58 6d 01 00       	add    $0x16d58,%eax
	cons_intr(kbd_proc_data);
f01005b5:	8d 80 1b 8f fe ff    	lea    -0x170e5(%eax),%eax
f01005bb:	e8 18 fc ff ff       	call   f01001d8 <cons_intr>
}
f01005c0:	c9                   	leave  
f01005c1:	c3                   	ret    

f01005c2 <cons_getc>:
{
f01005c2:	55                   	push   %ebp
f01005c3:	89 e5                	mov    %esp,%ebp
f01005c5:	53                   	push   %ebx
f01005c6:	83 ec 04             	sub    $0x4,%esp
f01005c9:	e8 e7 fb ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f01005ce:	81 c3 3a 6d 01 00    	add    $0x16d3a,%ebx
	serial_intr();
f01005d4:	e8 a4 ff ff ff       	call   f010057d <serial_intr>
	kbd_intr();
f01005d9:	e8 c7 ff ff ff       	call   f01005a5 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005de:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005e4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005e9:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005ef:	74 19                	je     f010060a <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005f1:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005f4:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005fa:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f0100601:	00 
		if (cons.rpos == CONSBUFSIZE)
f0100602:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100608:	74 06                	je     f0100610 <cons_getc+0x4e>
}
f010060a:	83 c4 04             	add    $0x4,%esp
f010060d:	5b                   	pop    %ebx
f010060e:	5d                   	pop    %ebp
f010060f:	c3                   	ret    
			cons.rpos = 0;
f0100610:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f0100617:	00 00 00 
f010061a:	eb ee                	jmp    f010060a <cons_getc+0x48>

f010061c <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010061c:	55                   	push   %ebp
f010061d:	89 e5                	mov    %esp,%ebp
f010061f:	57                   	push   %edi
f0100620:	56                   	push   %esi
f0100621:	53                   	push   %ebx
f0100622:	83 ec 1c             	sub    $0x1c,%esp
f0100625:	e8 8b fb ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010062a:	81 c3 de 6c 01 00    	add    $0x16cde,%ebx
	was = *cp;
f0100630:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100637:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010063e:	5a a5 
	if (*cp != 0xA55A) {
f0100640:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100647:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010064b:	0f 84 bc 00 00 00    	je     f010070d <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100651:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f0100658:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010065b:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100662:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f0100668:	b8 0e 00 00 00       	mov    $0xe,%eax
f010066d:	89 fa                	mov    %edi,%edx
f010066f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100670:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100673:	89 ca                	mov    %ecx,%edx
f0100675:	ec                   	in     (%dx),%al
f0100676:	0f b6 f0             	movzbl %al,%esi
f0100679:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010067c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100681:	89 fa                	mov    %edi,%edx
f0100683:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100684:	89 ca                	mov    %ecx,%edx
f0100686:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010068a:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100690:	0f b6 c0             	movzbl %al,%eax
f0100693:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100695:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010069c:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006a1:	89 c8                	mov    %ecx,%eax
f01006a3:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006a8:	ee                   	out    %al,(%dx)
f01006a9:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006ae:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006b3:	89 fa                	mov    %edi,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006bb:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006c0:	ee                   	out    %al,(%dx)
f01006c1:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006c6:	89 c8                	mov    %ecx,%eax
f01006c8:	89 f2                	mov    %esi,%edx
f01006ca:	ee                   	out    %al,(%dx)
f01006cb:	b8 03 00 00 00       	mov    $0x3,%eax
f01006d0:	89 fa                	mov    %edi,%edx
f01006d2:	ee                   	out    %al,(%dx)
f01006d3:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006d8:	89 c8                	mov    %ecx,%eax
f01006da:	ee                   	out    %al,(%dx)
f01006db:	b8 01 00 00 00       	mov    $0x1,%eax
f01006e0:	89 f2                	mov    %esi,%edx
f01006e2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006e3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006e8:	ec                   	in     (%dx),%al
f01006e9:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006eb:	3c ff                	cmp    $0xff,%al
f01006ed:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006f4:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006f9:	ec                   	in     (%dx),%al
f01006fa:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006ff:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100700:	80 f9 ff             	cmp    $0xff,%cl
f0100703:	74 25                	je     f010072a <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f0100705:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100708:	5b                   	pop    %ebx
f0100709:	5e                   	pop    %esi
f010070a:	5f                   	pop    %edi
f010070b:	5d                   	pop    %ebp
f010070c:	c3                   	ret    
		*cp = was;
f010070d:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100714:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f010071b:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010071e:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100725:	e9 38 ff ff ff       	jmp    f0100662 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010072a:	83 ec 0c             	sub    $0xc,%esp
f010072d:	8d 83 68 cf fe ff    	lea    -0x13098(%ebx),%eax
f0100733:	50                   	push   %eax
f0100734:	e8 fe 29 00 00       	call   f0103137 <cprintf>
f0100739:	83 c4 10             	add    $0x10,%esp
}
f010073c:	eb c7                	jmp    f0100705 <cons_init+0xe9>

f010073e <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010073e:	55                   	push   %ebp
f010073f:	89 e5                	mov    %esp,%ebp
f0100741:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100744:	8b 45 08             	mov    0x8(%ebp),%eax
f0100747:	e8 09 fc ff ff       	call   f0100355 <cons_putc>
}
f010074c:	c9                   	leave  
f010074d:	c3                   	ret    

f010074e <getchar>:

int
getchar(void)
{
f010074e:	55                   	push   %ebp
f010074f:	89 e5                	mov    %esp,%ebp
f0100751:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100754:	e8 69 fe ff ff       	call   f01005c2 <cons_getc>
f0100759:	85 c0                	test   %eax,%eax
f010075b:	74 f7                	je     f0100754 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010075d:	c9                   	leave  
f010075e:	c3                   	ret    

f010075f <iscons>:

int
iscons(int fdnum)
{
f010075f:	55                   	push   %ebp
f0100760:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100762:	b8 01 00 00 00       	mov    $0x1,%eax
f0100767:	5d                   	pop    %ebp
f0100768:	c3                   	ret    

f0100769 <__x86.get_pc_thunk.ax>:
f0100769:	8b 04 24             	mov    (%esp),%eax
f010076c:	c3                   	ret    

f010076d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010076d:	55                   	push   %ebp
f010076e:	89 e5                	mov    %esp,%ebp
f0100770:	56                   	push   %esi
f0100771:	53                   	push   %ebx
f0100772:	e8 3e fa ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0100777:	81 c3 91 6b 01 00    	add    $0x16b91,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010077d:	83 ec 04             	sub    $0x4,%esp
f0100780:	8d 83 98 d1 fe ff    	lea    -0x12e68(%ebx),%eax
f0100786:	50                   	push   %eax
f0100787:	8d 83 b6 d1 fe ff    	lea    -0x12e4a(%ebx),%eax
f010078d:	50                   	push   %eax
f010078e:	8d b3 bb d1 fe ff    	lea    -0x12e45(%ebx),%esi
f0100794:	56                   	push   %esi
f0100795:	e8 9d 29 00 00       	call   f0103137 <cprintf>
f010079a:	83 c4 0c             	add    $0xc,%esp
f010079d:	8d 83 9c d2 fe ff    	lea    -0x12d64(%ebx),%eax
f01007a3:	50                   	push   %eax
f01007a4:	8d 83 c4 d1 fe ff    	lea    -0x12e3c(%ebx),%eax
f01007aa:	50                   	push   %eax
f01007ab:	56                   	push   %esi
f01007ac:	e8 86 29 00 00       	call   f0103137 <cprintf>
	return 0;
}
f01007b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007b9:	5b                   	pop    %ebx
f01007ba:	5e                   	pop    %esi
f01007bb:	5d                   	pop    %ebp
f01007bc:	c3                   	ret    

f01007bd <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007bd:	55                   	push   %ebp
f01007be:	89 e5                	mov    %esp,%ebp
f01007c0:	57                   	push   %edi
f01007c1:	56                   	push   %esi
f01007c2:	53                   	push   %ebx
f01007c3:	83 ec 18             	sub    $0x18,%esp
f01007c6:	e8 ea f9 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f01007cb:	81 c3 3d 6b 01 00    	add    $0x16b3d,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d1:	8d 83 cd d1 fe ff    	lea    -0x12e33(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 5a 29 00 00       	call   f0103137 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007dd:	83 c4 08             	add    $0x8,%esp
f01007e0:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007e6:	8d 83 c4 d2 fe ff    	lea    -0x12d3c(%ebx),%eax
f01007ec:	50                   	push   %eax
f01007ed:	e8 45 29 00 00       	call   f0103137 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f2:	83 c4 0c             	add    $0xc,%esp
f01007f5:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007fb:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100801:	50                   	push   %eax
f0100802:	57                   	push   %edi
f0100803:	8d 83 ec d2 fe ff    	lea    -0x12d14(%ebx),%eax
f0100809:	50                   	push   %eax
f010080a:	e8 28 29 00 00       	call   f0103137 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010080f:	83 c4 0c             	add    $0xc,%esp
f0100812:	c7 c0 d9 41 10 f0    	mov    $0xf01041d9,%eax
f0100818:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010081e:	52                   	push   %edx
f010081f:	50                   	push   %eax
f0100820:	8d 83 10 d3 fe ff    	lea    -0x12cf0(%ebx),%eax
f0100826:	50                   	push   %eax
f0100827:	e8 0b 29 00 00       	call   f0103137 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082c:	83 c4 0c             	add    $0xc,%esp
f010082f:	c7 c0 60 90 11 f0    	mov    $0xf0119060,%eax
f0100835:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010083b:	52                   	push   %edx
f010083c:	50                   	push   %eax
f010083d:	8d 83 34 d3 fe ff    	lea    -0x12ccc(%ebx),%eax
f0100843:	50                   	push   %eax
f0100844:	e8 ee 28 00 00       	call   f0103137 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100849:	83 c4 0c             	add    $0xc,%esp
f010084c:	c7 c6 c0 96 11 f0    	mov    $0xf01196c0,%esi
f0100852:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100858:	50                   	push   %eax
f0100859:	56                   	push   %esi
f010085a:	8d 83 58 d3 fe ff    	lea    -0x12ca8(%ebx),%eax
f0100860:	50                   	push   %eax
f0100861:	e8 d1 28 00 00       	call   f0103137 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100869:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010086f:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100871:	c1 fe 0a             	sar    $0xa,%esi
f0100874:	56                   	push   %esi
f0100875:	8d 83 7c d3 fe ff    	lea    -0x12c84(%ebx),%eax
f010087b:	50                   	push   %eax
f010087c:	e8 b6 28 00 00       	call   f0103137 <cprintf>
	return 0;
}
f0100881:	b8 00 00 00 00       	mov    $0x0,%eax
f0100886:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100889:	5b                   	pop    %ebx
f010088a:	5e                   	pop    %esi
f010088b:	5f                   	pop    %edi
f010088c:	5d                   	pop    %ebp
f010088d:	c3                   	ret    

f010088e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010088e:	55                   	push   %ebp
f010088f:	89 e5                	mov    %esp,%ebp
f0100891:	57                   	push   %edi
f0100892:	56                   	push   %esi
f0100893:	53                   	push   %ebx
f0100894:	83 ec 28             	sub    $0x28,%esp
f0100897:	e8 19 f9 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010089c:	81 c3 6c 6a 01 00    	add    $0x16a6c,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008a2:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*) read_ebp();
f01008a4:	89 c7                	mov    %eax,%edi
	cprintf("Stack backtrace:\n");
f01008a6:	8d 83 e6 d1 fe ff    	lea    -0x12e1a(%ebx),%eax
f01008ac:	50                   	push   %eax
f01008ad:	e8 85 28 00 00       	call   f0103137 <cprintf>
	while(ebp){
f01008b2:	83 c4 10             	add    $0x10,%esp
		cprintf("ebp %x  ebp %x  args", ebp, *(ebp+1));
f01008b5:	8d 83 f8 d1 fe ff    	lea    -0x12e08(%ebx),%eax
f01008bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		cprintf(" %x", *(ebp+2));
f01008be:	8d b3 0d d2 fe ff    	lea    -0x12df3(%ebx),%esi
	while(ebp){
f01008c4:	eb 56                	jmp    f010091c <mon_backtrace+0x8e>
		cprintf("ebp %x  ebp %x  args", ebp, *(ebp+1));
f01008c6:	83 ec 04             	sub    $0x4,%esp
f01008c9:	ff 77 04             	pushl  0x4(%edi)
f01008cc:	57                   	push   %edi
f01008cd:	ff 75 e4             	pushl  -0x1c(%ebp)
f01008d0:	e8 62 28 00 00       	call   f0103137 <cprintf>
		cprintf(" %x", *(ebp+2));
f01008d5:	83 c4 08             	add    $0x8,%esp
f01008d8:	ff 77 08             	pushl  0x8(%edi)
f01008db:	56                   	push   %esi
f01008dc:	e8 56 28 00 00       	call   f0103137 <cprintf>
		cprintf(" %x", *(ebp+3));
f01008e1:	83 c4 08             	add    $0x8,%esp
f01008e4:	ff 77 0c             	pushl  0xc(%edi)
f01008e7:	56                   	push   %esi
f01008e8:	e8 4a 28 00 00       	call   f0103137 <cprintf>
		cprintf(" %x", *(ebp+4));
f01008ed:	83 c4 08             	add    $0x8,%esp
f01008f0:	ff 77 10             	pushl  0x10(%edi)
f01008f3:	56                   	push   %esi
f01008f4:	e8 3e 28 00 00       	call   f0103137 <cprintf>
		cprintf(" %x", *(ebp+5));
f01008f9:	83 c4 08             	add    $0x8,%esp
f01008fc:	ff 77 14             	pushl  0x14(%edi)
f01008ff:	56                   	push   %esi
f0100900:	e8 32 28 00 00       	call   f0103137 <cprintf>
		cprintf(" %x\n", *(ebp+6));
f0100905:	83 c4 08             	add    $0x8,%esp
f0100908:	ff 77 18             	pushl  0x18(%edi)
f010090b:	8d 83 16 d7 fe ff    	lea    -0x128ea(%ebx),%eax
f0100911:	50                   	push   %eax
f0100912:	e8 20 28 00 00       	call   f0103137 <cprintf>
		ebp = (uint32_t*) *ebp;
f0100917:	8b 3f                	mov    (%edi),%edi
f0100919:	83 c4 10             	add    $0x10,%esp
	while(ebp){
f010091c:	85 ff                	test   %edi,%edi
f010091e:	75 a6                	jne    f01008c6 <mon_backtrace+0x38>
	}
	// Your code here.
	return 0;
}
f0100920:	b8 00 00 00 00       	mov    $0x0,%eax
f0100925:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100928:	5b                   	pop    %ebx
f0100929:	5e                   	pop    %esi
f010092a:	5f                   	pop    %edi
f010092b:	5d                   	pop    %ebp
f010092c:	c3                   	ret    

f010092d <backtrace>:

int backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010092d:	55                   	push   %ebp
f010092e:	89 e5                	mov    %esp,%ebp
f0100930:	57                   	push   %edi
f0100931:	56                   	push   %esi
f0100932:	53                   	push   %ebx
f0100933:	83 ec 58             	sub    $0x58,%esp
f0100936:	e8 7a f8 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010093b:	81 c3 cd 69 01 00    	add    $0x169cd,%ebx
f0100941:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp = (uint32_t*) read_ebp();
f0100943:	89 c7                	mov    %eax,%edi
	cprintf("Stack backtrace:\n");
f0100945:	8d 83 e6 d1 fe ff    	lea    -0x12e1a(%ebx),%eax
f010094b:	50                   	push   %eax
f010094c:	e8 e6 27 00 00       	call   f0103137 <cprintf>
	while(ebp){
f0100951:	83 c4 10             	add    $0x10,%esp
		uint32_t eip = ebp[1];
		cprintf("ebp %x  eip %x  args", ebp, eip);
f0100954:	8d 83 11 d2 fe ff    	lea    -0x12def(%ebx),%eax
f010095a:	89 45 b8             	mov    %eax,-0x48(%ebp)
		int i;
		for(i = 2; i <= 6; ++i)
			cprintf(" %08.x",ebp[i]);
f010095d:	8d 83 26 d2 fe ff    	lea    -0x12dda(%ebx),%eax
f0100963:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	while(ebp){
f0100966:	e9 83 00 00 00       	jmp    f01009ee <backtrace+0xc1>
		uint32_t eip = ebp[1];
f010096b:	8b 47 04             	mov    0x4(%edi),%eax
f010096e:	89 45 c0             	mov    %eax,-0x40(%ebp)
		cprintf("ebp %x  eip %x  args", ebp, eip);
f0100971:	83 ec 04             	sub    $0x4,%esp
f0100974:	50                   	push   %eax
f0100975:	57                   	push   %edi
f0100976:	ff 75 b8             	pushl  -0x48(%ebp)
f0100979:	e8 b9 27 00 00       	call   f0103137 <cprintf>
f010097e:	8d 77 08             	lea    0x8(%edi),%esi
f0100981:	8d 47 1c             	lea    0x1c(%edi),%eax
f0100984:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100987:	83 c4 10             	add    $0x10,%esp
f010098a:	89 7d bc             	mov    %edi,-0x44(%ebp)
f010098d:	8b 7d b4             	mov    -0x4c(%ebp),%edi
			cprintf(" %08.x",ebp[i]);
f0100990:	83 ec 08             	sub    $0x8,%esp
f0100993:	ff 36                	pushl  (%esi)
f0100995:	57                   	push   %edi
f0100996:	e8 9c 27 00 00       	call   f0103137 <cprintf>
f010099b:	83 c6 04             	add    $0x4,%esi
		for(i = 2; i <= 6; ++i)
f010099e:	83 c4 10             	add    $0x10,%esp
f01009a1:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f01009a4:	75 ea                	jne    f0100990 <backtrace+0x63>
f01009a6:	8b 7d bc             	mov    -0x44(%ebp),%edi
		cprintf("\n");
f01009a9:	83 ec 0c             	sub    $0xc,%esp
f01009ac:	8d 83 f3 d6 fe ff    	lea    -0x1290d(%ebx),%eax
f01009b2:	50                   	push   %eax
f01009b3:	e8 7f 27 00 00       	call   f0103137 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f01009b8:	83 c4 08             	add    $0x8,%esp
f01009bb:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01009be:	50                   	push   %eax
f01009bf:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01009c2:	56                   	push   %esi
f01009c3:	e8 73 28 00 00       	call   f010323b <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n",
f01009c8:	83 c4 08             	add    $0x8,%esp
f01009cb:	89 f0                	mov    %esi,%eax
f01009cd:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01009d0:	50                   	push   %eax
f01009d1:	ff 75 d8             	pushl  -0x28(%ebp)
f01009d4:	ff 75 dc             	pushl  -0x24(%ebp)
f01009d7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01009da:	ff 75 d0             	pushl  -0x30(%ebp)
f01009dd:	8d 83 2d d2 fe ff    	lea    -0x12dd3(%ebx),%eax
f01009e3:	50                   	push   %eax
f01009e4:	e8 4e 27 00 00       	call   f0103137 <cprintf>
			info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
		ebp = (uint32_t*) *ebp	;
f01009e9:	8b 3f                	mov    (%edi),%edi
f01009eb:	83 c4 20             	add    $0x20,%esp
	while(ebp){
f01009ee:	85 ff                	test   %edi,%edi
f01009f0:	0f 85 75 ff ff ff    	jne    f010096b <backtrace+0x3e>
	}
	return 0;
}
f01009f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01009fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009fe:	5b                   	pop    %ebx
f01009ff:	5e                   	pop    %esi
f0100a00:	5f                   	pop    %edi
f0100a01:	5d                   	pop    %ebp
f0100a02:	c3                   	ret    

f0100a03 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100a03:	55                   	push   %ebp
f0100a04:	89 e5                	mov    %esp,%ebp
f0100a06:	57                   	push   %edi
f0100a07:	56                   	push   %esi
f0100a08:	53                   	push   %ebx
f0100a09:	83 ec 68             	sub    $0x68,%esp
f0100a0c:	e8 a4 f7 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0100a11:	81 c3 f7 68 01 00    	add    $0x168f7,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100a17:	8d 83 a8 d3 fe ff    	lea    -0x12c58(%ebx),%eax
f0100a1d:	50                   	push   %eax
f0100a1e:	e8 14 27 00 00       	call   f0103137 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a23:	8d 83 cc d3 fe ff    	lea    -0x12c34(%ebx),%eax
f0100a29:	89 04 24             	mov    %eax,(%esp)
f0100a2c:	e8 06 27 00 00       	call   f0103137 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n",0x0100,"blue",0x0200,"green",0x0400,"red");
f0100a31:	83 c4 0c             	add    $0xc,%esp
f0100a34:	8d 83 3e d2 fe ff    	lea    -0x12dc2(%ebx),%eax
f0100a3a:	50                   	push   %eax
f0100a3b:	68 00 04 00 00       	push   $0x400
f0100a40:	8d 83 42 d2 fe ff    	lea    -0x12dbe(%ebx),%eax
f0100a46:	50                   	push   %eax
f0100a47:	68 00 02 00 00       	push   $0x200
f0100a4c:	8d 83 48 d2 fe ff    	lea    -0x12db8(%ebx),%eax
f0100a52:	50                   	push   %eax
f0100a53:	68 00 01 00 00       	push   $0x100
f0100a58:	8d 83 4d d2 fe ff    	lea    -0x12db3(%ebx),%eax
f0100a5e:	50                   	push   %eax
f0100a5f:	e8 d3 26 00 00       	call   f0103137 <cprintf>
f0100a64:	83 c4 20             	add    $0x20,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100a67:	8d bb 61 d2 fe ff    	lea    -0x12d9f(%ebx),%edi
f0100a6d:	eb 4a                	jmp    f0100ab9 <monitor+0xb6>
f0100a6f:	83 ec 08             	sub    $0x8,%esp
f0100a72:	0f be c0             	movsbl %al,%eax
f0100a75:	50                   	push   %eax
f0100a76:	57                   	push   %edi
f0100a77:	e8 e8 32 00 00       	call   f0103d64 <strchr>
f0100a7c:	83 c4 10             	add    $0x10,%esp
f0100a7f:	85 c0                	test   %eax,%eax
f0100a81:	74 08                	je     f0100a8b <monitor+0x88>
			*buf++ = 0;
f0100a83:	c6 06 00             	movb   $0x0,(%esi)
f0100a86:	8d 76 01             	lea    0x1(%esi),%esi
f0100a89:	eb 79                	jmp    f0100b04 <monitor+0x101>
		if (*buf == 0)
f0100a8b:	80 3e 00             	cmpb   $0x0,(%esi)
f0100a8e:	74 7f                	je     f0100b0f <monitor+0x10c>
		if (argc == MAXARGS-1) {
f0100a90:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100a94:	74 0f                	je     f0100aa5 <monitor+0xa2>
		argv[argc++] = buf;
f0100a96:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a99:	8d 48 01             	lea    0x1(%eax),%ecx
f0100a9c:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100a9f:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100aa3:	eb 44                	jmp    f0100ae9 <monitor+0xe6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100aa5:	83 ec 08             	sub    $0x8,%esp
f0100aa8:	6a 10                	push   $0x10
f0100aaa:	8d 83 66 d2 fe ff    	lea    -0x12d9a(%ebx),%eax
f0100ab0:	50                   	push   %eax
f0100ab1:	e8 81 26 00 00       	call   f0103137 <cprintf>
f0100ab6:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ab9:	8d 83 5d d2 fe ff    	lea    -0x12da3(%ebx),%eax
f0100abf:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100ac2:	83 ec 0c             	sub    $0xc,%esp
f0100ac5:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100ac8:	e8 5f 30 00 00       	call   f0103b2c <readline>
f0100acd:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100acf:	83 c4 10             	add    $0x10,%esp
f0100ad2:	85 c0                	test   %eax,%eax
f0100ad4:	74 ec                	je     f0100ac2 <monitor+0xbf>
	argv[argc] = 0;
f0100ad6:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100add:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100ae4:	eb 1e                	jmp    f0100b04 <monitor+0x101>
			buf++;
f0100ae6:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ae9:	0f b6 06             	movzbl (%esi),%eax
f0100aec:	84 c0                	test   %al,%al
f0100aee:	74 14                	je     f0100b04 <monitor+0x101>
f0100af0:	83 ec 08             	sub    $0x8,%esp
f0100af3:	0f be c0             	movsbl %al,%eax
f0100af6:	50                   	push   %eax
f0100af7:	57                   	push   %edi
f0100af8:	e8 67 32 00 00       	call   f0103d64 <strchr>
f0100afd:	83 c4 10             	add    $0x10,%esp
f0100b00:	85 c0                	test   %eax,%eax
f0100b02:	74 e2                	je     f0100ae6 <monitor+0xe3>
		while (*buf && strchr(WHITESPACE, *buf))
f0100b04:	0f b6 06             	movzbl (%esi),%eax
f0100b07:	84 c0                	test   %al,%al
f0100b09:	0f 85 60 ff ff ff    	jne    f0100a6f <monitor+0x6c>
	argv[argc] = 0;
f0100b0f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100b12:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100b19:	00 
	if (argc == 0)
f0100b1a:	85 c0                	test   %eax,%eax
f0100b1c:	74 9b                	je     f0100ab9 <monitor+0xb6>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b1e:	83 ec 08             	sub    $0x8,%esp
f0100b21:	8d 83 b6 d1 fe ff    	lea    -0x12e4a(%ebx),%eax
f0100b27:	50                   	push   %eax
f0100b28:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b2b:	e8 d6 31 00 00       	call   f0103d06 <strcmp>
f0100b30:	83 c4 10             	add    $0x10,%esp
f0100b33:	85 c0                	test   %eax,%eax
f0100b35:	74 38                	je     f0100b6f <monitor+0x16c>
f0100b37:	83 ec 08             	sub    $0x8,%esp
f0100b3a:	8d 83 c4 d1 fe ff    	lea    -0x12e3c(%ebx),%eax
f0100b40:	50                   	push   %eax
f0100b41:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b44:	e8 bd 31 00 00       	call   f0103d06 <strcmp>
f0100b49:	83 c4 10             	add    $0x10,%esp
f0100b4c:	85 c0                	test   %eax,%eax
f0100b4e:	74 1a                	je     f0100b6a <monitor+0x167>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b50:	83 ec 08             	sub    $0x8,%esp
f0100b53:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b56:	8d 83 83 d2 fe ff    	lea    -0x12d7d(%ebx),%eax
f0100b5c:	50                   	push   %eax
f0100b5d:	e8 d5 25 00 00       	call   f0103137 <cprintf>
f0100b62:	83 c4 10             	add    $0x10,%esp
f0100b65:	e9 4f ff ff ff       	jmp    f0100ab9 <monitor+0xb6>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b6a:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100b6f:	83 ec 04             	sub    $0x4,%esp
f0100b72:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b75:	ff 75 08             	pushl  0x8(%ebp)
f0100b78:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b7b:	52                   	push   %edx
f0100b7c:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100b7f:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100b86:	83 c4 10             	add    $0x10,%esp
f0100b89:	85 c0                	test   %eax,%eax
f0100b8b:	0f 89 28 ff ff ff    	jns    f0100ab9 <monitor+0xb6>
				break;
	}
}
f0100b91:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b94:	5b                   	pop    %ebx
f0100b95:	5e                   	pop    %esi
f0100b96:	5f                   	pop    %edi
f0100b97:	5d                   	pop    %ebp
f0100b98:	c3                   	ret    

f0100b99 <boot_alloc>:
// anything.
//
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *boot_alloc(uint32_t n) {
f0100b99:	55                   	push   %ebp
f0100b9a:	89 e5                	mov    %esp,%ebp
f0100b9c:	56                   	push   %esi
f0100b9d:	53                   	push   %ebx
f0100b9e:	e8 12 f6 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0100ba3:	81 c3 65 67 01 00    	add    $0x16765,%ebx
f0100ba9:	89 c6                	mov    %eax,%esi
  // Initialize nextfree if this is the first time.
  // 'end' is a magic symbol automatically generated by the linker,
  // which points to the end of the kernel's bss segment:
  // the first virtual address that the linker did *not* assign
  // to any kernel code or global variables.
  if (!nextfree) {
f0100bab:	83 bb 90 1f 00 00 00 	cmpl   $0x0,0x1f90(%ebx)
f0100bb2:	74 4b                	je     f0100bff <boot_alloc+0x66>
  // Allocate a chunk large enough to hold 'n' bytes, then update
  // nextfree.  Make sure nextfree is kept aligned
  // to a multiple of PGSIZE.
  //
  // LAB 2: Your code here.
  cprintf("boot_alloc memory at %x\n", nextfree);
f0100bb4:	83 ec 08             	sub    $0x8,%esp
f0100bb7:	ff b3 90 1f 00 00    	pushl  0x1f90(%ebx)
f0100bbd:	8d 83 f1 d3 fe ff    	lea    -0x12c0f(%ebx),%eax
f0100bc3:	50                   	push   %eax
f0100bc4:	e8 6e 25 00 00       	call   f0103137 <cprintf>
  cprintf("Next memory at %x\n", ROUNDUP((char *)(nextfree + n), PGSIZE));
f0100bc9:	83 c4 08             	add    $0x8,%esp
f0100bcc:	89 f0                	mov    %esi,%eax
f0100bce:	03 83 90 1f 00 00    	add    0x1f90(%ebx),%eax
f0100bd4:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100bd9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bde:	50                   	push   %eax
f0100bdf:	8d 83 0a d4 fe ff    	lea    -0x12bf6(%ebx),%eax
f0100be5:	50                   	push   %eax
f0100be6:	e8 4c 25 00 00       	call   f0103137 <cprintf>
  if (n != 0) {
f0100beb:	83 c4 10             	add    $0x10,%esp
f0100bee:	85 f6                	test   %esi,%esi
f0100bf0:	75 25                	jne    f0100c17 <boot_alloc+0x7e>
    char *next = nextfree;
    nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
    return next;
  } else
    return nextfree;
f0100bf2:	8b 83 90 1f 00 00    	mov    0x1f90(%ebx),%eax

  return NULL;
}
f0100bf8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100bfb:	5b                   	pop    %ebx
f0100bfc:	5e                   	pop    %esi
f0100bfd:	5d                   	pop    %ebp
f0100bfe:	c3                   	ret    
    nextfree = ROUNDUP((char *)end, PGSIZE);
f0100bff:	c7 c0 c0 96 11 f0    	mov    $0xf01196c0,%eax
f0100c05:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100c0a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c0f:	89 83 90 1f 00 00    	mov    %eax,0x1f90(%ebx)
f0100c15:	eb 9d                	jmp    f0100bb4 <boot_alloc+0x1b>
    char *next = nextfree;
f0100c17:	8b 83 90 1f 00 00    	mov    0x1f90(%ebx),%eax
    nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
f0100c1d:	8d 94 30 ff 0f 00 00 	lea    0xfff(%eax,%esi,1),%edx
f0100c24:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c2a:	89 93 90 1f 00 00    	mov    %edx,0x1f90(%ebx)
    return next;
f0100c30:	eb c6                	jmp    f0100bf8 <boot_alloc+0x5f>

f0100c32 <check_va2pa>:
// This function returns the physical address of the page containing 'va',
// defined by the page directory 'pgdir'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t check_va2pa(pde_t *pgdir, uintptr_t va) {
f0100c32:	55                   	push   %ebp
f0100c33:	89 e5                	mov    %esp,%ebp
f0100c35:	56                   	push   %esi
f0100c36:	53                   	push   %ebx
f0100c37:	e8 68 24 00 00       	call   f01030a4 <__x86.get_pc_thunk.cx>
f0100c3c:	81 c1 cc 66 01 00    	add    $0x166cc,%ecx
  pte_t *p;

  pgdir = &pgdir[PDX(va)];
f0100c42:	89 d3                	mov    %edx,%ebx
f0100c44:	c1 eb 16             	shr    $0x16,%ebx
  if (!(*pgdir & PTE_P))
f0100c47:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100c4a:	a8 01                	test   $0x1,%al
f0100c4c:	74 5a                	je     f0100ca8 <check_va2pa+0x76>
    return ~0;
  p = (pte_t *)KADDR(PTE_ADDR(*pgdir));
f0100c4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

/* This macro takes a physical address and returns the corresponding kernel
 * virtual address.  It panics if you pass an invalid physical address. */
static inline void *_kaddr(const char *file, int line, physaddr_t pa) {
  if (PGNUM(pa) >= npages)
f0100c53:	89 c6                	mov    %eax,%esi
f0100c55:	c1 ee 0c             	shr    $0xc,%esi
f0100c58:	c7 c3 cc 96 11 f0    	mov    $0xf01196cc,%ebx
f0100c5e:	3b 33                	cmp    (%ebx),%esi
f0100c60:	73 2b                	jae    f0100c8d <check_va2pa+0x5b>
  if (!(p[PTX(va)] & PTE_P))
f0100c62:	c1 ea 0c             	shr    $0xc,%edx
f0100c65:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c6b:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c72:	89 c2                	mov    %eax,%edx
f0100c74:	83 e2 01             	and    $0x1,%edx
    return ~0;
  return PTE_ADDR(p[PTX(va)]);
f0100c77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c7c:	85 d2                	test   %edx,%edx
f0100c7e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100c83:	0f 44 c2             	cmove  %edx,%eax
}
f0100c86:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c89:	5b                   	pop    %ebx
f0100c8a:	5e                   	pop    %esi
f0100c8b:	5d                   	pop    %ebp
f0100c8c:	c3                   	ret    
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c8d:	50                   	push   %eax
f0100c8e:	8d 81 4c d7 fe ff    	lea    -0x128b4(%ecx),%eax
f0100c94:	50                   	push   %eax
f0100c95:	68 a8 02 00 00       	push   $0x2a8
f0100c9a:	8d 81 1d d4 fe ff    	lea    -0x12be3(%ecx),%eax
f0100ca0:	50                   	push   %eax
f0100ca1:	89 cb                	mov    %ecx,%ebx
f0100ca3:	e8 57 f4 ff ff       	call   f01000ff <_panic>
    return ~0;
f0100ca8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cad:	eb d7                	jmp    f0100c86 <check_va2pa+0x54>

f0100caf <check_page_free_list>:
static void check_page_free_list(bool only_low_memory) {
f0100caf:	55                   	push   %ebp
f0100cb0:	89 e5                	mov    %esp,%ebp
f0100cb2:	57                   	push   %edi
f0100cb3:	56                   	push   %esi
f0100cb4:	53                   	push   %ebx
f0100cb5:	83 ec 3c             	sub    $0x3c,%esp
f0100cb8:	e8 ef 23 00 00       	call   f01030ac <__x86.get_pc_thunk.di>
f0100cbd:	81 c7 4b 66 01 00    	add    $0x1664b,%edi
f0100cc3:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cc6:	84 c0                	test   %al,%al
f0100cc8:	0f 85 dd 02 00 00    	jne    f0100fab <check_page_free_list+0x2fc>
  if (!page_free_list)
f0100cce:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100cd1:	83 b8 94 1f 00 00 00 	cmpl   $0x0,0x1f94(%eax)
f0100cd8:	74 0c                	je     f0100ce6 <check_page_free_list+0x37>
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cda:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0100ce1:	e9 2f 03 00 00       	jmp    f0101015 <check_page_free_list+0x366>
    panic("'page_free_list' is a null pointer!");
f0100ce6:	83 ec 04             	sub    $0x4,%esp
f0100ce9:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cec:	8d 83 70 d7 fe ff    	lea    -0x12890(%ebx),%eax
f0100cf2:	50                   	push   %eax
f0100cf3:	68 f0 01 00 00       	push   $0x1f0
f0100cf8:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0100cfe:	50                   	push   %eax
f0100cff:	e8 fb f3 ff ff       	call   f01000ff <_panic>
f0100d04:	50                   	push   %eax
f0100d05:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d08:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f0100d0e:	50                   	push   %eax
f0100d0f:	6a 3f                	push   $0x3f
f0100d11:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f0100d17:	50                   	push   %eax
f0100d18:	e8 e2 f3 ff ff       	call   f01000ff <_panic>
  for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d1d:	8b 36                	mov    (%esi),%esi
f0100d1f:	85 f6                	test   %esi,%esi
f0100d21:	74 40                	je     f0100d63 <check_page_free_list+0xb4>
void page_decref(struct PageInfo *pp);

void tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t page2pa(struct PageInfo *pp) {
  return (pp - pages) << PGSHIFT;
f0100d23:	89 f0                	mov    %esi,%eax
f0100d25:	2b 07                	sub    (%edi),%eax
f0100d27:	c1 f8 03             	sar    $0x3,%eax
f0100d2a:	c1 e0 0c             	shl    $0xc,%eax
    if (PDX(page2pa(pp)) < pdx_limit)
f0100d2d:	89 c2                	mov    %eax,%edx
f0100d2f:	c1 ea 16             	shr    $0x16,%edx
f0100d32:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d35:	73 e6                	jae    f0100d1d <check_page_free_list+0x6e>
  if (PGNUM(pa) >= npages)
f0100d37:	89 c2                	mov    %eax,%edx
f0100d39:	c1 ea 0c             	shr    $0xc,%edx
f0100d3c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100d3f:	3b 11                	cmp    (%ecx),%edx
f0100d41:	73 c1                	jae    f0100d04 <check_page_free_list+0x55>
      memset(page2kva(pp), 0x97, 128);
f0100d43:	83 ec 04             	sub    $0x4,%esp
f0100d46:	68 80 00 00 00       	push   $0x80
f0100d4b:	68 97 00 00 00       	push   $0x97
  return (void *)(pa + KERNBASE);
f0100d50:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d55:	50                   	push   %eax
f0100d56:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d59:	e8 43 30 00 00       	call   f0103da1 <memset>
f0100d5e:	83 c4 10             	add    $0x10,%esp
f0100d61:	eb ba                	jmp    f0100d1d <check_page_free_list+0x6e>
  first_free_page = (char *)boot_alloc(0);
f0100d63:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d68:	e8 2c fe ff ff       	call   f0100b99 <boot_alloc>
f0100d6d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d70:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100d73:	8b 97 94 1f 00 00    	mov    0x1f94(%edi),%edx
    assert(pp >= pages);
f0100d79:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0100d7f:	8b 08                	mov    (%eax),%ecx
    assert(pp < pages + npages);
f0100d81:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0100d87:	8b 00                	mov    (%eax),%eax
f0100d89:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100d8c:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100d8f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  int nfree_basemem = 0, nfree_extmem = 0;
f0100d92:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d97:	89 75 d0             	mov    %esi,-0x30(%ebp)
  for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d9a:	e9 08 01 00 00       	jmp    f0100ea7 <check_page_free_list+0x1f8>
    assert(pp >= pages);
f0100d9f:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100da2:	8d 83 37 d4 fe ff    	lea    -0x12bc9(%ebx),%eax
f0100da8:	50                   	push   %eax
f0100da9:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0100daf:	50                   	push   %eax
f0100db0:	68 0a 02 00 00       	push   $0x20a
f0100db5:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0100dbb:	50                   	push   %eax
f0100dbc:	e8 3e f3 ff ff       	call   f01000ff <_panic>
    assert(pp < pages + npages);
f0100dc1:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dc4:	8d 83 58 d4 fe ff    	lea    -0x12ba8(%ebx),%eax
f0100dca:	50                   	push   %eax
f0100dcb:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0100dd1:	50                   	push   %eax
f0100dd2:	68 0b 02 00 00       	push   $0x20b
f0100dd7:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0100ddd:	50                   	push   %eax
f0100dde:	e8 1c f3 ff ff       	call   f01000ff <_panic>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100de3:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100de6:	8d 83 94 d7 fe ff    	lea    -0x1286c(%ebx),%eax
f0100dec:	50                   	push   %eax
f0100ded:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0100df3:	50                   	push   %eax
f0100df4:	68 0c 02 00 00       	push   $0x20c
f0100df9:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0100dff:	50                   	push   %eax
f0100e00:	e8 fa f2 ff ff       	call   f01000ff <_panic>
    assert(page2pa(pp) != 0);
f0100e05:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e08:	8d 83 6c d4 fe ff    	lea    -0x12b94(%ebx),%eax
f0100e0e:	50                   	push   %eax
f0100e0f:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0100e15:	50                   	push   %eax
f0100e16:	68 0f 02 00 00       	push   $0x20f
f0100e1b:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0100e21:	50                   	push   %eax
f0100e22:	e8 d8 f2 ff ff       	call   f01000ff <_panic>
    assert(page2pa(pp) != IOPHYSMEM);
f0100e27:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e2a:	8d 83 7d d4 fe ff    	lea    -0x12b83(%ebx),%eax
f0100e30:	50                   	push   %eax
f0100e31:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0100e37:	50                   	push   %eax
f0100e38:	68 10 02 00 00       	push   $0x210
f0100e3d:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0100e43:	50                   	push   %eax
f0100e44:	e8 b6 f2 ff ff       	call   f01000ff <_panic>
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e49:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e4c:	8d 83 c4 d7 fe ff    	lea    -0x1283c(%ebx),%eax
f0100e52:	50                   	push   %eax
f0100e53:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0100e59:	50                   	push   %eax
f0100e5a:	68 11 02 00 00       	push   $0x211
f0100e5f:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0100e65:	50                   	push   %eax
f0100e66:	e8 94 f2 ff ff       	call   f01000ff <_panic>
    assert(page2pa(pp) != EXTPHYSMEM);
f0100e6b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e6e:	8d 83 96 d4 fe ff    	lea    -0x12b6a(%ebx),%eax
f0100e74:	50                   	push   %eax
f0100e75:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0100e7b:	50                   	push   %eax
f0100e7c:	68 12 02 00 00       	push   $0x212
f0100e81:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0100e87:	50                   	push   %eax
f0100e88:	e8 72 f2 ff ff       	call   f01000ff <_panic>
  if (PGNUM(pa) >= npages)
f0100e8d:	89 c6                	mov    %eax,%esi
f0100e8f:	c1 ee 0c             	shr    $0xc,%esi
f0100e92:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0100e95:	76 70                	jbe    f0100f07 <check_page_free_list+0x258>
  return (void *)(pa + KERNBASE);
f0100e97:	2d 00 00 00 10       	sub    $0x10000000,%eax
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100e9c:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100e9f:	77 7f                	ja     f0100f20 <check_page_free_list+0x271>
      ++nfree_extmem;
f0100ea1:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
  for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ea5:	8b 12                	mov    (%edx),%edx
f0100ea7:	85 d2                	test   %edx,%edx
f0100ea9:	0f 84 93 00 00 00    	je     f0100f42 <check_page_free_list+0x293>
    assert(pp >= pages);
f0100eaf:	39 d1                	cmp    %edx,%ecx
f0100eb1:	0f 87 e8 fe ff ff    	ja     f0100d9f <check_page_free_list+0xf0>
    assert(pp < pages + npages);
f0100eb7:	39 d3                	cmp    %edx,%ebx
f0100eb9:	0f 86 02 ff ff ff    	jbe    f0100dc1 <check_page_free_list+0x112>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100ebf:	89 d0                	mov    %edx,%eax
f0100ec1:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100ec4:	a8 07                	test   $0x7,%al
f0100ec6:	0f 85 17 ff ff ff    	jne    f0100de3 <check_page_free_list+0x134>
  return (pp - pages) << PGSHIFT;
f0100ecc:	c1 f8 03             	sar    $0x3,%eax
f0100ecf:	c1 e0 0c             	shl    $0xc,%eax
    assert(page2pa(pp) != 0);
f0100ed2:	85 c0                	test   %eax,%eax
f0100ed4:	0f 84 2b ff ff ff    	je     f0100e05 <check_page_free_list+0x156>
    assert(page2pa(pp) != IOPHYSMEM);
f0100eda:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100edf:	0f 84 42 ff ff ff    	je     f0100e27 <check_page_free_list+0x178>
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ee5:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100eea:	0f 84 59 ff ff ff    	je     f0100e49 <check_page_free_list+0x19a>
    assert(page2pa(pp) != EXTPHYSMEM);
f0100ef0:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ef5:	0f 84 70 ff ff ff    	je     f0100e6b <check_page_free_list+0x1bc>
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100efb:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100f00:	77 8b                	ja     f0100e8d <check_page_free_list+0x1de>
      ++nfree_basemem;
f0100f02:	83 c7 01             	add    $0x1,%edi
f0100f05:	eb 9e                	jmp    f0100ea5 <check_page_free_list+0x1f6>
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f07:	50                   	push   %eax
f0100f08:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f0b:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f0100f11:	50                   	push   %eax
f0100f12:	6a 3f                	push   $0x3f
f0100f14:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f0100f1a:	50                   	push   %eax
f0100f1b:	e8 df f1 ff ff       	call   f01000ff <_panic>
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100f20:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f23:	8d 83 e8 d7 fe ff    	lea    -0x12818(%ebx),%eax
f0100f29:	50                   	push   %eax
f0100f2a:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0100f30:	50                   	push   %eax
f0100f31:	68 13 02 00 00       	push   $0x213
f0100f36:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0100f3c:	50                   	push   %eax
f0100f3d:	e8 bd f1 ff ff       	call   f01000ff <_panic>
f0100f42:	8b 75 d0             	mov    -0x30(%ebp),%esi
  assert(nfree_basemem > 0);
f0100f45:	85 ff                	test   %edi,%edi
f0100f47:	7e 1e                	jle    f0100f67 <check_page_free_list+0x2b8>
  assert(nfree_extmem > 0);
f0100f49:	85 f6                	test   %esi,%esi
f0100f4b:	7e 3c                	jle    f0100f89 <check_page_free_list+0x2da>
  cprintf("check_page_free_list done\n");
f0100f4d:	83 ec 0c             	sub    $0xc,%esp
f0100f50:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f53:	8d 83 d3 d4 fe ff    	lea    -0x12b2d(%ebx),%eax
f0100f59:	50                   	push   %eax
f0100f5a:	e8 d8 21 00 00       	call   f0103137 <cprintf>
}
f0100f5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f62:	5b                   	pop    %ebx
f0100f63:	5e                   	pop    %esi
f0100f64:	5f                   	pop    %edi
f0100f65:	5d                   	pop    %ebp
f0100f66:	c3                   	ret    
  assert(nfree_basemem > 0);
f0100f67:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f6a:	8d 83 b0 d4 fe ff    	lea    -0x12b50(%ebx),%eax
f0100f70:	50                   	push   %eax
f0100f71:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0100f77:	50                   	push   %eax
f0100f78:	68 1b 02 00 00       	push   $0x21b
f0100f7d:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0100f83:	50                   	push   %eax
f0100f84:	e8 76 f1 ff ff       	call   f01000ff <_panic>
  assert(nfree_extmem > 0);
f0100f89:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f8c:	8d 83 c2 d4 fe ff    	lea    -0x12b3e(%ebx),%eax
f0100f92:	50                   	push   %eax
f0100f93:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0100f99:	50                   	push   %eax
f0100f9a:	68 1c 02 00 00       	push   $0x21c
f0100f9f:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0100fa5:	50                   	push   %eax
f0100fa6:	e8 54 f1 ff ff       	call   f01000ff <_panic>
  if (!page_free_list)
f0100fab:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100fae:	8b 80 94 1f 00 00    	mov    0x1f94(%eax),%eax
f0100fb4:	85 c0                	test   %eax,%eax
f0100fb6:	0f 84 2a fd ff ff    	je     f0100ce6 <check_page_free_list+0x37>
    struct PageInfo **tp[2] = {&pp1, &pp2};
f0100fbc:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100fbf:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100fc2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100fc5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  return (pp - pages) << PGSHIFT;
f0100fc8:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100fcb:	c7 c3 d4 96 11 f0    	mov    $0xf01196d4,%ebx
f0100fd1:	89 c2                	mov    %eax,%edx
f0100fd3:	2b 13                	sub    (%ebx),%edx
      int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100fd5:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100fdb:	0f 95 c2             	setne  %dl
f0100fde:	0f b6 d2             	movzbl %dl,%edx
      *tp[pagetype] = pp;
f0100fe1:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100fe5:	89 01                	mov    %eax,(%ecx)
      tp[pagetype] = &pp->pp_link;
f0100fe7:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
    for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100feb:	8b 00                	mov    (%eax),%eax
f0100fed:	85 c0                	test   %eax,%eax
f0100fef:	75 e0                	jne    f0100fd1 <check_page_free_list+0x322>
    *tp[1] = 0;
f0100ff1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ff4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    *tp[0] = pp2;
f0100ffa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ffd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101000:	89 10                	mov    %edx,(%eax)
    page_free_list = pp1;
f0101002:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101005:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0101008:	89 87 94 1f 00 00    	mov    %eax,0x1f94(%edi)
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010100e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  for (pp = page_free_list; pp; pp = pp->pp_link)
f0101015:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0101018:	8b b0 94 1f 00 00    	mov    0x1f94(%eax),%esi
f010101e:	c7 c7 d4 96 11 f0    	mov    $0xf01196d4,%edi
  if (PGNUM(pa) >= npages)
f0101024:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f010102a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010102d:	e9 ed fc ff ff       	jmp    f0100d1f <check_page_free_list+0x70>

f0101032 <page_init>:
void page_init(void) {
f0101032:	55                   	push   %ebp
f0101033:	89 e5                	mov    %esp,%ebp
f0101035:	57                   	push   %edi
f0101036:	56                   	push   %esi
f0101037:	53                   	push   %ebx
f0101038:	83 ec 1c             	sub    $0x1c,%esp
f010103b:	e8 68 20 00 00       	call   f01030a8 <__x86.get_pc_thunk.si>
f0101040:	81 c6 c8 62 01 00    	add    $0x162c8,%esi
f0101046:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  for (i = 1; i < npages_basemem; i++) {
f0101049:	8b be 98 1f 00 00    	mov    0x1f98(%esi),%edi
f010104f:	8b 9e 94 1f 00 00    	mov    0x1f94(%esi),%ebx
f0101055:	ba 00 00 00 00       	mov    $0x0,%edx
f010105a:	b8 01 00 00 00       	mov    $0x1,%eax
    pages[i].pp_ref = 0;
f010105f:	c7 c6 d4 96 11 f0    	mov    $0xf01196d4,%esi
  for (i = 1; i < npages_basemem; i++) {
f0101065:	eb 1f                	jmp    f0101086 <page_init+0x54>
    pages[i].pp_ref = 0;
f0101067:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010106e:	89 d1                	mov    %edx,%ecx
f0101070:	03 0e                	add    (%esi),%ecx
f0101072:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
    pages[i].pp_link = page_free_list;
f0101078:	89 19                	mov    %ebx,(%ecx)
  for (i = 1; i < npages_basemem; i++) {
f010107a:	83 c0 01             	add    $0x1,%eax
    page_free_list = &pages[i];
f010107d:	89 d3                	mov    %edx,%ebx
f010107f:	03 1e                	add    (%esi),%ebx
f0101081:	ba 01 00 00 00       	mov    $0x1,%edx
  for (i = 1; i < npages_basemem; i++) {
f0101086:	39 c7                	cmp    %eax,%edi
f0101088:	77 dd                	ja     f0101067 <page_init+0x35>
f010108a:	84 d2                	test   %dl,%dl
f010108c:	75 7e                	jne    f010110c <page_init+0xda>
  int med = (int)ROUNDUP(((char *)pages) + (sizeof(struct PageInfo) * npages) -
f010108e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101091:	c7 c6 d4 96 11 f0    	mov    $0xf01196d4,%esi
f0101097:	c7 c7 cc 96 11 f0    	mov    $0xf01196cc,%edi
f010109d:	8b 17                	mov    (%edi),%edx
f010109f:	8b 06                	mov    (%esi),%eax
f01010a1:	8d 84 d0 ff 0f 00 10 	lea    0x10000fff(%eax,%edx,8),%eax
f01010a8:	c1 f8 0c             	sar    $0xc,%eax
f01010ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  cprintf("pageinfo size: %d\n", sizeof(struct PageInfo));
f01010ae:	83 ec 08             	sub    $0x8,%esp
f01010b1:	6a 08                	push   $0x8
f01010b3:	8d 83 ee d4 fe ff    	lea    -0x12b12(%ebx),%eax
f01010b9:	50                   	push   %eax
f01010ba:	e8 78 20 00 00       	call   f0103137 <cprintf>
  cprintf("%x\n", ((char *)pages) + (sizeof(struct PageInfo) * npages));
f01010bf:	83 c4 08             	add    $0x8,%esp
f01010c2:	8b 17                	mov    (%edi),%edx
f01010c4:	8b 06                	mov    (%esi),%eax
f01010c6:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01010c9:	50                   	push   %eax
f01010ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01010cd:	8d 87 17 d7 fe ff    	lea    -0x128e9(%edi),%eax
f01010d3:	50                   	push   %eax
f01010d4:	89 fb                	mov    %edi,%ebx
f01010d6:	e8 5c 20 00 00       	call   f0103137 <cprintf>
  cprintf("med=%d\n", med);
f01010db:	83 c4 08             	add    $0x8,%esp
f01010de:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01010e1:	56                   	push   %esi
f01010e2:	8d 87 01 d5 fe ff    	lea    -0x12aff(%edi),%eax
f01010e8:	50                   	push   %eax
f01010e9:	e8 49 20 00 00       	call   f0103137 <cprintf>
  for (i = med; i < npages; i++) {
f01010ee:	89 f0                	mov    %esi,%eax
f01010f0:	8b b7 94 1f 00 00    	mov    0x1f94(%edi),%esi
f01010f6:	83 c4 10             	add    $0x10,%esp
f01010f9:	ba 00 00 00 00       	mov    $0x0,%edx
f01010fe:	c7 c3 cc 96 11 f0    	mov    $0xf01196cc,%ebx
    pages[i].pp_ref = 0;
f0101104:	c7 c7 d4 96 11 f0    	mov    $0xf01196d4,%edi
  for (i = med; i < npages; i++) {
f010110a:	eb 2d                	jmp    f0101139 <page_init+0x107>
f010110c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010110f:	89 98 94 1f 00 00    	mov    %ebx,0x1f94(%eax)
f0101115:	e9 74 ff ff ff       	jmp    f010108e <page_init+0x5c>
f010111a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    pages[i].pp_ref = 0;
f0101121:	89 d1                	mov    %edx,%ecx
f0101123:	03 0f                	add    (%edi),%ecx
f0101125:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
    pages[i].pp_link = page_free_list;
f010112b:	89 31                	mov    %esi,(%ecx)
  for (i = med; i < npages; i++) {
f010112d:	83 c0 01             	add    $0x1,%eax
    page_free_list = &pages[i];
f0101130:	89 d6                	mov    %edx,%esi
f0101132:	03 37                	add    (%edi),%esi
f0101134:	ba 01 00 00 00       	mov    $0x1,%edx
  for (i = med; i < npages; i++) {
f0101139:	39 03                	cmp    %eax,(%ebx)
f010113b:	77 dd                	ja     f010111a <page_init+0xe8>
f010113d:	84 d2                	test   %dl,%dl
f010113f:	75 08                	jne    f0101149 <page_init+0x117>
}
f0101141:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101144:	5b                   	pop    %ebx
f0101145:	5e                   	pop    %esi
f0101146:	5f                   	pop    %edi
f0101147:	5d                   	pop    %ebp
f0101148:	c3                   	ret    
f0101149:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010114c:	89 b0 94 1f 00 00    	mov    %esi,0x1f94(%eax)
f0101152:	eb ed                	jmp    f0101141 <page_init+0x10f>

f0101154 <page_alloc>:
struct PageInfo *page_alloc(int alloc_flags) {
f0101154:	55                   	push   %ebp
f0101155:	89 e5                	mov    %esp,%ebp
f0101157:	56                   	push   %esi
f0101158:	53                   	push   %ebx
f0101159:	e8 57 f0 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010115e:	81 c3 aa 61 01 00    	add    $0x161aa,%ebx
  if (page_free_list) {
f0101164:	8b b3 94 1f 00 00    	mov    0x1f94(%ebx),%esi
f010116a:	85 f6                	test   %esi,%esi
f010116c:	74 0e                	je     f010117c <page_alloc+0x28>
    page_free_list = page_free_list->pp_link;
f010116e:	8b 06                	mov    (%esi),%eax
f0101170:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
    if (alloc_flags & ALLOC_ZERO)
f0101176:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010117a:	75 09                	jne    f0101185 <page_alloc+0x31>
}
f010117c:	89 f0                	mov    %esi,%eax
f010117e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101181:	5b                   	pop    %ebx
f0101182:	5e                   	pop    %esi
f0101183:	5d                   	pop    %ebp
f0101184:	c3                   	ret    
  return (pp - pages) << PGSHIFT;
f0101185:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f010118b:	89 f2                	mov    %esi,%edx
f010118d:	2b 10                	sub    (%eax),%edx
f010118f:	89 d0                	mov    %edx,%eax
f0101191:	c1 f8 03             	sar    $0x3,%eax
f0101194:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f0101197:	89 c1                	mov    %eax,%ecx
f0101199:	c1 e9 0c             	shr    $0xc,%ecx
f010119c:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f01011a2:	3b 0a                	cmp    (%edx),%ecx
f01011a4:	73 1a                	jae    f01011c0 <page_alloc+0x6c>
      memset(page2kva(ret), 0, PGSIZE);
f01011a6:	83 ec 04             	sub    $0x4,%esp
f01011a9:	68 00 10 00 00       	push   $0x1000
f01011ae:	6a 00                	push   $0x0
  return (void *)(pa + KERNBASE);
f01011b0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01011b5:	50                   	push   %eax
f01011b6:	e8 e6 2b 00 00       	call   f0103da1 <memset>
f01011bb:	83 c4 10             	add    $0x10,%esp
f01011be:	eb bc                	jmp    f010117c <page_alloc+0x28>
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011c0:	50                   	push   %eax
f01011c1:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f01011c7:	50                   	push   %eax
f01011c8:	6a 3f                	push   $0x3f
f01011ca:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f01011d0:	50                   	push   %eax
f01011d1:	e8 29 ef ff ff       	call   f01000ff <_panic>

f01011d6 <page_free>:
void page_free(struct PageInfo *pp) {
f01011d6:	55                   	push   %ebp
f01011d7:	89 e5                	mov    %esp,%ebp
f01011d9:	e8 8b f5 ff ff       	call   f0100769 <__x86.get_pc_thunk.ax>
f01011de:	05 2a 61 01 00       	add    $0x1612a,%eax
f01011e3:	8b 55 08             	mov    0x8(%ebp),%edx
  pp->pp_link = page_free_list;
f01011e6:	8b 88 94 1f 00 00    	mov    0x1f94(%eax),%ecx
f01011ec:	89 0a                	mov    %ecx,(%edx)
  page_free_list = pp;
f01011ee:	89 90 94 1f 00 00    	mov    %edx,0x1f94(%eax)
}
f01011f4:	5d                   	pop    %ebp
f01011f5:	c3                   	ret    

f01011f6 <page_decref>:
void page_decref(struct PageInfo *pp) {
f01011f6:	55                   	push   %ebp
f01011f7:	89 e5                	mov    %esp,%ebp
f01011f9:	8b 55 08             	mov    0x8(%ebp),%edx
  if (--pp->pp_ref == 0)
f01011fc:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101200:	83 e8 01             	sub    $0x1,%eax
f0101203:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101207:	66 85 c0             	test   %ax,%ax
f010120a:	74 02                	je     f010120e <page_decref+0x18>
}
f010120c:	c9                   	leave  
f010120d:	c3                   	ret    
    page_free(pp);
f010120e:	52                   	push   %edx
f010120f:	e8 c2 ff ff ff       	call   f01011d6 <page_free>
f0101214:	83 c4 04             	add    $0x4,%esp
}
f0101217:	eb f3                	jmp    f010120c <page_decref+0x16>

f0101219 <pgdir_walk>:
pte_t *pgdir_walk(pde_t *pgdir, const void *va, int create) {
f0101219:	55                   	push   %ebp
f010121a:	89 e5                	mov    %esp,%ebp
f010121c:	57                   	push   %edi
f010121d:	56                   	push   %esi
f010121e:	53                   	push   %ebx
f010121f:	83 ec 0c             	sub    $0xc,%esp
f0101222:	e8 8e ef ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0101227:	81 c3 e1 60 01 00    	add    $0x160e1,%ebx
f010122d:	8b 75 0c             	mov    0xc(%ebp),%esi
  int dindex = PDX(va), tindex = PTX(va);
f0101230:	89 f7                	mov    %esi,%edi
f0101232:	c1 ef 0c             	shr    $0xc,%edi
f0101235:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
f010123b:	c1 ee 16             	shr    $0x16,%esi
  if (!(pgdir[dindex] & PTE_P)) { // if pde not exist
f010123e:	c1 e6 02             	shl    $0x2,%esi
f0101241:	03 75 08             	add    0x8(%ebp),%esi
f0101244:	f6 06 01             	testb  $0x1,(%esi)
f0101247:	75 2f                	jne    f0101278 <pgdir_walk+0x5f>
    if (create) {
f0101249:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010124d:	74 67                	je     f01012b6 <pgdir_walk+0x9d>
      struct PageInfo *pg = page_alloc(ALLOC_ZERO); // alloc a zero page
f010124f:	83 ec 0c             	sub    $0xc,%esp
f0101252:	6a 01                	push   $0x1
f0101254:	e8 fb fe ff ff       	call   f0101154 <page_alloc>
      if (!pg)
f0101259:	83 c4 10             	add    $0x10,%esp
f010125c:	85 c0                	test   %eax,%eax
f010125e:	74 5d                	je     f01012bd <pgdir_walk+0xa4>
      pg->pp_ref++;
f0101260:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
  return (pp - pages) << PGSHIFT;
f0101265:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f010126b:	2b 02                	sub    (%edx),%eax
f010126d:	c1 f8 03             	sar    $0x3,%eax
f0101270:	c1 e0 0c             	shl    $0xc,%eax
      pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f0101273:	83 c8 07             	or     $0x7,%eax
f0101276:	89 06                	mov    %eax,(%esi)
  pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f0101278:	8b 06                	mov    (%esi),%eax
f010127a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if (PGNUM(pa) >= npages)
f010127f:	89 c1                	mov    %eax,%ecx
f0101281:	c1 e9 0c             	shr    $0xc,%ecx
f0101284:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f010128a:	3b 0a                	cmp    (%edx),%ecx
f010128c:	73 0f                	jae    f010129d <pgdir_walk+0x84>
  return p + tindex;
f010128e:	8d 84 b8 00 00 00 f0 	lea    -0x10000000(%eax,%edi,4),%eax
}
f0101295:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101298:	5b                   	pop    %ebx
f0101299:	5e                   	pop    %esi
f010129a:	5f                   	pop    %edi
f010129b:	5d                   	pop    %ebp
f010129c:	c3                   	ret    
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010129d:	50                   	push   %eax
f010129e:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f01012a4:	50                   	push   %eax
f01012a5:	68 5d 01 00 00       	push   $0x15d
f01012aa:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01012b0:	50                   	push   %eax
f01012b1:	e8 49 ee ff ff       	call   f01000ff <_panic>
      return NULL;
f01012b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01012bb:	eb d8                	jmp    f0101295 <pgdir_walk+0x7c>
        return NULL; // allocation fails
f01012bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01012c2:	eb d1                	jmp    f0101295 <pgdir_walk+0x7c>

f01012c4 <boot_map_region>:
                            physaddr_t pa, int perm) {
f01012c4:	55                   	push   %ebp
f01012c5:	89 e5                	mov    %esp,%ebp
f01012c7:	57                   	push   %edi
f01012c8:	56                   	push   %esi
f01012c9:	53                   	push   %ebx
f01012ca:	83 ec 30             	sub    $0x30,%esp
f01012cd:	e8 e3 ee ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f01012d2:	81 c3 36 60 01 00    	add    $0x16036,%ebx
f01012d8:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01012db:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01012de:	89 d6                	mov    %edx,%esi
f01012e0:	89 cf                	mov    %ecx,%edi
  cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f01012e2:	ff 75 08             	pushl  0x8(%ebp)
f01012e5:	52                   	push   %edx
f01012e6:	8d 83 2c d8 fe ff    	lea    -0x127d4(%ebx),%eax
f01012ec:	50                   	push   %eax
f01012ed:	e8 45 1e 00 00       	call   f0103137 <cprintf>
  for (i = 0; i < size / PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01012f2:	c1 ef 0c             	shr    $0xc,%edi
f01012f5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01012f8:	83 c4 10             	add    $0x10,%esp
f01012fb:	89 f3                	mov    %esi,%ebx
f01012fd:	bf 00 00 00 00       	mov    $0x0,%edi
f0101302:	8b 45 08             	mov    0x8(%ebp),%eax
f0101305:	29 f0                	sub    %esi,%eax
f0101307:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *pte = pa | perm | PTE_P;
f010130a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010130d:	83 c8 01             	or     $0x1,%eax
f0101310:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101313:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101316:	8d 34 18             	lea    (%eax,%ebx,1),%esi
  for (i = 0; i < size / PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101319:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f010131c:	74 43                	je     f0101361 <boot_map_region+0x9d>
    pte_t *pte = pgdir_walk(pgdir, (void *)va, 1); // create
f010131e:	83 ec 04             	sub    $0x4,%esp
f0101321:	6a 01                	push   $0x1
f0101323:	53                   	push   %ebx
f0101324:	ff 75 dc             	pushl  -0x24(%ebp)
f0101327:	e8 ed fe ff ff       	call   f0101219 <pgdir_walk>
    if (!pte)
f010132c:	83 c4 10             	add    $0x10,%esp
f010132f:	85 c0                	test   %eax,%eax
f0101331:	74 10                	je     f0101343 <boot_map_region+0x7f>
    *pte = pa | perm | PTE_P;
f0101333:	0b 75 d8             	or     -0x28(%ebp),%esi
f0101336:	89 30                	mov    %esi,(%eax)
  for (i = 0; i < size / PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101338:	83 c7 01             	add    $0x1,%edi
f010133b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101341:	eb d0                	jmp    f0101313 <boot_map_region+0x4f>
      panic("boot_map_region panic, out of memory");
f0101343:	83 ec 04             	sub    $0x4,%esp
f0101346:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101349:	8d 83 60 d8 fe ff    	lea    -0x127a0(%ebx),%eax
f010134f:	50                   	push   %eax
f0101350:	68 7a 01 00 00       	push   $0x17a
f0101355:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f010135b:	50                   	push   %eax
f010135c:	e8 9e ed ff ff       	call   f01000ff <_panic>
  cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f0101361:	83 ec 04             	sub    $0x4,%esp
f0101364:	56                   	push   %esi
f0101365:	53                   	push   %ebx
f0101366:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101369:	8d 83 2c d8 fe ff    	lea    -0x127d4(%ebx),%eax
f010136f:	50                   	push   %eax
f0101370:	e8 c2 1d 00 00       	call   f0103137 <cprintf>
}
f0101375:	83 c4 10             	add    $0x10,%esp
f0101378:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010137b:	5b                   	pop    %ebx
f010137c:	5e                   	pop    %esi
f010137d:	5f                   	pop    %edi
f010137e:	5d                   	pop    %ebp
f010137f:	c3                   	ret    

f0101380 <page_lookup>:
struct PageInfo *page_lookup(pde_t *pgdir, void *va, pte_t **pte_store) {
f0101380:	55                   	push   %ebp
f0101381:	89 e5                	mov    %esp,%ebp
f0101383:	56                   	push   %esi
f0101384:	53                   	push   %ebx
f0101385:	e8 2b ee ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010138a:	81 c3 7e 5f 01 00    	add    $0x15f7e,%ebx
f0101390:	8b 75 10             	mov    0x10(%ebp),%esi
  pte_t *pte = pgdir_walk(pgdir, va, 0); // not create
f0101393:	83 ec 04             	sub    $0x4,%esp
f0101396:	6a 00                	push   $0x0
f0101398:	ff 75 0c             	pushl  0xc(%ebp)
f010139b:	ff 75 08             	pushl  0x8(%ebp)
f010139e:	e8 76 fe ff ff       	call   f0101219 <pgdir_walk>
  if (!pte || !(*pte & PTE_P))
f01013a3:	83 c4 10             	add    $0x10,%esp
f01013a6:	85 c0                	test   %eax,%eax
f01013a8:	74 44                	je     f01013ee <page_lookup+0x6e>
f01013aa:	f6 00 01             	testb  $0x1,(%eax)
f01013ad:	74 46                	je     f01013f5 <page_lookup+0x75>
  if (pte_store)
f01013af:	85 f6                	test   %esi,%esi
f01013b1:	74 02                	je     f01013b5 <page_lookup+0x35>
    *pte_store = pte; // found and set
f01013b3:	89 06                	mov    %eax,(%esi)
f01013b5:	8b 00                	mov    (%eax),%eax
f01013b7:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo *pa2page(physaddr_t pa) {
  if (PGNUM(pa) >= npages)
f01013ba:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f01013c0:	39 02                	cmp    %eax,(%edx)
f01013c2:	76 12                	jbe    f01013d6 <page_lookup+0x56>
    panic("pa2page called with invalid pa");
  return &pages[PGNUM(pa)];
f01013c4:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f01013ca:	8b 12                	mov    (%edx),%edx
f01013cc:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01013cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01013d2:	5b                   	pop    %ebx
f01013d3:	5e                   	pop    %esi
f01013d4:	5d                   	pop    %ebp
f01013d5:	c3                   	ret    
    panic("pa2page called with invalid pa");
f01013d6:	83 ec 04             	sub    $0x4,%esp
f01013d9:	8d 83 88 d8 fe ff    	lea    -0x12778(%ebx),%eax
f01013df:	50                   	push   %eax
f01013e0:	6a 3b                	push   $0x3b
f01013e2:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f01013e8:	50                   	push   %eax
f01013e9:	e8 11 ed ff ff       	call   f01000ff <_panic>
    return NULL; // page not found
f01013ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01013f3:	eb da                	jmp    f01013cf <page_lookup+0x4f>
f01013f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01013fa:	eb d3                	jmp    f01013cf <page_lookup+0x4f>

f01013fc <page_remove>:
void page_remove(pde_t *pgdir, void *va) {
f01013fc:	55                   	push   %ebp
f01013fd:	89 e5                	mov    %esp,%ebp
f01013ff:	53                   	push   %ebx
f0101400:	83 ec 18             	sub    $0x18,%esp
f0101403:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f0101406:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101409:	50                   	push   %eax
f010140a:	53                   	push   %ebx
f010140b:	ff 75 08             	pushl  0x8(%ebp)
f010140e:	e8 6d ff ff ff       	call   f0101380 <page_lookup>
  if (!pg || !(*pte & PTE_P))
f0101413:	83 c4 10             	add    $0x10,%esp
f0101416:	85 c0                	test   %eax,%eax
f0101418:	74 08                	je     f0101422 <page_remove+0x26>
f010141a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010141d:	f6 02 01             	testb  $0x1,(%edx)
f0101420:	75 05                	jne    f0101427 <page_remove+0x2b>
}
f0101422:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101425:	c9                   	leave  
f0101426:	c3                   	ret    
  page_decref(pg);
f0101427:	83 ec 0c             	sub    $0xc,%esp
f010142a:	50                   	push   %eax
f010142b:	e8 c6 fd ff ff       	call   f01011f6 <page_decref>
  *pte = 0;
f0101430:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101433:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101439:	0f 01 3b             	invlpg (%ebx)
f010143c:	83 c4 10             	add    $0x10,%esp
f010143f:	eb e1                	jmp    f0101422 <page_remove+0x26>

f0101441 <page_insert>:
int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm) {
f0101441:	55                   	push   %ebp
f0101442:	89 e5                	mov    %esp,%ebp
f0101444:	57                   	push   %edi
f0101445:	56                   	push   %esi
f0101446:	53                   	push   %ebx
f0101447:	83 ec 10             	sub    $0x10,%esp
f010144a:	e8 5d 1c 00 00       	call   f01030ac <__x86.get_pc_thunk.di>
f010144f:	81 c7 b9 5e 01 00    	add    $0x15eb9,%edi
f0101455:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t *pte = pgdir_walk(pgdir, va, 1); // create on demand
f0101458:	6a 01                	push   $0x1
f010145a:	ff 75 10             	pushl  0x10(%ebp)
f010145d:	ff 75 08             	pushl  0x8(%ebp)
f0101460:	e8 b4 fd ff ff       	call   f0101219 <pgdir_walk>
  if (!pte)                              // page table not allocated
f0101465:	83 c4 10             	add    $0x10,%esp
f0101468:	85 c0                	test   %eax,%eax
f010146a:	74 46                	je     f01014b2 <page_insert+0x71>
f010146c:	89 c3                	mov    %eax,%ebx
  pp->pp_ref++;
f010146e:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
  if (*pte & PTE_P) // page colides, tle is invalidated in page_remove
f0101473:	f6 00 01             	testb  $0x1,(%eax)
f0101476:	75 27                	jne    f010149f <page_insert+0x5e>
  return (pp - pages) << PGSHIFT;
f0101478:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f010147e:	2b 30                	sub    (%eax),%esi
f0101480:	89 f0                	mov    %esi,%eax
f0101482:	c1 f8 03             	sar    $0x3,%eax
f0101485:	c1 e0 0c             	shl    $0xc,%eax
  *pte = page2pa(pp) | perm | PTE_P;
f0101488:	8b 55 14             	mov    0x14(%ebp),%edx
f010148b:	83 ca 01             	or     $0x1,%edx
f010148e:	09 d0                	or     %edx,%eax
f0101490:	89 03                	mov    %eax,(%ebx)
  return 0;
f0101492:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101497:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010149a:	5b                   	pop    %ebx
f010149b:	5e                   	pop    %esi
f010149c:	5f                   	pop    %edi
f010149d:	5d                   	pop    %ebp
f010149e:	c3                   	ret    
    page_remove(pgdir, va);
f010149f:	83 ec 08             	sub    $0x8,%esp
f01014a2:	ff 75 10             	pushl  0x10(%ebp)
f01014a5:	ff 75 08             	pushl  0x8(%ebp)
f01014a8:	e8 4f ff ff ff       	call   f01013fc <page_remove>
f01014ad:	83 c4 10             	add    $0x10,%esp
f01014b0:	eb c6                	jmp    f0101478 <page_insert+0x37>
    return -E_NO_MEM;
f01014b2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01014b7:	eb de                	jmp    f0101497 <page_insert+0x56>

f01014b9 <mem_init>:
void mem_init(void) {
f01014b9:	55                   	push   %ebp
f01014ba:	89 e5                	mov    %esp,%ebp
f01014bc:	57                   	push   %edi
f01014bd:	56                   	push   %esi
f01014be:	53                   	push   %ebx
f01014bf:	83 ec 48             	sub    $0x48,%esp
f01014c2:	e8 ee ec ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f01014c7:	81 c3 41 5e 01 00    	add    $0x15e41,%ebx
  return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01014cd:	6a 15                	push   $0x15
f01014cf:	e8 dc 1b 00 00       	call   f01030b0 <mc146818_read>
f01014d4:	89 c6                	mov    %eax,%esi
f01014d6:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01014dd:	e8 ce 1b 00 00       	call   f01030b0 <mc146818_read>
f01014e2:	c1 e0 08             	shl    $0x8,%eax
f01014e5:	09 f0                	or     %esi,%eax
  npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01014e7:	c1 e0 0a             	shl    $0xa,%eax
f01014ea:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01014f0:	85 c0                	test   %eax,%eax
f01014f2:	0f 48 c2             	cmovs  %edx,%eax
f01014f5:	c1 f8 0c             	sar    $0xc,%eax
f01014f8:	89 83 98 1f 00 00    	mov    %eax,0x1f98(%ebx)
  return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01014fe:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101505:	e8 a6 1b 00 00       	call   f01030b0 <mc146818_read>
f010150a:	89 c6                	mov    %eax,%esi
f010150c:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101513:	e8 98 1b 00 00       	call   f01030b0 <mc146818_read>
f0101518:	c1 e0 08             	shl    $0x8,%eax
f010151b:	09 f0                	or     %esi,%eax
  npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010151d:	c1 e0 0a             	shl    $0xa,%eax
f0101520:	89 c2                	mov    %eax,%edx
f0101522:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f0101528:	83 c4 10             	add    $0x10,%esp
f010152b:	85 d2                	test   %edx,%edx
f010152d:	0f 49 c2             	cmovns %edx,%eax
f0101530:	c1 f8 0c             	sar    $0xc,%eax
  if (npages_extmem)
f0101533:	85 c0                	test   %eax,%eax
f0101535:	0f 85 f1 00 00 00    	jne    f010162c <mem_init+0x173>
    npages = npages_basemem;
f010153b:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0101541:	8b 8b 98 1f 00 00    	mov    0x1f98(%ebx),%ecx
f0101547:	89 0a                	mov    %ecx,(%edx)
          npages_extmem * PGSIZE / 1024);
f0101549:	c1 e0 0c             	shl    $0xc,%eax
  cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010154c:	c1 e8 0a             	shr    $0xa,%eax
f010154f:	50                   	push   %eax
          npages * PGSIZE / 1024, npages_basemem * PGSIZE / 1024,
f0101550:	8b 83 98 1f 00 00    	mov    0x1f98(%ebx),%eax
f0101556:	c1 e0 0c             	shl    $0xc,%eax
  cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101559:	c1 e8 0a             	shr    $0xa,%eax
f010155c:	50                   	push   %eax
          npages * PGSIZE / 1024, npages_basemem * PGSIZE / 1024,
f010155d:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101563:	8b 00                	mov    (%eax),%eax
f0101565:	c1 e0 0c             	shl    $0xc,%eax
  cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101568:	c1 e8 0a             	shr    $0xa,%eax
f010156b:	50                   	push   %eax
f010156c:	8d 83 a8 d8 fe ff    	lea    -0x12758(%ebx),%eax
f0101572:	50                   	push   %eax
f0101573:	e8 bf 1b 00 00       	call   f0103137 <cprintf>
  kern_pgdir = (pde_t *)boot_alloc(PGSIZE);
f0101578:	b8 00 10 00 00       	mov    $0x1000,%eax
f010157d:	e8 17 f6 ff ff       	call   f0100b99 <boot_alloc>
f0101582:	c7 c6 d0 96 11 f0    	mov    $0xf01196d0,%esi
f0101588:	89 06                	mov    %eax,(%esi)
  memset(kern_pgdir, 0, PGSIZE);
f010158a:	83 c4 0c             	add    $0xc,%esp
f010158d:	68 00 10 00 00       	push   $0x1000
f0101592:	6a 00                	push   $0x0
f0101594:	50                   	push   %eax
f0101595:	e8 07 28 00 00       	call   f0103da1 <memset>
  kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010159a:	8b 06                	mov    (%esi),%eax
  if ((uint32_t)kva < KERNBASE)
f010159c:	83 c4 10             	add    $0x10,%esp
f010159f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01015a4:	0f 86 95 00 00 00    	jbe    f010163f <mem_init+0x186>
  return (physaddr_t)kva - KERNBASE;
f01015aa:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01015b0:	83 ca 05             	or     $0x5,%edx
f01015b3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
  pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f01015b9:	c7 c7 cc 96 11 f0    	mov    $0xf01196cc,%edi
f01015bf:	8b 07                	mov    (%edi),%eax
f01015c1:	c1 e0 03             	shl    $0x3,%eax
f01015c4:	e8 d0 f5 ff ff       	call   f0100b99 <boot_alloc>
f01015c9:	c7 c6 d4 96 11 f0    	mov    $0xf01196d4,%esi
f01015cf:	89 06                	mov    %eax,(%esi)
  cprintf("npages: %d\n", npages);
f01015d1:	83 ec 08             	sub    $0x8,%esp
f01015d4:	ff 37                	pushl  (%edi)
f01015d6:	8d 83 09 d5 fe ff    	lea    -0x12af7(%ebx),%eax
f01015dc:	50                   	push   %eax
f01015dd:	e8 55 1b 00 00       	call   f0103137 <cprintf>
  cprintf("npages_basemem: %d\n", npages_basemem);
f01015e2:	83 c4 08             	add    $0x8,%esp
f01015e5:	ff b3 98 1f 00 00    	pushl  0x1f98(%ebx)
f01015eb:	8d 83 15 d5 fe ff    	lea    -0x12aeb(%ebx),%eax
f01015f1:	50                   	push   %eax
f01015f2:	e8 40 1b 00 00       	call   f0103137 <cprintf>
  cprintf("pages: %x\n", pages);
f01015f7:	83 c4 08             	add    $0x8,%esp
f01015fa:	ff 36                	pushl  (%esi)
f01015fc:	8d 83 29 d5 fe ff    	lea    -0x12ad7(%ebx),%eax
f0101602:	50                   	push   %eax
f0101603:	e8 2f 1b 00 00       	call   f0103137 <cprintf>
  page_init();
f0101608:	e8 25 fa ff ff       	call   f0101032 <page_init>
  check_page_free_list(1);
f010160d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101612:	e8 98 f6 ff ff       	call   f0100caf <check_page_free_list>
  if (!pages)
f0101617:	83 c4 10             	add    $0x10,%esp
f010161a:	83 3e 00             	cmpl   $0x0,(%esi)
f010161d:	74 39                	je     f0101658 <mem_init+0x19f>
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010161f:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f0101625:	be 00 00 00 00       	mov    $0x0,%esi
f010162a:	eb 4c                	jmp    f0101678 <mem_init+0x1bf>
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010162c:	8d 88 00 01 00 00    	lea    0x100(%eax),%ecx
f0101632:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0101638:	89 0a                	mov    %ecx,(%edx)
f010163a:	e9 0a ff ff ff       	jmp    f0101549 <mem_init+0x90>
    _panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010163f:	50                   	push   %eax
f0101640:	8d 83 e4 d8 fe ff    	lea    -0x1271c(%ebx),%eax
f0101646:	50                   	push   %eax
f0101647:	68 87 00 00 00       	push   $0x87
f010164c:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101652:	50                   	push   %eax
f0101653:	e8 a7 ea ff ff       	call   f01000ff <_panic>
    panic("'pages' is a null pointer!");
f0101658:	83 ec 04             	sub    $0x4,%esp
f010165b:	8d 83 34 d5 fe ff    	lea    -0x12acc(%ebx),%eax
f0101661:	50                   	push   %eax
f0101662:	68 2c 02 00 00       	push   $0x22c
f0101667:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f010166d:	50                   	push   %eax
f010166e:	e8 8c ea ff ff       	call   f01000ff <_panic>
    ++nfree;
f0101673:	83 c6 01             	add    $0x1,%esi
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101676:	8b 00                	mov    (%eax),%eax
f0101678:	85 c0                	test   %eax,%eax
f010167a:	75 f7                	jne    f0101673 <mem_init+0x1ba>
  assert((pp0 = page_alloc(0)));
f010167c:	83 ec 0c             	sub    $0xc,%esp
f010167f:	6a 00                	push   $0x0
f0101681:	e8 ce fa ff ff       	call   f0101154 <page_alloc>
f0101686:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101689:	83 c4 10             	add    $0x10,%esp
f010168c:	85 c0                	test   %eax,%eax
f010168e:	0f 84 2e 02 00 00    	je     f01018c2 <mem_init+0x409>
  assert((pp1 = page_alloc(0)));
f0101694:	83 ec 0c             	sub    $0xc,%esp
f0101697:	6a 00                	push   $0x0
f0101699:	e8 b6 fa ff ff       	call   f0101154 <page_alloc>
f010169e:	89 c7                	mov    %eax,%edi
f01016a0:	83 c4 10             	add    $0x10,%esp
f01016a3:	85 c0                	test   %eax,%eax
f01016a5:	0f 84 36 02 00 00    	je     f01018e1 <mem_init+0x428>
  assert((pp2 = page_alloc(0)));
f01016ab:	83 ec 0c             	sub    $0xc,%esp
f01016ae:	6a 00                	push   $0x0
f01016b0:	e8 9f fa ff ff       	call   f0101154 <page_alloc>
f01016b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01016b8:	83 c4 10             	add    $0x10,%esp
f01016bb:	85 c0                	test   %eax,%eax
f01016bd:	0f 84 3d 02 00 00    	je     f0101900 <mem_init+0x447>
  assert(pp1 && pp1 != pp0);
f01016c3:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f01016c6:	0f 84 53 02 00 00    	je     f010191f <mem_init+0x466>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016cf:	39 c7                	cmp    %eax,%edi
f01016d1:	0f 84 67 02 00 00    	je     f010193e <mem_init+0x485>
f01016d7:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01016da:	0f 84 5e 02 00 00    	je     f010193e <mem_init+0x485>
  return (pp - pages) << PGSHIFT;
f01016e0:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f01016e6:	8b 08                	mov    (%eax),%ecx
  assert(page2pa(pp0) < npages * PGSIZE);
f01016e8:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f01016ee:	8b 10                	mov    (%eax),%edx
f01016f0:	c1 e2 0c             	shl    $0xc,%edx
f01016f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016f6:	29 c8                	sub    %ecx,%eax
f01016f8:	c1 f8 03             	sar    $0x3,%eax
f01016fb:	c1 e0 0c             	shl    $0xc,%eax
f01016fe:	39 d0                	cmp    %edx,%eax
f0101700:	0f 83 57 02 00 00    	jae    f010195d <mem_init+0x4a4>
f0101706:	89 f8                	mov    %edi,%eax
f0101708:	29 c8                	sub    %ecx,%eax
f010170a:	c1 f8 03             	sar    $0x3,%eax
f010170d:	c1 e0 0c             	shl    $0xc,%eax
  assert(page2pa(pp1) < npages * PGSIZE);
f0101710:	39 c2                	cmp    %eax,%edx
f0101712:	0f 86 64 02 00 00    	jbe    f010197c <mem_init+0x4c3>
f0101718:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010171b:	29 c8                	sub    %ecx,%eax
f010171d:	c1 f8 03             	sar    $0x3,%eax
f0101720:	c1 e0 0c             	shl    $0xc,%eax
  assert(page2pa(pp2) < npages * PGSIZE);
f0101723:	39 c2                	cmp    %eax,%edx
f0101725:	0f 86 70 02 00 00    	jbe    f010199b <mem_init+0x4e2>
  fl = page_free_list;
f010172b:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f0101731:	89 45 cc             	mov    %eax,-0x34(%ebp)
  page_free_list = 0;
f0101734:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f010173b:	00 00 00 
  assert(!page_alloc(0));
f010173e:	83 ec 0c             	sub    $0xc,%esp
f0101741:	6a 00                	push   $0x0
f0101743:	e8 0c fa ff ff       	call   f0101154 <page_alloc>
f0101748:	83 c4 10             	add    $0x10,%esp
f010174b:	85 c0                	test   %eax,%eax
f010174d:	0f 85 67 02 00 00    	jne    f01019ba <mem_init+0x501>
  page_free(pp0);
f0101753:	83 ec 0c             	sub    $0xc,%esp
f0101756:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101759:	e8 78 fa ff ff       	call   f01011d6 <page_free>
  page_free(pp1);
f010175e:	89 3c 24             	mov    %edi,(%esp)
f0101761:	e8 70 fa ff ff       	call   f01011d6 <page_free>
  page_free(pp2);
f0101766:	83 c4 04             	add    $0x4,%esp
f0101769:	ff 75 d0             	pushl  -0x30(%ebp)
f010176c:	e8 65 fa ff ff       	call   f01011d6 <page_free>
  assert((pp0 = page_alloc(0)));
f0101771:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101778:	e8 d7 f9 ff ff       	call   f0101154 <page_alloc>
f010177d:	89 c7                	mov    %eax,%edi
f010177f:	83 c4 10             	add    $0x10,%esp
f0101782:	85 c0                	test   %eax,%eax
f0101784:	0f 84 4f 02 00 00    	je     f01019d9 <mem_init+0x520>
  assert((pp1 = page_alloc(0)));
f010178a:	83 ec 0c             	sub    $0xc,%esp
f010178d:	6a 00                	push   $0x0
f010178f:	e8 c0 f9 ff ff       	call   f0101154 <page_alloc>
f0101794:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101797:	83 c4 10             	add    $0x10,%esp
f010179a:	85 c0                	test   %eax,%eax
f010179c:	0f 84 56 02 00 00    	je     f01019f8 <mem_init+0x53f>
  assert((pp2 = page_alloc(0)));
f01017a2:	83 ec 0c             	sub    $0xc,%esp
f01017a5:	6a 00                	push   $0x0
f01017a7:	e8 a8 f9 ff ff       	call   f0101154 <page_alloc>
f01017ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01017af:	83 c4 10             	add    $0x10,%esp
f01017b2:	85 c0                	test   %eax,%eax
f01017b4:	0f 84 5d 02 00 00    	je     f0101a17 <mem_init+0x55e>
  assert(pp1 && pp1 != pp0);
f01017ba:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01017bd:	0f 84 73 02 00 00    	je     f0101a36 <mem_init+0x57d>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017c3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017c6:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01017c9:	0f 84 86 02 00 00    	je     f0101a55 <mem_init+0x59c>
f01017cf:	39 c7                	cmp    %eax,%edi
f01017d1:	0f 84 7e 02 00 00    	je     f0101a55 <mem_init+0x59c>
  assert(!page_alloc(0));
f01017d7:	83 ec 0c             	sub    $0xc,%esp
f01017da:	6a 00                	push   $0x0
f01017dc:	e8 73 f9 ff ff       	call   f0101154 <page_alloc>
f01017e1:	83 c4 10             	add    $0x10,%esp
f01017e4:	85 c0                	test   %eax,%eax
f01017e6:	0f 85 88 02 00 00    	jne    f0101a74 <mem_init+0x5bb>
f01017ec:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f01017f2:	89 f9                	mov    %edi,%ecx
f01017f4:	2b 08                	sub    (%eax),%ecx
f01017f6:	89 c8                	mov    %ecx,%eax
f01017f8:	c1 f8 03             	sar    $0x3,%eax
f01017fb:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f01017fe:	89 c1                	mov    %eax,%ecx
f0101800:	c1 e9 0c             	shr    $0xc,%ecx
f0101803:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0101809:	3b 0a                	cmp    (%edx),%ecx
f010180b:	0f 83 82 02 00 00    	jae    f0101a93 <mem_init+0x5da>
  memset(page2kva(pp0), 1, PGSIZE);
f0101811:	83 ec 04             	sub    $0x4,%esp
f0101814:	68 00 10 00 00       	push   $0x1000
f0101819:	6a 01                	push   $0x1
  return (void *)(pa + KERNBASE);
f010181b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101820:	50                   	push   %eax
f0101821:	e8 7b 25 00 00       	call   f0103da1 <memset>
  page_free(pp0);
f0101826:	89 3c 24             	mov    %edi,(%esp)
f0101829:	e8 a8 f9 ff ff       	call   f01011d6 <page_free>
  assert((pp = page_alloc(ALLOC_ZERO)));
f010182e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101835:	e8 1a f9 ff ff       	call   f0101154 <page_alloc>
f010183a:	83 c4 10             	add    $0x10,%esp
f010183d:	85 c0                	test   %eax,%eax
f010183f:	0f 84 64 02 00 00    	je     f0101aa9 <mem_init+0x5f0>
  assert(pp && pp0 == pp);
f0101845:	39 c7                	cmp    %eax,%edi
f0101847:	0f 85 7b 02 00 00    	jne    f0101ac8 <mem_init+0x60f>
  return (pp - pages) << PGSHIFT;
f010184d:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0101853:	89 fa                	mov    %edi,%edx
f0101855:	2b 10                	sub    (%eax),%edx
f0101857:	c1 fa 03             	sar    $0x3,%edx
f010185a:	c1 e2 0c             	shl    $0xc,%edx
  if (PGNUM(pa) >= npages)
f010185d:	89 d1                	mov    %edx,%ecx
f010185f:	c1 e9 0c             	shr    $0xc,%ecx
f0101862:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101868:	3b 08                	cmp    (%eax),%ecx
f010186a:	0f 83 77 02 00 00    	jae    f0101ae7 <mem_init+0x62e>
  return (void *)(pa + KERNBASE);
f0101870:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101876:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
    assert(c[i] == 0);
f010187c:	80 38 00             	cmpb   $0x0,(%eax)
f010187f:	0f 85 78 02 00 00    	jne    f0101afd <mem_init+0x644>
f0101885:	83 c0 01             	add    $0x1,%eax
  for (i = 0; i < PGSIZE; i++)
f0101888:	39 d0                	cmp    %edx,%eax
f010188a:	75 f0                	jne    f010187c <mem_init+0x3c3>
  page_free_list = fl;
f010188c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010188f:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
  page_free(pp0);
f0101895:	83 ec 0c             	sub    $0xc,%esp
f0101898:	57                   	push   %edi
f0101899:	e8 38 f9 ff ff       	call   f01011d6 <page_free>
  page_free(pp1);
f010189e:	83 c4 04             	add    $0x4,%esp
f01018a1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018a4:	e8 2d f9 ff ff       	call   f01011d6 <page_free>
  page_free(pp2);
f01018a9:	83 c4 04             	add    $0x4,%esp
f01018ac:	ff 75 d0             	pushl  -0x30(%ebp)
f01018af:	e8 22 f9 ff ff       	call   f01011d6 <page_free>
  for (pp = page_free_list; pp; pp = pp->pp_link)
f01018b4:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f01018ba:	83 c4 10             	add    $0x10,%esp
f01018bd:	e9 5f 02 00 00       	jmp    f0101b21 <mem_init+0x668>
  assert((pp0 = page_alloc(0)));
f01018c2:	8d 83 4f d5 fe ff    	lea    -0x12ab1(%ebx),%eax
f01018c8:	50                   	push   %eax
f01018c9:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01018cf:	50                   	push   %eax
f01018d0:	68 34 02 00 00       	push   $0x234
f01018d5:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01018db:	50                   	push   %eax
f01018dc:	e8 1e e8 ff ff       	call   f01000ff <_panic>
  assert((pp1 = page_alloc(0)));
f01018e1:	8d 83 65 d5 fe ff    	lea    -0x12a9b(%ebx),%eax
f01018e7:	50                   	push   %eax
f01018e8:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01018ee:	50                   	push   %eax
f01018ef:	68 35 02 00 00       	push   $0x235
f01018f4:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01018fa:	50                   	push   %eax
f01018fb:	e8 ff e7 ff ff       	call   f01000ff <_panic>
  assert((pp2 = page_alloc(0)));
f0101900:	8d 83 7b d5 fe ff    	lea    -0x12a85(%ebx),%eax
f0101906:	50                   	push   %eax
f0101907:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010190d:	50                   	push   %eax
f010190e:	68 36 02 00 00       	push   $0x236
f0101913:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101919:	50                   	push   %eax
f010191a:	e8 e0 e7 ff ff       	call   f01000ff <_panic>
  assert(pp1 && pp1 != pp0);
f010191f:	8d 83 91 d5 fe ff    	lea    -0x12a6f(%ebx),%eax
f0101925:	50                   	push   %eax
f0101926:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010192c:	50                   	push   %eax
f010192d:	68 39 02 00 00       	push   $0x239
f0101932:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101938:	50                   	push   %eax
f0101939:	e8 c1 e7 ff ff       	call   f01000ff <_panic>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010193e:	8d 83 08 d9 fe ff    	lea    -0x126f8(%ebx),%eax
f0101944:	50                   	push   %eax
f0101945:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010194b:	50                   	push   %eax
f010194c:	68 3a 02 00 00       	push   $0x23a
f0101951:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101957:	50                   	push   %eax
f0101958:	e8 a2 e7 ff ff       	call   f01000ff <_panic>
  assert(page2pa(pp0) < npages * PGSIZE);
f010195d:	8d 83 28 d9 fe ff    	lea    -0x126d8(%ebx),%eax
f0101963:	50                   	push   %eax
f0101964:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010196a:	50                   	push   %eax
f010196b:	68 3b 02 00 00       	push   $0x23b
f0101970:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101976:	50                   	push   %eax
f0101977:	e8 83 e7 ff ff       	call   f01000ff <_panic>
  assert(page2pa(pp1) < npages * PGSIZE);
f010197c:	8d 83 48 d9 fe ff    	lea    -0x126b8(%ebx),%eax
f0101982:	50                   	push   %eax
f0101983:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0101989:	50                   	push   %eax
f010198a:	68 3c 02 00 00       	push   $0x23c
f010198f:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101995:	50                   	push   %eax
f0101996:	e8 64 e7 ff ff       	call   f01000ff <_panic>
  assert(page2pa(pp2) < npages * PGSIZE);
f010199b:	8d 83 68 d9 fe ff    	lea    -0x12698(%ebx),%eax
f01019a1:	50                   	push   %eax
f01019a2:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01019a8:	50                   	push   %eax
f01019a9:	68 3d 02 00 00       	push   $0x23d
f01019ae:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01019b4:	50                   	push   %eax
f01019b5:	e8 45 e7 ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f01019ba:	8d 83 a3 d5 fe ff    	lea    -0x12a5d(%ebx),%eax
f01019c0:	50                   	push   %eax
f01019c1:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01019c7:	50                   	push   %eax
f01019c8:	68 44 02 00 00       	push   $0x244
f01019cd:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01019d3:	50                   	push   %eax
f01019d4:	e8 26 e7 ff ff       	call   f01000ff <_panic>
  assert((pp0 = page_alloc(0)));
f01019d9:	8d 83 4f d5 fe ff    	lea    -0x12ab1(%ebx),%eax
f01019df:	50                   	push   %eax
f01019e0:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01019e6:	50                   	push   %eax
f01019e7:	68 4b 02 00 00       	push   $0x24b
f01019ec:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01019f2:	50                   	push   %eax
f01019f3:	e8 07 e7 ff ff       	call   f01000ff <_panic>
  assert((pp1 = page_alloc(0)));
f01019f8:	8d 83 65 d5 fe ff    	lea    -0x12a9b(%ebx),%eax
f01019fe:	50                   	push   %eax
f01019ff:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0101a05:	50                   	push   %eax
f0101a06:	68 4c 02 00 00       	push   $0x24c
f0101a0b:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101a11:	50                   	push   %eax
f0101a12:	e8 e8 e6 ff ff       	call   f01000ff <_panic>
  assert((pp2 = page_alloc(0)));
f0101a17:	8d 83 7b d5 fe ff    	lea    -0x12a85(%ebx),%eax
f0101a1d:	50                   	push   %eax
f0101a1e:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0101a24:	50                   	push   %eax
f0101a25:	68 4d 02 00 00       	push   $0x24d
f0101a2a:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101a30:	50                   	push   %eax
f0101a31:	e8 c9 e6 ff ff       	call   f01000ff <_panic>
  assert(pp1 && pp1 != pp0);
f0101a36:	8d 83 91 d5 fe ff    	lea    -0x12a6f(%ebx),%eax
f0101a3c:	50                   	push   %eax
f0101a3d:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0101a43:	50                   	push   %eax
f0101a44:	68 4f 02 00 00       	push   $0x24f
f0101a49:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101a4f:	50                   	push   %eax
f0101a50:	e8 aa e6 ff ff       	call   f01000ff <_panic>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a55:	8d 83 08 d9 fe ff    	lea    -0x126f8(%ebx),%eax
f0101a5b:	50                   	push   %eax
f0101a5c:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0101a62:	50                   	push   %eax
f0101a63:	68 50 02 00 00       	push   $0x250
f0101a68:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101a6e:	50                   	push   %eax
f0101a6f:	e8 8b e6 ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f0101a74:	8d 83 a3 d5 fe ff    	lea    -0x12a5d(%ebx),%eax
f0101a7a:	50                   	push   %eax
f0101a7b:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0101a81:	50                   	push   %eax
f0101a82:	68 51 02 00 00       	push   $0x251
f0101a87:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101a8d:	50                   	push   %eax
f0101a8e:	e8 6c e6 ff ff       	call   f01000ff <_panic>
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a93:	50                   	push   %eax
f0101a94:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f0101a9a:	50                   	push   %eax
f0101a9b:	6a 3f                	push   $0x3f
f0101a9d:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f0101aa3:	50                   	push   %eax
f0101aa4:	e8 56 e6 ff ff       	call   f01000ff <_panic>
  assert((pp = page_alloc(ALLOC_ZERO)));
f0101aa9:	8d 83 b2 d5 fe ff    	lea    -0x12a4e(%ebx),%eax
f0101aaf:	50                   	push   %eax
f0101ab0:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0101ab6:	50                   	push   %eax
f0101ab7:	68 56 02 00 00       	push   $0x256
f0101abc:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101ac2:	50                   	push   %eax
f0101ac3:	e8 37 e6 ff ff       	call   f01000ff <_panic>
  assert(pp && pp0 == pp);
f0101ac8:	8d 83 d0 d5 fe ff    	lea    -0x12a30(%ebx),%eax
f0101ace:	50                   	push   %eax
f0101acf:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0101ad5:	50                   	push   %eax
f0101ad6:	68 57 02 00 00       	push   $0x257
f0101adb:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101ae1:	50                   	push   %eax
f0101ae2:	e8 18 e6 ff ff       	call   f01000ff <_panic>
f0101ae7:	52                   	push   %edx
f0101ae8:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f0101aee:	50                   	push   %eax
f0101aef:	6a 3f                	push   $0x3f
f0101af1:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f0101af7:	50                   	push   %eax
f0101af8:	e8 02 e6 ff ff       	call   f01000ff <_panic>
    assert(c[i] == 0);
f0101afd:	8d 83 e0 d5 fe ff    	lea    -0x12a20(%ebx),%eax
f0101b03:	50                   	push   %eax
f0101b04:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0101b0a:	50                   	push   %eax
f0101b0b:	68 5a 02 00 00       	push   $0x25a
f0101b10:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0101b16:	50                   	push   %eax
f0101b17:	e8 e3 e5 ff ff       	call   f01000ff <_panic>
    --nfree;
f0101b1c:	83 ee 01             	sub    $0x1,%esi
  for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b1f:	8b 00                	mov    (%eax),%eax
f0101b21:	85 c0                	test   %eax,%eax
f0101b23:	75 f7                	jne    f0101b1c <mem_init+0x663>
  assert(nfree == 0);
f0101b25:	85 f6                	test   %esi,%esi
f0101b27:	0f 85 42 08 00 00    	jne    f010236f <mem_init+0xeb6>
  cprintf("check_page_alloc() succeeded!\n");
f0101b2d:	83 ec 0c             	sub    $0xc,%esp
f0101b30:	8d 83 88 d9 fe ff    	lea    -0x12678(%ebx),%eax
f0101b36:	50                   	push   %eax
f0101b37:	e8 fb 15 00 00       	call   f0103137 <cprintf>
  cprintf("so far so good\n");
f0101b3c:	8d 83 f5 d5 fe ff    	lea    -0x12a0b(%ebx),%eax
f0101b42:	89 04 24             	mov    %eax,(%esp)
f0101b45:	e8 ed 15 00 00       	call   f0103137 <cprintf>
  int i;
  extern pde_t entry_pgdir[];

  // should be able to allocate three pages
  pp0 = pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
f0101b4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b51:	e8 fe f5 ff ff       	call   f0101154 <page_alloc>
f0101b56:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101b59:	83 c4 10             	add    $0x10,%esp
f0101b5c:	85 c0                	test   %eax,%eax
f0101b5e:	0f 84 2a 08 00 00    	je     f010238e <mem_init+0xed5>
  assert((pp1 = page_alloc(0)));
f0101b64:	83 ec 0c             	sub    $0xc,%esp
f0101b67:	6a 00                	push   $0x0
f0101b69:	e8 e6 f5 ff ff       	call   f0101154 <page_alloc>
f0101b6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b71:	83 c4 10             	add    $0x10,%esp
f0101b74:	85 c0                	test   %eax,%eax
f0101b76:	0f 84 31 08 00 00    	je     f01023ad <mem_init+0xef4>
  assert((pp2 = page_alloc(0)));
f0101b7c:	83 ec 0c             	sub    $0xc,%esp
f0101b7f:	6a 00                	push   $0x0
f0101b81:	e8 ce f5 ff ff       	call   f0101154 <page_alloc>
f0101b86:	89 c7                	mov    %eax,%edi
f0101b88:	83 c4 10             	add    $0x10,%esp
f0101b8b:	85 c0                	test   %eax,%eax
f0101b8d:	0f 84 39 08 00 00    	je     f01023cc <mem_init+0xf13>

  assert(pp0);
  assert(pp1 && pp1 != pp0);
f0101b93:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b96:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
f0101b99:	0f 84 4c 08 00 00    	je     f01023eb <mem_init+0xf32>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b9f:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101ba2:	0f 84 62 08 00 00    	je     f010240a <mem_init+0xf51>
f0101ba8:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101bab:	0f 84 59 08 00 00    	je     f010240a <mem_init+0xf51>

  // temporarily steal the rest of the free pages
  fl = page_free_list;
f0101bb1:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f0101bb7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  page_free_list = 0;
f0101bba:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f0101bc1:	00 00 00 

  // should be no free memory
  assert(!page_alloc(0));
f0101bc4:	83 ec 0c             	sub    $0xc,%esp
f0101bc7:	6a 00                	push   $0x0
f0101bc9:	e8 86 f5 ff ff       	call   f0101154 <page_alloc>
f0101bce:	83 c4 10             	add    $0x10,%esp
f0101bd1:	85 c0                	test   %eax,%eax
f0101bd3:	0f 85 50 08 00 00    	jne    f0102429 <mem_init+0xf70>

  // there is no page allocated at address 0
  assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0101bd9:	83 ec 04             	sub    $0x4,%esp
f0101bdc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101bdf:	50                   	push   %eax
f0101be0:	6a 00                	push   $0x0
f0101be2:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101be8:	ff 30                	pushl  (%eax)
f0101bea:	e8 91 f7 ff ff       	call   f0101380 <page_lookup>
f0101bef:	83 c4 10             	add    $0x10,%esp
f0101bf2:	85 c0                	test   %eax,%eax
f0101bf4:	0f 85 4e 08 00 00    	jne    f0102448 <mem_init+0xf8f>

  // there is no free memory, so we can't allocate a page table
  assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101bfa:	6a 02                	push   $0x2
f0101bfc:	6a 00                	push   $0x0
f0101bfe:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c01:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101c07:	ff 30                	pushl  (%eax)
f0101c09:	e8 33 f8 ff ff       	call   f0101441 <page_insert>
f0101c0e:	83 c4 10             	add    $0x10,%esp
f0101c11:	85 c0                	test   %eax,%eax
f0101c13:	0f 89 4e 08 00 00    	jns    f0102467 <mem_init+0xfae>

  // free pp0 and try again: pp0 should be used for page table
  page_free(pp0);
f0101c19:	83 ec 0c             	sub    $0xc,%esp
f0101c1c:	ff 75 d0             	pushl  -0x30(%ebp)
f0101c1f:	e8 b2 f5 ff ff       	call   f01011d6 <page_free>
  assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c24:	6a 02                	push   $0x2
f0101c26:	6a 00                	push   $0x0
f0101c28:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c2b:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101c31:	ff 30                	pushl  (%eax)
f0101c33:	e8 09 f8 ff ff       	call   f0101441 <page_insert>
f0101c38:	83 c4 20             	add    $0x20,%esp
f0101c3b:	85 c0                	test   %eax,%eax
f0101c3d:	0f 85 43 08 00 00    	jne    f0102486 <mem_init+0xfcd>
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c43:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101c49:	8b 08                	mov    (%eax),%ecx
f0101c4b:	89 ce                	mov    %ecx,%esi
  return (pp - pages) << PGSHIFT;
f0101c4d:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0101c53:	8b 00                	mov    (%eax),%eax
f0101c55:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c58:	8b 09                	mov    (%ecx),%ecx
f0101c5a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101c5d:	89 ca                	mov    %ecx,%edx
f0101c5f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c65:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101c68:	29 c1                	sub    %eax,%ecx
f0101c6a:	89 c8                	mov    %ecx,%eax
f0101c6c:	c1 f8 03             	sar    $0x3,%eax
f0101c6f:	c1 e0 0c             	shl    $0xc,%eax
f0101c72:	39 c2                	cmp    %eax,%edx
f0101c74:	0f 85 2b 08 00 00    	jne    f01024a5 <mem_init+0xfec>
  assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c7a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c7f:	89 f0                	mov    %esi,%eax
f0101c81:	e8 ac ef ff ff       	call   f0100c32 <check_va2pa>
f0101c86:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c89:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101c8c:	c1 fa 03             	sar    $0x3,%edx
f0101c8f:	c1 e2 0c             	shl    $0xc,%edx
f0101c92:	39 d0                	cmp    %edx,%eax
f0101c94:	0f 85 2a 08 00 00    	jne    f01024c4 <mem_init+0x100b>
  assert(pp1->pp_ref == 1);
f0101c9a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c9d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ca2:	0f 85 3b 08 00 00    	jne    f01024e3 <mem_init+0x102a>
  assert(pp0->pp_ref == 1);
f0101ca8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cab:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101cb0:	0f 85 4c 08 00 00    	jne    f0102502 <mem_init+0x1049>

  // should be able to map pp2 at PGSIZE because pp0 is already allocated for
  // page table
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101cb6:	6a 02                	push   $0x2
f0101cb8:	68 00 10 00 00       	push   $0x1000
f0101cbd:	57                   	push   %edi
f0101cbe:	56                   	push   %esi
f0101cbf:	e8 7d f7 ff ff       	call   f0101441 <page_insert>
f0101cc4:	83 c4 10             	add    $0x10,%esp
f0101cc7:	85 c0                	test   %eax,%eax
f0101cc9:	0f 85 52 08 00 00    	jne    f0102521 <mem_init+0x1068>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ccf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cd4:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101cda:	8b 00                	mov    (%eax),%eax
f0101cdc:	e8 51 ef ff ff       	call   f0100c32 <check_va2pa>
f0101ce1:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f0101ce7:	89 f9                	mov    %edi,%ecx
f0101ce9:	2b 0a                	sub    (%edx),%ecx
f0101ceb:	89 ca                	mov    %ecx,%edx
f0101ced:	c1 fa 03             	sar    $0x3,%edx
f0101cf0:	c1 e2 0c             	shl    $0xc,%edx
f0101cf3:	39 d0                	cmp    %edx,%eax
f0101cf5:	0f 85 45 08 00 00    	jne    f0102540 <mem_init+0x1087>
  assert(pp2->pp_ref == 1);
f0101cfb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d00:	0f 85 59 08 00 00    	jne    f010255f <mem_init+0x10a6>

  // should be no free memory
  assert(!page_alloc(0));
f0101d06:	83 ec 0c             	sub    $0xc,%esp
f0101d09:	6a 00                	push   $0x0
f0101d0b:	e8 44 f4 ff ff       	call   f0101154 <page_alloc>
f0101d10:	83 c4 10             	add    $0x10,%esp
f0101d13:	85 c0                	test   %eax,%eax
f0101d15:	0f 85 63 08 00 00    	jne    f010257e <mem_init+0x10c5>

  // should be able to map pp2 at PGSIZE because it's already there
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101d1b:	6a 02                	push   $0x2
f0101d1d:	68 00 10 00 00       	push   $0x1000
f0101d22:	57                   	push   %edi
f0101d23:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101d29:	ff 30                	pushl  (%eax)
f0101d2b:	e8 11 f7 ff ff       	call   f0101441 <page_insert>
f0101d30:	83 c4 10             	add    $0x10,%esp
f0101d33:	85 c0                	test   %eax,%eax
f0101d35:	0f 85 62 08 00 00    	jne    f010259d <mem_init+0x10e4>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d3b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d40:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101d46:	8b 00                	mov    (%eax),%eax
f0101d48:	e8 e5 ee ff ff       	call   f0100c32 <check_va2pa>
f0101d4d:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f0101d53:	89 f9                	mov    %edi,%ecx
f0101d55:	2b 0a                	sub    (%edx),%ecx
f0101d57:	89 ca                	mov    %ecx,%edx
f0101d59:	c1 fa 03             	sar    $0x3,%edx
f0101d5c:	c1 e2 0c             	shl    $0xc,%edx
f0101d5f:	39 d0                	cmp    %edx,%eax
f0101d61:	0f 85 55 08 00 00    	jne    f01025bc <mem_init+0x1103>
  assert(pp2->pp_ref == 1);
f0101d67:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d6c:	0f 85 69 08 00 00    	jne    f01025db <mem_init+0x1122>

  // pp2 should NOT be on the free list
  // could happen in ref counts are handled sloppily in page_insert
  assert(!page_alloc(0));
f0101d72:	83 ec 0c             	sub    $0xc,%esp
f0101d75:	6a 00                	push   $0x0
f0101d77:	e8 d8 f3 ff ff       	call   f0101154 <page_alloc>
f0101d7c:	83 c4 10             	add    $0x10,%esp
f0101d7f:	85 c0                	test   %eax,%eax
f0101d81:	0f 85 73 08 00 00    	jne    f01025fa <mem_init+0x1141>

  // check that pgdir_walk returns a pointer to the pte
  ptep = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d87:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101d8d:	8b 10                	mov    (%eax),%edx
f0101d8f:	8b 02                	mov    (%edx),%eax
f0101d91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if (PGNUM(pa) >= npages)
f0101d96:	89 c1                	mov    %eax,%ecx
f0101d98:	c1 e9 0c             	shr    $0xc,%ecx
f0101d9b:	89 ce                	mov    %ecx,%esi
f0101d9d:	c7 c1 cc 96 11 f0    	mov    $0xf01196cc,%ecx
f0101da3:	3b 31                	cmp    (%ecx),%esi
f0101da5:	0f 83 6e 08 00 00    	jae    f0102619 <mem_init+0x1160>
  return (void *)(pa + KERNBASE);
f0101dab:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101db0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f0101db3:	83 ec 04             	sub    $0x4,%esp
f0101db6:	6a 00                	push   $0x0
f0101db8:	68 00 10 00 00       	push   $0x1000
f0101dbd:	52                   	push   %edx
f0101dbe:	e8 56 f4 ff ff       	call   f0101219 <pgdir_walk>
f0101dc3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101dc6:	8d 51 04             	lea    0x4(%ecx),%edx
f0101dc9:	83 c4 10             	add    $0x10,%esp
f0101dcc:	39 d0                	cmp    %edx,%eax
f0101dce:	0f 85 5e 08 00 00    	jne    f0102632 <mem_init+0x1179>

  // should be able to change permissions too.
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f0101dd4:	6a 06                	push   $0x6
f0101dd6:	68 00 10 00 00       	push   $0x1000
f0101ddb:	57                   	push   %edi
f0101ddc:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101de2:	ff 30                	pushl  (%eax)
f0101de4:	e8 58 f6 ff ff       	call   f0101441 <page_insert>
f0101de9:	83 c4 10             	add    $0x10,%esp
f0101dec:	85 c0                	test   %eax,%eax
f0101dee:	0f 85 5d 08 00 00    	jne    f0102651 <mem_init+0x1198>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101df4:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101dfa:	8b 00                	mov    (%eax),%eax
f0101dfc:	89 c6                	mov    %eax,%esi
f0101dfe:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e03:	e8 2a ee ff ff       	call   f0100c32 <check_va2pa>
  return (pp - pages) << PGSHIFT;
f0101e08:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f0101e0e:	89 f9                	mov    %edi,%ecx
f0101e10:	2b 0a                	sub    (%edx),%ecx
f0101e12:	89 ca                	mov    %ecx,%edx
f0101e14:	c1 fa 03             	sar    $0x3,%edx
f0101e17:	c1 e2 0c             	shl    $0xc,%edx
f0101e1a:	39 d0                	cmp    %edx,%eax
f0101e1c:	0f 85 4e 08 00 00    	jne    f0102670 <mem_init+0x11b7>
  assert(pp2->pp_ref == 1);
f0101e22:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e27:	0f 85 62 08 00 00    	jne    f010268f <mem_init+0x11d6>
  assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0101e2d:	83 ec 04             	sub    $0x4,%esp
f0101e30:	6a 00                	push   $0x0
f0101e32:	68 00 10 00 00       	push   $0x1000
f0101e37:	56                   	push   %esi
f0101e38:	e8 dc f3 ff ff       	call   f0101219 <pgdir_walk>
f0101e3d:	83 c4 10             	add    $0x10,%esp
f0101e40:	f6 00 04             	testb  $0x4,(%eax)
f0101e43:	0f 84 65 08 00 00    	je     f01026ae <mem_init+0x11f5>
  cprintf("pp2 %x\n", pp2);
f0101e49:	83 ec 08             	sub    $0x8,%esp
f0101e4c:	57                   	push   %edi
f0101e4d:	8d 83 38 d6 fe ff    	lea    -0x129c8(%ebx),%eax
f0101e53:	50                   	push   %eax
f0101e54:	e8 de 12 00 00       	call   f0103137 <cprintf>
  cprintf("kern_pgdir %x\n", kern_pgdir);
f0101e59:	83 c4 08             	add    $0x8,%esp
f0101e5c:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101e62:	89 c6                	mov    %eax,%esi
f0101e64:	ff 30                	pushl  (%eax)
f0101e66:	8d 83 40 d6 fe ff    	lea    -0x129c0(%ebx),%eax
f0101e6c:	50                   	push   %eax
f0101e6d:	e8 c5 12 00 00       	call   f0103137 <cprintf>
  cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f0101e72:	83 c4 08             	add    $0x8,%esp
f0101e75:	8b 06                	mov    (%esi),%eax
f0101e77:	ff 30                	pushl  (%eax)
f0101e79:	8d 83 4f d6 fe ff    	lea    -0x129b1(%ebx),%eax
f0101e7f:	50                   	push   %eax
f0101e80:	e8 b2 12 00 00       	call   f0103137 <cprintf>
  assert(kern_pgdir[0] & PTE_U);
f0101e85:	8b 06                	mov    (%esi),%eax
f0101e87:	83 c4 10             	add    $0x10,%esp
f0101e8a:	f6 00 04             	testb  $0x4,(%eax)
f0101e8d:	0f 84 3a 08 00 00    	je     f01026cd <mem_init+0x1214>

  // should be able to remap with fewer permissions
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101e93:	6a 02                	push   $0x2
f0101e95:	68 00 10 00 00       	push   $0x1000
f0101e9a:	57                   	push   %edi
f0101e9b:	50                   	push   %eax
f0101e9c:	e8 a0 f5 ff ff       	call   f0101441 <page_insert>
f0101ea1:	83 c4 10             	add    $0x10,%esp
f0101ea4:	85 c0                	test   %eax,%eax
f0101ea6:	0f 85 40 08 00 00    	jne    f01026ec <mem_init+0x1233>
  assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f0101eac:	83 ec 04             	sub    $0x4,%esp
f0101eaf:	6a 00                	push   $0x0
f0101eb1:	68 00 10 00 00       	push   $0x1000
f0101eb6:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101ebc:	ff 30                	pushl  (%eax)
f0101ebe:	e8 56 f3 ff ff       	call   f0101219 <pgdir_walk>
f0101ec3:	83 c4 10             	add    $0x10,%esp
f0101ec6:	f6 00 02             	testb  $0x2,(%eax)
f0101ec9:	0f 84 3c 08 00 00    	je     f010270b <mem_init+0x1252>
  assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101ecf:	83 ec 04             	sub    $0x4,%esp
f0101ed2:	6a 00                	push   $0x0
f0101ed4:	68 00 10 00 00       	push   $0x1000
f0101ed9:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101edf:	ff 30                	pushl  (%eax)
f0101ee1:	e8 33 f3 ff ff       	call   f0101219 <pgdir_walk>
f0101ee6:	83 c4 10             	add    $0x10,%esp
f0101ee9:	f6 00 04             	testb  $0x4,(%eax)
f0101eec:	0f 85 38 08 00 00    	jne    f010272a <mem_init+0x1271>

  // should not be able to map at PTSIZE because need free page for page table
  assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0101ef2:	6a 02                	push   $0x2
f0101ef4:	68 00 00 40 00       	push   $0x400000
f0101ef9:	ff 75 d0             	pushl  -0x30(%ebp)
f0101efc:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101f02:	ff 30                	pushl  (%eax)
f0101f04:	e8 38 f5 ff ff       	call   f0101441 <page_insert>
f0101f09:	83 c4 10             	add    $0x10,%esp
f0101f0c:	85 c0                	test   %eax,%eax
f0101f0e:	0f 89 35 08 00 00    	jns    f0102749 <mem_init+0x1290>

  // insert pp1 at PGSIZE (replacing pp2)
  assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f0101f14:	6a 02                	push   $0x2
f0101f16:	68 00 10 00 00       	push   $0x1000
f0101f1b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f1e:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101f24:	ff 30                	pushl  (%eax)
f0101f26:	e8 16 f5 ff ff       	call   f0101441 <page_insert>
f0101f2b:	83 c4 10             	add    $0x10,%esp
f0101f2e:	85 c0                	test   %eax,%eax
f0101f30:	0f 85 32 08 00 00    	jne    f0102768 <mem_init+0x12af>
  assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101f36:	83 ec 04             	sub    $0x4,%esp
f0101f39:	6a 00                	push   $0x0
f0101f3b:	68 00 10 00 00       	push   $0x1000
f0101f40:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101f46:	ff 30                	pushl  (%eax)
f0101f48:	e8 cc f2 ff ff       	call   f0101219 <pgdir_walk>
f0101f4d:	83 c4 10             	add    $0x10,%esp
f0101f50:	f6 00 04             	testb  $0x4,(%eax)
f0101f53:	0f 85 2e 08 00 00    	jne    f0102787 <mem_init+0x12ce>

  // should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
  assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f59:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101f5f:	8b 00                	mov    (%eax),%eax
f0101f61:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f64:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f69:	e8 c4 ec ff ff       	call   f0100c32 <check_va2pa>
f0101f6e:	89 c6                	mov    %eax,%esi
f0101f70:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0101f76:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101f79:	2b 08                	sub    (%eax),%ecx
f0101f7b:	89 c8                	mov    %ecx,%eax
f0101f7d:	c1 f8 03             	sar    $0x3,%eax
f0101f80:	c1 e0 0c             	shl    $0xc,%eax
f0101f83:	39 c6                	cmp    %eax,%esi
f0101f85:	0f 85 1b 08 00 00    	jne    f01027a6 <mem_init+0x12ed>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f8b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f90:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f93:	e8 9a ec ff ff       	call   f0100c32 <check_va2pa>
f0101f98:	39 c6                	cmp    %eax,%esi
f0101f9a:	0f 85 25 08 00 00    	jne    f01027c5 <mem_init+0x130c>
  // ... and ref counts should reflect this
  assert(pp1->pp_ref == 2);
f0101fa0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fa3:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101fa8:	0f 85 36 08 00 00    	jne    f01027e4 <mem_init+0x132b>
  assert(pp2->pp_ref == 0);
f0101fae:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101fb3:	0f 85 4a 08 00 00    	jne    f0102803 <mem_init+0x134a>

  // pp2 should be returned by page_alloc
  assert((pp = page_alloc(0)) && pp == pp2);
f0101fb9:	83 ec 0c             	sub    $0xc,%esp
f0101fbc:	6a 00                	push   $0x0
f0101fbe:	e8 91 f1 ff ff       	call   f0101154 <page_alloc>
f0101fc3:	83 c4 10             	add    $0x10,%esp
f0101fc6:	39 c7                	cmp    %eax,%edi
f0101fc8:	0f 85 54 08 00 00    	jne    f0102822 <mem_init+0x1369>
f0101fce:	85 c0                	test   %eax,%eax
f0101fd0:	0f 84 4c 08 00 00    	je     f0102822 <mem_init+0x1369>

  // unmapping pp1 at 0 should keep pp1 at PGSIZE
  page_remove(kern_pgdir, 0x0);
f0101fd6:	83 ec 08             	sub    $0x8,%esp
f0101fd9:	6a 00                	push   $0x0
f0101fdb:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101fe1:	89 c6                	mov    %eax,%esi
f0101fe3:	ff 30                	pushl  (%eax)
f0101fe5:	e8 12 f4 ff ff       	call   f01013fc <page_remove>
  assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101fea:	8b 06                	mov    (%esi),%eax
f0101fec:	89 c6                	mov    %eax,%esi
f0101fee:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ff3:	e8 3a ec ff ff       	call   f0100c32 <check_va2pa>
f0101ff8:	83 c4 10             	add    $0x10,%esp
f0101ffb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ffe:	0f 85 3d 08 00 00    	jne    f0102841 <mem_init+0x1388>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102004:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102009:	89 f0                	mov    %esi,%eax
f010200b:	e8 22 ec ff ff       	call   f0100c32 <check_va2pa>
f0102010:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f0102016:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102019:	2b 0a                	sub    (%edx),%ecx
f010201b:	89 ca                	mov    %ecx,%edx
f010201d:	c1 fa 03             	sar    $0x3,%edx
f0102020:	c1 e2 0c             	shl    $0xc,%edx
f0102023:	39 d0                	cmp    %edx,%eax
f0102025:	0f 85 35 08 00 00    	jne    f0102860 <mem_init+0x13a7>
  assert(pp1->pp_ref == 1);
f010202b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010202e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102033:	0f 85 46 08 00 00    	jne    f010287f <mem_init+0x13c6>
  assert(pp2->pp_ref == 0);
f0102039:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010203e:	0f 85 5a 08 00 00    	jne    f010289e <mem_init+0x13e5>

  // unmapping pp1 at PGSIZE should free it
  page_remove(kern_pgdir, (void *)PGSIZE);
f0102044:	83 ec 08             	sub    $0x8,%esp
f0102047:	68 00 10 00 00       	push   $0x1000
f010204c:	56                   	push   %esi
f010204d:	e8 aa f3 ff ff       	call   f01013fc <page_remove>
  assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102052:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102058:	8b 00                	mov    (%eax),%eax
f010205a:	89 c6                	mov    %eax,%esi
f010205c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102061:	e8 cc eb ff ff       	call   f0100c32 <check_va2pa>
f0102066:	83 c4 10             	add    $0x10,%esp
f0102069:	83 f8 ff             	cmp    $0xffffffff,%eax
f010206c:	0f 85 4b 08 00 00    	jne    f01028bd <mem_init+0x1404>
  assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102072:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102077:	89 f0                	mov    %esi,%eax
f0102079:	e8 b4 eb ff ff       	call   f0100c32 <check_va2pa>
f010207e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102081:	0f 85 55 08 00 00    	jne    f01028dc <mem_init+0x1423>
  assert(pp1->pp_ref == 0);
f0102087:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010208a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010208f:	0f 85 66 08 00 00    	jne    f01028fb <mem_init+0x1442>
  assert(pp2->pp_ref == 0);
f0102095:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010209a:	0f 85 7a 08 00 00    	jne    f010291a <mem_init+0x1461>

  // so it should be returned by page_alloc
  assert((pp = page_alloc(0)) && pp == pp1);
f01020a0:	83 ec 0c             	sub    $0xc,%esp
f01020a3:	6a 00                	push   $0x0
f01020a5:	e8 aa f0 ff ff       	call   f0101154 <page_alloc>
f01020aa:	83 c4 10             	add    $0x10,%esp
f01020ad:	85 c0                	test   %eax,%eax
f01020af:	0f 84 84 08 00 00    	je     f0102939 <mem_init+0x1480>
f01020b5:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01020b8:	0f 85 7b 08 00 00    	jne    f0102939 <mem_init+0x1480>

  // should be no free memory
  assert(!page_alloc(0));
f01020be:	83 ec 0c             	sub    $0xc,%esp
f01020c1:	6a 00                	push   $0x0
f01020c3:	e8 8c f0 ff ff       	call   f0101154 <page_alloc>
f01020c8:	83 c4 10             	add    $0x10,%esp
f01020cb:	85 c0                	test   %eax,%eax
f01020cd:	0f 85 85 08 00 00    	jne    f0102958 <mem_init+0x149f>

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01020d3:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f01020d9:	8b 08                	mov    (%eax),%ecx
f01020db:	8b 11                	mov    (%ecx),%edx
f01020dd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01020e3:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f01020e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01020ec:	2b 30                	sub    (%eax),%esi
f01020ee:	89 f0                	mov    %esi,%eax
f01020f0:	c1 f8 03             	sar    $0x3,%eax
f01020f3:	c1 e0 0c             	shl    $0xc,%eax
f01020f6:	39 c2                	cmp    %eax,%edx
f01020f8:	0f 85 79 08 00 00    	jne    f0102977 <mem_init+0x14be>
  kern_pgdir[0] = 0;
f01020fe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  assert(pp0->pp_ref == 1);
f0102104:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102107:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010210c:	0f 85 84 08 00 00    	jne    f0102996 <mem_init+0x14dd>
  pp0->pp_ref = 0;
f0102112:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102115:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

  // check pointer arithmetic in pgdir_walk
  page_free(pp0);
f010211b:	83 ec 0c             	sub    $0xc,%esp
f010211e:	50                   	push   %eax
f010211f:	e8 b2 f0 ff ff       	call   f01011d6 <page_free>
  va = (void *)(PGSIZE * NPDENTRIES + PGSIZE);
  ptep = pgdir_walk(kern_pgdir, va, 1);
f0102124:	83 c4 0c             	add    $0xc,%esp
f0102127:	6a 01                	push   $0x1
f0102129:	68 00 10 40 00       	push   $0x401000
f010212e:	c7 c6 d0 96 11 f0    	mov    $0xf01196d0,%esi
f0102134:	ff 36                	pushl  (%esi)
f0102136:	e8 de f0 ff ff       	call   f0101219 <pgdir_walk>
f010213b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010213e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  ptep1 = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102141:	8b 06                	mov    (%esi),%eax
f0102143:	8b 50 04             	mov    0x4(%eax),%edx
f0102146:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if (PGNUM(pa) >= npages)
f010214c:	c7 c1 cc 96 11 f0    	mov    $0xf01196cc,%ecx
f0102152:	8b 09                	mov    (%ecx),%ecx
f0102154:	89 d6                	mov    %edx,%esi
f0102156:	c1 ee 0c             	shr    $0xc,%esi
f0102159:	83 c4 10             	add    $0x10,%esp
f010215c:	39 ce                	cmp    %ecx,%esi
f010215e:	0f 83 51 08 00 00    	jae    f01029b5 <mem_init+0x14fc>
  assert(ptep == ptep1 + PTX(va));
f0102164:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010216a:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f010216d:	0f 85 5b 08 00 00    	jne    f01029ce <mem_init+0x1515>
  kern_pgdir[PDX(va)] = 0;
f0102173:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  pp0->pp_ref = 0;
f010217a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010217d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
  return (pp - pages) << PGSHIFT;
f0102183:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102189:	2b 30                	sub    (%eax),%esi
f010218b:	89 f0                	mov    %esi,%eax
f010218d:	c1 f8 03             	sar    $0x3,%eax
f0102190:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f0102193:	89 c2                	mov    %eax,%edx
f0102195:	c1 ea 0c             	shr    $0xc,%edx
f0102198:	39 d1                	cmp    %edx,%ecx
f010219a:	0f 86 4d 08 00 00    	jbe    f01029ed <mem_init+0x1534>

  // check that new page tables get cleared
  memset(page2kva(pp0), 0xFF, PGSIZE);
f01021a0:	83 ec 04             	sub    $0x4,%esp
f01021a3:	68 00 10 00 00       	push   $0x1000
f01021a8:	68 ff 00 00 00       	push   $0xff
  return (void *)(pa + KERNBASE);
f01021ad:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021b2:	50                   	push   %eax
f01021b3:	e8 e9 1b 00 00       	call   f0103da1 <memset>
  page_free(pp0);
f01021b8:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01021bb:	89 34 24             	mov    %esi,(%esp)
f01021be:	e8 13 f0 ff ff       	call   f01011d6 <page_free>
  pgdir_walk(kern_pgdir, 0x0, 1);
f01021c3:	83 c4 0c             	add    $0xc,%esp
f01021c6:	6a 01                	push   $0x1
f01021c8:	6a 00                	push   $0x0
f01021ca:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f01021d0:	ff 30                	pushl  (%eax)
f01021d2:	e8 42 f0 ff ff       	call   f0101219 <pgdir_walk>
  return (pp - pages) << PGSHIFT;
f01021d7:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f01021dd:	89 f2                	mov    %esi,%edx
f01021df:	2b 10                	sub    (%eax),%edx
f01021e1:	c1 fa 03             	sar    $0x3,%edx
f01021e4:	c1 e2 0c             	shl    $0xc,%edx
  if (PGNUM(pa) >= npages)
f01021e7:	89 d1                	mov    %edx,%ecx
f01021e9:	c1 e9 0c             	shr    $0xc,%ecx
f01021ec:	83 c4 10             	add    $0x10,%esp
f01021ef:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f01021f5:	3b 08                	cmp    (%eax),%ecx
f01021f7:	0f 83 06 08 00 00    	jae    f0102a03 <mem_init+0x154a>
  return (void *)(pa + KERNBASE);
f01021fd:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
  ptep = (pte_t *)page2kva(pp0);
f0102203:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102206:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f010220c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  for (i = 0; i < NPTENTRIES; i++)
    assert((ptep[i] & PTE_P) == 0);
f010220f:	f6 00 01             	testb  $0x1,(%eax)
f0102212:	0f 85 01 08 00 00    	jne    f0102a19 <mem_init+0x1560>
f0102218:	83 c0 04             	add    $0x4,%eax
  for (i = 0; i < NPTENTRIES; i++)
f010221b:	39 c2                	cmp    %eax,%edx
f010221d:	75 f0                	jne    f010220f <mem_init+0xd56>
  kern_pgdir[0] = 0;
f010221f:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102225:	8b 00                	mov    (%eax),%eax
f0102227:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  pp0->pp_ref = 0;
f010222d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

  // give free list back
  page_free_list = fl;
f0102233:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0102236:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)

  // free the pages we took
  page_free(pp0);
f010223c:	83 ec 0c             	sub    $0xc,%esp
f010223f:	56                   	push   %esi
f0102240:	e8 91 ef ff ff       	call   f01011d6 <page_free>
  page_free(pp1);
f0102245:	83 c4 04             	add    $0x4,%esp
f0102248:	ff 75 d4             	pushl  -0x2c(%ebp)
f010224b:	e8 86 ef ff ff       	call   f01011d6 <page_free>
  page_free(pp2);
f0102250:	89 3c 24             	mov    %edi,(%esp)
f0102253:	e8 7e ef ff ff       	call   f01011d6 <page_free>

  cprintf("check_page() succeeded!\n");
f0102258:	8d 83 dc d6 fe ff    	lea    -0x12924(%ebx),%eax
f010225e:	89 04 24             	mov    %eax,(%esp)
f0102261:	e8 d1 0e 00 00       	call   f0103137 <cprintf>
  boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102266:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f010226c:	8b 00                	mov    (%eax),%eax
  if ((uint32_t)kva < KERNBASE)
f010226e:	83 c4 10             	add    $0x10,%esp
f0102271:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102276:	0f 86 bc 07 00 00    	jbe    f0102a38 <mem_init+0x157f>
f010227c:	83 ec 08             	sub    $0x8,%esp
f010227f:	6a 04                	push   $0x4
  return (physaddr_t)kva - KERNBASE;
f0102281:	05 00 00 00 10       	add    $0x10000000,%eax
f0102286:	50                   	push   %eax
f0102287:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010228c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102291:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102297:	8b 00                	mov    (%eax),%eax
f0102299:	e8 26 f0 ff ff       	call   f01012c4 <boot_map_region>
  cprintf("PADDR(pages) %x\n", PADDR(pages));
f010229e:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f01022a4:	8b 00                	mov    (%eax),%eax
  if ((uint32_t)kva < KERNBASE)
f01022a6:	83 c4 10             	add    $0x10,%esp
f01022a9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022ae:	0f 86 9d 07 00 00    	jbe    f0102a51 <mem_init+0x1598>
f01022b4:	83 ec 08             	sub    $0x8,%esp
  return (physaddr_t)kva - KERNBASE;
f01022b7:	05 00 00 00 10       	add    $0x10000000,%eax
f01022bc:	50                   	push   %eax
f01022bd:	8d 83 f5 d6 fe ff    	lea    -0x1290b(%ebx),%eax
f01022c3:	50                   	push   %eax
f01022c4:	e8 6e 0e 00 00       	call   f0103137 <cprintf>
  if ((uint32_t)kva < KERNBASE)
f01022c9:	c7 c0 00 e0 10 f0    	mov    $0xf010e000,%eax
f01022cf:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01022d2:	83 c4 10             	add    $0x10,%esp
f01022d5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022da:	0f 86 8a 07 00 00    	jbe    f0102a6a <mem_init+0x15b1>
  return (physaddr_t)kva - KERNBASE;
f01022e0:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01022e3:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
  boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack),
f01022e9:	c7 c6 d0 96 11 f0    	mov    $0xf01196d0,%esi
f01022ef:	83 ec 08             	sub    $0x8,%esp
f01022f2:	6a 02                	push   $0x2
f01022f4:	57                   	push   %edi
f01022f5:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01022fa:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01022ff:	8b 06                	mov    (%esi),%eax
f0102301:	e8 be ef ff ff       	call   f01012c4 <boot_map_region>
  cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));
f0102306:	83 c4 08             	add    $0x8,%esp
f0102309:	57                   	push   %edi
f010230a:	8d 83 06 d7 fe ff    	lea    -0x128fa(%ebx),%eax
f0102310:	50                   	push   %eax
f0102311:	e8 21 0e 00 00       	call   f0103137 <cprintf>
  boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f0102316:	83 c4 08             	add    $0x8,%esp
f0102319:	6a 02                	push   $0x2
f010231b:	6a 00                	push   $0x0
f010231d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102322:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102327:	8b 06                	mov    (%esi),%eax
f0102329:	e8 96 ef ff ff       	call   f01012c4 <boot_map_region>
  pgdir = kern_pgdir;
f010232e:	8b 36                	mov    (%esi),%esi
  n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f0102330:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102336:	8b 00                	mov    (%eax),%eax
f0102338:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010233b:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102342:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102347:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010234a:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102350:	8b 00                	mov    (%eax),%eax
f0102352:	89 45 c0             	mov    %eax,-0x40(%ebp)
  if ((uint32_t)kva < KERNBASE)
f0102355:	89 45 cc             	mov    %eax,-0x34(%ebp)
  return (physaddr_t)kva - KERNBASE;
f0102358:	05 00 00 00 10       	add    $0x10000000,%eax
f010235d:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < n; i += PGSIZE)
f0102360:	bf 00 00 00 00       	mov    $0x0,%edi
f0102365:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102368:	89 c6                	mov    %eax,%esi
f010236a:	e9 35 07 00 00       	jmp    f0102aa4 <mem_init+0x15eb>
  assert(nfree == 0);
f010236f:	8d 83 ea d5 fe ff    	lea    -0x12a16(%ebx),%eax
f0102375:	50                   	push   %eax
f0102376:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010237c:	50                   	push   %eax
f010237d:	68 67 02 00 00       	push   $0x267
f0102382:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102388:	50                   	push   %eax
f0102389:	e8 71 dd ff ff       	call   f01000ff <_panic>
  assert((pp0 = page_alloc(0)));
f010238e:	8d 83 4f d5 fe ff    	lea    -0x12ab1(%ebx),%eax
f0102394:	50                   	push   %eax
f0102395:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010239b:	50                   	push   %eax
f010239c:	68 b9 02 00 00       	push   $0x2b9
f01023a1:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01023a7:	50                   	push   %eax
f01023a8:	e8 52 dd ff ff       	call   f01000ff <_panic>
  assert((pp1 = page_alloc(0)));
f01023ad:	8d 83 65 d5 fe ff    	lea    -0x12a9b(%ebx),%eax
f01023b3:	50                   	push   %eax
f01023b4:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01023ba:	50                   	push   %eax
f01023bb:	68 ba 02 00 00       	push   $0x2ba
f01023c0:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01023c6:	50                   	push   %eax
f01023c7:	e8 33 dd ff ff       	call   f01000ff <_panic>
  assert((pp2 = page_alloc(0)));
f01023cc:	8d 83 7b d5 fe ff    	lea    -0x12a85(%ebx),%eax
f01023d2:	50                   	push   %eax
f01023d3:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01023d9:	50                   	push   %eax
f01023da:	68 bb 02 00 00       	push   $0x2bb
f01023df:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01023e5:	50                   	push   %eax
f01023e6:	e8 14 dd ff ff       	call   f01000ff <_panic>
  assert(pp1 && pp1 != pp0);
f01023eb:	8d 83 91 d5 fe ff    	lea    -0x12a6f(%ebx),%eax
f01023f1:	50                   	push   %eax
f01023f2:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01023f8:	50                   	push   %eax
f01023f9:	68 be 02 00 00       	push   $0x2be
f01023fe:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102404:	50                   	push   %eax
f0102405:	e8 f5 dc ff ff       	call   f01000ff <_panic>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010240a:	8d 83 08 d9 fe ff    	lea    -0x126f8(%ebx),%eax
f0102410:	50                   	push   %eax
f0102411:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102417:	50                   	push   %eax
f0102418:	68 bf 02 00 00       	push   $0x2bf
f010241d:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102423:	50                   	push   %eax
f0102424:	e8 d6 dc ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f0102429:	8d 83 a3 d5 fe ff    	lea    -0x12a5d(%ebx),%eax
f010242f:	50                   	push   %eax
f0102430:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102436:	50                   	push   %eax
f0102437:	68 c6 02 00 00       	push   $0x2c6
f010243c:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102442:	50                   	push   %eax
f0102443:	e8 b7 dc ff ff       	call   f01000ff <_panic>
  assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0102448:	8d 83 a8 d9 fe ff    	lea    -0x12658(%ebx),%eax
f010244e:	50                   	push   %eax
f010244f:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102455:	50                   	push   %eax
f0102456:	68 c9 02 00 00       	push   $0x2c9
f010245b:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102461:	50                   	push   %eax
f0102462:	e8 98 dc ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102467:	8d 83 dc d9 fe ff    	lea    -0x12624(%ebx),%eax
f010246d:	50                   	push   %eax
f010246e:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102474:	50                   	push   %eax
f0102475:	68 cc 02 00 00       	push   $0x2cc
f010247a:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102480:	50                   	push   %eax
f0102481:	e8 79 dc ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102486:	8d 83 0c da fe ff    	lea    -0x125f4(%ebx),%eax
f010248c:	50                   	push   %eax
f010248d:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102493:	50                   	push   %eax
f0102494:	68 d0 02 00 00       	push   $0x2d0
f0102499:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f010249f:	50                   	push   %eax
f01024a0:	e8 5a dc ff ff       	call   f01000ff <_panic>
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01024a5:	8d 83 3c da fe ff    	lea    -0x125c4(%ebx),%eax
f01024ab:	50                   	push   %eax
f01024ac:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01024b2:	50                   	push   %eax
f01024b3:	68 d1 02 00 00       	push   $0x2d1
f01024b8:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01024be:	50                   	push   %eax
f01024bf:	e8 3b dc ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01024c4:	8d 83 64 da fe ff    	lea    -0x1259c(%ebx),%eax
f01024ca:	50                   	push   %eax
f01024cb:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01024d1:	50                   	push   %eax
f01024d2:	68 d2 02 00 00       	push   $0x2d2
f01024d7:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01024dd:	50                   	push   %eax
f01024de:	e8 1c dc ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 1);
f01024e3:	8d 83 05 d6 fe ff    	lea    -0x129fb(%ebx),%eax
f01024e9:	50                   	push   %eax
f01024ea:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01024f0:	50                   	push   %eax
f01024f1:	68 d3 02 00 00       	push   $0x2d3
f01024f6:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01024fc:	50                   	push   %eax
f01024fd:	e8 fd db ff ff       	call   f01000ff <_panic>
  assert(pp0->pp_ref == 1);
f0102502:	8d 83 16 d6 fe ff    	lea    -0x129ea(%ebx),%eax
f0102508:	50                   	push   %eax
f0102509:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010250f:	50                   	push   %eax
f0102510:	68 d4 02 00 00       	push   $0x2d4
f0102515:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f010251b:	50                   	push   %eax
f010251c:	e8 de db ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0102521:	8d 83 94 da fe ff    	lea    -0x1256c(%ebx),%eax
f0102527:	50                   	push   %eax
f0102528:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010252e:	50                   	push   %eax
f010252f:	68 d8 02 00 00       	push   $0x2d8
f0102534:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f010253a:	50                   	push   %eax
f010253b:	e8 bf db ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102540:	8d 83 d0 da fe ff    	lea    -0x12530(%ebx),%eax
f0102546:	50                   	push   %eax
f0102547:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010254d:	50                   	push   %eax
f010254e:	68 d9 02 00 00       	push   $0x2d9
f0102553:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102559:	50                   	push   %eax
f010255a:	e8 a0 db ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 1);
f010255f:	8d 83 27 d6 fe ff    	lea    -0x129d9(%ebx),%eax
f0102565:	50                   	push   %eax
f0102566:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010256c:	50                   	push   %eax
f010256d:	68 da 02 00 00       	push   $0x2da
f0102572:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102578:	50                   	push   %eax
f0102579:	e8 81 db ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f010257e:	8d 83 a3 d5 fe ff    	lea    -0x12a5d(%ebx),%eax
f0102584:	50                   	push   %eax
f0102585:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010258b:	50                   	push   %eax
f010258c:	68 dd 02 00 00       	push   $0x2dd
f0102591:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102597:	50                   	push   %eax
f0102598:	e8 62 db ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f010259d:	8d 83 94 da fe ff    	lea    -0x1256c(%ebx),%eax
f01025a3:	50                   	push   %eax
f01025a4:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01025aa:	50                   	push   %eax
f01025ab:	68 e0 02 00 00       	push   $0x2e0
f01025b0:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01025b6:	50                   	push   %eax
f01025b7:	e8 43 db ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025bc:	8d 83 d0 da fe ff    	lea    -0x12530(%ebx),%eax
f01025c2:	50                   	push   %eax
f01025c3:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01025c9:	50                   	push   %eax
f01025ca:	68 e1 02 00 00       	push   $0x2e1
f01025cf:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01025d5:	50                   	push   %eax
f01025d6:	e8 24 db ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 1);
f01025db:	8d 83 27 d6 fe ff    	lea    -0x129d9(%ebx),%eax
f01025e1:	50                   	push   %eax
f01025e2:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01025e8:	50                   	push   %eax
f01025e9:	68 e2 02 00 00       	push   $0x2e2
f01025ee:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01025f4:	50                   	push   %eax
f01025f5:	e8 05 db ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f01025fa:	8d 83 a3 d5 fe ff    	lea    -0x12a5d(%ebx),%eax
f0102600:	50                   	push   %eax
f0102601:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102607:	50                   	push   %eax
f0102608:	68 e6 02 00 00       	push   $0x2e6
f010260d:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102613:	50                   	push   %eax
f0102614:	e8 e6 da ff ff       	call   f01000ff <_panic>
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102619:	50                   	push   %eax
f010261a:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f0102620:	50                   	push   %eax
f0102621:	68 e9 02 00 00       	push   $0x2e9
f0102626:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f010262c:	50                   	push   %eax
f010262d:	e8 cd da ff ff       	call   f01000ff <_panic>
  assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f0102632:	8d 83 00 db fe ff    	lea    -0x12500(%ebx),%eax
f0102638:	50                   	push   %eax
f0102639:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010263f:	50                   	push   %eax
f0102640:	68 ea 02 00 00       	push   $0x2ea
f0102645:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f010264b:	50                   	push   %eax
f010264c:	e8 ae da ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f0102651:	8d 83 40 db fe ff    	lea    -0x124c0(%ebx),%eax
f0102657:	50                   	push   %eax
f0102658:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010265e:	50                   	push   %eax
f010265f:	68 ed 02 00 00       	push   $0x2ed
f0102664:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f010266a:	50                   	push   %eax
f010266b:	e8 8f da ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102670:	8d 83 d0 da fe ff    	lea    -0x12530(%ebx),%eax
f0102676:	50                   	push   %eax
f0102677:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010267d:	50                   	push   %eax
f010267e:	68 ee 02 00 00       	push   $0x2ee
f0102683:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102689:	50                   	push   %eax
f010268a:	e8 70 da ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 1);
f010268f:	8d 83 27 d6 fe ff    	lea    -0x129d9(%ebx),%eax
f0102695:	50                   	push   %eax
f0102696:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010269c:	50                   	push   %eax
f010269d:	68 ef 02 00 00       	push   $0x2ef
f01026a2:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01026a8:	50                   	push   %eax
f01026a9:	e8 51 da ff ff       	call   f01000ff <_panic>
  assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f01026ae:	8d 83 84 db fe ff    	lea    -0x1247c(%ebx),%eax
f01026b4:	50                   	push   %eax
f01026b5:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01026bb:	50                   	push   %eax
f01026bc:	68 f0 02 00 00       	push   $0x2f0
f01026c1:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01026c7:	50                   	push   %eax
f01026c8:	e8 32 da ff ff       	call   f01000ff <_panic>
  assert(kern_pgdir[0] & PTE_U);
f01026cd:	8d 83 64 d6 fe ff    	lea    -0x1299c(%ebx),%eax
f01026d3:	50                   	push   %eax
f01026d4:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01026da:	50                   	push   %eax
f01026db:	68 f4 02 00 00       	push   $0x2f4
f01026e0:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01026e6:	50                   	push   %eax
f01026e7:	e8 13 da ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f01026ec:	8d 83 94 da fe ff    	lea    -0x1256c(%ebx),%eax
f01026f2:	50                   	push   %eax
f01026f3:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01026f9:	50                   	push   %eax
f01026fa:	68 f7 02 00 00       	push   $0x2f7
f01026ff:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102705:	50                   	push   %eax
f0102706:	e8 f4 d9 ff ff       	call   f01000ff <_panic>
  assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f010270b:	8d 83 b8 db fe ff    	lea    -0x12448(%ebx),%eax
f0102711:	50                   	push   %eax
f0102712:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102718:	50                   	push   %eax
f0102719:	68 f8 02 00 00       	push   $0x2f8
f010271e:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102724:	50                   	push   %eax
f0102725:	e8 d5 d9 ff ff       	call   f01000ff <_panic>
  assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f010272a:	8d 83 ec db fe ff    	lea    -0x12414(%ebx),%eax
f0102730:	50                   	push   %eax
f0102731:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102737:	50                   	push   %eax
f0102738:	68 f9 02 00 00       	push   $0x2f9
f010273d:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102743:	50                   	push   %eax
f0102744:	e8 b6 d9 ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0102749:	8d 83 24 dc fe ff    	lea    -0x123dc(%ebx),%eax
f010274f:	50                   	push   %eax
f0102750:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102756:	50                   	push   %eax
f0102757:	68 fc 02 00 00       	push   $0x2fc
f010275c:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102762:	50                   	push   %eax
f0102763:	e8 97 d9 ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f0102768:	8d 83 5c dc fe ff    	lea    -0x123a4(%ebx),%eax
f010276e:	50                   	push   %eax
f010276f:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102775:	50                   	push   %eax
f0102776:	68 ff 02 00 00       	push   $0x2ff
f010277b:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102781:	50                   	push   %eax
f0102782:	e8 78 d9 ff ff       	call   f01000ff <_panic>
  assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0102787:	8d 83 ec db fe ff    	lea    -0x12414(%ebx),%eax
f010278d:	50                   	push   %eax
f010278e:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102794:	50                   	push   %eax
f0102795:	68 00 03 00 00       	push   $0x300
f010279a:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01027a0:	50                   	push   %eax
f01027a1:	e8 59 d9 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01027a6:	8d 83 98 dc fe ff    	lea    -0x12368(%ebx),%eax
f01027ac:	50                   	push   %eax
f01027ad:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01027b3:	50                   	push   %eax
f01027b4:	68 03 03 00 00       	push   $0x303
f01027b9:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01027bf:	50                   	push   %eax
f01027c0:	e8 3a d9 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01027c5:	8d 83 c4 dc fe ff    	lea    -0x1233c(%ebx),%eax
f01027cb:	50                   	push   %eax
f01027cc:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01027d2:	50                   	push   %eax
f01027d3:	68 04 03 00 00       	push   $0x304
f01027d8:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01027de:	50                   	push   %eax
f01027df:	e8 1b d9 ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 2);
f01027e4:	8d 83 7a d6 fe ff    	lea    -0x12986(%ebx),%eax
f01027ea:	50                   	push   %eax
f01027eb:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01027f1:	50                   	push   %eax
f01027f2:	68 06 03 00 00       	push   $0x306
f01027f7:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01027fd:	50                   	push   %eax
f01027fe:	e8 fc d8 ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 0);
f0102803:	8d 83 8b d6 fe ff    	lea    -0x12975(%ebx),%eax
f0102809:	50                   	push   %eax
f010280a:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102810:	50                   	push   %eax
f0102811:	68 07 03 00 00       	push   $0x307
f0102816:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f010281c:	50                   	push   %eax
f010281d:	e8 dd d8 ff ff       	call   f01000ff <_panic>
  assert((pp = page_alloc(0)) && pp == pp2);
f0102822:	8d 83 f4 dc fe ff    	lea    -0x1230c(%ebx),%eax
f0102828:	50                   	push   %eax
f0102829:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010282f:	50                   	push   %eax
f0102830:	68 0a 03 00 00       	push   $0x30a
f0102835:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f010283b:	50                   	push   %eax
f010283c:	e8 be d8 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102841:	8d 83 18 dd fe ff    	lea    -0x122e8(%ebx),%eax
f0102847:	50                   	push   %eax
f0102848:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010284e:	50                   	push   %eax
f010284f:	68 0e 03 00 00       	push   $0x30e
f0102854:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f010285a:	50                   	push   %eax
f010285b:	e8 9f d8 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102860:	8d 83 c4 dc fe ff    	lea    -0x1233c(%ebx),%eax
f0102866:	50                   	push   %eax
f0102867:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010286d:	50                   	push   %eax
f010286e:	68 0f 03 00 00       	push   $0x30f
f0102873:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102879:	50                   	push   %eax
f010287a:	e8 80 d8 ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 1);
f010287f:	8d 83 05 d6 fe ff    	lea    -0x129fb(%ebx),%eax
f0102885:	50                   	push   %eax
f0102886:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010288c:	50                   	push   %eax
f010288d:	68 10 03 00 00       	push   $0x310
f0102892:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102898:	50                   	push   %eax
f0102899:	e8 61 d8 ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 0);
f010289e:	8d 83 8b d6 fe ff    	lea    -0x12975(%ebx),%eax
f01028a4:	50                   	push   %eax
f01028a5:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01028ab:	50                   	push   %eax
f01028ac:	68 11 03 00 00       	push   $0x311
f01028b1:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01028b7:	50                   	push   %eax
f01028b8:	e8 42 d8 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01028bd:	8d 83 18 dd fe ff    	lea    -0x122e8(%ebx),%eax
f01028c3:	50                   	push   %eax
f01028c4:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01028ca:	50                   	push   %eax
f01028cb:	68 15 03 00 00       	push   $0x315
f01028d0:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01028d6:	50                   	push   %eax
f01028d7:	e8 23 d8 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01028dc:	8d 83 3c dd fe ff    	lea    -0x122c4(%ebx),%eax
f01028e2:	50                   	push   %eax
f01028e3:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01028e9:	50                   	push   %eax
f01028ea:	68 16 03 00 00       	push   $0x316
f01028ef:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01028f5:	50                   	push   %eax
f01028f6:	e8 04 d8 ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 0);
f01028fb:	8d 83 9c d6 fe ff    	lea    -0x12964(%ebx),%eax
f0102901:	50                   	push   %eax
f0102902:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102908:	50                   	push   %eax
f0102909:	68 17 03 00 00       	push   $0x317
f010290e:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102914:	50                   	push   %eax
f0102915:	e8 e5 d7 ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 0);
f010291a:	8d 83 8b d6 fe ff    	lea    -0x12975(%ebx),%eax
f0102920:	50                   	push   %eax
f0102921:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102927:	50                   	push   %eax
f0102928:	68 18 03 00 00       	push   $0x318
f010292d:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102933:	50                   	push   %eax
f0102934:	e8 c6 d7 ff ff       	call   f01000ff <_panic>
  assert((pp = page_alloc(0)) && pp == pp1);
f0102939:	8d 83 64 dd fe ff    	lea    -0x1229c(%ebx),%eax
f010293f:	50                   	push   %eax
f0102940:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102946:	50                   	push   %eax
f0102947:	68 1b 03 00 00       	push   $0x31b
f010294c:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102952:	50                   	push   %eax
f0102953:	e8 a7 d7 ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f0102958:	8d 83 a3 d5 fe ff    	lea    -0x12a5d(%ebx),%eax
f010295e:	50                   	push   %eax
f010295f:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102965:	50                   	push   %eax
f0102966:	68 1e 03 00 00       	push   $0x31e
f010296b:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102971:	50                   	push   %eax
f0102972:	e8 88 d7 ff ff       	call   f01000ff <_panic>
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102977:	8d 83 3c da fe ff    	lea    -0x125c4(%ebx),%eax
f010297d:	50                   	push   %eax
f010297e:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102984:	50                   	push   %eax
f0102985:	68 21 03 00 00       	push   $0x321
f010298a:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102990:	50                   	push   %eax
f0102991:	e8 69 d7 ff ff       	call   f01000ff <_panic>
  assert(pp0->pp_ref == 1);
f0102996:	8d 83 16 d6 fe ff    	lea    -0x129ea(%ebx),%eax
f010299c:	50                   	push   %eax
f010299d:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01029a3:	50                   	push   %eax
f01029a4:	68 23 03 00 00       	push   $0x323
f01029a9:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01029af:	50                   	push   %eax
f01029b0:	e8 4a d7 ff ff       	call   f01000ff <_panic>
f01029b5:	52                   	push   %edx
f01029b6:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f01029bc:	50                   	push   %eax
f01029bd:	68 2a 03 00 00       	push   $0x32a
f01029c2:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01029c8:	50                   	push   %eax
f01029c9:	e8 31 d7 ff ff       	call   f01000ff <_panic>
  assert(ptep == ptep1 + PTX(va));
f01029ce:	8d 83 ad d6 fe ff    	lea    -0x12953(%ebx),%eax
f01029d4:	50                   	push   %eax
f01029d5:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f01029db:	50                   	push   %eax
f01029dc:	68 2b 03 00 00       	push   $0x32b
f01029e1:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f01029e7:	50                   	push   %eax
f01029e8:	e8 12 d7 ff ff       	call   f01000ff <_panic>
f01029ed:	50                   	push   %eax
f01029ee:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f01029f4:	50                   	push   %eax
f01029f5:	6a 3f                	push   $0x3f
f01029f7:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f01029fd:	50                   	push   %eax
f01029fe:	e8 fc d6 ff ff       	call   f01000ff <_panic>
f0102a03:	52                   	push   %edx
f0102a04:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f0102a0a:	50                   	push   %eax
f0102a0b:	6a 3f                	push   $0x3f
f0102a0d:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f0102a13:	50                   	push   %eax
f0102a14:	e8 e6 d6 ff ff       	call   f01000ff <_panic>
    assert((ptep[i] & PTE_P) == 0);
f0102a19:	8d 83 c5 d6 fe ff    	lea    -0x1293b(%ebx),%eax
f0102a1f:	50                   	push   %eax
f0102a20:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102a26:	50                   	push   %eax
f0102a27:	68 35 03 00 00       	push   $0x335
f0102a2c:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102a32:	50                   	push   %eax
f0102a33:	e8 c7 d6 ff ff       	call   f01000ff <_panic>
    _panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a38:	50                   	push   %eax
f0102a39:	8d 83 e4 d8 fe ff    	lea    -0x1271c(%ebx),%eax
f0102a3f:	50                   	push   %eax
f0102a40:	68 ac 00 00 00       	push   $0xac
f0102a45:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102a4b:	50                   	push   %eax
f0102a4c:	e8 ae d6 ff ff       	call   f01000ff <_panic>
f0102a51:	50                   	push   %eax
f0102a52:	8d 83 e4 d8 fe ff    	lea    -0x1271c(%ebx),%eax
f0102a58:	50                   	push   %eax
f0102a59:	68 ad 00 00 00       	push   $0xad
f0102a5e:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102a64:	50                   	push   %eax
f0102a65:	e8 95 d6 ff ff       	call   f01000ff <_panic>
f0102a6a:	50                   	push   %eax
f0102a6b:	8d 83 e4 d8 fe ff    	lea    -0x1271c(%ebx),%eax
f0102a71:	50                   	push   %eax
f0102a72:	68 ba 00 00 00       	push   $0xba
f0102a77:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102a7d:	50                   	push   %eax
f0102a7e:	e8 7c d6 ff ff       	call   f01000ff <_panic>
f0102a83:	ff 75 c0             	pushl  -0x40(%ebp)
f0102a86:	8d 83 e4 d8 fe ff    	lea    -0x1271c(%ebx),%eax
f0102a8c:	50                   	push   %eax
f0102a8d:	68 7d 02 00 00       	push   $0x27d
f0102a92:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102a98:	50                   	push   %eax
f0102a99:	e8 61 d6 ff ff       	call   f01000ff <_panic>
  for (i = 0; i < n; i += PGSIZE)
f0102a9e:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102aa4:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0102aa7:	76 3d                	jbe    f0102ae6 <mem_init+0x162d>
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102aa9:	8d 97 00 00 00 ef    	lea    -0x11000000(%edi),%edx
f0102aaf:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102ab2:	e8 7b e1 ff ff       	call   f0100c32 <check_va2pa>
  if ((uint32_t)kva < KERNBASE)
f0102ab7:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102abe:	76 c3                	jbe    f0102a83 <mem_init+0x15ca>
f0102ac0:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102ac3:	39 c2                	cmp    %eax,%edx
f0102ac5:	74 d7                	je     f0102a9e <mem_init+0x15e5>
f0102ac7:	8d 83 88 dd fe ff    	lea    -0x12278(%ebx),%eax
f0102acd:	50                   	push   %eax
f0102ace:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102ad4:	50                   	push   %eax
f0102ad5:	68 7d 02 00 00       	push   $0x27d
f0102ada:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102ae0:	50                   	push   %eax
f0102ae1:	e8 19 d6 ff ff       	call   f01000ff <_panic>
f0102ae6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ae9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0102aec:	c1 e0 0c             	shl    $0xc,%eax
f0102aef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102af2:	bf 00 00 00 00       	mov    $0x0,%edi
f0102af7:	eb 17                	jmp    f0102b10 <mem_init+0x1657>
    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102af9:	8d 97 00 00 00 f0    	lea    -0x10000000(%edi),%edx
f0102aff:	89 f0                	mov    %esi,%eax
f0102b01:	e8 2c e1 ff ff       	call   f0100c32 <check_va2pa>
f0102b06:	39 c7                	cmp    %eax,%edi
f0102b08:	75 57                	jne    f0102b61 <mem_init+0x16a8>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102b0a:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102b10:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0102b13:	72 e4                	jb     f0102af9 <mem_init+0x1640>
f0102b15:	bf 00 80 ff ef       	mov    $0xefff8000,%edi
    assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) ==
f0102b1a:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102b1d:	05 00 80 00 20       	add    $0x20008000,%eax
f0102b22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b25:	89 fa                	mov    %edi,%edx
f0102b27:	89 f0                	mov    %esi,%eax
f0102b29:	e8 04 e1 ff ff       	call   f0100c32 <check_va2pa>
f0102b2e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102b31:	8d 14 39             	lea    (%ecx,%edi,1),%edx
f0102b34:	39 c2                	cmp    %eax,%edx
f0102b36:	75 48                	jne    f0102b80 <mem_init+0x16c7>
f0102b38:	81 c7 00 10 00 00    	add    $0x1000,%edi
  for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102b3e:	81 ff 00 00 00 f0    	cmp    $0xf0000000,%edi
f0102b44:	75 df                	jne    f0102b25 <mem_init+0x166c>
  assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102b46:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102b4b:	89 f0                	mov    %esi,%eax
f0102b4d:	e8 e0 e0 ff ff       	call   f0100c32 <check_va2pa>
f0102b52:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b55:	75 48                	jne    f0102b9f <mem_init+0x16e6>
  for (i = 0; i < NPDENTRIES; i++) {
f0102b57:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b5c:	e9 86 00 00 00       	jmp    f0102be7 <mem_init+0x172e>
    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102b61:	8d 83 bc dd fe ff    	lea    -0x12244(%ebx),%eax
f0102b67:	50                   	push   %eax
f0102b68:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102b6e:	50                   	push   %eax
f0102b6f:	68 81 02 00 00       	push   $0x281
f0102b74:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102b7a:	50                   	push   %eax
f0102b7b:	e8 7f d5 ff ff       	call   f01000ff <_panic>
    assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) ==
f0102b80:	8d 83 e4 dd fe ff    	lea    -0x1221c(%ebx),%eax
f0102b86:	50                   	push   %eax
f0102b87:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102b8d:	50                   	push   %eax
f0102b8e:	68 86 02 00 00       	push   $0x286
f0102b93:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102b99:	50                   	push   %eax
f0102b9a:	e8 60 d5 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102b9f:	8d 83 2c de fe ff    	lea    -0x121d4(%ebx),%eax
f0102ba5:	50                   	push   %eax
f0102ba6:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102bac:	50                   	push   %eax
f0102bad:	68 87 02 00 00       	push   $0x287
f0102bb2:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102bb8:	50                   	push   %eax
f0102bb9:	e8 41 d5 ff ff       	call   f01000ff <_panic>
      assert(pgdir[i] & PTE_P);
f0102bbe:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102bc2:	74 4f                	je     f0102c13 <mem_init+0x175a>
  for (i = 0; i < NPDENTRIES; i++) {
f0102bc4:	83 c0 01             	add    $0x1,%eax
f0102bc7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102bcc:	0f 87 ab 00 00 00    	ja     f0102c7d <mem_init+0x17c4>
    switch (i) {
f0102bd2:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102bd7:	72 0e                	jb     f0102be7 <mem_init+0x172e>
f0102bd9:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102bde:	76 de                	jbe    f0102bbe <mem_init+0x1705>
f0102be0:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102be5:	74 d7                	je     f0102bbe <mem_init+0x1705>
      if (i >= PDX(KERNBASE)) {
f0102be7:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102bec:	77 44                	ja     f0102c32 <mem_init+0x1779>
        assert(pgdir[i] == 0);
f0102bee:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102bf2:	74 d0                	je     f0102bc4 <mem_init+0x170b>
f0102bf4:	8d 83 3d d7 fe ff    	lea    -0x128c3(%ebx),%eax
f0102bfa:	50                   	push   %eax
f0102bfb:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102c01:	50                   	push   %eax
f0102c02:	68 96 02 00 00       	push   $0x296
f0102c07:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102c0d:	50                   	push   %eax
f0102c0e:	e8 ec d4 ff ff       	call   f01000ff <_panic>
      assert(pgdir[i] & PTE_P);
f0102c13:	8d 83 1b d7 fe ff    	lea    -0x128e5(%ebx),%eax
f0102c19:	50                   	push   %eax
f0102c1a:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102c20:	50                   	push   %eax
f0102c21:	68 8f 02 00 00       	push   $0x28f
f0102c26:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102c2c:	50                   	push   %eax
f0102c2d:	e8 cd d4 ff ff       	call   f01000ff <_panic>
        assert(pgdir[i] & PTE_P);
f0102c32:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102c35:	f6 c2 01             	test   $0x1,%dl
f0102c38:	74 24                	je     f0102c5e <mem_init+0x17a5>
        assert(pgdir[i] & PTE_W);
f0102c3a:	f6 c2 02             	test   $0x2,%dl
f0102c3d:	75 85                	jne    f0102bc4 <mem_init+0x170b>
f0102c3f:	8d 83 2c d7 fe ff    	lea    -0x128d4(%ebx),%eax
f0102c45:	50                   	push   %eax
f0102c46:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102c4c:	50                   	push   %eax
f0102c4d:	68 94 02 00 00       	push   $0x294
f0102c52:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102c58:	50                   	push   %eax
f0102c59:	e8 a1 d4 ff ff       	call   f01000ff <_panic>
        assert(pgdir[i] & PTE_P);
f0102c5e:	8d 83 1b d7 fe ff    	lea    -0x128e5(%ebx),%eax
f0102c64:	50                   	push   %eax
f0102c65:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102c6b:	50                   	push   %eax
f0102c6c:	68 93 02 00 00       	push   $0x293
f0102c71:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102c77:	50                   	push   %eax
f0102c78:	e8 82 d4 ff ff       	call   f01000ff <_panic>
  cprintf("check_kern_pgdir() succeeded!\n");
f0102c7d:	83 ec 0c             	sub    $0xc,%esp
f0102c80:	8d 83 5c de fe ff    	lea    -0x121a4(%ebx),%eax
f0102c86:	50                   	push   %eax
f0102c87:	e8 ab 04 00 00       	call   f0103137 <cprintf>
  lcr3(PADDR(kern_pgdir));
f0102c8c:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102c92:	8b 00                	mov    (%eax),%eax
f0102c94:	83 c4 10             	add    $0x10,%esp
f0102c97:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c9c:	0f 86 28 02 00 00    	jbe    f0102eca <mem_init+0x1a11>
  return (physaddr_t)kva - KERNBASE;
f0102ca2:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102ca7:	0f 22 d8             	mov    %eax,%cr3
  check_page_free_list(0);
f0102caa:	b8 00 00 00 00       	mov    $0x0,%eax
f0102caf:	e8 fb df ff ff       	call   f0100caf <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102cb4:	0f 20 c0             	mov    %cr0,%eax
  cr0 &= ~(CR0_TS | CR0_EM);
f0102cb7:	83 e0 f3             	and    $0xfffffff3,%eax
f0102cba:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102cbf:	0f 22 c0             	mov    %eax,%cr0
  uintptr_t va;
  int i;

  // check that we can read and write installed pages
  pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
f0102cc2:	83 ec 0c             	sub    $0xc,%esp
f0102cc5:	6a 00                	push   $0x0
f0102cc7:	e8 88 e4 ff ff       	call   f0101154 <page_alloc>
f0102ccc:	89 c6                	mov    %eax,%esi
f0102cce:	83 c4 10             	add    $0x10,%esp
f0102cd1:	85 c0                	test   %eax,%eax
f0102cd3:	0f 84 0a 02 00 00    	je     f0102ee3 <mem_init+0x1a2a>
  assert((pp1 = page_alloc(0)));
f0102cd9:	83 ec 0c             	sub    $0xc,%esp
f0102cdc:	6a 00                	push   $0x0
f0102cde:	e8 71 e4 ff ff       	call   f0101154 <page_alloc>
f0102ce3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102ce6:	83 c4 10             	add    $0x10,%esp
f0102ce9:	85 c0                	test   %eax,%eax
f0102ceb:	0f 84 11 02 00 00    	je     f0102f02 <mem_init+0x1a49>
  assert((pp2 = page_alloc(0)));
f0102cf1:	83 ec 0c             	sub    $0xc,%esp
f0102cf4:	6a 00                	push   $0x0
f0102cf6:	e8 59 e4 ff ff       	call   f0101154 <page_alloc>
f0102cfb:	89 c7                	mov    %eax,%edi
f0102cfd:	83 c4 10             	add    $0x10,%esp
f0102d00:	85 c0                	test   %eax,%eax
f0102d02:	0f 84 19 02 00 00    	je     f0102f21 <mem_init+0x1a68>
  page_free(pp0);
f0102d08:	83 ec 0c             	sub    $0xc,%esp
f0102d0b:	56                   	push   %esi
f0102d0c:	e8 c5 e4 ff ff       	call   f01011d6 <page_free>
  return (pp - pages) << PGSHIFT;
f0102d11:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102d17:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102d1a:	2b 08                	sub    (%eax),%ecx
f0102d1c:	89 c8                	mov    %ecx,%eax
f0102d1e:	c1 f8 03             	sar    $0x3,%eax
f0102d21:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f0102d24:	89 c1                	mov    %eax,%ecx
f0102d26:	c1 e9 0c             	shr    $0xc,%ecx
f0102d29:	83 c4 10             	add    $0x10,%esp
f0102d2c:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0102d32:	3b 0a                	cmp    (%edx),%ecx
f0102d34:	0f 83 06 02 00 00    	jae    f0102f40 <mem_init+0x1a87>
  memset(page2kva(pp1), 1, PGSIZE);
f0102d3a:	83 ec 04             	sub    $0x4,%esp
f0102d3d:	68 00 10 00 00       	push   $0x1000
f0102d42:	6a 01                	push   $0x1
  return (void *)(pa + KERNBASE);
f0102d44:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d49:	50                   	push   %eax
f0102d4a:	e8 52 10 00 00       	call   f0103da1 <memset>
  return (pp - pages) << PGSHIFT;
f0102d4f:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102d55:	89 f9                	mov    %edi,%ecx
f0102d57:	2b 08                	sub    (%eax),%ecx
f0102d59:	89 c8                	mov    %ecx,%eax
f0102d5b:	c1 f8 03             	sar    $0x3,%eax
f0102d5e:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f0102d61:	89 c1                	mov    %eax,%ecx
f0102d63:	c1 e9 0c             	shr    $0xc,%ecx
f0102d66:	83 c4 10             	add    $0x10,%esp
f0102d69:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0102d6f:	3b 0a                	cmp    (%edx),%ecx
f0102d71:	0f 83 df 01 00 00    	jae    f0102f56 <mem_init+0x1a9d>
  memset(page2kva(pp2), 2, PGSIZE);
f0102d77:	83 ec 04             	sub    $0x4,%esp
f0102d7a:	68 00 10 00 00       	push   $0x1000
f0102d7f:	6a 02                	push   $0x2
  return (void *)(pa + KERNBASE);
f0102d81:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d86:	50                   	push   %eax
f0102d87:	e8 15 10 00 00       	call   f0103da1 <memset>
  page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W);
f0102d8c:	6a 02                	push   $0x2
f0102d8e:	68 00 10 00 00       	push   $0x1000
f0102d93:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102d96:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102d9c:	ff 30                	pushl  (%eax)
f0102d9e:	e8 9e e6 ff ff       	call   f0101441 <page_insert>
  assert(pp1->pp_ref == 1);
f0102da3:	83 c4 20             	add    $0x20,%esp
f0102da6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102da9:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102dae:	0f 85 b8 01 00 00    	jne    f0102f6c <mem_init+0x1ab3>
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102db4:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102dbb:	01 01 01 
f0102dbe:	0f 85 c7 01 00 00    	jne    f0102f8b <mem_init+0x1ad2>
  page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W);
f0102dc4:	6a 02                	push   $0x2
f0102dc6:	68 00 10 00 00       	push   $0x1000
f0102dcb:	57                   	push   %edi
f0102dcc:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102dd2:	ff 30                	pushl  (%eax)
f0102dd4:	e8 68 e6 ff ff       	call   f0101441 <page_insert>
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102dd9:	83 c4 10             	add    $0x10,%esp
f0102ddc:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102de3:	02 02 02 
f0102de6:	0f 85 be 01 00 00    	jne    f0102faa <mem_init+0x1af1>
  assert(pp2->pp_ref == 1);
f0102dec:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102df1:	0f 85 d2 01 00 00    	jne    f0102fc9 <mem_init+0x1b10>
  assert(pp1->pp_ref == 0);
f0102df7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dfa:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102dff:	0f 85 e3 01 00 00    	jne    f0102fe8 <mem_init+0x1b2f>
  *(uint32_t *)PGSIZE = 0x03030303U;
f0102e05:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e0c:	03 03 03 
  return (pp - pages) << PGSHIFT;
f0102e0f:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102e15:	89 f9                	mov    %edi,%ecx
f0102e17:	2b 08                	sub    (%eax),%ecx
f0102e19:	89 c8                	mov    %ecx,%eax
f0102e1b:	c1 f8 03             	sar    $0x3,%eax
f0102e1e:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f0102e21:	89 c1                	mov    %eax,%ecx
f0102e23:	c1 e9 0c             	shr    $0xc,%ecx
f0102e26:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0102e2c:	3b 0a                	cmp    (%edx),%ecx
f0102e2e:	0f 83 d3 01 00 00    	jae    f0103007 <mem_init+0x1b4e>
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e34:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102e3b:	03 03 03 
f0102e3e:	0f 85 d9 01 00 00    	jne    f010301d <mem_init+0x1b64>
  page_remove(kern_pgdir, (void *)PGSIZE);
f0102e44:	83 ec 08             	sub    $0x8,%esp
f0102e47:	68 00 10 00 00       	push   $0x1000
f0102e4c:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102e52:	ff 30                	pushl  (%eax)
f0102e54:	e8 a3 e5 ff ff       	call   f01013fc <page_remove>
  assert(pp2->pp_ref == 0);
f0102e59:	83 c4 10             	add    $0x10,%esp
f0102e5c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102e61:	0f 85 d5 01 00 00    	jne    f010303c <mem_init+0x1b83>

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e67:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102e6d:	8b 08                	mov    (%eax),%ecx
f0102e6f:	8b 11                	mov    (%ecx),%edx
f0102e71:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return (pp - pages) << PGSHIFT;
f0102e77:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102e7d:	89 f7                	mov    %esi,%edi
f0102e7f:	2b 38                	sub    (%eax),%edi
f0102e81:	89 f8                	mov    %edi,%eax
f0102e83:	c1 f8 03             	sar    $0x3,%eax
f0102e86:	c1 e0 0c             	shl    $0xc,%eax
f0102e89:	39 c2                	cmp    %eax,%edx
f0102e8b:	0f 85 ca 01 00 00    	jne    f010305b <mem_init+0x1ba2>
  kern_pgdir[0] = 0;
f0102e91:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  assert(pp0->pp_ref == 1);
f0102e97:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102e9c:	0f 85 d8 01 00 00    	jne    f010307a <mem_init+0x1bc1>
  pp0->pp_ref = 0;
f0102ea2:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

  // free the pages we took
  page_free(pp0);
f0102ea8:	83 ec 0c             	sub    $0xc,%esp
f0102eab:	56                   	push   %esi
f0102eac:	e8 25 e3 ff ff       	call   f01011d6 <page_free>

  cprintf("check_page_installed_pgdir() succeeded!\n");
f0102eb1:	8d 83 f0 de fe ff    	lea    -0x12110(%ebx),%eax
f0102eb7:	89 04 24             	mov    %eax,(%esp)
f0102eba:	e8 78 02 00 00       	call   f0103137 <cprintf>
}
f0102ebf:	83 c4 10             	add    $0x10,%esp
f0102ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ec5:	5b                   	pop    %ebx
f0102ec6:	5e                   	pop    %esi
f0102ec7:	5f                   	pop    %edi
f0102ec8:	5d                   	pop    %ebp
f0102ec9:	c3                   	ret    
    _panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102eca:	50                   	push   %eax
f0102ecb:	8d 83 e4 d8 fe ff    	lea    -0x1271c(%ebx),%eax
f0102ed1:	50                   	push   %eax
f0102ed2:	68 d3 00 00 00       	push   $0xd3
f0102ed7:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102edd:	50                   	push   %eax
f0102ede:	e8 1c d2 ff ff       	call   f01000ff <_panic>
  assert((pp0 = page_alloc(0)));
f0102ee3:	8d 83 4f d5 fe ff    	lea    -0x12ab1(%ebx),%eax
f0102ee9:	50                   	push   %eax
f0102eea:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102ef0:	50                   	push   %eax
f0102ef1:	68 4e 03 00 00       	push   $0x34e
f0102ef6:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102efc:	50                   	push   %eax
f0102efd:	e8 fd d1 ff ff       	call   f01000ff <_panic>
  assert((pp1 = page_alloc(0)));
f0102f02:	8d 83 65 d5 fe ff    	lea    -0x12a9b(%ebx),%eax
f0102f08:	50                   	push   %eax
f0102f09:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102f0f:	50                   	push   %eax
f0102f10:	68 4f 03 00 00       	push   $0x34f
f0102f15:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102f1b:	50                   	push   %eax
f0102f1c:	e8 de d1 ff ff       	call   f01000ff <_panic>
  assert((pp2 = page_alloc(0)));
f0102f21:	8d 83 7b d5 fe ff    	lea    -0x12a85(%ebx),%eax
f0102f27:	50                   	push   %eax
f0102f28:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102f2e:	50                   	push   %eax
f0102f2f:	68 50 03 00 00       	push   $0x350
f0102f34:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102f3a:	50                   	push   %eax
f0102f3b:	e8 bf d1 ff ff       	call   f01000ff <_panic>
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f40:	50                   	push   %eax
f0102f41:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f0102f47:	50                   	push   %eax
f0102f48:	6a 3f                	push   $0x3f
f0102f4a:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f0102f50:	50                   	push   %eax
f0102f51:	e8 a9 d1 ff ff       	call   f01000ff <_panic>
f0102f56:	50                   	push   %eax
f0102f57:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f0102f5d:	50                   	push   %eax
f0102f5e:	6a 3f                	push   $0x3f
f0102f60:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f0102f66:	50                   	push   %eax
f0102f67:	e8 93 d1 ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 1);
f0102f6c:	8d 83 05 d6 fe ff    	lea    -0x129fb(%ebx),%eax
f0102f72:	50                   	push   %eax
f0102f73:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102f79:	50                   	push   %eax
f0102f7a:	68 55 03 00 00       	push   $0x355
f0102f7f:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102f85:	50                   	push   %eax
f0102f86:	e8 74 d1 ff ff       	call   f01000ff <_panic>
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f8b:	8d 83 7c de fe ff    	lea    -0x12184(%ebx),%eax
f0102f91:	50                   	push   %eax
f0102f92:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102f98:	50                   	push   %eax
f0102f99:	68 56 03 00 00       	push   $0x356
f0102f9e:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102fa4:	50                   	push   %eax
f0102fa5:	e8 55 d1 ff ff       	call   f01000ff <_panic>
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102faa:	8d 83 a0 de fe ff    	lea    -0x12160(%ebx),%eax
f0102fb0:	50                   	push   %eax
f0102fb1:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102fb7:	50                   	push   %eax
f0102fb8:	68 58 03 00 00       	push   $0x358
f0102fbd:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102fc3:	50                   	push   %eax
f0102fc4:	e8 36 d1 ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 1);
f0102fc9:	8d 83 27 d6 fe ff    	lea    -0x129d9(%ebx),%eax
f0102fcf:	50                   	push   %eax
f0102fd0:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102fd6:	50                   	push   %eax
f0102fd7:	68 59 03 00 00       	push   $0x359
f0102fdc:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0102fe2:	50                   	push   %eax
f0102fe3:	e8 17 d1 ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 0);
f0102fe8:	8d 83 9c d6 fe ff    	lea    -0x12964(%ebx),%eax
f0102fee:	50                   	push   %eax
f0102fef:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0102ff5:	50                   	push   %eax
f0102ff6:	68 5a 03 00 00       	push   $0x35a
f0102ffb:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0103001:	50                   	push   %eax
f0103002:	e8 f8 d0 ff ff       	call   f01000ff <_panic>
f0103007:	50                   	push   %eax
f0103008:	8d 83 4c d7 fe ff    	lea    -0x128b4(%ebx),%eax
f010300e:	50                   	push   %eax
f010300f:	6a 3f                	push   $0x3f
f0103011:	8d 83 29 d4 fe ff    	lea    -0x12bd7(%ebx),%eax
f0103017:	50                   	push   %eax
f0103018:	e8 e2 d0 ff ff       	call   f01000ff <_panic>
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010301d:	8d 83 c4 de fe ff    	lea    -0x1213c(%ebx),%eax
f0103023:	50                   	push   %eax
f0103024:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f010302a:	50                   	push   %eax
f010302b:	68 5c 03 00 00       	push   $0x35c
f0103030:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0103036:	50                   	push   %eax
f0103037:	e8 c3 d0 ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 0);
f010303c:	8d 83 8b d6 fe ff    	lea    -0x12975(%ebx),%eax
f0103042:	50                   	push   %eax
f0103043:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0103049:	50                   	push   %eax
f010304a:	68 5e 03 00 00       	push   $0x35e
f010304f:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0103055:	50                   	push   %eax
f0103056:	e8 a4 d0 ff ff       	call   f01000ff <_panic>
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010305b:	8d 83 3c da fe ff    	lea    -0x125c4(%ebx),%eax
f0103061:	50                   	push   %eax
f0103062:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0103068:	50                   	push   %eax
f0103069:	68 61 03 00 00       	push   $0x361
f010306e:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0103074:	50                   	push   %eax
f0103075:	e8 85 d0 ff ff       	call   f01000ff <_panic>
  assert(pp0->pp_ref == 1);
f010307a:	8d 83 16 d6 fe ff    	lea    -0x129ea(%ebx),%eax
f0103080:	50                   	push   %eax
f0103081:	8d 83 43 d4 fe ff    	lea    -0x12bbd(%ebx),%eax
f0103087:	50                   	push   %eax
f0103088:	68 63 03 00 00       	push   $0x363
f010308d:	8d 83 1d d4 fe ff    	lea    -0x12be3(%ebx),%eax
f0103093:	50                   	push   %eax
f0103094:	e8 66 d0 ff ff       	call   f01000ff <_panic>

f0103099 <tlb_invalidate>:
void tlb_invalidate(pde_t *pgdir, void *va) {
f0103099:	55                   	push   %ebp
f010309a:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010309c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010309f:	0f 01 38             	invlpg (%eax)
}
f01030a2:	5d                   	pop    %ebp
f01030a3:	c3                   	ret    

f01030a4 <__x86.get_pc_thunk.cx>:
f01030a4:	8b 0c 24             	mov    (%esp),%ecx
f01030a7:	c3                   	ret    

f01030a8 <__x86.get_pc_thunk.si>:
f01030a8:	8b 34 24             	mov    (%esp),%esi
f01030ab:	c3                   	ret    

f01030ac <__x86.get_pc_thunk.di>:
f01030ac:	8b 3c 24             	mov    (%esp),%edi
f01030af:	c3                   	ret    

f01030b0 <mc146818_read>:

#include <inc/x86.h>

#include <kern/kclock.h>

unsigned mc146818_read(unsigned reg) {
f01030b0:	55                   	push   %ebp
f01030b1:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01030b6:	ba 70 00 00 00       	mov    $0x70,%edx
f01030bb:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01030bc:	ba 71 00 00 00       	mov    $0x71,%edx
f01030c1:	ec                   	in     (%dx),%al
  outb(IO_RTC, reg);
  return inb(IO_RTC + 1);
f01030c2:	0f b6 c0             	movzbl %al,%eax
}
f01030c5:	5d                   	pop    %ebp
f01030c6:	c3                   	ret    

f01030c7 <mc146818_write>:

void mc146818_write(unsigned reg, unsigned datum) {
f01030c7:	55                   	push   %ebp
f01030c8:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01030ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01030cd:	ba 70 00 00 00       	mov    $0x70,%edx
f01030d2:	ee                   	out    %al,(%dx)
f01030d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030d6:	ba 71 00 00 00       	mov    $0x71,%edx
f01030db:	ee                   	out    %al,(%dx)
  outb(IO_RTC, reg);
  outb(IO_RTC + 1, datum);
f01030dc:	5d                   	pop    %ebp
f01030dd:	c3                   	ret    

f01030de <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01030de:	55                   	push   %ebp
f01030df:	89 e5                	mov    %esp,%ebp
f01030e1:	53                   	push   %ebx
f01030e2:	83 ec 10             	sub    $0x10,%esp
f01030e5:	e8 cb d0 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f01030ea:	81 c3 1e 42 01 00    	add    $0x1421e,%ebx
	cputchar(ch);
f01030f0:	ff 75 08             	pushl  0x8(%ebp)
f01030f3:	e8 46 d6 ff ff       	call   f010073e <cputchar>
	*cnt++;
}
f01030f8:	83 c4 10             	add    $0x10,%esp
f01030fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030fe:	c9                   	leave  
f01030ff:	c3                   	ret    

f0103100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103100:	55                   	push   %ebp
f0103101:	89 e5                	mov    %esp,%ebp
f0103103:	53                   	push   %ebx
f0103104:	83 ec 14             	sub    $0x14,%esp
f0103107:	e8 a9 d0 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010310c:	81 c3 fc 41 01 00    	add    $0x141fc,%ebx
	int cnt = 0;
f0103112:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103119:	ff 75 0c             	pushl  0xc(%ebp)
f010311c:	ff 75 08             	pushl  0x8(%ebp)
f010311f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103122:	50                   	push   %eax
f0103123:	8d 83 d6 bd fe ff    	lea    -0x1422a(%ebx),%eax
f0103129:	50                   	push   %eax
f010312a:	e8 98 04 00 00       	call   f01035c7 <vprintfmt>
	return cnt;
}
f010312f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103132:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103135:	c9                   	leave  
f0103136:	c3                   	ret    

f0103137 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103137:	55                   	push   %ebp
f0103138:	89 e5                	mov    %esp,%ebp
f010313a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010313d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103140:	50                   	push   %eax
f0103141:	ff 75 08             	pushl  0x8(%ebp)
f0103144:	e8 b7 ff ff ff       	call   f0103100 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103149:	c9                   	leave  
f010314a:	c3                   	ret    

f010314b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010314b:	55                   	push   %ebp
f010314c:	89 e5                	mov    %esp,%ebp
f010314e:	57                   	push   %edi
f010314f:	56                   	push   %esi
f0103150:	53                   	push   %ebx
f0103151:	83 ec 14             	sub    $0x14,%esp
f0103154:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103157:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010315a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010315d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103160:	8b 32                	mov    (%edx),%esi
f0103162:	8b 01                	mov    (%ecx),%eax
f0103164:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103167:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
	
	while (l <= r) {
f010316e:	eb 2f                	jmp    f010319f <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103170:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0103173:	39 c6                	cmp    %eax,%esi
f0103175:	7f 49                	jg     f01031c0 <stab_binsearch+0x75>
f0103177:	0f b6 0a             	movzbl (%edx),%ecx
f010317a:	83 ea 0c             	sub    $0xc,%edx
f010317d:	39 f9                	cmp    %edi,%ecx
f010317f:	75 ef                	jne    f0103170 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103181:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103184:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103187:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010318b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010318e:	73 35                	jae    f01031c5 <stab_binsearch+0x7a>
			*region_left = m;
f0103190:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103193:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0103195:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0103198:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f010319f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01031a2:	7f 4e                	jg     f01031f2 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f01031a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01031a7:	01 f0                	add    %esi,%eax
f01031a9:	89 c3                	mov    %eax,%ebx
f01031ab:	c1 eb 1f             	shr    $0x1f,%ebx
f01031ae:	01 c3                	add    %eax,%ebx
f01031b0:	d1 fb                	sar    %ebx
f01031b2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01031b5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01031b8:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01031bc:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f01031be:	eb b3                	jmp    f0103173 <stab_binsearch+0x28>
			l = true_m + 1;
f01031c0:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f01031c3:	eb da                	jmp    f010319f <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f01031c5:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01031c8:	76 14                	jbe    f01031de <stab_binsearch+0x93>
			*region_right = m - 1;
f01031ca:	83 e8 01             	sub    $0x1,%eax
f01031cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01031d0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01031d3:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f01031d5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01031dc:	eb c1                	jmp    f010319f <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01031de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01031e1:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01031e3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01031e7:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01031e9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01031f0:	eb ad                	jmp    f010319f <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01031f2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01031f6:	74 16                	je     f010320e <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01031f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01031fb:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01031fd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103200:	8b 0e                	mov    (%esi),%ecx
f0103202:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103205:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103208:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f010320c:	eb 12                	jmp    f0103220 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f010320e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103211:	8b 00                	mov    (%eax),%eax
f0103213:	83 e8 01             	sub    $0x1,%eax
f0103216:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103219:	89 07                	mov    %eax,(%edi)
f010321b:	eb 16                	jmp    f0103233 <stab_binsearch+0xe8>
		     l--)
f010321d:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0103220:	39 c1                	cmp    %eax,%ecx
f0103222:	7d 0a                	jge    f010322e <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0103224:	0f b6 1a             	movzbl (%edx),%ebx
f0103227:	83 ea 0c             	sub    $0xc,%edx
f010322a:	39 fb                	cmp    %edi,%ebx
f010322c:	75 ef                	jne    f010321d <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f010322e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103231:	89 07                	mov    %eax,(%edi)
	}
}
f0103233:	83 c4 14             	add    $0x14,%esp
f0103236:	5b                   	pop    %ebx
f0103237:	5e                   	pop    %esi
f0103238:	5f                   	pop    %edi
f0103239:	5d                   	pop    %ebp
f010323a:	c3                   	ret    

f010323b <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010323b:	55                   	push   %ebp
f010323c:	89 e5                	mov    %esp,%ebp
f010323e:	57                   	push   %edi
f010323f:	56                   	push   %esi
f0103240:	53                   	push   %ebx
f0103241:	83 ec 3c             	sub    $0x3c,%esp
f0103244:	e8 6c cf ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0103249:	81 c3 bf 40 01 00    	add    $0x140bf,%ebx
f010324f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103252:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103255:	8d 83 1c df fe ff    	lea    -0x120e4(%ebx),%eax
f010325b:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f010325d:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0103264:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103267:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010326e:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0103271:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103278:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010327e:	0f 86 37 01 00 00    	jbe    f01033bb <debuginfo_eip+0x180>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103284:	c7 c0 bd be 10 f0    	mov    $0xf010bebd,%eax
f010328a:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0103290:	0f 86 04 02 00 00    	jbe    f010349a <debuginfo_eip+0x25f>
f0103296:	c7 c0 db dc 10 f0    	mov    $0xf010dcdb,%eax
f010329c:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01032a0:	0f 85 fb 01 00 00    	jne    f01034a1 <debuginfo_eip+0x266>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01032a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01032ad:	c7 c0 3c 54 10 f0    	mov    $0xf010543c,%eax
f01032b3:	c7 c2 bc be 10 f0    	mov    $0xf010bebc,%edx
f01032b9:	29 c2                	sub    %eax,%edx
f01032bb:	c1 fa 02             	sar    $0x2,%edx
f01032be:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01032c4:	83 ea 01             	sub    $0x1,%edx
f01032c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01032ca:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01032cd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01032d0:	83 ec 08             	sub    $0x8,%esp
f01032d3:	57                   	push   %edi
f01032d4:	6a 64                	push   $0x64
f01032d6:	e8 70 fe ff ff       	call   f010314b <stab_binsearch>
	if (lfile == 0)
f01032db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032de:	83 c4 10             	add    $0x10,%esp
f01032e1:	85 c0                	test   %eax,%eax
f01032e3:	0f 84 bf 01 00 00    	je     f01034a8 <debuginfo_eip+0x26d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01032e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01032ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01032f2:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01032f5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01032f8:	83 ec 08             	sub    $0x8,%esp
f01032fb:	57                   	push   %edi
f01032fc:	6a 24                	push   $0x24
f01032fe:	c7 c0 3c 54 10 f0    	mov    $0xf010543c,%eax
f0103304:	e8 42 fe ff ff       	call   f010314b <stab_binsearch>

	if (lfun <= rfun) {
f0103309:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010330c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010330f:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0103312:	83 c4 10             	add    $0x10,%esp
f0103315:	39 c8                	cmp    %ecx,%eax
f0103317:	0f 8f b6 00 00 00    	jg     f01033d3 <debuginfo_eip+0x198>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010331d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103320:	c7 c1 3c 54 10 f0    	mov    $0xf010543c,%ecx
f0103326:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0103329:	8b 11                	mov    (%ecx),%edx
f010332b:	89 55 c0             	mov    %edx,-0x40(%ebp)
f010332e:	c7 c2 db dc 10 f0    	mov    $0xf010dcdb,%edx
f0103334:	81 ea bd be 10 f0    	sub    $0xf010bebd,%edx
f010333a:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f010333d:	73 0c                	jae    f010334b <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010333f:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103342:	81 c2 bd be 10 f0    	add    $0xf010bebd,%edx
f0103348:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010334b:	8b 51 08             	mov    0x8(%ecx),%edx
f010334e:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0103351:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0103353:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103356:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103359:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010335c:	83 ec 08             	sub    $0x8,%esp
f010335f:	6a 3a                	push   $0x3a
f0103361:	ff 76 08             	pushl  0x8(%esi)
f0103364:	e8 1c 0a 00 00       	call   f0103d85 <strfind>
f0103369:	2b 46 08             	sub    0x8(%esi),%eax
f010336c:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010336f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103372:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103375:	83 c4 08             	add    $0x8,%esp
f0103378:	57                   	push   %edi
f0103379:	6a 44                	push   $0x44
f010337b:	c7 c0 3c 54 10 f0    	mov    $0xf010543c,%eax
f0103381:	e8 c5 fd ff ff       	call   f010314b <stab_binsearch>
	if(lline > rline)
f0103386:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103389:	83 c4 10             	add    $0x10,%esp
f010338c:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f010338f:	0f 8f 1a 01 00 00    	jg     f01034af <debuginfo_eip+0x274>
		return -1;
	else
		info->eip_line = stabs[lline].n_desc;
f0103395:	89 d0                	mov    %edx,%eax
f0103397:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010339a:	c1 e2 02             	shl    $0x2,%edx
f010339d:	c7 c1 3c 54 10 f0    	mov    $0xf010543c,%ecx
f01033a3:	0f b7 7c 0a 06       	movzwl 0x6(%edx,%ecx,1),%edi
f01033a8:	89 7e 04             	mov    %edi,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01033ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01033ae:	8d 54 0a 04          	lea    0x4(%edx,%ecx,1),%edx
f01033b2:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01033b6:	89 75 0c             	mov    %esi,0xc(%ebp)
f01033b9:	eb 36                	jmp    f01033f1 <debuginfo_eip+0x1b6>
  	        panic("User address");
f01033bb:	83 ec 04             	sub    $0x4,%esp
f01033be:	8d 83 26 df fe ff    	lea    -0x120da(%ebx),%eax
f01033c4:	50                   	push   %eax
f01033c5:	6a 7f                	push   $0x7f
f01033c7:	8d 83 33 df fe ff    	lea    -0x120cd(%ebx),%eax
f01033cd:	50                   	push   %eax
f01033ce:	e8 2c cd ff ff       	call   f01000ff <_panic>
		info->eip_fn_addr = addr;
f01033d3:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f01033d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01033dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033df:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01033e2:	e9 75 ff ff ff       	jmp    f010335c <debuginfo_eip+0x121>
f01033e7:	83 e8 01             	sub    $0x1,%eax
f01033ea:	83 ea 0c             	sub    $0xc,%edx
f01033ed:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01033f1:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f01033f4:	39 c7                	cmp    %eax,%edi
f01033f6:	7f 24                	jg     f010341c <debuginfo_eip+0x1e1>
	       && stabs[lline].n_type != N_SOL
f01033f8:	0f b6 0a             	movzbl (%edx),%ecx
f01033fb:	80 f9 84             	cmp    $0x84,%cl
f01033fe:	74 46                	je     f0103446 <debuginfo_eip+0x20b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103400:	80 f9 64             	cmp    $0x64,%cl
f0103403:	75 e2                	jne    f01033e7 <debuginfo_eip+0x1ac>
f0103405:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0103409:	74 dc                	je     f01033e7 <debuginfo_eip+0x1ac>
f010340b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010340e:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103412:	74 3b                	je     f010344f <debuginfo_eip+0x214>
f0103414:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103417:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010341a:	eb 33                	jmp    f010344f <debuginfo_eip+0x214>
f010341c:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010341f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103422:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103425:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f010342a:	39 fa                	cmp    %edi,%edx
f010342c:	0f 8d 89 00 00 00    	jge    f01034bb <debuginfo_eip+0x280>
		for (lline = lfun + 1;
f0103432:	83 c2 01             	add    $0x1,%edx
f0103435:	89 d0                	mov    %edx,%eax
f0103437:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f010343a:	c7 c2 3c 54 10 f0    	mov    $0xf010543c,%edx
f0103440:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0103444:	eb 3b                	jmp    f0103481 <debuginfo_eip+0x246>
f0103446:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103449:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010344d:	75 26                	jne    f0103475 <debuginfo_eip+0x23a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010344f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103452:	c7 c0 3c 54 10 f0    	mov    $0xf010543c,%eax
f0103458:	8b 14 90             	mov    (%eax,%edx,4),%edx
f010345b:	c7 c0 db dc 10 f0    	mov    $0xf010dcdb,%eax
f0103461:	81 e8 bd be 10 f0    	sub    $0xf010bebd,%eax
f0103467:	39 c2                	cmp    %eax,%edx
f0103469:	73 b4                	jae    f010341f <debuginfo_eip+0x1e4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010346b:	81 c2 bd be 10 f0    	add    $0xf010bebd,%edx
f0103471:	89 16                	mov    %edx,(%esi)
f0103473:	eb aa                	jmp    f010341f <debuginfo_eip+0x1e4>
f0103475:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103478:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010347b:	eb d2                	jmp    f010344f <debuginfo_eip+0x214>
			info->eip_fn_narg++;
f010347d:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0103481:	39 c7                	cmp    %eax,%edi
f0103483:	7e 31                	jle    f01034b6 <debuginfo_eip+0x27b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103485:	0f b6 0a             	movzbl (%edx),%ecx
f0103488:	83 c0 01             	add    $0x1,%eax
f010348b:	83 c2 0c             	add    $0xc,%edx
f010348e:	80 f9 a0             	cmp    $0xa0,%cl
f0103491:	74 ea                	je     f010347d <debuginfo_eip+0x242>
	return 0;
f0103493:	b8 00 00 00 00       	mov    $0x0,%eax
f0103498:	eb 21                	jmp    f01034bb <debuginfo_eip+0x280>
		return -1;
f010349a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010349f:	eb 1a                	jmp    f01034bb <debuginfo_eip+0x280>
f01034a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01034a6:	eb 13                	jmp    f01034bb <debuginfo_eip+0x280>
		return -1;
f01034a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01034ad:	eb 0c                	jmp    f01034bb <debuginfo_eip+0x280>
		return -1;
f01034af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01034b4:	eb 05                	jmp    f01034bb <debuginfo_eip+0x280>
	return 0;
f01034b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034be:	5b                   	pop    %ebx
f01034bf:	5e                   	pop    %esi
f01034c0:	5f                   	pop    %edi
f01034c1:	5d                   	pop    %ebp
f01034c2:	c3                   	ret    

f01034c3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01034c3:	55                   	push   %ebp
f01034c4:	89 e5                	mov    %esp,%ebp
f01034c6:	57                   	push   %edi
f01034c7:	56                   	push   %esi
f01034c8:	53                   	push   %ebx
f01034c9:	83 ec 2c             	sub    $0x2c,%esp
f01034cc:	e8 d3 fb ff ff       	call   f01030a4 <__x86.get_pc_thunk.cx>
f01034d1:	81 c1 37 3e 01 00    	add    $0x13e37,%ecx
f01034d7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01034da:	89 c7                	mov    %eax,%edi
f01034dc:	89 d6                	mov    %edx,%esi
f01034de:	8b 45 08             	mov    0x8(%ebp),%eax
f01034e1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01034e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01034ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01034ed:	bb 00 00 00 00       	mov    $0x0,%ebx
f01034f2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f01034f5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f01034f8:	39 d3                	cmp    %edx,%ebx
f01034fa:	72 09                	jb     f0103505 <printnum+0x42>
f01034fc:	39 45 10             	cmp    %eax,0x10(%ebp)
f01034ff:	0f 87 83 00 00 00    	ja     f0103588 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103505:	83 ec 0c             	sub    $0xc,%esp
f0103508:	ff 75 18             	pushl  0x18(%ebp)
f010350b:	8b 45 14             	mov    0x14(%ebp),%eax
f010350e:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103511:	53                   	push   %ebx
f0103512:	ff 75 10             	pushl  0x10(%ebp)
f0103515:	83 ec 08             	sub    $0x8,%esp
f0103518:	ff 75 dc             	pushl  -0x24(%ebp)
f010351b:	ff 75 d8             	pushl  -0x28(%ebp)
f010351e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103521:	ff 75 d0             	pushl  -0x30(%ebp)
f0103524:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103527:	e8 74 0a 00 00       	call   f0103fa0 <__udivdi3>
f010352c:	83 c4 18             	add    $0x18,%esp
f010352f:	52                   	push   %edx
f0103530:	50                   	push   %eax
f0103531:	89 f2                	mov    %esi,%edx
f0103533:	89 f8                	mov    %edi,%eax
f0103535:	e8 89 ff ff ff       	call   f01034c3 <printnum>
f010353a:	83 c4 20             	add    $0x20,%esp
f010353d:	eb 13                	jmp    f0103552 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010353f:	83 ec 08             	sub    $0x8,%esp
f0103542:	56                   	push   %esi
f0103543:	ff 75 18             	pushl  0x18(%ebp)
f0103546:	ff d7                	call   *%edi
f0103548:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010354b:	83 eb 01             	sub    $0x1,%ebx
f010354e:	85 db                	test   %ebx,%ebx
f0103550:	7f ed                	jg     f010353f <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103552:	83 ec 08             	sub    $0x8,%esp
f0103555:	56                   	push   %esi
f0103556:	83 ec 04             	sub    $0x4,%esp
f0103559:	ff 75 dc             	pushl  -0x24(%ebp)
f010355c:	ff 75 d8             	pushl  -0x28(%ebp)
f010355f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103562:	ff 75 d0             	pushl  -0x30(%ebp)
f0103565:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103568:	89 f3                	mov    %esi,%ebx
f010356a:	e8 51 0b 00 00       	call   f01040c0 <__umoddi3>
f010356f:	83 c4 14             	add    $0x14,%esp
f0103572:	0f be 84 06 41 df fe 	movsbl -0x120bf(%esi,%eax,1),%eax
f0103579:	ff 
f010357a:	50                   	push   %eax
f010357b:	ff d7                	call   *%edi
}
f010357d:	83 c4 10             	add    $0x10,%esp
f0103580:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103583:	5b                   	pop    %ebx
f0103584:	5e                   	pop    %esi
f0103585:	5f                   	pop    %edi
f0103586:	5d                   	pop    %ebp
f0103587:	c3                   	ret    
f0103588:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010358b:	eb be                	jmp    f010354b <printnum+0x88>

f010358d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010358d:	55                   	push   %ebp
f010358e:	89 e5                	mov    %esp,%ebp
f0103590:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103593:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103597:	8b 10                	mov    (%eax),%edx
f0103599:	3b 50 04             	cmp    0x4(%eax),%edx
f010359c:	73 0a                	jae    f01035a8 <sprintputch+0x1b>
		*b->buf++ = ch;
f010359e:	8d 4a 01             	lea    0x1(%edx),%ecx
f01035a1:	89 08                	mov    %ecx,(%eax)
f01035a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01035a6:	88 02                	mov    %al,(%edx)
}
f01035a8:	5d                   	pop    %ebp
f01035a9:	c3                   	ret    

f01035aa <printfmt>:
{
f01035aa:	55                   	push   %ebp
f01035ab:	89 e5                	mov    %esp,%ebp
f01035ad:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01035b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01035b3:	50                   	push   %eax
f01035b4:	ff 75 10             	pushl  0x10(%ebp)
f01035b7:	ff 75 0c             	pushl  0xc(%ebp)
f01035ba:	ff 75 08             	pushl  0x8(%ebp)
f01035bd:	e8 05 00 00 00       	call   f01035c7 <vprintfmt>
}
f01035c2:	83 c4 10             	add    $0x10,%esp
f01035c5:	c9                   	leave  
f01035c6:	c3                   	ret    

f01035c7 <vprintfmt>:
{
f01035c7:	55                   	push   %ebp
f01035c8:	89 e5                	mov    %esp,%ebp
f01035ca:	57                   	push   %edi
f01035cb:	56                   	push   %esi
f01035cc:	53                   	push   %ebx
f01035cd:	83 ec 3c             	sub    $0x3c,%esp
f01035d0:	e8 e0 cb ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f01035d5:	81 c3 33 3d 01 00    	add    $0x13d33,%ebx
f01035db:	8b 75 0c             	mov    0xc(%ebp),%esi
f01035de:	8b 7d 10             	mov    0x10(%ebp),%edi
			csa = num;
f01035e1:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01035e7:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01035ea:	e9 d7 03 00 00       	jmp    f01039c6 <.L36+0x48>
				csa = 0x0700;
f01035ef:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01035f5:	c7 00 00 07 00 00    	movl   $0x700,(%eax)
}
f01035fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035fe:	5b                   	pop    %ebx
f01035ff:	5e                   	pop    %esi
f0103600:	5f                   	pop    %edi
f0103601:	5d                   	pop    %ebp
f0103602:	c3                   	ret    
		padc = ' ';
f0103603:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0103607:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f010360e:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0103615:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010361c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103621:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103624:	8d 47 01             	lea    0x1(%edi),%eax
f0103627:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010362a:	0f b6 17             	movzbl (%edi),%edx
f010362d:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103630:	3c 55                	cmp    $0x55,%al
f0103632:	0f 87 5a 04 00 00    	ja     f0103a92 <.L22>
f0103638:	0f b6 c0             	movzbl %al,%eax
f010363b:	89 d9                	mov    %ebx,%ecx
f010363d:	03 8c 83 cc df fe ff 	add    -0x12034(%ebx,%eax,4),%ecx
f0103644:	ff e1                	jmp    *%ecx

f0103646 <.L73>:
f0103646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0103649:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010364d:	eb d5                	jmp    f0103624 <vprintfmt+0x5d>

f010364f <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f010364f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0103652:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103656:	eb cc                	jmp    f0103624 <vprintfmt+0x5d>

f0103658 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0103658:	0f b6 d2             	movzbl %dl,%edx
f010365b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010365e:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0103663:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103666:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010366a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010366d:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103670:	83 f9 09             	cmp    $0x9,%ecx
f0103673:	77 55                	ja     f01036ca <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0103675:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0103678:	eb e9                	jmp    f0103663 <.L29+0xb>

f010367a <.L26>:
			precision = va_arg(ap, int);
f010367a:	8b 45 14             	mov    0x14(%ebp),%eax
f010367d:	8b 00                	mov    (%eax),%eax
f010367f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103682:	8b 45 14             	mov    0x14(%ebp),%eax
f0103685:	8d 40 04             	lea    0x4(%eax),%eax
f0103688:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010368b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010368e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103692:	79 90                	jns    f0103624 <vprintfmt+0x5d>
				width = precision, precision = -1;
f0103694:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103697:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010369a:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f01036a1:	eb 81                	jmp    f0103624 <vprintfmt+0x5d>

f01036a3 <.L27>:
f01036a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036a6:	85 c0                	test   %eax,%eax
f01036a8:	ba 00 00 00 00       	mov    $0x0,%edx
f01036ad:	0f 49 d0             	cmovns %eax,%edx
f01036b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01036b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01036b6:	e9 69 ff ff ff       	jmp    f0103624 <vprintfmt+0x5d>

f01036bb <.L23>:
f01036bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01036be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01036c5:	e9 5a ff ff ff       	jmp    f0103624 <vprintfmt+0x5d>
f01036ca:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01036cd:	eb bf                	jmp    f010368e <.L26+0x14>

f01036cf <.L33>:
			lflag++;
f01036cf:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01036d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01036d6:	e9 49 ff ff ff       	jmp    f0103624 <vprintfmt+0x5d>

f01036db <.L30>:
			putch(va_arg(ap, int), putdat);
f01036db:	8b 45 14             	mov    0x14(%ebp),%eax
f01036de:	8d 78 04             	lea    0x4(%eax),%edi
f01036e1:	83 ec 08             	sub    $0x8,%esp
f01036e4:	56                   	push   %esi
f01036e5:	ff 30                	pushl  (%eax)
f01036e7:	ff 55 08             	call   *0x8(%ebp)
			break;
f01036ea:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01036ed:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01036f0:	e9 ce 02 00 00       	jmp    f01039c3 <.L36+0x45>

f01036f5 <.L32>:
			err = va_arg(ap, int);
f01036f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01036f8:	8d 78 04             	lea    0x4(%eax),%edi
f01036fb:	8b 00                	mov    (%eax),%eax
f01036fd:	99                   	cltd   
f01036fe:	31 d0                	xor    %edx,%eax
f0103700:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103702:	83 f8 06             	cmp    $0x6,%eax
f0103705:	7f 27                	jg     f010372e <.L32+0x39>
f0103707:	8b 94 83 20 1d 00 00 	mov    0x1d20(%ebx,%eax,4),%edx
f010370e:	85 d2                	test   %edx,%edx
f0103710:	74 1c                	je     f010372e <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0103712:	52                   	push   %edx
f0103713:	8d 83 55 d4 fe ff    	lea    -0x12bab(%ebx),%eax
f0103719:	50                   	push   %eax
f010371a:	56                   	push   %esi
f010371b:	ff 75 08             	pushl  0x8(%ebp)
f010371e:	e8 87 fe ff ff       	call   f01035aa <printfmt>
f0103723:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103726:	89 7d 14             	mov    %edi,0x14(%ebp)
f0103729:	e9 95 02 00 00       	jmp    f01039c3 <.L36+0x45>
				printfmt(putch, putdat, "error %d", err);
f010372e:	50                   	push   %eax
f010372f:	8d 83 59 df fe ff    	lea    -0x120a7(%ebx),%eax
f0103735:	50                   	push   %eax
f0103736:	56                   	push   %esi
f0103737:	ff 75 08             	pushl  0x8(%ebp)
f010373a:	e8 6b fe ff ff       	call   f01035aa <printfmt>
f010373f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103742:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103745:	e9 79 02 00 00       	jmp    f01039c3 <.L36+0x45>

f010374a <.L37>:
			if ((p = va_arg(ap, char *)) == NULL)
f010374a:	8b 45 14             	mov    0x14(%ebp),%eax
f010374d:	83 c0 04             	add    $0x4,%eax
f0103750:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103753:	8b 45 14             	mov    0x14(%ebp),%eax
f0103756:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103758:	85 ff                	test   %edi,%edi
f010375a:	8d 83 52 df fe ff    	lea    -0x120ae(%ebx),%eax
f0103760:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103763:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103767:	0f 8e b5 00 00 00    	jle    f0103822 <.L37+0xd8>
f010376d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103771:	75 08                	jne    f010377b <.L37+0x31>
f0103773:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103776:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0103779:	eb 6d                	jmp    f01037e8 <.L37+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f010377b:	83 ec 08             	sub    $0x8,%esp
f010377e:	ff 75 cc             	pushl  -0x34(%ebp)
f0103781:	57                   	push   %edi
f0103782:	e8 ba 04 00 00       	call   f0103c41 <strnlen>
f0103787:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010378a:	29 c2                	sub    %eax,%edx
f010378c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010378f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103792:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103796:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103799:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010379c:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f010379e:	eb 10                	jmp    f01037b0 <.L37+0x66>
					putch(padc, putdat);
f01037a0:	83 ec 08             	sub    $0x8,%esp
f01037a3:	56                   	push   %esi
f01037a4:	ff 75 e0             	pushl  -0x20(%ebp)
f01037a7:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01037aa:	83 ef 01             	sub    $0x1,%edi
f01037ad:	83 c4 10             	add    $0x10,%esp
f01037b0:	85 ff                	test   %edi,%edi
f01037b2:	7f ec                	jg     f01037a0 <.L37+0x56>
f01037b4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01037b7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01037ba:	85 d2                	test   %edx,%edx
f01037bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01037c1:	0f 49 c2             	cmovns %edx,%eax
f01037c4:	29 c2                	sub    %eax,%edx
f01037c6:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01037c9:	89 75 0c             	mov    %esi,0xc(%ebp)
f01037cc:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01037cf:	eb 17                	jmp    f01037e8 <.L37+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f01037d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01037d5:	75 30                	jne    f0103807 <.L37+0xbd>
					putch(ch, putdat);
f01037d7:	83 ec 08             	sub    $0x8,%esp
f01037da:	ff 75 0c             	pushl  0xc(%ebp)
f01037dd:	50                   	push   %eax
f01037de:	ff 55 08             	call   *0x8(%ebp)
f01037e1:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01037e4:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01037e8:	83 c7 01             	add    $0x1,%edi
f01037eb:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01037ef:	0f be c2             	movsbl %dl,%eax
f01037f2:	85 c0                	test   %eax,%eax
f01037f4:	74 52                	je     f0103848 <.L37+0xfe>
f01037f6:	85 f6                	test   %esi,%esi
f01037f8:	78 d7                	js     f01037d1 <.L37+0x87>
f01037fa:	83 ee 01             	sub    $0x1,%esi
f01037fd:	79 d2                	jns    f01037d1 <.L37+0x87>
f01037ff:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103802:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103805:	eb 32                	jmp    f0103839 <.L37+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f0103807:	0f be d2             	movsbl %dl,%edx
f010380a:	83 ea 20             	sub    $0x20,%edx
f010380d:	83 fa 5e             	cmp    $0x5e,%edx
f0103810:	76 c5                	jbe    f01037d7 <.L37+0x8d>
					putch('?', putdat);
f0103812:	83 ec 08             	sub    $0x8,%esp
f0103815:	ff 75 0c             	pushl  0xc(%ebp)
f0103818:	6a 3f                	push   $0x3f
f010381a:	ff 55 08             	call   *0x8(%ebp)
f010381d:	83 c4 10             	add    $0x10,%esp
f0103820:	eb c2                	jmp    f01037e4 <.L37+0x9a>
f0103822:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103825:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0103828:	eb be                	jmp    f01037e8 <.L37+0x9e>
				putch(' ', putdat);
f010382a:	83 ec 08             	sub    $0x8,%esp
f010382d:	56                   	push   %esi
f010382e:	6a 20                	push   $0x20
f0103830:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0103833:	83 ef 01             	sub    $0x1,%edi
f0103836:	83 c4 10             	add    $0x10,%esp
f0103839:	85 ff                	test   %edi,%edi
f010383b:	7f ed                	jg     f010382a <.L37+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f010383d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103840:	89 45 14             	mov    %eax,0x14(%ebp)
f0103843:	e9 7b 01 00 00       	jmp    f01039c3 <.L36+0x45>
f0103848:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010384b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010384e:	eb e9                	jmp    f0103839 <.L37+0xef>

f0103850 <.L31>:
f0103850:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0103853:	83 f9 01             	cmp    $0x1,%ecx
f0103856:	7e 40                	jle    f0103898 <.L31+0x48>
		return va_arg(*ap, long long);
f0103858:	8b 45 14             	mov    0x14(%ebp),%eax
f010385b:	8b 50 04             	mov    0x4(%eax),%edx
f010385e:	8b 00                	mov    (%eax),%eax
f0103860:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103863:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103866:	8b 45 14             	mov    0x14(%ebp),%eax
f0103869:	8d 40 08             	lea    0x8(%eax),%eax
f010386c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010386f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103873:	79 55                	jns    f01038ca <.L31+0x7a>
				putch('-', putdat);
f0103875:	83 ec 08             	sub    $0x8,%esp
f0103878:	56                   	push   %esi
f0103879:	6a 2d                	push   $0x2d
f010387b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010387e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103881:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103884:	f7 da                	neg    %edx
f0103886:	83 d1 00             	adc    $0x0,%ecx
f0103889:	f7 d9                	neg    %ecx
f010388b:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010388e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103893:	e9 10 01 00 00       	jmp    f01039a8 <.L36+0x2a>
	else if (lflag)
f0103898:	85 c9                	test   %ecx,%ecx
f010389a:	75 17                	jne    f01038b3 <.L31+0x63>
		return va_arg(*ap, int);
f010389c:	8b 45 14             	mov    0x14(%ebp),%eax
f010389f:	8b 00                	mov    (%eax),%eax
f01038a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01038a4:	99                   	cltd   
f01038a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01038a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01038ab:	8d 40 04             	lea    0x4(%eax),%eax
f01038ae:	89 45 14             	mov    %eax,0x14(%ebp)
f01038b1:	eb bc                	jmp    f010386f <.L31+0x1f>
		return va_arg(*ap, long);
f01038b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01038b6:	8b 00                	mov    (%eax),%eax
f01038b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01038bb:	99                   	cltd   
f01038bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01038bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01038c2:	8d 40 04             	lea    0x4(%eax),%eax
f01038c5:	89 45 14             	mov    %eax,0x14(%ebp)
f01038c8:	eb a5                	jmp    f010386f <.L31+0x1f>
			num = getint(&ap, lflag);
f01038ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01038cd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01038d0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01038d5:	e9 ce 00 00 00       	jmp    f01039a8 <.L36+0x2a>

f01038da <.L38>:
f01038da:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01038dd:	83 f9 01             	cmp    $0x1,%ecx
f01038e0:	7e 18                	jle    f01038fa <.L38+0x20>
		return va_arg(*ap, unsigned long long);
f01038e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01038e5:	8b 10                	mov    (%eax),%edx
f01038e7:	8b 48 04             	mov    0x4(%eax),%ecx
f01038ea:	8d 40 08             	lea    0x8(%eax),%eax
f01038ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01038f0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01038f5:	e9 ae 00 00 00       	jmp    f01039a8 <.L36+0x2a>
	else if (lflag)
f01038fa:	85 c9                	test   %ecx,%ecx
f01038fc:	75 1a                	jne    f0103918 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
f01038fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0103901:	8b 10                	mov    (%eax),%edx
f0103903:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103908:	8d 40 04             	lea    0x4(%eax),%eax
f010390b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010390e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103913:	e9 90 00 00 00       	jmp    f01039a8 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f0103918:	8b 45 14             	mov    0x14(%ebp),%eax
f010391b:	8b 10                	mov    (%eax),%edx
f010391d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103922:	8d 40 04             	lea    0x4(%eax),%eax
f0103925:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103928:	b8 0a 00 00 00       	mov    $0xa,%eax
f010392d:	eb 79                	jmp    f01039a8 <.L36+0x2a>

f010392f <.L35>:
f010392f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0103932:	83 f9 01             	cmp    $0x1,%ecx
f0103935:	7e 15                	jle    f010394c <.L35+0x1d>
		return va_arg(*ap, unsigned long long);
f0103937:	8b 45 14             	mov    0x14(%ebp),%eax
f010393a:	8b 10                	mov    (%eax),%edx
f010393c:	8b 48 04             	mov    0x4(%eax),%ecx
f010393f:	8d 40 08             	lea    0x8(%eax),%eax
f0103942:	89 45 14             	mov    %eax,0x14(%ebp)
      			base = 8;
f0103945:	b8 08 00 00 00       	mov    $0x8,%eax
f010394a:	eb 5c                	jmp    f01039a8 <.L36+0x2a>
	else if (lflag)
f010394c:	85 c9                	test   %ecx,%ecx
f010394e:	75 17                	jne    f0103967 <.L35+0x38>
		return va_arg(*ap, unsigned int);
f0103950:	8b 45 14             	mov    0x14(%ebp),%eax
f0103953:	8b 10                	mov    (%eax),%edx
f0103955:	b9 00 00 00 00       	mov    $0x0,%ecx
f010395a:	8d 40 04             	lea    0x4(%eax),%eax
f010395d:	89 45 14             	mov    %eax,0x14(%ebp)
      			base = 8;
f0103960:	b8 08 00 00 00       	mov    $0x8,%eax
f0103965:	eb 41                	jmp    f01039a8 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f0103967:	8b 45 14             	mov    0x14(%ebp),%eax
f010396a:	8b 10                	mov    (%eax),%edx
f010396c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103971:	8d 40 04             	lea    0x4(%eax),%eax
f0103974:	89 45 14             	mov    %eax,0x14(%ebp)
      			base = 8;
f0103977:	b8 08 00 00 00       	mov    $0x8,%eax
f010397c:	eb 2a                	jmp    f01039a8 <.L36+0x2a>

f010397e <.L36>:
			putch('0', putdat);
f010397e:	83 ec 08             	sub    $0x8,%esp
f0103981:	56                   	push   %esi
f0103982:	6a 30                	push   $0x30
f0103984:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103987:	83 c4 08             	add    $0x8,%esp
f010398a:	56                   	push   %esi
f010398b:	6a 78                	push   $0x78
f010398d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0103990:	8b 45 14             	mov    0x14(%ebp),%eax
f0103993:	8b 10                	mov    (%eax),%edx
f0103995:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010399a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010399d:	8d 40 04             	lea    0x4(%eax),%eax
f01039a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01039a3:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01039a8:	83 ec 0c             	sub    $0xc,%esp
f01039ab:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01039af:	57                   	push   %edi
f01039b0:	ff 75 e0             	pushl  -0x20(%ebp)
f01039b3:	50                   	push   %eax
f01039b4:	51                   	push   %ecx
f01039b5:	52                   	push   %edx
f01039b6:	89 f2                	mov    %esi,%edx
f01039b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01039bb:	e8 03 fb ff ff       	call   f01034c3 <printnum>
			break;
f01039c0:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01039c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01039c6:	83 c7 01             	add    $0x1,%edi
f01039c9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01039cd:	83 f8 25             	cmp    $0x25,%eax
f01039d0:	0f 84 2d fc ff ff    	je     f0103603 <vprintfmt+0x3c>
			if (ch == '\0'){
f01039d6:	85 c0                	test   %eax,%eax
f01039d8:	0f 84 11 fc ff ff    	je     f01035ef <vprintfmt+0x28>
			putch(ch, putdat);
f01039de:	83 ec 08             	sub    $0x8,%esp
f01039e1:	56                   	push   %esi
f01039e2:	50                   	push   %eax
f01039e3:	ff 55 08             	call   *0x8(%ebp)
f01039e6:	83 c4 10             	add    $0x10,%esp
f01039e9:	eb db                	jmp    f01039c6 <.L36+0x48>

f01039eb <.L39>:
f01039eb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01039ee:	83 f9 01             	cmp    $0x1,%ecx
f01039f1:	7e 15                	jle    f0103a08 <.L39+0x1d>
		return va_arg(*ap, unsigned long long);
f01039f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01039f6:	8b 10                	mov    (%eax),%edx
f01039f8:	8b 48 04             	mov    0x4(%eax),%ecx
f01039fb:	8d 40 08             	lea    0x8(%eax),%eax
f01039fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103a01:	b8 10 00 00 00       	mov    $0x10,%eax
f0103a06:	eb a0                	jmp    f01039a8 <.L36+0x2a>
	else if (lflag)
f0103a08:	85 c9                	test   %ecx,%ecx
f0103a0a:	75 17                	jne    f0103a23 <.L39+0x38>
		return va_arg(*ap, unsigned int);
f0103a0c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a0f:	8b 10                	mov    (%eax),%edx
f0103a11:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103a16:	8d 40 04             	lea    0x4(%eax),%eax
f0103a19:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103a1c:	b8 10 00 00 00       	mov    $0x10,%eax
f0103a21:	eb 85                	jmp    f01039a8 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f0103a23:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a26:	8b 10                	mov    (%eax),%edx
f0103a28:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103a2d:	8d 40 04             	lea    0x4(%eax),%eax
f0103a30:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103a33:	b8 10 00 00 00       	mov    $0x10,%eax
f0103a38:	e9 6b ff ff ff       	jmp    f01039a8 <.L36+0x2a>

f0103a3d <.L25>:
			putch(ch, putdat);
f0103a3d:	83 ec 08             	sub    $0x8,%esp
f0103a40:	56                   	push   %esi
f0103a41:	6a 25                	push   $0x25
f0103a43:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103a46:	83 c4 10             	add    $0x10,%esp
f0103a49:	e9 75 ff ff ff       	jmp    f01039c3 <.L36+0x45>

f0103a4e <.L34>:
f0103a4e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0103a51:	83 f9 01             	cmp    $0x1,%ecx
f0103a54:	7e 18                	jle    f0103a6e <.L34+0x20>
		return va_arg(*ap, long long);
f0103a56:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a59:	8b 00                	mov    (%eax),%eax
f0103a5b:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103a5e:	8d 49 08             	lea    0x8(%ecx),%ecx
f0103a61:	89 4d 14             	mov    %ecx,0x14(%ebp)
			csa = num;
f0103a64:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103a67:	89 01                	mov    %eax,(%ecx)
			break;
f0103a69:	e9 55 ff ff ff       	jmp    f01039c3 <.L36+0x45>
	else if (lflag)
f0103a6e:	85 c9                	test   %ecx,%ecx
f0103a70:	75 10                	jne    f0103a82 <.L34+0x34>
		return va_arg(*ap, int);
f0103a72:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a75:	8b 00                	mov    (%eax),%eax
f0103a77:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103a7a:	8d 49 04             	lea    0x4(%ecx),%ecx
f0103a7d:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103a80:	eb e2                	jmp    f0103a64 <.L34+0x16>
		return va_arg(*ap, long);
f0103a82:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a85:	8b 00                	mov    (%eax),%eax
f0103a87:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103a8a:	8d 49 04             	lea    0x4(%ecx),%ecx
f0103a8d:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103a90:	eb d2                	jmp    f0103a64 <.L34+0x16>

f0103a92 <.L22>:
			putch('%', putdat);
f0103a92:	83 ec 08             	sub    $0x8,%esp
f0103a95:	56                   	push   %esi
f0103a96:	6a 25                	push   $0x25
f0103a98:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103a9b:	83 c4 10             	add    $0x10,%esp
f0103a9e:	89 f8                	mov    %edi,%eax
f0103aa0:	eb 03                	jmp    f0103aa5 <.L22+0x13>
f0103aa2:	83 e8 01             	sub    $0x1,%eax
f0103aa5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0103aa9:	75 f7                	jne    f0103aa2 <.L22+0x10>
f0103aab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103aae:	e9 10 ff ff ff       	jmp    f01039c3 <.L36+0x45>

f0103ab3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103ab3:	55                   	push   %ebp
f0103ab4:	89 e5                	mov    %esp,%ebp
f0103ab6:	53                   	push   %ebx
f0103ab7:	83 ec 14             	sub    $0x14,%esp
f0103aba:	e8 f6 c6 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0103abf:	81 c3 49 38 01 00    	add    $0x13849,%ebx
f0103ac5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ac8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103acb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ace:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103ad2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103ad5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103adc:	85 c0                	test   %eax,%eax
f0103ade:	74 2b                	je     f0103b0b <vsnprintf+0x58>
f0103ae0:	85 d2                	test   %edx,%edx
f0103ae2:	7e 27                	jle    f0103b0b <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103ae4:	ff 75 14             	pushl  0x14(%ebp)
f0103ae7:	ff 75 10             	pushl  0x10(%ebp)
f0103aea:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103aed:	50                   	push   %eax
f0103aee:	8d 83 85 c2 fe ff    	lea    -0x13d7b(%ebx),%eax
f0103af4:	50                   	push   %eax
f0103af5:	e8 cd fa ff ff       	call   f01035c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103afa:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103afd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b03:	83 c4 10             	add    $0x10,%esp
}
f0103b06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b09:	c9                   	leave  
f0103b0a:	c3                   	ret    
		return -E_INVAL;
f0103b0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103b10:	eb f4                	jmp    f0103b06 <vsnprintf+0x53>

f0103b12 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103b12:	55                   	push   %ebp
f0103b13:	89 e5                	mov    %esp,%ebp
f0103b15:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103b18:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103b1b:	50                   	push   %eax
f0103b1c:	ff 75 10             	pushl  0x10(%ebp)
f0103b1f:	ff 75 0c             	pushl  0xc(%ebp)
f0103b22:	ff 75 08             	pushl  0x8(%ebp)
f0103b25:	e8 89 ff ff ff       	call   f0103ab3 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103b2a:	c9                   	leave  
f0103b2b:	c3                   	ret    

f0103b2c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103b2c:	55                   	push   %ebp
f0103b2d:	89 e5                	mov    %esp,%ebp
f0103b2f:	57                   	push   %edi
f0103b30:	56                   	push   %esi
f0103b31:	53                   	push   %ebx
f0103b32:	83 ec 1c             	sub    $0x1c,%esp
f0103b35:	e8 7b c6 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0103b3a:	81 c3 ce 37 01 00    	add    $0x137ce,%ebx
f0103b40:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103b43:	85 c0                	test   %eax,%eax
f0103b45:	74 13                	je     f0103b5a <readline+0x2e>
		cprintf("%s", prompt);
f0103b47:	83 ec 08             	sub    $0x8,%esp
f0103b4a:	50                   	push   %eax
f0103b4b:	8d 83 55 d4 fe ff    	lea    -0x12bab(%ebx),%eax
f0103b51:	50                   	push   %eax
f0103b52:	e8 e0 f5 ff ff       	call   f0103137 <cprintf>
f0103b57:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103b5a:	83 ec 0c             	sub    $0xc,%esp
f0103b5d:	6a 00                	push   $0x0
f0103b5f:	e8 fb cb ff ff       	call   f010075f <iscons>
f0103b64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103b67:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103b6a:	bf 00 00 00 00       	mov    $0x0,%edi
f0103b6f:	eb 46                	jmp    f0103bb7 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0103b71:	83 ec 08             	sub    $0x8,%esp
f0103b74:	50                   	push   %eax
f0103b75:	8d 83 24 e1 fe ff    	lea    -0x11edc(%ebx),%eax
f0103b7b:	50                   	push   %eax
f0103b7c:	e8 b6 f5 ff ff       	call   f0103137 <cprintf>
			return NULL;
f0103b81:	83 c4 10             	add    $0x10,%esp
f0103b84:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b8c:	5b                   	pop    %ebx
f0103b8d:	5e                   	pop    %esi
f0103b8e:	5f                   	pop    %edi
f0103b8f:	5d                   	pop    %ebp
f0103b90:	c3                   	ret    
			if (echoing)
f0103b91:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103b95:	75 05                	jne    f0103b9c <readline+0x70>
			i--;
f0103b97:	83 ef 01             	sub    $0x1,%edi
f0103b9a:	eb 1b                	jmp    f0103bb7 <readline+0x8b>
				cputchar('\b');
f0103b9c:	83 ec 0c             	sub    $0xc,%esp
f0103b9f:	6a 08                	push   $0x8
f0103ba1:	e8 98 cb ff ff       	call   f010073e <cputchar>
f0103ba6:	83 c4 10             	add    $0x10,%esp
f0103ba9:	eb ec                	jmp    f0103b97 <readline+0x6b>
			buf[i++] = c;
f0103bab:	89 f0                	mov    %esi,%eax
f0103bad:	88 84 3b b8 1f 00 00 	mov    %al,0x1fb8(%ebx,%edi,1)
f0103bb4:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0103bb7:	e8 92 cb ff ff       	call   f010074e <getchar>
f0103bbc:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0103bbe:	85 c0                	test   %eax,%eax
f0103bc0:	78 af                	js     f0103b71 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103bc2:	83 f8 08             	cmp    $0x8,%eax
f0103bc5:	0f 94 c2             	sete   %dl
f0103bc8:	83 f8 7f             	cmp    $0x7f,%eax
f0103bcb:	0f 94 c0             	sete   %al
f0103bce:	08 c2                	or     %al,%dl
f0103bd0:	74 04                	je     f0103bd6 <readline+0xaa>
f0103bd2:	85 ff                	test   %edi,%edi
f0103bd4:	7f bb                	jg     f0103b91 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103bd6:	83 fe 1f             	cmp    $0x1f,%esi
f0103bd9:	7e 1c                	jle    f0103bf7 <readline+0xcb>
f0103bdb:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0103be1:	7f 14                	jg     f0103bf7 <readline+0xcb>
			if (echoing)
f0103be3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103be7:	74 c2                	je     f0103bab <readline+0x7f>
				cputchar(c);
f0103be9:	83 ec 0c             	sub    $0xc,%esp
f0103bec:	56                   	push   %esi
f0103bed:	e8 4c cb ff ff       	call   f010073e <cputchar>
f0103bf2:	83 c4 10             	add    $0x10,%esp
f0103bf5:	eb b4                	jmp    f0103bab <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0103bf7:	83 fe 0a             	cmp    $0xa,%esi
f0103bfa:	74 05                	je     f0103c01 <readline+0xd5>
f0103bfc:	83 fe 0d             	cmp    $0xd,%esi
f0103bff:	75 b6                	jne    f0103bb7 <readline+0x8b>
			if (echoing)
f0103c01:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103c05:	75 13                	jne    f0103c1a <readline+0xee>
			buf[i] = 0;
f0103c07:	c6 84 3b b8 1f 00 00 	movb   $0x0,0x1fb8(%ebx,%edi,1)
f0103c0e:	00 
			return buf;
f0103c0f:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0103c15:	e9 6f ff ff ff       	jmp    f0103b89 <readline+0x5d>
				cputchar('\n');
f0103c1a:	83 ec 0c             	sub    $0xc,%esp
f0103c1d:	6a 0a                	push   $0xa
f0103c1f:	e8 1a cb ff ff       	call   f010073e <cputchar>
f0103c24:	83 c4 10             	add    $0x10,%esp
f0103c27:	eb de                	jmp    f0103c07 <readline+0xdb>

f0103c29 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103c29:	55                   	push   %ebp
f0103c2a:	89 e5                	mov    %esp,%ebp
f0103c2c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103c2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c34:	eb 03                	jmp    f0103c39 <strlen+0x10>
		n++;
f0103c36:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103c39:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103c3d:	75 f7                	jne    f0103c36 <strlen+0xd>
	return n;
}
f0103c3f:	5d                   	pop    %ebp
f0103c40:	c3                   	ret    

f0103c41 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103c41:	55                   	push   %ebp
f0103c42:	89 e5                	mov    %esp,%ebp
f0103c44:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103c47:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103c4a:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c4f:	eb 03                	jmp    f0103c54 <strnlen+0x13>
		n++;
f0103c51:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103c54:	39 d0                	cmp    %edx,%eax
f0103c56:	74 06                	je     f0103c5e <strnlen+0x1d>
f0103c58:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103c5c:	75 f3                	jne    f0103c51 <strnlen+0x10>
	return n;
}
f0103c5e:	5d                   	pop    %ebp
f0103c5f:	c3                   	ret    

f0103c60 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103c60:	55                   	push   %ebp
f0103c61:	89 e5                	mov    %esp,%ebp
f0103c63:	53                   	push   %ebx
f0103c64:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103c6a:	89 c2                	mov    %eax,%edx
f0103c6c:	83 c1 01             	add    $0x1,%ecx
f0103c6f:	83 c2 01             	add    $0x1,%edx
f0103c72:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103c76:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103c79:	84 db                	test   %bl,%bl
f0103c7b:	75 ef                	jne    f0103c6c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103c7d:	5b                   	pop    %ebx
f0103c7e:	5d                   	pop    %ebp
f0103c7f:	c3                   	ret    

f0103c80 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103c80:	55                   	push   %ebp
f0103c81:	89 e5                	mov    %esp,%ebp
f0103c83:	53                   	push   %ebx
f0103c84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103c87:	53                   	push   %ebx
f0103c88:	e8 9c ff ff ff       	call   f0103c29 <strlen>
f0103c8d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103c90:	ff 75 0c             	pushl  0xc(%ebp)
f0103c93:	01 d8                	add    %ebx,%eax
f0103c95:	50                   	push   %eax
f0103c96:	e8 c5 ff ff ff       	call   f0103c60 <strcpy>
	return dst;
}
f0103c9b:	89 d8                	mov    %ebx,%eax
f0103c9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ca0:	c9                   	leave  
f0103ca1:	c3                   	ret    

f0103ca2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103ca2:	55                   	push   %ebp
f0103ca3:	89 e5                	mov    %esp,%ebp
f0103ca5:	56                   	push   %esi
f0103ca6:	53                   	push   %ebx
f0103ca7:	8b 75 08             	mov    0x8(%ebp),%esi
f0103caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103cad:	89 f3                	mov    %esi,%ebx
f0103caf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103cb2:	89 f2                	mov    %esi,%edx
f0103cb4:	eb 0f                	jmp    f0103cc5 <strncpy+0x23>
		*dst++ = *src;
f0103cb6:	83 c2 01             	add    $0x1,%edx
f0103cb9:	0f b6 01             	movzbl (%ecx),%eax
f0103cbc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103cbf:	80 39 01             	cmpb   $0x1,(%ecx)
f0103cc2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0103cc5:	39 da                	cmp    %ebx,%edx
f0103cc7:	75 ed                	jne    f0103cb6 <strncpy+0x14>
	}
	return ret;
}
f0103cc9:	89 f0                	mov    %esi,%eax
f0103ccb:	5b                   	pop    %ebx
f0103ccc:	5e                   	pop    %esi
f0103ccd:	5d                   	pop    %ebp
f0103cce:	c3                   	ret    

f0103ccf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103ccf:	55                   	push   %ebp
f0103cd0:	89 e5                	mov    %esp,%ebp
f0103cd2:	56                   	push   %esi
f0103cd3:	53                   	push   %ebx
f0103cd4:	8b 75 08             	mov    0x8(%ebp),%esi
f0103cd7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103cda:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103cdd:	89 f0                	mov    %esi,%eax
f0103cdf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103ce3:	85 c9                	test   %ecx,%ecx
f0103ce5:	75 0b                	jne    f0103cf2 <strlcpy+0x23>
f0103ce7:	eb 17                	jmp    f0103d00 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103ce9:	83 c2 01             	add    $0x1,%edx
f0103cec:	83 c0 01             	add    $0x1,%eax
f0103cef:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0103cf2:	39 d8                	cmp    %ebx,%eax
f0103cf4:	74 07                	je     f0103cfd <strlcpy+0x2e>
f0103cf6:	0f b6 0a             	movzbl (%edx),%ecx
f0103cf9:	84 c9                	test   %cl,%cl
f0103cfb:	75 ec                	jne    f0103ce9 <strlcpy+0x1a>
		*dst = '\0';
f0103cfd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103d00:	29 f0                	sub    %esi,%eax
}
f0103d02:	5b                   	pop    %ebx
f0103d03:	5e                   	pop    %esi
f0103d04:	5d                   	pop    %ebp
f0103d05:	c3                   	ret    

f0103d06 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103d06:	55                   	push   %ebp
f0103d07:	89 e5                	mov    %esp,%ebp
f0103d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103d0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103d0f:	eb 06                	jmp    f0103d17 <strcmp+0x11>
		p++, q++;
f0103d11:	83 c1 01             	add    $0x1,%ecx
f0103d14:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0103d17:	0f b6 01             	movzbl (%ecx),%eax
f0103d1a:	84 c0                	test   %al,%al
f0103d1c:	74 04                	je     f0103d22 <strcmp+0x1c>
f0103d1e:	3a 02                	cmp    (%edx),%al
f0103d20:	74 ef                	je     f0103d11 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103d22:	0f b6 c0             	movzbl %al,%eax
f0103d25:	0f b6 12             	movzbl (%edx),%edx
f0103d28:	29 d0                	sub    %edx,%eax
}
f0103d2a:	5d                   	pop    %ebp
f0103d2b:	c3                   	ret    

f0103d2c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103d2c:	55                   	push   %ebp
f0103d2d:	89 e5                	mov    %esp,%ebp
f0103d2f:	53                   	push   %ebx
f0103d30:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d33:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d36:	89 c3                	mov    %eax,%ebx
f0103d38:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103d3b:	eb 06                	jmp    f0103d43 <strncmp+0x17>
		n--, p++, q++;
f0103d3d:	83 c0 01             	add    $0x1,%eax
f0103d40:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103d43:	39 d8                	cmp    %ebx,%eax
f0103d45:	74 16                	je     f0103d5d <strncmp+0x31>
f0103d47:	0f b6 08             	movzbl (%eax),%ecx
f0103d4a:	84 c9                	test   %cl,%cl
f0103d4c:	74 04                	je     f0103d52 <strncmp+0x26>
f0103d4e:	3a 0a                	cmp    (%edx),%cl
f0103d50:	74 eb                	je     f0103d3d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103d52:	0f b6 00             	movzbl (%eax),%eax
f0103d55:	0f b6 12             	movzbl (%edx),%edx
f0103d58:	29 d0                	sub    %edx,%eax
}
f0103d5a:	5b                   	pop    %ebx
f0103d5b:	5d                   	pop    %ebp
f0103d5c:	c3                   	ret    
		return 0;
f0103d5d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d62:	eb f6                	jmp    f0103d5a <strncmp+0x2e>

f0103d64 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103d64:	55                   	push   %ebp
f0103d65:	89 e5                	mov    %esp,%ebp
f0103d67:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d6a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103d6e:	0f b6 10             	movzbl (%eax),%edx
f0103d71:	84 d2                	test   %dl,%dl
f0103d73:	74 09                	je     f0103d7e <strchr+0x1a>
		if (*s == c)
f0103d75:	38 ca                	cmp    %cl,%dl
f0103d77:	74 0a                	je     f0103d83 <strchr+0x1f>
	for (; *s; s++)
f0103d79:	83 c0 01             	add    $0x1,%eax
f0103d7c:	eb f0                	jmp    f0103d6e <strchr+0xa>
			return (char *) s;
	return 0;
f0103d7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d83:	5d                   	pop    %ebp
f0103d84:	c3                   	ret    

f0103d85 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103d85:	55                   	push   %ebp
f0103d86:	89 e5                	mov    %esp,%ebp
f0103d88:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d8b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103d8f:	eb 03                	jmp    f0103d94 <strfind+0xf>
f0103d91:	83 c0 01             	add    $0x1,%eax
f0103d94:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103d97:	38 ca                	cmp    %cl,%dl
f0103d99:	74 04                	je     f0103d9f <strfind+0x1a>
f0103d9b:	84 d2                	test   %dl,%dl
f0103d9d:	75 f2                	jne    f0103d91 <strfind+0xc>
			break;
	return (char *) s;
}
f0103d9f:	5d                   	pop    %ebp
f0103da0:	c3                   	ret    

f0103da1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103da1:	55                   	push   %ebp
f0103da2:	89 e5                	mov    %esp,%ebp
f0103da4:	57                   	push   %edi
f0103da5:	56                   	push   %esi
f0103da6:	53                   	push   %ebx
f0103da7:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103daa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103dad:	85 c9                	test   %ecx,%ecx
f0103daf:	74 13                	je     f0103dc4 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103db1:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103db7:	75 05                	jne    f0103dbe <memset+0x1d>
f0103db9:	f6 c1 03             	test   $0x3,%cl
f0103dbc:	74 0d                	je     f0103dcb <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103dc1:	fc                   	cld    
f0103dc2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103dc4:	89 f8                	mov    %edi,%eax
f0103dc6:	5b                   	pop    %ebx
f0103dc7:	5e                   	pop    %esi
f0103dc8:	5f                   	pop    %edi
f0103dc9:	5d                   	pop    %ebp
f0103dca:	c3                   	ret    
		c &= 0xFF;
f0103dcb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103dcf:	89 d3                	mov    %edx,%ebx
f0103dd1:	c1 e3 08             	shl    $0x8,%ebx
f0103dd4:	89 d0                	mov    %edx,%eax
f0103dd6:	c1 e0 18             	shl    $0x18,%eax
f0103dd9:	89 d6                	mov    %edx,%esi
f0103ddb:	c1 e6 10             	shl    $0x10,%esi
f0103dde:	09 f0                	or     %esi,%eax
f0103de0:	09 c2                	or     %eax,%edx
f0103de2:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0103de4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103de7:	89 d0                	mov    %edx,%eax
f0103de9:	fc                   	cld    
f0103dea:	f3 ab                	rep stos %eax,%es:(%edi)
f0103dec:	eb d6                	jmp    f0103dc4 <memset+0x23>

f0103dee <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103dee:	55                   	push   %ebp
f0103def:	89 e5                	mov    %esp,%ebp
f0103df1:	57                   	push   %edi
f0103df2:	56                   	push   %esi
f0103df3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103df6:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103df9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103dfc:	39 c6                	cmp    %eax,%esi
f0103dfe:	73 35                	jae    f0103e35 <memmove+0x47>
f0103e00:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103e03:	39 c2                	cmp    %eax,%edx
f0103e05:	76 2e                	jbe    f0103e35 <memmove+0x47>
		s += n;
		d += n;
f0103e07:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103e0a:	89 d6                	mov    %edx,%esi
f0103e0c:	09 fe                	or     %edi,%esi
f0103e0e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103e14:	74 0c                	je     f0103e22 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103e16:	83 ef 01             	sub    $0x1,%edi
f0103e19:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103e1c:	fd                   	std    
f0103e1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103e1f:	fc                   	cld    
f0103e20:	eb 21                	jmp    f0103e43 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103e22:	f6 c1 03             	test   $0x3,%cl
f0103e25:	75 ef                	jne    f0103e16 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103e27:	83 ef 04             	sub    $0x4,%edi
f0103e2a:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103e2d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103e30:	fd                   	std    
f0103e31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103e33:	eb ea                	jmp    f0103e1f <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103e35:	89 f2                	mov    %esi,%edx
f0103e37:	09 c2                	or     %eax,%edx
f0103e39:	f6 c2 03             	test   $0x3,%dl
f0103e3c:	74 09                	je     f0103e47 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103e3e:	89 c7                	mov    %eax,%edi
f0103e40:	fc                   	cld    
f0103e41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103e43:	5e                   	pop    %esi
f0103e44:	5f                   	pop    %edi
f0103e45:	5d                   	pop    %ebp
f0103e46:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103e47:	f6 c1 03             	test   $0x3,%cl
f0103e4a:	75 f2                	jne    f0103e3e <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103e4c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103e4f:	89 c7                	mov    %eax,%edi
f0103e51:	fc                   	cld    
f0103e52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103e54:	eb ed                	jmp    f0103e43 <memmove+0x55>

f0103e56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103e56:	55                   	push   %ebp
f0103e57:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103e59:	ff 75 10             	pushl  0x10(%ebp)
f0103e5c:	ff 75 0c             	pushl  0xc(%ebp)
f0103e5f:	ff 75 08             	pushl  0x8(%ebp)
f0103e62:	e8 87 ff ff ff       	call   f0103dee <memmove>
}
f0103e67:	c9                   	leave  
f0103e68:	c3                   	ret    

f0103e69 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103e69:	55                   	push   %ebp
f0103e6a:	89 e5                	mov    %esp,%ebp
f0103e6c:	56                   	push   %esi
f0103e6d:	53                   	push   %ebx
f0103e6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e71:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103e74:	89 c6                	mov    %eax,%esi
f0103e76:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103e79:	39 f0                	cmp    %esi,%eax
f0103e7b:	74 1c                	je     f0103e99 <memcmp+0x30>
		if (*s1 != *s2)
f0103e7d:	0f b6 08             	movzbl (%eax),%ecx
f0103e80:	0f b6 1a             	movzbl (%edx),%ebx
f0103e83:	38 d9                	cmp    %bl,%cl
f0103e85:	75 08                	jne    f0103e8f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103e87:	83 c0 01             	add    $0x1,%eax
f0103e8a:	83 c2 01             	add    $0x1,%edx
f0103e8d:	eb ea                	jmp    f0103e79 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0103e8f:	0f b6 c1             	movzbl %cl,%eax
f0103e92:	0f b6 db             	movzbl %bl,%ebx
f0103e95:	29 d8                	sub    %ebx,%eax
f0103e97:	eb 05                	jmp    f0103e9e <memcmp+0x35>
	}

	return 0;
f0103e99:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103e9e:	5b                   	pop    %ebx
f0103e9f:	5e                   	pop    %esi
f0103ea0:	5d                   	pop    %ebp
f0103ea1:	c3                   	ret    

f0103ea2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103ea2:	55                   	push   %ebp
f0103ea3:	89 e5                	mov    %esp,%ebp
f0103ea5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ea8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103eab:	89 c2                	mov    %eax,%edx
f0103ead:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103eb0:	39 d0                	cmp    %edx,%eax
f0103eb2:	73 09                	jae    f0103ebd <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103eb4:	38 08                	cmp    %cl,(%eax)
f0103eb6:	74 05                	je     f0103ebd <memfind+0x1b>
	for (; s < ends; s++)
f0103eb8:	83 c0 01             	add    $0x1,%eax
f0103ebb:	eb f3                	jmp    f0103eb0 <memfind+0xe>
			break;
	return (void *) s;
}
f0103ebd:	5d                   	pop    %ebp
f0103ebe:	c3                   	ret    

f0103ebf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103ebf:	55                   	push   %ebp
f0103ec0:	89 e5                	mov    %esp,%ebp
f0103ec2:	57                   	push   %edi
f0103ec3:	56                   	push   %esi
f0103ec4:	53                   	push   %ebx
f0103ec5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103ec8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103ecb:	eb 03                	jmp    f0103ed0 <strtol+0x11>
		s++;
f0103ecd:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0103ed0:	0f b6 01             	movzbl (%ecx),%eax
f0103ed3:	3c 20                	cmp    $0x20,%al
f0103ed5:	74 f6                	je     f0103ecd <strtol+0xe>
f0103ed7:	3c 09                	cmp    $0x9,%al
f0103ed9:	74 f2                	je     f0103ecd <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0103edb:	3c 2b                	cmp    $0x2b,%al
f0103edd:	74 2e                	je     f0103f0d <strtol+0x4e>
	int neg = 0;
f0103edf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103ee4:	3c 2d                	cmp    $0x2d,%al
f0103ee6:	74 2f                	je     f0103f17 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103ee8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103eee:	75 05                	jne    f0103ef5 <strtol+0x36>
f0103ef0:	80 39 30             	cmpb   $0x30,(%ecx)
f0103ef3:	74 2c                	je     f0103f21 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103ef5:	85 db                	test   %ebx,%ebx
f0103ef7:	75 0a                	jne    f0103f03 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103ef9:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0103efe:	80 39 30             	cmpb   $0x30,(%ecx)
f0103f01:	74 28                	je     f0103f2b <strtol+0x6c>
		base = 10;
f0103f03:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f08:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103f0b:	eb 50                	jmp    f0103f5d <strtol+0x9e>
		s++;
f0103f0d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0103f10:	bf 00 00 00 00       	mov    $0x0,%edi
f0103f15:	eb d1                	jmp    f0103ee8 <strtol+0x29>
		s++, neg = 1;
f0103f17:	83 c1 01             	add    $0x1,%ecx
f0103f1a:	bf 01 00 00 00       	mov    $0x1,%edi
f0103f1f:	eb c7                	jmp    f0103ee8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103f21:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103f25:	74 0e                	je     f0103f35 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0103f27:	85 db                	test   %ebx,%ebx
f0103f29:	75 d8                	jne    f0103f03 <strtol+0x44>
		s++, base = 8;
f0103f2b:	83 c1 01             	add    $0x1,%ecx
f0103f2e:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103f33:	eb ce                	jmp    f0103f03 <strtol+0x44>
		s += 2, base = 16;
f0103f35:	83 c1 02             	add    $0x2,%ecx
f0103f38:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103f3d:	eb c4                	jmp    f0103f03 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0103f3f:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103f42:	89 f3                	mov    %esi,%ebx
f0103f44:	80 fb 19             	cmp    $0x19,%bl
f0103f47:	77 29                	ja     f0103f72 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0103f49:	0f be d2             	movsbl %dl,%edx
f0103f4c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103f4f:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103f52:	7d 30                	jge    f0103f84 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0103f54:	83 c1 01             	add    $0x1,%ecx
f0103f57:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103f5b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0103f5d:	0f b6 11             	movzbl (%ecx),%edx
f0103f60:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103f63:	89 f3                	mov    %esi,%ebx
f0103f65:	80 fb 09             	cmp    $0x9,%bl
f0103f68:	77 d5                	ja     f0103f3f <strtol+0x80>
			dig = *s - '0';
f0103f6a:	0f be d2             	movsbl %dl,%edx
f0103f6d:	83 ea 30             	sub    $0x30,%edx
f0103f70:	eb dd                	jmp    f0103f4f <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0103f72:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103f75:	89 f3                	mov    %esi,%ebx
f0103f77:	80 fb 19             	cmp    $0x19,%bl
f0103f7a:	77 08                	ja     f0103f84 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0103f7c:	0f be d2             	movsbl %dl,%edx
f0103f7f:	83 ea 37             	sub    $0x37,%edx
f0103f82:	eb cb                	jmp    f0103f4f <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103f84:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103f88:	74 05                	je     f0103f8f <strtol+0xd0>
		*endptr = (char *) s;
f0103f8a:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103f8d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103f8f:	89 c2                	mov    %eax,%edx
f0103f91:	f7 da                	neg    %edx
f0103f93:	85 ff                	test   %edi,%edi
f0103f95:	0f 45 c2             	cmovne %edx,%eax
}
f0103f98:	5b                   	pop    %ebx
f0103f99:	5e                   	pop    %esi
f0103f9a:	5f                   	pop    %edi
f0103f9b:	5d                   	pop    %ebp
f0103f9c:	c3                   	ret    
f0103f9d:	66 90                	xchg   %ax,%ax
f0103f9f:	90                   	nop

f0103fa0 <__udivdi3>:
f0103fa0:	55                   	push   %ebp
f0103fa1:	57                   	push   %edi
f0103fa2:	56                   	push   %esi
f0103fa3:	53                   	push   %ebx
f0103fa4:	83 ec 1c             	sub    $0x1c,%esp
f0103fa7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0103fab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103faf:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103fb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103fb7:	85 d2                	test   %edx,%edx
f0103fb9:	75 35                	jne    f0103ff0 <__udivdi3+0x50>
f0103fbb:	39 f3                	cmp    %esi,%ebx
f0103fbd:	0f 87 bd 00 00 00    	ja     f0104080 <__udivdi3+0xe0>
f0103fc3:	85 db                	test   %ebx,%ebx
f0103fc5:	89 d9                	mov    %ebx,%ecx
f0103fc7:	75 0b                	jne    f0103fd4 <__udivdi3+0x34>
f0103fc9:	b8 01 00 00 00       	mov    $0x1,%eax
f0103fce:	31 d2                	xor    %edx,%edx
f0103fd0:	f7 f3                	div    %ebx
f0103fd2:	89 c1                	mov    %eax,%ecx
f0103fd4:	31 d2                	xor    %edx,%edx
f0103fd6:	89 f0                	mov    %esi,%eax
f0103fd8:	f7 f1                	div    %ecx
f0103fda:	89 c6                	mov    %eax,%esi
f0103fdc:	89 e8                	mov    %ebp,%eax
f0103fde:	89 f7                	mov    %esi,%edi
f0103fe0:	f7 f1                	div    %ecx
f0103fe2:	89 fa                	mov    %edi,%edx
f0103fe4:	83 c4 1c             	add    $0x1c,%esp
f0103fe7:	5b                   	pop    %ebx
f0103fe8:	5e                   	pop    %esi
f0103fe9:	5f                   	pop    %edi
f0103fea:	5d                   	pop    %ebp
f0103feb:	c3                   	ret    
f0103fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103ff0:	39 f2                	cmp    %esi,%edx
f0103ff2:	77 7c                	ja     f0104070 <__udivdi3+0xd0>
f0103ff4:	0f bd fa             	bsr    %edx,%edi
f0103ff7:	83 f7 1f             	xor    $0x1f,%edi
f0103ffa:	0f 84 98 00 00 00    	je     f0104098 <__udivdi3+0xf8>
f0104000:	89 f9                	mov    %edi,%ecx
f0104002:	b8 20 00 00 00       	mov    $0x20,%eax
f0104007:	29 f8                	sub    %edi,%eax
f0104009:	d3 e2                	shl    %cl,%edx
f010400b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010400f:	89 c1                	mov    %eax,%ecx
f0104011:	89 da                	mov    %ebx,%edx
f0104013:	d3 ea                	shr    %cl,%edx
f0104015:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104019:	09 d1                	or     %edx,%ecx
f010401b:	89 f2                	mov    %esi,%edx
f010401d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104021:	89 f9                	mov    %edi,%ecx
f0104023:	d3 e3                	shl    %cl,%ebx
f0104025:	89 c1                	mov    %eax,%ecx
f0104027:	d3 ea                	shr    %cl,%edx
f0104029:	89 f9                	mov    %edi,%ecx
f010402b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010402f:	d3 e6                	shl    %cl,%esi
f0104031:	89 eb                	mov    %ebp,%ebx
f0104033:	89 c1                	mov    %eax,%ecx
f0104035:	d3 eb                	shr    %cl,%ebx
f0104037:	09 de                	or     %ebx,%esi
f0104039:	89 f0                	mov    %esi,%eax
f010403b:	f7 74 24 08          	divl   0x8(%esp)
f010403f:	89 d6                	mov    %edx,%esi
f0104041:	89 c3                	mov    %eax,%ebx
f0104043:	f7 64 24 0c          	mull   0xc(%esp)
f0104047:	39 d6                	cmp    %edx,%esi
f0104049:	72 0c                	jb     f0104057 <__udivdi3+0xb7>
f010404b:	89 f9                	mov    %edi,%ecx
f010404d:	d3 e5                	shl    %cl,%ebp
f010404f:	39 c5                	cmp    %eax,%ebp
f0104051:	73 5d                	jae    f01040b0 <__udivdi3+0x110>
f0104053:	39 d6                	cmp    %edx,%esi
f0104055:	75 59                	jne    f01040b0 <__udivdi3+0x110>
f0104057:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010405a:	31 ff                	xor    %edi,%edi
f010405c:	89 fa                	mov    %edi,%edx
f010405e:	83 c4 1c             	add    $0x1c,%esp
f0104061:	5b                   	pop    %ebx
f0104062:	5e                   	pop    %esi
f0104063:	5f                   	pop    %edi
f0104064:	5d                   	pop    %ebp
f0104065:	c3                   	ret    
f0104066:	8d 76 00             	lea    0x0(%esi),%esi
f0104069:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0104070:	31 ff                	xor    %edi,%edi
f0104072:	31 c0                	xor    %eax,%eax
f0104074:	89 fa                	mov    %edi,%edx
f0104076:	83 c4 1c             	add    $0x1c,%esp
f0104079:	5b                   	pop    %ebx
f010407a:	5e                   	pop    %esi
f010407b:	5f                   	pop    %edi
f010407c:	5d                   	pop    %ebp
f010407d:	c3                   	ret    
f010407e:	66 90                	xchg   %ax,%ax
f0104080:	31 ff                	xor    %edi,%edi
f0104082:	89 e8                	mov    %ebp,%eax
f0104084:	89 f2                	mov    %esi,%edx
f0104086:	f7 f3                	div    %ebx
f0104088:	89 fa                	mov    %edi,%edx
f010408a:	83 c4 1c             	add    $0x1c,%esp
f010408d:	5b                   	pop    %ebx
f010408e:	5e                   	pop    %esi
f010408f:	5f                   	pop    %edi
f0104090:	5d                   	pop    %ebp
f0104091:	c3                   	ret    
f0104092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104098:	39 f2                	cmp    %esi,%edx
f010409a:	72 06                	jb     f01040a2 <__udivdi3+0x102>
f010409c:	31 c0                	xor    %eax,%eax
f010409e:	39 eb                	cmp    %ebp,%ebx
f01040a0:	77 d2                	ja     f0104074 <__udivdi3+0xd4>
f01040a2:	b8 01 00 00 00       	mov    $0x1,%eax
f01040a7:	eb cb                	jmp    f0104074 <__udivdi3+0xd4>
f01040a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01040b0:	89 d8                	mov    %ebx,%eax
f01040b2:	31 ff                	xor    %edi,%edi
f01040b4:	eb be                	jmp    f0104074 <__udivdi3+0xd4>
f01040b6:	66 90                	xchg   %ax,%ax
f01040b8:	66 90                	xchg   %ax,%ax
f01040ba:	66 90                	xchg   %ax,%ax
f01040bc:	66 90                	xchg   %ax,%ax
f01040be:	66 90                	xchg   %ax,%ax

f01040c0 <__umoddi3>:
f01040c0:	55                   	push   %ebp
f01040c1:	57                   	push   %edi
f01040c2:	56                   	push   %esi
f01040c3:	53                   	push   %ebx
f01040c4:	83 ec 1c             	sub    $0x1c,%esp
f01040c7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01040cb:	8b 74 24 30          	mov    0x30(%esp),%esi
f01040cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01040d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01040d7:	85 ed                	test   %ebp,%ebp
f01040d9:	89 f0                	mov    %esi,%eax
f01040db:	89 da                	mov    %ebx,%edx
f01040dd:	75 19                	jne    f01040f8 <__umoddi3+0x38>
f01040df:	39 df                	cmp    %ebx,%edi
f01040e1:	0f 86 b1 00 00 00    	jbe    f0104198 <__umoddi3+0xd8>
f01040e7:	f7 f7                	div    %edi
f01040e9:	89 d0                	mov    %edx,%eax
f01040eb:	31 d2                	xor    %edx,%edx
f01040ed:	83 c4 1c             	add    $0x1c,%esp
f01040f0:	5b                   	pop    %ebx
f01040f1:	5e                   	pop    %esi
f01040f2:	5f                   	pop    %edi
f01040f3:	5d                   	pop    %ebp
f01040f4:	c3                   	ret    
f01040f5:	8d 76 00             	lea    0x0(%esi),%esi
f01040f8:	39 dd                	cmp    %ebx,%ebp
f01040fa:	77 f1                	ja     f01040ed <__umoddi3+0x2d>
f01040fc:	0f bd cd             	bsr    %ebp,%ecx
f01040ff:	83 f1 1f             	xor    $0x1f,%ecx
f0104102:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104106:	0f 84 b4 00 00 00    	je     f01041c0 <__umoddi3+0x100>
f010410c:	b8 20 00 00 00       	mov    $0x20,%eax
f0104111:	89 c2                	mov    %eax,%edx
f0104113:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104117:	29 c2                	sub    %eax,%edx
f0104119:	89 c1                	mov    %eax,%ecx
f010411b:	89 f8                	mov    %edi,%eax
f010411d:	d3 e5                	shl    %cl,%ebp
f010411f:	89 d1                	mov    %edx,%ecx
f0104121:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104125:	d3 e8                	shr    %cl,%eax
f0104127:	09 c5                	or     %eax,%ebp
f0104129:	8b 44 24 04          	mov    0x4(%esp),%eax
f010412d:	89 c1                	mov    %eax,%ecx
f010412f:	d3 e7                	shl    %cl,%edi
f0104131:	89 d1                	mov    %edx,%ecx
f0104133:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104137:	89 df                	mov    %ebx,%edi
f0104139:	d3 ef                	shr    %cl,%edi
f010413b:	89 c1                	mov    %eax,%ecx
f010413d:	89 f0                	mov    %esi,%eax
f010413f:	d3 e3                	shl    %cl,%ebx
f0104141:	89 d1                	mov    %edx,%ecx
f0104143:	89 fa                	mov    %edi,%edx
f0104145:	d3 e8                	shr    %cl,%eax
f0104147:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010414c:	09 d8                	or     %ebx,%eax
f010414e:	f7 f5                	div    %ebp
f0104150:	d3 e6                	shl    %cl,%esi
f0104152:	89 d1                	mov    %edx,%ecx
f0104154:	f7 64 24 08          	mull   0x8(%esp)
f0104158:	39 d1                	cmp    %edx,%ecx
f010415a:	89 c3                	mov    %eax,%ebx
f010415c:	89 d7                	mov    %edx,%edi
f010415e:	72 06                	jb     f0104166 <__umoddi3+0xa6>
f0104160:	75 0e                	jne    f0104170 <__umoddi3+0xb0>
f0104162:	39 c6                	cmp    %eax,%esi
f0104164:	73 0a                	jae    f0104170 <__umoddi3+0xb0>
f0104166:	2b 44 24 08          	sub    0x8(%esp),%eax
f010416a:	19 ea                	sbb    %ebp,%edx
f010416c:	89 d7                	mov    %edx,%edi
f010416e:	89 c3                	mov    %eax,%ebx
f0104170:	89 ca                	mov    %ecx,%edx
f0104172:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0104177:	29 de                	sub    %ebx,%esi
f0104179:	19 fa                	sbb    %edi,%edx
f010417b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010417f:	89 d0                	mov    %edx,%eax
f0104181:	d3 e0                	shl    %cl,%eax
f0104183:	89 d9                	mov    %ebx,%ecx
f0104185:	d3 ee                	shr    %cl,%esi
f0104187:	d3 ea                	shr    %cl,%edx
f0104189:	09 f0                	or     %esi,%eax
f010418b:	83 c4 1c             	add    $0x1c,%esp
f010418e:	5b                   	pop    %ebx
f010418f:	5e                   	pop    %esi
f0104190:	5f                   	pop    %edi
f0104191:	5d                   	pop    %ebp
f0104192:	c3                   	ret    
f0104193:	90                   	nop
f0104194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104198:	85 ff                	test   %edi,%edi
f010419a:	89 f9                	mov    %edi,%ecx
f010419c:	75 0b                	jne    f01041a9 <__umoddi3+0xe9>
f010419e:	b8 01 00 00 00       	mov    $0x1,%eax
f01041a3:	31 d2                	xor    %edx,%edx
f01041a5:	f7 f7                	div    %edi
f01041a7:	89 c1                	mov    %eax,%ecx
f01041a9:	89 d8                	mov    %ebx,%eax
f01041ab:	31 d2                	xor    %edx,%edx
f01041ad:	f7 f1                	div    %ecx
f01041af:	89 f0                	mov    %esi,%eax
f01041b1:	f7 f1                	div    %ecx
f01041b3:	e9 31 ff ff ff       	jmp    f01040e9 <__umoddi3+0x29>
f01041b8:	90                   	nop
f01041b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01041c0:	39 dd                	cmp    %ebx,%ebp
f01041c2:	72 08                	jb     f01041cc <__umoddi3+0x10c>
f01041c4:	39 f7                	cmp    %esi,%edi
f01041c6:	0f 87 21 ff ff ff    	ja     f01040ed <__umoddi3+0x2d>
f01041cc:	89 da                	mov    %ebx,%edx
f01041ce:	89 f0                	mov    %esi,%eax
f01041d0:	29 f8                	sub    %edi,%eax
f01041d2:	19 ea                	sbb    %ebp,%edx
f01041d4:	e9 14 ff ff ff       	jmp    f01040ed <__umoddi3+0x2d>
