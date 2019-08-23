
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
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 78 09 ff ff    	lea    -0xf688(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 96 0b 00 00       	call   f0100bf9 <cprintf>
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
f0100073:	e8 bc 08 00 00       	call   f0100934 <backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 94 09 ff ff    	lea    -0xf66c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 6e 0b 00 00       	call   f0100bf9 <cprintf>
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
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 63 17 00 00       	call   f0101832 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 4f 05 00 00       	call   f0100623 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 af 09 ff ff    	lea    -0xf651(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 11 0b 00 00       	call   f0100bf9 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 09 09 00 00       	call   f0100a0a <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 d8 08 00 00       	call   f0100a0a <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 ca 09 ff ff    	lea    -0xf636(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 a6 0a 00 00       	call   f0100bf9 <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 65 0a 00 00       	call   f0100bc2 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 06 0a ff ff    	lea    -0xf5fa(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 8e 0a 00 00       	call   f0100bf9 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 e2 09 ff ff    	lea    -0xf61e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 61 0a 00 00       	call   f0100bf9 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 1e 0a 00 00       	call   f0100bc2 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 06 0a ff ff    	lea    -0xf5fa(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 47 0a 00 00       	call   f0100bf9 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 06 01 00 00    	je     f010034e <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100248:	a8 20                	test   $0x20,%al
f010024a:	0f 85 05 01 00 00    	jne    f0100355 <kbd_proc_data+0x12b>
f0100250:	ba 60 00 00 00       	mov    $0x60,%edx
f0100255:	ec                   	in     (%dx),%al
f0100256:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100258:	3c e0                	cmp    $0xe0,%al
f010025a:	0f 84 93 00 00 00    	je     f01002f3 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100260:	84 c0                	test   %al,%al
f0100262:	0f 88 a0 00 00 00    	js     f0100308 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100268:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 38 0b ff 	movzbl -0xf4c8(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 38 0a ff 	movzbl -0xf5c8(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ae:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b5:	a8 08                	test   $0x8,%al
f01002b7:	74 0d                	je     f01002c6 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002be:	83 f9 19             	cmp    $0x19,%ecx
f01002c1:	77 7a                	ja     f010033d <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002c3:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 33                	jne    f01002ff <kbd_proc_data+0xd5>
f01002cc:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002d2:	75 2b                	jne    f01002ff <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	8d 83 fc 09 ff ff    	lea    -0xf604(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 16 09 00 00       	call   f0100bf9 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ed:	ee                   	out    %al,(%dx)
f01002ee:	83 c4 10             	add    $0x10,%esp
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002f3:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ff:	89 f0                	mov    %esi,%eax
f0100301:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100304:	5b                   	pop    %ebx
f0100305:	5e                   	pop    %esi
f0100306:	5d                   	pop    %ebp
f0100307:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100308:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 38 0b ff 	movzbl -0xf4c8(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100336:	be 00 00 00 00       	mov    $0x0,%esi
f010033b:	eb c2                	jmp    f01002ff <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f010033d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100340:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100343:	83 fa 1a             	cmp    $0x1a,%edx
f0100346:	0f 42 f1             	cmovb  %ecx,%esi
f0100349:	e9 78 ff ff ff       	jmp    f01002c6 <kbd_proc_data+0x9c>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb aa                	jmp    f01002ff <kbd_proc_data+0xd5>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb a3                	jmp    f01002ff <kbd_proc_data+0xd5>

f010035c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	57                   	push   %edi
f0100360:	56                   	push   %esi
f0100361:	53                   	push   %ebx
f0100362:	83 ec 1c             	sub    $0x1c,%esp
f0100365:	e8 52 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010036a:	81 c3 9e 0f 01 00    	add    $0x10f9e,%ebx
f0100370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100373:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 09                	jmp    f010038d <cons_putc+0x31>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
	     i++)
f010038a:	83 c6 01             	add    $0x1,%esi
f010038d:	89 fa                	mov    %edi,%edx
f010038f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100390:	a8 20                	test   $0x20,%al
f0100392:	75 08                	jne    f010039c <cons_putc+0x40>
f0100394:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039a:	7e e8                	jle    f0100384 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039f:	89 f8                	mov    %edi,%eax
f01003a1:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	bf 79 03 00 00       	mov    $0x379,%edi
f01003b4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b9:	eb 09                	jmp    f01003c4 <cons_putc+0x68>
f01003bb:	89 ca                	mov    %ecx,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	83 c6 01             	add    $0x1,%esi
f01003c4:	89 fa                	mov    %edi,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 04                	jg     f01003d3 <cons_putc+0x77>
f01003cf:	84 c0                	test   %al,%al
f01003d1:	79 e8                	jns    f01003bb <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ed:	ee                   	out    %al,(%dx)
	if(!csa) csa = 0x0700;
f01003ee:	c7 c0 a8 36 11 f0    	mov    $0xf01136a8,%eax
f01003f4:	83 38 00             	cmpl   $0x0,(%eax)
f01003f7:	75 06                	jne    f01003ff <cons_putc+0xa3>
f01003f9:	c7 00 00 07 00 00    	movl   $0x700,(%eax)
	if (!(c & ~0xFF))
f01003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100402:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100408:	75 0d                	jne    f0100417 <cons_putc+0xbb>
		c |= csa;
f010040a:	c7 c0 a8 36 11 f0    	mov    $0xf01136a8,%eax
f0100410:	8b 00                	mov    (%eax),%eax
f0100412:	09 c7                	or     %eax,%edi
f0100414:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	switch (c & 0xff) {
f0100417:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f010041b:	83 f8 09             	cmp    $0x9,%eax
f010041e:	0f 84 b9 00 00 00    	je     f01004dd <cons_putc+0x181>
f0100424:	83 f8 09             	cmp    $0x9,%eax
f0100427:	7e 74                	jle    f010049d <cons_putc+0x141>
f0100429:	83 f8 0a             	cmp    $0xa,%eax
f010042c:	0f 84 9e 00 00 00    	je     f01004d0 <cons_putc+0x174>
f0100432:	83 f8 0d             	cmp    $0xd,%eax
f0100435:	0f 85 d9 00 00 00    	jne    f0100514 <cons_putc+0x1b8>
		crt_pos -= (crt_pos % CRT_COLS);
f010043b:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100442:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100448:	c1 e8 16             	shr    $0x16,%eax
f010044b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010044e:	c1 e0 04             	shl    $0x4,%eax
f0100451:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100458:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010045f:	cf 07 
f0100461:	0f 87 d4 00 00 00    	ja     f010053b <cons_putc+0x1df>
	outb(addr_6845, 14);
f0100467:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010046d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100472:	89 ca                	mov    %ecx,%edx
f0100474:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100475:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010047c:	8d 71 01             	lea    0x1(%ecx),%esi
f010047f:	89 d8                	mov    %ebx,%eax
f0100481:	66 c1 e8 08          	shr    $0x8,%ax
f0100485:	89 f2                	mov    %esi,%edx
f0100487:	ee                   	out    %al,(%dx)
f0100488:	b8 0f 00 00 00       	mov    $0xf,%eax
f010048d:	89 ca                	mov    %ecx,%edx
f010048f:	ee                   	out    %al,(%dx)
f0100490:	89 d8                	mov    %ebx,%eax
f0100492:	89 f2                	mov    %esi,%edx
f0100494:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100495:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100498:	5b                   	pop    %ebx
f0100499:	5e                   	pop    %esi
f010049a:	5f                   	pop    %edi
f010049b:	5d                   	pop    %ebp
f010049c:	c3                   	ret    
	switch (c & 0xff) {
f010049d:	83 f8 08             	cmp    $0x8,%eax
f01004a0:	75 72                	jne    f0100514 <cons_putc+0x1b8>
		if (crt_pos > 0) {
f01004a2:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004a9:	66 85 c0             	test   %ax,%ax
f01004ac:	74 b9                	je     f0100467 <cons_putc+0x10b>
			crt_pos--;
f01004ae:	83 e8 01             	sub    $0x1,%eax
f01004b1:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b8:	0f b7 c0             	movzwl %ax,%eax
f01004bb:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004bf:	b2 00                	mov    $0x0,%dl
f01004c1:	83 ca 20             	or     $0x20,%edx
f01004c4:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004ca:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004ce:	eb 88                	jmp    f0100458 <cons_putc+0xfc>
		crt_pos += CRT_COLS;
f01004d0:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004d7:	50 
f01004d8:	e9 5e ff ff ff       	jmp    f010043b <cons_putc+0xdf>
		cons_putc(' ');
f01004dd:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e2:	e8 75 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ec:	e8 6b fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f6:	e8 61 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004fb:	b8 20 00 00 00       	mov    $0x20,%eax
f0100500:	e8 57 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f0100505:	b8 20 00 00 00       	mov    $0x20,%eax
f010050a:	e8 4d fe ff ff       	call   f010035c <cons_putc>
f010050f:	e9 44 ff ff ff       	jmp    f0100458 <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100514:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010051b:	8d 50 01             	lea    0x1(%eax),%edx
f010051e:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100525:	0f b7 c0             	movzwl %ax,%eax
f0100528:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010052e:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100532:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100536:	e9 1d ff ff ff       	jmp    f0100458 <cons_putc+0xfc>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010053b:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f0100541:	83 ec 04             	sub    $0x4,%esp
f0100544:	68 00 0f 00 00       	push   $0xf00
f0100549:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010054f:	52                   	push   %edx
f0100550:	50                   	push   %eax
f0100551:	e8 29 13 00 00       	call   f010187f <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100556:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010055c:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100562:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100568:	83 c4 10             	add    $0x10,%esp
f010056b:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100570:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100573:	39 d0                	cmp    %edx,%eax
f0100575:	75 f4                	jne    f010056b <cons_putc+0x20f>
		crt_pos -= CRT_COLS;
f0100577:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010057e:	50 
f010057f:	e9 e3 fe ff ff       	jmp    f0100467 <cons_putc+0x10b>

f0100584 <serial_intr>:
{
f0100584:	e8 e7 01 00 00       	call   f0100770 <__x86.get_pc_thunk.ax>
f0100589:	05 7f 0d 01 00       	add    $0x10d7f,%eax
	if (serial_exists)
f010058e:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100595:	75 02                	jne    f0100599 <serial_intr+0x15>
f0100597:	f3 c3                	repz ret 
{
f0100599:	55                   	push   %ebp
f010059a:	89 e5                	mov    %esp,%ebp
f010059c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010059f:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f01005a5:	e8 35 fc ff ff       	call   f01001df <cons_intr>
}
f01005aa:	c9                   	leave  
f01005ab:	c3                   	ret    

f01005ac <kbd_intr>:
{
f01005ac:	55                   	push   %ebp
f01005ad:	89 e5                	mov    %esp,%ebp
f01005af:	83 ec 08             	sub    $0x8,%esp
f01005b2:	e8 b9 01 00 00       	call   f0100770 <__x86.get_pc_thunk.ax>
f01005b7:	05 51 0d 01 00       	add    $0x10d51,%eax
	cons_intr(kbd_proc_data);
f01005bc:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005c2:	e8 18 fc ff ff       	call   f01001df <cons_intr>
}
f01005c7:	c9                   	leave  
f01005c8:	c3                   	ret    

f01005c9 <cons_getc>:
{
f01005c9:	55                   	push   %ebp
f01005ca:	89 e5                	mov    %esp,%ebp
f01005cc:	53                   	push   %ebx
f01005cd:	83 ec 04             	sub    $0x4,%esp
f01005d0:	e8 e7 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005d5:	81 c3 33 0d 01 00    	add    $0x10d33,%ebx
	serial_intr();
f01005db:	e8 a4 ff ff ff       	call   f0100584 <serial_intr>
	kbd_intr();
f01005e0:	e8 c7 ff ff ff       	call   f01005ac <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005e5:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005eb:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005f0:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005f6:	74 19                	je     f0100611 <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005f8:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005fb:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f0100601:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f0100608:	00 
		if (cons.rpos == CONSBUFSIZE)
f0100609:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010060f:	74 06                	je     f0100617 <cons_getc+0x4e>
}
f0100611:	83 c4 04             	add    $0x4,%esp
f0100614:	5b                   	pop    %ebx
f0100615:	5d                   	pop    %ebp
f0100616:	c3                   	ret    
			cons.rpos = 0;
f0100617:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010061e:	00 00 00 
f0100621:	eb ee                	jmp    f0100611 <cons_getc+0x48>

f0100623 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100623:	55                   	push   %ebp
f0100624:	89 e5                	mov    %esp,%ebp
f0100626:	57                   	push   %edi
f0100627:	56                   	push   %esi
f0100628:	53                   	push   %ebx
f0100629:	83 ec 1c             	sub    $0x1c,%esp
f010062c:	e8 8b fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100631:	81 c3 d7 0c 01 00    	add    $0x10cd7,%ebx
	was = *cp;
f0100637:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010063e:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100645:	5a a5 
	if (*cp != 0xA55A) {
f0100647:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010064e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100652:	0f 84 bc 00 00 00    	je     f0100714 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100658:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010065f:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100662:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100669:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010066f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100674:	89 fa                	mov    %edi,%edx
f0100676:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100677:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010067a:	89 ca                	mov    %ecx,%edx
f010067c:	ec                   	in     (%dx),%al
f010067d:	0f b6 f0             	movzbl %al,%esi
f0100680:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100683:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100688:	89 fa                	mov    %edi,%edx
f010068a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010068b:	89 ca                	mov    %ecx,%edx
f010068d:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100691:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100697:	0f b6 c0             	movzbl %al,%eax
f010069a:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010069c:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006a8:	89 c8                	mov    %ecx,%eax
f01006aa:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006af:	ee                   	out    %al,(%dx)
f01006b0:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006b5:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006ba:	89 fa                	mov    %edi,%edx
f01006bc:	ee                   	out    %al,(%dx)
f01006bd:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006c2:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	89 f2                	mov    %esi,%edx
f01006d1:	ee                   	out    %al,(%dx)
f01006d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01006d7:	89 fa                	mov    %edi,%edx
f01006d9:	ee                   	out    %al,(%dx)
f01006da:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006df:	89 c8                	mov    %ecx,%eax
f01006e1:	ee                   	out    %al,(%dx)
f01006e2:	b8 01 00 00 00       	mov    $0x1,%eax
f01006e7:	89 f2                	mov    %esi,%edx
f01006e9:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ea:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006ef:	ec                   	in     (%dx),%al
f01006f0:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006f2:	3c ff                	cmp    $0xff,%al
f01006f4:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006fb:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100700:	ec                   	in     (%dx),%al
f0100701:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100706:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100707:	80 f9 ff             	cmp    $0xff,%cl
f010070a:	74 25                	je     f0100731 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f010070c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010070f:	5b                   	pop    %ebx
f0100710:	5e                   	pop    %esi
f0100711:	5f                   	pop    %edi
f0100712:	5d                   	pop    %ebp
f0100713:	c3                   	ret    
		*cp = was;
f0100714:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010071b:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100722:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100725:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010072c:	e9 38 ff ff ff       	jmp    f0100669 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f0100731:	83 ec 0c             	sub    $0xc,%esp
f0100734:	8d 83 08 0a ff ff    	lea    -0xf5f8(%ebx),%eax
f010073a:	50                   	push   %eax
f010073b:	e8 b9 04 00 00       	call   f0100bf9 <cprintf>
f0100740:	83 c4 10             	add    $0x10,%esp
}
f0100743:	eb c7                	jmp    f010070c <cons_init+0xe9>

f0100745 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100745:	55                   	push   %ebp
f0100746:	89 e5                	mov    %esp,%ebp
f0100748:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010074b:	8b 45 08             	mov    0x8(%ebp),%eax
f010074e:	e8 09 fc ff ff       	call   f010035c <cons_putc>
}
f0100753:	c9                   	leave  
f0100754:	c3                   	ret    

f0100755 <getchar>:

int
getchar(void)
{
f0100755:	55                   	push   %ebp
f0100756:	89 e5                	mov    %esp,%ebp
f0100758:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010075b:	e8 69 fe ff ff       	call   f01005c9 <cons_getc>
f0100760:	85 c0                	test   %eax,%eax
f0100762:	74 f7                	je     f010075b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100764:	c9                   	leave  
f0100765:	c3                   	ret    

f0100766 <iscons>:

int
iscons(int fdnum)
{
f0100766:	55                   	push   %ebp
f0100767:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100769:	b8 01 00 00 00       	mov    $0x1,%eax
f010076e:	5d                   	pop    %ebp
f010076f:	c3                   	ret    

f0100770 <__x86.get_pc_thunk.ax>:
f0100770:	8b 04 24             	mov    (%esp),%eax
f0100773:	c3                   	ret    

f0100774 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100774:	55                   	push   %ebp
f0100775:	89 e5                	mov    %esp,%ebp
f0100777:	56                   	push   %esi
f0100778:	53                   	push   %ebx
f0100779:	e8 3e fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010077e:	81 c3 8a 0b 01 00    	add    $0x10b8a,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100784:	83 ec 04             	sub    $0x4,%esp
f0100787:	8d 83 38 0c ff ff    	lea    -0xf3c8(%ebx),%eax
f010078d:	50                   	push   %eax
f010078e:	8d 83 56 0c ff ff    	lea    -0xf3aa(%ebx),%eax
f0100794:	50                   	push   %eax
f0100795:	8d b3 5b 0c ff ff    	lea    -0xf3a5(%ebx),%esi
f010079b:	56                   	push   %esi
f010079c:	e8 58 04 00 00       	call   f0100bf9 <cprintf>
f01007a1:	83 c4 0c             	add    $0xc,%esp
f01007a4:	8d 83 40 0d ff ff    	lea    -0xf2c0(%ebx),%eax
f01007aa:	50                   	push   %eax
f01007ab:	8d 83 64 0c ff ff    	lea    -0xf39c(%ebx),%eax
f01007b1:	50                   	push   %eax
f01007b2:	56                   	push   %esi
f01007b3:	e8 41 04 00 00       	call   f0100bf9 <cprintf>
	return 0;
}
f01007b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01007bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007c0:	5b                   	pop    %ebx
f01007c1:	5e                   	pop    %esi
f01007c2:	5d                   	pop    %ebp
f01007c3:	c3                   	ret    

f01007c4 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007c4:	55                   	push   %ebp
f01007c5:	89 e5                	mov    %esp,%ebp
f01007c7:	57                   	push   %edi
f01007c8:	56                   	push   %esi
f01007c9:	53                   	push   %ebx
f01007ca:	83 ec 18             	sub    $0x18,%esp
f01007cd:	e8 ea f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007d2:	81 c3 36 0b 01 00    	add    $0x10b36,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d8:	8d 83 6d 0c ff ff    	lea    -0xf393(%ebx),%eax
f01007de:	50                   	push   %eax
f01007df:	e8 15 04 00 00       	call   f0100bf9 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e4:	83 c4 08             	add    $0x8,%esp
f01007e7:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007ed:	8d 83 68 0d ff ff    	lea    -0xf298(%ebx),%eax
f01007f3:	50                   	push   %eax
f01007f4:	e8 00 04 00 00       	call   f0100bf9 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f9:	83 c4 0c             	add    $0xc,%esp
f01007fc:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100802:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100808:	50                   	push   %eax
f0100809:	57                   	push   %edi
f010080a:	8d 83 90 0d ff ff    	lea    -0xf270(%ebx),%eax
f0100810:	50                   	push   %eax
f0100811:	e8 e3 03 00 00       	call   f0100bf9 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100816:	83 c4 0c             	add    $0xc,%esp
f0100819:	c7 c0 69 1c 10 f0    	mov    $0xf0101c69,%eax
f010081f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100825:	52                   	push   %edx
f0100826:	50                   	push   %eax
f0100827:	8d 83 b4 0d ff ff    	lea    -0xf24c(%ebx),%eax
f010082d:	50                   	push   %eax
f010082e:	e8 c6 03 00 00       	call   f0100bf9 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100833:	83 c4 0c             	add    $0xc,%esp
f0100836:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010083c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100842:	52                   	push   %edx
f0100843:	50                   	push   %eax
f0100844:	8d 83 d8 0d ff ff    	lea    -0xf228(%ebx),%eax
f010084a:	50                   	push   %eax
f010084b:	e8 a9 03 00 00       	call   f0100bf9 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100850:	83 c4 0c             	add    $0xc,%esp
f0100853:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f0100859:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010085f:	50                   	push   %eax
f0100860:	56                   	push   %esi
f0100861:	8d 83 fc 0d ff ff    	lea    -0xf204(%ebx),%eax
f0100867:	50                   	push   %eax
f0100868:	e8 8c 03 00 00       	call   f0100bf9 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010086d:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100870:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100876:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100878:	c1 fe 0a             	sar    $0xa,%esi
f010087b:	56                   	push   %esi
f010087c:	8d 83 20 0e ff ff    	lea    -0xf1e0(%ebx),%eax
f0100882:	50                   	push   %eax
f0100883:	e8 71 03 00 00       	call   f0100bf9 <cprintf>
	return 0;
}
f0100888:	b8 00 00 00 00       	mov    $0x0,%eax
f010088d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100890:	5b                   	pop    %ebx
f0100891:	5e                   	pop    %esi
f0100892:	5f                   	pop    %edi
f0100893:	5d                   	pop    %ebp
f0100894:	c3                   	ret    

f0100895 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100895:	55                   	push   %ebp
f0100896:	89 e5                	mov    %esp,%ebp
f0100898:	57                   	push   %edi
f0100899:	56                   	push   %esi
f010089a:	53                   	push   %ebx
f010089b:	83 ec 28             	sub    $0x28,%esp
f010089e:	e8 19 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01008a3:	81 c3 65 0a 01 00    	add    $0x10a65,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008a9:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*) read_ebp();
f01008ab:	89 c7                	mov    %eax,%edi
	cprintf("Stack backtrace:\n");
f01008ad:	8d 83 86 0c ff ff    	lea    -0xf37a(%ebx),%eax
f01008b3:	50                   	push   %eax
f01008b4:	e8 40 03 00 00       	call   f0100bf9 <cprintf>
	while(ebp){
f01008b9:	83 c4 10             	add    $0x10,%esp
		cprintf("ebp %x  ebp %x  args", ebp, *(ebp+1));
f01008bc:	8d 83 98 0c ff ff    	lea    -0xf368(%ebx),%eax
f01008c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		cprintf(" %x", *(ebp+2));
f01008c5:	8d b3 ad 0c ff ff    	lea    -0xf353(%ebx),%esi
	while(ebp){
f01008cb:	eb 56                	jmp    f0100923 <mon_backtrace+0x8e>
		cprintf("ebp %x  ebp %x  args", ebp, *(ebp+1));
f01008cd:	83 ec 04             	sub    $0x4,%esp
f01008d0:	ff 77 04             	pushl  0x4(%edi)
f01008d3:	57                   	push   %edi
f01008d4:	ff 75 e4             	pushl  -0x1c(%ebp)
f01008d7:	e8 1d 03 00 00       	call   f0100bf9 <cprintf>
		cprintf(" %x", *(ebp+2));
f01008dc:	83 c4 08             	add    $0x8,%esp
f01008df:	ff 77 08             	pushl  0x8(%edi)
f01008e2:	56                   	push   %esi
f01008e3:	e8 11 03 00 00       	call   f0100bf9 <cprintf>
		cprintf(" %x", *(ebp+3));
f01008e8:	83 c4 08             	add    $0x8,%esp
f01008eb:	ff 77 0c             	pushl  0xc(%edi)
f01008ee:	56                   	push   %esi
f01008ef:	e8 05 03 00 00       	call   f0100bf9 <cprintf>
		cprintf(" %x", *(ebp+4));
f01008f4:	83 c4 08             	add    $0x8,%esp
f01008f7:	ff 77 10             	pushl  0x10(%edi)
f01008fa:	56                   	push   %esi
f01008fb:	e8 f9 02 00 00       	call   f0100bf9 <cprintf>
		cprintf(" %x", *(ebp+5));
f0100900:	83 c4 08             	add    $0x8,%esp
f0100903:	ff 77 14             	pushl  0x14(%edi)
f0100906:	56                   	push   %esi
f0100907:	e8 ed 02 00 00       	call   f0100bf9 <cprintf>
		cprintf(" %x\n", *(ebp+6));
f010090c:	83 c4 08             	add    $0x8,%esp
f010090f:	ff 77 18             	pushl  0x18(%edi)
f0100912:	8d 83 b1 0c ff ff    	lea    -0xf34f(%ebx),%eax
f0100918:	50                   	push   %eax
f0100919:	e8 db 02 00 00       	call   f0100bf9 <cprintf>
		ebp = (uint32_t*) *ebp;
f010091e:	8b 3f                	mov    (%edi),%edi
f0100920:	83 c4 10             	add    $0x10,%esp
	while(ebp){
f0100923:	85 ff                	test   %edi,%edi
f0100925:	75 a6                	jne    f01008cd <mon_backtrace+0x38>
	}
	// Your code here.
	return 0;
}
f0100927:	b8 00 00 00 00       	mov    $0x0,%eax
f010092c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010092f:	5b                   	pop    %ebx
f0100930:	5e                   	pop    %esi
f0100931:	5f                   	pop    %edi
f0100932:	5d                   	pop    %ebp
f0100933:	c3                   	ret    

f0100934 <backtrace>:

int backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100934:	55                   	push   %ebp
f0100935:	89 e5                	mov    %esp,%ebp
f0100937:	57                   	push   %edi
f0100938:	56                   	push   %esi
f0100939:	53                   	push   %ebx
f010093a:	83 ec 58             	sub    $0x58,%esp
f010093d:	e8 7a f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100942:	81 c3 c6 09 01 00    	add    $0x109c6,%ebx
f0100948:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp = (uint32_t*) read_ebp();
f010094a:	89 c7                	mov    %eax,%edi
	cprintf("Stack backtrace:\n");
f010094c:	8d 83 86 0c ff ff    	lea    -0xf37a(%ebx),%eax
f0100952:	50                   	push   %eax
f0100953:	e8 a1 02 00 00       	call   f0100bf9 <cprintf>
	while(ebp){
f0100958:	83 c4 10             	add    $0x10,%esp
		uint32_t eip = ebp[1];
		cprintf("ebp %x  eip %x  args", ebp, eip);
f010095b:	8d 83 b6 0c ff ff    	lea    -0xf34a(%ebx),%eax
f0100961:	89 45 b8             	mov    %eax,-0x48(%ebp)
		int i;
		for(i = 2; i <= 6; ++i)
			cprintf(" %08.x",ebp[i]);
f0100964:	8d 83 cb 0c ff ff    	lea    -0xf335(%ebx),%eax
f010096a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	while(ebp){
f010096d:	e9 83 00 00 00       	jmp    f01009f5 <backtrace+0xc1>
		uint32_t eip = ebp[1];
f0100972:	8b 47 04             	mov    0x4(%edi),%eax
f0100975:	89 45 c0             	mov    %eax,-0x40(%ebp)
		cprintf("ebp %x  eip %x  args", ebp, eip);
f0100978:	83 ec 04             	sub    $0x4,%esp
f010097b:	50                   	push   %eax
f010097c:	57                   	push   %edi
f010097d:	ff 75 b8             	pushl  -0x48(%ebp)
f0100980:	e8 74 02 00 00       	call   f0100bf9 <cprintf>
f0100985:	8d 77 08             	lea    0x8(%edi),%esi
f0100988:	8d 47 1c             	lea    0x1c(%edi),%eax
f010098b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010098e:	83 c4 10             	add    $0x10,%esp
f0100991:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0100994:	8b 7d b4             	mov    -0x4c(%ebp),%edi
			cprintf(" %08.x",ebp[i]);
f0100997:	83 ec 08             	sub    $0x8,%esp
f010099a:	ff 36                	pushl  (%esi)
f010099c:	57                   	push   %edi
f010099d:	e8 57 02 00 00       	call   f0100bf9 <cprintf>
f01009a2:	83 c6 04             	add    $0x4,%esi
		for(i = 2; i <= 6; ++i)
f01009a5:	83 c4 10             	add    $0x10,%esp
f01009a8:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f01009ab:	75 ea                	jne    f0100997 <backtrace+0x63>
f01009ad:	8b 7d bc             	mov    -0x44(%ebp),%edi
		cprintf("\n");
f01009b0:	83 ec 0c             	sub    $0xc,%esp
f01009b3:	8d 83 06 0a ff ff    	lea    -0xf5fa(%ebx),%eax
f01009b9:	50                   	push   %eax
f01009ba:	e8 3a 02 00 00       	call   f0100bf9 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f01009bf:	83 c4 08             	add    $0x8,%esp
f01009c2:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01009c5:	50                   	push   %eax
f01009c6:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01009c9:	56                   	push   %esi
f01009ca:	e8 2e 03 00 00       	call   f0100cfd <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n",
f01009cf:	83 c4 08             	add    $0x8,%esp
f01009d2:	89 f0                	mov    %esi,%eax
f01009d4:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01009d7:	50                   	push   %eax
f01009d8:	ff 75 d8             	pushl  -0x28(%ebp)
f01009db:	ff 75 dc             	pushl  -0x24(%ebp)
f01009de:	ff 75 d4             	pushl  -0x2c(%ebp)
f01009e1:	ff 75 d0             	pushl  -0x30(%ebp)
f01009e4:	8d 83 d2 0c ff ff    	lea    -0xf32e(%ebx),%eax
f01009ea:	50                   	push   %eax
f01009eb:	e8 09 02 00 00       	call   f0100bf9 <cprintf>
			info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
		ebp = (uint32_t*) *ebp	;
f01009f0:	8b 3f                	mov    (%edi),%edi
f01009f2:	83 c4 20             	add    $0x20,%esp
	while(ebp){
f01009f5:	85 ff                	test   %edi,%edi
f01009f7:	0f 85 75 ff ff ff    	jne    f0100972 <backtrace+0x3e>
	}
	return 0;
}
f01009fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a02:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a05:	5b                   	pop    %ebx
f0100a06:	5e                   	pop    %esi
f0100a07:	5f                   	pop    %edi
f0100a08:	5d                   	pop    %ebp
f0100a09:	c3                   	ret    

f0100a0a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100a0a:	55                   	push   %ebp
f0100a0b:	89 e5                	mov    %esp,%ebp
f0100a0d:	57                   	push   %edi
f0100a0e:	56                   	push   %esi
f0100a0f:	53                   	push   %ebx
f0100a10:	83 ec 68             	sub    $0x68,%esp
f0100a13:	e8 a4 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100a18:	81 c3 f0 08 01 00    	add    $0x108f0,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100a1e:	8d 83 4c 0e ff ff    	lea    -0xf1b4(%ebx),%eax
f0100a24:	50                   	push   %eax
f0100a25:	e8 cf 01 00 00       	call   f0100bf9 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a2a:	8d 83 70 0e ff ff    	lea    -0xf190(%ebx),%eax
f0100a30:	89 04 24             	mov    %eax,(%esp)
f0100a33:	e8 c1 01 00 00       	call   f0100bf9 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n",0x0100,"blue",0x0200,"green",0x0400,"red");
f0100a38:	83 c4 0c             	add    $0xc,%esp
f0100a3b:	8d 83 e3 0c ff ff    	lea    -0xf31d(%ebx),%eax
f0100a41:	50                   	push   %eax
f0100a42:	68 00 04 00 00       	push   $0x400
f0100a47:	8d 83 e7 0c ff ff    	lea    -0xf319(%ebx),%eax
f0100a4d:	50                   	push   %eax
f0100a4e:	68 00 02 00 00       	push   $0x200
f0100a53:	8d 83 ed 0c ff ff    	lea    -0xf313(%ebx),%eax
f0100a59:	50                   	push   %eax
f0100a5a:	68 00 01 00 00       	push   $0x100
f0100a5f:	8d 83 f2 0c ff ff    	lea    -0xf30e(%ebx),%eax
f0100a65:	50                   	push   %eax
f0100a66:	e8 8e 01 00 00       	call   f0100bf9 <cprintf>
f0100a6b:	83 c4 20             	add    $0x20,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100a6e:	8d bb 06 0d ff ff    	lea    -0xf2fa(%ebx),%edi
f0100a74:	eb 4a                	jmp    f0100ac0 <monitor+0xb6>
f0100a76:	83 ec 08             	sub    $0x8,%esp
f0100a79:	0f be c0             	movsbl %al,%eax
f0100a7c:	50                   	push   %eax
f0100a7d:	57                   	push   %edi
f0100a7e:	e8 72 0d 00 00       	call   f01017f5 <strchr>
f0100a83:	83 c4 10             	add    $0x10,%esp
f0100a86:	85 c0                	test   %eax,%eax
f0100a88:	74 08                	je     f0100a92 <monitor+0x88>
			*buf++ = 0;
f0100a8a:	c6 06 00             	movb   $0x0,(%esi)
f0100a8d:	8d 76 01             	lea    0x1(%esi),%esi
f0100a90:	eb 79                	jmp    f0100b0b <monitor+0x101>
		if (*buf == 0)
f0100a92:	80 3e 00             	cmpb   $0x0,(%esi)
f0100a95:	74 7f                	je     f0100b16 <monitor+0x10c>
		if (argc == MAXARGS-1) {
f0100a97:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100a9b:	74 0f                	je     f0100aac <monitor+0xa2>
		argv[argc++] = buf;
f0100a9d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100aa0:	8d 48 01             	lea    0x1(%eax),%ecx
f0100aa3:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100aa6:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100aaa:	eb 44                	jmp    f0100af0 <monitor+0xe6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100aac:	83 ec 08             	sub    $0x8,%esp
f0100aaf:	6a 10                	push   $0x10
f0100ab1:	8d 83 0b 0d ff ff    	lea    -0xf2f5(%ebx),%eax
f0100ab7:	50                   	push   %eax
f0100ab8:	e8 3c 01 00 00       	call   f0100bf9 <cprintf>
f0100abd:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ac0:	8d 83 02 0d ff ff    	lea    -0xf2fe(%ebx),%eax
f0100ac6:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100ac9:	83 ec 0c             	sub    $0xc,%esp
f0100acc:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100acf:	e8 e9 0a 00 00       	call   f01015bd <readline>
f0100ad4:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100ad6:	83 c4 10             	add    $0x10,%esp
f0100ad9:	85 c0                	test   %eax,%eax
f0100adb:	74 ec                	je     f0100ac9 <monitor+0xbf>
	argv[argc] = 0;
f0100add:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100ae4:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100aeb:	eb 1e                	jmp    f0100b0b <monitor+0x101>
			buf++;
f0100aed:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100af0:	0f b6 06             	movzbl (%esi),%eax
f0100af3:	84 c0                	test   %al,%al
f0100af5:	74 14                	je     f0100b0b <monitor+0x101>
f0100af7:	83 ec 08             	sub    $0x8,%esp
f0100afa:	0f be c0             	movsbl %al,%eax
f0100afd:	50                   	push   %eax
f0100afe:	57                   	push   %edi
f0100aff:	e8 f1 0c 00 00       	call   f01017f5 <strchr>
f0100b04:	83 c4 10             	add    $0x10,%esp
f0100b07:	85 c0                	test   %eax,%eax
f0100b09:	74 e2                	je     f0100aed <monitor+0xe3>
		while (*buf && strchr(WHITESPACE, *buf))
f0100b0b:	0f b6 06             	movzbl (%esi),%eax
f0100b0e:	84 c0                	test   %al,%al
f0100b10:	0f 85 60 ff ff ff    	jne    f0100a76 <monitor+0x6c>
	argv[argc] = 0;
f0100b16:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100b19:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100b20:	00 
	if (argc == 0)
f0100b21:	85 c0                	test   %eax,%eax
f0100b23:	74 9b                	je     f0100ac0 <monitor+0xb6>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b25:	83 ec 08             	sub    $0x8,%esp
f0100b28:	8d 83 56 0c ff ff    	lea    -0xf3aa(%ebx),%eax
f0100b2e:	50                   	push   %eax
f0100b2f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b32:	e8 60 0c 00 00       	call   f0101797 <strcmp>
f0100b37:	83 c4 10             	add    $0x10,%esp
f0100b3a:	85 c0                	test   %eax,%eax
f0100b3c:	74 38                	je     f0100b76 <monitor+0x16c>
f0100b3e:	83 ec 08             	sub    $0x8,%esp
f0100b41:	8d 83 64 0c ff ff    	lea    -0xf39c(%ebx),%eax
f0100b47:	50                   	push   %eax
f0100b48:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b4b:	e8 47 0c 00 00       	call   f0101797 <strcmp>
f0100b50:	83 c4 10             	add    $0x10,%esp
f0100b53:	85 c0                	test   %eax,%eax
f0100b55:	74 1a                	je     f0100b71 <monitor+0x167>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b57:	83 ec 08             	sub    $0x8,%esp
f0100b5a:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b5d:	8d 83 28 0d ff ff    	lea    -0xf2d8(%ebx),%eax
f0100b63:	50                   	push   %eax
f0100b64:	e8 90 00 00 00       	call   f0100bf9 <cprintf>
f0100b69:	83 c4 10             	add    $0x10,%esp
f0100b6c:	e9 4f ff ff ff       	jmp    f0100ac0 <monitor+0xb6>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b71:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100b76:	83 ec 04             	sub    $0x4,%esp
f0100b79:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b7c:	ff 75 08             	pushl  0x8(%ebp)
f0100b7f:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b82:	52                   	push   %edx
f0100b83:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100b86:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100b8d:	83 c4 10             	add    $0x10,%esp
f0100b90:	85 c0                	test   %eax,%eax
f0100b92:	0f 89 28 ff ff ff    	jns    f0100ac0 <monitor+0xb6>
				break;
	}
}
f0100b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b9b:	5b                   	pop    %ebx
f0100b9c:	5e                   	pop    %esi
f0100b9d:	5f                   	pop    %edi
f0100b9e:	5d                   	pop    %ebp
f0100b9f:	c3                   	ret    

f0100ba0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100ba0:	55                   	push   %ebp
f0100ba1:	89 e5                	mov    %esp,%ebp
f0100ba3:	53                   	push   %ebx
f0100ba4:	83 ec 10             	sub    $0x10,%esp
f0100ba7:	e8 10 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100bac:	81 c3 5c 07 01 00    	add    $0x1075c,%ebx
	cputchar(ch);
f0100bb2:	ff 75 08             	pushl  0x8(%ebp)
f0100bb5:	e8 8b fb ff ff       	call   f0100745 <cputchar>
	*cnt++;
}
f0100bba:	83 c4 10             	add    $0x10,%esp
f0100bbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100bc0:	c9                   	leave  
f0100bc1:	c3                   	ret    

f0100bc2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100bc2:	55                   	push   %ebp
f0100bc3:	89 e5                	mov    %esp,%ebp
f0100bc5:	53                   	push   %ebx
f0100bc6:	83 ec 14             	sub    $0x14,%esp
f0100bc9:	e8 ee f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100bce:	81 c3 3a 07 01 00    	add    $0x1073a,%ebx
	int cnt = 0;
f0100bd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100bdb:	ff 75 0c             	pushl  0xc(%ebp)
f0100bde:	ff 75 08             	pushl  0x8(%ebp)
f0100be1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100be4:	50                   	push   %eax
f0100be5:	8d 83 98 f8 fe ff    	lea    -0x10768(%ebx),%eax
f0100beb:	50                   	push   %eax
f0100bec:	e8 98 04 00 00       	call   f0101089 <vprintfmt>
	return cnt;
}
f0100bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100bf4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100bf7:	c9                   	leave  
f0100bf8:	c3                   	ret    

f0100bf9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100bf9:	55                   	push   %ebp
f0100bfa:	89 e5                	mov    %esp,%ebp
f0100bfc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100bff:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100c02:	50                   	push   %eax
f0100c03:	ff 75 08             	pushl  0x8(%ebp)
f0100c06:	e8 b7 ff ff ff       	call   f0100bc2 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100c0b:	c9                   	leave  
f0100c0c:	c3                   	ret    

f0100c0d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100c0d:	55                   	push   %ebp
f0100c0e:	89 e5                	mov    %esp,%ebp
f0100c10:	57                   	push   %edi
f0100c11:	56                   	push   %esi
f0100c12:	53                   	push   %ebx
f0100c13:	83 ec 14             	sub    $0x14,%esp
f0100c16:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100c19:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100c1c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100c1f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100c22:	8b 32                	mov    (%edx),%esi
f0100c24:	8b 01                	mov    (%ecx),%eax
f0100c26:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c29:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
	
	while (l <= r) {
f0100c30:	eb 2f                	jmp    f0100c61 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100c32:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100c35:	39 c6                	cmp    %eax,%esi
f0100c37:	7f 49                	jg     f0100c82 <stab_binsearch+0x75>
f0100c39:	0f b6 0a             	movzbl (%edx),%ecx
f0100c3c:	83 ea 0c             	sub    $0xc,%edx
f0100c3f:	39 f9                	cmp    %edi,%ecx
f0100c41:	75 ef                	jne    f0100c32 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100c43:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c46:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c49:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100c4d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c50:	73 35                	jae    f0100c87 <stab_binsearch+0x7a>
			*region_left = m;
f0100c52:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c55:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100c57:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100c5a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100c61:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100c64:	7f 4e                	jg     f0100cb4 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c69:	01 f0                	add    %esi,%eax
f0100c6b:	89 c3                	mov    %eax,%ebx
f0100c6d:	c1 eb 1f             	shr    $0x1f,%ebx
f0100c70:	01 c3                	add    %eax,%ebx
f0100c72:	d1 fb                	sar    %ebx
f0100c74:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c77:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c7a:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100c7e:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100c80:	eb b3                	jmp    f0100c35 <stab_binsearch+0x28>
			l = true_m + 1;
f0100c82:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100c85:	eb da                	jmp    f0100c61 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100c87:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c8a:	76 14                	jbe    f0100ca0 <stab_binsearch+0x93>
			*region_right = m - 1;
f0100c8c:	83 e8 01             	sub    $0x1,%eax
f0100c8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c92:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100c95:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100c97:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c9e:	eb c1                	jmp    f0100c61 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100ca0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ca3:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100ca5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100ca9:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100cab:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100cb2:	eb ad                	jmp    f0100c61 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100cb4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100cb8:	74 16                	je     f0100cd0 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100cba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cbd:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100cbf:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100cc2:	8b 0e                	mov    (%esi),%ecx
f0100cc4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100cc7:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100cca:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100cce:	eb 12                	jmp    f0100ce2 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100cd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cd3:	8b 00                	mov    (%eax),%eax
f0100cd5:	83 e8 01             	sub    $0x1,%eax
f0100cd8:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100cdb:	89 07                	mov    %eax,(%edi)
f0100cdd:	eb 16                	jmp    f0100cf5 <stab_binsearch+0xe8>
		     l--)
f0100cdf:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100ce2:	39 c1                	cmp    %eax,%ecx
f0100ce4:	7d 0a                	jge    f0100cf0 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100ce6:	0f b6 1a             	movzbl (%edx),%ebx
f0100ce9:	83 ea 0c             	sub    $0xc,%edx
f0100cec:	39 fb                	cmp    %edi,%ebx
f0100cee:	75 ef                	jne    f0100cdf <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100cf0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100cf3:	89 07                	mov    %eax,(%edi)
	}
}
f0100cf5:	83 c4 14             	add    $0x14,%esp
f0100cf8:	5b                   	pop    %ebx
f0100cf9:	5e                   	pop    %esi
f0100cfa:	5f                   	pop    %edi
f0100cfb:	5d                   	pop    %ebp
f0100cfc:	c3                   	ret    

f0100cfd <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100cfd:	55                   	push   %ebp
f0100cfe:	89 e5                	mov    %esp,%ebp
f0100d00:	57                   	push   %edi
f0100d01:	56                   	push   %esi
f0100d02:	53                   	push   %ebx
f0100d03:	83 ec 3c             	sub    $0x3c,%esp
f0100d06:	e8 b1 f4 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100d0b:	81 c3 fd 05 01 00    	add    $0x105fd,%ebx
f0100d11:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100d14:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100d17:	8d 83 98 0e ff ff    	lea    -0xf168(%ebx),%eax
f0100d1d:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100d1f:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100d26:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100d29:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100d30:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100d33:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100d3a:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100d40:	0f 86 37 01 00 00    	jbe    f0100e7d <debuginfo_eip+0x180>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100d46:	c7 c0 c9 62 10 f0    	mov    $0xf01062c9,%eax
f0100d4c:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100d52:	0f 86 04 02 00 00    	jbe    f0100f5c <debuginfo_eip+0x25f>
f0100d58:	c7 c0 6e 7c 10 f0    	mov    $0xf0107c6e,%eax
f0100d5e:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100d62:	0f 85 fb 01 00 00    	jne    f0100f63 <debuginfo_eip+0x266>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100d68:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100d6f:	c7 c0 bc 23 10 f0    	mov    $0xf01023bc,%eax
f0100d75:	c7 c2 c8 62 10 f0    	mov    $0xf01062c8,%edx
f0100d7b:	29 c2                	sub    %eax,%edx
f0100d7d:	c1 fa 02             	sar    $0x2,%edx
f0100d80:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100d86:	83 ea 01             	sub    $0x1,%edx
f0100d89:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100d8c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100d8f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100d92:	83 ec 08             	sub    $0x8,%esp
f0100d95:	57                   	push   %edi
f0100d96:	6a 64                	push   $0x64
f0100d98:	e8 70 fe ff ff       	call   f0100c0d <stab_binsearch>
	if (lfile == 0)
f0100d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100da0:	83 c4 10             	add    $0x10,%esp
f0100da3:	85 c0                	test   %eax,%eax
f0100da5:	0f 84 bf 01 00 00    	je     f0100f6a <debuginfo_eip+0x26d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100dab:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100dae:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100db1:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100db4:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100db7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100dba:	83 ec 08             	sub    $0x8,%esp
f0100dbd:	57                   	push   %edi
f0100dbe:	6a 24                	push   $0x24
f0100dc0:	c7 c0 bc 23 10 f0    	mov    $0xf01023bc,%eax
f0100dc6:	e8 42 fe ff ff       	call   f0100c0d <stab_binsearch>

	if (lfun <= rfun) {
f0100dcb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100dce:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100dd1:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100dd4:	83 c4 10             	add    $0x10,%esp
f0100dd7:	39 c8                	cmp    %ecx,%eax
f0100dd9:	0f 8f b6 00 00 00    	jg     f0100e95 <debuginfo_eip+0x198>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ddf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100de2:	c7 c1 bc 23 10 f0    	mov    $0xf01023bc,%ecx
f0100de8:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100deb:	8b 11                	mov    (%ecx),%edx
f0100ded:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100df0:	c7 c2 6e 7c 10 f0    	mov    $0xf0107c6e,%edx
f0100df6:	81 ea c9 62 10 f0    	sub    $0xf01062c9,%edx
f0100dfc:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100dff:	73 0c                	jae    f0100e0d <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100e01:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100e04:	81 c2 c9 62 10 f0    	add    $0xf01062c9,%edx
f0100e0a:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100e0d:	8b 51 08             	mov    0x8(%ecx),%edx
f0100e10:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100e13:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100e15:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100e18:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100e1b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100e1e:	83 ec 08             	sub    $0x8,%esp
f0100e21:	6a 3a                	push   $0x3a
f0100e23:	ff 76 08             	pushl  0x8(%esi)
f0100e26:	e8 eb 09 00 00       	call   f0101816 <strfind>
f0100e2b:	2b 46 08             	sub    0x8(%esi),%eax
f0100e2e:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100e31:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100e34:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100e37:	83 c4 08             	add    $0x8,%esp
f0100e3a:	57                   	push   %edi
f0100e3b:	6a 44                	push   $0x44
f0100e3d:	c7 c0 bc 23 10 f0    	mov    $0xf01023bc,%eax
f0100e43:	e8 c5 fd ff ff       	call   f0100c0d <stab_binsearch>
	if(lline > rline)
f0100e48:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100e4b:	83 c4 10             	add    $0x10,%esp
f0100e4e:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100e51:	0f 8f 1a 01 00 00    	jg     f0100f71 <debuginfo_eip+0x274>
		return -1;
	else
		info->eip_line = stabs[lline].n_desc;
f0100e57:	89 d0                	mov    %edx,%eax
f0100e59:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100e5c:	c1 e2 02             	shl    $0x2,%edx
f0100e5f:	c7 c1 bc 23 10 f0    	mov    $0xf01023bc,%ecx
f0100e65:	0f b7 7c 0a 06       	movzwl 0x6(%edx,%ecx,1),%edi
f0100e6a:	89 7e 04             	mov    %edi,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e70:	8d 54 0a 04          	lea    0x4(%edx,%ecx,1),%edx
f0100e74:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0100e78:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100e7b:	eb 36                	jmp    f0100eb3 <debuginfo_eip+0x1b6>
  	        panic("User address");
f0100e7d:	83 ec 04             	sub    $0x4,%esp
f0100e80:	8d 83 a2 0e ff ff    	lea    -0xf15e(%ebx),%eax
f0100e86:	50                   	push   %eax
f0100e87:	6a 7f                	push   $0x7f
f0100e89:	8d 83 af 0e ff ff    	lea    -0xf151(%ebx),%eax
f0100e8f:	50                   	push   %eax
f0100e90:	e8 71 f2 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100e95:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e9b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100e9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ea1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ea4:	e9 75 ff ff ff       	jmp    f0100e1e <debuginfo_eip+0x121>
f0100ea9:	83 e8 01             	sub    $0x1,%eax
f0100eac:	83 ea 0c             	sub    $0xc,%edx
f0100eaf:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0100eb3:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0100eb6:	39 c7                	cmp    %eax,%edi
f0100eb8:	7f 24                	jg     f0100ede <debuginfo_eip+0x1e1>
	       && stabs[lline].n_type != N_SOL
f0100eba:	0f b6 0a             	movzbl (%edx),%ecx
f0100ebd:	80 f9 84             	cmp    $0x84,%cl
f0100ec0:	74 46                	je     f0100f08 <debuginfo_eip+0x20b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100ec2:	80 f9 64             	cmp    $0x64,%cl
f0100ec5:	75 e2                	jne    f0100ea9 <debuginfo_eip+0x1ac>
f0100ec7:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0100ecb:	74 dc                	je     f0100ea9 <debuginfo_eip+0x1ac>
f0100ecd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100ed0:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100ed4:	74 3b                	je     f0100f11 <debuginfo_eip+0x214>
f0100ed6:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100ed9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100edc:	eb 33                	jmp    f0100f11 <debuginfo_eip+0x214>
f0100ede:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100ee1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ee4:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100ee7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100eec:	39 fa                	cmp    %edi,%edx
f0100eee:	0f 8d 89 00 00 00    	jge    f0100f7d <debuginfo_eip+0x280>
		for (lline = lfun + 1;
f0100ef4:	83 c2 01             	add    $0x1,%edx
f0100ef7:	89 d0                	mov    %edx,%eax
f0100ef9:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100efc:	c7 c2 bc 23 10 f0    	mov    $0xf01023bc,%edx
f0100f02:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100f06:	eb 3b                	jmp    f0100f43 <debuginfo_eip+0x246>
f0100f08:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100f0b:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100f0f:	75 26                	jne    f0100f37 <debuginfo_eip+0x23a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100f11:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100f14:	c7 c0 bc 23 10 f0    	mov    $0xf01023bc,%eax
f0100f1a:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100f1d:	c7 c0 6e 7c 10 f0    	mov    $0xf0107c6e,%eax
f0100f23:	81 e8 c9 62 10 f0    	sub    $0xf01062c9,%eax
f0100f29:	39 c2                	cmp    %eax,%edx
f0100f2b:	73 b4                	jae    f0100ee1 <debuginfo_eip+0x1e4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100f2d:	81 c2 c9 62 10 f0    	add    $0xf01062c9,%edx
f0100f33:	89 16                	mov    %edx,(%esi)
f0100f35:	eb aa                	jmp    f0100ee1 <debuginfo_eip+0x1e4>
f0100f37:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100f3a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f3d:	eb d2                	jmp    f0100f11 <debuginfo_eip+0x214>
			info->eip_fn_narg++;
f0100f3f:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100f43:	39 c7                	cmp    %eax,%edi
f0100f45:	7e 31                	jle    f0100f78 <debuginfo_eip+0x27b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100f47:	0f b6 0a             	movzbl (%edx),%ecx
f0100f4a:	83 c0 01             	add    $0x1,%eax
f0100f4d:	83 c2 0c             	add    $0xc,%edx
f0100f50:	80 f9 a0             	cmp    $0xa0,%cl
f0100f53:	74 ea                	je     f0100f3f <debuginfo_eip+0x242>
	return 0;
f0100f55:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f5a:	eb 21                	jmp    f0100f7d <debuginfo_eip+0x280>
		return -1;
f0100f5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f61:	eb 1a                	jmp    f0100f7d <debuginfo_eip+0x280>
f0100f63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f68:	eb 13                	jmp    f0100f7d <debuginfo_eip+0x280>
		return -1;
f0100f6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f6f:	eb 0c                	jmp    f0100f7d <debuginfo_eip+0x280>
		return -1;
f0100f71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f76:	eb 05                	jmp    f0100f7d <debuginfo_eip+0x280>
	return 0;
f0100f78:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f80:	5b                   	pop    %ebx
f0100f81:	5e                   	pop    %esi
f0100f82:	5f                   	pop    %edi
f0100f83:	5d                   	pop    %ebp
f0100f84:	c3                   	ret    

f0100f85 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100f85:	55                   	push   %ebp
f0100f86:	89 e5                	mov    %esp,%ebp
f0100f88:	57                   	push   %edi
f0100f89:	56                   	push   %esi
f0100f8a:	53                   	push   %ebx
f0100f8b:	83 ec 2c             	sub    $0x2c,%esp
f0100f8e:	e8 26 06 00 00       	call   f01015b9 <__x86.get_pc_thunk.cx>
f0100f93:	81 c1 75 03 01 00    	add    $0x10375,%ecx
f0100f99:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100f9c:	89 c7                	mov    %eax,%edi
f0100f9e:	89 d6                	mov    %edx,%esi
f0100fa0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fa3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100fa6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100fa9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100fac:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100faf:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100fb4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100fb7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100fba:	39 d3                	cmp    %edx,%ebx
f0100fbc:	72 09                	jb     f0100fc7 <printnum+0x42>
f0100fbe:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100fc1:	0f 87 83 00 00 00    	ja     f010104a <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100fc7:	83 ec 0c             	sub    $0xc,%esp
f0100fca:	ff 75 18             	pushl  0x18(%ebp)
f0100fcd:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fd0:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100fd3:	53                   	push   %ebx
f0100fd4:	ff 75 10             	pushl  0x10(%ebp)
f0100fd7:	83 ec 08             	sub    $0x8,%esp
f0100fda:	ff 75 dc             	pushl  -0x24(%ebp)
f0100fdd:	ff 75 d8             	pushl  -0x28(%ebp)
f0100fe0:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100fe3:	ff 75 d0             	pushl  -0x30(%ebp)
f0100fe6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fe9:	e8 42 0a 00 00       	call   f0101a30 <__udivdi3>
f0100fee:	83 c4 18             	add    $0x18,%esp
f0100ff1:	52                   	push   %edx
f0100ff2:	50                   	push   %eax
f0100ff3:	89 f2                	mov    %esi,%edx
f0100ff5:	89 f8                	mov    %edi,%eax
f0100ff7:	e8 89 ff ff ff       	call   f0100f85 <printnum>
f0100ffc:	83 c4 20             	add    $0x20,%esp
f0100fff:	eb 13                	jmp    f0101014 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101001:	83 ec 08             	sub    $0x8,%esp
f0101004:	56                   	push   %esi
f0101005:	ff 75 18             	pushl  0x18(%ebp)
f0101008:	ff d7                	call   *%edi
f010100a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010100d:	83 eb 01             	sub    $0x1,%ebx
f0101010:	85 db                	test   %ebx,%ebx
f0101012:	7f ed                	jg     f0101001 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101014:	83 ec 08             	sub    $0x8,%esp
f0101017:	56                   	push   %esi
f0101018:	83 ec 04             	sub    $0x4,%esp
f010101b:	ff 75 dc             	pushl  -0x24(%ebp)
f010101e:	ff 75 d8             	pushl  -0x28(%ebp)
f0101021:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101024:	ff 75 d0             	pushl  -0x30(%ebp)
f0101027:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010102a:	89 f3                	mov    %esi,%ebx
f010102c:	e8 1f 0b 00 00       	call   f0101b50 <__umoddi3>
f0101031:	83 c4 14             	add    $0x14,%esp
f0101034:	0f be 84 06 bd 0e ff 	movsbl -0xf143(%esi,%eax,1),%eax
f010103b:	ff 
f010103c:	50                   	push   %eax
f010103d:	ff d7                	call   *%edi
}
f010103f:	83 c4 10             	add    $0x10,%esp
f0101042:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101045:	5b                   	pop    %ebx
f0101046:	5e                   	pop    %esi
f0101047:	5f                   	pop    %edi
f0101048:	5d                   	pop    %ebp
f0101049:	c3                   	ret    
f010104a:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010104d:	eb be                	jmp    f010100d <printnum+0x88>

f010104f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010104f:	55                   	push   %ebp
f0101050:	89 e5                	mov    %esp,%ebp
f0101052:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101055:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101059:	8b 10                	mov    (%eax),%edx
f010105b:	3b 50 04             	cmp    0x4(%eax),%edx
f010105e:	73 0a                	jae    f010106a <sprintputch+0x1b>
		*b->buf++ = ch;
f0101060:	8d 4a 01             	lea    0x1(%edx),%ecx
f0101063:	89 08                	mov    %ecx,(%eax)
f0101065:	8b 45 08             	mov    0x8(%ebp),%eax
f0101068:	88 02                	mov    %al,(%edx)
}
f010106a:	5d                   	pop    %ebp
f010106b:	c3                   	ret    

f010106c <printfmt>:
{
f010106c:	55                   	push   %ebp
f010106d:	89 e5                	mov    %esp,%ebp
f010106f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0101072:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101075:	50                   	push   %eax
f0101076:	ff 75 10             	pushl  0x10(%ebp)
f0101079:	ff 75 0c             	pushl  0xc(%ebp)
f010107c:	ff 75 08             	pushl  0x8(%ebp)
f010107f:	e8 05 00 00 00       	call   f0101089 <vprintfmt>
}
f0101084:	83 c4 10             	add    $0x10,%esp
f0101087:	c9                   	leave  
f0101088:	c3                   	ret    

f0101089 <vprintfmt>:
{
f0101089:	55                   	push   %ebp
f010108a:	89 e5                	mov    %esp,%ebp
f010108c:	57                   	push   %edi
f010108d:	56                   	push   %esi
f010108e:	53                   	push   %ebx
f010108f:	83 ec 3c             	sub    $0x3c,%esp
f0101092:	e8 25 f1 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101097:	81 c3 71 02 01 00    	add    $0x10271,%ebx
f010109d:	8b 75 0c             	mov    0xc(%ebp),%esi
f01010a0:	8b 7d 10             	mov    0x10(%ebp),%edi
			csa = num;
f01010a3:	c7 c0 a8 36 11 f0    	mov    $0xf01136a8,%eax
f01010a9:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01010ac:	e9 a2 03 00 00       	jmp    f0101453 <.L36+0x48>
				csa = 0x0700;
f01010b1:	c7 c0 a8 36 11 f0    	mov    $0xf01136a8,%eax
f01010b7:	c7 00 00 07 00 00    	movl   $0x700,(%eax)
}
f01010bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010c0:	5b                   	pop    %ebx
f01010c1:	5e                   	pop    %esi
f01010c2:	5f                   	pop    %edi
f01010c3:	5d                   	pop    %ebp
f01010c4:	c3                   	ret    
		padc = ' ';
f01010c5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f01010c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01010d0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f01010d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01010de:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010e3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010e6:	8d 47 01             	lea    0x1(%edi),%eax
f01010e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010ec:	0f b6 17             	movzbl (%edi),%edx
f01010ef:	8d 42 dd             	lea    -0x23(%edx),%eax
f01010f2:	3c 55                	cmp    $0x55,%al
f01010f4:	0f 87 25 04 00 00    	ja     f010151f <.L22>
f01010fa:	0f b6 c0             	movzbl %al,%eax
f01010fd:	89 d9                	mov    %ebx,%ecx
f01010ff:	03 8c 83 4c 0f ff ff 	add    -0xf0b4(%ebx,%eax,4),%ecx
f0101106:	ff e1                	jmp    *%ecx

f0101108 <.L71>:
f0101108:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010110b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010110f:	eb d5                	jmp    f01010e6 <vprintfmt+0x5d>

f0101111 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0101111:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0101114:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101118:	eb cc                	jmp    f01010e6 <vprintfmt+0x5d>

f010111a <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f010111a:	0f b6 d2             	movzbl %dl,%edx
f010111d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0101120:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0101125:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101128:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010112c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010112f:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0101132:	83 f9 09             	cmp    $0x9,%ecx
f0101135:	77 55                	ja     f010118c <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0101137:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010113a:	eb e9                	jmp    f0101125 <.L29+0xb>

f010113c <.L26>:
			precision = va_arg(ap, int);
f010113c:	8b 45 14             	mov    0x14(%ebp),%eax
f010113f:	8b 00                	mov    (%eax),%eax
f0101141:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101144:	8b 45 14             	mov    0x14(%ebp),%eax
f0101147:	8d 40 04             	lea    0x4(%eax),%eax
f010114a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010114d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0101150:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101154:	79 90                	jns    f01010e6 <vprintfmt+0x5d>
				width = precision, precision = -1;
f0101156:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101159:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010115c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0101163:	eb 81                	jmp    f01010e6 <vprintfmt+0x5d>

f0101165 <.L27>:
f0101165:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101168:	85 c0                	test   %eax,%eax
f010116a:	ba 00 00 00 00       	mov    $0x0,%edx
f010116f:	0f 49 d0             	cmovns %eax,%edx
f0101172:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101175:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101178:	e9 69 ff ff ff       	jmp    f01010e6 <vprintfmt+0x5d>

f010117d <.L23>:
f010117d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0101180:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101187:	e9 5a ff ff ff       	jmp    f01010e6 <vprintfmt+0x5d>
f010118c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010118f:	eb bf                	jmp    f0101150 <.L26+0x14>

f0101191 <.L33>:
			lflag++;
f0101191:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101195:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0101198:	e9 49 ff ff ff       	jmp    f01010e6 <vprintfmt+0x5d>

f010119d <.L30>:
			putch(va_arg(ap, int), putdat);
f010119d:	8b 45 14             	mov    0x14(%ebp),%eax
f01011a0:	8d 78 04             	lea    0x4(%eax),%edi
f01011a3:	83 ec 08             	sub    $0x8,%esp
f01011a6:	56                   	push   %esi
f01011a7:	ff 30                	pushl  (%eax)
f01011a9:	ff 55 08             	call   *0x8(%ebp)
			break;
f01011ac:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01011af:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01011b2:	e9 99 02 00 00       	jmp    f0101450 <.L36+0x45>

f01011b7 <.L32>:
			err = va_arg(ap, int);
f01011b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ba:	8d 78 04             	lea    0x4(%eax),%edi
f01011bd:	8b 00                	mov    (%eax),%eax
f01011bf:	99                   	cltd   
f01011c0:	31 d0                	xor    %edx,%eax
f01011c2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01011c4:	83 f8 06             	cmp    $0x6,%eax
f01011c7:	7f 27                	jg     f01011f0 <.L32+0x39>
f01011c9:	8b 94 83 20 1d 00 00 	mov    0x1d20(%ebx,%eax,4),%edx
f01011d0:	85 d2                	test   %edx,%edx
f01011d2:	74 1c                	je     f01011f0 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f01011d4:	52                   	push   %edx
f01011d5:	8d 83 de 0e ff ff    	lea    -0xf122(%ebx),%eax
f01011db:	50                   	push   %eax
f01011dc:	56                   	push   %esi
f01011dd:	ff 75 08             	pushl  0x8(%ebp)
f01011e0:	e8 87 fe ff ff       	call   f010106c <printfmt>
f01011e5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01011e8:	89 7d 14             	mov    %edi,0x14(%ebp)
f01011eb:	e9 60 02 00 00       	jmp    f0101450 <.L36+0x45>
				printfmt(putch, putdat, "error %d", err);
f01011f0:	50                   	push   %eax
f01011f1:	8d 83 d5 0e ff ff    	lea    -0xf12b(%ebx),%eax
f01011f7:	50                   	push   %eax
f01011f8:	56                   	push   %esi
f01011f9:	ff 75 08             	pushl  0x8(%ebp)
f01011fc:	e8 6b fe ff ff       	call   f010106c <printfmt>
f0101201:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101204:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101207:	e9 44 02 00 00       	jmp    f0101450 <.L36+0x45>

f010120c <.L37>:
			if ((p = va_arg(ap, char *)) == NULL)
f010120c:	8b 45 14             	mov    0x14(%ebp),%eax
f010120f:	83 c0 04             	add    $0x4,%eax
f0101212:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101215:	8b 45 14             	mov    0x14(%ebp),%eax
f0101218:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010121a:	85 ff                	test   %edi,%edi
f010121c:	8d 83 ce 0e ff ff    	lea    -0xf132(%ebx),%eax
f0101222:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0101225:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101229:	0f 8e b5 00 00 00    	jle    f01012e4 <.L37+0xd8>
f010122f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101233:	75 08                	jne    f010123d <.L37+0x31>
f0101235:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101238:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010123b:	eb 6d                	jmp    f01012aa <.L37+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f010123d:	83 ec 08             	sub    $0x8,%esp
f0101240:	ff 75 cc             	pushl  -0x34(%ebp)
f0101243:	57                   	push   %edi
f0101244:	e8 89 04 00 00       	call   f01016d2 <strnlen>
f0101249:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010124c:	29 c2                	sub    %eax,%edx
f010124e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0101251:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101254:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101258:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010125b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010125e:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101260:	eb 10                	jmp    f0101272 <.L37+0x66>
					putch(padc, putdat);
f0101262:	83 ec 08             	sub    $0x8,%esp
f0101265:	56                   	push   %esi
f0101266:	ff 75 e0             	pushl  -0x20(%ebp)
f0101269:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010126c:	83 ef 01             	sub    $0x1,%edi
f010126f:	83 c4 10             	add    $0x10,%esp
f0101272:	85 ff                	test   %edi,%edi
f0101274:	7f ec                	jg     f0101262 <.L37+0x56>
f0101276:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101279:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010127c:	85 d2                	test   %edx,%edx
f010127e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101283:	0f 49 c2             	cmovns %edx,%eax
f0101286:	29 c2                	sub    %eax,%edx
f0101288:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010128b:	89 75 0c             	mov    %esi,0xc(%ebp)
f010128e:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101291:	eb 17                	jmp    f01012aa <.L37+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f0101293:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101297:	75 30                	jne    f01012c9 <.L37+0xbd>
					putch(ch, putdat);
f0101299:	83 ec 08             	sub    $0x8,%esp
f010129c:	ff 75 0c             	pushl  0xc(%ebp)
f010129f:	50                   	push   %eax
f01012a0:	ff 55 08             	call   *0x8(%ebp)
f01012a3:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01012a6:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01012aa:	83 c7 01             	add    $0x1,%edi
f01012ad:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01012b1:	0f be c2             	movsbl %dl,%eax
f01012b4:	85 c0                	test   %eax,%eax
f01012b6:	74 52                	je     f010130a <.L37+0xfe>
f01012b8:	85 f6                	test   %esi,%esi
f01012ba:	78 d7                	js     f0101293 <.L37+0x87>
f01012bc:	83 ee 01             	sub    $0x1,%esi
f01012bf:	79 d2                	jns    f0101293 <.L37+0x87>
f01012c1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01012c4:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01012c7:	eb 32                	jmp    f01012fb <.L37+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f01012c9:	0f be d2             	movsbl %dl,%edx
f01012cc:	83 ea 20             	sub    $0x20,%edx
f01012cf:	83 fa 5e             	cmp    $0x5e,%edx
f01012d2:	76 c5                	jbe    f0101299 <.L37+0x8d>
					putch('?', putdat);
f01012d4:	83 ec 08             	sub    $0x8,%esp
f01012d7:	ff 75 0c             	pushl  0xc(%ebp)
f01012da:	6a 3f                	push   $0x3f
f01012dc:	ff 55 08             	call   *0x8(%ebp)
f01012df:	83 c4 10             	add    $0x10,%esp
f01012e2:	eb c2                	jmp    f01012a6 <.L37+0x9a>
f01012e4:	89 75 0c             	mov    %esi,0xc(%ebp)
f01012e7:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01012ea:	eb be                	jmp    f01012aa <.L37+0x9e>
				putch(' ', putdat);
f01012ec:	83 ec 08             	sub    $0x8,%esp
f01012ef:	56                   	push   %esi
f01012f0:	6a 20                	push   $0x20
f01012f2:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f01012f5:	83 ef 01             	sub    $0x1,%edi
f01012f8:	83 c4 10             	add    $0x10,%esp
f01012fb:	85 ff                	test   %edi,%edi
f01012fd:	7f ed                	jg     f01012ec <.L37+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f01012ff:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101302:	89 45 14             	mov    %eax,0x14(%ebp)
f0101305:	e9 46 01 00 00       	jmp    f0101450 <.L36+0x45>
f010130a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010130d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101310:	eb e9                	jmp    f01012fb <.L37+0xef>

f0101312 <.L31>:
f0101312:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101315:	83 f9 01             	cmp    $0x1,%ecx
f0101318:	7e 40                	jle    f010135a <.L31+0x48>
		return va_arg(*ap, long long);
f010131a:	8b 45 14             	mov    0x14(%ebp),%eax
f010131d:	8b 50 04             	mov    0x4(%eax),%edx
f0101320:	8b 00                	mov    (%eax),%eax
f0101322:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101325:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101328:	8b 45 14             	mov    0x14(%ebp),%eax
f010132b:	8d 40 08             	lea    0x8(%eax),%eax
f010132e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101331:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101335:	79 55                	jns    f010138c <.L31+0x7a>
				putch('-', putdat);
f0101337:	83 ec 08             	sub    $0x8,%esp
f010133a:	56                   	push   %esi
f010133b:	6a 2d                	push   $0x2d
f010133d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101340:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101343:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101346:	f7 da                	neg    %edx
f0101348:	83 d1 00             	adc    $0x0,%ecx
f010134b:	f7 d9                	neg    %ecx
f010134d:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101350:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101355:	e9 db 00 00 00       	jmp    f0101435 <.L36+0x2a>
	else if (lflag)
f010135a:	85 c9                	test   %ecx,%ecx
f010135c:	75 17                	jne    f0101375 <.L31+0x63>
		return va_arg(*ap, int);
f010135e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101361:	8b 00                	mov    (%eax),%eax
f0101363:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101366:	99                   	cltd   
f0101367:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010136a:	8b 45 14             	mov    0x14(%ebp),%eax
f010136d:	8d 40 04             	lea    0x4(%eax),%eax
f0101370:	89 45 14             	mov    %eax,0x14(%ebp)
f0101373:	eb bc                	jmp    f0101331 <.L31+0x1f>
		return va_arg(*ap, long);
f0101375:	8b 45 14             	mov    0x14(%ebp),%eax
f0101378:	8b 00                	mov    (%eax),%eax
f010137a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010137d:	99                   	cltd   
f010137e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101381:	8b 45 14             	mov    0x14(%ebp),%eax
f0101384:	8d 40 04             	lea    0x4(%eax),%eax
f0101387:	89 45 14             	mov    %eax,0x14(%ebp)
f010138a:	eb a5                	jmp    f0101331 <.L31+0x1f>
			num = getint(&ap, lflag);
f010138c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010138f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0101392:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101397:	e9 99 00 00 00       	jmp    f0101435 <.L36+0x2a>

f010139c <.L38>:
f010139c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010139f:	83 f9 01             	cmp    $0x1,%ecx
f01013a2:	7e 15                	jle    f01013b9 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f01013a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01013a7:	8b 10                	mov    (%eax),%edx
f01013a9:	8b 48 04             	mov    0x4(%eax),%ecx
f01013ac:	8d 40 08             	lea    0x8(%eax),%eax
f01013af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01013b2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01013b7:	eb 7c                	jmp    f0101435 <.L36+0x2a>
	else if (lflag)
f01013b9:	85 c9                	test   %ecx,%ecx
f01013bb:	75 17                	jne    f01013d4 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f01013bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01013c0:	8b 10                	mov    (%eax),%edx
f01013c2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013c7:	8d 40 04             	lea    0x4(%eax),%eax
f01013ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01013cd:	b8 0a 00 00 00       	mov    $0xa,%eax
f01013d2:	eb 61                	jmp    f0101435 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f01013d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01013d7:	8b 10                	mov    (%eax),%edx
f01013d9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013de:	8d 40 04             	lea    0x4(%eax),%eax
f01013e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01013e4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01013e9:	eb 4a                	jmp    f0101435 <.L36+0x2a>

f01013eb <.L35>:
			putch('X', putdat);
f01013eb:	83 ec 08             	sub    $0x8,%esp
f01013ee:	56                   	push   %esi
f01013ef:	6a 58                	push   $0x58
f01013f1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01013f4:	83 c4 08             	add    $0x8,%esp
f01013f7:	56                   	push   %esi
f01013f8:	6a 58                	push   $0x58
f01013fa:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01013fd:	83 c4 08             	add    $0x8,%esp
f0101400:	56                   	push   %esi
f0101401:	6a 58                	push   $0x58
f0101403:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101406:	83 c4 10             	add    $0x10,%esp
f0101409:	eb 45                	jmp    f0101450 <.L36+0x45>

f010140b <.L36>:
			putch('0', putdat);
f010140b:	83 ec 08             	sub    $0x8,%esp
f010140e:	56                   	push   %esi
f010140f:	6a 30                	push   $0x30
f0101411:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101414:	83 c4 08             	add    $0x8,%esp
f0101417:	56                   	push   %esi
f0101418:	6a 78                	push   $0x78
f010141a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f010141d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101420:	8b 10                	mov    (%eax),%edx
f0101422:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101427:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010142a:	8d 40 04             	lea    0x4(%eax),%eax
f010142d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101430:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101435:	83 ec 0c             	sub    $0xc,%esp
f0101438:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010143c:	57                   	push   %edi
f010143d:	ff 75 e0             	pushl  -0x20(%ebp)
f0101440:	50                   	push   %eax
f0101441:	51                   	push   %ecx
f0101442:	52                   	push   %edx
f0101443:	89 f2                	mov    %esi,%edx
f0101445:	8b 45 08             	mov    0x8(%ebp),%eax
f0101448:	e8 38 fb ff ff       	call   f0100f85 <printnum>
			break;
f010144d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101453:	83 c7 01             	add    $0x1,%edi
f0101456:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010145a:	83 f8 25             	cmp    $0x25,%eax
f010145d:	0f 84 62 fc ff ff    	je     f01010c5 <vprintfmt+0x3c>
			if (ch == '\0'){
f0101463:	85 c0                	test   %eax,%eax
f0101465:	0f 84 46 fc ff ff    	je     f01010b1 <vprintfmt+0x28>
			putch(ch, putdat);
f010146b:	83 ec 08             	sub    $0x8,%esp
f010146e:	56                   	push   %esi
f010146f:	50                   	push   %eax
f0101470:	ff 55 08             	call   *0x8(%ebp)
f0101473:	83 c4 10             	add    $0x10,%esp
f0101476:	eb db                	jmp    f0101453 <.L36+0x48>

f0101478 <.L39>:
f0101478:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f010147b:	83 f9 01             	cmp    $0x1,%ecx
f010147e:	7e 15                	jle    f0101495 <.L39+0x1d>
		return va_arg(*ap, unsigned long long);
f0101480:	8b 45 14             	mov    0x14(%ebp),%eax
f0101483:	8b 10                	mov    (%eax),%edx
f0101485:	8b 48 04             	mov    0x4(%eax),%ecx
f0101488:	8d 40 08             	lea    0x8(%eax),%eax
f010148b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010148e:	b8 10 00 00 00       	mov    $0x10,%eax
f0101493:	eb a0                	jmp    f0101435 <.L36+0x2a>
	else if (lflag)
f0101495:	85 c9                	test   %ecx,%ecx
f0101497:	75 17                	jne    f01014b0 <.L39+0x38>
		return va_arg(*ap, unsigned int);
f0101499:	8b 45 14             	mov    0x14(%ebp),%eax
f010149c:	8b 10                	mov    (%eax),%edx
f010149e:	b9 00 00 00 00       	mov    $0x0,%ecx
f01014a3:	8d 40 04             	lea    0x4(%eax),%eax
f01014a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01014a9:	b8 10 00 00 00       	mov    $0x10,%eax
f01014ae:	eb 85                	jmp    f0101435 <.L36+0x2a>
		return va_arg(*ap, unsigned long);
f01014b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01014b3:	8b 10                	mov    (%eax),%edx
f01014b5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01014ba:	8d 40 04             	lea    0x4(%eax),%eax
f01014bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01014c0:	b8 10 00 00 00       	mov    $0x10,%eax
f01014c5:	e9 6b ff ff ff       	jmp    f0101435 <.L36+0x2a>

f01014ca <.L25>:
			putch(ch, putdat);
f01014ca:	83 ec 08             	sub    $0x8,%esp
f01014cd:	56                   	push   %esi
f01014ce:	6a 25                	push   $0x25
f01014d0:	ff 55 08             	call   *0x8(%ebp)
			break;
f01014d3:	83 c4 10             	add    $0x10,%esp
f01014d6:	e9 75 ff ff ff       	jmp    f0101450 <.L36+0x45>

f01014db <.L34>:
f01014db:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01014de:	83 f9 01             	cmp    $0x1,%ecx
f01014e1:	7e 18                	jle    f01014fb <.L34+0x20>
		return va_arg(*ap, long long);
f01014e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01014e6:	8b 00                	mov    (%eax),%eax
f01014e8:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01014eb:	8d 49 08             	lea    0x8(%ecx),%ecx
f01014ee:	89 4d 14             	mov    %ecx,0x14(%ebp)
			csa = num;
f01014f1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01014f4:	89 01                	mov    %eax,(%ecx)
			break;
f01014f6:	e9 55 ff ff ff       	jmp    f0101450 <.L36+0x45>
	else if (lflag)
f01014fb:	85 c9                	test   %ecx,%ecx
f01014fd:	75 10                	jne    f010150f <.L34+0x34>
		return va_arg(*ap, int);
f01014ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0101502:	8b 00                	mov    (%eax),%eax
f0101504:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101507:	8d 49 04             	lea    0x4(%ecx),%ecx
f010150a:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010150d:	eb e2                	jmp    f01014f1 <.L34+0x16>
		return va_arg(*ap, long);
f010150f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101512:	8b 00                	mov    (%eax),%eax
f0101514:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101517:	8d 49 04             	lea    0x4(%ecx),%ecx
f010151a:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010151d:	eb d2                	jmp    f01014f1 <.L34+0x16>

f010151f <.L22>:
			putch('%', putdat);
f010151f:	83 ec 08             	sub    $0x8,%esp
f0101522:	56                   	push   %esi
f0101523:	6a 25                	push   $0x25
f0101525:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101528:	83 c4 10             	add    $0x10,%esp
f010152b:	89 f8                	mov    %edi,%eax
f010152d:	eb 03                	jmp    f0101532 <.L22+0x13>
f010152f:	83 e8 01             	sub    $0x1,%eax
f0101532:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101536:	75 f7                	jne    f010152f <.L22+0x10>
f0101538:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010153b:	e9 10 ff ff ff       	jmp    f0101450 <.L36+0x45>

f0101540 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101540:	55                   	push   %ebp
f0101541:	89 e5                	mov    %esp,%ebp
f0101543:	53                   	push   %ebx
f0101544:	83 ec 14             	sub    $0x14,%esp
f0101547:	e8 70 ec ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010154c:	81 c3 bc fd 00 00    	add    $0xfdbc,%ebx
f0101552:	8b 45 08             	mov    0x8(%ebp),%eax
f0101555:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101558:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010155b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010155f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101562:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101569:	85 c0                	test   %eax,%eax
f010156b:	74 2b                	je     f0101598 <vsnprintf+0x58>
f010156d:	85 d2                	test   %edx,%edx
f010156f:	7e 27                	jle    f0101598 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101571:	ff 75 14             	pushl  0x14(%ebp)
f0101574:	ff 75 10             	pushl  0x10(%ebp)
f0101577:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010157a:	50                   	push   %eax
f010157b:	8d 83 47 fd fe ff    	lea    -0x102b9(%ebx),%eax
f0101581:	50                   	push   %eax
f0101582:	e8 02 fb ff ff       	call   f0101089 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101587:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010158a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010158d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101590:	83 c4 10             	add    $0x10,%esp
}
f0101593:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101596:	c9                   	leave  
f0101597:	c3                   	ret    
		return -E_INVAL;
f0101598:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010159d:	eb f4                	jmp    f0101593 <vsnprintf+0x53>

f010159f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010159f:	55                   	push   %ebp
f01015a0:	89 e5                	mov    %esp,%ebp
f01015a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01015a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01015a8:	50                   	push   %eax
f01015a9:	ff 75 10             	pushl  0x10(%ebp)
f01015ac:	ff 75 0c             	pushl  0xc(%ebp)
f01015af:	ff 75 08             	pushl  0x8(%ebp)
f01015b2:	e8 89 ff ff ff       	call   f0101540 <vsnprintf>
	va_end(ap);

	return rc;
}
f01015b7:	c9                   	leave  
f01015b8:	c3                   	ret    

f01015b9 <__x86.get_pc_thunk.cx>:
f01015b9:	8b 0c 24             	mov    (%esp),%ecx
f01015bc:	c3                   	ret    

f01015bd <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01015bd:	55                   	push   %ebp
f01015be:	89 e5                	mov    %esp,%ebp
f01015c0:	57                   	push   %edi
f01015c1:	56                   	push   %esi
f01015c2:	53                   	push   %ebx
f01015c3:	83 ec 1c             	sub    $0x1c,%esp
f01015c6:	e8 f1 eb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01015cb:	81 c3 3d fd 00 00    	add    $0xfd3d,%ebx
f01015d1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01015d4:	85 c0                	test   %eax,%eax
f01015d6:	74 13                	je     f01015eb <readline+0x2e>
		cprintf("%s", prompt);
f01015d8:	83 ec 08             	sub    $0x8,%esp
f01015db:	50                   	push   %eax
f01015dc:	8d 83 de 0e ff ff    	lea    -0xf122(%ebx),%eax
f01015e2:	50                   	push   %eax
f01015e3:	e8 11 f6 ff ff       	call   f0100bf9 <cprintf>
f01015e8:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01015eb:	83 ec 0c             	sub    $0xc,%esp
f01015ee:	6a 00                	push   $0x0
f01015f0:	e8 71 f1 ff ff       	call   f0100766 <iscons>
f01015f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01015f8:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01015fb:	bf 00 00 00 00       	mov    $0x0,%edi
f0101600:	eb 46                	jmp    f0101648 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0101602:	83 ec 08             	sub    $0x8,%esp
f0101605:	50                   	push   %eax
f0101606:	8d 83 a4 10 ff ff    	lea    -0xef5c(%ebx),%eax
f010160c:	50                   	push   %eax
f010160d:	e8 e7 f5 ff ff       	call   f0100bf9 <cprintf>
			return NULL;
f0101612:	83 c4 10             	add    $0x10,%esp
f0101615:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010161a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010161d:	5b                   	pop    %ebx
f010161e:	5e                   	pop    %esi
f010161f:	5f                   	pop    %edi
f0101620:	5d                   	pop    %ebp
f0101621:	c3                   	ret    
			if (echoing)
f0101622:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101626:	75 05                	jne    f010162d <readline+0x70>
			i--;
f0101628:	83 ef 01             	sub    $0x1,%edi
f010162b:	eb 1b                	jmp    f0101648 <readline+0x8b>
				cputchar('\b');
f010162d:	83 ec 0c             	sub    $0xc,%esp
f0101630:	6a 08                	push   $0x8
f0101632:	e8 0e f1 ff ff       	call   f0100745 <cputchar>
f0101637:	83 c4 10             	add    $0x10,%esp
f010163a:	eb ec                	jmp    f0101628 <readline+0x6b>
			buf[i++] = c;
f010163c:	89 f0                	mov    %esi,%eax
f010163e:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f0101645:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0101648:	e8 08 f1 ff ff       	call   f0100755 <getchar>
f010164d:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f010164f:	85 c0                	test   %eax,%eax
f0101651:	78 af                	js     f0101602 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101653:	83 f8 08             	cmp    $0x8,%eax
f0101656:	0f 94 c2             	sete   %dl
f0101659:	83 f8 7f             	cmp    $0x7f,%eax
f010165c:	0f 94 c0             	sete   %al
f010165f:	08 c2                	or     %al,%dl
f0101661:	74 04                	je     f0101667 <readline+0xaa>
f0101663:	85 ff                	test   %edi,%edi
f0101665:	7f bb                	jg     f0101622 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101667:	83 fe 1f             	cmp    $0x1f,%esi
f010166a:	7e 1c                	jle    f0101688 <readline+0xcb>
f010166c:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101672:	7f 14                	jg     f0101688 <readline+0xcb>
			if (echoing)
f0101674:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101678:	74 c2                	je     f010163c <readline+0x7f>
				cputchar(c);
f010167a:	83 ec 0c             	sub    $0xc,%esp
f010167d:	56                   	push   %esi
f010167e:	e8 c2 f0 ff ff       	call   f0100745 <cputchar>
f0101683:	83 c4 10             	add    $0x10,%esp
f0101686:	eb b4                	jmp    f010163c <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0101688:	83 fe 0a             	cmp    $0xa,%esi
f010168b:	74 05                	je     f0101692 <readline+0xd5>
f010168d:	83 fe 0d             	cmp    $0xd,%esi
f0101690:	75 b6                	jne    f0101648 <readline+0x8b>
			if (echoing)
f0101692:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101696:	75 13                	jne    f01016ab <readline+0xee>
			buf[i] = 0;
f0101698:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f010169f:	00 
			return buf;
f01016a0:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01016a6:	e9 6f ff ff ff       	jmp    f010161a <readline+0x5d>
				cputchar('\n');
f01016ab:	83 ec 0c             	sub    $0xc,%esp
f01016ae:	6a 0a                	push   $0xa
f01016b0:	e8 90 f0 ff ff       	call   f0100745 <cputchar>
f01016b5:	83 c4 10             	add    $0x10,%esp
f01016b8:	eb de                	jmp    f0101698 <readline+0xdb>

f01016ba <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01016ba:	55                   	push   %ebp
f01016bb:	89 e5                	mov    %esp,%ebp
f01016bd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01016c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01016c5:	eb 03                	jmp    f01016ca <strlen+0x10>
		n++;
f01016c7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01016ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01016ce:	75 f7                	jne    f01016c7 <strlen+0xd>
	return n;
}
f01016d0:	5d                   	pop    %ebp
f01016d1:	c3                   	ret    

f01016d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01016d2:	55                   	push   %ebp
f01016d3:	89 e5                	mov    %esp,%ebp
f01016d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01016db:	b8 00 00 00 00       	mov    $0x0,%eax
f01016e0:	eb 03                	jmp    f01016e5 <strnlen+0x13>
		n++;
f01016e2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01016e5:	39 d0                	cmp    %edx,%eax
f01016e7:	74 06                	je     f01016ef <strnlen+0x1d>
f01016e9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01016ed:	75 f3                	jne    f01016e2 <strnlen+0x10>
	return n;
}
f01016ef:	5d                   	pop    %ebp
f01016f0:	c3                   	ret    

f01016f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01016f1:	55                   	push   %ebp
f01016f2:	89 e5                	mov    %esp,%ebp
f01016f4:	53                   	push   %ebx
f01016f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01016f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01016fb:	89 c2                	mov    %eax,%edx
f01016fd:	83 c1 01             	add    $0x1,%ecx
f0101700:	83 c2 01             	add    $0x1,%edx
f0101703:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101707:	88 5a ff             	mov    %bl,-0x1(%edx)
f010170a:	84 db                	test   %bl,%bl
f010170c:	75 ef                	jne    f01016fd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010170e:	5b                   	pop    %ebx
f010170f:	5d                   	pop    %ebp
f0101710:	c3                   	ret    

f0101711 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101711:	55                   	push   %ebp
f0101712:	89 e5                	mov    %esp,%ebp
f0101714:	53                   	push   %ebx
f0101715:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101718:	53                   	push   %ebx
f0101719:	e8 9c ff ff ff       	call   f01016ba <strlen>
f010171e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101721:	ff 75 0c             	pushl  0xc(%ebp)
f0101724:	01 d8                	add    %ebx,%eax
f0101726:	50                   	push   %eax
f0101727:	e8 c5 ff ff ff       	call   f01016f1 <strcpy>
	return dst;
}
f010172c:	89 d8                	mov    %ebx,%eax
f010172e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101731:	c9                   	leave  
f0101732:	c3                   	ret    

f0101733 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101733:	55                   	push   %ebp
f0101734:	89 e5                	mov    %esp,%ebp
f0101736:	56                   	push   %esi
f0101737:	53                   	push   %ebx
f0101738:	8b 75 08             	mov    0x8(%ebp),%esi
f010173b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010173e:	89 f3                	mov    %esi,%ebx
f0101740:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101743:	89 f2                	mov    %esi,%edx
f0101745:	eb 0f                	jmp    f0101756 <strncpy+0x23>
		*dst++ = *src;
f0101747:	83 c2 01             	add    $0x1,%edx
f010174a:	0f b6 01             	movzbl (%ecx),%eax
f010174d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101750:	80 39 01             	cmpb   $0x1,(%ecx)
f0101753:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0101756:	39 da                	cmp    %ebx,%edx
f0101758:	75 ed                	jne    f0101747 <strncpy+0x14>
	}
	return ret;
}
f010175a:	89 f0                	mov    %esi,%eax
f010175c:	5b                   	pop    %ebx
f010175d:	5e                   	pop    %esi
f010175e:	5d                   	pop    %ebp
f010175f:	c3                   	ret    

f0101760 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101760:	55                   	push   %ebp
f0101761:	89 e5                	mov    %esp,%ebp
f0101763:	56                   	push   %esi
f0101764:	53                   	push   %ebx
f0101765:	8b 75 08             	mov    0x8(%ebp),%esi
f0101768:	8b 55 0c             	mov    0xc(%ebp),%edx
f010176b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010176e:	89 f0                	mov    %esi,%eax
f0101770:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101774:	85 c9                	test   %ecx,%ecx
f0101776:	75 0b                	jne    f0101783 <strlcpy+0x23>
f0101778:	eb 17                	jmp    f0101791 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010177a:	83 c2 01             	add    $0x1,%edx
f010177d:	83 c0 01             	add    $0x1,%eax
f0101780:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0101783:	39 d8                	cmp    %ebx,%eax
f0101785:	74 07                	je     f010178e <strlcpy+0x2e>
f0101787:	0f b6 0a             	movzbl (%edx),%ecx
f010178a:	84 c9                	test   %cl,%cl
f010178c:	75 ec                	jne    f010177a <strlcpy+0x1a>
		*dst = '\0';
f010178e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101791:	29 f0                	sub    %esi,%eax
}
f0101793:	5b                   	pop    %ebx
f0101794:	5e                   	pop    %esi
f0101795:	5d                   	pop    %ebp
f0101796:	c3                   	ret    

