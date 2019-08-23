
obj/kern/kernel:     file format elf32-i386


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
f0100057:	8d 83 18 07 ff ff    	lea    -0xf8e8(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 de 09 00 00       	call   f0100a41 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7e 29                	jle    f0100093 <test_backtrace+0x53>
		test_backtrace(x-1);
f010006a:	83 ec 0c             	sub    $0xc,%esp
f010006d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100070:	50                   	push   %eax
f0100071:	e8 ca ff ff ff       	call   f0100040 <test_backtrace>
f0100076:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 34 07 ff ff    	lea    -0xf8cc(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 b8 09 00 00       	call   f0100a41 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 00                	push   $0x0
f010009c:	e8 d4 07 00 00       	call   f0100875 <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

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
f01000ca:	e8 fc 14 00 00       	call   f01015cb <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 2f 05 00 00       	call   f0100603 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 4f 07 ff ff    	lea    -0xf8b1(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 59 09 00 00       	call   f0100a41 <cprintf>

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
f01000fc:	e8 7a 07 00 00       	call   f010087b <monitor>
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
f010012d:	e8 49 07 00 00       	call   f010087b <monitor>
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
f0100147:	8d 83 6a 07 ff ff    	lea    -0xf896(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 ee 08 00 00       	call   f0100a41 <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 ad 08 00 00       	call   f0100a0a <vcprintf>
	cprintf("\n");
f010015d:	8d 83 a6 07 ff ff    	lea    -0xf85a(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 d6 08 00 00       	call   f0100a41 <cprintf>
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
f010018c:	8d 83 82 07 ff ff    	lea    -0xf87e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 a9 08 00 00       	call   f0100a41 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 66 08 00 00       	call   f0100a0a <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 a6 07 ff ff    	lea    -0xf85a(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 8f 08 00 00       	call   f0100a41 <cprintf>
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

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c5:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c6:	a8 01                	test   $0x1,%al
f01001c8:	74 0a                	je     f01001d4 <serial_proc_data+0x14>
f01001ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001cf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d0:	0f b6 c0             	movzbl %al,%eax
f01001d3:	c3                   	ret    
		return -1;
f01001d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001d9:	c3                   	ret    

f01001da <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001da:	55                   	push   %ebp
f01001db:	89 e5                	mov    %esp,%ebp
f01001dd:	57                   	push   %edi
f01001de:	56                   	push   %esi
f01001df:	53                   	push   %ebx
f01001e0:	83 ec 1c             	sub    $0x1c,%esp
f01001e3:	e8 68 05 00 00       	call   f0100750 <__x86.get_pc_thunk.si>
f01001e8:	81 c6 20 11 01 00    	add    $0x11120,%esi
f01001ee:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001f0:	8d 1d 78 1d 00 00    	lea    0x1d78,%ebx
f01001f6:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001fc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100202:	ff d0                	call   *%eax
f0100204:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100207:	74 2b                	je     f0100234 <cons_intr+0x5a>
		if (c == 0)
f0100209:	85 c0                	test   %eax,%eax
f010020b:	74 f2                	je     f01001ff <cons_intr+0x25>
		cons.buf[cons.wpos++] = c;
f010020d:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100214:	8d 51 01             	lea    0x1(%ecx),%edx
f0100217:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010021a:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f010021d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100223:	b8 00 00 00 00       	mov    $0x0,%eax
f0100228:	0f 44 d0             	cmove  %eax,%edx
f010022b:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
f0100232:	eb cb                	jmp    f01001ff <cons_intr+0x25>
	}
}
f0100234:	83 c4 1c             	add    $0x1c,%esp
f0100237:	5b                   	pop    %ebx
f0100238:	5e                   	pop    %esi
f0100239:	5f                   	pop    %edi
f010023a:	5d                   	pop    %ebp
f010023b:	c3                   	ret    

f010023c <kbd_proc_data>:
{
f010023c:	55                   	push   %ebp
f010023d:	89 e5                	mov    %esp,%ebp
f010023f:	56                   	push   %esi
f0100240:	53                   	push   %ebx
f0100241:	e8 76 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100246:	81 c3 c2 10 01 00    	add    $0x110c2,%ebx
f010024c:	ba 64 00 00 00       	mov    $0x64,%edx
f0100251:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100252:	a8 01                	test   $0x1,%al
f0100254:	0f 84 fb 00 00 00    	je     f0100355 <kbd_proc_data+0x119>
	if (stat & KBS_TERR)
f010025a:	a8 20                	test   $0x20,%al
f010025c:	0f 85 fa 00 00 00    	jne    f010035c <kbd_proc_data+0x120>
f0100262:	ba 60 00 00 00       	mov    $0x60,%edx
f0100267:	ec                   	in     (%dx),%al
f0100268:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010026a:	3c e0                	cmp    $0xe0,%al
f010026c:	74 64                	je     f01002d2 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f010026e:	84 c0                	test   %al,%al
f0100270:	78 75                	js     f01002e7 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f0100272:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100278:	f6 c1 40             	test   $0x40,%cl
f010027b:	74 0e                	je     f010028b <kbd_proc_data+0x4f>
		data |= 0x80;
f010027d:	83 c8 80             	or     $0xffffff80,%eax
f0100280:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100282:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100285:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f010028b:	0f b6 d2             	movzbl %dl,%edx
f010028e:	0f b6 84 13 d8 08 ff 	movzbl -0xf728(%ebx,%edx,1),%eax
f0100295:	ff 
f0100296:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f010029c:	0f b6 8c 13 d8 07 ff 	movzbl -0xf828(%ebx,%edx,1),%ecx
f01002a3:	ff 
f01002a4:	31 c8                	xor    %ecx,%eax
f01002a6:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002ac:	89 c1                	mov    %eax,%ecx
f01002ae:	83 e1 03             	and    $0x3,%ecx
f01002b1:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002b8:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002bc:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002bf:	a8 08                	test   $0x8,%al
f01002c1:	74 65                	je     f0100328 <kbd_proc_data+0xec>
		if ('a' <= c && c <= 'z')
f01002c3:	89 f2                	mov    %esi,%edx
f01002c5:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002c8:	83 f9 19             	cmp    $0x19,%ecx
f01002cb:	77 4f                	ja     f010031c <kbd_proc_data+0xe0>
			c += 'A' - 'a';
f01002cd:	83 ee 20             	sub    $0x20,%esi
f01002d0:	eb 0c                	jmp    f01002de <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002d2:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002d9:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002de:	89 f0                	mov    %esi,%eax
f01002e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002e3:	5b                   	pop    %ebx
f01002e4:	5e                   	pop    %esi
f01002e5:	5d                   	pop    %ebp
f01002e6:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002e7:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f01002ed:	89 ce                	mov    %ecx,%esi
f01002ef:	83 e6 40             	and    $0x40,%esi
f01002f2:	83 e0 7f             	and    $0x7f,%eax
f01002f5:	85 f6                	test   %esi,%esi
f01002f7:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002fa:	0f b6 d2             	movzbl %dl,%edx
f01002fd:	0f b6 84 13 d8 08 ff 	movzbl -0xf728(%ebx,%edx,1),%eax
f0100304:	ff 
f0100305:	83 c8 40             	or     $0x40,%eax
f0100308:	0f b6 c0             	movzbl %al,%eax
f010030b:	f7 d0                	not    %eax
f010030d:	21 c8                	and    %ecx,%eax
f010030f:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100315:	be 00 00 00 00       	mov    $0x0,%esi
f010031a:	eb c2                	jmp    f01002de <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f010031c:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010031f:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100322:	83 fa 1a             	cmp    $0x1a,%edx
f0100325:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100328:	f7 d0                	not    %eax
f010032a:	a8 06                	test   $0x6,%al
f010032c:	75 b0                	jne    f01002de <kbd_proc_data+0xa2>
f010032e:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100334:	75 a8                	jne    f01002de <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f0100336:	83 ec 0c             	sub    $0xc,%esp
f0100339:	8d 83 9c 07 ff ff    	lea    -0xf864(%ebx),%eax
f010033f:	50                   	push   %eax
f0100340:	e8 fc 06 00 00       	call   f0100a41 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100345:	b8 03 00 00 00       	mov    $0x3,%eax
f010034a:	ba 92 00 00 00       	mov    $0x92,%edx
f010034f:	ee                   	out    %al,(%dx)
}
f0100350:	83 c4 10             	add    $0x10,%esp
f0100353:	eb 89                	jmp    f01002de <kbd_proc_data+0xa2>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb 82                	jmp    f01002de <kbd_proc_data+0xa2>
		return -1;
f010035c:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100361:	e9 78 ff ff ff       	jmp    f01002de <kbd_proc_data+0xa2>

f0100366 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100366:	55                   	push   %ebp
f0100367:	89 e5                	mov    %esp,%ebp
f0100369:	57                   	push   %edi
f010036a:	56                   	push   %esi
f010036b:	53                   	push   %ebx
f010036c:	83 ec 1c             	sub    $0x1c,%esp
f010036f:	e8 48 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100374:	81 c3 94 0f 01 00    	add    $0x10f94,%ebx
f010037a:	89 c7                	mov    %eax,%edi
	for (i = 0;
f010037c:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100381:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100386:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010038b:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010038c:	a8 20                	test   $0x20,%al
f010038e:	75 13                	jne    f01003a3 <cons_putc+0x3d>
f0100390:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100396:	7f 0b                	jg     f01003a3 <cons_putc+0x3d>
f0100398:	89 ca                	mov    %ecx,%edx
f010039a:	ec                   	in     (%dx),%al
f010039b:	ec                   	in     (%dx),%al
f010039c:	ec                   	in     (%dx),%al
f010039d:	ec                   	in     (%dx),%al
	     i++)
f010039e:	83 c6 01             	add    $0x1,%esi
f01003a1:	eb e3                	jmp    f0100386 <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f01003a3:	89 f8                	mov    %edi,%eax
f01003a5:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003ad:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003ae:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b8:	ba 79 03 00 00       	mov    $0x379,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003c4:	7f 0f                	jg     f01003d5 <cons_putc+0x6f>
f01003c6:	84 c0                	test   %al,%al
f01003c8:	78 0b                	js     f01003d5 <cons_putc+0x6f>
f01003ca:	89 ca                	mov    %ecx,%edx
f01003cc:	ec                   	in     (%dx),%al
f01003cd:	ec                   	in     (%dx),%al
f01003ce:	ec                   	in     (%dx),%al
f01003cf:	ec                   	in     (%dx),%al
f01003d0:	83 c6 01             	add    $0x1,%esi
f01003d3:	eb e3                	jmp    f01003b8 <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d5:	ba 78 03 00 00       	mov    $0x378,%edx
f01003da:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003de:	ee                   	out    %al,(%dx)
f01003df:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e9:	ee                   	out    %al,(%dx)
f01003ea:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ef:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003f0:	89 f8                	mov    %edi,%eax
f01003f2:	80 cc 07             	or     $0x7,%ah
f01003f5:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003fb:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f01003fe:	89 f8                	mov    %edi,%eax
f0100400:	0f b6 c0             	movzbl %al,%eax
f0100403:	89 f9                	mov    %edi,%ecx
f0100405:	80 f9 0a             	cmp    $0xa,%cl
f0100408:	0f 84 e2 00 00 00    	je     f01004f0 <cons_putc+0x18a>
f010040e:	83 f8 0a             	cmp    $0xa,%eax
f0100411:	7f 46                	jg     f0100459 <cons_putc+0xf3>
f0100413:	83 f8 08             	cmp    $0x8,%eax
f0100416:	0f 84 a8 00 00 00    	je     f01004c4 <cons_putc+0x15e>
f010041c:	83 f8 09             	cmp    $0x9,%eax
f010041f:	0f 85 d8 00 00 00    	jne    f01004fd <cons_putc+0x197>
		cons_putc(' ');
f0100425:	b8 20 00 00 00       	mov    $0x20,%eax
f010042a:	e8 37 ff ff ff       	call   f0100366 <cons_putc>
		cons_putc(' ');
f010042f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100434:	e8 2d ff ff ff       	call   f0100366 <cons_putc>
		cons_putc(' ');
f0100439:	b8 20 00 00 00       	mov    $0x20,%eax
f010043e:	e8 23 ff ff ff       	call   f0100366 <cons_putc>
		cons_putc(' ');
f0100443:	b8 20 00 00 00       	mov    $0x20,%eax
f0100448:	e8 19 ff ff ff       	call   f0100366 <cons_putc>
		cons_putc(' ');
f010044d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100452:	e8 0f ff ff ff       	call   f0100366 <cons_putc>
		break;
f0100457:	eb 26                	jmp    f010047f <cons_putc+0x119>
	switch (c & 0xff) {
f0100459:	83 f8 0d             	cmp    $0xd,%eax
f010045c:	0f 85 9b 00 00 00    	jne    f01004fd <cons_putc+0x197>
		crt_pos -= (crt_pos % CRT_COLS);
f0100462:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100469:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010046f:	c1 e8 16             	shr    $0x16,%eax
f0100472:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100475:	c1 e0 04             	shl    $0x4,%eax
f0100478:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f010047f:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f0100486:	cf 07 
f0100488:	0f 87 92 00 00 00    	ja     f0100520 <cons_putc+0x1ba>
	outb(addr_6845, 14);
f010048e:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f0100494:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100499:	89 ca                	mov    %ecx,%edx
f010049b:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010049c:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f01004a3:	8d 71 01             	lea    0x1(%ecx),%esi
f01004a6:	89 d8                	mov    %ebx,%eax
f01004a8:	66 c1 e8 08          	shr    $0x8,%ax
f01004ac:	89 f2                	mov    %esi,%edx
f01004ae:	ee                   	out    %al,(%dx)
f01004af:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004b4:	89 ca                	mov    %ecx,%edx
f01004b6:	ee                   	out    %al,(%dx)
f01004b7:	89 d8                	mov    %ebx,%eax
f01004b9:	89 f2                	mov    %esi,%edx
f01004bb:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004bf:	5b                   	pop    %ebx
f01004c0:	5e                   	pop    %esi
f01004c1:	5f                   	pop    %edi
f01004c2:	5d                   	pop    %ebp
f01004c3:	c3                   	ret    
		if (crt_pos > 0) {
f01004c4:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004cb:	66 85 c0             	test   %ax,%ax
f01004ce:	74 be                	je     f010048e <cons_putc+0x128>
			crt_pos--;
f01004d0:	83 e8 01             	sub    $0x1,%eax
f01004d3:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004da:	0f b7 c0             	movzwl %ax,%eax
f01004dd:	89 fa                	mov    %edi,%edx
f01004df:	b2 00                	mov    $0x0,%dl
f01004e1:	83 ca 20             	or     $0x20,%edx
f01004e4:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004ea:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004ee:	eb 8f                	jmp    f010047f <cons_putc+0x119>
		crt_pos += CRT_COLS;
f01004f0:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004f7:	50 
f01004f8:	e9 65 ff ff ff       	jmp    f0100462 <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004fd:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100504:	8d 50 01             	lea    0x1(%eax),%edx
f0100507:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f010050e:	0f b7 c0             	movzwl %ax,%eax
f0100511:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100517:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010051b:	e9 5f ff ff ff       	jmp    f010047f <cons_putc+0x119>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100520:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f0100526:	83 ec 04             	sub    $0x4,%esp
f0100529:	68 00 0f 00 00       	push   $0xf00
f010052e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100534:	52                   	push   %edx
f0100535:	50                   	push   %eax
f0100536:	e8 d8 10 00 00       	call   f0101613 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010053b:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100541:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100547:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010054d:	83 c4 10             	add    $0x10,%esp
f0100550:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100555:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100558:	39 d0                	cmp    %edx,%eax
f010055a:	75 f4                	jne    f0100550 <cons_putc+0x1ea>
		crt_pos -= CRT_COLS;
f010055c:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f0100563:	50 
f0100564:	e9 25 ff ff ff       	jmp    f010048e <cons_putc+0x128>

f0100569 <serial_intr>:
{
f0100569:	e8 de 01 00 00       	call   f010074c <__x86.get_pc_thunk.ax>
f010056e:	05 9a 0d 01 00       	add    $0x10d9a,%eax
	if (serial_exists)
f0100573:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f010057a:	75 01                	jne    f010057d <serial_intr+0x14>
f010057c:	c3                   	ret    
{
f010057d:	55                   	push   %ebp
f010057e:	89 e5                	mov    %esp,%ebp
f0100580:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100583:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100589:	e8 4c fc ff ff       	call   f01001da <cons_intr>
}
f010058e:	c9                   	leave  
f010058f:	c3                   	ret    

f0100590 <kbd_intr>:
{
f0100590:	55                   	push   %ebp
f0100591:	89 e5                	mov    %esp,%ebp
f0100593:	83 ec 08             	sub    $0x8,%esp
f0100596:	e8 b1 01 00 00       	call   f010074c <__x86.get_pc_thunk.ax>
f010059b:	05 6d 0d 01 00       	add    $0x10d6d,%eax
	cons_intr(kbd_proc_data);
f01005a0:	8d 80 34 ef fe ff    	lea    -0x110cc(%eax),%eax
f01005a6:	e8 2f fc ff ff       	call   f01001da <cons_intr>
}
f01005ab:	c9                   	leave  
f01005ac:	c3                   	ret    

f01005ad <cons_getc>:
{
f01005ad:	55                   	push   %ebp
f01005ae:	89 e5                	mov    %esp,%ebp
f01005b0:	53                   	push   %ebx
f01005b1:	83 ec 04             	sub    $0x4,%esp
f01005b4:	e8 03 fc ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005b9:	81 c3 4f 0d 01 00    	add    $0x10d4f,%ebx
	serial_intr();
f01005bf:	e8 a5 ff ff ff       	call   f0100569 <serial_intr>
	kbd_intr();
f01005c4:	e8 c7 ff ff ff       	call   f0100590 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005c9:	8b 83 78 1f 00 00    	mov    0x1f78(%ebx),%eax
	return 0;
f01005cf:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005d4:	3b 83 7c 1f 00 00    	cmp    0x1f7c(%ebx),%eax
f01005da:	74 1f                	je     f01005fb <cons_getc+0x4e>
		c = cons.buf[cons.rpos++];
f01005dc:	8d 48 01             	lea    0x1(%eax),%ecx
f01005df:	0f b6 94 03 78 1d 00 	movzbl 0x1d78(%ebx,%eax,1),%edx
f01005e6:	00 
			cons.rpos = 0;
f01005e7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f2:	0f 44 c8             	cmove  %eax,%ecx
f01005f5:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
}
f01005fb:	89 d0                	mov    %edx,%eax
f01005fd:	83 c4 04             	add    $0x4,%esp
f0100600:	5b                   	pop    %ebx
f0100601:	5d                   	pop    %ebp
f0100602:	c3                   	ret    

f0100603 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100603:	55                   	push   %ebp
f0100604:	89 e5                	mov    %esp,%ebp
f0100606:	57                   	push   %edi
f0100607:	56                   	push   %esi
f0100608:	53                   	push   %ebx
f0100609:	83 ec 1c             	sub    $0x1c,%esp
f010060c:	e8 ab fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100611:	81 c3 f7 0c 01 00    	add    $0x10cf7,%ebx
	was = *cp;
f0100617:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010061e:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100625:	5a a5 
	if (*cp != 0xA55A) {
f0100627:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010062e:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100632:	0f 84 bc 00 00 00    	je     f01006f4 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100638:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010063f:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100642:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100649:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010064f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100654:	89 fa                	mov    %edi,%edx
f0100656:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100657:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010065a:	89 ca                	mov    %ecx,%edx
f010065c:	ec                   	in     (%dx),%al
f010065d:	0f b6 f0             	movzbl %al,%esi
f0100660:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100663:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100668:	89 fa                	mov    %edi,%edx
f010066a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010066b:	89 ca                	mov    %ecx,%edx
f010066d:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100671:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100677:	0f b6 c0             	movzbl %al,%eax
f010067a:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010067c:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100683:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100688:	89 c8                	mov    %ecx,%eax
f010068a:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010068f:	ee                   	out    %al,(%dx)
f0100690:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100695:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010069a:	89 fa                	mov    %edi,%edx
f010069c:	ee                   	out    %al,(%dx)
f010069d:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006a2:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006a7:	ee                   	out    %al,(%dx)
f01006a8:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006ad:	89 c8                	mov    %ecx,%eax
f01006af:	89 f2                	mov    %esi,%edx
f01006b1:	ee                   	out    %al,(%dx)
f01006b2:	b8 03 00 00 00       	mov    $0x3,%eax
f01006b7:	89 fa                	mov    %edi,%edx
f01006b9:	ee                   	out    %al,(%dx)
f01006ba:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006bf:	89 c8                	mov    %ecx,%eax
f01006c1:	ee                   	out    %al,(%dx)
f01006c2:	b8 01 00 00 00       	mov    $0x1,%eax
f01006c7:	89 f2                	mov    %esi,%edx
f01006c9:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ca:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006cf:	ec                   	in     (%dx),%al
f01006d0:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006d2:	3c ff                	cmp    $0xff,%al
f01006d4:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006db:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006e0:	ec                   	in     (%dx),%al
f01006e1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006e6:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006e7:	80 f9 ff             	cmp    $0xff,%cl
f01006ea:	74 25                	je     f0100711 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006ef:	5b                   	pop    %ebx
f01006f0:	5e                   	pop    %esi
f01006f1:	5f                   	pop    %edi
f01006f2:	5d                   	pop    %ebp
f01006f3:	c3                   	ret    
		*cp = was;
f01006f4:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006fb:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100702:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100705:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010070c:	e9 38 ff ff ff       	jmp    f0100649 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f0100711:	83 ec 0c             	sub    $0xc,%esp
f0100714:	8d 83 a8 07 ff ff    	lea    -0xf858(%ebx),%eax
f010071a:	50                   	push   %eax
f010071b:	e8 21 03 00 00       	call   f0100a41 <cprintf>
f0100720:	83 c4 10             	add    $0x10,%esp
}
f0100723:	eb c7                	jmp    f01006ec <cons_init+0xe9>

f0100725 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100725:	55                   	push   %ebp
f0100726:	89 e5                	mov    %esp,%ebp
f0100728:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010072b:	8b 45 08             	mov    0x8(%ebp),%eax
f010072e:	e8 33 fc ff ff       	call   f0100366 <cons_putc>
}
f0100733:	c9                   	leave  
f0100734:	c3                   	ret    

f0100735 <getchar>:

int
getchar(void)
{
f0100735:	55                   	push   %ebp
f0100736:	89 e5                	mov    %esp,%ebp
f0100738:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010073b:	e8 6d fe ff ff       	call   f01005ad <cons_getc>
f0100740:	85 c0                	test   %eax,%eax
f0100742:	74 f7                	je     f010073b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100744:	c9                   	leave  
f0100745:	c3                   	ret    

f0100746 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100746:	b8 01 00 00 00       	mov    $0x1,%eax
f010074b:	c3                   	ret    

f010074c <__x86.get_pc_thunk.ax>:
f010074c:	8b 04 24             	mov    (%esp),%eax
f010074f:	c3                   	ret    

f0100750 <__x86.get_pc_thunk.si>:
f0100750:	8b 34 24             	mov    (%esp),%esi
f0100753:	c3                   	ret    

f0100754 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
f0100757:	56                   	push   %esi
f0100758:	53                   	push   %ebx
f0100759:	e8 5e fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010075e:	81 c3 aa 0b 01 00    	add    $0x10baa,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100764:	83 ec 04             	sub    $0x4,%esp
f0100767:	8d 83 d8 09 ff ff    	lea    -0xf628(%ebx),%eax
f010076d:	50                   	push   %eax
f010076e:	8d 83 f6 09 ff ff    	lea    -0xf60a(%ebx),%eax
f0100774:	50                   	push   %eax
f0100775:	8d b3 fb 09 ff ff    	lea    -0xf605(%ebx),%esi
f010077b:	56                   	push   %esi
f010077c:	e8 c0 02 00 00       	call   f0100a41 <cprintf>
f0100781:	83 c4 0c             	add    $0xc,%esp
f0100784:	8d 83 64 0a ff ff    	lea    -0xf59c(%ebx),%eax
f010078a:	50                   	push   %eax
f010078b:	8d 83 04 0a ff ff    	lea    -0xf5fc(%ebx),%eax
f0100791:	50                   	push   %eax
f0100792:	56                   	push   %esi
f0100793:	e8 a9 02 00 00       	call   f0100a41 <cprintf>
	return 0;
}
f0100798:	b8 00 00 00 00       	mov    $0x0,%eax
f010079d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007a0:	5b                   	pop    %ebx
f01007a1:	5e                   	pop    %esi
f01007a2:	5d                   	pop    %ebp
f01007a3:	c3                   	ret    

f01007a4 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007a4:	55                   	push   %ebp
f01007a5:	89 e5                	mov    %esp,%ebp
f01007a7:	57                   	push   %edi
f01007a8:	56                   	push   %esi
f01007a9:	53                   	push   %ebx
f01007aa:	83 ec 18             	sub    $0x18,%esp
f01007ad:	e8 0a fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007b2:	81 c3 56 0b 01 00    	add    $0x10b56,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007b8:	8d 83 0d 0a ff ff    	lea    -0xf5f3(%ebx),%eax
f01007be:	50                   	push   %eax
f01007bf:	e8 7d 02 00 00       	call   f0100a41 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007c4:	83 c4 08             	add    $0x8,%esp
f01007c7:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007cd:	8d 83 8c 0a ff ff    	lea    -0xf574(%ebx),%eax
f01007d3:	50                   	push   %eax
f01007d4:	e8 68 02 00 00       	call   f0100a41 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007d9:	83 c4 0c             	add    $0xc,%esp
f01007dc:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007e2:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007e8:	50                   	push   %eax
f01007e9:	57                   	push   %edi
f01007ea:	8d 83 b4 0a ff ff    	lea    -0xf54c(%ebx),%eax
f01007f0:	50                   	push   %eax
f01007f1:	e8 4b 02 00 00       	call   f0100a41 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007f6:	83 c4 0c             	add    $0xc,%esp
f01007f9:	c7 c0 1d 1a 10 f0    	mov    $0xf0101a1d,%eax
f01007ff:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100805:	52                   	push   %edx
f0100806:	50                   	push   %eax
f0100807:	8d 83 d8 0a ff ff    	lea    -0xf528(%ebx),%eax
f010080d:	50                   	push   %eax
f010080e:	e8 2e 02 00 00       	call   f0100a41 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100813:	83 c4 0c             	add    $0xc,%esp
f0100816:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010081c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100822:	52                   	push   %edx
f0100823:	50                   	push   %eax
f0100824:	8d 83 fc 0a ff ff    	lea    -0xf504(%ebx),%eax
f010082a:	50                   	push   %eax
f010082b:	e8 11 02 00 00       	call   f0100a41 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100830:	83 c4 0c             	add    $0xc,%esp
f0100833:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f0100839:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010083f:	50                   	push   %eax
f0100840:	56                   	push   %esi
f0100841:	8d 83 20 0b ff ff    	lea    -0xf4e0(%ebx),%eax
f0100847:	50                   	push   %eax
f0100848:	e8 f4 01 00 00       	call   f0100a41 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010084d:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100850:	29 fe                	sub    %edi,%esi
f0100852:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100858:	c1 fe 0a             	sar    $0xa,%esi
f010085b:	56                   	push   %esi
f010085c:	8d 83 44 0b ff ff    	lea    -0xf4bc(%ebx),%eax
f0100862:	50                   	push   %eax
f0100863:	e8 d9 01 00 00       	call   f0100a41 <cprintf>
	return 0;
}
f0100868:	b8 00 00 00 00       	mov    $0x0,%eax
f010086d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100870:	5b                   	pop    %ebx
f0100871:	5e                   	pop    %esi
f0100872:	5f                   	pop    %edi
f0100873:	5d                   	pop    %ebp
f0100874:	c3                   	ret    

f0100875 <mon_backtrace>:
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	return 0;
}
f0100875:	b8 00 00 00 00       	mov    $0x0,%eax
f010087a:	c3                   	ret    

f010087b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010087b:	55                   	push   %ebp
f010087c:	89 e5                	mov    %esp,%ebp
f010087e:	57                   	push   %edi
f010087f:	56                   	push   %esi
f0100880:	53                   	push   %ebx
f0100881:	83 ec 68             	sub    $0x68,%esp
f0100884:	e8 33 f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100889:	81 c3 7f 0a 01 00    	add    $0x10a7f,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010088f:	8d 83 70 0b ff ff    	lea    -0xf490(%ebx),%eax
f0100895:	50                   	push   %eax
f0100896:	e8 a6 01 00 00       	call   f0100a41 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010089b:	8d 83 94 0b ff ff    	lea    -0xf46c(%ebx),%eax
f01008a1:	89 04 24             	mov    %eax,(%esp)
f01008a4:	e8 98 01 00 00       	call   f0100a41 <cprintf>
f01008a9:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01008ac:	8d 83 2a 0a ff ff    	lea    -0xf5d6(%ebx),%eax
f01008b2:	89 45 a0             	mov    %eax,-0x60(%ebp)
f01008b5:	e9 dc 00 00 00       	jmp    f0100996 <monitor+0x11b>
f01008ba:	83 ec 08             	sub    $0x8,%esp
f01008bd:	0f be c0             	movsbl %al,%eax
f01008c0:	50                   	push   %eax
f01008c1:	ff 75 a0             	pushl  -0x60(%ebp)
f01008c4:	e8 c5 0c 00 00       	call   f010158e <strchr>
f01008c9:	83 c4 10             	add    $0x10,%esp
f01008cc:	85 c0                	test   %eax,%eax
f01008ce:	74 74                	je     f0100944 <monitor+0xc9>
			*buf++ = 0;
f01008d0:	c6 06 00             	movb   $0x0,(%esi)
f01008d3:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f01008d6:	8d 76 01             	lea    0x1(%esi),%esi
f01008d9:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f01008dc:	0f b6 06             	movzbl (%esi),%eax
f01008df:	84 c0                	test   %al,%al
f01008e1:	75 d7                	jne    f01008ba <monitor+0x3f>
	argv[argc] = 0;
f01008e3:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f01008ea:	00 
	if (argc == 0)
f01008eb:	85 ff                	test   %edi,%edi
f01008ed:	0f 84 a3 00 00 00    	je     f0100996 <monitor+0x11b>
		if (strcmp(argv[0], commands[i].name) == 0)
f01008f3:	83 ec 08             	sub    $0x8,%esp
f01008f6:	8d 83 f6 09 ff ff    	lea    -0xf60a(%ebx),%eax
f01008fc:	50                   	push   %eax
f01008fd:	ff 75 a8             	pushl  -0x58(%ebp)
f0100900:	e8 2b 0c 00 00       	call   f0101530 <strcmp>
f0100905:	83 c4 10             	add    $0x10,%esp
f0100908:	85 c0                	test   %eax,%eax
f010090a:	0f 84 b4 00 00 00    	je     f01009c4 <monitor+0x149>
f0100910:	83 ec 08             	sub    $0x8,%esp
f0100913:	8d 83 04 0a ff ff    	lea    -0xf5fc(%ebx),%eax
f0100919:	50                   	push   %eax
f010091a:	ff 75 a8             	pushl  -0x58(%ebp)
f010091d:	e8 0e 0c 00 00       	call   f0101530 <strcmp>
f0100922:	83 c4 10             	add    $0x10,%esp
f0100925:	85 c0                	test   %eax,%eax
f0100927:	0f 84 92 00 00 00    	je     f01009bf <monitor+0x144>
	cprintf("Unknown command '%s'\n", argv[0]);
f010092d:	83 ec 08             	sub    $0x8,%esp
f0100930:	ff 75 a8             	pushl  -0x58(%ebp)
f0100933:	8d 83 4c 0a ff ff    	lea    -0xf5b4(%ebx),%eax
f0100939:	50                   	push   %eax
f010093a:	e8 02 01 00 00       	call   f0100a41 <cprintf>
	return 0;
f010093f:	83 c4 10             	add    $0x10,%esp
f0100942:	eb 52                	jmp    f0100996 <monitor+0x11b>
		if (*buf == 0)
f0100944:	80 3e 00             	cmpb   $0x0,(%esi)
f0100947:	74 9a                	je     f01008e3 <monitor+0x68>
		if (argc == MAXARGS-1) {
f0100949:	83 ff 0f             	cmp    $0xf,%edi
f010094c:	74 34                	je     f0100982 <monitor+0x107>
		argv[argc++] = buf;
f010094e:	8d 47 01             	lea    0x1(%edi),%eax
f0100951:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100954:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100958:	0f b6 06             	movzbl (%esi),%eax
f010095b:	84 c0                	test   %al,%al
f010095d:	0f 84 76 ff ff ff    	je     f01008d9 <monitor+0x5e>
f0100963:	83 ec 08             	sub    $0x8,%esp
f0100966:	0f be c0             	movsbl %al,%eax
f0100969:	50                   	push   %eax
f010096a:	ff 75 a0             	pushl  -0x60(%ebp)
f010096d:	e8 1c 0c 00 00       	call   f010158e <strchr>
f0100972:	83 c4 10             	add    $0x10,%esp
f0100975:	85 c0                	test   %eax,%eax
f0100977:	0f 85 5c ff ff ff    	jne    f01008d9 <monitor+0x5e>
			buf++;
f010097d:	83 c6 01             	add    $0x1,%esi
f0100980:	eb d6                	jmp    f0100958 <monitor+0xdd>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100982:	83 ec 08             	sub    $0x8,%esp
f0100985:	6a 10                	push   $0x10
f0100987:	8d 83 2f 0a ff ff    	lea    -0xf5d1(%ebx),%eax
f010098d:	50                   	push   %eax
f010098e:	e8 ae 00 00 00       	call   f0100a41 <cprintf>
			return 0;
f0100993:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100996:	8d bb 26 0a ff ff    	lea    -0xf5da(%ebx),%edi
f010099c:	83 ec 0c             	sub    $0xc,%esp
f010099f:	57                   	push   %edi
f01009a0:	e8 9c 09 00 00       	call   f0101341 <readline>
f01009a5:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009a7:	83 c4 10             	add    $0x10,%esp
f01009aa:	85 c0                	test   %eax,%eax
f01009ac:	74 ee                	je     f010099c <monitor+0x121>
	argv[argc] = 0;
f01009ae:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009b5:	bf 00 00 00 00       	mov    $0x0,%edi
f01009ba:	e9 1d ff ff ff       	jmp    f01008dc <monitor+0x61>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009bf:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f01009c4:	83 ec 04             	sub    $0x4,%esp
f01009c7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01009ca:	ff 75 08             	pushl  0x8(%ebp)
f01009cd:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009d0:	52                   	push   %edx
f01009d1:	57                   	push   %edi
f01009d2:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f01009d9:	83 c4 10             	add    $0x10,%esp
f01009dc:	85 c0                	test   %eax,%eax
f01009de:	79 b6                	jns    f0100996 <monitor+0x11b>
				break;
	}
}
f01009e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009e3:	5b                   	pop    %ebx
f01009e4:	5e                   	pop    %esi
f01009e5:	5f                   	pop    %edi
f01009e6:	5d                   	pop    %ebp
f01009e7:	c3                   	ret    

f01009e8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009e8:	55                   	push   %ebp
f01009e9:	89 e5                	mov    %esp,%ebp
f01009eb:	53                   	push   %ebx
f01009ec:	83 ec 10             	sub    $0x10,%esp
f01009ef:	e8 c8 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01009f4:	81 c3 14 09 01 00    	add    $0x10914,%ebx
	cputchar(ch);
f01009fa:	ff 75 08             	pushl  0x8(%ebp)
f01009fd:	e8 23 fd ff ff       	call   f0100725 <cputchar>
	*cnt++;
}
f0100a02:	83 c4 10             	add    $0x10,%esp
f0100a05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a08:	c9                   	leave  
f0100a09:	c3                   	ret    

f0100a0a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100a0a:	55                   	push   %ebp
f0100a0b:	89 e5                	mov    %esp,%ebp
f0100a0d:	53                   	push   %ebx
f0100a0e:	83 ec 14             	sub    $0x14,%esp
f0100a11:	e8 a6 f7 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100a16:	81 c3 f2 08 01 00    	add    $0x108f2,%ebx
	int cnt = 0;
f0100a1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100a23:	ff 75 0c             	pushl  0xc(%ebp)
f0100a26:	ff 75 08             	pushl  0x8(%ebp)
f0100a29:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100a2c:	50                   	push   %eax
f0100a2d:	8d 83 e0 f6 fe ff    	lea    -0x10920(%ebx),%eax
f0100a33:	50                   	push   %eax
f0100a34:	e8 17 04 00 00       	call   f0100e50 <vprintfmt>
	return cnt;
}
f0100a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a3f:	c9                   	leave  
f0100a40:	c3                   	ret    

f0100a41 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100a41:	55                   	push   %ebp
f0100a42:	89 e5                	mov    %esp,%ebp
f0100a44:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100a47:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100a4a:	50                   	push   %eax
f0100a4b:	ff 75 08             	pushl  0x8(%ebp)
f0100a4e:	e8 b7 ff ff ff       	call   f0100a0a <vcprintf>
	va_end(ap);

	return cnt;
}
f0100a53:	c9                   	leave  
f0100a54:	c3                   	ret    

