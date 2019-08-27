
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
f0100057:	8d 83 98 cd fe ff    	lea    -0x13268(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 90 2f 00 00       	call   f0102ff3 <cprintf>
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
f010007f:	8d 83 b4 cd fe ff    	lea    -0x1324c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 68 2f 00 00       	call   f0102ff3 <cprintf>
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
f01000ca:	e8 8e 3b 00 00       	call   f0103c5d <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 48 05 00 00       	call   f010061c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 cf cd fe ff    	lea    -0x13231(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 0b 2f 00 00       	call   f0102ff3 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000e8:	e8 11 13 00 00       	call   f01013fe <mem_init>
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
f0100140:	8d 83 ea cd fe ff    	lea    -0x13216(%ebx),%eax
f0100146:	50                   	push   %eax
f0100147:	e8 a7 2e 00 00       	call   f0102ff3 <cprintf>
	vcprintf(fmt, ap);
f010014c:	83 c4 08             	add    $0x8,%esp
f010014f:	56                   	push   %esi
f0100150:	57                   	push   %edi
f0100151:	e8 66 2e 00 00       	call   f0102fbc <vcprintf>
	cprintf("\n");
f0100156:	8d 83 e0 dc fe ff    	lea    -0x12320(%ebx),%eax
f010015c:	89 04 24             	mov    %eax,(%esp)
f010015f:	e8 8f 2e 00 00       	call   f0102ff3 <cprintf>
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
f0100185:	8d 83 02 ce fe ff    	lea    -0x131fe(%ebx),%eax
f010018b:	50                   	push   %eax
f010018c:	e8 62 2e 00 00       	call   f0102ff3 <cprintf>
	vcprintf(fmt, ap);
f0100191:	83 c4 08             	add    $0x8,%esp
f0100194:	56                   	push   %esi
f0100195:	ff 75 10             	pushl  0x10(%ebp)
f0100198:	e8 1f 2e 00 00       	call   f0102fbc <vcprintf>
	cprintf("\n");
f010019d:	8d 83 e0 dc fe ff    	lea    -0x12320(%ebx),%eax
f01001a3:	89 04 24             	mov    %eax,(%esp)
f01001a6:	e8 48 2e 00 00       	call   f0102ff3 <cprintf>
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
f010027d:	0f b6 84 13 58 cf fe 	movzbl -0x130a8(%ebx,%edx,1),%eax
f0100284:	ff 
f0100285:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f010028b:	0f b6 8c 13 58 ce fe 	movzbl -0x131a8(%ebx,%edx,1),%ecx
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
f01002d0:	8d 83 1c ce fe ff    	lea    -0x131e4(%ebx),%eax
f01002d6:	50                   	push   %eax
f01002d7:	e8 17 2d 00 00       	call   f0102ff3 <cprintf>
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
f0100317:	0f b6 84 13 58 cf fe 	movzbl -0x130a8(%ebx,%edx,1),%eax
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
f010054a:	e8 5b 37 00 00       	call   f0103caa <memmove>
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
f010072d:	8d 83 28 ce fe ff    	lea    -0x131d8(%ebx),%eax
f0100733:	50                   	push   %eax
f0100734:	e8 ba 28 00 00       	call   f0102ff3 <cprintf>
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
f0100780:	8d 83 58 d0 fe ff    	lea    -0x12fa8(%ebx),%eax
f0100786:	50                   	push   %eax
f0100787:	8d 83 76 d0 fe ff    	lea    -0x12f8a(%ebx),%eax
f010078d:	50                   	push   %eax
f010078e:	8d b3 7b d0 fe ff    	lea    -0x12f85(%ebx),%esi
f0100794:	56                   	push   %esi
f0100795:	e8 59 28 00 00       	call   f0102ff3 <cprintf>
f010079a:	83 c4 0c             	add    $0xc,%esp
f010079d:	8d 83 5c d1 fe ff    	lea    -0x12ea4(%ebx),%eax
f01007a3:	50                   	push   %eax
f01007a4:	8d 83 84 d0 fe ff    	lea    -0x12f7c(%ebx),%eax
f01007aa:	50                   	push   %eax
f01007ab:	56                   	push   %esi
f01007ac:	e8 42 28 00 00       	call   f0102ff3 <cprintf>
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
f01007d1:	8d 83 8d d0 fe ff    	lea    -0x12f73(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 16 28 00 00       	call   f0102ff3 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007dd:	83 c4 08             	add    $0x8,%esp
f01007e0:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007e6:	8d 83 84 d1 fe ff    	lea    -0x12e7c(%ebx),%eax
f01007ec:	50                   	push   %eax
f01007ed:	e8 01 28 00 00       	call   f0102ff3 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f2:	83 c4 0c             	add    $0xc,%esp
f01007f5:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007fb:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100801:	50                   	push   %eax
f0100802:	57                   	push   %edi
f0100803:	8d 83 ac d1 fe ff    	lea    -0x12e54(%ebx),%eax
f0100809:	50                   	push   %eax
f010080a:	e8 e4 27 00 00       	call   f0102ff3 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010080f:	83 c4 0c             	add    $0xc,%esp
f0100812:	c7 c0 99 40 10 f0    	mov    $0xf0104099,%eax
f0100818:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010081e:	52                   	push   %edx
f010081f:	50                   	push   %eax
f0100820:	8d 83 d0 d1 fe ff    	lea    -0x12e30(%ebx),%eax
f0100826:	50                   	push   %eax
f0100827:	e8 c7 27 00 00       	call   f0102ff3 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082c:	83 c4 0c             	add    $0xc,%esp
f010082f:	c7 c0 60 90 11 f0    	mov    $0xf0119060,%eax
f0100835:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010083b:	52                   	push   %edx
f010083c:	50                   	push   %eax
f010083d:	8d 83 f4 d1 fe ff    	lea    -0x12e0c(%ebx),%eax
f0100843:	50                   	push   %eax
f0100844:	e8 aa 27 00 00       	call   f0102ff3 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100849:	83 c4 0c             	add    $0xc,%esp
f010084c:	c7 c6 c0 96 11 f0    	mov    $0xf01196c0,%esi
f0100852:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100858:	50                   	push   %eax
f0100859:	56                   	push   %esi
f010085a:	8d 83 18 d2 fe ff    	lea    -0x12de8(%ebx),%eax
f0100860:	50                   	push   %eax
f0100861:	e8 8d 27 00 00       	call   f0102ff3 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100869:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010086f:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100871:	c1 fe 0a             	sar    $0xa,%esi
f0100874:	56                   	push   %esi
f0100875:	8d 83 3c d2 fe ff    	lea    -0x12dc4(%ebx),%eax
f010087b:	50                   	push   %eax
f010087c:	e8 72 27 00 00       	call   f0102ff3 <cprintf>
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
f01008a6:	8d 83 a6 d0 fe ff    	lea    -0x12f5a(%ebx),%eax
f01008ac:	50                   	push   %eax
f01008ad:	e8 41 27 00 00       	call   f0102ff3 <cprintf>
	while(ebp){
f01008b2:	83 c4 10             	add    $0x10,%esp
		cprintf("ebp %x  ebp %x  args", ebp, *(ebp+1));
f01008b5:	8d 83 b8 d0 fe ff    	lea    -0x12f48(%ebx),%eax
f01008bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		cprintf(" %x", *(ebp+2));
f01008be:	8d b3 cd d0 fe ff    	lea    -0x12f33(%ebx),%esi
	while(ebp){
f01008c4:	eb 56                	jmp    f010091c <mon_backtrace+0x8e>
		cprintf("ebp %x  ebp %x  args", ebp, *(ebp+1));
f01008c6:	83 ec 04             	sub    $0x4,%esp
f01008c9:	ff 77 04             	pushl  0x4(%edi)
f01008cc:	57                   	push   %edi
f01008cd:	ff 75 e4             	pushl  -0x1c(%ebp)
f01008d0:	e8 1e 27 00 00       	call   f0102ff3 <cprintf>
		cprintf(" %x", *(ebp+2));
f01008d5:	83 c4 08             	add    $0x8,%esp
f01008d8:	ff 77 08             	pushl  0x8(%edi)
f01008db:	56                   	push   %esi
f01008dc:	e8 12 27 00 00       	call   f0102ff3 <cprintf>
		cprintf(" %x", *(ebp+3));
f01008e1:	83 c4 08             	add    $0x8,%esp
f01008e4:	ff 77 0c             	pushl  0xc(%edi)
f01008e7:	56                   	push   %esi
f01008e8:	e8 06 27 00 00       	call   f0102ff3 <cprintf>
		cprintf(" %x", *(ebp+4));
f01008ed:	83 c4 08             	add    $0x8,%esp
f01008f0:	ff 77 10             	pushl  0x10(%edi)
f01008f3:	56                   	push   %esi
f01008f4:	e8 fa 26 00 00       	call   f0102ff3 <cprintf>
		cprintf(" %x", *(ebp+5));
f01008f9:	83 c4 08             	add    $0x8,%esp
f01008fc:	ff 77 14             	pushl  0x14(%edi)
f01008ff:	56                   	push   %esi
f0100900:	e8 ee 26 00 00       	call   f0102ff3 <cprintf>
		cprintf(" %x\n", *(ebp+6));
f0100905:	83 c4 08             	add    $0x8,%esp
f0100908:	ff 77 18             	pushl  0x18(%edi)
f010090b:	8d 83 28 dc fe ff    	lea    -0x123d8(%ebx),%eax
f0100911:	50                   	push   %eax
f0100912:	e8 dc 26 00 00       	call   f0102ff3 <cprintf>
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
f0100945:	8d 83 a6 d0 fe ff    	lea    -0x12f5a(%ebx),%eax
f010094b:	50                   	push   %eax
f010094c:	e8 a2 26 00 00       	call   f0102ff3 <cprintf>
	while(ebp){
f0100951:	83 c4 10             	add    $0x10,%esp
		uint32_t eip = ebp[1];
		cprintf("ebp %x  eip %x  args", ebp, eip);
f0100954:	8d 83 d1 d0 fe ff    	lea    -0x12f2f(%ebx),%eax
f010095a:	89 45 b8             	mov    %eax,-0x48(%ebp)
		int i;
		for(i = 2; i <= 6; ++i)
			cprintf(" %08.x",ebp[i]);
f010095d:	8d 83 e6 d0 fe ff    	lea    -0x12f1a(%ebx),%eax
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
f0100979:	e8 75 26 00 00       	call   f0102ff3 <cprintf>
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
f0100996:	e8 58 26 00 00       	call   f0102ff3 <cprintf>
f010099b:	83 c6 04             	add    $0x4,%esi
		for(i = 2; i <= 6; ++i)
f010099e:	83 c4 10             	add    $0x10,%esp
f01009a1:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f01009a4:	75 ea                	jne    f0100990 <backtrace+0x63>
f01009a6:	8b 7d bc             	mov    -0x44(%ebp),%edi
		cprintf("\n");
f01009a9:	83 ec 0c             	sub    $0xc,%esp
f01009ac:	8d 83 e0 dc fe ff    	lea    -0x12320(%ebx),%eax
f01009b2:	50                   	push   %eax
f01009b3:	e8 3b 26 00 00       	call   f0102ff3 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f01009b8:	83 c4 08             	add    $0x8,%esp
f01009bb:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01009be:	50                   	push   %eax
f01009bf:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01009c2:	56                   	push   %esi
f01009c3:	e8 2f 27 00 00       	call   f01030f7 <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n",
f01009c8:	83 c4 08             	add    $0x8,%esp
f01009cb:	89 f0                	mov    %esi,%eax
f01009cd:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01009d0:	50                   	push   %eax
f01009d1:	ff 75 d8             	pushl  -0x28(%ebp)
f01009d4:	ff 75 dc             	pushl  -0x24(%ebp)
f01009d7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01009da:	ff 75 d0             	pushl  -0x30(%ebp)
f01009dd:	8d 83 ed d0 fe ff    	lea    -0x12f13(%ebx),%eax
f01009e3:	50                   	push   %eax
f01009e4:	e8 0a 26 00 00       	call   f0102ff3 <cprintf>
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
f0100a17:	8d 83 68 d2 fe ff    	lea    -0x12d98(%ebx),%eax
f0100a1d:	50                   	push   %eax
f0100a1e:	e8 d0 25 00 00       	call   f0102ff3 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a23:	8d 83 8c d2 fe ff    	lea    -0x12d74(%ebx),%eax
f0100a29:	89 04 24             	mov    %eax,(%esp)
f0100a2c:	e8 c2 25 00 00       	call   f0102ff3 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n",0x0100,"blue",0x0200,"green",0x0400,"red");
f0100a31:	83 c4 0c             	add    $0xc,%esp
f0100a34:	8d 83 fe d0 fe ff    	lea    -0x12f02(%ebx),%eax
f0100a3a:	50                   	push   %eax
f0100a3b:	68 00 04 00 00       	push   $0x400
f0100a40:	8d 83 02 d1 fe ff    	lea    -0x12efe(%ebx),%eax
f0100a46:	50                   	push   %eax
f0100a47:	68 00 02 00 00       	push   $0x200
f0100a4c:	8d 83 08 d1 fe ff    	lea    -0x12ef8(%ebx),%eax
f0100a52:	50                   	push   %eax
f0100a53:	68 00 01 00 00       	push   $0x100
f0100a58:	8d 83 0d d1 fe ff    	lea    -0x12ef3(%ebx),%eax
f0100a5e:	50                   	push   %eax
f0100a5f:	e8 8f 25 00 00       	call   f0102ff3 <cprintf>
f0100a64:	83 c4 20             	add    $0x20,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100a67:	8d bb 21 d1 fe ff    	lea    -0x12edf(%ebx),%edi
f0100a6d:	eb 4a                	jmp    f0100ab9 <monitor+0xb6>
f0100a6f:	83 ec 08             	sub    $0x8,%esp
f0100a72:	0f be c0             	movsbl %al,%eax
f0100a75:	50                   	push   %eax
f0100a76:	57                   	push   %edi
f0100a77:	e8 a4 31 00 00       	call   f0103c20 <strchr>
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
f0100aaa:	8d 83 26 d1 fe ff    	lea    -0x12eda(%ebx),%eax
f0100ab0:	50                   	push   %eax
f0100ab1:	e8 3d 25 00 00       	call   f0102ff3 <cprintf>
f0100ab6:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ab9:	8d 83 1d d1 fe ff    	lea    -0x12ee3(%ebx),%eax
f0100abf:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100ac2:	83 ec 0c             	sub    $0xc,%esp
f0100ac5:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100ac8:	e8 1b 2f 00 00       	call   f01039e8 <readline>
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
f0100af8:	e8 23 31 00 00       	call   f0103c20 <strchr>
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
f0100b21:	8d 83 76 d0 fe ff    	lea    -0x12f8a(%ebx),%eax
f0100b27:	50                   	push   %eax
f0100b28:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b2b:	e8 92 30 00 00       	call   f0103bc2 <strcmp>
f0100b30:	83 c4 10             	add    $0x10,%esp
f0100b33:	85 c0                	test   %eax,%eax
f0100b35:	74 38                	je     f0100b6f <monitor+0x16c>
f0100b37:	83 ec 08             	sub    $0x8,%esp
f0100b3a:	8d 83 84 d0 fe ff    	lea    -0x12f7c(%ebx),%eax
f0100b40:	50                   	push   %eax
f0100b41:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b44:	e8 79 30 00 00       	call   f0103bc2 <strcmp>
f0100b49:	83 c4 10             	add    $0x10,%esp
f0100b4c:	85 c0                	test   %eax,%eax
f0100b4e:	74 1a                	je     f0100b6a <monitor+0x167>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b50:	83 ec 08             	sub    $0x8,%esp
f0100b53:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b56:	8d 83 43 d1 fe ff    	lea    -0x12ebd(%ebx),%eax
f0100b5c:	50                   	push   %eax
f0100b5d:	e8 91 24 00 00       	call   f0102ff3 <cprintf>
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
f0100b9c:	e8 bb 23 00 00       	call   f0102f5c <__x86.get_pc_thunk.dx>
f0100ba1:	81 c2 67 67 01 00    	add    $0x16767,%edx
  // Initialize nextfree if this is the first time.
  // 'end' is a magic symbol automatically generated by the linker,
  // which points to the end of the kernel's bss segment:
  // the first virtual address that the linker did *not* assign
  // to any kernel code or global variables.
  if (!nextfree) {
f0100ba7:	83 ba 90 1f 00 00 00 	cmpl   $0x0,0x1f90(%edx)
f0100bae:	74 0e                	je     f0100bbe <boot_alloc+0x25>
  // to a multiple of PGSIZE.
  //
  // LAB 2: Your code here.
  //cprintf("boot_alloc memory at %x\n", nextfree);
  //cprintf("Next memory at %x\n", ROUNDUP((char *)(nextfree + n), PGSIZE));
  if (n != 0) {
f0100bb0:	85 c0                	test   %eax,%eax
f0100bb2:	75 24                	jne    f0100bd8 <boot_alloc+0x3f>
    char *next = nextfree;
    nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
    return next;
  } else
    return nextfree;
f0100bb4:	8b 8a 90 1f 00 00    	mov    0x1f90(%edx),%ecx

  return NULL;
}
f0100bba:	89 c8                	mov    %ecx,%eax
f0100bbc:	5d                   	pop    %ebp
f0100bbd:	c3                   	ret    
    nextfree = ROUNDUP((char *)end, PGSIZE);
f0100bbe:	c7 c1 c0 96 11 f0    	mov    $0xf01196c0,%ecx
f0100bc4:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100bca:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100bd0:	89 8a 90 1f 00 00    	mov    %ecx,0x1f90(%edx)
f0100bd6:	eb d8                	jmp    f0100bb0 <boot_alloc+0x17>
    char *next = nextfree;
f0100bd8:	8b 8a 90 1f 00 00    	mov    0x1f90(%edx),%ecx
    nextfree = ROUNDUP((char *)(nextfree + n), PGSIZE);
f0100bde:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0100be5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bea:	89 82 90 1f 00 00    	mov    %eax,0x1f90(%edx)
    return next;
f0100bf0:	eb c8                	jmp    f0100bba <boot_alloc+0x21>

f0100bf2 <check_va2pa>:
// This function returns the physical address of the page containing 'va',
// defined by the page directory 'pgdir'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t check_va2pa(pde_t *pgdir, uintptr_t va) {
f0100bf2:	55                   	push   %ebp
f0100bf3:	89 e5                	mov    %esp,%ebp
f0100bf5:	56                   	push   %esi
f0100bf6:	53                   	push   %ebx
f0100bf7:	e8 64 23 00 00       	call   f0102f60 <__x86.get_pc_thunk.cx>
f0100bfc:	81 c1 0c 67 01 00    	add    $0x1670c,%ecx
  pte_t *p;

  pgdir = &pgdir[PDX(va)];
f0100c02:	89 d3                	mov    %edx,%ebx
f0100c04:	c1 eb 16             	shr    $0x16,%ebx
  if (!(*pgdir & PTE_P))
f0100c07:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100c0a:	a8 01                	test   $0x1,%al
f0100c0c:	74 5a                	je     f0100c68 <check_va2pa+0x76>
    return ~0;
  p = (pte_t *)KADDR(PTE_ADDR(*pgdir));
f0100c0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

/* This macro takes a physical address and returns the corresponding kernel
 * virtual address.  It panics if you pass an invalid physical address. */
static inline void *_kaddr(const char *file, int line, physaddr_t pa) {
  if (PGNUM(pa) >= npages)
f0100c13:	89 c6                	mov    %eax,%esi
f0100c15:	c1 ee 0c             	shr    $0xc,%esi
f0100c18:	c7 c3 cc 96 11 f0    	mov    $0xf01196cc,%ebx
f0100c1e:	3b 33                	cmp    (%ebx),%esi
f0100c20:	73 2b                	jae    f0100c4d <check_va2pa+0x5b>
  if (!(p[PTX(va)] & PTE_P))
f0100c22:	c1 ea 0c             	shr    $0xc,%edx
f0100c25:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c2b:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c32:	89 c2                	mov    %eax,%edx
f0100c34:	83 e2 01             	and    $0x1,%edx
    return ~0;
  return PTE_ADDR(p[PTX(va)]);
f0100c37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c3c:	85 d2                	test   %edx,%edx
f0100c3e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100c43:	0f 44 c2             	cmove  %edx,%eax
}
f0100c46:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c49:	5b                   	pop    %ebx
f0100c4a:	5e                   	pop    %esi
f0100c4b:	5d                   	pop    %ebp
f0100c4c:	c3                   	ret    
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c4d:	50                   	push   %eax
f0100c4e:	8d 81 b4 d2 fe ff    	lea    -0x12d4c(%ecx),%eax
f0100c54:	50                   	push   %eax
f0100c55:	68 a8 02 00 00       	push   $0x2a8
f0100c5a:	8d 81 50 da fe ff    	lea    -0x125b0(%ecx),%eax
f0100c60:	50                   	push   %eax
f0100c61:	89 cb                	mov    %ecx,%ebx
f0100c63:	e8 97 f4 ff ff       	call   f01000ff <_panic>
    return ~0;
f0100c68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c6d:	eb d7                	jmp    f0100c46 <check_va2pa+0x54>

f0100c6f <check_page_free_list>:
static void check_page_free_list(bool only_low_memory) {
f0100c6f:	55                   	push   %ebp
f0100c70:	89 e5                	mov    %esp,%ebp
f0100c72:	57                   	push   %edi
f0100c73:	56                   	push   %esi
f0100c74:	53                   	push   %ebx
f0100c75:	83 ec 3c             	sub    $0x3c,%esp
f0100c78:	e8 eb 22 00 00       	call   f0102f68 <__x86.get_pc_thunk.di>
f0100c7d:	81 c7 8b 66 01 00    	add    $0x1668b,%edi
f0100c83:	89 7d c4             	mov    %edi,-0x3c(%ebp)
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c86:	84 c0                	test   %al,%al
f0100c88:	0f 85 dd 02 00 00    	jne    f0100f6b <check_page_free_list+0x2fc>
  if (!page_free_list)
f0100c8e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100c91:	83 b8 94 1f 00 00 00 	cmpl   $0x0,0x1f94(%eax)
f0100c98:	74 0c                	je     f0100ca6 <check_page_free_list+0x37>
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c9a:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0100ca1:	e9 2f 03 00 00       	jmp    f0100fd5 <check_page_free_list+0x366>
    panic("'page_free_list' is a null pointer!");
f0100ca6:	83 ec 04             	sub    $0x4,%esp
f0100ca9:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cac:	8d 83 d8 d2 fe ff    	lea    -0x12d28(%ebx),%eax
f0100cb2:	50                   	push   %eax
f0100cb3:	68 f0 01 00 00       	push   $0x1f0
f0100cb8:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0100cbe:	50                   	push   %eax
f0100cbf:	e8 3b f4 ff ff       	call   f01000ff <_panic>
f0100cc4:	50                   	push   %eax
f0100cc5:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cc8:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f0100cce:	50                   	push   %eax
f0100ccf:	6a 3f                	push   $0x3f
f0100cd1:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f0100cd7:	50                   	push   %eax
f0100cd8:	e8 22 f4 ff ff       	call   f01000ff <_panic>
  for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cdd:	8b 36                	mov    (%esi),%esi
f0100cdf:	85 f6                	test   %esi,%esi
f0100ce1:	74 40                	je     f0100d23 <check_page_free_list+0xb4>
void page_decref(struct PageInfo *pp);

void tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t page2pa(struct PageInfo *pp) {
  return (pp - pages) << PGSHIFT;
f0100ce3:	89 f0                	mov    %esi,%eax
f0100ce5:	2b 07                	sub    (%edi),%eax
f0100ce7:	c1 f8 03             	sar    $0x3,%eax
f0100cea:	c1 e0 0c             	shl    $0xc,%eax
    if (PDX(page2pa(pp)) < pdx_limit)
f0100ced:	89 c2                	mov    %eax,%edx
f0100cef:	c1 ea 16             	shr    $0x16,%edx
f0100cf2:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cf5:	73 e6                	jae    f0100cdd <check_page_free_list+0x6e>
  if (PGNUM(pa) >= npages)
f0100cf7:	89 c2                	mov    %eax,%edx
f0100cf9:	c1 ea 0c             	shr    $0xc,%edx
f0100cfc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100cff:	3b 11                	cmp    (%ecx),%edx
f0100d01:	73 c1                	jae    f0100cc4 <check_page_free_list+0x55>
      memset(page2kva(pp), 0x97, 128);
f0100d03:	83 ec 04             	sub    $0x4,%esp
f0100d06:	68 80 00 00 00       	push   $0x80
f0100d0b:	68 97 00 00 00       	push   $0x97
  return (void *)(pa + KERNBASE);
f0100d10:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d15:	50                   	push   %eax
f0100d16:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d19:	e8 3f 2f 00 00       	call   f0103c5d <memset>
f0100d1e:	83 c4 10             	add    $0x10,%esp
f0100d21:	eb ba                	jmp    f0100cdd <check_page_free_list+0x6e>
  first_free_page = (char *)boot_alloc(0);
f0100d23:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d28:	e8 6c fe ff ff       	call   f0100b99 <boot_alloc>
f0100d2d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d30:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100d33:	8b 97 94 1f 00 00    	mov    0x1f94(%edi),%edx
    assert(pp >= pages);
f0100d39:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0100d3f:	8b 08                	mov    (%eax),%ecx
    assert(pp < pages + npages);
f0100d41:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0100d47:	8b 00                	mov    (%eax),%eax
f0100d49:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100d4c:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100d4f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  int nfree_basemem = 0, nfree_extmem = 0;
f0100d52:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d57:	89 75 d0             	mov    %esi,-0x30(%ebp)
  for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d5a:	e9 08 01 00 00       	jmp    f0100e67 <check_page_free_list+0x1f8>
    assert(pp >= pages);
f0100d5f:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d62:	8d 83 6a da fe ff    	lea    -0x12596(%ebx),%eax
f0100d68:	50                   	push   %eax
f0100d69:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0100d6f:	50                   	push   %eax
f0100d70:	68 0a 02 00 00       	push   $0x20a
f0100d75:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0100d7b:	50                   	push   %eax
f0100d7c:	e8 7e f3 ff ff       	call   f01000ff <_panic>
    assert(pp < pages + npages);
f0100d81:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d84:	8d 83 8b da fe ff    	lea    -0x12575(%ebx),%eax
f0100d8a:	50                   	push   %eax
f0100d8b:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0100d91:	50                   	push   %eax
f0100d92:	68 0b 02 00 00       	push   $0x20b
f0100d97:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0100d9d:	50                   	push   %eax
f0100d9e:	e8 5c f3 ff ff       	call   f01000ff <_panic>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100da3:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100da6:	8d 83 fc d2 fe ff    	lea    -0x12d04(%ebx),%eax
f0100dac:	50                   	push   %eax
f0100dad:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0100db3:	50                   	push   %eax
f0100db4:	68 0c 02 00 00       	push   $0x20c
f0100db9:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0100dbf:	50                   	push   %eax
f0100dc0:	e8 3a f3 ff ff       	call   f01000ff <_panic>
    assert(page2pa(pp) != 0);
f0100dc5:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dc8:	8d 83 9f da fe ff    	lea    -0x12561(%ebx),%eax
f0100dce:	50                   	push   %eax
f0100dcf:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0100dd5:	50                   	push   %eax
f0100dd6:	68 0f 02 00 00       	push   $0x20f
f0100ddb:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0100de1:	50                   	push   %eax
f0100de2:	e8 18 f3 ff ff       	call   f01000ff <_panic>
    assert(page2pa(pp) != IOPHYSMEM);
f0100de7:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dea:	8d 83 b0 da fe ff    	lea    -0x12550(%ebx),%eax
f0100df0:	50                   	push   %eax
f0100df1:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0100df7:	50                   	push   %eax
f0100df8:	68 10 02 00 00       	push   $0x210
f0100dfd:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0100e03:	50                   	push   %eax
f0100e04:	e8 f6 f2 ff ff       	call   f01000ff <_panic>
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e09:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e0c:	8d 83 2c d3 fe ff    	lea    -0x12cd4(%ebx),%eax
f0100e12:	50                   	push   %eax
f0100e13:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0100e19:	50                   	push   %eax
f0100e1a:	68 11 02 00 00       	push   $0x211
f0100e1f:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0100e25:	50                   	push   %eax
f0100e26:	e8 d4 f2 ff ff       	call   f01000ff <_panic>
    assert(page2pa(pp) != EXTPHYSMEM);
f0100e2b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e2e:	8d 83 c9 da fe ff    	lea    -0x12537(%ebx),%eax
f0100e34:	50                   	push   %eax
f0100e35:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0100e3b:	50                   	push   %eax
f0100e3c:	68 12 02 00 00       	push   $0x212
f0100e41:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0100e47:	50                   	push   %eax
f0100e48:	e8 b2 f2 ff ff       	call   f01000ff <_panic>
  if (PGNUM(pa) >= npages)
f0100e4d:	89 c6                	mov    %eax,%esi
f0100e4f:	c1 ee 0c             	shr    $0xc,%esi
f0100e52:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0100e55:	76 70                	jbe    f0100ec7 <check_page_free_list+0x258>
  return (void *)(pa + KERNBASE);
f0100e57:	2d 00 00 00 10       	sub    $0x10000000,%eax
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100e5c:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100e5f:	77 7f                	ja     f0100ee0 <check_page_free_list+0x271>
      ++nfree_extmem;
f0100e61:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
  for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e65:	8b 12                	mov    (%edx),%edx
f0100e67:	85 d2                	test   %edx,%edx
f0100e69:	0f 84 93 00 00 00    	je     f0100f02 <check_page_free_list+0x293>
    assert(pp >= pages);
f0100e6f:	39 d1                	cmp    %edx,%ecx
f0100e71:	0f 87 e8 fe ff ff    	ja     f0100d5f <check_page_free_list+0xf0>
    assert(pp < pages + npages);
f0100e77:	39 d3                	cmp    %edx,%ebx
f0100e79:	0f 86 02 ff ff ff    	jbe    f0100d81 <check_page_free_list+0x112>
    assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100e7f:	89 d0                	mov    %edx,%eax
f0100e81:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100e84:	a8 07                	test   $0x7,%al
f0100e86:	0f 85 17 ff ff ff    	jne    f0100da3 <check_page_free_list+0x134>
  return (pp - pages) << PGSHIFT;
f0100e8c:	c1 f8 03             	sar    $0x3,%eax
f0100e8f:	c1 e0 0c             	shl    $0xc,%eax
    assert(page2pa(pp) != 0);
f0100e92:	85 c0                	test   %eax,%eax
f0100e94:	0f 84 2b ff ff ff    	je     f0100dc5 <check_page_free_list+0x156>
    assert(page2pa(pp) != IOPHYSMEM);
f0100e9a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e9f:	0f 84 42 ff ff ff    	je     f0100de7 <check_page_free_list+0x178>
    assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ea5:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100eaa:	0f 84 59 ff ff ff    	je     f0100e09 <check_page_free_list+0x19a>
    assert(page2pa(pp) != EXTPHYSMEM);
f0100eb0:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100eb5:	0f 84 70 ff ff ff    	je     f0100e2b <check_page_free_list+0x1bc>
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100ebb:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ec0:	77 8b                	ja     f0100e4d <check_page_free_list+0x1de>
      ++nfree_basemem;
f0100ec2:	83 c7 01             	add    $0x1,%edi
f0100ec5:	eb 9e                	jmp    f0100e65 <check_page_free_list+0x1f6>
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ec7:	50                   	push   %eax
f0100ec8:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ecb:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f0100ed1:	50                   	push   %eax
f0100ed2:	6a 3f                	push   $0x3f
f0100ed4:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f0100eda:	50                   	push   %eax
f0100edb:	e8 1f f2 ff ff       	call   f01000ff <_panic>
    assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100ee0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ee3:	8d 83 50 d3 fe ff    	lea    -0x12cb0(%ebx),%eax
f0100ee9:	50                   	push   %eax
f0100eea:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0100ef0:	50                   	push   %eax
f0100ef1:	68 13 02 00 00       	push   $0x213
f0100ef6:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0100efc:	50                   	push   %eax
f0100efd:	e8 fd f1 ff ff       	call   f01000ff <_panic>
f0100f02:	8b 75 d0             	mov    -0x30(%ebp),%esi
  assert(nfree_basemem > 0);
f0100f05:	85 ff                	test   %edi,%edi
f0100f07:	7e 1e                	jle    f0100f27 <check_page_free_list+0x2b8>
  assert(nfree_extmem > 0);
f0100f09:	85 f6                	test   %esi,%esi
f0100f0b:	7e 3c                	jle    f0100f49 <check_page_free_list+0x2da>
  cprintf("check_page_free_list done\n");
f0100f0d:	83 ec 0c             	sub    $0xc,%esp
f0100f10:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f13:	8d 83 06 db fe ff    	lea    -0x124fa(%ebx),%eax
f0100f19:	50                   	push   %eax
f0100f1a:	e8 d4 20 00 00       	call   f0102ff3 <cprintf>
}
f0100f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f22:	5b                   	pop    %ebx
f0100f23:	5e                   	pop    %esi
f0100f24:	5f                   	pop    %edi
f0100f25:	5d                   	pop    %ebp
f0100f26:	c3                   	ret    
  assert(nfree_basemem > 0);
f0100f27:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f2a:	8d 83 e3 da fe ff    	lea    -0x1251d(%ebx),%eax
f0100f30:	50                   	push   %eax
f0100f31:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0100f37:	50                   	push   %eax
f0100f38:	68 1b 02 00 00       	push   $0x21b
f0100f3d:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0100f43:	50                   	push   %eax
f0100f44:	e8 b6 f1 ff ff       	call   f01000ff <_panic>
  assert(nfree_extmem > 0);
f0100f49:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f4c:	8d 83 f5 da fe ff    	lea    -0x1250b(%ebx),%eax
f0100f52:	50                   	push   %eax
f0100f53:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0100f59:	50                   	push   %eax
f0100f5a:	68 1c 02 00 00       	push   $0x21c
f0100f5f:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0100f65:	50                   	push   %eax
f0100f66:	e8 94 f1 ff ff       	call   f01000ff <_panic>
  if (!page_free_list)
f0100f6b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100f6e:	8b 80 94 1f 00 00    	mov    0x1f94(%eax),%eax
f0100f74:	85 c0                	test   %eax,%eax
f0100f76:	0f 84 2a fd ff ff    	je     f0100ca6 <check_page_free_list+0x37>
    struct PageInfo **tp[2] = {&pp1, &pp2};
f0100f7c:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f7f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f82:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f85:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  return (pp - pages) << PGSHIFT;
f0100f88:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100f8b:	c7 c3 d4 96 11 f0    	mov    $0xf01196d4,%ebx
f0100f91:	89 c2                	mov    %eax,%edx
f0100f93:	2b 13                	sub    (%ebx),%edx
      int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f95:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f9b:	0f 95 c2             	setne  %dl
f0100f9e:	0f b6 d2             	movzbl %dl,%edx
      *tp[pagetype] = pp;
f0100fa1:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100fa5:	89 01                	mov    %eax,(%ecx)
      tp[pagetype] = &pp->pp_link;
f0100fa7:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
    for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fab:	8b 00                	mov    (%eax),%eax
f0100fad:	85 c0                	test   %eax,%eax
f0100faf:	75 e0                	jne    f0100f91 <check_page_free_list+0x322>
    *tp[1] = 0;
f0100fb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fb4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    *tp[0] = pp2;
f0100fba:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fc0:	89 10                	mov    %edx,(%eax)
    page_free_list = pp1;
f0100fc2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100fc5:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100fc8:	89 87 94 1f 00 00    	mov    %eax,0x1f94(%edi)
  unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fce:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  for (pp = page_free_list; pp; pp = pp->pp_link)
f0100fd5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100fd8:	8b b0 94 1f 00 00    	mov    0x1f94(%eax),%esi
f0100fde:	c7 c7 d4 96 11 f0    	mov    $0xf01196d4,%edi
  if (PGNUM(pa) >= npages)
f0100fe4:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0100fea:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100fed:	e9 ed fc ff ff       	jmp    f0100cdf <check_page_free_list+0x70>

f0100ff2 <page_init>:
void page_init(void) {
f0100ff2:	55                   	push   %ebp
f0100ff3:	89 e5                	mov    %esp,%ebp
f0100ff5:	57                   	push   %edi
f0100ff6:	56                   	push   %esi
f0100ff7:	53                   	push   %ebx
f0100ff8:	83 ec 04             	sub    $0x4,%esp
f0100ffb:	e8 64 1f 00 00       	call   f0102f64 <__x86.get_pc_thunk.si>
f0101000:	81 c6 08 63 01 00    	add    $0x16308,%esi
f0101006:	89 75 f0             	mov    %esi,-0x10(%ebp)
  for (i = 1; i < npages_basemem; i++) {
f0101009:	8b be 98 1f 00 00    	mov    0x1f98(%esi),%edi
f010100f:	8b 9e 94 1f 00 00    	mov    0x1f94(%esi),%ebx
f0101015:	ba 00 00 00 00       	mov    $0x0,%edx
f010101a:	b8 01 00 00 00       	mov    $0x1,%eax
    pages[i].pp_ref = 0;
f010101f:	c7 c6 d4 96 11 f0    	mov    $0xf01196d4,%esi
  for (i = 1; i < npages_basemem; i++) {
f0101025:	eb 1f                	jmp    f0101046 <page_init+0x54>
    pages[i].pp_ref = 0;
f0101027:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010102e:	89 d1                	mov    %edx,%ecx
f0101030:	03 0e                	add    (%esi),%ecx
f0101032:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
    pages[i].pp_link = page_free_list;
f0101038:	89 19                	mov    %ebx,(%ecx)
  for (i = 1; i < npages_basemem; i++) {
f010103a:	83 c0 01             	add    $0x1,%eax
    page_free_list = &pages[i];
f010103d:	89 d3                	mov    %edx,%ebx
f010103f:	03 1e                	add    (%esi),%ebx
f0101041:	ba 01 00 00 00       	mov    $0x1,%edx
  for (i = 1; i < npages_basemem; i++) {
f0101046:	39 c7                	cmp    %eax,%edi
f0101048:	77 dd                	ja     f0101027 <page_init+0x35>
f010104a:	84 d2                	test   %dl,%dl
f010104c:	75 36                	jne    f0101084 <page_init+0x92>
  int med = (int)ROUNDUP(((char *)pages) + (sizeof(struct PageInfo) * npages) -
f010104e:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0101051:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101057:	8b 10                	mov    (%eax),%edx
f0101059:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f010105f:	8b 00                	mov    (%eax),%eax
f0101061:	8d 84 d0 ff 0f 00 10 	lea    0x10000fff(%eax,%edx,8),%eax
f0101068:	c1 f8 0c             	sar    $0xc,%eax
f010106b:	8b 9e 94 1f 00 00    	mov    0x1f94(%esi),%ebx
  for (i = med; i < npages; i++) {
f0101071:	ba 00 00 00 00       	mov    $0x0,%edx
f0101076:	c7 c7 cc 96 11 f0    	mov    $0xf01196cc,%edi
    pages[i].pp_ref = 0;
f010107c:	c7 c6 d4 96 11 f0    	mov    $0xf01196d4,%esi
  for (i = med; i < npages; i++) {
f0101082:	eb 2a                	jmp    f01010ae <page_init+0xbc>
f0101084:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101087:	89 98 94 1f 00 00    	mov    %ebx,0x1f94(%eax)
f010108d:	eb bf                	jmp    f010104e <page_init+0x5c>
f010108f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    pages[i].pp_ref = 0;
f0101096:	89 d1                	mov    %edx,%ecx
f0101098:	03 0e                	add    (%esi),%ecx
f010109a:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
    pages[i].pp_link = page_free_list;
f01010a0:	89 19                	mov    %ebx,(%ecx)
  for (i = med; i < npages; i++) {
f01010a2:	83 c0 01             	add    $0x1,%eax
    page_free_list = &pages[i];
f01010a5:	89 d3                	mov    %edx,%ebx
f01010a7:	03 1e                	add    (%esi),%ebx
f01010a9:	ba 01 00 00 00       	mov    $0x1,%edx
  for (i = med; i < npages; i++) {
f01010ae:	39 07                	cmp    %eax,(%edi)
f01010b0:	77 dd                	ja     f010108f <page_init+0x9d>
f01010b2:	84 d2                	test   %dl,%dl
f01010b4:	75 08                	jne    f01010be <page_init+0xcc>
}
f01010b6:	83 c4 04             	add    $0x4,%esp
f01010b9:	5b                   	pop    %ebx
f01010ba:	5e                   	pop    %esi
f01010bb:	5f                   	pop    %edi
f01010bc:	5d                   	pop    %ebp
f01010bd:	c3                   	ret    
f01010be:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01010c1:	89 98 94 1f 00 00    	mov    %ebx,0x1f94(%eax)
f01010c7:	eb ed                	jmp    f01010b6 <page_init+0xc4>

f01010c9 <page_alloc>:
struct PageInfo *page_alloc(int alloc_flags) {
f01010c9:	55                   	push   %ebp
f01010ca:	89 e5                	mov    %esp,%ebp
f01010cc:	56                   	push   %esi
f01010cd:	53                   	push   %ebx
f01010ce:	e8 e2 f0 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f01010d3:	81 c3 35 62 01 00    	add    $0x16235,%ebx
  if (page_free_list) {
f01010d9:	8b b3 94 1f 00 00    	mov    0x1f94(%ebx),%esi
f01010df:	85 f6                	test   %esi,%esi
f01010e1:	74 0e                	je     f01010f1 <page_alloc+0x28>
    page_free_list = page_free_list->pp_link;
f01010e3:	8b 06                	mov    (%esi),%eax
f01010e5:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
    if (alloc_flags & ALLOC_ZERO)
f01010eb:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01010ef:	75 09                	jne    f01010fa <page_alloc+0x31>
}
f01010f1:	89 f0                	mov    %esi,%eax
f01010f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010f6:	5b                   	pop    %ebx
f01010f7:	5e                   	pop    %esi
f01010f8:	5d                   	pop    %ebp
f01010f9:	c3                   	ret    
  return (pp - pages) << PGSHIFT;
f01010fa:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0101100:	89 f2                	mov    %esi,%edx
f0101102:	2b 10                	sub    (%eax),%edx
f0101104:	89 d0                	mov    %edx,%eax
f0101106:	c1 f8 03             	sar    $0x3,%eax
f0101109:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f010110c:	89 c1                	mov    %eax,%ecx
f010110e:	c1 e9 0c             	shr    $0xc,%ecx
f0101111:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0101117:	3b 0a                	cmp    (%edx),%ecx
f0101119:	73 1a                	jae    f0101135 <page_alloc+0x6c>
      memset(page2kva(ret), 0, PGSIZE);
f010111b:	83 ec 04             	sub    $0x4,%esp
f010111e:	68 00 10 00 00       	push   $0x1000
f0101123:	6a 00                	push   $0x0
  return (void *)(pa + KERNBASE);
f0101125:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010112a:	50                   	push   %eax
f010112b:	e8 2d 2b 00 00       	call   f0103c5d <memset>
f0101130:	83 c4 10             	add    $0x10,%esp
f0101133:	eb bc                	jmp    f01010f1 <page_alloc+0x28>
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101135:	50                   	push   %eax
f0101136:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f010113c:	50                   	push   %eax
f010113d:	6a 3f                	push   $0x3f
f010113f:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f0101145:	50                   	push   %eax
f0101146:	e8 b4 ef ff ff       	call   f01000ff <_panic>

f010114b <page_free>:
void page_free(struct PageInfo *pp) {
f010114b:	55                   	push   %ebp
f010114c:	89 e5                	mov    %esp,%ebp
f010114e:	e8 16 f6 ff ff       	call   f0100769 <__x86.get_pc_thunk.ax>
f0101153:	05 b5 61 01 00       	add    $0x161b5,%eax
f0101158:	8b 55 08             	mov    0x8(%ebp),%edx
  pp->pp_link = page_free_list;
f010115b:	8b 88 94 1f 00 00    	mov    0x1f94(%eax),%ecx
f0101161:	89 0a                	mov    %ecx,(%edx)
  page_free_list = pp;
f0101163:	89 90 94 1f 00 00    	mov    %edx,0x1f94(%eax)
}
f0101169:	5d                   	pop    %ebp
f010116a:	c3                   	ret    

f010116b <page_decref>:
void page_decref(struct PageInfo *pp) {
f010116b:	55                   	push   %ebp
f010116c:	89 e5                	mov    %esp,%ebp
f010116e:	8b 55 08             	mov    0x8(%ebp),%edx
  if (--pp->pp_ref == 0)
f0101171:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101175:	83 e8 01             	sub    $0x1,%eax
f0101178:	66 89 42 04          	mov    %ax,0x4(%edx)
f010117c:	66 85 c0             	test   %ax,%ax
f010117f:	74 02                	je     f0101183 <page_decref+0x18>
}
f0101181:	c9                   	leave  
f0101182:	c3                   	ret    
    page_free(pp);
f0101183:	52                   	push   %edx
f0101184:	e8 c2 ff ff ff       	call   f010114b <page_free>
f0101189:	83 c4 04             	add    $0x4,%esp
}
f010118c:	eb f3                	jmp    f0101181 <page_decref+0x16>

f010118e <pgdir_walk>:
pte_t *pgdir_walk(pde_t *pgdir, const void *va, int create) {
f010118e:	55                   	push   %ebp
f010118f:	89 e5                	mov    %esp,%ebp
f0101191:	57                   	push   %edi
f0101192:	56                   	push   %esi
f0101193:	53                   	push   %ebx
f0101194:	83 ec 0c             	sub    $0xc,%esp
f0101197:	e8 19 f0 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010119c:	81 c3 6c 61 01 00    	add    $0x1616c,%ebx
f01011a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  int dindex = PDX(va), tindex = PTX(va);
f01011a5:	89 f7                	mov    %esi,%edi
f01011a7:	c1 ef 0c             	shr    $0xc,%edi
f01011aa:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
f01011b0:	c1 ee 16             	shr    $0x16,%esi
  if (!(pgdir[dindex] & PTE_P)) { // if pde not exist
f01011b3:	c1 e6 02             	shl    $0x2,%esi
f01011b6:	03 75 08             	add    0x8(%ebp),%esi
f01011b9:	f6 06 01             	testb  $0x1,(%esi)
f01011bc:	75 2f                	jne    f01011ed <pgdir_walk+0x5f>
    if (create) {
f01011be:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011c2:	74 67                	je     f010122b <pgdir_walk+0x9d>
      struct PageInfo *pg = page_alloc(ALLOC_ZERO); // alloc a zero page
f01011c4:	83 ec 0c             	sub    $0xc,%esp
f01011c7:	6a 01                	push   $0x1
f01011c9:	e8 fb fe ff ff       	call   f01010c9 <page_alloc>
      if (!pg)
f01011ce:	83 c4 10             	add    $0x10,%esp
f01011d1:	85 c0                	test   %eax,%eax
f01011d3:	74 5d                	je     f0101232 <pgdir_walk+0xa4>
      pg->pp_ref++;
f01011d5:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
  return (pp - pages) << PGSHIFT;
f01011da:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f01011e0:	2b 02                	sub    (%edx),%eax
f01011e2:	c1 f8 03             	sar    $0x3,%eax
f01011e5:	c1 e0 0c             	shl    $0xc,%eax
      pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f01011e8:	83 c8 07             	or     $0x7,%eax
f01011eb:	89 06                	mov    %eax,(%esi)
  pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f01011ed:	8b 06                	mov    (%esi),%eax
f01011ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if (PGNUM(pa) >= npages)
f01011f4:	89 c1                	mov    %eax,%ecx
f01011f6:	c1 e9 0c             	shr    $0xc,%ecx
f01011f9:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f01011ff:	3b 0a                	cmp    (%edx),%ecx
f0101201:	73 0f                	jae    f0101212 <pgdir_walk+0x84>
  return p + tindex;
f0101203:	8d 84 b8 00 00 00 f0 	lea    -0x10000000(%eax,%edi,4),%eax
}
f010120a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010120d:	5b                   	pop    %ebx
f010120e:	5e                   	pop    %esi
f010120f:	5f                   	pop    %edi
f0101210:	5d                   	pop    %ebp
f0101211:	c3                   	ret    
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101212:	50                   	push   %eax
f0101213:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f0101219:	50                   	push   %eax
f010121a:	68 5d 01 00 00       	push   $0x15d
f010121f:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0101225:	50                   	push   %eax
f0101226:	e8 d4 ee ff ff       	call   f01000ff <_panic>
      return NULL;
f010122b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101230:	eb d8                	jmp    f010120a <pgdir_walk+0x7c>
        return NULL; // allocation fails
f0101232:	b8 00 00 00 00       	mov    $0x0,%eax
f0101237:	eb d1                	jmp    f010120a <pgdir_walk+0x7c>

f0101239 <boot_map_region>:
                            physaddr_t pa, int perm) {
f0101239:	55                   	push   %ebp
f010123a:	89 e5                	mov    %esp,%ebp
f010123c:	57                   	push   %edi
f010123d:	56                   	push   %esi
f010123e:	53                   	push   %ebx
f010123f:	83 ec 1c             	sub    $0x1c,%esp
f0101242:	e8 21 1d 00 00       	call   f0102f68 <__x86.get_pc_thunk.di>
f0101247:	81 c7 c1 60 01 00    	add    $0x160c1,%edi
f010124d:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0101250:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101253:	8b 45 08             	mov    0x8(%ebp),%eax
  for (i = 0; i < size / PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101256:	c1 e9 0c             	shr    $0xc,%ecx
f0101259:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010125c:	89 c3                	mov    %eax,%ebx
f010125e:	be 00 00 00 00       	mov    $0x0,%esi
    pte_t *pte = pgdir_walk(pgdir, (void *)va, 1); // create
f0101263:	89 d7                	mov    %edx,%edi
f0101265:	29 c7                	sub    %eax,%edi
    *pte = pa | perm | PTE_P;
f0101267:	8b 45 0c             	mov    0xc(%ebp),%eax
f010126a:	83 c8 01             	or     $0x1,%eax
f010126d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for (i = 0; i < size / PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101270:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f0101273:	74 48                	je     f01012bd <boot_map_region+0x84>
    pte_t *pte = pgdir_walk(pgdir, (void *)va, 1); // create
f0101275:	83 ec 04             	sub    $0x4,%esp
f0101278:	6a 01                	push   $0x1
f010127a:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f010127d:	50                   	push   %eax
f010127e:	ff 75 e0             	pushl  -0x20(%ebp)
f0101281:	e8 08 ff ff ff       	call   f010118e <pgdir_walk>
    if (!pte)
f0101286:	83 c4 10             	add    $0x10,%esp
f0101289:	85 c0                	test   %eax,%eax
f010128b:	74 12                	je     f010129f <boot_map_region+0x66>
    *pte = pa | perm | PTE_P;
f010128d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101290:	09 da                	or     %ebx,%edx
f0101292:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < size / PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101294:	83 c6 01             	add    $0x1,%esi
f0101297:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010129d:	eb d1                	jmp    f0101270 <boot_map_region+0x37>
      panic("boot_map_region panic, out of memory");
f010129f:	83 ec 04             	sub    $0x4,%esp
f01012a2:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f01012a5:	8d 83 94 d3 fe ff    	lea    -0x12c6c(%ebx),%eax
f01012ab:	50                   	push   %eax
f01012ac:	68 7a 01 00 00       	push   $0x17a
f01012b1:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01012b7:	50                   	push   %eax
f01012b8:	e8 42 ee ff ff       	call   f01000ff <_panic>
}
f01012bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012c0:	5b                   	pop    %ebx
f01012c1:	5e                   	pop    %esi
f01012c2:	5f                   	pop    %edi
f01012c3:	5d                   	pop    %ebp
f01012c4:	c3                   	ret    

f01012c5 <page_lookup>:
struct PageInfo *page_lookup(pde_t *pgdir, void *va, pte_t **pte_store) {
f01012c5:	55                   	push   %ebp
f01012c6:	89 e5                	mov    %esp,%ebp
f01012c8:	56                   	push   %esi
f01012c9:	53                   	push   %ebx
f01012ca:	e8 e6 ee ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f01012cf:	81 c3 39 60 01 00    	add    $0x16039,%ebx
f01012d5:	8b 75 10             	mov    0x10(%ebp),%esi
  pte_t *pte = pgdir_walk(pgdir, va, 0); // not create
f01012d8:	83 ec 04             	sub    $0x4,%esp
f01012db:	6a 00                	push   $0x0
f01012dd:	ff 75 0c             	pushl  0xc(%ebp)
f01012e0:	ff 75 08             	pushl  0x8(%ebp)
f01012e3:	e8 a6 fe ff ff       	call   f010118e <pgdir_walk>
  if (!pte || !(*pte & PTE_P))
f01012e8:	83 c4 10             	add    $0x10,%esp
f01012eb:	85 c0                	test   %eax,%eax
f01012ed:	74 44                	je     f0101333 <page_lookup+0x6e>
f01012ef:	f6 00 01             	testb  $0x1,(%eax)
f01012f2:	74 46                	je     f010133a <page_lookup+0x75>
  if (pte_store)
f01012f4:	85 f6                	test   %esi,%esi
f01012f6:	74 02                	je     f01012fa <page_lookup+0x35>
    *pte_store = pte; // found and set
f01012f8:	89 06                	mov    %eax,(%esi)
f01012fa:	8b 00                	mov    (%eax),%eax
f01012fc:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo *pa2page(physaddr_t pa) {
  if (PGNUM(pa) >= npages)
f01012ff:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0101305:	39 02                	cmp    %eax,(%edx)
f0101307:	76 12                	jbe    f010131b <page_lookup+0x56>
    panic("pa2page called with invalid pa");
  return &pages[PGNUM(pa)];
f0101309:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f010130f:	8b 12                	mov    (%edx),%edx
f0101311:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101314:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101317:	5b                   	pop    %ebx
f0101318:	5e                   	pop    %esi
f0101319:	5d                   	pop    %ebp
f010131a:	c3                   	ret    
    panic("pa2page called with invalid pa");
f010131b:	83 ec 04             	sub    $0x4,%esp
f010131e:	8d 83 bc d3 fe ff    	lea    -0x12c44(%ebx),%eax
f0101324:	50                   	push   %eax
f0101325:	6a 3b                	push   $0x3b
f0101327:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f010132d:	50                   	push   %eax
f010132e:	e8 cc ed ff ff       	call   f01000ff <_panic>
    return NULL; // page not found
f0101333:	b8 00 00 00 00       	mov    $0x0,%eax
f0101338:	eb da                	jmp    f0101314 <page_lookup+0x4f>
f010133a:	b8 00 00 00 00       	mov    $0x0,%eax
f010133f:	eb d3                	jmp    f0101314 <page_lookup+0x4f>

f0101341 <page_remove>:
void page_remove(pde_t *pgdir, void *va) {
f0101341:	55                   	push   %ebp
f0101342:	89 e5                	mov    %esp,%ebp
f0101344:	53                   	push   %ebx
f0101345:	83 ec 18             	sub    $0x18,%esp
f0101348:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f010134b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010134e:	50                   	push   %eax
f010134f:	53                   	push   %ebx
f0101350:	ff 75 08             	pushl  0x8(%ebp)
f0101353:	e8 6d ff ff ff       	call   f01012c5 <page_lookup>
  if (!pg || !(*pte & PTE_P))
f0101358:	83 c4 10             	add    $0x10,%esp
f010135b:	85 c0                	test   %eax,%eax
f010135d:	74 08                	je     f0101367 <page_remove+0x26>
f010135f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101362:	f6 02 01             	testb  $0x1,(%edx)
f0101365:	75 05                	jne    f010136c <page_remove+0x2b>
}
f0101367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010136a:	c9                   	leave  
f010136b:	c3                   	ret    
  page_decref(pg);
f010136c:	83 ec 0c             	sub    $0xc,%esp
f010136f:	50                   	push   %eax
f0101370:	e8 f6 fd ff ff       	call   f010116b <page_decref>
  *pte = 0;
f0101375:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101378:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010137e:	0f 01 3b             	invlpg (%ebx)
f0101381:	83 c4 10             	add    $0x10,%esp
f0101384:	eb e1                	jmp    f0101367 <page_remove+0x26>

f0101386 <page_insert>:
int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm) {
f0101386:	55                   	push   %ebp
f0101387:	89 e5                	mov    %esp,%ebp
f0101389:	57                   	push   %edi
f010138a:	56                   	push   %esi
f010138b:	53                   	push   %ebx
f010138c:	83 ec 10             	sub    $0x10,%esp
f010138f:	e8 d4 1b 00 00       	call   f0102f68 <__x86.get_pc_thunk.di>
f0101394:	81 c7 74 5f 01 00    	add    $0x15f74,%edi
f010139a:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t *pte = pgdir_walk(pgdir, va, 1); // create on demand
f010139d:	6a 01                	push   $0x1
f010139f:	ff 75 10             	pushl  0x10(%ebp)
f01013a2:	ff 75 08             	pushl  0x8(%ebp)
f01013a5:	e8 e4 fd ff ff       	call   f010118e <pgdir_walk>
  if (!pte)                              // page table not allocated
f01013aa:	83 c4 10             	add    $0x10,%esp
f01013ad:	85 c0                	test   %eax,%eax
f01013af:	74 46                	je     f01013f7 <page_insert+0x71>
f01013b1:	89 c3                	mov    %eax,%ebx
  pp->pp_ref++;
f01013b3:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
  if (*pte & PTE_P) // page colides, tle is invalidated in page_remove
f01013b8:	f6 00 01             	testb  $0x1,(%eax)
f01013bb:	75 27                	jne    f01013e4 <page_insert+0x5e>
  return (pp - pages) << PGSHIFT;
f01013bd:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f01013c3:	2b 30                	sub    (%eax),%esi
f01013c5:	89 f0                	mov    %esi,%eax
f01013c7:	c1 f8 03             	sar    $0x3,%eax
f01013ca:	c1 e0 0c             	shl    $0xc,%eax
  *pte = page2pa(pp) | perm | PTE_P;
f01013cd:	8b 55 14             	mov    0x14(%ebp),%edx
f01013d0:	83 ca 01             	or     $0x1,%edx
f01013d3:	09 d0                	or     %edx,%eax
f01013d5:	89 03                	mov    %eax,(%ebx)
  return 0;
f01013d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013df:	5b                   	pop    %ebx
f01013e0:	5e                   	pop    %esi
f01013e1:	5f                   	pop    %edi
f01013e2:	5d                   	pop    %ebp
f01013e3:	c3                   	ret    
    page_remove(pgdir, va);
f01013e4:	83 ec 08             	sub    $0x8,%esp
f01013e7:	ff 75 10             	pushl  0x10(%ebp)
f01013ea:	ff 75 08             	pushl  0x8(%ebp)
f01013ed:	e8 4f ff ff ff       	call   f0101341 <page_remove>
f01013f2:	83 c4 10             	add    $0x10,%esp
f01013f5:	eb c6                	jmp    f01013bd <page_insert+0x37>
    return -E_NO_MEM;
f01013f7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01013fc:	eb de                	jmp    f01013dc <page_insert+0x56>

f01013fe <mem_init>:
void mem_init(void) {
f01013fe:	55                   	push   %ebp
f01013ff:	89 e5                	mov    %esp,%ebp
f0101401:	57                   	push   %edi
f0101402:	56                   	push   %esi
f0101403:	53                   	push   %ebx
f0101404:	83 ec 48             	sub    $0x48,%esp
f0101407:	e8 a9 ed ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010140c:	81 c3 fc 5e 01 00    	add    $0x15efc,%ebx
  return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101412:	6a 15                	push   $0x15
f0101414:	e8 53 1b 00 00       	call   f0102f6c <mc146818_read>
f0101419:	89 c6                	mov    %eax,%esi
f010141b:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101422:	e8 45 1b 00 00       	call   f0102f6c <mc146818_read>
f0101427:	c1 e0 08             	shl    $0x8,%eax
f010142a:	09 f0                	or     %esi,%eax
  npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010142c:	c1 e0 0a             	shl    $0xa,%eax
f010142f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101435:	85 c0                	test   %eax,%eax
f0101437:	0f 48 c2             	cmovs  %edx,%eax
f010143a:	c1 f8 0c             	sar    $0xc,%eax
f010143d:	89 83 98 1f 00 00    	mov    %eax,0x1f98(%ebx)
  return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101443:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010144a:	e8 1d 1b 00 00       	call   f0102f6c <mc146818_read>
f010144f:	89 c6                	mov    %eax,%esi
f0101451:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101458:	e8 0f 1b 00 00       	call   f0102f6c <mc146818_read>
f010145d:	c1 e0 08             	shl    $0x8,%eax
f0101460:	09 f0                	or     %esi,%eax
  npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101462:	c1 e0 0a             	shl    $0xa,%eax
f0101465:	89 c2                	mov    %eax,%edx
f0101467:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f010146d:	83 c4 10             	add    $0x10,%esp
f0101470:	85 d2                	test   %edx,%edx
f0101472:	0f 49 c2             	cmovns %edx,%eax
f0101475:	c1 f8 0c             	sar    $0xc,%eax
  if (npages_extmem)
f0101478:	85 c0                	test   %eax,%eax
f010147a:	0f 85 b3 00 00 00    	jne    f0101533 <mem_init+0x135>
    npages = npages_basemem;
f0101480:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0101486:	8b 8b 98 1f 00 00    	mov    0x1f98(%ebx),%ecx
f010148c:	89 0a                	mov    %ecx,(%edx)
          npages_extmem * PGSIZE / 1024);
f010148e:	c1 e0 0c             	shl    $0xc,%eax
  cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101491:	c1 e8 0a             	shr    $0xa,%eax
f0101494:	50                   	push   %eax
          npages * PGSIZE / 1024, npages_basemem * PGSIZE / 1024,
f0101495:	8b 83 98 1f 00 00    	mov    0x1f98(%ebx),%eax
f010149b:	c1 e0 0c             	shl    $0xc,%eax
  cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010149e:	c1 e8 0a             	shr    $0xa,%eax
f01014a1:	50                   	push   %eax
          npages * PGSIZE / 1024, npages_basemem * PGSIZE / 1024,
f01014a2:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f01014a8:	8b 00                	mov    (%eax),%eax
f01014aa:	c1 e0 0c             	shl    $0xc,%eax
  cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014ad:	c1 e8 0a             	shr    $0xa,%eax
f01014b0:	50                   	push   %eax
f01014b1:	8d 83 dc d3 fe ff    	lea    -0x12c24(%ebx),%eax
f01014b7:	50                   	push   %eax
f01014b8:	e8 36 1b 00 00       	call   f0102ff3 <cprintf>
  kern_pgdir = (pde_t *)boot_alloc(PGSIZE);
f01014bd:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014c2:	e8 d2 f6 ff ff       	call   f0100b99 <boot_alloc>
f01014c7:	c7 c6 d0 96 11 f0    	mov    $0xf01196d0,%esi
f01014cd:	89 06                	mov    %eax,(%esi)
  memset(kern_pgdir, 0, PGSIZE);
f01014cf:	83 c4 0c             	add    $0xc,%esp
f01014d2:	68 00 10 00 00       	push   $0x1000
f01014d7:	6a 00                	push   $0x0
f01014d9:	50                   	push   %eax
f01014da:	e8 7e 27 00 00       	call   f0103c5d <memset>
  kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014df:	8b 06                	mov    (%esi),%eax
  if ((uint32_t)kva < KERNBASE)
f01014e1:	83 c4 10             	add    $0x10,%esp
f01014e4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014e9:	76 5b                	jbe    f0101546 <mem_init+0x148>
  return (physaddr_t)kva - KERNBASE;
f01014eb:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01014f1:	83 ca 05             	or     $0x5,%edx
f01014f4:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
  pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f01014fa:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0101500:	8b 00                	mov    (%eax),%eax
f0101502:	c1 e0 03             	shl    $0x3,%eax
f0101505:	e8 8f f6 ff ff       	call   f0100b99 <boot_alloc>
f010150a:	c7 c6 d4 96 11 f0    	mov    $0xf01196d4,%esi
f0101510:	89 06                	mov    %eax,(%esi)
  page_init();
f0101512:	e8 db fa ff ff       	call   f0100ff2 <page_init>
  check_page_free_list(1);
f0101517:	b8 01 00 00 00       	mov    $0x1,%eax
f010151c:	e8 4e f7 ff ff       	call   f0100c6f <check_page_free_list>
  if (!pages)
f0101521:	83 3e 00             	cmpl   $0x0,(%esi)
f0101524:	74 39                	je     f010155f <mem_init+0x161>
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101526:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f010152c:	be 00 00 00 00       	mov    $0x0,%esi
f0101531:	eb 4c                	jmp    f010157f <mem_init+0x181>
    npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101533:	8d 88 00 01 00 00    	lea    0x100(%eax),%ecx
f0101539:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f010153f:	89 0a                	mov    %ecx,(%edx)
f0101541:	e9 48 ff ff ff       	jmp    f010148e <mem_init+0x90>
    _panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101546:	50                   	push   %eax
f0101547:	8d 83 18 d4 fe ff    	lea    -0x12be8(%ebx),%eax
f010154d:	50                   	push   %eax
f010154e:	68 87 00 00 00       	push   $0x87
f0101553:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0101559:	50                   	push   %eax
f010155a:	e8 a0 eb ff ff       	call   f01000ff <_panic>
    panic("'pages' is a null pointer!");
f010155f:	83 ec 04             	sub    $0x4,%esp
f0101562:	8d 83 21 db fe ff    	lea    -0x124df(%ebx),%eax
f0101568:	50                   	push   %eax
f0101569:	68 2c 02 00 00       	push   $0x22c
f010156e:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0101574:	50                   	push   %eax
f0101575:	e8 85 eb ff ff       	call   f01000ff <_panic>
    ++nfree;
f010157a:	83 c6 01             	add    $0x1,%esi
  for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010157d:	8b 00                	mov    (%eax),%eax
f010157f:	85 c0                	test   %eax,%eax
f0101581:	75 f7                	jne    f010157a <mem_init+0x17c>
  assert((pp0 = page_alloc(0)));
f0101583:	83 ec 0c             	sub    $0xc,%esp
f0101586:	6a 00                	push   $0x0
f0101588:	e8 3c fb ff ff       	call   f01010c9 <page_alloc>
f010158d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101590:	83 c4 10             	add    $0x10,%esp
f0101593:	85 c0                	test   %eax,%eax
f0101595:	0f 84 2e 02 00 00    	je     f01017c9 <mem_init+0x3cb>
  assert((pp1 = page_alloc(0)));
f010159b:	83 ec 0c             	sub    $0xc,%esp
f010159e:	6a 00                	push   $0x0
f01015a0:	e8 24 fb ff ff       	call   f01010c9 <page_alloc>
f01015a5:	89 c7                	mov    %eax,%edi
f01015a7:	83 c4 10             	add    $0x10,%esp
f01015aa:	85 c0                	test   %eax,%eax
f01015ac:	0f 84 36 02 00 00    	je     f01017e8 <mem_init+0x3ea>
  assert((pp2 = page_alloc(0)));
f01015b2:	83 ec 0c             	sub    $0xc,%esp
f01015b5:	6a 00                	push   $0x0
f01015b7:	e8 0d fb ff ff       	call   f01010c9 <page_alloc>
f01015bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01015bf:	83 c4 10             	add    $0x10,%esp
f01015c2:	85 c0                	test   %eax,%eax
f01015c4:	0f 84 3d 02 00 00    	je     f0101807 <mem_init+0x409>
  assert(pp1 && pp1 != pp0);
f01015ca:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f01015cd:	0f 84 53 02 00 00    	je     f0101826 <mem_init+0x428>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015d6:	39 c7                	cmp    %eax,%edi
f01015d8:	0f 84 67 02 00 00    	je     f0101845 <mem_init+0x447>
f01015de:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01015e1:	0f 84 5e 02 00 00    	je     f0101845 <mem_init+0x447>
  return (pp - pages) << PGSHIFT;
f01015e7:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f01015ed:	8b 08                	mov    (%eax),%ecx
  assert(page2pa(pp0) < npages * PGSIZE);
f01015ef:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f01015f5:	8b 10                	mov    (%eax),%edx
f01015f7:	c1 e2 0c             	shl    $0xc,%edx
f01015fa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015fd:	29 c8                	sub    %ecx,%eax
f01015ff:	c1 f8 03             	sar    $0x3,%eax
f0101602:	c1 e0 0c             	shl    $0xc,%eax
f0101605:	39 d0                	cmp    %edx,%eax
f0101607:	0f 83 57 02 00 00    	jae    f0101864 <mem_init+0x466>
f010160d:	89 f8                	mov    %edi,%eax
f010160f:	29 c8                	sub    %ecx,%eax
f0101611:	c1 f8 03             	sar    $0x3,%eax
f0101614:	c1 e0 0c             	shl    $0xc,%eax
  assert(page2pa(pp1) < npages * PGSIZE);
f0101617:	39 c2                	cmp    %eax,%edx
f0101619:	0f 86 64 02 00 00    	jbe    f0101883 <mem_init+0x485>
f010161f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101622:	29 c8                	sub    %ecx,%eax
f0101624:	c1 f8 03             	sar    $0x3,%eax
f0101627:	c1 e0 0c             	shl    $0xc,%eax
  assert(page2pa(pp2) < npages * PGSIZE);
f010162a:	39 c2                	cmp    %eax,%edx
f010162c:	0f 86 70 02 00 00    	jbe    f01018a2 <mem_init+0x4a4>
  fl = page_free_list;
f0101632:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f0101638:	89 45 cc             	mov    %eax,-0x34(%ebp)
  page_free_list = 0;
f010163b:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f0101642:	00 00 00 
  assert(!page_alloc(0));
f0101645:	83 ec 0c             	sub    $0xc,%esp
f0101648:	6a 00                	push   $0x0
f010164a:	e8 7a fa ff ff       	call   f01010c9 <page_alloc>
f010164f:	83 c4 10             	add    $0x10,%esp
f0101652:	85 c0                	test   %eax,%eax
f0101654:	0f 85 67 02 00 00    	jne    f01018c1 <mem_init+0x4c3>
  page_free(pp0);
f010165a:	83 ec 0c             	sub    $0xc,%esp
f010165d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101660:	e8 e6 fa ff ff       	call   f010114b <page_free>
  page_free(pp1);
f0101665:	89 3c 24             	mov    %edi,(%esp)
f0101668:	e8 de fa ff ff       	call   f010114b <page_free>
  page_free(pp2);
f010166d:	83 c4 04             	add    $0x4,%esp
f0101670:	ff 75 d0             	pushl  -0x30(%ebp)
f0101673:	e8 d3 fa ff ff       	call   f010114b <page_free>
  assert((pp0 = page_alloc(0)));
f0101678:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010167f:	e8 45 fa ff ff       	call   f01010c9 <page_alloc>
f0101684:	89 c7                	mov    %eax,%edi
f0101686:	83 c4 10             	add    $0x10,%esp
f0101689:	85 c0                	test   %eax,%eax
f010168b:	0f 84 4f 02 00 00    	je     f01018e0 <mem_init+0x4e2>
  assert((pp1 = page_alloc(0)));
f0101691:	83 ec 0c             	sub    $0xc,%esp
f0101694:	6a 00                	push   $0x0
f0101696:	e8 2e fa ff ff       	call   f01010c9 <page_alloc>
f010169b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010169e:	83 c4 10             	add    $0x10,%esp
f01016a1:	85 c0                	test   %eax,%eax
f01016a3:	0f 84 56 02 00 00    	je     f01018ff <mem_init+0x501>
  assert((pp2 = page_alloc(0)));
f01016a9:	83 ec 0c             	sub    $0xc,%esp
f01016ac:	6a 00                	push   $0x0
f01016ae:	e8 16 fa ff ff       	call   f01010c9 <page_alloc>
f01016b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01016b6:	83 c4 10             	add    $0x10,%esp
f01016b9:	85 c0                	test   %eax,%eax
f01016bb:	0f 84 5d 02 00 00    	je     f010191e <mem_init+0x520>
  assert(pp1 && pp1 != pp0);
f01016c1:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01016c4:	0f 84 73 02 00 00    	je     f010193d <mem_init+0x53f>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016ca:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016cd:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01016d0:	0f 84 86 02 00 00    	je     f010195c <mem_init+0x55e>
f01016d6:	39 c7                	cmp    %eax,%edi
f01016d8:	0f 84 7e 02 00 00    	je     f010195c <mem_init+0x55e>
  assert(!page_alloc(0));
f01016de:	83 ec 0c             	sub    $0xc,%esp
f01016e1:	6a 00                	push   $0x0
f01016e3:	e8 e1 f9 ff ff       	call   f01010c9 <page_alloc>
f01016e8:	83 c4 10             	add    $0x10,%esp
f01016eb:	85 c0                	test   %eax,%eax
f01016ed:	0f 85 88 02 00 00    	jne    f010197b <mem_init+0x57d>
f01016f3:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f01016f9:	89 f9                	mov    %edi,%ecx
f01016fb:	2b 08                	sub    (%eax),%ecx
f01016fd:	89 c8                	mov    %ecx,%eax
f01016ff:	c1 f8 03             	sar    $0x3,%eax
f0101702:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f0101705:	89 c1                	mov    %eax,%ecx
f0101707:	c1 e9 0c             	shr    $0xc,%ecx
f010170a:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0101710:	3b 0a                	cmp    (%edx),%ecx
f0101712:	0f 83 82 02 00 00    	jae    f010199a <mem_init+0x59c>
  memset(page2kva(pp0), 1, PGSIZE);
f0101718:	83 ec 04             	sub    $0x4,%esp
f010171b:	68 00 10 00 00       	push   $0x1000
f0101720:	6a 01                	push   $0x1
  return (void *)(pa + KERNBASE);
f0101722:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101727:	50                   	push   %eax
f0101728:	e8 30 25 00 00       	call   f0103c5d <memset>
  page_free(pp0);
f010172d:	89 3c 24             	mov    %edi,(%esp)
f0101730:	e8 16 fa ff ff       	call   f010114b <page_free>
  assert((pp = page_alloc(ALLOC_ZERO)));
f0101735:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010173c:	e8 88 f9 ff ff       	call   f01010c9 <page_alloc>
f0101741:	83 c4 10             	add    $0x10,%esp
f0101744:	85 c0                	test   %eax,%eax
f0101746:	0f 84 64 02 00 00    	je     f01019b0 <mem_init+0x5b2>
  assert(pp && pp0 == pp);
f010174c:	39 c7                	cmp    %eax,%edi
f010174e:	0f 85 7b 02 00 00    	jne    f01019cf <mem_init+0x5d1>
  return (pp - pages) << PGSHIFT;
f0101754:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f010175a:	89 fa                	mov    %edi,%edx
f010175c:	2b 10                	sub    (%eax),%edx
f010175e:	c1 fa 03             	sar    $0x3,%edx
f0101761:	c1 e2 0c             	shl    $0xc,%edx
  if (PGNUM(pa) >= npages)
f0101764:	89 d1                	mov    %edx,%ecx
f0101766:	c1 e9 0c             	shr    $0xc,%ecx
f0101769:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f010176f:	3b 08                	cmp    (%eax),%ecx
f0101771:	0f 83 77 02 00 00    	jae    f01019ee <mem_init+0x5f0>
  return (void *)(pa + KERNBASE);
f0101777:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010177d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
    assert(c[i] == 0);
f0101783:	80 38 00             	cmpb   $0x0,(%eax)
f0101786:	0f 85 78 02 00 00    	jne    f0101a04 <mem_init+0x606>
f010178c:	83 c0 01             	add    $0x1,%eax
  for (i = 0; i < PGSIZE; i++)
f010178f:	39 d0                	cmp    %edx,%eax
f0101791:	75 f0                	jne    f0101783 <mem_init+0x385>
  page_free_list = fl;
f0101793:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101796:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
  page_free(pp0);
f010179c:	83 ec 0c             	sub    $0xc,%esp
f010179f:	57                   	push   %edi
f01017a0:	e8 a6 f9 ff ff       	call   f010114b <page_free>
  page_free(pp1);
f01017a5:	83 c4 04             	add    $0x4,%esp
f01017a8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017ab:	e8 9b f9 ff ff       	call   f010114b <page_free>
  page_free(pp2);
f01017b0:	83 c4 04             	add    $0x4,%esp
f01017b3:	ff 75 d0             	pushl  -0x30(%ebp)
f01017b6:	e8 90 f9 ff ff       	call   f010114b <page_free>
  for (pp = page_free_list; pp; pp = pp->pp_link)
f01017bb:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f01017c1:	83 c4 10             	add    $0x10,%esp
f01017c4:	e9 5f 02 00 00       	jmp    f0101a28 <mem_init+0x62a>
  assert((pp0 = page_alloc(0)));
f01017c9:	8d 83 3c db fe ff    	lea    -0x124c4(%ebx),%eax
f01017cf:	50                   	push   %eax
f01017d0:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01017d6:	50                   	push   %eax
f01017d7:	68 34 02 00 00       	push   $0x234
f01017dc:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01017e2:	50                   	push   %eax
f01017e3:	e8 17 e9 ff ff       	call   f01000ff <_panic>
  assert((pp1 = page_alloc(0)));
f01017e8:	8d 83 52 db fe ff    	lea    -0x124ae(%ebx),%eax
f01017ee:	50                   	push   %eax
f01017ef:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01017f5:	50                   	push   %eax
f01017f6:	68 35 02 00 00       	push   $0x235
f01017fb:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0101801:	50                   	push   %eax
f0101802:	e8 f8 e8 ff ff       	call   f01000ff <_panic>
  assert((pp2 = page_alloc(0)));
f0101807:	8d 83 68 db fe ff    	lea    -0x12498(%ebx),%eax
f010180d:	50                   	push   %eax
f010180e:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0101814:	50                   	push   %eax
f0101815:	68 36 02 00 00       	push   $0x236
f010181a:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0101820:	50                   	push   %eax
f0101821:	e8 d9 e8 ff ff       	call   f01000ff <_panic>
  assert(pp1 && pp1 != pp0);
f0101826:	8d 83 7e db fe ff    	lea    -0x12482(%ebx),%eax
f010182c:	50                   	push   %eax
f010182d:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0101833:	50                   	push   %eax
f0101834:	68 39 02 00 00       	push   $0x239
f0101839:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010183f:	50                   	push   %eax
f0101840:	e8 ba e8 ff ff       	call   f01000ff <_panic>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101845:	8d 83 3c d4 fe ff    	lea    -0x12bc4(%ebx),%eax
f010184b:	50                   	push   %eax
f010184c:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0101852:	50                   	push   %eax
f0101853:	68 3a 02 00 00       	push   $0x23a
f0101858:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010185e:	50                   	push   %eax
f010185f:	e8 9b e8 ff ff       	call   f01000ff <_panic>
  assert(page2pa(pp0) < npages * PGSIZE);
f0101864:	8d 83 5c d4 fe ff    	lea    -0x12ba4(%ebx),%eax
f010186a:	50                   	push   %eax
f010186b:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0101871:	50                   	push   %eax
f0101872:	68 3b 02 00 00       	push   $0x23b
f0101877:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010187d:	50                   	push   %eax
f010187e:	e8 7c e8 ff ff       	call   f01000ff <_panic>
  assert(page2pa(pp1) < npages * PGSIZE);
f0101883:	8d 83 7c d4 fe ff    	lea    -0x12b84(%ebx),%eax
f0101889:	50                   	push   %eax
f010188a:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0101890:	50                   	push   %eax
f0101891:	68 3c 02 00 00       	push   $0x23c
f0101896:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010189c:	50                   	push   %eax
f010189d:	e8 5d e8 ff ff       	call   f01000ff <_panic>
  assert(page2pa(pp2) < npages * PGSIZE);
f01018a2:	8d 83 9c d4 fe ff    	lea    -0x12b64(%ebx),%eax
f01018a8:	50                   	push   %eax
f01018a9:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01018af:	50                   	push   %eax
f01018b0:	68 3d 02 00 00       	push   $0x23d
f01018b5:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01018bb:	50                   	push   %eax
f01018bc:	e8 3e e8 ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f01018c1:	8d 83 90 db fe ff    	lea    -0x12470(%ebx),%eax
f01018c7:	50                   	push   %eax
f01018c8:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01018ce:	50                   	push   %eax
f01018cf:	68 44 02 00 00       	push   $0x244
f01018d4:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01018da:	50                   	push   %eax
f01018db:	e8 1f e8 ff ff       	call   f01000ff <_panic>
  assert((pp0 = page_alloc(0)));
f01018e0:	8d 83 3c db fe ff    	lea    -0x124c4(%ebx),%eax
f01018e6:	50                   	push   %eax
f01018e7:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01018ed:	50                   	push   %eax
f01018ee:	68 4b 02 00 00       	push   $0x24b
f01018f3:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01018f9:	50                   	push   %eax
f01018fa:	e8 00 e8 ff ff       	call   f01000ff <_panic>
  assert((pp1 = page_alloc(0)));
f01018ff:	8d 83 52 db fe ff    	lea    -0x124ae(%ebx),%eax
f0101905:	50                   	push   %eax
f0101906:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010190c:	50                   	push   %eax
f010190d:	68 4c 02 00 00       	push   $0x24c
f0101912:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0101918:	50                   	push   %eax
f0101919:	e8 e1 e7 ff ff       	call   f01000ff <_panic>
  assert((pp2 = page_alloc(0)));
f010191e:	8d 83 68 db fe ff    	lea    -0x12498(%ebx),%eax
f0101924:	50                   	push   %eax
f0101925:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010192b:	50                   	push   %eax
f010192c:	68 4d 02 00 00       	push   $0x24d
f0101931:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0101937:	50                   	push   %eax
f0101938:	e8 c2 e7 ff ff       	call   f01000ff <_panic>
  assert(pp1 && pp1 != pp0);
f010193d:	8d 83 7e db fe ff    	lea    -0x12482(%ebx),%eax
f0101943:	50                   	push   %eax
f0101944:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010194a:	50                   	push   %eax
f010194b:	68 4f 02 00 00       	push   $0x24f
f0101950:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0101956:	50                   	push   %eax
f0101957:	e8 a3 e7 ff ff       	call   f01000ff <_panic>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010195c:	8d 83 3c d4 fe ff    	lea    -0x12bc4(%ebx),%eax
f0101962:	50                   	push   %eax
f0101963:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0101969:	50                   	push   %eax
f010196a:	68 50 02 00 00       	push   $0x250
f010196f:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0101975:	50                   	push   %eax
f0101976:	e8 84 e7 ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f010197b:	8d 83 90 db fe ff    	lea    -0x12470(%ebx),%eax
f0101981:	50                   	push   %eax
f0101982:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0101988:	50                   	push   %eax
f0101989:	68 51 02 00 00       	push   $0x251
f010198e:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0101994:	50                   	push   %eax
f0101995:	e8 65 e7 ff ff       	call   f01000ff <_panic>
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010199a:	50                   	push   %eax
f010199b:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f01019a1:	50                   	push   %eax
f01019a2:	6a 3f                	push   $0x3f
f01019a4:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f01019aa:	50                   	push   %eax
f01019ab:	e8 4f e7 ff ff       	call   f01000ff <_panic>
  assert((pp = page_alloc(ALLOC_ZERO)));
f01019b0:	8d 83 9f db fe ff    	lea    -0x12461(%ebx),%eax
f01019b6:	50                   	push   %eax
f01019b7:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01019bd:	50                   	push   %eax
f01019be:	68 56 02 00 00       	push   $0x256
f01019c3:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01019c9:	50                   	push   %eax
f01019ca:	e8 30 e7 ff ff       	call   f01000ff <_panic>
  assert(pp && pp0 == pp);
f01019cf:	8d 83 bd db fe ff    	lea    -0x12443(%ebx),%eax
f01019d5:	50                   	push   %eax
f01019d6:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01019dc:	50                   	push   %eax
f01019dd:	68 57 02 00 00       	push   $0x257
f01019e2:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01019e8:	50                   	push   %eax
f01019e9:	e8 11 e7 ff ff       	call   f01000ff <_panic>
f01019ee:	52                   	push   %edx
f01019ef:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f01019f5:	50                   	push   %eax
f01019f6:	6a 3f                	push   $0x3f
f01019f8:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f01019fe:	50                   	push   %eax
f01019ff:	e8 fb e6 ff ff       	call   f01000ff <_panic>
    assert(c[i] == 0);
f0101a04:	8d 83 cd db fe ff    	lea    -0x12433(%ebx),%eax
f0101a0a:	50                   	push   %eax
f0101a0b:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0101a11:	50                   	push   %eax
f0101a12:	68 5a 02 00 00       	push   $0x25a
f0101a17:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0101a1d:	50                   	push   %eax
f0101a1e:	e8 dc e6 ff ff       	call   f01000ff <_panic>
    --nfree;
f0101a23:	83 ee 01             	sub    $0x1,%esi
  for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a26:	8b 00                	mov    (%eax),%eax
f0101a28:	85 c0                	test   %eax,%eax
f0101a2a:	75 f7                	jne    f0101a23 <mem_init+0x625>
  assert(nfree == 0);
f0101a2c:	85 f6                	test   %esi,%esi
f0101a2e:	0f 85 38 08 00 00    	jne    f010226c <mem_init+0xe6e>
  cprintf("check_page_alloc() succeeded!\n");
f0101a34:	83 ec 0c             	sub    $0xc,%esp
f0101a37:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0101a3d:	50                   	push   %eax
f0101a3e:	e8 b0 15 00 00       	call   f0102ff3 <cprintf>
  cprintf("so far so good\n");
f0101a43:	8d 83 e2 db fe ff    	lea    -0x1241e(%ebx),%eax
f0101a49:	89 04 24             	mov    %eax,(%esp)
f0101a4c:	e8 a2 15 00 00       	call   f0102ff3 <cprintf>
  int i;
  extern pde_t entry_pgdir[];

  // should be able to allocate three pages
  pp0 = pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
f0101a51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a58:	e8 6c f6 ff ff       	call   f01010c9 <page_alloc>
f0101a5d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a60:	83 c4 10             	add    $0x10,%esp
f0101a63:	85 c0                	test   %eax,%eax
f0101a65:	0f 84 20 08 00 00    	je     f010228b <mem_init+0xe8d>
  assert((pp1 = page_alloc(0)));
f0101a6b:	83 ec 0c             	sub    $0xc,%esp
f0101a6e:	6a 00                	push   $0x0
f0101a70:	e8 54 f6 ff ff       	call   f01010c9 <page_alloc>
f0101a75:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a78:	83 c4 10             	add    $0x10,%esp
f0101a7b:	85 c0                	test   %eax,%eax
f0101a7d:	0f 84 27 08 00 00    	je     f01022aa <mem_init+0xeac>
  assert((pp2 = page_alloc(0)));
f0101a83:	83 ec 0c             	sub    $0xc,%esp
f0101a86:	6a 00                	push   $0x0
f0101a88:	e8 3c f6 ff ff       	call   f01010c9 <page_alloc>
f0101a8d:	89 c7                	mov    %eax,%edi
f0101a8f:	83 c4 10             	add    $0x10,%esp
f0101a92:	85 c0                	test   %eax,%eax
f0101a94:	0f 84 2f 08 00 00    	je     f01022c9 <mem_init+0xecb>

  assert(pp0);
  assert(pp1 && pp1 != pp0);
f0101a9a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101a9d:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
f0101aa0:	0f 84 42 08 00 00    	je     f01022e8 <mem_init+0xeea>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101aa6:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101aa9:	0f 84 58 08 00 00    	je     f0102307 <mem_init+0xf09>
f0101aaf:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101ab2:	0f 84 4f 08 00 00    	je     f0102307 <mem_init+0xf09>

  // temporarily steal the rest of the free pages
  fl = page_free_list;
f0101ab8:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
f0101abe:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  page_free_list = 0;
f0101ac1:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f0101ac8:	00 00 00 

  // should be no free memory
  assert(!page_alloc(0));
f0101acb:	83 ec 0c             	sub    $0xc,%esp
f0101ace:	6a 00                	push   $0x0
f0101ad0:	e8 f4 f5 ff ff       	call   f01010c9 <page_alloc>
f0101ad5:	83 c4 10             	add    $0x10,%esp
f0101ad8:	85 c0                	test   %eax,%eax
f0101ada:	0f 85 46 08 00 00    	jne    f0102326 <mem_init+0xf28>

  // there is no page allocated at address 0
  assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0101ae0:	83 ec 04             	sub    $0x4,%esp
f0101ae3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ae6:	50                   	push   %eax
f0101ae7:	6a 00                	push   $0x0
f0101ae9:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101aef:	ff 30                	pushl  (%eax)
f0101af1:	e8 cf f7 ff ff       	call   f01012c5 <page_lookup>
f0101af6:	83 c4 10             	add    $0x10,%esp
f0101af9:	85 c0                	test   %eax,%eax
f0101afb:	0f 85 44 08 00 00    	jne    f0102345 <mem_init+0xf47>

  // there is no free memory, so we can't allocate a page table
  assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b01:	6a 02                	push   $0x2
f0101b03:	6a 00                	push   $0x0
f0101b05:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b08:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101b0e:	ff 30                	pushl  (%eax)
f0101b10:	e8 71 f8 ff ff       	call   f0101386 <page_insert>
f0101b15:	83 c4 10             	add    $0x10,%esp
f0101b18:	85 c0                	test   %eax,%eax
f0101b1a:	0f 89 44 08 00 00    	jns    f0102364 <mem_init+0xf66>

  // free pp0 and try again: pp0 should be used for page table
  page_free(pp0);
f0101b20:	83 ec 0c             	sub    $0xc,%esp
f0101b23:	ff 75 d0             	pushl  -0x30(%ebp)
f0101b26:	e8 20 f6 ff ff       	call   f010114b <page_free>
  assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b2b:	6a 02                	push   $0x2
f0101b2d:	6a 00                	push   $0x0
f0101b2f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b32:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101b38:	ff 30                	pushl  (%eax)
f0101b3a:	e8 47 f8 ff ff       	call   f0101386 <page_insert>
f0101b3f:	83 c4 20             	add    $0x20,%esp
f0101b42:	85 c0                	test   %eax,%eax
f0101b44:	0f 85 39 08 00 00    	jne    f0102383 <mem_init+0xf85>
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b4a:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101b50:	8b 08                	mov    (%eax),%ecx
f0101b52:	89 ce                	mov    %ecx,%esi
  return (pp - pages) << PGSHIFT;
f0101b54:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0101b5a:	8b 00                	mov    (%eax),%eax
f0101b5c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b5f:	8b 09                	mov    (%ecx),%ecx
f0101b61:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101b64:	89 ca                	mov    %ecx,%edx
f0101b66:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b6c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101b6f:	29 c1                	sub    %eax,%ecx
f0101b71:	89 c8                	mov    %ecx,%eax
f0101b73:	c1 f8 03             	sar    $0x3,%eax
f0101b76:	c1 e0 0c             	shl    $0xc,%eax
f0101b79:	39 c2                	cmp    %eax,%edx
f0101b7b:	0f 85 21 08 00 00    	jne    f01023a2 <mem_init+0xfa4>
  assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b81:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b86:	89 f0                	mov    %esi,%eax
f0101b88:	e8 65 f0 ff ff       	call   f0100bf2 <check_va2pa>
f0101b8d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101b90:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b93:	c1 fa 03             	sar    $0x3,%edx
f0101b96:	c1 e2 0c             	shl    $0xc,%edx
f0101b99:	39 d0                	cmp    %edx,%eax
f0101b9b:	0f 85 20 08 00 00    	jne    f01023c1 <mem_init+0xfc3>
  assert(pp1->pp_ref == 1);
f0101ba1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ba4:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ba9:	0f 85 31 08 00 00    	jne    f01023e0 <mem_init+0xfe2>
  assert(pp0->pp_ref == 1);
f0101baf:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bb2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101bb7:	0f 85 42 08 00 00    	jne    f01023ff <mem_init+0x1001>

  // should be able to map pp2 at PGSIZE because pp0 is already allocated for
  // page table
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101bbd:	6a 02                	push   $0x2
f0101bbf:	68 00 10 00 00       	push   $0x1000
f0101bc4:	57                   	push   %edi
f0101bc5:	56                   	push   %esi
f0101bc6:	e8 bb f7 ff ff       	call   f0101386 <page_insert>
f0101bcb:	83 c4 10             	add    $0x10,%esp
f0101bce:	85 c0                	test   %eax,%eax
f0101bd0:	0f 85 48 08 00 00    	jne    f010241e <mem_init+0x1020>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bd6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bdb:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101be1:	8b 00                	mov    (%eax),%eax
f0101be3:	e8 0a f0 ff ff       	call   f0100bf2 <check_va2pa>
f0101be8:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f0101bee:	89 f9                	mov    %edi,%ecx
f0101bf0:	2b 0a                	sub    (%edx),%ecx
f0101bf2:	89 ca                	mov    %ecx,%edx
f0101bf4:	c1 fa 03             	sar    $0x3,%edx
f0101bf7:	c1 e2 0c             	shl    $0xc,%edx
f0101bfa:	39 d0                	cmp    %edx,%eax
f0101bfc:	0f 85 3b 08 00 00    	jne    f010243d <mem_init+0x103f>
  assert(pp2->pp_ref == 1);
f0101c02:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c07:	0f 85 4f 08 00 00    	jne    f010245c <mem_init+0x105e>

  // should be no free memory
  assert(!page_alloc(0));
f0101c0d:	83 ec 0c             	sub    $0xc,%esp
f0101c10:	6a 00                	push   $0x0
f0101c12:	e8 b2 f4 ff ff       	call   f01010c9 <page_alloc>
f0101c17:	83 c4 10             	add    $0x10,%esp
f0101c1a:	85 c0                	test   %eax,%eax
f0101c1c:	0f 85 59 08 00 00    	jne    f010247b <mem_init+0x107d>

  // should be able to map pp2 at PGSIZE because it's already there
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101c22:	6a 02                	push   $0x2
f0101c24:	68 00 10 00 00       	push   $0x1000
f0101c29:	57                   	push   %edi
f0101c2a:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101c30:	ff 30                	pushl  (%eax)
f0101c32:	e8 4f f7 ff ff       	call   f0101386 <page_insert>
f0101c37:	83 c4 10             	add    $0x10,%esp
f0101c3a:	85 c0                	test   %eax,%eax
f0101c3c:	0f 85 58 08 00 00    	jne    f010249a <mem_init+0x109c>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c42:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c47:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101c4d:	8b 00                	mov    (%eax),%eax
f0101c4f:	e8 9e ef ff ff       	call   f0100bf2 <check_va2pa>
f0101c54:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f0101c5a:	89 f9                	mov    %edi,%ecx
f0101c5c:	2b 0a                	sub    (%edx),%ecx
f0101c5e:	89 ca                	mov    %ecx,%edx
f0101c60:	c1 fa 03             	sar    $0x3,%edx
f0101c63:	c1 e2 0c             	shl    $0xc,%edx
f0101c66:	39 d0                	cmp    %edx,%eax
f0101c68:	0f 85 4b 08 00 00    	jne    f01024b9 <mem_init+0x10bb>
  assert(pp2->pp_ref == 1);
f0101c6e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c73:	0f 85 5f 08 00 00    	jne    f01024d8 <mem_init+0x10da>

  // pp2 should NOT be on the free list
  // could happen in ref counts are handled sloppily in page_insert
  assert(!page_alloc(0));
f0101c79:	83 ec 0c             	sub    $0xc,%esp
f0101c7c:	6a 00                	push   $0x0
f0101c7e:	e8 46 f4 ff ff       	call   f01010c9 <page_alloc>
f0101c83:	83 c4 10             	add    $0x10,%esp
f0101c86:	85 c0                	test   %eax,%eax
f0101c88:	0f 85 69 08 00 00    	jne    f01024f7 <mem_init+0x10f9>

  // check that pgdir_walk returns a pointer to the pte
  ptep = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c8e:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101c94:	8b 10                	mov    (%eax),%edx
f0101c96:	8b 02                	mov    (%edx),%eax
f0101c98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if (PGNUM(pa) >= npages)
f0101c9d:	89 c1                	mov    %eax,%ecx
f0101c9f:	c1 e9 0c             	shr    $0xc,%ecx
f0101ca2:	89 ce                	mov    %ecx,%esi
f0101ca4:	c7 c1 cc 96 11 f0    	mov    $0xf01196cc,%ecx
f0101caa:	3b 31                	cmp    (%ecx),%esi
f0101cac:	0f 83 64 08 00 00    	jae    f0102516 <mem_init+0x1118>
  return (void *)(pa + KERNBASE);
f0101cb2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cb7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f0101cba:	83 ec 04             	sub    $0x4,%esp
f0101cbd:	6a 00                	push   $0x0
f0101cbf:	68 00 10 00 00       	push   $0x1000
f0101cc4:	52                   	push   %edx
f0101cc5:	e8 c4 f4 ff ff       	call   f010118e <pgdir_walk>
f0101cca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ccd:	8d 51 04             	lea    0x4(%ecx),%edx
f0101cd0:	83 c4 10             	add    $0x10,%esp
f0101cd3:	39 d0                	cmp    %edx,%eax
f0101cd5:	0f 85 54 08 00 00    	jne    f010252f <mem_init+0x1131>

  // should be able to change permissions too.
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f0101cdb:	6a 06                	push   $0x6
f0101cdd:	68 00 10 00 00       	push   $0x1000
f0101ce2:	57                   	push   %edi
f0101ce3:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101ce9:	ff 30                	pushl  (%eax)
f0101ceb:	e8 96 f6 ff ff       	call   f0101386 <page_insert>
f0101cf0:	83 c4 10             	add    $0x10,%esp
f0101cf3:	85 c0                	test   %eax,%eax
f0101cf5:	0f 85 53 08 00 00    	jne    f010254e <mem_init+0x1150>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cfb:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101d01:	8b 00                	mov    (%eax),%eax
f0101d03:	89 c6                	mov    %eax,%esi
f0101d05:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d0a:	e8 e3 ee ff ff       	call   f0100bf2 <check_va2pa>
  return (pp - pages) << PGSHIFT;
f0101d0f:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f0101d15:	89 f9                	mov    %edi,%ecx
f0101d17:	2b 0a                	sub    (%edx),%ecx
f0101d19:	89 ca                	mov    %ecx,%edx
f0101d1b:	c1 fa 03             	sar    $0x3,%edx
f0101d1e:	c1 e2 0c             	shl    $0xc,%edx
f0101d21:	39 d0                	cmp    %edx,%eax
f0101d23:	0f 85 44 08 00 00    	jne    f010256d <mem_init+0x116f>
  assert(pp2->pp_ref == 1);
f0101d29:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d2e:	0f 85 58 08 00 00    	jne    f010258c <mem_init+0x118e>
  assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0101d34:	83 ec 04             	sub    $0x4,%esp
f0101d37:	6a 00                	push   $0x0
f0101d39:	68 00 10 00 00       	push   $0x1000
f0101d3e:	56                   	push   %esi
f0101d3f:	e8 4a f4 ff ff       	call   f010118e <pgdir_walk>
f0101d44:	83 c4 10             	add    $0x10,%esp
f0101d47:	f6 00 04             	testb  $0x4,(%eax)
f0101d4a:	0f 84 5b 08 00 00    	je     f01025ab <mem_init+0x11ad>
  cprintf("pp2 %x\n", pp2);
f0101d50:	83 ec 08             	sub    $0x8,%esp
f0101d53:	57                   	push   %edi
f0101d54:	8d 83 25 dc fe ff    	lea    -0x123db(%ebx),%eax
f0101d5a:	50                   	push   %eax
f0101d5b:	e8 93 12 00 00       	call   f0102ff3 <cprintf>
  cprintf("kern_pgdir %x\n", kern_pgdir);
f0101d60:	83 c4 08             	add    $0x8,%esp
f0101d63:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101d69:	89 c6                	mov    %eax,%esi
f0101d6b:	ff 30                	pushl  (%eax)
f0101d6d:	8d 83 2d dc fe ff    	lea    -0x123d3(%ebx),%eax
f0101d73:	50                   	push   %eax
f0101d74:	e8 7a 12 00 00       	call   f0102ff3 <cprintf>
  cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f0101d79:	83 c4 08             	add    $0x8,%esp
f0101d7c:	8b 06                	mov    (%esi),%eax
f0101d7e:	ff 30                	pushl  (%eax)
f0101d80:	8d 83 3c dc fe ff    	lea    -0x123c4(%ebx),%eax
f0101d86:	50                   	push   %eax
f0101d87:	e8 67 12 00 00       	call   f0102ff3 <cprintf>
  assert(kern_pgdir[0] & PTE_U);
f0101d8c:	8b 06                	mov    (%esi),%eax
f0101d8e:	83 c4 10             	add    $0x10,%esp
f0101d91:	f6 00 04             	testb  $0x4,(%eax)
f0101d94:	0f 84 30 08 00 00    	je     f01025ca <mem_init+0x11cc>

  // should be able to remap with fewer permissions
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101d9a:	6a 02                	push   $0x2
f0101d9c:	68 00 10 00 00       	push   $0x1000
f0101da1:	57                   	push   %edi
f0101da2:	50                   	push   %eax
f0101da3:	e8 de f5 ff ff       	call   f0101386 <page_insert>
f0101da8:	83 c4 10             	add    $0x10,%esp
f0101dab:	85 c0                	test   %eax,%eax
f0101dad:	0f 85 36 08 00 00    	jne    f01025e9 <mem_init+0x11eb>
  assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f0101db3:	83 ec 04             	sub    $0x4,%esp
f0101db6:	6a 00                	push   $0x0
f0101db8:	68 00 10 00 00       	push   $0x1000
f0101dbd:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101dc3:	ff 30                	pushl  (%eax)
f0101dc5:	e8 c4 f3 ff ff       	call   f010118e <pgdir_walk>
f0101dca:	83 c4 10             	add    $0x10,%esp
f0101dcd:	f6 00 02             	testb  $0x2,(%eax)
f0101dd0:	0f 84 32 08 00 00    	je     f0102608 <mem_init+0x120a>
  assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101dd6:	83 ec 04             	sub    $0x4,%esp
f0101dd9:	6a 00                	push   $0x0
f0101ddb:	68 00 10 00 00       	push   $0x1000
f0101de0:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101de6:	ff 30                	pushl  (%eax)
f0101de8:	e8 a1 f3 ff ff       	call   f010118e <pgdir_walk>
f0101ded:	83 c4 10             	add    $0x10,%esp
f0101df0:	f6 00 04             	testb  $0x4,(%eax)
f0101df3:	0f 85 2e 08 00 00    	jne    f0102627 <mem_init+0x1229>

  // should not be able to map at PTSIZE because need free page for page table
  assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0101df9:	6a 02                	push   $0x2
f0101dfb:	68 00 00 40 00       	push   $0x400000
f0101e00:	ff 75 d0             	pushl  -0x30(%ebp)
f0101e03:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101e09:	ff 30                	pushl  (%eax)
f0101e0b:	e8 76 f5 ff ff       	call   f0101386 <page_insert>
f0101e10:	83 c4 10             	add    $0x10,%esp
f0101e13:	85 c0                	test   %eax,%eax
f0101e15:	0f 89 2b 08 00 00    	jns    f0102646 <mem_init+0x1248>

  // insert pp1 at PGSIZE (replacing pp2)
  assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f0101e1b:	6a 02                	push   $0x2
f0101e1d:	68 00 10 00 00       	push   $0x1000
f0101e22:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e25:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101e2b:	ff 30                	pushl  (%eax)
f0101e2d:	e8 54 f5 ff ff       	call   f0101386 <page_insert>
f0101e32:	83 c4 10             	add    $0x10,%esp
f0101e35:	85 c0                	test   %eax,%eax
f0101e37:	0f 85 28 08 00 00    	jne    f0102665 <mem_init+0x1267>
  assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101e3d:	83 ec 04             	sub    $0x4,%esp
f0101e40:	6a 00                	push   $0x0
f0101e42:	68 00 10 00 00       	push   $0x1000
f0101e47:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101e4d:	ff 30                	pushl  (%eax)
f0101e4f:	e8 3a f3 ff ff       	call   f010118e <pgdir_walk>
f0101e54:	83 c4 10             	add    $0x10,%esp
f0101e57:	f6 00 04             	testb  $0x4,(%eax)
f0101e5a:	0f 85 24 08 00 00    	jne    f0102684 <mem_init+0x1286>

  // should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
  assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e60:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101e66:	8b 00                	mov    (%eax),%eax
f0101e68:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e6b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e70:	e8 7d ed ff ff       	call   f0100bf2 <check_va2pa>
f0101e75:	89 c6                	mov    %eax,%esi
f0101e77:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0101e7d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e80:	2b 08                	sub    (%eax),%ecx
f0101e82:	89 c8                	mov    %ecx,%eax
f0101e84:	c1 f8 03             	sar    $0x3,%eax
f0101e87:	c1 e0 0c             	shl    $0xc,%eax
f0101e8a:	39 c6                	cmp    %eax,%esi
f0101e8c:	0f 85 11 08 00 00    	jne    f01026a3 <mem_init+0x12a5>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e92:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e97:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101e9a:	e8 53 ed ff ff       	call   f0100bf2 <check_va2pa>
f0101e9f:	39 c6                	cmp    %eax,%esi
f0101ea1:	0f 85 1b 08 00 00    	jne    f01026c2 <mem_init+0x12c4>
  // ... and ref counts should reflect this
  assert(pp1->pp_ref == 2);
f0101ea7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eaa:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101eaf:	0f 85 2c 08 00 00    	jne    f01026e1 <mem_init+0x12e3>
  assert(pp2->pp_ref == 0);
f0101eb5:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101eba:	0f 85 40 08 00 00    	jne    f0102700 <mem_init+0x1302>

  // pp2 should be returned by page_alloc
  assert((pp = page_alloc(0)) && pp == pp2);
f0101ec0:	83 ec 0c             	sub    $0xc,%esp
f0101ec3:	6a 00                	push   $0x0
f0101ec5:	e8 ff f1 ff ff       	call   f01010c9 <page_alloc>
f0101eca:	83 c4 10             	add    $0x10,%esp
f0101ecd:	39 c7                	cmp    %eax,%edi
f0101ecf:	0f 85 4a 08 00 00    	jne    f010271f <mem_init+0x1321>
f0101ed5:	85 c0                	test   %eax,%eax
f0101ed7:	0f 84 42 08 00 00    	je     f010271f <mem_init+0x1321>

  // unmapping pp1 at 0 should keep pp1 at PGSIZE
  page_remove(kern_pgdir, 0x0);
f0101edd:	83 ec 08             	sub    $0x8,%esp
f0101ee0:	6a 00                	push   $0x0
f0101ee2:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101ee8:	89 c6                	mov    %eax,%esi
f0101eea:	ff 30                	pushl  (%eax)
f0101eec:	e8 50 f4 ff ff       	call   f0101341 <page_remove>
  assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ef1:	8b 06                	mov    (%esi),%eax
f0101ef3:	89 c6                	mov    %eax,%esi
f0101ef5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101efa:	e8 f3 ec ff ff       	call   f0100bf2 <check_va2pa>
f0101eff:	83 c4 10             	add    $0x10,%esp
f0101f02:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f05:	0f 85 33 08 00 00    	jne    f010273e <mem_init+0x1340>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f0b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f10:	89 f0                	mov    %esi,%eax
f0101f12:	e8 db ec ff ff       	call   f0100bf2 <check_va2pa>
f0101f17:	c7 c2 d4 96 11 f0    	mov    $0xf01196d4,%edx
f0101f1d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101f20:	2b 0a                	sub    (%edx),%ecx
f0101f22:	89 ca                	mov    %ecx,%edx
f0101f24:	c1 fa 03             	sar    $0x3,%edx
f0101f27:	c1 e2 0c             	shl    $0xc,%edx
f0101f2a:	39 d0                	cmp    %edx,%eax
f0101f2c:	0f 85 2b 08 00 00    	jne    f010275d <mem_init+0x135f>
  assert(pp1->pp_ref == 1);
f0101f32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f35:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f3a:	0f 85 3c 08 00 00    	jne    f010277c <mem_init+0x137e>
  assert(pp2->pp_ref == 0);
f0101f40:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f45:	0f 85 50 08 00 00    	jne    f010279b <mem_init+0x139d>

  // unmapping pp1 at PGSIZE should free it
  page_remove(kern_pgdir, (void *)PGSIZE);
f0101f4b:	83 ec 08             	sub    $0x8,%esp
f0101f4e:	68 00 10 00 00       	push   $0x1000
f0101f53:	56                   	push   %esi
f0101f54:	e8 e8 f3 ff ff       	call   f0101341 <page_remove>
  assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f59:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101f5f:	8b 00                	mov    (%eax),%eax
f0101f61:	89 c6                	mov    %eax,%esi
f0101f63:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f68:	e8 85 ec ff ff       	call   f0100bf2 <check_va2pa>
f0101f6d:	83 c4 10             	add    $0x10,%esp
f0101f70:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f73:	0f 85 41 08 00 00    	jne    f01027ba <mem_init+0x13bc>
  assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f79:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f7e:	89 f0                	mov    %esi,%eax
f0101f80:	e8 6d ec ff ff       	call   f0100bf2 <check_va2pa>
f0101f85:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f88:	0f 85 4b 08 00 00    	jne    f01027d9 <mem_init+0x13db>
  assert(pp1->pp_ref == 0);
f0101f8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f91:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101f96:	0f 85 5c 08 00 00    	jne    f01027f8 <mem_init+0x13fa>
  assert(pp2->pp_ref == 0);
f0101f9c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101fa1:	0f 85 70 08 00 00    	jne    f0102817 <mem_init+0x1419>

  // so it should be returned by page_alloc
  assert((pp = page_alloc(0)) && pp == pp1);
f0101fa7:	83 ec 0c             	sub    $0xc,%esp
f0101faa:	6a 00                	push   $0x0
f0101fac:	e8 18 f1 ff ff       	call   f01010c9 <page_alloc>
f0101fb1:	83 c4 10             	add    $0x10,%esp
f0101fb4:	85 c0                	test   %eax,%eax
f0101fb6:	0f 84 7a 08 00 00    	je     f0102836 <mem_init+0x1438>
f0101fbc:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101fbf:	0f 85 71 08 00 00    	jne    f0102836 <mem_init+0x1438>

  // should be no free memory
  assert(!page_alloc(0));
f0101fc5:	83 ec 0c             	sub    $0xc,%esp
f0101fc8:	6a 00                	push   $0x0
f0101fca:	e8 fa f0 ff ff       	call   f01010c9 <page_alloc>
f0101fcf:	83 c4 10             	add    $0x10,%esp
f0101fd2:	85 c0                	test   %eax,%eax
f0101fd4:	0f 85 7b 08 00 00    	jne    f0102855 <mem_init+0x1457>

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101fda:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0101fe0:	8b 08                	mov    (%eax),%ecx
f0101fe2:	8b 11                	mov    (%ecx),%edx
f0101fe4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101fea:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0101ff0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101ff3:	2b 30                	sub    (%eax),%esi
f0101ff5:	89 f0                	mov    %esi,%eax
f0101ff7:	c1 f8 03             	sar    $0x3,%eax
f0101ffa:	c1 e0 0c             	shl    $0xc,%eax
f0101ffd:	39 c2                	cmp    %eax,%edx
f0101fff:	0f 85 6f 08 00 00    	jne    f0102874 <mem_init+0x1476>
  kern_pgdir[0] = 0;
f0102005:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  assert(pp0->pp_ref == 1);
f010200b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010200e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102013:	0f 85 7a 08 00 00    	jne    f0102893 <mem_init+0x1495>
  pp0->pp_ref = 0;
f0102019:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010201c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

  // check pointer arithmetic in pgdir_walk
  page_free(pp0);
f0102022:	83 ec 0c             	sub    $0xc,%esp
f0102025:	50                   	push   %eax
f0102026:	e8 20 f1 ff ff       	call   f010114b <page_free>
  va = (void *)(PGSIZE * NPDENTRIES + PGSIZE);
  ptep = pgdir_walk(kern_pgdir, va, 1);
f010202b:	83 c4 0c             	add    $0xc,%esp
f010202e:	6a 01                	push   $0x1
f0102030:	68 00 10 40 00       	push   $0x401000
f0102035:	c7 c6 d0 96 11 f0    	mov    $0xf01196d0,%esi
f010203b:	ff 36                	pushl  (%esi)
f010203d:	e8 4c f1 ff ff       	call   f010118e <pgdir_walk>
f0102042:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  ptep1 = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102048:	8b 06                	mov    (%esi),%eax
f010204a:	8b 50 04             	mov    0x4(%eax),%edx
f010204d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if (PGNUM(pa) >= npages)
f0102053:	c7 c1 cc 96 11 f0    	mov    $0xf01196cc,%ecx
f0102059:	8b 09                	mov    (%ecx),%ecx
f010205b:	89 d6                	mov    %edx,%esi
f010205d:	c1 ee 0c             	shr    $0xc,%esi
f0102060:	83 c4 10             	add    $0x10,%esp
f0102063:	39 ce                	cmp    %ecx,%esi
f0102065:	0f 83 47 08 00 00    	jae    f01028b2 <mem_init+0x14b4>
  assert(ptep == ptep1 + PTX(va));
f010206b:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102071:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102074:	0f 85 51 08 00 00    	jne    f01028cb <mem_init+0x14cd>
  kern_pgdir[PDX(va)] = 0;
f010207a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  pp0->pp_ref = 0;
f0102081:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102084:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
  return (pp - pages) << PGSHIFT;
f010208a:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102090:	2b 30                	sub    (%eax),%esi
f0102092:	89 f0                	mov    %esi,%eax
f0102094:	c1 f8 03             	sar    $0x3,%eax
f0102097:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f010209a:	89 c2                	mov    %eax,%edx
f010209c:	c1 ea 0c             	shr    $0xc,%edx
f010209f:	39 d1                	cmp    %edx,%ecx
f01020a1:	0f 86 43 08 00 00    	jbe    f01028ea <mem_init+0x14ec>

  // check that new page tables get cleared
  memset(page2kva(pp0), 0xFF, PGSIZE);
f01020a7:	83 ec 04             	sub    $0x4,%esp
f01020aa:	68 00 10 00 00       	push   $0x1000
f01020af:	68 ff 00 00 00       	push   $0xff
  return (void *)(pa + KERNBASE);
f01020b4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020b9:	50                   	push   %eax
f01020ba:	e8 9e 1b 00 00       	call   f0103c5d <memset>
  page_free(pp0);
f01020bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01020c2:	89 34 24             	mov    %esi,(%esp)
f01020c5:	e8 81 f0 ff ff       	call   f010114b <page_free>
  pgdir_walk(kern_pgdir, 0x0, 1);
f01020ca:	83 c4 0c             	add    $0xc,%esp
f01020cd:	6a 01                	push   $0x1
f01020cf:	6a 00                	push   $0x0
f01020d1:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f01020d7:	ff 30                	pushl  (%eax)
f01020d9:	e8 b0 f0 ff ff       	call   f010118e <pgdir_walk>
  return (pp - pages) << PGSHIFT;
f01020de:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f01020e4:	89 f2                	mov    %esi,%edx
f01020e6:	2b 10                	sub    (%eax),%edx
f01020e8:	c1 fa 03             	sar    $0x3,%edx
f01020eb:	c1 e2 0c             	shl    $0xc,%edx
  if (PGNUM(pa) >= npages)
f01020ee:	89 d1                	mov    %edx,%ecx
f01020f0:	c1 e9 0c             	shr    $0xc,%ecx
f01020f3:	83 c4 10             	add    $0x10,%esp
f01020f6:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f01020fc:	3b 08                	cmp    (%eax),%ecx
f01020fe:	0f 83 fc 07 00 00    	jae    f0102900 <mem_init+0x1502>
  return (void *)(pa + KERNBASE);
f0102104:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
  ptep = (pte_t *)page2kva(pp0);
f010210a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010210d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
f0102113:	8b 75 d0             	mov    -0x30(%ebp),%esi
  for (i = 0; i < NPTENTRIES; i++)
    assert((ptep[i] & PTE_P) == 0);
f0102116:	f6 00 01             	testb  $0x1,(%eax)
f0102119:	0f 85 f7 07 00 00    	jne    f0102916 <mem_init+0x1518>
f010211f:	83 c0 04             	add    $0x4,%eax
  for (i = 0; i < NPTENTRIES; i++)
f0102122:	39 c2                	cmp    %eax,%edx
f0102124:	75 f0                	jne    f0102116 <mem_init+0xd18>
  kern_pgdir[0] = 0;
f0102126:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f010212c:	8b 00                	mov    (%eax),%eax
f010212e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  pp0->pp_ref = 0;
f0102134:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

  // give free list back
  page_free_list = fl;
f010213a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010213d:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)

  // free the pages we took
  page_free(pp0);
f0102143:	83 ec 0c             	sub    $0xc,%esp
f0102146:	56                   	push   %esi
f0102147:	e8 ff ef ff ff       	call   f010114b <page_free>
  page_free(pp1);
f010214c:	83 c4 04             	add    $0x4,%esp
f010214f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102152:	e8 f4 ef ff ff       	call   f010114b <page_free>
  page_free(pp2);
f0102157:	89 3c 24             	mov    %edi,(%esp)
f010215a:	e8 ec ef ff ff       	call   f010114b <page_free>

  cprintf("check_page() succeeded!\n");
f010215f:	8d 83 c9 dc fe ff    	lea    -0x12337(%ebx),%eax
f0102165:	89 04 24             	mov    %eax,(%esp)
f0102168:	e8 86 0e 00 00       	call   f0102ff3 <cprintf>
  boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010216d:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102173:	8b 00                	mov    (%eax),%eax
  if ((uint32_t)kva < KERNBASE)
f0102175:	83 c4 10             	add    $0x10,%esp
f0102178:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010217d:	0f 86 b2 07 00 00    	jbe    f0102935 <mem_init+0x1537>
f0102183:	83 ec 08             	sub    $0x8,%esp
f0102186:	6a 04                	push   $0x4
  return (physaddr_t)kva - KERNBASE;
f0102188:	05 00 00 00 10       	add    $0x10000000,%eax
f010218d:	50                   	push   %eax
f010218e:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102193:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102198:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f010219e:	8b 00                	mov    (%eax),%eax
f01021a0:	e8 94 f0 ff ff       	call   f0101239 <boot_map_region>
  if ((uint32_t)kva < KERNBASE)
f01021a5:	c7 c0 00 e0 10 f0    	mov    $0xf010e000,%eax
f01021ab:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01021ae:	83 c4 10             	add    $0x10,%esp
f01021b1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021b6:	0f 86 92 07 00 00    	jbe    f010294e <mem_init+0x1550>
  boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack),
f01021bc:	c7 c6 d0 96 11 f0    	mov    $0xf01196d0,%esi
f01021c2:	83 ec 08             	sub    $0x8,%esp
f01021c5:	6a 02                	push   $0x2
  return (physaddr_t)kva - KERNBASE;
f01021c7:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01021ca:	05 00 00 00 10       	add    $0x10000000,%eax
f01021cf:	50                   	push   %eax
f01021d0:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01021d5:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01021da:	8b 06                	mov    (%esi),%eax
f01021dc:	e8 58 f0 ff ff       	call   f0101239 <boot_map_region>
  boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f01021e1:	83 c4 08             	add    $0x8,%esp
f01021e4:	6a 02                	push   $0x2
f01021e6:	6a 00                	push   $0x0
f01021e8:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01021ed:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01021f2:	8b 06                	mov    (%esi),%eax
f01021f4:	e8 40 f0 ff ff       	call   f0101239 <boot_map_region>
  pgdir = kern_pgdir;
f01021f9:	8b 36                	mov    (%esi),%esi
  n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f01021fb:	c7 c0 cc 96 11 f0    	mov    $0xf01196cc,%eax
f0102201:	8b 00                	mov    (%eax),%eax
f0102203:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102206:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010220d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102212:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102215:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f010221b:	8b 00                	mov    (%eax),%eax
f010221d:	89 45 c0             	mov    %eax,-0x40(%ebp)
  if ((uint32_t)kva < KERNBASE)
f0102220:	89 45 cc             	mov    %eax,-0x34(%ebp)
  return (physaddr_t)kva - KERNBASE;
f0102223:	05 00 00 00 10       	add    $0x10000000,%eax
f0102228:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < n; i += PGSIZE)
f010222b:	bf 00 00 00 00       	mov    $0x0,%edi
f0102230:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102233:	89 c6                	mov    %eax,%esi
f0102235:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0102238:	0f 86 63 07 00 00    	jbe    f01029a1 <mem_init+0x15a3>
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010223e:	8d 97 00 00 00 ef    	lea    -0x11000000(%edi),%edx
f0102244:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102247:	e8 a6 e9 ff ff       	call   f0100bf2 <check_va2pa>
  if ((uint32_t)kva < KERNBASE)
f010224c:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102253:	0f 86 0e 07 00 00    	jbe    f0102967 <mem_init+0x1569>
f0102259:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010225c:	39 c2                	cmp    %eax,%edx
f010225e:	0f 85 1e 07 00 00    	jne    f0102982 <mem_init+0x1584>
  for (i = 0; i < n; i += PGSIZE)
f0102264:	81 c7 00 10 00 00    	add    $0x1000,%edi
f010226a:	eb c9                	jmp    f0102235 <mem_init+0xe37>
  assert(nfree == 0);
f010226c:	8d 83 d7 db fe ff    	lea    -0x12429(%ebx),%eax
f0102272:	50                   	push   %eax
f0102273:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102279:	50                   	push   %eax
f010227a:	68 67 02 00 00       	push   $0x267
f010227f:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102285:	50                   	push   %eax
f0102286:	e8 74 de ff ff       	call   f01000ff <_panic>
  assert((pp0 = page_alloc(0)));
f010228b:	8d 83 3c db fe ff    	lea    -0x124c4(%ebx),%eax
f0102291:	50                   	push   %eax
f0102292:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102298:	50                   	push   %eax
f0102299:	68 b9 02 00 00       	push   $0x2b9
f010229e:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01022a4:	50                   	push   %eax
f01022a5:	e8 55 de ff ff       	call   f01000ff <_panic>
  assert((pp1 = page_alloc(0)));
f01022aa:	8d 83 52 db fe ff    	lea    -0x124ae(%ebx),%eax
f01022b0:	50                   	push   %eax
f01022b1:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01022b7:	50                   	push   %eax
f01022b8:	68 ba 02 00 00       	push   $0x2ba
f01022bd:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01022c3:	50                   	push   %eax
f01022c4:	e8 36 de ff ff       	call   f01000ff <_panic>
  assert((pp2 = page_alloc(0)));
f01022c9:	8d 83 68 db fe ff    	lea    -0x12498(%ebx),%eax
f01022cf:	50                   	push   %eax
f01022d0:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01022d6:	50                   	push   %eax
f01022d7:	68 bb 02 00 00       	push   $0x2bb
f01022dc:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01022e2:	50                   	push   %eax
f01022e3:	e8 17 de ff ff       	call   f01000ff <_panic>
  assert(pp1 && pp1 != pp0);
f01022e8:	8d 83 7e db fe ff    	lea    -0x12482(%ebx),%eax
f01022ee:	50                   	push   %eax
f01022ef:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01022f5:	50                   	push   %eax
f01022f6:	68 be 02 00 00       	push   $0x2be
f01022fb:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102301:	50                   	push   %eax
f0102302:	e8 f8 dd ff ff       	call   f01000ff <_panic>
  assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102307:	8d 83 3c d4 fe ff    	lea    -0x12bc4(%ebx),%eax
f010230d:	50                   	push   %eax
f010230e:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102314:	50                   	push   %eax
f0102315:	68 bf 02 00 00       	push   $0x2bf
f010231a:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102320:	50                   	push   %eax
f0102321:	e8 d9 dd ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f0102326:	8d 83 90 db fe ff    	lea    -0x12470(%ebx),%eax
f010232c:	50                   	push   %eax
f010232d:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102333:	50                   	push   %eax
f0102334:	68 c6 02 00 00       	push   $0x2c6
f0102339:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010233f:	50                   	push   %eax
f0102340:	e8 ba dd ff ff       	call   f01000ff <_panic>
  assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0102345:	8d 83 dc d4 fe ff    	lea    -0x12b24(%ebx),%eax
f010234b:	50                   	push   %eax
f010234c:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102352:	50                   	push   %eax
f0102353:	68 c9 02 00 00       	push   $0x2c9
f0102358:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010235e:	50                   	push   %eax
f010235f:	e8 9b dd ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102364:	8d 83 10 d5 fe ff    	lea    -0x12af0(%ebx),%eax
f010236a:	50                   	push   %eax
f010236b:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102371:	50                   	push   %eax
f0102372:	68 cc 02 00 00       	push   $0x2cc
f0102377:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010237d:	50                   	push   %eax
f010237e:	e8 7c dd ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102383:	8d 83 40 d5 fe ff    	lea    -0x12ac0(%ebx),%eax
f0102389:	50                   	push   %eax
f010238a:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102390:	50                   	push   %eax
f0102391:	68 d0 02 00 00       	push   $0x2d0
f0102396:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010239c:	50                   	push   %eax
f010239d:	e8 5d dd ff ff       	call   f01000ff <_panic>
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023a2:	8d 83 70 d5 fe ff    	lea    -0x12a90(%ebx),%eax
f01023a8:	50                   	push   %eax
f01023a9:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01023af:	50                   	push   %eax
f01023b0:	68 d1 02 00 00       	push   $0x2d1
f01023b5:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01023bb:	50                   	push   %eax
f01023bc:	e8 3e dd ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01023c1:	8d 83 98 d5 fe ff    	lea    -0x12a68(%ebx),%eax
f01023c7:	50                   	push   %eax
f01023c8:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01023ce:	50                   	push   %eax
f01023cf:	68 d2 02 00 00       	push   $0x2d2
f01023d4:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01023da:	50                   	push   %eax
f01023db:	e8 1f dd ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 1);
f01023e0:	8d 83 f2 db fe ff    	lea    -0x1240e(%ebx),%eax
f01023e6:	50                   	push   %eax
f01023e7:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01023ed:	50                   	push   %eax
f01023ee:	68 d3 02 00 00       	push   $0x2d3
f01023f3:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01023f9:	50                   	push   %eax
f01023fa:	e8 00 dd ff ff       	call   f01000ff <_panic>
  assert(pp0->pp_ref == 1);
f01023ff:	8d 83 03 dc fe ff    	lea    -0x123fd(%ebx),%eax
f0102405:	50                   	push   %eax
f0102406:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010240c:	50                   	push   %eax
f010240d:	68 d4 02 00 00       	push   $0x2d4
f0102412:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102418:	50                   	push   %eax
f0102419:	e8 e1 dc ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f010241e:	8d 83 c8 d5 fe ff    	lea    -0x12a38(%ebx),%eax
f0102424:	50                   	push   %eax
f0102425:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010242b:	50                   	push   %eax
f010242c:	68 d8 02 00 00       	push   $0x2d8
f0102431:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102437:	50                   	push   %eax
f0102438:	e8 c2 dc ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010243d:	8d 83 04 d6 fe ff    	lea    -0x129fc(%ebx),%eax
f0102443:	50                   	push   %eax
f0102444:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010244a:	50                   	push   %eax
f010244b:	68 d9 02 00 00       	push   $0x2d9
f0102450:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102456:	50                   	push   %eax
f0102457:	e8 a3 dc ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 1);
f010245c:	8d 83 14 dc fe ff    	lea    -0x123ec(%ebx),%eax
f0102462:	50                   	push   %eax
f0102463:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102469:	50                   	push   %eax
f010246a:	68 da 02 00 00       	push   $0x2da
f010246f:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102475:	50                   	push   %eax
f0102476:	e8 84 dc ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f010247b:	8d 83 90 db fe ff    	lea    -0x12470(%ebx),%eax
f0102481:	50                   	push   %eax
f0102482:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102488:	50                   	push   %eax
f0102489:	68 dd 02 00 00       	push   $0x2dd
f010248e:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102494:	50                   	push   %eax
f0102495:	e8 65 dc ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f010249a:	8d 83 c8 d5 fe ff    	lea    -0x12a38(%ebx),%eax
f01024a0:	50                   	push   %eax
f01024a1:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01024a7:	50                   	push   %eax
f01024a8:	68 e0 02 00 00       	push   $0x2e0
f01024ad:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01024b3:	50                   	push   %eax
f01024b4:	e8 46 dc ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024b9:	8d 83 04 d6 fe ff    	lea    -0x129fc(%ebx),%eax
f01024bf:	50                   	push   %eax
f01024c0:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01024c6:	50                   	push   %eax
f01024c7:	68 e1 02 00 00       	push   $0x2e1
f01024cc:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01024d2:	50                   	push   %eax
f01024d3:	e8 27 dc ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 1);
f01024d8:	8d 83 14 dc fe ff    	lea    -0x123ec(%ebx),%eax
f01024de:	50                   	push   %eax
f01024df:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01024e5:	50                   	push   %eax
f01024e6:	68 e2 02 00 00       	push   $0x2e2
f01024eb:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01024f1:	50                   	push   %eax
f01024f2:	e8 08 dc ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f01024f7:	8d 83 90 db fe ff    	lea    -0x12470(%ebx),%eax
f01024fd:	50                   	push   %eax
f01024fe:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102504:	50                   	push   %eax
f0102505:	68 e6 02 00 00       	push   $0x2e6
f010250a:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102510:	50                   	push   %eax
f0102511:	e8 e9 db ff ff       	call   f01000ff <_panic>
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102516:	50                   	push   %eax
f0102517:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f010251d:	50                   	push   %eax
f010251e:	68 e9 02 00 00       	push   $0x2e9
f0102523:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102529:	50                   	push   %eax
f010252a:	e8 d0 db ff ff       	call   f01000ff <_panic>
  assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f010252f:	8d 83 34 d6 fe ff    	lea    -0x129cc(%ebx),%eax
f0102535:	50                   	push   %eax
f0102536:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010253c:	50                   	push   %eax
f010253d:	68 ea 02 00 00       	push   $0x2ea
f0102542:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102548:	50                   	push   %eax
f0102549:	e8 b1 db ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f010254e:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f0102554:	50                   	push   %eax
f0102555:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010255b:	50                   	push   %eax
f010255c:	68 ed 02 00 00       	push   $0x2ed
f0102561:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102567:	50                   	push   %eax
f0102568:	e8 92 db ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010256d:	8d 83 04 d6 fe ff    	lea    -0x129fc(%ebx),%eax
f0102573:	50                   	push   %eax
f0102574:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010257a:	50                   	push   %eax
f010257b:	68 ee 02 00 00       	push   $0x2ee
f0102580:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102586:	50                   	push   %eax
f0102587:	e8 73 db ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 1);
f010258c:	8d 83 14 dc fe ff    	lea    -0x123ec(%ebx),%eax
f0102592:	50                   	push   %eax
f0102593:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102599:	50                   	push   %eax
f010259a:	68 ef 02 00 00       	push   $0x2ef
f010259f:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01025a5:	50                   	push   %eax
f01025a6:	e8 54 db ff ff       	call   f01000ff <_panic>
  assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f01025ab:	8d 83 b8 d6 fe ff    	lea    -0x12948(%ebx),%eax
f01025b1:	50                   	push   %eax
f01025b2:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01025b8:	50                   	push   %eax
f01025b9:	68 f0 02 00 00       	push   $0x2f0
f01025be:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01025c4:	50                   	push   %eax
f01025c5:	e8 35 db ff ff       	call   f01000ff <_panic>
  assert(kern_pgdir[0] & PTE_U);
f01025ca:	8d 83 51 dc fe ff    	lea    -0x123af(%ebx),%eax
f01025d0:	50                   	push   %eax
f01025d1:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01025d7:	50                   	push   %eax
f01025d8:	68 f4 02 00 00       	push   $0x2f4
f01025dd:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01025e3:	50                   	push   %eax
f01025e4:	e8 16 db ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f01025e9:	8d 83 c8 d5 fe ff    	lea    -0x12a38(%ebx),%eax
f01025ef:	50                   	push   %eax
f01025f0:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01025f6:	50                   	push   %eax
f01025f7:	68 f7 02 00 00       	push   $0x2f7
f01025fc:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102602:	50                   	push   %eax
f0102603:	e8 f7 da ff ff       	call   f01000ff <_panic>
  assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f0102608:	8d 83 ec d6 fe ff    	lea    -0x12914(%ebx),%eax
f010260e:	50                   	push   %eax
f010260f:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102615:	50                   	push   %eax
f0102616:	68 f8 02 00 00       	push   $0x2f8
f010261b:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102621:	50                   	push   %eax
f0102622:	e8 d8 da ff ff       	call   f01000ff <_panic>
  assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0102627:	8d 83 20 d7 fe ff    	lea    -0x128e0(%ebx),%eax
f010262d:	50                   	push   %eax
f010262e:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102634:	50                   	push   %eax
f0102635:	68 f9 02 00 00       	push   $0x2f9
f010263a:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102640:	50                   	push   %eax
f0102641:	e8 b9 da ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0102646:	8d 83 58 d7 fe ff    	lea    -0x128a8(%ebx),%eax
f010264c:	50                   	push   %eax
f010264d:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102653:	50                   	push   %eax
f0102654:	68 fc 02 00 00       	push   $0x2fc
f0102659:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010265f:	50                   	push   %eax
f0102660:	e8 9a da ff ff       	call   f01000ff <_panic>
  assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f0102665:	8d 83 90 d7 fe ff    	lea    -0x12870(%ebx),%eax
f010266b:	50                   	push   %eax
f010266c:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102672:	50                   	push   %eax
f0102673:	68 ff 02 00 00       	push   $0x2ff
f0102678:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010267e:	50                   	push   %eax
f010267f:	e8 7b da ff ff       	call   f01000ff <_panic>
  assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0102684:	8d 83 20 d7 fe ff    	lea    -0x128e0(%ebx),%eax
f010268a:	50                   	push   %eax
f010268b:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102691:	50                   	push   %eax
f0102692:	68 00 03 00 00       	push   $0x300
f0102697:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010269d:	50                   	push   %eax
f010269e:	e8 5c da ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01026a3:	8d 83 cc d7 fe ff    	lea    -0x12834(%ebx),%eax
f01026a9:	50                   	push   %eax
f01026aa:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01026b0:	50                   	push   %eax
f01026b1:	68 03 03 00 00       	push   $0x303
f01026b6:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01026bc:	50                   	push   %eax
f01026bd:	e8 3d da ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026c2:	8d 83 f8 d7 fe ff    	lea    -0x12808(%ebx),%eax
f01026c8:	50                   	push   %eax
f01026c9:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01026cf:	50                   	push   %eax
f01026d0:	68 04 03 00 00       	push   $0x304
f01026d5:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01026db:	50                   	push   %eax
f01026dc:	e8 1e da ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 2);
f01026e1:	8d 83 67 dc fe ff    	lea    -0x12399(%ebx),%eax
f01026e7:	50                   	push   %eax
f01026e8:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01026ee:	50                   	push   %eax
f01026ef:	68 06 03 00 00       	push   $0x306
f01026f4:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01026fa:	50                   	push   %eax
f01026fb:	e8 ff d9 ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 0);
f0102700:	8d 83 78 dc fe ff    	lea    -0x12388(%ebx),%eax
f0102706:	50                   	push   %eax
f0102707:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010270d:	50                   	push   %eax
f010270e:	68 07 03 00 00       	push   $0x307
f0102713:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102719:	50                   	push   %eax
f010271a:	e8 e0 d9 ff ff       	call   f01000ff <_panic>
  assert((pp = page_alloc(0)) && pp == pp2);
f010271f:	8d 83 28 d8 fe ff    	lea    -0x127d8(%ebx),%eax
f0102725:	50                   	push   %eax
f0102726:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010272c:	50                   	push   %eax
f010272d:	68 0a 03 00 00       	push   $0x30a
f0102732:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102738:	50                   	push   %eax
f0102739:	e8 c1 d9 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010273e:	8d 83 4c d8 fe ff    	lea    -0x127b4(%ebx),%eax
f0102744:	50                   	push   %eax
f0102745:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010274b:	50                   	push   %eax
f010274c:	68 0e 03 00 00       	push   $0x30e
f0102751:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102757:	50                   	push   %eax
f0102758:	e8 a2 d9 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010275d:	8d 83 f8 d7 fe ff    	lea    -0x12808(%ebx),%eax
f0102763:	50                   	push   %eax
f0102764:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010276a:	50                   	push   %eax
f010276b:	68 0f 03 00 00       	push   $0x30f
f0102770:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102776:	50                   	push   %eax
f0102777:	e8 83 d9 ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 1);
f010277c:	8d 83 f2 db fe ff    	lea    -0x1240e(%ebx),%eax
f0102782:	50                   	push   %eax
f0102783:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102789:	50                   	push   %eax
f010278a:	68 10 03 00 00       	push   $0x310
f010278f:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102795:	50                   	push   %eax
f0102796:	e8 64 d9 ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 0);
f010279b:	8d 83 78 dc fe ff    	lea    -0x12388(%ebx),%eax
f01027a1:	50                   	push   %eax
f01027a2:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01027a8:	50                   	push   %eax
f01027a9:	68 11 03 00 00       	push   $0x311
f01027ae:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01027b4:	50                   	push   %eax
f01027b5:	e8 45 d9 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027ba:	8d 83 4c d8 fe ff    	lea    -0x127b4(%ebx),%eax
f01027c0:	50                   	push   %eax
f01027c1:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01027c7:	50                   	push   %eax
f01027c8:	68 15 03 00 00       	push   $0x315
f01027cd:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01027d3:	50                   	push   %eax
f01027d4:	e8 26 d9 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01027d9:	8d 83 70 d8 fe ff    	lea    -0x12790(%ebx),%eax
f01027df:	50                   	push   %eax
f01027e0:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01027e6:	50                   	push   %eax
f01027e7:	68 16 03 00 00       	push   $0x316
f01027ec:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01027f2:	50                   	push   %eax
f01027f3:	e8 07 d9 ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 0);
f01027f8:	8d 83 89 dc fe ff    	lea    -0x12377(%ebx),%eax
f01027fe:	50                   	push   %eax
f01027ff:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102805:	50                   	push   %eax
f0102806:	68 17 03 00 00       	push   $0x317
f010280b:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102811:	50                   	push   %eax
f0102812:	e8 e8 d8 ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 0);
f0102817:	8d 83 78 dc fe ff    	lea    -0x12388(%ebx),%eax
f010281d:	50                   	push   %eax
f010281e:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102824:	50                   	push   %eax
f0102825:	68 18 03 00 00       	push   $0x318
f010282a:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102830:	50                   	push   %eax
f0102831:	e8 c9 d8 ff ff       	call   f01000ff <_panic>
  assert((pp = page_alloc(0)) && pp == pp1);
f0102836:	8d 83 98 d8 fe ff    	lea    -0x12768(%ebx),%eax
f010283c:	50                   	push   %eax
f010283d:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102843:	50                   	push   %eax
f0102844:	68 1b 03 00 00       	push   $0x31b
f0102849:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010284f:	50                   	push   %eax
f0102850:	e8 aa d8 ff ff       	call   f01000ff <_panic>
  assert(!page_alloc(0));
f0102855:	8d 83 90 db fe ff    	lea    -0x12470(%ebx),%eax
f010285b:	50                   	push   %eax
f010285c:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102862:	50                   	push   %eax
f0102863:	68 1e 03 00 00       	push   $0x31e
f0102868:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010286e:	50                   	push   %eax
f010286f:	e8 8b d8 ff ff       	call   f01000ff <_panic>
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102874:	8d 83 70 d5 fe ff    	lea    -0x12a90(%ebx),%eax
f010287a:	50                   	push   %eax
f010287b:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102881:	50                   	push   %eax
f0102882:	68 21 03 00 00       	push   $0x321
f0102887:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010288d:	50                   	push   %eax
f010288e:	e8 6c d8 ff ff       	call   f01000ff <_panic>
  assert(pp0->pp_ref == 1);
f0102893:	8d 83 03 dc fe ff    	lea    -0x123fd(%ebx),%eax
f0102899:	50                   	push   %eax
f010289a:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01028a0:	50                   	push   %eax
f01028a1:	68 23 03 00 00       	push   $0x323
f01028a6:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01028ac:	50                   	push   %eax
f01028ad:	e8 4d d8 ff ff       	call   f01000ff <_panic>
f01028b2:	52                   	push   %edx
f01028b3:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f01028b9:	50                   	push   %eax
f01028ba:	68 2a 03 00 00       	push   $0x32a
f01028bf:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01028c5:	50                   	push   %eax
f01028c6:	e8 34 d8 ff ff       	call   f01000ff <_panic>
  assert(ptep == ptep1 + PTX(va));
f01028cb:	8d 83 9a dc fe ff    	lea    -0x12366(%ebx),%eax
f01028d1:	50                   	push   %eax
f01028d2:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01028d8:	50                   	push   %eax
f01028d9:	68 2b 03 00 00       	push   $0x32b
f01028de:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01028e4:	50                   	push   %eax
f01028e5:	e8 15 d8 ff ff       	call   f01000ff <_panic>
f01028ea:	50                   	push   %eax
f01028eb:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f01028f1:	50                   	push   %eax
f01028f2:	6a 3f                	push   $0x3f
f01028f4:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f01028fa:	50                   	push   %eax
f01028fb:	e8 ff d7 ff ff       	call   f01000ff <_panic>
f0102900:	52                   	push   %edx
f0102901:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f0102907:	50                   	push   %eax
f0102908:	6a 3f                	push   $0x3f
f010290a:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f0102910:	50                   	push   %eax
f0102911:	e8 e9 d7 ff ff       	call   f01000ff <_panic>
    assert((ptep[i] & PTE_P) == 0);
f0102916:	8d 83 b2 dc fe ff    	lea    -0x1234e(%ebx),%eax
f010291c:	50                   	push   %eax
f010291d:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102923:	50                   	push   %eax
f0102924:	68 35 03 00 00       	push   $0x335
f0102929:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010292f:	50                   	push   %eax
f0102930:	e8 ca d7 ff ff       	call   f01000ff <_panic>
    _panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102935:	50                   	push   %eax
f0102936:	8d 83 18 d4 fe ff    	lea    -0x12be8(%ebx),%eax
f010293c:	50                   	push   %eax
f010293d:	68 ac 00 00 00       	push   $0xac
f0102942:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102948:	50                   	push   %eax
f0102949:	e8 b1 d7 ff ff       	call   f01000ff <_panic>
f010294e:	50                   	push   %eax
f010294f:	8d 83 18 d4 fe ff    	lea    -0x12be8(%ebx),%eax
f0102955:	50                   	push   %eax
f0102956:	68 ba 00 00 00       	push   $0xba
f010295b:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102961:	50                   	push   %eax
f0102962:	e8 98 d7 ff ff       	call   f01000ff <_panic>
f0102967:	ff 75 c0             	pushl  -0x40(%ebp)
f010296a:	8d 83 18 d4 fe ff    	lea    -0x12be8(%ebx),%eax
f0102970:	50                   	push   %eax
f0102971:	68 7d 02 00 00       	push   $0x27d
f0102976:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010297c:	50                   	push   %eax
f010297d:	e8 7d d7 ff ff       	call   f01000ff <_panic>
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102982:	8d 83 bc d8 fe ff    	lea    -0x12744(%ebx),%eax
f0102988:	50                   	push   %eax
f0102989:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f010298f:	50                   	push   %eax
f0102990:	68 7d 02 00 00       	push   $0x27d
f0102995:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f010299b:	50                   	push   %eax
f010299c:	e8 5e d7 ff ff       	call   f01000ff <_panic>
f01029a1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029a4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01029a7:	c1 e0 0c             	shl    $0xc,%eax
f01029aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029ad:	bf 00 00 00 00       	mov    $0x0,%edi
f01029b2:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01029b5:	73 38                	jae    f01029ef <mem_init+0x15f1>
    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029b7:	8d 97 00 00 00 f0    	lea    -0x10000000(%edi),%edx
f01029bd:	89 f0                	mov    %esi,%eax
f01029bf:	e8 2e e2 ff ff       	call   f0100bf2 <check_va2pa>
f01029c4:	39 c7                	cmp    %eax,%edi
f01029c6:	75 08                	jne    f01029d0 <mem_init+0x15d2>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029c8:	81 c7 00 10 00 00    	add    $0x1000,%edi
f01029ce:	eb e2                	jmp    f01029b2 <mem_init+0x15b4>
    assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029d0:	8d 83 f0 d8 fe ff    	lea    -0x12710(%ebx),%eax
f01029d6:	50                   	push   %eax
f01029d7:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f01029dd:	50                   	push   %eax
f01029de:	68 81 02 00 00       	push   $0x281
f01029e3:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f01029e9:	50                   	push   %eax
f01029ea:	e8 10 d7 ff ff       	call   f01000ff <_panic>
  for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029ef:	bf 00 80 ff ef       	mov    $0xefff8000,%edi
    assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) ==
f01029f4:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01029f7:	05 00 80 00 20       	add    $0x20008000,%eax
f01029fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029ff:	89 fa                	mov    %edi,%edx
f0102a01:	89 f0                	mov    %esi,%eax
f0102a03:	e8 ea e1 ff ff       	call   f0100bf2 <check_va2pa>
f0102a08:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102a0b:	8d 14 39             	lea    (%ecx,%edi,1),%edx
f0102a0e:	39 c2                	cmp    %eax,%edx
f0102a10:	75 26                	jne    f0102a38 <mem_init+0x163a>
f0102a12:	81 c7 00 10 00 00    	add    $0x1000,%edi
  for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a18:	81 ff 00 00 00 f0    	cmp    $0xf0000000,%edi
f0102a1e:	75 df                	jne    f01029ff <mem_init+0x1601>
  assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a20:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a25:	89 f0                	mov    %esi,%eax
f0102a27:	e8 c6 e1 ff ff       	call   f0100bf2 <check_va2pa>
f0102a2c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a2f:	75 26                	jne    f0102a57 <mem_init+0x1659>
  for (i = 0; i < NPDENTRIES; i++) {
f0102a31:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a36:	eb 67                	jmp    f0102a9f <mem_init+0x16a1>
    assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) ==
f0102a38:	8d 83 18 d9 fe ff    	lea    -0x126e8(%ebx),%eax
f0102a3e:	50                   	push   %eax
f0102a3f:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102a45:	50                   	push   %eax
f0102a46:	68 86 02 00 00       	push   $0x286
f0102a4b:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102a51:	50                   	push   %eax
f0102a52:	e8 a8 d6 ff ff       	call   f01000ff <_panic>
  assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a57:	8d 83 60 d9 fe ff    	lea    -0x126a0(%ebx),%eax
f0102a5d:	50                   	push   %eax
f0102a5e:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102a64:	50                   	push   %eax
f0102a65:	68 87 02 00 00       	push   $0x287
f0102a6a:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102a70:	50                   	push   %eax
f0102a71:	e8 89 d6 ff ff       	call   f01000ff <_panic>
      assert(pgdir[i] & PTE_P);
f0102a76:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102a7a:	74 4f                	je     f0102acb <mem_init+0x16cd>
  for (i = 0; i < NPDENTRIES; i++) {
f0102a7c:	83 c0 01             	add    $0x1,%eax
f0102a7f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a84:	0f 87 ab 00 00 00    	ja     f0102b35 <mem_init+0x1737>
    switch (i) {
f0102a8a:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102a8f:	72 0e                	jb     f0102a9f <mem_init+0x16a1>
f0102a91:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102a96:	76 de                	jbe    f0102a76 <mem_init+0x1678>
f0102a98:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a9d:	74 d7                	je     f0102a76 <mem_init+0x1678>
      if (i >= PDX(KERNBASE)) {
f0102a9f:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102aa4:	77 44                	ja     f0102aea <mem_init+0x16ec>
        assert(pgdir[i] == 0);
f0102aa6:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102aaa:	74 d0                	je     f0102a7c <mem_init+0x167e>
f0102aac:	8d 83 04 dd fe ff    	lea    -0x122fc(%ebx),%eax
f0102ab2:	50                   	push   %eax
f0102ab3:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102ab9:	50                   	push   %eax
f0102aba:	68 96 02 00 00       	push   $0x296
f0102abf:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102ac5:	50                   	push   %eax
f0102ac6:	e8 34 d6 ff ff       	call   f01000ff <_panic>
      assert(pgdir[i] & PTE_P);
f0102acb:	8d 83 e2 dc fe ff    	lea    -0x1231e(%ebx),%eax
f0102ad1:	50                   	push   %eax
f0102ad2:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102ad8:	50                   	push   %eax
f0102ad9:	68 8f 02 00 00       	push   $0x28f
f0102ade:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102ae4:	50                   	push   %eax
f0102ae5:	e8 15 d6 ff ff       	call   f01000ff <_panic>
        assert(pgdir[i] & PTE_P);
f0102aea:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102aed:	f6 c2 01             	test   $0x1,%dl
f0102af0:	74 24                	je     f0102b16 <mem_init+0x1718>
        assert(pgdir[i] & PTE_W);
f0102af2:	f6 c2 02             	test   $0x2,%dl
f0102af5:	75 85                	jne    f0102a7c <mem_init+0x167e>
f0102af7:	8d 83 f3 dc fe ff    	lea    -0x1230d(%ebx),%eax
f0102afd:	50                   	push   %eax
f0102afe:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102b04:	50                   	push   %eax
f0102b05:	68 94 02 00 00       	push   $0x294
f0102b0a:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102b10:	50                   	push   %eax
f0102b11:	e8 e9 d5 ff ff       	call   f01000ff <_panic>
        assert(pgdir[i] & PTE_P);
f0102b16:	8d 83 e2 dc fe ff    	lea    -0x1231e(%ebx),%eax
f0102b1c:	50                   	push   %eax
f0102b1d:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102b23:	50                   	push   %eax
f0102b24:	68 93 02 00 00       	push   $0x293
f0102b29:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102b2f:	50                   	push   %eax
f0102b30:	e8 ca d5 ff ff       	call   f01000ff <_panic>
  cprintf("check_kern_pgdir() succeeded!\n");
f0102b35:	83 ec 0c             	sub    $0xc,%esp
f0102b38:	8d 83 90 d9 fe ff    	lea    -0x12670(%ebx),%eax
f0102b3e:	50                   	push   %eax
f0102b3f:	e8 af 04 00 00       	call   f0102ff3 <cprintf>
  lcr3(PADDR(kern_pgdir));
f0102b44:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102b4a:	8b 00                	mov    (%eax),%eax
  if ((uint32_t)kva < KERNBASE)
f0102b4c:	83 c4 10             	add    $0x10,%esp
f0102b4f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b54:	0f 86 28 02 00 00    	jbe    f0102d82 <mem_init+0x1984>
  return (physaddr_t)kva - KERNBASE;
f0102b5a:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b5f:	0f 22 d8             	mov    %eax,%cr3
  check_page_free_list(0);
f0102b62:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b67:	e8 03 e1 ff ff       	call   f0100c6f <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b6c:	0f 20 c0             	mov    %cr0,%eax
  cr0 &= ~(CR0_TS | CR0_EM);
f0102b6f:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b72:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b77:	0f 22 c0             	mov    %eax,%cr0
  uintptr_t va;
  int i;

  // check that we can read and write installed pages
  pp1 = pp2 = 0;
  assert((pp0 = page_alloc(0)));
f0102b7a:	83 ec 0c             	sub    $0xc,%esp
f0102b7d:	6a 00                	push   $0x0
f0102b7f:	e8 45 e5 ff ff       	call   f01010c9 <page_alloc>
f0102b84:	89 c6                	mov    %eax,%esi
f0102b86:	83 c4 10             	add    $0x10,%esp
f0102b89:	85 c0                	test   %eax,%eax
f0102b8b:	0f 84 0a 02 00 00    	je     f0102d9b <mem_init+0x199d>
  assert((pp1 = page_alloc(0)));
f0102b91:	83 ec 0c             	sub    $0xc,%esp
f0102b94:	6a 00                	push   $0x0
f0102b96:	e8 2e e5 ff ff       	call   f01010c9 <page_alloc>
f0102b9b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b9e:	83 c4 10             	add    $0x10,%esp
f0102ba1:	85 c0                	test   %eax,%eax
f0102ba3:	0f 84 11 02 00 00    	je     f0102dba <mem_init+0x19bc>
  assert((pp2 = page_alloc(0)));
f0102ba9:	83 ec 0c             	sub    $0xc,%esp
f0102bac:	6a 00                	push   $0x0
f0102bae:	e8 16 e5 ff ff       	call   f01010c9 <page_alloc>
f0102bb3:	89 c7                	mov    %eax,%edi
f0102bb5:	83 c4 10             	add    $0x10,%esp
f0102bb8:	85 c0                	test   %eax,%eax
f0102bba:	0f 84 19 02 00 00    	je     f0102dd9 <mem_init+0x19db>
  page_free(pp0);
f0102bc0:	83 ec 0c             	sub    $0xc,%esp
f0102bc3:	56                   	push   %esi
f0102bc4:	e8 82 e5 ff ff       	call   f010114b <page_free>
  return (pp - pages) << PGSHIFT;
f0102bc9:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102bcf:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102bd2:	2b 08                	sub    (%eax),%ecx
f0102bd4:	89 c8                	mov    %ecx,%eax
f0102bd6:	c1 f8 03             	sar    $0x3,%eax
f0102bd9:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f0102bdc:	89 c1                	mov    %eax,%ecx
f0102bde:	c1 e9 0c             	shr    $0xc,%ecx
f0102be1:	83 c4 10             	add    $0x10,%esp
f0102be4:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0102bea:	3b 0a                	cmp    (%edx),%ecx
f0102bec:	0f 83 06 02 00 00    	jae    f0102df8 <mem_init+0x19fa>
  memset(page2kva(pp1), 1, PGSIZE);
f0102bf2:	83 ec 04             	sub    $0x4,%esp
f0102bf5:	68 00 10 00 00       	push   $0x1000
f0102bfa:	6a 01                	push   $0x1
  return (void *)(pa + KERNBASE);
f0102bfc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c01:	50                   	push   %eax
f0102c02:	e8 56 10 00 00       	call   f0103c5d <memset>
  return (pp - pages) << PGSHIFT;
f0102c07:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102c0d:	89 f9                	mov    %edi,%ecx
f0102c0f:	2b 08                	sub    (%eax),%ecx
f0102c11:	89 c8                	mov    %ecx,%eax
f0102c13:	c1 f8 03             	sar    $0x3,%eax
f0102c16:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f0102c19:	89 c1                	mov    %eax,%ecx
f0102c1b:	c1 e9 0c             	shr    $0xc,%ecx
f0102c1e:	83 c4 10             	add    $0x10,%esp
f0102c21:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0102c27:	3b 0a                	cmp    (%edx),%ecx
f0102c29:	0f 83 df 01 00 00    	jae    f0102e0e <mem_init+0x1a10>
  memset(page2kva(pp2), 2, PGSIZE);
f0102c2f:	83 ec 04             	sub    $0x4,%esp
f0102c32:	68 00 10 00 00       	push   $0x1000
f0102c37:	6a 02                	push   $0x2
  return (void *)(pa + KERNBASE);
f0102c39:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c3e:	50                   	push   %eax
f0102c3f:	e8 19 10 00 00       	call   f0103c5d <memset>
  page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W);
f0102c44:	6a 02                	push   $0x2
f0102c46:	68 00 10 00 00       	push   $0x1000
f0102c4b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102c4e:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102c54:	ff 30                	pushl  (%eax)
f0102c56:	e8 2b e7 ff ff       	call   f0101386 <page_insert>
  assert(pp1->pp_ref == 1);
f0102c5b:	83 c4 20             	add    $0x20,%esp
f0102c5e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c61:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102c66:	0f 85 b8 01 00 00    	jne    f0102e24 <mem_init+0x1a26>
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c6c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c73:	01 01 01 
f0102c76:	0f 85 c7 01 00 00    	jne    f0102e43 <mem_init+0x1a45>
  page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W);
f0102c7c:	6a 02                	push   $0x2
f0102c7e:	68 00 10 00 00       	push   $0x1000
f0102c83:	57                   	push   %edi
f0102c84:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102c8a:	ff 30                	pushl  (%eax)
f0102c8c:	e8 f5 e6 ff ff       	call   f0101386 <page_insert>
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c91:	83 c4 10             	add    $0x10,%esp
f0102c94:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c9b:	02 02 02 
f0102c9e:	0f 85 be 01 00 00    	jne    f0102e62 <mem_init+0x1a64>
  assert(pp2->pp_ref == 1);
f0102ca4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ca9:	0f 85 d2 01 00 00    	jne    f0102e81 <mem_init+0x1a83>
  assert(pp1->pp_ref == 0);
f0102caf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cb2:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102cb7:	0f 85 e3 01 00 00    	jne    f0102ea0 <mem_init+0x1aa2>
  *(uint32_t *)PGSIZE = 0x03030303U;
f0102cbd:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cc4:	03 03 03 
  return (pp - pages) << PGSHIFT;
f0102cc7:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102ccd:	89 f9                	mov    %edi,%ecx
f0102ccf:	2b 08                	sub    (%eax),%ecx
f0102cd1:	89 c8                	mov    %ecx,%eax
f0102cd3:	c1 f8 03             	sar    $0x3,%eax
f0102cd6:	c1 e0 0c             	shl    $0xc,%eax
  if (PGNUM(pa) >= npages)
f0102cd9:	89 c1                	mov    %eax,%ecx
f0102cdb:	c1 e9 0c             	shr    $0xc,%ecx
f0102cde:	c7 c2 cc 96 11 f0    	mov    $0xf01196cc,%edx
f0102ce4:	3b 0a                	cmp    (%edx),%ecx
f0102ce6:	0f 83 d3 01 00 00    	jae    f0102ebf <mem_init+0x1ac1>
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cec:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cf3:	03 03 03 
f0102cf6:	0f 85 d9 01 00 00    	jne    f0102ed5 <mem_init+0x1ad7>
  page_remove(kern_pgdir, (void *)PGSIZE);
f0102cfc:	83 ec 08             	sub    $0x8,%esp
f0102cff:	68 00 10 00 00       	push   $0x1000
f0102d04:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102d0a:	ff 30                	pushl  (%eax)
f0102d0c:	e8 30 e6 ff ff       	call   f0101341 <page_remove>
  assert(pp2->pp_ref == 0);
f0102d11:	83 c4 10             	add    $0x10,%esp
f0102d14:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d19:	0f 85 d5 01 00 00    	jne    f0102ef4 <mem_init+0x1af6>

  // forcibly take pp0 back
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d1f:	c7 c0 d0 96 11 f0    	mov    $0xf01196d0,%eax
f0102d25:	8b 08                	mov    (%eax),%ecx
f0102d27:	8b 11                	mov    (%ecx),%edx
f0102d29:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return (pp - pages) << PGSHIFT;
f0102d2f:	c7 c0 d4 96 11 f0    	mov    $0xf01196d4,%eax
f0102d35:	89 f7                	mov    %esi,%edi
f0102d37:	2b 38                	sub    (%eax),%edi
f0102d39:	89 f8                	mov    %edi,%eax
f0102d3b:	c1 f8 03             	sar    $0x3,%eax
f0102d3e:	c1 e0 0c             	shl    $0xc,%eax
f0102d41:	39 c2                	cmp    %eax,%edx
f0102d43:	0f 85 ca 01 00 00    	jne    f0102f13 <mem_init+0x1b15>
  kern_pgdir[0] = 0;
f0102d49:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  assert(pp0->pp_ref == 1);
f0102d4f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d54:	0f 85 d8 01 00 00    	jne    f0102f32 <mem_init+0x1b34>
  pp0->pp_ref = 0;
f0102d5a:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

  // free the pages we took
  page_free(pp0);
f0102d60:	83 ec 0c             	sub    $0xc,%esp
f0102d63:	56                   	push   %esi
f0102d64:	e8 e2 e3 ff ff       	call   f010114b <page_free>

  cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d69:	8d 83 24 da fe ff    	lea    -0x125dc(%ebx),%eax
f0102d6f:	89 04 24             	mov    %eax,(%esp)
f0102d72:	e8 7c 02 00 00       	call   f0102ff3 <cprintf>
}
f0102d77:	83 c4 10             	add    $0x10,%esp
f0102d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d7d:	5b                   	pop    %ebx
f0102d7e:	5e                   	pop    %esi
f0102d7f:	5f                   	pop    %edi
f0102d80:	5d                   	pop    %ebp
f0102d81:	c3                   	ret    
    _panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d82:	50                   	push   %eax
f0102d83:	8d 83 18 d4 fe ff    	lea    -0x12be8(%ebx),%eax
f0102d89:	50                   	push   %eax
f0102d8a:	68 d3 00 00 00       	push   $0xd3
f0102d8f:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102d95:	50                   	push   %eax
f0102d96:	e8 64 d3 ff ff       	call   f01000ff <_panic>
  assert((pp0 = page_alloc(0)));
f0102d9b:	8d 83 3c db fe ff    	lea    -0x124c4(%ebx),%eax
f0102da1:	50                   	push   %eax
f0102da2:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102da8:	50                   	push   %eax
f0102da9:	68 4e 03 00 00       	push   $0x34e
f0102dae:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102db4:	50                   	push   %eax
f0102db5:	e8 45 d3 ff ff       	call   f01000ff <_panic>
  assert((pp1 = page_alloc(0)));
f0102dba:	8d 83 52 db fe ff    	lea    -0x124ae(%ebx),%eax
f0102dc0:	50                   	push   %eax
f0102dc1:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102dc7:	50                   	push   %eax
f0102dc8:	68 4f 03 00 00       	push   $0x34f
f0102dcd:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102dd3:	50                   	push   %eax
f0102dd4:	e8 26 d3 ff ff       	call   f01000ff <_panic>
  assert((pp2 = page_alloc(0)));
f0102dd9:	8d 83 68 db fe ff    	lea    -0x12498(%ebx),%eax
f0102ddf:	50                   	push   %eax
f0102de0:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102de6:	50                   	push   %eax
f0102de7:	68 50 03 00 00       	push   $0x350
f0102dec:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102df2:	50                   	push   %eax
f0102df3:	e8 07 d3 ff ff       	call   f01000ff <_panic>
    _panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102df8:	50                   	push   %eax
f0102df9:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f0102dff:	50                   	push   %eax
f0102e00:	6a 3f                	push   $0x3f
f0102e02:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f0102e08:	50                   	push   %eax
f0102e09:	e8 f1 d2 ff ff       	call   f01000ff <_panic>
f0102e0e:	50                   	push   %eax
f0102e0f:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f0102e15:	50                   	push   %eax
f0102e16:	6a 3f                	push   $0x3f
f0102e18:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f0102e1e:	50                   	push   %eax
f0102e1f:	e8 db d2 ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 1);
f0102e24:	8d 83 f2 db fe ff    	lea    -0x1240e(%ebx),%eax
f0102e2a:	50                   	push   %eax
f0102e2b:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102e31:	50                   	push   %eax
f0102e32:	68 55 03 00 00       	push   $0x355
f0102e37:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102e3d:	50                   	push   %eax
f0102e3e:	e8 bc d2 ff ff       	call   f01000ff <_panic>
  assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e43:	8d 83 b0 d9 fe ff    	lea    -0x12650(%ebx),%eax
f0102e49:	50                   	push   %eax
f0102e4a:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102e50:	50                   	push   %eax
f0102e51:	68 56 03 00 00       	push   $0x356
f0102e56:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102e5c:	50                   	push   %eax
f0102e5d:	e8 9d d2 ff ff       	call   f01000ff <_panic>
  assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e62:	8d 83 d4 d9 fe ff    	lea    -0x1262c(%ebx),%eax
f0102e68:	50                   	push   %eax
f0102e69:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102e6f:	50                   	push   %eax
f0102e70:	68 58 03 00 00       	push   $0x358
f0102e75:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102e7b:	50                   	push   %eax
f0102e7c:	e8 7e d2 ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 1);
f0102e81:	8d 83 14 dc fe ff    	lea    -0x123ec(%ebx),%eax
f0102e87:	50                   	push   %eax
f0102e88:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102e8e:	50                   	push   %eax
f0102e8f:	68 59 03 00 00       	push   $0x359
f0102e94:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102e9a:	50                   	push   %eax
f0102e9b:	e8 5f d2 ff ff       	call   f01000ff <_panic>
  assert(pp1->pp_ref == 0);
f0102ea0:	8d 83 89 dc fe ff    	lea    -0x12377(%ebx),%eax
f0102ea6:	50                   	push   %eax
f0102ea7:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102ead:	50                   	push   %eax
f0102eae:	68 5a 03 00 00       	push   $0x35a
f0102eb3:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102eb9:	50                   	push   %eax
f0102eba:	e8 40 d2 ff ff       	call   f01000ff <_panic>
f0102ebf:	50                   	push   %eax
f0102ec0:	8d 83 b4 d2 fe ff    	lea    -0x12d4c(%ebx),%eax
f0102ec6:	50                   	push   %eax
f0102ec7:	6a 3f                	push   $0x3f
f0102ec9:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f0102ecf:	50                   	push   %eax
f0102ed0:	e8 2a d2 ff ff       	call   f01000ff <_panic>
  assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ed5:	8d 83 f8 d9 fe ff    	lea    -0x12608(%ebx),%eax
f0102edb:	50                   	push   %eax
f0102edc:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102ee2:	50                   	push   %eax
f0102ee3:	68 5c 03 00 00       	push   $0x35c
f0102ee8:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102eee:	50                   	push   %eax
f0102eef:	e8 0b d2 ff ff       	call   f01000ff <_panic>
  assert(pp2->pp_ref == 0);
f0102ef4:	8d 83 78 dc fe ff    	lea    -0x12388(%ebx),%eax
f0102efa:	50                   	push   %eax
f0102efb:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102f01:	50                   	push   %eax
f0102f02:	68 5e 03 00 00       	push   $0x35e
f0102f07:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102f0d:	50                   	push   %eax
f0102f0e:	e8 ec d1 ff ff       	call   f01000ff <_panic>
  assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f13:	8d 83 70 d5 fe ff    	lea    -0x12a90(%ebx),%eax
f0102f19:	50                   	push   %eax
f0102f1a:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102f20:	50                   	push   %eax
f0102f21:	68 61 03 00 00       	push   $0x361
f0102f26:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102f2c:	50                   	push   %eax
f0102f2d:	e8 cd d1 ff ff       	call   f01000ff <_panic>
  assert(pp0->pp_ref == 1);
f0102f32:	8d 83 03 dc fe ff    	lea    -0x123fd(%ebx),%eax
f0102f38:	50                   	push   %eax
f0102f39:	8d 83 76 da fe ff    	lea    -0x1258a(%ebx),%eax
f0102f3f:	50                   	push   %eax
f0102f40:	68 63 03 00 00       	push   $0x363
f0102f45:	8d 83 50 da fe ff    	lea    -0x125b0(%ebx),%eax
f0102f4b:	50                   	push   %eax
f0102f4c:	e8 ae d1 ff ff       	call   f01000ff <_panic>

f0102f51 <tlb_invalidate>:
void tlb_invalidate(pde_t *pgdir, void *va) {
f0102f51:	55                   	push   %ebp
f0102f52:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102f54:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f57:	0f 01 38             	invlpg (%eax)
}
f0102f5a:	5d                   	pop    %ebp
f0102f5b:	c3                   	ret    

f0102f5c <__x86.get_pc_thunk.dx>:
f0102f5c:	8b 14 24             	mov    (%esp),%edx
f0102f5f:	c3                   	ret    

f0102f60 <__x86.get_pc_thunk.cx>:
f0102f60:	8b 0c 24             	mov    (%esp),%ecx
f0102f63:	c3                   	ret    

f0102f64 <__x86.get_pc_thunk.si>:
f0102f64:	8b 34 24             	mov    (%esp),%esi
f0102f67:	c3                   	ret    

f0102f68 <__x86.get_pc_thunk.di>:
f0102f68:	8b 3c 24             	mov    (%esp),%edi
f0102f6b:	c3                   	ret    

f0102f6c <mc146818_read>:

#include <inc/x86.h>

#include <kern/kclock.h>

unsigned mc146818_read(unsigned reg) {
f0102f6c:	55                   	push   %ebp
f0102f6d:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f72:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f77:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f78:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f7d:	ec                   	in     (%dx),%al
  outb(IO_RTC, reg);
  return inb(IO_RTC + 1);
f0102f7e:	0f b6 c0             	movzbl %al,%eax
}
f0102f81:	5d                   	pop    %ebp
f0102f82:	c3                   	ret    

f0102f83 <mc146818_write>:

void mc146818_write(unsigned reg, unsigned datum) {
f0102f83:	55                   	push   %ebp
f0102f84:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f86:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f89:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f8e:	ee                   	out    %al,(%dx)
f0102f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f92:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f97:	ee                   	out    %al,(%dx)
  outb(IO_RTC, reg);
  outb(IO_RTC + 1, datum);
f0102f98:	5d                   	pop    %ebp
f0102f99:	c3                   	ret    

f0102f9a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f9a:	55                   	push   %ebp
f0102f9b:	89 e5                	mov    %esp,%ebp
f0102f9d:	53                   	push   %ebx
f0102f9e:	83 ec 10             	sub    $0x10,%esp
f0102fa1:	e8 0f d2 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0102fa6:	81 c3 62 43 01 00    	add    $0x14362,%ebx
	cputchar(ch);
f0102fac:	ff 75 08             	pushl  0x8(%ebp)
f0102faf:	e8 8a d7 ff ff       	call   f010073e <cputchar>
	*cnt++;
}
f0102fb4:	83 c4 10             	add    $0x10,%esp
f0102fb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fba:	c9                   	leave  
f0102fbb:	c3                   	ret    

f0102fbc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102fbc:	55                   	push   %ebp
f0102fbd:	89 e5                	mov    %esp,%ebp
f0102fbf:	53                   	push   %ebx
f0102fc0:	83 ec 14             	sub    $0x14,%esp
f0102fc3:	e8 ed d1 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0102fc8:	81 c3 40 43 01 00    	add    $0x14340,%ebx
	int cnt = 0;
f0102fce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102fd5:	ff 75 0c             	pushl  0xc(%ebp)
f0102fd8:	ff 75 08             	pushl  0x8(%ebp)
f0102fdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102fde:	50                   	push   %eax
f0102fdf:	8d 83 92 bc fe ff    	lea    -0x1436e(%ebx),%eax
f0102fe5:	50                   	push   %eax
f0102fe6:	e8 98 04 00 00       	call   f0103483 <vprintfmt>
	return cnt;
}
f0102feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102ff1:	c9                   	leave  
f0102ff2:	c3                   	ret    

f0102ff3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102ff3:	55                   	push   %ebp
f0102ff4:	89 e5                	mov    %esp,%ebp
f0102ff6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102ff9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102ffc:	50                   	push   %eax
f0102ffd:	ff 75 08             	pushl  0x8(%ebp)
f0103000:	e8 b7 ff ff ff       	call   f0102fbc <vcprintf>
	va_end(ap);

	return cnt;
}
f0103005:	c9                   	leave  
f0103006:	c3                   	ret    

f0103007 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103007:	55                   	push   %ebp
f0103008:	89 e5                	mov    %esp,%ebp
f010300a:	57                   	push   %edi
f010300b:	56                   	push   %esi
f010300c:	53                   	push   %ebx
f010300d:	83 ec 14             	sub    $0x14,%esp
f0103010:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103013:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103016:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103019:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010301c:	8b 32                	mov    (%edx),%esi
f010301e:	8b 01                	mov    (%ecx),%eax
f0103020:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103023:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
	
	while (l <= r) {
f010302a:	eb 2f                	jmp    f010305b <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010302c:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010302f:	39 c6                	cmp    %eax,%esi
f0103031:	7f 49                	jg     f010307c <stab_binsearch+0x75>
f0103033:	0f b6 0a             	movzbl (%edx),%ecx
f0103036:	83 ea 0c             	sub    $0xc,%edx
f0103039:	39 f9                	cmp    %edi,%ecx
f010303b:	75 ef                	jne    f010302c <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010303d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103040:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103043:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103047:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010304a:	73 35                	jae    f0103081 <stab_binsearch+0x7a>
			*region_left = m;
f010304c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010304f:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0103051:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0103054:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f010305b:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f010305e:	7f 4e                	jg     f01030ae <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0103060:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103063:	01 f0                	add    %esi,%eax
f0103065:	89 c3                	mov    %eax,%ebx
f0103067:	c1 eb 1f             	shr    $0x1f,%ebx
f010306a:	01 c3                	add    %eax,%ebx
f010306c:	d1 fb                	sar    %ebx
f010306e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103071:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103074:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103078:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f010307a:	eb b3                	jmp    f010302f <stab_binsearch+0x28>
			l = true_m + 1;
f010307c:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010307f:	eb da                	jmp    f010305b <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0103081:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103084:	76 14                	jbe    f010309a <stab_binsearch+0x93>
			*region_right = m - 1;
f0103086:	83 e8 01             	sub    $0x1,%eax
f0103089:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010308c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010308f:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0103091:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103098:	eb c1                	jmp    f010305b <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010309a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010309d:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010309f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01030a3:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01030a5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01030ac:	eb ad                	jmp    f010305b <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01030ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01030b2:	74 16                	je     f01030ca <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01030b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01030b7:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01030b9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01030bc:	8b 0e                	mov    (%esi),%ecx
f01030be:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01030c1:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01030c4:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01030c8:	eb 12                	jmp    f01030dc <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f01030ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030cd:	8b 00                	mov    (%eax),%eax
f01030cf:	83 e8 01             	sub    $0x1,%eax
f01030d2:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01030d5:	89 07                	mov    %eax,(%edi)
f01030d7:	eb 16                	jmp    f01030ef <stab_binsearch+0xe8>
		     l--)
f01030d9:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01030dc:	39 c1                	cmp    %eax,%ecx
f01030de:	7d 0a                	jge    f01030ea <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f01030e0:	0f b6 1a             	movzbl (%edx),%ebx
f01030e3:	83 ea 0c             	sub    $0xc,%edx
f01030e6:	39 fb                	cmp    %edi,%ebx
f01030e8:	75 ef                	jne    f01030d9 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f01030ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01030ed:	89 07                	mov    %eax,(%edi)
	}
}
f01030ef:	83 c4 14             	add    $0x14,%esp
f01030f2:	5b                   	pop    %ebx
f01030f3:	5e                   	pop    %esi
f01030f4:	5f                   	pop    %edi
f01030f5:	5d                   	pop    %ebp
f01030f6:	c3                   	ret    

f01030f7 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01030f7:	55                   	push   %ebp
f01030f8:	89 e5                	mov    %esp,%ebp
f01030fa:	57                   	push   %edi
f01030fb:	56                   	push   %esi
f01030fc:	53                   	push   %ebx
f01030fd:	83 ec 3c             	sub    $0x3c,%esp
f0103100:	e8 b0 d0 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0103105:	81 c3 03 42 01 00    	add    $0x14203,%ebx
f010310b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010310e:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103111:	8d 83 12 dd fe ff    	lea    -0x122ee(%ebx),%eax
f0103117:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0103119:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0103120:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103123:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010312a:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f010312d:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103134:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010313a:	0f 86 37 01 00 00    	jbe    f0103277 <debuginfo_eip+0x180>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103140:	c7 c0 19 bc 10 f0    	mov    $0xf010bc19,%eax
f0103146:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f010314c:	0f 86 04 02 00 00    	jbe    f0103356 <debuginfo_eip+0x25f>
f0103152:	c7 c0 42 da 10 f0    	mov    $0xf010da42,%eax
f0103158:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010315c:	0f 85 fb 01 00 00    	jne    f010335d <debuginfo_eip+0x266>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103162:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103169:	c7 c0 34 52 10 f0    	mov    $0xf0105234,%eax
f010316f:	c7 c2 18 bc 10 f0    	mov    $0xf010bc18,%edx
f0103175:	29 c2                	sub    %eax,%edx
f0103177:	c1 fa 02             	sar    $0x2,%edx
f010317a:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103180:	83 ea 01             	sub    $0x1,%edx
f0103183:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103186:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103189:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010318c:	83 ec 08             	sub    $0x8,%esp
f010318f:	57                   	push   %edi
f0103190:	6a 64                	push   $0x64
f0103192:	e8 70 fe ff ff       	call   f0103007 <stab_binsearch>
	if (lfile == 0)
f0103197:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010319a:	83 c4 10             	add    $0x10,%esp
f010319d:	85 c0                	test   %eax,%eax
f010319f:	0f 84 bf 01 00 00    	je     f0103364 <debuginfo_eip+0x26d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01031a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01031a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01031ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01031ae:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01031b1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01031b4:	83 ec 08             	sub    $0x8,%esp
f01031b7:	57                   	push   %edi
f01031b8:	6a 24                	push   $0x24
f01031ba:	c7 c0 34 52 10 f0    	mov    $0xf0105234,%eax
f01031c0:	e8 42 fe ff ff       	call   f0103007 <stab_binsearch>

	if (lfun <= rfun) {
f01031c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01031c8:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01031cb:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01031ce:	83 c4 10             	add    $0x10,%esp
f01031d1:	39 c8                	cmp    %ecx,%eax
f01031d3:	0f 8f b6 00 00 00    	jg     f010328f <debuginfo_eip+0x198>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01031d9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01031dc:	c7 c1 34 52 10 f0    	mov    $0xf0105234,%ecx
f01031e2:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f01031e5:	8b 11                	mov    (%ecx),%edx
f01031e7:	89 55 c0             	mov    %edx,-0x40(%ebp)
f01031ea:	c7 c2 42 da 10 f0    	mov    $0xf010da42,%edx
f01031f0:	81 ea 19 bc 10 f0    	sub    $0xf010bc19,%edx
f01031f6:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f01031f9:	73 0c                	jae    f0103207 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01031fb:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01031fe:	81 c2 19 bc 10 f0    	add    $0xf010bc19,%edx
f0103204:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103207:	8b 51 08             	mov    0x8(%ecx),%edx
f010320a:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f010320d:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f010320f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103212:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103215:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103218:	83 ec 08             	sub    $0x8,%esp
f010321b:	6a 3a                	push   $0x3a
f010321d:	ff 76 08             	pushl  0x8(%esi)
f0103220:	e8 1c 0a 00 00       	call   f0103c41 <strfind>
f0103225:	2b 46 08             	sub    0x8(%esi),%eax
f0103228:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010322b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010322e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103231:	83 c4 08             	add    $0x8,%esp
f0103234:	57                   	push   %edi
f0103235:	6a 44                	push   $0x44
f0103237:	c7 c0 34 52 10 f0    	mov    $0xf0105234,%eax
f010323d:	e8 c5 fd ff ff       	call   f0103007 <stab_binsearch>
	if(lline > rline)
f0103242:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103245:	83 c4 10             	add    $0x10,%esp
f0103248:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f010324b:	0f 8f 1a 01 00 00    	jg     f010336b <debuginfo_eip+0x274>
		return -1;
	else
		info->eip_line = stabs[lline].n_desc;
f0103251:	89 d0                	mov    %edx,%eax
f0103253:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103256:	c1 e2 02             	shl    $0x2,%edx
f0103259:	c7 c1 34 52 10 f0    	mov    $0xf0105234,%ecx
f010325f:	0f b7 7c 0a 06       	movzwl 0x6(%edx,%ecx,1),%edi
f0103264:	89 7e 04             	mov    %edi,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103267:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010326a:	8d 54 0a 04          	lea    0x4(%edx,%ecx,1),%edx
f010326e:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103272:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103275:	eb 36                	jmp    f01032ad <debuginfo_eip+0x1b6>
  	        panic("User address");
f0103277:	83 ec 04             	sub    $0x4,%esp
f010327a:	8d 83 1c dd fe ff    	lea    -0x122e4(%ebx),%eax
f0103280:	50                   	push   %eax
f0103281:	6a 7f                	push   $0x7f
f0103283:	8d 83 29 dd fe ff    	lea    -0x122d7(%ebx),%eax
f0103289:	50                   	push   %eax
f010328a:	e8 70 ce ff ff       	call   f01000ff <_panic>
		info->eip_fn_addr = addr;
f010328f:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0103292:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103295:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103298:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010329b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010329e:	e9 75 ff ff ff       	jmp    f0103218 <debuginfo_eip+0x121>
f01032a3:	83 e8 01             	sub    $0x1,%eax
f01032a6:	83 ea 0c             	sub    $0xc,%edx
f01032a9:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f01032ad:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f01032b0:	39 c7                	cmp    %eax,%edi
f01032b2:	7f 24                	jg     f01032d8 <debuginfo_eip+0x1e1>
	       && stabs[lline].n_type != N_SOL
f01032b4:	0f b6 0a             	movzbl (%edx),%ecx
f01032b7:	80 f9 84             	cmp    $0x84,%cl
f01032ba:	74 46                	je     f0103302 <debuginfo_eip+0x20b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01032bc:	80 f9 64             	cmp    $0x64,%cl
f01032bf:	75 e2                	jne    f01032a3 <debuginfo_eip+0x1ac>
f01032c1:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f01032c5:	74 dc                	je     f01032a3 <debuginfo_eip+0x1ac>
f01032c7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01032ca:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01032ce:	74 3b                	je     f010330b <debuginfo_eip+0x214>
f01032d0:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01032d3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01032d6:	eb 33                	jmp    f010330b <debuginfo_eip+0x214>
f01032d8:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01032db:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032de:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01032e1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01032e6:	39 fa                	cmp    %edi,%edx
f01032e8:	0f 8d 89 00 00 00    	jge    f0103377 <debuginfo_eip+0x280>
		for (lline = lfun + 1;
f01032ee:	83 c2 01             	add    $0x1,%edx
f01032f1:	89 d0                	mov    %edx,%eax
f01032f3:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f01032f6:	c7 c2 34 52 10 f0    	mov    $0xf0105234,%edx
f01032fc:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0103300:	eb 3b                	jmp    f010333d <debuginfo_eip+0x246>
f0103302:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103305:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103309:	75 26                	jne    f0103331 <debuginfo_eip+0x23a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010330b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010330e:	c7 c0 34 52 10 f0    	mov    $0xf0105234,%eax
f0103314:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0103317:	c7 c0 42 da 10 f0    	mov    $0xf010da42,%eax
f010331d:	81 e8 19 bc 10 f0    	sub    $0xf010bc19,%eax
f0103323:	39 c2                	cmp    %eax,%edx
f0103325:	73 b4                	jae    f01032db <debuginfo_eip+0x1e4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103327:	81 c2 19 bc 10 f0    	add    $0xf010bc19,%edx
f010332d:	89 16                	mov    %edx,(%esi)
f010332f:	eb aa                	jmp    f01032db <debuginfo_eip+0x1e4>
f0103331:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103334:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103337:	eb d2                	jmp    f010330b <debuginfo_eip+0x214>
			info->eip_fn_narg++;
f0103339:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f010333d:	39 c7                	cmp    %eax,%edi
f010333f:	7e 31                	jle    f0103372 <debuginfo_eip+0x27b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103341:	0f b6 0a             	movzbl (%edx),%ecx
f0103344:	83 c0 01             	add    $0x1,%eax
f0103347:	83 c2 0c             	add    $0xc,%edx
f010334a:	80 f9 a0             	cmp    $0xa0,%cl
f010334d:	74 ea                	je     f0103339 <debuginfo_eip+0x242>
	return 0;
f010334f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103354:	eb 21                	jmp    f0103377 <debuginfo_eip+0x280>
		return -1;
f0103356:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010335b:	eb 1a                	jmp    f0103377 <debuginfo_eip+0x280>
f010335d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103362:	eb 13                	jmp    f0103377 <debuginfo_eip+0x280>
		return -1;
f0103364:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103369:	eb 0c                	jmp    f0103377 <debuginfo_eip+0x280>
		return -1;
f010336b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103370:	eb 05                	jmp    f0103377 <debuginfo_eip+0x280>
	return 0;
f0103372:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103377:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010337a:	5b                   	pop    %ebx
f010337b:	5e                   	pop    %esi
f010337c:	5f                   	pop    %edi
f010337d:	5d                   	pop    %ebp
f010337e:	c3                   	ret    

f010337f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010337f:	55                   	push   %ebp
f0103380:	89 e5                	mov    %esp,%ebp
f0103382:	57                   	push   %edi
f0103383:	56                   	push   %esi
f0103384:	53                   	push   %ebx
f0103385:	83 ec 2c             	sub    $0x2c,%esp
f0103388:	e8 d3 fb ff ff       	call   f0102f60 <__x86.get_pc_thunk.cx>
f010338d:	81 c1 7b 3f 01 00    	add    $0x13f7b,%ecx
f0103393:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0103396:	89 c7                	mov    %eax,%edi
f0103398:	89 d6                	mov    %edx,%esi
f010339a:	8b 45 08             	mov    0x8(%ebp),%eax
f010339d:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01033a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01033a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01033a9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01033ae:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f01033b1:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f01033b4:	39 d3                	cmp    %edx,%ebx
f01033b6:	72 09                	jb     f01033c1 <printnum+0x42>
f01033b8:	39 45 10             	cmp    %eax,0x10(%ebp)
f01033bb:	0f 87 83 00 00 00    	ja     f0103444 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01033c1:	83 ec 0c             	sub    $0xc,%esp
f01033c4:	ff 75 18             	pushl  0x18(%ebp)
f01033c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01033ca:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01033cd:	53                   	push   %ebx
f01033ce:	ff 75 10             	pushl  0x10(%ebp)
f01033d1:	83 ec 08             	sub    $0x8,%esp
f01033d4:	ff 75 dc             	pushl  -0x24(%ebp)
f01033d7:	ff 75 d8             	pushl  -0x28(%ebp)
f01033da:	ff 75 d4             	pushl  -0x2c(%ebp)
f01033dd:	ff 75 d0             	pushl  -0x30(%ebp)
f01033e0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01033e3:	e8 78 0a 00 00       	call   f0103e60 <__udivdi3>
f01033e8:	83 c4 18             	add    $0x18,%esp
f01033eb:	52                   	push   %edx
f01033ec:	50                   	push   %eax
f01033ed:	89 f2                	mov    %esi,%edx
f01033ef:	89 f8                	mov    %edi,%eax
f01033f1:	e8 89 ff ff ff       	call   f010337f <printnum>
f01033f6:	83 c4 20             	add    $0x20,%esp
f01033f9:	eb 13                	jmp    f010340e <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01033fb:	83 ec 08             	sub    $0x8,%esp
f01033fe:	56                   	push   %esi
f01033ff:	ff 75 18             	pushl  0x18(%ebp)
f0103402:	ff d7                	call   *%edi
f0103404:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103407:	83 eb 01             	sub    $0x1,%ebx
f010340a:	85 db                	test   %ebx,%ebx
f010340c:	7f ed                	jg     f01033fb <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010340e:	83 ec 08             	sub    $0x8,%esp
f0103411:	56                   	push   %esi
f0103412:	83 ec 04             	sub    $0x4,%esp
f0103415:	ff 75 dc             	pushl  -0x24(%ebp)
f0103418:	ff 75 d8             	pushl  -0x28(%ebp)
f010341b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010341e:	ff 75 d0             	pushl  -0x30(%ebp)
f0103421:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103424:	89 f3                	mov    %esi,%ebx
f0103426:	e8 55 0b 00 00       	call   f0103f80 <__umoddi3>
f010342b:	83 c4 14             	add    $0x14,%esp
f010342e:	0f be 84 06 37 dd fe 	movsbl -0x122c9(%esi,%eax,1),%eax
f0103435:	ff 
f0103436:	50                   	push   %eax
f0103437:	ff d7                	call   *%edi
}
f0103439:	83 c4 10             	add    $0x10,%esp
f010343c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010343f:	5b                   	pop    %ebx
f0103440:	5e                   	pop    %esi
f0103441:	5f                   	pop    %edi
f0103442:	5d                   	pop    %ebp
f0103443:	c3                   	ret    
f0103444:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103447:	eb be                	jmp    f0103407 <printnum+0x88>

f0103449 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103449:	55                   	push   %ebp
f010344a:	89 e5                	mov    %esp,%ebp
f010344c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010344f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103453:	8b 10                	mov    (%eax),%edx
f0103455:	3b 50 04             	cmp    0x4(%eax),%edx
f0103458:	73 0a                	jae    f0103464 <sprintputch+0x1b>
		*b->buf++ = ch;
f010345a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010345d:	89 08                	mov    %ecx,(%eax)
f010345f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103462:	88 02                	mov    %al,(%edx)
}
f0103464:	5d                   	pop    %ebp
f0103465:	c3                   	ret    

f0103466 <printfmt>:
{
f0103466:	55                   	push   %ebp
f0103467:	89 e5                	mov    %esp,%ebp
f0103469:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010346c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010346f:	50                   	push   %eax
f0103470:	ff 75 10             	pushl  0x10(%ebp)
f0103473:	ff 75 0c             	pushl  0xc(%ebp)
f0103476:	ff 75 08             	pushl  0x8(%ebp)
f0103479:	e8 05 00 00 00       	call   f0103483 <vprintfmt>
}
f010347e:	83 c4 10             	add    $0x10,%esp
f0103481:	c9                   	leave  
f0103482:	c3                   	ret    

f0103483 <vprintfmt>:
{
f0103483:	55                   	push   %ebp
f0103484:	89 e5                	mov    %esp,%ebp
f0103486:	57                   	push   %edi
f0103487:	56                   	push   %esi
f0103488:	53                   	push   %ebx
f0103489:	83 ec 3c             	sub    $0x3c,%esp
f010348c:	e8 24 cd ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f0103491:	81 c3 77 3e 01 00    	add    $0x13e77,%ebx
f0103497:	8b 75 0c             	mov    0xc(%ebp),%esi
f010349a:	8b 7d 10             	mov    0x10(%ebp),%edi
			csa = num;
f010349d:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01034a3:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01034a6:	e9 d7 03 00 00       	jmp    f0103882 <.L36+0x48>
				csa = 0x0700;
f01034ab:	c7 c0 c8 96 11 f0    	mov    $0xf01196c8,%eax
f01034b1:	c7 00 00 07 00 00    	movl   $0x700,(%eax)
}
f01034b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034ba:	5b                   	pop    %ebx
f01034bb:	5e                   	pop    %esi
f01034bc:	5f                   	pop    %edi
f01034bd:	5d                   	pop    %ebp
f01034be:	c3                   	ret    
		padc = ' ';
f01034bf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f01034c3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01034ca:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f01034d1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01034d8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01034dd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01034e0:	8d 47 01             	lea    0x1(%edi),%eax
f01034e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01034e6:	0f b6 17             	movzbl (%edi),%edx
f01034e9:	8d 42 dd             	lea    -0x23(%edx),%eax
f01034ec:	3c 55                	cmp    $0x55,%al
f01034ee:	0f 87 5a 04 00 00    	ja     f010394e <.L22>
f01034f4:	0f b6 c0             	movzbl %al,%eax
f01034f7:	89 d9                	mov    %ebx,%ecx
f01034f9:	03 8c 83 c4 dd fe ff 	add    -0x1223c(%ebx,%eax,4),%ecx
f0103500:	ff e1                	jmp    *%ecx

f0103502 <.L73>:
f0103502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0103505:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0103509:	eb d5                	jmp    f01034e0 <vprintfmt+0x5d>

f010350b <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f010350b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f010350e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103512:	eb cc                	jmp    f01034e0 <vprintfmt+0x5d>

f0103514 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0103514:	0f b6 d2             	movzbl %dl,%edx
f0103517:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010351a:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f010351f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103522:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103526:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103529:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010352c:	83 f9 09             	cmp    $0x9,%ecx
f010352f:	77 55                	ja     f0103586 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0103531:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0103534:	eb e9                	jmp    f010351f <.L29+0xb>

f0103536 <.L26>:
			precision = va_arg(ap, int);
f0103536:	8b 45 14             	mov    0x14(%ebp),%eax
f0103539:	8b 00                	mov    (%eax),%eax
f010353b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010353e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103541:	8d 40 04             	lea    0x4(%eax),%eax
f0103544:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010354a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010354e:	79 90                	jns    f01034e0 <vprintfmt+0x5d>
				width = precision, precision = -1;
f0103550:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103553:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103556:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f010355d:	eb 81                	jmp    f01034e0 <vprintfmt+0x5d>

f010355f <.L27>:
f010355f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103562:	85 c0                	test   %eax,%eax
f0103564:	ba 00 00 00 00       	mov    $0x0,%edx
f0103569:	0f 49 d0             	cmovns %eax,%edx
f010356c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010356f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103572:	e9 69 ff ff ff       	jmp    f01034e0 <vprintfmt+0x5d>

f0103577 <.L23>:
f0103577:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f010357a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103581:	e9 5a ff ff ff       	jmp    f01034e0 <vprintfmt+0x5d>
f0103586:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103589:	eb bf                	jmp    f010354a <.L26+0x14>

f010358b <.L33>:
			lflag++;
f010358b:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010358f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0103592:	e9 49 ff ff ff       	jmp    f01034e0 <vprintfmt+0x5d>

f0103597 <.L30>:
			putch(va_arg(ap, int), putdat);
f0103597:	8b 45 14             	mov    0x14(%ebp),%eax
f010359a:	8d 78 04             	lea    0x4(%eax),%edi
f010359d:	83 ec 08             	sub    $0x8,%esp
f01035a0:	56                   	push   %esi
f01035a1:	ff 30                	pushl  (%eax)
f01035a3:	ff 55 08             	call   *0x8(%ebp)
			break;
f01035a6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01035a9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01035ac:	e9 ce 02 00 00       	jmp    f010387f <.L36+0x45>

f01035b1 <.L32>:
			err = va_arg(ap, int);
f01035b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01035b4:	8d 78 04             	lea    0x4(%eax),%edi
f01035b7:	8b 00                	mov    (%eax),%eax
f01035b9:	99                   	cltd   
f01035ba:	31 d0                	xor    %edx,%eax
f01035bc:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01035be:	83 f8 06             	cmp    $0x6,%eax
f01035c1:	7f 27                	jg     f01035ea <.L32+0x39>
f01035c3:	8b 94 83 20 1d 00 00 	mov    0x1d20(%ebx,%eax,4),%edx
f01035ca:	85 d2                	test   %edx,%edx
f01035cc:	74 1c                	je     f01035ea <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f01035ce:	52                   	push   %edx
f01035cf:	8d 83 88 da fe ff    	lea    -0x12578(%ebx),%eax
f01035d5:	50                   	push   %eax
f01035d6:	56                   	push   %esi
f01035d7:	ff 75 08             	pushl  0x8(%ebp)
f01035da:	e8 87 fe ff ff       	call   f0103466 <printfmt>
f01035df:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01035e2:	89 7d 14             	mov    %edi,0x14(%ebp)
f01035e5:	e9 95 02 00 00       	jmp    f010387f <.L36+0x45>
				printfmt(putch, putdat, "error %d", err);
f01035ea:	50                   	push   %eax
f01035eb:	8d 83 4f dd fe ff    	lea    -0x122b1(%ebx),%eax
f01035f1:	50                   	push   %eax
f01035f2:	56                   	push   %esi
f01035f3:	ff 75 08             	pushl  0x8(%ebp)
f01035f6:	e8 6b fe ff ff       	call   f0103466 <printfmt>
f01035fb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01035fe:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103601:	e9 79 02 00 00       	jmp    f010387f <.L36+0x45>

f0103606 <.L37>:
			if ((p = va_arg(ap, char *)) == NULL)
f0103606:	8b 45 14             	mov    0x14(%ebp),%eax
f0103609:	83 c0 04             	add    $0x4,%eax
f010360c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010360f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103612:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103614:	85 ff                	test   %edi,%edi
f0103616:	8d 83 48 dd fe ff    	lea    -0x122b8(%ebx),%eax
f010361c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010361f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103623:	0f 8e b5 00 00 00    	jle    f01036de <.L37+0xd8>
f0103629:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010362d:	75 08                	jne    f0103637 <.L37+0x31>
f010362f:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103632:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0103635:	eb 6d                	jmp    f01036a4 <.L37+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103637:	83 ec 08             	sub    $0x8,%esp
f010363a:	ff 75 cc             	pushl  -0x34(%ebp)
f010363d:	57                   	push   %edi
f010363e:	e8 ba 04 00 00       	call   f0103afd <strnlen>
f0103643:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103646:	29 c2                	sub    %eax,%edx
f0103648:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010364b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010364e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103652:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103655:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103658:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f010365a:	eb 10                	jmp    f010366c <.L37+0x66>
					putch(padc, putdat);
f010365c:	83 ec 08             	sub    $0x8,%esp
f010365f:	56                   	push   %esi
f0103660:	ff 75 e0             	pushl  -0x20(%ebp)
f0103663:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0103666:	83 ef 01             	sub    $0x1,%edi
f0103669:	83 c4 10             	add    $0x10,%esp
f010366c:	85 ff                	test   %edi,%edi
f010366e:	7f ec                	jg     f010365c <.L37+0x56>
f0103670:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103673:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103676:	85 d2                	test   %edx,%edx
f0103678:	b8 00 00 00 00       	mov    $0x0,%eax
f010367d:	0f 49 c2             	cmovns %edx,%eax
f0103680:	29 c2                	sub    %eax,%edx
f0103682:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0103685:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103688:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010368b:	eb 17                	jmp    f01036a4 <.L37+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f010368d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103691:	75 30                	jne    f01036c3 <.L37+0xbd>
					putch(ch, putdat);
f0103693:	83 ec 08             	sub    $0x8,%esp
f0103696:	ff 75 0c             	pushl  0xc(%ebp)
f0103699:	50                   	push   %eax
f010369a:	ff 55 08             	call   *0x8(%ebp)
f010369d:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01036a0:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01036a4:	83 c7 01             	add    $0x1,%edi
f01036a7:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01036ab:	0f be c2             	movsbl %dl,%eax
f01036ae:	85 c0                	test   %eax,%eax
f01036b0:	74 52                	je     f0103704 <.L37+0xfe>
f01036b2:	85 f6                	test   %esi,%esi
f01036b4:	78 d7                	js     f010368d <.L37+0x87>
f01036b6:	83 ee 01             	sub    $0x1,%esi
f01036b9:	79 d2                	jns    f010368d <.L37+0x87>
f01036bb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01036be:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01036c1:	eb 32                	jmp    f01036f5 <.L37+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f01036c3:	0f be d2             	movsbl %dl,%edx
f01036c6:	83 ea 20             	sub    $0x20,%edx
f01036c9:	83 fa 5e             	cmp    $0x5e,%edx
f01036cc:	76 c5                	jbe    f0103693 <.L37+0x8d>
					putch('?', putdat);
f01036ce:	83 ec 08             	sub    $0x8,%esp
f01036d1:	ff 75 0c             	pushl  0xc(%ebp)
f01036d4:	6a 3f                	push   $0x3f
f01036d6:	ff 55 08             	call   *0x8(%ebp)
f01036d9:	83 c4 10             	add    $0x10,%esp
f01036dc:	eb c2                	jmp    f01036a0 <.L37+0x9a>
f01036de:	89 75 0c             	mov    %esi,0xc(%ebp)
f01036e1:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01036e4:	eb be                	jmp    f01036a4 <.L37+0x9e>
				putch(' ', putdat);
f01036e6:	83 ec 08             	sub    $0x8,%esp
f01036e9:	56                   	push   %esi
f01036ea:	6a 20                	push   $0x20
f01036ec:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f01036ef:	83 ef 01             	sub    $0x1,%edi
f01036f2:	83 c4 10             	add    $0x10,%esp
f01036f5:	85 ff                	test   %edi,%edi
f01036f7:	7f ed                	jg     f01036e6 <.L37+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f01036f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01036fc:	89 45 14             	mov    %eax,0x14(%ebp)
f01036ff:	e9 7b 01 00 00       	jmp    f010387f <.L36+0x45>
f0103704:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103707:	8b 75 0c             	mov    0xc(%ebp),%esi
f010370a:	eb e9                	jmp    f01036f5 <.L37+0xef>

f010370c <.L31>:
f010370c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010370f:	83 f9 01             	cmp    $0x1,%ecx
f0103712:	7e 40                	jle    f0103754 <.L31+0x48>
		return va_arg(*ap, long long);
f0103714:	8b 45 14             	mov    0x14(%ebp),%eax
f0103717:	8b 50 04             	mov    0x4(%eax),%edx
f010371a:	8b 00                	mov    (%eax),%eax
f010371c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010371f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103722:	8b 45 14             	mov    0x14(%ebp),%eax
f0103725:	8d 40 08             	lea    0x8(%eax),%eax
f0103728:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010372b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010372f:	79 55                	jns    f0103786 <.L31+0x7a>
				putch('-', putdat);
f0103731:	83 ec 08             	sub    $0x8,%esp
f0103734:	56                   	push   %esi
f0103735:	6a 2d                	push   $0x2d
f0103737:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010373a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010373d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103740:	f7 da                	neg    %edx
f0103742:	83 d1 00             	adc    $0x0,%ecx
f0103745:	f7 d9                	neg    %ecx
f0103747:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010374a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010374f:	e9 10 01 00 00       	jmp    f0103864 <.L36+0x2a>
	else if (lflag)
f0103754:	85 c9                	test   %ecx,%ecx
f0103756:	75 17                	jne    f010376f <.L31+0x63>
		return va_arg(*ap, int);
f0103758:	8b 45 14             	mov    0x14(%ebp),%eax
f010375b:	8b 00                	mov    (%eax),%eax
f010375d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103760:	99                   	cltd   
f0103761:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103764:	8b 45 14             	mov    0x14(%ebp),%eax
f0103767:	8d 40 04             	lea    0x4(%eax),%eax
f010376a:	89 45 14             	mov    %eax,0x14(%ebp)
f010376d:	eb bc                	jmp    f010372b <.L31+0x1f>
		return va_arg(*ap, long);
f010376f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103772:	8b 00                	mov    (%eax),%eax
f0103774:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103777:	99                   	cltd   
f0103778:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010377b:	8b 45 14             	mov    0x14(%ebp),%eax
f010377e:	8d 40 04             	lea    0x4(%eax),%eax
f0103781:	89 45 14             	mov    %eax,0x14(%ebp)
f0103784:	eb a5                	jmp    f010372b <.L31+0x1f>
			num = getint(&ap, lflag);
f0103786:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103789:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010378c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103791:	e9 ce 00 00 00       	jmp    f0103864 <.L36+0x2a>

f0103796 <.L38>:
f0103796:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0103799:	83 f9 01             	cmp    $0x1,%ecx
f010379c:	7e 18                	jle    f01037b6 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
f010379e:	8b 45 14             	mov    0x14(%ebp),%eax
f01037a1:	8b 10                	mov    (%eax),%edx
f01037a3:	8b 48 04             	mov    0x4(%eax),%ecx
f01037a6:	8d 40 08             	lea    0x8(%eax),%eax
f01037a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01037ac:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037b1:	e9 ae 00 00 00       	jmp    f0103864 <.L36+0x2a>
	else if (lflag)
f01037b6:	85 c9                	test   %ecx,%ecx
f01037b8:	75 1a                	jne    f01037d4 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
f01037ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01037bd:	8b 10                	mov    (%eax),%edx
f01037bf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01037c4:	8d 40 04             	lea    0x4(%eax),%eax
f01037c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01037ca:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037cf:	e9 90 00 00 00       	jmp    f0103864 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f01037d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01037d7:	8b 10                	mov    (%eax),%edx
f01037d9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01037de:	8d 40 04             	lea    0x4(%eax),%eax
f01037e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01037e4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037e9:	eb 79                	jmp    f0103864 <.L36+0x2a>

f01037eb <.L35>:
f01037eb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01037ee:	83 f9 01             	cmp    $0x1,%ecx
f01037f1:	7e 15                	jle    f0103808 <.L35+0x1d>
		return va_arg(*ap, unsigned long long);
f01037f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01037f6:	8b 10                	mov    (%eax),%edx
f01037f8:	8b 48 04             	mov    0x4(%eax),%ecx
f01037fb:	8d 40 08             	lea    0x8(%eax),%eax
f01037fe:	89 45 14             	mov    %eax,0x14(%ebp)
      			base = 8;
f0103801:	b8 08 00 00 00       	mov    $0x8,%eax
f0103806:	eb 5c                	jmp    f0103864 <.L36+0x2a>
	else if (lflag)
f0103808:	85 c9                	test   %ecx,%ecx
f010380a:	75 17                	jne    f0103823 <.L35+0x38>
		return va_arg(*ap, unsigned int);
f010380c:	8b 45 14             	mov    0x14(%ebp),%eax
f010380f:	8b 10                	mov    (%eax),%edx
f0103811:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103816:	8d 40 04             	lea    0x4(%eax),%eax
f0103819:	89 45 14             	mov    %eax,0x14(%ebp)
      			base = 8;
f010381c:	b8 08 00 00 00       	mov    $0x8,%eax
f0103821:	eb 41                	jmp    f0103864 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f0103823:	8b 45 14             	mov    0x14(%ebp),%eax
f0103826:	8b 10                	mov    (%eax),%edx
f0103828:	b9 00 00 00 00       	mov    $0x0,%ecx
f010382d:	8d 40 04             	lea    0x4(%eax),%eax
f0103830:	89 45 14             	mov    %eax,0x14(%ebp)
      			base = 8;
f0103833:	b8 08 00 00 00       	mov    $0x8,%eax
f0103838:	eb 2a                	jmp    f0103864 <.L36+0x2a>

f010383a <.L36>:
			putch('0', putdat);
f010383a:	83 ec 08             	sub    $0x8,%esp
f010383d:	56                   	push   %esi
f010383e:	6a 30                	push   $0x30
f0103840:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103843:	83 c4 08             	add    $0x8,%esp
f0103846:	56                   	push   %esi
f0103847:	6a 78                	push   $0x78
f0103849:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f010384c:	8b 45 14             	mov    0x14(%ebp),%eax
f010384f:	8b 10                	mov    (%eax),%edx
f0103851:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0103856:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103859:	8d 40 04             	lea    0x4(%eax),%eax
f010385c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010385f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0103864:	83 ec 0c             	sub    $0xc,%esp
f0103867:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010386b:	57                   	push   %edi
f010386c:	ff 75 e0             	pushl  -0x20(%ebp)
f010386f:	50                   	push   %eax
f0103870:	51                   	push   %ecx
f0103871:	52                   	push   %edx
f0103872:	89 f2                	mov    %esi,%edx
f0103874:	8b 45 08             	mov    0x8(%ebp),%eax
f0103877:	e8 03 fb ff ff       	call   f010337f <printnum>
			break;
f010387c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010387f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103882:	83 c7 01             	add    $0x1,%edi
f0103885:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103889:	83 f8 25             	cmp    $0x25,%eax
f010388c:	0f 84 2d fc ff ff    	je     f01034bf <vprintfmt+0x3c>
			if (ch == '\0'){
f0103892:	85 c0                	test   %eax,%eax
f0103894:	0f 84 11 fc ff ff    	je     f01034ab <vprintfmt+0x28>
			putch(ch, putdat);
f010389a:	83 ec 08             	sub    $0x8,%esp
f010389d:	56                   	push   %esi
f010389e:	50                   	push   %eax
f010389f:	ff 55 08             	call   *0x8(%ebp)
f01038a2:	83 c4 10             	add    $0x10,%esp
f01038a5:	eb db                	jmp    f0103882 <.L36+0x48>

f01038a7 <.L39>:
f01038a7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01038aa:	83 f9 01             	cmp    $0x1,%ecx
f01038ad:	7e 15                	jle    f01038c4 <.L39+0x1d>
		return va_arg(*ap, unsigned long long);
f01038af:	8b 45 14             	mov    0x14(%ebp),%eax
f01038b2:	8b 10                	mov    (%eax),%edx
f01038b4:	8b 48 04             	mov    0x4(%eax),%ecx
f01038b7:	8d 40 08             	lea    0x8(%eax),%eax
f01038ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01038bd:	b8 10 00 00 00       	mov    $0x10,%eax
f01038c2:	eb a0                	jmp    f0103864 <.L36+0x2a>
	else if (lflag)
f01038c4:	85 c9                	test   %ecx,%ecx
f01038c6:	75 17                	jne    f01038df <.L39+0x38>
		return va_arg(*ap, unsigned int);
f01038c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01038cb:	8b 10                	mov    (%eax),%edx
f01038cd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01038d2:	8d 40 04             	lea    0x4(%eax),%eax
f01038d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01038d8:	b8 10 00 00 00       	mov    $0x10,%eax
f01038dd:	eb 85                	jmp    f0103864 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f01038df:	8b 45 14             	mov    0x14(%ebp),%eax
f01038e2:	8b 10                	mov    (%eax),%edx
f01038e4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01038e9:	8d 40 04             	lea    0x4(%eax),%eax
f01038ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01038ef:	b8 10 00 00 00       	mov    $0x10,%eax
f01038f4:	e9 6b ff ff ff       	jmp    f0103864 <.L36+0x2a>

f01038f9 <.L25>:
			putch(ch, putdat);
f01038f9:	83 ec 08             	sub    $0x8,%esp
f01038fc:	56                   	push   %esi
f01038fd:	6a 25                	push   $0x25
f01038ff:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103902:	83 c4 10             	add    $0x10,%esp
f0103905:	e9 75 ff ff ff       	jmp    f010387f <.L36+0x45>

f010390a <.L34>:
f010390a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010390d:	83 f9 01             	cmp    $0x1,%ecx
f0103910:	7e 18                	jle    f010392a <.L34+0x20>
		return va_arg(*ap, long long);
f0103912:	8b 45 14             	mov    0x14(%ebp),%eax
f0103915:	8b 00                	mov    (%eax),%eax
f0103917:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010391a:	8d 49 08             	lea    0x8(%ecx),%ecx
f010391d:	89 4d 14             	mov    %ecx,0x14(%ebp)
			csa = num;
f0103920:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103923:	89 01                	mov    %eax,(%ecx)
			break;
f0103925:	e9 55 ff ff ff       	jmp    f010387f <.L36+0x45>
	else if (lflag)
f010392a:	85 c9                	test   %ecx,%ecx
f010392c:	75 10                	jne    f010393e <.L34+0x34>
		return va_arg(*ap, int);
f010392e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103931:	8b 00                	mov    (%eax),%eax
f0103933:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103936:	8d 49 04             	lea    0x4(%ecx),%ecx
f0103939:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010393c:	eb e2                	jmp    f0103920 <.L34+0x16>
		return va_arg(*ap, long);
f010393e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103941:	8b 00                	mov    (%eax),%eax
f0103943:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103946:	8d 49 04             	lea    0x4(%ecx),%ecx
f0103949:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010394c:	eb d2                	jmp    f0103920 <.L34+0x16>

f010394e <.L22>:
			putch('%', putdat);
f010394e:	83 ec 08             	sub    $0x8,%esp
f0103951:	56                   	push   %esi
f0103952:	6a 25                	push   $0x25
f0103954:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103957:	83 c4 10             	add    $0x10,%esp
f010395a:	89 f8                	mov    %edi,%eax
f010395c:	eb 03                	jmp    f0103961 <.L22+0x13>
f010395e:	83 e8 01             	sub    $0x1,%eax
f0103961:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0103965:	75 f7                	jne    f010395e <.L22+0x10>
f0103967:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010396a:	e9 10 ff ff ff       	jmp    f010387f <.L36+0x45>

f010396f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010396f:	55                   	push   %ebp
f0103970:	89 e5                	mov    %esp,%ebp
f0103972:	53                   	push   %ebx
f0103973:	83 ec 14             	sub    $0x14,%esp
f0103976:	e8 3a c8 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f010397b:	81 c3 8d 39 01 00    	add    $0x1398d,%ebx
f0103981:	8b 45 08             	mov    0x8(%ebp),%eax
f0103984:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103987:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010398a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010398e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103991:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103998:	85 c0                	test   %eax,%eax
f010399a:	74 2b                	je     f01039c7 <vsnprintf+0x58>
f010399c:	85 d2                	test   %edx,%edx
f010399e:	7e 27                	jle    f01039c7 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01039a0:	ff 75 14             	pushl  0x14(%ebp)
f01039a3:	ff 75 10             	pushl  0x10(%ebp)
f01039a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01039a9:	50                   	push   %eax
f01039aa:	8d 83 41 c1 fe ff    	lea    -0x13ebf(%ebx),%eax
f01039b0:	50                   	push   %eax
f01039b1:	e8 cd fa ff ff       	call   f0103483 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01039b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01039b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01039bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039bf:	83 c4 10             	add    $0x10,%esp
}
f01039c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01039c5:	c9                   	leave  
f01039c6:	c3                   	ret    
		return -E_INVAL;
f01039c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01039cc:	eb f4                	jmp    f01039c2 <vsnprintf+0x53>

f01039ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01039ce:	55                   	push   %ebp
f01039cf:	89 e5                	mov    %esp,%ebp
f01039d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01039d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01039d7:	50                   	push   %eax
f01039d8:	ff 75 10             	pushl  0x10(%ebp)
f01039db:	ff 75 0c             	pushl  0xc(%ebp)
f01039de:	ff 75 08             	pushl  0x8(%ebp)
f01039e1:	e8 89 ff ff ff       	call   f010396f <vsnprintf>
	va_end(ap);

	return rc;
}
f01039e6:	c9                   	leave  
f01039e7:	c3                   	ret    