f0101797 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101797:	55                   	push   %ebp
f0101798:	89 e5                	mov    %esp,%ebp
f010179a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010179d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01017a0:	eb 06                	jmp    f01017a8 <strcmp+0x11>
		p++, q++;
f01017a2:	83 c1 01             	add    $0x1,%ecx
f01017a5:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01017a8:	0f b6 01             	movzbl (%ecx),%eax
f01017ab:	84 c0                	test   %al,%al
f01017ad:	74 04                	je     f01017b3 <strcmp+0x1c>
f01017af:	3a 02                	cmp    (%edx),%al
f01017b1:	74 ef                	je     f01017a2 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01017b3:	0f b6 c0             	movzbl %al,%eax
f01017b6:	0f b6 12             	movzbl (%edx),%edx
f01017b9:	29 d0                	sub    %edx,%eax
}
f01017bb:	5d                   	pop    %ebp
f01017bc:	c3                   	ret    

f01017bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01017bd:	55                   	push   %ebp
f01017be:	89 e5                	mov    %esp,%ebp
f01017c0:	53                   	push   %ebx
f01017c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01017c4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017c7:	89 c3                	mov    %eax,%ebx
f01017c9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01017cc:	eb 06                	jmp    f01017d4 <strncmp+0x17>
		n--, p++, q++;