f0100a55 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100a55:	55                   	push   %ebp
f0100a56:	89 e5                	mov    %esp,%ebp
f0100a58:	57                   	push   %edi
f0100a59:	56                   	push   %esi
f0100a5a:	53                   	push   %ebx
f0100a5b:	83 ec 14             	sub    $0x14,%esp
f0100a5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100a61:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100a64:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a67:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a6a:	8b 1a                	mov    (%edx),%ebx
f0100a6c:	8b 01                	mov    (%ecx),%eax
f0100a6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a71:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100a78:	eb 23                	jmp    f0100a9d <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a7a:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100a7d:	eb 1e                	jmp    f0100a9d <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a7f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a82:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a85:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a89:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100a8c:	73 46                	jae    f0100ad4 <stab_binsearch+0x7f>
			*region_left = m;
f0100a8e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a91:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a93:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100a96:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100a9d:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100aa0:	7f 5f                	jg     f0100b01 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100aa5:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100aa8:	89 d0                	mov    %edx,%eax
f0100aaa:	c1 e8 1f             	shr    $0x1f,%eax
f0100aad:	01 d0                	add    %edx,%eax
f0100aaf:	89 c7                	mov    %eax,%edi
f0100ab1:	d1 ff                	sar    %edi
f0100ab3:	83 e0 fe             	and    $0xfffffffe,%eax
f0100ab6:	01 f8                	add    %edi,%eax
f0100ab8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100abb:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100abf:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100ac1:	39 c3                	cmp    %eax,%ebx
f0100ac3:	7f b5                	jg     f0100a7a <stab_binsearch+0x25>
f0100ac5:	0f b6 0a             	movzbl (%edx),%ecx
f0100ac8:	83 ea 0c             	sub    $0xc,%edx
f0100acb:	39 f1                	cmp    %esi,%ecx
f0100acd:	74 b0                	je     f0100a7f <stab_binsearch+0x2a>
			m--;