f01039e8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01039e8:	55                   	push   %ebp
f01039e9:	89 e5                	mov    %esp,%ebp
f01039eb:	57                   	push   %edi
f01039ec:	56                   	push   %esi
f01039ed:	53                   	push   %ebx
f01039ee:	83 ec 1c             	sub    $0x1c,%esp
f01039f1:	e8 bf c7 ff ff       	call   f01001b5 <__x86.get_pc_thunk.bx>
f01039f6:	81 c3 12 39 01 00    	add    $0x13912,%ebx
f01039fc:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01039ff:	85 c0                	test   %eax,%eax
f0103a01:	74 13                	je     f0103a16 <readline+0x2e>
		cprintf("%s", prompt);
f0103a03:	83 ec 08             	sub    $0x8,%esp
f0103a06:	50                   	push   %eax
f0103a07:	8d 83 88 da fe ff    	lea    -0x12578(%ebx),%eax
f0103a0d:	50                   	push   %eax
f0103a0e:	e8 e0 f5 ff ff       	call   f0102ff3 <cprintf>
f0103a13:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103a16:	83 ec 0c             	sub    $0xc,%esp
f0103a19:	6a 00                	push   $0x0
f0103a1b:	e8 3f cd ff ff       	call   f010075f <iscons>
f0103a20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a23:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103a26:	bf 00 00 00 00       	mov    $0x0,%edi
f0103a2b:	eb 46                	jmp    f0103a73 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0103a2d:	83 ec 08             	sub    $0x8,%esp
f0103a30:	50                   	push   %eax
f0103a31:	8d 83 1c df fe ff    	lea    -0x120e4(%ebx),%eax
f0103a37:	50                   	push   %eax
f0103a38:	e8 b6 f5 ff ff       	call   f0102ff3 <cprintf>
			return NULL;