f01017ce:	83 c0 01             	add    $0x1,%eax
f01017d1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01017d4:	39 d8                	cmp    %ebx,%eax
f01017d6:	74 16                	je     f01017ee <strncmp+0x31>
f01017d8:	0f b6 08             	movzbl (%eax),%ecx
f01017db:	84 c9                	test   %cl,%cl
f01017dd:	74 04                	je     f01017e3 <strncmp+0x26>
f01017df:	3a 0a                	cmp    (%edx),%cl
f01017e1:	74 eb                	je     f01017ce <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01017e3:	0f b6 00             	movzbl (%eax),%eax
f01017e6:	0f b6 12             	movzbl (%edx),%edx
f01017e9:	29 d0                	sub    %edx,%eax
}
f01017eb:	5b                   	pop    %ebx
f01017ec:	5d                   	pop    %ebp
f01017ed:	c3                   	ret    
		return 0;
f01017ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01017f3:	eb f6                	jmp    f01017eb <strncmp+0x2e>

f01017f5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01017f5:	55                   	push   %ebp
f01017f6:	89 e5                	mov    %esp,%ebp
f01017f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01017fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017ff:	0f b6 10             	movzbl (%eax),%edx
f0101802:	84 d2                	test   %dl,%dl
f0101804:	74 09                	je     f010180f <strchr+0x1a>
		if (*s == c)