f0100acf:	83 e8 01             	sub    $0x1,%eax
f0100ad2:	eb ed                	jmp    f0100ac1 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0100ad4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100ad7:	76 14                	jbe    f0100aed <stab_binsearch+0x98>
			*region_right = m - 1;
f0100ad9:	83 e8 01             	sub    $0x1,%eax
f0100adc:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100adf:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100ae2:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100ae4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100aeb:	eb b0                	jmp    f0100a9d <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100aed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100af0:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100af2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100af6:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100af8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100aff:	eb 9c                	jmp    f0100a9d <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100b01:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100b05:	75 15                	jne    f0100b1c <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100b07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b0a:	8b 00                	mov    (%eax),%eax
f0100b0c:	83 e8 01             	sub    $0x1,%eax
f0100b0f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100b12:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100b14:	83 c4 14             	add    $0x14,%esp
f0100b17:	5b                   	pop    %ebx
f0100b18:	5e                   	pop    %esi
f0100b19:	5f                   	pop    %edi
f0100b1a:	5d                   	pop    %ebp
f0100b1b:	c3                   	ret    
		for (l = *region_right;
f0100b1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b1f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100b21:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b24:	8b 0f                	mov    (%edi),%ecx
f0100b26:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b29:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100b2c:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100b30:	eb 03                	jmp    f0100b35 <stab_binsearch+0xe0>
		     l--)
f0100b32:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100b35:	39 c1                	cmp    %eax,%ecx
f0100b37:	7d 0a                	jge    f0100b43 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0100b39:	0f b6 1a             	movzbl (%edx),%ebx
f0100b3c:	83 ea 0c             	sub    $0xc,%edx
f0100b3f:	39 f3                	cmp    %esi,%ebx
f0100b41:	75 ef                	jne    f0100b32 <stab_binsearch+0xdd>
		*region_left = l;
f0100b43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b46:	89 07                	mov    %eax,(%edi)
}
f0100b48:	eb ca                	jmp    f0100b14 <stab_binsearch+0xbf>

f0100b4a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100b4a:	55                   	push   %ebp
f0100b4b:	89 e5                	mov    %esp,%ebp
f0100b4d:	57                   	push   %edi
f0100b4e:	56                   	push   %esi
f0100b4f:	53                   	push   %ebx
f0100b50:	83 ec 2c             	sub    $0x2c,%esp
f0100b53:	e8 fc 01 00 00       	call   f0100d54 <__x86.get_pc_thunk.cx>
f0100b58:	81 c1 b0 07 01 00    	add    $0x107b0,%ecx
f0100b5e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100b61:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100b64:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b67:	8d 81 bc 0b ff ff    	lea    -0xf444(%ecx),%eax
f0100b6d:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0100b6f:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0100b76:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0100b79:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0100b80:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0100b83:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b8a:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0100b90:	0f 86 f4 00 00 00    	jbe    f0100c8a <debuginfo_eip+0x140>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b96:	c7 c0 71 63 10 f0    	mov    $0xf0106371,%eax
f0100b9c:	39 81 fc ff ff ff    	cmp    %eax,-0x4(%ecx)
f0100ba2:	0f 86 88 01 00 00    	jbe    f0100d30 <debuginfo_eip+0x1e6>
f0100ba8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100bab:	c7 c0 ef 7c 10 f0    	mov    $0xf0107cef,%eax
f0100bb1:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100bb5:	0f 85 7c 01 00 00    	jne    f0100d37 <debuginfo_eip+0x1ed>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100bbb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100bc2:	c7 c0 e0 20 10 f0    	mov    $0xf01020e0,%eax
f0100bc8:	c7 c2 70 63 10 f0    	mov    $0xf0106370,%edx
f0100bce:	29 c2                	sub    %eax,%edx
f0100bd0:	c1 fa 02             	sar    $0x2,%edx
f0100bd3:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100bd9:	83 ea 01             	sub    $0x1,%edx
f0100bdc:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100bdf:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100be2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100be5:	83 ec 08             	sub    $0x8,%esp
f0100be8:	53                   	push   %ebx
f0100be9:	6a 64                	push   $0x64
f0100beb:	e8 65 fe ff ff       	call   f0100a55 <stab_binsearch>
	if (lfile == 0)