f0103a3d:	83 c4 10             	add    $0x10,%esp
f0103a40:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103a45:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a48:	5b                   	pop    %ebx
f0103a49:	5e                   	pop    %esi
f0103a4a:	5f                   	pop    %edi
f0103a4b:	5d                   	pop    %ebp
f0103a4c:	c3                   	ret    
			if (echoing)
f0103a4d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103a51:	75 05                	jne    f0103a58 <readline+0x70>
			i--;
f0103a53:	83 ef 01             	sub    $0x1,%edi
f0103a56:	eb 1b                	jmp    f0103a73 <readline+0x8b>
				cputchar('\b');
f0103a58:	83 ec 0c             	sub    $0xc,%esp
f0103a5b:	6a 08                	push   $0x8
f0103a5d:	e8 dc cc ff ff       	call   f010073e <cputchar>
f0103a62:	83 c4 10             	add    $0x10,%esp
f0103a65:	eb ec                	jmp    f0103a53 <readline+0x6b>
			buf[i++] = c;
f0103a67:	89 f0                	mov    %esi,%eax
f0103a69:	88 84 3b b8 1f 00 00 	mov    %al,0x1fb8(%ebx,%edi,1)
f0103a70:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0103a73:	e8 d6 cc ff ff       	call   f010074e <getchar>
f0103a78:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0103a7a:	85 c0                	test   %eax,%eax
f0103a7c:	78 af                	js     f0103a2d <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103a7e:	83 f8 08             	cmp    $0x8,%eax
f0103a81:	0f 94 c2             	sete   %dl
f0103a84:	83 f8 7f             	cmp    $0x7f,%eax
f0103a87:	0f 94 c0             	sete   %al
f0103a8a:	08 c2                	or     %al,%dl
f0103a8c:	74 04                	je     f0103a92 <readline+0xaa>
f0103a8e:	85 ff                	test   %edi,%edi
f0103a90:	7f bb                	jg     f0103a4d <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103a92:	83 fe 1f             	cmp    $0x1f,%esi
f0103a95:	7e 1c                	jle    f0103ab3 <readline+0xcb>
f0103a97:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0103a9d:	7f 14                	jg     f0103ab3 <readline+0xcb>
			if (echoing)
