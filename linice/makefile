##############################################################################
#																			 #
#	Makefile for LINICE kernel module										 #
#																			 #
#	(c) 2000-2005 Goran Devic												 #
#	(c) "Linice" by Goran Devic												 #
#	(c) "Linsym" by Goran Devic												 #
#																			 #
##############################################################################

#-----------------------------------------------------------------------------
# List of include directories
#-----------------------------------------------------------------------------

INC = include
H1  = ../include
H2  = ../bin

#-----------------------------------------------------------------------------
# Compiler defines:
#   make 				- engineering non-debug build (default)
#	make debug			- engineering debug build
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# Compiler defines: Engineering NON-DEBUG build (default)
#-----------------------------------------------------------------------------

DEF = -DMODULE -DLINUX -DND
CFLAGS = -Wall $(DEF) -O2 -I$(INC) -I$(H1) -I$(H2)

#-----------------------------------------------------------------------------
# Compiler defines: Engineering DEBUG build (Development)
#-----------------------------------------------------------------------------
ifeq ($(MAKECMDGOALS),debug)

DEF    = -DMODULE -DLINUX -DDBG
CFLAGS = -gstabs+ -Wall $(DEF) -O -I$(INC) -I$(H1) -I$(H2)

endif
#-----------------------------------------------------------------------------
# Compiler and assembler that are used. nasm is a mandatory assembler.
#-----------------------------------------------------------------------------

CC = gcc
AS = nasm

#-----------------------------------------------------------------------------
# Formal targets
#-----------------------------------------------------------------------------

debug:	../bin/linice_kernel.o ../bin/Version.txt

nd:		../bin/linice_kernel.o ../bin/Version.txt
	perl strip_symbols.pl ../bin/linice_kernel.o

all:	../bin/linice_kernel.o ../bin/Version.txt

clean:
	rm -f ../bin/linice_kernel.o
	rm -f *.o *~ core
	rm -f ../bin/Version.txt

#-----------------------------------------------------------------------------
# List of object modules that build the target
#-----------------------------------------------------------------------------

# Generate a version text file (version + date/time stamp)

../bin/Version.txt:
	@perl make_version.pl

../bin/linice_kernel.o:		\
			objectstart.o	\
			driver.o		\
			i386.o			\
			malloc.o		\
			memaccess.o		\
			evalex.o		\
			init.o			\
			errors.o		\
			syscall.o		\
			task.o		    \
			symbolTable.o	\
			symbols.o		\
			context.o		\
			types.o			\
			typesprint.o	\
			string.o 		\
			printf.o 		\
			printk.o 		\
			ctype.o			\
			proc.o			\
			edlin.o			\
			debugger.o		\
			dis.o			\
			dis_len.o		\
			dis_ea.o		\
			interrupt.o		\
			apic.o			\
			command.o		\
			registers.o		\
			lists.o			\
			locals.o		\
			stack.o			\
			watch.o			\
			data.o			\
			code.o			\
			customization.o	\
			windowcontrol.o	\
			blockops.o		\
			ioport.o		\
			sysinfo.o		\
			page.o			\
			breakpoints.o	\
			pci.o			\
			flow.o			\
			history.o		\
			messages.o		\
			input.o			\
			keyboard.o		\
			vt100i.o		\
			mouse.o			\
			serial.o		\
			output.o		\
			font.o      	\
			window.o		\
			vga.o			\
			mda.o			\
			lfb.o			\
            vt100o.o		\
			extend.o		\
			objectend.o		\
			endasm.o
	$(LD) -r $^ -o ../bin/linice_kernel.o

objectstart.o:	objectstart.c
	$(CC) $(CFLAGS) -c objectstart.c

driver.o:	driver.c
	$(CC) $(CFLAGS) -c driver.c

malloc.o:	malloc.c
	$(CC) $(CFLAGS) -c malloc.c

memaccess.o:	memaccess.c
	$(CC) $(CFLAGS) -c memaccess.c

init.o:		init.c
	$(CC) $(CFLAGS) -c init.c

errors.o:		errors.c
	$(CC) $(CFLAGS) -c errors.c

syscall.o:		syscall.c
	$(CC) $(CFLAGS) -c syscall.c

task.o:			task.c
	$(CC) $(CFLAGS) -c task.c

symbolTable.o:		symbolTable.c
	$(CC) $(CFLAGS) -c symbolTable.c

symbols.o:		symbols.c
	$(CC) $(CFLAGS) -c symbols.c

context.o:		context.c
	$(CC) $(CFLAGS) -c context.c

types.o:		types.c
	$(CC) $(CFLAGS) -c types.c

typesprint.o:		typesprint.c
	$(CC) $(CFLAGS) -c typesprint.c