f0100bf0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bf3:	83 c4 10             	add    $0x10,%esp
f0100bf6:	85 c0                	test   %eax,%eax
f0100bf8:	0f 84 40 01 00 00    	je     f0100d3e <debuginfo_eip+0x1f4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100bfe:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100c01:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c04:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100c07:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100c0a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c0d:	83 ec 08             	sub    $0x8,%esp
f0100c10:	53                   	push   %ebx
f0100c11:	6a 24                	push   $0x24
f0100c13:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0100c16:	c7 c0 e0 20 10 f0    	mov    $0xf01020e0,%eax
f0100c1c:	e8 34 fe ff ff       	call   f0100a55 <stab_binsearch>

	if (lfun <= rfun) {
f0100c21:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100c24:	83 c4 10             	add    $0x10,%esp
f0100c27:	3b 75 d8             	cmp    -0x28(%ebp),%esi
f0100c2a:	7f 79                	jg     f0100ca5 <debuginfo_eip+0x15b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100c2c:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c2f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c32:	c7 c2 e0 20 10 f0    	mov    $0xf01020e0,%edx
f0100c38:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100c3b:	8b 11                	mov    (%ecx),%edx
f0100c3d:	c7 c0 ef 7c 10 f0    	mov    $0xf0107cef,%eax
f0100c43:	81 e8 71 63 10 f0    	sub    $0xf0106371,%eax
f0100c49:	39 c2                	cmp    %eax,%edx
f0100c4b:	73 09                	jae    f0100c56 <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c4d:	81 c2 71 63 10 f0    	add    $0xf0106371,%edx
f0100c53:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c56:	8b 41 08             	mov    0x8(%ecx),%eax
f0100c59:	89 47 10             	mov    %eax,0x10(%edi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c5c:	83 ec 08             	sub    $0x8,%esp
f0100c5f:	6a 3a                	push   $0x3a
f0100c61:	ff 77 08             	pushl  0x8(%edi)
f0100c64:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c67:	e8 43 09 00 00       	call   f01015af <strfind>
f0100c6c:	2b 47 08             	sub    0x8(%edi),%eax
f0100c6f:	89 47 0c             	mov    %eax,0xc(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c72:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100c75:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100c78:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100c7b:	c7 c2 e0 20 10 f0    	mov    $0xf01020e0,%edx
f0100c81:	8d 44 82 04          	lea    0x4(%edx,%eax,4),%eax
f0100c85:	83 c4 10             	add    $0x10,%esp
f0100c88:	eb 29                	jmp    f0100cb3 <debuginfo_eip+0x169>
  	        panic("User address");
f0100c8a:	83 ec 04             	sub    $0x4,%esp
f0100c8d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c90:	8d 83 c6 0b ff ff    	lea    -0xf43a(%ebx),%eax
f0100c96:	50                   	push   %eax
f0100c97:	6a 7f                	push   $0x7f
f0100c99:	8d 83 d3 0b ff ff    	lea    -0xf42d(%ebx),%eax
f0100c9f:	50                   	push   %eax
f0100ca0:	e8 61 f4 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100ca5:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0100ca8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100cab:	eb af                	jmp    f0100c5c <debuginfo_eip+0x112>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100cad:	83 ee 01             	sub    $0x1,%esi
f0100cb0:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100cb3:	39 f3                	cmp    %esi,%ebx
f0100cb5:	7f 3a                	jg     f0100cf1 <debuginfo_eip+0x1a7>
	       && stabs[lline].n_type != N_SOL
f0100cb7:	0f b6 10             	movzbl (%eax),%edx
f0100cba:	80 fa 84             	cmp    $0x84,%dl
f0100cbd:	74 0b                	je     f0100cca <debuginfo_eip+0x180>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100cbf:	80 fa 64             	cmp    $0x64,%dl
f0100cc2:	75 e9                	jne    f0100cad <debuginfo_eip+0x163>
f0100cc4:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100cc8:	74 e3                	je     f0100cad <debuginfo_eip+0x163>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100cca:	8d 14 76             	lea    (%esi,%esi,2),%edx
f0100ccd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cd0:	c7 c0 e0 20 10 f0    	mov    $0xf01020e0,%eax
f0100cd6:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100cd9:	c7 c0 ef 7c 10 f0    	mov    $0xf0107cef,%eax
f0100cdf:	81 e8 71 63 10 f0    	sub    $0xf0106371,%eax
f0100ce5:	39 c2                	cmp    %eax,%edx
f0100ce7:	73 08                	jae    f0100cf1 <debuginfo_eip+0x1a7>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100ce9:	81 c2 71 63 10 f0    	add    $0xf0106371,%edx
f0100cef:	89 17                	mov    %edx,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cf1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cf4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cf7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0100cfc:	39 c8                	cmp    %ecx,%eax
f0100cfe:	7d 4a                	jge    f0100d4a <debuginfo_eip+0x200>
		for (lline = lfun + 1;
f0100d00:	8d 50 01             	lea    0x1(%eax),%edx
f0100d03:	8d 1c 40             	lea    (%eax,%eax,2),%ebx
f0100d06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d09:	c7 c0 e0 20 10 f0    	mov    $0xf01020e0,%eax
f0100d0f:	8d 44 98 10          	lea    0x10(%eax,%ebx,4),%eax
f0100d13:	eb 07                	jmp    f0100d1c <debuginfo_eip+0x1d2>
			info->eip_fn_narg++;
f0100d15:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0100d19:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f0100d1c:	39 d1                	cmp    %edx,%ecx
f0100d1e:	74 25                	je     f0100d45 <debuginfo_eip+0x1fb>
f0100d20:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100d23:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100d27:	74 ec                	je     f0100d15 <debuginfo_eip+0x1cb>
	return 0;
f0100d29:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d2e:	eb 1a                	jmp    f0100d4a <debuginfo_eip+0x200>
		return -1;
f0100d30:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100d35:	eb 13                	jmp    f0100d4a <debuginfo_eip+0x200>
f0100d37:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100d3c:	eb 0c                	jmp    f0100d4a <debuginfo_eip+0x200>
		return -1;
f0100d3e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100d43:	eb 05                	jmp    f0100d4a <debuginfo_eip+0x200>
	return 0;
f0100d45:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d4a:	89 d0                	mov    %edx,%eax
f0100d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d4f:	5b                   	pop    %ebx
f0100d50:	5e                   	pop    %esi
f0100d51:	5f                   	pop    %edi
f0100d52:	5d                   	pop    %ebp
f0100d53:	c3                   	ret    

f0100d54 <__x86.get_pc_thunk.cx>:
f0100d54:	8b 0c 24             	mov    (%esp),%ecx
f0100d57:	c3                   	ret    

f0100d58 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d58:	55                   	push   %ebp
f0100d59:	89 e5                	mov    %esp,%ebp
f0100d5b:	57                   	push   %edi
f0100d5c:	56                   	push   %esi
f0100d5d:	53                   	push   %ebx
f0100d5e:	83 ec 2c             	sub    $0x2c,%esp
f0100d61:	e8 ee ff ff ff       	call   f0100d54 <__x86.get_pc_thunk.cx>
f0100d66:	81 c1 a2 05 01 00    	add    $0x105a2,%ecx
f0100d6c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100d6f:	89 c7                	mov    %eax,%edi
f0100d71:	89 d6                	mov    %edx,%esi
f0100d73:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d76:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d79:	89 d1                	mov    %edx,%ecx
f0100d7b:	89 c2                	mov    %eax,%edx
f0100d7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d80:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100d83:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d86:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d89:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d8c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100d93:	39 c2                	cmp    %eax,%edx
f0100d95:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100d98:	72 41                	jb     f0100ddb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d9a:	83 ec 0c             	sub    $0xc,%esp
f0100d9d:	ff 75 18             	pushl  0x18(%ebp)
f0100da0:	83 eb 01             	sub    $0x1,%ebx
f0100da3:	53                   	push   %ebx
f0100da4:	50                   	push   %eax
f0100da5:	83 ec 08             	sub    $0x8,%esp
f0100da8:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100dab:	ff 75 e0             	pushl  -0x20(%ebp)
f0100dae:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100db1:	ff 75 d0             	pushl  -0x30(%ebp)
f0100db4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100db7:	e8 04 0a 00 00       	call   f01017c0 <__udivdi3>
f0100dbc:	83 c4 18             	add    $0x18,%esp
f0100dbf:	52                   	push   %edx
f0100dc0:	50                   	push   %eax
f0100dc1:	89 f2                	mov    %esi,%edx
f0100dc3:	89 f8                	mov    %edi,%eax
f0100dc5:	e8 8e ff ff ff       	call   f0100d58 <printnum>
f0100dca:	83 c4 20             	add    $0x20,%esp
f0100dcd:	eb 13                	jmp    f0100de2 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100dcf:	83 ec 08             	sub    $0x8,%esp
f0100dd2:	56                   	push   %esi
f0100dd3:	ff 75 18             	pushl  0x18(%ebp)
f0100dd6:	ff d7                	call   *%edi
f0100dd8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100ddb:	83 eb 01             	sub    $0x1,%ebx
f0100dde:	85 db                	test   %ebx,%ebx
f0100de0:	7f ed                	jg     f0100dcf <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100de2:	83 ec 08             	sub    $0x8,%esp
f0100de5:	56                   	push   %esi
f0100de6:	83 ec 04             	sub    $0x4,%esp
f0100de9:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100dec:	ff 75 e0             	pushl  -0x20(%ebp)
f0100def:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100df2:	ff 75 d0             	pushl  -0x30(%ebp)
f0100df5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100df8:	e8 d3 0a 00 00       	call   f01018d0 <__umoddi3>
f0100dfd:	83 c4 14             	add    $0x14,%esp
f0100e00:	0f be 84 03 e1 0b ff 	movsbl -0xf41f(%ebx,%eax,1),%eax
f0100e07:	ff 
f0100e08:	50                   	push   %eax
f0100e09:	ff d7                	call   *%edi
}
f0100e0b:	83 c4 10             	add    $0x10,%esp
f0100e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e11:	5b                   	pop    %ebx
f0100e12:	5e                   	pop    %esi
f0100e13:	5f                   	pop    %edi
f0100e14:	5d                   	pop    %ebp
f0100e15:	c3                   	ret    

f0100e16 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e16:	55                   	push   %ebp
f0100e17:	89 e5                	mov    %esp,%ebp
f0100e19:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e1c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100e20:	8b 10                	mov    (%eax),%edx
f0100e22:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e25:	73 0a                	jae    f0100e31 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100e27:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100e2a:	89 08                	mov    %ecx,(%eax)
f0100e2c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e2f:	88 02                	mov    %al,(%edx)
}
f0100e31:	5d                   	pop    %ebp
f0100e32:	c3                   	ret    

f0100e33 <printfmt>:
{
f0100e33:	55                   	push   %ebp
f0100e34:	89 e5                	mov    %esp,%ebp
f0100e36:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100e39:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e3c:	50                   	push   %eax
f0100e3d:	ff 75 10             	pushl  0x10(%ebp)
f0100e40:	ff 75 0c             	pushl  0xc(%ebp)
f0100e43:	ff 75 08             	pushl  0x8(%ebp)
f0100e46:	e8 05 00 00 00       	call   f0100e50 <vprintfmt>
}
f0100e4b:	83 c4 10             	add    $0x10,%esp
f0100e4e:	c9                   	leave  
f0100e4f:	c3                   	ret    

f0100e50 <vprintfmt>:
{
f0100e50:	55                   	push   %ebp
f0100e51:	89 e5                	mov    %esp,%ebp
f0100e53:	57                   	push   %edi
f0100e54:	56                   	push   %esi
f0100e55:	53                   	push   %ebx
f0100e56:	83 ec 3c             	sub    $0x3c,%esp
f0100e59:	e8 ee f8 ff ff       	call   f010074c <__x86.get_pc_thunk.ax>
f0100e5e:	05 aa 04 01 00       	add    $0x104aa,%eax
f0100e63:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e66:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e69:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100e6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100e6f:	8d 80 20 1d 00 00    	lea    0x1d20(%eax),%eax
f0100e75:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100e78:	e9 94 03 00 00       	jmp    f0101211 <.L25+0x48>
		padc = ' ';
f0100e7d:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0100e81:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0100e88:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0100e8f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f0100e96:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e9b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100e9e:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100ea1:	8d 43 01             	lea    0x1(%ebx),%eax
f0100ea4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100ea7:	0f b6 13             	movzbl (%ebx),%edx
f0100eaa:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100ead:	3c 55                	cmp    $0x55,%al
f0100eaf:	0f 87 e8 03 00 00    	ja     f010129d <.L20>
f0100eb5:	0f b6 c0             	movzbl %al,%eax
f0100eb8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ebb:	89 ce                	mov    %ecx,%esi
f0100ebd:	03 b4 81 70 0c ff ff 	add    -0xf390(%ecx,%eax,4),%esi
f0100ec4:	ff e6                	jmp    *%esi

f0100ec6 <.L66>:
f0100ec6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0100ec9:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0100ecd:	eb d2                	jmp    f0100ea1 <vprintfmt+0x51>

f0100ecf <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0100ecf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100ed2:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0100ed6:	eb c9                	jmp    f0100ea1 <vprintfmt+0x51>

f0100ed8 <.L31>:
f0100ed8:	0f b6 d2             	movzbl %dl,%edx
f0100edb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0100ede:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ee3:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0100ee6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100ee9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100eed:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0100ef0:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100ef3:	83 f9 09             	cmp    $0x9,%ecx
f0100ef6:	77 58                	ja     f0100f50 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0100ef8:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0100efb:	eb e9                	jmp    f0100ee6 <.L31+0xe>

f0100efd <.L34>:
			precision = va_arg(ap, int);
f0100efd:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f00:	8b 00                	mov    (%eax),%eax
f0100f02:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f05:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f08:	8d 40 04             	lea    0x4(%eax),%eax
f0100f0b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f0e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0100f11:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100f15:	79 8a                	jns    f0100ea1 <vprintfmt+0x51>
				width = precision, precision = -1;
f0100f17:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f1a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f1d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0100f24:	e9 78 ff ff ff       	jmp    f0100ea1 <vprintfmt+0x51>

f0100f29 <.L33>:
f0100f29:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100f2c:	85 c0                	test   %eax,%eax
f0100f2e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f33:	0f 49 d0             	cmovns %eax,%edx
f0100f36:	89 55 d0             	mov    %edx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f39:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0100f3c:	e9 60 ff ff ff       	jmp    f0100ea1 <vprintfmt+0x51>

f0100f41 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0100f41:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0100f44:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0100f4b:	e9 51 ff ff ff       	jmp    f0100ea1 <vprintfmt+0x51>
f0100f50:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f53:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f56:	eb b9                	jmp    f0100f11 <.L34+0x14>

f0100f58 <.L27>:
			lflag++;
f0100f58:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f5c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0100f5f:	e9 3d ff ff ff       	jmp    f0100ea1 <vprintfmt+0x51>

f0100f64 <.L30>:
f0100f64:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0100f67:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f6a:	8d 58 04             	lea    0x4(%eax),%ebx
f0100f6d:	83 ec 08             	sub    $0x8,%esp
f0100f70:	57                   	push   %edi
f0100f71:	ff 30                	pushl  (%eax)
f0100f73:	ff d6                	call   *%esi
			break;
f0100f75:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100f78:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0100f7b:	e9 8e 02 00 00       	jmp    f010120e <.L25+0x45>

f0100f80 <.L28>:
f0100f80:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f0100f83:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f86:	8d 58 04             	lea    0x4(%eax),%ebx
f0100f89:	8b 00                	mov    (%eax),%eax
f0100f8b:	99                   	cltd   
f0100f8c:	31 d0                	xor    %edx,%eax
f0100f8e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f90:	83 f8 06             	cmp    $0x6,%eax
f0100f93:	7f 27                	jg     f0100fbc <.L28+0x3c>
f0100f95:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100f98:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0100f9b:	85 d2                	test   %edx,%edx
f0100f9d:	74 1d                	je     f0100fbc <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f0100f9f:	52                   	push   %edx
f0100fa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fa3:	8d 80 02 0c ff ff    	lea    -0xf3fe(%eax),%eax
f0100fa9:	50                   	push   %eax
f0100faa:	57                   	push   %edi
f0100fab:	56                   	push   %esi
f0100fac:	e8 82 fe ff ff       	call   f0100e33 <printfmt>
f0100fb1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100fb4:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0100fb7:	e9 52 02 00 00       	jmp    f010120e <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0100fbc:	50                   	push   %eax
f0100fbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fc0:	8d 80 f9 0b ff ff    	lea    -0xf407(%eax),%eax
f0100fc6:	50                   	push   %eax
f0100fc7:	57                   	push   %edi
f0100fc8:	56                   	push   %esi
f0100fc9:	e8 65 fe ff ff       	call   f0100e33 <printfmt>
f0100fce:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100fd1:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100fd4:	e9 35 02 00 00       	jmp    f010120e <.L25+0x45>

f0100fd9 <.L24>:
f0100fd9:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f0100fdc:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fdf:	83 c0 04             	add    $0x4,%eax
f0100fe2:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0100fe5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fe8:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0100fea:	85 d2                	test   %edx,%edx
f0100fec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100fef:	8d 80 f2 0b ff ff    	lea    -0xf40e(%eax),%eax
f0100ff5:	0f 45 c2             	cmovne %edx,%eax
f0100ff8:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0100ffb:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100fff:	7e 06                	jle    f0101007 <.L24+0x2e>
f0101001:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0101005:	75 0d                	jne    f0101014 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101007:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010100a:	89 c3                	mov    %eax,%ebx
f010100c:	03 45 d0             	add    -0x30(%ebp),%eax
f010100f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101012:	eb 58                	jmp    f010106c <.L24+0x93>
f0101014:	83 ec 08             	sub    $0x8,%esp
f0101017:	ff 75 d8             	pushl  -0x28(%ebp)
f010101a:	ff 75 c8             	pushl  -0x38(%ebp)
f010101d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101020:	e8 39 04 00 00       	call   f010145e <strnlen>
f0101025:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101028:	29 c2                	sub    %eax,%edx
f010102a:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010102d:	83 c4 10             	add    $0x10,%esp
f0101030:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0101032:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101036:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101039:	85 db                	test   %ebx,%ebx
f010103b:	7e 11                	jle    f010104e <.L24+0x75>
					putch(padc, putdat);
f010103d:	83 ec 08             	sub    $0x8,%esp
f0101040:	57                   	push   %edi
f0101041:	ff 75 d0             	pushl  -0x30(%ebp)
f0101044:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101046:	83 eb 01             	sub    $0x1,%ebx
f0101049:	83 c4 10             	add    $0x10,%esp
f010104c:	eb eb                	jmp    f0101039 <.L24+0x60>
f010104e:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0101051:	85 d2                	test   %edx,%edx
f0101053:	b8 00 00 00 00       	mov    $0x0,%eax
f0101058:	0f 49 c2             	cmovns %edx,%eax
f010105b:	29 c2                	sub    %eax,%edx
f010105d:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101060:	eb a5                	jmp    f0101007 <.L24+0x2e>
					putch(ch, putdat);
f0101062:	83 ec 08             	sub    $0x8,%esp
f0101065:	57                   	push   %edi
f0101066:	52                   	push   %edx
f0101067:	ff d6                	call   *%esi
f0101069:	83 c4 10             	add    $0x10,%esp
f010106c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010106f:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101071:	83 c3 01             	add    $0x1,%ebx
f0101074:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101078:	0f be d0             	movsbl %al,%edx
f010107b:	85 d2                	test   %edx,%edx
f010107d:	74 4b                	je     f01010ca <.L24+0xf1>
f010107f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101083:	78 06                	js     f010108b <.L24+0xb2>
f0101085:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101089:	78 1e                	js     f01010a9 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f010108b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010108f:	74 d1                	je     f0101062 <.L24+0x89>
f0101091:	0f be c0             	movsbl %al,%eax
f0101094:	83 e8 20             	sub    $0x20,%eax
f0101097:	83 f8 5e             	cmp    $0x5e,%eax
f010109a:	76 c6                	jbe    f0101062 <.L24+0x89>
					putch('?', putdat);
f010109c:	83 ec 08             	sub    $0x8,%esp
f010109f:	57                   	push   %edi
f01010a0:	6a 3f                	push   $0x3f
f01010a2:	ff d6                	call   *%esi
f01010a4:	83 c4 10             	add    $0x10,%esp
f01010a7:	eb c3                	jmp    f010106c <.L24+0x93>
f01010a9:	89 cb                	mov    %ecx,%ebx
f01010ab:	eb 0e                	jmp    f01010bb <.L24+0xe2>
				putch(' ', putdat);
f01010ad:	83 ec 08             	sub    $0x8,%esp
f01010b0:	57                   	push   %edi
f01010b1:	6a 20                	push   $0x20
f01010b3:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01010b5:	83 eb 01             	sub    $0x1,%ebx
f01010b8:	83 c4 10             	add    $0x10,%esp
f01010bb:	85 db                	test   %ebx,%ebx
f01010bd:	7f ee                	jg     f01010ad <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01010bf:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01010c2:	89 45 14             	mov    %eax,0x14(%ebp)
f01010c5:	e9 44 01 00 00       	jmp    f010120e <.L25+0x45>
f01010ca:	89 cb                	mov    %ecx,%ebx
f01010cc:	eb ed                	jmp    f01010bb <.L24+0xe2>

f01010ce <.L29>:
f01010ce:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01010d1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01010d4:	83 f9 01             	cmp    $0x1,%ecx
f01010d7:	7f 1b                	jg     f01010f4 <.L29+0x26>
	else if (lflag)
f01010d9:	85 c9                	test   %ecx,%ecx
f01010db:	74 63                	je     f0101140 <.L29+0x72>
		return va_arg(*ap, long);
f01010dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e0:	8b 00                	mov    (%eax),%eax
f01010e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010e5:	99                   	cltd   
f01010e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ec:	8d 40 04             	lea    0x4(%eax),%eax
f01010ef:	89 45 14             	mov    %eax,0x14(%ebp)
f01010f2:	eb 17                	jmp    f010110b <.L29+0x3d>
		return va_arg(*ap, long long);
f01010f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f7:	8b 50 04             	mov    0x4(%eax),%edx
f01010fa:	8b 00                	mov    (%eax),%eax
f01010fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101102:	8b 45 14             	mov    0x14(%ebp),%eax
f0101105:	8d 40 08             	lea    0x8(%eax),%eax
f0101108:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010110b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010110e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0101111:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0101116:	85 c9                	test   %ecx,%ecx
f0101118:	0f 89 d6 00 00 00    	jns    f01011f4 <.L25+0x2b>
				putch('-', putdat);
f010111e:	83 ec 08             	sub    $0x8,%esp
f0101121:	57                   	push   %edi
f0101122:	6a 2d                	push   $0x2d
f0101124:	ff d6                	call   *%esi
				num = -(long long) num;
f0101126:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101129:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010112c:	f7 da                	neg    %edx
f010112e:	83 d1 00             	adc    $0x0,%ecx
f0101131:	f7 d9                	neg    %ecx
f0101133:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101136:	b8 0a 00 00 00       	mov    $0xa,%eax
f010113b:	e9 b4 00 00 00       	jmp    f01011f4 <.L25+0x2b>
		return va_arg(*ap, int);
f0101140:	8b 45 14             	mov    0x14(%ebp),%eax
f0101143:	8b 00                	mov    (%eax),%eax
f0101145:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101148:	99                   	cltd   
f0101149:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010114c:	8b 45 14             	mov    0x14(%ebp),%eax
f010114f:	8d 40 04             	lea    0x4(%eax),%eax
f0101152:	89 45 14             	mov    %eax,0x14(%ebp)
f0101155:	eb b4                	jmp    f010110b <.L29+0x3d>

f0101157 <.L23>:
f0101157:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010115a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010115d:	83 f9 01             	cmp    $0x1,%ecx
f0101160:	7f 1b                	jg     f010117d <.L23+0x26>
	else if (lflag)
f0101162:	85 c9                	test   %ecx,%ecx
f0101164:	74 2c                	je     f0101192 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f0101166:	8b 45 14             	mov    0x14(%ebp),%eax
f0101169:	8b 10                	mov    (%eax),%edx
f010116b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101170:	8d 40 04             	lea    0x4(%eax),%eax
f0101173:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101176:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f010117b:	eb 77                	jmp    f01011f4 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010117d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101180:	8b 10                	mov    (%eax),%edx
f0101182:	8b 48 04             	mov    0x4(%eax),%ecx
f0101185:	8d 40 08             	lea    0x8(%eax),%eax
f0101188:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010118b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0101190:	eb 62                	jmp    f01011f4 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101192:	8b 45 14             	mov    0x14(%ebp),%eax
f0101195:	8b 10                	mov    (%eax),%edx
f0101197:	b9 00 00 00 00       	mov    $0x0,%ecx
f010119c:	8d 40 04             	lea    0x4(%eax),%eax
f010119f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01011a2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f01011a7:	eb 4b                	jmp    f01011f4 <.L25+0x2b>

f01011a9 <.L26>:
f01011a9:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('X', putdat);
f01011ac:	83 ec 08             	sub    $0x8,%esp
f01011af:	57                   	push   %edi
f01011b0:	6a 58                	push   $0x58
f01011b2:	ff d6                	call   *%esi
			putch('X', putdat);
f01011b4:	83 c4 08             	add    $0x8,%esp
f01011b7:	57                   	push   %edi
f01011b8:	6a 58                	push   $0x58
f01011ba:	ff d6                	call   *%esi
			putch('X', putdat);
f01011bc:	83 c4 08             	add    $0x8,%esp
f01011bf:	57                   	push   %edi
f01011c0:	6a 58                	push   $0x58
f01011c2:	ff d6                	call   *%esi
			break;
f01011c4:	83 c4 10             	add    $0x10,%esp
f01011c7:	eb 45                	jmp    f010120e <.L25+0x45>

f01011c9 <.L25>:
f01011c9:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f01011cc:	83 ec 08             	sub    $0x8,%esp
f01011cf:	57                   	push   %edi
f01011d0:	6a 30                	push   $0x30
f01011d2:	ff d6                	call   *%esi
			putch('x', putdat);
f01011d4:	83 c4 08             	add    $0x8,%esp
f01011d7:	57                   	push   %edi
f01011d8:	6a 78                	push   $0x78
f01011da:	ff d6                	call   *%esi
			num = (unsigned long long)
f01011dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01011df:	8b 10                	mov    (%eax),%edx
f01011e1:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01011e6:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01011e9:	8d 40 04             	lea    0x4(%eax),%eax
f01011ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01011ef:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01011f4:	83 ec 0c             	sub    $0xc,%esp
f01011f7:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f01011fb:	53                   	push   %ebx
f01011fc:	ff 75 d0             	pushl  -0x30(%ebp)
f01011ff:	50                   	push   %eax
f0101200:	51                   	push   %ecx
f0101201:	52                   	push   %edx
f0101202:	89 fa                	mov    %edi,%edx
f0101204:	89 f0                	mov    %esi,%eax
f0101206:	e8 4d fb ff ff       	call   f0100d58 <printnum>
			break;
f010120b:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f010120e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101211:	83 c3 01             	add    $0x1,%ebx
f0101214:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101218:	83 f8 25             	cmp    $0x25,%eax
f010121b:	0f 84 5c fc ff ff    	je     f0100e7d <vprintfmt+0x2d>
			if (ch == '\0')
f0101221:	85 c0                	test   %eax,%eax
f0101223:	0f 84 97 00 00 00    	je     f01012c0 <.L20+0x23>
			putch(ch, putdat);
f0101229:	83 ec 08             	sub    $0x8,%esp
f010122c:	57                   	push   %edi
f010122d:	50                   	push   %eax
f010122e:	ff d6                	call   *%esi
f0101230:	83 c4 10             	add    $0x10,%esp
f0101233:	eb dc                	jmp    f0101211 <.L25+0x48>

f0101235 <.L21>:
f0101235:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101238:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010123b:	83 f9 01             	cmp    $0x1,%ecx
f010123e:	7f 1b                	jg     f010125b <.L21+0x26>
	else if (lflag)
f0101240:	85 c9                	test   %ecx,%ecx
f0101242:	74 2c                	je     f0101270 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0101244:	8b 45 14             	mov    0x14(%ebp),%eax
f0101247:	8b 10                	mov    (%eax),%edx
f0101249:	b9 00 00 00 00       	mov    $0x0,%ecx
f010124e:	8d 40 04             	lea    0x4(%eax),%eax
f0101251:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101254:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0101259:	eb 99                	jmp    f01011f4 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010125b:	8b 45 14             	mov    0x14(%ebp),%eax
f010125e:	8b 10                	mov    (%eax),%edx
f0101260:	8b 48 04             	mov    0x4(%eax),%ecx
f0101263:	8d 40 08             	lea    0x8(%eax),%eax
f0101266:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101269:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f010126e:	eb 84                	jmp    f01011f4 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101270:	8b 45 14             	mov    0x14(%ebp),%eax
f0101273:	8b 10                	mov    (%eax),%edx
f0101275:	b9 00 00 00 00       	mov    $0x0,%ecx
f010127a:	8d 40 04             	lea    0x4(%eax),%eax
f010127d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101280:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0101285:	e9 6a ff ff ff       	jmp    f01011f4 <.L25+0x2b>

f010128a <.L35>:
f010128a:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f010128d:	83 ec 08             	sub    $0x8,%esp
f0101290:	57                   	push   %edi
f0101291:	6a 25                	push   $0x25
f0101293:	ff d6                	call   *%esi
			break;
f0101295:	83 c4 10             	add    $0x10,%esp
f0101298:	e9 71 ff ff ff       	jmp    f010120e <.L25+0x45>

f010129d <.L20>:
f010129d:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f01012a0:	83 ec 08             	sub    $0x8,%esp
f01012a3:	57                   	push   %edi
f01012a4:	6a 25                	push   $0x25
f01012a6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01012a8:	83 c4 10             	add    $0x10,%esp
f01012ab:	89 d8                	mov    %ebx,%eax
f01012ad:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01012b1:	74 05                	je     f01012b8 <.L20+0x1b>
f01012b3:	83 e8 01             	sub    $0x1,%eax
f01012b6:	eb f5                	jmp    f01012ad <.L20+0x10>
f01012b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01012bb:	e9 4e ff ff ff       	jmp    f010120e <.L25+0x45>
}
f01012c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012c3:	5b                   	pop    %ebx
f01012c4:	5e                   	pop    %esi
f01012c5:	5f                   	pop    %edi
f01012c6:	5d                   	pop    %ebp
f01012c7:	c3                   	ret    

f01012c8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01012c8:	55                   	push   %ebp
f01012c9:	89 e5                	mov    %esp,%ebp
f01012cb:	53                   	push   %ebx
f01012cc:	83 ec 14             	sub    $0x14,%esp
f01012cf:	e8 e8 ee ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01012d4:	81 c3 34 00 01 00    	add    $0x10034,%ebx
f01012da:	8b 45 08             	mov    0x8(%ebp),%eax
f01012dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01012e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01012e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01012e7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01012ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01012f1:	85 c0                	test   %eax,%eax
f01012f3:	74 2b                	je     f0101320 <vsnprintf+0x58>
f01012f5:	85 d2                	test   %edx,%edx
f01012f7:	7e 27                	jle    f0101320 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01012f9:	ff 75 14             	pushl  0x14(%ebp)
f01012fc:	ff 75 10             	pushl  0x10(%ebp)
f01012ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101302:	50                   	push   %eax
f0101303:	8d 83 0e fb fe ff    	lea    -0x104f2(%ebx),%eax
f0101309:	50                   	push   %eax
f010130a:	e8 41 fb ff ff       	call   f0100e50 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010130f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101312:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101315:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101318:	83 c4 10             	add    $0x10,%esp
}
f010131b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010131e:	c9                   	leave  
f010131f:	c3                   	ret    
		return -E_INVAL;
f0101320:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101325:	eb f4                	jmp    f010131b <vsnprintf+0x53>

f0101327 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101327:	55                   	push   %ebp
f0101328:	89 e5                	mov    %esp,%ebp
f010132a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010132d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101330:	50                   	push   %eax
f0101331:	ff 75 10             	pushl  0x10(%ebp)
f0101334:	ff 75 0c             	pushl  0xc(%ebp)
f0101337:	ff 75 08             	pushl  0x8(%ebp)
f010133a:	e8 89 ff ff ff       	call   f01012c8 <vsnprintf>
	va_end(ap);

	return rc;
}
f010133f:	c9                   	leave  
f0101340:	c3                   	ret    