f0103a9f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103aa3:	74 c2                	je     f0103a67 <readline+0x7f>
				cputchar(c);
f0103aa5:	83 ec 0c             	sub    $0xc,%esp
f0103aa8:	56                   	push   %esi
f0103aa9:	e8 90 cc ff ff       	call   f010073e <cputchar>
f0103aae:	83 c4 10             	add    $0x10,%esp
f0103ab1:	eb b4                	jmp    f0103a67 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0103ab3:	83 fe 0a             	cmp    $0xa,%esi
f0103ab6:	74 05                	je     f0103abd <readline+0xd5>
f0103ab8:	83 fe 0d             	cmp    $0xd,%esi
f0103abb:	75 b6                	jne    f0103a73 <readline+0x8b>
			if (echoing)
f0103abd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103ac1:	75 13                	jne    f0103ad6 <readline+0xee>
			buf[i] = 0;
f0103ac3:	c6 84 3b b8 1f 00 00 	movb   $0x0,0x1fb8(%ebx,%edi,1)
f0103aca:	00 
			return buf;
f0103acb:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0103ad1:	e9 6f ff ff ff       	jmp    f0103a45 <readline+0x5d>
				cputchar('\n');
f0103ad6:	83 ec 0c             	sub    $0xc,%esp
f0103ad9:	6a 0a                	push   $0xa
f0103adb:	e8 5e cc ff ff       	call   f010073e <cputchar>
f0103ae0:	83 c4 10             	add    $0x10,%esp
f0103ae3:	eb de                	jmp    f0103ac3 <readline+0xdb>