string.o:		string.c
	$(CC) $(CFLAGS) -c string.c

printf.o:		printf.c
	$(CC) $(CFLAGS) -c printf.c

printk.o:		printk.c
	$(CC) $(CFLAGS) -c printk.c

ctype.o:		ctype.c
	$(CC) $(CFLAGS) -c ctype.c

proc.o:		proc.c
	$(CC) $(CFLAGS) -c proc.c

interrupt.o:		interrupt.c
	$(CC) $(CFLAGS) -c interrupt.c

apic.o:		apic.c
	$(CC) $(CFLAGS) -c apic.c

history.o:	history.c
	$(CC) $(CFLAGS) -c history.c

messages.o:	messages.c
	$(CC) $(CFLAGS) -c messages.c

debugger.o:	command/debugger.c
	$(CC) $(CFLAGS) -c command/debugger.c

dis.o:	command/disassembler.c
	$(CC) $(CFLAGS) -c command/disassembler.c -o dis.o

dis_len.o:	command/disassembler-bytelen.c
	$(CC) $(CFLAGS) -c command/disassembler-bytelen.c -o dis_len.o

dis_ea.o:	command/disassembler-ea.c
	$(CC) $(CFLAGS) -c command/disassembler-ea.c -o dis_ea.o

edlin.o:	command/edlin.c
	$(CC) $(CFLAGS) -c command/edlin.c

command.o:	command/command.c
	$(CC) $(CFLAGS) -c command/command.c

evalex.o:	command/evalex.c
	$(CC) $(CFLAGS) -c command/evalex.c

registers.o:		command/registers.c
	$(CC) $(CFLAGS) -c command/registers.c

lists.o:			command/lists.c
	$(CC) $(CFLAGS) -c command/lists.c

locals.o:	command/locals.c
	$(CC) $(CFLAGS) -c command/locals.c

stack.o:	command/stack.c
	$(CC) $(CFLAGS) -c command/stack.c

watch.o:	command/watch.c
	$(CC) $(CFLAGS) -c command/watch.c

data.o:		command/data.c
	$(CC) $(CFLAGS) -c command/data.c

code.o:		command/code.c
	$(CC) $(CFLAGS) -c command/code.c

customization.o:		command/customization.c
	$(CC) $(CFLAGS) -c command/customization.c

windowcontrol.o:		command/windowcontrol.c
	$(CC) $(CFLAGS) -c command/windowcontrol.c

blockops.o:		command/blockops.c
	$(CC) $(CFLAGS) -c command/blockops.c

ioport.o:		command/ioport.c
	$(CC) $(CFLAGS) -c command/ioport.c

sysinfo.o:		command/sysinfo.c
	$(CC) $(CFLAGS) -c command/sysinfo.c

page.o:		    command/page.c
	$(CC) $(CFLAGS) -c command/page.c

breakpoints.o:	command/breakpoints.c
	$(CC) $(CFLAGS) -c command/breakpoints.c

pci.o:		    command/pci.c
	$(CC) $(CFLAGS) -c command/pci.c

flow.o:		command/flow.c
	$(CC) $(CFLAGS) -c command/flow.c

input.o:	input/input.c
	$(CC) $(CFLAGS) -c input/input.c

keyboard.o:	input/keyboard.c
	$(CC) $(CFLAGS) -c input/keyboard.c

vt100i.o:	input/vt100.c
	$(CC) $(CFLAGS) -c input/vt100.c -o vt100i.o

mouse.o:	input/mouse.c
	$(CC) $(CFLAGS) -c input/mouse.c

serial.o:	serial.c
	$(CC) $(CFLAGS) -c serial.c -o serial.o

output.o:	output/output.c
	$(CC) $(CFLAGS) -c output/output.c

font.o:		output/font.c
	$(CC) $(CFLAGS) -c output/font.c

window.o:	output/window.c
	$(CC) $(CFLAGS) -c output/window.c

vga.o:		output/vga.c
	$(CC) $(CFLAGS) -c output/vga.c

mda.o:		output/mda.c
	$(CC) $(CFLAGS) -c output/mda.c

lfb.o:		output/lfb.c
	$(CC) $(CFLAGS) -c output/lfb.c

vt100o.o:	output/vt100o.c
	$(CC) $(CFLAGS) -c output/vt100o.c -o vt100o.o

extend.o:	extend.c
	$(CC) $(CFLAGS) -c extend.c -o extend.o

i386.o:		i386.asm
	$(AS) -f elf i386.asm -o i386.o

objectend.o:	objectend.c
	$(CC) $(CFLAGS) -c objectend.c

endasm.o:		endasm.asm
	$(AS) -f elf endasm.asm -o endasm.o