f0101341 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101341:	55                   	push   %ebp
f0101342:	89 e5                	mov    %esp,%ebp
f0101344:	57                   	push   %edi
f0101345:	56                   	push   %esi
f0101346:	53                   	push   %ebx
f0101347:	83 ec 1c             	sub    $0x1c,%esp
f010134a:	e8 6d ee ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010134f:	81 c3 b9 ff 00 00    	add    $0xffb9,%ebx
f0101355:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101358:	85 c0                	test   %eax,%eax
f010135a:	74 13                	je     f010136f <readline+0x2e>
		cprintf("%s", prompt);
f010135c:	83 ec 08             	sub    $0x8,%esp
f010135f:	50                   	push   %eax
f0101360:	8d 83 02 0c ff ff    	lea    -0xf3fe(%ebx),%eax
f0101366:	50                   	push   %eax
f0101367:	e8 d5 f6 ff ff       	call   f0100a41 <cprintf>
f010136c:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010136f:	83 ec 0c             	sub    $0xc,%esp
f0101372:	6a 00                	push   $0x0
f0101374:	e8 cd f3 ff ff       	call   f0100746 <iscons>
f0101379:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010137c:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010137f:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0101384:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f010138a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010138d:	eb 51                	jmp    f01013e0 <readline+0x9f>
			cprintf("read error: %e\n", c);