f0103ae5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103ae5:	55                   	push   %ebp
f0103ae6:	89 e5                	mov    %esp,%ebp
f0103ae8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103aeb:	b8 00 00 00 00       	mov    $0x0,%eax
f0103af0:	eb 03                	jmp    f0103af5 <strlen+0x10>
		n++;
f0103af2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103af5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103af9:	75 f7                	jne    f0103af2 <strlen+0xd>
	return n;
}
f0103afb:	5d                   	pop    %ebp
f0103afc:	c3                   	ret    

f0103afd <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103afd:	55                   	push   %ebp
f0103afe:	89 e5                	mov    %esp,%ebp
f0103b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b03:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103b06:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b0b:	eb 03                	jmp    f0103b10 <strnlen+0x13>
		n++;
f0103b0d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103b10:	39 d0                	cmp    %edx,%eax
f0103b12:	74 06                	je     f0103b1a <strnlen+0x1d>
f0103b14:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103b18:	75 f3                	jne    f0103b0d <strnlen+0x10>
	return n;
}
f0103b1a:	5d                   	pop    %ebp
f0103b1b:	c3                   	ret    

f0103b1c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103b1c:	55                   	push   %ebp
f0103b1d:	89 e5                	mov    %esp,%ebp
f0103b1f:	53                   	push   %ebx
f0103b20:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103b26:	89 c2                	mov    %eax,%edx
f0103b28:	83 c1 01             	add    $0x1,%ecx
f0103b2b:	83 c2 01             	add    $0x1,%edx
f0103b2e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103b32:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103b35:	84 db                	test   %bl,%bl
f0103b37:	75 ef                	jne    f0103b28 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103b39:	5b                   	pop    %ebx
f0103b3a:	5d                   	pop    %ebp
f0103b3b:	c3                   	ret    