f0101806:	38 ca                	cmp    %cl,%dl
f0101808:	74 0a                	je     f0101814 <strchr+0x1f>
	for (; *s; s++)
f010180a:	83 c0 01             	add    $0x1,%eax
f010180d:	eb f0                	jmp    f01017ff <strchr+0xa>
			return (char *) s;
	return 0;
f010180f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101814:	5d                   	pop    %ebp
f0101815:	c3                   	ret    

f0101816 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101816:	55                   	push   %ebp
f0101817:	89 e5                	mov    %esp,%ebp
f0101819:	8b 45 08             	mov    0x8(%ebp),%eax
f010181c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101820:	eb 03                	jmp    f0101825 <strfind+0xf>
f0101822:	83 c0 01             	add    $0x1,%eax
f0101825:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101828:	38 ca                	cmp    %cl,%dl
f010182a:	74 04                	je     f0101830 <strfind+0x1a>
f010182c:	84 d2                	test   %dl,%dl
f010182e:	75 f2                	jne    f0101822 <strfind+0xc>
			break;
	return (char *) s;
}
f0101830:	5d                   	pop    %ebp
f0101831:	c3                   	ret    

f0101832 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101832:	55                   	push   %ebp
f0101833:	89 e5                	mov    %esp,%ebp
f0101835:	57                   	push   %edi
f0101836:	56                   	push   %esi
f0101837:	53                   	push   %ebx
f0101838:	8b 7d 08             	mov    0x8(%ebp),%edi
f010183b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010183e:	85 c9                	test   %ecx,%ecx
f0101840:	74 13                	je     f0101855 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101842:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101848:	75 05                	jne    f010184f <memset+0x1d>
f010184a:	f6 c1 03             	test   $0x3,%cl
f010184d:	74 0d                	je     f010185c <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010184f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101852:	fc                   	cld    
f0101853:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101855:	89 f8                	mov    %edi,%eax
f0101857:	5b                   	pop    %ebx
f0101858:	5e                   	pop    %esi
f0101859:	5f                   	pop    %edi
f010185a:	5d                   	pop    %ebp
f010185b:	c3                   	ret    
		c &= 0xFF;