f010138f:	83 ec 08             	sub    $0x8,%esp
f0101392:	50                   	push   %eax
f0101393:	8d 83 c8 0d ff ff    	lea    -0xf238(%ebx),%eax
f0101399:	50                   	push   %eax
f010139a:	e8 a2 f6 ff ff       	call   f0100a41 <cprintf>
			return NULL;
f010139f:	83 c4 10             	add    $0x10,%esp
f01013a2:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01013a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013aa:	5b                   	pop    %ebx
f01013ab:	5e                   	pop    %esi
f01013ac:	5f                   	pop    %edi
f01013ad:	5d                   	pop    %ebp
f01013ae:	c3                   	ret    
			if (echoing)
f01013af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01013b3:	75 05                	jne    f01013ba <readline+0x79>
			i--;
f01013b5:	83 ef 01             	sub    $0x1,%edi
f01013b8:	eb 26                	jmp    f01013e0 <readline+0x9f>
				cputchar('\b');
f01013ba:	83 ec 0c             	sub    $0xc,%esp
f01013bd:	6a 08                	push   $0x8
f01013bf:	e8 61 f3 ff ff       	call   f0100725 <cputchar>
f01013c4:	83 c4 10             	add    $0x10,%esp
f01013c7:	eb ec                	jmp    f01013b5 <readline+0x74>
				cputchar(c);
f01013c9:	83 ec 0c             	sub    $0xc,%esp
f01013cc:	56                   	push   %esi
f01013cd:	e8 53 f3 ff ff       	call   f0100725 <cputchar>
f01013d2:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01013d5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01013d8:	89 f0                	mov    %esi,%eax
f01013da:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01013dd:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01013e0:	e8 50 f3 ff ff       	call   f0100735 <getchar>
f01013e5:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01013e7:	85 c0                	test   %eax,%eax
f01013e9:	78 a4                	js     f010138f <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01013eb:	83 f8 08             	cmp    $0x8,%eax
f01013ee:	0f 94 c2             	sete   %dl
f01013f1:	83 f8 7f             	cmp    $0x7f,%eax
f01013f4:	0f 94 c0             	sete   %al
f01013f7:	08 c2                	or     %al,%dl
f01013f9:	74 04                	je     f01013ff <readline+0xbe>
f01013fb:	85 ff                	test   %edi,%edi
f01013fd:	7f b0                	jg     f01013af <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01013ff:	83 fe 1f             	cmp    $0x1f,%esi
f0101402:	7e 10                	jle    f0101414 <readline+0xd3>
f0101404:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f010140a:	7f 08                	jg     f0101414 <readline+0xd3>
			if (echoing)
f010140c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101410:	74 c3                	je     f01013d5 <readline+0x94>
f0101412:	eb b5                	jmp    f01013c9 <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f0101414:	83 fe 0a             	cmp    $0xa,%esi
f0101417:	74 05                	je     f010141e <readline+0xdd>
f0101419:	83 fe 0d             	cmp    $0xd,%esi
f010141c:	75 c2                	jne    f01013e0 <readline+0x9f>
			if (echoing)
f010141e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101422:	75 13                	jne    f0101437 <readline+0xf6>
			buf[i] = 0;
f0101424:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f010142b:	00 
			return buf;
f010142c:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101432:	e9 70 ff ff ff       	jmp    f01013a7 <readline+0x66>
				cputchar('\n');
f0101437:	83 ec 0c             	sub    $0xc,%esp
f010143a:	6a 0a                	push   $0xa
f010143c:	e8 e4 f2 ff ff       	call   f0100725 <cputchar>
f0101441:	83 c4 10             	add    $0x10,%esp
f0101444:	eb de                	jmp    f0101424 <readline+0xe3>

f0101446 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101446:	55                   	push   %ebp
f0101447:	89 e5                	mov    %esp,%ebp
f0101449:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010144c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101451:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101455:	74 05                	je     f010145c <strlen+0x16>
		n++;
f0101457:	83 c0 01             	add    $0x1,%eax
f010145a:	eb f5                	jmp    f0101451 <strlen+0xb>
	return n;
}
f010145c:	5d                   	pop    %ebp
f010145d:	c3                   	ret    

f010145e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010145e:	55                   	push   %ebp
f010145f:	89 e5                	mov    %esp,%ebp
f0101461:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101464:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101467:	b8 00 00 00 00       	mov    $0x0,%eax
f010146c:	39 d0                	cmp    %edx,%eax
f010146e:	74 0d                	je     f010147d <strnlen+0x1f>
f0101470:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101474:	74 05                	je     f010147b <strnlen+0x1d>
		n++;
f0101476:	83 c0 01             	add    $0x1,%eax
f0101479:	eb f1                	jmp    f010146c <strnlen+0xe>
f010147b:	89 c2                	mov    %eax,%edx
	return n;
}
f010147d:	89 d0                	mov    %edx,%eax
f010147f:	5d                   	pop    %ebp
f0101480:	c3                   	ret    

f0101481 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101481:	55                   	push   %ebp
f0101482:	89 e5                	mov    %esp,%ebp
f0101484:	53                   	push   %ebx
f0101485:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101488:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010148b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101490:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0101494:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0101497:	83 c0 01             	add    $0x1,%eax
f010149a:	84 d2                	test   %dl,%dl
f010149c:	75 f2                	jne    f0101490 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010149e:	89 c8                	mov    %ecx,%eax
f01014a0:	5b                   	pop    %ebx
f01014a1:	5d                   	pop    %ebp
f01014a2:	c3                   	ret    

f01014a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01014a3:	55                   	push   %ebp
f01014a4:	89 e5                	mov    %esp,%ebp
f01014a6:	53                   	push   %ebx
f01014a7:	83 ec 10             	sub    $0x10,%esp
f01014aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01014ad:	53                   	push   %ebx
f01014ae:	e8 93 ff ff ff       	call   f0101446 <strlen>
f01014b3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01014b6:	ff 75 0c             	pushl  0xc(%ebp)
f01014b9:	01 d8                	add    %ebx,%eax
f01014bb:	50                   	push   %eax
f01014bc:	e8 c0 ff ff ff       	call   f0101481 <strcpy>
	return dst;
}
f01014c1:	89 d8                	mov    %ebx,%eax
f01014c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014c6:	c9                   	leave  
f01014c7:	c3                   	ret    

f01014c8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01014c8:	55                   	push   %ebp
f01014c9:	89 e5                	mov    %esp,%ebp
f01014cb:	56                   	push   %esi
f01014cc:	53                   	push   %ebx
f01014cd:	8b 75 08             	mov    0x8(%ebp),%esi
f01014d0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014d3:	89 f3                	mov    %esi,%ebx
f01014d5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01014d8:	89 f0                	mov    %esi,%eax
f01014da:	39 d8                	cmp    %ebx,%eax
f01014dc:	74 11                	je     f01014ef <strncpy+0x27>
		*dst++ = *src;
f01014de:	83 c0 01             	add    $0x1,%eax
f01014e1:	0f b6 0a             	movzbl (%edx),%ecx
f01014e4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01014e7:	80 f9 01             	cmp    $0x1,%cl
f01014ea:	83 da ff             	sbb    $0xffffffff,%edx
f01014ed:	eb eb                	jmp    f01014da <strncpy+0x12>
	}
	return ret;
}
f01014ef:	89 f0                	mov    %esi,%eax
f01014f1:	5b                   	pop    %ebx
f01014f2:	5e                   	pop    %esi
f01014f3:	5d                   	pop    %ebp
f01014f4:	c3                   	ret    

f01014f5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01014f5:	55                   	push   %ebp
f01014f6:	89 e5                	mov    %esp,%ebp
f01014f8:	56                   	push   %esi
f01014f9:	53                   	push   %ebx
f01014fa:	8b 75 08             	mov    0x8(%ebp),%esi
f01014fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101500:	8b 55 10             	mov    0x10(%ebp),%edx
f0101503:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101505:	85 d2                	test   %edx,%edx
f0101507:	74 21                	je     f010152a <strlcpy+0x35>
f0101509:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010150d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f010150f:	39 c2                	cmp    %eax,%edx
f0101511:	74 14                	je     f0101527 <strlcpy+0x32>
f0101513:	0f b6 19             	movzbl (%ecx),%ebx
f0101516:	84 db                	test   %bl,%bl
f0101518:	74 0b                	je     f0101525 <strlcpy+0x30>
			*dst++ = *src++;
f010151a:	83 c1 01             	add    $0x1,%ecx
f010151d:	83 c2 01             	add    $0x1,%edx
f0101520:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101523:	eb ea                	jmp    f010150f <strlcpy+0x1a>
f0101525:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101527:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010152a:	29 f0                	sub    %esi,%eax
}
f010152c:	5b                   	pop    %ebx
f010152d:	5e                   	pop    %esi
f010152e:	5d                   	pop    %ebp
f010152f:	c3                   	ret    