f0103b3c <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103b3c:	55                   	push   %ebp
f0103b3d:	89 e5                	mov    %esp,%ebp
f0103b3f:	53                   	push   %ebx
f0103b40:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103b43:	53                   	push   %ebx
f0103b44:	e8 9c ff ff ff       	call   f0103ae5 <strlen>
f0103b49:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103b4c:	ff 75 0c             	pushl  0xc(%ebp)
f0103b4f:	01 d8                	add    %ebx,%eax
f0103b51:	50                   	push   %eax
f0103b52:	e8 c5 ff ff ff       	call   f0103b1c <strcpy>
	return dst;
}
f0103b57:	89 d8                	mov    %ebx,%eax
f0103b59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b5c:	c9                   	leave  
f0103b5d:	c3                   	ret    

f0103b5e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103b5e:	55                   	push   %ebp
f0103b5f:	89 e5                	mov    %esp,%ebp
f0103b61:	56                   	push   %esi
f0103b62:	53                   	push   %ebx
f0103b63:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103b69:	89 f3                	mov    %esi,%ebx
f0103b6b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103b6e:	89 f2                	mov    %esi,%edx
f0103b70:	eb 0f                	jmp    f0103b81 <strncpy+0x23>
		*dst++ = *src;
f0103b72:	83 c2 01             	add    $0x1,%edx
f0103b75:	0f b6 01             	movzbl (%ecx),%eax
f0103b78:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103b7b:	80 39 01             	cmpb   $0x1,(%ecx)
f0103b7e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0103b81:	39 da                	cmp    %ebx,%edx
f0103b83:	75 ed                	jne    f0103b72 <strncpy+0x14>
	}
	return ret;
}
f0103b85:	89 f0                	mov    %esi,%eax
f0103b87:	5b                   	pop    %ebx
f0103b88:	5e                   	pop    %esi
f0103b89:	5d                   	pop    %ebp
f0103b8a:	c3                   	ret    