f010185c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101860:	89 d3                	mov    %edx,%ebx
f0101862:	c1 e3 08             	shl    $0x8,%ebx
f0101865:	89 d0                	mov    %edx,%eax
f0101867:	c1 e0 18             	shl    $0x18,%eax
f010186a:	89 d6                	mov    %edx,%esi
f010186c:	c1 e6 10             	shl    $0x10,%esi
f010186f:	09 f0                	or     %esi,%eax
f0101871:	09 c2                	or     %eax,%edx
f0101873:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0101875:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101878:	89 d0                	mov    %edx,%eax
f010187a:	fc                   	cld    
f010187b:	f3 ab                	rep stos %eax,%es:(%edi)
f010187d:	eb d6                	jmp    f0101855 <memset+0x23>

f010187f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010187f:	55                   	push   %ebp
f0101880:	89 e5                	mov    %esp,%ebp
f0101882:	57                   	push   %edi
f0101883:	56                   	push   %esi
f0101884:	8b 45 08             	mov    0x8(%ebp),%eax
f0101887:	8b 75 0c             	mov    0xc(%ebp),%esi
f010188a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010188d:	39 c6                	cmp    %eax,%esi
f010188f:	73 35                	jae    f01018c6 <memmove+0x47>
f0101891:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101894:	39 c2                	cmp    %eax,%edx
f0101896:	76 2e                	jbe    f01018c6 <memmove+0x47>
		s += n;
		d += n;