f0101530 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101530:	55                   	push   %ebp
f0101531:	89 e5                	mov    %esp,%ebp
f0101533:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101536:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101539:	0f b6 01             	movzbl (%ecx),%eax
f010153c:	84 c0                	test   %al,%al
f010153e:	74 0c                	je     f010154c <strcmp+0x1c>
f0101540:	3a 02                	cmp    (%edx),%al
f0101542:	75 08                	jne    f010154c <strcmp+0x1c>
		p++, q++;
f0101544:	83 c1 01             	add    $0x1,%ecx
f0101547:	83 c2 01             	add    $0x1,%edx
f010154a:	eb ed                	jmp    f0101539 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010154c:	0f b6 c0             	movzbl %al,%eax
f010154f:	0f b6 12             	movzbl (%edx),%edx
f0101552:	29 d0                	sub    %edx,%eax
}
f0101554:	5d                   	pop    %ebp
f0101555:	c3                   	ret    

f0101556 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101556:	55                   	push   %ebp
f0101557:	89 e5                	mov    %esp,%ebp
f0101559:	53                   	push   %ebx
f010155a:	8b 45 08             	mov    0x8(%ebp),%eax
f010155d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101560:	89 c3                	mov    %eax,%ebx
f0101562:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101565:	eb 06                	jmp    f010156d <strncmp+0x17>
		n--, p++, q++;
f0101567:	83 c0 01             	add    $0x1,%eax
f010156a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010156d:	39 d8                	cmp    %ebx,%eax
f010156f:	74 16                	je     f0101587 <strncmp+0x31>
f0101571:	0f b6 08             	movzbl (%eax),%ecx
f0101574:	84 c9                	test   %cl,%cl
f0101576:	74 04                	je     f010157c <strncmp+0x26>
f0101578:	3a 0a                	cmp    (%edx),%cl
f010157a:	74 eb                	je     f0101567 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010157c:	0f b6 00             	movzbl (%eax),%eax
f010157f:	0f b6 12             	movzbl (%edx),%edx
f0101582:	29 d0                	sub    %edx,%eax
}
f0101584:	5b                   	pop    %ebx
f0101585:	5d                   	pop    %ebp
f0101586:	c3                   	ret    
		return 0;
f0101587:	b8 00 00 00 00       	mov    $0x0,%eax
f010158c:	eb f6                	jmp    f0101584 <strncmp+0x2e>

f010158e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010158e:	55                   	push   %ebp
f010158f:	89 e5                	mov    %esp,%ebp
f0101591:	8b 45 08             	mov    0x8(%ebp),%eax
f0101594:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101598:	0f b6 10             	movzbl (%eax),%edx
f010159b:	84 d2                	test   %dl,%dl
f010159d:	74 09                	je     f01015a8 <strchr+0x1a>
		if (*s == c)
f010159f:	38 ca                	cmp    %cl,%dl
f01015a1:	74 0a                	je     f01015ad <strchr+0x1f>
	for (; *s; s++)
f01015a3:	83 c0 01             	add    $0x1,%eax
f01015a6:	eb f0                	jmp    f0101598 <strchr+0xa>
			return (char *) s;
	return 0;
f01015a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015ad:	5d                   	pop    %ebp
f01015ae:	c3                   	ret    

f01015af <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01015af:	55                   	push   %ebp
f01015b0:	89 e5                	mov    %esp,%ebp
f01015b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01015b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01015b9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01015bc:	38 ca                	cmp    %cl,%dl
f01015be:	74 09                	je     f01015c9 <strfind+0x1a>
f01015c0:	84 d2                	test   %dl,%dl
f01015c2:	74 05                	je     f01015c9 <strfind+0x1a>
	for (; *s; s++)
f01015c4:	83 c0 01             	add    $0x1,%eax
f01015c7:	eb f0                	jmp    f01015b9 <strfind+0xa>
			break;
	return (char *) s;
}
f01015c9:	5d                   	pop    %ebp
f01015ca:	c3                   	ret    

f01015cb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01015cb:	55                   	push   %ebp
f01015cc:	89 e5                	mov    %esp,%ebp
f01015ce:	57                   	push   %edi
f01015cf:	56                   	push   %esi
f01015d0:	53                   	push   %ebx
f01015d1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01015d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01015d7:	85 c9                	test   %ecx,%ecx
f01015d9:	74 31                	je     f010160c <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01015db:	89 f8                	mov    %edi,%eax
f01015dd:	09 c8                	or     %ecx,%eax
f01015df:	a8 03                	test   $0x3,%al
f01015e1:	75 23                	jne    f0101606 <memset+0x3b>
		c &= 0xFF;
f01015e3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01015e7:	89 d3                	mov    %edx,%ebx
f01015e9:	c1 e3 08             	shl    $0x8,%ebx
f01015ec:	89 d0                	mov    %edx,%eax
f01015ee:	c1 e0 18             	shl    $0x18,%eax
f01015f1:	89 d6                	mov    %edx,%esi
f01015f3:	c1 e6 10             	shl    $0x10,%esi
f01015f6:	09 f0                	or     %esi,%eax
f01015f8:	09 c2                	or     %eax,%edx
f01015fa:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01015fc:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01015ff:	89 d0                	mov    %edx,%eax
f0101601:	fc                   	cld    
f0101602:	f3 ab                	rep stos %eax,%es:(%edi)
f0101604:	eb 06                	jmp    f010160c <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101606:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101609:	fc                   	cld    
f010160a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010160c:	89 f8                	mov    %edi,%eax
f010160e:	5b                   	pop    %ebx
f010160f:	5e                   	pop    %esi
f0101610:	5f                   	pop    %edi
f0101611:	5d                   	pop    %ebp
f0101612:	c3                   	ret    

f0101613 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101613:	55                   	push   %ebp
f0101614:	89 e5                	mov    %esp,%ebp
f0101616:	57                   	push   %edi
f0101617:	56                   	push   %esi
f0101618:	8b 45 08             	mov    0x8(%ebp),%eax
f010161b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010161e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101621:	39 c6                	cmp    %eax,%esi
f0101623:	73 32                	jae    f0101657 <memmove+0x44>
f0101625:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101628:	39 c2                	cmp    %eax,%edx
f010162a:	76 2b                	jbe    f0101657 <memmove+0x44>
		s += n;
		d += n;
f010162c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010162f:	89 fe                	mov    %edi,%esi
f0101631:	09 ce                	or     %ecx,%esi
f0101633:	09 d6                	or     %edx,%esi
f0101635:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010163b:	75 0e                	jne    f010164b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010163d:	83 ef 04             	sub    $0x4,%edi
f0101640:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101643:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101646:	fd                   	std    
f0101647:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101649:	eb 09                	jmp    f0101654 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010164b:	83 ef 01             	sub    $0x1,%edi
f010164e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101651:	fd                   	std    
f0101652:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101654:	fc                   	cld    
f0101655:	eb 1a                	jmp    f0101671 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101657:	89 c2                	mov    %eax,%edx
f0101659:	09 ca                	or     %ecx,%edx
f010165b:	09 f2                	or     %esi,%edx
f010165d:	f6 c2 03             	test   $0x3,%dl
f0101660:	75 0a                	jne    f010166c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101662:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101665:	89 c7                	mov    %eax,%edi
f0101667:	fc                   	cld    
f0101668:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010166a:	eb 05                	jmp    f0101671 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f010166c:	89 c7                	mov    %eax,%edi
f010166e:	fc                   	cld    
f010166f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101671:	5e                   	pop    %esi
f0101672:	5f                   	pop    %edi
f0101673:	5d                   	pop    %ebp
f0101674:	c3                   	ret    

f0101675 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101675:	55                   	push   %ebp
f0101676:	89 e5                	mov    %esp,%ebp
f0101678:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010167b:	ff 75 10             	pushl  0x10(%ebp)
f010167e:	ff 75 0c             	pushl  0xc(%ebp)
f0101681:	ff 75 08             	pushl  0x8(%ebp)
f0101684:	e8 8a ff ff ff       	call   f0101613 <memmove>
}
f0101689:	c9                   	leave  
f010168a:	c3                   	ret    

f010168b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010168b:	55                   	push   %ebp
f010168c:	89 e5                	mov    %esp,%ebp
f010168e:	56                   	push   %esi
f010168f:	53                   	push   %ebx
f0101690:	8b 45 08             	mov    0x8(%ebp),%eax
f0101693:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101696:	89 c6                	mov    %eax,%esi
f0101698:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010169b:	39 f0                	cmp    %esi,%eax
f010169d:	74 1c                	je     f01016bb <memcmp+0x30>
		if (*s1 != *s2)
f010169f:	0f b6 08             	movzbl (%eax),%ecx
f01016a2:	0f b6 1a             	movzbl (%edx),%ebx
f01016a5:	38 d9                	cmp    %bl,%cl
f01016a7:	75 08                	jne    f01016b1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01016a9:	83 c0 01             	add    $0x1,%eax
f01016ac:	83 c2 01             	add    $0x1,%edx
f01016af:	eb ea                	jmp    f010169b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01016b1:	0f b6 c1             	movzbl %cl,%eax
f01016b4:	0f b6 db             	movzbl %bl,%ebx
f01016b7:	29 d8                	sub    %ebx,%eax
f01016b9:	eb 05                	jmp    f01016c0 <memcmp+0x35>
	}

	return 0;
f01016bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016c0:	5b                   	pop    %ebx
f01016c1:	5e                   	pop    %esi
f01016c2:	5d                   	pop    %ebp
f01016c3:	c3                   	ret    

f01016c4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01016c4:	55                   	push   %ebp
f01016c5:	89 e5                	mov    %esp,%ebp
f01016c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01016ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01016cd:	89 c2                	mov    %eax,%edx
f01016cf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01016d2:	39 d0                	cmp    %edx,%eax
f01016d4:	73 09                	jae    f01016df <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01016d6:	38 08                	cmp    %cl,(%eax)
f01016d8:	74 05                	je     f01016df <memfind+0x1b>
	for (; s < ends; s++)
f01016da:	83 c0 01             	add    $0x1,%eax
f01016dd:	eb f3                	jmp    f01016d2 <memfind+0xe>
			break;
	return (void *) s;
}
f01016df:	5d                   	pop    %ebp
f01016e0:	c3                   	ret    

f01016e1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01016e1:	55                   	push   %ebp
f01016e2:	89 e5                	mov    %esp,%ebp
f01016e4:	57                   	push   %edi
f01016e5:	56                   	push   %esi
f01016e6:	53                   	push   %ebx
f01016e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01016ed:	eb 03                	jmp    f01016f2 <strtol+0x11>
		s++;
f01016ef:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01016f2:	0f b6 01             	movzbl (%ecx),%eax
f01016f5:	3c 20                	cmp    $0x20,%al
f01016f7:	74 f6                	je     f01016ef <strtol+0xe>
f01016f9:	3c 09                	cmp    $0x9,%al
f01016fb:	74 f2                	je     f01016ef <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01016fd:	3c 2b                	cmp    $0x2b,%al
f01016ff:	74 2a                	je     f010172b <strtol+0x4a>
	int neg = 0;
f0101701:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101706:	3c 2d                	cmp    $0x2d,%al
f0101708:	74 2b                	je     f0101735 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010170a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101710:	75 0f                	jne    f0101721 <strtol+0x40>
f0101712:	80 39 30             	cmpb   $0x30,(%ecx)
f0101715:	74 28                	je     f010173f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101717:	85 db                	test   %ebx,%ebx
f0101719:	b8 0a 00 00 00       	mov    $0xa,%eax
f010171e:	0f 44 d8             	cmove  %eax,%ebx
f0101721:	b8 00 00 00 00       	mov    $0x0,%eax
f0101726:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101729:	eb 46                	jmp    f0101771 <strtol+0x90>
		s++;
f010172b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010172e:	bf 00 00 00 00       	mov    $0x0,%edi
f0101733:	eb d5                	jmp    f010170a <strtol+0x29>
		s++, neg = 1;
f0101735:	83 c1 01             	add    $0x1,%ecx
f0101738:	bf 01 00 00 00       	mov    $0x1,%edi
f010173d:	eb cb                	jmp    f010170a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010173f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101743:	74 0e                	je     f0101753 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0101745:	85 db                	test   %ebx,%ebx
f0101747:	75 d8                	jne    f0101721 <strtol+0x40>
		s++, base = 8;
f0101749:	83 c1 01             	add    $0x1,%ecx
f010174c:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101751:	eb ce                	jmp    f0101721 <strtol+0x40>
		s += 2, base = 16;
f0101753:	83 c1 02             	add    $0x2,%ecx
f0101756:	bb 10 00 00 00       	mov    $0x10,%ebx
f010175b:	eb c4                	jmp    f0101721 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f010175d:	0f be d2             	movsbl %dl,%edx
f0101760:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101763:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101766:	7d 3a                	jge    f01017a2 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0101768:	83 c1 01             	add    $0x1,%ecx
f010176b:	0f af 45 10          	imul   0x10(%ebp),%eax
f010176f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101771:	0f b6 11             	movzbl (%ecx),%edx
f0101774:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101777:	89 f3                	mov    %esi,%ebx
f0101779:	80 fb 09             	cmp    $0x9,%bl
f010177c:	76 df                	jbe    f010175d <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f010177e:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101781:	89 f3                	mov    %esi,%ebx
f0101783:	80 fb 19             	cmp    $0x19,%bl
f0101786:	77 08                	ja     f0101790 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0101788:	0f be d2             	movsbl %dl,%edx
f010178b:	83 ea 57             	sub    $0x57,%edx
f010178e:	eb d3                	jmp    f0101763 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0101790:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101793:	89 f3                	mov    %esi,%ebx
f0101795:	80 fb 19             	cmp    $0x19,%bl
f0101798:	77 08                	ja     f01017a2 <strtol+0xc1>
			dig = *s - 'A' + 10;
f010179a:	0f be d2             	movsbl %dl,%edx
f010179d:	83 ea 37             	sub    $0x37,%edx
f01017a0:	eb c1                	jmp    f0101763 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f01017a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01017a6:	74 05                	je     f01017ad <strtol+0xcc>
		*endptr = (char *) s;
f01017a8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017ab:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01017ad:	89 c2                	mov    %eax,%edx
f01017af:	f7 da                	neg    %edx
f01017b1:	85 ff                	test   %edi,%edi
f01017b3:	0f 45 c2             	cmovne %edx,%eax
}
f01017b6:	5b                   	pop    %ebx
f01017b7:	5e                   	pop    %esi
f01017b8:	5f                   	pop    %edi
f01017b9:	5d                   	pop    %ebp
f01017ba:	c3                   	ret    
f01017bb:	66 90                	xchg   %ax,%ax
f01017bd:	66 90                	xchg   %ax,%ax
f01017bf:	90                   	nop