f0103b8b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103b8b:	55                   	push   %ebp
f0103b8c:	89 e5                	mov    %esp,%ebp
f0103b8e:	56                   	push   %esi
f0103b8f:	53                   	push   %ebx
f0103b90:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b93:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b96:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103b99:	89 f0                	mov    %esi,%eax
f0103b9b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103b9f:	85 c9                	test   %ecx,%ecx
f0103ba1:	75 0b                	jne    f0103bae <strlcpy+0x23>
f0103ba3:	eb 17                	jmp    f0103bbc <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103ba5:	83 c2 01             	add    $0x1,%edx
f0103ba8:	83 c0 01             	add    $0x1,%eax
f0103bab:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0103bae:	39 d8                	cmp    %ebx,%eax
f0103bb0:	74 07                	je     f0103bb9 <strlcpy+0x2e>
f0103bb2:	0f b6 0a             	movzbl (%edx),%ecx
f0103bb5:	84 c9                	test   %cl,%cl
f0103bb7:	75 ec                	jne    f0103ba5 <strlcpy+0x1a>
		*dst = '\0';
f0103bb9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103bbc:	29 f0                	sub    %esi,%eax
}
f0103bbe:	5b                   	pop    %ebx
f0103bbf:	5e                   	pop    %esi
f0103bc0:	5d                   	pop    %ebp
f0103bc1:	c3                   	ret    