f0101898:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010189b:	89 d6                	mov    %edx,%esi
f010189d:	09 fe                	or     %edi,%esi
f010189f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01018a5:	74 0c                	je     f01018b3 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01018a7:	83 ef 01             	sub    $0x1,%edi
f01018aa:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01018ad:	fd                   	std    
f01018ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01018b0:	fc                   	cld    
f01018b1:	eb 21                	jmp    f01018d4 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01018b3:	f6 c1 03             	test   $0x3,%cl
f01018b6:	75 ef                	jne    f01018a7 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01018b8:	83 ef 04             	sub    $0x4,%edi
f01018bb:	8d 72 fc             	lea    -0x4(%edx),%esi
f01018be:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01018c1:	fd                   	std    
f01018c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01018c4:	eb ea                	jmp    f01018b0 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01018c6:	89 f2                	mov    %esi,%edx
f01018c8:	09 c2                	or     %eax,%edx
f01018ca:	f6 c2 03             	test   $0x3,%dl
f01018cd:	74 09                	je     f01018d8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01018cf:	89 c7                	mov    %eax,%edi
f01018d1:	fc                   	cld    
f01018d2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01018d4:	5e                   	pop    %esi
f01018d5:	5f                   	pop    %edi
f01018d6:	5d                   	pop    %ebp
f01018d7:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01018d8:	f6 c1 03             	test   $0x3,%cl
f01018db:	75 f2                	jne    f01018cf <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01018dd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01018e0:	89 c7                	mov    %eax,%edi
f01018e2:	fc                   	cld    
f01018e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01018e5:	eb ed                	jmp    f01018d4 <memmove+0x55>