f01017c0 <__udivdi3>:
f01017c0:	f3 0f 1e fb          	endbr32 
f01017c4:	55                   	push   %ebp
f01017c5:	57                   	push   %edi
f01017c6:	56                   	push   %esi
f01017c7:	53                   	push   %ebx
f01017c8:	83 ec 1c             	sub    $0x1c,%esp
f01017cb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01017cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01017d3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01017d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01017db:	85 d2                	test   %edx,%edx
f01017dd:	75 19                	jne    f01017f8 <__udivdi3+0x38>
f01017df:	39 f3                	cmp    %esi,%ebx
f01017e1:	76 4d                	jbe    f0101830 <__udivdi3+0x70>
f01017e3:	31 ff                	xor    %edi,%edi
f01017e5:	89 e8                	mov    %ebp,%eax
f01017e7:	89 f2                	mov    %esi,%edx
f01017e9:	f7 f3                	div    %ebx
f01017eb:	89 fa                	mov    %edi,%edx
f01017ed:	83 c4 1c             	add    $0x1c,%esp
f01017f0:	5b                   	pop    %ebx
f01017f1:	5e                   	pop    %esi
f01017f2:	5f                   	pop    %edi
f01017f3:	5d                   	pop    %ebp
f01017f4:	c3                   	ret    
f01017f5:	8d 76 00             	lea    0x0(%esi),%esi
f01017f8:	39 f2                	cmp    %esi,%edx
f01017fa:	76 14                	jbe    f0101810 <__udivdi3+0x50>
f01017fc:	31 ff                	xor    %edi,%edi
f01017fe:	31 c0                	xor    %eax,%eax
f0101800:	89 fa                	mov    %edi,%edx
f0101802:	83 c4 1c             	add    $0x1c,%esp
f0101805:	5b                   	pop    %ebx
f0101806:	5e                   	pop    %esi
f0101807:	5f                   	pop    %edi
f0101808:	5d                   	pop    %ebp
f0101809:	c3                   	ret    
f010180a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101810:	0f bd fa             	bsr    %edx,%edi
f0101813:	83 f7 1f             	xor    $0x1f,%edi
f0101816:	75 48                	jne    f0101860 <__udivdi3+0xa0>
f0101818:	39 f2                	cmp    %esi,%edx
f010181a:	72 06                	jb     f0101822 <__udivdi3+0x62>
f010181c:	31 c0                	xor    %eax,%eax
f010181e:	39 eb                	cmp    %ebp,%ebx
f0101820:	77 de                	ja     f0101800 <__udivdi3+0x40>
f0101822:	b8 01 00 00 00       	mov    $0x1,%eax
f0101827:	eb d7                	jmp    f0101800 <__udivdi3+0x40>
f0101829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101830:	89 d9                	mov    %ebx,%ecx
f0101832:	85 db                	test   %ebx,%ebx
f0101834:	75 0b                	jne    f0101841 <__udivdi3+0x81>
f0101836:	b8 01 00 00 00       	mov    $0x1,%eax
f010183b:	31 d2                	xor    %edx,%edx
f010183d:	f7 f3                	div    %ebx
f010183f:	89 c1                	mov    %eax,%ecx
f0101841:	31 d2                	xor    %edx,%edx
f0101843:	89 f0                	mov    %esi,%eax
f0101845:	f7 f1                	div    %ecx
f0101847:	89 c6                	mov    %eax,%esi
f0101849:	89 e8                	mov    %ebp,%eax
f010184b:	89 f7                	mov    %esi,%edi
f010184d:	f7 f1                	div    %ecx
f010184f:	89 fa                	mov    %edi,%edx
f0101851:	83 c4 1c             	add    $0x1c,%esp
f0101854:	5b                   	pop    %ebx
f0101855:	5e                   	pop    %esi
f0101856:	5f                   	pop    %edi
f0101857:	5d                   	pop    %ebp
f0101858:	c3                   	ret    
f0101859:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101860:	89 f9                	mov    %edi,%ecx
f0101862:	b8 20 00 00 00       	mov    $0x20,%eax
f0101867:	29 f8                	sub    %edi,%eax
f0101869:	d3 e2                	shl    %cl,%edx
f010186b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010186f:	89 c1                	mov    %eax,%ecx
f0101871:	89 da                	mov    %ebx,%edx
f0101873:	d3 ea                	shr    %cl,%edx
f0101875:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101879:	09 d1                	or     %edx,%ecx
f010187b:	89 f2                	mov    %esi,%edx
f010187d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101881:	89 f9                	mov    %edi,%ecx
f0101883:	d3 e3                	shl    %cl,%ebx
f0101885:	89 c1                	mov    %eax,%ecx
f0101887:	d3 ea                	shr    %cl,%edx
f0101889:	89 f9                	mov    %edi,%ecx
f010188b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010188f:	89 eb                	mov    %ebp,%ebx
f0101891:	d3 e6                	shl    %cl,%esi
f0101893:	89 c1                	mov    %eax,%ecx
f0101895:	d3 eb                	shr    %cl,%ebx
f0101897:	09 de                	or     %ebx,%esi
f0101899:	89 f0                	mov    %esi,%eax
f010189b:	f7 74 24 08          	divl   0x8(%esp)
f010189f:	89 d6                	mov    %edx,%esi
f01018a1:	89 c3                	mov    %eax,%ebx
f01018a3:	f7 64 24 0c          	mull   0xc(%esp)
f01018a7:	39 d6                	cmp    %edx,%esi
f01018a9:	72 15                	jb     f01018c0 <__udivdi3+0x100>
f01018ab:	89 f9                	mov    %edi,%ecx
f01018ad:	d3 e5                	shl    %cl,%ebp
f01018af:	39 c5                	cmp    %eax,%ebp
f01018b1:	73 04                	jae    f01018b7 <__udivdi3+0xf7>
f01018b3:	39 d6                	cmp    %edx,%esi
f01018b5:	74 09                	je     f01018c0 <__udivdi3+0x100>
f01018b7:	89 d8                	mov    %ebx,%eax
f01018b9:	31 ff                	xor    %edi,%edi
f01018bb:	e9 40 ff ff ff       	jmp    f0101800 <__udivdi3+0x40>
f01018c0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01018c3:	31 ff                	xor    %edi,%edi
f01018c5:	e9 36 ff ff ff       	jmp    f0101800 <__udivdi3+0x40>
f01018ca:	66 90                	xchg   %ax,%ax
f01018cc:	66 90                	xchg   %ax,%ax
f01018ce:	66 90                	xchg   %ax,%ax

f01018d0 <__umoddi3>:
f01018d0:	f3 0f 1e fb          	endbr32 
f01018d4:	55                   	push   %ebp
f01018d5:	57                   	push   %edi
f01018d6:	56                   	push   %esi
f01018d7:	53                   	push   %ebx
f01018d8:	83 ec 1c             	sub    $0x1c,%esp
f01018db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01018df:	8b 74 24 30          	mov    0x30(%esp),%esi
f01018e3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01018e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01018eb:	85 c0                	test   %eax,%eax
f01018ed:	75 19                	jne    f0101908 <__umoddi3+0x38>
f01018ef:	39 df                	cmp    %ebx,%edi
f01018f1:	76 5d                	jbe    f0101950 <__umoddi3+0x80>
f01018f3:	89 f0                	mov    %esi,%eax
f01018f5:	89 da                	mov    %ebx,%edx
f01018f7:	f7 f7                	div    %edi
f01018f9:	89 d0                	mov    %edx,%eax
f01018fb:	31 d2                	xor    %edx,%edx
f01018fd:	83 c4 1c             	add    $0x1c,%esp
f0101900:	5b                   	pop    %ebx
f0101901:	5e                   	pop    %esi
f0101902:	5f                   	pop    %edi
f0101903:	5d                   	pop    %ebp
f0101904:	c3                   	ret    
f0101905:	8d 76 00             	lea    0x0(%esi),%esi
f0101908:	89 f2                	mov    %esi,%edx
f010190a:	39 d8                	cmp    %ebx,%eax
f010190c:	76 12                	jbe    f0101920 <__umoddi3+0x50>
f010190e:	89 f0                	mov    %esi,%eax
f0101910:	89 da                	mov    %ebx,%edx
f0101912:	83 c4 1c             	add    $0x1c,%esp
f0101915:	5b                   	pop    %ebx
f0101916:	5e                   	pop    %esi
f0101917:	5f                   	pop    %edi
f0101918:	5d                   	pop    %ebp
f0101919:	c3                   	ret    
f010191a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101920:	0f bd e8             	bsr    %eax,%ebp
f0101923:	83 f5 1f             	xor    $0x1f,%ebp
f0101926:	75 50                	jne    f0101978 <__umoddi3+0xa8>
f0101928:	39 d8                	cmp    %ebx,%eax
f010192a:	0f 82 e0 00 00 00    	jb     f0101a10 <__umoddi3+0x140>
f0101930:	89 d9                	mov    %ebx,%ecx
f0101932:	39 f7                	cmp    %esi,%edi
f0101934:	0f 86 d6 00 00 00    	jbe    f0101a10 <__umoddi3+0x140>
f010193a:	89 d0                	mov    %edx,%eax
f010193c:	89 ca                	mov    %ecx,%edx
f010193e:	83 c4 1c             	add    $0x1c,%esp
f0101941:	5b                   	pop    %ebx
f0101942:	5e                   	pop    %esi
f0101943:	5f                   	pop    %edi
f0101944:	5d                   	pop    %ebp
f0101945:	c3                   	ret    
f0101946:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010194d:	8d 76 00             	lea    0x0(%esi),%esi
f0101950:	89 fd                	mov    %edi,%ebp
f0101952:	85 ff                	test   %edi,%edi
f0101954:	75 0b                	jne    f0101961 <__umoddi3+0x91>
f0101956:	b8 01 00 00 00       	mov    $0x1,%eax
f010195b:	31 d2                	xor    %edx,%edx
f010195d:	f7 f7                	div    %edi
f010195f:	89 c5                	mov    %eax,%ebp
f0101961:	89 d8                	mov    %ebx,%eax
f0101963:	31 d2                	xor    %edx,%edx
f0101965:	f7 f5                	div    %ebp
f0101967:	89 f0                	mov    %esi,%eax
f0101969:	f7 f5                	div    %ebp
f010196b:	89 d0                	mov    %edx,%eax
f010196d:	31 d2                	xor    %edx,%edx
f010196f:	eb 8c                	jmp    f01018fd <__umoddi3+0x2d>
f0101971:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101978:	89 e9                	mov    %ebp,%ecx
f010197a:	ba 20 00 00 00       	mov    $0x20,%edx
f010197f:	29 ea                	sub    %ebp,%edx
f0101981:	d3 e0                	shl    %cl,%eax
f0101983:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101987:	89 d1                	mov    %edx,%ecx
f0101989:	89 f8                	mov    %edi,%eax
f010198b:	d3 e8                	shr    %cl,%eax
f010198d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101991:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101995:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101999:	09 c1                	or     %eax,%ecx
f010199b:	89 d8                	mov    %ebx,%eax
f010199d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01019a1:	89 e9                	mov    %ebp,%ecx
f01019a3:	d3 e7                	shl    %cl,%edi
f01019a5:	89 d1                	mov    %edx,%ecx
f01019a7:	d3 e8                	shr    %cl,%eax
f01019a9:	89 e9                	mov    %ebp,%ecx
f01019ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01019af:	d3 e3                	shl    %cl,%ebx
f01019b1:	89 c7                	mov    %eax,%edi
f01019b3:	89 d1                	mov    %edx,%ecx
f01019b5:	89 f0                	mov    %esi,%eax
f01019b7:	d3 e8                	shr    %cl,%eax
f01019b9:	89 e9                	mov    %ebp,%ecx
f01019bb:	89 fa                	mov    %edi,%edx
f01019bd:	d3 e6                	shl    %cl,%esi
f01019bf:	09 d8                	or     %ebx,%eax
f01019c1:	f7 74 24 08          	divl   0x8(%esp)
f01019c5:	89 d1                	mov    %edx,%ecx
f01019c7:	89 f3                	mov    %esi,%ebx
f01019c9:	f7 64 24 0c          	mull   0xc(%esp)
f01019cd:	89 c6                	mov    %eax,%esi
f01019cf:	89 d7                	mov    %edx,%edi
f01019d1:	39 d1                	cmp    %edx,%ecx
f01019d3:	72 06                	jb     f01019db <__umoddi3+0x10b>
f01019d5:	75 10                	jne    f01019e7 <__umoddi3+0x117>
f01019d7:	39 c3                	cmp    %eax,%ebx
f01019d9:	73 0c                	jae    f01019e7 <__umoddi3+0x117>
f01019db:	2b 44 24 0c          	sub    0xc(%esp),%eax
f01019df:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01019e3:	89 d7                	mov    %edx,%edi
f01019e5:	89 c6                	mov    %eax,%esi
f01019e7:	89 ca                	mov    %ecx,%edx
f01019e9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01019ee:	29 f3                	sub    %esi,%ebx
f01019f0:	19 fa                	sbb    %edi,%edx
f01019f2:	89 d0                	mov    %edx,%eax
f01019f4:	d3 e0                	shl    %cl,%eax
f01019f6:	89 e9                	mov    %ebp,%ecx
f01019f8:	d3 eb                	shr    %cl,%ebx
f01019fa:	d3 ea                	shr    %cl,%edx
f01019fc:	09 d8                	or     %ebx,%eax
f01019fe:	83 c4 1c             	add    $0x1c,%esp
f0101a01:	5b                   	pop    %ebx
f0101a02:	5e                   	pop    %esi
f0101a03:	5f                   	pop    %edi
f0101a04:	5d                   	pop    %ebp
f0101a05:	c3                   	ret    
f0101a06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a0d:	8d 76 00             	lea    0x0(%esi),%esi
f0101a10:	29 fe                	sub    %edi,%esi
f0101a12:	19 c3                	sbb    %eax,%ebx
f0101a14:	89 f2                	mov    %esi,%edx
f0101a16:	89 d9                	mov    %ebx,%ecx
f0101a18:	e9 1d ff ff ff       	jmp    f010193a <__umoddi3+0x6a>
