CROSS_COMPILE ?= aarch64-linux-gnu-

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

COMP = 1

ASFLAGS =	-g --defsym comp=$(COMP)
LDFLAGS =	-g -static

SRCS = prog2.s
OBJS = $(SRCS:.s=.o)

EXE = prog2

all: clean $(EXE)

clean:
		rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
		$(LD) $(LDFLAGS) $(OBJS) -o $(EXE)

$(OBJS):
		$(AS) $(ASFLAGS) $(SRCS) -o $(OBJS)