f01018e7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01018e7:	55                   	push   %ebp
f01018e8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01018ea:	ff 75 10             	pushl  0x10(%ebp)
f01018ed:	ff 75 0c             	pushl  0xc(%ebp)
f01018f0:	ff 75 08             	pushl  0x8(%ebp)
f01018f3:	e8 87 ff ff ff       	call   f010187f <memmove>
}
f01018f8:	c9                   	leave  
f01018f9:	c3                   	ret    

f01018fa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01018fa:	55                   	push   %ebp
f01018fb:	89 e5                	mov    %esp,%ebp
f01018fd:	56                   	push   %esi
f01018fe:	53                   	push   %ebx
f01018ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0101902:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101905:	89 c6                	mov    %eax,%esi
f0101907:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010190a:	39 f0                	cmp    %esi,%eax
f010190c:	74 1c                	je     f010192a <memcmp+0x30>
		if (*s1 != *s2)
f010190e:	0f b6 08             	movzbl (%eax),%ecx
f0101911:	0f b6 1a             	movzbl (%edx),%ebx
f0101914:	38 d9                	cmp    %bl,%cl
f0101916:	75 08                	jne    f0101920 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101918:	83 c0 01             	add    $0x1,%eax
f010191b:	83 c2 01             	add    $0x1,%edx
f010191e:	eb ea                	jmp    f010190a <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0101920:	0f b6 c1             	movzbl %cl,%eax
f0101923:	0f b6 db             	movzbl %bl,%ebx
f0101926:	29 d8                	sub    %ebx,%eax
f0101928:	eb 05                	jmp    f010192f <memcmp+0x35>
	}

	return 0;
f010192a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010192f:	5b                   	pop    %ebx
f0101930:	5e                   	pop    %esi
f0101931:	5d                   	pop    %ebp
f0101932:	c3                   	ret    

f0101933 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101933:	55                   	push   %ebp
f0101934:	89 e5                	mov    %esp,%ebp
f0101936:	8b 45 08             	mov    0x8(%ebp),%eax
f0101939:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010193c:	89 c2                	mov    %eax,%edx
f010193e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101941:	39 d0                	cmp    %edx,%eax
f0101943:	73 09                	jae    f010194e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101945:	38 08                	cmp    %cl,(%eax)
f0101947:	74 05                	je     f010194e <memfind+0x1b>
	for (; s < ends; s++)
f0101949:	83 c0 01             	add    $0x1,%eax
f010194c:	eb f3                	jmp    f0101941 <memfind+0xe>
			break;
	return (void *) s;
}
f010194e:	5d                   	pop    %ebp
f010194f:	c3                   	ret    

f0101950 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101950:	55                   	push   %ebp
f0101951:	89 e5                	mov    %esp,%ebp
f0101953:	57                   	push   %edi
f0101954:	56                   	push   %esi
f0101955:	53                   	push   %ebx
f0101956:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101959:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010195c:	eb 03                	jmp    f0101961 <strtol+0x11>
		s++;
f010195e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101961:	0f b6 01             	movzbl (%ecx),%eax
f0101964:	3c 20                	cmp    $0x20,%al
f0101966:	74 f6                	je     f010195e <strtol+0xe>
f0101968:	3c 09                	cmp    $0x9,%al
f010196a:	74 f2                	je     f010195e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010196c:	3c 2b                	cmp    $0x2b,%al
f010196e:	74 2e                	je     f010199e <strtol+0x4e>
	int neg = 0;
f0101970:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101975:	3c 2d                	cmp    $0x2d,%al
f0101977:	74 2f                	je     f01019a8 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101979:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010197f:	75 05                	jne    f0101986 <strtol+0x36>
f0101981:	80 39 30             	cmpb   $0x30,(%ecx)
f0101984:	74 2c                	je     f01019b2 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101986:	85 db                	test   %ebx,%ebx
f0101988:	75 0a                	jne    f0101994 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010198a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f010198f:	80 39 30             	cmpb   $0x30,(%ecx)
f0101992:	74 28                	je     f01019bc <strtol+0x6c>
		base = 10;
f0101994:	b8 00 00 00 00       	mov    $0x0,%eax
f0101999:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010199c:	eb 50                	jmp    f01019ee <strtol+0x9e>
		s++;
f010199e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01019a1:	bf 00 00 00 00       	mov    $0x0,%edi
f01019a6:	eb d1                	jmp    f0101979 <strtol+0x29>
		s++, neg = 1;
f01019a8:	83 c1 01             	add    $0x1,%ecx
f01019ab:	bf 01 00 00 00       	mov    $0x1,%edi
f01019b0:	eb c7                	jmp    f0101979 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01019b2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01019b6:	74 0e                	je     f01019c6 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01019b8:	85 db                	test   %ebx,%ebx
f01019ba:	75 d8                	jne    f0101994 <strtol+0x44>
		s++, base = 8;
f01019bc:	83 c1 01             	add    $0x1,%ecx
f01019bf:	bb 08 00 00 00       	mov    $0x8,%ebx
f01019c4:	eb ce                	jmp    f0101994 <strtol+0x44>
		s += 2, base = 16;
f01019c6:	83 c1 02             	add    $0x2,%ecx
f01019c9:	bb 10 00 00 00       	mov    $0x10,%ebx
f01019ce:	eb c4                	jmp    f0101994 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01019d0:	8d 72 9f             	lea    -0x61(%edx),%esi
f01019d3:	89 f3                	mov    %esi,%ebx
f01019d5:	80 fb 19             	cmp    $0x19,%bl
f01019d8:	77 29                	ja     f0101a03 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01019da:	0f be d2             	movsbl %dl,%edx
f01019dd:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01019e0:	3b 55 10             	cmp    0x10(%ebp),%edx
f01019e3:	7d 30                	jge    f0101a15 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01019e5:	83 c1 01             	add    $0x1,%ecx
f01019e8:	0f af 45 10          	imul   0x10(%ebp),%eax
f01019ec:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01019ee:	0f b6 11             	movzbl (%ecx),%edx
f01019f1:	8d 72 d0             	lea    -0x30(%edx),%esi
f01019f4:	89 f3                	mov    %esi,%ebx
f01019f6:	80 fb 09             	cmp    $0x9,%bl
f01019f9:	77 d5                	ja     f01019d0 <strtol+0x80>
			dig = *s - '0';