f0103bc2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103bc2:	55                   	push   %ebp
f0103bc3:	89 e5                	mov    %esp,%ebp
f0103bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103bcb:	eb 06                	jmp    f0103bd3 <strcmp+0x11>
		p++, q++;
f0103bcd:	83 c1 01             	add    $0x1,%ecx
f0103bd0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0103bd3:	0f b6 01             	movzbl (%ecx),%eax
f0103bd6:	84 c0                	test   %al,%al
f0103bd8:	74 04                	je     f0103bde <strcmp+0x1c>
f0103bda:	3a 02                	cmp    (%edx),%al
f0103bdc:	74 ef                	je     f0103bcd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103bde:	0f b6 c0             	movzbl %al,%eax
f0103be1:	0f b6 12             	movzbl (%edx),%edx
f0103be4:	29 d0                	sub    %edx,%eax
}
f0103be6:	5d                   	pop    %ebp
f0103be7:	c3                   	ret    

f0103be8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103be8:	55                   	push   %ebp
f0103be9:	89 e5                	mov    %esp,%ebp
f0103beb:	53                   	push   %ebx
f0103bec:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bef:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103bf2:	89 c3                	mov    %eax,%ebx
f0103bf4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103bf7:	eb 06                	jmp    f0103bff <strncmp+0x17>
		n--, p++, q++;
f0103bf9:	83 c0 01             	add    $0x1,%eax
f0103bfc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103bff:	39 d8                	cmp    %ebx,%eax
f0103c01:	74 16                	je     f0103c19 <strncmp+0x31>
f0103c03:	0f b6 08             	movzbl (%eax),%ecx
f0103c06:	84 c9                	test   %cl,%cl
f0103c08:	74 04                	je     f0103c0e <strncmp+0x26>
f0103c0a:	3a 0a                	cmp    (%edx),%cl
f0103c0c:	74 eb                	je     f0103bf9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103c0e:	0f b6 00             	movzbl (%eax),%eax
f0103c11:	0f b6 12             	movzbl (%edx),%edx
f0103c14:	29 d0                	sub    %edx,%eax
}
f0103c16:	5b                   	pop    %ebx
f0103c17:	5d                   	pop    %ebp
f0103c18:	c3                   	ret    
		return 0;
f0103c19:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c1e:	eb f6                	jmp    f0103c16 <strncmp+0x2e>

f0103c20 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103c20:	55                   	push   %ebp
f0103c21:	89 e5                	mov    %esp,%ebp
f0103c23:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c26:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103c2a:	0f b6 10             	movzbl (%eax),%edx
f0103c2d:	84 d2                	test   %dl,%dl
f0103c2f:	74 09                	je     f0103c3a <strchr+0x1a>
		if (*s == c)
f0103c31:	38 ca                	cmp    %cl,%dl
f0103c33:	74 0a                	je     f0103c3f <strchr+0x1f>
	for (; *s; s++)
f0103c35:	83 c0 01             	add    $0x1,%eax
f0103c38:	eb f0                	jmp    f0103c2a <strchr+0xa>
			return (char *) s;
	return 0;
f0103c3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c3f:	5d                   	pop    %ebp
f0103c40:	c3                   	ret    

f0103c41 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103c41:	55                   	push   %ebp
f0103c42:	89 e5                	mov    %esp,%ebp
f0103c44:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c47:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103c4b:	eb 03                	jmp    f0103c50 <strfind+0xf>
f0103c4d:	83 c0 01             	add    $0x1,%eax
f0103c50:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103c53:	38 ca                	cmp    %cl,%dl
f0103c55:	74 04                	je     f0103c5b <strfind+0x1a>
f0103c57:	84 d2                	test   %dl,%dl
f0103c59:	75 f2                	jne    f0103c4d <strfind+0xc>
			break;
	return (char *) s;
}
f0103c5b:	5d                   	pop    %ebp
f0103c5c:	c3                   	ret    

f0103c5d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103c5d:	55                   	push   %ebp
f0103c5e:	89 e5                	mov    %esp,%ebp
f0103c60:	57                   	push   %edi
f0103c61:	56                   	push   %esi
f0103c62:	53                   	push   %ebx
f0103c63:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103c66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103c69:	85 c9                	test   %ecx,%ecx
f0103c6b:	74 13                	je     f0103c80 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103c6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103c73:	75 05                	jne    f0103c7a <memset+0x1d>
f0103c75:	f6 c1 03             	test   $0x3,%cl
f0103c78:	74 0d                	je     f0103c87 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c7d:	fc                   	cld    
f0103c7e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103c80:	89 f8                	mov    %edi,%eax
f0103c82:	5b                   	pop    %ebx
f0103c83:	5e                   	pop    %esi
f0103c84:	5f                   	pop    %edi
f0103c85:	5d                   	pop    %ebp
f0103c86:	c3                   	ret    
		c &= 0xFF;
f0103c87:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103c8b:	89 d3                	mov    %edx,%ebx
f0103c8d:	c1 e3 08             	shl    $0x8,%ebx
f0103c90:	89 d0                	mov    %edx,%eax
f0103c92:	c1 e0 18             	shl    $0x18,%eax
f0103c95:	89 d6                	mov    %edx,%esi
f0103c97:	c1 e6 10             	shl    $0x10,%esi
f0103c9a:	09 f0                	or     %esi,%eax
f0103c9c:	09 c2                	or     %eax,%edx
f0103c9e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0103ca0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103ca3:	89 d0                	mov    %edx,%eax
f0103ca5:	fc                   	cld    
f0103ca6:	f3 ab                	rep stos %eax,%es:(%edi)
f0103ca8:	eb d6                	jmp    f0103c80 <memset+0x23>

f0103caa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103caa:	55                   	push   %ebp
f0103cab:	89 e5                	mov    %esp,%ebp
f0103cad:	57                   	push   %edi
f0103cae:	56                   	push   %esi
f0103caf:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cb2:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103cb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103cb8:	39 c6                	cmp    %eax,%esi
f0103cba:	73 35                	jae    f0103cf1 <memmove+0x47>
f0103cbc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103cbf:	39 c2                	cmp    %eax,%edx
f0103cc1:	76 2e                	jbe    f0103cf1 <memmove+0x47>
		s += n;
		d += n;
f0103cc3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103cc6:	89 d6                	mov    %edx,%esi
f0103cc8:	09 fe                	or     %edi,%esi
f0103cca:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103cd0:	74 0c                	je     f0103cde <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103cd2:	83 ef 01             	sub    $0x1,%edi
f0103cd5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103cd8:	fd                   	std    
f0103cd9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103cdb:	fc                   	cld    
f0103cdc:	eb 21                	jmp    f0103cff <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103cde:	f6 c1 03             	test   $0x3,%cl
f0103ce1:	75 ef                	jne    f0103cd2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103ce3:	83 ef 04             	sub    $0x4,%edi
f0103ce6:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103ce9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103cec:	fd                   	std    
f0103ced:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103cef:	eb ea                	jmp    f0103cdb <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103cf1:	89 f2                	mov    %esi,%edx
f0103cf3:	09 c2                	or     %eax,%edx
f0103cf5:	f6 c2 03             	test   $0x3,%dl
f0103cf8:	74 09                	je     f0103d03 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103cfa:	89 c7                	mov    %eax,%edi
f0103cfc:	fc                   	cld    
f0103cfd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103cff:	5e                   	pop    %esi
f0103d00:	5f                   	pop    %edi
f0103d01:	5d                   	pop    %ebp
f0103d02:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103d03:	f6 c1 03             	test   $0x3,%cl
f0103d06:	75 f2                	jne    f0103cfa <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103d08:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103d0b:	89 c7                	mov    %eax,%edi
f0103d0d:	fc                   	cld    
f0103d0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103d10:	eb ed                	jmp    f0103cff <memmove+0x55>

f0103d12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103d12:	55                   	push   %ebp
f0103d13:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103d15:	ff 75 10             	pushl  0x10(%ebp)
f0103d18:	ff 75 0c             	pushl  0xc(%ebp)
f0103d1b:	ff 75 08             	pushl  0x8(%ebp)
f0103d1e:	e8 87 ff ff ff       	call   f0103caa <memmove>
}
f0103d23:	c9                   	leave  
f0103d24:	c3                   	ret    

f0103d25 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103d25:	55                   	push   %ebp
f0103d26:	89 e5                	mov    %esp,%ebp
f0103d28:	56                   	push   %esi
f0103d29:	53                   	push   %ebx
f0103d2a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d2d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d30:	89 c6                	mov    %eax,%esi
f0103d32:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103d35:	39 f0                	cmp    %esi,%eax
f0103d37:	74 1c                	je     f0103d55 <memcmp+0x30>
		if (*s1 != *s2)
f0103d39:	0f b6 08             	movzbl (%eax),%ecx
f0103d3c:	0f b6 1a             	movzbl (%edx),%ebx
f0103d3f:	38 d9                	cmp    %bl,%cl
f0103d41:	75 08                	jne    f0103d4b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103d43:	83 c0 01             	add    $0x1,%eax
f0103d46:	83 c2 01             	add    $0x1,%edx
f0103d49:	eb ea                	jmp    f0103d35 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0103d4b:	0f b6 c1             	movzbl %cl,%eax
f0103d4e:	0f b6 db             	movzbl %bl,%ebx
f0103d51:	29 d8                	sub    %ebx,%eax
f0103d53:	eb 05                	jmp    f0103d5a <memcmp+0x35>
	}

	return 0;
f0103d55:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d5a:	5b                   	pop    %ebx
f0103d5b:	5e                   	pop    %esi
f0103d5c:	5d                   	pop    %ebp
f0103d5d:	c3                   	ret    

f0103d5e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103d5e:	55                   	push   %ebp
f0103d5f:	89 e5                	mov    %esp,%ebp
f0103d61:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103d67:	89 c2                	mov    %eax,%edx
f0103d69:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103d6c:	39 d0                	cmp    %edx,%eax
f0103d6e:	73 09                	jae    f0103d79 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103d70:	38 08                	cmp    %cl,(%eax)
f0103d72:	74 05                	je     f0103d79 <memfind+0x1b>
	for (; s < ends; s++)
f0103d74:	83 c0 01             	add    $0x1,%eax
f0103d77:	eb f3                	jmp    f0103d6c <memfind+0xe>
			break;
	return (void *) s;
}
f0103d79:	5d                   	pop    %ebp
f0103d7a:	c3                   	ret    

f0103d7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103d7b:	55                   	push   %ebp
f0103d7c:	89 e5                	mov    %esp,%ebp
f0103d7e:	57                   	push   %edi
f0103d7f:	56                   	push   %esi
f0103d80:	53                   	push   %ebx
f0103d81:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103d84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103d87:	eb 03                	jmp    f0103d8c <strtol+0x11>
		s++;
f0103d89:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0103d8c:	0f b6 01             	movzbl (%ecx),%eax
f0103d8f:	3c 20                	cmp    $0x20,%al
f0103d91:	74 f6                	je     f0103d89 <strtol+0xe>
f0103d93:	3c 09                	cmp    $0x9,%al
f0103d95:	74 f2                	je     f0103d89 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0103d97:	3c 2b                	cmp    $0x2b,%al
f0103d99:	74 2e                	je     f0103dc9 <strtol+0x4e>
	int neg = 0;
f0103d9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103da0:	3c 2d                	cmp    $0x2d,%al
f0103da2:	74 2f                	je     f0103dd3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103da4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103daa:	75 05                	jne    f0103db1 <strtol+0x36>
f0103dac:	80 39 30             	cmpb   $0x30,(%ecx)
f0103daf:	74 2c                	je     f0103ddd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103db1:	85 db                	test   %ebx,%ebx
f0103db3:	75 0a                	jne    f0103dbf <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103db5:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0103dba:	80 39 30             	cmpb   $0x30,(%ecx)
f0103dbd:	74 28                	je     f0103de7 <strtol+0x6c>
		base = 10;
f0103dbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0103dc4:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103dc7:	eb 50                	jmp    f0103e19 <strtol+0x9e>
		s++;
f0103dc9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0103dcc:	bf 00 00 00 00       	mov    $0x0,%edi
f0103dd1:	eb d1                	jmp    f0103da4 <strtol+0x29>
		s++, neg = 1;
f0103dd3:	83 c1 01             	add    $0x1,%ecx
f0103dd6:	bf 01 00 00 00       	mov    $0x1,%edi
f0103ddb:	eb c7                	jmp    f0103da4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103ddd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103de1:	74 0e                	je     f0103df1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0103de3:	85 db                	test   %ebx,%ebx
f0103de5:	75 d8                	jne    f0103dbf <strtol+0x44>
		s++, base = 8;
f0103de7:	83 c1 01             	add    $0x1,%ecx
f0103dea:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103def:	eb ce                	jmp    f0103dbf <strtol+0x44>
		s += 2, base = 16;
f0103df1:	83 c1 02             	add    $0x2,%ecx
f0103df4:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103df9:	eb c4                	jmp    f0103dbf <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0103dfb:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103dfe:	89 f3                	mov    %esi,%ebx
f0103e00:	80 fb 19             	cmp    $0x19,%bl
f0103e03:	77 29                	ja     f0103e2e <strtol+0xb3>
			dig = *s - 'a' + 10;
f0103e05:	0f be d2             	movsbl %dl,%edx
f0103e08:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103e0b:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103e0e:	7d 30                	jge    f0103e40 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0103e10:	83 c1 01             	add    $0x1,%ecx
f0103e13:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103e17:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0103e19:	0f b6 11             	movzbl (%ecx),%edx
f0103e1c:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103e1f:	89 f3                	mov    %esi,%ebx
f0103e21:	80 fb 09             	cmp    $0x9,%bl
f0103e24:	77 d5                	ja     f0103dfb <strtol+0x80>
			dig = *s - '0';
f0103e26:	0f be d2             	movsbl %dl,%edx
f0103e29:	83 ea 30             	sub    $0x30,%edx
f0103e2c:	eb dd                	jmp    f0103e0b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0103e2e:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103e31:	89 f3                	mov    %esi,%ebx
f0103e33:	80 fb 19             	cmp    $0x19,%bl
f0103e36:	77 08                	ja     f0103e40 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0103e38:	0f be d2             	movsbl %dl,%edx
f0103e3b:	83 ea 37             	sub    $0x37,%edx
f0103e3e:	eb cb                	jmp    f0103e0b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103e40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103e44:	74 05                	je     f0103e4b <strtol+0xd0>
		*endptr = (char *) s;
f0103e46:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103e49:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103e4b:	89 c2                	mov    %eax,%edx
f0103e4d:	f7 da                	neg    %edx
f0103e4f:	85 ff                	test   %edi,%edi
f0103e51:	0f 45 c2             	cmovne %edx,%eax
}
f0103e54:	5b                   	pop    %ebx
f0103e55:	5e                   	pop    %esi
f0103e56:	5f                   	pop    %edi
f0103e57:	5d                   	pop    %ebp
f0103e58:	c3                   	ret    
f0103e59:	66 90                	xchg   %ax,%ax
f0103e5b:	66 90                	xchg   %ax,%ax
f0103e5d:	66 90                	xchg   %ax,%ax
f0103e5f:	90                   	nop

f0103e60 <__udivdi3>:
f0103e60:	55                   	push   %ebp
f0103e61:	57                   	push   %edi
f0103e62:	56                   	push   %esi
f0103e63:	53                   	push   %ebx
f0103e64:	83 ec 1c             	sub    $0x1c,%esp
f0103e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0103e6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103e73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103e77:	85 d2                	test   %edx,%edx
f0103e79:	75 35                	jne    f0103eb0 <__udivdi3+0x50>
f0103e7b:	39 f3                	cmp    %esi,%ebx
f0103e7d:	0f 87 bd 00 00 00    	ja     f0103f40 <__udivdi3+0xe0>
f0103e83:	85 db                	test   %ebx,%ebx
f0103e85:	89 d9                	mov    %ebx,%ecx
f0103e87:	75 0b                	jne    f0103e94 <__udivdi3+0x34>
f0103e89:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e8e:	31 d2                	xor    %edx,%edx
f0103e90:	f7 f3                	div    %ebx
f0103e92:	89 c1                	mov    %eax,%ecx
f0103e94:	31 d2                	xor    %edx,%edx
f0103e96:	89 f0                	mov    %esi,%eax
f0103e98:	f7 f1                	div    %ecx
f0103e9a:	89 c6                	mov    %eax,%esi
f0103e9c:	89 e8                	mov    %ebp,%eax
f0103e9e:	89 f7                	mov    %esi,%edi
f0103ea0:	f7 f1                	div    %ecx
f0103ea2:	89 fa                	mov    %edi,%edx
f0103ea4:	83 c4 1c             	add    $0x1c,%esp
f0103ea7:	5b                   	pop    %ebx
f0103ea8:	5e                   	pop    %esi
f0103ea9:	5f                   	pop    %edi
f0103eaa:	5d                   	pop    %ebp
f0103eab:	c3                   	ret    
f0103eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103eb0:	39 f2                	cmp    %esi,%edx
f0103eb2:	77 7c                	ja     f0103f30 <__udivdi3+0xd0>
f0103eb4:	0f bd fa             	bsr    %edx,%edi
f0103eb7:	83 f7 1f             	xor    $0x1f,%edi
f0103eba:	0f 84 98 00 00 00    	je     f0103f58 <__udivdi3+0xf8>
f0103ec0:	89 f9                	mov    %edi,%ecx
f0103ec2:	b8 20 00 00 00       	mov    $0x20,%eax
f0103ec7:	29 f8                	sub    %edi,%eax
f0103ec9:	d3 e2                	shl    %cl,%edx
f0103ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103ecf:	89 c1                	mov    %eax,%ecx
f0103ed1:	89 da                	mov    %ebx,%edx
f0103ed3:	d3 ea                	shr    %cl,%edx
f0103ed5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103ed9:	09 d1                	or     %edx,%ecx
f0103edb:	89 f2                	mov    %esi,%edx
f0103edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103ee1:	89 f9                	mov    %edi,%ecx
f0103ee3:	d3 e3                	shl    %cl,%ebx
f0103ee5:	89 c1                	mov    %eax,%ecx
f0103ee7:	d3 ea                	shr    %cl,%edx
f0103ee9:	89 f9                	mov    %edi,%ecx
f0103eeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103eef:	d3 e6                	shl    %cl,%esi
f0103ef1:	89 eb                	mov    %ebp,%ebx
f0103ef3:	89 c1                	mov    %eax,%ecx
f0103ef5:	d3 eb                	shr    %cl,%ebx
f0103ef7:	09 de                	or     %ebx,%esi
f0103ef9:	89 f0                	mov    %esi,%eax
f0103efb:	f7 74 24 08          	divl   0x8(%esp)
f0103eff:	89 d6                	mov    %edx,%esi
f0103f01:	89 c3                	mov    %eax,%ebx
f0103f03:	f7 64 24 0c          	mull   0xc(%esp)
f0103f07:	39 d6                	cmp    %edx,%esi
f0103f09:	72 0c                	jb     f0103f17 <__udivdi3+0xb7>
f0103f0b:	89 f9                	mov    %edi,%ecx
f0103f0d:	d3 e5                	shl    %cl,%ebp
f0103f0f:	39 c5                	cmp    %eax,%ebp
f0103f11:	73 5d                	jae    f0103f70 <__udivdi3+0x110>
f0103f13:	39 d6                	cmp    %edx,%esi
f0103f15:	75 59                	jne    f0103f70 <__udivdi3+0x110>
f0103f17:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0103f1a:	31 ff                	xor    %edi,%edi
f0103f1c:	89 fa                	mov    %edi,%edx
f0103f1e:	83 c4 1c             	add    $0x1c,%esp
f0103f21:	5b                   	pop    %ebx
f0103f22:	5e                   	pop    %esi
f0103f23:	5f                   	pop    %edi
f0103f24:	5d                   	pop    %ebp
f0103f25:	c3                   	ret    
f0103f26:	8d 76 00             	lea    0x0(%esi),%esi
f0103f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0103f30:	31 ff                	xor    %edi,%edi
f0103f32:	31 c0                	xor    %eax,%eax
f0103f34:	89 fa                	mov    %edi,%edx
f0103f36:	83 c4 1c             	add    $0x1c,%esp
f0103f39:	5b                   	pop    %ebx
f0103f3a:	5e                   	pop    %esi
f0103f3b:	5f                   	pop    %edi
f0103f3c:	5d                   	pop    %ebp
f0103f3d:	c3                   	ret    
f0103f3e:	66 90                	xchg   %ax,%ax
f0103f40:	31 ff                	xor    %edi,%edi
f0103f42:	89 e8                	mov    %ebp,%eax
f0103f44:	89 f2                	mov    %esi,%edx
f0103f46:	f7 f3                	div    %ebx
f0103f48:	89 fa                	mov    %edi,%edx
f0103f4a:	83 c4 1c             	add    $0x1c,%esp
f0103f4d:	5b                   	pop    %ebx
f0103f4e:	5e                   	pop    %esi
f0103f4f:	5f                   	pop    %edi
f0103f50:	5d                   	pop    %ebp
f0103f51:	c3                   	ret    
f0103f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103f58:	39 f2                	cmp    %esi,%edx
f0103f5a:	72 06                	jb     f0103f62 <__udivdi3+0x102>
f0103f5c:	31 c0                	xor    %eax,%eax
f0103f5e:	39 eb                	cmp    %ebp,%ebx
f0103f60:	77 d2                	ja     f0103f34 <__udivdi3+0xd4>
f0103f62:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f67:	eb cb                	jmp    f0103f34 <__udivdi3+0xd4>
f0103f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103f70:	89 d8                	mov    %ebx,%eax
f0103f72:	31 ff                	xor    %edi,%edi
f0103f74:	eb be                	jmp    f0103f34 <__udivdi3+0xd4>
f0103f76:	66 90                	xchg   %ax,%ax
f0103f78:	66 90                	xchg   %ax,%ax
f0103f7a:	66 90                	xchg   %ax,%ax
f0103f7c:	66 90                	xchg   %ax,%ax
f0103f7e:	66 90                	xchg   %ax,%ax

f0103f80 <__umoddi3>:
f0103f80:	55                   	push   %ebp
f0103f81:	57                   	push   %edi
f0103f82:	56                   	push   %esi
f0103f83:	53                   	push   %ebx
f0103f84:	83 ec 1c             	sub    $0x1c,%esp
f0103f87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0103f8b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103f8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103f97:	85 ed                	test   %ebp,%ebp
f0103f99:	89 f0                	mov    %esi,%eax
f0103f9b:	89 da                	mov    %ebx,%edx
f0103f9d:	75 19                	jne    f0103fb8 <__umoddi3+0x38>
f0103f9f:	39 df                	cmp    %ebx,%edi
f0103fa1:	0f 86 b1 00 00 00    	jbe    f0104058 <__umoddi3+0xd8>
f0103fa7:	f7 f7                	div    %edi
f0103fa9:	89 d0                	mov    %edx,%eax
f0103fab:	31 d2                	xor    %edx,%edx
f0103fad:	83 c4 1c             	add    $0x1c,%esp
f0103fb0:	5b                   	pop    %ebx
f0103fb1:	5e                   	pop    %esi
f0103fb2:	5f                   	pop    %edi
f0103fb3:	5d                   	pop    %ebp
f0103fb4:	c3                   	ret    
f0103fb5:	8d 76 00             	lea    0x0(%esi),%esi
f0103fb8:	39 dd                	cmp    %ebx,%ebp
f0103fba:	77 f1                	ja     f0103fad <__umoddi3+0x2d>
f0103fbc:	0f bd cd             	bsr    %ebp,%ecx
f0103fbf:	83 f1 1f             	xor    $0x1f,%ecx
f0103fc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103fc6:	0f 84 b4 00 00 00    	je     f0104080 <__umoddi3+0x100>
f0103fcc:	b8 20 00 00 00       	mov    $0x20,%eax
f0103fd1:	89 c2                	mov    %eax,%edx
f0103fd3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103fd7:	29 c2                	sub    %eax,%edx
f0103fd9:	89 c1                	mov    %eax,%ecx
f0103fdb:	89 f8                	mov    %edi,%eax
f0103fdd:	d3 e5                	shl    %cl,%ebp
f0103fdf:	89 d1                	mov    %edx,%ecx
f0103fe1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103fe5:	d3 e8                	shr    %cl,%eax
f0103fe7:	09 c5                	or     %eax,%ebp
f0103fe9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103fed:	89 c1                	mov    %eax,%ecx
f0103fef:	d3 e7                	shl    %cl,%edi
f0103ff1:	89 d1                	mov    %edx,%ecx
f0103ff3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103ff7:	89 df                	mov    %ebx,%edi
f0103ff9:	d3 ef                	shr    %cl,%edi
f0103ffb:	89 c1                	mov    %eax,%ecx
f0103ffd:	89 f0                	mov    %esi,%eax
f0103fff:	d3 e3                	shl    %cl,%ebx
f0104001:	89 d1                	mov    %edx,%ecx
f0104003:	89 fa                	mov    %edi,%edx
f0104005:	d3 e8                	shr    %cl,%eax
f0104007:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010400c:	09 d8                	or     %ebx,%eax
f010400e:	f7 f5                	div    %ebp
f0104010:	d3 e6                	shl    %cl,%esi
f0104012:	89 d1                	mov    %edx,%ecx
f0104014:	f7 64 24 08          	mull   0x8(%esp)
f0104018:	39 d1                	cmp    %edx,%ecx
f010401a:	89 c3                	mov    %eax,%ebx
f010401c:	89 d7                	mov    %edx,%edi
f010401e:	72 06                	jb     f0104026 <__umoddi3+0xa6>
f0104020:	75 0e                	jne    f0104030 <__umoddi3+0xb0>
f0104022:	39 c6                	cmp    %eax,%esi
f0104024:	73 0a                	jae    f0104030 <__umoddi3+0xb0>
f0104026:	2b 44 24 08          	sub    0x8(%esp),%eax
f010402a:	19 ea                	sbb    %ebp,%edx
f010402c:	89 d7                	mov    %edx,%edi
f010402e:	89 c3                	mov    %eax,%ebx
f0104030:	89 ca                	mov    %ecx,%edx
f0104032:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0104037:	29 de                	sub    %ebx,%esi
f0104039:	19 fa                	sbb    %edi,%edx
f010403b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010403f:	89 d0                	mov    %edx,%eax
f0104041:	d3 e0                	shl    %cl,%eax
f0104043:	89 d9                	mov    %ebx,%ecx
f0104045:	d3 ee                	shr    %cl,%esi
f0104047:	d3 ea                	shr    %cl,%edx
f0104049:	09 f0                	or     %esi,%eax
f010404b:	83 c4 1c             	add    $0x1c,%esp
f010404e:	5b                   	pop    %ebx
f010404f:	5e                   	pop    %esi
f0104050:	5f                   	pop    %edi
f0104051:	5d                   	pop    %ebp
f0104052:	c3                   	ret    
f0104053:	90                   	nop
f0104054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104058:	85 ff                	test   %edi,%edi
f010405a:	89 f9                	mov    %edi,%ecx
f010405c:	75 0b                	jne    f0104069 <__umoddi3+0xe9>
f010405e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104063:	31 d2                	xor    %edx,%edx
f0104065:	f7 f7                	div    %edi
f0104067:	89 c1                	mov    %eax,%ecx
f0104069:	89 d8                	mov    %ebx,%eax
f010406b:	31 d2                	xor    %edx,%edx
f010406d:	f7 f1                	div    %ecx
f010406f:	89 f0                	mov    %esi,%eax
f0104071:	f7 f1                	div    %ecx
f0104073:	e9 31 ff ff ff       	jmp    f0103fa9 <__umoddi3+0x29>
f0104078:	90                   	nop
f0104079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104080:	39 dd                	cmp    %ebx,%ebp
f0104082:	72 08                	jb     f010408c <__umoddi3+0x10c>
f0104084:	39 f7                	cmp    %esi,%edi
f0104086:	0f 87 21 ff ff ff    	ja     f0103fad <__umoddi3+0x2d>
f010408c:	89 da                	mov    %ebx,%edx
f010408e:	89 f0                	mov    %esi,%eax
f0104090:	29 f8                	sub    %edi,%eax
f0104092:	19 ea                	sbb    %ebp,%edx
f0104094:	e9 14 ff ff ff       	jmp    f0103fad <__umoddi3+0x2d>
