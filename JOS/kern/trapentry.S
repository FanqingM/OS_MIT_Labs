/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
    .data;  \
        .long name; \
    .text;  \
        .globl name;		/* define global symbol for 'name' */	\
    	.type name, @function;	/* symbol type is function */		\
    	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
        .if !(num == 8 || num == 17 || (num >= 10 && num <= 14));   \
        pushl $0;   \
        .endif;     \
    	pushl $(num);							\
    	jmp _alltraps


.data
    .globl  vectors

vectors:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
/*
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
*/
//Challenge
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