f01019fb:	0f be d2             	movsbl %dl,%edx
f01019fe:	83 ea 30             	sub    $0x30,%edx
f0101a01:	eb dd                	jmp    f01019e0 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0101a03:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101a06:	89 f3                	mov    %esi,%ebx
f0101a08:	80 fb 19             	cmp    $0x19,%bl
f0101a0b:	77 08                	ja     f0101a15 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101a0d:	0f be d2             	movsbl %dl,%edx
f0101a10:	83 ea 37             	sub    $0x37,%edx
f0101a13:	eb cb                	jmp    f01019e0 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101a15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101a19:	74 05                	je     f0101a20 <strtol+0xd0>
		*endptr = (char *) s;
f0101a1b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101a1e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101a20:	89 c2                	mov    %eax,%edx
f0101a22:	f7 da                	neg    %edx
f0101a24:	85 ff                	test   %edi,%edi
f0101a26:	0f 45 c2             	cmovne %edx,%eax
}
f0101a29:	5b                   	pop    %ebx
f0101a2a:	5e                   	pop    %esi
f0101a2b:	5f                   	pop    %edi
f0101a2c:	5d                   	pop    %ebp
f0101a2d:	c3                   	ret    
f0101a2e:	66 90                	xchg   %ax,%ax

f0101a30 <__udivdi3>:
f0101a30:	55                   	push   %ebp
f0101a31:	57                   	push   %edi
f0101a32:	56                   	push   %esi
f0101a33:	53                   	push   %ebx
f0101a34:	83 ec 1c             	sub    $0x1c,%esp
f0101a37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101a3b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101a3f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101a43:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101a47:	85 d2                	test   %edx,%edx
f0101a49:	75 35                	jne    f0101a80 <__udivdi3+0x50>
f0101a4b:	39 f3                	cmp    %esi,%ebx
f0101a4d:	0f 87 bd 00 00 00    	ja     f0101b10 <__udivdi3+0xe0>
f0101a53:	85 db                	test   %ebx,%ebx
f0101a55:	89 d9                	mov    %ebx,%ecx
f0101a57:	75 0b                	jne    f0101a64 <__udivdi3+0x34>
f0101a59:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a5e:	31 d2                	xor    %edx,%edx
f0101a60:	f7 f3                	div    %ebx
f0101a62:	89 c1                	mov    %eax,%ecx
f0101a64:	31 d2                	xor    %edx,%edx
f0101a66:	89 f0                	mov    %esi,%eax
f0101a68:	f7 f1                	div    %ecx
f0101a6a:	89 c6                	mov    %eax,%esi
f0101a6c:	89 e8                	mov    %ebp,%eax
f0101a6e:	89 f7                	mov    %esi,%edi
f0101a70:	f7 f1                	div    %ecx
f0101a72:	89 fa                	mov    %edi,%edx
f0101a74:	83 c4 1c             	add    $0x1c,%esp
f0101a77:	5b                   	pop    %ebx
f0101a78:	5e                   	pop    %esi
f0101a79:	5f                   	pop    %edi
f0101a7a:	5d                   	pop    %ebp
f0101a7b:	c3                   	ret    
f0101a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101a80:	39 f2                	cmp    %esi,%edx
f0101a82:	77 7c                	ja     f0101b00 <__udivdi3+0xd0>
f0101a84:	0f bd fa             	bsr    %edx,%edi
f0101a87:	83 f7 1f             	xor    $0x1f,%edi
f0101a8a:	0f 84 98 00 00 00    	je     f0101b28 <__udivdi3+0xf8>
f0101a90:	89 f9                	mov    %edi,%ecx
f0101a92:	b8 20 00 00 00       	mov    $0x20,%eax
f0101a97:	29 f8                	sub    %edi,%eax
f0101a99:	d3 e2                	shl    %cl,%edx
f0101a9b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101a9f:	89 c1                	mov    %eax,%ecx
f0101aa1:	89 da                	mov    %ebx,%edx
f0101aa3:	d3 ea                	shr    %cl,%edx
f0101aa5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101aa9:	09 d1                	or     %edx,%ecx
f0101aab:	89 f2                	mov    %esi,%edx
f0101aad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ab1:	89 f9                	mov    %edi,%ecx
f0101ab3:	d3 e3                	shl    %cl,%ebx
f0101ab5:	89 c1                	mov    %eax,%ecx
f0101ab7:	d3 ea                	shr    %cl,%edx
f0101ab9:	89 f9                	mov    %edi,%ecx
f0101abb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101abf:	d3 e6                	shl    %cl,%esi
f0101ac1:	89 eb                	mov    %ebp,%ebx
f0101ac3:	89 c1                	mov    %eax,%ecx
f0101ac5:	d3 eb                	shr    %cl,%ebx
f0101ac7:	09 de                	or     %ebx,%esi
f0101ac9:	89 f0                	mov    %esi,%eax
f0101acb:	f7 74 24 08          	divl   0x8(%esp)
f0101acf:	89 d6                	mov    %edx,%esi
f0101ad1:	89 c3                	mov    %eax,%ebx
f0101ad3:	f7 64 24 0c          	mull   0xc(%esp)
f0101ad7:	39 d6                	cmp    %edx,%esi
f0101ad9:	72 0c                	jb     f0101ae7 <__udivdi3+0xb7>
f0101adb:	89 f9                	mov    %edi,%ecx
f0101add:	d3 e5                	shl    %cl,%ebp
f0101adf:	39 c5                	cmp    %eax,%ebp
f0101ae1:	73 5d                	jae    f0101b40 <__udivdi3+0x110>
f0101ae3:	39 d6                	cmp    %edx,%esi
f0101ae5:	75 59                	jne    f0101b40 <__udivdi3+0x110>
f0101ae7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101aea:	31 ff                	xor    %edi,%edi
f0101aec:	89 fa                	mov    %edi,%edx
f0101aee:	83 c4 1c             	add    $0x1c,%esp
f0101af1:	5b                   	pop    %ebx
f0101af2:	5e                   	pop    %esi
f0101af3:	5f                   	pop    %edi
f0101af4:	5d                   	pop    %ebp
f0101af5:	c3                   	ret    
f0101af6:	8d 76 00             	lea    0x0(%esi),%esi
f0101af9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101b00:	31 ff                	xor    %edi,%edi
f0101b02:	31 c0                	xor    %eax,%eax
f0101b04:	89 fa                	mov    %edi,%edx
f0101b06:	83 c4 1c             	add    $0x1c,%esp
f0101b09:	5b                   	pop    %ebx
f0101b0a:	5e                   	pop    %esi
f0101b0b:	5f                   	pop    %edi
f0101b0c:	5d                   	pop    %ebp
f0101b0d:	c3                   	ret    
f0101b0e:	66 90                	xchg   %ax,%ax
f0101b10:	31 ff                	xor    %edi,%edi
f0101b12:	89 e8                	mov    %ebp,%eax
f0101b14:	89 f2                	mov    %esi,%edx
f0101b16:	f7 f3                	div    %ebx
f0101b18:	89 fa                	mov    %edi,%edx
f0101b1a:	83 c4 1c             	add    $0x1c,%esp
f0101b1d:	5b                   	pop    %ebx
f0101b1e:	5e                   	pop    %esi
f0101b1f:	5f                   	pop    %edi
f0101b20:	5d                   	pop    %ebp
f0101b21:	c3                   	ret    
f0101b22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b28:	39 f2                	cmp    %esi,%edx
f0101b2a:	72 06                	jb     f0101b32 <__udivdi3+0x102>
f0101b2c:	31 c0                	xor    %eax,%eax
f0101b2e:	39 eb                	cmp    %ebp,%ebx
f0101b30:	77 d2                	ja     f0101b04 <__udivdi3+0xd4>
f0101b32:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b37:	eb cb                	jmp    f0101b04 <__udivdi3+0xd4>
f0101b39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b40:	89 d8                	mov    %ebx,%eax
f0101b42:	31 ff                	xor    %edi,%edi
f0101b44:	eb be                	jmp    f0101b04 <__udivdi3+0xd4>
f0101b46:	66 90                	xchg   %ax,%ax
f0101b48:	66 90                	xchg   %ax,%ax
f0101b4a:	66 90                	xchg   %ax,%ax
f0101b4c:	66 90                	xchg   %ax,%ax
f0101b4e:	66 90                	xchg   %ax,%ax

f0101b50 <__umoddi3>:
f0101b50:	55                   	push   %ebp
f0101b51:	57                   	push   %edi
f0101b52:	56                   	push   %esi
f0101b53:	53                   	push   %ebx
f0101b54:	83 ec 1c             	sub    $0x1c,%esp
f0101b57:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101b5b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101b5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101b63:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101b67:	85 ed                	test   %ebp,%ebp
f0101b69:	89 f0                	mov    %esi,%eax
f0101b6b:	89 da                	mov    %ebx,%edx
f0101b6d:	75 19                	jne    f0101b88 <__umoddi3+0x38>
f0101b6f:	39 df                	cmp    %ebx,%edi
f0101b71:	0f 86 b1 00 00 00    	jbe    f0101c28 <__umoddi3+0xd8>
f0101b77:	f7 f7                	div    %edi
f0101b79:	89 d0                	mov    %edx,%eax
f0101b7b:	31 d2                	xor    %edx,%edx
f0101b7d:	83 c4 1c             	add    $0x1c,%esp
f0101b80:	5b                   	pop    %ebx
f0101b81:	5e                   	pop    %esi
f0101b82:	5f                   	pop    %edi
f0101b83:	5d                   	pop    %ebp
f0101b84:	c3                   	ret    
f0101b85:	8d 76 00             	lea    0x0(%esi),%esi
f0101b88:	39 dd                	cmp    %ebx,%ebp
f0101b8a:	77 f1                	ja     f0101b7d <__umoddi3+0x2d>
f0101b8c:	0f bd cd             	bsr    %ebp,%ecx
f0101b8f:	83 f1 1f             	xor    $0x1f,%ecx
f0101b92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101b96:	0f 84 b4 00 00 00    	je     f0101c50 <__umoddi3+0x100>
f0101b9c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101ba1:	89 c2                	mov    %eax,%edx
f0101ba3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101ba7:	29 c2                	sub    %eax,%edx
f0101ba9:	89 c1                	mov    %eax,%ecx
f0101bab:	89 f8                	mov    %edi,%eax
f0101bad:	d3 e5                	shl    %cl,%ebp
f0101baf:	89 d1                	mov    %edx,%ecx
f0101bb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101bb5:	d3 e8                	shr    %cl,%eax
f0101bb7:	09 c5                	or     %eax,%ebp
f0101bb9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101bbd:	89 c1                	mov    %eax,%ecx
f0101bbf:	d3 e7                	shl    %cl,%edi
f0101bc1:	89 d1                	mov    %edx,%ecx
f0101bc3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101bc7:	89 df                	mov    %ebx,%edi
f0101bc9:	d3 ef                	shr    %cl,%edi
f0101bcb:	89 c1                	mov    %eax,%ecx
f0101bcd:	89 f0                	mov    %esi,%eax
f0101bcf:	d3 e3                	shl    %cl,%ebx
f0101bd1:	89 d1                	mov    %edx,%ecx
f0101bd3:	89 fa                	mov    %edi,%edx
f0101bd5:	d3 e8                	shr    %cl,%eax
f0101bd7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101bdc:	09 d8                	or     %ebx,%eax
f0101bde:	f7 f5                	div    %ebp
f0101be0:	d3 e6                	shl    %cl,%esi
f0101be2:	89 d1                	mov    %edx,%ecx
f0101be4:	f7 64 24 08          	mull   0x8(%esp)
f0101be8:	39 d1                	cmp    %edx,%ecx
f0101bea:	89 c3                	mov    %eax,%ebx
f0101bec:	89 d7                	mov    %edx,%edi
f0101bee:	72 06                	jb     f0101bf6 <__umoddi3+0xa6>
f0101bf0:	75 0e                	jne    f0101c00 <__umoddi3+0xb0>
f0101bf2:	39 c6                	cmp    %eax,%esi
f0101bf4:	73 0a                	jae    f0101c00 <__umoddi3+0xb0>
f0101bf6:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101bfa:	19 ea                	sbb    %ebp,%edx
f0101bfc:	89 d7                	mov    %edx,%edi
f0101bfe:	89 c3                	mov    %eax,%ebx
f0101c00:	89 ca                	mov    %ecx,%edx
f0101c02:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101c07:	29 de                	sub    %ebx,%esi
f0101c09:	19 fa                	sbb    %edi,%edx
f0101c0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101c0f:	89 d0                	mov    %edx,%eax
f0101c11:	d3 e0                	shl    %cl,%eax
f0101c13:	89 d9                	mov    %ebx,%ecx
f0101c15:	d3 ee                	shr    %cl,%esi
f0101c17:	d3 ea                	shr    %cl,%edx
f0101c19:	09 f0                	or     %esi,%eax
f0101c1b:	83 c4 1c             	add    $0x1c,%esp
f0101c1e:	5b                   	pop    %ebx
f0101c1f:	5e                   	pop    %esi
f0101c20:	5f                   	pop    %edi
f0101c21:	5d                   	pop    %ebp
f0101c22:	c3                   	ret    
f0101c23:	90                   	nop
f0101c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101c28:	85 ff                	test   %edi,%edi
f0101c2a:	89 f9                	mov    %edi,%ecx
f0101c2c:	75 0b                	jne    f0101c39 <__umoddi3+0xe9>
f0101c2e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c33:	31 d2                	xor    %edx,%edx
f0101c35:	f7 f7                	div    %edi
f0101c37:	89 c1                	mov    %eax,%ecx
f0101c39:	89 d8                	mov    %ebx,%eax
f0101c3b:	31 d2                	xor    %edx,%edx
f0101c3d:	f7 f1                	div    %ecx
f0101c3f:	89 f0                	mov    %esi,%eax
f0101c41:	f7 f1                	div    %ecx
f0101c43:	e9 31 ff ff ff       	jmp    f0101b79 <__umoddi3+0x29>
f0101c48:	90                   	nop
f0101c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c50:	39 dd                	cmp    %ebx,%ebp
f0101c52:	72 08                	jb     f0101c5c <__umoddi3+0x10c>
f0101c54:	39 f7                	cmp    %esi,%edi
f0101c56:	0f 87 21 ff ff ff    	ja     f0101b7d <__umoddi3+0x2d>
f0101c5c:	89 da                	mov    %ebx,%edx
f0101c5e:	89 f0                	mov    %esi,%eax
f0101c60:	29 f8                	sub    %edi,%eax
f0101c62:	19 ea                	sbb    %ebp,%edx
f0101c64:	e9 14 ff ff ff       	jmp    f0101b7d <__umoddi3+0x2d>
